# "Namespace: ICU4N.Dev.Test.Normalizers"
type
  IntHashtable = ref object
    defaultValue: int
    table: IDictionary[Integer, Integer] = Dictionary<Integer, Integer>

proc newIntHashtable(defaultValue: int): IntHashtable =
  self.defaultValue = defaultValue
proc Put*(key: int, value: int) =
    if value == defaultValue:
table.Remove(Integer(key))
    else:
        table[Integer(key)] = Integer(value)
proc Get*(key: int): int =
    return     if !table.TryGetValue(key,     var value: Integer) || value == nil:
defaultValue
    else:
value.Value