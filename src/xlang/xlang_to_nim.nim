## XLang AST to Nim AST Converter
##
## This module provides comprehensive conversion from XLang intermediate AST
## to Nim AST (compile-time macros representation).
##
## Handles all XLang node kinds and converts them to idiomatic Nim constructs.

import macros, options, strutils
import xlang_types

proc convertXLangToNim*(node: XLangNode): NimNode

# Forward declarations for mutual recursion
proc convertType(node: XLangNode): NimNode
proc convertExpression(node: XLangNode): NimNode
proc convertStatement(node: XLangNode): NimNode
proc convertDeclaration(node: XLangNode): NimNode

# =============================================================================
# Type Conversions
# =============================================================================

proc convertType(node: XLangNode): NimNode =
  case node.kind
  of xnkNamedType:
    result = newIdentNode(node.typeName)

  of xnkArrayType:
    result = newNimNode(nnkBracketExpr)
    result.add(newIdentNode("array"))
    if node.arraySize.isSome:
      result.add(convertExpression(node.arraySize.get))
    result.add(convertType(node.elementType))

  of xnkMapType:
    result = newNimNode(nnkBracketExpr)
    result.add(newIdentNode("Table"))
    result.add(convertType(node.keyType))
    result.add(convertType(node.valueType))

  of xnkFuncType:
    result = newNimNode(nnkProcTy)
    let params = newNimNode(nnkFormalParams)
    if node.funcReturnType.isSome:
      params.add(convertType(node.funcReturnType.get))
    else:
      params.add(newEmptyNode())
    for param in node.funcParams:
      params.add(convertXLangToNim(param))
    result.add(params)
    result.add(newEmptyNode())  # pragmas

  of xnkPointerType:
    result = newNimNode(nnkPtrTy)
    result.add(convertType(node.referentType))

  of xnkReferenceType:
    result = newNimNode(nnkRefTy)
    result.add(convertType(node.referentType))

  of xnkGenericType:
    result = newNimNode(nnkBracketExpr)
    result.add(newIdentNode(node.genericTypeName))
    for arg in node.genericArgs:
      result.add(convertType(arg))

  of xnkUnionType:
    # Nim doesn't have union types, use variant object or concept
    result = newCommentStmtNode("Union type - needs manual conversion")

  of xnkIntersectionType:
    # Nim doesn't have intersection types directly
    result = newCommentStmtNode("Intersection type - needs manual conversion")

  else:
    result = newIdentNode("UnhandledType")

# =============================================================================
# Expression Conversions
# =============================================================================

proc convertExpression(node: XLangNode): NimNode =
  case node.kind
  of xnkIntLit:
    result = newLit(node.literalValue.parseInt)

  of xnkFloatLit:
    result = newLit(node.literalValue.parseFloat)

  of xnkStringLit:
    result = newLit(node.literalValue)

  of xnkCharLit:
    result = newLit(node.literalValue[0])

  of xnkBoolLit:
    result = newLit(node.boolValue)

  of xnkNoneLit:
    result = newNilLit()

  of xnkIdentifier:
    result = newIdentNode(node.identName)

  of xnkBinaryExpr:
    result = newNimNode(nnkInfix)
    result.add(newIdentNode(node.binaryOp))
    result.add(convertExpression(node.binaryLeft))
    result.add(convertExpression(node.binaryRight))

  of xnkUnaryExpr:
    result = newNimNode(nnkPrefix)
    result.add(newIdentNode(node.unaryOp))
    result.add(convertExpression(node.unaryOperand))

  of xnkTernaryExpr:
    # Nim doesn't have ternary, convert to if expression
    result = newNimNode(nnkIfExpr)
    let branch = newNimNode(nnkElifExpr)
    branch.add(convertExpression(node.ternaryCondition))
    branch.add(convertExpression(node.ternaryThen))
    result.add(branch)
    let elseBranch = newNimNode(nnkElseExpr)
    elseBranch.add(convertExpression(node.ternaryElse))
    result.add(elseBranch)

  of xnkCallExpr:
    result = newNimNode(nnkCall)
    result.add(convertExpression(node.callee))
    for arg in node.args:
      result.add(convertExpression(arg))

  of xnkIndexExpr:
    result = newNimNode(nnkBracketExpr)
    result.add(convertExpression(node.indexExpr))
    for arg in node.indexArgs:
      result.add(convertExpression(arg))

  of xnkSliceExpr:
    result = newNimNode(nnkInfix)
    result.add(newIdentNode(".."))
    if node.sliceStart.isSome:
      result.add(convertExpression(node.sliceStart.get))
    else:
      result.add(newLit(0))
    if node.sliceEnd.isSome:
      result.add(convertExpression(node.sliceEnd.get))
    else:
      result.add(newIdentNode("^1"))

  of xnkMemberAccessExpr:
    result = newNimNode(nnkDotExpr)
    result.add(convertExpression(node.memberExpr))
    result.add(newIdentNode(node.memberName))

  of xnkLambdaExpr:
    result = newNimNode(nnkLambda)
    let params = newNimNode(nnkFormalParams)
    params.add(newEmptyNode())  # return type
    for param in node.lambdaParams:
      params.add(convertXLangToNim(param))
    result.add(newEmptyNode())  # name
    result.add(newEmptyNode())  # term rewriting
    result.add(newEmptyNode())  # generic params
    result.add(params)
    result.add(newEmptyNode())  # pragmas
    result.add(newEmptyNode())  # reserved
    result.add(convertStatement(node.lambdaBody))

  of xnkListExpr:
    result = newNimNode(nnkBracket)
    for elem in node.elements:
      result.add(convertExpression(elem))

  of xnkSetExpr:
    result = newNimNode(nnkCurly)
    for elem in node.elements:
      result.add(convertExpression(elem))

  of xnkTupleExpr:
    result = newNimNode(nnkTupleConstr)
    for elem in node.elements:
      result.add(convertExpression(elem))

  of xnkDictExpr:
    result = newNimNode(nnkTableConstr)
    for i in 0 ..< node.keys.len:
      let pair = newNimNode(nnkExprColonExpr)
      pair.add(convertExpression(node.keys[i]))
      pair.add(convertExpression(node.values[i]))
      result.add(pair)

  of xnkComprehensionExpr:
    # List comprehensions need to be converted to seq operations
    result = newCommentStmtNode("List comprehension - needs manual conversion")

  of xnkAwaitExpr:
    result = newNimNode(nnkCommand)
    result.add(newIdentNode("await"))
    result.add(convertExpression(node.awaitExpr))

  of xnkYieldExpr:
    result = newNimNode(nnkYieldStmt)
    if node.yieldExpr.isSome:
      result.add(convertExpression(node.yieldExpr.get))
    else:
      result.add(newEmptyNode())

  else:
    result = newIdentNode("UnhandledExpression")

# =============================================================================
# Statement Conversions
# =============================================================================

proc convertStatement(node: XLangNode): NimNode =
  case node.kind
  of xnkBlockStmt:
    result = newStmtList()
    for stmt in node.blockBody:
      result.add(convertXLangToNim(stmt))

  of xnkIfStmt:
    result = newNimNode(nnkIfStmt)
    let branch = newNimNode(nnkElifBranch)
    branch.add(convertExpression(node.ifCondition))
    branch.add(convertStatement(node.ifBody))
    result.add(branch)
    if node.elseBody.isSome:
      let elseBranch = newNimNode(nnkElse)
      elseBranch.add(convertStatement(node.elseBody.get))
      result.add(elseBranch)

  of xnkSwitchStmt:
    result = newNimNode(nnkCaseStmt)
    result.add(convertExpression(node.switchExpr))
    for caseNode in node.switchCases:
      if caseNode.kind == xnkCaseClause:
        let ofBranch = newNimNode(nnkOfBranch)
        for val in caseNode.caseValues:
          ofBranch.add(convertExpression(val))
        ofBranch.add(convertStatement(caseNode.caseBody))
        result.add(ofBranch)
      elif caseNode.kind == xnkDefaultClause:
        let elseBranch = newNimNode(nnkElse)
        elseBranch.add(convertStatement(caseNode.defaultBody))
        result.add(elseBranch)

  of xnkForStmt:
    if node.forInit.isSome and node.forCond.isSome and node.forIncrement.isSome:
      # C-style for loop - convert to while
      result = newStmtList()
      result.add(convertStatement(node.forInit.get))
      let whileStmt = newNimNode(nnkWhileStmt)
      whileStmt.add(convertExpression(node.forCond.get))
      let body = newStmtList()
      body.add(convertStatement(node.forBody))
      body.add(convertStatement(node.forIncrement.get))
      whileStmt.add(body)
      result.add(whileStmt)
    else:
      result = newCommentStmtNode("For loop - incomplete conversion")

  of xnkWhileStmt:
    result = newNimNode(nnkWhileStmt)
    result.add(convertExpression(node.whileCondition))
    result.add(convertStatement(node.whileBody))

  of xnkDoWhileStmt:
    # Convert do-while to while true with break
    result = newStmtList()
    let whileStmt = newNimNode(nnkWhileStmt)
    whileStmt.add(newLit(true))
    let body = newStmtList()
    body.add(convertStatement(node.whileBody))
    let ifStmt = newNimNode(nnkIfStmt)
    let branch = newNimNode(nnkElifBranch)
    branch.add(newNimNode(nnkPrefix).add(
      newIdentNode("not"),
      convertExpression(node.whileCondition)
    ))
    branch.add(newNimNode(nnkBreakStmt).add(newEmptyNode()))
    ifStmt.add(branch)
    body.add(ifStmt)
    whileStmt.add(body)
    result.add(whileStmt)

  of xnkForeachStmt:
    result = newNimNode(nnkForStmt)
    result.add(convertExpression(node.foreachVar))
    result.add(convertExpression(node.foreachIter))
    result.add(convertStatement(node.foreachBody))

  of xnkTryStmt:
    result = newNimNode(nnkTryStmt)
    result.add(convertStatement(node.tryBody))
    for catchClause in node.catchClauses:
      result.add(convertXLangToNim(catchClause))
    if node.finallyClause.isSome:
      let finallyBranch = newNimNode(nnkFinally)
      finallyBranch.add(convertStatement(node.finallyClause.get))
      result.add(finallyBranch)

  of xnkCatchStmt:
    result = newNimNode(nnkExceptBranch)
    if node.catchType.isSome:
      result.add(convertType(node.catchType.get))
    else:
      result.add(newEmptyNode())
    result.add(convertStatement(node.catchBody))

  of xnkFinallyStmt:
    result = newNimNode(nnkFinally)
    result.add(convertStatement(node.finallyBody))

  of xnkReturnStmt:
    result = newNimNode(nnkReturnStmt)
    if node.returnExpr.isSome:
      result.add(convertExpression(node.returnExpr.get))
    else:
      result.add(newEmptyNode())

  of xnkYieldStmt:
    result = newNimNode(nnkYieldStmt)
    result.add(convertExpression(node.yieldStmt))

  of xnkBreakStmt:
    result = newNimNode(nnkBreakStmt)
    if node.label.isSome:
      result.add(newIdentNode(node.label.get))
    else:
      result.add(newEmptyNode())

  of xnkContinueStmt:
    result = newNimNode(nnkContinueStmt)
    if node.label.isSome:
      result.add(newIdentNode(node.label.get))
    else:
      result.add(newEmptyNode())

  of xnkThrowStmt:
    result = newNimNode(nnkRaiseStmt)
    result.add(convertExpression(node.throwExpr))

  of xnkAssertStmt:
    result = newNimNode(nnkCommand)
    result.add(newIdentNode("assert"))
    result.add(convertExpression(node.assertCond))
    if node.assertMsg.isSome:
      result.add(convertExpression(node.assertMsg.get))

  of xnkWithStmt:
    # With statement - needs context-specific conversion
    result = newCommentStmtNode("With statement - needs manual conversion")

  of xnkPassStmt:
    result = newNimNode(nnkDiscardStmt)
    result.add(newEmptyNode())

  of xnkDeferStmt:
    result = newNimNode(nnkDefer)
    result.add(convertStatement(node.staticBody))

  of xnkStaticStmt:
    result = newNimNode(nnkStaticStmt)
    result.add(convertStatement(node.staticBody))

  of xnkAsmStmt:
    result = newNimNode(nnkAsmStmt)
    result.add(newEmptyNode())  # pragmas
    result.add(newStrLitNode(node.asmCode))

  of xnkUsingStmt:
    result = newNimNode(nnkBlockStmt)
    result.add(newEmptyNode())  # no label
    let body = newStmtList()
    body.add(convertExpression(node.usingExpr))
    body.add(convertStatement(node.usingBody))
    result.add(body)

  else:
    # Try as expression
    result = convertExpression(node)

# =============================================================================
# Declaration Conversions
# =============================================================================

proc convertDeclaration(node: XLangNode): NimNode =
  case node.kind
  of xnkFuncDecl, xnkMethodDecl:
    var paramSeq: seq[NimNode] = @[]
    if node.returnType.isSome:
      paramSeq.add(convertType(node.returnType.get))
    else:
      paramSeq.add(newEmptyNode())
    for param in node.params:
      paramSeq.add(convertXLangToNim(param))

    result = newProc(
      name = newIdentNode(node.funcName),
      params = paramSeq,
      body = convertStatement(node.body),
      procType = if node.kind == xnkFuncDecl: nnkProcDef else: nnkMethodDef
    )
    if node.isAsync:
      result.addPragma(newIdentNode("async"))

  of xnkClassDecl, xnkStructDecl:
    result = newNimNode(nnkTypeSection)
    let objType = newNimNode(nnkObjectTy)
    objType.add(newEmptyNode())  # no pragmas

    let inheritanceList = newNimNode(nnkOfInherit)
    for baseType in node.baseTypes:
      inheritanceList.add(convertType(baseType))
    objType.add(inheritanceList)

    let recList = newNimNode(nnkRecList)
    for member in node.members:
      recList.add(convertXLangToNim(member))
    objType.add(recList)

    result.add(
      newNimNode(nnkTypeDef).add(
        newIdentNode(node.typeNameDecl),
        newEmptyNode(),
        newNimNode(nnkRefTy).add(objType)
      )
    )

  of xnkInterfaceDecl:
    # Convert to concept
    result = newNimNode(nnkTypeSection)
    let conceptDef = newNimNode(nnkTypeDef)
    conceptDef.add(newIdentNode(node.typeNameDecl))
    conceptDef.add(newEmptyNode())
    let conceptTy = newNimNode(nnkObjectTy)  # Use object type for concepts
    conceptTy.add(newEmptyNode())  # no generic params
    conceptTy.add(newEmptyNode())  # no inherits
    let recList = newNimNode(nnkRecList)
    for member in node.members:
      recList.add(convertXLangToNim(member))
    conceptTy.add(recList)
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
          convertExpression(member.value.get)
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

  of xnkVarDecl:
    result = newNimNode(nnkVarSection)
    let identDefs = newNimNode(nnkIdentDefs)
    identDefs.add(newIdentNode(node.declName))
    if node.declType.isSome:
      identDefs.add(convertType(node.declType.get))
    else:
      identDefs.add(newEmptyNode())
    if node.initializer.isSome:
      identDefs.add(convertExpression(node.initializer.get))
    else:
      identDefs.add(newEmptyNode())
    result.add(identDefs)

  of xnkLetDecl:
    result = newNimNode(nnkLetSection)
    let identDefs = newNimNode(nnkIdentDefs)
    identDefs.add(newIdentNode(node.declName))
    if node.declType.isSome:
      identDefs.add(convertType(node.declType.get))
    else:
      identDefs.add(newEmptyNode())
    if node.initializer.isSome:
      identDefs.add(convertExpression(node.initializer.get))
    else:
      identDefs.add(newEmptyNode())
    result.add(identDefs)

  of xnkConstDecl:
    result = newNimNode(nnkConstSection)
    let identDefs = newNimNode(nnkIdentDefs)
    identDefs.add(newIdentNode(node.declName))
    if node.declType.isSome:
      identDefs.add(convertType(node.declType.get))
    else:
      identDefs.add(newEmptyNode())
    if node.initializer.isSome:
      identDefs.add(convertExpression(node.initializer.get))
    else:
      identDefs.add(newEmptyNode())
    result.add(identDefs)

  of xnkTypeDecl:
    result = newNimNode(nnkTypeSection)
    result.add(
      newNimNode(nnkTypeDef).add(
        newIdentNode(node.typeDefName),
        newEmptyNode(),
        convertType(node.typeDefBody)
      )
    )

  of xnkPropertyDecl:
    # Convert property to getter/setter procs
    result = newStmtList()
    if node.getter.isSome:
      let getterProc = newProc(
        name = newIdentNode(node.propName),
        params = [convertType(node.propType)],
        body = convertStatement(node.getter.get),
        procType = nnkProcDef
      )
      result.add(getterProc)
    if node.setter.isSome:
      let setterProc = newProc(
        name = newIdentNode(node.propName & "="),
        params = [
          newEmptyNode(),
          newIdentDefs(newIdentNode("value"), convertType(node.propType))
        ],
        body = convertStatement(node.setter.get),
        procType = nnkProcDef
      )
      result.add(setterProc)

  of xnkFieldDecl:
    result = newIdentDefs(
      newIdentNode(node.fieldName),
      convertType(node.fieldType)
    )
    if node.fieldInitializer.isSome:
      result.add(convertExpression(node.fieldInitializer.get))
    else:
      result.add(newEmptyNode())

  of xnkConstructorDecl:
    result = newProc(
      name = newIdentNode("new"),
      params = [newIdentNode("self")],
      body = convertStatement(node.constructorBody),
      procType = nnkProcDef
    )
    for param in node.constructorParams:
      result.params.add(convertXLangToNim(param))

  of xnkDestructorDecl:
    result = newProc(
      name = newIdentNode("=destroy"),
      params = [newEmptyNode(), newIdentDefs(newIdentNode("self"), newIdentNode("typedesc"))],
      body = convertStatement(node.destructorBody),
      procType = nnkProcDef
    )

  of xnkDelegateDecl:
    result = newNimNode(nnkTypeSection)
    let funcTy = newNimNode(nnkProcTy)
    let formalParams = newNimNode(nnkFormalParams)
    if node.delegateReturnType.isSome:
      formalParams.add(convertType(node.delegateReturnType.get))
    else:
      formalParams.add(newEmptyNode())
    for param in node.delegateParams:
      formalParams.add(convertXLangToNim(param))
    funcTy.add(formalParams)
    funcTy.add(newEmptyNode())  # pragmas
    result.add(
      newNimNode(nnkTypeDef).add(
        newIdentNode(node.delegateName),
        newEmptyNode(),
        funcTy
      )
    )

  of xnkTemplateDef, xnkMacroDef:
    result = if node.kind == xnkTemplateDef: newNimNode(nnkTemplateDef) else: newNimNode(nnkMacroDef)
    result.add(newIdentNode(node.name))
    result.add(newEmptyNode())  # pattern
    result.add(newEmptyNode())  # generic params
    let formalParams = newNimNode(nnkFormalParams)
    formalParams.add(newEmptyNode())  # return type
    for param in node.tplparams:
      formalParams.add(convertXLangToNim(param))
    result.add(formalParams)
    result.add(newEmptyNode())  # pragmas
    result.add(newEmptyNode())  # reserved
    result.add(convertStatement(node.tmplbody))
    if node.isExported:
      result = newNimNode(nnkPostfix).add(newIdentNode("*"), result)

  of xnkDistinctTypeDef:
    result = newNimNode(nnkTypeSection)
    let typeDef = newNimNode(nnkTypeDef)
    typeDef.add(newIdentNode(node.distinctName))
    typeDef.add(newEmptyNode())
    let distinctTy = newNimNode(nnkDistinctTy)
    distinctTy.add(convertType(node.baseType))
    typeDef.add(distinctTy)
    result.add(typeDef)

  of xnkConceptDef:
    result = newNimNode(nnkTypeSection)
    let typeDef = newNimNode(nnkTypeDef)
    typeDef.add(newIdentNode(node.conceptName))
    typeDef.add(newEmptyNode())
    let conceptTy = newNimNode(nnkObjectTy)  # Use object type for concepts
    conceptTy.add(newEmptyNode())
    conceptTy.add(newEmptyNode())
    conceptTy.add(convertStatement(node.conceptBody))
    typeDef.add(conceptTy)
    result.add(typeDef)

  else:
    result = newCommentStmtNode("Unhandled declaration: " & $node.kind)

# =============================================================================
# Other Node Conversions
# =============================================================================

proc convertOther(node: XLangNode): NimNode =
  case node.kind
  of xnkImport:
    result = newNimNode(nnkImportStmt)
    result.add(newIdentNode(node.importPath))
    if node.importAlias.isSome:
      result = newNimNode(nnkImportExceptStmt)
      result.add(newIdentNode(node.importPath))
      result.add(newNimNode(nnkPrefix).add(
        newIdentNode("as"),
        newIdentNode(node.importAlias.get)
      ))

  of xnkExport:
    result = newNimNode(nnkExportStmt)
    result.add(convertXLangToNim(node.exportedDecl))

  of xnkComment:
    if node.isDocComment:
      result = newCommentStmtNode("## " & node.commentText)
    else:
      result = newCommentStmtNode("# " & node.commentText)

  of xnkParameter:
    result = newIdentDefs(
      newIdentNode(node.paramName),
      convertType(node.paramType)
    )
    if node.defaultValue.isSome:
      result.add(convertExpression(node.defaultValue.get))
    else:
      result.add(newEmptyNode())

  of xnkArgument:
    if node.argName.isSome:
      result = newNimNode(nnkExprEqExpr)
      result.add(newIdentNode(node.argName.get))
      result.add(convertExpression(node.argValue))
    else:
      result = convertExpression(node.argValue)

  of xnkGenericParameter:
    result = newNimNode(nnkIdentDefs)
    result.add(newIdentNode(node.genericParamName))
    if node.genericParamConstraints.len > 0:
      for constraint in node.genericParamConstraints:
        result.add(convertType(constraint))
    else:
      result.add(newEmptyNode())
    result.add(newEmptyNode())

  of xnkAttribute, xnkDecorator:
    result = newNimNode(nnkPragma)
    result.add(convertExpression(node.decoratorExpr))

  of xnkPragma:
    result = newNimNode(nnkPragma)
    for pragma in node.pragmas:
      result.add(convertXLangToNim(pragma))

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
      result.add(convertExpression(elem))

  of xnkTupleUnpacking:
    result = newNimNode(nnkVarTuple)
    for target in node.unpackTargets:
      result.add(convertExpression(target))
    result.add(newEmptyNode())
    result.add(convertExpression(node.unpackExpr))

  else:
    result = newCommentStmtNode("Unhandled node: " & $node.kind)

# =============================================================================
# Main Dispatcher
# =============================================================================

proc convertXLangToNim*(node: XLangNode): NimNode =
  case node.kind
  # Top-level containers
  of xnkFile:
    result = newStmtList()
    for decl in node.moduleDecls:
      result.add(convertXLangToNim(decl))

  of xnkModule:
    result = newCommentStmtNode("Module: " & node.moduleName)
    for stmt in node.moduleBody:
      result.add(convertXLangToNim(stmt))

  of xnkNamespace:
    result = newCommentStmtNode("Namespace: " & node.namespaceName)
    for stmt in node.namespaceBody:
      result.add(convertXLangToNim(stmt))

  # Types
  of xnkNamedType, xnkArrayType, xnkMapType, xnkFuncType, xnkPointerType,
     xnkReferenceType, xnkGenericType, xnkUnionType, xnkIntersectionType:
    result = convertType(node)

  # Expressions
  of xnkIntLit, xnkFloatLit, xnkStringLit, xnkCharLit, xnkBoolLit, xnkNoneLit,
     xnkIdentifier, xnkBinaryExpr, xnkUnaryExpr, xnkTernaryExpr, xnkCallExpr,
     xnkIndexExpr, xnkSliceExpr, xnkMemberAccessExpr, xnkLambdaExpr,
     xnkListExpr, xnkSetExpr, xnkTupleExpr, xnkDictExpr, xnkComprehensionExpr,
     xnkAwaitExpr, xnkYieldExpr:
    result = convertExpression(node)

  # Statements
  of xnkBlockStmt, xnkIfStmt, xnkSwitchStmt, xnkForStmt, xnkWhileStmt,
     xnkDoWhileStmt, xnkForeachStmt, xnkTryStmt, xnkCatchStmt, xnkFinallyStmt,
     xnkReturnStmt, xnkYieldStmt, xnkBreakStmt, xnkContinueStmt, xnkThrowStmt,
     xnkAssertStmt, xnkWithStmt, xnkPassStmt, xnkDeferStmt, xnkStaticStmt,
     xnkAsmStmt, xnkUsingStmt:
    result = convertStatement(node)

  # Declarations
  of xnkFuncDecl, xnkMethodDecl, xnkClassDecl, xnkStructDecl, xnkInterfaceDecl,
     xnkEnumDecl, xnkVarDecl, xnkLetDecl, xnkConstDecl, xnkTypeDecl,
     xnkPropertyDecl, xnkFieldDecl, xnkConstructorDecl, xnkDestructorDecl,
     xnkDelegateDecl, xnkTemplateDef, xnkMacroDef, xnkDistinctTypeDef,
     xnkConceptDef:
    result = convertDeclaration(node)

  # Other
  of xnkImport, xnkExport, xnkComment, xnkParameter, xnkArgument,
     xnkGenericParameter, xnkAttribute, xnkDecorator, xnkPragma, xnkMixinStmt,
     xnkBindStmt, xnkTupleConstr, xnkTupleUnpacking:
    result = convertOther(node)

  # Catch-all for unhandled cases
  else:
    result = newCommentStmtNode("Unhandled XLang node: " & $node.kind)

# =============================================================================
# Batch Converter
# =============================================================================

proc convertXLangASTToNimAST*(xlangAST: XLangAST): NimNode =
  ## Convert a complete XLang AST to Nim AST
  result = newStmtList()
  for node in xlangAST:
    result.add(convertXLangToNim(node))

# =============================================================================
# Main Module - Standalone Executable
# =============================================================================

when isMainModule:
  import os, json
  
  if paramCount() < 1:
    echo "Usage: xlang_to_nim <xlang.json>"
    quit(1)
  
  let inputFile = paramStr(1)
  let jsonContent = readFile(inputFile)
  let xlangJson = parseJson(jsonContent)
  
  # Parse JSON to XLang nodes (simplified - just convert top-level)
  var xlangAST: seq[XLangNode] = @[]
  
  # For now, output a comment - full implementation would parse JSON to XLangNode
  echo "# Transpiled from XLang"
  echo "# Input: ", inputFile
  echo ""
  echo "# TODO: Complete XLang JSON to XLangNode parser"
