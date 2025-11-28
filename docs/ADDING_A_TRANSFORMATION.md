# Step-by-Step: Adding a Transformation

This tutorial walks through implementing a **switch with fallthrough** transformation as a complete example.

## The Problem

Go has `switch` statements with `fallthrough` keyword:
```go
switch x {
case 1:
    println("one")
    fallthrough
case 2:
    println("one or two")
default:
    println("other")
}
```

Nim's `case` doesn't support fallthrough. We need to transform this into if-elif chains.

---

## Step 1: Check if XLang Already Supports It

Look in `xlangtypes.nim`:

```nim
type
  XLangNodeKind* = enum
    # ... many other kinds ...
    xnkSwitchStmt        # ✓ Already exists!
    xnkCaseClause        # ✓ Already exists!
    xnkDefaultClause     # ✓ Already exists!
```

Check the variant object fields:

```nim
XLangNode* = object
  case kind*: XLangNodeKind
  # ...
  of xnkSwitchStmt:
    switchExpr*: XLangNode
    switchCases*: seq[XLangNode]
  of xnkCaseClause:
    caseValues*: seq[XLangNode]
    caseBody*: XLangNode
    caseFallthrough*: bool  # ✓ Field exists for fallthrough!
```

Great! XLang already supports this. If it didn't, we'd need to add it.

---

## Step 2: Add Pass ID

Edit `src/transforms/pass_manager.nim`:

```nim
type
  TransformPassID* = enum
    tpNone = "none"
    tpForToWhile = "for-to-while"
    tpDoWhileToWhile = "dowhile-to-while"
    tpTernaryToIf = "ternary-to-if"
    tpInterfaceToConcept = "interface-to-concept"
    tpPropertyToProcs = "property-to-procs"
    tpSwitchFallthrough = "switch-fallthrough"  # ← Add this
```

---

## Step 3: Create the Transformation Module

Create `src/transforms/switch_fallthrough.nim`:

```nim
## Switch with Fallthrough Transformation
##
## Transforms: switch with fallthrough → if-elif chain
## Because Nim's case statement doesn't support fallthrough

import ../../xlangtypes
import options

proc mergeBlocks(body1, body2: XLangNode): XLangNode =
  ## Merge two block statements into one
  var stmts: seq[XLangNode] = @[]

  # Add statements from first block
  if body1.kind == xnkBlockStmt:
    stmts.add(body1.blockBody)
  else:
    stmts.add(body1)

  # Add statements from second block
  if body2.kind == xnkBlockStmt:
    stmts.add(body2.blockBody)
  else:
    stmts.add(body2)

  result = XLangNode(kind: xnkBlockStmt, blockBody: stmts)

proc buildOrCondition(switchExpr: XLangNode, values: seq[XLangNode]): XLangNode =
  ## Build: x == val1 or x == val2 or x == val3
  if values.len == 0:
    # Shouldn't happen, but handle it
    return XLangNode(kind: xnkBoolLit, literalValue: "false")

  if values.len == 1:
    return XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: "==",
      binaryLeft: switchExpr,
      binaryRight: values[0]
    )

  # Build chain of 'or' expressions
  var condition = XLangNode(
    kind: xnkBinaryExpr,
    binaryOp: "==",
    binaryLeft: switchExpr,
    binaryRight: values[0]
  )

  for i in 1..<values.len:
    let nextCond = XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: "==",
      binaryLeft: switchExpr,
      binaryRight: values[i]
    )

    condition = XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: "or",
      binaryLeft: condition,
      binaryRight: nextCond
    )

  result = condition

proc transformSwitchFallthrough*(node: XLangNode): XLangNode =
  ## Transform switch statements with fallthrough into if-elif chains
  if node.kind != xnkSwitchStmt:
    return node

  # Check if any case has fallthrough
  var hasFallthrough = false
  for caseNode in node.switchCases:
    if caseNode.kind == xnkCaseClause and caseNode.caseFallthrough:
      hasFallthrough = true
      break

  # If no fallthrough, Nim's case can handle it directly
  if not hasFallthrough:
    return node

  # Build if-elif chain
  var ifNodes: seq[XLangNode] = @[]
  var defaultBody: Option[XLangNode] = none(XLangNode)

  # Process each case
  var i = 0
  while i < node.switchCases.len:
    let caseNode = node.switchCases[i]

    if caseNode.kind == xnkDefaultClause:
      defaultBody = some(caseNode.caseBody)
      i += 1
      continue

    if caseNode.kind != xnkCaseClause:
      i += 1
      continue

    # Build condition for this case
    let condition = buildOrCondition(node.switchExpr, caseNode.caseValues)

    # Collect body - include next case's body if fallthrough
    var body = caseNode.caseBody

    if caseNode.caseFallthrough:
      # Merge with subsequent case bodies until we hit one without fallthrough
      var j = i + 1
      while j < node.switchCases.len:
        let nextCase = node.switchCases[j]
        if nextCase.kind == xnkCaseClause:
          body = mergeBlocks(body, nextCase.caseBody)
          if not nextCase.caseFallthrough:
            break
        j += 1

    # Create if/elif node
    ifNodes.add(XLangNode(
      kind: xnkIfStmt,
      ifCondition: condition,
      ifBody: body,
      elseBody: none(XLangNode)
    ))

    i += 1

  # Build the if-elif-else chain
  if ifNodes.len == 0:
    # Only had default clause?
    return if defaultBody.isSome: defaultBody.get else: node

  # Start with first if
  result = ifNodes[0]

  # Chain the rest as elif (elseBody containing next if)
  var current = result
  for i in 1..<ifNodes.len:
    current.elseBody = some(ifNodes[i])
    current = ifNodes[i]

  # Add default clause as final else
  if defaultBody.isSome:
    current.elseBody = some(defaultBody.get)

  # Wrap in block to ensure it's a statement, not expression
  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: @[result]
  )
```

---

## Step 4: Register the Pass

Edit `src/transforms/nim_passes.nim`:

```nim
import ../../xlangtypes
import pass_manager
import for_to_while
import dowhile_to_while
import ternary_to_if
import interface_to_concept
import property_to_procs
import switch_fallthrough  # ← Add import

proc registerNimPasses*(pm: PassManager) =
  # ... existing passes ...

  # 6. Switch with fallthrough → if-elif chain
  # Nim's case doesn't support fallthrough
  pm.addPass(newTransformPass(
    id: tpSwitchFallthrough,
    name: "switch-fallthrough",
    kind: tpkLowering,
    description: "Transform switch with fallthrough to if-elif chain",
    transform: transformSwitchFallthrough,
    dependencies: @[]  # No dependencies
  ))
```

---

## Step 5: Handle in xlangtonim_complete.nim

Check if `convertStatement` handles both `xnkSwitchStmt` and `xnkIfStmt`:

```nim
# In convertStatement proc
of xnkSwitchStmt:
  # Convert to Nim's case statement (no fallthrough version)
  let caseStmt = nnkCaseStmt.newTree()
  caseStmt.add(convertExpression(node.switchExpr))

  for caseNode in node.switchCases:
    if caseNode.kind == xnkCaseClause:
      let ofBranch = nnkOfBranch.newTree()
      for value in caseNode.caseValues:
        ofBranch.add(convertExpression(value))
      ofBranch.add(convertStatement(caseNode.caseBody))
      caseStmt.add(ofBranch)
    elif caseNode.kind == xnkDefaultClause:
      let elseBranch = nnkElse.newTree()
      elseBranch.add(convertStatement(caseNode.caseBody))
      caseStmt.add(elseBranch)

  result = caseStmt

of xnkIfStmt:
  # Already handled - our transformation produces if-elif chains
  # which are already supported
  ...
```

If switch conversion doesn't exist yet, add it. The if-statement conversion should already exist.

---

## Step 6: Write Tests

Create test in `test_transforms.nim`:

```nim
proc testSwitchWithFallthrough() =
  echo "=== Test: Switch with Fallthrough ==="
  echo ""

  # Create switch with fallthrough:
  # switch x {
  # case 1:
  #   echo "one"
  #   fallthrough
  # case 2:
  #   echo "two"
  # default:
  #   echo "other"
  # }

  let switchStmt = XLangNode(
    kind: xnkSwitchStmt,
    switchExpr: XLangNode(kind: xnkIdentifier, identName: "x"),
    switchCases: @[
      XLangNode(
        kind: xnkCaseClause,
        caseValues: @[XLangNode(kind: xnkIntLit, literalValue: "1")],
        caseBody: XLangNode(
          kind: xnkBlockStmt,
          blockBody: @[
            XLangNode(
              kind: xnkCallExpr,
              callFunc: XLangNode(kind: xnkIdentifier, identName: "echo"),
              callArgs: @[XLangNode(kind: xnkStringLit, literalValue: "one")]
            )
          ]
        ),
        caseFallthrough: true  # ← Fallthrough!
      ),
      XLangNode(
        kind: xnkCaseClause,
        caseValues: @[XLangNode(kind: xnkIntLit, literalValue: "2")],
        caseBody: XLangNode(
          kind: xnkBlockStmt,
          blockBody: @[
            XLangNode(
              kind: xnkCallExpr,
              callFunc: XLangNode(kind: xnkIdentifier, identName: "echo"),
              callArgs: @[XLangNode(kind: xnkStringLit, literalValue: "two")]
            )
          ]
        ),
        caseFallthrough: false
      ),
      XLangNode(
        kind: xnkDefaultClause,
        caseBody: XLangNode(
          kind: xnkBlockStmt,
          blockBody: @[
            XLangNode(
              kind: xnkCallExpr,
              callFunc: XLangNode(kind: xnkIdentifier, identName: "echo"),
              callArgs: @[XLangNode(kind: xnkStringLit, literalValue: "other")]
            )
          ]
        )
      )
    ]
  )

  echo "Original XLang: switch with fallthrough"
  let transformed = transformSwitchFallthrough(switchStmt)
  echo "Transformed to: ", transformed.kind
  echo ""

  # Should be if-elif chain
  assert transformed.kind == xnkBlockStmt
  assert transformed.blockBody[0].kind == xnkIfStmt

  let nimAst = convertXLangToNim(transformed)
  echo "Nim code:"
  echo nimAst.repr
  echo ""
```

Add to `when isMainModule` section:

```nim
when isMainModule:
  # ... existing tests ...
  testSwitchWithFallthrough()
```

---

## Step 7: Integration Test

Add to `test_integration.nim`:

```nim
proc testSwitchTransformation() =
  echo "=== Integration Test: Switch with Fallthrough ==="
  echo ""

  let jsonAst = %* {
    "kind": "xnkSwitchStmt",
    "switchExpr": {
      "kind": "xnkIdentifier",
      "identName": "x"
    },
    "switchCases": [
      {
        "kind": "xnkCaseClause",
        "caseValues": [{"kind": "xnkIntLit", "literalValue": "1"}],
        "caseBody": {
          "kind": "xnkBlockStmt",
          "blockBody": [
            {
              "kind": "xnkCallExpr",
              "callFunc": {"kind": "xnkIdentifier", "identName": "echo"},
              "callArgs": [{"kind": "xnkStringLit", "literalValue": "one"}]
            }
          ]
        },
        "caseFallthrough": true
      },
      {
        "kind": "xnkCaseClause",
        "caseValues": [{"kind": "xnkIntLit", "literalValue": "2"}],
        "caseBody": {
          "kind": "xnkBlockStmt",
          "blockBody": [
            {
              "kind": "xnkCallExpr",
              "callFunc": {"kind": "xnkIdentifier", "identName": "echo"},
              "callArgs": [{"kind": "xnkStringLit", "literalValue": "two"}]
            }
          ]
        },
        "caseFallthrough": false
      }
    ]
  }

  echo "JSON input → XLang → Transform → Nim"

  var xlangAst = parseXLangJsonString($jsonAst)
  echo "✓ Parsed"

  let pm = createNimPassManager()
  xlangAst = pm.runPasses(xlangAst)
  echo "✓ Transformed"

  let nimAst = convertXLangToNim(xlangAst)
  echo "✓ Converted to Nim AST"

  let nimCode = generateNimCode(nimAst)
  echo "Generated Nim code:"
  echo nimCode
  echo ""
```

---

## Step 8: Test It

If you had a Nim compiler available:

```bash
# Unit test
nim c test_transforms.nim
./test_transforms

# Integration test
nim c test_integration.nim
./test_integration
```

Expected output:
```
=== Test: Switch with Fallthrough ===

Original XLang: switch with fallthrough
Transformed to: xnkBlockStmt

Nim code:
if x == 1:
  echo "one"
  echo "two"
elif x == 2:
  echo "two"
```

---

## Step 9: Document It

Add to `TRANSFORMATION_EXAMPLES.md` in the switch section, showing:
- Input code (Go)
- XLang representation
- Transformation logic
- Output code (Nim)

---

## Step 10: Commit

```bash
git add src/transforms/switch_fallthrough.nim
git add src/transforms/nim_passes.nim
git add src/transforms/pass_manager.nim
git add test_transforms.nim
git add test_integration.nim
git add TRANSFORMATION_EXAMPLES.md

git commit -m "Add switch with fallthrough transformation

Implements transformation of Go-style switch statements with
fallthrough keyword into Nim-compatible if-elif chains.

- Added tpSwitchFallthrough pass ID
- Implemented switch_fallthrough.nim transformation module
- Registered pass in nim_passes.nim
- Added unit and integration tests
- Documented in TRANSFORMATION_EXAMPLES.md

Transform: switch with fallthrough → if-elif chain
Because: Nim's case statement doesn't support fallthrough"

git push
```

---

## Summary: The Pattern

For ANY new transformation:

1. **Check XLang support** - Add node kind/fields if needed
2. **Add pass ID** - Update TransformPassID enum
3. **Create transform module** - Implement transformation logic
4. **Register pass** - Add to nim_passes.nim with dependencies
5. **Update xlangtonim** - Ensure Nim AST conversion handles result
6. **Write tests** - Unit tests in test_transforms.nim
7. **Integration tests** - End-to-end in test_integration.nim
8. **Document** - Add example to TRANSFORMATION_EXAMPLES.md
9. **Commit** - Clear message explaining what and why

The key insight: **We're rewriting the XLang tree from "superset" constructs to "Nim subset" constructs before converting to Nim AST.**
