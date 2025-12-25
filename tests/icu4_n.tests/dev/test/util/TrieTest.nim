# "Namespace: ICU4N.Dev.Test.Util"
type
  TrieTest = ref object
    setRanges1: seq[SetRange] = @[SetRange(0, 32, 0, false), SetRange(32, 167, 4660, false), SetRange(167, 13312, 0, false), SetRange(13312, 40870, 24930, false), SetRange(40870, 55966, 12594, false), SetRange(56026, 61166, 34815, false), SetRange(61166, 69905, 1, false), SetRange(69905, 279620, 24930, false), SetRange(279620, 393219, 0, false), SetRange(983043, 983044, 15, false), SetRange(983044, 983046, 16, false), SetRange(983046, 983047, 17, false), SetRange(983047, 983072, 18, false), SetRange(983072, 1114112, 0, false)]
    checkRanges1: seq[CheckRange] = @[CheckRange(0, 0), CheckRange(32, 0), CheckRange(167, 4660), CheckRange(13312, 0), CheckRange(40870, 24930), CheckRange(55966, 12594), CheckRange(56026, 0), CheckRange(61166, 34815), CheckRange(69905, 1), CheckRange(279620, 24930), CheckRange(983043, 0), CheckRange(983044, 15), CheckRange(983046, 16), CheckRange(983047, 17), CheckRange(983072, 18), CheckRange(1114112, 0)]
    setRanges2: seq[SetRange] = @[SetRange(33, 127, 21845, true), SetRange(194560, 196316, 122, true), SetRange(114, 221, 3, true), SetRange(221, 222, 4, false), SetRange(194951, 195224, 5, true), SetRange(194423, 194611, 0, true), SetRange(194816, 196590, 1, false), SetRange(196590, 196591, 2, true)]
    checkRanges2: seq[CheckRange] = @[CheckRange(0, 0), CheckRange(33, 0), CheckRange(114, 21845), CheckRange(221, 3), CheckRange(222, 4), CheckRange(194611, 0), CheckRange(194951, 122), CheckRange(195224, 5), CheckRange(196316, 122), CheckRange(196590, 1), CheckRange(196591, 2), CheckRange(1114112, 0)]
    setRanges3: seq[SetRange] = @[SetRange(49, 164, 1, false), SetRange(13312, 26505, 2, false), SetRange(196608, 214375, 9, true), SetRange(284280, 354185, 3, true)]
    checkRanges3: seq[CheckRange] = @[CheckRange(0, 9), CheckRange(49, 9), CheckRange(164, 1), CheckRange(13312, 9), CheckRange(26505, 2), CheckRange(284280, 9), CheckRange(354185, 3), CheckRange(1114112, 9)]

proc newTrieTest(): TrieTest =

type
  SetRange = ref object
    start: int
    value: int
    overwrite: bool

proc newSetRange(start: int, limit: int, value: int, overwrite: bool): SetRange =
  self.start = start
  self.limit = limit
  self.value = value
  self.overwrite = overwrite
type
  CheckRange = ref object
    Limit: int
    Value: int

proc newCheckRange(limit: int, value: int): CheckRange =
  self.Limit = limit
  self.Value = value
type
  _testFoldedValue = ref object
    m_builder_: Int32TrieBuilder

proc new_testFoldedValue(builder: Int32TrieBuilder): _testFoldedValue =
  m_builder_ = builder
proc GetFoldedValue*(start: int, offset: int): int =
    var foldedValue: int = 0
    var limit: int = start + 1024
    while start < limit:
        var value: int = m_builder_.GetValue(start)
        if m_builder_.IsInZeroBlock(start):
            start = TrieBuilder.DataBlockLength
        else:
            foldedValue = value
++start
    if foldedValue != 0:
        return offset << 16 | foldedValue
    return 0
type
  _testFoldingOffset = ref object


proc GetFoldingOffset*(value: int): int =
    return value >>> 16
type
  _testEnumValue = ref object


proc new_testEnumValue(data: Trie): _testEnumValue =
newTrieEnumerator(data)
proc Extract(value: int): int =
    return value ^ 21845
proc _testTrieIteration(trie: Int32Trie, checkRanges: seq[CheckRange], countCheckRanges: int) =
    var countValues: int = 0
    var s: OpenStringBuilder = OpenStringBuilder
    var values: int[] = seq[int]
      var i: int = 0
      while i < countCheckRanges:
          var c: int = checkRanges[i].Limit
          if c != 0:
--c
s.AppendCodePoint(c)
              values[++countValues] = checkRanges[i].Value
++i
      var limit: int = s.Length
      var p: int = 0
      var i: int = 0
      while p < limit:
          var c: int = UTF16.CharAt(s.AsSpan, p)
          p = UTF16.GetCharCount(c)
          var value: int = trie.GetCodePointValue(c)
          if value != values[i]:
Errln("wrong value from UTRIE_NEXT(U+" + c.ToHexString + "): 0x" + value.ToHexString + " instead of 0x" + values[i].ToHexString)
          var lead: char = UTF16.GetLeadSurrogate(c)
          var trail: char = UTF16.GetTrailSurrogate(c)
          if           if lead == 0:
trail != s[p - 1]
          else:
!UTF16.IsLeadSurrogate(lead) || !UTF16.IsTrailSurrogate(trail) || lead != s[p - 2] || trail != s[p - 1]:
Errln("wrong (lead, trail) from UTRIE_NEXT(U+" + c.ToHexString)
              continue
          if lead != 0:
              value = trie.GetLeadValue(lead)
              value = trie.GetTrailValue(value, trail)
              if value != trie.GetSurrogateValue(lead, trail) && value != values[i]:
Errln("wrong value from getting supplementary " + "values (U+" + c.ToHexString + "): 0x" + value.ToHexString + " instead of 0x" + values[i].ToHexString)
++i
proc _testTrieRanges(setRanges: seq[SetRange], countSetRanges: int, checkRanges: seq[CheckRange], countCheckRanges: int, latin1Linear: bool) =
    var newTrie: Int32TrieBuilder = Int32TrieBuilder(nil, 2000, checkRanges[0].Value, checkRanges[0].Value, latin1Linear)
    var ok: bool = true
      var i: int = 0
      while i < countSetRanges:
          var start: int = setRanges[i].start
          var limit: int = setRanges[i].limit
          var value: int = setRanges[i].value
          var overwrite: bool = setRanges[i].overwrite
          if limit - start == 1 && overwrite:
              ok = newTrie.SetValue(start, value)
          else:
              ok = newTrie.SetRange(start, limit, value, overwrite)
++i
    if !ok:
Errln("setting values into a trie failed")
        return
      var start: int = 0
        var i: int = 0
        while i < countCheckRanges:
            var limit: int = checkRanges[i].Limit
            var value: int = checkRanges[i].Value
            while start < limit:
                if value != newTrie.GetValue(start):
Errln("newTrie [U+" + start.ToHexString + "]==0x" + newTrie.GetValue(start).ToHexString + " instead of 0x" + value.ToHexString)
++start
++i
      var trie: Int32Trie = newTrie.Serialize(_testFoldedValue(newTrie), _testFoldingOffset)
      if latin1Linear:
          start = 0
            var i: int = 0
            while i < countCheckRanges && start <= 255:
                var limit: int = checkRanges[i].Limit
                var value: int = checkRanges[i].Value
                while start < limit && start <= 255:
                    if value != trie.GetLatin1LinearValue(cast[char](start)):
Errln("IntTrie.getLatin1LinearValue[U+" + start.ToHexString + "]==0x" + trie.GetLatin1LinearValue(cast[char](start)).ToHexString + " instead of 0x" + value.ToHexString)
++start
++i
      if latin1Linear != trie.IsLatin1Linear:
Errln("trie serialization did not preserve " + "Latin-1-linearity")
      start = 0
        var i: int = 0
        while i < countCheckRanges:
            var limit: int = checkRanges[i].Limit
            var value: int = checkRanges[i].Value
            if start == 55296:
                start = limit
                continue
            while start < limit:
                if start <= 65535:
                    var value2: int = trie.GetBMPValue(cast[char](start))
                    if value != value2:
Errln("serialized trie.getBMPValue(U+" + start.ToHexString + " == 0x" + value2.ToHexString + " instead of 0x" + value.ToHexString)
                    if !UTF16.IsLeadSurrogate(cast[char](start)):
                        value2 = trie.GetLeadValue(cast[char](start))
                        if value != value2:
Errln("serialized trie.getLeadValue(U+" + start.ToHexString + " == 0x" + value2.ToHexString + " instead of 0x" + value.ToHexString)
                  var value2: int = trie.GetCodePointValue(start)
                  if value != value2:
Errln("serialized trie.getCodePointValue(U+" + start.ToHexString + ")==0x" + value2.ToHexString + " instead of 0x" + value.ToHexString)
++start
++i
      var enumRanges: int = 1
      var iter: TrieEnumerator = _testEnumValue(trie)
      while iter.MoveNext:
          var result: RangeValueEnumeratorElement = iter.Current
          if result.Start != checkRanges[enumRanges - 1].Limit || result.Limit != checkRanges[enumRanges].Limit || result.Value ^ 21845 != checkRanges[enumRanges].Value:
Errln("utrie_enum() delivers wrong range [U+" + result.Start.ToHexString + "..U+" + result.Limit.ToHexString + "].0x" + result.Value ^ 21845.ToHexString + " instead of [U+" + checkRanges[enumRanges - 1].Limit.ToHexString + "..U+" + checkRanges[enumRanges].Limit.ToHexString + "].0x" + checkRanges[enumRanges].Value.ToHexString)
++enumRanges
      if trie.IsLatin1Linear:
            start = 0
            while start < 256:
                if trie.GetLatin1LinearValue(cast[char](start)) != trie.GetLeadValue(cast[char](start)):
Errln("trie.getLatin1LinearValue[U+" + start.ToHexString + "]=0x" + trie.GetLatin1LinearValue(cast[char](start)).ToHexString + " instead of 0x" + trie.GetLeadValue(cast[char](start)).ToHexString)
++start
_testTrieIteration(trie, checkRanges, countCheckRanges)
proc _testTrieRanges2(setRanges: seq[SetRange], countSetRanges: int, checkRanges: seq[CheckRange], countCheckRanges: int) =
_testTrieRanges(setRanges, countSetRanges, checkRanges, countCheckRanges, false)
_testTrieRanges(setRanges, countSetRanges, checkRanges, countCheckRanges, true)
proc _testTrieRanges4(setRanges: seq[SetRange], countSetRanges: int, checkRanges: seq[CheckRange], countCheckRanges: int) =
_testTrieRanges2(setRanges, countSetRanges, checkRanges, countCheckRanges)
proc TestIntTrie*() =
_testTrieRanges4(setRanges1, setRanges1.Length, checkRanges1, checkRanges1.Length)
_testTrieRanges4(setRanges2, setRanges2.Length, checkRanges2, checkRanges2.Length)
_testTrieRanges4(setRanges3, setRanges3.Length, checkRanges3, checkRanges3.Length)
type
  DummyGetFoldingOffset = ref object


proc GetFoldingOffset*(value: int): int =
    return -1
proc TestDummyCharTrie*() =
    var trie: CharTrie
      var initialValue: int = 787
      var leadUnitValue: int = 45054
    var value: int
    var c: int
    trie = CharTrie(initialValue, leadUnitValue, DummyGetFoldingOffset)
      c = 0
      while c <= 1114111:
          value = trie.GetCodePointValue(c)
          if value != initialValue:
Errln("CharTrie/dummy.getCodePointValue(c)(U+" + Hex(c) + ")=0x" + Hex(value) + " instead of 0x" + Hex(initialValue))
++c
      c = 55296
      while c <= 56319:
          value = trie.GetLeadValue(cast[char](c))
          if value != leadUnitValue:
Errln("CharTrie/dummy.getLeadValue(c)(U+" + Hex(c) + ")=0x" + Hex(value) + " instead of 0x" + Hex(leadUnitValue))
++c
proc TestDummyIntTrie*() =
    var trie: Int32Trie
      var initialValue: int = 19088743
      var leadUnitValue: int = cast[int](2309737967)
    var value: int
    var c: int
    trie = Int32Trie(initialValue, leadUnitValue, DummyGetFoldingOffset)
      c = 0
      while c <= 1114111:
          value = trie.GetCodePointValue(c)
          if value != initialValue:
Errln("IntTrie/dummy.getCodePointValue(c)(U+" + Hex(c) + ")=0x" + Hex(value) + " instead of 0x" + Hex(initialValue))
++c
      c = 55296
      while c <= 56319:
          value = trie.GetLeadValue(cast[char](c))
          if value != leadUnitValue:
Errln("IntTrie/dummy.getLeadValue(c)(U+" + Hex(c) + ")=0x" + Hex(value) + " instead of 0x" + Hex(leadUnitValue))
++c