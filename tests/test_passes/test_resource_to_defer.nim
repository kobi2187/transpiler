## Tests for resource-to-defer transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleResource = """{
  "kind": "xnkExternal_Resource",
  "extResourceItems": [
    {
      "kind": "xnkResourceItem",
      "resourceExpr": {"kind": "xnkCallExpr", "callee": {"kind": "xnkIdentifier", "identName": "openFile"}, "args": [{"kind": "xnkStringLit", "literalValue": "test.txt"}]},
      "resourceVar": {"kind": "xnkIdentifier", "identName": "f"}
    }
  ],
  "extResourceBody": {"kind": "xnkBlockStmt", "blockBody": [
    {"kind": "xnkCallExpr", "callee": {"kind": "xnkIdentifier", "identName": "readFile"}, "args": [{"kind": "xnkIdentifier", "identName": "f"}]}
  ]}
}"""

suite "Resource to Defer Transform":
  test "transforms resource management to defer":
    check testTransformEliminatesKind(
      sampleResource,
      tpResourceToDefer,
      xnkExternal_Resource
    )
