## Indexer to Procs Transform
##
## Converts C# indexer declarations to Nim operator procs.
##
## C# indexers have get/set accessors:
##   public int this[int i] {
##     get { return data[i]; }
##     set { data[i] = value; }
##   }
##
## Becomes two Nim procs:
##   proc `[]`(self: MyClass, i: int): int = data[i]
##   proc `[]=`(self: var MyClass, i: int, value: int) = data[i] = value

import ../../xlangtypes
import options

proc transformIndexerToProcs*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.}

proc convertIndexerDecl(node: XLangNode): seq[XLangNode] =
  ## Convert a single indexer declaration to getter/setter procs
  result = @[]

  # Create getter proc: proc `[]`(self: T, params...): ReturnType
  if node.indexerGetter.isSome():
    let getter = XLangNode(kind: xnkFuncDecl)
    getter.funcName = "[]"  # Will be backtick-quoted in xlangtonim
    getter.params = @[]

    # Add self parameter
    let selfParam = XLangNode(
      kind: xnkParameter,
      paramName: "self",
      paramType: some(XLangNode(
        kind: xnkIdentifier,
        identName: "Self"  # Will be replaced with actual class type
      )),
      defaultValue: none(XLangNode)
    )
    getter.params.add(selfParam)

    # Add index parameters
    for param in node.indexerParams:
      getter.params.add(param)

    getter.returnType = some(node.indexerType)
    getter.body = node.indexerGetter.get
    getter.isAsync = false

    result.add(getter)

  # Create setter proc: proc `[]=`(self: var T, params..., value: ReturnType)
  if node.indexerSetter.isSome():
    let setter = XLangNode(kind: xnkFuncDecl)
    setter.funcName = "[]="
    setter.params = @[]

    # Add self parameter (var for mutation)
    let selfParam = XLangNode(
      kind: xnkParameter,
      paramName: "self",
      paramType: some(XLangNode(
        kind: xnkReferenceType,
        referentType: XLangNode(
          kind: xnkIdentifier,
          identName: "Self"
        )
      )),
      defaultValue: none(XLangNode)
    )
    setter.params.add(selfParam)

    # Add index parameters
    for param in node.indexerParams:
      setter.params.add(param)

    # Add value parameter
    let valueParam = XLangNode(
      kind: xnkParameter,
      paramName: "value",
      paramType: some(node.indexerType),
      defaultValue: none(XLangNode)
    )
    setter.params.add(valueParam)

    setter.returnType = none(XLangNode)  # void
    setter.body = node.indexerSetter.get
    setter.isAsync = false

    result.add(setter)

proc transformIndexerHelper(node: XLangNode): seq[XLangNode] =
  ## Transform a node, potentially splitting indexers into multiple procs
  if node.kind == xnkIndexerDecl:
    return convertIndexerDecl(node)
  else:
    return @[node]

proc transformIndexerToProcs*(node: XLangNode): XLangNode =
  ## Transform indexer declarations to operator procs
  case node.kind
  of xnkClassDecl, xnkStructDecl:
    # Transform class members, expanding indexers
    var newMembers: seq[XLangNode] = @[]
    for member in node.members:
      let transformed = transformIndexerHelper(member)
      for m in transformed:
        newMembers.add(m)

    result = node
    result.members = newMembers

  of xnkIndexerDecl:
    # Standalone indexer (shouldn't happen, but handle it)
    let procs = convertIndexerDecl(node)
    if procs.len > 0:
      result = procs[0]  # Return first proc
    else:
      result = node

  else:
    result = node
