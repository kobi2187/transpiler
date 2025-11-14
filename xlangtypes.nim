import options

type
  XLangNodeKind* = enum
    # Basic structure
    xnkFile, xnkModule, xnkNamespace

    # Declarations
    xnkFuncDecl, xnkMethodDecl, xnkClassDecl, xnkStructDecl, xnkInterfaceDecl
    xnkEnumDecl, xnkVarDecl, xnkConstDecl, xnkTypeDecl, xnkPropertyDecl, xnkLetDecl
    xnkFieldDecl, xnkConstructorDecl, xnkDestructorDecl, xnkDelegateDecl

    # Statements
    xnkBlockStmt, xnkIfStmt, xnkSwitchStmt, xnkCaseClause, xnkDefaultClause, xnkForStmt, xnkWhileStmt
    xnkDoWhileStmt, xnkForeachStmt, xnkTryStmt, xnkCatchStmt, xnkFinallyStmt
    xnkReturnStmt, xnkYieldStmt, xnkBreakStmt, xnkContinueStmt
    xnkThrowStmt, xnkAssertStmt, xnkWithStmt, xnkPassStmt

    # Expressions
    xnkBinaryExpr, xnkUnaryExpr, xnkTernaryExpr, xnkCallExpr, xnkIndexExpr
    xnkSliceExpr, xnkMemberAccessExpr, xnkSafeNavigationExpr, xnkNullCoalesceExpr
    xnkLambdaExpr, xnkListExpr, xnkDictExpr
    xnkSetExpr, xnkTupleExpr, xnkComprehensionExpr, xnkAwaitExpr, xnkYieldExpr

    # Literals
    xnkIntLit, xnkFloatLit, xnkStringLit, xnkCharLit, xnkBoolLit, xnkNoneLit

    # Types
    xnkNamedType, xnkArrayType, xnkMapType, xnkFuncType, xnkPointerType
    xnkReferenceType, xnkGenericType, xnkUnionType, xnkIntersectionType

    # Other
    xnkIdentifier, xnkComment, xnkImport, xnkExport, xnkAttribute
    xnkGenericParameter, xnkParameter, xnkArgument, xnkDecorator,
    # Comments

    xnkTemplateDef, xnkMacroDef, xnkPragma, xnkStaticStmt, xnkDeferStmt,
    xnkAsmStmt, xnkDistinctTypeDef, xnkConceptDef, xnkMixinStmt,
    xnkBindStmt, xnkTupleConstr, xnkTupleUnpacking, xnkUsingStmt




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
    of xnkFuncDecl, xnkMethodDecl:
      funcName*: string
      params*: seq[XLangNode]
      returnType*: Option[XLangNode]
      body*: XLangNode
      isAsync*: bool
    of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
      typeNameDecl*: string
      baseTypes*: seq[XLangNode]
      members*: seq[XLangNode]
    # of xnkLetDecl, xnkConstDecl:
    #   declName: string
    #   declType: Option[XLangNode]
    #   initializer: Option[XLangNode]

    of xnkEnumDecl:
      enumName*: string
      enumMembers*: seq[tuple[name: string, value: Option[XLangNode]]]
    of xnkVarDecl, xnkLetDecl, xnkConstDecl:
      declName*: string
      declType*: Option[XLangNode]
      initializer*: Option[XLangNode]
    of xnkTypeDecl:
      typeDefName*: string
      typeDefBody*: XLangNode
    of xnkPropertyDecl:
      propName*: string
      propType*: XLangNode
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
    of xnkBlockStmt:
      blockBody*: seq[XLangNode]
    of xnkIfStmt:
      ifCondition*: XLangNode
      ifBody*: XLangNode
      elseBody*: Option[XLangNode]
    of xnkSwitchStmt:
      switchExpr*: XLangNode
      switchCases*: seq[XLangNode]  # Contains xnkCaseClause and xnkDefaultClause nodes
    of xnkCaseClause:
      caseValues*: seq[XLangNode]  # Multiple values for case 1, 2, 3:
      caseBody*: XLangNode
      caseFallthrough*: bool  # For Go's fallthrough keyword
    of xnkDefaultClause:
      defaultBody*: XLangNode
    of xnkForStmt:
      forInit*: Option[XLangNode]
      forCond*: Option[XLangNode]
      forIncrement*: Option[XLangNode]
      forBody*: XLangNode
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
    of xnkYieldStmt:
      yieldStmt*: XLangNode
    of xnkBreakStmt, xnkContinueStmt:
      label*: Option[string]
    of xnkThrowStmt:
      throwExpr*: XLangNode
    of xnkAssertStmt:
      assertCond*: XLangNode
      assertMsg*: Option[XLangNode]
    of xnkWithStmt:
      withItems*: seq[tuple[contextExpr: XLangNode, asExpr: Option[XLangNode]]]
      withBody*: XLangNode
    of xnkPassStmt:
      discard
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
      safeNavMember*: string  # For user?.Name
    of xnkNullCoalesceExpr:
      nullCoalesceLeft*: XLangNode  # Left side of ??
      nullCoalesceRight*: XLangNode  # Right side of ??
    of xnkLambdaExpr:
      lambdaParams*: seq[XLangNode]
      lambdaBody*: XLangNode
    of xnkListExpr, xnkSetExpr, xnkTupleExpr:
      elements*: seq[XLangNode]
    of xnkDictExpr:
      keys*: seq[XLangNode]
      values*: seq[XLangNode]
    of xnkComprehensionExpr:
      compExpr*: XLangNode
      compFor*: seq[tuple[vars: seq[XLangNode], iter: XLangNode]]
      compIf*: seq[XLangNode]
    of xnkAwaitExpr:
      awaitExpr*: XLangNode
    of xnkYieldExpr:
      yieldExpr*: Option[XLangNode]
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
      genericArgs*: seq[XLangNode]
    of xnkUnionType, xnkIntersectionType:
      typeMembers*: seq[XLangNode]
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
    of xnkParameter:
      paramName*: string
      paramType*: XLangNode
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
    # else: discard


  XLangAST* = seq[XLangNode]



type
  XLangVersion = tuple[major, minor, patch: int]

  # XLangAST2 = object
  #   version: XLangVersion
  #   root: XLangNode


const SUPPORTED_XLANG_VERSION: XLangVersion = (1, 0, 0)
import strutils
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