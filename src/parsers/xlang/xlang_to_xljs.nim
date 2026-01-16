## XLang to XLJS Converter
## Main entry point for parsing xlang text and outputting XLJS (JSON).
##
## Usage:
##   xlang_to_xljs input.xlang [output.json]
##   xlang_to_xljs --validate input.xlang
##   xlang_to_xljs --stdin < input.xlang

import std/[os, json, strutils]
import xlang_parser
import ../../core/xlangtypes

proc printUsage() =
  echo """
XLang Parser - Parse xlang text format to XLJS (JSON)

Usage:
  xlang_to_xljs <input.xlang> [output.json]   Parse file and output JSON
  xlang_to_xljs --validate <input.xlang>       Validate syntax only
  xlang_to_xljs --stdin                        Read from stdin
  xlang_to_xljs --help                         Show this help

Options:
  --validate   Only check syntax, don't output JSON
  --stdin      Read input from stdin instead of file
  --compact    Output compact JSON (no pretty printing)
  --help       Show this help message

Examples:
  xlang_to_xljs mycode.xlang                   Output JSON to stdout
  xlang_to_xljs mycode.xlang output.json       Output JSON to file
  xlang_to_xljs --validate mycode.xlang        Check syntax only
  echo "module test" | xlang_to_xljs --stdin   Parse from stdin
"""

proc main() =
  var args = commandLineParams()

  if args.len == 0 or "--help" in args:
    printUsage()
    quit(0)

  var validateOnly = false
  var readStdin = false
  var compact = false
  var inputFile = ""
  var outputFile = ""

  # Parse arguments
  var i = 0
  while i < args.len:
    let arg = args[i]
    case arg
    of "--validate":
      validateOnly = true
    of "--stdin":
      readStdin = true
    of "--compact":
      compact = true
    of "--help":
      printUsage()
      quit(0)
    else:
      if inputFile.len == 0:
        inputFile = arg
      else:
        outputFile = arg
    inc i

  # Read input
  var source: string
  if readStdin:
    source = stdin.readAll()
  elif inputFile.len > 0:
    if not fileExists(inputFile):
      echo "Error: File not found: " & inputFile
      quit(1)
    source = readFile(inputFile)
  else:
    echo "Error: No input specified"
    printUsage()
    quit(1)

  # Validate only
  if validateOnly:
    let (valid, errors) = validate(source)
    if valid:
      echo "Syntax OK"
      quit(0)
    else:
      echo "Syntax errors:"
      for err in errors:
        echo "  " & err
      quit(1)

  # Parse and convert to JSON
  try:
    let ast = parse(source)
    let jsonStr = if compact: $ast.toJson() else: ast.toJsonString()

    if outputFile.len > 0:
      writeFile(outputFile, jsonStr)
      echo "Output written to: " & outputFile
    else:
      echo jsonStr

  except ParseError as e:
    echo "Parse error: " & e.msg
    quit(1)
  except Exception as e:
    echo "Error: " & e.msg
    quit(1)

when isMainModule:
  main()
