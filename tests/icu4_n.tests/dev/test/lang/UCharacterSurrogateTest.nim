# "Namespace: ICU4N.Dev.Test.Lang"
type
  UCharacterSurrogateTest = ref object


proc TestUnicodeBlockForName*() =
    var names: String[] = @["Latin-1 Supplement", "Optical Character Recognition", "CJK Unified Ideographs Extension A", "Supplemental Arrows-B", "Supplemental arrows b", "supp-lement-al arrowsb", "Supplementary Private Use Area-B", "supplementary_Private_Use_Area-b", "supplementary_PRIVATE_Use_Area_b"]
      var i: int = 0
      while i < names.Length:
          try:
              var b: UnicodeBlock = UnicodeBlock.GetInstance(names[i])
Logln("found: " + b + " for name: " + names[i])
          except Exception:
Errln("could not find block for name: " + names[i])
              break
++i
proc TestIsValidCodePoint*() =
    if UChar.IsValidCodePoint(-1):
Errln("-1")
    if !UChar.IsValidCodePoint(0):
Errln("0")
    if !UChar.IsValidCodePoint(UChar.MaxCodePoint):
Errln("0x10ffff")
    if UChar.IsValidCodePoint(UChar.MaxCodePoint + 1):
Errln("0x110000")
proc TestIsSupplementaryCodePoint*() =
    if UChar.IsSupplementaryCodePoint(-1):
Errln("-1")
    if UChar.IsSupplementaryCodePoint(0):
Errln("0")
    if UChar.IsSupplementaryCodePoint(UChar.MinSupplementaryCodePoint - 1):
Errln("0xffff")
    if !UChar.IsSupplementaryCodePoint(UChar.MinSupplementaryCodePoint):
Errln("0x10000")
    if !UChar.IsSupplementaryCodePoint(UChar.MaxCodePoint):
Errln("0x10ffff")
    if UChar.IsSupplementaryCodePoint(UChar.MaxCodePoint + 1):
Errln("0x110000")
proc TestIsHighSurrogate*() =
    if UChar.IsHighSurrogate(cast[char](UChar.MinHighSurrogate - 1)):
Errln("0xd7ff")
    if !UChar.IsHighSurrogate(UChar.MinHighSurrogate):
Errln("0xd800")
    if !UChar.IsHighSurrogate(UChar.MaxHighSurrogate):
Errln("0xdbff")
    if UChar.IsHighSurrogate(cast[char](UChar.MaxHighSurrogate + 1)):
Errln("0xdc00")
proc TestIsLowSurrogate*() =
    if UChar.IsLowSurrogate(cast[char](UChar.MinLowSurrogate - 1)):
Errln("0xdbff")
    if !UChar.IsLowSurrogate(UChar.MinLowSurrogate):
Errln("0xdc00")
    if !UChar.IsLowSurrogate(UChar.MaxLowSurrogate):
Errln("0xdfff")
    if UChar.IsLowSurrogate(cast[char](UChar.MaxLowSurrogate + 1)):
Errln("0xe000")
proc TestIsSurrogatePair*() =
    if UChar.IsSurrogatePair(cast[char](UChar.MinHighSurrogate - 1), UChar.MinLowSurrogate):
Errln("0xd7ff,0xdc00")
    if UChar.IsSurrogatePair(cast[char](UChar.MaxHighSurrogate + 1), UChar.MinLowSurrogate):
Errln("0xd800,0xdc00")
    if UChar.IsSurrogatePair(UChar.MinHighSurrogate, cast[char](UChar.MinLowSurrogate - 1)):
Errln("0xd800,0xdbff")
    if UChar.IsSurrogatePair(UChar.MinHighSurrogate, cast[char](UChar.MaxLowSurrogate + 1)):
Errln("0xd800,0xe000")
    if !UChar.IsSurrogatePair(UChar.MinHighSurrogate, UChar.MinLowSurrogate):
Errln("0xd800,0xdc00")
proc TestCharCount*() =
UChar.CharCount(-1)
UChar.CharCount(UChar.MaxCodePoint + 1)
    if UChar.CharCount(UChar.MinSupplementaryCodePoint - 1) != 1:
Errln("0xffff")
    if UChar.CharCount(UChar.MinSupplementaryCodePoint) != 2:
Errln("0x010000")
proc TestToCodePoint*() =
    var pairs: char[] = @[cast[char](UChar.MinHighSurrogate + 0), cast[char](UChar.MinLowSurrogate + 0), cast[char](UChar.MinHighSurrogate + 1), cast[char](UChar.MinLowSurrogate + 1), cast[char](UChar.MinHighSurrogate + 2), cast[char](UChar.MinLowSurrogate + 2), cast[char](UChar.MaxHighSurrogate - 2), cast[char](UChar.MaxLowSurrogate - 2), cast[char](UChar.MaxHighSurrogate - 1), cast[char](UChar.MaxLowSurrogate - 1), cast[char](UChar.MaxHighSurrogate - 0), cast[char](UChar.MaxLowSurrogate - 0)]
      var i: int = 0
      while i < pairs.Length:
          var cp: int = UChar.ToCodePoint(pairs[i], pairs[i + 1])
          if pairs[i] != UTF16.GetLeadSurrogate(cp) || pairs[i + 1] != UTF16.GetTrailSurrogate(cp):
Errln(pairs[i].ToHexString + ", " + pairs[i + 1])
              break
          i = 2
proc TestCodePointAtBefore*() =
    var s: String = "" + UChar.MinHighSurrogate + UChar.MinHighSurrogate + UChar.MinLowSurrogate + UChar.MinLowSurrogate
    var c: char[] = s.ToCharArray
    var avalues: int[] = @[UChar.MinHighSurrogate, UChar.ToCodePoint(UChar.MinHighSurrogate, UChar.MinLowSurrogate), UChar.MinLowSurrogate, UChar.MinLowSurrogate]
    var bvalues: int[] = @[UChar.MinHighSurrogate, UChar.MinHighSurrogate, UChar.ToCodePoint(UChar.MinHighSurrogate, UChar.MinLowSurrogate), UChar.MinLowSurrogate]
    var sp: ReadOnlySpan<char> = s.AsSpan
      var i: int = 0
      while i < avalues.Length:
          if UChar.CodePointAt(s, i) != avalues[i]:
Errln("string at: " + i)
          if UChar.CodePointAt(c, i) != avalues[i]:
Errln("chars at: " + i)
          if UChar.CodePointAt(sp, i) != avalues[i]:
Errln("stringbuffer at: " + i)
          if UChar.CodePointBefore(s, i + 1) != bvalues[i]:
Errln("string before: " + i)
          if UChar.CodePointBefore(c, i + 1) != bvalues[i]:
Errln("chars before: " + i)
          if UChar.CodePointBefore(sp, i + 1) != bvalues[i]:
Errln("stringbuffer before: " + i)
++i
Logln("Testing codePointAtBefore with limit ...")
      var i: int = 0
      while i < avalues.Length:
          if UChar.CodePointAt(c, i, 4) != avalues[i]:
Errln("chars at: " + i)
          if UChar.CodePointBefore(c, i + 1, 0) != bvalues[i]:
Errln("chars before: " + i)
++i
proc TestToChars*() =
    var chars: char[] = seq[char]
    var cp: int = UChar.ToCodePoint(UChar.MinHighSurrogate, UChar.MinLowSurrogate)
UChar.ToChars(cp, chars, 1)
    if chars[1] != UChar.MinHighSurrogate || chars[2] != UChar.MinLowSurrogate:
Errln("fail")
    chars = UChar.ToChars(cp)
    if chars[0] != UChar.MinHighSurrogate || chars[1] != UChar.MinLowSurrogate:
Errln("fail")
type
  CodePointCountTest = ref object


proc Str(s: String, start: int, limit: int): String =
    if s == nil:
        s = ""
    return "codePointCount('" + Utility.Escape(s) + "' " + start + ", " + limit + ")"
proc Test(s: String, start: int, limit: int, expected: int) =
    var length: int = limit - start
    var val1: int = UChar.CodePointCount(s.AsSpan(start, length))
    var val2: int = UChar.CodePointCount(s, start, length)
    if val1 != expected:
Errln("char[] " + Str(s, start, limit) + "(" + val1 + ") != " + expected)

    elif val2 != expected:
Errln("String " + Str(s, start, limit) + "(" + val2 + ") != " + expected)
    else:
      if IsVerbose:
Logln(Str(s, start, limit) + " == " + expected)
proc Fail(s: String, start: int, limit: int, exc: Type) =
    try:
UChar.CodePointCount(s, start, limit - start)
Errln("unexpected success " + Str(s, start, limit))
    except Exception:
        var isAssignableFrom: bool = exc.IsAssignableFrom(e.GetType)
        if !isAssignableFrom:
Warnln("bad exception " + Str(s, start, limit) + e.GetType.Name)
proc TestCodePointCount*() =
    var test: CodePointCountTest = CodePointCountTest
test.Fail(nil, 0, 1, type(ArgumentNullException))
test.Fail("a", -1, 0, type(ArgumentOutOfRangeException))
test.Fail("a", 1, 2, type(ArgumentOutOfRangeException))
test.Fail("a", 1, 0, type(ArgumentOutOfRangeException))
test.Test("", 0, 0, 0)
test.Test("�", 0, 1, 1)
test.Test("�", 0, 1, 1)
test.Test("𐀀", 0, 1, 1)
test.Test("𐀀", 1, 2, 1)
test.Test("𐀀", 0, 2, 1)
test.Test("��", 0, 1, 1)
test.Test("��", 1, 2, 1)
test.Test("��", 0, 2, 2)
test.Test("�𐀀", 0, 2, 2)
test.Test("�𐀀", 1, 3, 1)
test.Test("�𐀀", 0, 3, 2)
test.Test("𐀀�", 0, 2, 1)
test.Test("𐀀�", 1, 3, 2)
test.Test("𐀀�", 0, 3, 2)
type
  OffsetByCodePointsTest = ref object


proc Str(s: String, start: int, count: int, index: int, offset: int): String =
    return "offsetByCodePoints('" + Utility.Escape(s) + "' " + start + ", " + count + ", " + index + ", " + offset + ")"
proc Test(s: String, start: int, count: int, index: int, offset: int, expected: int, flip: bool) =
    var chars: char[] = s.ToCharArray
    var strng: String = s.Substring(start, count)
    var val1: int = UChar.OffsetByCodePoints(chars, start, count, index, offset)
    var val2: int = UChar.OffsetByCodePoints(strng, index - start, offset) + start
    if val1 != expected:
TestFmwk.Errln("char[] " + Str(s, start, count, index, offset) + "(" + val1 + ") != " + expected)

    elif val2 != expected:
TestFmwk.Errln("String " + Str(s, start, count, index, offset) + "(" + val2 + ") != " + expected)
    else:
      if TestFmwk.IsVerbose:
TestFmwk.Logln(Str(s, start, count, index, offset) + " == " + expected)
    if flip:
        val1 = UChar.OffsetByCodePoints(chars, start, count, expected, -offset)
        val2 = UChar.OffsetByCodePoints(strng, expected - start, -offset) + start
        if val1 != index:
TestFmwk.Errln("char[] " + Str(s, start, count, expected, -offset) + "(" + val1 + ") != " + index)

        elif val2 != index:
TestFmwk.Errln("String " + Str(s, start, count, expected, -offset) + "(" + val2 + ") != " + index)
        else:
          if TestFmwk.IsVerbose:
TestFmwk.Logln(Str(s, start, count, expected, -offset) + " == " + index)
proc Fail(text: seq[char], start: int, count: int, index: int, offset: int, exc: Type) =
    try:
UChar.OffsetByCodePoints(text, start, count, index, offset)
Errln("unexpected success " + Str(String(text), start, count, index, offset))
    except Exception:
        var isAssignableFrom: bool = exc.IsAssignableFrom(e.GetType)
        if !isAssignableFrom:
Errln("bad exception " + Str(String(text), start, count, index, offset) + e.GetType.Name)
proc Fail(text: String, index: int, offset: int, exc: Type) =
    try:
UChar.OffsetByCodePoints(text, index, offset)
Errln("unexpected success " + Str(text, index, offset, 0, text.Length))
    except Exception:
        var isAssignableFrom: bool = exc.IsAssignableFrom(e.GetType)
        if !isAssignableFrom:
Errln("bad exception " + Str(text, 0, text.Length, index, offset) + e.GetType.Name)
proc TestOffsetByCodePoints*() =
    var test: OffsetByCodePointsTest = OffsetByCodePointsTest
test.Test("�𐀀", 0, 2, 0, 1, 1, true)
test.Fail(cast[char[]](nil), 0, 1, 0, 1, type(ArgumentNullException))
test.Fail(cast[String](nil), 0, 1, type(ArgumentNullException))
test.Fail("abc", -1, 0, type(ArgumentOutOfRangeException))
test.Fail("abc", 4, 0, type(ArgumentOutOfRangeException))
test.Fail("abc", 1, -2, type(ArgumentOutOfRangeException))
test.Fail("abc", 2, 2, type(ArgumentOutOfRangeException))
    var abc: char[] = "abc".ToCharArray
test.Fail(abc, -1, 2, 0, 0, type(ArgumentOutOfRangeException))
test.Fail(abc, 2, 2, 3, 0, type(ArgumentOutOfRangeException))
test.Fail(abc, 1, -1, 0, 0, type(ArgumentOutOfRangeException))
test.Fail(abc, 1, 1, 2, -2, type(ArgumentOutOfRangeException))
test.Fail(abc, 1, 1, 1, 2, type(ArgumentOutOfRangeException))
test.Fail(abc, 1, 2, 1, 3, type(ArgumentOutOfRangeException))
test.Fail(abc, 0, 2, 2, -3, type(ArgumentOutOfRangeException))
test.Test("", 0, 0, 0, 0, 0, false)
test.Test("�", 0, 1, 0, 1, 1, true)
test.Test("�", 0, 1, 0, 1, 1, true)
    var s: String = "𐀀"
test.Test(s, 0, 1, 0, 1, 1, true)
test.Test(s, 0, 2, 0, 1, 2, true)
test.Test(s, 0, 2, 1, 1, 2, false)
test.Test(s, 1, 1, 1, 1, 2, true)
    s = "��"
test.Test(s, 0, 1, 0, 1, 1, true)
test.Test(s, 0, 2, 0, 1, 1, true)
test.Test(s, 0, 2, 0, 2, 2, true)
test.Test(s, 0, 2, 1, 1, 2, true)
test.Test(s, 1, 1, 1, 1, 2, true)
    s = "�𐀀"
test.Test(s, 0, 1, 0, 1, 1, true)
test.Test(s, 0, 2, 0, 1, 1, true)
test.Test(s, 0, 2, 0, 2, 2, true)
test.Test(s, 0, 2, 1, 1, 2, true)
test.Test(s, 0, 3, 0, 1, 1, true)
test.Test(s, 0, 3, 0, 2, 3, true)
test.Test(s, 0, 3, 1, 1, 3, true)
test.Test(s, 0, 3, 2, 1, 3, false)
test.Test(s, 1, 1, 1, 1, 2, true)
test.Test(s, 1, 2, 1, 1, 3, true)
test.Test(s, 1, 2, 2, 1, 3, false)
test.Test(s, 2, 1, 2, 1, 3, true)
    s = "𐀀�"
test.Test(s, 0, 1, 0, 1, 1, true)
test.Test(s, 0, 2, 0, 1, 2, true)
test.Test(s, 0, 2, 1, 1, 2, false)
test.Test(s, 0, 3, 0, 1, 2, true)
test.Test(s, 0, 3, 0, 2, 3, true)
test.Test(s, 0, 3, 1, 1, 2, false)
test.Test(s, 0, 3, 1, 2, 3, false)
test.Test(s, 0, 3, 2, 1, 3, true)
test.Test(s, 1, 1, 1, 1, 2, true)
test.Test(s, 1, 2, 1, 1, 2, true)
test.Test(s, 1, 2, 1, 2, 3, true)
test.Test(s, 1, 2, 2, 1, 3, true)
test.Test(s, 2, 1, 2, 1, 3, true)