## Property to Getter/Setter Procs Transformation
##
## Transforms C# properties into getter/setter procedures.
##
## Handles all property variants:
## - { get; set; }           - auto r/w property, needs backing field
## - { get; }                - auto read-only property, needs backing field
## - { set; }                - auto write-only property (C# 9+), needs backing field
## - { get { ... } }         - explicit getter only
## - { set { ... } }         - explicit setter only
## - { get { ... } set { ... } } - explicit both
## - { get; set { ... } }    - mixed: auto get, explicit set, needs backing field
## - { get { ... } set; }    - mixed: explicit get, auto set, needs backing field
## - { get; } = value;       - auto with initializer

import core/xlangtypes
import transforms/transform_context
import error_collector
import options
import strutils

proc makeBackingFieldName(propName: string): string =
  ## Convert PropertyName to _propertyName
  "_" & propName[0].toLowerAscii() & propName[1..^1]

proc makeGetterName(propName: string): string =
  "get" & propName

proc makeSetterName(propName: string): string =
  "set" & propName

proc createBackingField(prop: XLangNode, backingFieldName: string): XLangNode =
  ## Create a backing field declaration for an auto-property
  XLangNode(
    kind: xnkFieldDecl,
    fieldName: backingFieldName,
    fieldType: if prop.extPropType.isSome(): prop.extPropType.get
               else: XLangNode(kind: xnkNamedType, typeName: "auto"),
    fieldInitializer: prop.extPropInitializer  # May include initializer like = 5
  )

proc createAutoGetterBody(backingFieldName: string): XLangNode =
  ## Create body for auto-getter: return self._field
  XLangNode(
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

proc createAutoSetterBody(backingFieldName: string): XLangNode =
  ## Create body for auto-setter: self._field = value
  XLangNode(
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

proc createGetterProc(prop: XLangNode, body: XLangNode): XLangNode =
  ## Create a getter procedure
  XLangNode(
    kind: xnkFuncDecl,
    funcName: makeGetterName(prop.extPropName),
    params: @[],
    returnType: prop.extPropType,
    body: body,
    isAsync: false,
    funcVisibility: prop.extPropVisibility,
    funcIsStatic: prop.extPropIsStatic
  )

proc createSetterProc(prop: XLangNode, body: XLangNode): XLangNode =
  ## Create a setter procedure
  let valueParam = XLangNode(
    kind: xnkParameter,
    paramName: "value",
    paramType: prop.extPropType,
    defaultValue: none(XLangNode)
  )
  XLangNode(
    kind: xnkFuncDecl,
    funcName: makeSetterName(prop.extPropName),
    params: @[valueParam],
    returnType: none(XLangNode),
    body: body,
    isAsync: false,
    funcVisibility: prop.extPropVisibility,
    funcIsStatic: prop.extPropIsStatic
  )

proc transformPropertyToProcs*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform property declarations into getter/setter procedures
  if node.kind != xnkExternal_Property:
    return node

  let prop = node
  var results: seq[XLangNode] = @[]

  # Determine what kind of accessors we have
  let hasGetter = prop.extPropHasGetter
  let hasSetter = prop.extPropHasSetter
  let getterIsAuto = hasGetter and prop.extPropGetterBody.isNone
  let setterIsAuto = hasSetter and prop.extPropSetterBody.isNone

  # If any accessor is auto, we need a backing field
  let needsBackingField = getterIsAuto or setterIsAuto
  let backingFieldName = makeBackingFieldName(prop.extPropName)

  # Register the property rename in semantic info
  if ctx.semanticInfo != nil:
    let propSym = ctx.getDeclSymbol(node)
    if propSym.isSome():
      let sym = propSym.get()
      ctx.renameSymbol("PropertyToProcs", sym, makeGetterName(prop.extPropName))

  # Add backing field if needed
  if needsBackingField:
    let containingClass = ctx.findContainingClass(node)
    if containingClass != nil:
      let backingField = createBackingField(prop, backingFieldName)
      ctx.queueFieldForClass("PropertyToProcs", containingClass, backingField)
    else:
      ctx.addWarning(tekTransformError,
        "Auto-property '" & prop.extPropName & "' - could not find containing class",
        ctx.currentFile)

  # Create getter if present
  if hasGetter:
    let getterBody = if getterIsAuto:
      createAutoGetterBody(backingFieldName)
    else:
      prop.extPropGetterBody.get
    results.add(createGetterProc(prop, getterBody))

  # Create setter if present
  if hasSetter:
    let setterBody = if setterIsAuto:
      createAutoSetterBody(backingFieldName)
    else:
      prop.extPropSetterBody.get
    results.add(createSetterProc(prop, setterBody))

  # Return result
  if results.len == 0:
    # Property with no accessors (shouldn't happen, but handle gracefully)
    ctx.addWarning(tekTransformError,
      "Property '" & prop.extPropName & "' has no accessors",
      ctx.currentFile)
    result = node
  elif results.len == 1:
    result = results[0]
  else:
    result = XLangNode(
      kind: xnkBlockStmt,
      blockBody: results
    )
