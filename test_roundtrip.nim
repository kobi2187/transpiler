import macros
import nimtoXlang
import xlangtonim_complete
import xlangtypes

## Round-trip test: Nim → XLang → Nim
## Validates that the full pipeline works correctly

proc testSimpleFunction() =
  echo "=== Test 1: Simple Function ==="

  let nimCode = """
proc hello(name: string): string =
  return "Hello, " & name
"""

  # Parse Nim code to NimNode
  let nimAst = parseStmt(nimCode)
  echo "Original Nim AST:"
  echo nimAst.repr
  echo ""

  # Convert NimNode → XLang
  let xlangAst = convertNimToXLang(nimAst)
  echo "XLang AST kind: ", xlangAst.kind
  echo ""

  # Convert XLang → NimNode
  let nimAst2 = convertXLangToNim(xlangAst)
  echo "Regenerated Nim AST:"
  echo nimAst2.repr
  echo ""

proc testVariableDeclaration() =
  echo "=== Test 2: Variable Declaration ==="

  let nimCode = """
var x = 42
"""

  let nimAst = parseStmt(nimCode)
  echo "Original: ", nimAst.repr

  let xlangAst = convertNimToXLang(nimAst)
  echo "XLang kind: ", xlangAst.kind

  let nimAst2 = convertXLangToNim(xlangAst)
  echo "Regenerated: ", nimAst2.repr
  echo ""

proc testIfStatement() =
  echo "=== Test 3: If Statement ==="

  let nimCode = """
if x > 5:
  echo "big"
else:
  echo "small"
"""

  let nimAst = parseStmt(nimCode)
  echo "Original: ", nimAst.repr

  let xlangAst = convertNimToXLang(nimAst)
  echo "XLang kind: ", xlangAst.kind

  let nimAst2 = convertXLangToNim(xlangAst)
  echo "Regenerated: ", nimAst2.repr
  echo ""

proc testForLoop() =
  echo "=== Test 4: For Loop ==="

  let nimCode = """
for i in 0..<10:
  echo i
"""

  let nimAst = parseStmt(nimCode)
  echo "Original: ", nimAst.repr

  let xlangAst = convertNimToXLang(nimAst)
  echo "XLang kind: ", xlangAst.kind

  let nimAst2 = convertXLangToNim(xlangAst)
  echo "Regenerated: ", nimAst2.repr
  echo ""

proc testTypeDeclaration() =
  echo "=== Test 5: Type Declaration ==="

  let nimCode = """
type
  Person = ref object
    name: string
    age: int
"""

  let nimAst = parseStmt(nimCode)
  echo "Original: ", nimAst.repr

  let xlangAst = convertNimToXLang(nimAst)
  echo "XLang kind: ", xlangAst.kind
  if xlangAst.kind == xnkClassDecl:
    echo "Type name: ", xlangAst.typeNameDecl
    echo "Members: ", xlangAst.members.len

  let nimAst2 = convertXLangToNim(xlangAst)
  echo "Regenerated: ", nimAst2.repr
  echo ""

proc testEnum() =
  echo "=== Test 6: Enum ==="

  let nimCode = """
type
  Color = enum
    Red, Green, Blue
"""

  let nimAst = parseStmt(nimCode)
  echo "Original: ", nimAst.repr

  let xlangAst = convertNimToXLang(nimAst)
  echo "XLang kind: ", xlangAst.kind
  if xlangAst.kind == xnkEnumDecl:
    echo "Enum name: ", xlangAst.enumName
    echo "Members: ", xlangAst.enumMembers.len

  let nimAst2 = convertXLangToNim(xlangAst)
  echo "Regenerated: ", nimAst2.repr
  echo ""

proc testBinaryExpression() =
  echo "=== Test 7: Binary Expression ==="

  let nimCode = """
let result = x + y * 2
"""

  let nimAst = parseStmt(nimCode)
  echo "Original: ", nimAst.repr

  let xlangAst = convertNimToXLang(nimAst)
  echo "XLang kind: ", xlangAst.kind

  let nimAst2 = convertXLangToNim(xlangAst)
  echo "Regenerated: ", nimAst2.repr
  echo ""

proc testWhileLoop() =
  echo "=== Test 8: While Loop ==="

  let nimCode = """
while x > 0:
  dec x
"""

  let nimAst = parseStmt(nimCode)
  echo "Original: ", nimAst.repr

  let xlangAst = convertNimToXLang(nimAst)
  echo "XLang kind: ", xlangAst.kind

  let nimAst2 = convertXLangToNim(xlangAst)
  echo "Regenerated: ", nimAst2.repr
  echo ""

proc testCaseStatement() =
  echo "=== Test 9: Case Statement ==="

  let nimCode = """
case x
of 1:
  echo "one"
of 2:
  echo "two"
else:
  echo "other"
"""

  let nimAst = parseStmt(nimCode)
  echo "Original: ", nimAst.repr

  let xlangAst = convertNimToXLang(nimAst)
  echo "XLang kind: ", xlangAst.kind

  let nimAst2 = convertXLangToNim(xlangAst)
  echo "Regenerated: ", nimAst2.repr
  echo ""

proc testTryCatch() =
  echo "=== Test 10: Try/Catch ==="

  let nimCode = """
try:
  doSomething()
except IOError:
  echo "IO error"
finally:
  cleanup()
"""

  let nimAst = parseStmt(nimCode)
  echo "Original: ", nimAst.repr

  let xlangAst = convertNimToXLang(nimAst)
  echo "XLang kind: ", xlangAst.kind

  let nimAst2 = convertXLangToNim(xlangAst)
  echo "Regenerated: ", nimAst2.repr
  echo ""

when isMainModule:
  echo "╔════════════════════════════════════════════════════════╗"
  echo "║         Nim → XLang → Nim Round-Trip Tests           ║"
  echo "╚════════════════════════════════════════════════════════╝"
  echo ""

  testSimpleFunction()
  testVariableDeclaration()
  testIfStatement()
  testForLoop()
  testTypeDeclaration()
  testEnum()
  testBinaryExpression()
  testWhileLoop()
  testCaseStatement()
  testTryCatch()

  echo "╔════════════════════════════════════════════════════════╗"
  echo "║              All Round-Trip Tests Complete            ║"
  echo "╚════════════════════════════════════════════════════════╝"
