## XLang JSON Parser
##
## This module provides functionality to parse XLang intermediate representation
## from JSON format into XLang AST (Nim types).
##
## XLang JSON is produced by language-specific parsers (Python, Go, C#, etc.)

import jsony, json, options
import xlang_types

proc parseXLangJson*(filePath: string): XLangNode =
  ## Parse XLang AST from a JSON file
  ## Returns the root XLangNode
  let jsonString = readFile(filePath)
  result = jsonString.fromJson(XLangNode)

proc parseXLangJsonString*(jsonString: string): XLangNode =
  ## Parse XLang AST from a JSON string
  ## Returns the root XLangNode
  result = jsonString.fromJson(XLangNode)

proc parseXLangASTFromFile*(filePath: string): XLangAST =
  ## Parse a complete XLang AST (sequence of nodes) from a JSON file
  let jsonString = readFile(filePath)
  result = jsonString.fromJson(XLangAST)

proc parseXLangASTFromString*(jsonString: string): XLangAST =
  ## Parse a complete XLang AST (sequence of nodes) from a JSON string
  result = jsonString.fromJson(XLangAST)

# Example XLang JSON structure:
when isMainModule:
  let jsonExample = """
  {
    "kind": "xnkFile",
    "fileName": "example.nim",
    "moduleDecls": [
      {
        "kind": "xnkFuncDecl",
        "funcName": "main",
        "params": [],
        "returnType": null,
        "isAsync": false,
        "body": {
          "kind": "xnkBlockStmt",
          "blockBody": [
            {
              "kind": "xnkCallExpr",
              "callee": {"kind": "xnkIdentifier", "identName": "echo"},
              "args": [{"kind": "xnkStringLit", "literalValue": "Hello, World!"}]
            }
          ]
        }
      }
    ]
  }
  """

  let xlangNode = parseXLangJsonString(jsonExample)
  echo "Parsed XLang node kind: ", xlangNode.kind
  echo "File name: ", xlangNode.fileName
