import options
# import strutils

# type
#   XLangVersion = tuple[major, minor, patch: int]

# const SUPPORTED_XLANG_VERSION: XLangVersion = (1, 0, 0)
# proc parseVersion(v: string): XLangVersion =
#   let parts: seq[string] = v.split(".")
#   if parts.len != 3:
#     raise newException(ValueError, "Invalid version string")
#   result = (parseInt(parts[0]), parseInt(parts[1]), parseInt(parts[2]))

# proc isVersionCompatible(ast_version, supported_version: XLangVersion): bool =
#   if ast_version.major != supported_version.major:
#     return false
#   if ast_version.major == supported_version.major and ast_version.minor > supported_version.minor:
#     return false
#   return true



type
  XLangNodeKind* = enum
    # xnkNone
    # Basic structure
    xnkFile, xnkModule, xnkNamespace

    # Declarations
    xnkFuncDecl, xnkMethodDecl, xnkIteratorDecl, xnkClassDecl, xnkStructDecl, xnkInterfaceDecl
    xnkEnumDecl, xnkVarDecl, xnkConstDecl, xnkTypeDecl, xnkPropertyDecl, xnkLetDecl
    xnkFieldDecl, xnkConstructorDecl, xnkDestructorDecl, xnkDelegateDecl, xnkEventDecl,
    xnkModuleDecl, xnkTypeAlias, xnkAbstractDecl, xnkEnumMember,
    xnkIndexerDecl, xnkOperatorDecl, xnkConversionOperatorDecl,
    xnkAbstractType, xnkFunctionType, xnkMetadata,
    # C FFI and external declarations
    xnkLibDecl, xnkCFuncDecl, xnkExternalVar

    # Statements
    xnkAsgn, xnkBlockStmt, xnkIfStmt, xnkSwitchStmt, xnkCaseClause, xnkDefaultClause, xnkForStmt, xnkWhileStmt
    xnkDoWhileStmt, xnkForeachStmt, xnkTryStmt, xnkCatchStmt, xnkFinallyStmt
    xnkReturnStmt, xnkIteratorYield, xnkIteratorDelegate, xnkBreakStmt, xnkContinueStmt
    # Legacy (deprecated - unified into iterator nodes):
    xnkYieldStmt, xnkYieldExpr, xnkYieldFromStmt
    xnkThrowStmt, xnkAssertStmt, xnkWithStmt, xnkPassStmt, xnkTypeSwitchStmt,
    xnkResourceStmt, xnkResourceItem,  # Unified resource management (with/using)
    xnkDiscardStmt, xnkCaseStmt, xnkRaiseStmt, xnkImportStmt, xnkExportStmt, xnkFromImportStmt, xnkTypeCaseClause, xnkWithItem,
    xnkEmptyStmt, xnkLabeledStmt, xnkGotoStmt, xnkFixedStmt, xnkLockStmt, xnkUnsafeStmt, xnkCheckedStmt, xnkLocalFunctionStmt,
    xnkUnlessStmt, xnkUntilStmt, xnkStaticAssert, xnkSwitchCase, xnkMixinDecl, xnkTemplateDecl, xnkMacroDecl, xnkInclude, xnkExtend
    # Expressions
    xnkBinaryExpr, xnkUnaryExpr, xnkTernaryExpr, xnkCallExpr, xnkThisCall, xnkBaseCall, xnkIndexExpr,
     xnkSliceExpr, xnkMemberAccessExpr, xnkSafeNavigationExpr, xnkNullCoalesceExpr,
      xnkLambdaExpr, xnkTypeAssertion, xnkCastExpr, xnkThisExpr, xnkBaseExpr, xnkRefExpr, xnkInstanceVar, xnkClassVar, xnkGlobalVar, xnkProcLiteral, xnkProcPointer, xnkNumberLit, xnkSymbolLit, xnkDynamicType,
      xnkGeneratorExpr, xnkAwaitExpr, xnkStringInterpolation, xnkDotExpr, xnkBracketExpr, xnkCompFor,
      xnkDefaultExpr, xnkTypeOfExpr, xnkSizeOfExpr, xnkCheckedExpr, xnkThrowExpr, xnkSwitchExpr, xnkStackAllocExpr, xnkImplicitArrayCreation
    # Literals
    xnkIntLit, xnkFloatLit, xnkStringLit, xnkCharLit, xnkBoolLit, xnkNoneLit, xnkNilLit

    # Types
    xnkNamedType, xnkArrayType, xnkMapType, xnkFuncType, xnkPointerType
    xnkReferenceType, xnkGenericType, xnkUnionType, xnkIntersectionType, xnkDistinctType

    # Other
    xnkIdentifier, xnkComment, xnkImport, xnkExport, xnkAttribute
    xnkGenericParameter, xnkParameter, xnkArgument, xnkDecorator, xnkLambdaProc, xnkArrowFunc, xnkConceptRequirement,
    xnkQualifiedName, xnkAliasQualifiedName, xnkGenericName,
    xnkUnknown  # Fallback for unhandled constructs
    # Comments

    xnkTemplateDef, xnkMacroDef, xnkPragma, xnkStaticStmt, xnkDeferStmt,
    xnkAsmStmt, xnkDistinctTypeDef, xnkConceptDef, xnkMixinStmt, xnkConceptDecl,
    xnkBindStmt, xnkTupleConstr, xnkTupleUnpacking, xnkUsingStmt,
    xnkDestructureObj, xnkDestructureArray

    xnkMethodReference
    # Collection literals (renamed for clarity and consistency):
    xnkSequenceLiteral, xnkSetLiteral, xnkMapLiteral, xnkArrayLiteral, xnkTupleExpr, xnkComprehensionExpr, xnkDictEntry
    # Legacy (deprecated - renamed to *Literal):
    xnkListExpr, xnkSetExpr, xnkDictExpr, xnkArrayLit



  XLangNode* = ref object
    case kind*: XLangNodeKind
    of xnkFile:
      fileName*: string
      moduleDecls*: seq[XLangNode]
    of xnkModule:
      moduleName*: string
      moduleBody*: seq[XLangNode]
    of xnkNamespace:
      namespaceName*: string
      namespaceBody*: seq[XLangNode]
    of xnkFuncDecl:
      funcName*: string
      params*: seq[XLangNode]
      returnType*: Option[XLangNode]
      body*: XLangNode
      isAsync*: bool

    of xnkMethodDecl:
      receiver*: Option[XLangNode]       # <- method-specific field
      methodName*: string
      mparams*: seq[XLangNode]
      mreturnType*: Option[XLangNode]
      mbody*: XLangNode
      methodIsAsync*: bool
    of xnkIteratorDecl:
      iteratorName*: string
      iteratorParams*: seq[XLangNode]
      iteratorReturnType*: Option[XLangNode]
      iteratorBody*: XLangNode
    of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
      typeNameDecl*: string
      baseTypes*: seq[XLangNode]
      members*: seq[XLangNode]
    of xnkEnumDecl:
      enumName*: string
      enumMembers*: seq[XLangNode]
    of xnkVarDecl, xnkLetDecl, xnkConstDecl:
      declName*: string
      declType*: Option[XLangNode]
      initializer*: Option[XLangNode]
    of xnkTypeDecl:
      typeDefName*: string
      typeDefBody*: XLangNode
    of xnkPropertyDecl:
      propName*: string
      propType*: Option[XLangNode]
      getter*: Option[XLangNode]
      setter*: Option[XLangNode]
    of xnkFieldDecl:
      fieldName*: string
      fieldType*: XLangNode
      fieldInitializer*: Option[XLangNode]
    of xnkConstructorDecl:
      constructorParams*: seq[XLangNode]
      constructorInitializers*: seq[XLangNode]
      constructorBody*: XLangNode
    of xnkDestructorDecl:
      destructorBody*: XLangNode
    of xnkDelegateDecl:
      delegateName*: string
      delegateParams*: seq[XLangNode]
      delegateReturnType*: Option[XLangNode]
    of xnkEventDecl:
      eventName*: string
      eventType*: XLangNode
      addAccessor*: Option[XLangNode]
      removeAccessor*: Option[XLangNode]
    of xnkAsgn:
      asgnLeft*: XLangNode
      asgnRight*: XLangNode
    of xnkBlockStmt:
      blockBody*: seq[XLangNode]
    of xnkIfStmt:
      ifCondition*: XLangNode
      ifBody*: XLangNode
      elseBody*: Option[XLangNode]
    of xnkSwitchStmt:
      switchExpr*: XLangNode
      switchCases*: seq[XLangNode]       # Contains xnkCaseClause and xnkDefaultClause nodes
    of xnkCaseClause:
      caseValues*: seq[XLangNode]        # Multiple values for case 1, 2, 3:
      caseBody*: XLangNode
      caseFallthrough*: bool             # For Go's fallthrough keyword
    of xnkDefaultClause:
      defaultBody*: XLangNode
    of xnkForStmt:
      forInit*: Option[XLangNode]
      forCond*: Option[XLangNode]
      forIncrement*: Option[XLangNode]
      forBody*: Option[XLangNode]
    of xnkWhileStmt, xnkDoWhileStmt:
      whileCondition*: XLangNode
      whileBody*: XLangNode
    of xnkForeachStmt:
      foreachVar*: XLangNode
      foreachIter*: XLangNode
      foreachBody*: XLangNode
    of xnkTryStmt:
      tryBody*: XLangNode
      catchClauses*: seq[XLangNode]
      finallyClause*: Option[XLangNode]
    of xnkCatchStmt:
      catchType*: Option[XLangNode]
      catchVar*: Option[string]
      catchBody*: XLangNode
    of xnkFinallyStmt:
      finallyBody*: XLangNode
    of xnkReturnStmt:
      returnExpr*: Option[XLangNode]
    of xnkIteratorYield:
      ## Unified iterator/generator yield: Python yield, C# yield return, Nim yield
      iteratorYieldValue*: Option[XLangNode]
    of xnkIteratorDelegate:
      ## Delegate to sub-iterator: Python yield from, conceptually like foreach+yield
      iteratorDelegateExpr*: XLangNode
    # Legacy (deprecated):
    of xnkYieldStmt:
      yieldStmt*: Option[XLangNode]
    of xnkYieldExpr:
      yieldExpr*: Option[XLangNode]
    of xnkYieldFromStmt:
      yieldFromExpr*: XLangNode
    of xnkBreakStmt, xnkContinueStmt:
      label*: Option[string]
    of xnkThrowStmt:
      throwExpr*: XLangNode
    of xnkAssertStmt:
      assertCond*: XLangNode
      assertMsg*: Option[XLangNode]
    
    of xnkWithStmt:
      items*: seq[XLangNode]
      withBody*: XLangNode
    of xnkWithItem:
      contextExpr*: XLangNode
      asExpr*: Option[XLangNode]
    of xnkResourceStmt:
      ## Unified resource management: Python 'with', C# 'using', Java 'try-with-resources'
      resourceItems*: seq[XLangNode]  # xnkResourceItem nodes
      resourceBody*: XLangNode
    of xnkResourceItem:
      ## Individual resource in a resource statement
      resourceExpr*: XLangNode           # Expression that acquires resource
      resourceVar*: Option[XLangNode]    # Variable to bind resource to
      cleanupHint*: Option[string]       # Cleanup method: "close", "dispose", etc.
    of xnkPassStmt:
      discard
    of xnkTypeSwitchStmt:
      typeSwitchExpr*: XLangNode
      typeSwitchVar*: Option[XLangNode]
      typeSwitchCases*: seq[XLangNode]   # Contains xnkTypeCaseClause and xnkDefaultClause nodes
    of xnkBinaryExpr:
      binaryLeft*: XLangNode
      binaryOp*: string
      binaryRight*: XLangNode
    of xnkUnaryExpr:
      unaryOp*: string
      unaryOperand*: XLangNode
    of xnkTernaryExpr:
      ternaryCondition*: XLangNode
      ternaryThen*: XLangNode
      ternaryElse*: XLangNode
    of xnkCallExpr:
      callee*: XLangNode
      args*: seq[XLangNode]
    of xnkThisCall, xnkBaseCall:
      ## C# constructor initializers: this(...) or base(...)
      arguments*: seq[XLangNode]
    of xnkIndexExpr:
      indexExpr*: XLangNode
      indexArgs*: seq[XLangNode]
    of xnkSliceExpr:
      sliceExpr*: XLangNode
      sliceStart*: Option[XLangNode]
      sliceEnd*: Option[XLangNode]
      sliceStep*: Option[XLangNode]
    of xnkMemberAccessExpr:
      memberExpr*: XLangNode
      memberName*: string
    of xnkSafeNavigationExpr:
      safeNavObject*: XLangNode
      safeNavMember*: string             # For user?.Name
    of xnkNullCoalesceExpr:
      nullCoalesceLeft*: XLangNode       # Left side of ??
      nullCoalesceRight*: XLangNode      # Right side of ??
    of xnkLambdaExpr:
      lambdaParams*: seq[XLangNode]
      lambdaReturnType*: Option[XLangNode]
      lambdaBody*: XLangNode
    of xnkTypeAssertion:
      assertExpr*: XLangNode
      assertType*: XLangNode
    of xnkLambdaProc:
      lambdaProcParams*: seq[XLangNode]
      lambdaProcReturn*: Option[XLangNode]
      lambdaProcBody*: XLangNode
    of xnkArrowFunc:
      arrowParams*: seq[XLangNode]
      arrowBody*: XLangNode
      arrowReturnType*: Option[XLangNode]
    of xnkConceptRequirement:
      reqName*: string
      reqParams*: seq[XLangNode]
      reqReturn*: Option[XLangNode]
    of xnkMethodReference:
      refObject*: XLangNode
      refMethod*: string
    of xnkSequenceLiteral, xnkSetLiteral, xnkArrayLiteral, xnkTupleExpr:
      ## Collection literals: [1,2,3], {1,2,3}, (1,2,3)
      elements*: seq[XLangNode]
    of xnkMapLiteral:
      ## Map/dictionary literal: {"a": 1, "b": 2}
      entries*: seq[XLangNode]  # seq of xnkDictEntry
    # Legacy (deprecated - use unified *Literal nodes):
    of xnkListExpr, xnkSetExpr:
      legacyElements*: seq[XLangNode]
    of xnkDictExpr:
      legacyEntries*: seq[XLangNode]
    of xnkArrayLit:
      legacyArrayElements*: seq[XLangNode]
    of xnkDictEntry:
      key*: XLangNode
      value*: XLangNode
    of xnkComprehensionExpr:
      compExpr*: XLangNode
      fors*: seq[XLangNode]
      compIf*: seq[XLangNode]
    of xnkCompFor:
      vars*: seq[XLangNode]
      iter*: XLangNode
    of xnkGeneratorExpr:
      genExpr*: XLangNode
      genFor*: seq[tuple[vars: seq[XLangNode], iter: XLangNode]]
      genIf*: seq[XLangNode]
    of xnkAwaitExpr:
      awaitExpr*: XLangNode
    # xnkYieldExpr handled above grouped with xnkYieldStmt
    of xnkStringInterpolation:
      interpParts*: seq[XLangNode]       # Mix of string literals and expressions
      interpIsExpr*: seq[bool]           # True if corresponding part is expression
    of xnkIntLit, xnkFloatLit, xnkStringLit, xnkCharLit:
      literalValue*: string
    of xnkBoolLit:
      boolValue*: bool
    of xnkNoneLit:
      discard
    of xnkNamedType:
      typeName*: string
    of xnkArrayType:
      elementType*: XLangNode
      arraySize*: Option[XLangNode]
    of xnkMapType:
      keyType*: XLangNode
      valueType*: XLangNode
    of xnkFuncType:
      funcParams*: seq[XLangNode]
      funcReturnType*: Option[XLangNode]
    of xnkPointerType, xnkReferenceType:
      referentType*: XLangNode
    of xnkGenericType:
      genericTypeName*: string
      genericBase*: Option[XLangNode]
      genericArgs*: seq[XLangNode]
    of xnkUnionType:
      unionTypes*: seq[XLangNode]
    of xnkIntersectionType:
      typeMembers*: seq[XLangNode]
    of xnkDistinctType:
      distinctBaseType*: XLangNode
    of xnkIdentifier:
      identName*: string

    of xnkComment:
      commentText*: string
      isDocComment*: bool

    of xnkImport:
      importPath*: string
      importAlias*: Option[string]
    of xnkExport:
      exportedDecl*: XLangNode
    of xnkAttribute:
      attrName*: string
      attrArgs*: seq[XLangNode]
    of xnkGenericParameter:
      genericParamName*: string
      genericParamConstraints*: seq[XLangNode]
      bounds*: seq[XLangNode]
    of xnkParameter:
      paramName*: string
      paramType*: Option[XLangNode]
      defaultValue*: Option[XLangNode]
    of xnkArgument:
      argName*: Option[string]
      argValue*: XLangNode
    of xnkDecorator:
      decoratorExpr*: XLangNode
    of xnkTemplateDef, xnkMacroDef:
      name*: string
      tplparams*: seq[XLangNode]
      tmplbody*: XLangNode
      isExported*: bool
    of xnkPragma:
      pragmas*: seq[XLangNode]
    of xnkStaticStmt, xnkDeferStmt:
      staticBody*: XLangNode
    of xnkAsmStmt:
      asmCode*: string
    of xnkDistinctTypeDef:
      distinctName*: string
      baseType*: XLangNode
    of xnkConceptDef:
      conceptName*: string
      conceptBody*: XLangNode
    of xnkConceptDecl:
      conceptDeclName*: string
      conceptRequirements*: seq[XLangNode]
    of xnkMixinStmt:
      mixinNames*: seq[string]
    of xnkBindStmt:
      bindNames*: seq[string]
    of xnkTupleConstr:
      tupleElements*: seq[XLangNode]
    of xnkTupleUnpacking:
      unpackTargets*: seq[XLangNode]
      unpackExpr*: XLangNode
    of xnkUsingStmt:
      usingExpr*: XLangNode
      usingBody*: XLangNode
    of xnkDestructureObj:
      destructObjFields*: seq[string]    # Field names to extract
      destructObjSource*: XLangNode      # Source object
    of xnkDestructureArray:
      destructArrayVars*: seq[string]    # Variable names for elements
      destructArrayRest*: Option[string] # Rest/spread variable name
      destructArraySource*: XLangNode    # Source array
    of xnkDotExpr:
      dotBase*: XLangNode
      member*: XLangNode
      # dot expr used for dot-style member access; memberExpr/memberName handled via xnkMemberAccessExpr
    of xnkBracketExpr:
      base*: XLangNode
      index*: XLangNode
    of xnkCaseStmt:
      expr*: Option[XLangNode]
      branches*: seq[XLangNode]
      caseElseBody*: Option[XLangNode]
    of xnkRaiseStmt:
      raiseExpr*: Option[XLangNode]
    of xnkImportStmt:
      imports*: seq[string]
    of xnkExportStmt:
      exports*: seq[string]
    of xnkFromImportStmt:
      module*: string
      fromImports*: seq[string]
      # imports handled by xnkImportStmt; keep canonical 'fromImports*'
    of xnkNilLit:
      discard
    of xnkDiscardStmt:
      discardExpr*: Option[XLangNode]
    of xnkTypeCaseClause:
      caseType*: XLangNode
      typeCaseBody*: XLangNode
    of xnkModuleDecl:
      moduleNameDecl*: string
      moduleMembers*: seq[XLangNode]
    of xnkTypeAlias:
      aliasName*: string
      aliasTarget*: XLangNode
    of xnkAbstractDecl:
      abstractName*: string
      abstractBody*: seq[XLangNode]
    of xnkEnumMember:
      enumMemberName*: string
      enumMemberValue*: Option[XLangNode]
    of xnkLibDecl:
      libName*: string
      libBody*: seq[XLangNode]
    of xnkCFuncDecl:
      cfuncName*: string
      cfuncParams*: seq[XLangNode]
      cfuncReturnType*: Option[XLangNode]
    of xnkExternalVar:
      extVarName*: string
      extVarType*: XLangNode
    of xnkUnlessStmt:
      unlessCondition*: XLangNode
      unlessBody*: XLangNode
    of xnkUntilStmt:
      untilCondition*: XLangNode
      untilBody*: XLangNode
    of xnkStaticAssert:
      staticAssertCondition*: XLangNode
      staticAssertMessage*: Option[XLangNode]
    of xnkSwitchCase:
      switchCaseConditions*: seq[XLangNode]
      switchCaseBody*: XLangNode
    of xnkMixinDecl:
      mixinDeclExpr*: XLangNode
    of xnkTemplateDecl:
      templateName*: string
      templateParams*: seq[XLangNode]
      templateBody*: seq[XLangNode]
    of xnkMacroDecl:
      macroName*: string
      macroParams*: seq[XLangNode]
      macroBody*: XLangNode
    of xnkInclude:
      includeName*: XLangNode
    of xnkExtend:
      extendName*: XLangNode
    of xnkCastExpr:
      castExpr*: XLangNode
      castType*: XLangNode
    of xnkThisExpr:
      discard  # No fields needed - represents "this" keyword
    of xnkInstanceVar, xnkClassVar, xnkGlobalVar:
      varName*: string
    of xnkProcLiteral:
      procBody*: XLangNode
    of xnkProcPointer:
      procPointerName*: string
    # xnkArrayLit moved to unified collection literals section (line 286)
    of xnkNumberLit:
      numberValue*: string
    of xnkSymbolLit:
      symbolValue*: string
    of xnkDynamicType:
      dynamicConstraint*: Option[XLangNode]
    of xnkAbstractType:
      abstractTypeName*: string
    of xnkFunctionType:
      functionTypeParams*: seq[XLangNode]
      functionTypeReturn*: Option[XLangNode]
    of xnkMetadata:
      metadataEntries*: seq[XLangNode]
    # New C# constructs
    of xnkIndexerDecl:
      indexerParams*: seq[XLangNode]
      indexerType*: XLangNode
      indexerGetter*: Option[XLangNode]
      indexerSetter*: Option[XLangNode]
    of xnkOperatorDecl:
      operatorSymbol*: string
      operatorParams*: seq[XLangNode]
      operatorReturnType*: XLangNode
      operatorBody*: XLangNode
    of xnkConversionOperatorDecl:
      conversionIsImplicit*: bool
      conversionFromType*: XLangNode
      conversionToType*: XLangNode
      conversionBody*: XLangNode
    of xnkBaseExpr:
      discard  # Represents "base" keyword
    of xnkRefExpr:
      refExpr*: XLangNode
    of xnkDefaultExpr:
      defaultType*: Option[XLangNode]
    of xnkTypeOfExpr:
      typeOfType*: XLangNode
    of xnkSizeOfExpr:
      sizeOfType*: XLangNode
    of xnkCheckedExpr:
      checkedExpr*: XLangNode
      isChecked*: bool
    of xnkThrowExpr:
      throwExprValue*: XLangNode
    of xnkSwitchExpr:
      switchExprValue*: XLangNode
      switchExprArms*: seq[XLangNode]
    of xnkStackAllocExpr:
      stackAllocType*: XLangNode
      stackAllocSize*: Option[XLangNode]
    of xnkImplicitArrayCreation:
      implicitArrayElements*: seq[XLangNode]
    of xnkEmptyStmt:
      discard
    of xnkLabeledStmt:
      labelName*: string
      labeledStmt*: XLangNode
    of xnkGotoStmt:
      gotoLabel*: string
    of xnkFixedStmt:
      fixedDeclarations*: seq[XLangNode]
      fixedBody*: XLangNode
    of xnkLockStmt:
      lockExpr*: XLangNode
      lockBody*: XLangNode
    of xnkUnsafeStmt:
      unsafeBody*: XLangNode
    of xnkCheckedStmt:
      checkedBody*: XLangNode
      checkedIsChecked*: bool
    of xnkLocalFunctionStmt:
      localFuncName*: string
      localFuncParams*: seq[XLangNode]
      localFuncReturnType*: Option[XLangNode]
      localFuncBody*: XLangNode
    of xnkQualifiedName:
      qualifiedLeft*: XLangNode
      qualifiedRight*: string
    of xnkAliasQualifiedName:
      aliasQualifier*: string
      aliasQualifiedName*: string
    of xnkGenericName:
      genericNameIdentifier*: string
      genericNameArgs*: seq[XLangNode]
    of xnkUnknown:
      unknownData*: string
    # else: discard


# type XLangAST = object
#   version: XLangVersion
#   root: XLangNode


proc `$`*(node: XLangNode): string =
  if node == nil: return "nil"

  result = $node.kind

  case node.kind:
  of xnkFile:
    result &= "(" & node.fileName & ")"
  of xnkModule:
    result &= "(" & node.moduleName & ")"
  of xnkNamespace:
    result &= "(" & node.namespaceName & ")"
  of xnkFuncDecl:
    result &= "(" & node.funcName & ")"
  of xnkMethodDecl:
    result &= "(" & node.methodName & ")"
  of xnkIteratorDecl:
    result &= "(" & node.iteratorName & ")"
  of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
    result &= "(" & node.typeNameDecl & ")"
  of xnkEnumDecl:
    result &= "(" & node.enumName & ")"
  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    result &= "(" & node.declName & ")"
  of xnkTypeDecl:
    result &= "(" & node.typeDefName & ")"
  of xnkPropertyDecl:
    result &= "(" & node.propName & ")"
  of xnkFieldDecl:
    result &= "(" & node.fieldName & ")"
  of xnkDelegateDecl:
    result &= "(" & node.delegateName & ")"
  of xnkEventDecl:
    result &= "(" & node.eventName & ")"
  of xnkBinaryExpr:
    result &= "(" & node.binaryOp & ")"
  of xnkUnaryExpr:
    result &= "(" & node.unaryOp & ")"
  of xnkMemberAccessExpr:
    result &= "(" & node.memberName & ")"
  of xnkSafeNavigationExpr:
    result &= "(" & node.safeNavMember & ")"
  of xnkIntLit, xnkFloatLit, xnkStringLit, xnkCharLit:
    result &= "(\"" & node.literalValue & "\")"
  of xnkBoolLit:
    result &= "(" & $node.boolValue & ")"
  of xnkNamedType:
    result &= "(" & node.typeName & ")"
  of xnkGenericType:
    result &= "(" & node.genericTypeName & ")"
  of xnkIdentifier:
    result &= "(" & node.identName & ")"
  of xnkComment:
    let preview = if node.commentText.len > 30: node.commentText[0..29] & "..." else: node.commentText
    result &= "(\"" & preview & "\")"
  of xnkImport:
    result &= "(" & node.importPath & ")"
  of xnkAttribute:
    result &= "(" & node.attrName & ")"
  of xnkGenericParameter:
    result &= "(" & node.genericParamName & ")"
  of xnkParameter:
    result &= "(" & node.paramName & ")"
  of xnkArgument:
    if node.argName.isSome():
      result &= "(" & node.argName.get & ")"
  of xnkTemplateDef, xnkMacroDef:
    result &= "(" & node.name & ")"
  of xnkAsmStmt:
    let preview = if node.asmCode.len > 30: node.asmCode[0..29] & "..." else: node.asmCode
    result &= "(\"" & preview & "\")"
  of xnkDistinctTypeDef:
    result &= "(" & node.distinctName & ")"
  of xnkConceptDef:
    result &= "(" & node.conceptName & ")"
  of xnkConceptDecl:
    result &= "(" & node.conceptDeclName & ")"
  of xnkConceptRequirement:
    result &= "(" & node.reqName & ")"
  of xnkModuleDecl:
    result &= "(" & node.moduleNameDecl & ")"
  of xnkTypeAlias:
    result &= "(" & node.aliasName & ")"
  of xnkAbstractDecl:
    result &= "(" & node.abstractName & ")"
  of xnkEnumMember:
    result &= "(" & node.enumMemberName & ")"
  of xnkLibDecl:
    result &= "(" & node.libName & ")"
  of xnkCFuncDecl:
    result &= "(" & node.cfuncName & ")"
  of xnkExternalVar:
    result &= "(" & node.extVarName & ")"
  of xnkTemplateDecl:
    result &= "(" & node.templateName & ")"
  of xnkMacroDecl:
    result &= "(" & node.macroName & ")"
  of xnkInstanceVar, xnkClassVar, xnkGlobalVar:
    result &= "(" & node.varName & ")"
  of xnkProcPointer:
    result &= "(" & node.procPointerName & ")"
  of xnkNumberLit:
    result &= "(\"" & node.numberValue & "\")"
  of xnkSymbolLit:
    result &= "(\"" & node.symbolValue & "\")"
  of xnkAbstractType:
    result &= "(" & node.abstractTypeName & ")"
  of xnkOperatorDecl:
    result &= "(" & node.operatorSymbol & ")"
  of xnkConversionOperatorDecl:
    result &= "(" & (if node.conversionIsImplicit: "implicit" else: "explicit") & ")"
  of xnkCheckedExpr:
    result &= "(" & (if node.isChecked: "checked" else: "unchecked") & ")"
  of xnkLabeledStmt:
    result &= "(" & node.labelName & ")"
  of xnkGotoStmt:
    result &= "(" & node.gotoLabel & ")"
  of xnkCheckedStmt:
    result &= "(" & (if node.checkedIsChecked: "checked" else: "unchecked") & ")"
  of xnkLocalFunctionStmt:
    result &= "(" & node.localFuncName & ")"
  of xnkQualifiedName:
    result &= "(" & node.qualifiedRight & ")"
  of xnkAliasQualifiedName:
    result &= "(" & node.aliasQualifier & "::" & node.aliasQualifiedName & ")"
  of xnkGenericName:
    result &= "(" & node.genericNameIdentifier & ")"
  of xnkUnknown:
    let preview = if node.unknownData.len > 30: node.unknownData[0..29] & "..." else: node.unknownData
    result &= "(\"" & preview & "\")"
  of xnkBreakStmt, xnkContinueStmt:
    if node.label.isSome():
      result &= "(" & node.label.get & ")"
  of xnkCatchStmt:
    if node.catchVar.isSome():
      result &= "(" & node.catchVar.get & ")"
  of xnkMixinStmt:
    result &= "(" & $node.mixinNames & ")"
  of xnkBindStmt:
    result &= "(" & $node.bindNames & ")"
  of xnkDestructureObj:
    result &= "(" & $node.destructObjFields & ")"
  of xnkDestructureArray:
    result &= "(" & $node.destructArrayVars & ")"
  of xnkImportStmt:
    result &= "(" & $node.imports & ")"
  of xnkExportStmt:
    result &= "(" & $node.exports & ")"
  of xnkFromImportStmt:
    result &= "(from " & node.module & ")"
  of xnkResourceItem:
    if node.cleanupHint.isSome():
      result &= "(" & node.cleanupHint.get & ")"
  of xnkStringInterpolation:
    result &= "(" & $node.interpParts.len & " parts)"
  of xnkMethodReference:
    result &= "(" & node.refMethod & ")"

  # Statements and expressions with no meaningful string fields to display
  of xnkConstructorDecl, xnkDestructorDecl, xnkAsgn, xnkBlockStmt, xnkIfStmt,
     xnkSwitchStmt, xnkCaseClause, xnkDefaultClause, xnkForStmt, xnkWhileStmt,
     xnkDoWhileStmt, xnkForeachStmt, xnkTryStmt, xnkFinallyStmt,
     xnkReturnStmt, xnkIteratorYield, xnkIteratorDelegate,
     xnkYieldStmt, xnkYieldExpr, xnkYieldFromStmt,
     xnkThrowStmt, xnkAssertStmt, xnkWithStmt, xnkPassStmt, xnkTypeSwitchStmt,
     xnkResourceStmt, xnkWithItem, xnkDiscardStmt, xnkCaseStmt, xnkRaiseStmt,
     xnkTypeCaseClause, xnkEmptyStmt, xnkFixedStmt, xnkLockStmt, xnkUnsafeStmt,
     xnkUnlessStmt, xnkUntilStmt, xnkStaticAssert, xnkSwitchCase,
     xnkInclude, xnkExtend, xnkTernaryExpr, xnkCallExpr, xnkThisCall, xnkBaseCall,
     xnkIndexExpr, xnkSliceExpr, xnkNullCoalesceExpr, xnkLambdaExpr,
     xnkTypeAssertion, xnkCastExpr, xnkThisExpr, xnkBaseExpr, xnkRefExpr,
     xnkProcLiteral, xnkDynamicType, xnkGeneratorExpr, xnkAwaitExpr,
     xnkDotExpr, xnkBracketExpr, xnkCompFor, xnkDefaultExpr, xnkTypeOfExpr,
     xnkSizeOfExpr, xnkThrowExpr, xnkSwitchExpr, xnkStackAllocExpr,
     xnkImplicitArrayCreation, xnkNoneLit, xnkNilLit, xnkArrayType, xnkMapType,
     xnkFuncType, xnkPointerType, xnkReferenceType, xnkUnionType,
     xnkIntersectionType, xnkDistinctType, xnkExport, xnkDecorator,
     xnkLambdaProc, xnkArrowFunc, xnkPragma, xnkStaticStmt, xnkDeferStmt,
     xnkTupleConstr, xnkTupleUnpacking, xnkUsingStmt, xnkSequenceLiteral,
     xnkSetLiteral, xnkMapLiteral, xnkArrayLiteral, xnkTupleExpr,
     xnkComprehensionExpr, xnkDictEntry, xnkListExpr, xnkSetExpr, xnkDictExpr,
     xnkArrayLit, xnkIndexerDecl, xnkFunctionType, xnkMetadata, xnkMixinDecl:
    discard

