## Transpilation Report Tool
## Tests transpilation of C# files and produces a detailed error report

import std/[os, osproc, strutils, strformat, tables, sequtils, times, re, algorithm]

type
  TranspileResult = object
    file: string
    success: bool
    errorCount: int
    errors: seq[string]
    transpileTime: float
    crashed: bool
    crashReason: string

  ErrorCategory = enum
    ecAssertionFailure
    ecException
    ecSegfault
    ecTimeout
    ecNimDefect
    ecIndexDefect
    ecFieldDefect
    ecRangeDefect
    ecAccessViolation
    ecParseError
    ecOther

  ErrorStats = object
    category: ErrorCategory
    count: int
    examples: seq[tuple[file: string, msg: string]]

proc categorizeError(errMsg: string): ErrorCategory =
  ## Categorize an error message
  let lower = errMsg.toLowerAscii()

  # Check for assertion failures
  if "assertion" in lower or "assert" in lower or "failed:" in lower:
    return ecAssertionFailure

  # Check for segfaults
  elif "segmentation fault" in lower or "sigsegv" in lower:
    return ecSegfault

  # Check for timeouts
  elif "timeout" in lower or "timed out" in lower:
    return ecTimeout

  # Check for specific Nim defects
  elif "indexdefect" in lower or "index out of bounds" in lower:
    return ecIndexDefect

  elif "fielddefect" in lower or "field not accessible" in lower:
    return ecFieldDefect

  elif "rangedefect" in lower:
    return ecRangeDefect

  elif "accessviolationdefect" in lower or "accessviolationerror" in lower:
    return ecAccessViolation

  # Check for generic Nim defects/errors
  elif "defect" in lower or "error:" in lower:
    return ecNimDefect

  # Check for exceptions
  elif "exception" in lower or "error" in lower:
    return ecException

  # Check for parsing errors
  elif "parse" in lower or "syntax" in lower:
    return ecParseError

  else:
    return ecOther

proc extractErrorMessage(output: string): seq[string] =
  ## Extract error messages from transpiler output
  result = @[]

  for line in output.splitLines():
    let trimmed = line.strip()
    if trimmed.len == 0:
      continue

    # Look for common error patterns
    if "Error:" in line or "error:" in line:
      result.add(trimmed)
    elif "Exception" in line or "exception" in line:
      result.add(trimmed)
    elif "Assertion" in line or "assertion" in line:
      result.add(trimmed)
    elif "Defect" in line or "defect" in line:
      result.add(trimmed)
    elif "Traceback" in line:
      result.add(trimmed)
    elif line.contains(re"^\s*\[\w+\]"):  # Stack trace lines like [Exception]
      result.add(trimmed)

proc transpileFile(filePath: string, transpilerPath: string, verbose: bool = false, timeoutSecs: int = 30): TranspileResult =
  ## Try to transpile a single C# file and capture errors
  result.file = filePath
  result.success = false
  result.errors = @[]
  result.crashed = false

  let startTime = cpuTime()

  # Run the transpiler with timeout
  let cmd = &"timeout {timeoutSecs} {quoteShell(transpilerPath)} {quoteShell(filePath)}"
  echo "CMD: ", cmd
  let (output, exitCode) = execCmdEx(cmd)

  result.transpileTime = cpuTime() - startTime
  result.success = (exitCode == 0)
  echo output
  # echo stdout
  if not result.success:
    # Check if it was a timeout
    if exitCode == 124:  # timeout command returns 124
      result.crashed = true
      result.crashReason = "Timeout"
      result.errors.add(&"Transpilation timed out after {timeoutSecs} seconds")
      result.errorCount = 1
    # Check for segfault
    elif exitCode == 139:  # SIGSEGV
      result.crashed = true
      result.crashReason = "Segmentation Fault"
      result.errors.add("Segmentation fault (core dumped)")
      result.errorCount = 1
    # Check for other crashes
    elif exitCode > 128:
      result.crashed = true
      result.crashReason = &"Signal {exitCode - 128}"
      result.errors.add(&"Process crashed with signal {exitCode - 128}")
      result.errorCount = 1
    else:
      # Parse errors from output
      let errorMessages = extractErrorMessage(output)
      if errorMessages.len > 0:
        result.errors = errorMessages
        result.errorCount = errorMessages.len
      else:
        # If no specific errors found but exit code != 0, include raw output
        result.errors.add(&"Process exited with code {exitCode}")
        if output.len > 0:
          # Include first few lines of output
          let lines = output.splitLines()
          for i, line in lines[0..min(10, lines.high)]:
            if line.strip().len > 0:
              result.errors.add(line.strip())
        result.errorCount = result.errors.len

  if verbose:
    if result.success:
      echo "✓ ", filePath
    else:
      echo "✗ ", filePath, " (", result.errors.len, " errors)"

proc generateReport(results: seq[TranspileResult], outputPath: string = "", filterCategories: seq[ErrorCategory] = @[]) =
  ## Generate a detailed transpilation report
  var errorsByCategory = initTable[ErrorCategory, seq[tuple[file: string, msg: string]]]()
  var totalFiles = results.len
  var successCount = 0
  var crashCount = 0
  var totalErrors = 0

  # Collect statistics (with optional filtering)
  var filteredErrors = 0
  for res in results:
    if res.success:
      successCount.inc
    else:
      if res.crashed:
        crashCount.inc
      for err in res.errors:
        let cat = categorizeError(err)
        # If filter is set, ONLY include filtered categories
        if filterCategories.len > 0:
          if cat notin filterCategories:
            filteredErrors.inc
            continue
        totalErrors.inc
        if not errorsByCategory.hasKey(cat):
          errorsByCategory[cat] = @[]
        errorsByCategory[cat].add((file: res.file, msg: err))

  # Build report
  var report = ""

  report.add "╔═══════════════════════════════════════════════════════╗\n"
  report.add "║         TRANSPILATION REPORT                          ║\n"
  report.add "╚═══════════════════════════════════════════════════════╝\n\n"

  report.add &"Total files tested:  {totalFiles}\n"
  report.add &"Successful:          {successCount} ({(successCount*100/totalFiles).formatFloat(ffDecimal, 2)}%)\n"
  report.add &"Failed:              {totalFiles - successCount} ({((totalFiles-successCount)*100/totalFiles).formatFloat(ffDecimal, 2)}%)\n"
  report.add &"Crashed:             {crashCount}\n"
  report.add &"Total errors:        {totalErrors}\n"
  if filteredErrors > 0:
    report.add &"Excluded errors:     {filteredErrors} (not matching filter)\n"
  report.add "\n"

  if successCount > 0:
    report.add "Successfully transpiled files:\n"
    for res in results:
      if res.success:
        report.add &"  ✓ {res.file} ({res.transpileTime:.3f}s)\n"
    report.add "\n"

  if crashCount > 0:
    report.add "╔═══════════════════════════════════════════════════════╗\n"
    report.add "║         CRASHED FILES                                 ║\n"
    report.add "╚═══════════════════════════════════════════════════════╝\n\n"
    for res in results:
      if res.crashed:
        report.add &"  ✗ {res.file}\n"
        report.add &"    Reason: {res.crashReason}\n"
        if res.errors.len > 0:
          report.add &"    Error: {res.errors[0]}\n"
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
  var maxErrors = 0  # 0 means unlimited
  var timeoutSecs = 30
  var transpilerPath = "./main"  # Default transpiler executable
  var filterCategories: seq[ErrorCategory] = @[]

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
    of "--max-errors":
      i.inc
      if i <= paramCount():
        maxErrors = parseInt(paramStr(i))
    of "--timeout":
      i.inc
      if i <= paramCount():
        timeoutSecs = parseInt(paramStr(i))
    of "--transpiler":
      i.inc
      if i <= paramCount():
        transpilerPath = paramStr(i)
    of "--filter":
      i.inc
      if i <= paramCount():
        let filterStr = paramStr(i).toLowerAscii()
        case filterStr
        of "assert": filterCategories.add(ecAssertionFailure)
        of "exception": filterCategories.add(ecException)
        of "crash":
          filterCategories.add(ecSegfault)
          filterCategories.add(ecTimeout)
        of "defect":
          filterCategories.add(ecNimDefect)
          filterCategories.add(ecIndexDefect)
          filterCategories.add(ecFieldDefect)
          filterCategories.add(ecRangeDefect)
          filterCategories.add(ecAccessViolation)
        else:
          echo "Unknown filter: ", filterStr
    else:
      if dirPath == "":
        dirPath = arg
    i.inc

  if dirPath == "":
    echo "Usage: transpile_reporter <directory> [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -o, --output <file>       Write report to file"
    echo "  -v, --verbose             Show progress"
    echo "  --max N                   Limit to first N files"
    echo "  --max-errors N            Stop after collecting N errors (0 = unlimited)"
    echo "  --timeout N               Timeout per file in seconds (default: 30)"
    echo "  --transpiler <path>       Path to transpiler executable (default: ./main)"
    echo "  --filter CATEGORY         Show ONLY errors of this category"
    echo "                            (assert, exception, crash, defect)"
    quit(1)

  if not dirExists(dirPath):
    echo "Error: Directory not found: ", dirPath
    quit(1)

  if not fileExists(transpilerPath):
    echo "Error: Transpiler not found: ", transpilerPath
    quit(1)

  echo "Scanning for .xljs files in: ", dirPath
  echo "Using transpiler: ", transpilerPath

  # Collect all .xljs files
  var xljsFiles: seq[string] = @[]
  for file in walkDirRec(dirPath):
    if file.endsWith(".xljs"):
      xljsFiles.add(file)

  if maxFiles > 0 and xljsFiles.len > maxFiles:
    xljsFiles = xljsFiles[0..<maxFiles]

  echo "Found ", xljsFiles.len, " .xljs files"
  echo "Starting transpilation tests...\n"

  # Test transpilation of each file
  var results: seq[TranspileResult] = @[]
  var fileNum = 0
  var totalErrorsSoFar = 0
  for file in xljsFiles:
    fileNum.inc
    if verbose or (fileNum mod 10 == 0):
      echo &"[{fileNum}/{xljsFiles.len}] Testing: {file}"

    let result = transpileFile(file, transpilerPath, verbose, timeoutSecs)
    results.add(result)

    # Check if we've hit max errors limit
    if maxErrors > 0 and not result.success:
      totalErrorsSoFar += result.errorCount
      if totalErrorsSoFar >= maxErrors:
        echo &"\nReached error limit ({maxErrors}). Stopping after {fileNum} files."
        break

  echo "\n"
  echo "Transpilation testing complete!"
  echo "Generating report...\n"

  generateReport(results, outputPath, filterCategories)

when isMainModule:
  main()
