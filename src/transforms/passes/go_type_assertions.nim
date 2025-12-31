## Go Type Assertions and Type Switches
##
## Transforms Go's type assertions and type switches to Nim's type checking
##
## Go type assertion:
##   value, ok := x.(ConcreteType)
##   value := x.(ConcreteType)  // panics if wrong type
##
## Go type switch:
##   switch v := x.(type) {
##   case int:
##     // v is int
##   case string:
##     // v is string
##   }
##
## Nim:
##   if x of ConcreteType:
##     let value = ConcreteType(x)
##
##   case x
##   of int: ...
##   of string: ...

import ../../../xlangtypes
import ../../semantic/semantic_analysis
import options
import strutils

proc isTypeAssertion(node: XLangNode): bool =
  ## Check if this is a Go type assertion: x.(Type)
  if node.kind != xnkTypeAssertion:
    return false
  return true

proc transformTypeAssertion*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform Go type assertion to Nim type check and cast
  ##
  ## Go: value, ok := x.(ConcreteType)
  ## Nim:
  ##   if x of ConcreteType:
  ##     let value = ConcreteType(x)
  ##     let ok = true
  ##   else:
  ##     let ok = false

  if not isTypeAssertion(node):
    return node

  let expr = node.assertExpr
  let targetType = node.assertType

  # Check if this is the "ok" form: value, ok := x.(Type)
  # or panic form: value := x.(Type)

  # For now, generate the safe "of" check
  # This would typically be part of a larger assignment transformation

  # Generate: if expr of targetType: targetType(expr) else: nil
  result = XLangNode(
    kind: xnkIfStmt,
    ifCondition: XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: opIs,
      binaryLeft: expr,
      binaryRight: targetType
    ),
    ifBody: XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[
        # Cast expression
        XLangNode(
          kind: xnkCallExpr,
          callee: targetType,
          args: @[expr]
        )
      ]
    ),
    elseBody: some(XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[
        XLangNode(kind: xnkNoneLit)
      ]
    ))
  )

proc transformTypeSwitch*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform Go type switch to Nim case with type checking
  ##
  ## Go:
  ##   switch v := x.(type) {
  ##   case int:
  ##     // use v as int
  ##   case string:
  ##     // use v as string
  ##   default:
  ##     // v has original type
  ##   }
  ##
  ## Nim:
  ##   case x.kind  # For variant objects
  ##   of intKind: let v = x.intVal
  ##   of stringKind: let v = x.strVal
  ##   else: discard

  if node.kind != xnkTypeSwitchStmt:
    return node

  let switchExpr = node.typeSwitchExpr
  let switchVar = node.typeSwitchVar  # Optional variable binding
  let cases = node.typeSwitchCases

  # For variant objects in Nim, we check the kind field
  # For interface types, we'd use a series of if-of checks

  # Build if-elif chain for type checks
  var currentElse: Option[XLangNode] = none(XLangNode)

  # Process cases in reverse to build chain
  for i in countdown(cases.len - 1, 0):
    let caseNode = cases[i]

    if caseNode.kind == xnkTypeCaseClause:
      let caseType = caseNode.caseType
      let caseBody = caseNode.caseBody

      # Add variable binding if specified
      var bodyWithBinding: XLangNode

      if switchVar.isSome:
        let varName = if switchVar.get.kind == xnkIdentifier:
                        switchVar.get.identName
                      else:
                        "v"

        # Bind variable to casted value
        let varDecl = XLangNode(
          kind: xnkLetDecl,
          declName: varName,
          declType: some(caseType),
          initializer: some(XLangNode(
            kind: xnkCallExpr,
            callee: caseType,
            args: @[switchExpr]
          ))
        )

        var bodyStmts = @[varDecl]
        if caseBody.kind == xnkBlockStmt:
          bodyStmts.add(caseBody.blockBody)
        else:
          bodyStmts.add(caseBody)

        bodyWithBinding = XLangNode(
          kind: xnkBlockStmt,
          blockBody: bodyStmts
        )
      else:
        bodyWithBinding = caseBody

      # Build if statement
      let ifStmt = XLangNode(
        kind: xnkIfStmt,
        ifCondition: XLangNode(
          kind: xnkBinaryExpr,
          binaryOp: opIs,
          binaryLeft: switchExpr,
          binaryRight: caseType
        ),
        ifBody: bodyWithBinding,
        elseBody: currentElse
      )

      currentElse = some(ifStmt)

    elif caseNode.kind == xnkDefaultClause:
      # Default case
      currentElse = some(caseNode.defaultBody)

  result = currentElse.get(node)

# Interface type assertions in Go
# Go's empty interface (interface{}) can hold any value
# Type assertions are the only way to get the value back

proc transformEmptyInterface*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform Go empty interface type
  ##
  ## Go: interface{} or any (Go 1.18+)
  ## Nim: RootObj or ref RootObj or generics

  if node.kind != xnkNamedType:
    return node

  if node.typeName in ["interface{}", "any"]:
    # Map to Nim's RootObj (base of all ref objects)
    # or use generics depending on context
    result = XLangNode(
      kind: xnkNamedType,
      typeName: "RootRef"  # or "any" in newer Nim
    )
  else:
    result = node

# Comma-ok idiom transformation
# Go: value, ok := x.(Type)

proc transformCommaOkTypeAssertion*(assignNode: XLangNode): XLangNode =
  ## Transform Go's comma-ok type assertion in assignment
  ##
  ## Go: value, ok := x.(Type)
  ## Nim:
  ##   let ok = x of Type
  ##   let value = if ok: Type(x) else: default(Type)

  # This would be called from assignment transformation
  # when it detects type assertion on RHS

  result = assignNode  # Placeholder

# Main transformation
proc transformGoTypeAssertions*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Main type assertion transformation

  case node.kind
  of xnkTypeAssertion:
    return transformTypeAssertion(node, semanticInfo)

  of xnkTypeSwitchStmt:
    return transformTypeSwitch(node, semanticInfo)

  of xnkNamedType:
    return transformEmptyInterface(node, semanticInfo)

  else:
    return node
