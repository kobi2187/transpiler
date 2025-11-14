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

import ../../xlangtypes
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

proc transformMultipleCatch*(node: XLangNode): XLangNode =
  ## Transform try statements with multiple catch blocks into single catch with type checking
  if node.kind != xnkTryStmt:
    return node

  # If single catch or no catch, no transformation needed
  if node.catchClauses.len <= 1:
    return node

  # Build if-elif chain for type checking
  var ifChain: seq[XLangNode] = @[]

  for catchClause in node.catchClauses:
    if catchClause.kind != xnkCatchStmt:
      continue

    # Get exception variable name (use 'e' as default)
    let varName = if catchClause.catchVar.isSome:
                    catchClause.catchVar.get
                  else:
                    "e"

    # Build type check: e is ExceptionType
    let typeCheck = XLangNode(
      kind: xnkCallExpr,
      callFunc: XLangNode(kind: xnkIdentifier, identName: "is"),
      callArgs: @[
        XLangNode(kind: xnkIdentifier, identName: varName),
        if catchClause.catchType.isSome:
          catchClause.catchType.get
        else:
          XLangNode(kind: xnkNamedType, typeName: "Exception")
      ]
    )

    # Create if statement for this catch
    ifChain.add(XLangNode(
      kind: xnkIfStmt,
      ifCondition: typeCheck,
      ifBody: catchClause.catchBody,
      elseBody: none(XLangNode)
    ))

  # Create single catch block with if-elif chain
  let singleCatch = XLangNode(
    kind: xnkCatchStmt,
    catchType: some(XLangNode(kind: xnkNamedType, typeName: "Exception")),
    catchVar: some("e"),
    catchBody: buildIfElifChain(ifChain)
  )

  # Return try statement with single catch
  result = XLangNode(
    kind: xnkTryStmt,
    tryBody: node.tryBody,
    catchClauses: @[singleCatch],
    finallyClause: node.finallyClause
  )
