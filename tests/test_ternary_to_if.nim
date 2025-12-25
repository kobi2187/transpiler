## Tests for ternary-to-if transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleTernary = """{
  "kind": "xnkExternal_Ternary",
  "extTernaryCondition": {"kind": "xnkBinaryExpr", "binaryOp": ">", "binaryLeft": {"kind": "xnkIdentifier", "identName": "x"}, "binaryRight": {"kind": "xnkIntLit", "literalValue": "0"}},
  "extTernaryThen": {"kind": "xnkStringLit", "literalValue": "positive"},
  "extTernaryElse": {"kind": "xnkStringLit", "literalValue": "negative"}
}"""

const sampleNestedTernary = """{
  "kind": "xnkExternal_Ternary",
  "extTernaryCondition": {"kind": "xnkBinaryExpr", "binaryOp": ">", "binaryLeft": {"kind": "xnkIdentifier", "identName": "x"}, "binaryRight": {"kind": "xnkIntLit", "literalValue": "0"}},
  "extTernaryThen": {"kind": "xnkStringLit", "literalValue": "positive"},
  "extTernaryElse": {
    "kind": "xnkExternal_Ternary",
    "extTernaryCondition": {"kind": "xnkBinaryExpr", "binaryOp": "<", "binaryLeft": {"kind": "xnkIdentifier", "identName": "x"}, "binaryRight": {"kind": "xnkIntLit", "literalValue": "0"}},
    "extTernaryThen": {"kind": "xnkStringLit", "literalValue": "negative"},
    "extTernaryElse": {"kind": "xnkStringLit", "literalValue": "zero"}
  }
}"""

suite "Ternary to If Transform":
  test "transforms simple ternary expression":
    check testTransformEliminatesKind(
      sampleTernary,
      tpTernaryToIf,
      xnkExternal_Ternary
    )

  test "transforms nested ternary expression":
    check testTransformEliminatesKind(
      sampleNestedTernary,
      tpTernaryToIf,
      xnkExternal_Ternary
    )
