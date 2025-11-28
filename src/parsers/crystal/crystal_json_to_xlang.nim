## Crystal JSON to XLang Converter
## Converts Crystal parser's semi-XLang JSON output to canonical XLang format
##
## Field Mappings:
## - "className" -> "typeNameDecl"
## - "moduleName" -> "typeNameDecl" (for modules)
## - "funcName" -> already correct
## - "parameters" -> "params"
## - "declarations" -> "moduleDecls" (file level)
## - "statements" -> "blockBody"
## - "condition" -> "ifCondition"/"whileCondition"/"untilCondition"
## - "thenBranch" -> "ifThen"
## - "elseBranch" -> "ifElse"
## - "body" -> "whileBody"/"funcBody"
## - "name" -> "identName" (identifiers)
## - "left"/"right" -> "binaryLeft"/"binaryRight"
## - "operand" -> "unaryOperand"
##
## Crystal-specific features:
## - Unless statements (inverted if)
## - Until statements (inverted while)
## - Symbol literals
## - Instance variables (@var)
## - Class variables (@@var)
## - Global variables ($var)
## - Macros (compile-time code generation)
## - Lib declarations (C bindings)
## - Proc literals and pointers

import json, strutils, sequtils

proc convertNode(node: JsonNode): JsonNode

proc convertFile(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkFile",
    "fileName": "unknown",
    "moduleDecls": newJArray()
  }

  if node.hasKey("declarations"):
    for decl in node["declarations"]:
      result["moduleDecls"].add(convertNode(decl))

proc convertBlockStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkBlockStmt",
    "blockBody": newJArray()
  }

  if node.hasKey("statements"):
    for stmt in node["statements"]:
      result["blockBody"].add(convertNode(stmt))

proc convertClassDecl(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkClassDecl",
    "typeNameDecl": node{"className"}.getStr(""),
    "baseTypes": newJArray(),
    "members": newJArray(),
    "isAbstract": node{"abstract"}.getBool(false)
  }

  # Crystal has superclass instead of baseTypes list
  if node.hasKey("superclass") and node["superclass"].kind != JNull:
    result["baseTypes"].add(convertNode(node["superclass"]))

  # Convert body to members
  if node.hasKey("body") and node["body"].kind != JNull:
    let body = convertNode(node["body"])
    if body.hasKey("blockBody"):
      result["members"] = body["blockBody"]
    else:
      result["members"].add(body)

proc convertModuleDecl(node: JsonNode): JsonNode =
  ## Crystal modules are like traits/interfaces
  result = %* {
    "kind": "xnkModuleDecl",
    "typeNameDecl": node{"moduleName"}.getStr(""),
    "members": newJArray()
  }

  # Convert body to members
  if node.hasKey("body") and node["body"].kind != JNull:
    let body = convertNode(node["body"])
    if body.hasKey("blockBody"):
      result["members"] = body["blockBody"]
    else:
      result["members"].add(body)

proc convertFuncDecl(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkFuncDecl",
    "funcName": node{"funcName"}.getStr(""),
    "params": newJArray(),
    "returnType": newJNull(),
    "funcBody": newJNull(),
    "isAsync": false,
    "isExtern": false,
    "isInline": false
  }

  # Convert parameters
  if node.hasKey("parameters"):
    for param in node["parameters"]:
      result["params"].add(convertNode(param))

  # Convert return type
  if node.hasKey("returnType") and node["returnType"].kind != JNull:
    result["returnType"] = convertNode(node["returnType"])

  # Convert function body
  if node.hasKey("body") and node["body"].kind != JNull:
    result["funcBody"] = convertNode(node["body"])

  # Crystal methods can have receivers (self type)
  if node.hasKey("receiver") and node["receiver"].kind != JNull:
    result["funcReceiver"] = convertNode(node["receiver"])

proc convertMacroDecl(node: JsonNode): JsonNode =
  ## Crystal macros are compile-time code generation
  result = %* {
    "kind": "xnkMacroDecl",
    "macroName": node{"macroName"}.getStr(""),
    "macroParams": newJArray(),
    "macroBody": newJNull()
  }

  if node.hasKey("parameters"):
    for param in node["parameters"]:
      result["macroParams"].add(convertNode(param))

  if node.hasKey("body") and node["body"].kind != JNull:
    result["macroBody"] = convertNode(node["body"])

proc convertParameter(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkParameter",
    "paramName": node{"paramName"}.getStr(""),
    "paramType": newJNull(),
    "paramDefault": newJNull()
  }

  if node.hasKey("paramType") and node["paramType"].kind != JNull:
    result["paramType"] = convertNode(node["paramType"])

  if node.hasKey("defaultValue") and node["defaultValue"].kind != JNull:
    result["paramDefault"] = convertNode(node["defaultValue"])

proc convertCallExpr(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkCallExpr",
    "callName": node{"name"}.getStr(""),
    "callArgs": newJArray(),
    "callReceiver": newJNull()
  }

  if node.hasKey("args"):
    for arg in node["args"]:
      result["callArgs"].add(convertNode(arg))

  if node.hasKey("receiver") and node["receiver"].kind != JNull:
    result["callReceiver"] = convertNode(node["receiver"])

  # Crystal supports named arguments
  if node.hasKey("namedArgs") and node["namedArgs"].kind != JNull:
    result["callNamedArgs"] = newJArray()
    for arg in node["namedArgs"]:
      result["callNamedArgs"].add(convertNode(arg))

proc convertIfStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkIfStmt",
    "ifCondition": newJNull(),
    "ifThen": newJNull(),
    "ifElse": newJNull()
  }

  if node.hasKey("condition") and node["condition"].kind != JNull:
    result["ifCondition"] = convertNode(node["condition"])

  if node.hasKey("thenBranch") and node["thenBranch"].kind != JNull:
    result["ifThen"] = convertNode(node["thenBranch"])

  if node.hasKey("elseBranch") and node["elseBranch"].kind != JNull:
    result["ifElse"] = convertNode(node["elseBranch"])

proc convertUnlessStmt(node: JsonNode): JsonNode =
  ## Crystal unless is like if-not
  ## Convert to if statement with negated condition
  result = %* {
    "kind": "xnkUnlessStmt",
    "unlessCondition": newJNull(),
    "unlessBody": newJNull(),
    "unlessElse": newJNull()
  }

  if node.hasKey("condition") and node["condition"].kind != JNull:
    result["unlessCondition"] = convertNode(node["condition"])

  if node.hasKey("body") and node["body"].kind != JNull:
    result["unlessBody"] = convertNode(node["body"])

  if node.hasKey("elseBody") and node["elseBody"].kind != JNull:
    result["unlessElse"] = convertNode(node["elseBody"])

proc convertWhileStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkWhileStmt",
    "whileCondition": newJNull(),
    "whileBody": newJNull()
  }

  if node.hasKey("condition") and node["condition"].kind != JNull:
    result["whileCondition"] = convertNode(node["condition"])

  if node.hasKey("body") and node["body"].kind != JNull:
    result["whileBody"] = convertNode(node["body"])

proc convertUntilStmt(node: JsonNode): JsonNode =
  ## Crystal until is like while-not
  result = %* {
    "kind": "xnkUntilStmt",
    "untilCondition": newJNull(),
    "untilBody": newJNull()
  }

  if node.hasKey("condition") and node["condition"].kind != JNull:
    result["untilCondition"] = convertNode(node["condition"])

  if node.hasKey("body") and node["body"].kind != JNull:
    result["untilBody"] = convertNode(node["body"])

proc convertSwitchStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkSwitchStmt",
    "switchExpr": newJNull(),
    "switchCases": newJArray(),
    "switchDefault": newJNull()
  }

  if node.hasKey("subject") and node["subject"].kind != JNull:
    result["switchExpr"] = convertNode(node["subject"])

  if node.hasKey("whens"):
    for whenNode in node["whens"]:
      result["switchCases"].add(convertNode(whenNode))

  if node.hasKey("elseBody") and node["elseBody"].kind != JNull:
    result["switchDefault"] = convertNode(node["elseBody"])

proc convertSwitchCase(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkSwitchCase",
    "caseConditions": newJArray(),
    "caseBody": newJNull()
  }

  if node.hasKey("conditions"):
    for cond in node["conditions"]:
      result["caseConditions"].add(convertNode(cond))

  if node.hasKey("body") and node["body"].kind != JNull:
    result["caseBody"] = convertNode(node["body"])

proc convertAssignExpr(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkAssignExpr",
    "assignTarget": newJNull(),
    "assignValue": newJNull()
  }

  if node.hasKey("target") and node["target"].kind != JNull:
    result["assignTarget"] = convertNode(node["target"])

  if node.hasKey("value") and node["value"].kind != JNull:
    result["assignValue"] = convertNode(node["value"])

proc convertIdentifier(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkIdentifier",
    "identName": node{"name"}.getStr("")
  }

proc convertInstanceVar(node: JsonNode): JsonNode =
  ## Crystal instance variables (@name)
  result = %* {
    "kind": "xnkInstanceVar",
    "varName": node{"name"}.getStr("")
  }

proc convertClassVar(node: JsonNode): JsonNode =
  ## Crystal class variables (@@name)
  result = %* {
    "kind": "xnkClassVar",
    "varName": node{"name"}.getStr("")
  }

proc convertGlobalVar(node: JsonNode): JsonNode =
  ## Crystal global variables ($name)
  result = %* {
    "kind": "xnkGlobalVar",
    "varName": node{"name"}.getStr("")
  }

proc convertBinaryExpr(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkBinaryExpr",
    "binaryOp": node{"operator"}.getStr(""),
    "binaryLeft": newJNull(),
    "binaryRight": newJNull()
  }

  if node.hasKey("left") and node["left"].kind != JNull:
    result["binaryLeft"] = convertNode(node["left"])

  if node.hasKey("right") and node["right"].kind != JNull:
    result["binaryRight"] = convertNode(node["right"])

proc convertUnaryExpr(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkUnaryExpr",
    "unaryOp": node{"operator"}.getStr(""),
    "unaryOperand": newJNull()
  }

  if node.hasKey("operand") and node["operand"].kind != JNull:
    result["unaryOperand"] = convertNode(node["operand"])

proc convertStringLit(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkStringLit",
    "stringValue": node{"value"}.getStr("")
  }

proc convertNumberLit(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkNumberLit",
    "numberValue": node{"value"}.getStr("")
  }

proc convertSymbolLit(node: JsonNode): JsonNode =
  ## Crystal symbol literals (:symbol)
  result = %* {
    "kind": "xnkSymbolLit",
    "symbolValue": node{"value"}.getStr("")
  }

proc convertArrayLit(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkArrayLit",
    "arrayElements": newJArray()
  }

  if node.hasKey("elements"):
    for elem in node["elements"]:
      result["arrayElements"].add(convertNode(elem))

proc convertDictLit(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkDictLit",
    "dictEntries": newJArray()
  }

  if node.hasKey("entries"):
    for entry in node["entries"]:
      let convertedEntry = %* {
        "key": convertNode(entry["key"]),
        "value": convertNode(entry["value"])
      }
      result["dictEntries"].add(convertedEntry)

proc convertRequire(node: JsonNode): JsonNode =
  ## Crystal require statements
  result = %* {
    "kind": "xnkImport",
    "importPath": node{"path"}.getStr(""),
    "importAlias": newJNull(),
    "importSymbols": newJArray()
  }

proc convertInclude(node: JsonNode): JsonNode =
  ## Crystal include (mixin module into class)
  result = %* {
    "kind": "xnkInclude",
    "includeName": newJNull()
  }

  if node.hasKey("name") and node["name"].kind != JNull:
    result["includeName"] = convertNode(node["name"])

proc convertExtend(node: JsonNode): JsonNode =
  ## Crystal extend (add module methods as class methods)
  result = %* {
    "kind": "xnkExtend",
    "extendName": newJNull()
  }

  if node.hasKey("name") and node["name"].kind != JNull:
    result["extendName"] = convertNode(node["name"])

proc convertAlias(node: JsonNode): JsonNode =
  ## Crystal type aliases
  result = %* {
    "kind": "xnkTypeAlias",
    "aliasName": node{"name"}.getStr(""),
    "aliasTarget": newJNull()
  }

  if node.hasKey("value") and node["value"].kind != JNull:
    result["aliasTarget"] = convertNode(node["value"])

proc convertTypeDecl(node: JsonNode): JsonNode =
  ## Crystal type declarations (var : Type = value)
  result = %* {
    "kind": "xnkVarDecl",
    "declName": "",
    "declType": newJNull(),
    "declInit": newJNull(),
    "isConst": false,
    "isMutable": true
  }

  if node.hasKey("var") and node["var"].kind != JNull:
    let varNode = convertNode(node["var"])
    if varNode.hasKey("identName"):
      result["declName"] = varNode["identName"]

  if node.hasKey("declaredType") and node["declaredType"].kind != JNull:
    result["declType"] = convertNode(node["declaredType"])

  if node.hasKey("value") and node["value"].kind != JNull:
    result["declInit"] = convertNode(node["value"])

proc convertUninitializedVar(node: JsonNode): JsonNode =
  ## Crystal uninitialized variables
  result = %* {
    "kind": "xnkVarDecl",
    "declName": "",
    "declType": newJNull(),
    "declInit": newJNull(),
    "isConst": false,
    "isMutable": true,
    "isUninitialized": true
  }

  if node.hasKey("var") and node["var"].kind != JNull:
    let varNode = convertNode(node["var"])
    if varNode.hasKey("identName"):
      result["declName"] = varNode["identName"]

  if node.hasKey("declaredType") and node["declaredType"].kind != JNull:
    result["declType"] = convertNode(node["declaredType"])

proc convertGenericType(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkGenericType",
    "genericBase": newJNull(),
    "genericArgs": newJArray()
  }

  if node.hasKey("name") and node["name"].kind != JNull:
    result["genericBase"] = convertNode(node["name"])

  if node.hasKey("typeArgs"):
    for arg in node["typeArgs"]:
      result["genericArgs"].add(convertNode(arg))

proc convertUnionType(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkUnionType",
    "unionTypes": newJArray()
  }

  if node.hasKey("types"):
    for typeNode in node["types"]:
      result["unionTypes"].add(convertNode(typeNode))

proc convertFunctionType(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkFunctionType",
    "funcTypeParams": newJArray(),
    "funcTypeReturn": newJNull()
  }

  if node.hasKey("inputs"):
    for input in node["inputs"]:
      result["funcTypeParams"].add(convertNode(input))

  if node.hasKey("output") and node["output"].kind != JNull:
    result["funcTypeReturn"] = convertNode(node["output"])

proc convertEnumDecl(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkEnumDecl",
    "enumName": node{"name"}.getStr(""),
    "enumBaseType": newJNull(),
    "enumMembers": newJArray()
  }

  if node.hasKey("members"):
    for member in node["members"]:
      result["enumMembers"].add(convertNode(member))

proc convertLibDecl(node: JsonNode): JsonNode =
  ## Crystal lib declarations (C FFI)
  result = %* {
    "kind": "xnkLibDecl",
    "libName": node{"name"}.getStr(""),
    "libBody": newJNull()
  }

  if node.hasKey("body") and node["body"].kind != JNull:
    result["libBody"] = convertNode(node["body"])

proc convertCFuncDecl(node: JsonNode): JsonNode =
  ## Crystal C function declarations inside lib blocks
  result = %* {
    "kind": "xnkCFuncDecl",
    "funcName": node{"name"}.getStr(""),
    "params": newJArray(),
    "returnType": newJNull(),
    "funcBody": newJNull()
  }

  if node.hasKey("args"):
    for arg in node["args"]:
      result["params"].add(convertNode(arg))

  if node.hasKey("returnType") and node["returnType"].kind != JNull:
    result["returnType"] = convertNode(node["returnType"])

  if node.hasKey("body") and node["body"].kind != JNull:
    result["funcBody"] = convertNode(node["body"])

proc convertExternalVar(node: JsonNode): JsonNode =
  ## Crystal external variables (C variables)
  result = %* {
    "kind": "xnkExternalVar",
    "varName": node{"name"}.getStr(""),
    "varType": newJNull()
  }

  if node.hasKey("type") and node["type"].kind != JNull:
    result["varType"] = convertNode(node["type"])

proc convertProcLiteral(node: JsonNode): JsonNode =
  ## Crystal proc literals (lambda/closure)
  result = %* {
    "kind": "xnkProcLiteral",
    "procDef": newJNull()
  }

  if node.hasKey("def") and node["def"].kind != JNull:
    result["procDef"] = convertNode(node["def"])

proc convertProcPointer(node: JsonNode): JsonNode =
  ## Crystal proc pointers
  result = %* {
    "kind": "xnkProcPointer",
    "procObj": newJNull(),
    "procName": node{"name"}.getStr(""),
    "procArgs": newJArray()
  }

  if node.hasKey("obj") and node["obj"].kind != JNull:
    result["procObj"] = convertNode(node["obj"])

  if node.hasKey("args"):
    for arg in node["args"]:
      result["procArgs"].add(convertNode(arg))

proc convertNode(node: JsonNode): JsonNode =
  if node.kind != JObject:
    return node

  if not node.hasKey("kind"):
    return node

  let kind = node["kind"].getStr()

  case kind
  of "xnkFile":
    result = convertFile(node)
  of "xnkBlockStmt":
    result = convertBlockStmt(node)
  of "xnkClassDecl":
    result = convertClassDecl(node)
  of "xnkModuleDecl":
    result = convertModuleDecl(node)
  of "xnkFuncDecl":
    result = convertFuncDecl(node)
  of "xnkMacroDecl":
    result = convertMacroDecl(node)
  of "xnkParameter":
    result = convertParameter(node)
  of "xnkCallExpr":
    result = convertCallExpr(node)
  of "xnkIfStmt":
    result = convertIfStmt(node)
  of "xnkUnlessStmt":
    result = convertUnlessStmt(node)
  of "xnkWhileStmt":
    result = convertWhileStmt(node)
  of "xnkUntilStmt":
    result = convertUntilStmt(node)
  of "xnkSwitchStmt":
    result = convertSwitchStmt(node)
  of "xnkSwitchCase":
    result = convertSwitchCase(node)
  of "xnkAssignExpr":
    result = convertAssignExpr(node)
  of "xnkIdentifier":
    result = convertIdentifier(node)
  of "xnkInstanceVar":
    result = convertInstanceVar(node)
  of "xnkClassVar":
    result = convertClassVar(node)
  of "xnkGlobalVar":
    result = convertGlobalVar(node)
  of "xnkBinaryExpr":
    result = convertBinaryExpr(node)
  of "xnkUnaryExpr":
    result = convertUnaryExpr(node)
  of "xnkStringLit":
    result = convertStringLit(node)
  of "xnkNumberLit":
    result = convertNumberLit(node)
  of "xnkSymbolLit":
    result = convertSymbolLit(node)
  of "xnkArrayLit":
    result = convertArrayLit(node)
  of "xnkDictLit":
    result = convertDictLit(node)
  of "xnkRequire":
    result = convertRequire(node)
  of "xnkInclude":
    result = convertInclude(node)
  of "xnkExtend":
    result = convertExtend(node)
  of "xnkAlias":
    result = convertAlias(node)
  of "xnkTypeDecl":
    result = convertTypeDecl(node)
  of "xnkUninitializedVar":
    result = convertUninitializedVar(node)
  of "xnkGenericType":
    result = convertGenericType(node)
  of "xnkUnionType":
    result = convertUnionType(node)
  of "xnkFunctionType":
    result = convertFunctionType(node)
  of "xnkEnumDecl":
    result = convertEnumDecl(node)
  of "xnkLibDecl":
    result = convertLibDecl(node)
  of "xnkCFuncDecl":
    result = convertCFuncDecl(node)
  of "xnkExternalVar":
    result = convertExternalVar(node)
  of "xnkProcLiteral":
    result = convertProcLiteral(node)
  of "xnkProcPointer":
    result = convertProcPointer(node)
  of "xnkUnknown":
    result = node
  else:
    # Unknown node kind - pass through
    result = node

proc convertCrystalJsonToXLang*(input: string): string =
  ## Main entry point: converts Crystal parser JSON to canonical XLang JSON
  let inputJson = parseJson(input)
  let outputJson = convertNode(inputJson)
  result = $outputJson

when isMainModule:
  import os

  if paramCount() < 1:
    echo "Usage: crystal_json_to_xlang <input.json>"
    quit(1)

  let inputFile = paramStr(1)
  let inputJson = readFile(inputFile)
  let outputJson = convertCrystalJsonToXLang(inputJson)
  echo outputJson
