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

import ../../xlangtypes
import options

proc transformStringInterpolation*(node: XLangNode): XLangNode =
  ## Transform string interpolation into Nim string concatenation or strformat
  if node.kind != xnkStringInterpolation:
    return node

  # Strategy: Build concatenation chain with & operator
  # f"Hello {name}!" → "Hello " & name & "!"

  if node.interpParts.len == 0:
    # Empty interpolation, return empty string
    return XLangNode(kind: xnkStringLit, literalValue: "")

  if node.interpParts.len == 1 and not node.interpIsExpr[0]:
    # Single string literal, no interpolation
    return node.interpParts[0]

  # Build concatenation chain
  var parts: seq[XLangNode] = @[]

  for i, part in node.interpParts:
    if node.interpIsExpr[i]:
      # Expression - may need to convert to string with $
      # For now, assume it's already the right type or will be handled
      parts.add(part)
    else:
      # String literal
      parts.add(part)

  # Build left-associative concatenation: a & b & c
  if parts.len == 1:
    result = parts[0]
  else:
    result = parts[0]
    for i in 1..<parts.len:
      result = XLangNode(
        kind: xnkBinaryExpr,
        binaryOp: "&",
        binaryLeft: result,
        binaryRight: parts[i]
      )

  # Alternative strategy (commented out): Use strformat
  # Could generate: fmt"Hello {name}!" directly if all parts are known
  # This would be more idiomatic but requires importing strformat
