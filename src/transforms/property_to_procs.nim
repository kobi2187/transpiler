## Property to Getter/Setter Procs Transformation
##
## Transforms: property Age { get {...} set {...} }
## Into:       proc Age(): T = {...}
##             proc `Age=`(value: T) = {...}

import ../../xlangtypes
import options

proc transformPropertyToProcs*(node: XLangNode): XLangNode =
  ## Transform property declarations into getter/setter procedures
  ## Returns a block containing both the getter and setter procs
  if node.kind != xnkPropertyDecl:
    return node

  var procs: seq[XLangNode] = @[]

  # Create getter proc
  if node.propGetter.isSome:
    let getter = XLangNode(
      kind: xnkFuncDecl,
      funcName: node.propName,
      params: @[],  # No parameters for getter
      returnType: if node.propType.isSome:
                    some(node.propType.get)
                  else:
                    none(XLangNode),
      body: node.propGetter.get,
      isPublic: node.isPublic,
      isExported: node.isExported
    )
    procs.add(getter)

  # Create setter proc
  if node.propSetter.isSome:
    # Nim uses `Name=` for setter procs
    let setterName = "`" & node.propName & "=`"

    # Setter takes a value parameter
    let valueParam = XLangNode(
      kind: xnkParameter,
      paramName: "value",
      paramType: if node.propType.isSome:
                   some(node.propType.get)
                 else:
                   none(XLangNode)
    )

    let setter = XLangNode(
      kind: xnkFuncDecl,
      funcName: setterName,
      params: @[valueParam],
      returnType: none(XLangNode),  # Setters return void
      body: node.propSetter.get,
      isPublic: node.isPublic,
      isExported: node.isExported
    )
    procs.add(setter)

  # If we have both getter and setter, wrap in block
  # If only one, return just that proc
  if procs.len == 1:
    result = procs[0]
  else:
    result = XLangNode(
      kind: xnkBlockStmt,
      blockBody: procs
    )
