## Interface to Concept Transformation
##
## Transforms: interface Drawable { proc draw() }
## Into:       type Drawable = concept x { x.draw() }

import core/xlangtypes
import semantic/semantic_analysis
import options

proc transformInterfaceToConcept*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform interface declarations into Nim concepts
  ## This is needed because Nim doesn't have interfaces
  if node.kind != xnkExternal_Interface:
    return node

  # Nim concepts require method calls to be demonstrated
  # interface methods → concept requirements

  # Create concept body from interface members
  var conceptBody: seq[XLangNode] = @[]

  # Process each member of the interface
  for member in node.extInterfaceMembers:
    if member.kind in {xnkFuncDecl, xnkMethodDecl}:
      # Create a method call requirement: x.methodName(args)
      var callArgs: seq[XLangNode] = @[]
      for param in member.params:
        if param.kind == xnkParameter:
          # Add parameter type as requirement
          callArgs.add(XLangNode(
            kind: xnkIdentifier,
            identName: param.paramName
          ))

      let methodCall = XLangNode(
        kind: xnkCallExpr,
        callee: XLangNode(
          kind: xnkMemberAccessExpr,
          memberExpr: XLangNode(kind: xnkIdentifier, identName: "x"),
          memberName: member.funcName
        ),
        args: callArgs
      )

      conceptBody.add(methodCall)

  result = XLangNode(
    kind: xnkConceptDef,
    conceptName: node.extInterfaceName,
    conceptBody: XLangNode(
      kind: xnkBlockStmt,
      blockBody: conceptBody
    )
  )
