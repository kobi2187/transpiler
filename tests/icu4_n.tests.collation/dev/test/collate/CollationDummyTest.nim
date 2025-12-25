# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationDummyTest = ref object
    testSourceCases: seq[char] = @[@[cast[char](97), cast[char](98), cast[char](39), cast[char](99)], @[cast[char](99), cast[char](111), cast[char](45), cast[char](111), cast[char](112)], @[cast[char](97), cast[char](98)], @[cast[char](97), cast[char](109), cast[char](112), cast[char](101), cast[char](114), cast[char](115), cast[char](97), cast[char](100)], @[cast[char](97), cast[char](108), cast[char](108)], @[cast[char](102), cast[char](111), cast[char](117), cast[char](114)], @[cast[char](102), cast[char](105), cast[char](118), cast[char](101)], @[cast[char](49)], @[cast[char](49)], @[cast[char](49)], @[cast[char](50)], @[cast[char](50)], @[cast[char](72), cast[char](101), cast[char](108), cast[char](108), cast[char](111)], @[cast[char](97), cast[char](60), cast[char](98)], @[cast[char](97), cast[char](60), cast[char](98)], @[cast[char](97), cast[char](99), cast[char](99)], @[cast[char](97), cast[char](99), cast[char](72), cast[char](99)], @[cast[char](112), cast[char](234), cast[char](99), cast[char](104), cast[char](101)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](230), cast[char](99)], @[cast[char](97), cast[char](99), cast[char](72), cast[char](99)], @[cast[char](98), cast[char](108), cast[char](97), cast[char](99), cast[char](107)], @[cast[char](102), cast[char](111), cast[char](117), cast[char](114)], @[cast[char](102), cast[char](105), cast[char](118), cast[char](101)], @[cast[char](49)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99), cast[char](72)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](99), cast[char](72), cast[char](99)], @[cast[char](97), cast[char](99), cast[char](101), cast[char](48)], @[cast[char](49), cast[char](48)], @[cast[char](112), cast[char](234), cast[char](48)]]
    testTargetCases: seq[char] = @[@[cast[char](97), cast[char](98), cast[char](99), cast[char](39)], @[cast[char](67), cast[char](79), cast[char](79), cast[char](80)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](38)], @[cast[char](38)], @[cast[char](52)], @[cast[char](53)], @[cast[char](111), cast[char](110), cast[char](101)], @[cast[char](110), cast[char](110), cast[char](101)], @[cast[char](112), cast[char](110), cast[char](101)], @[cast[char](116), cast[char](119), cast[char](111)], @[cast[char](117), cast[char](119), cast[char](111)], @[cast[char](104), cast[char](101), cast[char](108), cast[char](108), cast[char](79)], @[cast[char](97), cast[char](60), cast[char](61), cast[char](98)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](67), cast[char](72), cast[char](99)], @[cast[char](97), cast[char](67), cast[char](72), cast[char](99)], @[cast[char](112), cast[char](233), cast[char](99), cast[char](104), cast[char](233)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](66), cast[char](67)], @[cast[char](97), cast[char](98), cast[char](99), cast[char](104)], @[cast[char](97), cast[char](98), cast[char](100)], @[cast[char](228), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](198), cast[char](99)], @[cast[char](97), cast[char](67), cast[char](72), cast[char](99)], @[cast[char](98), cast[char](108), cast[char](97), cast[char](99), cast[char](107), cast[char](45), cast[char](98), cast[char](105), cast[char](114), cast[char](100)], @[cast[char](52)], @[cast[char](53)], @[cast[char](111), cast[char](110), cast[char](101)], @[cast[char](97), cast[char](98), cast[char](99)], @[cast[char](97), cast[char](66), cast[char](99)], @[cast[char](97), cast[char](98), cast[char](99), cast[char](104)], @[cast[char](97), cast[char](98), cast[char](100)], @[cast[char](97), cast[char](67), cast[char](72), cast[char](99)], @[cast[char](97), cast[char](99), cast[char](101), cast[char](48)], @[cast[char](49), cast[char](48)], @[cast[char](112), cast[char](235), cast[char](48)]]
    testCases: seq[char] = @[@[cast[char](97)], @[cast[char](65)], @[cast[char](228)], @[cast[char](196)], @[cast[char](97), cast[char](101)], @[cast[char](97), cast[char](69)], @[cast[char](65), cast[char](101)], @[cast[char](65), cast[char](69)], @[cast[char](230)], @[cast[char](198)], @[cast[char](98)], @[cast[char](99)], @[cast[char](122)]]
    results: seq[int] = @[-1, -1, -1, -1, -1, -1, -1, 1, 1, -1, 1, -1, 1, 1, -1, -1, -1, 0, 0, 0, -1, -1, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, -1]
    MAX_TOKEN_LEN: int = 16
    myCollation: RuleBasedCollator
    SUPPORT_VARIABLE_TOP_RELATION: bool = false

proc newCollationDummyTest(): CollationDummyTest =

proc Init*() =
    var ruleset: String = "& C < ch, cH, Ch, CH & Five, 5 & Four, 4 & one, 1 & Ampersand; '&' & Two, 2 "
    myCollation = RuleBasedCollator(ruleset)
proc TestTertiary*() =
    var i: int = 0
    myCollation.Strength = Collator.Tertiary
      i = 0
      while i < 17:
DoTest(myCollation, testSourceCases[i], testTargetCases[i], results[i])
++i
proc TestPrimary*() =
    myCollation.Strength = Collator.Primary
      var i: int = 17
      while i < 26:
DoTest(myCollation, testSourceCases[i], testTargetCases[i], results[i])
++i
proc TestSecondary*() =
    var i: int
    myCollation.Strength = Collator.Secondary
      i = 26
      while i < 34:
DoTest(myCollation, testSourceCases[i], testTargetCases[i], results[i])
++i
proc TestExtra*() =
      var i: int
      var j: int
    myCollation.Strength = Collator.Tertiary
      i = 0
      while i < testCases.Length - 1:
            j = i + 1
            while j < testCases.Length:
DoTest(myCollation, testCases[i], testCases[j], -1)
                j = 1
++i
proc TestIdentical*() =
    var i: int
    myCollation.Strength = Collator.Identical
      i = 34
      while i < 37:
DoTest(myCollation, testSourceCases[i], testTargetCases[i], results[i])
++i
proc TestJB581*() =
    var source: String = "THISISATEST."
    var target: String = "Thisisatest."
    var coll: Collator = nil
    try:
        coll = Collator.GetInstance(CultureInfo("en"))
    except Exception:
Errln("ERROR: Failed to create the collator for : en_US
")
        return
    var result: int = coll.Compare(source, target)
    if result != 1:
Errln("Comparing two strings with only secondary differences in C failed.
")
        return
    coll.Strength = Collator.Primary
    result = coll.Compare(source, target)
    if result != 0:
Errln("Comparing two strings with no differences in C failed.
")
        return
      var sourceKeyOut: CollationKey
      var targetKeyOut: CollationKey
    sourceKeyOut = coll.GetCollationKey(source)
    targetKeyOut = coll.GetCollationKey(target)
    result = sourceKeyOut.CompareTo(targetKeyOut)
    if result != 0:
Errln("Comparing two strings with sort keys in C failed.
")
        return
proc TestSurrogates*() =
    var rules: String = "&z<'𐀀'<'𐀊̈'<A"
    var source: String[] = @["z", "𐀀", "𐀊̈", "𐀂"]
    var target: String[] = @["𐀀", "𐀊̈", "A", "𐀃"]
    var enCollation: Collator
    try:
        enCollation = Collator.GetInstance(CultureInfo("en"))
    except Exception:
Errln("ERROR: Failed to create the collator for ENGLISH")
        return
    myCollation.Strength = Collator.Tertiary
    var count: int = 0
    while count < 2:
DoTest(enCollation, source[count], target[count], -1)
++count
DoTest(enCollation, source[count], target[count], 1)
    count = 0
    var newCollation: Collator
    try:
        newCollation = RuleBasedCollator(rules)
    except Exception:
Errln("ERROR: Failed to create the collator for rules")
        return
    while count < 4:
DoTest(newCollation, source[count], target[count], -1)
++count
    var enKey: CollationKey = enCollation.GetCollationKey(source[3])
    var newKey: CollationKey = newCollation.GetCollationKey(source[3])
    var keyResult: int = enKey.CompareTo(newKey)
    if keyResult != 0:
Errln("Failed : non-tailored supplementary characters should have the same value
")
proc TestVariableTop*() =
    if !SUPPORT_VARIABLE_TOP_RELATION:
        return
    var rule: String = "&z = [variable top]"
    var myColl: Collator
    var enColl: Collator
    var source: char[] = seq[char]
    var ch: char
    var expected: int[] = @[0]
    try:
        enColl = Collator.GetInstance(CultureInfo("en"))
    except Exception:
Errln("ERROR: Failed to create the collator for ENGLISH")
        return
    try:
        myColl = RuleBasedCollator(rule)
    except Exception:
Errln("Fail to create RuleBasedCollator with rules:" + rule)
        return
    enColl.Strength = Collator.Primary
    myColl.Strength = Collator.Primary
    cast[RuleBasedCollator](enColl).IsAlternateHandlingShifted = true
    cast[RuleBasedCollator](myColl).IsAlternateHandlingShifted = true
    if cast[RuleBasedCollator](enColl).IsAlternateHandlingShifted != true:
Errln("ERROR: ALTERNATE_HANDLING value can not be set to SHIFTED
")
    var key: CollationKey = enColl.GetCollationKey(" ")
    var result: byte[] = key.ToByteArray
      var i: int = 0
      while i < result.Length:
          if result[i] != expected[i]:
Errln("ERROR: SHIFTED alternate does not return 0 for primary of space
")
              break
++i
    ch = 'a'
    while ch < 'z':
        source[0] = ch
        key = myColl.GetCollationKey(String(source))
        result = key.ToByteArray
          var i: int = 0
          while i < result.Length:
              if result[i] != expected[i]:
Errln("ERROR: SHIFTED alternate does not return 0 for primary of space
")
                  break
++i
++ch
proc TestJB1401*() =
    var myCollator: Collator = nil
    var NFD_UnsafeStartChars: char[] = @[cast[char](3955), cast[char](3957), cast[char](3969), cast[char](0)]
    var i: int
    try:
        myCollator = Collator.GetInstance(CultureInfo("en"))
    except Exception:
Errln("ERROR: Failed to create the collator for ENGLISH")
        return
    myCollator.Decomposition = Collator.CanonicalDecomposition
      i = 0
      while true:
          var c: char = NFD_UnsafeStartChars[i]
          if c == 0:
              break
          var x: String = "À" + c
          var y: String
          var z: String
          try:
              y = Normalizer.Decompose(x, false)
              z = Normalizer.Decompose(y, true)
          except Exception:
Errln("ERROR: Failed to normalize test of character" + c)
              return
DoTest(myCollator, x, y, 0)
DoTest(myCollator, x, z, 0)
DoTest(myCollator, y, z, 0)
              var ceiX: CollationElementIterator
              var ceiY: CollationElementIterator
              var ceiZ: CollationElementIterator
              var ceX: int
              var ceY: int
              var ceZ: int
            var j: int
            try:
                ceiX = cast[RuleBasedCollator](myCollator).GetCollationElementIterator(x)
                ceiY = cast[RuleBasedCollator](myCollator).GetCollationElementIterator(y)
                ceiZ = cast[RuleBasedCollator](myCollator).GetCollationElementIterator(z)
            except Exception:
Errln("ERROR: getCollationElementIterator failed")
                return
              j = 0
              while true:
                  try:
                      ceX = ceiX.Next
                      ceY = ceiY.Next
                      ceZ = ceiZ.Next
                  except Exception:
Errln("ERROR: CollationElementIterator.next failed for iteration " + j)
                      break
                  if ceX != ceY || ceY != ceZ:
Errln("ERROR: ucol_next failed for iteration " + j)
                      break
                  if ceX == CollationElementIterator.NullOrder:
                      break
++j
++i
proc DoTest(collation: Collator, source: seq[char], target: seq[char], result: int) =
    var s: String = String(source)
    var t: String = String(target)
DoTestVariant(collation, s, t, result)
    if result == -1:
DoTestVariant(collation, t, s, 1)

    elif result == 1:
DoTestVariant(collation, t, s, -1)
    else:
DoTestVariant(collation, t, s, 0)
proc DoTest(collation: Collator, s: String, t: String, result: int) =
DoTestVariant(collation, s, t, result)
    if result == -1:
DoTestVariant(collation, t, s, 1)

    elif result == 1:
DoTestVariant(collation, t, s, -1)
    else:
DoTestVariant(collation, t, s, 0)
proc DoTestVariant(collation: Collator, source: String, target: String, result: int) =
    var compareResult: int = collation.Compare(source, target)
      var srckey: CollationKey
      var tgtkey: CollationKey
    srckey = collation.GetCollationKey(source)
    tgtkey = collation.GetCollationKey(target)
    var keyResult: int = srckey.CompareTo(tgtkey)
    if compareResult != result:
Errln("String comparison failed in variant test
")
    if keyResult != result:
Errln("Collation key comparison failed in variant test
")