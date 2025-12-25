# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationMonkeyTest = ref object
    source: String = "-abcdefghijklmnopqrstuvwxyz#&^$@"

proc TestCollationKey*() =
    if source.Length == 0:
Errln("CollationMonkeyTest.TestCollationKey(): source is empty - ICU_DATA not set or data missing?")
        return
    var myCollator: Collator
    try:
        myCollator = Collator.GetInstance(CultureInfo("en-US"))
    except Exception:
Warnln("ERROR: in creation of collator of ENGLISH locale")
        return
    var rand: Random = CreateRandom
    var s: int = rand.Next(32767) % source.Length
    var t: int = rand.Next(32767) % source.Length
    var slen: int = Math.Abs(rand.Next(32767) % source.Length - source.Length) % source.Length
    var tlen: int = Math.Abs(rand.Next(32767) % source.Length - source.Length) % source.Length
    var subs: String = source.Substring(Math.Min(s, slen), Math.Min(s + slen, source.Length) - Math.Min(s, slen))
    var subt: String = source.Substring(Math.Min(t, tlen), Math.Min(t + tlen, source.Length) - Math.Min(t, tlen))
      var collationKey1: CollationKey
      var collationKey2: CollationKey
    myCollator.Strength = Collator.Tertiary
    collationKey1 = myCollator.GetCollationKey(subs)
    collationKey2 = myCollator.GetCollationKey(subt)
    var result: int = collationKey1.CompareTo(collationKey2)
    var revResult: int = collationKey2.CompareTo(collationKey1)
report(subs, subt, result, revResult)
    myCollator.Strength = Collator.Secondary
    collationKey1 = myCollator.GetCollationKey(subs)
    collationKey2 = myCollator.GetCollationKey(subt)
    result = collationKey1.CompareTo(collationKey2)
    revResult = collationKey2.CompareTo(collationKey1)
report(subs, subt, result, revResult)
    myCollator.Strength = Collator.Primary
    collationKey1 = myCollator.GetCollationKey(subs)
    collationKey2 = myCollator.GetCollationKey(subt)
    result = collationKey1.CompareTo(collationKey2)
    revResult = collationKey2.CompareTo(collationKey1)
report(subs, subt, result, revResult)
    var msg: String = ""
    var addOne: String = subs + 57344.ToString(CultureInfo.InvariantCulture)
    collationKey1 = myCollator.GetCollationKey(subs)
    collationKey2 = myCollator.GetCollationKey(addOne)
    result = collationKey1.CompareTo(collationKey2)
    if result != -1:
        msg = "CollationKey("
        msg = subs
        msg = ") .LT. CollationKey("
        msg = addOne
        msg = ") Failed."
Errln(msg)
    msg = ""
    result = collationKey2.CompareTo(collationKey1)
    if result != 1:
        msg = "CollationKey("
        msg = addOne
        msg = ") .GT. CollationKey("
        msg = subs
        msg = ") Failed."
Errln(msg)
proc TestCompare*() =
    if source.Length == 0:
Errln("CollationMonkeyTest.TestCompare(): source is empty - ICU_DATA not set or data missing?")
        return
    var myCollator: Collator
    try:
        myCollator = Collator.GetInstance(CultureInfo("en-US"))
    except Exception:
Warnln("ERROR: in creation of collator of ENGLISH locale")
        return
    var rand: Random = CreateRandom
    var s: int = rand.Next(32767) % source.Length
    var t: int = rand.Next(32767) % source.Length
    var slen: int = Math.Abs(rand.Next(32767) % source.Length - source.Length) % source.Length
    var tlen: int = Math.Abs(rand.Next(32767) % source.Length - source.Length) % source.Length
    var subs: String = source.Substring(Math.Min(s, slen), Math.Min(s + slen, source.Length) - Math.Min(s, slen))
    var subt: String = source.Substring(Math.Min(t, tlen), Math.Min(t + tlen, source.Length) - Math.Min(t, tlen))
    myCollator.Strength = Collator.Tertiary
    var result: int = myCollator.Compare(subs, subt)
    var revResult: int = myCollator.Compare(subt, subs)
report(subs, subt, result, revResult)
    myCollator.Strength = Collator.Secondary
    result = myCollator.Compare(subs, subt)
    revResult = myCollator.Compare(subt, subs)
report(subs, subt, result, revResult)
    myCollator.Strength = Collator.Primary
    result = myCollator.Compare(subs, subt)
    revResult = myCollator.Compare(subt, subs)
report(subs, subt, result, revResult)
    var msg: String = ""
    var addOne: String = subs + 57344.ToString(CultureInfo.InvariantCulture)
    result = myCollator.Compare(subs, addOne)
    if result != -1:
        msg = "Test : "
        msg = subs
        msg = " .LT. "
        msg = addOne
        msg = " Failed."
Errln(msg)
    msg = ""
    result = myCollator.Compare(addOne, subs)
    if result != 1:
        msg = "Test : "
        msg = addOne
        msg = " .GT. "
        msg = subs
        msg = " Failed."
Errln(msg)
proc report(s: String, t: String, result: int, revResult: int) =
    if revResult != -result:
        var msg: String = ""
        msg = s
        msg = " and "
        msg = t
        msg = " round trip comparison failed"
        msg = " (result " + result + ", reverse Result " + revResult + ")"
Errln(msg)
proc TestRules*() =
    var testSourceCases: String[] = @["abz", "abz"]
    var testTargetCases: String[] = @["abä", "abä"]
    var i: int = 0
Logln("Demo Test 1 : Create a new table collation with rules "& z < 0x00e4"")
    var col: Collator = Collator.GetInstance(CultureInfo("en-US"))
    var baseRules: String = cast[RuleBasedCollator](col).GetRules
    var newRules: String = " & z < "
    newRules = baseRules + newRules + 228.ToString(CultureInfo.InvariantCulture)
    var myCollation: RuleBasedCollator = nil
    try:
        myCollation = RuleBasedCollator(newRules)
    except Exception:
Warnln("Demo Test 1 Table Collation object creation failed.")
        return
      i = 0
      while i < 2:
doTest(myCollation, testSourceCases[i], testTargetCases[i], -1)
++i
Logln("Demo Test 2 : Create a new table collation with rules "& z < a 0x0308"")
    newRules = ""
    newRules = baseRules + " & z < a" + 776.ToString(CultureInfo.InvariantCulture)
    try:
        myCollation = RuleBasedCollator(newRules)
    except Exception:
Errln("Demo Test 1 Table Collation object creation failed.")
        return
      i = 0
      while i < 2:
doTest(myCollation, testSourceCases[i], testTargetCases[i], -1)
++i
proc doTest(myCollation: RuleBasedCollator, mysource: String, target: String, result: int) =
    var compareResult: int = myCollation.Compare(source, target)
      var sortKey1: CollationKey
      var sortKey2: CollationKey
    try:
        sortKey1 = myCollation.GetCollationKey(source)
        sortKey2 = myCollation.GetCollationKey(target)
    except Exception:
Errln("SortKey generation Failed.
")
        return
    var keyResult: int = sortKey1.CompareTo(sortKey2)
reportCResult(mysource, target, sortKey1, sortKey2, compareResult, keyResult, compareResult, result)
proc reportCResult*(src: String, target: String, sourceKey: CollationKey, targetKey: CollationKey, compareResult: int, keyResult: int, incResult: int, expectedResult: int) =
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
Logln(msg1 + src + msg2 + target + msg3 + sResult)
        else:
Errln(msg1 + src + msg2 + target + msg3 + sResult + msg4 + sExpect)
        msg1 =         if ok2:
"Ok: key(""
        else:
"FAIL: key(""
        msg2 = "").compareTo(key(""
        msg3 = "")) returned "
        sResult = CollationTest.AppendCompareResult(keyResult, sResult)
        if ok2:
Logln(msg1 + src + msg2 + target + msg3 + sResult)
        else:
Errln(msg1 + src + msg2 + target + msg3 + sResult + msg4 + sExpect)
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
Logln(msg1 + src + msg2 + target + msg3 + sResult)
        else:
Errln(msg1 + src + msg2 + target + msg3 + sResult + msg4 + sExpect)