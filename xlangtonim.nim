import xlangtypes
import src/helpers
import options, strutils
import src/my_nim_node

# Track warnings for unsupported constructs
type TranspileWarning* = object
  kind*: XLangNodeKind
  message*: string
  location*: string  # Could be file:line if available

var transpileWarnings*: seq[TranspileWarning] = @[]

proc addWarning(kind: XLangNodeKind, msg: string, loc: string = "") =
  transpileWarnings.add(TranspileWarning(kind: kind, message: msg, location: loc))

proc clearWarnings*() =
  transpileWarnings.setLen(0)

# Serialize node to a deterministic string representation for structural comparison.
proc serializeXLangNode*(node: XLangNode): string =
  if node == nil:
    return "nil"
  var sbParts: seq[string] = @[]
  sbParts.add($node.kind)
  case node.kind
  of xnkIdentifier:
    sbParts.add(":" & node.identName)
  of xnkStringLit:
    sbParts.add(":" & node.literalValue)
  of xnkIntLit:
    sbParts.add(":" & node.literalValue)
  of xnkFloatLit:
    sbParts.add(":" & node.literalValue)
  of xnkBoolLit:
    sbParts.add(":" & $node.boolValue)
  of xnkCharLit:
    sbParts.add(":" & node.literalValue)
  of xnkNamedType:
    sbParts.add(":" & node.typeName)
  of xnkUnionType:
    sbParts.add(":[")
    var unionParts: seq[string] = @[]
    for t in node.unionTypes:
      unionParts.add(serializeXLangNode(t))
    sbParts.add(unionParts.join(","))
    sbParts.add("]")
  of xnkMemberAccessExpr:
    sbParts.add(":(base=" & serializeXLangNode(node.memberExpr) & ",mem=" & node.memberName & ")")
  of xnkBlockStmt:
    sbParts.add(":{")
    var stmtParts: seq[string] = @[]
    for s in node.blockBody:
      stmtParts.add(serializeXLangNode(s))
    sbParts.add(stmtParts.join(","))
    sbParts.add("}")
  of xnkIfStmt:
    sbParts.add(":(cond=" & serializeXLangNode(node.ifCondition) & ",then=" & serializeXLangNode(node.ifBody))
    if node.elseBody.isSome:
      sbParts.add(",else=" & serializeXLangNode(node.elseBody.get))
    sbParts.add(")")
  of xnkCallExpr:
    sbParts.add(":(callee=" & serializeXLangNode(node.callee) & ",args=[")
    var argsOut: seq[string] = @[]
    for a in node.args:
      argsOut.add(serializeXLangNode(a))
    sbParts.add(argsOut.join(","))
    sbParts.add("])")
  of xnkVarDecl:
    sbParts.add(":name=" & node.declName)
    if node.initializer.isSome:
      sbParts.add(":init=" & serializeXLangNode(node.initializer.get))
  of xnkReturnStmt:
    if node.returnExpr.isSome:
      sbParts.add(":ret=" & serializeXLangNode(node.returnExpr.get))
  else:
    # fallback: serialize child nodes obtained via getChildren
    var children = getChildren(node)
    if children.len > 0:
      sbParts.add(":[")
      var childParts: seq[string] = @[]
      for c in children:
        childParts.add(serializeXLangNode(c))
      sbParts.add(childParts.join(","))
      sbParts.add("]")
  return sbParts.join("")

# Public structural equality function using the deterministic serializer.
proc nodesEqual*(a, b: XLangNode): bool =
  if a.isNil and b.isNil:
    return true
  if a == nil or b == nil:
    return false
  return serializeXLangNode(a) == serializeXLangNode(b)



# Forward declaration for mutual recursion (helpers call this)
proc convertToNimAST*(node: XLangNode): MyNimNode

# Helper procs for each XLang node kind — extract case logic here
proc conv_xnkFile(node: XLangNode): MyNimNode =
  result = newStmtList()
  for decl in node.moduleDecls:
    result.add(convertToNimAST(decl))

proc conv_xnkModule(node: XLangNode): MyNimNode =
  # Nim doesn't have a direct equivalent to Java's module system
  # We'll create a comment node to preserve the information
  result = newCommentStmtNode("Module: " & node.moduleName)
  for stmt in node.moduleBody:
    result.add(convertToNimAST(stmt))

proc conv_xnkNamespace(node: XLangNode): MyNimNode =
  result = newCommentStmtNode("Namespace: " & node.namespaceName)
  for stmt in node.namespaceBody:
    result.add(convertToNimAST(stmt))

proc conv_xnkFuncDecl_method(node: XLangNode): MyNimNode =
  # Build a proc/method node using my_nim_node API
  let kind = if node.kind == xnkFuncDecl: nnkProcDef else: nnkMethodDef
  result = newNimNode(kind)
  # 0: name
  result.add(newIdentNode(node.funcName))
  # 1: pattern/term rewriting placeholder
  result.add(newEmptyNode())
  # 2: generic params placeholder
  result.add(newEmptyNode())
  # 3: formal params
  let formalParams = newNimNode(nnkFormalParams)
  if node.returnType.isSome():
    formalParams.add(convertToNimAST(node.returnType.get))
  else:
    formalParams.add(newEmptyNode())
  for param in node.params:
    formalParams.add(convertToNimAST(param))
  result.add(formalParams)
  # 4: pragmas
  result.add(newEmptyNode())
  # 5: reserved
  result.add(newEmptyNode())
  # 6: body
  result.add(convertToNimAST(node.body))
  if node.isAsync:
    setPragma(result, newPragma(newIdentNode("async")))

proc conv_xnkClassDecl_structDecl(node: XLangNode): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let typeDef = newNimNode(nnkTypeDef)
  typeDef.add(newIdentNode(node.typeNameDecl))
  typeDef.add(newEmptyNode())
  let refTy = newNimNode(nnkRefTy)
  let objType = newNimNode(nnkObjectTy)
  objType.add(newEmptyNode()) # no pragmas
  # base types / inheritance
  let inheritList = newNimNode(nnkOfInherit)
  for baseType in node.baseTypes:
    inheritList.add(convertToNimAST(baseType))
  objType.add(inheritList)
  # members
  let recList = newNimNode(nnkRecList)
  for member in node.members:
    recList.add(convertToNimAST(member))
  objType.add(recList)
  refTy.add(objType)
  typeDef.add(refTy)
  result.add(typeDef)

proc conv_xnkInterfaceDecl(node: XLangNode): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let conceptDef = newNimNode(nnkTypeDef)
  conceptDef.add(newIdentNode(node.typeNameDecl))
  conceptDef.add(newEmptyNode())
  let conceptTy = newNimNode(nnkObjectTy)
  for meth in node.members:
    conceptTy.add(convertToNimAST(meth))
  conceptDef.add(conceptTy)
  result.add(conceptDef)

proc conv_xnkEnumDecl(node: XLangNode): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let enumTy = newNimNode(nnkEnumTy)
  enumTy.add(newEmptyNode())
  for member in node.enumMembers:
    if member.enumMemberValue.isSome():
      let field = newNimNode(nnkEnumFieldDef)
      field.add(newIdentNode(member.enumMemberName))
      field.add(convertToNimAST(member.enumMemberValue.get))
      enumTy.add(field)
    else:
      enumTy.add(newIdentNode(member.enumMemberName))
  let typeDef = newNimNode(nnkTypeDef)
  typeDef.add(newIdentNode(node.enumName))
  typeDef.add(newEmptyNode())
  typeDef.add(enumTy)
  result.add(typeDef)

proc conv_xnkVarLetConst(node: XLangNode): MyNimNode =
  let kind = if node.kind == xnkVarDecl: nnkVarSection elif node.kind == xnkLetDecl: nnkLetSection else: nnkConstSection
  result = newNimNode(kind)
  let identDefs = newNimNode(nnkIdentDefs)
  identDefs.add(newIdentNode(node.declName))
  if node.declType.isSome():
    identDefs.add(convertToNimAST(node.declType.get))
  else:
    identDefs.add(newEmptyNode())
  if node.initializer.isSome():
    identDefs.add(convertToNimAST(node.initializer.get))
  else:
    identDefs.add(newEmptyNode())
  result.add(identDefs)

proc conv_xnkIfStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkIfStmt)
  let branchNode = newNimNode(nnkElifBranch)
  branchNode.add(convertToNimAST(node.ifCondition))
  branchNode.add(convertToNimAST(node.ifBody))
  result.add(branchNode)
  if node.elseBody.isSome():
    let elseNode = newNimNode(nnkElse)
    elseNode.add(convertToNimAST(node.elseBody.get))
    result.add(elseNode)

proc conv_xnkWhileStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkWhileStmt)
  result.add(convertToNimAST(node.whileCondition))
  result.add(convertToNimAST(node.whileBody))

proc conv_xnkForStmt(node: XLangNode): MyNimNode =
  # Handle C-style or for-in style
  if node.forInit.isSome() and node.forCond.isSome() and node.forIncrement.isSome():
    result = newStmtList()
    result.add(convertToNimAST(node.forInit.get))
    let whileStmt = newNimNode(nnkWhileStmt)
    whileStmt.add(convertToNimAST(node.forCond.get))
    let body = newStmtList()
    body.add(convertToNimAST(node.forBody.get))
    body.add(convertToNimAST(node.forIncrement.get))
    whileStmt.add(body)
    result.add(whileStmt)
  else:
    # fallback: map to a simple for stmt if a foreach-like structure exists
    result = newNimNode(nnkForStmt)
    if node.forBody.isSome():
      result.add(convertToNimAST(node.forBody.get))
    else:
      result.add(newEmptyNode())

proc conv_xnkBlockStmt(node: XLangNode): MyNimNode =
  # xlangtypes: blockBody is a seq[XLangNode]
  let body = newStmtList()
  for stmt in node.blockBody:
    body.add(convertToNimAST(stmt))
  result = newBlockStmt(newEmptyNode(), body)

# Patch member access and index kinds to xlangtypes style
proc conv_xnkMemberAccess(node: XLangNode): MyNimNode =
  result = newNimNode(nnkDotExpr)
  result.add(convertToNimAST(node.memberExpr))
  result.add(newIdentNode(node.memberName))

proc conv_xnkIndexExpr(node: XLangNode): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  result.add(convertToNimAST(node.indexExpr))
  for arg in node.indexArgs:
    result.add(convertToNimAST(arg))

proc conv_xnkReturnStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkReturnStmt)
  if node.returnExpr.isSome:
    result.add(convertToNimAST(node.returnExpr.get))
  else:
    result.add(newEmptyNode())

proc conv_xnkYieldStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkYieldStmt)
  if node.yieldExpr.isSome:
    result.add(convertToNimAST(node.yieldExpr.get))
  else:
    result.add(newEmptyNode())

proc conv_xnkDiscardStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkDiscardStmt)
  if node.discardExpr.isSome:
    result.add(convertToNimAST(node.discardExpr.get))
  else:
    result.add(newEmptyNode())

proc conv_xnkCaseStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkCaseStmt)
  if node.expr.isSome():
    result.add(convertToNimAST(node.expr.get))
  else:
    result.add(newEmptyNode())
  for branch in node.branches:
    let ofBranch = newNimNode(nnkOfBranch)
    for cond in branch.caseValues:
      ofBranch.add(convertToNimAST(cond))
    ofBranch.add(convertToNimAST(branch.caseBody))
    result.add(ofBranch)
  if node.elseBody.isSome:
    let elseBranch = newNimNode(nnkElse)
    elseBranch.add(convertToNimAST(node.elseBody.get))
    result.add(elseBranch)

proc conv_xnkTryStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkTryStmt)
  result.add(convertToNimAST(node.tryBody))
  for exceptt in node.catchClauses:
    let exceptBranch = newNimNode(nnkExceptBranch)
    if exceptt.catchType.isSome:
      exceptBranch.add(convertToNimAST(exceptt.catchType.get))
    exceptBranch.add(convertToNimAST(exceptt.catchBody))
    result.add(exceptBranch)
  if node.finallyClause.isSome:
    let finallyBranch = newNimNode(nnkFinally)
    finallyBranch.add(convertToNimAST(node.finallyClause.get))
    result.add(finallyBranch)

proc conv_xnkRaiseStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkRaiseStmt)
  if node.raiseExpr.isSome:
    result.add(convertToNimAST(node.raiseExpr.get))
  else:
    result.add(newEmptyNode())

proc conv_xnkTypeDecl(node: XLangNode): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let typeDef = newNimNode(nnkTypeDef)
  typeDef.add(newIdentNode(node.typeDefName))
  typeDef.add(newEmptyNode())
  typeDef.add(convertToNimAST(node.typeDefBody))
  result.add(typeDef)

proc conv_xnkImportStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkImportStmt)
  for item in node.imports:
    result.add(newIdentNode(item))

proc conv_xnkImport(node: XLangNode): MyNimNode =
  result = newNimNode(nnkImportStmt)
  result.add(newIdentNode(node.importPath))
  if node.importAlias.isSome:
    result.add(newIdentNode("as"))
    result.add(newIdentNode(node.importAlias.get))

proc conv_xnkExport(node: XLangNode): MyNimNode =
  result = newNimNode(nnkExportStmt)
  result.add(convertToNimAST(node.exportedDecl))

proc conv_xnkExportStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkExportStmt)
  for item in node.exports:
    result.add(newIdentNode(item))

proc conv_xnkFromImportStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkFromStmt)
  result.add(newIdentNode(node.module))
  let importList = newNimNode(nnkImportStmt)
  for item in node.fromImports:
    importList.add(newIdentNode(item))
  result.add(importList)

proc conv_xnkGenericParameter(node: XLangNode): MyNimNode =
  result = newNimNode(nnkGenericParams)
  let identDefs = newNimNode(nnkIdentDefs)
  identDefs.add(newIdentNode(node.genericParamName))
  if node.bounds.len > 0:
    for bound in node.bounds:
      identDefs.add(convertToNimAST(bound))
  else:
    identDefs.add(newEmptyNode())
  identDefs.add(newEmptyNode())
  result.add(identDefs)

proc conv_xnkIdentifier(node: XLangNode): MyNimNode =
  result = newIdentNode(node.identName)

proc conv_xnkComment(node: XLangNode): MyNimNode =
  if node.isDocComment:
    result = newCommentStmtNode("## " & node.commentText)
  else:
    result = newCommentStmtNode("# " & node.commentText)

proc conv_xnkIntLit(node: XLangNode): MyNimNode =
  # Parse integer literal value and create integer literal node
  result = newIntLitNode(parseInt(node.literalValue))

proc conv_xnkFloatLit(node: XLangNode): MyNimNode =
  result = newFloatLitNode(parseFloat(node.literalValue))

proc conv_xnkStringLit(node: XLangNode): MyNimNode =
  result = newStrLitNode(node.literalValue)

proc conv_xnkCharLit(node: XLangNode): MyNimNode =
  if node.literalValue.len > 0:
    result = newCharNode(node.literalValue[0])
  else:
    result = newCharNode('\0')

proc conv_xnkBoolLit(node: XLangNode): MyNimNode =
  result = newIdentNode(if node.boolValue: "true" else: "false")

proc conv_xnkNilLit(node: XLangNode): MyNimNode =
  result = newNilLit()

proc conv_xnkTemplateMacro(node: XLangNode): MyNimNode =
  result = if node.kind == xnkTemplateDef: newNimNode(nnkTemplateDef) else: newNimNode(nnkMacroDef)
  result.add(newIdentNode(node.name))
  result.add(newEmptyNode())
  result.add(newEmptyNode())
  let formalParams = newNimNode(nnkFormalParams)
  formalParams.add(newEmptyNode())
  for param in node.tplparams:
    formalParams.add(convertToNimAST(param))
  result.add(formalParams)
  result.add(newEmptyNode())
  result.add(newEmptyNode())
  result.add(convertToNimAST(node.tmplbody))
  if node.isExported:
    let postfix = newNimNode(nnkPostfix)
    postfix.add(newIdentNode("*"))
    postfix.add(result)
    result = postfix

proc conv_xnkPragma(node: XLangNode): MyNimNode =
  result = newNimNode(nnkPragma)
  for pragma in node.pragmas:
    result.add(convertToNimAST(pragma))

proc conv_xnkStaticStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkStaticStmt)
  result.add(convertToNimAST(node.staticBody))

proc conv_xnkDeferStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkDefer)
  result.add(convertToNimAST(node.staticBody))

proc conv_xnkAsmStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkAsmStmt)
  result.add(newStrLitNode(node.asmCode))

proc conv_xnkDistinctTypeDef(node: XLangNode): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let typeDef = newNimNode(nnkTypeDef)
  typeDef.add(newIdentNode(node.distinctName))
  typeDef.add(newEmptyNode())
  let distinctTy = newNimNode(nnkDistinctTy)
  distinctTy.add(convertToNimAST(node.baseType))
  typeDef.add(distinctTy)
  result.add(typeDef)

proc conv_xnkConceptDef(node: XLangNode): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let typeDef = newNimNode(nnkTypeDef)
  typeDef.add(newIdentNode(node.conceptName))
  typeDef.add(newEmptyNode())
  let conceptTy = newNimNode(nnkObjectTy)
  conceptTy.add(newEmptyNode())
  conceptTy.add(convertToNimAST(node.conceptBody))
  typeDef.add(conceptTy)
  result.add(typeDef)

proc conv_xnkMixinStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkMixinStmt)
  for name in node.mixinNames:
    result.add(newIdentNode(name))

proc conv_xnkBindStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkBindStmt)
  for name in node.bindNames:
    result.add(newIdentNode(name))

proc conv_xnkTupleConstr(node: XLangNode): MyNimNode =
  result = newNimNode(nnkTupleConstr)
  for elem in node.tupleElements:
    result.add(convertToNimAST(elem))

proc conv_xnkTupleUnpacking(node: XLangNode): MyNimNode =
  result = newNimNode(nnkVarTuple)
  for target in node.unpackTargets:
    result.add(convertToNimAST(target))
  result.add(newEmptyNode())
  result.add(convertToNimAST(node.unpackExpr))

proc conv_xnkUsingStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkUsingStmt)
  result.add(convertToNimAST(node.usingExpr))
  result.add(convertToNimAST(node.usingBody))


proc conv_xnkCallExpr(node: XLangNode): MyNimNode =
  result = newNimNode(nnkCall)
  result.add(convertToNimAST(node.callee))
  for arg in node.args:
    result.add(convertToNimAST(arg))

proc conv_xnkDotExpr(node: XLangNode): MyNimNode =
  result = newNimNode(nnkDotExpr)
  result.add(convertToNimAST(node.dotBase))
  result.add(convertToNimAST(node.member))

proc conv_xnkBracketExpr(node: XLangNode): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  result.add(convertToNimAST(node.base))
  result.add(convertToNimAST(node.index))


proc conv_xnkBinaryExpr(node: XLangNode): MyNimNode =
  result = newNimNode(nnkInfix)
  result.add(convertToNimAST(node.binaryLeft))
  result.add(newIdentNode(node.binaryOp))
  result.add(convertToNimAST(node.binaryRight))

proc conv_xnkUnaryExpr(node: XLangNode): MyNimNode =
  result = newNimNode(nnkPrefix)
  result.add(newIdentNode(node.unaryOp))
  result.add(convertToNimAST(node.unaryOperand))


# === ADDITIONAL CONVERTER IMPLEMENTATIONS ===

# Constructs that should have been lowered by transforms - assert if we see them
template assertLowered(kind: string): MyNimNode =
  doAssert(false, kind & " should have been lowered by transform passes")
  newNimNode(nnkDiscardStmt)

# Constructs mapped but not yet implemented - return discard with comment
template notYetImpl(kind: string): MyNimNode =
  var n = newNimNode(nnkCommentStmt)
  n.strVal = "TODO: Implement " & kind
  n

# These constructs should have been lowered by transform passes:
# - xnkPropertyDecl → property_to_procs.nim
# - xnkEventDecl → csharp_events.nim
# - xnkDoWhileStmt → dowhile_to_while.nim
# - xnkTernaryExpr → ternary_to_if.nim
# - xnkWithStmt, xnkWithItem → with_to_defer.nim
# - xnkStringInterpolation → string_interpolation.nim
# - xnkNullCoalesceExpr, xnkSafeNavigationExpr → null_coalesce.nim
# - xnkComprehensionExpr → list_comprehension.nim
# - xnkDestructureObj, xnkDestructureArray → destructuring.nim
# - xnkYieldFromStmt → python_generators.nim
# - xnkConditionalAccessExpr → null_coalesce.nim
# - xnkUnionType → union_to_variant.nim
proc conv_xnkPropertyDecl(node: XLangNode): MyNimNode = assertLowered("xnkPropertyDecl")
proc conv_xnkEventDecl(node: XLangNode): MyNimNode = assertLowered("xnkEventDecl")
proc conv_xnkDoWhileStmt(node: XLangNode): MyNimNode = assertLowered("xnkDoWhileStmt")
proc conv_xnkTernaryExpr(node: XLangNode): MyNimNode = assertLowered("xnkTernaryExpr")
proc conv_xnkWithStmt(node: XLangNode): MyNimNode = assertLowered("xnkWithStmt")
proc conv_xnkWithItem(node: XLangNode): MyNimNode = assertLowered("xnkWithItem")
proc conv_xnkStringInterpolation(node: XLangNode): MyNimNode = assertLowered("xnkStringInterpolation")
proc conv_xnkNullCoalesceExpr(node: XLangNode): MyNimNode = assertLowered("xnkNullCoalesceExpr")
proc conv_xnkSafeNavigationExpr(node: XLangNode): MyNimNode = assertLowered("xnkSafeNavigationExpr")
proc conv_xnkComprehensionExpr(node: XLangNode): MyNimNode = assertLowered("xnkComprehensionExpr")
proc conv_xnkDestructureObj(node: XLangNode): MyNimNode = assertLowered("xnkDestructureObj")
proc conv_xnkDestructureArray(node: XLangNode): MyNimNode = assertLowered("xnkDestructureArray")
proc conv_xnkYieldFromStmt(node: XLangNode): MyNimNode = assertLowered("xnkYieldFromStmt")
proc conv_xnkConditionalAccessExpr(node: XLangNode): MyNimNode = assertLowered("xnkConditionalAccessExpr")

# ==== SIMPLE DIRECT MAPPINGS ====

## C#: `this.x`
## Nim: `self.x`
proc conv_xnkThisExpr(node: XLangNode): MyNimNode =
  newIdentNode("self")

## C#: `break;`
## Nim: `break`
proc conv_xnkBreakStmt(node: XLangNode): MyNimNode =
  newNimNode(nnkBreakStmt)

## C#: `continue;`
## Nim: `continue`
proc conv_xnkContinueStmt(node: XLangNode): MyNimNode =
  newNimNode(nnkContinueStmt)

## C#: `;` or empty statement
## Nim: (empty node)
proc conv_xnkEmptyStmt(node: XLangNode): MyNimNode =
  newNimNode(nnkEmpty)

## Python: `pass`
## Nim: `discard`
proc conv_xnkPassStmt(node: XLangNode): MyNimNode =
  newNimNode(nnkDiscardStmt)

## Python: `None` or C#: `null`
## Nim: `nil`
proc conv_xnkNoneLit(node: XLangNode): MyNimNode =
  newIdentNode("nil")

## C#: `[Attribute]` (discarded - Nim uses pragmas differently)
## Nim: (discarded)
proc conv_xnkAttribute(node: XLangNode): MyNimNode =
  newNimNode(nnkDiscardStmt)

## C#: `abstract void Foo();` (no body in Nim)
## Nim: (discarded - interface handles this)
proc conv_xnkAbstractDecl(node: XLangNode): MyNimNode =
  newNimNode(nnkDiscardStmt)

proc conv_xnkAbstractType(node: XLangNode): MyNimNode =
  newNimNode(nnkDiscardStmt)

## Metadata/annotations
## Nim: (discarded)
proc conv_xnkMetadata(node: XLangNode): MyNimNode =
  newNimNode(nnkDiscardStmt)

## Unknown constructs
## Nim: `discard`
proc conv_xnkUnknown(node: XLangNode): MyNimNode =
  newNimNode(nnkDiscardStmt)

# ==== DECLARATIONS NEEDING IMPLEMENTATION ====

proc conv_xnkIteratorDecl(node: XLangNode): MyNimNode = notYetImpl("xnkIteratorDecl")

## C#: `int x;` or `private int x = 5;`
## Nim: `var x: int` or `var x: int = 5`
proc conv_xnkFieldDecl(node: XLangNode): MyNimNode =
  result = newNimNode(nnkIdentDefs)
  result.add(newIdentNode(node.fieldName))
  result.add(convertToNimAST(node.fieldType))
  if node.fieldInitializer.isSome():
    result.add(convertToNimAST(node.fieldInitializer.get))
  else:
    result.add(newEmptyNode())
## C#: `MyClass() { }` → Constructor
## Nim: `proc initMyClass(): MyClass =`
proc conv_xnkConstructorDecl(node: XLangNode): MyNimNode = notYetImpl("xnkConstructorDecl")

## C#: `~MyClass()` → Destructor (Nim has no destructors)
## Nim: (discarded or use destructor hooks)
proc conv_xnkDestructorDecl(node: XLangNode): MyNimNode =
  newNimNode(nnkDiscardStmt)

## C#: `delegate void D(int x);`
## Nim: `type D = proc(x: int)`
proc conv_xnkDelegateDecl(node: XLangNode): MyNimNode = notYetImpl("xnkDelegateDecl")

## C#: `int this[int i] { get; }`
## Nim: proc getItem or `[]` operator
proc conv_xnkIndexerDecl(node: XLangNode): MyNimNode = notYetImpl("xnkIndexerDecl")

## C#: `static T operator+(T a, T b)`
## Nim: ``proc `+`(a, b: T): T``
proc conv_xnkOperatorDecl(node: XLangNode): MyNimNode = notYetImpl("xnkOperatorDecl")

proc conv_xnkConversionOperatorDecl(node: XLangNode): MyNimNode = notYetImpl("xnkConversionOperatorDecl")
proc conv_xnkEnumMember(node: XLangNode): MyNimNode = notYetImpl("xnkEnumMember")

## C: `extern void foo(int x);`
## Nim: `proc foo(x: cint) {.importc.}`
proc conv_xnkCFuncDecl(node: XLangNode): MyNimNode = notYetImpl("xnkCFuncDecl")

proc conv_xnkExternalVar(node: XLangNode): MyNimNode = notYetImpl("xnkExternalVar")
proc conv_xnkLibDecl(node: XLangNode): MyNimNode = notYetImpl("xnkLibDecl")

## C#: `foreach (var x in arr) { }`
## Nim: `for x in arr:`
proc conv_xnkForeachStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkForStmt)
  result.add(convertToNimAST(node.foreachVar))
  result.add(convertToNimAST(node.foreachIter))
  result.add(convertToNimAST(node.foreachBody))

## C#: `catch (Exception e) { }`
## Nim: `except e:`
proc conv_xnkCatchStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkExceptBranch)
  # Exception type
  if node.catchType.isSome():
    result.add(convertToNimAST(node.catchType.get))
  else:
    result.add(newEmptyNode())
  # Exception variable (if named)
  if node.catchVar.isSome():
    result.add(newIdentNode(node.catchVar.get))
  # Body
  result.add(convertToNimAST(node.catchBody))

## C#: `finally { }`
## Nim: `finally:`
proc conv_xnkFinallyStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkFinally)
  result.add(convertToNimAST(node.finallyBody))

## C#: `yield return x;`
## Nim: `yield x`
proc conv_xnkYieldExpr(node: XLangNode): MyNimNode =
  result = newNimNode(nnkYieldStmt)
  if node.yieldExpr.isSome():
    result.add(convertToNimAST(node.yieldExpr.get))
  else:
    result.add(newEmptyNode())

## C#: `throw e;`
## Nim: `raise e`
proc conv_xnkThrowStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkRaiseStmt)
  result.add(convertToNimAST(node.throwExpr))

## C#: `Debug.Assert(x);`
## Nim: `assert x`
proc conv_xnkAssertStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkCall)
  result.add(newIdentNode("assert"))
  result.add(convertToNimAST(node.assertCond))
## C#: `myLabel: statement;` (Nim has no goto/labels)
## Nim: (discarded)
proc conv_xnkLabeledStmt(node: XLangNode): MyNimNode =
  convertToNimAST(node.labeledStmt)  # Just convert the statement, discard label

## C#: `goto label;` (Nim has no goto)
## Nim: (discarded - should restructure code)
proc conv_xnkGotoStmt(node: XLangNode): MyNimNode =
  addWarning(xnkGotoStmt, "goto statement not supported in Nim - code needs restructuring")
  result = newNimNode(nnkCommentStmt)
  result.strVal = "UNSUPPORTED: goto " & node.gotoLabel & " - requires manual restructuring"

## C#: `fixed (int* p = arr) { }` (unsafe pointers)
## Nim: (discarded - use ptr manually)
proc conv_xnkFixedStmt(node: XLangNode): MyNimNode =
  addWarning(xnkFixedStmt, "fixed statement not supported - use ptr manually in Nim")
  result = newNimNode(nnkCommentStmt)
  result.strVal = "UNSUPPORTED: fixed statement - use unsafe pointer operations manually"

## C#: `lock (obj) { }` (Nim has no built-in lock)
## Nim: (use locks module manually)
proc conv_xnkLockStmt(node: XLangNode): MyNimNode =
  addWarning(xnkLockStmt, "lock statement not directly supported - use locks module")
  result = newNimNode(nnkCommentStmt)
  result.strVal = "UNSUPPORTED: lock statement - use locks module with withLock template"

## C#: `unsafe { }` (Nim doesn't need unsafe blocks)
## Nim: (just convert body)
proc conv_xnkUnsafeStmt(node: XLangNode): MyNimNode =
  convertToNimAST(node.unsafeBody)

## C#: `checked { }` / `unchecked { }` (overflow checking)
## Nim: (discarded - Nim has compile-time overflow checks)
proc conv_xnkCheckedStmt(node: XLangNode): MyNimNode =
  convertToNimAST(node.checkedBody)

## C#: local function inside method
## Nim: nested proc
proc conv_xnkLocalFunctionStmt(node: XLangNode): MyNimNode = notYetImpl("xnkLocalFunctionStmt")

## Ruby: `unless x` → `if not x`
## Nim: (already lowered to if)
proc conv_xnkUnlessStmt(node: XLangNode): MyNimNode = notYetImpl("xnkUnlessStmt")

## `repeat...until x` → `while not x`
## Nim: (already lowered)
proc conv_xnkUntilStmt(node: XLangNode): MyNimNode = notYetImpl("xnkUntilStmt")

## C++: `static_assert(x)`
## Nim: `static: assert x`
proc conv_xnkStaticAssert(node: XLangNode): MyNimNode =
  result = newNimNode(nnkStaticStmt)
  let assertCall = newNimNode(nnkCall)
  assertCall.add(newIdentNode("assert"))
  assertCall.add(convertToNimAST(node.staticAssertCondition))
  result.add(assertCall)

## C#: `switch (x) { case 1: ...; default: ...; }`
## Nim: `case x: of 1: ...; else: ...`
proc conv_xnkSwitchStmt(node: XLangNode): MyNimNode =
  result = newNimNode(nnkCaseStmt)
  result.add(convertToNimAST(node.switchExpr))
  for caseNode in node.switchCases:
    result.add(convertToNimAST(caseNode))

## C#: `case 1: case 2: statements;`
## Nim: `of 1, 2: statements`
proc conv_xnkCaseClause(node: XLangNode): MyNimNode =
  result = newNimNode(nnkOfBranch)
  for val in node.caseValues:
    result.add(convertToNimAST(val))
  result.add(convertToNimAST(node.caseBody))

## C#: `default: statements;`
## Nim: `else: statements`
proc conv_xnkDefaultClause(node: XLangNode): MyNimNode =
  result = newNimNode(nnkElse)
  result.add(convertToNimAST(node.defaultBody))
# ==== EXPRESSION CONVERSIONS ====

## C#/Python: `[1, 2, 3]`
## Nim: `[1, 2, 3]`
proc conv_xnkArrayLit(node: XLangNode): MyNimNode =
  result = newNimNode(nnkBracket)
  for elem in node.arrayLitElements:
    result.add(convertToNimAST(elem))

## Python: `[1, 2, 3]`
## Nim: `@[1, 2, 3]`
proc conv_xnkListExpr(node: XLangNode): MyNimNode =
  result = newNimNode(nnkPrefix)
  result.add(newIdentNode("@"))
  let bracket = newNimNode(nnkBracket)
  for elem in node.elements:
    bracket.add(convertToNimAST(elem))
  result.add(bracket)

## Python: `{1, 2, 3}`
## Nim: `{1, 2, 3}`
proc conv_xnkSetExpr(node: XLangNode): MyNimNode =
  result = newNimNode(nnkCurly)
  for elem in node.elements:
    result.add(convertToNimAST(elem))

## Python: `(1, 2, 3)`
## Nim: `(1, 2, 3)`
proc conv_xnkTupleExpr(node: XLangNode): MyNimNode =
  result = newNimNode(nnkTupleConstr)
  for elem in node.elements:
    result.add(convertToNimAST(elem))

## Python: `{"a": 1, "b": 2}`
## Nim: `{"a": 1, "b": 2}.toTable`
proc conv_xnkDictExpr(node: XLangNode): MyNimNode =
  result = newNimNode(nnkTableConstr)
  for entry in node.entries:
    result.add(convertToNimAST(entry))

## Dictionary entry `"key": value`
## Nim: `"key": value`
proc conv_xnkDictEntry(node: XLangNode): MyNimNode =
  result = newNimNode(nnkExprColonExpr)
  result.add(convertToNimAST(node.key))
  result.add(convertToNimAST(node.value))

## Python: `arr[1:3]`
## Nim: `arr[1..3]` or `arr[1..^1]`
proc conv_xnkSliceExpr(node: XLangNode): MyNimNode =
  result = newNimNode(nnkInfix)
  result.add(newIdentNode(".."))
  if node.sliceStart.isSome():
    result.add(convertToNimAST(node.sliceStart.get))
  else:
    result.add(newIntLitNode(0))  # Default to 0
  if node.sliceEnd.isSome():
    result.add(convertToNimAST(node.sliceEnd.get))
  else:
    # Default to ^1 (last element)
    let backwardsIdx = newNimNode(nnkPrefix)
    backwardsIdx.add(newIdentNode("^"))
    backwardsIdx.add(newIntLitNode(1))
    result.add(backwardsIdx)

## C#: `x => x + 1`
## Nim: `proc (x: auto): auto = x + 1`
proc conv_xnkLambdaExpr(node: XLangNode): MyNimNode = notYetImpl("xnkLambdaExpr")

proc conv_xnkLambdaProc(node: XLangNode): MyNimNode = notYetImpl("xnkLambdaProc")

## JS: `x => x + 1`
## Nim: `proc (x: auto): auto = x + 1`
proc conv_xnkArrowFunc(node: XLangNode): MyNimNode = notYetImpl("xnkArrowFunc")

## TypeScript: `x as string`
## Nim: `x`  (type assertion not needed at runtime)
proc conv_xnkTypeAssertion(node: XLangNode): MyNimNode =
  convertToNimAST(node.assertExpr)  # Just convert the expression

## C#: `(T)x`
## Nim: `cast[T](x)` or `T(x)`
proc conv_xnkCastExpr(node: XLangNode): MyNimNode =
  result = newNimNode(nnkCast)
  result.add(convertToNimAST(node.castType))
  result.add(convertToNimAST(node.castExpr))
## C#: `base.Method()`
## Nim: `procCall Method(self)` (needs proper super implementation)
proc conv_xnkBaseExpr(node: XLangNode): MyNimNode = notYetImpl("xnkBaseExpr")

## C#: `ref x` or `&x`
## Nim: `addr x`
proc conv_xnkRefExpr(node: XLangNode): MyNimNode =
  result = newNimNode(nnkAddr)
  result.add(convertToNimAST(node.refExpr))

## Instance variable, class variable, global variable
## These are just variable references (identifiers)
## The actual dot expression is handled by xnkDotExpr
proc conv_xnkInstanceVar(node: XLangNode): MyNimNode =
  newIdentNode(node.varName)

proc conv_xnkClassVar(node: XLangNode): MyNimNode =
  newIdentNode(node.varName)

proc conv_xnkGlobalVar(node: XLangNode): MyNimNode =
  newIdentNode(node.varName)

proc conv_xnkProcLiteral(node: XLangNode): MyNimNode = notYetImpl("xnkProcLiteral")
proc conv_xnkProcPointer(node: XLangNode): MyNimNode = notYetImpl("xnkProcPointer")

## Any number literal (int/float)
## Nim: parse and create appropriate literal
proc conv_xnkNumberLit(node: XLangNode): MyNimNode =
  # Try to parse as int, fallback to float
  try:
    result = newIntLitNode(parseInt(node.literalValue))
  except ValueError:
    result = newFloatLitNode(parseFloat(node.literalValue))

## Ruby: `:symbol`
## Nim: (convert to string or ident)
proc conv_xnkSymbolLit(node: XLangNode): MyNimNode =
  newStrLitNode(node.symbolValue)
proc conv_xnkDynamicType(node: XLangNode): MyNimNode = notYetImpl("xnkDynamicType")
proc conv_xnkGeneratorExpr(node: XLangNode): MyNimNode = notYetImpl("xnkGeneratorExpr")
proc conv_xnkAwaitExpr(node: XLangNode): MyNimNode = notYetImpl("xnkAwaitExpr")
proc conv_xnkCompFor(node: XLangNode): MyNimNode = notYetImpl("xnkCompFor")
proc conv_xnkDefaultExpr(node: XLangNode): MyNimNode = notYetImpl("xnkDefaultExpr")
proc conv_xnkTypeOfExpr(node: XLangNode): MyNimNode = notYetImpl("xnkTypeOfExpr")
proc conv_xnkSizeOfExpr(node: XLangNode): MyNimNode = notYetImpl("xnkSizeOfExpr")
proc conv_xnkCheckedExpr(node: XLangNode): MyNimNode = notYetImpl("xnkCheckedExpr")
proc conv_xnkThrowExpr(node: XLangNode): MyNimNode = notYetImpl("xnkThrowExpr")
proc conv_xnkSwitchExpr(node: XLangNode): MyNimNode = notYetImpl("xnkSwitchExpr")
proc conv_xnkStackAllocExpr(node: XLangNode): MyNimNode = notYetImpl("xnkStackAllocExpr")
proc conv_xnkImplicitArrayCreation(node: XLangNode): MyNimNode = notYetImpl("xnkImplicitArrayCreation")
proc conv_xnkNamedType(node: XLangNode): MyNimNode = newIdentNode(node.typeName)

## C#: `int[]` or `int[10]`
## Nim: `seq[int]` or `array[10, int]`
proc conv_xnkArrayType(node: XLangNode): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  if node.arraySize.isSome():
    # Fixed-size array
    result.add(newIdentNode("array"))
    result.add(convertToNimAST(node.arraySize.get))
    result.add(convertToNimAST(node.elementType))
  else:
    # Dynamic array → seq
    result.add(newIdentNode("seq"))
    result.add(convertToNimAST(node.elementType))

## C#: `Dictionary<K, V>`
## Nim: `Table[K, V]`
proc conv_xnkMapType(node: XLangNode): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  result.add(newIdentNode("Table"))
  result.add(convertToNimAST(node.keyType))
  result.add(convertToNimAST(node.valueType))

## Function type: `(int) -> string`
## Nim: `proc(x: int): string`
proc conv_xnkFuncType(node: XLangNode): MyNimNode =
  result = newNimNode(nnkProcTy)
  var params = newNimNode(nnkFormalParams)
  # Return type first
  if node.funcReturnType.isSome():
    params.add(convertToNimAST(node.funcReturnType.get))
  else:
    params.add(newEmptyNode())
  # Parameters
  for param in node.funcParams:
    params.add(convertToNimAST(param))
  result.add(params)
  result.add(newEmptyNode()) # pragmas

proc conv_xnkFunctionType(node: XLangNode): MyNimNode = conv_xnkFuncType(node)

## C: `int*`
## Nim: `ptr int`
proc conv_xnkPointerType(node: XLangNode): MyNimNode =
  result = newNimNode(nnkPtrTy)
  result.add(convertToNimAST(node.referentType))

## C#: `ref T`
## Nim: `ref T`
proc conv_xnkReferenceType(node: XLangNode): MyNimNode =
  result = newNimNode(nnkRefTy)
  result.add(convertToNimAST(node.referentType))

## C#: `List<T>`
## Nim: `List[T]`
proc conv_xnkGenericType(node: XLangNode): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  result.add(newIdentNode(node.genericTypeName))
  for arg in node.genericArgs:
    result.add(convertToNimAST(arg))
proc conv_xnkUnionType(node: XLangNode): MyNimNode = assertLowered("xnkUnionType")

## TypeScript: `A & B` (should be lowered by transform)
proc conv_xnkIntersectionType(node: XLangNode): MyNimNode = assertLowered("xnkIntersectionType")

## Nim: `distinct int`
proc conv_xnkDistinctType(node: XLangNode): MyNimNode =
  result = newNimNode(nnkDistinctTy)
  result.add(convertToNimAST(node.distinctBaseType))

## Parameter in function signature
## Nim: `x: int` → nnkIdentDefs
proc conv_xnkParameter(node: XLangNode): MyNimNode =
  result = newNimNode(nnkIdentDefs)
  result.add(newIdentNode(node.paramName))
  if node.paramType.isSome():
    result.add(convertToNimAST(node.paramType.get))
  else:
    result.add(newEmptyNode())
  if node.defaultValue.isSome():
    result.add(convertToNimAST(node.defaultValue.get))
  else:
    result.add(newEmptyNode())

## Argument in function call (just the expression)
proc conv_xnkArgument(node: XLangNode): MyNimNode =
  convertToNimAST(node.argValue)
## Python decorator (should be lowered to pragmas or discarded)
proc conv_xnkDecorator(node: XLangNode): MyNimNode = newNimNode(nnkDiscardStmt)

proc conv_xnkConceptRequirement(node: XLangNode): MyNimNode = notYetImpl("xnkConceptRequirement")
proc conv_xnkConceptDecl(node: XLangNode): MyNimNode = notYetImpl("xnkConceptDecl")

## Qualified name: `a.b.c`
## Nim: nested dot expression
proc conv_xnkQualifiedName(node: XLangNode): MyNimNode =
  # Recursively build: left.right
  result = newNimNode(nnkDotExpr)
  result.add(convertToNimAST(node.qualifiedLeft))
  result.add(newIdentNode(node.qualifiedRight))

## Alias qualified name: `alias::Name`
proc conv_xnkAliasQualifiedName(node: XLangNode): MyNimNode =
  result = newNimNode(nnkDotExpr)
  result.add(newIdentNode(node.aliasQualifier))
  result.add(newIdentNode(node.aliasQualifiedName))

## Generic name: `List<T>`
## Nim: `List[T]` (bracket expression)
proc conv_xnkGenericName(node: XLangNode): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  result.add(newIdentNode(node.genericNameIdentifier))
  for arg in node.genericNameArgs:
    result.add(convertToNimAST(arg))

## Method reference: `obj.Method`
## Nim: dot expression
proc conv_xnkMethodReference(node: XLangNode): MyNimNode =
  result = newNimNode(nnkDotExpr)
  result.add(convertToNimAST(node.refObject))
  result.add(newIdentNode(node.refMethod))
## Python module (convert to statement list)
proc conv_xnkModuleDecl(node: XLangNode): MyNimNode =
  result = newNimNode(nnkStmtList)
  for stmt in node.moduleBody:
    result.add(convertToNimAST(stmt))

## C#: `using X = Y;`
## Nim: `type X = Y`
proc conv_xnkTypeAlias(node: XLangNode): MyNimNode =
  result = newNimNode(nnkTypeDef)
  result.add(newIdentNode(node.aliasName))
  result.add(newEmptyNode()) # generic params
  result.add(convertToNimAST(node.aliasTarget))

## Nim: `include "filename"`
proc conv_xnkInclude(node: XLangNode): MyNimNode =
  result = newNimNode(nnkIncludeStmt)
  result.add(convertToNimAST(node.includeName))

## Nim mixin statement
proc conv_xnkMixinDecl(node: XLangNode): MyNimNode =
  result = newNimNode(nnkMixinStmt)
  for name in node.mixinNames:
    result.add(newIdentNode(name))

proc conv_xnkTemplateDecl(node: XLangNode): MyNimNode = notYetImpl("xnkTemplateDecl")
proc conv_xnkMacroDecl(node: XLangNode): MyNimNode = notYetImpl("xnkMacroDecl")
proc conv_xnkExtend(node: XLangNode): MyNimNode = notYetImpl("xnkExtend")
proc conv_xnkTypeSwitchStmt(node: XLangNode): MyNimNode = notYetImpl("xnkTypeSwitchStmt")
proc conv_xnkTypeCaseClause(node: XLangNode): MyNimNode = notYetImpl("xnkTypeCaseClause")
proc conv_xnkSwitchCase(node: XLangNode): MyNimNode = notYetImpl("xnkSwitchCase")
proc conv_xnkAsgn(node: XLangNode): MyNimNode = notYetImpl("xnkAsgn")


#TODO: support all LOWERED (after transforms) xlangtypes node kinds
proc convertToNimAST*(node: XLangNode): MyNimNode =
  case node.kind
  of xnkFile:
    result = conv_xnkFile(node)
  of xnkModule:
    result = conv_xnkModule(node)
  of xnkNamespace:
    result = conv_xnkNamespace(node)
  of xnkFuncDecl, xnkMethodDecl:
    result = conv_xnkFuncDecl_method(node)
  of xnkClassDecl, xnkStructDecl:
    result = conv_xnkClassDecl_structDecl(node)
  of xnkInterfaceDecl:
    result = conv_xnkInterfaceDecl(node)
  of xnkEnumDecl:
    result = conv_xnkEnumDecl(node)
  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    result = conv_xnkVarLetConst(node)
  of xnkIfStmt:
    result = conv_xnkIfStmt(node)
  of xnkWhileStmt:
    result = conv_xnkWhileStmt(node)
  of xnkForStmt:
    result = conv_xnkForStmt(node)
  of xnkBlockStmt:
    result = conv_xnkBlockStmt(node)
  of xnkCallExpr:
    result = conv_xnkCallExpr(node)
  of xnkDotExpr:
    result = conv_xnkDotExpr(node)
  of xnkMemberAccessExpr:
    result = conv_xnkMemberAccess(node)
  of xnkBracketExpr:
    result = conv_xnkBracketExpr(node)
  of xnkIndexExpr:
    result = conv_xnkIndexExpr(node)
  of xnkBinaryExpr:
    result = conv_xnkBinaryExpr(node)
  of xnkUnaryExpr:
    result = conv_xnkUnaryExpr(node)
  of xnkReturnStmt:
    result = conv_xnkReturnStmt(node)
  of xnkYieldStmt:
    result = conv_xnkYieldStmt(node)
  of xnkDiscardStmt:
    result = conv_xnkDiscardStmt(node)
  of xnkCaseStmt:
    result = conv_xnkCaseStmt(node)
  of xnkTryStmt:
    result = conv_xnkTryStmt(node)
  of xnkRaiseStmt:
    result = conv_xnkRaiseStmt(node)
  of xnkTypeDecl:
    result = conv_xnkTypeDecl(node)
  of xnkImportStmt:
    result = conv_xnkImportStmt(node)
  of xnkImport:
    result = conv_xnkImport(node)
  of xnkExport:
    result = conv_xnkExport(node)
  of xnkExportStmt:
    result = conv_xnkExportStmt(node)
  of xnkFromImportStmt:
    result = conv_xnkFromImportStmt(node)
  of xnkGenericParameter:
    result = conv_xnkGenericParameter(node)
  of xnkIdentifier:
    result = conv_xnkIdentifier(node)
  of xnkComment:
    result = conv_xnkComment(node)
  of xnkIntLit:
    result = conv_xnkIntLit(node)
  of xnkFloatLit:
    result = conv_xnkFloatLit(node)
  of xnkStringLit:
    result = conv_xnkStringLit(node)
  of xnkCharLit:
    result = conv_xnkCharLit(node)
  of xnkBoolLit:
    result = conv_xnkBoolLit(node)
  of xnkNilLit:
    result = conv_xnkNilLit(node)
  of xnkTemplateDef, xnkMacroDef:
    result = conv_xnkTemplateMacro(node)
  of xnkPragma:
    result = conv_xnkPragma(node)
  of xnkStaticStmt:
    result = conv_xnkStaticStmt(node)
  of xnkDeferStmt:
    result = conv_xnkDeferStmt(node)
  of xnkAsmStmt:
    result = conv_xnkAsmStmt(node)
  of xnkDistinctTypeDef:
    result = conv_xnkDistinctTypeDef(node)
  of xnkConceptDef:
    result = conv_xnkConceptDef(node)
  of xnkMixinStmt:
    result = conv_xnkMixinStmt(node)
  of xnkBindStmt:
    result = conv_xnkBindStmt(node)
  of xnkTupleConstr:
    result = conv_xnkTupleConstr(node)
  of xnkTupleUnpacking:
    result = conv_xnkTupleUnpacking(node)
  of xnkUsingStmt:
    result = conv_xnkUsingStmt(node)
  
  # TODO: discard (when nim doesn't have it - disappears in transforms) or write conv_ procs after mapping and example of c# code of that construct to expected Nim code.
  of xnkIteratorDecl:
    result = conv_xnkIteratorDecl(node)
  of xnkPropertyDecl:
    result = conv_xnkPropertyDecl(node)
  of xnkFieldDecl:
    result = conv_xnkFieldDecl(node)
  of xnkConstructorDecl:
    result = conv_xnkConstructorDecl(node)
  of xnkDestructorDecl:
    result = conv_xnkDestructorDecl(node)
  of xnkDelegateDecl:
    result = conv_xnkDelegateDecl(node)
  of xnkEventDecl:
    result = conv_xnkEventDecl(node)
  of xnkModuleDecl:
    result = conv_xnkModuleDecl(node)
  of xnkTypeAlias:
    result = conv_xnkTypeAlias(node)
  of xnkAbstractDecl:
    result = conv_xnkAbstractDecl(node)
  of xnkEnumMember:
    result = conv_xnkEnumMember(node)
  of xnkIndexerDecl:
    result = conv_xnkIndexerDecl(node)
  of xnkOperatorDecl:
    result = conv_xnkOperatorDecl(node)
  of xnkConversionOperatorDecl:
    result = conv_xnkConversionOperatorDecl(node)
  of xnkAbstractType:
    result = conv_xnkAbstractType(node)
  of xnkFunctionType:
    result = conv_xnkFunctionType(node)
  of xnkMetadata:
    result = conv_xnkMetadata(node)
  of xnkLibDecl:
    result = conv_xnkLibDecl(node)
  of xnkCFuncDecl:
    result = conv_xnkCFuncDecl(node)
  of xnkExternalVar:
    result = conv_xnkExternalVar(node)
  of xnkAsgn:
    result = conv_xnkAsgn(node)
  of xnkSwitchStmt:
    result = conv_xnkSwitchStmt(node)
  of xnkCaseClause:
    result = conv_xnkCaseClause(node)
  of xnkDefaultClause:
    result = conv_xnkDefaultClause(node)
  of xnkDoWhileStmt:
    result = conv_xnkDoWhileStmt(node)
  of xnkForeachStmt:
    result = conv_xnkForeachStmt(node)
  of xnkCatchStmt:
    result = conv_xnkCatchStmt(node)
  of xnkFinallyStmt:
    result = conv_xnkFinallyStmt(node)
  of xnkYieldExpr:
    result = conv_xnkYieldExpr(node)
  of xnkYieldFromStmt:
    result = conv_xnkYieldFromStmt(node)
  of xnkBreakStmt:
    result = conv_xnkBreakStmt(node)
  of xnkContinueStmt:
    result = conv_xnkContinueStmt(node)
  of xnkThrowStmt:
    result = conv_xnkThrowStmt(node)
  of xnkAssertStmt:
    result = conv_xnkAssertStmt(node)
  of xnkWithStmt:
    result = conv_xnkWithStmt(node)
  of xnkPassStmt:
    result = conv_xnkPassStmt(node)
  of xnkTypeSwitchStmt:
    result = conv_xnkTypeSwitchStmt(node)
  of xnkTypeCaseClause:
    result = conv_xnkTypeCaseClause(node)
  of xnkWithItem:
    result = conv_xnkWithItem(node)
  of xnkEmptyStmt:
    result = conv_xnkEmptyStmt(node)
  of xnkLabeledStmt:
    result = conv_xnkLabeledStmt(node)
  of xnkGotoStmt:
    result = conv_xnkGotoStmt(node)
  of xnkFixedStmt:
    result = conv_xnkFixedStmt(node)
  of xnkLockStmt:
    result = conv_xnkLockStmt(node)
  of xnkUnsafeStmt:
    result = conv_xnkUnsafeStmt(node)
  of xnkCheckedStmt:
    result = conv_xnkCheckedStmt(node)
  of xnkLocalFunctionStmt:
    result = conv_xnkLocalFunctionStmt(node)
  of xnkUnlessStmt:
    result = conv_xnkUnlessStmt(node)
  of xnkUntilStmt:
    result = conv_xnkUntilStmt(node)
  of xnkStaticAssert:
    result = conv_xnkStaticAssert(node)
  of xnkSwitchCase:
    result = conv_xnkSwitchCase(node)
  of xnkMixinDecl:
    result = conv_xnkMixinDecl(node)
  of xnkTemplateDecl:
    result = conv_xnkTemplateDecl(node)
  of xnkMacroDecl:
    result = conv_xnkMacroDecl(node)
  of xnkInclude:
    result = conv_xnkInclude(node)
  of xnkExtend:
    result = conv_xnkExtend(node)
  of xnkTernaryExpr:
    result = conv_xnkTernaryExpr(node)
  of xnkSliceExpr:
    result = conv_xnkSliceExpr(node)
  of xnkSafeNavigationExpr:
    result = conv_xnkSafeNavigationExpr(node)
  of xnkNullCoalesceExpr:
    result = conv_xnkNullCoalesceExpr(node)
  of xnkConditionalAccessExpr:
    result = conv_xnkConditionalAccessExpr(node)
  of xnkLambdaExpr:
    result = conv_xnkLambdaExpr(node)
  of xnkTypeAssertion:
    result = conv_xnkTypeAssertion(node)
  of xnkCastExpr:
    result = conv_xnkCastExpr(node)
  of xnkThisExpr:
    result = conv_xnkThisExpr(node)
  of xnkBaseExpr:
    result = conv_xnkBaseExpr(node)
  of xnkRefExpr:
    result = conv_xnkRefExpr(node)
  of xnkInstanceVar:
    result = conv_xnkInstanceVar(node)
  of xnkClassVar:
    result = conv_xnkClassVar(node)
  of xnkGlobalVar:
    result = conv_xnkGlobalVar(node)
  of xnkProcLiteral:
    result = conv_xnkProcLiteral(node)
  of xnkProcPointer:
    result = conv_xnkProcPointer(node)
  of xnkArrayLit:
    result = conv_xnkArrayLit(node)
  of xnkNumberLit:
    result = conv_xnkNumberLit(node)
  of xnkSymbolLit:
    result = conv_xnkSymbolLit(node)
  of xnkDynamicType:
    result = conv_xnkDynamicType(node)
  of xnkGeneratorExpr:
    result = conv_xnkGeneratorExpr(node)
  of xnkAwaitExpr:
    result = conv_xnkAwaitExpr(node)
  of xnkStringInterpolation:
    result = conv_xnkStringInterpolation(node)
  of xnkCompFor:
    result = conv_xnkCompFor(node)
  of xnkDefaultExpr:
    result = conv_xnkDefaultExpr(node)
  of xnkTypeOfExpr:
    result = conv_xnkTypeOfExpr(node)
  of xnkSizeOfExpr:
    result = conv_xnkSizeOfExpr(node)
  of xnkCheckedExpr:
    result = conv_xnkCheckedExpr(node)
  of xnkThrowExpr:
    result = conv_xnkThrowExpr(node)
  of xnkSwitchExpr:
    result = conv_xnkSwitchExpr(node)
  of xnkStackAllocExpr:
    result = conv_xnkStackAllocExpr(node)
  of xnkImplicitArrayCreation:
    result = conv_xnkImplicitArrayCreation(node)
  of xnkNoneLit:
    result = conv_xnkNoneLit(node)
  of xnkNamedType:
    result = conv_xnkNamedType(node)
  of xnkArrayType:
    result = conv_xnkArrayType(node)
  of xnkMapType:
    result = conv_xnkMapType(node)
  of xnkFuncType:
    result = conv_xnkFuncType(node)
  of xnkPointerType:
    result = conv_xnkPointerType(node)
  of xnkReferenceType:
    result = conv_xnkReferenceType(node)
  of xnkGenericType:
    result = conv_xnkGenericType(node)
  of xnkUnionType:
    result = conv_xnkUnionType(node)
  of xnkIntersectionType:
    result = conv_xnkIntersectionType(node)
  of xnkDistinctType:
    result = conv_xnkDistinctType(node)
  of xnkAttribute:
    result = conv_xnkAttribute(node)
  of xnkParameter:
    result = conv_xnkParameter(node)
  of xnkArgument:
    result = conv_xnkArgument(node)
  of xnkDecorator:
    result = conv_xnkDecorator(node)
  of xnkLambdaProc:
    result = conv_xnkLambdaProc(node)
  of xnkArrowFunc:
    result = conv_xnkArrowFunc(node)
  of xnkConceptRequirement:
    result = conv_xnkConceptRequirement(node)
  of xnkQualifiedName:
    result = conv_xnkQualifiedName(node)
  of xnkAliasQualifiedName:
    result = conv_xnkAliasQualifiedName(node)
  of xnkGenericName:
    result = conv_xnkGenericName(node)
  of xnkUnknown:
    result = conv_xnkUnknown(node)
  of xnkConceptDecl:
    result = conv_xnkConceptDecl(node)
  of xnkDestructureObj:
    result = conv_xnkDestructureObj(node)
  of xnkDestructureArray:
    result = conv_xnkDestructureArray(node)
  of xnkMethodReference:
    result = conv_xnkMethodReference(node)
  of xnkListExpr:
    result = conv_xnkListExpr(node)
  of xnkSetExpr:
    result = conv_xnkSetExpr(node)
  of xnkTupleExpr:
    result = conv_xnkTupleExpr(node)
  of xnkDictExpr:
    result = conv_xnkDictExpr(node)
  of xnkComprehensionExpr:
    result = conv_xnkComprehensionExpr(node)
  of xnkDictEntry:
    result = conv_xnkDictEntry(node)


  # else:
  #   raise newException(ValueError, "Unsupported XLang node kind: " & $node.kind)



# # proc convertXLangASTToNimAST*(xlangAST: XLangAST): MyNimNode =
# #   result = newStmtList()
# #   for node in xlangAST:
# #     result.add(convertToNimAST(node))

# # Example usage
# when isMainModule:
#   let xlangAST = XLangNode(kind: xnkFile, fileName: "example.nim", declarations: @[
#     XLangNode(kind: xnkFuncDecl, funcName: "main", params: @[], returnType: none(XLangNode),
#       body: XLangNode(kind: xnkBlockStmt, body: @[
#         XLangNode(kind: xnkCallExpr, callee: XLangNode(kind: xnkIdentifier, identName: "echo"),
#                  args: @[XLangNode(kind: xnkStringLit, literalValue: "Hello, World!")])
#       ])
#     )
#   ])

#   let nimAST = convertToNimAST(xlangAST)
#   echo nimAST.repr