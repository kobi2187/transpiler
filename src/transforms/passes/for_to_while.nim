## C-Style For Loop to While Loop Transformation
##
## Transforms: for (init; condition; update) body
## Into:       init; while condition: body; update

import core/xlangtypes
import transforms/transform_context
import options

proc transformForToWhile*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform C-style for loops into while loops
  ## This is needed because Nim doesn't have C-style for loops
  if node.kind != xnkExternal_ForStmt:
    return node

  ctx.log("Transforming C-style for loop to while loop")

  # C-style for has: init, condition, update, body
  # Transform to: block containing init, while loop with condition and body+update

  var stmts: seq[XLangNode] = @[]

  # Add initialization statement if present
  if node.extForInit.isSome:
    stmts.add(node.extForInit.get)

  # Create while loop body and append update increment if present
  var bodyStmts: seq[XLangNode] = @[]
  if node.extForBody.isSome:
    if node.extForBody.get.kind == xnkBlockStmt:
      bodyStmts = node.extForBody.get.blockBody
    else:
      bodyStmts.add(node.extForBody.get)
  # extForIncrement holds the update expression in our types
  if node.extForIncrement.isSome:
    bodyStmts.add(node.extForIncrement.get)

  let whileBody = XLangNode(kind: xnkBlockStmt, blockBody: bodyStmts)

  let whileLoop = XLangNode(
    kind: xnkWhileStmt,
    whileCondition: if node.extForCond.isSome:
                      node.extForCond.get
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
