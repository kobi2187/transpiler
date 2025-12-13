## String Interpolation Transformation
##
## Transforms string interpolation/template strings to concatenation or format calls
##
## Examples:
## - Python f"Hello {name}, you are {age} years old"
## - JavaScript `Hello ${name}, you are ${age} years old`
## - C# $"Hello {name}, you are {age} years old"
##
## Transforms to either:
## - String concatenation: "Hello " & name & ", you are " & $age & " years old"
## - Or strformat: fmt"Hello {name}, you are {age} years old"  (more idiomatic)

import ../../../xlangtypes
import options, sequtils

proc transformStringInterpolation*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.}

proc transformStringInterpolationHelper(node: XLangNode): XLangNode =
  ## Helper that recursively transforms string interpolations in any expression context
  case node.kind
  of xnkStringInterpolation:
    # Strategy: Build concatenation chain with & operator
    # f"Hello {name}!" → "Hello " & name & "!"

    if node.interpParts.len == 0:
      # Empty interpolation, return empty string
      return XLangNode(kind: xnkStringLit, literalValue: "")

    if node.interpParts.len == 1 and not node.interpIsExpr[0]:
      # Single string literal, no interpolation
      return node.interpParts[0]

    # Build concatenation chain (recursively transform parts that might contain interpolations)
    var parts: seq[XLangNode] = @[]

    for i, part in node.interpParts:
      if node.interpIsExpr[i]:
        # Expression - recursively transform it
        parts.add(transformStringInterpolationHelper(part))
      else:
        # String literal part
        parts.add(part)

    # Create chain of binary & operations
    result = parts[0]
    for i in 1..<parts.len:
      result = XLangNode(
        kind: xnkBinaryExpr,
        binaryOp: "&",
        binaryLeft: result,
        binaryRight: parts[i]
      )

  of xnkCallExpr:
    # Recursively transform arguments
    result = node
    result.args = node.args.map(transformStringInterpolationHelper)

  of xnkBinaryExpr:
    result = node
    result.binaryLeft = transformStringInterpolationHelper(node.binaryLeft)
    result.binaryRight = transformStringInterpolationHelper(node.binaryRight)

  of xnkUnaryExpr:
    result = node
    result.unaryOperand = transformStringInterpolationHelper(node.unaryOperand)

  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    result = node
    if node.initializer.isSome():
      result.initializer = some(transformStringInterpolationHelper(node.initializer.get()))

  of xnkAsgn:
    result = node
    result.asgnRight = transformStringInterpolationHelper(node.asgnRight)

  of xnkReturnStmt:
    result = node
    if node.returnExpr.isSome():
      result.returnExpr = some(transformStringInterpolationHelper(node.returnExpr.get()))

  of xnkRaiseStmt:
    result = node
    if node.raiseExpr.isSome():
      result.raiseExpr = some(transformStringInterpolationHelper(node.raiseExpr.get()))

  of xnkBlockStmt:
    result = node
    result.blockBody = node.blockBody.map(transformStringInterpolationHelper)

  of xnkIfStmt:
    result = node
    result.ifCondition = transformStringInterpolationHelper(node.ifCondition)
    result.ifBody = transformStringInterpolationHelper(node.ifBody)
    if node.elseBody.isSome():
      result.elseBody = some(transformStringInterpolationHelper(node.elseBody.get()))

  of xnkFuncDecl, xnkMethodDecl:
    result = node
    # Transform function body
    if node.kind == xnkFuncDecl:
      result.body = transformStringInterpolationHelper(node.body)
    else:
      result.mbody = transformStringInterpolationHelper(node.mbody)

  of xnkClassDecl, xnkStructDecl:
    result = node
    result.members = node.members.map(transformStringInterpolationHelper)

  of xnkNamespace:
    result = node
    result.namespaceBody = node.namespaceBody.map(transformStringInterpolationHelper)

  of xnkFile:
    result = node
    result.moduleDecls = node.moduleDecls.map(transformStringInterpolationHelper)

  else:
    # For all other nodes, return as-is (don't recurse into everything)
    result = node

proc transformStringInterpolation*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Transform string interpolation into Nim string concatenation
  ## Recursively handles interpolations in all expression contexts
  result = transformStringInterpolationHelper(node)
