## Tests for generator expressions transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleGenerator = """{
  "kind": "xnkExternal_Generator",
  "extGenExpr": {"kind": "xnkIdentifier", "identName": "n"},
  "extGenFor": [
    {
      "kind": "xnkCompFor",
      "vars": [{"kind": "xnkIdentifier", "identName": "n"}],
      "iter": {
        "kind": "xnkCallExpr",
        "callee": {"kind": "xnkIdentifier", "identName": "range"},
        "args": [{"kind": "xnkIntLit", "literalValue": "10"}]
      }
    }
  ],
  "extGenIf": []
}"""

suite "Generator Expressions Transform":
  test "transforms generator expression":
    check testTransformEliminatesKind(
      sampleGenerator,
      tpGeneratorExpressions,
      xnkExternal_Generator
    )
