# "Namespace: ICU4N.Dev.Test.Format"
type
  NumberFormatTest = ref object
    KEYWORDS: seq[string] = @["ref=", "loc=", "f:", "fp:", "rt:", "p:", "perr:", "pat:", "fpc:", "strict="]
    roundingModeNames: seq[string] = @["ROUND_UP", "ROUND_DOWN", "ROUND_CEILING", "ROUND_FLOOR", "ROUND_HALF_UP", "ROUND_HALF_DOWN", "ROUND_HALF_EVEN", "ROUND_UNNECESSARY"]

proc TestRoundingScientific10542*() =
    var format: DecimalFormat = DecimalFormat("0.00E0")
    var roundingModes: int[] = @[cast[int](BigDecimal.RoundCeiling), cast[int](BigDecimal.RoundDown), cast[int](BigDecimal.RoundFloor), cast[int](BigDecimal.RoundHalfDown), cast[int](BigDecimal.RoundHalfEven), cast[int](BigDecimal.RoundHalfUp), cast[int](BigDecimal.RoundUp)]
    var descriptions: string[] = @["Round Ceiling", "Round Down", "Round Floor", "Round half down", "Round half even", "Round half up", "Round up"]
    var values: double[] = @[-0.003006, -0.003005, -0.003004, 0.003014, 0.003015, 0.003016]
    var expected: string[][] = @[@["-3.00E-3", "-3.00E-3", "-3.00E-3", "3.02E-3", "3.02E-3", "3.02E-3"], @["-3.00E-3", "-3.00E-3", "-3.00E-3", "3.01E-3", "3.01E-3", "3.01E-3"], @["-3.01E-3", "-3.01E-3", "-3.01E-3", "3.01E-3", "3.01E-3", "3.01E-3"], @["-3.01E-3", "-3.00E-3", "-3.00E-3", "3.01E-3", "3.01E-3", "3.02E-3"], @["-3.01E-3", "-3.00E-3", "-3.00E-3", "3.01E-3", "3.02E-3", "3.02E-3"], @["-3.01E-3", "-3.01E-3", "-3.00E-3", "3.01E-3", "3.02E-3", "3.02E-3"], @["-3.01E-3", "-3.01E-3", "-3.01E-3", "3.02E-3", "3.02E-3", "3.02E-3"]]
verifyRounding(format, values, expected, roundingModes, descriptions)
    values = @[-3006.0, -3005, -3004, 3014, 3015, 3016]
    expected = @[@["-3.00E3", "-3.00E3", "-3.00E3", "3.02E3", "3.02E3", "3.02E3"], @["-3.00E3", "-3.00E3", "-3.00E3", "3.01E3", "3.01E3", "3.01E3"], @["-3.01E3", "-3.01E3", "-3.01E3", "3.01E3", "3.01E3", "3.01E3"], @["-3.01E3", "-3.00E3", "-3.00E3", "3.01E3", "3.01E3", "3.02E3"], @["-3.01E3", "-3.00E3", "-3.00E3", "3.01E3", "3.02E3", "3.02E3"], @["-3.01E3", "-3.01E3", "-3.00E3", "3.01E3", "3.02E3", "3.02E3"], @["-3.01E3", "-3.01E3", "-3.01E3", "3.02E3", "3.02E3", "3.02E3"]]
verifyRounding(format, values, expected, roundingModes, descriptions)
    values = @[0.0, -0.0]
    expected = @[@["0.00E0", "-0.00E0"], @["0.00E0", "-0.00E0"], @["0.00E0", "-0.00E0"], @["0.00E0", "-0.00E0"], @["0.00E0", "-0.00E0"], @["0.00E0", "-0.00E0"], @["0.00E0", "-0.00E0"]]
verifyRounding(format, values, expected, roundingModes, descriptions)
    values = @[1e+25, 1e+25 + 1000000000000000.0, 1e+25 - 1000000000000000.0]
    expected = @[@["1.00E25", "1.01E25", "1.00E25"], @["1.00E25", "1.00E25", "9.99E24"], @["1.00E25", "1.00E25", "9.99E24"], @["1.00E25", "1.00E25", "1.00E25"], @["1.00E25", "1.00E25", "1.00E25"], @["1.00E25", "1.00E25", "1.00E25"], @["1.00E25", "1.01E25", "1.00E25"]]
verifyRounding(format, values, expected, roundingModes, descriptions)
    values = @[-1e+25, -1e+25 + 1000000000000000.0, -1e+25 - 1000000000000000.0]
    expected = @[@["-1.00E25", "-9.99E24", "-1.00E25"], @["-1.00E25", "-9.99E24", "-1.00E25"], @["-1.00E25", "-1.00E25", "-1.01E25"], @["-1.00E25", "-1.00E25", "-1.00E25"], @["-1.00E25", "-1.00E25", "-1.00E25"], @["-1.00E25", "-1.00E25", "-1.00E25"], @["-1.00E25", "-1.00E25", "-1.01E25"]]
verifyRounding(format, values, expected, roundingModes, descriptions)
    values = @[1e-25, 1e-25 + 1e-35, 1e-25 - 1e-35]
    expected = @[@["1.00E-25", "1.01E-25", "1.00E-25"], @["1.00E-25", "1.00E-25", "9.99E-26"], @["1.00E-25", "1.00E-25", "9.99E-26"], @["1.00E-25", "1.00E-25", "1.00E-25"], @["1.00E-25", "1.00E-25", "1.00E-25"], @["1.00E-25", "1.00E-25", "1.00E-25"], @["1.00E-25", "1.01E-25", "1.00E-25"]]
verifyRounding(format, values, expected, roundingModes, descriptions)
    values = @[-1e-25, -1e-25 + 1e-35, -1e-25 - 1e-35]
    expected = @[@["-1.00E-25", "-9.99E-26", "-1.00E-25"], @["-1.00E-25", "-9.99E-26", "-1.00E-25"], @["-1.00E-25", "-1.00E-25", "-1.01E-25"], @["-1.00E-25", "-1.00E-25", "-1.00E-25"], @["-1.00E-25", "-1.00E-25", "-1.00E-25"], @["-1.00E-25", "-1.00E-25", "-1.00E-25"], @["-1.00E-25", "-1.00E-25", "-1.01E-25"]]
verifyRounding(format, values, expected, roundingModes, descriptions)
proc verifyRounding(format: DecimalFormat, values: seq[double], expected: seq[string], roundingModes: seq[int], descriptions: seq[string]) =
      var i: int = 0
      while i < roundingModes.Length:
          format.RoundingMode = cast[Numerics.BigMath.RoundingMode](roundingModes[i])
            var j: int = 0
            while j < values.Length:
assertEquals(descriptions[i] + " " + values[j], expected[i][j], format.Format(values[j]))
++j
++i
proc Test10419RoundingWith0FractionDigits*() =
    var data: object[][] = @[@[BigDecimal.RoundCeiling, 1.488, "2"], @[BigDecimal.RoundDown, 1.588, "1"], @[BigDecimal.RoundFloor, 1.588, "1"], @[BigDecimal.RoundHalfDown, 1.5, "1"], @[BigDecimal.RoundHalfEven, 2.5, "2"], @[BigDecimal.RoundHalfUp, 2.5, "3"], @[BigDecimal.RoundUp, 1.5, "2"]]
    var nff: NumberFormat = NumberFormat.GetNumberInstance(UCultureInfo("en"))
    nff.MaximumFractionDigits = 0
    for item in data:
        nff.RoundingMode = cast[Numerics.BigMath.RoundingMode](item[0])
assertEquals("Test10419", item[2], nff.Format(item[1]))
proc TestParseNegativeWithFaLocale*() =
    var parser: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(UCultureInfo("fa")))
    try:
        var value: double = parser.Parse("-0,5").ToDouble
assertEquals("Expect -0.5", -0.5, value)
    except FormatException:
TestFmwk.Errln("Parsing -0.5 should have succeeded.")
proc TestParseNegativeWithAlternativeMinusSign*() =
    var parser: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(UCultureInfo("en")))
    try:
        var value: double = parser.Parse("₋0.5").ToDouble
assertEquals("Expect -0.5", -0.5, value)
    except FormatException:
TestFmwk.Errln("Parsing -0.5 should have succeeded.")
proc TestPatterns*() =
    var sym: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-US"))
    var pat: string[] = @["#.#", "#.", ".#", "#"]
    var pat_length: int = pat.Length
    var newpat: string[] = @["0.#", "0.", "#.0", "0"]
    var num: string[] = @["0", "0.", ".0", "0"]
      var i: int = 0
      while i < pat_length:
          var fmt: DecimalFormat = DecimalFormat(pat[i], sym)
          var newp: String = fmt.ToPattern
          if !newp.Equals(newpat[i], StringComparison.Ordinal):
Errln("FAIL: Pattern " + pat[i] + " should transmute to " + newpat[i] + "; " + newp + " seen instead")
          var s: String = cast[NumberFormat](fmt).Format(0)
          if !s.Equals(num[i], StringComparison.Ordinal):
Errln("FAIL: Pattern " + pat[i] + " should format zero as " + num[i] + "; " + s + " seen instead")
Logln("Min integer digits = " + fmt.MinimumIntegerDigits)
          s = cast[NumberFormat](fmt).Format(BigInteger.Zero)
          if !s.Equals(num[i], StringComparison.Ordinal):
Errln("FAIL: Pattern " + pat[i] + " should format BigInteger zero as " + num[i] + "; " + s + " seen instead")
Logln("Min integer digits = " + fmt.MinimumIntegerDigits)
++i
proc TestExponential*() =
    var sym: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-US"))
    var pat: string[] = @["0.####E0", "00.000E00", "##0.######E000", "0.###E0;[0.###E0]"]
    var pat_length: int = pat.Length
    var val: double[] = @[0.01234, 123456789, 1.23e+300, -3.141592653e-271]
    var val_length: int = val.Length
    var valFormat: string[] = @["1.234E-2", "1.2346E8", "1.23E300", "-3.1416E-271", "12.340E-03", "12.346E07", "12.300E299", "-31.416E-272", "12.34E-003", "123.4568E006", "1.23E300", "-314.1593E-273", "1.234E-2", "1.235E8", "1.23E300", "[3.142E-271]"]
    var lval: int[] = @[0, -1, 1, 123456789]
    var lval_length: int = lval.Length
    var lvalFormat: string[] = @["0E0", "-1E0", "1E0", "1.2346E8", "00.000E00", "-10.000E-01", "10.000E-01", "12.346E07", "0E000", "-1E000", "1E000", "123.4568E006", "0E0", "[1E0]", "1E0", "1.235E8"]
    var lvalParse: int[] = @[0, -1, 1, 123460000, 0, -1, 1, 123460000, 0, -1, 1, 123456800, 0, -1, 1, 123500000]
      var ival: int = 0
      var ilval: int = 0
      var p: int = 0
      while p < pat_length:
          var fmt: DecimalFormat = DecimalFormat(pat[p], sym)
Logln("Pattern "" + pat[p] + "" -toPattern-> "" + fmt.ToPattern + """)
          var v: int
            v = 0
            while v < val_length:
                var s: String
                s = cast[NumberFormat](fmt).Format(val[v])
Logln(" " + val[v] + " -format-> " + s)
                if !s.Equals(valFormat[v + ival], StringComparison.Ordinal):
Errln("FAIL: Expected " + valFormat[v + ival])
                var pos: ParsePosition = ParsePosition(0)
                var a: double = fmt.Parse(s, pos).ToDouble
                if pos.Index == s.Length:
Logln("  -parse-> " + a.ToString(CultureInfo.InvariantCulture))
                else:
Errln("FAIL: Partial parse (" + pos.Index + " chars) -> " + a)
++v
            v = 0
            while v < lval_length:
                var s: String
                s = cast[NumberFormat](fmt).Format(lval[v])
Logln(" " + lval[v] + "L -format-> " + s)
                if !s.Equals(lvalFormat[v + ilval], StringComparison.Ordinal):
Errln("ERROR: Expected " + lvalFormat[v + ilval] + " Got: " + s)
                var pos: ParsePosition = ParsePosition(0)
                var a: long = 0
                var A: Number = fmt.Parse(s, pos)
                if A != nil:
                    a = A.ToInt64
                    if pos.Index == s.Length:
Logln("  -parse-> " + a)
                        if a != lvalParse[v + ilval]:
Errln("FAIL: Expected " + lvalParse[v + ilval])
                    else:
Errln("FAIL: Partial parse (" + pos.Index + " chars) -> " + Long.ToString(a, CultureInfo.InvariantCulture))
                else:
Errln("Fail to parse the string: " + s)
++v
          ival = val_length
          ilval = lval_length
++p
proc TestQuotes*() =
    var pat: StringBuffer
    var sym: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-US"))
    pat = StringBuffer("a'fo''o'b#")
    var fmt: DecimalFormat = DecimalFormat(pat.ToString, sym)
    var s: String = cast[NumberFormat](fmt).Format(123)
Logln("Pattern "" + pat + """)
Logln(" Format 123 . " + s)
    if !s.Equals("afo'ob123", StringComparison.Ordinal):
Errln("FAIL: Expected afo'ob123")
    s = ""
    pat = StringBuffer("a''b#")
    fmt = DecimalFormat(pat.ToString, sym)
    s = cast[NumberFormat](fmt).Format(123)
Logln("Pattern "" + pat + """)
Logln(" Format 123 . " + s)
    if !s.Equals("a'b123", StringComparison.Ordinal):
Errln("FAIL: Expected a'b123")
proc TestParseCurrencyTrailingSymbol*() =
    var fmt: NumberFormat = NumberFormat.GetCurrencyInstance(CultureInfo("de-DE"))
    var val: float = 12345.67
    var str: String = fmt.Format(val)
Logln("val: " + val + " str: " + str)
    try:
        var num: Number = fmt.Parse(str)
Logln("num: " + num)
    except FormatException:
Errln("parse of '" + str + "' threw exception: " + e)
proc TestCurrencySign*() =
    var sym: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-US"))
    var pat: StringBuffer = StringBuffer("")
    var currency: char = cast[char](164)
pat.Append(currency).Append("#,##0.00;-").Append(currency).Append("#,##0.00")
    var fmt: DecimalFormat = DecimalFormat(pat.ToString, sym)
    var s: String = cast[NumberFormat](fmt).Format(1234.56)
    pat = StringBuffer
Logln("Pattern "" + fmt.ToPattern + """)
Logln(" Format " + 1234.56 + " . " + s)
assertEquals("symbol, pos", "$1,234.56", s)
    s = cast[NumberFormat](fmt).Format(-1234.56)
Logln(" Format " + -1234.56.ToString(CultureInfo.InvariantCulture) + " . " + s)
assertEquals("symbol, neg", "-$1,234.56", s)
    pat.Length = 0
pat.Append(currency).Append(currency).Append(" #,##0.00;").Append(currency).Append(currency).Append(" -#,##0.00")
    fmt = DecimalFormat(pat.ToString, sym)
    s = cast[NumberFormat](fmt).Format(1234.56)
Logln("Pattern "" + fmt.ToPattern + """)
Logln(" Format " + 1234.56.ToString(CultureInfo.InvariantCulture) + " . " + s)
assertEquals("name, pos", "USD 1,234.56", s)
    s = cast[NumberFormat](fmt).Format(-1234.56)
Logln(" Format " + -1234.56.ToString(CultureInfo.InvariantCulture) + " . " + s)
assertEquals("name, neg", "USD -1,234.56", s)
proc TestSpaceParsing*() =
    var DATA: string[][] = @[@["$124", "4", "-1"], @["$124 $124", "4", "-1"], @["$124 ", "4", "-1"], @["$124  ", "4", "-1"], @["$ 124 ", "5", "-1"], @["$ 124 ", "5", "-1"], @[" $ 124 ", "6", "-1"], @["124$", "3", "-1"], @["124 $", "3", "-1"], @["$124 ", "4", "-1"], @["$ 124", "5", "-1"]]
    var foo: NumberFormat = NumberFormat.GetCurrencyInstance
      var i: int = 0
      while i < DATA.Length:
          var parsePosition: ParsePosition = ParsePosition(0)
          var stringToBeParsed: String = DATA[i][0]
          var parsedPosition: int = Integer.Parse(DATA[i][1], 10)
          var errorIndex: int = Integer.Parse(DATA[i][2], 10)
          try:
              var result: Number = foo.Parse(stringToBeParsed, parsePosition)
              if parsePosition.Index != parsedPosition || parsePosition.ErrorIndex != errorIndex:
Errln("FAILED parse " + stringToBeParsed + "; parse position: " + parsePosition.Index + "; error position: " + parsePosition.ErrorIndex)
              if parsePosition.ErrorIndex == -1 && result.ToDouble != 124:
Errln("FAILED parse " + stringToBeParsed + "; value " + result.ToDouble)
          except Exception:
Errln("FAILED " + e.ToString)
++i
proc TestSpaceParsingStrict*() =
    var cases: object[][] = @[@["123 ", 3, -1], @["123  ", 3, -1], @["123  ,", 3, -1], @["123,", 3, -1], @["123, ", 3, -1], @["123,,", 3, -1], @["123,, ", 3, -1], @["123 ,", 3, -1], @["123, ", 3, -1], @["123, 456", 3, -1], @["123  456", 0, 8]]
    var df: DecimalFormat = DecimalFormat("#,###")
    df.ParseStrict = true
    for cas in cases:
        var input: string = cast[string](cas[0])
        var expectedIndex: int = cast[int](cas[1])
        var expectedErrorIndex: int = cast[int](cas[2])
        var ppos: ParsePosition = ParsePosition(0)
df.Parse(input, ppos)
assertEquals("Failed on index: '" + input + "'", expectedIndex, ppos.Index)
assertEquals("Failed on error: '" + input + "'", expectedErrorIndex, ppos.ErrorIndex)
proc TestMultiCurrencySign*() =
    var DATA: string[][] = @[@["en_US", "¤#,##0.00;-¤#,##0.00", "1234.56", "$1,234.56", "USD 1,234.56", "US dollars 1,234.56"], @["en_US", "¤#,##0.00;-¤#,##0.00", "-1234.56", "-$1,234.56", "-USD 1,234.56", "-US dollars 1,234.56"], @["en_US", "¤#,##0.00;-¤#,##0.00", "1", "$1.00", "USD 1.00", "US dollars 1.00"], @["zh_CN", "¤#,##0.00;(¤#,##0.00)", "1234.56", "￥1,234.56", "CNY 1,234.56", "人民币 1,234.56"], @["zh_CN", "¤#,##0.00;(¤#,##0.00)", "-1234.56", "(￥1,234.56)", "(CNY 1,234.56)", "(人民币 1,234.56)"], @["zh_CN", "¤#,##0.00;(¤#,##0.00)", "1", "￥1.00", "CNY 1.00", "人民币 1.00"]]
    var doubleCurrencyStr: String = "¤¤"
    var tripleCurrencyStr: String = "¤¤¤"
      var i: int = 0
      while i < DATA.Length:
          var locale: String = DATA[i][0]
          var pat: String = DATA[i][1]
          var numberToBeFormat: Double = Double.Parse(DATA[i][2], CultureInfo.InvariantCulture)
          var sym: DecimalFormatSymbols = DecimalFormatSymbols(UCultureInfo(locale))
            var j: int = 1
            while j <= 3:
                if j == 2:
                    pat = pat.Replace("¤", doubleCurrencyStr)

                elif j == 3:
                    pat = pat.Replace("¤¤", tripleCurrencyStr)
                var fmt: DecimalFormat = DecimalFormat(pat, sym)
                var s: String = cast[NumberFormat](fmt).Format(numberToBeFormat)
                var currencyFormatResult: String = DATA[i][2 + j]
                if !s.Equals(currencyFormatResult, StringComparison.Ordinal):
Errln("FAIL format: Expected " + currencyFormatResult + " but got " + s)
                try:
                      var k: int = 3
                      while k <= 4:
                          var oneCurrencyFormat: String = DATA[i][k]
                          if fmt.Parse(oneCurrencyFormat).ToDouble != numberToBeFormat.ToDouble:
Errln("FAILED parse " + oneCurrencyFormat)
++k
                except FormatException:
Errln("FAILED, DecimalFormat parse currency: " + e.ToString)
++j
++i
proc TestCurrencyFormatForMixParsing*() =

proc TestDecimalFormatCurrencyParse*() =
    var sym: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-US"))
    var pat: StringBuffer = StringBuffer("")
    var currency: char = cast[char](164)
pat.Append(currency).Append(currency).Append(currency).Append("#,##0.00;-").Append(currency).Append(currency).Append(currency).Append("#,##0.00")
    var fmt: DecimalFormat = DecimalFormat(pat.ToString, sym)
    var DATA: string[][] = @[@["$1.00", "1"], @["USD1.00", "1"], @["1.00 US dollar", "1"], @["$1,234.56", "1234.56"], @["USD1,234.56", "1234.56"], @["1,234.56 US dollar", "1234.56"]]
    try:
          var i: int = 0
          while i < DATA.Length:
              var stringToBeParsed: string = DATA[i][0]
              var parsedResult: double = Double.Parse(DATA[i][1], CultureInfo.InvariantCulture)
              var num: Number = fmt.Parse(stringToBeParsed)
              if num.ToDouble != parsedResult:
Errln("FAIL parse: Expected " + parsedResult)
++i
    except FormatException:
Errln("FAILED, DecimalFormat parse currency: " + e.ToString)
proc TestCurrency*() =
    var DATA: string[] = @["fr", "CA", "", "1,50 $", "de", "DE", "", "1,50 €", "de", "DE", "PREEURO", "1,50 DM", "fr", "FR", "", "1,50 €", "fr", "FR", "PREEURO", "1,50 F"]
      var i: int = 0
      while i < DATA.Length:
          var fmt: NumberFormat
          var localeString: string
          if DATA[i + 2] == string.Empty:
              localeString = string.Concat(DATA[i], "-", DATA[i + 1])
              var locale: CultureInfo = CultureInfo(localeString)
              fmt = NumberFormat.GetCurrencyInstance(locale)
          else:
              localeString = string.Concat(DATA[i], "-", DATA[i + 1], "-", DATA[i + 2])
              var locale: UCultureInfo = UCultureInfo(localeString)
              fmt = NumberFormat.GetCurrencyInstance(locale)
          var s: String = fmt.Format(1.5)
          if s.Equals(DATA[i + 3], StringComparison.Ordinal):
Logln("Ok: 1.50 x " + localeString + " => " + s)
          else:
Logln("FAIL: 1.50 x " + localeString + " => " + s + ", expected " + DATA[i + 3])
          i = 4
      var i: int = 0
      while i < DATA.Length:
          var curr: Currency
          var fmt: NumberFormat
          var localeString: string
          var currencyName: string
          if DATA[i + 2] == string.Empty:
              localeString = string.Concat(DATA[i], "-", DATA[i + 1])
              var locale: CultureInfo = CultureInfo(localeString)
              curr = Currency.GetInstance(locale)
              currencyName = curr.GetName(locale, CurrencyNameStyle.LongName,               var _: bool)
              fmt = NumberFormat.GetCurrencyInstance(locale)
          else:
              localeString = string.Concat(DATA[i], "-", DATA[i + 1], "-", DATA[i + 2])
              var locale: UCultureInfo = UCultureInfo(localeString)
              curr = Currency.GetInstance(locale)
              currencyName = curr.GetName(locale, CurrencyNameStyle.LongName,               var _: bool)
              fmt = NumberFormat.GetCurrencyInstance(locale)
Logln("
Name of the currency is: " + currencyName)
          var cAmt: CurrencyAmount = CurrencyAmount(cast[Number](Double.GetInstance(1.5)), curr)
Logln("CurrencyAmount object's hashCode is: " + cAmt.GetHashCode)
          var sCurr: String = fmt.Format(cAmt)
          if sCurr.Equals(DATA[i + 3], StringComparison.Ordinal):
Logln("Ok: 1.50 x " + localeString + " => " + sCurr)
          else:
Errln("FAIL: 1.50 x " + localeString + " => " + sCurr + ", expected " + DATA[i + 3])
          i = 4
proc TestJavaCurrencyConversion*() =

proc TestCurrencyIsoPluralFormat*() =
    var DATA: string[][] = @[@["en_US", "1", "USD", "$1.00", "USD 1.00", "1.00 US dollars"], @["en_US", "1234.56", "USD", "$1,234.56", "USD 1,234.56", "1,234.56 US dollars"], @["en_US", "-1234.56", "USD", "-$1,234.56", "-USD 1,234.56", "-1,234.56 US dollars"], @["zh_CN", "1", "USD", "US$1.00", "USD 1.00", "1.00 美元"], @["zh_CN", "1234.56", "USD", "US$1,234.56", "USD 1,234.56", "1,234.56 美元"], @["zh_CN", "1", "CNY", "￥1.00", "CNY 1.00", "1.00 人民币"], @["zh_CN", "1234.56", "CNY", "￥1,234.56", "CNY 1,234.56", "1,234.56 人民币"], @["ru_RU", "1", "RUB", "1,00 ₽", "1,00 RUB", "1,00 российского рубля"], @["ru_RU", "2", "RUB", "2,00 ₽", "2,00 RUB", "2,00 российского рубля"], @["ru_RU", "5", "RUB", "5,00 ₽", "5,00 RUB", "5,00 российского рубля"], @["root", "-1.23", "USD", "-US$ 1.23", "-USD 1.23", "-1.23 USD"], @["root@numbers=latn", "-1.23", "USD", "-US$ 1.23", "-USD 1.23", "-1.23 USD"], @["root@numbers=arab", "-1.23", "USD", "؜-١٫٢٣ US$", "؜-١٫٢٣ USD", "؜-١٫٢٣ USD"], @["es_AR", "1", "INR", "INR 1,00", "INR 1,00", "1,00 rupia india"], @["ar_EG", "1", "USD", "١٫٠٠ US$", "١٫٠٠ USD", "١٫٠٠ دولار أمريكي"]]
      var i: int = 0
      while i < DATA.Length:
            var k: int = cast[int](NumberFormatStyle.CurrencyStyle)
            while k <= cast[int](NumberFormatStyle.PluralCurrencyStyle):
                if k != cast[int](NumberFormatStyle.CurrencyStyle) && k != cast[int](NumberFormatStyle.ISOCurrencyStyle) && k != cast[int](NumberFormatStyle.PluralCurrencyStyle):
                    continue
                var localeString: string = DATA[i][0]
                var numberToBeFormat: Double = Double.Parse(DATA[i][1], CultureInfo.InvariantCulture)
                var currencyISOCode: string = DATA[i][2]
                var locale: UCultureInfo = UCultureInfo(localeString)
                var numFmt: NumberFormat = NumberFormat.GetInstance(locale, cast[NumberFormatStyle](k))
                numFmt.Currency = Currency.GetInstance(currencyISOCode)
                var strBuf: string = numFmt.Format(numberToBeFormat)
                var resultDataIndex: int = k - 1
                if k == cast[int](NumberFormatStyle.CurrencyStyle):
                    resultDataIndex = k + 2
                var formatResult: string = DATA[i][resultDataIndex]
                if !strBuf.Equals(formatResult, StringComparison.Ordinal):
Errln("FAIL: localeID: " + localeString + ", expected(" + formatResult.Length + "): "" + formatResult + "", actual(" + strBuf.Length + "): "" + strBuf + """)
                  var j: int = 3
                  while j < 6:
                      var oneCurrencyFormatResult: String = DATA[i][j]
                      var val: CurrencyAmount = numFmt.ParseCurrency(oneCurrencyFormatResult, nil)
                      if val.Number.ToDouble != numberToBeFormat.ToDouble:
Errln("FAIL: getCurrencyFormat of locale " + localeString + " failed roundtripping the number. val=" + val + "; expected: " + numberToBeFormat)
++j
++k
++i
proc TestMiscCurrencyParsing*() =
    var DATA: string[][] = @[@["1.00 ", "4", "-1", "0", "5"], @["1.00 UAE dirha", "4", "-1", "0", "14"], @["1.00 us dollar", "4", "-1", "14", "-1"], @["1.00 US DOLLAR", "4", "-1", "14", "-1"], @["1.00 usd", "4", "-1", "8", "-1"], @["1.00 USD", "4", "-1", "8", "-1"]]
    var locale: UCultureInfo = UCultureInfo("en_US")
      var i: int = 0
      while i < DATA.Length:
          var stringToBeParsed: string = DATA[i][0]
          var parsedPosition: int = Integer.Parse(DATA[i][1], 10)
          var errorIndex: int = Integer.Parse(DATA[i][2], 10)
          var currParsedPosition: int = Integer.Parse(DATA[i][3], 10)
          var currErrorIndex: int = Integer.Parse(DATA[i][4], 10)
          var numFmt: NumberFormat = NumberFormat.GetInstance(locale, NumberFormatStyle.CurrencyStyle)
          var parsePosition: ParsePosition = ParsePosition(0)
          var val: Number = numFmt.Parse(stringToBeParsed, parsePosition)
          if parsePosition.Index != parsedPosition || parsePosition.ErrorIndex != errorIndex:
Errln("FAIL: parse failed on case " + i + ". expected position: " + parsedPosition + "; actual: " + parsePosition.Index)
Errln("FAIL: parse failed on case " + i + ". expected error position: " + errorIndex + "; actual: " + parsePosition.ErrorIndex)
          if parsePosition.ErrorIndex == -1 && val.ToDouble != 1.0:
Errln("FAIL: parse failed. expected 1.00, actual:" + val)
          parsePosition = ParsePosition(0)
          var amt: CurrencyAmount = numFmt.ParseCurrency(stringToBeParsed, parsePosition)
          if parsePosition.Index != currParsedPosition || parsePosition.ErrorIndex != currErrorIndex:
Errln("FAIL: parseCurrency failed on case " + i + ". expected error position: " + currErrorIndex + "; actual: " + parsePosition.ErrorIndex)
Errln("FAIL: parseCurrency failed on case " + i + ". expected position: " + currParsedPosition + "; actual: " + parsePosition.Index)
          if parsePosition.ErrorIndex == -1 && amt.Number.ToDouble != 1.0:
Errln("FAIL: parseCurrency failed. expected 1.00, actual:" + val)
++i
type
  ParseCurrencyItem = ref object
    localeString: String
    descrip: String
    currStr: String
    numExpectPos: int
    numExpectVal: int
    curExpectPos: int
    curExpectVal: int
    curExpectCurr: String

proc newParseCurrencyItem(locStr: String, desc: String, curr: String, numExPos: int, numExVal: int, curExPos: int, curExVal: int, curExCurr: String): ParseCurrencyItem =
  localeString = locStr
  descrip = desc
  currStr = curr
  numExpectPos = numExPos
  numExpectVal = numExVal
  curExpectPos = curExPos
  curExpectVal = curExVal
  curExpectCurr = curExCurr
proc getLocaleString*(): String =
    return localeString
proc getDescrip*(): String =
    return descrip
proc getCurrStr*(): String =
    return currStr
proc getNumExpectPos*(): int =
    return numExpectPos
proc getNumExpectVal*(): int =
    return numExpectVal
proc getCurExpectPos*(): int =
    return curExpectPos
proc getCurExpectVal*(): int =
    return curExpectVal
proc getCurExpectCurr*(): String =
    return curExpectCurr
proc TestParseCurrency*() =
    var parseCurrencyItems: ParseCurrencyItem[] = @[ParseCurrencyItem("en_US", "dollars2", "$2.00", 5, 2, 5, 2, "USD"), ParseCurrencyItem("en_US", "dollars4", "$4", 2, 4, 2, 4, "USD"), ParseCurrencyItem("en_US", "dollars9", "9 $", 1, 9, 3, 9, "USD"), ParseCurrencyItem("en_US", "pounds3", "£3.00", 0, 0, 5, 3, "GBP"), ParseCurrencyItem("en_US", "pounds5", "£5", 0, 0, 2, 5, "GBP"), ParseCurrencyItem("en_US", "pounds7", "7 £", 1, 7, 3, 7, "GBP"), ParseCurrencyItem("en_US", "euros8", "€8", 0, 0, 2, 8, "EUR"), ParseCurrencyItem("en_GB", "pounds3", "£3.00", 5, 3, 5, 3, "GBP"), ParseCurrencyItem("en_GB", "pounds5", "£5", 2, 5, 2, 5, "GBP"), ParseCurrencyItem("en_GB", "pounds7", "7 £", 1, 7, 3, 7, "GBP"), ParseCurrencyItem("en_GB", "euros4", "4,00 €", 4, 400, 6, 400, "EUR"), ParseCurrencyItem("en_GB", "euros6", "6 €", 1, 6, 3, 6, "EUR"), ParseCurrencyItem("en_GB", "euros8", "€8", 0, 0, 2, 8, "EUR"), ParseCurrencyItem("en_GB", "dollars4", "US$4", 0, 0, 4, 4, "USD"), ParseCurrencyItem("fr_FR", "euros4", "4,00 €", 6, 4, 6, 4, "EUR"), ParseCurrencyItem("fr_FR", "euros6", "6 €", 3, 6, 3, 6, "EUR"), ParseCurrencyItem("fr_FR", "euros8", "€8", 0, 0, 2, 8, "EUR"), ParseCurrencyItem("fr_FR", "dollars2", "$2.00", 0, 0, 0, 0, ""), ParseCurrencyItem("fr_FR", "dollars4", "$4", 0, 0, 0, 0, "")]
    for item in parseCurrencyItems:
        var localeString: String = item.getLocaleString
        var uloc: UCultureInfo = UCultureInfo(localeString)
        var fmt: NumberFormat = nil
        try:
            fmt = NumberFormat.GetCurrencyInstance(uloc)
        except Exception:
Errln("NumberFormat.getCurrencyInstance fails for locale " + localeString)
            continue
        var currStr: String = item.getCurrStr
        var parsePos: ParsePosition = ParsePosition(0)
        var numVal: Number = fmt.Parse(currStr, parsePos)
        if parsePos.Index != item.getNumExpectPos || numVal != nil && numVal.ToInt32 != item.getNumExpectVal:
            if numVal != nil:
Errln("NumberFormat.getCurrencyInstance parse " + localeString + "/" + item.getDescrip + ", expect pos/val " + item.getNumExpectPos + "/" + item.getNumExpectVal + ", get " + parsePos.Index + "/" + numVal.ToInt32)
            else:
Errln("NumberFormat.getCurrencyInstance parse " + localeString + "/" + item.getDescrip + ", expect pos/val " + item.getNumExpectPos + "/" + item.getNumExpectVal + ", get " + parsePos.Index + "/(NULL)")
        parsePos.Index = 0
        var curExpectPos: int = item.getCurExpectPos
        var currAmt: CurrencyAmount = fmt.ParseCurrency(currStr, parsePos)
        if parsePos.Index != curExpectPos || currAmt != nil && currAmt.Number.ToInt32 != item.getCurExpectVal || currAmt.Currency.CurrencyCode.CompareToOrdinal(item.getCurExpectCurr) != 0:
            if currAmt != nil:
Errln("NumberFormat.getCurrencyInstance parseCurrency " + localeString + "/" + item.getDescrip + ", expect pos/val/curr " + curExpectPos + "/" + item.getCurExpectVal + "/" + item.getCurExpectCurr + ", get " + parsePos.Index + "/" + currAmt.Number.ToInt32 + "/" + currAmt.Currency.CurrencyCode)
            else:
Errln("NumberFormat.getCurrencyInstance parseCurrency " + localeString + "/" + item.getDescrip + ", expect pos/val/curr " + curExpectPos + "/" + item.getCurExpectVal + "/" + item.getCurExpectCurr + ", get " + parsePos.Index + "/(NULL)")
proc TestParseCurrencyWithWhitespace*() =
    var df: DecimalFormat = DecimalFormat("#,##0.00 ¤¤")
    var ppos: ParsePosition = ParsePosition(0)
df.ParseCurrency("1.00 us denmark", ppos)
assertEquals("Expected to fail on 'us denmark' string", 9, ppos.ErrorIndex)
proc TestParseCurrPatternWithDecStyle*() =
    var currpat: String = "¤#,##0.00"
    var parsetxt: String = "x0y$"
    var decfmt: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(UCultureInfo("en_US"), NumberFormatStyle.NumberStyle))
decfmt.ApplyPattern(currpat)
    var ppos: ParsePosition = ParsePosition(0)
    var value: Number = decfmt.Parse(parsetxt, ppos)
    if ppos.Index != 0:
Errln("DecimalFormat.parse expected to fail but got ppos " + ppos.Index + ", value " + value)
proc TestCurrencyObject*() =
    var fmt: NumberFormat = NumberFormat.GetCurrencyInstance(CultureInfo("en-US"))
expectCurrency(fmt, nil, 1234.56, "$1,234.56")
expectCurrency(fmt, Currency.GetInstance(CultureInfo("fr-FR")), 1234.56, "€1,234.56")
expectCurrency(fmt, Currency.GetInstance(CultureInfo("ja-JP")), 1234.56, "¥1,235")
expectCurrency(fmt, Currency.GetInstance(CultureInfo("fr-CH")), 1234.56, "CHF 1,234.56")
expectCurrency(fmt, Currency.GetInstance(CultureInfo("en-US")), 1234.56, "$1,234.56")
    fmt = NumberFormat.GetCurrencyInstance(CultureInfo("fr-FR"))
expectCurrency(fmt, nil, 1234.56, "1 234,56 €")
expectCurrency(fmt, Currency.GetInstance(CultureInfo("ja-JP")), 1234.56, "1 235 JPY")
expectCurrency(fmt, Currency.GetInstance(CultureInfo("fr-CH")), 1234.56, "1 234,56 CHF")
expectCurrency(fmt, Currency.GetInstance(CultureInfo("en-US")), 1234.56, "1 234,56 $US")
expectCurrency(fmt, Currency.GetInstance(CultureInfo("fr-FR")), 1234.56, "1 234,56 €")
proc TestCompatibleCurrencies*() =
    var fmt: NumberFormat = NumberFormat.GetCurrencyInstance(CultureInfo("en-US"))
expectParseCurrency(fmt, Currency.GetInstance(CultureInfo("ja-JP")), "¥1,235")
expectParseCurrency(fmt, Currency.GetInstance(CultureInfo("ja-JP")), "￥1,235")
proc TestCurrencyPatterns*() =
    var i: int
    var rnd: Random = Random(2017)
    var locs: CultureInfo[] = NumberFormat.GetCultures(UCultureTypes.AllCultures)
      i = 0
      while i < locs.Length:
          if rnd.NextDouble < 0.9:
              continue
          var nf: NumberFormat = NumberFormat.GetCurrencyInstance(locs[i])
          var min: int = nf.MinimumFractionDigits
          var max: int = nf.MaximumFractionDigits
          if min != max:
              var a: String = nf.Format(1.0)
              var b: String = nf.Format(1.125)
Errln("FAIL: " + locs[i] + " min fraction digits != max fraction digits; " + "x 1.0 => " + a + "; x 1.125 => " + b)
          if nf is DecimalFormat:
              var curr: Currency = cast[DecimalFormat](nf).Currency
              if curr != nil && "EUR".Equals(curr.CurrencyCode, StringComparison.Ordinal):
                  if min != 2 || max != 2:
                      var a: String = nf.Format(1.0)
Errln("FAIL: " + locs[i] + " is a EURO format but it does not have 2 fraction digits; " + "x 1.0 => " + a)
++i
proc TestParse*() =
    var arg: String = "0.0"
    var format: DecimalFormat = DecimalFormat("00")
    var aNumber: double = 0
    try:
        aNumber = format.Parse(arg).ToDouble
    except ParseException:
Console.Out.WriteLine(e)
Logln("parse(" + arg + ") = " + aNumber)
proc TestRounding487*() =
    var nf: NumberFormat = NumberFormat.GetInstance
roundingTest(nf, 0.00159999, 4, "0.0016")
roundingTest(nf, 0.00995, 4, "0.01")
roundingTest(nf, 12.3995, 3, "12.4")
roundingTest(nf, 12.4999, 0, "12")
roundingTest(nf, -19.5, 0, "-20")
proc TestSecondaryGrouping*() =
    var US: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-US"))
    var f: DecimalFormat = DecimalFormat("#,##,###", US)
expect(f, 123456789, "12,34,56,789")
expectPat(f, "#,##,##0")
f.ApplyPattern("#,###")
    f.SecondaryGroupingSize = 4
expect(f, 123456789, "12,3456,789")
expectPat(f, "#,####,##0")
    var g: NumberFormat = NumberFormat.GetInstance(CultureInfo("hi-IN"))
    var @out: String = ""
    var l: long = 1876543210
    @out = g.Format(l)
    var ok: bool = true
    if @out.Length != 14:
        ok = false
    else:
          var i: int = 0
          while i < @out.Length:
              var expectGroup: bool = false
              case i
              of 1:
                  expectGroup = true
                  break
              of 4:
                  expectGroup = true
                  break
              of 7:
                  expectGroup = true
                  break
              of 10:
                  expectGroup = true
                  break
              var isGroup: bool = @out[i] == 44
              if isGroup != expectGroup:
                  ok = false
                  break
++i
    if !ok:
Errln("FAIL  Expected " + l + " x hi_IN . "1,87,65,43,210" (with Hindi digits), got "" + @out + """)
    else:
Logln("Ok    " + l + " x hi_IN . "" + @out + """)
proc roundingTest(nf: NumberFormat, x: double, maxFractionDigits: int, expected: String) =
    nf.MaximumFractionDigits = maxFractionDigits
    var @out: String = nf.Format(x)
Logln(x + " formats with " + maxFractionDigits + " fractional digits to " + @out)
    if !@out.Equals(expected, StringComparison.Ordinal):
Errln("FAIL: Expected " + expected)
proc TestExponent*() =
    var US: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-US"))
    var fmt1: DecimalFormat = DecimalFormat("0.###E0", US)
    var fmt2: DecimalFormat = DecimalFormat("0.###E+0", US)
    var n: int = 1234
expect2(fmt1, n, "1.234E3")
expect2(fmt2, n, "1.234E+3")
expect(fmt1, "1.234E+3", n)
proc TestScientific*() =
    var US: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-US"))
    var PAT: string[] = @["#E0", "0.####E0", "00.000E00", "##0.####E000", "0.###E0;[0.###E0]"]
    var PAT_length: int = PAT.Length
    var DIGITS: int[] = @[0, 1, 0, 0, 1, 1, 0, 4, 2, 2, 3, 3, 1, 3, 0, 4, 1, 1, 0, 3]
      var i: int = 0
      while i < PAT_length:
          var pat: String = PAT[i]
          var df: DecimalFormat = DecimalFormat(pat, US)
          var pat2: String = df.ToPattern
          if pat.Equals(pat2, StringComparison.Ordinal):
Logln("Ok   Pattern rt "" + pat + "" . "" + pat2 + """)
          else:
Errln("FAIL Pattern rt "" + pat + "" . "" + pat2 + """)
          if i == 0:
            continue
          if df.MinimumIntegerDigits != DIGITS[4 * i] || df.MaximumIntegerDigits != DIGITS[4 * i + 1] || df.MinimumFractionDigits != DIGITS[4 * i + 2] || df.MaximumFractionDigits != DIGITS[4 * i + 3]:
Errln("FAIL "" + pat + "" min/max int; min/max frac = " + df.MinimumIntegerDigits + "/" + df.MaximumIntegerDigits + ";" + df.MinimumFractionDigits + "/" + df.MaximumFractionDigits + ", expect " + DIGITS[4 * i] + "/" + DIGITS[4 * i + 1] + ";" + DIGITS[4 * i + 2] + "/" + DIGITS[4 * i + 3])
++i
expect2(DecimalFormat("#E0", US), 12345.0, "1.2345E4")
expect(DecimalFormat("0E0", US), 12345.0, "1E4")
expect2(NumberFormat.GetScientificInstance(CultureInfo("en-US")), 12345.678901, "1.2345678901E4")
Logln("Testing NumberFormat.getScientificInstance(ULocale) ...")
expect2(NumberFormat.GetScientificInstance(UCultureInfo("en-US")), 12345.678901, "1.2345678901E4")
expect(DecimalFormat("##0.###E0", US), 12345.0, "12.34E3")
expect(DecimalFormat("##0.###E0", US), 12345.00001, "12.35E3")
expect2(DecimalFormat("##0.####E0", US), 12345, "12.345E3")
expect2(NumberFormat.GetScientificInstance(CultureInfo("fr-FR")), 12345.678901, "1,2345678901E4")
Logln("Testing NumberFormat.getScientificInstance(ULocale) ...")
expect2(NumberFormat.GetScientificInstance(UCultureInfo("fr-FR")), 12345.678901, "1,2345678901E4")
expect(DecimalFormat("##0.####E0", US), 0.00000078912345, "789.12E-9")
expect2(DecimalFormat("##0.####E0", US), 0.00000078, "780E-9")
expect(DecimalFormat(".###E0", US), 45678.0, ".457E5")
expect2(DecimalFormat(".###E0", US), 0, ".0E0")
expect2(DecimalFormat("#E0", US), 45678000, "4.5678E7")
expect2(DecimalFormat("##E0", US), 45678000, "45.678E6")
expect2(DecimalFormat("####E0", US), 45678000, "4567.8E4")
expect(DecimalFormat("0E0", US), 45678000, "5E7")
expect(DecimalFormat("00E0", US), 45678000, "46E6")
expect(DecimalFormat("000E0", US), 45678000, "457E5")
expect2(DecimalFormat("###E0", US), 0.0000123, "12.3E-6")
expect2(DecimalFormat("###E0", US), 0.000123, "123E-6")
expect2(DecimalFormat("###E0", US), 0.00123, "1.23E-3")
expect2(DecimalFormat("###E0", US), 0.0123, "12.3E-3")
expect2(DecimalFormat("###E0", US), 0.123, "123E-3")
expect2(DecimalFormat("###E0", US), 1.23, "1.23E0")
expect2(DecimalFormat("###E0", US), 12.3, "12.3E0")
expect2(DecimalFormat("###E0", US), 123.0, "123E0")
expect2(DecimalFormat("###E0", US), 1230.0, "1.23E3")
expect2(DecimalFormat("0.#E+00", US), 0.00012, "1.2E-04")
expect2(DecimalFormat("0.#E+00", US), 12000, "1.2E+04")
proc TestPad*() =
    var US: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-US"))
expect2(DecimalFormat("*^##.##", US), 0, "^^^^0")
expect2(DecimalFormat("*^##.##", US), -1.3, "^-1.3")
expect2(DecimalFormat("##0.0####E0*_ 'g-m/s^2'", US), 0, "0.0E0______ g-m/s^2")
expect(DecimalFormat("##0.0####E0*_ 'g-m/s^2'", US), 1.0 / 3, "333.333E-3_ g-m/s^2")
expect2(DecimalFormat("##0.0####*_ 'g-m/s^2'", US), 0, "0.0______ g-m/s^2")
expect(DecimalFormat("##0.0####*_ 'g-m/s^2'", US), 1.0 / 3, "0.33333__ g-m/s^2")
    var formatStr: String = "*x#,###,###,##0.0#;*x(###,###,##0.0#)"
expect2(DecimalFormat(formatStr, US), -10, "xxxxxxxxxx(10.0)")
expect2(DecimalFormat(formatStr, US), -1000, "xxxxxxx(1,000.0)")
expect2(DecimalFormat(formatStr, US), -1000000, "xxx(1,000,000.0)")
expect2(DecimalFormat(formatStr, US), -100.37, "xxxxxxxx(100.37)")
expect2(DecimalFormat(formatStr, US), -10456.37, "xxxxx(10,456.37)")
expect2(DecimalFormat(formatStr, US), -1120456.37, "xx(1,120,456.37)")
expect2(DecimalFormat(formatStr, US), -112045600.37, "(112,045,600.37)")
expect2(DecimalFormat(formatStr, US), -1252045600.37, "(1,252,045,600.37)")
expect2(DecimalFormat(formatStr, US), 10, "xxxxxxxxxxxx10.0")
expect2(DecimalFormat(formatStr, US), 1000, "xxxxxxxxx1,000.0")
expect2(DecimalFormat(formatStr, US), 1000000, "xxxxx1,000,000.0")
expect2(DecimalFormat(formatStr, US), 100.37, "xxxxxxxxxx100.37")
expect2(DecimalFormat(formatStr, US), 10456.37, "xxxxxxx10,456.37")
expect2(DecimalFormat(formatStr, US), 1120456.37, "xxxx1,120,456.37")
expect2(DecimalFormat(formatStr, US), 112045600.37, "xx112,045,600.37")
expect2(DecimalFormat(formatStr, US), 10252045600.37, "10,252,045,600.37")
    var formatStr2: String = "#,###,###,##0.0#*x;(###,###,##0.0#*x)"
expect2(DecimalFormat(formatStr2, US), -10, "(10.0xxxxxxxxxx)")
expect2(DecimalFormat(formatStr2, US), -1000, "(1,000.0xxxxxxx)")
expect2(DecimalFormat(formatStr2, US), -1000000, "(1,000,000.0xxx)")
expect2(DecimalFormat(formatStr2, US), -100.37, "(100.37xxxxxxxx)")
expect2(DecimalFormat(formatStr2, US), -10456.37, "(10,456.37xxxxx)")
expect2(DecimalFormat(formatStr2, US), -1120456.37, "(1,120,456.37xx)")
expect2(DecimalFormat(formatStr2, US), -112045600.37, "(112,045,600.37)")
expect2(DecimalFormat(formatStr2, US), -1252045600.37, "(1,252,045,600.37)")
expect2(DecimalFormat(formatStr2, US), 10, "10.0xxxxxxxxxxxx")
expect2(DecimalFormat(formatStr2, US), 1000, "1,000.0xxxxxxxxx")
expect2(DecimalFormat(formatStr2, US), 1000000, "1,000,000.0xxxxx")
expect2(DecimalFormat(formatStr2, US), 100.37, "100.37xxxxxxxxxx")
expect2(DecimalFormat(formatStr2, US), 10456.37, "10,456.37xxxxxxx")
expect2(DecimalFormat(formatStr2, US), 1120456.37, "1,120,456.37xxxx")
expect2(DecimalFormat(formatStr2, US), 112045600.37, "112,045,600.37xx")
expect2(DecimalFormat(formatStr2, US), 10252045600.37, "10,252,045,600.37")
    var fmt: DecimalFormat = DecimalFormat("#", US)
    var padString: char = 'P'
    fmt.PadCharacter = padString
expectPad(fmt, "*P##.##", PadPosition.BeforePrefix, 5, padString)
    fmt.PadCharacter = '^'
expectPad(fmt, "*^#", PadPosition.BeforePrefix, 1, '^')
expect2(DecimalFormat("*'😃'####.00", US), 1.1, "😃😃😃1.10")
proc TestPatterns2*() =
    var US: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-US"))
    var fmt: DecimalFormat = DecimalFormat("#", US)
    var hat: char = cast[char](94)
expectPad(fmt, "*^#", PadPosition.BeforePrefix, 1, hat)
expectPad(fmt, "$*^#", PadPosition.AfterPrefix, 2, hat)
expectPad(fmt, "#*^", PadPosition.BeforeSuffix, 1, hat)
expectPad(fmt, "#$*^", PadPosition.AfterSuffix, 2, hat)
expectPad(fmt, "$*^$#", cast[PadPosition](-1))
expectPad(fmt, "#$*^$", cast[PadPosition](-1))
expectPad(fmt, "'pre'#,##0*x'post'", PadPosition.BeforeSuffix, 12, cast[char](120))
expectPad(fmt, "''#0*x", PadPosition.BeforeSuffix, 3, cast[char](120))
expectPad(fmt, "'I''ll'*a###.##", PadPosition.AfterPrefix, 10, cast[char](97))
fmt.ApplyPattern("AA#,##0.00ZZ")
    fmt.PadCharacter = hat
    fmt.FormatWidth = 10
    fmt.PadPosition = PadPosition.BeforePrefix
expectPat(fmt, "*^AA#,##0.00ZZ")
    fmt.PadPosition = PadPosition.BeforeSuffix
expectPat(fmt, "AA#,##0.00*^ZZ")
    fmt.PadPosition = PadPosition.AfterSuffix
expectPat(fmt, "AA#,##0.00ZZ*^")
    var exp: String = "AA*^#,##0.00ZZ"
    fmt.FormatWidth = 12
    fmt.PadPosition = PadPosition.AfterPrefix
expectPat(fmt, exp)
    fmt.FormatWidth = 13
expectPat(fmt, "AA*^##,##0.00ZZ")
    fmt.FormatWidth = 14
expectPat(fmt, "AA*^###,##0.00ZZ")
    fmt.FormatWidth = 15
expectPat(fmt, "AA*^####,##0.00ZZ")
    fmt.FormatWidth = 16
expectPat(fmt, "AA*^#####,##0.00ZZ")
type
  TestFactory = ref object
    currencyStyle: NumberFormat

proc newTestFactory(SRC_LOC: UCultureInfo, SWAP_LOC: UCultureInfo): TestFactory =
newSimpleNumberFormatFactory(SRC_LOC, true)
  currencyStyle = NumberFormat.GetIntegerInstance(SWAP_LOC)
proc CreateFormat*(loc: UCultureInfo, formatType: int): NumberFormat =
    if formatType == FormatCurrency:
        return currencyStyle
    return nil
proc TestRegistration*() =
    var SRC_LOC: UCultureInfo = UCultureInfo("fr-FR")
    var SWAP_LOC: UCultureInfo = UCultureInfo("en-US")
    var f0: NumberFormat = NumberFormat.GetIntegerInstance(SWAP_LOC)
    var f1: NumberFormat = NumberFormat.GetIntegerInstance(SRC_LOC)
    var f2: NumberFormat = NumberFormat.GetCurrencyInstance(SRC_LOC)
    var key: Object = NumberFormat.RegisterFactory(TestFactory(SRC_LOC, SWAP_LOC))
    var f3: NumberFormat = NumberFormat.GetCurrencyInstance(SRC_LOC)
    var f4: NumberFormat = NumberFormat.GetIntegerInstance(SRC_LOC)
NumberFormat.Unregister(key)
    var f5: NumberFormat = NumberFormat.GetCurrencyInstance(SRC_LOC)
    var n: float = 1234.567
Logln("f0 swap int: " + f0.Format(n))
Logln("f1 src int: " + f1.Format(n))
Logln("f2 src cur: " + f2.Format(n))
Logln("f3 reg cur: " + f3.Format(n))
Logln("f4 reg int: " + f4.Format(n))
Logln("f5 unreg cur: " + f5.Format(n))
    if !f3.Format(n).Equals(f0.Format(n), StringComparison.Ordinal):
Errln("registered service did not match")
    if !f4.Format(n).Equals(f1.Format(n), StringComparison.Ordinal):
Errln("registered service did not inherit")
    if !f5.Format(n).Equals(f2.Format(n), StringComparison.Ordinal):
Errln("unregistered service did not match original")
proc TestScientific2*() =
    var fmt: DecimalFormat = cast[DecimalFormat](NumberFormat.GetCurrencyInstance)
    var num: Number = Double.GetInstance(12.34)
expect(fmt, num, "$12.34")
    fmt.UseScientificNotation = true
expect(fmt, num, "$1.23E1")
    fmt.UseScientificNotation = false
expect(fmt, num, "$12.34")
proc TestScientificGrouping*() =
    var fmt: DecimalFormat = DecimalFormat("###.##E0")
expect(fmt, 0.01234, "12.3E-3")
expect(fmt, 0.1234, "123E-3")
expect(fmt, 1.234, "1.23E0")
expect(fmt, 12.34, "12.3E0")
expect(fmt, 123.4, "123E0")
expect(fmt, 1234, "1.23E3")
type
  PI = ref object
    INSTANCE: Number = PI

proc newPI(): PI =

proc ToInt32*(): int =
    return cast[int](Math.PI)
proc ToInt64*(): long =
    return cast[long](Math.PI)
proc ToSingle*(): float =
    return cast[float](Math.PI)
proc ToDouble*(): double =
    return Math.PI
proc ToByte*(): byte =
    return cast[byte](Math.PI)
proc ToInt16*(): short =
    return cast[short](Math.PI)
proc ToString*(format: string, provider: IFormatProvider): string =
    return Math.PI.ToString(format, provider)
proc TestCoverage*() =
    var fmt: NumberFormat = NumberFormat.GetNumberInstance
Logln(fmt.Format(BigInteger.Parse("1234567890987654321234567890987654321", 10)))
    fmt = NumberFormat.GetScientificInstance
Logln(fmt.Format(PI.INSTANCE))
    try:
Logln(fmt.Format("12345"))
Errln("numberformat of string did not throw exception")
    except Exception:
Logln("PASS: numberformat of string failed as expected")
    var hash: int = fmt.GetHashCode
Logln("hash code " + hash)
Logln("compare to string returns: " + fmt.Equals(""))
    var US: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-US"))
    var df: DecimalFormat = DecimalFormat("'*&'' '¤' ''&*' #,##0.00", US)
    df.Currency = Currency.GetInstance("INR")
expect2(df, 1.0, "*&' ₹ '&* 1.00")
expect2(df, -2.0, "-*&' ₹ '&* 2.00")
df.ApplyPattern("#,##0.00 '*&'' '¤' ''&*'")
expect2(df, 2.0, "2.00 *&' ₹ '&*")
expect2(df, -1.0, "-1.00 *&' ₹ '&*")
    var r: Numerics.BigMath.BigDecimal
    r = df.RoundingIncrement
    if r != nil:
Errln("FAIL: rounding = " + r + ", expect null")
    if df.UseScientificNotation:
Errln("FAIL: isScientificNotation = true, expect false")
    df = DecimalFormat("0.00000", US)
    df.UseScientificNotation = true
    if !df.UseScientificNotation:
Errln("FAIL: isScientificNotation = false, expect true")
    df.MinimumExponentDigits = cast[byte](2)
    if df.MinimumExponentDigits != 2:
Errln("FAIL: getMinimumExponentDigits = " + df.MinimumExponentDigits + ", expect 2")
    df.ExponentSignAlwaysShown = true
    if !df.ExponentSignAlwaysShown:
Errln("FAIL: isExponentSignAlwaysShown = false, expect true")
    df.SecondaryGroupingSize = 0
    if df.SecondaryGroupingSize != 0:
Errln("FAIL: getSecondaryGroupingSize = " + df.SecondaryGroupingSize + ", expect 0")
expect2(df, 3.14159, "3.14159E+00")
    var decsym1: DecimalFormatSymbols = DecimalFormatSymbols.GetInstance
    var decsym2: DecimalFormatSymbols = DecimalFormatSymbols
    if !decsym1.Equals(decsym2):
Errln("FAIL: DecimalFormatSymbols returned by getInstance()" + "does not match new DecimalFormatSymbols().")
    decsym1 = DecimalFormatSymbols.GetInstance(CultureInfo("ja-JP"))
    decsym2 = DecimalFormatSymbols.GetInstance(UCultureInfo("ja-JP"))
    if !decsym1.Equals(decsym2):
Errln("FAIL: DecimalFormatSymbols returned by getInstance(Locale.JAPAN)" + "does not match the one returned by getInstance(ULocale.JAPAN).")
    var allLocales: CultureInfo[] = DecimalFormatSymbols.GetCultures(UCultureTypes.AllCultures)
    if allLocales.Length == 0:
Errln("FAIL: Got a empty list for DecimalFormatSymbols.getAvailableLocales")
    else:
Logln("PASS: " + allLocales.Length + " available locales returned by DecimalFormatSymbols.getAvailableLocales")
    var allULocales: UCultureInfo[] = DecimalFormatSymbols.GetUCultures(UCultureTypes.AllCultures)
    if allULocales.Length == 0:
Errln("FAIL: Got a empty list for DecimalFormatSymbols.getAvailableLocales")
    else:
Logln("PASS: " + allULocales.Length + " available locales returned by DecimalFormatSymbols.getAvailableULocales")
proc TestLocalizedPatternSymbolCoverage*() =
    var standardPatterns: string[] = @["#,##0.05+%;#,##0.05-%", "* @@@E0‰"]
    var standardPatterns58: string[] = @["#,##0.05+%;#,##0.05-%", "* @@@E0‰;* -@@@E0‰"]
    var localizedPatterns: string[] = @["▰⁖▰▰໐⁘໐໕†⁜⁙▰⁖▰▰໐⁘໐໕‡⁜", "⁂ ⁕⁕⁕⁑⁑໐‱"]
    var localizedPatterns58: string[] = @["▰⁖▰▰໐⁘໐໕+⁜⁙▰⁖▰▰໐⁘໐໕‡⁜", "⁂ ⁕⁕⁕⁑⁑໐‱⁙⁂ ‡⁕⁕⁕⁑⁑໐‱"]
    var dfs: DecimalFormatSymbols = DecimalFormatSymbols
    dfs.GroupingSeparator = '�'
    dfs.DecimalSeparator = '�'
    dfs.PatternSeparator = '�'
    dfs.Digit = '�'
    dfs.ZeroDigit = '�'
    dfs.SignificantDigit = '�'
    dfs.PlusSign = '�'
    dfs.MinusSign = '�'
    dfs.Percent = '�'
    dfs.PerMill = '�'
    dfs.ExponentSeparator = "⁑⁑"
    dfs.PadEscape = '�'
      var i: int = 0
      while i < 2:
          var standardPattern: String = standardPatterns[i]
          var standardPattern58: String = standardPatterns58[i]
          var localizedPattern: String = localizedPatterns[i]
          var localizedPattern58: String = localizedPatterns58[i]
          var df1: DecimalFormat = DecimalFormat("#", dfs)
df1.ApplyPattern(standardPattern)
          var df2: DecimalFormat = DecimalFormat("#", dfs)
df2.ApplyLocalizedPattern(localizedPattern)
assertEquals("DecimalFormat instances should be equal", df1, df2)
assertEquals("toPattern should match on localizedPattern instance", standardPattern, df2.ToPattern)
assertEquals("toLocalizedPattern should match on standardPattern instance", localizedPattern, df1.ToLocalizedPattern)
++i
proc TestParseNull*() =
    var df: DecimalFormat = DecimalFormat
    try:
df.Parse(nil)
fail("df.Parse(null) didn't throw an exception")
    except ArgumentNullException:

    try:
df.Parse(nil, nil)
fail("df.Parse(null) didn't throw an exception")
    except ArgumentNullException:

    try:
df.ParseCurrency(nil, nil)
fail("df.Parse(null) didn't throw an exception")
    except ArgumentNullException:

proc TestWhiteSpaceParsing*() =
    var US: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-US"))
    var fmt: DecimalFormat = DecimalFormat("a  b#0c  ", US)
    var n: int = 1234
expect(fmt, "a b1234c ", n)
expect(fmt, "a   b1234c   ", n)
expect(fmt, "ab1234", n)
fmt.ApplyPattern("a b #")
expect(fmt, "ab1234", n)
expect(fmt, "ab  1234", n)
expect(fmt, "a b1234", n)
expect(fmt, "a   b1234", n)
expect(fmt, " a b 1234", n)
expect(fmt, "	a b 1234", n)
expect(fmt, "a        b1234", n)
expectParseException(fmt, "
ab1234", n)
expectParseException(fmt, "a    
   b1234", n)
expectParseException(fmt, "a       b1234", n)
expectParseException(fmt, "a        b1234", n)
    var blanks: UnicodeSet = UnicodeSet("[[:Zs:][\u0009]]").Freeze
    for space in blanks:
        var str: string = "a  " + space + "  b1234"
expect(fmt, str, n)
    var otherWhitespace: UnicodeSet = UnicodeSet("[[:whitespace:]]").ExceptWith(blanks).Freeze
    for space in otherWhitespace:
        var str: string = "a  " + space + "  b1234"
expectParseException(fmt, str, n)
proc TestComplexCurrency*() =

proc TestCurrencyKeyword*() =
    var locale: UCultureInfo = UCultureInfo("th_TH@currency=QQQ")
    var format: NumberFormat = NumberFormat.GetCurrencyInstance(locale)
    var result: String = format.Format(12.34)
    if !"QQQ 12.34".Equals(result, StringComparison.Ordinal):
Errln("got unexpected currency: " + result)
type
  TestNumberingSystemItem = ref object
    localeName: String
    value: double
    isRBNF: bool
    expectedResult: String

proc newTestNumberingSystemItem(loc: String, val: double, rbnf: bool, exp: String): TestNumberingSystemItem =
  localeName = loc
  value = val
  isRBNF = rbnf
  expectedResult = exp
proc TestNumberingSystems*() =
    var DATA: TestNumberingSystemItem[] = @[TestNumberingSystemItem("en_US@numbers=thai", 1234.567, false, "๑,๒๓๔.๕๖๗"), TestNumberingSystemItem("en_US@numbers=thai", 1234.567, false, "๑,๒๓๔.๕๖๗"), TestNumberingSystemItem("en_US@numbers=hebr", 5678.0, true, "ה׳תרע״ח"), TestNumberingSystemItem("en_US@numbers=arabext", 1234.567, false, "۱٬۲۳۴٫۵۶۷"), TestNumberingSystemItem("de_DE@numbers=foobar", 1234.567, false, "1.234,567"), TestNumberingSystemItem("ar_EG", 1234.567, false, "١٬٢٣٤٫٥٦٧"), TestNumberingSystemItem("th_TH@numbers=traditional", 1234.567, false, "๑,๒๓๔.๕๖๗"), TestNumberingSystemItem("ar_MA", 1234.567, false, "1.234,567"), TestNumberingSystemItem("en_US@numbers=hanidec", 1234.567, false, "一,二三四.五六七"), TestNumberingSystemItem("ta_IN@numbers=native", 1234.567, false, "௧,௨௩௪.௫௬௭"), TestNumberingSystemItem("ta_IN@numbers=traditional", 1235.0, true, "௲௨௱௩௰௫"), TestNumberingSystemItem("ta_IN@numbers=finance", 1234.567, false, "1,234.567"), TestNumberingSystemItem("zh_TW@numbers=native", 1234.567, false, "一,二三四.五六七"), TestNumberingSystemItem("zh_TW@numbers=traditional", 1234.567, true, "一千二百三十四點五六七"), TestNumberingSystemItem("zh_TW@numbers=finance", 1234.567, true, "壹仟貳佰參拾肆點伍陸柒"), TestNumberingSystemItem("en_US@numbers=mathsanb", 1234.567, false, "𝟭,𝟮𝟯𝟰.𝟱𝟲𝟳")]
    for item in DATA:
        var loc: UCultureInfo = UCultureInfo(item.localeName)
        var fmt: NumberFormat = NumberFormat.GetInstance(loc)
        if item.isRBNF:
expect3(fmt, item.value, item.expectedResult)
        else:
expect2(fmt, item.value, item.expectedResult)
proc TestNumberingSystemCoverage*() =
    var availableNames: string[] = NumberingSystem.GetAvailableNames
    if availableNames == nil || availableNames.Length <= 0:
Errln("ERROR: NumberingSystem.getAvailableNames() returned a null or empty array.")
    else:
        var latnFound: bool = false
        for name in availableNames:
            if "latn".Equals(name, StringComparison.Ordinal):
                latnFound = true
                break
        if !latnFound:
Errln("ERROR: 'latn' numbering system not found on NumberingSystem.getAvailableNames().")
    var ns1: NumberingSystem = NumberingSystem.GetInstance
    if ns1 == nil || ns1.IsAlgorithmic:
Errln("ERROR: NumberingSystem.GetInstance() returned a null or invalid NumberingSystem")
    var ns2: NumberingSystem = NumberingSystem.GetInstance(10, false, "0123456789")
    if ns2 == nil || ns2.IsAlgorithmic:
Errln("ERROR: NumberingSystem.GetInstance(int,bool,String) returned a null or invalid NumberingSystem")
    var ns3: NumberingSystem = NumberingSystem.GetInstance(CultureInfo("en"))
    if ns3 == nil || ns3.IsAlgorithmic:
Errln("ERROR: NumberingSystem.GetInstance(Locale) returned a null or invalid NumberingSystem")
proc Test6816*() =
    var cur1: Currency = Currency.GetInstance(CultureInfo("und-PH"))
    var nfmt: NumberFormat = NumberFormat.GetCurrencyInstance(CultureInfo("und-PH"))
    var decsym: DecimalFormatSymbols = cast[DecimalFormat](nfmt).GetDecimalFormatSymbols
    var cur2: Currency = decsym.Currency
    if !cur1.CurrencyCode.Equals("PHP", StringComparison.Ordinal) || !cur2.CurrencyCode.Equals("PHP", StringComparison.Ordinal):
Errln("FAIL: Currencies should match PHP: cur1 = " + cur1.CurrencyCode + "; cur2 = " + cur2.CurrencyCode)
type
  FormatTask = ref object
    fmt: DecimalFormat
    buf: StringBuffer
    inc: bool
    num: float

proc newFormatTask(fmt: DecimalFormat, index: int): FormatTask =
  self.fmt = fmt
  self.buf = StringBuffer
  self.inc = index & 1 == 0
  self.num =   if inc:
0
  else:
10000
proc Run*() =
    if inc:
        while num < 10000:
buf.Append(fmt.Format(num) + "
")
            num = 3.14159
    else:
        while num > 0:
buf.Append(fmt.Format(num) + "
")
            num = 3.14159
proc Result(): string =
    return buf.ToString
proc TestThreadedFormat*() =
    var fmt: DecimalFormat = DecimalFormat("0.####")
    var formatTasks: FormatTask[] = seq[FormatTask]
    var tasks: Action[] = seq[Action]
      var i: int = 0
      while i < tasks.Length:
          formatTasks[i] = FormatTask(fmt, i)
          tasks[i] = formatTasks[i].Run
++i
TestUtil.RunUntilDone(tasks)
      var i: int = 2
      while i < formatTasks.Length:
          var str1: String = formatTasks[i].Result
          var str2: String = formatTasks[i - 2].Result
          if !str1.Equals(str2):
Console.Out.WriteLine("mismatch at " + i)
Console.Out.WriteLine(str1)
Console.Out.WriteLine(str2)
Errln("decimal format thread mismatch")
              break
          str1 = str2
++i
proc TestPerMill*() =
    var fmt: DecimalFormat = DecimalFormat("###.###‰")
assertEquals("0.4857 x ###.###‰", "485.7‰", fmt.Format(0.4857))
    var sym: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en"))
    sym.PerMill = 'm'
    var fmt2: DecimalFormat = DecimalFormat("", sym)
fmt2.ApplyLocalizedPattern("###.###m")
assertEquals("0.4857 x ###.###m", "485.7m", fmt2.Format(0.4857))
proc TestIllegalPatterns*() =
    var DATA: string[] = @["-:000.000|###", "+:000.000'|###'"]
      var i: int = 0
      while i < DATA.Length:
          var pat: string = DATA[i]
          var valid: bool = pat[0] == '+'
          pat = pat.Substring(2)
          var e: Exception = nil
          try:
DecimalFormat(pat)
          except FormatException:
              e = e1
          var msg: String =           if e == nil:
"success"
          else:
e.Message
          if e == nil == valid:
Logln("Ok: pattern "" + pat + "": " + msg)
          else:
Errln("FAIL: pattern "" + pat + "" should have " +               if valid:
"succeeded"
              else:
"failed" + "; got " + msg)
++i
proc parseCurrencyAmount(str: String, fmt: NumberFormat, delim: char): CurrencyAmount =
    var i: int = str.IndexOf(delim)
    return CurrencyAmount(fmt.Parse(str.Substring(0, i)), Currency.GetInstance(str.Substring(i + 1)))
proc keywordIndex(tok: string): int =
      var i: int = 0
      while i < KEYWORDS.Length:
          if tok.Equals(KEYWORDS[i], StringComparison.Ordinal):
              return i
++i
    return -1
proc TestCases*() =

proc TestFieldPositionDecimal*() =
    var nf: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(UCultureInfo("en")))
    nf.PositivePrefix = "FOO"
    nf.PositiveSuffix = "BA"
    var buffer: StringBuffer = StringBuffer
    var fp: FieldPosition = FieldPosition(NumberFormatField.DecimalSeparator)
nf.Format(35.47, buffer, fp)
assertEquals("35.47", "FOO35.47BA", buffer.ToString)
assertEquals("fp begin", 5, fp.BeginIndex)
assertEquals("fp end", 6, fp.EndIndex)
proc TestFieldPositionInteger*() =
    var nf: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(UCultureInfo("en")))
    nf.PositivePrefix = "FOO"
    nf.PositiveSuffix = "BA"
    var buffer: StringBuffer = StringBuffer
    var fp: FieldPosition = FieldPosition(NumberFormatField.Integer)
nf.Format(35.47, buffer, fp)
assertEquals("35.47", "FOO35.47BA", buffer.ToString)
assertEquals("fp begin", 3, fp.BeginIndex)
assertEquals("fp end", 5, fp.EndIndex)
proc TestFieldPositionFractionButInteger*() =
    var nf: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(UCultureInfo("en")))
    nf.PositivePrefix = "FOO"
    nf.PositiveSuffix = "BA"
    var buffer: StringBuffer = StringBuffer
    var fp: FieldPosition = FieldPosition(NumberFormatField.Fraction)
nf.Format(35, buffer, fp)
assertEquals("35", "FOO35BA", buffer.ToString)
assertEquals("fp begin", 5, fp.BeginIndex)
assertEquals("fp end", 5, fp.EndIndex)
proc TestFieldPositionFraction*() =
    var nf: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(UCultureInfo("en")))
    nf.PositivePrefix = "FOO"
    nf.PositiveSuffix = "BA"
    var buffer: StringBuffer = StringBuffer
    var fp: FieldPosition = FieldPosition(NumberFormatField.Fraction)
nf.Format(35.47, buffer, fp)
assertEquals("35.47", "FOO35.47BA", buffer.ToString)
assertEquals("fp begin", 6, fp.BeginIndex)
assertEquals("fp end", 8, fp.EndIndex)
proc TestFieldPositionCurrency*() =
    var nf: DecimalFormat = cast[DecimalFormat](NumberFormat.GetCurrencyInstance(CultureInfo("en-US")))
    var amount: double = 35.47
    var negAmount: double = -34.567
    var cp: FieldPosition = FieldPosition(NumberFormatField.Currency)
    var buffer0: StringBuffer = StringBuffer
nf.Format(amount, buffer0, cp)
assertEquals("$35.47", "$35.47", buffer0.ToString)
assertEquals("cp begin", 0, cp.BeginIndex)
assertEquals("cp end", 1, cp.EndIndex)
    var buffer01: StringBuffer = StringBuffer
nf.Format(negAmount, buffer01, cp)
assertEquals("-$34.57", "-$34.57", buffer01.ToString)
assertEquals("cp begin", 1, cp.BeginIndex)
assertEquals("cp end", 2, cp.EndIndex)
    nf.Currency = Currency.GetInstance(CultureInfo("fr-FR"))
    var buffer1: StringBuffer = StringBuffer
nf.Format(amount, buffer1, cp)
assertEquals("€35.47", "€35.47", buffer1.ToString)
assertEquals("cp begin", 0, cp.BeginIndex)
assertEquals("cp end", 1, cp.EndIndex)
    nf.Currency = Currency.GetInstance(CultureInfo("fr-ch"))
    var buffer2: StringBuffer = StringBuffer
nf.Format(amount, buffer2, cp)
assertEquals("CHF 35.47", "CHF 35.47", buffer2.ToString)
assertEquals("cp begin", 0, cp.BeginIndex)
assertEquals("cp end", 3, cp.EndIndex)
    var buffer20: StringBuffer = StringBuffer
nf.Format(negAmount, buffer20, cp)
assertEquals("-CHF 34.57", "-CHF 34.57", buffer20.ToString)
assertEquals("cp begin", 1, cp.BeginIndex)
assertEquals("cp end", 4, cp.EndIndex)
    nf = cast[DecimalFormat](NumberFormat.GetCurrencyInstance(CultureInfo("fr-FR")))
    var buffer3: StringBuffer = StringBuffer
nf.Format(amount, buffer3, cp)
assertEquals("35,47 €", "35,47 €", buffer3.ToString)
assertEquals("cp begin", 6, cp.BeginIndex)
assertEquals("cp end", 7, cp.EndIndex)
    var buffer4: StringBuffer = StringBuffer
nf.Format(negAmount, buffer4, cp)
assertEquals("-34,57 €", "-34,57 €", buffer4.ToString)
assertEquals("cp begin", 7, cp.BeginIndex)
assertEquals("cp end", 8, cp.EndIndex)
    nf.Currency = Currency.GetInstance(CultureInfo("fr-ch"))
    var buffer5: StringBuffer = StringBuffer
nf.Format(negAmount, buffer5, cp)
assertEquals("-34,57 CHF", "-34,57 CHF", buffer5.ToString)
assertEquals("cp begin", 7, cp.BeginIndex)
assertEquals("cp end", 10, cp.EndIndex)
    var plCurrencyFmt: NumberFormat = NumberFormat.GetInstance(CultureInfo("fr-ch"), NumberFormatStyle.PluralCurrencyStyle)
    var buffer6: StringBuffer = StringBuffer
plCurrencyFmt.Format(negAmount, buffer6, cp)
assertEquals("-34.57 francs suisses", "-34.57 francs suisses", buffer6.ToString)
assertEquals("cp begin", 7, cp.BeginIndex)
assertEquals("cp end", 21, cp.EndIndex)
    plCurrencyFmt = NumberFormat.GetInstance(CultureInfo("ja-ch"), NumberFormatStyle.PluralCurrencyStyle)
    var buffer7: StringBuffer = StringBuffer
plCurrencyFmt.Format(amount, buffer7, cp)
assertEquals("35.47 スイス フラン", "35.47 スイス フラン", buffer7.ToString)
assertEquals("cp begin", 6, cp.BeginIndex)
assertEquals("cp end", 13, cp.EndIndex)
    plCurrencyFmt = NumberFormat.GetInstance(CultureInfo("ja-de"), NumberFormatStyle.PluralCurrencyStyle)
    var buffer8: StringBuffer = StringBuffer
plCurrencyFmt.Format(negAmount, buffer8, cp)
assertEquals("-34.57 ユーロ", "-34.57 ユーロ", buffer8.ToString)
assertEquals("cp begin", 7, cp.BeginIndex)
assertEquals("cp end", 10, cp.EndIndex)
    nf = cast[DecimalFormat](NumberFormat.GetCurrencyInstance(CultureInfo("ja-JP")))
    nf.Currency = Currency.GetInstance(CultureInfo("ja-jp"))
    var buffer9: StringBuffer = StringBuffer
nf.Format(negAmount, buffer9, cp)
assertEquals("-￥35", "-￥35", buffer9.ToString)
assertEquals("cp begin", 1, cp.BeginIndex)
assertEquals("cp end", 2, cp.EndIndex)
    plCurrencyFmt = NumberFormat.GetInstance(CultureInfo("ja-ch"), NumberFormatStyle.PluralCurrencyStyle)
    var buffer10: StringBuffer = StringBuffer
plCurrencyFmt.Format(negAmount, buffer10, cp)
assertEquals("-34.57 スイス フラン", "-34.57 スイス フラン", buffer10.ToString)
assertEquals("cp begin", 7, cp.BeginIndex)
assertEquals("cp end", 14, cp.EndIndex)
    nf = cast[DecimalFormat](NumberFormat.GetCurrencyInstance(CultureInfo("ar-eg")))
    plCurrencyFmt = NumberFormat.GetInstance(CultureInfo("ar-eg"), NumberFormatStyle.PluralCurrencyStyle)
    var buffer11: StringBuffer = StringBuffer
plCurrencyFmt.Format(negAmount, buffer11, cp)
assertEquals("؜-٣٤٫٥٧ جنيه مصري", "؜-٣٤٫٥٧ جنيه مصري", buffer11.ToString)
assertEquals("cp begin", 8, cp.BeginIndex)
assertEquals("cp end", 17, cp.EndIndex)
proc TestRounding*() =
    var nf: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(UCultureInfo("en")))
    if false:
        nf.RoundingMode = Numerics.BigMath.RoundingMode.HalfUp
checkRounding(nf, BigDecimal.Parse("300.0300000000", CultureInfo.InvariantCulture), 0, BigDecimal.Parse("0.020000000", CultureInfo.InvariantCulture))
    var roundingIncrements: int[] = @[1, 2, 5, 20, 50, 100]
    var testValues: int[] = @[0, 300]
      var j: int = 0
      while j < testValues.Length:
            var mode: int = cast[int](Numerics.BigMath.RoundingMode.Up)
            while mode < cast[int](Numerics.BigMath.RoundingMode.HalfEven):
                nf.RoundingMode = cast[Numerics.BigMath.RoundingMode](mode)
                  var increment: int = 0
                  while increment < roundingIncrements.Length:
                      var @base: BigDecimal = BigDecimal(testValues[j])
                      var rInc: BigDecimal = BigDecimal(roundingIncrements[increment])
checkRounding(nf, @base, 20, rInc)
                      rInc = BigDecimal.Parse("1.000000000", CultureInfo.InvariantCulture) / rInc
checkRounding(nf, @base, 20, rInc)
++increment
++mode
++j
type
  TestRoundingPatternItem = ref object
    pattern: String
    roundingIncrement: BigDecimal
    testCase: double
    expected: String

proc newTestRoundingPatternItem(pattern: String, roundingIncrement: BigDecimal, testCase: double, expected: String): TestRoundingPatternItem =
  self.pattern = pattern
  self.roundingIncrement = roundingIncrement
  self.testCase = testCase
  self.expected = expected
proc TestRoundingPattern*() =
    var tests: TestRoundingPatternItem[] = @[TestRoundingPatternItem("##0.65", BigDecimal.Parse("0.65", CultureInfo.InvariantCulture), 1.234, "1.30"), TestRoundingPatternItem("#50", BigDecimal.Parse("50", CultureInfo.InvariantCulture), 1230, "1250")]
    var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(UCultureInfo("en")))
    var result: String
      var i: int = 0
      while i < tests.Length:
df.ApplyPattern(tests[i].pattern)
          result = df.Format(tests[i].testCase)
          if !tests[i].expected.Equals(result, StringComparison.Ordinal):
Errln("String Pattern Rounding Test Failed: Pattern: "" + tests[i].pattern + "" Number: " + tests[i].testCase + " - Got: " + result + " Expected: " + tests[i].expected)
df.SetRoundingIncrement(tests[i].roundingIncrement)
          result = df.Format(tests[i].testCase)
          if !tests[i].expected.Equals(result, StringComparison.Ordinal):
Errln("BigDecimal Rounding Test Failed: Pattern: "" + tests[i].pattern + "" Number: " + tests[i].testCase + " - Got: " + result + " Expected: " + tests[i].expected)
++i
proc TestBigDecimalRounding*() =
    var figure: String = "50.000000004"
    var dbl: Double = Double.Parse(figure, CultureInfo.InvariantCulture)
    var dec: BigDecimal = BigDecimal.Parse(figure, CultureInfo.InvariantCulture)
    var f: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance)
f.ApplyPattern("00.00######")
assertEquals("double format", "50.00", f.Format(dbl))
assertEquals("bigdec format", "50.00", f.Format(dec))
    var maxFracDigits: int = f.MaximumFractionDigits
    var roundingIncrement: BigDecimal = BigDecimal.Parse("1", CultureInfo.InvariantCulture).MovePointLeft(maxFracDigits)
f.SetRoundingIncrement(roundingIncrement)
    f.RoundingMode = Numerics.BigMath.RoundingMode.Down
assertEquals("Rounding down", f.Format(dbl), f.Format(dec))
f.SetRoundingIncrement(roundingIncrement)
    f.RoundingMode = Numerics.BigMath.RoundingMode.HalfUp
assertEquals("Rounding half up", f.Format(dbl), f.Format(dec))
proc checkRounding(nf: DecimalFormat, @base: BigDecimal, iterations: int, increment: BigDecimal) =
nf.SetRoundingIncrement(increment.ToBigDecimal)
    var lastParsed: BigDecimal = BigDecimal(int.MinValue)
      var i: int = -iterations
      while i <= iterations:
          var iValue: BigDecimal = @base.Add(increment.Multiply(BigDecimal(i)).MovePointLeft(1))
          var smallIncrement: BigDecimal = BigDecimal.Parse("0.00000001", CultureInfo.InvariantCulture)
          if iValue.Sign != 0:
smallIncrement.Multiply(iValue)
          lastParsed = checkRound(nf, iValue - smallIncrement, lastParsed)
          lastParsed = checkRound(nf, iValue, lastParsed)
          lastParsed = checkRound(nf, iValue + smallIncrement, lastParsed)
++i
proc checkRound(nf: DecimalFormat, iValue: BigDecimal, lastParsed: BigDecimal): BigDecimal =
    var formatedBigDecimal: String = nf.Format(iValue)
    var formattedDouble: String = nf.Format(iValue.ToDouble)
    if !equalButForTrailingZeros(formatedBigDecimal, formattedDouble):
Errln("Failure at: " + iValue + " (" + iValue.ToDouble + ")" + ",	Rounding-mode: " + roundingModeNames[cast[int](nf.RoundingMode)] + ",	Rounding-increment: " + nf.RoundingIncrement + ",	double: " + formattedDouble + ",	BigDecimal: " + formatedBigDecimal)
    else:
Logln("Value: " + iValue + ",	Rounding-mode: " + roundingModeNames[cast[int](nf.RoundingMode)] + ",	Rounding-increment: " + nf.RoundingIncrement + ",	double: " + formattedDouble + ",	BigDecimal: " + formatedBigDecimal)
    try:
        var parsed: BigDecimal = toBigDecimal(nf.Parse(formatedBigDecimal))
        if lastParsed.CompareTo(parsed) > 0:
Errln("Rounding wrong direction!: " + lastParsed + " > " + parsed)
        lastParsed = parsed
    except FormatException:
Errln("Parse Failure with: " + formatedBigDecimal)
    return lastParsed
proc toBigDecimal(number: Number): BigDecimal =
    return     if number:
bigDecimal
    else:
        if number:
BigDecimal(bigInteger)
        else:
            if number:
BigDecimal(bigDecimal2)
            else:
                if number is Double:
BigDecimal(number.ToDouble)
                else:
                    if number is Float:
BigDecimal(number.ToSingle)
                    else:
BigDecimal(number.ToInt64)
proc equalButForTrailingZeros(formatted1: string, formatted2: string): bool =
    if formatted1.Length == formatted2.Length:
      return formatted1.Equals(formatted2, StringComparison.Ordinal)
    return stripFinalZeros(formatted1).Equals(stripFinalZeros(formatted2), StringComparison.Ordinal)
proc stripFinalZeros(formatted: string): string =
    var len1: int = formatted.Length
    var ch: char
    while len1 > 0 &&     ch = formatted[len1 - 1] == '0' || ch == '.':
--len1
    if len1 == 1 &&     ch = formatted[len1 - 1] == '-':
--len1
    return formatted.Substring(0, len1)
proc expect2(fmt: NumberFormat, n: Number, exp: string) =
expect(fmt, n, exp, false)
expect(fmt, exp, n)
proc expect3(fmt: NumberFormat, n: Number, exp: String) =
expect_rbnf(fmt, n, exp, false)
expect_rbnf(fmt, exp, n)
proc expect2(fmt: NumberFormat, n: double, exp: String) =
expect2(fmt, cast[Number](Double.GetInstance(n)), exp)
proc expect3(fmt: NumberFormat, n: double, exp: String) =
expect3(fmt, cast[Number](Double.GetInstance(n)), exp)
proc expect2(fmt: NumberFormat, n: long, exp: String) =
expect2(fmt, cast[Number](Long.GetInstance(n)), exp)
proc expect3(fmt: NumberFormat, n: long, exp: String) =
expect3(fmt, cast[Number](Long.GetInstance(n)), exp)
proc expect(fmt: NumberFormat, n: Number, exp: String, rt: bool) =
    var saw: StringBuffer = StringBuffer
    var pos: FieldPosition = FieldPosition(0)
fmt.Format(n, saw, pos)
    var pat: String = cast[DecimalFormat](fmt).ToPattern
    if saw.ToString.Equals(exp, StringComparison.Ordinal):
Logln("Ok   " + n + " x " + pat + " = "" + saw + """)
        if rt:
            try:
                var n2: Number = fmt.Parse(exp)
                var saw2: StringBuffer = StringBuffer
fmt.Format(n2, saw2, pos)
                if !saw2.ToString.Equals(exp, StringComparison.Ordinal):
Errln("expect() format test rt, locale " + fmt.ValidCulture + ", FAIL "" + exp + "" => " + n2 + " => "" + saw2 + '"')
            except FormatException:
Errln("expect() format test rt, locale " + fmt.ValidCulture + ", " + e.Message)
                return
    else:
Errln("expect() format test, locale " + fmt.ValidCulture + ", FAIL " + n + " x " + pat + " = "" + saw + "", expected "" + exp + """)
proc expect_rbnf(fmt: NumberFormat, n: Number, exp: string, rt: bool) =
    var saw: StringBuffer = StringBuffer
    var pos: FieldPosition = FieldPosition(0)
fmt.Format(n, saw, pos)
    if saw.ToString.Equals(exp, StringComparison.Ordinal):
Logln("Ok   " + n + " = "" + saw + """)
        if rt:
            try:
                var n2: Number = fmt.Parse(exp)
                var saw2: StringBuffer = StringBuffer
fmt.Format(n2, saw2, pos)
                if !saw2.ToString.Equals(exp, StringComparison.Ordinal):
Errln("expect_rbnf() format test rt, locale " + fmt.ValidCulture + ", FAIL "" + exp + "" => " + n2 + " => "" + saw2 + '"')
            except FormatException:
Errln("expect_rbnf() format test rt, locale " + fmt.ValidCulture + ", " + e.Message)
                return
    else:
Errln("expect_rbnf() format test, locale " + fmt.ValidCulture + ", FAIL " + n + " = "" + saw + "", expected "" + exp + """)
proc expect(fmt: NumberFormat, n: Number, exp: string) =
expect(fmt, n, exp, true)
proc expect(fmt: NumberFormat, n: double, exp: string) =
expect(fmt, cast[Number](Double.GetInstance(n)), exp)
proc expect(fmt: NumberFormat, n: long, exp: string) =
expect(fmt, cast[Number](Long.GetInstance(n)), exp)
proc expect(fmt: NumberFormat, str: string, n: Number) =
    var num: Number = nil
    try:
        num = fmt.Parse(str)
    except FormatException:
Errln(e.Message)
        return
    var pat: string = cast[DecimalFormat](fmt).ToPattern
    if num.Equals(n) || num.ToDouble == n.ToDouble:
Logln("Ok   "" + str + "" x " + pat + " = " + num)
    else:
Errln("expect() parse test, locale " + fmt.ValidCulture + ", FAIL "" + str + "" x " + pat + " = " + num + ", expected " + n)
proc expect_rbnf(fmt: NumberFormat, str: string, n: Number) =
    var num: Number = nil
    try:
        num = fmt.Parse(str)
    except FormatException:
Errln(e.Message)
        return
    if num.Equals(n) || num.ToDouble == n.ToDouble:
Logln("Ok   "" + str + " = " + num)
    else:
Errln("expect_rbnf() parse test, locale " + fmt.ValidCulture + ", FAIL "" + str + " = " + num + ", expected " + n)
proc expect(fmt: NumberFormat, str: string, n: double) =
expect(fmt, str, cast[Number](Double.GetInstance(n)))
proc expect(fmt: NumberFormat, str: string, n: long) =
expect(fmt, str, cast[Number](Long.GetInstance(n)))
proc expectParseException(fmt: DecimalFormat, str: string, n: double) =
expectParseException(fmt, str, cast[Number](Double.GetInstance(n)))
proc expectParseException(fmt: DecimalFormat, str: string, n: long) =
expectParseException(fmt, str, cast[Number](Long.GetInstance(n)))
proc expectParseException(fmt: DecimalFormat, str: string, n: Number) =
    var num: Number = nil
    try:
        num = fmt.Parse(str)
Errln("Expected failure, but passed: " + n + " on " + fmt.ToPattern + " -> " + num)
    except FormatException:

proc expectCurrency(nf: NumberFormat, curr: Currency, value: double, @string: string) =
    var fmt: DecimalFormat = cast[DecimalFormat](nf)
    if curr != nil:
        fmt.Currency = curr
    var s: string = fmt.Format(value).Replace('�', ' ')
    if s.Equals(@string):
Logln("Ok: " + value + " x " + curr + " => " + s)
    else:
Errln("FAIL: " + value + " x " + curr + " => " + s + ", expected " + @string)
proc expectPad(fmt: DecimalFormat, pat: string, pos: PadPosition) =
expectPad(fmt, pat, pos, 0, cast[char](0))
proc expectPad(fmt: DecimalFormat, pat: string, pos: PadPosition, width: int, pad: char) =
    var apos: PadPosition = cast[PadPosition](0)
    var awidth: int = 0
    var apadStr: char
    try:
fmt.ApplyPattern(pat)
        apos = fmt.PadPosition
        awidth = fmt.FormatWidth
        apadStr = fmt.PadCharacter
    except Exception:
        apos = cast[PadPosition](-1)
        awidth = width
        apadStr = pad
    if apos == pos && awidth == width && apadStr == pad:
Logln("Ok   "" + pat + "" pos=" + apos +         if cast[int](pos) == -1:
""
        else:
" width=" + awidth + " pad=" + apadStr)
    else:
Errln("FAIL "" + pat + "" pos=" + apos + " width=" + awidth + " pad=" + apadStr + ", expected " + pos + " " + width + " " + pad)
proc expectPat(fmt: DecimalFormat, exp: string) =
    var pat: string = fmt.ToPattern
    if pat.Equals(exp, StringComparison.Ordinal):
Logln("Ok   "" + pat + """)
    else:
Errln("FAIL "" + pat + "", expected "" + exp + """)
proc expectParseCurrency(fmt: NumberFormat, expected: Currency, text: string) =
    var pos: ParsePosition = ParsePosition(0)
    var currencyAmount: CurrencyAmount = fmt.ParseCurrency(text, pos)
assertTrue("Parse of " + text + " should have succeeded.", pos.Index > 0)
assertEquals("Currency should be correct.", expected, currencyAmount.Currency)
proc TestJB3832*() =
    var locale: UCultureInfo = UCultureInfo("pt_PT@currency=PTE")
    var format: NumberFormat = NumberFormat.GetCurrencyInstance(locale)
    var curr: Currency = Currency.GetInstance(locale)
Logln("
Name of the currency is: " + curr.GetName(locale, CurrencyNameStyle.LongName,     var _: bool))
    var cAmt: CurrencyAmount = CurrencyAmount(1150.5, curr)
Logln("CurrencyAmount object's hashCode is: " + cAmt.GetHashCode)
    var str: String = format.Format(cAmt)
    var expected: String = "1,150$50 ​"
    if !expected.Equals(str, StringComparison.Ordinal):
Errln("Did not get the expected output Expected: " + expected + " Got: " + str)
proc TestScientificWithGrouping*() =
    var df: DecimalFormat = DecimalFormat("###0.000E0")
    df.IsGroupingUsed = true
expect2(df, 123, "123.0E0")
expect2(df, 1234, "1,234E0")
expect2(df, 12340, "1.234E4")
proc TestStrictParse*() =
    var pass: string[] = @["0", "0 ", "0.", "0,", "0.0", "0. ", "0.100,5", ".00", "1234567", "12345, ", "1,234, ", "1,234,567", "0E", "00", "012", "0,456", "999,999", "-99,999", "-999,999", "-9,999,999"]
    var fail: string[] = @["1,2", ",0", ",1", ",.02", "1,.02", "1,,200", "1,45", "1,45 that", "1,45.34", "1234,567", "12,34,567", "1,23,456,7890"]
    var nf: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(CultureInfo("en")))
runStrictParseBatch(nf, pass, fail)
    var scientificPass: string[] = @["0E2", "1234E2", "1,234E", "00E2"]
    var scientificFail: string[] = @[]
    nf = cast[DecimalFormat](NumberFormat.GetInstance(CultureInfo("en")))
runStrictParseBatch(nf, scientificPass, scientificFail)
    var mixedPass: string[] = @["12,34,567", "12,34,567,", "12,34,567, that", "12,34,567 that"]
    var mixedFail: string[] = @["12,34,56", "12,34,56,", "12,34,56, that ", "12,34,56 that"]
    nf = DecimalFormat("#,##,##0.#")
runStrictParseBatch(nf, mixedPass, mixedFail)
proc runStrictParseBatch(nf: DecimalFormat, pass: seq[string], fail: seq[string]) =
    nf.ParseStrict = false
runStrictParseTests("should pass", nf, pass, true)
runStrictParseTests("should also pass", nf, fail, true)
    nf.ParseStrict = true
runStrictParseTests("should still pass", nf, pass, true)
runStrictParseTests("should fail", nf, fail, false)
proc runStrictParseTests(msg: string, nf: DecimalFormat, tests: seq[string], pass: bool) =
Logln("")
Logln("pattern: '" + nf.ToPattern + "'")
Logln(msg)
      var i: int = 0
      while i < tests.Length:
          var str: string = tests[i]
          var pp: ParsePosition = ParsePosition(0)
          var n: Number = nf.Parse(str, pp)
          var formatted: string =           if n != nil:
nf.Format(n)
          else:
"null"
          var err: string =           if pp.ErrorIndex == -1:
""
          else:
"(error at " + pp.ErrorIndex + ")"
          if err.Length == 0 != pass:
Errln("'" + str + "' parsed '" + str.Substring(0, pp.Index) + "' returned " + n + " formats to '" + formatted + "' " + err)
          else:
              if err.Length > 0:
                  err = "got expected " + err
Logln("'" + str + "' parsed '" + str.Substring(0, pp.Index) + "' returned " + n + " formats to '" + formatted + "' " + err)
++i
proc TestJB5251*() =
    var defaultLocale: UCultureInfo = UCultureInfo.CurrentCulture
    UCultureInfo.CurrentCulture = UCultureInfo("qr_QR")
    try:
NumberFormat.GetInstance
    except Exception:
Errln("Numberformat threw exception for non-existent locale. It should use the default.")
    UCultureInfo.CurrentCulture = defaultLocale
proc TestParseReturnType*() =
    var defaultLong: string[] = @["123", "123.0", "0.0", "-9223372036854775808", "9223372036854775807"]
    var defaultNonLong: string[] = @["12345678901234567890", "9223372036854775808", "-9223372036854775809"]
    var doubles: string[] = @["-0.0", "NaN", "∞"]
    var sym: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-US"))
    var nf: DecimalFormat = DecimalFormat("#.#", sym)
    if nf.ParseToBigDecimal:
Errln("FAIL: isParseDecimal() must return false by default")
      var i: int = 0
      while i < defaultLong.Length:
          try:
              var n: Number = nf.Parse(defaultLong[i])
              if !n is Long:
Errln("FAIL: parse does not return Long instance")
          except FormatException:
Errln("parse of '" + defaultLong[i] + "' threw exception: " + e)
++i
      var i: int = 0
      while i < defaultNonLong.Length:
          try:
              var n: Number = nf.Parse(defaultNonLong[i])
              if n is Long || n is BigDecimal:
Errln("FAIL: parse returned a Long or a BigDecimal")
          except FormatException:
Errln("parse of '" + defaultNonLong[i] + "' threw exception: " + e)
++i
      var i: int = 0
      while i < doubles.Length:
          try:
              var n: Number = nf.Parse(doubles[i])
              if !n is Double:
Errln("FAIL: parse does not return Double instance")
          except FormatException:
Errln("parse of '" + doubles[i] + "' threw exception: " + e)
++i
    nf.ParseToBigDecimal = true
    if !nf.ParseToBigDecimal:
Errln("FAIL: isParseBigDecimal() must return true")
      var i: int = 0
      while i < defaultLong.Length + defaultNonLong.Length:
          var input: String =           if i < defaultLong.Length:
defaultLong[i]
          else:
defaultNonLong[i - defaultLong.Length]
          try:
              var n: Number = nf.Parse(input)
              if !n is BigDecimal:
Errln("FAIL: parse does not return BigDecimal instance")
          except FormatException:
Errln("parse of '" + input + "' threw exception: " + e)
++i
      var i: int = 0
      while i < doubles.Length:
          try:
              var n: Number = nf.Parse(doubles[i])
              if !n is Double:
Errln("FAIL: parse does not return Double instance")
          except FormatException:
Errln("parse of '" + doubles[i] + "' threw exception: " + e)
++i
proc TestNonpositiveMultiplier*() =
    var df: DecimalFormat = DecimalFormat("0")
    try:
        df.Multiplier = 0
Errln("DecimalFormat.setMultiplier(0) did not throw an IllegalArgumentException")
    except ArgumentException:

    try:
        df.Multiplier = -1
        if df.Multiplier != -1:
Errln("DecimalFormat.setMultiplier(-1) did not change the multiplier to -1")
            return
    except ArgumentException:
Errln("DecimalFormat.setMultiplier(-1) threw an IllegalArgumentException")
        return
expect(df, "1122.123", -1122.123)
expect(df, "-1122.123", 1122.123)
expect(df, "1.2", -1.2)
expect(df, "-1.2", 1.2)
expect2(df, long.MaxValue, -BigInteger.GetInstance(long.MaxValue).ToString(CultureInfo.InvariantCulture))
expect2(df, long.MinValue, -BigInteger.GetInstance(long.MinValue).ToString(CultureInfo.InvariantCulture))
expect2(df, long.MaxValue / 2, -BigInteger.GetInstance(long.MaxValue / 2).ToString(CultureInfo.InvariantCulture))
expect2(df, long.MinValue / 2, -BigInteger.GetInstance(long.MinValue / 2).ToString(CultureInfo.InvariantCulture))
expect2(df, BigDecimal.GetInstance(long.MaxValue), -BigDecimal.GetInstance(long.MaxValue).ToString(CultureInfo.InvariantCulture))
expect2(df, BigDecimal.GetInstance(long.MinValue), -BigDecimal.GetInstance(long.MinValue).ToString(CultureInfo.InvariantCulture))
expect2(df, ICU4N.Numerics.BigMath.BigDecimal.GetInstance(long.MaxValue), -ICU4N.Numerics.BigMath.BigDecimal.GetInstance(long.MaxValue).ToString(CultureInfo.InvariantCulture))
expect2(df, ICU4N.Numerics.BigMath.BigDecimal.GetInstance(long.MinValue), -ICU4N.Numerics.BigMath.BigDecimal.GetInstance(long.MinValue).ToString(CultureInfo.InvariantCulture))
proc TestJB5358*() =
    var numThreads: int = 10
    var numstr: String = "12345"
    var expected: double = 12345
    var sym: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-US"))
    var fmt: DecimalFormat = DecimalFormat("#.#", sym)
    var errors: IList<string> = List<string>
    var threads: ParseThreadJB5358[] = seq[ParseThreadJB5358]
      var i: int = 0
      while i < numThreads:
          threads[i] = ParseThreadJB5358(cast[DecimalFormat](fmt.Clone), numstr, expected, errors)
threads[i].Start
++i
      var i: int = 0
      while i < numThreads:
          try:
threads[i].Join
          except ThreadInterruptedException:
Console.Out.WriteLine(ie.ToString)
++i
    if errors.Count != 0:
        var errBuf: StringBuffer = StringBuffer
          var i: int = 0
          while i < errors.Count:
errBuf.Append(errors[i])
errBuf.Append("
")
++i
Errln("FAIL: " + errBuf)
type
  ParseThreadJB5358 = ref object
    decfmt: DecimalFormat
    numstr: string
    expect: double
    errors: IList[string]

proc newParseThreadJB5358(decfmt: DecimalFormat, numstr: string, expect: double, errors: IList[string]): ParseThreadJB5358 =
  self.decfmt = decfmt
  self.numstr = numstr
  self.expect = expect
  self.errors = errors
proc Run*() =
      var i: int = 0
      while i < 10000:
          try:
              var n: Number = decfmt.Parse(numstr)
              if n.ToDouble != expect:
acquire(errors)
                    try:
errors.Add("Bad parse result - expected:" + expect + " actual:" + n.ToDouble)
                    finally:
                      finally:
release(errors)
          except Exception:
acquire(errors)
                try:
errors.Add(t.GetType.FullName + " - " + t.Message)
                finally:
                  finally:
release(errors)
++i
proc TestSetCurrency*() =
    var decf1: DecimalFormatSymbols = DecimalFormatSymbols.GetInstance(UCultureInfo("en-US"))
    var decf2: DecimalFormatSymbols = DecimalFormatSymbols.GetInstance(UCultureInfo("en-US"))
    decf2.CurrencySymbol = "UKD"
    var format1: DecimalFormat = DecimalFormat("000.000", decf1)
    var format2: DecimalFormat = DecimalFormat("000.000", decf2)
    var euro: Currency = Currency.GetInstance("EUR")
    format1.Currency = euro
    format2.Currency = euro
assertEquals("Reset with currency symbol", format1, format2)
proc TestFormat*() =
    var nf: NumberFormat = NumberFormat.GetInstance
    var sb: StringBuffer = StringBuffer("dummy")
    var fp: FieldPosition = FieldPosition(0)
    try:
nf.Format(Long.GetInstance(Long.Parse("0", CultureInfo.InvariantCulture)), sb, fp)
    except Exception:
Errln("NumberFormat.Format(Object number, ...) was not suppose to " + "return an exception for a Long object. Error: " + e)
    try:
nf.Format(cast[object](BigInteger.Parse("0", 10)), sb, fp)
    except Exception:
Errln("NumberFormat.Format(Object number, ...) was not suppose to " + "return an exception for a BigInteger object. Error: " + e)
    try:
nf.Format(cast[Object](ICU4N.Numerics.BigMath.BigDecimal.Parse("0", CultureInfo.InvariantCulture)), sb, fp)
    except Exception:
Errln("NumberFormat.Format(Object number, ...) was not suppose to " + "return an exception for a java.math.BigDecimal object. Error: " + e)
    try:
nf.Format(cast[Object](ICU4N.Numerics.BigDecimal.Parse("0", CultureInfo.InvariantCulture)), sb, fp)
    except Exception:
Errln("NumberFormat.Format(Object number, ...) was not suppose to " + "return an exception for a com.ibm.icu.math.BigDecimal object. Error: " + e)
    try:
        var ca: CurrencyAmount = CurrencyAmount(0.0, Currency.GetInstance(UCultureInfo("en_US")))
nf.Format(cast[Object](ca), sb, fp)
    except Exception:
Errln("NumberFormat.Format(Object number, ...) was not suppose to " + "return an exception for a CurrencyAmount object. Error: " + e)
    try:
nf.Format(0.0, sb, fp)
    except Exception:
Errln("NumberFormat.Format(Object number, ...) was not suppose to " + "to return an exception for a Number object. Error: " + e)
    try:
nf.Format(object, sb, fp)
Errln("NumberFormat.Format(Object number, ...) was suppose to " + "return an exception for an invalid object.")
    except Exception:

    try:
nf.Format("dummy", sb, fp)
Errln("NumberFormat.Format(Object number, ...) was suppose to " + "return an exception for an invalid object.")
    except Exception:

proc TestFormatAbstractImplCoverage*() =
    var df: NumberFormat = DecimalFormat.GetInstance(CultureInfo("en"))
    var cdf: NumberFormat = CompactDecimalFormat.GetInstance(CultureInfo("en"), CompactDecimalFormat.CompactStyle.Short)
    var rbf: NumberFormat = RuleBasedNumberFormat(UCultureInfo("en"), NumberPresentation.SpellOut)
    var sb: StringBuffer = StringBuffer
    var result: string = df.Format(BigDecimal(2000.43), sb, FieldPosition(0)).ToString
    if !"2,000.43".Equals(result):
Errln("DecimalFormat failed. Expected: 2,000.43 - Actual: " + result)
sb.Clear
    result = cdf.Format(BigDecimal(2000.43), sb, FieldPosition(0)).ToString
    if !"2K".Equals(result):
Errln("DecimalFormat failed. Expected: 2K - Actual: " + result)
sb.Clear
    result = rbf.Format(BigDecimal(2000.43), sb, FieldPosition(0)).ToString
    if !"two thousand point four three".Equals(result):
Errln("DecimalFormat failed. Expected: 'two thousand point four three' - Actual: '" + result + "'")
proc TestGetInstance*() =
    var maxStyle: int = cast[int](NumberFormatStyle.StandardCurrencyStyle)
    var invalid_cases: int[] = @[cast[int](NumberFormatStyle.NumberStyle) - 1, cast[int](NumberFormatStyle.NumberStyle) - 2, maxStyle + 1, maxStyle + 2]
      var i: int = cast[int](NumberFormatStyle.NumberStyle)
      while i < maxStyle:
          try:
NumberFormat.GetInstance(cast[NumberFormatStyle](i))
          except Exception:
Errln("NumberFormat.GetInstance(int style) was not suppose to " + "return an exception for passing value of " + i)
++i
      var i: int = 0
      while i < invalid_cases.Length:
          try:
NumberFormat.GetInstance(cast[NumberFormatStyle](invalid_cases[i]))
Errln("NumberFormat.GetInstance(int style) was suppose to " + "return an exception for passing value of " + invalid_cases[i])
          except Exception:

++i
    var localeCases: string[] = @["en-US", "fr-FR", "de-DE", "ja-JP"]
      var i: int = cast[int](NumberFormatStyle.NumberStyle)
      while i < maxStyle:
            var j: int = 0
            while j < localeCases.Length:
                try:
NumberFormat.GetInstance(CultureInfo(localeCases[j]), cast[NumberFormatStyle](i))
                except Exception:
Errln("NumberFormat.GetInstance(Locale inLocale, int style) was not suppose to " + "return an exception for passing value of " + localeCases[j] + ", " + i)
++j
++i
      var i: int = 0
      while i < invalid_cases.Length:
          try:
NumberFormat.GetInstance(cast[UCultureInfo](nil), cast[NumberFormatStyle](invalid_cases[i]))
Errln("NumberFormat.GetInstance(ULocale inLocale, int choice) was not suppose to " + "return an exception for passing value of " + invalid_cases[i])
          except Exception:

++i
type
  TestFactory_X = ref object


proc newTestFactory_X(): TestFactory_X =

proc GetSupportedLocaleNames*(): ICollection<string> =
    return nil
proc CreateFormat*(loc: UCultureInfo, formatType: int): NumberFormat =
    return nil
type
  TestFactory_X1 = ref object


proc newTestFactory_X1(): TestFactory_X1 =

proc GetSupportedLocaleNames*(): ICollection<string> =
    return nil
proc CreateFormat*(loc: CultureInfo, formatType: int): NumberFormat =
    return nil
proc TestNumberFormatFactory*() =
    var tf: TestFactory_X = TestFactory_X
    var tf1: TestFactory_X1 = TestFactory_X1
    if tf.Visible != true:
Errln("NumberFormatFactory.visible() was suppose to return true.")
    if tf.CreateFormat(CultureInfo(""), 0) != nil:
Errln("NumberFormatFactory.createFormat(Locale loc, int formatType) " + "was suppose to return null")
    if tf1.CreateFormat(UCultureInfo(""), 0) != nil:
Errln("NumberFormatFactory.createFormat(ULocale loc, int formatType) " + "was suppose to return null")
type
  TestSimpleNumberFormatFactoryClass = ref object


proc newTestSimpleNumberFormatFactoryClass(): TestSimpleNumberFormatFactoryClass =
newSimpleNumberFormatFactory(CultureInfo(""))
proc TestSimpleNumberFormatFactory*() =
    var tsnff: TestSimpleNumberFormatFactoryClass = TestSimpleNumberFormatFactoryClass
type
  TestGetAvailableLocalesClass = ref object


proc Format(number: double, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer =
    return nil
proc Format(number: long, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer =
    return nil
proc Format(number: BigInteger, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer =
    return nil
proc Format(number: Numerics.BigMath.BigDecimal, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer =
    return nil
proc Format(number: BigDecimal, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer =
    return nil
proc Parse*(text: string, parsePosition: ParsePosition): Number =
    return nil
proc TestGetAvailableLocales*() =
    try:
        var test: TestGetAvailableLocalesClass = TestGetAvailableLocalesClass
NumberFormat.GetCultures(UCultureTypes.AllCultures)
    except Exception:
Errln("NumberFormat.getAvailableLocales() was not suppose to " + "return an exception when getting getting available locales.")
proc TestSetMinimumIntegerDigits*() =
    var nf: NumberFormat = NumberFormat.GetInstance
    var cases: int[][] = @[@[-1, 0], @[0, 1], @[1, 0], @[2, 0], @[2, 1], @[10, 0]]
    var expectedMax: int[] = @[1, 1, 0, 0, 1, 0]
    if cases.Length != expectedMax.Length:
Errln("Can't continue test case method TestSetMinimumIntegerDigits " + "since the test case arrays are unequal.")
    else:
          var i: int = 0
          while i < cases.Length:
              nf.MinimumIntegerDigits = cases[i][0]
              nf.MaximumIntegerDigits = cases[i][1]
              if nf.MaximumIntegerDigits != expectedMax[i]:
Errln("NumberFormat.setMinimumIntegerDigits(int newValue " + "did not return an expected result for parameter " + cases[i][0] + " and " + cases[i][1] + " and expected " + expectedMax[i] + " but got " + nf.MaximumIntegerDigits)
++i
type
  TestRoundingModeClass = ref object


proc Format(number: double, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer =
    return nil
proc Format(number: long, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer =
    return nil
proc Format(number: BigInteger, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer =
    return nil
proc Format(number: Numerics.BigMath.BigDecimal, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer =
    return nil
proc Format(number: BigDecimal, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer =
    return nil
proc Parse*(text: string, parsePosition: ParsePosition): Number =
    return nil
proc TestRoundingMode*() =
    var tgrm: TestRoundingModeClass = TestRoundingModeClass
    try:
        tgrm.RoundingMode = cast[Numerics.BigMath.RoundingMode](0)
Errln("NumberFormat.setRoundingMode(int) was suppose to return an exception")
    except Exception:

    try:
        var _ = tgrm.RoundingMode
Errln("NumberFormat.getRoundingMode() was suppose to return an exception")
    except Exception:

proc TestLenientSymbolParsing*() =
    var fmt: DecimalFormat = DecimalFormat
    var sym: DecimalFormatSymbols = DecimalFormatSymbols
expect(fmt, "12。34", 12.34)
    sym.DecimalSeparator = '�'
fmt.SetDecimalFormatSymbols(sym)
    fmt.ParseStrict = true
expect(fmt, "23。45", 23.45)
    fmt.ParseStrict = false
    sym.DecimalSeparator = '.'
    sym.GroupingSeparator = ','
fmt.SetDecimalFormatSymbols(sym)
expect(fmt, "1,234.56", 1234.56)
    sym.GroupingSeparator = '�'
fmt.SetDecimalFormatSymbols(sym)
expect(fmt, "2｡345.67", 2345.67)
    sym.GroupingSeparator = ','
fmt.SetDecimalFormatSymbols(sym)
    var skipExtSepParse: String = ICUConfig.DecimalFormat_SkipExtendedSeparatorParsing
    if skipExtSepParse.Equals("true", StringComparison.Ordinal):
expect(fmt, "23 456", 23)
    else:
expect(fmt, "12 345", 12345)
proc TestCurrencyFractionDigits*() =
    var value: double = 99.12345
    var cfmt: NumberFormat = NumberFormat.GetCurrencyInstance(UCultureInfo("ja_JP"))
    var text1: String = cfmt.Format(value)
    cfmt.Currency = cfmt.Currency
    var text2: String = cfmt.Format(value)
    if !text1.Equals(text2, StringComparison.Ordinal):
Errln("NumberFormat.Format() should return the same result - text1=" + text1 + " text2=" + text2)
proc TestNegZeroRounding*() =
    var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance)
    df.RoundingMode = Numerics.BigMath.RoundingMode.HalfUp
    df.MinimumFractionDigits = 1
    df.MaximumFractionDigits = 1
    var text1: String = df.Format(-0.01)
df.SetRoundingIncrement(0.1)
    var text2: String = df.Format(-0.01)
    if !text1.Equals(text2, StringComparison.Ordinal):
Errln("NumberFormat.Format() should return the same result - text1=" + text1 + " text2=" + text2)
proc TestCurrencyAmountCoverage*() =
      var ca: CurrencyAmount
      var cb: CurrencyAmount
    try:
        ca = CurrencyAmount(nil, cast[Currency](nil))
Errln("NullPointerException should have been thrown.")
    except ArgumentNullException:

    try:
        ca = CurrencyAmount(cast[Number](Integer.GetInstance(0)), cast[Currency](nil))
Errln("NullPointerException should have been thrown.")
    except ArgumentNullException:

    ca = CurrencyAmount(cast[Number](Integer.GetInstance(0)), Currency.GetInstance(UCultureInfo("ja_JP")))
    cb = CurrencyAmount(cast[Number](Integer.GetInstance(1)), Currency.GetInstance(UCultureInfo("ja_JP")))
    if ca.Equals(nil):
Errln("Comparison should return false.")
    if !ca.Equals(ca):
Errln("Comparision should return true.")
    if ca.Equals(cb):
Errln("Comparison should return false.")
proc TestExponentParse*() =
    var parsePos: ParsePosition = ParsePosition(0)
    var symbols: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-US"))
    var fmt: DecimalFormat = DecimalFormat("#####", symbols)
    var result: Number = fmt.Parse("5.06e-27", parsePos)
    if result.ToDouble != 5.06e-27 || parsePos.Index != 8:
Errln("ERROR: ERROR: parse failed - expected 5.06E-27, 8; got " + result.ToDouble + ", " + parsePos.Index)
proc TestExplicitParents*() =
    var DATA: string[] = @["es", "CO", "", "1.250,75", "es", "ES", "", "1.250,75", "es", "GQ", "", "1.250,75", "es", "MX", "", "1,250.75", "es", "US", "", "1,250.75", "es", "VE", "", "1.250,75"]
      var i: int = 0
      while i < DATA.Length:
          var locale: CultureInfo = CultureInfo(string.Concat(DATA[i], "-", DATA[i + 1]))
          var fmt: NumberFormat = NumberFormat.GetInstance(locale)
          var s: String = fmt.Format(1250.75)
          if s.Equals(DATA[i + 3], StringComparison.Ordinal):
Logln("Ok: 1250.75 x " + locale + " => " + s)
          else:
Errln("FAIL: 1250.75 x " + locale + " => " + s + ", expected " + DATA[i + 3])
          i = 4
proc TestFormatToCharacterIteratorThread*() =
    var COUNT: int = 10
    var fmt1: DecimalFormat = DecimalFormat("#0")
    var fmt2: DecimalFormat = cast[DecimalFormat](fmt1.Clone)
    var res1: int[] = seq[int]
    var res2: int[] = seq[int]
    var t1: ThreadJob = FormatCharItrTestThread(fmt1, 1, res1)
    var t2: ThreadJob = FormatCharItrTestThread(fmt2, 100, res2)
t1.Start
t2.Start
    try:
t1.Join
t2.Join
    except ThreadInterruptedException:

    var val1: int = res1[0]
    var val2: int = res2[0]
      var i: int = 0
      while i < COUNT:
          if res1[i] != val1:
Errln("Inconsistent first run limit in test thread 1")
          if res2[i] != val2:
Errln("Inconsistent first run limit in test thread 2")
++i
type
  FormatCharItrTestThread = ref object
    fmt: NumberFormat
    num: int
    result: seq[int]

proc newFormatCharItrTestThread(fmt: NumberFormat, num: int, result: seq[int]): FormatCharItrTestThread =
  self.fmt = fmt
  self.num = num
  self.result = result
proc Run*() =
      var i: int = 0
      while i < result.Length:
          var acitr: AttributedCharacterIterator = fmt.FormatToCharacterIterator(Integer.GetInstance(num))
acitr.First
          result[i] = acitr.GetRunLimit
++i
proc TestRoundingBehavior*() =
    var TEST_CASES: object[][] = @[@[UCultureInfo("en-US"), "#.##", Integer.GetInstance(cast[int](BigDecimal.RoundDown)), Double.GetInstance(0.0), Double.GetInstance(123.4567), "123.45"], @[UCultureInfo("en-US"), "#.##", nil, Double.GetInstance(0.1), Double.GetInstance(123.4567), "123.5"], @[UCultureInfo("en-US"), "#.##", Integer.GetInstance(cast[int](BigDecimal.RoundDown)), Double.GetInstance(0.1), Double.GetInstance(123.4567), "123.4"], @[UCultureInfo("en-US"), "#.##", Integer.GetInstance(cast[int](BigDecimal.RoundUnnecessary)), nil, Double.GetInstance(123.4567), nil], @[UCultureInfo("en-US"), "#.##", Integer.GetInstance(cast[int](BigDecimal.RoundDown)), nil, Long.GetInstance(1234), "1234"]]
    var testNum: int = 1
    for testCase in TEST_CASES:
        var locale: UCultureInfo =         if testCase[0] == nil:
UCultureInfo.CurrentCulture
        else:
cast[UCultureInfo](testCase[0])
        var pattern: String = cast[String](testCase[1])
        var fmt: DecimalFormat = DecimalFormat(pattern, DecimalFormatSymbols.GetInstance(locale))
        var roundingMode: Integer = nil
        if testCase[2] != nil:
            roundingMode = cast[Integer](testCase[2])
            fmt.RoundingMode = cast[Numerics.BigMath.RoundingMode](roundingMode.ToInt32)
        if testCase[3] != nil:
            if testCase[3]:
fmt.SetRoundingIncrement(dbl)

            elif testCase[3]:
fmt.SetRoundingIncrement(bigDecimal)
            else:
              if testCase[3]:
fmt.SetRoundingIncrement(bigDecimal2)
        var s: String = nil
        var bException: bool = false
        try:
            s = fmt.Format(testCase[4])
        except ArithmeticException:
            bException = true
        if bException:
            if testCase[5] != nil:
Errln("Test case #" + testNum + ": ArithmeticException was thrown.")
        else:
            if testCase[5] == nil:
Errln("Test case #" + testNum + ": ArithmeticException must be thrown, but got formatted result: " + s)
            else:
assertEquals("Test case #" + testNum, testCase[5], s)
++testNum
proc TestSignificantDigits*() =
    var input: double[] = @[0, 0, 123, -123, 12345, -12345, 123.45, -123.45, 123.44501, -123.44501, 0.001234, -0.001234, 1.23e-9, -1.23e-9, 1.23e-20, -1.23e-20, 1.2, -1.2, 1.2344501e-9, -1.2344501e-9, 123445.01, -123445.01, 1.2344501e+34, -1.2344501e+34]
    var expected: string[] = @["0.00", "0.00", "123", "-123", "12345", "-12345", "123.45", "-123.45", "123.45", "-123.45", "0.001234", "-0.001234", "0.00000000123", "-0.00000000123", "0.0000000000000000000123", "-0.0000000000000000000123", "1.20", "-1.20", "0.0000000012345", "-0.0000000012345", "123450", "-123450", "12345000000000000000000000000000000", "-12345000000000000000000000000000000"]
    var numberFormat: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(UCultureInfo("en-US")))
    numberFormat.AreSignificantDigitsUsed = true
    numberFormat.MinimumSignificantDigits = 3
    numberFormat.MaximumSignificantDigits = 5
    numberFormat.IsGroupingUsed = false
      var i: int = 0
      while i < input.Length:
assertEquals("TestSignificantDigits", expected[i], numberFormat.Format(input[i]))
++i
proc TestBug9936*() =
    var numberFormat: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(UCultureInfo("en-US")))
assertFalse("", numberFormat.AreSignificantDigitsUsed)
    numberFormat.AreSignificantDigitsUsed = true
assertTrue("", numberFormat.AreSignificantDigitsUsed)
    numberFormat.AreSignificantDigitsUsed = false
assertFalse("", numberFormat.AreSignificantDigitsUsed)
    numberFormat.MinimumSignificantDigits = 3
assertTrue("", numberFormat.AreSignificantDigitsUsed)
    numberFormat.AreSignificantDigitsUsed = false
    numberFormat.MaximumSignificantDigits = 6
assertTrue("", numberFormat.AreSignificantDigitsUsed)
proc TestShowZero*() =
    var numberFormat: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(UCultureInfo("en-US")))
    numberFormat.AreSignificantDigitsUsed = true
    numberFormat.MaximumSignificantDigits = 3
assertEquals("TestShowZero", "0", numberFormat.Format(0.0))
proc TestCurrencyPlurals*() =
    var tests: string[][] = @[@["en", "USD", "1", "1 US dollar"], @["en", "USD", "1.0", "1.0 US dollars"], @["en", "USD", "1.00", "1.00 US dollars"], @["en", "USD", "1.99", "1.99 US dollars"], @["en", "AUD", "1", "1 Australian dollar"], @["en", "AUD", "1.00", "1.00 Australian dollars"], @["sl", "USD", "1", "1 ameriški dolar"], @["sl", "USD", "2", "2 ameriška dolarja"], @["sl", "USD", "3", "3 ameriški dolarji"], @["sl", "USD", "5", "5 ameriških dolarjev"], @["fr", "USD", "1.99", "1,99 dollar des États-Unis"], @["ru", "RUB", "1", "1 российский рубль"], @["ru", "RUB", "2", "2 российских рубля"], @["ru", "RUB", "5", "5 российских рублей"]]
    for test in tests:
        var numberFormat: DecimalFormat = cast[DecimalFormat](DecimalFormat.GetInstance(UCultureInfo(test[0]), NumberFormatStyle.PluralCurrencyStyle))
        numberFormat.Currency = Currency.GetInstance(test[1])
        var number: double = Double.Parse(test[2], CultureInfo.InvariantCulture)
        var dotPos: int = test[2].IndexOf('.')
        var decimals: int =         if dotPos < 0:
0
        else:
test[2].Length - dotPos - 1
        var digits: int =         if dotPos < 0:
test[2].Length
        else:
test[2].Length - 1
        numberFormat.MaximumFractionDigits = decimals
        numberFormat.MinimumFractionDigits = decimals
        var actual: String = numberFormat.Format(number)
assertEquals(test[0] + "	" + test[1] + "	" + test[2], test[3], actual)
        numberFormat.MaximumSignificantDigits = digits
        numberFormat.MinimumSignificantDigits = digits
        actual = numberFormat.Format(number)
assertEquals(test[0] + "	" + test[1] + "	" + test[2], test[3], actual)
proc TestCustomCurrencySignAndSeparator*() =
    var custom: DecimalFormatSymbols = DecimalFormatSymbols(UCultureInfo("en-US"))
    custom.CurrencySymbol = "*"
    custom.MonetaryGroupingSeparator = '^'
    custom.MonetaryDecimalSeparator = ':'
    var fmt: DecimalFormat = DecimalFormat("¤ #,##0.00", custom)
    var numstr: string = "* 1^234:56"
expect2(fmt, 1234.56, numstr)
type
  SignsAndMarksItem = ref object
    locale: String
    lenient: bool
    numString: String
    value: double

proc newSignsAndMarksItem(loc: String, lnt: bool, numStr: String, val: double): SignsAndMarksItem =
  locale = loc
  lenient = lnt
  numString = numStr
  value = val
proc TestParseSignsAndMarks*() =
    var items: SignsAndMarksItem[] = @[SignsAndMarksItem("en", false, "12", 12), SignsAndMarksItem("en", true, "12", 12), SignsAndMarksItem("en", false, "-23", -23), SignsAndMarksItem("en", true, "-23", -23), SignsAndMarksItem("en", true, "- 23", -23), SignsAndMarksItem("en", false, "‎-23", -23), SignsAndMarksItem("en", true, "‎-23", -23), SignsAndMarksItem("en", true, "‎- 23", -23), SignsAndMarksItem("en@numbers=arab", false, "٣٤", 34), SignsAndMarksItem("en@numbers=arab", true, "٣٤", 34), SignsAndMarksItem("en@numbers=arab", false, "-٤٥", -45), SignsAndMarksItem("en@numbers=arab", true, "-٤٥", -45), SignsAndMarksItem("en@numbers=arab", true, "- ٤٥", -45), SignsAndMarksItem("en@numbers=arab", false, "‏-٤٥", -45), SignsAndMarksItem("en@numbers=arab", true, "‏-٤٥", -45), SignsAndMarksItem("en@numbers=arab", true, "‏- ٤٥", -45), SignsAndMarksItem("en@numbers=arabext", false, "۵۶", 56), SignsAndMarksItem("en@numbers=arabext", true, "۵۶", 56), SignsAndMarksItem("en@numbers=arabext", false, "-۶۷", -67), SignsAndMarksItem("en@numbers=arabext", true, "-۶۷", -67), SignsAndMarksItem("en@numbers=arabext", true, "- ۶۷", -67), SignsAndMarksItem("en@numbers=arabext", false, "‎-‎۶۷", -67), SignsAndMarksItem("en@numbers=arabext", true, "‎-‎۶۷", -67), SignsAndMarksItem("en@numbers=arabext", true, "‎-‎ ۶۷", -67), SignsAndMarksItem("he", false, "12", 12), SignsAndMarksItem("he", true, "12", 12), SignsAndMarksItem("he", false, "-23", -23), SignsAndMarksItem("he", true, "-23", -23), SignsAndMarksItem("he", true, "- 23", -23), SignsAndMarksItem("he", false, "‎-23", -23), SignsAndMarksItem("he", true, "‎-23", -23), SignsAndMarksItem("he", true, "‎- 23", -23), SignsAndMarksItem("ar", false, "٣٤", 34), SignsAndMarksItem("ar", true, "٣٤", 34), SignsAndMarksItem("ar", false, "-٤٥", -45), SignsAndMarksItem("ar", true, "-٤٥", -45), SignsAndMarksItem("ar", true, "- ٤٥", -45), SignsAndMarksItem("ar", false, "‏-٤٥", -45), SignsAndMarksItem("ar", true, "‏-٤٥", -45), SignsAndMarksItem("ar", true, "‏- ٤٥", -45), SignsAndMarksItem("ar_MA", false, "12", 12), SignsAndMarksItem("ar_MA", true, "12", 12), SignsAndMarksItem("ar_MA", false, "-23", -23), SignsAndMarksItem("ar_MA", true, "-23", -23), SignsAndMarksItem("ar_MA", true, "- 23", -23), SignsAndMarksItem("ar_MA", false, "‎-23", -23), SignsAndMarksItem("ar_MA", true, "‎-23", -23), SignsAndMarksItem("ar_MA", true, "‎- 23", -23), SignsAndMarksItem("fa", false, "۵۶", 56), SignsAndMarksItem("fa", true, "۵۶", 56), SignsAndMarksItem("fa", false, "−۶۷", -67), SignsAndMarksItem("fa", true, "−۶۷", -67), SignsAndMarksItem("fa", true, "− ۶۷", -67), SignsAndMarksItem("fa", false, "‎−‎۶۷", -67), SignsAndMarksItem("fa", true, "‎−‎۶۷", -67), SignsAndMarksItem("fa", true, "‎−‎ ۶۷", -67), SignsAndMarksItem("ps", false, "۵۶", 56), SignsAndMarksItem("ps", true, "۵۶", 56), SignsAndMarksItem("ps", false, "-۶۷", -67), SignsAndMarksItem("ps", true, "-۶۷", -67), SignsAndMarksItem("ps", true, "- ۶۷", -67), SignsAndMarksItem("ps", false, "‎-‎۶۷", -67), SignsAndMarksItem("ps", true, "‎-‎۶۷", -67), SignsAndMarksItem("ps", true, "‎-‎ ۶۷", -67), SignsAndMarksItem("ps", false, "-‎۶۷", -67), SignsAndMarksItem("ps", true, "-‎۶۷", -67), SignsAndMarksItem("ps", true, "-‎ ۶۷", -67)]
    for item in items:
        var locale: UCultureInfo = UCultureInfo(item.locale)
        var numfmt: NumberFormat = NumberFormat.GetInstance(locale)
        if numfmt != nil:
            numfmt.ParseStrict = !item.lenient
            var ppos: ParsePosition = ParsePosition(0)
            var num: Number = numfmt.Parse(item.numString, ppos)
            if num != nil && ppos.Index == item.numString.Length:
                var parsedValue: double = num.ToDouble
                if parsedValue != item.value:
Errln("FAIL: locale " + item.locale + ", lenient " + item.lenient + ", parse of "" + item.numString + "" gives value " + parsedValue)
            else:
Errln("FAIL: locale " + item.locale + ", lenient " + item.lenient + ", parse of "" + item.numString + "" gives position " + ppos.Index)
        else:
Errln("FAIL: NumberFormat.getInstance for locale " + item.locale)
proc TestContext*() =
    var nfmt: NumberFormat = NumberFormat.GetInstance
    var context: DisplayContext = nfmt.GetContext(DisplayContextType.Capitalization)
    if context != DisplayContext.CapitalizationNone:
Errln("FAIL: Initial NumberFormat.getContext() is not CAPITALIZATION_NONE")
nfmt.SetContext(DisplayContext.CapitalizationForStandalone)
    context = nfmt.GetContext(DisplayContextType.Capitalization)
    if context != DisplayContext.CapitalizationForStandalone:
Errln("FAIL: NumberFormat.getContext() does not return the value set, CAPITALIZATION_FOR_STANDALONE")
proc TestAccountingCurrency*() =
    var tests: string[][] = @[@["en_US", "1234.5", "$1,234.50", "$1,234.50", "$1,234.50", "true"], @["en_US@cf=account", "1234.5", "$1,234.50", "$1,234.50", "$1,234.50", "true"], @["en_US", "-1234.5", "-$1,234.50", "-$1,234.50", "($1,234.50)", "true"], @["en_US@cf=standard", "-1234.5", "-$1,234.50", "-$1,234.50", "($1,234.50)", "true"], @["en_US@cf=account", "-1234.5", "($1,234.50)", "-$1,234.50", "($1,234.50)", "true"], @["en_US", "0", "$0.00", "$0.00", "$0.00", "true"], @["en_US", "-0.2", "-$0.20", "-$0.20", "($0.20)", "true"], @["en_US@cf=standard", "-0.2", "-$0.20", "-$0.20", "($0.20)", "true"], @["en_US@cf=account", "-0.2", "($0.20)", "-$0.20", "($0.20)", "true"], @["ja_JP", "10000", "￥10,000", "￥10,000", "￥10,000", "true"], @["ja_JP", "-1000.5", "-￥1,000", "-￥1,000", "(￥1,000)", "false"], @["ja_JP@cf=account", "-1000.5", "(￥1,000)", "-￥1,000", "(￥1,000)", "false"], @["de_DE", "-23456.7", "-23.456,70 €", "-23.456,70 €", "-23.456,70 €", "true"]]
    for data in tests:
        var loc: UCultureInfo = UCultureInfo(data[0])
        var num: Double = Double.Parse(data[1], CultureInfo.InvariantCulture)
        var fmtPerLocExpected: String = data[2]
        var fmtStandardExpected: String = data[3]
        var fmtAccountExpected: String = data[4]
        var rt: bool = bool.Parse(data[5])
        var fmtPerLoc: NumberFormat = NumberFormat.GetInstance(loc, NumberFormatStyle.CurrencyStyle)
expect(fmtPerLoc, cast[Number](num), fmtPerLocExpected, rt)
        var fmtStandard: NumberFormat = NumberFormat.GetInstance(loc, NumberFormatStyle.StandardCurrencyStyle)
expect(fmtStandard, cast[Number](num), fmtStandardExpected, rt)
        var fmtAccount: NumberFormat = NumberFormat.GetInstance(loc, NumberFormatStyle.AccountingCurrencyStyle)
expect(fmtAccount, cast[Number](num), fmtAccountExpected, rt)
proc TestCurrencyUsage*() =
      var i: int = 0
      while i < 2:
          var original_expected: String = "PKR 124"
          var custom: DecimalFormat = nil
          if i == 0:
              custom = cast[DecimalFormat](DecimalFormat.GetInstance(UCultureInfo("en_US@currency=PKR"), NumberFormatStyle.CurrencyStyle))
              var original: String = custom.Format(123.567)
assertEquals("Test Currency Context", original_expected, original)
assertEquals("Test Currency Context Purpose", custom.CurrencyUsage, CurrencyUsage.Standard)
              custom.CurrencyUsage = CurrencyUsage.Cash
assertEquals("Test Currency Context Purpose", custom.CurrencyUsage, CurrencyUsage.Cash)
          else:
              custom = cast[DecimalFormat](DecimalFormat.GetInstance(UCultureInfo("en_US@currency=PKR"), NumberFormatStyle.CashCurrencyStyle))
assertEquals("Test Currency Context Purpose", custom.CurrencyUsage, CurrencyUsage.Cash)
          var cash_currency: String = custom.Format(123.567)
          var cash_currency_expected: String = "PKR 124"
assertEquals("Test Currency Context", cash_currency_expected, cash_currency)
++i
      var i: int = 0
      while i < 2:
          var original_rounding_expected: String = "CA$123.57"
          var fmt: DecimalFormat = nil
          if i == 0:
              fmt = cast[DecimalFormat](DecimalFormat.GetInstance(UCultureInfo("en_US@currency=CAD"), NumberFormatStyle.CurrencyStyle))
              var original_rounding: String = fmt.Format(123.566)
assertEquals("Test Currency Context", original_rounding_expected, original_rounding)
              fmt.CurrencyUsage = CurrencyUsage.Cash
          else:
              fmt = cast[DecimalFormat](DecimalFormat.GetInstance(UCultureInfo("en_US@currency=CAD"), NumberFormatStyle.CashCurrencyStyle))
          var cash_rounding_currency: String = fmt.Format(123.567)
          var cash__rounding_currency_expected: String = "CA$123.55"
assertEquals("Test Currency Context", cash__rounding_currency_expected, cash_rounding_currency)
++i
      var i: int = 0
      while i < 2:
          var fmt2: DecimalFormat = nil
          if i == 1:
              fmt2 = cast[DecimalFormat](NumberFormat.GetInstance(UCultureInfo("en_US@currency=JPY"), NumberFormatStyle.CurrencyStyle))
              fmt2.CurrencyUsage = CurrencyUsage.Cash
          else:
              fmt2 = cast[DecimalFormat](NumberFormat.GetInstance(UCultureInfo("en_US@currency=JPY"), NumberFormatStyle.CashCurrencyStyle))
          fmt2.Currency = Currency.GetInstance("PKR")
          var PKR_changed: String = fmt2.Format(123.567)
          var PKR_changed_expected: String = "PKR 124"
assertEquals("Test Currency Context", PKR_changed_expected, PKR_changed)
++i
proc TestCurrencyWithMinMaxFractionDigits*() =
    var df: DecimalFormat = DecimalFormat
df.ApplyPattern("¤#,##0.00")
    df.Currency = Currency.GetInstance("USD")
assertEquals("Basic currency format fails", "$1.23", df.Format(1.234))
    df.MaximumFractionDigits = 4
assertEquals("Currency with max fraction == 4", "$1.234", df.Format(1.234))
    df.MinimumFractionDigits = 4
assertEquals("Currency with min fraction == 4", "$1.2340", df.Format(1.234))
proc TestParseRequiredDecimalPoint*() =
    var testPattern: string[] = @["00.####", "00.0", "00"]
    var value2Parse: String = "99"
    var value2ParseWithDecimal: String = "99.9"
    var parseValue: double = 99
    var parseValueWithDecimal: double = 99.9
    var parser: DecimalFormat = DecimalFormat
    var result: double
    var hasDecimalPoint: bool
      var i: int = 0
      while i < testPattern.Length:
parser.ApplyPattern(testPattern[i])
          hasDecimalPoint = testPattern[i].Contains(".")
          parser.DecimalPatternMatchRequired = false
          try:
              result = parser.Parse(value2Parse).ToDouble
assertEquals("wrong parsed value", parseValue, result)
          except FormatException:
TestFmwk.Errln("Parsing " + value2Parse + " should have succeeded with " + testPattern[i] + " and isDecimalPointMatchRequired set to: " + parser.DecimalPatternMatchRequired)
          try:
              result = parser.Parse(value2ParseWithDecimal).ToDouble
assertEquals("wrong parsed value", parseValueWithDecimal, result)
          except FormatException:
TestFmwk.Errln("Parsing " + value2ParseWithDecimal + " should have succeeded with " + testPattern[i] + " and isDecimalPointMatchRequired set to: " + parser.DecimalPatternMatchRequired)
          parser.DecimalPatternMatchRequired = true
          try:
              result = parser.Parse(value2Parse).ToDouble
              if hasDecimalPoint:
TestFmwk.Errln("Parsing " + value2Parse + " should NOT have succeeded with " + testPattern[i] + " and isDecimalPointMatchRequired set to: " + parser.DecimalPatternMatchRequired)
          except FormatException:

          try:
              result = parser.Parse(value2ParseWithDecimal).ToDouble
              if !hasDecimalPoint:
TestFmwk.Errln("Parsing " + value2ParseWithDecimal + " should NOT have succeeded with " + testPattern[i] + " and isDecimalPointMatchRequired set to: " + parser.DecimalPatternMatchRequired)
          except FormatException:

++i
proc TestCurrFmtNegSameAsPositive*() =
    var decfmtsym: DecimalFormatSymbols = DecimalFormatSymbols.GetInstance(CultureInfo("en-US"))
    decfmtsym.MinusSign = '�'
    var decfmt: DecimalFormat = DecimalFormat("¤#,##0.00;-¤#,##0.00", decfmtsym)
    var currFmtResult: String = decfmt.Format(-100.0)
    if !currFmtResult.Equals("​$100.00", StringComparison.Ordinal):
Errln("decfmt.toPattern results wrong, expected ​$100.00, got " + currFmtResult)
proc TestNumberFormatTestDataToString*() =
DataDrivenNumberFormatTestData.ToString
proc TestFormatToCharacterIteratorIssue11805*() =
    var number: double = -350.76
    var dfUS: DecimalFormat = cast[DecimalFormat](DecimalFormat.GetCurrencyInstance(CultureInfo("en-US")))
    var strUS: String = dfUS.Format(number)
    var resultUS: ICollection<AttributedCharacterIteratorAttribute> = dfUS.FormatToCharacterIterator(cast[Double](number)).GetAllAttributeKeys
assertEquals("Negative US Results: " + strUS, 5, resultUS.Count)
    var dfDE: DecimalFormat = cast[DecimalFormat](DecimalFormat.GetCurrencyInstance(CultureInfo("de-DE")))
    var strDE: String = dfDE.Format(number)
    var resultDE: ICollection<AttributedCharacterIteratorAttribute> = dfDE.FormatToCharacterIterator(cast[Double](number)).GetAllAttributeKeys
assertEquals("Negative DE Results: " + strDE, 5, resultDE.Count)
    var dfIN: DecimalFormat = cast[DecimalFormat](DecimalFormat.GetCurrencyInstance(CultureInfo("hi-in")))
    var strIN: String = dfIN.Format(number)
    var resultIN: ICollection<AttributedCharacterIteratorAttribute> = dfIN.FormatToCharacterIterator(cast[Double](number)).GetAllAttributeKeys
assertEquals("Negative IN Results: " + strIN, 5, resultIN.Count)
    var dfJP: DecimalFormat = cast[DecimalFormat](DecimalFormat.GetCurrencyInstance(CultureInfo("ja-JP")))
    var strJP: String = dfJP.Format(number)
    var resultJP: ICollection<AttributedCharacterIteratorAttribute> = dfJP.FormatToCharacterIterator(cast[Double](number)).GetAllAttributeKeys
assertEquals("Negative JA Results: " + strJP, 3, resultJP.Count)
    var dfGB: DecimalFormat = cast[DecimalFormat](DecimalFormat.GetCurrencyInstance(CultureInfo("en-gb")))
    var strGB: String = dfGB.Format(number)
    var resultGB: ICollection<AttributedCharacterIteratorAttribute> = dfGB.FormatToCharacterIterator(cast[Double](number)).GetAllAttributeKeys
assertEquals("Negative GB Results: " + strGB, 5, resultGB.Count)
    var dfPlural: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(CultureInfo("en-gb"), NumberFormatStyle.PluralCurrencyStyle))
    strGB = dfPlural.Format(number)
    resultGB = dfPlural.FormatToCharacterIterator(cast[Double](number)).GetAllAttributeKeys
assertEquals("Negative GB Results: " + strGB, 5, resultGB.Count)
    strGB = dfPlural.Format(1)
    resultGB = dfPlural.FormatToCharacterIterator(cast[Integer](1)).GetAllAttributeKeys
assertEquals("Negative GB Results: " + strGB, 4, resultGB.Count)
    var auPlural: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(CultureInfo("en-au"), NumberFormatStyle.PluralCurrencyStyle))
    var strAU: String = auPlural.Format(1)
    var resultAU: ICollection<AttributedCharacterIteratorAttribute> = auPlural.FormatToCharacterIterator(cast[Long](1)).GetAllAttributeKeys
assertEquals("Unit AU Result: " + strAU, 4, resultAU.Count)
    var sym: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en-gb"))
    var dfPermille: DecimalFormat = DecimalFormat("####0.##‰", sym)
    strGB = dfPermille.Format(number)
    resultGB = dfPermille.FormatToCharacterIterator(cast[Double](number)).GetAllAttributeKeys
assertEquals("Negative GB Permille Results: " + strGB, 3, resultGB.Count)
proc TestRoundUnnecessarytIssue11808*() =
    var df: DecimalFormat = cast[DecimalFormat](DecimalFormat.GetInstance)
    var result: StringBuffer = StringBuffer("")
    df.RoundingMode = Numerics.BigMath.RoundingMode.Unnecessary
df.ApplyPattern("00.0#E0")
    try:
df.Format(99999.0, result, FieldPosition(0))
fail("Missing ArithmeticException for double: " + result)
    except ArithmeticException:

    try:
        result = df.Format(99999, result, FieldPosition(0))
fail("Missing ArithmeticException for int: " + result)
    except ArithmeticException:

    try:
        result = df.Format(BigInteger.Parse("999999", 10), result, FieldPosition(0))
fail("Missing ArithmeticException for BigInteger: " + result)
    except ArithmeticException:

    try:
        result = df.Format(BigDecimal.Parse("99999", CultureInfo.InvariantCulture), result, FieldPosition(0))
fail("Missing ArithmeticException for BigDecimal: " + result)
    except ArithmeticException:

    try:
        result = df.Format(BigDecimal.Parse("-99999", CultureInfo.InvariantCulture), result, FieldPosition(0))
fail("Missing ArithmeticException for BigDecimal: " + result)
    except ArithmeticException:

proc TestNPEIssue11735*() =
    var fmt: DecimalFormat = DecimalFormat("0", DecimalFormatSymbols(UCultureInfo("en")))
    var ppos: ParsePosition = ParsePosition(0)
assertEquals("Currency symbol missing in parse. Expect null result.", fmt.ParseCurrency("53.45", ppos), nil)
proc CompareAttributedCharacterFormatOutput(iterator: AttributedCharacterIterator, expected: IList[FieldContainer], formattedOutput: String) =
    var result: List<FieldContainer> = List<FieldContainer>
    while iterator.Index != iterator.EndIndex:
        var start: int = iterator.GetRunStart
        var end: int = iterator.GetRunLimit
        var it = iterator.GetAttributes.Keys.GetEnumerator
it.MoveNext
        var attribute: AttributedCharacterIteratorAttribute = cast[AttributedCharacterIteratorAttribute](it.Current)
        if it.MoveNext && attribute.Equals(NumberFormatField.Integer):
            attribute = cast[AttributedCharacterIteratorAttribute](it.Current)
        var value: Object = iterator.GetAttribute(attribute)
result.Add(FieldContainer(start, end, attribute, value))
iterator.SetIndex(end)
assertEquals("Comparing vector length for " + formattedOutput, expected.Count, result.Count)
    if result.Except(expected).Any:
          var i: int = 0
          while i < expected.Count:
Console.Out.WriteLine("     expected[" + i + "] =" + expected[i].start + " " + expected[i].end + " " + expected[i].attribute + " " + expected[i].value)
Console.Out.WriteLine(" result[" + i + "] =" + result[i].start + " " + result[i].end + " " + result[i].attribute + " " + result[i].value)
++i
assertTrue("Comparing vector results for " + formattedOutput, !result.Except(expected).Any)
proc TestNPEIssue11914*() =
    var v1: List<FieldContainer> = List<FieldContainer>(7)
v1.Add(FieldContainer(0, 3, NumberFormatField.Integer))
v1.Add(FieldContainer(3, 4, NumberFormatField.GroupingSeparator))
v1.Add(FieldContainer(4, 7, NumberFormatField.Integer))
v1.Add(FieldContainer(7, 8, NumberFormatField.GroupingSeparator))
v1.Add(FieldContainer(8, 11, NumberFormatField.Integer))
v1.Add(FieldContainer(11, 12, NumberFormatField.DecimalSeparator))
v1.Add(FieldContainer(12, 15, NumberFormatField.Fraction))
    var number: Number = Double.GetInstance(123456789.9753)
    var usLoc: UCultureInfo = UCultureInfo("en-US")
    var US: DecimalFormatSymbols = DecimalFormatSymbols(usLoc)
    var outFmt: NumberFormat = NumberFormat.GetNumberInstance(usLoc)
    var numFmtted: String = outFmt.Format(number)
    var iterator: AttributedCharacterIterator = outFmt.FormatToCharacterIterator(number)
CompareAttributedCharacterFormatOutput(iterator, v1, numFmtted)
    var v2: List<FieldContainer> = List<FieldContainer>(7)
v2.Add(FieldContainer(0, 1, NumberFormatField.Integer))
v2.Add(FieldContainer(1, 2, NumberFormatField.DecimalSeparator))
v2.Add(FieldContainer(2, 5, NumberFormatField.Fraction))
v2.Add(FieldContainer(5, 6, NumberFormatField.ExponentSymbol))
v2.Add(FieldContainer(6, 7, NumberFormatField.ExponentSign))
v2.Add(FieldContainer(7, 8, NumberFormatField.Exponent))
    var fmt2: DecimalFormat = DecimalFormat("0.###E+0", US)
    numFmtted = fmt2.Format(number)
    iterator = fmt2.FormatToCharacterIterator(number)
CompareAttributedCharacterFormatOutput(iterator, v2, numFmtted)
    var v3: List<FieldContainer> = List<FieldContainer>(7)
v3.Add(FieldContainer(0, 1, NumberFormatField.Sign))
v3.Add(FieldContainer(1, 2, NumberFormatField.Integer))
v3.Add(FieldContainer(2, 3, NumberFormatField.GroupingSeparator))
v3.Add(FieldContainer(3, 6, NumberFormatField.Integer))
v3.Add(FieldContainer(6, 7, NumberFormatField.GroupingSeparator))
v3.Add(FieldContainer(7, 10, NumberFormatField.Integer))
v3.Add(FieldContainer(10, 11, NumberFormatField.GroupingSeparator))
v3.Add(FieldContainer(11, 14, NumberFormatField.Integer))
v3.Add(FieldContainer(14, 15, NumberFormatField.GroupingSeparator))
v3.Add(FieldContainer(15, 18, NumberFormatField.Integer))
v3.Add(FieldContainer(18, 19, NumberFormatField.GroupingSeparator))
v3.Add(FieldContainer(19, 22, NumberFormatField.Integer))
v3.Add(FieldContainer(22, 23, NumberFormatField.GroupingSeparator))
v3.Add(FieldContainer(23, 26, NumberFormatField.Integer))
    var bigNumberInt: BigInteger = BigInteger.Parse("-1234567890246813579", 10)
    var fmtNumberBigInt: String = outFmt.Format(bigNumberInt)
    iterator = outFmt.FormatToCharacterIterator(bigNumberInt)
CompareAttributedCharacterFormatOutput(iterator, v3, fmtNumberBigInt)
    var v4: List<FieldContainer> = List<FieldContainer>(7)
v4.Add(FieldContainer(0, 1, NumberFormatField.Sign))
v4.Add(FieldContainer(1, 2, NumberFormatField.Integer))
v4.Add(FieldContainer(2, 3, NumberFormatField.DecimalSeparator))
v4.Add(FieldContainer(3, 6, NumberFormatField.Fraction))
v4.Add(FieldContainer(6, 7, NumberFormatField.ExponentSymbol))
v4.Add(FieldContainer(7, 8, NumberFormatField.ExponentSign))
v4.Add(FieldContainer(8, 9, NumberFormatField.Exponent))
    var numberBigD: Numerics.BigMath.BigDecimal = Numerics.BigMath.BigDecimal(-123456789)
    var fmtNumberBigDExp: String = fmt2.Format(numberBigD)
    iterator = fmt2.FormatToCharacterIterator(numberBigD)
CompareAttributedCharacterFormatOutput(iterator, v4, fmtNumberBigDExp)
proc checkFormatWithField(testInfo: String, format: Formatter, @object: Object, expected: String, field: FormatField, begin: int, end: int) =
    var buffer: StringBuffer = StringBuffer
    var pos: FieldPosition = FieldPosition(field)
format.Format(@object, buffer, pos)
assertEquals("Test " + testInfo + ": incorrect formatted text", expected, buffer.ToString)
    if begin != pos.BeginIndex || end != pos.EndIndex:
assertEquals("Index mismatch", field + " " + begin + ".." + end, pos.FieldAttribute + " " + pos.BeginIndex + ".." + pos.EndIndex)
proc TestMissingFieldPositionsCurrency*() =
    var formatter: DecimalFormat = cast[DecimalFormat](NumberFormat.GetCurrencyInstance(UCultureInfo("en-US")))
    var number: Number = Double.GetInstance(92314587.66)
    var result: String = "$92,314,587.66"
checkFormatWithField("currency", formatter, number, result, NumberFormatField.Currency, 0, 1)
checkFormatWithField("integer", formatter, number, result, NumberFormatField.Integer, 1, 11)
checkFormatWithField("grouping separator", formatter, number, result, NumberFormatField.GroupingSeparator, 3, 4)
checkFormatWithField("decimal separator", formatter, number, result, NumberFormatField.DecimalSeparator, 11, 12)
checkFormatWithField("fraction", formatter, number, result, NumberFormatField.Fraction, 12, 14)
proc TestMissingFieldPositionsNegativeDouble*() =
    var us_symbols: DecimalFormatSymbols = DecimalFormatSymbols(UCultureInfo("en-US"))
    var number: Number = Double.GetInstance(-12345678.90123)
    var formatter: DecimalFormat = DecimalFormat("0.#####E+00", us_symbols)
    var numFmtted: String = formatter.Format(number)
checkFormatWithField("sign", formatter, number, numFmtted, NumberFormatField.Sign, 0, 1)
checkFormatWithField("integer", formatter, number, numFmtted, NumberFormatField.Integer, 1, 2)
checkFormatWithField("decimal separator", formatter, number, numFmtted, NumberFormatField.DecimalSeparator, 2, 3)
checkFormatWithField("exponent symbol", formatter, number, numFmtted, NumberFormatField.ExponentSymbol, 8, 9)
checkFormatWithField("exponent sign", formatter, number, numFmtted, NumberFormatField.ExponentSign, 9, 10)
checkFormatWithField("exponent", formatter, number, numFmtted, NumberFormatField.Exponent, 10, 12)
proc TestMissingFieldPositionsPerCent*() =
    var percentFormat: DecimalFormat = cast[DecimalFormat](NumberFormat.GetPercentInstance(UCultureInfo("en-US")))
    var number: Number = Double.GetInstance(-0.986)
    var numberFormatted: String = percentFormat.Format(number)
checkFormatWithField("sign", percentFormat, number, numberFormatted, NumberFormatField.Sign, 0, 1)
checkFormatWithField("integer", percentFormat, number, numberFormatted, NumberFormatField.Integer, 1, 3)
checkFormatWithField("percent", percentFormat, number, numberFormatted, NumberFormatField.Percent, 3, 4)
proc TestMissingFieldPositionsPerCentPattern*() =
    var us_symbols: DecimalFormatSymbols = DecimalFormatSymbols(UCultureInfo("en-US"))
    var fmtPercent: DecimalFormat = DecimalFormat("0.#####%", us_symbols)
    var number: Number = Double.GetInstance(-0.986)
    var numFmtted: String = fmtPercent.Format(number)
checkFormatWithField("sign", fmtPercent, number, numFmtted, NumberFormatField.Sign, 0, 1)
checkFormatWithField("integer", fmtPercent, number, numFmtted, NumberFormatField.Integer, 1, 3)
checkFormatWithField("decimal separator", fmtPercent, number, numFmtted, NumberFormatField.DecimalSeparator, 3, 4)
checkFormatWithField("fraction", fmtPercent, number, numFmtted, NumberFormatField.Fraction, 4, 5)
checkFormatWithField("percent", fmtPercent, number, numFmtted, NumberFormatField.Percent, 5, 6)
proc TestMissingFieldPositionsPerMille*() =
    var us_symbols: DecimalFormatSymbols = DecimalFormatSymbols(UCultureInfo("en-US"))
    var fmtPerMille: DecimalFormat = DecimalFormat("0.######‰", us_symbols)
    var numberPermille: Number = Double.GetInstance(-0.98654)
    var numFmtted: String = fmtPerMille.Format(numberPermille)
checkFormatWithField("sign", fmtPerMille, numberPermille, numFmtted, NumberFormatField.Sign, 0, 1)
checkFormatWithField("integer", fmtPerMille, numberPermille, numFmtted, NumberFormatField.Integer, 1, 4)
checkFormatWithField("decimal separator", fmtPerMille, numberPermille, numFmtted, NumberFormatField.DecimalSeparator, 4, 5)
checkFormatWithField("fraction", fmtPerMille, numberPermille, numFmtted, NumberFormatField.Fraction, 5, 7)
checkFormatWithField("permille", fmtPerMille, numberPermille, numFmtted, NumberFormatField.PerMille, 7, 8)
proc TestMissingFieldPositionsNegativeBigInt*() =
    var us_symbols: DecimalFormatSymbols = DecimalFormatSymbols(UCultureInfo("en-US"))
    var formatter: DecimalFormat = DecimalFormat("0.#####E+0", us_symbols)
    var number: Number = BigDecimal.Parse("-123456789987654321", CultureInfo.InvariantCulture)
    var bigDecFmtted: String = formatter.Format(number)
checkFormatWithField("sign", formatter, number, bigDecFmtted, NumberFormatField.Sign, 0, 1)
checkFormatWithField("integer", formatter, number, bigDecFmtted, NumberFormatField.Integer, 1, 2)
checkFormatWithField("decimal separator", formatter, number, bigDecFmtted, NumberFormatField.DecimalSeparator, 2, 3)
checkFormatWithField("exponent symbol", formatter, number, bigDecFmtted, NumberFormatField.ExponentSymbol, 8, 9)
checkFormatWithField("exponent sign", formatter, number, bigDecFmtted, NumberFormatField.ExponentSign, 9, 10)
checkFormatWithField("exponent", formatter, number, bigDecFmtted, NumberFormatField.Exponent, 10, 12)
proc TestMissingFieldPositionsNegativeLong*() =
    var number: Number = Long.GetInstance(Long.Parse("-123456789987654321", CultureInfo.InvariantCulture))
    var us_symbols: DecimalFormatSymbols = DecimalFormatSymbols(UCultureInfo("en-US"))
    var formatter: DecimalFormat = DecimalFormat("0.#####E+0", us_symbols)
    var longFmtted: String = formatter.Format(number)
checkFormatWithField("sign", formatter, number, longFmtted, NumberFormatField.Sign, 0, 1)
checkFormatWithField("integer", formatter, number, longFmtted, NumberFormatField.Integer, 1, 2)
checkFormatWithField("decimal separator", formatter, number, longFmtted, NumberFormatField.DecimalSeparator, 2, 3)
checkFormatWithField("exponent symbol", formatter, number, longFmtted, NumberFormatField.ExponentSymbol, 8, 9)
checkFormatWithField("exponent sign", formatter, number, longFmtted, NumberFormatField.ExponentSign, 9, 10)
checkFormatWithField("exponent", formatter, number, longFmtted, NumberFormatField.Exponent, 10, 12)
proc TestMissingFieldPositionsPositiveBigDec*() =
    var us_symbols: DecimalFormatSymbols = DecimalFormatSymbols(UCultureInfo("en-US"))
    var fmtPosNegSign: DecimalFormat = DecimalFormat("+0.####E+00;-0.#######E+0", us_symbols)
    var positiveExp: Number = Double.GetInstance(Double.Parse("9876543210", CultureInfo.InvariantCulture))
    var posExpFormatted: String = fmtPosNegSign.Format(positiveExp)
checkFormatWithField("sign", fmtPosNegSign, positiveExp, posExpFormatted, NumberFormatField.Sign, 0, 1)
checkFormatWithField("integer", fmtPosNegSign, positiveExp, posExpFormatted, NumberFormatField.Integer, 1, 2)
checkFormatWithField("decimal separator", fmtPosNegSign, positiveExp, posExpFormatted, NumberFormatField.DecimalSeparator, 2, 3)
checkFormatWithField("fraction", fmtPosNegSign, positiveExp, posExpFormatted, NumberFormatField.Fraction, 3, 7)
checkFormatWithField("exponent symbol", fmtPosNegSign, positiveExp, posExpFormatted, NumberFormatField.ExponentSymbol, 7, 8)
checkFormatWithField("exponent sign", fmtPosNegSign, positiveExp, posExpFormatted, NumberFormatField.ExponentSign, 8, 9)
checkFormatWithField("exponent", fmtPosNegSign, positiveExp, posExpFormatted, NumberFormatField.Exponent, 9, 11)
proc TestMissingFieldPositionsNegativeBigDec*() =
    var us_symbols: DecimalFormatSymbols = DecimalFormatSymbols(UCultureInfo("en-US"))
    var fmtPosNegSign: DecimalFormat = DecimalFormat("+0.####E+00;-0.#######E+0", us_symbols)
    var negativeExp: Number = BigDecimal.Parse("-0.000000987654321083", CultureInfo.InvariantCulture)
    var negExpFormatted: String = fmtPosNegSign.Format(negativeExp)
checkFormatWithField("sign", fmtPosNegSign, negativeExp, negExpFormatted, NumberFormatField.Sign, 0, 1)
checkFormatWithField("integer", fmtPosNegSign, negativeExp, negExpFormatted, NumberFormatField.Integer, 1, 2)
checkFormatWithField("decimal separator", fmtPosNegSign, negativeExp, negExpFormatted, NumberFormatField.DecimalSeparator, 2, 3)
checkFormatWithField("fraction", fmtPosNegSign, negativeExp, negExpFormatted, NumberFormatField.Fraction, 3, 7)
checkFormatWithField("exponent symbol", fmtPosNegSign, negativeExp, negExpFormatted, NumberFormatField.ExponentSymbol, 7, 8)
checkFormatWithField("exponent sign", fmtPosNegSign, negativeExp, negExpFormatted, NumberFormatField.ExponentSign, 8, 9)
checkFormatWithField("exponent", fmtPosNegSign, negativeExp, negExpFormatted, NumberFormatField.Exponent, 9, 11)
proc TestStringSymbols*() =
    var symbols: DecimalFormatSymbols = DecimalFormatSymbols(UCultureInfo("en-US"))
    var customDigits: string[] = @["(0)", "(1)", "(2)", "(3)", "(4)", "(5)", "(6)", "(7)", "(8)", "(9)"]
    symbols.DigitStrings = customDigits
    var fmt: DecimalFormat = DecimalFormat("#,##0.0#", symbols)
expect2(fmt, 1234567.89, "(1),(2)(3)(4),(5)(6)(7).(8)(9)")
fmt.ApplyPattern("@@@E0")
expect2(fmt, 1230000, "(1).(2)(3)E(6)")
    symbols.DecimalSeparatorString = "~~"
    symbols.GroupingSeparatorString = "^^"
fmt.SetDecimalFormatSymbols(symbols)
fmt.ApplyPattern("#,##0.0#")
assertEquals("Custom decimal and grouping separator string with multiple characters", "(1)^^(2)(3)(4)^^(5)(6)(7)~~(8)(9)", fmt.Format(1234567.89))
      var i: int = 0
      while i < 10:
          customDigits[i] = string(Character.ToChars(120782 + i))
++i
    symbols.DigitStrings = customDigits
    symbols.DecimalSeparatorString = "😁"
    symbols.GroupingSeparatorString = "😎"
fmt.SetDecimalFormatSymbols(symbols)
expect2(fmt, 1234.56, "𝟏😎𝟐𝟑𝟒😁𝟓𝟔")
proc TestArabicCurrencyPatternInfo*() =
    var arLocale: UCultureInfo = UCultureInfo("ar")
    var symbols: DecimalFormatSymbols = DecimalFormatSymbols(arLocale)
    var currSpacingPatn: String = symbols.GetPatternForCurrencySpacing(CurrencySpacingPattern.CurrencyMatch, true)
    if currSpacingPatn == nil || currSpacingPatn.Length == 0:
Errln("locale ar, getPatternForCurrencySpacing returns null or 0-length string")
    var currAcctFormat: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(arLocale, NumberFormatStyle.AccountingCurrencyStyle))
    var currAcctPatn: String = currAcctFormat.ToPattern
    if currAcctPatn == nil || currAcctPatn.Length == 0:
Errln("locale ar, toPattern for ACCOUNTINGCURRENCYSTYLE returns null or 0-length string")
proc TestMinMaxOverrides*() =
    var baseClasses: Type[] = @[type(NumberFormat), type(NumberFormat), type(DecimalFormat)]
    var names: string[] = @["Integer", "Fraction", "Significant"]
      var i: int = 0
      while i < 3:
          var df: DecimalFormat = DecimalFormat
          var @base: Type = baseClasses[i]
          var name: String = names[i]
          var getMinimum: MethodInfo = @base.GetMethod("get_Minimum" + name + "Digits")
          var setMinimum: MethodInfo = @base.GetMethod("set_Minimum" + name + "Digits", @[type(int)])
          var getMaximum: MethodInfo = @base.GetMethod("get_Maximum" + name + "Digits")
          var setMaximum: MethodInfo = @base.GetMethod("set_Maximum" + name + "Digits", @[type(int)])
setMinimum.Invoke(df, @[2])
assertEquals(name + " getMin A", 2, getMinimum.Invoke(df, seq[object]))
setMaximum.Invoke(df, @[3])
assertEquals(name + " getMin B", 2, getMinimum.Invoke(df, seq[object]))
assertEquals(name + " getMax B", 3, getMaximum.Invoke(df, seq[object]))
setMaximum.Invoke(df, @[2])
assertEquals(name + " getMin C", 2, getMinimum.Invoke(df, seq[object]))
assertEquals(name + " getMax C", 2, getMaximum.Invoke(df, seq[object]))
setMaximum.Invoke(df, @[1])
assertEquals(name + " getMin D", 1, getMinimum.Invoke(df, seq[object]))
assertEquals(name + " getMax D", 1, getMaximum.Invoke(df, seq[object]))
setMaximum.Invoke(df, @[2])
assertEquals(name + " getMax E", 2, getMaximum.Invoke(df, seq[object]))
setMinimum.Invoke(df, @[1])
assertEquals(name + " getMin F", 1, getMinimum.Invoke(df, seq[object]))
assertEquals(name + " getMax F", 2, getMaximum.Invoke(df, seq[object]))
setMinimum.Invoke(df, @[2])
assertEquals(name + " getMin G", 2, getMinimum.Invoke(df, seq[object]))
assertEquals(name + " getMax G", 2, getMaximum.Invoke(df, seq[object]))
setMinimum.Invoke(df, @[3])
assertEquals(name + " getMin H", 3, getMinimum.Invoke(df, seq[object]))
assertEquals(name + " getMax H", 3, getMaximum.Invoke(df, seq[object]))
++i
proc TestSetMathContext*() =
    var fourDigits: Numerics.BigMath.MathContext = Numerics.BigMath.MathContext(4)
    var unlimitedCeiling: Numerics.BigMath.MathContext = Numerics.BigMath.MathContext(0, Numerics.BigMath.RoundingMode.Ceiling)
    var df: DecimalFormat = DecimalFormat
assertEquals("Default format", "9,876.543", df.Format(9876.5432))
    df.MathContext = fourDigits
assertEquals("Format with fourDigits", "9,877", df.Format(9876.5432))
    df.MathContext = unlimitedCeiling
assertEquals("Format with unlimitedCeiling", "9,876.544", df.Format(9876.5432))
    df = DecimalFormat("0.000%")
assertEquals("Default multiplication", "12.001%", df.Format(0.120011))
    df.MathContext = fourDigits
assertEquals("Multiplication with fourDigits", "12.000%", df.Format(0.120011))
    df.MathContext = unlimitedCeiling
assertEquals("Multiplication with unlimitedCeiling", "12.002%", df.Format(0.120011))
    df = DecimalFormat("0%")
assertEquals("Default division", 0.12001, df.Parse("12.001%").ToDouble)
    df.MathContext = fourDigits
assertEquals("Division with fourDigits", 0.12, df.Parse("12.001%").ToDouble)
    df.MathContext = unlimitedCeiling
assertEquals("Division with unlimitedCeiling", 0.12001, df.Parse("12.001%").ToDouble)
    df = DecimalFormat
    df.Multiplier = 1000000007
    var hugeNumberString: String = "9876543212345678987654321234567898765432123456789"
    var huge34Digits: BigInteger = BigInteger.Parse("9876543143209876985185182338271622000000", 10)
    var huge4Digits: BigInteger = BigInteger.Parse("9877000000000000000000000000000000000000", 10)
assertEquals("Default extreme division", huge34Digits, df.Parse(hugeNumberString))
    df.MathContext = fourDigits
assertEquals("Extreme division with fourDigits", huge4Digits, df.Parse(hugeNumberString))
    df.MathContext = unlimitedCeiling
    try:
df.Parse(hugeNumberString)
fail("Extreme division with unlimitedCeiling should throw ArithmeticException")
    except ArithmeticException:

proc Test10436*() =
    var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(CultureInfo("en")))
    df.RoundingMode = Numerics.BigMath.RoundingMode.Ceiling
    df.MinimumFractionDigits = 0
    df.MaximumFractionDigits = 0
assertEquals("-.99 should round toward infinity", "-0", df.Format(-0.99))
proc Test10765*() =
    var fmt: NumberFormat = NumberFormat.GetInstance(UCultureInfo("en"))
    fmt.MinimumIntegerDigits = 10
    var pos: FieldPosition = FieldPosition(NumberFormatField.GroupingSeparator)
    var sb: StringBuffer = StringBuffer
fmt.Format(1234567, sb, pos)
assertEquals("Should have multiple grouping separators", "0,001,234,567", sb.ToString)
assertEquals("FieldPosition should report the first occurence", 1, pos.BeginIndex)
assertEquals("FieldPosition should report the first occurence", 2, pos.EndIndex)
proc Test10997*() =
    var fmt: NumberFormat = NumberFormat.GetCurrencyInstance(UCultureInfo("en-US"))
    fmt.MinimumFractionDigits = 4
    fmt.MaximumFractionDigits = 4
    var str1: String = fmt.Format(CurrencyAmount(123.45, Currency.GetInstance("USD")))
    var str2: String = fmt.Format(CurrencyAmount(123.45, Currency.GetInstance("EUR")))
assertEquals("minFrac 4 should be respected in default currency", "$123.4500", str1)
assertEquals("minFrac 4 should be respected in different currency", "€123.4500", str2)
proc Test11020*() =
    var sym: DecimalFormatSymbols = DecimalFormatSymbols(UCultureInfo("fr-FR"))
    var fmt: DecimalFormat = DecimalFormat("0.05E0", sym)
    var result: String = fmt.Format(12301.2).Replace('�', ' ')
assertEquals("Rounding increment should be applied after magnitude scaling", "1,25E4", result)
proc Test11025*() =
    var pattern: String = "¤¤ **####0.00"
    var sym: DecimalFormatSymbols = DecimalFormatSymbols(UCultureInfo("fr-FR"))
    var fmt: DecimalFormat = DecimalFormat(pattern, sym)
    var result: String = fmt.Format(433.0)
assertEquals("Number should be padded to 11 characters", "EUR *433,00", result)
proc Test11640*() =
    var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance)
df.ApplyPattern("¤¤¤ 0")
    var result: String = df.PositivePrefix
assertEquals("Triple-currency should give long name on getPositivePrefix", "US dollar ", result)
proc Test11645*() =
    var pattern: String = "#,##0.0#"
    var fmt: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance)
fmt.ApplyPattern(pattern)
    var fmtCopy: DecimalFormat
    var newMultiplier: int = 37
    fmtCopy = cast[DecimalFormat](fmt.Clone)
assertNotEquals("Value before setter", fmtCopy.Multiplier, newMultiplier)
    fmtCopy.Multiplier = newMultiplier
assertEquals("Value after setter", fmtCopy.Multiplier, newMultiplier)
fmtCopy.ApplyPattern(pattern)
assertEquals("Value after applyPattern", fmtCopy.Multiplier, newMultiplier)
assertFalse("multiplier", fmt.Equals(fmtCopy))
    var newRoundingMode: Numerics.BigMath.RoundingMode = Numerics.BigMath.RoundingMode.Ceiling
    fmtCopy = cast[DecimalFormat](fmt.Clone)
assertNotEquals("Value before setter", fmtCopy.RoundingMode, newRoundingMode)
    fmtCopy.RoundingMode = newRoundingMode
assertEquals("Value after setter", fmtCopy.RoundingMode, newRoundingMode)
fmtCopy.ApplyPattern(pattern)
assertEquals("Value after applyPattern", fmtCopy.RoundingMode, newRoundingMode)
assertFalse("roundingMode", fmt.Equals(fmtCopy))
    var newCurrency: Currency = Currency.GetInstance("EAT")
    fmtCopy = cast[DecimalFormat](fmt.Clone)
assertNotEquals("Value before setter", fmtCopy.Currency, newCurrency)
    fmtCopy.Currency = newCurrency
assertEquals("Value after setter", fmtCopy.Currency, newCurrency)
fmtCopy.ApplyPattern(pattern)
assertEquals("Value after applyPattern", fmtCopy.Currency, newCurrency)
assertFalse("currency", fmt.Equals(fmtCopy))
    var newCurrencyUsage: CurrencyUsage = CurrencyUsage.Cash
    fmtCopy = cast[DecimalFormat](fmt.Clone)
assertNotEquals("Value before setter", fmtCopy.CurrencyUsage, newCurrencyUsage)
    fmtCopy.CurrencyUsage = CurrencyUsage.Cash
assertEquals("Value after setter", fmtCopy.CurrencyUsage, newCurrencyUsage)
fmtCopy.ApplyPattern(pattern)
assertEquals("Value after applyPattern", fmtCopy.CurrencyUsage, newCurrencyUsage)
assertFalse("currencyUsage", fmt.Equals(fmtCopy))
proc Test11646*() =
    var symbols: DecimalFormatSymbols = DecimalFormatSymbols(UCultureInfo("en_US"))
    var pattern: String = "¤¤¤ 0.00 %¤¤"
    var fmt: DecimalFormat = DecimalFormat(pattern, symbols)
      var fmtCopy: DecimalFormat = cast[DecimalFormat](fmt.Clone)
assertEquals("", fmt, fmtCopy)
      fmtCopy.PositivePrefix = fmtCopy.PositivePrefix
assertNotEquals("", fmt, fmtCopy)
      var fmtCopy: DecimalFormat = cast[DecimalFormat](fmt.Clone)
assertEquals("", fmt, fmtCopy)
      fmtCopy.PositiveSuffix = fmtCopy.PositiveSuffix
assertNotEquals("", fmt, fmtCopy)
      var fmtCopy: DecimalFormat = cast[DecimalFormat](fmt.Clone)
assertEquals("", fmt, fmtCopy)
      fmtCopy.NegativePrefix = fmtCopy.NegativePrefix
assertNotEquals("", fmt, fmtCopy)
      var fmtCopy: DecimalFormat = cast[DecimalFormat](fmt.Clone)
assertEquals("", fmt, fmtCopy)
      fmtCopy.NegativeSuffix = fmtCopy.NegativeSuffix
assertNotEquals("", fmt, fmtCopy)
proc Test11648*() =
    var df: DecimalFormat = DecimalFormat("0.00")
    df.UseScientificNotation = true
    var pat: String = df.ToPattern
assertEquals("A valid scientific notation pattern should be produced", "0.00E0", pat)
proc Test11649*() =
    var pattern: String = "¤¤¤ 0.00"
    var fmt: DecimalFormat = DecimalFormat(pattern)
    fmt.Currency = Currency.GetInstance("USD")
assertEquals("Triple currency sign should format long name", "US dollars 12.34", fmt.Format(12.34))
    var newPattern: String = fmt.ToPattern
assertEquals("Should produce a valid pattern", pattern, newPattern)
    var fmt2: DecimalFormat = DecimalFormat(newPattern)
    fmt2.Currency = Currency.GetInstance("USD")
assertEquals("Triple currency sign pattern should round-trip", "US dollars 12.34", fmt2.Format(12.34))
    var quotedPattern: String = "¤¤'¤' 0.00"
    var fmt3: DecimalFormat = DecimalFormat(quotedPattern)
assertEquals("Should be treated as double currency sign", "USD¤ 12.34", fmt3.Format(12.34))
    var outQuotedPattern: String = fmt3.ToPattern
assertEquals("Double currency sign with quoted sign should round-trip", quotedPattern, outQuotedPattern)
proc Test11686*() =
    var df: DecimalFormat = DecimalFormat
    df.PositiveSuffix = "0K"
    df.NegativeSuffix = "0N"
expect2(df, 123, "1230K")
expect2(df, -123, "-1230N")
proc Test11839*() =
    var dfs: DecimalFormatSymbols = DecimalFormatSymbols(UCultureInfo("en"))
    dfs.MinusSignString = "a∸"
    dfs.PlusSignString = "b∔"
    var df: DecimalFormat = DecimalFormat("0.00+;0.00-", dfs)
    var result: String = df.Format(-1.234)
assertEquals("Locale-specific minus sign should be used", "1.23a∸", result)
    result = df.Format(1.234)
assertEquals("Locale-specific plus sign should be used", "1.23b∔", result)
expect2(df, -456, "456.00a∸")
expect2(df, 456, "456.00b∔")
proc Test12753*() =
    var locale: UCultureInfo = UCultureInfo("en-US")
    var symbols: DecimalFormatSymbols = DecimalFormatSymbols.GetInstance(locale)
    symbols.DecimalSeparator = '*'
    var df: DecimalFormat = DecimalFormat("0.00", symbols)
    df.DecimalPatternMatchRequired = true
    try:
df.Parse("123")
fail("Parsing integer succeeded even though setDecimalPatternMatchRequired was set")
    except FormatException:

proc Test12962*() =
    var pat: String = "**0.00"
    var df: DecimalFormat = DecimalFormat(pat)
    var newPat: String = df.ToPattern
assertEquals("Format width changed upon calling applyPattern", pat.Length, newPat.Length)
proc Test10354*() =
    var dfs: DecimalFormatSymbols = DecimalFormatSymbols
    dfs.NaN = ""
    var df: DecimalFormat = DecimalFormat
df.SetDecimalFormatSymbols(dfs)
    try:
df.FormatToCharacterIterator(Double.GetInstance(double.NaN))
    except ArgumentException:
        raise AssertionException(e.ToString, e)
proc Test11913*() =
    var df: NumberFormat = DecimalFormat.GetInstance
    var result: String = df.Format(BigDecimal.Parse("1.23456789E400", CultureInfo.InvariantCulture))
assertEquals("Should format more than 309 digits", "12,345,678", result.Substring(0, 10))
assertEquals("Should format more than 309 digits", 534, result.Length)
proc Test12045*() =
    if logKnownIssue("12045", "XSU is missing from fr"):
        return
    var nf: NumberFormat = NumberFormat.GetInstance(UCultureInfo("fr"), NumberFormatStyle.PluralCurrencyStyle)
    var ppos: ParsePosition = ParsePosition(0)
    try:
        var result: CurrencyAmount = nf.ParseCurrency("2,34 XSU", ppos)
assertEquals("Parsing should succeed on XSU", CurrencyAmount(2.34, Currency.GetInstance("XSU")), result)
    except Exception:
        raise AssertionException("Should have been able to parse XSU: " + e.Message, e)
proc Test11739*() =
    var nf: NumberFormat = NumberFormat.GetCurrencyInstance(UCultureInfo("sr_BA"))
cast[DecimalFormat](nf).ApplyPattern("#,##0.0 ¤¤¤")
    var ppos: ParsePosition = ParsePosition(0)
    var result: CurrencyAmount = nf.ParseCurrency("1.500 амерички долар", ppos)
assertEquals("Should parse to 1500 USD", CurrencyAmount(1500, Currency.GetInstance("USD")), result)
proc Test11647*() =
    var df: DecimalFormat = DecimalFormat
df.ApplyPattern("¤¤¤¤#")
    var actual: String = df.Format(123)
assertEquals("Should replace 4 currency signs with U+FFFD", "�123", actual)
proc Test12567*() =
    var df1: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(NumberFormatStyle.PluralCurrencyStyle))
    var df2: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(NumberFormatStyle.NumberStyle))
    df2.Currency = df1.Currency
    df2.CurrencyPluralInfo = df1.CurrencyPluralInfo
df1.ApplyPattern("0.00")
df2.ApplyPattern("0.00")
assertEquals("df1 == df2", df1, df2)
assertEquals("df2 == df1", df2, df1)
    df2.PositivePrefix = "abc"
assertNotEquals("df1 != df2", df1, df2)
assertNotEquals("df2 != df1", df2, df1)
proc Test13055*() =
    var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetPercentInstance)
    df.MaximumFractionDigits = 0
    df.RoundingMode = Numerics.BigMath.RoundingMode.HalfEven
assertEquals("Should round percent toward even number", "216%", df.Format(2.155))
proc Test13056*() =
    var df: DecimalFormat = DecimalFormat("#,##0")
assertEquals("Primary grouping should return 3", 3, df.GroupingSize)
assertEquals("Secondary grouping should return 0", 0, df.SecondaryGroupingSize)
    df.SecondaryGroupingSize = 3
assertEquals("Primary grouping should still return 3", 3, df.GroupingSize)
assertEquals("Secondary grouping should still return 0", 0, df.SecondaryGroupingSize)
    df.GroupingSize = 4
assertEquals("Primary grouping should return 4", 4, df.GroupingSize)
assertEquals("Secondary should remember explicit setting and return 3", 3, df.SecondaryGroupingSize)
proc Test13074*() =
    var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetCurrencyInstance(UCultureInfo("bg-BG")))
    var result: String = df.Format(987654.321)
assertEquals("Locale 'bg' should not use monetary grouping", "987654,32 лв.", result)
proc Test13088and13162*() =
    var loc: UCultureInfo = UCultureInfo("fa")
    var pattern1: String = "% #,##0;% -#,##0"
    var num: double = -12.34
    var symbols: DecimalFormatSymbols = DecimalFormatSymbols.GetInstance(loc)
    symbols.PercentString = "‎٪"
assertEquals("Checking for expected symbols", "‎−", symbols.MinusSignString)
assertEquals("Checking for expected symbols", "‎٪", symbols.PercentString)
    var numfmt: DecimalFormat = DecimalFormat(pattern1, symbols)
expect2(numfmt, num, "‎٪ ‎−۱٬۲۳۴")
    var pattern2: String = "%#,##0;%-#,##0"
    numfmt = DecimalFormat(pattern2, symbols)
expect2(numfmt, num, "‎٪‎−۱٬۲۳۴")
proc Test13113_MalformedPatterns*() =
    var cases: string[][] = @[@["'", "quoted literal"], @["ab#c'd", "quoted literal"], @["ab#c*", "unquoted literal"], @["0#", "# cannot follow 0"], @[".#0", "0 cannot follow #"], @["@0", "Cannot mix @ and 0"], @["0@", "Cannot mix 0 and @"], @["#x#", "unquoted special character"], @["@#@", "# inside of a run of @"]]
    for cas in cases:
        try:
DecimalFormat(cas[0])
fail("Should have thrown on malformed pattern")
        except FormatException:
assertTrue("Exception should contain "Malformed pattern": " + ex.Message, ex.Message.Contains("Malformed pattern"))
assertTrue("Exception should contain "" + cas[1] + """ + ex.Message, ex.Message.Contains(cas[1]))
proc Test13118*() =
    var df: DecimalFormat = DecimalFormat("@@@")
    df.UseScientificNotation = true
      var d: double = 12345.67
      while d > 0.000001:
          var result: String = df.Format(d)
assertEquals("Should produce a string of expected length on " + d,           if d > 1:
6
          else:
7, result.Length)
          d = 10
proc Test13148*() =
    if logKnownIssue("13148", "Currency separators used in non-currency parsing"):
      return
    var fmt: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(UCultureInfo("en-ZA")))
    var symbols: DecimalFormatSymbols = fmt.GetDecimalFormatSymbols
    symbols.DecimalSeparator = '.'
    symbols.GroupingSeparator = ','
fmt.SetDecimalFormatSymbols(symbols)
    var ppos: ParsePosition = ParsePosition(0)
    var number: Number = fmt.Parse("300,000", ppos)
assertEquals("Should parse to 300000 using non-monetary separators: " + ppos, 300000, number)
proc Test13289*() =
    var df: DecimalFormat = DecimalFormat("#00.0#E0")
    var result: String = df.Format(0.00123)
assertEquals("Should ignore scientific minInt if maxInt>minInt", "1.23E-3", result)
proc Test13310*() =
assertEquals("Should not throw an assertion error", "100000007.6E-1", DecimalFormat("000000000.0#E0").Format(10000000.76))
proc Test13391*() =
    var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(UCultureInfo("ccp")))
    df.ParseStrict = true
    var expected: String = "𑄷𑄸,𑄹𑄺𑄻"
assertEquals("Should produce expected output in ccp", expected, df.Format(12345))
    var result: Number = df.Parse(expected)
assertEquals("Should parse to 12345 in ccp", 12345, result.ToInt64)
    df = cast[DecimalFormat](NumberFormat.GetScientificInstance(UCultureInfo("ccp")))
    df.ParseStrict = true
    var expectedScientific: String = "𑄷.𑄹E𑄸"
assertEquals("Should produce expected scientific output in ccp", expectedScientific, df.Format(130))
    var resultScientific: Number = df.Parse(expectedScientific)
assertEquals("Should parse scientific to 130 in ccp", 130, resultScientific.ToInt64)
proc testPercentZero*() =
    var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetPercentInstance)
    var actual: String = df.Format(0)
assertEquals("Should have one zero digit", "0%", actual)
proc testCurrencyZeroRounding*() =
    var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetCurrencyInstance)
    df.MaximumFractionDigits = 0
    var actual: String = df.Format(0)
assertEquals("Should have zero fraction digits", "$0", actual)
proc testCustomCurrencySymbol*() =
    var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetCurrencyInstance)
    df.Currency = Currency.GetInstance("USD")
    var symbols: DecimalFormatSymbols = df.GetDecimalFormatSymbols
    symbols.CurrencySymbol = "#"
df.SetDecimalFormatSymbols(symbols)
    var actual: String = df.Format(123)
assertEquals("Should use '#' instad of '$'", "# 123.00", actual)
proc TestBasicSerializationRoundTrip*() =

proc testGetSetCurrency*() =
    var df: DecimalFormat = DecimalFormat("¤#")
assertEquals("Currency should start out null", nil, df.Currency)
    var curr: Currency = Currency.GetInstance("EUR")
    df.Currency = curr
assertEquals("Currency should equal EUR after set", curr, df.Currency)
    var result: String = df.Format(123)
assertEquals("Currency should format as expected in EUR", "€123.00", result)
proc testRoundingModeSetters*() =
    var df1: DecimalFormat = DecimalFormat
    var df2: DecimalFormat = DecimalFormat
    df1.RoundingMode = Numerics.BigMath.RoundingMode.Ceiling
assertNotEquals("Rounding mode was set to a non-default", df1, df2)
    df2.RoundingMode = Numerics.BigMath.RoundingMode.Ceiling
assertEquals("Rounding mode from icu.math and java.math should be the same", df1, df2)
    df2.RoundingMode = Numerics.BigMath.RoundingMode.Ceiling
assertEquals("Rounding mode ordinal from java.math.RoundingMode should be the same", df1, df2)
proc testCurrencySignificantDigits*() =
    var locale: UCultureInfo = UCultureInfo("en-US")
    var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetCurrencyInstance(locale))
    df.MaximumSignificantDigits = 2
    var result: String = df.Format(1234)
assertEquals("Currency rounding should obey significant digits", "$1,200", result)
proc testParseStrictScientific*() =
    var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetScientificInstance)
    df.ParseStrict = true
    var ppos: ParsePosition = ParsePosition(0)
    var result0: Number = df.Parse("123E4", ppos)
assertEquals("Should accept number with exponent", 1230000, result0.ToInt64)
assertEquals("Should consume the whole number", 5, ppos.Index)
    ppos.Index = 0
    result0 = df.Parse("123", ppos)
assertNull("Should reject number without exponent", result0)
    ppos.Index = 0
    var result1: CurrencyAmount = df.ParseCurrency("USD123", ppos)
assertNull("Should reject currency without exponent", result1)
proc testParseLenientScientific*() =
    var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetScientificInstance)
    var ppos: ParsePosition = ParsePosition(0)
    var result0: Number = df.Parse("123E", ppos)
assertEquals("Should parse the number in lenient mode", 123, result0.ToInt64)
assertEquals("Should stop before the E", 3, ppos.Index)
    var dfs: DecimalFormatSymbols = df.GetDecimalFormatSymbols
    dfs.ExponentSeparator = "EE"
df.SetDecimalFormatSymbols(dfs)
    ppos.Index = 0
    result0 = df.Parse("123EE", ppos)
assertEquals("Should parse the number in lenient mode", 123, result0.ToInt64)
assertEquals("Should stop before the EE", 3, ppos.Index)
proc testParseAcceptAsciiPercentPermilleFallback*() =
    var loc: UCultureInfo = UCultureInfo("ar")
    var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetPercentInstance(loc))
    var ppos: ParsePosition = ParsePosition(0)
    var result: Number = df.Parse("42%", ppos)
assertEquals("Should parse as 0.42 even in ar", BigDecimal.Parse("0.42", CultureInfo.InvariantCulture), result)
assertEquals("Should consume the entire string even in ar", 3, ppos.Index)
df.ApplyPattern(df.ToPattern.Replace("%", "‰"))
    ppos.Index = 0
    result = df.Parse("42‰", ppos)
assertEquals("Should parse as 0.042 even in ar", BigDecimal.Parse("0.042", CultureInfo.InvariantCulture), result)
assertEquals("Should consume the entire string even in ar", 3, ppos.Index)
proc testParseSubtraction*() =
    var df: DecimalFormat = DecimalFormat
    var str: String = "12 - 5"
    var ppos: ParsePosition = ParsePosition(0)
    var n1: Number = df.Parse(str, ppos)
    var n2: Number = df.Parse(str, ppos)
assertEquals("Should parse 12 and -5", 7, n1.ToInt32 + n2.ToInt32)
proc testSetPrefixDefaultSuffix*() =
    var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetPercentInstance)
    df.PositivePrefix = "+"
assertEquals("Should have manual plus sign and auto percent sign", "+100%", df.Format(1))
proc testMultiCodePointPaddingInPattern*() =
    var df: DecimalFormat = DecimalFormat("a*'நி'###0b")
    var result: String = df.Format(12)
assertEquals("Multi-codepoint padding should not be split", "aநிநி12b", result)
    df = DecimalFormat("a*😁###0b")
    result = df.Format(12)
assertEquals("Single-codepoint padding should not be split", "a😁😁12b", result)
    df = DecimalFormat("a*''###0b")
    result = df.Format(12)
assertEquals("Quote should be escapable in padding syntax", "a''12b", result)
proc testParseAmbiguousAffixes*() =
    var positive: BigDecimal = BigDecimal.Parse("0.0567", CultureInfo.InvariantCulture)
    var negative: BigDecimal = BigDecimal.Parse("-0.0567", CultureInfo.InvariantCulture)
    var df: DecimalFormat = DecimalFormat
    df.ParseToBigDecimal = true
    var patterns: string[] = @["+0.00%;-0.00%", "+0.00%;0.00%", "0.00%;-0.00%"]
    var inputs: string[] = @["+5.67%", "-5.67%", "5.67%"]
    var expectedPositive: bool[][] = @[@[true, false, true], @[true, false, false], @[true, false, true]]
      var i: int = 0
      while i < patterns.Length:
          var pattern: String = patterns[i]
df.ApplyPattern(pattern)
            var j: int = 0
            while j < inputs.Length:
                var input: String = inputs[j]
                var ppos: ParsePosition = ParsePosition(0)
                var actual: Number = df.Parse(input, ppos)
                var expected: BigDecimal =                 if expectedPositive[i][j]:
positive
                else:
negative
                var message: String = "Pattern " + pattern + " with input " + input
assertEquals(message, expected, actual)
assertEquals(message, input.Length, ppos.Index)
++j
++i
proc testParseIgnorables*() =
    var dfs: DecimalFormatSymbols = DecimalFormatSymbols.GetInstance
    dfs.PercentString = "‎%‎"
    var df: DecimalFormat = DecimalFormat("0 %;-0a", dfs)
    var ppos: ParsePosition = ParsePosition(0)
    var result: Number = df.Parse("42‎%‎ ", ppos)
assertEquals("Should parse as percentage", BigDecimal.Parse("0.42", CultureInfo.InvariantCulture), result)
assertEquals("Should consume the trailing bidi since it is in the symbol", 5, ppos.Index)
    ppos.Index = 0
    result = df.Parse("-42a‎ ", ppos)
assertEquals("Should parse as percent", BigDecimal.Parse("-0.42", CultureInfo.InvariantCulture), result)
assertEquals("Should not consume the trailing bidi or whitespace", 4, ppos.Index)
expect(df, "42%", 0.42)
expect(df, "42 %", 0.42)
expect(df, "42   %", 0.42)
expect(df, "42 %", 0.42)
proc testCustomCurrencyUsageOverridesPattern*() =
    var df: DecimalFormat = DecimalFormat("#,##0.###")
expect2(df, 1234, "1,234")
    df.CurrencyUsage = CurrencyUsage.Standard
expect2(df, 1234, "1,234.00")
df.SetCurrencyUsage(nil)
expect2(df, 1234, "1,234")
proc testCurrencyUsageFractionOverrides*() =
    var df: NumberFormat = DecimalFormat.GetCurrencyInstance(UCultureInfo("en-US"))
expect2(df, 35.0, "$35.00")
    df.MinimumFractionDigits = 3
expect2(df, 35.0, "$35.000")
    df.MaximumFractionDigits = 3
expect2(df, 35.0, "$35.000")
    df.MinimumFractionDigits = -1
expect2(df, 35.0, "$35")
    df.MaximumFractionDigits = -1
expect2(df, 35.0, "$35.00")
proc testParseVeryVeryLargeExponent*() =
    var df: DecimalFormat = DecimalFormat
    var ppos: ParsePosition = ParsePosition(0)
    var cases: object[][] = @[@["1.2E+1234567890", Double.GetInstance(double.PositiveInfinity)], @["1.2E+999999999", BigDecimal.Parse("1.2E+999999999", CultureInfo.InvariantCulture)], @["1.2E+1000000000", Double.GetInstance(double.PositiveInfinity)], @["-1.2E+999999999", BigDecimal.Parse("-1.2E+999999999", CultureInfo.InvariantCulture)], @["-1.2E+1000000000", Double.GetInstance(double.NegativeInfinity)], @["1.2E-999999999", BigDecimal.Parse("1.2E-999999999", CultureInfo.InvariantCulture)], @["1.2E-1000000000", Double.GetInstance(0.0)], @["-1.2E-999999999", BigDecimal.Parse("-1.2E-999999999", CultureInfo.InvariantCulture)], @["-1.2E-1000000000", Double.GetInstance(-0.0)]]
    for cas in cases:
        ppos.Index = 0
        var input: string = cast[string](cas[0])
        var expected: Number = cast[Number](cas[1])
        var actual: Number = df.Parse(input, ppos)
assertEquals(input, expected, actual)
proc testStringMethodsNPE*() =
    var npeMethods: string[] = @["ApplyLocalizedPattern", "ApplyPattern", "set_NegativePrefix", "set_NegativeSuffix", "set_PositivePrefix", "set_PositiveSuffix"]
    for npeMethod in npeMethods:
        var df: DecimalFormat = DecimalFormat
        try:
type(DecimalFormat).GetMethod(npeMethod, @[type(string)]).Invoke(df, @[cast[string](nil)])
fail("NullPointerException not thrown in method " + npeMethod)
        except TargetInvocationException:
assertTrue("Exception should be NullPointerException in method " + npeMethod, e.InnerException is ArgumentNullException)
        except Exception:
            raise AssertionException("Reflection error in method " + npeMethod + ": " + e.Message)
    try:
DecimalFormat(nil)
fail("NullPointerException not thrown in 1-parameter constructor")
    except ArgumentNullException:

    try:
DecimalFormat(nil, DecimalFormatSymbols)
fail("NullPointerException not thrown in 2-parameter constructor")
    except ArgumentNullException:

    try:
DecimalFormat(nil, DecimalFormatSymbols, CurrencyPluralInfo.GetInstance, 0)
fail("NullPointerException not thrown in 4-parameter constructor")
    except ArgumentNullException:

proc testParseGroupingMode*() =
    var locales: UCultureInfo[] = @[UCultureInfo("en-US"), UCultureInfo("fr-FR"), UCultureInfo("de-CH"), UCultureInfo("es-PY")]
    var inputs: string[] = @["12,345.67", "12 345,67", "12'345.67", "12.345,67", "12,345", "12 345", "12'345", "12.345"]
    var outputs: BigDecimal[] = @[BigDecimal.Parse("12345.67", CultureInfo.InvariantCulture), BigDecimal.Parse("12345.67", CultureInfo.InvariantCulture), BigDecimal.Parse("12345.67", CultureInfo.InvariantCulture), BigDecimal.Parse("12345.67", CultureInfo.InvariantCulture), BigDecimal.Parse("12345", CultureInfo.InvariantCulture), BigDecimal.Parse("12345", CultureInfo.InvariantCulture), BigDecimal.Parse("12345", CultureInfo.InvariantCulture), BigDecimal.Parse("12345", CultureInfo.InvariantCulture)]
    var expecteds: int[][] = @[@[3, 0, 1, 0, 3, 1, 1, 0], @[0, 3, 0, 1, 0, 3, 3, 1], @[1, 0, 3, 0, 1, 3, 3, 0], @[0, 1, 0, 3, 0, 1, 1, 3]]
      var i: int = 0
      while i < locales.Length:
          var loc: UCultureInfo = locales[i]
          var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetInstance(loc))
          df.ParseToBigDecimal = true
            var j: int = 0
            while j < inputs.Length:
                var input: String = inputs[j]
                var output: BigDecimal = outputs[j]
                var expected: int = expecteds[i][j]
                var ppos: ParsePosition = ParsePosition(0)
                var result: Number = df.Parse(input, ppos)
                var actualNull: bool = output.Equals(result) && ppos.Index == input.Length
assertEquals("Locale " + loc + ", string "" + input + "", DEFAULT, " + "actual result: " + result + " (ppos: " + ppos.Index + ")", expected & 1 != 0, actualNull)
++j
++i
proc testParseNoExponent*() =
    var df: DecimalFormat = DecimalFormat
assertEquals("Parse no exponent has wrong default", false, df.ParseNoExponent)
    var result1: Number = df.Parse("123E4")
    df.ParseNoExponent = true
assertEquals("Parse no exponent getter is broken", true, df.ParseNoExponent)
    var result2: Number = df.Parse("123E4")
assertEquals("Exponent did not parse before setParseNoExponent", result1, Long.GetInstance(1230000))
assertEquals("Exponent parsed after setParseNoExponent", result2, Long.GetInstance(123))
proc testMinimumGroupingDigits*() =
    var allExpected: string[][] = @[@["123", "123"], @["1,230", "1230"], @["12,300", "12,300"], @["1,23,000", "1,23,000"]]
    var df: DecimalFormat = DecimalFormat("#,##,##0")
assertEquals("Minimum grouping digits has wrong default", 1, df.MinimumGroupingDigits)
      var l: int = 123
      while l <= 123000:
          df.MinimumGroupingDigits = 1
assertEquals("Minimum grouping digits getter is broken", 1, df.MinimumGroupingDigits)
          var actual: String = df.Format(l)
assertEquals("Output is wrong for 1, " + i, allExpected[i][0], actual)
          df.MinimumGroupingDigits = 2
assertEquals("Minimum grouping digits getter is broken", 2, df.MinimumGroupingDigits)
          actual = df.Format(l)
assertEquals("Output is wrong for 2, " + i, allExpected[i][1], actual)
          l = 10
proc testParseCaseSensitive*() =
    var patterns: string[] = @["a#b", "A#B"]
    var inputs: string[] = @["a500b", "A500b", "a500B", "a500e10b", "a500E10b"]
    var expectedParsePositions: int[][] = @[@[5, 5, 5, 8, 8], @[5, 0, 4, 4, 8], @[5, 5, 5, 8, 8], @[0, 4, 0, 0, 0]]
      var p: int = 0
      while p < patterns.Length:
          var pat: String = patterns[p]
          var df: DecimalFormat = DecimalFormat(pat)
assertEquals("parseCaseSensitive default is wrong", false, df.ParseCaseSensitive)
            var i: int = 0
            while i < inputs.Length:
                var inp: String = inputs[i]
                df.ParseCaseSensitive = false
assertEquals("parseCaseSensitive getter is broken", false, df.ParseCaseSensitive)
                var actualInsensitive: ParsePosition = ParsePosition(0)
df.Parse(inp, actualInsensitive)
assertEquals("Insensitive, pattern " + p + ", input " + i, expectedParsePositions[p * 2][i], actualInsensitive.Index)
                df.ParseCaseSensitive = true
assertEquals("parseCaseSensitive getter is broken", true, df.ParseCaseSensitive)
                var actualSensitive: ParsePosition = ParsePosition(0)
df.Parse(inp, actualSensitive)
assertEquals("Sensitive, pattern " + p + ", input " + i, expectedParsePositions[p * 2 + 1][i], actualSensitive.Index)
++i
++p
proc testPlusSignAlwaysShown*() =
    var numbers: double[] = @[0.012, 5.78, 0, -0.012, -5.78]
    var locs: UCultureInfo[] = @[UCultureInfo("en-US"), UCultureInfo("ar-EG"), UCultureInfo("es-CL")]
    var expecteds: string[][][] = @[@[@["+0.012", "+5.78", "+0", "-0.012", "-5.78"], @["+$0.01", "+$5.78", "+$0.00", "-$0.01", "-$5.78"]], @[@["؜+٠٫٠١٢", "؜+٥٫٧٨", "؜+٠", "؜-٠٫٠١٢", "؜-٥٫٧٨"], @["؜+٠٫٠١ ج.م.‏", "؜+٥٫٧٨ ج.م.‏", "؜+٠٫٠٠ ج.م.‏", "؜-٠٫٠١ ج.م.‏", "؜-٥٫٧٨ ج.م.‏"]], @[@["+0,012", "+5,78", "+0", "-0,012", "-5,78"], @["$+0", "$+6", "$+0", "$-0", "$-6"]]]
      var i: int = 0
      while i < locs.Length:
          var loc: UCultureInfo = locs[i]
          var df1: DecimalFormat = cast[DecimalFormat](NumberFormat.GetNumberInstance(loc))
assertFalse("Default should be false", df1.SignAlwaysShown)
          df1.SignAlwaysShown = true
assertTrue("Getter should now return true", df1.SignAlwaysShown)
          var df2: DecimalFormat = cast[DecimalFormat](NumberFormat.GetCurrencyInstance(loc))
assertFalse("Default should be false", df2.SignAlwaysShown)
          df2.SignAlwaysShown = true
assertTrue("Getter should now return true", df2.SignAlwaysShown)
            var j: int = 0
            while j < 2:
                var df: DecimalFormat =                 if j == 0:
df1
                else:
df2
                  var k: int = 0
                  while k < numbers.Length:
                      var d: double = numbers[k]
                      var exp: String = expecteds[i][j][k]
                      var act: String = df.Format(d)
assertEquals("Locale " + loc + ", type " + j + ", " + d, exp, act)
                      var parsedExp: BigDecimal = BigDecimal.GetInstance(d)
                      if j == 1:
                          var scale: int =                           if i == 2:
0
                          else:
2
                          parsedExp = parsedExp.SetScale(scale, BigDecimal.RoundHalfEven)
                      var parsedNum: Number = df.Parse(exp)
                      var parsedAct: BigDecimal =                       if parsedNum.GetType == type(BigDecimal):
cast[BigDecimal](parsedNum)
                      else:
BigDecimal.GetInstance(parsedNum.ToDouble)
assertEquals("Locale " + loc + ", type " + j + ", " + d + ", " + parsedExp + " => " + parsedAct, 0, parsedExp.CompareTo(parsedAct))
++k
++j
++i
type
  PropertySetterAnonymousClass = ref object
    rules: PluralRules

proc newPropertySetterAnonymousClass(rules: PluralRules): PropertySetterAnonymousClass =
  self.rules =   if rules != nil:
rules
  else:
      raise ArgumentNullException(nameof(rules))
proc Set*(props: Numerics.DecimalFormatProperties) =
    props.PluralRules = rules
proc TestCurrencyPluralInfoAndCustomPluralRules*() =
    var symbols: DecimalFormatSymbols = DecimalFormatSymbols.GetInstance(UCultureInfo("en"))
    var rules: PluralRules = PluralRules.ParseDescription("one: n is 1; few: n in 2..4")
    var info: CurrencyPluralInfo = CurrencyPluralInfo.GetInstance(UCultureInfo("en"))
info.SetCurrencyPluralPattern("one", "0 qwerty")
info.SetCurrencyPluralPattern("few", "0 dvorak")
    var df: DecimalFormat = DecimalFormat("#", symbols, info, NumberFormatStyle.CurrencyStyle)
    df.Currency = Currency.GetInstance("USD")
df.SetProperties(PropertySetterAnonymousClass(rules))
assertEquals("Plural one", "1.00 qwerty", df.Format(1))
assertEquals("Plural few", "3.00 dvorak", df.Format(3))
assertEquals("Plural other", "5.80 US dollars", df.Format(5.8))
proc TestNarrowCurrencySymbols*() =
    var df: DecimalFormat = cast[DecimalFormat](NumberFormat.GetCurrencyInstance(UCultureInfo("en-CA")))
    df.Currency = Currency.GetInstance("USD")
expect2(df, 123.45, "US$123.45")
    var pattern: String = df.ToPattern
    pattern = pattern.Replace("¤", "¤¤¤¤¤")
df.ApplyPattern(pattern)
assertEquals("Narrow currency symbol for USD in en_CA is $", "$123.45", df.Format(123.45))