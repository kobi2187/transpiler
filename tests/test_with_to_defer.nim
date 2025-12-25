## Tests for with-to-defer transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleWith = """{
  "kind": "xnkExternal_With",
  "extWithItems": [
    {
      "kind": "xnkWithItem",
      "contextExpr": {
        "kind": "xnkCallExpr",
        "callee": {"kind": "xnkIdentifier", "identName": "open"},
        "args": [{"kind": "xnkStringLit", "literalValue": "file.txt"}]
      },
      "asExpr": {"kind": "xnkIdentifier", "identName": "f"}
    }
  ],
  "extWithBody": {
    "kind": "xnkBlockStmt",
    "blockBody": [
      {
        "kind": "xnkCallExpr",
        "callee": {"kind": "xnkIdentifier", "identName": "read"},
        "args": [{"kind": "xnkIdentifier", "identName": "f"}]
      }
    ]
  }
}"""

suite "With to Defer Transform":
  test "transforms with statement to defer":
    check testTransformEliminatesKind(
      sampleWith,
      tpWithToDefer,
      xnkExternal_With
    )
