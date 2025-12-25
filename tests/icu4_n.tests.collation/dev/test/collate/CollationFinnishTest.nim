# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationFinnishTest = ref object
    testSourceCases: seq[char] = @[@[cast[char](119), cast[char](97), cast[char](116)], @[cast[char](118), cast[char](97), cast[char](116)], @[cast[char](97), cast[char](252), cast[char](98), cast[char](101), cast[char](99), cast[char](107)], @[cast[char](76), cast[char](229), cast[char](118), cast[char](105)], @[cast[char](119), cast[char](97), cast[char](116)]]
    testTargetCases: seq[char] = @[@[cast[char](118), cast[char](97), cast[char](116)], @[cast[char](119), cast[char](97), cast[char](121)], @[cast[char](97), cast[char](120), cast[char](98), cast[char](101), cast[char](99), cast[char](107)], @[cast[char](76), cast[char](228), cast[char](119), cast[char](101)], @[cast[char](118), cast[char](97), cast[char](116)]]
    results: seq[int] = @[1, -1, 1, -1, 1]
    myCollation: Collator = nil

proc newCollationFinnishTest(): CollationFinnishTest =

proc Init*() =
    myCollation = Collator.GetInstance(UCultureInfo("fi_FI@collation=standard"))
proc TestPrimary*() =
    var i: int = 0
    myCollation.Strength = Collator.Primary
      i = 4
      while i < 5:
DoTest(testSourceCases[i], testTargetCases[i], results[i])
++i
proc TestTertiary*() =
    var i: int = 0
    myCollation.Strength = Collator.Tertiary
      i = 0
      while i < 4:
DoTest(testSourceCases[i], testTargetCases[i], results[i])
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