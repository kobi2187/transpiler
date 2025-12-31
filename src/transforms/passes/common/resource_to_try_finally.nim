## Resource to Try-Finally Transformation
##
## Alternative to resource_to_defer for targets without defer support
##
## Transforms resource management statements to try-finally pattern:
##
## Input:
##   using (var f = File.Open("file"))
##   {
##     body
##   }
##
## Output:
##   let f = File.Open("file")
##   try:
##     body
##   finally:
##     f.close()

import core/xlangtypes
import transforms/transform_context
import options

proc transformResourceToTryFinally*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform unified resource statements to try-finally pattern

  if node.kind != xnkExternal_Resource:
    return node

  var stmts: seq[XLangNode] = @[]
  var cleanupCalls: seq[XLangNode] = @[]

  # Process each resource item
  for item in node.extResourceItems:
    let resourceExpr = item.resourceExpr

    # Determine variable name
    var varName = ""
    var varNode: XLangNode

    if item.resourceVar.isSome():
      let resourceVar = item.resourceVar.get

      # Extract variable name based on node type
      case resourceVar.kind
      of xnkIdentifier:
        varName = resourceVar.identName
        varNode = resourceVar
      of xnkVarDecl, xnkLetDecl:
        varName = resourceVar.declName
        varNode = XLangNode(kind: xnkIdentifier, identName: varName)
      else:
        # Fallback: generate a name
        varName = "resource"
        varNode = XLangNode(kind: xnkIdentifier, identName: varName)
    else:
      # No variable binding, create temp
      varName = "resource"
      varNode = XLangNode(kind: xnkIdentifier, identName: varName)

    # 1. Variable declaration: let var = expr (outside try)
    stmts.add(XLangNode(
      kind: xnkLetDecl,
      declName: varName,
      declType: none(XLangNode),
      initializer: some(resourceExpr)
    ))

    # 2. Build cleanup call for finally block
    let cleanupMethod = if item.cleanupHint.isSome(): item.cleanupHint.get else: "close"

    let cleanupCall = XLangNode(
      kind: xnkCallExpr,
      callee: XLangNode(
        kind: xnkMemberAccessExpr,
        memberExpr: varNode,
        memberName: cleanupMethod
      ),
      args: @[]
    )
    cleanupCalls.add(cleanupCall)

  # 3. Build finally block with all cleanup calls
  let finallyBody = XLangNode(
    kind: xnkBlockStmt,
    blockBody: cleanupCalls
  )

  let finallyClause = XLangNode(
    kind: xnkFinallyStmt,
    finallyBody: finallyBody
  )

  # 4. Build try statement
  let tryStmt = XLangNode(
    kind: xnkTryStmt,
    tryBody: node.extResourceBody,
    catchClauses: @[],  # No catch - just try-finally
    finallyClause: some(finallyClause)
  )

  stmts.add(tryStmt)

  # Wrap in block
  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: stmts
  )
