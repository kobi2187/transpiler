## Transformation Pass Manager
##
## Orchestrates multiple transformation passes on XLang AST
## to lower constructs and make code more idiomatic for the target language.

import ../../xlangtypes
import ../lang_capabilities
import ../error_handling
import options
import tables
import strutils

type
  TransformPassID* = enum
    ## Unique identifier for each transformation pass
    ## Used for dependency tracking
    tpNone = "none"
    tpForToWhile = "for-to-while"
    tpDoWhileToWhile = "dowhile-to-while"
    tpTernaryToIf = "ternary-to-if"
    tpInterfaceToConcept = "interface-to-concept"
    tpPropertyToProcs = "property-to-procs"
    tpSwitchFallthrough = "switch-fallthrough"
    tpNullCoalesce = "null-coalesce"
    tpMultipleCatch = "multiple-catch"
    tpDestructuring = "destructuring"
    tpListComprehension = "list-comprehension"
    tpNormalizeSimple = "normalize-simple"
    tpStringInterpolation = "string-interpolation"
    tpWithToDefer = "with-to-defer"
    tpAsyncNormalization = "async-normalization"
    tpUnionToVariant = "union-to-variant"
    tpLinqToSequtils = "linq-to-sequtils"
    tpOperatorOverload = "operator-overload"
    tpPatternMatching = "pattern-matching"
    tpDecoratorAttribute = "decorator-attribute"
    tpExtensionMethods = "extension-methods"
    tpGoErrorHandling = "go-error-handling"
    tpGoDefer = "go-defer"
    tpCSharpUsing = "csharp-using"
    tpGoConcurrency = "go-concurrency"
    # Add more passes here as they are implemented

  TransformPassKind* = enum
    ## Different kinds of transformation passes
    tpkLowering      ## Lower high-level constructs to simpler ones
    tpkOptimization  ## Optimize code patterns
    tpkNormalization ## Normalize to idiomatic patterns
    tpkValidation    ## Validate AST structure

  TransformPass* = ref object
    ## A single transformation pass
    id*: TransformPassID         ## Unique identifier
    name*: string
    kind*: TransformPassKind
    description*: string
    enabled*: bool
    dependencies*: seq[TransformPassID]  ## Passes that must run before this one
    transform*: proc(node: XLangNode): XLangNode

  PassManager* = ref object
    ## Manages and executes transformation passes
    passes*: seq[TransformPass]
    maxIterations*: int  ## Maximum number of times to run all passes
    config*: Table[string, bool]  ## Configuration for conditional passes
    targetLang*: LangCapabilities  ## Target language capabilities
    errorCollector*: ErrorCollector  ## Collect errors during transformation

proc newTransformPass*(
  id: TransformPassID,
  name: string,
  kind: TransformPassKind,
  description: string,
  transform: proc(node: XLangNode): XLangNode,
  dependencies: seq[TransformPassID] = @[]
): TransformPass =
  ## Create a new transformation pass with dependency tracking
  TransformPass(
    id: id,
    name: name,
    kind: kind,
    description: description,
    enabled: true,
    dependencies: dependencies,
    transform: transform
  )

proc newPassManager*(targetLang: string = "nim", maxIterations: int = 10,
                     errorCollector: ErrorCollector = nil): PassManager =
  ## Create a new pass manager for a target language
  PassManager(
    passes: @[],
    maxIterations: maxIterations,
    config: initTable[string, bool](),
    targetLang: getCapabilities(targetLang),
    errorCollector: if errorCollector != nil: errorCollector else: newErrorCollector()
  )

proc addPass*(pm: PassManager, pass: TransformPass) =
  ## Add a transformation pass to the manager
  pm.passes.add(pass)

proc enablePass*(pm: PassManager, passName: string) =
  ## Enable a specific pass by name
  for pass in pm.passes:
    if pass.name == passName:
      pass.enabled = true
      return

proc disablePass*(pm: PassManager, passName: string) =
  ## Disable a specific pass by name
  for pass in pm.passes:
    if pass.name == passName:
      pass.enabled = false
      return

proc applyPass(pass: TransformPass, node: XLangNode): XLangNode =
  ## Apply a single pass recursively to an AST node
  if not pass.enabled:
    return node

  # Apply transformation to current node
  result = pass.transform(node)

  # Recursively apply to children based on node kind
  case result.kind
  of xnkFile, xnkModule, xnkNamespace:
    if result.children.len > 0:
      var newChildren: seq[XLangNode] = @[]
      for child in result.children:
        newChildren.add(applyPass(pass, child))
      result.children = newChildren

  of xnkBlockStmt:
    if result.blockBody.len > 0:
      var newBody: seq[XLangNode] = @[]
      for stmt in result.blockBody:
        newBody.add(applyPass(pass, stmt))
      result.blockBody = newBody

  of xnkIfStmt:
    result.ifCondition = applyPass(pass, result.ifCondition)
    result.ifBody = applyPass(pass, result.ifBody)
    if result.elseBody.isSome:
      result.elseBody = some(applyPass(pass, result.elseBody.get))

  of xnkWhileStmt:
    result.whileCondition = applyPass(pass, result.whileCondition)
    result.whileBody = applyPass(pass, result.whileBody)

  of xnkForeachStmt:
    result.foreachVar = applyPass(pass, result.foreachVar)
    result.foreachIter = applyPass(pass, result.foreachIter)
    result.foreachBody = applyPass(pass, result.foreachBody)

  of xnkForStmt:
    if result.forInit.isSome:
      result.forInit = some(applyPass(pass, result.forInit.get))
    if result.forCond.isSome:
      result.forCond = some(applyPass(pass, result.forCond.get))
    if result.forIncrement.isSome:
      result.forIncrement = some(applyPass(pass, result.forIncrement.get))
    result.forBody = applyPass(pass, result.forBody)

  of xnkSwitchStmt:
    result.switchExpr = applyPass(pass, result.switchExpr)
    if result.switchCases.len > 0:
      var newCases: seq[XLangNode] = @[]
      for case_node in result.switchCases:
        newCases.add(applyPass(pass, case_node))
      result.switchCases = newCases

  of xnkTryStmt:
    result.tryBody = applyPass(pass, result.tryBody)
    if result.catchClauses.len > 0:
      var newCatches: seq[XLangNode] = @[]
      for catch_node in result.catchClauses:
        newCatches.add(applyPass(pass, catch_node))
      result.catchClauses = newCatches
    if result.finallyClause.isSome:
      result.finallyClause = some(applyPass(pass, result.finallyClause.get))

  of xnkFuncDecl, xnkMethodDecl:
    result.body = applyPass(pass, result.body)
    if result.params.len > 0:
      var newParams: seq[XLangNode] = @[]
      for param in result.params:
        newParams.add(applyPass(pass, param))
      result.params = newParams

  of xnkBinaryExpr:
    result.binaryLeft = applyPass(pass, result.binaryLeft)
    result.binaryRight = applyPass(pass, result.binaryRight)

  of xnkUnaryExpr:
    result.unaryOperand = applyPass(pass, result.unaryOperand)

  of xnkCallExpr:
    result.callee = applyPass(pass, result.callee)
    if result.args.len > 0:
      var newArgs: seq[XLangNode] = @[]
      for arg in result.args:
        newArgs.add(applyPass(pass, arg))
      result.args = newArgs

  of xnkReturnStmt:
    if result.returnExpr.isSome:
      result.returnExpr = some(applyPass(pass, result.returnExpr.get))

  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    if result.initializer.isSome:
      result.initializer = some(applyPass(pass, result.initializer.get))

  else:
    # For other node types, return as-is
    discard

proc detectCircularDependencies*(pm: PassManager): seq[string] =
  ## Detect circular dependencies in passes using hashtable method
  ## Returns list of error messages, empty if no cycles found
  result = @[]

  # Build dependency map
  var depMap = initTable[TransformPassID, seq[TransformPassID]]()
  for pass in pm.passes:
    if pass.enabled:
      depMap[pass.id] = pass.dependencies

  # Track visited nodes and recursion stack
  var visited = initTable[TransformPassID, bool]()
  var recStack = initTable[TransformPassID, bool]()

  proc hasCycle(passID: TransformPassID, path: seq[TransformPassID]): bool =
    # Mark current node as visited and add to recursion stack
    visited[passID] = true
    recStack[passID] = true

    # Check all dependencies
    if depMap.hasKey(passID):
      for dep in depMap[passID]:
        if not visited.getOrDefault(dep, false):
          # Recurse on unvisited dependency
          if hasCycle(dep, path & @[passID]):
            return true
        elif recStack.getOrDefault(dep, false):
          # Found a cycle!
          var cyclePath = path & @[passID, dep]
          var cycleStr = ""
          for i, id in cyclePath:
            if i > 0:
              cycleStr &= " → "
            cycleStr &= $id
          result.add("Circular dependency detected: " & cycleStr)
          return true

    # Remove from recursion stack
    recStack[passID] = false
    return false

  # Check each pass as potential cycle start
  for pass in pm.passes:
    if pass.enabled and not visited.getOrDefault(pass.id, false):
      discard hasCycle(pass.id, @[])

proc getPassExecutionOrder*(pm: PassManager): seq[TransformPass] =
  ## Determine pass execution order based on dependencies
  ## Returns passes ordered bottom-up from dependency tree (leaves first)
  result = @[]

  # Build pass lookup table
  var passTable = initTable[TransformPassID, TransformPass]()
  for pass in pm.passes:
    if pass.enabled:
      passTable[pass.id] = pass

  # Track which passes have been added
  var added = initTable[TransformPassID, bool]()

  proc addPassWithDeps(passID: TransformPassID) =
    # Skip if already added
    if added.getOrDefault(passID, false):
      return

    # Skip if pass not found (could be disabled)
    if not passTable.hasKey(passID):
      return

    let pass = passTable[passID]

    # First add all dependencies
    for dep in pass.dependencies:
      addPassWithDeps(dep)

    # Then add this pass
    result.add(pass)
    added[passID] = true

  # Add all enabled passes in dependency order
  for pass in pm.passes:
    if pass.enabled:
      addPassWithDeps(pass.id)

proc runPassUntilConvergence(pm: PassManager, pass: TransformPass, ast: XLangNode): XLangNode =
  ## Run a single pass repeatedly until it no longer makes changes
  ## This ensures the construct the pass transforms completely disappears
  result = ast
  var iteration = 0

  while iteration < pm.maxIterations:
    let before = $result
    result = applyPass(pass, result)
    let after = $result

    if before == after:
      # No more changes, pass has converged
      break

    iteration += 1

proc runPasses*(pm: PassManager, ast: XLangNode): XLangNode =
  ## Run all enabled passes on the AST in dependency order
  ## Each pass runs until convergence before moving to next
  result = ast

  # Check for circular dependencies
  let cycles = pm.detectCircularDependencies()
  if cycles.len > 0:
    # Collect all circular dependency errors
    for cycle in cycles:
      pm.errorCollector.addError(
        tekTransformError,
        cycle,
        location = "Pass dependency graph"
      )
    # Exit immediately on circular dependencies
    pm.errorCollector.reportAndExit()

  # Get passes in execution order (dependency-respecting)
  let orderedPasses = pm.getPassExecutionOrder()

  # Run each pass until convergence
  for pass in orderedPasses:
    try:
      result = pm.runPassUntilConvergence(pass, result)
    except Exception as e:
      pm.errorCollector.addError(
        tekTransformError,
        "Pass '" & pass.name & "' failed: " & e.msg,
        location = $pass.id,
        details = e.getStackTrace()
      )
      # Continue to try other passes to collect more errors
      # But mark that we had a critical failure

  # If any errors occurred, report and exit
  if pm.errorCollector.hasErrors():
    pm.errorCollector.reportAndExit()

proc listPasses*(pm: PassManager): seq[string] =
  ## List all registered passes with their status
  result = @[]
  for pass in pm.passes:
    let status = if pass.enabled: "✓" else: "✗"
    result.add("[" & status & "] " & pass.name & " (" & $pass.kind & "): " & pass.description)

proc getStats*(pm: PassManager): tuple[total: int, enabled: int, disabled: int] =
  ## Get statistics about registered passes
  result.total = pm.passes.len
  result.enabled = 0
  result.disabled = 0
  for pass in pm.passes:
    if pass.enabled:
      result.enabled += 1
    else:
      result.disabled += 1
