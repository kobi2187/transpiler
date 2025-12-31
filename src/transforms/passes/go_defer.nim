## Go Defer Statement Normalization
##
## Transforms Go's defer to Nim's defer
##
## Go defer executes at function exit (not block exit), and is LIFO ordered:
##   func example() {
##     defer fmt.Println("world")
##     defer fmt.Println("hello")
##     // do work
##   }
##   // Output: "hello" then "world" (LIFO)
##
## Nim's defer executes at scope exit and is also LIFO:
##   proc example() =
##     defer: echo "world"
##     defer: echo "hello"
##     # do work
##   # Output: "hello" then "world" (LIFO)
##
## The main difference:
## - Go defer: executes at function exit
## - Nim defer: executes at scope/block exit
##
## For top-level function defers, they're equivalent.
## For defers inside nested blocks, we need to track scope.

import ../../../xlangtypes
import ../../semantic/semantic_analysis
import options

proc transformGoDefer*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform Go defer statements to Nim defer
  ##
  ## Go and Nim defer are very similar, main differences:
  ## 1. Go evaluates defer arguments immediately, Nim evaluates at defer execution
  ## 2. Both are LIFO ordered
  ## 3. Go defers execute at function exit, Nim at scope exit

  if node.kind != xnkDeferStmt:
    return node

  # In most cases, Go defer → Nim defer is direct
  # The XLang AST already has xnkDeferStmt with staticBody
  # which contains the statement to defer

  # Nim's defer syntax: defer: statement
  # Go's defer syntax: defer statement

  # Direct mapping works for most cases
  result = node

  # Note: One edge case is Go's defer with arguments evaluated immediately:
  # Go:
  #   x := 5
  #   defer fmt.Println(x)  # Captures x=5
  #   x = 10
  #   // Prints 5, not 10
  #
  # Nim:
  #   var x = 5
  #   defer: echo x  # Captures x reference
  #   x = 10
  #   # Prints 10, not 5
  #
  # To handle this, we'd need to:
  # 1. Detect function calls in defer
  # 2. Evaluate arguments immediately and store in temp variables
  # 3. Use temp variables in defer
  #
  # For now, we'll document this difference and handle it in documentation

# Helper to transform defers inside nested blocks
# In Go, defer always executes at function exit
# In Nim, defer executes at current scope exit
# We need to move defers to function level if they're in nested scopes

proc collectDefers(node: XLangNode): seq[XLangNode] =
  ## Recursively collect all defer statements from nested blocks
  result = @[]

  case node.kind
  of xnkDeferStmt:
    result.add(node)

  of xnkBlockStmt:
    for stmt in node.blockBody:
      for d in collectDefers(stmt):
        result.add(d)

  of xnkIfStmt:
    for d in collectDefers(node.ifBody): result.add(d)
    if node.elseBody.isSome:
      for d in collectDefers(node.elseBody.get): result.add(d)

  of xnkWhileStmt, xnkDoWhileStmt:
    for d in collectDefers(node.whileBody): result.add(d)

  of xnkExternal_ForStmt:
    if node.extForBody.isSome:
      for d in collectDefers(node.extForBody.get): result.add(d)

  of xnkForeachStmt:
    for d in collectDefers(node.foreachBody): result.add(d)

  of xnkSwitchStmt:
    for caseNode in node.switchCases:
      if caseNode.kind == xnkCaseClause:
        for d in collectDefers(caseNode.caseBody): result.add(d)
      elif caseNode.kind == xnkDefaultClause:
        for d in collectDefers(caseNode.defaultBody): result.add(d)

  else:
    discard

proc hoistDefersToFunctionLevel*(funcNode: XLangNode): XLangNode =
  ## Hoist defers from nested scopes to function level
  ## to match Go's behavior where defer executes at function exit
  ##
  ## This is a complex transformation that changes semantics,
  ## so we'll only apply it when specifically requested
  ## or when we detect Go-specific patterns

  if funcNode.kind notin {xnkFuncDecl, xnkMethodDecl}:
    return funcNode

  # Collect all defers in the function body
  let defers = collectDefers(funcNode.body)

  if defers.len == 0:
    return funcNode

  # For now, keep defers in place
  # A full implementation would:
  # 1. Remove defers from nested scopes
  # 2. Add them at function level
  # 3. Handle conditional defers properly
  # This is complex and may change program semantics

  result = funcNode
