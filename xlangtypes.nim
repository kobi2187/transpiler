import options
import strutils

type
  XLangVersion = tuple[major, minor, patch: int]

const SUPPORTED_XLANG_VERSION: XLangVersion = (1, 0, 0)
proc parseVersion(v: string): XLangVersion =
  let parts: seq[string] = v.split(".")
  if parts.len != 3:
    raise newException(ValueError, "Invalid version string")
  result = (parseInt(parts[0]), parseInt(parts[1]), parseInt(parts[2]))

proc isVersionCompatible(ast_version, supported_version: XLangVersion): bool =
  if ast_version.major != supported_version.major:
    return false
  if ast_version.major == supported_version.major and ast_version.minor > supported_version.minor:
    return false
  return true



type
  XLangNodeKind* = enum
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


type XLangAST = object
  version: XLangVersion
  root: XLangNode


proc `$`*(node: XLangNode): string =
  if node == nil: return "nil"
  result = $node.kind

proc getChildren*(node: XLangNode): seq[XLangNode] =
  case node.kind:
  of xnkFile:
    return node.moduleDecls
  of xnkModule:
    return node.moduleBody
  of xnkNamespace:
    return node.namespaceBody
  of xnkFuncDecl:
    var fchildren: seq[XLangNode] = @[]
    if node.returnType != none(XLangNode): fchildren.add(node.returnType.get)
    for p in node.params: fchildren.add(p)
    fchildren.add(node.body)
    return fchildren
  of xnkMethodDecl:
    var mchildren: seq[XLangNode] = @[]
    if node.receiver != none(XLangNode): mchildren.add(node.receiver.get)
    if node.mreturnType != none(XLangNode): mchildren.add(node.mreturnType.get)
    for p in node.mparams: mchildren.add(p)
    mchildren.add(node.mbody)
    return mchildren
  of xnkIteratorDecl:
    var itchildren: seq[XLangNode] = @[]
    for p in node.iteratorParams: itchildren.add(p)
    if node.iteratorReturnType != none(XLangNode): itchildren.add(node.iteratorReturnType.get)
    itchildren.add(node.iteratorBody)
    return itchildren
  of xnkGenericType:
    var gchildren: seq[XLangNode] = @[]
    if node.genericBase != none(XLangNode): gchildren.add(node.genericBase.get)
    for ga in node.genericArgs: gchildren.add(ga)
    return gchildren
  of xnkGeneratorExpr:
    var genChildren: seq[XLangNode] = @[]
    genChildren.add(node.genExpr)
    for f in node.genFor:
      for v in f.vars: genChildren.add(v)
      genChildren.add(f.iter)
    for ifn in node.genIf: genChildren.add(ifn)
    return genChildren
  of xnkIteratorYield:
    if node.iteratorYieldValue.isSome():
      return @[node.iteratorYieldValue.get]
    return @[]
  of xnkIteratorDelegate:
    return @[node.iteratorDelegateExpr]
  # Legacy:
  of xnkYieldStmt:
    if node.yieldStmt.isSome():
      return @[node.yieldStmt.get]
    return @[]
  of xnkYieldExpr:
    if node.yieldExpr.isSome():
      return @[node.yieldExpr.get]
    return @[]
  of xnkYieldFromStmt:
    return @[node.yieldFromExpr]
  of xnkLambdaProc:
    var lpChildren: seq[XLangNode] = @[]
    for p in node.lambdaProcParams: lpChildren.add(p)
    if node.lambdaProcReturn != none(XLangNode): lpChildren.add(node.lambdaProcReturn.get)
    lpChildren.add(node.lambdaProcBody)
    return lpChildren
  of xnkArrowFunc:
    var afChildren: seq[XLangNode] = @[]
    for p in node.arrowParams: afChildren.add(p)
    afChildren.add(node.arrowBody)
    return afChildren
  of xnkMethodReference:
    return @[node.refObject]
  of xnkEventDecl:
    return @[node.eventType]
  of xnkResourceStmt:
    var rchildren: seq[XLangNode] = @[]
    for item in node.resourceItems: rchildren.add(item)
    rchildren.add(node.resourceBody)
    return rchildren
  of xnkResourceItem:
    var richildren: seq[XLangNode] = @[]
    richildren.add(node.resourceExpr)
    if node.resourceVar.isSome(): richildren.add(node.resourceVar.get)
    return richildren
  else: return @[]
