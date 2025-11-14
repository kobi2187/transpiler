## Ternary to If Expression Transformation
##
## Transforms: condition ? valueA : valueB
## Into:       if condition: valueA else: valueB

import ../../xlangtypes
import options

proc transformTernaryToIf*(node: XLangNode): XLangNode =
  ## Transform ternary expressions into if expressions
  ## This is needed for languages that don't have ternary operators
  ## but do have if expressions (like Nim)
  if node.kind != xnkTernaryExpr:
    return node

  # Create if expression
  # In Nim, if expressions work like: if cond: a else: b
  result = XLangNode(
    kind: xnkIfStmt,  # Will be converted to nnkIfExpr by xlangtonim
    ifCondition: node.ternaryCondition,
    ifBody: XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[node.ternaryThen]
    ),
    elseBody: some(XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[node.ternaryElse]
    ))
  )
