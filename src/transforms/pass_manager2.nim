## Simple Pass Manager - Fixed-Point Iteration
##
## Much simpler approach than pass_manager.nim:
## 1. Collect all transforms and their targetKinds into a HashSet and Table
## 2. Traverse full AST tree
## 3. When node.kind matches a transform's targetKinds, apply the transform
## 4. Count each application
## 5. Repeat entire tree traversal until counter = 0 (fixed point reached)

import ../../xlangtypes
import types
import ../xlang/error_handling
import tables
import sets

import helpers


type
  PassManagerResult* = object
    ## Result of running the pass manager
    success*: bool
    iterations*: int
    loopWarning*: bool
    loopKinds*: seq[XLangNodeKind]
    maxIterationsReached*: bool

  PassManager2* = ref object
    ## Simplified pass manager using fixed-point iteration
    kindToTransform*: Table[XLangNodeKind, TransformPass]
    activeKinds*: HashSet[XLangNodeKind]
    maxIterations*: int
    errorCollector*: ErrorCollector
    result*: PassManagerResult

proc newPassManager2*(maxIterations: int = 10000,
                      errorCollector: ErrorCollector = nil): PassManager2 =
  ## Create a new simplified pass manager
  PassManager2(
    kindToTransform: initTable[XLangNodeKind, TransformPass](), # 1:1 mapping
    activeKinds: initHashSet[XLangNodeKind](),
    maxIterations: maxIterations,
    errorCollector: if errorCollector != nil: errorCollector else: newErrorCollector(),
    result: PassManagerResult(success: true, iterations: 0, loopWarning: false, loopKinds: @[], maxIterationsReached: false)
  )

# [v]
proc addTransforms*(pm: PassManager2, transforms: seq[TransformPass]) =
  ## Add transforms to the manager, building the kind->transform mapping
  for transform in transforms:       
    # Map each target kind to this transform
    for kind in transform.operatesOnKinds:
      pm.activeKinds.incl(kind)
      pm.kindToTransform[kind] = transform


proc applyTransform*(pm: PassManager2, node: var XLangNode,
                     counter: var int, applicableKinds: HashSet[XLangNodeKind]) =
  let kind = node.kind
  # Skip if this kind is not applicable in this iteration
  if kind notin applicableKinds:
    return

  let transform = pm.kindToTransform.getOrDefault(kind, nil)
  if transform != nil:
    node = transform.transform(node)
    counter.inc()

proc run*(pm: PassManager2, root: var XLangNode): XLangNode =
  ## Run the pass manager on the given AST until fixed point is reached
  var counter = 1  # Initialize to 1 to enter the loop
  var iterations = 0
  const loopWarningThreshold = 20

  # Reset result
  pm.result = PassManagerResult(success: true, iterations: 0, loopWarning: false, loopKinds: @[], maxIterationsReached: false)

  while counter > 0 and iterations < pm.maxIterations:
    counter = 0
    iterations.inc()

    # Collect all kinds present in the tree for this iteration
    var treeKinds = collectAllKinds(root)

    # Calculate applicable transforms for this iteration (intersection)
    let applicableKinds = pm.activeKinds * treeKinds

    # Calculate how many transform kinds are not needed this iteration
    let unusedKinds = pm.activeKinds - treeKinds

    if applicableKinds.len == 0:
      break

    # Detect potential infinite loop after threshold iterations
    if iterations == loopWarningThreshold and applicableKinds.len > 0:
      pm.result.loopWarning = true
      for kind in applicableKinds:
        pm.result.loopKinds.add(kind)

    # Traverse entire tree and apply only applicable transforms
    traverseTree(root, proc(node: var XLangNode) =
      applyTransform(pm, node, counter, applicableKinds))

    if iterations >= pm.maxIterations:
      pm.result.maxIterationsReached = true
      pm.result.success = false
      pm.errorCollector.addError(tekTransformLimitReachedError,
        "PassManager2: Max iterations reached")
      break

    if counter == 0:
      break

  pm.result.iterations = iterations
  result = root

