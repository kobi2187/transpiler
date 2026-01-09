## Transformation pass to lower Go's tagless switch to if-elif-else chains
##
## Go tagless switch:
##   switch {
##   case x > 10:
##     // ...
##   case y < 5:
##     // ...
##   default:
##     // ...
##   }
##
## Becomes:
##   if x > 10:
##     // ...
##   elif y < 5:
##     // ...
##   else:
##     // ...

import core/xlangtypes
import transforms/transform_context
import options

proc lowerGoTaglessSwitch*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Convert xnkExternal_GoTaglessSwitch to if-elif-else chain
  if node.kind != xnkExternal_GoTaglessSwitch:
    return node

  # Build an if statement with elif branches
  var ifStmt = XLangNode(kind: xnkIfStmt)
  ifStmt.elifBranches = @[]
  var hasIf = false
  var defaultBody: Option[XLangNode] = none(XLangNode)

  for caseNode in node.extGoTaglessSwitchCases:
    if caseNode.kind == xnkCaseClause:
      # Convert case to if/elif branch
      # For tagless switch, caseValues contains the condition(s)
      let condition = if caseNode.caseValues.len == 1:
        # Recursively transform the condition
        lowerGoTaglessSwitch(caseNode.caseValues[0], ctx)
      elif caseNode.caseValues.len > 1:
        # Multiple conditions: combine with OR
        var orNode = XLangNode(kind: xnkBinaryExpr)
        orNode.binaryOp = opLogicalOr
        orNode.binaryLeft = lowerGoTaglessSwitch(caseNode.caseValues[0], ctx)
        orNode.binaryRight = lowerGoTaglessSwitch(caseNode.caseValues[1], ctx)
        # TODO: handle more than 2 conditions by chaining ORs
        orNode
      else:
        # No condition? Shouldn't happen, but create a true literal
        XLangNode(kind: xnkBoolLit, boolValue: true)

      # Recursively transform the body
      let body = lowerGoTaglessSwitch(caseNode.caseBody, ctx)

      if not hasIf:
        # First case becomes the main if
        ifStmt.ifCondition = condition
        ifStmt.ifBody = body
        hasIf = true
      else:
        # Subsequent cases become elif branches
        ifStmt.elifBranches.add((condition: condition, body: body))

    elif caseNode.kind == xnkDefaultClause:
      # Default case becomes else - recursively transform it
      defaultBody = some(lowerGoTaglessSwitch(caseNode.defaultBody, ctx))

  if hasIf:
    ifStmt.elseBody = defaultBody
    return ifStmt
  elif defaultBody.isSome():
    # Only default case? Just return the body
    return defaultBody.get()
  else:
    # No cases at all? Return empty block
    return XLangNode(kind: xnkBlockStmt, blockBody: @[])

proc transformGoTaglessSwitch*(ast: XLangNode, ctx: TransformContext): XLangNode =
  ## Main entry point for the transformation pass
  result = lowerGoTaglessSwitch(ast, ctx)
