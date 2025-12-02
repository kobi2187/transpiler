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
  case node.kind
  of xnkPropertyDecl:
    let prop = node
    var procs: seq[XLangNode] = @[]

    # Create getter proc
    if prop.getter != none(XLangNode):
      let getter = XLangNode(
        kind: xnkFuncDecl,
        funcName: node.propName,
        params: @[],  # No parameters for getter
        returnType: some(node.propType),
        body: prop.getter.get
      )
      procs.add(getter)

    # Create setter proc
    if prop.setter != none(XLangNode):
      # Nim uses `Name=` for setter procs
      let setterName = "`" & node.propName & "=`"

      # Setter takes a value parameter
      let valueParam = XLangNode(
        kind: xnkParameter,
        paramName: "value",
        paramType: prop.propType
      )

      let setter = XLangNode(
        kind: xnkFuncDecl,
        funcName: setterName,
        params: @[valueParam],
        returnType: none(XLangNode),  # Setters return void
        body: prop.setter.get
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
  else:
    return node
