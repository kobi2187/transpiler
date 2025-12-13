## String Interpolation Transformation
##
## Transforms string interpolation/template strings to string concatenation.
## This pass is for target languages that don't have native string interpolation.
## Languages like Nim with strformat should skip this pass.
##
## Examples:
## - Python f"Hello {name}, you are {age} years old"
## - JavaScript `Hello ${name}, you are ${age} years old`
## - C# $"Hello {name}, you are {age} years old"
##
## Transforms to:
## - String concatenation: "Hello " & name & ", you are " & $age & " years old"
## - Non-string expressions automatically get $ for stringification

import ../../../xlangtypes
import options, sequtils

proc transformStringInterpolation*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.}

proc needsStringification(node: XLangNode): bool =
  ## Check if a node needs $ for string conversion
  ## String literals and explicit string operations don't need it
  case node.kind
  of xnkStringLit:
    return false
  of xnkBinaryExpr:
    # If it's string concatenation, assume it's already a string
    return node.binaryOp != "&"
  of xnkCallExpr:
    # Assume function calls might not return strings
    return true
  else:
    # Idents, literals, etc. - likely need stringification if not already a string
    return true

proc wrapWithStringify(node: XLangNode): XLangNode =
  ## Wrap a node with $ operator for stringification if needed
  if needsStringification(node):
    return XLangNode(
      kind: xnkUnaryExpr,
      unaryOp: "$",
      unaryOperand: node
    )
  else:
    return node

proc transformStringInterpolationHelper(node: XLangNode): XLangNode =
  ## Helper that recursively transforms string interpolations in any expression context
  case node.kind
  of xnkStringInterpolation:
    # Strategy: Build concatenation chain with & operator
    # f"Hello {name}!" → "Hello " & name & "!"
    # f"Count: {n}" → "Count: " & $n  (auto-stringification)

    if node.interpParts.len == 0:
      # Empty interpolation, return empty string
      return XLangNode(kind: xnkStringLit, literalValue: "")

    if node.interpParts.len == 1 and not node.interpIsExpr[0]:
      # Single string literal, no interpolation
      return node.interpParts[0]

    # Build concatenation chain, skipping empty strings and handling stringification
    var parts: seq[XLangNode] = @[]

    for i, part in node.interpParts:
      if node.interpIsExpr[i]:
        # Expression - recursively transform it and wrap with $ if needed
        let transformed = transformStringInterpolationHelper(part)
        parts.add(wrapWithStringify(transformed))
      else:
        # String literal part - skip if empty
        if part.kind == xnkStringLit and part.literalValue.len > 0:
          parts.add(part)
        elif part.kind != xnkStringLit:
          # Non-string-lit parts (shouldn't happen but be safe)
          parts.add(part)

    # Handle edge cases
    if parts.len == 0:
      return XLangNode(kind: xnkStringLit, literalValue: "")
    if parts.len == 1:
      return parts[0]

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
  ## Transform string interpolation into string concatenation with & operator
  ## Automatically adds $ operator for non-string expressions
  ## Recursively handles interpolations in all expression contexts
  result = transformStringInterpolationHelper(node)
