# "Namespace: ICU4N.Dev.Test.Format"
type
  PluralFormatTest = ref object


proc helperTestRules(localeIDs: String, testPattern: String, changes: IDictionary[Integer, String]) =
    var locales: String[] = Utility.Split(localeIDs, ',')
Log("test pattern: '" + testPattern + "'")
      var i: int = 0
      while i < locales.Length:
          try:
              var plf: PluralFormat = PluralFormat(UCultureInfo(locales[i]), testPattern)
Log("plf: " + plf)
              var expected: String = changes[Integer.GetInstance(0)]
                var n: int = 0
                while n < 200:
                    if changes.TryGetValue(n,                     var value: string) && value != nil:
                        expected = value
assertEquals("Locale: " + locales[i] + ", number: " + n, expected, plf.Format(n))
TestIcuNumber_PluralFormat(locales[i], n, testPattern, nil, expected, "Locale: " + locales[i] + ", number: " + n)
++n
          except ArgumentException:
Errln(e.ToString + " locale: " + locales[i] + " pattern: '" + testPattern + "' " + J2N.Time.CurrentTimeMilliseconds)
++i
proc TestIcuNumber_PluralFormat*(culture: string, number: int, pluralPattern: string, decimalPattern: string, expected: string, assertMessage: string) =
    var locale = UCultureInfo(culture)
    var messagePattern: MessagePattern = MessagePattern
messagePattern.ParsePluralStyle(pluralPattern)
    var actual: string = IcuNumber.FormatPlural(number, decimalPattern, messagePattern, locale.NumberFormat)
assertEquals(assertMessage, expected, actual)
proc TestOneFormLocales*() =
    var localeIDs: String = "ja,ko,tr,vi"
    var testPattern: String = "other{other}"
    var changes = Dictionary<Integer, string>
    changes[Integer.GetInstance(0)] = "other"
helperTestRules(localeIDs, testPattern, changes)
proc TestSingular1Locales*() =
    var localeIDs: String = "bem,da,de,el,en,eo,es,et,fi,fo,he,it,nb,nl,nn,no,pt_PT,sv,af,bg,ca,eu,fur,fy,ha,ku,lb,ml," + "nah,ne,om,or,pap,ps,so,sq,sw,ta,te,tk,ur,mn,gsw,rm"
    var testPattern: String = "one{one} other{other}"
    var changes = Dictionary<Integer, string>
    changes[Integer.GetInstance(0)] = "other"
    changes[Integer.GetInstance(1)] = "one"
    changes[Integer.GetInstance(2)] = "other"
helperTestRules(localeIDs, testPattern, changes)
proc TestSingular01Locales*() =
    var localeIDs: String = "ff,fr,kab,gu,mr,pa,pt,zu,bn"
    var testPattern: String = "one{one} other{other}"
    var changes = Dictionary<Integer, string>
    changes[Integer.GetInstance(0)] = "one"
    changes[Integer.GetInstance(2)] = "other"
helperTestRules(localeIDs, testPattern, changes)
proc TestZeroSingularLocales*() =
    var localeIDs: String = "lv"
    var testPattern: String = "zero{zero} one{one} other{other}"
    var changes = Dictionary<Integer, string>
    changes[Integer.GetInstance(0)] = "zero"
    changes[Integer.GetInstance(1)] = "one"
      var i: int = 2
      while i < 20:
          if i < 10:
              changes[Integer.GetInstance(i)] = "other"
          else:
              changes[Integer.GetInstance(i)] = "zero"
          changes[Integer.GetInstance(i * 10)] = "zero"
          if i == 11:
              changes[Integer.GetInstance(i * 10 + 1)] = "zero"
              changes[Integer.GetInstance(i * 10 + 2)] = "zero"
          else:
              changes[Integer.GetInstance(i * 10 + 1)] = "one"
              changes[Integer.GetInstance(i * 10 + 2)] = "other"
++i
helperTestRules(localeIDs, testPattern, changes)
proc TestSingularDual*() =
    var localeIDs: String = "ga"
    var testPattern: String = "one{one} two{two} other{other}"
    var changes = Dictionary<Integer, string>
    changes[Integer.GetInstance(0)] = "other"
    changes[Integer.GetInstance(1)] = "one"
    changes[Integer.GetInstance(2)] = "two"
    changes[Integer.GetInstance(3)] = "other"
helperTestRules(localeIDs, testPattern, changes)
proc TestSingularZeroSome*() =
    var localeIDs: String = "ro"
    var testPattern: String = "few{few} one{one} other{other}"
    var changes = Dictionary<Integer, string>
    changes[Integer.GetInstance(0)] = "few"
    changes[Integer.GetInstance(1)] = "one"
    changes[Integer.GetInstance(2)] = "few"
    changes[Integer.GetInstance(20)] = "other"
    changes[Integer.GetInstance(101)] = "few"
    changes[Integer.GetInstance(120)] = "other"
helperTestRules(localeIDs, testPattern, changes)
proc TestSpecial12_19*() =
    var localeIDs: String = "lt"
    var testPattern: String = "one{one} few{few} other{other}"
    var changes = Dictionary<Integer, string>
    changes[Integer.GetInstance(0)] = "other"
    changes[Integer.GetInstance(1)] = "one"
    changes[Integer.GetInstance(2)] = "few"
    changes[Integer.GetInstance(10)] = "other"
      var i: int = 2
      while i < 20:
          if i == 11:
              continue
          changes[Integer.GetInstance(i * 10 + 1)] = "one"
          changes[Integer.GetInstance(i * 10 + 2)] = "few"
          changes[Integer.GetInstance(i + 1 * 10)] = "other"
++i
helperTestRules(localeIDs, testPattern, changes)
proc TestPaucalExcept11_14*() =
    var localeIDs: String = "hr,sr,uk"
    var testPattern: String = "one{one} few{few} other{other}"
    var changes = Dictionary<Integer, string>
    changes[Integer.GetInstance(0)] = "other"
    changes[Integer.GetInstance(1)] = "one"
    changes[Integer.GetInstance(2)] = "few"
    changes[Integer.GetInstance(5)] = "other"
      var i: int = 2
      while i < 20:
          if i == 11:
              continue
          changes[Integer.GetInstance(i * 10 + 1)] = "one"
          changes[Integer.GetInstance(i * 10 + 2)] = "few"
          changes[Integer.GetInstance(i * 10 + 5)] = "other"
++i
helperTestRules(localeIDs, testPattern, changes)
proc TestPaucalRu*() =
    var localeIDs: String = "ru"
    var testPattern: String = "one{one} many{many} other{other}"
    var changes = Dictionary<Integer, string>
      var i: int = 0
      while i < 200:
          if i == 10 || i == 110:
put(i, 0, 9, "many", changes)
              continue
put(i, 0, "many", changes)
put(i, 1, "one", changes)
put(i, 2, 4, "other", changes)
put(i, 5, 9, "many", changes)
          i = 10
helperTestRules(localeIDs, testPattern, changes)
proc put*(@base: int, start: int, end: int, value: T, m: IDictionary[Integer, T]) =
      var i: int = start
      while i <= end:
          if m.ContainsKey(@base + i):
              raise ArgumentException
          m[@base + i] = value
++i
proc put*(@base: int, start: int, value: T, m: IDictionary[Integer, T]) =
put(@base, start, start, value, m)
proc TestSingularPaucal*() =
    var localeIDs: String = "cs,sk"
    var testPattern: String = "one{one} few{few} other{other}"
    var changes = Dictionary<Integer, string>
    changes[Integer.GetInstance(0)] = "other"
    changes[Integer.GetInstance(1)] = "one"
    changes[Integer.GetInstance(2)] = "few"
    changes[Integer.GetInstance(5)] = "other"
helperTestRules(localeIDs, testPattern, changes)
proc TestPaucal1_234*() =
    var localeIDs: String = "pl"
    var testPattern: String = "one{one} few{few} other{other}"
    var changes = Dictionary<Integer, string>
    changes[Integer.GetInstance(0)] = "other"
    changes[Integer.GetInstance(1)] = "one"
    changes[Integer.GetInstance(2)] = "few"
    changes[Integer.GetInstance(5)] = "other"
      var i: int = 2
      while i < 20:
          if i == 11:
              continue
          changes[Integer.GetInstance(i * 10 + 2)] = "few"
          changes[Integer.GetInstance(i * 10 + 5)] = "other"
++i
helperTestRules(localeIDs, testPattern, changes)
proc TestPaucal1_2_34*() =
    var localeIDs: String = "sl"
    var testPattern: String = "one{one} two{two} few{few} other{other}"
    var changes = Dictionary<Integer, string>
    changes[Integer.GetInstance(0)] = "other"
    changes[Integer.GetInstance(1)] = "one"
    changes[Integer.GetInstance(2)] = "two"
    changes[Integer.GetInstance(3)] = "few"
    changes[Integer.GetInstance(5)] = "other"
    changes[Integer.GetInstance(101)] = "one"
    changes[Integer.GetInstance(102)] = "two"
    changes[Integer.GetInstance(103)] = "few"
    changes[Integer.GetInstance(105)] = "other"
helperTestRules(localeIDs, testPattern, changes)
proc TestGetPluralRules*() =
    var cpi: CurrencyPluralInfo = CurrencyPluralInfo
    try:
        var _ = cpi.PluralRules
    except Exception:
Errln("CurrencyPluralInfo.getPluralRules() was not suppose to " + "return an exception.")
proc TestGetLocale*() =
    var cpi: CurrencyPluralInfo = CurrencyPluralInfo(UCultureInfo("en_US"))
    if !cpi.Culture.Equals(UCultureInfo("en_US")):
Errln("CurrencyPluralInfo.getLocale() was suppose to return true " + "when passing the same ULocale")
    if cpi.Culture.Equals(UCultureInfo("jp_JP")):
Errln("CurrencyPluralInfo.getLocale() was not suppose to return true " + "when passing a different ULocale")
proc TestSetLocale*() =
    var cpi: CurrencyPluralInfo = CurrencyPluralInfo
    cpi.Culture = UCultureInfo("en_US")
    if !cpi.Culture.Equals(UCultureInfo("en_US")):
Errln("CurrencyPluralInfo.setLocale() was suppose to return true when passing the same ULocale")
    if cpi.Culture.Equals(UCultureInfo("jp_JP")):
Errln("CurrencyPluralInfo.setLocale() was not suppose to return true when passing a different ULocale")
proc TestEquals*() =
    var cpi: CurrencyPluralInfo = CurrencyPluralInfo
    if cpi.Equals(0):
Errln("CurrencyPluralInfo.equals(Object) was not suppose to return true when comparing to an invalid object for integer 0.")
    if cpi.Equals(0.0):
Errln("CurrencyPluralInfo.equals(Object) was not suppose to return true when comparing to an invalid object for float 0.")
    if cpi.Equals("0"):
Errln("CurrencyPluralInfo.equals(Object) was not suppose to return true when comparing to an invalid object for string 0.")
proc TestFractionRounding*() =
    var nf: NumberFormat = NumberFormat.GetInstance(CultureInfo("en"))
    nf.MaximumFractionDigits = 0
    var pf: PluralFormat = PluralFormat(UCultureInfo("en"), "one{#kg}other{#kgs}")
pf.SetNumberFormat(nf)
assertEquals("1.2kg", "1kg", pf.Format(1.2))