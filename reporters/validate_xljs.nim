import os, tables, strutils, sequtils, algorithm, times
import xlangtypes
import jsontoxlangtypes

type
  ValidationError* = object
    filePath*: string
    errorMsg*: string
    offset*: int
    errorKind*: string

  ValidationStats* = object
    totalFiles*: int
    successCount*: int
    errorCount*: int
    errorsByKind*: CountTable[string]
    errorsByMessage*: CountTable[string]
    errors*: seq[ValidationError]

proc newValidationStats*(): ValidationStats =
  result.totalFiles = 0
  result.successCount = 0
  result.errorCount = 0
  result.errorsByKind = initCountTable[string]()
  result.errorsByMessage = initCountTable[string]()
  result.errors = @[]

proc addError*(stats: var ValidationStats, filePath: string, errorMsg: string, offset: int = -1) =
  ## Add an error to the statistics
  inc stats.errorCount

  # Extract error kind from message (e.g., "Expected { but got..." -> "ParseError")
  let errorKind = if "parse" in errorMsg.toLowerAscii or "Expected" in errorMsg:
    "ParseError"
  elif "Unsupported" in errorMsg:
    "UnsupportedNode"
  elif "not found" in errorMsg.toLowerAscii:
    "NotFound"
  else:
    "OtherError"

  stats.errorsByKind.inc(errorKind)
  stats.errorsByMessage.inc(errorMsg)

  stats.errors.add(ValidationError(
    filePath: filePath,
    errorMsg: errorMsg,
    offset: offset,
    errorKind: errorKind
  ))

proc collectXljsFiles*(path: string): seq[string] =
  ## Recursively collect all .xljs files from a path (file or directory)
  if fileExists(path):
    if path.endsWith(".xljs"):
      return @[path]
    else:
      return @[]
  elif dirExists(path):
    result = @[]
    for kind, filePath in walkDir(path):
      case kind
      of pcFile:
        if filePath.endsWith(".xljs"):
          result.add(filePath)
      of pcDir:
        result.add(collectXljsFiles(filePath))
      else:
        discard
  else:
    return @[]

proc getContextAroundOffset*(filePath: string, offset: int, contextSize: int = 100): string =
  ## Get the text context around a specific offset in a file
  try:
    let content = readFile(filePath)
    if offset < 0 or offset >= content.len:
      return ""

    let start = max(0, offset - contextSize)
    let endPos = min(content.len, offset + contextSize)

    var context = ""

    # Show position info
    context.add("Position: " & $offset & " / " & $content.len & "\n")

    # Calculate line number
    var lineNum = 1
    var colNum = 1
    for i in 0..<offset:
      if i < content.len and content[i] == '\n':
        inc lineNum
        colNum = 1
      else:
        inc colNum

    context.add("Line: " & $lineNum & ", Column: " & $colNum & "\n")
    context.add("=" .repeat(60) & "\n")

    # Show context with marker
    let beforeContext = content[start..<offset]
    let atOffset = if offset < content.len: content[offset] else: '\0'
    let afterContext = content[(offset+1)..<endPos]

    context.add(beforeContext)
    context.add(">>>" & $atOffset & "<<<")
    context.add(afterContext)
    context.add("\n")
    context.add("=" .repeat(60) & "\n")

    # Show hex dump around the offset
    context.add("Hex dump around offset:\n")
    let hexStart = max(0, offset - 20)
    let hexEnd = min(content.len, offset + 20)
    for i in hexStart..<hexEnd:
      let ch = content[i]
      let marker = if i == offset: " >>>" else: "    "
      context.add(marker & " [" & $i & "] 0x" & toHex(ord(ch), 2) & " '" &
                  (if ch >= ' ' and ch <= '~': $ch else: ".") & "'\n")

    return context
  except:
    return "Error reading file context"

proc validateXljsFile*(filePath: string, stats: var ValidationStats): bool =
  ## Validate a single .xljs file
  ## Returns true if valid, false if error
  try:
    let xlangNode = parseXLangJson(filePath)
    inc stats.successCount
    return true
  except CatchableError as e:
    # Extract offset from error message if present
    var offset = -1
    let msg = e.msg
    if "offset:" in msg.toLowerAscii:
      try:
        let parts = msg.split("offset:")
        if parts.len > 1:
          let offsetStr = parts[1].strip().split()[0]
          offset = parseInt(offsetStr)
      except:
        discard

    stats.addError(filePath, e.msg, offset)
    return false

proc validateXljsFolder*(folderPath: string, verbose: bool = false): ValidationStats =
  ## Validate all .xljs files in a folder
  result = newValidationStats()

  if verbose:
    echo "Scanning for .xljs files in: ", folderPath

  let xlsjFiles = collectXljsFiles(folderPath)
  result.totalFiles = xlsjFiles.len

  if verbose:
    echo "Found ", xlsjFiles.len, " .xljs file(s)"
    echo ""

  for i, filePath in xlsjFiles:
    if verbose:
      echo "[", i + 1, "/", xlsjFiles.len, "] Validating: ", filePath

    let success = validateXljsFile(filePath, result)

    if verbose and not success:
      echo "  ERROR: ", result.errors[^1].errorMsg
      echo ""

proc printValidationReport*(stats: ValidationStats) =
  ## Print a detailed validation report
  echo ""
  echo "╔═══════════════════════════════════════════════════════╗"
  echo "║           XLJS VALIDATION REPORT                      ║"
  echo "╚═══════════════════════════════════════════════════════╝"
  echo ""
  echo "Total files:      ", stats.totalFiles
  echo "Successful:       ", stats.successCount, " (",
       formatFloat(100.0 * stats.successCount.float / stats.totalFiles.float, ffDecimal, 2), "%)"
  echo "Errors:           ", stats.errorCount, " (",
       formatFloat(100.0 * stats.errorCount.float / stats.totalFiles.float, ffDecimal, 2), "%)"
  echo ""

  if stats.errorsByKind.len > 0:
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║           ERRORS BY KIND                              ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo ""

    # Sort by count descending
    var errorKinds = toSeq(stats.errorsByKind.pairs)
    errorKinds.sort(proc(a, b: (string, int)): int = cmp(b[1], a[1]))

    for (kind, count) in errorKinds:
      echo "  ", kind.alignLeft(30), ": ", count, " occurrences"
    echo ""

  if stats.errorsByMessage.len > 0:
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║           DETAILED ERRORS                             ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo ""

    # Group errors by unique message and show full details
    var errorMsgs = toSeq(stats.errorsByMessage.pairs)
    errorMsgs.sort(proc(a, b: (string, int)): int = cmp(b[1], a[1]))

    # Show top 50 unique error types with full messages
    for i, (msg, count) in errorMsgs:
      if i >= 50:
        echo ""
        echo "... and ", errorMsgs.len - 50, " more unique error types"
        break

      echo "═" .repeat(80)
      echo "ERROR TYPE ", i + 1, " (", count, " occurrence", (if count > 1: "s" else: ""), "):"
      echo "─" .repeat(80)

      # Show full error message (no truncation)
      echo msg
      echo ""

      # Find and show 1-3 example files with this error
      var exampleCount = 0
      for err in stats.errors:
        if err.errorMsg == msg:
          echo "  Example file: ", err.filePath
          if err.offset >= 0:
            echo "  At offset:    ", err.offset
          exampleCount += 1
          if exampleCount >= 3:
            if count > 3:
              echo "  ... and ", count - 3, " more file(s) with this error"
            break
      echo ""

proc writeErrorReport*(stats: ValidationStats, outputPath: string) =
  ## Write detailed error report to a file
  var f = open(outputPath, fmWrite)
  defer: f.close()

  f.writeLine("XLJS VALIDATION ERROR REPORT")
  f.writeLine("=" .repeat(80))
  f.writeLine("")
  f.writeLine("Generated: ", $now())
  f.writeLine("Total files: ", stats.totalFiles)
  f.writeLine("Successful: ", stats.successCount)
  f.writeLine("Errors: ", stats.errorCount)
  f.writeLine("")
  f.writeLine("=" .repeat(80))
  f.writeLine("")

  if stats.errors.len > 0:
    f.writeLine("DETAILED ERROR LIST")
    f.writeLine("-" .repeat(80))
    f.writeLine("")

    for i, err in stats.errors:
      f.writeLine("ERROR #", i + 1)
      f.writeLine("  File: ", err.filePath)
      f.writeLine("  Kind: ", err.errorKind)
      if err.offset >= 0:
        f.writeLine("  Offset: ", err.offset)
      f.writeLine("  Message: ", err.errorMsg)

      # Show context around the error
      if err.offset >= 0:
        f.writeLine("")
        f.writeLine("  CONTEXT:")
        let context = getContextAroundOffset(err.filePath, err.offset, 80)
        for line in context.splitLines():
          f.writeLine("    ", line)

      f.writeLine("")
      f.writeLine("-" .repeat(80))
      f.writeLine("")

  f.writeLine("=" .repeat(80))
  f.writeLine("ERRORS BY KIND")
  f.writeLine("-" .repeat(80))
  f.writeLine("")

  var errorKinds = toSeq(stats.errorsByKind.pairs)
  errorKinds.sort(proc(a, b: (string, int)): int = cmp(b[1], a[1]))

  for (kind, count) in errorKinds:
    f.writeLine(kind.alignLeft(30), ": ", count, " occurrences")

  f.writeLine("")
  f.writeLine("=" .repeat(80))
  f.writeLine("ERRORS BY MESSAGE")
  f.writeLine("-" .repeat(80))
  f.writeLine("")

  var errorMsgs = toSeq(stats.errorsByMessage.pairs)
  errorMsgs.sort(proc(a, b: (string, int)): int = cmp(b[1], a[1]))

  for (msg, count) in errorMsgs:
    f.writeLine("[", count, "x] ", msg)

proc main() =
  var folderPath: string
  var verbose = false
  var detailed = false
  var outputReport = ""

  # Parse command line arguments
  var i = 1
  while i <= paramCount():
    let param = paramStr(i)
    case param
    of "-v", "--verbose":
      verbose = true
    of "-d", "--detailed":
      detailed = true
    of "-o", "--output":
      if i < paramCount():
        inc i
        outputReport = paramStr(i)
    else:
      if folderPath == "":
        folderPath = param
    inc i

  if folderPath == "":
    echo "Usage: validate_xljs [options] <folder_path>"
    echo ""
    echo "Options:"
    echo "  -v, --verbose         Show progress for each file"
    echo "  -d, --detailed        Show detailed error information"
    echo "  -o, --output <file>   Write detailed error report to file"
    echo ""
    echo "Validates all .xljs files in the given folder and reports statistics."
    quit(1)

  if not dirExists(folderPath) and not fileExists(folderPath):
    echo "Error: Path does not exist: ", folderPath
    quit(1)

  # Run validation
  let stats = validateXljsFolder(folderPath, verbose)

  # Print report
  printValidationReport(stats)

  # Write detailed error report if requested
  if outputReport != "":
    writeErrorReport(stats, outputReport)
    echo ""
    echo "Detailed error report written to: ", outputReport

  # Exit with error code if there were errors
  if stats.errorCount > 0:
    quit(1)

when isMainModule:
  main()
