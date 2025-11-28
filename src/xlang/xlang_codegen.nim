## XLang JSON to Nim Code Generator
## Runtime transpiler that reads XLang JSON and outputs Nim source code

import json, strutils, sequtils, os

proc indent(s: string, level: int): string =
  let prefix = "  ".repeat(level)
  result = s.split('\n').mapIt(if it.len > 0: prefix & it else: it).join("\n")

proc genNode(node: JsonNode, level: int = 0): string

proc genFile(node: JsonNode, level: int): string =
  result = "# Generated from XLang\n\n"
  if node.hasKey("moduleDecls"):
    for decl in node["moduleDecls"]:
      result &= genNode(decl, level) & "\n\n"

proc genNamespace(node: JsonNode, level: int): string =
  # Nim doesn't have namespaces, just output a comment
  result = "# Namespace: " & node{"namespaceName"}.getStr("") & "\n"
  if node.hasKey("moduleDecls"):
    for decl in node["moduleDecls"]:
      result &= genNode(decl, level)
  elif node.hasKey("namespaceBody"):
    for decl in node["namespaceBody"]:
      result &= genNode(decl, level)

proc genClass(node: JsonNode, level: int): string =
  let name = node{"typeNameDecl"}.getStr("UnknownClass")
  result = "type\n"
  result &= indent(name & "* = ref object\n", level)
  if node.hasKey("members"):
    for member in node["members"]:
      result &= indent(genNode(member, level + 1), level)

proc genFunc(node: JsonNode, level: int): string =
  let name = node{"funcName"}.getStr("unknownFunc")
  result = "proc " & name & "*("

  # Parameters
  if node.hasKey("params") and node["params"].len > 0:
    var paramStrs: seq[string] = @[]
    for param in node["params"]:
      let paramName = param{"declName"}.getStr("arg")
      paramStrs.add(paramName & ": auto")
    result &= paramStrs.join(", ")

  result &= ")"

  # Return type
  if node.hasKey("returnType") and node["returnType"].kind != JNull:
    let retType = node["returnType"]
    if retType.hasKey("name"):
      let typeName = retType["name"].getStr()
      if typeName != "void":
        result &= ": " & typeName

  result &= " =\n"

  # Body
  if node.hasKey("funcBody") and node["funcBody"].kind != JNull:
    result &= indent(genNode(node["funcBody"], level + 1), level + 1)
  else:
    result &= indent("discard\n", level + 1)

proc genBlock(node: JsonNode, level: int): string =
  if node.hasKey("blockBody"):
    for stmt in node["blockBody"]:
      result &= genNode(stmt, level) & "\n"
  if result.len == 0:
    result = "discard\n"

proc genCall(node: JsonNode, level: int): string =
  var callee = ""
  if node.hasKey("callExpr") and node["callExpr"].kind != JNull:
    let callExpr = node["callExpr"]
    if callExpr.hasKey("text"):
      callee = callExpr["text"].getStr()
    elif callExpr.hasKey("identName"):
      callee = callExpr["identName"].getStr()

  result = callee & "("

  if node.hasKey("callArgs"):
    var argStrs: seq[string] = @[]
    for arg in node["callArgs"]:
      if arg.hasKey("text"):
        argStrs.add(arg["text"].getStr())
      else:
        argStrs.add(genNode(arg, 0))
    result &= argStrs.join(", ")

  result &= ")"

proc genNode(node: JsonNode, level: int = 0): string =
  if node.isNil or node.kind == JNull:
    return ""

  if not node.hasKey("kind"):
    return "# Unknown node: " & $node

  let kind = node["kind"].getStr()

  case kind
  of "xnkFile": result = genFile(node, level)
  of "xnkNamespace": result = genNamespace(node, level)
  of "xnkClassDecl", "xnkStructDecl": result = genClass(node, level)
  of "xnkFuncDecl", "xnkMethodDecl": result = genFunc(node, level)
  of "xnkBlockStmt": result = genBlock(node, level)
  of "xnkCallExpr": result = genCall(node, level)
  else:
    result = "# Unhandled: " & kind & "\n"

when isMainModule:
  if paramCount() < 1:
    echo "Usage: xlang_json_to_nim <xlang.json>"
    quit(1)

  let inputFile = paramStr(1)
  let jsonContent = readFile(inputFile)
  let xlangJson = parseJson(jsonContent)

  let nimCode = genNode(xlangJson)
  echo nimCode
