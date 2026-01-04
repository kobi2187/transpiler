import core/xlangtypes
import core/helpers
import ../../helpers
import options, strutils, tables, sets, sequtils, algorithm, os
import my_nim_node
import naming_conventions
import semantic/semantic_analysis
import transforms/transform_context
import error_collector
import uuid4

# ==============================================================================
# NOTE: ConversionContext has been replaced by TransformContext
# TransformContext (from transforms/transform_context) now handles all conversion state
# ==============================================================================

# Helper functions for TransformContext (conversion-specific)
# These were previously methods on ConversionContext but are now standalone procs

proc isInClassScope*(ctx: TransformContext): bool =
  ## Check if we're currently inside a class
  ctx.conversion.currentClass.isSome()

proc getClassName*(ctx: TransformContext): string =
  ## Get the name of the current class (or empty string)
  if ctx.conversion.currentClass.isSome():
    result = ctx.conversion.currentClass.get().typeNameDecl
  else:
    result = ""

proc isClassField*(ctx: TransformContext, name: string): bool =
  ## Check if a name is a field of the current class
  if ctx.conversion.currentClass.isSome():
    let classNode = ctx.conversion.currentClass.get()
    for member in classNode.members:
      if member.kind == xnkFieldDecl and member.fieldName == name:
        return true
  return false

proc classHasBaseTypes*(ctx: TransformContext): bool =
  ## Check if the current class has any base types (inheritance)
  if ctx.conversion.currentClass.isSome():
    let classNode = ctx.conversion.currentClass.get()
    return classNode.baseTypes.len > 0
  return false

proc isInFunctionScope*(ctx: TransformContext): bool =
  ## Check if we're currently inside a function
  ctx.conversion.currentFunction.isSome()

proc isInAsyncFunction*(ctx: TransformContext): bool =
  ## Check if we're in an async function
  if ctx.conversion.currentFunction.isSome():
    return ctx.conversion.currentFunction.get().isAsync
  return false

proc addImport*(ctx: TransformContext, module: string) =
  ## Track that a Nim module needs to be imported
  ctx.conversion.requiredImports.incl(module)

proc getImports*(ctx: TransformContext): seq[string] =
  ## Get sorted list of required imports
  result = toSeq(ctx.conversion.requiredImports)
  result.sort()

proc setCurrentClass*(ctx: TransformContext, classNode: XLangNode) =
  ## Set the current class being converted
  ctx.conversion.currentClass = some(classNode)

proc clearCurrentClass*(ctx: TransformContext) =
  ## Clear the current class context
  ctx.conversion.currentClass = none(XLangNode)

proc setCurrentFunction*(ctx: TransformContext, funcNode: XLangNode) =
  ## Set the current function being converted
  ctx.conversion.currentFunction = some(funcNode)

proc clearCurrentFunction*(ctx: TransformContext) =
  ## Clear the current function context
  ctx.conversion.currentFunction = none(XLangNode)

proc setCurrentNamespace*(ctx: TransformContext, nsNode: XLangNode) =
  ## Set the current namespace
  ctx.conversion.currentNamespace = some(nsNode)

proc clearCurrentNamespace*(ctx: TransformContext) =
  ctx.conversion.currentNamespace = none(XLangNode)

proc newMinimalContext*(): TransformContext =
  ## Create a minimal TransformContext for backward compatibility
  ## when no semantic analysis or error collection is needed
  let emptySemanticInfo = SemanticInfo(
    nodeToSymbol: initTable[XLangNode, Symbol](),
    declToSymbol: initTable[XLangNode, Symbol](),
    nodeToScope: initTable[XLangNode, Scope](),
    allSymbols: @[],
    allScopes: @[],
    symbolById: initTable[Uuid, Symbol](),
    scopeById: initTable[Uuid, Scope](),
    renames: initTable[Symbol, string](),
    targetKeywords: initHashSet[string](),
    errors: @[],
    warnings: @[]
  )
  newTransformContext(
    semanticInfo = emptySemanticInfo,
    errorCollector = newErrorCollector()
  )

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
#   xnkExternal_Event       → csharp_events.nim (C# events to callback patterns)
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
    raise newException(ValueError, "Unsupported node kind: " & $node.kind)
    # # fallback: serialize child nodes obtained via getChildren
    # var children = getChildren(node)
    # if children.len > 0:
    #   sbParts.add(":[")
    #   var childParts: seq[string] = @[]
    #   for c in children:
    #     childParts.add(serializeXLangNode(c))
    #   sbParts.add(childParts.join(","))
    #   sbParts.add("]")
  return sbParts.join("")

# Public structural equality function using the deterministic serializer.
proc nodesEqual*(a, b: XLangNode): bool =
  if a.isNil and b.isNil:
    return true
  if a == nil or b == nil:
    return false
  return serializeXLangNode(a) == serializeXLangNode(b)



# Forward declaration for mutual recursion (helpers call this)
proc convertToNimAST(node: XLangNode, ctx: TransformContext = nil): MyNimNode

# Helper procs for each XLang node kind — extract case logic here

proc conv_xnkFile(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newStmtList()

  # Process imports from moduleDecls (xnkImport nodes)
  # Note: std/sugar import is added by modifyBeforeConversion if lambdas are detected
  if ctx.sourceLang == "csharp":
    # Separate stdlib and user imports
    var stdlibImports: seq[string] = @[]
    var userImports: seq[string] = @[]

    for decl in node.moduleDecls:
      if decl.kind == xnkImport:
        let importPath = decl.importPath
        # C# stdlib namespaces typically start with System, Microsoft.*, etc.
        if importPath.startsWith("System") or importPath.startsWith("Microsoft"):
          # Convert namespace to module path: System.Collections.Generic -> system/collections/generic
          let modulePath = importPath.replace(".", "/").toLowerAscii()
          stdlibImports.add(modulePath)
        else:
          # User imports - these would be other project namespaces
          userImports.add(importPath)

    # Generate from-import for stdlib imports
    if stdlibImports.len > 0:
      let fromImport = newNimNode(nnkFromStmt)
      let homeDir = getEnv("HOME")
      let compatPath = homeDir & "/.transpiler/compat/csharp_compat"
      fromImport.add(newStrLitNode(compatPath))

      # Add each import as a direct child (not wrapped in nnkImportStmt)
      for modPath in stdlibImports:
        fromImport.add(newIdentNode(modPath))
      result.add(fromImport)

    # Generate regular imports for user imports (if any)
    for userImport in userImports:
      let importStmt = newNimNode(nnkImportStmt)
      # Convert namespace to module path: NAudio.Wave.Compression -> naudio/wave/compression
      let modulePath = userImport.replace(".", "/").toLowerAscii()
      importStmt.add(newIdentNode(modulePath))
      result.add(importStmt)

  elif ctx.sourceLang != "" and ctx.sourceLang != "unknown" and ctx.sourceLang != "nim":
    # Fallback for non-C# languages: add blanket compat import
    let compatImport = newNimNode(nnkImportStmt)
    let homeDir = getEnv("HOME")
    let compatPath = homeDir & "/.transpiler/compat/" & ctx.sourceLang & "_compat"
    compatImport.add(newStrLitNode(compatPath))
    result.add(compatImport)

  # Process all other declarations (skip xnkImport nodes as they're already processed above)
  for decl in node.moduleDecls:
    if decl.kind != xnkImport:
      result.add(convertToNimAST(decl, ctx))

proc conv_xnkModule(node: XLangNode, ctx: TransformContext): MyNimNode =
  # Nim doesn't have a direct equivalent to Java's module system
  # We'll create a comment node to preserve the information
  result = newCommentStmtNode("Module: " & node.moduleName)
  for stmt in node.moduleBody:
    result.add(convertToNimAST(stmt, ctx))

proc conv_xnkNamespace(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newStmtList()
  result.add(newCommentStmtNode("Namespace: " & node.namespaceName))
  for stmt in node.namespaceBody:
    result.add(convertToNimAST(stmt, ctx))

proc conv_xnkFuncDecl_standalone(node: XLangNode, ctx: TransformContext): MyNimNode =
  ## Convert standalone function (not a class method)
  ## For static class methods in multi-class files, adds class name prefix
  result = newNimNode(nnkProcDef)

  # 0: name - add asterisk for public procs
  # Convert C# PascalCase to Nim camelCase (e.g., ToString -> toString)
  var baseName = memberNameToNim(node.funcName)

  # If this is a static method in a file with multiple classes, add class name prefix
  if ctx.conversion.currentClass.isSome() and node.funcIsStatic and ctx.conversion.classCount > 1:
    # Get the class name and create prefix (e.g., JarUtil -> jarUtil_)
    let className = ctx.conversion.currentClass.get().typeNameDecl
    let prefix = className[0].toLowerAscii() & className[1..^1] & "_"
    baseName = prefix & baseName

  let procName = wrapProcName(baseName, node.funcVisibility == "public")
  result.add(newIdentNode(procName))
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
  # 6: body - set static context so identifiers don't get self. prefix
  let wasInStatic = ctx.conversion.inStaticFunction
  ctx.conversion.inStaticFunction = true
  result.add(convertToNimAST(node.body, ctx))
  ctx.conversion.inStaticFunction = wasInStatic
  if node.isAsync:
    setPragma(result, newPragma(newIdentNode("async")))

proc conv_xnkFuncDecl_instanceMethod(node: XLangNode, ctx: TransformContext): MyNimNode =
  ## Convert instance method (class member, non-static)
  ## Adds 'self' parameter as first parameter
  ## Uses 'method' (nnkMethodDef) if class has inheritance, otherwise 'proc' (nnkProcDef)

  # Use method for classes with inheritance (enables dynamic dispatch)
  let useMethod = ctx.classHasBaseTypes()
  result = if useMethod: newNimNode(nnkMethodDef) else: newNimNode(nnkProcDef)

  # 0: name - add asterisk for public procs/methods
  # Convert C# PascalCase to Nim camelCase (e.g., ToString -> toString)
  let baseName = memberNameToNim(node.funcName)
  let procName = wrapProcName(baseName, node.funcVisibility == "public")
  result.add(newIdentNode(procName))
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

  # Add 'self' parameter as first parameter
  let className = ctx.getClassName()
  if className.len > 0:
    let selfParam = newNimNode(nnkIdentDefs)
    selfParam.add(newIdentNode("self"))
    selfParam.add(newIdentNode(className))
    selfParam.add(newEmptyNode())  # no default value
    formalParams.add(selfParam)

  # Add original parameters
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

proc conv_xnkClassDecl_structDecl(node: XLangNode, ctx: TransformContext): MyNimNode =
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

  # Add const/static members as module-level constants before the methods
  for member in node.members:
    if member.kind == xnkConstDecl:
      result.add(convertToNimAST(member, ctx))

  # Add methods and constructors as separate procs
  for member in node.members:
    if member.kind != xnkFieldDecl and member.kind != xnkConstDecl:
      # Handle blocks (e.g., from property transforms that return multiple methods)
      if member.kind == xnkBlockStmt:
        for item in member.blockBody:
          result.add(convertToNimAST(item, ctx))
      else:
        result.add(convertToNimAST(member, ctx))

proc conv_xnkInterfaceDecl(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let conceptDef = newNimNode(nnkTypeDef)
  conceptDef.add(newIdentNode(node.typeNameDecl))
  conceptDef.add(newEmptyNode())
  let conceptTy = newNimNode(nnkObjectTy)
  for meth in node.members:
    conceptTy.add(convertToNimAST(meth, ctx))
  conceptDef.add(conceptTy)
  result.add(conceptDef)

proc conv_xnkEnumDecl(node: XLangNode, ctx: TransformContext): MyNimNode =
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

proc conv_xnkVarLetConst(node: XLangNode, ctx: TransformContext): MyNimNode =
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

proc conv_xnkIfStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkIfStmt)
  let branchNode = newNimNode(nnkElifBranch)
  branchNode.add(convertToNimAST(node.ifCondition, ctx))
  branchNode.add(convertToNimAST(node.ifBody, ctx))
  result.add(branchNode)
  if node.elseBody.isSome():
    let elseNode = newNimNode(nnkElse)
    elseNode.add(convertToNimAST(node.elseBody.get, ctx))
    result.add(elseNode)

proc conv_xnkWhileStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkWhileStmt)
  result.add(convertToNimAST(node.whileCondition, ctx))
  result.add(convertToNimAST(node.whileBody, ctx))

proc conv_xnkForStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  # Handle C-style or for-in style
  if node.extForInit.isSome() and node.extForCond.isSome() and node.extForIncrement.isSome():
    result = newStmtList()
    result.add(convertToNimAST(node.extForInit.get, ctx))
    let whileStmt = newNimNode(nnkWhileStmt)
    whileStmt.add(convertToNimAST(node.extForCond.get, ctx))
    let body = newStmtList()
    body.add(convertToNimAST(node.extForBody.get, ctx))
    body.add(convertToNimAST(node.extForIncrement.get, ctx))
    whileStmt.add(body)
    result.add(whileStmt)
  else:
    # fallback: map to a simple for stmt if a foreach-like structure exists
    result = newNimNode(nnkForStmt)
    if node.extForBody.isSome():
      result.add(convertToNimAST(node.extForBody.get, ctx))
    else:
      result.add(newEmptyNode())

proc conv_xnkBlockStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  # xlangtypes: blockBody is a seq[XLangNode]
  # C# blocks don't need to be Nim blocks - just return the statement list
  result = newStmtList()
  for stmt in node.blockBody:
    result.add(convertToNimAST(stmt, ctx))

# Patch member access and index kinds to xlangtypes style
proc conv_xnkMemberAccess(node: XLangNode, ctx: TransformContext): MyNimNode =
  # Note: Enum member access should already be normalized by the enum transformation pass
  # (transformEnumNormalization) which converts EnumType.Value → etValue
  # This includes both source-defined enums and external BCL enums detected via isEnumAccess

  result = newNimNode(nnkDotExpr)

  # Convert the left side (memberExpr)
  var leftSide = convertToNimAST(node.memberExpr, ctx)

  # Handle static member access on types
  if node.memberExpr.kind == xnkIdentifier:
    # Check if this identifier might be a type name being used for static member access
    # Type names in C# are PascalCase, Nim modules are snake_case
    let originalName = node.memberExpr.identName
    if originalName.len > 0 and originalName[0].isUpperAscii:
      # This looks like a type name - convert to snake_case for module access
      let snakeName = pascalToSnake(originalName)
      leftSide = newIdentNode(snakeName)
  elif node.memberExpr.kind == xnkNamedType:
    # Static member access on a type (e.g., string.Join, Path.Combine)
    # For primitive types, capitalize to match csharp_compat (string -> String)
    # For other types, use PascalCase as-is
    let typeName = node.memberExpr.typeName
    case typeName
    of "string", "int", "long", "double", "float", "bool", "byte", "short", "char":
      # Capitalize primitive types for static method calls
      let capitalizedName = typeName[0].toUpperAscii() & typeName[1..^1]
      leftSide = newIdentNode(capitalizedName)
    else:
      # Keep other types as-is (already handled by convertToNimAST)
      discard

  result.add(leftSide)

  # Check if this member access is for a property that was renamed
  # Properties are transformed to getPropertyName/setPropertyName by property_to_procs
  var memberName = node.memberName
  if ctx.semanticInfo != nil:
    let propertyRename = ctx.semanticInfo.getPropertyRename(node.memberName)
    if propertyRename.isSome():
      # This is a property access - use the getter name and make it a call
      memberName = propertyRename.get()
      # Convert from property access to method call: obj.property → obj.getProperty()
      result = newNimNode(nnkCall)
      let dotExpr = newNimNode(nnkDotExpr)
      dotExpr.add(leftSide)
      dotExpr.add(newIdentNode(memberName))
      result.add(dotExpr)
      return

  result.add(newIdentNode(memberName))

proc conv_xnkIndexExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  result.add(convertToNimAST(node.indexExpr, ctx))
  for arg in node.indexArgs:
    result.add(convertToNimAST(arg, ctx))

proc conv_xnkReturnStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkReturnStmt)
  if node.returnExpr.isSome:
    result.add(convertToNimAST(node.returnExpr.get, ctx))
  else:
    result.add(newEmptyNode())

## Unified iterator yield: Python yield, C# yield return, Nim yield
proc conv_xnkIteratorYield(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkYieldStmt)
  if node.iteratorYieldValue.isSome:
    result.add(convertToNimAST(node.iteratorYieldValue.get, ctx))
  else:
    result.add(newEmptyNode())

proc conv_xnkDiscardStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkDiscardStmt)
  if node.discardExpr.isSome:
    result.add(convertToNimAST(node.discardExpr.get, ctx))
  else:
    result.add(newEmptyNode())

proc conv_xnkCaseStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
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
  if node.caseElseBody.isSome:
    let elseBranch = newNimNode(nnkElse)
    elseBranch.add(convertToNimAST(node.caseElseBody.get, ctx))
    result.add(elseBranch)

proc conv_xnkTryStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
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
    # Convert the body of the finally clause, not the xnkFinallyStmt node itself
    # to avoid double-wrapping in nnkFinally nodes
    finallyBranch.add(convertToNimAST(node.finallyClause.get.finallyBody, ctx))
    result.add(finallyBranch)

proc conv_xnkRaiseStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkRaiseStmt)
  if node.raiseExpr.isSome:
    result.add(convertToNimAST(node.raiseExpr.get, ctx))
  else:
    result.add(newEmptyNode())

proc conv_xnkTypeDecl(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let typeDef = newNimNode(nnkTypeDef)
  typeDef.add(newIdentNode(node.typeDefName))
  typeDef.add(newEmptyNode())
  typeDef.add(convertToNimAST(node.typeDefBody, ctx))
  result.add(typeDef)

proc conv_xnkImportStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  ## Convert import statements, converting C# namespaces to Nim module paths
  ## Example: "System.Collections.Generic" -> "system/collections/generic"
  result = newNimNode(nnkImportStmt)
  for item in node.imports:
    let modulePath = namespaceToModulePath(item)
    result.add(newIdentNode(modulePath))

proc conv_xnkImport(node: XLangNode, ctx: TransformContext): MyNimNode =
  ## Convert single import, converting C# namespace to Nim module path
  result = newNimNode(nnkImportStmt)
  let modulePath = namespaceToModulePath(node.importPath)
  result.add(newIdentNode(modulePath))
  if node.importAlias.isSome:
    result.add(newIdentNode("as"))
    result.add(newIdentNode(node.importAlias.get))

proc conv_xnkExport(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkExportStmt)
  result.add(convertToNimAST(node.exportedDecl, ctx))

proc conv_xnkExportStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkExportStmt)
  for item in node.exports:
    result.add(newIdentNode(item))

proc conv_xnkFromImportStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkFromStmt)
  result.add(newIdentNode(node.module))
  let importList = newNimNode(nnkImportStmt)
  for item in node.fromImports:
    importList.add(newIdentNode(item))
  result.add(importList)

proc conv_xnkGenericParameter(node: XLangNode, ctx: TransformContext): MyNimNode =
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

proc conv_xnkIdentifier(node: XLangNode, ctx: TransformContext): MyNimNode =
  # Get the effective name (handles keyword renames from semantic analysis)
  var identName = node.identName
  if ctx.semanticInfo != nil:
    let effectiveName = ctx.semanticInfo.getEffectiveName(node)
    if effectiveName.isSome:
      identName = effectiveName.get

  # Check if this identifier is a class field being accessed in an instance method
  # In constructors and static functions, don't add self. prefix
  if ctx.isInClassScope() and ctx.isClassField(node.identName) and
     not ctx.conversion.inConstructor and not ctx.conversion.inStaticFunction:
    # Convert to self.fieldName
    result = newNimNode(nnkDotExpr)
    result.add(newIdentNode("self"))
    result.add(newIdentNode(identName))
  else:
    # Regular identifier (or in constructor where we access params directly)
    result = newIdentNode(identName)

proc conv_xnkComment(node: XLangNode, ctx: TransformContext): MyNimNode =
  if node.isDocComment:
    # Use multi-line doc comment syntax for doc comments
    result = newCommentStmtNode("##[ " & node.commentText & " ]##")
  else:
    # Regular comments - just pass through without adding prefix (astprinter will add "# ")
    result = newCommentStmtNode(node.commentText)

proc conv_xnkNumberLit(node: XLangNode, ctx: TransformContext): MyNimNode =
  # Preserve the literal format from source when possible
  var literal = node.numberValue

  # Strip C#/Java type suffixes (L, l, D, d, F, f, M, m, U, u, UL, ul, etc.)
  # BUT: Don't strip F/f from hex literals (0xF is a hex digit, not a suffix)
  var hasFloatSuffix = false
  let isHexLiteral = literal.len > 2 and literal[0..1].toLowerAscii() == "0x"

  if literal.len > 0:
    let lastChar = literal[^1]
    # For hex literals, only strip L/l, U/u suffixes (F is a valid hex digit)
    # For decimal, strip all suffixes including F/f, D/d, M/m
    if isHexLiteral:
      if lastChar in {'L', 'l', 'U', 'u'}:
        literal = literal[0..^2]  # Remove suffix
        # Handle UL/ul suffix
        if literal.len > 0 and literal[^1] in {'L', 'l', 'U', 'u'}:
          literal = literal[0..^2]
    else:
      if lastChar in {'L', 'l', 'U', 'u', 'D', 'd', 'F', 'f', 'M', 'm'}:
        if lastChar in {'D', 'd', 'F', 'f', 'M', 'm'}:
          hasFloatSuffix = true
        literal = literal[0..^2]  # Remove suffix
        # Handle UL/ul suffix
        if literal.len > 0 and literal[^1] in {'L', 'l', 'U', 'u'}:
          literal = literal[0..^2]

  # Check if it's a hex literal first (before checking for 'e')
  if literal.len > 2 and literal[0..1].toLowerAscii() == "0x":
    # Hex literal - preserve the exact format
    try:
      let value = parseHexInt(literal)
      result = newIntLitNode(value)
      result.literalText = literal.toLowerAscii()  # Nim uses lowercase 0x
    except ValueError:
      # Value too large - use literal as-is
      result = newIntLitNode(0)  # Placeholder
      result.literalText = literal.toLowerAscii()
  # Check if it's a floating-point literal
  elif '.' in literal or 'e' in literal or 'E' in literal or hasFloatSuffix:
    result = newFloatLitNode(parseFloat(literal))
  else:
    # Regular decimal integer
    try:
      result = newIntLitNode(parseInt(literal))
    except ValueError:
      # Value too large - use literal as-is (for BigInt or similar)
      result = newIntLitNode(0)  # Placeholder
      result.literalText = literal

proc conv_xnkIntLit(node: XLangNode, ctx: TransformContext): MyNimNode =
  # Parse integer literal value and create integer literal node
  result = newIntLitNode(parseInt(node.literalValue))

proc conv_xnkFloatLit(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newFloatLitNode(parseFloat(node.literalValue))

proc conv_xnkStringLit(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newStrLitNode(node.literalValue)

proc conv_xnkCharLit(node: XLangNode, ctx: TransformContext): MyNimNode =
  if node.literalValue.len > 0:
    result = newCharNode(node.literalValue[0])
  else:
    result = newCharNode('\0')

proc conv_xnkBoolLit(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newIdentNode(if node.boolValue: "true" else: "false")

proc conv_xnkNilLit(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNilLit()

proc conv_xnkTemplateMacro(node: XLangNode, ctx: TransformContext): MyNimNode =
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

proc conv_xnkPragma(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkPragma)
  for pragma in node.pragmas:
    result.add(convertToNimAST(pragma, ctx))

proc conv_xnkStaticStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkStaticStmt)
  result.add(convertToNimAST(node.staticBody, ctx))

proc conv_xnkDeferStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkDefer)
  result.add(convertToNimAST(node.staticBody, ctx))

proc conv_xnkAsmStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkAsmStmt)
  result.add(newStrLitNode(node.asmCode))

proc conv_xnkDistinctTypeDef(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let typeDef = newNimNode(nnkTypeDef)
  typeDef.add(newIdentNode(node.distinctName))
  typeDef.add(newEmptyNode())
  let distinctTy = newNimNode(nnkDistinctTy)
  distinctTy.add(convertToNimAST(node.baseType, ctx))
  typeDef.add(distinctTy)
  result.add(typeDef)

proc conv_xnkConceptDef(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let typeDef = newNimNode(nnkTypeDef)
  typeDef.add(newIdentNode(node.conceptName))
  typeDef.add(newEmptyNode())
  let conceptTy = newNimNode(nnkObjectTy)
  conceptTy.add(newEmptyNode())
  conceptTy.add(convertToNimAST(node.conceptBody, ctx))
  typeDef.add(conceptTy)
  result.add(typeDef)

proc conv_xnkMixinStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkMixinStmt)
  for name in node.mixinNames:
    result.add(newIdentNode(name))

proc conv_xnkBindStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkBindStmt)
  for name in node.bindNames:
    result.add(newIdentNode(name))

proc conv_xnkTupleConstr(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkTupleConstr)
  for elem in node.tupleElements:
    result.add(convertToNimAST(elem, ctx))

proc conv_xnkTupleUnpacking(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkVarTuple)
  for target in node.unpackTargets:
    result.add(convertToNimAST(target, ctx))
  result.add(newEmptyNode())
  result.add(convertToNimAST(node.unpackExpr, ctx))

# ## C# using statement → should be lowered to xnkResourceStmt first
# ## (Keeping stub implementation for now, but should use transform pass)
# proc conv_xnkUsingStmt_DEPRECATED(node: XLangNode, ctx: TransformContext): MyNimNode =
#   result = newNimNode(nnkUsingStmt)
#   result.add(convertToNimAST(node.usingExpr, ctx))
#   result.add(convertToNimAST(node.usingBody, ctx))


proc conv_xnkCallExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkCall)

  # Check if this is a constructor call (callee is a type name)
  # Constructor calls should be converted to newTypeName()
  if node.callee.kind == xnkNamedType:
    # This is a constructor call: TypeName() -> newTypeName()
    let typeName = node.callee.typeName
    result.add(newIdentNode("new" & typeName))
  else:
    result.add(convertToNimAST(node.callee, ctx))

  for arg in node.args:
    result.add(convertToNimAST(arg, ctx))

proc conv_xnkThisCall(node: XLangNode, ctx: TransformContext): MyNimNode =
  ## C# constructor initializer: this(...)
  ## Convert to a call to the current type's constructor
  ## In Nim, this would typically be handled differently, but we approximate with a proc call
  result = newNimNode(nnkCall)

  # Get the current class name for the constructor call
  let typeName = if ctx.conversion.currentClass.isSome():
    ctx.conversion.currentClass.get().typeNameDecl
  else:
    "UnknownType"

  result.add(newIdentNode("new" & typeName))
  for arg in node.arguments:
    result.add(convertToNimAST(arg, ctx))

proc conv_xnkBaseCall(node: XLangNode, ctx: TransformContext): MyNimNode =
  ## C# constructor initializer: base(...)
  ## Convert to a call to the parent type's constructor
  ## In Nim, there's no direct equivalent, so we approximate with a proc call
  result = newNimNode(nnkCall)

  # Try to determine parent type name
  let parentTypeName = if ctx.conversion.currentClass.isSome() and ctx.conversion.currentClass.get().baseTypes.len > 0:
    # Get first base type name (simplified - assumes it's xnkNamedType)
    let baseType = ctx.conversion.currentClass.get().baseTypes[0]
    if baseType.kind == xnkNamedType:
      baseType.typeName
    else:
      "ParentType"
  else:
    "ParentType"

  result.add(newIdentNode("new" & parentTypeName))
  for arg in node.arguments:
    result.add(convertToNimAST(arg, ctx))

proc conv_xnkDotExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkDotExpr)
  result.add(convertToNimAST(node.dotBase, ctx))
  result.add(convertToNimAST(node.member, ctx))

proc conv_xnkBracketExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  result.add(convertToNimAST(node.base, ctx))
  result.add(convertToNimAST(node.index, ctx))


proc binaryOpToNim(op: BinaryOp): string =
  ## Map semantic binary operator to Nim syntax
  case op
  # Arithmetic
  of opAdd: "+"
  of opSub: "-"
  of opMul: "*"
  of opDiv: "/"
  of opMod: "mod"
  of opPow: "^"
  of opIntDiv: "div"

  # Bitwise
  of opBitAnd: "and"
  of opBitOr: "or"
  of opBitXor: "xor"
  of opShiftLeft: "shl"
  of opShiftRight: "shr"
  of opShiftRightUnsigned: "shr"  # Nim doesn't distinguish signed/unsigned shift

  # Comparison
  of opEqual: "=="
  of opNotEqual: "!="
  of opLess: "<"
  of opLessEqual: "<="
  of opGreater: ">"
  of opGreaterEqual: ">="
  of opIdentical: "is"
  of opNotIdentical: "isnot"

  # Logical
  of opLogicalAnd: "and"
  of opLogicalOr: "or"

  # Assignment (compound) - these should be lowered by transforms
  of opAddAssign: "+="
  of opSubAssign: "-="
  of opMulAssign: "*="
  of opDivAssign: "/="
  of opModAssign: "mod="
  of opBitAndAssign: "and="
  of opBitOrAssign: "or="
  of opBitXorAssign: "xor="
  of opShiftLeftAssign: "shl="
  of opShiftRightAssign: "shr="
  of opShiftRightUnsignedAssign: "shr="

  # Special
  of opNullCoalesce: "?"  # Should be lowered by null_coalesce pass
  of opElvis: "?"         # Should be lowered
  of opRange: ".."
  of opIn: "in"
  of opNotIn: "notin"
  of opIs: "is"
  of opAs: "as"
  of opConcat: "&"

proc unaryOpToNim(op: UnaryOp): string =
  ## Map semantic unary operator to Nim syntax
  case op
  of opNegate: "-"
  of opUnaryPlus: "+"
  of opNot: "not"
  of opBitNot: "not"  # Nim uses 'not' for both logical and bitwise
  of opPreIncrement: "inc"   # Will need special handling
  of opPostIncrement: "inc"  # Will need special handling
  of opPreDecrement: "dec"   # Will need special handling
  of opPostDecrement: "dec"  # Will need special handling
  of opAddressOf: "addr"
  of opDereference: "[]"     # Will need special handling
  of opAwait: "await"
  of opSpread: "..."         # May need lowering
  of opIndexFromEnd: "^"     # Nim uses same syntax for backIndex

proc conv_xnkBinaryExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkInfix)
  # nnkInfix structure: [operator, left, right]
  result.add(newIdentNode(binaryOpToNim(node.binaryOp)))
  result.add(convertToNimAST(node.binaryLeft, ctx))
  result.add(convertToNimAST(node.binaryRight, ctx))

proc conv_xnkUnaryExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  # Handle increment/decrement specially as they need statement conversion
  case node.unaryOp
  of opPreIncrement, opPostIncrement, opPreDecrement, opPostDecrement:
    # These should ideally be lowered by a transformation pass
    # For now, convert to Nim idiom: inc(x) or dec(x)
    result = newNimNode(nnkCall)
    result.add(newIdentNode(unaryOpToNim(node.unaryOp)))
    result.add(convertToNimAST(node.unaryOperand, ctx))
  else:
    result = newNimNode(nnkPrefix)
    result.add(newIdentNode(unaryOpToNim(node.unaryOp)))
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
# - xnkExternal_Event → csharp_events.nim
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
proc conv_xnkPropertyDecl(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkPropertyDecl")
proc conv_xnkExternal_Event(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkExternal_Event")
proc conv_xnkDoWhileStmt(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkDoWhileStmt")
proc conv_xnkTernaryExpr(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkTernaryExpr")
## Python 'with' / C# 'using' → should be lowered to xnkResourceStmt
proc conv_xnkWithStmt(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkWithStmt")
proc conv_xnkUsingStmt(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkUsingStmt")

## Unified resource management → should be lowered to defer pattern
proc conv_xnkResourceStmt(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkResourceStmt")
proc conv_xnkResourceItem(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkResourceItem")
proc conv_xnkWithItem(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkWithItem")
proc conv_xnkStringInterpolation(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkStringInterpolation")
proc conv_xnkNullCoalesceExpr(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkNullCoalesceExpr")
proc conv_xnkSafeNavigationExpr(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkSafeNavigationExpr")
proc conv_xnkComprehensionExpr(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkComprehensionExpr")
proc conv_xnkDestructureObj(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkDestructureObj")
proc conv_xnkDestructureArray(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkDestructureArray")
proc conv_xnkIteratorDelegate(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkIteratorDelegate")
# Legacy yield nodes (deprecated - unified into xnkIteratorYield):
proc conv_xnkYieldStmt(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkYieldStmt")
proc conv_xnkYieldExpr(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkYieldExpr")
proc conv_xnkYieldFromStmt(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkYieldFromStmt")
# xnkConditionalAccessExpr removed - was duplicate of xnkSafeNavigationExpr

# ==== SIMPLE DIRECT MAPPINGS ====

## C#: `this.x`
## Nim: `self.x`
proc conv_xnkThisExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  # In constructors, 'this' should be 'result'
  # In instance methods, 'this' should be 'self'
  if ctx.conversion.inConstructor:
    newIdentNode("result")
  else:
    newIdentNode("self")

## C#: `break;`
## Nim: `break`
proc conv_xnkBreakStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  newNimNode(nnkBreakStmt)

## C#: `continue;`
## Nim: `continue`
proc conv_xnkContinueStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  newNimNode(nnkContinueStmt)

## C#: `;` or empty statement
## Nim: (empty node)
proc conv_xnkEmptyStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  newNimNode(nnkEmpty)

## Python: `pass`
## Nim: `discard`
proc conv_xnkPassStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  newNimNode(nnkDiscardStmt)

## Python: `None` or C#: `null`
## Nim: `nil`
proc conv_xnkNoneLit(node: XLangNode, ctx: TransformContext): MyNimNode =
  newIdentNode("nil")

## C#: `[Attribute]` (discarded - Nim uses pragmas differently)
## Nim: (discarded)
proc conv_xnkAttribute(node: XLangNode, ctx: TransformContext): MyNimNode =
  newNimNode(nnkDiscardStmt)

## C#: `abstract void Foo();` (no body in Nim)
## Nim: (discarded - interface handles this)
proc conv_xnkAbstractDecl(node: XLangNode, ctx: TransformContext): MyNimNode =
  newNimNode(nnkDiscardStmt)

proc conv_xnkAbstractType(node: XLangNode, ctx: TransformContext): MyNimNode =
  newNimNode(nnkDiscardStmt)

## Metadata/annotations
## Nim: (discarded)
proc conv_xnkMetadata(node: XLangNode, ctx: TransformContext): MyNimNode =
  newNimNode(nnkDiscardStmt)

## Unknown constructs
## Nim: `discard`
proc conv_xnkUnknown(node: XLangNode, ctx: TransformContext): MyNimNode =
  newNimNode(nnkDiscardStmt)

# ==== DECLARATIONS NEEDING IMPLEMENTATION ====

## Python: `def gen(): yield x` or C#: `IEnumerable<T> Gen()`
## Nim: `iterator gen(): T = yield x`
proc conv_xnkIteratorDecl(node: XLangNode, ctx: TransformContext): MyNimNode =
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
proc conv_xnkFieldDecl(node: XLangNode, ctx: TransformContext): MyNimNode =
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
proc conv_xnkConstructorDecl(node: XLangNode, ctx: TransformContext): MyNimNode =
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

  # Add result = TypeName() initialization at the start
  if className.len > 0:
    let initStmt = newNimNode(nnkAsgn)
    initStmt.add(newIdentNode("result"))
    let objConstr = newNimNode(nnkObjConstr)
    objConstr.add(newIdentNode(className))
    initStmt.add(objConstr)
    body.add(initStmt)

  # Set constructor flag so field accesses use result. instead of self.
  ctx.conversion.inConstructor = true

  # Helper to convert field assignment to result.field = value
  proc convertConstructorFieldAssignment(stmt: XLangNode, ctx: TransformContext): MyNimNode =
    # Check if this is a field assignment
    if stmt.kind == xnkAsgn:
      var fieldName = ""

      # Check for: this.fieldName = value (C#/Java)
      if stmt.asgnLeft.kind == xnkMemberAccessExpr and
         stmt.asgnLeft.memberExpr.kind == xnkThisExpr:
        fieldName = stmt.asgnLeft.memberName
      # Check for: fieldName = value (simpler case)
      elif stmt.asgnLeft.kind == xnkIdentifier:
        let name = stmt.asgnLeft.identName
        if ctx.isClassField(name):
          fieldName = name

      # If we found a field assignment, convert to result.field = value
      if fieldName.len > 0:
        result = newNimNode(nnkAsgn)
        let dotExpr = newNimNode(nnkDotExpr)
        dotExpr.add(newIdentNode("result"))
        dotExpr.add(newIdentNode(fieldName))
        result.add(dotExpr)
        result.add(convertToNimAST(stmt.asgnRight, ctx))
        return

    # Not a field assignment, convert normally
    return convertToNimAST(stmt, ctx)

  # Add initializers first (field assignments)
  for init in node.constructorInitializers:
    body.add(convertConstructorFieldAssignment(init, ctx))

  # Add constructor body
  if not node.constructorBody.isNil:
    if node.constructorBody.kind == xnkBlockStmt:
      for stmt in node.constructorBody.blockBody:
        body.add(convertConstructorFieldAssignment(stmt, ctx))
    else:
      body.add(convertConstructorFieldAssignment(node.constructorBody, ctx))

  # Clear constructor flag
  ctx.conversion.inConstructor = false

  result.add(body)

## C#: `~MyClass()` → Destructor (Nim has no destructors)
## Nim: (discarded or use destructor hooks)
proc conv_xnkDestructorDecl(node: XLangNode, ctx: TransformContext): MyNimNode =
  ## Convert C# destructor/finalizer to Nim =destroy hook
  ## C#: ~ClassName() { body }
  ## Nim: proc `=destroy`(self: var ClassName) = body
  result = newNimNode(nnkProcDef)

  # 0: name - use `=destroy` for Nim destructor hook
  result.add(newIdentNode("=destroy"))

  # 1: empty (unused)
  result.add(newEmptyNode())

  # 2: empty (generic params)
  result.add(newEmptyNode())

  # 3: params - (returnType, param1, param2, ...)
  let params = newNimNode(nnkFormalParams)
  params.add(newEmptyNode()) # no return type (void)

  # Add self parameter as var (destructors modify the object)
  if ctx.conversion.currentClass.isSome():
    let selfParam = newNimNode(nnkIdentDefs)
    selfParam.add(newIdentNode("self"))
    let varType = newNimNode(nnkVarTy)
    varType.add(newIdentNode(ctx.conversion.currentClass.get().typeNameDecl))
    selfParam.add(varType)
    selfParam.add(newEmptyNode())
    params.add(selfParam)

  result.add(params)

  # 4: empty (pragmas)
  result.add(newEmptyNode())

  # 5: empty (reserved)
  result.add(newEmptyNode())

  # 6: body
  let body = if node.destructorBody.isSome():
    convertToNimAST(node.destructorBody.get(), ctx)
  else:
    newStmtList()
  result.add(body)

## C#: `delegate void D(int x);`
## Nim: `type D = proc(x: int)`
proc conv_xnkDelegateDecl(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkTypeSection)
  let typeDef = newNimNode(nnkTypeDef)
  typeDef.add(newIdentNode(node.extDelegateName))
  typeDef.add(newEmptyNode())

  # Create proc type
  let procTy = newNimNode(nnkProcTy)
  let formalParams = newNimNode(nnkFormalParams)

  if node.extDelegateReturnType.isSome():
    formalParams.add(convertToNimAST(node.extDelegateReturnType.get, ctx))
  else:
    formalParams.add(newEmptyNode())  # void

  for param in node.extDelegateParams:
    formalParams.add(convertToNimAST(param, ctx))

  procTy.add(formalParams)
  procTy.add(newEmptyNode())  # pragmas
  typeDef.add(procTy)
  result.add(typeDef)

## C#: `int this[int i] { get; }`
## Nim: proc `[]` and `[]=` operators (lowered by indexer_to_procs.nim)
proc conv_xnkIndexerDecl(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkIndexerDecl")

## Operator overload declaration
## C#:      static Vector operator+(Vector a, Vector b) { ... }
## C++:     Vector operator+(const Vector& a, const Vector& b) { ... }
## Python:  def __add__(self, other): ...
## Nim:     proc `+`(a, b: Vector): Vector = ...
proc conv_xnkOperatorDecl(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkProcDef)

  # Operator name with backticks (e.g., `+`, `-`, `*`)
  result.add(newIdentNode("`" & node.extOperatorSymbol & "`"))

  # Empty term-rewriting template
  result.add(newEmptyNode())

  # Empty generic params
  result.add(newEmptyNode())

  # Formal params
  let formalParams = newNimNode(nnkFormalParams)

  # Return type
  formalParams.add(convertToNimAST(node.extOperatorReturnType, ctx))

  # Parameters
  for param in node.extOperatorParams:
    formalParams.add(convertToNimAST(param, ctx))

  result.add(formalParams)

  # Empty pragmas
  result.add(newEmptyNode())

  # Empty reserved
  result.add(newEmptyNode())

  # Body
  let body = newNimNode(nnkStmtList)
  # extOperatorBody is an Option[XLangNode]; handle absence and unwrap safely
  if node.extOperatorBody.isSome() and node.extOperatorBody.get.kind == xnkBlockStmt:
    for stmt in node.extOperatorBody.get.blockBody:
      body.add(convertToNimAST(stmt, ctx))
  elif node.extOperatorBody.isSome():
    body.add(convertToNimAST(node.extOperatorBody.get, ctx))
  else:
    discard

  result.add(body)

proc conv_xnkConversionOperatorDecl(node: XLangNode, ctx: TransformContext): MyNimNode =
  ## Convert C# conversion operators to Nim procs
  ## C#: public static implicit operator int(Integer value) => value.Value;
  ## Nim: proc toInt*(value: Integer): int = value.value
  result = newNimNode(nnkProcDef)

  # Generate function name from target type
  let toTypeName = if node.extConversionToType.kind == xnkNamedType:
    node.extConversionToType.typeName
  else:
    "Converted"
  let funcName = "to" & toTypeName[0].toUpperAscii & toTypeName[1..^1] & "*"  # public

  # 0: name
  result.add(newIdentNode(funcName))
  # 1: empty
  result.add(newEmptyNode())
  # 2: empty
  result.add(newEmptyNode())

  # 3: formal params (return type + parameters)
  let formalParams = newNimNode(nnkFormalParams)
  formalParams.add(convertToNimAST(node.extConversionToType, ctx))  # return type

  # Add the conversion parameter
  let param = newNimNode(nnkIdentDefs)
  param.add(newIdentNode(node.extConversionParamName))
  param.add(convertToNimAST(node.extConversionFromType, ctx))
  param.add(newEmptyNode())  # no default
  formalParams.add(param)

  result.add(formalParams)
  # 4: pragmas - empty for now (could add {.inline.} or {.converter.})
  result.add(newEmptyNode())
  # 5: reserved
  result.add(newEmptyNode())
  # 6: body - Get the expression from the XLang body and return it
  # The body is a BlockStmt with a ReturnStmt that has a returnExpr (or returnValue)
  # We'll extract the expression directly from the XLang AST before conversion

  # IMPORTANT: Conversion operators are ALWAYS static in C#
  # Create a non-class context to prevent identifier resolution from adding implicit self.
  let savedClass = ctx.conversion.currentClass
  ctx.clearCurrentClass()

  let newBody = newStmtList()

  if node.extConversionBody.kind == xnkBlockStmt and node.extConversionBody.blockBody.len > 0:
    let firstStmt = node.extConversionBody.blockBody[0]
    if firstStmt.kind == xnkReturnStmt:
      # Extract the return expression from XLang and convert it
      if firstStmt.returnExpr.isSome:
        let exprToReturn = firstStmt.returnExpr.get
        # Create: let convResult = <expression>
        let letSection = newNimNode(nnkLetSection)
        let identDefs = newNimNode(nnkIdentDefs)
        identDefs.add(newIdentNode("convResult"))
        identDefs.add(newEmptyNode())
        identDefs.add(convertToNimAST(exprToReturn, ctx))
        letSection.add(identDefs)
        newBody.add(letSection)
        # Create: return convResult
        let returnStmt = newNimNode(nnkReturnStmt)
        returnStmt.add(newIdentNode("convResult"))
        newBody.add(returnStmt)
      else:
        # No expression, just return
        let returnStmt = newNimNode(nnkReturnStmt)
        returnStmt.add(newEmptyNode())
        newBody.add(returnStmt)
    else:
      # Not a return statement - convert normally
      newBody.add(convertToNimAST(firstStmt, ctx))
  else:
    # Fallback - convert the whole body
    for stmt in node.extConversionBody.blockBody:
      newBody.add(convertToNimAST(stmt, ctx))

  # Restore class context
  ctx.conversion.currentClass = savedClass

  result.add(newBody)
proc conv_xnkEnumMember(node: XLangNode, ctx: TransformContext): MyNimNode = notYetImpl("xnkEnumMember")

## C: `extern void foo(int x);`
## Nim: `proc foo(x: cint) {.importc.}`
proc conv_xnkCFuncDecl(node: XLangNode, ctx: TransformContext): MyNimNode = notYetImpl("xnkCFuncDecl")

proc conv_xnkExternalVar(node: XLangNode, ctx: TransformContext): MyNimNode = notYetImpl("xnkExternalVar")
proc conv_xnkLibDecl(node: XLangNode, ctx: TransformContext): MyNimNode = notYetImpl("xnkLibDecl")

## C#: `foreach (var x in arr) { }`
## Nim: `for x in arr:`
proc conv_xnkForeachStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkForStmt)
  # For foreach, we only need the variable name, not the full declaration with type
  # The loop variable type is inferred from the iterable
  let varName = if node.foreachVar.kind == xnkVarDecl:
    node.foreachVar.declName  # Just the variable name
  else:
    "item"  # Fallback
  result.add(newIdentNode(varName))
  result.add(convertToNimAST(node.foreachIter, ctx))
  result.add(convertToNimAST(node.foreachBody, ctx))

## C#: `catch (Exception e) { }`
## Nim: `except e:`
proc conv_xnkCatchStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
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
proc conv_xnkFinallyStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkFinally)
  result.add(convertToNimAST(node.finallyBody, ctx))

## (conv_xnkYieldExpr moved to unified iterator yield section - see line 333)

## C#: `throw e;` → Should be migrated to xnkRaiseStmt by parser
## Nim: `raise e`
proc conv_xnkThrowStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  # Legacy support: convert throw to raise on the fly
  result = newNimNode(nnkRaiseStmt)
  result.add(convertToNimAST(node.throwExpr, ctx))

## Python/Nim: `raise` or `raise e`  (already defined earlier at line ~368)
## C#: `Debug.Assert(x);`
## Nim: `assert x`
proc conv_xnkAssertStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkCall)
  result.add(newIdentNode("assert"))
  result.add(convertToNimAST(node.assertCond, ctx))
## C#: `myLabel: statement;` (Nim has no goto/labels)
## Nim: (discarded)
proc conv_xnkLabeledStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  convertToNimAST(node.labeledStmt, ctx)  # Just convert the statement, discard label

## C#: `goto label;` (Nim has no goto)
## Nim: (discarded - should restructure code)
proc conv_xnkGotoStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  addWarning(xnkGotoStmt, "goto statement not supported in Nim - code needs restructuring")
  result = newCommentStmtNode("UNSUPPORTED: goto " & node.gotoLabel & " - requires manual restructuring")

## C#: `fixed (int* p = arr) { }` (unsafe pointers)
## Nim: (discarded - use ptr manually)
proc conv_xnkFixedStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  addWarning(xnkExternal_Fixed, "fixed statement not supported - use ptr manually in Nim")
  result = newCommentStmtNode("UNSUPPORTED: fixed statement - use unsafe pointer operations manually")

## C#: `lock (obj) { }` → should be lowered by lock_to_withlock.nim transform
## Nim: `withLock obj:` or acquire/defer/release pattern
proc conv_xnkLockStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  assertLowered("xnkLockStmt")

## C#: `unsafe { }` (Nim doesn't need unsafe blocks)
## Nim: (just convert body)
proc conv_xnkUnsafeStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  convertToNimAST(node.extUnsafeBody, ctx)

## C#: `checked { }` / `unchecked { }` (overflow checking)
## Nim: (discarded - Nim has compile-time overflow checks)
proc conv_xnkCheckedStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  convertToNimAST(node.extCheckedBody, ctx)

## C#: local function inside method
## Nim: nested proc
## C#: Local function inside method
## Nim: Nested proc
proc conv_xnkLocalFunctionStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkProcDef)
  result.add(newIdentNode(node.extLocalFuncName))
  result.add(newEmptyNode())  # term-rewriting
  result.add(newEmptyNode())  # generic params

  # Formal params
  let formalParams = newNimNode(nnkFormalParams)
  if node.extLocalFuncReturnType.isSome():
    formalParams.add(convertToNimAST(node.extLocalFuncReturnType.get, ctx))
  else:
    formalParams.add(newEmptyNode())

  for param in node.extLocalFuncParams:
    formalParams.add(convertToNimAST(param, ctx))

  result.add(formalParams)
  result.add(newEmptyNode())  # pragmas
  result.add(newEmptyNode())  # reserved
  if node.extLocalFuncBody.isSome():
    result.add(convertToNimAST(node.extLocalFuncBody.get, ctx))
  else:
    result.add(newEmptyNode())

## Ruby: `unless x` → `if not x` (lowered by normalize_simple.nim)
proc conv_xnkUnlessStmt(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkUnlessStmt")

## `repeat...until x` → `while not x` (lowered by normalize_simple.nim)
proc conv_xnkUntilStmt(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkUntilStmt")

## C++: `static_assert(x)`
## Nim: `static: assert x`
proc conv_xnkStaticAssert(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkStaticStmt)
  let assertCall = newNimNode(nnkCall)
  assertCall.add(newIdentNode("assert"))
  assertCall.add(convertToNimAST(node.staticAssertCondition, ctx))
  result.add(assertCall)

## C#: `switch (x) { case 1: ...; default: ...; }`
## Nim: `case x: of 1: ...; else: ...`
proc conv_xnkSwitchStmt(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkCaseStmt)
  result.add(convertToNimAST(node.switchExpr, ctx))
  for caseNode in node.switchCases:
    result.add(convertToNimAST(caseNode, ctx))

## C#: `case 1: case 2: statements;`
## Nim: `of 1, 2: statements`
proc conv_xnkCaseClause(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkOfBranch)
  for val in node.caseValues:
    result.add(convertToNimAST(val, ctx))
  result.add(convertToNimAST(node.caseBody, ctx))

## C#: `default: statements;`
## Nim: `else: statements`
proc conv_xnkDefaultClause(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkElse)
  result.add(convertToNimAST(node.defaultBody, ctx))
# ==== EXPRESSION CONVERSIONS ====

## C#/Python: `[1, 2, 3]`
## Nim: `[1, 2, 3]`
## Array literal `[1, 2, 3]` (fixed-size)
## Nim: `[1, 2, 3]`
proc conv_xnkArrayLiteral(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkBracket)
  for elem in node.elements:
    result.add(convertToNimAST(elem, ctx))

## Sequence literal `[1, 2, 3]` (dynamic)
## Nim: `@[1, 2, 3]`
proc conv_xnkSequenceLiteral(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkPrefix)
  result.add(newIdentNode("@"))
  let bracket = newNimNode(nnkBracket)
  for elem in node.elements:
    bracket.add(convertToNimAST(elem, ctx))
  result.add(bracket)

## Set literal `{1, 2, 3}`
## Nim: `{1, 2, 3}`
proc conv_xnkSetLiteral(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkCurly)
  for elem in node.elements:
    result.add(convertToNimAST(elem, ctx))

## Map/Dict literal `{"a": 1, "b": 2}`
## Nim: `{"a": 1, "b": 2}.toTable`
proc conv_xnkMapLiteral(node: XLangNode, ctx: TransformContext): MyNimNode =
  # Map literals require the tables module
  ctx.addImport("tables")
  result = newNimNode(nnkTableConstr)
  for entry in node.entries:
    result.add(convertToNimAST(entry, ctx))

# Legacy (deprecated - use *Literal):
proc conv_xnkArrayLit(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkArrayLit")
proc conv_xnkListExpr(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkListExpr")
proc conv_xnkSetExpr(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkSetExpr")
proc conv_xnkDictExpr(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkDictExpr")

## Tuple literal `(1, 2, 3)`
## Nim: `(1, 2, 3)`
proc conv_xnkTupleExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkTupleConstr)
  for elem in node.elements:
    result.add(convertToNimAST(elem, ctx))

## Dictionary entry `"key": value`
## Nim: `"key": value`
proc conv_xnkDictEntry(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkExprColonExpr)
  result.add(convertToNimAST(node.key, ctx))
  result.add(convertToNimAST(node.value, ctx))

## Python: `arr[1:3]`
## Nim: `arr[1..3]` or `arr[1..^1]`
proc conv_xnkSliceExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
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
proc conv_xnkLambdaExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
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
proc conv_xnkLambdaProc(node: XLangNode, ctx: TransformContext): MyNimNode =
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
proc conv_xnkArrowFunc(node: XLangNode, ctx: TransformContext): MyNimNode =
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
proc conv_xnkTypeAssertion(node: XLangNode, ctx: TransformContext): MyNimNode =
  # Check if this is a null check: `x is null`
  if node.assertType.kind == xnkNamedType and node.assertType.typeName == "null":
    # Convert to: x == nil
    result = newNimNode(nnkInfix)
    result.add(newIdentNode("=="))
    result.add(convertToNimAST(node.assertExpr, ctx))
    result.add(newIdentNode("nil"))
  else:
    # For other type assertions, just return the expression (may need proper implementation later)
    result = convertToNimAST(node.assertExpr, ctx)

## C#: `(T)x`
## Nim: `cast[T](x)` or `T(x)`
proc conv_xnkCastExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkCast)
  result.add(convertToNimAST(node.castType, ctx))
  result.add(convertToNimAST(node.castExpr, ctx))
## C#: `base.Method()`
## Nim: `procCall Method(self)` (needs proper super implementation)
## C#: `base.Method()` or Java: `super.method()`
## Nim: `procCall baseType.method(self)`
proc conv_xnkBaseExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  # In Nim, we use procCall to call base implementation
  # For now, just return identifier "procCall" - full implementation needs member access context
  newIdentNode("procCall")

## C#: `ref x` or `&x`
## Nim: `addr x`
proc conv_xnkRefExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkAddr)
  result.add(convertToNimAST(node.refExpr, ctx))

## Instance variable, class variable, global variable
## These are just variable references (identifiers)
## The actual dot expression is handled by xnkDotExpr
proc conv_xnkInstanceVar(node: XLangNode, ctx: TransformContext): MyNimNode =
  newIdentNode(node.varName)

proc conv_xnkClassVar(node: XLangNode, ctx: TransformContext): MyNimNode =
  newIdentNode(node.varName)

proc conv_xnkGlobalVar(node: XLangNode, ctx: TransformContext): MyNimNode =
  newIdentNode(node.varName)

## Nim: `proc = body` literal
proc conv_xnkProcLiteral(node: XLangNode, ctx: TransformContext): MyNimNode =
  # Just convert the body as anonymous proc
  convertToNimAST(node.procBody, ctx)

## C: Function pointer `void (*f)(int)`
## Nim: `proc(x: int)` (proc type)
proc conv_xnkProcPointer(node: XLangNode, ctx: TransformContext): MyNimNode =
  # Just return the identifier - proc pointers are first-class in Nim
  newIdentNode(node.procPointerName)

# conv_xnkNumberLit is defined earlier in the file (line 708)

## Ruby: `:symbol`
## Nim: (convert to string or ident)
proc conv_xnkSymbolLit(node: XLangNode, ctx: TransformContext): MyNimNode =
  newStrLitNode(node.symbolValue)
## Python: `x: Any` or JS: `any`
## Nim: No direct equivalent - use generics or RootObj
proc conv_xnkDynamicType(node: XLangNode, ctx: TransformContext): MyNimNode =
  # In Nim, we can use RootRef or just "auto" for generic code
  if node.dynamicConstraint.isSome():
    convertToNimAST(node.dynamicConstraint.get, ctx)
  else:
    newIdentNode("RootRef")

## Python: `(x*2 for x in range(10))` → iterator (lowered by generator_expressions.nim)
proc conv_xnkGeneratorExpr(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkGeneratorExpr")
## Async/await expression
## Python:     await asyncFunc()
## JavaScript: await asyncFunc()
## C#:         await AsyncFunc()
## Nim:        await asyncFunc()
proc conv_xnkAwaitExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  # Await requires asyncdispatch module
  ctx.addImport("asyncdispatch")
  result = newNimNode(nnkCommand)
  result.add(newIdentNode("await"))
  result.add(convertToNimAST(node.extAwaitExpr, ctx))
proc conv_xnkCompFor(node: XLangNode, ctx: TransformContext): MyNimNode = notYetImpl("xnkCompFor")

## C#: `default(T)` or `default`
## Nim: `default(T)` or type-specific defaults
proc conv_xnkDefaultExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  if node.defaultType.isSome():
    result = newNimNode(nnkCall)
    result.add(newIdentNode("default"))
    result.add(convertToNimAST(node.defaultType.get, ctx))
  else:
    # Generic default value
    result = newIdentNode("default")

## C#: `typeof(T)`
## Nim: `T` (type identifier) or `type(value)`
proc conv_xnkTypeOfExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  # In Nim, typeof is just the type itself or type() proc
  result = newNimNode(nnkCall)
  result.add(newIdentNode("type"))
  result.add(convertToNimAST(node.typeOfType, ctx))

## C#/C: `sizeof(T)`
## Nim: `sizeof(T)`
proc conv_xnkSizeOfExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkCall)
  result.add(newIdentNode("sizeof"))
  result.add(convertToNimAST(node.sizeOfType, ctx))

## C#: `checked(expr)` - overflow checking
## Nim: Just the expression (Nim checks by default in debug, or use -d:nimOldCaseObjects)
proc conv_xnkCheckedExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  # Nim has overflow checking in debug builds, so just convert the expression
  convertToNimAST(node.checkedExpr, ctx)

## C#: `throw new Exception()` as expression (lowered by throw_expression.nim)
proc conv_xnkThrowExpr(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkThrowExpr")

## C#: Switch expression `x switch { 1 => "one", _ => "other" }`
## Nim: Case expression
proc conv_xnkSwitchExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkCaseStmt)
  result.add(convertToNimAST(node.extSwitchExprValue, ctx))
  for arm in node.extSwitchExprArms:
    result.add(convertToNimAST(arm, ctx))
## C#: `stackalloc int[10]`
## Nim: `var arr: array[10, int]` (Nim is stack-allocated by default)
proc conv_xnkStackAllocExpr(node: XLangNode, ctx: TransformContext): MyNimNode =
  # In Nim, arrays are stack-allocated by default, so create array type
  result = newNimNode(nnkBracketExpr)
  result.add(newIdentNode("array"))
  if node.extStackAllocSize.isSome():
    result.add(convertToNimAST(node.extStackAllocSize.get, ctx))
  else:
    # Unknown size - use seq instead
    result = newNimNode(nnkBracketExpr)
    result.add(newIdentNode("seq"))
  result.add(convertToNimAST(node.extStackAllocType, ctx))

## C#: `new[] { 1, 2, 3 }` - implicit array creation
## Nim: `@[1, 2, 3]` or array literal
proc conv_xnkImplicitArrayCreation(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkPrefix)
  result.add(newIdentNode("@"))
  let bracket = newNimNode(nnkBracket)
  for elem in node.implicitArrayElements:
    bracket.add(convertToNimAST(elem, ctx))
  result.add(bracket)
proc conv_xnkNamedType(node: XLangNode, ctx: TransformContext): MyNimNode = newIdentNode(node.typeName)

## C#: `int[]` or `int[10]`
## Nim: `seq[int]` or `array[10, int]`
proc conv_xnkArrayType(node: XLangNode, ctx: TransformContext): MyNimNode =
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
proc conv_xnkMapType(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  result.add(newIdentNode("Table"))
  result.add(convertToNimAST(node.keyType, ctx))
  result.add(convertToNimAST(node.valueType, ctx))

## Function type: `(int) -> string`
## Nim: `proc(x: int): string`
proc conv_xnkFuncType(node: XLangNode, ctx: TransformContext): MyNimNode =
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

proc conv_xnkFunctionType(node: XLangNode, ctx: TransformContext): MyNimNode = conv_xnkFuncType(node, ctx)

## C: `int*`
## Nim: `ptr int`
proc conv_xnkPointerType(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkPtrTy)
  result.add(convertToNimAST(node.referentType, ctx))

## C#: `ref T`
## Nim: `ref T`
proc conv_xnkReferenceType(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkRefTy)
  result.add(convertToNimAST(node.referentType, ctx))

## C#: `(int x, string y)`
## Nim: `tuple[x: int, y: string]`
proc conv_xnkTupleType(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkTupleTy)
  for elem in node.tupleTypeElements:
    # Each element should be a Parameter with paramName and paramType
    if elem.kind == xnkParameter:
      var identDefs = newNimNode(nnkIdentDefs)
      if elem.paramName.len > 0:
        identDefs.add(newIdentNode(elem.paramName))
      else:
        identDefs.add(newEmptyNode())  # Unnamed tuple element
      if elem.paramType.isSome():
        identDefs.add(convertToNimAST(elem.paramType.get, ctx))
      else:
        identDefs.add(newEmptyNode())
      identDefs.add(newEmptyNode())  # No default value for tuple type fields
      result.add(identDefs)

## C#: `List<T>`
## Nim: `List[T]`
proc conv_xnkGenericType(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  result.add(newIdentNode(node.genericTypeName))
  for arg in node.genericArgs:
    result.add(convertToNimAST(arg, ctx))
proc conv_xnkUnionType(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkUnionType")

## TypeScript: `A & B` (should be lowered by transform)
proc conv_xnkIntersectionType(node: XLangNode, ctx: TransformContext): MyNimNode = assertLowered("xnkIntersectionType")

## Nim: `distinct int`
proc conv_xnkDistinctType(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkDistinctTy)
  result.add(convertToNimAST(node.distinctBaseType, ctx))

## Parameter in function signature
## Nim: `x: int` → nnkIdentDefs
proc conv_xnkParameter(node: XLangNode, ctx: TransformContext): MyNimNode =
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
proc conv_xnkArgument(node: XLangNode, ctx: TransformContext): MyNimNode =
  convertToNimAST(node.argValue, ctx)
## Python decorator (should be lowered to pragmas or discarded)
proc conv_xnkDecorator(node: XLangNode, ctx: TransformContext): MyNimNode = newNimNode(nnkDiscardStmt)

proc conv_xnkConceptRequirement(node: XLangNode, ctx: TransformContext): MyNimNode = notYetImpl("xnkConceptRequirement")
proc conv_xnkConceptDecl(node: XLangNode, ctx: TransformContext): MyNimNode = notYetImpl("xnkConceptDecl")

## Qualified name: `a.b.c`
## Nim: nested dot expression
proc conv_xnkQualifiedName(node: XLangNode, ctx: TransformContext): MyNimNode =
  # Recursively build: left.right
  result = newNimNode(nnkDotExpr)
  result.add(convertToNimAST(node.qualifiedLeft, ctx))
  result.add(convertToNimAST(node.qualifiedRight, ctx))

## Alias qualified name: `alias::Name`
proc conv_xnkAliasQualifiedName(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkDotExpr)
  result.add(newIdentNode(node.aliasQualifier))
  result.add(newIdentNode(node.aliasQualifiedName))

## Generic name: `List<T>`
## Nim: `List[T]` (bracket expression)
proc conv_xnkGenericName(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkBracketExpr)
  result.add(newIdentNode(node.genericNameIdentifier))
  for arg in node.genericNameArgs:
    result.add(convertToNimAST(arg, ctx))

## Method reference: `obj.Method`
## Nim: dot expression
proc conv_xnkMethodReference(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkDotExpr)
  result.add(convertToNimAST(node.refObject, ctx))
  result.add(newIdentNode(node.refMethod))
## Python module (convert to statement list)
proc conv_xnkModuleDecl(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkStmtList)
  for stmt in node.moduleBody:
    result.add(convertToNimAST(stmt, ctx))

## C#: `using X = Y;`
## Nim: `type X = Y`
proc conv_xnkTypeAlias(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkTypeDef)
  result.add(newIdentNode(node.aliasName))
  result.add(newEmptyNode()) # generic params
  result.add(convertToNimAST(node.aliasTarget, ctx))

## Nim: `include "filename"`
proc conv_xnkInclude(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkIncludeStmt)
  result.add(convertToNimAST(node.includeName, ctx))

## Nim mixin statement
proc conv_xnkMixinDecl(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkMixinStmt)
  for name in node.mixinNames:
    result.add(newIdentNode(name))

proc conv_xnkTemplateDecl(node: XLangNode, ctx: TransformContext): MyNimNode = notYetImpl("xnkTemplateDecl")
proc conv_xnkMacroDecl(node: XLangNode, ctx: TransformContext): MyNimNode = notYetImpl("xnkMacroDecl")
proc conv_xnkExtend(node: XLangNode, ctx: TransformContext): MyNimNode = notYetImpl("xnkExtend")
proc conv_xnkTypeSwitchStmt(node: XLangNode, ctx: TransformContext): MyNimNode = notYetImpl("xnkTypeSwitchStmt")
proc conv_xnkTypeCaseClause(node: XLangNode, ctx: TransformContext): MyNimNode = notYetImpl("xnkTypeCaseClause")
proc conv_xnkSwitchCase(node: XLangNode, ctx: TransformContext): MyNimNode = notYetImpl("xnkSwitchCase")
## Assignment statement
## Universal: x = 5, arr[i] = 10, obj.field = "hello"
## Nim: Same syntax
proc conv_xnkAsgn(node: XLangNode, ctx: TransformContext): MyNimNode =
  result = newNimNode(nnkAsgn)
  result.add(convertToNimAST(node.asgnLeft, ctx))
  result.add(convertToNimAST(node.asgnRight, ctx))


# Helper proc to get a description of a node for error reporting
proc getNodeDescription(node: XLangNode): string =
  if node.isNil:
    return "nil"

  result = $node.kind

  # Add identifying information based on node type
  case node.kind
  of xnkModule:
    if node.moduleName.len > 0:
      result &= " (module: " & node.moduleName & ")"
  of xnkFuncDecl, xnkMethodDecl:
    if node.funcName.len > 0:
      result &= " (name: " & node.funcName & ")"
  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    if node.declName.len > 0:
      result &= " (name: " & node.declName & ")"
  of xnkIdentifier:
    if node.identName.len > 0:
      result &= " (" & node.identName & ")"
  of xnkIntLit:
    if node.literalValue.len > 0:
      result &= " (" & node.literalValue & ")"
  of xnkFloatLit:
    if node.literalValue.len > 0:
      result &= " (" & node.literalValue & ")"
  of xnkStringLit:
    if node.literalValue.len > 0:
      let s = node.literalValue
      result &= " (\"" & (if s.len > 30: s[0..29] & "..." else: s) & "\")"
  else:
    discard

proc modifyBeforeConversion(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Preprocessing pass that modifies the XLang AST before conversion to Nim AST
  ## This is where we add necessary imports based on what features are used
  result = node

  # Only process at file level
  if node.kind != xnkFile:
    return result

  # Collect all node kinds used in the AST
  var mutableNode = node
  let kinds = collectAllKinds(mutableNode)

  # Track which imports we need to add
  var importsToAdd: seq[string] = @[]

  # Check if file contains lambdas → need std/sugar
  if kinds.contains(xnkLambdaExpr) or kinds.contains(xnkLambdaProc) or kinds.contains(xnkArrowFunc):
    importsToAdd.add("std/sugar")

  # Check if file uses async/await → need asyncdispatch
  # Note: xnkExternal_Await is the node kind for await expressions
  # Also check for async functions by scanning for functions with isAsync=true
  if kinds.contains(xnkExternal_Await):
    importsToAdd.add("asyncdispatch")
  else:
    # Also check if any function/method declarations have isAsync=true
    var needsAsync = false
    traverseTree(mutableNode, proc(n: var XLangNode) =
      if n.kind in {xnkFuncDecl, xnkMethodDecl} and n.isAsync:
        needsAsync = true
    )
    if needsAsync:
      importsToAdd.add("asyncdispatch")

  # Check if file uses map/dictionary literals → need tables
  if kinds.contains(xnkMapLiteral):
    importsToAdd.add("tables")

  # Add all required imports at the beginning of moduleDecls
  for i, importPath in importsToAdd:
    let importNode = XLangNode(
      kind: xnkImport,
      importPath: importPath,
      importAlias: none(string)
    )
    # Insert in reverse order so they appear in the order we added them
    result.moduleDecls.insert(importNode, 0)


proc convertToNimAST(node: XLangNode, ctx: TransformContext = nil): MyNimNode =
  # Check for nil node
  if node.isNil:
    let fileInfo = if not ctx.isNil and ctx.currentFile != "": " in " & ctx.currentFile else: ""
    echo "WARNING: convertToNimAST called with nil node", fileInfo
    return newNimNode(nnkDiscardStmt)

  # Create temporary context if none provided (for backward compatibility)
  let context = if ctx.isNil: newMinimalContext() else: ctx

  # Push node onto stack for error tracking
  context.conversion.nodeStack.add(node)
  defer:
    # Pop node from stack when we exit (success or failure)
    discard context.conversion.nodeStack.pop()

  # Wrap in try-except to provide better error context
  try:
    case node.kind

    of xnkFile:
      result = conv_xnkFile(node, context)
    of xnkModule:
      result = conv_xnkModule(node, context)
    of xnkNamespace:
      result = conv_xnkNamespace(node, context)
    of xnkFuncDecl, xnkMethodDecl:
      # Choose converter based on whether we're in a class context and if it's static
      if context.isInClassScope() and not node.funcIsStatic:
        # Instance method - add self parameter
        result = conv_xnkFuncDecl_instanceMethod(node, context)
      else:
        # Standalone function or static method
        result = conv_xnkFuncDecl_standalone(node, context)
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
    of xnkExternal_ForStmt:
      result = conv_xnkForStmt(node, ctx)
    of xnkBlockStmt:
      result = conv_xnkBlockStmt(node, ctx)
    of xnkCallExpr:
      result = conv_xnkCallExpr(node, ctx)
    of xnkThisCall:
      result = conv_xnkThisCall(node, ctx)
    of xnkBaseCall:
      result = conv_xnkBaseCall(node, ctx)
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
    of xnkNumberLit:
      result = conv_xnkNumberLit(node, ctx)
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
    of xnkExternal_Property:
      result = conv_xnkPropertyDecl(node, ctx)
    of xnkFieldDecl:
      result = conv_xnkFieldDecl(node, ctx)
    of xnkConstructorDecl:
      result = conv_xnkConstructorDecl(node, ctx)
    of xnkDestructorDecl:
      result = conv_xnkDestructorDecl(node, ctx)
    of xnkExternal_Delegate:
      result = conv_xnkDelegateDecl(node, ctx)
    of xnkExternal_Event:
      result = conv_xnkExternal_Event(node, ctx)
    of xnkModuleDecl:
      result = conv_xnkModuleDecl(node, ctx)
    of xnkTypeAlias:
      result = conv_xnkTypeAlias(node, ctx)
    of xnkAbstractDecl:
      result = conv_xnkAbstractDecl(node, ctx)
    of xnkEnumMember:
      result = conv_xnkEnumMember(node, ctx)
    of xnkExternal_Indexer:
      result = conv_xnkIndexerDecl(node, ctx)
    of xnkExternal_Operator:
      result = conv_xnkOperatorDecl(node, ctx)
    of xnkExternal_ConversionOp:
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
    of xnkExternal_With:
      result = conv_xnkWithStmt(node, ctx)
    of xnkExternal_Resource:
      result = conv_xnkResourceStmt(node, ctx)
    of xnkResourceItem:
      result = conv_xnkResourceItem(node, ctx)
    of xnkExternal_Pass:
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
    of xnkExternal_Fixed:
      result = conv_xnkFixedStmt(node, ctx)
    of xnkExternal_Lock:
      result = conv_xnkLockStmt(node, ctx)
    of xnkExternal_Unsafe:
      result = conv_xnkUnsafeStmt(node, ctx)
    of xnkExternal_Checked:
      result = conv_xnkCheckedStmt(node, ctx)
    of xnkExternal_LocalFunction:
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
    of xnkExternal_Ternary:
      result = conv_xnkTernaryExpr(node, ctx)
    of xnkSliceExpr:
      result = conv_xnkSliceExpr(node, ctx)
    of xnkExternal_SafeNavigation:
      result = conv_xnkSafeNavigationExpr(node, ctx)
    of xnkExternal_NullCoalesce:
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
    of xnkSymbolLit:
      result = conv_xnkSymbolLit(node, ctx)
    of xnkDynamicType:
      result = conv_xnkDynamicType(node, ctx)
    of xnkExternal_Generator:
      result = conv_xnkGeneratorExpr(node, ctx)
    of xnkExternal_Await:
      result = conv_xnkAwaitExpr(node, ctx)
    of xnkExternal_StringInterp:
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
    of xnkExternal_ThrowExpr:
      result = conv_xnkThrowExpr(node, ctx)
    of xnkExternal_SwitchExpr:
      result = conv_xnkSwitchExpr(node, ctx)
    of xnkExternal_StackAlloc:
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
    of xnkTupleType:
      result = conv_xnkTupleType(node, ctx)
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
    
    of xnkDictEntry:
      result = conv_xnkDictEntry(node, ctx)
    else:
      raise newException(ValueError, "Unsupported or unlowered XLang node kind: " & $node.kind)
  except Exception as e:
    # Print hierarchy only once - when we first catch the error
    # Check if this is the first time we're seeing this error by checking
    # if we're deeper in the stack than a simple File node
    if context.conversion.nodeStack.len > 1:
      let fileInfo = if context.currentFile != "": " in " & context.currentFile else: ""
      echo "ERROR", fileInfo, ":"
      echo "  ", e.msg
      echo "  Node hierarchy (innermost first):"
      for i in countdown(context.conversion.nodeStack.len - 1, 0):
        let desc = getNodeDescription(context.conversion.nodeStack[i])
        echo "    ", desc
    raise  # Re-raise the exception with original stack trace


proc xlangToNimAST*(node: XLangNode, ctx: TransformContext = nil): MyNimNode =
  let modifiedNode = modifyBeforeConversion(node, ctx)
  convertToNimAST(modifiedNode, ctx)
