import os, parseopt
import xlangtypes
import jsontoxlangtypes
import nimastToCode
import xlangtonim
import src/transforms/pass_manager
import src/transforms/nim_passes
import src/xlang/error_handling
import src/my_nim_node




proc main() =
  var inputFile, outputFile: string
  var verbose = false
  var skipTransforms = false
  var targetLang = "nim"

  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      inputFile = key
    of cmdLongOption, cmdShortOption:
      case key
      of "out", "o": outputFile = val
      of "verbose", "v": verbose = true
      of "skip-transforms": skipTransforms = true
      of "target-lang", "t": targetLang = val
    of cmdEnd: assert(false)  # Should not happen
  
  if inputFile == "":
    quit("No input file specified")

  if verbose:
    echo "Processing input file: ", inputFile
    echo "Target language: ", targetLang
    if skipTransforms:
      echo "Transformations: DISABLED"
    else:
      echo "Transformations: ENABLED"

  # Create error collector for the entire pipeline
  let errorCollector = newErrorCollector()

  # Step 1: Parse JSON to XLang AST
  var xlangAst: XLangNode
  try:
    xlangAst = parseXLangJson(inputFile)
    if verbose:
      echo "✓ XLang AST created successfully"
  except Exception as e:
    errorCollector.addError(
      tekParseError,
      "Failed to parse input file: " & e.msg,
      location = inputFile,
      details = e.getStackTrace()
    )
    errorCollector.reportAndExit()

  # Step 2: Apply transformation passes (unless disabled)
  if not skipTransforms:
    if verbose:
      echo "Running transformation passes..."

    try:
      let pm = newPassManager()
      registerNimPasses(pm)
      # Use the same error collector
      pm.errorCollector = errorCollector

      if verbose:
        echo "  Registered passes:"
        for passDesc in pm.listPasses():
          echo "    ", passDesc

      xlangAst = pm.runPasses(xlangAst)

      if verbose:
        echo "✓ Transformations applied successfully"
    except Exception as e:
      errorCollector.addError(
        tekTransformError,
        "Transformation pipeline failed: " & e.msg,
        location = "Pass manager",
        details = e.getStackTrace()
      )
      errorCollector.reportAndExit()

  # Step 3: Convert XLang AST to Nim AST
  var nimAst: MyNimNode
  try:
    nimAst = convertToNimAST(xlangAst)
    if verbose:
      echo "✓ Nim AST created successfully"
  except Exception as e:
    errorCollector.addError(
      tekConversionError,
      "Failed to convert XLang to Nim AST: " & e.msg,
      location = "xlangtonim_complete",
      details = e.getStackTrace()
    )
    errorCollector.reportAndExit()

  # Step 4: Generate Nim code from AST
  var nimCode: string
  try:
    nimCode = generateNimCode(nimAst)
    if verbose:
      echo "✓ Nim code generated successfully"
  except Exception as e:
    errorCollector.addError(
      tekCodegenError,
      "Failed to generate Nim code: " & e.msg,
      location = "nimastToCode",
      details = e.getStackTrace()
    )
    errorCollector.reportAndExit()

  # Step 5: Write output
  try:
    if outputFile != "":
      writeFile(outputFile, nimCode)
      if verbose:
        echo "✓ Output written to: ", outputFile
    else:
      echo nimCode
  except Exception as e:
    errorCollector.addError(
      tekCodegenError,
      "Failed to write output: " & e.msg,
      location = outputFile,
      details = e.getStackTrace()
    )
    errorCollector.reportAndExit()

  # Report any warnings (success case)
  if errorCollector.hasWarnings():
    errorCollector.reportSummary()

when isMainModule:
  main()
