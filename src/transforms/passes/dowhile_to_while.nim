## Do-While to While Transformation
##
## Transforms: do { body } while (condition)
## Into:       while true: body; if not condition: break

import core/xlangtypes
import transforms/transform_context
import options

proc extractAssignmentsFromCondition(cond: XLangNode): tuple[assignments: seq[XLangNode], cleanCondition: XLangNode] =
  ## Extract assignment expressions from a condition
  ## C#: while ((match = match.NextMatch()).Success)
  ## Becomes: assignments=[match = match.NextMatch()], cleanCondition=match.Success

  result.assignments = @[]

  # Check if condition is a member access with an assignment as the base
  if cond.kind == xnkMemberAccessExpr and cond.memberExpr.kind == xnkAsgn:
    # Extract the assignment
    result.assignments.add(cond.memberExpr)
    # Create clean condition using the assigned variable
    result.cleanCondition = XLangNode(
      kind: xnkMemberAccessExpr,
      memberExpr: XLangNode(
        kind: xnkIdentifier,
        identName: cond.memberExpr.asgnLeft.identName  # Use the variable name
      ),
      memberName: cond.memberName
    )
  else:
    # No assignment, use condition as-is
    result.cleanCondition = cond

proc transformDoWhileToWhile*(node: XLangNode, ctx: TransformContext): XLangNode {.gcsafe.} =
  ## Transform do-while loops into while-true loops with break
  ## This is needed because Nim doesn't have do-while loops
  ## Also handles assignments in conditions like: while ((x = foo()).bar)
  if node.kind != xnkExternal_DoWhile:
    return node

  # Extract any assignments from the condition
  let (assignments, cleanCondition) = extractAssignmentsFromCondition(node.extDoWhileCondition)

  # Get the body statements
  var bodyStmts: seq[XLangNode] = @[]
  if node.extDoWhileBody.kind == xnkBlockStmt:
    for s in node.extDoWhileBody.blockBody:
      bodyStmts.add(s)
  else:
    bodyStmts.add(node.extDoWhileBody)

  # Add assignment statements before the break check
  for asgn in assignments:
    bodyStmts.add(asgn)

  # Create: if not condition: break
  let breakStmt = XLangNode(
    kind: xnkIfStmt,
    ifCondition: XLangNode(
      kind: xnkUnaryExpr,
      unaryOp: opNot,
      unaryOperand: cleanCondition
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
