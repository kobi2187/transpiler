## Unit tests for transformation passes
## Tests that each transform correctly eliminates its external kind

import std/json
import std/tables
import std/strutils
import jsontoxlangtypes
import xlangtypes
import src/transforms/helpers
import src/transforms/pass_manager2
import src/transforms/nim_passes
import src/transforms/types
import sets

# Test samples for each external kind
const testSamples = {
  "xnkExternal_Property": """{
    "kind": "xnkExternal_Property",
    "extPropName": "Age",
    "extPropType": {"kind": "xnkNamedType", "typeName": "int"},
    "extPropGetter": {
      "kind": "xnkBlockStmt",
      "blockBody": [
        {"kind": "xnkReturnStmt", "returnExpr": {"kind": "xnkIdentifier", "identName": "age"}}
      ]
    }
  }""",

  "xnkExternal_ForStmt": """{
    "kind": "xnkExternal_ForStmt",
    "extForInit": {"kind": "xnkVarDecl", "declName": "i", "declType": {"kind": "xnkNamedType", "typeName": "int"}, "initializer": {"kind": "xnkIntLit", "literalValue": "0"}},
    "extForCond": {"kind": "xnkBinaryExpr", "binaryOp": "<", "binaryLeft": {"kind": "xnkIdentifier", "identName": "i"}, "binaryRight": {"kind": "xnkIntLit", "literalValue": "10"}},
    "extForIncrement": {"kind": "xnkAsgn", "asgnLeft": {"kind": "xnkIdentifier", "identName": "i"}, "asgnRight": {"kind": "xnkBinaryExpr", "binaryOp": "+", "binaryLeft": {"kind": "xnkIdentifier", "identName": "i"}, "binaryRight": {"kind": "xnkIntLit", "literalValue": "1"}}},
    "extForBody": {"kind": "xnkBlockStmt", "blockBody": []}
  }""",

  "xnkExternal_DoWhile": """{
    "kind": "xnkExternal_DoWhile",
    "extDoWhileCondition": {"kind": "xnkBinaryExpr", "binaryOp": "<", "binaryLeft": {"kind": "xnkIdentifier", "identName": "x"}, "binaryRight": {"kind": "xnkIntLit", "literalValue": "10"}},
    "extDoWhileBody": {"kind": "xnkBlockStmt", "blockBody": [
      {"kind": "xnkAsgn", "asgnLeft": {"kind": "xnkIdentifier", "identName": "x"}, "asgnRight": {"kind": "xnkBinaryExpr", "binaryOp": "+", "binaryLeft": {"kind": "xnkIdentifier", "identName": "x"}, "binaryRight": {"kind": "xnkIntLit", "literalValue": "1"}}}
    ]}
  }""",

  "xnkExternal_Ternary": """{
    "kind": "xnkExternal_Ternary",
    "extTernaryCondition": {"kind": "xnkBinaryExpr", "binaryOp": ">", "binaryLeft": {"kind": "xnkIdentifier", "identName": "x"}, "binaryRight": {"kind": "xnkIntLit", "literalValue": "0"}},
    "extTernaryThen": {"kind": "xnkStringLit", "literalValue": "positive"},
    "extTernaryElse": {"kind": "xnkStringLit", "literalValue": "negative"}
  }""",

  "xnkExternal_StringInterp": """{
    "kind": "xnkExternal_StringInterp",
    "extInterpParts": [
      {"kind": "xnkStringLit", "literalValue": "Hello "},
      {"kind": "xnkIdentifier", "identName": "name"},
      {"kind": "xnkStringLit", "literalValue": "!"}
    ],
    "extInterpIsExpr": [false, true, false]
  }"""
}

proc testTransform(kindName: string, jsonSample: string, passId: TransformPassID): bool =
  ## Test a single transform
  ## Returns true if the external kind was successfully eliminated
  echo "\n=== Testing ", passId, " on ", kindName, " ==="

  # Parse JSON to XLang
  var node = jsonSample.parseJson().to(XLangNode)
  echo "  Input kind: ", node.kind

  # Collect kinds before transform
  let kindsBefore = collectAllKinds(node)
  echo "  Kinds before: ", kindsBefore

  # Apply transform directly
  let registry = buildNimPassRegistry()
  if not registry.hasKey(passId):
    echo "  ❌ ERROR: Transform ", passId, " not found in registry"
    return false
  let transform = registry.getOrDefault(passId)
  node = transform.transform(node)

  echo "  Output kind: ", node.kind

  # Collect kinds after transform
  let kindsAfter = collectAllKinds(node)
  echo "  Kinds after: ", kindsAfter

  # Check if external kind was eliminated
  let externalKind = parseEnum[XLangNodeKind](kindName)
  if externalKind in kindsAfter:
    echo "  ❌ FAILED: External kind ", kindName, " still present after transform!"
    return false
  else:
    echo "  ✓ PASSED: External kind ", kindName, " was eliminated"
    return true

proc main() =
  echo "Running transformation pass tests..."
  echo "===================================="

  var passed = 0
  var failed = 0

  # Test each transform
  if testTransform("xnkExternal_Property", testSamples[0][1], tpPropertyToProcs):
    passed.inc()
  else:
    failed.inc()

  if testTransform("xnkExternal_ForStmt", testSamples[1][1], tpForToWhile):
    passed.inc()
  else:
    failed.inc()

  if testTransform("xnkExternal_DoWhile", testSamples[2][1], tpDoWhileToWhile):
    passed.inc()
  else:
    failed.inc()

  if testTransform("xnkExternal_Ternary", testSamples[3][1], tpTernaryToIf):
    passed.inc()
  else:
    failed.inc()

  if testTransform("xnkExternal_StringInterp", testSamples[4][1], tpStringInterpolation):
    passed.inc()
  else:
    failed.inc()

  echo "\n===================================="
  echo "Test Results:"
  echo "  Passed: ", passed
  echo "  Failed: ", failed
  echo "  Total:  ", passed + failed

  if failed > 0:
    quit(1)

when isMainModule:
  main()
