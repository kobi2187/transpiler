## Haxe JSON to XLang Converter
## Converts Haxe parser's semi-XLang JSON output to canonical XLang format
##
## Field Mappings:
## - "className" -> "typeNameDecl"
## - "name" -> "funcName" (functions/methods)
## - "name" -> "declName" (variables)
## - "name" -> "identName" (identifiers)
## - "name" -> "enumName" (enums)
## - "fields" -> "members" (class fields)
## - "statements" -> "blockBody"
## - "condition" -> "ifCondition"/"whileCondition"
## - "thenBranch" -> "ifThen"
## - "elseBranch" -> "ifElse"
## - "body" -> "whileBody"/"funcBody"
## - "left"/"right" -> "binaryLeft"/"binaryRight"
## - "expr" -> "unaryOperand" (unary expressions)
## - "expr" -> "returnExpr" (return statements)
##
## Haxe-specific features:
## - Abstract types
## - Metadata/annotations (@:meta)
## - Enum constructors with parameters
## - Type parameters with constraints
## - Anonymous structures (structural types)
## - Dynamic types
## - Lazy types
## - Typedef aliases
## - Static extensions

import json, strutils, sequtils

proc convertNode(node: JsonNode): JsonNode

proc convertClassDecl(node: JsonNode): JsonNode =
  result = %* {
    "kind": node["kind"].getStr(),  # Keep xnkClassDecl or xnkInterfaceDecl
    "typeNameDecl": node{"className"}.getStr(""),
    "baseTypes": newJArray(),
    "members": newJArray(),
    "isAbstract": false,
    "isPrivate": node{"isPrivate"}.getBool(false),
    "isFinal": node{"isFinal"}.getBool(false)
  }

  # Convert superclass to baseTypes
  if node.hasKey("superClass") and node["superClass"].kind != JNull:
    result["baseTypes"].add(convertNode(node["superClass"]))

  # Convert interfaces to baseTypes
  if node.hasKey("interfaces"):
    for iface in node["interfaces"]:
      result["baseTypes"].add(convertNode(iface))

  # Convert fields to members
  if node.hasKey("fields"):
    for field in node["fields"]:
      result["members"].add(convertNode(field))

  # Convert statics to members
  if node.hasKey("statics"):
    for staticField in node["statics"]:
      var converted = convertNode(staticField)
      converted["isStatic"] = %true
      result["members"].add(converted)

  # Constructor
  if node.hasKey("constructor") and node["constructor"].kind != JNull:
    result["members"].add(convertNode(node["constructor"]))

  # Type parameters (generics)
  if node.hasKey("typeParameters"):
    result["typeParams"] = newJArray()
    for param in node["typeParameters"]:
      result["typeParams"].add(convertNode(param))

  # Metadata
  if node.hasKey("meta") and node["meta"].kind != JNull:
    result["metadata"] = convertNode(node["meta"])

proc convertFieldDecl(node: JsonNode): JsonNode =
  let isMethod = node["kind"].getStr() == "xnkMethodDecl"

  if isMethod:
    result = %* {
      "kind": "xnkFuncDecl",
      "funcName": node{"name"}.getStr(""),
      "params": newJArray(),
      "returnType": newJNull(),
      "funcBody": newJNull(),
      "isStatic": node{"isStatic"}.getBool(false),
      "isFinal": node{"isFinal"}.getBool(false),
      "isOverride": node{"isOverride"}.getBool(false),
      "isAsync": false,
      "isExtern": false,
      "isInline": false
    }

    # Convert type to function signature
    if node.hasKey("type") and node["type"].kind != JNull:
      let typeNode = convertNode(node["type"])
      if typeNode.hasKey("funcTypeReturn"):
        result["returnType"] = typeNode["funcTypeReturn"]
      if typeNode.hasKey("funcTypeParams"):
        result["params"] = typeNode["funcTypeParams"]

    # Convert body expression
    if node.hasKey("expr") and node["expr"].kind != JNull:
      result["funcBody"] = convertNode(node["expr"])
  else:
    # Field declaration
    result = %* {
      "kind": "xnkVarDecl",
      "declName": node{"name"}.getStr(""),
      "declType": newJNull(),
      "declInit": newJNull(),
      "isStatic": node{"isStatic"}.getBool(false),
      "isFinal": node{"isFinal"}.getBool(false),
      "isConst": false,
      "isMutable": true
    }

    if node.hasKey("type") and node["type"].kind != JNull:
      result["declType"] = convertNode(node["type"])

    if node.hasKey("expr") and node["expr"].kind != JNull:
      result["declInit"] = convertNode(node["expr"])

  # Metadata
  if node.hasKey("meta") and node["meta"].kind != JNull:
    result["metadata"] = convertNode(node["meta"])

proc convertEnumDecl(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkEnumDecl",
    "enumName": node{"name"}.getStr(""),
    "enumBaseType": newJNull(),
    "enumMembers": newJArray(),
    "isPrivate": node{"isPrivate"}.getBool(false)
  }

  # Haxe enums have constructors instead of simple members
  if node.hasKey("constructors"):
    for constructor in node["constructors"]:
      result["enumMembers"].add(convertNode(constructor))

  # Type parameters
  if node.hasKey("typeParameters"):
    result["typeParams"] = newJArray()
    for param in node["typeParameters"]:
      result["typeParams"].add(convertNode(param))

  # Metadata
  if node.hasKey("meta") and node["meta"].kind != JNull:
    result["metadata"] = convertNode(node["meta"])

proc convertEnumConstructor(node: JsonNode): JsonNode =
  ## Haxe enum constructors can have parameters
  result = %* {
    "kind": "xnkEnumMember",
    "enumMemberName": node{"name"}.getStr(""),
    "enumMemberValue": newJNull(),
    "enumMemberParams": newJArray()
  }

  # Constructor arguments
  if node.hasKey("args"):
    for arg in node["args"]:
      result["enumMemberParams"].add(%* {
        "paramName": arg{"name"}.getStr(""),
        "paramType": arg.hasKey("type") ? convertNode(arg["type"]) : newJNull()
      })

  # Metadata
  if node.hasKey("meta") and node["meta"].kind != JNull:
    result["metadata"] = convertNode(node["meta"])

proc convertTypeDecl(node: JsonNode): JsonNode =
  ## Haxe typedef
  result = %* {
    "kind": "xnkTypeAlias",
    "aliasName": node{"name"}.getStr(""),
    "aliasTarget": newJNull(),
    "isPrivate": node{"isPrivate"}.getBool(false)
  }

  if node.hasKey("type") and node["type"].kind != JNull:
    result["aliasTarget"] = convertNode(node["type"])

  # Type parameters
  if node.hasKey("typeParameters"):
    result["typeParams"] = newJArray()
    for param in node["typeParameters"]:
      result["typeParams"].add(convertNode(param))

  # Metadata
  if node.hasKey("meta") and node["meta"].kind != JNull:
    result["metadata"] = convertNode(node["meta"])

proc convertAbstractDecl(node: JsonNode): JsonNode =
  ## Haxe abstract types
  result = %* {
    "kind": "xnkAbstractDecl",
    "abstractName": node{"name"}.getStr(""),
    "abstractType": newJNull(),
    "isPrivate": node{"isPrivate"}.getBool(false),
    "fromTypes": newJArray(),
    "toTypes": newJArray()
  }

  if node.hasKey("type") and node["type"].kind != JNull:
    result["abstractType"] = convertNode(node["type"])

  # From conversions
  if node.hasKey("fromTypes"):
    for fromType in node["fromTypes"]:
      result["fromTypes"].add(convertNode(fromType))

  # To conversions
  if node.hasKey("toTypes"):
    for toType in node["toTypes"]:
      result["toTypes"].add(convertNode(toType))

  # Implementation (abstract can have methods)
  if node.hasKey("impl") and node["impl"].kind != JNull:
    result["abstractImpl"] = convertNode(node["impl"])

  # Type parameters
  if node.hasKey("typeParameters"):
    result["typeParams"] = newJArray()
    for param in node["typeParameters"]:
      result["typeParams"].add(convertNode(param))

  # Metadata
  if node.hasKey("meta") and node["meta"].kind != JNull:
    result["metadata"] = convertNode(node["meta"])

proc convertIdentifier(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkIdentifier",
    "identName": node{"name"}.getStr("")
  }

proc convertIndexExpr(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkIndexExpr",
    "indexTarget": newJNull(),
    "indexValue": newJNull()
  }

  if node.hasKey("expr") and node["expr"].kind != JNull:
    result["indexTarget"] = convertNode(node["expr"])

  if node.hasKey("index") and node["index"].kind != JNull:
    result["indexValue"] = convertNode(node["index"])

proc convertBinaryExpr(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkBinaryExpr",
    "binaryOp": node{"op"}.getStr(""),
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
    "unaryOp": node{"op"}.getStr(""),
    "unaryOperand": newJNull(),
    "isPostfix": node{"postFix"}.getBool(false)
  }

  if node.hasKey("expr") and node["expr"].kind != JNull:
    result["unaryOperand"] = convertNode(node["expr"])

proc convertMemberAccessExpr(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkMemberAccessExpr",
    "memberObject": newJNull(),
    "memberName": ""
  }

  if node.hasKey("expr") and node["expr"].kind != JNull:
    result["memberObject"] = convertNode(node["expr"])

  if node.hasKey("field") and node["field"].kind != JNull:
    let field = convertNode(node["field"])
    if field.hasKey("identName"):
      result["memberName"] = field["identName"]

proc convertCallExpr(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkCallExpr",
    "callExpr": newJNull(),
    "callArgs": newJArray()
  }

  if node.hasKey("expr") and node["expr"].kind != JNull:
    result["callExpr"] = convertNode(node["expr"])

  if node.hasKey("args"):
    for arg in node["args"]:
      result["callArgs"].add(convertNode(arg))

proc convertLambdaExpr(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkLambdaExpr",
    "lambdaParams": newJArray(),
    "lambdaBody": newJNull(),
    "lambdaReturnType": newJNull()
  }

  if node.hasKey("args"):
    for arg in node["args"]:
      result["lambdaParams"].add(convertNode(arg))

  if node.hasKey("expr") and node["expr"].kind != JNull:
    result["lambdaBody"] = convertNode(node["expr"])

  if node.hasKey("ret") and node["ret"].kind != JNull:
    result["lambdaReturnType"] = convertNode(node["ret"])

proc convertVarDecl(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkVarDecl",
    "declName": node{"name"}.getStr(""),
    "declType": newJNull(),
    "declInit": newJNull(),
    "isConst": false,
    "isMutable": true
  }

  if node.hasKey("type") and node["type"].kind != JNull:
    result["declType"] = convertNode(node["type"])

  if node.hasKey("expr") and node["expr"].kind != JNull:
    result["declInit"] = convertNode(node["expr"])

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

proc convertDoWhileStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkDoWhileStmt",
    "doWhileCondition": newJNull(),
    "doWhileBody": newJNull()
  }

  if node.hasKey("condition") and node["condition"].kind != JNull:
    result["doWhileCondition"] = convertNode(node["condition"])

  if node.hasKey("body") and node["body"].kind != JNull:
    result["doWhileBody"] = convertNode(node["body"])

proc convertForStmt(node: JsonNode): JsonNode =
  ## Haxe for loops are iterator-based
  result = %* {
    "kind": "xnkForStmt",
    "forIterator": newJNull(),
    "forBody": newJNull(),
    "forIsForeach": true
  }

  if node.hasKey("variable") and node["variable"].kind != JNull:
    result["forVariable"] = convertNode(node["variable"])

  if node.hasKey("expr") and node["expr"].kind != JNull:
    result["forIterator"] = convertNode(node["expr"])

  if node.hasKey("body") and node["body"].kind != JNull:
    result["forBody"] = convertNode(node["body"])

proc convertSwitchStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkSwitchStmt",
    "switchExpr": newJNull(),
    "switchCases": newJArray(),
    "switchDefault": newJNull()
  }

  if node.hasKey("expr") and node["expr"].kind != JNull:
    result["switchExpr"] = convertNode(node["expr"])

  if node.hasKey("cases"):
    for caseNode in node["cases"]:
      var switchCase = %* {
        "kind": "xnkSwitchCase",
        "caseConditions": newJArray(),
        "caseBody": newJNull()
      }

      if caseNode.hasKey("patterns"):
        for pattern in caseNode["patterns"]:
          switchCase["caseConditions"].add(convertNode(pattern))

      if caseNode.hasKey("body") and caseNode["body"].kind != JNull:
        switchCase["caseBody"] = convertNode(caseNode["body"])

      result["switchCases"].add(switchCase)

  if node.hasKey("defaultBody") and node["defaultBody"].kind != JNull:
    result["switchDefault"] = convertNode(node["defaultBody"])

proc convertTryStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkTryStmt",
    "tryBody": newJNull(),
    "tryCatches": newJArray(),
    "tryFinally": newJNull()
  }

  if node.hasKey("body") and node["body"].kind != JNull:
    result["tryBody"] = convertNode(node["body"])

  if node.hasKey("catches"):
    for catchNode in node["catches"]:
      result["tryCatches"].add(convertNode(catchNode))

proc convertCatchStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkCatchStmt",
    "catchType": newJNull(),
    "catchName": node{"name"}.getStr(""),
    "catchBody": newJNull()
  }

  if node.hasKey("type") and node["type"].kind != JNull:
    result["catchType"] = convertNode(node["type"])

  if node.hasKey("body") and node["body"].kind != JNull:
    result["catchBody"] = convertNode(node["body"])

proc convertReturnStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkReturnStmt",
    "returnExpr": newJNull()
  }

  if node.hasKey("expr") and node["expr"].kind != JNull:
    result["returnExpr"] = convertNode(node["expr"])

proc convertThrowStmt(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkThrowStmt",
    "throwExpr": newJNull()
  }

  if node.hasKey("expr") and node["expr"].kind != JNull:
    result["throwExpr"] = convertNode(node["expr"])

proc convertTypeCheck(node: JsonNode): JsonNode =
  ## Haxe type casts
  result = %* {
    "kind": "xnkCastExpr",
    "castExpr": newJNull(),
    "castType": newJNull()
  }

  if node.hasKey("expr") and node["expr"].kind != JNull:
    result["castExpr"] = convertNode(node["expr"])

  if node.hasKey("type") and node["type"].kind != JNull:
    result["castType"] = convertNode(node["type"])

proc convertMetadata(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkMetadata",
    "metadataEntries": newJArray()
  }

  if node.hasKey("entries"):
    for entry in node["entries"]:
      var metaEntry = %* {
        "name": entry{"name"}.getStr(""),
        "args": newJArray()
      }

      if entry.hasKey("args"):
        for arg in entry["args"]:
          metaEntry["args"].add(convertNode(arg))

      result["metadataEntries"].add(metaEntry)

  # Handle single metadata entry
  if node.hasKey("name"):
    result = %* {
      "kind": "xnkMetadata",
      "metadataName": node{"name"}.getStr(""),
      "metadataArgs": newJArray(),
      "metadataExpr": newJNull()
    }

    if node.hasKey("args"):
      for arg in node["args"]:
        result["metadataArgs"].add(convertNode(arg))

    if node.hasKey("expr") and node["expr"].kind != JNull:
      result["metadataExpr"] = convertNode(node["expr"])

proc convertGenericType(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkGenericType",
    "genericBase": %* {
      "kind": "xnkNamedType",
      "typeName": node{"name"}.getStr("")
    },
    "genericArgs": newJArray()
  }

  if node.hasKey("typeArgs"):
    for arg in node["typeArgs"]:
      result["genericArgs"].add(convertNode(arg))

proc convertFuncType(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkFunctionType",
    "funcTypeParams": newJArray(),
    "funcTypeReturn": newJNull()
  }

  if node.hasKey("args"):
    for arg in node["args"]:
      var param = %* {
        "kind": "xnkParameter",
        "paramName": arg{"name"}.getStr(""),
        "paramType": newJNull(),
        "paramDefault": newJNull()
      }

      if arg.hasKey("type") and arg["type"].kind != JNull:
        param["paramType"] = convertNode(arg["type"])

      result["funcTypeParams"].add(param)

  if node.hasKey("returnType") and node["returnType"].kind != JNull:
    result["funcTypeReturn"] = convertNode(node["returnType"])

proc convertStructDecl(node: JsonNode): JsonNode =
  ## Anonymous structures
  result = %* {
    "kind": "xnkStructDecl",
    "typeNameDecl": "",
    "members": newJArray(),
    "isAnonymous": true
  }

  if node.hasKey("fields"):
    for field in node["fields"]:
      result["members"].add(convertNode(field))

proc convertDynamicType(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkDynamicType",
    "dynamicConstraint": newJNull()
  }

  if node.hasKey("type") and node["type"].kind != JNull:
    result["dynamicConstraint"] = convertNode(node["type"])

proc convertAbstractType(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkAbstractType",
    "abstractName": node{"name"}.getStr(""),
    "abstractTypeArgs": newJArray()
  }

  if node.hasKey("typeArgs"):
    for arg in node["typeArgs"]:
      result["abstractTypeArgs"].add(convertNode(arg))

proc convertGenericParameter(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkGenericParameter",
    "genericParamName": node{"name"}.getStr(""),
    "genericParamConstraints": newJArray()
  }

  if node.hasKey("constraints"):
    for constraint in node["constraints"]:
      result["genericParamConstraints"].add(convertNode(constraint))

proc convertNamedType(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkNamedType",
    "typeName": node{"name"}.getStr("")
  }

proc convertIntLit(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkIntLit",
    "intValue": node{"value"}.getInt()
  }

proc convertFloatLit(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkFloatLit",
    "floatValue": node{"value"}.getFloat()
  }

proc convertStringLit(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkStringLit",
    "stringValue": node{"value"}.getStr("")
  }

proc convertBoolLit(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkBoolLit",
    "boolValue": node{"value"}.getBool()
  }

proc convertListExpr(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkArrayLit",
    "arrayElements": newJArray()
  }

  if node.hasKey("elements"):
    for elem in node["elements"]:
      result["arrayElements"].add(convertNode(elem))

proc convertDictExpr(node: JsonNode): JsonNode =
  result = %* {
    "kind": "xnkDictLit",
    "dictEntries": newJArray()
  }

  if node.hasKey("entries"):
    for entry in node["entries"]:
      let convertedEntry = %* {
        "key": entry.hasKey("key") ? convertNode(entry["key"]) : newJNull(),
        "value": entry.hasKey("value") ? convertNode(entry["value"]) : newJNull()
      }
      result["dictEntries"].add(convertedEntry)

proc convertNode(node: JsonNode): JsonNode =
  if node.kind != JObject:
    return node

  if not node.hasKey("kind"):
    return node

  let kind = node["kind"].getStr()

  case kind
  of "xnkClassDecl", "xnkInterfaceDecl":
    result = convertClassDecl(node)
  of "xnkMethodDecl", "xnkFieldDecl":
    result = convertFieldDecl(node)
  of "xnkEnumDecl":
    result = convertEnumDecl(node)
  of "xnkEnumConstructor":
    result = convertEnumConstructor(node)
  of "xnkTypeDecl":
    result = convertTypeDecl(node)
  of "xnkAbstractDecl":
    result = convertAbstractDecl(node)
  of "xnkIdentifier":
    result = convertIdentifier(node)
  of "xnkIndexExpr":
    result = convertIndexExpr(node)
  of "xnkBinaryExpr":
    result = convertBinaryExpr(node)
  of "xnkUnaryExpr":
    result = convertUnaryExpr(node)
  of "xnkMemberAccessExpr":
    result = convertMemberAccessExpr(node)
  of "xnkCallExpr":
    result = convertCallExpr(node)
  of "xnkLambdaExpr":
    result = convertLambdaExpr(node)
  of "xnkVarDecl":
    result = convertVarDecl(node)
  of "xnkBlockStmt":
    result = convertBlockStmt(node)
  of "xnkIfStmt":
    result = convertIfStmt(node)
  of "xnkWhileStmt":
    result = convertWhileStmt(node)
  of "xnkDoWhileStmt":
    result = convertDoWhileStmt(node)
  of "xnkForStmt":
    result = convertForStmt(node)
  of "xnkSwitchStmt":
    result = convertSwitchStmt(node)
  of "xnkTryStmt":
    result = convertTryStmt(node)
  of "xnkCatchStmt":
    result = convertCatchStmt(node)
  of "xnkReturnStmt":
    result = convertReturnStmt(node)
  of "xnkBreakStmt", "xnkContinueStmt":
    result = node
  of "xnkThrowStmt":
    result = convertThrowStmt(node)
  of "xnkTypeCheck":
    result = convertTypeCheck(node)
  of "xnkMetadata":
    result = convertMetadata(node)
  of "xnkGenericType":
    result = convertGenericType(node)
  of "xnkFuncType":
    result = convertFuncType(node)
  of "xnkStructDecl":
    result = convertStructDecl(node)
  of "xnkDynamicType":
    result = convertDynamicType(node)
  of "xnkAbstractType":
    result = convertAbstractType(node)
  of "xnkGenericParameter":
    result = convertGenericParameter(node)
  of "xnkNamedType":
    result = convertNamedType(node)
  of "xnkIntLit":
    result = convertIntLit(node)
  of "xnkFloatLit":
    result = convertFloatLit(node)
  of "xnkStringLit":
    result = convertStringLit(node)
  of "xnkBoolLit":
    result = convertBoolLit(node)
  of "xnkNoneLit", "xnkThisExpr", "xnkSuperExpr":
    result = node
  of "xnkListExpr":
    result = convertListExpr(node)
  of "xnkDictExpr":
    result = convertDictExpr(node)
  of "xnkEnumParameterExpr", "xnkEnumIndexExpr":
    result = node
  else:
    # Unknown node kind - pass through
    result = node

proc convertHaxeJsonToXLang*(input: string): string =
  ## Main entry point: converts Haxe parser JSON to canonical XLang JSON
  let inputJson = parseJson(input)
  let outputJson = convertNode(inputJson)
  result = $outputJson

when isMainModule:
  import os

  if paramCount() < 1:
    echo "Usage: haxe_json_to_xlang <input.json>"
    quit(1)

  let inputFile = paramStr(1)
  let inputJson = readFile(inputFile)
  let outputJson = convertHaxeJsonToXLang(inputJson)
  echo outputJson
