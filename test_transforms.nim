import macros
import xlangtypes
import src/transforms/pass_manager
import src/transforms/nim_passes
import src/transforms/for_to_while
import src/transforms/dowhile_to_while
import src/transforms/ternary_to_if
import xlangtonim_complete
import options

## Test Transformation Passes
## Validates that XLang transformations work correctly

proc testForToWhile() =
  echo "=== Test 1: C-Style For → While ==="
  echo ""

  # Create: for (i = 0; i < 10; i++) { echo i }
  let forLoop = XLangNode(
    kind: xnkForStmt,
    forInit: some(XLangNode(
      kind: xnkVarDecl,
      varName: "i",
      varValue: some(XLangNode(kind: xnkIntLit, literalValue: "0"))
    )),
    forCondition: some(XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: "<",
      binaryLeft: XLangNode(kind: xnkIdentifier, identName: "i"),
      binaryRight: XLangNode(kind: xnkIntLit, literalValue: "10")
    )),
    forUpdate: some(XLangNode(
      kind: xnkCallExpr,
      callFunc: XLangNode(kind: xnkIdentifier, identName: "inc"),
      callArgs: @[XLangNode(kind: xnkIdentifier, identName: "i")]
    )),
    forBody: XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[
        XLangNode(
          kind: xnkCallExpr,
          callFunc: XLangNode(kind: xnkIdentifier, identName: "echo"),
          callArgs: @[XLangNode(kind: xnkIdentifier, identName: "i")]
        )
      ]
    )
  )

  echo "Original XLang: for (i = 0; i < 10; i++) {...}"
  let transformed = transformForToWhile(forLoop)
  echo "Transformed to: ", transformed.kind

  # Convert to Nim AST to see the result
  let nimAst = convertXLangToNim(transformed)
  echo "Nim code:"
  echo nimAst.repr
  echo ""

proc testDoWhileToWhile() =
  echo "=== Test 2: Do-While → While ==="
  echo ""

  # Create: do { echo i; inc i } while (i < 10)
  let doWhile = XLangNode(
    kind: xnkDoWhileStmt,
    doWhileCondition: XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: "<",
      binaryLeft: XLangNode(kind: xnkIdentifier, identName: "i"),
      binaryRight: XLangNode(kind: xnkIntLit, literalValue: "10")
    ),
    doWhileBody: XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[
        XLangNode(
          kind: xnkCallExpr,
          callFunc: XLangNode(kind: xnkIdentifier, identName: "echo"),
          callArgs: @[XLangNode(kind: xnkIdentifier, identName: "i")]
        ),
        XLangNode(
          kind: xnkCallExpr,
          callFunc: XLangNode(kind: xnkIdentifier, identName: "inc"),
          callArgs: @[XLangNode(kind: xnkIdentifier, identName: "i")]
        )
      ]
    )
  )

  echo "Original XLang: do {...} while (i < 10)"
  let transformed = transformDoWhileToWhile(doWhile)
  echo "Transformed to: ", transformed.kind

  let nimAst = convertXLangToNim(transformed)
  echo "Nim code:"
  echo nimAst.repr
  echo ""

proc testTernaryToIf() =
  echo "=== Test 3: Ternary → If Expression ==="
  echo ""

  # Create: x > 5 ? "big" : "small"
  let ternary = XLangNode(
    kind: xnkTernaryExpr,
    ternaryCondition: XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: ">",
      binaryLeft: XLangNode(kind: xnkIdentifier, identName: "x"),
      binaryRight: XLangNode(kind: xnkIntLit, literalValue: "5")
    ),
    ternaryThen: XLangNode(kind: xnkStringLit, literalValue: "big"),
    ternaryElse: XLangNode(kind: xnkStringLit, literalValue: "small")
  )

  echo "Original XLang: x > 5 ? \"big\" : \"small\""
  let transformed = transformTernaryToIf(ternary)
  echo "Transformed to: ", transformed.kind

  let nimAst = convertXLangToNim(transformed)
  echo "Nim code:"
  echo nimAst.repr
  echo ""

proc testPassManager() =
  echo "=== Test 4: Pass Manager with Multiple Passes ==="
  echo ""

  # Create a pass manager for Nim
  let pm = createNimPassManager()

  echo "Registered passes:"
  for passDesc in pm.listPasses():
    echo "  ", passDesc

  let stats = pm.getStats()
  echo ""
  echo "Total passes: ", stats.total
  echo "Enabled: ", stats.enabled
  echo "Disabled: ", stats.disabled
  echo ""

  # Create AST with multiple constructs that need transformation
  # for (i = 0; i < 10; i++) { result = i > 5 ? "big" : "small" }
  let complexAst = XLangNode(
    kind: xnkForStmt,
    forInit: some(XLangNode(
      kind: xnkVarDecl,
      varName: "i",
      varValue: some(XLangNode(kind: xnkIntLit, literalValue: "0"))
    )),
    forCondition: some(XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: "<",
      binaryLeft: XLangNode(kind: xnkIdentifier, identName: "i"),
      binaryRight: XLangNode(kind: xnkIntLit, literalValue: "10")
    )),
    forUpdate: some(XLangNode(
      kind: xnkCallExpr,
      callFunc: XLangNode(kind: xnkIdentifier, identName: "inc"),
      callArgs: @[XLangNode(kind: xnkIdentifier, identName: "i")]
    )),
    forBody: XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[
        XLangNode(
          kind: xnkBinaryExpr,
          binaryOp: "=",
          binaryLeft: XLangNode(kind: xnkIdentifier, identName: "result"),
          binaryRight: XLangNode(
            kind: xnkTernaryExpr,
            ternaryCondition: XLangNode(
              kind: xnkBinaryExpr,
              binaryOp: ">",
              binaryLeft: XLangNode(kind: xnkIdentifier, identName: "i"),
              binaryRight: XLangNode(kind: xnkIntLit, literalValue: "5")
            ),
            ternaryThen: XLangNode(kind: xnkStringLit, literalValue: "big"),
            ternaryElse: XLangNode(kind: xnkStringLit, literalValue: "small")
          )
        )
      ]
    )
  )

  echo "Original: for loop with ternary expression inside"
  echo "Running all transformation passes..."

  let transformed = pm.runPasses(complexAst)
  echo "Transformation complete!"
  echo ""

  let nimAst = convertXLangToNim(transformed)
  echo "Final Nim code:"
  echo nimAst.repr
  echo ""

when isMainModule:
  echo "╔════════════════════════════════════════════════════════╗"
  echo "║           XLang Transformation Pass Tests            ║"
  echo "╚════════════════════════════════════════════════════════╝"
  echo ""

  testForToWhile()
  testDoWhileToWhile()
  testTernaryToIf()
  testPassManager()

  echo "╔════════════════════════════════════════════════════════╗"
  echo "║          All Transformation Tests Complete            ║"
  echo "╚════════════════════════════════════════════════════════╝"
