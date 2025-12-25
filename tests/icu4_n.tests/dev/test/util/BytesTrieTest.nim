# "Namespace: ICU4N.Dev.Test.Util"
type
  BytesTrieTest = ref object
    builder_: BytesTrieBuilder = BytesTrieBuilder

proc newBytesTrieTest(): BytesTrieTest =

proc Test00Builder*() =
builder_.Clear
    try:
builder_.Build(TrieBuilderOption.Fast)
Errln("BytesTrieBuilder().build() did not throw IndexOutOfBoundsException")
        return
    except IndexOutOfRangeException:

    try:
        var equal: byte[] = @[61]
builder_.Add(equal, 1, 0).Add(equal, 1, 1)
Errln("BytesTrieBuilder.add() did not detect duplicates")
        return
    except ArgumentException:

type
  StringAndValue = ref object
    s: String
    bytes: seq[byte]
    value: int

proc newStringAndValue(str: String, val: int): StringAndValue =
  s = str
  bytes = seq[byte]
    var i: int = 0
    while i < bytes.Length:
        bytes[i] = cast[byte](s[i])
++i
  value = val
proc Test10Empty*() =
    var data: StringAndValue[] = @[StringAndValue("", 0)]
checkData(data)
proc Test11_a*() =
    var data: StringAndValue[] = @[StringAndValue("a", 1)]
checkData(data)
proc Test12_a_ab*() =
    var data: StringAndValue[] = @[StringAndValue("a", 1), StringAndValue("ab", 100)]
checkData(data)
proc Test20ShortestBranch*() =
    var data: StringAndValue[] = @[StringAndValue("a", 1000), StringAndValue("b", 2000)]
checkData(data)
proc Test21Branches*() =
    var data: StringAndValue[] = @[StringAndValue("a", 16), StringAndValue("cc", 64), StringAndValue("e", 256), StringAndValue("ggg", 1024), StringAndValue("i", 4096), StringAndValue("kkkk", 16384), StringAndValue("n", 65536), StringAndValue("ppppp", 262144), StringAndValue("r", 1048576), StringAndValue("sss", 2097152), StringAndValue("t", 4194304), StringAndValue("uu", 8388608), StringAndValue("vv", 2147483647), StringAndValue("zz", cast[int](2147483648))]
      var length: int = 2
      while length <= data.Length:
Logln("TestBranches length=" + length)
checkData(data, length)
++length
proc Test22LongSequence*() =
    var data: StringAndValue[] = @[StringAndValue("a", -1), StringAndValue("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", -2), StringAndValue("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" + "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" + "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" + "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" + "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" + "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", -3)]
checkData(data)
proc Test23LongBranch*() =
    var data: StringAndValue[] = @[StringAndValue("a", -2), StringAndValue("b", -1), StringAndValue("c", 0), StringAndValue("d2", 1), StringAndValue("f", 63), StringAndValue("g", 64), StringAndValue("h", 65), StringAndValue("j23", 6400), StringAndValue("j24", 6655), StringAndValue("j25", 6656), StringAndValue("k2", 6784), StringAndValue("k3", 6911), StringAndValue("l234567890", 6912), StringAndValue("l234567890123", 6913), StringAndValue("nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn", 1114111), StringAndValue("oooooooooooooooooooooooooooooooooooooooooooooooooooooo", 1114112), StringAndValue("pppppppppppppppppppppppppppppppppppppppppppppppppppppp", 1179648), StringAndValue("r", 3355443), StringAndValue("s2345", 71582788), StringAndValue("t234567890", 2004318071), StringAndValue("z", cast[int](2147483649))]
checkData(data)
proc Test24ValuesForState*() =
    var data: StringAndValue[] = @[StringAndValue("a", -1), StringAndValue("ab", -2), StringAndValue("abc", -3), StringAndValue("abcd", -4), StringAndValue("abcde", -5), StringAndValue("abcdef", -6)]
checkData(data)
proc Test30Compact*() =
    var data: StringAndValue[] = @[StringAndValue("+", 0), StringAndValue("+august", 8), StringAndValue("+december", 12), StringAndValue("+july", 7), StringAndValue("+june", 6), StringAndValue("+november", 11), StringAndValue("+october", 10), StringAndValue("+september", 9), StringAndValue("-", 0), StringAndValue("-august", 8), StringAndValue("-december", 12), StringAndValue("-july", 7), StringAndValue("-june", 6), StringAndValue("-november", 11), StringAndValue("-october", 10), StringAndValue("-september", 9), StringAndValue("xjuly", 7), StringAndValue("xjune", 6)]
checkData(data)
proc buildMonthsTrie*(buildOption: TrieBuilderOption): BytesTrie =
    var data: StringAndValue[] = @[StringAndValue("august", 8), StringAndValue("jan", 1), StringAndValue("jan.", 1), StringAndValue("jana", 1), StringAndValue("janbb", 1), StringAndValue("janc", 1), StringAndValue("janddd", 1), StringAndValue("janee", 1), StringAndValue("janef", 1), StringAndValue("janf", 1), StringAndValue("jangg", 1), StringAndValue("janh", 1), StringAndValue("janiiii", 1), StringAndValue("janj", 1), StringAndValue("jankk", 1), StringAndValue("jankl", 1), StringAndValue("jankmm", 1), StringAndValue("janl", 1), StringAndValue("janm", 1), StringAndValue("jannnnnnnnnnnnnnnnnnnnnnnnnnnnn", 1), StringAndValue("jano", 1), StringAndValue("janpp", 1), StringAndValue("janqqq", 1), StringAndValue("janr", 1), StringAndValue("januar", 1), StringAndValue("january", 1), StringAndValue("july", 7), StringAndValue("jun", 6), StringAndValue("jun.", 6), StringAndValue("june", 6)]
    return buildTrie(data, data.Length, buildOption)
proc Test40GetUniqueValue*() =
    var trie: BytesTrie = buildMonthsTrie(TrieBuilderOption.Fast)
    var uniqueValue: long
    if     uniqueValue = trie.GetUniqueValue != 0:
Errln("unique value at root")
trie.Next('j')
trie.Next('a')
trie.Next('n')
    if     uniqueValue = trie.GetUniqueValue != 1 << 1 | 1:
Errln("not unique value 1 after "jan": instead " + uniqueValue)
trie.First('j')
trie.Next('u')
    if     uniqueValue = trie.GetUniqueValue != 0:
Errln("unique value after "ju"")
    if trie.Next('n') != Result.IntermediateValue || 6 != trie.GetValue:
Errln("not normal value 6 after "jun"")
    if     uniqueValue = trie.GetUniqueValue != 6 << 1 | 1:
Errln("not unique value 6 after "jun"")
trie.First('a')
trie.Next('u')
    if     uniqueValue = trie.GetUniqueValue != 8 << 1 | 1:
Errln("not unique value 8 after "au"")
proc Test41GetNextBytes*() =
    var trie: BytesTrie = buildMonthsTrie(TrieBuilderOption.Small)
    var buffer: StringBuilder = StringBuilder
    var count: int = trie.GetNextBytes(buffer)
    if count != 2 || !"aj".ContentEquals(buffer):
Errln("months getNextBytes()!=[aj] at root")
trie.Next('j')
trie.Next('a')
trie.Next('n')
    buffer.Length = 0
    count = trie.GetNextBytes(buffer)
    if count != 20 || !".abcdefghijklmnopqru".ContentEquals(buffer):
Errln("months getNextBytes()!=[.abcdefghijklmnopqru] after "jan"")
trie.GetValue
    buffer.Length = 0
    count = trie.GetNextBytes(buffer)
    if count != 20 || !".abcdefghijklmnopqru".ContentEquals(buffer):
Errln("months getNextBytes()!=[.abcdefghijklmnopqru] after "jan"+getValue()")
trie.Next('u')
    buffer.Length = 0
    count = trie.GetNextBytes(buffer)
    if count != 1 || !"a".ContentEquals(buffer):
Errln("months getNextBytes()!=[a] after "janu"")
trie.Next('a')
    buffer.Length = 0
    count = trie.GetNextBytes(buffer)
    if count != 1 || !"r".ContentEquals(buffer):
Errln("months getNextBytes()!=[r] after "janua"")
trie.Next('r')
trie.Next('y')
    buffer.Length = 0
    count = trie.GetNextBytes(buffer)
    if count != 0 || buffer.Length != 0:
Errln("months getNextBytes()!=[] after "january"")
proc Test50IteratorFromBranch*() =
    var trie: BytesTrie = buildMonthsTrie(TrieBuilderOption.Fast)
trie.Next('j')
trie.Next('a')
trie.Next('n')
    var iter: BytesTrieEnumerator = cast[BytesTrieEnumerator](trie.GetEnumerator)
    var data: StringAndValue[] = @[StringAndValue("", 1), StringAndValue(".", 1), StringAndValue("a", 1), StringAndValue("bb", 1), StringAndValue("c", 1), StringAndValue("ddd", 1), StringAndValue("ee", 1), StringAndValue("ef", 1), StringAndValue("f", 1), StringAndValue("gg", 1), StringAndValue("h", 1), StringAndValue("iiii", 1), StringAndValue("j", 1), StringAndValue("kk", 1), StringAndValue("kl", 1), StringAndValue("kmm", 1), StringAndValue("l", 1), StringAndValue("m", 1), StringAndValue("nnnnnnnnnnnnnnnnnnnnnnnnnnnn", 1), StringAndValue("o", 1), StringAndValue("pp", 1), StringAndValue("qqq", 1), StringAndValue("r", 1), StringAndValue("uar", 1), StringAndValue("uary", 1)]
checkIterator(iter, data)
Logln("after iter.Reset()")
checkIterator(iter.Reset, data)
proc Test51IteratorFromLinearMatch*() =
    var trie: BytesTrie = buildMonthsTrie(TrieBuilderOption.Small)
trie.Next('j')
trie.Next('a')
trie.Next('n')
trie.Next('u')
trie.Next('a')
    var iter: BytesTrieEnumerator = trie.GetEnumerator
    var data: StringAndValue[] = @[StringAndValue("r", 1), StringAndValue("ry", 1)]
checkIterator(iter, data)
Logln("after iter.Reset()")
checkIterator(iter.Reset, data)
proc Test52TruncatingIteratorFromRoot*() =
    var trie: BytesTrie = buildMonthsTrie(TrieBuilderOption.Fast)
    var iter: BytesTrieEnumerator = trie.GetEnumerator(4)
    var data: StringAndValue[] = @[StringAndValue("augu", -1), StringAndValue("jan", 1), StringAndValue("jan.", 1), StringAndValue("jana", 1), StringAndValue("janb", -1), StringAndValue("janc", 1), StringAndValue("jand", -1), StringAndValue("jane", -1), StringAndValue("janf", 1), StringAndValue("jang", -1), StringAndValue("janh", 1), StringAndValue("jani", -1), StringAndValue("janj", 1), StringAndValue("jank", -1), StringAndValue("janl", 1), StringAndValue("janm", 1), StringAndValue("jann", -1), StringAndValue("jano", 1), StringAndValue("janp", -1), StringAndValue("janq", -1), StringAndValue("janr", 1), StringAndValue("janu", -1), StringAndValue("july", 7), StringAndValue("jun", 6), StringAndValue("jun.", 6), StringAndValue("june", 6)]
checkIterator(iter, data)
Logln("after iter.Reset()")
checkIterator(iter.Reset, data)
proc Test53TruncatingIteratorFromLinearMatchShort*() =
    var data: StringAndValue[] = @[StringAndValue("abcdef", 10), StringAndValue("abcdepq", 200), StringAndValue("abcdeyz", 3000)]
    var trie: BytesTrie = buildTrie(data, data.Length, TrieBuilderOption.Fast)
trie.Next('a')
trie.Next('b')
    var iter: BytesTrieEnumerator = trie.GetEnumerator(2)
    var expected: StringAndValue[] = @[StringAndValue("cd", -1)]
checkIterator(iter, expected)
Logln("after iter.Reset()")
checkIterator(iter.Reset, expected)
proc Test54TruncatingIteratorFromLinearMatchLong*() =
    var data: StringAndValue[] = @[StringAndValue("abcdef", 10), StringAndValue("abcdepq", 200), StringAndValue("abcdeyz", 3000)]
    var trie: BytesTrie = buildTrie(data, data.Length, TrieBuilderOption.Fast)
trie.Next('a')
trie.Next('b')
trie.Next('c')
    var iter: BytesTrieEnumerator = trie.GetEnumerator(3)
    var expected: StringAndValue[] = @[StringAndValue("def", 10), StringAndValue("dep", -1), StringAndValue("dey", -1)]
checkIterator(iter, expected)
Logln("after iter.Reset()")
checkIterator(iter.Reset, expected)
proc Test59IteratorFromBytes*() =
    var data: StringAndValue[] = @[StringAndValue("mm", 3), StringAndValue("mmm", 33), StringAndValue("mmnop", 333)]
builder_.Clear
    for item in data:
builder_.Add(item.bytes, item.bytes.Length, item.value)
    var trieBytes: ByteBuffer = builder_.BuildByteBuffer(TrieBuilderOption.Fast)
checkIterator(BytesTrie.GetEnumerator(trieBytes.Array, trieBytes.ArrayOffset + trieBytes.Position, 0), data)
proc checkData(data: seq[StringAndValue]) =
checkData(data, data.Length)
proc checkData(data: seq[StringAndValue], dataLength: int) =
Logln("checkData(dataLength=" + dataLength + ", fast)")
checkData(data, dataLength, TrieBuilderOption.Fast)
Logln("checkData(dataLength=" + dataLength + ", small)")
checkData(data, dataLength, TrieBuilderOption.Small)
proc checkData(data: seq[StringAndValue], dataLength: int, buildOption: TrieBuilderOption) =
    var trie: BytesTrie = buildTrie(data, dataLength, buildOption)
checkFirst(trie, data, dataLength)
checkNext(trie, data, dataLength)
checkNextWithState(trie, data, dataLength)
checkNextString(trie, data, dataLength)
checkIterator(trie, data, dataLength)
proc buildTrie(data: seq[StringAndValue], dataLength: int, buildOption: TrieBuilderOption): BytesTrie =
      var index: int
      var step: int
    if dataLength & 1 != 0:
        index = dataLength / 2
        step = 2

    elif dataLength % 3 != 0:
        index = dataLength / 5
        step = 3
    else:
        index = dataLength - 1
        step = -1
builder_.Clear
      var i: int = 0
      while i < dataLength:
builder_.Add(data[index].bytes, data[index].bytes.Length, data[index].value)
          index = index + step % dataLength
++i
    var trie: BytesTrie = builder_.Build(buildOption)
    try:
builder_.Add(@[122, 122, 122], 0, 999)
Errln("builder.build().add(zzz) did not throw InvalidOperationException")
    except InvalidOperationException:

    var trieBytes: ByteBuffer = builder_.BuildByteBuffer(buildOption)
Logln("serialized trie size: " + trieBytes.Remaining + " bytes
")
    if dataLength & 1 != 0:
        return trie
    else:
        return BytesTrie(trieBytes.Array, trieBytes.ArrayOffset + trieBytes.Position)
proc checkFirst(trie: BytesTrie, data: seq[StringAndValue], dataLength: int) =
      var i: int = 0
      while i < dataLength:
          if data[i].s.Length == 0:
              continue
          var c: int = data[i].bytes[0]
          var firstResult: Result = trie.First(c)
          var firstValue: int =           if firstResult.HasValue:
trie.GetValue
          else:
-1
          var nextC: int =           if data[i].s.Length > 1:
data[i].bytes[1]
          else:
0
          var nextResult: Result = trie.Next(nextC)
          if firstResult != trie.Reset.Next(c) || firstResult != trie.Current || firstValue !=           if firstResult.HasValue:
trie.GetValue
          else:
-1 || nextResult != trie.Next(nextC):
Errln(string.Format("trie.First({0})!=trie.Reset().Next(same) for {1}", cast[char](c), data[i].s))
++i
trie.Reset
proc checkNext(trie: BytesTrie, data: seq[StringAndValue], dataLength: int) =
    var state: BytesTrieState = BytesTrieState
      var i: int = 0
      while i < dataLength:
          var stringLength: int = data[i].s.Length
          var result: Result
          if !          result = trie.Next(data[i].bytes, 0, stringLength).HasValue || result != trie.Current:
Errln("trie does not seem to contain " + data[i].s)

          elif trie.GetValue != data[i].value:
Errln(string.Format("trie value for {0} is {1:d}=0x{2:x} instead of expected {3:d}=0x{4:x}", data[i].s, trie.GetValue, trie.GetValue, data[i].value, data[i].value))
          else:
            if result != trie.Current || trie.GetValue != data[i].value:
Errln("trie value for " + data[i].s + " changes when repeating current()/getValue()")
trie.Reset
          result = trie.Current
            var j: int = 0
            while j < stringLength:
                if !result.HasNext:
Errln(String.Format("trie.Current!=hasNext before end of {0} (at index {1:d})", data[i].s, j))
                    break
                if result == Result.IntermediateValue:
trie.GetValue
                    if trie.Current != Result.IntermediateValue:
Errln(String.Format("trie.GetValue().Current!=BytesTrieResult.INTERMEDIATE_VALUE " + "before end of {0} (at index {1:d})", data[i].s, j))
                        break
                result = trie.Next(data[i].bytes[j])
                if !result.Matches:
Errln(String.Format("trie.Next()=BytesTrieResult.NO_MATCH " + "before end of {0} (at index {1:d})", data[i].s, j))
                    break
                if result != trie.Current:
Errln(String.Format("trie.Next()!=following current() " + "before end of {0} (at index {1:d})", data[i].s, j))
                    break
++j
          if !result.HasValue:
Errln("trie.Next()!=hasValue at the end of " + data[i].s)
              continue
trie.GetValue
          if result != trie.Current:
Errln("trie.Current != current()+getValue()+current() after end of " + data[i].s)
trie.SaveState(state)
          var nextContinues: bool = false
            var c: int = 32
            while c < 127:
                if trie.ResetToState(state).Next(c).Matches:
                    nextContinues = true
                    break
++c
          if result == Result.IntermediateValue != nextContinues:
Errln("(trie.Current==BytesTrieResult.INTERMEDIATE_VALUE) contradicts " + "(trie.Next(some UChar)!=BytesTrieResult.NO_MATCH) after end of " + data[i].s)
trie.Reset
++i
proc checkNextWithState(trie: BytesTrie, data: seq[StringAndValue], dataLength: int) =
      var noState: BytesTrieState = BytesTrieState
      var state: BytesTrieState = BytesTrieState
      var i: int = 0
      while i < dataLength:
          if i & 1 == 0:
              try:
trie.ResetToState(noState)
Errln("trie.ResetToState(noState) should throw an ArgumentException")
              except ArgumentException:

          var expectedString: byte[] = data[i].bytes
          var stringLength: int = data[i].s.Length
          var partialLength: int = stringLength / 3
            var j: int = 0
            while j < partialLength:
                if !trie.Next(expectedString[j]).Matches:
Errln("trie.Next()=BytesTrieResult.NO_MATCH for a prefix of " + data[i].s)
                    return
++j
trie.SaveState(state)
          var resultAtState: Result = trie.Current
          var result: Result
          var valueAtState: int = -99
          if resultAtState.HasValue:
              valueAtState = trie.GetValue
          result = trie.Next(0)
          if result != Result.NoMatch || result != trie.Current:
Errln("trie.Next(0) matched after part of " + data[i].s)
          if resultAtState != trie.ResetToState(state).Current || resultAtState.HasValue && valueAtState != trie.GetValue:
Errln("trie.Next(part of " + data[i].s + ") changes current()/getValue() after " + "saveState/next(0)/resetToState")

          elif !          result = trie.Next(expectedString, partialLength, stringLength).HasValue || result != trie.Current:
Errln("trie.Next(rest of " + data[i].s + ") does not seem to contain " + data[i].s + " after " + "saveState/next(0)/resetToState")
          else:
            if !            result = trie.ResetToState(state).Next(expectedString, partialLength, stringLength).HasValue || result != trie.Current:
Errln("trie does not seem to contain " + data[i].s + " after saveState/next(rest)/resetToState")

            elif trie.GetValue != data[i].value:
Errln(String.Format("trie value for {0} is {1:d}=0x{2:x} instead of expected {3:d}=0x{4:x}", data[i].s, trie.GetValue, trie.GetValue, data[i].value, data[i].value))
trie.Reset
++i
proc checkNextString(trie: BytesTrie, data: seq[StringAndValue], dataLength: int) =
      var i: int = 0
      while i < dataLength:
          var expectedString: byte[] = data[i].bytes
          var stringLength: int = data[i].s.Length
          if !trie.Next(expectedString, 0, stringLength / 2).Matches:
Errln("trie.Next(up to middle of string)=BytesTrieResult.NO_MATCH for " + data[i].s)
              continue
trie.Next(expectedString, stringLength / 2, stringLength)
          if trie.Next(0).Matches:
Errln("trie.Next(string+NUL)!=BytesTrieResult.NO_MATCH for " + data[i].s)
trie.Reset
++i
proc checkIterator(trie: BytesTrie, data: seq[StringAndValue], dataLength: int) =
checkIterator(trie.GetEnumerator, data, dataLength)
proc checkIterator(iter: BytesTrieEnumerator, data: seq[StringAndValue]) =
checkIterator(iter, data, data.Length)
proc checkIterator(iter: BytesTrieEnumerator, data: seq[StringAndValue], dataLength: int) =
      var i: int = 0
      while i < dataLength:
          if !iter.MoveNext:
Errln("trie iterator MoveNext()=false for item " + i + ": " + data[i].s)
              break
          var entry: BytesTrieEntry = iter.Current
          var bytesString: StringBuilder = StringBuilder
            var j: int = 0
            while j < entry.BytesLength:
bytesString.Append(cast[char](entry[j] & 255))
++j
          if !data[i].s.ContentEquals(bytesString):
Errln(String.Format("trie iterator next().getString()={0} but expected {1} for item {2:d}", bytesString, data[i].s, i))
          if entry.value != data[i].value:
Errln(String.Format("trie iterator next().GetValue()={0:d}=0x{1:x} but expected {2:d}=0x{3:x} for item {4:d}: {5}", entry.value, entry.value, data[i].value, data[i].value, i, data[i].s))
++i
    if iter.MoveNext:
Errln("trie iterator MoveNext()=true after all items")