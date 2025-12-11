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
import options

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
                     counter: var int) =
  let kind = node.kind
  let transform = pm.kindToTransform.getOrDefault(kind, nil)
  # we assume transform itself knows how to handle the node type and its children.
  if transform != nil:
    echo "Applying transform ", transform.id, " to ", node.kind
    node = transform.transform(node) #, pm.errorCollector)
    counter.inc()
  

# use helpers to traverse the tree and apply transforms
proc run*(pm: PassManager2, root: var XLangNode): XLangNode =
  ## Run the pass manager on the given AST
  var counter = 0
  var iterations = 0
  while counter > 0 and iterations < pm.maxIterations:
    counter = 0
    iterations.inc()
    traverseTree(root, proc(node: var XLangNode) =
      applyTransform(pm, node, counter))
  
    if iterations >= pm.maxIterations:
      pm.errorCollector.addError(tekTransformLimitReachedError, "PassManager2: Max iterations reached")
      break
    if counter == 0:
      echo "PassManager2: Fixed point reached after ", iterations, " iterations"
      break
  return root




# proc getNextMatchingNode*(node: XLangNode, kind: XLangNodeKind): Option[XLangNode] =
#   ## Find the next node of the given kind in the AST
#   if node.kind == kind:
#     return some node
#   let kids = node.getChildren()
#   if kids.isSome():
#     for child in kids.get:
#       let res = getNextMatchingNode(child, kind)
#       if res.isSome:
#         return res
#   return none(XLangNode)


# REDO from this point, using helpers and apply_to_kids

  
proc traverseAndTransform*(pm: PassManager2, node: var XLangNode,
                            counter: var int): XLangNode =
  ## Traverse the AST and apply transforms
  if pm.activeKinds.contains(node.kind):
    result = applyTransform(pm, node, counter)  

proc applyTransormtoChildren*(pm: PassManager2, node: XLangNode,
                              counter: var int): XLangNode =
  case node.kind:
    of xnkFile:
      var newChildren: seq[XLangNode] = @[]
      for child in result.moduleDecls:
        newChildren.add(pm.traverseAndTransform(child, counter))
      result.moduleDecls = newChildren

    of xnkModule:
      var newChildren: seq[XLangNode] = @[]
      for child in result.moduleBody:
        newChildren.add(pm.traverseAndTransform(child, counter))
      result.moduleBody = newChildren

    of xnkNamespace:
      var newChildren: seq[XLangNode] = @[]
      for child in result.namespaceBody:
        newChildren.add(pm.traverseAndTransform(child, counter))
      result.namespaceBody = newChildren

    of xnkBlockStmt:
      var newBody: seq[XLangNode] = @[]
      for stmt in result.blockBody:
        newBody.add(pm.traverseAndTransform(stmt, counter))
      result.blockBody = newBody

    of xnkIfStmt:
      result.ifCondition = pm.traverseAndTransform(result.ifCondition, counter)
      result.ifBody = pm.traverseAndTransform(result.ifBody, counter)
      if result.elseBody.isSome:
        result.elseBody = some(pm.traverseAndTransform(result.elseBody.get, counter))

    of xnkWhileStmt:
      result.whileCondition = pm.traverseAndTransform(result.whileCondition, counter)
      result.whileBody = pm.traverseAndTransform(result.whileBody, counter)

    of xnkDoWhileStmt:
      result.doWhileBody = pm.traverseAndTransform(result.doWhileBody, counter)
      result.doWhileCondition = pm.traverseAndTransform(result.doWhileCondition, counter)

    of xnkForeachStmt:
      result.foreachVar = pm.traverseAndTransform(result.foreachVar, counter)
      result.foreachIter = pm.traverseAndTransform(result.foreachIter, counter)
      result.foreachBody = pm.traverseAndTransform(result.foreachBody, counter)

    of xnkForStmt:
      if result.forInit.isSome:
        result.forInit = some(pm.traverseAndTransform(result.forInit.get, counter))
      if result.forCond.isSome:
        result.forCond = some(pm.traverseAndTransform(result.forCond.get, counter))
      if result.forIncrement.isSome:
        result.forIncrement = some(pm.traverseAndTransform(result.forIncrement.get, counter))
      if result.forBody.isSome:
        result.forBody = some(pm.traverseAndTransform(result.forBody.get, counter))

    of xnkSwitchStmt:
      result.switchExpr = pm.traverseAndTransform(result.switchExpr, counter)
      var newCases: seq[XLangNode] = @[]
      for case_node in result.switchCases:
        newCases.add(pm.traverseAndTransform(case_node, counter))
      result.switchCases = newCases

    of xnkCaseClause:
      var newPatterns: seq[XLangNode] = @[]
      for pattern in result.casePatterns:
        newPatterns.add(pm.traverseAndTransform(pattern, counter))
      result.casePatterns = newPatterns
      result.caseBody = pm.traverseAndTransform(result.caseBody, counter)

    of xnkTryStmt:
      result.tryBody = pm.traverseAndTransform(result.tryBody, counter)
      var newCatches: seq[XLangNode] = @[]
      for catch_node in result.catchClauses:
        newCatches.add(pm.traverseAndTransform(catch_node, counter))
      result.catchClauses = newCatches
      if result.finallyClause.isSome:
        result.finallyClause = some(pm.traverseAndTransform(result.finallyClause.get, counter))

    of xnkCatchClause:
      result.catchBody = pm.traverseAndTransform(result.catchBody, counter)

    of xnkFuncDecl, xnkMethodDecl:
      var newParams: seq[XLangNode] = @[]
      for param in result.params:
        newParams.add(pm.traverseAndTransform(param, counter))
      result.params = newParams
      result.body = pm.traverseAndTransform(result.body, counter)

    of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
      var newMembers: seq[XLangNode] = @[]
      for member in result.members:
        newMembers.add(pm.traverseAndTransform(member, counter))
      result.members = newMembers

    of xnkPropertyDecl:
      if result.propGetter.isSome:
        result.propGetter = some(pm.traverseAndTransform(result.propGetter.get, counter))
      if result.propSetter.isSome:
        result.propSetter = some(pm.traverseAndTransform(result.propSetter.get, counter))

    of xnkBinaryExpr:
      result.binaryLeft = pm.traverseAndTransform(result.binaryLeft, counter)
      result.binaryRight = pm.traverseAndTransform(result.binaryRight, counter)

    of xnkUnaryExpr:
      result.unaryOperand = pm.traverseAndTransform(result.unaryOperand, counter)

    of xnkCallExpr:
      result.callee = pm.traverseAndTransform(result.callee, counter)
      var newArgs: seq[XLangNode] = @[]
      for arg in result.args:
        newArgs.add(pm.traverseAndTransform(arg, counter))
      result.args = newArgs

    of xnkReturnStmt:
      if result.returnExpr.isSome:
        result.returnExpr = some(pm.traverseAndTransform(result.returnExpr.get, counter))

    of xnkRaiseStmt:
      if result.raiseExpr.isSome:
        result.raiseExpr = some(pm.traverseAndTransform(result.raiseExpr.get, counter))

    of xnkVarDecl, xnkLetDecl, xnkConstDecl:
      if result.initializer.isSome:
        result.initializer = some(pm.traverseAndTransform(result.initializer.get, counter))

    of xnkAsgn:
      result.asgnLeft = pm.traverseAndTransform(result.asgnLeft, counter)
      result.asgnRight = pm.traverseAndTransform(result.asgnRight, counter)

    of xnkTernaryExpr:
      result.ternaryCondition = pm.traverseAndTransform(result.ternaryCondition, counter)
      result.ternaryThen = pm.traverseAndTransform(result.ternaryThen, counter)
      result.ternaryElse = pm.traverseAndTransform(result.ternaryElse, counter)

    of xnkArrayLit:
      var newElements: seq[XLangNode] = @[]
      for elem in result.arrayElements:
        newElements.add(pm.traverseAndTransform(elem, counter))
      result.arrayElements = newElements

    of xnkTupleLit:
      var newElements: seq[XLangNode] = @[]
      for elem in result.tupleElements:
        newElements.add(pm.traverseAndTransform(elem, counter))
      result.tupleElements = newElements

    of xnkIndexExpr:
      result.indexBase = pm.traverseAndTransform(result.indexBase, counter)
      result.indexArg = pm.traverseAndTransform(result.indexArg, counter)

    of xnkDotExpr:
      result.dotLeft = pm.traverseAndTransform(result.dotLeft, counter)

    of xnkCastExpr:
      result.castExpr = pm.traverseAndTransform(result.castExpr, counter)

    of xnkLambdaExpr:
      result.lambdaBody = pm.traverseAndTransform(result.lambdaBody, counter)

    of xnkWithStmt, xnkUsingStmt:
      result.withExpr = pm.traverseAndTransform(result.withExpr, counter)
      result.withBody = pm.traverseAndTransform(result.withBody, counter)

    of xnkAwaitExpr:
      result.awaitExpr = pm.traverseAndTransform(result.awaitExpr, counter)

    of xnkYieldExpr, xnkYieldStmt:
      if result.yieldExpr.isSome:
        result.yieldExpr = some(pm.traverseAndTransform(result.yieldExpr.get, counter))

    else:
      # For other node types (literals, identifiers, etc.), no children to traverse
      discard



proc applyTransformToTree*(pm: PassManager2, root: XLangNode): XLangNode =
  ## Apply all transforms to the entire tree until fixed point is reached
  result = root
  var counter = 0
  var iteration = 0
  while iteration < pm.maxIterations:
    counter = 0
    result = pm.applyTransform(result, counter)

    # If no transforms were applied, we've reached fixed point
    if counter == 0:
      break

    iteration.inc()


proc applyTransformsToNode(pm: PassManager2, node: XLangNode,
                           counter: var int): XLangNode =
  ## Apply all matching transforms to a single node
  result = node

  # First apply universal transforms (those with empty targetKinds)
  if pm.kindToTransforms.hasKey(xnkNone):
    for transform in pm.kindToTransforms[xnkNone]:
      let before = result
      result = transform.transform(result)
      if before != result:
        counter.inc()

  # Then apply kind-specific transforms
  if node.kind in pm.activeKinds and pm.kindToTransforms.hasKey(node.kind):
    for transform in pm.kindToTransforms[node.kind]:
      let before = result
      result = transform.transform(result)
      if before != result:
        counter.inc()

proc traverseAndTransform(pm: PassManager2, node: XLangNode,
                         counter: var int): XLangNode =
  ## Recursively traverse the AST and apply transforms
  ## Returns transformed node

  # First, apply transforms to this node
  result = pm.applyTransformsToNode(node, counter)
  let kids = getChildren(node)
  if kids.len == 0:
    return result
  else:
    for kid in kids:
      pm.traverseAndTransform(kid, counter) 
      
      # pm.applyTransformsToNode(kid, counter)


  # # Then recursively process children based on node kind
  #

proc runPasses*(pm: PassManager2, ast: XLangNode): XLangNode =
  ## Run all transforms until fixed point (no more changes)
  result = ast
  var iteration = 0

  while iteration < pm.maxIterations:
    var counter = 0

    try:
      result = pm.traverseAndTransform(result, counter)
    except Exception as e:
      pm.errorCollector.addError(
        tekTransformError,
        "Pass iteration " & $iteration & " failed: " & e.msg,
        location = "PassManager2.runPasses",
        details = e.getStackTrace()
      )
      pm.errorCollector.reportAndExit()

    # If no transforms were applied, we've reached fixed point
    if counter == 0:
      break

    iteration.inc()

  # Check if we hit max iterations without converging
  if iteration >= pm.maxIterations:
    pm.errorCollector.addError(
      tekTransformError,
      "Pass manager did not converge after " & $pm.maxIterations & " iterations",
      location = "PassManager2.runPasses"
    )
    pm.errorCollector.reportAndExit()

  # Report any accumulated errors
  if pm.errorCollector.hasErrors():
    pm.errorCollector.reportAndExit()
