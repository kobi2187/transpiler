## Java Parser JSON to XLang JSON Converter
##
## Converts the JSON output from java_to_xlang.java (JavaParser AST) to canonical
## XLang JSON format matching xlang_types.nim.
##
## Java parser already uses "xnk" prefixes but with different field names:
## - "name" → "funcName", "declName", "typeNameDecl", "enumName"
## - "declarations" → "moduleDecls"
## - "parameters" → "params"
## - "enumMembers" has different structure
##
## Also handles Java-specific constructs:
## - Package declarations → xnkNamespace
## - Module system (Java 9+)
## - Annotations → xnkDecorator
## - Generic type parameters
##
## Usage: nim c -r java_json_to_xlang.nim input.json > output.xlang.json

import json, options, strutils, os, tables

proc convertNode(node: JsonNode): JsonNode

proc convertFile(node: JsonNode): JsonNode =
  ## Convert Java file node to XLang xnkFile
  result = %* {
    "kind": "xnkFile",
    "fileName": "",
    "moduleDecls": []
  }

  if node.hasKey("fileName"):
    result["fileName"] = node["fileName"]

  # Convert package declaration to namespace
  if node.hasKey("packageDecl") and not node["packageDecl"].isNil:
    let pkg = node["packageDecl"]
    let nsNode = %* {
      "kind": "xnkNamespace",
      "namespaceName": if pkg.hasKey("name"): pkg["name"] else: "",
      "namespaceBody": []
    }
    result["moduleDecls"].add(nsNode)

  # Convert imports
  if node.hasKey("imports") and node["imports"].kind == JArray:
    for imp in node["imports"]:
      result["moduleDecls"].add(convertImport(imp))

  # Convert type declarations
  if node.hasKey("declarations") and node["declarations"].kind == JArray:
    for decl in node["declarations"]:
      let converted = convertNode(decl)
      if not converted.isNil:
        # If we have a package namespace, add to it; otherwise add to file
        if result["moduleDecls"].len > 0 and result["moduleDecls"][0]["kind"].getStr == "xnkNamespace":
          result["moduleDecls"][0]["namespaceBody"].add(converted)
        else:
          result["moduleDecls"].add(converted)

  # Convert module declaration (Java 9+)
  if node.hasKey("moduleDecl") and not node["moduleDecl"].isNil:
    result["moduleDecls"].add(convertModuleDecl(node["moduleDecl"]))

proc convertImport(node: JsonNode): JsonNode =
  ## Convert Java import to XLang xnkImport
  result = %* {
    "kind": "xnkImport",
    "importPath": "",
    "importAlias": nil
  }

  if node.hasKey("name"):
    result["importPath"] = node["name"]

  # Java imports can be static or wildcard
  # Store additional info as comments or metadata
  # XLang doesn't have isStatic/isAsterisk fields, so we encode in path
  if node.hasKey("isStatic") and node["isStatic"].getBool:
    result["importPath"] = %* ("static " & result["importPath"].getStr)

  if node.hasKey("isAsterisk") and node["isAsterisk"].getBool:
    result["importPath"] = %* (result["importPath"].getStr & ".*")

proc convertModuleDecl(node: JsonNode): JsonNode =
  ## Convert Java module declaration (Java 9+) to XLang xnkModule
  result = %* {
    "kind": "xnkModule",
    "moduleName": "",
    "moduleBody": []
  }

  if node.hasKey("name"):
    result["moduleName"] = node["name"]

  # Module directives (requires, exports, etc.) would need custom XLang nodes
  # For now, convert to comments
  if node.hasKey("directives") and node["directives"].kind == JArray:
    for directive in node["directives"]:
      # Note: May need to extend XLang with module directive nodes
      let comment = %* {
        "kind": "xnkComment",
        "commentText": "Module directive: " & $directive,
        "isDocComment": false
      }
      result["moduleBody"].add(comment)

proc convertClassDecl(node: JsonNode): JsonNode =
  ## Convert Java class/interface to XLang xnkClassDecl/xnkInterfaceDecl
  let kind = node["kind"].getStr

  result = %* {
    "kind": kind,  # Already xnkClassDecl or xnkInterfaceDecl
    "typeNameDecl": "",
    "baseTypes": [],
    "members": []
  }

  # Map "name" → "typeNameDecl"
  if node.hasKey("name"):
    result["typeNameDecl"] = node["name"]

  # Base types already in correct format
  if node.hasKey("baseTypes"):
    result["baseTypes"] = node["baseTypes"]

  # Convert members
  if node.hasKey("members") and node["members"].kind == JArray:
    for member in node["members"]:
      result["members"].add(convertClassMember(member))

  # Handle type parameters (Java generics)
  if node.hasKey("typeParameters") and node["typeParameters"].kind == JArray:
    # Store as metadata - may need custom XLang node
    # For now, convert to generic parameters
    for typeParam in node["typeParameters"]:
      let genericParam = convertTypeParameter(typeParam)
      if not genericParam.isNil:
        # Add to members as a special marker
        # Note: This might need a better representation in XLang
        result["members"].insert(genericParam, 0)

  # Convert annotations to decorators
  if node.hasKey("decorators"):
    # Annotations already converted to decorators by Java parser
    pass

  # Modifiers (public, private, static, final, etc.)
  if node.hasKey("modifiers"):
    # Store as pragmas or comments
    # Note: XLang may need visibility/modifier fields
    pass

proc convertEnumDecl(node: JsonNode): JsonNode =
  ## Convert Java enum to XLang xnkEnumDecl
  result = %* {
    "kind": "xnkEnumDecl",
    "enumName": "",
    "enumMembers": []
  }

  # Map "name" → "enumName"
  if node.hasKey("name"):
    result["enumName"] = node["name"]

  # Convert enum members
  # Java format: [{"name": "RED", "arguments": [...]}]
  # XLang format: [{"name": "RED", "value": ...}]
  if node.hasKey("enumMembers") and node["enumMembers"].kind == JArray:
    for member in node["enumMembers"]:
      let enumMember = %* {
        "name": "",
        "value": nil
      }

      if member.hasKey("name"):
        enumMember["name"] = member["name"]

      # Java enum members can have constructor arguments
      # Convert first argument as value, or create call expression
      if member.hasKey("arguments") and member["arguments"].kind == JArray:
        let args = member["arguments"]
        if args.len == 1:
          enumMember["value"] = convertNode(args[0])
        elif args.len > 1:
          # Multiple arguments - create a tuple or call expression
          enumMember["value"] = %* {
            "kind": "xnkTupleExpr",
            "elements": []
          }
          for arg in args:
            enumMember["value"]["elements"].add(convertNode(arg))

      result["enumMembers"].add(enumMember)

proc convertClassMember(node: JsonNode): JsonNode =
  ## Convert Java class member (method, field, constructor, nested class)
  if node.isNil or not node.hasKey("kind"):
    return newJNull()

  let kind = node["kind"].getStr

  case kind
  of "xnkMethodDecl":
    result = convertMethodDecl(node)
  of "xnkFieldDecl":
    result = convertFieldDecl(node)
  of "xnkConstructorDecl":
    result = convertConstructorDecl(node)
  of "xnkClassDecl", "xnkInterfaceDecl":
    # Nested class
    result = convertClassDecl(node)
  else:
    result = convertNode(node)

proc convertMethodDecl(node: JsonNode): JsonNode =
  ## Convert Java method to XLang xnkMethodDecl
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
  if node.hasKey("parameters"):
    result["params"] = convertParameters(node["parameters"])

  # Return type
  if node.hasKey("returnType"):
    result["returnType"] = convertNode(node["returnType"])

  # Body
  if node.hasKey("body") and not node["body"].isNil:
    result["body"] = convertNode(node["body"])

  # Java doesn't have async/await (uses threads/CompletableFuture)
  result["isAsync"] = false

proc convertFieldDecl(node: JsonNode): JsonNode =
  ## Convert Java field declaration
  ## Java can have multiple variables in one declaration
  result = %* {
    "kind": "xnkFieldDecl",
    "fieldName": "",
    "fieldType": %* {"kind": "xnkNamedType", "typeName": "Object"},
    "fieldInitializer": nil
  }

  # Type is common to all variables
  if node.hasKey("type"):
    result["fieldType"] = convertNode(node["type"])

  # If multiple variables, take first one
  # TODO: May need to return array of field declarations
  if node.hasKey("variables") and node["variables"].kind == JArray and node["variables"].len > 0:
    let firstVar = node["variables"][0]
    if firstVar.hasKey("name"):
      result["fieldName"] = firstVar["name"]
    if firstVar.hasKey("initializer"):
      result["fieldInitializer"] = convertNode(firstVar["initializer"])
  elif node.hasKey("name"):
    # Single field format
    result["fieldName"] = node["name"]
    if node.hasKey("initializer"):
      result["fieldInitializer"] = convertNode(node["initializer"])

proc convertConstructorDecl(node: JsonNode): JsonNode =
  ## Convert Java constructor to XLang xnkConstructorDecl
  result = %* {
    "kind": "xnkConstructorDecl",
    "constructorParams": [],
    "constructorInitializers": [],
    "constructorBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("parameters"):
    result["constructorParams"] = convertParameters(node["parameters"])

  if node.hasKey("body") and not node["body"].isNil:
    result["constructorBody"] = convertNode(node["body"])

  # Java constructors can have explicit this() or super() calls
  # These would be in constructorInitializers
  # TODO: Extract from body if needed

proc convertParameters(params: JsonNode): JsonNode =
  ## Convert parameter list
  result = newJArray()

  if params.isNil or params.kind != JArray:
    return result

  for param in params:
    let paramNode = %* {
      "kind": "xnkParameter",
      "paramName": "",
      "paramType": %* {"kind": "xnkNamedType", "typeName": "Object"},
      "defaultValue": nil
    }

    if param.hasKey("name"):
      paramNode["paramName"] = param["name"]

    if param.hasKey("type"):
      paramNode["paramType"] = convertNode(param["type"])

    # Java doesn't have default parameters (uses overloading)
    # but may have varargs
    if param.hasKey("isVarArgs") and param["isVarArgs"].getBool:
      # Mark as varargs somehow - may need XLang extension
      # For now, modify type name
      if paramNode["paramType"].hasKey("typeName"):
        paramNode["paramType"]["typeName"] = %* (paramNode["paramType"]["typeName"].getStr & "...")

    result.add(paramNode)

proc convertTypeParameter(node: JsonNode): JsonNode =
  ## Convert Java generic type parameter to XLang xnkGenericParameter
  result = %* {
    "kind": "xnkGenericParameter",
    "genericParamName": "",
    "genericParamConstraints": []
  }

  if node.hasKey("name"):
    result["genericParamName"] = node["name"]

  # Type bounds (extends clause)
  if node.hasKey("bounds") and node["bounds"].kind == JArray:
    for bound in node["bounds"]:
      result["genericParamConstraints"].add(convertNode(bound))

proc convertBlockStmt(node: JsonNode): JsonNode =
  ## Convert Java block statement to XLang xnkBlockStmt
  result = %* {
    "kind": "xnkBlockStmt",
    "blockBody": []
  }

  if node.hasKey("statements") and node["statements"].kind == JArray:
    for stmt in node["statements"]:
      result["blockBody"].add(convertNode(stmt))

proc convertIfStmt(node: JsonNode): JsonNode =
  ## Convert Java if statement to XLang xnkIfStmt
  result = %* {
    "kind": "xnkIfStmt",
    "ifCondition": %* {"kind": "xnkBoolLit", "boolValue": true},
    "ifBody": %* {"kind": "xnkBlockStmt", "blockBody": []},
    "elseBody": nil
  }

  if node.hasKey("condition"):
    result["ifCondition"] = convertNode(node["condition"])

  if node.hasKey("thenStmt"):
    result["ifBody"] = convertNode(node["thenStmt"])
  elif node.hasKey("body"):
    result["ifBody"] = convertNode(node["body"])

  if node.hasKey("elseStmt") and not node["elseStmt"].isNil:
    result["elseBody"] = convertNode(node["elseStmt"])

proc convertForStmt(node: JsonNode): JsonNode =
  ## Convert Java for loop to XLang xnkForStmt
  result = %* {
    "kind": "xnkForStmt",
    "forInit": nil,
    "forCond": nil,
    "forIncrement": nil,
    "forBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("initialization") and not node["initialization"].isNil:
    result["forInit"] = convertNode(node["initialization"])

  if node.hasKey("compare") and not node["compare"].isNil:
    result["forCond"] = convertNode(node["compare"])

  if node.hasKey("update") and not node["update"].isNil:
    result["forIncrement"] = convertNode(node["update"])

  if node.hasKey("body"):
    result["forBody"] = convertNode(node["body"])

proc convertForeachStmt(node: JsonNode): JsonNode =
  ## Convert Java enhanced for (foreach) to XLang xnkForeachStmt
  result = %* {
    "kind": "xnkForeachStmt",
    "foreachVar": %* {"kind": "xnkIdentifier", "identName": "item"},
    "foreachIter": %* {"kind": "xnkIdentifier", "identName": "collection"},
    "foreachBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("variable"):
    result["foreachVar"] = convertNode(node["variable"])

  if node.hasKey("iterable"):
    result["foreachIter"] = convertNode(node["iterable"])

  if node.hasKey("body"):
    result["foreachBody"] = convertNode(node["body"])

proc convertWhileStmt(node: JsonNode): JsonNode =
  ## Convert Java while loop to XLang xnkWhileStmt
  result = %* {
    "kind": "xnkWhileStmt",
    "whileCondition": %* {"kind": "xnkBoolLit", "boolValue": true},
    "whileBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("condition"):
    result["whileCondition"] = convertNode(node["condition"])

  if node.hasKey("body"):
    result["whileBody"] = convertNode(node["body"])

proc convertDoWhileStmt(node: JsonNode): JsonNode =
  ## Convert Java do-while loop to XLang xnkDoWhileStmt
  result = %* {
    "kind": "xnkDoWhileStmt",
    "whileCondition": %* {"kind": "xnkBoolLit", "boolValue": true},
    "whileBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("condition"):
    result["whileCondition"] = convertNode(node["condition"])

  if node.hasKey("body"):
    result["whileBody"] = convertNode(node["body"])

proc convertSwitchStmt(node: JsonNode): JsonNode =
  ## Convert Java switch statement to XLang xnkSwitchStmt
  result = %* {
    "kind": "xnkSwitchStmt",
    "switchExpr": %* {"kind": "xnkIdentifier", "identName": ""},
    "switchCases": []
  }

  if node.hasKey("selector"):
    result["switchExpr"] = convertNode(node["selector"])

  if node.hasKey("entries") and node["entries"].kind == JArray:
    for entry in node["entries"]:
      if entry.hasKey("kind") and entry["kind"].getStr == "SwitchEntry":
        let caseNode = convertSwitchEntry(entry)
        if not caseNode.isNil:
          result["switchCases"].add(caseNode)

proc convertSwitchEntry(node: JsonNode): JsonNode =
  ## Convert Java switch entry to XLang xnkCaseClause or xnkDefaultClause
  # Check if default case
  if node.hasKey("labels") and node["labels"].kind == JArray and node["labels"].len == 0:
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
      "caseFallthrough": false
    }

    if node.hasKey("labels"):
      for label in node["labels"]:
        result["caseValues"].add(convertNode(label))

    if node.hasKey("statements"):
      var blockBody = newJArray()
      var hasFallthrough = true
      for stmt in node["statements"]:
        let converted = convertNode(stmt)
        blockBody.add(converted)
        # Check for break statement
        if converted.hasKey("kind") and converted["kind"].getStr == "xnkBreakStmt":
          hasFallthrough = false
      result["caseBody"] = %* {"kind": "xnkBlockStmt", "blockBody": blockBody}
      result["caseFallthrough"] = %hasFallthrough

proc convertTryStmt(node: JsonNode): JsonNode =
  ## Convert Java try-catch-finally to XLang xnkTryStmt
  result = %* {
    "kind": "xnkTryStmt",
    "tryBody": %* {"kind": "xnkBlockStmt", "blockBody": []},
    "catchClauses": [],
    "finallyClause": nil
  }

  if node.hasKey("tryBlock"):
    result["tryBody"] = convertNode(node["tryBlock"])

  if node.hasKey("catchClauses") and node["catchClauses"].kind == JArray:
    for catchClause in node["catchClauses"]:
      result["catchClauses"].add(convertCatchClause(catchClause))

  if node.hasKey("finallyBlock") and not node["finallyBlock"].isNil:
    result["finallyClause"] = %* {
      "kind": "xnkFinallyStmt",
      "finallyBody": convertNode(node["finallyBlock"])
    }

  # Java 7+ try-with-resources
  if node.hasKey("resources") and node["resources"].kind == JArray and node["resources"].len > 0:
    # Convert to using statement or add to body
    # May need custom XLang node for try-with-resources
    # For now, add as comment
    let comment = %* {
      "kind": "xnkComment",
      "commentText": "Try-with-resources: " & $node["resources"],
      "isDocComment": false
    }
    if result["tryBody"]["blockBody"].kind == JArray:
      result["tryBody"]["blockBody"].insert(comment, 0)

proc convertCatchClause(node: JsonNode): JsonNode =
  ## Convert Java catch clause to XLang xnkCatchStmt
  result = %* {
    "kind": "xnkCatchStmt",
    "catchType": nil,
    "catchVar": nil,
    "catchBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("parameter"):
    let param = node["parameter"]
    if param.hasKey("type"):
      result["catchType"] = convertNode(param["type"])
    if param.hasKey("name"):
      result["catchVar"] = param["name"]

  if node.hasKey("body"):
    result["catchBody"] = convertNode(node["body"])

proc convertReturnStmt(node: JsonNode): JsonNode =
  ## Convert Java return statement to XLang xnkReturnStmt
  result = %* {
    "kind": "xnkReturnStmt",
    "returnExpr": nil
  }

  if node.hasKey("expression") and not node["expression"].isNil:
    result["returnExpr"] = convertNode(node["expression"])

proc convertThrowStmt(node: JsonNode): JsonNode =
  ## Convert Java throw statement to XLang xnkThrowStmt
  result = %* {
    "kind": "xnkThrowStmt",
    "throwExpr": %* {"kind": "xnkIdentifier", "identName": "Exception"}
  }

  if node.hasKey("expression"):
    result["throwExpr"] = convertNode(node["expression"])

proc convertBreakStmt(node: JsonNode): JsonNode =
  ## Convert Java break statement to XLang xnkBreakStmt
  result = %* {
    "kind": "xnkBreakStmt",
    "label": nil
  }

  if node.hasKey("label") and not node["label"].isNil:
    result["label"] = node["label"]

proc convertContinueStmt(node: JsonNode): JsonNode =
  ## Convert Java continue statement to XLang xnkContinueStmt
  result = %* {
    "kind": "xnkContinueStmt",
    "label": nil
  }

  if node.hasKey("label") and not node["label"].isNil:
    result["label"] = node["label"]

proc convertAssertStmt(node: JsonNode): JsonNode =
  ## Convert Java assert statement to XLang xnkAssertStmt
  result = %* {
    "kind": "xnkAssertStmt",
    "assertCond": %* {"kind": "xnkBoolLit", "boolValue": true},
    "assertMsg": nil
  }

  if node.hasKey("check"):
    result["assertCond"] = convertNode(node["check"])

  if node.hasKey("message") and not node["message"].isNil:
    result["assertMsg"] = convertNode(node["message"])

proc convertBinaryExpr(node: JsonNode): JsonNode =
  ## Convert Java binary expression to XLang xnkBinaryExpr
  result = %* {
    "kind": "xnkBinaryExpr",
    "binaryLeft": %* {"kind": "xnkNoneLit"},
    "binaryOp": "",
    "binaryRight": %* {"kind": "xnkNoneLit"}
  }

  if node.hasKey("left"):
    result["binaryLeft"] = convertNode(node["left"])

  if node.hasKey("operator"):
    result["binaryOp"] = node["operator"]

  if node.hasKey("right"):
    result["binaryRight"] = convertNode(node["right"])

proc convertUnaryExpr(node: JsonNode): JsonNode =
  ## Convert Java unary expression to XLang xnkUnaryExpr
  result = %* {
    "kind": "xnkUnaryExpr",
    "unaryOp": "",
    "unaryOperand": %* {"kind": "xnkNoneLit"}
  }

  if node.hasKey("operator"):
    result["unaryOp"] = node["operator"]

  if node.hasKey("expression"):
    result["unaryOperand"] = convertNode(node["expression"])

proc convertCallExpr(node: JsonNode): JsonNode =
  ## Convert Java method call to XLang xnkCallExpr
  result = %* {
    "kind": "xnkCallExpr",
    "callee": %* {"kind": "xnkIdentifier", "identName": ""},
    "args": []
  }

  # Java has different call types: method call, static call, constructor call
  if node.hasKey("name"):
    result["callee"] = %* {
      "kind": "xnkIdentifier",
      "identName": node["name"]
    }
  elif node.hasKey("scope"):
    # Scoped call like obj.method() or Class.staticMethod()
    result["callee"] = %* {
      "kind": "xnkMemberAccessExpr",
      "memberExpr": convertNode(node["scope"]),
      "memberName": if node.hasKey("name"): node["name"].getStr else: ""
    }

  if node.hasKey("arguments") and node["arguments"].kind == JArray:
    for arg in node["arguments"]:
      result["args"].add(convertNode(arg))

proc convertMemberAccessExpr(node: JsonNode): JsonNode =
  ## Convert Java field access to XLang xnkMemberAccessExpr
  result = %* {
    "kind": "xnkMemberAccessExpr",
    "memberExpr": %* {"kind": "xnkIdentifier", "identName": ""},
    "memberName": ""
  }

  if node.hasKey("scope"):
    result["memberExpr"] = convertNode(node["scope"])

  if node.hasKey("name"):
    result["memberName"] = node["name"]

proc convertArrayAccessExpr(node: JsonNode): JsonNode =
  ## Convert Java array access to XLang xnkIndexExpr
  result = %* {
    "kind": "xnkIndexExpr",
    "indexExpr": %* {"kind": "xnkIdentifier", "identName": ""},
    "indexArgs": []
  }

  if node.hasKey("name"):
    result["indexExpr"] = convertNode(node["name"])

  if node.hasKey("index"):
    result["indexArgs"].add(convertNode(node["index"]))

proc convertCastExpr(node: JsonNode): JsonNode =
  ## Convert Java cast expression
  ## Note: XLang may need explicit cast node
  result = %* {
    "kind": "xnkCallExpr",
    "callee": %* {"kind": "xnkIdentifier", "identName": "cast"},
    "args": []
  }

  if node.hasKey("type"):
    result["args"].add(convertNode(node["type"]))

  if node.hasKey("expression"):
    result["args"].add(convertNode(node["expression"]))

proc convertInstanceOfExpr(node: JsonNode): JsonNode =
  ## Convert Java instanceof to XLang binary expression
  result = %* {
    "kind": "xnkBinaryExpr",
    "binaryLeft": %* {"kind": "xnkNoneLit"},
    "binaryOp": "is",
    "binaryRight": %* {"kind": "xnkNamedType", "typeName": ""}
  }

  if node.hasKey("expression"):
    result["binaryLeft"] = convertNode(node["expression"])

  if node.hasKey("type"):
    result["binaryRight"] = convertNode(node["type"])

proc convertTernaryExpr(node: JsonNode): JsonNode =
  ## Convert Java ternary operator to XLang xnkTernaryExpr
  result = %* {
    "kind": "xnkTernaryExpr",
    "ternaryCondition": %* {"kind": "xnkBoolLit", "boolValue": true},
    "ternaryThen": %* {"kind": "xnkNoneLit"},
    "ternaryElse": %* {"kind": "xnkNoneLit"}
  }

  if node.hasKey("condition"):
    result["ternaryCondition"] = convertNode(node["condition"])

  if node.hasKey("thenExpr"):
    result["ternaryThen"] = convertNode(node["thenExpr"])

  if node.hasKey("elseExpr"):
    result["ternaryElse"] = convertNode(node["elseExpr"])

proc convertLambdaExpr(node: JsonNode): JsonNode =
  ## Convert Java lambda expression to XLang xnkLambdaExpr
  result = %* {
    "kind": "xnkLambdaExpr",
    "lambdaParams": [],
    "lambdaBody": %* {"kind": "xnkBlockStmt", "blockBody": []}
  }

  if node.hasKey("parameters") and node["parameters"].kind == JArray:
    for param in node["parameters"]:
      result["lambdaParams"].add(convertNode(param))

  if node.hasKey("body"):
    result["lambdaBody"] = convertNode(node["body"])

proc convertNewExpr(node: JsonNode): JsonNode =
  ## Convert Java new expression (object creation) to XLang call expression
  result = %* {
    "kind": "xnkCallExpr",
    "callee": %* {"kind": "xnkIdentifier", "identName": "new"},
    "args": []
  }

  if node.hasKey("type"):
    let typeNode = convertNode(node["type"])
    result["callee"] = typeNode

  if node.hasKey("arguments") and node["arguments"].kind == JArray:
    for arg in node["arguments"]:
      result["args"].add(convertNode(arg))

  # Anonymous class body
  if node.hasKey("anonymousClassBody") and not node["anonymousClassBody"].isNil:
    # May need special XLang node for anonymous classes
    # For now, ignore or add as comment
    pass

proc convertArrayInitExpr(node: JsonNode): JsonNode =
  ## Convert Java array initializer to XLang xnkListExpr
  result = %* {
    "kind": "xnkListExpr",
    "elements": []
  }

  if node.hasKey("values") and node["values"].kind == JArray:
    for val in node["values"]:
      result["elements"].add(convertNode(val))

proc convertIdentifier(node: JsonNode): JsonNode =
  ## Convert Java identifier/name to XLang xnkIdentifier
  result = %* {
    "kind": "xnkIdentifier",
    "identName": ""
  }

  if node.hasKey("name"):
    result["identName"] = node["name"]
  elif node.hasKey("identifier"):
    result["identName"] = node["identifier"]

proc convertLiteral(node: JsonNode, xlangKind: string): JsonNode =
  ## Convert Java literal to XLang literal
  case xlangKind
  of "xnkIntLit", "xnkFloatLit", "xnkStringLit", "xnkCharLit":
    result = %* {
      "kind": xlangKind,
      "literalValue": ""
    }
    if node.hasKey("value"):
      result["literalValue"] = node["value"]
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
  ## Convert Java type to XLang type node
  if node.isNil or node.kind == JNull:
    return newJNull()

  if not node.hasKey("kind"):
    # Simple type name
    if node.kind == JString:
      return %* {
        "kind": "xnkNamedType",
        "typeName": node.getStr
      }
    return node

  let kind = node["kind"].getStr

  case kind
  of "PrimitiveType", "NamedType":
    result = %* {
      "kind": "xnkNamedType",
      "typeName": if node.hasKey("name"): node["name"] else: "Object"
    }

  of "ArrayType":
    result = %* {
      "kind": "xnkArrayType",
      "elementType": %* {"kind": "xnkNamedType", "typeName": "Object"},
      "arraySize": nil
    }
    if node.hasKey("componentType"):
      result["elementType"] = convertType(node["componentType"])

  of "GenericType", "ClassOrInterfaceType":
    if node.hasKey("typeArguments") and node["typeArguments"].kind == JArray and node["typeArguments"].len > 0:
      result = %* {
        "kind": "xnkGenericType",
        "genericTypeName": if node.hasKey("name"): node["name"].getStr else: "",
        "genericArgs": []
      }
      for arg in node["typeArguments"]:
        result["genericArgs"].add(convertType(arg))
    else:
      result = %* {
        "kind": "xnkNamedType",
        "typeName": if node.hasKey("name"): node["name"] else: "Object"
      }

  of "VoidType":
    result = %* {
      "kind": "xnkNamedType",
      "typeName": "void"
    }

  of "WildcardType":
    # Java wildcard <?>, <? extends T>, <? super T>
    # May need special XLang representation
    result = %* {
      "kind": "xnkNamedType",
      "typeName": "?"
    }
    if node.hasKey("extendsBound"):
      result["typeName"] = %* ("? extends " & $convertType(node["extendsBound"]))
    elif node.hasKey("superBound"):
      result["typeName"] = %* ("? super " & $convertType(node["superBound"]))

  else:
    result = node

proc convertNode(node: JsonNode): JsonNode =
  if node.isNil or node.kind == JNull:
    return newJNull()

  # Handle simple types that don't have "kind"
  if not node.hasKey("kind"):
    if node.kind == JString:
      return convertIdentifier(%* {"name": node})
    return node

  let kind = node["kind"].getStr

  case kind
  of "xnkFile":
    result = convertFile(node)
  of "xnkImport":
    result = convertImport(node)
  of "xnkNamespace":
    # Already has correct format, just verify field names
    result = node
    if node.hasKey("name") and not node.hasKey("namespaceName"):
      result["namespaceName"] = node["name"]
      result.delete("name")
  of "xnkModule":
    result = convertModuleDecl(node)
  of "xnkClassDecl", "xnkInterfaceDecl":
    result = convertClassDecl(node)
  of "xnkEnumDecl":
    result = convertEnumDecl(node)
  of "xnkMethodDecl":
    result = convertMethodDecl(node)
  of "xnkFieldDecl":
    result = convertFieldDecl(node)
  of "xnkConstructorDecl":
    result = convertConstructorDecl(node)
  of "xnkParameter":
    # Already correct format
    result = node
    if node.hasKey("name") and not node.hasKey("paramName"):
      result["paramName"] = node["name"]
      result.delete("name")
  of "xnkBlockStmt", "BlockStmt":
    result = convertBlockStmt(node)
  of "xnkIfStmt", "IfStmt":
    result = convertIfStmt(node)
  of "xnkForStmt", "ForStmt":
    result = convertForStmt(node)
  of "xnkForeachStmt", "ForeachStmt":
    result = convertForeachStmt(node)
  of "xnkWhileStmt", "WhileStmt":
    result = convertWhileStmt(node)
  of "xnkDoWhileStmt", "DoStmt":
    result = convertDoWhileStmt(node)
  of "xnkSwitchStmt", "SwitchStmt":
    result = convertSwitchStmt(node)
  of "xnkTryStmt", "TryStmt":
    result = convertTryStmt(node)
  of "xnkReturnStmt", "ReturnStmt":
    result = convertReturnStmt(node)
  of "xnkThrowStmt", "ThrowStmt":
    result = convertThrowStmt(node)
  of "xnkBreakStmt", "BreakStmt":
    result = convertBreakStmt(node)
  of "xnkContinueStmt", "ContinueStmt":
    result = convertContinueStmt(node)
  of "xnkAssertStmt", "AssertStmt":
    result = convertAssertStmt(node)
  of "xnkBinaryExpr", "BinaryExpr":
    result = convertBinaryExpr(node)
  of "xnkUnaryExpr", "UnaryExpr":
    result = convertUnaryExpr(node)
  of "xnkTernaryExpr", "ConditionalExpr":
    result = convertTernaryExpr(node)
  of "xnkCallExpr", "MethodCallExpr":
    result = convertCallExpr(node)
  of "xnkMemberAccessExpr", "FieldAccessExpr":
    result = convertMemberAccessExpr(node)
  of "xnkIndexExpr", "ArrayAccessExpr":
    result = convertArrayAccessExpr(node)
  of "CastExpr":
    result = convertCastExpr(node)
  of "InstanceOfExpr":
    result = convertInstanceOfExpr(node)
  of "xnkLambdaExpr", "LambdaExpr":
    result = convertLambdaExpr(node)
  of "ObjectCreationExpr", "NewExpr":
    result = convertNewExpr(node)
  of "ArrayInitializerExpr":
    result = convertArrayInitExpr(node)
  of "xnkIdentifier", "NameExpr", "SimpleName":
    result = convertIdentifier(node)
  of "xnkIntLit", "IntegerLiteralExpr":
    result = convertLiteral(node, "xnkIntLit")
  of "xnkFloatLit", "DoubleLiteralExpr":
    result = convertLiteral(node, "xnkFloatLit")
  of "xnkStringLit", "StringLiteralExpr":
    result = convertLiteral(node, "xnkStringLit")
  of "xnkCharLit", "CharLiteralExpr":
    result = convertLiteral(node, "xnkCharLit")
  of "xnkBoolLit", "BooleanLiteralExpr":
    result = convertLiteral(node, "xnkBoolLit")
  of "xnkNoneLit", "NullLiteralExpr":
    result = convertLiteral(node, "xnkNoneLit")
  of "PrimitiveType", "ClassOrInterfaceType", "ArrayType", "VoidType", "WildcardType":
    result = convertType(node)
  else:
    echo "Warning: Unknown Java AST node kind: ", kind
    result = node

when isMainModule:
  if paramCount() < 1:
    echo "Usage: java_json_to_xlang <input.json>"
    quit(1)

  let inputFile = paramStr(1)
  let jsonContent = readFile(inputFile)
  let inputJson = parseJson(jsonContent)

  let outputJson = convertNode(inputJson)

  echo pretty(outputJson, indent=2)
