## With Statement to Defer Pattern Transformation
##
## Transforms Python's with statement to Nim's defer pattern
##
## Example:
## with open("file.txt") as f:
##   process(f)
##
## Transforms to:
## let f = open("file.txt")
## defer: f.close()
## process(f)

import ../../xlangtypes
import options
import strutils

proc transformWithToDefer*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Transform with statements to defer pattern
  if node.kind != xnkWithStmt:
    return node

  # Python's with statement:
  # with expr as var:
  #   body
  #
  # Transforms to:
  # let var = expr
  # defer: var.close()  # Assume context manager has close() method
  # body

  var stmts: seq[XLangNode] = @[]

  # Process each with item (Python allows: with a as x, b as y:)
  for item in node.withItems:
    let contextExpr = item.contextExpr

    if item.asExpr.isSome:
      let asExpr = item.asExpr.get

      # Extract variable name
      var varName = ""
      if asExpr.kind == xnkIdentifier:
        varName = asExpr.identName
      else:
        # Fallback: generate a name
        varName = "ctx"

      # 1. Let declaration: let var = contextExpr
      stmts.add(XLangNode(
        kind: xnkLetDecl,
        declName: varName,
        declType: none(XLangNode),
        initializer: some(contextExpr)
      ))

      # 2. Defer statement: defer: var.close()
      # Nim's defer takes a statement to execute on scope exit
      let closeCall = XLangNode(
        kind: xnkCallExpr,
        callee: XLangNode(
          kind: xnkMemberAccessExpr,
          memberExpr: XLangNode(kind: xnkIdentifier, identName: varName),
          memberName: "close"
        ),
        args: @[]
      )

      stmts.add(XLangNode(
        kind: xnkDeferStmt,
        staticBody: closeCall
      ))
    else:
      # No 'as' clause - just evaluate the expression for side effects
      # This is less common but valid in Python: with expr:
      # We still need to ensure cleanup, but without a variable name
      # We'll create a temporary variable

      let tempVar = "ctxTemp"
      stmts.add(XLangNode(
        kind: xnkLetDecl,
        declName: tempVar,
        declType: none(XLangNode),
        initializer: some(contextExpr)
      ))

      let closeCall = XLangNode(
        kind: xnkCallExpr,
        callee: XLangNode(
          kind: xnkMemberAccessExpr,
          memberExpr: XLangNode(kind: xnkIdentifier, identName: tempVar),
          memberName: "close"
        ),
        args: @[]
      )

      stmts.add(XLangNode(
        kind: xnkDeferStmt,
        staticBody: closeCall
      ))

  # 3. Add the body statements
  # If body is a block, unwrap its statements
  if node.withBody.kind == xnkBlockStmt:
    for stmt in node.withBody.blockBody:
      stmts.add(stmt)
  else:
    stmts.add(node.withBody)

  # Wrap everything in a block
  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: stmts
  )
