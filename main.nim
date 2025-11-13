import os, parseopt
import xlangtypes, jsontoxlangtypes, nimastToCode, xlangtonim
# import xlangast, nimast, codegeneration



proc main() =
  var inputFile, outputFile: string
  var verbose = false

  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      inputFile = key
    of cmdLongOption, cmdShortOption:
      case key
      of "out", "o": outputFile = val
      of "verbose", "v": verbose = true
    of cmdEnd: assert(false)  # Should not happen
  
  if inputFile == "":
    quit("No input file specified")

  if verbose:
    echo "Processing input file: ", inputFile

  let xlangAst = parseXLangJson(inputFile)
  
  if verbose:
    echo "XLang AST created successfully"

  let nimAst: NimNode = convertXLangASTToNimAST(xlangAst)

  if verbose:
    echo "Nim AST created successfully"

  let nimCode = generateNimCode(nimAst)

  if verbose:
    echo "Nim code generated successfully"

  if outputFile != "":
    writeFile(outputFile, nimCode)
    if verbose:
      echo "Output written to: ", outputFile
  else:
    echo nimCode

when isMainModule:
  main()
