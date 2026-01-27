## Fixed-Point Transformer (Lowering Manager)
##
## Repeatedly applies lowering transformations until a fixed point is reached.
## Each proc does one thing. Names are self-documenting.
##
## Algorithm:
## 1. Collect all transforms and their target node kinds
## 2. Traverse entire AST tree
## 3. Apply matching transforms to nodes
## 4. Repeat until no more transformations occur (fixed point)

import core/xlangtypes
import core/xlang_printer
import types
import transform_context
import error_collector
# import options
# import semantic/semantic_analysis
import tables
import sets, strutils, sequtils
import core/helpers

# =============================================================================
# Types
# =============================================================================

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
    kindToTransform*: Table[XLangNodeKind, TransformPass]
    activeKinds*: HashSet[XLangNodeKind]
    maxIterations*: int
    errorCollector*: ErrorCollector
    transformContext*: TransformContext
    result*: FixedPointResult

# =============================================================================
# Constants
# =============================================================================

const
  defaultMaxIterations = 10000
  loopWarningThreshold = 20
  progressInterval = 100

# =============================================================================
# Result Helpers
# =============================================================================

proc initResult(): FixedPointResult =
  ## Initialize a fresh result
  FixedPointResult(
    success: true,
    iterations: 0,
    loopWarning: false,
    loopKinds: @[],
    maxIterationsReached: false
  )

proc markLoopWarning(result: var FixedPointResult, kinds: HashSet[XLangNodeKind]) =
  ## Mark that a potential loop was detected
  result.loopWarning = true
  for kind in kinds:
    result.loopKinds.add(kind)

proc markMaxReached(result: var FixedPointResult) =
  ## Mark that max iterations was reached
  result.maxIterationsReached = true
  result.success = false

# =============================================================================
# Transformer Creation
# =============================================================================

proc newFixedPointTransformer*(maxIterations: int = defaultMaxIterations,
                                errorCollector: ErrorCollector = nil): FixedPointTransformer =
  ## Create a new fixed-point transformer
  FixedPointTransformer(
    kindToTransform: initTable[XLangNodeKind, TransformPass](),
    activeKinds: initHashSet[XLangNodeKind](),
    maxIterations: maxIterations,
    errorCollector: if errorCollector != nil: errorCollector else: newErrorCollector(),
    result: initResult()
  )

# =============================================================================
# Transform Registration
# =============================================================================

proc registerTransformForKind(pm: FixedPointTransformer, kind: XLangNodeKind, transform: TransformPass) =
  ## Register a transform for a specific kind
  pm.activeKinds.incl(kind)
  pm.kindToTransform[kind] = transform

proc addTransforms*(pm: FixedPointTransformer, transforms: seq[TransformPass]) =
  ## Add transforms to the manager
  for transform in transforms:
    for kind in transform.operatesOnKinds:
      registerTransformForKind(pm, kind, transform)

# =============================================================================
# Transform Application Helpers
# =============================================================================

proc isApplicable(kind: XLangNodeKind, applicableKinds: HashSet[XLangNodeKind]): bool =
  ## Check if a kind is applicable in this iteration
  kind in applicableKinds

proc getTransformForKind(pm: FixedPointTransformer, kind: XLangNodeKind): TransformPass =
  ## Get the transform for a kind, or nil if none
  pm.kindToTransform.getOrDefault(kind, nil)

proc nodeWasTransformed(oldNode, newNode: XLangNode): bool =
  ## Check if a node was changed by a transform
  newNode != oldNode

proc trackReintroducedKind(kind: XLangNodeKind, activeKinds: HashSet[XLangNodeKind], reintroducedKinds: var HashSet[XLangNodeKind]) =
  ## Track if transform produced a kind that could trigger more transforms
  if kind in activeKinds:
    reintroducedKinds.incl(kind)

proc applyTransform*(pm: FixedPointTransformer, node: var XLangNode,
                     counter: var int, applicableKinds: HashSet[XLangNodeKind],
                     reintroducedKinds: var HashSet[XLangNodeKind]) =
  ## Apply transform to a single node if applicable
  let kind = node.kind
  
  if not isApplicable(kind, applicableKinds):
    return
  
  let transform = getTransformForKind(pm, kind)
  if transform == nil:
    return
  
  let newNode = transform.transform(node, pm.transformContext)
  if nodeWasTransformed(node, newNode):
    node = newNode
    counter.inc()
    trackReintroducedKind(node.kind, pm.activeKinds, reintroducedKinds)

# =============================================================================
# Iteration Helpers
# =============================================================================

proc computeApplicableKinds(pm: FixedPointTransformer, root: var XLangNode): HashSet[XLangNodeKind] =
  ## Compute which transforms can apply in this iteration
  let treeKinds = collectAllKinds(root)
  pm.activeKinds * treeKinds

proc hasNoApplicableKinds(kinds: HashSet[XLangNodeKind]): bool =
  ## Check if no transforms can apply
  kinds.len == 0

proc shouldShowProgress(iterations: int, verbose: bool): bool =
  ## Check if we should show progress
  verbose and iterations mod progressInterval == 0

proc showProgress(iterations: int) =
  ## Show iteration progress
  stderr.write("\r  Pass iteration: " & $iterations & "...")
  stderr.flushFile()

proc clearProgress(verbose: bool, iterations: int) =
  ## Clear progress line if we showed any
  if verbose and iterations >= progressInterval:
    stderr.write("\r" & " ".repeat(40) & "\r")
    stderr.flushFile()

# =============================================================================
# Cycle Detection Helpers
# =============================================================================

proc shouldWarnAboutCycle(iterations: int, reintroducedKinds: HashSet[XLangNodeKind], alreadyWarned: bool): bool =
  ## Check if we should warn about a potential cycle
  reintroducedKinds.len > 0 and iterations >= loopWarningThreshold and not alreadyWarned

proc showCycleWarning(iterations: int, kinds: HashSet[XLangNodeKind], verbose: bool) =
  ## Show warning about potential cycle
  if verbose:
    stderr.write("\n  WARNING: Potential transform cycle detected at iteration " & $iterations & "\n")
    stderr.write("    Transforms producing triggerable kinds: ")
    for k in kinds:
      stderr.write($k & " ")
    stderr.write("\n")
    stderr.flushFile()

# =============================================================================
# Max Iterations Helpers
# =============================================================================

proc reachedMaxIterations(iterations, maxIterations: int): bool =
  ## Check if max iterations reached
  iterations >= maxIterations

proc buildCycleInfo(kinds: HashSet[XLangNodeKind]): string =
  ## Build cycle info string for error message
  if kinds.len > 0:
    " (cycle on: " & kinds.toSeq.mapIt($it).join(", ") & ")"
  else:
    ""

proc reportMaxIterationsError(pm: FixedPointTransformer, kinds: HashSet[XLangNodeKind]) =
  ## Report max iterations error
  let cycleInfo = buildCycleInfo(kinds)
  pm.errorCollector.addError(tekTransformLimitReachedError,
    "FixedPointTransformer: Max iterations reached" & cycleInfo)

# =============================================================================
# Main Run Loop
# =============================================================================

proc run*(pm: FixedPointTransformer, root: var XLangNode, verbose: bool = false, xlangOutput: bool = false,
          ctx: TransformContext): XLangNode =
  ## Run transforms until fixed point is reached
  pm.transformContext = ctx
  pm.transformContext.transform.transformCount = 0
  pm.result = initResult()
  
  var counter = 1
  var iterations = 0
  var reintroducedKinds = initHashSet[XLangNodeKind]()
  var cycleWarningShown = false
  
  while counter > 0 and not reachedMaxIterations(iterations, pm.maxIterations):
    counter = 0
    iterations.inc()
    reintroducedKinds.clear()
    
    # Progress feedback
    if shouldShowProgress(iterations, verbose):
      showProgress(iterations)
    
    # Compute applicable transforms
    let applicableKinds = computeApplicableKinds(pm, root)
    if hasNoApplicableKinds(applicableKinds):
      break
    
    # Apply transforms
    traverseTree(root, proc(node: var XLangNode) =
      applyTransform(pm, node, counter, applicableKinds, reintroducedKinds))

    # Flush any pending fields that transforms queued
    if pm.transformContext != nil:
      pm.transformContext.flushPendingFields()

    # Print XLang AST after each iteration if verbose and changes were made
    if verbose and counter > 0:
      echo "\n=== After transform iteration ", iterations, " (", counter, " changes) ==="
      
      if xlangOutput:
        echo printXlang(root)
      echo "=== End iteration ", iterations, " ===\n"

    # Cycle detection
    if shouldWarnAboutCycle(iterations, reintroducedKinds, cycleWarningShown):
      markLoopWarning(pm.result, reintroducedKinds)
      showCycleWarning(iterations, reintroducedKinds, verbose)
      cycleWarningShown = true
    
    # Max iterations check
    if reachedMaxIterations(iterations, pm.maxIterations):
      markMaxReached(pm.result)
      reportMaxIterationsError(pm, reintroducedKinds)
      break
    
    if counter == 0:
      break
  
  clearProgress(verbose, iterations)
  pm.result.iterations = iterations
  result = root
