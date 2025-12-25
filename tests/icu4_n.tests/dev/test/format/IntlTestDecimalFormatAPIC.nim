# "Namespace: ICU4N.Dev.Test.Format"
type
  IntlTestDecimalFormatAPIC = ref object


proc TestAPI*() =
Logln("DecimalFormat API test---")
Logln("")
    procCall.CurrentCulture = CultureInfo("en")
Logln("Testing DecimalFormat constructors")
    var def: DecimalFormat = DecimalFormat
    var pattern: String = "#,##0.# FF"
    var symbols: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("fr"))
    var infoInput: CurrencyPluralInfo = CurrencyPluralInfo(UCultureInfo("fr"))
    var pat: DecimalFormat = nil
    try:
        pat = DecimalFormat(pattern)
    except ArgumentException:
Errln("ERROR: Could not create DecimalFormat (pattern)")
    var cust1: DecimalFormat = nil
    try:
        cust1 = DecimalFormat(pattern, symbols)
    except ArgumentException:
Errln("ERROR: Could not create DecimalFormat (pattern, symbols)")
    var cust2: DecimalFormat = nil
    try:
        cust2 = DecimalFormat(pattern, symbols, infoInput, NumberFormatStyle.PluralCurrencyStyle)
    except ArgumentException:
Errln("ERROR: Could not create DecimalFormat (pattern, symbols, infoInput, style)")
Logln("Testing clone() and equality operators")
    var clone: UFormat = cast[UFormat](def.Clone)
    if !def.Equals(clone):
Errln("ERROR: Clone() failed")
Logln("Testing various format() methods")
    var d: double = -10456.0037
    var l: long = 100000000
Logln("" + d.ToString(CultureInfo.InvariantCulture) + " is the double value")
    var res1: StringBuffer = StringBuffer
    var res2: StringBuffer = StringBuffer
    var res3: StringBuffer = StringBuffer
    var res4: StringBuffer = StringBuffer
    var pos1: FieldPosition = FieldPosition(0)
    var pos2: FieldPosition = FieldPosition(0)
    var pos3: FieldPosition = FieldPosition(0)
    var pos4: FieldPosition = FieldPosition(0)
    res1 = def.Format(d, res1, pos1)
Logln("" + Double.ToString(d, CultureInfo.InvariantCulture) + " formatted to " + res1)
    res2 = pat.Format(l, res2, pos2)
Logln("" + l + " formatted to " + res2)
    res3 = cust1.Format(d, res3, pos3)
Logln("" + Double.ToString(d, CultureInfo.InvariantCulture) + " formatted to " + res3)
    res4 = cust1.Format(l, res4, pos4)
Logln("" + l + " formatted to " + res4)
Logln("Testing parse()")
    var text: String = "-10,456.0037"
    var pos: ParsePosition = ParsePosition(0)
    var patt: String = "#,##0.#"
pat.ApplyPattern(patt)
    var d2: double = pat.Parse(text, pos).ToDouble
    if d2 != d:
Errln("ERROR: Roundtrip failed (via parse(" + Double.ToString(d2, CultureInfo.InvariantCulture) + " != " + Double.ToString(d, CultureInfo.InvariantCulture) + ")) for " + text)
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
    pat.CurrencyPluralInfo = infoInput
    if !infoInput.Equals(pat.CurrencyPluralInfo):
Errln("ERROR: set/get CurrencyPluralInfo() failed")
    pat.CurrencyPluralInfo = infoInput
    if !infoInput.Equals(pat.CurrencyPluralInfo):
Errln("ERROR: set/get CurrencyPluralInfo() failed")
Logln("Testing applyPattern()")
    var p1: String = "#,##0.0#;(#,##0.0#)"
Logln("Applying pattern " + p1)
pat.ApplyPattern(p1)
    var s2: String
    s2 = pat.ToPattern
Logln("Extracted pattern is " + s2)
    if !s2.Equals(p1, StringComparison.Ordinal):
Errln("ERROR: toPattern() result did not match pattern applied: " + p1 + " vs " + s2)
    var p2: String = "#,##0.0# FF;(#,##0.0# FF)"
Logln("Applying pattern " + p2)
pat.ApplyLocalizedPattern(p2)
    var s3: String
    s3 = pat.ToLocalizedPattern
Logln("Extracted pattern is " + s3)
assertEquals("ERROR: toLocalizedPattern() result did not match pattern applied", p2, s3)
proc TestRounding*() =
    var Roundingnumber: double = 2.55
    var Roundingnumber1: double = -2.55
    var result: double[] = @[3, -3, 2, -2, 3, -2, 2, -3, 3, -3, 3, -3, 3, -3]
    var pat: DecimalFormat = DecimalFormat
    var s: String = ""
    s = pat.ToPattern
Logln("pattern = " + s)
    var mode: int
    var i: int = 0
    var message: String
    var resultStr: String
      mode = 0
      while mode < 7:
          pat.RoundingMode = cast[Numerics.BigMath.RoundingMode](mode)
          if cast[int](pat.RoundingMode) != mode:
Errln("SetRoundingMode or GetRoundingMode failed for mode=" + mode)
pat.SetRoundingIncrement(Numerics.BigMath.BigDecimal.One)
          resultStr = pat.Format(Roundingnumber)
          message = "round(" + Roundingnumber + "," + mode + ",FALSE) with RoundingIncrement=1.0==>"
verify(message, resultStr, result[++i])
          message = ""
          resultStr = ""
          resultStr = pat.Format(Roundingnumber1)
          message = "round(" + Roundingnumber1 + "," + mode + ",FALSE) with RoundingIncrement=1.0==>"
verify(message, resultStr, result[++i])
          message = ""
          resultStr = ""
++mode
proc testFormatToCharacterIterator*() =
    var number: Number = Double.GetInstance(350.76)
    var negativeNumber: Number = Double.GetInstance(-350.76)
    var us: CultureInfo = CultureInfo("en-US")
t_Format(1, number, NumberFormat.GetNumberInstance(us), getNumberVectorUS)
t_Format(3, number, NumberFormat.GetPercentInstance(us), getPercentVectorUS)
    var format: DecimalFormat = DecimalFormat("###0.##‰")
t_Format(4, number, format, getPermilleVector)
    format = DecimalFormat("00.0#E0")
t_Format(5, number, format, getPositiveExponentVector)
    format = DecimalFormat("0000.0#E0")
t_Format(6, number, format, getNegativeExponentVector)
t_Format(7, number, NumberFormat.GetCurrencyInstance(us), getPositiveCurrencyVectorUS)
t_Format(8, negativeNumber, NumberFormat.GetCurrencyInstance(us), getNegativeCurrencyVectorUS)
    number = Long.GetInstance(100300400)
t_Format(11, number, NumberFormat.GetNumberInstance(us), getNumberVector2US)
    number = Long.GetInstance(0)
t_Format(12, number, NumberFormat.GetNumberInstance(us), getZeroVector)
proc getNumberVectorUS(): List<FieldContainer> =
    var v: List<FieldContainer> = List<FieldContainer>(3)
v.Add(FieldContainer(0, 3, NumberFormatField.Integer))
v.Add(FieldContainer(3, 4, NumberFormatField.DecimalSeparator))
v.Add(FieldContainer(4, 6, NumberFormatField.Fraction))
    return v
proc getPositiveCurrencyVectorUS(): IList<FieldContainer> =
    var v: List<FieldContainer> = List<FieldContainer>(4)
v.Add(FieldContainer(0, 1, NumberFormatField.Currency))
v.Add(FieldContainer(1, 4, NumberFormatField.Integer))
v.Add(FieldContainer(4, 5, NumberFormatField.DecimalSeparator))
v.Add(FieldContainer(5, 7, NumberFormatField.Fraction))
    return v
proc getNegativeCurrencyVectorUS(): IList<FieldContainer> =
    var v: List<FieldContainer> = List<FieldContainer>(4)
v.Add(FieldContainer(0, 1, NumberFormatField.Sign))
v.Add(FieldContainer(1, 2, NumberFormatField.Currency))
v.Add(FieldContainer(2, 5, NumberFormatField.Integer))
v.Add(FieldContainer(5, 6, NumberFormatField.DecimalSeparator))
v.Add(FieldContainer(6, 8, NumberFormatField.Fraction))
    return v
proc getPercentVectorUS(): IList<FieldContainer> =
    var v: List<FieldContainer> = List<FieldContainer>(5)
v.Add(FieldContainer(0, 2, NumberFormatField.Integer))
v.Add(FieldContainer(2, 3, NumberFormatField.Integer))
v.Add(FieldContainer(2, 3, NumberFormatField.GroupingSeparator))
v.Add(FieldContainer(3, 6, NumberFormatField.Integer))
v.Add(FieldContainer(6, 7, NumberFormatField.Percent))
    return v
proc getPermilleVector(): IList<FieldContainer> =
    var v: List<FieldContainer> = List<FieldContainer>(2)
v.Add(FieldContainer(0, 6, NumberFormatField.Integer))
v.Add(FieldContainer(6, 7, NumberFormatField.PerMille))
    return v
proc getNegativeExponentVector(): IList<FieldContainer> =
    var v: List<FieldContainer> = List<FieldContainer>(6)
v.Add(FieldContainer(0, 4, NumberFormatField.Integer))
v.Add(FieldContainer(4, 5, NumberFormatField.DecimalSeparator))
v.Add(FieldContainer(5, 6, NumberFormatField.Fraction))
v.Add(FieldContainer(6, 7, NumberFormatField.ExponentSymbol))
v.Add(FieldContainer(7, 8, NumberFormatField.ExponentSign))
v.Add(FieldContainer(8, 9, NumberFormatField.Exponent))
    return v
proc getPositiveExponentVector(): IList<FieldContainer> =
    var v: List<FieldContainer> = List<FieldContainer>(5)
v.Add(FieldContainer(0, 2, NumberFormatField.Integer))
v.Add(FieldContainer(2, 3, NumberFormatField.DecimalSeparator))
v.Add(FieldContainer(3, 5, NumberFormatField.Fraction))
v.Add(FieldContainer(5, 6, NumberFormatField.ExponentSymbol))
v.Add(FieldContainer(6, 7, NumberFormatField.Exponent))
    return v
proc getNumberVector2US(): IList<FieldContainer> =
    var v: List<FieldContainer> = List<FieldContainer>(7)
v.Add(FieldContainer(0, 3, NumberFormatField.Integer))
v.Add(FieldContainer(3, 4, NumberFormatField.GroupingSeparator))
v.Add(FieldContainer(3, 4, NumberFormatField.Integer))
v.Add(FieldContainer(4, 7, NumberFormatField.Integer))
v.Add(FieldContainer(7, 8, NumberFormatField.GroupingSeparator))
v.Add(FieldContainer(7, 8, NumberFormatField.Integer))
v.Add(FieldContainer(8, 11, NumberFormatField.Integer))
    return v
proc getZeroVector(): IList<FieldContainer> =
    var v: List<FieldContainer> = List<FieldContainer>(1)
v.Add(FieldContainer(0, 1, NumberFormatField.Integer))
    return v
proc t_Format(count: int, obj: Object, format: Formatter, expectedResults: IList[FieldContainer]) =
    var results: List<FieldContainer> = findFields(format.FormatToCharacterIterator(obj))
assertTrue("Test " + count + ": Format returned incorrect CharacterIterator for " + format.Format(obj), compare(results, expectedResults))
proc compare(vector1: IList[T], vector2: IList[T]): bool =
    return vector1.Count == vector2.Count && !vector2.Except(vector1).Any
proc findFields(iterator: AttributedCharacterIterator): List<FieldContainer> =
    var result: List<FieldContainer> = List<FieldContainer>
    while iterator.Index != iterator.EndIndex:
        var start: int = iterator.GetRunStart
        var end: int = iterator.GetRunLimit
        var it = iterator.GetAttributes.Keys.GetEnumerator
        while it.MoveNext:
            var attribute: AttributedCharacterIteratorAttribute = cast[AttributedCharacterIteratorAttribute](it.Current)
            var value: Object = iterator.GetAttribute(attribute)
result.Add(FieldContainer(start, end, attribute, value))
iterator.SetIndex(end)
    return result
proc verify*(message: string, got: string, expected: double) =
Logln(message + got + " Expected : " + cast[long](expected))
    var expectedStr: String = ""
    expectedStr = expectedStr + cast[long](expected)
    if !got.Equals(expectedStr, StringComparison.Ordinal):
Errln("ERROR: Round() failed:  " + message + got + "  Expected : " + expectedStr)
type
  FieldContainer = ref object
    start: int
    attribute: AttributedCharacterIteratorAttribute
    value: object

proc newFieldContainer(start: int, end: int, attribute: AttributedCharacterIteratorAttribute): FieldContainer =
newFieldContainer(start, end, attribute, attribute)
proc newFieldContainer(start: int, end: int, attribute: AttributedCharacterIteratorAttribute, value: int): FieldContainer =
newFieldContainer(start, end, attribute, cast[object](Integer.GetInstance(value)))
proc newFieldContainer(start: int, end: int, attribute: AttributedCharacterIteratorAttribute, value: object): FieldContainer =
  self.start = start
  self.end = end
  self.attribute = attribute
  self.value = value
proc Equals*(obj: Object): bool =
    if !obj:
      return false
    return start == fc.start && end == fc.end && attribute == fc.attribute && value.Equals(fc.value)
proc GetHashCode*(): int =
    return start.GetHashCode ^ end.GetHashCode