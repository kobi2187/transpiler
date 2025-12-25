# "Namespace: ICU4N.Dev.Test.Normalizers"
type
  TestCanonicalIterator = ref object
    SHOW_NAMES: bool = false
    testArray: seq[string] = @[@["Åḑ̇", "Åḑ̇, Åḑ̇, Åḑ̇, " + "Åḑ̇, Åḑ̇, Åḑ̇, " + "Åḑ̇, Åḑ̇, Åḑ̇, " + "Åḑ̇, Åḑ̇, Åḑ̇"], @["čž", "čž, čž, čž, čž"], @["ẋ̧", "ẋ̧, ẋ̧, ẋ̧"]]

proc TestExhaustive*() =
    var counter: int = 0
    var it: CanonicalEnumerator = CanonicalEnumerator("")
      var i: int = 0
      while i < 1114111:
          var type: UUnicodeCategory = UChar.GetUnicodeCategory(i)
          if type == UUnicodeCategory.OtherNotAssigned || type == UUnicodeCategory.PrivateUse || type == UUnicodeCategory.Surrogate:
            continue
          if ++counter % 5000 == 0:
Logln("Testing " + Utility.Hex(i, 0))
          var s: string = UTF16.ValueOf(i)
CharacterTest(s, i, it)
CharacterTest(s + "ͅ", i, it)
++i
proc TestSpeed*(): int =
    if !IsVerbose:
      return 0
    var s: string = "각ͅ"
    var it: CanonicalEnumerator = CanonicalEnumerator(s)
      var start: double
      var end: double
    var x: int = 0
    var iterations: int = 10000
    var slowDelta: double = 0
    start = Time.CurrentTimeMilliseconds
      var i: int = 0
      while i < iterations:
it.SetSource(s)
          while it.MoveNext:
              var item: string = it.Current
              x = item.Length
++i
    end = Time.CurrentTimeMilliseconds
    var fastDelta: double = end - start / iterations
Logln("Fast iteration: " + fastDelta +     if slowDelta != 0:
", " + fastDelta / slowDelta
    else:
"")
    return x
proc TestBasic*() =
    var results: ISet<string> = SortedSet<string>(StringComparer.Ordinal)
CanonicalEnumerator.Permute("ABC", false, results)
expectEqual("Simple permutation ", "", CollectionToString(results), "ABC, ACB, BAC, BCA, CAB, CBA")
    var set: ISet<string> = SortedSet<string>(StringComparer.Ordinal)
      var i: int = 0
      while i < testArray.Length:
          var it: CanonicalEnumerator = CanonicalEnumerator(testArray[i][0])
set.Clear
          var first: string = nil
          while it.MoveNext:
              var result: string = it.Current
              if first == nil:
                  first = result
set.Add(result)
expectEqual(i + ": ", testArray[i][0], CollectionToString(set), testArray[i][1])
it.Reset
it.MoveNext
          if !it.Current.Equals(first):
Errln("CanonicalIterator.reset() failed")
          if !it.Source.Equals(Normalizer.Normalize(testArray[i][0], NormalizerMode.NFD)):
Errln("CanonicalIterator.getSource() does not return NFD of input source")
++i
proc expectEqual(message: string, item: string, a: object, b: object) =
    if !a.Equals(b):
Errln("FAIL: " + message + GetReadable(item))
Errln("	" + GetReadable(a))
Errln("	" + GetReadable(b))
    else:
Logln("Checked: " + message + GetReadable(item))
Logln("	" + GetReadable(a))
Logln("	" + GetReadable(b))
proc GetReadable*(obj: object): string =
    if obj == nil:
      return "null"
    var s: string = obj.ToString
    if s.Length == 0:
      return ""
    return "[" +     if SHOW_NAMES:
Hex(s) + "; "
    else:
"" + Hex(s) + "]"
proc CharacterTest(s: string, ch: int, it: CanonicalEnumerator) =
    var mixedCounter: int = 0
    var lastMixedCounter: int = -1
    var gotDecomp: bool = false
    var gotComp: bool = false
    var gotSource: bool = false
    var decomp: string = Normalizer.Decompose(s, false)
    var comp: string = Normalizer.Compose(s, false)
    if s.Equals(decomp) && s.Equals(comp):
      return
it.SetSource(s)
    while it.MoveNext:
        var item: string = it.Current
        if item.Equals(s):
          gotSource = true
        if item.Equals(decomp):
          gotDecomp = true
        if item.Equals(comp):
          gotComp = true
        if mixedCounter & 127 == 0 && ch < 44288 || ch > 44032 + 11172:
            if lastMixedCounter != mixedCounter:
Logln("")
                lastMixedCounter = mixedCounter
Logln("	" + mixedCounter + "	" + Hex(item) +             if item.Equals(s):
"	(*original*)"
            else:
"" +             if item.Equals(decomp):
"	(*decomp*)"
            else:
"" +             if item.Equals(comp):
"	(*comp*)"
            else:
"")
++mixedCounter
    if !gotSource || !gotDecomp || !gotComp:
Errln("FAIL CanonicalIterator: " + s + " decomp: " + decomp + " comp: " + comp)
it.Reset
        while it.MoveNext:
            var item: string = it.Current
Err(item + "    ")
Errln("")
proc CollectionToString(col: ICollection[T]): string =
    var result: StringBuffer = StringBuffer
      let it = col.GetEnumerator
<unhandled: nnkDefer>
      while it.MoveNext:
          if result.Length != 0:
result.Append(", ")
result.Append(it.Current.ToString)
    return result.ToString