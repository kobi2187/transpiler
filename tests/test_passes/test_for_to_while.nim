## Tests for for-to-while transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleForLoop = """{
  "kind": "xnkExternal_ForStmt",
  "extForInit": {"kind": "xnkVarDecl", "declName": "i", "declType": {"kind": "xnkNamedType", "typeName": "int"}, "initializer": {"kind": "xnkIntLit", "literalValue": "0"}},
  "extForCond": {"kind": "xnkBinaryExpr", "binaryOp": "<", "binaryLeft": {"kind": "xnkIdentifier", "identName": "i"}, "binaryRight": {"kind": "xnkIntLit", "literalValue": "10"}},
  "extForIncrement": {"kind": "xnkAsgn", "asgnLeft": {"kind": "xnkIdentifier", "identName": "i"}, "asgnRight": {"kind": "xnkBinaryExpr", "binaryOp": "+", "binaryLeft": {"kind": "xnkIdentifier", "identName": "i"}, "binaryRight": {"kind": "xnkIntLit", "literalValue": "1"}}},
  "extForBody": {"kind": "xnkBlockStmt", "blockBody": []}
}"""

const sampleInfiniteFor = """{
  "kind": "xnkExternal_ForStmt",
  "extForBody": {"kind": "xnkBlockStmt", "blockBody": [
    {"kind": "xnkCallExpr", "callee": {"kind": "xnkIdentifier", "identName": "doWork"}, "args": []}
  ]}
}"""

suite "For to While Transform":
  test "transforms C-style for loop to while":
    check testTransformEliminatesKind(
      sampleForLoop,
      tpForToWhile,
      xnkExternal_ForStmt
    )

  test "transforms infinite for loop":
    check testTransformEliminatesKind(
      sampleInfiniteFor,
      tpForToWhile,
      xnkExternal_ForStmt
    )
