## Null Coalescing and Safe Navigation Transformation
##
## Transforms:
## - a ?? b  →  if a != nil: a else: b
## - a?.b    →  if a != nil: a.b else: nil
##
## Because Nim doesn't have these C# operators

import ../../xlangtypes
import options

proc transformNullCoalesce*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Transform null coalescing and safe navigation operators
  case node.kind
  of xnkNullCoalesceExpr:
    # a ?? b  →  if a != nil: a else: b
    result = XLangNode(
      kind: xnkIfStmt,
      ifCondition: XLangNode(
        kind: xnkBinaryExpr,
        binaryOp: "!=",
        binaryLeft: node.nullCoalesceLeft,
        binaryRight: XLangNode(kind: xnkNoneLit)
      ),
      ifBody: XLangNode(
        kind: xnkBlockStmt,
        blockBody: @[node.nullCoalesceLeft]
      ),
      elseBody: some(XLangNode(
        kind: xnkBlockStmt,
        blockBody: @[node.nullCoalesceRight]
      ))
    )

  of xnkSafeNavigationExpr:
    # user?.Name  →  if user != nil: user.Name else: nil
    result = XLangNode(
      kind: xnkIfStmt,
      ifCondition: XLangNode(
        kind: xnkBinaryExpr,
        binaryOp: "!=",
        binaryLeft: node.safeNavObject,
        binaryRight: XLangNode(kind: xnkNoneLit)
      ),
      ifBody: XLangNode(
        kind: xnkBlockStmt,
        blockBody: @[XLangNode(
          kind: xnkMemberAccessExpr,
          memberExpr: node.safeNavObject,
          memberName: node.safeNavMember
        )]
      ),
      elseBody: some(XLangNode(
        kind: xnkBlockStmt,
        blockBody: @[XLangNode(kind: xnkNoneLit)]
      ))
    )

  else:
    result = node
