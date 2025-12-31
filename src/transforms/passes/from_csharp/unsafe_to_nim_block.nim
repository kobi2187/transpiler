## Unsafe to Nim Block Transform
##
## Converts C# unsafe blocks (which allow pointer operations) to annotated Nim blocks.
##
## C# unsafe block:
##   unsafe {
##     int* ptr = &x;
##     *ptr = 42;
##   }
##
## Becomes Nim with documentation marker:
##   # Note: C# unsafe block - contains pointer operations
##   block:
##     var ptr = addr x
##     ptr[] = 42
##
## Note: C# unsafe blocks are required for pointer operations and unmanaged memory access.
## Nim doesn't have a separate "unsafe" context - pointer operations are always allowed
## but require explicit syntax (addr, ptr[], etc). We add a documentation comment to
## preserve the semantic intent that this code deals with low-level pointer operations.

import core/xlangtypes
import transforms/transform_context

proc transformUnsafeToNimBlock*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform C# unsafe blocks by unwrapping them with a documentation marker
  if node.kind != xnkExternal_Unsafe:
    return node

  # Create a comment node to document that this was an unsafe block
  let unsafeComment = XLangNode(
    kind: xnkComment,
    commentText: "Note: C# unsafe block - contains pointer operations",
    isDocComment: false
  )

  # Wrap the body in a block with the comment
  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: @[unsafeComment, node.extUnsafeBody]
  )
