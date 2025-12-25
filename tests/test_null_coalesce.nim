## Tests for null-coalesce transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleNullCoalesce = """{
  "kind": "xnkExternal_NullCoalesce",
  "extNullCoalesceLeft": {"kind": "xnkIdentifier", "identName": "name"},
  "extNullCoalesceRight": {"kind": "xnkStringLit", "literalValue": "default"}
}"""

suite "Null Coalesce Transform":
  test "transforms null coalesce operator":
    check testTransformEliminatesKind(
      sampleNullCoalesce,
      tpNullCoalesce,
      xnkExternal_NullCoalesce
    )
