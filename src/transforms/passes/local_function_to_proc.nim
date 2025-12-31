## Local Function Transform
##
## Converts C# local functions (functions defined inside methods) to Nim nested procs.
##
## C# local function:
##   void OuterMethod() {
##     int LocalFunc(int x) {
##       return x * 2;
##     }
##     var result = LocalFunc(5);
##   }
##
## Becomes Nim nested proc:
##   proc outerMethod() =
##     proc localFunc(x: int): int =
##       return x * 2
##     var result = localFunc(5)
##
## Note: C# local functions can capture variables from the enclosing scope,
## and Nim nested procs have the same capability through closure semantics.

import core/xlangtypes
import semantic/semantic_analysis
import options

proc transformLocalFunctionToProc*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform C# local functions into Nim nested procs
  if node.kind != xnkExternal_LocalFunction:
    return node

  # Determine body - use empty block for abstract/interface declarations
  let actualBody = if node.extLocalFuncBody.isNone:
    XLangNode(kind: xnkBlockStmt, blockBody: @[])
  else:
    node.extLocalFuncBody.get

  # Convert to a regular function declaration
  # Nim supports nested procs which behave like C# local functions
  result = XLangNode(
    kind: xnkFuncDecl,
    funcName: node.extLocalFuncName,
    params: node.extLocalFuncParams,
    returnType: node.extLocalFuncReturnType,
    body: actualBody,
    isAsync: false
  )
