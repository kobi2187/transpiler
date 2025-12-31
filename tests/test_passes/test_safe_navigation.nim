## Tests for safe-navigation transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleSafeNav = """{
  "kind": "xnkExternal_SafeNavigation",
  "extSafeNavObject": {"kind": "xnkIdentifier", "identName": "obj"},
  "extSafeNavMember": "name"
}"""

suite "Safe Navigation Transform":
  test "transforms safe navigation operator":
    check testTransformEliminatesKind(
      sampleSafeNav,
      tpSafeNavigation,
      xnkExternal_SafeNavigation
    )
