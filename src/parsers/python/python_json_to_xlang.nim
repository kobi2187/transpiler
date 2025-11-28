## Python Parser JSON to XLang JSON Converter
##
## Converts the JSON output from python_to_xlang.py to canonical XLang JSON format
## that matches the xlang_types.nim specification.
##
## Usage: nim c -r python_json_to_xlang.nim input.xlang.json > output.canonical.xlang.json

import json, options, strutils, os

proc convertNode(node: JsonNode): JsonNode

proc convertFile(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkFile",
    "fileName": "",
    "moduleDecls": []
  }
  if node.hasKey("declarations"):
    result["moduleDecls"] = newJArray()
    for decl in node["declarations"]:
      result["moduleDecls"].add(convertNode(decl))

proc convertFuncDecl(node: JsonNode): JsonNode =
  result = %* {
    "kind": node["kind"].getStr,
    "funcName": node["name"].getStr,
    "params": [],
    "returnType": nil,
    "body": %*{"kind": "xnkBlockStmt", "blockBody": []},
    "isAsync": node.getOrDefault("isAsync").getBool(false)
  }

  # Convert parameters
  if node.hasKey("parameters"):
    for param in node["parameters"]:
      result["params"].add(convertNode(param))

  # Convert return type
  if node.hasKey("returnType") and not node["returnType"].isNil:
    result["returnType"] = convertNode(node["returnType"])

  # Convert body
  if node.hasKey("body"):
    result["body"] = convertNode(node["body"])

proc convertClassDecl(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkClassDecl",
    "typeNameDecl": node["name"].getStr,
    "baseTypes": [],
    "members": []
  }

  if node.hasKey("baseTypes"):
    for base in node["baseTypes"]:
      result["baseTypes"].add(convertNode(base))

  if node.hasKey("members"):
    for member in node["members"]:
      result["members"].add(convertNode(member))

proc convertVarDecl(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkVarDecl",
    "declName": "",
    "declType": nil,
    "initializer": nil
  }

  # Handle different Python variable declaration patterns
  if node.hasKey("target"):
    # Single target (annotated assignment)
    let target = convertNode(node["target"])
    if target.hasKey("identName"):
      result["declName"] = target["identName"]
  elif node.hasKey("targets"):
    # Multiple targets (regular assignment) - take first for now
    if node["targets"].len > 0:
      let target = convertNode(node["targets"][0])
      if target.hasKey("identName"):
        result["declName"] = target["identName"]

  if node.hasKey("type") and not node["type"].isNil:
    result["declType"] = convertNode(node["type"])

  if node.hasKey("value") and not node["value"].isNil:
    result["initializer"] = convertNode(node["value"])

proc convertReturnStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkReturnStmt",
    "returnExpr": nil
  }

  if node.hasKey("expression") and not node["expression"].isNil:
    result["returnExpr"] = convertNode(node["expression"])

proc convertIfStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkIfStmt",
    "ifCondition": %*{"kind": "xnkNoneLit"},
    "ifBody": %*{"kind": "xnkBlockStmt", "blockBody": []},
    "elseBody": nil
  }

  if node.hasKey("condition"):
    result["ifCondition"] = convertNode(node["condition"])

  if node.hasKey("thenBranch"):
    var blockBody = newJArray()
    for stmt in node["thenBranch"]:
      blockBody.add(convertNode(stmt))
    result["ifBody"] = %* {"kind": "xnkBlockStmt", "blockBody": blockBody}

  if node.hasKey("elseBranch") and node["elseBranch"].len > 0:
    var blockBody = newJArray()
    for stmt in node["elseBranch"]:
      blockBody.add(convertNode(stmt))
    result["elseBody"] = %* {"kind": "xnkBlockStmt", "blockBody": blockBody}

proc convertWhileStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkWhileStmt",
    "whileCondition": %*{"kind": "xnkNoneLit"},
    "whileBody": %*{"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("condition"):
    result["whileCondition"] = convertNode(node["condition"])

  if node.hasKey("body"):
    var blockBody = newJArray()
    for stmt in node["body"]:
      blockBody.add(convertNode(stmt))
    result["whileBody"] = %* {"kind": "xnkBlockStmt", "blockBody": blockBody}

proc convertForeachStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkForeachStmt",
    "foreachVar": %*{"kind": "xnkIdentifier", "identName": ""},
    "foreachIter": %*{"kind": "xnkNoneLit"},
    "foreachBody": %*{"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("variable"):
    result["foreachVar"] = convertNode(node["variable"])

  if node.hasKey("iterable"):
    result["foreachIter"] = convertNode(node["iterable"])

  if node.hasKey("body"):
    var blockBody = newJArray()
    for stmt in node["body"]:
      blockBody.add(convertNode(stmt))
    result["foreachBody"] = %* {"kind": "xnkBlockStmt", "blockBody": blockBody}

proc convertTryStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkTryStmt",
    "tryBody": %*{"kind": "xnkBlockStmt", "blockBody": []},
    "catchClauses": [],
    "finallyClause": nil
  }

  if node.hasKey("body"):
    var blockBody = newJArray()
    for stmt in node["body"]:
      blockBody.add(convertNode(stmt))
    result["tryBody"] = %* {"kind": "xnkBlockStmt", "blockBody": blockBody}

  if node.hasKey("handlers"):
    for handler in node["handlers"]:
      result["catchClauses"].add(convertNode(handler))

  if node.hasKey("finalbody") and node["finalbody"].len > 0:
    var blockBody = newJArray()
    for stmt in node["finalbody"]:
      blockBody.add(convertNode(stmt))
    result["finallyClause"] = %* {"kind": "xnkFinallyStmt", "finallyBody": %* {"kind": "xnkBlockStmt", "blockBody": blockBody}}

proc convertCatchStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkCatchStmt",
    "catchType": nil,
    "catchVar": nil,
    "catchBody": %*{"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("type") and not node["type"].isNil:
    result["catchType"] = convertNode(node["type"])

  if node.hasKey("name") and not node["name"].isNil:
    result["catchVar"] = node["name"]

  if node.hasKey("body"):
    var blockBody = newJArray()
    for stmt in node["body"]:
      blockBody.add(convertNode(stmt))
    result["catchBody"] = %* {"kind": "xnkBlockStmt", "blockBody": blockBody}

proc convertBinaryExpr(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkBinaryExpr",
    "binaryLeft": %*{"kind": "xnkNoneLit"},
    "binaryOp": "",
    "binaryRight": %*{"kind": "xnkNoneLit"}
  }

  if node.hasKey("left"):
    result["binaryLeft"] = convertNode(node["left"])

  if node.hasKey("operator"):
    result["binaryOp"] = node["operator"]

  if node.hasKey("right"):
    result["binaryRight"] = convertNode(node["right"])

proc convertCallExpr(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkCallExpr",
    "callee": %*{"kind": "xnkIdentifier", "identName": ""},
    "args": []
  }

  if node.hasKey("function"):
    result["callee"] = convertNode(node["function"])

  if node.hasKey("arguments"):
    for arg in node["arguments"]:
      result["args"].add(convertNode(arg))

proc convertIdentifier(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkIdentifier",
    "identName": node["name"].getStr
  }

proc convertLiteral(node: JsonNode, kind: string): JsonNode =
  case kind
  of "xnkIntLit", "xnkFloatLit", "xnkStringLit", "xnkCharLit":
    result = %* {
      "kind": kind,
      "literalValue": node["value"]
    }
  of "xnkBoolLit":
    result = %* {
      "kind": "xnkBoolLit",
      "boolValue": node["value"]
    }
  of "xnkNoneLit":
    result = %* {"kind": "xnkNoneLit"}
  else:
    result = node

proc convertNode(node: JsonNode): JsonNode =
  if node.isNil or node.kind == JNull:
    return newJNull()

  let kind = node["kind"].getStr

  case kind
  of "xnkFile":
    result = convertFile(node)
  of "xnkFuncDecl", "xnkMethodDecl":
    result = convertFuncDecl(node)
  of "xnkClassDecl":
    result = convertClassDecl(node)
  of "xnkVarDecl":
    result = convertVarDecl(node)
  of "xnkReturnStmt":
    result = convertReturnStmt(node)
  of "xnkIfStmt":
    result = convertIfStmt(node)
  of "xnkWhileStmt":
    result = convertWhileStmt(node)
  of "xnkForeachStmt":
    result = convertForeachStmt(node)
  of "xnkTryStmt":
    result = convertTryStmt(node)
  of "xnkCatchStmt":
    result = convertCatchStmt(node)
  of "xnkBinaryExpr":
    result = convertBinaryExpr(node)
  of "xnkCallExpr":
    result = convertCallExpr(node)
  of "xnkIdentifier":
    result = convertIdentifier(node)
  of "xnkIntLit", "xnkFloatLit", "xnkStringLit", "xnkCharLit", "xnkBoolLit", "xnkNoneLit":
    result = convertLiteral(node, kind)
  of "xnkPassStmt", "xnkBreakStmt", "xnkContinueStmt":
    result = node  # These have no fields to convert
  else:
    # Pass through unknown nodes as-is
    result = node

when isMainModule:
  if paramCount() < 1:
    echo "Usage: python_json_to_xlang <input.xlang.json>"
    quit(1)

  let inputFile = paramStr(1)
  let jsonContent = readFile(inputFile)
  let inputJson = parseJson(jsonContent)

  let outputJson = convertNode(inputJson)

  echo pretty(outputJson, indent=2)
