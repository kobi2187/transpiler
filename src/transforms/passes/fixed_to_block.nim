## Fixed Statement Transform
##
## Converts C# fixed statements (which pin managed memory) to plain blocks in Nim.
##
## C# fixed statement:
##   fixed (char* ptr = str) {
##     // use ptr
##   }
##
## Becomes Nim:
##   block:
##     var ptr = addr str
##     # use ptr
##
## Note: C# fixed statements pin managed objects in memory to prevent the
## garbage collector from moving them while accessing via pointers.
## Nim doesn't require explicit pinning - the memory management system
## handles this automatically when using addr or ptr.

import ../../../xlangtypes

proc transformFixedToBlock*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Transform C# fixed statements by unwrapping them into regular blocks
  if node.kind != xnkExternal_Fixed:
    return node

  # Create a block with the fixed declarations followed by the body
  var blockStatements: seq[XLangNode] = @[]

  # Add all the declarations (they're already variable declarations)
  # These will typically be pointer declarations that need to be converted
  for decl in node.extFixedDeclarations:
    blockStatements.add(decl)

  # Add the body statements
  if node.extFixedBody.kind == xnkBlockStmt:
    # If the body is already a block, add its statements directly
    blockStatements.add(node.extFixedBody.blockBody)
  else:
    # Otherwise, add the body as a single statement
    blockStatements.add(node.extFixedBody)

  # Return a block statement with all declarations and body
  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: blockStatements
  )
