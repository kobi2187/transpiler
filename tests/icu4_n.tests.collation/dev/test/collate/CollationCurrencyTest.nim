# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationCurrencyTest = ref object


proc TestCurrency*() =
    var currency: char[][] = @[@[cast[char](164)], @[cast[char](162)], @[cast[char](65504)], @[cast[char](36)], @[cast[char](65284)], @[cast[char](65129)], @[cast[char](163)], @[cast[char](65505)], @[cast[char](165)], @[cast[char](65509)], @[cast[char](2546)], @[cast[char](2547)], @[cast[char](3647)], @[cast[char](6107)], @[cast[char](8352)], @[cast[char](8353)], @[cast[char](8354)], @[cast[char](8355)], @[cast[char](8356)], @[cast[char](8357)], @[cast[char](8358)], @[cast[char](8359)], @[cast[char](8361)], @[cast[char](65510)], @[cast[char](8362)], @[cast[char](8363)], @[cast[char](8364)], @[cast[char](8365)], @[cast[char](8366)], @[cast[char](8367)]]
      var i: int
      var j: int
    var expectedResult: int = 0
    var c: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en")))
    var source: String
    var target: String
      i = 0
      while i < currency.Length:
            j = 0
            while j < currency.Length:
                source = String(currency[i])
                target = String(currency[j])
                if i < j:
                    expectedResult = -1

                elif i == j:
                    expectedResult = 0
                else:
                    expectedResult = 1
                var compareResult: int = c.Compare(source, target)
                var sourceKey: CollationKey = nil
                sourceKey = c.GetCollationKey(source)
                if sourceKey == nil:
Errln("Couldn't get collationKey for source")
                    continue
                var targetKey: CollationKey = nil
                targetKey = c.GetCollationKey(target)
                if targetKey == nil:
Errln("Couldn't get collationKey for source")
                    continue
                var keyResult: int = sourceKey.CompareTo(targetKey)
ReportCResult(source, target, sourceKey, targetKey, compareResult, keyResult, compareResult, expectedResult)
                j = 1
          i = 1
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