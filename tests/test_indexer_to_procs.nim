## Tests for indexer-to-procs transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleIndexer = """{
  "kind": "xnkExternal_Indexer",
  "extIndexerParams": [
    {"kind": "xnkParameter", "paramName": "index", "paramType": {"kind": "xnkNamedType", "typeName": "int"}}
  ],
  "extIndexerType": {"kind": "xnkNamedType", "typeName": "string"},
  "extIndexerGetter": {
    "kind": "xnkBlockStmt",
    "blockBody": [
      {"kind": "xnkReturnStmt", "returnExpr": {"kind": "xnkIdentifier", "identName": "items"}}
    ]
  }
}"""

suite "Indexer to Procs Transform":
  test "transforms indexer to getter/setter procs":
    check testTransformEliminatesKind(
      sampleIndexer,
      tpIndexerToProcs,
      xnkExternal_Indexer
    )
