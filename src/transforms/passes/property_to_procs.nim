## Property to Getter/Setter Procs Transformation
##
## Transforms: property Age { get {...} set {...} }
## Into:       proc getAge(): T = {...}
##             proc setAge(value: T) = {...}

import ../../../xlangtypes
import ../../semantic/semantic_analysis
import options
import strutils
import tables

proc transformPropertyHelper(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform a single property node
  case node.kind
  of xnkExternal_Property:
    let prop = node
    var procs: seq[XLangNode] = @[]

    # Register the property rename in semantic info
    # Look up the property symbol and register its getter/setter names
    if semanticInfo != nil:
      let propSym = semanticInfo.getDeclSymbol(node)
      if propSym.isSome():
        let sym = propSym.get()
        # Register getter as the primary rename for property access
        let getterName = "get" & prop.extPropName
        semanticInfo.renames[sym] = getterName

    # Create getter proc
    if prop.extPropGetter.isSome():
      # Use getPropertyName pattern to avoid shadowing and recursion
      let getterName = "get" & prop.extPropName

      let getter = XLangNode(
        kind: xnkFuncDecl,
        funcName: getterName,
        params: @[],  # No parameters for getter
        returnType: prop.extPropType,
        body: prop.extPropGetter.get,
        isAsync: false,
        funcVisibility: "public",  # Inherit property visibility
        funcIsStatic: false
      )
      procs.add(getter)

    # Create setter proc
    if prop.extPropSetter.isSome():
      # Use setPropertyName pattern
      let setterName = "set" & prop.extPropName

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
        isAsync: false,
        funcVisibility: "public",
        funcIsStatic: false
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

proc transformPropertyToProcs*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform property declarations into getter/setter procedures
  ## Handles properties nested in classes/structs/interfaces
  case node.kind
  of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
    # Transform class members, converting properties to procs
    var newMembers: seq[XLangNode] = @[]
    for member in node.members:
      newMembers.add(transformPropertyHelper(member, semanticInfo))

    result = node
    result.members = newMembers

  of xnkExternal_Property:
    # Standalone property (shouldn't happen usually, but handle it)
    result = transformPropertyHelper(node, semanticInfo)

  else:
    result = node
