# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationMiscTest = ref object
    m_rangeTestCases_: seq[OneTestCase] = @[OneTestCase("a", "b", -1), OneTestCase("b", "c", -1), OneTestCase("a", "c", -1), OneTestCase("b", "k", -1), OneTestCase("k", "l", -1), OneTestCase("b", "l", -1), OneTestCase("a", "l", -1), OneTestCase("a", "m", -1), OneTestCase("y", "m", -1), OneTestCase("y", "g", -1), OneTestCase("a", "h", -1), OneTestCase("a", "e", -1), OneTestCase("a", "1", 0), OneTestCase("a", "2", 0), OneTestCase("a", "3", 0), OneTestCase("a", "f", -1), OneTestCase("la", "kb", -1), OneTestCase("aaa", "123", 0), OneTestCase("b", "z", -1), OneTestCase("azb", "2ym", -1)]
    m_rangeTestCasesSupplemental_: seq[OneTestCase] = @[OneTestCase("一", "￻", -1), OneTestCase("￻", "𐀀", -1), OneTestCase("𐀀", "𐀁", -1), OneTestCase("一", "𐀁", -1), OneTestCase("𐀁", "𐀂", -1), OneTestCase("𐀀", "𠀂", -1), OneTestCase("一", "඄0�", -1)]
    m_qwertCollationTestCases_: seq[OneTestCase] = @[OneTestCase("q", "w", -1), OneTestCase("w", "e", -1), OneTestCase("y", "u", -1), OneTestCase("q", "u", -1), OneTestCase("t", "i", -1), OneTestCase("o", "p", -1), OneTestCase("y", "e", -1), OneTestCase("i", "u", -1), OneTestCase("quest", "were", -1), OneTestCase("quack", "quest", -1)]

type
  Tester = ref object
    u: int
    NFC: String
    NFD: String

proc hasCollationElements(locale: CultureInfo): bool =
    var rb: ICUResourceBundle = cast[ICUResourceBundle](UResourceBundle.GetBundleInstance(ICUData.IcuCollationBaseName, locale))
    if rb != nil:
        try:
            var collkey: String = rb.GetStringWithFallback("collations/default")
            var elements: ICUResourceBundle = rb.GetWithFallback("collations/" + collkey)
            if elements != nil:
                return true
        except Exception:

    return false
proc TestComposeDecompose*() =
    var t: Tester[] = seq[Tester]
    t[0] = Tester
Logln("Testing UCA extensively
")
    var coll: RuleBasedCollator
    try:
        coll = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en")))
    except Exception:
Warnln("Error opening collator
")
        return
    var noCases: int = 0
      var u: int = 0
      while u < 196608:
          var comp: String = UTF16.ValueOf(u)
          var len: int = comp.Length
          t[noCases].NFC = Normalizer.Normalize(u, NormalizerMode.NFC)
          t[noCases].NFD = Normalizer.Normalize(u, NormalizerMode.NFD)
          if t[noCases].NFC.Length != t[noCases].NFD.Length || t[noCases].NFC.CompareToOrdinal(t[noCases].NFD) != 0 || len != t[noCases].NFD.Length || comp.CompareToOrdinal(t[noCases].NFD) != 0:
              t[noCases].u = u
              if len != t[noCases].NFD.Length || comp.CompareToOrdinal(t[noCases].NFD) != 0:
                  t[noCases].NFC = comp
++noCases
              t[noCases] = Tester
++u
      var u: int = 0
      while u < noCases:
          if !coll.Equals(t[u].NFC, t[u].NFD):
Errln("Failure: codePoint \u" + t[u].u.ToHexString + " fails TestComposeDecompose in the UCA")
CollationTest.DoTest(self, coll, t[u].NFC, t[u].NFD, 0)
++u
Logln("Testing locales, number of cases = " + noCases)
    var loc: CultureInfo[] = Collator.GetCultures(UCultureTypes.AllCultures)
      var i: int = 0
      while i < loc.Length:
          if hasCollationElements(loc[i]):
Logln("Testing locale " + loc[i].DisplayName)
              coll = cast[RuleBasedCollator](Collator.GetInstance(loc[i]))
              coll.Strength = Collator.Identical
                var u: int = 0
                while u < noCases:
                    if !coll.Equals(t[u].NFC, t[u].NFD):
Errln("Failure: codePoint \u" + t[u].u.ToHexString + " fails TestComposeDecompose for locale " + loc[i].DisplayName)
CollationTest.DoTest(self, coll, t[u].NFC, t[u].NFD, 0)
++u
++i
proc TestRuleOptions*() =
    var LAST_VARIABLE_CHAR_STRING: String = "\U00010A7F"
    var FIRST_REGULAR_CHAR_STRING: String = "\u0060"
    var SECOND_REGULAR_CHAR_STRING: String = "\u00B4"
    var LAST_REGULAR_CHAR_STRING: String = "\U0001342E"
    var rules: String[] = @["&[before 3][first secondary ignorable]<<<a", "&[before 3][last secondary ignorable]<<<a", "&[before 3][first primary ignorable]<<<c<<<b &' '<a", "&[before 3][last primary ignorable]<<<c<<<b &' '<a", "&[before 3][first variable]<<<c<<<b &[first variable]<a", "&[last variable]<a &[before 3][last variable]<<<c<<<b ", "&[first regular]<a &[before 1][first regular]<b", "&[before 1][last regular]<b &[last regular]<a", "&[before 1][first implicit]<b &[first implicit]<a", "&[last variable]<z" + "&' '<x" + "&[last secondary ignorable]<<y&[last tertiary ignorable]<<<w&[top]<u"]
    var data: String[][] = @[@["\u0000", "a"], @["\u0000", "a"], @["c", "b", "\u0332", "a"], @["\u0332", "\u20e3", "c", "b", "a"], @["c", "b", "\u0009", "a", "\u000a"], @[LAST_VARIABLE_CHAR_STRING, "c", "b", "a", FIRST_REGULAR_CHAR_STRING], @["b", FIRST_REGULAR_CHAR_STRING, "a", SECOND_REGULAR_CHAR_STRING], @[LAST_REGULAR_CHAR_STRING, "b", "a", "\u4e00"], @["b", "\u4e00", "a", "\u4e01"], @["￻", "w", "y", "⃣", "x", LAST_VARIABLE_CHAR_STRING, "z", "u"]]
      var i: int = 0
      while i < rules.Length:
Logln(String.Format("rules[{0}] = "{1}"", i, rules[i]))
genericRulesStarter(rules[i], data[i])
++i
proc genericRulesStarter(rules: String, s: seq[String]) =
genericRulesStarterWithResult(rules, s, -1)
proc genericRulesStarterWithResult(rules: String, s: seq[String], result: int) =
    var coll: RuleBasedCollator = nil
    try:
        coll = RuleBasedCollator(rules)
genericOrderingTestWithResult(coll, s, result)
    except Exception:
Warnln("Unable to open collator with rules " + rules + ": " + e)
proc genericRulesStarterWithOptionsAndResult(rules: String, s: seq[String], atts: seq[String], attVals: seq[Object], result: int) =
    var coll: RuleBasedCollator = nil
    try:
        coll = RuleBasedCollator(rules)
genericOptionsSetter(coll, atts, attVals)
genericOrderingTestWithResult(coll, s, result)
    except Exception:
Warnln("Unable to open collator with rules " + rules)
proc genericOrderingTestWithResult(coll: Collator, s: seq[String], result: int) =
    var t1: String = ""
    var t2: String = ""
      var i: int = 0
      while i < s.Length - 1:
            var j: int = i + 1
            while j < s.Length:
                t1 = Utility.Unescape(s[i])
                t2 = Utility.Unescape(s[j])
CollationTest.DoTest(self, cast[RuleBasedCollator](coll), t1, t2, result)
++j
++i
proc reportCResult(source: String, target: String, sourceKey: CollationKey, targetKey: CollationKey, compareResult: int, keyResult: int, incResult: int, expectedResult: int) =
    if expectedResult < -1 || expectedResult > 1:
Errln("***** invalid call to reportCResult ****")
        return
    var ok1: bool = compareResult == expectedResult
    var ok2: bool = keyResult == expectedResult
    var ok3: bool = incResult == expectedResult
    if ok1 && ok2 && ok3:
        return
    else:
        var msg1: String =         if ok1:
"Ok: compare(""
        else:
"FAIL: compare(""
        var msg2: String = "", ""
        var msg3: String = "") returned "
        var msg4: String = "; expected "
        var sExpect: String = ""
        var sResult: String = ""
        sResult = CollationTest.AppendCompareResult(compareResult, sResult)
        sExpect = CollationTest.AppendCompareResult(expectedResult, sExpect)
        if ok1:

        else:
Errln(msg1 + source + msg2 + target + msg3 + sResult + msg4 + sExpect)
        msg1 =         if ok2:
"Ok: key(""
        else:
"FAIL: key(""
        msg2 = "").compareTo(key(""
        msg3 = "")) returned "
        sResult = CollationTest.AppendCompareResult(keyResult, sResult)
        if ok2:

        else:
Errln(msg1 + source + msg2 + target + msg3 + sResult + msg4 + sExpect)
            msg1 = "  "
            msg2 = " vs. "
Errln(msg1 + CollationTest.Prettify(sourceKey) + msg2 + CollationTest.Prettify(targetKey))
        msg1 =         if ok3:
"Ok: incCompare(""
        else:
"FAIL: incCompare(""
        msg2 = "", ""
        msg3 = "") returned "
        sResult = CollationTest.AppendCompareResult(incResult, sResult)
        if ok3:

        else:
Errln(msg1 + source + msg2 + target + msg3 + sResult + msg4 + sExpect)
proc TestBeforePrefixFailure*() =
    var rules: String[] = @["&g <<< a&[before 3]ａ <<< x", "&ェ=ェ=ぇ=ｪ&エ=エ=え=ｴ&[before 3]ェ<<<ォ", "&[before 3]ェ<<<ォ&ェ=ェ=ぇ=ｪ&エ=エ=え=ｴ"]
    var data: String[][] = @[@["x", "ａ"], @["ォ", "ェ"], @["ォ", "ェ"]]
      var i: int = 0
      while i < rules.Length:
genericRulesStarter(rules[i], data[i])
++i
proc TestContractionClosure*() =
    var rules: String[] = @["&b=ää", "&b=Å"]
    var data: String[][] = @[@["b", "ää", "ää", "ää", "ää"], @["b", "Å", "Å", "Å"]]
      var i: int = 0
      while i < rules.Length:
genericRulesStarterWithResult(rules[i], data[i], 0)
++i
proc TestPrefixCompose*() =
    var rule1: String = "&ェ<<<カ|ー=ガ|ー"
    var str: String = rule1
    try:
        var coll: RuleBasedCollator = RuleBasedCollator(str)
Logln("rule:" + coll.GetRules)
    except Exception:
Warnln("Error open RuleBasedCollator rule = " + str)
proc TestStrCollIdenticalPrefix*() =
    var rule: String = "&񼁰=񼁱"
    var test: String[] = @["ab񼁰", "ab񼁱"]
genericRulesStarterWithResult(rule, test, 0)
proc TestPrefix*() =
    var rules: String[] = @["&z <<< z|a", "&z <<< z|   a", "[strength I]&a=񐀥&z<<<񐀥|a"]
    var data: String[][] = @[@["zz", "za"], @["zz", "za"], @["aa", "az", "񐀥z", "񐀥a", "zz"]]
      var i: int = 0
      while i < rules.Length:
genericRulesStarter(rules[i], data[i])
++i
proc TestNewJapanese*() =
    var test1: String[] = @["シャーレ", "シャイ", "シヤィ", "シャレ", "ちょこ", "ちよこ", "チョコレート", "てーた", "テータ", "テェタ", "てえた", "でーた", "データ", "デェタ", "でえた", "てーたー", "テータァ", "テェター", "てぇたぁ", "てえたー", "でーたー", "データァ", "でェたァ", "デぇタぁ", "デエタア", "ひゆ", "びゅあ", "ぴゅあ", "びゅあー", "ビュアー", "ぴゅあー", "ピュアー", "ヒュウ", "ヒユウ", "ピュウア", "びゅーあー", "ビューアー", "ビュウアー", "ひゅん", "ぴゅん", "ふーり", "フーリ", "ふぅり", "ふゥり", "ふゥリ", "フウリ", "ぶーり", "ブーリ", "ぶぅり", "ブゥり", "ぷうり", "プウリ", "ふーりー", "フゥリー", "ふゥりィ", "フぅりぃ", "フウリー", "ふうりぃ", "ブウリイ", "ぷーりー", "ぷゥりイ", "ぷうりー", "プウリイ", "フヽ", "ふゞ", "ぶゝ", "ぶふ", "ぶフ", "ブふ", "ブフ", "ぶゞ", "ぶぷ", "ブぷ", "ぷゝ", "プヽ", "ぷふ"]
    var test2: String[] = @["はゝ", "ハヽ", "はは", "はハ", "ハハ", "はゞ", "ハヾ", "はば", "ハバ", "はぱ", "ハぱ", "ハパ", "ばゝ", "バヽ", "ばは", "バハ", "ばゞ", "バヾ", "ばば", "バば", "ババ", "ばぱ", "バパ", "ぱゝ", "パヽ", "ぱは", "パハ", "ぱば", "ぱバ", "パバ", "ぱぱ", "パパ"]
    var att: String[] = @["strength"]
    var val: Object[] = @[int?(cast[int](Collator.Quaternary))]
    var attShifted: String[] = @["strength", "AlternateHandling"]
    var valShifted: Object[] = @[int?(cast[int](Collator.Quaternary)), true]
genericLocaleStarterWithOptions(CultureInfo("ja"), test1, att, val)
genericLocaleStarterWithOptions(CultureInfo("ja"), test2, att, val)
genericLocaleStarterWithOptions(CultureInfo("ja"), test1, attShifted, valShifted)
genericLocaleStarterWithOptions(CultureInfo("ja"), test2, attShifted, valShifted)
proc genericLocaleStarter(locale: CultureInfo, s: seq[String]) =
    var coll: RuleBasedCollator = nil
    try:
        coll = cast[RuleBasedCollator](Collator.GetInstance(locale))
    except Exception:
Warnln("Unable to open collator for locale " + locale)
        return
genericOrderingTest(coll, s)
proc genericLocaleStarterWithOptions(locale: CultureInfo, s: seq[String], attrs: seq[String], values: seq[Object]) =
genericLocaleStarterWithOptionsAndResult(locale, s, attrs, values, -1)
proc genericOptionsSetter(coll: RuleBasedCollator, attrs: seq[String], values: seq[Object]) =
      var i: int = 0
      while i < attrs.Length:
          if attrs[i].Equals("strength"):
              coll.Strength = cast[CollationStrength](cast[int?](values[i]).Value)

          elif attrs[i].Equals("decomp"):
              coll.Decomposition = cast[NormalizationMode](cast[int?](values[i]).Value)
          else:
            if attrs[i].Equals("AlternateHandling"):
                coll.IsAlternateHandlingShifted = cast[bool](values[i])

            elif attrs[i].Equals("NumericCollation"):
                coll.IsNumericCollation = cast[bool](values[i])
            else:
              if attrs[i].Equals("UpperFirst"):
                  coll.IsUpperCaseFirst = cast[bool](values[i])

              elif attrs[i].Equals("LowerFirst"):
                  coll.IsLowerCaseFirst = cast[bool](values[i])
              else:
                if attrs[i].Equals("CaseLevel"):
                    coll.IsCaseLevel = cast[bool](values[i])
++i
proc genericLocaleStarterWithOptionsAndResult(locale: CultureInfo, s: seq[String], attrs: seq[String], values: seq[Object], result: int) =
    var coll: RuleBasedCollator = nil
    try:
        coll = cast[RuleBasedCollator](Collator.GetInstance(locale))
    except Exception:
Warnln("Unable to open collator for locale " + locale)
        return
genericOptionsSetter(coll, attrs, values)
genericOrderingTestWithResult(coll, s, result)
proc genericOrderingTest(coll: Collator, s: seq[String]) =
genericOrderingTestWithResult(coll, s, -1)
proc TestNonChars*() =
    var test: String[] = @[" ", "￾", "﷐", "﷯", "\U0001FFFE", "\U0001FFFF", "\U0002FFFE", "\U0002FFFF", "\U0003FFFE", "\U0003FFFF", "\U0004FFFE", "\U0004FFFF", "\U0005FFFE", "\U0005FFFF", "\U0006FFFE", "\U0006FFFF", "\U0007FFFE", "\U0007FFFF", "\U0008FFFE", "\U0008FFFF", "\U0009FFFE", "\U0009FFFF", "\U000AFFFE", "\U000AFFFF", "\U000BFFFE", "\U000BFFFF", "\U000CFFFE", "\U000CFFFF", "\U000DFFFE", "\U000DFFFF", "\U000EFFFE", "\U000EFFFF", "\U000FFFFE", "\U000FFFFF", "\U0010FFFE", "\U0010FFFF", "￿"]
    var coll: Collator = nil
    try:
        coll = Collator.GetInstance(CultureInfo("en-US"))
    except Exception:
Warnln("Unable to open collator")
        return
genericOrderingTestWithResult(coll, test, -1)
proc TestExtremeCompression*() =
    var test: String[] = seq[String]
      var i: int = 0
      while i < 4:
          var temp: StringBuffer = StringBuffer
            var j: int = 0
            while j < 2047:
temp.Append('a')
++j
temp.Append(cast[char]('a' + i))
          test[i] = temp.ToString
++i
genericLocaleStarter(CultureInfo("en-US"), test)
proc TestSurrogates*() =
    var test: String[] = @["z", "񐀥", "𑑐", "𐀀y", "𐀀r", "𐀀f", "𐀀", "𐀀c", "𐀀b", "𐀀fa", "𐀀fb", "𐀀a", "c", "b"]
    var rule: String = "&z < 񐀥 < 𑑐 < 𐀀y " + "< 𐀀r < 𐀀f << 𐀀 " + "< 𐀀fa << 𐀀fb < 𐀀a " + "< c < b"
genericRulesStarter(rule, test)
proc TestBocsuCoverage*() =
    var test: String = "Aс䑁\U00044441䑁сA"
    var coll: Collator = Collator.GetInstance
    coll.Strength = Collator.Identical
    var key: CollationKey = coll.GetCollationKey(test)
Logln("source:" + key.SourceString)
proc TestCyrillicTailoring*() =
    var test: String[] = @["Аb", "Ӑa", "ӐA"]
genericRulesStarter("&А = А < Ӑ", test)
genericRulesStarter("&Z < А < Ӑ", test)
proc TestSuppressContractions*() =
    var testNoCont2: String[] = @["А̂a", "Ӑb", "Аc"]
    var testNoCont: String[] = @["aА", "AӐ", "ＡА̂"]
genericRulesStarter("[suppressContractions [Ѐ-ѿ]]", testNoCont)
genericRulesStarter("[suppressContractions [Ѐ-ѿ]]", testNoCont2)
proc TestCase*() =
    var gRules: String = "&0<1,①<a,A"
    var testCase: String[] = @["1a", "1A", "①a", "①A"]
    var caseTestResults: int[][] = @[@[-1, -1, -1, 0, -1, -1, 0, 0, -1], @[1, -1, -1, 0, -1, -1, 0, 0, 1], @[-1, -1, -1, 0, 1, -1, 0, 0, -1], @[1, -1, 1, 0, -1, -1, 0, 0, 1]]
    var caseTestAttributes: bool[][] = @[@[false, false], @[true, false], @[false, true], @[true, true]]
      var i: int
      var j: int
      var k: int
    var myCollation: Collator
    try:
        myCollation = Collator.GetInstance(CultureInfo("en-US"))
    except Exception:
Warnln("ERROR: in creation of rule based collator ")
        return
    myCollation.Strength = Collator.Tertiary
      k = 0
      while k < 4:
          if caseTestAttributes[k][0] == true:
              cast[RuleBasedCollator](myCollation).IsUpperCaseFirst = true
          else:
              cast[RuleBasedCollator](myCollation).IsLowerCaseFirst = true
          cast[RuleBasedCollator](myCollation).IsCaseLevel = caseTestAttributes[k][1]
            i = 0
            while i < 3:
                  j = i + 1
                  while j < 4:
CollationTest.DoTest(self, cast[RuleBasedCollator](myCollation), testCase[i], testCase[j], caseTestResults[k][3 * i + j - 1])
++j
++i
++k
    try:
        myCollation = RuleBasedCollator(gRules)
    except Exception:
Warnln("ERROR: in creation of rule based collator")
        return
    myCollation.Strength = Collator.Tertiary
      k = 0
      while k < 4:
          if caseTestAttributes[k][0] == true:
              cast[RuleBasedCollator](myCollation).IsUpperCaseFirst = true
          else:
              cast[RuleBasedCollator](myCollation).IsUpperCaseFirst = false
          cast[RuleBasedCollator](myCollation).IsCaseLevel = caseTestAttributes[k][1]
            i = 0
            while i < 3:
                  j = i + 1
                  while j < 4:
CollationTest.DoTest(self, cast[RuleBasedCollator](myCollation), testCase[i], testCase[j], caseTestResults[k][3 * i + j - 1])
++j
++i
++k
      var lowerFirst: String[] = @["h", "H", "ch", "Ch", "CH", "cha", "chA", "Cha", "ChA", "CHa", "CHA", "i", "I"]
      var upperFirst: String[] = @["H", "h", "CH", "Ch", "ch", "CHA", "CHa", "ChA", "Cha", "chA", "cha", "I", "i"]
genericRulesStarter("[caseFirst lower]&H<ch<<<Ch<<<CH", lowerFirst)
genericRulesStarter("[caseFirst upper]&H<ch<<<Ch<<<CH", upperFirst)
genericRulesStarter("[caseFirst lower][caseLevel on]&H<ch<<<Ch<<<CH", lowerFirst)
genericRulesStarter("[caseFirst upper][caseLevel on]&H<ch<<<Ch<<<CH", upperFirst)
proc TestIncompleteCnt*() =
    var cnt1: String[] = @["AA", "AC", "AZ", "AQ", "AB", "ABZ", "ABQ", "Z", "ABC", "Q", "B"]
    var cnt2: String[] = @["DA", "DAD", "DAZ", "MAR", "Z", "DAVIS", "MARK", "DAV", "DAVI"]
    var coll: RuleBasedCollator = nil
    var temp: String = " & Z < ABC < Q < B"
    try:
        coll = RuleBasedCollator(temp)
    except Exception:
Warnln("fail to create RuleBasedCollator")
        return
    var size: int = cnt1.Length
      var i: int = 0
      while i < size - 1:
            var j: int = i + 1
            while j < size:
                var t1: String = cnt1[i]
                var t2: String = cnt1[j]
CollationTest.DoTest(self, coll, t1, t2, -1)
++j
++i
    temp = " & Z < DAVIS < MARK <DAV"
    try:
        coll = RuleBasedCollator(temp)
    except Exception:
Warnln("fail to create RuleBasedCollator")
        return
    size = cnt2.Length
      var i: int = 0
      while i < size - 1:
            var j: int = i + 1
            while j < size:
                var t1: String = cnt2[i]
                var t2: String = cnt2[j]
CollationTest.DoTest(self, coll, t1, t2, -1)
++j
++i
proc TestBlackBird*() =
    var shifted: String[] = @["black bird", "black-bird", "blackbird", "black Bird", "black-Bird", "blackBird", "black birds", "black-birds", "blackbirds"]
    var shiftedTert: int[] = @[0, 0, 0, -1, 0, 0, -1, 0, 0]
    var nonignorable: String[] = @["black bird", "black Bird", "black birds", "black-bird", "black-Bird", "black-birds", "blackbird", "blackBird", "blackbirds"]
      var i: int = 0
      var j: int = 0
    var size: int = 0
    var coll: Collator = Collator.GetInstance(CultureInfo("en-US"))
    cast[RuleBasedCollator](coll).IsAlternateHandlingShifted = false
    size = nonignorable.Length
      i = 0
      while i < size - 1:
            j = i + 1
            while j < size:
                var t1: String = nonignorable[i]
                var t2: String = nonignorable[j]
CollationTest.DoTest(self, cast[RuleBasedCollator](coll), t1, t2, -1)
++j
++i
    cast[RuleBasedCollator](coll).IsAlternateHandlingShifted = true
    coll.Strength = Collator.Quaternary
    size = shifted.Length
      i = 0
      while i < size - 1:
            j = i + 1
            while j < size:
                var t1: String = shifted[i]
                var t2: String = shifted[j]
CollationTest.DoTest(self, cast[RuleBasedCollator](coll), t1, t2, -1)
++j
++i
    coll.Strength = Collator.Tertiary
    size = shifted.Length
      i = 1
      while i < size:
          var t1: String = shifted[i - 1]
          var t2: String = shifted[i]
CollationTest.DoTest(self, cast[RuleBasedCollator](coll), t1, t2, shiftedTert[i])
++i
proc TestFunkyA*() =
    var testSourceCases: String[] = @["À́", "À̖", "À", "À́", "À̖"]
    var testTargetCases: String[] = @["Á̀", "À̖", "À", "Á̀", "À̖"]
    var results: int[] = @[1, 0, 0, 1, 0]
    var myCollation: Collator
    try:
        myCollation = Collator.GetInstance(CultureInfo("en-US"))
    except Exception:
Warnln("ERROR: in creation of rule based collator")
        return
    myCollation.Decomposition = Collator.CanonicalDecomposition
    myCollation.Strength = Collator.Tertiary
      var i: int = 0
      while i < 4:
CollationTest.DoTest(self, cast[RuleBasedCollator](myCollation), testSourceCases[i], testTargetCases[i], results[i])
++i
proc TestChMove*() =
    var chTest: String[] = @["c", "C", "ca", "cb", "cx", "cy", "CZ", "č", "Č", "h", "H", "ha", "Ha", "harly", "hb", "HB", "hx", "HX", "hy", "HY", "ch", "cH", "Ch", "CH", "cha", "charly", "che", "chh", "chch", "chr", "i", "I", "iarly", "r", "R", "ř", "Ř", "s", "S", "š", "Š", "z", "Z", "ž", "Ž"]
    var coll: Collator = nil
    try:
        coll = Collator.GetInstance(CultureInfo("cs"))
    except Exception:
Warnln("Cannot create Collator")
        return
    var size: int = chTest.Length
      var i: int = 0
      while i < size - 1:
            var j: int = i + 1
            while j < size:
                var t1: String = chTest[i]
                var t2: String = chTest[j]
CollationTest.DoTest(self, cast[RuleBasedCollator](coll), t1, t2, -1)
++j
++i
proc TestImplicitTailoring*() =
    var rules: String[] = @["&[before 1]一 < b < c " + "&[before 1]一 < d < e", "&一 < a <<< A < b <<< B", "&[before 1]一 < 丁 < 丂", "&[before 1]丁 < 丂 < 七"]
    var cases: String[][] = @[@["b", "c", "d", "e", "一"], @["一", "a", "A", "b", "B", "丁"], @["丁", "丂", "一"], @["丂", "七", "丁"]]
    var i: int = 0
      i = 0
      while i < rules.Length:
genericRulesStarter(rules[i], cases[i])
++i
proc TestFCDProblem*() =
    var s1: String = "ӑ̥"
    var s2: String = "ӑ̥"
    var coll: Collator = nil
    try:
        coll = Collator.GetInstance
    except Exception:
Warnln("Can't create collator")
        return
    coll.Decomposition = Collator.NoDecomposition
CollationTest.DoTest(self, cast[RuleBasedCollator](coll), s1, s2, 0)
    coll.Decomposition = Collator.CanonicalDecomposition
CollationTest.DoTest(self, cast[RuleBasedCollator](coll), s1, s2, 0)
proc TestEmptyRule*() =
    var rulez: String = ""
    try:
        var coll: RuleBasedCollator = RuleBasedCollator(rulez)
Logln("rule:" + coll.GetRules)
    except Exception:
Warnln(e.ToString)
proc TestJ815*() =
    var data: String[] = @["aa", "Aa", "ab", "Ab", "ad", "Ad", "ae", "Ae", "æ", "Æ", "af", "Af", "b", "B"]
genericLocaleStarter(CultureInfo("fr"), data)
genericRulesStarter("[backwards 2]&A<<æ/e<<<Æ/E", data)
proc TestJ3087*() =
    var rule: String[] = @["&h<H&CH=Ч", "&CH=Ч"]
    var rbc: RuleBasedCollator = nil
    var iter1: CollationElementIterator
    var iter2: CollationElementIterator
      var i: int = 0
      while i < rule.Length:
          try:
              rbc = RuleBasedCollator(rule[i])
          except Exception:
Warnln(e.ToString)
              continue
          iter1 = rbc.GetCollationElementIterator("CH")
          iter2 = rbc.GetCollationElementIterator("Ч")
          var ce1: int = CollationElementIterator.Ignorable
          var ce2: int = CollationElementIterator.Ignorable
          var mask: int = ~0
          while ce1 != CollationElementIterator.NullOrder && ce2 != CollationElementIterator.NullOrder:
              ce1 = iter1.Next
              ce2 = iter2.Next
              if ce1 & mask != ce2 & mask:
Errln("Error generating RuleBasedCollator with the rule " + rule[i])
Errln("CH != \u0427")
              mask = ~192
++i
proc TestUpperCaseFirst*() =
    var data: String[] = @["I", "i", "Y", "y"]
genericLocaleStarter(CultureInfo("da"), data)
proc TestBefore*() =
    var data: String[] = @["ā", "á", "ǎ", "à", "A", "ē", "é", "ě", "è", "E", "ī", "í", "ǐ", "ì", "I", "ō", "ó", "ǒ", "ò", "O", "ū", "ú", "ǔ", "ù", "U", "ǖ", "ǘ", "ǚ", "ǜ", "ü"]
genericRulesStarter("&[before 1]a<ā<á<ǎ<à" + "&[before 1]e<ē<é<ě<è" + "&[before 1]i<ī<í<ǐ<ì" + "&[before 1]o<ō<ó<ǒ<ò" + "&[before 1]u<ū<ú<ǔ<ù" + "&u<ǖ<ǘ<ǚ<ǜ<ü", data)
proc TestHangulTailoring*() =
    var koreanData: String[] = @["가", "伽", "佳", "假", "價", "加", "可", "呵", "哥", "嘉", "嫁", "家", "暇", "架", "枷", "柯", "歌", "珂", "痂", "稼", "苛", "茄", "街", "袈", "訶", "賈", "跏", "軻", "迦", "駕", "仮", "傢", "咖", "哿", "坷", "宊", "斝", "榎", "檟", "珈", "笳", "耞", "舸", "葭", "謌"]
    var rules: String = "&가 <<< 伽 <<< 佳 <<< 假 <<< 價 <<< 加 <<< 可 <<< 呵 " + "<<< 哥 <<< 嘉 <<< 嫁 <<< 家 <<< 暇 <<< 架 <<< 枷 <<< 柯 " + "<<< 歌 <<< 珂 <<< 痂 <<< 稼 <<< 苛 <<< 茄 <<< 街 <<< 袈 " + "<<< 訶 <<< 賈 <<< 跏 <<< 軻 <<< 迦 <<< 駕 " + "<<< 仮 <<< 傢 <<< 咖 <<< 哿 <<< 坷 <<< 宊 <<< 斝 <<< 榎 " + "<<< 檟 <<< 珈 <<< 笳 <<< 耞 <<< 舸 <<< 葭 <<< 謌"
    var rlz: String = rules
    var coll: Collator = nil
    try:
        coll = RuleBasedCollator(rlz)
    except Exception:
Warnln("Unable to open collator with rules" + rules)
        return
genericOrderingTest(coll, koreanData)
proc TestIncrementalNormalize*() =
    var coll: Collator = nil
      try:
          coll = Collator.GetInstance(CultureInfo("en-US"))
      except Exception:
Warnln("Cannot get default instance!")
          return
      var baseA: char = cast[char](65)
      var ccMix: char[] = @[cast[char](790), cast[char](801), cast[char](768)]
      var sLen: int
      var i: int
      var strA: StringBuffer = StringBuffer
      var strB: StringBuffer = StringBuffer
      coll.Decomposition = Collator.CanonicalDecomposition
        sLen = 1000
        while sLen < 1001:
strA.Delete(0, strA.Length - 0)
strA.Append(baseA)
strB.Delete(0, strB.Length - 0)
strB.Append(baseA)
              i = 1
              while i < sLen:
strA.Append(ccMix[i % 3])
strB.Insert(1, ccMix[i % 3])
++i
            coll.Strength = Collator.Tertiary
CollationTest.DoTest(self, cast[RuleBasedCollator](coll), strA.ToString, strB.ToString, 0)
            coll.Strength = Collator.Identical
CollationTest.DoTest(self, cast[RuleBasedCollator](coll), strA.ToString, strB.ToString, 0)
++sLen
      var strA: String = "AÀ̖"
      var strB: String = "AÀ̖"
      coll.Strength = Collator.Tertiary
CollationTest.DoTest(self, cast[RuleBasedCollator](coll), strA, strB, 0)
      var strA: String = "AÀ̖𐀁"
      var strB: String = "AÀ̖𐀀"
      coll.Strength = Collator.Tertiary
CollationTest.DoTest(self, cast[RuleBasedCollator](coll), strA, strB, 1)
proc TestContraction*() =
    var testrules: String[] = @["&A = AB / B", "&A = A\u0306/\u0306", "&c = ch / h"]
    var testdata: String[] = @["AB", "AB", "Ă", "ch"]
    var testdata2: String[] = @["cg", "ch", "cl"]
    var coll: RuleBasedCollator = nil
      var i: int = 0
      while i < testrules.Length:
          var iter1: CollationElementIterator = nil
          var j: int = 0
          var rule: String = testrules[i]
          try:
              coll = RuleBasedCollator(rule)
          except Exception:
Warnln("Collator creation failed " + testrules[i])
              return
          try:
              iter1 = coll.GetCollationElementIterator(testdata[i])
          except Exception:
Errln("Collation iterator creation failed
")
              return
          while j < 2:
              var iter2: CollationElementIterator
              var ce: int
              try:
                  iter2 = coll.GetCollationElementIterator(testdata[i][j] + "")
              except Exception:
Errln("Collation iterator creation failed
")
                  return
              ce = iter2.Next
              while ce != CollationElementIterator.NullOrder:
                  if iter1.Next != ce:
Errln("Collation elements in contraction split does not match
")
                      return
                  ce = iter2.Next
++j
          if iter1.Next != CollationElementIterator.NullOrder:
Errln("Collation elements not exhausted
")
              return
++i
      var rule: String = "& a < b < c < ch < d & c = ch / h"
      try:
          coll = RuleBasedCollator(rule)
      except Exception:
Errln("cannot create rulebased collator")
          return
      if coll.Compare(testdata2[0], testdata2[1]) != -1:
Errln("Expected " + testdata2[0] + " < " + testdata2[1])
          return
      if coll.Compare(testdata2[1], testdata2[2]) != -1:
Errln("Expected " + testdata2[1] + " < " + testdata2[2])
          return
proc TestExpansion*() =
    var testrules: String[] = @["&J << K / B << M"]
    var testdata: String[] = @["JA", "MA", "KA", "KC", "JC", "MC"]
    var coll: Collator
      var i: int = 0
      while i < testrules.Length:
          var rule: String = testrules[i]
          try:
              coll = RuleBasedCollator(rule)
          except Exception:
Warnln("Collator creation failed " + testrules[i])
              return
            var j: int = 0
            while j < 5:
CollationTest.DoTest(self, cast[RuleBasedCollator](coll), testdata[j], testdata[j + 1], -1)
++j
++i
proc TestContractionEndCompare*() =
    var rules: String = "&b=ch"
    var src: String = "bec"
    var tgt: String = "bech"
    var coll: Collator = nil
    try:
        coll = RuleBasedCollator(rules)
    except Exception:
Warnln("Collator creation failed " + rules)
        return
CollationTest.DoTest(self, cast[RuleBasedCollator](coll), src, tgt, 1)
proc TestLocaleRuleBasedCollators*() =
    if TestFmwk.GetExhaustiveness < 5:
        return
    var locale: CultureInfo[] = Collator.GetCultures(UCultureTypes.AllCultures)
    var prevrule: String = nil
      var i: int = 0
      while i < locale.Length:
          var l: CultureInfo = locale[i]
          try:
              var rb: ICUResourceBundle = cast[ICUResourceBundle](UResourceBundle.GetBundleInstance(ICUData.IcuCollationBaseName, l))
              var collkey: String = rb.GetStringWithFallback("collations/default")
              var elements: ICUResourceBundle = rb.GetWithFallback("collations/" + collkey)
              if elements == nil:
                  continue
              var rule: String = nil
              rule = elements.GetString("Sequence")
              var col1: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(l))
              if !rule.Equals(col1.GetRules):
Errln("Rules should be the same in the RuleBasedCollator and Locale")
              if rule != nil && rule.Length > 0 && !rule.Equals(prevrule):
                  var col2: RuleBasedCollator = RuleBasedCollator(rule)
                  if !col1.Equals(col2):
Errln("Error creating RuleBasedCollator from " + "locale rules for " + l.ToString)
              prevrule = rule
          except Exception:
Warnln("Error retrieving resource bundle for testing: " + e.ToString)
++i
proc TestOptimize*() =
    var rules: String[] = @["[optimize [\uAC00-\uD7FF]]"]
    var data: String[][] = @[@["a", "b"]]
    var i: int = 0
      i = 0
      while i < rules.Length:
genericRulesStarter(rules[i], data[i])
++i
proc TestIdenticalCompare*() =
    try:
        var coll: RuleBasedCollator = RuleBasedCollator("& 𐀀 = 𐀁")
        var strA: String = "AÀ̖𐀁"
        var strB: String = "AÀ̖𐀀"
        coll.Strength = Collator.Identical
CollationTest.DoTest(self, coll, strA, strB, 1)
    except Exception:
Warnln(e.ToString)
proc TestMergeSortKeys*() =
    var cases: String[] = @["abc", "abcd", "abcde"]
    var prefix: String = "foo"
    var suffix: String = "egg"
    var mergedPrefixKeys: CollationKey[] = seq[CollationKey]
    var mergedSuffixKeys: CollationKey[] = seq[CollationKey]
    var coll: Collator = Collator.GetInstance(CultureInfo("en"))
genericLocaleStarter(CultureInfo("en"), cases)
    var strength: CollationStrength = Collator.Primary
    while strength <= Collator.Identical:
        coll.Strength = strength
        var prefixKey: CollationKey = coll.GetCollationKey(prefix)
        var suffixKey: CollationKey = coll.GetCollationKey(suffix)
          var i: int = 0
          while i < cases.Length:
              var key: CollationKey = coll.GetCollationKey(cases[i])
              mergedPrefixKeys[i] = prefixKey.Merge(key)
              mergedSuffixKeys[i] = suffixKey.Merge(key)
              if mergedPrefixKeys[i].SourceString != nil || mergedSuffixKeys[i].SourceString != nil:
Errln("Merged source string error: expected null")
              if i > 0:
                  if mergedPrefixKeys[i - 1].CompareTo(mergedPrefixKeys[i]) >= 0:
Errln("Error while comparing prefixed keys @ strength " + strength)
Errln(CollationTest.Prettify(mergedPrefixKeys[i - 1]))
Errln(CollationTest.Prettify(mergedPrefixKeys[i]))
                  if mergedSuffixKeys[i - 1].CompareTo(mergedSuffixKeys[i]) >= 0:
Errln("Error while comparing suffixed keys @ strength " + strength)
Errln(CollationTest.Prettify(mergedSuffixKeys[i - 1]))
Errln(CollationTest.Prettify(mergedSuffixKeys[i]))
++i
        if strength == Collator.Quaternary:
            strength = Collator.Identical
        else:
++strength
proc TestVariableTop*() =
    var rules: String = "& ' ' < b < c < de < fg & hi = j"
    try:
        var coll: RuleBasedCollator = RuleBasedCollator(rules)
        var tokens: String[] = @[" ", "b", "c", "de", "fg", "hi", "j", "ab"]
        coll.IsAlternateHandlingShifted = true
          var i: int = 0
          while i < tokens.Length:
              var varTopOriginal: int = coll.VariableTop
              try:
                  var varTop: int = coll.SetVariableTop(tokens[i])
                  if i > 4:
Errln("Token " + tokens[i] + " expected to fail")
                  if varTop != coll.VariableTop:
Errln("Error setting and getting variable top")
                  var key1: CollationKey = coll.GetCollationKey(tokens[i])
                    var j: int = 0
                    while j < i:
                        var key2: CollationKey = coll.GetCollationKey(tokens[j])
                        if key2.CompareTo(key1) < 0:
Errln("Setting variable top shouldn't change the comparison sequence")
                        var sortorder: byte[] = key2.ToByteArray
                        if sortorder.Length > 0 && key2.ToByteArray[0] > 1:
Errln("Primary sort order should be 0")
++j
              except Exception:
                  var iter: CollationElementIterator = coll.GetCollationElementIterator(tokens[i])
iter.Next
                  var ce2: int = iter.Next
                  if ce2 == CollationElementIterator.NullOrder:
Errln("Token " + tokens[i] + " not expected to fail")
                  if coll.VariableTop != varTopOriginal:
Errln("When exception is thrown variable top should " + "not be changed")
              coll.VariableTop = varTopOriginal
              if varTopOriginal != coll.VariableTop:
Errln("Couldn't restore old variable top
")
++i
        try:
coll.SetVariableTop("")
Errln("Empty string should throw an IllegalArgumentException")
        except ArgumentException:
Logln("PASS: Empty string failed as expected")
        try:
coll.SetVariableTop(nil)
Errln("Null string should throw an IllegalArgumentException")
        except ArgumentException:
Logln("PASS: null string failed as expected")
    except Exception:
Warnln("Error creating RuleBasedCollator")
proc TestVariableTopSetting*() =
      var varTopOriginal: int = 0
      var varTop1: int
      var varTop2: int
    var coll: Collator = Collator.GetInstance(UCultureInfo.InvariantCulture)
    var empty: String = ""
    var space: String = " "
    var dot: String = "."
    var degree: String = "°"
    var dollar: String = "$"
    var zero: String = "0"
    varTopOriginal = coll.VariableTop
Logln(String.Format("coll.getVariableTop(root) -> %08x", varTopOriginal))
    cast[RuleBasedCollator](coll).IsAlternateHandlingShifted = true
    varTop1 = coll.SetVariableTop(space)
    varTop2 = coll.VariableTop
Logln(String.Format("coll.setVariableTop(space) -> {0:x8}", varTop1))
    if varTop1 != varTop2 || !coll.Equals(empty, space) || coll.Equals(empty, dot) || coll.Equals(empty, degree) || coll.Equals(empty, dollar) || coll.Equals(empty, zero) || coll.Compare(space, dot) >= 0:
Errln("coll.setVariableTop(space) did not work")
    varTop1 = coll.SetVariableTop(dot)
    varTop2 = coll.VariableTop
Logln(String.Format("coll.setVariableTop(dot) -> {0:x8}", varTop1))
    if varTop1 != varTop2 || !coll.Equals(empty, space) || !coll.Equals(empty, dot) || coll.Equals(empty, degree) || coll.Equals(empty, dollar) || coll.Equals(empty, zero) || coll.Compare(dot, degree) >= 0:
Errln("coll.setVariableTop(dot) did not work")
    varTop1 = coll.SetVariableTop(degree)
    varTop2 = coll.VariableTop
Logln(String.Format("coll.setVariableTop(degree) -> %08x", varTop1))
    if varTop1 != varTop2 || !coll.Equals(empty, space) || !coll.Equals(empty, dot) || !coll.Equals(empty, degree) || coll.Equals(empty, dollar) || coll.Equals(empty, zero) || coll.Compare(degree, dollar) >= 0:
Errln("coll.setVariableTop(degree) did not work")
    varTop1 = coll.SetVariableTop(dollar)
    varTop2 = coll.VariableTop
Logln(String.Format("coll.setVariableTop(dollar) -> {0:x8}", varTop1))
    if varTop1 != varTop2 || !coll.Equals(empty, space) || !coll.Equals(empty, dot) || !coll.Equals(empty, degree) || !coll.Equals(empty, dollar) || coll.Equals(empty, zero) || coll.Compare(dollar, zero) >= 0:
Errln("coll.setVariableTop(dollar) did not work")
Logln("Testing setting variable top to contractions")
    try:
coll.SetVariableTop("@P")
Errln("Invalid contraction succeded in setting variable top!")
    except Exception:

Logln("Test restoring variable top")
    coll.VariableTop = varTopOriginal
    if varTopOriginal != coll.VariableTop:
Errln("Couldn't restore old variable top")
proc TestMaxVariable*() =
      var oldMax: int
      var max: int
    var empty: String = ""
    var space: String = " "
    var dot: String = "."
    var degree: String = "°"
    var dollar: String = "$"
    var zero: String = "0"
    var coll: Collator = Collator.GetInstance(UCultureInfo.InvariantCulture)
    oldMax = coll.MaxVariable
Logln(String.Format("coll.getMaxVariable(root) -> {0:x4}", cast[int](oldMax)))
    cast[RuleBasedCollator](coll).IsAlternateHandlingShifted = true
    coll.MaxVariable = ReorderCodes.Space
    max = coll.MaxVariable
Logln(String.Format("coll.setMaxVariable(space) -> {0:x4}", cast[int](max)))
    if max != ReorderCodes.Space || !coll.Equals(empty, space) || coll.Equals(empty, dot) || coll.Equals(empty, degree) || coll.Equals(empty, dollar) || coll.Equals(empty, zero) || coll.Compare(space, dot) >= 0:
Errln("coll.setMaxVariable(space) did not work")
    coll.MaxVariable = ReorderCodes.Punctuation
    max = coll.MaxVariable
Logln(String.Format("coll.setMaxVariable(punctuation) -> {0:x4}", cast[int](max)))
    if max != ReorderCodes.Punctuation || !coll.Equals(empty, space) || !coll.Equals(empty, dot) || coll.Equals(empty, degree) || coll.Equals(empty, dollar) || coll.Equals(empty, zero) || coll.Compare(dot, degree) >= 0:
Errln("coll.setMaxVariable(punctuation) did not work")
    coll.MaxVariable = ReorderCodes.Symbol
    max = coll.MaxVariable
Logln(String.Format("coll.setMaxVariable(symbol) -> {0:x4}", cast[int](max)))
    if max != ReorderCodes.Symbol || !coll.Equals(empty, space) || !coll.Equals(empty, dot) || !coll.Equals(empty, degree) || coll.Equals(empty, dollar) || coll.Equals(empty, zero) || coll.Compare(degree, dollar) >= 0:
Errln("coll.setMaxVariable(symbol) did not work")
    coll.MaxVariable = ReorderCodes.Currency
    max = coll.MaxVariable
Logln(String.Format("coll.setMaxVariable(currency) -> {0:x4}", cast[int](max)))
    if max != ReorderCodes.Currency || !coll.Equals(empty, space) || !coll.Equals(empty, dot) || !coll.Equals(empty, degree) || !coll.Equals(empty, dollar) || coll.Equals(empty, zero) || coll.Compare(dollar, zero) >= 0:
Errln("coll.setMaxVariable(currency) did not work")
Logln("Test restoring maxVariable")
    coll.MaxVariable = oldMax
    if oldMax != coll.MaxVariable:
Errln("Couldn't restore old maxVariable")
proc TestUCARules*() =
    try:
        var coll: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo.InvariantCulture))
        var rule: String = coll.GetRules(false)
        if !rule.Equals(""):
Errln("Empty rule string should have empty rules " + rule)
        rule = coll.GetRules(true)
        if rule.Equals(""):
Errln("UCA rule string should not be empty")
        coll = RuleBasedCollator(rule)
    except Exception:
Warnln(e.ToString)
proc TestShifted*() =
    var collator: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance)
    collator.Strength = Collator.Primary
    collator.IsAlternateHandlingShifted = true
CollationTest.DoTest(self, collator, " a", "a", 0)
CollationTest.DoTest(self, collator, "a", "a ", 0)
proc TestNumericCollation*() =
    var basicTestStrings: String[] = @["hello1", "hello2", "hello123456"]
    var preZeroTestStrings: String[] = @["avery1", "avery01", "avery001", "avery0001"]
    var thirtyTwoBitNumericStrings: String[] = @["avery42949672960", "avery42949672961", "avery42949672962", "avery429496729610"]
    var supplementaryDigits: String[] = @["𝟎", "𝟏", "𝟐", "𝟑", "𝟏𝟎", "𝟏𝟏", "𝟏𝟐", "𝟐𝟎", "𝟐𝟏", "𝟐𝟐"]
    var foreignDigits: String[] = @["١", "٢", "٣", "١٠", "١٢", "١٣", "٢٠", "٢٢", "٢٣", "٣٠", "٣٢", "٣٣"]
    var lastDigitDifferent: String[] = @["2004", "2005", "110005", "110006", "11005", "11006", "100000000005", "100000000006"]
    var coll: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en")))
    var att: String[] = @["NumericCollation"]
    var val: object[] = @[true]
genericLocaleStarterWithOptions(CultureInfo("en"), basicTestStrings, att, val)
genericLocaleStarterWithOptions(CultureInfo("en"), thirtyTwoBitNumericStrings, att, val)
genericLocaleStarterWithOptions(CultureInfo("en"), foreignDigits, att, val)
genericLocaleStarterWithOptions(CultureInfo("en"), supplementaryDigits, att, val)
    coll.IsNumericCollation = true
      var i: int = 0
      while i < preZeroTestStrings.Length - 1:
            var j: int = i + 1
            while j < preZeroTestStrings.Length:
CollationTest.DoTest(self, coll, preZeroTestStrings[i], preZeroTestStrings[j], 0)
++j
++i
      var i: int = 0
      while i < lastDigitDifferent.Length - 1:
CollationTest.DoTest(self, coll, lastDigitDifferent[i], lastDigitDifferent[i + 1], -1)
          i = i + 2
assertTrue("The Numeric Collation setting is on", coll.IsNumericCollation)
coll.SetNumericCollationToDefault
Logln("After set Numeric to default, the setting is: " + coll.IsNumericCollation)
proc Test3249*() =
    var rule: String = "&x < a &z < a"
    try:
        var coll: RuleBasedCollator = RuleBasedCollator(rule)
        if coll != nil:
Logln("Collator did not throw an exception")
    except Exception:
Warnln("Error creating RuleBasedCollator with " + rule + " failed")
proc TestTibetanConformance*() =
    var test: String[] = @["ྲཱ֑a", "ྲཱa"]
    try:
        var coll: Collator = Collator.GetInstance
        coll.Decomposition = Collator.CanonicalDecomposition
        if coll.Compare(test[0], test[1]) != 0:
Errln("Tibetan comparison error")
CollationTest.DoTest(self, cast[RuleBasedCollator](coll), test[0], test[1], 0)
    except Exception:
Warnln("Error creating UCA collator")
proc TestJ3347*() =
    try:
        var coll: Collator = Collator.GetInstance(CultureInfo("fr"))
        cast[RuleBasedCollator](coll).IsAlternateHandlingShifted = true
        if coll.Compare("6", "!6") != 0:
Errln("Jitterbug 3347 failed")
    except Exception:
Warnln("Error creating UCA collator")
proc TestPinyinProblem*() =
    var test: String[] = @["乖乖睡", "乖孩子"]
genericLocaleStarter(CultureInfo("zh-Hans"), test)
proc TestBeforePinyin*() =
    var rules: String = "&[before 2]A << ā  <<< Ā << á <<< Á << ǎ <<< Ǎ << à <<< À" + "&[before 2]e << ē <<< Ē << é <<< É << ě <<< Ě << è <<< È" + "&[before 2] i << ī <<< Ī << í <<< Í << ǐ <<< Ǐ << ì <<< Ì" + "&[before 2] o << ō <<< Ō << ó <<< Ó << ǒ <<< Ǒ << ò <<< Ò" + "&[before 2]u << ū <<< Ū << ú <<< Ú << ǔ <<< Ǔ << ù <<< Ù" + "&U << ǖ <<< Ǖ << ǘ <<< Ǘ << ǚ <<< Ǚ << ǜ <<< Ǜ << ü"
    var test: String[] = @["lā", "la", "lān", "lan ", "lē", "le", "lēn", "len"]
    var test2: String[] = @["xā", "xĀ", "Xā", "XĀ", "xá", "xÁ", "Xá", "XÁ", "xǎ", "xǍ", "Xǎ", "XǍ", "xà", "xÀ", "Xà", "XÀ", "xa", "xA", "Xa", "XA", "xāx", "xĀx", "xáx", "xÁx", "xǎx", "xǍx", "xàx", "xÀx", "xax", "xAx"]
genericRulesStarter(rules, test)
genericLocaleStarter(CultureInfo("zh"), test)
genericRulesStarter(rules, test2)
genericLocaleStarter(CultureInfo("zh"), test2)
proc TestUpperFirstQuaternary*() =
    var tests: String[] = @["B", "b", "Bb", "bB"]
    var att: String[] = @["strength", "UpperFirst"]
    var attVals: Object[] = @[int?(cast[int](Collator.Quaternary)), true]
genericLocaleStarterWithOptions(CultureInfo.InvariantCulture, tests, att, attVals)
proc TestJ4960*() =
    var tests: String[] = @["\u00e2T", "aT"]
    var att: String[] = @["strength", "CaseLevel"]
    var attVals: Object[] = @[int?(cast[int](Collator.Primary)), true]
    var tests2: String[] = @["a", "A"]
    var rule: String = "&[first tertiary ignorable]=A=a"
    var att2: String[] = @["CaseLevel"]
    var attVals2: Object[] = @[true]
genericLocaleStarterWithOptionsAndResult(CultureInfo.InvariantCulture, tests, att, attVals, 0)
genericLocaleStarterWithOptions(CultureInfo.InvariantCulture, tests2, att, attVals)
genericRulesStarterWithOptionsAndResult(rule, tests2, att2, attVals2, 0)
proc TestJB5298*() =
    var locales: UCultureInfo[] = Collator.GetUCultures(UCultureTypes.AllCultures)
Logln("Number of collator locales returned : " + locales.Length)
    var keywords: String[] = Collator.Keywords.ToArray
    if keywords.Length != 1 || !keywords[0].Equals("collation"):
        raise ArgumentException("internal collation error")
    var values: String[] = Collator.GetKeywordValues("collation")
Log("Collator.getKeywordValues returned: ")
      var i: int = 0
      while i < values.Length:
Log(values[i] + ", ")
++i
Logln("")
Logln("Number of collation keyword values returned : " + values.Length)
      var i: int = 0
      while i < values.Length:
          if values[i].StartsWith("private-", StringComparison.Ordinal):
Errln("Collator.getKeywordValues() returns private collation keyword: " + values[i])
++i
    var foundValues = SortedSet<string>(values, StringComparer.Ordinal)
      var i: int = 0
      while i < locales.Length:
            var j: int = 0
            while j < values.Length:
                var tryLocale: UCultureInfo =                 if values[j].Equals("standard"):
locales[i]
                else:
UCultureInfo(locales[i] + "@collation=" + values[j])
                var canon: UCultureInfo = Collator.GetFunctionalEquivalent("collation", tryLocale)
                if !canon.Equals(tryLocale):
                    continue
                else:
Logln(tryLocale + " : " + canon + ", ")
                var can: String = canon.ToString
                var idx: int = can.IndexOf("@collation=", StringComparison.Ordinal)
                var val: String =                 if idx >= 0:
can.Substring(idx + 11, can.Length - idx + 11)
                else:
""
                if val.Length > 0 && !foundValues.Contains(val):
Errln("Unknown collation found " + can)
++j
++i
Logln(" ")
proc TestJ5367*() =
    var test: String[] = @["a", "y"]
    var rules: String = "&Ny << Y &[first secondary ignorable] <<< a"
genericRulesStarter(rules, test)
proc TestVI5913*() =
    var rules: String[] = @["&a < â <<< Â", "&a < ῳ ", "&s < š ", "&x < ae &z < aê"]
    var cases: String[][] = @[@["Ậ", "Ậ", "Ậ", "Ậ"], @["ᾢ", "ᾢ", "ᾢ", "ᾢ", "ᾢ", "ᾢ"], @["ṣ̌", "ṣ̌", "ṣ̌"], @["aệ", "aệ", "aệ"]]
      var i: int = 0
      while i < rules.Length:
          var coll: RuleBasedCollator = nil
          try:
              coll = RuleBasedCollator(rules[i])
          except Exception:
Warnln("Unable to open collator with rules " + rules[i])
Logln("Test case[" + i + "]:")
          var expectingKey: CollationKey = coll.GetCollationKey(cases[i][0])
            var j: int = 1
            while j < cases[i].Length:
                var key: CollationKey = coll.GetCollationKey(cases[i][j])
                if key.CompareTo(expectingKey) != 0:
Errln("Error! Test case[" + i + "]:" + "source:" + key.SourceString)
Errln("expecting:" + CollationTest.Prettify(expectingKey) + "got:" + CollationTest.Prettify(key))
Logln("   Key:" + CollationTest.Prettify(key))
++j
++i
    var vi_vi: RuleBasedCollator = nil
    try:
        vi_vi = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("vi")))
Logln("VI sort:")
        var expectingKey: CollationKey = vi_vi.GetCollationKey(cases[0][0])
          var j: int = 1
          while j < cases[0].Length:
              var key: CollationKey = vi_vi.GetCollationKey(cases[0][j])
              if key.CompareTo(expectingKey) != 0:
Logln("Error!! in Vietnese sort - source:" + key.SourceString)
Logln("expecting:" + CollationTest.Prettify(expectingKey) + "got:" + CollationTest.Prettify(key))
Logln("   Key:" + CollationTest.Prettify(key))
++j
    except Exception:
Warnln("Error creating Vietnese collator")
        return
proc Test6179*() =
    var rules: String[] = @["&[last primary ignorable]<< a  &[first primary ignorable]<<b ", "&[last secondary ignorable]<<< a &[first secondary ignorable]<<<b"]
    var firstPrimIgn: String = "̲"
    var lastPrimIgn: String = "𐇽"
    var firstVariable: String = "	"
    var secIgnKey: byte[] = @[1, 1, 4, 0]
    var i: int = 0
      var coll: RuleBasedCollator = nil
      try:
          coll = RuleBasedCollator(rules[i])
      except Exception:
Warnln("Unable to open collator with rules " + rules[i] + ": " + e)
          return
Logln("Test rule[" + i + "]" + rules[i])
      var keyA: CollationKey = coll.GetCollationKey("a")
Logln("Key for "a":" + CollationTest.Prettify(keyA))
      if keyA.CompareTo(coll.GetCollationKey(lastPrimIgn)) <= 0:
          var key: CollationKey = coll.GetCollationKey(lastPrimIgn)
Logln("Collation key for 0xD800 0xDDFD: " + CollationTest.Prettify(key))
Errln("Error! String "a" must be greater than 𐇽 -" + "[Last Primary Ignorable]")
      if keyA.CompareTo(coll.GetCollationKey(firstVariable)) >= 0:
          var key: CollationKey = coll.GetCollationKey(firstVariable)
Logln("Collation key for 0x0009: " + CollationTest.Prettify(key))
Errln("Error! String "a" must be less than 0x0009 - [First Variable]")
      var keyB: CollationKey = coll.GetCollationKey("b")
Logln("Key for "b":" + CollationTest.Prettify(keyB))
      if keyB.CompareTo(coll.GetCollationKey(firstPrimIgn)) <= 0:
          var key: CollationKey = coll.GetCollationKey(firstPrimIgn)
Logln("Collation key for 0x0332: " + CollationTest.Prettify(key))
Errln("Error! String "b" must be greater than 0x0332 -" + "[First Primary Ignorable]")
      if keyB.CompareTo(coll.GetCollationKey(firstVariable)) >= 0:
          var key: CollationKey = coll.GetCollationKey(firstVariable)
Logln("Collation key for 0x0009: " + CollationTest.Prettify(key))
Errln("Error! String "b" must be less than 0x0009 - [First Variable]")
      i = 1
      var coll: RuleBasedCollator = nil
      try:
          coll = RuleBasedCollator(rules[i])
      except Exception:
Warnln("Unable to open collator with rules " + rules[i])
Logln("Test rule[" + i + "]" + rules[i])
      var keyA: CollationKey = coll.GetCollationKey("a")
Logln("Key for "a":" + CollationTest.Prettify(keyA))
      var keyAInBytes: byte[] = keyA.ToByteArray
        var j: int = 0
        while j < keyAInBytes.Length && j < secIgnKey.Length:
            if keyAInBytes[j] != secIgnKey[j]:
                if cast[char](keyAInBytes[j]) <= cast[char](secIgnKey[j]):
Logln("Error! String "a" must be greater than [Last Secondary Ignorable]")
                break
++j
      if keyA.CompareTo(coll.GetCollationKey(firstVariable)) >= 0:
Errln("Error! String "a" must be less than 0x0009 - [First Variable]")
          var key: CollationKey = coll.GetCollationKey(firstVariable)
Logln("Collation key for 0x0009: " + CollationTest.Prettify(key))
      var keyB: CollationKey = coll.GetCollationKey("b")
Logln("Key for "b":" + CollationTest.Prettify(keyB))
      var keyBInBytes: byte[] = keyB.ToByteArray
        var j: int = 0
        while j < keyBInBytes.Length && j < secIgnKey.Length:
            if keyBInBytes[j] != secIgnKey[j]:
                if cast[char](keyBInBytes[j]) <= cast[char](secIgnKey[j]):
Errln("Error! String "b" must be greater than [Last Secondary Ignorable]")
                break
++j
      if keyB.CompareTo(coll.GetCollationKey(firstVariable)) >= 0:
          var key: CollationKey = coll.GetCollationKey(firstVariable)
Logln("Collation key for 0x0009: " + CollationTest.Prettify(key))
Errln("Error! String "b" must be less than 0x0009 - [First Variable]")
proc TestUCAPrecontext*() =
    var rules: String[] = @["& ·<a ", "& L· << a"]
    var cases: String[] = @["·", "·", "a", "l", "L̲", "l·", "l·", "L·", "la·", "La·"]
    var en: RuleBasedCollator = nil
Logln("EN sort:")
    try:
        en = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en")))
          var j: int = 0
          while j < cases.Length:
              var key: CollationKey = en.GetCollationKey(cases[j])
              if j > 0:
                  var prevKey: CollationKey = en.GetCollationKey(cases[j - 1])
                  if key.CompareTo(prevKey) < 0:
Errln("Error! EN test[" + j + "]:source:" + cases[j] + " is not >= previous test string.")
Logln("String:" + cases[j] + "   Key:" + CollationTest.Prettify(key))
++j
    except Exception:
Warnln("Error creating English collator")
        return
    var ja: RuleBasedCollator = nil
Logln("JA sort:")
    try:
        ja = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("ja")))
          var j: int = 0
          while j < cases.Length:
              var key: CollationKey = ja.GetCollationKey(cases[j])
              if j > 0:
                  var prevKey: CollationKey = ja.GetCollationKey(cases[j - 1])
                  if key.CompareTo(prevKey) < 0:
Errln("Error! JA test[" + j + "]:source:" + cases[j] + " is not >= previous test string.")
Logln("String:" + cases[j] + "   Key:" + CollationTest.Prettify(key))
++j
    except Exception:
Warnln("Error creating Japanese collator")
        return
      var i: int = 0
      while i < rules.Length:
          var coll: RuleBasedCollator = nil
Logln("Tailoring rule:" + rules[i])
          try:
              coll = RuleBasedCollator(rules[i])
          except Exception:
Warnln("Unable to open collator with rules " + rules[i])
              continue
            var j: int = 0
            while j < cases.Length:
                var key: CollationKey = coll.GetCollationKey(cases[j])
                if j > 0:
                    var prevKey: CollationKey = coll.GetCollationKey(cases[j - 1])
                    if i == 1 && j == 3:
                        if key.CompareTo(prevKey) > 0:
Errln("Error! Rule:" + rules[i] + " test[" + j + "]:source:" + cases[j] + " is not <= previous test string.")
                    else:
                        if key.CompareTo(prevKey) < 0:
Errln("Error! Rule:" + rules[i] + " test[" + j + "]:source:" + cases[j] + " is not >= previous test string.")
Logln("String:" + cases[j] + "   Key:" + CollationTest.Prettify(key))
++j
++i
type
  OneTestCase = ref object
    m_source_: String
    m_target_: String
    m_result_: int

proc newOneTestCase(source: String, target: String, result: int): OneTestCase =
  m_source_ = source
  m_target_ = target
  m_result_ = result
proc doTestCollation(testCases: seq[OneTestCase], rules: seq[String]) =
    var myCollation: Collator
    for rule in rules:
        try:
            myCollation = RuleBasedCollator(rule)
        except Exception:
Warnln("ERROR: in creation of rule based collator: " + e)
            return
        myCollation.Decomposition = Collator.CanonicalDecomposition
        myCollation.Strength = Collator.Tertiary
        for testCase in testCases:
CollationTest.DoTest(self, cast[RuleBasedCollator](myCollation), testCase.m_source_, testCase.m_target_, testCase.m_result_)
proc TestSameStrengthList*() =
    var rules: String[] = @["&a<b<c<d &b<<k<<l<<m &k<<<x<<<y<<<z &y<f<g<h<e &a=1=2=3", "&a<*bcd &b<<*klm &k<<<*xyz &y<*fghe &a=*123", "&'a'<*bcd &b<<*klm &k<<<*xyz &y<*f'gh'e &a=*123"]
doTestCollation(m_rangeTestCases_, rules)
proc TestSameStrengthListQuoted*() =
    var rules: String[] = @["&'a'<*bcd &b<<*klm &k<<<*xyz &y<*f'gh'e &a=1=2=3", "&'a'<*b'c'd &b<<*klm &k<<<*xyz &'y'<*fgh'e' " + "&a=*'123'", "&'a'<*'b'c'd' &b<<*klm &k<<<*xyz  &y<*fghe " + "&a=*'123'"]
doTestCollation(m_rangeTestCases_, rules)
proc TestSameStrengthListQwerty*() =
    var rules: String[] = @["&q<w<e<r &w<<t<<y<<u &t<<<i<<<o<<<p &o=a=s=d", "&q<*wer &w<<*tyu &t<<<*iop &o=*asd"]
doTestCollation(m_qwertCollationTestCases_, rules)
proc TestSameStrengthListWithSupplementalCharacters*() =
    var rules: String[] = @["&一<￻<'𐀀'<'𐀁'<'𐀂' " + "&'𐀀'<<'𠀁'<<'𠀂'<<'𠀂'  " + "&'𠀁'='𰀁'='񀀁'='񀀂'", "&一<*'￻𐀀𐀁𐀂' " + "&'𐀀'<<*'𠀁𠀂𠀃'  " + "&'𠀁'=*'𰀁𰀂𰀃񀀁' "]
doTestCollation(m_rangeTestCasesSupplemental_, rules)
proc TestSameStrengthListRanges*() =
    var rules: String[] = @["&a<*b-d &b<<*k-m &k<<<*x-z &y<*f-he &a=*1-3", "&'a'<*'b'-'d' &b<<*klm &k<<<*xyz " + "&'y'<*'f'-'he' &a=*123", "&'a'<*'b'-'d' " + "&b<<*'k'-m &k<<<*x-'z' " + "&'y'<*'f'-h'e' &a=*'123'"]
doTestCollation(m_rangeTestCases_, rules)
proc TestSameStrengthListRangesWithSupplementalCharacters*() =
    var rules: String[] = @["&一<*'￻'𐀀-'𐀂' " + "&'𐀀'<<*'𠀁'-'𠀃'  " + "&'𠀁'=*'𰀁'-'𰀃񀀁' "]
doTestCollation(m_rangeTestCasesSupplemental_, rules)
proc TestSpecialCharacters*() =
    var rules: String[] = @["&';'<'+'<','<'-'<'&'<'*'", "&';'<*'+,-&*'", "&';'<*'+'-'-&*'", "&';'<'+'<','<'-'<'&'<'*'", "&';'<*'+,-&*'", "&';'<*'+,-&*'", "&';'<*'+'-'-&*'", "&';'<*'+'-'-&*'"]
    var testCases: OneTestCase[] = @[OneTestCase(";", "+", -1), OneTestCase("+", ",", -1), OneTestCase(",", "-", -1), OneTestCase("-", "&", -1)]
doTestCollation(testCases, rules)
proc TestInvalidListsAndRanges*() =
    var invalidRules: String[] = @["&一<￻-'𐀂'", "&a<*-c", "&a<*b-", "&a<*b-g-l", "&a<*k-b"]
    for rule in invalidRules:
        try:
            var myCollation: Collator = RuleBasedCollator(rule)
Warnln("ERROR: Creation of collator didn't fail for " + rule + " when it should.")
CollationTest.DoTest(self, cast[RuleBasedCollator](myCollation), "x", "y", -1)
        except Exception:
            continue
        raise ArgumentException("ERROR: Invalid collator with rule " + rule + " worked fine.")
proc TestQuoteAndSpace*() =
    var rules: String[] = @["&';'<'+'<','<'-'<'&'<''<'*'<' '", "&';'<*'+,-&''''* '", "&';'<*'+'-'-&''''* '"]
    var testCases: OneTestCase[] = @[OneTestCase(";", "+", -1), OneTestCase("+", ",", -1), OneTestCase(",", "-", -1), OneTestCase("-", "&", -1), OneTestCase("&", "'", -1), OneTestCase("'", "*", -1)]
doTestCollation(testCases, rules)
proc TestCollationKeyEquals*() =
    var ck: CollationKey = CollationKey("", cast[byte[]](nil))
    if ck.Equals(Object):
Errln("CollationKey.Equals() was not suppose to return false " + "since it is comparing to a non Collation Key object.")
    if ck.Equals(""):
Errln("CollationKey.Equals() was not suppose to return false " + "since it is comparing to a non Collation Key object.")
    if ck.Equals(0):
Errln("CollationKey.Equals() was not suppose to return false " + "since it is comparing to a non Collation Key object.")
    if ck.Equals(0.0):
Errln("CollationKey.Equals() was not suppose to return false " + "since it is comparing to a non Collation Key object.")
    if ck.Equals(cast[CollationKey](nil)):
Errln("CollationKey.Equals() was not suppose to return false " + "since it is comparing to a null Collation Key object.")
proc TestCollationKeyHashCode*() =
    var ck: CollationKey = CollationKey("", cast[byte[]](nil))
    if ck.GetHashCode != 1:
Errln("CollationKey.hashCode() was suppose to return 1 " + "when m_key is null due a null parameter in the " + "constructor.")
proc TestGetBound*() =
    var ck: CollationKey = CollationKey("", cast[byte[]](nil))
    try:
ck.GetBound(cast[CollationKeyBoundMode](Enum.GetNames(type(CollationKeyBoundMode)).Length), cast[CollationStrength](-1))
Errln("CollationKey.getBound(int,int) was suppose to return an " + "exception for an invalid boundType value.")
    except Exception:

    var b: byte[] = @[]
    var ck1: CollationKey = CollationKey("", b)
    try:
ck1.GetBound(cast[CollationKeyBoundMode](0), cast[CollationStrength](1))
Errln("CollationKey.getBound(int,int) was suppose to return an " + "exception a value of noOfLevels that exceeds expected.")
    except Exception:

proc TestMerge*() =
    var b: byte[] = @[]
    var ck: CollationKey = CollationKey("", b)
    try:
ck.Merge(nil)
Errln("Collationkey.Merge(CollationKey) was suppose to return " + "an exception for a null parameter.")
    except Exception:

    try:
ck.Merge(ck)
Errln("Collationkey.Merge(CollationKey) was suppose to return " + "an exception for a null parameter.")
    except Exception:

proc TestRawCollationKeyCompareTo*() =
    var rck: RawCollationKey = RawCollationKey
    var b: byte[] = @[cast[byte](10), cast[byte](20)]
    var rck100: RawCollationKey = RawCollationKey(b, 2)
    if rck.CompareTo(rck) != 0:
Errln("RawCollatonKey.compareTo(RawCollationKey) was suppose to return 0 " + "for two idential RawCollationKey objects.")
    if rck.CompareTo(rck100) == 0:
Errln("RawCollatonKey.compareTo(RawCollationKey) was not suppose to return 0 " + "for two different RawCollationKey objects.")
proc TestHungarianTailoring*() =
    var rules: String = "&DZ<dzs<<<Dzs<<<DZS" + "&G<gy<<<Gy<<<GY" + "&L<ly<<<Ly<<<LY" + "&N<ny<<<Ny<<<NY" + "&S<sz<<<Sz<<<SZ" + "&T<ty<<<Ty<<<TY" + "&Z<zs<<<Zs<<<ZS" + "&O<ö<<<Ö<<ő<<<Ő" + "&U<ü<<<Ü<<ű<<<ű" + "&cs<<<ccs/cs" + "&Cs<<<Ccs/cs" + "&CS<<<CCS/CS" + "&dz<<<ddz/dz" + "&Dz<<<Ddz/dz" + "&DZ<<<DDZ/DZ" + "&dzs<<<ddzs/dzs" + "&Dzs<<<Ddzs/dzs" + "&DZS<<<DDZS/DZS" + "&gy<<<ggy/gy" + "&Gy<<<Ggy/gy" + "&GY<<<GGY/GY"
    var coll: RuleBasedCollator
    try:
        var str1: String = "ggy"
        var str2: String = "GGY"
        coll = RuleBasedCollator(rules)
        if coll.Compare("ggy", "GGY") >= 0:
Errln("TestHungarianTailoring.compare(" + str1 + "," + str2 + ") was suppose to return -1 ")
        var sortKey1: CollationKey = coll.GetCollationKey(str1)
        var sortKey2: CollationKey = coll.GetCollationKey(str2)
        if sortKey1.CompareTo(sortKey2) >= 0:
Errln("TestHungarianTailoring getCollationKey("" + str1 + "") was suppose " + "less than getCollationKey("" + str2 + "").")
Errln("  getCollationKey("ggy"):" + CollationTest.Prettify(sortKey1) + "  getCollationKey("GGY"):" + CollationTest.Prettify(sortKey2))
        var iter1: CollationElementIterator = coll.GetCollationElementIterator(str1)
        var iter2: CollationElementIterator = coll.GetCollationElementIterator(str2)
          var ce1: int
          var ce2: int
        while         ce1 = iter1.Next != CollationElementIterator.NullOrder &&         ce2 = iter2.Next != CollationElementIterator.NullOrder:
            if ce1 > ce2:
Errln("TestHungarianTailoring.CollationElementIterator(" + str1 + "," + str2 + ") was suppose to return -1 ")
    except Exception:
e.PrintStackTrace
proc TestImport*() =
    try:
        var vicoll: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(UCultureInfo("vi")))
        var escoll: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(UCultureInfo("es")))
        var viescoll: RuleBasedCollator = RuleBasedCollator(vicoll.GetRules + escoll.GetRules)
        var importviescoll: RuleBasedCollator = RuleBasedCollator("[import vi][import es]")
        var tailoredSet: UnicodeSet = viescoll.GetTailoredSet
        var importTailoredSet: UnicodeSet = importviescoll.GetTailoredSet
        if !tailoredSet.Equals(importTailoredSet):
Warnln("Tailored set not equal")
          var it: UnicodeSetIterator = UnicodeSetIterator(tailoredSet)
          while it.Next:
              var t: String = it.GetString
              var sk1: CollationKey = viescoll.GetCollationKey(t)
              var sk2: CollationKey = importviescoll.GetCollationKey(t)
              if !sk1.Equals(sk2):
Warnln("Collation key's not equal for " + t)
    except Exception:
Warnln("ERROR: in creation of rule based collator")
proc TestImportWithType*() =
    try:
        var vicoll: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(UCultureInfo("vi")))
        var decoll: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(UCultureInfo.GetCultureInfoByIetfLanguageTag("de-u-co-phonebk")))
        var videcoll: RuleBasedCollator = RuleBasedCollator(vicoll.GetRules + decoll.GetRules)
        var importvidecoll: RuleBasedCollator = RuleBasedCollator("[import vi][import de-u-co-phonebk]")
        var tailoredSet: UnicodeSet = videcoll.GetTailoredSet
        var importTailoredSet: UnicodeSet = importvidecoll.GetTailoredSet
        if !tailoredSet.Equals(importTailoredSet):
Warnln("Tailored set not equal")
          var it: UnicodeSetIterator = UnicodeSetIterator(tailoredSet)
          while it.Next:
              var t: String = it.GetString
              var sk1: CollationKey = videcoll.GetCollationKey(t)
              var sk2: CollationKey = importvidecoll.GetCollationKey(t)
              if !sk1.Equals(sk2):
Warnln("Collation key's not equal for " + t)
    except Exception:
Warnln("ERROR: in creation of rule based collator")
proc TestBeforeRuleWithScriptReordering*() =
    var rules: String = "&[before 1]α < ก"
    var reorderCodes: int[] = @[UScript.Greek]
    var result: int
    var myCollation: Collator = RuleBasedCollator(rules)
    myCollation.Decomposition = Collator.CanonicalDecomposition
    myCollation.Strength = Collator.Tertiary
    var @base: String = "α"
    var before: String = "ก"
    result = myCollation.Compare(@base, before)
    if !result > 0:
Errln("Collation result not correct before script reordering.")
    var baseKey: CollationKey = myCollation.GetCollationKey(@base)
    var beforeKey: CollationKey = myCollation.GetCollationKey(before)
    var baseKeyBytes: byte[] = baseKey.ToByteArray
    var beforeKeyBytes: byte[] = beforeKey.ToByteArray
    if baseKeyBytes[0] != beforeKeyBytes[0]:
Errln("Different lead byte for sort keys using before rule and before script reordering. base character lead byte = " + baseKeyBytes[0] + ", before character lead byte = " + beforeKeyBytes[0])
myCollation.SetReorderCodes(reorderCodes)
    result = myCollation.Compare(@base, before)
    if !result > 0:
Errln("Collation result not correct after script reordering.")
    baseKey = myCollation.GetCollationKey(@base)
    beforeKey = myCollation.GetCollationKey(before)
    baseKeyBytes = baseKey.ToByteArray
    beforeKeyBytes = beforeKey.ToByteArray
    if baseKeyBytes[0] != beforeKeyBytes[0]:
Errln("Different lead byte for sort keys using before rule and before script reordering. base character lead byte = " + baseKeyBytes[0] + ", before character lead byte = " + beforeKeyBytes[0])
proc TestNonLeadBytesDuringCollationReordering*() =
    var myCollation: Collator
    var baseKey: byte[]
    var reorderKey: byte[]
    var reorderCodes: int[] = @[UScript.Greek]
    var testString: String = "αβγ"
    myCollation = RuleBasedCollator("")
    myCollation.Strength = Collator.Tertiary
    baseKey = myCollation.GetCollationKey(testString).ToByteArray
myCollation.SetReorderCodes(reorderCodes)
    reorderKey = myCollation.GetCollationKey(testString).ToByteArray
    if baseKey.Length != reorderKey.Length:
Errln("Key lengths not the same during reordering.
")
      var i: int = 1
      while i < baseKey.Length:
          if baseKey[i] != reorderKey[i]:
Errln("Collation key bytes not the same at position " + i)
++i
    myCollation = RuleBasedCollator("")
    myCollation.Strength = Collator.Quaternary
    baseKey = myCollation.GetCollationKey(testString).ToByteArray
myCollation.SetReorderCodes(reorderCodes)
    reorderKey = myCollation.GetCollationKey(testString).ToByteArray
    if baseKey.Length != reorderKey.Length:
Errln("Key lengths not the same during reordering.
")
      var i: int = 1
      while i < baseKey.Length:
          if baseKey[i] != reorderKey[i]:
Errln("Collation key bytes not the same at position " + i)
++i
proc TestReorderingAPI*() =
    var myCollation: Collator
    var reorderCodes: int[] = @[UScript.Greek, UScript.Han, ReorderCodes.Punctuation]
    var duplicateReorderCodes: int[] = @[UScript.Hiragana, UScript.Greek, ReorderCodes.Currency, UScript.Katakana]
    var reorderCodesStartingWithDefault: int[] = @[ReorderCodes.Default, UScript.Greek, UScript.Han, ReorderCodes.Punctuation]
    var retrievedReorderCodes: int[]
    var greekString: String = "α"
    var punctuationString: String = "‾"
    myCollation = RuleBasedCollator("")
    myCollation.Strength = Collator.Tertiary
myCollation.SetReorderCodes(reorderCodes)
    retrievedReorderCodes = myCollation.GetReorderCodes
    if !ArrayEqualityComparer[int].OneDimensional.Equals(reorderCodes, retrievedReorderCodes):
Errln("ERROR: retrieved reorder codes do not match set reorder codes.")
    if !myCollation.Compare(greekString, punctuationString) < 0:
Errln("ERROR: collation result should have been less.")
myCollation.SetReorderCodes(nil)
    retrievedReorderCodes = myCollation.GetReorderCodes
    if retrievedReorderCodes.Length != 0:
Errln("ERROR: retrieved reorder codes was not null.")
    if !myCollation.Compare(greekString, punctuationString) > 0:
Errln("ERROR: collation result should have been greater.")
myCollation.SetReorderCodes(reorderCodes)
    retrievedReorderCodes = myCollation.GetReorderCodes
    if !ArrayEqualityComparer[int].OneDimensional.Equals(reorderCodes, retrievedReorderCodes):
Errln("ERROR: retrieved reorder codes do not match set reorder codes.")
    if !myCollation.Compare(greekString, punctuationString) < 0:
Errln("ERROR: collation result should have been less.")
myCollation.SetReorderCodes(@[])
    retrievedReorderCodes = myCollation.GetReorderCodes
    if retrievedReorderCodes.Length != 0:
Errln("ERROR: retrieved reorder codes was not null.")
    if !myCollation.Compare(greekString, punctuationString) > 0:
Errln("ERROR: collation result should have been greater.")
myCollation.SetReorderCodes(@[ReorderCodes.None])
    retrievedReorderCodes = myCollation.GetReorderCodes
    if retrievedReorderCodes.Length != 0:
Errln("ERROR: [NONE] retrieved reorder codes was not null.")
    var gotException: bool = false
    try:
myCollation.SetReorderCodes(duplicateReorderCodes)
    except ArgumentException:
        gotException = true
    if !gotException:
Errln("ERROR: exception was not thrown for illegal reorder codes argument.")
    gotException = false
    try:
myCollation.SetReorderCodes(reorderCodesStartingWithDefault)
    except ArgumentException:
        gotException = true
    if !gotException:
Errln("ERROR: reorder codes following a 'default' code should have thrown an exception but did not.")
proc TestReorderingAPIWithRuleCreatedCollator*() =
    var myCollation: Collator
    var rules: String = "[reorder Hani Grek]"
    var rulesReorderCodes: int[] = @[UScript.Han, UScript.Greek]
    var reorderCodes: int[] = @[UScript.Greek, UScript.Han, ReorderCodes.Punctuation]
    var retrievedReorderCodes: int[]
    myCollation = RuleBasedCollator(rules)
    myCollation.Strength = Collator.Tertiary
    retrievedReorderCodes = myCollation.GetReorderCodes
    if !ArrayEqualityComparer[int].OneDimensional.Equals(rulesReorderCodes, retrievedReorderCodes):
Errln("ERROR: retrieved reorder codes do not match set reorder codes.")
myCollation.SetReorderCodes(nil)
    retrievedReorderCodes = myCollation.GetReorderCodes
    if retrievedReorderCodes.Length != 0:
Errln("ERROR: retrieved reorder codes was not null.")
myCollation.SetReorderCodes(reorderCodes)
    retrievedReorderCodes = myCollation.GetReorderCodes
    if !ArrayEqualityComparer[int].OneDimensional.Equals(reorderCodes, retrievedReorderCodes):
Errln("ERROR: retrieved reorder codes do not match set reorder codes.")
myCollation.SetReorderCodes(ReorderCodes.Default)
    retrievedReorderCodes = myCollation.GetReorderCodes
    if !ArrayEqualityComparer[int].OneDimensional.Equals(rulesReorderCodes, retrievedReorderCodes):
Errln("ERROR: retrieved reorder codes do not match set reorder codes.")
proc containsExpectedScript(scripts: seq[int], expectedScript: int): bool =
      var i: int = 0
      while i < scripts.Length:
          if expectedScript == scripts[i]:
              return true
++i
    return false
proc TestEquivalentReorderingScripts*() =
    var expectedScripts: int[] = @[UScript.Hiragana, UScript.Katakana, UScript.KatakanaOrHiragana]
    var equivalentScripts: int[] = RuleBasedCollator.GetEquivalentReorderCodes(UScript.Gothic)
    if equivalentScripts.Length != 1 || equivalentScripts[0] != UScript.Gothic:
Errln(String.Format("ERROR/Gothic: retrieved equivalent scripts wrong: " + "length expected 1, was = {0}; expected [{1}] was [{2}]", equivalentScripts.Length, UScript.Gothic, equivalentScripts[0]))
    equivalentScripts = RuleBasedCollator.GetEquivalentReorderCodes(UScript.Hiragana)
    if equivalentScripts.Length != expectedScripts.Length:
Errln(String.Format("ERROR/Hiragana: retrieved equivalent script length wrong: " + "expected {0}, was = {1}", expectedScripts.Length, equivalentScripts.Length))
    var prevScript: int = -1
      var i: int = 0
      while i < equivalentScripts.Length:
          var script: int = equivalentScripts[i]
          if script <= prevScript:
Errln("ERROR/Hiragana: equivalent scripts out of order at index " + i)
          prevScript = script
++i
    for code in expectedScripts:
        if !containsExpectedScript(equivalentScripts, code):
Errln("ERROR/Hiragana: equivalent scripts do not contain " + code)
    equivalentScripts = RuleBasedCollator.GetEquivalentReorderCodes(UScript.Katakana)
    if equivalentScripts.Length != expectedScripts.Length:
Errln(String.Format("ERROR/Katakana: retrieved equivalent script length wrong: " + "expected {0}, was = {1}", expectedScripts.Length, equivalentScripts.Length))
    for code in expectedScripts:
        if !containsExpectedScript(equivalentScripts, code):
Errln("ERROR/Katakana: equivalent scripts do not contain " + code)
    equivalentScripts = RuleBasedCollator.GetEquivalentReorderCodes(UScript.KatakanaOrHiragana)
    if equivalentScripts.Length != expectedScripts.Length:
Errln(String.Format("ERROR/Hrkt: retrieved equivalent script length wrong: " + "expected {0}, was = {1}", expectedScripts.Length, equivalentScripts.Length))
    equivalentScripts = RuleBasedCollator.GetEquivalentReorderCodes(UScript.Han)
    if equivalentScripts.Length != 3:
Errln("ERROR/Hani: retrieved equivalent script length wrong: " + "expected 3, was = " + equivalentScripts.Length)
    equivalentScripts = RuleBasedCollator.GetEquivalentReorderCodes(UScript.SimplifiedHan)
    if equivalentScripts.Length != 3:
Errln("ERROR/Hans: retrieved equivalent script length wrong: " + "expected 3, was = " + equivalentScripts.Length)
    equivalentScripts = RuleBasedCollator.GetEquivalentReorderCodes(UScript.TraditionalHan)
    if equivalentScripts.Length != 3:
Errln("ERROR/Hant: retrieved equivalent script length wrong: " + "expected 3, was = " + equivalentScripts.Length)
    equivalentScripts = RuleBasedCollator.GetEquivalentReorderCodes(UScript.MeroiticCursive)
    if equivalentScripts.Length != 2:
Errln("ERROR/Merc: retrieved equivalent script length wrong: " + "expected 2, was = " + equivalentScripts.Length)
    equivalentScripts = RuleBasedCollator.GetEquivalentReorderCodes(UScript.MeroiticHieroglyphs)
    if equivalentScripts.Length != 2:
Errln("ERROR/Mero: retrieved equivalent script length wrong: " + "expected 2, was = " + equivalentScripts.Length)
proc TestGreekFirstReorderCloning*() =
    var testSourceCases: String[] = @["A", "αA", "a", "Aa", "Α"]
    var testTargetCases: String[] = @["α", "Aα", "Α", "Αα", "Α"]
    var results: int[] = @[1, -1, 1, 1, 0]
    var originalCollation: Collator
    var myCollation: Collator
    var rules: String = "[reorder Grek]"
    try:
        originalCollation = RuleBasedCollator(rules)
    except Exception:
Warnln("ERROR: in creation of rule based collator")
        return
    try:
        myCollation = cast[Collator](originalCollation.Clone)
    except Exception:
Warnln("ERROR: in creation of rule based collator")
        return
    myCollation.Decomposition = Collator.CanonicalDecomposition
    myCollation.Strength = Collator.Tertiary
      var i: int = 0
      while i < testSourceCases.Length:
CollationTest.DoTest(self, cast[RuleBasedCollator](myCollation), testSourceCases[i], testTargetCases[i], results[i])
++i
proc doTestOneReorderingAPITestCase(testCases: seq[OneTestCase], reorderTokens: seq[int]) =
    var myCollation: Collator = Collator.GetInstance(UCultureInfo("en"))
myCollation.SetReorderCodes(reorderTokens)
    for testCase in testCases:
CollationTest.DoTest(self, cast[RuleBasedCollator](myCollation), testCase.m_source_, testCase.m_target_, testCase.m_result_)
proc TestGreekFirstReorder*() =
    var strRules: String[] = @["[reorder Grek]"]
    var apiRules: int[] = @[UScript.Greek]
    var privateUseCharacterStrings: OneTestCase[] = @[OneTestCase("Α", "Α", 0), OneTestCase("A", "Α", 1), OneTestCase("αA", "αΑ", 1), OneTestCase("`", "Α", -1), OneTestCase("Α", "", -1), OneTestCase("Α", "`", 1)]
doTestCollation(privateUseCharacterStrings, strRules)
doTestOneReorderingAPITestCase(privateUseCharacterStrings, apiRules)
proc TestGreekLastReorder*() =
    var strRules: String[] = @["[reorder Zzzz Grek]"]
    var apiRules: int[] = @[UScript.Unknown, UScript.Greek]
    var privateUseCharacterStrings: OneTestCase[] = @[OneTestCase("Α", "Α", 0), OneTestCase("A", "Α", -1), OneTestCase("αA", "αΑ", -1), OneTestCase("`", "Α", -1), OneTestCase("Α", "", 1)]
doTestCollation(privateUseCharacterStrings, strRules)
doTestOneReorderingAPITestCase(privateUseCharacterStrings, apiRules)
proc TestNonScriptReorder*() =
    var strRules: String[] = @["[reorder Grek Symbol DIGIT Latn Punct space Zzzz cURRENCy]"]
    var apiRules: int[] = @[UScript.Greek, ReorderCodes.Symbol, ReorderCodes.Digit, UScript.Latin, ReorderCodes.Punctuation, ReorderCodes.Space, UScript.Unknown, ReorderCodes.Currency]
    var privateUseCharacterStrings: OneTestCase[] = @[OneTestCase("Α", "A", -1), OneTestCase("A", "Α", 1), OneTestCase("`", "A", -1), OneTestCase("`", "Α", 1), OneTestCase("$", "A", 1)]
doTestCollation(privateUseCharacterStrings, strRules)
doTestOneReorderingAPITestCase(privateUseCharacterStrings, apiRules)
proc TestHaniReorder*() =
    var strRules: String[] = @["[reorder Hani]"]
    var apiRules: int[] = @[UScript.Han]
    var privateUseCharacterStrings: OneTestCase[] = @[OneTestCase("一", "A", -1), OneTestCase("一", "`", 1), OneTestCase("𫝀", "A", -1), OneTestCase("𫝀", "`", 1), OneTestCase("一", "𫝀", -1), OneTestCase("﨧", "A", -1), OneTestCase("𪜀", "A", -1)]
doTestCollation(privateUseCharacterStrings, strRules)
doTestOneReorderingAPITestCase(privateUseCharacterStrings, apiRules)
proc TestHaniReorderWithOtherRules*() =
    var strRules: String[] = @["[reorder Hani]  &b<a"]
    var privateUseCharacterStrings: OneTestCase[] = @[OneTestCase("一", "A", -1), OneTestCase("一", "`", 1), OneTestCase("𫝀", "A", -1), OneTestCase("𫝀", "`", 1), OneTestCase("一", "𫝀", -1), OneTestCase("﨧", "A", -1), OneTestCase("𪜀", "A", -1), OneTestCase("b", "a", -1)]
doTestCollation(privateUseCharacterStrings, strRules)
proc TestMultipleReorder*() =
    var strRules: String[] = @["[reorder Grek Zzzz DIGIT Latn Hani]"]
    var apiRules: int[] = @[UScript.Greek, UScript.Unknown, ReorderCodes.Digit, UScript.Latin, UScript.Han]
    var collationTestCases: OneTestCase[] = @[OneTestCase("Α", "A", -1), OneTestCase("1", "A", -1), OneTestCase("u0041", "一", -1)]
doTestCollation(collationTestCases, strRules)
doTestOneReorderingAPITestCase(collationTestCases, apiRules)
proc TestFrozeness*() =
    var myCollation: Collator = Collator.GetInstance(UCultureInfo("en_CA"))
    var exceptionCaught: bool = false
myCollation.Freeze
assertTrue("Collator not frozen.", myCollation.IsFrozen)
    try:
        myCollation.Strength = Collator.Secondary
    except NotSupportedException:
        exceptionCaught = true
assertTrue("Frozen collator allowed change.", exceptionCaught)
    exceptionCaught = false
    try:
myCollation.SetReorderCodes(ReorderCodes.Default)
    except NotSupportedException:
        exceptionCaught = true
assertTrue("Frozen collator allowed change.", exceptionCaught)
    exceptionCaught = false
    try:
        myCollation.VariableTop = 12
    except NotSupportedException:
        exceptionCaught = true
assertTrue("Frozen collator allowed change.", exceptionCaught)
    exceptionCaught = false
    var myClone: Collator = nil
    myClone = cast[Collator](myCollation.Clone)
assertTrue("Clone not frozen as expected.", myClone.IsFrozen)
    myClone = myClone.CloneAsThawed
assertFalse("Clone not thawed as expected.", myClone.IsFrozen)
proc TestUnknownCollationKeyword*() =
    var coll1: Collator = Collator.GetInstance(UCultureInfo("en_US@collation=bogus"))
    var coll2: Collator = Collator.GetInstance(UCultureInfo("en_US"))
assertEquals("Unknown collation keyword 'bogus' should be ignored", coll1, coll2)