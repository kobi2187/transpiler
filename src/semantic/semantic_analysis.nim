# semantic_analysis.nim - Semantic analysis pass for XLang AST
#
# This module provides symbol table construction and identifier resolution.
# Run after parsing, before transforms. Results are used by transforms and emitter.
#
# Key concepts:
# - Symbol: A named entity (variable, function, parameter, type, field)
# - Scope: A lexical scope containing symbols (module, class, function, block)
# - SemanticInfo: The analysis result - maps AST nodes to their resolved symbols

import std/[tables, sets, options, hashes, strutils]
import uuid4
import core/xlangtypes

# Nim builtin identifiers that don't need to be declared
const NimBuiltins* = [
  # Implicit variables
  "result",
  # Boolean literals (sometimes parsed as identifiers)
  "true", "false",
  # Nil
  "nil",
  # Common procs
  "echo", "debugEcho", "assert", "doAssert", "quit", "new", "newSeq", "newString",
  "len", "high", "low", "inc", "dec", "succ", "pred", "abs", "min", "max",
  "ord", "chr", "sizeof", "typeof", "defined", "declared",
  "add", "insert", "delete", "pop", "contains", "find",
  "repr", "astToStr", "getTypeInst",
  # String operations
  "$", "&",
  # Comparison
  "cmp",
  # Memory
  "alloc", "dealloc", "realloc", "allocShared", "deallocShared",
  "GC_ref", "GC_unref", "GC_fullCollect",
  # Type operations
  "compiles", "default", "reset", "move", "sink",
  # Iterators
  "items", "pairs", "mitems", "mpairs", "fields", "fieldPairs",
  # Async
  "await", "async",
  # Exceptions
  "getCurrentException", "getCurrentExceptionMsg", "raise",
  # Common templates/macros
  "when", "block", "static", "defer",
  # Common modules (often used unqualified)
  "strutils", "sequtils", "tables", "sets", "options", "json", "os", "strformat",
  # Macro utilities
  "newCall", "newLit", "newIdentNode", "newTree", "bindSym", "genSym",
  "newStmtList", "newNimNode", "ident", "quote", "unquote",
  "expectKind", "expectLen", "expectMinLen",
  # Common type constructors
  "some", "none",
  # Operators as identifiers
  "+", "-", "*", "/", "==", "!=", "<", ">", "<=", ">=",
  "and", "or", "not", "xor", "shl", "shr", "div", "mod",
  "%", "%*", "@", "[]", "[]=", "{}",
  # Range
  "..", "..<",
  # Misc
  "discard", "self", "this", "it"
].toHashSet

# Hash function for XLangNode (pointer identity for ref object)
proc hash*(node: XLangNode): Hash =
  result = hash(cast[pointer](node))

type
  SymbolKind* = enum
    skVariable      # var, let declarations
    skConstant      # const declarations
    skParameter     # function/method parameters
    skFunction      # function/method declarations
    skType          # class, struct, interface, enum declarations
    skField         # class/struct fields
    skProperty      # property declarations (before transformation to getX/setX)
    skEnumMember    # enum values
    skNamespace     # namespace declarations
    skModule        # module declarations

  Symbol* = ref object
    id*: Uuid                  # Unique identifier for this symbol
    name*: string              # Original name from source
    mangledName*: string       # Target language name (empty = no rename needed)
    kind*: SymbolKind
    declNode*: XLangNode       # The AST node where this was declared
    scope*: Scope              # The scope this symbol belongs to
    # Analysis results
    isCaptured*: bool          # Referenced from inner scope (closure)
    isMutable*: bool           # Reassigned after declaration
    isUsed*: bool              # Referenced at least once
    capturedBy*: seq[XLangNode]  # Functions that capture this symbol

  ScopeKind* = enum
    scopeModule
    scopeNamespace
    scopeClass
    scopeFunction
    scopeBlock
    scopeLoop       # for/while - for break/continue analysis

  Scope* = ref object
    id*: Uuid                  # Unique identifier for this scope
    kind*: ScopeKind
    parent*: Scope
    node*: XLangNode           # The AST node that created this scope
    symbols*: Table[string, Symbol]
    children*: seq[Scope]      # For tree traversal if needed
    depth*: int

  SemanticInfo* = ref object
    # Core mappings
    nodeToSymbol*: Table[XLangNode, Symbol]   # Identifier nodes → resolved symbol
    declToSymbol*: Table[XLangNode, Symbol]   # Declaration nodes → their symbol
    nodeToScope*: Table[XLangNode, Scope]     # Scope-creating nodes → their scope

    # Global registries
    allSymbols*: seq[Symbol]
    allScopes*: seq[Scope]

    # UUID-based lookups
    symbolById*: Table[Uuid, Symbol]          # UUID → Symbol (for stable lookups)
    scopeById*: Table[Uuid, Scope]            # UUID → Scope (for stable lookups)

    # For rename tracking
    renames*: Table[Symbol, string]           # Symbol → target name

    # Target language keywords (for conflict detection)
    targetKeywords*: HashSet[string]

    # Errors collected during analysis
    errors*: seq[string]
    warnings*: seq[string]

  Analyzer = ref object
    info*: SemanticInfo
    currentScope*: Scope
    globalScope*: Scope

# Hash function for Symbol (pointer identity for ref object)
proc hash*(sym: Symbol): Hash =
  result = hash(cast[pointer](sym))

# =============================================================================
# Scope Management
# =============================================================================

proc newScope(parent: Scope, kind: ScopeKind, node: XLangNode): Scope =
  result = Scope(
    id: uuid4(),               # Generate unique ID for scope
    kind: kind,
    parent: parent,
    node: node,
    symbols: initTable[string, Symbol](),
    children: @[],
    depth: if parent.isNil: 0 else: parent.depth + 1
  )
  if not parent.isNil:
    parent.children.add(result)

proc addSymbol*(scope: Scope, name: string, kind: SymbolKind,
                node: XLangNode, info: SemanticInfo): Symbol =
  ## Add a symbol to the scope. Returns the created symbol.
  result = Symbol(
    id: uuid4(),               # Generate unique ID for symbol
    name: name,
    mangledName: "",
    kind: kind,
    declNode: node,
    scope: scope,
    isCaptured: false,
    isMutable: false,
    isUsed: false,
    capturedBy: @[]
  )
  scope.symbols[name] = result
  info.allSymbols.add(result)
  info.declToSymbol[node] = result
  info.symbolById[result.id] = result  # Register by UUID for stable lookup

proc lookup*(scope: Scope, name: string): Option[Symbol] =
  ## Look up a symbol by name, searching up the scope chain.
  var s = scope
  while s != nil:
    if name in s.symbols:
      return some(s.symbols[name])
    s = s.parent
  return none(Symbol)

proc lookupLocal*(scope: Scope, name: string): Option[Symbol] =
  ## Look up a symbol only in the current scope (no parent search).
  if name in scope.symbols:
    return some(scope.symbols[name])
  return none(Symbol)

# =============================================================================
# Scope Entry Helpers
# =============================================================================

template withScope(a: Analyzer, kind: ScopeKind, node: XLangNode, body: untyped) =
  let saved = a.currentScope
  a.currentScope = newScope(saved, kind, node)
  a.info.nodeToScope[node] = a.currentScope
  a.info.allScopes.add(a.currentScope)
  a.info.scopeById[a.currentScope.id] = a.currentScope  # Register by UUID for stable lookup
  body
  a.currentScope = saved

# =============================================================================
# Analysis Pass
# =============================================================================

# Forward declarations
proc collectDeclarations(a: Analyzer, node: XLangNode)
proc analyzeReferences(a: Analyzer, node: XLangNode)

# Pass 1 helper functions - collect declarations only
proc collectDeclarationsChildren(a: Analyzer, nodes: seq[XLangNode]) =
  for child in nodes:
    a.collectDeclarations(child)

proc collectDeclarationsOption(a: Analyzer, node: Option[XLangNode]) =
  if node.isSome:
    a.collectDeclarations(node.get)

# Pass 2 helper functions - analyze references after all declarations collected
proc analyzeReferencesChildren(a: Analyzer, nodes: seq[XLangNode]) =
  for child in nodes:
    a.analyzeReferences(child)

proc analyzeReferencesOption(a: Analyzer, node: Option[XLangNode]) =
  if node.isSome:
    a.analyzeReferences(node.get)

# Helper to enter a scope that was created in pass 1
template withExistingScope(a: Analyzer, node: XLangNode, body: untyped) =
  let scope = a.info.nodeToScope.getOrDefault(node)
  if scope != nil:
    let saved = a.currentScope
    a.currentScope = scope
    body
    a.currentScope = saved
  else:
    # Scope wasn't created in pass 1, just execute body
    body

# =============================================================================
# Pass 1: Collect Declarations
# =============================================================================
# This pass only collects symbols (functions, types, variables) without
# analyzing their bodies. This allows forward references to work.

proc collectDeclarations(a: Analyzer, node: XLangNode) =
  if node.isNil:
    return

  case node.kind

  # -------------------------------------------------------------------------
  # Scope-creating constructs - create scopes but don't analyze bodies yet
  # -------------------------------------------------------------------------

  of xnkModule:
    a.withScope(scopeModule, node):
      for child in node.moduleBody:
        a.collectDeclarations(child)

  of xnkNamespace:
    a.withScope(scopeNamespace, node):
      for child in node.namespaceBody:
        a.collectDeclarations(child)

  of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
    # Register the type
    discard a.currentScope.addSymbol(node.typeNameDecl, skType, node, a.info)
    # Enter class scope and collect member declarations
    a.withScope(scopeClass, node):
      for member in node.members:
        a.collectDeclarations(member)

  of xnkFuncDecl:
    # Register function
    discard a.currentScope.addSymbol(node.funcName, skFunction, node, a.info)
    # Enter function scope to collect parameters and local declarations
    a.withScope(scopeFunction, node):
      for param in node.params:
        a.collectDeclarations(param)
      # Traverse body to collect local variable declarations
      a.collectDeclarations(node.body)

  of xnkMethodDecl:
    discard a.currentScope.addSymbol(node.methodName, skFunction, node, a.info)
    a.withScope(scopeFunction, node):
      for param in node.mparams:
        a.collectDeclarations(param)
      a.collectDeclarations(node.mbody)

  of xnkIteratorDecl:
    discard a.currentScope.addSymbol(node.iteratorName, skFunction, node, a.info)
    a.withScope(scopeFunction, node):
      for param in node.iteratorParams:
        a.collectDeclarations(param)
      a.collectDeclarations(node.iteratorBody)

  of xnkConstructorDecl:
    a.withScope(scopeFunction, node):
      for param in node.constructorParams:
        a.collectDeclarations(param)
      a.collectDeclarations(node.constructorBody)

  # -------------------------------------------------------------------------
  # Top-level declarations
  # -------------------------------------------------------------------------

  of xnkVarDecl, xnkLetDecl:
    discard a.currentScope.addSymbol(node.declName, skVariable, node, a.info)

  of xnkConstDecl:
    discard a.currentScope.addSymbol(node.declName, skConstant, node, a.info)

  of xnkParameter:
    discard a.currentScope.addSymbol(node.paramName, skParameter, node, a.info)

  of xnkFieldDecl:
    discard a.currentScope.addSymbol(node.fieldName, skField, node, a.info)

  of xnkExternal_Property:
    # Register property as a symbol - will be transformed to getX/setX later
    discard a.currentScope.addSymbol(node.extPropName, skProperty, node, a.info)

  of xnkEnumDecl:
    discard a.currentScope.addSymbol(node.enumName, skType, node, a.info)
    for member in node.enumMembers:
      a.collectDeclarations(member)

  of xnkEnumMember:
    discard a.currentScope.addSymbol(node.enumMemberName, skEnumMember, node, a.info)

  of xnkTypeDecl:
    discard a.currentScope.addSymbol(node.typeDefName, skType, node, a.info)

  of xnkTypeAlias:
    discard a.currentScope.addSymbol(node.aliasName, skType, node, a.info)

  of xnkModuleDecl:
    discard a.currentScope.addSymbol(node.moduleNameDecl, skModule, node, a.info)
    for member in node.moduleMembers:
      a.collectDeclarations(member)

  of xnkAbstractDecl:
    discard a.currentScope.addSymbol(node.abstractName, skType, node, a.info)

  of xnkCFuncDecl:
    discard a.currentScope.addSymbol(node.cfuncName, skFunction, node, a.info)

  of xnkExternalVar:
    discard a.currentScope.addSymbol(node.extVarName, skVariable, node, a.info)

  of xnkConceptDecl:
    discard a.currentScope.addSymbol(node.conceptDeclName, skType, node, a.info)

  of xnkTemplateDef, xnkMacroDef:
    discard a.currentScope.addSymbol(node.name, skFunction, node, a.info)

  of xnkGenericParameter:
    discard a.currentScope.addSymbol(node.genericParamName, skType, node, a.info)

  of xnkFile:
    for decl in node.moduleDecls:
      a.collectDeclarations(decl)

  # -------------------------------------------------------------------------
  # Statement blocks - traverse to find declarations inside
  # -------------------------------------------------------------------------

  of xnkBlockStmt:
    a.withScope(scopeBlock, node):
      for stmt in node.blockBody:
        a.collectDeclarations(stmt)

  of xnkIfStmt:
    a.collectDeclarations(node.ifCondition)
    a.collectDeclarations(node.ifBody)
    if node.elseBody.isSome:
      a.collectDeclarations(node.elseBody.get)

  of xnkWhileStmt:
    a.withScope(scopeLoop, node):
      a.collectDeclarations(node.whileCondition)
      a.collectDeclarations(node.whileBody)

  of xnkExternal_ForStmt:
    a.withScope(scopeLoop, node):
      # C-style for loop - collect init declarations
      a.collectDeclarationsOption(node.extForInit)
      a.collectDeclarationsOption(node.extForCond)
      a.collectDeclarationsOption(node.extForIncrement)
      a.collectDeclarationsOption(node.extForBody)

  of xnkForeachStmt:
    a.withScope(scopeLoop, node):
      # foreachVar is a node (could be xnkIdentifier or pattern)
      a.collectDeclarations(node.foreachVar)
      a.collectDeclarations(node.foreachIter)
      a.collectDeclarations(node.foreachBody)

  of xnkTryStmt:
    a.collectDeclarations(node.tryBody)
    for catchClause in node.catchClauses:
      a.collectDeclarations(catchClause)
    a.collectDeclarationsOption(node.finallyClause)

  of xnkCatchStmt:
    a.withScope(scopeBlock, node):
      if node.catchVar.isSome:
        discard a.currentScope.addSymbol(node.catchVar.get, skVariable, node, a.info)
      a.collectDeclarations(node.catchBody)

  of xnkSwitchStmt:
    a.collectDeclarations(node.switchExpr)
    for caseNode in node.switchCases:
      a.collectDeclarations(caseNode)

  of xnkCaseClause:
    for val in node.caseValues:
      a.collectDeclarations(val)
    a.collectDeclarations(node.caseBody)

  # Skip everything else - expressions don't contain declarations
  else:
    discard

# =============================================================================
# Pass 2: Analyze References and Bodies
# =============================================================================
# This pass analyzes bodies, resolves identifiers, tracks captures, etc.

proc analyzeReferences(a: Analyzer, node: XLangNode) =
  if node.isNil:
    return

  case node.kind

  # -------------------------------------------------------------------------
  # Scope-creating constructs
  # -------------------------------------------------------------------------

  of xnkModule:
    a.withExistingScope(node):
      a.analyzeReferencesChildren(node.moduleBody)

  of xnkNamespace:
    a.withExistingScope(node):
      a.analyzeReferencesChildren(node.namespaceBody)

  of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
    # Enter class scope for members (symbol already registered in pass 1)
    a.withExistingScope(node):
      a.analyzeReferencesChildren(node.baseTypes)
      a.analyzeReferencesChildren(node.members)

  of xnkFuncDecl:
    # Enter function scope (symbol already registered in pass 1)
    a.withExistingScope(node):
      # Analyze parameters
      for param in node.params:
        a.analyzeReferences(param)
      # Analyze body
      a.analyzeReferences(node.body)

  of xnkMethodDecl:
    # Enter function scope (symbol already registered in pass 1)
    a.withExistingScope(node):
      a.analyzeReferencesOption(node.receiver)
      for param in node.mparams:
        a.analyzeReferences(param)
      a.analyzeReferences(node.mbody)

  of xnkIteratorDecl:
    a.withExistingScope(node):
      for param in node.iteratorParams:
        a.analyzeReferences(param)
      a.analyzeReferences(node.iteratorBody)

  of xnkConstructorDecl:
    a.withExistingScope(node):
      for param in node.constructorParams:
        a.analyzeReferences(param)
      a.analyzeReferencesChildren(node.constructorInitializers)
      a.analyzeReferences(node.constructorBody)

  of xnkLambdaExpr:
    a.withExistingScope(node):
      a.analyzeReferencesChildren(node.lambdaParams)
      a.analyzeReferences(node.lambdaBody)

  of xnkBlockStmt:
    a.withExistingScope(node):
      a.analyzeReferencesChildren(node.blockBody)

  of xnkWhileStmt:
    a.analyzeReferences(node.whileCondition)
    a.withExistingScope(node):
      a.analyzeReferences(node.whileBody)

  of xnkForeachStmt:
    a.withExistingScope(node):
      # Loop variable was declared in pass 1
      a.analyzeReferences(node.foreachVar)
      a.analyzeReferences(node.foreachIter)
      a.analyzeReferences(node.foreachBody)

  of xnkTryStmt:
    a.analyzeReferences(node.tryBody)
    a.analyzeReferencesChildren(node.catchClauses)
    a.analyzeReferencesOption(node.finallyClause)

  of xnkCatchStmt:
    a.withExistingScope(node):
      # Exception variable was declared in pass 1
      a.analyzeReferencesOption(node.catchType)
      a.analyzeReferences(node.catchBody)

  # -------------------------------------------------------------------------
  # Declarations (symbols already added in pass 1, just analyze sub-expressions)
  # -------------------------------------------------------------------------

  of xnkVarDecl, xnkLetDecl:
    a.analyzeReferencesOption(node.declType)
    a.analyzeReferencesOption(node.initializer)

  of xnkConstDecl:
    a.analyzeReferencesOption(node.declType)
    a.analyzeReferencesOption(node.initializer)

  of xnkParameter:
    a.analyzeReferencesOption(node.paramType)
    a.analyzeReferencesOption(node.defaultValue)

  of xnkFieldDecl:
    a.analyzeReferences(node.fieldType)
    a.analyzeReferencesOption(node.fieldInitializer)

  of xnkEnumDecl:
    # Symbol already added in pass 1
    for member in node.enumMembers:
      a.analyzeReferences(member)

  of xnkEnumMember:
    # Symbol already added in pass 1
    a.analyzeReferencesOption(node.enumMemberValue)

  of xnkTypeDecl:
    # Symbol already added in pass 1
    a.analyzeReferences(node.typeDefBody)

  of xnkTypeAlias:
    # Symbol already added in pass 1
    a.analyzeReferences(node.aliasTarget)

  of xnkModuleDecl:
    # Symbol already added in pass 1
    a.analyzeReferencesChildren(node.moduleMembers)

  of xnkDestructorDecl:
    a.withExistingScope(node):
      a.analyzeReferencesOption(node.destructorBody)

  of xnkAbstractDecl:
    # Symbol already added in pass 1
    a.analyzeReferencesChildren(node.abstractBody)

  of xnkLibDecl:
    a.analyzeReferencesChildren(node.libBody)

  of xnkCFuncDecl:
    # Symbol already added in pass 1
    a.analyzeReferencesChildren(node.cfuncParams)
    a.analyzeReferencesOption(node.cfuncReturnType)

  of xnkExternalVar:
    # Symbol already added in pass 1
    a.analyzeReferences(node.extVarType)

  of xnkConceptDecl:
    # Symbol already added in pass 1
    a.analyzeReferencesChildren(node.conceptRequirements)

  of xnkTemplateDef, xnkMacroDef:
    # Symbol already added in pass 1
    a.withExistingScope(node):
      a.analyzeReferencesChildren(node.tplparams)
      a.analyzeReferences(node.tmplbody)

  of xnkGenericParameter:
    # Symbol already added in pass 1
    a.analyzeReferencesChildren(node.genericParamConstraints)

  # -------------------------------------------------------------------------
  # References (resolve symbols)
  # -------------------------------------------------------------------------

  of xnkIdentifier:
    # Debug: trace nextChar lookups
    let isDebugIdent = node.identName == "nextChar" and false  # set to true to enable
    if isDebugIdent:
      stderr.writeLine "Looking up 'nextChar' from scope depth ", a.currentScope.depth, " kind ", a.currentScope.kind
      var s = a.currentScope
      while s != nil:
        stderr.writeLine "  -> ", s.kind, " depth ", s.depth, " has nextChar: ", "nextChar" in s.symbols
        s = s.parent

    let sym = a.currentScope.lookup(node.identName)

    if isDebugIdent:
      stderr.writeLine "Lookup result: ", sym.isSome
    if sym.isSome:
      let s = sym.get
      a.info.nodeToSymbol[node] = s
      s.isUsed = true

      # Check if captured from outer scope
      if s.scope.depth < a.currentScope.depth:
        # Find the function scope boundary
        var funcScope = a.currentScope
        while funcScope != nil and funcScope.kind != scopeFunction:
          funcScope = funcScope.parent

        # If symbol is from outside our function, it's captured
        if funcScope != nil and s.scope.depth < funcScope.depth:
          s.isCaptured = true
          if funcScope.node notin s.capturedBy:
            s.capturedBy.add(funcScope.node)
    elif node.identName notin NimBuiltins:
      # Undefined identifier - not a builtin, could be external reference
      # Debug: check if this identifier exists anywhere in allSymbols
      var existsElsewhere = false
      for existingSym in a.info.allSymbols:
        if existingSym.name == node.identName:
          existsElsewhere = true
          break
      if existsElsewhere:
        a.info.warnings.add("Unresolved (exists elsewhere): " & node.identName)
      else:
        a.info.warnings.add("Undefined identifier: " & node.identName)

  of xnkAsgn:
    a.analyzeReferences(node.asgnLeft)
    a.analyzeReferences(node.asgnRight)
    # Mark target as mutable if it's an identifier
    if node.asgnLeft.kind == xnkIdentifier:
      let sym = a.info.nodeToSymbol.getOrDefault(node.asgnLeft, nil)
      if sym != nil:
        sym.isMutable = true

  # -------------------------------------------------------------------------
  # Expressions (recurse)
  # -------------------------------------------------------------------------

  of xnkBinaryExpr:
    a.analyzeReferences(node.binaryLeft)
    a.analyzeReferences(node.binaryRight)

  of xnkUnaryExpr:
    a.analyzeReferences(node.unaryOperand)

  of xnkCallExpr:
    a.analyzeReferences(node.callee)
    a.analyzeReferencesChildren(node.args)

  of xnkMemberAccessExpr:
    a.analyzeReferences(node.memberExpr)
    # Note: memberName is not resolved here - it's resolved against the type
    # of memberExpr, which requires type inference

  of xnkIndexExpr:
    a.analyzeReferences(node.indexExpr)
    a.analyzeReferencesChildren(node.indexArgs)

  of xnkIfStmt:
    a.analyzeReferences(node.ifCondition)
    a.analyzeReferences(node.ifBody)
    a.analyzeReferencesOption(node.elseBody)

  of xnkReturnStmt:
    a.analyzeReferencesOption(node.returnExpr)

  of xnkFile:
    for decl in node.moduleDecls:
      a.analyzeReferences(decl)

  # -------------------------------------------------------------------------
  # More Statements
  # -------------------------------------------------------------------------

  of xnkSwitchStmt:
    a.analyzeReferences(node.switchExpr)
    a.analyzeReferencesChildren(node.switchCases)

  of xnkCaseClause:
    a.analyzeReferencesChildren(node.caseValues)
    a.analyzeReferences(node.caseBody)

  of xnkDefaultClause:
    a.analyzeReferences(node.defaultBody)

  of xnkCaseStmt:
    a.analyzeReferencesOption(node.expr)
    a.analyzeReferencesChildren(node.branches)
    a.analyzeReferencesOption(node.caseElseBody)

  of xnkDoWhileStmt:
    a.analyzeReferences(node.whileCondition)
    a.withScope(scopeLoop, node):
      a.analyzeReferences(node.whileBody)

  of xnkFinallyStmt:
    a.analyzeReferences(node.finallyBody)

  of xnkThrowStmt:
    a.analyzeReferences(node.throwExpr)

  of xnkRaiseStmt:
    a.analyzeReferencesOption(node.raiseExpr)

  of xnkAssertStmt:
    a.analyzeReferences(node.assertCond)
    a.analyzeReferencesOption(node.assertMsg)

  of xnkDiscardStmt:
    a.analyzeReferencesOption(node.discardExpr)

  of xnkDeferStmt, xnkStaticStmt:
    a.analyzeReferences(node.staticBody)

  of xnkTypeSwitchStmt:
    a.analyzeReferences(node.typeSwitchExpr)
    a.analyzeReferencesOption(node.typeSwitchVar)
    a.analyzeReferencesChildren(node.typeSwitchCases)

  of xnkTypeCaseClause:
    a.analyzeReferences(node.caseType)
    a.analyzeReferences(node.typeCaseBody)

  of xnkUsingStmt:
    a.analyzeReferences(node.usingExpr)
    a.analyzeReferences(node.usingBody)

  of xnkUnlessStmt:
    a.analyzeReferences(node.unlessCondition)
    a.analyzeReferences(node.unlessBody)

  of xnkUntilStmt:
    a.analyzeReferences(node.untilCondition)
    a.analyzeReferences(node.untilBody)

  of xnkTupleUnpacking:
    # Variables being unpacked into - they're declared here
    for target in node.unpackTargets:
      a.analyzeReferences(target)
    a.analyzeReferences(node.unpackExpr)

  of xnkResourceItem:
    a.analyzeReferences(node.resourceExpr)
    a.analyzeReferencesOption(node.resourceVar)

  of xnkWithItem:
    a.analyzeReferences(node.contextExpr)
    a.analyzeReferencesOption(node.asExpr)

  of xnkIteratorYield:
    a.analyzeReferencesOption(node.iteratorYieldValue)

  of xnkIteratorDelegate:
    a.analyzeReferences(node.iteratorDelegateExpr)

  of xnkYieldStmt:
    a.analyzeReferencesOption(node.yieldStmt)

  of xnkYieldExpr:
    a.analyzeReferencesOption(node.yieldExpr)

  of xnkYieldFromStmt:
    a.analyzeReferences(node.yieldFromExpr)

  of xnkBreakStmt, xnkContinueStmt, xnkPassStmt, xnkEmptyStmt:
    discard  # No children to analyze

  # -------------------------------------------------------------------------
  # More Expressions
  # -------------------------------------------------------------------------

  of xnkSliceExpr:
    a.analyzeReferences(node.sliceExpr)
    a.analyzeReferencesOption(node.sliceStart)
    a.analyzeReferencesOption(node.sliceEnd)
    a.analyzeReferencesOption(node.sliceStep)

  of xnkCastExpr:
    a.analyzeReferences(node.castExpr)
    a.analyzeReferences(node.castType)

  of xnkTypeAssertion:
    a.analyzeReferences(node.assertExpr)
    a.analyzeReferences(node.assertType)

  of xnkThisExpr, xnkBaseExpr:
    discard  # Keywords, no children

  of xnkThisCall, xnkBaseCall:
    a.analyzeReferencesChildren(node.arguments)

  of xnkDotExpr:
    a.analyzeReferences(node.dotBase)
    a.analyzeReferences(node.member)

  of xnkBracketExpr:
    a.analyzeReferences(node.base)
    a.analyzeReferences(node.index)

  of xnkLambdaProc:
    a.withScope(scopeFunction, node):
      a.analyzeReferencesChildren(node.lambdaProcParams)
      a.analyzeReferencesOption(node.lambdaProcReturn)
      a.analyzeReferences(node.lambdaProcBody)

  of xnkArrowFunc:
    a.withScope(scopeFunction, node):
      a.analyzeReferencesChildren(node.arrowParams)
      a.analyzeReferencesOption(node.arrowReturnType)
      a.analyzeReferences(node.arrowBody)

  of xnkArgument:
    a.analyzeReferences(node.argValue)

  of xnkMethodReference:
    a.analyzeReferences(node.refObject)
    # refMethod is a string, not a node

  of xnkCompFor:
    a.analyzeReferencesChildren(node.vars)
    a.analyzeReferences(node.iter)

  of xnkDestructureObj:
    a.analyzeReferences(node.destructObjSource)

  of xnkDestructureArray:
    a.analyzeReferences(node.destructArraySource)

  of xnkConceptRequirement:
    a.analyzeReferencesChildren(node.reqParams)
    a.analyzeReferencesOption(node.reqReturn)

  of xnkStaticAssert:
    a.analyzeReferences(node.staticAssertCondition)
    a.analyzeReferencesOption(node.staticAssertMessage)

  of xnkTypeOfExpr, xnkSizeOfExpr:
    discard  # Would need child access - check xlangtypes

  of xnkDefaultExpr:
    discard  # Typically no children

  # -------------------------------------------------------------------------
  # Collection Literals
  # -------------------------------------------------------------------------

  of xnkSequenceLiteral, xnkSetLiteral, xnkArrayLiteral, xnkTupleExpr:
    a.analyzeReferencesChildren(node.elements)

  of xnkMapLiteral:
    a.analyzeReferencesChildren(node.entries)

  of xnkDictEntry:
    a.analyzeReferences(node.key)
    a.analyzeReferences(node.value)

  of xnkTupleConstr:
    a.analyzeReferencesChildren(node.tupleElements)

  # Legacy collection nodes
  of xnkListExpr, xnkSetExpr:
    a.analyzeReferencesChildren(node.legacyElements)

  of xnkDictExpr:
    a.analyzeReferencesChildren(node.legacyEntries)

  of xnkArrayLit:
    a.analyzeReferencesChildren(node.legacyArrayElements)

  # -------------------------------------------------------------------------
  # Type nodes (recurse into type structure)
  # -------------------------------------------------------------------------

  of xnkNamedType:
    discard  # Just a type name string

  of xnkArrayType:
    a.analyzeReferences(node.elementType)
    a.analyzeReferencesOption(node.arraySize)

  of xnkMapType:
    a.analyzeReferences(node.keyType)
    a.analyzeReferences(node.valueType)

  of xnkFuncType:
    a.analyzeReferencesChildren(node.funcParams)
    a.analyzeReferencesOption(node.funcReturnType)

  of xnkPointerType, xnkReferenceType:
    a.analyzeReferences(node.referentType)

  of xnkGenericType:
    a.analyzeReferencesOption(node.genericBase)
    a.analyzeReferencesChildren(node.genericArgs)

  of xnkUnionType:
    a.analyzeReferencesChildren(node.unionTypes)

  of xnkIntersectionType:
    a.analyzeReferencesChildren(node.typeMembers)

  of xnkDistinctType:
    a.analyzeReferences(node.distinctBaseType)

  # -------------------------------------------------------------------------
  # Imports/Exports (no symbol resolution needed here)
  # -------------------------------------------------------------------------

  of xnkImport:
    discard  # Import path is a string

  of xnkExport:
    a.analyzeReferences(node.exportedDecl)

  of xnkImportStmt, xnkExportStmt, xnkFromImportStmt:
    discard  # String-based

  of xnkAttribute, xnkDecorator:
    a.analyzeReferences(node.decoratorExpr)

  of xnkPragma:
    a.analyzeReferencesChildren(node.pragmas)

  # -------------------------------------------------------------------------
  # Literals and terminals (no action needed)
  # -------------------------------------------------------------------------

  of xnkIntLit, xnkFloatLit, xnkStringLit, xnkCharLit,
     xnkBoolLit, xnkNoneLit, xnkNilLit, xnkComment,
     xnkNumberLit, xnkSymbolLit:
    discard

  # -------------------------------------------------------------------------
  # External nodes (should be lowered before semantic analysis, but handle anyway)
  # -------------------------------------------------------------------------

  of xnkExternal_Ternary, xnkExternal_DoWhile, xnkExternal_ForStmt,
     xnkExternal_Interface, xnkExternal_Generator, xnkExternal_Comprehension,
     xnkExternal_With, xnkExternal_Destructure, xnkExternal_Await,
     xnkExternal_LocalFunction, xnkExternal_ExtensionMethod,
     xnkExternal_FallthroughCase, xnkExternal_Unless, xnkExternal_Until,
     xnkExternal_Pass, xnkExternal_Channel, xnkExternal_Goroutine,
     xnkExternal_GoDefer, xnkExternal_GoSelect, xnkExternal_Property,
     xnkExternal_Indexer, xnkExternal_Event, xnkExternal_Delegate,
     xnkExternal_Operator, xnkExternal_ConversionOp, xnkExternal_Resource,
     xnkExternal_Fixed, xnkExternal_Lock, xnkExternal_Unsafe,
     xnkExternal_Checked, xnkExternal_SafeNavigation, xnkExternal_NullCoalesce,
     xnkExternal_ThrowExpr, xnkExternal_SwitchExpr, xnkExternal_StackAlloc,
     xnkExternal_StringInterp:
    # These should be lowered before semantic analysis
    # For now, skip them - transforms will handle them
    discard

  # -------------------------------------------------------------------------
  # Catch-all for remaining nodes
  # -------------------------------------------------------------------------

  else:
    # Nodes we haven't explicitly handled yet
    # Log for debugging if needed
    discard

# =============================================================================
# Keyword Conflict Detection
# =============================================================================

proc sanitizeAndCheckKeywords*(info: SemanticInfo) =
  ## Sanitize identifiers and mark conflicts with target language keywords.
  ## Handles:
  ## - @ prefix removal (C# keyword escaping)
  ## - Trailing _ removal (C# convention, invalid in Nim)
  ## - Keyword conflicts
  for sym in info.allSymbols:
    var sanitized = sym.name

    # Remove @ prefix (C# keyword escaping)
    if sanitized.len > 0 and sanitized[0] == '@':
      sanitized = sanitized[1..^1]

    # Remove trailing underscores
    while sanitized.len > 0 and sanitized[^1] == '_':
      sanitized = sanitized[0..^2]

    # Check if sanitized name is a keyword or if name changed
    if sanitized != sym.name:
      # Name was sanitized, now check if result is a keyword
      if sanitized in info.targetKeywords:
        # Result is a keyword, append "Var"
        sym.mangledName = sanitized & "Var"
      else:
        # Just use the sanitized name
        sym.mangledName = sanitized
      info.renames[sym] = sym.mangledName
    elif sym.name in info.targetKeywords:
      # Original name is already a keyword (without @)
      sym.mangledName = "x" & sym.name
      info.renames[sym] = sym.mangledName

proc markKeywordConflicts*(info: SemanticInfo) =
  ## Mark symbols that conflict with target language keywords.
  ## DEPRECATED: Use sanitizeAndCheckKeywords instead
  sanitizeAndCheckKeywords(info)

# =============================================================================
# Public API
# =============================================================================

proc analyzeProgram*(root: XLangNode, targetKeywords: seq[string] = @[]): SemanticInfo =
  ## Run semantic analysis on an XLang AST.
  ## Returns SemanticInfo with symbol tables and resolution info.
  result = SemanticInfo(
    nodeToSymbol: initTable[XLangNode, Symbol](),
    declToSymbol: initTable[XLangNode, Symbol](),
    nodeToScope: initTable[XLangNode, Scope](),
    allSymbols: @[],
    allScopes: @[],
    symbolById: initTable[Uuid, Symbol](),
    scopeById: initTable[Uuid, Scope](),
    renames: initTable[Symbol, string](),
    targetKeywords: targetKeywords.toHashSet,
    errors: @[],
    warnings: @[]
  )

  let analyzer = Analyzer(
    info: result,
    globalScope: newScope(nil, scopeModule, root),
    currentScope: nil
  )
  analyzer.currentScope = analyzer.globalScope
  result.nodeToScope[root] = analyzer.globalScope
  result.allScopes.add(analyzer.globalScope)
  result.scopeById[analyzer.globalScope.id] = analyzer.globalScope  # Register global scope by UUID

  # Two-pass analysis to handle forward references
  # Pass 1: Collect all declarations without analyzing bodies
  analyzer.collectDeclarations(root)

  # Pass 2: Analyze bodies and resolve identifier references
  # Reset to global scope for pass 2
  analyzer.currentScope = analyzer.globalScope
  analyzer.analyzeReferences(root)

  # Post-processing
  result.markKeywordConflicts()

# =============================================================================
# Query Helpers (for transforms and emitter)
# =============================================================================

proc getSymbol*(info: SemanticInfo, node: XLangNode): Option[Symbol] =
  ## Get the symbol that an identifier node refers to.
  if node in info.nodeToSymbol:
    return some(info.nodeToSymbol[node])
  return none(Symbol)

proc getDeclSymbol*(info: SemanticInfo, node: XLangNode): Option[Symbol] =
  ## Get the symbol declared by a declaration node.
  if node in info.declToSymbol:
    return some(info.declToSymbol[node])
  return none(Symbol)

proc getScope*(info: SemanticInfo, node: XLangNode): Option[Scope] =
  ## Get the scope created by a scope-creating node.
  if node in info.nodeToScope:
    return some(info.nodeToScope[node])
  return none(Scope)

proc getEffectiveName*(info: SemanticInfo, sym: Symbol): string =
  ## Get the name to use in output (mangled if renamed, original otherwise).
  if sym.mangledName != "":
    return sym.mangledName
  return sym.name

proc getEffectiveName*(info: SemanticInfo, node: XLangNode): Option[string] =
  ## Get the effective name for an identifier node.
  let sym = info.getSymbol(node)
  if sym.isSome:
    return some(info.getEffectiveName(sym.get))
  return none(string)

proc getCapturedSymbols*(info: SemanticInfo, funcNode: XLangNode): seq[Symbol] =
  ## Get all symbols captured by a function (for closure transformation).
  result = @[]
  for sym in info.allSymbols:
    if funcNode in sym.capturedBy:
      result.add(sym)

proc isCaptured*(info: SemanticInfo, node: XLangNode): bool =
  ## Check if an identifier refers to a captured variable.
  let sym = info.getSymbol(node)
  if sym.isSome:
    return sym.get.isCaptured
  return false

proc getPropertyRename*(info: SemanticInfo, propertyName: string): Option[string] =
  ## DEPRECATED: Use getPropertyRenameBySymbol instead for UUID-based lookup.
  ## Check if a member name corresponds to a renamed property.
  ## Returns the getter name if the property was renamed (e.g., "WaveFormat" → "getWaveFormat")
  ## Performs case-insensitive matching since member names may be converted to camelCase
  ## WARNING: This name-based lookup can fail after renames - use UUID-based lookup when possible
  for sym in info.allSymbols:
    if sym.kind == skProperty and sym.name.toLowerAscii() == propertyName.toLowerAscii():
      if sym in info.renames:
        return some(info.renames[sym])
  return none(string)

proc getPropertyRenameBySymbol*(info: SemanticInfo, sym: Symbol): Option[string] =
  ## Check if a symbol corresponds to a renamed property.
  ## Returns the getter name if the property was renamed (e.g., "WaveFormat" → "getWaveFormat")
  ## Uses UUID-based lookup, so it works correctly even after the symbol has been renamed.
  if sym.kind == skProperty and sym in info.renames:
    return some(info.renames[sym])
  return none(string)

proc getPropertyRenameByNode*(info: SemanticInfo, node: XLangNode): Option[string] =
  ## Check if a node corresponds to a renamed property by looking up its symbol.
  ## Returns the getter name if the property was renamed.
  ## Uses UUID-based symbol lookup, so it works correctly even after renames.
  if node in info.nodeToSymbol:
    let sym = info.nodeToSymbol[node]
    return getPropertyRenameBySymbol(info, sym)
  return none(string)

# =============================================================================
# Nim Naming Conventions
# =============================================================================

proc toSnakeCase(name: string): string =
  ## Convert PascalCase/camelCase to snake_case.
  for i, c in name:
    if c.isUpperAscii:
      if i > 0 and result.len > 0 and result[^1] != '_':
        # Don't add underscore if previous char was also uppercase (acronym)
        # unless next char is lowercase
        let prevUpper = i > 0 and name[i-1].isUpperAscii
        let nextLower = i + 1 < name.len and name[i+1].isLowerAscii
        if not prevUpper or nextLower:
          result.add('_')
      result.add(c.toLowerAscii)
    else:
      result.add(c)

proc toNimFileName*(sourceName: string): string =
  ## Convert a source file name to idiomatic Nim file name.
  ## Examples:
  ##   "MyClass.cs" -> "my_class.nim"
  ##   "HTTPClient.java" -> "http_client.nim"
  ##   "UserService.py" -> "user_service.nim"
  # Remove extension
  var baseName = sourceName
  let dotPos = baseName.rfind('.')
  if dotPos >= 0:
    baseName = baseName[0..<dotPos]

  return toSnakeCase(baseName) & ".nim"

proc toNimModuleName*(sourceName: string): string =
  ## Convert a source file/class name to idiomatic Nim module name (for imports).
  ## Examples:
  ##   "MyClass" -> "my_class"
  ##   "HTTPClient" -> "http_client"
  ##   "System.Collections.Generic" -> "system/collections/generic"
  # Handle dotted names (namespaces)
  if '.' in sourceName:
    var parts: seq[string] = @[]
    for part in sourceName.split('.'):
      parts.add(toNimModuleName(part))
    return parts.join("/")

  return toSnakeCase(sourceName)

proc toNimImportPath*(namespace: string, typeName: string): string =
  ## Convert a namespace and type to Nim import path.
  ## Examples:
  ##   ("System.Collections", "List") -> "system/collections/list"
  ##   ("", "MyClass") -> "my_class"
  if namespace.len > 0:
    return toNimModuleName(namespace) & "/" & toNimModuleName(typeName)
  else:
    return toNimModuleName(typeName)
