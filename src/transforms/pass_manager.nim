## Transformation Pass Manager
##
## Orchestrates multiple transformation passes on XLang AST
## to lower constructs and make code more idiomatic for the target language.

import ../../xlangtypes
import ../lang_capabilities
import options
import tables
import strutils

type
  TransformPassKind* = enum
    ## Different kinds of transformation passes
    tpkLowering      ## Lower high-level constructs to simpler ones
    tpkOptimization  ## Optimize code patterns
    tpkNormalization ## Normalize to idiomatic patterns
    tpkValidation    ## Validate AST structure

  TransformPass* = ref object
    ## A single transformation pass
    name*: string
    kind*: TransformPassKind
    description*: string
    enabled*: bool
    transform*: proc(node: XLangNode): XLangNode

  PassManager* = ref object
    ## Manages and executes transformation passes
    passes*: seq[TransformPass]
    maxIterations*: int  ## Maximum number of times to run all passes
    config*: Table[string, bool]  ## Configuration for conditional passes
    targetLang*: LangCapabilities  ## Target language capabilities

proc newTransformPass*(
  name: string,
  kind: TransformPassKind,
  description: string,
  transform: proc(node: XLangNode): XLangNode
): TransformPass =
  ## Create a new transformation pass
  TransformPass(
    name: name,
    kind: kind,
    description: description,
    enabled: true,
    transform: transform
  )

proc newPassManager*(targetLang: string = "nim", maxIterations: int = 10): PassManager =
  ## Create a new pass manager for a target language
  PassManager(
    passes: @[],
    maxIterations: maxIterations,
    config: initTable[string, bool](),
    targetLang: getCapabilities(targetLang)
  )

proc addPass*(pm: PassManager, pass: TransformPass) =
  ## Add a transformation pass to the manager
  pm.passes.add(pass)

proc enablePass*(pm: PassManager, passName: string) =
  ## Enable a specific pass by name
  for pass in pm.passes:
    if pass.name == passName:
      pass.enabled = true
      return

proc disablePass*(pm: PassManager, passName: string) =
  ## Disable a specific pass by name
  for pass in pm.passes:
    if pass.name == passName:
      pass.enabled = false
      return

proc applyPass(pass: TransformPass, node: XLangNode): XLangNode =
  ## Apply a single pass recursively to an AST node
  if not pass.enabled:
    return node

  # Apply transformation to current node
  result = pass.transform(node)

  # Recursively apply to children based on node kind
  case result.kind
  of xnkFile, xnkModule, xnkNamespace:
    if result.children.len > 0:
      var newChildren: seq[XLangNode] = @[]
      for child in result.children:
        newChildren.add(applyPass(pass, child))
      result.children = newChildren

  of xnkBlockStmt:
    if result.blockBody.len > 0:
      var newBody: seq[XLangNode] = @[]
      for stmt in result.blockBody:
        newBody.add(applyPass(pass, stmt))
      result.blockBody = newBody

  of xnkIfStmt:
    result.ifCondition = applyPass(pass, result.ifCondition)
    result.ifBody = applyPass(pass, result.ifBody)
    if result.elseBody.isSome:
      result.elseBody = some(applyPass(pass, result.elseBody.get))

  of xnkWhileStmt:
    result.whileCondition = applyPass(pass, result.whileCondition)
    result.whileBody = applyPass(pass, result.whileBody)

  of xnkForeachStmt:
    result.foreachVar = applyPass(pass, result.foreachVar)
    result.foreachIter = applyPass(pass, result.foreachIter)
    result.foreachBody = applyPass(pass, result.foreachBody)

  of xnkForStmt:
    if result.forInit.isSome:
      result.forInit = some(applyPass(pass, result.forInit.get))
    if result.forCondition.isSome:
      result.forCondition = some(applyPass(pass, result.forCondition.get))
    if result.forUpdate.isSome:
      result.forUpdate = some(applyPass(pass, result.forUpdate.get))
    result.forBody = applyPass(pass, result.forBody)

  of xnkSwitchStmt:
    result.switchExpr = applyPass(pass, result.switchExpr)
    if result.switchCases.len > 0:
      var newCases: seq[XLangNode] = @[]
      for case_node in result.switchCases:
        newCases.add(applyPass(pass, case_node))
      result.switchCases = newCases

  of xnkTryStmt:
    result.tryBody = applyPass(pass, result.tryBody)
    if result.catchClauses.len > 0:
      var newCatches: seq[XLangNode] = @[]
      for catch_node in result.catchClauses:
        newCatches.add(applyPass(pass, catch_node))
      result.catchClauses = newCatches
    if result.finallyBody.isSome:
      result.finallyBody = some(applyPass(pass, result.finallyBody.get))

  of xnkFuncDecl, xnkMethodDecl:
    result.body = applyPass(pass, result.body)
    if result.params.len > 0:
      var newParams: seq[XLangNode] = @[]
      for param in result.params:
        newParams.add(applyPass(pass, param))
      result.params = newParams

  of xnkBinaryExpr:
    result.binaryLeft = applyPass(pass, result.binaryLeft)
    result.binaryRight = applyPass(pass, result.binaryRight)

  of xnkUnaryExpr:
    result.unaryOperand = applyPass(pass, result.unaryOperand)

  of xnkCallExpr:
    result.callFunc = applyPass(pass, result.callFunc)
    if result.callArgs.len > 0:
      var newArgs: seq[XLangNode] = @[]
      for arg in result.callArgs:
        newArgs.add(applyPass(pass, arg))
      result.callArgs = newArgs

  of xnkReturnStmt:
    if result.returnValue.isSome:
      result.returnValue = some(applyPass(pass, result.returnValue.get))

  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    if result.varValue.isSome:
      result.varValue = some(applyPass(pass, result.varValue.get))

  else:
    # For other node types, return as-is
    discard

proc runPasses*(pm: PassManager, ast: XLangNode): XLangNode =
  ## Run all enabled passes on the AST
  ## Iterates until no more changes or max iterations reached
  result = ast
  var iteration = 0
  var changed = true

  while changed and iteration < pm.maxIterations:
    changed = false
    iteration += 1

    # Run each enabled pass
    for pass in pm.passes:
      if pass.enabled:
        let before = $result  # Simple change detection
        result = applyPass(pass, result)
        let after = $result
        if before != after:
          changed = true

    if not changed:
      break

proc listPasses*(pm: PassManager): seq[string] =
  ## List all registered passes with their status
  result = @[]
  for pass in pm.passes:
    let status = if pass.enabled: "✓" else: "✗"
    result.add("[" & status & "] " & pass.name & " (" & $pass.kind & "): " & pass.description)

proc getStats*(pm: PassManager): tuple[total: int, enabled: int, disabled: int] =
  ## Get statistics about registered passes
  result.total = pm.passes.len
  result.enabled = 0
  result.disabled = 0
  for pass in pm.passes:
    if pass.enabled:
      result.enabled += 1
    else:
      result.disabled += 1
