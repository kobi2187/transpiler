## Tests for destructuring transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleDestructuring = """{
  "kind": "xnkExternal_Destructure",
  "extDestructKind": "array",
  "extDestructSource": {
    "kind": "xnkTupleExpr",
    "elements": [
      {"kind": "xnkIntLit", "literalValue": "1"},
      {"kind": "xnkIntLit", "literalValue": "2"}
    ]
  },
  "extDestructFields": [],
  "extDestructVars": ["x", "y"],
  "extDestructRest": null
}"""

suite "Destructuring Transform":
  test "transforms destructuring assignment":
    check testTransformEliminatesKind(
      sampleDestructuring,
      tpDestructuring,
      xnkExternal_Destructure
    )
