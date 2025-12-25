# "Namespace: ICU4N.Dev.Test.Normalizers"
type
  IntStringHashtable = ref object
    defaultValue: string
    table: IDictionary[Integer, string] = Dictionary<Integer, string>

proc newIntStringHashtable(defaultValue: string): IntStringHashtable =
  self.defaultValue = defaultValue
proc Put*(key: int, value: string) =
    if value == defaultValue:
table.Remove(Integer(key))
    else:
        table[Integer(key)] = value
proc Get*(key: int): string =
    return     if !table.TryGetValue(key,     var value: string) || value == nil:
defaultValue
    else:
value