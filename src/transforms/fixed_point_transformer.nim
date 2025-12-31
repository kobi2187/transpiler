## Fixed-Point Transformer (Lowering Manager)
##
## Repeatedly applies lowering transformations until a fixed point is reached.
## Purpose: Transform language-specific AST nodes into output-language-compatible forms.
##
## Algorithm:
## 1. Collect all transforms and their target node kinds
## 2. Traverse entire AST tree
## 3. Apply matching transforms to nodes
## 4. Repeat until no more transformations occur (fixed point)

import core/xlangtypes
import types
import transform_context
import error_collector
import semantic/semantic_analysis
import tables
import sets, strutils, sequtils

import core/helpers


type
  FixedPointResult* = object
    ## Result of running the fixed-point transformer
    success*: bool
    iterations*: int
    loopWarning*: bool
    loopKinds*: seq[XLangNodeKind]
    maxIterationsReached*: bool

  FixedPointTransformer* = ref object
    ## Fixed-point lowering transformer
    ## Repeatedly applies transforms until AST stabilizes
    kindToTransform*: Table[XLangNodeKind, TransformPass]
    activeKinds*: HashSet[XLangNodeKind]
    maxIterations*: int
    errorCollector*: ErrorCollector
    transformContext*: TransformContext  # Central context for transforms
    result*: FixedPointResult

proc newFixedPointTransformer*(maxIterations: int = 10000,
                                errorCollector: ErrorCollector = nil): FixedPointTransformer =
  ## Create a new fixed-point transformer
  FixedPointTransformer(
    kindToTransform: initTable[XLangNodeKind, TransformPass](), # 1:1 mapping
    activeKinds: initHashSet[XLangNodeKind](),
    maxIterations: maxIterations,
    errorCollector: if errorCollector != nil: errorCollector else: newErrorCollector(),
    result: FixedPointResult(success: true, iterations: 0, loopWarning: false, loopKinds: @[], maxIterationsReached: false)
  )

# [v]
proc addTransforms*(pm: FixedPointTransformer, transforms: seq[TransformPass]) =
  ## Add transforms to the manager, building the kind->transform mapping
  for transform in transforms:       
    # Map each target kind to this transform
    for kind in transform.operatesOnKinds:
      pm.activeKinds.incl(kind)
      pm.kindToTransform[kind] = transform


proc applyTransform*(pm: FixedPointTransformer, node: var XLangNode,
                     counter: var int, applicableKinds: HashSet[XLangNodeKind],
                     reintroducedKinds: var HashSet[XLangNodeKind]) =
  let kind = node.kind
  # Skip if this kind is not applicable in this iteration
  if kind notin applicableKinds:
    return

  let transform = pm.kindToTransform.getOrDefault(kind, nil)
  if transform != nil:
    let newNode = transform.transform(node, pm.transformContext)
    # Only count as transformation if the node actually changed
    if newNode != node:
      node = newNode
      counter.inc()
      # Track if the transform produced a kind that has a registered transform
      # This could indicate a cycle
      if node.kind in pm.activeKinds:
        reintroducedKinds.incl(node.kind)

proc run*(pm: FixedPointTransformer, root: var XLangNode, verbose: bool = false,
          ctx: TransformContext): XLangNode =
  ## Run the pass manager on the given AST until fixed point is reached.
  ## Transforms access all services via the TransformContext.
  pm.transformContext = ctx
  pm.transformContext.transformCount = 0
  var counter = 1  # Initialize to 1 to enter the loop
  var iterations = 0
  const loopWarningThreshold = 20
  const progressInterval = 100  # Print progress every N iterations

  # Track kinds that get reintroduced by transforms (potential cycles)
  var reintroducedKinds: HashSet[XLangNodeKind] = initHashSet[XLangNodeKind]()
  var cycleWarningShown = false

  # Reset result
  pm.result = FixedPointResult(success: true, iterations: 0, loopWarning: false, loopKinds: @[], maxIterationsReached: false)

  while counter > 0 and iterations < pm.maxIterations:
    counter = 0
    iterations.inc()
    reintroducedKinds.clear()

    # Progress feedback for long-running transforms
    if verbose and iterations mod progressInterval == 0:
      stderr.write("\r  Pass iteration: " & $iterations & "...")
      stderr.flushFile()

    # Collect all kinds present in the tree for this iteration
    var treeKinds = collectAllKinds(root)

    # Calculate applicable transforms for this iteration (intersection)
    let applicableKinds = pm.activeKinds * treeKinds

    if applicableKinds.len == 0:
      break

    # Traverse entire tree and apply only applicable transforms
    traverseTree(root, proc(node: var XLangNode) =
      applyTransform(pm, node, counter, applicableKinds, reintroducedKinds))

    # Detect cycle: transforms are producing kinds that trigger more transforms
    if reintroducedKinds.len > 0 and iterations >= loopWarningThreshold and not cycleWarningShown:
      pm.result.loopWarning = true
      for kind in reintroducedKinds:
        pm.result.loopKinds.add(kind)
      if verbose:
        stderr.write("\n  WARNING: Potential transform cycle detected at iteration " & $iterations & "\n")
        stderr.write("    Transforms producing triggerable kinds: ")
        for k in reintroducedKinds:
          stderr.write($k & " ")
        stderr.write("\n")
        stderr.flushFile()
      cycleWarningShown = true

    if iterations >= pm.maxIterations:
      pm.result.maxIterationsReached = true
      pm.result.success = false
      let cycleInfo = if reintroducedKinds.len > 0:
        " (cycle on: " & reintroducedKinds.toSeq.mapIt($it).join(", ") & ")"
      else:
        ""
      pm.errorCollector.addError(tekTransformLimitReachedError,
        "FixedPointTransformer: Max iterations reached" & cycleInfo)
      break

    if counter == 0:
      break

  # Clear progress line if we printed any
  if verbose and iterations >= progressInterval:
    stderr.write("\r" & " ".repeat(40) & "\r")
    stderr.flushFile()

  pm.result.iterations = iterations
  result = root

