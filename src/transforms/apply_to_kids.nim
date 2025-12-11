# apply_to_kids.nim

import xlangtypes


# recursive, only touch the child nodes
proc visit*(var node: XLangNode, p: proc (var XLangNode)) =
  p node
  case node.kind:
  of xnkFile:
    for m in node.moduleDecls: visit m, p
  of xnkModule:
    for body in moduleBody: visit body, p
  of xnkNamespace:
    for item in node.namespaceBody: visit item, p
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

  of xnkConstructorDecl:
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
# ... Continue

  #[
    visit node.withBody, p
    visit node.contextExpr, p
    visit node.resourceBody, p
    visit node.resourceExpr, p
    visit node.typeSwitchExpr, p
    visit node.binaryLeft, p
    visit node.binaryRight, p
    visit node.unaryOperand, p
    visit node.ternaryCondition, p
    visit node.ternaryThen, p
    visit node.ternaryElse, p
    visit node.callee, p
    visit node.indexExpr, p
    visit node.sliceExpr, p
    visit node.memberExpr, p
    visit node.safeNavObject, p
    visit node.nullCoalesceLeft, p
    visit node.nullCoalesceRight, p
    visit node.lambdaBody, p
    visit node.assertExpr, p
    visit node.assertType, p
    visit node.lambdaProcBody, p
    visit node.arrowBody, p
    visit node.refObject, p
    visit node.key, p
    visit node.value, p
    visit node.compExpr, p
    visit node.iter, p
    visit node.genExpr, p
    visit node.awaitExpr, p
    visit node.elementType, p
    visit node.keyType, p
    visit node.valueType, p
    visit node.referentType, p
    visit node.distinctBaseType, p
    visit node.exportedDecl, p
    visit node.argValue, p
    visit node.decoratorExpr, p
    visit node.tmplbody, p
    visit node.staticBody, p
    visit node.baseType, p
    visit node.conceptBody, p
    visit node.unpackExpr, p
    visit node.usingExpr, p
    visit node.usingBody, p
    visit node.destructObjSource, p
    visit node.destructArraySource, p
    visit node.dotBase, p
    visit node.member, p
    visit node.base, p
    visit node.index, p
    visit node.caseType, p
    visit node.typeCaseBody, p
    visit node.aliasTarget, p
    visit node.extVarType, p
    visit node.unlessCondition, p
    visit node.unlessBody, p
    visit node.untilCondition, p
    visit node.untilBody, p
    visit node.staticAssertCondition, p
    visit node.switchCaseBody, p
    visit node.mixinDeclExpr, p
    visit node.macroBody, p
    visit node.includeName, p
    visit node.extendName, p
    visit node.castExpr, p
    visit node.castType, p
    visit node.procBody, p
    visit node.indexerType, p
    visit node.operatorReturnType, p
    visit node.operatorBody, p
    visit node.conversionFromType, p
    visit node.conversionToType, p
    visit node.conversionBody, p
    visit node.refExpr, p
    visit node.typeOfType, p
    visit node.sizeOfType, p
    visit node.checkedExpr, p
    visit node.throwExprValue, p
    visit node.switchExprValue, p
    visit node.stackAllocType, p
    visit node.labeledStmt, p
    visit node.fixedBody, p
    visit node.lockExpr, p
    visit node.lockBody, p
    visit node.unsafeBody, p
    visit node.checkedBody, p
    visit node.localFuncBody, p
    visit node.qualifiedLeft, p




    if node.asExpr.isSome(): visit node.asExpr.get, p
    if node.resourceVar.isSome(): visit node.resourceVar.get, p
    if node.typeSwitchVar.isSome(): visit node.typeSwitchVar.get, p
    if node.sliceStart.isSome(): visit node.sliceStart.get, p
    if node.sliceEnd.isSome(): visit node.sliceEnd.get, p
    if node.sliceStep.isSome(): visit node.sliceStep.get, p
    if node.lambdaReturnType.isSome(): visit node.lambdaReturnType.get, p
    if node.lambdaProcReturn.isSome(): visit node.lambdaProcReturn.get, p
    if node.arrowReturnType.isSome(): visit node.arrowReturnType.get, p
    if node.reqReturn.isSome(): visit node.reqReturn.get, p
    if node.arraySize.isSome(): visit node.arraySize.get, p
    if node.funcReturnType.isSome(): visit node.funcReturnType.get, p
    if node.genericBase.isSome(): visit node.genericBase.get, p
    if node.paramType.isSome(): visit node.paramType.get, p
    if node.defaultValue.isSome(): visit node.defaultValue.get, p
    if node.expr.isSome(): visit node.expr.get, p
    if node.caseElseBody.isSome(): visit node.caseElseBody.get, p
    if node.raiseExpr.isSome(): visit node.raiseExpr.get, p
    if node.discardExpr.isSome(): visit node.discardExpr.get, p
    if node.enumMemberValue.isSome(): visit node.enumMemberValue.get, p
    if node.cfuncReturnType.isSome(): visit node.cfuncReturnType.get, p
    if node.staticAssertMessage.isSome(): visit node.staticAssertMessage.get, p
    if node.dynamicConstraint.isSome(): visit node.dynamicConstraint.get, p
    if node.functionTypeReturn.isSome(): visit node.functionTypeReturn.get, p
    if node.indexerGetter.isSome(): visit node.indexerGetter.get, p
    if node.indexerSetter.isSome(): visit node.indexerSetter.get, p
    if node.defaultType.isSome(): visit node.defaultType.get, p
    if node.stackAllocSize.isSome(): visit node.stackAllocSize.get, p
    if node.localFuncReturnType.isSome(): visit node.localFuncReturnType.get, p


    for item in node.items: visit item, p
    for item in node.resourceItems: visit item, p
    for item in node.typeSwitchCases: visit item, p
    for item in node.args: visit item, p
    for item in node.arguments: visit item, p
    for item in node.indexArgs: visit item, p
    for item in node.lambdaParams: visit item, p
    for item in node.lambdaProcParams: visit item, p
    for item in node.arrowParams: visit item, p
    for item in node.reqParams: visit item, p
    for item in node.elements: visit item, p
    for item in node.entries: visit item, p
    for item in node.legacyElements: visit item, p
    for item in node.legacyEntries: visit item, p
    for item in node.legacyArrayElements: visit item, p
    for item in node.fors: visit item, p
    for item in node.compIf: visit item, p
    for item in node.vars: visit item, p
    for item in node.genIf: visit item, p
    for item in node.interpParts: visit item, p
    for item in node.funcParams: visit item, p
    for item in node.genericArgs: visit item, p
    for item in node.unionTypes: visit item, p
    for item in node.typeMembers: visit item, p
    for item in node.attrArgs: visit item, p
    for item in node.genericParamConstraints: visit item, p
    for item in node.bounds: visit item, p
    for item in node.tplparams: visit item, p
    for item in node.pragmas: visit item, p
    for item in node.conceptRequirements: visit item, p
    for item in node.tupleElements: visit item, p
    for item in node.unpackTargets: visit item, p
    for item in node.branches: visit item, p
    for item in node.moduleMembers: visit item, p
    for item in node.abstractBody: visit item, p
    for item in node.libBody: visit item, p
    for item in node.cfuncParams: visit item, p
    for item in node.switchCaseConditions: visit item, p
    for item in node.templateParams: visit item, p
    for item in node.templateBody: visit item, p
    for item in node.macroParams: visit item, p
    for item in node.functionTypeParams: visit item, p
    for item in node.metadataEntries: visit item, p
    for item in node.indexerParams: visit item, p
    for item in node.operatorParams: visit item, p
    for item in node.switchExprArms: visit item, p
    for item in node.implicitArrayElements: visit item, p
    for item in node.fixedDeclarations: visit item, p
    for item in node.localFuncParams: visit item, p
    for item in node.genericNameArgs: visit item, p

    ]#