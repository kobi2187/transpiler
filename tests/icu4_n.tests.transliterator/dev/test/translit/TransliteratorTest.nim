# "Namespace: ICU4N.Dev.Test.Translit"
type
  TransliteratorTest = ref object
    registerRules: seq[string] = @[@["Any-Dev1", "x > X; y > Y;"], @["Any-Dev2", "XY > Z"], @["Greek-Latin/FAKE", "[^[:L:][:M:]] { μπ > b ; " + "μπ } [^[:L:][:M:]] > b ; " + "[^[:L:][:M:]] { [Μμ][Ππ] > B ; " + "[Μμ][Ππ] } [^[:L:][:M:]] > B ;"]]
    DESERET_DEE: String = UTF16.ValueOf(66580)
    DESERET_dee: String = UTF16.ValueOf(66620)
    testCases: seq[String] = @[@["NFD", "à à 가 ｶﾞϓ"], @["NFC", "à à 가 ｶﾞϓ"], @["NFKD", "à à 가 ｶﾞϓ"], @["NFKC", "à à 가 ｶﾞϓ"], @["Greek-Latin/UNGEGN", "(μπ)", "(b)"], @["Greek-Latin/FAKE", "(μπ)", "(b)"], @["nfd;Dev1;Dev2;nfc", "xy", "Z"], @["Title", "ab'cD ffiıIİ Ǉǈǉ " + DESERET_dee + DESERET_DEE, "Ab'cd Ffiıii̇ ǈǉǉ " + DESERET_DEE + DESERET_dee], @["Upper", "ab'cD ﬀiıIİ Ǉǈǉ " + DESERET_dee + DESERET_DEE, "AB'CD FFIIIİ ǇǇǇ " + DESERET_DEE + DESERET_DEE], @["Lower", "ab'cD ﬀiıIİ Ǉǈǉ " + DESERET_dee + DESERET_DEE, "ab'cd ﬀiıii̇ ǉǉǉ " + DESERET_dee + DESERET_dee], @["Upper", "ab'cD ﬀiıIİ Ǉǈǉ " + DESERET_dee + DESERET_DEE], @["Lower", "ab'cD ﬀiıIİ Ǉǈǉ " + DESERET_dee + DESERET_DEE], @["Greek-Latin/UNGEGN", "σ σς ςσ", "s ss s̱s̱"], @["Latin-Greek/UNGEGN", "s ss s̱s̱", "σ σς ςσ"], @["Greek-Latin", "σ σς ςσ", "s ss s̱s̱"], @["Latin-Greek", "s ss s̱s̱", "σ σς ςσ"], @["Upper", "tatʹâna", "TATʹÂNA"], @["Lower", "TATʹÂNA", "tatʹâna"], @["Title", "tatʹâna", "Tatʹâna"]]
    BEGIN_END_RULES: seq[String] = @["abc > xy;" + "aba > z;", "", "", "", "abc > xy;" + "::Null;" + "aba > z;", "::Upper;" + "ABC > xy;" + "AB > x;" + "C > z;" + "::Upper;" + "XYZ > p;" + "XY > q;" + "Z > r;" + "::Upper;", "$ws = [[:Separator:][\u0009-\u000C]$];" + "$delim = [\-$ws];" + "$ws $delim* > ' ';" + "'-' $delim* > '-';", "::Null;" + "$ws = [[:Separator:][\u0009-\u000C]$];" + "$delim = [\-$ws];" + "$ws $delim* > ' ';" + "'-' $delim* > '-';", "$ws = [[:Separator:][\u0009-\u000C]$];" + "$delim = [\-$ws];" + "$ws $delim* > ' ';" + "'-' $delim* > '-';" + "::Null;", "$ws = [[:Separator:][\u0009-\u000C]$];" + "$delim = [\-$ws];" + "::Null;" + "$ws $delim* > ' ';" + "'-' $delim* > '-';", "", "", "", "$ws = [[:Separator:][\u0009-\u000C]$];" + "$delim = [\-$ws];" + "$ab = [ab];" + "::Null;" + "$ws $delim* > ' ';" + "'-' $delim* > '-';" + "::Null;" + "$ab { ' ' } $ab > '-';" + "c { ' ' > ;" + "::Null;" + "'a-a' > a\%|a;", "", "::[abc];" + "abc > xy;" + "::Null;" + "aba > yz;" + "::Upper;", "", "::[abc];" + "abc <> xy;" + "::Null;" + "aba <> yz;" + "::Upper(Lower);" + "::([XYZ]);"]
    BEGIN_END_TEST_CASES: seq[String] = @[BEGIN_END_RULES[0], "abc ababc aba", "xy zbc z", BEGIN_END_RULES[4], "abc ababc aba", "xy abxy z", BEGIN_END_RULES[5], "abccabaacababcbc", "PXAARXQBR", BEGIN_END_RULES[6], "e   e - e---e-  e", "e e e-e-e", BEGIN_END_RULES[7], "e   e - e---e-  e", "e e e-e-e", BEGIN_END_RULES[8], "e   e - e---e-  e", "e e e-e-e", BEGIN_END_RULES[9], "e   e - e---e-  e", "e e e-e-e", BEGIN_END_RULES[13], "e   e - e---e-  e", "e e e-e-e", BEGIN_END_RULES[13], "a    a    a    a", "a%a%a%a", BEGIN_END_RULES[13], "a a-b c b a", "a%a-b cb-a", BEGIN_END_RULES[15], "abc xy ababc xyz aba", "XY xy ABXY xyz YZ", BEGIN_END_RULES[17], "abc xy ababc xyz aba", "XY xy ABXY xyz YZ"]

proc TestHangul*() =
    var lh: Transliterator = Transliterator.GetInstance("Latin-Hangul")
    var hl: Transliterator = lh.GetInverse
AssertTransform("Transform", "츠", lh, "ch")
AssertTransform("Transform", "아따", lh, hl, "atta", "a-tta")
AssertTransform("Transform", "아빠", lh, hl, "appa", "a-ppa")
AssertTransform("Transform", "아짜", lh, hl, "ajja", "a-jja")
AssertTransform("Transform", "아까", lh, hl, "akka", "a-kka")
AssertTransform("Transform", "아싸", lh, hl, "assa", "a-ssa")
AssertTransform("Transform", "아차", lh, hl, "acha", "a-cha")
AssertTransform("Transform", "악사", lh, hl, "agsa", "ag-sa")
AssertTransform("Transform", "안자", lh, hl, "anja", "an-ja")
AssertTransform("Transform", "안하", lh, hl, "anha", "an-ha")
AssertTransform("Transform", "알가", lh, hl, "alga", "al-ga")
AssertTransform("Transform", "알마", lh, hl, "alma", "al-ma")
AssertTransform("Transform", "알바", lh, hl, "alba", "al-ba")
AssertTransform("Transform", "알사", lh, hl, "alsa", "al-sa")
AssertTransform("Transform", "알타", lh, hl, "alta", "al-ta")
AssertTransform("Transform", "알파", lh, hl, "alpa", "al-pa")
AssertTransform("Transform", "알하", lh, hl, "alha", "al-ha")
AssertTransform("Transform", "압사", lh, hl, "absa", "ab-sa")
AssertTransform("Transform", "안가", lh, hl, "anga", "an-ga")
AssertTransform("Transform", "악싸", lh, hl, "agssa", "ag-ssa")
AssertTransform("Transform", "안짜", lh, hl, "anjja", "an-jja")
AssertTransform("Transform", "알싸", lh, hl, "alssa", "al-ssa")
AssertTransform("Transform", "알따", lh, hl, "altta", "al-tta")
AssertTransform("Transform", "알빠", lh, hl, "alppa", "al-ppa")
AssertTransform("Transform", "압싸", lh, hl, "abssa", "ab-ssa")
AssertTransform("Transform", "앆카", lh, hl, "akkka", "akk-ka")
AssertTransform("Transform", "았사", lh, hl, "asssa", "ass-sa")
proc TestChinese*() =
    var hanLatin: Transliterator = Transliterator.GetInstance("Han-Latin")
AssertTransform("Transform", "zào Unicode", hanLatin, "造Unicode")
AssertTransform("Transform", "zài chuàng zào Unicode zhī qián", hanLatin, "在創造Unicode之前")
proc TestRegistry*() =
checkRegistry("foo3", "::[a-z]; ::NFC; [:letter:] a > b;")
checkRegistry("foo2", "::NFC; [:letter:] a > b;")
checkRegistry("foo1", "[:letter:] a > b;")
    for id in Transliterator.GetAvailableIDs:
checkRegistry(id)
Transliterator.Unregister("foo3")
Transliterator.Unregister("foo2")
Transliterator.Unregister("foo1")
proc checkRegistry(id: String, rules: String) =
    var foo: Transliterator = Transliterator.CreateFromRules(id, rules, Transliterator.Forward)
Transliterator.RegisterInstance(foo)
checkRegistry(id)
proc checkRegistry(id: String) =
    var fie: Transliterator = Transliterator.GetInstance(id)
    var fae: UnicodeSet = UnicodeSet("[a-z5]")
    fie.Filter = fae
    var foe: Transliterator = Transliterator.GetInstance(id)
    var fee: UnicodeFilter = foe.Filter
    if fae.Equals(fee):
Errln("Changed what is in registry for " + id)
proc TestInstantiationError*() =
    try:
        var ID: String = "<Not a valid Transliterator ID>"
        var t: Transliterator = Transliterator.GetInstance(ID)
Errln("FAIL: " + ID + " returned " + t)
    except ArgumentException:
Logln("OK: Bogus ID handled properly")
proc TestSimpleRules*() =
Expect("ab>x|y;" + "yc>z", "eabcd", "exzd")
Expect("ab>x|yzacw;" + "za>q;" + "qc>r;" + "cw>n", "ab", "xyqn")
    var t: Transliterator = Transliterator.CreateFromRules("<ID>", "$dummy=;" + "$vowel=[aeiouAEIOU];" + "$lu=[:Lu:];" + "$vowel } $lu > '!';" + "$vowel > '&';" + "'!' { $lu > '^';" + "$lu > '*';" + "a>ERROR", Transliterator.Forward)
Expect(t, "abcdefgABCDEFGU", "&bcd&fg!^**!^*&")
proc TestInlineSet*() =
Expect("{ [:Ll:] } x > y; [:Ll:] > z;", "aAbxq", "zAyzz")
Expect("a[0-9]b > qrs", "1a7b9", "1qrs9")
Expect("$digit = [0-9];" + "$alpha = [a-zA-Z];" + "$alphanumeric = [$digit $alpha];" + "$special = [^$alphanumeric];" + "$alphanumeric > '-';" + "$special > '*';", "thx-1138", "---*----")
proc TestRuleBasedInverse*() =
    var RULES: String = "abc>zyx;" + "ab>yz;" + "bc>zx;" + "ca>xy;" + "a>x;" + "b>y;" + "c>z;" + "abc<zyx;" + "ab<yz;" + "bc<zx;" + "ca<xy;" + "a<x;" + "b<y;" + "c<z;" + ""
    var DATA: String[] = @["a", "x", "abcacab", "zyxxxyy", "caccb", "xyzzy"]
    var fwd: Transliterator = Transliterator.CreateFromRules("<ID>", RULES, Transliterator.Forward)
    var rev: Transliterator = Transliterator.CreateFromRules("<ID>", RULES, Transliterator.Reverse)
      var i: int = 0
      while i < DATA.Length:
Expect(fwd, DATA[i], DATA[i + 1])
Expect(rev, DATA[i + 1], DATA[i])
          i = 2
proc TestKeyboard*() =
    var t: Transliterator = Transliterator.CreateFromRules("<ID>", "psch>Y;" + "ps>y;" + "ch>x;" + "a>A;", Transliterator.Forward)
    var DATA: String[] = @["a", "A", "p", "Ap", "s", "Aps", "c", "Apsc", "a", "AycA", "psch", "AycAY", nil, "AycAY"]
keyboardAux(t, DATA)
proc TestKeyboard2*() =
    var t: Transliterator = Transliterator.CreateFromRules("<ID>", "ych>Y;" + "ps>|y;" + "ch>x;" + "a>A;", Transliterator.Forward)
    var DATA: String[] = @["a", "A", "p", "Ap", "s", "Aps", "c", "Apsc", "a", "AycA", "p", "AycAp", "s", "AycAps", "c", "AycApsc", "h", "AycAY", nil, "AycAY"]
keyboardAux(t, DATA)
proc TestKeyboard3*() =
    var RULES: String = "t>|y;" + "yh>z;" + ""
    var DATA: String[] = @["a", "a", "b", "ab", "t", "abt", "c", "abyc", "t", "abyct", "h", "abycz", nil, "abycz"]
    var t: Transliterator = Transliterator.CreateFromRules("<ID>", RULES, Transliterator.Forward)
keyboardAux(t, DATA)
proc keyboardAux(t: Transliterator, DATA: seq[String]) =
    var index: TransliterationPosition = TransliterationPosition
    var s: ReplaceableString = ReplaceableString
      var i: int = 0
      while i < DATA.Length:
          var log: StringBuffer
          if DATA[i] != nil:
              log = StringBuffer(s.ToString + " + " + DATA[i] + " -> ")
t.Transliterate(s, index, DATA[i])
          else:
              log = StringBuffer(s.ToString + " => ")
t.FinishTransliteration(s, index)
UtilityExtensions.FormatInput(log, s, index)
          if s.ToString.Equals(DATA[i + 1]):
Logln(log.ToString)
          else:
Errln("FAIL: " + log.ToString + ", expected " + DATA[i + 1])
          i = 2
proc TestCompoundKana*() =
    var t: Transliterator = Transliterator.GetInstance("Latin-Katakana;Katakana-Latin")
Expect(t, "aaaaa", "aaaaa")
proc TestCompoundHex*() =
    var a: Transliterator = Transliterator.GetInstance("Any-Hex")
    var b: Transliterator = Transliterator.GetInstance("Hex-Any")
    var ab: Transliterator = Transliterator.GetInstance("Any-Hex;Hex-Any")
Expect(b, "\u0030\u0031", "01")
    var s: String = "abcde"
Expect(ab, s, s)
    var ba: Transliterator = Transliterator.GetInstance("Hex-Any;Any-Hex")
    var str: ReplaceableString = ReplaceableString(s)
a.Transliterate(str)
Expect(ba, str.ToString, str.ToString)
type
  TestFilteringUnicodeFilter = ref object


proc Contains*(c: int): bool =
    return c != 'c'
proc ToPattern*(escapeUnprintable: bool): string =
    return ""
proc TryToPattern*(escapeUnprintable: bool, destination: Span[char], charsLength: int): bool =
    destination = nil
    charsLength = 0
    return true
proc MatchesIndexValue*(v: int): bool =
    return false
proc AddMatchSetTo*(toUnionTo: UnicodeSet) =

proc TestFiltering*() =
    var tempTrans: Transliterator = Transliterator.CreateFromRules("temp", "x > y; x{a} > b; ", Transliterator.Forward)
    tempTrans.Filter = UnicodeSet("[a]")
    var tempResult: String = tempTrans.Transform("xa")
assertEquals("context should not be filtered ", "xb", tempResult)
    tempTrans = Transliterator.CreateFromRules("temp", "::[a]; x > y; x{a} > b; ", Transliterator.Forward)
    tempResult = tempTrans.Transform("xa")
assertEquals("context should not be filtered ", "xb", tempResult)
    var hex: Transliterator = Transliterator.GetInstance("Any-Hex")
    hex.Filter = TestFilteringUnicodeFilter
    var s: String = "abcde"
    var @out: String = hex.Transliterate(s)
    var exp: String = "\u0061\u0062c\u0064\u0065"
    if @out.Equals(exp):
Logln("Ok:   "" + exp + """)
    else:
Logln("FAIL: "" + @out + "", wanted "" + exp + """)
proc TestAnchors*() =
Expect("^ab  > 01 ;" + " ab  > |8 ;" + "  b  > k ;" + " 8x$ > 45 ;" + " 8x  > 77 ;", "ababbabxabx", "018k7745")
Expect("$s = [z$] ;" + "$s{ab    > 01 ;" + "   ab    > |8 ;" + "    b    > k ;" + "   8x}$s > 45 ;" + "   8x    > 77 ;", "abzababbabxzabxabx", "01z018k45z01x45")
proc TestPatternQuoting*() =
    var DATA: String[] = @["丁>'[male adult]'", "丁", "[male adult]"]
      var i: int = 0
      while i < DATA.Length:
Logln("Pattern: " + Utility.Escape(DATA[i]))
          var t: Transliterator = Transliterator.CreateFromRules("<ID>", DATA[i], Transliterator.Forward)
Expect(t, DATA[i + 1], DATA[i + 2])
          i = 3
proc TestVariableNames*() =
    var gl: Transliterator = Transliterator.CreateFromRules("foo5", "$ⷀ = qy; a>b;", Transliterator.Forward)
    if gl == nil:
Errln("FAIL: null Transliterator returned.")
proc TestJ277*() =
    var gl: Transliterator = Transliterator.GetInstance("Greek-Latin; NFD; [:M:]Remove; NFC")
    var sigma: char = cast[char](963)
    var upsilon: char = cast[char](965)
    var nu: char = cast[char](957)
    var alpha: char = cast[char](945)
    var buf: StringBuffer = StringBuffer
buf.Append(sigma).Append(upsilon).Append(nu)
    var syn: String = buf.ToString
Expect(gl, syn, "syn")
    buf.Length = 0
buf.Append(sigma).Append(alpha).Append(upsilon).Append(nu)
    var sayn: String = buf.ToString
Expect(gl, sayn, "saun")
    var rules: String = "$alpha   = α;" + "$nu      = ν;" + "$sigma   = σ;" + "$ypsilon = υ;" + "$vowel   = [aeiouAEIOU$alpha$ypsilon];" + "s <>           $sigma;" + "a <>           $alpha;" + "u <>  $vowel { $ypsilon;" + "y <>           $ypsilon;" + "n <>           $nu;"
    var mini: Transliterator = Transliterator.CreateFromRules("mini", rules, Transliterator.Reverse)
Expect(mini, syn, "syn")
Expect(mini, sayn, "saun")
proc TestJ329*() =
    var DATA: Object[] = @[false, "a > b; c > d", true, "a > b; no operator; c > d"]
      var i: int = 0
      while i < DATA.Length:
          var err: String = nil
          try:
Transliterator.CreateFromRules("<ID>", cast[String](DATA[i + 1]), Transliterator.Forward)
          except ArgumentException:
              err = e.ToString
          var gotError: bool = err != nil
          var desc: String = cast[String](DATA[i + 1]) +           if gotError:
" -> error: " + err
          else:
" -> no error"
          if err != nil == cast[bool](DATA[i]):
Logln("Ok:   " + desc)
          else:
Errln("FAIL: " + desc)
          i = 2
proc TestSegments*() =
    var DATA: String[] = @["([a-z]) '.' ([0-9]) > $2 '-' $1", "abc.123.xyz.456", "ab1-c23.xy4-z56"]
      var i: int = 0
      while i < DATA.Length:
Logln("Pattern: " + Utility.Escape(DATA[i]))
          var t: Transliterator = Transliterator.CreateFromRules("<ID>", DATA[i], Transliterator.Forward)
Expect(t, DATA[i + 1], DATA[i + 2])
          i = 3
proc TestCursorOffset*() =
    var DATA: String[] = @["pre {alpha} post > | @ ALPHA ;" + "eALPHA > beta ;" + "pre {beta} post > BETA @@ | ;" + "post > xyz", "prealphapost prebetapost", "prbetaxyz preBETApost"]
      var i: int = 0
      while i < DATA.Length:
Logln("Pattern: " + Utility.Escape(DATA[i]))
          var t: Transliterator = Transliterator.CreateFromRules("<ID>", DATA[i], Transliterator.Forward)
Expect(t, DATA[i + 1], DATA[i + 2])
          i = 3
proc TestArbitraryVariableValues*() =
    var DATA: String[] = @["$abe = ab;" + "$pat = x[yY]z;" + "$ll  = 'a-z';" + "$llZ = [$ll];" + "$llY = [$ll$pat];" + "$emp = ;" + "$abe > ABE;" + "$pat > END;" + "$llZ > 1;" + "$llY > 2;" + "7$emp 8 > 9;" + "", "ab xYzxyz stY78", "ABE ENDEND 1129"]
      var i: int = 0
      while i < DATA.Length:
Logln("Pattern: " + Utility.Escape(DATA[i]))
          var t: Transliterator = Transliterator.CreateFromRules("<ID>", DATA[i], Transliterator.Forward)
Expect(t, DATA[i + 1], DATA[i + 2])
          i = 3
proc TestPositionHandling*() =
    var DATA: String[] = @["a{t} > SS ; {t}b > UU ; {t} > TT ;", "xtat txtb", "xTTaSS TTxUUb", "a{t} > SS ; {t}b > UU ; {t} > TT ;", "xtat txtb", "xtaSS TTxUUb", "a{t} > SS ; {t}b > UU ; {t} > TT ;", "xtat txtb", "xtaTT TTxTTb"]
    var POS: int[] = @[0, 9, 0, 9, 2, 9, 3, 8, 3, 8, 3, 8]
    var n: int = DATA.Length / 3
      var i: int = 0
      while i < n:
          var t: Transliterator = Transliterator.CreateFromRules("<ID>", DATA[3 * i], Transliterator.Forward)
          var pos: TransliterationPosition = TransliterationPosition(POS[4 * i], POS[4 * i + 1], POS[4 * i + 2], POS[4 * i + 3])
          var rsource: ReplaceableString = ReplaceableString(DATA[3 * i + 1])
t.Transliterate(rsource, pos)
t.FinishTransliteration(rsource, pos)
          var result: String = rsource.ToString
          var exp: String = DATA[3 * i + 2]
ExpectAux(Utility.Escape(DATA[3 * i]), DATA[3 * i + 1], result, result.Equals(exp), exp)
++i
proc TestHiraganaKatakana*() =
    var hk: Transliterator = Transliterator.GetInstance("Hiragana-Katakana")
    var kh: Transliterator = Transliterator.GetInstance("Katakana-Hiragana")
    var DATA: String[] = @["both", "あゐ゙をぐ", "アヸヲグ", "kh", "ぼけだあんー", "ボヶダーンー"]
      var i: int = 0
      while i < DATA.Length:
          case DATA[i][0]
          of 'h':
Expect(hk, DATA[i + 1], DATA[i + 2])
              break
          of 'k':
Expect(kh, DATA[i + 2], DATA[i + 1])
              break
          of 'b':
Expect(hk, DATA[i + 1], DATA[i + 2])
Expect(kh, DATA[i + 2], DATA[i + 1])
              break
          i = 3
proc TestCopyJ476*() =

proc TestInterIndic*() =
    var ID: String = "Devanagari-Gujarati"
    var dg: Transliterator = Transliterator.GetInstance(ID)
    if dg == nil:
Errln("FAIL: getInstance(" + ID + ") returned null")
        return
    var id: String = dg.ID
    if !id.Equals(ID):
Errln("FAIL: getInstance(" + ID + ").ID => " + id)
    var dev: String = "ँऋथ"
    var guj: String = "ઁઋથ"
Expect(dg, dev, guj)
proc TestFilterIDs*() =
    var DATA: String[] = @["[aeiou]Any-Hex", "[aeiou]Hex-Any", "quizzical", "q\u0075\u0069zz\u0069c\u0061l", "[aeiou]Any-Hex;[^5]Hex-Any", "[^5]Any-Hex;[aeiou]Hex-Any", "quizzical", "q\u0075izzical", "[abc]Null", "[abc]Null", "xyz", "xyz"]
      var i: int = 0
      while i < DATA.Length:
          var ID: String = DATA[i]
          var t: Transliterator = Transliterator.GetInstance(ID)
Expect(t, DATA[i + 2], DATA[i + 3])
          if !ID.Equals(t.ID):
Errln("FAIL: getInstance(" + ID + ").ID => " + t.ID)
          var uID: String = DATA[i + 1]
          var u: Transliterator = t.GetInverse
          if u == nil:
Errln("FAIL: " + ID + ".GetInverse() returned NULL")

          elif !u.ID.Equals(uID):
Errln("FAIL: " + ID + ".GetInverse().ID => " + u.ID + ", expected " + uID)
          i = 4
proc TestCaseMap*() =
    var toUpper: Transliterator = Transliterator.GetInstance("Any-Upper[^xyzXYZ]")
    var toLower: Transliterator = Transliterator.GetInstance("Any-Lower[^xyzXYZ]")
    var toTitle: Transliterator = Transliterator.GetInstance("Any-Title[^xyzXYZ]")
Expect(toUpper, "The quick brown fox jumped over the lazy dogs.", "THE QUICK BROWN FOx JUMPED OVER THE LAzy DOGS.")
Expect(toLower, "The quIck brown fOX jUMPED OVER THE LAzY dogs.", "the quick brown foX jumped over the lazY dogs.")
Expect(toTitle, "the quick brown foX caN'T jump over the laZy dogs.", "The Quick Brown FoX Can't Jump Over The LaZy Dogs.")
proc TestNameMap*() =
    var uni2name: Transliterator = Transliterator.GetInstance("Any-Name[^abc]")
    var name2uni: Transliterator = Transliterator.GetInstance("Name-Any")
Expect(uni2name, " abc丁µઁ�	￿", "\N{NO-BREAK SPACE}abc\N{CJK UNIFIED IDEOGRAPH-4E01}\N{MICRO SIGN}\N{GUJARATI SIGN CANDRABINDU}\N{REPLACEMENT CHARACTER}\N{<control-0004>}\N{<control-0009>}\N{<control-0081>}\N{<noncharacter-FFFF>}")
Expect(name2uni, "{\N { NO-BREAK SPACE}abc\N{  CJK UNIFIED  IDEOGRAPH-4E01  }\N{x\N{MICRO SIGN}\N{GUJARATI SIGN CANDRABINDU}\N{REPLACEMENT CHARACTER}\N{<control-0004>}\N{<control-0009>}\N{<control-0081>}\N{<noncharacter-FFFF>}\N{<control-0004>}\N{", "{ abc丁\N{xµઁ�	￿\N{")
    var t: Transliterator = Transliterator.GetInstance("Any-Name;Name-Any")
    var s: String = "{ abc丁\N{xµઁ�	￿\N{"
Expect(t, s, s)
proc TestLiberalizedID*() =
    var DATA: String[] = @["latin-greek", nil, "case insensitivity", "  Null  ", "Null", "whitespace", " Latin[a-z]-Greek  ", "[a-z]Latin-Greek", "inline filter", "  null  ; latin-greek  ", nil, "compound whitespace"]
      var i: int = 0
      while i < DATA.Length:
          try:
              var t: Transliterator = Transliterator.GetInstance(DATA[i])
              if DATA[i + 1] == nil || DATA[i + 1].Equals(t.ID):
Logln("Ok: " + DATA[i + 2] + " create ID "" + DATA[i] + "" => "" + t.ID + """)
              else:
Errln("FAIL: " + DATA[i + 2] + " create ID "" + DATA[i] + "" => "" + t.ID + "", exp "" + DATA[i + 1] + """)
          except ArgumentException:
Errln("FAIL: " + DATA[i + 2] + " create ID "" + DATA[i] + """)
          i = 3
proc TestCreateInstance*() =
    var FORWARD: String = "F"
    var REVERSE: String = "R"
    var DATA: String[] = @["Latin-Hangul", REVERSE, "Hangul-Latin", "InvalidSource-InvalidTarget", FORWARD, "", "InvalidSource-InvalidTarget", REVERSE, "", "Hex-Any;InvalidSource-InvalidTarget", FORWARD, "", "Hex-Any;InvalidSource-InvalidTarget", REVERSE, "", "InvalidSource-InvalidTarget;Hex-Any", FORWARD, "", "InvalidSource-InvalidTarget;Hex-Any", REVERSE, "", nil]
      var i: int = 0
      while DATA[i] != nil:
          var id: String = DATA[i]
          var dir: TransliterationDirection =           if DATA[i + 1] == FORWARD:
Transliterator.Forward
          else:
Transliterator.Reverse
          var expID: String = DATA[i + 2]
          var e: Exception = nil
          var t: Transliterator
          try:
              t = Transliterator.GetInstance(id, dir)
          except Exception:
              e = e1
              t = nil
          var newID: String =           if t != nil:
t.ID
          else:
""
          var ok: bool = newID.Equals(expID)
          if t == nil:
              newID = e.Message
          if ok:
Logln("Ok: createInstance(" + id + "," + DATA[i + 1] + ") => " + newID)
          else:
Errln("FAIL: createInstance(" + id + "," + DATA[i + 1] + ") => " + newID + ", expected " + expID)
          i = 3
proc TestNormalizationTransliterator*() =
    var CANON: String[][] = @[@["cat", "cat", "cat"], @["àardvark", "àardvark", "àardvark"], @["Ḋ", "Ḋ", "Ḋ"], @["Ḋ", "Ḋ", "Ḋ"], @["Ḍ̇", "Ḍ̇", "Ḍ̇"], @["Ḍ̇", "Ḍ̇", "Ḍ̇"], @["Ḍ̇", "Ḍ̇", "Ḍ̇"], @["Ḑ̣̇", "Ḑ̣̇", "Ḑ̣̇"], @["Ḍ̨̇", "Ḍ̨̇", "Ḍ̨̇"], @["Ḕ", "Ḕ", "Ḕ"], @["Ḕ", "Ḕ", "Ḕ"], @["È̄", "È̄", "È̄"], @["Å", "Å", "Å"], @["Å", "Å", "Å"], @["ýffin", "ýffin", "ýffin"], @["ýﬃn", "ýﬃn", "ýﬃn"], @["Henry IV", "Henry IV", "Henry IV"], @["Henry Ⅳ", "Henry Ⅳ", "Henry Ⅳ"], @["ガ", "ガ", "ガ"], @["ガ", "ガ", "ガ"], @["ｶﾞ", "ｶﾞ", "ｶﾞ"], @["カﾞ", "カﾞ", "カﾞ"], @["ｶ゙", "ｶ゙", "ｶ゙"], @["À̖", "À̖", "À̖"]]
    var COMPAT: String[][] = @[@["ﭏ", "אל", "אל"], @["ýffin", "ýffin", "ýffin"], @["ýﬃn", "ýffin", "ýffin"], @["Henry IV", "Henry IV", "Henry IV"], @["Henry Ⅳ", "Henry IV", "Henry IV"], @["ガ", "ガ", "ガ"], @["ガ", "ガ", "ガ"], @["ｶ゙", "ガ", "ガ"]]
    var NFD: Transliterator = Transliterator.GetInstance("NFD")
    var NFC: Transliterator = Transliterator.GetInstance("NFC")
      var i: int = 0
      while i < CANON.Length:
          var @in: String = CANON[i][0]
          var expd: String = CANON[i][1]
          var expc: String = CANON[i][2]
Expect(NFD, @in, expd)
Expect(NFC, @in, expc)
++i
    var NFKD: Transliterator = Transliterator.GetInstance("NFKD")
    var NFKC: Transliterator = Transliterator.GetInstance("NFKC")
      var i: int = 0
      while i < COMPAT.Length:
          var @in: String = COMPAT[i][0]
          var expkd: String = COMPAT[i][1]
          var expkc: String = COMPAT[i][2]
Expect(NFKD, @in, expkd)
Expect(NFKC, @in, expkc)
++i
    var t: Transliterator = Transliterator.GetInstance("NFD; [x]Remove")
Expect(t, "čx", "č")
proc TestCompoundRBT*() =
    var rule: String = "::Hex-Any;
" + "::Any-Lower;
" + "a > '.A.';
" + "b > '.B.';
" + "::[^t]Any-Upper;"
    var t: Transliterator = Transliterator.CreateFromRules("Test", rule, Transliterator.Forward)
    if t == nil:
Errln("FAIL: createFromRules failed")
        return
Expect(t, "Cat in the hat, bat on the mat", "C.A.t IN tHE H.A.t, .B..A.t ON tHE M.A.t")
    var r: String = t.ToRules(true)
    if r.Equals(rule):
Logln("OK: toRules() => " + r)
    else:
Errln("FAIL: toRules() => " + r + ", expected " + rule)
    t = Transliterator.GetInstance("Greek-Latin; Latin-Cyrillic", Transliterator.Forward)
    if t == nil:
Errln("FAIL: createInstance failed")
        return
    var exp: String = "::Greek-Latin;
::Latin-Cyrillic;"
    r = t.ToRules(true)
    if !r.Equals(exp):
Errln("FAIL: toRules() => " + r + ", expected " + exp)
    else:
Logln("OK: toRules() => " + r)
    t = Transliterator.CreateFromRules("Test", r, Transliterator.Forward)
    if t == nil:
Errln("FAIL: createFromRules #2 failed")
        return
    else:
Logln("OK: createFromRules(" + r + ") succeeded")
    r = t.ToRules(true)
    if !r.Equals(exp):
Errln("FAIL: toRules() => " + r + ", expected " + exp)
    else:
Logln("OK: toRules() => " + r)
    var id: String = "Upper(Lower);(NFKC)"
    t = Transliterator.GetInstance(id, Transliterator.Forward)
    if t == nil:
Errln("FAIL: createInstance #2 failed")
        return
    if t.ID.Equals(id):
Logln("OK: created " + id)
    else:
Errln("FAIL: createInstance(" + id + ").ID => " + t.ID)
    var u: Transliterator = t.GetInverse
    if u == nil:
Errln("FAIL: createInverse failed")
        return
    exp = "NFKC();Lower(Upper)"
    if u.ID.Equals(exp):
Logln("OK: createInverse(" + id + ") => " + u.ID)
    else:
Errln("FAIL: createInverse(" + id + ") => " + u.ID)
proc TestCompoundFilter*() =
    var t: Transliterator = Transliterator.GetInstance("Greek-Latin; Latin-Greek; Lower", Transliterator.Forward)
    t.Filter = UnicodeSet("[^A]")
Expect(t, CharsToUnicodeString("BA\u039A\u0391"), CharsToUnicodeString("\u03b2A\u03ba\u03b1"))
proc TestRemove*() =
    var t: Transliterator = Transliterator.GetInstance("Remove[aeiou]")
Expect(t, "The quick brown fox.", "Th qck brwn fx.")
proc TestToRules*() =
    var RBT: String = "rbt"
    var SET: String = "set"
    var DATA: String[] = @[RBT, "$a=\u4E61; [$a] > A;", "[\u4E61] > A;", RBT, "$white=[[:Zs:][:Zl:]]; $white{a} > A;", "[[:Zs:][:Zl:]]{a} > A;", SET, "[[:Zs:][:Zl:]]", "[[:Zs:][:Zl:]]", SET, "[:Ps:]", "[:Ps:]", SET, "[:L:]", "[:L:]", SET, "[[:L:]-[A]]", "[[:L:]-[A]]", SET, "[~[:Lu:][:Ll:]]", "[~[:Lu:][:Ll:]]", SET, "[~[a-z]]", "[~[a-z]]", RBT, "$white=[:Zs:]; $black=[^$white]; $black{a} > A;", "[^[:Zs:]]{a} > A;", RBT, "$a=[:Zs:]; $b=[[a-z]-$a]; $b{a} > A;", "[[a-z]-[:Zs:]]{a} > A;", RBT, "$a=[:Zs:]; $b=[$a&[a-z]]; $b{a} > A;", "[[:Zs:]&[a-z]]{a} > A;", RBT, "$a=[:Zs:]; $b=[x$a]; $b{a} > A;", "[x[:Zs:]]{a} > A;", RBT, "$accentMinus = [ [\u0300-\u0345] & [:M:] - [\u0338]] ;" + "$macron = \u0304 ;" + "$evowel = [aeiouyAEIOUY] ;" + "$iotasub = \u0345 ;" + "($evowel $macron $accentMinus *) i > | $1 $iotasub ;", "([AEIOUYaeiouy]\u0304[[\u0300-\u0345]&[:M:]-[\u0338]]*)i > | $1 \u0345;", RBT, "([AEIOUYaeiouy]\u0304[[:M:]-[\u0304\u0345]]*)i > | $1 \u0345;", "([AEIOUYaeiouy]\u0304[[:M:]-[\u0304\u0345]]*)i > | $1 \u0345;"]
      var d: int = 0
      while d < DATA.Length:
          if DATA[d] == RBT:
              var t: Transliterator = Transliterator.CreateFromRules("ID", DATA[d + 1], Transliterator.Forward)
              if t == nil:
Errln("FAIL: createFromRules failed")
                  return
                var rules: String
                var escapedRules: String
              rules = t.ToRules(false)
              escapedRules = t.ToRules(true)
              var expRules: String = Utility.Unescape(DATA[d + 2])
              var expEscapedRules: String = DATA[d + 2]
              if rules.Equals(expRules):
Logln("Ok: " + DATA[d + 1] + " => " + Utility.Escape(rules))
              else:
Errln("FAIL: " + DATA[d + 1] + " => " + Utility.Escape(rules + ", exp " + expRules))
              if escapedRules.Equals(expEscapedRules):
Logln("Ok: " + DATA[d + 1] + " => " + escapedRules)
              else:
Errln("FAIL: " + DATA[d + 1] + " => " + escapedRules + ", exp " + expEscapedRules)
          else:
              var pat: String = DATA[d + 1]
              var expToPat: String = DATA[d + 2]
              var set: UnicodeSet = UnicodeSet(pat)
              var toPat: String
              toPat = set.ToPattern(true)
              if expToPat.Equals(toPat):
Logln("Ok: " + pat + " => " + toPat)
              else:
Errln("FAIL: " + pat + " => " + Utility.Escape(toPat) + ", exp " + Utility.Escape(pat))
          d = 3
proc TestContext*() =
    var pos: TransliterationPosition = TransliterationPosition(0, 2, 0, 1)
Expect("de > x; {d}e > y;", "de", "ye", pos)
Expect("ab{c} > z;", "xadabdabcy", "xadabdabzy")
proc CharsToUnicodeString(s: String): String =
    return Utility.Unescape(s)
proc TestSupplemental*() =
Expect(CharsToUnicodeString("$a=\U00010300; $s=[\U00010300-\U00010323];" + "a > $a; $s > i;"), CharsToUnicodeString("ab\U0001030Fx"), CharsToUnicodeString("\U00010300bix"))
Expect(CharsToUnicodeString("$a=[a-z\U00010300-\U00010323];" + "$b=[A-Z\U00010400-\U0001044D];" + "($a)($b) > $2 $1;"), CharsToUnicodeString("aB\U00010300\U00010400c\U00010401\U00010301D"), CharsToUnicodeString("Ba\U00010400\U00010300\U00010401cD\U00010301"))
Expect(CharsToUnicodeString("$a=[a\U00010300-\U00010323];" + "$a {x} > | @ \U00010400;" + "{$a} [^\u0000-\uFFFF] > y;"), CharsToUnicodeString("kax\U00010300xm"), CharsToUnicodeString("ky\U00010400y\U00010400m"))
Expect(Transliterator.GetInstance("Any-Name"), CharsToUnicodeString("\U00010330\U000E0061\u00A0"), "\N{GOTHIC LETTER AHSA}\N{TAG LATIN SMALL LETTER A}\N{NO-BREAK SPACE}")
Expect(Transliterator.GetInstance("Name-Any"), "\N{GOTHIC LETTER AHSA}\N{TAG LATIN SMALL LETTER A}\N{NO-BREAK SPACE}", CharsToUnicodeString("\U00010330\U000E0061\u00A0"))
Expect(Transliterator.GetInstance("Any-Hex/Unicode"), CharsToUnicodeString("\U00010330\U0010FF00\U000E0061\u00A0"), "U+10330U+10FF00U+E0061U+00A0")
Expect(Transliterator.GetInstance("Any-Hex/C"), CharsToUnicodeString("\U00010330\U0010FF00\U000E0061\u00A0"), "\U00010330\U0010FF00\U000E0061\u00A0")
Expect(Transliterator.GetInstance("Any-Hex/Perl"), CharsToUnicodeString("\U00010330\U0010FF00\U000E0061\u00A0"), "\x{10330}\x{10FF00}\x{E0061}\x{A0}")
Expect(Transliterator.GetInstance("Any-Hex/Java"), CharsToUnicodeString("\U00010330\U0010FF00\U000E0061\u00A0"), "\uD800\uDF30\uDBFF\uDF00\uDB40\uDC61\u00A0")
Expect(Transliterator.GetInstance("Any-Hex/XML"), CharsToUnicodeString("\U00010330\U0010FF00\U000E0061\u00A0"), "&#x10330;&#x10FF00;&#xE0061;&#xA0;")
Expect(Transliterator.GetInstance("Any-Hex/XML10"), CharsToUnicodeString("\U00010330\U0010FF00\U000E0061\u00A0"), "&#66352;&#1113856;&#917601;&#160;")
Expect(Transliterator.GetInstance("[\U000E0000-\U000E0FFF] Remove"), CharsToUnicodeString("\U00010330\U0010FF00\U000E0061\u00A0"), CharsToUnicodeString("\U00010330\U0010FF00\u00A0"))
proc TestQuantifier*() =
Expect("a+ {b} > | @@ c; A > a; (a+ c) > '(' $1 ')';", "AAAAAb", "aaa(aac)")
Expect("{b} a+ > c @@ |; (a+) > '(' $1 ')';", "baaaaa", "caa(aaa)")
Expect("{(b)} a+ > $1 @@ |; (a+) > '(' $1 ')';", "baaaaa", "baa(aaa)")
    var pos: TransliterationPosition = TransliterationPosition(0, 5, 3, 5)
Expect("a+ {b} > | @@ c; x > y; (a+ c) > '(' $1 ')';", "xxxab", "xxx(ac)", pos)
    var pos2: TransliterationPosition = TransliterationPosition(0, 4, 0, 2)
Expect("{b} a+ > c @@ |; x > y; a > A;", "baxx", "caxx", pos2)
Expect("{b} a+ > c @@ |; x > y; a > A;", "baxx", "cayy")
Expect("(ab)? c > d;", "c abc ababc", "d d abd")
Expect("(ab)+ {x} > '(' $1 ')';", "x abx ababxy", "x ab(ab) abab(ab)y")
Expect("b+ > x;", "ac abc abbc abbbc", "ac axc axc axc")
Expect("[abc]+ > x;", "qac abrc abbcs abtbbc", "qx xrx xs xtx")
Expect("q{(ab)+} > x;", "qa qab qaba qababc qaba", "qa qx qxa qxc qxa")
Expect("q(ab)* > x;", "qa qab qaba qababc", "xa x xa xc")
Expect("q(ab)* > '(' $1 ')';", "qa qab qaba qababc", "()a (ab) (ab)a (ab)c")
Expect("'ab'+ > x;", "bb ab ababb", "bb x xb")
Expect("$var = ab; $var+ > x;", "bb ab ababb", "bb x xb")
type
  TestFact = ref object
    id: String

type
  NameableNullTrans = ref object


proc newNameableNullTrans(id: String): NameableNullTrans =
newTransliterator(id, nil)
proc HandleTransliterate(text: IReplaceable, offsets: TransliterationPosition, incremental: bool) =
    offsets.Start = offsets.Limit
proc new(theID: String) =
  id = theID
proc GetInstance*(ignoredID: String): Transliterator =
    return NameableNullTrans(id)
proc TestSTV*() =
      let es = Transliterator.GetAvailableSources.GetEnumerator
<unhandled: nnkDefer>
        var i: int = 0
        while es.MoveNext:
            var source: String = cast[String](es.Current)
Logln("" + i + ": " + source)
            if source.Length == 0:
Errln("FAIL: empty source")
                continue
              let et = Transliterator.GetAvailableTargets(source).GetEnumerator
<unhandled: nnkDefer>
                var j: int = 0
                while et.MoveNext:
                    var target: String = cast[String](et.Current)
Logln(" " + j + ": " + target)
                    if target.Length == 0:
Errln("FAIL: empty target")
                        continue
                      let ev = Transliterator.GetAvailableVariants(source, target).GetEnumerator
<unhandled: nnkDefer>
                        var k: int = 0
                        while ev.MoveNext:
                            var variant: String = cast[String](ev.Current)
                            if variant.Length == 0:
Logln("  " + k + ": <empty>")
                            else:
Logln("  " + k + ": " + variant)
++k
++j
++i
    var IDS: String[] = @["Fieruwer", "Seoridf-Sweorie", "Oewoir-Oweri/Vsie"]
    var FULL_IDS: String[] = @["Any-Fieruwer", "Seoridf-Sweorie", "Oewoir-Oweri/Vsie"]
    var SOURCES: String[] = @[nil, "Seoridf", "Oewoir"]
      var i: int = 0
      while i < 3:
Transliterator.RegisterFactory(IDS[i], TestFact(IDS[i]))
          try:
              var t: Transliterator = Transliterator.GetInstance(IDS[i])
              if t.ID.Equals(IDS[i]):
Logln("Ok: Registration/creation succeeded for ID " + IDS[i])
              else:
Errln("FAIL: Registration of ID " + IDS[i] + " creates ID " + t.ID)
Transliterator.Unregister(IDS[i])
              try:
                  t = Transliterator.GetInstance(IDS[i])
Errln("FAIL: Unregistration failed for ID " + IDS[i] + "; still receiving ID " + t.ID)
              except ArgumentException:
Logln("Ok; Unregistered " + IDS[i])
          except ArgumentException:
Errln("FAIL: Registration/creation failed for ID " + IDS[i])
          finally:
Transliterator.Unregister(IDS[i])
++i
    for id in Transliterator.GetAvailableIDs:
          var i: int = 0
          while i < 3:
              if id.Equals(FULL_IDS[i]):
Errln("FAIL: unregister(" + id + ") failed")
++i
    for t in Transliterator.GetAvailableTargets("Any"):
        if t.Equals(IDS[0]):
Errln("FAIL: unregister(Any-" + t + ") failed")
    for s in Transliterator.GetAvailableSources:
          var i: int = 0
          while i < 3:
              if SOURCES[i] == nil:
                continue
              if s.Equals(SOURCES[i]):
Errln("FAIL: unregister(" + s + "-*) failed")
++i
proc TestCompoundInverse*() =
    var t: Transliterator = Transliterator.GetInstance("Greek-Latin; Title()", Transliterator.Reverse)
    if t == nil:
Errln("FAIL: createInstance")
        return
    var exp: String = "(Title);Latin-Greek"
    if t.ID.Equals(exp):
Logln("Ok: inverse of "Greek-Latin; Title()" is "" + t.ID)
    else:
Errln("FAIL: inverse of "Greek-Latin; Title()" is "" + t.ID + "", expected "" + exp + """)
proc TestNFDChainRBT*() =
    var t: Transliterator = Transliterator.CreateFromRules("TEST", "::NFD; aa > Q; a > q;", Transliterator.Forward)
Logln(t.ToRules(true))
Expect(t, "aa", "Q")
proc TestNullInverse*() =
    var t: Transliterator = Transliterator.GetInstance("Null")
    var u: Transliterator = t.GetInverse
    if !u.ID.Equals("Null"):
Errln("FAIL: Inverse of Null should be Null")
proc TestAliasInverseID*() =
    var ID: String = "Latin-Hangul"
    var t: Transliterator = Transliterator.GetInstance(ID)
    var u: Transliterator = t.GetInverse
    var exp: String = "Hangul-Latin"
    var got: String = u.ID
    if !got.Equals(exp):
Errln("FAIL: Inverse of " + ID + " is " + got + ", expected " + exp)
proc TestCompoundInverseID*() =
    var ID: String = "Latin-Jamo;NFC(NFD)"
    var t: Transliterator = Transliterator.GetInstance(ID)
    var u: Transliterator = t.GetInverse
    var exp: String = "NFD(NFC);Jamo-Latin"
    var got: String = u.ID
    if !got.Equals(exp):
Errln("FAIL: Inverse of " + ID + " is " + got + ", expected " + exp)
proc TestUndefinedVariable*() =
    var rule: String = "$initial } a <> ᅡ;"
    try:
Transliterator.CreateFromRules("<ID>", rule, Transliterator.Forward)
    except ArgumentException:
Logln("OK: Got exception for " + rule + ", as expected: " + e.ToString)
        return
Errln("Fail: bogus rule " + rule + " compiled without error")
proc TestEmptyContext*() =
Expect(" { a } > b;", "xay a ", "xby b ")
proc TestCompoundFilterID*() =
    var DATA: String[] = @["[abc]; [abc]", nil, nil, nil, "Latin-Greek; [abc];", nil, nil, nil, "[b]; Latin-Greek; Upper; ([xyz])", "F", "abc", "aΒc", "[b]; (Lower); Latin-Greek; Upper(); ([Β])", "R", "ΑΒΓ", "ΑbΓ", "#
::[b]; ::Latin-Greek; ::Upper; ::([xyz]);", "F", "abc", "aΒc", "#
::[b]; ::(Lower); ::Latin-Greek; ::Upper(); ::([Β]);", "R", "ΑΒΓ", "ΑbΓ"]
      var i: int = 0
      while i < DATA.Length:
          var id: String = DATA[i]
          var direction: TransliterationDirection =           if DATA[i + 1] != nil && DATA[i + 1][0] == 'R':
Transliterator.Reverse
          else:
Transliterator.Forward
          var source: String = DATA[i + 2]
          var exp: String = DATA[i + 3]
          var expOk: bool = DATA[i + 1] != nil
          var t: Transliterator = nil
          var e: ArgumentException = nil
          try:
              if id[0] == '#':
                  t = Transliterator.CreateFromRules("ID", id, direction)
              else:
                  t = Transliterator.GetInstance(id, direction)
          except ArgumentException:
              e = ee
          var ok: bool = t != nil && e == nil
          if ok == expOk:
Logln("Ok: " + id + " => " + t +               if e != nil:
", " + e.ToString
              else:
"")
              if source != nil:
Expect(t, source, exp)
          else:
Errln("FAIL: " + id + " => " + t +               if e != nil:
", " + e.ToString
              else:
"")
          i = 4
proc TestPropertySet*() =
Expect("a>A; \p{Lu}>x; \p{Any}>y;", "abcDEF", "Ayyxxx")
Expect("(.+)>'[' $1 ']';", " a stitch 
 in time  saves 9", "[ a stitch ]
[ in time ][ saves 9]")
proc TestNewEngine*() =
    var t: Transliterator = Transliterator.GetInstance("Latin-Hiragana")
Expect(t, "aあア", "ああア")
    if true:
        var a: Transliterator = Transliterator.CreateFromRules("a_to_A", "a > A;", Transliterator.Forward)
        var A: Transliterator = Transliterator.CreateFromRules("A_to_b", "A > b;", Transliterator.Forward)
        try:
Transliterator.RegisterInstance(a)
Transliterator.RegisterInstance(A)
            t = Transliterator.GetInstance("[:Ll:];a_to_A;NFD;A_to_b")
Expect(t, "aAaA", "bAbA")
            var u: Transliterator[] = t.GetElements
assertTrue("getElements().Length", u.Length == 3)
assertEquals("getElements()[0]", u[0].ID, "a_to_A")
assertEquals("getElements()[1]", u[1].ID, "NFD")
assertEquals("getElements()[2]", u[2].ID, "A_to_b")
            t = Transliterator.GetInstance("a_to_A;NFD;A_to_b")
            t.Filter = UnicodeSet("[:Ll:]")
Expect(t, "aAaA", "bAbA")
        finally:
Transliterator.Unregister("a_to_A")
Transliterator.Unregister("A_to_b")
Expect("$smooth = x; $macron = q; [:^L:] { ([aeiouyAEIOUY] $macron?) } [^aeiouyAEIOUY$smooth$macron] > | $1 $smooth ;", "a", "ax")
    var gr: String = "$ddot = ̈ ;" + "$lcgvowel = [αεηιουω] ;" + "$rough = ̔ ;" + "($lcgvowel+ $ddot?) $rough > h | $1 ;" + "α <> a ;" + "$rough <> h ;"
Expect(gr, "ἁ", "ha")
proc TestQuantifiedSegment*() =
Expect("([abc]+) > x $1 x;", "cba", "xcbax")
Expect("([abc])+ > x $1 x;", "cba", "xax")
Expect("([abc])+ { q > x $1 x;", "cbaq", "cbaxax")
Expect("{q} ([a-d])+ > '(' $1 ')';", "ddqcba", "dd(a)cba")
    var r: String = "([a-c]){q} > x $1 x;"
    var t: Transliterator = Transliterator.CreateFromRules("ID", r, Transliterator.Forward)
    var rr: String = t.ToRules(true)
    if !r.Equals(rr):
Errln("FAIL: "" + r + "" x toRules() => "" + rr + """)
    else:
Logln("Ok: "" + r + "" x toRules() => "" + rr + """)
    r = "([a-c])+{q} > x $1 x;"
    t = Transliterator.CreateFromRules("ID", r, Transliterator.Forward)
    rr = t.ToRules(true)
    if !r.Equals(rr):
Errln("FAIL: "" + r + "" x toRules() => "" + rr + """)
    else:
Logln("Ok: "" + r + "" x toRules() => "" + rr + """)
proc TestDevanagariLatinRT*() =
    var source: String[] = @["bhārata", "kra", "kṣa", "khra", "gra", "ṅra", "cra", "chra", "jña", "jhra", "ñra", "ṭya", "ṭhra", "ḍya", "ḍhya", "ṛhra", "ṇra", "tta", "thra", "dda", "dhra", "nna", "pra", "phra", "bra", "bhra", "mra", "ṉra", "yra", "ẏra", "vra", "śra", "ṣra", "sra", "hma", "ṭṭa", "ṭṭha", "ṭhṭha", "ḍḍa", "ḍḍha", "ṭya", "ṭhya", "ḍya", "ḍhya", "hya", "śr̥", "śca", "ĕ", "san̄jīb sēnagupta", "ānand vaddirāju"]
    var expected: String[] = @["भारत", "क्र", "क्ष", "ख्र", "ग्र", "ङ्र", "च्र", "छ्र", "ज्ञ", "झ्र", "ञ्र", "ट्य", "ठ्र", "ड्य", "ढ्य", "ढ़्र", "ण्र", "त्त", "थ्र", "द्द", "ध्र", "न्न", "प्र", "फ्र", "ब्र", "भ्र", "म्र", "ऩ्र", "य्र", "य़्र", "व्र", "श्र", "ष्र", "स्र", "ह्म", "ट्ट", "ट्ठ", "ठ्ठ", "ड्ड", "ड्ढ", "ट्य", "ठ्य", "ड्य", "ढ्य", "ह्य", "शृ", "श्च", "ऍ", "संजीब् सेनगुप्त", "आनंद् वद्दिराजु"]
    var latinToDev: Transliterator = Transliterator.GetInstance("Latin-Devanagari", Transliterator.Forward)
    var devToLatin: Transliterator = Transliterator.GetInstance("Devanagari-Latin", Transliterator.Forward)
      var i: int = 0
      while i < source.Length:
Expect(latinToDev, source[i], expected[i])
Expect(devToLatin, expected[i], source[i])
++i
proc TestTeluguLatinRT*() =
    var source: String[] = @["raghurām viśvanādha", "ānand vaddirāju", "rājīv kaśarabāda", "san̄jīv kaśarabāda", "san̄jīb sen'gupta", "amarēndra hanumānula", "ravi kumār viśvanādha", "āditya kandrēgula", "śrīdhar kaṇṭamaśeṭṭi", "mādhav deśeṭṭi"]
    var expected: String[] = @["రఘురామ్ విశ్వనాధ", "ఆనంద్ వద్దిరాజు", "రాజీవ్ కశరబాద", "సంజీవ్ కశరబాద", "సంజీబ్ సెన్గుప్త", "అమరేంద్ర హనుమానుల", "రవి కుమార్ విశ్వనాధ", "ఆదిత్య కంద్రేగుల", "శ్రీధర్ కంటమశెట్టి", "మాధవ్ దెశెట్టి"]
    var latinToDev: Transliterator = Transliterator.GetInstance("Latin-Telugu", Transliterator.Forward)
    var devToLatin: Transliterator = Transliterator.GetInstance("Telugu-Latin", Transliterator.Forward)
      var i: int = 0
      while i < source.Length:
Expect(latinToDev, source[i], expected[i])
Expect(devToLatin, expected[i], source[i])
++i
proc TestSanskritLatinRT*() =
    var MAX_LEN: int = 15
    var source: String[] = @["rmkṣēt", "śrīmad", "bhagavadgītā", "adhyāya", "arjuna", "viṣāda", "yōga", "dhr̥tarāṣṭra", "uvācr̥", "dharmakṣētrē", "kurukṣētrē", "samavētā", "yuyutsavaḥ", "māmakāḥ", "kimakurvata", "san̄java"]
    var expected: String[] = @["र्म्क्षेत्", "श्रीमद्", "भगवद्गीता", "अध्याय", "अर्जुन", "विषाद", "योग", "धृतराष्ट्र", "उवाचृ", "धर्मक्षेत्रे", "कुरुक्षेत्रे", "समवेता", "युयुत्सवः", "मामकाः", "किमकुर्वत", "संजव"]
    var latinToDev: Transliterator = Transliterator.GetInstance("Latin-Devanagari", Transliterator.Forward)
    var devToLatin: Transliterator = Transliterator.GetInstance("Devanagari-Latin", Transliterator.Forward)
      var i: int = 0
      while i < MAX_LEN:
Expect(latinToDev, source[i], expected[i])
Expect(devToLatin, expected[i], source[i])
++i
proc TestCompoundLatinRT*() =
    var MAX_LEN: int = 15
    var source: String[] = @["rmkṣēt", "śrīmad", "bhagavadgītā", "adhyāya", "arjuna", "viṣāda", "yōga", "dhr̥tarāṣṭra", "uvācr̥", "dharmakṣētrē", "kurukṣētrē", "samavētā", "yuyutsavaḥ", "māmakāḥ", "kimakurvata", "san̄java"]
    var expected: String[] = @["र्म्क्षेत्", "श्रीमद्", "भगवद्गीता", "अध्याय", "अर्जुन", "विषाद", "योग", "धृतराष्ट्र", "उवाचृ", "धर्मक्षेत्रे", "कुरुक्षेत्रे", "समवेता", "युयुत्सवः", "मामकाः", "किमकुर्वत", "संजव"]
    var latinToDevToLatin: Transliterator = Transliterator.GetInstance("Latin-Devanagari;Devanagari-Latin", Transliterator.Forward)
    var devToLatinToDev: Transliterator = Transliterator.GetInstance("Devanagari-Latin;Latin-Devanagari", Transliterator.Forward)
      var i: int = 0
      while i < MAX_LEN:
Expect(latinToDevToLatin, source[i], source[i])
Expect(devToLatinToDev, expected[i], expected[i])
++i
proc TestGurmukhiDevanagari*() =
    var vowel: UnicodeSet = UnicodeSet("[अ-ऊ एऐओऔ ा-ूेैोौ्]")
    var non_vowel: UnicodeSet = UnicodeSet("[क-नप-र]")
    var vIter: UnicodeSetIterator = UnicodeSetIterator(vowel)
    var nvIter: UnicodeSetIterator = UnicodeSetIterator(non_vowel)
    var trans: Transliterator = Transliterator.GetInstance("Devanagari-Gurmukhi")
    var src: StringBuffer = StringBuffer(" ं")
    var expect: StringBuffer = StringBuffer(" ਂ")
    while vIter.Next:
        src[0] = cast[char](vIter.Codepoint)
        expect[0] = cast[char](vIter.Codepoint + 256)
Expect(trans, src.ToString, expect.ToString)
    expect[1] = '�'
    while nvIter.Next:
        src[0] = cast[char](nvIter.Codepoint)
        expect[0] = cast[char](nvIter.Codepoint + 256)
Expect(trans, src.ToString, expect.ToString)
proc TestLocaleInstantiation*() =
    var t: Transliterator
    try:
        t = Transliterator.GetInstance("te_IN-Latin")
    except ArgumentException:
Warnln("Could not load locale data for obtaining the script used in the locale te_IN. " + ex.ToString)
    try:
        t = Transliterator.GetInstance("ru_RU-Latin")
Expect(t, "а", "a")
    except ArgumentException:
Warnln("Could not load locale data for obtaining the script used in the locale ru_RU. " + ex.ToString)
    try:
        t = Transliterator.GetInstance("en-el")
Expect(t, "a", "α")
    except ArgumentException:
Warnln("Could not load locale data for obtaining the script used in the locale el. " + ex.ToString)
proc TestTitleAccents*() =
    var t: Transliterator = Transliterator.GetInstance("Title")
Expect(t, "àb can't abe", "Àb Can't Abe")
proc TestLocaleResource*() =
    var DATA: String[] = @["Latin-Greek/UNGEGN", "b", "μπ", "Latin-el", "b", "μπ", "Latin-Greek", "b", "β", "Greek-Latin/UNGEGN", "β", "v", "el-Latin", "β", "v", "Greek-Latin", "β", "b"]
      var i: int = 0
      while i < DATA.Length:
          var t: Transliterator = Transliterator.GetInstance(DATA[i])
Expect(t, DATA[i + 1], DATA[i + 2])
          i = 3
proc TestParseError*() =
    var rule: String = "a > b;
" + "# more stuff
" + "d << b;"
    try:
        var t: Transliterator = Transliterator.CreateFromRules("ID", rule, Transliterator.Forward)
        if t != nil:
Errln("FAIL: Did not get expected exception")
    except ArgumentException:
        var err: String = e.Message
        if err.IndexOf("d << b", StringComparison.Ordinal) >= 0:
Logln("Ok: " + err)
        else:
Errln("FAIL: " + err)
        return
Errln("FAIL: no syntax error")
proc TestOutputSet*() =
    var rule: String = "$set = [a-cm-n]; b > $set;"
    var t: Transliterator = nil
    try:
        t = Transliterator.CreateFromRules("ID", rule, Transliterator.Forward)
        if t != nil:
Errln("FAIL: Did not get the expected exception")
    except ArgumentException:
Logln("Ok: " + e.ToString)
        return
Errln("FAIL: No syntax error")
proc TestVariableRange*() =
    var rule: String = "use variable range 0x70 0x72; a > A; b > B; q > Q;"
    try:
        var t: Transliterator = Transliterator.CreateFromRules("ID", rule, Transliterator.Forward)
        if t != nil:
Errln("FAIL: Did not get the expected exception")
    except ArgumentException:
Logln("Ok: " + e.ToString)
        return
Errln("FAIL: No syntax error")
proc TestInvalidPostContext*() =
    try:
        var t: Transliterator = Transliterator.CreateFromRules("ID", "a}b{c>d;", Transliterator.Forward)
        if t != nil:
Errln("FAIL: Did not get the expected exception")
    except ArgumentException:
        var msg: String = e.ToString
        if msg.IndexOf("a}b{c", StringComparison.Ordinal) >= 0:
Logln("Ok: " + msg)
        else:
Errln("FAIL: " + msg)
        return
Errln("FAIL: No syntax error")
proc TestIDForms*() =
    var DATA: String[] = @["NFC", nil, "NFD", "nfd", nil, "NFC", "Any-NFKD", nil, "Any-NFKC", "Null", nil, "Null", "-nfkc", "nfkc", "NFKD", "-nfkc/", "nfkc", "NFKD", "Latin-Greek/UNGEGN", nil, "Greek-Latin/UNGEGN", "Greek/UNGEGN-Latin", "Greek-Latin/UNGEGN", "Latin-Greek/UNGEGN", "Bengali-Devanagari/", "Bengali-Devanagari", "Devanagari-Bengali", "Source-", nil, nil, "Source/Variant-", nil, nil, "Source-/Variant", nil, nil, "/Variant", nil, nil, "/Variant-", nil, nil, "-/Variant", nil, nil, "-/", nil, nil, "-", nil, nil, "/", nil, nil]
      var i: int = 0
      while i < DATA.Length:
          var ID: String = DATA[i]
          var expID: String = DATA[i + 1]
          var expInvID: String = DATA[i + 2]
          var expValid: bool = expInvID != nil
          if expID == nil:
              expID = ID
          try:
              var t: Transliterator = Transliterator.GetInstance(ID)
              var u: Transliterator = t.GetInverse
              if t.ID.Equals(expID) && u.ID.Equals(expInvID):
Logln("Ok: " + ID + ".GetInverse() => " + expInvID)
              else:
Errln("FAIL: getInstance(" + ID + ") => " + t.ID + " x getInverse() => " + u.ID + ", expected " + expInvID)
          except ArgumentException:
              if !expValid:
Logln("Ok: getInstance(" + ID + ") => " + e.ToString)
              else:
Errln("FAIL: getInstance(" + ID + ") => " + e.ToString)
          i = 3
proc checkRules(label: String, t2: Transliterator, testRulesForward: String) =
    var rules2: String = t2.ToRules(true)
    rules2 = TestUtility.Replace(rules2, " ", "")
    rules2 = TestUtility.Replace(rules2, "
", "")
    rules2 = TestUtility.Replace(rules2, "", "")
    testRulesForward = TestUtility.Replace(testRulesForward, " ", "")
    if !rules2.Equals(testRulesForward):
Errln(label)
Logln("GENERATED RULES: " + rules2)
Logln("SHOULD BE:       " + testRulesForward)
proc TestToRulesMark*() =
    var testRules: String = "::[[:Latin:][:Mark:]];" + "::NFKD (NFC);" + "::Lower (Lower);" + "a <> \u03B1;" + "::NFKC (NFD);" + "::Upper (Lower);" + "::Lower ();" + "::([[:Greek:][:Mark:]]);"
    var testRulesForward: String = "::[[:Latin:][:Mark:]];" + "::NFKD(NFC);" + "::Lower(Lower);" + "a > \u03B1;" + "::NFKC(NFD);" + "::Upper (Lower);" + "::Lower ();"
    var testRulesBackward: String = "::[[:Greek:][:Mark:]];" + "::Lower (Upper);" + "::NFD(NFKC);" + "\u03B1 > a;" + "::Lower(Lower);" + "::NFC(NFKD);"
    var source: String = "á"
    var target: String = "ά"
    var t2: Transliterator = Transliterator.CreateFromRules("source-target", testRules, Transliterator.Forward)
    var t3: Transliterator = Transliterator.CreateFromRules("target-source", testRules, Transliterator.Reverse)
Expect(t2, source, target)
Expect(t3, target, source)
checkRules("Failed toRules FORWARD", t2, testRulesForward)
checkRules("Failed toRules BACKWARD", t3, testRulesBackward)
proc TestEscape*() =
Expect(Transliterator.GetInstance("Hex-Any"), "\x{40}\U00000031&#x32;&#81;", "@12Q")
Expect(Transliterator.GetInstance("Any-Hex/C"), CharsToUnicodeString("A\U0010BEEF\uFEED"), "\u0041\U0010BEEF\uFEED")
Expect(Transliterator.GetInstance("Any-Hex/DotNet"), CharsToUnicodeString("A\U0010BEEF\uFEED"), "\u0041\uDBEF\uDEEF\uFEED")
Expect(Transliterator.GetInstance("Any-Hex/Perl"), CharsToUnicodeString("A\U0010BEEF\uFEED"), "\x{41}\x{10BEEF}\x{FEED}")
proc TestDisplayName*() =
    var DATA: String[] = @["Any-Hex", "Any to Hex Escape", "Hex Escape to Any", "Any-Hex/Perl", "Any to Hex Escape/Perl", "Hex Escape to Any/Perl", "NFC", "Any to NFC", "Any to NFD"]
    var US: CultureInfo = CultureInfo("en-US")
      var i: int = 0
      while i < DATA.Length:
          var name: String = Transliterator.GetDisplayName(DATA[i], US)
          if !name.Equals(DATA[i + 1]):
Errln("FAIL: " + DATA[i] + ".getDisplayName() => " + name + ", expected " + DATA[i + 1])
          else:
Logln("Ok: " + DATA[i] + ".getDisplayName() => " + name)
          var t: Transliterator = Transliterator.GetInstance(DATA[i], Transliterator.Reverse)
          name = Transliterator.GetDisplayName(t.ID, US)
          if !name.Equals(DATA[i + 2]):
Errln("FAIL: " + t.ID + ".getDisplayName() => " + name + ", expected " + DATA[i + 2])
          else:
Logln("Ok: " + t.ID + ".getDisplayName() => " + name)
            let resource = ThreadCultureChange("en_US", "en_US")
<unhandled: nnkDefer>
            var name2: String = Transliterator.GetDisplayName(t.ID)
            if !name.Equals(name2):
Errln("FAIL: getDisplayName with default locale failed")
          i = 3
proc TestAnchorMasking*() =
    var rule: String = "^a > Q; a > q;"
    try:
        var t: Transliterator = Transliterator.CreateFromRules("ID", rule, Transliterator.Forward)
        if t == nil:
Errln("FAIL: Did not get the expected exception")
    except ArgumentException:
Errln("FAIL: " + rule + " => " + e)
proc TestScriptAllCodepoints*() =
    var code: int
    var scriptIdsChecked: HashSet<string> = HashSet<string>
    var scriptAbbrsChecked: HashSet<string> = HashSet<string>
      var i: int = 0
      while i <= 1114111:
          code = UScript.GetScript(i)
          if code == UScript.InvalidCode:
Errln("UScript.getScript for codepoint 0x" + Hex(i) + " failed")
          var id: String = UScript.GetName(code)
          var abbr: String = UScript.GetShortName(code)
          if !scriptIdsChecked.Contains(id):
scriptIdsChecked.Add(id)
              var newId: String = "[:" + id + ":];NFD"
              try:
                  var t: Transliterator = Transliterator.GetInstance(newId)
                  if t == nil:
Errln("Failed to create transliterator for " + Hex(i) + " script code: " + id)
              except Exception:
Errln("Failed to create transliterator for " + Hex(i) + " script code: " + id + " Exception: " + e.ToString)
          if !scriptAbbrsChecked.Contains(abbr):
scriptAbbrsChecked.Add(abbr)
              var newAbbrId: String = "[:" + abbr + ":];NFD"
              try:
                  var t: Transliterator = Transliterator.GetInstance(newAbbrId)
                  if t == nil:
Errln("Failed to create transliterator for " + Hex(i) + " script code: " + abbr)
              except Exception:
Errln("Failed to create transliterator for " + Hex(i) + " script code: " + abbr + " Exception: " + e.ToString)
++i
proc TestScriptAllCodepointsUsingTry*() =
    var code: int
    var scriptIdsChecked: HashSet<string> = HashSet<string>
    var scriptAbbrsChecked: HashSet<string> = HashSet<string>
      var i: int = 0
      while i <= 1114111:
          code = UScript.GetScript(i)
          if code == UScript.InvalidCode:
Errln("UScript.getScript for codepoint 0x" + Hex(i) + " failed")
          if !UScript.TryGetName(code,           var idSpan: ReadOnlySpan<char>):
Errln("UScript.TryGetName for codepoint 0x" + Hex(i) + " failed")
          var id: string = idSpan.ToString
          if !UScript.TryGetShortName(code,           var abbrSpan: ReadOnlySpan<char>):
Errln("UScript.TryGetShortName for codepoint 0x" + Hex(i) + " failed")
          var abbr: string = abbrSpan.ToString
          if !scriptIdsChecked.Contains(id):
scriptIdsChecked.Add(id)
              var newId: string = "[:" + id + ":];NFD"
              try:
                  var t: Transliterator = Transliterator.GetInstance(newId)
                  if t == nil:
Errln("Failed to create transliterator for " + Hex(i) + " script code: " + id)
              except Exception:
Errln("Failed to create transliterator for " + Hex(i) + " script code: " + id + " Exception: " + e.ToString)
          if !scriptAbbrsChecked.Contains(abbr):
scriptAbbrsChecked.Add(abbr)
              var newAbbrId: String = "[:" + abbr + ":];NFD"
              try:
                  var t: Transliterator = Transliterator.GetInstance(newAbbrId)
                  if t == nil:
Errln("Failed to create transliterator for " + Hex(i) + " script code: " + abbr)
              except Exception:
Errln("Failed to create transliterator for " + Hex(i) + " script code: " + abbr + " Exception: " + e.ToString)
++i
proc TestSpecialCases*() =
      var i: int = 0
      while i < registerRules.Length:
          var t: Transliterator = Transliterator.CreateFromRules(registerRules[i][0], registerRules[i][1], Transliterator.Forward)
DummyFactory.Add(registerRules[i][0], t)
++i
      var i: int = 0
      while i < testCases.Length:
          var name: String = testCases[i][0]
          var t: Transliterator = Transliterator.GetInstance(name)
          var id: String = t.ID
          var source: String = testCases[i][1]
          var target: String = nil
          if testCases[i].Length > 2:
            target = testCases[i][2]

          elif id.Equals("NFD", StringComparison.OrdinalIgnoreCase):
            target = Normalizer.Normalize(source, NormalizerMode.NFD)
          else:
            if id.Equals("NFC", StringComparison.OrdinalIgnoreCase):
              target = Normalizer.Normalize(source, NormalizerMode.NFC)

            elif id.Equals("NFKD", StringComparison.OrdinalIgnoreCase):
              target = Normalizer.Normalize(source, NormalizerMode.NFKD)
            else:
              if id.Equals("NFKC", StringComparison.OrdinalIgnoreCase):
                target = Normalizer.Normalize(source, NormalizerMode.NFKC)

              elif id.Equals("Lower", StringComparison.OrdinalIgnoreCase):
                target = UChar.ToLower(CultureInfo("en-US"), source)
              else:
                if id.Equals("Upper", StringComparison.OrdinalIgnoreCase):
                  target = UChar.ToUpper(CultureInfo("en-US"), source)
Expect(t, source, target)
++i
      var i: int = 0
      while i < registerRules.Length:
Transliterator.Unregister(registerRules[i][0])
++i
type
  DummyFactory = ref object
    singleton: DummyFactory = DummyFactory
    m: IDictionary[string, Transliterator] = Dictionary<string, Transliterator>

proc Add(ID: String, t: Transliterator) =
    m[ID] = t
Transliterator.RegisterFactory(ID, singleton)
proc GetInstance*(ID: String): Transliterator =
    return cast[Transliterator](m.Get(ID))
proc TestCasing*() =
    var toLower: Transliterator = Transliterator.GetInstance("lower")
    var toCasefold: Transliterator = Transliterator.GetInstance("casefold")
    var toUpper: Transliterator = Transliterator.GetInstance("upper")
    var toTitle: Transliterator = Transliterator.GetInstance("title")
      var i: int = 0
      while i < 1536:
          var s: String = UTF16.ValueOf(i)
          var lower: String = UChar.ToLower(UCultureInfo.InvariantCulture, s)
assertEquals("Lowercase", lower, toLower.Transform(s))
          var casefold: String = UChar.FoldCase(s, true)
assertEquals("Casefold", casefold, toCasefold.Transform(s))
          if i != 837:
              var title: String = UChar.ToTitleCase(UCultureInfo.InvariantCulture, s, nil)
assertEquals("Title", title, toTitle.Transform(s))
          var upper: String = UChar.ToUpper(UCultureInfo.InvariantCulture, s)
assertEquals("Upper", upper, toUpper.Transform(s))
++i
proc TestSurrogateCasing*() =
    var dee: int = UTF16.CharAt(DESERET_dee, 0)
    var DEE: int = UChar.ToTitleCase(dee)
    if !UTF16.ValueOf(DEE).Equals(DESERET_DEE):
Errln("Fails titlecase of surrogates" + Convert.ToString(dee, 16) + ", " + Convert.ToString(DEE, 16))
    if !UChar.ToUpper(DESERET_dee + DESERET_DEE).Equals(DESERET_DEE + DESERET_DEE):
Errln("Fails uppercase of surrogates")
    if !UChar.ToLower(DESERET_dee + DESERET_DEE).Equals(DESERET_dee + DESERET_dee):
Errln("Fails lowercase of surrogates")
proc TestFunction*() =
    var rule: String = "([:Lu:]) > $1 '(' &Lower( $1 ) '=' &Hex( &Any-Lower( $1 ) ) ')';"
    var t: Transliterator = Transliterator.CreateFromRules("Test", rule, Transliterator.Forward)
    if t == nil:
Errln("FAIL: createFromRules failed")
        return
    var r: String = t.ToRules(true)
    if r.Equals(rule):
Logln("OK: toRules() => " + r)
    else:
Errln("FAIL: toRules() => " + r + ", expected " + rule)
Expect(t, "The Quick Brown Fox", "T(t=\u0074)he Q(q=\u0071)uick B(b=\u0062)rown F(f=\u0066)ox")
    rule = "([^\ -\u007F]) > &Hex/Unicode( $1 ) ' ' &Name( $1 ) ;"
    t = Transliterator.CreateFromRules("Test", rule, Transliterator.Forward)
    if t == nil:
Errln("FAIL: createFromRules failed")
        return
    r = t.ToRules(true)
    if r.Equals(rule):
Logln("OK: toRules() => " + r)
    else:
Errln("FAIL: toRules() => " + r + ", expected " + rule)
Expect(t, "́", "U+0301 \N{COMBINING ACUTE ACCENT}")
proc TestInvalidBackRef*() =
    var rule: String = ". > $1;"
    var rule2: String = "(.) <> &hex/unicode($1) &name($1); . > $1; [{}] > ;"
    try:
        var t: Transliterator = Transliterator.CreateFromRules("Test", rule, Transliterator.Forward)
        if t != nil:
Errln("FAIL: createFromRules should have returned NULL")
Errln("FAIL: Ok: . > $1; => no error")
        var t2: Transliterator = Transliterator.CreateFromRules("Test2", rule2, Transliterator.Forward)
        if t2 != nil:
Errln("FAIL: createFromRules should have returned NULL")
Errln("FAIL: Ok: . > $1; => no error")
    except ArgumentException:
Logln("Ok: . > $1; => " + e.ToString)
proc TestMulticharStringSet*() =
    var rule: String = "       [{aa}]       > x;" + "         a          > y;" + "       [b{bc}]      > z;" + "[{gd}] { e          > q;" + "         e } [{fg}] > r;"
    var t: Transliterator = Transliterator.CreateFromRules("Test", rule, Transliterator.Forward)
    if t == nil:
Errln("FAIL: createFromRules failed")
        return
Expect(t, "a aa ab bc d gd de gde gdefg ddefg", "y x yz z d gd de gdq gdqfg ddrfg")
    rule = "    [a {ab} {abc}]    > x;" + "           b          > y;" + "           c          > z;" + " q [t {st} {rst}] { e > p;"
    t = Transliterator.CreateFromRules("Test", rule, Transliterator.Forward)
    if t == nil:
Errln("FAIL: createFromRules failed")
        return
Expect(t, "a ab abc qte qste qrste", "x x x qtp qstp qrstp")
proc TestUserFunction*() =
    var t: Transliterator
TestUserFunctionFactory.Add("Any-gif", Transliterator.CreateFromRules("gif", "'\'u(..)(..) > '<img src="http://www.unicode.org/gifs/24/' $1 '/U' $1$2 '.gif">';", Transliterator.Forward))
TestUserFunctionFactory.Add("Any-RemoveCurly", Transliterator.CreateFromRules("RemoveCurly", "[\{\}] > ; \\N > ;", Transliterator.Forward))
Logln("Trying &hex")
    t = Transliterator.CreateFromRules("hex2", "(.) > &hex($1);", Transliterator.Forward)
Logln("Registering")
TestUserFunctionFactory.Add("Any-hex2", t)
    t = Transliterator.GetInstance("Any-hex2")
Expect(t, "abc", "\u0061\u0062\u0063")
Logln("Trying &gif")
    t = Transliterator.CreateFromRules("gif2", "(.) > &Gif(&Hex2($1));", Transliterator.Forward)
Logln("Registering")
TestUserFunctionFactory.Add("Any-gif2", t)
    t = Transliterator.GetInstance("Any-gif2")
Expect(t, "ab", "<img src="http://www.unicode.org/gifs/24/00/U0061.gif">" + "<img src="http://www.unicode.org/gifs/24/00/U0062.gif">")
    t = Transliterator.CreateFromRules("test", "(.) > &Hex($1) ' ' &Any-RemoveCurly(&Name($1)) ' ';", Transliterator.Forward)
Expect(t, "abc", "\u0061 LATIN SMALL LETTER A \u0062 LATIN SMALL LETTER B \u0063 LATIN SMALL LETTER C ")
TestUserFunctionFactory.Unregister
type
  TestUserFunctionFactory = ref object
    singleton: TestUserFunctionFactory = TestUserFunctionFactory
    m: IDictionary[CaseInsensitiveString, Transliterator] = Dictionary<CaseInsensitiveString, Transliterator>

proc Add(ID: String, t: Transliterator) =
    m[CaseInsensitiveString(ID)] = t
Transliterator.RegisterFactory(ID, singleton)
proc GetInstance*(ID: String): Transliterator =
    return cast[Transliterator](m.Get(CaseInsensitiveString(ID)))
proc Unregister() =
    var toRemove = List<CaseInsensitiveString>
      let ids = m.Keys.GetEnumerator
<unhandled: nnkDefer>
      while ids.MoveNext:
          var id: CaseInsensitiveString = cast[CaseInsensitiveString](ids.Current)
Transliterator.Unregister(id.String)
toRemove.Add(id)
    for item in toRemove:
m.Remove(item)
proc TestAnyX*() =
    var anyLatin: Transliterator = Transliterator.GetInstance("Any-Latin", Transliterator.Forward)
Expect(anyLatin, "greek:αβκΑΒΚ hiragana:あぶく cyrillic:абц", "greek:abkABK hiragana:abuku cyrillic:abc")
proc TestAny*() =
    var alphabetic: UnicodeSet = UnicodeSet("[:alphabetic:]").Freeze
    var testString: StringBuffer = StringBuffer
      var i: int = 0
      while i < UScript.CodeLimit:
          var sample: UnicodeSet = UnicodeSet.ApplyPropertyAlias("script", UScript.GetShortName(i)).RetainAll(alphabetic)
          var count: int = 5
            var it: UnicodeSetIterator = UnicodeSetIterator(sample)
            while it.Next:
testString.Append(it.GetString)
                if --count < 0:
                  break
++i
Logln("Sample set for Any-Latin: " + testString)
    var anyLatin: Transliterator = Transliterator.GetInstance("any-Latn")
    var result: String = anyLatin.Transliterate(testString.ToString)
Logln("Sample result for Any-Latin: " + result)
proc TestSourceTargetSet*() =
    var r: String = "a > b; " + "r [x{lu}] > q;"
    var expSrc: UnicodeSet = UnicodeSet("[arx{lu}]")
    var expTrg: UnicodeSet = UnicodeSet("[bq]")
    var t: Transliterator = Transliterator.CreateFromRules("test", r, Transliterator.Forward)
    var src: UnicodeSet = t.GetSourceSet
    var trg: UnicodeSet = t.GetTargetSet
    if src.Equals(expSrc) && trg.Equals(expTrg):
Logln("Ok: " + r + " => source = " + src.ToPattern(true) + ", target = " + trg.ToPattern(true))
    else:
Errln("FAIL: " + r + " => source = " + src.ToPattern(true) + ", expected " + expSrc.ToPattern(true) + "; target = " + trg.ToPattern(true) + ", expected " + expTrg.ToPattern(true))
proc TestSourceTargetSet2*() =
    var nfc: Normalizer2 = Normalizer2.NFCInstance
    var nfd: Normalizer2 = Normalizer2.NFDInstance
    var leadToTrail: UnicodeMap<UnicodeSet> = UnicodeMap<UnicodeSet>
    var leadToSources: UnicodeMap<UnicodeSet> = UnicodeMap<UnicodeSet>
    var nonStarters: UnicodeSet = UnicodeSet("[:^ccc=0:]").Freeze
    var can: CanonicalEnumerator = CanonicalEnumerator("")
    var disorderedMarks: UnicodeSet = UnicodeSet
      var i: int = 0
      while i <= 1114111:
          var s: String = nfd.GetDecomposition(i)
          if s == nil:
              continue
can.SetSource(s)
          while can.MoveNext:
disorderedMarks.Add(can.Current)
          var first: int = s.CodePointAt(0)
          var firstCount: int = Character.CharCount(first)
          if s.Length == firstCount:
            continue
          var trailString: String = s.Substring(firstCount)
          if !nonStarters.ContainsSome(trailString):
              continue
          var trailSet: UnicodeSet = leadToTrail.Get(first)
          if trailSet == nil:
leadToTrail.Put(first,               trailSet = UnicodeSet)
trailSet.AddAll(trailString)
          var sourcesSet: UnicodeSet = leadToSources.Get(first)
          if sourcesSet == nil:
leadToSources.Put(first,               sourcesSet = UnicodeSet)
sourcesSet.Add(i)
++i
    for x in leadToSources.EntrySet:
        var lead: String = x.Key
        var sources: UnicodeSet = x.Value
        var trailSet: UnicodeSet = leadToTrail.Get(lead)
        for source in sources:
            for trail in trailSet:
can.SetSource(source + trail)
                while can.MoveNext:
                    var t: string = can.Current
                    if t.EndsWith(trail, StringComparison.Ordinal):
                      continue
disorderedMarks.Add(t)
    for s in nonStarters:
disorderedMarks.Add("ͅ" + s)
disorderedMarks.Add(s + "̣")
        var xx: String = nfc.Normalize("Ǭ" + s)
        if !xx.StartsWith("Ǭ", StringComparison.Ordinal):
Logln("??")
Logln("Test cases: " + disorderedMarks.Count)
disorderedMarks.AddAll(0, 1114111).Freeze
Logln("isInert Ą " + nfc.IsInert('�'))
    var rules: Object[][] = @[@[":: [:sc=COMMON:] any-name;", nil], @[":: [:Greek:] hex-any/C;", nil], @[":: [:Greek:] any-hex/C;", nil], @[":: [[:Mn:][:Me:]] remove;", nil], @[":: [[:Mn:][:Me:]] null;", nil], @[":: lower;", nil], @[":: upper;", nil], @[":: title;", nil], @[":: CaseFold;", nil], @[":: NFD;", nil], @[":: NFC;", nil], @[":: NFKD;", nil], @[":: NFKC;", nil], @[":: [[:Mn:][:Me:]] NFKD;", nil], @[":: Latin-Greek;", nil], @[":: [:Latin:] NFKD;", nil], @[":: NFKD;", nil], @[":: NFKD;
" + ":: [[:Mn:][:Me:]] remove;
" + ":: NFC;", nil]]
    for rulex in rules:
        var rule: String = cast[String](rulex[0])
        var trans: Transliterator = Transliterator.CreateFromRules("temp", rule, Transliterator.Forward)
        var actualSource: UnicodeSet = trans.GetSourceSet
        var actualTarget: UnicodeSet = trans.GetTargetSet
        var empiricalSource: UnicodeSet = UnicodeSet
        var empiricalTarget: UnicodeSet = UnicodeSet
        var ruleDisplay: String = rule.Replace("
", "		")
        var toTest: UnicodeSet = disorderedMarks
        var test: String = nfd.Normalize("Ą")
        var DEBUG: bool = true
        var count: int = 0
        for s in toTest:
            if s.Equals(test):
Logln(test)
            var t: String = trans.Transform(s)
            if !s.Equals(t):
                if !isAtomic(s, t, trans):
isAtomic(s, t, trans)
                    continue
                if DEBUG:
                    if !actualSource.ContainsAll(s):
++count
                    if !actualTarget.ContainsAll(t):
++count
AddSourceTarget(s, empiricalSource, t, empiricalTarget)
        if rule.Contains("title"):
empiricalSource.Remove(837)
assertEquals("getSource(" + ruleDisplay + ")", empiricalSource, actualSource, SetAssert.MISSING_OK)
assertEquals("getTarget(" + ruleDisplay + ")", empiricalTarget, actualTarget, SetAssert.MISSING_OK)
proc TestSourceTargetSetFilter*() =
    var tests: String[][] = @[@["[] Latin-Greek", nil, "[']"], @["::[] ; ::NFD ; ::NFKC ; :: ([]) ;"], @["[] Any-Latin"], @["[] casefold"], @["[] NFKD;"], @["[] NFKC;"], @["[] hex"], @["[] lower"], @["[] null"], @["[] remove"], @["[] title"], @["[] upper"]]
    var expectedSource: UnicodeSet = UnicodeSet.Empty
    for testPair in tests:
        var test: String = testPair[0]
        var t0: Transliterator
        try:
            t0 = Transliterator.GetInstance(test)
        except Exception:
            t0 = Transliterator.CreateFromRules("temp", test, Transliterator.Forward)
        var t1: Transliterator
        try:
            t1 = t0.GetInverse
        except Exception:
            t1 = Transliterator.CreateFromRules("temp", test, Transliterator.Reverse)
        var targetIndex: int = 0
        for t in @[t0, t1]:
            var ok: bool
            var source: UnicodeSet = t.GetSourceSet
            var direction: String =             if t == t0:
"FORWARD	"
            else:
"REVERSE	"
++targetIndex
            var expectedTarget: UnicodeSet =             if testPair.Length <= targetIndex:
expectedSource
            else:
                if testPair[targetIndex] == nil:
expectedSource
                else:
                    if testPair[targetIndex].Length == 0:
expectedSource
                    else:
UnicodeSet(testPair[targetIndex])
            ok = assertEquals(direction + "getSource	"" + test + '"', expectedSource, source)
            if !ok:
                source = t.GetSourceSet
            var target: UnicodeSet = t.GetTargetSet
            ok = assertEquals(direction + "getTarget	"" + test + '"', expectedTarget, target)
            if !ok:
                target = t.GetTargetSet
proc isAtomic(s: String, t: String, trans: Transliterator): bool =
      var i: int = 1
      while i < s.Length:
          if !CharSequences.OnCharacterBoundary(s, i):
              continue
          var q: String = trans.Transform(s.Substring(0, i))
          if t.StartsWith(q, StringComparison.Ordinal):
              var r: String = trans.Transform(s.Substring(i))
              if t.Length == q.Length + r.Length && t.EndsWith(r, StringComparison.Ordinal):
                  return false
++i
    return true
proc AddSourceTarget(s: String, expectedSource: UnicodeSet, t: String, expectedTarget: UnicodeSet) =
expectedSource.AddAll(s)
    if t.Length > 0:
expectedTarget.AddAll(t)
proc TestCharUtils*() =
    var startTests: String[][] = @[@["1", "a", "ab"], @["0", "a", "xb"], @["0", "�", "𐀁"], @["1", "�a", "�b"], @["0", "𐀀", "𐀁"]]
    for row in startTests:
        var actual: int = findSharedStartLength(row[1], row[2])
assertEquals("findSharedStartLength(" + row[1] + "," + row[2] + ")", int.Parse(row[0], CultureInfo.InvariantCulture), actual)
    var endTests: String[][] = @[@["0", "�", "𐐀"], @["1", "a", "ba"], @["0", "a", "bx"], @["1", "a�", "b�"], @["0", "𐀀", "𐐀"]]
    for row in endTests:
        var actual: int = findSharedEndLength(row[1], row[2])
assertEquals("findSharedEndLength(" + row[1] + "," + row[2] + ")", int.Parse(row[0], CultureInfo.InvariantCulture), actual)
proc findSharedStartLength(s: string, t: string): int =
    var min: int = Math.Min(s.Length, t.Length)
    var i: int
      var sch: char
      var tch: char
      i = 0
      while i < min:
          sch = s[i]
          tch = t[i]
          if sch != tch:
              break
++i
    return     if CharSequences.OnCharacterBoundary(s, i) && CharSequences.OnCharacterBoundary(t, i):
i
    else:
i - 1
proc findSharedEndLength(s: string, t: string): int =
    var slength: int = s.Length
    var tlength: int = t.Length
    var min: int = Math.Min(slength, tlength)
    var i: int
      var sch: char
      var tch: char
      i = 0
      while i < min:
          sch = s[slength - i - 1]
          tch = t[tlength - i - 1]
          if sch != tch:
              break
++i
    return     if CharSequences.OnCharacterBoundary(s, slength - i) && CharSequences.OnCharacterBoundary(t, tlength - i):
i
    else:
i - 1
type
  SetAssert = enum
    EQUALS
    MISSING_OK
    EXTRA_OK

proc assertEquals(message: String, empirical: UnicodeSet, actual: UnicodeSet, setAssert: SetAssert) =
    var haveError: bool = false
    if !actual.ContainsAll(empirical):
        var missing: UnicodeSet = UnicodeSet(empirical).RemoveAll(actual)
Errln(message + " 	getXSet < empirical (" + missing.Count + "): " + toPattern(missing))
        haveError = true
    if !empirical.ContainsAll(actual):
        var extra: UnicodeSet = UnicodeSet(actual).RemoveAll(empirical)
Logln("WARNING: " + message + " 	getXSet > empirical (" + extra.Count + "): " + toPattern(extra))
        haveError = true
    if !haveError:
Logln("OK " + message + ' ' + toPattern(empirical))
proc toPattern(missing: UnicodeSet): String =
    var result: String = missing.ToPattern(false)
    if result.Length < 200:
        return result
    return result.Substring(0,     if CharSequences.OnCharacterBoundary(result, 200):
200
    else:
199) + "…"
proc TestPatternWhitespace*() =
    var r: String = "a > ‎ b;"
    var t: Transliterator = Transliterator.CreateFromRules("test", r, Transliterator.Forward)
Expect(t, "a", "b")
    var set: UnicodeSet = UnicodeSet("[a ‎]")
    if set.Contains(8206):
Errln("FAIL: U+200E not being ignored by UnicodeSet")
proc TestAlternateSyntax*() =
Expect("a → x; b ← y; c ↔ z", "abc", "xbz")
Expect("([:^ASCII:]) → ∆Name($1);", "<=←; >=→; <>=↔; &=∆", "<=\N{LEFTWARDS ARROW}; >=\N{RIGHTWARDS ARROW}; <>=\N{LEFT RIGHT ARROW}; &=\N{INCREMENT}")
proc TestPositionAPI*() =
    var a: TransliterationPosition = TransliterationPosition(3, 5, 7, 11)
    var b: TransliterationPosition = TransliterationPosition(a)
    var c: TransliterationPosition = TransliterationPosition
c.Set(a)
    if a.Equals(b) && a.Equals(c):
Logln("Ok: " + a + " == " + b + " == " + c)
    else:
Errln("FAIL: " + a + " != " + b + " != " + c)
proc TestBeginEnd*() =
      var i: int = 0
      while i < BEGIN_END_TEST_CASES.Length:
Expect(BEGIN_END_TEST_CASES[i], BEGIN_END_TEST_CASES[i + 1], BEGIN_END_TEST_CASES[i + 2])
          i = 3
    var reversed: Transliterator = Transliterator.CreateFromRules("Reversed", BEGIN_END_RULES[17], Transliterator.Reverse)
Expect(reversed, "xy XY XYZ yz YZ", "xy abc xaba yz aba")
proc TestBeginEndToRules*() =
      var i: int = 0
      while i < BEGIN_END_TEST_CASES.Length:
          var t: Transliterator = Transliterator.CreateFromRules("--", BEGIN_END_TEST_CASES[i], Transliterator.Forward)
          var rules: String = t.ToRules(false)
          var t2: Transliterator = Transliterator.CreateFromRules("Test case #" + i / 3, rules, Transliterator.Forward)
Expect(t2, BEGIN_END_TEST_CASES[i + 1], BEGIN_END_TEST_CASES[i + 2])
          i = 3
      var reversed: Transliterator = Transliterator.CreateFromRules("Reversed", BEGIN_END_RULES[17], Transliterator.Reverse)
      var rules: String = reversed.ToRules(false)
      var reversed2: Transliterator = Transliterator.CreateFromRules("Reversed", rules, Transliterator.Forward)
Expect(reversed2, "xy XY XYZ yz YZ", "xy abc xaba yz aba")
proc TestRegisterAlias*() =
    var longID: String = "Lower;[aeiou]Upper"
    var shortID: String = "Any-CapVowels"
    var reallyShortID: String = "CapVowels"
Transliterator.RegisterAlias(shortID, longID)
    var t1: Transliterator = Transliterator.GetInstance(longID)
    var t2: Transliterator = Transliterator.GetInstance(reallyShortID)
    if !t1.ID.Equals(longID):
Errln("Transliterator instantiated with long ID doesn't have long ID")
    if !t2.ID.Equals(reallyShortID):
Errln("Transliterator instantiated with short ID doesn't have short ID")
    if !t1.ToRules(true).Equals(t2.ToRules(true)):
Errln("Alias transliterators aren't the same")
Transliterator.Unregister(shortID)
    try:
        t1 = Transliterator.GetInstance(shortID)
Errln("Instantiation with short ID succeeded after short ID was unregistered")
    except ArgumentException:

    var realID: String = "Latin-Greek"
    var fakeID: String = "Latin-dlgkjdflkjdl"
Transliterator.RegisterAlias(fakeID, realID)
    t1 = Transliterator.GetInstance(realID)
    t2 = Transliterator.GetInstance(fakeID)
    if !t1.ToRules(true).Equals(t2.ToRules(true)):
Errln("Alias transliterators aren't the same")
Transliterator.Unregister(fakeID)
proc TestHalfwidthFullwidth*() =
    var hf: Transliterator = Transliterator.GetInstance("Halfwidth-Fullwidth")
    var fh: Transliterator = Transliterator.GetInstance("Fullwidth-Halfwidth")
    var DATA: String[] = @["both", "￩￪￫￬aｱ¯ ", "←↑→↓ａア￣　"]
      var i: int = 0
      while i < DATA.Length:
          case DATA[i][0]
          of 'h':
Expect(hf, DATA[i + 1], DATA[i + 2])
              break
          of 'f':
Expect(fh, DATA[i + 2], DATA[i + 1])
              break
          of 'b':
Expect(hf, DATA[i + 1], DATA[i + 2])
Expect(fh, DATA[i + 2], DATA[i + 1])
              break
          i = 3
proc TestThai*() =
    var tr: Transliterator = Transliterator.GetInstance("Any-Latin", Transliterator.Forward)
    var thaiText: String = "โดยพื้นฐานแล้ว, คอ" + "มพิวเตอร์จะเกี่ย" + "วข้องกับเรื่องขอ" + "งตัวเลข. คอมพิวเตอ" + "ร์จัดเก็บตัวอักษ" + "รและอักขระอื่นๆ โ" + "ดยการกำหนดหมายเล" + "ขให้สำหรับแต่ละต" + "ัว. ก่อนหน้าที่๊ Unicode จ" + "ะถูกสร้างขึ้น, ได้" + "มีระบบ encoding อยู่หลายร" + "้อยระบบสำหรับการ" + "กำหนดหมายเลขเหล่" + "านี้. ไม่มี encoding ใดที่" + "มีจำนวนตัวอักขระ" + "มากเพียงพอ: ยกตัวอ" + "ย่างเช่น, เฉพาะในก" + "ลุ่มสหภาพยุโรปเพ" + "ียงแห่งเดียว ก็ต้" + "องการหลาย encoding ในการค" + "รอบคลุมทุกภาษาใน" + "กลุ่ม. หรือแม้แต่ใ" + "นภาษาเดี่ยว เช่น ภ" + "าษาอังกฤษ ก็ไม่มี" + " encoding ใดที่เพียงพอสำห" + "รับทุกตัวอักษร, เค" + "รื่องหมายวรรคตอน" + " และสัญลักษณ์ทางเ" + "ทคนิคที่ใช้กันอย" + "ู่ทั่วไป."
    var latinText: String = "doy phụ̄̂n ṭ̄hān læ̂w, khxmphiwtexr̒ ca keī̀" + "ywk̄ĥxng kạb reụ̄̀xng k̄hxng tạwlek̄h. khxmphiwtexr" + "̒ cạd kĕb tạw xạks̄ʹr læa xạkk̄h ra xụ̄" + "̀n« doy kār kảh̄nd h̄māylek̄h h̄ı̂ s̄" + "ảh̄rạb tæ̀la tạw. k̀xn h̄n̂ā thī̀́" + " Unicode ca t̄hūk s̄r̂āng k̄hụ̂n, dị̂ mī " + "rabb encoding xyū̀ h̄lāy r̂xy rabb s̄ảh̄rạb kā" + "r kảh̄nd h̄māylek̄h h̄el̀ā nī̂. mị̀m" + "ī encoding dı thī̀ mī cảnwn tạw xạkk̄hra māk p" + "heīyng phx: yk tạwxỳāng chèn, c̄hephāa nı klùm s̄" + "h̄p̣hāph yurop pheīyng h̄æ̀ng deīyw k̆ t̂xngkā" + "r h̄lāy encoding nı kār khrxbkhlum thuk p̣hās̄ʹā nı" + " klùm. h̄rụ̄x mæ̂tæ̀ nı p̣hās̄ʹ" + "ā deī̀yw chèn p̣hās̄ʹā xạngkvs̄ʹ k̆" + " mị̀mī encoding dı thī̀ pheīyng phx s̄ảh̄rạ" + "b thuk tạw xạks̄ʹr, kherụ̄̀xngh̄māy wrrkh txn læ" + "a s̄ạỵlạks̄ʹṇ̒ thāng thekhnikh thī̀ chı" + "̂ kạn xyū̀ thạ̀wpị."
Expect(tr, thaiText, latinText)
proc TestCoverage*() =
    var t: Transliterator = Transliterator.GetInstance("Null", Transliterator.Forward)
Expect(t, "a", "a")
    t = Transliterator.GetInstance("Latin-Greek", Transliterator.Forward)
    t.Filter = UnicodeSet("[A-Z]")
Logln("source = " + t.GetSourceSet)
Logln("target = " + t.GetTargetSet)
    t = Transliterator.CreateFromRules("x", "(.) > &Any-Hex($1);", Transliterator.Forward)
Logln("source = " + t.GetSourceSet)
Logln("target = " + t.GetTargetSet)
proc TestT5160*() =
    var testData: String[] = @["a", "b", "া", "Á"]
    var expected: String[] = @["a", "b", "া", "Á"]
    var translit: Transliterator = Transliterator.GetInstance("NFC")
    var tasks: NormTranslitTask[] = seq[NormTranslitTask]
      var i: int = 0
      while i < tasks.Length:
          tasks[i] = NormTranslitTask(translit, testData[i], expected[i])
++i
TestUtil.RunUntilDone(tasks.Select(<unhandled: nnkLambda>).ToArray)
      var i: int = 0
      while i < tasks.Length:
          if tasks[i].ErrorMessage != nil:
Console.Out.WriteLine("Fail: thread#" + i + " " + tasks[i].ErrorMessage)
              break
++i
type
  NormTranslitTask = ref object
    translit: Transliterator
    testData: String
    expectedData: String
    errorMsg: String

proc newNormTranslitTask(translit: Transliterator, testData: String, expectedData: String): NormTranslitTask =
  self.translit = translit
  self.testData = testData
  self.expectedData = expectedData
proc Run*() =
    errorMsg = nil
    var inBuf: StringBuffer = StringBuffer(testData)
    var expectedBuf: StringBuffer = StringBuffer(expectedData)
      var i: int = 0
      while i < 1000:
          var @in: String = inBuf.ToString
          var @out: String = translit.Transliterate(@in)
          var expected: String = expectedBuf.ToString
          if !@out.Equals(expected):
              errorMsg = "in {" + @in + "} / out {" + @out + "} / expected {" + expected + "}"
              break
inBuf.Append(testData)
expectedBuf.Append(expectedData)
++i
proc ErrorMessage(): String =
    return errorMsg
proc Expect(rules: String, source: String, expectedResult: String, pos: TransliterationPosition) =
    var t: Transliterator = Transliterator.CreateFromRules("<ID>", rules, Transliterator.Forward)
Expect(t, source, expectedResult, pos)
proc Expect(rules: String, source: String, expectedResult: String) =
Expect(rules, source, expectedResult, nil)
proc Expect(t: Transliterator, source: String, expectedResult: String, reverseTransliterator: Transliterator) =
Expect(t, source, expectedResult)
    if reverseTransliterator != nil:
Expect(reverseTransliterator, expectedResult, source)
proc Expect(t: Transliterator, source: String, expectedResult: String) =
Expect(t, source, expectedResult, cast[TransliterationPosition](nil))
proc Expect(t: Transliterator, source: String, expectedResult: String, pos: TransliterationPosition) =
    if pos == nil:
        var result: String = t.Transliterate(source)
        if !ExpectAux(t.ID + ":String", source, result, expectedResult):
          return
    var index: TransliterationPosition = nil
    if pos == nil:
        index = TransliterationPosition(0, source.Length, 0, source.Length)
    else:
        index = TransliterationPosition(pos.ContextStart, pos.ContextLimit, pos.Start, pos.Limit)
    var rsource: ReplaceableString = ReplaceableString(source)
t.FinishTransliteration(rsource, index)
    if index.Start != index.Limit:
ExpectAux(t.ID + ":UNFINISHED", source, "start: " + index.Start + ", limit: " + index.Limit, false, expectedResult)
        return
      var result: String = rsource.ToString
      if !ExpectAux(t.ID + ":Replaceable", source, result, expectedResult):
        return
      if pos == nil:
          index = TransliterationPosition
      else:
          index = TransliterationPosition(pos.ContextStart, pos.ContextLimit, pos.Start, pos.Limit)
      var v: List<String> = List<String>
v.Add(source)
rsource.Replace(0, rsource.Length - 0, "")
      if pos != nil:
rsource.Replace(0, 0 - 0, source)
v.Add(UtilityExtensions.FormatInput(rsource, index))
t.Transliterate(rsource, index)
v.Add(UtilityExtensions.FormatInput(rsource, index))
      else:
            var i: int = 0
            while i < source.Length:
t.Transliterate(rsource, index, source[i])
v.Add(UtilityExtensions.FormatInput(rsource, index) +                 if i < source.Length - 1:
" + '" + source[i + 1] + "' ->"
                else:
" =>")
++i
t.FinishTransliteration(rsource, index)
      result = rsource.ToString
v.Add(result)
      var results: String[] = seq[String]
v.CopyTo(results)
ExpectAux(t.ID + ":Incremental", results, result.Equals(expectedResult), expectedResult)
proc ExpectAux(tag: String, source: String, result: String, expectedResult: String): bool =
    return ExpectAux(tag, @[source, result], result.Equals(expectedResult), expectedResult)
proc ExpectAux(tag: String, source: String, result: String, pass: bool, expectedResult: String): bool =
    return ExpectAux(tag, @[source, result], pass, expectedResult)
proc ExpectAux(tag: String, source: String, pass: bool, expectedResult: String): bool =
    return ExpectAux(tag, @[source], pass, expectedResult)
proc ExpectAux(tag: String, results: seq[String], pass: bool, expectedResult: String): bool =
msg(    if pass:
"("
    else:
"FAIL: (" + tag + ")",     if pass:
LOG
    else:
ERR, true, true)
      var i: int = 0
      while i < results.Length:
          var label: String
          if i == 0:
              label = "source:   "

          elif i == results.Length - 1:
              label = "result:   "
          else:
              if !IsVerbose && pass:
                continue
              label = "interm" + i + ":  "
msg("    " + label + results[i],           if pass:
LOG
          else:
ERR, false, true)
++i
    if !pass:
msg("    expected: " + expectedResult, ERR, false, true)
    return pass
proc AssertTransform(message: String, expected: String, t: IStringTransform, source: String) =
assertEquals(message + " " + source, expected, t.Transform(source))
proc AssertTransform(message: String, expected: String, t: IStringTransform, back: IStringTransform, source: String, source2: String) =
assertEquals(message + " " + source, expected, t.Transform(source))
assertEquals(message + " " + source2, expected, t.Transform(source2))
assertEquals(message + " " + expected, source, back.Transform(expected))
proc TestGetAvailableTargets*() =
    try:
Transliterator.GetAvailableTargets("")
    except Exception:
Errln("TransliteratorRegistry.getAvailableTargets(String) was not " + "supposed to return an exception.")
proc TestGetAvailableVariants*() =
    try:
Transliterator.GetAvailableVariants("", "")
    except Exception:
Errln("TransliteratorRegistry.getAvailableVariants(String) was not " + "supposed to return an exception.")
proc TestNextLine*() =
    try:
Transliterator.CreateFromRules("gif", "\", Transliterator.Forward)
    except Exception:
Errln("TransliteratorParser.nextLine() was not suppose to return an " + "exception for a rule of '\'")