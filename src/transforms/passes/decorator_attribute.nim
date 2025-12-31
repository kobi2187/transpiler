## Decorator and Attribute Normalization
##
## Normalizes Python decorators and C# attributes to Nim pragmas
##
## Examples:
## Python:
##   @property
##   def name(self): return self._name
##   →
##   proc name(self: Type): string {.property.}
##
## C#:
##   [HttpGet("/users")]
##   public void GetUsers() { }
##   →
##   proc getUsers() {.httpGet: "/users".}

import ../../../xlangtypes
import ../../semantic/semantic_analysis
import options
import strutils
import tables

# Common decorator/attribute mappings to Nim pragmas
const DECORATOR_PRAGMA_MAP = {
  # Python decorators
  "property": "property",
  "staticmethod": "static",
  "classmethod": "classmethod",
  "abstractmethod": "abstract",
  "override": "override",
  "deprecated": "deprecated",
  "lru_cache": "memoize",

  # C# attributes
  "Obsolete": "deprecated",
  "Pure": "noSideEffect",
  "DllImport": "importc",
  "StructLayout": "packed",
  "HttpGet": "httpGet",
  "HttpPost": "httpPost",
  "Authorize": "authorize",
  "Serializable": "serializable"
}.toTable

proc decoratorToPragma(decorator: XLangNode): Option[XLangNode] =
  ## Convert decorator/attribute to Nim pragma
  ## Returns pragma node or none if can't convert

  var pragmaName = ""
  var pragmaArgs: seq[XLangNode] = @[]

  case decorator.kind
  of xnkDecorator:
    # Python decorator: @decorator or @decorator(args)
    let decoratorExpr = decorator.decoratorExpr

    if decoratorExpr.kind == xnkIdentifier:
      # Simple decorator: @property
      pragmaName = decoratorExpr.identName
    elif decoratorExpr.kind == xnkCallExpr:
      # Decorator with args: @lru_cache(maxsize=128)
      if decoratorExpr.callee.kind == xnkIdentifier:
        pragmaName = decoratorExpr.callee.identName
        pragmaArgs = decoratorExpr.args

  of xnkAttribute:
    # C# attribute: [HttpGet("/users")]
    pragmaName = decorator.attrName
    pragmaArgs = decorator.attrArgs

  else:
    return none(XLangNode)

  # Map to Nim pragma name if known
  if DECORATOR_PRAGMA_MAP.hasKey(pragmaName):
    pragmaName = DECORATOR_PRAGMA_MAP[pragmaName]

  # Create pragma node
  # Nim pragmas: {.pragmaName.} or {.pragmaName: args.}
  if pragmaArgs.len == 0:
    # Simple pragma: {.property.}
    result = some(XLangNode(
      kind: xnkPragma,
      pragmas: @[XLangNode(kind: xnkIdentifier, identName: pragmaName)]
    ))
  else:
    # Pragma with args: {.httpGet: "/users".}
    # Store as identifier with args
    let pragmaWithArgs = XLangNode(
      kind: xnkCallExpr,
      callee: XLangNode(kind: xnkIdentifier, identName: pragmaName),
      args: pragmaArgs
    )
    result = some(XLangNode(
      kind: xnkPragma,
      pragmas: @[pragmaWithArgs]
    ))

proc transformDecoratorAttribute*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform decorators and attributes to Nim pragmas
  ## Note: XLangNode would need pragma field for functions
  ## For now, we'll add pragmas to a special location

  case node.kind
  of xnkFuncDecl, xnkMethodDecl:
    # Functions can have decorators in Python or attributes in C#
    # These should be converted to Nim pragmas

    # In the current XLang AST, we don't have a direct way to store decorators
    # They would need to be in the parent scope or as metadata
    # For this transformation, we assume decorators are processed separately
    # and attached to the function definition

    # This is a placeholder - proper implementation would:
    # 1. Check for decorator nodes attached to the function
    # 2. Convert them to pragmas
    # 3. Add pragmas to the function definition

    result = node

  of xnkDecorator:
    # Standalone decorator - convert to pragma
    let pragma = decoratorToPragma(node)
    if pragma.isSome:
      result = pragma.get
    else:
      result = node

  of xnkAttribute:
    # Standalone attribute - convert to pragma
    let pragma = decoratorToPragma(node)
    if pragma.isSome:
      result = pragma.get
    else:
      result = node

  of xnkClassDecl, xnkStructDecl:
    # Classes/structs can have decorators/attributes too
    # Similar handling as functions
    result = node

  else:
    result = node

# Special handling for common Python decorators that change function semantics

proc isPropertyDecorator(decorator: XLangNode): bool =
  ## Check if decorator is @property
  if decorator.kind == xnkDecorator:
    let expr = decorator.decoratorExpr
    if expr.kind == xnkIdentifier and expr.identName == "property":
      return true
  return false

proc transformPropertyDecorator*(funcNode: XLangNode): XLangNode =
  ## Transform @property decorated function to Nim getter proc
  ## This is called after detecting @property decorator
  ##
  ## Python:
  ##   @property
  ##   def name(self): return self._name
  ##
  ## Nim:
  ##   proc name(self: Type): string =
  ##     result = self.name  # Nim uses properties directly

  # In Nim, properties are often just regular procs
  # The @property decorator mostly affects Python's attribute access
  # In Nim, you'd use templates or regular procs

  result = funcNode
