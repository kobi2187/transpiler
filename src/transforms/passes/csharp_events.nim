## C# Events and Delegates to Nim Callbacks
##
## Transforms C# event/delegate pattern to Nim's proc types and callback lists
##
## C#:
##   public delegate void ButtonClickHandler(object sender, EventArgs e);
##   public event ButtonClickHandler Click;
##   Click?.Invoke(this, EventArgs.Empty);
##   Click += OnButtonClick;
##
## Nim:
##   type ButtonClickHandler = proc(sender: RootRef, e: EventArgs)
##   var clickHandlers: seq[ButtonClickHandler] = @[]
##   for handler in clickHandlers: handler(this, EventArgs())
##   clickHandlers.add(onButtonClick)

import ../../../xlangtypes
import options
import strutils

proc transformDelegate*(node: XLangNode): XLangNode =
  ## Transform C# delegate declaration to Nim proc type
  ##
  ## C#: public delegate RetType DelegateName(params);
  ## Nim: type DelegateName = proc(params): RetType

  if node.kind != xnkDelegateDecl:
    return node

  # Extract delegate signature
  let delegateName = node.delegateName
  let params = node.delegateParams
  let returnType = node.delegateReturnType

  # Create proc type alias
  # In Nim: type CallbackProc = proc(x: int): string
  # The proc type is represented as a type declaration

  result = XLangNode(
    kind: xnkTypeDecl,
    typeDefName: delegateName,
    typeDefBody: XLangNode(
      kind: xnkFuncType,
      funcParams: params,
      funcReturnType: returnType
    )
  )

proc transformEventDeclaration*(node: XLangNode): XLangNode =
  ## Transform C# event declaration to Nim callback list
  ##
  ## C#: public event DelegateType EventName;
  ## Nim: var eventNameHandlers: seq[DelegateType] = @[]

  if node.kind != xnkExternal_Event:
    return node

  let eventName = node.extEventName
  let eventType = node.extEventType

  # Create a seq variable to hold event handlers
  let handlerListName = eventName & "Handlers"

  result = XLangNode(
    kind: xnkVarDecl,
    declName: handlerListName,
    declType: some(XLangNode(
      kind: xnkGenericType,
      genericBase: some(XLangNode(kind: xnkNamedType, typeName: "seq")),
      genericArgs: @[eventType]
    )),
    initializer: some(XLangNode(
      kind: xnkSequenceLiteral,
      elements: @[]  # Empty sequence @[]
    ))
  )

proc transformEventSubscription*(node: XLangNode): XLangNode =
  ## Transform event subscription (+=) to seq.add
  ##
  ## C#: event += handler
  ## Nim: eventHandlers.add(handler)

  if node.kind != xnkBinaryExpr:
    return node

  # Check for += operator on event
  if node.binaryOp != "+=":
    return node

  # Assuming left side is event, right side is handler
  let eventExpr = node.binaryLeft
  let handlerExpr = node.binaryRight

  # Determine event handler list name
  # If eventExpr is identifier "Click", handler list is "ClickHandlers"
  var handlerListExpr: XLangNode

  if eventExpr.kind == xnkIdentifier:
    handlerListExpr = XLangNode(
      kind: xnkIdentifier,
      identName: eventExpr.identName & "Handlers"
    )
  elif eventExpr.kind == xnkMemberAccessExpr:
    # obj.Event → obj.EventHandlers
    handlerListExpr = XLangNode(
      kind: xnkMemberAccessExpr,
      memberExpr: eventExpr.memberExpr,
      memberName: eventExpr.memberName & "Handlers"
    )
  else:
    return node  # Can't transform

  # Build: handlerList.add(handler)
  result = XLangNode(
    kind: xnkCallExpr,
    callee: XLangNode(
      kind: xnkMemberAccessExpr,
      memberExpr: handlerListExpr,
      memberName: "add"
    ),
    args: @[handlerExpr]
  )

proc transformEventUnsubscription*(node: XLangNode): XLangNode =
  ## Transform event unsubscription (-=) to seq.delete
  ##
  ## C#: event -= handler
  ## Nim: eventHandlers.delete(eventHandlers.find(handler))

  if node.kind != xnkBinaryExpr:
    return node

  if node.binaryOp != "-=":
    return node

  let eventExpr = node.binaryLeft
  let handlerExpr = node.binaryRight

  var handlerListExpr: XLangNode
  if eventExpr.kind == xnkIdentifier:
    handlerListExpr = XLangNode(
      kind: xnkIdentifier,
      identName: eventExpr.identName & "Handlers"
    )
  elif eventExpr.kind == xnkMemberAccessExpr:
    handlerListExpr = XLangNode(
      kind: xnkMemberAccessExpr,
      memberExpr: eventExpr.memberExpr,
      memberName: eventExpr.memberName & "Handlers"
    )
  else:
    return node

  # Build: handlerList.keepItIf(it != handler)
  # Or: handlerList.delete(handlerList.find(handler))
  let findCall = XLangNode(
    kind: xnkCallExpr,
    callee: XLangNode(
      kind: xnkMemberAccessExpr,
      memberExpr: handlerListExpr,
      memberName: "find"
    ),
    args: @[handlerExpr]
  )

  result = XLangNode(
    kind: xnkCallExpr,
    callee: XLangNode(
      kind: xnkMemberAccessExpr,
      memberExpr: handlerListExpr,
      memberName: "delete"
    ),
    args: @[findCall]
  )

proc transformEventInvocation*(node: XLangNode): XLangNode =
  ## Transform event invocation to foreach loop
  ##
  ## C#: Event?.Invoke(args) or Event(args)
  ## Nim: for handler in eventHandlers: handler(args)

  if node.kind != xnkCallExpr:
    return node

  # Check if this is event invocation
  # Pattern: Event.Invoke(args) or Event(args) where Event is an event field
  var isEventInvoke = false
  var eventExpr: XLangNode

  if node.callee.kind == xnkMemberAccessExpr and node.callee.memberName == "Invoke":
    # Event.Invoke(args) pattern
    isEventInvoke = true
    eventExpr = node.callee.memberExpr
  elif node.callee.kind in {xnkIdentifier, xnkMemberAccessExpr}:
    # Might be direct event call Event(args)
    # Need metadata to determine if it's an event
    # For now, assume it is if it matches naming convention
    isEventInvoke = true
    eventExpr = node.callee

  if not isEventInvoke:
    return node

  # Determine handler list name
  var handlerListExpr: XLangNode
  if eventExpr.kind == xnkIdentifier:
    handlerListExpr = XLangNode(
      kind: xnkIdentifier,
      identName: eventExpr.identName & "Handlers"
    )
  elif eventExpr.kind == xnkMemberAccessExpr:
    handlerListExpr = XLangNode(
      kind: xnkMemberAccessExpr,
      memberExpr: eventExpr.memberExpr,
      memberName: eventExpr.memberName & "Handlers"
    )
  else:
    return node

  # Build: for handler in handlerList: handler(args)
  let handlerVar = XLangNode(kind: xnkIdentifier, identName: "handler")

  let handlerCall = XLangNode(
    kind: xnkCallExpr,
    callee: handlerVar,
    args: node.args
  )

  result = XLangNode(
    kind: xnkForeachStmt,
    foreachVar: handlerVar,
    foreachIter: handlerListExpr,
    foreachBody: XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[handlerCall]
    )
  )

# Multicast delegates
# C# events are multicast delegates by default
# Nim doesn't have this built-in, so we use seq[proc]

# Action and Func delegates (C# built-in)
# Action<T> → proc(x: T)
# Func<T, R> → proc(x: T): R

proc transformActionFunc*(node: XLangNode): XLangNode =
  ## Transform C# Action and Func to Nim proc types
  ##
  ## C#: Action<int, string> → Nim: proc(a: int, b: string)
  ## C#: Func<int, string> → Nim: proc(a: int): string

  if node.kind != xnkGenericType:
    return node

  var baseName = ""
  if node.genericBase != none(XLangNode) and node.genericBase.get.kind == xnkNamedType:
    baseName = node.genericBase.get.typeName
  elif node.genericTypeName != "":
    baseName = node.genericTypeName

  if baseName == "Action":
    # Action<T1, T2, ...> → proc(a1: T1, a2: T2, ...)
    var params: seq[XLangNode] = @[]
    for i, argType in node.genericArgs:
      params.add(XLangNode(
        kind: xnkParameter,
        paramName: "arg" & $i,
        paramType: some(argType),
        defaultValue: none(XLangNode)
      ))

    return XLangNode(
      kind: xnkFuncType,
      funcParams: params,
      funcReturnType: none(XLangNode)  # void
    )

  elif baseName == "Func":
    # Func<T1, T2, ..., TResult> → proc(a1: T1, a2: T2, ...): TResult
    # Last type arg is return type
    if node.genericArgs.len == 0:
      return node

    let returnType = node.genericArgs[^1]
    var params: seq[XLangNode] = @[]

    for i in 0..<(node.genericArgs.len - 1):
      params.add(XLangNode(
        kind: xnkParameter,
        paramName: "arg" & $i,
        paramType: some(node.genericArgs[i]),
        defaultValue: none(XLangNode)
      ))

    return XLangNode(
      kind: xnkFuncType,
      funcParams: params,
      funcReturnType: some(returnType)
    )

  return node

# Main transformation
proc transformCSharpEvents*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Main event/delegate transformation

  case node.kind
  of xnkDelegateDecl:
    return transformDelegate(node)

  of xnkExternal_Event:
    return transformEventDeclaration(node)

  of xnkBinaryExpr:
    # Event subscription/unsubscription
    if node.binaryOp == "+=":
      return transformEventSubscription(node)
    elif node.binaryOp == "-=":
      return transformEventUnsubscription(node)

  of xnkCallExpr:
    # Event invocation
    return transformEventInvocation(node)

  of xnkGenericType:
    # Action/Func transformation
    return transformActionFunc(node)

  else:
    discard

  return node
