## Tests for async normalization transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleAwait = """{
  "kind": "xnkExternal_Await",
  "extAwaitExpr": {
    "kind": "xnkCallExpr",
    "callee": {"kind": "xnkIdentifier", "identName": "fetchData"},
    "args": []
  }
}"""

suite "Async Normalization Transform":
  test "transforms await expression":
    check testTransformEliminatesKind(
      sampleAwait,
      tpAsyncNormalization,
      xnkExternal_Await
    )
