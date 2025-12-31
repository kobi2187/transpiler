## Destructuring Assignment Transformation
##
## Transforms:
## - {name, age} = person  →  let name = person.name; let age = person.age
## - [a, b, ...rest] = arr  →  let a = arr[0]; let b = arr[1]; let rest = arr[2..^1]
##
## Because JS/Python style destructuring needs to be explicit in Nim

import core/xlangtypes
import transforms/transform_context
import options
import sequtils
import strutils

proc transformDestructuring*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform destructuring assignments into explicit assignments
  case node.kind
  of xnkExternal_Destructure:
    # Unified external destructuring node
    var declarations: seq[XLangNode] = @[]

    if node.extDestructKind == "object":
      # {name, age} = person
      # Transform to:
      # let name = person.name
      # let age = person.age
      for field in node.extDestructFields:
        declarations.add(XLangNode(
          kind: xnkLetDecl,
          declName: field,
          declType: none(XLangNode),
          initializer: some(XLangNode(
            kind: xnkMemberAccessExpr,
            memberExpr: node.extDestructSource,
            memberName: field
          ))
        ))

    elif node.extDestructKind == "array":
      # [first, second, ...rest] = array
      # Transform to:
      # let first = array[0]
      # let second = array[1]
      # let rest = array[2..^1]

      # Destructure indexed elements
      for i, varName in node.extDestructVars:
        declarations.add(XLangNode(
          kind: xnkLetDecl,
          declName: varName,
          declType: none(XLangNode),
          initializer: some(XLangNode(
            kind: xnkIndexExpr,
            indexExpr: node.extDestructSource,
            indexArgs: @[XLangNode(kind: xnkIntLit, literalValue: $i)]
          ))
        ))

      # Handle rest/spread operator if present
      if node.extDestructRest.isSome:
        let startIdx = node.extDestructVars.len
        declarations.add(XLangNode(
          kind: xnkLetDecl,
          declName: node.extDestructRest.get,
          declType: none(XLangNode),
          initializer: some(XLangNode(
            kind: xnkSliceExpr,
            sliceExpr: node.extDestructSource,
            sliceStart: some(XLangNode(kind: xnkIntLit, literalValue: $startIdx)),
            sliceEnd: none(XLangNode),  # To end of array (^1 in Nim)
            sliceStep: none(XLangNode)
          ))
        ))

    result = XLangNode(kind: xnkBlockStmt, blockBody: declarations)

  of xnkTupleUnpacking:
    # Go-style: (a, b, c) = foo()
    # Already close to Nim, but ensure proper let declaration
    # let (a, b, c) = foo()

    # If unpackTargets are identifiers, create tuple unpack let
    var targetNames: seq[string] = @[]
    for target in node.unpackTargets:
      if target.kind == xnkIdentifier:
        targetNames.add(target.identName)

    if targetNames.len > 0:
      # Create a special tuple unpacking declaration
      # Nim supports: let (a, b) = (1, 2)
      result = XLangNode(
        kind: xnkLetDecl,
        declName: "(" & targetNames.join(", ") & ")",  # Special syntax marker
        declType: none(XLangNode),
        initializer: some(node.unpackExpr)
      )
    else:
      # Fallback: create individual assignments
      var declarations: seq[XLangNode] = @[]
      for i, target in node.unpackTargets:
        declarations.add(XLangNode(
          kind: xnkLetDecl,
          declName: if target.kind == xnkIdentifier: target.identName else: "_",
          declType: none(XLangNode),
          initializer: some(XLangNode(
            kind: xnkIndexExpr,
            indexExpr: node.unpackExpr,
            indexArgs: @[XLangNode(kind: xnkIntLit, literalValue: $i)]
          ))
        ))
      result = XLangNode(kind: xnkBlockStmt, blockBody: declarations)

  else:
    result = node
