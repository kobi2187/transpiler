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
  of xnkExternal_Property:
    let prop = node
    var procs: seq[XLangNode] = @[]

    # Create getter proc
    if prop.extPropGetter.isSome():
      let getter = XLangNode(
        kind: xnkFuncDecl,
        funcName: prop.extPropName,
        params: @[],  # No parameters for getter
        returnType: prop.extPropType,
        body: prop.extPropGetter.get,
        isAsync: false
      )
      procs.add(getter)

    # Create setter proc
    if prop.extPropSetter.isSome():
      # Nim uses `Name=` for setter procs
      let setterName = "`" & prop.extPropName & "=`"

      # Setter takes a value parameter
      let valueParam = XLangNode(
        kind: xnkParameter,
        paramName: "value",
        paramType: prop.extPropType,
        defaultValue: none(XLangNode)
      )

      let setter = XLangNode(
        kind: xnkFuncDecl,
        funcName: setterName,
        params: @[valueParam],
        returnType: none(XLangNode),  # Setters return void
        body: prop.extPropSetter.get,
        isAsync: false
      )
      procs.add(setter)

    # If we have both getter and setter, wrap in block
    # If only one, return just that proc
    # If neither, convert to a simple field
    if procs.len == 0:
      # No getter/setter - convert to field declaration (auto-property)
      result = XLangNode(
        kind: xnkFieldDecl,
        fieldName: prop.extPropName,
        fieldType: if prop.extPropType.isSome(): prop.extPropType.get else: XLangNode(kind: xnkNamedType, typeName: "auto"),
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

  of xnkExternal_Property:
    # Standalone property (shouldn't happen usually, but handle it)
    result = transformPropertyHelper(node)

  else:
    result = node
