# "Namespace: ICU4N.Dev.Test.Util"
type
  LocaleAliasCollationTest = ref object
    _LOCALES: seq[UCultureInfo] = @[@[UCultureInfo("en_RH"), UCultureInfo("en_ZW")], @[UCultureInfo("in"), UCultureInfo("id")], @[UCultureInfo("in_ID"), UCultureInfo("id_ID")], @[UCultureInfo("iw"), UCultureInfo("he")], @[UCultureInfo("iw_IL"), UCultureInfo("he_IL")], @[UCultureInfo("ji"), UCultureInfo("yi")], @[UCultureInfo("en_BU"), UCultureInfo("en_MM")], @[UCultureInfo("en_DY"), UCultureInfo("en_BJ")], @[UCultureInfo("en_HV"), UCultureInfo("en_BF")], @[UCultureInfo("en_NH"), UCultureInfo("en_VU")], @[UCultureInfo("en_TP"), UCultureInfo("en_TL")], @[UCultureInfo("en_ZR"), UCultureInfo("en_CD")]]
    _LOCALE_NUMBER: int = _LOCALES.Length
    available: seq[UCultureInfo] = nil
    availableMap: Dictionary[object, object] = Dictionary<object, object>
    _DEFAULT_LOCALE: UCultureInfo = UCultureInfo("en_US")

proc newLocaleAliasCollationTest(): LocaleAliasCollationTest =

proc Init*() =
    available = UCultureInfo.GetCultures(UCultureTypes.AllCultures)
      var i: int = 0
      while i < available.Length:
          availableMap[available[i].ToString] = ""
++i
proc TestCollation*() =
      let resource = ThreadCultureChange(_DEFAULT_LOCALE, _DEFAULT_LOCALE)
<unhandled: nnkDefer>
        var i: int = 0
        while i < _LOCALE_NUMBER:
            var oldLoc: UCultureInfo = _LOCALES[i][0]
            var newLoc: UCultureInfo = _LOCALES[i][1]
            if !availableMap.TryGetValue(_LOCALES[i][1],             var value: object) || value == nil:
Logln(_LOCALES[i][1] + " is not available. Skipping!")
                continue
            var c1: Collator = Collator.GetInstance(oldLoc)
            var c2: Collator = Collator.GetInstance(newLoc)
            if !c1.Equals(c2):
Errln("CollationTest: c1!=c2: newLoc= " + newLoc + " oldLoc= " + oldLoc)
Logln("Collation old:" + oldLoc + "   new:" + newLoc)
++i