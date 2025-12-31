## Unified Resource Management Transformation
##
## Transforms resource management statements to Nim's defer pattern
##
## Handles:
## - Python: with open("file") as f:
## - C#: using (var f = File.Open("file"))
## - Java: try-with-resources
##
## All become:
##   let f = open("file")
##   defer: f.close()
##   # body

import core/xlangtypes
import transforms/transform_context
import options

proc transformResourceToDefer*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform unified resource statements to defer pattern

  if node.kind != xnkExternal_Resource:
    return node

  var stmts: seq[XLangNode] = @[]

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

    # 1. Variable declaration: let var = expr
    stmts.add(XLangNode(
      kind: xnkLetDecl,
      declName: varName,
      declType: none(XLangNode),
      initializer: some(resourceExpr)
    ))

    # 2. Defer cleanup
    # Use cleanup hint if provided, otherwise default to "close"
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

    stmts.add(XLangNode(
      kind: xnkDeferStmt,
      staticBody: cleanupCall
    ))

  # 3. Add body
  if node.extResourceBody.kind == xnkBlockStmt:
    for stmt in node.extResourceBody.blockBody:
      stmts.add(stmt)
  else:
    stmts.add(node.extResourceBody)

  # Wrap in block
  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: stmts
  )


## Legacy support: Transform old xnkWithStmt to xnkResourceStmt
proc migrateWithStmt*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Migrate Python with statements to unified resource management

  if node.kind != xnkExternal_With:
    return node

  var resourceItems: seq[XLangNode] = @[]

  for item in node.extWithItems:
    resourceItems.add(XLangNode(
      kind: xnkResourceItem,
      resourceExpr: item.contextExpr,
      resourceVar: item.asExpr,
      cleanupHint: some("close")  # Python context managers use __exit__, map to close
    ))

  result = XLangNode(
    kind: xnkExternal_Resource,
    extResourceItems: resourceItems,
    extResourceBody: node.extWithBody
  )


## Legacy support: Transform old xnkUsingStmt to xnkResourceStmt
proc migrateUsingStmt*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Migrate C# using statements to unified resource management

  if node.kind != xnkUsingStmt:
    return node

  # C# using has single expression/declaration
  var resourceVar: Option[XLangNode] = none(XLangNode)
  var resourceExpr = node.usingExpr

  # Check if the expression is a variable declaration
  if resourceExpr.kind in {xnkVarDecl, xnkLetDecl}:
    resourceVar = some(resourceExpr)
    if resourceExpr.initializer.isSome():
      resourceExpr = resourceExpr.initializer.get

  let resourceItem = XLangNode(
    kind: xnkResourceItem,
    resourceExpr: resourceExpr,
    resourceVar: resourceVar,
    cleanupHint: some("Dispose")  # C# IDisposable uses Dispose()
  )

  result = XLangNode(
    kind: xnkExternal_Resource,
    extResourceItems: @[resourceItem],
    extResourceBody: node.usingBody
  )
