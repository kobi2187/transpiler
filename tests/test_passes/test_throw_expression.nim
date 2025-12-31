## Tests for throw expression transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleThrowExpr = """{
  "kind": "xnkExternal_ThrowExpr",
  "extThrowExprValue": {
    "kind": "xnkCallExpr",
    "callee": {"kind": "xnkIdentifier", "identName": "ValueError"},
    "args": [{"kind": "xnkStringLit", "literalValue": "Invalid value"}]
  }
}"""

suite "Throw Expression Transform":
  test "transforms throw expression":
    check testTransformEliminatesKind(
      sampleThrowExpr,
      tpThrowExpression,
      xnkExternal_ThrowExpr
    )
