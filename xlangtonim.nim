import xlangtypes
import src/helpers
import options, strutils
import src/my_nim_node

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
    if member.value.isSome():
      let field = newNimNode(nnkEnumFieldDef)
      field.add(newIdentNode(member.name))
      field.add(convertToNimAST(member.value.get))
      enumTy.add(field)
    else:
      enumTy.add(newIdentNode(member.name))
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

  else:
    raise newException(ValueError, "Unsupported XLang node kind: " & $node.kind)



# proc convertXLangASTToNimAST*(xlangAST: XLangAST): MyNimNode =
#   result = newStmtList()
#   for node in xlangAST:
#     result.add(convertToNimAST(node))

# Example usage
when isMainModule:
  let xlangAST = XLangNode(kind: xnkFile, fileName: "example.nim", declarations: @[
    XLangNode(kind: xnkFuncDecl, funcName: "main", params: @[], returnType: none(XLangNode),
      body: XLangNode(kind: xnkBlockStmt, body: @[
        XLangNode(kind: xnkCallExpr, callee: XLangNode(kind: xnkIdentifier, identName: "echo"),
                 args: @[XLangNode(kind: xnkStringLit, literalValue: "Hello, World!")])
      ])
    )
  ])

  let nimAST = convertToNimAST(xlangAST)
  echo nimAST.repr