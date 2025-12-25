# "Namespace: ICU4N.Dev.Test.Translit"
type
  UnicodeMapExtensions = ref object


proc Put*(map: UnicodeMap[Double], codePoint: int, value: double): UnicodeMap<Double> =
    return map.Put(codePoint, Double(value))
proc Put*(map: UnicodeMap[Double], str: string, value: double): UnicodeMap<Double> =
    return map.Put(str, Double(value))
proc Put*(map: UnicodeMap[Integer], codePoint: int, value: int): UnicodeMap<Integer> =
    return map.Put(codePoint, Integer(value))
proc Put*(map: UnicodeMap[Integer], str: string, value: int): UnicodeMap<Integer> =
    return map.Put(str, Integer(value))
proc Put*(map: UnicodeMap[Character], codePoint: int, value: char): UnicodeMap<Character> =
    return map.Put(codePoint, Character(value))
proc Put*(map: UnicodeMap[Character], str: string, value: char): UnicodeMap<Character> =
    return map.Put(str, Character(value))
proc PutAll*(map: UnicodeMap[Double], startCodePoint: int, endCodePoint: int, value: double): UnicodeMap<Double> =
    return map.PutAll(startCodePoint, endCodePoint, Double(value))
proc PutAll*(map: UnicodeMap[Integer], startCodePoint: int, endCodePoint: int, value: int): UnicodeMap<Integer> =
    return map.PutAll(startCodePoint, endCodePoint, Integer(value))
proc PutAll*(map: UnicodeMap[Character], startCodePoint: int, endCodePoint: int, value: char): UnicodeMap<Character> =
    return map.PutAll(startCodePoint, endCodePoint, Character(value))
type
  UnicodeMapTest = ref object
    MODIFY_TEST_LIMIT: int = 32
    MODIFY_TEST_ITERATIONS: int = 100000
    temp: ISet[KeyValuePair<string, Integer>] = JCG.HashSet<KeyValuePair<string, Integer>>
    OneFirstComparator: IComparer[String] = OneFirstComparer
    LIMIT: int = 21
    ITERATIONS: int = 1000000
    SHOW_PROGRESS: bool = false
    DEBUG: bool = false
    log: JCG.SortedSet<string> = JCG.SortedSet<string>
    TEST_VALUES: seq[string] = @["A", "B", "C", "D", "E", "F"]
    random: Random = Random(12345)
    SET_LIMIT: int = 1114111
    propEnum: UProperty = UProperty.General_Category
    ENTRY_COMPARATOR: IComparer[KeyValuePair<int, string>] = EntryComparer

proc TestIterations*() =
    var foo: UnicodeMap<Double> = UnicodeMap<Double>
checkToString(foo, "")
foo.Put(3, 6.0).Put(5, 10.0)
checkToString(foo, "0003=6.0
0005=10.0
")
foo.Put(1114111, 666.0)
checkToString(foo, "0003=6.0
0005=10.0
10FFFF=666.0
")
foo.Put("neg", -555.0)
checkToString(foo, "0003=6.0
0005=10.0
10FFFF=666.0
006E,0065,0067=-555.0
")
    var i: double = 0
    for entryRange in foo.GetEntryRanges:
        i = entryRange.Value.Value
assertEquals("EntryRange<T>", 127.0, i)
proc checkToString*(foo: UnicodeMap[Double], expected: String) =
assertEquals("EntryRange<T>", expected, string.Join("
", foo.GetEntryRanges.Select(<unhandled: nnkLambda>).ToArray) +     if foo.Count == 0:
""
    else:
"
")
assertEquals("EntryRange<T>", expected, foo.ToString)
proc TestRemove*() =
    var foo: UnicodeMap<Double> = UnicodeMap<Double>.PutAll(32, 41, -2.0).Put("abc", 3.0).Put("xy", 2.0).Put("mark", 4.0).Freeze
    var fii: UnicodeMap<Double> = UnicodeMap<Double>.PutAll(33, 37, -2.0).PutAll(38, 40, -3.0).Put("abc", 3.0).Put("mark", 999.0).Freeze
    var afterFiiRemoval: UnicodeMap<Double> = UnicodeMap<Double>.Put(32, -2.0).PutAll(38, 41, -2.0).Put("xy", 2.0).Put("mark", 4.0).Freeze
    var afterFiiRetained: UnicodeMap<Double> = UnicodeMap<Double>.PutAll(33, 37, -2.0).Put("abc", 3.0).Freeze
    var test: UnicodeMap<Double> = UnicodeMap<Double>.PutAll(foo).RemoveAll(fii)
assertEquals("removeAll", afterFiiRemoval, test)
    test = UnicodeMap<Double>.PutAll(foo).RetainAll(fii)
assertEquals("retainAll", afterFiiRetained, test)
proc TestAMonkey*() =
    var stayWithMe: JCG.SortedDictionary<String, Integer> = JCG.SortedDictionary<String, Integer>(OneFirstComparator)
    var me: UnicodeMap<Integer> = UnicodeMap<Integer>.PutAll(stayWithMe)
me.PutAll(1114110, 1114111, 666)
me.Remove(1114111)
    var iterations: int = 100000
    var test: JCG.SortedDictionary<String, Integer> = JCG.SortedDictionary<string, Integer>(StringComparer.Ordinal)
    var rand: Random = Random(0)
    var other: String
    var value: Integer
      var i: int = 0
      while i < iterations:
          case           if i == 0:
0
          else:
rand.Next(20)
          of 0:
Logln("clear")
stayWithMe.Clear
me.Clear
              break
          of 1:
fillRandomMap(rand, 5, test)
Logln("putAll	" + test)
stayWithMe.PutAll(test)
me.PutAll(test)
              break
          of 2:
              other = GetRandomKey(rand)
Logln("remove	" + other)
stayWithMe.Remove(other)
              try:
me.Remove(other)
              except ArgumentException:
Errln("remove	" + other + "	failed: " + e.ToString + "
" + me)
me.Clear
stayWithMe.Clear
              break
          of 3:
              other = GetRandomKey(rand)
Logln("remove	" + other)
stayWithMe.Remove(other)
              try:
me.Remove(other)
              except ArgumentException:
Errln("remove	" + other + "	failed: " + e.ToString + "
" + me)
me.Clear
stayWithMe.Clear
              break
          of 4:
              other = GetRandomKey(rand)
Logln("remove	" + other)
stayWithMe.Remove(other)
              try:
me.Remove(other)
              except ArgumentException:
Errln("remove	" + other + "	failed: " + e.ToString + "
" + me)
me.Clear
stayWithMe.Clear
              break
          of 5:
              other = GetRandomKey(rand)
Logln("remove	" + other)
stayWithMe.Remove(other)
              try:
me.Remove(other)
              except ArgumentException:
Errln("remove	" + other + "	failed: " + e.ToString + "
" + me)
me.Clear
stayWithMe.Clear
              break
          of 6:
              other = GetRandomKey(rand)
Logln("remove	" + other)
stayWithMe.Remove(other)
              try:
me.Remove(other)
              except ArgumentException:
Errln("remove	" + other + "	failed: " + e.ToString + "
" + me)
me.Clear
stayWithMe.Clear
              break
          of 7:
              other = GetRandomKey(rand)
Logln("remove	" + other)
stayWithMe.Remove(other)
              try:
me.Remove(other)
              except ArgumentException:
Errln("remove	" + other + "	failed: " + e.ToString + "
" + me)
me.Clear
stayWithMe.Clear
              break
          of 8:
              other = GetRandomKey(rand)
Logln("remove	" + other)
stayWithMe.Remove(other)
              try:
me.Remove(other)
              except ArgumentException:
Errln("remove	" + other + "	failed: " + e.ToString + "
" + me)
me.Clear
stayWithMe.Clear
              break
          else:
              other = GetRandomKey(rand)
              value = Integer(rand.Next(50) + 50)
Logln("put	" + other + " = " + value)
              stayWithMe[other] = value
me.Put(other, value)
              break
checkEquals(me, stayWithMe)
++i
proc fillRandomMap(rand: Random, max: int, test: JCG.SortedDictionary<String, Integer>): JCG.SortedDictionary<String, Integer> =
test.Clear
    max = rand.Next(max)
      var i: int = 0
      while i < max:
          test[GetRandomKey(rand)] = Integer(rand.Next(50) + 50)
++i
    return test
proc checkEquals(me: UnicodeMap[Integer], stayWithMe: JCG.SortedDictionary<String, Integer>) =
temp.Clear
    for e in me.EntrySet:
temp.Add(e)
    var entrySet: ISet<KeyValuePair<String, Integer>> = JCG.HashSet<KeyValuePair<string, Integer>>(stayWithMe)
    if !entrySet.SetEquals(temp):
Logln(me.EntrySet.ToString)
Logln(me.ToString)
assertEquals("are in parallel", entrySet, temp)
entrySet.Clear
temp.Clear
        return
    for pair in stayWithMe:
assertEquals("containsKey", stayWithMe.ContainsKey(pair.Key), me.ContainsKey(pair.Key))
        var value: Integer = pair.Value
assertEquals("get", value, me.Get(pair.Key))
assertEquals("containsValue", stayWithMe.ContainsValue(value), me.ContainsValue(value))
        var cp: int = UnicodeSet.GetSingleCodePoint(pair.Key)
        if cp != int.MaxValue:
assertEquals("get", value, me.Get(cp))
    var values: ISet<Integer> = JCG.SortedSet<Integer>(stayWithMe.Values)
    var myValues: ISet<Integer> = JCG.SortedSet<Integer>(me.Values)
assertEquals("values", myValues, values)
    for key in stayWithMe.Keys:
assertEquals("containsKey", stayWithMe.ContainsKey(key), me.ContainsKey(key))
type
  OneFirstComparer = ref object


proc Compare*(o1: string, o2: string): int =
    var cp1: int = UnicodeSet.GetSingleCodePoint(o1)
    var cp2: int = UnicodeSet.GetSingleCodePoint(o2)
    var result: int = cp1 - cp2
    if result != 0:
        return result
    if cp1 == int.MaxValue:
        return o1.CompareToOrdinal(o2)
    return 0
proc GetRandomKey(rand: Random): String =
    var r: int = rand.Next(30)
    if r == 0:
        return UTF16.ValueOf(r)

    elif r < 10:
        return UTF16.ValueOf('A' - 1 + r)
    else:
      if r < 20:
          return UTF16.ValueOf(1114111 - r - 10)
    return "a" + UTF16.ValueOf(r + 'a' - 1)
proc TestModify*() =
    var random: Random = Random(0)
    var unicodeMap: UnicodeMap<string> = UnicodeMap<string>
    var hashMap: JCG.Dictionary<int, string> = JCG.Dictionary<int, string>
    var values: String[] = @[nil, "the", "quick", "brown", "fox"]
      var count: int = 1
      while count <= MODIFY_TEST_ITERATIONS:
          var value: String = values[random.Next(values.Length)]
          var start: int = random.Next(MODIFY_TEST_LIMIT)
          var end: int = random.Next(MODIFY_TEST_LIMIT)
          if start > end:
              var temp: int = start
              start = end
              end = temp
          var modCount: int = count & 255
          if modCount == 0 && IsVerbose:
Logln("***" + count)
Logln(unicodeMap.ToString)
unicodeMap.PutAll(start, end, value)
          if modCount == 1 && IsVerbose:
Logln(">>>	" + Utility.Hex(start) + ".." + Utility.Hex(end) + "	" + value)
Logln(unicodeMap.ToString)
            var i: int = start
            while i <= end:
                hashMap[i] = value
++i
          if !hasSameValues(unicodeMap, hashMap):
Errln("Failed at " + count)
++count
proc hasSameValues(unicodeMap: UnicodeMap[string], hashMap: IDictionary[int, string]): bool =
      var i: int = 0
      while i < MODIFY_TEST_LIMIT:
          var unicodeMapValue: string = unicodeMap.GetValue(i)
hashMap.TryGetValue(i,           var hashMapValue: string)
          if unicodeMapValue != hashMapValue:
              return false
++i
    return true
proc TestCloneAsThawed11721*() =
    var test: UnicodeMap<Integer> = UnicodeMap<Integer>.Put("abc", 3).Freeze
    var copy: UnicodeMap<Integer> = test.CloneAsThawed
copy.Put("def", 4)
assertEquals("original-abc", Integer(3), test.Get("abc"))
assertNull("original-def", test.Get("def"))
assertEquals("copy-def", Integer(4), copy.Get("def"))
proc TestUnicodeMapRandom*() =
    var random = Random(12345)
Logln("Comparing against HashMap")
    var map1: UnicodeMap<string> = UnicodeMap<string>
    var map2: IDictionary<int, string> = JCG.Dictionary<int, string>
      var counter: int = 0
      while counter < ITERATIONS:
          var start: int = random.Next(LIMIT)
          var value: string = TEST_VALUES[random.Next(TEST_VALUES.Length)]
          var logline: string = Utility.Hex(start) + "	" + value
          if SHOW_PROGRESS:
Logln(counter + "	" + logline)
log.Add(logline)
          if DEBUG && counter == 144:
Console.Out.WriteLine(" debug")
map1.Put(start, value)
          map2[start] = value
check(map1, map2, counter)
++counter
checkNext(map1, map2, LIMIT)
proc TestUnicodeMapGeneralCategory*() =
Logln("Setting General Category")
    var map1: UnicodeMap<string> = UnicodeMap<string>
    var map2: IDictionary<int, string> = JCG.Dictionary<int, string>
    map1 = UnicodeMap<string>
    map2 = JCG.SortedDictionary<int, string>
      var cp: int = 0
      while cp <= SET_LIMIT:
          var enumValue: int = UChar.GetIntPropertyValue(cp, propEnum)
          var value: String = UChar.GetPropertyValueName(propEnum, enumValue, NameChoice.Long)
map1.Put(cp, value)
          map2[Integer(cp)] = value
++cp
checkNext(map1, map2, int.MaxValue)
Logln("Comparing General Category")
check(map1, map2, -1)
Logln("Comparing Values")
    var values1: ISet<string> = JCG.SortedSet<string>(StringComparer.Ordinal)
map1.GetAvailableValues(values1)
    var values2: ISet<string> = JCG.SortedSet<string>(map2.Values.Distinct, StringComparer.Ordinal)
    if !TestBoilerplate[string].VerifySetsIdentical(self, values1, values2):
        raise ArgumentException("Halting")
Logln("Comparing Sets")
    for value in values1:
Logln(        if value == nil:
"null"
        else:
value)
        var set1: UnicodeSet = map1.KeySet(value)
        var set2: UnicodeSet = TestBoilerplate[string].GetSet(map2, value)
        if !TestBoilerplate[string].VerifySetsIdentical(self, set1, set2):
            raise ArgumentException("Halting")
proc TestAUnicodeMap2*() =
    var foo: UnicodeMap<object> = UnicodeMap<object>
    var hash: int = foo.GetHashCode
    var fii = foo.StringKeys
type
  Char = ref object
    value: char

proc newChar(value: char): Char =
  self.value = value
proc CompareTo*(other: Char): int =
    return value.CompareTo(other.value)
proc Equals*(other: Char): bool =
    return value.Equals(other.value)
proc Equals*(obj: object): bool =
    if obj:
      return value.Equals(c1.value)
    if obj:
      return value.Equals(c2)
    return false
proc GetHashCode*(): int =
    return value.GetHashCode
proc toChar(value: Char): char =
    return c.value
proc toChar(value: char): Char =
    return Char(c)
proc TestAUnicodeMapInverse*() =
    var foo1: UnicodeMap<Char> = UnicodeMap<Char>.PutAll('a', 'z', 'b').Put("ab", 'c').Put('x', 'b').Put("xy", 'c')
    var target: IDictionary<Char, UnicodeSet> = JCG.Dictionary<Char, UnicodeSet>
foo1.AddInverseTo(target)
    var reverse: UnicodeMap<Char> = UnicodeMap<Char>.PutAllInverse(target)
assertEquals("", foo1, reverse)
proc checkNext(map1: UnicodeMap[string], map2: IDictionary[int, string], limit: int) =
Logln("Comparing nextRange")
    var localMap: IDictionary<int, string> = JCG.SortedDictionary<int, string>
    var mi: UnicodeMapIterator<string> = UnicodeMapIterator<string>(map1)
    while mi.NextRange:
Logln(Utility.Hex(mi.Codepoint) + ".." + Utility.Hex(mi.CodepointEnd) + " => " + mi.Value)
          var i: int = mi.Codepoint
          while i <= mi.CodepointEnd:
              localMap[i] = mi.Value
++i
checkMap(map2, localMap)
Logln("Comparing next")
mi.Reset
    localMap = JCG.SortedDictionary<int, string>
    while mi.Next:
        localMap[mi.Codepoint] = mi.Value
checkMap(map2, localMap)
proc check*(map1: UnicodeMap[string], map2: IDictionary[int, string], counter: int) =
      var i: int = 0
      while i < LIMIT:
          var value1: string = map1.GetValue(i)
map2.TryGetValue(i,           var value2: string)
          if !UnicodeMap[string].AreEqual(value1, value2):
Errln(counter + " Difference at " + Utility.Hex(i) + "	 UnicodeMap: " + value1 + "	 HashMap: " + value2)
Errln("UnicodeMap: " + map1)
Errln("Log: " + TestBoilerplate[string].Show(log))
Errln("HashMap: " + TestBoilerplate[string].Show(map2))
++i
proc checkMap(m1: IDictionary[int, string], m2: IDictionary[int, string]) =
    if DictionaryEqualityComparer[int, string].Default.Equals(m1, m2):
      return
    var buffer: StringBuilder = StringBuilder
    var m1entries: ICollection<KeyValuePair<int, string>> = m1
    var m2entries: ICollection<KeyValuePair<int, string>> = m2
getEntries("
In First, and not Second", m1entries, m2entries, buffer, 20)
getEntries("
In Second, and not First", m2entries, m1entries, buffer, 20)
Errln(buffer.ToString)
type
  EntryComparer = ref object


proc Compare*(o1: KeyValuePair[int, string], o2: KeyValuePair[int, string]): int =
    var a = o1
    var b = o2
    var result: int = CompareInteger(a.Key, b.Key)
    if result != 0:
      return result
    return CompareString(a.Value, b.Value)
proc CompareString(o1: string, o2: string): int =
    if o1 == o2:
      return 0
    if o1 == nil:
      return -1
    if o2 == nil:
      return 1
    return o1.CompareToOrdinal(o2)
proc CompareInteger(o1: int, o2: int): int =
    if o1 == o2:
      return 0
    return o1.CompareTo(o2)
proc getEntries(title: string, m1entries: ICollection[KeyValuePair<int, string>], m2entries: ICollection[KeyValuePair<int, string>], buffer: StringBuilder, limit: int) =
    var m1_m2: ISet<KeyValuePair<int, string>> = JCG.SortedSet<KeyValuePair<int, string>>(ENTRY_COMPARATOR)
m1_m2.UnionWith(m1entries)
m1_m2.ExceptWith(m2entries)
buffer.Append(title + ": " + m1_m2.Count + "
")
    for entry in m1_m2:
        if --limit < 0:
          return
buffer.Append(entry.Key).Append(" => ").Append(entry.Value).Append("
")