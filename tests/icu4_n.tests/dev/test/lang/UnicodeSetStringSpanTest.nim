# "Namespace: ICU4N.Dev.Test.Lang"
type
  UnicodeSetStringSpanTest = ref object
    SPAN_UTF16: int = 1
    SPAN_UTF8: int = 2
    SPAN_UTFS: int = 3
    SPAN_SET: int = 4
    SPAN_COMPLEMENT: int = 8
    SPAN_POLARITY: int = 12
    SPAN_FWD: int = 16
    SPAN_BACK: int = 32
    SPAN_DIRS: int = 48
    SPAN_CONTAINED: int = 256
    SPAN_SIMPLE: int = 512
    SPAN_CONDITION: int = 768
    SPAN_ALL: int = 831
    SLOW: int = 0
    SLOW_NOT: int = 1
    FAST: int = 2
    FAST_NOT: int = 3
    SET_COUNT: int = 4
    setNames: seq[String] = @["slow", "slow.not", "fast", "fast.not"]
    interestingStringChars: seq[char] = @[cast[char](97), cast[char](98), cast[char](32), cast[char](945), cast[char](946), cast[char](947), cast[char](55552), cast[char](12288), cast[char](12459), cast[char](12461), cast[char](56325), cast[char](160), cast[char](44032), cast[char](55203), cast[char](55552), cast[char](56325), cast[char](55360), cast[char](57343), cast[char](55392), cast[char](57342), cast[char](55204), cast[char](56325), cast[char](55552), cast[char](8232)]
    interestingString: String = String(interestingStringChars)
    unicodeSet1: String = "[[[:ID_Continue:]-[\u30ab\u30ad]]{\u3000\u30ab}{\u3000\u30ab\u30ad}]"
    patternWithUnpairedSurrogate: String = "[a\U00020001\U00020400{ab}{b\uD840}{\uDC00a}]"
    stringWithUnpairedSurrogate: String = "aaab\U00020001ba\U00020400aba\uD840ab\uD840\U00020000b\U00020000a\U00020000\uDC00a\uDC00babbb"
    _63_a: String = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    _64_a: String = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    _63_b: String = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    _64_b: String = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    longPattern: String = "[a{" + _64_a + _64_a + _64_a + _64_a + "b}" + "{a" + _64_b + _64_b + _64_b + _64_b + "}]"

proc TestSimpleStringSpan*() =
    var pattern: String = "[a{ab}{bc}]"
    var str: String = "abc"
    var set: UnicodeSet = UnicodeSet(pattern)
set.Complement
    var pos: int = set.SpanBack(str, 3, SpanCondition.Simple)
    if pos != 1:
Errln(string.Format("FAIL: UnicodeSet({0}).SpanBack({1}) returns the wrong value pos {2} (!= 1)", set.ToString, str, pos))
    pos = set.Span(str, SpanCondition.Simple)
    if pos != 3:
Errln(string.Format("FAIL: UnicodeSet({0}).Span({1}) returns the wrong value pos {2} (!= 3)", set.ToString, str, pos))
    pos = set.Span(str, 1, SpanCondition.Simple)
    if pos != 3:
Errln(string.Format("FAIL: UnicodeSet({0}).Span({1}, 1) returns the wrong value pos {2} (!= 3)", set.ToString, str, pos))
proc TestSimpleStringSpanSlow*() =
    var pattern: String = "[a{ab}{bc}]"
    var str: String = "abc"
    var uset: UnicodeSet = UnicodeSet(pattern)
uset.Complement
    var set: UnicodeSetWithStrings = UnicodeSetWithStrings(uset)
    var length: int = ContainsSpanBackUTF16(set, str, 3, SpanCondition.Simple)
    if length != 1:
Errln(string.Format("FAIL: UnicodeSet({0}) containsSpanBackUTF16({1}) returns the wrong value length {2} (!= 1)", set.ToString, str, length))
    length = ContainsSpanUTF16(set, str, SpanCondition.Simple)
    if length != 3:
Errln(string.Format("FAIL: UnicodeSet({0}) containsSpanUTF16({1}) returns the wrong value length {2} (!= 3)", set.ToString, str, length))
    length = ContainsSpanUTF16(set, str.Substring(1), SpanCondition.Simple)
    if length != 2:
Errln(string.Format("FAIL: UnicodeSet({0}) containsSpanUTF16({1}) returns the wrong value length {2} (!= 2)", set.ToString, str, length))
proc TestSimpleStringSpanAndFreeze*() =
    var pattern: String = "[x{xy}{xya}{axy}{ax}]"
    var str: String = "xx" + "xyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxya" + "xx" + "xyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxya" + "xx" + "xyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxyaxy" + "aaaa"
    var set: UnicodeSet = UnicodeSet(pattern)
    if set.ContainsAll(str):
Errln("FAIL: UnicodeSet(" + pattern + ").containsAll(" + str + ") should be FALSE")
    var string16: String = str.Substring(0, str.Length - 4)
    if !set.ContainsAll(string16):
Errln("FAIL: UnicodeSet(" + pattern + ").containsAll(" + str + "[:-4]) should be TRUE")
    var s16: String = "byayaxya"
    if set.Span(s16.Substring(0, 8), SpanCondition.NotContained) != 4 || set.Span(s16.Substring(0, 7), SpanCondition.NotContained) != 4 || set.Span(s16.Substring(0, 6), SpanCondition.NotContained) != 4 || set.Span(s16.Substring(0, 5), SpanCondition.NotContained) != 5 || set.Span(s16.Substring(0, 4), SpanCondition.NotContained) != 4 || set.Span(s16.Substring(0, 3), SpanCondition.NotContained) != 3:
Errln("FAIL: UnicodeSet(" + pattern + ").Span(while not) returns the wrong value")
    pattern = "[a{ab}{abc}{cd}]"
set.ApplyPattern(pattern)
    s16 = "acdabcdabccd"
    if set.Span(s16.Substring(0, 12), SpanCondition.Contained) != 12 || set.Span(s16.Substring(0, 12), SpanCondition.Simple) != 6 || set.Span(s16.Substring(7), SpanCondition.Simple) != 5:
Errln("FAIL: UnicodeSet(" + pattern + ").Span(while longest match) returns the wrong value")
set.Freeze
    if set.Span(s16.Substring(0, 12), SpanCondition.Contained) != 12 || set.Span(s16.Substring(0, 12), SpanCondition.Simple) != 6 || set.Span(s16.Substring(7), SpanCondition.Simple) != 5:
Errln("FAIL: UnicodeSet(" + pattern + ").Span(while longest match) returns the wrong value")
    pattern = "[d{cd}{bcd}{ab}]"
    set = set.CloneAsThawed
set.ApplyPattern(pattern).Freeze
    s16 = "abbcdabcdabd"
    if set.SpanBack(s16, 12, SpanCondition.Contained) != 0 || set.SpanBack(s16, 12, SpanCondition.Simple) != 6 || set.SpanBack(s16, 5, SpanCondition.Simple) != 0:
Errln("FAIL: UnicodeSet(" + pattern + ").SpanBack(while longest match) returns the wrong value")
type
  UnicodeSetWithStrings = ref object
    set: UnicodeSet
    setStrings: ICollection[string]
    stringsLength: int

proc newUnicodeSetWithStrings(normalSet: UnicodeSet): UnicodeSetWithStrings =
  set = normalSet
  setStrings = normalSet.Strings
  stringsLength = setStrings.Count
proc Set(): UnicodeSet =
    return set
proc HasStrings(): bool =
    return stringsLength > 0
proc Strings(): IEnumerable[string] =
    return setStrings
proc Matches16CPB(s: string, start: int, limit: int, t: string): bool =
    limit = start
    var length: int = t.Length
    return t.Equals(s.Substring(start, length)) && !0 < start && UTF16.IsLeadSurrogate(s[start - 1]) && UTF16.IsTrailSurrogate(s[start]) && !length < limit && UTF16.IsLeadSurrogate(s[start + length - 1]) && UTF16.IsTrailSurrogate(s[start + length])
proc ContainsSpanUTF16(set: UnicodeSetWithStrings, s: string, spanCondition: SpanCondition): int =
    var realSet: UnicodeSet = set.Set
    var length: int = s.Length
    if !set.HasStrings:
        var spanContained: bool = false
        if spanCondition != SpanCondition.NotContained:
            spanContained = true
        var c: int
          var start: int = 0
          var prev: int
        while         prev = start < length:
            c = s.CodePointAt(start)
            start = s.OffsetByCodePoints(start, 1)
            if realSet.Contains(c) != spanContained:
                break
        return prev

    elif spanCondition == SpanCondition.NotContained:
        var c: int
          var start: int
          var next: int
          start =           next = 0
          while start < length:
              c = s.CodePointAt(next)
              next = s.OffsetByCodePoints(next, 1)
              if realSet.Contains(c):
                  break
              for str in set.Strings:
                  if str.Length <= length - start && Matches16CPB(s, start, length, str):
                      return start
              start = next
        return start
    else:
        var c: int
          var start: int
          var next: int
          var maxSpanLimit: int = 0
          start =           next = 0
          while start < length:
              c = s.CodePointAt(next)
              next = s.OffsetByCodePoints(next, 1)
              if !realSet.Contains(c):
                  next = start
              for str in set.Strings:
                  if str.Length <= length - start && Matches16CPB(s, start, length, str):
                      var matchLimit: int = start + str.Length
                      if matchLimit == length:
                          return length
                      if spanCondition == SpanCondition.Contained:
                          if next == start:
                              next = matchLimit
                          else:
                              if matchLimit < next:
                                  var temp: int = next
                                  next = matchLimit
                                  matchLimit = temp
                              var spanLength: int = ContainsSpanUTF16(set, s.Substring(matchLimit), SpanCondition.Contained)
                              if matchLimit + spanLength > maxSpanLimit:
                                  maxSpanLimit = matchLimit + spanLength
                                  if maxSpanLimit == length:
                                      return length
                      else:
                          if matchLimit > next:
                              next = matchLimit
              if next == start:
                  break
              start = next
        if start > maxSpanLimit:
            return start
        else:
            return maxSpanLimit
proc ContainsSpanBackUTF16(set: UnicodeSetWithStrings, s: String, length: int, spanCondition: SpanCondition): int =
    if length == 0:
        return 0
    var realSet: UnicodeSet = set.Set
    if !set.HasStrings:
        var spanContained: bool = false
        if spanCondition != SpanCondition.NotContained:
            spanContained = true
        var c: int
        var prev: int = length
        while true:
            c = s.CodePointBefore(prev)
            if realSet.Contains(c) != spanContained:
                break
            prev = s.OffsetByCodePoints(prev, -1)
            if notprev > 0:
                break
        return prev

    elif spanCondition == SpanCondition.NotContained:
        var c: int
          var prev: int = length
          var length0: int = length
        while true:
            c = s.CodePointBefore(prev)
            if realSet.Contains(c):
                break
            for str in set.Strings:
                if str.Length <= prev && Matches16CPB(s, prev - str.Length, length0, str):
                    return prev
            prev = s.OffsetByCodePoints(prev, -1)
            if notprev > 0:
                break
        return prev
    else:
        var c: int
          var prev: int = length
          var minSpanStart: int = length
          var length0: int = length
        while true:
            c = s.CodePointBefore(length)
            length = s.OffsetByCodePoints(length, -1)
            if !realSet.Contains(c):
                length = prev
            for str in set.Strings:
                if str.Length <= prev && Matches16CPB(s, prev - str.Length, length0, str):
                    var matchStart: int = prev - str.Length
                    if matchStart == 0:
                        return 0
                    if spanCondition == SpanCondition.Contained:
                        if length == prev:
                            length = matchStart
                        else:
                            if matchStart > length:
                                var temp: int = length
                                length = matchStart
                                matchStart = temp
                            var spanStart: int = ContainsSpanBackUTF16(set, s, matchStart, SpanCondition.Contained)
                            if spanStart < minSpanStart:
                                minSpanStart = spanStart
                                if minSpanStart == 0:
                                    return 0
                    else:
                        if matchStart < length:
                            length = matchStart
            if length == prev:
                break
            if not            prev = length > 0:
                break
        if prev < minSpanStart:
            return prev
        else:
            return minSpanStart
proc InvertSpanCondition(spanCondition: SpanCondition, contained: SpanCondition): SpanCondition =
    return     if spanCondition == SpanCondition.NotContained:
contained
    else:
SpanCondition.NotContained
proc GetSpans(set: UnicodeSetWithStrings, isComplement: bool, s: String, whichSpans: int, type: int, typeName: seq[String], limits: seq[int], limitsCapacity: int, expectCount: int): int =
    var realSet: UnicodeSet = set.Set
      var start: int
      var count: int
      var i: int
      var spanCondition: SpanCondition
      var firstSpanCondition: SpanCondition
      var contained: SpanCondition
    var isForward: bool
    var length: int = s.Length
    if type < 0 || 7 < type:
        typeName[0] = nil
        return 0
    var typeNames16: String[] = @["contains", "contains(LM)", "span", "span(LM)", "containsBack", "containsBack(LM)", "spanBack", "spanBack(LM)"]
    typeName[0] = typeNames16[type]
    if type <= 3:
        if whichSpans & SPAN_FWD == 0:
            return -1
        isForward = true
    else:
        if whichSpans & SPAN_BACK == 0:
            return -1
        isForward = false
    if type & 1 == 0:
        if whichSpans & SPAN_CONTAINED == 0:
            return -1
        contained = SpanCondition.Contained
    else:
        if whichSpans & SPAN_SIMPLE == 0:
            return -1
        contained = SpanCondition.Simple
    spanCondition = SpanCondition.NotContained
    if isComplement:
        spanCondition = InvertSpanCondition(spanCondition, contained)
    firstSpanCondition = spanCondition
    if !isForward && whichSpans & SPAN_FWD != 0 && expectCount & 1 == 0:
        spanCondition = InvertSpanCondition(spanCondition, contained)
    count = 0
    case type
    of 0:
        start = 0
          while true:
              start = ContainsSpanUTF16(set, s.Substring(start), spanCondition)
              if count < limitsCapacity:
                  limits[count] = start
++count
              if start >= length:
                  break
              spanCondition = InvertSpanCondition(spanCondition, contained)
        break
    of 1:
        start = 0
          while true:
              start = ContainsSpanUTF16(set, s.Substring(start), spanCondition)
              if count < limitsCapacity:
                  limits[count] = start
++count
              if start >= length:
                  break
              spanCondition = InvertSpanCondition(spanCondition, contained)
        break
    of 2:
        start = 0
          while true:
              start = realSet.Span(s, start, spanCondition)
              if count < limitsCapacity:
                  limits[count] = start
++count
              if start >= length:
                  break
              spanCondition = InvertSpanCondition(spanCondition, contained)
        break
    of 3:
        start = 0
          while true:
              start = realSet.Span(s, start, spanCondition)
              if count < limitsCapacity:
                  limits[count] = start
++count
              if start >= length:
                  break
              spanCondition = InvertSpanCondition(spanCondition, contained)
        break
    of 4:
          while true:
++count
              if count <= limitsCapacity:
                  limits[limitsCapacity - count] = length
              length = ContainsSpanBackUTF16(set, s, length, spanCondition)
              if length == 0 && spanCondition == firstSpanCondition:
                  break
              spanCondition = InvertSpanCondition(spanCondition, contained)
        if count < limitsCapacity:
              i = count
              while --i > 0:
                  limits[i] = limits[limitsCapacity - count + i]
        break
    of 5:
          while true:
++count
              if count <= limitsCapacity:
                  limits[limitsCapacity - count] = length
              length = ContainsSpanBackUTF16(set, s, length, spanCondition)
              if length == 0 && spanCondition == firstSpanCondition:
                  break
              spanCondition = InvertSpanCondition(spanCondition, contained)
        if count < limitsCapacity:
              i = count
              while --i > 0:
                  limits[i] = limits[limitsCapacity - count + i]
        break
    of 6:
          while true:
++count
              if count <= limitsCapacity:
                  limits[limitsCapacity - count] =                   if length >= 0:
length
                  else:
s.Length
              length = realSet.SpanBack(s, length, spanCondition)
              if length == 0 && spanCondition == firstSpanCondition:
                  break
              spanCondition = InvertSpanCondition(spanCondition, contained)
        if count < limitsCapacity:
              i = count
              while --i > 0:
                  limits[i] = limits[limitsCapacity - count + i]
        break
    of 7:
          while true:
++count
              if count <= limitsCapacity:
                  limits[limitsCapacity - count] =                   if length >= 0:
length
                  else:
s.Length
              length = realSet.SpanBack(s, length, spanCondition)
              if length == 0 && spanCondition == firstSpanCondition:
                  break
              spanCondition = InvertSpanCondition(spanCondition, contained)
        if count < limitsCapacity:
              i = count
              while --i > 0:
                  limits[i] = limits[limitsCapacity - count + i]
        break
    else:
        typeName = nil
        return -1
    return count
proc VerifySpan(sets: seq[UnicodeSetWithStrings], s: String, whichSpans: int, expectLimits: seq[int], expectCount: int, testName: String, index: int) =
    var limits: int[] = seq[int]
    var limitsCount: int
      var i: int
      var j: int
    var typeName: String[] = seq[String]
    var type: int
      i = 0
      while i < SET_COUNT:
          if i & 1 == 0:
              if whichSpans & SPAN_SET == 0:
                  continue
          else:
              if whichSpans & SPAN_COMPLEMENT == 0:
                  continue
            type = 0
            while true:
                limitsCount = GetSpans(sets[i], 0 != i & 1, s, whichSpans, type, typeName, limits, limits.Length, expectCount)
                if typeName[0] == nil:
                    break
                if limitsCount < 0:
                    continue
                if expectCount < 0:
                    expectCount = limitsCount
                    if limitsCount > limits.Length:
Errln(string.Format("FAIL: {0}[0x{1:x}].{2}.{3} span count={4} > {5} capacity - too many spans", testName, index, setNames[i], typeName[0], limitsCount, limits.Length))
                        return
                      j = limitsCount
                      while --j > 0:
                          expectLimits[j] = limits[j]

                elif limitsCount != expectCount:
Errln(string.Format("FAIL: {0}[0x{1:x}].{2}.{3} span count={4} != {5}", testName, index, setNames[i], typeName[0], limitsCount, expectCount))
                else:
                      j = 0
                      while j < limitsCount:
                          if limits[j] != expectLimits[j]:
Errln(string.Format("FAIL: {0}[0x{1:x}].{2}.{3} span count={4} limits[{5}]={6} != {7}", testName, index, setNames[i], typeName[0], limitsCount, j, limits[j], expectLimits[j]))
                              break
++j
++type
++i
    if whichSpans & SPAN_SET != 0:
        var s16: String = s
        var str: String
          var prev: int = 0
          var limit: int
          var len: int
          i = 0
          while i < expectCount:
              limit = expectLimits[i]
              len = limit - prev
              if len > 0:
                  str = s16.Substring(prev, len)
                  if 0 != i & 1:
                      if !sets[SLOW].Set.ContainsAll(str):
Errln(string.Format("FAIL:{0}[0x{1:x}].{2}.containsAll({3}..{4})==false contradicts span()", testName, index, setNames[SLOW], prev, limit))
                          return
                      if !sets[FAST].Set.ContainsAll(str):
Errln(string.Format("FAIL: {0}[0x{1:x}].{2}.containsAll({3}..{4})==false contradicts span()", testName, index, setNames[FAST], prev, limit))
                          return
                  else:
                      if !sets[SLOW].Set.ContainsNone(str):
Errln(string.Format("FAIL: {0}[0x{1:x}].{2}.containsNone([3}..{4})==false contradicts span()", testName, index, setNames[SLOW], prev, limit))
                          return
                      if !sets[FAST].Set.ContainsNone(str):
Errln(string.Format("FAIL: {0}[0x{1:x}].{2}.containsNone({3}..{4})==false contradicts span()", testName, index, setNames[FAST], prev, limit))
                          return
              prev = limit
++i
proc VerifySpan(sets: seq[UnicodeSetWithStrings], s: String, whichSpans: int, testName: String, index: int) =
    var expectLimits: int[] = seq[int]
    var expectCount: int = -1
VerifySpan(sets, s, whichSpans, expectLimits, expectCount, testName, index)
proc VerifySpanBothUTFs(sets: seq[UnicodeSetWithStrings], s16: String, whichSpans: int, testName: String, index: int) =
    var expectLimits: int[] = seq[int]
    var expectCount: int
    expectCount = -1
    if whichSpans & SPAN_UTF16 != 0:
VerifySpan(sets, s16, whichSpans, expectLimits, expectCount, testName, index)
proc NextCodePoint(c: int): int =
    case c
    of 13377:
        return 19839
    of 20736:
        return 40704
    of 45120:
        return 55168
    of 57409:
        return 63742
    of 65792:
        return 131072
    of 131137:
        return 917504
    of 917761:
        return 1114109
    else:
        return c + 1
proc VerifySpanContents(sets: seq[UnicodeSetWithStrings], whichSpans: int, testName: String) =
    var s: StringBuffer = StringBuffer
    var localWhichSpans: int
      var c: int
      var first: int
      first =       c = 0
      while true:
          if c > 1114111 || s.Length > 1024:
              localWhichSpans = whichSpans
VerifySpanBothUTFs(sets, s.ToString, localWhichSpans, testName, first)
              if c > 1114111:
                  break
s.Delete(0, s.Length - 0)
              first = c
UTF16.Append(s, c)
          c = NextCodePoint(c)
proc TestInterestingStringSpan*() =
    var uset: UnicodeSet = UnicodeSet(Utility.Unescape(unicodeSet1))
    var spanCondition: SpanCondition = SpanCondition.NotContained
    var expect: int = 2
    var start: int = 14
    var c: int = 55360
    var contains: bool = uset.Contains(c)
    if false != contains:
Errln(string.Format("FAIL: UnicodeSet(unicodeSet1).Contains({0}) = true (expect false)", c))
    var set: UnicodeSetWithStrings = UnicodeSetWithStrings(uset)
    var len: int = ContainsSpanUTF16(set, interestingString.Substring(start), spanCondition)
    if expect != len:
Errln(string.Format("FAIL: containsSpanUTF16(unicodeSet1, "{0}({1})") = {2} (expect {3})", interestingString, start, len, expect))
    len = uset.Span(interestingString, start, spanCondition) - start
    if expect != len:
Errln(string.Format("FAIL: UnicodeSet(unicodeSet1).Span("{0}", {1}) = {2} (expect {3})", interestingString, start, len, expect))
proc VerifySpanUTF16String(sets: seq[UnicodeSetWithStrings], whichSpans: int, testName: String) =
    if whichSpans & SPAN_UTF16 == 0:
        return
VerifySpan(sets, interestingString, whichSpans & ~SPAN_UTF8, testName, 1)
proc AddAlternative(whichSpans: seq[int], whichSpansCount: int, mask: int, a: int, b: int, c: int): int =
    var s: int
    var i: int
      i = 0
      while i < whichSpansCount:
          s = whichSpans[i] & mask
          whichSpans[i] = s | a
          if b != 0:
              whichSpans[whichSpansCount + i] = s | b
              if c != 0:
                  whichSpans[2 * whichSpansCount + i] = s | c
++i
    return     if b == 0:
whichSpansCount
    else:
        if c == 0:
2 * whichSpansCount
        else:
3 * whichSpansCount
proc TestStringWithUnpairedSurrogateSpan*() =
    var str: String = Utility.Unescape(stringWithUnpairedSurrogate)
    var uset: UnicodeSet = UnicodeSet(Utility.Unescape(patternWithUnpairedSurrogate))
    var spanCondition: SpanCondition = SpanCondition.NotContained
    var start: int = 17
    var expect: int = 5
    var set: UnicodeSetWithStrings = UnicodeSetWithStrings(uset)
    var len: int = ContainsSpanUTF16(set, str.Substring(start), spanCondition)
    if expect != len:
Errln(string.Format("FAIL: containsSpanUTF16(patternWithUnpairedSurrogate, "{0}({1})") = {2} (expect {3})", str, start, len, expect))
    len = uset.Span(str, start, spanCondition) - start
    if expect != len:
Errln(string.Format("FAIL: UnicodeSet(patternWithUnpairedSurrogate).Span("{0}", {1}) = {2} (expect {3})", str, start, len, expect))
proc TestSpan*() =
    var testdata: String[] = @["[:ID_Continue:]", "*", "[:White_Space:]", "*", "[]", "*", "[\u0000-\U0010FFFF]", "*", "[\u0000\u0080\u0800\U00010000]", "*", "[\u007F\u07FF\uFFFF\U0010FFFF]", "*", unicodeSet1, "-c", "*", "[[[:ID_Continue:]-[\u30ab\u30ad]]{\u30ab\u30ad}{\u3000\u30ab\u30ad}]", "-c", "*", "[x{xy}{xya}{axy}{ax}]", "-cl", "xx" + "xyaxyaxyaxya" + "xx" + "xyaxyaxyaxya" + "xx" + "xyaxyaxyaxya" + "aaa", "xx" + "xyaxyaxyaxya" + "xx" + "xyaxyaxyaxya" + "xx" + "xyaxyaxyaxy", "-bc", "byayaxya", "-c", "byayaxy", "byayax", "-", "byaya", "byay", "bya", "[a{ab}{bc}]", "-cl", "abc", "[a{ab}{abc}{cd}]", "-cl", "acdabcdabccd", "[c{ab}{bc}]", "-cl", "abc", "[d{cd}{bcd}{ab}]", "-cl", "abbcdabcdabd", "[\u042B{\u042B\u30AB}{\u042B\u30AB\U000200AB}{\U000200AB\U000204AB}]", "-cl", "\u042B\U000200AB\U000204AB\u042B\u30AB\U000200AB\U000204AB\u042B\u30AB\U000200AB\U000200AB\U000204AB", "[\U000204AB{\U000200AB\U000204AB}{\u30AB\U000200AB\U000204AB}{\u042B\u30AB}]", "-cl", "\u042B\u30AB\u30AB\U000200AB\U000204AB\u042B\u30AB\U000200AB\U000204AB\u042B\u30AB\U000204AB", "[b{bb}]", "-c", "bbbbbbbbbbbbbbbbbbbbbbbb-", "-bc", "bbbbbbbbbbbbbbbbbbbbbbbbb-", longPattern, "-c", _64_a + _64_a + _64_a + _63_a + "b", _64_a + _64_a + _64_a + _64_a + "b", _64_a + _64_a + _64_a + _64_a + "aaaabbbb", "a" + _64_b + _64_b + _64_b + _63_b, "a" + _64_b + _64_b + _64_b + _64_b, "aaaabbbb" + _64_b + _64_b + _64_b + _64_b, patternWithUnpairedSurrogate, "-8cl", stringWithUnpairedSurrogate]
      var i: int
      var j: int
    var whichSpansCount: int = 1
    var whichSpans: int[] = seq[int]
      i = whichSpans.Length
      while --i > 0:
          whichSpans[i] = SPAN_ALL
    var sets: UnicodeSet[] = seq[UnicodeSet]
    var sets_with_str: UnicodeSetWithStrings[] = seq[UnicodeSetWithStrings]
    var testName: String = nil
    var testNameLimit: String
      i = 0
      while i < testdata.Length:
          var s: String = testdata[i]
          if s[0] == '[':
                j = 0
                while j < SET_COUNT:
                    sets_with_str[j] = nil
                    sets[j] = nil
++j
              sets[SLOW] = UnicodeSet(Utility.Unescape(s))
              sets[SLOW_NOT] = UnicodeSet(sets[SLOW])
sets[SLOW_NOT].Complement
              var fast: UnicodeSet = UnicodeSet(sets[SLOW])
fast.Freeze
              sets[FAST] = cast[UnicodeSet](fast.Clone)
              fast = nil
              var fastNot: UnicodeSet = UnicodeSet(sets[SLOW_NOT])
fastNot.Freeze
              sets[FAST_NOT] = cast[UnicodeSet](fastNot.Clone)
              fastNot = nil
                j = 0
                while j < SET_COUNT:
                    sets_with_str[j] = UnicodeSetWithStrings(sets[j])
++j
              testName = s + ':'
              whichSpans[0] = SPAN_ALL
              whichSpansCount = 1

          elif s[0] == '-':
              whichSpans[0] = SPAN_ALL
              whichSpansCount = 1
                j = 1
                while j < s.Length:
                    case s[j]
                    of 'c':
                        whichSpansCount = AddAlternative(whichSpans, whichSpansCount, ~SPAN_POLARITY, SPAN_SET, SPAN_COMPLEMENT, 0)
                        break
                    of 'b':
                        whichSpansCount = AddAlternative(whichSpans, whichSpansCount, ~SPAN_DIRS, SPAN_FWD, SPAN_BACK, 0)
                        break
                    of 'l':
                        whichSpansCount = AddAlternative(whichSpans, whichSpansCount, ~SPAN_DIRS | SPAN_CONDITION, SPAN_DIRS | SPAN_CONTAINED, SPAN_FWD | SPAN_SIMPLE, SPAN_BACK | SPAN_SIMPLE)
                        break
                    of '8':
                        whichSpansCount = AddAlternative(whichSpans, whichSpansCount, ~SPAN_UTFS, SPAN_UTF16, SPAN_UTF8, 0)
                        break
                    else:
Errln(String.Format("FAIL: unrecognized span set option in "{0}"", testdata[i]))
                        break
++j
          else:
            if s.Equals("*"):
                testNameLimit = "bad_string"
                  j = 0
                  while j < whichSpansCount:
                      if whichSpansCount > 1:
                          testNameLimit = String.Format("%%0x{0:x3}", whichSpans[j])
VerifySpanUTF16String(sets_with_str, whichSpans[j], testName)
++j
                testNameLimit = "contents"
                  j = 0
                  while j < whichSpansCount:
                      if whichSpansCount > 1:
                          testNameLimit = String.Format("%%0x{0:x3}", whichSpans[j])
VerifySpanContents(sets_with_str, whichSpans[j], testName)
++j
            else:
                var str: String = Utility.Unescape(s)
                testNameLimit = "test_string"
                  j = 0
                  while j < whichSpansCount:
                      if whichSpansCount > 1:
                          testNameLimit = String.Format("%%0x{0:x3}", whichSpans[j])
VerifySpanBothUTFs(sets_with_str, str, whichSpans[j], testName, i)
++j
++i
proc TestSpanAndCount*() =
    var abc: UnicodeSet = UnicodeSet('a', 'c')
    var crlf: UnicodeSet = UnicodeSet.Add('
').Add('').Add("
")
    var ab_cd: UnicodeSet = UnicodeSet.Add('a').Add("ab").Add("abc").Add("cd")
    var sStr: string = StringHelper.Concat("ab

".AsSpan, UTF16.ValueOf(327680, newSeq[char](2)), "abcde".AsSpan)
    var s: ReadOnlySpan<char> = sStr.AsSpan
    var count: int = 0
assertEquals("abc span[8, 11[", 11, abc.SpanAndCount(s, 8, SpanCondition.Simple, count))
assertEquals("abc count=3", 3, count)
assertEquals("no abc span[2, 8[", 8, abc.SpanAndCount(s, 2, SpanCondition.NotContained, count))
assertEquals("no abc count=5", 5, count)
assertEquals("line endings span[2, 6[", 6, crlf.SpanAndCount(s, 2, SpanCondition.Contained, count))
assertEquals("line endings count=3", 3, count)
assertEquals("no ab+cd span[2, 8[", 8, ab_cd.SpanAndCount(s, 2, SpanCondition.NotContained, count))
assertEquals("no ab+cd count=5", 5, count)
assertEquals("ab+cd span[8, 12[", 12, ab_cd.SpanAndCount(s, 8, SpanCondition.Contained, count))
assertEquals("ab+cd count=2", 2, count)
assertEquals("1x abc span[8, 11[", 11, ab_cd.SpanAndCount(s, 8, SpanCondition.Simple, count))
assertEquals("1x abc count=1", 1, count)
abc.Freeze
crlf.Freeze
ab_cd.Freeze
assertEquals("abc span[8, 11[ (frozen)", 11, abc.SpanAndCount(s, 8, SpanCondition.Simple, count))
assertEquals("abc count=3 (frozen)", 3, count)
assertEquals("no abc span[2, 8[ (frozen)", 8, abc.SpanAndCount(s, 2, SpanCondition.NotContained, count))
assertEquals("no abc count=5 (frozen)", 5, count)
assertEquals("line endings span[2, 6[ (frozen)", 6, crlf.SpanAndCount(s, 2, SpanCondition.Contained, count))
assertEquals("line endings count=3 (frozen)", 3, count)
assertEquals("no ab+cd span[2, 8[ (frozen)", 8, ab_cd.SpanAndCount(s, 2, SpanCondition.NotContained, count))
assertEquals("no ab+cd count=5 (frozen)", 5, count)
assertEquals("ab+cd span[8, 12[ (frozen)", 12, ab_cd.SpanAndCount(s, 8, SpanCondition.Contained, count))
assertEquals("ab+cd count=2 (frozen)", 2, count)
assertEquals("1x abc span[8, 11[ (frozen)", 11, ab_cd.SpanAndCount(s, 8, SpanCondition.Simple, count))
assertEquals("1x abc count=1 (frozen)", 1, count)