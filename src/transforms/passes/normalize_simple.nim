## Simple Normalization Transformations
##
## Handles simple, straightforward transformations:
## - Remove pass statements (Python)
## - Normalize empty blocks
## - Clean up redundant constructs

import ../../../xlangtypes
import ../../semantic/semantic_analysis
import options

proc transformNormalizeSimple*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Perform simple normalizations
  case node.kind
  of xnkExternal_Pass:
    # Python's pass statement → Nim's discard
    # pass is just a placeholder, discard serves the same purpose
    result = XLangNode(
      kind: xnkCallExpr,
      callee: XLangNode(kind: xnkIdentifier, identName: "discard"),
      args: @[]
    )

  of xnkBlockStmt:
    # Normalize blocks: remove nested single-statement blocks
    if node.blockBody.len == 1:
      let child = node.blockBody[0]
      # If single child is also a block, unwrap it
      if child.kind == xnkBlockStmt:
        result = child
      else:
        result = node
    elif node.blockBody.len == 0:
      # Empty block - could be pass statement result
      result = node
    else:
      result = node

  of xnkExternal_With:
    # Python's with statement → defer pattern (simplified version)
    # with resource as var:
    #   body
    # →
    # let var = resource
    # defer: var.close()  # Assumption: has close() method
    # body

    result = XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[
        # TODO: Extract variable binding from withExpr
        # For now, keep as-is
        node
      ]
    )

  of xnkExternal_Unless:
    # Ruby: unless x → if not x
    result = XLangNode(
      kind: xnkIfStmt,
      ifCondition: XLangNode(
        kind: xnkUnaryExpr,
        unaryOp: opNot,
        unaryOperand: transformNormalizeSimple(node.extUnlessCondition, semanticInfo)
      ),
      ifBody: transformNormalizeSimple(node.extUnlessBody, semanticInfo),
      elseBody: none(XLangNode)
    )

  of xnkExternal_Until:
    # repeat...until x → while not x
    result = XLangNode(
      kind: xnkWhileStmt,
      whileCondition: XLangNode(
        kind: xnkUnaryExpr,
        unaryOp: opNot,
        unaryOperand: transformNormalizeSimple(node.extUntilCondition, semanticInfo)
      ),
      whileBody: transformNormalizeSimple(node.extUntilBody, semanticInfo)
    )

  else:
    result = node
