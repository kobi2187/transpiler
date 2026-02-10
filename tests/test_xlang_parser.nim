## Test suite for xlang parser
## Tests parsing of xlang text format into XLangNode AST

import std/[unittest, options, json]
import ../src/parsers/xlang/xlang_lexer
import ../src/parsers/xlang/xlang_parser
import ../src/core/xlangtypes

suite "XLang Lexer":
  test "tokenize simple identifiers":
    let tokens = tokenize("hello world")
    check tokens[0].kind == tkIdent
    check tokens[0].value == "hello"
    check tokens[1].kind == tkIdent
    check tokens[1].value == "world"

  test "tokenize keywords":
    let tokens = tokenize("func class if while return")
    check tokens[0].kind == tkFunc
    check tokens[1].kind == tkClass
    check tokens[2].kind == tkIf
    check tokens[3].kind == tkWhile
    check tokens[4].kind == tkReturn

  test "tokenize operators":
    let tokens = tokenize("+ - * / == != < > <= >=")
    check tokens[0].kind == tkPlus
    check tokens[1].kind == tkMinus
    check tokens[2].kind == tkStar
    check tokens[3].kind == tkSlash
    check tokens[4].kind == tkEq
    check tokens[5].kind == tkNeq
    check tokens[6].kind == tkLt
    check tokens[7].kind == tkGt
    check tokens[8].kind == tkLe
    check tokens[9].kind == tkGe

  test "tokenize numbers":
    let tokens = tokenize("123 45.67 0xFF 0b1010")
    check tokens[0].kind == tkIntLit
    check tokens[0].value == "123"
    check tokens[1].kind == tkFloatLit
    check tokens[1].value == "45.67"
    check tokens[2].kind == tkIntLit
    check tokens[2].value == "0xFF"
    check tokens[3].kind == tkIntLit
    check tokens[3].value == "0b1010"

  test "tokenize strings":
    let tokens = tokenize("\"hello\" 'c'")
    check tokens[0].kind == tkStringLit
    check tokens[0].value == "hello"
    check tokens[1].kind == tkCharLit
    check tokens[1].value == "c"

  test "tokenize indentation":
    let tokens = tokenize("a\n  b\n    c\n  d\ne")
    # a, newline, indent, b, newline, indent, c, newline, dedent, d, newline, dedent, e, EOF
    var kinds: seq[TokenKind] = @[]
    for t in tokens:
      kinds.add(t.kind)
    check tkIndent in kinds
    check tkDedent in kinds

  test "tokenize compound operators":
    let tokens = tokenize("+= -= *= /= ++ -- && || ?? ?.")
    check tokens[0].kind == tkPlusEq
    check tokens[1].kind == tkMinusEq
    check tokens[2].kind == tkStarEq
    check tokens[3].kind == tkSlashEq
    check tokens[4].kind == tkPlusPlus
    check tokens[5].kind == tkMinusMinus
    # && and || map to and/or keywords if present, otherwise...
    # Actually, let's check for proper tokens

suite "XLang Parser - Expressions":
  test "parse integer literal":
    let ast = parse("module test\n| body:\n  123")
    check ast.kind == xnkFile
    check ast.moduleDecls.len >= 1

  test "parse binary expression":
    let ast = parse("module test\n| body:\n  1 + 2")
    check ast.kind == xnkFile

  test "parse function call":
    let ast = parse("module test\n| body:\n  foo(1, 2, 3)")
    check ast.kind == xnkFile

  test "parse array literal":
    let ast = parse("module test\n| body:\n  [1, 2, 3]")
    check ast.kind == xnkFile

  test "parse map literal":
    let ast = parse("module test\n| body:\n  {\"a\": 1, \"b\": 2}")
    check ast.kind == xnkFile

  test "parse member access":
    let ast = parse("module test\n| body:\n  obj.field")
    check ast.kind == xnkFile

  test "parse index expression":
    let ast = parse("module test\n| body:\n  arr[0]")
    check ast.kind == xnkFile

suite "XLang Parser - Statements":
  test "parse if statement":
    let source = """
module test
| body:
  if x > 5:
    return true
  else:
    return false
"""
    let ast = parse(source)
    check ast.kind == xnkFile
    check ast.moduleDecls.len >= 1
    let stmt = ast.moduleDecls[0]
    check stmt.kind == xnkIfStmt
    check stmt.ifCondition != nil
    check stmt.ifBody != nil
    check stmt.elseBody.isSome

  test "parse while statement":
    let source = """
module test
| body:
  while i < 10:
    i = i + 1
"""
    let ast = parse(source)
    check ast.kind == xnkFile
    let stmt = ast.moduleDecls[0]
    check stmt.kind == xnkWhileStmt

  test "parse foreach statement":
    let source = """
module test
| body:
  foreach x in items:
    print(x)
"""
    let ast = parse(source)
    check ast.kind == xnkFile
    let stmt = ast.moduleDecls[0]
    check stmt.kind == xnkForeachStmt

  test "parse try-catch-finally":
    let source = """
module test
| body:
  try:
    riskyCall()
  catch e: Exception:
    handleError(e)
  finally:
    cleanup()
"""
    let ast = parse(source)
    check ast.kind == xnkFile
    let stmt = ast.moduleDecls[0]
    check stmt.kind == xnkTryStmt
    check stmt.catchClauses.len == 1
    check stmt.finallyClause.isSome

  test "parse match statement":
    let source = """
module test
| body:
  match x
    | 1:
      echo "one"
    | 2, 3:
      echo "two or three"
    | _:
      echo "other"
"""
    let ast = parse(source)
    check ast.kind == xnkFile
    let stmt = ast.moduleDecls[0]
    check stmt.kind == xnkSwitchStmt
    check stmt.switchCases.len == 3

  test "parse variable declarations":
    let source = """
module test
| body:
  var x: int = 5
  let y = "hello"
  const PI: float = 3.14
"""
    let ast = parse(source)
    check ast.kind == xnkFile
    check ast.moduleDecls.len == 3
    check ast.moduleDecls[0].kind == xnkVarDecl
    check ast.moduleDecls[0].declName == "x"
    check ast.moduleDecls[1].kind == xnkLetDecl
    check ast.moduleDecls[2].kind == xnkConstDecl

suite "XLang Parser - Declarations":
  test "parse function declaration":
    let source = """
module test
| body:
  func add
    | params:
      a: int
      b: int
    | returns: int
    | body:
      return a + b
"""
    let ast = parse(source)
    check ast.kind == xnkFile
    check ast.moduleDecls.len >= 1
    let funcDecl = ast.moduleDecls[0]
    check funcDecl.kind == xnkFuncDecl
    check funcDecl.funcName == "add"
    check funcDecl.params.len == 2
    check funcDecl.returnType.isSome

  test "parse async function":
    let source = """
module test
| body:
  async func fetchData
    | returns: string
    | body:
      return await getData()
"""
    let ast = parse(source)
    check ast.kind == xnkFile
    let funcDecl = ast.moduleDecls[0]
    check funcDecl.kind == xnkFuncDecl
    check funcDecl.isAsync == true

  test "parse class declaration":
    let source = """
module test
| body:
  class Person
    | kind: class
    | base: BaseClass
    | members:
      name: string
      age: int
      func greet
        | returns: string
        | body:
          return "Hello"
"""
    let ast = parse(source)
    check ast.kind == xnkFile
    let classDecl = ast.moduleDecls[0]
    check classDecl.kind == xnkClassDecl
    check classDecl.typeNameDecl == "Person"
    check classDecl.members.len >= 2

  test "parse interface declaration":
    let source = """
module test
| body:
  interface Printable
    | kind: interface
    | methods:
      func print
        | returns: string
"""
    let ast = parse(source)
    check ast.kind == xnkFile
    let intfDecl = ast.moduleDecls[0]
    check intfDecl.kind == xnkInterfaceDecl
    check intfDecl.typeNameDecl == "Printable"

  test "parse enum declaration":
    let source = """
module test
| body:
  enum Color
    | values:
      Red = 0
      Green = 1
      Blue = 2
"""
    let ast = parse(source)
    check ast.kind == xnkFile
    let enumDecl = ast.moduleDecls[0]
    check enumDecl.kind == xnkEnumDecl
    check enumDecl.enumName == "Color"
    check enumDecl.enumMembers.len == 3

suite "XLang Parser - Types":
  test "parse generic types":
    let source = """
module test
| body:
  var list: List<int>
"""
    let ast = parse(source)
    check ast.kind == xnkFile
    let varDecl = ast.moduleDecls[0]
    check varDecl.kind == xnkVarDecl
    check varDecl.declType.isSome
    let typ = varDecl.declType.get
    check typ.kind == xnkGenericType
    check typ.genericTypeName == "List"

  test "parse array type":
    let source = """
module test
| body:
  var arr: array[int, 10]
"""
    let ast = parse(source)
    let varDecl = ast.moduleDecls[0]
    check varDecl.declType.isSome
    let typ = varDecl.declType.get
    check typ.kind == xnkArrayType

  test "parse map type":
    let source = """
module test
| body:
  var dict: Map<string, int>
"""
    let ast = parse(source)
    let varDecl = ast.moduleDecls[0]
    check varDecl.declType.isSome
    let typ = varDecl.declType.get
    check typ.kind == xnkMapType

  test "parse function type":
    let source = """
module test
| body:
  var callback: func(int, int) -> int
"""
    let ast = parse(source)
    let varDecl = ast.moduleDecls[0]
    check varDecl.declType.isSome
    let typ = varDecl.declType.get
    check typ.kind == xnkFuncType

suite "XLang Parser - JSON Output":
  test "basic JSON output":
    let source = """
module test
| source: nim
| body:
  var x: int = 42
"""
    let ast = parse(source)
    let jsonStr = ast.toJsonString(pretty = false)
    check jsonStr.len > 0
    let j = parseJson(jsonStr)
    check j["kind"].getStr() == "xnkFile"
    check j["fileName"].getStr() == "test"
    check j["sourceLang"].getStr() == "nim"

  test "complex JSON output":
    let source = """
module myapp
| source: csharp
| body:
  class Calculator
    | kind: class
    | members:
      func add
        | params:
          a: int
          b: int
        | returns: int
        | body:
          return a + b
"""
    let ast = parse(source)
    let jsonStr = ast.toJsonString()
    check jsonStr.len > 0
    let j = parseJson(jsonStr)
    check j["kind"].getStr() == "xnkFile"
    check j["moduleDecls"].len >= 1

suite "XLang Parser - Validation":
  test "validate correct syntax":
    let source = """
module test
| body:
  var x = 5
"""
    let (valid, errors) = validate(source)
    check valid == true
    check errors.len == 0

  test "validate with errors":
    # Missing module keyword - should fail
    let source = "x = 5"
    let (valid, errors) = validate(source)
    check valid == false
    check errors.len > 0

suite "XLang Parser - Edge Cases":
  test "empty module":
    let source = """
module empty
| body:
  pass
"""
    let ast = parse(source)
    check ast.kind == xnkFile
    check ast.fileName == "empty"

  test "nested expressions":
    let source = """
module test
| body:
  result = (a + b) * (c - d) / e
"""
    let ast = parse(source)
    check ast.kind == xnkFile

  test "method with receiver":
    let source = """
module test
| body:
  method greet
    | receiver: self: Person
    | returns: string
    | body:
      return self.name
"""
    let ast = parse(source)
    let methodDecl = ast.moduleDecls[0]
    check methodDecl.kind == xnkMethodDecl
    check methodDecl.receiver.isSome

when isMainModule:
  # Run all tests
  discard
