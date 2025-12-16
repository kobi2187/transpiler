## Checked/Unchecked Transform
##
## Converts C# checked/unchecked arithmetic blocks to plain blocks.
##
## C# checked block:
##   checked {
##     result = a + b;  // throws on overflow
##   }
##
## C# unchecked block:
##   unchecked {
##     result = a + b;  // wraps on overflow
##   }
##
## Becomes Nim (both cases):
##   result = a + b  # Nim behavior depends on compilation flags
##
## Note: Nim doesn't have built-in overflow checking like C#.
## Overflow behavior is controlled by compilation flags (-d:nimIntOverflowCheck).
## We simply unwrap these blocks since we can't preserve the exact semantics.

import ../../../xlangtypes

proc transformCheckedToBlock*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Transform C# checked/unchecked blocks by unwrapping them
  if node.kind != xnkExternal_Checked:
    return node

  # Simply return the body - Nim doesn't have checked/unchecked blocks
  # The overflow behavior will be controlled by compilation flags
  result = node.extCheckedBody
