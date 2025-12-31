## Python Generator to Nim Iterator Transformation
##
## Transforms Python generator functions (using yield) to Nim iterators
##
## Python:
##   def fibonacci():
##     a, b = 0, 1
##     while True:
##       yield a
##       a, b = b, a + b
##
## Nim:
##   iterator fibonacci(): int =
##     var a = 0
##     var b = 1
##     while true:
##       yield a
##       let temp = b
##       b = a + b
##       a = temp

import core/xlangtypes
import transforms/transform_context
import options
import strutils

proc isGeneratorFunction(node: XLangNode): bool =
  ## Check if function contains yield statements, making it a generator
  if node.kind notin {xnkFuncDecl, xnkMethodDecl}:
    return false

  proc hasYield(n: XLangNode): bool =
    case n.kind
    of xnkIteratorYield, xnkYieldStmt, xnkYieldExpr:  # Include legacy for now
      return true
    of xnkBlockStmt:
      for stmt in n.blockBody:
        if hasYield(stmt):
          return true
    of xnkIfStmt:
      if hasYield(n.ifBody):
        return true
      if n.elseBody.isSome and hasYield(n.elseBody.get):
        return true
    of xnkWhileStmt, xnkDoWhileStmt:
      return hasYield(n.whileBody)
    of xnkExternal_ForStmt:
      if n.extForBody.isSome:
        return hasYield(n.extForBody.get)
      else:
        return false
    of xnkForeachStmt:
      return hasYield(n.foreachBody)
    else:
      discard
    return false

  return hasYield(node.body)

proc transformPythonGenerator*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform Python generator functions to Nim iterators
  ##
  ## Key differences:
  ## - Python: def name(): yield x → Nim: iterator name(): T = yield x
  ## - Python generators are lazy and stateful
  ## - Nim iterators are inline by default (can use {.closure.} for heap-based)

  if not isGeneratorFunction(node):
    return node

  # Transform function to iterator
  # In Python, generators return generator objects
  # In Nim, iterators are first-class

  # Determine return type from yield statements
  # For now, we'll keep the declared return type or infer from first yield

  result = XLangNode(
    kind: xnkIteratorDecl,
    iteratorName: node.funcName,
    iteratorParams: node.params,
    iteratorReturnType: node.returnType,
    iteratorBody: node.body
  )

  # Note: Python generators can:
  # 1. yield values (simple case, maps to Nim iterator)
  # 2. send values (generator.send(value)) - needs closure iterator
  # 3. throw exceptions (generator.throw(exc)) - complex
  #
  # For send/throw support, we'd need closure iterators:
  # iterator name(): T {.closure.} = ...

# Generator expressions (different from generator functions)
# Python: (x**2 for x in range(10))
# These are similar to list comprehensions but lazy

proc transformGeneratorExpression*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform Python generator expressions to Nim iterators
  ##
  ## Python: squares = (x**2 for x in range(10))
  ## Nim: iterator squares(): int = (for x in 0..<10: yield x * x)

  if node.kind != xnkExternal_Generator:
    return node

  # Generator expressions are inline iterators
  # Similar to list comprehensions but don't build a list

  # Build iterator body similar to list comprehension transformation
  # but with yield instead of result.add

  # For now, return as-is - full implementation would build iterator
  result = node

# Async generators (Python 3.6+)
# async def gen():
#   yield value
#
# These combine async and generators
# In Nim, you can't have async iterators directly
# Would need to return AsyncIterator or use channels

proc transformAsyncGenerator*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform Python async generators
  ##
  ## Python async generators are complex to map to Nim
  ## Options:
  ## 1. Use channels with async
  ## 2. Use custom AsyncIterator type
  ## 3. Convert to proc that returns seq[Future[T]]

  if not (node.isAsync and isGeneratorFunction(node)):
    return node

  # This is an async generator
  # For now, document that this needs manual handling
  # A full implementation would create a channel-based solution

  result = node

# Helper: Transform yield from (Python 3.3+)
# yield from iterable → delegates to sub-iterator
# In Nim: for item in iterable: yield item

proc transformYieldFrom*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform Python's yield from to explicit iteration
  ##
  ## Python: yield from other_generator()
  ## Nim: for item in other_generator(): yield item

  # Handle both new and legacy forms
  if node.kind notin {xnkIteratorDelegate, xnkYieldFromStmt}:
    return node

  let delegateExpr = if node.kind == xnkIteratorDelegate:
    node.iteratorDelegateExpr
  else:
    node.yieldFromExpr

  # Build for loop that yields each item
  result = XLangNode(
    kind: xnkForeachStmt,
    foreachVar: XLangNode(kind: xnkIdentifier, identName: "item"),
    foreachIter: delegateExpr,
    foreachBody: XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[
        XLangNode(
          kind: xnkIteratorYield,
          iteratorYieldValue: some(XLangNode(kind: xnkIdentifier, identName: "item"))
        )
      ]
    )
  )
