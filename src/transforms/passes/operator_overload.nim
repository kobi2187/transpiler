## Operator Overloading Normalization
##
## Normalizes operator overload definitions from various languages to Nim's syntax
##
## Examples:
## - Python: def __add__(self, other): → proc `+`(a, b: Type): Type
## - C++: Type operator+(const Type& other) → proc `+`(a, b: Type): Type
## - C#: public static Type operator+(Type a, Type b) → proc `+`(a, b: Type): Type

import ../../../xlangtypes
import options
import strutils
import tables

# Mapping from special method names to operators
const OPERATOR_MAP = {
  # Python special methods
  "__add__": "+",
  "__sub__": "-",
  "__mul__": "*",
  "__div__": "/",
  "__truediv__": "/",
  "__floordiv__": "div",
  "__mod__": "mod",
  "__pow__": "^",
  "__eq__": "==",
  "__ne__": "!=",
  "__lt__": "<",
  "__le__": "<=",
  "__gt__": ">",
  "__ge__": ">=",
  "__and__": "and",
  "__or__": "or",
  "__xor__": "xor",
  "__neg__": "-",
  "__pos__": "+",
  "__invert__": "not",
  "__getitem__": "[]",
  "__setitem__": "[]=",
  "__len__": "len",
  "__contains__": "in",

  # C# operator names (used in operator keyword)
  "operator+": "+",
  "operator-": "-",
  "operator*": "*",
  "operator/": "/",
  "operator%": "mod",
  "operator==": "==",
  "operator!=": "!=",
  "operator<": "<",
  "operator<=": "<=",
  "operator>": ">",
  "operator>=": ">=",
  "operator&": "and",
  "operator|": "or",
  "operator^": "xor",
  "operator~": "not",
  "operator!": "not",
  "operator[]": "[]"
}.toTable

proc isOperatorOverload(funcName: string): bool =
  ## Check if function name is an operator overload
  OPERATOR_MAP.hasKey(funcName) or funcName.startsWith("operator")

proc getOperatorSymbol(funcName: string): string =
  ## Get the operator symbol from function name
  if OPERATOR_MAP.hasKey(funcName):
    return OPERATOR_MAP[funcName]

  # Handle C-style operator functions
  if funcName.startsWith("operator"):
    let op = funcName[8..^1].strip()
    if op.len > 0:
      return op

  return funcName

# Helper: construct a function/method node with operator name in backticks
proc buildOperatorNode*(k: XLangNodeKind, src: XLangNode, opSymbol: string): XLangNode =
  case k
  of xnkFuncDecl:
    result = XLangNode(kind: xnkFuncDecl)
    result.funcName = "`" & opSymbol & "`"
    result.params = src.params
    result.returnType = src.returnType
    result.body = src.body
    result.isAsync = src.isAsync
  of xnkMethodDecl:
    result = XLangNode(kind: xnkMethodDecl)
    result.funcName = "`" & opSymbol & "`"
    result.params = src.params
    result.returnType = src.returnType
    result.body = src.body
    result.isAsync = src.isAsync
    if src.kind == xnkMethodDecl:
      # copy receiver if present
      if src.receiver != none(XLangNode):
        result.receiver = src.receiver
  else:
    result = src

proc transformOperatorOverload*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Normalize operator overload definitions to Nim syntax
  case node.kind
  of xnkFuncDecl, xnkMethodDecl:
    # Check if this is an operator overload
    if not isOperatorOverload(node.funcName):
      return node

    let opSymbol = getOperatorSymbol(node.funcName)

    # Create new function with operator name in backticks using helper
    result = buildOperatorNode(node.kind, node, opSymbol)

    # Special handling for Python's __getitem__ and __setitem__
    # These need special signatures in Nim
    if node.funcName == "__getitem__":
      # def __getitem__(self, key): → proc `[]`(self: Type, key: KeyType): ValueType
      # Already handled by general case above
      discard

    elif node.funcName == "__setitem__":
      # def __setitem__(self, key, value): → proc `[]=`(self: var Type, key: KeyType, value: ValueType)
      # Need to ensure first param is var (mutable)
      if result.params.len > 0:
        var newParams = result.params
        # TODO: add and populate mutability field to xnkParameter in xlangtypes,
        # then mark newParams[0].isMutable = true
        result.params = newParams

  else:
    result = node
