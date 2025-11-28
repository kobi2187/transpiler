## D JSON to XLang Converter
## Converts D parser's semi-XLang JSON output to canonical XLang format
##
## Field Mappings:
## - "name" -> "funcName" (functions)
## - "name" -> "typeNameDecl" (classes/structs/interfaces)
## - "name" -> "declName" (variables, parameters)
## - "name" -> "enumName" (enums)
## - "parameters" -> "params"
## - "declarations" -> "moduleDecls" (file level)
## - "statements" -> "blockBody"
## - "condition" -> "ifCondition" (if statements)
## - "condition" -> "whileCondition" (while statements)
## - "thenBranch" -> "ifThen"
## - "elseBranch" -> "ifElse"
## - "body" -> "whileBody" (while statements)
## - "body" -> "funcBody" (functions)

import json, strutils, sequtils

proc convertNode(node: JsonNode): JsonNode

proc convertFile(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkFile",
    "fileName": node{"fileName"}.getStr("unknown"),
    "moduleDecls": newJArray()
  }

  if node.hasKey("declarations"):
    for decl in node["declarations"]:
      result["moduleDecls"].add(convertNode(decl))

proc convertFuncDecl(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkFuncDecl",
    "funcName": node{"name"}.getStr(""),
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

proc convertClassDecl(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkClassDecl",
    "typeNameDecl": node{"name"}.getStr(""),
    "baseTypes": newJArray(),
    "members": newJArray(),
    "isAbstract": false
  }

  # Convert base types
  if node.hasKey("baseTypes"):
    for baseType in node["baseTypes"]:
      result["baseTypes"].add(convertNode(baseType))

  # Convert members
  if node.hasKey("members"):
    for member in node["members"]:
      result["members"].add(convertNode(member))

proc convertStructDecl(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkStructDecl",
    "typeNameDecl": node{"name"}.getStr(""),
    "members": newJArray()
  }

  # Convert members
  if node.hasKey("members"):
    for member in node["members"]:
      result["members"].add(convertNode(member))

proc convertInterfaceDecl(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkInterfaceDecl",
    "typeNameDecl": node{"name"}.getStr(""),
    "baseTypes": newJArray(),
    "members": newJArray()
  }

  # Convert base types
  if node.hasKey("baseTypes"):
    for baseType in node["baseTypes"]:
      result["baseTypes"].add(convertNode(baseType))

  # Convert members
  if node.hasKey("members"):
    for member in node["members"]:
      result["members"].add(convertNode(member))

proc convertEnumDecl(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkEnumDecl",
    "enumName": node{"name"}.getStr(""),
    "enumBaseType": newJNull(),
    "enumMembers": newJArray()
  }

  # Convert base type
  if node.hasKey("baseType") and node["baseType"].kind != JNull:
    result["enumBaseType"] = convertNode(node["baseType"])

  # Convert enum members
  if node.hasKey("members"):
    for member in node["members"]:
      var enumMember = %* {
        "kind": "xnkEnumMember",
        "enumMemberName": member{"name"}.getStr(""),
        "enumMemberValue": newJNull()
      }

      if member.hasKey("value") and member["value"].kind != JNull:
        enumMember["enumMemberValue"] = convertNode(member["value"])

      result["enumMembers"].add(enumMember)

proc convertTemplateDecl(node: JsonNode): JsonNode =
  ## D templates are compile-time code generation constructs
  ## Map to a generic template/macro node
  result = %* {
    "kind": "xnkTemplateDecl",
    "templateName": node{"name"}.getStr(""),
    "templateParams": newJArray(),
    "templateBody": newJArray()
  }

  # Convert template parameters
  if node.hasKey("parameters"):
    for param in node["parameters"]:
      result["templateParams"].add(convertNode(param))

  # Convert template body declarations
  if node.hasKey("declarations"):
    for decl in node["declarations"]:
      result["templateBody"].add(convertNode(decl))

proc convertMixinDecl(node: JsonNode): JsonNode =
  ## D mixins are compile-time code injection
  ## Map to a mixin/macro expansion node
  result = %* {
    "kind": "xnkMixinDecl",
    "mixinExpr": newJNull()
  }

  if node.hasKey("expression") and node["expression"].kind != JNull:
    result["mixinExpr"] = convertNode(node["expression"])

proc convertAliasDecl(node: JsonNode): JsonNode =
  ## D alias declarations (type aliases)
  result = %* {
    "kind": "xnkTypeAlias",
    "aliasName": node{"name"}.getStr(""),
    "aliasTarget": newJNull()
  }

  if node.hasKey("type") and node["type"].kind != JNull:
    result["aliasTarget"] = convertNode(node["type"])

proc convertVarDecl(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkVarDecl",
    "declName": "",
    "declType": newJNull(),
    "declInit": newJNull(),
    "isConst": false,
    "isMutable": true
  }

  # Handle D's variable declarators (can have multiple in one declaration)
  if node.hasKey("declarators") and node["declarators"].len > 0:
    let firstDeclarator = node["declarators"][0]
    result["declName"] = firstDeclarator{"name"}.getStr("")

    if firstDeclarator.hasKey("initializer") and firstDeclarator["initializer"].kind != JNull:
      result["declInit"] = convertNode(firstDeclarator["initializer"])

  # Variable type
  if node.hasKey("type") and node["type"].kind != JNull:
    result["declType"] = convertNode(node["type"])

proc convertImport(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkImport",
    "importPath": node{"path"}.getStr(""),
    "importAlias": newJNull(),
    "importSymbols": newJArray()
  }

  if node.hasKey("importAlias") and node["importAlias"].kind != JNull:
    result["importAlias"] = node["importAlias"]

proc convertStaticAssert(node: JsonNode): JsonNode =
  ## D static assertions (compile-time checks)
  result = %* {
    "kind": "xnkStaticAssert",
    "assertCondition": newJNull(),
    "assertMessage": newJNull()
  }

  if node.hasKey("condition") and node["condition"].kind != JNull:
    result["assertCondition"] = convertNode(node["condition"])

  if node.hasKey("message") and node["message"].kind != JNull:
    result["assertMessage"] = convertNode(node["message"])

proc convertParameter(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkParameter",
    "paramName": node{"name"}.getStr(""),
    "paramType": newJNull(),
    "paramDefault": newJNull()
  }

  if node.hasKey("type") and node["type"].kind != JNull:
    result["paramType"] = convertNode(node["type"])

  if node.hasKey("defaultValue") and node["defaultValue"].kind != JNull:
    result["paramDefault"] = convertNode(node["defaultValue"])

proc convertTemplateParameter(node: JsonNode): JsonNode =
  ## D template parameters can be types or values
  result = %* {
    "kind": "xnkTemplateParameter",
    "templateParamName": node{"name"}.getStr(""),
    "templateParamKind": node{"paramType"}.getStr("type")
  }

  # If it's a value parameter, include the type
  if node.hasKey("type") and node["type"].kind != JNull:
    result["templateParamType"] = convertNode(node["type"])

proc convertNamedType(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkNamedType",
    "typeName": node{"name"}.getStr("")
  }

proc convertBlockStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkBlockStmt",
    "blockBody": newJArray()
  }

  if node.hasKey("statements"):
    for stmt in node["statements"]:
      result["blockBody"].add(convertNode(stmt))

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

proc convertForStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkForStmt",
    "forInit": newJNull(),
    "forCondition": newJNull(),
    "forIncrement": newJNull(),
    "forBody": newJNull()
  }

  if node.hasKey("init") and node["init"].kind != JNull:
    result["forInit"] = convertNode(node["init"])

  if node.hasKey("condition") and node["condition"].kind != JNull:
    result["forCondition"] = convertNode(node["condition"])

  if node.hasKey("increment") and node["increment"].kind != JNull:
    result["forIncrement"] = convertNode(node["increment"])

  if node.hasKey("body") and node["body"].kind != JNull:
    result["forBody"] = convertNode(node["body"])

proc convertForeachStmt(node: JsonNode): JsonNode =
  ## D foreach is similar to range-based for loops
  result = %* {
    "kind": "xnkForStmt",
    "forIterator": newJNull(),
    "forBody": newJNull(),
    "forIsForeach": true
  }

  if node.hasKey("iterator") and node["iterator"].kind != JNull:
    result["forIterator"] = convertNode(node["iterator"])

  if node.hasKey("body") and node["body"].kind != JNull:
    result["forBody"] = convertNode(node["body"])

proc convertSwitchStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkSwitchStmt",
    "switchExpr": newJNull(),
    "switchCases": newJArray()
  }

  if node.hasKey("expression") and node["expression"].kind != JNull:
    result["switchExpr"] = convertNode(node["expression"])

proc convertReturnStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkReturnStmt",
    "returnExpr": newJNull()
  }

  if node.hasKey("expression") and node["expression"].kind != JNull:
    result["returnExpr"] = convertNode(node["expression"])

proc convertExpression(node: JsonNode): JsonNode =
  ## Generic expression node
  ## The D parser stores expression text directly
  result = %* {
    "kind": "xnkExpression",
    "exprText": node{"text"}.getStr("")
  }

proc convertInitializer(node: JsonNode): JsonNode =
  ## D initializers can be complex (struct literals, array literals, etc.)
  result = %* {
    "kind": "xnkInitializer"
  }

proc convertNode(node: JsonNode): JsonNode =
  if node.kind != JObject:
    return node

  if not node.hasKey("kind"):
    return node

  let kind = node["kind"].getStr()

  case kind
  of "xnkFile":
    result = convertFile(node)
  of "xnkFuncDecl":
    result = convertFuncDecl(node)
  of "xnkClassDecl":
    result = convertClassDecl(node)
  of "xnkStructDecl":
    result = convertStructDecl(node)
  of "xnkInterfaceDecl":
    result = convertInterfaceDecl(node)
  of "xnkEnumDecl":
    result = convertEnumDecl(node)
  of "xnkTemplateDecl":
    result = convertTemplateDecl(node)
  of "xnkMixinDecl":
    result = convertMixinDecl(node)
  of "xnkAliasDecl":
    result = convertAliasDecl(node)
  of "xnkVarDecl":
    result = convertVarDecl(node)
  of "xnkImport":
    result = convertImport(node)
  of "xnkStaticAssert":
    result = convertStaticAssert(node)
  of "xnkParameter":
    result = convertParameter(node)
  of "xnkTemplateParameter":
    result = convertTemplateParameter(node)
  of "xnkNamedType":
    result = convertNamedType(node)
  of "xnkBlockStmt":
    result = convertBlockStmt(node)
  of "xnkIfStmt":
    result = convertIfStmt(node)
  of "xnkWhileStmt":
    result = convertWhileStmt(node)
  of "xnkForStmt":
    result = convertForStmt(node)
  of "xnkForeachStmt":
    result = convertForeachStmt(node)
  of "xnkSwitchStmt":
    result = convertSwitchStmt(node)
  of "xnkReturnStmt":
    result = convertReturnStmt(node)
  of "xnkExpression":
    result = convertExpression(node)
  of "xnkInitializer":
    result = convertInitializer(node)
  of "xnkEmpty", "xnkUnknown":
    result = node
  else:
    # Unknown node kind - pass through
    result = node

proc convertDJsonToXLang*(input: string): string =
  ## Main entry point: converts D parser JSON to canonical XLang JSON
  let inputJson = parseJson(input)
  let outputJson = convertNode(inputJson)
  result = $outputJson

when isMainModule:
  import os

  if paramCount() < 1:
    echo "Usage: d_json_to_xlang <input.json>"
    quit(1)

  let inputFile = paramStr(1)
  let inputJson = readFile(inputFile)
  let outputJson = convertDJsonToXLang(inputJson)
  echo outputJson
