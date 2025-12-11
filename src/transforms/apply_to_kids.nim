# apply_to_kids.nim

import ../../xlangtypes


# recursive, only touch the child nodes
proc visit*(node: var XLangNode, p: proc (x: var XLangNode)) =
  case node.kind:
  of xnkFile:
    for m in node.moduleDecls.mitems: visit m, p
  of xnkModule:
    for body in node.moduleBody.mitems: visit body, p
  of xnkNamespace:
    for item in node.namespaceBody.mitems: visit item, p
  of xnkFuncDecl:
    for item in node.params: visit item, p
    if node.returnType.isSome(): 
      visit node.returnType.get, p
    visit node.body, p
  of xnkMethodDecl:
    if node.receiver.isSome():
      visit node.receiver.get, p
    for item in node.mparams: visit item, p
    if node.mreturnType.isSome(): visit node.mreturnType.get, p
    visit node.mbody, p

  of xnkIteratorDecl:
    for item in node.iteratorParams: visit item, p
    if node.iteratorReturnType.isSome(): visit node.iteratorReturnType.get, p
    visit node.iteratorBody, p
  
  of xnkClassDecl:
    for item in node.baseTypes: visit item, p
    for item in node.members: visit item, p

  of xnkEnumDecl:
    for item in node.enumMembers: visit item, p

  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    if node.declType.isSome(): visit node.declType.get, p
    if node.initializer.isSome(): visit node.initializer.get, p

  of xnkTypeDecl:
    visit node.typeDefBody, p

  of xnkPropertyDecl:
    if node.propType.isSome(): visit node.propType.get, p
    if node.getter.isSome(): visit node.getter.get, p
    if node.setter.isSome(): visit node.setter.get, p

  of xnkFieldDecl:
    visit node.fieldType, p
    if node.fieldInitializer.isSome(): visit node.fieldInitializer.get, p

  
  of xnkConstructorDecl:
    for item in node.constructorParams: visit item, p
    for item in node.constructorInitializers: visit item, p
    visit node.constructorBody, p

  of xnkDestructorDecl:
    visit node.destructorBody, p
  of xnkDelegateDecl:
    for item in node.delegateParams: visit item, p
    if node.delegateReturnType.isSome(): visit node.delegateReturnType.get, p

  of xnkEventDecl:
    visit node.eventType, p
    if node.addAccessor.isSome(): visit node.addAccessor.get, p
    if node.removeAccessor.isSome(): visit node.removeAccessor.get, p
  of xnkAsgn:
    visit node.asgnLeft, p
    visit node.asgnRight, p
  of xnkBlockStmt:
    for item in node.blockBody: visit item, p
  of xnkIfStmt:
    visit node.ifCondition, p
    visit node.ifBody, p
    if node.elseBody.isSome(): visit node.elseBody.get, p
  of xnkSwitchStmt:
    visit node.switchExpr, p
    for item in node.switchCases: visit item, p
  of xnkCaseClause:
    for item in node.caseValues: visit item, p
    visit node.caseBody, p
  of xnkDefaultClause:
    visit node.defaultBody, p
  of xnkForStmt:
    if node.forInit.isSome(): visit node.forInit.get, p
    if node.forCond.isSome(): visit node.forCond.get, p
    if node.forIncrement.isSome(): visit node.forIncrement.get, p
    if node.forBody.isSome(): visit node.forBody.get, p
  of xnkWhileStmt, xnkDoWhileStmt:
    visit node.whileCondition, p
    visit node.whileBody, p
  of xnkForeachStmt:
    visit node.foreachVar, p
    visit node.foreachIter, p
    visit node.foreachBody, p
  of xnkTryStmt:
    visit node.tryBody, p
    for item in node.catchClauses: visit item, p
    if node.finallyClause.isSome(): visit node.finallyClause.get, p
  of xnkCatchStmt:
    if node.catchType.isSome(): visit node.catchType.get, p
    visit node.catchBody, p
  of xnkFinallyStmt:
    visit node.finallyBody, p
  of xnkReturnStmt:
    if node.returnExpr.isSome(): visit node.returnExpr.get, p
  of xnkIteratorYield:
    if node.iteratorYieldValue.isSome(): visit node.iteratorYieldValue.get, p
  of xnkIteratorDelegate:
    visit node.iteratorDelegateExpr, p
  of xnkYieldStmt:
    if node.yieldStmt.isSome(): visit node.yieldStmt.get, p
  of xnkYieldExpr:
    if node.yieldExpr.isSome(): visit node.yieldExpr.get, p
  of xnkYieldFromStmt:
    visit node.yieldFromExpr, p
  of xnkBreakStmt, xnkContinueStmt:
    if node.label.isSome(): visit node.label.get, p
  of xnkThrowStmt:
    visit node.throwExpr, p
  of xnkAssertStmt:
    visit node.assertCond, p
    if node.assertMsg.isSome(): visit node.assertMsg.get, p

  of xnkWithStmt:
    for item in node.items: visit item, p
    visit node.withBody, p
  of xnkWithItem:
    visit node.contextExpr, p
    if node.asExpr.isSome(): visit node.asExpr.get, p
  of xnkResourceStmt:
    for item in node.resourceItems: visit item, p
    visit node.resourceBody, p
  of xnkResourceItem:
    visit node.resourceExpr, p
    if node.resourceVar.isSome(): visit node.resourceVar.get, p
  of xnkPassStmt:
    discard
  of xnkTypeSwitchStmt:
    visit node.typeSwitchExpr, p
    if node.typeSwitchVar.isSome(): visit node.typeSwitchVar.get, p
    for item in node.typeSwitchCases: visit item, p

  of xnkBinaryExpr:
    visit node.binaryLeft, p
    visit node.binaryRight, p
  of xnkUnaryExpr:
    visit node.unaryOperand, p
  of xnkTernaryExpr:
    visit node.ternaryCondition, p
    visit node.ternaryThen, p
    visit node.ternaryElse, p
  of xnkCallExpr:
    visit node.callee, p
    for item in node.args: visit item, p
  of xnkThisCall, xnkBaseCall:
    for item in node.arguments: visit item, p
  of xnkIndexExpr:
    visit node.indexExpr, p
    for item in node.indexArgs: visit item, p
  of xnkSliceExpr:
    visit node.sliceExpr, p
    if node.sliceStart.isSome(): visit node.sliceStart.get, p
    if node.sliceEnd.isSome(): visit node.sliceEnd.get, p
    if node.sliceStep.isSome(): visit node.sliceStep.get, p
  of xnkMemberAccessExpr:
    visit node.memberExpr, p
  of xnkSafeNavigationExpr:
    visit node.safeNavObject, p
  of xnkNullCoalesceExpr:
    visit node.nullCoalesceLeft, p
    visit node.nullCoalesceRight, p
  of xnkLambdaExpr:
    for item in node.lambdaParams: visit item, p
    if node.lambdaReturnType.isSome(): visit node.lambdaReturnType.get, p
    visit node.lambdaBody, p
  of xnkTypeAssertion:
    visit node.assertExpr, p
    visit node.assertType, p
  of xnkLambdaProc:
    for item in node.lambdaProcParams: visit item, p
    if node.lambdaProcReturn.isSome(): visit node.lambdaProcReturn.get, p
    visit node.lambdaProcBody, p
  of xnkArrowFunc:
    for item in node.arrowParams: visit item, p
    visit node.arrowBody, p
    if node.arrowReturnType.isSome(): visit node.arrowReturnType.get, p
  of xnkConceptRequirement:
    for item in node.reqParams: visit item, p
    if node.reqReturn.isSome(): visit node.reqReturn.get, p
  of xnkMethodReference:
    visit node.refObject, p

  of xnkSequenceLiteral, xnkSetLiteral, xnkArrayLiteral, xnkTupleExpr:
    for item in node.elements: visit item, p
  of xnkMapLiteral:
    for item in node.entries: visit item, p
  of xnkListExpr, xnkSetExpr:
    for item in node.legacyElements: visit item, p
  of xnkDictExpr:
    for item in node.legacyEntries: visit item, p
  of xnkArrayLit:
    for item in node.legacyArrayElements: visit item, p
  of xnkDictEntry:
    visit node.key, p
    visit node.value, p
  of xnkComprehensionExpr:
    visit node.compExpr, p
    for item in node.fors: visit item, p
    for item in node.compIf: visit item, p
  of xnkCompFor:
    for item in node.vars: visit item, p
    visit node.iter, p
  of xnkGeneratorExpr:
    visit node.genExpr, p
    for f in node.genFor:
      for v in f.vars: visit v, p
      visit f.iter, p
    for item in node.genIf: visit item, p
  of xnkAwaitExpr:
    visit node.awaitExpr, p
  of xnkStringInterpolation:
    for item in node.interpParts: visit item, p

  of xnkIntLit, xnkFloatLit, xnkStringLit, xnkCharLit, xnkBoolLit, xnkNoneLit, xnkNilLit:
    discard

  of xnkNamedType:
    discard
  of xnkArrayType:
    visit node.elementType, p
    if node.arraySize.isSome(): visit node.arraySize.get, p
  of xnkMapType:
    visit node.keyType, p
    visit node.valueType, p
  of xnkFuncType:
    for item in node.funcParams: visit item, p
    if node.funcReturnType.isSome(): visit node.funcReturnType.get, p
  of xnkPointerType, xnkReferenceType:
    visit node.referentType, p
  of xnkGenericType:
    if node.genericBase.isSome(): visit node.genericBase.get, p
    for item in node.genericArgs: visit item, p
  of xnkUnionType:
    for item in node.unionTypes: visit item, p
  of xnkIntersectionType:
    for item in node.typeMembers: visit item, p
  of xnkDistinctType:
    visit node.distinctBaseType, p

  of xnkIdentifier, xnkComment:
    discard
  of xnkImport:
    discard
  of xnkExport:
    visit node.exportedDecl, p
  of xnkAttribute:
    for item in node.attrArgs: visit item, p
  of xnkGenericParameter:
    for item in node.genericParamConstraints: visit item, p
    for item in node.bounds: visit item, p
  of xnkParameter:
    if node.paramType.isSome(): visit node.paramType.get, p
    if node.defaultValue.isSome(): visit node.defaultValue.get, p
  of xnkArgument:
    visit node.argValue, p
  of xnkDecorator:
    visit node.decoratorExpr, p

  of xnkTemplateDef, xnkMacroDef:
    for item in node.tplparams: visit item, p
    visit node.tmplbody, p
  of xnkPragma:
    for item in node.pragmas: visit item, p
  of xnkStaticStmt, xnkDeferStmt:
    visit node.staticBody, p
  of xnkAsmStmt:
    discard
  of xnkDistinctTypeDef:
    visit node.baseType, p
  of xnkConceptDef:
    visit node.conceptBody, p
  of xnkConceptDecl:
    for item in node.conceptRequirements: visit item, p
  of xnkMixinStmt, xnkBindStmt:
    discard
  of xnkTupleConstr:
    for item in node.tupleElements: visit item, p
  of xnkTupleUnpacking:
    for item in node.unpackTargets: visit item, p
    visit node.unpackExpr, p
  of xnkUsingStmt:
    visit node.usingExpr, p
    visit node.usingBody, p
  of xnkDestructureObj:
    visit node.destructObjSource, p
  of xnkDestructureArray:
    visit node.destructArraySource, p

  of xnkDotExpr:
    visit node.dotBase, p
    visit node.member, p
  of xnkBracketExpr:
    visit node.base, p
    visit node.index, p
  of xnkCaseStmt:
    if node.expr.isSome(): visit node.expr.get, p
    for item in node.branches: visit item, p
    if node.caseElseBody.isSome(): visit node.caseElseBody.get, p
  of xnkRaiseStmt:
    if node.raiseExpr.isSome(): visit node.raiseExpr.get, p
  of xnkImportStmt, xnkExportStmt, xnkFromImportStmt:
    discard
  of xnkDiscardStmt:
    if node.discardExpr.isSome(): visit node.discardExpr.get, p
  of xnkTypeCaseClause:
    visit node.caseType, p
    visit node.typeCaseBody, p

  of xnkModuleDecl:
    for item in node.moduleMembers: visit item, p
  of xnkTypeAlias:
    visit node.aliasTarget, p
  of xnkAbstractDecl:
    for item in node.abstractBody: visit item, p
  of xnkEnumMember:
    if node.enumMemberValue.isSome(): visit node.enumMemberValue.get, p

  of xnkLibDecl:
    for item in node.libBody: visit item, p
  of xnkCFuncDecl:
    for item in node.cfuncParams: visit item, p
    if node.cfuncReturnType.isSome(): visit node.cfuncReturnType.get, p
  of xnkExternalVar:
    visit node.extVarType, p

  of xnkUnlessStmt:
    visit node.unlessCondition, p
    visit node.unlessBody, p
  of xnkUntilStmt:
    visit node.untilCondition, p
    visit node.untilBody, p
  of xnkStaticAssert:
    visit node.staticAssertCondition, p
    if node.staticAssertMessage.isSome(): visit node.staticAssertMessage.get, p
  of xnkSwitchCase:
    for item in node.switchCaseConditions: visit item, p
    visit node.switchCaseBody, p
  of xnkMixinDecl:
    visit node.mixinDeclExpr, p
  of xnkTemplateDecl:
    for item in node.templateParams: visit item, p
    for item in node.templateBody: visit item, p
  of xnkMacroDecl:
    for item in node.macroParams: visit item, p
    visit node.macroBody, p
  of xnkInclude:
    visit node.includeName, p
  of xnkExtend:
    visit node.extendName, p

  of xnkCastExpr:
    visit node.castExpr, p
    visit node.castType, p
  of xnkThisExpr, xnkBaseExpr:
    discard
  of xnkInstanceVar, xnkClassVar, xnkGlobalVar:
    discard
  of xnkProcLiteral:
    visit node.procBody, p
  of xnkProcPointer:
    discard
  of xnkNumberLit, xnkSymbolLit:
    discard
  of xnkDynamicType:
    if node.dynamicConstraint.isSome(): visit node.dynamicConstraint.get, p
  of xnkAbstractType:
    discard
  of xnkFunctionType:
    for item in node.functionTypeParams: visit item, p
    if node.functionTypeReturn.isSome(): visit node.functionTypeReturn.get, p
  of xnkMetadata:
    for item in node.metadataEntries: visit item, p

  of xnkIndexerDecl:
    for item in node.indexerParams: visit item, p
    visit node.indexerType, p
    if node.indexerGetter.isSome(): visit node.indexerGetter.get, p
    if node.indexerSetter.isSome(): visit node.indexerSetter.get, p
  of xnkOperatorDecl:
    for item in node.operatorParams: visit item, p
    visit node.operatorReturnType, p
    visit node.operatorBody, p
  of xnkConversionOperatorDecl:
    visit node.conversionFromType, p
    visit node.conversionToType, p
    visit node.conversionBody, p
  of xnkRefExpr:
    visit node.refExpr, p
  of xnkDefaultExpr:
    if node.defaultType.isSome(): visit node.defaultType.get, p
  of xnkTypeOfExpr:
    visit node.typeOfType, p
  of xnkSizeOfExpr:
    visit node.sizeOfType, p
  of xnkCheckedExpr:
    visit node.checkedExpr, p
  of xnkThrowExpr:
    visit node.throwExprValue, p
  of xnkSwitchExpr:
    visit node.switchExprValue, p
    for item in node.switchExprArms: visit item, p
  of xnkStackAllocExpr:
    visit node.stackAllocType, p
    if node.stackAllocSize.isSome(): visit node.stackAllocSize.get, p
  of xnkImplicitArrayCreation:
    for item in node.implicitArrayElements: visit item, p

  of xnkEmptyStmt:
    discard
  of xnkLabeledStmt:
    visit node.labeledStmt, p
  of xnkGotoStmt:
    discard
  of xnkFixedStmt:
    for item in node.fixedDeclarations: visit item, p
    visit node.fixedBody, p
  of xnkLockStmt:
    visit node.lockExpr, p
    visit node.lockBody, p
  of xnkUnsafeStmt:
    visit node.unsafeBody, p
  of xnkCheckedStmt:
    visit node.checkedBody, p
  of xnkLocalFunctionStmt:
    for item in node.localFuncParams: visit item, p
    if node.localFuncReturnType.isSome(): visit node.localFuncReturnType.get, p
    visit node.localFuncBody, p

  of xnkQualifiedName:
    visit node.qualifiedLeft, p
  of xnkAliasQualifiedName:
    discard
  of xnkGenericName:
    for item in node.genericNameArgs: visit item, p

  of xnkUnknown:
    discard