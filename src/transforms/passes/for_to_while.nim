## C-Style For Loop to While Loop Transformation
##
## Transforms: for (init; condition; update) body
## Into:       init; while condition: body; update

import ../../../xlangtypes
import options

proc transformForToWhile*(node: XLangNode): XLangNode =
  ## Transform C-style for loops into while loops
  ## This is needed because Nim doesn't have C-style for loops
  if node.kind != xnkForStmt:
    return node

  # C-style for has: init, condition, update, body
  # Transform to: block containing init, while loop with condition and body+update

  var stmts: seq[XLangNode] = @[]

  # Add initialization statement if present
  if node.forInit.isSome:
    stmts.add(node.forInit.get)

  # Create while loop body and append update increment if present
  var bodyStmts: seq[XLangNode] = @[]
  if node.forBody.isSome:
    if node.forBody.get.kind == xnkBlockStmt:
      bodyStmts = node.forBody.get.blockBody
    else:
      bodyStmts.add(node.forBody.get)
  # forIncrement holds the update expression in our types
  if node.forIncrement.isSome:
    bodyStmts.add(node.forIncrement.get)

  let whileBody = XLangNode(kind: xnkBlockStmt, blockBody: bodyStmts)

  let whileLoop = XLangNode(
    kind: xnkWhileStmt,
    whileCondition: if node.forCond.isSome:
                      node.forCond.get
                    else:
                      # No condition means infinite loop
                      XLangNode(kind: xnkBoolLit, boolValue: true),
    whileBody: whileBody
  )

  stmts.add(whileLoop)

  # Wrap everything in a block
  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: stmts
  )
