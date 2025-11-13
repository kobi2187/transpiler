import macros
import xlangtypes

import macros, options, strutils




proc convertToNimAST*(node: XLangNode): NimNode =
  case node.kind
  
  of xnkFile:
    result = newStmtList()
    
    for decl in node.moduleDecls:
      result.add(convertToNimAST(decl))

  # of xnkModule:
  #   result = newNimNode(nnkStmtList)
  #   result.add(newNimNode(nnkModuleDecl).add(newIdentNode(node.moduleName)))
  #   for stmt in node.moduleBody:
  #     result.add(convertToNimAST(stmt))
  of xnkModule:
    # Nim doesn't have a direct equivalent to Java's module system
    # We'll create a comment node to preserve the information
    result = newCommentStmtNode("Module: " & node.moduleName)
    for stmt in node.moduleBody:
      result.add(convertToNimAST(stmt))
  
  of xnkFuncDecl, xnkMethodDecl:
    result = newProc(
      name = newIdentNode(node.funcName),
      params = [newNimNode(nnkFormalParams)],
      body = convertToNimAST(node.body),
      procType = if node.kind == xnkFuncDecl: nnkProcDef else: nnkMethodDef
    )
    for param in node.params:
      result.params.add(convertToNimAST(param))
    if node.returnType.isSome:
      result.params[0] = convertToNimAST(node.returnType.get)
    else:
      result.params[0] = newEmptyNode()

  of xnkClassDecl:
    result = newNimNode(nnkTypeSection)
    let typeDef = newNimNode(nnkTypeDef)
    typeDef.add(newIdentNode(node.typeName))
    typeDef.add(newEmptyNode())  # No generic params for now
    let objTy = newNimNode(nnkObjectTy)
    objTy.add(newEmptyNode())  # No pragma
    objTy.add(newEmptyNode())  # No parent object
    let recList = newNimNode(nnkRecList)
    for member in node.members:
      recList.add(convertToNimAST(member))
    objTy.add(recList)
    typeDef.add(objTy)
    result.add(typeDef)

  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    result = newNimNode(
      case node.kind
      of xnkVarDecl: nnkVarSection
      of xnkLetDecl: nnkLetSection
      of xnkConstDecl: nnkConstSection
      else: nnkVarSection  # This should never happen
    )
    let identDefs = newNimNode(nnkIdentDefs)
    identDefs.add(newIdentNode(node.name))
    if node.typ.isSome:
      identDefs.add(convertToNimAST(node.typ.get))
    else:
      identDefs.add(newEmptyNode())
    if node.value.isSome:
      identDefs.add(convertToNimAST(node.value.get))
    else:
      identDefs.add(newEmptyNode())
    result.add(identDefs)

  of xnkIfStmt:
    result = newNimNode(nnkIfStmt)
    for branch in node.branches:
      let branchNode = newNimNode(nnkElifBranch)
      branchNode.add(convertToNimAST(branch.condition))
      branchNode.add(convertToNimAST(branch.body))
      result.add(branchNode)
    if node.elseBody.isSome:
      let elseNode = newNimNode(nnkElse)
      elseNode.add(convertToNimAST(node.elseBody.get))
      result.add(elseNode)

  of xnkWhileStmt:
    result = newNimNode(nnkWhileStmt)
    result.add(convertToNimAST(node.condition))
    result.add(convertToNimAST(node.body))

  of xnkForStmt:
    result = newNimNode(nnkForStmt)
    for v in node.vars:
      result.add(newIdentNode(v))
    result.add(convertToNimAST(node.iter))
    result.add(convertToNimAST(node.body))

  of xnkBlockStmt:
    result = newNimNode(nnkBlockStmt)
    if node.label.isSome:
      result.add(newIdentNode(node.label.get))
    else:
      result.add(newEmptyNode())
    result.add(convertToNimAST(node.body))

  of xnkCallExpr:
    result = newNimNode(nnkCall)
    result.add(convertToNimAST(node.callee))
    for arg in node.args:
      result.add(convertToNimAST(arg))

  of xnkDotExpr:
    result = newNimNode(nnkDotExpr)
    result.add(convertToNimAST(node.left))
    result.add(convertToNimAST(node.right))

  of xnkBracketExpr:
    result = newNimNode(nnkBracketExpr)
    result.add(convertToNimAST(node.expr))
    for index in node.indices:
      result.add(convertToNimAST(index))

  of xnkBinaryExpr:
    result = newNimNode(nnkInfix)
    result.add(newIdentNode(node.op))
    result.add(convertToNimAST(node.left))
    result.add(convertToNimAST(node.right))

  of xnkUnaryExpr:
    if node.isPostfix:
      result = newNimNode(nnkPostfix)
    else:
      result = newNimNode(nnkPrefix)
    result.add(newIdentNode(node.op))
    result.add(convertToNimAST(node.operand))

  of xnkReturnStmt:
    result = newNimNode(nnkReturnStmt)
    if node.expr.isSome:
      result.add(convertToNimAST(node.expr.get))
    else:
      result.add(newEmptyNode())

  of xnkYieldStmt:
    result = newNimNode(nnkYieldStmt)
    if node.expr.isSome:
      result.add(convertToNimAST(node.expr.get))
    else:
      result.add(newEmptyNode())

  of xnkDiscardStmt:
    result = newNimNode(nnkDiscardStmt)
    if node.expr.isSome:
      result.add(convertToNimAST(node.expr.get))
    else:
      result.add(newEmptyNode())

  of xnkCaseStmt:
    result = newNimNode(nnkCaseStmt)
    result.add(convertToNimAST(node.expr))
    for branch in node.branches:
      let ofBranch = newNimNode(nnkOfBranch)
      for cond in branch.conditions:
        ofBranch.add(convertToNimAST(cond))
      ofBranch.add(convertToNimAST(branch.body))
      result.add(ofBranch)
    if node.elseBody.isSome:
      let elseBranch = newNimNode(nnkElse)
      elseBranch.add(convertToNimAST(node.elseBody.get))
      result.add(elseBranch)

  of xnkTryStmt:
    result = newNimNode(nnkTryStmt)
    result.add(convertToNimAST(node.tryBody))
    for exceptt in node.exceptBranches:
      let exceptBranch = newNimNode(nnkExceptBranch)
      if exceptt.exceptionType.isSome:
        exceptBranch.add(convertToNimAST(exceptt.exceptionType.get))
      exceptBranch.add(convertToNimAST(exceptt.body))
      result.add(exceptBranch)
    if node.finallyBody.isSome:
      let finallyBranch = newNimNode(nnkFinally)
      finallyBranch.add(convertToNimAST(node.finallyBody.get))
      result.add(finallyBranch)


  of xnkFile:
    result = newStmtList()
    for decl in node.moduleDecls:
      result.add(convertXLangNodeToNim(decl))
  
  of xnkModule:
    result = newStmtList()
    for stmt in node.moduleBody:
      result.add(convertXLangNodeToNim(stmt))
  
  of xnkFuncDecl, xnkMethodDecl:
    let params = newNimNode(nnkFormalParams)
    if node.returnType.isSome:
      params.add(convertXLangNodeToNim(node.returnType.get))
    else:
      params.add(newEmptyNode())
    for param in node.params:
      params.add(convertXLangNodeToNim(param))

    result = newProc(
      name = newIdentNode(node.funcName),
      params = params,
      body = convertXLangNodeToNim(node.body),
      procType = nnkProcDef
    )
    if node.isAsync:
      result.addPragma(newIdentNode("async"))

  of xnkClassDecl, xnkStructDecl:
    result = newNimNode(nnkTypeSection)
    let objType = newNimNode(nnkObjectTy)
    objType.add(newEmptyNode())
    
    let inheritanceList = newNimNode(nnkOfInherit)
    for baseType in node.baseTypes:
      inheritanceList.add(convertXLangNodeToNim(baseType))
    objType.add(inheritanceList)

    let recList = newNimNode(nnkRecList)
    for member in node.members:
      recList.add(convertXLangNodeToNim(member))
    objType.add(recList)

    result.add(
      newNimNode(nnkTypeDef).add(
        newIdentNode(node.typeName),
        newEmptyNode(),
        newNimNode(nnkRefTy).add(objType)
      )
    )

  of xnkInterfaceDecl:
    # Nim doesn't have direct interface equivalent, we'll use concepts
    result = newNimNode(nnkTypeSection)
    let conceptDef = newNimNode(nnkTypeDef)
    conceptDef.add(newIdentNode(node.typeName))
    conceptDef.add(newEmptyNode())
    let conceptTy = newNimNode(nnkConceptTy)
    for meth in node.members:
      conceptTy.add(convertXLangNodeToNim(meth))
    conceptDef.add(conceptTy)
    result.add(conceptDef)

  of xnkEnumDecl:
    result = newNimNode(nnkTypeSection)
    let enumTy = newNimNode(nnkEnumTy)
    enumTy.add(newEmptyNode())
    for member in node.enumMembers:
      if member.value.isSome:
        enumTy.add(newNimNode(nnkEnumFieldDef).add(
          newIdentNode(member.name),
          convertXLangNodeToNim(member.value.get)
        ))
      else:
        enumTy.add(newIdentNode(member.name))
    result.add(
      newNimNode(nnkTypeDef).add(
        newIdentNode(node.enumName),
        newEmptyNode(),
        enumTy
      )
    )

  of xnkVarDecl, xnkConstDecl:
    result = newNimNode(if node.kind == xnkVarDecl: nnkVarSection else: nnkConstSection)
    let identDefs = newNimNode(nnkIdentDefs)
    identDefs.add(newIdentNode(node.declName))
    if node.declType.isSome:
      identDefs.add(convertXLangNodeToNim(node.declType.get))
    else:
      identDefs.add(newEmptyNode())
    if node.initializer.isSome:
      identDefs.add(convertXLangNodeToNim(node.initializer.get))
    else:
      identDefs.add(newEmptyNode())
    result.add(identDefs)


  of xnkRaiseStmt:
    result = newNimNode(nnkRaiseStmt)
    if node.expr.isSome:
      result.add(convertToNimAST(node.expr.get))
    else:
      result.add(newEmptyNode())

  of xnkTypeDecl:
    result = newNimNode(nnkTypeSection)
    result.add(
      newNimNode(nnkTypeDef).add(
        newIdentNode(node.typeDefName),
        newEmptyNode(),
        convertXLangToNim(node.typeDefBody)
      )
    )

  of xnkImportStmt:
    result = newNimNode(nnkImportStmt)
    for item in node.imports:
      result.add(newIdentNode(item))

  of xnkImport:
    result = newNimNode(nnkImportStmt)
    result.add(newIdentNode(node.importPath))
    if node.importAlias.isSome:
      result.add(newIdentNode("as"))
      result.add(newIdentNode(node.importAlias.get))

  of xnkExport:
    result = newNimNode(nnkExportStmt)
    result.add(convertXLangToNim(node.exportedDecl))

  of xnkExportStmt:
    result = newNimNode(nnkExportStmt)
    for item in node.exports:
      result.add(newIdentNode(item))

  of xnkFromImportStmt:
    result = newNimNode(nnkFromStmt)
    result.add(newIdentNode(node.module))
    let importList = newNimNode(nnkImportStmt)
    for item in node.imports:
      importList.add(newIdentNode(item))
    result.add(importList)

  of xnkGenericParam:
    result = newNimNode(nnkGenericParams)
    let identDefs = newNimNode(nnkIdentDefs)
    identDefs.add(newIdentNode(node.name))
    if node.bounds.len > 0:
      for bound in node.bounds:
        identDefs.add(convertToNimAST(bound))
    else:
      identDefs.add(newEmptyNode())
    identDefs.add(newEmptyNode())  # No default value
    result.add(identDefs)

  of xnkIdentifier:
    result = newIdentNode(node.name)

  of xnkComment:
    if node.isDocComment:
      result = newCommentStmt("## " & node.commentText)
    else:
      result = newCommentStmt("# " & node.commentText)

  of xnkIntLit, xnkFloatLit, xnkStringLit, xnkCharLit:
    result = newLit(parseExpr(node.literalValue))


  of xnkBoolLit:
    result = newLit(node.boolValue)

  of xnkNilLit:
    result = newNilLit()

  of xnkTemplateDef, xnkMacroDef:
    result = if node.kind == xnkTemplateDef: newNimNode(nnkTemplateDef) else: newNimNode(nnkMacroDef)
    result.add(newIdentNode(node.name))
    result.add(newEmptyNode())  # Pattern matching (not implemented here)
    result.add(newEmptyNode())  # Generic params (not implemented here)
    let formalParams = newNimNode(nnkFormalParams)
    formalParams.add(newEmptyNode())  # Return type (templates/macros don't have explicit return types)
    for param in node.params:
      formalParams.add(convertToNimAST(param))
    result.add(formalParams)
    result.add(newEmptyNode())  # Pragmas (not implemented here)
    result.add(newEmptyNode())  # Reserved slot for future use
    result.add(convertToNimAST(node.body))
    if node.isExported:
      result = newNimNode(nnkPostfix).add(newIdentNode("*"), result)

  of xnkPragma:
    result = newNimNode(nnkPragma)
    for pragma in node.pragmas:
      result.add(convertToNimAST(pragma))

  of xnkStaticStmt:
    result = newNimNode(nnkStaticStmt)
    result.add(convertToNimAST(node.staticBody))

  of xnkDeferStmt:
    result = newNimNode(nnkDeferStmt)
    result.add(convertToNimAST(node.staticBody))

  of xnkAsmStmt:
    result = newNimNode(nnkAsmStmt)
    result.add(newStrLitNode(node.asmCode))

  of xnkDistinctTypeDef:
    result = newNimNode(nnkTypeSection)
    let typeDef = newNimNode(nnkTypeDef)
    typeDef.add(newIdentNode(node.distinctName))
    typeDef.add(newEmptyNode())  # No generic params
    let distinctTy = newNimNode(nnkDistinctTy)
    distinctTy.add(convertToNimAST(node.baseType))
    typeDef.add(distinctTy)
    result.add(typeDef)

  of xnkConceptDef:
    result = newNimNode(nnkTypeSection)
    let typeDef = newNimNode(nnkTypeDef)
    typeDef.add(newIdentNode(node.conceptName))
    typeDef.add(newEmptyNode())  # No generic params
    let conceptTy = newNimNode(nnkConceptTy)
    conceptTy.add(newEmptyNode())  # No determinants
    conceptTy.add(convertToNimAST(node.conceptBody))
    typeDef.add(conceptTy)
    result.add(typeDef)

  of xnkMixinStmt:
    result = newNimNode(nnkMixinStmt)
    for name in node.mixinNames:
      result.add(newIdentNode(name))

  of xnkBindStmt:
    result = newNimNode(nnkBindStmt)
    for name in node.bindNames:
      result.add(newIdentNode(name))

  of xnkTupleConstr:
    result = newNimNode(nnkTupleConstr)
    for elem in node.tupleElements:
      result.add(convertToNimAST(elem))

  of xnkTupleUnpacking:
    result = newNimNode(nnkVarTuple)
    for target in node.unpackTargets:
      result.add(convertToNimAST(target))
    result.add(newEmptyNode())  # No type
    result.add(convertToNimAST(node.unpackExpr))

  of xnkClassDecl, xnkStructDecl:
    result = newNimNode(nnkTypeSection)
    let objType = newNimNode(nnkObjectTy)
    objType.add(newEmptyNode())
    
    let inheritanceList = newNimNode(nnkOfInherit)
    for baseType in node.baseTypes:
      inheritanceList.add(convertXLangToNim(baseType))
    objType.add(inheritanceList)

    let recList = newNimNode(nnkRecList)
    for member in node.members:
      recList.add(convertXLangToNim(member))
    objType.add(recList)

    result.add(
      newNimNode(nnkTypeDef).add(
        newIdentNode(node.typeName),
        newEmptyNode(),
        newNimNode(nnkRefTy).add(objType)
      )
    )



  of xnkFile:
    result = newStmtList()
    for decl in node.moduleDecls:
      result.add(convertXLangToNim(decl))
  
  of xnkModule:
    # Nim doesn't have a direct equivalent to Java's module system
    # We'll create a comment node to preserve the information
    result = newCommentStmtNode("Module: " & node.moduleName)
    for stmt in node.moduleBody:
      result.add(convertXLangToNim(stmt))
  
  of xnkNamespace:
    # Nim doesn't have namespaces, but we can use a comment to preserve the information
    result = newCommentStmtNode("Namespace: " & node.namespaceName)
    for stmt in node.namespaceBody:
      result.add(convertXLangToNim(stmt))

  of xnkFuncDecl, xnkMethodDecl:
    let params = newNimNode(nnkFormalParams)
    if node.returnType.isSome:
      params.add(convertXLangToNim(node.returnType.get))
    else:
      params.add(newEmptyNode())
    for param in node.params:
      params.add(convertXLangToNim(param))

    result = newProc(
      name = newIdentNode(node.funcName),
      params = params,
      body = convertXLangToNim(node.body),
      procType = nnkProcDef
    )
    if node.isAsync:
      result.addPragma(newIdentNode("async"))



  of xnkEnumDecl:
    result = newNimNode(nnkTypeSection)
    let enumTy = newNimNode(nnkEnumTy)
    enumTy.add(newEmptyNode())
    for member in node.enumMembers:
      if member.value.isSome:
        enumTy.add(newNimNode(nnkEnumFieldDef).add(
          newIdentNode(member.name),
          convertXLangToNim(member.value.get)
        ))
      else:
        enumTy.add(newIdentNode(member.name))
    result.add(
      newNimNode(nnkTypeDef).add(
        newIdentNode(node.enumName),
        newEmptyNode(),
        enumTy
      )
    )

  of xnkInterfaceDecl:
    # Nim doesn't have interfaces, but we can use concepts
    result = newNimNode(nnkTypeSection)
    let conceptDef = newNimNode(nnkTypeDef)
    conceptDef.add(newIdentNode(node.typeName))
    conceptDef.add(newEmptyNode())
    let conceptTy = newNimNode(nnkConceptTy)
    for meth in node.members:
      conceptTy.add(convertXLangToNim(meth))
    conceptDef.add(conceptTy)
    result.add(conceptDef)

  of xnkVarDecl:
    result = newNimNode(nnkVarSection)
    let identDefs = newNimNode(nnkIdentDefs)
    identDefs.add(newIdentNode(node.declName))
    if node.declType.isSome:
      identDefs.add(convertXLangToNim(node.declType.get))
    else:
      identDefs.add(newEmptyNode())
    if node.initializer.isSome:
      identDefs.add(convertXLangToNim(node.initializer.get))
    else:
      identDefs.add(newEmptyNode())
    result.add(identDefs)

  of xnkLetDecl:
    result = newNimNode(nnkLetSection)
    let identDefs = newNimNode(nnkIdentDefs)
    identDefs.add(newIdentNode(node.declName))
    if node.declType.isSome:
      identDefs.add(convertXLangToNim(node.declType.get))
    else:
      identDefs.add(newEmptyNode())
    if node.initializer.isSome:
      identDefs.add(convertXLangToNim(node.initializer.get))
    else:
      identDefs.add(newEmptyNode())
    result.add(identDefs)

  of xnkConstDecl:
    result = newNimNode(nnkConstSection)
    let identDefs = newNimNode(nnkIdentDefs)
    identDefs.add(newIdentNode(node.declName))
    if node.declType.isSome:
      identDefs.add(convertXLangToNim(node.declType.get))
    else:
      identDefs.add(newEmptyNode())
    if node.initializer.isSome:
      identDefs.add(convertXLangToNim(node.initializer.get))
    else:
      identDefs.add(newEmptyNode())
    result.add(identDefs)

  of xnkUsingStmt:
    result = newNimNode(nnkUsingStmt)
    result.add(convertToNimAST(node.usingExpr))
    result.add(convertToNimAST(node.usingBody))
  # else:
    # For constructs that don't have a direct equivalent or haven't been implemented
    # raise newException(ValueError, "Unsupported XLang node kind: " & $node.kind)



proc convertXLangASTToNimAST*(xlangAST: XLangAST): NimNode =
  result = newStmtList()
  for node in xlangAST:
    result.add(convertToNimAST(node))

# Example usage
when isMainModule:
  let xlangAST: XLangAST = @[
    XLangNode(kind: xnkFile, fileName: "example.nim", declarations: @[
      XLangNode(kind: xnkFuncDecl, funcName: "main", params: @[], returnType: none(XLangNode),
        body: XLangNode(kind: xnkBlockStmt, body: @[
          XLangNode(kind: xnkCallExpr, callee: XLangNode(kind: xnkIdentifier, name: "echo"),
            args: @[XLangNode(kind: xnkStringLit, value: "Hello, World!")])
        ])
      )
    ])
  ]

  let nimAST = convertToNimAST(xlangAST)
  echo nimAST.repr