## List Comprehension Transformation
##
## Transforms: [expr for x in iter if cond] → loop with filter and collect
## Python-style list comprehensions to Nim for loops
##
## Example:
## [x**2 for x in range(10) if x % 2 == 0]
## →
## block:
##   var result: seq[T] = @[]
##   for x in 0..<10:
##     if x mod 2 == 0:
##       result.add(x * x)
##   result

import ../../xlangtypes
import options
import strutils

var comprehensionCounter {.compileTime.}: int = 0

proc genUniqueName(prefix: string): string =
  ## Generate unique variable name for comprehension results
  comprehensionCounter += 1
  result = prefix & $comprehensionCounter

proc transformListComprehension*(node: XLangNode): XLangNode =
  ## Transform list comprehensions into for loops with collection
  if node.kind != xnkComprehensionExpr:
    return node

  # [expr for var in iter if cond]
  # Transform to:
  # block:
  #   var result: seq[T] = @[]
  #   for var in iter:
  #     if cond:
  #       result.add(expr)
  #   result

  let resultVar = genUniqueName("compResult")

  # Start with the innermost expression: result.add(expr)
  let addCall = XLangNode(
    kind: xnkCallExpr,
    callee: XLangNode(
      kind: xnkMemberAccessExpr,
      memberExpr: XLangNode(kind: xnkIdentifier, identName: resultVar),
      memberName: "add"
    ),
    args: @[node.compExpr]
  )

  # Wrap in if statements for all conditions (from innermost out)
  var bodyStmt: XLangNode = addCall
  for condition in node.compIf:
    bodyStmt = XLangNode(
      kind: xnkIfStmt,
      ifCondition: condition,
      ifBody: XLangNode(kind: xnkBlockStmt, blockBody: @[bodyStmt]),
      elseBody: none(XLangNode)
    )

  # Build nested for loops (from innermost out)
  # Python allows: [x+y for x in a for y in b]
  # Process in reverse order so innermost is built first
  for i in countdown(node.compFor.len - 1, 0):
    let (vars, iter) = node.compFor[i]

    # For single variable: for x in iter
    if vars.len == 1 and vars[0].kind == xnkIdentifier:
      bodyStmt = XLangNode(
        kind: xnkForeachStmt,
        foreachVar: vars[0],
        foreachIter: iter,
        foreachBody: XLangNode(kind: xnkBlockStmt, blockBody: @[bodyStmt])
      )
    else:
      # Multiple variables: for (a, b) in iter - use tuple unpacking
      # Create a temp var and unpack inside loop
      let tempVar = genUniqueName("temp")
      var unpackStmts: seq[XLangNode] = @[]

      for j, varNode in vars:
        if varNode.kind == xnkIdentifier:
          unpackStmts.add(XLangNode(
            kind: xnkLetDecl,
            declName: varNode.identName,
            declType: none(XLangNode),
            initializer: some(XLangNode(
              kind: xnkIndexExpr,
              indexExpr: XLangNode(kind: xnkIdentifier, identName: tempVar),
              indexArgs: @[XLangNode(kind: xnkIntLit, literalValue: $j)]
            ))
          ))

      unpackStmts.add(bodyStmt)

      bodyStmt = XLangNode(
        kind: xnkForeachStmt,
        foreachVar: XLangNode(kind: xnkIdentifier, identName: tempVar),
        foreachIter: iter,
        foreachBody: XLangNode(kind: xnkBlockStmt, blockBody: unpackStmts)
      )

  # Wrap everything in block with result variable declaration
  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: @[
      # var result: seq[T] = @[]
      XLangNode(
        kind: xnkVarDecl,
        declName: resultVar,
        declType: none(XLangNode),  # Type inference will handle it
        initializer: some(XLangNode(
          kind: xnkListExpr,
          elements: @[]  # Empty list literal @[]
        ))
      ),
      # The for loop(s) with conditions
      bodyStmt,
      # Return the result
      XLangNode(kind: xnkIdentifier, identName: resultVar)
    ]
  )
