# "Namespace: ICU4N.Dev.Test.Format"
type
  NumberFormatDataDrivenTest = ref object
    EN: UCultureInfo = UCultureInfo("en")
    ICU60: DataDrivenNumberFormatTestUtility.CodeUnderTest = ICU60CodeUnderTestAnonymousClass
    ICU60_Other: DataDrivenNumberFormatTestUtility.CodeUnderTest = ICU60OtherCodeUnderTestAnonymousClass

proc toNumber(s: String): Number =
    if s.Equals("NaN", StringComparison.Ordinal):
        return Double.GetInstance(double.NaN)

    elif s.Equals("-Inf", StringComparison.Ordinal):
        return Double.GetInstance(double.NegativeInfinity)
    else:
      if s.Equals("Inf", StringComparison.Ordinal):
          return Double.GetInstance(double.PositiveInfinity)
    return ICU4N.Numerics.BigMath.BigDecimal.Parse(s, CultureInfo.InvariantCulture)
proc propertiesFromTuple(tuple: DataDrivenNumberFormatTestData, properties: DecimalFormatProperties) =
    if tuple.minIntegerDigits != nil:
        properties.MinimumIntegerDigits = tuple.minIntegerDigits
    if tuple.maxIntegerDigits != nil:
        properties.MaximumIntegerDigits = tuple.maxIntegerDigits
    if tuple.minFractionDigits != nil:
        properties.MinimumFractionDigits = tuple.minFractionDigits
    if tuple.maxFractionDigits != nil:
        properties.MaximumFractionDigits = tuple.maxFractionDigits
    if tuple.currency != nil:
        properties.Currency = tuple.currency
    if tuple.minGroupingDigits != nil:
        properties.MinimumGroupingDigits = tuple.minGroupingDigits
    if tuple.useSigDigits != nil:

    if tuple.minSigDigits != nil:
        properties.MinimumSignificantDigits = tuple.minSigDigits
    if tuple.maxSigDigits != nil:
        properties.MaximumSignificantDigits = tuple.maxSigDigits
    if tuple.useGrouping != nil && tuple.useGrouping == 0:
        properties.GroupingSize = -1
        properties.SecondaryGroupingSize = -1
    if tuple.multiplier != nil:
        properties.Multiplier = ICU4N.Numerics.BigMath.BigDecimal(tuple.multiplier)
    if tuple.roundingIncrement != nil:
        properties.RoundingIncrement = ICU4N.Numerics.BigMath.BigDecimal.Parse(tuple.roundingIncrement.ToString(CultureInfo.InvariantCulture), CultureInfo.InvariantCulture)
    if tuple.formatWidth != nil:
        properties.FormatWidth = tuple.formatWidth
    if tuple.padCharacter != nil && tuple.padCharacter.Length > 0:
        properties.PadString = tuple.padCharacter.ToString
    if tuple.useScientific != nil:
        properties.MinimumExponentDigits =         if tuple.useScientific != 0:
1
        else:
-1
    if tuple.grouping != nil:
        properties.GroupingSize = tuple.grouping
    if tuple.grouping2 != nil:
        properties.SecondaryGroupingSize = tuple.grouping2
    if tuple.roundingMode != nil:
        properties.RoundingMode = cast[ICU4N.Numerics.BigMath.RoundingMode?](tuple.roundingMode)
    if tuple.currencyUsage != nil:
        properties.CurrencyUsage = tuple.currencyUsage
    if tuple.minimumExponentDigits != nil:
        properties.MinimumExponentDigits = tuple.minimumExponentDigits.ToByte
    if tuple.exponentSignAlwaysShown != nil:
        properties.ExponentSignAlwaysShown = tuple.exponentSignAlwaysShown != 0
    if tuple.decimalSeparatorAlwaysShown != nil:
        properties.DecimalSeparatorAlwaysShown = tuple.decimalSeparatorAlwaysShown != 0
    if tuple.padPosition != nil:
        properties.PadPosition =         if tuple.padPosition.HasValue:
tuple.padPosition.Value.ToNew
        else:
nil
    if tuple.positivePrefix != nil:
        properties.PositivePrefix = tuple.positivePrefix
    if tuple.positiveSuffix != nil:
        properties.PositiveSuffix = tuple.positiveSuffix
    if tuple.negativePrefix != nil:
        properties.NegativePrefix = tuple.negativePrefix
    if tuple.negativeSuffix != nil:
        properties.NegativeSuffix = tuple.negativeSuffix
    if tuple.localizedPattern != nil:
        var symbols: DecimalFormatSymbols = DecimalFormatSymbols.GetInstance(tuple.locale)
        var converted: String = PatternStringUtils.ConvertLocalized(tuple.localizedPattern, symbols, false)
PatternStringParser.ParseToExistingProperties(converted, properties)
    if tuple.lenient != nil:
        properties.ParseMode =         if tuple.lenient == 0:
Parser.ParseMode.Strict
        else:
Parser.ParseMode.Lenient
    if tuple.parseIntegerOnly != nil:
        properties.ParseIntegerOnly = tuple.parseIntegerOnly != 0
    if tuple.parseCaseSensitive != nil:
        properties.ParseCaseSensitive = tuple.parseCaseSensitive != 0
    if tuple.decimalPatternMatchRequired != nil:
        properties.DecimalPatternMatchRequired = tuple.decimalPatternMatchRequired != 0
    if tuple.parseNoExponent != nil:
        properties.ParseNoExponent = tuple.parseNoExponent != 0
type
  ICU60CodeUnderTestAnonymousClass = ref object


proc Id(): Option[char] =
    return 'Q'
proc Format*(tuple: DataDrivenNumberFormatTestData): string =
    var pattern: String =     if tuple.pattern == nil:
"0"
    else:
tuple.pattern
    var locale: UCultureInfo =     if tuple.locale == nil:
UCultureInfo("en")
    else:
tuple.locale
    var properties: DecimalFormatProperties = PatternStringParser.ParseToProperties(pattern,     if tuple.currency != nil:
PatternStringParser.IGNORE_ROUNDING_ALWAYS
    else:
PatternStringParser.IGNORE_ROUNDING_NEVER)
propertiesFromTuple(tuple, properties)
    var symbols: DecimalFormatSymbols = DecimalFormatSymbols.GetInstance(locale)
    var fmt: LocalizedNumberFormatter = NumberFormatter.FromDecimalFormat(properties, symbols, nil).Culture(locale)
    var number: Number = toNumber(tuple.format)
    var expected: String = tuple.output
    var actual: String = fmt.Format(number).ToString
    if !expected.Equals(actual, StringComparison.Ordinal):
        return "Expected "" + expected + "", got "" + actual + """
    return nil
type
  DecimalFormatPropertySetter = ref object
    properties: DecimalFormatProperties

proc newDecimalFormatPropertySetter(properties: DecimalFormatProperties): DecimalFormatPropertySetter =
  self.properties =   if properties != nil:
properties
  else:
      raise ArgumentNullException(nameof(properties))
proc Set*(props: DecimalFormatProperties) =
props.CopyFrom(properties)
type
  ICU60OtherCodeUnderTestAnonymousClass = ref object


proc Id(): Option[char] =
    return 'S'
proc ToPattern*(tuple: DataDrivenNumberFormatTestData): string =
    var pattern: String =     if tuple.pattern == nil:
"0"
    else:
tuple.pattern
    var properties: DecimalFormatProperties
    var df: DecimalFormat
    try:
        properties = PatternStringParser.ParseToProperties(pattern,         if tuple.currency != nil:
PatternStringParser.IGNORE_ROUNDING_ALWAYS
        else:
PatternStringParser.IGNORE_ROUNDING_NEVER)
propertiesFromTuple(tuple, properties)
        df = DecimalFormat
df.SetProperties(DecimalFormatPropertySetter(properties))
    except ArgumentException:
Console.WriteLine(e.ToString)
        return e.ToString
    if tuple.toPattern != nil:
        var expected: String = tuple.toPattern
        var actual: String = df.ToPattern
        if !expected.Equals(actual, StringComparison.Ordinal):
            return "Expected toPattern='" + expected + "'; got '" + actual + "'"
    if tuple.toLocalizedPattern != nil:
        var expected: String = tuple.toLocalizedPattern
        var actual: String = PatternStringUtils.PropertiesToPatternString(properties)
        if !expected.Equals(actual, StringComparison.Ordinal):
            return "Expected toLocalizedPattern='" + expected + "'; got '" + actual + "'"
    return nil
proc Parse*(tuple: DataDrivenNumberFormatTestData): string =
    var pattern: String =     if tuple.pattern == nil:
"0"
    else:
tuple.pattern
    var properties: DecimalFormatProperties
    var ppos: ParsePosition = ParsePosition(0)
    var actual: Number
    try:
        properties = PatternStringParser.ParseToProperties(pattern,         if tuple.currency != nil:
PatternStringParser.IGNORE_ROUNDING_ALWAYS
        else:
PatternStringParser.IGNORE_ROUNDING_NEVER)
propertiesFromTuple(tuple, properties)
        actual = Parser.Parse(tuple.parse, ppos, properties, DecimalFormatSymbols.GetInstance(tuple.locale))
    except ArgumentException:
        return "parse exception: " + e.Message
    if actual == nil && ppos.Index != 0:
        raise AssertionException("Error: value is null but parse position is not zero")
    if ppos.Index == 0:
        return "Parse failed; got " + actual + ", but expected " + tuple.output
    if tuple.output.Equals("NaN", StringComparison.Ordinal):
        if !double.IsNaN(actual.ToDouble):
            return "Expected NaN, but got: " + actual
        return nil

    elif tuple.output.Equals("Inf", StringComparison.Ordinal):
        if !double.IsInfinity(actual.ToDouble) || JCG.Comparer.Default.Compare(actual.ToDouble, 0.0) < 0:
            return "Expected Inf, but got: " + actual
        return nil
    else:
      if tuple.output.Equals("-Inf", StringComparison.Ordinal):
          if !double.IsInfinity(actual.ToDouble) || JCG.Comparer.Default.Compare(actual.ToDouble, 0.0) > 0:
              return "Expected -Inf, but got: " + actual
          return nil

      elif tuple.output.Equals("fail", StringComparison.Ordinal):
          return nil
      else:
        if ICU4N.Numerics.BigMath.BigDecimal.Parse(tuple.output).CompareTo(ICU4N.Numerics.BigMath.BigDecimal.Parse(actual.ToString(CultureInfo.InvariantCulture))) != 0:
            return "Expected: " + tuple.output + ", got: " + actual
        else:
            return nil
proc ParseCurrency*(tuple: DataDrivenNumberFormatTestData): string =
    var pattern: String =     if tuple.pattern == nil:
"0"
    else:
tuple.pattern
    var properties: DecimalFormatProperties
    var ppos: ParsePosition = ParsePosition(0)
    var actual: CurrencyAmount
    try:
        properties = PatternStringParser.ParseToProperties(pattern,         if tuple.currency != nil:
PatternStringParser.IGNORE_ROUNDING_ALWAYS
        else:
PatternStringParser.IGNORE_ROUNDING_NEVER)
propertiesFromTuple(tuple, properties)
        actual = Parser.ParseCurrency(tuple.parse, ppos, properties, DecimalFormatSymbols.GetInstance(tuple.locale))
    except ParseException:
Console.WriteLine(e.ToString)
        return "parse exception: " + e.Message
    if ppos.Index == 0 || actual.Currency.CurrencyCode.Equals("XXX", StringComparison.Ordinal):
        return "Parse failed; got " + actual + ", but expected " + tuple.output
    var expectedNumber: ICU4N.Numerics.BigMath.BigDecimal = ICU4N.Numerics.BigMath.BigDecimal.Parse(tuple.output, CultureInfo.InvariantCulture)
    if expectedNumber.CompareTo(ICU4N.Numerics.BigMath.BigDecimal.Parse(actual.Number.ToString(CultureInfo.InvariantCulture))) != 0:
        return "Wrong number: Expected: " + expectedNumber + ", got: " + actual
    var expectedCurrency: String = tuple.outputCurrency
    if !expectedCurrency.Equals(actual.Currency.ToString):
        return "Wrong currency: Expected: " + expectedCurrency + ", got: " + actual
    return nil
proc Select*(tuple: DataDrivenNumberFormatTestData): string =
    return nil
proc TestDataDrivenICU58*() =
    raise NotImplementedException
proc TestDataDrivenICULatest_Format*() =
DataDrivenNumberFormatTestUtility.runFormatSuiteIncludingKnownFailures("numberformattestspecification.txt", ICU60)
proc TestDataDrivenICULatest_Other*() =
DataDrivenNumberFormatTestUtility.runFormatSuiteIncludingKnownFailures("numberformattestspecification.txt", ICU60_Other)