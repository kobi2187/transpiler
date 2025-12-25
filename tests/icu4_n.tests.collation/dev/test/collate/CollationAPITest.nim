# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationAPITest = ref object
    bigone: String = "One"
    littleone: String = "one"

proc TestCollationKey*() =
Logln("testing CollationKey begins...")
    var col: Collator = Collator.GetInstance
    col.Strength = Collator.Tertiary
    var test1: String = "Abcda"
    var test2: String = "abcda"
Logln("Testing weird arguments")
    var sortk1: CollationKey = col.GetCollationKey("")
    var bytes: byte[] = sortk1.ToByteArray
DoAssert(bytes.Length == 3 && bytes[0] == 1 && bytes[1] == 1 && bytes[2] == 0, "Empty string should return a collation key with empty levels")
    var sortkIgnorable: CollationKey = col.GetCollationKey("͏")
DoAssert(sortkIgnorable != nil && sortkIgnorable.ToByteArray.Length == 3, "Completely ignorable string should return a collation key with empty levels")
DoAssert(sortkIgnorable.CompareTo(sortk1) == 0, "Completely ignorable string should compare equal to empty string")
    sortk1 = col.GetCollationKey(nil)
DoAssert(sortk1 == nil, "Error code should return bogus collation key")
Logln("Use tertiary comparison level testing ....")
    sortk1 = col.GetCollationKey(test1)
    var sortk2: CollationKey = col.GetCollationKey(test2)
DoAssert(sortk1.CompareTo(sortk2) > 0, "Result should be "Abcda" >>> "abcda"")
    var sortkNew: CollationKey
    sortkNew = sortk1
DoAssert(!sortk1.Equals(sortk2), "The sort keys should be different")
DoAssert(sortk1.GetHashCode != sortk2.GetHashCode, "sort key hashCode() failed")
DoAssert(sortk1.Equals(sortkNew), "The sort keys assignment failed")
DoAssert(sortk1.GetHashCode == sortkNew.GetHashCode, "sort key hashCode() failed")
    try:
        col = Collator.GetInstance
    except Exception:
Errln("Collator.GetInstance() failed")
    if col.Strength != Collator.Tertiary:
Errln("Default collation did not have tertiary strength")
    col.Strength = Collator.Identical
    var key1: CollationKey = col.GetCollationKey(test1)
    var key2: CollationKey = col.GetCollationKey(test2)
    var key3: CollationKey = col.GetCollationKey(test2)
DoAssert(key1.CompareTo(key2) > 0, "Result should be "Abcda" > "abcda"")
DoAssert(key2.CompareTo(key1) < 0, "Result should be "abcda" < "Abcda"")
DoAssert(key2.CompareTo(key3) == 0, "Result should be "abcda" ==  "abcda"")
    var key2identical: byte[] = key2.ToByteArray
Logln("Use secondary comparision level testing ...")
    col.Strength = Collator.Secondary
    key1 = col.GetCollationKey(test1)
    key2 = col.GetCollationKey(test2)
    key3 = col.GetCollationKey(test2)
DoAssert(key1.CompareTo(key2) == 0, "Result should be "Abcda" == "abcda"")
DoAssert(key2.CompareTo(key3) == 0, "Result should be "abcda" ==  "abcda"")
    var tempkey: byte[] = key2.ToByteArray
    var subkey2compat: byte[] = seq[byte]
System.Array.Copy(key2identical, 0, subkey2compat, 0, tempkey.Length)
    subkey2compat[subkey2compat.Length - 1] = 0
DoAssert(ArrayEqualityComparer[byte].OneDimensional.Equals(tempkey, subkey2compat), "Binary format for 'abcda' sortkey different for secondary strength!")
DoAssert(sortk1.GetHashCode != GetHashCode_Old(sortk1), "sort key hashCode() doesn't match original")
DoAssert(sortk2.GetHashCode != GetHashCode_Old(sortk2), "sort key hashCode() doesn't match original")
Logln("testing sortkey ends...")
proc GetHashCode_Old(collationKey: CollationKey): int =
    var m_key_: byte[] = collationKey.m_key_
    var size: int = m_key_.Length >> 1
    var key: StringBuilder = StringBuilder(size)
    var i: int = 0
    while m_key_[i] != 0 && m_key_[i + 1] != 0:
key.Append(cast[char](m_key_[i] << 8 | 255 & collationKey.m_key_[i + 1]))
        i = 2
    if m_key_[i] != 0:
key.Append(cast[char](m_key_[i] << 8))
    return key.ToString.GetHashCode
proc TestRawCollationKey*() =
    var key: RawCollationKey = RawCollationKey
    if key.Bytes != nil || key.Length != 0:
Errln("Empty default constructor expected to leave the bytes null " + "and size 0")
    var array: byte[] = seq[byte]
    key = RawCollationKey(array)
    if key.Bytes != array || key.Length != 0:
Errln("Constructor taking an array expected to adopt it and " + "retaining its size 0")
    try:
        key = RawCollationKey(array, 129)
Errln("Constructor taking an array and a size > array.Length " + "expected to throw an exception")
    except IndexOutOfRangeException:
Logln("PASS: Constructor failed as expected")
    try:
        key = RawCollationKey(array, -1)
Errln("Constructor taking an array and a size < 0 " + "expected to throw an exception")
    except IndexOutOfRangeException:
Logln("PASS: Constructor failed as expected")
    key = RawCollationKey(array, array.Length >> 1)
    if key.Bytes != array || key.Length != array.Length >> 1:
Errln("Constructor taking an array and a size, " + "expected to adopt it and take the size specified")
    key = RawCollationKey(10)
    if key.Bytes == nil || key.Bytes.Length != 10 || key.Length != 0:
Errln("Constructor taking a specified capacity expected to " + "create a new internal byte array with length 10 and " + "retain size 0")
proc DoAssert(conditions: bool, message: String) =
    if !conditions:
Errln(message)
proc TestCompare*() =
Logln("The compare tests begin : ")
    var col: Collator = Collator.GetInstance(CultureInfo("en"))
    var test1: String = "Abcda"
    var test2: String = "abcda"
Logln("Use tertiary comparison level testing ....")
DoAssert(!col.Equals(test1, test2), "Result should be "Abcda" != "abcda"")
DoAssert(col.Compare(test1, test2) > 0, "Result should be "Abcda" >>> "abcda"")
    col.Strength = Collator.Secondary
Logln("Use secondary comparison level testing ....")
DoAssert(col.Equals(test1, test2), "Result should be "Abcda" == "abcda"")
DoAssert(col.Compare(test1, test2) == 0, "Result should be "Abcda" == "abcda"")
    col.Strength = Collator.Primary
Logln("Use primary comparison level testing ....")
DoAssert(col.Equals(test1, test2), "Result should be "Abcda" == "abcda"")
DoAssert(col.Compare(test1, test2) == 0, "Result should be "Abcda" == "abcda"")
Logln("The compare tests end.")
proc TestDecomposition*() =
      var en_US: Collator = nil
      var el_GR: Collator = nil
      var vi_VN: Collator = nil
    en_US = Collator.GetInstance(CultureInfo("en-US"))
    el_GR = Collator.GetInstance(CultureInfo("el-GR"))
    vi_VN = Collator.GetInstance(CultureInfo("vi-VN"))
    if vi_VN.Decomposition != Collator.CanonicalDecomposition:
Errln("vi_VN collation did not have cannonical decomposition for normalization!")
    if el_GR.Decomposition != Collator.CanonicalDecomposition:
Errln("el_GR collation did not have cannonical decomposition for normalization!")
    if en_US.Decomposition != Collator.NoDecomposition:
Errln("en_US collation had cannonical decomposition for normalization!")
proc TestDuplicate*() =
    var col1: Collator = Collator.GetInstance(CultureInfo("en"))
    var ruleset: String = "&9 < a, A < b, B < c, C < d, D, e, E"
    var col3: RuleBasedCollator = nil
    try:
        col3 = RuleBasedCollator(ruleset)
    except Exception:
Errln("Failure creating RuleBasedCollator with rule: "" + ruleset + ""
" + e)
        return
DoAssert(!col1.Equals(col3), "Cloned object is equal to some dummy")
    col3 = cast[RuleBasedCollator](col1)
DoAssert(col1.Equals(col3), "Copied object is not equal to the orginal")
proc TestElemIter*() =
    var col: Collator = Collator.GetInstance(CultureInfo("en"))
    var testString1: String = "XFILE What subset of all possible test cases has the highest probability of detecting the most errors?"
    var testString2: String = "Xf_ile What subset of all possible test cases has the lowest probability of detecting the least errors?"
    var iterator1: CollationElementIterator = cast[RuleBasedCollator](col).GetCollationElementIterator(testString1)
    var chariter: CharacterIterator = StringCharacterIterator(testString1)
    var iterator2: CollationElementIterator = cast[RuleBasedCollator](col).GetCollationElementIterator(chariter)
    var uchariter: UCharacterIterator = UCharacterIterator.GetInstance(testString2)
    var iterator3: CollationElementIterator = cast[RuleBasedCollator](col).GetCollationElementIterator(uchariter)
    var offset: int = 0
    offset = iterator1.GetOffset
    if offset != 0:
Errln("Error in getOffset for collation element iterator")
        return
iterator1.SetOffset(6)
iterator1.SetOffset(0)
      var order1: int
      var order2: int
      var order3: int
    order1 = iterator1.Next
DoAssert(!iterator1.Equals(iterator2), "The first iterator advance failed")
    order2 = iterator2.Next
DoAssert(iterator1.GetOffset == iterator2.GetOffset, "The second iterator advance failed")
DoAssert(order1 == order2, "The order result should be the same")
    order3 = iterator3.Next
DoAssert(CollationElementIterator.PrimaryOrder(order1) == CollationElementIterator.PrimaryOrder(order3), "The primary orders should be the same")
DoAssert(CollationElementIterator.SecondaryOrder(order1) == CollationElementIterator.SecondaryOrder(order3), "The secondary orders should be the same")
DoAssert(CollationElementIterator.TertiaryOrder(order1) == CollationElementIterator.TertiaryOrder(order3), "The tertiary orders should be the same")
    order1 = iterator1.Next
    order3 = iterator3.Next
DoAssert(CollationElementIterator.PrimaryOrder(order1) == CollationElementIterator.PrimaryOrder(order3), "The primary orders should be identical")
DoAssert(CollationElementIterator.TertiaryOrder(order1) != CollationElementIterator.TertiaryOrder(order3), "The tertiary orders should be different")
    order1 = iterator1.Next
    order3 = iterator3.Next
DoAssert(order1 != CollationElementIterator.NullOrder, "Unexpected end of iterator reached")
iterator1.Reset
iterator2.Reset
iterator3.Reset
    order1 = iterator1.Next
DoAssert(!iterator1.Equals(iterator2), "The first iterator advance failed")
    order2 = iterator2.Next
DoAssert(iterator1.GetOffset == iterator2.GetOffset, "The second iterator advance failed")
DoAssert(order1 == order2, "The order result should be the same")
    order3 = iterator3.Next
DoAssert(CollationElementIterator.PrimaryOrder(order1) == CollationElementIterator.PrimaryOrder(order3), "The primary orders should be the same")
DoAssert(CollationElementIterator.SecondaryOrder(order1) == CollationElementIterator.SecondaryOrder(order3), "The secondary orders should be the same")
DoAssert(CollationElementIterator.TertiaryOrder(order1) == CollationElementIterator.TertiaryOrder(order3), "The tertiary orders should be the same")
    order1 = iterator1.Next
    order2 = iterator2.Next
    order3 = iterator3.Next
DoAssert(CollationElementIterator.PrimaryOrder(order1) == CollationElementIterator.PrimaryOrder(order3), "The primary orders should be identical")
DoAssert(CollationElementIterator.TertiaryOrder(order1) != CollationElementIterator.TertiaryOrder(order3), "The tertiary orders should be different")
    order1 = iterator1.Next
    order3 = iterator3.Next
DoAssert(order1 != CollationElementIterator.NullOrder, "Unexpected end of iterator reached")
DoAssert(!iterator2.Equals(iterator3), "The iterators should be different")
Logln("testing CollationElementIterator ends...")
proc TestHashCode*() =
Logln("hashCode tests begin.")
    var col1: Collator = Collator.GetInstance(CultureInfo("en"))
    var col2: Collator = nil
    var dk: CultureInfo = CultureInfo("da-DK")
    try:
        col2 = Collator.GetInstance(dk)
    except Exception:
Errln("Danish collation creation failed.")
        return
    var col3: Collator = nil
    try:
        col3 = Collator.GetInstance(CultureInfo("en"))
    except Exception:
Errln("2nd default collation creation failed.")
        return
Logln("Collator.GetHashCode() testing ...")
DoAssert(col1.GetHashCode != col2.GetHashCode, "Hash test1 result incorrect")
DoAssert(!col1.GetHashCode == col2.GetHashCode, "Hash test2 result incorrect")
DoAssert(col1.GetHashCode == col3.GetHashCode, "Hash result not equal")
Logln("hashCode tests end.")
    var test1: String = "Abcda"
    var test2: String = "abcda"
      var sortk1: CollationKey
      var sortk2: CollationKey
      var sortk3: CollationKey
    sortk1 = col3.GetCollationKey(test1)
    sortk2 = col3.GetCollationKey(test2)
    sortk3 = col3.GetCollationKey(test2)
DoAssert(sortk1.GetHashCode != sortk2.GetHashCode, "Hash test1 result incorrect")
DoAssert(sortk2.GetHashCode == sortk3.GetHashCode, "Hash result not equal")
proc TestProperty*() =
Logln("The property tests begin : ")
Logln("Test ctors : ")
    var col: Collator = Collator.GetInstance(CultureInfo("en"))
Logln("Test getVersion")
    var expectedVersion: VersionInfo = VersionInfo.GetInstance(49, 192, 0, 5)
DoAssert(col.GetVersion.CompareTo(expectedVersion) >= 0, "Expected minimum version " + expectedVersion.ToString + " got " + col.GetVersion.ToString)
Logln("Test getUCAVersion")
    var ucdVersion: VersionInfo = UChar.UnicodeVersion
    var ucaVersion: VersionInfo = col.GetUCAVersion
DoAssert(ucaVersion.Equals(ucdVersion), "Expected UCA version " + ucdVersion.ToString + " got " + col.GetUCAVersion.ToString)
DoAssert(col.Compare("ab", "abc") < 0, "ab < abc comparison failed")
DoAssert(col.Compare("ab", "AB") < 0, "ab < AB comparison failed")
DoAssert(col.Compare("blackbird", "black-bird") > 0, "black-bird > blackbird comparison failed")
DoAssert(col.Compare("black bird", "black-bird") < 0, "black bird > black-bird comparison failed")
DoAssert(col.Compare("Hello", "hello") > 0, "Hello > hello comparison failed")
Logln("Test ctors ends.")
Logln("testing Collator.Strength method ...")
DoAssert(col.Strength == Collator.Tertiary, "collation object has the wrong strength")
DoAssert(col.Strength != Collator.Primary, "collation object's strength is primary difference")
Logln("testing Collator.setStrength() method ...")
    col.Strength = Collator.Secondary
DoAssert(col.Strength != Collator.Tertiary, "collation object's strength is secondary difference")
DoAssert(col.Strength != Collator.Primary, "collation object's strength is primary difference")
DoAssert(col.Strength == Collator.Secondary, "collation object has the wrong strength")
Logln("testing Collator.setDecomposition() method ...")
    col.Decomposition = Collator.NoDecomposition
DoAssert(col.Decomposition != Collator.CanonicalDecomposition, "Decomposition mode != Collator.CANONICAL_DECOMPOSITION")
DoAssert(col.Decomposition == Collator.NoDecomposition, "Decomposition mode = Collator.NO_DECOMPOSITION")
    var rcol: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("da-DK")))
DoAssert(rcol.GetRules.Length != 0, "da_DK rules does not have length 0")
    try:
        col = Collator.GetInstance(CultureInfo("fr"))
    except Exception:
Errln("Creating French collation failed.")
        return
    col.Strength = Collator.Primary
Logln("testing Collator.Strength method again ...")
DoAssert(col.Strength != Collator.Tertiary, "collation object has the wrong strength")
DoAssert(col.Strength == Collator.Primary, "collation object's strength is not primary difference")
Logln("testing French Collator.setStrength() method ...")
    col.Strength = Collator.Tertiary
DoAssert(col.Strength == Collator.Tertiary, "collation object's strength is not tertiary difference")
DoAssert(col.Strength != Collator.Primary, "collation object's strength is primary difference")
DoAssert(col.Strength != Collator.Secondary, "collation object's strength is secondary difference")
proc TestJunkCollator*() =
Logln("Create junk collation: ")
    var abcd = CultureInfo.InvariantCulture
    var junk: Collator = Collator.GetInstance(abcd)
    var col: Collator = Collator.GetInstance
    var colrules: String = cast[RuleBasedCollator](col).GetRules
    var junkrules: String = cast[RuleBasedCollator](junk).GetRules
DoAssert(colrules == junkrules || colrules.Equals(junkrules), "The default collation should be returned.")
    var frCol: Collator = nil
    try:
        frCol = Collator.GetInstance(CultureInfo("fr-CA"))
    except Exception:
Errln("Creating fr_CA collator failed.")
        return
DoAssert(!frCol.Equals(junk), "The junk is the same as the fr_CA collator.")
Logln("Collator property test ended.")
proc TestRuleBasedColl*() =
      var col1: RuleBasedCollator = nil
      var col2: RuleBasedCollator = nil
      var col3: RuleBasedCollator = nil
      var col4: RuleBasedCollator = nil
    var ruleset1: String = "&9 < a, A < b, B < c, C; ch, cH, Ch, CH < d, D, e, E"
    var ruleset2: String = "&9 < a, A < b, B < c, C < d, D, e, E"
    var ruleset3: String = "&"
    try:
        col1 = RuleBasedCollator(ruleset1)
    except Exception:
Warnln("RuleBased Collator creation failed.")
        return
    try:
        col2 = RuleBasedCollator(ruleset2)
    except Exception:
Errln("RuleBased Collator creation failed.")
        return
    try:
        col3 = RuleBasedCollator(ruleset3)
Errln("Failure: Empty rules for the collator should fail")
        return
    except MissingManifestResourceException:
Warnln(e.ToString)
    except Exception:
Logln("PASS: Empty rules for the collator failed as expected")
    var locale = CultureInfo.InvariantCulture
    try:
        col3 = cast[RuleBasedCollator](Collator.GetInstance(locale))
    except Exception:
Errln("Fallback Collator creation failed.: %s")
        return
    try:
        col3 = cast[RuleBasedCollator](Collator.GetInstance)
    except Exception:
Errln("Default Collator creation failed.: %s")
        return
    var rule1: String = col1.GetRules
    var rule2: String = col2.GetRules
    var rule3: String = col3.GetRules
DoAssert(!rule1.Equals(rule2), "Default collator getRules failed")
DoAssert(!rule2.Equals(rule3), "Default collator getRules failed")
DoAssert(!rule1.Equals(rule3), "Default collator getRules failed")
    try:
        col4 = RuleBasedCollator(rule2)
    except Exception:
Errln("RuleBased Collator creation failed.")
        return
    var rule4: String = col4.GetRules
DoAssert(rule2.Equals(rule4), "Default collator getRules failed")
    var exclamationrules: String = "!&a<b"
    var thaistr: String = "เกอ"
    try:
        var col5: RuleBasedCollator = RuleBasedCollator(exclamationrules)
        var encol: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en")))
        var col5iter: CollationElementIterator = col5.GetCollationElementIterator(thaistr)
        var encoliter: CollationElementIterator = encol.GetCollationElementIterator(thaistr)
        while true:
            var ce: int = col5iter.Next
            var ce2: int = encoliter.Next
            if ce2 != ce:
Errln("! modifier test failed")
            if ce == CollationElementIterator.NullOrder:
                break
    except Exception:
Errln("RuleBased Collator creation failed for ! modifier.")
        return
proc TestRules*() =
    var coll: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo.InvariantCulture))
    var rules: String = coll.GetRules
    if rules != nil && rules.Length != 0:
Errln("Root tailored rules failed")
proc TestSafeClone*() =
    var test1: String = "abCda"
    var test2: String = "abcda"
    var someCollators: RuleBasedCollator[] = @[cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en"))), cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("ko-KR"))), cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("ja-JP")))]
    var someClonedCollators: RuleBasedCollator[] = seq[RuleBasedCollator]
      var index: int = 0
      while index < someCollators.Length:
          someClonedCollators[index] = cast[RuleBasedCollator](someCollators[index].Clone)
          someClonedCollators[index].Strength = Collator.Tertiary
          someCollators[index].Strength = Collator.Primary
          someClonedCollators[index].IsCaseLevel = false
          someCollators[index].IsCaseLevel = false
DoAssert(someClonedCollators[index].Compare(test1, test2) > 0, "Result should be "abCda" >>> "abcda" ")
DoAssert(someCollators[index].Compare(test1, test2) == 0, "Result should be "abCda" == "abcda" ")
++index
proc TestGetTailoredSet*() =
Logln("testing getTailoredSet...")
    var rules: String[] = @["&a < Å", "& S < š <<< Š"]
    var data: String[][] = @[@["Å", "Å", "Å"], @["š", "š", "Š", "Š"]]
      var i: int = 0
      var j: int = 0
    var coll: RuleBasedCollator
    var set: UnicodeSet
      i = 0
      while i < rules.Length:
          try:
Logln("Instantiating a collator from " + rules[i])
              coll = RuleBasedCollator(rules[i])
              set = coll.GetTailoredSet
Logln("Got set: " + set.ToPattern(true))
              if set.Count < data[i].Length:
Errln("Tailored set size smaller (" + set.Count + ") than expected (" + data[i].Length + ")")
                j = 0
                while j < data[i].Length:
Logln("Checking to see whether " + data[i][j] + " is in set")
                    if !set.Contains(data[i][j]):
Errln("Tailored set doesn't contain " + data[i][j] + "... It should")
++j
          except Exception:
Warnln("Couldn't open collator with rules " + rules[i])
++i
type
  TestCollator = ref object


proc Equals*(that: Object): bool =
    return self == that
proc GetHashCode*(): int =
    return 0
proc Compare*(source: ReadOnlyMemory[char], target: ReadOnlyMemory[char]): int =
    return source.Span.CompareTo(target.Span, StringComparison.Ordinal)
proc GetCollationKey*(source: String): CollationKey =
    return CollationKey(source, GetRawCollationKey(source, RawCollationKey))
proc GetRawCollationKey*(source: String, key: RawCollationKey): RawCollationKey =
    var temp1: byte[] = source.GetBytes(Encoding.UTF8)
    var temp2: byte[] = seq[byte]
System.Array.Copy(temp1, 0, temp2, 0, temp1.Length)
    temp2[temp1.Length] = 0
    if key == nil:
        key = RawCollationKey
    key.Bytes = temp2
    key.Length = temp2.Length
    return key
  proc VariableTop(): int =
      return 0
  proc `VariableTop=`(value: int) =
      if IsFrozen:
          raise NotSupportedException("Attempt to modify frozen object")
proc SetVariableTop*(str: string): int =
    if IsFrozen:
        raise NotSupportedException("Attempt to modify frozen object")
    return 0
proc GetVersion*(): VersionInfo =
    return VersionInfo.GetInstance(0)
proc GetUCAVersion*(): VersionInfo =
    return VersionInfo.GetInstance(0)
proc TestSubClass*() =
    var col1: Collator = TestCollator
    var col2: Collator = TestCollator
    if col1.Equals(col2):
Errln("2 different instance of TestCollator should fail")
    if col1.GetHashCode != col2.GetHashCode:
Errln("Every TestCollator has the same hashcode")
    var abc: String = "abc"
    var bcd: String = "bcd"
    if col1.Compare(abc, bcd) != abc.CompareToOrdinal(bcd):
Errln("TestCollator compare should be the same as the default " + "string comparison")
    var key: CollationKey = col1.GetCollationKey(abc)
    var temp1: byte[] = abc.GetBytes(Encoding.UTF8)
    var temp2: byte[] = seq[byte]
System.Array.Copy(temp1, 0, temp2, 0, temp1.Length)
    temp2[temp1.Length] = 0
    if !ArrayEqualityComparer[byte].OneDimensional.Equals(key.ToByteArray, temp2) || !key.SourceString.Equals(abc):
Errln("TestCollator collationkey API is returning wrong values")
    var set: UnicodeSet = col1.GetTailoredSet
    if !set.Equals(UnicodeSet(0, 1114111)):
Errln("Error getting default tailored set")
assertEquals("compare(strings as Object)", 0, col1.Compare(StringBuilder("abc"), StringBuffer("abc")))
    col1.Strength = Collator.Secondary
assertNotEquals("getStrength()", Collator.Primary, col1.Strength)
assertNotEquals("setStrength2().Strength", Collator.Primary, col1.SetStrength2(Collator.Identical).Strength)
    try:
        col1.Decomposition = Collator.CanonicalDecomposition
    except NotSupportedException:

assertNotEquals("getDecomposition()", -1, col1.Decomposition)
    try:
        col1.MaxVariable = ReorderCodes.Currency
    except NotSupportedException:

assertNotEquals("getMaxVariable()", -1, col1.MaxVariable)
    try:
col1.SetReorderCodes(0, 1, 2)
    except NotSupportedException:

    try:
col1.GetReorderCodes
    except NotSupportedException:

assertFalse("getDisplayName()", Collator.GetDisplayName(CultureInfo("de")) == string.Empty)
assertFalse("getDisplayName()", Collator.GetDisplayName(CultureInfo("de"), CultureInfo("it")) == string.Empty)
assertNotEquals("getLocale()", UCultureInfo("de"), col1.ActualCulture)
    var token: Object = Collator.RegisterInstance(TestCollator, UCultureInfo("de-Japn-419"))
Collator.Unregister(token)
assertFalse("not yet frozen", col2.IsFrozen)
    try:
col2.Freeze
assertTrue("now frozen", col2.IsFrozen)
    except NotSupportedException:

    try:
        col2.Strength = Collator.Primary
        if col2.IsFrozen:
fail("(frozen Collator).setStrength() should throw an exception")
    except NotSupportedException:

    try:
        var col3: Collator = col2.CloneAsThawed
assertFalse("!cloneAsThawed().isFrozen()", col3.IsFrozen)
    except NotSupportedException:

proc TestSetGet*() =
    var collator: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance)
    var decomp: NormalizationMode = collator.Decomposition
    var strength: CollationStrength = collator.Strength
    var alt: bool = collator.IsAlternateHandlingShifted
    var caselevel: bool = collator.IsCaseLevel
    var french: bool = collator.IsFrenchCollation
    var hquart: bool = collator.IsHiraganaQuaternary
    var lowercase: bool = collator.IsLowerCaseFirst
    var uppercase: bool = collator.IsUpperCaseFirst
    collator.Decomposition = Collator.CanonicalDecomposition
    if collator.Decomposition != Collator.CanonicalDecomposition:
Errln("Setting decomposition failed")
    collator.Strength = Collator.Quaternary
    if collator.Strength != Collator.Quaternary:
Errln("Setting strength failed")
    collator.IsAlternateHandlingShifted = !alt
    if collator.IsAlternateHandlingShifted == alt:
Errln("Setting alternate handling failed")
    collator.IsCaseLevel = !caselevel
    if collator.IsCaseLevel == caselevel:
Errln("Setting case level failed")
    collator.IsFrenchCollation = !french
    if collator.IsFrenchCollation == french:
Errln("Setting french collation failed")
    collator.IsHiraganaQuaternary = !hquart
    if collator.IsHiraganaQuaternary != hquart:
Errln("Setting hiragana quartenary worked but should be a no-op since ICU 50")
    collator.IsLowerCaseFirst = !lowercase
    if collator.IsLowerCaseFirst == lowercase:
Errln("Setting lower case first failed")
    collator.IsUpperCaseFirst = !uppercase
    if collator.IsUpperCaseFirst == uppercase:
Errln("Setting upper case first failed")
collator.SetDecompositionToDefault
    if collator.Decomposition != decomp:
Errln("Setting decomposition default failed")
collator.SetStrengthToDefault
    if collator.Strength != strength:
Errln("Setting strength default failed")
collator.SetAlternateHandlingToDefault
    if collator.IsAlternateHandlingShifted != alt:
Errln("Setting alternate handling default failed")
collator.SetCaseLevelToDefault
    if collator.IsCaseLevel != caselevel:
Errln("Setting case level default failed")
collator.SetFrenchCollationToDefault
    if collator.IsFrenchCollation != french:
Errln("Setting french handling default failed")
collator.SetHiraganaQuaternaryToDefault
    if collator.IsHiraganaQuaternary != hquart:
Errln("Setting Hiragana Quartenary default failed")
collator.SetCaseFirstToDefault
    if collator.IsLowerCaseFirst != lowercase || collator.IsUpperCaseFirst != uppercase:
Errln("Setting case first handling default failed")
proc TestVariableTopSetting*() =
    var coll: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(UCultureInfo.InvariantCulture))
    var oldVarTop: int = coll.VariableTop
    try:
coll.SetVariableTop("A")
Errln("setVariableTop(letter) did not detect illegal argument")
    except ArgumentException:

    var newVarTop: int = coll.SetVariableTop("$")
    if newVarTop != coll.VariableTop:
Errln("setVariableTop(dollar sign) != following getVariableTop()")
    var dollar: string = "$"
    var euro: string = "€"
    var newVarTop2: int = coll.SetVariableTop(euro)
assertEquals("setVariableTop(Euro sign) == following getVariableTop()", newVarTop2, coll.VariableTop)
assertEquals("setVariableTop(Euro sign) == setVariableTop(dollar sign) (should pin to top of currency group)", newVarTop2, newVarTop)
    coll.IsAlternateHandlingShifted = true
assertEquals("empty==dollar", 0, coll.Compare("", dollar))
assertEquals("empty==euro", 0, coll.Compare("", euro))
assertEquals("dollar<zero", -1, coll.Compare(dollar, "0"))
    coll.VariableTop = oldVarTop
    var newerVarTop: int = coll.SetVariableTop("$")
    if newVarTop != newerVarTop:
Errln("Didn't set vartop properly from String!
")
proc TestMaxVariable*() =
    var coll: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(UCultureInfo.InvariantCulture))
    try:
        coll.MaxVariable = ReorderCodes.Others
Errln("setMaxVariable(others) did not detect illegal argument")
    except ArgumentException:

    coll.MaxVariable = ReorderCodes.Currency
    if ReorderCodes.Currency != coll.MaxVariable:
Errln("setMaxVariable(currency) != following getMaxVariable()")
    coll.IsAlternateHandlingShifted = true
assertEquals("empty==dollar", 0, coll.Compare("", "$"))
assertEquals("empty==euro", 0, coll.Compare("", "€"))
assertEquals("dollar<zero", -1, coll.Compare("$", "0"))
proc TestGetLocale*() =
    var rules: String = "&a<x<y<z"
    var coll: Collator = Collator.GetInstance(UCultureInfo("root"))
    var locale: UCultureInfo = coll.ActualCulture
    if !locale.Equals(UCultureInfo.InvariantCulture):
Errln("Collator.GetInstance("root").getLocale(actual) != UCultureInfo.InvariantCulture; " + "getLocale().getName() = "" + locale.FullName + """)
    coll = Collator.GetInstance(UCultureInfo(""))
    locale = coll.ActualCulture
    if !locale.Equals(UCultureInfo.InvariantCulture):
Errln("Collator.GetInstance("").getLocale(actual) != UCultureInfo.InvariantCulture; " + "getLocale().getName() = "" + locale.FullName + """)
    var i: int = 0
    var testStruct: string[][] = @[@["de_DE", "de", ""], @["sr_RS", "sr_Cyrl_RS", "sr"], @["en_US_CALIFORNIA", "en_US", ""], @["fr_FR_NONEXISTANT", "fr", ""], @["zh_CN", "zh_Hans_CN", "zh"], @["zh_TW", "zh_Hant_TW", "zh@collation=stroke"], @["zh_TW@collation=pinyin", "zh_Hant_TW@collation=pinyin", "zh"], @["zh_CN@collation=stroke", "zh_Hans_CN@collation=stroke", "zh@collation=stroke"], @["yue", "zh_Hant", "zh@collation=stroke"], @["yue_HK", "zh_Hant", "zh@collation=stroke"], @["yue_Hant", "zh_Hant", "zh@collation=stroke"], @["yue_Hant_HK", "zh_Hant", "zh@collation=stroke"], @["yue@collation=pinyin", "zh_Hant@collation=pinyin", "zh"], @["yue_HK@collation=pinyin", "zh_Hant@collation=pinyin", "zh"], @["yue_CN", "zh_Hans", "zh"], @["yue_Hans", "zh_Hans", "zh"], @["yue_Hans_CN", "zh_Hans", "zh"], @["yue_Hans@collation=stroke", "zh_Hans@collation=stroke", "zh@collation=stroke"], @["yue_CN@collation=stroke", "zh_Hans@collation=stroke", "zh@collation=stroke"]]
      i = 0
      while i < testStruct.Length:
          var requestedLocale: String = testStruct[i][0]
          var validLocale: String = testStruct[i][1]
          var actualLocale: String = testStruct[i][2]
          try:
              coll = Collator.GetInstance(UCultureInfo(requestedLocale))
          except Exception:
Errln(String.Format("Failed to open collator for {0} with {1}", requestedLocale, e))
              continue
          locale = coll.ValidCulture
          if !locale.Equals(UCultureInfo(validLocale)):
Errln(String.Format("[Coll {0}]: Error in valid locale, expected {1}, got {2}", requestedLocale, validLocale, locale.FullName))
          locale = coll.ActualCulture
          if !locale.Equals(UCultureInfo(actualLocale)):
Errln(String.Format("[Coll {0}]: Error in actual locale, expected {1}, got {2}", requestedLocale, actualLocale, locale.FullName))
          var coll2: Collator
          try:
              coll2 = Collator.GetInstance(locale)
          except Exception:
Errln(String.Format("Failed to open collator for actual locale "{0}" with {1}", locale.FullName, e))
              continue
          var actual2: UCultureInfo = coll2.ActualCulture
          if !actual2.Equals(locale):
Errln(String.Format("[Coll actual "{0}"]: Error in actual locale, got different one: "{1}"", locale.FullName, actual2.FullName))
          if !coll2.Equals(coll):
Errln(String.Format("[Coll actual "{0}"]: Got different collator than before", locale.FullName))
++i
      try:
          coll = Collator.GetInstance(UCultureInfo("blahaha"))
      except Exception:
Errln("Failed to open collator with " + e)
          return
      var valid: UCultureInfo = coll.ValidCulture
      var name: String = valid.FullName
      if name.Length != 0 && !name.Equals("root"):
Errln("Valid locale for nonexisting locale collator is "" + name + "" not root")
      var actual: UCultureInfo = coll.ActualCulture
      name = actual.FullName
      if name.Length != 0 && !name.Equals("root"):
Errln("Actual locale for nonexisting locale collator is "" + name + "" not root")
    try:
        coll = RuleBasedCollator(rules)
    except Exception:
Errln("RuleBasedCollator(" + rules + ") failed: " + e)
        return
    locale = coll.ValidCulture
    if locale != nil:
Errln(String.Format("For collator instantiated from rules, valid locale {0} is not bogus", locale.FullName))
    locale = coll.ActualCulture
    if locale != nil:
Errln(String.Format("For collator instantiated from rules, actual locale {0} is not bogus", locale.FullName))
proc TestBounds*() =
    var coll: Collator = Collator.GetInstance(CultureInfo("sh"))
    var test: String[] = @["John Smith", "JOHN SMITH", "john SMITH", "jöhn smïth", "Jöhn Smïth", "JÖHN SMÏTH", "john smithsonian", "John Smithsonian"]
    var testStr: String[] = @["ČAKI MIHALJ", "ČAKI MIHALJ", "ČAKI PIROŠKA", "ČABAI ANDRIJA", "ČABAI LAJOŠ", "ČABAI MARIJA", "ČABAI STEVAN", "ČABAI STEVAN", "ČABARKAPA BRANKO", "ČABARKAPA MILENKO", "ČABARKAPA MIROSLAV", "ČABARKAPA SIMO", "ČABARKAPA STANKO", "ČABARKAPA TAMARA", "ČABARKAPA TOMAŠ", "ČABDARIĆ NIKOLA", "ČABDARIĆ ZORICA", "ČABI NANDOR", "ČABOVIĆ MILAN", "ČABRADI AGNEZIJA", "ČABRADI IVAN", "ČABRADI JELENA", "ČABRADI LJUBICA", "ČABRADI STEVAN", "ČABRDA MARTIN", "ČABRILO BOGDAN", "ČABRILO BRANISLAV", "ČABRILO LAZAR", "ČABRILO LJUBICA", "ČABRILO SPASOJA", "ČADEŠ ZDENKA", "ČADESKI BLAGOJE", "ČADOVSKI VLADIMIR", "ČAGLJEVIĆ TOMA", "ČAGOROVIĆ VLADIMIR", "ČAJA VANKA", "ČAJIĆ BOGOLJUB", "ČAJIĆ BORISLAV", "ČAJIĆ RADOSLAV", "ČAKŠIRAN MILADIN", "ČAKAN EUGEN", "ČAKAN EVGENIJE", "ČAKAN IVAN", "ČAKAN JULIJAN", "ČAKAN MIHAJLO", "ČAKAN STEVAN", "ČAKAN VLADIMIR", "ČAKAN VLADIMIR", "ČAKAN VLADIMIR", "ČAKARA ANA", "ČAKAREVIĆ MOMIR", "ČAKAREVIĆ NEDELJKO", "ČAKI ŠANDOR", "ČAKI AMALIJA", "ČAKI ANDRAŠ", "ČAKI LADISLAV", "ČAKI LAJOŠ", "ČAKI LASLO"]
    var testKey: CollationKey[] = seq[CollationKey]
      var i: int = 0
      while i < testStr.Length:
          testKey[i] = coll.GetCollationKey(testStr[i])
++i
Array.Sort(testKey)
      var i: int = 0
      while i < testKey.Length - 1:
          var lower: CollationKey = testKey[i].GetBound(CollationKeyBoundMode.Lower, Collator.Secondary)
            var j: int = i + 1
            while j < testKey.Length:
                var upper: CollationKey = testKey[j].GetBound(CollationKeyBoundMode.Upper, Collator.Secondary)
                  var k: int = i
                  while k <= j:
                      if lower.CompareTo(testKey[k]) > 0:
Errln("Problem with lower bound at i = " + i + " j = " + j + " k = " + k)
                      if upper.CompareTo(testKey[k]) <= 0:
Errln("Problem with upper bound at i = " + i + " j = " + j + " k = " + k)
++k
++j
++i
      var i: int = 0
      while i < test.Length:
          var key: CollationKey = coll.GetCollationKey(test[i])
          var lower: CollationKey = key.GetBound(CollationKeyBoundMode.Lower, Collator.Secondary)
          var upper: CollationKey = key.GetBound(CollationKeyBoundMode.UpperLong, Collator.Secondary)
            var j: int = i + 1
            while j < test.Length:
                key = coll.GetCollationKey(test[j])
                if lower.CompareTo(key) > 0:
Errln("Problem with lower bound i = " + i + " j = " + j)
                if upper.CompareTo(key) <= 0:
Errln("Problem with upper bound i = " + i + " j = " + j)
++j
++i
proc TestGetAll*() =
    var list: CultureInfo[] = Collator.GetCultures(UCultureTypes.AllCultures)
    var errorCount: int = 0
      var i: int = 0
      while i < list.Length:
Log("Locale name: ")
Log(string.Format(StringFormatter.CurrentCulture, "{0}", list[i]))
Log(" , the display name is : ")
Logln(list[i].DisplayName)
          try:
Logln("     ...... Or display as: " + Collator.GetDisplayName(list[i]))
Logln("     ...... and display in Chinese: " + Collator.GetDisplayName(list[i], CultureInfo("zh")))
          except MissingManifestResourceException:
++errorCount
Logln("could not get displayName for " + list[i])
++i
    if errorCount > 0:
Warnln("Could not load the locale data.")
proc DoSetsTest(@ref: UnicodeSet, set: UnicodeSet, inSet: String, outSet: String): bool =
    var ok: bool = true
set.Clear
set.ApplyPattern(inSet)
    if !@ref.ContainsAll(set):
Err("Some stuff from " + inSet + " is not present in the set.
Missing:" + set.RemoveAll(@ref).ToPattern(true) + "
")
        ok = false
set.Clear
set.ApplyPattern(outSet)
    if !@ref.ContainsNone(set):
Err("Some stuff from " + outSet + " is present in the set.
Unexpected:" + set.RetainAll(@ref).ToPattern(true) + "
")
        ok = false
    return ok
proc TestGetContractions*() =
    var tests: String[][] = @[@["ru", "[{Й}{й}]", "[йї]", "[æ]", "[ae]", "[Ии]", "[aAbBxv]"], @["uk", "[{Ї}{ї}{Й}{й}]", "[ЇЙйї]", "[æ]", "[ae]", "[ІіИи]", "[aAbBxv]"], @["sh", "[{Ć}{Č}{Ć}{DŽ}{Dž}{DŽ}{Dž}{lj}{nj}]", "[{ゞ}{ヾ}]", "[æ]", "[a]", "[nlcdzNLCDZ]", "[jabv]"], @["ja", "[{ごゝ}{ごゞ}{ごー}" + "{こゝ}{こゞ}{こー}" + "{ゴー}{ゴヽ}{ゴヾ}" + "{コー}{コヽ}{コヾ}]", "[{ヾ}{ゞ}{ご}{ゴ}{lj}{nj}]", "[ヾæ]", "[a]", "[゙]", "[]"]]
    var coll: RuleBasedCollator = nil
    var i: int = 0
    var conts: UnicodeSet = UnicodeSet
    var exp: UnicodeSet = UnicodeSet
    var set: UnicodeSet = UnicodeSet
      i = 0
      while i < tests.Length:
Logln("Testing locale: " + tests[i][0])
          coll = cast[RuleBasedCollator](Collator.GetInstance(UCultureInfo(tests[i][0])))
coll.GetContractionsAndExpansions(conts, exp, true)
          var ok: bool = true
Logln("Contractions " + conts.Count + ":
" + conts.ToPattern(true))
          ok = DoSetsTest(conts, set, tests[i][1], tests[i][2])
Logln("Expansions " + exp.Count + ":
" + exp.ToPattern(true))
          ok = DoSetsTest(exp, set, tests[i][3], tests[i][4])
          if !ok:
              var rules: String = coll.GetRules(false)
Logln("Collation rules (getLocale()=" + coll.ActualCulture.ToString + "): " + Utility.Escape(rules))
++i
proc TestClone*() =
Logln("
init c0")
    var c0: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance)
    c0.Strength = Collator.Tertiary
Dump("c0", c0)
Logln("
init c1")
    var c1: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance)
    c1.Strength = Collator.Tertiary
    c1.IsUpperCaseFirst = !c1.IsUpperCaseFirst
Dump("c0", c0)
Dump("c1", c1)
Logln("
init c2")
    var c2: RuleBasedCollator = cast[RuleBasedCollator](c1.Clone)
    c2.IsUpperCaseFirst = !c2.IsUpperCaseFirst
Dump("c0", c0)
Dump("c1", c1)
Dump("c2", c2)
    if c1.Equals(c2):
Errln("The cloned objects refer to same data")
proc Dump(msg: String, c: RuleBasedCollator) =
Logln(msg + " " + c.Compare(bigone, littleone) + " s: " + c.Strength + " u: " + c.IsUpperCaseFirst)
proc TestIterNumeric*() =
    var coll: RuleBasedCollator = RuleBasedCollator("[reorder Hang Hani]")
    coll.IsNumericCollation = true
    var result: int = coll.Compare("40", "72")
assertTrue("40<72", result < 0)
proc TestSetStrength*() =
    var cases: int[] = @[-1, 4, 5]
      var i: int = 0
      while i < cases.Length:
          try:
              var c: Collator = Collator.GetInstance
              c.Strength = cast[CollationStrength](cases[i])
Errln("Collator.setStrength(int) is suppose to return " + "an exception for an invalid newStrength value of " + cases[i])
          except Exception:

++i
proc TestSetDecomposition*() =
    var cases: int[] = @[0, 1, 14, 15, 18, 19]
      var i: int = 0
      while i < cases.Length:
          try:
              var c: Collator = Collator.GetInstance
              c.Decomposition = cast[NormalizationMode](cases[i])
Errln("Collator.setDecomposition(int) is suppose to return " + "an exception for an invalid decomposition value of " + cases[i])
          except Exception:

++i
type
  TestCreateCollator0 = ref object


proc GetSupportedLocaleIDs*(): ICollection<String> =
    return HashSet<String>
proc newTestCreateCollator0(): TestCreateCollator0 =
newCollatorFactory
proc CreateCollator*(c: UCultureInfo): Collator =
    return nil
type
  TestCreateCollator1 = ref object


proc GetSupportedLocaleIDs*(): ICollection<String> =
    return HashSet<String>
proc newTestCreateCollator1(): TestCreateCollator1 =
newCollatorFactory
proc CreateCollator*(c: CultureInfo): Collator =
    return nil
proc Visible(): bool =
    return false
proc TestCreateCollator*() =
    try:
        var tcc: TestCreateCollator0 = TestCreateCollator0
tcc.CreateCollator(CultureInfo("en-US"))
    except Exception:
Errln("Collator.createCollator(Locale) was not suppose to " + "return an exception.")
    try:
        var tcc: TestCreateCollator1 = TestCreateCollator1
tcc.CreateCollator(UCultureInfo("en_US"))
    except Exception:
Errln("Collator.CreateCollator(UCultureInfo) was not suppose to " + "return an exception.")
    try:
        var tcc: TestCreateCollator0 = TestCreateCollator0
tcc.GetDisplayName(CultureInfo("en-US"), CultureInfo("jp-JP"))
    except Exception:
Errln("Collator.getDisplayName(Locale,Locale) was not suppose to return an exception.")
    try:
        var tcc: TestCreateCollator1 = TestCreateCollator1
tcc.GetDisplayName(UCultureInfo("en_US"), UCultureInfo("jp_JP"))
    except Exception:
Errln("Collator.GetDisplayName(UCultureInfo,UCultureInfo) was not suppose to return an exception.")
proc TestGetKeywordValues*() =
    var cases: String[] = @["", "dummy"]
      var i: int = 0
      while i < cases.Length:
          try:
              var s: String[] = Collator.GetKeywordValues(cases[i])
Errln("Collator.getKeywordValues(String) is suppose to return " + "an exception for an invalid keyword.")
          except Exception:

++i
proc TestBadKeywords*() =
    var localeID: String = "it-u-ks-xyz"
    try:
Collator.GetInstance(UCultureInfo(localeID))
Errln("Collator.GetInstance(" + localeID + ") did not fail as expected")
    except ArgumentException:

    except Exception:
Errln("Collator.GetInstance(" + localeID + ") did not fail as expected - " + other)
    localeID = "it@colHiraganaQuaternary=true"
    try:
Collator.GetInstance(UCultureInfo(localeID))
Errln("Collator.GetInstance(" + localeID + ") did not fail as expected")
    except NotSupportedException:

    except Exception:
Errln("Collator.GetInstance(" + localeID + ") did not fail as expected - " + other)
    localeID = "it-u-vt-u24"
    try:
Collator.GetInstance(UCultureInfo(localeID))
Errln("Collator.GetInstance(" + localeID + ") did not fail as expected")
    except NotSupportedException:

    except Exception:
Errln("Collator.GetInstance(" + localeID + ") did not fail as expected - " + other)
proc TestGapTooSmall*() =
    try:
RuleBasedCollator("&☺<*一-鿿")
Errln("no exception for primary-gap overflow")
    except NotSupportedException:
assertTrue("exception message mentions 'gap'", e.Message.Contains("gap"))
    except Exception:
Errln("unexpected exception for primary-gap overflow: " + e)
    try:
        var coll: Collator = RuleBasedCollator("&[before 1]﷑€<*一-鿿")
assertTrue("tailored Han before currency", coll.Compare("一", "$") < 0)
    except Exception:
Errln("unexpected exception for tailoring many characters at the end of symbols: " + e)