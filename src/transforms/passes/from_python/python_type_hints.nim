## Python Type Hints to Nim Type Annotations
##
## Transforms Python 3.5+ type hints to Nim's static type system
##
## Python:
##   def greet(name: str, age: int) -> str:
##     return f"Hello {name}, you are {age}"
##
## Nim:
##   proc greet(name: string, age: int): string =
##     return "Hello " & name & ", you are " & $age

import core/xlangtypes
import semantic/semantic_analysis
import options
import strutils
import tables

# Map Python type names to Nim type names
const PYTHON_TO_NIM_TYPES = {
  # Built-in types
  "str": "string",
  "int": "int",
  "float": "float",
  "bool": "bool",
  "bytes": "seq[byte]",
  "bytearray": "seq[byte]",

  # Collections
  "list": "seq",
  "dict": "Table",
  "set": "HashSet",
  "tuple": "tuple",
  "frozenset": "HashSet",

  # Optional/None
  "None": "void",
  "NoneType": "void",

  # typing module types
  "List": "seq",
  "Dict": "Table",
  "Set": "HashSet",
  "Tuple": "tuple",
  "Optional": "Option",
  "Union": "union",  # Special handling needed
  "Any": "any",      # In Nim, typically use generics or RootObj
  "Callable": "proc",
  "Iterable": "iterator",
  "Iterator": "iterator",
  "Sequence": "seq",
  "Mapping": "Table",

  # IO types
  "TextIO": "File",
  "BinaryIO": "File",

  # Special forms
  "Literal": "enum",  # Literal types
  "Final": "const",   # Immutable
  "ClassVar": "static",

  # Async
  "Awaitable": "Future",
  "Coroutine": "Future",
  "AsyncIterator": "AsyncIterator"
}.toTable

proc transformPythonType(typeNode: XLangNode): XLangNode =
  ## Transform a Python type annotation to Nim type

  case typeNode.kind
  of xnkNamedType:
    let typeName = typeNode.typeName

    # Map simple types
    if PYTHON_TO_NIM_TYPES.hasKey(typeName):
      let nimType = PYTHON_TO_NIM_TYPES[typeName]
      return XLangNode(kind: xnkNamedType, typeName: nimType)

    # Keep custom types as-is (class names, etc.)
    return typeNode

  of xnkGenericType:
    # Handle generic types like List[int], Dict[str, int]
    var baseName = ""
    if typeNode.genericBase != none(XLangNode) and typeNode.genericBase.get.kind == xnkNamedType:
      baseName = typeNode.genericBase.get.typeName
    elif typeNode.genericTypeName != "":
      baseName = typeNode.genericTypeName

    if baseName == "Optional":
      # Optional[T] → Option[T]
      if typeNode.genericArgs.len > 0:
        return XLangNode(
          kind: xnkGenericType,
          genericBase: some(XLangNode(kind: xnkNamedType, typeName: "Option")),
          genericArgs: @[transformPythonType(typeNode.genericArgs[0])]
        )

    elif baseName == "Union":
      # Union[A, B, C] - needs variant object or keep as union
      # For now, mark as special union type
      var transformedArgs: seq[XLangNode] = @[]
      for arg in typeNode.genericArgs:
        transformedArgs.add(transformPythonType(arg))
      return XLangNode(
        kind: xnkUnionType,
        unionTypes: transformedArgs
      )

    elif baseName in ["List", "list"]:
      # List[T] → seq[T]
      if typeNode.genericArgs.len > 0:
        return XLangNode(
          kind: xnkGenericType,
          genericBase: some(XLangNode(kind: xnkNamedType, typeName: "seq")),
          genericArgs: @[transformPythonType(typeNode.genericArgs[0])]
        )

    elif baseName in ["Dict", "dict"]:
      # Dict[K, V] → Table[K, V]
      if typeNode.genericArgs.len == 2:
        return XLangNode(
          kind: xnkGenericType,
          genericBase: some(XLangNode(kind: xnkNamedType, typeName: "Table")),
          genericArgs: @[
            transformPythonType(typeNode.genericArgs[0]),
            transformPythonType(typeNode.genericArgs[1])
          ]
        )

    elif baseName in ["Set", "set"]:
      # Set[T] → HashSet[T]
      if typeNode.genericArgs.len > 0:
        return XLangNode(
          kind: xnkGenericType,
          genericBase: some(XLangNode(kind: xnkNamedType, typeName: "HashSet")),
          genericArgs: @[transformPythonType(typeNode.genericArgs[0])]
        )

    elif baseName == "Callable":
      # Callable[[ArgTypes], ReturnType] → proc(args): RetType
      # This is complex, simplified handling
      return XLangNode(kind: xnkNamedType, typeName: "proc")

    # Default: transform base and args recursively
    var transformedArgs: seq[XLangNode] = @[]
    for arg in typeNode.genericArgs:
      transformedArgs.add(transformPythonType(arg))

    return XLangNode(
      kind: xnkGenericType,
      genericBase: if typeNode.genericBase != none(XLangNode): some(transformPythonType(typeNode.genericBase.get)) else: none(XLangNode),
      genericArgs: transformedArgs
    )

  of xnkTupleExpr:
    # Tuple[int, str, bool] → tuple[a: int, b: string, c: bool]
    # Python tuples don't have field names, Nim tuples do
    # We'll generate field names: field0, field1, etc.
    var fields: seq[XLangNode] = @[]
    for i, elemType in typeNode.elements:
      fields.add(XLangNode(
        kind: xnkFieldDecl,
        fieldName: "field" & $i,
        fieldType: transformPythonType(elemType),
        fieldInitializer: none(XLangNode)
      ))

    return XLangNode(
      kind: xnkStructDecl,  # Tuple as struct
      typeNameDecl: "tuple",
      members: fields,
      baseTypes: @[]
    )

  else:
    return typeNode

proc transformPythonTypeHints*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform Python type hints in function signatures and variables

  case node.kind
  of xnkFuncDecl, xnkMethodDecl:
    # Transform parameter types and return type
    var newParams: seq[XLangNode] = @[]

    for param in node.params:
      if param.kind == xnkParameter:
        var newParam = param
        if param.paramType.isSome:
          newParam.paramType = some(transformPythonType(param.paramType.get))
        newParams.add(newParam)
      else:
        newParams.add(param)

    var newReturnType = node.returnType
    if newReturnType.isSome:
      newReturnType = some(transformPythonType(newReturnType.get))

    case node.kind:
    of xnkFuncDecl:
      result = XLangNode(
        kind: xnkFuncDecl,
        funcName: node.funcName,
        params: newParams,
        returnType: newReturnType,
        body: node.body,
        isAsync: node.isAsync
      )
    of xnkMethodDecl:
      result = XLangNode(
        kind: xnkMethodDecl,
        receiver: node.receiver,
        methodName: node.methodName,
        mparams: newParams,
        mreturnType: newReturnType,
        mbody: node.mbody,
        methodIsAsync: node.methodIsAsync
      )
    else:
      result = node

  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    # Transform variable type annotations
    var newDeclType = none(XLangNode)
    if node.declType.isSome:
      newDeclType = some(transformPythonType(node.declType.get))

    case node.kind:
    of xnkVarDecl:
      result = XLangNode(kind: xnkVarDecl, declName: node.declName, declType: newDeclType, initializer: node.initializer)
    of xnkLetDecl:
      result = XLangNode(kind: xnkLetDecl, declName: node.declName, declType: newDeclType, initializer: node.initializer)
    of xnkConstDecl:
      result = XLangNode(kind: xnkConstDecl, declName: node.declName, declType: newDeclType, initializer: node.initializer)
    else:
      result = node

  of xnkClassDecl:
    # Transform class member type annotations
    var newMembers: seq[XLangNode] = @[]
    for member in node.members:
      newMembers.add(transformPythonTypeHints(member, semanticInfo))

    result = XLangNode(
      kind: xnkClassDecl,
      typeNameDecl: node.typeNameDecl,
      baseTypes: node.baseTypes,
      members: newMembers
    )

  else:
    result = node

# Special handling for Python 3.10+ union syntax
# def func(x: int | str) → def func(x: Union[int, str])
# This gets normalized to Union before type transformation

proc transformPythonUnionSyntax*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform Python 3.10+ union operator (int | str)
  ## This should happen before general type hint transformation

  if node.kind == xnkBinaryExpr and node.binaryOp == opBitOr:
    # This might be a type union: int | str
    # Check if both operands are types
    # For now, convert to Union generic type

    result = XLangNode(
      kind: xnkUnionType,
      unionTypes: @[node.binaryLeft, node.binaryRight]
    )
  else:
    result = node

# TypeVar handling (generic type variables)
# Python: T = TypeVar('T')
# Nim: generic types are declared differently

proc transformTypeVar*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform Python TypeVar declarations
  ##
  ## Python:
  ##   T = TypeVar('T')
  ##   def first(items: List[T]) -> T:
  ##
  ## Nim:
  ##   proc first[T](items: seq[T]): T =
  ##
  ## The TypeVar becomes a generic parameter in Nim

  # This would need context about where T is used
  # For now, placeholder
  result = node
