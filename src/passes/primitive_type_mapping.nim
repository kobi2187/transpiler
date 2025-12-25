## Primitive Type Mapping Pass
##
## Maps C#/Java primitive types to their Nim equivalents
## This runs after transformations but before Nim AST conversion
##
## Mappings:
## - long -> int64
## - ulong -> uint64
## - byte -> uint8
## - sbyte -> int8
## - short -> int16
## - ushort -> uint16
## - uint -> uint32
## - decimal -> float64 (or BigInt for precision)
## - object -> any (or RootObj)
## - String -> string
## - Boolean -> bool

import ../../xlangtypes
import ../transforms/helpers
import options, tables

const primitiveTypeMap = {
  "long": "int64",
  "ulong": "uint64",
  "byte": "uint8",
  "sbyte": "int8",
  "short": "int16",
  "ushort": "uint16",
  "uint": "uint32",
  "int": "int32",  # Explicit int32 for clarity
  "decimal": "float64",  # Note: loses precision, may need BigInt
  "object": "RootObj",
  "Object": "RootObj",
  "String": "string",
  "Boolean": "bool",
  "boolean": "bool",
  "char": "char",
  "Char": "char",
  "void": "void",
  "Void": "void"
}.toTable

proc mapPrimitiveType(typeName: string): string =
  ## Map a primitive type name to its Nim equivalent
  if primitiveTypeMap.hasKey(typeName):
    return primitiveTypeMap[typeName]
  return typeName

proc mapTypesInNode(node: var XLangNode) =
  ## Map primitive types in an XLang node (mutates in place)
  if node.isNil:
    return

  case node.kind
  # Named types - map the type name
  of xnkNamedType:
    node.typeName = mapPrimitiveType(node.typeName)

  # Array types - map the element type
  of xnkArrayType:
    mapTypesInNode(node.elementType)

  # Pointer types - map the target type
  of xnkPointerType, xnkReferenceType:
    mapTypesInNode(node.referentType)

  # Generic types - map type name and arguments
  of xnkGenericType:
    node.genericTypeName = mapPrimitiveType(node.genericTypeName)
    for arg in node.genericArgs.mitems:
      mapTypesInNode(arg)

  # Generic name (C# specific) - map identifier and arguments
  of xnkGenericName:
    node.genericNameIdentifier = mapPrimitiveType(node.genericNameIdentifier)
    for arg in node.genericNameArgs.mitems:
      mapTypesInNode(arg)

  # Function types - map parameter and return types
  of xnkFuncType:
    for param in node.funcParams.mitems:
      mapTypesInNode(param)
    if node.funcReturnType.isSome:
      var retType = node.funcReturnType.get
      mapTypesInNode(retType)
      node.funcReturnType = some(retType)

  # Variable/field declarations - map their types
  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    if node.declType.isSome:
      var declType = node.declType.get
      mapTypesInNode(declType)
      node.declType = some(declType)

  of xnkFieldDecl:
    if not node.fieldType.isNil:
      mapTypesInNode(node.fieldType)

  # Function declarations - map return type and parameters
  of xnkFuncDecl, xnkMethodDecl:
    if node.returnType.isSome:
      var retType = node.returnType.get
      mapTypesInNode(retType)
      node.returnType = some(retType)
    for param in node.params.mitems:
      mapTypesInNode(param)

  # Class/struct/interface members - map recursively
  of xnkClassDecl, xnkStructDecl:
    for member in node.members.mitems:
      mapTypesInNode(member)
    for baseType in node.baseTypes.mitems:
      mapTypesInNode(baseType)

  of xnkInterfaceDecl:
    for member in node.extInterfaceMembers.mitems:
      mapTypesInNode(member)
    for baseType in node.extInterfaceBaseTypes.mitems:
      mapTypesInNode(baseType)

  else:
    discard

  # Note: apply_to_kids is used by the transformation passes in each handled case above
  # This pass focuses on type names and type-bearing nodes

proc applyPrimitiveTypeMapping*(root: XLangNode): XLangNode =
  ## Apply primitive type mapping to entire XLang AST
  ## This is the main entry point for this pass
  result = root

  # Apply recursively using applyToKids which handles the tree traversal
  applyToKids(result, mapTypesInNode)

  # Finally map the root
  mapTypesInNode(result)
