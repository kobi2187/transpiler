# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationFrenchTest = ref object
    testSourceCases: seq[char] = @[@[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](67), cast[char](79), cast[char](84), cast[char](69)], @[cast[char](99), cast[char](111), cast[char](45), cast[char](111), cast[char](112)], @[cast[char](112), cast[char](234), cast[char](99), cast[char](104), cast[char](101)], @[cast[char](112), cast[char](234), cast[char](99), cast[char](104), cast[char](101), cast[char](114)], @[cast[char](112), cast[char](233), cast[char](99), cast[char](104), cast[char](101), cast[char](114)], @[cast[char](112), cast[char](233), cast[char](99), cast[char](104), cast[char](101), cast[char](114)], @[cast[char](72), cast[char](101), cast[char](108), cast[char](108), cast[char](111)], @[cast[char](497)], @[cast[char](64256)], @[cast[char](506)], @[cast[char](257)]]
    testTargetCases: seq[char] = @[@[cast[char](65), cast[char](66), cast[char](67)], @[cast[char](99), cast[char](244), cast[char](116), cast[char](101)], @[cast[char](67), cast[char](79), cast[char](79), cast[char](80)], @[cast[char](112), cast[char](233), cast[char](99), cast[char](104), cast[char](233)], @[cast[char](112), cast[char](233), cast[char](99), cast[char](104), cast[char](233)], @[cast[char](112), cast[char](234), cast[char](99), cast[char](104), cast[char](101)], @[cast[char](112), cast[char](234), cast[char](99), cast[char](104), cast[char](101), cast[char](114)], @[cast[char](104), cast[char](101), cast[char](108), cast[char](108), cast[char](79)], @[cast[char](494)], @[cast[char](9674)], @[cast[char](224)], @[cast[char](479)]]
    results: seq[int] = @[-1, -1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1]
    testAcute: seq[char] = @[@[cast[char](101), cast[char](101)], @[cast[char](101), cast[char](769), cast[char](101)], @[cast[char](101), cast[char](768), cast[char](769), cast[char](101)], @[cast[char](101), cast[char](768), cast[char](101)], @[cast[char](101), cast[char](769), cast[char](768), cast[char](101)], @[cast[char](101), cast[char](101), cast[char](769)], @[cast[char](101), cast[char](769), cast[char](101), cast[char](769)], @[cast[char](101), cast[char](768), cast[char](769), cast[char](101), cast[char](769)], @[cast[char](101), cast[char](768), cast[char](101), cast[char](769)], @[cast[char](101), cast[char](769), cast[char](768), cast[char](101), cast[char](769)], @[cast[char](101), cast[char](101), cast[char](768), cast[char](769)], @[cast[char](101), cast[char](769), cast[char](101), cast[char](768), cast[char](769)], @[cast[char](101), cast[char](768), cast[char](769), cast[char](101), cast[char](768), cast[char](769)], @[cast[char](101), cast[char](768), cast[char](101), cast[char](768), cast[char](769)], @[cast[char](101), cast[char](769), cast[char](768), cast[char](101), cast[char](768), cast[char](769)], @[cast[char](101), cast[char](101), cast[char](768)], @[cast[char](101), cast[char](769), cast[char](101), cast[char](768)], @[cast[char](101), cast[char](768), cast[char](769), cast[char](101), cast[char](768)], @[cast[char](101), cast[char](768), cast[char](101), cast[char](768)], @[cast[char](101), cast[char](769), cast[char](768), cast[char](101), cast[char](768)], @[cast[char](101), cast[char](101), cast[char](769), cast[char](768)], @[cast[char](101), cast[char](769), cast[char](101), cast[char](769), cast[char](768)], @[cast[char](101), cast[char](768), cast[char](769), cast[char](101), cast[char](769), cast[char](768)], @[cast[char](101), cast[char](768), cast[char](101), cast[char](769), cast[char](768)], @[cast[char](101), cast[char](769), cast[char](768), cast[char](101), cast[char](769), cast[char](768)]]
    testBugs: seq[char] = @[@[cast[char](97)], @[cast[char](65)], @[cast[char](101)], @[cast[char](69)], @[cast[char](233)], @[cast[char](232)], @[cast[char](234)], @[cast[char](235)], @[cast[char](101), cast[char](97)], @[cast[char](120)]]
    myCollation: Collator = nil

proc newCollationFrenchTest(): CollationFrenchTest =

proc Init*() =
    myCollation = Collator.GetInstance(CultureInfo("fr-CA"))
proc TestTertiary*() =
    var i: int = 0
    myCollation.Strength = CollationStrength.Tertiary
      i = 0
      while i < 12:
doTest(testSourceCases[i], testTargetCases[i], results[i])
++i
proc TestSecondary*() =
    var i: int = 0
    var j: int
    var expected: int
    myCollation.Strength = CollationStrength.Secondary
      i = 0
      while i < testAcute.Length:
            j = 0
            while j < testAcute.Length:
                if i < j:
                    expected = -1

                elif i == j:
                    expected = 0
                else:
                    expected = 1
doTest(testAcute[i], testAcute[j], expected)
++j
++i
proc TestExtra*() =
      var i: int
      var j: int
    myCollation.Strength = CollationStrength.Tertiary
      i = 0
      while i < 9:
            j = i + 1
            while j < 10:
doTest(testBugs[i], testBugs[j], -1)
                j = 1
++i
proc TestContinuationReordering*() =
    var rule: String = "&0x2f00 << 0x2f01"
    try:
        var collator: RuleBasedCollator = RuleBasedCollator(rule)
        collator.IsFrenchCollation = true
        var key1: CollationKey = collator.GetCollationKey("ḁ⼀⼁b̥")
        var key2: CollationKey = collator.GetCollationKey("ḁ⼁⼁b̥")
        if key1.CompareTo(key2) >= 0:
Errln("Error comparing continuation strings")
    except Exception:
Errln(e.ToString)
proc doTest(source: seq[char], target: seq[char], result: int) =
    var s: String = String(source)
    var t: String = String(target)
    var compareResult: int = myCollation.Compare(s, t)
      var sortKey1: CollationKey
      var sortKey2: CollationKey
    sortKey1 = myCollation.GetCollationKey(s)
    sortKey2 = myCollation.GetCollationKey(t)
    var keyResult: int = sortKey1.CompareTo(sortKey2)
ReportCResult(s, t, sortKey1, sortKey2, compareResult, keyResult, compareResult, result)
proc ReportCResult(source: String, target: String, sourceKey: CollationKey, targetKey: CollationKey, compareResult: int, keyResult: int, incResult: int, expectedResult: int) =
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