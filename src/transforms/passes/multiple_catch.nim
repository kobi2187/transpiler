## Multiple Catch Blocks Transformation
##
## Transforms: try with multiple catch blocks → try with single catch and type checking
## Because Nim only supports single catch block
##
## Example:
## try:
##   risky()
## catch IOException as e:
##   handleIO(e)
## catch SQLException as e:
##   handleSQL(e)
##
## Becomes:
## try:
##   risky()
## except Exception as e:
##   if e is IOException:
##     handleIO(e)
##   elif e is SQLException:
##     handleSQL(e)

import core/xlangtypes
import semantic/semantic_analysis
import options

proc buildIfElifChain(clauses: seq[XLangNode]): XLangNode =
  ## Build if-elif chain from catch clauses
  if clauses.len == 0:
    return XLangNode(kind: xnkBlockStmt, blockBody: @[])

  if clauses.len == 1:
    return clauses[0]

  # Start with first if
  result = clauses[0]

  # Chain the rest as elif (elseBody containing next if)
  var current = result
  for i in 1..<clauses.len:
    current.elseBody = some(clauses[i])
    current = clauses[i]

proc transformMultipleCatch*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform try statements with multiple catch blocks into single catch with type checking
  if node.kind != xnkTryStmt:
    return node

  # If single catch or no catch, no transformation needed
  if node.catchClauses.len <= 1:
    return node

  # Build if-elif chain for type checking
  var ifChain: seq[XLangNode] = @[]

  let unifiedVarName = "e"
  for catchClause in node.catchClauses:
    if catchClause.kind != xnkCatchStmt:
      continue

    # Get exception variable name from original clause (if any)
    let originalVarName = if catchClause.catchVar != none(string): catchClause.catchVar.get else: unifiedVarName

    # Build type check: e is ExceptionType
    let typeCheck = XLangNode(
      kind: xnkCallExpr,
      callee: XLangNode(kind: xnkIdentifier, identName: "is"),
      args: @[
        XLangNode(kind: xnkIdentifier, identName: unifiedVarName),
        if catchClause.catchType != none(XLangNode):
          catchClause.catchType.get
        else:
          XLangNode(kind: xnkNamedType, typeName: "Exception")
      ]
    )

    # Ensure the catch body references the unified var name by binding if needed
    var adjustedBody = catchClause.catchBody
    if originalVarName != unifiedVarName:
      # Build a block that declares originalVarName = unifiedVarName and then executes the original body
      let binder = XLangNode(kind: xnkVarDecl, declName: originalVarName,
                            declType: none(XLangNode),
                            initializer: some(XLangNode(kind: xnkIdentifier, identName: unifiedVarName)))
      adjustedBody = XLangNode(kind: xnkBlockStmt, blockBody: @[binder, catchClause.catchBody])

    ifChain.add(XLangNode(kind: xnkIfStmt, ifCondition: typeCheck, ifBody: adjustedBody, elseBody: none(XLangNode)))

  # Create single catch block with if-elif chain
  let singleCatch = XLangNode(
    kind: xnkCatchStmt,
    catchType: some(XLangNode(kind: xnkNamedType, typeName: "Exception")),
    catchVar: some(unifiedVarName),
    catchBody: buildIfElifChain(ifChain)
  )

  # Return try statement with single catch
  result = XLangNode(
    kind: xnkTryStmt,
    tryBody: node.tryBody,
    catchClauses: @[singleCatch],
    finallyClause: node.finallyClause
  )
