## Record With Expression Transformation
##
## Transforms C# record with-expressions into block statements that copy and modify.
##
## C# with expression:
##   person with { Age = 31 }
##
## Becomes:
##   block:
##     var __withResult = person
##     __withResult.Age = 31
##     __withResult
##
## This creates a modified copy of the record without mutating the original.

import core/xlangtypes
import transforms/transform_context
import options

var withCounter {.global.}: int = 0

proc generateWithTempName(): string =
  ## Generate a unique temp variable name for with expressions
  inc withCounter
  "__withResult" & $withCounter

proc transformRecordWithToBlock*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform C# record with-expression into a block that copies and modifies
  if node.kind != xnkExternal_RecordWith:
    return node

  let tempName = generateWithTempName()
  var bodyStmts: seq[XLangNode] = @[]

  # 1. Create temp variable initialized with copy of source expression
  # var __withResult = sourceExpr
  let tempDecl = XLangNode(
    kind: xnkVarDecl,
    declName: tempName,
    declType: some(XLangNode(kind: xnkNamedType, typeName: "auto")),
    initializer: some(node.extWithExpression)
  )
  bodyStmts.add(tempDecl)

  # 2. Apply each modification from the initializer
  # The initializer is typically a SequenceLiteral containing assignments
  if node.extWithInitializer != nil and node.extWithInitializer.kind == xnkSequenceLiteral:
    for elem in node.extWithInitializer.elements:
      if elem.kind == xnkAsgn:
        # Convert field assignment to: __withResult.field = value
        let fieldAssign = XLangNode(
          kind: xnkAsgn,
          asgnLeft: XLangNode(
            kind: xnkMemberAccessExpr,
            memberExpr: XLangNode(kind: xnkIdentifier, identName: tempName),
            memberName: if elem.asgnLeft.kind == xnkIdentifier: elem.asgnLeft.identName else: "unknown"
          ),
          asgnRight: elem.asgnRight
        )
        bodyStmts.add(fieldAssign)
      elif elem.kind == xnkMemberAccessExpr:
        # Handle case where it's already a member access with implicit assignment
        bodyStmts.add(elem)

  # 3. Add the temp variable as the final expression (result of block)
  bodyStmts.add(XLangNode(kind: xnkIdentifier, identName: tempName))

  # Create the block statement (acts as block expression in Nim with final value)
  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: bodyStmts
  )

  # Register the new node tree
  ctx.registerNodeTree(result, node.parentId)
