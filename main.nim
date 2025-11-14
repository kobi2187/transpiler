import os, parseopt
import xlangtypes
import jsontoxlangtypes
import nimastToCode
import xlangtonim_complete
import src/transforms/pass_manager
import src/transforms/nim_passes
import macros



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

  # Step 1: Parse JSON to XLang AST
  var xlangAst = parseXLangJson(inputFile)

  if verbose:
    echo "✓ XLang AST created successfully"

  # Step 2: Apply transformation passes (unless disabled)
  if not skipTransforms:
    if verbose:
      echo "Running transformation passes..."

    let pm = createNimPassManager()

    if verbose:
      echo "  Registered passes:"
      for passDesc in pm.listPasses():
        echo "    ", passDesc

    xlangAst = pm.runPasses(xlangAst)

    if verbose:
      echo "✓ Transformations applied successfully"

  # Step 3: Convert XLang AST to Nim AST
  let nimAst: NimNode = convertXLangToNim(xlangAst)

  if verbose:
    echo "✓ Nim AST created successfully"

  # Step 4: Generate Nim code from AST
  let nimCode = generateNimCode(nimAst)

  if verbose:
    echo "✓ Nim code generated successfully"

  # Step 5: Write output
  if outputFile != "":
    writeFile(outputFile, nimCode)
    if verbose:
      echo "✓ Output written to: ", outputFile
  else:
    echo nimCode

when isMainModule:
  main()
