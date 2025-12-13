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

import ../../../xlangtypes
import options

proc transformResourceToDefer*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Transform unified resource statements to defer pattern

  if node.kind != xnkResourceStmt:
    return node

  var stmts: seq[XLangNode] = @[]

  # Process each resource item
  for item in node.resourceItems:
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
  if node.resourceBody.kind == xnkBlockStmt:
    for stmt in node.resourceBody.blockBody:
      stmts.add(stmt)
  else:
    stmts.add(node.resourceBody)

  # Wrap in block
  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: stmts
  )


## Legacy support: Transform old xnkWithStmt to xnkResourceStmt
proc migrateWithStmt*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Migrate Python with statements to unified resource management

  if node.kind != xnkWithStmt:
    return node

  var resourceItems: seq[XLangNode] = @[]

  for item in node.items:
    resourceItems.add(XLangNode(
      kind: xnkResourceItem,
      resourceExpr: item.contextExpr,
      resourceVar: item.asExpr,
      cleanupHint: some("close")  # Python context managers use __exit__, map to close
    ))

  result = XLangNode(
    kind: xnkResourceStmt,
    resourceItems: resourceItems,
    resourceBody: node.withBody
  )


## Legacy support: Transform old xnkUsingStmt to xnkResourceStmt
proc migrateUsingStmt*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
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
    kind: xnkResourceStmt,
    resourceItems: @[resourceItem],
    resourceBody: node.usingBody
  )
