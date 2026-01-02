## Property to Getter/Setter Procs Transformation
##
## Transforms: property Age { get {...} set {...} }
## Into:       proc getAge(): T = {...}
##             proc setAge(value: T) = {...}

import core/xlangtypes
import transforms/transform_context
import error_collector
import options
import strutils
import tables

proc transformPropertyHelper(node: XLangNode, ctx: TransformContext, parentClass: XLangNode): XLangNode =
  ## Transform a single property node
  case node.kind
  of xnkExternal_Property:
    let prop = node
    var results: seq[XLangNode] = @[]

    # Determine if this is an auto-property (no explicit getter/setter bodies)
    let isAutoFullProperty = prop.extPropGetter.isNone() and prop.extPropSetter.isNone()
    let isAutoGetProperty = prop.extPropSetter.isNone() and prop.extPropGetter.isSome() and
                            prop.extPropGetter.get.kind == xnkEmptyStmt
    let isAutoSetProperty = prop.extPropGetter.isNone() and prop.extPropSetter.isSome() and
                            prop.extPropSetter.get.kind == xnkEmptyStmt
    
    let isAutoProperty = isAutoFullProperty or isAutoGetProperty or isAutoSetProperty



    # Register the property rename in semantic info
    # Look up the property symbol and register its getter/setter names
    if ctx.semanticInfo != nil:
      let propSym = ctx.getDeclSymbol(node)
      if propSym.isSome():
        let sym = propSym.get()
        # Register getter as the primary rename for property access
        let getterName = "get" & prop.extPropName
        ctx.renameSymbol("PropertyToProcs", sym, getterName)

    # For auto-properties, create a private backing field and add it to the containing class
    # Following C# convention: PropertyName -> _propertyName
    if isAutoProperty:
      let backingFieldName = "_" & prop.extPropName[0].toLowerAscii() & prop.extPropName[1..^1]

      # Find the containing class and add the backing field to it
      var containingClass = ctx.findContainingClass(node)
      
      if containingClass != nil:
        let backingField = XLangNode(
          kind: xnkFieldDecl,
          fieldName: backingFieldName,
          fieldType: if prop.extPropType.isSome(): prop.extPropType.get else: XLangNode(kind: xnkNamedType, typeName: "auto"),
          fieldInitializer: none(XLangNode)
        )
        ctx.queueFieldForClass("PropertyToProcs", containingClass, backingField)
      else:
        echo "containingClass is nil"
        ctx.addWarning(tekTransformError,
          "Auto-property '" & prop.extPropName & " - containingClass was nil",
          ctx.currentFile)

      # Create getter that returns backing field
      let getterName = "get" & prop.extPropName
      let getterBody = XLangNode(
        kind: xnkBlockStmt,
        blockBody: @[
          XLangNode(
            kind: xnkReturnStmt,
            returnExpr: some(XLangNode(
              kind: xnkMemberAccessExpr,
              memberExpr: XLangNode(kind: xnkIdentifier, identName: "self"),
              memberName: backingFieldName
            ))
          )
        ]
      )
      let getter = XLangNode(
        kind: xnkFuncDecl,
        funcName: getterName,
        params: @[],
        returnType: prop.extPropType,
        body: getterBody,
        isAsync: false,
        funcVisibility: "public",
        funcIsStatic: false
      )
      results.add(getter)

      # Create setter for read-write auto-properties
      let setterName = "set" & prop.extPropName
      let valueParam = XLangNode(
        kind: xnkParameter,
        paramName: "value",
        paramType: prop.extPropType,
        defaultValue: none(XLangNode)
      )
      let setterBody = XLangNode(
        kind: xnkBlockStmt,
        blockBody: @[
          XLangNode(
            kind: xnkAsgn,
            asgnLeft: XLangNode(
              kind: xnkMemberAccessExpr,
              memberExpr: XLangNode(kind: xnkIdentifier, identName: "self"),
              memberName: backingFieldName
            ),
            asgnRight: XLangNode(kind: xnkIdentifier, identName: "value")
          )
        ]
      )
      let setter = XLangNode(
        kind: xnkFuncDecl,
        funcName: setterName,
        params: @[valueParam],
        returnType: none(XLangNode),
        body: setterBody,
        isAsync: false,
        funcVisibility: "public",
        funcIsStatic: false
      )
      results.add(setter)

    else:
      # Explicit getter/setter bodies - use them directly
      # Create getter proc
      if prop.extPropGetter.isSome():
        let getterName = "get" & prop.extPropName
        let getter = XLangNode(
          kind: xnkFuncDecl,
          funcName: getterName,
          params: @[],
          returnType: prop.extPropType,
          body: prop.extPropGetter.get,
          isAsync: false,
          funcVisibility: "public",
          funcIsStatic: false
        )
        results.add(getter)

      # Create setter proc
      if prop.extPropSetter.isSome():
        let setterName = "set" & prop.extPropName
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
          returnType: none(XLangNode),
          body: prop.extPropSetter.get,
          isAsync: false,
          funcVisibility: "public",
          funcIsStatic: false
        )
        results.add(setter)

    # Return getter and setter in a block (backing field was added directly to parent)
    if results.len == 0:
      # No getter/setter (shouldn't happen)
      result = node
    elif results.len == 1:
      result = results[0]
    else:
      result = XLangNode(
        kind: xnkBlockStmt,
        blockBody: results
      )
  else:
    return node

proc transformPropertyToProcs*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform property declarations into getter/setter procedures
  case node.kind
  of xnkExternal_Property:
    result = transformPropertyHelper(node, ctx, nil)

  else:
    result = node
