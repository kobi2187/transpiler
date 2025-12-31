import unittest
import src/astprinter  # This re-exports my_nim_node

suite "AST Printer Tests":
  test "Simple infix expression":
    let expr1 = newInfixCall("+", newIdentNode("x"), newIntLitNode(42))
    check toNimCode(expr1) == "x + 42"

  test "Variable declaration":
    let varDecl = newVarStmt(
      newIdentNode("count"),
      newIdentNode("int"),
      newIntLitNode(0)
    )
    check toNimCode(varDecl) == "var count: int = 0"

  test "Function call":
    let callExpr = newCall("println",
      newStrLitNode("Hello, World!"),
      newIntLitNode(123)
    )
    check toNimCode(callExpr) == "println(\"Hello, World!\", 123)"

  test "If statement":
    let ifStmt = newIfStmt(
      newElifBranch(
        newInfixCall(">", newIdentNode("x"), newIntLitNode(0)),
        newStmtList()
      )
    )
    ifStmt[0][1].add(newCall("echo", newStrLitNode("positive")))
    let expected = """if x > 0:
  echo("positive")"""
    check toNimCode(ifStmt) == expected

  test "Proc definition":
    let procDef = newMyNimNode(nnkProcDef)
    # Add children: name, patterns, generics, params, pragma, reserved, body
    procDef.sons.add(newIdentNode("greet"))  # 0: name
    procDef.sons.add(newEmptyNode())         # 1: patterns
    procDef.sons.add(newEmptyNode())         # 2: generics
    # 3: formal params
    let params = newMyNimNode(nnkFormalParams)
    params.sons.add(newEmptyNode())  # return type
    let param1 = newIdentDefs(
      newIdentNode("name"),
      newIdentNode("string"),
      newEmptyNode()
    )
    params.sons.add(param1)
    procDef.sons.add(params)
    procDef.sons.add(newEmptyNode())         # 4: pragma
    procDef.sons.add(newEmptyNode())         # 5: reserved
    # 6: body
    let body = newStmtList()
    body.add(newCall("echo", newInfixCall("&", newStrLitNode("Hello, "), newIdentNode("name"))))
    procDef.sons.add(body)
    let expected = """proc greet(name: string) =
  echo("Hello, " & name)"""
    check toNimCode(procDef) == expected

  test "Type definition":
    let typeSec = newMyNimNode(nnkTypeSection)
    let typeDef = newMyNimNode(nnkTypeDef)
    typeDef.sons.add(newIdentNode("Person"))  # name
    typeDef.sons.add(newEmptyNode())          # generic params
    let objTy = newMyNimNode(nnkObjectTy)
    objTy.sons.add(newEmptyNode())            # inheritance
    objTy.sons.add(newEmptyNode())            # pragmas
    let recList = newMyNimNode(nnkRecList)
    recList.sons.add(newIdentDefs(newIdentNode("name"), newIdentNode("string"), newEmptyNode()))
    recList.sons.add(newIdentDefs(newIdentNode("age"), newIdentNode("int"), newEmptyNode()))
    objTy.sons.add(recList)
    typeDef.sons.add(objTy)
    typeSec.sons.add(typeDef)
    let expected = """type
  Person = object
    name: string
    age: int
"""
    check toNimCode(typeSec) == expected

  test "For loop":
    let forLoop = newForStmt(
      newIdentNode("i"),
      newInfixCall("..", newIntLitNode(1), newIntLitNode(10)),
      newStmtList()
    )
    forLoop[2].add(newCall("echo", newIdentNode("i")))
    let expected = """for i in 1 .. 10:
  echo(i)"""
    check toNimCode(forLoop) == expected

  test "Case statement":
    let caseStmt = newMyNimNode(nnkCaseStmt)
    caseStmt.sons.add(newIdentNode("x"))
    let ofBranch1 = newMyNimNode(nnkOfBranch)
    ofBranch1.sons.add(newIntLitNode(1))
    let ofBody1 = newStmtList()
    ofBody1.add(newCall("echo", newStrLitNode("one")))
    ofBranch1.sons.add(ofBody1)
    caseStmt.sons.add(ofBranch1)
    let elseNode = newElse(newStmtList())
    elseNode[0].add(newCall("echo", newStrLitNode("other")))
    caseStmt.sons.add(elseNode)
    let expected = """case x
of 1:
  echo("one")
else:
  echo("other")"""
    check toNimCode(caseStmt) == expected

  test "Array literal":
    let arrLit = newBracket(
      newIntLitNode(1),
      newIntLitNode(2),
      newIntLitNode(3),
      newIntLitNode(4),
      newIntLitNode(5)
    )
    check toNimCode(arrLit) == "[1, 2, 3, 4, 5]"

  test "Tuple constructor":
    let tupleLit = newTupleConstr(
      newStrLitNode("Alice"),
      newIntLitNode(30)
    )
    check toNimCode(tupleLit) == """("Alice", 30)"""

  test "Dot expression":
    let dotExpr = newDotExpr(
      newIdentNode("person"),
      newIdentNode("name")
    )
    check toNimCode(dotExpr) == "person.name"

  test "Complete program":
    let program = newStmtList()
    program.add(newVarStmt(newIdentNode("x"), newIdentNode("int"), newIntLitNode(10)))
    program.add(newVarStmt(newIdentNode("y"), newIdentNode("int"), newIntLitNode(20)))
    program.add(newLetStmt(newIdentNode("sum"), newEmptyNode(),
      newInfixCall("+", newIdentNode("x"), newIdentNode("y"))))
    program.add(newCall("echo", newIdentNode("sum")))
    let expected = """var x: int = 10
var y: int = 20
let sum = x + y
echo(sum)"""
    check toNimCode(program) == expected

  test "While loop":
    let whileStmt = newWhileStmt(
      newInfixCall("<", newIdentNode("i"), newIntLitNode(10)),
      newStmtList()
    )
    whileStmt[1].add(newCall("inc", newIdentNode("i")))
    let expected = """while i < 10:
  inc(i)"""
    check toNimCode(whileStmt) == expected

  test "Assignment":
    let asgn = newAssignment(newIdentNode("x"), newIntLitNode(100))
    check toNimCode(asgn) == "x = 100"

  test "Prefix operator":
    let prefix = newPrefixCall("-", newIdentNode("x"))
    check toNimCode(prefix) == "-x"

  test "Multiple infix operations":
    let expr = newInfixCall("*",
      newInfixCall("+", newIdentNode("a"), newIdentNode("b")),
      newIdentNode("c")
    )
    check toNimCode(expr) == "a + b * c"

  test "Bracket expression":
    let bracketExpr = newBracketExpr(
      newIdentNode("arr"),
      newIntLitNode(0)
    )
    check toNimCode(bracketExpr) == "arr[0]"

  test "Let statement without type":
    let letStmt = newLetStmt(
      newIdentNode("x"),
      newEmptyNode(),
      newIntLitNode(42)
    )
    check toNimCode(letStmt) == "let x = 42"

  test "Character literal":
    let charLit = newCharNode('A')
    check toNimCode(charLit) == "'A'"

  test "Return statement":
    let retStmt = newReturnStmt(newIdentNode("result"))
    check toNimCode(retStmt) == "return result"
