## C-Style For Loop to While Loop Transformation
##
## Transforms: for (init; condition; update) body
## Into:       init; while condition: body; update

import ../../xlangtypes
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

  # Create while loop
  let whileBody = if node.forBody.kind == xnkBlockStmt:
    # Add update to end of existing block
    var bodyStmts = node.forBody.blockBody
    if node.forUpdate.isSome:
      bodyStmts.add(node.forUpdate.get)
    XLangNode(
      kind: xnkBlockStmt,
      blockBody: bodyStmts
    )
  else:
    # Create new block with body and update
    var bodyStmts = @[node.forBody]
    if node.forUpdate.isSome:
      bodyStmts.add(node.forUpdate.get)
    XLangNode(
      kind: xnkBlockStmt,
      blockBody: bodyStmts
    )

  let whileLoop = XLangNode(
    kind: xnkWhileStmt,
    whileCondition: if node.forCondition.isSome:
                      node.forCondition.get
                    else:
                      # No condition means infinite loop
                      XLangNode(kind: xnkBoolLit, literalValue: "true"),
    whileBody: whileBody
  )

  stmts.add(whileLoop)

  # Wrap everything in a block
  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: stmts
  )
