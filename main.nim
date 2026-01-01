import os, parseopt, strutils, sequtils
import core/xlangtypes
import pipeline_manager
import backends/backend_types
import backends/nim/nim_backend

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
  var targetLangStr = "nim"
  var outputJson = false
  var useStdout = false
  var sameDir = false

  parseArgs(inputPath, outputDirIgnored, verbose, skipTransforms, outputJson, useStdout, sameDir, targetLangStr)

  if inputPath == "":
    quit("No input path specified (file or directory)")

  # Convert target language string to enum
  let targetLang = case targetLangStr.toLowerAscii()
    of "nim": olNim
    # etc. for other languages
    else:
      quit("Unknown target language: " & targetLangStr & "\nSupported: nim, go, rust, cpp")

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
      echo "JSON output: ENABLED (backend-specific AST JSON will be generated)"

  # Create pipeline configuration
  let baseConfig = PipelineConfig(
    outputDir: outputDir,
    inputRoot: inputRoot,
    verbose: verbose,
    skipTransforms: skipTransforms,
    outputJson: outputJson,
    useStdout: useStdout,
    sameDir: sameDir,
    targetLang: targetLang
  )

  # Create backend based on target language

  var backend = case targetLang
  of olNim:
    newNimBackend()
  # of olGo: -- for example.
    # quit("Go backend not yet implemented")
    # newGoBackend()

  var pipeline = newTranspilationPipeline(baseConfig, backend)

  # Process each xljs file
  for inputFile in xlsjFiles:
    # Update config with current input file
    pipeline.config.inputFile = inputFile

    # Run the pipeline
    let result = pipeline.run()

    # Handle errors
    if not result.success:
      for error in result.errors:
        echo "ERROR [", inputFile, "]: ", error

  # Report results
  pipeline.reportResults()


when isMainModule:
  main()
