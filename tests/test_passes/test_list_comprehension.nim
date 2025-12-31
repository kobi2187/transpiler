## Tests for list comprehension transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleComprehension = """{
  "kind": "xnkExternal_Comprehension",
  "extCompExpr": {"kind": "xnkIdentifier", "identName": "x"},
  "extCompFors": [
    {
      "kind": "xnkCompFor",
      "vars": [{"kind": "xnkIdentifier", "identName": "x"}],
      "iter": {
        "kind": "xnkCallExpr",
        "callee": {"kind": "xnkIdentifier", "identName": "range"},
        "args": [{"kind": "xnkIntLit", "literalValue": "10"}]
      }
    }
  ],
  "extCompIf": []
}"""

suite "List Comprehension Transform":
  test "transforms list comprehension to loop":
    check testTransformEliminatesKind(
      sampleComprehension,
      tpListComprehension,
      xnkExternal_Comprehension
    )
