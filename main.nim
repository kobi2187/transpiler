import os, parseopt, strutils, sequtils
import core/xlangtypes
import backends/nim/my_nim_node
import transforms/pass_manager2
import transforms/nim_passes
import error_collector
import semantic/semantic_analysis

import main_steps

# proc detectInputLang(fileName: string): string =
#   ## Detect input language from file extension
#   ## Returns: "csharp", "java", "python", "typescript", etc.
#   let ext = fileName.splitFile().ext.toLowerAscii()
#   case ext
#   of ".cs": return "csharp"
#   of ".java": return "java"
#   of ".py": return "python"
#   of ".ts": return "typescript"
#   of ".js": return "javascript"
#   of ".go": return "go"
#   of ".rs": return "rust"
#   of ".cpp", ".cc", ".cxx": return "cpp"
#   of ".c": return "c"
#   of ".d": return "d"
#   of ".nim": return "nim"
#   else: return "unknown"

proc collectXljsFiles(path: string): seq[string] =
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

proc parseArgs(inputPath, outputDir: var string, verbose, skipTransforms, outputJson, useStdout, sameDir: var bool, targetLang: var string) =
  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      inputPath = key
    of cmdLongOption, cmdShortOption:
      case key
      of "out", "o", "output": outputDir = val
      of "verbose", "v": verbose = true
      of "skip-transforms": skipTransforms = true
      of "target-lang", "t": targetLang = val
      of "output-json", "j": outputJson = true
      of "stdout", "s": useStdout = true
      of "same-dir", "d": sameDir = true
    of cmdEnd: assert(false)

proc setupOutputDir(inputPath: string, useStdout, verbose: bool): string =
  ## Sets up output directory as "transpiler_output" at the root of the input path
  ## Returns the absolute path to the output directory
  if useStdout:
    return ""

  # Determine the root directory for output
  let rootDir = if dirExists(inputPath):
    inputPath.absolutePath()
  elif fileExists(inputPath):
    inputPath.parentDir().absolutePath()
  else:
    getCurrentDir()

  # Output directory is always "transpiler_output" at the root
  result = rootDir / "transpiler_output"

  if not dirExists(result):
    createDir(result)
    if verbose:
      echo "Created output directory: ", result
  elif verbose:
    echo "Using output directory: ", result

proc main() =
  var inputPath: string
  var outputDirIgnored: string  # For backward compatibility with parseArgs, but ignored
  var verbose = false
  var skipTransforms = false
  var targetLang = "nim"
  var outputJson = false
  var useStdout = false
  var sameDir = false

  parseArgs(inputPath, outputDirIgnored, verbose, skipTransforms, outputJson, useStdout, sameDir, targetLang)

  if inputPath == "":
    quit("No input path specified (file or directory)")

  let outputDir = setupOutputDir(inputPath, useStdout, verbose)

  # Collect all xljs files
  let xlsjFiles = collectXljsFiles(inputPath)

  if xlsjFiles.len == 0:
    quit("No .xljs files found at: " & inputPath)

  # Determine the root directory for relative path calculation
  # If inputPath is a directory, use it as root; if a file, use its parent
  let inputRoot = if dirExists(inputPath):
    inputPath.absolutePath()
  elif fileExists(inputPath):
    inputPath.parentDir().absolutePath()
  else:
    ""

  if verbose:
    echo "Found ", xlsjFiles.len, " .xljs file(s)"
    if sameDir:
      echo "Output mode: SAME DIRECTORY (next to source files)"
    else:
      echo "Output directory: ", outputDir
      if inputRoot != "":
        echo "Input root: ", inputRoot
    echo "Target language: ", targetLang
    if skipTransforms:
      echo "Transformations: DISABLED"
    else:
      echo "Transformations: ENABLED"
    if outputJson:
      echo "JSON output: ENABLED (.nimjs files will be generated)"

  # Create error collector for the entire pipeline
  let errorCollector = newErrorCollector()

  # Track files with infinite loops
  var infiniteLoopFiles: seq[tuple[file: string, iterations: int, kinds: seq[XLangNodeKind]]] = @[]

  # Create and register transform passes once (global for all files)
  var passManager: PassManager2 = nil
  if not skipTransforms:
    passManager = newPassManager2()
    registerNimPasses(passManager, verbose)
    passManager.errorCollector = errorCollector

  # Process each xljs file
  for inputFile in xlsjFiles:
    if verbose:
      echo "\n=== Processing: ", inputFile, " ==="

    # Step 1: Parse JSON to XLang AST
    var xlangAst: XLangNode
    try:
      xlangAst = stepParseXLang(inputFile, errorCollector, verbose)
    except Exception as e:
      echo "ERROR: Failed to parse input file: ", e.msg
      echo "Stack trace: ", e.getStackTrace()
      errorCollector.addError(tekParseError, "Failed to parse input file: " & e.msg, location = inputFile, details = e.getStackTrace())
      continue

    # Step 1.5: Run semantic analysis
    var semanticInfo: SemanticInfo
    try:
      semanticInfo = stepSemanticAnalysis(xlangAst, verbose)
    except Exception as e:
      echo "ERROR: Semantic analysis failed: ", e.msg
      echo "Stack trace: ", e.getStackTrace()
      errorCollector.addError(tekValidationError, "Semantic analysis failed: " & e.msg, location = inputFile, details = e.getStackTrace())
      continue

    # Step 1.7: Normalize enum member access
    try:
      stepEnumNormalization(xlangAst, verbose, semanticInfo)
    except Exception as e:
      echo "ERROR: Enum normalization failed: ", e.msg
      echo "Stack trace: ", e.getStackTrace()
      errorCollector.addError(tekTransformError, "Enum normalization failed: " & e.msg, location = "Enum normalization", details = e.getStackTrace())
      continue

    # Step 2: Apply transformation passes
    if not skipTransforms:
      try:
        stepTransformPasses(xlangAst, semanticInfo, passManager, inputFile, infiniteLoopFiles, verbose)
      except Exception as e:
        echo "ERROR: Transformation pipeline failed: ", e.msg
        echo "Stack trace: ", e.getStackTrace()
        errorCollector.addError(tekTransformError, "Transformation pipeline failed: " & e.msg, location = "Pass manager", details = e.getStackTrace())
        continue

    # Step 2.5: Apply identifier sanitization
    try:
      stepSanitizeIdentifiers(xlangAst, verbose)
    except Exception as e:
      echo "ERROR: Identifier sanitization failed: ", e.msg
      echo "Stack trace: ", e.getStackTrace()
      errorCollector.addError(tekTransformError, "Identifier sanitization failed: " & e.msg, location = "Nim identifier sanitization", details = e.getStackTrace())
      continue

    # Step 2.6: Fix generic type syntax
    try:
      stepFixGenericTypes(xlangAst, verbose)
    except Exception as e:
      echo "ERROR: Generic type fix failed: ", e.msg
      echo "Stack trace: ", e.getStackTrace()
      errorCollector.addError(tekTransformError, "Generic type fix failed: " & e.msg, location = "Generic type syntax fix", details = e.getStackTrace())
      continue

    # Step 2.7: Apply primitive type mapping
    try:
      stepMapPrimitiveTypes(xlangAst, verbose)
    except Exception as e:
      echo "ERROR: Primitive type mapping failed: ", e.msg
      echo "Stack trace: ", e.getStackTrace()
      errorCollector.addError(tekTransformError, "Primitive type mapping failed: " & e.msg, location = "Primitive type mapping", details = e.getStackTrace())
      continue

    # Step 3: Convert XLang AST to Nim AST
    var nimAst: MyNimNode
    try:
      nimAst = stepConvertToNim(xlangAst, semanticInfo, inputFile, verbose)
    except Exception as e:
      echo "ERROR [", inputFile, "]: Failed to convert XLang to Nim AST: ", e.msg
      echo "Stack trace: ", e.getStackTrace()
      errorCollector.addError(tekConversionError, "Failed to convert XLang to Nim AST: " & e.msg, location = inputFile, details = e.getStackTrace())
      continue

    # Step 4: Generate Nim code from AST
    var nimCode: string
    try:
      nimCode = stepGenerateCode(nimAst, verbose)
    except Exception as e:
      echo "ERROR: Failed to generate Nim code: ", e.msg
      echo "Stack trace: ", e.getStackTrace()
      errorCollector.addError(tekCodegenError, "Failed to generate Nim code: " & e.msg, location = "astprinter", details = e.getStackTrace())
      continue

    # Step 5: Write outputs
    try:
      stepWriteOutputs(nimCode, nimAst, xlangAst, inputFile, outputDir, inputRoot, useStdout, outputJson, sameDir, verbose)
    except Exception as e:
      echo "ERROR: Failed to write output: ", e.msg
      echo "Stack trace: ", e.getStackTrace()
      errorCollector.addError(tekCodegenError, "Failed to write output: " & e.msg, location = inputFile, details = e.getStackTrace())
      continue

  # Report infinite loop files
  if infiniteLoopFiles.len > 0:
    echo ""
    echo "=== INFINITE LOOP REPORT ==="
    echo "Files that reached max iterations (", passManager.maxIterations, "):"
    for entry in infiniteLoopFiles:
      echo "  - ", entry.file
      echo "    Iterations: ", entry.iterations
      if entry.kinds.len > 0:
        echo "    Stuck on kinds: ", entry.kinds.mapIt($it).join(", ")
    echo ""
    echo "Total files with infinite loops: ", infiniteLoopFiles.len
    echo ""

  # Report any warnings or errors
  if errorCollector.hasWarnings() or errorCollector.hasErrors():
    errorCollector.reportSummary()

  if not errorCollector.hasErrors(): echo "No errors encountered." 
  if infiniteLoopFiles.len == 0: echo "hadn't detected any infinite loops in transform passes"
  
  errorCollector.reportSummary()


when isMainModule:
  main()
