## Tests for property-to-procs transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleProperty = """{
  "kind": "xnkExternal_Property",
  "extPropName": "Age",
  "extPropType": {"kind": "xnkNamedType", "typeName": "int"},
  "extPropGetter": {
    "kind": "xnkBlockStmt",
    "blockBody": [
      {"kind": "xnkReturnStmt", "returnExpr": {"kind": "xnkIdentifier", "identName": "age"}}
    ]
  }
}"""

const samplePropertyWithSetter = """{
  "kind": "xnkExternal_Property",
  "extPropName": "Name",
  "extPropType": {"kind": "xnkNamedType", "typeName": "string"},
  "extPropGetter": {
    "kind": "xnkBlockStmt",
    "blockBody": [
      {"kind": "xnkReturnStmt", "returnExpr": {"kind": "xnkIdentifier", "identName": "_name"}}
    ]
  },
  "extPropSetter": {
    "kind": "xnkBlockStmt",
    "blockBody": [
      {"kind": "xnkAsgn", "asgnLeft": {"kind": "xnkIdentifier", "identName": "_name"}, "asgnRight": {"kind": "xnkIdentifier", "identName": "value"}}
    ]
  }
}"""

const sampleAutoProperty = """{
  "kind": "xnkExternal_Property",
  "extPropName": "Count",
  "extPropType": {"kind": "xnkNamedType", "typeName": "int"}
}"""

suite "Property to Procs Transform":
  test "transforms property with getter to function":
    check testTransformEliminatesKind(
      sampleProperty,
      tpPropertyToProcs,
      xnkExternal_Property
    )

  test "transforms property with getter and setter":
    check testTransformEliminatesKind(
      samplePropertyWithSetter,
      tpPropertyToProcs,
      xnkExternal_Property
    )

  test "transforms auto-property to field":
    check testTransformEliminatesKind(
      sampleAutoProperty,
      tpPropertyToProcs,
      xnkExternal_Property
    )
