## Nim Identifier Sanitization Pass
##
## Sanitizes XLang identifiers to be valid Nim identifiers.
## Currently handles: removing trailing underscores (C# convention, invalid in Nim)
##
## Two-phase approach to handle collisions:
## 1. Collect all identifiers in the tree
## 2. Sanitize identifiers, checking for collisions and appending numbers if needed
##
## Example: If we have both "test" and "test_", sanitizing "test_" would collide,
## so we rename it to "test2" (or "test3" if "test2" exists, etc.)

import core/xlangtypes
import backends/nim/naming_conventions
import core/helpers
import options, sets, tables

type
  SanitizationContext = object
    ## Tracks identifiers during sanitization
    existingIdentifiers: HashSet[string]  # All identifiers found in original tree
    usedIdentifiers: HashSet[string]      # Identifiers used after sanitization
    renameMap: Table[string, string]      # Original -> Sanitized mapping

proc collectIdentifier(ctx: var SanitizationContext, ident: string) =
  ## Collect an identifier from the original tree
  if ident.len > 0:
    ctx.existingIdentifiers.incl(ident)

proc collectIdentifiersFromNode(node: XLangNode, ctx: var SanitizationContext) =
  ## Collect all identifiers from a single node
  if node.isNil:
    return

  case node.kind
  # Type declarations
  of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
    collectIdentifier(ctx, node.typeNameDecl)
  of xnkEnumDecl:
    collectIdentifier(ctx, node.enumName)
  of xnkEnumMember:
    collectIdentifier(ctx, node.enumMemberName)
  of xnkTypeDecl:
    collectIdentifier(ctx, node.typeDefName)
  of xnkDistinctTypeDef:
    collectIdentifier(ctx, node.distinctName)
  of xnkConceptDecl:
    collectIdentifier(ctx, node.conceptDeclName)
  of xnkConceptDef:
    collectIdentifier(ctx, node.conceptName)

  # Function/method declarations
  of xnkFuncDecl:
    collectIdentifier(ctx, node.funcName)
  of xnkMethodDecl:
    collectIdentifier(ctx, node.methodName)
  of xnkIteratorDecl:
    collectIdentifier(ctx, node.iteratorName)
  of xnkTemplateDecl:
    collectIdentifier(ctx, node.templateName)
  of xnkMacroDecl:
    collectIdentifier(ctx, node.macroName)

  # Variable/field declarations
  of xnkFieldDecl:
    collectIdentifier(ctx, node.fieldName)
  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    collectIdentifier(ctx, node.declName)
  of xnkParameter:
    collectIdentifier(ctx, node.paramName)

  # Identifiers and references
  of xnkIdentifier:
    collectIdentifier(ctx, node.identName)
  of xnkMemberAccessExpr:
    collectIdentifier(ctx, node.memberName)

  # C#-specific external nodes
  of xnkExternal_Property:
    collectIdentifier(ctx, node.extPropName)
  of xnkExternal_Event:
    collectIdentifier(ctx, node.extEventName)
  of xnkExternal_Delegate:
    collectIdentifier(ctx, node.extDelegateName)
  of xnkExternal_LocalFunction:
    collectIdentifier(ctx, node.extLocalFuncName)

  # Other declarations
  of xnkAbstractDecl:
    collectIdentifier(ctx, node.abstractName)
  of xnkLabeledStmt:
    collectIdentifier(ctx, node.labelName)
  of xnkGotoStmt:
    collectIdentifier(ctx, node.gotoLabel)
  of xnkGenericParameter:
    collectIdentifier(ctx, node.genericParamName)
  of xnkLibDecl:
    collectIdentifier(ctx, node.libName)
  of xnkCFuncDecl:
    collectIdentifier(ctx, node.cfuncName)
  of xnkExternalVar:
    collectIdentifier(ctx, node.extVarName)

  # Optional string fields
  of xnkCatchStmt:
    if node.catchVar.isSome:
      collectIdentifier(ctx, node.catchVar.get)
  of xnkArgument:
    if node.argName.isSome:
      collectIdentifier(ctx, node.argName.get)
  of xnkImport:
    if node.importAlias.isSome:
      collectIdentifier(ctx, node.importAlias.get)

  else:
    discard

proc getSanitizedIdentifier(ctx: var SanitizationContext, original: string, convertCase: bool = false, skipCollisionCheck: bool = false): string =
  ## Get sanitized version of an identifier, handling collisions
  ## If convertCase is true, also converts PascalCase to camelCase (for methods/members)
  ## If skipCollisionCheck is true, doesn't check for collisions (for member accesses which are always qualified)
  if original.len == 0:
    return original

  # Check if we already computed the sanitized version
  if original in ctx.renameMap:
    return ctx.renameMap[original]

  # Apply sanitization (remove trailing underscores)
  var sanitized = sanitizeNimIdentifier(original)

  # Optionally convert PascalCase to camelCase
  if convertCase:
    sanitized = memberNameToNim(sanitized)

  # If it didn't change, no need to check collisions
  if sanitized == original:
    ctx.renameMap[original] = original
    ctx.usedIdentifiers.incl(original)
    return original

  # For member accesses, skip collision checking since they're always qualified (obj.member)
  if skipCollisionCheck:
    ctx.renameMap[original] = sanitized
    ctx.usedIdentifiers.incl(sanitized)
    return sanitized

  # Check for collision with existing identifiers or already-used sanitized names
  var candidate = sanitized
  var counter = 2

  while candidate in ctx.existingIdentifiers or candidate in ctx.usedIdentifiers:
    # Collision detected, try appending a number
    candidate = sanitized & $counter
    counter.inc()

  # Found a non-colliding name
  ctx.renameMap[original] = candidate
  ctx.usedIdentifiers.incl(candidate)
  return candidate

proc sanitizeNodeIdentifiers(node: var XLangNode, ctx: var SanitizationContext) =
  ## Sanitize identifiers in a single node (Phase 2)
  if node.isNil:
    return

  case node.kind
  # Type declarations
  of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
    node.typeNameDecl = getSanitizedIdentifier(ctx, node.typeNameDecl)
  of xnkEnumDecl:
    node.enumName = getSanitizedIdentifier(ctx, node.enumName)
  of xnkEnumMember:
    node.enumMemberName = getSanitizedIdentifier(ctx, node.enumMemberName)
  of xnkTypeDecl:
    node.typeDefName = getSanitizedIdentifier(ctx, node.typeDefName)
  of xnkDistinctTypeDef:
    node.distinctName = getSanitizedIdentifier(ctx, node.distinctName)
  of xnkConceptDecl:
    node.conceptDeclName = getSanitizedIdentifier(ctx, node.conceptDeclName)
  of xnkConceptDef:
    node.conceptName = getSanitizedIdentifier(ctx, node.conceptName)

  # Function/method declarations - convert to camelCase
  of xnkFuncDecl:
    node.funcName = getSanitizedIdentifier(ctx, node.funcName, convertCase = true)
  of xnkMethodDecl:
    node.methodName = getSanitizedIdentifier(ctx, node.methodName, convertCase = true)
  of xnkIteratorDecl:
    node.iteratorName = getSanitizedIdentifier(ctx, node.iteratorName, convertCase = true)
  of xnkTemplateDecl:
    node.templateName = getSanitizedIdentifier(ctx, node.templateName, convertCase = true)
  of xnkMacroDecl:
    node.macroName = getSanitizedIdentifier(ctx, node.macroName, convertCase = true)

  # Variable/field declarations - convert to camelCase
  of xnkFieldDecl:
    node.fieldName = getSanitizedIdentifier(ctx, node.fieldName, convertCase = true)
  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    node.declName = getSanitizedIdentifier(ctx, node.declName)
  of xnkParameter:
    node.paramName = getSanitizedIdentifier(ctx, node.paramName)

  # Identifiers and references
  of xnkIdentifier:
    node.identName = getSanitizedIdentifier(ctx, node.identName)
  of xnkMemberAccessExpr:
    # Member accesses (properties/methods) should be camelCase
    # Skip collision check since they're always qualified (obj.member)
    node.memberName = getSanitizedIdentifier(ctx, node.memberName, convertCase = true, skipCollisionCheck = true)

  # C#-specific external nodes
  of xnkExternal_Property:
    # Properties should be camelCase
    node.extPropName = getSanitizedIdentifier(ctx, node.extPropName, convertCase = true)
  of xnkExternal_Event:
    node.extEventName = getSanitizedIdentifier(ctx, node.extEventName)
  of xnkExternal_Delegate:
    node.extDelegateName = getSanitizedIdentifier(ctx, node.extDelegateName)
  of xnkExternal_LocalFunction:
    node.extLocalFuncName = getSanitizedIdentifier(ctx, node.extLocalFuncName)

  # Other declarations
  of xnkAbstractDecl:
    node.abstractName = getSanitizedIdentifier(ctx, node.abstractName)
  of xnkLabeledStmt:
    node.labelName = getSanitizedIdentifier(ctx, node.labelName)
  of xnkGotoStmt:
    node.gotoLabel = getSanitizedIdentifier(ctx, node.gotoLabel)
  of xnkGenericParameter:
    node.genericParamName = getSanitizedIdentifier(ctx, node.genericParamName)
  of xnkLibDecl:
    node.libName = getSanitizedIdentifier(ctx, node.libName)
  of xnkCFuncDecl:
    node.cfuncName = getSanitizedIdentifier(ctx, node.cfuncName)
  of xnkExternalVar:
    node.extVarName = getSanitizedIdentifier(ctx, node.extVarName)

  # Optional string fields
  of xnkCatchStmt:
    if node.catchVar.isSome:
      node.catchVar = some(getSanitizedIdentifier(ctx, node.catchVar.get))
  of xnkArgument:
    if node.argName.isSome:
      node.argName = some(getSanitizedIdentifier(ctx, node.argName.get))
  of xnkImport:
    if node.importAlias.isSome:
      node.importAlias = some(getSanitizedIdentifier(ctx, node.importAlias.get))

  else:
    discard

proc applyNimIdentifierSanitization*(ast: XLangNode): XLangNode =
  ## Apply identifier sanitization to entire XLang AST
  ## Two-phase approach:
  ## 1. Collect all identifiers
  ## 2. Sanitize identifiers, detecting and resolving collisions
  if ast.isNil:
    return ast

  var ctx = SanitizationContext(
    existingIdentifiers: initHashSet[string](),
    usedIdentifiers: initHashSet[string](),
    renameMap: initTable[string, string]()
  )

  # Phase 1: Collect all identifiers
  var astMut = ast
  traverseTree(astMut, proc(node: var XLangNode) = collectIdentifiersFromNode(node, ctx))

  # Phase 2: Sanitize identifiers with collision detection
  traverseTree(astMut, proc(node: var XLangNode) = sanitizeNodeIdentifiers(node, ctx))

  return astMut
