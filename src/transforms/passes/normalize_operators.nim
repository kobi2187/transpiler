## Normalize Operators
##
## Converts special operator symbols to their External node equivalents
## This runs early in the pipeline to normalize the AST
##
## - ?? operator → xnkExternal_NullCoalesce
## - Other special operators can be added here

import core/xlangtypes
import transforms/transform_context
import options

proc normalizeOperators*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Convert special operators to their External node types
  ## ONLY runs on binary expressions with special operators
  case node.kind
  of xnkBinaryExpr:
    # ONLY transform if this is a special operator
    if node.binaryOp == opNullCoalesce:
      # Convert ?? to xnkExternal_NullCoalesce
      result = XLangNode(
        kind: xnkExternal_NullCoalesce,
        extNullCoalesceLeft: node.binaryLeft,
        extNullCoalesceRight: node.binaryRight
      )
    else:
      # NOT a special operator - return unchanged
      # IMPORTANT: The pass manager should not count this as a transformation
      result = node

  else:
    # Not a binary expression - return unchanged
    result = node
