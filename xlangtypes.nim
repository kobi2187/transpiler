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
    xnkFieldDecl, xnkConstructorDecl, xnkDestructorDecl, xnkDelegateDecl, xnkEventDecl

    # Statements
    xnkBlockStmt, xnkIfStmt, xnkSwitchStmt, xnkCaseClause, xnkDefaultClause, xnkForStmt, xnkWhileStmt
    xnkDoWhileStmt, xnkForeachStmt, xnkTryStmt, xnkCatchStmt, xnkFinallyStmt
    xnkReturnStmt, xnkYieldStmt, xnkYieldExpr, xnkYieldFromStmt, xnkBreakStmt, xnkContinueStmt
    xnkThrowStmt, xnkAssertStmt, xnkWithStmt, xnkPassStmt,
    xnkDiscardStmt, xnkCaseStmt, xnkRaiseStmt, xnkImportStmt, xnkExportStmt, xnkFromImportStmt

    # Expressions
    xnkBinaryExpr, xnkUnaryExpr, xnkTernaryExpr, xnkCallExpr, xnkIndexExpr,
     xnkSliceExpr, xnkMemberAccessExpr, xnkSafeNavigationExpr, xnkNullCoalesceExpr
     xnkLambdaExpr,
     xnkGeneratorExpr, xnkAwaitExpr, xnkStringInterpolation, xnkDotExpr, xnkBracketExpr
    # Literals
    xnkIntLit, xnkFloatLit, xnkStringLit, xnkCharLit, xnkBoolLit, xnkNoneLit, xnkNilLit

    # Types
    xnkNamedType, xnkArrayType, xnkMapType, xnkFuncType, xnkPointerType
    xnkReferenceType, xnkGenericType, xnkUnionType, xnkIntersectionType

    # Other
    xnkIdentifier, xnkComment, xnkImport, xnkExport, xnkAttribute
    xnkGenericParameter, xnkParameter, xnkArgument, xnkDecorator, xnkLambdaProc, xnkArrowFunc
    # Comments

    xnkTemplateDef, xnkMacroDef, xnkPragma, xnkStaticStmt, xnkDeferStmt,
    xnkAsmStmt, xnkDistinctTypeDef, xnkConceptDef, xnkMixinStmt,
    xnkBindStmt, xnkTupleConstr, xnkTupleUnpacking, xnkUsingStmt,
    xnkDestructureObj, xnkDestructureArray

    xnkMethodReference
    xnkListExpr, xnkSetExpr, xnkTupleExpr, xnkDictExpr, xnkComprehensionExpr



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
      receiver*: Option[XLangNode]     # <- method-specific field
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
      lambdaReturnType*: Option[XLangNode]
      lambdaBody*: XLangNode
    of xnkLambdaProc:
      lambdaProcParams*: seq[XLangNode]
      lambdaProcReturn*: Option[XLangNode]
      lambdaProcBody*: XLangNode
    of xnkArrowFunc:
      arrowParams*: seq[XLangNode]
      arrowBody*: XLangNode
      arrowReturnType*: Option[XLangNode]
    of xnkMethodReference:
      refObject*: XLangNode
      refMethod*: string
    of xnkListExpr, xnkSetExpr, xnkTupleExpr:
      elements*: seq[XLangNode]
    of xnkDictExpr:
      keys*: seq[XLangNode]
      values*: seq[XLangNode]
    of xnkComprehensionExpr:
      compExpr*: XLangNode
      compFor*: seq[tuple[vars: seq[XLangNode], iter: XLangNode]]
      compIf*: seq[XLangNode]
    of xnkGeneratorExpr:
      genExpr*: XLangNode
      genFor*: seq[tuple[vars: seq[XLangNode], iter: XLangNode]]
      genIf*: seq[XLangNode]
    of xnkAwaitExpr:
      awaitExpr*: XLangNode
    # xnkYieldExpr handled above grouped with xnkYieldStmt
    of xnkStringInterpolation:
      interpParts*: seq[XLangNode]  # Mix of string literals and expressions
      interpIsExpr*: seq[bool]       # True if corresponding part is expression
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
      destructObjFields*: seq[string]  # Field names to extract
      destructObjSource*: XLangNode     # Source object
    of xnkDestructureArray:
      destructArrayVars*: seq[string]   # Variable names for elements
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
    # else: discard


type XLangAST = object
  version: XLangVersion
  root: XLangNode


proc `$`*(node: XLangNode): string =
  if node == nil: return "nil"
  result = $node.kind

proc getChildren*(node: XLangNode) : seq[XLangNode] =
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
  else: return @[]