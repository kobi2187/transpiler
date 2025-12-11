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
  PassManager2* = ref object
    ## Simplified pass manager using fixed-point iteration
    kindToTransform*: Table[XLangNodeKind, TransformPass]
    activeKinds*: HashSet[XLangNodeKind]
    maxIterations*: int
    errorCollector*: ErrorCollector

proc newPassManager2*(maxIterations: int = 1000,
                      errorCollector: ErrorCollector = nil): PassManager2 =
  ## Create a new simplified pass manager
  PassManager2(
    kindToTransform: initTable[XLangNodeKind, TransformPass](), # 1:1 mapping
    activeKinds: initHashSet[XLangNodeKind](),
    maxIterations: maxIterations,
    errorCollector: if errorCollector != nil: errorCollector else: newErrorCollector()
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
    echo "Applying transform ", transform.id, " to ", node.kind
    node = transform.transform(node)
    counter.inc()

proc run*(pm: PassManager2, root: var XLangNode): XLangNode =
  ## Run the pass manager on the given AST until fixed point is reached
  var counter = 1  # Initialize to 1 to enter the loop
  var iterations = 0

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
      echo "PassManager2: No applicable transforms in iteration ", iterations
      break

    echo "PassManager2: Iteration ", iterations, " - applicable: ", applicableKinds.len,
         ", unused: ", unusedKinds.len, " kinds"

    # Traverse entire tree and apply only applicable transforms
    traverseTree(root, proc(node: var XLangNode) =
      applyTransform(pm, node, counter, applicableKinds))

    if iterations >= pm.maxIterations:
      pm.errorCollector.addError(tekTransformLimitReachedError,
        "PassManager2: Max iterations reached")
      break

    if counter == 0:
      echo "PassManager2: Fixed point reached after ", iterations, " iterations"
      break

  result = root
