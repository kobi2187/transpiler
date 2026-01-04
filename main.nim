## Transpiler CLI Entry Point
##
## Converts XLang JSON files (.xljs) to target language code.
## Usage: transpiler <input_path> [options]

import os, parseopt, strutils, sequtils
import core/xlangtypes
import pipeline_manager
import error_collector

# =============================================================================
# CLI Options Type
# =============================================================================

type
  CliOptions* = object
    inputPath*: string
    outputDir*: string
    inputRoot*: string
    verbose*: bool
    skipTransforms*: bool
    outputJson*: bool
    useStdout*: bool
    sameDir*: bool

# =============================================================================
# File Collection Helpers
# =============================================================================

proc isXljsFile(path: string): bool =
  ## Check if a path is an .xljs file
  path.endsWith(".xljs")

proc collectXljsFilesFromFile(path: string): seq[string] =
  ## If path is an .xljs file, return it; otherwise empty
  if isXljsFile(path): @[path] else: @[]

proc collectXljsFilesFromDir(path: string): seq[string] =
  ## Recursively collect all .xljs files from a directory
  result = @[]
  for kind, filePath in walkDir(path):
    case kind
    of pcFile:
      if isXljsFile(filePath):
        result.add(filePath)
    of pcDir:
      result.add(collectXljsFilesFromDir(filePath))
    else:
      discard

proc collectXljsFiles(path: string): seq[string] =
  ## Collect all .xljs files from a path (file or directory)
  if fileExists(path):
    collectXljsFilesFromFile(path)
  elif dirExists(path):
    collectXljsFilesFromDir(path)
  else:
    @[]

# =============================================================================
# Argument Parsing Helpers
# =============================================================================

proc parseTargetLanguage(langStr: string): string =
  ## Validate target language (currently only nim)
  case langStr.toLowerAscii()
  of "nim": "nim"
  else:
    quit("Unknown target language: " & langStr & "\nSupported: nim")

proc initDefaultOptions(): CliOptions =
  ## Create default CLI options
  CliOptions(
    inputPath: "",
    outputDir: "",
    inputRoot: "",
    verbose: false,
    skipTransforms: false,
    outputJson: false,
    useStdout: false,
    sameDir: false
  )

proc applyArgument(opts: var CliOptions, arg: string) =
  ## Apply a positional argument to options
  opts.inputPath = arg

proc applyOption(opts: var CliOptions, key, val: string) =
  ## Apply a named option to options
  case key
  of "out", "o", "output": opts.outputDir = val
  of "verbose", "v": opts.verbose = true
  of "skip-transforms": opts.skipTransforms = true
  of "target-lang", "t": discard parseTargetLanguage(val)  # Validate but ignore (only nim supported)
  of "output-json", "j": opts.outputJson = true
  of "stdout", "s": opts.useStdout = true
  of "same-dir", "d": opts.sameDir = true
  else: discard

proc parseCliOptions(): CliOptions =
  ## Parse command line arguments into CliOptions
  result = initDefaultOptions()
  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      result.applyArgument(key)
    of cmdLongOption, cmdShortOption:
      result.applyOption(key, val)
    of cmdEnd:
      discard

# =============================================================================
# Input Validation Helpers
# =============================================================================

proc validateInputPath(path: string) =
  ## Ensure input path is provided
  if path == "":
    quit("No input path specified (file or directory)")

proc validateXljsFilesExist(files: seq[string], inputPath: string) =
  ## Ensure at least one .xljs file was found
  if files.len == 0:
    quit("No .xljs files found at: " & inputPath)

# =============================================================================
# Path Resolution Helpers
# =============================================================================

proc determineInputRoot(inputPath: string): string =
  ## Determine the root directory for relative path calculation
  if dirExists(inputPath):
    inputPath.absolutePath()
  elif fileExists(inputPath):
    inputPath.parentDir().absolutePath()
  else:
    ""

proc determineOutputRoot(inputPath: string): string =
  ## Determine the root directory for output
  if dirExists(inputPath):
    inputPath.absolutePath()
  elif fileExists(inputPath):
    inputPath.parentDir().absolutePath()
  else:
    getCurrentDir()

proc buildOutputDir(rootDir: string): string =
  ## Build output directory path
  rootDir / "transpiler_output"

proc ensureOutputDirExists(outputDir: string, verbose: bool) =
  ## Create output directory if it doesn't exist
  if not dirExists(outputDir):
    createDir(outputDir)
    if verbose:
      echo "Created output directory: ", outputDir
  elif verbose:
    echo "Using output directory: ", outputDir

proc setupOutputDir(inputPath: string, useStdout, verbose: bool): string =
  ## Setup and return the output directory path
  if useStdout:
    return ""
  let rootDir = determineOutputRoot(inputPath)
  result = buildOutputDir(rootDir)
  ensureOutputDirExists(result, verbose)

# =============================================================================
# Verbose Output Helpers
# =============================================================================

proc printFileCount(count: int) =
  echo "Found ", count, " .xljs file(s)"

proc printOutputMode(sameDir: bool, outputDir, inputRoot: string) =
  if sameDir:
    echo "Output mode: SAME DIRECTORY (next to source files)"
  else:
    echo "Output directory: ", outputDir
    if inputRoot != "":
      echo "Input root: ", inputRoot

proc printTargetLanguage() =
  echo "Target language: nim"

proc printTransformStatus(skipTransforms: bool) =
  if skipTransforms:
    echo "Transformations: DISABLED"
  else:
    echo "Transformations: ENABLED"

proc printJsonStatus(outputJson: bool) =
  if outputJson:
    echo "JSON output: ENABLED (backend-specific AST JSON will be generated)"

proc printVerboseConfig(opts: CliOptions, fileCount: int) =
  ## Print verbose configuration info
  printFileCount(fileCount)
  printOutputMode(opts.sameDir, opts.outputDir, opts.inputRoot)
  printTargetLanguage()
  printTransformStatus(opts.skipTransforms)
  printJsonStatus(opts.outputJson)

# =============================================================================
# Pipeline Configuration
# =============================================================================

proc buildPipelineConfig(opts: CliOptions): PipelineConfig =
  ## Build pipeline configuration from CLI options
  PipelineConfig(
    outputDir: opts.outputDir,
    inputRoot: opts.inputRoot,
    verbose: opts.verbose,
    skipTransforms: opts.skipTransforms,
    outputJson: opts.outputJson,
    useStdout: opts.useStdout,
    sameDir: opts.sameDir
  )

# =============================================================================
# File Processing
# =============================================================================

var allErrors: seq[string] = @[]

proc processOneFile(pipeline: var TranspilationPipeline, inputFile: string) =
  ## Process a single .xljs file through the pipeline
  pipeline.config.inputFile = inputFile
  let result = pipeline.run()
  if not result.success:
    for error in result.errors:
      echo "ERROR [", inputFile, "]: ", error
      allErrors.add(inputFile & ":" & error)

proc processAllFiles(pipeline: var TranspilationPipeline, files: seq[string]) =
  ## Process all .xljs files through the pipeline
  for inputFile in files:
    processOneFile(pipeline, inputFile)

# =============================================================================
# Main Entry Point
# =============================================================================

proc runTranspiler() =
  ## Main transpiler workflow
  # Parse and validate
  var opts = parseCliOptions()
  validateInputPath(opts.inputPath)
  
  # Collect files
  let xljsFiles = collectXljsFiles(opts.inputPath)
  validateXljsFilesExist(xljsFiles, opts.inputPath)
  
  # Setup paths
  opts.inputRoot = determineInputRoot(opts.inputPath)
  opts.outputDir = setupOutputDir(opts.inputPath, opts.useStdout, opts.verbose)
  
  # Verbose output
  if opts.verbose:
    printVerboseConfig(opts, xljsFiles.len)
  
  # Create pipeline
  let config = buildPipelineConfig(opts)
  var pipeline = newTranspilationPipeline(config)
  
  # Process files
  processAllFiles(pipeline, xljsFiles)
  
  # Report results
  pipeline.reportResults()
  for error in allErrors:
    echo "ERROR: ", error

proc main() =
  ## Entry point
  runTranspiler()

when isMainModule:
  main()
