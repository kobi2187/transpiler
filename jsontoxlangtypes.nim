import jsony
import xlangtypes
import os

proc parseXLangJson*(filePath: string): XLangNode =
  ## Parse XLang AST from a JSON file
  ## Returns the root XLangNode
  let jsonString = readFile(filePath)
  result = jsonString.fromJson(XLangNode)

proc parseXLangJsonString*(jsonString: string): XLangNode =
  ## Parse XLang AST from a JSON string
  ## Returns the root XLangNode
  result = jsonString.fromJson(XLangNode)

proc example() =

  # Usage example
  let jsonInput = """
  [
  {
    "kind": "xnkFile",
    "fileName": "example.nim",
    "declarations": [
    {
        "kind": "xnkFuncDecl",
        "funcName": "main",
        "params": [],
        "returnType": null,
        "body": {
        "kind": "xnkBlockStmt",
        "statements": [
            {
            "kind": "xnkCallExpr",
            "callee": {"kind": "xnkIdent", "name": "echo"},
            "arguments": [{"kind": "xnkStringLit", "value": "Hello, World!"}]
              }
          ]
          }
      }
      ]
  }
  ]
  """

  let xlangAst = parseXLangJson(jsonInput)
  # echo "Parsed XLang AST: ", $xlangAst