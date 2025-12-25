# "Namespace: ICU4N.Globalization"
type
  UNumberFormatInfoTest = ref object


proc TestAllCultures*() =
    for culture in UCultureInfo.GetCultures(UCultureTypes.AllCultures):
        var expected: DecimalFormatSymbols = DecimalFormatSymbols(culture)
        var actual: IDecimalFormatSymbols = culture.NumberFormat
        try:
assertDecimalFormatSymbolsEqual(expected, actual)
        except Exception:
fail(culture.ToString + Environment.NewLine + ex.ToString)
proc Test_en_FI*() =
    var culture = UCultureInfo("en_FI")
    var expected: DecimalFormatSymbols = DecimalFormatSymbols(culture)
    var actual: IDecimalFormatSymbols = culture.NumberFormat
assertDecimalFormatSymbolsEqual(expected, actual)
proc TestArabic*() =
    var culture = UCultureInfo("ar")
    var expected: DecimalFormatSymbols = DecimalFormatSymbols(culture)
    var actual: IDecimalFormatSymbols = culture.NumberFormat
assertDecimalFormatSymbolsEqual(expected, actual)
proc TestInvariantCulture*() =
    var expected: DecimalFormatSymbols = DecimalFormatSymbols(UCultureInfo.InvariantCulture)
    var actual: IDecimalFormatSymbols = UNumberFormatInfo
assertDecimalFormatSymbolsEqual(expected, actual)
proc assertDecimalFormatSymbolsEqual(expected: DecimalFormatSymbols, actual: IDecimalFormatSymbols) =
assertEquals("invalid CodePointZero", expected.CodePointZero, actual.CodePointZero)
assertEquals("invalid DecimalSeparator", expected.DecimalSeparator, actual.DecimalSeparator)
assertEquals("invalid DecimalSeparatorString", expected.DecimalSeparatorString, actual.DecimalSeparatorString)
assertEquals("invalid Digit", expected.Digit, actual.Digit)
assertEquals("invalid Digits", expected.Digits, actual.Digits)
assertEquals("invalid DigitStrings", expected.DigitStrings, actual.DigitStrings)
assertEquals("invalid DigitStringsLocal", expected.DigitStringsLocal, actual.DigitStringsLocal)
assertEquals("invalid ExponentMultiplicationSign", expected.ExponentMultiplicationSign, actual.ExponentMultiplicationSign)
assertEquals("invalid ExponentSeparator", expected.ExponentSeparator, actual.ExponentSeparator)
assertEquals("invalid GroupingSeparator", expected.GroupingSeparator, actual.GroupingSeparator)
assertEquals("invalid GroupingSeparatorString", expected.GroupingSeparatorString, actual.GroupingSeparatorString)
assertEquals("invalid Infinity", expected.Infinity, actual.Infinity)
assertEquals("invalid MinusSign", expected.MinusSign, actual.MinusSign)
assertEquals("invalid MinusSignString", expected.MinusSignString, actual.MinusSignString)
assertEquals("invalid NaN", expected.NaN, actual.NaN)
assertEquals("invalid PadEscape", expected.PadEscape, actual.PadEscape)
assertEquals("invalid PatternSeparator", expected.PatternSeparator, actual.PatternSeparator)
assertEquals("invalid Percent", expected.Percent, actual.Percent)
assertEquals("invalid PercentString", expected.PercentString, actual.PercentString)
assertEquals("invalid PerMill", expected.PerMill, actual.PerMill)
assertEquals("invalid PerMillString", expected.PerMillString, actual.PerMillString)
assertEquals("invalid PlusSign", expected.PlusSign, actual.PlusSign)
assertEquals("invalid PlusSignString", expected.PlusSignString, actual.PlusSignString)
assertEquals("invalid SignificantDigit", expected.SignificantDigit, actual.SignificantDigit)
assertEquals("invalid ZeroDigit", expected.ZeroDigit, actual.ZeroDigit)
proc assertCurrencySpacingPatternsEqual(expected: DecimalFormatSymbols, actual: IDecimalFormatSymbols) =
assertEquals("invalid CurrencyMatch prefix", expected.GetPatternForCurrencySpacing(CurrencySpacingPattern.CurrencyMatch, true), actual.GetPatternForCurrencySpacing(CurrencySpacingPattern.CurrencyMatch, true))
assertEquals("invalid CurrencyMatch suffix", expected.GetPatternForCurrencySpacing(CurrencySpacingPattern.CurrencyMatch, false), actual.GetPatternForCurrencySpacing(CurrencySpacingPattern.CurrencyMatch, false))
assertEquals("invalid SurroundingMatch prefix", expected.GetPatternForCurrencySpacing(CurrencySpacingPattern.SurroundingMatch, true), actual.GetPatternForCurrencySpacing(CurrencySpacingPattern.SurroundingMatch, true))
assertEquals("invalid SurroundingMatch suffix", expected.GetPatternForCurrencySpacing(CurrencySpacingPattern.SurroundingMatch, false), actual.GetPatternForCurrencySpacing(CurrencySpacingPattern.SurroundingMatch, false))
assertEquals("invalid InsertBetween prefix", expected.GetPatternForCurrencySpacing(CurrencySpacingPattern.InsertBetween, true), actual.GetPatternForCurrencySpacing(CurrencySpacingPattern.InsertBetween, true))
assertEquals("invalid InsertBetween suffix", expected.GetPatternForCurrencySpacing(CurrencySpacingPattern.InsertBetween, false), actual.GetPatternForCurrencySpacing(CurrencySpacingPattern.InsertBetween, false))