## Null Coalescing and Safe Navigation Transformation
##
## Transforms:
## - a ?? b  →  if a != nil: a else: b
## - a?.b    →  if a != nil: a.b else: nil
##
## Because Nim doesn't have these C# operators

import ../../../xlangtypes
import ../../semantic/semantic_analysis
import options

proc transformNullCoalesce*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform null coalescing operator
  case node.kind
  of xnkExternal_NullCoalesce:
    # a ?? b  →  if a != nil: a else: b
    result = XLangNode(
      kind: xnkIfStmt,
      ifCondition: XLangNode(
        kind: xnkBinaryExpr,
        binaryOp: opNotEqual,
        binaryLeft: node.extNullCoalesceLeft,
        binaryRight: XLangNode(kind: xnkNoneLit)
      ),
      ifBody: XLangNode(
        kind: xnkBlockStmt,
        blockBody: @[node.extNullCoalesceLeft]
      ),
      elseBody: some(XLangNode(
        kind: xnkBlockStmt,
        blockBody: @[node.extNullCoalesceRight]
      ))
    )

  else:
    result = node
