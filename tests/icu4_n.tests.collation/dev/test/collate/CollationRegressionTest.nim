# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationRegressionTest = ref object


proc Test4048446*() =
    var test1: String = "XFILE What subset of all possible test cases has the highest probability of detecting the most errors?"
    var en_us: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    var i1: CollationElementIterator = en_us.GetCollationElementIterator(test1)
    var i2: CollationElementIterator = en_us.GetCollationElementIterator(test1)
    if i1 == nil || i2 == nil:
Errln("Could not create CollationElementIterator's")
        return
    while i1.Next != CollationElementIterator.NullOrder:

i1.Reset
assertEqual(i1, i2)
proc assertEqual(i1: CollationElementIterator, i2: CollationElementIterator) =
      var c1: int
      var c2: int
      var count: int = 0
    while true:
        c1 = i1.Next
        c2 = i2.Next
        if c1 != c2:
            var msg: String = ""
            var msg1: String = "    "
            msg = msg1 + count
            msg = ": strength(0x" + c1.ToHexString
            msg = ") != strength(0x" + c2.ToHexString
            msg = ")"
Errln(msg)
            break
        count = 1
        if notc1 != CollationElementIterator.NullOrder:
            break
proc Test4051866*() =
    var rules: String = "&n < o & oe ,oむ& oe ,ᔰ ,O& OE ,Oむ& OE ,ᔠ< p ,P"
    var c1: RuleBasedCollator = nil
    try:
        c1 = RuleBasedCollator(rules)
    except Exception:
Errln("Fail to create RuleBasedCollator with rules:" + rules)
        return
    var c2: RuleBasedCollator = nil
    try:
        c2 = RuleBasedCollator(c1.GetRules)
    except Exception:
Errln("Fail to create RuleBasedCollator with rules:" + rules)
        return
    if !c1.GetRules.Equals(c2.GetRules):
Errln("Rules are not equal")
proc Test4053636*() =
    var en_us: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    if en_us.Equals("black_bird", "black"):
Errln("black-bird == black")
proc Test4054238*() =
    var chars3: char[] = @[cast[char](97), cast[char](252), cast[char](98), cast[char](101), cast[char](99), cast[char](107), cast[char](32), cast[char](71), cast[char](114), cast[char](246), cast[char](223), cast[char](101), cast[char](32), cast[char](76), cast[char](252), cast[char](98), cast[char](99), cast[char](107), cast[char](0)]
    var test3: String = String(chars3)
    var c: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    c.Decomposition = Collator.NoDecomposition
    var i1: CollationElementIterator = c.GetCollationElementIterator(test3)
Logln("Offset:" + i1.GetOffset)
proc Test4054734*() =
    var decomp: String[] = @["", "<", "", "", "=", "", "A", ">", "~", "À", "=", "À"]
    var c: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    c.Strength = Collator.Identical
    c.Decomposition = Collator.CanonicalDecomposition
CompareArray(c, decomp)
proc CompareArray(c: Collator, tests: seq[String]) =
    var expectedResult: int = 0
      var i: int = 0
      while i < tests.Length:
          var source: String = tests[i]
          var comparison: String = tests[i + 1]
          var target: String = tests[i + 2]
          if comparison.Equals("<"):
              expectedResult = -1

          elif comparison.Equals(">"):
              expectedResult = 1
          else:
            if comparison.Equals("="):
                expectedResult = 0
            else:
Errln("Bogus comparison string "" + comparison + """)
          var compareResult: int = 0
Logln("i = " + i)
Logln(source)
Logln(target)
          try:
              compareResult = c.Compare(source, target)
          except Exception:
Errln(e.ToString)
            var sourceKey: CollationKey = nil
            var targetKey: CollationKey = nil
          try:
              sourceKey = c.GetCollationKey(source)
          except Exception:
Errln("Couldn't get collationKey for source")
              continue
          try:
              targetKey = c.GetCollationKey(target)
          except Exception:
Errln("Couldn't get collationKey for target")
              continue
          var keyResult: int = sourceKey.CompareTo(targetKey)
ReportCResult(source, target, sourceKey, targetKey, compareResult, keyResult, compareResult, expectedResult)
          i = 3
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
proc Test4054736*() =
    var c: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    c.Strength = Collator.Secondary
    c.Decomposition = Collator.NoDecomposition
    var tests: String[] = @["ﭏ", "=", "אל"]
CompareArray(c, tests)
proc Test4058613*() =
    var oldDefault: CultureInfo = CultureInfo.CurrentCulture
    System.Threading.Thread.CurrentThread.CurrentCulture = CultureInfo("ko")
    var c: Collator = nil
    c = Collator.GetInstance(CultureInfo("en-US"))
    if c == nil:
Errln("Could not create a Korean collator")
        System.Threading.Thread.CurrentThread.CurrentCulture = oldDefault
        return
    if c.Decomposition != Collator.NoDecomposition:
Errln("Decomposition is not set to NO_DECOMPOSITION for Korean collator")
    System.Threading.Thread.CurrentThread.CurrentCulture = oldDefault
proc Test4059820*() =
    var c: RuleBasedCollator = nil
    var rules: String = "&9 < a < b , c/a < d < z"
    try:
        c = RuleBasedCollator(rules)
    except Exception:
Errln("Failure building a collator.")
        return
    if c.GetRules.IndexOf("c/a", StringComparison.Ordinal) == -1:
Errln("returned rules do not contain 'c/a'")
proc Test4060154*() =
    var rules: String = "&f < g, G < h, H < i, I < j, J & H < ı, İ, i, I"
    var c: RuleBasedCollator = nil
    try:
        c = RuleBasedCollator(rules)
    except Exception:
Errln("failure building collator:" + e)
        return
    c.Decomposition = Collator.NoDecomposition
    var tertiary: String[] = @["A", "<", "B", "H", "<", "ı", "H", "<", "I", "ı", "<", "İ", "İ", "<", "i", "İ", ">", "H"]
    c.Strength = Collator.Tertiary
CompareArray(c, tertiary)
    var secondary: String[] = @["H", "<", "I", "ı", "=", "İ"]
    c.Strength = Collator.Primary
CompareArray(c, secondary)
proc Test4062418*() =
    var c: RuleBasedCollator = nil
    try:
        c = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("fr-CA")))
    except Exception:
Errln("Failed to create collator for Locale.CANADA_FRENCH")
        return
    c.Strength = Collator.Secondary
    var tests: String[] = @["pêche", "<", "péché"]
CompareArray(c, tests)
proc Test4065540*() =
    var en_us: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    if en_us.Compare("abcd e", "abcd f") == 0:
Errln("'abcd e' == 'abcd f'")
proc Test4066189*() =
    var test1: String = "ằ"
    var test2: String = "ằ"
    var c1: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    c1.Decomposition = Collator.CanonicalDecomposition
    var i1: CollationElementIterator = c1.GetCollationElementIterator(test1)
    var c2: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    c2.Decomposition = Collator.NoDecomposition
    var i2: CollationElementIterator = c2.GetCollationElementIterator(test2)
assertEqual(i1, i2)
proc Test4066696*() =
    var c: RuleBasedCollator = nil
    try:
        c = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("fr-CA")))
    except Exception:
Errln("Failure creating collator for Locale.CANADA_FRENCH")
        return
    c.Strength = Collator.Secondary
    var tests: String[] = @["à", ">", "Ǻ"]
CompareArray(c, tests)
proc Test4076676*() =
    var s1: String = "Á̂̀"
    var s2: String = "Ầ́"
    var c: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    c.Strength = Collator.Tertiary
    if c.Compare(s1, s2) == 0:
Errln("Same-class combining chars were reordered")
proc Test4078588*() =
    var rbc: RuleBasedCollator = nil
    try:
        rbc = RuleBasedCollator("&9 < a < bb")
    except Exception:
Errln("Failed to create RuleBasedCollator.")
        return
    var result: int = rbc.Compare("a", "bb")
    if result >= 0:
Errln("Compare(a,bb) returned " + result + "; expected -1")
proc Test4079231*() =
    var en_us: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    try:
        if en_us.Equals(nil):
Errln("en_us.Equals(null) returned true")
    except Exception:
Errln("en_us.Equals(null) threw " + e.ToString)
proc Test4081866*() =
    var s1: String = "À̧̖̕"
    var s2: String = "À̧̖̕"
    var c: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    c.Strength = Collator.Tertiary
    c.Decomposition = Collator.CanonicalDecomposition
    if c.Compare(s1, s2) != 0:
Errln("Combining chars were not reordered")
proc Test4087241*() =
    var da_DK: CultureInfo = CultureInfo("da-DK")
    var c: RuleBasedCollator = nil
    try:
        c = cast[RuleBasedCollator](Collator.GetInstance(da_DK))
    except Exception:
Errln("Failed to create collator for da_DK locale")
        return
    c.Strength = Collator.Secondary
    var tests: String[] = @["z", "<", "æ", "ä", "<", "å", "Y", "<", "ü"]
CompareArray(c, tests)
proc Test4087243*() =
    var c: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    c.Strength = Collator.Tertiary
    var tests: String[] = @["123", "=", "123"]
CompareArray(c, tests)
proc Test4092260*() =
    var el: CultureInfo = CultureInfo("el")
    var c: Collator = nil
    try:
        c = Collator.GetInstance(el)
    except Exception:
Errln("Failed to create collator for el locale.")
        return
    c.Strength = Collator.Secondary
    var tests: String[] = @["µ", "=", "μ"]
CompareArray(c, tests)
proc Test4095316*() =
    var el_GR: CultureInfo = CultureInfo("el-GR")
    var c: Collator = nil
    try:
        c = Collator.GetInstance(el_GR)
    except Exception:
Errln("Failed to create collator for el_GR locale")
        return
    c.Strength = Collator.Secondary
    var tests: String[] = @["ϔ", "=", "Ϋ"]
CompareArray(c, tests)
proc Test4101940*() =
    var c: RuleBasedCollator = nil
    var rules: String = "&9 < a < b"
    var nothing: String = ""
    try:
        c = RuleBasedCollator(rules)
    except Exception:
Errln("Failed to create RuleBasedCollator")
        return
    var i: CollationElementIterator = c.GetCollationElementIterator(nothing)
i.Reset
    if i.Next != CollationElementIterator.NullOrder:
Errln("next did not return NULLORDER")
proc Test4103436*() =
    var c: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    c.Strength = Collator.Tertiary
    var tests: String[] = @["file", "<", "file access", "file", "<", "fileaccess"]
CompareArray(c, tests)
proc Test4114076*() =
    var c: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    c.Strength = Collator.Tertiary
    var test1: String[] = @["퓛", "=", "퓛"]
    c.Decomposition = Collator.CanonicalDecomposition
CompareArray(c, test1)
proc Test4114077*() =
    var c: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    c.Strength = Collator.Tertiary
    var test1: String[] = @["À", "=", "À", "pêche", ">", "péché", "Ȅ", "=", "Ȅ", "Ǻ", "=", "Ǻ", "À̖", "<", "À̖"]
    c.Decomposition = Collator.NoDecomposition
CompareArray(c, test1)
    var test2: String[] = @["À̖", "=", "À̖"]
    c.Decomposition = Collator.CanonicalDecomposition
CompareArray(c, test2)
proc Test4124632*() =
    var coll: Collator = nil
    try:
        coll = Collator.GetInstance(CultureInfo("ja-JP"))
    except Exception:
Errln("Failed to create collator for Locale::JAPAN")
        return
    var test: String = "Äbc"
    var key: CollationKey
    try:
        key = coll.GetCollationKey(test)
Logln(key.SourceString)
    except Exception:
Errln("CollationKey creation failed.")
proc Test4132736*() =
    var c: Collator = nil
    try:
        c = Collator.GetInstance(CultureInfo("fr-CA"))
        c.Strength = Collator.Tertiary
    except Exception:
Errln("Failed to create a collator for Locale.CANADA_FRENCH")
    var test1: String[] = @["èé", "<", "éè", "è́", "<", "é̀"]
CompareArray(c, test1)
proc Test4133509*() =
    var en_us: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    var test1: String[] = @["Exception", "<", "ExceptionInInitializerError", "Graphics", "<", "GraphicsEnvironment", "String", "<", "StringBuffer"]
CompareArray(en_us, test1)
proc Test4139572*() =
    var l: CultureInfo = CultureInfo("es-es")
    var col: Collator = nil
    try:
        col = Collator.GetInstance(l)
    except Exception:
Errln("Failed to create a collator for es_es locale.")
        return
    var key: CollationKey = nil
    try:
        key = col.GetCollationKey("Nombre De Objeto")
Logln("source:" + key.SourceString)
    except Exception:
Errln("Error creating CollationKey for "Nombre De Ojbeto"")
proc Test4141640*() =
    var locales: CultureInfo[] = Collator.GetCultures(UCultureTypes.AllCultures)
      var i: int = 0
      while i < locales.Length:
          var c: Collator = nil
          try:
              c = Collator.GetInstance(locales[i])
Logln("source: " + c.Strength)
          except Exception:
              var msg: String = ""
              msg = "Could not create collator for locale "
              msg = locales[i].DisplayName
Errln(msg)
          i = 1
proc CheckListOrder(sortedList: seq[String], c: Collator) =
      var i: int = 0
      while i < sortedList.Length - 1:
          if c.Compare(sortedList[i], sortedList[i + 1]) >= 0:
Errln("List out of order at element #" + i + ": " + sortedList[i] + " >= " + sortedList[i + 1])
++i
proc Test4171974*() =
    var englishList: String[] = @["uu", "uü", "uǖ", "uū", "uṻ", "üu", "üü", "üǖ", "üū", "üṻ", "ǖu", "ǖü", "ǖǖ", "ǖū", "ǖṻ", "ūu", "ūü", "ūǖ", "ūū", "ūṻ", "ṻu", "ṻü", "ṻǖ", "ṻū", "ṻṻ"]
    var english: Collator = Collator.GetInstance(CultureInfo("en"))
Logln("Testing English order...")
CheckListOrder(englishList, english)
Logln("Testing English order without decomposition...")
    english.Decomposition = Collator.NoDecomposition
CheckListOrder(englishList, english)
proc Test4179216*() =
    var coll: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    coll = RuleBasedCollator(coll.GetRules + " & C < ch , cH , Ch , CH < cat < crunchy")
    var testText: String = "church church catcatcher runcrunchynchy"
    var iter: CollationElementIterator = coll.GetCollationElementIterator(testText)
iter.SetOffset(4)
    var elt4: int = CollationElementIterator.PrimaryOrder(iter.Next)
iter.Reset
    var elt0: int = CollationElementIterator.PrimaryOrder(iter.Next)
iter.SetOffset(5)
    var elt5: int = CollationElementIterator.PrimaryOrder(iter.Next)
    if elt4 != elt0 || elt5 != elt0:
Errln(String.Format("The collation elements at positions 0 (0x{0:x4}), " + "4 (0x{1:x4}), and 5 (0x{2:x4}) don't match.", elt0, elt4, elt5))
iter.SetOffset(14)
    var elt14: int = CollationElementIterator.PrimaryOrder(iter.Next)
iter.SetOffset(15)
    var elt15: int = CollationElementIterator.PrimaryOrder(iter.Next)
iter.SetOffset(16)
    var elt16: int = CollationElementIterator.PrimaryOrder(iter.Next)
iter.SetOffset(17)
    var elt17: int = CollationElementIterator.PrimaryOrder(iter.Next)
iter.SetOffset(18)
    var elt18: int = CollationElementIterator.PrimaryOrder(iter.Next)
iter.SetOffset(19)
    var elt19: int = CollationElementIterator.PrimaryOrder(iter.Next)
    if elt14 != elt15 || elt14 != elt16 || elt14 != elt17 || elt14 != elt18 || elt14 != elt19:
Errln(String.Format(""cat" elements don't match: elt14 = 0x{0:x4}, " + "elt15 = 0x{1:x4}, elt16 = 0x{2:x4}, elt17 = 0x{3:x4}, " + "elt18 = 0x{4:x4}, elt19 = 0x{5:x4}", elt14, elt15, elt16, elt17, elt18, elt19))
iter.Reset
    var elt: int = iter.Next
    var count: int = 0
    while elt != CollationElementIterator.NullOrder:
++count
        elt = iter.Next
    var nextElements: String[] = seq[String]
    var setOffsetElements: String[] = seq[String]
    var lastPos: int = 0
iter.Reset
    elt = iter.Next
    count = 0
    while elt != CollationElementIterator.NullOrder:
        nextElements[++count] = testText.Substring(lastPos, iter.GetOffset - lastPos)
        lastPos = iter.GetOffset
        elt = iter.Next
    count = 0
      var i: int = 0
      while i < testText.Length:
iter.SetOffset(i)
          lastPos = iter.GetOffset
          elt = iter.Next
          setOffsetElements[++count] = testText.Substring(lastPos, iter.GetOffset - lastPos)
          i = iter.GetOffset
      var i: int = 0
      while i < nextElements.Length:
          if nextElements[i].Equals(setOffsetElements[i]):
Logln(nextElements[i])
          else:
Errln("Error: next() yielded " + nextElements[i] + ", but setOffset() yielded " + setOffsetElements[i])
++i
proc Test4216006*() =
    var caughtException: bool = false
    try:
RuleBasedCollator("à<à")
    except FormatException:
        caughtException = true
    if !caughtException:
        raise Exception(""a<a" collation sequence didn't cause parse error!")
    var collator: RuleBasedCollator = RuleBasedCollator("&a<à=à")
    collator.Strength = Collator.Identical
    var tests: String[] = @["à", "=", "à", "à", "=", "à"]
CompareArray(collator, tests)
proc Test4179686*() =
    var en_us: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    var coll: RuleBasedCollator = RuleBasedCollator(en_us.GetRules + " & ae ; ä & AE ; Ä" + " & oe ; ö & OE ; Ö" + " & ue ; ü & UE ; Ü")
    var text: String = "Töne"
    var iter: CollationElementIterator = coll.GetCollationElementIterator(text)
    var elements: List<object> = List<object>
    var elem: int
    while     elem = iter.Next != CollationElementIterator.NullOrder:
elements.Add(elem)
iter.Reset
    var index: int = elements.Count - 1
    while     elem = iter.Previous != CollationElementIterator.NullOrder:
        var expect: int = cast[int](elements[index])
        if elem != expect:
Errln("Mismatch at index " + index + ": got " + Convert.ToString(elem, 16) + ", expected " + Convert.ToString(expect, 16))
--index
proc Test4244884*() =
    var coll: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    coll = RuleBasedCollator(coll.GetRules + " & C < ch , cH , Ch , CH < cat < crunchy")
    var testStrings: String[] = @["car", "cave", "clamp", "cramp", "czar", "church", "catalogue", "crunchy", "dog"]
      var i: int = 1
      while i < testStrings.Length:
          if coll.Compare(testStrings[i - 1], testStrings[i]) >= 0:
Errln("error: "" + testStrings[i - 1] + "" is greater than or equal to "" + testStrings[i] + "".")
++i
proc Test4663220*() =
    var collator: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    var stringIter: StringCharacterIterator = StringCharacterIterator("fox")
    var iter: CollationElementIterator = collator.GetCollationElementIterator(stringIter)
    var elements_next: int[] = seq[int]
Logln("calling next:")
      var i: int = 0
      while i < 3:
Logln("[" + i + "] " +           elements_next[i] = iter.Next)
++i
    var elements_fwd: int[] = seq[int]
Logln("calling set/next:")
      var i: int = 0
      while i < 3:
iter.SetOffset(i)
Logln("[" + i + "] " +           elements_fwd[i] = iter.Next)
++i
      var i: int = 0
      while i < 3:
          if elements_next[i] != elements_fwd[i]:
Errln("mismatch at position " + i + ": " + elements_next[i] + " != " + elements_fwd[i])
++i
proc Test8484*() =
    var s: String = "鿡컳➘ꪶ�"
    var coll: Collator = Collator.GetInstance
    var collKey: CollationKey = coll.GetCollationKey(s)
Logln("Pass: " + collKey.ToString + " generated OK.")
proc TestBengaliSortKey*() =
    var rules: char[] = @[cast[char](38), cast[char](2554), cast[char](60), cast[char](2444), cast[char](60), cast[char](2529), cast[char](60), cast[char](2447), cast[char](60), cast[char](2448), cast[char](60), cast[char](2451), cast[char](60), cast[char](2452), cast[char](60), cast[char](2492), cast[char](60), cast[char](2434), cast[char](60), cast[char](2435), cast[char](60), cast[char](2433), cast[char](60), cast[char](2480), cast[char](60), cast[char](2488), cast[char](60), cast[char](2489), cast[char](60), cast[char](2493), cast[char](60), cast[char](2494), cast[char](60), cast[char](2495), cast[char](60), cast[char](2504), cast[char](60), cast[char](2507), cast[char](61), cast[char](2507)]
    var col: Collator = RuleBasedCollator(String(rules))
    var str1: String = "া"
    var str2: String = "୰"
    var result: int = col.Compare(str1, str2)
Console.Out.Flush
    if result >= 0:
Errln("
ERROR: result is " + result + " , wanted negative.")
Errln(PrintKey(col, str1).ToString)
Errln(PrintKey(col, str2).ToString)
    else:
Logln("Pass: result is OK.")
proc PrintKey(col: Collator, str1: String): StringBuilder =
    var sb: StringBuilder = StringBuilder
    var sortk1: CollationKey = col.GetCollationKey(str1)
    var bytes: byte[] = sortk1.ToByteArray
      var i: int = 0
      while i < str1.Length:
sb.Append("\u" + str1[i].ToHexString)
++i
Console.Out.Write(": ")
      var i: int = 0
      while i < bytes.Length:
sb.Append(" 0x" + bytes[i] & 255.ToHexString)
++i
sb.Append("
")
    return sb
proc TestCaseFirstCompression*() =
    var col: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
CaseFirstCompressionSub(col, "default")
    col.IsUpperCaseFirst = true
CaseFirstCompressionSub(col, "upper first")
    col.IsLowerCaseFirst = true
CaseFirstCompressionSub(col, "lower first")
proc TestTrailingComment*() =
    var coll: RuleBasedCollator = RuleBasedCollator("&c<b#comment1
<a#comment2")
assertTrue("c<b", coll.Compare("c", "b") < 0)
assertTrue("b<a", coll.Compare("b", "a") < 0)
proc TestBeforeWithTooStrongAfter*() =
    try:
RuleBasedCollator("&[before 2]x<<q<p")
Errln("should forbid before-2-reset followed by primary relation")
    except Exception:

    try:
RuleBasedCollator("&[before 3]x<<<q<<s<p")
Errln("should forbid before-3-reset followed by primary or secondary relation")
    except Exception:

proc CaseFirstCompressionSub(col: RuleBasedCollator, opt: String) =
    var maxLength: int = 50
    var buf1: StringBuilder = StringBuilder
    var buf2: StringBuilder = StringBuilder
      var str1: String
      var str2: String
      var n: int = 1
      while n <= maxLength:
          buf1.Length = 0
          buf2.Length = 0
            var i: int = 0
            while i < n - 1:
buf1.Append('a')
buf2.Append('a')
++i
buf1.Append('A')
buf2.Append('a')
          str1 = buf1.ToString
          str2 = buf2.ToString
          var key1: CollationKey = col.GetCollationKey(str1)
          var key2: CollationKey = col.GetCollationKey(str2)
          var cmpKey: int = key1.CompareTo(key2)
          var cmpCol: int = col.Compare(str1, str2)
          if cmpKey < 0 && cmpCol >= 0 || cmpKey > 0 && cmpCol <= 0 || cmpKey == 0 && cmpCol != 0:
Errln("Inconsistent comparison(" + opt + "): str1=" + str1 + ", str2=" + str2 + ", cmpKey=" + cmpKey + " , cmpCol=" + cmpCol)
++n