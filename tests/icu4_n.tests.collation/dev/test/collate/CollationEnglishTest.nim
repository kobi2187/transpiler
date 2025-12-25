# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationEnglishTest = ref object
    testSourceCases: seq[char] = @[@[cast[char](97), cast[char](98)], @[cast[char](98), cast[char](108), cast[char](97), cast[char](99), cast[char](107), cast[char](45), cast[char](98), cast[char](105), cast[char](114), cast[char](100)], @[cast[char](98), cast[char](108), cast[char](97), cast[char](99), cast[char](107), cast[char](32), cast[char](98), cast[char](105), cast[char](114), cast[char](100)], @[cast[char](98), cast[char](108), cast[char](97), cast[char](99), cast[char](107), cast[char](45), cast[char](98), cast[char](105), cast[char](114), cast[char](100)], @[cast[char](72), cast[char](101), cast[char](108), cast[char](108), cast[char](111)], @[cast[char](65), cast[char](66), cast[char](67)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](98), cast[char](108), cast[char](97), cast[char](99), cast[char](107), cast[char](98), cast[char](105), cast[char](114), cast[char](100)], @[cast[char](98), cast[char](108), cast[char](97), cast[char](99), cast[char](107), cast[char](45), cast[char](98), cast[char](105), cast[char](114), cast[char](100)], @[cast[char](98), cast[char](108), cast[char](97), cast[char](99), cast[char](107), cast[char](45), cast[char](98), cast[char](105), cast[char](114), cast[char](100)], @[cast[char](112), cast[char](234), cast[char](99), cast[char](104), cast[char](101)], @[cast[char](112), cast[char](233), cast[char](99), cast[char](104), cast[char](233)], @[cast[char](196), cast[char](66), cast[char](776), cast[char](67), cast[char](776)], @[cast[char](97), cast[char](776), cast[char](98), cast[char](99)], @[cast[char](112), cast[char](233), cast[char](99), cast[char](104), cast[char](101), cast[char](114)], @[cast[char](114), cast[char](111), cast[char](108), cast[char](101), cast[char](115)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](65)], @[cast[char](65)], @[cast[char](97), cast[char](98)], @[cast[char](116), cast[char](99), cast[char](111), cast[char](109), cast[char](112), cast[char](97), cast[char](114), cast[char](101), cast[char](112), cast[char](108), cast[char](97), cast[char](105), cast[char](110)], @[cast[char](97), cast[char](98)], @[cast[char](97), cast[char](35), cast[char](98)], @[cast[char](97), cast[char](35), cast[char](98)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](65), cast[char](98), cast[char](99), cast[char](100), cast[char](97)], @[cast[char](97), cast[char](98), cast[char](99), cast[char](100), cast[char](97)], @[cast[char](97), cast[char](98), cast[char](99), cast[char](100), cast[char](97)], @[cast[char](230), cast[char](98), cast[char](99), cast[char](100), cast[char](97)], @[cast[char](228), cast[char](98), cast[char](99), cast[char](100), cast[char](97)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](99), cast[char](72), cast[char](99)], @[cast[char](97), cast[char](776), cast[char](98), cast[char](99)], @[cast[char](116), cast[char](104), cast[char](105), cast[char](770), cast[char](115)], @[cast[char](112), cast[char](234), cast[char](99), cast[char](104), cast[char](101)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](230), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](230), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](112), cast[char](233), cast[char](99), cast[char](104), cast[char](233)]]
    testTargetCases: seq[char] = @[@[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](98), cast[char](108), cast[char](97), cast[char](99), cast[char](107), cast[char](98), cast[char](105), cast[char](114), cast[char](100)], @[cast[char](98), cast[char](108), cast[char](97), cast[char](99), cast[char](107), cast[char](45), cast[char](98), cast[char](105), cast[char](114), cast[char](100)], @[cast[char](98), cast[char](108), cast[char](97), cast[char](99), cast[char](107)], @[cast[char](104), cast[char](101), cast[char](108), cast[char](108), cast[char](111)], @[cast[char](65), cast[char](66), cast[char](67)], @[cast[char](65), cast[char](66), cast[char](67)], @[cast[char](98), cast[char](108), cast[char](97), cast[char](99), cast[char](107), cast[char](98), cast[char](105), cast[char](114), cast[char](100), cast[char](115)], @[cast[char](98), cast[char](108), cast[char](97), cast[char](99), cast[char](107), cast[char](98), cast[char](105), cast[char](114), cast[char](100), cast[char](115)], @[cast[char](98), cast[char](108), cast[char](97), cast[char](99), cast[char](107), cast[char](98), cast[char](105), cast[char](114), cast[char](100)], @[cast[char](112), cast[char](233), cast[char](99), cast[char](104), cast[char](233)], @[cast[char](112), cast[char](233), cast[char](99), cast[char](104), cast[char](101), cast[char](114)], @[cast[char](196), cast[char](66), cast[char](776), cast[char](67), cast[char](776)], @[cast[char](65), cast[char](776), cast[char](98), cast[char](99)], @[cast[char](112), cast[char](233), cast[char](99), cast[char](104), cast[char](101)], @[cast[char](114), cast[char](111), cast[char](770), cast[char](108), cast[char](101)], @[cast[char](65), cast[char](225), cast[char](99), cast[char](100)], @[cast[char](65), cast[char](225), cast[char](99), cast[char](100)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](84), cast[char](67), cast[char](111), cast[char](109), cast[char](112), cast[char](97), cast[char](114), cast[char](101), cast[char](80), cast[char](108), cast[char](97), cast[char](105), cast[char](110)], @[cast[char](97), cast[char](66), cast[char](99)], @[cast[char](97), cast[char](35), cast[char](66)], @[cast[char](97), cast[char](38), cast[char](98)], @[cast[char](97), cast[char](35), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99), cast[char](100), cast[char](97)], @[cast[char](196), cast[char](98), cast[char](99), cast[char](100), cast[char](97)], @[cast[char](228), cast[char](98), cast[char](99), cast[char](100), cast[char](97)], @[cast[char](196), cast[char](98), cast[char](99), cast[char](100), cast[char](97)], @[cast[char](196), cast[char](98), cast[char](99), cast[char](100), cast[char](97)], @[cast[char](97), cast[char](98), cast[char](35), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](61), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](100)], @[cast[char](228), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](67), cast[char](72), cast[char](99)], @[cast[char](228), cast[char](98), cast[char](99)], @[cast[char](116), cast[char](104), cast[char](238), cast[char](115)], @[cast[char](112), cast[char](233), cast[char](99), cast[char](104), cast[char](233)], @[cast[char](97), cast[char](66), cast[char](67)], @[cast[char](97), cast[char](98), cast[char](100)], @[cast[char](228), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](198), cast[char](99)], @[cast[char](97), cast[char](66), cast[char](100)], @[cast[char](228), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](198), cast[char](99)], @[cast[char](97), cast[char](66), cast[char](100)], @[cast[char](228), cast[char](98), cast[char](99)], @[cast[char](112), cast[char](234), cast[char](99), cast[char](104), cast[char](101)]]
    results: seq[int] = @[-1, -1, -1, 1, 1, 0, -1, -1, -1, -1, 1, -1, 0, -1, 1, 1, 1, -1, -1, -1, -1, -1, -1, 1, 1, 1, -1, -1, 1, -1, 1, 0, 1, -1, -1, -1, 0, 0, 0, 0, -1, 0, 0, -1, -1, 0, -1, -1, -1]
    testBugs: seq[char] = @[@[cast[char](97)], @[cast[char](65)], @[cast[char](101)], @[cast[char](69)], @[cast[char](233)], @[cast[char](232)], @[cast[char](234)], @[cast[char](235)], @[cast[char](101), cast[char](97)], @[cast[char](120)]]
    testAcute: seq[char] = @[@[cast[char](101), cast[char](101)], @[cast[char](101), cast[char](101), cast[char](769)], @[cast[char](101), cast[char](101), cast[char](769), cast[char](768)], @[cast[char](101), cast[char](101), cast[char](768)], @[cast[char](101), cast[char](101), cast[char](768), cast[char](769)], @[cast[char](101), cast[char](769), cast[char](101)], @[cast[char](101), cast[char](769), cast[char](101), cast[char](769)], @[cast[char](101), cast[char](769), cast[char](101), cast[char](769), cast[char](768)], @[cast[char](101), cast[char](769), cast[char](101), cast[char](768)], @[cast[char](101), cast[char](769), cast[char](101), cast[char](768), cast[char](769)], @[cast[char](101), cast[char](769), cast[char](768), cast[char](101)], @[cast[char](101), cast[char](769), cast[char](768), cast[char](101), cast[char](769)], @[cast[char](101), cast[char](769), cast[char](768), cast[char](101), cast[char](769), cast[char](768)], @[cast[char](101), cast[char](769), cast[char](768), cast[char](101), cast[char](768)], @[cast[char](101), cast[char](769), cast[char](768), cast[char](101), cast[char](768), cast[char](769)], @[cast[char](101), cast[char](768), cast[char](101)], @[cast[char](101), cast[char](768), cast[char](101), cast[char](769)], @[cast[char](101), cast[char](768), cast[char](101), cast[char](769), cast[char](768)], @[cast[char](101), cast[char](768), cast[char](101), cast[char](768)], @[cast[char](101), cast[char](768), cast[char](101), cast[char](768), cast[char](769)], @[cast[char](101), cast[char](768), cast[char](769), cast[char](101)], @[cast[char](101), cast[char](768), cast[char](769), cast[char](101), cast[char](769)], @[cast[char](101), cast[char](768), cast[char](769), cast[char](101), cast[char](769), cast[char](768)], @[cast[char](101), cast[char](768), cast[char](769), cast[char](101), cast[char](768)], @[cast[char](101), cast[char](768), cast[char](769), cast[char](101), cast[char](768), cast[char](769)]]
    testMore: seq[char] = @[@[cast[char](97), cast[char](101)], @[cast[char](230)], @[cast[char](198)], @[cast[char](97), cast[char](102)], @[cast[char](111), cast[char](101)], @[cast[char](339)], @[cast[char](338)], @[cast[char](111), cast[char](102)]]
    myCollation: Collator = nil

proc newCollationEnglishTest(): CollationEnglishTest =

proc Init*() =
    myCollation = Collator.GetInstance(CultureInfo("en"))
proc TestPrimary*() =
    var i: int
    myCollation.Strength = CollationStrength.Primary
      i = 38
      while i < 43:
DoTest(testSourceCases[i], testTargetCases[i], results[i])
++i
proc TestSecondary*() =
    var i: int
    myCollation.Strength = CollationStrength.Secondary
      i = 43
      while i < 49:
DoTest(testSourceCases[i], testTargetCases[i], results[i])
++i
    var j: int
    var expected: int
      i = 0
      while i < testAcute.Length:
            j = 0
            while j < testAcute.Length:
Logln("i = " + i + "; j = " + j)
                if i < j:
                  expected = -1

                elif i == j:
                  expected = 0
                else:
                  expected = 1
DoTest(testAcute[i], testAcute[j], expected)
++j
++i
proc TestTertiary*() =
    var i: int = 0
    myCollation.Strength = CollationStrength.Tertiary
      i = 0
      while i < 38:
DoTest(testSourceCases[i], testTargetCases[i], results[i])
++i
    var j: int = 0
      i = 0
      while i < 10:
            j = i + 1
            while j < 10:
DoTest(testBugs[i], testBugs[j], -1)
++j
++i
    var expected: int
      i = 0
      while i < testMore.Length:
            j = 0
            while j < testMore.Length:
                if i < j:
                  expected = -1

                elif i == j:
                  expected = 0
                else:
                  expected = 1
DoTest(testMore[i], testMore[j], expected)
++j
++i
proc DoTest(source: seq[char], target: seq[char], result: int) =
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