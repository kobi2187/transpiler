## Switch with Fallthrough Transformation
##
## Transforms: switch with fallthrough → if-elif chain
## Because Nim's case statement doesn't support fallthrough

import core/xlangtypes
import semantic/semantic_analysis
import options

proc mergeBlocks(body1, body2: XLangNode): XLangNode =
  ## Merge two block statements into one
  var stmts: seq[XLangNode] = @[]

  # Add statements from first block
  if body1.kind == xnkBlockStmt:
    stmts.add(body1.blockBody)
  else:
    stmts.add(body1)

  # Add statements from second block
  if body2.kind == xnkBlockStmt:
    stmts.add(body2.blockBody)
  else:
    stmts.add(body2)

  result = XLangNode(kind: xnkBlockStmt, blockBody: stmts)

proc buildOrCondition(switchExpr: XLangNode, values: seq[XLangNode]): XLangNode =
  ## Build: x == val1 or x == val2 or x == val3
  if values.len == 0:
    # Shouldn't happen, but handle it
    return XLangNode(kind: xnkBoolLit, boolValue: false)

  if values.len == 1:
    return XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: opEqual,
      binaryLeft: switchExpr,
      binaryRight: values[0]
    )

  # Build chain of 'or' expressions
  var condition = XLangNode(
    kind: xnkBinaryExpr,
    binaryOp: opEqual,
    binaryLeft: switchExpr,
    binaryRight: values[0]
  )

  for i in 1..<values.len:
    let nextCond = XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: opEqual,
      binaryLeft: switchExpr,
      binaryRight: values[i]
    )

    condition = XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: opLogicalOr,
      binaryLeft: condition,
      binaryRight: nextCond
    )

  result = condition

proc transformSwitchFallthrough*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform switch statements with fallthrough into if-elif chains
  if node.kind != xnkSwitchStmt:
    return node

  # Check if any case has fallthrough
  var hasFallthrough = false
  for caseNode in node.switchCases:
    if caseNode.kind == xnkCaseClause and caseNode.caseFallthrough:
      hasFallthrough = true
      break

  # If no fallthrough, Nim's case can handle it directly
  if not hasFallthrough:
    return node

  # Build if-elif chain
  var ifNodes: seq[XLangNode] = @[]
  var defaultBody: Option[XLangNode] = none(XLangNode)

  # Process each case
  var i = 0
  while i < node.switchCases.len:
    let caseNode = node.switchCases[i]

    if caseNode.kind == xnkDefaultClause:
      defaultBody = some(caseNode.defaultBody)
      i += 1
      continue

    if caseNode.kind != xnkCaseClause:
      i += 1
      continue

    # Build condition for this case
    let condition = buildOrCondition(node.switchExpr, caseNode.caseValues)

    # Collect body - include next case's body if fallthrough
    var body = caseNode.caseBody

    if caseNode.caseFallthrough:
      # Merge with subsequent case bodies until we hit one without fallthrough
      var j = i + 1
      while j < node.switchCases.len:
        let nextCase = node.switchCases[j]
        if nextCase.kind == xnkCaseClause:
          body = mergeBlocks(body, nextCase.caseBody)
          if not nextCase.caseFallthrough:
            break
        j += 1

    # Create if/elif node
    ifNodes.add(XLangNode(
      kind: xnkIfStmt,
      ifCondition: condition,
      ifBody: body,
      elseBody: none(XLangNode)
    ))

    i += 1

  # Build the if-elif-else chain
  if ifNodes.len == 0:
    # Only had default clause?
    return if defaultBody.isSome: defaultBody.get else: node

  # Start with first if
  result = ifNodes[0]

  # Chain the rest as elif (elseBody containing next if)
  var current = result
  for i in 1..<ifNodes.len:
    current.elseBody = some(ifNodes[i])
    current = ifNodes[i]

  # Add default clause as final else
  if defaultBody.isSome:
    current.elseBody = some(defaultBody.get)

  # Wrap in block to ensure it's a statement, not expression
  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: @[result]
  )
