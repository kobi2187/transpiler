import jsony, xlangtypes


proc parseXLangJson*(jsonString: string): XLangAST =
  result = jsonString.fromJson(XLangAST)

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