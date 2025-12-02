## Go Panic/Recover to Nim Exception Handling
##
## Transforms Go's panic/recover mechanism to Nim's try/except
##
## Go:
##   defer func() {
##     if r := recover(); r != nil {
##       log.Println("Recovered:", r)
##     }
##   }()
##   panic("something went wrong")
##
## Nim:
##   try:
##     raise newException(Exception, "something went wrong")
##   except Exception as e:
##     echo "Recovered: ", e.msg

import ../../xlangtypes
import options
import strutils

proc isPanicCall(node: XLangNode): bool =
  ## Check if this is a panic() call
  if node.kind != xnkCallExpr:
    return false

  if node.callee.kind == xnkIdentifier and node.callee.identName == "panic":
    return true

  return false

proc isRecoverCall(node: XLangNode): bool =
  ## Check if this is a recover() call
  if node.kind != xnkCallExpr:
    return false

  if node.callee.kind == xnkIdentifier and node.callee.identName == "recover":
    return true

  return false

proc transformPanic*(node: XLangNode): XLangNode =
  ## Transform Go panic to Nim raise
  ##
  ## Go: panic(message) or panic(error)
  ## Nim: raise newException(Exception, message)

  if not isPanicCall(node):
    return node

  # panic(value) → raise newException(Exception, $value)
  let panicArg = if node.args.len > 0:
                   node.args[0]
                 else:
                   XLangNode(kind: xnkStringLit, literalValue: "panic")

  # Create exception object
  # In Go, panic can take any value; in Nim we need an exception type
  let exceptionObj = XLangNode(
    kind: xnkCallExpr,
    callee: XLangNode(kind: xnkIdentifier, identName: "newException"),
    args: @[
      XLangNode(kind: xnkIdentifier, identName: "Exception"),
      # Convert panic value to string
      XLangNode(
        kind: xnkCallExpr,
        callee: XLangNode(kind: xnkIdentifier, identName: "$"),
        args: @[panicArg]
      )
    ]
  )

  result = XLangNode(
    kind: xnkThrowStmt,
    throwExpr: exceptionObj
  )

proc transformRecover*(deferBlock: XLangNode): XLangNode =
  ## Transform Go defer with recover to Nim try/except
  ##
  ## Go pattern:
  ##   defer func() {
  ##     if r := recover(); r != nil {
  ##       // handle panic
  ##     }
  ##   }()
  ##
  ## This is typically found in deferred anonymous functions
  ## Transform to wrap the function body in try/except

  # This is complex - recover only works inside defer
  # We need to identify the pattern and wrap the entire function in try/except

  result = deferBlock  # Placeholder

proc findRecoverPattern(node: XLangNode): Option[XLangNode] =
  ## Find the recover pattern in deferred function
  ##
  ## Look for: if r := recover(); r != nil { ... }

  case node.kind
  of xnkIfStmt:
    # Check if condition involves recover()
    # This is a simplified check
    return some(node)

  of xnkBlockStmt:
    for stmt in node.blockBody:
      let found = findRecoverPattern(stmt)
      if found.isSome:
        return found

  else:
    discard

  return none(XLangNode)

proc wrapWithTryExcept*(funcNode: XLangNode): XLangNode =
  ## Wrap function body with try/except when recover pattern detected
  ##
  ## If function has deferred recover, wrap body in try block
  ## and move recover handler to except block

  if funcNode.kind notin {xnkFuncDecl, xnkMethodDecl}:
    return funcNode

  # Look for defer with recover in function body
  var hasRecover = false
  var recoverHandler: Option[XLangNode] = none(XLangNode)

  # Scan for defer statements with recover
  proc scanForRecover(n: XLangNode): bool =
    if n.kind == xnkDeferStmt:
      let found = findRecoverPattern(n.staticBody)
      if found.isSome:
        recoverHandler = found
        return true
    elif n.kind == xnkBlockStmt:
      for stmt in n.blockBody:
        if scanForRecover(stmt):
          return true
    return false

  hasRecover = scanForRecover(funcNode.body)

  if not hasRecover:
    return funcNode

  # Wrap function body in try/except
  # Remove defer with recover, put handler in except

  let tryBody = funcNode.body  # Simplified - should remove defer

  let exceptClause = if recoverHandler.isSome:
    # Transform recover handler to except block
    recoverHandler.get
  else:
    # Default handler
    XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[
        XLangNode(
          kind: xnkCallExpr,
          callee: XLangNode(kind: xnkIdentifier, identName: "echo"),
          args: @[XLangNode(kind: xnkStringLit, literalValue: "Recovered from panic")]
        )
      ]
    )

  let wrappedBody = XLangNode(
    kind: xnkTryStmt,
    tryBody: tryBody,
    catchClauses: @[
      XLangNode(
        kind: xnkCatchStmt,
        catchVar: some("e"),
        catchType: some(XLangNode(kind: xnkNamedType, typeName: "Exception")),
        catchBody: exceptClause
      )
    ],
    finallyClause: none(XLangNode)
  )

  case funcNode.kind:
  of xnkFuncDecl:
    result = XLangNode(
      kind: xnkFuncDecl,
      funcName: funcNode.funcName,
      params: funcNode.params,
      returnType: funcNode.returnType,
      body: wrappedBody,
      isAsync: funcNode.isAsync
    )
  of xnkMethodDecl:
    result = XLangNode(
      kind: xnkMethodDecl,
      receiver: funcNode.receiver,
      methodName: funcNode.methodName,
      mparams: funcNode.mparams,
      mreturnType: funcNode.mreturnType,
      mbody: wrappedBody,
      methodIsAsync: funcNode.methodIsAsync
    )
  else:
    result = funcNode

# Alternative approach: use Nim's defects
# Go panic for programming errors can map to Nim defects
# which can be caught with {.raises: [Defect].}

proc transformPanicToDefect*(node: XLangNode): XLangNode =
  ## Transform panic to Nim defect for programming errors
  ##
  ## Go: panic("index out of bounds")
  ## Nim: raise newException(IndexDefect, "index out of bounds")

  if not isPanicCall(node):
    return node

  let panicArg = if node.args.len > 0:
                   node.args[0]
                 else:
                   XLangNode(kind: xnkStringLit, literalValue: "panic")

  # Use Defect for panic (vs Exception for errors)
  let defectObj = XLangNode(
    kind: xnkCallExpr,
    callee: XLangNode(kind: xnkIdentifier, identName: "newException"),
    args: @[
      XLangNode(kind: xnkIdentifier, identName: "Defect"),
      XLangNode(
        kind: xnkCallExpr,
        callee: XLangNode(kind: xnkIdentifier, identName: "$"),
        args: @[panicArg]
      )
    ]
  )

  result = XLangNode(
    kind: xnkThrowStmt,
    throwExpr: defectObj
  )

# Main transformation function
proc transformGoPanicRecover*(node: XLangNode): XLangNode =
  ## Main transformation for panic/recover

  case node.kind
  of xnkCallExpr:
    # Transform panic calls
    if isPanicCall(node):
      return transformPanic(node)

  of xnkFuncDecl, xnkMethodDecl:
    # Check if function uses recover, wrap with try/except
    return wrapWithTryExcept(node)

  else:
    discard

  return node
