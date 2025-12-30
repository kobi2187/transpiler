## Conversion Operator Transform
##
## Converts C# implicit/explicit conversion operators to Nim converter/proc.
##
## C# implicit conversion:
##   public static implicit operator long(Long value) => value.Value;
##
## Becomes Nim converter:
##   converter toLong*(value: Long): long = value.Value
##
## C# explicit conversion:
##   public static explicit operator byte(BigDecimal value) { ... }
##
## Becomes Nim proc:
##   proc toByte*(value: BigDecimal): byte = ...
##
## Note: Nim converters are automatically applied for implicit conversions,
## while explicit conversions require calling the proc directly.

import ../../../xlangtypes
import options
import strutils

proc capitalizeFirst(s: string): string =
  ## Capitalize the first letter of a string
  if s.len == 0:
    return s
  result = s[0].toUpperAscii() & s[1..^1]

proc getFuncNameFromType(typeNode: XLangNode): string =
  ## Extract a function name from a type node
  ## e.g., "long" -> "toLong", "byte" -> "toByte"
  if typeNode.kind == xnkNamedType:
    result = "to" & capitalizeFirst(typeNode.typeName)
  else:
    # Fallback for complex types
    result = "toConverted"

proc transformConversionOpToProc*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Transform C# conversion operators into Nim converter or proc
  if node.kind != xnkExternal_ConversionOp:
    return node

  # Extract conversion information
  let isImplicit = node.extConversionIsImplicit
  let paramName = node.extConversionParamName
  let fromType = node.extConversionFromType
  let toType = node.extConversionToType
  let body = node.extConversionBody  # No longer Option

  # Generate function name based on target type
  let funcName = getFuncNameFromType(toType)

  # Create parameter for the conversion function
  # C# conversion operators take one parameter of the source type
  let param = XLangNode(
    kind: xnkParameter,
    paramName: paramName,
    paramType: some(fromType),
    defaultValue: none(XLangNode)
  )

  # Create the function declaration
  # Conversion operators are static in C#, so mark as static
  var funcNode = XLangNode(
    kind: xnkFuncDecl,
    funcName: funcName,
    params: @[param],
    returnType: some(toType),
    body: body,
    isAsync: false,
    funcIsStatic: true  # Conversion operators are static - no self parameter
  )

  # For implicit conversions, we could add a pragma or annotation
  # In Nim, we use the {.converter.} pragma
  if isImplicit:
    # Add converter pragma - this would be represented as an annotation/pragma node
    # For now, we create a regular proc and the code generator will need to handle
    # the converter keyword based on context
    discard

  result = funcNode
