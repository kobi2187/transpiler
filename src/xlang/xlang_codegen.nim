## XLang to Nim Code Generator (Runtime)
##
## Reads XLang JSON, converts to XLangNode, generates NimNode AST, outputs Nim code

import os, macros
import xlang_parser
import "../../xlangtonim_complete"

when isMainModule:
  if paramCount() < 1:
    echo "Usage: xlang_codegen <xlang.json>"
    quit(1)

  let inputFile = paramStr(1)

  # Step 1: Parse XLang JSON to XLangNode
  let xlangNode = parseXLangJson(inputFile)

  # Step 2: Convert XLangNode to NimNode AST
  let nimAst = convertXLangToNim(xlangNode)

  # Debug: Show AST tree structure
  when defined(debug):
    echo "=== NimNode AST Tree ==="
    echo treeRepr(nimAst)
    echo ""

  # Step 3: Render NimNode to Nim source code
  echo repr(nimAst)
