## Throw Expression Transform
##
## Converts throw expressions (C# 7.0+) to statements with temporary variables.
## Nim doesn't support raise as an expression, so we need to hoist it.
##
## Examples:
##   C#: x = y ?? throw new Exception("null")
##   →   if y == nil: raise newException(Exception, "null")
##       x = y
##
##   C#: return data ?? throw new InvalidOperationException()
##   →   if data == nil: raise newException(InvalidOperationException, "")
##       return data

import core/xlangtypes
import semantic/semantic_analysis
import options

proc transformThrowExpression*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode {.gcsafe.}

var tempVarCounter = 0

proc genTempVarName(): string =
  ## Generate unique temporary variable name
  result = "temp" & $tempVarCounter
  inc tempVarCounter

proc hoistThrowExpr(node: XLangNode, stmts: var seq[XLangNode]): XLangNode =
  ## Recursively find and hoist throw expressions
  ## Returns the transformed expression
  case node.kind
  of xnkExternal_ThrowExpr:
    # Found a throw expression - create raise statement
    let raiseStmt = XLangNode(
      kind: xnkRaiseStmt,
      raiseExpr: some(node.extThrowExprValue)
    )
    stmts.add(raiseStmt)

    # Return a placeholder (won't be used since raise doesn't return)
    result = XLangNode(kind: xnkNoneLit)

  of xnkBinaryExpr:
    # Check if this is null coalesce with throw on right
    # a ?? throw exc → if a == nil: raise exc; a
    if node.binaryOp == opNullCoalesce:
      let rightTransformed = hoistThrowExpr(node.binaryRight, stmts)
      if rightTransformed.kind == xnkNoneLit and stmts.len > 0 and stmts[^1].kind == xnkRaiseStmt:
        # Right side was a throw expression
        # Create: if left == nil: raise; return left
        let condition = XLangNode(
          kind: xnkBinaryExpr,
          binaryLeft: node.binaryLeft,
          binaryOp: opEqual,
          binaryRight: XLangNode(kind: xnkNoneLit)
        )

        let ifStmt = XLangNode(
          kind: xnkIfStmt,
          ifCondition: condition,
          ifBody: XLangNode(
            kind: xnkBlockStmt,
            blockBody: @[stmts[^1]]  # The raise statement
          ),
          elseBody: none(XLangNode)
        )

        stmts[^1] = ifStmt  # Replace raise with if
        result = node.binaryLeft  # Return left operand
      else:
        result = XLangNode(
          kind: xnkBinaryExpr,
          binaryLeft: node.binaryLeft,
          binaryOp: node.binaryOp,
          binaryRight: rightTransformed
        )
    else:
      let leftTransformed = hoistThrowExpr(node.binaryLeft, stmts)
      let rightTransformed = hoistThrowExpr(node.binaryRight, stmts)
      result = XLangNode(
        kind: xnkBinaryExpr,
        binaryLeft: leftTransformed,
        binaryOp: node.binaryOp,
        binaryRight: rightTransformed
      )

  of xnkExternal_Ternary:
    # condition ? throw : value  or  condition ? value : throw
    let condStmts: seq[XLangNode] = @[]
    let thenStmts: seq[XLangNode] = @[]
    let elseStmts: seq[XLangNode] = @[]

    let thenTransformed = hoistThrowExpr(node.extTernaryThen, stmts)
    let elseTransformed = hoistThrowExpr(node.extTernaryElse, stmts)

    # If either branch throws, convert to if statement
    result = XLangNode(
      kind: xnkExternal_Ternary,
      extTernaryCondition: node.extTernaryCondition,
      extTernaryThen: thenTransformed,
      extTernaryElse: elseTransformed
    )

  else:
    # Default: return node as-is
    result = node

proc transformThrowExpression*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform throw expressions to statements
  case node.kind
  of xnkExternal_ThrowExpr:
    # Standalone throw expression → convert to raise statement
    result = XLangNode(
      kind: xnkRaiseStmt,
      raiseExpr: some(node.extThrowExprValue)
    )

  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    # x = y ?? throw exc
    if node.initializer.isSome():
      var stmts: seq[XLangNode] = @[]
      let transformedInit = hoistThrowExpr(node.initializer.get, stmts)

      if stmts.len > 0:
        # Create block with hoisted statements + declaration
        var updatedDecl = node
        updatedDecl.initializer = some(transformedInit)
        result = XLangNode(
          kind: xnkBlockStmt,
          blockBody: stmts & @[updatedDecl]
        )
      else:
        result = node
    else:
      result = node

  of xnkReturnStmt:
    # return x ?? throw exc
    if node.returnExpr.isSome():
      var stmts: seq[XLangNode] = @[]
      let transformedExpr = hoistThrowExpr(node.returnExpr.get, stmts)

      if stmts.len > 0:
        # Create block with hoisted statements + return
        result = XLangNode(
          kind: xnkBlockStmt,
          blockBody: stmts & @[XLangNode(
            kind: xnkReturnStmt,
            returnExpr: some(transformedExpr)
          )]
        )
      else:
        result = node
    else:
      result = node

  of xnkAsgn:
    # target = value ?? throw exc
    var stmts: seq[XLangNode] = @[]
    let transformedRight = hoistThrowExpr(node.asgnRight, stmts)

    if stmts.len > 0:
      # Create block with hoisted statements + assignment
      result = XLangNode(
        kind: xnkBlockStmt,
        blockBody: stmts & @[XLangNode(
          kind: xnkAsgn,
          asgnLeft: node.asgnLeft,
          asgnRight: transformedRight
        )]
      )
    else:
      result = node

  else:
    result = node
