## Go Parser JSON to XLang JSON Converter
##
## Converts the JSON output from go_to_xlang.go (Go native AST) to canonical
## XLang JSON format that matches the xlang_types.nim specification.
##
## Go AST uses kinds like: "File", "FuncDecl", "StructType", "InterfaceType"
## XLang uses kinds like: "xnkFile", "xnkFuncDecl", "xnkStructDecl", "xnkInterfaceDecl"
##
## Usage: nim c -r go_json_to_xlang.nim input.json > output.xlang.json

import json, options, strutils, os, tables

proc convertNode(node: JsonNode): JsonNode

proc convertFile(node: JsonNode): JsonNode =
  ## Convert Go "File" node to XLang "xnkFile"
  result = %* {
    "kind": "xnkFile",
    "fileName": "",
    "moduleDecls": []
  }

  if node.hasKey("Data"):
    let data = node["Data"]
    if data.hasKey("Name"):
      result["fileName"] = %* (data["Name"].getStr & ".go")

    # Convert imports
    if data.hasKey("Imports") and data["Imports"].kind == JArray:
      for imp in data["Imports"]:
        result["moduleDecls"].add(convertNode(imp))

    # Convert declarations
    if data.hasKey("Decls") and data["Decls"].kind == JArray:
      for decl in data["Decls"]:
        let converted = convertNode(decl)
        if not converted.isNil:
          result["moduleDecls"].add(converted)

proc convertImport(node: JsonNode): JsonNode =
  ## Convert Go "Import" to XLang "xnkImport"
  result = %* {
    "kind": "xnkImport",
    "importPath": "",
    "importAlias": nil
  }

  if node.hasKey("Data"):
    let data = node["Data"]
    if data.hasKey("Path"):
      # Remove quotes from path
      var path = data["Path"].getStr
      path = path.strip(chars = {'"'})
      result["importPath"] = %path

    if data.hasKey("Name") and data["Name"].getStr != "":
      result["importAlias"] = data["Name"]

proc convertFuncDecl(node: JsonNode): JsonNode =
  ## Convert Go "FuncDecl" to XLang "xnkFuncDecl" or "xnkMethodDecl"
  if not node.hasKey("Data"):
    return newJNull()

  let data = node["Data"]
  let isMethod = data.hasKey("Receiver") and not data["Receiver"].isNil

  result = %* {
    "kind": if isMethod: "xnkMethodDecl" else: "xnkFuncDecl",
    "funcName": "",
    "params": [],
    "returnType": nil,
    "body": %* {"kind": "xnkBlockStmt", "blockBody": []},
    "isAsync": false  # Go doesn't have async/await, uses goroutines
  }

  if data.hasKey("Name"):
    result["funcName"] = data["Name"]

  # Convert parameters from FuncType
  if data.hasKey("Type"):
    let funcType = convertNode(data["Type"])
    if not funcType.isNil and funcType.hasKey("params"):
      result["params"] = funcType["params"]
    if not funcType.isNil and funcType.hasKey("returnType"):
      result["returnType"] = funcType["returnType"]

  # Convert body
  if data.hasKey("Body"):
    result["body"] = convertNode(data["Body"])

proc convertFuncType(node: JsonNode): JsonNode =
  ## Convert Go "FuncType" - helper for function signatures
  result = %* {
    "params": [],
    "returnType": nil
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  # Convert parameters
  if data.hasKey("Params"):
    let params = convertNode(data["Params"])
    if params.hasKey("fields"):
      result["params"] = params["fields"]

  # Convert results (return types)
  if data.hasKey("Results") and not data["Results"].isNil:
    let results = convertNode(data["Results"])
    if results.hasKey("fields") and results["fields"].len > 0:
      # If single unnamed return, use it directly
      if results["fields"].len == 1:
        result["returnType"] = results["fields"][0]
      else:
        # Multiple returns -> tuple type
        result["returnType"] = %* {
          "kind": "xnkTupleExpr",
          "elements": results["fields"]
        }

proc convertTypeDecl(node: JsonNode): JsonNode =
  ## Convert Go "TypeDecl" to XLang type declarations
  ## Can be struct, interface, or type alias
  if not node.hasKey("Data") or node["Data"].kind != JArray:
    return newJNull()

  # Process first type spec (Go allows multiple in one declaration)
  let specs = node["Data"]
  if specs.len == 0:
    return newJNull()

  return convertNode(specs[0])

proc convertTypeSpec(node: JsonNode): JsonNode =
  ## Convert Go "TypeSpec" to appropriate XLang type declaration
  if not node.hasKey("Data"):
    return newJNull()

  let data = node["Data"]
  let typeName = if data.hasKey("Name"): data["Name"].getStr else: ""

  if not data.hasKey("Type"):
    return newJNull()

  let typeNode = data["Type"]
  let typeKind = if typeNode.hasKey("Kind"): typeNode["Kind"].getStr else: ""

  case typeKind
  of "StructType":
    result = %* {
      "kind": "xnkStructDecl",
      "typeNameDecl": typeName,
      "baseTypes": [],
      "members": []
    }
    if typeNode.hasKey("Data") and typeNode["Data"].hasKey("Fields"):
      let fields = convertNode(typeNode["Data"]["Fields"])
      if fields.hasKey("fields"):
        result["members"] = fields["fields"]

  of "InterfaceType":
    result = %* {
      "kind": "xnkInterfaceDecl",
      "typeNameDecl": typeName,
      "baseTypes": [],
      "members": []
    }
    if typeNode.hasKey("Data") and typeNode["Data"].hasKey("Methods"):
      let methods = convertNode(typeNode["Data"]["Methods"])
      if methods.hasKey("fields"):
        result["members"] = methods["fields"]

  else:
    # Type alias
    result = %* {
      "kind": "xnkTypeDecl",
      "typeDefName": typeName,
      "typeDefBody": convertNode(typeNode)
    }

proc convertFieldList(node: JsonNode): JsonNode =
  ## Convert Go "FieldList" to array of field declarations
  result = %* {
    "fields": []
  }

  if not node.hasKey("Data") or node["Data"].kind != JArray:
    return result

  for field in node["Data"]:
    if field.hasKey("Kind") and field["Kind"].getStr == "Field":
      let converted = convertField(field)
      if not converted.isNil:
        if converted.kind == JArray:
          for item in converted:
            result["fields"].add(item)
        else:
          result["fields"].add(converted)

proc convertField(node: JsonNode): JsonNode =
  ## Convert Go "Field" to XLang "xnkFieldDecl" or "xnkParameter"
  if not node.hasKey("Data"):
    return newJNull()

  let data = node["Data"]
  var names: seq[string] = @[]

  if data.hasKey("Names") and data["Names"].kind == JArray:
    for name in data["Names"]:
      names.add(name.getStr)

  let fieldType = if data.hasKey("Type"): convertNode(data["Type"]) else: newJNull()

  # If no names, create single unnamed field/param
  if names.len == 0:
    return %* {
      "kind": "xnkFieldDecl",
      "fieldName": "",
      "fieldType": fieldType,
      "fieldInitializer": nil
    }

  # Create field/param for each name
  result = newJArray()
  for name in names:
    result.add(%* {
      "kind": "xnkParameter",  # Context-dependent, could be field
      "paramName": name,
      "paramType": fieldType,
      "defaultValue": nil
    })

proc convertVarDecl(node: JsonNode): JsonNode =
  ## Convert Go "VarDecl" to XLang "xnkVarDecl"
  if not node.hasKey("Data") or node["Data"].kind != JArray:
    return newJNull()

  # Process first value spec
  let specs = node["Data"]
  if specs.len == 0:
    return newJNull()

  return convertValueSpec(specs[0], "xnkVarDecl")

proc convertConstDecl(node: JsonNode): JsonNode =
  ## Convert Go "ConstDecl" to XLang "xnkConstDecl"
  if not node.hasKey("Data") or node["Data"].kind != JArray:
    return newJNull()

  let specs = node["Data"]
  if specs.len == 0:
    return newJNull()

  return convertValueSpec(specs[0], "xnkConstDecl")

proc convertValueSpec(node: JsonNode, kind: string): JsonNode =
  ## Convert Go "ValueSpec" to var/const declaration
  result = %* {
    "kind": kind,
    "declName": "",
    "declType": nil,
    "initializer": nil
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  # Get first name
  if data.hasKey("Names") and data["Names"].kind == JArray and data["Names"].len > 0:
    result["declName"] = data["Names"][0]

  # Get type
  if data.hasKey("Type") and not data["Type"].isNil:
    result["declType"] = convertNode(data["Type"])

  # Get value
  if data.hasKey("Values") and data["Values"].kind == JArray and data["Values"].len > 0:
    result["initializer"] = convertNode(data["Values"][0])

proc convertBlockStmt(node: JsonNode): JsonNode =
  ## Convert Go "BlockStmt" to XLang "xnkBlockStmt"
  result = %* {
    "kind": "xnkBlockStmt",
    "blockBody": []
  }

  if node.hasKey("Data") and node["Data"].kind == JArray:
    for stmt in node["Data"]:
      let converted = convertNode(stmt)
      if not converted.isNil:
        result["blockBody"].add(converted)

proc convertIfStmt(node: JsonNode): JsonNode =
  ## Convert Go "IfStmt" to XLang "xnkIfStmt"
  result = %* {
    "kind": "xnkIfStmt",
    "ifCondition": %* {"kind": "xnkBoolLit", "boolValue": true},
    "ifBody": %* {"kind": "xnkBlockStmt", "blockBody": []},
    "elseBody": nil
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("Cond"):
    result["ifCondition"] = convertNode(data["Cond"])

  if data.hasKey("Body"):
    result["ifBody"] = convertNode(data["Body"])

  if data.hasKey("Else") and not data["Else"].isNil:
    result["elseBody"] = convertNode(data["Else"])

proc convertForStmt(node: JsonNode): JsonNode =
  ## Convert Go "ForStmt" to XLang "xnkForStmt" or "xnkWhileStmt"
  if not node.hasKey("Data"):
    return newJNull()

  let data = node["Data"]

  # Check if it's a C-style for loop
  if data.hasKey("Init") or data.hasKey("Post"):
    result = %* {
      "kind": "xnkForStmt",
      "forInit": nil,
      "forCond": nil,
      "forIncrement": nil,
      "forBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
    }

    if data.hasKey("Init") and not data["Init"].isNil:
      result["forInit"] = convertNode(data["Init"])

    if data.hasKey("Cond") and not data["Cond"].isNil:
      result["forCond"] = convertNode(data["Cond"])

    if data.hasKey("Post") and not data["Post"].isNil:
      result["forIncrement"] = convertNode(data["Post"])

    if data.hasKey("Body"):
      result["forBody"] = convertNode(data["Body"])
  else:
    # Simple while-style loop
    result = %* {
      "kind": "xnkWhileStmt",
      "whileCondition": %* {"kind": "xnkBoolLit", "boolValue": true},
      "whileBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
    }

    if data.hasKey("Cond") and not data["Cond"].isNil:
      result["whileCondition"] = convertNode(data["Cond"])

    if data.hasKey("Body"):
      result["whileBody"] = convertNode(data["Body"])

proc convertRangeStmt(node: JsonNode): JsonNode =
  ## Convert Go "RangeStmt" to XLang "xnkForeachStmt"
  result = %* {
    "kind": "xnkForeachStmt",
    "foreachVar": %* {"kind": "xnkIdentifier", "identName": "_"},
    "foreachIter": %* {"kind": "xnkIdentifier", "identName": ""},
    "foreachBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("Key"):
    result["foreachVar"] = convertNode(data["Key"])

  if data.hasKey("X"):
    result["foreachIter"] = convertNode(data["X"])

  if data.hasKey("Body"):
    result["foreachBody"] = convertNode(data["Body"])

proc convertReturnStmt(node: JsonNode): JsonNode =
  ## Convert Go "ReturnStmt" to XLang "xnkReturnStmt"
  result = %* {
    "kind": "xnkReturnStmt",
    "returnExpr": nil
  }

  if node.hasKey("Data") and node["Data"].kind == JArray and node["Data"].len > 0:
    result["returnExpr"] = convertNode(node["Data"][0])

proc convertAssignStmt(node: JsonNode): JsonNode =
  ## Convert Go "AssignStmt" to XLang "xnkVarDecl" or binary expression
  if not node.hasKey("Data"):
    return newJNull()

  let data = node["Data"]
  let tok = if data.hasKey("Tok"): data["Tok"].getStr else: ""

  if tok == "DEFINE" or tok == ":=":
    # Short variable declaration
    result = %* {
      "kind": "xnkVarDecl",
      "declName": "",
      "declType": nil,
      "initializer": nil
    }

    if data.hasKey("Lhs") and data["Lhs"].kind == JArray and data["Lhs"].len > 0:
      let lhs = convertNode(data["Lhs"][0])
      if lhs.hasKey("identName"):
        result["declName"] = lhs["identName"]

    if data.hasKey("Rhs") and data["Rhs"].kind == JArray and data["Rhs"].len > 0:
      result["initializer"] = convertNode(data["Rhs"][0])
  else:
    # Regular assignment - convert to binary expression
    result = %* {
      "kind": "xnkBinaryExpr",
      "binaryLeft": %* {"kind": "xnkIdentifier", "identName": ""},
      "binaryOp": "=",
      "binaryRight": %* {"kind": "xnkNoneLit"}
    }

    if data.hasKey("Lhs") and data["Lhs"].kind == JArray and data["Lhs"].len > 0:
      result["binaryLeft"] = convertNode(data["Lhs"][0])

    if data.hasKey("Rhs") and data["Rhs"].kind == JArray and data["Rhs"].len > 0:
      result["binaryRight"] = convertNode(data["Rhs"][0])

proc convertBinaryExpr(node: JsonNode): JsonNode =
  ## Convert Go "BinaryExpr" to XLang "xnkBinaryExpr"
  result = %* {
    "kind": "xnkBinaryExpr",
    "binaryLeft": %* {"kind": "xnkNoneLit"},
    "binaryOp": "",
    "binaryRight": %* {"kind": "xnkNoneLit"}
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("X"):
    result["binaryLeft"] = convertNode(data["X"])

  if data.hasKey("Op"):
    result["binaryOp"] = data["Op"]

  if data.hasKey("Y"):
    result["binaryRight"] = convertNode(data["Y"])

proc convertUnaryExpr(node: JsonNode): JsonNode =
  ## Convert Go "UnaryExpr" to XLang "xnkUnaryExpr"
  result = %* {
    "kind": "xnkUnaryExpr",
    "unaryOp": "",
    "unaryOperand": %* {"kind": "xnkNoneLit"}
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("Op"):
    result["unaryOp"] = data["Op"]

  if data.hasKey("X"):
    result["unaryOperand"] = convertNode(data["X"])

proc convertCallExpr(node: JsonNode): JsonNode =
  ## Convert Go "CallExpr" to XLang "xnkCallExpr"
  result = %* {
    "kind": "xnkCallExpr",
    "callee": %* {"kind": "xnkIdentifier", "identName": ""},
    "args": []
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("Fun"):
    result["callee"] = convertNode(data["Fun"])

  if data.hasKey("Args") and data["Args"].kind == JArray:
    for arg in data["Args"]:
      result["args"].add(convertNode(arg))

proc convertIdent(node: JsonNode): JsonNode =
  ## Convert Go "Ident" to XLang "xnkIdentifier"
  result = %* {
    "kind": "xnkIdentifier",
    "identName": ""
  }

  if node.hasKey("Data") and node["Data"].hasKey("Name"):
    result["identName"] = node["Data"]["Name"]

proc convertBasicLit(node: JsonNode): JsonNode =
  ## Convert Go "BasicLit" to appropriate XLang literal
  if not node.hasKey("Data"):
    return %* {"kind": "xnkNoneLit"}

  let data = node["Data"]
  let kind = if data.hasKey("Kind"): data["Kind"].getStr else: ""
  let value = if data.hasKey("Value"): data["Value"].getStr else: ""

  case kind
  of "INT":
    result = %* {
      "kind": "xnkIntLit",
      "literalValue": value
    }
  of "FLOAT":
    result = %* {
      "kind": "xnkFloatLit",
      "literalValue": value
    }
  of "STRING":
    result = %* {
      "kind": "xnkStringLit",
      "literalValue": value.strip(chars = {'"'})
    }
  of "CHAR":
    result = %* {
      "kind": "xnkCharLit",
      "literalValue": value.strip(chars = {'\''})
    }
  else:
    result = %* {
      "kind": "xnkStringLit",
      "literalValue": value
    }

proc convertSelectorExpr(node: JsonNode): JsonNode =
  ## Convert Go "SelectorExpr" to XLang "xnkMemberAccessExpr"
  result = %* {
    "kind": "xnkMemberAccessExpr",
    "memberExpr": %* {"kind": "xnkIdentifier", "identName": ""},
    "memberName": ""
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("X"):
    result["memberExpr"] = convertNode(data["X"])

  if data.hasKey("Sel"):
    let sel = convertNode(data["Sel"])
    if sel.hasKey("identName"):
      result["memberName"] = sel["identName"]

proc convertIndexExpr(node: JsonNode): JsonNode =
  ## Convert Go "IndexExpr" to XLang "xnkIndexExpr"
  result = %* {
    "kind": "xnkIndexExpr",
    "indexExpr": %* {"kind": "xnkIdentifier", "identName": ""},
    "indexArgs": []
  }

  if not node.hasKey("Data"):
    return result

  let data = node["Data"]

  if data.hasKey("X"):
    result["indexExpr"] = convertNode(data["X"])

  if data.hasKey("Index"):
    result["indexArgs"].add(convertNode(data["Index"]))

proc convertNode(node: JsonNode): JsonNode =
  if node.isNil or node.kind == JNull:
    return newJNull()

  if not node.hasKey("Kind"):
    return node

  let kind = node["Kind"].getStr

  case kind
  of "File": result = convertFile(node)
  of "Import": result = convertImport(node)
  of "FuncDecl": result = convertFuncDecl(node)
  of "FuncType": result = convertFuncType(node)
  of "TypeDecl": result = convertTypeDecl(node)
  of "TypeSpec": result = convertTypeSpec(node)
  of "FieldList": result = convertFieldList(node)
  of "Field": result = convertField(node)
  of "VarDecl": result = convertVarDecl(node)
  of "ConstDecl": result = convertConstDecl(node)
  of "ValueSpec": result = convertValueSpec(node, "xnkVarDecl")
  of "BlockStmt": result = convertBlockStmt(node)
  of "IfStmt": result = convertIfStmt(node)
  of "ForStmt": result = convertForStmt(node)
  of "RangeStmt": result = convertRangeStmt(node)
  of "ReturnStmt": result = convertReturnStmt(node)
  of "AssignStmt": result = convertAssignStmt(node)
  of "BinaryExpr": result = convertBinaryExpr(node)
  of "UnaryExpr": result = convertUnaryExpr(node)
  of "CallExpr": result = convertCallExpr(node)
  of "Ident": result = convertIdent(node)
  of "BasicLit": result = convertBasicLit(node)
  of "SelectorExpr": result = convertSelectorExpr(node)
  of "IndexExpr": result = convertIndexExpr(node)
  else:
    # Pass through unknown nodes
    echo "Warning: Unknown Go AST node kind: ", kind
    result = node

when isMainModule:
  if paramCount() < 1:
    echo "Usage: go_json_to_xlang <input.json>"
    quit(1)

  let inputFile = paramStr(1)
  let jsonContent = readFile(inputFile)
  let inputJson = parseJson(jsonContent)

  let outputJson = convertNode(inputJson)

  echo pretty(outputJson, indent=2)
