# "Namespace: ICU4N.Dev.Test.Normalizers"
type
  LongHashtable = ref object
    defaultValue: int
    table: IDictionary[Long, Integer] = Dictionary<Long, Integer>

proc newLongHashtable(defaultValue: int): LongHashtable =
  self.defaultValue = defaultValue
proc Put*(key: long, value: int) =
    if value == defaultValue:
table.Remove(Long(key))
    else:
        table[Long(key)] = Integer(value)
proc Get*(key: long): int =
    return     if !table.TryGetValue(key,     var value: Integer) || value == nil:
defaultValue
    else:
value.Value