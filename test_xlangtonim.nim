import xlangtonim_complete
import xlangtypes
import options

# Test basic conversions
proc testBasicTypes() =
  echo "Testing basic type conversions..."

  # Test named type
  let namedType = XLangNode(kind: xnkNamedType, typeName: "int")
  let nimType = convertXLangToNim(namedType)
  echo "Named type: ", nimType.repr

  # Test identifier
  let ident = XLangNode(kind: xnkIdentifier, identName: "myVar")
  let nimIdent = convertXLangToNim(ident)
  echo "Identifier: ", nimIdent.repr

  # Test int literal
  let intLit = XLangNode(kind: xnkIntLit, literalValue: "42")
  let nimInt = convertXLangToNim(intLit)
  echo "Int literal: ", nimInt.repr

  # Test bool literal
  let boolLit = XLangNode(kind: xnkBoolLit, boolValue: true)
  let nimBool = convertXLangToNim(boolLit)
  echo "Bool literal: ", nimBool.repr

proc testSimpleFunction() =
  echo "\nTesting function conversion..."

  # Create a simple function: proc hello() = echo "Hello"
  let echoCall = XLangNode(
    kind: xnkCallExpr,
    callee: XLangNode(kind: xnkIdentifier, identName: "echo"),
    args: @[XLangNode(kind: xnkStringLit, literalValue: "Hello")]
  )

  let funcBody = XLangNode(
    kind: xnkBlockStmt,
    blockBody: @[echoCall]
  )

  let funcDecl = XLangNode(
    kind: xnkFuncDecl,
    funcName: "hello",
    params: @[],
    returnType: none(XLangNode),
    body: funcBody,
    isAsync: false
  )

  let nimFunc = convertXLangToNim(funcDecl)
  echo "Function: ", nimFunc.repr

proc testVarDeclaration() =
  echo "\nTesting variable declaration..."

  let varDecl = XLangNode(
    kind: xnkVarDecl,
    declName: "x",
    declType: some(XLangNode(kind: xnkNamedType, typeName: "int")),
    initializer: some(XLangNode(kind: xnkIntLit, literalValue: "10"))
  )

  let nimVar = convertXLangToNim(varDecl)
  echo "Var decl: ", nimVar.repr

proc testIfStatement() =
  echo "\nTesting if statement..."

  let condition = XLangNode(
    kind: xnkBinaryExpr,
    binaryLeft: XLangNode(kind: xnkIdentifier, identName: "x"),
    binaryOp: ">",
    binaryRight: XLangNode(kind: xnkIntLit, literalValue: "5")
  )

  let thenBody = XLangNode(
    kind: xnkBlockStmt,
    blockBody: @[
      XLangNode(
        kind: xnkCallExpr,
        callee: XLangNode(kind: xnkIdentifier, identName: "echo"),
        args: @[XLangNode(kind: xnkStringLit, literalValue: "x is greater than 5")]
      )
    ]
  )

  let ifStmt = XLangNode(
    kind: xnkIfStmt,
    ifCondition: condition,
    ifBody: thenBody,
    elseBody: none(XLangNode)
  )

  let nimIf = convertXLangToNim(ifStmt)
  echo "If statement: ", nimIf.repr

proc testEnum() =
  echo "\nTesting enum declaration..."

  let enumDecl = XLangNode(
    kind: xnkEnumDecl,
    enumName: "Color",
    enumMembers: @[
      (name: "Red", value: none(XLangNode)),
      (name: "Green", value: none(XLangNode)),
      (name: "Blue", value: none(XLangNode))
    ]
  )

  let nimEnum = convertXLangToNim(enumDecl)
  echo "Enum: ", nimEnum.repr

when isMainModule:
  echo "=== XLang to Nim Conversion Tests ===\n"

  testBasicTypes()
  testSimpleFunction()
  testVarDeclaration()
  testIfStatement()
  testEnum()

  echo "\n=== Tests Complete ==="
