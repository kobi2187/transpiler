## Tests for interface-to-concept transformation (Nim-specific)

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleInterface = """{
  "kind": "xnkExternal_Interface",
  "extInterfaceName": "IDrawable",
  "extInterfaceBaseTypes": [],
  "extInterfaceMembers": [
    {
      "kind": "xnkFuncDecl",
      "funcName": "draw",
      "params": [],
      "returnType": {"kind": "xnkNamedType", "typeName": "void"},
      "body": {"kind": "xnkBlockStmt", "blockBody": []},
      "isAsync": false
    }
  ]
}"""

suite "Interface to Concept Transform":
  test "transforms interface to Nim concept":
    check testTransformEliminatesKind(
      sampleInterface,
      tpNimInterfaceToConcept,
      xnkExternal_Interface
    )
