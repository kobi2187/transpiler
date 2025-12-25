# "Namespace: ICU4N.Dev.Test.Translit"
type
  UnicodeMapBoilerplateTest = ref object
    TEST_VALUES: seq[String] = @["A", "B", "C", "D", "E", "F"]

proc TestUnicodeMapBoilerplate*() =

proc Test*() =
procCall.Test
proc HasSameBehavior(a: UnicodeMap[string], b: UnicodeMap[string]): bool =
    return true
proc AddTestObject(list: IList[UnicodeMap<string>]): bool =
    if list.Count > 30:
      return false
    var result: UnicodeMap<string> = UnicodeMap<string>
      var i: int = 0
      while i < 50:
          var start: int = random.Next(25)
          var value: String = TEST_VALUES[random.Next(TEST_VALUES.Length)]
result.Put(start, value)
++i
list.Add(result)
    return true