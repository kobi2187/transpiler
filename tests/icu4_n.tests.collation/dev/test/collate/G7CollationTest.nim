# "Namespace: ICU4N.Dev.Test.Collate"
type
  G7CollationTest = ref object
    testCases: seq[String] = @["blackbirds", "Pat", "péché", "pêche", "pécher", "pêcher", "Tod", "Töne", "Tofu", "blackbird", "Ton", "PAT", "black-bird", "black-birds", "pat", "czar", "churo", "cat", "darn", "?", "quick", "#", "&", "a-rdvark", "aardvark", "abbot", "co-p", "cop", "coop", "zebra"]
    results: seq[int] = @[@[12, 13, 9, 0, 14, 1, 11, 2, 3, 4, 5, 6, 8, 10, 7, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31], @[12, 13, 9, 0, 14, 1, 11, 2, 3, 4, 5, 6, 8, 10, 7, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31], @[12, 13, 9, 0, 14, 1, 11, 2, 3, 4, 5, 6, 8, 10, 7, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31], @[12, 13, 9, 0, 14, 1, 11, 2, 3, 4, 5, 6, 8, 10, 7, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31], @[12, 13, 9, 0, 14, 1, 11, 3, 2, 4, 5, 6, 8, 10, 7, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31], @[12, 13, 9, 0, 14, 1, 11, 2, 3, 4, 5, 6, 8, 10, 7, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31], @[12, 13, 9, 0, 14, 1, 11, 2, 3, 4, 5, 6, 8, 10, 7, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31], @[12, 13, 9, 0, 14, 1, 11, 2, 3, 4, 5, 6, 8, 10, 7, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31], @[12, 13, 9, 0, 6, 8, 10, 7, 14, 1, 11, 2, 3, 4, 5, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31], @[19, 22, 21, 23, 24, 25, 12, 13, 9, 0, 17, 26, 28, 27, 15, 16, 18, 14, 1, 11, 2, 3, 4, 5, 20, 6, 8, 10, 7, 29], @[23, 24, 25, 22, 12, 13, 9, 0, 17, 16, 26, 28, 27, 15, 18, 21, 14, 1, 11, 2, 3, 4, 5, 19, 20, 6, 8, 10, 7, 29], @[19, 22, 21, 24, 23, 25, 12, 13, 9, 0, 17, 16, 28, 26, 27, 15, 18, 14, 1, 11, 2, 3, 4, 5, 20, 6, 8, 10, 7, 29]]
    FIXEDTESTSET: int = 15
    TOTALTESTSET: int = 30

proc TestDemo1*() =
Logln("Demo Test 1 : Create a new table collation with rules "& Z < p, P"")
    var col: Collator = Collator.GetInstance(CultureInfo("en"))
    var baseRules: String = cast[RuleBasedCollator](col).GetRules
    var newRules: String = " & Z < p, P"
    newRules = baseRules + newRules
    var myCollation: RuleBasedCollator = nil
    try:
        myCollation = RuleBasedCollator(newRules)
    except Exception:
Errln("Fail to create RuleBasedCollator with rules:" + newRules)
        return
      var j: int
      var n: int
      j = 0
      while j < FIXEDTESTSET:
            n = j + 1
            while n < FIXEDTESTSET:
DoTest(myCollation, testCases[results[8][j]], testCases[results[8][n]], -1)
++n
++j
proc TestDemo2*() =
Logln("Demo Test 2 : Create a new table collation with rules "& C < ch , cH, Ch, CH"")
    var col: Collator = Collator.GetInstance(CultureInfo("en"))
    var baseRules: String = cast[RuleBasedCollator](col).GetRules
    var newRules: String = "& C < ch , cH, Ch, CH"
    newRules = baseRules + newRules
    var myCollation: RuleBasedCollator = nil
    try:
        myCollation = RuleBasedCollator(newRules)
    except Exception:
Errln("Fail to create RuleBasedCollator with rules:" + newRules)
        return
      var j: int
      var n: int
      j = 0
      while j < TOTALTESTSET:
            n = j + 1
            while n < TOTALTESTSET:
DoTest(myCollation, testCases[results[9][j]], testCases[results[9][n]], -1)
++n
++j
proc TestDemo3*() =
    var col: Collator = Collator.GetInstance(CultureInfo("en"))
    var baseRules: String = cast[RuleBasedCollator](col).GetRules
    var newRules: String = "& Question'-'mark ; '?' & Hash'-'mark ; '#' & Ampersand ; '&'"
    newRules = baseRules + newRules
    var myCollation: RuleBasedCollator = nil
    try:
        myCollation = RuleBasedCollator(newRules)
    except Exception:
Errln("Fail to create RuleBasedCollator with rules:" + newRules)
        return
      var j: int
      var n: int
      j = 0
      while j < TOTALTESTSET:
            n = j + 1
            while n < TOTALTESTSET:
DoTest(myCollation, testCases[results[10][j]], testCases[results[10][n]], -1)
++n
++j
proc TestDemo4*() =
Logln("Demo Test 4 : Create a new table collation with rules " & aa ; a'-' & ee ; e'-' & ii ; i'-' & oo ; o'-' & uu ; u'-' "")
    var col: Collator = Collator.GetInstance(CultureInfo("en"))
    var baseRules: String = cast[RuleBasedCollator](col).GetRules
    var newRules: String = " & aa ; a'-' & ee ; e'-' & ii ; i'-' & oo ; o'-' & uu ; u'-' "
    newRules = baseRules + newRules
    var myCollation: RuleBasedCollator = nil
    try:
        myCollation = RuleBasedCollator(newRules)
    except Exception:
Errln("Fail to create RuleBasedCollator with rules:" + newRules)
        return
      var j: int
      var n: int
      j = 0
      while j < TOTALTESTSET:
            n = j + 1
            while n < TOTALTESTSET:
DoTest(myCollation, testCases[results[11][j]], testCases[results[11][n]], -1)
++n
++j
proc TestG7Data*() =
    var locales: CultureInfo[] = @[CultureInfo("en-US"), CultureInfo("en-GB"), CultureInfo("en-CA"), CultureInfo("fr-FR"), CultureInfo("fr-CA"), CultureInfo("de-DE"), CultureInfo("ja-JP"), CultureInfo("it-IT")]
      var i: int = 0
      var j: int = 0
      i = 0
      while i < locales.Length:
          var myCollation: Collator = nil
          var tblColl1: RuleBasedCollator = nil
          try:
              myCollation = Collator.GetInstance(locales[i])
              tblColl1 = RuleBasedCollator(cast[RuleBasedCollator](myCollation).GetRules)
          except Exception:
Warnln("Exception: " + foo.Message + "; Locale : " + locales[i].DisplayName + " getRules failed")
              continue
            j = 0
            while j < FIXEDTESTSET:
                  var n: int = j + 1
                  while n < FIXEDTESTSET:
DoTest(tblColl1, testCases[results[i][j]], testCases[results[i][n]], -1)
++n
++j
          myCollation = nil
++i
proc DoTest(myCollation: Collator, source: String, target: String, result: int) =
    var compareResult: int = myCollation.Compare(source, target)
      var sortKey1: CollationKey
      var sortKey2: CollationKey
    sortKey1 = myCollation.GetCollationKey(source)
    sortKey2 = myCollation.GetCollationKey(target)
    var keyResult: int = sortKey1.CompareTo(sortKey2)
ReportCResult(source, target, sortKey1, sortKey2, compareResult, keyResult, compareResult, result)
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