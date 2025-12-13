## Property to Getter/Setter Procs Transformation
##
## Transforms: property Age { get {...} set {...} }
## Into:       proc Age(): T = {...}
##             proc `Age=`(value: T) = {...}

import ../../../xlangtypes
import options

proc transformPropertyHelper(node: XLangNode): XLangNode =
  ## Transform a single property node
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
        returnType: node.propType,
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
    # If neither, convert to a simple field
    if procs.len == 0:
      # No getter/setter - convert to field declaration
      result = XLangNode(
        kind: xnkFieldDecl,
        fieldName: prop.propName,
        fieldType: if prop.propType.isSome(): prop.propType.get() else: XLangNode(kind: xnkNamedType, typeName: "auto"),
        fieldInitializer: none(XLangNode)
      )
    elif procs.len == 1:
      result = procs[0]
    else:
      result = XLangNode(
        kind: xnkBlockStmt,
        blockBody: procs
      )
  else:
    return node

proc transformPropertyToProcs*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Transform property declarations into getter/setter procedures
  ## Handles properties nested in classes/structs/interfaces
  case node.kind
  of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
    # Transform class members, converting properties to procs
    var newMembers: seq[XLangNode] = @[]
    for member in node.members:
      newMembers.add(transformPropertyHelper(member))

    result = node
    result.members = newMembers

  of xnkPropertyDecl:
    # Standalone property (shouldn't happen usually, but handle it)
    result = transformPropertyHelper(node)

  else:
    result = node
