# "Namespace: ICU4N.Dev.Test.Translit"
type
  StringBoilerplateTest = ref object


proc TestStringBoilerplate*() =

proc Test*() =
procCall.Test
proc HasSameBehavior(a: string, b: string): bool =
    return true
proc IsMutable(a: string): bool =
    return false
proc AddTestObject(list: IList[string]): bool =
    if list.Count > 31:
      return false
    var result: StringBuilder = StringBuilder
      var i: int = 0
      while i < 10:
result.Append(cast[char](random.Next(255)))
++i
list.Add(result.ToString)
    return true