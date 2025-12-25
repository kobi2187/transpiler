# "Namespace: ICU4N.Dev.Test.Util"
type
  Trie2Test = ref object
    trieNames: seq[String] = @["setRanges1", "setRanges2", "setRanges3", "setRangesEmpty", "setRangesSingleValue"]
    setRanges1: seq[int] = @[@[0, 0, 0, 0], @[0, 64, 0, 0], @[64, 231, 4660, 0], @[231, 13312, 0, 0], @[13312, 40870, 24930, 0], @[40870, 55966, 12594, 0], @[56026, 61166, 34815, 0], @[61166, 69905, 1, 0], @[69905, 279620, 24930, 0], @[279620, 393219, 0, 0], @[983043, 983044, 15, 0], @[983044, 983046, 16, 0], @[983046, 983047, 17, 0], @[983047, 983104, 18, 0], @[983104, 1114112, 0, 0]]
    checkRanges1: seq[int] = @[@[0, 0], @[64, 0], @[231, 4660], @[13312, 0], @[40870, 24930], @[55966, 12594], @[56026, 0], @[61166, 34815], @[69905, 1], @[279620, 24930], @[983043, 0], @[983044, 15], @[983046, 16], @[983047, 17], @[983104, 18], @[1114112, 0]]
    setRanges2: seq[int] = @[@[0, 0, 0, 0], @[33, 127, 21845, 1], @[194560, 196316, 122, 1], @[114, 221, 3, 1], @[221, 222, 4, 0], @[513, 576, 6, 1], @[577, 640, 6, 1], @[641, 704, 6, 1], @[194951, 195224, 5, 1], @[194423, 194691, 0, 1], @[194816, 196522, 1, 0], @[196522, 196523, 2, 1], @[196539, 196544, 7, 1]]
    checkRanges2: seq[int] = @[@[0, 0], @[33, 0], @[114, 21845], @[221, 3], @[222, 4], @[513, 0], @[576, 6], @[577, 0], @[640, 6], @[641, 0], @[704, 6], @[194691, 0], @[194951, 122], @[195224, 5], @[196316, 122], @[196522, 1], @[196523, 2], @[196539, 0], @[196544, 7], @[1114112, 0]]
    setRanges3: seq[int] = @[@[0, 0, 9, 0], @[49, 164, 1, 0], @[13312, 26505, 2, 0], @[32768, 35243, 9, 1], @[36864, 40960, 4, 1], @[43981, 48350, 3, 1], @[349525, 1114112, 6, 1], @[52428, 349525, 6, 1]]
    checkRanges3: seq[int] = @[@[0, 9], @[49, 9], @[164, 1], @[13312, 9], @[26505, 2], @[36864, 9], @[40960, 4], @[43981, 9], @[48350, 3], @[52428, 9], @[1114112, 6]]
    setRangesEmpty: seq[int] = @[@[0, 0, 3, 0]]
    checkRangesEmpty: seq[int] = @[@[0, 3], @[1114112, 3]]
    setRangesSingleValue: seq[int] = @[@[0, 0, 3, 0], @[0, 1114112, 5, 1]]
    checkRangesSingleValue: seq[int] = @[@[0, 3], @[1114112, 5]]

proc newTrie2Test(): Trie2Test =

type
  Trie2ValueMapper = ref object
    map: Func[int, int]

proc newTrie2ValueMapper(map: Func[int, int]): Trie2ValueMapper =
  self.map = map
proc Map*(v: int): int =
    return map(v)
proc TestTrie2API*() =
    try:
        var trie: Trie2Writable = Trie2Writable(0, 0)
        var os: MemoryStream = MemoryStream
trie.ToTrie2_16.Serialize(os)
        var @is: MemoryStream = MemoryStream(os.ToArray)
assertEquals(nil, 2, Trie2.GetVersion(@is, true))
    except IOException:
Errln(where + e.ToString)
      var trieWA: Trie2Writable = Trie2Writable(0, 0)
      var trieWB: Trie2Writable = Trie2Writable(0, 0)
      var trieA: Trie2 = trieWA
      var trieB: Trie2 = trieWB
assertTrue("", trieA.Equals(trieB))
assertEquals("", trieA, trieB)
assertEquals("", trieA.GetHashCode, trieB.GetHashCode)
trieWA.Set(500, 2)
assertNotEquals("", trieA, trieB)
assertNotEquals("", trieA.GetHashCode, trieB.GetHashCode)
trieWB.Set(500, 2)
      trieA = trieWA.ToTrie2_16
assertEquals("", trieA, trieB)
assertEquals("", trieA.GetHashCode, trieB.GetHashCode)
      var trie: Trie2Writable = Trie2Writable(17, 0)
      var it: IEnumerator<Trie2Range>
        let resource =         it = trie.GetEnumerator
<unhandled: nnkDefer>
it.MoveNext
        var r: Trie2Range = it.Current
assertEquals("", 0, r.StartCodePoint)
assertEquals("", 1114111, r.EndCodePoint)
assertEquals("", 17, r.Value)
assertEquals("", false, r.IsLeadSurrogate)
it.MoveNext
        r = it.Current
assertEquals("", 55296, r.StartCodePoint)
assertEquals("", 56319, r.EndCodePoint)
assertEquals("", 17, r.Value)
assertEquals("", true, r.IsLeadSurrogate)
        var i: int = 0
        for rr in trie:
            case i
            of 0:
assertEquals("", 0, rr.StartCodePoint)
assertEquals("", 1114111, rr.EndCodePoint)
assertEquals("", 17, rr.Value)
assertEquals("", false, rr.IsLeadSurrogate)
                break
            of 1:
assertEquals("", 55296, rr.StartCodePoint)
assertEquals("", 56319, rr.EndCodePoint)
assertEquals("", 17, rr.Value)
assertEquals("", true, rr.IsLeadSurrogate)
                break
            else:
Errln(where + " Unexpected iteration result")
                break
++i
      var trie: Trie2Writable = Trie2Writable(195952365, 0)
trie.Set(65827, 42)
      var vm: IValueMapper = Trie2ValueMapper(<unhandled: nnkLambda>)
        let it2 = trie.GetEnumerator(vm)
<unhandled: nnkDefer>
it2.MoveNext
        var r: Trie2Range = it2.Current
assertEquals("", 0, r.StartCodePoint)
assertEquals("", 1114111, r.EndCodePoint)
assertEquals("", 42, r.Value)
assertEquals("", false, r.IsLeadSurrogate)
      var trie: Trie2Writable = Trie2Writable(14613015, 0)
trie.Set(194576, 10)
        let it = trie.GetEnumeratorForLeadSurrogate(cast[char](55422))
<unhandled: nnkDefer>
it.MoveNext
        var r: Trie2Range = it.Current
assertEquals("", 194560, r.StartCodePoint)
assertEquals("", 194575, r.EndCodePoint)
assertEquals("", 14613015, r.Value)
assertEquals("", false, r.IsLeadSurrogate)
it.MoveNext
        r = it.Current
assertEquals("", 194576, r.StartCodePoint)
assertEquals("", 194576, r.EndCodePoint)
assertEquals("", 10, r.Value)
assertEquals("", false, r.IsLeadSurrogate)
it.MoveNext
        r = it.Current
assertEquals("", 194577, r.StartCodePoint)
assertEquals("", 195583, r.EndCodePoint)
assertEquals("", 14613015, r.Value)
assertEquals("", false, r.IsLeadSurrogate)
assertFalse("", it.MoveNext)
      var trie: Trie2Writable = Trie2Writable(14613015, 0)
trie.Set(194576, 10)
      var m: IValueMapper = Trie2ValueMapper(<unhandled: nnkLambda>)
        let it = trie.GetEnumeratorForLeadSurrogate(cast[char](55422), m)
<unhandled: nnkDefer>
it.MoveNext
        var r: Trie2Range = it.Current
assertEquals("", 194560, r.StartCodePoint)
assertEquals("", 195583, r.EndCodePoint)
assertEquals("", 14613015, r.Value)
assertEquals("", false, r.IsLeadSurrogate)
assertFalse("", it.MoveNext)
      var trie: Trie2Writable = Trie2Writable(101, 0)
trie.SetRange(61440, 245760, 200, true)
trie.Set(65518, 300)
      var frozen16: Trie2_16 = trie.ToTrie2_16
      var frozen32: Trie2_32 = trie.ToTrie2_32
assertEquals("", trie, frozen16)
assertEquals("", trie, frozen32)
assertEquals("", frozen16, frozen32)
      var os: MemoryStream = MemoryStream
      try:
frozen16.Serialize(os)
          var unserialized16: Trie2 = Trie2.CreateFromSerialized(ByteBuffer.Wrap(os.ToArray))
assertEquals("", trie, unserialized16)
assertEquals("", type(Trie2_16), unserialized16.GetType)
os.Seek(0, SeekOrigin.Begin)
frozen32.Serialize(os)
          var unserialized32: Trie2 = Trie2.CreateFromSerialized(ByteBuffer.Wrap(os.ToArray))
assertEquals("", trie, unserialized32)
assertEquals("", type(Trie2_32), unserialized32.GetType)
      except IOException:
Errln(where + " Unexpected exception:  " + e)
proc TestTrie2WritableAPI*() =
    var t1: Trie2 = Trie2Writable(6, 666)
    var t2: Trie2 = Trie2Writable(t1)
assertTrue("", t1.Equals(t2))
    var t1w: Trie2Writable = Trie2Writable(10, 666)
t1w.Set(17767, 99)
assertEquals("", 10, t1w.Get(17766))
assertEquals("", 99, t1w.Get(17767))
assertEquals("", 666, t1w.Get(-1))
assertEquals("", 666, t1w.Get(1114112))
    t1w = Trie2Writable(10, 666)
t1w.SetRange(13, 6666, 7788, false)
t1w.SetRange(6000, 7000, 9900, true)
assertEquals("", 10, t1w.Get(12))
assertEquals("", 7788, t1w.Get(13))
assertEquals("", 7788, t1w.Get(5999))
assertEquals("", 9900, t1w.Get(6000))
assertEquals("", 9900, t1w.Get(7000))
assertEquals("", 10, t1w.Get(7001))
assertEquals("", 666, t1w.Get(1114112))
    var r: Trie2Range = Trie2Range
    r.StartCodePoint = 50
    r.EndCodePoint = 52
    r.Value = 305419896
    r.IsLeadSurrogate = false
    t1w = Trie2Writable(0, 2989)
t1w.SetRange(r, true)
assertEquals(nil, 0, t1w.Get(49))
assertEquals("", 305419896, t1w.Get(50))
assertEquals("", 305419896, t1w.Get(52))
assertEquals("", 0, t1w.Get(53))
    t1w = Trie2Writable(10, 2989)
assertEquals("", 10, t1w.GetFromU16SingleLead(cast[char](55297)))
t1w.SetForLeadSurrogateCodeUnit(cast[char](55297), 5000)
t1w.Set(55297, 6000)
assertEquals("", 5000, t1w.GetFromU16SingleLead(cast[char](55297)))
assertEquals("", 6000, t1w.Get(55297))
    t1w = Trie2Writable(10, 666)
t1w.Set(42, 5555)
t1w.Set(130816, 224)
    var t1_16: Trie2_16 = t1w.ToTrie2_16
assertTrue("", t1w.Equals(t1_16))
t1w.Set(152, 129)
    t1_16 = t1w.ToTrie2_16
assertTrue("", t1w.Equals(t1_16))
assertEquals("", 129, t1w.Get(152))
    t1w = Trie2Writable(10, 666)
t1w.Set(42, 5555)
t1w.Set(130816, 224)
    var t1_32: Trie2_32 = t1w.ToTrie2_32
assertTrue("", t1w.Equals(t1_32))
t1w.Set(152, 129)
assertNotEquals("", t1_32, t1w)
    t1_32 = t1w.ToTrie2_32
assertTrue("", t1w.Equals(t1_32))
assertEquals("", 129, t1w.Get(152))
    var os: MemoryStream = MemoryStream
    t1w = Trie2Writable(0, 2989)
t1w.Set(65, 256)
t1w.Set(194, 512)
t1w.Set(1028, 768)
t1w.Set(55555, 1280)
t1w.Set(56617, 1536)
t1w.Set(1070547, 1792)
t1w.SetForLeadSurrogateCodeUnit(cast[char](55834), 2048)
    try:
        var serializedLen: int = t1w.ToTrie2_16.Serialize(os)
assertEquals("", 3508, serializedLen)
        var t1ws16: Trie2 = Trie2.CreateFromSerialized(ByteBuffer.Wrap(os.ToArray))
assertEquals("", t1ws16.GetType, type(Trie2_16))
assertEquals("", t1w, t1ws16)
os.Seek(0, SeekOrigin.Begin)
        serializedLen = t1w.ToTrie2_32.Serialize(os)
assertEquals("", 4332, serializedLen)
        var t1ws32: Trie2 = Trie2.CreateFromSerialized(ByteBuffer.Wrap(os.ToArray))
assertEquals("", t1ws32.GetType, type(Trie2_32))
assertEquals("", t1w, t1ws32)
    except IOException:
Errln(where + e.ToString)
proc TestCharSequenceIterator*() =
    var text: String = "abc123𐀁 "
    var vals: String = "LLLNNNX?S"
    var tw: Trie2Writable = Trie2Writable(0, 666)
tw.SetRange('a', 'z', 'L', false)
tw.SetRange('1', '9', 'N', false)
tw.Set(' ', 'S')
tw.Set(65537, 'X')
    var it = tw.GetCharSequenceEnumerator(text, 0)
    var i: int
      i = 0
      while it.MoveNext:
          var expectedCP: int = Character.CodePointAt(text, i)
assertEquals("" + " i=" + i, expectedCP, it.CodePoint)
assertEquals("" + " i=" + i, i, it.Index)
assertEquals("" + " i=" + i, vals[i], it.Value)
          if expectedCP >= 65536:
++i
++i
assertEquals("", text.Length, i)
    it.Index = 5
      i = 5
      while it.MovePrevious:
          var expectedCP: int = Character.CodePointBefore(text, i)
          i =           if expectedCP < 65536:
1
          else:
2
assertEquals("" + " i=" + i, expectedCP, it.CodePoint)
assertEquals("" + " i=" + i, i, it.Index)
assertEquals("" + " i=" + i, vals[i], it.Value)
assertEquals("", 0, i)
      i = 3
      var expectedCP: int = Character.CodePointAt(text, i)
      it.Index = i
assertEquals("" + " i=" + i, expectedCP, it.CodePoint)
assertEquals("" + " i=" + i, i, it.Index)
assertEquals("" + " i=" + i, vals[i], it.Value)
      i = 1
      expectedCP = Character.CodePointAt(text, i)
      it.Index = i
assertEquals("" + " i=" + i, expectedCP, it.CodePoint)
assertEquals("" + " i=" + i, i, it.Index)
assertEquals("" + " i=" + i, vals[i], it.Value)
proc genTrieFromSetRanges(ranges: seq[int]): Trie2Writable =
    var i: int = 0
    var initialValue: int = 0
    var errorValue: int = 2989
    if ranges[i][1] < 0:
        errorValue = ranges[i][2]
++i
    initialValue = ranges[++i][2]
    var trie: Trie2Writable = Trie2Writable(initialValue, errorValue)
      while i < ranges.Length:
          var rangeStart: int = ranges[i][0]
          var rangeEnd: int = ranges[i][1] - 1
          var value: int = ranges[i][2]
          var overwrite: bool = ranges[i][3] != 0
trie.SetRange(rangeStart, rangeEnd, value, overwrite)
++i
trie.SetForLeadSurrogateCodeUnit(cast[char](55296), 90)
trie.SetForLeadSurrogateCodeUnit(cast[char](55705), 94)
trie.SetForLeadSurrogateCodeUnit(cast[char](56319), 99)
    return trie
proc trieGettersTest(testName: String, trie: Trie2, checkRanges: seq[int]) =
    var countCheckRanges: int = checkRanges.Length
      var initialValue: int
      var errorValue: int
      var value: int
      var value2: int
      var start: int
      var limit: int
      var i: int
      var countSpecials: int
    countSpecials = 0
    errorValue = 2989
    initialValue = 0
    if checkRanges[countSpecials][0] == 0:
        initialValue = checkRanges[countSpecials][1]
++countSpecials
    start = 0
      i = countSpecials
      while i < countCheckRanges:
          limit = checkRanges[i][0]
          value = checkRanges[i][1]
          while start < limit:
              value2 = trie.Get(start)
              if value != value2:
assertEquals("wrong value for " + testName + " of " + start.ToHexString, value, value2)
++start
++i
    if !testName.StartsWith("dummy", StringComparison.Ordinal) && !testName.StartsWith("trie1", StringComparison.Ordinal):
          start = 55295
          while start < 56321:
              case start
              of 55295:
                  value = trie.Get(start)
                  break
              of 56320:
                  value = trie.Get(start)
                  break
              of 55296:
                  value = 90
                  break
              of 55705:
                  value = 94
                  break
              of 56319:
                  value = 99
                  break
              else:
                  value = initialValue
                  break
              value2 = trie.GetFromU16SingleLead(cast[char](start))
              if value2 != value:
Errln(where + " testName: " + testName + " getFromU16SingleLead() failed." + "char, exected, actual = " + start.ToHexString + ", " + value.ToHexString + ", " + value2.ToHexString)
++start
    value = trie.Get(-1)
    value2 = trie.Get(1114112)
    if value != errorValue || value2 != errorValue:
Errln("trie2.Get() error value test.  Expected, actual1, actual2 = " + errorValue + ", " + value + ", " + value2)
    for range in trie:
          var cp: int = range.StartCodePoint
          while cp <= range.EndCodePoint:
              if range.IsLeadSurrogate:
assertTrue(testName, cp >= cast[char](55296) && cp < cast[char](56320))
assertEquals(testName, range.Value, trie.GetFromU16SingleLead(cast[char](cp)))
              else:
assertEquals(testName, range.Value, trie.Get(cp))
++cp
proc checkTrieRanges(testName: String, serializedName: String, withClone: bool, setRanges: seq[int], checkRanges: seq[int]) =
    var ns: string = type(Trie2Test).Namespace
    var fileName16: String = ns + ".Trie2Test." + serializedName + ".16.tri2"
    var fileName32: String = ns + ".Trie2Test." + serializedName + ".32.tri2"
    var assembly: Assembly = type(Trie2Test).Assembly
    var @is: Stream = assembly.GetManifestResourceStream(fileName16)
    var trie16: Trie2
    try:
        trie16 = Trie2.CreateFromSerialized(ICUBinary.GetByteBufferFromStreamAndDisposeStream(@is))
    finally:
@is.Dispose
trieGettersTest(testName, trie16, checkRanges)
    @is = assembly.GetManifestResourceStream(fileName32)
    var trie32: Trie2
    try:
        trie32 = Trie2.CreateFromSerialized(ICUBinary.GetByteBufferFromStreamAndDisposeStream(@is))
    finally:
@is.Dispose
trieGettersTest(testName, trie32, checkRanges)
    var trieW: Trie2Writable = genTrieFromSetRanges(setRanges)
trieGettersTest(testName, trieW, checkRanges)
assertEquals("", trieW, trie16)
assertEquals("", trieW, trie32)
    var trie32a: Trie2_32 = trieW.ToTrie2_32
trieGettersTest(testName, trie32a, checkRanges)
    var trie16a: Trie2_16 = trieW.ToTrie2_16
trieGettersTest(testName, trie16a, checkRanges)
proc TestRanges*() =
checkTrieRanges("set1", "setRanges1", false, setRanges1, checkRanges1)
checkTrieRanges("set2-overlap", "setRanges2", false, setRanges2, checkRanges2)
checkTrieRanges("set3-initial-9", "setRanges3", false, setRanges3, checkRanges3)
checkTrieRanges("set-empty", "setRangesEmpty", false, setRangesEmpty, checkRangesEmpty)
checkTrieRanges("set-single-value", "setRangesSingleValue", false, setRangesSingleValue, checkRangesSingleValue)
checkTrieRanges("set2-overlap.withClone", "setRanges2", true, setRanges2, checkRanges2)
proc where(): String =
    return string.Empty