## C# Parser JSON to XLang JSON Converter
##
## Converts the JSON output from csharp_to_xlang.cs (C# native AST from ANTLR)
## to canonical XLang JSON format matching xlang_types.nim.
##
## C# AST uses kinds like: "CompilationUnit", "Class", "Method", "Namespace"
## XLang uses kinds like: "xnkFile", "xnkClassDecl", "xnkMethodDecl", "xnkNamespace"
##
## Usage: nim c -r csharp_json_to_xlang.nim input.json > output.xlang.json

import json, options, strutils, os

proc convertNode(node: JsonNode): JsonNode

proc convertCompilationUnit(node: JsonNode): JsonNode =
  ## Convert C# "CompilationUnit" to XLang "xnkFile"
  result = %* {
    "kind": "xnkFile",
    "fileName": "Program.cs",
    "moduleDecls": []
  }

  if node.hasKey("Data") and node["Data"].kind == JArray:
    for member in node["Data"]:
      let converted = convertNode(member)
      if not converted.isNil:
        result["moduleDecls"].add(converted)

proc convertNamespace(node: JsonNode): JsonNode =
  ## Convert C# "Namespace" to XLang "xnkNamespace"
  result = %* {
    "kind": "xnkNamespace",
    "namespaceName": "",
    "namespaceBody": []
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("Name"):
    result["namespaceName"] = data["Name"]

  if data.hasKey("Members"):
    let members = data["Members"]
    if members.kind == JArray:
      for member in members:
        result["namespaceBody"].add(convertNode(member))
    elif not members.isNil:
      result["namespaceBody"].add(convertNode(members))

proc convertClass(node: JsonNode): JsonNode =
  ## Convert C# "Class" to XLang "xnkClassDecl"
  result = %* {
    "kind": "xnkClassDecl",
    "typeNameDecl": "",
    "baseTypes": [],
    "members": []
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("Name"):
    result["typeNameDecl"] = data["Name"]

  if data.hasKey("BaseList") and not data["BaseList"].isNil:
    # Base list can be single item or array
    let baseList = data["BaseList"]
    if baseList.kind == JArray:
      for base in baseList:
        result["baseTypes"].add(convertNode(base))
    elif baseList.hasKey("kind"):
      result["baseTypes"].add(convertNode(baseList))

  if data.hasKey("Members") and data["Members"].kind == JArray:
    for member in data["Members"]:
      result["members"].add(convertNode(member))

proc convertStruct(node: JsonNode): JsonNode =
  ## Convert C# "Struct" to XLang "xnkStructDecl"
  result = %* {
    "kind": "xnkStructDecl",
    "typeNameDecl": "",
    "baseTypes": [],
    "members": []
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("Name"):
    result["typeNameDecl"] = data["Name"]

  if data.hasKey("BaseList") and not data["BaseList"].isNil:
    let baseList = data["BaseList"]
    if baseList.kind == JArray:
      for base in baseList:
        result["baseTypes"].add(convertNode(base))
    elif baseList.hasKey("kind"):
      result["baseTypes"].add(convertNode(baseList))

  if data.hasKey("Members") and data["Members"].kind == JArray:
    for member in data["Members"]:
      result["members"].add(convertNode(member))

proc convertInterface(node: JsonNode): JsonNode =
  ## Convert C# "Interface" to XLang "xnkInterfaceDecl"
  result = %* {
    "kind": "xnkInterfaceDecl",
    "typeNameDecl": "",
    "baseTypes": [],
    "members": []
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("Name"):
    result["typeNameDecl"] = data["Name"]

  if data.hasKey("BaseList") and not data["BaseList"].isNil:
    let baseList = data["BaseList"]
    if baseList.kind == JArray:
      for base in baseList:
        result["baseTypes"].add(convertNode(base))

  if data.hasKey("Members") and data["Members"].kind == JArray:
    for member in data["Members"]:
      result["members"].add(convertNode(member))

proc convertEnum(node: JsonNode): JsonNode =
  ## Convert C# "Enum" to XLang "xnkEnumDecl"
  result = %* {
    "kind": "xnkEnumDecl",
    "enumName": "",
    "enumMembers": []
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("Name"):
    result["enumName"] = data["Name"]

  if data.hasKey("Members") and data["Members"].kind == JArray:
    for member in data["Members"]:
      if member.hasKey("Name"):
        let enumMember = %* {
          "name": member["Name"],
          "value": nil
        }
        if member.hasKey("Value"):
          enumMember["value"] = convertNode(member["Value"])
        result["enumMembers"].add(enumMember)

proc convertMethod(node: JsonNode): JsonNode =
  ## Convert C# "Method" to XLang "xnkMethodDecl"
  result = %* {
    "kind": "xnkMethodDecl",
    "funcName": "",
    "params": [],
    "returnType": nil,
    "body": %* {"kind": "xnkBlockStmt", "blockBody": []},
    "isAsync": false
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("Name"):
    result["funcName"] = data["Name"]

  if data.hasKey("ReturnType"):
    result["returnType"] = %* {
      "kind": "xnkNamedType",
      "typeName": data["ReturnType"]
    }

  if data.hasKey("Parameters") and not data["Parameters"].isNil:
    let params = data["Parameters"]
    if params.kind == JArray:
      for param in params:
        result["params"].add(convertNode(param))
    elif params.hasKey("kind"):
      result["params"].add(convertNode(params))

  if data.hasKey("Body") and not data["Body"].isNil:
    result["body"] = convertNode(data["Body"])

  # Check for async keyword (would need to be in modifiers)
  if data.hasKey("Modifiers") and data["Modifiers"].kind == JArray:
    for modifier in data["Modifiers"]:
      if modifier.getStr == "async":
        result["isAsync"] = %true

proc convertProperty(node: JsonNode): JsonNode =
  ## Convert C# "Property" to XLang "xnkPropertyDecl"
  result = %* {
    "kind": "xnkPropertyDecl",
    "propName": "",
    "propType": %* {"kind": "xnkNamedType", "typeName": "object"},
    "getter": nil,
    "setter": nil
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("Name"):
    result["propName"] = data["Name"]

  if data.hasKey("Type"):
    result["propType"] = %* {
      "kind": "xnkNamedType",
      "typeName": data["Type"]
    }

  if data.hasKey("Getter") and not data["Getter"].isNil:
    result["getter"] = convertNode(data["Getter"])

  if data.hasKey("Setter") and not data["Setter"].isNil:
    result["setter"] = convertNode(data["Setter"])

proc convertField(node: JsonNode): JsonNode =
  ## Convert C# "Field" to XLang "xnkFieldDecl"
  result = %* {
    "kind": "xnkFieldDecl",
    "fieldName": "",
    "fieldType": %* {"kind": "xnkNamedType", "typeName": "object"},
    "fieldInitializer": nil
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("Name"):
    result["fieldName"] = data["Name"]

  if data.hasKey("Type"):
    result["fieldType"] = %* {
      "kind": "xnkNamedType",
      "typeName": data["Type"]
    }

  if data.hasKey("Initializer") and not data["Initializer"].isNil:
    result["fieldInitializer"] = convertNode(data["Initializer"])

proc convertParameter(node: JsonNode): JsonNode =
  ## Convert C# parameter to XLang "xnkParameter"
  result = %* {
    "kind": "xnkParameter",
    "paramName": "",
    "paramType": %* {"kind": "xnkNamedType", "typeName": "object"},
    "defaultValue": nil
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("Name"):
    result["paramName"] = data["Name"]

  if data.hasKey("Type"):
    result["paramType"] = %* {
      "kind": "xnkNamedType",
      "typeName": data["Type"]
    }

  if data.hasKey("DefaultValue") and not data["DefaultValue"].isNil:
    result["defaultValue"] = convertNode(data["DefaultValue"])

proc convertDelegate(node: JsonNode): JsonNode =
  ## Convert C# "Delegate" to XLang "xnkDelegateDecl"
  result = %* {
    "kind": "xnkDelegateDecl",
    "delegateName": "",
    "delegateParams": [],
    "delegateReturnType": nil
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("Name"):
    result["delegateName"] = data["Name"]

  if data.hasKey("ReturnType"):
    result["delegateReturnType"] = %* {
      "kind": "xnkNamedType",
      "typeName": data["ReturnType"]
    }

  if data.hasKey("Parameters") and not data["Parameters"].isNil:
    let params = data["Parameters"]
    if params.kind == JArray:
      for param in params:
        result["delegateParams"].add(convertNode(param))

proc convertBlock(node: JsonNode): JsonNode =
  ## Convert C# "Block" to XLang "xnkBlockStmt"
  result = %* {
    "kind": "xnkBlockStmt",
    "blockBody": []
  }

  if node.hasKey("Data") and node["Data"].kind == JArray:
    for stmt in node["Data"]:
      result["blockBody"].add(convertNode(stmt))

proc convertIdentifier(node: JsonNode): JsonNode =
  ## Convert C# identifier/name to XLang "xnkIdentifier"
  result = %* {
    "kind": "xnkIdentifier",
    "identName": ""
  }

  if node.hasKey("Data"):
    if node["Data"].kind == JString:
      result["identName"] = node["Data"]
    elif node["Data"].hasKey("Name"):
      result["identName"] = node["Data"]["Name"]

proc convertLiteral(node: JsonNode, xlangKind: string): JsonNode =
  ## Convert C# literal to XLang literal
  case xlangKind
  of "xnkIntLit", "xnkFloatLit", "xnkStringLit", "xnkCharLit":
    result = %* {
      "kind": xlangKind,
      "literalValue": ""
    }
    if node.hasKey("Data"):
      if node["Data"].kind == JString:
        result["literalValue"] = node["Data"]
      elif node["Data"].hasKey("Value"):
        result["literalValue"] = node["Data"]["Value"]
  of "xnkBoolLit":
    result = %* {
      "kind": "xnkBoolLit",
      "boolValue": false
    }
    if node.hasKey("Data"):
      if node["Data"].kind == JBool:
        result["boolValue"] = node["Data"]
      elif node["Data"].hasKey("Value"):
        result["boolValue"] = node["Data"]["Value"]
  of "xnkNoneLit":
    result = %* {"kind": "xnkNoneLit"}
  else:
    result = node

proc fixFieldNames(node: JsonNode): JsonNode =
  ## Recursively fix field names to match canonical XLang format
  if node.isNil:
    return newJNull()

  if node.kind == JArray:
    result = newJArray()
    for item in node:
      result.add(fixFieldNames(item))
    return result

  if node.kind != JObject:
    return node

  result = newJObject()

  for key, val in node.pairs:
    case key
    of "className": result["typeNameDecl"] = fixFieldNames(val)
    of "name":
      # Context-sensitive: could be funcName, declName, etc.
      if node.hasKey("kind"):
        let kind = node["kind"].getStr()
        case kind
        of "xnkFuncDecl", "xnkMethodDecl": result["funcName"] = fixFieldNames(val)
        of "xnkClassDecl", "xnkStructDecl", "xnkInterfaceDecl": result["typeNameDecl"] = fixFieldNames(val)
        of "xnkVarDecl", "xnkParameter": result["declName"] = fixFieldNames(val)
        of "xnkIdentifier": result["identName"] = fixFieldNames(val)
        of "xnkNamespace": result["namespaceName"] = fixFieldNames(val)
        else: result[key] = fixFieldNames(val)
      else:
        result[key] = fixFieldNames(val)
    of "parameters": result["params"] = fixFieldNames(val)
    of "declarations": result["moduleDecls"] = fixFieldNames(val)
    of "statements": result["blockBody"] = fixFieldNames(val)
    of "members": result["members"] = fixFieldNames(val)
    of "body": result["funcBody"] = fixFieldNames(val)
    of "expr": result["callExpr"] = fixFieldNames(val)
    of "args": result["callArgs"] = fixFieldNames(val)
    else:
      if val.kind == JObject or val.kind == JArray:
        result[key] = fixFieldNames(val)
      else:
        result[key] = val

  return result

proc convertNode(node: JsonNode): JsonNode =
  if node.isNil or node.kind == JNull:
    return newJNull()

  # Check for both "Kind" (ANTLR) and "kind" (Roslyn)
  let hasKind = node.hasKey("kind") or node.hasKey("Kind")
  if not hasKind:
    return node

  let kind = if node.hasKey("kind"): node["kind"].getStr() else: node["Kind"].getStr()

  # If already in xnk* format, just fix field names
  if kind.startsWith("xnk"):
    return fixFieldNames(node)

  # Otherwise convert from ANTLR format
  case kind
  of "CompilationUnit": result = convertCompilationUnit(node)
  of "Namespace": result = convertNamespace(node)
  of "Class": result = convertClass(node)
  of "Struct": result = convertStruct(node)
  of "Interface": result = convertInterface(node)
  of "Enum": result = convertEnum(node)
  of "Method": result = convertMethod(node)
  of "Property": result = convertProperty(node)
  of "Field": result = convertField(node)
  of "Parameter": result = convertParameter(node)
  of "Delegate": result = convertDelegate(node)
  of "Block": result = convertBlock(node)
  of "Identifier", "Name": result = convertIdentifier(node)
  of "IntLiteral": result = convertLiteral(node, "xnkIntLit")
  of "FloatLiteral": result = convertLiteral(node, "xnkFloatLit")
  of "StringLiteral": result = convertLiteral(node, "xnkStringLit")
  of "CharLiteral": result = convertLiteral(node, "xnkCharLit")
  of "BoolLiteral": result = convertLiteral(node, "xnkBoolLit")
  of "NullLiteral": result = convertLiteral(node, "xnkNoneLit")
  else:
    echo "Warning: Unknown C# AST node kind: ", kind
    result = node

when isMainModule:
  if paramCount() < 1:
    echo "Usage: csharp_json_to_xlang <input.json>"
    quit(1)

  let inputFile = paramStr(1)
  let jsonContent = readFile(inputFile)
  let inputJson = parseJson(jsonContent)

  let outputJson = convertNode(inputJson)

  echo pretty(outputJson, indent=2)
