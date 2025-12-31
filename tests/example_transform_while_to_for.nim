import macros
import nimtoXlang
import xlangtonim_complete
import xlangtypes
import options

## Example Transformation: While Loop → For Loop
## Demonstrates how to create a simple transformation pass

proc isSimpleCounter(node: XLangNode): bool =
  ## Check if a while loop is a simple counter pattern
  ## Pattern: while i < N: body; inc i
  if node.kind != xnkWhileStmt:
    return false

  # Check condition is binary comparison
  if node.whileCondition.kind != xnkBinaryExpr:
    return false

  let condition = node.whileCondition
  if condition.binaryOp notin ["<", "<=", "!=", ">", ">="]:
    return false

  # Check body has increment at end
  if node.whileBody.kind != xnkBlockStmt:
    return false

  if node.whileBody.blockBody.len == 0:
    return false

  # Very simplified check - real version would be more thorough
  return true

proc transformWhileToFor(node: XLangNode): XLangNode =
  ## Transform simple counter while loops to for loops
  if not isSimpleCounter(node):
    return node

  # Extract the counter variable name
  let condition = node.whileCondition
  if condition.binaryLeft.kind != xnkIdentifier:
    return node

  let counterName = condition.binaryLeft.identName
  let limit = condition.binaryRight

  # Create for loop: for counter in 0..<limit
  result = XLangNode(
    kind: xnkForeachStmt,
    foreachVar: XLangNode(kind: xnkIdentifier, identName: counterName),
    foreachIter: XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: "..<",
      binaryLeft: XLangNode(kind: xnkIntLit, literalValue: "0"),
      binaryRight: limit
    ),
    foreachBody: node.whileBody
  )

proc transformXLang(node: XLangNode): XLangNode =
  ## Recursively apply transformations to XLang AST
  case node.kind
  of xnkWhileStmt:
    result = transformWhileToFor(node)
    # Recursively transform the body
    result.whileBody = transformXLang(result.whileBody)

  of xnkBlockStmt:
    result = node
    result.blockBody = @[]
    for stmt in node.blockBody:
      result.blockBody.add(transformXLang(stmt))

  of xnkIfStmt:
    result = node
    result.ifCondition = transformXLang(result.ifCondition)
    result.ifBody = transformXLang(result.ifBody)
    if result.elseBody.isSome:
      result.elseBody = some(transformXLang(result.elseBody.get))

  of xnkFuncDecl, xnkMethodDecl:
    result = node
    result.body = transformXLang(result.body)

  else:
    # Most nodes pass through unchanged
    result = node

proc testTransformation() =
  echo "=== Transformation Example: While → For ==="
  echo ""

  let nimCode = """
proc countToTen() =
  var i = 0
  while i < 10:
    echo i
    inc i
"""

  echo "Original Nim code:"
  echo nimCode
  echo ""

  # Step 1: Parse Nim → XLang
  let nimAst = parseStmt(nimCode)
  let xlangAst = convertNimToXLang(nimAst)
  echo "Step 1: Parsed to XLang ✓"

  # Step 2: Transform XLang
  let transformedXLang = transformXLang(xlangAst)
  echo "Step 2: Applied transformation ✓"

  # Step 3: Convert back to Nim
  let nimAst2 = convertXLangToNim(transformedXLang)
  echo "Step 3: Converted back to Nim ✓"
  echo ""

  echo "Transformed Nim code:"
  echo nimAst2.repr
  echo ""
  echo "Note: The while loop should be transformed to a for loop"

when isMainModule:
  testTransformation()
