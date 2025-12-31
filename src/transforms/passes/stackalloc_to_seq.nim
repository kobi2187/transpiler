## StackAlloc to Seq Transform
##
## Converts C# stackalloc expressions to Nim seq allocations.
##
## C# stackalloc:
##   stackalloc int[10]
##   stackalloc char[size]
##
## Becomes Nim:
##   newSeq[int](10)
##   newSeq[char](size)
##
## Note: C# stackalloc allocates on the stack for performance, but Nim's
## seq (heap-allocated) is safer and provides automatic memory management.

import core/xlangtypes
import transforms/transform_context
import options
import strutils

proc transformStackAllocToSeq*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform C# stackalloc expressions into Nim newSeq calls
  if node.kind != xnkExternal_StackAlloc:
    return node

  # Extract type and size from stackalloc
  # extStackAllocType contains the full type like "char[CharStackBufferSize]"
  # We need to parse it to get the element type and size

  let typeNode = node.extStackAllocType
  var elementType: XLangNode
  var sizeExpr: Option[XLangNode]

  # Check if the type is an array type specification
  if typeNode.kind == xnkNamedType:
    let typeName = typeNode.typeName
    # Parse "char[size]" format
    if '[' in typeName:
      let parts = typeName.split('[')
      let baseType = parts[0]
      let sizeStr = parts[1].replace("]", "")

      elementType = XLangNode(
        kind: xnkNamedType,
        typeName: baseType
      )

      # Create size expression (could be a number or identifier)
      if sizeStr.len > 0:
        # Try to parse as integer
        try:
          let sizeInt = parseInt(sizeStr)
          sizeExpr = some(XLangNode(
            kind: xnkIntLit,
            literalValue: sizeStr
          ))
        except:
          # It's an identifier or expression
          sizeExpr = some(XLangNode(
            kind: xnkIdentifier,
            identName: sizeStr
          ))
    else:
      # Simple type without size
      elementType = typeNode
      sizeExpr = node.extStackAllocSize
  else:
    elementType = typeNode
    sizeExpr = node.extStackAllocSize

  # Create newSeq[T](size) call
  let newSeqCall = XLangNode(
    kind: xnkCallExpr,
    callee: XLangNode(
      kind: xnkGenericName,
      genericNameIdentifier: "newSeq",
      genericNameArgs: @[elementType]
    ),
    args: if sizeExpr.isSome: @[sizeExpr.get] else: @[]
  )

  result = newSeqCall
