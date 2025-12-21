import os, parseopt, strutils, sequtils
import std/json
import xlangtypes
import jsontoxlangtypes
import xlangtonim
import src/transforms/pass_manager2
import src/transforms/nim_passes
import src/xlang/error_handling
import src/my_nim_node
import src/astprinter
import src/naming_conventions


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

proc main() =
  var inputPath, outputFile: string
  var verbose = false
  var skipTransforms = false
  var targetLang = "nim"
  var outputJson = false

  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      inputPath = key
    of cmdLongOption, cmdShortOption:
      case key
      of "out", "o": outputFile = val
      of "verbose", "v": verbose = true
      of "skip-transforms": skipTransforms = true
      of "target-lang", "t": targetLang = val
      of "output-json", "j": outputJson = true
    of cmdEnd: assert(false)  # Should not happen

  if inputPath == "":
    quit("No input path specified (file or directory)")

  # Collect all xljs files
  let xlsjFiles = collectXljsFiles(inputPath)

  if xlsjFiles.len == 0:
    quit("No .xljs files found at: " & inputPath)

  if verbose:
    echo "Found ", xlsjFiles.len, " .xljs file(s)"
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
    registerNimPasses(passManager)
    passManager.errorCollector = errorCollector

  # Process each xljs file
  for inputFile in xlsjFiles:
    if verbose:
      echo "\n=== Processing: ", inputFile, " ==="

    # Step 1: Parse JSON to XLang AST
    var xlangAst: XLangNode
    try:
      if verbose:
        echo "DEBUG: About to parse xljs file..."
      xlangAst = parseXLangJson(inputFile)
      if verbose:
        echo "DEBUG: XLang AST kind: ", xlangAst.kind
        echo "DEBUG: XLang AST has ", (if xlangAst.kind == xnkFile: $xlangAst.moduleDecls.len else: "N/A"), " module declarations"
        echo "✓ XLang AST created successfully"
    except Exception as e:
      echo "ERROR: Failed to parse input file: ", e.msg
      echo "Stack trace: ", e.getStackTrace()
      errorCollector.addError(
        tekParseError,
        "Failed to parse input file: " & e.msg,
        location = inputFile,
        details = e.getStackTrace()
      )
      continue  # Skip to next file

    # Step 2: Apply transformation passes (unless disabled)
    if not skipTransforms:
      if verbose:
        echo "DEBUG: Running transformation passes..."

      try:
        if verbose:
          echo "DEBUG: About to run passes on AST..."
        xlangAst = passManager.run(xlangAst, verbose)

        # Check for infinite loop
        if passManager.result.maxIterationsReached:
          infiniteLoopFiles.add((
            file: inputFile,
            iterations: passManager.result.iterations,
            kinds: passManager.result.loopKinds
          ))
          echo "WARNING: Max iterations reached for: ", inputFile
        elif passManager.result.loopWarning and verbose:
          echo "WARNING: Potential infinite loop detected (", passManager.result.iterations, " iterations)"

        if verbose:
          echo "DEBUG: After transformations, AST kind: ", xlangAst.kind
          echo "✓ Transformations applied successfully"
      except Exception as e:
        echo "ERROR: Transformation pipeline failed: ", e.msg
        echo "Stack trace: ", e.getStackTrace()
        errorCollector.addError(
          tekTransformError,
          "Transformation pipeline failed: " & e.msg,
          location = "Pass manager",
          details = e.getStackTrace()
        )
        continue  # Skip to next file

    # Step 3: Convert XLang AST to Nim AST
    var nimAst: MyNimNode
    try:
      if verbose:
        echo "DEBUG: About to convert XLang AST to Nim AST..."
      # Create context with file information for better error reporting
      let ctx = newContext()
      ctx.currentFile = inputFile
      nimAst = convertToNimAST(xlangAst, ctx)
      if verbose:
        echo "DEBUG: Nim AST root kind: ", nimAst.kind
        echo "DEBUG: Nim AST has ", nimAst.sons.len, " sons"
        echo "✓ Nim AST created successfully"
    except Exception as e:
      echo "ERROR [", inputFile, "]: Failed to convert XLang to Nim AST: ", e.msg
      echo "Stack trace: ", e.getStackTrace()
      errorCollector.addError(
        tekConversionError,
        "Failed to convert XLang to Nim AST: " & e.msg,
        location = inputFile,
        details = e.getStackTrace()
      )
      continue  # Skip to next file

    # Step 4: Generate Nim code from AST
    var nimCode: string
    try:
      if verbose:
        echo "DEBUG: About to generate Nim code from AST..."
      nimCode = nimAst.toNimCode()
      if verbose:
        echo "DEBUG: Generated Nim code length: ", nimCode.len, " characters"
        echo "✓ Nim code generated successfully"
    except Exception as e:
      echo "ERROR: Failed to generate Nim code: ", e.msg
      echo "Stack trace: ", e.getStackTrace()
      errorCollector.addError(
        tekCodegenError,
        "Failed to generate Nim code: " & e.msg,
        location = "astprinter",
        details = e.getStackTrace()
      )
      continue  # Skip to next file

    # Step 5: Write outputs
    try:
      # Determine output file name
      var nimOutputFile: string
      if outputFile != "" and xlsjFiles.len == 1:
        # Single file with explicit output name
        nimOutputFile = outputFile
      else:
        # Auto-generate output name from input based on namespace conventions
        # Pass inputPath to preserve directory structure and avoid collisions
        nimOutputFile = getOutputFileName(xlangAst, inputFile, ".nim", inputPath)

        # Create parent directories if needed
        let parentDir = nimOutputFile.parentDir()
        if parentDir != "" and not dirExists(parentDir):
          createDir(parentDir)
          if verbose:
            echo "DEBUG: Created directory: ", parentDir

      if verbose:
        echo "DEBUG: About to write .nim file to: ", nimOutputFile

      # Write .nim file
      writeFile(nimOutputFile, nimCode)
      if verbose:
        echo "✓ Nim code written to: ", nimOutputFile

      # Optionally write .nimjs file
      if outputJson:
        let nimJsonFile = inputFile.changeFileExt(".nimjs")
        if verbose:
          echo "DEBUG: About to serialize Nim AST to JSON using %* operator..."
        let jsonNode = %nimAst  # Uses the %* operator we defined
        if verbose:
          echo "DEBUG: JSON node created, about to pretty-print..."
        let jsonContent = pretty(jsonNode)
        if verbose:
          echo "DEBUG: JSON content length: ", jsonContent.len, " characters"
          echo "DEBUG: About to write .nimjs file to: ", nimJsonFile
        writeFile(nimJsonFile, jsonContent)
        if verbose:
          echo "✓ Nim AST JSON written to: ", nimJsonFile
          echo "DEBUG: First 200 chars of nimjs: ", jsonContent[0..<min(200, jsonContent.len)]

    except Exception as e:
      echo "ERROR: Failed to write output: ", e.msg
      echo "Stack trace: ", e.getStackTrace()
      errorCollector.addError(
        tekCodegenError,
        "Failed to write output: " & e.msg,
        location = inputFile,
        details = e.getStackTrace()
      )
      continue  # Skip to next file

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
