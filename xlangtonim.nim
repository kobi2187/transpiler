import xlangtypes
import src/helpers
import options, strutils, tables, sets, sequtils, algorithm
import src/my_nim_node

# ==============================================================================
# CONVERSION CONTEXT
# ==============================================================================
#
# Context object that tracks state during XLang → Nim conversion.
# Enables:
# - Knowing current class name for constructors (newPerson not just new)
# - Tracking required imports (tables, options, asyncdispatch)
# - Type inference through symbol tables
# - Scope management (fields vs local variables)

type
  Scope* = ref object
    kind*: ScopeKind
    node*: Option[XLangNode]  # The node that created this scope
    symbols*: Table[string, XLangNode]  # Symbols declared in this scope

  ScopeKind* = enum
    skModule, skClass, skFunction, skBlock, skLoop

  ConversionContext* = ref object
    # ===== Current Scope Context (XLangNode references) =====
    currentClass*: Option[XLangNode]
    # ^ The xnkClassDecl/xnkInterfaceDecl we're inside
    # Gives access to: className, classGenerics, classFields, classMethods, etc.

    currentFunction*: Option[XLangNode]
    # ^ The xnkFuncDecl/xnkMethodDecl we're inside
    # Gives access to: funcName, returnType, params, isAsync, etc.

    currentNamespace*: Option[XLangNode]
    # ^ The xnkNamespace we're inside
    # Gives access to: namespace path

    currentModule*: Option[XLangNode]
    # ^ The xnkFile/xnkModule being converted
    # Gives access to: moduleName, all top-level declarations

    # ===== Symbol Tables (XLangNode references) =====
    types*: Table[string, XLangNode]
    # ^ All type declarations: xnkClassDecl, xnkInterfaceDecl, xnkEnumDecl
    # Key: type name, Value: the declaration node

    variables*: Table[string, XLangNode]
    # ^ All variable declarations: xnkVarDecl, xnkLetDecl, xnkParamDecl
    # Key: variable name, Value: the declaration node

    functions*: Table[string, XLangNode]
    # ^ All function/method declarations
    # Key: function name, Value: xnkFuncDecl/xnkMethodDecl node

    # ===== Scope Stack =====
    scopeStack*: seq[Scope]
    # ^ Stack of nested scopes (module → class → function → block)

    # ===== Import Tracking =====
    requiredImports*: HashSet[string]
    # ^ Nim modules to import (tables, options, asyncdispatch, etc.)

# ===== Context Creation =====
proc newContext*(): ConversionContext =
  result = ConversionContext(
    currentClass: none(XLangNode),
    currentFunction: none(XLangNode),
    currentNamespace: none(XLangNode),
    currentModule: none(XLangNode),
    types: initTable[string, XLangNode](),
    variables: initTable[string, XLangNode](),
    functions: initTable[string, XLangNode](),
    scopeStack: @[],
    requiredImports: initHashSet[string]()
  )

# ===== Import Management =====
proc addImport*(ctx: ConversionContext, module: string) =
  ## Track that a Nim module needs to be imported
  ctx.requiredImports.incl(module)

proc getImports*(ctx: ConversionContext): seq[string] =
  ## Get sorted list of required imports
  result = toSeq(ctx.requiredImports)
  result.sort()

# ===== Context Modification (for entering/exiting scopes) =====
proc setCurrentClass*(ctx: ConversionContext, classNode: XLangNode) =
  ## Set the current class being converted
  ctx.currentClass = some(classNode)

proc clearCurrentClass*(ctx: ConversionContext) =
  ## Clear the current class context
  ctx.currentClass = none(XLangNode)

proc setCurrentFunction*(ctx: ConversionContext, funcNode: XLangNode) =
  ## Set the current function being converted
  ctx.currentFunction = some(funcNode)

proc clearCurrentFunction*(ctx: ConversionContext) =
  ## Clear the current function context
  ctx.currentFunction = none(XLangNode)

proc setCurrentNamespace*(ctx: ConversionContext, nsNode: XLangNode) =
  ## Set the current namespace
  ctx.currentNamespace = some(nsNode)

proc clearCurrentNamespace*(ctx: ConversionContext) =
  ctx.currentNamespace = none(XLangNode)

# ===== Scope Management =====
proc enterScope*(ctx: ConversionContext, kind: ScopeKind, node: XLangNode = nil) =
  ## Enter a new scope (class, function, block, etc.)
  let scopeNode = if node.isNil: none(XLangNode) else: some(node)
  ctx.scopeStack.add(Scope(
    kind: kind,
    node: scopeNode,
    symbols: initTable[string, XLangNode]()
  ))

proc exitScope*(ctx: ConversionContext) =
  ## Exit the current scope
  if ctx.scopeStack.len > 0:
    discard ctx.scopeStack.pop()

proc currentScope*(ctx: ConversionContext): Scope =
  ## Get the current scope
  if ctx.scopeStack.len > 0:
    result = ctx.scopeStack[^1]
  else:
    # Return empty scope if none exists
    result = Scope(
      kind: skModule,
      node: none(XLangNode),
      symbols: initTable[string, XLangNode]()
    )

# ===== Symbol Declaration =====
proc declareType*(ctx: ConversionContext, name: string, node: XLangNode) =
  ## Register a type declaration (class, interface, enum)
  ctx.types[name] = node
  if ctx.scopeStack.len > 0:
    ctx.currentScope().symbols[name] = node

proc declareVariable*(ctx: ConversionContext, name: string, node: XLangNode) =
  ## Register a variable in current scope
  ctx.variables[name] = node
  if ctx.scopeStack.len > 0:
    ctx.currentScope().symbols[name] = node

proc declareFunction*(ctx: ConversionContext, name: string, node: XLangNode) =
  ## Register a function/method
  ctx.functions[name] = node
  if ctx.scopeStack.len > 0:
    ctx.currentScope().symbols[name] = node

# ===== Symbol Lookup =====
proc lookupType*(ctx: ConversionContext, name: string): Option[XLangNode] =
  ## Look up a type declaration
  if name in ctx.types:
    result = some(ctx.types[name])
  else:
    result = none(XLangNode)

proc lookupVariable*(ctx: ConversionContext, name: string): Option[XLangNode] =
  ## Look up a variable (searches scopes from innermost to outermost)
  # Search scope stack from innermost to outermost
  for i in countdown(ctx.scopeStack.len - 1, 0):
    let scope = ctx.scopeStack[i]
    if name in scope.symbols:
      return some(scope.symbols[name])

  # Not in any scope
  result = none(XLangNode)

proc lookupFunction*(ctx: ConversionContext, name: string): Option[XLangNode] =
  ## Look up a function declaration
  if name in ctx.functions:
    result = some(ctx.functions[name])
  else:
    result = none(XLangNode)

# ===== Class Context Helpers =====
proc isInClassScope*(ctx: ConversionContext): bool =
  ## Check if we're currently inside a class
  ctx.currentClass.isSome()

proc getClassName*(ctx: ConversionContext): string =
  ## Get the name of the current class (or empty string)
  if ctx.currentClass.isSome():
    result = ctx.currentClass.get().typeNameDecl
  else:
    result = ""

proc isClassField*(ctx: ConversionContext, name: string): bool =
  ## Check if a name is a field of the current class
  if ctx.currentClass.isSome():
    let classNode = ctx.currentClass.get()
    for member in classNode.members:
      if member.kind == xnkFieldDecl and member.fieldName == name:
        return true
  return false

# ===== Function Context Helpers =====
proc isInFunctionScope*(ctx: ConversionContext): bool =
  ## Check if we're currently inside a function
  ctx.currentFunction.isSome()

proc isInAsyncFunction*(ctx: ConversionContext): bool =
  ## Check if we're in an async function
  if ctx.currentFunction.isSome():
    return ctx.currentFunction.get().isAsync
  return false

# ===== RAII-style Context Templates =====
template withClassContext*(ctx: ConversionContext, classNode: XLangNode, body: untyped) =
  ## Execute body with class context set
  ## Automatically enters/exits scope and sets/clears currentClass
  let prevClass = ctx.currentClass
  ctx.setCurrentClass(classNode)
  ctx.enterScope(skClass, classNode)
  try:
    body
  finally:
    ctx.exitScope()
    if prevClass.isSome():
      ctx.setCurrentClass(prevClass.get())
    else:
      ctx.clearCurrentClass()

template withFunctionContext*(ctx: ConversionContext, funcNode: XLangNode, body: untyped) =
  ## Execute body with function context set
  let prevFunc = ctx.currentFunction
  ctx.setCurrentFunction(funcNode)
  ctx.enterScope(skFunction, funcNode)
  try:
    body
  finally:
    ctx.exitScope()
    if prevFunc.isSome():
      ctx.setCurrentFunction(prevFunc.get())
    else:
      ctx.clearCurrentFunction()

# Track warnings for unsupported constructs
type TranspileWarning* = object
  kind*: XLangNodeKind
  message*: string
  location*: string  # Could be file:line if available

var transpileWarnings*: seq[TranspileWarning] = @[]

proc addWarning(kind: XLangNodeKind, msg: string, loc: string = "") =
  transpileWarnings.add(TranspileWarning(kind: kind, message: msg, location: loc))

proc clearWarnings*() =
  transpileWarnings.setLen(0)

# ==============================================================================
# CONSTRUCTS THAT SHOULD BE LOWERED BY TRANSFORM PASSES
# ==============================================================================
#
# The following XLang constructs should NOT reach the final xlang→nim converter.
# They must be transformed by earlier passes in the transform pipeline:
#
# Language-Specific Constructs:
#   xnkPropertyDecl         → property_to_procs.nim (C# properties to getter/setter procs)
#   xnkEventDecl            → csharp_events.nim (C# events to callback patterns)
#   xnkIndexerDecl          → property_to_procs.nim (C# indexers to [] operators)
#   xnkUsingStmt            → csharp_using.nim (C# using to defer pattern)
#   xnkLockStmt             → lock_to_withlock.nim (C# lock to Nim locks module)
#
# Control Flow Transforms:
#   xnkDoWhileStmt          → dowhile_to_while.nim (do-while to while true + break)
#   xnkTernaryExpr          → ternary_to_if.nim (?: to if expression)
#   xnkWithStmt             → with_to_defer.nim (Python with to defer)
#   xnkUnlessStmt           → normalize_simple.nim (unless to if not)
#   xnkUntilStmt            → normalize_simple.nim (until to while not)
#
# Expression Transforms:
#   xnkStringInterpolation  → string_interpolation.nim (f"..." to &"...")
#   xnkNullCoalesceExpr     → null_coalesce.nim (?? to if x != nil)
#   xnkSafeNavigationExpr   → null_coalesce.nim (?. to if x != nil)
#   (xnkConditionalAccessExpr removed - was duplicate of xnkSafeNavigationExpr)
#   xnkComprehensionExpr    → list_comprehension.nim ([x for x in y] to collect)
#   xnkGeneratorExpr        → python_generators.nim (generator expressions)
#
# Type Transforms:
#   xnkUnionType            → union_to_variant.nim (union types to variant objects)
#   xnkIntersectionType     → interface_to_concept.nim (intersection types)
#
# Destructuring:
#   xnkDestructureObj       → destructuring.nim ({a,b} = obj to tuple unpacking)
#   xnkDestructureArray     → destructuring.nim ([a,b] = arr to tuple unpacking)
#
# Advanced Features:
#   xnkIteratorDelegate     → python_generators.nim (yield from to loop + yield)
#   xnkYieldFromStmt        → (deprecated, use xnkIteratorDelegate)
#   xnkAwaitExpr            → async_normalization.nim (await handling)
#   xnkLambdaExpr           → lambda_normalization.nim (complex lambdas)
#   xnkDelegateDecl         → lambda_normalization.nim (delegates to proc types)
#
# If any of these reach the converter, it's a bug in the transform pipeline.
# Use assertLowered() for these constructs.
#
# ==============================================================================

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
proc convertToNimAST*(node: XLangNode, ctx: ConversionContext = nil): MyNimNode

# Helper procs for each XLang node kind — extract case logic here
proc conv_xnkFile(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newStmtList()
  for decl in node.moduleDecls:
    result.add(convertToNimAST(decl, ctx))

proc conv_xnkModule(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # Nim doesn't have a direct equivalent to Java's module system
  # We'll create a comment node to preserve the information
  result = newCommentStmtNode("Module: " & node.moduleName)
  for stmt in node.moduleBody:
    result.add(convertToNimAST(stmt, ctx))

proc conv_xnkNamespace(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newStmtList()
  result.add(newCommentStmtNode("Namespace: " & node.namespaceName))
  for stmt in node.namespaceBody:
    result.add(convertToNimAST(stmt, ctx))

proc conv_xnkFuncDecl_method(node: XLangNode, ctx: ConversionContext): MyNimNode =
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
    formalParams.add(convertToNimAST(node.returnType.get, ctx))
  else:
    formalParams.add(newEmptyNode())
  for param in node.params:
    formalParams.add(convertToNimAST(param, ctx))
  result.add(formalParams)
  # 4: pragmas
  result.add(newEmptyNode())
  # 5: reserved
  result.add(newEmptyNode())
  # 6: body
  result.add(convertToNimAST(node.body, ctx))
  if node.isAsync:
    setPragma(result, newPragma(newIdentNode("async")))

proc conv_xnkClassDecl_structDecl(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # Set class context for converting members (methods, constructors, fields)
  ctx.setCurrentClass(node)
  defer: ctx.clearCurrentClass()  # Ensure cleanup happens even on error

  result = newStmtList()

  # Create type definition with fields only
  let typeSection = newNimNode(nnkTypeSection)
  let typeDef = newNimNode(nnkTypeDef)
  typeDef.add(newIdentNode(node.typeNameDecl))
  typeDef.add(newEmptyNode())
  let refTy = newNimNode(nnkRefTy)
  let objType = newNimNode(nnkObjectTy)
  objType.add(newEmptyNode()) # no pragmas
  # base types / inheritance
  let inheritList = newNimNode(nnkOfInherit)
  for baseType in node.baseTypes:
    inheritList.add(convertToNimAST(baseType, ctx))
  objType.add(inheritList)
  # fields only (not methods/constructors)
  let recList = newNimNode(nnkRecList)
  for member in node.members:
    if member.kind == xnkFieldDecl:
      recList.add(convertToNimAST(member, ctx))
  objType.add(recList)
  refTy.add(objType)
  typeDef.add(refTy)
  typeSection.add(typeDef)
  result.add(typeSection)

  # Add methods and constructors as separate procs
  for member in node.members:
    if member.kind != xnkFieldDecl:
      result.add(convertToNimAST(member, ctx))

proc conv_xnkInterfaceDecl(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let conceptDef = newNimNode(nnkTypeDef)
  conceptDef.add(newIdentNode(node.typeNameDecl))
  conceptDef.add(newEmptyNode())
  let conceptTy = newNimNode(nnkObjectTy)
  for meth in node.members:
    conceptTy.add(convertToNimAST(meth, ctx))
  conceptDef.add(conceptTy)
  result.add(conceptDef)

proc conv_xnkEnumDecl(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let enumTy = newNimNode(nnkEnumTy)
  enumTy.add(newEmptyNode())
  for member in node.enumMembers:
    if member.enumMemberValue.isSome():
      let field = newNimNode(nnkEnumFieldDef)
      field.add(newIdentNode(member.enumMemberName))
      field.add(convertToNimAST(member.enumMemberValue.get, ctx))
      enumTy.add(field)
    else:
      enumTy.add(newIdentNode(member.enumMemberName))
  let typeDef = newNimNode(nnkTypeDef)
  typeDef.add(newIdentNode(node.enumName))
  typeDef.add(newEmptyNode())
  typeDef.add(enumTy)
  result.add(typeDef)

proc conv_xnkVarLetConst(node: XLangNode, ctx: ConversionContext): MyNimNode =
  let kind = if node.kind == xnkVarDecl: nnkVarSection elif node.kind == xnkLetDecl: nnkLetSection else: nnkConstSection
  result = newNimNode(kind)
  let identDefs = newNimNode(nnkIdentDefs)
  identDefs.add(newIdentNode(node.declName))
  if node.declType.isSome():
    identDefs.add(convertToNimAST(node.declType.get, ctx))
  else:
    identDefs.add(newEmptyNode())
  if node.initializer.isSome():
    identDefs.add(convertToNimAST(node.initializer.get, ctx))
  else:
    identDefs.add(newEmptyNode())
  result.add(identDefs)

proc conv_xnkIfStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkIfStmt)
  let branchNode = newNimNode(nnkElifBranch)
  branchNode.add(convertToNimAST(node.ifCondition, ctx))
  branchNode.add(convertToNimAST(node.ifBody, ctx))
  result.add(branchNode)
  if node.elseBody.isSome():
    let elseNode = newNimNode(nnkElse)
    elseNode.add(convertToNimAST(node.elseBody.get, ctx))
    result.add(elseNode)

proc conv_xnkWhileStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkWhileStmt)
  result.add(convertToNimAST(node.whileCondition, ctx))
  result.add(convertToNimAST(node.whileBody, ctx))

proc conv_xnkForStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # Handle C-style or for-in style
  if node.forInit.isSome() and node.forCond.isSome() and node.forIncrement.isSome():
    result = newStmtList()
    result.add(convertToNimAST(node.forInit.get, ctx))
    let whileStmt = newNimNode(nnkWhileStmt)
    whileStmt.add(convertToNimAST(node.forCond.get, ctx))
    let body = newStmtList()
    body.add(convertToNimAST(node.forBody.get, ctx))
    body.add(convertToNimAST(node.forIncrement.get, ctx))
    whileStmt.add(body)
    result.add(whileStmt)
  else:
    # fallback: map to a simple for stmt if a foreach-like structure exists
    result = newNimNode(nnkForStmt)
    if node.forBody.isSome():
      result.add(convertToNimAST(node.forBody.get, ctx))
    else:
      result.add(newEmptyNode())

proc conv_xnkBlockStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # xlangtypes: blockBody is a seq[XLangNode]
  let body = newStmtList()
  for stmt in node.blockBody:
    body.add(convertToNimAST(stmt, ctx))
  result = newBlockStmt(newEmptyNode(), body)

# Patch member access and index kinds to xlangtypes style
proc conv_xnkMemberAccess(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkDotExpr)
  result.add(convertToNimAST(node.memberExpr, ctx))
  result.add(newIdentNode(node.memberName))

proc conv_xnkIndexExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  result.add(convertToNimAST(node.indexExpr, ctx))
  for arg in node.indexArgs:
    result.add(convertToNimAST(arg, ctx))

proc conv_xnkReturnStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkReturnStmt)
  if node.returnExpr.isSome:
    result.add(convertToNimAST(node.returnExpr.get, ctx))
  else:
    result.add(newEmptyNode())

## Unified iterator yield: Python yield, C# yield return, Nim yield
proc conv_xnkIteratorYield(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkYieldStmt)
  if node.iteratorYieldValue.isSome:
    result.add(convertToNimAST(node.iteratorYieldValue.get, ctx))
  else:
    result.add(newEmptyNode())

proc conv_xnkDiscardStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkDiscardStmt)
  if node.discardExpr.isSome:
    result.add(convertToNimAST(node.discardExpr.get, ctx))
  else:
    result.add(newEmptyNode())

proc conv_xnkCaseStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkCaseStmt)
  if node.expr.isSome():
    result.add(convertToNimAST(node.expr.get, ctx))
  else:
    result.add(newEmptyNode())
  for branch in node.branches:
    let ofBranch = newNimNode(nnkOfBranch)
    for cond in branch.caseValues:
      ofBranch.add(convertToNimAST(cond, ctx))
    ofBranch.add(convertToNimAST(branch.caseBody, ctx))
    result.add(ofBranch)
  if node.elseBody.isSome:
    let elseBranch = newNimNode(nnkElse)
    elseBranch.add(convertToNimAST(node.elseBody.get, ctx))
    result.add(elseBranch)

proc conv_xnkTryStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkTryStmt)
  result.add(convertToNimAST(node.tryBody, ctx))
  for exceptt in node.catchClauses:
    let exceptBranch = newNimNode(nnkExceptBranch)
    if exceptt.catchType.isSome:
      exceptBranch.add(convertToNimAST(exceptt.catchType.get, ctx))
    exceptBranch.add(convertToNimAST(exceptt.catchBody, ctx))
    result.add(exceptBranch)
  if node.finallyClause.isSome:
    let finallyBranch = newNimNode(nnkFinally)
    finallyBranch.add(convertToNimAST(node.finallyClause.get, ctx))
    result.add(finallyBranch)

proc conv_xnkRaiseStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkRaiseStmt)
  if node.raiseExpr.isSome:
    result.add(convertToNimAST(node.raiseExpr.get, ctx))
  else:
    result.add(newEmptyNode())

proc conv_xnkTypeDecl(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let typeDef = newNimNode(nnkTypeDef)
  typeDef.add(newIdentNode(node.typeDefName))
  typeDef.add(newEmptyNode())
  typeDef.add(convertToNimAST(node.typeDefBody, ctx))
  result.add(typeDef)

proc conv_xnkImportStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkImportStmt)
  for item in node.imports:
    result.add(newIdentNode(item))

proc conv_xnkImport(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkImportStmt)
  result.add(newIdentNode(node.importPath))
  if node.importAlias.isSome:
    result.add(newIdentNode("as"))
    result.add(newIdentNode(node.importAlias.get))

proc conv_xnkExport(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkExportStmt)
  result.add(convertToNimAST(node.exportedDecl, ctx))

proc conv_xnkExportStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkExportStmt)
  for item in node.exports:
    result.add(newIdentNode(item))

proc conv_xnkFromImportStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkFromStmt)
  result.add(newIdentNode(node.module))
  let importList = newNimNode(nnkImportStmt)
  for item in node.fromImports:
    importList.add(newIdentNode(item))
  result.add(importList)

proc conv_xnkGenericParameter(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkGenericParams)
  let identDefs = newNimNode(nnkIdentDefs)
  identDefs.add(newIdentNode(node.genericParamName))
  if node.bounds.len > 0:
    for bound in node.bounds:
      identDefs.add(convertToNimAST(bound, ctx))
  else:
    identDefs.add(newEmptyNode())
  identDefs.add(newEmptyNode())
  result.add(identDefs)

proc conv_xnkIdentifier(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newIdentNode(node.identName)

proc conv_xnkComment(node: XLangNode, ctx: ConversionContext): MyNimNode =
  if node.isDocComment:
    result = newCommentStmtNode("## " & node.commentText)
  else:
    result = newCommentStmtNode("# " & node.commentText)

proc conv_xnkIntLit(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # Parse integer literal value and create integer literal node
  result = newIntLitNode(parseInt(node.literalValue))

proc conv_xnkFloatLit(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newFloatLitNode(parseFloat(node.literalValue))

proc conv_xnkStringLit(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newStrLitNode(node.literalValue)

proc conv_xnkCharLit(node: XLangNode, ctx: ConversionContext): MyNimNode =
  if node.literalValue.len > 0:
    result = newCharNode(node.literalValue[0])
  else:
    result = newCharNode('\0')

proc conv_xnkBoolLit(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newIdentNode(if node.boolValue: "true" else: "false")

proc conv_xnkNilLit(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNilLit()

proc conv_xnkTemplateMacro(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = if node.kind == xnkTemplateDef: newNimNode(nnkTemplateDef) else: newNimNode(nnkMacroDef)
  result.add(newIdentNode(node.name))
  result.add(newEmptyNode())
  result.add(newEmptyNode())
  let formalParams = newNimNode(nnkFormalParams)
  formalParams.add(newEmptyNode())
  for param in node.tplparams:
    formalParams.add(convertToNimAST(param, ctx))
  result.add(formalParams)
  result.add(newEmptyNode())
  result.add(newEmptyNode())
  result.add(convertToNimAST(node.tmplbody, ctx))
  if node.isExported:
    let postfix = newNimNode(nnkPostfix)
    postfix.add(newIdentNode("*"))
    postfix.add(result)
    result = postfix

proc conv_xnkPragma(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkPragma)
  for pragma in node.pragmas:
    result.add(convertToNimAST(pragma, ctx))

proc conv_xnkStaticStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkStaticStmt)
  result.add(convertToNimAST(node.staticBody, ctx))

proc conv_xnkDeferStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkDefer)
  result.add(convertToNimAST(node.staticBody, ctx))

proc conv_xnkAsmStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkAsmStmt)
  result.add(newStrLitNode(node.asmCode))

proc conv_xnkDistinctTypeDef(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let typeDef = newNimNode(nnkTypeDef)
  typeDef.add(newIdentNode(node.distinctName))
  typeDef.add(newEmptyNode())
  let distinctTy = newNimNode(nnkDistinctTy)
  distinctTy.add(convertToNimAST(node.baseType, ctx))
  typeDef.add(distinctTy)
  result.add(typeDef)

proc conv_xnkConceptDef(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let typeDef = newNimNode(nnkTypeDef)
  typeDef.add(newIdentNode(node.conceptName))
  typeDef.add(newEmptyNode())
  let conceptTy = newNimNode(nnkObjectTy)
  conceptTy.add(newEmptyNode())
  conceptTy.add(convertToNimAST(node.conceptBody, ctx))
  typeDef.add(conceptTy)
  result.add(typeDef)

proc conv_xnkMixinStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkMixinStmt)
  for name in node.mixinNames:
    result.add(newIdentNode(name))

proc conv_xnkBindStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkBindStmt)
  for name in node.bindNames:
    result.add(newIdentNode(name))

proc conv_xnkTupleConstr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkTupleConstr)
  for elem in node.tupleElements:
    result.add(convertToNimAST(elem, ctx))

proc conv_xnkTupleUnpacking(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkVarTuple)
  for target in node.unpackTargets:
    result.add(convertToNimAST(target, ctx))
  result.add(newEmptyNode())
  result.add(convertToNimAST(node.unpackExpr, ctx))

## C# using statement → should be lowered to xnkResourceStmt first
## (Keeping stub implementation for now, but should use transform pass)
proc conv_xnkUsingStmt_DEPRECATED(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkUsingStmt)
  result.add(convertToNimAST(node.usingExpr, ctx))
  result.add(convertToNimAST(node.usingBody, ctx))


proc conv_xnkCallExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkCall)
  result.add(convertToNimAST(node.callee, ctx))
  for arg in node.args:
    result.add(convertToNimAST(arg, ctx))

proc conv_xnkDotExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkDotExpr)
  result.add(convertToNimAST(node.dotBase, ctx))
  result.add(convertToNimAST(node.member, ctx))

proc conv_xnkBracketExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  result.add(convertToNimAST(node.base, ctx))
  result.add(convertToNimAST(node.index, ctx))


proc conv_xnkBinaryExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkInfix)
  result.add(convertToNimAST(node.binaryLeft, ctx))
  result.add(newIdentNode(node.binaryOp))
  result.add(convertToNimAST(node.binaryRight, ctx))

proc conv_xnkUnaryExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkPrefix)
  result.add(newIdentNode(node.unaryOp))
  result.add(convertToNimAST(node.unaryOperand, ctx))


# === ADDITIONAL CONVERTER IMPLEMENTATIONS ===

# Constructs that should have been lowered by transforms - assert if we see them
template assertLowered(kind: string): MyNimNode =
  doAssert(false, kind & " should have been lowered by transform passes")
  newNimNode(nnkDiscardStmt)

# Constructs mapped but not yet implemented - return discard with comment
template notYetImpl(kind: string): MyNimNode =
  var n = newNimNode(nnkCommentStmt)
  n.strVal = "TODO: Implement " & kind
  n

# These constructs should have been lowered by transform passes:
# - xnkPropertyDecl → property_to_procs.nim
# - xnkEventDecl → csharp_events.nim
# - xnkDoWhileStmt → dowhile_to_while.nim
# - xnkTernaryExpr → ternary_to_if.nim
# - xnkWithStmt, xnkWithItem → with_to_defer.nim
# - xnkStringInterpolation → string_interpolation.nim
# - xnkNullCoalesceExpr, xnkSafeNavigationExpr → null_coalesce.nim
# - xnkComprehensionExpr → list_comprehension.nim
# - xnkDestructureObj, xnkDestructureArray → destructuring.nim
# - xnkIteratorDelegate → python_generators.nim
# - xnkYieldFromStmt → (deprecated, use xnkIteratorDelegate)
# - (xnkConditionalAccessExpr removed - duplicate of xnkSafeNavigationExpr)
# - xnkUnionType → union_to_variant.nim
proc conv_xnkPropertyDecl(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkPropertyDecl")
proc conv_xnkEventDecl(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkEventDecl")
proc conv_xnkDoWhileStmt(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkDoWhileStmt")
proc conv_xnkTernaryExpr(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkTernaryExpr")
## Python 'with' / C# 'using' → should be lowered to xnkResourceStmt
proc conv_xnkWithStmt(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkWithStmt")
proc conv_xnkUsingStmt(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkUsingStmt")

## Unified resource management → should be lowered to defer pattern
proc conv_xnkResourceStmt(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkResourceStmt")
proc conv_xnkResourceItem(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkResourceItem")
proc conv_xnkWithItem(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkWithItem")
proc conv_xnkStringInterpolation(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkStringInterpolation")
proc conv_xnkNullCoalesceExpr(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkNullCoalesceExpr")
proc conv_xnkSafeNavigationExpr(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkSafeNavigationExpr")
proc conv_xnkComprehensionExpr(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkComprehensionExpr")
proc conv_xnkDestructureObj(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkDestructureObj")
proc conv_xnkDestructureArray(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkDestructureArray")
proc conv_xnkIteratorDelegate(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkIteratorDelegate")
# Legacy yield nodes (deprecated - unified into xnkIteratorYield):
proc conv_xnkYieldStmt(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkYieldStmt")
proc conv_xnkYieldExpr(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkYieldExpr")
proc conv_xnkYieldFromStmt(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkYieldFromStmt")
# xnkConditionalAccessExpr removed - was duplicate of xnkSafeNavigationExpr

# ==== SIMPLE DIRECT MAPPINGS ====

## C#: `this.x`
## Nim: `self.x`
proc conv_xnkThisExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  newIdentNode("self")

## C#: `break;`
## Nim: `break`
proc conv_xnkBreakStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  newNimNode(nnkBreakStmt)

## C#: `continue;`
## Nim: `continue`
proc conv_xnkContinueStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  newNimNode(nnkContinueStmt)

## C#: `;` or empty statement
## Nim: (empty node)
proc conv_xnkEmptyStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  newNimNode(nnkEmpty)

## Python: `pass`
## Nim: `discard`
proc conv_xnkPassStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  newNimNode(nnkDiscardStmt)

## Python: `None` or C#: `null`
## Nim: `nil`
proc conv_xnkNoneLit(node: XLangNode, ctx: ConversionContext): MyNimNode =
  newIdentNode("nil")

## C#: `[Attribute]` (discarded - Nim uses pragmas differently)
## Nim: (discarded)
proc conv_xnkAttribute(node: XLangNode, ctx: ConversionContext): MyNimNode =
  newNimNode(nnkDiscardStmt)

## C#: `abstract void Foo();` (no body in Nim)
## Nim: (discarded - interface handles this)
proc conv_xnkAbstractDecl(node: XLangNode, ctx: ConversionContext): MyNimNode =
  newNimNode(nnkDiscardStmt)

proc conv_xnkAbstractType(node: XLangNode, ctx: ConversionContext): MyNimNode =
  newNimNode(nnkDiscardStmt)

## Metadata/annotations
## Nim: (discarded)
proc conv_xnkMetadata(node: XLangNode, ctx: ConversionContext): MyNimNode =
  newNimNode(nnkDiscardStmt)

## Unknown constructs
## Nim: `discard`
proc conv_xnkUnknown(node: XLangNode, ctx: ConversionContext): MyNimNode =
  newNimNode(nnkDiscardStmt)

# ==== DECLARATIONS NEEDING IMPLEMENTATION ====

## Python: `def gen(): yield x` or C#: `IEnumerable<T> Gen()`
## Nim: `iterator gen(): T = yield x`
proc conv_xnkIteratorDecl(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkIteratorDef)
  result.add(newIdentNode(node.iteratorName))
  result.add(newEmptyNode())  # term-rewriting
  result.add(newEmptyNode())  # generic params

  let formalParams = newNimNode(nnkFormalParams)
  if node.iteratorReturnType.isSome():
    formalParams.add(convertToNimAST(node.iteratorReturnType.get, ctx))
  else:
    formalParams.add(newEmptyNode())

  for param in node.iteratorParams:
    formalParams.add(convertToNimAST(param, ctx))

  result.add(formalParams)
  result.add(newEmptyNode())  # pragmas
  result.add(newEmptyNode())  # reserved
  result.add(convertToNimAST(node.iteratorBody, ctx))

## C#: `int x;` or `private int x = 5;`
## Nim: `var x: int` or `var x: int = 5`
proc conv_xnkFieldDecl(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkIdentDefs)
  result.add(newIdentNode(node.fieldName))
  result.add(convertToNimAST(node.fieldType, ctx))
  if node.fieldInitializer.isSome():
    result.add(convertToNimAST(node.fieldInitializer.get, ctx))
  else:
    result.add(newEmptyNode())
## C#: `MyClass() { }` → Constructor
## Nim: `proc initMyClass(): MyClass =`
## Constructor declaration
## C#:   public MyClass(int x) { this.x = x; }
## Java: public MyClass(int x) { this.x = x; }
## Nim:  proc newMyClass(x: int): MyClass = result.x = x
proc conv_xnkConstructorDecl(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # NOTE: In Nim, constructors are factory procs named `new<TypeName>`
  # The type name comes from the current class context
  result = newNimNode(nnkProcDef)

  # Proc name - use context to get class name
  let className = ctx.getClassName()
  let procName = if className.len > 0: "new" & className else: "new"
  result.add(newIdentNode(procName))

  # Empty term-rewriting template
  result.add(newEmptyNode())

  # Empty generic params
  result.add(newEmptyNode())

  # Formal params
  let formalParams = newNimNode(nnkFormalParams)

  # Return type - use the class type from context
  if className.len > 0:
    formalParams.add(newIdentNode(className))
  else:
    formalParams.add(newEmptyNode())

  # Parameters
  for param in node.constructorParams:
    formalParams.add(convertToNimAST(param, ctx))

  result.add(formalParams)

  # Empty pragmas
  result.add(newEmptyNode())

  # Empty reserved
  result.add(newEmptyNode())

  # Body
  let body = newNimNode(nnkStmtList)

  # Add initializers first (field assignments)
  for init in node.constructorInitializers:
    body.add(convertToNimAST(init, ctx))

  # Add constructor body
  if not node.constructorBody.isNil:
    if node.constructorBody.kind == xnkBlockStmt:
      for stmt in node.constructorBody.blockBody:
        body.add(convertToNimAST(stmt, ctx))
    else:
      body.add(convertToNimAST(node.constructorBody, ctx))

  result.add(body)

## C#: `~MyClass()` → Destructor (Nim has no destructors)
## Nim: (discarded or use destructor hooks)
proc conv_xnkDestructorDecl(node: XLangNode, ctx: ConversionContext): MyNimNode =
  newNimNode(nnkDiscardStmt)

## C#: `delegate void D(int x);`
## Nim: `type D = proc(x: int)`
proc conv_xnkDelegateDecl(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let typeDef = newNimNode(nnkTypeDef)
  typeDef.add(newIdentNode(node.delegateName))
  typeDef.add(newEmptyNode())

  # Create proc type
  let procTy = newNimNode(nnkProcTy)
  let formalParams = newNimNode(nnkFormalParams)

  if node.delegateReturnType.isSome():
    formalParams.add(convertToNimAST(node.delegateReturnType.get, ctx))
  else:
    formalParams.add(newEmptyNode())  # void

  for param in node.delegateParams:
    formalParams.add(convertToNimAST(param, ctx))

  procTy.add(formalParams)
  procTy.add(newEmptyNode())  # pragmas
  typeDef.add(procTy)
  result.add(typeDef)

## C#: `int this[int i] { get; }`
## Nim: proc `[]` and `[]=` operators (lowered by indexer_to_procs.nim)
proc conv_xnkIndexerDecl(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkIndexerDecl")

## Operator overload declaration
## C#:      static Vector operator+(Vector a, Vector b) { ... }
## C++:     Vector operator+(const Vector& a, const Vector& b) { ... }
## Python:  def __add__(self, other): ...
## Nim:     proc `+`(a, b: Vector): Vector = ...
proc conv_xnkOperatorDecl(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkProcDef)

  # Operator name with backticks (e.g., `+`, `-`, `*`)
  result.add(newIdentNode("`" & node.operatorSymbol & "`"))

  # Empty term-rewriting template
  result.add(newEmptyNode())

  # Empty generic params
  result.add(newEmptyNode())

  # Formal params
  let formalParams = newNimNode(nnkFormalParams)

  # Return type
  formalParams.add(convertToNimAST(node.operatorReturnType, ctx))

  # Parameters
  for param in node.operatorParams:
    formalParams.add(convertToNimAST(param, ctx))

  result.add(formalParams)

  # Empty pragmas
  result.add(newEmptyNode())

  # Empty reserved
  result.add(newEmptyNode())

  # Body
  let body = newNimNode(nnkStmtList)
  if node.operatorBody.kind == xnkBlockStmt:
    for stmt in node.operatorBody.blockBody:
      body.add(convertToNimAST(stmt, ctx))
  else:
    body.add(convertToNimAST(node.operatorBody, ctx))

  result.add(body)

proc conv_xnkConversionOperatorDecl(node: XLangNode, ctx: ConversionContext): MyNimNode = notYetImpl("xnkConversionOperatorDecl")
proc conv_xnkEnumMember(node: XLangNode, ctx: ConversionContext): MyNimNode = notYetImpl("xnkEnumMember")

## C: `extern void foo(int x);`
## Nim: `proc foo(x: cint) {.importc.}`
proc conv_xnkCFuncDecl(node: XLangNode, ctx: ConversionContext): MyNimNode = notYetImpl("xnkCFuncDecl")

proc conv_xnkExternalVar(node: XLangNode, ctx: ConversionContext): MyNimNode = notYetImpl("xnkExternalVar")
proc conv_xnkLibDecl(node: XLangNode, ctx: ConversionContext): MyNimNode = notYetImpl("xnkLibDecl")

## C#: `foreach (var x in arr) { }`
## Nim: `for x in arr:`
proc conv_xnkForeachStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkForStmt)
  result.add(convertToNimAST(node.foreachVar, ctx))
  result.add(convertToNimAST(node.foreachIter, ctx))
  result.add(convertToNimAST(node.foreachBody, ctx))

## C#: `catch (Exception e) { }`
## Nim: `except e:`
proc conv_xnkCatchStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkExceptBranch)
  # Exception type
  if node.catchType.isSome():
    result.add(convertToNimAST(node.catchType.get, ctx))
  else:
    result.add(newEmptyNode())
  # Exception variable (if named)
  if node.catchVar.isSome():
    result.add(newIdentNode(node.catchVar.get))
  # Body
  result.add(convertToNimAST(node.catchBody, ctx))

## C#: `finally { }`
## Nim: `finally:`
proc conv_xnkFinallyStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkFinally)
  result.add(convertToNimAST(node.finallyBody, ctx))

## (conv_xnkYieldExpr moved to unified iterator yield section - see line 333)

## C#: `throw e;` → Should be migrated to xnkRaiseStmt by parser
## Nim: `raise e`
proc conv_xnkThrowStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # Legacy support: convert throw to raise on the fly
  result = newNimNode(nnkRaiseStmt)
  result.add(convertToNimAST(node.throwExpr, ctx))

## Python/Nim: `raise` or `raise e`  (already defined earlier at line ~368)
## C#: `Debug.Assert(x);`
## Nim: `assert x`
proc conv_xnkAssertStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkCall)
  result.add(newIdentNode("assert"))
  result.add(convertToNimAST(node.assertCond, ctx))
## C#: `myLabel: statement;` (Nim has no goto/labels)
## Nim: (discarded)
proc conv_xnkLabeledStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  convertToNimAST(node.labeledStmt, ctx)  # Just convert the statement, discard label

## C#: `goto label;` (Nim has no goto)
## Nim: (discarded - should restructure code)
proc conv_xnkGotoStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  addWarning(xnkGotoStmt, "goto statement not supported in Nim - code needs restructuring")
  result = newNimNode(nnkCommentStmt)
  result.strVal = "UNSUPPORTED: goto " & node.gotoLabel & " - requires manual restructuring"

## C#: `fixed (int* p = arr) { }` (unsafe pointers)
## Nim: (discarded - use ptr manually)
proc conv_xnkFixedStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  addWarning(xnkFixedStmt, "fixed statement not supported - use ptr manually in Nim")
  result = newNimNode(nnkCommentStmt)
  result.strVal = "UNSUPPORTED: fixed statement - use unsafe pointer operations manually"

## C#: `lock (obj) { }` → should be lowered by lock_to_withlock.nim transform
## Nim: `withLock obj:` or acquire/defer/release pattern
proc conv_xnkLockStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  assertLowered("xnkLockStmt")

## C#: `unsafe { }` (Nim doesn't need unsafe blocks)
## Nim: (just convert body)
proc conv_xnkUnsafeStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  convertToNimAST(node.unsafeBody, ctx)

## C#: `checked { }` / `unchecked { }` (overflow checking)
## Nim: (discarded - Nim has compile-time overflow checks)
proc conv_xnkCheckedStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  convertToNimAST(node.checkedBody, ctx)

## C#: local function inside method
## Nim: nested proc
## C#: Local function inside method
## Nim: Nested proc
proc conv_xnkLocalFunctionStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkProcDef)
  result.add(newIdentNode(node.localFuncName))
  result.add(newEmptyNode())  # term-rewriting
  result.add(newEmptyNode())  # generic params

  # Formal params
  let formalParams = newNimNode(nnkFormalParams)
  if node.localFuncReturnType.isSome():
    formalParams.add(convertToNimAST(node.localFuncReturnType.get, ctx))
  else:
    formalParams.add(newEmptyNode())

  for param in node.localFuncParams:
    formalParams.add(convertToNimAST(param, ctx))

  result.add(formalParams)
  result.add(newEmptyNode())  # pragmas
  result.add(newEmptyNode())  # reserved
  result.add(convertToNimAST(node.localFuncBody, ctx))

## Ruby: `unless x` → `if not x` (lowered by normalize_simple.nim)
proc conv_xnkUnlessStmt(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkUnlessStmt")

## `repeat...until x` → `while not x` (lowered by normalize_simple.nim)
proc conv_xnkUntilStmt(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkUntilStmt")

## C++: `static_assert(x)`
## Nim: `static: assert x`
proc conv_xnkStaticAssert(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkStaticStmt)
  let assertCall = newNimNode(nnkCall)
  assertCall.add(newIdentNode("assert"))
  assertCall.add(convertToNimAST(node.staticAssertCondition, ctx))
  result.add(assertCall)

## C#: `switch (x) { case 1: ...; default: ...; }`
## Nim: `case x: of 1: ...; else: ...`
proc conv_xnkSwitchStmt(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkCaseStmt)
  result.add(convertToNimAST(node.switchExpr, ctx))
  for caseNode in node.switchCases:
    result.add(convertToNimAST(caseNode, ctx))

## C#: `case 1: case 2: statements;`
## Nim: `of 1, 2: statements`
proc conv_xnkCaseClause(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkOfBranch)
  for val in node.caseValues:
    result.add(convertToNimAST(val, ctx))
  result.add(convertToNimAST(node.caseBody, ctx))

## C#: `default: statements;`
## Nim: `else: statements`
proc conv_xnkDefaultClause(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkElse)
  result.add(convertToNimAST(node.defaultBody, ctx))
# ==== EXPRESSION CONVERSIONS ====

## C#/Python: `[1, 2, 3]`
## Nim: `[1, 2, 3]`
## Array literal `[1, 2, 3]` (fixed-size)
## Nim: `[1, 2, 3]`
proc conv_xnkArrayLiteral(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkBracket)
  for elem in node.elements:
    result.add(convertToNimAST(elem, ctx))

## Sequence literal `[1, 2, 3]` (dynamic)
## Nim: `@[1, 2, 3]`
proc conv_xnkSequenceLiteral(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkPrefix)
  result.add(newIdentNode("@"))
  let bracket = newNimNode(nnkBracket)
  for elem in node.elements:
    bracket.add(convertToNimAST(elem, ctx))
  result.add(bracket)

## Set literal `{1, 2, 3}`
## Nim: `{1, 2, 3}`
proc conv_xnkSetLiteral(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkCurly)
  for elem in node.elements:
    result.add(convertToNimAST(elem, ctx))

## Map/Dict literal `{"a": 1, "b": 2}`
## Nim: `{"a": 1, "b": 2}.toTable`
proc conv_xnkMapLiteral(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # Map literals require the tables module
  ctx.addImport("tables")
  result = newNimNode(nnkTableConstr)
  for entry in node.entries:
    result.add(convertToNimAST(entry, ctx))

# Legacy (deprecated - use *Literal):
proc conv_xnkArrayLit(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkArrayLit")
proc conv_xnkListExpr(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkListExpr")
proc conv_xnkSetExpr(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkSetExpr")
proc conv_xnkDictExpr(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkDictExpr")

## Tuple literal `(1, 2, 3)`
## Nim: `(1, 2, 3)`
proc conv_xnkTupleExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkTupleConstr)
  for elem in node.elements:
    result.add(convertToNimAST(elem, ctx))

## Dictionary entry `"key": value`
## Nim: `"key": value`
proc conv_xnkDictEntry(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkExprColonExpr)
  result.add(convertToNimAST(node.key, ctx))
  result.add(convertToNimAST(node.value, ctx))

## Python: `arr[1:3]`
## Nim: `arr[1..3]` or `arr[1..^1]`
proc conv_xnkSliceExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkInfix)
  result.add(newIdentNode(".."))
  if node.sliceStart.isSome():
    result.add(convertToNimAST(node.sliceStart.get, ctx))
  else:
    result.add(newIntLitNode(0))  # Default to 0
  if node.sliceEnd.isSome():
    result.add(convertToNimAST(node.sliceEnd.get, ctx))
  else:
    # Default to ^1 (last element)
    let backwardsIdx = newNimNode(nnkPrefix)
    backwardsIdx.add(newIdentNode("^"))
    backwardsIdx.add(newIntLitNode(1))
    result.add(backwardsIdx)

## C#: `x => x + 1`
## Nim: `proc (x: auto): auto = x + 1`
## Lambda expression (single expression body)
## Python:     lambda x: x * 2
## JavaScript: (x) => x * 2
## C#:         x => x * 2
## Nim:        proc(x: auto): auto = x * 2
proc conv_xnkLambdaExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkLambda)

  # Empty name for anonymous lambda
  result.add(newEmptyNode())

  # Empty term-rewriting template
  result.add(newEmptyNode())

  # Empty generic params
  result.add(newEmptyNode())

  # Formal params: return type + parameters
  let formalParams = newNimNode(nnkFormalParams)

  # Return type (use auto if not specified)
  if node.lambdaReturnType.isSome():
    formalParams.add(convertToNimAST(node.lambdaReturnType.get, ctx))
  else:
    formalParams.add(newIdentNode("auto"))

  # Parameters
  for param in node.lambdaParams:
    formalParams.add(convertToNimAST(param, ctx))

  result.add(formalParams)

  # Empty pragmas
  result.add(newEmptyNode())

  # Empty reserved
  result.add(newEmptyNode())

  # Body (single expression converted to statement list)
  let body = newNimNode(nnkStmtList)
  body.add(convertToNimAST(node.lambdaBody, ctx))
  result.add(body)

## Python/Nim: `proc(x, y): return x + y`
## Nim: `proc(x, y: auto): auto = x + y`
proc conv_xnkLambdaProc(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkLambda)
  result.add(newEmptyNode())  # Empty name
  result.add(newEmptyNode())  # Empty term-rewriting
  result.add(newEmptyNode())  # Empty generic params

  let formalParams = newNimNode(nnkFormalParams)
  if node.lambdaProcReturn.isSome():
    formalParams.add(convertToNimAST(node.lambdaProcReturn.get, ctx))
  else:
    formalParams.add(newIdentNode("auto"))

  for param in node.lambdaProcParams:
    formalParams.add(convertToNimAST(param, ctx))

  result.add(formalParams)
  result.add(newEmptyNode())  # Empty pragmas
  result.add(newEmptyNode())  # Empty reserved

  let body = newNimNode(nnkStmtList)
  body.add(convertToNimAST(node.lambdaProcBody, ctx))
  result.add(body)

## JS: `x => x + 1`
## Nim: `proc (x: auto): auto = x + 1`
proc conv_xnkArrowFunc(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkLambda)
  result.add(newEmptyNode())  # Empty name
  result.add(newEmptyNode())  # Empty term-rewriting
  result.add(newEmptyNode())  # Empty generic params

  let formalParams = newNimNode(nnkFormalParams)
  if node.arrowReturnType.isSome():
    formalParams.add(convertToNimAST(node.arrowReturnType.get, ctx))
  else:
    formalParams.add(newIdentNode("auto"))

  for param in node.arrowParams:
    formalParams.add(convertToNimAST(param, ctx))

  result.add(formalParams)
  result.add(newEmptyNode())  # Empty pragmas
  result.add(newEmptyNode())  # Empty reserved

  # Arrow function body is an expression, wrap in statement list
  let body = newNimNode(nnkStmtList)
  body.add(convertToNimAST(node.arrowBody, ctx))
  result.add(body)

## TypeScript: `x as string`
## Nim: `x`  (type assertion not needed at runtime)
proc conv_xnkTypeAssertion(node: XLangNode, ctx: ConversionContext): MyNimNode =
  convertToNimAST(node.assertExpr, ctx)  # Just convert the expression

## C#: `(T)x`
## Nim: `cast[T](x)` or `T(x)`
proc conv_xnkCastExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkCast)
  result.add(convertToNimAST(node.castType, ctx))
  result.add(convertToNimAST(node.castExpr, ctx))
## C#: `base.Method()`
## Nim: `procCall Method(self)` (needs proper super implementation)
## C#: `base.Method()` or Java: `super.method()`
## Nim: `procCall baseType.method(self)`
proc conv_xnkBaseExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # In Nim, we use procCall to call base implementation
  # For now, just return identifier "procCall" - full implementation needs member access context
  newIdentNode("procCall")

## C#: `ref x` or `&x`
## Nim: `addr x`
proc conv_xnkRefExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkAddr)
  result.add(convertToNimAST(node.refExpr, ctx))

## Instance variable, class variable, global variable
## These are just variable references (identifiers)
## The actual dot expression is handled by xnkDotExpr
proc conv_xnkInstanceVar(node: XLangNode, ctx: ConversionContext): MyNimNode =
  newIdentNode(node.varName)

proc conv_xnkClassVar(node: XLangNode, ctx: ConversionContext): MyNimNode =
  newIdentNode(node.varName)

proc conv_xnkGlobalVar(node: XLangNode, ctx: ConversionContext): MyNimNode =
  newIdentNode(node.varName)

## Nim: `proc = body` literal
proc conv_xnkProcLiteral(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # Just convert the body as anonymous proc
  convertToNimAST(node.procBody, ctx)

## C: Function pointer `void (*f)(int)`
## Nim: `proc(x: int)` (proc type)
proc conv_xnkProcPointer(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # Just return the identifier - proc pointers are first-class in Nim
  newIdentNode(node.procPointerName)

## Any number literal (int/float)
## Nim: parse and create appropriate literal
proc conv_xnkNumberLit(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # Try to parse as int, fallback to float
  try:
    result = newIntLitNode(parseInt(node.literalValue))
  except ValueError:
    result = newFloatLitNode(parseFloat(node.literalValue))

## Ruby: `:symbol`
## Nim: (convert to string or ident)
proc conv_xnkSymbolLit(node: XLangNode, ctx: ConversionContext): MyNimNode =
  newStrLitNode(node.symbolValue)
## Python: `x: Any` or JS: `any`
## Nim: No direct equivalent - use generics or RootObj
proc conv_xnkDynamicType(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # In Nim, we can use RootRef or just "auto" for generic code
  if node.dynamicConstraint.isSome():
    convertToNimAST(node.dynamicConstraint.get, ctx)
  else:
    newIdentNode("RootRef")

## Python: `(x*2 for x in range(10))` → iterator (lowered by generator_expressions.nim)
proc conv_xnkGeneratorExpr(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkGeneratorExpr")
## Async/await expression
## Python:     await asyncFunc()
## JavaScript: await asyncFunc()
## C#:         await AsyncFunc()
## Nim:        await asyncFunc()
proc conv_xnkAwaitExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # Await requires asyncdispatch module
  ctx.addImport("asyncdispatch")
  result = newNimNode(nnkCommand)
  result.add(newIdentNode("await"))
  result.add(convertToNimAST(node.awaitExpr, ctx))
proc conv_xnkCompFor(node: XLangNode, ctx: ConversionContext): MyNimNode = notYetImpl("xnkCompFor")

## C#: `default(T)` or `default`
## Nim: `default(T)` or type-specific defaults
proc conv_xnkDefaultExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  if node.defaultType.isSome():
    result = newNimNode(nnkCall)
    result.add(newIdentNode("default"))
    result.add(convertToNimAST(node.defaultType.get, ctx))
  else:
    # Generic default value
    result = newIdentNode("default")

## C#: `typeof(T)`
## Nim: `T` (type identifier) or `type(value)`
proc conv_xnkTypeOfExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # In Nim, typeof is just the type itself or type() proc
  result = newNimNode(nnkCall)
  result.add(newIdentNode("type"))
  result.add(convertToNimAST(node.typeOfType, ctx))

## C#/C: `sizeof(T)`
## Nim: `sizeof(T)`
proc conv_xnkSizeOfExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkCall)
  result.add(newIdentNode("sizeof"))
  result.add(convertToNimAST(node.sizeOfType, ctx))

## C#: `checked(expr)` - overflow checking
## Nim: Just the expression (Nim checks by default in debug, or use -d:nimOldCaseObjects)
proc conv_xnkCheckedExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # Nim has overflow checking in debug builds, so just convert the expression
  convertToNimAST(node.checkedExpr, ctx)

## C#: `throw new Exception()` as expression (lowered by throw_expression.nim)
proc conv_xnkThrowExpr(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkThrowExpr")

## C#: Switch expression `x switch { 1 => "one", _ => "other" }`
## Nim: Case expression
proc conv_xnkSwitchExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkCaseStmt)
  result.add(convertToNimAST(node.switchExprValue, ctx))
  for arm in node.switchExprArms:
    result.add(convertToNimAST(arm, ctx))
## C#: `stackalloc int[10]`
## Nim: `var arr: array[10, int]` (Nim is stack-allocated by default)
proc conv_xnkStackAllocExpr(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # In Nim, arrays are stack-allocated by default, so create array type
  result = newNimNode(nnkBracketExpr)
  result.add(newIdentNode("array"))
  if node.stackAllocSize.isSome():
    result.add(convertToNimAST(node.stackAllocSize.get, ctx))
  else:
    # Unknown size - use seq instead
    result = newNimNode(nnkBracketExpr)
    result.add(newIdentNode("seq"))
  result.add(convertToNimAST(node.stackAllocType, ctx))

## C#: `new[] { 1, 2, 3 }` - implicit array creation
## Nim: `@[1, 2, 3]` or array literal
proc conv_xnkImplicitArrayCreation(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkPrefix)
  result.add(newIdentNode("@"))
  let bracket = newNimNode(nnkBracket)
  for elem in node.implicitArrayElements:
    bracket.add(convertToNimAST(elem, ctx))
  result.add(bracket)
proc conv_xnkNamedType(node: XLangNode, ctx: ConversionContext): MyNimNode = newIdentNode(node.typeName)

## C#: `int[]` or `int[10]`
## Nim: `seq[int]` or `array[10, int]`
proc conv_xnkArrayType(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  if node.arraySize.isSome():
    # Fixed-size array
    result.add(newIdentNode("array"))
    result.add(convertToNimAST(node.arraySize.get, ctx))
    result.add(convertToNimAST(node.elementType, ctx))
  else:
    # Dynamic array → seq
    result.add(newIdentNode("seq"))
    result.add(convertToNimAST(node.elementType, ctx))

## C#: `Dictionary<K, V>`
## Nim: `Table[K, V]`
proc conv_xnkMapType(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  result.add(newIdentNode("Table"))
  result.add(convertToNimAST(node.keyType, ctx))
  result.add(convertToNimAST(node.valueType, ctx))

## Function type: `(int) -> string`
## Nim: `proc(x: int): string`
proc conv_xnkFuncType(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkProcTy)
  var params = newNimNode(nnkFormalParams)
  # Return type first
  if node.funcReturnType.isSome():
    params.add(convertToNimAST(node.funcReturnType.get, ctx))
  else:
    params.add(newEmptyNode())
  # Parameters
  for param in node.funcParams:
    params.add(convertToNimAST(param, ctx))
  result.add(params)
  result.add(newEmptyNode()) # pragmas

proc conv_xnkFunctionType(node: XLangNode, ctx: ConversionContext): MyNimNode = conv_xnkFuncType(node, ctx)

## C: `int*`
## Nim: `ptr int`
proc conv_xnkPointerType(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkPtrTy)
  result.add(convertToNimAST(node.referentType, ctx))

## C#: `ref T`
## Nim: `ref T`
proc conv_xnkReferenceType(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkRefTy)
  result.add(convertToNimAST(node.referentType, ctx))

## C#: `List<T>`
## Nim: `List[T]`
proc conv_xnkGenericType(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  result.add(newIdentNode(node.genericTypeName))
  for arg in node.genericArgs:
    result.add(convertToNimAST(arg, ctx))
proc conv_xnkUnionType(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkUnionType")

## TypeScript: `A & B` (should be lowered by transform)
proc conv_xnkIntersectionType(node: XLangNode, ctx: ConversionContext): MyNimNode = assertLowered("xnkIntersectionType")

## Nim: `distinct int`
proc conv_xnkDistinctType(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkDistinctTy)
  result.add(convertToNimAST(node.distinctBaseType, ctx))

## Parameter in function signature
## Nim: `x: int` → nnkIdentDefs
proc conv_xnkParameter(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkIdentDefs)
  result.add(newIdentNode(node.paramName))
  if node.paramType.isSome():
    result.add(convertToNimAST(node.paramType.get, ctx))
  else:
    result.add(newEmptyNode())
  if node.defaultValue.isSome():
    result.add(convertToNimAST(node.defaultValue.get, ctx))
  else:
    result.add(newEmptyNode())

## Argument in function call (just the expression)
proc conv_xnkArgument(node: XLangNode, ctx: ConversionContext): MyNimNode =
  convertToNimAST(node.argValue, ctx)
## Python decorator (should be lowered to pragmas or discarded)
proc conv_xnkDecorator(node: XLangNode, ctx: ConversionContext): MyNimNode = newNimNode(nnkDiscardStmt)

proc conv_xnkConceptRequirement(node: XLangNode, ctx: ConversionContext): MyNimNode = notYetImpl("xnkConceptRequirement")
proc conv_xnkConceptDecl(node: XLangNode, ctx: ConversionContext): MyNimNode = notYetImpl("xnkConceptDecl")

## Qualified name: `a.b.c`
## Nim: nested dot expression
proc conv_xnkQualifiedName(node: XLangNode, ctx: ConversionContext): MyNimNode =
  # Recursively build: left.right
  result = newNimNode(nnkDotExpr)
  result.add(convertToNimAST(node.qualifiedLeft, ctx))
  result.add(newIdentNode(node.qualifiedRight))

## Alias qualified name: `alias::Name`
proc conv_xnkAliasQualifiedName(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkDotExpr)
  result.add(newIdentNode(node.aliasQualifier))
  result.add(newIdentNode(node.aliasQualifiedName))

## Generic name: `List<T>`
## Nim: `List[T]` (bracket expression)
proc conv_xnkGenericName(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  result.add(newIdentNode(node.genericNameIdentifier))
  for arg in node.genericNameArgs:
    result.add(convertToNimAST(arg, ctx))

## Method reference: `obj.Method`
## Nim: dot expression
proc conv_xnkMethodReference(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkDotExpr)
  result.add(convertToNimAST(node.refObject, ctx))
  result.add(newIdentNode(node.refMethod))
## Python module (convert to statement list)
proc conv_xnkModuleDecl(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkStmtList)
  for stmt in node.moduleBody:
    result.add(convertToNimAST(stmt, ctx))

## C#: `using X = Y;`
## Nim: `type X = Y`
proc conv_xnkTypeAlias(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkTypeDef)
  result.add(newIdentNode(node.aliasName))
  result.add(newEmptyNode()) # generic params
  result.add(convertToNimAST(node.aliasTarget, ctx))

## Nim: `include "filename"`
proc conv_xnkInclude(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkIncludeStmt)
  result.add(convertToNimAST(node.includeName, ctx))

## Nim mixin statement
proc conv_xnkMixinDecl(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkMixinStmt)
  for name in node.mixinNames:
    result.add(newIdentNode(name))

proc conv_xnkTemplateDecl(node: XLangNode, ctx: ConversionContext): MyNimNode = notYetImpl("xnkTemplateDecl")
proc conv_xnkMacroDecl(node: XLangNode, ctx: ConversionContext): MyNimNode = notYetImpl("xnkMacroDecl")
proc conv_xnkExtend(node: XLangNode, ctx: ConversionContext): MyNimNode = notYetImpl("xnkExtend")
proc conv_xnkTypeSwitchStmt(node: XLangNode, ctx: ConversionContext): MyNimNode = notYetImpl("xnkTypeSwitchStmt")
proc conv_xnkTypeCaseClause(node: XLangNode, ctx: ConversionContext): MyNimNode = notYetImpl("xnkTypeCaseClause")
proc conv_xnkSwitchCase(node: XLangNode, ctx: ConversionContext): MyNimNode = notYetImpl("xnkSwitchCase")
## Assignment statement
## Universal: x = 5, arr[i] = 10, obj.field = "hello"
## Nim: Same syntax
proc conv_xnkAsgn(node: XLangNode, ctx: ConversionContext): MyNimNode =
  result = newNimNode(nnkAsgn)
  result.add(convertToNimAST(node.asgnLeft, ctx))
  result.add(convertToNimAST(node.asgnRight, ctx))


#TODO: support all LOWERED (after transforms) xlangtypes node kinds
proc convertToNimAST*(node: XLangNode, ctx: ConversionContext = nil): MyNimNode =
  # Create temporary context if none provided (for backward compatibility)
  let context = if ctx.isNil: newContext() else: ctx

  case node.kind
  of xnkFile:
    result = conv_xnkFile(node, context)
  of xnkModule:
    result = conv_xnkModule(node, context)
  of xnkNamespace:
    result = conv_xnkNamespace(node, context)
  of xnkFuncDecl, xnkMethodDecl:
    result = conv_xnkFuncDecl_method(node, context)
  of xnkClassDecl, xnkStructDecl:
    result = conv_xnkClassDecl_structDecl(node, context)
  of xnkInterfaceDecl:
    result = conv_xnkInterfaceDecl(node, ctx)
  of xnkEnumDecl:
    result = conv_xnkEnumDecl(node, ctx)
  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    result = conv_xnkVarLetConst(node, ctx)
  of xnkIfStmt:
    result = conv_xnkIfStmt(node, ctx)
  of xnkWhileStmt:
    result = conv_xnkWhileStmt(node, ctx)
  of xnkForStmt:
    result = conv_xnkForStmt(node, ctx)
  of xnkBlockStmt:
    result = conv_xnkBlockStmt(node, ctx)
  of xnkCallExpr:
    result = conv_xnkCallExpr(node, ctx)
  of xnkDotExpr:
    result = conv_xnkDotExpr(node, ctx)
  of xnkMemberAccessExpr:
    result = conv_xnkMemberAccess(node, ctx)
  of xnkBracketExpr:
    result = conv_xnkBracketExpr(node, ctx)
  of xnkIndexExpr:
    result = conv_xnkIndexExpr(node, ctx)
  of xnkBinaryExpr:
    result = conv_xnkBinaryExpr(node, ctx)
  of xnkUnaryExpr:
    result = conv_xnkUnaryExpr(node, ctx)
  of xnkReturnStmt:
    result = conv_xnkReturnStmt(node, ctx)
  of xnkIteratorYield:
    result = conv_xnkIteratorYield(node, ctx)
  of xnkYieldStmt:
    result = conv_xnkYieldStmt(node, ctx)
  of xnkDiscardStmt:
    result = conv_xnkDiscardStmt(node, ctx)
  of xnkCaseStmt:
    result = conv_xnkCaseStmt(node, ctx)
  of xnkTryStmt:
    result = conv_xnkTryStmt(node, ctx)
  of xnkRaiseStmt:
    result = conv_xnkRaiseStmt(node, ctx)
  of xnkTypeDecl:
    result = conv_xnkTypeDecl(node, ctx)
  of xnkImportStmt:
    result = conv_xnkImportStmt(node, ctx)
  of xnkImport:
    result = conv_xnkImport(node, ctx)
  of xnkExport:
    result = conv_xnkExport(node, ctx)
  of xnkExportStmt:
    result = conv_xnkExportStmt(node, ctx)
  of xnkFromImportStmt:
    result = conv_xnkFromImportStmt(node, ctx)
  of xnkGenericParameter:
    result = conv_xnkGenericParameter(node, ctx)
  of xnkIdentifier:
    result = conv_xnkIdentifier(node, ctx)
  of xnkComment:
    result = conv_xnkComment(node, ctx)
  of xnkIntLit:
    result = conv_xnkIntLit(node, ctx)
  of xnkFloatLit:
    result = conv_xnkFloatLit(node, ctx)
  of xnkStringLit:
    result = conv_xnkStringLit(node, ctx)
  of xnkCharLit:
    result = conv_xnkCharLit(node, ctx)
  of xnkBoolLit:
    result = conv_xnkBoolLit(node, ctx)
  of xnkNilLit:
    result = conv_xnkNilLit(node, ctx)
  of xnkTemplateDef, xnkMacroDef:
    result = conv_xnkTemplateMacro(node, ctx)
  of xnkPragma:
    result = conv_xnkPragma(node, ctx)
  of xnkStaticStmt:
    result = conv_xnkStaticStmt(node, ctx)
  of xnkDeferStmt:
    result = conv_xnkDeferStmt(node, ctx)
  of xnkAsmStmt:
    result = conv_xnkAsmStmt(node, ctx)
  of xnkDistinctTypeDef:
    result = conv_xnkDistinctTypeDef(node, ctx)
  of xnkConceptDef:
    result = conv_xnkConceptDef(node, ctx)
  of xnkMixinStmt:
    result = conv_xnkMixinStmt(node, ctx)
  of xnkBindStmt:
    result = conv_xnkBindStmt(node, ctx)
  of xnkTupleConstr:
    result = conv_xnkTupleConstr(node, ctx)
  of xnkTupleUnpacking:
    result = conv_xnkTupleUnpacking(node, ctx)
  of xnkUsingStmt:
    result = conv_xnkUsingStmt(node, ctx)
  
  # TODO: discard (when nim doesn't have it - disappears in transforms) or write conv_ procs after mapping and example of c# code of that construct to expected Nim code.
  of xnkIteratorDecl:
    result = conv_xnkIteratorDecl(node, ctx)
  of xnkPropertyDecl:
    result = conv_xnkPropertyDecl(node, ctx)
  of xnkFieldDecl:
    result = conv_xnkFieldDecl(node, ctx)
  of xnkConstructorDecl:
    result = conv_xnkConstructorDecl(node, ctx)
  of xnkDestructorDecl:
    result = conv_xnkDestructorDecl(node, ctx)
  of xnkDelegateDecl:
    result = conv_xnkDelegateDecl(node, ctx)
  of xnkEventDecl:
    result = conv_xnkEventDecl(node, ctx)
  of xnkModuleDecl:
    result = conv_xnkModuleDecl(node, ctx)
  of xnkTypeAlias:
    result = conv_xnkTypeAlias(node, ctx)
  of xnkAbstractDecl:
    result = conv_xnkAbstractDecl(node, ctx)
  of xnkEnumMember:
    result = conv_xnkEnumMember(node, ctx)
  of xnkIndexerDecl:
    result = conv_xnkIndexerDecl(node, ctx)
  of xnkOperatorDecl:
    result = conv_xnkOperatorDecl(node, ctx)
  of xnkConversionOperatorDecl:
    result = conv_xnkConversionOperatorDecl(node, ctx)
  of xnkAbstractType:
    result = conv_xnkAbstractType(node, ctx)
  of xnkFunctionType:
    result = conv_xnkFunctionType(node, ctx)
  of xnkMetadata:
    result = conv_xnkMetadata(node, ctx)
  of xnkLibDecl:
    result = conv_xnkLibDecl(node, ctx)
  of xnkCFuncDecl:
    result = conv_xnkCFuncDecl(node, ctx)
  of xnkExternalVar:
    result = conv_xnkExternalVar(node, ctx)
  of xnkAsgn:
    result = conv_xnkAsgn(node, ctx)
  of xnkSwitchStmt:
    result = conv_xnkSwitchStmt(node, ctx)
  of xnkCaseClause:
    result = conv_xnkCaseClause(node, ctx)
  of xnkDefaultClause:
    result = conv_xnkDefaultClause(node, ctx)
  of xnkDoWhileStmt:
    result = conv_xnkDoWhileStmt(node, ctx)
  of xnkForeachStmt:
    result = conv_xnkForeachStmt(node, ctx)
  of xnkCatchStmt:
    result = conv_xnkCatchStmt(node, ctx)
  of xnkFinallyStmt:
    result = conv_xnkFinallyStmt(node, ctx)
  of xnkIteratorDelegate:
    result = conv_xnkIteratorDelegate(node, ctx)
  of xnkYieldExpr:
    result = conv_xnkYieldExpr(node, ctx)
  of xnkYieldFromStmt:
    result = conv_xnkYieldFromStmt(node, ctx)
  of xnkBreakStmt:
    result = conv_xnkBreakStmt(node, ctx)
  of xnkContinueStmt:
    result = conv_xnkContinueStmt(node, ctx)
  of xnkThrowStmt:
    result = conv_xnkThrowStmt(node, ctx)
  of xnkAssertStmt:
    result = conv_xnkAssertStmt(node, ctx)
  of xnkWithStmt:
    result = conv_xnkWithStmt(node, ctx)
  of xnkResourceStmt:
    result = conv_xnkResourceStmt(node, ctx)
  of xnkResourceItem:
    result = conv_xnkResourceItem(node, ctx)
  of xnkPassStmt:
    result = conv_xnkPassStmt(node, ctx)
  of xnkTypeSwitchStmt:
    result = conv_xnkTypeSwitchStmt(node, ctx)
  of xnkTypeCaseClause:
    result = conv_xnkTypeCaseClause(node, ctx)
  of xnkWithItem:
    result = conv_xnkWithItem(node, ctx)
  of xnkEmptyStmt:
    result = conv_xnkEmptyStmt(node, ctx)
  of xnkLabeledStmt:
    result = conv_xnkLabeledStmt(node, ctx)
  of xnkGotoStmt:
    result = conv_xnkGotoStmt(node, ctx)
  of xnkFixedStmt:
    result = conv_xnkFixedStmt(node, ctx)
  of xnkLockStmt:
    result = conv_xnkLockStmt(node, ctx)
  of xnkUnsafeStmt:
    result = conv_xnkUnsafeStmt(node, ctx)
  of xnkCheckedStmt:
    result = conv_xnkCheckedStmt(node, ctx)
  of xnkLocalFunctionStmt:
    result = conv_xnkLocalFunctionStmt(node, ctx)
  of xnkUnlessStmt:
    result = conv_xnkUnlessStmt(node, ctx)
  of xnkUntilStmt:
    result = conv_xnkUntilStmt(node, ctx)
  of xnkStaticAssert:
    result = conv_xnkStaticAssert(node, ctx)
  of xnkSwitchCase:
    result = conv_xnkSwitchCase(node, ctx)
  of xnkMixinDecl:
    result = conv_xnkMixinDecl(node, ctx)
  of xnkTemplateDecl:
    result = conv_xnkTemplateDecl(node, ctx)
  of xnkMacroDecl:
    result = conv_xnkMacroDecl(node, ctx)
  of xnkInclude:
    result = conv_xnkInclude(node, ctx)
  of xnkExtend:
    result = conv_xnkExtend(node, ctx)
  of xnkTernaryExpr:
    result = conv_xnkTernaryExpr(node, ctx)
  of xnkSliceExpr:
    result = conv_xnkSliceExpr(node, ctx)
  of xnkSafeNavigationExpr:
    result = conv_xnkSafeNavigationExpr(node, ctx)
  of xnkNullCoalesceExpr:
    result = conv_xnkNullCoalesceExpr(node, ctx)
  # xnkConditionalAccessExpr removed - was duplicate of xnkSafeNavigationExpr
  of xnkLambdaExpr:
    result = conv_xnkLambdaExpr(node, ctx)
  of xnkTypeAssertion:
    result = conv_xnkTypeAssertion(node, ctx)
  of xnkCastExpr:
    result = conv_xnkCastExpr(node, ctx)
  of xnkThisExpr:
    result = conv_xnkThisExpr(node, ctx)
  of xnkBaseExpr:
    result = conv_xnkBaseExpr(node, ctx)
  of xnkRefExpr:
    result = conv_xnkRefExpr(node, ctx)
  of xnkInstanceVar:
    result = conv_xnkInstanceVar(node, ctx)
  of xnkClassVar:
    result = conv_xnkClassVar(node, ctx)
  of xnkGlobalVar:
    result = conv_xnkGlobalVar(node, ctx)
  of xnkProcLiteral:
    result = conv_xnkProcLiteral(node, ctx)
  of xnkProcPointer:
    result = conv_xnkProcPointer(node, ctx)
  of xnkArrayLit:
    result = conv_xnkArrayLit(node, ctx)
  of xnkNumberLit:
    result = conv_xnkNumberLit(node, ctx)
  of xnkSymbolLit:
    result = conv_xnkSymbolLit(node, ctx)
  of xnkDynamicType:
    result = conv_xnkDynamicType(node, ctx)
  of xnkGeneratorExpr:
    result = conv_xnkGeneratorExpr(node, ctx)
  of xnkAwaitExpr:
    result = conv_xnkAwaitExpr(node, ctx)
  of xnkStringInterpolation:
    result = conv_xnkStringInterpolation(node, ctx)
  of xnkCompFor:
    result = conv_xnkCompFor(node, ctx)
  of xnkDefaultExpr:
    result = conv_xnkDefaultExpr(node, ctx)
  of xnkTypeOfExpr:
    result = conv_xnkTypeOfExpr(node, ctx)
  of xnkSizeOfExpr:
    result = conv_xnkSizeOfExpr(node, ctx)
  of xnkCheckedExpr:
    result = conv_xnkCheckedExpr(node, ctx)
  of xnkThrowExpr:
    result = conv_xnkThrowExpr(node, ctx)
  of xnkSwitchExpr:
    result = conv_xnkSwitchExpr(node, ctx)
  of xnkStackAllocExpr:
    result = conv_xnkStackAllocExpr(node, ctx)
  of xnkImplicitArrayCreation:
    result = conv_xnkImplicitArrayCreation(node, ctx)
  of xnkNoneLit:
    result = conv_xnkNoneLit(node, ctx)
  of xnkNamedType:
    result = conv_xnkNamedType(node, ctx)
  of xnkArrayType:
    result = conv_xnkArrayType(node, ctx)
  of xnkMapType:
    result = conv_xnkMapType(node, ctx)
  of xnkFuncType:
    result = conv_xnkFuncType(node, ctx)
  of xnkPointerType:
    result = conv_xnkPointerType(node, ctx)
  of xnkReferenceType:
    result = conv_xnkReferenceType(node, ctx)
  of xnkGenericType:
    result = conv_xnkGenericType(node, ctx)
  of xnkUnionType:
    result = conv_xnkUnionType(node, ctx)
  of xnkIntersectionType:
    result = conv_xnkIntersectionType(node, ctx)
  of xnkDistinctType:
    result = conv_xnkDistinctType(node, ctx)
  of xnkAttribute:
    result = conv_xnkAttribute(node, ctx)
  of xnkParameter:
    result = conv_xnkParameter(node, ctx)
  of xnkArgument:
    result = conv_xnkArgument(node, ctx)
  of xnkDecorator:
    result = conv_xnkDecorator(node, ctx)
  of xnkLambdaProc:
    result = conv_xnkLambdaProc(node, ctx)
  of xnkArrowFunc:
    result = conv_xnkArrowFunc(node, ctx)
  of xnkConceptRequirement:
    result = conv_xnkConceptRequirement(node, ctx)
  of xnkQualifiedName:
    result = conv_xnkQualifiedName(node, ctx)
  of xnkAliasQualifiedName:
    result = conv_xnkAliasQualifiedName(node, ctx)
  of xnkGenericName:
    result = conv_xnkGenericName(node, ctx)
  of xnkUnknown:
    result = conv_xnkUnknown(node, ctx)
  of xnkConceptDecl:
    result = conv_xnkConceptDecl(node, ctx)
  of xnkDestructureObj:
    result = conv_xnkDestructureObj(node, ctx)
  of xnkDestructureArray:
    result = conv_xnkDestructureArray(node, ctx)
  of xnkMethodReference:
    result = conv_xnkMethodReference(node, ctx)
  of xnkSequenceLiteral:
    result = conv_xnkSequenceLiteral(node, ctx)
  of xnkSetLiteral:
    result = conv_xnkSetLiteral(node, ctx)
  of xnkMapLiteral:
    result = conv_xnkMapLiteral(node, ctx)
  of xnkArrayLiteral:
    result = conv_xnkArrayLiteral(node, ctx)
  of xnkListExpr:
    result = conv_xnkListExpr(node, ctx)
  of xnkSetExpr:
    result = conv_xnkSetExpr(node, ctx)
  of xnkTupleExpr:
    result = conv_xnkTupleExpr(node, ctx)
  of xnkDictExpr:
    result = conv_xnkDictExpr(node, ctx)
  of xnkComprehensionExpr:
    result = conv_xnkComprehensionExpr(node, ctx)
  of xnkDictEntry:
    result = conv_xnkDictEntry(node, ctx)


  # else:
  #   raise newException(ValueError, "Unsupported XLang node kind: " & $node.kind)



# # proc convertXLangASTToNimAST*(xlangAST: XLangAST): MyNimNode =
# #   result = newStmtList()
# #   for node in xlangAST:
# #     result.add(convertToNimAST(node, ctx))

# # Example usage
# when isMainModule:
#   let xlangAST = XLangNode(kind: xnkFile, fileName: "example.nim", declarations: @[
#     XLangNode(kind: xnkFuncDecl, funcName: "main", params: @[], returnType: none(XLangNode),
#       body: XLangNode(kind: xnkBlockStmt, body: @[
#         XLangNode(kind: xnkCallExpr, callee: XLangNode(kind: xnkIdentifier, identName: "echo"),
#                  args: @[XLangNode(kind: xnkStringLit, literalValue: "Hello, World!")])
#       ])
#     )
#   ])

#   let nimAST = convertToNimAST(xlangAST, ctx)
#   echo nimAST.repr