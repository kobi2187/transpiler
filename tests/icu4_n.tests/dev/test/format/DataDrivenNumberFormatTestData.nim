# "Namespace: ICU4N.Dev.Test.Format"
type
  DataDrivenNumberFormatTestData = ref object
    locale: UCultureInfo = nil
    currency: Currency = nil
    pattern: string = nil
    format: string = nil
    output: string = nil
    comment: string = nil
    minIntegerDigits: Integer = nil
    maxIntegerDigits: Integer = nil
    minFractionDigits: Integer = nil
    maxFractionDigits: Integer = nil
    minGroupingDigits: Integer = nil
    useSigDigits: Integer = nil
    minSigDigits: Integer = nil
    maxSigDigits: Integer = nil
    useGrouping: Integer = nil
    multiplier: Integer = nil
    roundingIncrement: Double = nil
    formatWidth: Integer = nil
    padCharacter: string = nil
    useScientific: Integer = nil
    grouping: Integer = nil
    grouping2: Integer = nil
    roundingMode: Option[RoundingMode] = nil
    currencyUsage: Option[CurrencyUsage] = nil
    minimumExponentDigits: Integer = nil
    exponentSignAlwaysShown: Integer = nil
    decimalSeparatorAlwaysShown: Integer = nil
    padPosition: Option[PadPosition] = nil
    positivePrefix: string = nil
    positiveSuffix: string = nil
    negativePrefix: string = nil
    negativeSuffix: string = nil
    localizedPattern: string = nil
    toPattern: string = nil
    toLocalizedPattern: string = nil
    style: Option[NumberFormatStyle] = nil
    parse: string = nil
    lenient: Integer = nil
    plural: string = nil
    parseIntegerOnly: Integer = nil
    decimalPatternMatchRequired: Integer = nil
    parseCaseSensitive: Integer = nil
    parseNoExponent: Integer = nil
    outputCurrency: string = nil
    breaks: string = nil
    roundingModeMap: IDictionary[String, int] = Dictionary<String, int>
    currencyUsageMap: IDictionary[String, CurrencyUsage] = Dictionary<String, CurrencyUsage>
    padPositionMap: IDictionary[String, PadPosition] = Dictionary<String, PadPosition>
    formatStyleMap: IDictionary[String, NumberFormatStyle] = Dictionary<String, NumberFormatStyle>
    fieldOrdering: seq[String] = @["locale", "currency", "pattern", "format", "output", "comment", "minIntegerDigits", "maxIntegerDigits", "minFractionDigits", "maxFractionDigits", "minGroupingDigits", "breaks", "useSigDigits", "minSigDigits", "maxSigDigits", "useGrouping", "multiplier", "roundingIncrement", "formatWidth", "padCharacter", "useScientific", "grouping", "grouping2", "roundingMode", "currencyUsage", "minimumExponentDigits", "exponentSignAlwaysShown", "decimalSeparatorAlwaysShown", "padPosition", "positivePrefix", "positiveSuffix", "negativePrefix", "negativeSuffix", "localizedPattern", "toPattern", "toLocalizedPattern", "style", "parse", "lenient", "plural", "parseIntegerOnly", "decimalPatternMatchRequired", "parseNoExponent", "outputCurrency"]

proc newDataDrivenNumberFormatTestData(): DataDrivenNumberFormatTestData =
  var set: HashSet<string> = HashSet<string>
  for s in fieldOrdering:
      if !set.Add(s):
          raise Exception(s + "is a duplicate field.")
proc fromString(map: IDictionary[string, T], key: string): T =
    if !map.TryGetValue(key,     var value: T) || value == nil:
        raise ArgumentException("Bad value: " + key)
    return value
proc setLocale*(value: string) =
    locale = UCultureInfo(value)
proc setCurrency*(value: string) =
    currency = Currency.GetInstance(value)
proc setPattern*(value: string) =
    pattern = value
proc setFormat*(value: string) =
    format = value
proc setOutput*(value: string) =
    output = value
proc setComment*(value: string) =
    comment = value
proc setMinIntegerDigits*(value: string) =
    minIntegerDigits = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setMaxIntegerDigits*(value: string) =
    maxIntegerDigits = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setMinFractionDigits*(value: string) =
    minFractionDigits = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setMaxFractionDigits*(value: string) =
    maxFractionDigits = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setMinGroupingDigits*(value: string) =
    minGroupingDigits = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setBreaks*(value: string) =
    breaks = value
proc setUseSigDigits*(value: string) =
    useSigDigits = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setMinSigDigits*(value: string) =
    minSigDigits = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setMaxSigDigits*(value: string) =
    maxSigDigits = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setUseGrouping*(value: string) =
    useGrouping = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setMultiplier*(value: string) =
    multiplier = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setRoundingIncrement*(value: string) =
    roundingIncrement = Double.GetInstance(Double.Parse(value, CultureInfo.InvariantCulture))
proc setFormatWidth*(value: string) =
    formatWidth = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setPadCharacter*(value: string) =
    padCharacter = value
proc setUseScientific*(value: string) =
    useScientific = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setGrouping*(value: string) =
    grouping = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setGrouping2*(value: string) =
    grouping2 = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setRoundingMode*(value: string) =
    roundingMode = cast[RoundingMode?](fromString(roundingModeMap, value))
proc setCurrencyUsage*(value: string) =
    currencyUsage = fromString(currencyUsageMap, value)
proc setMinimumExponentDigits*(value: string) =
    minimumExponentDigits = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setExponentSignAlwaysShown*(value: string) =
    exponentSignAlwaysShown = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setDecimalSeparatorAlwaysShown*(value: string) =
    decimalSeparatorAlwaysShown = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setPadPosition*(value: string) =
    padPosition = fromString(padPositionMap, value)
proc setPositivePrefix*(value: string) =
    positivePrefix = value
proc setPositiveSuffix*(value: string) =
    positiveSuffix = value
proc setNegativePrefix*(value: string) =
    negativePrefix = value
proc setNegativeSuffix*(value: string) =
    negativeSuffix = value
proc setLocalizedPattern*(value: string) =
    localizedPattern = value
proc setToPattern*(value: string) =
    toPattern = value
proc setToLocalizedPattern*(value: string) =
    toLocalizedPattern = value
proc setStyle*(value: string) =
    style = fromString(formatStyleMap, value)
proc setParse*(value: string) =
    parse = value
proc setLenient*(value: string) =
    lenient = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setPlural*(value: string) =
    plural = value
proc setParseIntegerOnly*(value: string) =
    parseIntegerOnly = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setParseCaseSensitive*(value: string) =
    parseCaseSensitive = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setDecimalPatternMatchRequired*(value: string) =
    decimalPatternMatchRequired = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setParseNoExponent*(value: string) =
    parseNoExponent = Integer.GetInstance(Integer.Parse(value, CultureInfo.InvariantCulture))
proc setOutputCurrency*(value: string) =
    outputCurrency = value
proc clearBreaks*() =
    breaks = nil
proc clearUseGrouping*() =
    useGrouping = nil
proc clearGrouping2*() =
    grouping2 = nil
proc clearGrouping*() =
    grouping = nil
proc clearMinGroupingDigits*() =
    minGroupingDigits = nil
proc clearUseScientific*() =
    useScientific = nil
proc clearDecimalSeparatorAlwaysShown*() =
    decimalSeparatorAlwaysShown = nil
proc setField*(fieldName: string, valueString: string) =
    var m: MethodInfo = GetType.GetMethod(fieldToSetter(fieldName), @[type(string)])
m.Invoke(self, @[valueString])
proc clearField*(fieldName: string) =
    var m: MethodInfo = GetType.GetMethod(fieldToClearer(fieldName))
m.Invoke(self, seq[object])
proc ToString*(): string =
    var result: StringBuilder = StringBuilder
result.Append("{")
    var first: bool = true
    for fieldName in fieldOrdering:
        var field: FieldInfo = GetType.GetField(fieldName)
        var optionalValue: object = field.GetValue(self)
        if optionalValue == nil:
            continue
        if !first:
result.Append(", ")
        first = false
result.Append(fieldName)
result.Append(": ")
result.Append(optionalValue)
result.Append("}")
    return result.ToString
proc fieldToSetter(fieldName: string): string =
    return "set" + char.ToUpperInvariant(fieldName[0]) + fieldName.Substring(1)
proc fieldToClearer(fieldName: string): string =
    return "clear" + char.ToUpperInvariant(fieldName[0]) + fieldName.Substring(1)