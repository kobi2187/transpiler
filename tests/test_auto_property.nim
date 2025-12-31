type Person = ref object


_name: string
proc getName*(self: Person): string =
  return self._name

proc setName*(self: Person, value: string) =
  self._name = value

_age: int32
proc getAge*(self: Person): int32 =
  return self._age

proc setAge*(self: Person, value: int32) =
  self._age = value
