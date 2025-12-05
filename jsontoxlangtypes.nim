import jsony
import xlangtypes
import os

proc stripBOM(s: string): string =
  ## Strip UTF-8 BOM if present
  if s.len >= 3 and s[0] == '\xEF' and s[1] == '\xBB' and s[2] == '\xBF':
    return s[3..^1]
  return s

proc parseXLangJson*(filePath: string): XLangNode =
  ## Parse XLang AST from a JSON file
  ## Returns the root XLangNode
  var jsonString = readFile(filePath)
  jsonString = stripBOM(jsonString)

  # Use jsony with relaxed parsing
  try:
    result = jsonString.fromJson(XLangNode)
  except JsonError as e:
    # If jsony fails, provide more helpful error message
    raise newException(IOError, "Failed to parse JSON from " & filePath & ": " & e.msg)

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