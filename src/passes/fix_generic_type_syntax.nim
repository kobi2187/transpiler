## Fix Generic Type Syntax Pass
##
## Converts generic type names like "List<int>" into proper xnkGenericType nodes
## This handles cases where the C# parser outputs generic types as simple strings
##
## Example:
##   xnkNamedType(typeName: "List<int>")
## Becomes:
##   xnkGenericType(genericTypeName: "List", genericArgs: [xnkNamedType("int")])

import ../../xlangtypes
import ../transforms/helpers
import options, strutils, sequtils

proc parseGenericType(typeName: string): tuple[baseName: string, args: seq[string], isGeneric: bool] =
  ## Parse a generic type string like "List<int>" or "Dictionary<string, int>"
  ## Returns (baseName, args, isGeneric)

  let openBracket = typeName.find('<')
  if openBracket == -1:
    return (typeName, @[], false)

  let closeBracket = typeName.rfind('>')
  if closeBracket == -1 or closeBracket <= openBracket:
    return (typeName, @[], false)

  let baseName = typeName[0..<openBracket].strip()
  let argsStr = typeName[openBracket+1..<closeBracket].strip()

  # Simple split by comma (doesn't handle nested generics perfectly, but good enough for now)
  var args: seq[string] = @[]
  var current = ""
  var depth = 0

  for c in argsStr:
    if c == '<':
      depth.inc
      current.add(c)
    elif c == '>':
      depth.dec
      current.add(c)
    elif c == ',' and depth == 0:
      if current.len > 0:
        args.add(current.strip())
      current = ""
    else:
      current.add(c)

  if current.len > 0:
    args.add(current.strip())

  return (baseName, args, true)

proc parseArrayType(typeName: string): tuple[elementType: string, isArray: bool] =
  ## Check if a type name ends with [] and extract the element type
  ## Returns (elementType, isArray)
  if typeName.endsWith("[]"):
    return (typeName[0..^3], true)
  else:
    return (typeName, false)

proc convertGenericTypeName(typeName: string): XLangNode =
  ## Convert a type name string (possibly generic and/or array) into an XLang type node

  # First check if it's an array type
  let (baseType, isArray) = parseArrayType(typeName)

  if isArray:
    # It's an array - recursively convert the element type
    let elementTypeNode = convertGenericTypeName(baseType)
    return XLangNode(
      kind: xnkArrayType,
      elementType: elementTypeNode
    )

  # Not an array, check if it's generic
  let (baseName, args, isGeneric) = parseGenericType(baseType)

  if not isGeneric:
    return XLangNode(kind: xnkNamedType, typeName: baseType)

  # Create generic type node
  var genericArgs: seq[XLangNode] = @[]
  for arg in args:
    genericArgs.add(convertGenericTypeName(arg))  # Recursive for nested generics

  return XLangNode(
    kind: xnkGenericType,
    genericTypeName: baseName,
    genericBase: none(XLangNode),
    genericArgs: genericArgs
  )

proc fixGenericTypesInNode(node: var XLangNode) =
  ## Fix generic type syntax in a single node (replaces node if needed)
  if node.isNil:
    return

  case node.kind
  of xnkNamedType:
    # Check if this is an array type or generic type in disguise
    let (arrayBaseType, isArray) = parseArrayType(node.typeName)

    if isArray:
      # It's an array type - convert the entire thing
      node = convertGenericTypeName(node.typeName)
    else:
      # Not an array, check if it's a generic type
      let (baseName, args, isGeneric) = parseGenericType(node.typeName)
      if isGeneric:
        # Convert to proper generic type - create new node
        var genericArgs: seq[XLangNode] = @[]
        for arg in args:
          genericArgs.add(convertGenericTypeName(arg))

        # Replace the node entirely
        node = XLangNode(
          kind: xnkGenericType,
          genericTypeName: baseName,
          genericBase: none(XLangNode),
          genericArgs: genericArgs
        )

  of xnkGenericType:
    # Also fix the base type name if it has generics
    let (baseName, args, isGeneric) = parseGenericType(node.genericTypeName)
    if isGeneric:
      # This shouldn't happen, but handle it anyway
      node.genericTypeName = baseName

  else:
    discard

proc applyGenericTypeFix*(root: XLangNode): XLangNode =
  ## Apply generic type syntax fix to entire XLang AST
  ## This is the main entry point for this pass
  result = root

  # Apply recursively using applyToKids which handles the tree traversal
  applyToKids(result, fixGenericTypesInNode)

  # Finally fix the root
  fixGenericTypesInNode(result)
