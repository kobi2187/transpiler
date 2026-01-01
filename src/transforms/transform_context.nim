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

import core/xlangtypes
import semantic/semantic_analysis
import error_collector
import uuid4
import std/tables
import std/options
import std/sets
import core/apply_to_kids

type
  TransformContext* = ref object
    ## Central context for all AST passes - transforms AND conversion
    ## Provides access to semantic info, scope tracking, and all services

    # Core semantic data
    semanticInfo*: SemanticInfo        ## Symbol tables, scopes, resolved references

    # Services
    errorCollector*: ErrorCollector    ## For reporting errors/warnings during transforms

    # Configuration
    targetLang*: string                ## Target output language ("nim", "go", etc.)
    sourceLang*: string                ## Source language from input file
    verbose*: bool                     ## Verbose output flag

    # Current file being processed
    currentFile*: string               ## Path to current input file

    # Transform state
    transformCount*: int               ## How many times transforms have been applied
    nodeById*: Table[Uuid, XLangNode]  ## Quick lookup of nodes by UUID (built on demand)

    # Conversion scope tracking (for code generation phase)
    currentClass*: Option[XLangNode]      ## Current class/interface being converted
    currentFunction*: Option[XLangNode]   ## Current function/method being converted
    currentNamespace*: Option[XLangNode]  ## Current namespace being converted
    currentModule*: Option[XLangNode]     ## Current file/module being converted
    inConstructor*: bool                  ## True if inside a constructor body
    nodeStack*: seq[XLangNode]            ## Stack for error reporting (shows hierarchy)

    # Symbol tables for conversion (XLangNode references)
    types*: Table[string, XLangNode]      ## Type declarations
    variables*: Table[string, XLangNode]  ## Variable declarations
    functions*: Table[string, XLangNode]  ## Function declarations

    # Import tracking
    requiredImports*: HashSet[string]     ## Nim modules to import (tables, options, etc.)

    # Multi-class file handling
    classCount*: int                      ## Number of classes in file (for static method prefixing)

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
    transformCount: 0,
    nodeById: initTable[Uuid, XLangNode](),
    # Initialize conversion state fields
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
  if ctx.nodeById.hasKey(id):
    return ctx.nodeById[id]
  return nil

proc getParentNode*(ctx: TransformContext, node: XLangNode): XLangNode =
  ## Get the parent node using the parentId field
  ## Returns nil if no parent (root node)
  if node.parentId.isNone:
    return nil
  return ctx.getNodeById(node.parentId.get())

proc findContainingClass*(ctx: TransformContext, node: XLangNode): XLangNode =
  ## Walk up the parent chain to find the containing class declaration
  ## Returns nil if not inside a class
  var current = node
  while current != nil:
    if current.kind == xnkClassDecl:
      return current
    current = ctx.getParentNode(current)
  return nil

proc addFieldToClass*(ctx: TransformContext, classNode: XLangNode, field: XLangNode) =
  ## Add a field to a class's field/member list
  ## This mutates the class node to include the new field
  if classNode.kind in {xnkClassDecl, xnkStructDecl, xnkInterfaceDecl}:
    classNode.members.add(field)
    # Also register the new field in nodeById if it has an ID
    if field.id.isSome:
      ctx.nodeById[field.id.get()] = field
    ctx.log("Added field '" & field.fieldName & "' to type '" & classNode.typeNameDecl & "'")

proc buildNodeIndex*(ctx: TransformContext, root: var XLangNode) =
  ## Build the nodeById index by traversing the entire AST
  ## Assigns UUIDs to all nodes, sets parent IDs, and builds the lookup table
  ctx.nodeById.clear()

  proc assignIdsAndParents(node: var XLangNode, parentId: Option[Uuid]) =
    # Assign a new UUID if not set
    if node.id.isNone:
      node.id = some(uuid4())

    # Set parent ID
    node.parentId = parentId

    # Add to lookup table
    ctx.nodeById[node.id.get()] = node

    # Recursively process children with this node as parent
    let currentId = node.id
    let nodeId = node.id.get()  # Capture the ID value, not the node itself
    case node.kind
    of xnkFile:
      for child in node.moduleDecls.mitems:
        assignIdsAndParents(child, currentId)
    of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
      for member in node.members.mitems:
        assignIdsAndParents(member, currentId)
    else:
      # For all other node types, use the visitor pattern
      visit(node, proc(child: var XLangNode) =
        if child.id.isSome and child.id.get() != nodeId:  # Don't re-process the current node
          assignIdsAndParents(child, currentId)
      )

  assignIdsAndParents(root, none(Uuid))
  ctx.log("Built node index with " & $ctx.nodeById.len & " nodes")

# Future additions:
# - Type inference helpers
# - Constant folding
# - Data flow analysis
# - Control flow graph access
# - etc.
