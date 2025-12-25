# "Namespace: ICU4N.Dev.Test.Format"
type
  NumberFormatRegressionTest = ref object


proc Test4161100*() =
    var nf: NumberFormat = NumberFormat.GetInstance(CultureInfo("en-US"))
    nf.MinimumFractionDigits = 1
    nf.MaximumFractionDigits = 1
    var a: double = -0.09
    var s: String = nf.Format(a)
Logln(a + " x " + cast[DecimalFormat](nf).ToPattern + " = " + s)
    if !s.Equals("-0.1", StringComparison.Ordinal):
Errln("FAIL")
proc Test4408066*() =
    var nf1: NumberFormat = NumberFormat.GetIntegerInstance
    var nf2: NumberFormat = NumberFormat.GetIntegerInstance(CultureInfo("zh-CN"))
    if !nf1.ParseIntegerOnly || !nf2.ParseIntegerOnly:
Errln("Failed : Integer Number Format Instance should set setParseIntegerOnly(true)")
      var data: double[] = @[-3.75, -2.5, -1.5, -1.25, 0, 1.0, 1.25, 1.5, 2.5, 3.75, 10.0, 255.5]
      var expected: String[] = @["-4", "-2", "-2", "-1", "0", "1", "1", "2", "2", "4", "10", "256"]
        var i: int = 0
        while i < data.Length:
            var result: String = nf1.Format(data[i])
            if !result.Equals(expected[i], StringComparison.Ordinal):
Errln("Failed => Source: " + data[i].ToString(CultureInfo.InvariantCulture) + ";Formatted : " + result + ";but expectted: " + expected[i])
++i
      var data: String[] = @["-3.75", "-2.5", "-1.5", "-1.25", "0", "1.0", "1.25", "1.5", "2.5", "3.75", "10.0", "255.5"]
      var expected: long[] = @[-3, -2, -1, -1, 0, 1, 1, 1, 2, 3, 10, 255]
        var i: int = 0
        while i < data.Length:
            var n: Number = nil
            try:
                n = nf1.Parse(data[i])
            except FormatException:
Errln("Failed: " + e.Message)
            if !n is Long || n is Integer:
Errln("Failed: Integer Number Format should parse string to Long/Integer")
            if n.ToInt64 != expected[i]:
Errln("Failed=> Source: " + data[i] + ";result : " + n.ToString(CultureInfo.InvariantCulture) + ";expected :" + expected[i].ToString(CultureInfo.InvariantCulture))
++i
proc TestJB5509*() =
    var data: String[] = @["1,2", "1.2", "1,2.5", "1,23.5", "1,234.5", "1,234", "1,234,567", "1,234,567.8", "1,234,5", "1,234,5.6", "1,234,56.7"]
    var expected: bool[] = @[false, true, false, false, true, true, true, true, false, false, false, false]
    var df: DecimalFormat = DecimalFormat("#,##0.###", DecimalFormatSymbols(UCultureInfo("en_US")))
    df.ParseStrict = true
      var i: int = 0
      while i < data.Length:
          try:
df.Parse(data[i])
              if !expected[i]:
Errln("Failed: ParseException must be thrown for string " + data[i])
          except FormatException:
              if expected[i]:
Errln("Failed: ParseException must not be thrown for string " + data[i])
++i
proc TestT5698*() =
    var data: String[] = @["12345679E66666666666666666", "-12345679E66666666666666666", ".1E2147483648", ".1E2147483647", ".1E-2147483648", ".1E-2147483649", "1.23E350", "1.23E300", "-1.23E350", "-1.23E300", "4.9E-324", "1.0E-325", "-1.0E-325"]
    var expected: double[] = @[double.PositiveInfinity, double.NegativeInfinity, double.PositiveInfinity, double.PositiveInfinity, 0.0, 0.0, double.PositiveInfinity, 1.23e+300, double.NegativeInfinity, -1.23e+300, 5e-324, 0.0, -0.0]
    var nfmt: NumberFormat = NumberFormat.GetInstance
      var i: int = 0
      while i < data.Length:
          try:
              var n: Number = nfmt.Parse(data[i])
              if expected[i] != n.ToDouble:
Errln("Failed: Parsed result for " + data[i] + ": " + n.ToDouble + " / expected: " + expected[i])
          except FormatException:
Errln("Failed: ParseException is thrown for " + data[i])
++i
proc TestSurrogatesParsing*() =
    var data: String[] = @["1𐒢,3𐒤5.67", "𐒡𐒢,𐒣𐒤𐒥.𐒦𐒧𐒨", "𝟒.𝟗E-𝟑", "𝟓.8E-0𝟐"]
    var expected: double[] = @[12345.67, 12345.678, 0.0049, 0.058]
    var nfmt: NumberFormat = NumberFormat.GetInstance
      var i: int = 0
      while i < data.Length:
          try:
              var n: Number = nfmt.Parse(data[i])
              if expected[i] != n.ToDouble:
Errln("Failed: Parsed result for " + data[i] + ": " + n.ToDouble + " / expected: " + expected[i])
          except FormatException:
Errln("Failed: ParseException is thrown for " + data[i])
++i
proc checkNBSPPatternRtNum(testcase: String, nf: NumberFormat, myNumber: double) =
    var myString: String = nf.Format(myNumber)
    var aNumber: double
    try:
        aNumber = nf.Parse(myString).ToDouble
    except FormatException:
Errln("FAIL: " + testcase + " - failed to parse. " + e.ToString)
        return
    if Math.Abs(aNumber - myNumber) > 0.001:
Errln("FAIL: " + testcase + ": formatted " + myNumber + ", parsed into " + aNumber + "
")
    else:
Logln("PASS: " + testcase + ": formatted " + myNumber + ", parsed into " + aNumber + "
")
proc checkNBSPPatternRT(testcase: String, nf: NumberFormat) =
checkNBSPPatternRtNum(testcase, nf, 12345.0)
checkNBSPPatternRtNum(testcase, nf, -12345.0)
proc TestNBSPInPattern*() =
    var nf: NumberFormat = nil
    var testcase: String
    testcase = "ar_AE UNUM_CURRENCY"
    nf = NumberFormat.GetCurrencyInstance(UCultureInfo("ar_AE"))
checkNBSPPatternRT(testcase, nf)
    var SPECIAL_PATTERN: String = "¤¤'د.إ.‏ '###0.00"
    testcase = "ar_AE special pattern: " + SPECIAL_PATTERN
    nf = DecimalFormat
cast[DecimalFormat](nf).ApplyPattern(SPECIAL_PATTERN)
checkNBSPPatternRT(testcase, nf)
proc TestT9293*() =
    var fmt: NumberFormat = NumberFormat.GetCurrencyInstance
    fmt.ParseStrict = true
    var val: int = 123456
    var txt: String = fmt.Format(123456)
    var pos: ParsePosition = ParsePosition(0)
    var num: Number = fmt.Parse(txt, pos)
    if pos.ErrorIndex >= 0:
Errln("FAIL: Parsing " + txt + " - error index: " + pos.ErrorIndex)

    elif val != num.ToInt32:
Errln("FAIL: Parsed result: " + num + " - expected: " + val)
proc TestAffixesNoCurrency*() =
    var locale: UCultureInfo = UCultureInfo("en")
    var nf: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(locale, NumberFormatStyle.PluralCurrencyStyle))
assertEquals("Positive suffix should contain the single currency sign when no currency is set", " ¤", nf.PositiveSuffix)