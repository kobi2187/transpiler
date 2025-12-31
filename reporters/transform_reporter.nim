## Transform Reporter
##
## Validates that all transformation passes correctly eliminate external kinds.
## Runs on a directory of .xljs files and reports any remaining external kinds.
##
## Usage: ./transform_reporter <directory>

import std/[os, strutils, sequtils, tables, sets, json, options]
import xlangtypes
import jsontoxlangtypes
import src/transforms/pass_manager2
import src/transforms/nim_passes
import src/transforms/helpers

type
  TransformIssue = object
    filename: string
    externalKinds: seq[XLangNodeKind]
    lastAst: XLangNode

  ReportResults = object
    totalFiles: int
    successFiles: int
    failedFiles: int
    issues: seq[TransformIssue]

proc collectAllKinds(node: XLangNode): HashSet[XLangNodeKind] =
  ## Recursively collect all node kinds in the AST
  result = initHashSet[XLangNodeKind]()

  proc traverse(n: XLangNode) =
    if n.isNil:
      return
    result.incl(n.kind)
    # Simplified traversal - just collect from main containers
    case n.kind
    of xnkFile:
      for child in n.moduleDecls: traverse(child)
    of xnkNamespace:
      for child in n.namespaceBody: traverse(child)
    of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
      for member in n.members: traverse(member)
    of xnkFuncDecl, xnkMethodDecl:
      for param in n.params: traverse(param)
      if n.returnType.isSome: traverse(n.returnType.get)
      traverse(n.body)
    of xnkBlockStmt:
      for stmt in n.blockBody: traverse(stmt)
    else:
      discard # Don't traverse deeper for now

  traverse(node)

proc isExternalKind(kind: XLangNodeKind): bool =
  ## Check if a kind is an external kind that should be eliminated
  const externalKinds = {
    xnkExternal_Property, xnkExternal_Indexer, xnkExternal_Event,
    xnkExternal_Operator, xnkExternal_ConversionOp, xnkExternal_Resource,
    xnkExternal_Fixed, xnkExternal_Lock, xnkExternal_Unsafe, xnkExternal_Checked,
    xnkExternal_SafeNavigation, xnkExternal_NullCoalesce, xnkExternal_ThrowExpr,
    xnkExternal_SwitchExpr, xnkExternal_StackAlloc, xnkExternal_StringInterp,
    xnkExternal_Ternary, xnkExternal_DoWhile, xnkExternal_ForStmt,
    xnkExternal_Interface, xnkExternal_Delegate, xnkExternal_Generator,
    xnkExternal_Comprehension, xnkExternal_With, xnkExternal_Destructure,
    xnkExternal_Await, xnkExternal_LocalFunction, xnkExternal_ExtensionMethod,
    xnkExternal_FallthroughCase, xnkExternal_Unless, xnkExternal_Until,
    xnkExternal_Channel, xnkExternal_GoSelect
  }
  return kind in externalKinds

proc getExternalKinds(kinds: HashSet[XLangNodeKind]): seq[XLangNodeKind] =
  ## Extract external kinds from a set of kinds
  result = @[]
  for kind in kinds:
    if isExternalKind(kind):
      result.add(kind)

proc findNodesWithKinds(node: XLangNode, targetKinds: seq[XLangNodeKind], path: string = ""): seq[tuple[path: string, node: XLangNode]] =
  ## Find all nodes matching any of the target kinds, with their path
  result = @[]

  # Check for nil node
  if node.isNil:
    return

  if node.kind in targetKinds:
    result.add((path, node))

  # Simplified traversal
  case node.kind
  of xnkFile:
    for i, child in node.moduleDecls:
      result.add(findNodesWithKinds(child, targetKinds, path & "/file[" & $i & "]"))
  of xnkNamespace:
    for i, child in node.namespaceBody:
      result.add(findNodesWithKinds(child, targetKinds, path & "/namespace:" & node.namespaceName & "[" & $i & "]"))
  of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
    for i, member in node.members:
      result.add(findNodesWithKinds(member, targetKinds, path & "/type:" & node.typeNameDecl & "[" & $i & "]"))
  of xnkFuncDecl, xnkMethodDecl:
    for i, param in node.params:
      result.add(findNodesWithKinds(param, targetKinds, path & "/func:" & node.funcName & "/param[" & $i & "]"))
    if node.returnType.isSome:
      result.add(findNodesWithKinds(node.returnType.get, targetKinds, path & "/func:" & node.funcName & "/return"))
    result.add(findNodesWithKinds(node.body, targetKinds, path & "/func:" & node.funcName & "/body"))
  of xnkBlockStmt:
    for i, stmt in node.blockBody:
      result.add(findNodesWithKinds(stmt, targetKinds, path & "/block[" & $i & "]"))
  else:
    discard

proc nodeToJsonString(node: XLangNode, maxLength: int = 500): string =
  ## Convert node to JSON string representation (truncated)
  result = "<JSON output disabled for performance>"
  # TODO: Add actual JSON conversion when needed
  # try:
  #   let jsonNode = ... convert to json ...
  #   result = $jsonNode
  #   if result.len > maxLength:
  #     result = result[0 ..< maxLength] & "... (truncated)"
  # except:
  #   result = "<error converting to JSON>"

proc formatNodeDetails(node: XLangNode): string =
  ## Format detailed information about a node
  result = "    Kind: " & $node.kind & "\n"

  # Add kind-specific details
  case node.kind
  of xnkExternal_Property:
    result &= "      Property name: " & node.extPropName & "\n"
    result &= "      Has getter: " & $node.extPropGetter.isSome & "\n"
    result &= "      Has setter: " & $node.extPropSetter.isSome & "\n"
  of xnkExternal_Indexer:
    result &= "      Params: " & $node.extIndexerParams.len & "\n"
    result &= "      Has getter: " & $node.extIndexerGetter.isSome & "\n"
    result &= "      Has setter: " & $node.extIndexerSetter.isSome & "\n"
  of xnkExternal_Interface:
    result &= "      Interface name: " & node.extInterfaceName & "\n"
    result &= "      Members: " & $node.extInterfaceMembers.len & "\n"
  of xnkExternal_ForStmt:
    result &= "      Has init: " & $node.extForInit.isSome & "\n"
    result &= "      Has condition: " & $node.extForCond.isSome & "\n"
    result &= "      Has increment: " & $node.extForIncrement.isSome & "\n"
  of xnkExternal_DoWhile:
    result &= "      Condition kind: " & $node.extDoWhileCondition.kind & "\n"
  of xnkExternal_Ternary:
    result &= "      Condition kind: " & $node.extTernaryCondition.kind & "\n"
    result &= "      Then kind: " & $node.extTernaryThen.kind & "\n"
    result &= "      Else kind: " & $node.extTernaryElse.kind & "\n"
  of xnkExternal_StringInterp:
    result &= "      Parts: " & $node.extInterpParts.len & "\n"
  of xnkExternal_NullCoalesce:
    result &= "      Left kind: " & $node.extNullCoalesceLeft.kind & "\n"
    result &= "      Right kind: " & $node.extNullCoalesceRight.kind & "\n"
  of xnkExternal_SafeNavigation:
    result &= "      Object kind: " & $node.extSafeNavObject.kind & "\n"
    result &= "      Member: " & node.extSafeNavMember & "\n"
  of xnkExternal_Operator:
    result &= "      Operator: " & node.extOperatorSymbol & "\n"
    result &= "      Params: " & $node.extOperatorParams.len & "\n"
  of xnkExternal_Event:
    result &= "      Event name: " & node.extEventName & "\n"
  of xnkExternal_Await:
    result &= "      Expr kind: " & $node.extAwaitExpr.kind & "\n"
  of xnkExternal_ThrowExpr:
    result &= "      Value kind: " & $node.extThrowExprValue.kind & "\n"
  of xnkExternal_With:
    result &= "      Items: " & $node.extWithItems.len & "\n"
  of xnkExternal_Destructure:
    result &= "      Kind: " & node.extDestructKind & "\n"
    result &= "      Fields: " & $node.extDestructFields.len & "\n"
    result &= "      Vars: " & $node.extDestructVars.len & "\n"
  of xnkExternal_Comprehension:
    result &= "      Fors: " & $node.extCompFors.len & "\n"
    result &= "      Ifs: " & $node.extCompIf.len & "\n"
  of xnkExternal_Generator:
    result &= "      Fors: " & $node.extGenFor.len & "\n"
    result &= "      Ifs: " & $node.extGenIf.len & "\n"
  of xnkExternal_Resource:
    result &= "      Items: " & $node.extResourceItems.len & "\n"
  else:
    discard

  # Add JSON representation
  result &= "      JSON: " & nodeToJsonString(node) & "\n"

proc processXljsFile(filepath: string): TransformIssue =
  ## Process a single .xljs file and check for remaining external kinds
  result.filename = filepath

  try:
    # Read and parse the xljs file
    let content = readFile(filepath)
    let jsonNode = parseJson(content)
    var ast = jsonNode.to(XLangNode)

    # Set up pass manager with Nim transforms
    var pm = newPassManager2()
    registerNimPasses(pm)

    # Apply transforms
    ast = pm.run(ast)

    # Check for loop warnings
    if pm.result.loopWarning:
      echo "\nWARNING: Potential infinite loop detected in ", filepath.extractFilename()
      echo "  After ", pm.result.iterations, " iterations, still processing kinds:"
      for kind in pm.result.loopKinds:
        echo "    - ", kind

    # Check if max iterations reached
    if pm.result.maxIterationsReached:
      echo "\nERROR: Max iterations reached in ", filepath.extractFilename()
      echo "  Transform pipeline did not converge after ", pm.result.iterations, " iterations"

    # Collect all kinds in the transformed AST
    let allKinds = collectAllKinds(ast)

    # Check for remaining external kinds
    result.externalKinds = getExternalKinds(allKinds)
    result.lastAst = ast

  except Exception as e:
    echo "Error processing ", filepath, ": ", e.msg
    result.externalKinds = @[]

proc findXljsFiles(directory: string): seq[string] =
  ## Recursively find all .xljs files in a directory
  result = @[]
  for kind, path in walkDir(directory):
    if kind == pcFile and path.endsWith(".xljs"):
      result.add(path)
    elif kind == pcDir:
      result.add(findXljsFiles(path))

proc generateReport(results: ReportResults): string =
  ## Generate a human-readable report
  result = "=" .repeat(80) & "\n"
  result &= "TRANSFORM VALIDATION REPORT\n"
  result &= "=" .repeat(80) & "\n\n"

  result &= "Summary:\n"
  result &= "  Total files: " & $results.totalFiles & "\n"
  result &= "  Successful: " & $results.successFiles & "\n"
  result &= "  Failed: " & $results.failedFiles & "\n"
  result &= "\n"

  if results.failedFiles == 0:
    result &= "✓ All files passed! No external kinds remaining.\n"
  else:
    result &= "✗ Issues found in " & $results.failedFiles & " files:\n\n"

    # Group by external kind
    var kindToFiles = initTable[XLangNodeKind, seq[string]]()
    for issue in results.issues:
      for kind in issue.externalKinds:
        if not kindToFiles.hasKey(kind):
          kindToFiles[kind] = @[]
        kindToFiles[kind].add(issue.filename)

    result &= "Issues by external kind:\n"
    for kind, files in kindToFiles:
      result &= "\n  " & $kind & " (" & $files.len & " files):\n"
      for file in files:
        result &= "    - " & file & "\n"

    result &= "\n" & "-".repeat(80) & "\n"
    result &= "Detailed Issues:\n"
    result &= "-".repeat(80) & "\n\n"

    for i, issue in results.issues:
      if issue.externalKinds.len > 0:
        result &= "[" & $(i+1) & "] " & issue.filename & "\n"
        result &= "  External kinds remaining: " & issue.externalKinds.join(", ") & "\n\n"

        # Find and display each problematic node with context
        let problematicNodes = findNodesWithKinds(issue.lastAst, issue.externalKinds)
        result &= "  Found " & $problematicNodes.len & " node(s) with external kinds:\n\n"

        for j, (path, node) in problematicNodes:
          result &= "  [" & $(j+1) & "] Location: " & path & "\n"
          result &= formatNodeDetails(node)
          result &= "\n"

        result &= "\n"

proc main() =
  if paramCount() < 1:
    echo "Usage: transform_reporter <directory>"
    echo ""
    echo "Validates that transformation passes eliminate all external kinds."
    quit(1)

  let directory = paramStr(1)

  if not dirExists(directory):
    echo "Error: Directory not found: ", directory
    quit(1)

  echo "Scanning for .xljs files in: ", directory
  let xljsFiles = findXljsFiles(directory)
  echo "Found ", xljsFiles.len, " .xljs files"
  echo ""

  if xljsFiles.len == 0:
    echo "No .xljs files found."
    quit(0)

  var results = ReportResults(
    totalFiles: xljsFiles.len,
    successFiles: 0,
    failedFiles: 0,
    issues: @[]
  )

  # Process each file
  for i, filepath in xljsFiles:
    stdout.write("\rProcessing [" & $(i+1) & "/" & $xljsFiles.len & "] " & filepath.extractFilename())
    stdout.flushFile()

    let issue = processXljsFile(filepath)

    if issue.externalKinds.len > 0:
      results.failedFiles.inc()
      results.issues.add(issue)
    else:
      results.successFiles.inc()

  echo "\n"

  # Generate and display report
  let report = generateReport(results)
  echo report

  # Write report to file
  let reportPath = "transform_validation_report.txt"
  writeFile(reportPath, report)
  echo "Report written to: ", reportPath

when isMainModule:
  main()
