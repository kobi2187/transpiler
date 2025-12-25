# "Namespace: ICU4N.Dev.Test.Util"
type
  CurrencyTest = ref object
    tcurrMetaInfo: TestCurrencyMetaInfo = TestCurrencyMetaInfo

proc TestAPI*() =
    var usd: Currency = Currency.GetInstance("USD")
usd.GetHashCode
    var jpy: Currency = Currency.GetInstance("JPY")
    if usd.Equals(jpy):
Errln("FAIL: USD == JPY")
    if usd.Equals("abc"):
Errln("FAIL: USD == (String)")
    if usd.Equals(nil):
Errln("FAIL: USD == (null)")
    if !usd.Equals(usd):
Errln("FAIL: USD != USD")
    try:
        var nullCurrency: Currency = Currency.GetInstance(cast[string](nil))
Errln("FAIL: Expected getInstance(null) to throw " + "a NullPointerException, but returned " + nullCurrency)
    except ArgumentNullException:
Logln("PASS: getInstance(null) threw a NullPointerException")
    try:
        var bogusCurrency: Currency = Currency.GetInstance("BOGUS")
Errln("FAIL: Expected getInstance("BOGUS") to throw " + "an IllegalArgumentException, but returned " + bogusCurrency)
    except ArgumentException:
Logln("PASS: getInstance("BOGUS") threw an IllegalArgumentException")
    var avail: CultureInfo[] = Currency.GetCultures(UCultureTypes.AllCultures)
    if avail == nil:
Errln("FAIL: getAvailableLocales returned null")
    try:
usd.GetName(UCultureInfo("en-US"), cast[CurrencyNameStyle](5),         var _: bool)
Errln("expected getName with invalid type parameter to throw exception")
    except Exception:
Logln("PASS: getName failed as expected")
proc TestRegistration*() =
    var jpy: Currency = Currency.GetInstance("JPY")
    var usd: Currency = Currency.GetInstance(CultureInfo("en-US"))
    try:
Currency.Unregister(nil)
Errln("expected unregister of null to throw exception")
    except Exception:
Logln("PASS: unregister of null failed as expected")
    if Currency.Unregister(""):
Errln("unregister before register erroneously succeeded")
    var fu_FU: UCultureInfo = UCultureInfo("fu_FU")
    var key1: Object = Currency.RegisterInstance(jpy, UCultureInfo("en-US"))
    var key2: Object = Currency.RegisterInstance(jpy, fu_FU)
    var nus: Currency = Currency.GetInstance(CultureInfo("en-US"))
    if !nus.Equals(jpy):
Errln("expected " + jpy + " but got: " + nus)
    var nus1: Currency = Currency.GetInstance(CultureInfo("ja-JP"))
    if !nus1.Equals(jpy):
Errln("expected " + jpy + " but got: " + nus1)
    var locales: UCultureInfo[] = Currency.GetUCultures(UCultureTypes.AllCultures)
    var found: bool = false
      var i: int = 0
      while i < locales.Length:
          if locales[i].Equals(fu_FU):
              found = true
              break
++i
    if !found:
Errln("did not find locale" + fu_FU + " in currency locales")
    if !Currency.Unregister(key1):
Errln("unable to unregister currency using key1")
    if !Currency.Unregister(key2):
Errln("unable to unregister currency using key2")
    var nus2: Currency = Currency.GetInstance(CultureInfo("en-US"))
    if !nus2.Equals(usd):
Errln("expected " + usd + " but got: " + nus2)
    locales = Currency.GetUCultures(UCultureTypes.AllCultures)
    found = false
      var i: int = 0
      while i < locales.Length:
          if locales[i].Equals(fu_FU):
              found = true
              break
++i
    if found:
Errln("found locale" + fu_FU + " in currency locales after unregister")
    var locs: CultureInfo[] = Currency.GetCultures(UCultureTypes.AllCultures)
    found = false
      var i: int = 0
      while i < locs.Length:
          if locs[i].Equals(fu_FU):
              found = true
              break
++i
    if found:
Errln("found locale" + fu_FU + " in currency locales after unregister")
proc TestNames*() =
    var en: UCultureInfo = UCultureInfo("en")
    var isChoiceFormat: bool
    var usd: Currency = Currency.GetInstance("USD")
assertEquals("USD.getName(SYMBOL_NAME)", "$", usd.GetName(en, Currency.SymbolName, isChoiceFormat))
assertEquals("USD.getName(LONG_NAME)", "US Dollar", usd.GetName(en, Currency.LongName, isChoiceFormat))
proc testGetName_Locale_Int_String_BooleanArray*() =
    var currency: Currency = Currency.GetInstance(UCultureInfo("zh_Hans_CN"))
    var isChoiceFormat: bool
    var nameStyle: CurrencyNameStyle = Currency.LongName
    var pluralCount: String = ""
    var ulocaleName: String = currency.GetName(UCultureInfo("en-CA"), nameStyle, pluralCount, isChoiceFormat)
assertEquals("currency name mismatch", "Chinese Yuan", ulocaleName)
    var localeName: String = currency.GetName(CultureInfo("en-CA"), nameStyle, pluralCount, isChoiceFormat)
assertEquals("currency name mismatch", ulocaleName, localeName)
proc TestCoverage*() =
Assume.That(!PlatformDetection.IsLinux, "LUCENENET TODO: On Linux, this test is failing for some unkown reason.")
    var usd: Currency = Currency.GetInstance("USD")
assertEquals("USD.GetSymbol() in " & $UCultureInfo.CurrentUICulture.FullName, "$", usd.GetSymbol)
proc TestCurrencyDisplayNames*() =
    if !CurrencyDisplayNames.HasData:
Errln("hasData() should return true.")
    var cdn: CurrencyDisplayNames = CurrencyDisplayNames.GetInstance(UCultureInfo("de-DE"))
assertEquals("de_USD_name", "US-Dollar", cdn.GetName("USD"))
assertEquals("de_USD_symbol", "$", cdn.GetSymbol("USD"))
assertEquals("de_USD_plural_other", "US-Dollar", cdn.GetPluralName("USD", "other"))
assertEquals("de_USD_plural_foo", "US-Dollar", cdn.GetPluralName("USD", "foo"))
    cdn = CurrencyDisplayNames.GetInstance(UCultureInfo("en-US"))
assertEquals("en-US_USD_name", "US Dollar", cdn.GetName("USD"))
assertEquals("en-US_USD_symbol", "$", cdn.GetSymbol("USD"))
assertEquals("en-US_USD_plural_one", "US dollar", cdn.GetPluralName("USD", "one"))
assertEquals("en-US_USD_plural_other", "US dollars", cdn.GetPluralName("USD", "other"))
assertEquals("en-US_FOO_name", "FOO", cdn.GetName("FOO"))
assertEquals("en-US_FOO_symbol", "FOO", cdn.GetSymbol("FOO"))
assertEquals("en-US_FOO_plural_other", "FOO", cdn.GetPluralName("FOO", "other"))
assertEquals("en-US bundle", "en", cdn.UCulture.ToString)
    cdn = CurrencyDisplayNames.GetInstance(UCultureInfo("zz-Gggg-YY"))
assertEquals("bundle from current locale", "en", cdn.UCulture.ToString)
    cdn = CurrencyDisplayNames.GetInstance(UCultureInfo("de-DE"), true)
assertNotNull("have currency data for Germany", cdn)
assertEquals("de_USD_name", "US-Dollar", cdn.GetName("USD"))
assertEquals("de_USD_symbol", "$", cdn.GetSymbol("USD"))
assertEquals("de_USD_plural_other", "US-Dollar", cdn.GetPluralName("USD", "other"))
assertNull("de_USD_plural_foo", cdn.GetPluralName("USD", "foo"))
assertNull("de_FOO_name", cdn.GetName("FOO"))
assertNull("de_FOO_symbol", cdn.GetSymbol("FOO"))
assertNull("de_FOO_plural_other", cdn.GetPluralName("FOO", "other"))
assertNull("de_FOO_plural_foo", cdn.GetPluralName("FOO", "foo"))
    cdn = CurrencyDisplayNames.GetInstance(UCultureInfo("zz-Gggg-YY"), true)
    var ln: String = ""
    if cdn != nil:
        ln = " (" + cdn.UCulture.ToString + ")"
assertNull("no fallback from unknown locale" + ln, cdn)
    cdn = CurrencyDisplayNames.GetInstance(CultureInfo("de-DE"), true)
assertNotNull("have currency data for Germany (Java Locale)", cdn)
assertEquals("de_USD_name (Locale)", "US-Dollar", cdn.GetName("USD"))
assertNull("de_FOO_name (Locale)", cdn.GetName("FOO"))
proc TestCurrencyData*() =
    var info_fallback: DefaultCurrencyDisplayInfo = cast[DefaultCurrencyDisplayInfo](DefaultCurrencyDisplayInfo.GetWithFallback(true))
    if info_fallback == nil:
Errln("getWithFallback() returned null.")
        return
    var info_nofallback: DefaultCurrencyDisplayInfo = cast[DefaultCurrencyDisplayInfo](DefaultCurrencyDisplayInfo.GetWithFallback(false))
    if info_nofallback == nil:
Errln("getWithFallback() returned null.")
        return
    if !info_fallback.GetName("isoCode").Equals("isoCode") || info_nofallback.GetName("isoCode") != nil:
Errln("Error calling getName().")
        return
    if !info_fallback.GetPluralName("isoCode", "type").Equals("isoCode") || info_nofallback.GetPluralName("isoCode", "type") != nil:
Errln("Error calling getPluralName().")
        return
    if !info_fallback.GetSymbol("isoCode").Equals("isoCode") || info_nofallback.GetSymbol("isoCode") != nil:
Errln("Error calling getSymbol().")
        return
    if info_fallback.SymbolMap.Count != 0:
Errln("symbolMap() should return empty map.")
        return
    if info_fallback.NameMap.Count != 0:
Errln("nameMap() should return empty map.")
        return
    if info_fallback.GetUnitPatterns.Count != 0 || info_nofallback.GetUnitPatterns != nil:
Errln("Error calling getUnitPatterns().")
        return
    if !info_fallback.GetSpacingInfo.Equals(CurrencySpacingInfo.Default) || info_nofallback.GetSpacingInfo != nil:
Errln("Error calling getSpacingInfo().")
        return
    if info_fallback.UCulture != UCultureInfo.InvariantCulture:
Errln("Error calling getLocale().")
        return
    if info_fallback.GetFormatInfo("isoCode") != nil:
Errln("Error calling getFormatInfo().")
        return
proc testCurrencyMetaInfoRanges*() =
    var metainfo: CurrencyMetaInfo = CurrencyMetaInfo.GetInstance(true)
assertNotNull("have metainfo", metainfo)
    var filter: CurrencyFilter = CurrencyFilter.OnRegion("DE")
    var currenciesInGermany: IList<CurrencyInfo> = metainfo.CurrencyInfo(filter)
Logln("currencies: " + currenciesInGermany.Count)
    var demLastDate: DateTime = JavaDateToDotNetDateTime(long.MaxValue)
    var eurFirstDate: DateTime = JavaDateToDotNetDateTime(long.MinValue)
    for info in currenciesInGermany:
Logln(info.ToString)
Logln("from: " + JavaDateToDotNetDateTimeOffset(info.From).ToString("yyyy-MM-dd HH:mm:ss.fff zzz ") + info.From.ToHexString)
Logln("  to: " + JavaDateToDotNetDateTimeOffset(info.To).ToString("yyyy-MM-dd HH:mm:ss.fff zzz ") + info.To.ToHexString)
        if info.Code.Equals("DEM", StringComparison.Ordinal):
            demLastDate = JavaDateToDotNetDateTime(info.To)

        elif info.Code.Equals("EUR", StringComparison.Ordinal):
            eurFirstDate = JavaDateToDotNetDateTime(info.From)
assertEquals("DEM available at last date", 2, metainfo.CurrencyInfo(filter.WithDate(demLastDate)).Count)
    var demLastDatePlus1ms: DateTime = demLastDate.AddMilliseconds(1)
assertEquals("DEM not available after very start of last date", 1, metainfo.CurrencyInfo(filter.WithDate(demLastDatePlus1ms)).Count)
assertEquals("EUR available on start of first date", 2, metainfo.CurrencyInfo(filter.WithDate(eurFirstDate)).Count)
    var eurFirstDateMinus1ms: DateTime = eurFirstDate.AddMilliseconds(-1)
assertEquals("EUR not avilable before very start of first date", 1, metainfo.CurrencyInfo(filter.WithDate(eurFirstDateMinus1ms)).Count)
assertEquals("hour is 23", 23, demLastDate.Hour)
assertEquals("minute is 59", 59, demLastDate.Minute)
assertEquals("second is 59", 59, demLastDate.Second)
assertEquals("millisecond is 999", 999, demLastDate.Millisecond)
assertEquals("hour is 0", 0, eurFirstDate.Hour)
assertEquals("minute is 0", 0, eurFirstDate.Minute)
assertEquals("second is 0", 0, eurFirstDate.Second)
assertEquals("millisecond is 0", 0, eurFirstDate.Millisecond)
proc JavaDateToDotNetDateTime(getTimeResult: long): DateTime =
    if getTimeResult < DateTimeOffsetUtil.MinMilliseconds:
      getTimeResult = DateTimeOffsetUtil.MinMilliseconds
    if getTimeResult > DateTimeOffsetUtil.MaxMilliseconds:
      getTimeResult = DateTimeOffsetUtil.MaxMilliseconds
    return DateTime(DateTimeOffsetUtil.GetTicksFromUnixTimeMilliseconds(getTimeResult), DateTimeKind.Utc)
proc JavaDateToDotNetDateTimeOffset(getTimeResult: long): DateTimeOffset =
    if getTimeResult < DateTimeOffsetUtil.MinMilliseconds:
      getTimeResult = DateTimeOffsetUtil.MinMilliseconds
    if getTimeResult > DateTimeOffsetUtil.MaxMilliseconds:
      getTimeResult = DateTimeOffsetUtil.MaxMilliseconds
    return DateTimeOffset(DateTimeOffsetUtil.GetTicksFromUnixTimeMilliseconds(getTimeResult), TimeSpan.Zero)
proc testCurrencyMetaInfoRangesWithLongs*() =
    var metainfo: CurrencyMetaInfo = CurrencyMetaInfo.GetInstance(true)
assertNotNull("have metainfo", metainfo)
    var filter: CurrencyFilter = CurrencyFilter.OnRegion("DE")
    var currenciesInGermany: IList<CurrencyInfo> = metainfo.CurrencyInfo(filter)
    var filter_br: CurrencyFilter = CurrencyFilter.OnRegion("BR")
    var currenciesInBrazil: IList<CurrencyInfo> = metainfo.CurrencyInfo(filter_br)
Logln("currencies Germany: " + currenciesInGermany.Count)
Logln("currencies Brazil: " + currenciesInBrazil.Count)
    var demFirstDate: long = long.MinValue
    var demLastDate: long = long.MaxValue
    var eurFirstDate: long = long.MinValue
    var demInfo: CurrencyInfo = nil
    for info in currenciesInGermany:
Logln(info.ToString)
        if info.Code.Equals("DEM", StringComparison.Ordinal):
            demInfo = info
            demFirstDate = info.From
            demLastDate = info.To

        elif info.Code.Equals("EUR", StringComparison.Ordinal):
            eurFirstDate = info.From
assertEquals("DEM available at last date", 2, metainfo.CurrencyInfo(filter.WithDate(demLastDate)).Count)
    var demLastDatePlus1ms: long = demLastDate + 1
assertEquals("DEM not available after very start of last date", 1, metainfo.CurrencyInfo(filter.WithDate(demLastDatePlus1ms)).Count)
assertEquals("EUR available on start of first date", 2, metainfo.CurrencyInfo(filter.WithDate(eurFirstDate)).Count)
    var eurFirstDateMinus1ms: long = eurFirstDate - 1
assertEquals("EUR not avilable before very start of first date", 1, metainfo.CurrencyInfo(filter.WithDate(eurFirstDateMinus1ms)).Count)
assertEquals("Millisecond of DEM Big Bang", 1, metainfo.CurrencyInfo(CurrencyFilter.OnDate(demFirstDate).WithRegion("DE")).Count)
assertEquals("From Deutschmark to Euro", 2, metainfo.CurrencyInfo(CurrencyFilter.OnDateRange(demFirstDate, eurFirstDate).WithRegion("DE")).Count)
assertEquals("all Tender for Brazil", 7, metainfo.CurrencyInfo(CurrencyFilter.OnTender.WithRegion("BR")).Count)
assertTrue("No legal tender", demInfo.IsTender)
proc TestWithTender*() =
    var metainfo: CurrencyMetaInfo = CurrencyMetaInfo.GetInstance
    if metainfo == nil:
Errln("Unable to get CurrencyMetaInfo instance.")
        return
    var filter: CurrencyFilter = CurrencyFilter.OnRegion("CH")
    var currencies: IList<string> = metainfo.Currencies(filter)
assertTrue("More than one currency for switzerland", currencies.Count > 1)
assertEquals("With tender", @["CHF", "CHE", "CHW"], metainfo.Currencies(filter.WithTender))
proc TestCurrencyMetaInfo2*() =
    var metainfo: CurrencyMetaInfo = CurrencyMetaInfo.GetInstance
    if metainfo == nil:
Errln("Unable to get CurrencyMetaInfo instance.")
        return
    if !CurrencyMetaInfo.HasData:
Errln("hasData() should note return false.")
        return
    var filter: CurrencyFilter
    var info: CurrencyInfo
    var digits: CurrencyDigits
      filter = CurrencyFilter.OnCurrency("currency")
      var filter2: CurrencyFilter = CurrencyFilter.OnCurrency("test")
      if filter == nil:
Errln("Unable to create CurrencyFilter.")
          return
      if filter.Equals(Object):
Errln("filter should not equal to Object")
          return
      if filter.Equals(filter2):
Errln("filter should not equal filter2")
          return
      if filter.GetHashCode == 0:
Errln("Error getting filter hashcode")
          return
      if filter.ToString == nil:
Errln("Error calling toString()")
          return
      info = CurrencyInfo("region", "code", 0, 1, 1, false)
      if info == nil:
Errln("Error creating CurrencyInfo.")
          return
      if info.ToString == nil:
Errln("Error calling toString()")
          return
      digits = metainfo.CurrencyDigits("isoCode")
      if digits == nil:
Errln("Unable to get CurrencyDigits.")
          return
      if digits.ToString == nil:
Errln("Error calling toString()")
          return
proc TestCurrencyKeyword*() =
    var locale: UCultureInfo = UCultureInfo("th_TH@collation=traditional;currency=QQQ")
    var currency: Currency = Currency.GetInstance(locale)
    var result: String = currency.CurrencyCode
    if !"QQQ".Equals(result):
Errln("got unexpected currency: " + result)
proc TestDeprecatedCurrencyFormat*() =
    var locale: CultureInfo = CultureInfo("sr-QQ")
    var icuSymbols: DecimalFormatSymbols = DecimalFormatSymbols(locale)
    var symbol: String = icuSymbols.CurrencySymbol
    var currency: Currency = icuSymbols.Currency
    var expectCur: String = nil
    var expectSym: String = "¤"
    if !symbol.ToString.Equals(expectSym, StringComparison.Ordinal) || currency != nil:
Errln("for " + locale + " expected " + expectSym + "/" + expectCur + " but got " + symbol + "/" + currency)
    else:
Logln("for " + locale + " expected " + expectSym + "/" + expectCur + " and got " + symbol + "/" + currency)
proc TestGetKeywordValues*() =
    var PREFERRED: string[][] = @[@["root"], @["und"], @["und_ZZ", "XAG", "XAU", "XBA", "XBB", "XBC", "XBD", "XDR", "XPD", "XPT", "XSU", "XTS", "XUA", "XXX"], @["en_US", "USD", "USN"], @["en_029"], @["en_TH", "THB"], @["de", "EUR"], @["de_DE", "EUR"], @["de_ZZ", "XAG", "XAU", "XBA", "XBB", "XBC", "XBD", "XDR", "XPD", "XPT", "XSU", "XTS", "XUA", "XXX"], @["ar", "EGP"], @["ar_PS", "ILS", "JOD"], @["en@currency=CAD", "USD", "USN"], @["fr@currency=ZZZ", "EUR"], @["de_DE@currency=DEM", "EUR"], @["en_US@rg=THZZZZ", "THB"], @["de@rg=USZZZZ", "USD", "USN"], @["en_US@currency=CAD;rg=THZZZZ", "THB"]]
    var ALL: String[] = Currency.GetKeywordValuesForLocale("currency", UCultureInfo.CurrentCulture, false)
    var ALLSET: HashSet<string> = HashSet<string>
      var i: int = 0
      while i < ALL.Length:
ALLSET.Add(ALL[i])
++i
      var i: int = 0
      while i < PREFERRED.Length:
          var loc: UCultureInfo = UCultureInfo(PREFERRED[i][0])
          var expected: String[] = seq[String]
Array.Copy(PREFERRED[i], 1, expected, 0, expected.Length)
          var pref: String[] = Currency.GetKeywordValuesForLocale("currency", loc, true)
assertEquals(loc.ToString, expected, pref)
          var all: String[] = Currency.GetKeywordValuesForLocale("currency", loc, false)
          var returnedSet: ISet<String> = HashSet<String>
returnedSet.UnionWith(all)
assertEquals(loc.ToString, ALLSET, returnedSet)
++i
proc TestIsAvailable*() =
    var d1995: DateTime = DateTime(DateTimeOffsetUtil.GetTicksFromUnixTimeMilliseconds(788918400000))
    var d2000: DateTime = DateTime(DateTimeOffsetUtil.GetTicksFromUnixTimeMilliseconds(946684800000))
    var d2005: DateTime = DateTime(DateTimeOffsetUtil.GetTicksFromUnixTimeMilliseconds(1104537600000))
assertTrue("USD all time", Currency.IsAvailable("USD", nil, nil))
assertTrue("USD before 1995", Currency.IsAvailable("USD", nil, d1995))
assertTrue("USD 1995-2005", Currency.IsAvailable("USD", d1995, d2005))
assertTrue("USD after 2005", Currency.IsAvailable("USD", d2005, nil))
assertTrue("USD on 2005-01-01", Currency.IsAvailable("USD", d2005, d2005))
assertTrue("usd all time", Currency.IsAvailable("usd", nil, nil))
assertTrue("DEM all time", Currency.IsAvailable("DEM", nil, nil))
assertTrue("DEM before 1995", Currency.IsAvailable("DEM", nil, d1995))
assertTrue("DEM 1995-2000", Currency.IsAvailable("DEM", d1995, d2000))
assertTrue("DEM 1995-2005", Currency.IsAvailable("DEM", d1995, d2005))
assertFalse("DEM after 2005", Currency.IsAvailable("DEM", d2005, nil))
assertTrue("DEM on 2000-01-01", Currency.IsAvailable("DEM", d2000, d2000))
assertFalse("DEM on 2005-01-01", Currency.IsAvailable("DEM", d2005, d2005))
assertTrue("CHE all the time", Currency.IsAvailable("CHE", nil, nil))
assertFalse("XXY unknown code", Currency.IsAvailable("XXY", nil, nil))
assertFalse("USDOLLAR invalid code", Currency.IsAvailable("USDOLLAR", nil, nil))
    try:
Currency.IsAvailable("USD", d2005, d1995)
Errln("Expected IllegalArgumentException, because lower range is after upper range")
    except ArgumentException:
Logln("IllegalArgumentException, because lower range is after upper range")
proc TestGetAvailableCurrencies*() =
    var avail1: ISet<Currency> = Currency.GetAvailableCurrencies
avail1.Add(Currency.GetInstance("ZZZ"))
    var avail2: ISet<Currency> = Currency.GetAvailableCurrencies
assertTrue("avail1 does not contain all currencies in avail2", avail1.IsSupersetOf(avail2))
assertTrue("avail1 must have one more currency", avail1.Count - avail2.Count == 1)
proc TestGetNumericCode*() =
    var NUMCODE_TESTDATA: object[][] = @[@["USD", 840], @["Usd", 840], @["EUR", 978], @["JPY", 392], @["XFU", 0], @["ZZZ", 0]]
    for data in NUMCODE_TESTDATA:
        var cur: Currency = Currency.GetInstance(cast[String](data[0]))
        var numCode: int = cur.GetNumericCode
        var expected: int = cast[int](data[1])
        if numCode != expected:
Errln("FAIL: getNumericCode returned " + numCode + " for " + cur.CurrencyCode + " - expected: " + expected)
proc TestGetDisplayName*() =
    var DISPNAME_TESTDATA: string[][] = @[@["USD", "US Dollar"], @["EUR", "Euro"], @["JPY", "Japanese Yen"]]
    var defLocale: CultureInfo = CultureInfo.CurrentCulture
    var jaJP: CultureInfo = CultureInfo("ja-JP")
    var root: CultureInfo = CultureInfo.InvariantCulture
    for data in DISPNAME_TESTDATA:
        var cur: Currency = Currency.GetInstance(data[0])
assertEquals("getDisplayName() for " + data[0], data[1], cur.GetDisplayName)
assertEquals("getDisplayName() for " + data[0] + " in locale " + defLocale, data[1], cur.GetDisplayName(defLocale))
assertNotEquals("getDisplayName() for " + data[0] + " in locale " + jaJP, data[1], cur.GetDisplayName(jaJP))
assertEquals("getDisplayName() for " + data[0] + " in locale " + root, data[0], cur.GetDisplayName(root))
proc TestCurrencyInfoCtor*() =
CurrencyInfo("region", "code", 0, 0, 1)
type
  TestCurrencyMetaInfo = ref object


proc TestCurrMetaInfoBaseClass*() =
    var usFilter: CurrencyFilter = CurrencyFilter.OnRegion("US")
assertEquals("Empty list expected", 0, tcurrMetaInfo.CurrencyInfo(usFilter).Count)
assertEquals("Empty list expected", 0, tcurrMetaInfo.Currencies(usFilter).Count)
assertEquals("Empty list expected", 0, tcurrMetaInfo.Regions(usFilter).Count)
assertEquals("Iso format for digits expected", "CurrencyDigits(fractionDigits='2',roundingIncrement='0')", tcurrMetaInfo.CurrencyDigits("isoCode").ToString)
proc testGetDefaultFractionDigits_CurrencyUsage*() =
    var currency: Currency = Currency.GetInstance(UCultureInfo("zh_Hans_CN"))
    var cashFractionDigits: int = currency.GetDefaultFractionDigits(CurrencyUsage.Cash)
assertEquals("number of digits in fraction incorrect", 2, cashFractionDigits)
proc testGetRoundingIncrement*() =
    var currency: Currency = Currency.GetInstance(UCultureInfo("ja-JP"))
    var roundingIncrement: double = currency.GetRoundingIncrement
assertEquals("Rounding increment not zero", 0.0, roundingIncrement, 0.0)
proc testGetRoundingIncrement_CurrencyUsage*() =
    var currency: Currency = Currency.GetInstance(UCultureInfo("ja-JP"))
    var roundingIncrement: double = currency.GetRoundingIncrement(CurrencyUsage.Cash)
assertEquals("Rounding increment not zero", 0.0, roundingIncrement, 0.0)
proc TestCurrencyDataCtor*() =
CheckDefaultPrivateConstructor(type(CurrencyData))