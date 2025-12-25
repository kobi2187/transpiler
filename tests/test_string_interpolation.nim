## Tests for string-interpolation transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleStringInterp = """{
  "kind": "xnkExternal_StringInterp",
  "extInterpParts": [
    {"kind": "xnkStringLit", "literalValue": "Hello "},
    {"kind": "xnkIdentifier", "identName": "name"},
    {"kind": "xnkStringLit", "literalValue": "!"}
  ],
  "extInterpIsExpr": [false, true, false]
}"""

const sampleMultipleExprs = """{
  "kind": "xnkExternal_StringInterp",
  "extInterpParts": [
    {"kind": "xnkStringLit", "literalValue": "User: "},
    {"kind": "xnkIdentifier", "identName": "name"},
    {"kind": "xnkStringLit", "literalValue": ", Age: "},
    {"kind": "xnkIdentifier", "identName": "age"}
  ],
  "extInterpIsExpr": [false, true, false, true]
}"""

suite "String Interpolation Transform":
  test "transforms string interpolation to concatenation":
    check testTransformEliminatesKind(
      sampleStringInterp,
      tpStringInterpolation,
      xnkExternal_StringInterp
    )

  test "transforms interpolation with multiple expressions":
    check testTransformEliminatesKind(
      sampleMultipleExprs,
      tpStringInterpolation,
      xnkExternal_StringInterp
    )
