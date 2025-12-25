## Compilation Report Tool
## Tests compilation of generated Nim files and produces a detailed error report

import std/[os, osproc, strutils, strformat, tables, sequtils, times, re, algorithm]

type
  CompileResult = object
    file: string
    success: bool
    errorCount: int
    errors: seq[string]
    compileTime: float

  ErrorCategory = enum
    ecTypeError
    ecUndeclaredIdentifier
    ecUndeclaredField
    ecUndeclaredRoutine
    ecSyntaxError
    ecImportError
    ecPragmaError
    ecExpressionNoType
    ecCannotAssign
    ecOther

  ErrorStats = object
    category: ErrorCategory
    count: int
    examples: seq[tuple[file: string, msg: string]]

proc categorizeError(errMsg: string): ErrorCategory =
  ## Categorize an error message
  let lower = errMsg.toLowerAscii()

  # Check for undeclared field errors (including the mysterious "undeclared field: '.'")
  if "undeclared field:" in lower:
    return ecUndeclaredField

  # Check for undeclared routine/procedure calls
  elif "undeclared routine" in lower or "attempting to call undeclared" in lower:
    return ecUndeclaredRoutine

  # Check for "expression has no type" errors
  elif "has no type" in lower or "expression '' has no type" in lower or "expression ''" in lower:
    return ecExpressionNoType

  # Check for assignment errors
  elif "cannot be assigned to" in lower or "'' cannot be assigned" in lower:
    return ecCannotAssign

  # Type errors
  elif "type mismatch" in lower or "got <" in lower:
    return ecTypeError

  # Expression expected errors (often from syntax issues)
  elif "expression expected" in lower:
    return ecSyntaxError

  # Undeclared identifiers
  elif "undeclared identifier" in lower or "not declared" in lower or "unknown identifier" in lower:
    return ecUndeclaredIdentifier

  # Syntax errors
  elif "invalid" in lower and ("syntax" in lower or "pragma" in lower or "indentation" in lower):
    return ecSyntaxError

  # Import/module errors
  elif "cannot open" in lower or ("module" in lower and "invalid" in lower):
    return ecImportError

  # Pragma errors
  elif "pragma" in lower:
    return ecPragmaError

  else:
    return ecOther

proc extractErrorMessage(line: string): string =
  ## Extract just the error message part
  # Format: filepath(line, col) Error: message
  let parts = line.split("Error:")
  if parts.len > 1:
    return parts[1].strip()
  let parts2 = line.split("Warning:")
  if parts2.len > 1:
    return parts2[1].strip()
  return line.strip()

proc compileNimFile(filePath: string, verbose: bool = false): CompileResult =
  ## Try to compile a single Nim file and capture errors
  result.file = filePath
  result.success = false
  result.errors = @[]

  let startTime = cpuTime()

  # Use nim check for faster checking without full compilation
  let (output, exitCode) = execCmdEx("/home/kl/apps/Nim/bin/nim check --hints:off --warnings:off " & quoteShell(filePath))

  result.compileTime = cpuTime() - startTime
  result.success = (exitCode == 0)

  if not result.success:
    # Parse errors from output
    for line in output.splitLines():
      if "Error:" in line:
        result.errors.add(extractErrorMessage(line))
        result.errorCount.inc
      elif verbose and "Warning:" in line:
        result.errors.add(extractErrorMessage(line))

  if verbose and result.success:
    echo "✓ ", filePath

proc generateReport(results: seq[CompileResult], outputPath: string = "") =
  ## Generate a detailed compilation report
  var errorsByCategory = initTable[ErrorCategory, seq[tuple[file: string, msg: string]]]()
  var totalFiles = results.len
  var successCount = 0
  var totalErrors = 0

  # Collect statistics
  for res in results:
    if res.success:
      successCount.inc
    else:
      totalErrors += res.errorCount
      for err in res.errors:
        let cat = categorizeError(err)
        if not errorsByCategory.hasKey(cat):
          errorsByCategory[cat] = @[]
        errorsByCategory[cat].add((file: res.file, msg: err))

  # Build report
  var report = ""

  report.add "╔═══════════════════════════════════════════════════════╗\n"
  report.add "║         NIM COMPILATION REPORT                        ║\n"
  report.add "╚═══════════════════════════════════════════════════════╝\n\n"

  report.add &"Total files tested:  {totalFiles}\n"
  report.add &"Successful:          {successCount} ({(successCount*100/totalFiles).formatFloat(ffDecimal, 2)}%)\n"
  report.add &"Failed:              {totalFiles - successCount} ({((totalFiles-successCount)*100/totalFiles).formatFloat(ffDecimal, 2)}%)\n"
  report.add &"Total errors:        {totalErrors}\n\n"

  if successCount > 0:
    report.add "Successfully compiled files:\n"
    for res in results:
      if res.success:
        report.add &"  ✓ {res.file}\n"
    report.add "\n"

  if errorsByCategory.len > 0:
    report.add "╔═══════════════════════════════════════════════════════╗\n"
    report.add "║         ERRORS BY CATEGORY                            ║\n"
    report.add "╚═══════════════════════════════════════════════════════╝\n\n"

    # Sort categories by count
    var catCounts: seq[tuple[cat: ErrorCategory, count: int]] = @[]
    for cat, errors in errorsByCategory:
      catCounts.add((cat: cat, count: errors.len))
    catCounts.sort(proc (a, b: auto): int = cmp(b.count, a.count))

    for item in catCounts:
      report.add &"  {$item.cat:<25}: {item.count} occurrences\n"

    report.add "\n"
    report.add "╔═══════════════════════════════════════════════════════╗\n"
    report.add "║         DETAILED ERROR BREAKDOWN                      ║\n"
    report.add "╚═══════════════════════════════════════════════════════╝\n\n"

    var errorNum = 1
    for item in catCounts:
      let errors = errorsByCategory[item.cat]
      report.add "════════════════════════════════════════════════════════════════════════════════\n"
      report.add &"ERROR CATEGORY {errorNum}: {$item.cat} ({errors.len} occurrences)\n"
      report.add "────────────────────────────────────────────────────────────────────────────────\n"

      # Group identical error messages
      var errorGroups = initTable[string, seq[string]]()
      for (file, msg) in errors:
        if not errorGroups.hasKey(msg):
          errorGroups[msg] = @[]
        errorGroups[msg].add(file)

      # Show top 5 most common error messages for this category
      var sortedErrors: seq[tuple[msg: string, files: seq[string]]] = @[]
      for msg, files in errorGroups:
        sortedErrors.add((msg: msg, files: files))
      sortedErrors.sort(proc (a, b: auto): int = cmp(b.files.len, a.files.len))

      for i, err in sortedErrors[0..min(4, sortedErrors.high)]:
        report.add &"\n  Error message: {err.msg}\n"
        report.add &"  Occurs in {err.files.len} file(s):\n"
        for j, file in err.files[0..min(2, err.files.high)]:
          report.add &"    - {file}\n"
        if err.files.len > 3:
          report.add &"    ... and {err.files.len - 3} more file(s)\n"

      if sortedErrors.len > 5:
        report.add &"\n  ... and {sortedErrors.len - 5} more unique error messages\n"

      report.add "\n"
      errorNum.inc

  # Output report
  if outputPath != "":
    writeFile(outputPath, report)
    echo "Report written to: ", outputPath
  echo report

proc main() =
  var dirPath = ""
  var outputPath = ""
  var verbose = false
  var maxFiles = 0  # 0 means all files

  # Parse command line arguments
  var i = 1
  while i <= paramCount():
    let arg = paramStr(i)
    case arg
    of "-o", "--output":
      i.inc
      if i <= paramCount():
        outputPath = paramStr(i)
    of "-v", "--verbose":
      verbose = true
    of "--max":
      i.inc
      if i <= paramCount():
        maxFiles = parseInt(paramStr(i))
    else:
      if dirPath == "":
        dirPath = arg
    i.inc

  if dirPath == "":
    echo "Usage: compile_reporter <directory> [-o output_file] [-v] [--max N]"
    echo ""
    echo "Options:"
    echo "  -o, --output <file>  Write report to file"
    echo "  -v, --verbose        Show progress"
    echo "  --max N              Limit to first N files"
    quit(1)

  if not dirExists(dirPath):
    echo "Error: Directory not found: ", dirPath
    quit(1)

  echo "Scanning for .nim files in: ", dirPath

  # Collect all .nim files
  var nimFiles: seq[string] = @[]
  for file in walkDirRec(dirPath):
    if file.endsWith(".nim"):
      nimFiles.add(file)

  if maxFiles > 0 and nimFiles.len > maxFiles:
    nimFiles = nimFiles[0..<maxFiles]

  echo "Found ", nimFiles.len, " .nim files"
  echo "Starting compilation tests...\n"

  # Test compilation of each file
  var results: seq[CompileResult] = @[]
  var fileNum = 0
  for file in nimFiles:
    fileNum.inc
    if verbose or (fileNum mod 10 == 0):
      echo &"[{fileNum}/{nimFiles.len}] Testing: {file}"

    let result = compileNimFile(file, verbose)
    results.add(result)

  echo "\n"
  echo "Compilation testing complete!"
  echo "Generating report...\n"

  generateReport(results, outputPath)

when isMainModule:
  main()
