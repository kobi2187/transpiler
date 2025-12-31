## Lambda Expression Normalization
##
## Normalizes lambda/anonymous function syntax from various languages to Nim procs
##
## Python: lambda x, y: x + y
## JavaScript: (x, y) => x + y
## C#: (x, y) => x + y
## Java: (x, y) -> x + y
## Go: func(x, y int) int { return x + y }
##
## Nim: proc(x, y: int): int = x + y

import core/xlangtypes
import semantic/semantic_analysis
import options
import strutils

proc transformLambda*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform lambda expressions to Nim anonymous procs

  if node.kind != xnkLambdaExpr:
    return node

  # Lambda structure:
  # - lambdaParams: parameter list
  # - lambdaBody: expression or statement block
  # - lambdaReturnType: optional return type

  let params = node.lambdaParams
  let body = node.lambdaBody
  let returnType = node.lambdaReturnType

  # In Nim, lambdas are anonymous procs
  # proc(params): RetType = body

  # Determine if body is expression or statements
  var procBody: XLangNode

  if body.kind == xnkBlockStmt:
    # Multi-statement lambda (unusual in Python/JS, common in C#/Java)
    procBody = body
  else:
    # Single expression - wrap in block with implicit return
    # In Nim, last expression is returned
    procBody = XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[body]
    )

  # Create anonymous proc
  result = XLangNode(
    kind: xnkLambdaProc,  # Special node for inline proc
    lambdaProcParams: params,
    lambdaProcReturn: returnType,
    lambdaProcBody: procBody
  )

# Arrow functions with implicit return (JavaScript, C#)
# x => x * 2  vs  x => { return x * 2; }

proc transformArrowFunction*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform arrow functions with special handling for implicit return
  ##
  ## JS: x => x * 2  (expression body, implicit return)
  ## JS: x => { return x * 2; }  (block body, explicit return)

  if node.kind != xnkArrowFunc:
    return node

  # Similar to lambda but may have implicit return
  # If body is expression, it's an implicit return

  let params = node.arrowParams
  let body = node.arrowBody
  let isExpressionBody = body.kind != xnkBlockStmt

  var procBody: XLangNode

  if isExpressionBody:
    # Expression body - implicit return
    # x => x * 2  means  x => { return x * 2; }
    procBody = XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[
        XLangNode(
          kind: xnkReturnStmt,
          returnExpr: some(body)
        )
      ]
    )
  else:
    # Block body - explicit returns already present
    procBody = body

  result = XLangNode(
    kind: xnkLambdaProc,
    lambdaProcParams: params,
    lambdaProcReturn: none(XLangNode),  # Usually inferred
    lambdaProcBody: procBody
  )

# Closure handling
# Many languages have closures that capture variables
# Nim supports closures with {.closure.} pragma

proc markAsClosure*(node: XLangNode): XLangNode =
  ## Mark lambda as closure if it captures variables
  ##
  ## This requires analysis of variable usage
  ## For now, we'll mark all lambdas as potential closures

  if node.kind != xnkLambdaProc:
    return node

  # In Nim, if a proc is passed as a value or captures variables,
  # it needs {.closure.} pragma
  # For transpiler, we can be conservative and always use closure

  # Add closure pragma (would need pragma support in XLang)
  result = node  # Would add pragma metadata

# Java method references
# Class::method → Nim proc reference

proc transformMethodReference*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform Java method references to Nim proc references
  ##
  ## Java: list.forEach(System.out::println)
  ## Nim: list.forEach(proc(x: T) = echo x)
  ##
  ## Method references are syntactic sugar for lambdas

  if node.kind != xnkMethodReference:
    return node

  # Method reference: object::method
  let objectExpr = node.refObject
  let methodName = node.refMethod

  # Create lambda that calls the method
  # This needs parameter information which we may not have
  # Simplified: create proc reference

  result = XLangNode(
    kind: xnkMemberAccessExpr,
    memberExpr: objectExpr,
    memberName: methodName
  )

# Python functools.partial → Nim partial application

proc transformPartialApplication*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform partial function application
  ##
  ## Python: partial(func, arg1, arg2)
  ## Nim: proc(remaining_args) = func(arg1, arg2, remaining_args)

  if node.kind != xnkCallExpr:
    return node

  # Check if this is a partial() call
  if node.callee.kind == xnkIdentifier and node.callee.identName == "partial":
    # partial(func, fixed_args...) → lambda with fixed args

    if node.args.len < 1:
      return node

    let funcExpr = node.args[0]
    let fixedArgs = node.args[1..^1]

    # Create lambda that applies fixed args
    # This needs signature information
    # Simplified version for now

    result = node  # Would create proper lambda
  else:
    result = node

# Default parameters in lambdas (Python, JavaScript ES6)
# lambda x, y=10: x + y

proc transformLambdaDefaults*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform lambda with default parameters
  ##
  ## Python: lambda x, y=10: x + y
  ## Nim: proc(x: int, y: int = 10): int = x + y

  if node.kind != xnkLambdaExpr:
    return node

  # Default parameters are in the parameter declarations
  # Already handled by parameter transformation
  # Just ensure they're preserved

  result = transformLambda(node, semanticInfo)

# Rest parameters in lambdas (JavaScript, Python)
# (...args) => args.length  or  lambda *args: len(args)

proc transformRestParameters*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform rest/varargs parameters in lambdas
  ##
  ## JS: (...args) => args.length
  ## Python: lambda *args: len(args)
  ## Nim: proc(args: varargs[T]): int = args.len

  if node.kind notin {xnkLambdaExpr, xnkArrowFunc}:
    return node

  # Check for rest/varargs parameter
  # These would be marked in parameter declarations
  # Transform to Nim's varargs

  result = node  # Parameters already transformed

# IIFE (Immediately Invoked Function Expression)
# JavaScript: (function() { ... })()
# Transform to Nim block

proc transformIIFE*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform IIFE to Nim block
  ##
  ## JS: (function() { var x = 1; return x * 2; })()
  ## Nim: block: var x = 1; x * 2

  if node.kind != xnkCallExpr:
    return node

  # Check if calling a lambda/anonymous function
  if node.callee.kind in {xnkLambdaExpr, xnkArrowFunc, xnkLambdaProc}:
    # This is IIFE
    let lambda = node.callee

    # Extract lambda body and convert to block
    var bodyStmts: seq[XLangNode] = @[]

    if lambda.kind == xnkLambdaExpr:
      if lambda.lambdaBody.kind == xnkBlockStmt:
        bodyStmts = lambda.lambdaBody.blockBody
      else:
        bodyStmts = @[lambda.lambdaBody]
    elif lambda.kind == xnkArrowFunc:
      if lambda.arrowBody.kind == xnkBlockStmt:
        bodyStmts = lambda.arrowBody.blockBody
      else:
        bodyStmts = @[lambda.arrowBody]

    # Create block statement
    result = XLangNode(
      kind: xnkBlockStmt,
      blockBody: bodyStmts
    )
  else:
    result = node

# Main transformation
proc transformLambdaNormalization*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Main lambda normalization transformation

  case node.kind
  of xnkLambdaExpr:
    return transformLambda(node, semanticInfo)

  of xnkArrowFunc:
    return transformArrowFunction(node, semanticInfo)

  of xnkMethodReference:
    return transformMethodReference(node, semanticInfo)

  of xnkCallExpr:
    # Check for IIFE or partial application
    let iife = transformIIFE(node, semanticInfo)
    if iife.kind != xnkCallExpr:
      return iife
    return transformPartialApplication(node, semanticInfo)

  else:
    return node
