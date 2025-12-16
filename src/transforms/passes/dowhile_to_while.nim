## Do-While to While Transformation
##
## Transforms: do { body } while (condition)
## Into:       while true: body; if not condition: break

import ../../../xlangtypes
import options

proc transformDoWhileToWhile*(node: XLangNode): XLangNode {.gcsafe.} =
  ## Transform do-while loops into while-true loops with break
  ## This is needed because Nim doesn't have do-while loops
  if node.kind != xnkExternal_DoWhile:
    return node

  # Get the body statements
  var bodyStmts: seq[XLangNode] = @[]
  if node.extDoWhileBody.kind == xnkBlockStmt:
    for s in node.extDoWhileBody.blockBody:
      bodyStmts.add(s)
  else:
    bodyStmts.add(node.extDoWhileBody)

  # Create: if not condition: break
  let breakStmt = XLangNode(
    kind: xnkIfStmt,
    ifCondition: XLangNode(
      kind: xnkUnaryExpr,
      unaryOp: "not",
      unaryOperand: node.extDoWhileCondition
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
