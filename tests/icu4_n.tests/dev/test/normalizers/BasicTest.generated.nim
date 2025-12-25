# "Namespace: ICU4N.Dev.Test.Normalizers"
type
  BasicTest = ref object


proc TestCustomComp_String*() =
    var pairs: string[][] = @[@["\uD801\uE000\uDFFE", ""], @["\uD800\uD801\uE000\uDFFE\uDFFF", "\uD7FF\uFFFF"], @["\uD800\uD801\uDFFE\uDFFF", "\uD7FF\U000107FE\uFFFF"], @["\uE001\U000110B9\u0345\u0308\u0327", "\uE002\U000110B9\u0327\u0345"], @["\uE010\U000F0011\uE012", "\uE011\uE012"], @["\uE010\U000F0011\U000F0011\uE012", "\uE011\U000F0010"], @["\uE111\u1161\uE112\u1162", "\uAE4C\u1102\u0062\u1162"], @["\uFFF3\uFFF7\U00010036\U00010077", "\U00010037\U00010037\uFFF6\U00010037"]]
    var customNorm2: Normalizer2
    var assembly: Assembly = type(BasicTest).Assembly
    customNorm2 = Normalizer2.GetInstance(assembly.GetManifestResourceStream("ICU4N.Dev.Data.TestData.testnorm.nrm"), "testnorm", Normalizer2Mode.Compose)
    var resultSpan: Span<char> = newSeq[char](64)
      var i: int = 0
      while i < pairs.Length:
          var pair: string[] = pairs[i]
          var input: string = Utility.Unescape(pair[0])
          var expected: string = Utility.Unescape(pair[1])
          var result: string = customNorm2.Normalize(input)
          if !result.Equals(expected):
Errln("custom compose Normalizer2 did not normalize input " + i + " as expected")
assertTrue("", customNorm2.TryNormalize(input, resultSpan,           var charsLength: int))
          if !resultSpan.Slice(0, charsLength).SequenceEqual(expected.AsSpan):
Errln("custom compose Normalizer2 did not normalize input " + i + " as expected")
++i
proc TestCustomComp_ReadOnlySpan*() =
    var pairs: string[][] = @[@["\uD801\uE000\uDFFE", ""], @["\uD800\uD801\uE000\uDFFE\uDFFF", "\uD7FF\uFFFF"], @["\uD800\uD801\uDFFE\uDFFF", "\uD7FF\U000107FE\uFFFF"], @["\uE001\U000110B9\u0345\u0308\u0327", "\uE002\U000110B9\u0327\u0345"], @["\uE010\U000F0011\uE012", "\uE011\uE012"], @["\uE010\U000F0011\U000F0011\uE012", "\uE011\U000F0010"], @["\uE111\u1161\uE112\u1162", "\uAE4C\u1102\u0062\u1162"], @["\uFFF3\uFFF7\U00010036\U00010077", "\U00010037\U00010037\uFFF6\U00010037"]]
    var customNorm2: Normalizer2
    var assembly: Assembly = type(BasicTest).Assembly
    customNorm2 = Normalizer2.GetInstance(assembly.GetManifestResourceStream("ICU4N.Dev.Data.TestData.testnorm.nrm"), "testnorm", Normalizer2Mode.Compose)
    var resultSpan: Span<char> = newSeq[char](64)
      var i: int = 0
      while i < pairs.Length:
          var pair: string[] = pairs[i]
          var input: string = Utility.Unescape(pair[0])
          var expected: string = Utility.Unescape(pair[1])
          var result: string = customNorm2.Normalize(input.AsSpan)
          if !result.Equals(expected):
Errln("custom compose Normalizer2 did not normalize input " + i + " as expected")
assertTrue("", customNorm2.TryNormalize(input.AsSpan, resultSpan,           var charsLength: int))
          if !resultSpan.Slice(0, charsLength).SequenceEqual(expected.AsSpan):
Errln("custom compose Normalizer2 did not normalize input " + i + " as expected")
++i
proc TestCustomComp_CharArray*() =
    var pairs: string[][] = @[@["\uD801\uE000\uDFFE", ""], @["\uD800\uD801\uE000\uDFFE\uDFFF", "\uD7FF\uFFFF"], @["\uD800\uD801\uDFFE\uDFFF", "\uD7FF\U000107FE\uFFFF"], @["\uE001\U000110B9\u0345\u0308\u0327", "\uE002\U000110B9\u0327\u0345"], @["\uE010\U000F0011\uE012", "\uE011\uE012"], @["\uE010\U000F0011\U000F0011\uE012", "\uE011\U000F0010"], @["\uE111\u1161\uE112\u1162", "\uAE4C\u1102\u0062\u1162"], @["\uFFF3\uFFF7\U00010036\U00010077", "\U00010037\U00010037\uFFF6\U00010037"]]
    var customNorm2: Normalizer2
    var assembly: Assembly = type(BasicTest).Assembly
    customNorm2 = Normalizer2.GetInstance(assembly.GetManifestResourceStream("ICU4N.Dev.Data.TestData.testnorm.nrm"), "testnorm", Normalizer2Mode.Compose)
    var resultSpan: Span<char> = newSeq[char](64)
      var i: int = 0
      while i < pairs.Length:
          var pair: string[] = pairs[i]
          var input: string = Utility.Unescape(pair[0])
          var expected: string = Utility.Unescape(pair[1])
          var result: string = customNorm2.Normalize(input.ToCharArray)
          if !result.Equals(expected):
Errln("custom compose Normalizer2 did not normalize input " + i + " as expected")
assertTrue("", customNorm2.TryNormalize(input.ToCharArray, resultSpan,           var charsLength: int))
          if !resultSpan.Slice(0, charsLength).SequenceEqual(expected.AsSpan):
Errln("custom compose Normalizer2 did not normalize input " + i + " as expected")
++i
proc TestCustomFCC_String*() =
    var pairs: string[][] = @[@["\uD801\uE000\uDFFE", ""], @["\uD800\uD801\uE000\uDFFE\uDFFF", "\uD7FF\uFFFF"], @["\uD800\uD801\uDFFE\uDFFF", "\uD7FF\U000107FE\uFFFF"], @["\uE001\U000110B9\u0345\u0308\u0327", "\uE001\U000110B9\u0327\u0308\u0345"], @["\uE010\U000F0011\uE012", "\uE011\uE012"], @["\uE010\U000F0011\U000F0011\uE012", "\uE011\U000F0010"], @["\uE111\u1161\uE112\u1162", "\uAE4C\u1102\u0062\u1162"], @["\uFFF3\uFFF7\U00010036\U00010077", "\U00010037\U00010037\uFFF6\U00010037"]]
    var assembly: Assembly = type(BasicTest).Assembly
    var customNorm2: Normalizer2
    customNorm2 = Normalizer2.GetInstance(assembly.GetManifestResourceStream("ICU4N.Dev.Data.TestData.testnorm.nrm"), "testnorm", Normalizer2Mode.ComposeContiguous)
    var resultSpan: Span<char> = newSeq[char](64)
      var i: int = 0
      while i < pairs.Length:
          var pair: string[] = pairs[i]
          var input: string = Utility.Unescape(pair[0])
          var expected: string = Utility.Unescape(pair[1])
          var result: string = customNorm2.Normalize(input)
          if !result.Equals(expected):
Errln("custom FCC Normalizer2 did not normalize input " + i + " as expected")
assertTrue("", customNorm2.TryNormalize(input, resultSpan,           var charsLength: int))
          if !resultSpan.Slice(0, charsLength).SequenceEqual(expected.AsSpan):
Errln("custom compose Normalizer2 did not normalize input " + i + " as expected")
++i
proc TestCustomFCC_ReadOnlySpan*() =
    var pairs: string[][] = @[@["\uD801\uE000\uDFFE", ""], @["\uD800\uD801\uE000\uDFFE\uDFFF", "\uD7FF\uFFFF"], @["\uD800\uD801\uDFFE\uDFFF", "\uD7FF\U000107FE\uFFFF"], @["\uE001\U000110B9\u0345\u0308\u0327", "\uE001\U000110B9\u0327\u0308\u0345"], @["\uE010\U000F0011\uE012", "\uE011\uE012"], @["\uE010\U000F0011\U000F0011\uE012", "\uE011\U000F0010"], @["\uE111\u1161\uE112\u1162", "\uAE4C\u1102\u0062\u1162"], @["\uFFF3\uFFF7\U00010036\U00010077", "\U00010037\U00010037\uFFF6\U00010037"]]
    var assembly: Assembly = type(BasicTest).Assembly
    var customNorm2: Normalizer2
    customNorm2 = Normalizer2.GetInstance(assembly.GetManifestResourceStream("ICU4N.Dev.Data.TestData.testnorm.nrm"), "testnorm", Normalizer2Mode.ComposeContiguous)
    var resultSpan: Span<char> = newSeq[char](64)
      var i: int = 0
      while i < pairs.Length:
          var pair: string[] = pairs[i]
          var input: string = Utility.Unescape(pair[0])
          var expected: string = Utility.Unescape(pair[1])
          var result: string = customNorm2.Normalize(input.AsSpan)
          if !result.Equals(expected):
Errln("custom FCC Normalizer2 did not normalize input " + i + " as expected")
assertTrue("", customNorm2.TryNormalize(input.AsSpan, resultSpan,           var charsLength: int))
          if !resultSpan.Slice(0, charsLength).SequenceEqual(expected.AsSpan):
Errln("custom compose Normalizer2 did not normalize input " + i + " as expected")
++i
proc TestCustomFCC_CharArray*() =
    var pairs: string[][] = @[@["\uD801\uE000\uDFFE", ""], @["\uD800\uD801\uE000\uDFFE\uDFFF", "\uD7FF\uFFFF"], @["\uD800\uD801\uDFFE\uDFFF", "\uD7FF\U000107FE\uFFFF"], @["\uE001\U000110B9\u0345\u0308\u0327", "\uE001\U000110B9\u0327\u0308\u0345"], @["\uE010\U000F0011\uE012", "\uE011\uE012"], @["\uE010\U000F0011\U000F0011\uE012", "\uE011\U000F0010"], @["\uE111\u1161\uE112\u1162", "\uAE4C\u1102\u0062\u1162"], @["\uFFF3\uFFF7\U00010036\U00010077", "\U00010037\U00010037\uFFF6\U00010037"]]
    var assembly: Assembly = type(BasicTest).Assembly
    var customNorm2: Normalizer2
    customNorm2 = Normalizer2.GetInstance(assembly.GetManifestResourceStream("ICU4N.Dev.Data.TestData.testnorm.nrm"), "testnorm", Normalizer2Mode.ComposeContiguous)
    var resultSpan: Span<char> = newSeq[char](64)
      var i: int = 0
      while i < pairs.Length:
          var pair: string[] = pairs[i]
          var input: string = Utility.Unescape(pair[0])
          var expected: string = Utility.Unescape(pair[1])
          var result: string = customNorm2.Normalize(input.ToCharArray)
          if !result.Equals(expected):
Errln("custom FCC Normalizer2 did not normalize input " + i + " as expected")
assertTrue("", customNorm2.TryNormalize(input.ToCharArray, resultSpan,           var charsLength: int))
          if !resultSpan.Slice(0, charsLength).SequenceEqual(expected.AsSpan):
Errln("custom compose Normalizer2 did not normalize input " + i + " as expected")
++i
proc TestFilteredNormalizer2_String*() =
    var nfcNorm2: Normalizer2 = Normalizer2.NFCInstance
    var filter: UnicodeSet = UnicodeSet("[^ -ÿ̐-̟]")
    var fn2: FilteredNormalizer2 = FilteredNormalizer2(nfcNorm2, filter)
    var c: int
      c = 0
      while c <= 1023:
          var expectedCC: int =           if filter.Contains(c):
nfcNorm2.GetCombiningClass(c)
          else:
0
          var cc: int = fn2.GetCombiningClass(c)
assertEquals("FilteredNormalizer2(NFC, ^A0-FF,310-31F).getCombiningClass(U+" + Hex(c) + ")==filtered NFC.getCC()", expectedCC, cc)
++c
    var sb: StringBuilder = StringBuilder
    var input: string = "äǟ"
assertEquals("filtered normalize()", "äǟ", fn2.Normalize(input, sb).ToString)
assertTrue("filtered hasBoundaryAfter()", fn2.HasBoundaryAfter('�'))
assertTrue("filtered isInert()", fn2.IsInert(787))
proc TestFilteredNormalizer2_ReadOnlySpan*() =
    var nfcNorm2: Normalizer2 = Normalizer2.NFCInstance
    var filter: UnicodeSet = UnicodeSet("[^ -ÿ̐-̟]")
    var fn2: FilteredNormalizer2 = FilteredNormalizer2(nfcNorm2, filter)
    var c: int
      c = 0
      while c <= 1023:
          var expectedCC: int =           if filter.Contains(c):
nfcNorm2.GetCombiningClass(c)
          else:
0
          var cc: int = fn2.GetCombiningClass(c)
assertEquals("FilteredNormalizer2(NFC, ^A0-FF,310-31F).getCombiningClass(U+" + Hex(c) + ")==filtered NFC.getCC()", expectedCC, cc)
++c
    var sb: StringBuilder = StringBuilder
    var input: string = "äǟ"
assertEquals("filtered normalize()", "äǟ", fn2.Normalize(input.AsSpan, sb).ToString)
assertTrue("filtered hasBoundaryAfter()", fn2.HasBoundaryAfter('�'))
assertTrue("filtered isInert()", fn2.IsInert(787))
proc TestFilteredNormalizer2_CharArray*() =
    var nfcNorm2: Normalizer2 = Normalizer2.NFCInstance
    var filter: UnicodeSet = UnicodeSet("[^ -ÿ̐-̟]")
    var fn2: FilteredNormalizer2 = FilteredNormalizer2(nfcNorm2, filter)
    var c: int
      c = 0
      while c <= 1023:
          var expectedCC: int =           if filter.Contains(c):
nfcNorm2.GetCombiningClass(c)
          else:
0
          var cc: int = fn2.GetCombiningClass(c)
assertEquals("FilteredNormalizer2(NFC, ^A0-FF,310-31F).getCombiningClass(U+" + Hex(c) + ")==filtered NFC.getCC()", expectedCC, cc)
++c
    var sb: StringBuilder = StringBuilder
    var input: string = "äǟ"
assertEquals("filtered normalize()", "äǟ", fn2.Normalize(input.ToCharArray, sb).ToString)
assertTrue("filtered hasBoundaryAfter()", fn2.HasBoundaryAfter('�'))
assertTrue("filtered isInert()", fn2.IsInert(787))
proc TestFilteredAppend_String*() =
    var nfcNorm2: Normalizer2 = Normalizer2.NFCInstance
    var filter: UnicodeSet = UnicodeSet("[^ -ÿ̐-̟]")
    var fn2: FilteredNormalizer2 = FilteredNormalizer2(nfcNorm2, filter)
    var first: string = "a̓a"
    var sb: StringBuilder = StringBuilder(first)
    var second: string = "́̓"
    var expected: string = "a̓á̓"
assertEquals("append()", expected, fn2.Append(sb, second).ToString)
    var resultSpan: Span<char> = newSeq[char](64)
assertTrue("", fn2.TryConcat(first, second, resultSpan,     var charsLength: int))
assertEquals("TryConcat()", expected, resultSpan.Slice(0, charsLength).ToString)
sb.Replace(0, 2147483647 - 0, "a̓a")
    expected = "a̓á̓"
assertEquals("normalizeSecondAndAppend()", expected, fn2.NormalizeSecondAndAppend(sb, second).ToString)
assertTrue("", fn2.TryNormalizeSecondAndConcat(first, second, resultSpan, charsLength))
assertEquals("TryNormalizeSecondAndConcat()", expected, resultSpan.Slice(0, charsLength).ToString)
    var input: string = "a̓á̓"
assertEquals("normalize()", "a̓á̓", fn2.Normalize(input))
assertTrue("", fn2.TryNormalize(input, resultSpan, charsLength))
assertEquals("TryNormalize()", expected, resultSpan.Slice(0, charsLength).ToString)
proc TestFilteredAppend_ReadOnlySpan*() =
    var nfcNorm2: Normalizer2 = Normalizer2.NFCInstance
    var filter: UnicodeSet = UnicodeSet("[^ -ÿ̐-̟]")
    var fn2: FilteredNormalizer2 = FilteredNormalizer2(nfcNorm2, filter)
    var first: string = "a̓a"
    var sb: StringBuilder = StringBuilder(first)
    var second: string = "́̓"
    var expected: string = "a̓á̓"
assertEquals("append()", expected, fn2.Append(sb, second.AsSpan).ToString)
    var resultSpan: Span<char> = newSeq[char](64)
assertTrue("", fn2.TryConcat(first.AsSpan, second.AsSpan, resultSpan,     var charsLength: int))
assertEquals("TryConcat()", expected, resultSpan.Slice(0, charsLength).ToString)
sb.Replace(0, 2147483647 - 0, "a̓a")
    expected = "a̓á̓"
assertEquals("normalizeSecondAndAppend()", expected, fn2.NormalizeSecondAndAppend(sb, second.AsSpan).ToString)
assertTrue("", fn2.TryNormalizeSecondAndConcat(first.AsSpan, second.AsSpan, resultSpan, charsLength))
assertEquals("TryNormalizeSecondAndConcat()", expected, resultSpan.Slice(0, charsLength).ToString)
    var input: string = "a̓á̓"
assertEquals("normalize()", "a̓á̓", fn2.Normalize(input.AsSpan))
assertTrue("", fn2.TryNormalize(input.AsSpan, resultSpan, charsLength))
assertEquals("TryNormalize()", expected, resultSpan.Slice(0, charsLength).ToString)
proc TestFilteredAppend_CharArray*() =
    var nfcNorm2: Normalizer2 = Normalizer2.NFCInstance
    var filter: UnicodeSet = UnicodeSet("[^ -ÿ̐-̟]")
    var fn2: FilteredNormalizer2 = FilteredNormalizer2(nfcNorm2, filter)
    var first: string = "a̓a"
    var sb: StringBuilder = StringBuilder(first)
    var second: string = "́̓"
    var expected: string = "a̓á̓"
assertEquals("append()", expected, fn2.Append(sb, second.ToCharArray).ToString)
    var resultSpan: Span<char> = newSeq[char](64)
assertTrue("", fn2.TryConcat(first.ToCharArray, second.ToCharArray, resultSpan,     var charsLength: int))
assertEquals("TryConcat()", expected, resultSpan.Slice(0, charsLength).ToString)
sb.Replace(0, 2147483647 - 0, "a̓a")
    expected = "a̓á̓"
assertEquals("normalizeSecondAndAppend()", expected, fn2.NormalizeSecondAndAppend(sb, second.ToCharArray).ToString)
assertTrue("", fn2.TryNormalizeSecondAndConcat(first.ToCharArray, second.ToCharArray, resultSpan, charsLength))
assertEquals("TryNormalizeSecondAndConcat()", expected, resultSpan.Slice(0, charsLength).ToString)
    var input: string = "a̓á̓"
assertEquals("normalize()", "a̓á̓", fn2.Normalize(input.ToCharArray))
assertTrue("", fn2.TryNormalize(input.ToCharArray, resultSpan, charsLength))
assertEquals("TryNormalize()", expected, resultSpan.Slice(0, charsLength).ToString)
proc TestGetEasyToUseInstance_String*() =
    var @in: string = " Ḉ"
    var n2: Normalizer2 = Normalizer2.NFCInstance
    var @out: string = n2.Normalize(@in)
assertEquals("getNFCInstance() did not return an NFC instance " + "(normalizes to " + Prettify(@out) + ')', " Ḉ", @out)
    n2 = Normalizer2.NFDInstance
    @out = n2.Normalize(@in)
assertEquals("getNFDInstance() did not return an NFD instance " + "(normalizes to " + Prettify(@out) + ')', " Ḉ", @out)
    n2 = Normalizer2.NFKCInstance
    @out = n2.Normalize(@in)
assertEquals("getNFKCInstance() did not return an NFKC instance " + "(normalizes to " + Prettify(@out) + ')', " Ḉ", @out)
    n2 = Normalizer2.NFKDInstance
    @out = n2.Normalize(@in)
assertEquals("getNFKDInstance() did not return an NFKD instance " + "(normalizes to " + Prettify(@out) + ')', " Ḉ", @out)
    n2 = Normalizer2.NFKCCaseFoldInstance
    @out = n2.Normalize(@in)
assertEquals("getNFKCCasefoldInstance() did not return an NFKC_Casefold instance " + "(normalizes to " + Prettify(@out) + ')', " ḉ", @out)
proc TestGetEasyToUseInstance_ReadOnlySpan*() =
    var @in: string = " Ḉ"
    var n2: Normalizer2 = Normalizer2.NFCInstance
    var @out: string = n2.Normalize(@in.AsSpan)
assertEquals("getNFCInstance() did not return an NFC instance " + "(normalizes to " + Prettify(@out) + ')', " Ḉ", @out)
    n2 = Normalizer2.NFDInstance
    @out = n2.Normalize(@in.AsSpan)
assertEquals("getNFDInstance() did not return an NFD instance " + "(normalizes to " + Prettify(@out) + ')', " Ḉ", @out)
    n2 = Normalizer2.NFKCInstance
    @out = n2.Normalize(@in.AsSpan)
assertEquals("getNFKCInstance() did not return an NFKC instance " + "(normalizes to " + Prettify(@out) + ')', " Ḉ", @out)
    n2 = Normalizer2.NFKDInstance
    @out = n2.Normalize(@in.AsSpan)
assertEquals("getNFKDInstance() did not return an NFKD instance " + "(normalizes to " + Prettify(@out) + ')', " Ḉ", @out)
    n2 = Normalizer2.NFKCCaseFoldInstance
    @out = n2.Normalize(@in.AsSpan)
assertEquals("getNFKCCasefoldInstance() did not return an NFKC_Casefold instance " + "(normalizes to " + Prettify(@out) + ')', " ḉ", @out)
proc TestGetEasyToUseInstance_CharArray*() =
    var @in: string = " Ḉ"
    var n2: Normalizer2 = Normalizer2.NFCInstance
    var @out: string = n2.Normalize(@in.ToCharArray)
assertEquals("getNFCInstance() did not return an NFC instance " + "(normalizes to " + Prettify(@out) + ')', " Ḉ", @out)
    n2 = Normalizer2.NFDInstance
    @out = n2.Normalize(@in.ToCharArray)
assertEquals("getNFDInstance() did not return an NFD instance " + "(normalizes to " + Prettify(@out) + ')', " Ḉ", @out)
    n2 = Normalizer2.NFKCInstance
    @out = n2.Normalize(@in.ToCharArray)
assertEquals("getNFKCInstance() did not return an NFKC instance " + "(normalizes to " + Prettify(@out) + ')', " Ḉ", @out)
    n2 = Normalizer2.NFKDInstance
    @out = n2.Normalize(@in.ToCharArray)
assertEquals("getNFKDInstance() did not return an NFKD instance " + "(normalizes to " + Prettify(@out) + ')', " Ḉ", @out)
    n2 = Normalizer2.NFKCCaseFoldInstance
    @out = n2.Normalize(@in.ToCharArray)
assertEquals("getNFKCCasefoldInstance() did not return an NFKC_Casefold instance " + "(normalizes to " + Prettify(@out) + ')', " ḉ", @out)
proc TestLowMappingToEmpty_D_String*() =
    var n2: Normalizer2 = Normalizer2.GetInstance(nil, "nfkc_cf", Normalizer2Mode.Decompose)
checkLowMappingToEmpty(n2)
    var sh: string = "­"
assertFalse("soft hyphen is not normalized", n2.IsNormalized(sh))
    var result: string = n2.Normalize(sh)
assertTrue("soft hyphen normalizes to empty", result == string.Empty)
assertEquals("soft hyphen QC=No", QuickCheckResult.No, n2.QuickCheck(sh))
assertEquals("soft hyphen spanQuickCheckYes", 0, n2.SpanQuickCheckYes(sh))
    var s: string = "­Ä­̣"
    result = n2.Normalize(s)
assertEquals("normalize string with soft hyphens", "ạ̈", result)
proc TestLowMappingToEmpty_D_ReadOnlySpan*() =
    var n2: Normalizer2 = Normalizer2.GetInstance(nil, "nfkc_cf", Normalizer2Mode.Decompose)
checkLowMappingToEmpty(n2)
    var sh: string = "­"
assertFalse("soft hyphen is not normalized", n2.IsNormalized(sh.AsSpan))
    var result: string = n2.Normalize(sh.AsSpan)
assertTrue("soft hyphen normalizes to empty", result == string.Empty)
assertEquals("soft hyphen QC=No", QuickCheckResult.No, n2.QuickCheck(sh.AsSpan))
assertEquals("soft hyphen spanQuickCheckYes", 0, n2.SpanQuickCheckYes(sh.AsSpan))
    var s: string = "­Ä­̣"
    result = n2.Normalize(s.AsSpan)
assertEquals("normalize string with soft hyphens", "ạ̈", result)
proc TestLowMappingToEmpty_D_CharArray*() =
    var n2: Normalizer2 = Normalizer2.GetInstance(nil, "nfkc_cf", Normalizer2Mode.Decompose)
checkLowMappingToEmpty(n2)
    var sh: string = "­"
assertFalse("soft hyphen is not normalized", n2.IsNormalized(sh.ToCharArray))
    var result: string = n2.Normalize(sh.ToCharArray)
assertTrue("soft hyphen normalizes to empty", result == string.Empty)
assertEquals("soft hyphen QC=No", QuickCheckResult.No, n2.QuickCheck(sh.ToCharArray))
assertEquals("soft hyphen spanQuickCheckYes", 0, n2.SpanQuickCheckYes(sh.ToCharArray))
    var s: string = "­Ä­̣"
    result = n2.Normalize(s.ToCharArray)
assertEquals("normalize string with soft hyphens", "ạ̈", result)
proc TestLowMappingToEmpty_FCD_String*() =
    var n2: Normalizer2 = Normalizer2.GetInstance(nil, "nfkc_cf", Normalizer2Mode.FCD)
checkLowMappingToEmpty(n2)
    var sh: string = "­"
assertTrue("soft hyphen is FCD", n2.IsNormalized(sh))
    var s: string = "­Ä­̣"
    var result: string = n2.Normalize(s)
assertEquals("normalize string with soft hyphens", "­ạ̈", result)
proc TestLowMappingToEmpty_FCD_ReadOnlySpan*() =
    var n2: Normalizer2 = Normalizer2.GetInstance(nil, "nfkc_cf", Normalizer2Mode.FCD)
checkLowMappingToEmpty(n2)
    var sh: string = "­"
assertTrue("soft hyphen is FCD", n2.IsNormalized(sh.AsSpan))
    var s: string = "­Ä­̣"
    var result: string = n2.Normalize(s.AsSpan)
assertEquals("normalize string with soft hyphens", "­ạ̈", result)
proc TestLowMappingToEmpty_FCD_CharArray*() =
    var n2: Normalizer2 = Normalizer2.GetInstance(nil, "nfkc_cf", Normalizer2Mode.FCD)
checkLowMappingToEmpty(n2)
    var sh: string = "­"
assertTrue("soft hyphen is FCD", n2.IsNormalized(sh.ToCharArray))
    var s: string = "­Ä­̣"
    var result: string = n2.Normalize(s.ToCharArray)
assertEquals("normalize string with soft hyphens", "­ạ̈", result)
proc TestNormalizeIllFormedText_String*() =
    var nfkc_cf: Normalizer2 = Normalizer2.NFKCCaseFoldInstance
    var src: string = "  A�ÄÄ�Ä­̣�Ạ̈," + "­�가각가ㄳ  �"
    var expected: string = "  a�ää�ạ̈�ạ̈,�가각갃  �"
    var result: string = nfkc_cf.Normalize(src)
assertEquals("normalize", expected, result)
proc TestNormalizeIllFormedText_ReadOnlySpan*() =
    var nfkc_cf: Normalizer2 = Normalizer2.NFKCCaseFoldInstance
    var src: string = "  A�ÄÄ�Ä­̣�Ạ̈," + "­�가각가ㄳ  �"
    var expected: string = "  a�ää�ạ̈�ạ̈,�가각갃  �"
    var result: string = nfkc_cf.Normalize(src.AsSpan)
assertEquals("normalize", expected, result)
proc TestNormalizeIllFormedText_CharArray*() =
    var nfkc_cf: Normalizer2 = Normalizer2.NFKCCaseFoldInstance
    var src: string = "  A�ÄÄ�Ä­̣�Ạ̈," + "­�가각가ㄳ  �"
    var expected: string = "  a�ää�ạ̈�ạ̈,�가각갃  �"
    var result: string = nfkc_cf.Normalize(src.ToCharArray)
assertEquals("normalize", expected, result)
proc TestComposeJamoTBase_String*() =
    var nfkc: Normalizer2 = Normalizer2.NFKCInstance
    var s: string = "가ᆧᄀㅏᆧ가ᆧ"
    var expected: string = "가ᆧ가ᆧ가ᆧ"
    var result: string = nfkc.Normalize(s)
assertEquals("normalize(LV+11A7)", expected, result)
assertFalse("isNormalized(LV+11A7)", nfkc.IsNormalized(s))
assertTrue("isNormalized(normalized)", nfkc.IsNormalized(result))
proc TestComposeJamoTBase_ReadOnlySpan*() =
    var nfkc: Normalizer2 = Normalizer2.NFKCInstance
    var s: string = "가ᆧᄀㅏᆧ가ᆧ"
    var expected: string = "가ᆧ가ᆧ가ᆧ"
    var result: string = nfkc.Normalize(s.AsSpan)
assertEquals("normalize(LV+11A7)", expected, result)
assertFalse("isNormalized(LV+11A7)", nfkc.IsNormalized(s.AsSpan))
assertTrue("isNormalized(normalized)", nfkc.IsNormalized(result.AsSpan))
proc TestComposeJamoTBase_CharArray*() =
    var nfkc: Normalizer2 = Normalizer2.NFKCInstance
    var s: string = "가ᆧᄀㅏᆧ가ᆧ"
    var expected: string = "가ᆧ가ᆧ가ᆧ"
    var result: string = nfkc.Normalize(s.ToCharArray)
assertEquals("normalize(LV+11A7)", expected, result)
assertFalse("isNormalized(LV+11A7)", nfkc.IsNormalized(s.ToCharArray))
assertTrue("isNormalized(normalized)", nfkc.IsNormalized(result.ToCharArray))
proc TestComposeBoundaryAfter_String*() =
    var nfkc: Normalizer2 = Normalizer2.NFKCInstance
    var s: string = "˚̹ שֶּׁ"
    var expected: string = " ̹̊ שֶּׁ"
    var result: string = nfkc.Normalize(s)
assertEquals("nfkc", expected, result)
assertFalse("U+02DA boundary-after", nfkc.HasBoundaryAfter(730))
assertFalse("U+FB2C boundary-after", nfkc.HasBoundaryAfter(64300))
proc TestComposeBoundaryAfter_ReadOnlySpan*() =
    var nfkc: Normalizer2 = Normalizer2.NFKCInstance
    var s: string = "˚̹ שֶּׁ"
    var expected: string = " ̹̊ שֶּׁ"
    var result: string = nfkc.Normalize(s.AsSpan)
assertEquals("nfkc", expected, result)
assertFalse("U+02DA boundary-after", nfkc.HasBoundaryAfter(730))
assertFalse("U+FB2C boundary-after", nfkc.HasBoundaryAfter(64300))
proc TestComposeBoundaryAfter_CharArray*() =
    var nfkc: Normalizer2 = Normalizer2.NFKCInstance
    var s: string = "˚̹ שֶּׁ"
    var expected: string = " ̹̊ שֶּׁ"
    var result: string = nfkc.Normalize(s.ToCharArray)
assertEquals("nfkc", expected, result)
assertFalse("U+02DA boundary-after", nfkc.HasBoundaryAfter(730))
assertFalse("U+FB2C boundary-after", nfkc.HasBoundaryAfter(64300))
proc TestNoopNormalizer2_String*() =
    var noop: Normalizer2 = Norm2AllModes.NoopNormalizer2
    var input: string = "̧"
assertEquals("noop.normalizeSecondAndAppend()", "ä̧", noop.NormalizeSecondAndAppend(StringBuilder("ä"), input).ToString)
assertEquals("noop.getDecomposition()", nil, noop.GetDecomposition('�'))
assertTrue("noop.hasBoundaryAfter()", noop.HasBoundaryAfter(776))
assertTrue("noop.isInert()", noop.IsInert(776))
proc TestNoopNormalizer2_ReadOnlySpan*() =
    var noop: Normalizer2 = Norm2AllModes.NoopNormalizer2
    var input: string = "̧"
assertEquals("noop.normalizeSecondAndAppend()", "ä̧", noop.NormalizeSecondAndAppend(StringBuilder("ä"), input.AsSpan).ToString)
assertEquals("noop.getDecomposition()", nil, noop.GetDecomposition('�'))
assertTrue("noop.hasBoundaryAfter()", noop.HasBoundaryAfter(776))
assertTrue("noop.isInert()", noop.IsInert(776))
proc TestNoopNormalizer2_CharArray*() =
    var noop: Normalizer2 = Norm2AllModes.NoopNormalizer2
    var input: string = "̧"
assertEquals("noop.normalizeSecondAndAppend()", "ä̧", noop.NormalizeSecondAndAppend(StringBuilder("ä"), input.ToCharArray).ToString)
assertEquals("noop.getDecomposition()", nil, noop.GetDecomposition('�'))
assertTrue("noop.hasBoundaryAfter()", noop.HasBoundaryAfter(776))
assertTrue("noop.isInert()", noop.IsInert(776))