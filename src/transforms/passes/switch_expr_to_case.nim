## Switch Expression to Case Transform
##
## Converts C# switch expressions to Nim case expressions.
##
## C# switch expression:
##   x switch {
##     Pattern1 => Result1,
##     Pattern2 => Result2,
##     _ => DefaultResult
##   }
##
## Becomes Nim case expression:
##   case x
##   of Pattern1: Result1
##   of Pattern2: Result2
##   else: DefaultResult

import ../../../xlangtypes
import options

proc transformSwitchExprToCase*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Transform C# switch expressions into Nim case expressions
  if node.kind != xnkExternal_SwitchExpr:
    return node

  # Build case branches
  var branches: seq[XLangNode] = @[]
  var elseBody: Option[XLangNode] = none(XLangNode)

  for arm in node.extSwitchExprArms:
    if arm.kind == xnkSwitchCase:
      # Check if this is the default case (_)
      let isDefault = arm.switchCaseConditions.len > 0 and
                      arm.switchCaseConditions[0].kind == xnkIdentifier and
                      arm.switchCaseConditions[0].identName == "_"

      if isDefault:
        # This is the default/else branch
        elseBody = some(arm.switchCaseBody)
      else:
        # Regular pattern branch
        branches.add(arm)

  # Create case statement/expression
  result = XLangNode(
    kind: xnkCaseStmt,
    expr: some(node.extSwitchExprValue),
    branches: branches,
    caseElseBody: elseBody
  )
