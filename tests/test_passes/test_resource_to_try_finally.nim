## Tests for resource-to-try-finally transformation (alternative for targets without defer)

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleResource = """{
  "kind": "xnkExternal_Resource",
  "extResourceItems": [
    {
      "kind": "xnkResourceItem",
      "resourceExpr": {
        "kind": "xnkCallExpr",
        "callee": {"kind": "xnkIdentifier", "identName": "openFile"},
        "args": [{"kind": "xnkStringLit", "literalValue": "test.txt"}]
      },
      "resourceVar": {"kind": "xnkIdentifier", "identName": "f"}
    }
  ],
  "extResourceBody": {
    "kind": "xnkBlockStmt",
    "blockBody": [
      {
        "kind": "xnkCallExpr",
        "callee": {"kind": "xnkIdentifier", "identName": "readFile"},
        "args": [{"kind": "xnkIdentifier", "identName": "f"}]
      }
    ]
  }
}"""

suite "Resource to Try-Finally Transform":
  test "transforms resource management to try-finally":
    check testTransformEliminatesKind(
      sampleResource,
      tpResourceToTryFinally,
      xnkExternal_Resource
    )
