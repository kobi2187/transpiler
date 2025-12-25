# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationKanaTest = ref object
    testSourceCases: seq[char] = @[@[cast[char](65438)], @[cast[char](12354)], @[cast[char](12450)], @[cast[char](12354), cast[char](12354)], @[cast[char](12450), cast[char](12540)], @[cast[char](12450), cast[char](12540), cast[char](12488)]]
    testTargetCases: seq[char] = @[@[cast[char](65439)], @[cast[char](12450)], @[cast[char](12354), cast[char](12354)], @[cast[char](12450), cast[char](12540)], @[cast[char](12450), cast[char](12540), cast[char](12488)], @[cast[char](12354), cast[char](12354), cast[char](12392)]]
    results: seq[int] = @[-1, 0, -1, 1, -1, -1]
    testBaseCases: seq[char] = @[@[cast[char](12459)], @[cast[char](12459), cast[char](12461)], @[cast[char](12461)], @[cast[char](12461), cast[char](12461)]]
    testPlainDakutenHandakutenCases: seq[char] = @[@[cast[char](12495), cast[char](12459)], @[cast[char](12496), cast[char](12459)], @[cast[char](12495), cast[char](12461)], @[cast[char](12496), cast[char](12461)]]
    testSmallLargeCases: seq[char] = @[@[cast[char](12483), cast[char](12495)], @[cast[char](12484), cast[char](12495)], @[cast[char](12483), cast[char](12496)], @[cast[char](12484), cast[char](12496)]]
    testKatakanaHiraganaCases: seq[char] = @[@[cast[char](12354), cast[char](12483)], @[cast[char](12450), cast[char](12483)], @[cast[char](12354), cast[char](12484)], @[cast[char](12450), cast[char](12484)]]
    testChooonKigooCases: seq[char] = @[@[cast[char](12459), cast[char](12540), cast[char](12354)], @[cast[char](12459), cast[char](12540), cast[char](12450)], @[cast[char](12459), cast[char](12452), cast[char](12354)], @[cast[char](12459), cast[char](12452), cast[char](12450)], @[cast[char](12461), cast[char](12540), cast[char](12354)], @[cast[char](12461), cast[char](12540), cast[char](12450)], @[cast[char](12461), cast[char](12452), cast[char](12354)], @[cast[char](12461), cast[char](12452), cast[char](12450)]]
    myCollation: Collator = nil

proc newCollationKanaTest(): CollationKanaTest =

proc init*() =
    if myCollation == nil:
        myCollation = Collator.GetInstance(CultureInfo("ja"))
proc TestTertiary*() =
    var i: int = 0
    myCollation.Strength = Collator.Tertiary
      i = 0
      while i < 6:
doTest(testSourceCases[i], testTargetCases[i], results[i])
++i
proc TestBase*() =
    var i: int
    myCollation.Strength = Collator.Primary
      i = 0
      while i < 3:
doTest(testBaseCases[i], testBaseCases[i + 1], -1)
++i
proc TestPlainDakutenHandakuten*() =
    var i: int
    myCollation.Strength = Collator.Secondary
      i = 0
      while i < 3:
doTest(testPlainDakutenHandakutenCases[i], testPlainDakutenHandakutenCases[i + 1], -1)
++i
proc TestSmallLarge*() =
    var i: int
    myCollation.Strength = Collator.Tertiary
      i = 0
      while i < 3:
doTest(testSmallLargeCases[i], testSmallLargeCases[i + 1], -1)
++i
proc TestKatakanaHiragana*() =
    var i: int
    myCollation.Strength = Collator.Quaternary
      i = 0
      while i < 3:
doTest(testKatakanaHiraganaCases[i], testKatakanaHiraganaCases[i + 1], -1)
++i
proc TestChooonKigoo*() =
    var i: int
    myCollation.Strength = Collator.Quaternary
      i = 0
      while i < 7:
doTest(testChooonKigooCases[i], testChooonKigooCases[i + 1], -1)
++i
proc TestCommonCharacters*() =
    var tmp1: char[] = @[cast[char](12376), cast[char](12472)]
    var tmp2: char[] = @[cast[char](12375), cast[char](12441), cast[char](12471), cast[char](12441)]
      var key1: CollationKey
      var key2: CollationKey
    var result: int
    var string1: String = String(tmp1)
    var string2: String = String(tmp2)
    var rb: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(UCultureInfo("ja")))
    rb.Strength = Collator.Quaternary
    rb.IsAlternateHandlingShifted = false
    result = rb.Compare(string1, string2)
    key1 = rb.GetCollationKey(string1)
    key2 = rb.GetCollationKey(string2)
    if result != 0 || !key1.Equals(key2):
Errln("Failed Hiragana and Katakana common characters test. Expected results to be equal.")
proc doTest(source: seq[char], target: seq[char], result: int) =
    var s: String = String(source)
    var t: String = String(target)
    var compareResult: int = myCollation.Compare(s, t)
      var sortKey1: CollationKey
      var sortKey2: CollationKey
    sortKey1 = myCollation.GetCollationKey(s)
    sortKey2 = myCollation.GetCollationKey(t)
    var keyResult: int = sortKey1.CompareTo(sortKey2)
reportCResult(s, t, sortKey1, sortKey2, compareResult, keyResult, compareResult, result)
proc reportCResult(source: String, target: String, sourceKey: CollationKey, targetKey: CollationKey, compareResult: int, keyResult: int, incResult: int, expectedResult: int) =
    if expectedResult < -1 || expectedResult > 1:
Errln("***** invalid call to reportCResult ****")
        return
    var ok1: bool = compareResult == expectedResult
    var ok2: bool = keyResult == expectedResult
    var ok3: bool = incResult == expectedResult
    if ok1 && ok2 && ok3 && !IsVerbose:
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
Logln(msg1 + source + msg2 + target + msg3 + sResult)
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
Logln(msg1 + source + msg2 + target + msg3 + sResult)
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
Logln(msg1 + source + msg2 + target + msg3 + sResult)
        else:
Errln(msg1 + source + msg2 + target + msg3 + sResult + msg4 + sExpect)