## Do-While to While Transformation
##
## Transforms: do { body } while (condition)
## Into:       while true: body; if not condition: break

import ../../xlangtypes
import options

proc transformDoWhileToWhile*(node: XLangNode): XLangNode =
  ## Transform do-while loops into while-true loops with break
  ## This is needed because Nim doesn't have do-while loops
  if node.kind != xnkDoWhileStmt:
    return node

  # Get the body statements
  var bodyStmts = if node.doWhileBody.kind == xnkBlockStmt:
    node.doWhileBody.blockBody
  else:
    @[node.doWhileBody]

  # Create: if not condition: break
  let breakStmt = XLangNode(
    kind: xnkIfStmt,
    ifCondition: XLangNode(
      kind: xnkUnaryExpr,
      unaryOp: "not",
      unaryOperand: node.doWhileCondition
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
    whileCondition: XLangNode(kind: xnkBoolLit, literalValue: "true"),
    whileBody: XLangNode(
      kind: xnkBlockStmt,
      blockBody: bodyStmts
    )
  )
