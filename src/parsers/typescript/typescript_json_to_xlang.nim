## TypeScript Parser JSON to XLang JSON Converter
##
## Converts the JSON output from typescript_to_xlang.ts (TypeScript Compiler API AST)
## to canonical XLang JSON format matching xlang_types.nim.
##
## TypeScript parser already uses "xnk" prefixes but with different field names:
## - "name" → "funcName", "declName", "typeNameDecl", "enumName", "fieldName"
## - "declarations" → "moduleDecls"
## - "parameters" → "params"
## - "type" → "declType", "fieldType", "paramType"
## - "value" → "literalValue", "boolValue"
##
## Also handles TypeScript-specific constructs:
## - Type annotations and type system
## - Decorators
## - Generics
## - Union and intersection types
## - Namespaces/modules
##
## Usage: nim c -r typescript_json_to_xlang.nim input.json > output.xlang.json

import json, options, strutils, os, tables

# Forward declarations
proc convertNode(node: JsonNode): JsonNode
proc convertType(node: JsonNode): JsonNode
proc convertParameter(param: JsonNode): JsonNode

proc convertFile(node: JsonNode): JsonNode =
  ## Convert TypeScript SourceFile to XLang xnkFile
  result = %* {
    "kind": "xnkFile",
    "fileName": "",
    "moduleDecls": []
  }

  if node.hasKey("fileName"):
    result["fileName"] = node["fileName"]

  # Map "declarations" → "moduleDecls"
  if node.hasKey("declarations") and node["declarations"].kind == JArray:
    for decl in node["declarations"]:
      result["moduleDecls"].add(convertNode(decl))

proc convertClassDecl(node: JsonNode): JsonNode =
  ## Convert TypeScript class to XLang xnkClassDecl
  result = %* {
    "kind": "xnkClassDecl",
    "typeNameDecl": "",
    "baseTypes": [],
    "members": []
  }

  # Map "name" → "typeNameDecl"
  if node.hasKey("name"):
    result["typeNameDecl"] = node["name"]

  # Base types already in array format
  if node.hasKey("baseTypes") and node["baseTypes"].kind == JArray:
    for baseType in node["baseTypes"]:
      result["baseTypes"].add(convertNode(baseType))

  # Convert members
  if node.hasKey("members") and node["members"].kind == JArray:
    for member in node["members"]:
      result["members"].add(convertNode(member))

  # Type parameters for generics
  if node.hasKey("typeParameters") and node["typeParameters"].kind == JArray:
    for typeParam in node["typeParameters"]:
      let genericParam = convertTypeParameter(typeParam)
      if not genericParam.isNil:
        # Add to members as markers (XLang may need better representation)
        result["members"].insert(genericParam, 0)

  # Decorators
  if node.hasKey("decorators") and node["decorators"].kind == JArray:
    # TypeScript decorators already in correct format
    pass

proc convertInterfaceDecl(node: JsonNode): JsonNode =
  ## Convert TypeScript interface to XLang xnkInterfaceDecl
  result = %* {
    "kind": "xnkInterfaceDecl",
    "typeNameDecl": "",
    "baseTypes": [],
    "members": []
  }

  # Map "name" → "typeNameDecl"
  if node.hasKey("name"):
    result["typeNameDecl"] = node["name"]

  # Base types (extends)
  if node.hasKey("baseTypes") and node["baseTypes"].kind == JArray:
    for baseType in node["baseTypes"]:
      result["baseTypes"].add(convertNode(baseType))

  # Members
  if node.hasKey("members") and node["members"].kind == JArray:
    for member in node["members"]:
      result["members"].add(convertNode(member))

  # Type parameters
  if node.hasKey("typeParameters") and node["typeParameters"].kind == JArray:
    for typeParam in node["typeParameters"]:
      let genericParam = convertTypeParameter(typeParam)
      if not genericParam.isNil:
        result["members"].insert(genericParam, 0)

proc convertEnumDecl(node: JsonNode): JsonNode =
  ## Convert TypeScript enum to XLang xnkEnumDecl
  result = %* {
    "kind": "xnkEnumDecl",
    "enumName": "",
    "enumMembers": []
  }

  # Map "name" → "enumName"
  if node.hasKey("name"):
    result["enumName"] = node["name"]

  # Convert members
  if node.hasKey("members") and node["members"].kind == JArray:
    for member in node["members"]:
      let enumMember = %* {
        "name": "",
        "value": nil
      }

      if member.hasKey("name"):
        enumMember["name"] = member["name"]

      if member.hasKey("initializer") and not member["initializer"].isNil:
        enumMember["value"] = convertNode(member["initializer"])

      result["enumMembers"].add(enumMember)

proc convertFuncDecl(node: JsonNode): JsonNode =
  ## Convert TypeScript function to XLang xnkFuncDecl
  result = %* {
    "kind": "xnkFuncDecl",
    "funcName": "",
    "params": [],
    "returnType": nil,
    "body": %* {"kind": "xnkBlockStmt", "blockBody": []},
    "isAsync": false
  }

  # Map "name" → "funcName"
  if node.hasKey("name"):
    result["funcName"] = node["name"]

  # Map "parameters" → "params"
  if node.hasKey("parameters") and node["parameters"].kind == JArray:
    for param in node["parameters"]:
      result["params"].add(convertParameter(param))

  # Return type
  if node.hasKey("returnType") and not node["returnType"].isNil:
    result["returnType"] = convertNode(node["returnType"])

  # Body
  if node.hasKey("body") and not node["body"].isNil:
    result["body"] = convertNode(node["body"])

  # Async flag
  if node.hasKey("isAsync"):
    result["isAsync"] = node["isAsync"]

  # Type parameters
  if node.hasKey("typeParameters") and node["typeParameters"].kind == JArray:
    # Store as metadata or in special field
    # XLang may need explicit generic parameter support for functions
    pass

proc convertMethodDecl(node: JsonNode): JsonNode =
  ## Convert TypeScript method to XLang xnkMethodDecl
  result = %* {
    "kind": "xnkMethodDecl",
    "funcName": "",
    "params": [],
    "returnType": nil,
    "body": %* {"kind": "xnkBlockStmt", "blockBody": []},
    "isAsync": false
  }

  # Map "name" → "funcName"
  if node.hasKey("name"):
    result["funcName"] = node["name"]

  # Map "parameters" → "params"
  if node.hasKey("parameters") and node["parameters"].kind == JArray:
    for param in node["parameters"]:
      result["params"].add(convertParameter(param))

  # Return type
  if node.hasKey("returnType") and not node["returnType"].isNil:
    result["returnType"] = convertNode(node["returnType"])

  # Body
  if node.hasKey("body") and not node["body"].isNil:
    result["body"] = convertNode(node["body"])

  # Async flag
  if node.hasKey("isAsync"):
    result["isAsync"] = node["isAsync"]

proc convertFieldDecl(node: JsonNode): JsonNode =
  ## Convert TypeScript property/field to XLang xnkFieldDecl
  result = %* {
    "kind": "xnkFieldDecl",
    "fieldName": "",
    "fieldType": %* {"kind": "xnkNamedType", "typeName": "any"},
    "fieldInitializer": nil
  }

  # Map "name" → "fieldName"
  if node.hasKey("name"):
    result["fieldName"] = node["name"]

  # Map "type" → "fieldType"
  if node.hasKey("type") and not node["type"].isNil:
    result["fieldType"] = convertNode(node["type"])

  # Initializer
  if node.hasKey("initializer") and not node["initializer"].isNil:
    result["fieldInitializer"] = convertNode(node["initializer"])

proc convertVarDecl(node: JsonNode): JsonNode =
  ## Convert TypeScript variable declaration
  ## Handles var, let, const
  let kind = node["kind"].getStr  # Already xnkVarDecl, xnkLetDecl, or xnkConstDecl

  result = %* {
    "kind": kind,
    "declName": "",
    "declType": nil,
    "initializer": nil
  }

  # Variable declarations can have multiple declarators
  # Take first one or handle specially
  if node.hasKey("declarations") and node["declarations"].kind == JArray and node["declarations"].len > 0:
    let firstDecl = node["declarations"][0]

    if firstDecl.hasKey("name"):
      result["declName"] = firstDecl["name"]

    if firstDecl.hasKey("type") and not firstDecl["type"].isNil:
      result["declType"] = convertNode(firstDecl["type"])

    if firstDecl.hasKey("initializer") and not firstDecl["initializer"].isNil:
      result["initializer"] = convertNode(firstDecl["initializer"])
  elif node.hasKey("name"):
    # Single declaration format
    result["declName"] = node["name"]

    if node.hasKey("type") and not node["type"].isNil:
      result["declType"] = convertNode(node["type"])

    if node.hasKey("initializer") and not node["initializer"].isNil:
      result["initializer"] = convertNode(node["initializer"])

proc convertTypeAliasDecl(node: JsonNode): JsonNode =
  ## Convert TypeScript type alias to XLang xnkTypeDecl
  result = %* {
    "kind": "xnkTypeDecl",
    "typeDefName": "",
    "typeDefBody": %* {"kind": "xnkNamedType", "typeName": "any"}
  }

  if node.hasKey("name"):
    result["typeDefName"] = node["name"]

  if node.hasKey("type") and not node["type"].isNil:
    result["typeDefBody"] = convertNode(node["type"])

proc convertModuleDecl(node: JsonNode): JsonNode =
  ## Convert TypeScript namespace/module to XLang xnkNamespace or xnkModule
  result = %* {
    "kind": "xnkNamespace",
    "namespaceName": "",
    "namespaceBody": []
  }

  if node.hasKey("name"):
    result["namespaceName"] = node["name"]

  if node.hasKey("body") and node["body"].kind == JArray:
    for stmt in node["body"]:
      result["namespaceBody"].add(convertNode(stmt))
  elif node.hasKey("body") and not node["body"].isNil:
    result["namespaceBody"].add(convertNode(node["body"]))

proc convertImportDecl(node: JsonNode): JsonNode =
  ## Convert TypeScript import to XLang xnkImport with rich import structure
  result = %* {
    "kind": "xnkImport",
    "importPath": "",
    "importKind": "ikNamed",  # Default, will be determined
    "importBindings": [],
    "importAlias": nil  # Deprecated but kept for compatibility
  }

  # Get module path
  if node.hasKey("moduleSpecifier"):
    result["importPath"] = node["moduleSpecifier"]

  # Determine import kind and bindings
  if not node.hasKey("importClause") or node["importClause"].isNil:
    # Side-effect import: import "./file"
    result["importKind"] = %"ikSideEffect"
    return result

  let clause = node["importClause"]
  var hasDefault = false
  var hasNamed = false
  var hasNamespace = false

  # Check for default import
  if clause.hasKey("name") and not clause["name"].isNil:
    hasDefault = true
    let defaultBinding = %* {
      "sourceName": "default",
      "localName": clause["name"].getStr,
      "isDefault": true
    }
    result["importBindings"].add(defaultBinding)

  # Check for named bindings (namespace or named imports)
  if clause.hasKey("namedBindings") and not clause["namedBindings"].isNil:
    let bindings = clause["namedBindings"]
    let bindingsKind = if bindings.hasKey("kind"): bindings["kind"].getStr else: ""

    if bindingsKind == "NamespaceImport":
      # import * as ns from "mod"
      hasNamespace = true
      if bindings.hasKey("name"):
        result["importAlias"] = bindings["name"]
        let nsBinding = %* {
          "sourceName": "*",
          "localName": bindings["name"].getStr,
          "isDefault": false
        }
        result["importBindings"].add(nsBinding)

    elif bindingsKind == "NamedImports":
      # import { a, b, c as d } from "mod"
      hasNamed = true
      if bindings.hasKey("elements") and bindings["elements"].kind == JArray:
        for elem in bindings["elements"]:
          var sourceName = ""
          var localName = ""

          # Get property name (what we're importing from the module)
          if elem.hasKey("propertyName"):
            sourceName = elem["propertyName"].getStr
          elif elem.hasKey("name"):
            sourceName = elem["name"].getStr

          # Get local name (what we call it locally)
          if elem.hasKey("name"):
            localName = elem["name"].getStr

          # If no propertyName, source and local are the same
          if sourceName == "":
            sourceName = localName

          let namedBinding = %* {
            "sourceName": sourceName,
            "localName": localName,
            "isDefault": false
          }
          result["importBindings"].add(namedBinding)

  # Determine overall import kind
  if hasDefault and hasNamed:
    result["importKind"] = %"ikMixed"
  elif hasDefault and not hasNamed and not hasNamespace:
    result["importKind"] = %"ikDefault"
  elif hasNamespace:
    result["importKind"] = %"ikNamespace"
  elif hasNamed:
    result["importKind"] = %"ikNamed"
  else:
    result["importKind"] = %"ikSideEffect"

proc convertExportDecl(node: JsonNode): JsonNode =
  ## Convert TypeScript export to XLang xnkExport
  result = %* {
    "kind": "xnkExport",
    "exportedDecl": %* {"kind": "xnkIdentifier", "identName": ""}
  }

  if node.hasKey("declaration") and not node["declaration"].isNil:
    result["exportedDecl"] = convertNode(node["declaration"])

proc convertParameter(param: JsonNode): JsonNode =
  ## Convert TypeScript parameter to XLang xnkParameter
  result = %* {
    "kind": "xnkParameter",
    "paramName": "",
    "paramType": %* {"kind": "xnkNamedType", "typeName": "any"},
    "defaultValue": nil
  }

  if param.hasKey("name"):
    result["paramName"] = param["name"]

  if param.hasKey("type") and not param["type"].isNil:
    result["paramType"] = convertNode(param["type"])

  if param.hasKey("initializer") and not param["initializer"].isNil:
    result["defaultValue"] = convertNode(param["initializer"])

  # TypeScript-specific: optional parameters, rest parameters
  if param.hasKey("questionToken") and param["questionToken"].getBool:
    # Mark as optional - may need XLang extension
    pass

  if param.hasKey("dotDotDotToken") and param["dotDotDotToken"].getBool:
    # Rest parameter - modify type
    if result["paramType"].hasKey("typeName"):
      result["paramType"]["typeName"] = %* (result["paramType"]["typeName"].getStr & "...")

proc convertTypeParameter(typeParam: JsonNode): JsonNode =
  ## Convert TypeScript type parameter to XLang xnkGenericParameter
  result = %* {
    "kind": "xnkGenericParameter",
    "genericParamName": "",
    "genericParamConstraints": []
  }

  if typeParam.hasKey("name"):
    result["genericParamName"] = typeParam["name"]

  if typeParam.hasKey("constraint") and not typeParam["constraint"].isNil:
    result["genericParamConstraints"].add(convertNode(typeParam["constraint"]))

  if typeParam.hasKey("default") and not typeParam["default"].isNil:
    # Default type - may need XLang extension
    pass

proc convertBlockStmt(node: JsonNode): JsonNode =
  ## Convert TypeScript block to XLang xnkBlockStmt
  result = %* {
    "kind": "xnkBlockStmt",
    "blockBody": []
  }

  if node.hasKey("statements") and node["statements"].kind == JArray:
    for stmt in node["statements"]:
      result["blockBody"].add(convertNode(stmt))

proc convertIfStmt(node: JsonNode): JsonNode =
  ## Convert TypeScript if statement to XLang xnkIfStmt
  result = %* {
    "kind": "xnkIfStmt",
    "ifCondition": %* {"kind": "xnkBoolLit", "boolValue": true},
    "ifBody": %* {"kind": "xnkBlockStmt", "blockBody": []},
    "elseBody": nil
  }

  if node.hasKey("expression"):
    result["ifCondition"] = convertNode(node["expression"])

  if node.hasKey("thenStatement"):
    result["ifBody"] = convertNode(node["thenStatement"])

  if node.hasKey("elseStatement") and not node["elseStatement"].isNil:
    result["elseBody"] = convertNode(node["elseStatement"])

proc convertWhileStmt(node: JsonNode): JsonNode =
  ## Convert TypeScript while loop to XLang xnkWhileStmt
  result = %* {
    "kind": "xnkWhileStmt",
    "whileCondition": %* {"kind": "xnkBoolLit", "boolValue": true},
    "whileBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("expression"):
    result["whileCondition"] = convertNode(node["expression"])

  if node.hasKey("statement"):
    result["whileBody"] = convertNode(node["statement"])

proc convertDoWhileStmt(node: JsonNode): JsonNode =
  ## Convert TypeScript do-while to XLang xnkDoWhileStmt
  result = %* {
    "kind": "xnkDoWhileStmt",
    "whileCondition": %* {"kind": "xnkBoolLit", "boolValue": true},
    "whileBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("expression"):
    result["whileCondition"] = convertNode(node["expression"])

  if node.hasKey("statement"):
    result["whileBody"] = convertNode(node["statement"])

proc convertForStmt(node: JsonNode): JsonNode =
  ## Convert TypeScript for loop to XLang xnkForStmt
  result = %* {
    "kind": "xnkForStmt",
    "forInit": nil,
    "forCond": nil,
    "forIncrement": nil,
    "forBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("initializer") and not node["initializer"].isNil:
    result["forInit"] = convertNode(node["initializer"])

  if node.hasKey("condition") and not node["condition"].isNil:
    result["forCond"] = convertNode(node["condition"])

  if node.hasKey("incrementor") and not node["incrementor"].isNil:
    result["forIncrement"] = convertNode(node["incrementor"])

  if node.hasKey("statement"):
    result["forBody"] = convertNode(node["statement"])

proc convertForOfStmt(node: JsonNode): JsonNode =
  ## Convert TypeScript for-of/for-in to XLang xnkForeachStmt
  result = %* {
    "kind": "xnkForeachStmt",
    "foreachVar": %* {"kind": "xnkIdentifier", "identName": "item"},
    "foreachIter": %* {"kind": "xnkIdentifier", "identName": "collection"},
    "foreachBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("initializer"):
    result["foreachVar"] = convertNode(node["initializer"])

  if node.hasKey("expression"):
    result["foreachIter"] = convertNode(node["expression"])

  if node.hasKey("statement"):
    result["foreachBody"] = convertNode(node["statement"])

proc convertSwitchStmt(node: JsonNode): JsonNode =
  ## Convert TypeScript switch to XLang xnkSwitchStmt
  result = %* {
    "kind": "xnkSwitchStmt",
    "switchExpr": %* {"kind": "xnkIdentifier", "identName": ""},
    "switchCases": []
  }

  if node.hasKey("expression"):
    result["switchExpr"] = convertNode(node["expression"])

  if node.hasKey("caseBlock") and node["caseBlock"].hasKey("clauses"):
    for clause in node["caseBlock"]["clauses"]:
      result["switchCases"].add(convertSwitchClause(clause))

proc convertSwitchClause(node: JsonNode): JsonNode =
  ## Convert TypeScript case/default clause
  if node.hasKey("isDefault") and node["isDefault"].getBool:
    result = %* {
      "kind": "xnkDefaultClause",
      "defaultBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
    }

    if node.hasKey("statements"):
      var blockBody = newJArray()
      for stmt in node["statements"]:
        blockBody.add(convertNode(stmt))
      result["defaultBody"] = %* {"kind": "xnkBlockStmt", "blockBody": blockBody}
  else:
    result = %* {
      "kind": "xnkCaseClause",
      "caseValues": [],
      "caseBody": %* {"kind": "xnkBlockStmt", "blockBody": []},
      "caseFallthrough": true  # TypeScript has implicit fallthrough
    }

    if node.hasKey("expression"):
      result["caseValues"].add(convertNode(node["expression"]))

    if node.hasKey("statements"):
      var blockBody = newJArray()
      var hasFallthrough = true
      for stmt in node["statements"]:
        let converted = convertNode(stmt)
        blockBody.add(converted)
        # Check for break/return
        if converted.hasKey("kind"):
          let stmtKind = converted["kind"].getStr
          if stmtKind == "xnkBreakStmt" or stmtKind == "xnkReturnStmt":
            hasFallthrough = false
      result["caseBody"] = %* {"kind": "xnkBlockStmt", "blockBody": blockBody}
      result["caseFallthrough"] = %hasFallthrough

proc convertTryStmt(node: JsonNode): JsonNode =
  ## Convert TypeScript try-catch-finally to XLang xnkTryStmt
  result = %* {
    "kind": "xnkTryStmt",
    "tryBody": %* {"kind": "xnkBlockStmt", "blockBody": []},
    "catchClauses": [],
    "finallyClause": nil
  }

  if node.hasKey("tryBlock"):
    result["tryBody"] = convertNode(node["tryBlock"])

  if node.hasKey("catchClause") and not node["catchClause"].isNil:
    let catchNode = %* {
      "kind": "xnkCatchStmt",
      "catchType": nil,
      "catchVar": nil,
      "catchBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
    }

    let catchClause = node["catchClause"]
    if catchClause.hasKey("variableDeclaration"):
      let varDecl = catchClause["variableDeclaration"]
      if varDecl.hasKey("name"):
        catchNode["catchVar"] = varDecl["name"]
      if varDecl.hasKey("type"):
        catchNode["catchType"] = convertNode(varDecl["type"])

    if catchClause.hasKey("block"):
      catchNode["catchBody"] = convertNode(catchClause["block"])

    result["catchClauses"].add(catchNode)

  if node.hasKey("finallyBlock") and not node["finallyBlock"].isNil:
    result["finallyClause"] = %* {
      "kind": "xnkFinallyStmt",
      "finallyBody": convertNode(node["finallyBlock"])
    }

proc convertReturnStmt(node: JsonNode): JsonNode =
  ## Convert TypeScript return to XLang xnkReturnStmt
  result = %* {
    "kind": "xnkReturnStmt",
    "returnExpr": nil
  }

  if node.hasKey("expression") and not node["expression"].isNil:
    result["returnExpr"] = convertNode(node["expression"])

proc convertThrowStmt(node: JsonNode): JsonNode =
  ## Convert TypeScript throw to XLang xnkThrowStmt
  result = %* {
    "kind": "xnkThrowStmt",
    "throwExpr": %* {"kind": "xnkIdentifier", "identName": "Error"}
  }

  if node.hasKey("expression"):
    result["throwExpr"] = convertNode(node["expression"])

proc convertBreakStmt(node: JsonNode): JsonNode =
  ## Convert TypeScript break to XLang xnkBreakStmt
  result = %* {
    "kind": "xnkBreakStmt",
    "label": nil
  }

  if node.hasKey("label") and not node["label"].isNil:
    result["label"] = node["label"]

proc convertContinueStmt(node: JsonNode): JsonNode =
  ## Convert TypeScript continue to XLang xnkContinueStmt
  result = %* {
    "kind": "xnkContinueStmt",
    "label": nil
  }

  if node.hasKey("label") and not node["label"].isNil:
    result["label"] = node["label"]

proc convertBinaryExpr(node: JsonNode): JsonNode =
  ## Convert TypeScript binary expression to XLang xnkBinaryExpr
  result = %* {
    "kind": "xnkBinaryExpr",
    "binaryLeft": %* {"kind": "xnkNoneLit"},
    "binaryOp": "",
    "binaryRight": %* {"kind": "xnkNoneLit"}
  }

  if node.hasKey("left"):
    result["binaryLeft"] = convertNode(node["left"])

  if node.hasKey("operatorToken"):
    result["binaryOp"] = node["operatorToken"]

  if node.hasKey("right"):
    result["binaryRight"] = convertNode(node["right"])

proc convertUnaryExpr(node: JsonNode): JsonNode =
  ## Convert TypeScript unary/prefix expression to XLang xnkUnaryExpr
  result = %* {
    "kind": "xnkUnaryExpr",
    "unaryOp": "",
    "unaryOperand": %* {"kind": "xnkNoneLit"}
  }

  if node.hasKey("operator"):
    result["unaryOp"] = node["operator"]

  if node.hasKey("operand"):
    result["unaryOperand"] = convertNode(node["operand"])

proc convertCallExpr(node: JsonNode): JsonNode =
  ## Convert TypeScript call expression to XLang xnkCallExpr
  result = %* {
    "kind": "xnkCallExpr",
    "callee": %* {"kind": "xnkIdentifier", "identName": ""},
    "args": []
  }

  if node.hasKey("expression"):
    result["callee"] = convertNode(node["expression"])

  if node.hasKey("arguments") and node["arguments"].kind == JArray:
    for arg in node["arguments"]:
      result["args"].add(convertNode(arg))

  # Type arguments for generic calls
  if node.hasKey("typeArguments") and node["typeArguments"].kind == JArray:
    # Store as metadata - may need XLang extension
    pass

proc convertPropertyAccessExpr(node: JsonNode): JsonNode =
  ## Convert TypeScript property access to XLang xnkMemberAccessExpr
  result = %* {
    "kind": "xnkMemberAccessExpr",
    "memberExpr": %* {"kind": "xnkIdentifier", "identName": ""},
    "memberName": ""
  }

  if node.hasKey("expression"):
    result["memberExpr"] = convertNode(node["expression"])

  if node.hasKey("name"):
    result["memberName"] = node["name"]

proc convertElementAccessExpr(node: JsonNode): JsonNode =
  ## Convert TypeScript element access (array/object indexing) to XLang xnkIndexExpr
  result = %* {
    "kind": "xnkIndexExpr",
    "indexExpr": %* {"kind": "xnkIdentifier", "identName": ""},
    "indexArgs": []
  }

  if node.hasKey("expression"):
    result["indexExpr"] = convertNode(node["expression"])

  if node.hasKey("argumentExpression"):
    result["indexArgs"].add(convertNode(node["argumentExpression"]))

proc convertConditionalExpr(node: JsonNode): JsonNode =
  ## Convert TypeScript ternary/conditional to XLang xnkTernaryExpr
  result = %* {
    "kind": "xnkTernaryExpr",
    "ternaryCondition": %* {"kind": "xnkBoolLit", "boolValue": true},
    "ternaryThen": %* {"kind": "xnkNoneLit"},
    "ternaryElse": %* {"kind": "xnkNoneLit"}
  }

  if node.hasKey("condition"):
    result["ternaryCondition"] = convertNode(node["condition"])

  if node.hasKey("whenTrue"):
    result["ternaryThen"] = convertNode(node["whenTrue"])

  if node.hasKey("whenFalse"):
    result["ternaryElse"] = convertNode(node["whenFalse"])

proc convertArrowFunction(node: JsonNode): JsonNode =
  ## Convert TypeScript arrow function to XLang xnkLambdaExpr
  result = %* {
    "kind": "xnkLambdaExpr",
    "lambdaParams": [],
    "lambdaBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("parameters") and node["parameters"].kind == JArray:
    for param in node["parameters"]:
      result["lambdaParams"].add(convertParameter(param))

  if node.hasKey("body"):
    result["lambdaBody"] = convertNode(node["body"])

proc convertArrayLiteralExpr(node: JsonNode): JsonNode =
  ## Convert TypeScript array literal to XLang xnkListExpr
  result = %* {
    "kind": "xnkListExpr",
    "elements": []
  }

  if node.hasKey("elements") and node["elements"].kind == JArray:
    for elem in node["elements"]:
      result["elements"].add(convertNode(elem))

proc convertObjectLiteralExpr(node: JsonNode): JsonNode =
  ## Convert TypeScript object literal to XLang xnkMapLiteral with xnkDictEntry
  result = %* {
    "kind": "xnkMapLiteral",
    "entries": []
  }

  if node.hasKey("properties") and node["properties"].kind == JArray:
    for prop in node["properties"]:
      let propKind = if prop.hasKey("kind"): prop["kind"].getStr else: ""

      case propKind
      of "PropertyAssignment":
        # Regular property: key: value
        let entry = %* {
          "kind": "xnkDictEntry",
          "key": %* {"kind": "xnkIdentifier", "identName": ""},
          "value": %* {"kind": "xnkNoneLit"},
          "isComputed": false,
          "isShorthand": false
        }
        if prop.hasKey("name"):
          # Check if computed property name [expr]
          if prop.hasKey("computed") and prop["computed"].getBool:
            entry["isComputed"] = %true
          entry["key"] = convertNode(prop["name"])
        if prop.hasKey("initializer"):
          entry["value"] = convertNode(prop["initializer"])
        result["entries"].add(entry)

      of "ShorthandPropertyAssignment":
        # Shorthand property: { name } → { name: name }
        let entry = %* {
          "kind": "xnkDictEntry",
          "key": %* {"kind": "xnkIdentifier", "identName": ""},
          "value": %* {"kind": "xnkIdentifier", "identName": ""},
          "isComputed": false,
          "isShorthand": true
        }
        if prop.hasKey("name"):
          let nameNode = convertNode(prop["name"])
          entry["key"] = nameNode
          entry["value"] = nameNode  # Same identifier for key and value
        result["entries"].add(entry)

      of "SpreadAssignment":
        # Spread in object: { ...other }
        result["entries"].add(convertSpreadElement(prop))

      of "MethodDeclaration":
        # Method shorthand: { method() { } }
        let methodNode = convertMethodDecl(prop)
        # Store as a property with method value
        let entry = %* {
          "kind": "xnkDictEntry",
          "key": %* {"kind": "xnkIdentifier", "identName": ""},
          "value": methodNode,
          "isComputed": false,
          "isShorthand": false
        }
        if prop.hasKey("name"):
          entry["key"] = convertNode(prop["name"])
        result["entries"].add(entry)

      else:
        # Fallback for unknown property types
        if prop.hasKey("name") and prop.hasKey("initializer"):
          let entry = %* {
            "kind": "xnkDictEntry",
            "key": convertNode(prop["name"]),
            "value": convertNode(prop["initializer"]),
            "isComputed": false,
            "isShorthand": false
          }
          result["entries"].add(entry)

proc convertTemplateExpression(node: JsonNode): JsonNode =
  ## Convert TypeScript template string to XLang xnkStringInterpolation
  result = %* {
    "kind": "xnkStringInterpolation",
    "interpParts": [],
    "interpIsExpr": []
  }

  if node.hasKey("head"):
    result["interpParts"].add(%* {
      "kind": "xnkStringLit",
      "literalValue": node["head"]
    })
    result["interpIsExpr"].add(%false)

  if node.hasKey("templateSpans") and node["templateSpans"].kind == JArray:
    for span in node["templateSpans"]:
      if span.hasKey("expression"):
        result["interpParts"].add(convertNode(span["expression"]))
        result["interpIsExpr"].add(%true)

      if span.hasKey("literal"):
        result["interpParts"].add(%* {
          "kind": "xnkStringLit",
          "literalValue": span["literal"]
        })
        result["interpIsExpr"].add(%false)

proc convertAsExpression(node: JsonNode): JsonNode =
  ## Convert TypeScript type assertion (as) to call expression
  ## Note: XLang may need explicit type assertion node
  result = %* {
    "kind": "xnkCallExpr",
    "callee": %* {"kind": "xnkIdentifier", "identName": "cast"},
    "args": []
  }

  if node.hasKey("expression"):
    result["args"].add(convertNode(node["expression"]))

  if node.hasKey("type"):
    result["args"].add(convertNode(node["type"]))

proc convertTypeOfExpression(node: JsonNode): JsonNode =
  ## Convert TypeScript typeof to unary expression
  result = %* {
    "kind": "xnkUnaryExpr",
    "unaryOp": "typeof",
    "unaryOperand": %* {"kind": "xnkNoneLit"}
  }

  if node.hasKey("expression"):
    result["unaryOperand"] = convertNode(node["expression"])

proc convertAwaitExpression(node: JsonNode): JsonNode =
  ## Convert TypeScript await to XLang xnkAwaitExpr
  result = %* {
    "kind": "xnkAwaitExpr",
    "awaitExpr": %* {"kind": "xnkIdentifier", "identName": ""}
  }

  if node.hasKey("expression"):
    result["awaitExpr"] = convertNode(node["expression"])

proc convertNewExpression(node: JsonNode): JsonNode =
  ## Convert TypeScript new expression to XLang xnkCallExpr with isConstructor flag
  result = %* {
    "kind": "xnkCallExpr",
    "callee": %* {"kind": "xnkIdentifier", "identName": ""},
    "args": [],
    "isConstructor": true
  }

  if node.hasKey("expression"):
    result["callee"] = convertNode(node["expression"])

  if node.hasKey("arguments") and node["arguments"].kind == JArray:
    for arg in node["arguments"]:
      result["args"].add(convertNode(arg))

  # Type arguments for generic constructors
  if node.hasKey("typeArguments") and node["typeArguments"].kind == JArray:
    # Store as metadata - may need XLang extension
    pass

proc convertSpreadElement(node: JsonNode): JsonNode =
  ## Convert TypeScript spread element (...expr) to XLang xnkUnaryExpr(opSpread)
  result = %* {
    "kind": "xnkUnaryExpr",
    "unaryOp": "spread",
    "unaryOperand": %* {"kind": "xnkNoneLit"}
  }

  if node.hasKey("expression"):
    result["unaryOperand"] = convertNode(node["expression"])

proc convertDeleteExpression(node: JsonNode): JsonNode =
  ## Convert TypeScript delete expression to XLang xnkDeleteStmt
  result = %* {
    "kind": "xnkDeleteStmt",
    "deleteTarget": %* {"kind": "xnkIdentifier", "identName": ""}
  }

  if node.hasKey("expression"):
    result["deleteTarget"] = convertNode(node["expression"])

proc convertVoidExpression(node: JsonNode): JsonNode =
  ## Convert TypeScript void expression to XLang xnkDiscardStmt
  result = %* {
    "kind": "xnkDiscardStmt",
    "discardExpr": nil
  }

  if node.hasKey("expression"):
    result["discardExpr"] = convertNode(node["expression"])

proc convertNonNullExpression(node: JsonNode): JsonNode =
  ## Convert TypeScript non-null assertion (expr!) - just unwrap, it's compile-time only
  if node.hasKey("expression"):
    result = convertNode(node["expression"])
  else:
    result = %* {"kind": "xnkNoneLit"}

proc convertFunctionExpression(node: JsonNode): JsonNode =
  ## Convert TypeScript function expression to XLang xnkLambdaExpr
  ## Similar to convertArrowFunction but for function() {} syntax
  result = %* {
    "kind": "xnkLambdaExpr",
    "lambdaParams": [],
    "lambdaReturnType": nil,
    "lambdaBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("parameters") and node["parameters"].kind == JArray:
    for param in node["parameters"]:
      result["lambdaParams"].add(convertParameter(param))

  if node.hasKey("type") and not node["type"].isNil:
    result["lambdaReturnType"] = convertType(node["type"])

  if node.hasKey("body"):
    result["lambdaBody"] = convertNode(node["body"])

proc convertClassExpression(node: JsonNode): JsonNode =
  ## Convert TypeScript class expression (anonymous class) to XLang xnkClassDecl
  result = convertClassDecl(node)
  # Name might be empty for anonymous classes

proc convertYieldExpression(node: JsonNode): JsonNode =
  ## Convert TypeScript yield expression to XLang xnkIteratorYield
  result = %* {
    "kind": "xnkIteratorYield",
    "iteratorYieldValue": nil
  }

  if node.hasKey("expression") and not node["expression"].isNil:
    result["iteratorYieldValue"] = convertNode(node["expression"])

  # Check for yield* (yield from)
  if node.hasKey("asteriskToken") and node["asteriskToken"].getBool:
    result["kind"] = "xnkIteratorDelegate"
    result["iteratorDelegateExpr"] = result["iteratorYieldValue"]
    result.delete("iteratorYieldValue")

proc convertObjectBindingPattern(node: JsonNode): JsonNode =
  ## Convert TypeScript object destructuring to XLang xnkDestructureObj
  result = %* {
    "kind": "xnkDestructureObj",
    "destructObjFields": [],
    "destructObjSource": %* {"kind": "xnkNoneLit"}
  }

  if node.hasKey("elements") and node["elements"].kind == JArray:
    for elem in node["elements"]:
      if elem.hasKey("name"):
        let name = if elem["name"].kind == JString: elem["name"].getStr
                   else: elem["name"]["text"].getStr
        result["destructObjFields"].add(%name)

proc convertArrayBindingPattern(node: JsonNode): JsonNode =
  ## Convert TypeScript array destructuring to XLang xnkDestructureArray
  result = %* {
    "kind": "xnkDestructureArray",
    "destructArrayVars": [],
    "destructArrayRest": nil,
    "destructArraySource": %* {"kind": "xnkNoneLit"}
  }

  if node.hasKey("elements") and node["elements"].kind == JArray:
    for elem in node["elements"]:
      if elem.kind == JNull or (elem.hasKey("kind") and elem["kind"].getStr == "OmittedExpression"):
        # Array hole, skip
        result["destructArrayVars"].add(%"")
      elif elem.hasKey("dotDotDotToken") and elem["dotDotDotToken"].getBool:
        # Rest element
        if elem.hasKey("name"):
          let name = if elem["name"].kind == JString: elem["name"].getStr
                     else: elem["name"]["text"].getStr
          result["destructArrayRest"] = %name
      elif elem.hasKey("name"):
        let name = if elem["name"].kind == JString: elem["name"].getStr
                   else: elem["name"]["text"].getStr
        result["destructArrayVars"].add(%name)

proc convertConstructor(node: JsonNode): JsonNode =
  ## Convert TypeScript constructor to XLang xnkConstructorDecl
  result = %* {
    "kind": "xnkConstructorDecl",
    "constructorParams": [],
    "constructorInitializers": [],
    "constructorBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("parameters") and node["parameters"].kind == JArray:
    for param in node["parameters"]:
      result["constructorParams"].add(convertParameter(param))

  if node.hasKey("body") and not node["body"].isNil:
    result["constructorBody"] = convertNode(node["body"])

proc convertGetAccessor(node: JsonNode): JsonNode =
  ## Convert TypeScript getter to XLang xnkExternal_Property
  result = %* {
    "kind": "xnkExternal_Property",
    "extPropName": "",
    "extPropType": nil,
    "extPropGetter": %* {"kind": "xnkBlockStmt", "blockBody": []},
    "extPropSetter": nil
  }

  if node.hasKey("name"):
    result["extPropName"] = node["name"]

  if node.hasKey("type") and not node["type"].isNil:
    result["extPropType"] = convertType(node["type"])

  if node.hasKey("body") and not node["body"].isNil:
    result["extPropGetter"] = convertNode(node["body"])

proc convertSetAccessor(node: JsonNode): JsonNode =
  ## Convert TypeScript setter to XLang xnkExternal_Property
  result = %* {
    "kind": "xnkExternal_Property",
    "extPropName": "",
    "extPropType": nil,
    "extPropGetter": nil,
    "extPropSetter": %* {"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("name"):
    result["extPropName"] = node["name"]

  # Setter type comes from parameter
  if node.hasKey("parameters") and node["parameters"].kind == JArray and node["parameters"].len > 0:
    let param = node["parameters"][0]
    if param.hasKey("type") and not param["type"].isNil:
      result["extPropType"] = convertType(param["type"])

  if node.hasKey("body") and not node["body"].isNil:
    result["extPropSetter"] = convertNode(node["body"])

proc convertDecorator(node: JsonNode): JsonNode =
  ## Convert TypeScript decorator to XLang xnkDecorator
  result = %* {
    "kind": "xnkDecorator",
    "decoratorExpr": %* {"kind": "xnkIdentifier", "identName": ""}
  }

  if node.hasKey("expression"):
    result["decoratorExpr"] = convertNode(node["expression"])

proc convertExpressionStatement(node: JsonNode): JsonNode =
  ## Convert TypeScript expression statement to XLang xnkExpressionStmt
  result = %* {
    "kind": "xnkExpressionStmt",
    "expr": %* {"kind": "xnkNoneLit"}
  }

  if node.hasKey("expression"):
    result["expr"] = convertNode(node["expression"])

proc convertEmptyStatement(node: JsonNode): JsonNode =
  ## Convert TypeScript empty statement (;) to XLang xnkEmptyStmt
  result = %* {"kind": "xnkEmptyStmt"}

proc convertLabeledStatement(node: JsonNode): JsonNode =
  ## Convert TypeScript labeled statement to XLang xnkLabeledStmt
  result = %* {
    "kind": "xnkLabeledStmt",
    "labelName": "",
    "labeledStmt": %* {"kind": "xnkEmptyStmt"}
  }

  if node.hasKey("label"):
    result["labelName"] = node["label"]

  if node.hasKey("statement"):
    result["labeledStmt"] = convertNode(node["statement"])

proc convertIdentifier(node: JsonNode): JsonNode =
  ## Convert TypeScript identifier to XLang xnkIdentifier
  result = %* {
    "kind": "xnkIdentifier",
    "identName": ""
  }

  if node.hasKey("name"):
    result["identName"] = node["name"]
  elif node.hasKey("text"):
    result["identName"] = node["text"]

proc convertLiteral(node: JsonNode, xlangKind: string): JsonNode =
  ## Convert TypeScript literal to XLang literal
  case xlangKind
  of "xnkIntLit", "xnkFloatLit", "xnkStringLit", "xnkCharLit":
    result = %* {
      "kind": xlangKind,
      "literalValue": ""
    }
    if node.hasKey("value"):
      if node["value"].kind == JString:
        result["literalValue"] = node["value"]
      else:
        result["literalValue"] = %* $node["value"]
    elif node.hasKey("text"):
      result["literalValue"] = node["text"]

  of "xnkBoolLit":
    result = %* {
      "kind": "xnkBoolLit",
      "boolValue": false
    }
    if node.hasKey("value"):
      result["boolValue"] = node["value"]

  of "xnkNoneLit":
    result = %* {"kind": "xnkNoneLit"}

  else:
    result = node

proc convertType(node: JsonNode): JsonNode =
  ## Convert TypeScript type annotation to XLang type
  if node.isNil or node.kind == JNull:
    return newJNull()

  if not node.hasKey("kind"):
    if node.kind == JString:
      return %* {
        "kind": "xnkNamedType",
        "typeName": node.getStr
      }
    return node

  let kind = node["kind"].getStr

  case kind
  of "TypeReference", "NamedType":
    if node.hasKey("typeArguments") and node["typeArguments"].kind == JArray and node["typeArguments"].len > 0:
      # Generic type
      result = %* {
        "kind": "xnkGenericType",
        "genericTypeName": if node.hasKey("typeName"): node["typeName"].getStr else: "",
        "genericArgs": []
      }
      for arg in node["typeArguments"]:
        result["genericArgs"].add(convertType(arg))
    else:
      result = %* {
        "kind": "xnkNamedType",
        "typeName": if node.hasKey("typeName"): node["typeName"] else: "any"
      }

  of "ArrayType":
    result = %* {
      "kind": "xnkArrayType",
      "elementType": %* {"kind": "xnkNamedType", "typeName": "any"},
      "arraySize": nil
    }
    if node.hasKey("elementType"):
      result["elementType"] = convertType(node["elementType"])

  of "TupleType":
    result = %* {
      "kind": "xnkTupleExpr",
      "elements": []
    }
    if node.hasKey("elementTypes") and node["elementTypes"].kind == JArray:
      for elemType in node["elementTypes"]:
        result["elements"].add(convertType(elemType))

  of "UnionType":
    result = %* {
      "kind": "xnkUnionType",
      "typeMembers": []
    }
    if node.hasKey("types") and node["types"].kind == JArray:
      for t in node["types"]:
        result["typeMembers"].add(convertType(t))

  of "IntersectionType":
    result = %* {
      "kind": "xnkIntersectionType",
      "typeMembers": []
    }
    if node.hasKey("types") and node["types"].kind == JArray:
      for t in node["types"]:
        result["typeMembers"].add(convertType(t))

  of "FunctionType":
    result = %* {
      "kind": "xnkFuncType",
      "funcParams": [],
      "funcReturnType": nil
    }
    if node.hasKey("parameters"):
      for param in node["parameters"]:
        result["funcParams"].add(convertParameter(param))
    if node.hasKey("type"):
      result["funcReturnType"] = convertType(node["type"])

  else:
    result = %* {
      "kind": "xnkNamedType",
      "typeName": if node.hasKey("typeName"): node["typeName"] else: "any"
    }

proc convertNode(node: JsonNode): JsonNode =
  if node.isNil or node.kind == JNull:
    return newJNull()

  if not node.hasKey("kind"):
    if node.kind == JString:
      return convertIdentifier(%* {"name": node})
    return node

  let kind = node["kind"].getStr

  case kind
  of "xnkFile":
    result = convertFile(node)
  of "xnkClassDecl":
    result = convertClassDecl(node)
  of "xnkInterfaceDecl":
    result = convertInterfaceDecl(node)
  of "xnkEnumDecl":
    result = convertEnumDecl(node)
  of "xnkFuncDecl":
    result = convertFuncDecl(node)
  of "xnkMethodDecl":
    result = convertMethodDecl(node)
  of "xnkFieldDecl":
    result = convertFieldDecl(node)
  of "xnkVarDecl", "xnkLetDecl", "xnkConstDecl":
    result = convertVarDecl(node)
  of "xnkTypeDecl", "TypeAliasDeclaration":
    result = convertTypeAliasDecl(node)
  of "xnkNamespace", "ModuleDeclaration":
    result = convertModuleDecl(node)
  of "xnkImport", "ImportDeclaration":
    result = convertImportDecl(node)
  of "xnkExport", "ExportDeclaration":
    result = convertExportDecl(node)
  of "xnkBlockStmt", "Block":
    result = convertBlockStmt(node)
  of "xnkIfStmt", "IfStatement":
    result = convertIfStmt(node)
  of "xnkWhileStmt", "WhileStatement":
    result = convertWhileStmt(node)
  of "xnkDoWhileStmt", "DoStatement":
    result = convertDoWhileStmt(node)
  of "xnkForStmt", "ForStatement":
    result = convertForStmt(node)
  of "xnkForeachStmt", "ForOfStatement", "ForInStatement":
    result = convertForOfStmt(node)
  of "xnkSwitchStmt", "SwitchStatement":
    result = convertSwitchStmt(node)
  of "xnkTryStmt", "TryStatement":
    result = convertTryStmt(node)
  of "xnkReturnStmt", "ReturnStatement":
    result = convertReturnStmt(node)
  of "xnkThrowStmt", "ThrowStatement":
    result = convertThrowStmt(node)
  of "xnkBreakStmt", "BreakStatement":
    result = convertBreakStmt(node)
  of "xnkContinueStmt", "ContinueStatement":
    result = convertContinueStmt(node)
  # Statements
  of "ExpressionStatement":
    result = convertExpressionStatement(node)
  of "EmptyStatement":
    result = convertEmptyStatement(node)
  of "LabeledStatement":
    result = convertLabeledStatement(node)

  # Expressions
  of "xnkBinaryExpr", "BinaryExpression":
    result = convertBinaryExpr(node)
  of "xnkUnaryExpr", "PrefixUnaryExpression", "PostfixUnaryExpression":
    result = convertUnaryExpr(node)
  of "xnkTernaryExpr", "ConditionalExpression":
    result = convertConditionalExpr(node)
  of "xnkCallExpr", "CallExpression":
    result = convertCallExpr(node)
  of "NewExpression":
    result = convertNewExpression(node)
  of "xnkMemberAccessExpr", "PropertyAccessExpression":
    result = convertPropertyAccessExpr(node)
  of "xnkIndexExpr", "ElementAccessExpression":
    result = convertElementAccessExpr(node)
  of "xnkLambdaExpr", "ArrowFunction":
    result = convertArrowFunction(node)
  of "FunctionExpression":
    result = convertFunctionExpression(node)
  of "ClassExpression":
    result = convertClassExpression(node)
  of "ArrayLiteralExpression":
    result = convertArrayLiteralExpr(node)
  of "ObjectLiteralExpression":
    result = convertObjectLiteralExpr(node)
  of "TemplateExpression":
    result = convertTemplateExpression(node)
  of "AsExpression", "SatisfiesExpression":
    result = convertAsExpression(node)
  of "TypeOfExpression":
    result = convertTypeOfExpression(node)
  of "DeleteExpression":
    result = convertDeleteExpression(node)
  of "VoidExpression":
    result = convertVoidExpression(node)
  of "xnkAwaitExpr", "AwaitExpression":
    result = convertAwaitExpression(node)
  of "YieldExpression":
    result = convertYieldExpression(node)
  of "SpreadElement":
    result = convertSpreadElement(node)
  of "NonNullExpression":
    result = convertNonNullExpression(node)

  # Binding patterns (destructuring)
  of "ObjectBindingPattern":
    result = convertObjectBindingPattern(node)
  of "ArrayBindingPattern":
    result = convertArrayBindingPattern(node)

  # Class members
  of "Constructor":
    result = convertConstructor(node)
  of "GetAccessor":
    result = convertGetAccessor(node)
  of "SetAccessor":
    result = convertSetAccessor(node)
  of "Decorator":
    result = convertDecorator(node)
  of "xnkIdentifier", "Identifier":
    result = convertIdentifier(node)
  of "xnkIntLit", "NumericLiteral":
    result = convertLiteral(node, "xnkIntLit")
  of "xnkFloatLit":
    result = convertLiteral(node, "xnkFloatLit")
  of "xnkStringLit", "StringLiteral":
    result = convertLiteral(node, "xnkStringLit")
  of "xnkBoolLit", "TrueKeyword", "FalseKeyword":
    result = convertLiteral(node, "xnkBoolLit")
  of "xnkNoneLit", "NullKeyword", "UndefinedKeyword":
    result = convertLiteral(node, "xnkNoneLit")
  of "TypeReference", "ArrayType", "TupleType", "UnionType", "IntersectionType", "FunctionType":
    result = convertType(node)
  else:
    echo "Warning: Unknown TypeScript AST node kind: ", kind
    result = node

when isMainModule:
  if paramCount() < 1:
    echo "Usage: typescript_json_to_xlang <input.json>"
    quit(1)

  let inputFile = paramStr(1)
  let jsonContent = readFile(inputFile)
  let inputJson = parseJson(jsonContent)

  let outputJson = convertNode(inputJson)

  echo pretty(outputJson, indent=2)
