# apply_to_kids.nim

import xlangtypes
import options



# recursive, only touch the child nodes
proc visit*(node: var XLangNode, p: proc (x: var XLangNode)) =
  # Check for nil node - this should rarely happen and may indicate a bug
  if node.isNil:
    when defined(debug) or defined(verbose):
      stderr.writeLine("[WARNING] visit() called with nil node - this may indicate a parser or transform bug")
    return
  
  p(node)
  case node.kind:
  of xnkFile:
    for m in node.moduleDecls.mitems: visit(m, p)
  of xnkModule:
    for body in node.moduleBody.mitems: visit body, p
  of xnkNamespace:
    for item in node.namespaceBody.mitems: visit item, p
  of xnkFuncDecl:
    for item in node.params.mitems: visit item, p
    if node.returnType.isSome(): 
      visit node.returnType.get, p
    visit node.body, p
  of xnkMethodDecl:
    if node.receiver.isSome():
      visit node.receiver.get, p
    for item in node.mparams.mitems: visit item, p
    if node.mreturnType.isSome(): visit node.mreturnType.get, p
    visit node.mbody, p

  of xnkIteratorDecl:
    for item in node.iteratorParams.mitems: visit item, p
    if node.iteratorReturnType.isSome(): visit node.iteratorReturnType.get, p
    visit node.iteratorBody, p
  
  of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
    for item in node.baseTypes.mitems: visit item, p
    for item in node.members.mitems: visit item, p

  of xnkEnumDecl:
    for item in node.enumMembers.mitems: visit item, p

  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    if node.declType.isSome(): visit node.declType.get, p
    if node.initializer.isSome(): visit node.initializer.get, p

  of xnkTypeDecl:
    visit node.typeDefBody, p

  of xnkExternal_Property:
    if node.extPropType.isSome(): visit node.extPropType.get, p
    if node.extPropGetterBody.isSome(): visit node.extPropGetterBody.get, p
    if node.extPropSetterBody.isSome(): visit node.extPropSetterBody.get, p
    if node.extPropInitializer.isSome(): visit node.extPropInitializer.get, p

  of xnkFieldDecl:
    visit node.fieldType, p
    if node.fieldInitializer.isSome(): visit node.fieldInitializer.get, p

  
  of xnkConstructorDecl:
    for item in node.constructorParams.mitems: visit item, p
    for item in node.constructorInitializers.mitems: visit item, p
    visit node.constructorBody, p

  of xnkDestructorDecl:
    if node.destructorBody.isSome(): visit node.destructorBody.get, p
  of xnkExternal_Delegate:
    for item in node.extDelegateParams.mitems: visit item, p
    if node.extDelegateReturnType.isSome(): visit node.extDelegateReturnType.get, p

  of xnkExternal_Event:
    visit node.extEventType, p
    if node.extEventAdd.isSome(): visit node.extEventAdd.get, p
    if node.extEventRemove.isSome(): visit node.extEventRemove.get, p
  of xnkAsgn:
    visit node.asgnLeft, p
    visit node.asgnRight, p
  of xnkBlockStmt:
    for item in node.blockBody.mitems: visit item, p
  of xnkIfStmt:
    visit node.ifCondition, p
    visit node.ifBody, p
    if node.elseBody.isSome(): visit node.elseBody.get, p
  of xnkSwitchStmt:
    visit node.switchExpr, p
    for item in node.switchCases.mitems: visit item, p
  of xnkCaseClause:
    for item in node.caseValues.mitems: visit item, p
    visit node.caseBody, p
  of xnkDefaultClause:
    visit node.defaultBody, p
  of xnkExternal_ForStmt:
    if node.extForInit.isSome(): visit node.extForInit.get, p
    if node.extForCond.isSome(): visit node.extForCond.get, p
    if node.extForIncrement.isSome(): visit node.extForIncrement.get, p
    if node.extForBody.isSome(): visit node.extForBody.get, p
  of xnkWhileStmt, xnkDoWhileStmt:
    visit node.whileCondition, p
    visit node.whileBody, p
  of xnkForeachStmt:
    visit node.foreachVar, p
    visit node.foreachIter, p
    visit node.foreachBody, p
  of xnkTryStmt:
    visit node.tryBody, p
    for item in node.catchClauses.mitems: visit item, p
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
    discard  # label is Option[string], not a node
  of xnkThrowStmt:
    visit node.throwExpr, p
  of xnkAssertStmt:
    visit node.assertCond, p
    if node.assertMsg.isSome(): visit node.assertMsg.get, p

  of xnkExternal_With:
    for item in node.extWithItems.mitems: visit item, p
    visit node.extWithBody, p
  of xnkWithItem:
    visit node.contextExpr, p
    if node.asExpr.isSome(): visit node.asExpr.get, p
  of xnkExternal_Resource:
    for item in node.extResourceItems.mitems: visit item, p
    visit node.extResourceBody, p
  of xnkResourceItem:
    visit node.resourceExpr, p
    if node.resourceVar.isSome(): visit node.resourceVar.get, p
  of xnkExternal_Pass:
    discard
  of xnkTypeSwitchStmt:
    visit node.typeSwitchExpr, p
    if node.typeSwitchVar.isSome(): visit node.typeSwitchVar.get, p
    for item in node.typeSwitchCases.mitems: visit item, p

  of xnkBinaryExpr:
    visit node.binaryLeft, p
    visit node.binaryRight, p
  of xnkUnaryExpr:
    visit node.unaryOperand, p
  of xnkExternal_Ternary:
    visit node.extTernaryCondition, p
    visit node.extTernaryThen, p
    visit node.extTernaryElse, p
  of xnkCallExpr:
    visit node.callee, p
    for item in node.args.mitems: visit item, p
  of xnkThisCall, xnkBaseCall:
    for item in node.arguments.mitems: visit item, p
  of xnkIndexExpr:
    visit node.indexExpr, p
    for item in node.indexArgs.mitems: visit item, p
  of xnkSliceExpr:
    visit node.sliceExpr, p
    if node.sliceStart.isSome(): visit node.sliceStart.get, p
    if node.sliceEnd.isSome(): visit node.sliceEnd.get, p
    if node.sliceStep.isSome(): visit node.sliceStep.get, p
  of xnkMemberAccessExpr:
    visit node.memberExpr, p
  of xnkExternal_SafeNavigation:
    visit node.extSafeNavObject, p
  of xnkExternal_NullCoalesce:
    visit node.extNullCoalesceLeft, p
    visit node.extNullCoalesceRight, p
  of xnkLambdaExpr:
    for item in node.lambdaParams.mitems: visit item, p
    if node.lambdaReturnType.isSome(): visit node.lambdaReturnType.get, p
    visit node.lambdaBody, p
  of xnkTypeAssertion:
    visit node.assertExpr, p
    visit node.assertType, p
  of xnkLambdaProc:
    for item in node.lambdaProcParams.mitems: visit item, p
    if node.lambdaProcReturn.isSome(): visit node.lambdaProcReturn.get, p
    visit node.lambdaProcBody, p
  of xnkArrowFunc:
    for item in node.arrowParams.mitems: visit item, p
    visit node.arrowBody, p
    if node.arrowReturnType.isSome(): visit node.arrowReturnType.get, p
  of xnkConceptRequirement:
    for item in node.reqParams.mitems: visit item, p
    if node.reqReturn.isSome(): visit node.reqReturn.get, p
  of xnkMethodReference:
    visit node.refObject, p

  of xnkSequenceLiteral, xnkSetLiteral, xnkArrayLiteral, xnkTupleExpr:
    for item in node.elements.mitems: visit item, p
  of xnkMapLiteral:
    for item in node.entries.mitems: visit item, p
  of xnkListExpr, xnkSetExpr:
    for item in node.legacyElements.mitems: visit item, p
  of xnkDictExpr:
    for item in node.legacyEntries.mitems: visit item, p
  of xnkArrayLit:
    for item in node.legacyArrayElements.mitems: visit item, p
  of xnkDictEntry:
    visit node.key, p
    visit node.value, p
  of xnkExternal_Comprehension:
    visit node.extCompExpr, p
    for item in node.extCompFors.mitems: visit item, p
    for item in node.extCompIf.mitems: visit item, p
  of xnkCompFor:
    for item in node.vars.mitems: visit item, p
    visit node.iter, p
  of xnkExternal_Generator:
    visit node.extGenExpr, p
    for item in node.extGenFor.mitems: visit item, p  # Each is xnkCompFor
    for item in node.extGenIf.mitems: visit item, p
  of xnkExternal_Await:
    visit node.extAwaitExpr, p
  of xnkExternal_StringInterp:
    for item in node.extInterpParts.mitems: visit item, p

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
    for item in node.funcParams.mitems: visit item, p
    if node.funcReturnType.isSome(): visit node.funcReturnType.get, p
  of xnkPointerType, xnkReferenceType:
    visit node.referentType, p
  of xnkGenericType:
    if node.genericBase.isSome(): visit node.genericBase.get, p
    for item in node.genericArgs.mitems: visit item, p
  of xnkUnionType:
    for item in node.unionTypes.mitems: visit item, p
  of xnkIntersectionType:
    for item in node.typeMembers.mitems: visit item, p
  of xnkDistinctType:
    visit node.distinctBaseType, p

  of xnkIdentifier, xnkComment:
    discard
  of xnkImport:
    discard
  of xnkExport:
    visit node.exportedDecl, p
  of xnkAttribute:
    for item in node.attrArgs.mitems: visit item, p
  of xnkGenericParameter:
    for item in node.genericParamConstraints.mitems: visit item, p
    for item in node.bounds.mitems: visit item, p
  of xnkParameter:
    if node.paramType.isSome(): visit node.paramType.get, p
    if node.defaultValue.isSome(): visit node.defaultValue.get, p
  of xnkArgument:
    visit node.argValue, p
  of xnkDecorator:
    visit node.decoratorExpr, p

  of xnkTemplateDef, xnkMacroDef:
    for item in node.tplparams.mitems: visit item, p
    visit node.tmplbody, p
  of xnkPragma:
    for item in node.pragmas.mitems: visit item, p
  of xnkStaticStmt, xnkDeferStmt:
    visit node.staticBody, p
  of xnkAsmStmt:
    discard
  of xnkDistinctTypeDef:
    visit node.baseType, p
  of xnkConceptDef:
    visit node.conceptBody, p
  of xnkConceptDecl:
    for item in node.conceptRequirements.mitems: visit item, p
  of xnkMixinStmt, xnkBindStmt:
    discard
  of xnkTupleConstr:
    for item in node.tupleElements.mitems: visit item, p
  of xnkTupleUnpacking:
    for item in node.unpackTargets.mitems: visit item, p
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
    for item in node.branches.mitems: visit item, p
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
    for item in node.moduleMembers.mitems: visit item, p
  of xnkTypeAlias:
    visit node.aliasTarget, p
  of xnkAbstractDecl:
    for item in node.abstractBody.mitems: visit item, p
  of xnkEnumMember:
    if node.enumMemberValue.isSome(): visit node.enumMemberValue.get, p

  of xnkLibDecl:
    for item in node.libBody.mitems: visit item, p
  of xnkCFuncDecl:
    for item in node.cfuncParams.mitems: visit item, p
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
    for item in node.switchCaseConditions.mitems: visit item, p
    visit node.switchCaseBody, p
  of xnkMixinDecl:
    visit node.mixinDeclExpr, p
  of xnkTemplateDecl:
    for item in node.templateParams.mitems: visit item, p
    for item in node.templateBody.mitems: visit item, p
  of xnkMacroDecl:
    for item in node.macroParams.mitems: visit item, p
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
    for item in node.functionTypeParams.mitems: visit item, p
    if node.functionTypeReturn.isSome(): visit node.functionTypeReturn.get, p
  of xnkMetadata:
    for item in node.metadataEntries.mitems: visit item, p

  of xnkExternal_Indexer:
    for item in node.extIndexerParams.mitems: visit item, p
    visit node.extIndexerType, p
    if node.extIndexerGetter.isSome(): visit node.extIndexerGetter.get, p
    if node.extIndexerSetter.isSome(): visit node.extIndexerSetter.get, p
  of xnkExternal_Operator:
    for item in node.extOperatorParams.mitems: visit item, p
    visit node.extOperatorReturnType, p
    if node.extOperatorBody.isSome(): visit node.extOperatorBody.get, p
  of xnkExternal_ConversionOp:
    visit node.extConversionFromType, p
    visit node.extConversionToType, p
    visit node.extConversionBody, p  # No longer Option
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
  of xnkExternal_ThrowExpr:
    visit node.extThrowExprValue, p
  of xnkExternal_SwitchExpr:
    visit node.extSwitchExprValue, p
    for item in node.extSwitchExprArms.mitems: visit item, p
  of xnkExternal_StackAlloc:
    visit node.extStackAllocType, p
    if node.extStackAllocSize.isSome(): visit node.extStackAllocSize.get, p
  of xnkImplicitArrayCreation:
    for item in node.implicitArrayElements.mitems: visit item, p

  of xnkEmptyStmt:
    discard
  of xnkLabeledStmt:
    visit node.labeledStmt, p
  of xnkGotoStmt:
    discard
  of xnkExternal_Fixed:
    for item in node.extFixedDeclarations.mitems: visit item, p
    visit node.extFixedBody, p
  of xnkExternal_Lock:
    visit node.extLockExpr, p
    visit node.extLockBody, p
  of xnkExternal_Unsafe:
    visit node.extUnsafeBody, p
  of xnkExternal_Checked:
    visit node.extCheckedBody, p
  of xnkExternal_LocalFunction:
    for item in node.extLocalFuncParams.mitems: visit item, p
    if node.extLocalFuncReturnType.isSome(): visit node.extLocalFuncReturnType.get, p
    if node.extLocalFuncBody.isSome(): visit node.extLocalFuncBody.get, p

  of xnkQualifiedName:
    visit node.qualifiedLeft, p
  of xnkAliasQualifiedName:
    discard
  of xnkGenericName:
    for item in node.genericNameArgs.mitems: visit item, p

  of xnkUnknown:
    discard
  else:
    # External or unhandled kinds: no recursive child visitation by default
    discard