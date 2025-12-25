# "Namespace: ICU4N.Dev.Test.Format"
type
  IntlTestDecimalFormatAPI = ref object


proc TestJB1871*() =
    var number: double = 8.88885
    var expected: String = "8.8889"
    var pat: String = ",##0.0000"
    var dec: DecimalFormat = DecimalFormat(pat)
    dec.RoundingMode = ICU4N.Numerics.BigMath.RoundingMode.HalfUp
dec.SetRoundingIncrement(ICU4N.Numerics.BigMath.BigDecimal.Parse("0.0001", CultureInfo.InvariantCulture))
    var str: String = dec.Format(number)
    if !str.Equals(expected, StringComparison.Ordinal):
Errln("Fail: " + number + " x "" + pat + "" = "" + str + "", expected "" + expected + """)
    pat = ",##0.0001"
    dec = DecimalFormat(pat)
    dec.RoundingMode = ICU4N.Numerics.BigMath.RoundingMode.HalfUp
    str = dec.Format(number)
    if !str.Equals(expected, StringComparison.Ordinal):
Errln("Fail: " + number + " x "" + pat + "" = "" + str + "", expected "" + expected + """)
    pat = ",##0.00000000000000000001"
    dec = DecimalFormat(pat)
    var bignumber: BigDecimal = BigDecimal.Parse("8.888888888888888888885", CultureInfo.InvariantCulture)
    expected = "8.88888888888888888889"
    dec.RoundingMode = ICU4N.Numerics.BigMath.RoundingMode.HalfUp
    str = dec.Format(bignumber)
    if !str.Equals(expected, StringComparison.Ordinal):
Errln("Fail: " + bignumber + " x "" + pat + "" = "" + str + "", expected "" + expected + """)
proc TestAPI*() =
Logln("DecimalFormat API test---")
Logln("")
    var context = CultureContext("en")
Logln("Testing DecimalFormat constructors")
    var def: DecimalFormat = DecimalFormat
    var pattern: string = "#,##0.# FF"
    var pat: DecimalFormat = nil
    try:
        pat = DecimalFormat(pattern)
    except ArgumentException:
Errln("ERROR: Could not create DecimalFormat (pattern)")
    var symbols: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("fr"))
    var cust1: DecimalFormat = DecimalFormat(pattern, symbols)
Logln("Testing clone() and equality operators")
    var clone: Formatter = cast[Formatter](def.Clone)
    if !def.Equals(clone):
Errln("ERROR: Clone() failed")
Logln("Testing various format() methods")
    var d: double = -10456.0037
    var l: long = 100000000
Logln("" + d + " is the double value")
    var res1: StringBuffer = StringBuffer
    var res2: StringBuffer = StringBuffer
    var res3: StringBuffer = StringBuffer
    var res4: StringBuffer = StringBuffer
    var pos1: FieldPosition = FieldPosition(0)
    var pos2: FieldPosition = FieldPosition(0)
    var pos3: FieldPosition = FieldPosition(0)
    var pos4: FieldPosition = FieldPosition(0)
    res1 = def.Format(d, res1, pos1)
Logln("" + d + " formatted to " + res1)
    res2 = pat.Format(l, res2, pos2)
Logln("" + l + " formatted to " + res2)
    res3 = cust1.Format(d, res3, pos3)
Logln("" + d + " formatted to " + res3)
    res4 = cust1.Format(l, res4, pos4)
Logln("" + l + " formatted to " + res4)
Logln("Testing parse()")
    var text: String = "-10,456.0037"
    var pos: ParsePosition = ParsePosition(0)
    var patt: String = "#,##0.#"
pat.ApplyPattern(patt)
    var d2: double = pat.Parse(text, pos).ToDouble
    if d2 != d:
Errln("ERROR: Roundtrip failed (via parse(" + d2 + " != " + d + ")) for " + text)
Logln(text + " parsed into " + cast[long](d2))
Logln("Testing getters and setters")
    var syms: DecimalFormatSymbols = pat.GetDecimalFormatSymbols
def.SetDecimalFormatSymbols(syms)
    if !pat.GetDecimalFormatSymbols.Equals(def.GetDecimalFormatSymbols):
Errln("ERROR: set DecimalFormatSymbols() failed")
    var posPrefix: String
    pat.PositivePrefix = "+"
    posPrefix = pat.PositivePrefix
Logln("Positive prefix (should be +): " + posPrefix)
assertEquals("ERROR: setPositivePrefix() failed", "+", posPrefix)
    var negPrefix: String
    pat.NegativePrefix = "-"
    negPrefix = pat.NegativePrefix
Logln("Negative prefix (should be -): " + negPrefix)
assertEquals("ERROR: setNegativePrefix() failed", "-", negPrefix)
    var posSuffix: String
    pat.PositiveSuffix = "_"
    posSuffix = pat.PositiveSuffix
Logln("Positive suffix (should be _): " + posSuffix)
assertEquals("ERROR: setPositiveSuffix() failed", "_", posSuffix)
    var negSuffix: String
    pat.NegativeSuffix = "~"
    negSuffix = pat.NegativeSuffix
Logln("Negative suffix (should be ~): " + negSuffix)
assertEquals("ERROR: setNegativeSuffix() failed", "~", negSuffix)
    var multiplier: long = 0
    pat.Multiplier = 8
    multiplier = pat.Multiplier
Logln("Multiplier (should be 8): " + multiplier)
    if multiplier != 8:
Errln("ERROR: setMultiplier() failed")
    var groupingSize: int = 0
    pat.GroupingSize = 2
    groupingSize = pat.GroupingSize
Logln("Grouping size (should be 2): " + cast[long](groupingSize))
    if groupingSize != 2:
Errln("ERROR: setGroupingSize() failed")
    pat.DecimalSeparatorAlwaysShown = true
    var tf: bool = pat.DecimalSeparatorAlwaysShown
Logln("DecimalSeparatorIsAlwaysShown (should be true) is " +     if tf:
"true"
    else:
"false")
    if tf != true:
Errln("ERROR: setDecimalSeparatorAlwaysShown() failed")
    var funkyPat: String
    funkyPat = pat.ToPattern
Logln("Pattern is " + funkyPat)
    var locPat: String
    locPat = pat.ToLocalizedPattern
Logln("Localized pattern is " + locPat)
Logln("Testing applyPattern()")
    var p1: String = "#,##0.0#;(#,##0.0#)"
Logln("Applying pattern " + p1)
pat.ApplyPattern(p1)
    var s2: String
    s2 = pat.ToPattern
Logln("Extracted pattern is " + s2)
    if !s2.Equals(p1, StringComparison.Ordinal):
Errln("ERROR: toPattern() result did not match pattern applied")
    var p2: String = "#,##0.0# FF;(#,##0.0# FF)"
Logln("Applying pattern " + p2)
pat.ApplyLocalizedPattern(p2)
    var s3: String
    s3 = pat.ToLocalizedPattern
Logln("Extracted pattern is " + s3)
    if !s3.Equals(p2, StringComparison.Ordinal):
Errln("ERROR: toLocalizedPattern() result did not match pattern applied")
proc TestJB6134*() =
    var decfmt: DecimalFormat = DecimalFormat
    var buf: StringBuffer = StringBuffer
    var fposByInt: FieldPosition = FieldPosition(NumberFormat.IntegerField)
decfmt.Format(123, buf, fposByInt)
    buf.Length = 0
    var fposByField: FieldPosition = FieldPosition(NumberFormatField.Integer)
decfmt.Format(123, buf, fposByField)
    if fposByInt.EndIndex != fposByField.EndIndex:
Errln("ERROR: End index for integer field - fposByInt:" + fposByInt.EndIndex + " / fposByField: " + fposByField.EndIndex)
proc TestJB4971*() =
    var decfmt: DecimalFormat = DecimalFormat
    var resultICU: MathContext
    var comp1: MathContext = MathContext(0, MathContext.Plain, false, MathContext.RoundHalfEven)
    resultICU = decfmt.MathContextICU
    if comp1.Digits != resultICU.Digits || comp1.Form != resultICU.Form || comp1.LostDigits != resultICU.LostDigits || comp1.RoundingMode != resultICU.RoundingMode:
Errln("ERROR: Math context 1 not equal - result: " + resultICU.ToString + " / expected: " + comp1.ToString)
    var comp2: MathContext = MathContext(5, MathContext.Engineering, false, MathContext.RoundHalfEven)
    decfmt.MathContextICU = comp2
    resultICU = decfmt.MathContextICU
    if comp2.Digits != resultICU.Digits || comp2.Form != resultICU.Form || comp2.LostDigits != resultICU.LostDigits || comp2.RoundingMode != resultICU.RoundingMode:
Errln("ERROR: Math context 2 not equal - result: " + resultICU.ToString + " / expected: " + comp2.ToString)
    var result: ICU4N.Numerics.BigMath.MathContext
    var comp3: ICU4N.Numerics.BigMath.MathContext = ICU4N.Numerics.BigMath.MathContext(3, ICU4N.Numerics.BigMath.RoundingMode.Down)
    decfmt.MathContext = comp3
    result = decfmt.MathContext
    if comp3.Precision != result.Precision || comp3.RoundingMode != result.RoundingMode:
Errln("ERROR: Math context 3 not equal - result: " + result.ToString + " / expected: " + comp3.ToString)
proc TestJB6354*() =
    var pat: DecimalFormat = DecimalFormat("#,##0.00")
      var r1: ICU4N.Numerics.BigMath.BigDecimal
      var r2: ICU4N.Numerics.BigMath.BigDecimal
    r1 = pat.RoundingIncrement
    pat.RoundingMode = ICU4N.Numerics.BigMath.RoundingMode.Up
    r2 = pat.RoundingIncrement
    if r1 != nil && r2 != nil:
        if r1.CompareTo(r2) == 0:
Errln("ERROR: Rounding increment did not change")
proc TestJB6648*() =
    var df: DecimalFormat = DecimalFormat
    df.ParseStrict = true
    var numstr: String
    var patterns: String[] = @["0", "00", "000", "0,000", "0.0", "#000.0"]
      var i: int = 0
      while i < patterns.Length:
df.ApplyPattern(patterns[i])
          numstr = df.Format(5)
          try:
              var n: Number = df.Parse(numstr)
Logln("INFO: Parsed " + numstr + " -> " + n)
          except FormatException:
Errln("ERROR: Failed round trip with strict parsing.")
++i
df.ApplyPattern(patterns[1])
    numstr = "005"
    try:
        var n: Number = df.Parse(numstr)
Logln("INFO: Successful parse for " + numstr + " with strict parse enabled. Number is " + n)
    except FormatException:
Errln("ERROR: Parse Exception encountered in strict mode: numstr -> " + numstr)