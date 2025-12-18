# "Namespace: ICU4N"
type
  IcuNumberFormattingTest = ref object
    CharStackBufferSize: int = 64

proc TestTryFormatInt64_AgainstRbnfDecimalFormat_SpellOut(): void =
  block:
    var number: long = 123456789012345678
    var destination: Span<char> = newSeq[char](CharStackBufferSize)
    for var locale: UCultureInfo in NumberFormat.GetUCultures(UCultureTypes.AllCultures):
      block:
        AssertTryFormatFor(number, locale, NumberPresentation.SpellOut, destination)
proc TestTryFormatInt64_AgainstRbnfDecimalFormat_SpellOut_ar_EH(): void =
  block:
    var number: long = 123456789012345678
    var destination: Span<char> = newSeq[char](CharStackBufferSize)
    AssertTryFormatFor(number, UCultureInfo("ar_EH"), NumberPresentation.SpellOut, destination)
proc AssertTryFormatFor(): void =
  block:
    var culture: var = locale.ToCultureInfo
    var rbnf: var = RuleBasedNumberFormat(locale, presentation)
    var decimalFormat: var = rbnf.DecimalFormat
    var expected: string = decimalFormat.Format(number)
    assertTrue(& "TryFormatInt64 returned false for " $locale, IcuNumber.TryFormatInt64(number, locale.NumberFormat.NumberPattern.AsSpan, locale.NumberFormat, destination, var charsWritten: int))
    var actual: string = destination.Slice(0, charsWritten).ToString
    assertEquals(& "bad format for " $locale, expected, actual)
proc Test_PluralFormatUnitTest_Data(): IEnumerable<TestCaseData> =
  block:
    var culture: string
    var decimalPattern: string
    var pluralPattern: string
    var pluralType: PluralType
    var expecteds: string[] = @["There are no widgets.", "There is one widget.", "There is a bling widget and one other widget.", "There is a bling widget and 2 other widgets.", "There is a bling widget and 3 other widgets.", "Widgets, five (5-1=4) there be.", "There is a bling widget and 5 other widgets.", "There is a bling widget and 6 other widgets."]
    culture = "en"
    pluralPattern = + + + + + "offset:1.0 " "=0 {There are no widgets.} " "=1.0 {There is one widget.} " "=5 {Widgets, five (5-1=#) there be.} " "one {There is a bling widget and one other widget.} " "other {There is a bling widget and # other widgets.}"
    pluralType = PluralType.Cardinal
    decimalPattern = nil
    block:
      var i: int = 0
      while <= i 7:
        block:
          yield TestCaseData(culture, i, pluralPattern, pluralType, decimalPattern, expecteds[i], + + "PluralFormat.format(value " i ")")
++i
    culture = "en"
    pluralPattern = "one{#st file}two{#nd file}few{#rd file}other{#th file}"
    pluralType = PluralType.Ordinal
    decimalPattern = nil
    yield TestCaseData(culture, 321, pluralPattern, pluralType, decimalPattern, "321st file", "PluralFormat.format(321)")
    yield TestCaseData(culture, 22, pluralPattern, pluralType, decimalPattern, "22nd file", "PluralFormat.format(22)")
    yield TestCaseData(culture, 3, pluralPattern, pluralType, decimalPattern, "3rd file", "PluralFormat.format(3)")
    yield TestCaseData(culture, 456, pluralPattern, pluralType, decimalPattern, "456th file", "PluralFormat.format(456)")
    yield TestCaseData(culture, 111, pluralPattern, pluralType, decimalPattern, "111th file", "PluralFormat.format(111)")
    culture = "en"
    pluralPattern = "one{one meter}other{# meters}"
    pluralType = PluralType.Cardinal
    decimalPattern = nil
    yield TestCaseData(culture, 1, pluralPattern, pluralType, decimalPattern, "one meter", "simple format(1)")
    yield TestCaseData(culture, 1.5, pluralPattern, pluralType, decimalPattern, "1.5 meters", "simple format(1.5)")
    culture = "en"
    pluralPattern = "offset:1 one{another meter}other{another # meters}"
    pluralType = PluralType.Cardinal
    decimalPattern = "0.0"
    yield TestCaseData(culture, 1, pluralPattern, pluralType, decimalPattern, "another 0.0 meters", "offset-decimals format(1)")
    yield TestCaseData(culture, 2, pluralPattern, pluralType, decimalPattern, "another 1.0 meters", "offset-decimals format(2)")
    yield TestCaseData(culture, 2.5, pluralPattern, pluralType, decimalPattern, "another 1.5 meters", "offset-decimals format(2.5)")
    culture = "en"
    pluralPattern = "one{# foot}other{# feet}"
    pluralType = PluralType.Cardinal
    decimalPattern = nil
    yield TestCaseData(culture, -3, pluralPattern, pluralType, decimalPattern, "-3 feet", "locale=en, pattern=one{# foot}other{# feet}")
proc Test_PluralFormatUnitTest(): void =
  block:
    var locale: var = UCultureInfo(culture)
    var messagePattern: MessagePattern = MessagePattern
    messagePattern.ParsePluralStyle(pluralPattern)
    var actual: string = IcuNumber.FormatPlural(number, decimalPattern, messagePattern, pluralType, locale.NumberFormat)
    assertEquals(assertMessage, expected, actual)