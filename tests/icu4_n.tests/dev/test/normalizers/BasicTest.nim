# "Namespace: ICU4N.Dev.Test.Normalizers"
type
  BasicTest = ref object
    canonTests: seq[string] = @[@["cat", "cat", "cat"], @["àardvark", "àardvark", "àardvark"], @["Ḋ", "Ḋ", "Ḋ"], @["Ḋ", "Ḋ", "Ḋ"], @["Ḍ̇", "Ḍ̇", "Ḍ̇"], @["Ḍ̇", "Ḍ̇", "Ḍ̇"], @["Ḍ̇", "Ḍ̇", "Ḍ̇"], @["Ḑ̣̇", "Ḑ̣̇", "Ḑ̣̇"], @["Ḍ̨̇", "Ḍ̨̇", "Ḍ̨̇"], @["Ḕ", "Ḕ", "Ḕ"], @["Ḕ", "Ḕ", "Ḕ"], @["È̄", "È̄", "È̄"], @["Å", "Å", "Å"], @["Å", "Å", "Å"], @["Äffin", "Äffin", "Äffin"], @["Äﬃn", "Äﬃn", "Äﬃn"], @["ýffin", "ýffin", "ýffin"], @["ýﬃn", "ýﬃn", "ýﬃn"], @["Henry IV", "Henry IV", "Henry IV"], @["Henry Ⅳ", "Henry Ⅳ", "Henry Ⅳ"], @["ガ", "ガ", "ガ"], @["ガ", "ガ", "ガ"], @["ｶﾞ", "ｶﾞ", "ｶﾞ"], @["カﾞ", "カﾞ", "カﾞ"], @["ｶ゙", "ｶ゙", "ｶ゙"], @["À̖", "À̖", "À̖"], @["\U0001d15e\U0001d157\U0001d165\U0001d15e", "\U0001D157\U0001D165\U0001D157\U0001D165\U0001D157\U0001D165", "\U0001D157\U0001D165\U0001D157\U0001D165\U0001D157\U0001D165"]]
    compatTests: seq[string] = @[@["cat", "cat", "cat"], @["ﭏ", "אל", "אל"], @["Äffin", "Äffin", "Äffin"], @["Äﬃn", "Äffin", "Äffin"], @["ýffin", "ýffin", "ýffin"], @["ýﬃn", "ýffin", "ýffin"], @["Henry IV", "Henry IV", "Henry IV"], @["Henry Ⅳ", "Henry IV", "Henry IV"], @["ガ", "ガ", "ガ"], @["ガ", "ガ", "ガ"], @["ｶ゙", "ガ", "ガ"], @["ｶﾞ", "ガ", "ガ"], @["カﾞ", "ガ", "ガ"]]
    hangulCanon: seq[string] = @[@["퓛", "퓛", "퓛"], @["퓛", "퓛", "퓛"]]
    hangulCompat: seq[string] = @[]
    RAND_MAX: int = 32767
    strings: seq[string] = @["Ḍ̛̇", "Ḍ̛̇", "Ḍ̛̇", "ḍ̛̇", "ä", "ä", "Ä", "Å", "Å", "Å", "å", "a〪̖̯֚b", "a〪̖̯֚b", "a〪̖̯֚b", "A〪̖̯֚b", "Aßµﬃ\U0001040cı", "assμffi\U00010434i", "aBıΣßﬃ񟿿", "AbiσsSFfI񟿿", "AbıσSsfFi񟿿", "AbiσsSFfI񟿽", "�𐀁", "𐀀", "€�", "€𐀀", "�", "�｡", "�", "｡�", "｡𐀂", "𐀂", "𣑖", "궋궋궋궋" + "\U0001d15e\U0001d157\U0001d165\U0001d15e\U0001d15e\U0001d15e\U0001d15e" + "\U0001d15e\U0001d157\U0001d165\U0001d15e\U0001d15e\U0001d15e\U0001d15e" + "\U0001d15e\U0001d157\U0001d165\U0001d15e\U0001d15e\U0001d15e\U0001d15e" + "\U0001d157\U0001d165\U0001d15e\U0001d15e\U0001d15e\U0001d15e\U0001d15e" + "\U0001d157\U0001d165\U0001d15e\U0001d15e\U0001d15e\U0001d15e\U0001d15e" + "aaaaaaaaaaaaaaaaaazzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz" + "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" + "ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc" + "ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd" + "궋궋궋궋" + "ḍ̛̇", "궋궋궋궋" + "\U0001d157\U0001d165\U0001d15e\U0001d15e\U0001d15e\U0001d15e\U0001d15e" + "\U0001d157\U0001d165\U0001d15e\U0001d15e\U0001d15e\U0001d15e\U0001d15e" + "\U0001d157\U0001d165\U0001d15e\U0001d15e\U0001d15e\U0001d15e\U0001d15e" + "\U0001d15e\U0001d157\U0001d165\U0001d15e\U0001d15e\U0001d15e\U0001d15e" + "\U0001d15e\U0001d157\U0001d165\U0001d15e\U0001d15e\U0001d15e\U0001d15e" + "aaaaaaaaaaAAAAAAAAZZZZZZZZZZZZZZZZzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz" + "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" + "ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc" + "ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd" + "궋궋궋궋" + "Ḍ̛̇", "̴͠ͅ", "͠ι̴", "͠ᾀ̴", "͠ἀι̴", "͠ῼ̴", "͠ωι̴", "a͠͠ͅͅb", "a͠͠ͅͅb", "Ì", "ì", "ä᤻\U0002f868", "ä᤻㛼"]
    opt: seq[Temp] = @[Temp(0, "default"), Temp(Normalizer.COMPARE_CODE_POINT_ORDER, "code point order"), Temp(Normalizer.COMPARE_IGNORE_CASE, "ignore case"), Temp(Normalizer.COMPARE_CODE_POINT_ORDER | Normalizer.COMPARE_IGNORE_CASE, "code point order & ignore case"), Temp(Normalizer.COMPARE_IGNORE_CASE | Normalizer.FOLD_CASE_EXCLUDE_SPECIAL_I, "ignore case & special i"), Temp(Normalizer.COMPARE_CODE_POINT_ORDER | Normalizer.COMPARE_IGNORE_CASE | Normalizer.FOLD_CASE_EXCLUDE_SPECIAL_I, "code point order & ignore case & special i"), Temp(Normalizer.Unicode3_2, "Unicode 3.2")]
    D: int = 0
    kModeStrings: seq[string] = @["D", "C", "KD", "KC"]
    tnorm2: TestNormalizer2 = TestNormalizer2

proc TestHangulCompose*() =
Logln("Canonical composition...")
staticTest(NormalizerMode.NFC, hangulCanon, 2)
Logln("Compatibility composition...")
staticTest(NormalizerMode.NFKC, hangulCompat, 2)
Logln("Iterative composition...")
    var norm: Normalizer = Normalizer("", NormalizerMode.NFC, 0)
iterateTest(norm, hangulCanon, 2)
norm.SetMode(NormalizerMode.NFKD)
iterateTest(norm, hangulCompat, 2)
Logln("Reverse iteration...")
norm.SetMode(NormalizerMode.NFC)
backAndForth(norm, hangulCanon)
proc TestHangulDecomp*() =
Logln("Canonical decomposition...")
staticTest(NormalizerMode.NFD, hangulCanon, 1)
Logln("Compatibility decomposition...")
staticTest(NormalizerMode.NFKD, hangulCompat, 1)
Logln("Iterative decomposition...")
    var norm: Normalizer = Normalizer("", NormalizerMode.NFD, 0)
iterateTest(norm, hangulCanon, 1)
norm.SetMode(NormalizerMode.NFKD)
iterateTest(norm, hangulCompat, 1)
Logln("Reverse iteration...")
norm.SetMode(NormalizerMode.NFD)
backAndForth(norm, hangulCanon)
proc TestNone*() =
    var norm: Normalizer = Normalizer("", NormalizerMode.None, 0)
iterateTest(norm, canonTests, 0)
staticTest(NormalizerMode.None, canonTests, 0)
proc TestDecomp*() =
    var norm: Normalizer = Normalizer("", NormalizerMode.NFD, 0)
iterateTest(norm, canonTests, 1)
staticTest(NormalizerMode.NFD, canonTests, 1)
decomposeTest(NormalizerMode.NFD, canonTests, 1)
proc TestCompatDecomp*() =
    var norm: Normalizer = Normalizer("", NormalizerMode.NFKD, 0)
iterateTest(norm, compatTests, 1)
staticTest(NormalizerMode.NFKD, compatTests, 1)
decomposeTest(NormalizerMode.NFKD, compatTests, 1)
proc TestCanonCompose*() =
    var norm: Normalizer = Normalizer("", NormalizerMode.NFC, 0)
staticTest(NormalizerMode.NFC, canonTests, 2)
iterateTest(norm, canonTests, 2)
composeTest(NormalizerMode.NFC, canonTests, 2)
proc TestCompatCompose*() =
    var norm: Normalizer = Normalizer("", NormalizerMode.NFKC, 0)
iterateTest(norm, compatTests, 2)
staticTest(NormalizerMode.NFKC, compatTests, 2)
composeTest(NormalizerMode.NFKC, compatTests, 2)
proc TestExplodingBase*() =
    var canon: string[][] = @[@["Tschuſ", "Tschuſ", "Tschuſ"], @["Tschuẛ", "Tschuẛ", "Tschuẛ"]]
    var compat: string[][] = @[@["ſ", "s", "s"], @["ẛ", "ṡ", "ṡ"]]
staticTest(NormalizerMode.NFD, canon, 1)
staticTest(NormalizerMode.NFC, canon, 2)
staticTest(NormalizerMode.NFKD, compat, 1)
staticTest(NormalizerMode.NFKC, compat, 2)
proc TestTibetan*() =
    var decomp: string[][] = @[@["ཷ", "ཷ", "ྲཱྀ"]]
    var compose: string[][] = @[@["ྲཱྀ", "ྲཱྀ", "ྲཱྀ"]]
staticTest(NormalizerMode.NFD, decomp, 1)
staticTest(NormalizerMode.NFKD, decomp, 2)
staticTest(NormalizerMode.NFC, compose, 1)
staticTest(NormalizerMode.NFKC, compose, 2)
proc TestCompositionExclusion*() =
    var EXCLUDED: string = "̀́̓̈́ʹ;·क़" + "ख़ग़ज़ड़ढ़फ़य़ড়" + "ঢ়য়ਲ਼ਸ਼ਖ਼ਗ਼ਜ਼ਫ਼" + "ଡ଼ଢ଼གྷཌྷདྷབྷཛྷཀྵ" + "ཱཱིུྲྀླཱྀྀྒྷྜྷྡྷ" + "ྦྷྫྷྐྵάέήίό" + "ύώΆιΈΉΐΊ" + "ΰΎ΅`ΌΏ´ " + " ΩKÅ〈〉豈塚" + "晴凞蘒諸逸都飯ײַ" + "שׁשׂשּׁשּׂאַאָאּבּ" + "גּדּהּוּזּטּיּךּ" + "כּלּמּנּסּףּפּצּ" + "קּרּשּתּוֹבֿכֿפֿ"
      var i: int = 0
      while i < EXCLUDED.Length:
          var a: string = Convert.ToString(EXCLUDED[i])
          var b: string = Normalizer.Normalize(a, NormalizerMode.NFKD)
          var c: string = Normalizer.Normalize(b, NormalizerMode.NFC)
          if c.Equals(a):
Errln("FAIL: " + Hex(a) + " x DECOMP_COMPAT => " + Hex(b) + " x COMPOSE => " + Hex(c))

          elif IsVerbose:
Logln("Ok: " + Hex(a) + " x DECOMP_COMPAT => " + Hex(b) + " x COMPOSE => " + Hex(c))
++i
proc TestZeroIndex*() =
    var DATA: string[] = @["À̖", "À̖", "À̖", "À̖", "À̖", "À̖", "À̧", "À̧", "À̧", "c̡̧", "c̡̧", "c̡̧", "ç̡", "ç̡", "ç̡"]
      var i: int = 0
      while i < DATA.Length:
          var a: string = DATA[i]
          var b: string = Normalizer.Normalize(a, NormalizerMode.NFKC)
          var exp: string = DATA[i + 1]
          if b.Equals(exp):
Logln("Ok: " + Hex(a) + " x COMPOSE_COMPAT => " + Hex(b))
          else:
Errln("FAIL: " + Hex(a) + " x COMPOSE_COMPAT => " + Hex(b) + ", expect " + Hex(exp))
          a = Normalizer.Normalize(b, NormalizerMode.NFD)
          exp = DATA[i + 2]
          if a.Equals(exp):
Logln("Ok: " + Hex(b) + " x DECOMP => " + Hex(a))
          else:
Errln("FAIL: " + Hex(b) + " x DECOMP => " + Hex(a) + ", expect " + Hex(exp))
          i = 3
proc TestVerisign*() =
    var inputs: string[] = @["ֱָֹ֑׃ְ֬֟", "ְַּ֥֒׀֭ׄ"]
    var outputs: string[] = @["ֱָֹ֑׃ְ֬֟", "ְַּ֥֒׀֭ׄ"]
      var i: int = 0
      while i < inputs.Length:
          var input: string = inputs[i]
          var output: string = outputs[i]
          var result: string = Normalizer.Decompose(input, false)
          if !result.Equals(output):
Errln("FAIL input: " + Hex(input))
Errln(" decompose: " + Hex(result))
Errln("  expected: " + Hex(output))
          result = Normalizer.Compose(input, false)
          if !result.Equals(output):
Errln("FAIL input: " + Hex(input))
Errln("   compose: " + Hex(result))
Errln("  expected: " + Hex(output))
++i
proc TestQuickCheckResultNO*() =
    var CPNFD: char[] = @[cast[char](197), cast[char](1031), cast[char](7680), cast[char](8023), cast[char](8716), cast[char](12462), cast[char](44032), cast[char](55203), cast[char](64310), cast[char](64334)]
    var CPNFC: char[] = @[cast[char](832), cast[char](3987), cast[char](8055), cast[char](8123), cast[char](8171), cast[char](8192), cast[char](9002), cast[char](63744), cast[char](64030), cast[char](64334)]
    var CPNFKD: char[] = @[cast[char](160), cast[char](740), cast[char](8155), cast[char](9450), cast[char](13054), cast[char](44032), cast[char](64334), cast[char](64016), cast[char](65343), cast[char](64045)]
    var CPNFKC: char[] = @[cast[char](160), cast[char](383), cast[char](8192), cast[char](9450), cast[char](13054), cast[char](13310), cast[char](64334), cast[char](64016), cast[char](65343), cast[char](64045)]
    var SIZE: int = 10
    var count: int = 0
      while count < SIZE:
          if Normalizer.QuickCheck(Convert.ToString(CPNFD[count]), NormalizerMode.NFD, 0) != QuickCheckResult.No:
Errln("ERROR in NFD quick check at U+" + CPNFD[count].ToHexString)
              return
          if Normalizer.QuickCheck(Convert.ToString(CPNFC[count]), NormalizerMode.NFC, 0) != QuickCheckResult.No:
Errln("ERROR in NFC quick check at U+" + CPNFC[count].ToHexString)
              return
          if Normalizer.QuickCheck(Convert.ToString(CPNFKD[count]), NormalizerMode.NFKD, 0) != QuickCheckResult.No:
Errln("ERROR in NFKD quick check at U+" + CPNFKD[count].ToHexString)
              return
          if Normalizer.QuickCheck(Convert.ToString(CPNFKC[count]), NormalizerMode.NFKC, 0) != QuickCheckResult.No:
Errln("ERROR in NFKC quick check at U+" + CPNFKC[count].ToHexString)
              return
          if Normalizer.QuickCheck(Convert.ToString(CPNFKC[count]), NormalizerMode.NFKC) != QuickCheckResult.No:
Errln("ERROR in NFKC quick check at U+" + CPNFKC[count].ToHexString)
              return
++count
proc TestQuickCheckResultYES*() =
    var CPNFD: char[] = @[cast[char](198), cast[char](383), cast[char](3956), cast[char](4096), cast[char](7834), cast[char](8801), cast[char](12405), cast[char](16384), cast[char](20480), cast[char](61440)]
    var CPNFC: char[] = @[cast[char](1024), cast[char](1344), cast[char](2305), cast[char](4096), cast[char](5376), cast[char](7834), cast[char](12288), cast[char](16384), cast[char](20480), cast[char](61440)]
    var CPNFKD: char[] = @[cast[char](171), cast[char](672), cast[char](4096), cast[char](4135), cast[char](12283), cast[char](16383), cast[char](20479), cast[char](40960), cast[char](61440), cast[char](64039)]
    var CPNFKC: char[] = @[cast[char](176), cast[char](256), cast[char](512), cast[char](2562), cast[char](4096), cast[char](8208), cast[char](12336), cast[char](16384), cast[char](40960), cast[char](64014)]
    var SIZE: int = 10
    var count: int = 0
    var cp: char = cast[char](0)
    while cp < 160:
        if Normalizer.QuickCheck(Convert.ToString(cp), NormalizerMode.NFD, 0) != QuickCheckResult.Yes:
Errln("ERROR in NFD quick check at U+" + cp.ToHexString)
            return
        if Normalizer.QuickCheck(Convert.ToString(cp), NormalizerMode.NFC, 0) != QuickCheckResult.Yes:
Errln("ERROR in NFC quick check at U+" + cp.ToHexString)
            return
        if Normalizer.QuickCheck(Convert.ToString(cp), NormalizerMode.NFKD, 0) != QuickCheckResult.Yes:
Errln("ERROR in NFKD quick check at U+" + cp.ToHexString)
            return
        if Normalizer.QuickCheck(Convert.ToString(cp), NormalizerMode.NFKC, 0) != QuickCheckResult.Yes:
Errln("ERROR in NFKC quick check at U+" + cp.ToHexString)
            return
        if Normalizer.QuickCheck(Convert.ToString(cp), NormalizerMode.NFKC) != QuickCheckResult.Yes:
Errln("ERROR in NFKC quick check at U+" + cp.ToHexString)
            return
++cp
      while count < SIZE:
          if Normalizer.QuickCheck(Convert.ToString(CPNFD[count]), NormalizerMode.NFD, 0) != QuickCheckResult.Yes:
Errln("ERROR in NFD quick check at U+" + CPNFD[count].ToHexString)
              return
          if Normalizer.QuickCheck(Convert.ToString(CPNFC[count]), NormalizerMode.NFC, 0) != QuickCheckResult.Yes:
Errln("ERROR in NFC quick check at U+" + CPNFC[count].ToHexString)
              return
          if Normalizer.QuickCheck(Convert.ToString(CPNFKD[count]), NormalizerMode.NFKD, 0) != QuickCheckResult.Yes:
Errln("ERROR in NFKD quick check at U+" + CPNFKD[count].ToHexString)
              return
          if Normalizer.QuickCheck(Convert.ToString(CPNFKC[count]), NormalizerMode.NFKC, 0) != QuickCheckResult.Yes:
Errln("ERROR in NFKC quick check at U+" + CPNFKC[count].ToHexString)
              return
          if Normalizer.QuickCheck(Convert.ToString(CPNFKC[count]), NormalizerMode.NFKC) != QuickCheckResult.Yes:
Errln("ERROR in NFKC quick check at U+" + CPNFKC[count].ToHexString)
              return
++count
proc TestBengali*() =
    var input: string = "়া্া"
    var output: string = Normalizer.Normalize(input, NormalizerMode.NFC)
    if !input.Equals(output):
Errln("ERROR in NFC of string")
proc TestQuickCheckResultMAYBE*() =
    var CPNFC: char[] = @[cast[char](774), cast[char](1620), cast[char](3006), cast[char](4142), cast[char](4449), cast[char](4458), cast[char](4467), cast[char](4469), cast[char](12441), cast[char](12442)]
    var CPNFKC: char[] = @[cast[char](768), cast[char](1620), cast[char](1621), cast[char](2519), cast[char](2878), cast[char](3535), cast[char](3551), cast[char](4142), cast[char](4520), cast[char](12441)]
    var SIZE: int = 10
    var count: int = 0
      while count < SIZE:
          if Normalizer.QuickCheck(Convert.ToString(CPNFC[count]), NormalizerMode.NFC, 0) != QuickCheckResult.Maybe:
Errln("ERROR in NFC quick check at U+" + CPNFC[count].ToHexString)
              return
          if Normalizer.QuickCheck(Convert.ToString(CPNFKC[count]), NormalizerMode.NFKC, 0) != QuickCheckResult.Maybe:
Errln("ERROR in NFKC quick check at U+" + CPNFKC[count].ToHexString)
              return
          if Normalizer.QuickCheck(@[CPNFC[count]], NormalizerMode.NFC, 0) != QuickCheckResult.Maybe:
Errln("ERROR in NFC quick check at U+" + CPNFC[count].ToHexString)
              return
          if Normalizer.QuickCheck(@[CPNFKC[count]], NormalizerMode.NFKC, 0) != QuickCheckResult.Maybe:
Errln("ERROR in NFKC quick check at U+" + CPNFKC[count].ToHexString)
              return
          if Normalizer.QuickCheck(@[CPNFKC[count]], NormalizerMode.None, 0) != QuickCheckResult.Yes:
Errln("ERROR in NONE quick check at U+" + CPNFKC[count].ToHexString)
              return
++count
proc TestQuickCheckStringResult*() =
    var count: int
    var d: string
    var c: string
      count = 0
      while count < canonTests.Length:
          d = canonTests[count][1]
          c = canonTests[count][2]
          if Normalizer.QuickCheck(d, NormalizerMode.NFD, 0) != QuickCheckResult.Yes:
Errln("ERROR in NFD quick check for string at count " + count)
              return
          if Normalizer.QuickCheck(c, NormalizerMode.NFC, 0) == QuickCheckResult.No:
Errln("ERROR in NFC quick check for string at count " + count)
              return
++count
      count = 0
      while count < compatTests.Length:
          d = compatTests[count][1]
          c = compatTests[count][2]
          if Normalizer.QuickCheck(d, NormalizerMode.NFKD, 0) != QuickCheckResult.Yes:
Errln("ERROR in NFKD quick check for string at count " + count)
              return
          if Normalizer.QuickCheck(c, NormalizerMode.NFKC, 0) != QuickCheckResult.Yes:
Errln("ERROR in NFKC quick check for string at count " + count)
              return
++count
proc qcToInt(qc: QuickCheckResult): int =
    if qc == QuickCheckResult.No:
        return 0

    elif qc == QuickCheckResult.Yes:
        return 1
    else:
        return 2
proc TestQuickCheckPerCP*() =
      var c: int
      var lead: int
      var trail: int
      var s: string
      var nfd: string
      var lccc1: int
      var lccc2: int
      var tccc1: int
      var tccc2: int
      var qc1: int
      var qc2: int
    if UChar.GetIntPropertyMaxValue(UProperty.NFD_Quick_Check) != 1 || UChar.GetIntPropertyMaxValue(UProperty.NFKD_Quick_Check) != 1 || UChar.GetIntPropertyMaxValue(UProperty.NFC_Quick_Check) != 2 || UChar.GetIntPropertyMaxValue(UProperty.NFKC_Quick_Check) != 2 || UChar.GetIntPropertyMaxValue(UProperty.Lead_Canonical_Combining_Class) != UChar.GetIntPropertyMaxValue(UProperty.Canonical_Combining_Class) || UChar.GetIntPropertyMaxValue(UProperty.Trail_Canonical_Combining_Class) != UChar.GetIntPropertyMaxValue(UProperty.Canonical_Combining_Class):
Errln("wrong result from one of the u_getIntPropertyMaxValue(UCHAR_NF*_QUICK_CHECK) or UCHAR_*_CANONICAL_COMBINING_CLASS")
    c = 0
    while c < 1114112:
        s = UTF16.ValueOf(c)
        qc1 = UChar.GetIntPropertyValue(c, UProperty.NFC_Quick_Check)
        qc2 = qcToInt(Normalizer.QuickCheck(s, NormalizerMode.NFC))
        if qc1 != qc2:
Errln("getIntPropertyValue(NFC)=" + qc1 + " != " + qc2 + "=quickCheck(NFC) for U+" + c.ToHexString)
        qc1 = UChar.GetIntPropertyValue(c, UProperty.NFD_Quick_Check)
        qc2 = qcToInt(Normalizer.QuickCheck(s, NormalizerMode.NFD))
        if qc1 != qc2:
Errln("getIntPropertyValue(NFD)=" + qc1 + " != " + qc2 + "=quickCheck(NFD) for U+" + c.ToHexString)
        qc1 = UChar.GetIntPropertyValue(c, UProperty.NFKC_Quick_Check)
        qc2 = qcToInt(Normalizer.QuickCheck(s, NormalizerMode.NFKC))
        if qc1 != qc2:
Errln("getIntPropertyValue(NFKC)=" + qc1 + " != " + qc2 + "=quickCheck(NFKC) for U+" + c.ToHexString)
        qc1 = UChar.GetIntPropertyValue(c, UProperty.NFKD_Quick_Check)
        qc2 = qcToInt(Normalizer.QuickCheck(s, NormalizerMode.NFKD))
        if qc1 != qc2:
Errln("getIntPropertyValue(NFKD)=" + qc1 + " != " + qc2 + "=quickCheck(NFKD) for U+" + c.ToHexString)
        nfd = Normalizer.Normalize(s, NormalizerMode.NFD)
        lead = UTF16.CharAt(nfd, 0)
        trail = UTF16.CharAt(nfd, nfd.Length - 1)
        lccc1 = UChar.GetIntPropertyValue(c, UProperty.Lead_Canonical_Combining_Class)
        lccc2 = UChar.GetCombiningClass(lead)
        tccc1 = UChar.GetIntPropertyValue(c, UProperty.Trail_Canonical_Combining_Class)
        tccc2 = UChar.GetCombiningClass(trail)
        if lccc1 != lccc2:
Errln("getIntPropertyValue(lccc)=" + lccc1 + " != " + lccc2 + "=getCombiningClass(lead) for U+" + c.ToHexString)
        if tccc1 != tccc2:
Errln("getIntPropertyValue(tccc)=" + tccc1 + " != " + tccc2 + "=getCombiningClass(trail) for U+" + c.ToHexString)
        c = 20 * c / 19 + 1
proc backAndForth(iter: Normalizer, tests: seq[string]) =
    var forward: ValueStringBuilder = ValueStringBuilder(newSeq[char](32))
    var reverse: ValueStringBuilder = ValueStringBuilder(newSeq[char](32))
    try:
          var i: int = 0
          while i < tests.Length:
iter.SetText(tests[i][0])
              forward.Length = 0
                var ch: int = iter.First
                while ch != Normalizer.Done:
forward.Append(ch)
                    ch = iter.Next
              reverse.Length = 0
                var ch: int = iter.Last
                while ch != Normalizer.Done:
reverse.Insert(0, ch)
                    ch = iter.Previous
              if !forward.AsSpan.Equals(reverse.AsSpan, StringComparison.Ordinal):
Errln("FAIL: Forward/reverse mismatch for input " + Hex(tests[i][0]) + ", forward: " + Hex(forward.AsSpan) + ", backward: " + Hex(reverse.AsSpan))

              elif IsVerbose:
Logln("Ok: Forward/reverse for input " + Hex(tests[i][0]) + ", forward: " + Hex(forward.AsSpan) + ", backward: " + Hex(reverse.AsSpan))
++i
    finally:
forward.Dispose
reverse.Dispose
proc staticTest(mode: NormalizerMode, tests: seq[string], outCol: int) =
      var i: int = 0
      while i < tests.Length:
          var input: string = Utility.Unescape(tests[i][0])
          var expect: string = Utility.Unescape(tests[i][outCol])
Logln("Normalizing '" + input + "' (" + Hex(input) + ")")
          var output2: string = Normalizer.Normalize(input, mode)
          if !output2.Equals(expect):
Errln("FAIL: case " + i + " expected '" + expect + "' (" + Hex(expect) + ")" + " but got '" + output2 + "' (" + Hex(output2) + ")")
++i
    var output: char[] = seq[char]
      var i: int = 0
      while i < tests.Length:
          var input: char[] = Utility.Unescape(tests[i][0]).ToCharArray
          var expect: string = Utility.Unescape(tests[i][outCol])
Logln("Normalizing '" + string(input) + "' (" + Hex(string(input)) + ")")
          var reqLength: int = 0
          while true:
              if Normalizer.TryNormalize(input, output, reqLength, mode, 0):
                  if reqLength <= output.Length:
                      break
              else:
                  output = seq[char]
                  continue
          if !expect.AsSpan.Equals(output.AsSpan(0, reqLength), StringComparison.Ordinal):
Errln("FAIL: case " + i + " expected '" + expect + "' (" + Hex(expect) + ")" + " but got '" + string(output) + "' (" + Hex(output) + ")")
++i
proc decomposeTest(mode: NormalizerMode, tests: seq[string], outCol: int) =
      var i: int = 0
      while i < tests.Length:
          var input: string = Utility.Unescape(tests[i][0])
          var expect: string = Utility.Unescape(tests[i][outCol])
Logln("Normalizing '" + input + "' (" + Hex(input) + ")")
          var output2: string = Normalizer.Decompose(input, mode == NormalizerMode.NFKD)
          if !output2.Equals(expect):
Errln("FAIL: case " + i + " expected '" + expect + "' (" + Hex(expect) + ")" + " but got '" + output2 + "' (" + Hex(output2) + ")")
++i
    var output: char[] = seq[char]
      var i: int = 0
      while i < tests.Length:
          var input: char[] = Utility.Unescape(tests[i][0]).ToCharArray
          var expect: string = Utility.Unescape(tests[i][outCol])
Logln("Normalizing '" + string(input) + "' (" + Hex(string(input)) + ")")
          var reqLength: int = 0
          while true:
              if Normalizer.TryDecompose(input, output, reqLength, mode == NormalizerMode.NFKD, 0):
                  if reqLength <= output.Length:
                      break
              else:
                  output = seq[char]
                  continue
          if !expect.AsSpan.Equals(output.AsSpan(0, reqLength), StringComparison.Ordinal):
Errln("FAIL: case " + i + " expected '" + expect + "' (" + Hex(expect) + ")" + " but got '" + string(output) + "' (" + Hex(output) + ")")
++i
    output = seq[char]
      var i: int = 0
      while i < tests.Length:
          var input: char[] = Utility.Unescape(tests[i][0]).ToCharArray
          var expect: string = Utility.Unescape(tests[i][outCol])
Logln("Normalizing '" + string(input) + "' (" + Hex(input) + ")")
          var reqLength: int = 0
          while true:
              if Normalizer.TryDecompose(input.AsSpan(0, input.Length), output.AsSpan(0, output.Length), reqLength, mode == NormalizerMode.NFKD, 0):
                  if reqLength <= output.Length:
                      break
              else:
                  output = seq[char]
                  continue
          if !expect.AsSpan.Equals(output.AsSpan(0, reqLength), StringComparison.Ordinal):
Errln("FAIL: case " + i + " expected '" + expect + "' (" + Hex(expect) + ")" + " but got '" + string(output) + "' (" + Hex(output) + ")")
          var output2: char[] = seq[char]
System.Array.Copy(output, 0, output2, 0, reqLength)
          var success: bool = Normalizer.TryDecompose(input.AsSpan(0, input.Length), output2.AsSpan(reqLength, output2.Length - reqLength),           var retLength: int, mode == NormalizerMode.NFKC, 0)
          if retLength != reqLength:
Logln("FAIL: Normalizer.TryDecompose did not return the expected length. Expected: " + reqLength + " Got: " + retLength)
++i
proc composeTest(mode: NormalizerMode, tests: seq[string], outCol: int) =
      var i: int = 0
      while i < tests.Length:
          var input: string = Utility.Unescape(tests[i][0])
          var expect: string = Utility.Unescape(tests[i][outCol])
Logln("Normalizing '" + input + "' (" + Hex(input) + ")")
          var output2: string = Normalizer.Compose(input, mode == NormalizerMode.NFKC)
          if !output2.Equals(expect):
Errln("FAIL: case " + i + " expected '" + expect + "' (" + Hex(expect) + ")" + " but got '" + output2 + "' (" + Hex(output2) + ")")
++i
    var output: char[] = seq[char]
      var i: int = 0
      while i < tests.Length:
          var input: char[] = Utility.Unescape(tests[i][0]).ToCharArray
          var expect: string = Utility.Unescape(tests[i][outCol])
Logln("Normalizing '" + string(input) + "' (" + Hex(string(input)) + ")")
          var reqLength: int = 0
          while true:
              if Normalizer.TryCompose(input, output, reqLength, mode == NormalizerMode.NFKC, 0):
                  if reqLength <= output.Length:
                      break
              else:
                  output = seq[char]
                  continue
          if !expect.Equals(string(output, 0, reqLength)):
Errln("FAIL: case " + i + " expected '" + expect + "' (" + Hex(expect) + ")" + " but got '" + string(output) + "' (" + Hex(string(output)) + ")")
++i
    output = seq[char]
      var i: int = 0
      while i < tests.Length:
          var input: char[] = Utility.Unescape(tests[i][0]).ToCharArray
          var expect: string = Utility.Unescape(tests[i][outCol])
Logln("Normalizing '" + string(input) + "' (" + Hex(input) + ")")
          var reqLength: int = 0
          while true:
              if Normalizer.TryCompose(input.AsSpan(0, input.Length), output.AsSpan(0, output.Length), reqLength, mode == NormalizerMode.NFKC, 0):
                  if reqLength <= output.Length:
                      break
              else:
                  output = seq[char]
                  continue
          if !expect.AsSpan.Equals(output.AsSpan(0, reqLength), StringComparison.Ordinal):
Errln("FAIL: case " + i + " expected '" + expect + "' (" + Hex(expect) + ")" + " but got '" + string(output) + "' (" + Hex(string(output)) + ")")
          var output2: char[] = seq[char]
System.Array.Copy(output, 0, output2, 0, reqLength)
          var success: bool = Normalizer.TryCompose(input.AsSpan(0, input.Length), output2.AsSpan(reqLength, output2.Length - reqLength),           var retLength: int, mode == NormalizerMode.NFKC, 0)
          if retLength != reqLength:
Logln("FAIL: Normalizer.compose did not return the expected length. Expected: " + reqLength + " Got: " + retLength)
++i
proc iterateTest(iter: Normalizer, tests: seq[string], outCol: int) =
      var i: int = 0
      while i < tests.Length:
          var input: string = Utility.Unescape(tests[i][0])
          var expect: string = Utility.Unescape(tests[i][outCol])
Logln("Normalizing '" + input + "' (" + Hex(input) + ")")
iter.SetText(input)
assertEqual(expect, iter, "case " + i + " ")
++i
proc assertEqual(expected: string, iter: Normalizer, msg: string) =
    var index: int = 0
    var ch: int
    var cIter: UCharacterIterator = UCharacterIterator.GetInstance(expected)
    while     ch = iter.Next != Normalizer.Done:
        if index >= expected.Length:
Errln("FAIL: " + msg + "Unexpected character '" + cast[char](ch) + "' (" + Hex(ch) + ")" + " at index " + index)
            break
        var want: int = UTF16.CharAt(expected, index)
        if ch != want:
Errln("FAIL: " + msg + "got '" + cast[char](ch) + "' (" + Hex(ch) + ")" + " but expected '" + want + "' (" + Hex(want) + ")" + " at index " + index)
        index = UTF16.GetCharCount(ch)
    if index < expected.Length:
Errln("FAIL: " + msg + "Only got " + index + " chars, expected " + expected.Length)
cIter.SetToLimit
    while     ch = iter.Previous != Normalizer.Done:
        var want: int = cIter.PreviousCodePoint
        if ch != want:
Errln("FAIL: " + msg + "got '" + cast[char](ch) + "' (" + Hex(ch) + ")" + " but expected '" + want + "' (" + Hex(want) + ")" + " at index " + index)
proc TestDebugStatic*() =
    var @in: string = Utility.Unescape("\U0001D157\U0001D165")
    if !Normalizer.IsNormalized(@in, NormalizerMode.NFC, 0):
Errln("isNormalized failed")
    var input: string = "궋궋궋궋" + "\U0001d15e\U0001d157\U0001d165\U0001d15e\U0001d15e\U0001d15e\U0001d15e" + "\U0001d15e\U0001d157\U0001d165\U0001d15e\U0001d15e\U0001d15e\U0001d15e" + "\U0001d15e\U0001d157\U0001d165\U0001d15e\U0001d15e\U0001d15e\U0001d15e" + "\U0001d157\U0001d165\U0001d15e\U0001d15e\U0001d15e\U0001d15e\U0001d15e" + "\U0001d157\U0001d165\U0001d15e\U0001d15e\U0001d15e\U0001d15e\U0001d15e" + "aaaaaaaaaaaaaaaaaazzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz" + "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" + "ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc" + "ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd" + "궋궋궋궋" + "ḍ̛̇"
    var expect: string = "궋궋궈" + "ᆪ궋𝅗𝅥" + "𝅗𝅥𝅗𝅥" + "𝅗𝅥𝅗𝅥" + "𝅗𝅥𝅗𝅥" + "𝅗𝅥𝅗𝅥" + "𝅗𝅥𝅗𝅥" + "𝅗𝅥𝅗𝅥" + "𝅗𝅥𝅗𝅥" + "𝅗𝅥𝅗𝅥" + "𝅗𝅥𝅗𝅥" + "𝅗𝅥𝅗𝅥" + "𝅗𝅥𝅗𝅥" + "𝅗𝅥𝅗𝅥" + "𝅗𝅥𝅗𝅥" + "𝅗𝅥𝅗𝅥" + "𝅗𝅥aaaaaaaaaaaaaaaaaazzzzzz" + "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz" + "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" + "bbbbbbbbbbbbbbbbbbbbbbbbccccccccccccccccccccccccccccc" + "cccccccccccccccccccccccccccccccccccccccccccccccc" + "ddddddddddddddddddddddddddddddddddddddddddddddddddddd" + "dddddddddddddddddddddddd" + "궋궋궈" + "ᆪ궋ḍ̛̇"
    var output: string = Normalizer.Normalize(Utility.Unescape(input), NormalizerMode.NFD)
    if !expect.Equals(output):
Errln("FAIL expected: " + Hex(expect) + " got: " + Hex(output))
proc TestDebugIter*() =
    var src: string = Utility.Unescape("\U0001d15e\U0001d157\U0001d165\U0001d15e")
    var expected: string = Utility.Unescape("\U0001d15e\U0001d157\U0001d165\U0001d15e")
    var iter: Normalizer = Normalizer(StringCharacterIterator(Utility.Unescape(src)), NormalizerMode.None, 0)
    var index: int = 0
    var ch: int
    var cIter: UCharacterIterator = UCharacterIterator.GetInstance(expected)
    while     ch = iter.Next != Normalizer.Done:
        if index >= expected.Length:
Errln("FAIL: " + "Unexpected character '" + cast[char](ch) + "' (" + Hex(ch) + ")" + " at index " + index)
            break
        var want: int = UTF16.CharAt(expected, index)
        if ch != want:
Errln("FAIL: " + "got '" + cast[char](ch) + "' (" + Hex(ch) + ")" + " but expected '" + want + "' (" + Hex(want) + ")" + " at index " + index)
        index = UTF16.GetCharCount(ch)
    if index < expected.Length:
Errln("FAIL: " + "Only got " + index + " chars, expected " + expected.Length)
cIter.SetToLimit
    while     ch = iter.Previous != Normalizer.Done:
        var want: int = cIter.PreviousCodePoint
        if ch != want:
Errln("FAIL: " + "got '" + cast[char](ch) + "' (" + Hex(ch) + ")" + " but expected '" + want + "' (" + Hex(want) + ")" + " at index " + index)
proc TestDebugIterOld*() =
    var input: string = "\U0001D15E"
    var expected: string = "𝅗𝅥"
    var expectedReverse: string = "𝅥𝅗"
    var index: int = 0
    var ch: int
    var iter: Normalizer = Normalizer(StringCharacterIterator(Utility.Unescape(input)), NormalizerMode.NFKC, 0)
    var codePointBuffer: Span<char> = newSeq[char](2)
    var got: ValueStringBuilder = ValueStringBuilder(newSeq[char](32))
    try:
          ch = iter.First
          while ch != Normalizer.Done:
              if index >= expected.Length:
Errln("FAIL: " + "Unexpected character '" + cast[char](ch) + "' (" + Hex(ch) + ")" + " at index " + index)
                  break
got.Append(UChar.ConvertFromUtf32(ch, codePointBuffer))
++index
              ch = iter.Next
        if !expected.AsSpan.Equals(got.AsSpan, StringComparison.Ordinal):
Errln("FAIL: " + "got '" + got.AsSpan.ToString + "' (" + Hex(got.AsSpan) + ")" + " but expected '" + expected + "' (" + Hex(expected) + ")")
        if got.Length < expected.Length:
Errln("FAIL: " + "Only got " + index + " chars, expected " + expected.Length)
Logln("Reverse Iteration
")
iter.SetIndexOnly(iter.EndIndex)
        got.Length = 0
          ch = iter.Previous
          while ch != Normalizer.Done:
              if index >= expected.Length:
Errln("FAIL: " + "Unexpected character '" + cast[char](ch) + "' (" + Hex(ch) + ")" + " at index " + index)
                  break
got.Append(UChar.ConvertFromUtf32(ch, codePointBuffer))
              ch = iter.Previous
        if !expectedReverse.AsSpan.Equals(got.AsSpan, StringComparison.Ordinal):
Errln("FAIL: " + "got '" + got.AsSpan.ToString + "' (" + Hex(got.AsSpan) + ")" + " but expected '" + expected + "' (" + Hex(expected) + ")")
        if got.Length < expected.Length:
Errln("FAIL: " + "Only got " + index + " chars, expected " + expected.Length)
    finally:
got.Dispose
type
  UCharIterator = ref object
    s: seq[int]
    length: int

proc newUCharIterator(src: seq[int], len: int, index: int): UCharIterator =
  s = src
  length = len
  i = index
proc Current(): int =
    if i < length:
        return s[i]
    else:
        return -1
proc Next*(): int =
    if i < length:
        return s[++i]
    else:
        return -1
proc Previous*(): int =
    if i > 0:
        return s[--i]
    else:
        return -1
proc Index(): int =
    return i
proc TestPreviousNext*() =
    var src: char[] = @[UTF16.GetLeadSurrogate(194969), UTF16.GetTrailSurrogate(194969), UTF16.GetLeadSurrogate(119135), UTF16.GetTrailSurrogate(119135), cast[char](196), cast[char](7888)]
    var expect: int[] = @[33565, 119128, 119141, 65, 776, 79, 770, 769]
    var expectIndex: int[] = @[0, 2, 2, 4, 4, 5, 5, 5, 6]
    var SRC_MIDDLE: int = 4
    var EXPECT_MIDDLE: int = 3
    var moves: string = "0+0+0--0-0-+++0--+++++++0--------"
    var iter: Normalizer = Normalizer(string(src), NormalizerMode.NFD, 0)
    var iter32: UCharIterator = UCharIterator(expect, expect.Length, EXPECT_MIDDLE)
      var c1: int
      var c2: int
    var m: char
iter.SetIndexOnly(SRC_MIDDLE)
    var movesIndex: int = 0
    while movesIndex < moves.Length:
        m = moves[++movesIndex]
        if m == '-':
            c1 = iter.Previous
            c2 = iter32.Previous

        elif m == '0':
            c1 = iter.Current
            c2 = iter32.Current
        else:
            c1 = iter.Next
            c2 = iter32.Next
        if c1 != c2:
            var history: string = moves.Substring(0, movesIndex)
Errln("error: mismatch in Normalizer iteration at " + history + ": " + "got c1= " + Hex(c1) + " != expected c2= " + Hex(c2))
            break
        if iter.Index != expectIndex[iter32.Index]:
            var history: string = moves.Substring(0, movesIndex)
Errln("error: index mismatch in Normalizer iteration at " + history + " : " + "Normalizer index " + iter.Index + " expected " + expectIndex[iter32.Index])
            break
proc TestPreviousNextJCI*() =
    var src: char[] = @[UTF16.GetLeadSurrogate(194969), UTF16.GetTrailSurrogate(194969), UTF16.GetLeadSurrogate(119135), UTF16.GetTrailSurrogate(119135), cast[char](196), cast[char](7888)]
    var expect: int[] = @[33565, 119128, 119141, 65, 776, 79, 770, 769]
    var expectIndex: int[] = @[0, 2, 2, 4, 4, 5, 5, 5, 6]
    var SRC_MIDDLE: int = 4
    var EXPECT_MIDDLE: int = 3
    var moves: string = "0+0+0--0-0-+++0--+++++++0--------"
    var text: StringCharacterIterator = StringCharacterIterator(string(src))
    var iter: Normalizer = Normalizer(text, NormalizerMode.NFD, 0)
    var iter32: UCharIterator = UCharIterator(expect, expect.Length, EXPECT_MIDDLE)
      var c1: int
      var c2: int
    var m: char
iter.SetIndexOnly(SRC_MIDDLE)
    var movesIndex: int = 0
    while movesIndex < moves.Length:
        m = moves[++movesIndex]
        if m == '-':
            c1 = iter.Previous
            c2 = iter32.Previous

        elif m == '0':
            c1 = iter.Current
            c2 = iter32.Current
        else:
            c1 = iter.Next
            c2 = iter32.Next
        if c1 != c2:
            var history: string = moves.Substring(0, movesIndex)
Errln("error: mismatch in Normalizer iteration at " + history + ": " + "got c1= " + Hex(c1) + " != expected c2= " + Hex(c2))
            break
        if iter.Index != expectIndex[iter32.Index]:
            var history: string = moves.Substring(0, movesIndex)
Errln("error: index mismatch in Normalizer iteration at " + history + " : " + "Normalizer index " + iter.Index + " expected " + expectIndex[iter32.Index])
            break
proc TestNormalizerAPI*() =
    try:
        var s: string = Utility.Unescape("ä가\U0002f800")
        var iter: UCharacterIterator = UCharacterIterator.GetInstance(s + s)
        var norm: Normalizer = Normalizer(iter, NormalizerMode.NFC)
        if norm.Next != 228:
Errln("error in Normalizer(CharacterIterator).Next()")
        var clone: Normalizer = cast[Normalizer](norm.Clone)
        if clone.Equals(norm):
Errln("error in Normalizer(Normalizer(CharacterIterator)).clone()!=norm")
        if clone.Length != norm.Length:
Errln("error in Normalizer.getBeginIndex()")
        if clone.Next != 44032:
Errln("error in Normalizer(Normalizer(CharacterIterator)).Next()")
        var ch: int = clone.Next
        if ch != 20029:
Errln("error in Normalizer(Normalizer(CharacterIterator)).clone().Next()")
        if clone.GetHashCode == norm.GetHashCode:
Errln("error in Normalizer(Normalizer(CharacterIterator)).clone().Next().hashCode()==copy.hashCode()")
        var tel: StringBuffer
          var nfkc: string
          var nfkd: string
        tel = StringBuffer("℡℡℡℡℡℡℡℡℡℡")
tel.Insert(1, cast[char](769))
        nfkc = Normalizer.Compose(tel.ToString, true)
        nfkd = Normalizer.Decompose(tel.ToString, true)
        if !nfkc.Equals(Utility.Unescape("TEĹTELTELTELTELTELTELTELTELTEL")) || !nfkd.Equals(Utility.Unescape("TEĹTELTELTELTELTELTELTELTELTEL")):
Errln("error in Normalizer::(de)compose(): wrong result(s)")
        ch = norm.SetIndex(3)
        if ch != 20029:
Errln("error in Normalizer(CharacterIterator).setIndex(3)")
          var @out: string
          var out2: string
clone.SetText(iter)
        @out = clone.GetText
        out2 = iter.GetText
        if !@out.Equals(out2) || clone.StartIndex != 0 || clone.EndIndex != iter.Length:
Errln("error in Normalizer::setText() or Normalizer::getText()")
        var fillIn1: char[] = seq[char]
        var fillIn2: char[] = seq[char]
clone.TryGetText(fillIn1,         var len: int)
iter.TryGetText(fillIn2, _)
        if !Utility.ArrayRegionMatches(fillIn1, 0, fillIn2, 0, len):
Errln("error in Normalizer.TryGetText(). Normalizer: " + Utility.Hex(fillIn1) + " Iter: " + Utility.Hex(fillIn2))
clone.SetText(fillIn1)
clone.TryGetText(fillIn2, len)
        if !Utility.ArrayRegionMatches(fillIn1, 0, fillIn2, 0, len):
Errln("error in Normalizer.SetText() or Normalizer.TryGetText()" + Utility.Hex(fillIn1) + " Iter: " + Utility.Hex(fillIn2))
clone.SetText(s)
clone.SetIndexOnly(1)
clone.SetMode(NormalizerMode.NFD)
        if clone.GetMode != NormalizerMode.NFD:
Errln("error in Normalizer::setMode() or Normalizer::getMode()")
        if clone.Next != 776 || clone.Next != 4352:
Errln("error in Normalizer::setText() or Normalizer::setMode()")
        var buf: StringBuffer = StringBuffer("aaaaaaaaaa")
        buf[10 - 1] = '�'
clone.SetText(buf)
        if clone.Last != 776:
Errln("error in Normalizer(10*U+0308).last()")
norm.SetMode(NormalizerMode.None)
        if norm.First != 97 || norm.Next != 776 || norm.Last != 194560:
Errln("error in Normalizer(UNORM_NONE).first()/next()/last()")
        @out = Normalizer.Normalize(s, NormalizerMode.None)
        if !@out.Equals(s):
Errln("error in Normalizer::normalize(UNORM_NONE)")
        ch = 119134
        var exp: string = "\U0001D157\U0001D165"
        var ns: string = Normalizer.Normalize(ch, NormalizerMode.NFC)
        if !ns.Equals(Utility.Unescape(exp)):
Errln("error in Normalizer.Normalize(int,Mode)")
        ns = Normalizer.Normalize(ch, NormalizerMode.NFC, 0)
        if !ns.Equals(Utility.Unescape(exp)):
Errln("error in Normalizer.Normalize(int,Mode,int)")
    except Exception:
        raise
proc TestConcatenate*() =
    var cases: object[][] = @[@[NormalizerMode.NFC, "re", "́sumé", "résumé"], @[NormalizerMode.NFC, "aᄀ", "ᅡbcdefghijk", "a가bcdefghijk"], @[NormalizerMode.NFD, "ᾳ", "𝅩𑂺్", "ᾳ𝅩𑂺్"]]
      var left: string
      var right: string
      var expect: string
      var result: string
    var mode: NormalizerMode
    var i: int
      i = 0
      while i < cases.Length:
          mode = cast[NormalizerMode](cases[i][0])
          left = cast[string](cases[i][1])
          right = cast[string](cases[i][2])
          expect = cast[string](cases[i][3])
            result = Normalizer.Concat(left, right, mode, 0)
            if !result.Equals(expect):
Errln("error in Normalizer.Concatenate(), cases[] failed" + ", result==expect: expected: " + Hex(expect) + " =========> got: " + Hex(result))
            result = Normalizer.Concat(left.AsSpan, right.AsSpan, mode, 0)
            if !result.Equals(expect):
Errln("error in Normalizer.Concatenate(), cases[] failed" + ", result==expect: expected: " + Hex(expect) + " =========> got: " + Hex(result))
++i
    mode = NormalizerMode.NFC
    var destination: char[] = "My resume is here".ToCharArray
    left = "resume"
    right = "résumé is HERE"
    expect = "My résumé is HERE"
Normalizer.TryConcat(left.AsSpan(0, 2), right.AsSpan(2, 15 - 2), destination.AsSpan(3, 17 - 3),     var charsLength: int, mode, 0)
    if !string(destination).Equals(expect):
Errln("error in Normalizer.TryConcat(), cases2[] failed" + ", result==expect: expected: " + Hex(expect) + " =========> got: " + Hex(destination))
assertFalse("Normalizer.TryConcat() tested for failure but passed", Normalizer.TryConcat(left.AsSpan(0, 2), right.AsSpan(2, 15 - 2), destination.AsSpan(3, 16 - 3), charsLength, mode, 0))
assertEquals("Normalizer.TryConcat() failed", 14, charsLength)
proc TestCheckFCD*() =
    var FAST: char[] = @[cast[char](1), cast[char](2), cast[char](3), cast[char](4), cast[char](5), cast[char](6), cast[char](7), cast[char](8), cast[char](9), cast[char](10)]
    var FALSE: char[] = @[cast[char](1), cast[char](2), cast[char](746), cast[char](1003), cast[char](768), cast[char](769), cast[char](697), cast[char](788), cast[char](789), cast[char](790)]
    var TRUE: char[] = @[cast[char](48), cast[char](64), cast[char](1088), cast[char](1389), cast[char](1615), cast[char](1767), cast[char](80), cast[char](1840), cast[char](2542), cast[char](7696)]
    var datastr: char[][] = @[@[cast[char](97), cast[char](778), cast[char](7685), cast[char](770), cast[char](0)], @[cast[char](97), cast[char](778), cast[char](226), cast[char](803), cast[char](0)], @[cast[char](97), cast[char](803), cast[char](226), cast[char](803), cast[char](0)], @[cast[char](97), cast[char](803), cast[char](7685), cast[char](770), cast[char](0)]]
    var result: QuickCheckResult[] = @[QuickCheckResult.Yes, QuickCheckResult.No, QuickCheckResult.No, QuickCheckResult.Yes]
    var datachar: char[] = @[cast[char](96), cast[char](97), cast[char](98), cast[char](99), cast[char](100), cast[char](101), cast[char](102), cast[char](103), cast[char](104), cast[char](105), cast[char](106), cast[char](224), cast[char](225), cast[char](226), cast[char](227), cast[char](228), cast[char](229), cast[char](230), cast[char](231), cast[char](232), cast[char](233), cast[char](234), cast[char](768), cast[char](769), cast[char](770), cast[char](771), cast[char](772), cast[char](773), cast[char](774), cast[char](775), cast[char](776), cast[char](777), cast[char](778), cast[char](800), cast[char](801), cast[char](802), cast[char](803), cast[char](804), cast[char](805), cast[char](806), cast[char](807), cast[char](808), cast[char](809), cast[char](810), cast[char](7680), cast[char](7681), cast[char](7682), cast[char](7683), cast[char](7684), cast[char](7685), cast[char](7686), cast[char](7687), cast[char](7688), cast[char](7689), cast[char](7690)]
    var count: int = 0
    if Normalizer.QuickCheck(FAST.AsSpan(0, FAST.Length), NormalizerMode.FCD, 0) != QuickCheckResult.Yes:
Errln("Normalizer.QuickCheck(FCD) failed: expected value for fast Normalizer.quickCheck is NormalizerQuickCheckResult.Yes
")
    if Normalizer.QuickCheck(FALSE.AsSpan(0, FALSE.Length), NormalizerMode.FCD, 0) != QuickCheckResult.No:
Errln("Normalizer.QuickCheck(FCD) failed: expected value for error Normalizer.quickCheck is NormalizerQuickCheckResult.No
")
    if Normalizer.QuickCheck(TRUE.AsSpan(0, TRUE.Length), NormalizerMode.FCD, 0) != QuickCheckResult.Yes:
Errln("Normalizer.QuickCheck(FCD) failed: expected value for correct Normalizer.quickCheck is NormalizerQuickCheckResult.Yes
")
    while count < 4:
        var fcdresult: QuickCheckResult = Normalizer.QuickCheck(datastr[count].AsSpan(0, datastr[count].Length), NormalizerMode.FCD, 0)
        if result[count] != fcdresult:
Errln("Normalizer.QuickCheck(FCD) failed: Data set " + count + " expected value " + result[count])
++count
    var rand: Random = CreateRandom
      count = 0
      while count < 50:
          var size: int = 0
          var testresult: QuickCheckResult = QuickCheckResult.Yes
          var data: char[] = seq[char]
          var norm: char[] = seq[char]
          var nfd: char[] = seq[char]
          var normStart: int = 0
          var nfdsize: int = 0
          while size != 19:
              data[size] = datachar[rand.Next(RAND_MAX) * 50 / RAND_MAX]
Logln("0x" + data[size])
assertTrue("", Normalizer.TryNormalize(data.AsSpan(size, 1), norm.AsSpan(normStart, 100 - normStart),               var charsLength: int, NormalizerMode.NFD, 0))
              normStart = charsLength
++size
Logln("
")
assertTrue("", Normalizer.TryNormalize(data.AsSpan(0, size), nfd.AsSpan(0, nfd.Length), nfdsize, NormalizerMode.NFD, 0))
          if nfdsize != normStart || Utility.ArrayRegionMatches(nfd, 0, norm, 0, nfdsize) == false:
              testresult = QuickCheckResult.No
          if testresult == QuickCheckResult.Yes:
Logln("result NormalizerQuickCheckResult.Yes
")
          else:
Logln("result NormalizerQuickCheckResult.No
")
          if Normalizer.QuickCheck(data.AsSpan(0, data.Length), NormalizerMode.FCD, 0) != testresult:
Errln("Normalizer.QuickCheck(FCD) failed: expected " + testresult + " for random data: " + Hex(data))
++count
proc ref_norm_compare(s1: string, s2: string, options: int): int =
      var t1: string
      var t2: string
      var r1: string
      var r2: string
    var normalizerVersion = options.AsFlagsToEnum
    var foldCase = options.AsFlagsToEnum
    if options & Normalizer.COMPARE_IGNORE_CASE != 0:
        r1 = Normalizer.Decompose(s1, false, normalizerVersion)
        r2 = Normalizer.Decompose(s2, false, normalizerVersion)
        r1 = UChar.FoldCase(r1, foldCase)
        r2 = UChar.FoldCase(r2, foldCase)
    else:
        r1 = s1
        r2 = s2
    t1 = Normalizer.Decompose(r1, false, normalizerVersion)
    t2 = Normalizer.Decompose(r2, false, normalizerVersion)
    if options & Normalizer.COMPARE_CODE_POINT_ORDER != 0:
        var comp: UTF16.StringComparer = UTF16.StringComparer(true, false, UTF16.StringComparer.FoldCaseDefault)
        return comp.Compare(t1, t2)
    else:
        return t1.CompareToOrdinal(t2)
proc norm_compare(s1: string, s2: string, options: int): int =
    var unicodeVersion = options.AsFlagsToEnum
    if QuickCheckResult.Yes == Normalizer.QuickCheck(s1, NormalizerMode.FCD, unicodeVersion) && QuickCheckResult.Yes == Normalizer.QuickCheck(s2, NormalizerMode.FCD, unicodeVersion):
        options = cast[int](NormalizerComparison.InputIsFCD)
    var normalizerComparison = options.AsFlagsToEnum
    var foldCase = options.AsFlagsToEnum
    var cmpStrings: int = Normalizer.Compare(s1, s2, normalizerComparison, foldCase, unicodeVersion)
    var cmpArrays: int = Normalizer.Compare(s1.AsSpan(0, s1.Length), s2.AsSpan(0, s2.Length), normalizerComparison, foldCase, unicodeVersion)
assertEquals("compare strings == compare char arrays", cmpStrings, cmpArrays)
    return cmpStrings
proc ref_case_compare(s1: string, s2: string, options: int): int =
      var t1: string
      var t2: string
    t1 = s1
    t2 = s2
    t1 = UChar.FoldCase(t1, options & Normalizer.FOLD_CASE_EXCLUDE_SPECIAL_I == 0)
    t2 = UChar.FoldCase(t2, options & Normalizer.FOLD_CASE_EXCLUDE_SPECIAL_I == 0)
    if options & Normalizer.COMPARE_CODE_POINT_ORDER != 0:
        var comp: UTF16.StringComparer = UTF16.StringComparer(true, false, UTF16.StringComparer.FoldCaseDefault)
        return comp.Compare(t1, t2)
    else:
        return t1.CompareToOrdinal(t2)
proc sign(value: int): int =
    if value == 0:
        return 0
    else:
        return value >> 31 | 1
proc signString(value: int): string =
    if value < 0:
        return "<0"

    elif value == 0:
        return "=0"
    else:
        return ">0"
type
  Temp = ref object
    options: int
    name: string

proc newTemp(opt: int, str: string): Temp =
  options = opt
  name = str
proc TestCompareDebug*() =
    var s: string[] = seq[string]
      var i: int
      var j: int
      var k: int
      var count: int = strings.Length
      var result: int
      var refResult: int
      i = 0
      while i < count:
          s[i] = Utility.Unescape(strings[i])
++i
    var comp: UTF16.StringComparer = UTF16.StringComparer(true, false, UTF16.StringComparer.FoldCaseDefault)
    i = 42
    j = 43
    k = 2
    result = norm_compare(s[i], s[j], opt[k].options)
    refResult = ref_norm_compare(s[i], s[j], opt[k].options)
    if sign(result) != sign(refResult):
Errln("Normalizer::compare( " + i + ", " + j + ", " + k + "( " + opt[k].name + "))=" + result + " should be same sign as " + refResult)
    if 0 != opt[k].options & Normalizer.COMPARE_IGNORE_CASE:
        if opt[k].options & Normalizer.FOLD_CASE_EXCLUDE_SPECIAL_I == 0:
            comp.IgnoreCase = true
            comp.IgnoreCaseOption = UTF16.StringComparer.FoldCaseDefault
        else:
            comp.IgnoreCase = true
            comp.IgnoreCaseOption = UTF16.StringComparer.FoldCaseExcludeSpecialI
        result = comp.Compare(s[i], s[j])
        refResult = ref_case_compare(s[i], s[j], opt[k].options)
        if sign(result) != sign(refResult):
Errln("Normalizer::compare( " + i + ", " + j + ", " + k + "( " + opt[k].name + "))=" + result + " should be same sign as " + refResult)
    var value1: string = "Úterý"
    var value2: string = "úterý"
    if Normalizer.Compare(value1, value2, 0) != 0:
        var foldCase = Normalizer.COMPARE_IGNORE_CASE.AsFlagsToEnum
        if Normalizer.Compare(value1, value2, NormalizerComparison.Default, foldCase) == 0:

proc TestCompare*() =
    var s: string[] = seq[string]
      var i: int
      var j: int
      var k: int
      var count: int = strings.Length
      var result: int
      var refResult: int
      i = 0
      while i < count:
          s[i] = Utility.Unescape(strings[i])
++i
    var comp: UTF16.StringComparer = UTF16.StringComparer
      i = 0
      while i < count:
            j = i
            while j < count:
                  k = 0
                  while k < opt.Length:
                      result = norm_compare(s[i], s[j], opt[k].options)
                      refResult = ref_norm_compare(s[i], s[j], opt[k].options)
                      if sign(result) != sign(refResult):
Errln("Normalizer::compare( " + i + ", " + j + ", " + k + "( " + opt[k].name + "))=" + result + " should be same sign as " + refResult)
                      if 0 != opt[k].options & Normalizer.COMPARE_IGNORE_CASE:
                          if opt[k].options & Normalizer.FOLD_CASE_EXCLUDE_SPECIAL_I == 0:
                              comp.IgnoreCase = true
                              comp.IgnoreCaseOption = UTF16.StringComparer.FoldCaseDefault
                          else:
                              comp.IgnoreCase = true
                              comp.IgnoreCaseOption = UTF16.StringComparer.FoldCaseExcludeSpecialI
                          comp.CodePointCompare = opt[k].options & Normalizer.COMPARE_CODE_POINT_ORDER != 0
                          result = comp.Compare(s[i], s[j])
                          refResult = ref_case_compare(s[i], s[j], opt[k].options)
                          if sign(result) != sign(refResult):
Errln("Normalizer::compare( " + i + ", " + j + ", " + k + "( " + opt[k].name + "))=" + result + " should be same sign as " + refResult)
++k
++j
++i
    var iI: char[] = @[cast[char](73), cast[char](105), cast[char](304), cast[char](305)]
      var set: UnicodeSet = UnicodeSet
      var iSet: UnicodeSet = UnicodeSet
    var nfcImpl: Normalizer2Impl = Norm2AllModes.NFCInstance.Impl
nfcImpl.EnsureCanonIterData
      var s1: string
      var s2: string
      i = 0
      while i < iI.Length:
          if nfcImpl.GetCanonStartSet(iI[i], iSet):
set.AddAll(iSet)
++i
    var nfcNorm2: Normalizer2 = Normalizer2.NFCInstance
    var it: UnicodeSetIterator = UnicodeSetIterator(set)
    var c: int
    while it.Next &&     c = it.Codepoint != UnicodeSetIterator.IsString:
        s1 = UTF16.ValueOf(c)
        s2 = nfcNorm2.GetDecomposition(c)
          k = 0
          while k < opt.Length:
              result = norm_compare(s1, s2, opt[k].options)
              refResult = ref_norm_compare(s1, s2, opt[k].options)
              if sign(result) != sign(refResult):
Errln("Normalizer.compare(U+" + Hex(c) + " with its NFD, " + opt[k].name + ")" + signString(result) + " should be " + signString(refResult))
              if opt[k].options & Normalizer.COMPARE_IGNORE_CASE > 0:
                  if opt[k].options & Normalizer.FOLD_CASE_EXCLUDE_SPECIAL_I == 0:
                      comp.IgnoreCase = true
                      comp.IgnoreCaseOption = UTF16.StringComparer.FoldCaseDefault
                  else:
                      comp.IgnoreCase = true
                      comp.IgnoreCaseOption = UTF16.StringComparer.FoldCaseExcludeSpecialI
                  comp.CodePointCompare = opt[k].options & Normalizer.COMPARE_CODE_POINT_ORDER != 0
                  result = comp.Compare(s1, s2)
                  refResult = ref_case_compare(s1, s2, opt[k].options)
                  if sign(result) != sign(refResult):
Errln("UTF16.compare(U+" + Hex(c) + " with its NFD, " + opt[k].name + ")" + signString(result) + " should be " + signString(refResult))
++k
    if nfcNorm2.GetDecomposition(32) != nil || nfcNorm2.GetDecomposition(19968) != nil || nfcNorm2.GetDecomposition(131074) != nil:
Errln("NFC.getDecomposition() returns TRUE for characters which do not have decompositions")
    if nfcNorm2.GetRawDecomposition(32) != nil || nfcNorm2.GetRawDecomposition(19968) != nil || nfcNorm2.GetRawDecomposition(131074) != nil:
Errln("getRawDecomposition() returns TRUE for characters which do not have decompositions")
    if nfcNorm2.ComposePair(32, 769) >= 0 || nfcNorm2.ComposePair(97, 773) >= 0 || nfcNorm2.ComposePair(4352, 4448) >= 0 || nfcNorm2.ComposePair(44032, 4519) >= 0:
Errln("NFC.composePair() incorrectly composes some pairs of characters")
    var filter: UnicodeSet = UnicodeSet("[^ -ÿ]")
    var fn2: FilteredNormalizer2 = FilteredNormalizer2(nfcNorm2, filter)
    if fn2.GetDecomposition(228) != nil || !"Ā".Equals(fn2.GetDecomposition(256)):
Errln("FilteredNormalizer2(NFC, ^A0-FF).getDecomposition() failed")
    if fn2.GetRawDecomposition(228) != nil || !"Ā".Equals(fn2.GetRawDecomposition(256)):
Errln("FilteredNormalizer2(NFC, ^A0-FF).getRawDecomposition() failed")
    if 256 != fn2.ComposePair(65, 772) || fn2.ComposePair(199, 769) >= 0:
Errln("FilteredNormalizer2(NFC, ^A0-FF).composePair() failed")
proc countFoldFCDExceptions(foldingOptions: int): int =
      var s: string
      var d: string
    var c: int
    var count: int
      var cc: int
      var trailCC: int
      var foldCC: int
      var foldTrailCC: int
    var qcResult: QuickCheckResult
    var category: UUnicodeCategory
    var isNFD: bool
Logln("Test if case folding may un-FCD a string (folding options 0x)" + Hex(foldingOptions))
    count = 0
      c = 0
      while c <= 1114111:
          category = UChar.GetUnicodeCategory(c)
          if category == UUnicodeCategory.OtherNotAssigned:
              continue
          if c == 44032:
              c = 55203
              continue
          if c == 13312:
              c = 19893
              continue
          if c == 19968:
              c = 40869
              continue
          if c == 131072:
              c = 173782
              continue
          s = UTF16.ValueOf(c)
          d = Normalizer.Decompose(s, false)
          isNFD = s == d
          cc = UChar.GetCombiningClass(UTF16.CharAt(d, 0))
          trailCC = UChar.GetCombiningClass(UTF16.CharAt(d, d.Length - 1))
UChar.FoldCase(s, foldingOptions == 0)
          d = Normalizer.Decompose(s, false)
          foldCC = UChar.GetCombiningClass(UTF16.CharAt(d, 0))
          foldTrailCC = UChar.GetCombiningClass(UTF16.CharAt(d, d.Length - 1))
          qcResult = Normalizer.QuickCheck(s, NormalizerMode.FCD, 0)
          if qcResult != QuickCheckResult.Yes || s.Length == 0 || cc != foldCC && foldCC != 0 || trailCC != foldTrailCC && foldTrailCC != 0:
++count
Errln("U+" + Hex(c) + ": case-folding may un-FCD a string (folding options 0x" + Hex(foldingOptions) + ")")
              continue
          if isNFD && QuickCheckResult.Yes != Normalizer.QuickCheck(s, NormalizerMode.NFD, 0):
++count
Errln("U+" + Hex(c) + ": case-folding may un-FCD a string (folding options 0x" + Hex(foldingOptions) + ")")
++c
Logln("There are " + Hex(count) + " code points for which case-folding may un-FCD a string (folding options" + foldingOptions + "x)")
    return count
proc TestFindFoldFCDExceptions*() =
    var count: int
    count = countFoldFCDExceptions(0)
    count = countFoldFCDExceptions(Normalizer.FOLD_CASE_EXCLUDE_SPECIAL_I)
    if count > 0:
Errln("error: There are " + count + " code points for which case-folding" + " may un-FCD a string for all folding options.
 See comment" + " in BasicNormalizerTest::FindFoldFCDExceptions()!")
proc TestCombiningMarks*() =
    var src: string = "ཱཱཱིིུུ"
    var expected: string = "ཱཱཱིིུུ"
    var result: string = Normalizer.Decompose(src, false)
    if !expected.Equals(result):
Errln("Reordering of combining marks failed. Expected: " + Utility.Hex(expected) + " Got: " + Utility.Hex(result))
type
  TestStruct = ref object
    c: int
    s: string

proc newTestStruct(cp: int, src: string): TestStruct =
  c = cp
  s = src
proc TestFCNFKCClosure*() =
    var tests: TestStruct[] = @[TestStruct(196, ""), TestStruct(228, ""), TestStruct(890, " ι"), TestStruct(978, "υ"), TestStruct(8360, "rs"), TestStruct(8459, "h"), TestStruct(8460, "h"), TestStruct(8481, "tel"), TestStruct(8482, "tm"), TestStruct(8488, "z"), TestStruct(120283, "h"), TestStruct(120301, "z"), TestStruct(97, "")]
      var i: int = 0
      while i < tests.Length:
          var result: string = Normalizer.GetFC_NFKC_Closure(tests[i].c)
          if !result.Equals(tests[i].s):
Errln("getFC_NFKC_Closure(U+" + tests[i].c.ToHexString + ") is wrong")
++i
    var length: int = Normalizer.GetFC_NFKC_Closure(92, nil)
    if length != 0:
Errln("getFC_NFKC_Closure did not perform error handling correctly")
proc TestBugJ2324*() =
    var troublesome: string = "゚"
      var i: int = 12288
      while i < 12544:
          var input: string = cast[char](i) + troublesome
          try:
Normalizer.Compose(input, false)
          except IndexOutOfRangeException:
Errln("compose() failed for input: " + Utility.Hex(input) + " Exception: " + e.ToString)
++i
proc initSkippables(skipSets: seq[UnicodeSet]): UnicodeSet[] =
skipSets[D].ApplyPattern("[[:NFD_QC=Yes:]&[:ccc=0:]]", false)
skipSets[C].ApplyPattern("[[:NFC_QC=Yes:]&[:ccc=0:]-[:HST=LV:]]", false)
skipSets[KD].ApplyPattern("[[:NFKD_QC=Yes:]&[:ccc=0:]]", false)
skipSets[KC].ApplyPattern("[[:NFKC_QC=Yes:]&[:ccc=0:]-[:HST=LV:]]", false)
    var combineBack: UnicodeSet = UnicodeSet("[:NFC_QC=Maybe:]")
    var numCombineBack: int = combineBack.Count
    var combineBackCharsAndCc: int[] = seq[int]
    var iter: UnicodeSetIterator = UnicodeSetIterator(combineBack)
      var i: int = 0
      while i < numCombineBack:
iter.Next
          var c: int = iter.Codepoint
          combineBackCharsAndCc[2 * i] = c
          combineBackCharsAndCc[2 * i + 1] = UChar.GetCombiningClass(c)
++i
    var notInteresting: UnicodeSet = UnicodeSet("[[:C:][:Unified_Ideograph:][:HST=LVT:]]")
    var unsure: UnicodeSet = cast[UnicodeSet](skipSets[C].Clone).RemoveAll(notInteresting)
    var norm2: Normalizer2 = Normalizer2.NFCInstance
    var s: ValueStringBuilder = ValueStringBuilder(newSeq[char](32))
    try:
iter.Reset(unsure)
        while iter.Next:
            var c: int = iter.Codepoint
s.Delete(0, 2147483647 - 0)
s.AppendCodePoint(c)
            var cLength: int = s.Length
            var tccc: int = UChar.GetIntPropertyValue(c, UProperty.Trail_Canonical_Combining_Class)
              var i: int = 0
              while i < numCombineBack:
                  var cc2: int = combineBackCharsAndCc[2 * i + 1]
                  if tccc == 0 || cc2 != 0:
                      var c2: int = combineBackCharsAndCc[2 * i]
s.AppendCodePoint(c2)
                      if !norm2.IsNormalized(s.AsSpan):
skipSets[C].Remove(c)
skipSets[KC].Remove(c)
                          break
s.Delete(cLength, 2147483647 - cLength)
++i
        return skipSets
    finally:
s.Dispose
proc TestSkippable*() =
    var skipSets: UnicodeSet[] = @[UnicodeSet, UnicodeSet, UnicodeSet, UnicodeSet]
    var expectSets: UnicodeSet[] = @[UnicodeSet, UnicodeSet, UnicodeSet, UnicodeSet]
      var s: StringBuilder
      var pattern: StringBuilder
skipSets[D].ApplyPattern("[:NFD_Inert:]")
skipSets[C].ApplyPattern("[:NFC_Inert:]")
skipSets[KD].ApplyPattern("[:NFKD_Inert:]")
skipSets[KC].ApplyPattern("[:NFKC_Inert:]")
    expectSets = initSkippables(expectSets)
    if expectSets[D].Contains(848):
Errln("expectSets[D] contains 0x0350")
      var i: int = 0
      while i < expectSets.Length:
          if !skipSets[i].Equals(expectSets[i]):
              var ms: string = kModeStrings[i]
Errln("error: TestSkippable skipSets[" + ms + "]!=expectedSets[" + ms + "]
")
              s = StringBuilder
s.Append("

skip=       ")
s.Append(skipSets[i].ToPattern(true))
s.Append("

")
s.Append("skip-expect=")
              pattern = StringBuilder(cast[UnicodeSet](skipSets[i].Clone).RemoveAll(expectSets[i]).ToPattern(true))
s.Append(pattern)
pattern.Delete(0, pattern.Length - 0)
s.Append("

expect-skip=")
              pattern = StringBuilder(cast[UnicodeSet](expectSets[i].Clone).RemoveAll(skipSets[i]).ToPattern(true))
s.Append(pattern)
s.Append("

")
pattern.Delete(0, pattern.Length - 0)
s.Append("

intersection(expect,skip)=")
              var intersection: UnicodeSet = cast[UnicodeSet](expectSets[i].Clone).RetainAll(skipSets[i])
              pattern = StringBuilder(intersection.ToPattern(true))
s.Append(pattern)
s.Append('
')
s.Append('
')
Errln(s.ToString)
++i
proc TestBugJ2068*() =
    var sample: string = "The quick brown fox jumped over the lazy dog"
    var text: UCharacterIterator = UCharacterIterator.GetInstance(sample)
    var norm: Normalizer = Normalizer(text, NormalizerMode.NFC, 0)
    text.Index = 4
    if text.Current == norm.Current:
Errln("Normalizer is not cloning the UCharacterIterator")
proc TestGetCombiningClass*() =
      var i: int = 0
      while i < 1114111:
          var cc: int = UChar.GetCombiningClass(i)
          if 55296 <= i && i <= 57343 && cc > 0:
              cc = UChar.GetCombiningClass(i)
Errln("CC: " + cc + " for codepoint: " + Utility.Hex(i, 8))
++i
proc TestSerializedSet*() =
    var sset: USerializedSet = USerializedSet
    var set: UnicodeSet = UnicodeSet
      var start: int
      var end: int
    var serialized: char[] = @[cast[char](32775), cast[char](3), cast[char](192), cast[char](254), cast[char](65532), cast[char](1), cast[char](9), cast[char](16), cast[char](65532)]
sset.GetSet(serialized, 0)
    var startEnd: int[] = seq[int]
    var count: int = sset.CountRanges
      var j: int = 0
      while j < count:
sset.GetRange(j, startEnd)
set.Add(startEnd[0], startEnd[1])
++j
    var it: UnicodeSetIterator = UnicodeSetIterator(set)
    while it.NextRange && it.Codepoint != UnicodeSetIterator.IsString:
        start = it.Codepoint
        end = it.CodepointEnd
        while start <= end:
            if !sset.Contains(start):
Errln("USerializedSet.contains failed for " + Utility.Hex(start, 8))
++start
proc TestReturnFailure*() =
    var term: char[] = @['r', '�', 's', 'u', 'm', '�']
    var decomposed_term: char[] = seq[char]
Normalizer.TryDecompose(term.AsSpan(0, term.Length), decomposed_term.AsSpan(0, decomposed_term.Length),     var rc: int, true, 0)
Normalizer.TryDecompose(term.AsSpan(0, term.Length), decomposed_term.AsSpan(10, decomposed_term.Length - 10),     var rc1: int, true, 0)
    if rc != rc1:
Errln("Normalizer decompose did not return correct length")
type
  TestCompositionCase = ref object
    mode: NormalizerMode
    options: int
    input: string

proc newTestCompositionCase(mode: NormalizerMode, options: int, input: string, expect: string): TestCompositionCase =
  self.mode = mode
  self.options = options
  self.input = input
  self.expect = expect
proc TestComposition*() =
    var cases: TestCompositionCase[] = @[TestCompositionCase(NormalizerMode.NFC, 0, "ᄀ̀ᅡ̧", "ᄀ̀ᅡ̧"), TestCompositionCase(NormalizerMode.NFC, 0, "ᄀ̀ᅡ̧ᆨ", "ᄀ̀ᅡ̧ᆨ"), TestCompositionCase(NormalizerMode.NFC, 0, "가̧̀ᆨ", "가̧̀ᆨ"), TestCompositionCase(NormalizerMode.NFC, 0, "େ̀ା", "େ̀ା")]
    var output: string
    var i: int
      i = 0
      while i < cases.Length:
          output = Normalizer.Normalize(cases[i].input, cases[i].mode, cases[i].options.AsFlagsToEnum)
          if !output.Equals(cases[i].expect):
Errln("unexpected result for case " + i)
++i
proc TestGetDecomposition*() =
    var n2: Normalizer2 = Normalizer2.GetInstance(nil, "nfc", Normalizer2Mode.ComposeContiguous)
    var decomp: string = n2.GetDecomposition(32)
assertEquals("fcc.getDecomposition(space) failed", nil, decomp)
    decomp = n2.GetDecomposition(228)
assertEquals("fcc.getDecomposition(a-umlaut) failed", "ä", decomp)
    decomp = n2.GetDecomposition(44033)
assertEquals("fcc.getDecomposition(Hangul syllable U+AC01) failed", "각", decomp)
proc TestGetRawDecomposition*() =
    var n2: Normalizer2 = Normalizer2.NFKCInstance
    var decomp: string = n2.GetRawDecomposition(32)
assertEquals("nfkc.getRawDecomposition(space) failed", nil, decomp)
    decomp = n2.GetRawDecomposition(228)
assertEquals("nfkc.getRawDecomposition(a-umlaut) failed", "ä", decomp)
    decomp = n2.GetRawDecomposition(7688)
assertEquals("nfkc.getRawDecomposition(c-cedilla-acute) failed", "Ḉ", decomp)
    decomp = n2.GetRawDecomposition(8491)
assertEquals("nfkc.getRawDecomposition(angstrom sign) failed", "Å", decomp)
    decomp = n2.GetRawDecomposition(44032)
assertEquals("nfkc.getRawDecomposition(Hangul syllable U+AC00) failed", "가", decomp)
    decomp = n2.GetRawDecomposition(44033)
assertEquals("nfkc.getRawDecomposition(Hangul syllable U+AC01) failed", "각", decomp)
proc TestCanonIterData*() =
    var impl: Normalizer2Impl = Norm2AllModes.NFCInstance.Impl.EnsureCanonIterData
    if impl.IsCanonSegmentStarter(4021):
Errln("isCanonSegmentStarter(U+0fb5)=true is wrong")
    var segStarters: UnicodeSet = UnicodeSet("[:Segment_Starter:]").Freeze
    if segStarters.Contains(4021):
Errln("[:Segment_Starter:].Contains(U+0fb5)=true is wrong")
      var c: int = 0
      while c <= 13311:
          var isStarter: bool = impl.IsCanonSegmentStarter(c)
          var isContained: bool = segStarters.Contains(c)
          if isStarter != isContained:
Errln(string.Format("discrepancy: isCanonSegmentStarter(U+%04x)=%5b != " + "[:Segment_Starter:].Contains(same)", c, isStarter))
++c
proc checkLowMappingToEmpty(n2: Normalizer2) =
    var mapping: string = n2.GetDecomposition(173)
assertNotNull("getDecomposition(soft hyphen)", mapping)
assertTrue("soft hyphen maps to empty", mapping == string.Empty)
assertFalse("soft hyphen has no boundary before", n2.HasBoundaryBefore(173))
assertFalse("soft hyphen has no boundary after", n2.HasBoundaryAfter(173))
assertFalse("soft hyphen is not inert", n2.IsInert(173))
proc TestNFC*() =
    var nfc: Normalizer2 = Normalizer2.NFCInstance
assertTrue("nfc.hasBoundaryAfter(space)", nfc.HasBoundaryAfter(' '))
assertFalse("nfc.hasBoundaryAfter(ä)", nfc.HasBoundaryAfter('�'))
proc TestNFD*() =
    var nfd: Normalizer2 = Normalizer2.NFDInstance
assertTrue("nfd.hasBoundaryAfter(space)", nfd.HasBoundaryAfter(' '))
assertFalse("nfd.hasBoundaryAfter(ä)", nfd.HasBoundaryAfter('�'))
proc TestFCD*() =
    var fcd: Normalizer2 = Normalizer2.GetInstance(nil, "nfc", Normalizer2Mode.FCD)
assertTrue("fcd.hasBoundaryAfter(space)", fcd.HasBoundaryAfter(' '))
assertFalse("fcd.hasBoundaryAfter(ä)", fcd.HasBoundaryAfter('�'))
assertTrue("fcd.isInert(space)", fcd.IsInert(' '))
assertFalse("fcd.isInert(ä)", fcd.IsInert('�'))
    var impl: FCDNormalizer2 = cast[FCDNormalizer2](fcd)
assertEquals("fcd impl.getQuickCheck(space)", 1, impl.GetQuickCheck(' '))
assertEquals("fcd impl.getQuickCheck(ä)", 0, impl.GetQuickCheck('�'))
proc TestNoneNormalizer*() =
assertEquals("NONE.Concatenate()", "ä̧", Normalizer.Concat("ä", "̧", NormalizerMode.None, 0))
    var input: string = "ä̧"
assertTrue("NONE.IsNormalized()", Normalizer.IsNormalized(input, NormalizerMode.None, 0))
type
  TestNormalizer2 = ref object


proc newTestNormalizer2(): TestNormalizer2 =

proc Normalize*(src: ReadOnlySpan[char], dest: StringBuffer): StringBuffer =
    return nil
proc Normalize(src: ReadOnlySpan[char], dest: ValueStringBuilder) =

proc Normalize*(src: ReadOnlySpan[char], dest: TAppendable): TAppendable =
    return nil
proc NormalizeSecondAndAppend*(first: StringBuffer, second: ReadOnlySpan[char]): StringBuffer =
    return nil
proc NormalizeSecondAndAppend(first: ValueStringBuilder, second: ReadOnlySpan[char]) =

proc Append*(first: StringBuffer, second: ReadOnlySpan[char]): StringBuffer =
    return nil
proc Append(first: ValueStringBuilder, second: ReadOnlySpan[char]) =

proc GetDecomposition*(c: int): string =
    return nil
proc TryGetDecomposition*(codePoint: int, destination: Span[char], charsLength: int): bool =
    charsLength = 0
    return false
proc IsNormalized*(s: ReadOnlySpan[char]): bool =
    return false
proc QuickCheck*(s: ReadOnlySpan[char]): QuickCheckResult =
    return cast[QuickCheckResult](-1)
proc SpanQuickCheckYes*(s: ReadOnlySpan[char]): int =
    return 0
proc HasBoundaryBefore*(c: int): bool =
    return false
proc HasBoundaryAfter*(c: int): bool =
    return false
proc IsInert*(c: int): bool =
    return false
proc TryNormalize*(source: ReadOnlySpan[char], destination: Span[char], charsLength: int): bool =
    charsLength = 0
    return false
proc TryNormalizeSecondAndConcat*(first: ReadOnlySpan[char], second: ReadOnlySpan[char], destination: Span[char], charsLength: int): bool =
    charsLength = 0
    return false
proc TryConcat*(first: ReadOnlySpan[char], second: ReadOnlySpan[char], destination: Span[char], charsLength: int): bool =
    charsLength = 0
    return false
proc TestGetRawDecompositionBase*() =
    var c: int = '�'
assertEquals("Unexpected value returned from Normalizer2.getRawDecomposition()", nil, tnorm2.GetRawDecomposition(c))
proc TestComposePairBase*() =
    var a: int = 'a'
    var b: int = '�'
assertEquals("Unexpected value returned from Normalizer2.composePair()", -1, tnorm2.ComposePair(a, b))
proc TestGetCombiningClassBase*() =
    var c: int = '�'
assertEquals("Unexpected value returned from Normalizer2.getCombiningClass()", 0, tnorm2.GetCombiningClass(c))