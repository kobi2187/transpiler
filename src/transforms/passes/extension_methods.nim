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

import ../../../xlangtypes
import options
import strutils

proc transformExtensionMethods*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Transform C# extension methods to regular Nim procedures
  case node.kind
  of xnkExternal_ExtensionMethod:
    # Transform extension method to regular proc
    # C#:
    #   public static PadPosition ToOld(this Padder.PadPosition padPosition) { ... }
    #
    # Nim:
    #   proc toOld(padPosition: Padder.PadPosition): PadPosition = ...

    # The transformation:
    # 1. Convert to xnkFuncDecl (Nim procs are already static-like)
    # 2. Keep all parameters including the 'this' parameter (Nim's UFCS handles it)
    # 3. Keep same body

    result = XLangNode(
      kind: xnkFuncDecl,
      funcName: node.extExtMethodName,
      params: node.extExtMethodParams,  # Keep all params, including the 'this' one
      returnType: node.extExtMethodReturnType,
      body: node.extExtMethodBody,
      isAsync: false  # Will be tracked separately if needed
    )

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
