## Go Error Handling Pattern Normalization
##
## Transforms Go's explicit error handling to Nim's exception-based approach
##
## Go pattern:
##   result, err := someFunc()
##   if err != nil {
##     return err
##   }
##   // use result
##
## Nim approach (option 1 - exceptions):
##   let result = someFunc()  # Raises exception on error
##   # use result
##
## Nim approach (option 2 - Option/Result type):
##   let resultOpt = someFunc()
##   if resultOpt.isNone:
##     return
##   let result = resultOpt.get
##   # use result

import ../../../xlangtypes
import options
import strutils

proc isErrorCheckPattern(node: XLangNode): bool =
  ## Check if this is Go's error checking pattern: if err != nil
  if node.kind != xnkIfStmt:
    return false

  let cond = node.ifCondition
  if cond.kind != xnkBinaryExpr:
    return false

  # Check for: err != nil or err == nil
  if cond.binaryOp notin ["!=", "=="]:
    return false

  # Check if one side is 'err' and other is nil
  let isErrCheck = (
    (cond.binaryLeft.kind == xnkIdentifier and
     cond.binaryLeft.identName == "err" and
     cond.binaryRight.kind == xnkNoneLit) or
    (cond.binaryRight.kind == xnkIdentifier and
     cond.binaryRight.identName == "err" and
     cond.binaryLeft.kind == xnkNoneLit)
  )

  return isErrCheck

proc isErrorReturn(node: XLangNode): bool =
  ## Check if statement is: return err
  if node.kind != xnkReturnStmt:
    return false

  if node.returnExpr.isNone:
    return false

  let retVal = node.returnExpr.get
  return retVal.kind == xnkIdentifier and retVal.identName == "err"

proc transformGoErrorHandling*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Transform Go error handling patterns to Nim exception handling
  if not isErrorCheckPattern(node):
    return node

  # We have: if err != nil { ... }
  # Common patterns:
  # 1. if err != nil { return err }  → Remove (Nim auto-propagates exceptions)
  # 2. if err != nil { return fmt.Errorf(...) }  → Keep for custom errors
  # 3. if err != nil { log.Fatal(err) }  → Convert to Nim's error handling

  let cond = node.ifCondition
  let isNotNil = cond.binaryOp == "!="

  if node.ifBody.kind != xnkBlockStmt:
    return node

  let bodyStmts = if node.ifBody.kind == xnkBlockStmt:
                    node.ifBody.blockBody
                  else:
                    @[node.ifBody]

  # Pattern 1: if err != nil { return err }
  if isNotNil and bodyStmts.len == 1 and isErrorReturn(bodyStmts[0]):
    # This is the common Go error propagation pattern
    # In Nim with exceptions, this is automatic - the exception propagates
    # So we can potentially remove this check entirely
    # However, to be safe, we'll convert it to a raise statement

    result = XLangNode(
      kind: xnkIfStmt,
      ifCondition: XLangNode(
        kind: xnkBinaryExpr,
        binaryOp: "!=",
        binaryLeft: XLangNode(kind: xnkIdentifier, identName: "err"),
        binaryRight: XLangNode(kind: xnkNoneLit)
      ),
      ifBody: XLangNode(
        kind: xnkBlockStmt,
        blockBody: @[
          XLangNode(
            kind: xnkThrowStmt,
            throwExpr: XLangNode(kind: xnkIdentifier, identName: "err")
          )
        ]
      ),
      elseBody: node.elseBody
    )
    return

  # Pattern 2: if err != nil { log.Fatal(err) } or panic
  # Look for Fatal, panic, log calls
  if isNotNil and bodyStmts.len > 0:
    let firstStmt = bodyStmts[0]
    if firstStmt.kind == xnkCallExpr:
      # Check if it's a fatal/panic call
      var isFatalCall = false
      if firstStmt.callee.kind == xnkMemberAccessExpr:
        if firstStmt.callee.memberName in ["Fatal", "Fatalf", "Panic", "Panicf"]:
          isFatalCall = true
      elif firstStmt.callee.kind == xnkIdentifier:
        if firstStmt.callee.identName in ["panic", "fatal"]:
          isFatalCall = true

      if isFatalCall:
        # Convert to raise or assert false
        result = XLangNode(
          kind: xnkIfStmt,
          ifCondition: XLangNode(
            kind: xnkBinaryExpr,
            binaryOp: "!=",
            binaryLeft: XLangNode(kind: xnkIdentifier, identName: "err"),
            binaryRight: XLangNode(kind: xnkNoneLit)
          ),
          ifBody: XLangNode(
            kind: xnkBlockStmt,
            blockBody: @[
              XLangNode(
                kind: xnkThrowStmt,
                throwExpr: XLangNode(kind: xnkIdentifier, identName: "err")
              )
            ]
          ),
          elseBody: node.elseBody
        )
        return

  # Pattern 3: if err == nil { ... } (success case)
  # This is the opposite - proceeding when there's no error
  # In Nim, we'd wrap the success code in a try block
  if not isNotNil:
    # Keep as-is for now, might need different handling
    result = node
    return

  # Default: keep the error check as-is
  result = node

# Additional helper for transforming function returns with errors
# Go: func foo() (Result, error)
# Nim: proc foo(): Result (raises exception on error)

proc transformErrorReturnType*(node: XLangNode): XLangNode =
  ## Transform Go functions that return (T, error) to Nim functions that return T
  ## The error becomes an exception

  if node.kind notin {xnkFuncDecl, xnkMethodDecl}:
    return node

  # Check if return type is a tuple with last element being 'error'
  if node.returnType.isNone:
    return node

  let retType = node.returnType.get
  if retType.kind != xnkTupleExpr:
    return node

  # Check if last element is 'error' type
  if retType.elements.len < 2:
    return node

  let lastElem = retType.elements[^1]
  var isErrorType = false
  if lastElem.kind == xnkNamedType and lastElem.typeName == "error":
    isErrorType = true

  if not isErrorType:
    return node

  # Transform: func() (T, error) → proc(): T {.raises: [Exception].}
  # Remove 'error' from return type tuple
  var newElements = retType.elements[0..^2]

  let newRetType = if newElements.len == 1:
    # Single return value
    newElements[0]
  else:
    # Multiple return values (still a tuple)
    XLangNode(kind: xnkTupleExpr, elements: newElements)

  case node.kind
  of xnkFuncDecl:
    result = XLangNode(
      kind: xnkFuncDecl,
      funcName: node.funcName,
      params: node.params,
      returnType: some(newRetType),
      body: node.body,
      isAsync: node.isAsync
    )
  of xnkMethodDecl:
    result = XLangNode(
      kind: xnkMethodDecl,
      receiver: node.receiver,
      methodName: node.methodName,
      mparams: node.mparams,
      mreturnType: some(newRetType),
      mbody: node.mbody,
      methodIsAsync: node.methodIsAsync
    )
  else:
    result = node
