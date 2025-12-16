## Ternary to If Expression Transformation
##
## Transforms: condition ? valueA : valueB
## Into:       if condition: valueA else: valueB

import ../../../xlangtypes
import options

proc transformTernaryToIf*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Transform ternary expressions into if expressions
  ## This is needed for languages that don't have ternary operators
  ## but do have if expressions (like Nim)
  if node.kind != xnkExternal_Ternary:
    return node

  # Recursively transform nested ternaries
  let transformedThen = transformTernaryToIf(node.extTernaryThen)
  let transformedElse = transformTernaryToIf(node.extTernaryElse)

  # Create if expression
  # In Nim, if expressions work like: if cond: a else: b
  result = XLangNode(
    kind: xnkIfStmt,  # Will be converted to nnkIfExpr by xlangtonim
    ifCondition: node.extTernaryCondition,
    ifBody: XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[transformedThen]
    ),
    elseBody: some(XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[transformedElse]
    ))
  )
