## Tests for C# events transformation

import unittest
import test_common
import ../xlangtypes
import ../src/transforms/types

const sampleEvent = """{
  "kind": "xnkExternal_Event",
  "extEventName": "OnClick",
  "extEventType": {
    "kind": "xnkNamedType",
    "typeName": "EventHandler"
  },
  "extEventAdd": null,
  "extEventRemove": null
}"""

suite "C# Events Transform":
  test "transforms C# event to delegate pattern":
    check testTransformEliminatesKind(
      sampleEvent,
      tpCSharpEvents,
      xnkExternal_Event
    )
