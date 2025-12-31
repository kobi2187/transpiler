## Tests for operator overload transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleOperatorOverload = """{
  "kind": "xnkExternal_Operator",
  "extOperatorSymbol": "+",
  "extOperatorParams": [
    {
      "kind": "xnkParameter",
      "paramName": "a",
      "paramType": {"kind": "xnkNamedType", "typeName": "int"}
    },
    {
      "kind": "xnkParameter",
      "paramName": "b",
      "paramType": {"kind": "xnkNamedType", "typeName": "int"}
    }
  ],
  "extOperatorReturnType": {"kind": "xnkNamedType", "typeName": "int"},
  "extOperatorBody": {
    "kind": "xnkBlockStmt",
    "blockBody": [
      {
        "kind": "xnkReturnStmt",
        "returnExpr": {
          "kind": "xnkBinaryExpr",
          "binaryOp": "+",
          "binaryLeft": {"kind": "xnkIdentifier", "identName": "a"},
          "binaryRight": {"kind": "xnkIdentifier", "identName": "b"}
        }
      }
    ]
  }
}"""

suite "Operator Overload Transform":
  test "transforms operator overload to function":
    check testTransformEliminatesKind(
      sampleOperatorOverload,
      tpOperatorOverload,
      xnkExternal_Operator
    )
