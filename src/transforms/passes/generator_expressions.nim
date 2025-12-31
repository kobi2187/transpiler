## Generator Expression Transform
##
## Converts Python-style generator expressions to Nim iterators or collect patterns.
##
## Examples:
##   Python: (x*2 for x in range(10))
##   →       iterator gen(): int =
##             for x in range(10):
##               yield x * 2
##
##   Python: (x for x in items if x > 5)
##   →       iterator gen(): auto =
##             for x in items:
##               if x > 5:
##                 yield x

import core/xlangtypes
import semantic/semantic_analysis
import options

proc transformGeneratorExpressions*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode {.gcsafe.}

var generatorCounter = 0

proc genGeneratorName(): string =
  ## Generate unique generator iterator name
  result = "gen" & $generatorCounter
  inc generatorCounter

proc buildGeneratorIterator(node: XLangNode): XLangNode =
  ## Convert generator expression to iterator
  ## node is xnkExternal_Generator with extGenExpr, extGenFor, extGenIf

  let iterName = genGeneratorName()

  # Build body with nested for loops and if filters
  var body: XLangNode = XLangNode(
    kind: xnkIteratorYield,
    iteratorYieldValue: some(node.extGenExpr)
  )

  # Wrap in if filters (innermost first)
  for i in countdown(node.extGenIf.len - 1, 0):
    body = XLangNode(
      kind: xnkIfStmt,
      ifCondition: node.extGenIf[i],
      ifBody: XLangNode(
        kind: xnkBlockStmt,
        blockBody: @[body]
      ),
      elseBody: none(XLangNode)
    )

  # Wrap in for loops (outermost last)
  for i in countdown(node.extGenFor.len - 1, 0):
    let forClause = node.extGenFor[i]  # xnkCompFor node
    assert forClause.kind == xnkCompFor

    # Create loop variable(s)
    let loopVar = if forClause.vars.len == 1:
      forClause.vars[0]
    else:
      # Multiple variables - create tuple destructuring
      XLangNode(
        kind: xnkTupleExpr,
        elements: forClause.vars
      )

    body = XLangNode(
      kind: xnkForeachStmt,
      foreachVar: loopVar,
      foreachIter: forClause.iter,
      foreachBody: XLangNode(
        kind: xnkBlockStmt,
        blockBody: @[body]
      )
    )

  # Create iterator declaration
  result = XLangNode(
    kind: xnkIteratorDecl,
    iteratorName: iterName,
    iteratorParams: @[],
    iteratorReturnType: some(XLangNode(
      kind: xnkIdentifier,
      identName: "auto"
    )),
    iteratorBody: XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[body]
    )
  )

proc transformGeneratorExpressionsHelper(node: XLangNode, hoistedIterators: var seq[XLangNode]): XLangNode =
  ## Transform generator expressions, collecting hoisted iterators
  case node.kind
  of xnkExternal_Generator:
    # Convert to iterator and hoist
    let iterNode = buildGeneratorIterator(node)
    hoistedIterators.add(iterNode)

    # Replace with call to iterator
    result = XLangNode(
      kind: xnkCallExpr,
      callee: XLangNode(
        kind: xnkIdentifier,
        identName: iterNode.iteratorName
      ),
      args: @[]
    )

  of xnkFuncDecl, xnkMethodDecl:
    # Handle generators inside function bodies
    var iterators: seq[XLangNode] = @[]
    let transformedBody = transformGeneratorExpressionsHelper(node.body, iterators)

    if iterators.len > 0:
      # Prepend iterator declarations to function body
      var newBodyStmts: seq[XLangNode] = @[]
      for it in iterators:
        newBodyStmts.add(it)

      if transformedBody.kind == xnkBlockStmt:
        for stmt in transformedBody.blockBody:
          newBodyStmts.add(stmt)
      else:
        newBodyStmts.add(transformedBody)

      result = node
      result.body = XLangNode(
        kind: xnkBlockStmt,
        blockBody: newBodyStmts
      )
    else:
      result = node

  of xnkBlockStmt:
    # Transform statements in block
    var iterators: seq[XLangNode] = @[]
    var newStmts: seq[XLangNode] = @[]

    for stmt in node.blockBody:
      let transformed = transformGeneratorExpressionsHelper(stmt, iterators)
      newStmts.add(transformed)

    if iterators.len > 0:
      # Prepend iterators
      result = XLangNode(
        kind: xnkBlockStmt,
        blockBody: iterators & newStmts
      )
    else:
      result = XLangNode(
        kind: xnkBlockStmt,
        blockBody: newStmts
      )

  else:
    result = node

proc transformGeneratorExpressions*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform generator expressions to iterators
  var hoistedIterators: seq[XLangNode] = @[]
  result = transformGeneratorExpressionsHelper(node, hoistedIterators)

  # If there are top-level hoisted iterators, wrap in block
  if hoistedIterators.len > 0:
    result = XLangNode(
      kind: xnkBlockStmt,
      blockBody: hoistedIterators & @[result]
    )
