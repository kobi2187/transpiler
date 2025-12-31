## Shared transform registry for all languages

import ../types
import tables

var transformRegistry {.global.} = initTable[TransformPassID, TransformPass]()

proc clearTransformRegistry*() =
  transformRegistry = initTable[TransformPassID, TransformPass]()

proc registerTransform*(id: TransformPassID, p: TransformPass) =
  transformRegistry[id] = p

proc hasTransform*(id: TransformPassID): bool =
  transformRegistry.hasKey(id)

proc getTransform*(id: TransformPassID): TransformPass =
  result = transformRegistry.getOrDefault(id, nil)

proc allTransforms*(): Table[TransformPassID, TransformPass] =
  result = transformRegistry
