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

proc transformGoEmptyTypes*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform Go empty types to named types with markers
  case node.kind
  of xnkExternal_GoEmptyInterfaceType:
    result = lowerGoEmptyInterfaceType(node, ctx)
  of xnkExternal_GoEmptyStructType:
    result = lowerGoEmptyStructType(node, ctx)
  else:
    # Not a target node, return unchanged
    result = node