# "Namespace: ICU4N.Dev.Test.Lang"
type
  UCharacterCaseTest = ref object
    ZIG_ZAG: seq[int] = @[0, 1, 2, 3, 2, 1]
    TURKISH_LOCALE_: CultureInfo = CultureInfo("tr-TR")
    GERMAN_LOCALE_: CultureInfo = CultureInfo("de-DE")
    GREEK_LOCALE_: CultureInfo = CultureInfo("el-GR")
    ENGLISH_LOCALE_: CultureInfo = CultureInfo("en-US")
    LITHUANIAN_LOCALE_: CultureInfo = CultureInfo("lt-LT")
    DUTCH_LOCALE_: CultureInfo = CultureInfo("nl")
    CHARACTER_UPPER_: seq[int] = @[65, 66, 67, 68, 69, 70, 71, 177, 178, 179, 72, 73, 74, 46, 63, 58, 75, 76, 77, 78, 79, 452, 456, 12, 0]
    CHARACTER_LOWER_: seq[int] = @[97, 98, 99, 100, 101, 102, 103, 177, 178, 179, 104, 105, 106, 46, 63, 58, 107, 108, 109, 110, 111, 454, 457, 12, 0]
    FOLDING_SIMPLE_: seq[int] = @[97, 97, 97, 73, 105, 305, 304, 304, 105, 305, 305, 305, 223, 223, 223, 64259, 64259, 64259, 66574, 66614, 66614, 393215, 393215, 393215]
    FOLDING_MIXED_: seq[String] = @["aBİIıϐßﬃ񟿿", "Aßµﬃ𐐌İı"]
    FOLDING_DEFAULT_: seq[String] = @["abi̇iıβssffi񟿿", "assμffi𐐴i̇ı"]
    FOLDING_EXCLUDE_SPECIAL_I_: seq[String] = @["abiııβssffi񟿿", "assμffi𐐴iı"]
    SHARED_UPPERCASE_GREEK_: String = "ΙΕΣΥΣ ΧΡΙΣΤΟΣ"
    SHARED_LOWERCASE_GREEK_: String = "ιεσυς χριστος"
    SHARED_LOWERCASE_TURKISH_: String = "istanbul, not constantınople!"
    SHARED_UPPERCASE_TURKISH_: String = "TOPKAPI PALACE, İSTANBUL"
    SHARED_UPPERCASE_ISTANBUL_: String = "İSTANBUL, NOT CONSTANTINOPLE!"
    SHARED_LOWERCASE_ISTANBUL_: String = "i̇stanbul, not constantinople!"
    SHARED_LOWERCASE_TOPKAP_: String = "topkapı palace, istanbul"
    SHARED_UPPERCASE_TOPKAP_: String = "TOPKAPI PALACE, ISTANBUL"
    SHARED_LOWERCASE_GERMAN_: String = "Süßmayrstraße"
    SHARED_UPPERCASE_GERMAN_: String = "SÜSSMAYRSTRASSE"
    UPPER_BEFORE_: String = "aBiςßσ/ﬃﬃﬃ񟿿"
    UPPER_ROOT_: String = "ABIΣSSΣ/FFIFFIFFI񟿿"
    UPPER_TURKISH_: String = "ABİΣSSΣ/FFIFFIFFI񟿿"
    UPPER_MINI_: String = "ßa"
    UPPER_MINI_UPPER_: String = "SSA"
    LOWER_BEFORE_: String = "aBIΣßΣ/񟿿"
    LOWER_ROOT_: String = "abiσßς/񟿿"
    LOWER_TURKISH_: String = "abıσßς/񟿿"
    TITLE_DATA_: seq[String] = @["aB iς ßσ/ﬃ񟿿", "AB IΣ SsΣ/Ffi񟿿", "", "0", "", "aB iς ßσ/ﬃ񟿿", "Ab Iς Ssσ/Ffi񟿿", "", "1", "", "ʻaMeLikA huI Pū ʻʻʻiA", "ʻAmelika Hui Pū ʻʻʻIa", "", "-1", "", " tHe QUIcK bRoWn", " The Quick Brown", "", "4", "", "ǄǅǆǇǈǉǊǋǌ", "ǅǅǅǈǈǈǋǋǋ", "", "0", "", "ǉubav ljubav", "ǈubav Ljubav", "", "-1", "", "'oH dOn'T tItLeCaSe AfTeR lEtTeR+'", "'Oh Don't Titlecase After Letter+'", "", "-1", "", "a ʻCaT. A ʻdOg! ʻeTc.", "A ʻCat. A ʻDog! ʻEtc.", "", "-1", "", "a ʻCaT. A ʻdOg! ʻeTc.", "A ʻcat. A ʻdog! ʻetc.", "", "-1", "A", "a ʻCaT. A ʻdOg! ʻeTc.", "A ʻCaT. A ʻdOg! ʻETc.", "", "3", "L", "ʻcAt! ʻeTc.", "ʻCat! ʻetc.", "", "-2", "", "ʻcAt! ʻeTc.", "ʻcat! ʻetc.", "", "-2", "A", "ʻcAt! ʻeTc.", "ʻCAt! ʻeTc.", "", "-2", "L", "ʻcAt! ʻeTc.", "ʻcAt! ʻeTc.", "", "-2", "AL", "a b c", "A B C", "", "1", "L"]
    SPECIAL_DATA_: seq[String] = @[UTF16.ValueOf(66620) + UTF16.ValueOf(66580), UTF16.ValueOf(66620) + UTF16.ValueOf(66620), UTF16.ValueOf(66580) + UTF16.ValueOf(66580), "ab'cD ﬀiıIİ Ǉǈǉ " + UTF16.ValueOf(66620) + UTF16.ValueOf(66580), "ab'cd ﬀiıii̇ ǉǉǉ " + UTF16.ValueOf(66620) + UTF16.ValueOf(66620), "AB'CD FFIIIİ ǇǇǇ " + UTF16.ValueOf(66580) + UTF16.ValueOf(66580), "i̇Σ̈j ̇Σ̈j i­Σ̈ ̇Σ̈ ", "i̇σ̈j ̇σ̈j i­ς̈ ̇σ̈ ", "İΣ̈J ̇Σ̈J I­Σ̈ ̇Σ̈ "]
    SPECIAL_LOCALES_: seq[CultureInfo] = @[nil, ENGLISH_LOCALE_, nil]
    SPECIAL_DOTTED_: String = "I İ İ İ̧ Í̇ İ̧́"
    SPECIAL_DOTTED_LOWER_TURKISH_: String = "ı i i i̧ ı́̇ í̧"
    SPECIAL_DOTTED_LOWER_GERMAN_: String = "i i̇ i̇ i̧̇ í̇ i̧̇́"
    SPECIAL_DOT_ABOVE_: String = "ȧ ̇ i̇ j̧̇ j́̇"
    SPECIAL_DOT_ABOVE_UPPER_LITHUANIAN_: String = "Ȧ ̇ I J̧ J́̇"
    SPECIAL_DOT_ABOVE_UPPER_GERMAN_: String = "Ȧ ̇ İ J̧̇ J́̇"
    SPECIAL_DOT_ABOVE_UPPER_: String = "I Í J J́ Į Į́ ÌÍĨ"
    SPECIAL_DOT_ABOVE_LOWER_LITHUANIAN_: String = "i i̇́ j j̇́ į į̇́ i̇̀i̇́i̇̃"
    SPECIAL_DOT_ABOVE_LOWER_GERMAN_: String = "i í j j́ į į́ ìíĩ"

proc newUCharacterCaseTest(): UCharacterCaseTest =

proc TestCharacter*() =
      var i: int = 0
      while i < CHARACTER_LOWER_.Length:
          if UChar.IsLetter(CHARACTER_LOWER_[i]) && !UChar.IsLower(CHARACTER_LOWER_[i]):
Errln("FAIL isLowerCase test for \u" + Hex(CHARACTER_LOWER_[i]))
              break
          if UChar.IsLetter(CHARACTER_UPPER_[i]) && !UChar.IsUpper(CHARACTER_UPPER_[i]) || UChar.IsTitleCase(CHARACTER_UPPER_[i]):
Errln("FAIL isUpperCase test for \u" + Hex(CHARACTER_UPPER_[i]))
              break
          if CHARACTER_LOWER_[i] != UChar.ToLower(CHARACTER_UPPER_[i]) || CHARACTER_UPPER_[i] != UChar.ToUpper(CHARACTER_LOWER_[i]) && CHARACTER_UPPER_[i] != UChar.ToTitleCase(CHARACTER_LOWER_[i]):
Errln("FAIL case conversion test for \u" + Hex(CHARACTER_UPPER_[i]) + " to \u" + Hex(CHARACTER_LOWER_[i]))
              break
          if CHARACTER_LOWER_[i] != UChar.ToLower(CHARACTER_LOWER_[i]):
Errln("FAIL lower case conversion test for \u" + Hex(CHARACTER_LOWER_[i]))
              break
          if CHARACTER_UPPER_[i] != UChar.ToUpper(CHARACTER_UPPER_[i]) && CHARACTER_UPPER_[i] != UChar.ToTitleCase(CHARACTER_UPPER_[i]):
Errln("FAIL upper case conversion test for \u" + Hex(CHARACTER_UPPER_[i]))
              break
Logln("Ok    \u" + Hex(CHARACTER_UPPER_[i]) + " and \u" + Hex(CHARACTER_LOWER_[i]))
++i
proc TestFolding*() =
      var i: int = 0
      while i < FOLDING_SIMPLE_.Length:
          if UChar.FoldCase(FOLDING_SIMPLE_[i], true) != FOLDING_SIMPLE_[i + 1]:
Errln("FAIL: foldCase(\u" + Hex(FOLDING_SIMPLE_[i]) + ", true) should be \u" + Hex(FOLDING_SIMPLE_[i + 1]))
          if UChar.FoldCase(FOLDING_SIMPLE_[i], FoldCase.Default) != FOLDING_SIMPLE_[i + 1]:
Errln("FAIL: foldCase(\u" + Hex(FOLDING_SIMPLE_[i]) + ", UCharacter.FOLD_CASE_DEFAULT) should be \u" + Hex(FOLDING_SIMPLE_[i + 1]))
          if UChar.FoldCase(FOLDING_SIMPLE_[i], false) != FOLDING_SIMPLE_[i + 2]:
Errln("FAIL: foldCase(\u" + Hex(FOLDING_SIMPLE_[i]) + ", false) should be \u" + Hex(FOLDING_SIMPLE_[i + 2]))
          if UChar.FoldCase(FOLDING_SIMPLE_[i], FoldCase.ExcludeSpecialI) != FOLDING_SIMPLE_[i + 2]:
Errln("FAIL: foldCase(\u" + Hex(FOLDING_SIMPLE_[i]) + ", UCharacter.FOLD_CASE_EXCLUDE_SPECIAL_I) should be \u" + Hex(FOLDING_SIMPLE_[i + 2]))
          i = 3
    if !FOLDING_DEFAULT_[0].Equals(UChar.FoldCase(FOLDING_MIXED_[0], true)):
Errln("FAIL: foldCase(" + Prettify(FOLDING_MIXED_[0]) + ", true)=" + Prettify(UChar.FoldCase(FOLDING_MIXED_[0], true)) + " should be " + Prettify(FOLDING_DEFAULT_[0]))
    if !FOLDING_DEFAULT_[0].Equals(UChar.FoldCase(FOLDING_MIXED_[0], FoldCase.Default)):
Errln("FAIL: foldCase(" + Prettify(FOLDING_MIXED_[0]) + ", UCharacter.FOLD_CASE_DEFAULT)=" + Prettify(UChar.FoldCase(FOLDING_MIXED_[0], FoldCase.Default)) + " should be " + Prettify(FOLDING_DEFAULT_[0]))
    if !FOLDING_EXCLUDE_SPECIAL_I_[0].Equals(UChar.FoldCase(FOLDING_MIXED_[0], false)):
Errln("FAIL: foldCase(" + Prettify(FOLDING_MIXED_[0]) + ", false)=" + Prettify(UChar.FoldCase(FOLDING_MIXED_[0], false)) + " should be " + Prettify(FOLDING_EXCLUDE_SPECIAL_I_[0]))
    if !FOLDING_EXCLUDE_SPECIAL_I_[0].Equals(UChar.FoldCase(FOLDING_MIXED_[0], FoldCase.ExcludeSpecialI)):
Errln("FAIL: foldCase(" + Prettify(FOLDING_MIXED_[0]) + ", UCharacter.FOLD_CASE_EXCLUDE_SPECIAL_I)=" + Prettify(UChar.FoldCase(FOLDING_MIXED_[0], FoldCase.ExcludeSpecialI)) + " should be " + Prettify(FOLDING_EXCLUDE_SPECIAL_I_[0]))
    if !FOLDING_DEFAULT_[1].Equals(UChar.FoldCase(FOLDING_MIXED_[1], true)):
Errln("FAIL: foldCase(" + Prettify(FOLDING_MIXED_[1]) + ", true)=" + Prettify(UChar.FoldCase(FOLDING_MIXED_[1], true)) + " should be " + Prettify(FOLDING_DEFAULT_[1]))
    if !FOLDING_DEFAULT_[1].Equals(UChar.FoldCase(FOLDING_MIXED_[1], FoldCase.Default)):
Errln("FAIL: foldCase(" + Prettify(FOLDING_MIXED_[1]) + ", UCharacter.FOLD_CASE_DEFAULT)=" + Prettify(UChar.FoldCase(FOLDING_MIXED_[1], FoldCase.Default)) + " should be " + Prettify(FOLDING_DEFAULT_[1]))
    if !FOLDING_EXCLUDE_SPECIAL_I_[1].Equals(UChar.FoldCase(FOLDING_MIXED_[1], false)):
Errln("FAIL: foldCase(" + Prettify(FOLDING_MIXED_[1]) + ", false)=" + Prettify(UChar.FoldCase(FOLDING_MIXED_[1], false)) + " should be " + Prettify(FOLDING_EXCLUDE_SPECIAL_I_[1]))
    if !FOLDING_EXCLUDE_SPECIAL_I_[1].Equals(UChar.FoldCase(FOLDING_MIXED_[1], FoldCase.ExcludeSpecialI)):
Errln("FAIL: foldCase(" + Prettify(FOLDING_MIXED_[1]) + ", UCharacter.FOLD_CASE_EXCLUDE_SPECIAL_I)=" + Prettify(UChar.FoldCase(FOLDING_MIXED_[1], FoldCase.ExcludeSpecialI)) + " should be " + Prettify(FOLDING_EXCLUDE_SPECIAL_I_[1]))
proc TestUpper*() =
    if !UPPER_ROOT_.Equals(UChar.ToUpper(UPPER_BEFORE_)):
Errln("Fail " + UPPER_BEFORE_ + " after uppercase should be " + UPPER_ROOT_ + " instead got " + UChar.ToUpper(UPPER_BEFORE_))
    if !UPPER_TURKISH_.Equals(UChar.ToUpper(TURKISH_LOCALE_, UPPER_BEFORE_)):
Errln("Fail " + UPPER_BEFORE_ + " after turkish-sensitive uppercase should be " + UPPER_TURKISH_ + " instead of " + UChar.ToUpper(TURKISH_LOCALE_, UPPER_BEFORE_))
    if !UPPER_MINI_UPPER_.Equals(UChar.ToUpper(UPPER_MINI_)):
Errln("error in toUpper(root locale)="" + UPPER_MINI_ + "" expected "" + UPPER_MINI_UPPER_ + """)
    if !SHARED_UPPERCASE_TOPKAP_.Equals(UChar.ToUpper(SHARED_LOWERCASE_TOPKAP_)):
Errln("toUpper failed: expected "" + SHARED_UPPERCASE_TOPKAP_ + "", got "" + UChar.ToUpper(SHARED_LOWERCASE_TOPKAP_) + "".")
    if !SHARED_UPPERCASE_TURKISH_.Equals(UChar.ToUpper(TURKISH_LOCALE_, SHARED_LOWERCASE_TOPKAP_)):
Errln("toUpper failed: expected "" + SHARED_UPPERCASE_TURKISH_ + "", got "" + UChar.ToUpper(TURKISH_LOCALE_, SHARED_LOWERCASE_TOPKAP_) + "".")
    if !SHARED_UPPERCASE_GERMAN_.Equals(UChar.ToUpper(GERMAN_LOCALE_, SHARED_LOWERCASE_GERMAN_)):
Errln("toUpper failed: expected "" + SHARED_UPPERCASE_GERMAN_ + "", got "" + UChar.ToUpper(GERMAN_LOCALE_, SHARED_LOWERCASE_GERMAN_) + "".")
    if !SHARED_UPPERCASE_GREEK_.Equals(UChar.ToUpper(SHARED_LOWERCASE_GREEK_)):
Errln("toLower failed: expected "" + SHARED_UPPERCASE_GREEK_ + "", got "" + UChar.ToUpper(SHARED_LOWERCASE_GREEK_) + "".")
proc TestLower*() =
    if !LOWER_ROOT_.Equals(UChar.ToLower(LOWER_BEFORE_)):
Errln("Fail " + LOWER_BEFORE_ + " after lowercase should be " + LOWER_ROOT_ + " instead of " + UChar.ToLower(LOWER_BEFORE_))
    if !LOWER_TURKISH_.Equals(UChar.ToLower(TURKISH_LOCALE_, LOWER_BEFORE_)):
Errln("Fail " + LOWER_BEFORE_ + " after turkish-sensitive lowercase should be " + LOWER_TURKISH_ + " instead of " + UChar.ToLower(TURKISH_LOCALE_, LOWER_BEFORE_))
    if !SHARED_LOWERCASE_ISTANBUL_.Equals(UChar.ToLower(SHARED_UPPERCASE_ISTANBUL_)):
Errln("1. toLower failed: expected "" + SHARED_LOWERCASE_ISTANBUL_ + "", got "" + UChar.ToLower(SHARED_UPPERCASE_ISTANBUL_) + "".")
    if !SHARED_LOWERCASE_TURKISH_.Equals(UChar.ToLower(TURKISH_LOCALE_, SHARED_UPPERCASE_ISTANBUL_)):
Errln("2. toLower failed: expected "" + SHARED_LOWERCASE_TURKISH_ + "", got "" + UChar.ToLower(TURKISH_LOCALE_, SHARED_UPPERCASE_ISTANBUL_) + "".")
    if !SHARED_LOWERCASE_GREEK_.Equals(UChar.ToLower(GREEK_LOCALE_, SHARED_UPPERCASE_GREEK_)):
Errln("toLower failed: expected "" + SHARED_LOWERCASE_GREEK_ + "", got "" + UChar.ToLower(GREEK_LOCALE_, SHARED_UPPERCASE_GREEK_) + "".")
proc TestTitleRegression*() =
    var isIgnorable: bool = UChar.HasBinaryProperty(''', UProperty.Case_Ignorable)
assertTrue("Case Ignorable check of ASCII apostrophe", isIgnorable)
assertEquals("Titlecase check", "The Quick Brown Fox Can't Jump Over The Lazy Dogs.", UChar.ToTitleCase(UCultureInfo("en"), "THE QUICK BROWN FOX CAN'T JUMP OVER THE LAZY DOGS.", nil))
proc TestTitle*() =
    try:
          var i: int = 0
          while i < TITLE_DATA_.Length:
              var test: String = TITLE_DATA_[++i]
              var expected: String = TITLE_DATA_[++i]
              var locale: UCultureInfo = UCultureInfo(TITLE_DATA_[++i])
              var breakType: int = int.Parse(TITLE_DATA_[++i], CultureInfo.InvariantCulture)
              var optionsString: String = TITLE_DATA_[++i]
              var iter: BreakIterator =               if breakType >= 0:
BreakIterator.GetBreakInstance(locale, breakType)
              else:
                  if breakType == -2:
RuleBasedBreakIterator(".*;")
                  else:
nil
              var options: int = 0
              if optionsString.IndexOf('L') >= 0:
                  options = UChar.TitleCaseNoLowerCase
              if optionsString.IndexOf('A') >= 0:
                  options = UChar.TitleCaseNoBreakAdjustment
              var result: String = UChar.ToTitleCase(locale, test, iter, options)
              if !expected.Equals(result):
Errln("titlecasing for " + Prettify(test) + " (options " + options + ") should be " + Prettify(expected) + " but got " + Prettify(result))
              if options == 0:
                  result = UChar.ToTitleCase(locale, test, iter)
                  if !expected.Equals(result):
Errln("titlecasing for " + Prettify(test) + " should be " + Prettify(expected) + " but got " + Prettify(result))
    except Exception:
Warnln("Could not find data for BreakIterators")
proc TestCasingImpl(input: String, output: String, toTitle: TitleCaseMap, locale: CultureInfo) =
    var sb = ValueStringBuilder(newSeq[char](32))
    try:
toTitle.Apply(locale, nil, input.AsMemory, sb, nil)
        var result: string = sb.ToString
assertEquals("toTitle(" + input + ')', output, result)
    finally:
sb.Dispose
proc TestTitleOptions*() =
    var root: CultureInfo = CultureInfo.InvariantCulture
TestCasingImpl("ʻcAt! ʻeTc.", "ʻCat! ʻetc.", CaseMap.ToTitle.WholeString, root)
TestCasingImpl("a ʻCaT. A ʻdOg! ʻeTc.", "A ʻCaT. A ʻdOg! ʻETc.", CaseMap.ToTitle.Sentences.NoLowercase, root)
TestCasingImpl("49eRs", "49ers", CaseMap.ToTitle.WholeString, root)
TestCasingImpl("«丰(aBc)»", "«丰(abc)»", CaseMap.ToTitle.WholeString, root)
TestCasingImpl("49eRs", "49Ers", CaseMap.ToTitle.WholeString.AdjustToCased, root)
TestCasingImpl("«丰(aBc)»", "«丰(Abc)»", CaseMap.ToTitle.WholeString.AdjustToCased, root)
TestCasingImpl(" john. Smith", " John. Smith", CaseMap.ToTitle.WholeString.NoLowercase, root)
TestCasingImpl(" john. Smith", " john. smith", CaseMap.ToTitle.WholeString.NoBreakAdjustment, root)
TestCasingImpl("«ijs»", "«IJs»", CaseMap.ToTitle.WholeString, CultureInfo("nl-BE"))
TestCasingImpl("«ijs»", "«İjs»", CaseMap.ToTitle.WholeString, CultureInfo("tr-DE"))
    try:
CaseMap.ToTitle.NoBreakAdjustment.AdjustToCased.Apply(root, nil, "".AsMemory, StringBuilder, nil)
fail("CaseMap.toTitle(multiple adjustment options) " + "did not throw an ArgumentException")
    except ArgumentException:

    try:
CaseMap.ToTitle.WholeString.Sentences.Apply(root, nil, "".AsMemory, StringBuilder, nil)
fail("CaseMap.toTitle(multiple iterator options) " + "did not throw an ArgumentException")
    except ArgumentException:

    var iter: BreakIterator = BreakIterator.GetCharacterInstance(root)
    try:
CaseMap.ToTitle.WholeString.Apply(root, iter, "".AsMemory, StringBuilder, nil)
fail("CaseMap.toTitle(iterator option + iterator) " + "did not throw an ArgumentException")
    except ArgumentException:

proc TestDutchTitle*() =
    var LOC_DUTCH: UCultureInfo = UCultureInfo("nl")
    var options: int = 0
    options = UChar.TitleCaseNoLowerCase
    var iter: BreakIterator = BreakIterator.GetWordInstance(LOC_DUTCH)
assertEquals("Dutch titlecase check in English", "Ijssel Igloo Ijmuiden", UChar.ToTitleCase(UCultureInfo("en"), "ijssel igloo IJMUIDEN", nil))
assertEquals("Dutch titlecase check in Dutch", "IJssel Igloo IJmuiden", UChar.ToTitleCase(LOC_DUTCH, "ijssel igloo IJMUIDEN", nil))
assertEquals("Dutch titlecase check in English (Java Locale)", "Ijssel Igloo Ijmuiden", UChar.ToTitleCase(CultureInfo("en"), "ijssel igloo IJMUIDEN", nil))
assertEquals("Dutch titlecase check in Dutch (Java Locale)", "IJssel Igloo IJmuiden", UChar.ToTitleCase(DUTCH_LOCALE_, "ijssel igloo IJMUIDEN", nil))
iter.SetText("ijssel igloo IjMUIdEN iPoD ijenough")
assertEquals("Dutch titlecase check in Dutch with nolowercase option", "IJssel Igloo IJMUIdEN IPoD IJenough", UChar.ToTitleCase(LOC_DUTCH, "ijssel igloo IjMUIdEN iPoD ijenough", iter, options))
proc TestSpecial*() =
      var i: int = 0
      while i < SPECIAL_LOCALES_.Length:
          var j: int = i * 3
          var locale: CultureInfo = SPECIAL_LOCALES_[i]
          var str: String = SPECIAL_DATA_[j]
          if locale != nil:
              if !SPECIAL_DATA_[j + 1].Equals(UChar.ToLower(locale, str)):
Errln("error lowercasing special characters " + Hex(str) + " expected " + Hex(SPECIAL_DATA_[j + 1]) + " for locale " + locale.ToString + " but got " + Hex(UChar.ToLower(locale, str)))
              if !SPECIAL_DATA_[j + 2].Equals(UChar.ToUpper(locale, str)):
Errln("error uppercasing special characters " + Hex(str) + " expected " + SPECIAL_DATA_[j + 2] + " for locale " + locale.ToString + " but got " + Hex(UChar.ToUpper(locale, str)))
          else:
              if !SPECIAL_DATA_[j + 1].Equals(UChar.ToLower(str)):
Errln("error lowercasing special characters " + Hex(str) + " expected " + SPECIAL_DATA_[j + 1] + " but got " + Hex(UChar.ToLower(locale, str)))
              if !SPECIAL_DATA_[j + 2].Equals(UChar.ToUpper(locale, str)):
Errln("error uppercasing special characters " + Hex(str) + " expected " + SPECIAL_DATA_[j + 2] + " but got " + Hex(UChar.ToUpper(locale, str)))
++i
    if !SPECIAL_DOTTED_LOWER_TURKISH_.Equals(UChar.ToLower(TURKISH_LOCALE_, SPECIAL_DOTTED_)):
Errln("error in dots.toLower(tr)="" + SPECIAL_DOTTED_ + "" expected "" + SPECIAL_DOTTED_LOWER_TURKISH_ + "" but got " + UChar.ToLower(TURKISH_LOCALE_, SPECIAL_DOTTED_))
    if !SPECIAL_DOTTED_LOWER_GERMAN_.Equals(UChar.ToLower(GERMAN_LOCALE_, SPECIAL_DOTTED_)):
Errln("error in dots.toLower(de)="" + SPECIAL_DOTTED_ + "" expected "" + SPECIAL_DOTTED_LOWER_GERMAN_ + "" but got " + UChar.ToLower(GERMAN_LOCALE_, SPECIAL_DOTTED_))
    if !SPECIAL_DOT_ABOVE_UPPER_LITHUANIAN_.Equals(UChar.ToUpper(LITHUANIAN_LOCALE_, SPECIAL_DOT_ABOVE_)):
Errln("error in dots.toUpper(lt)="" + SPECIAL_DOT_ABOVE_ + "" expected "" + SPECIAL_DOT_ABOVE_UPPER_LITHUANIAN_ + "" but got " + UChar.ToLower(LITHUANIAN_LOCALE_, SPECIAL_DOT_ABOVE_))
    if !SPECIAL_DOT_ABOVE_UPPER_GERMAN_.Equals(UChar.ToUpper(GERMAN_LOCALE_, SPECIAL_DOT_ABOVE_)):
Errln("error in dots.toUpper(de)="" + SPECIAL_DOT_ABOVE_ + "" expected "" + SPECIAL_DOT_ABOVE_UPPER_GERMAN_ + "" but got " + UChar.ToLower(GERMAN_LOCALE_, SPECIAL_DOT_ABOVE_))
    if !SPECIAL_DOT_ABOVE_LOWER_LITHUANIAN_.Equals(UChar.ToLower(LITHUANIAN_LOCALE_, SPECIAL_DOT_ABOVE_UPPER_)):
Errln("error in dots.toLower(lt)="" + SPECIAL_DOT_ABOVE_UPPER_ + "" expected "" + SPECIAL_DOT_ABOVE_LOWER_LITHUANIAN_ + "" but got " + UChar.ToLower(LITHUANIAN_LOCALE_, SPECIAL_DOT_ABOVE_UPPER_))
    if !SPECIAL_DOT_ABOVE_LOWER_GERMAN_.Equals(UChar.ToLower(GERMAN_LOCALE_, SPECIAL_DOT_ABOVE_UPPER_)):
Errln("error in dots.toLower(de)="" + SPECIAL_DOT_ABOVE_UPPER_ + "" expected "" + SPECIAL_DOT_ABOVE_LOWER_GERMAN_ + "" but got " + UChar.ToLower(GERMAN_LOCALE_, SPECIAL_DOT_ABOVE_UPPER_))
proc TestSpecialCasingTxt*() =
    try:
        var input: TextReader = TestUtil.GetDataReader("unicode/SpecialCasing.txt")
        while true:
            var s: String = input.ReadLine
            if s == nil:
                break
            if s.Length == 0 || s[0] == '#':
                continue
            var chstr: String[] = GetUnicodeStrings(s)
            var strbuffer: StringBuffer = StringBuffer(chstr[0])
            var lowerbuffer: StringBuffer = StringBuffer(chstr[1])
            var upperbuffer: StringBuffer = StringBuffer(chstr[3])
            var locale: CultureInfo = nil
              var i: int = 4
              while i < chstr.Length:
                  var condition: String = chstr[i]
                  if char.IsLower(chstr[i][0]):
                      locale = CultureInfo(chstr[i])

                  elif condition.CompareToOrdinalIgnoreCase("Not_Before_Dot") == 0:

                  else:
                    if condition.CompareToOrdinalIgnoreCase("More_Above") == 0:
strbuffer.Append(cast[char](768))
lowerbuffer.Append(cast[char](768))
upperbuffer.Append(cast[char](768))

                    elif condition.CompareToOrdinalIgnoreCase("After_Soft_Dotted") == 0:
strbuffer.Insert(0, 'i')
lowerbuffer.Insert(0, 'i')
                        var lang: String = ""
                        if locale != nil:
                            lang = UCultureInfo.GetLanguage(locale.Name)
                        if lang.Equals("tr") || lang.Equals("az"):
                            chstr[i] = "After_I"
strbuffer.Remove(0, 1)
lowerbuffer.Remove(0, 1)
--i
                            continue
                        else:
upperbuffer.Insert(0, 'I')
                    else:
                      if condition.CompareToOrdinalIgnoreCase("Final_Sigma") == 0:
strbuffer.Insert(0, 'c')
lowerbuffer.Insert(0, 'c')
upperbuffer.Insert(0, 'C')

                      elif condition.CompareToOrdinalIgnoreCase("After_I") == 0:
strbuffer.Insert(0, 'I')
lowerbuffer.Insert(0, 'i')
                          var lang: String = ""
                          if locale != nil:
                              lang = UCultureInfo.GetLanguage(locale.Name)
                          if lang.Equals("tr") || lang.Equals("az"):
upperbuffer.Insert(0, 'I')
++i
            chstr[0] = strbuffer.ToString
            chstr[1] = lowerbuffer.ToString
            chstr[3] = upperbuffer.ToString
            if locale == nil:
                if !UChar.ToLower(chstr[0]).Equals(chstr[1]):
Errln(s)
Errln("Fail: toLowerCase for character " + Utility.Escape(chstr[0]) + ", expected " + Utility.Escape(chstr[1]) + " but resulted in " + Utility.Escape(UChar.ToLower(chstr[0])))
                if !UChar.ToUpper(chstr[0]).Equals(chstr[3]):
Errln(s)
Errln("Fail: toUpperCase for character " + Utility.Escape(chstr[0]) + ", expected " + Utility.Escape(chstr[3]) + " but resulted in " + Utility.Escape(UChar.ToUpper(chstr[0])))
            else:
                if !UChar.ToLower(locale, chstr[0]).Equals(chstr[1]):
Errln(s)
Errln("Fail: toLowerCase for character " + Utility.Escape(chstr[0]) + ", expected " + Utility.Escape(chstr[1]) + " but resulted in " + Utility.Escape(UChar.ToLower(locale, chstr[0])))
                if !UChar.ToUpper(locale, chstr[0]).Equals(chstr[3]):
Errln(s)
Errln("Fail: toUpperCase for character " + Utility.Escape(chstr[0]) + ", expected " + Utility.Escape(chstr[3]) + " but resulted in " + Utility.Escape(UChar.ToUpper(locale, chstr[0])))
input.Dispose
    except Exception:
e.PrintStackTrace
proc TestUpperLower*() =
    var upper: int[] = @[65, 66, 178, 452, 454, 457, 456, 457, 12]
    var lower: int[] = @[97, 98, 178, 454, 454, 457, 457, 457, 12]
    var upperTest: String = "abcdefg123hij.?:klmno"
    var lowerTest: String = "ABCDEFG123HIJ.?:KLMNO"
      var i: int = 8448
      while i < 8504:
          if i != 8486 && i != 8490 && i != 8491 && i != 8498:
              if i != UChar.ToLower(i):
Errln("Failed case conversion with itself: \u" + Utility.Hex(i, 4))
              if i != UChar.ToLower(i):
Errln("Failed case conversion with itself: \u" + Utility.Hex(i, 4))
++i
      var i: int = 0
      while i < upper.Length:
          if UChar.ToLower(upper[i]) != lower[i]:
Errln("FAILED UCharacter.tolower() for \u" + Utility.Hex(upper[i], 4) + " Expected \u" + Utility.Hex(lower[i], 4) + " Got \u" + Utility.Hex(UChar.ToLower(upper[i]), 4))
++i
Logln("testing upper lower")
      var i: int = 0
      while i < upperTest.Length:
Logln("testing to upper to lower")
          if UChar.IsLetter(upperTest[i]) && !UChar.IsLower(upperTest[i]):
Errln("Failed isLowerCase test at \u" + Utility.Hex(upperTest[i], 4))

          elif UChar.IsLetter(lowerTest[i]) && !UChar.IsUpper(lowerTest[i]):
Errln("Failed isUpperCase test at \u" + Utility.Hex(lowerTest[i], 4))
          else:
            if upperTest[i] != UChar.ToLower(lowerTest[i]):
Errln("Failed case conversion from \u" + Utility.Hex(lowerTest[i], 4) + " To \u" + Utility.Hex(upperTest[i], 4))

            elif lowerTest[i] != UChar.ToUpper(upperTest[i]):
Errln("Failed case conversion : \u" + Utility.Hex(upperTest[i], 4) + " To \u" + Utility.Hex(lowerTest[i], 4))
            else:
              if upperTest[i] != UChar.ToLower(upperTest[i]):
Errln("Failed case conversion with itself: \u" + Utility.Hex(upperTest[i]))

              elif lowerTest[i] != UChar.ToUpper(lowerTest[i]):
Errln("Failed case conversion with itself: \u" + Utility.Hex(lowerTest[i]))
++i
Logln("done testing upper Lower")
proc AssertGreekUpper(s: String, expected: String) =
assertEquals("toUpper/Greek(" + s + ')', expected, UChar.ToUpper(GREEK_LOCALE_, s))
proc TestGreekUpper*() =
AssertGreekUpper("άδικος, κείμενο, ίριδα", "ΑΔΙΚΟΣ, ΚΕΙΜΕΝΟ, ΙΡΙΔΑ")
AssertGreekUpper("Πατάτα", "ΠΑΤΑΤΑ")
AssertGreekUpper("Αέρας, Μυστήριο, Ωραίο", "ΑΕΡΑΣ, ΜΥΣΤΗΡΙΟ, ΩΡΑΙΟ")
AssertGreekUpper("Μαΐου, Πόρος, Ρύθμιση", "ΜΑΪΟΥ, ΠΟΡΟΣ, ΡΥΘΜΙΣΗ")
AssertGreekUpper("ΰ, Τηρώ, Μάιος", "Ϋ, ΤΗΡΩ, ΜΑΪΟΣ")
AssertGreekUpper("άυλος", "ΑΫΛΟΣ")
AssertGreekUpper("ΑΫΛΟΣ", "ΑΫΛΟΣ")
AssertGreekUpper("Άκλιτα ρήματα ή άκλιτες μετοχές", "ΑΚΛΙΤΑ ΡΗΜΑΤΑ Ή ΑΚΛΙΤΕΣ ΜΕΤΟΧΕΣ")
AssertGreekUpper("Επειδή η αναγνώριση της αξιοπρέπειας", "ΕΠΕΙΔΗ Η ΑΝΑΓΝΩΡΙΣΗ ΤΗΣ ΑΞΙΟΠΡΕΠΕΙΑΣ")
AssertGreekUpper("νομικού ή διεθνούς", "ΝΟΜΙΚΟΥ Ή ΔΙΕΘΝΟΥΣ")
AssertGreekUpper("Ἐπειδὴ ἡ ἀναγνώριση", "ΕΠΕΙΔΗ Η ΑΝΑΓΝΩΡΙΣΗ")
AssertGreekUpper("νομικοῦ ἢ διεθνοῦς", "ΝΟΜΙΚΟΥ Ή ΔΙΕΘΝΟΥΣ")
AssertGreekUpper("Νέο, Δημιουργία", "ΝΕΟ, ΔΗΜΙΟΥΡΓΙΑ")
AssertGreekUpper("Ελάτε να φάτε τα καλύτερα παϊδάκια!", "ΕΛΑΤΕ ΝΑ ΦΑΤΕ ΤΑ ΚΑΛΥΤΕΡΑ ΠΑΪΔΑΚΙΑ!")
AssertGreekUpper("Μαΐου, τρόλεϊ", "ΜΑΪΟΥ, ΤΡΟΛΕΪ")
AssertGreekUpper("Το ένα ή το άλλο.", "ΤΟ ΕΝΑ Ή ΤΟ ΑΛΛΟ.")
AssertGreekUpper("ρωμέικα", "ΡΩΜΕΪΚΑ")
AssertGreekUpper("ή.", "Ή.")
type
  EditChange = ref object
    Change: bool
    OldLength: int
    NewLength: int

proc newEditChange(change: bool, oldLength: int, newLength: int): EditChange =
  self.Change = change
  self.OldLength = oldLength
  self.NewLength = newLength
proc PrintOneEdit(ei: EditsEnumerator): String =
    if ei.HasChange:
        return "" + ei.OldLength + "->" + ei.NewLength
    else:
        return "" + ei.OldLength + "=" + ei.NewLength
proc SrcIndexFromDest(expected: seq[EditChange], srcLength: int, destLength: int, index: int): int =
    var srcIndex: int = srcLength
    var destIndex: int = destLength
    var i: int = expected.Length
    while index < destIndex && i > 0:
--i
        var prevSrcIndex: int = srcIndex - expected[i].OldLength
        var prevDestIndex: int = destIndex - expected[i].NewLength
        if index == prevDestIndex:
            return prevSrcIndex

        elif index > prevDestIndex:
            if expected[i].Change:
                return srcIndex
            else:
                return prevSrcIndex + index - prevDestIndex
        srcIndex = prevSrcIndex
        destIndex = prevDestIndex
    return srcIndex
proc DestIndexFromSrc(expected: seq[EditChange], srcLength: int, destLength: int, index: int): int =
    var srcIndex: int = srcLength
    var destIndex: int = destLength
    var i: int = expected.Length
    while index < srcIndex && i > 0:
--i
        var prevSrcIndex: int = srcIndex - expected[i].OldLength
        var prevDestIndex: int = destIndex - expected[i].NewLength
        if index == prevSrcIndex:
            return prevDestIndex

        elif index > prevSrcIndex:
            if expected[i].Change:
                return destIndex
            else:
                return prevDestIndex + index - prevSrcIndex
        srcIndex = prevSrcIndex
        destIndex = prevDestIndex
    return destIndex
proc CheckEqualEdits(name: String, e1: Edits, e2: Edits) =
    var ei1: EditsEnumerator = e1.GetFineEnumerator
    var ei2: EditsEnumerator = e2.GetFineEnumerator
      var i: int = 0
      while true:
          var ei1HasNext: bool = ei1.MoveNext
          var ei2HasNext: bool = ei2.MoveNext
assertEquals(name + " next()[" + i + "]", ei1HasNext, ei2HasNext)
assertEquals(name + " edit[" + i + "]", PrintOneEdit(ei1), PrintOneEdit(ei2))
          if !ei1HasNext || !ei2HasNext:
              break
++i
proc CheckEditsIter(name: String, ei1: EditsEnumerator, ei2: EditsEnumerator, expected: seq[EditChange], withUnchanged: bool) =
assertFalse(name, ei2.FindSourceIndex(-1))
assertFalse(name, ei2.FindDestinationIndex(-1))
    var expSrcIndex: int = 0
    var expDestIndex: int = 0
    var expReplIndex: int = 0
      var expIndex: int = 0
      while expIndex < expected.Length:
          var expect: EditChange = expected[expIndex]
          var msg: String = name + ' ' + expIndex
          if withUnchanged || expect.Change:
assertTrue(msg, ei1.MoveNext)
assertEquals(msg, expect.Change, ei1.HasChange)
assertEquals(msg, expect.OldLength, ei1.OldLength)
assertEquals(msg, expect.NewLength, ei1.NewLength)
assertEquals(msg, expSrcIndex, ei1.SourceIndex)
assertEquals(msg, expDestIndex, ei1.DestinationIndex)
assertEquals(msg, expReplIndex, ei1.ReplacementIndex)
          if expect.OldLength > 0:
assertTrue(msg, ei2.FindSourceIndex(expSrcIndex))
assertEquals(msg, expect.Change, ei2.HasChange)
assertEquals(msg, expect.OldLength, ei2.OldLength)
assertEquals(msg, expect.NewLength, ei2.NewLength)
assertEquals(msg, expSrcIndex, ei2.SourceIndex)
assertEquals(msg, expDestIndex, ei2.DestinationIndex)
assertEquals(msg, expReplIndex, ei2.ReplacementIndex)
              if !withUnchanged:
ei2.MoveNext
ei2.MoveNext
          if expect.NewLength > 0:
assertTrue(msg, ei2.FindDestinationIndex(expDestIndex))
assertEquals(msg, expect.Change, ei2.HasChange)
assertEquals(msg, expect.OldLength, ei2.OldLength)
assertEquals(msg, expect.NewLength, ei2.NewLength)
assertEquals(msg, expSrcIndex, ei2.SourceIndex)
assertEquals(msg, expDestIndex, ei2.DestinationIndex)
assertEquals(msg, expReplIndex, ei2.ReplacementIndex)
              if !withUnchanged:
ei2.MoveNext
ei2.MoveNext
          expSrcIndex = expect.OldLength
          expDestIndex = expect.NewLength
          if expect.Change:
              expReplIndex = expect.NewLength
++expIndex
      var msg: String = name + " end"
assertFalse(msg, ei1.MoveNext)
assertFalse(msg, ei1.HasChange)
assertEquals(msg, 0, ei1.OldLength)
assertEquals(msg, 0, ei1.NewLength)
assertEquals(msg, expSrcIndex, ei1.SourceIndex)
assertEquals(msg, expDestIndex, ei1.DestinationIndex)
assertEquals(msg, expReplIndex, ei1.ReplacementIndex)
assertFalse(name, ei2.FindSourceIndex(expSrcIndex))
assertFalse(name, ei2.FindDestinationIndex(expDestIndex))
      var srcLength: int = expSrcIndex
      var destLength: int = expDestIndex
      var srcIndexes: List<int> = List<int>
      var destIndexes: List<int> = List<int>
srcIndexes.Add(-1)
destIndexes.Add(-1)
      var srcIndex: int = 0
      var destIndex: int = 0
        var i: int = 0
        while i < expected.Length:
            if expected[i].OldLength > 0:
srcIndexes.Add(srcIndex)
                if expected[i].OldLength > 1:
srcIndexes.Add(srcIndex + 1)
                    if expected[i].OldLength > 2:
srcIndexes.Add(srcIndex + expected[i].OldLength - 1)
            if expected[i].NewLength > 0:
destIndexes.Add(destIndex)
                if expected[i].NewLength > 1:
destIndexes.Add(destIndex + 1)
                    if expected[i].NewLength > 2:
destIndexes.Add(destIndex + expected[i].NewLength - 1)
            srcIndex = expected[i].OldLength
            destIndex = expected[i].NewLength
++i
srcIndexes.Add(srcLength)
destIndexes.Add(destLength)
srcIndexes.Add(srcLength + 1)
destIndexes.Add(destLength + 1)
destIndexes.Reverse
        var i: int = 0
        while i < srcIndexes.Count:
            for j in ZIG_ZAG:
                if i + j < srcIndexes.Count:
                    var si: int = srcIndexes[i + j]
assertEquals(name + " destIndexFromSrc(" + si + "):", DestIndexFromSrc(expected, srcLength, destLength, si), ei2.DestinationIndexFromSourceIndex(si))
++i
        var i: int = 0
        while i < destIndexes.Count:
            for j in ZIG_ZAG:
                if i + j < destIndexes.Count:
                    var di: int = destIndexes[i + j]
assertEquals(name + " srcIndexFromDest(" + di + "):", SrcIndexFromDest(expected, srcLength, destLength, di), ei2.SourceIndexFromDestinationIndex(di))
++i
proc TestEdits*() =
    var edits: Edits = Edits
assertFalse("new Edits hasChanges", edits.HasChanges)
assertEquals("new Edits numberOfChanges", 0, edits.NumberOfChanges)
assertEquals("new Edits", 0, edits.LengthDelta)
edits.AddUnchanged(1)
edits.AddUnchanged(10000)
edits.AddReplace(0, 0)
edits.AddUnchanged(2)
assertFalse("unchanged 10003 hasChanges", edits.HasChanges)
assertEquals("unchanged 10003 numberOfChanges", 0, edits.NumberOfChanges)
assertEquals("unchanged 10003", 0, edits.LengthDelta)
edits.AddReplace(2, 1)
edits.AddUnchanged(0)
edits.AddReplace(2, 1)
edits.AddReplace(2, 1)
edits.AddReplace(0, 10)
edits.AddReplace(100, 0)
edits.AddReplace(3000, 4000)
edits.AddReplace(100000, 100000)
assertTrue("some edits hasChanges", edits.HasChanges)
assertEquals("some edits numberOfChanges", 7, edits.NumberOfChanges)
assertEquals("some edits", -3 + 10 - 100 + 1000, edits.LengthDelta)
    var coarseExpectedChanges: EditChange[] = @[EditChange(false, 10003, 10003), EditChange(true, 103106, 104013)]
CheckEditsIter("coarse", edits.GetCoarseEnumerator, edits.GetCoarseEnumerator, coarseExpectedChanges, true)
CheckEditsIter("coarse changes", edits.GetCoarseChangesEnumerator, edits.GetCoarseChangesEnumerator, coarseExpectedChanges, false)
    var fineExpectedChanges: EditChange[] = @[EditChange(false, 10003, 10003), EditChange(true, 2, 1), EditChange(true, 2, 1), EditChange(true, 2, 1), EditChange(true, 0, 10), EditChange(true, 100, 0), EditChange(true, 3000, 4000), EditChange(true, 100000, 100000)]
CheckEditsIter("fine", edits.GetFineEnumerator, edits.GetFineEnumerator, fineExpectedChanges, true)
CheckEditsIter("fine changes", edits.GetFineChangesEnumerator, edits.GetFineChangesEnumerator, fineExpectedChanges, false)
edits.Reset
assertFalse("reset hasChanges", edits.HasChanges)
assertEquals("reset numberOfChanges", 0, edits.NumberOfChanges)
assertEquals("reset", 0, edits.LengthDelta)
    var ei: EditsEnumerator = edits.GetCoarseChangesEnumerator
assertFalse("reset then iterator", ei.MoveNext)
proc TestEditsFindFwdBwd*() =
    var e: Edits = Edits
    var N: int = 200000
      var i: int = 0
      while i < N:
e.AddUnchanged(1)
e.AddReplace(3, 1)
++i
    var iter: EditsEnumerator = e.GetFineEnumerator
      var i: int = 0
      while i <= N:
assertEquals("ascending", i * 2, iter.SourceIndexFromDestinationIndex(i))
assertEquals("ascending", i * 2 + 1, iter.SourceIndexFromDestinationIndex(i + 1))
          i = 2
      var i: int = N
      while i >= 0:
assertEquals("descending", i * 2 + 1, iter.SourceIndexFromDestinationIndex(i + 1))
assertEquals("descending", i * 2, iter.SourceIndexFromDestinationIndex(i))
          i = 2
proc TestMergeEdits*() =
      var ab: Edits = Edits
      var bc: Edits = Edits
      var ac: Edits = Edits
      var expected_ac: Edits = Edits
ab.AddUnchanged(2)
bc.AddUnchanged(2)
expected_ac.AddUnchanged(2)
ab.AddReplace(3, 2)
bc.AddReplace(2, 1)
expected_ac.AddReplace(3, 1)
ab.AddUnchanged(5)
bc.AddUnchanged(3)
expected_ac.AddUnchanged(3)
ab.AddReplace(4, 3)
bc.AddReplace(3, 2)
ab.AddReplace(4, 3)
bc.AddReplace(3, 2)
ab.AddReplace(4, 3)
bc.AddReplace(3, 2)
bc.AddUnchanged(4)
expected_ac.AddReplace(14, 8)
ab.AddUnchanged(2)
expected_ac.AddUnchanged(2)
ab.AddReplace(0, 5)
ab.AddReplace(0, 2)
bc.AddReplace(7, 0)
ab.AddReplace(1, 2)
bc.AddReplace(2, 3)
expected_ac.AddReplace(1, 3)
ab.AddReplace(1, 0)
ab.AddReplace(2, 0)
ab.AddReplace(3, 0)
expected_ac.AddReplace(1, 0)
expected_ac.AddReplace(2, 0)
expected_ac.AddReplace(3, 0)
ab.AddUnchanged(2)
bc.AddUnchanged(1)
expected_ac.AddUnchanged(1)
bc.AddReplace(0, 4)
bc.AddReplace(0, 5)
bc.AddReplace(0, 6)
expected_ac.AddReplace(0, 4)
expected_ac.AddReplace(0, 5)
expected_ac.AddReplace(0, 6)
bc.AddReplace(2, 2)
ab.AddReplace(1, 0)
ab.AddReplace(2, 0)
ab.AddReplace(3, 0)
ab.AddReplace(4, 1)
expected_ac.AddReplace(11, 2)
ab.AddReplace(5, 6)
bc.AddReplace(3, 3)
bc.AddReplace(0, 4)
bc.AddReplace(0, 5)
bc.AddReplace(0, 6)
bc.AddReplace(3, 7)
expected_ac.AddReplace(5, 25)
ab.AddReplace(4, 4)
ab.AddReplace(3, 0)
ab.AddUnchanged(2)
bc.AddReplace(2, 2)
bc.AddReplace(4, 0)
expected_ac.AddReplace(9, 2)
ab.AddReplace(0, 2)
bc.AddReplace(1, 1)
bc.AddReplace(0, 8)
bc.AddUnchanged(4)
expected_ac.AddReplace(0, 10)
ab.AddUnchanged(3)
expected_ac.AddUnchanged(3)
ab.AddReplace(2, 0)
ab.AddReplace(4, 0)
ab.AddReplace(6, 0)
bc.AddReplace(0, 1)
bc.AddReplace(0, 3)
bc.AddReplace(0, 5)
expected_ac.AddReplace(0, 1)
expected_ac.AddReplace(0, 3)
expected_ac.AddReplace(0, 5)
expected_ac.AddReplace(2, 0)
expected_ac.AddReplace(4, 0)
expected_ac.AddReplace(6, 0)
ab.AddUnchanged(1)
bc.AddUnchanged(1)
expected_ac.AddUnchanged(1)
ac.MergeAndAppend(ab, bc)
CheckEqualEdits("ab+bc", expected_ac, ac)
      var ab2: Edits = Edits
      var bc2: Edits = Edits
ab2.AddUnchanged(5)
bc2.AddReplace(1, 2)
bc2.AddUnchanged(4)
expected_ac.AddReplace(1, 2)
expected_ac.AddUnchanged(4)
ac.MergeAndAppend(ab2, bc2)
CheckEqualEdits("ab2+bc2", expected_ac, ac)
    var empty: Edits = Edits
ac.MergeAndAppend(empty, empty)
CheckEqualEdits("empty+empty", expected_ac, ac)
    var mismatch: Edits = Edits
mismatch.AddReplace(1, 1)
    try:
ac.MergeAndAppend(ab2, mismatch)
fail("ab2+mismatch did not yield ArgumentException")
    except ArgumentException:

    try:
ac.MergeAndAppend(mismatch, bc2)
fail("mismatch+bc2 did not yield ArgumentException")
    except ArgumentException:

proc TestCaseMapWithEdits*() =
    var sb: StringBuilder = StringBuilder
    var edits: Edits = Edits
    sb = CaseMap.ToLower.OmitUnchangedText.Apply(TURKISH_LOCALE_, "IstanBul".AsSpan, sb, edits)
assertEquals("toLower(Istanbul)", "ıb", sb.ToString)
    var lowerExpectedChanges: EditChange[] = @[EditChange(true, 1, 1), EditChange(false, 4, 4), EditChange(true, 1, 1), EditChange(false, 2, 2)]
CheckEditsIter("toLower(Istanbul)", edits.GetFineEnumerator, edits.GetFineEnumerator, lowerExpectedChanges, true)
sb.Delete(0, sb.Length - 0)
edits.Reset
    sb = CaseMap.ToUpper.OmitUnchangedText.Apply(GREEK_LOCALE_, "Πατάτα".AsSpan, sb, edits)
assertEquals("toUpper(Πατάτα)", "ΑΤΑΤΑ", sb.ToString)
    var upperExpectedChanges: EditChange[] = @[EditChange(false, 1, 1), EditChange(true, 1, 1), EditChange(true, 1, 1), EditChange(true, 1, 1), EditChange(true, 1, 1), EditChange(true, 1, 1)]
CheckEditsIter("toUpper(Πατάτα)", edits.GetFineEnumerator, edits.GetFineEnumerator, upperExpectedChanges, true)
sb.Delete(0, sb.Length - 0)
edits.Reset
    sb = CaseMap.ToTitle.OmitUnchangedText.NoBreakAdjustment.NoLowercase.Apply(DUTCH_LOCALE_, nil, "IjssEL IglOo".AsMemory, sb, edits)
assertEquals("toTitle(IjssEL IglOo)", "J", sb.ToString)
    var titleExpectedChanges: EditChange[] = @[EditChange(false, 1, 1), EditChange(true, 1, 1), EditChange(false, 10, 10)]
CheckEditsIter("toTitle(IjssEL IglOo)", edits.GetFineEnumerator, edits.GetFineEnumerator, titleExpectedChanges, true)
sb.Delete(0, sb.Length - 0)
edits.Reset
    sb = CaseMap.ToFold.OmitUnchangedText.Turkic.Apply("IßtanBul".AsSpan, sb, edits)
assertEquals("fold(IßtanBul)", "ıssb", sb.ToString)
    var foldExpectedChanges: EditChange[] = @[EditChange(true, 1, 1), EditChange(true, 1, 2), EditChange(false, 3, 3), EditChange(true, 1, 1), EditChange(false, 2, 2)]
CheckEditsIter("fold(IßtanBul)", edits.GetFineEnumerator, edits.GetFineEnumerator, foldExpectedChanges, true)
proc TestCaseMapToString*() =
assertEquals("toLower(Istanbul)", "ıb", CaseMap.ToLower.OmitUnchangedText.Apply(TURKISH_LOCALE_, "IstanBul".AsSpan))
assertEquals("toUpper(Πατάτα)", "ΑΤΑΤΑ", CaseMap.ToUpper.OmitUnchangedText.Apply(GREEK_LOCALE_, "Πατάτα".AsSpan))
assertEquals("toTitle(IjssEL IglOo)", "J", CaseMap.ToTitle.OmitUnchangedText.NoBreakAdjustment.NoLowercase.Apply(DUTCH_LOCALE_, nil, "IjssEL IglOo".AsMemory))
assertEquals("fold(IßtanBul)", "ıssb", CaseMap.ToFold.OmitUnchangedText.Turkic.Apply("IßtanBul".AsSpan))
assertEquals("toLower(Istanbul)", "ıstanbul", CaseMap.ToLower.Apply(TURKISH_LOCALE_, "IstanBul".AsSpan))
assertEquals("toUpper(Πατάτα)", "ΠΑΤΑΤΑ", CaseMap.ToUpper.Apply(GREEK_LOCALE_, "Πατάτα".AsSpan))
assertEquals("toTitle(IjssEL IglOo)", "IJssEL IglOo", CaseMap.ToTitle.NoBreakAdjustment.NoLowercase.Apply(DUTCH_LOCALE_, nil, "IjssEL IglOo".AsMemory))
assertEquals("fold(IßtanBul)", "ısstanbul", CaseMap.ToFold.Turkic.Apply("IßtanBul".AsSpan))
proc GetUnicodeStrings(str: String): String[] =
    var v: List<String> = List<String>(10)
    var start: int = 0
      var casecount: int = 4
      while casecount > 0:
          var end: int = str.IndexOf("; ", start, StringComparison.Ordinal)
          var casestr: String = str.Substring(start, end - start)
          var buffer: StringBuffer = StringBuffer
          var spaceoffset: int = 0
          while spaceoffset < casestr.Length:
              var nextspace: int = casestr.IndexOf(' ', spaceoffset)
              if nextspace == -1:
                  nextspace = casestr.Length
buffer.Append(cast[char](Convert.ToInt32(casestr.Substring(spaceoffset, nextspace - spaceoffset), 16)))
              spaceoffset = nextspace + 1
          start = end + 2
v.Add(buffer.ToString)
--casecount
    var comments: int = str.IndexOf(" #", start, StringComparison.Ordinal)
    if comments != -1 && comments != start:
        if str[comments - 1] == ';':
--comments
        var conditions: String = str.Substring(start, comments - start)
        var offset: int = 0
        while offset < conditions.Length:
            var spaceoffset: int = conditions.IndexOf(' ', offset)
            if spaceoffset == -1:
                spaceoffset = conditions.Length
v.Add(conditions.Substring(offset, spaceoffset - offset))
            offset = spaceoffset + 1
    var size: int = v.Count
    var result: String[] = seq[String]
      var i: int = 0
      while i < size:
          result[i] = v[i]
++i
    return result