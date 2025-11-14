## Extension Methods Transformation
##
## Transforms C# extension methods to regular Nim procedures
##
## C# extension methods are static methods where the first parameter has 'this' modifier:
##   public static int WordCount(this string str) { ... }
##
## In Nim, these become regular procedures:
##   proc wordCount(str: string): int = ...
##
## Usage also changes:
##   C#: str.WordCount()
##   Nim: str.wordCount() or wordCount(str)

import ../../xlangtypes
import options
import strutils

proc isExtensionMethod(node: XLangNode): bool =
  ## Check if this function is a C# extension method
  ## Extension methods are static and have 'this' on first parameter
  if node.kind notin {xnkFuncDecl, xnkMethodDecl}:
    return false

  # In XLang AST, extension method info would be in metadata
  # For now, check if function name or params have indicators
  # A proper implementation would check:
  # 1. Function is static
  # 2. First parameter has 'this' modifier
  # This would require extending XLangNode to track parameter modifiers

  # Placeholder check - would need metadata
  return false

proc transformExtensionMethods*(node: XLangNode): XLangNode =
  ## Transform C# extension methods to regular Nim procedures
  case node.kind
  of xnkFuncDecl, xnkMethodDecl:
    # Check if this is an extension method
    if not isExtensionMethod(node):
      return node

    # Transform extension method to regular proc
    # C#:
    #   public static int WordCount(this string str) { ... }
    #
    # Nim:
    #   proc wordCount(str: string): int = ...

    # The transformation is mainly:
    # 1. Remove 'static' modifier (Nim procs are already static-like)
    # 2. Remove 'this' from first parameter
    # 3. Keep same parameter list and body

    result = XLangNode(
      kind: xnkFuncDecl,  # Convert method to function
      funcName: node.funcName,
      params: node.params,  # 'this' modifier would be removed from param metadata
      returnType: node.returnType,
      body: node.body,
      isAsync: node.isAsync
    )

  of xnkCallExpr:
    # Also need to transform extension method calls
    # C#: str.WordCount() where WordCount is extension
    # Nim: wordCount(str) or str.wordCount()

    # In Nim, both syntaxes work (UFCS - Uniform Function Call Syntax)
    # So member access to extension method can stay as-is
    result = node

  else:
    result = node

# Note: This transformation is simplified.
# A complete implementation would:
#
# 1. Detect extension methods by checking:
#    - Function is in a static class
#    - First parameter has 'this' modifier
#    - Method is static
#
# 2. Track extension method imports:
#    - C#: using ExtensionNamespace;
#    - Nim: import extension_module
#
# 3. Transform method calls appropriately:
#    - obj.ExtensionMethod(args) → extensionMethod(obj, args)
#    - But in Nim UFCS, obj.extensionMethod(args) works too!
#
# 4. Handle extension method resolution:
#    - C# has complex rules for finding extension methods
#    - Nim's UFCS is simpler - just needs the proc in scope
