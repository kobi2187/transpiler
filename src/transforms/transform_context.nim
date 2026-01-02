## Transform Context
##
## Provides all services and data that transform passes need.
## This is passed to every transform, giving them flexible access to:
## - Semantic information (symbols, scopes, types)
## - Error reporting
## - Configuration (target language, flags)
## - Helper utilities
##
## Design: Instead of passing many parameters, we pass one context with everything.
## Uses composition: ctx.transform.* for transform-phase state, ctx.conversion.* for conversion-phase state.

import core/xlangtypes
import semantic/semantic_analysis
import error_collector
import uuid4
import std/tables
import std/options
import std/sets
import core/apply_to_kids

type
  # =============================================================================
  # Phase-Specific State Objects
  # =============================================================================
  
  PendingField* = object
    ## A field to be added to a class after iteration completes
    classId*: Uuid        ## UUID of the class to add to
    field*: XLangNode     ## The field to add
    source*: string       ## Transform that requested it

  TransformState* = object
    ## State used during the transform/lowering phase
    ## Access via ctx.transform.*
    nodeById*: Table[Uuid, XLangNode]  ## Quick lookup of nodes by UUID
    transformCount*: int               ## How many times transforms have been applied
    log*: seq[string]                  ## Audit log of transform actions
    pendingFields*: seq[PendingField]  ## Fields to add after iteration

  ConversionState* = object
    ## State used during the conversion/code-gen phase
    ## Access via ctx.conversion.*
    currentClass*: Option[XLangNode]      ## Current class/interface being converted
    currentFunction*: Option[XLangNode]   ## Current function/method being converted
    currentNamespace*: Option[XLangNode]  ## Current namespace being converted
    currentModule*: Option[XLangNode]     ## Current file/module being converted
    inConstructor*: bool                  ## True if inside a constructor body
    nodeStack*: seq[XLangNode]            ## Stack for error reporting (shows hierarchy)
    types*: Table[string, XLangNode]      ## Type declarations
    variables*: Table[string, XLangNode]  ## Variable declarations
    functions*: Table[string, XLangNode]  ## Function declarations
    requiredImports*: HashSet[string]     ## Nim modules to import (tables, options, etc.)
    classCount*: int                      ## Number of classes in file (for static method prefixing)

  # =============================================================================
  # Main Context Type
  # =============================================================================

  TransformContext* = ref object
    ## Central context for all AST passes - transforms AND conversion
    ## Provides access to semantic info, scope tracking, and all services

    # Shared - both phases need these
    semanticInfo*: SemanticInfo        ## Symbol tables, scopes, resolved references
    errorCollector*: ErrorCollector    ## For reporting errors/warnings
    targetLang*: string                ## Target output language ("nim", "go", etc.)
    sourceLang*: string                ## Source language from input file
    currentFile*: string               ## Path to current input file
    verbose*: bool                     ## Verbose output flag

    # Phase-specific state (one dot away, still direct access)
    transform*: TransformState         ## Transform-phase state
    conversion*: ConversionState       ## Conversion-phase state

# =============================================================================
# Initialization Helpers
# =============================================================================

proc initTransformState(): TransformState =
  ## Initialize transform-phase state
  TransformState(
    nodeById: initTable[Uuid, XLangNode](),
    transformCount: 0,
    log: @[],
    pendingFields: @[]
  )

proc initConversionState(): ConversionState =
  ## Initialize conversion-phase state
  ConversionState(
    currentClass: none(XLangNode),
    currentFunction: none(XLangNode),
    currentNamespace: none(XLangNode),
    currentModule: none(XLangNode),
    inConstructor: false,
    nodeStack: @[],
    types: initTable[string, XLangNode](),
    variables: initTable[string, XLangNode](),
    functions: initTable[string, XLangNode](),
    requiredImports: initHashSet[string](),
    classCount: 0
  )

proc newTransformContext*(semanticInfo: SemanticInfo,
                         errorCollector: ErrorCollector,
                         targetLang: string = "nim",
                         sourceLang: string = "",
                         currentFile: string = "",
                         verbose: bool = false): TransformContext =
  ## Create a new transform context with all services
  TransformContext(
    semanticInfo: semanticInfo,
    errorCollector: errorCollector,
    targetLang: targetLang,
    sourceLang: sourceLang,
    currentFile: currentFile,
    verbose: verbose,
    transform: initTransformState(),
    conversion: initConversionState()
  )

# =============================================================================
# Convenience Accessors - Direct access to common operations
# =============================================================================

proc getSymbol*(ctx: TransformContext, node: XLangNode): Symbol =
  ## Get the symbol for a node (if resolved during semantic analysis)
  if ctx.semanticInfo.nodeToSymbol.hasKey(node):
    return ctx.semanticInfo.nodeToSymbol[node]
  return nil

proc getDeclSymbol*(ctx: TransformContext, node: XLangNode): Option[Symbol] =
  ## Get the symbol for a declaration node (wraps SemanticInfo.getDeclSymbol)
  ctx.semanticInfo.getDeclSymbol(node)

proc getSymbolById*(ctx: TransformContext, id: Uuid): Symbol =
  ## Get a symbol by its UUID (stable across renames)
  if ctx.semanticInfo.symbolById.hasKey(id):
    return ctx.semanticInfo.symbolById[id]
  return nil

proc getScope*(ctx: TransformContext, node: XLangNode): Scope =
  ## Get the scope for a node
  if ctx.semanticInfo.nodeToScope.hasKey(node):
    return ctx.semanticInfo.nodeToScope[node]
  return nil

proc getScopeById*(ctx: TransformContext, id: Uuid): Scope =
  ## Get a scope by its UUID
  if ctx.semanticInfo.scopeById.hasKey(id):
    return ctx.semanticInfo.scopeById[id]
  return nil

proc getRename*(ctx: TransformContext, sym: Symbol): string =
  ## Get the renamed identifier for a symbol (if renamed)
  if ctx.semanticInfo.renames.hasKey(sym):
    return ctx.semanticInfo.renames[sym]
  return sym.name

proc addError*(ctx: TransformContext, kind: TranspilerErrorKind,
               message: string, location: string = "", details: string = "") =
  ## Report an error during transformation
  ctx.errorCollector.addError(kind, message, location, details)

proc addWarning*(ctx: TransformContext, kind: TranspilerErrorKind,
                message: string, location: string = "", details: string = "") =
  ## Report a warning during transformation
  ctx.errorCollector.addWarning(kind, message, location, details)

proc log*(ctx: TransformContext, message: string) =
  ## Log a debug message (only if verbose mode)
  if ctx.verbose:
    echo "  [Transform] ", message

proc logAction*(ctx: TransformContext, source: string, action: string) =
  ## Record a transform action in the audit log
  ## source: name of the transform or component performing the action
  ## action: description of what was done
  ctx.transform.log.add("[" & source & "] " & action)

proc getTransformLog*(ctx: TransformContext): seq[string] =
  ## Get the accumulated transform log
  ctx.transform.log

proc clearTransformLog*(ctx: TransformContext) =
  ## Clear the transform log
  ctx.transform.log.setLen(0)

proc formatTransformLog*(ctx: TransformContext): string =
  ## Format the transform log as a human-readable string
  if ctx.transform.log.len == 0:
    return ""
  result = "=== Transform Log (" & $ctx.transform.log.len & " entries) ===\n"
  for entry in ctx.transform.log:
    result.add(entry & "\n")

proc renameSymbol*(ctx: TransformContext, source: string, sym: Symbol, newName: string) =
  ## Rename a symbol and log the action
  ## source: name of the transform performing this action
  let oldName = sym.name
  ctx.semanticInfo.renames[sym] = newName
  ctx.logAction(source, "renamed '" & oldName & "' -> '" & newName & "'")

# =============================================================================
# Symbol Queries - Easy access to semantic info
# =============================================================================

proc isProperty*(ctx: TransformContext, sym: Symbol): bool =
  ## Check if a symbol is a property
  sym.kind == skProperty

proc isRenamed*(ctx: TransformContext, sym: Symbol): bool =
  ## Check if a symbol has been renamed
  ctx.semanticInfo.renames.hasKey(sym)

proc findSymbolByName*(ctx: TransformContext, scope: Scope, name: string): Symbol =
  ## Find a symbol by name in a scope (searches up the scope chain)
  let opt = scope.lookup(name)
  if opt.isSome:
    return opt.get()
  return nil

proc getAllSymbolsOfKind*(ctx: TransformContext, kind: SymbolKind): seq[Symbol] =
  ## Get all symbols of a specific kind
  result = @[]
  for sym in ctx.semanticInfo.allSymbols:
    if sym.kind == kind:
      result.add(sym)

# =============================================================================
# Node Utilities - Helper functions for AST manipulation
# =============================================================================

proc cloneNode*(ctx: TransformContext, node: XLangNode): XLangNode =
  ## Clone a node (shallow copy - for future deep clone if needed)
  ## For now, just returns the node (XLangNode is a ref type)
  ## Future: implement deep copy if transforms need to duplicate subtrees
  node

# =============================================================================
# AST Traversal - Finding parent nodes and containing scopes via UUID
# =============================================================================

proc getNodeById*(ctx: TransformContext, id: Uuid): XLangNode =
  ## Get a node by its UUID from the cache
  ## Returns nil if not found
  if ctx.transform.nodeById.hasKey(id):
    return ctx.transform.nodeById[id]
  return nil

proc getParentNode*(ctx: TransformContext, node: XLangNode): XLangNode =
  ## Get the parent node using the parentId field
  ## Returns nil if no parent (root node)
  if node.parentId.isNone:
    return nil
  return ctx.getNodeById(node.parentId.get())

# =============================================================================
# Class/Struct Detection Helpers
# =============================================================================

proc isClassOrStruct(node: XLangNode): bool =
  ## Check if node is a class or struct declaration
  node.kind in {xnkClassDecl, xnkStructDecl}

proc exceedsMaxDepth(depth: int): bool =
  ## Check if we've exceeded safe traversal depth
  const maxDepth = 100
  depth > maxDepth

proc warnExcessiveDepth() =
  ## Warn about potential infinite loop
  echo "WARNING: findContainingClass exceeded max depth, breaking to avoid infinite loop"

proc findContainingClass*(ctx: TransformContext, node: XLangNode): XLangNode =
  ## Walk up the parent chain to find the containing class/struct declaration
  ## Returns nil if not inside a class or struct
  var current = node
  var depth = 0
  while current != nil:
    if isClassOrStruct(current):
      return current
    current = ctx.getParentNode(current)
    depth.inc()
    if exceedsMaxDepth(depth):
      warnExcessiveDepth()
      break
  return nil

# =============================================================================
# Field Addition Helpers
# =============================================================================

proc canAddField(node: XLangNode): bool =
  ## Check if node can have fields added to it
  node.kind in {xnkClassDecl, xnkStructDecl, xnkInterfaceDecl}

proc linkFieldToParent(field: XLangNode, classNode: XLangNode) =
  ## Set parent ID on field
  field.parentId = classNode.id

proc registerFieldInIndex(ctx: TransformContext, field: XLangNode) =
  ## Add field to node index if it has an ID
  if field.id.isSome:
    ctx.transform.nodeById[field.id.get()] = field

proc queueFieldForClass*(ctx: TransformContext, source: string, classNode: XLangNode, field: XLangNode) =
  ## Queue a field to be added to a class after iteration completes
  ## source: name of the transform performing this action (for logging)
  ## This avoids modifying the members seq during iteration
  if not canAddField(classNode):
    return
  if classNode.id.isNone:
    ctx.logAction(source, "ERROR: class has no id, cannot queue field '" & field.fieldName & "'")
    return
  ctx.transform.pendingFields.add(PendingField(
    classId: classNode.id.get(),
    field: field,
    source: source
  ))
  ctx.logAction(source, "queued field '" & field.fieldName & "' for " & classNode.typeNameDecl)

proc flushPendingFields*(ctx: TransformContext) =
  ## Add all pending fields to their classes
  ## Call this after each iteration of the fixed-point transformer
  for pending in ctx.transform.pendingFields:
    let classNode = ctx.getNodeById(pending.classId)
    if classNode.isNil:
      ctx.logAction(pending.source, "ERROR: class not found for pending field")
      continue
    classNode.members.add(pending.field)
    linkFieldToParent(pending.field, classNode)
    registerFieldInIndex(ctx, pending.field)
    ctx.logAction(pending.source, "added field '" & pending.field.fieldName & "' to " & classNode.typeNameDecl)
  ctx.transform.pendingFields.setLen(0)

# =============================================================================
# Node Index Building Helpers
# =============================================================================

proc ensureNodeHasId(node: var XLangNode) =
  ## Assign a UUID if node doesn't have one
  if node.id.isNone:
    node.id = some(uuid4())

proc setParentId(node: var XLangNode, parentId: Option[Uuid]) =
  ## Set the parent ID on a node
  node.parentId = parentId

proc addToNodeIndex(ctx: TransformContext, node: XLangNode) =
  ## Add node to the lookup table
  ctx.transform.nodeById[node.id.get()] = node

proc assignIdsAndParents(node: var XLangNode, parentId: Option[Uuid], ctx: TransformContext) =
  ## Recursively assign IDs and parent links to all nodes
  ensureNodeHasId(node)
  setParentId(node, parentId)
  addToNodeIndex(ctx, node)
  
  let currentId = node.id
  let nodeId = node.id.get()
  
  case node.kind
  of xnkFile:
    for child in node.moduleDecls.mitems:
      assignIdsAndParents(child, currentId, ctx)
  of xnkNamespace:
    for child in node.namespaceBody.mitems:
      assignIdsAndParents(child, currentId, ctx)
  of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
    for member in node.members.mitems:
      assignIdsAndParents(member, currentId, ctx)
  else:
    visit(node, proc(child: var XLangNode) =
      if child.id.isSome and child.id.get() != nodeId:
        assignIdsAndParents(child, currentId, ctx)
    )

proc clearNodeIndex(ctx: TransformContext) =
  ## Clear the node index
  ctx.transform.nodeById.clear()

proc logNodeIndexSize(ctx: TransformContext) =
  ## Log the size of the node index
  ctx.log("Built node index with " & $ctx.transform.nodeById.len & " nodes")

proc buildNodeIndex*(ctx: TransformContext, root: var XLangNode) =
  ## Build the nodeById index by traversing the entire AST
  ## Assigns UUIDs to all nodes, sets parent IDs, and builds the lookup table
  clearNodeIndex(ctx)
  assignIdsAndParents(root, none(Uuid), ctx)
  logNodeIndexSize(ctx)

# Future additions:
# - Type inference helpers
# - Constant folding
# - Data flow analysis
# - Control flow graph access
# - etc.
