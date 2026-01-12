## Transformation pass to lower Go's empty interface{} and struct{} types
##
## Go empty interface{}:
##   interface{}  // any type
##
## Becomes:
##   xnkNamedType with isEmptyMarkerType = some(true)
##
## Go empty struct{}:
##   struct{}  // zero-sized marker type
##
## Becomes:
##   xnkNamedType with isEmptyMarkerType = some(true)

import core/xlangtypes
import transforms/transform_context
import options

var typeCounter = 0

proc lowerGoEmptyInterfaceType*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Convert xnkExternal_GoEmptyInterfaceType to xnkNamedType with marker
  if node.kind != xnkExternal_GoEmptyInterfaceType:
    return node

  # Create a named type with the empty marker flag
  var namedType = XLangNode(kind: xnkNamedType)
  namedType.typeName = "any"  # Placeholder - will be handled by codegen based on isEmptyMarkerType
  namedType.isEmptyMarkerType = some(true)
  return namedType

proc lowerGoEmptyStructType*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Convert xnkExternal_GoEmptyStructType to xnkNamedType with marker
  if node.kind != xnkExternal_GoEmptyStructType:
    return node

  # Create a named type with the empty marker flag
  var namedType = XLangNode(kind: xnkNamedType)
  namedType.typeName = "void"  # Placeholder - will be handled by codegen based on isEmptyMarkerType
  namedType.isEmptyMarkerType = some(true)
  return namedType

proc lowerInlineStruct*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Convert xnkInlineStruct to xnkNamedType and add module-level declaration
  if node.kind != xnkInlineStruct:
    return node

  # Generate unique name
  typeCounter += 1
  let typeName = "InlineStruct" & $typeCounter

  # Create module-level struct declaration
  var structDecl = XLangNode(kind: xnkStructDecl)
  structDecl.typeNameDecl = typeName
  structDecl.baseTypes = @[]
  structDecl.members = node.inlineMembers

  # Register the new node in the context
  ctx.registerNewNode(structDecl)

  # Add to module declarations
  if ctx.conversion.currentModule.isSome:
    ctx.conversion.currentModule.get.moduleDecls.add(structDecl)
    ctx.logAction("go_empty_types", "added inline struct '" & typeName & "' to module")

  # Return named type reference
  var namedType = XLangNode(kind: xnkNamedType)
  namedType.typeName = typeName
  return namedType

proc lowerInlineInterface*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Convert xnkInlineInterface to xnkNamedType and add module-level declaration
  if node.kind != xnkInlineInterface:
    return node

  # Generate unique name
  typeCounter += 1
  let typeName = "InlineInterface" & $typeCounter

  # Create module-level interface declaration
  var interfaceDecl = XLangNode(kind: xnkInterfaceDecl)
  interfaceDecl.typeNameDecl = typeName
  interfaceDecl.baseTypes = @[]
  interfaceDecl.members = node.inlineMembers

  # Register the new node in the context
  ctx.registerNewNode(interfaceDecl)

  # Add to module declarations
  if ctx.conversion.currentModule.isSome:
    ctx.conversion.currentModule.get.moduleDecls.add(interfaceDecl)
    ctx.logAction("go_empty_types", "added inline interface '" & typeName & "' to module")

  # Return named type reference
  var namedType = XLangNode(kind: xnkNamedType)
  namedType.typeName = typeName
  return namedType

proc transformGoEmptyTypes*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform Go empty and inline types
  case node.kind
  of xnkExternal_GoEmptyInterfaceType:
    result = lowerGoEmptyInterfaceType(node, ctx)
  of xnkExternal_GoEmptyStructType:
    result = lowerGoEmptyStructType(node, ctx)
  of xnkInlineStruct:
    result = lowerInlineStruct(node, ctx)
  of xnkInlineInterface:
    result = lowerInlineInterface(node, ctx)
  else:
    # Not a target node, return unchanged
    result = node