# "Namespace: ICU4N.Dev.Test.Format"
type
  IntlTestDecimalFormatSymbolsC = ref object


proc TestSymbols*() =
    var fr: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("fr"))
    var en: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en"))
    if en.Equals(fr):
Errln("ERROR: English DecimalFormatSymbols equal to French")
    var zero: char = en.ZeroDigit
    fr.ZeroDigit = zero
    if fr.ZeroDigit != en.ZeroDigit:
Errln("ERROR: get/set ZeroDigit failed")
    var group: char = en.GroupingSeparator
    fr.GroupingSeparator = group
    if fr.GroupingSeparator != en.GroupingSeparator:
Errln("ERROR: get/set GroupingSeparator failed")
    var @decimal: char = en.DecimalSeparator
    fr.DecimalSeparator = @decimal
    if fr.DecimalSeparator != en.DecimalSeparator:
Errln("ERROR: get/set DecimalSeparator failed")
    var perMill: char = en.PerMill
    fr.PerMill = perMill
    if fr.PerMill != en.PerMill:
Errln("ERROR: get/set PerMill failed")
    var percent: char = en.Percent
    fr.Percent = percent
    if fr.Percent != en.Percent:
Errln("ERROR: get/set Percent failed")
    var digit: char = en.Digit
    fr.Digit = digit
    if fr.Percent != en.Percent:
Errln("ERROR: get/set Percent failed")
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
    en = cast[DecimalFormatSymbols](fr.Clone)
    if !en.Equals(fr):
Errln("ERROR: Clone failed")
    var sym: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-US"))
verify(34.5, "00.00", sym, "34.50")
    sym.DecimalSeparator = 'S'
verify(34.5, "00.00", sym, "34S50")
    sym.Percent = 'P'
verify(34.5, "00 %", sym, "3450 P")
    sym.CurrencySymbol = "D"
verify(34.5, "¤##.##", sym, "D 34.50")
    sym.GroupingSeparator = '|'
verify(3456.5, "0,000.##", sym, "3|456S5")
proc verify(value: double, pattern: string, sym: DecimalFormatSymbols, expected: string) =
