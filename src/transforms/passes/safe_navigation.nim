## Safe Navigation Operator Transform
##
## Lowers safe navigation (null-conditional) operators to explicit null checks.
##
## Examples:
##   C#: a?.b?.c
##   → if a != nil: (if a.b != nil: a.b.c else: nil) else: nil
##
##   C#: obj?.Method()
##   → if obj != nil: obj.Method() else: nil

import core/xlangtypes
import semantic/semantic_analysis
import options, sequtils

proc transformSafeNavigation*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode

proc transformSafeNavigationHelper(node: XLangNode): XLangNode =
  ## Recursively transform safe navigation expressions
  case node.kind
  of xnkExternal_SafeNavigation:
    # a?.b → if a != nil: a.b else: nil
    let obj = transformSafeNavigationHelper(node.extSafeNavObject)
    let memberName = node.extSafeNavMember

    # Create: obj != nil ? obj.member : nil (use external ternary kind)
    result = XLangNode(
      kind: xnkExternal_Ternary,
      extTernaryCondition: XLangNode(
        kind: xnkBinaryExpr,
        binaryLeft: obj,
        binaryOp: opNotEqual,
        binaryRight: XLangNode(kind: xnkNoneLit)
      ),
      extTernaryThen: XLangNode(
        kind: xnkMemberAccessExpr,
        memberExpr: obj,
        memberName: memberName
      ),
      extTernaryElse: XLangNode(kind: xnkNoneLit)
    )

  of xnkMemberAccessExpr:
    # Check if the object is a safe navigation that needs transformation
    let transformedExpr = transformSafeNavigationHelper(node.memberExpr)
    if transformedExpr == node.memberExpr:
      result = node  # No change
    else:
      result = XLangNode(
        kind: xnkMemberAccessExpr,
        memberExpr: transformedExpr,
        memberName: node.memberName
      )

  of xnkCallExpr:
    # Transform callee and arguments
    result = XLangNode(
      kind: xnkCallExpr,
      callee: transformSafeNavigationHelper(node.callee),
      args: node.args.map(transformSafeNavigationHelper)
    )

  of xnkIndexExpr:
    result = XLangNode(
      kind: xnkIndexExpr,
      indexExpr: transformSafeNavigationHelper(node.indexExpr),
      indexArgs: node.indexArgs.map(transformSafeNavigationHelper)
    )

  else:
    # For all other nodes, recursively transform children
    result = node

proc transformSafeNavigation*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform safe navigation operators into explicit null checks
  result = transformSafeNavigationHelper(node)
