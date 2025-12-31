## Shared enum registry used by multiple transform modules

import core/xlangtypes
import collections/tables

var enumRegistry {.global.} = initTable[string, string]()

proc createEnumPrefix*(typeName: string): string =
  result = ""
  for ch in typeName:
    if ch >= 'A' and ch <= 'Z':
      result.add(($ch).toLowerAscii())

proc registerEnum*(enumName: string) =
  let prefix = createEnumPrefix(enumName)
  enumRegistry[enumName] = prefix

proc getEnumPrefix*(enumName: string): Option[string] =
  if enumRegistry.hasKey(enumName):
    return some(enumRegistry[enumName])
  return none(string)

proc isEnumType*(typeName: string): bool =
  return enumRegistry.hasKey(typeName)
