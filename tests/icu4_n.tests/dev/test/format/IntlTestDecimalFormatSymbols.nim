# "Namespace: ICU4N.Dev.Test.Format"
type
  IntlTestDecimalFormatSymbols = ref object


proc TestSymbols*() =
    var fr: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("fr"))
    var en: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en"))
    if en.Equals(fr):
Errln("ERROR: English DecimalFormatSymbols equal to French")
    if !en.Culture.Equals(CultureInfo("en")):
Errln("ERROR: getLocale failed")
    if !en.UCulture.Equals(UCultureInfo("en")):
Errln("ERROR: getULocale failed")
    if !en.Culture.Equals(CultureInfo("en")):
Errln("ERROR: getLocale failed")
    if !en.UCulture.Equals(UCultureInfo("en")):
Errln("ERROR: getULocale failed")
    var zero: char = en.ZeroDigit
    fr.ZeroDigit = zero
    if fr.ZeroDigit != en.ZeroDigit:
Errln("ERROR: get/set ZeroDigit failed")
    var digits: String[] = en.DigitStrings
    fr.DigitStrings = digits
    if !ArrayEqualityComparer[string].OneDimensional.Equals(fr.DigitStrings, en.DigitStrings):
Errln("ERROR: get/set DigitStrings failed")
    var sigDigit: char = en.SignificantDigit
    fr.SignificantDigit = sigDigit
    if fr.SignificantDigit != en.SignificantDigit:
Errln("ERROR: get/set SignificantDigit failed")
    var currency: Currency = Currency.GetInstance("USD")
    fr.Currency = currency
    if !fr.Currency.Equals(currency):
Errln("ERROR: get/set Currency failed")
    var group: char = en.GroupingSeparator
    fr.GroupingSeparator = group
    if fr.GroupingSeparator != en.GroupingSeparator:
Errln("ERROR: get/set GroupingSeparator failed")
    var groupStr: String = en.GroupingSeparatorString
    fr.GroupingSeparatorString = groupStr
    if !fr.GroupingSeparatorString.Equals(en.GroupingSeparatorString, StringComparison.Ordinal):
Errln("ERROR: get/set GroupingSeparatorString failed")
    var @decimal: char = en.DecimalSeparator
    fr.DecimalSeparator = @decimal
    if fr.DecimalSeparator != en.DecimalSeparator:
Errln("ERROR: get/set DecimalSeparator failed")
    var decimalStr: String = en.DecimalSeparatorString
    fr.DecimalSeparatorString = decimalStr
    if !fr.DecimalSeparatorString.Equals(en.DecimalSeparatorString):
Errln("ERROR: get/set DecimalSeparatorString failed")
    var monetaryGroup: char = en.MonetaryGroupingSeparator
    fr.MonetaryGroupingSeparator = monetaryGroup
    if fr.MonetaryGroupingSeparator != en.MonetaryGroupingSeparator:
Errln("ERROR: get/set MonetaryGroupingSeparator failed")
    var monetaryGroupStr: String = en.MonetaryGroupingSeparatorString
    fr.MonetaryGroupingSeparatorString = monetaryGroupStr
    if !fr.MonetaryGroupingSeparatorString.Equals(en.MonetaryGroupingSeparatorString, StringComparison.Ordinal):
Errln("ERROR: get/set MonetaryGroupingSeparatorString failed")
    var monetaryDecimal: char = en.MonetaryDecimalSeparator
    fr.MonetaryDecimalSeparator = monetaryDecimal
    if fr.MonetaryDecimalSeparator != en.MonetaryDecimalSeparator:
Errln("ERROR: get/set MonetaryDecimalSeparator failed")
    var monetaryDecimalStr: String = en.MonetaryDecimalSeparatorString
    fr.MonetaryDecimalSeparatorString = monetaryDecimalStr
    if !fr.MonetaryDecimalSeparatorString.Equals(en.MonetaryDecimalSeparatorString, StringComparison.Ordinal):
Errln("ERROR: get/set MonetaryDecimalSeparatorString failed")
    var perMill: char = en.PerMill
    fr.PerMill = perMill
    if fr.PerMill != en.PerMill:
Errln("ERROR: get/set PerMill failed")
    var perMillStr: String = en.PerMillString
    fr.PerMillString = perMillStr
    if !fr.PerMillString.Equals(en.PerMillString):
Errln("ERROR: get/set PerMillString failed")
    var percent: char = en.Percent
    fr.Percent = percent
    if fr.Percent != en.Percent:
Errln("ERROR: get/set Percent failed")
    var percentStr: String = en.PercentString
    fr.PercentString = percentStr
    if !fr.PercentString.Equals(en.PercentString):
Errln("ERROR: get/set PercentString failed")
    var digit: char = en.Digit
    fr.Digit = digit
    if fr.Digit != en.Digit:
Errln("ERROR: get/set Digit failed")
    var patternSeparator: char = en.PatternSeparator
    fr.PatternSeparator = patternSeparator
    if fr.PatternSeparator != en.PatternSeparator:
Errln("ERROR: get/set PatternSeparator failed")
    var infinity: String = en.Infinity
    fr.Infinity = infinity
    var infinity2: String = fr.Infinity
    if !infinity.Equals(infinity2, StringComparison.Ordinal):
Errln("ERROR: get/set Infinity failed")
    var nan: String = en.NaN
    fr.NaN = nan
    var nan2: String = fr.NaN
    if !nan.Equals(nan2, StringComparison.Ordinal):
Errln("ERROR: get/set NaN failed")
    var minusSign: char = en.MinusSign
    fr.MinusSign = minusSign
    if fr.MinusSign != en.MinusSign:
Errln("ERROR: get/set MinusSign failed")
    var minusSignStr: String = en.MinusSignString
    fr.MinusSignString = minusSignStr
    if !fr.MinusSignString.Equals(en.MinusSignString, StringComparison.Ordinal):
Errln("ERROR: get/set MinusSignString failed")
    var plusSign: char = en.PlusSign
    fr.PlusSign = plusSign
    if fr.PlusSign != en.PlusSign:
Errln("ERROR: get/set PlusSign failed")
    var plusSignStr: String = en.PlusSignString
    fr.PlusSignString = plusSignStr
    if !fr.PlusSignString.Equals(en.PlusSignString, StringComparison.Ordinal):
Errln("ERROR: get/set PlusSignString failed")
    var padEscape: char = en.PadEscape
    fr.PadEscape = padEscape
    if fr.PadEscape != en.PadEscape:
Errln("ERROR: get/set PadEscape failed")
    var exponential: String = en.ExponentSeparator
    fr.ExponentSeparator = exponential
    if fr.ExponentSeparator != en.ExponentSeparator:
Errln("ERROR: get/set Exponential failed")
    var exponentMultiplicationSign: String = en.ExponentMultiplicationSign
    fr.ExponentMultiplicationSign = exponentMultiplicationSign
    if fr.ExponentMultiplicationSign != en.ExponentMultiplicationSign:
Errln("ERROR: get/set ExponentMultiplicationSign failed")
      var i: int = cast[int](CurrencySpacingPattern.CurrencyMatch)
      while i <= cast[int](CurrencySpacingPattern.InsertBetween):
          if en.GetPatternForCurrencySpacing(cast[CurrencySpacingPattern](i), true) != fr.GetPatternForCurrencySpacing(cast[CurrencySpacingPattern](i), true):
Errln("ERROR: get currency spacing item:" + i + " before the currency")
              if en.GetPatternForCurrencySpacing(cast[CurrencySpacingPattern](i), false) != fr.GetPatternForCurrencySpacing(cast[CurrencySpacingPattern](i), false):
Errln("ERROR: get currency spacing item:" + i + " after currency")
++i
    var dash: String = "-"
en.SetPatternForCurrencySpacing(CurrencySpacingPattern.InsertBetween, true, dash)
    if dash != en.GetPatternForCurrencySpacing(CurrencySpacingPattern.InsertBetween, true):
Errln("ERROR: set currency spacing pattern for before currency.")
    en = cast[DecimalFormatSymbols](fr.Clone)
    if !en.Equals(fr):
Errln("ERROR: Clone failed")
proc TestCoverage*() =
    var df: DecimalFormatSymbols = DecimalFormatSymbols
    var df2: DecimalFormatSymbols = cast[DecimalFormatSymbols](df.Clone)
    if !df.Equals(df2) || df.GetHashCode != df2.GetHashCode:
Errln("decimal format symbols clone, equals, or hashCode failed")
proc TestPropagateZeroDigit*() =
    var dfs: DecimalFormatSymbols = DecimalFormatSymbols
    dfs.ZeroDigit = '�'
    var df: DecimalFormat = DecimalFormat("0")
df.SetDecimalFormatSymbols(dfs)
assertEquals("Should propagate char with number property zero", '�', dfs.Digits[1])
assertEquals("Should propagate char with number property zero", "၄၀၁၂၃", df.Format(40123))
    dfs.ZeroDigit = 'a'
df.SetDecimalFormatSymbols(dfs)
assertEquals("Should propagate char WITHOUT number property zero", 'b', dfs.Digits[1])
assertEquals("Should propagate char WITHOUT number property zero", "eabcd", df.Format(40123))
proc TestDigitSymbols*() =
    var defZero: char = '0'
    var defDigits: char[] = @['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
    var defDigitStrings: string[] = @["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    var osmanyaDigitStrings: string[] = @["𐒠", "𐒡", "𐒢", "𐒣", "𐒤", "𐒥", "𐒦", "𐒧", "𐒨", "𐒩"]
    var differentDigitStrings: String[] = @["0", "b", "3", "d", "5", "ff", "7", "h", "9", "j"]
    var symbols: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en"))
    symbols.DigitStrings = osmanyaDigitStrings
    if !ArrayEqualityComparer[string].OneDimensional.Equals(symbols.DigitStrings, osmanyaDigitStrings):
Errln("ERROR: Osmanya digits (supplementary) should be set")
    if Character.CodePointAt(osmanyaDigitStrings[0], 0) != symbols.CodePointZero:
Errln("ERROR: Code point zero be Osmanya code point zero")
    if defZero != symbols.ZeroDigit:
Errln("ERROR: Zero digit should be 0")
    if !ArrayEqualityComparer[char].OneDimensional.Equals(symbols.Digits, defDigits):
Errln("ERROR: Char digits should be Latin digits")
    symbols.DigitStrings = differentDigitStrings
    if !ArrayEqualityComparer[string].OneDimensional.Equals(symbols.DigitStrings, differentDigitStrings):
Errln("ERROR: Different digits should be set")
    if -1 != symbols.CodePointZero:
Errln("ERROR: Code point zero should be invalid")
    symbols.ZeroDigit = defZero
    if !ArrayEqualityComparer[string].OneDimensional.Equals(symbols.DigitStrings, defDigitStrings):
Errln("ERROR: Latin digits should be set" + symbols.DigitStrings[0])
    if defZero != symbols.CodePointZero:
Errln("ERROR: Code point zero be ASCII 0")
proc TestNumberingSystem*() =
    var cases: object[][] = @[@["en", "latn", "1,234.56", ';'], @["en", "arab", "١٬٢٣٤٫٥٦", '�'], @["en", "mathsanb", "𝟭,𝟮𝟯𝟰.𝟱𝟲", ';'], @["en", "mymr", "၁,၂၃၄.၅၆", ';'], @["my", "latn", "1,234.56", ';'], @["my", "arab", "١٬٢٣٤٫٥٦", '�'], @["my", "mathsanb", "𝟭,𝟮𝟯𝟰.𝟱𝟲", ';'], @["my", "mymr", "၁,၂၃၄.၅၆", '�'], @["en@numbers=thai", "mymr", "၁,၂၃၄.၅၆", ';']]
    for cas in cases:
        var loc: UCultureInfo = UCultureInfo(cast[string](cas[0]))
        var ns: NumberingSystem = NumberingSystem.GetInstanceByName(cast[string](cas[1]))
        var expectedFormattedNumberString: String = cast[string](cas[2])
        var expectedPatternSeparator: char = cast[char](cas[3])
        var dfs: DecimalFormatSymbols = DecimalFormatSymbols.ForNumberingSystem(loc, ns)
        var actual2: char = dfs.PatternSeparator
assertEquals("Pattern separator with " + loc + " and " + ns.Name, expectedPatternSeparator, actual2)
        var dfs2: DecimalFormatSymbols = DecimalFormatSymbols.ForNumberingSystem(loc.ToCultureInfo, ns)
assertEquals("JDK Locale and ICU Locale should produce the same object", dfs, dfs2)