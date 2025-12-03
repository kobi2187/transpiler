## Do-While to While Transformation
##
## Transforms: do { body } while (condition)
## Into:       while true: body; if not condition: break

import ../../xlangtypes
import options

proc transformDoWhileToWhile*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Transform do-while loops into while-true loops with break
  ## This is needed because Nim doesn't have do-while loops
  if node.kind != xnkDoWhileStmt:
    return node

  # Get the body statements
  var bodyStmts: seq[XLangNode] = @[]
  if node.whileBody.kind == xnkBlockStmt:
    for s in node.whileBody.blockBody:
      bodyStmts.add(s)
  else:
    bodyStmts.add(node.whileBody)

  # Create: if not condition: break
  let breakStmt = XLangNode(
    kind: xnkIfStmt,
    ifCondition: XLangNode(
      kind: xnkUnaryExpr,
      unaryOp: "not",
      unaryOperand: node.whileCondition
    ),
    ifBody: XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[XLangNode(kind: xnkBreakStmt)]
    ),
    elseBody: none(XLangNode)
  )

  # Add break statement after body
  bodyStmts.add(breakStmt)

  # Create while true loop
  result = XLangNode(
    kind: xnkWhileStmt,
    whileCondition: XLangNode(kind: xnkBoolLit, boolValue: true),
    whileBody: XLangNode(
      kind: xnkBlockStmt,
      blockBody: bodyStmts
    )
  )
