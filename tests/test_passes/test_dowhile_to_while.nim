## Tests for dowhile-to-while transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleDoWhile = """{
  "kind": "xnkExternal_DoWhile",
  "extDoWhileCondition": {"kind": "xnkBinaryExpr", "binaryOp": "<", "binaryLeft": {"kind": "xnkIdentifier", "identName": "x"}, "binaryRight": {"kind": "xnkIntLit", "literalValue": "10"}},
  "extDoWhileBody": {"kind": "xnkBlockStmt", "blockBody": [
    {"kind": "xnkAsgn", "asgnLeft": {"kind": "xnkIdentifier", "identName": "x"}, "asgnRight": {"kind": "xnkBinaryExpr", "binaryOp": "+", "binaryLeft": {"kind": "xnkIdentifier", "identName": "x"}, "binaryRight": {"kind": "xnkIntLit", "literalValue": "1"}}}
  ]}
}"""

suite "Do-While to While Transform":
  test "transforms do-while to while-true with break":
    check testTransformEliminatesKind(
      sampleDoWhile,
      tpDoWhileToWhile,
      xnkExternal_DoWhile
    )
