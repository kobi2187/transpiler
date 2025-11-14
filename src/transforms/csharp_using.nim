## C# Using Statement Transformation
##
## Transforms C#'s using statement (IDisposable pattern) to Nim's defer
##
## C#:
##   using (var file = File.Open("data.txt"))
##   {
##     // use file
##   }  // file.Dispose() called automatically
##
## Nim:
##   let file = open("data.txt")
##   defer: file.close()
##   # use file

import ../../xlangtypes
import options

proc transformCSharpUsing*(node: XLangNode): XLangNode =
  ## Transform C# using statements to Nim defer pattern
  ##
  ## C# using ensures Dispose() is called on IDisposable objects
  ## Nim doesn't have IDisposable, but uses similar patterns with defer and destructors

  if node.kind != xnkUsingStmt:
    return node

  # C# using statement:
  # using (Type var = expr) { body }
  # or
  # using var = expr; (C# 8.0+)

  # Extract the variable declaration and body
  let usingExpr = node.usingExpr
  let usingBody = node.usingBody

  # Determine variable name and initialization
  var varName = ""
  var initExpr: Option[XLangNode] = none(XLangNode)
  var varDecl: Option[XLangNode] = none(XLangNode)

  if usingExpr.kind == xnkVarDecl or usingExpr.kind == xnkLetDecl:
    # using (var file = ...)
    varName = usingExpr.declName
    initExpr = usingExpr.initializer
    varDecl = some(usingExpr)
  elif usingExpr.kind == xnkIdentifier:
    # using (existingVar)
    varName = usingExpr.identName
    # No initialization, variable already exists
  else:
    # using (expression) - create temp variable
    varName = "usingTemp"
    initExpr = some(usingExpr)

  # Build transformation:
  # let var = expr
  # defer: var.close() or var.dispose()
  # body

  var stmts: seq[XLangNode] = @[]

  # 1. Variable declaration (if needed)
  if varDecl.isSome:
    stmts.add(varDecl.get)
  elif initExpr.isSome:
    stmts.add(XLangNode(
      kind: xnkLetDecl,
      declName: varName,
      declType: none(XLangNode),
      initializer: initExpr
    ))

  # 2. Defer statement for cleanup
  # C# calls Dispose(), Nim typically calls close()
  # We'll generate both patterns and let the Nim converter choose

  let disposeCall = XLangNode(
    kind: xnkCallExpr,
    callee: XLangNode(
      kind: xnkMemberAccessExpr,
      memberExpr: XLangNode(kind: xnkIdentifier, identName: varName),
      memberName: "close"  # or "dispose" - could be configurable
    ),
    args: @[]
  )

  stmts.add(XLangNode(
    kind: xnkDeferStmt,
    staticBody: disposeCall
  ))

  # 3. Body statements
  if usingBody.kind == xnkBlockStmt:
    stmts.add(usingBody.blockBody)
  else:
    stmts.add(usingBody)

  # Wrap in block
  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: stmts
  )

# C# 8.0+ using declarations (simplified syntax):
# using var file = File.Open("data.txt");
# // use file
# // Dispose() called at end of scope
#
# This is even closer to Nim's defer pattern

proc transformCSharpUsingDeclaration*(node: XLangNode): XLangNode =
  ## Transform C# 8.0+ using declarations
  ## These are variable declarations with automatic disposal

  if node.kind notin {xnkVarDecl, xnkLetDecl}:
    return node

  # Check if this is a using declaration
  # Would need metadata flag in XLang AST to detect this
  # For now, this is a placeholder

  result = node

# Note: C# using can also be used for namespace imports:
# using System.Collections.Generic;
#
# This is different from IDisposable using and should be handled
# by import transformation, not this pass
