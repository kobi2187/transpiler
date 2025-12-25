# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationServiceTest = ref object
    KW: seq[String] = @["collation"]
    KWVAL: seq[String] = @["phonebook", "stroke"]

proc TestRegister*() =
    var frcol: Collator = Collator.GetInstance(UCultureInfo("fr_FR"))
    var uscol: Collator = Collator.GetInstance(UCultureInfo("en_US"))
      var key: Object = Collator.RegisterInstance(frcol, UCultureInfo("en_US"))
      var ncol: Collator = Collator.GetInstance(UCultureInfo("en_US"))
      if !frcol.Equals(ncol):
Errln("register of french collator for en_US failed")
      var test: Collator = Collator.GetInstance(UCultureInfo("de_DE"))
      if !test.ValidCulture.Equals(UCultureInfo("de")):
Errln("Collation from Germany is really " + test.ValidCulture)
      if !Collator.Unregister(key):
Errln("failed to unregister french collator")
      ncol = Collator.GetInstance(UCultureInfo("en_US"))
      if !uscol.Equals(ncol):
Errln("collator after unregister does not match original")
    var fu_FU: UCultureInfo = UCultureInfo("fu_FU_FOO")
      var fucol: Collator = Collator.GetInstance(fu_FU)
      var key: Object = Collator.RegisterInstance(frcol, fu_FU)
      var ncol: Collator = Collator.GetInstance(fu_FU)
      if !frcol.Equals(ncol):
Errln("register of fr collator for fu_FU failed")
      var locales: UCultureInfo[] = Collator.GetUCultures(UCultureTypes.AllCultures)
      var found: bool = false
        var i: int = 0
        while i < locales.Length:
            if locales[i].Equals(fu_FU):
                found = true
                break
++i
      if !found:
Errln("new locale fu_FU not reported as supported locale")
      try:
          var name: String = Collator.GetDisplayName(fu_FU)
          if !"fu (FU, FOO)".Equals(name) && !"fu_FU_FOO".Equals(name):
Errln("found " + name + " for fu_FU")
      except MissingManifestResourceException:
Warnln("Could not load locale data.")
      try:
          var name: String = Collator.GetDisplayName(fu_FU, fu_FU)
          if !"fu (FU, FOO)".Equals(name) && !"fu_FU_FOO".Equals(name):
Errln("found " + name + " for fu_FU")
      except MissingManifestResourceException:
Warnln("Could not load locale data.")
      if !Collator.Unregister(key):
Errln("failed to unregister french collator")
      ncol = Collator.GetInstance(fu_FU)
      if !fucol.Equals(ncol):
Errln("collator after unregister does not match original fu_FU")
      var locales: UCultureInfo[] = Collator.GetUCultures(UCultureTypes.AllCultures)
        var i: int = 0
        while i < locales.Length:
            if locales[i].Equals(fu_FU):
Errln("new locale fu_FU not reported as supported locale")
                break
++i
      var ncol: Collator = Collator.GetInstance(UCultureInfo("en_US"))
      if !ncol.ValidCulture.Equals(UCultureInfo("en_US")):
Errln("Collation from US is really " + ncol.ValidCulture)
type
  CollatorInfo = ref object
    locale: UCultureInfo
    collator: Collator
    displayNames: IDictionary[object, object]

proc newCollatorInfo(locale: UCultureInfo, collator: Collator, displayNames: IDictionary[object, object]): CollatorInfo =
  self.locale = locale
  self.collator = collator
  self.displayNames = displayNames
proc GetDisplayName(displayLocale: UCultureInfo): string =
    var name: string = nil
    if displayNames != nil:
        name =         if displayNames.TryGetValue(displayLocale,         var val: object):
cast[string](val)
        else:
nil
    if name == nil:
        name = locale.GetDisplayName(displayLocale)
    return name
type
  TestFactory = ref object
    map: IDictionary[object, object]
    ids: ISet[string]

proc newTestFactory(info: seq[CollatorInfo]): TestFactory =
  map = Dictionary<object, object>
    var i: int = 0
    while i < info.Length:
        var ci: CollatorInfo = info[i]
        map[ci.locale] = ci
++i
proc CreateCollator*(loc: UCultureInfo): Collator =
    if map.TryGetValue(loc,     var cio: object) && cio && ci != nil:
      return ci.collator
    return nil
proc GetDisplayName*(objectLocale: UCultureInfo, displayLocale: UCultureInfo): String =
    if map.TryGetValue(objectLocale,     var cio: object) && cio && ci != nil:
      return ci.GetDisplayName(displayLocale)
    return nil
proc GetSupportedLocaleIDs*(): ICollection<string> =
    if ids == nil:
        var set: HashSet<string> = HashSet<string>
          let iter = map.Keys.GetEnumerator
<unhandled: nnkDefer>
          while iter.MoveNext:
              var locale: UCultureInfo = cast[UCultureInfo](iter.Current)
              var id: String = locale.ToString
set.Add(id)
          ids = set.AsReadOnly
    return ids
type
  TestFactoryWrapper = ref object
    @delegate: CollatorFactory

proc newTestFactoryWrapper(@delegate: CollatorFactory): TestFactoryWrapper =
  self.@delegate = @delegate
proc CreateCollator*(loc: UCultureInfo): Collator =
    return @delegate.CreateCollator(loc)
proc GetSupportedLocaleIDs*(): ICollection<string> =
    return @delegate.GetSupportedLocaleIDs
proc TestRegisterFactory*() =
    var fu_FU: UCultureInfo = UCultureInfo("fu_FU")
    var fu_FU_FOO: UCultureInfo = UCultureInfo("fu_FU_FOO")
    var fuFUNames: IDictionary<object, object> = Dictionary<object, object>
    var frcol: Collator = Collator.GetInstance(UCultureInfo("fr_FR"))
Collator.GetInstance(UCultureInfo("en_US"))
    var gecol: Collator = Collator.GetInstance(UCultureInfo("de_DE"))
    var jpcol: Collator = Collator.GetInstance(UCultureInfo("ja_JP"))
    var fucol: Collator = Collator.GetInstance(fu_FU)
    var info: CollatorInfo[] = @[CollatorInfo(UCultureInfo("en_US"), frcol, nil), CollatorInfo(UCultureInfo("fr_FR"), gecol, nil), CollatorInfo(fu_FU, jpcol, fuFUNames)]
    var factory: TestFactory = nil
    try:
        factory = TestFactory(info)
    except MissingManifestResourceException:
Warnln("Could not load locale data.")
      var wrapper: TestFactoryWrapper = TestFactoryWrapper(factory)
      var key: Object = Collator.RegisterFactory(wrapper)
      var name: String = nil
      try:
          name = Collator.GetDisplayName(fu_FU, fu_FU_FOO)
      except MissingManifestResourceException:
Warnln("Could not load locale data.")
Logln("*** default name: " + name)
Collator.Unregister(key)
      var bar_BAR: UCultureInfo = UCultureInfo("bar_BAR")
      var col: Collator = Collator.GetInstance(bar_BAR)
      var valid: UCultureInfo = col.ValidCulture
      var validName: String = valid.FullName
      if validName.Length != 0 && !validName.Equals("root"):
Errln("Collation from bar_BAR is really "" + validName + "" but should be root")
    var n1: int = checkAvailable("before registerFactory")
      var key: Object = Collator.RegisterFactory(factory)
      var n2: int = checkAvailable("after registerFactory")
      var ncol: Collator = Collator.GetInstance(UCultureInfo("en_US"))
      if !frcol.Equals(ncol):
Errln("frcoll for en_US failed")
      ncol = Collator.GetInstance(fu_FU_FOO)
      if !jpcol.Equals(ncol):
Errln("jpcol for fu_FU_FOO failed, got: " + ncol)
      var locales: UCultureInfo[] = Collator.GetUCultures(UCultureTypes.AllCultures)
      var found: bool = false
        var i: int = 0
        while i < locales.Length:
            if locales[i].Equals(fu_FU):
                found = true
                break
++i
      if !found:
Errln("new locale fu_FU not reported as supported locale")
      var name: String = Collator.GetDisplayName(fu_FU)
      if !"little bunny Foo Foo".Equals(name):
Errln("found " + name + " for fu_FU")
      name = Collator.GetDisplayName(fu_FU, fu_FU_FOO)
      if !"zee leetel bunny Foo-Foo".Equals(name):
Errln("found " + name + " for fu_FU in fu_FU_FOO")
      if !Collator.Unregister(key):
Errln("failed to unregister factory")
      var n3: int = checkAvailable("after unregister")
assertTrue("register increases count", n2 > n1)
assertTrue("unregister restores count", n3 == n1)
      ncol = Collator.GetInstance(fu_FU)
      if !fucol.Equals(ncol):
Errln("collator after unregister does not match original fu_FU")
proc checkAvailable(msg: String): int =
    var locs: CultureInfo[] = Collator.GetCultures(UCultureTypes.AllCultures)
    if !assertTrue("getAvailableLocales != null", locs != nil):
      return -1
CheckArray(msg, locs, nil)
    var ulocs: UCultureInfo[] = Collator.GetUCultures(UCultureTypes.AllCultures)
    if !assertTrue("getAvailableULocales != null", ulocs != nil):
      return -1
CheckArray(msg, ulocs, nil)
    return locs.Length
proc TestSeparateTrees*() =
    var kw = Collator.Keywords.ToArray
    if !assertTrue("getKeywords != null", kw != nil):
      return
CheckArray("getKeywords", kw, KW)
    var kwval: String[] = Collator.GetKeywordValues(KW[0])
    if !assertTrue("getKeywordValues != null", kwval != nil):
      return
CheckArray("getKeywordValues", kwval, KWVAL)
    var equiv: UCultureInfo = Collator.GetFunctionalEquivalent(KW[0], UCultureInfo("de"),     var isAvailable: bool)
    if assertTrue("getFunctionalEquivalent(de)!=null", equiv != nil):
assertEquals("getFunctionalEquivalent(de)", "root", equiv.ToString)
assertTrue("getFunctionalEquivalent(de).isAvailable==true", isAvailable == true)
    equiv = Collator.GetFunctionalEquivalent(KW[0], UCultureInfo("de_DE"), isAvailable)
    if assertTrue("getFunctionalEquivalent(de_DE)!=null", equiv != nil):
assertEquals("getFunctionalEquivalent(de_DE)", "root", equiv.ToString)
assertTrue("getFunctionalEquivalent(de_DE).isAvailable==false", isAvailable == false)
    equiv = Collator.GetFunctionalEquivalent(KW[0], UCultureInfo("zh_Hans"))
    if assertTrue("getFunctionalEquivalent(zh_Hans)!=null", equiv != nil):
assertEquals("getFunctionalEquivalent(zh_Hans)", "zh", equiv.ToString)
proc TestGetFunctionalEquivalent*() =
    var kw = Collator.Keywords
    var DATA: String[] = @["sv", "sv", "t", "sv@collation=direct", "sv", "t", "sv@collation=traditional", "sv", "t", "sv@collation=gb2312han", "sv", "t", "sv@collation=stroke", "sv", "t", "sv@collation=pinyin", "sv", "t", "sv@collation=standard", "sv@collation=standard", "t", "sv@collation=reformed", "sv", "t", "sv@collation=big5han", "sv", "t", "sv_FI", "sv", "f", "sv_FI@collation=direct", "sv", "f", "sv_FI@collation=traditional", "sv", "f", "sv_FI@collation=gb2312han", "sv", "f", "sv_FI@collation=stroke", "sv", "f", "sv_FI@collation=pinyin", "sv", "f", "sv_FI@collation=standard", "sv@collation=standard", "f", "sv_FI@collation=reformed", "sv", "f", "sv_FI@collation=big5han", "sv", "f", "nl", "root", "t", "nl@collation=direct", "root", "t", "nl_BE", "root", "f", "nl_BE@collation=direct", "root", "f", "nl_BE@collation=traditional", "root", "f", "nl_BE@collation=gb2312han", "root", "f", "nl_BE@collation=stroke", "root", "f", "nl_BE@collation=pinyin", "root", "f", "nl_BE@collation=big5han", "root", "f", "nl_BE@collation=phonebook", "root", "f", "en_US_VALLEYGIRL", "root", "f"]
    var DATA_COUNT: int = DATA.Length / 3
      var i: int = 0
      while i < DATA_COUNT:
          var input: UCultureInfo = UCultureInfo(DATA[i * 3 + 0])
          var expect: UCultureInfo = UCultureInfo(DATA[i * 3 + 1])
          var expectAvailable: bool = DATA[i * 3 + 2].Equals("t")
          var actual: UCultureInfo = Collator.GetFunctionalEquivalent(kw[0], input,           var isAvailable: bool)
          if !actual.Equals(expect) || expectAvailable != isAvailable:
Errln("#" + i + ": Collator.getFunctionalEquivalent(" + input + ")=" + actual + ", avail " + isAvailable + ", " + "expected " + expect + " avail " + expectAvailable)
          else:
Logln("#" + i + ": Collator.getFunctionalEquivalent(" + input + ")=" + actual + ", avail " + isAvailable)
++i
proc arrayContains(array: seq[String], s: String): bool =
      var i: int = 0
      while i < array.Length:
          if s.Equals(array[i]):
              return true
++i
    return false
proc TestGetKeywordValues*() =
    var PREFERRED: String[][] = @[@["und", "standard", "eor", "search"], @["en_US", "standard", "eor", "search"], @["en_029", "standard", "eor", "search"], @["de_DE", "standard", "phonebook", "search", "eor"], @["de_Latn_DE", "standard", "phonebook", "search", "eor"], @["zh", "pinyin", "stroke", "eor", "search", "standard"], @["zh_Hans", "pinyin", "stroke", "eor", "search", "standard"], @["zh_CN", "pinyin", "stroke", "eor", "search", "standard"], @["zh_Hant", "stroke", "pinyin", "eor", "search", "standard"], @["zh_TW", "stroke", "pinyin", "eor", "search", "standard"], @["zh__PINYIN", "pinyin", "stroke", "eor", "search", "standard"], @["es_ES", "standard", "search", "traditional", "eor"], @["es__TRADITIONAL", "traditional", "search", "standard", "eor"], @["und@collation=phonebook", "standard", "eor", "search"], @["de_DE@collation=big5han", "standard", "phonebook", "search", "eor"], @["zzz@collation=xxx", "standard", "eor", "search"]]
      var i: int = 0
      while i < PREFERRED.Length:
          var locale: String = PREFERRED[i][0]
          var loc: UCultureInfo = UCultureInfo(locale)
          var expected: String[] = PREFERRED[i]
          var pref: String[] = Collator.GetKeywordValuesForLocale("collation", loc, true)
            var j: int = 1
            while j < expected.Length:
                if !arrayContains(pref, expected[j]):
Errln("Keyword value " + expected[j] + " missing for locale: " + locale)
++j
          var all: String[] = Collator.GetKeywordValuesForLocale("collation", loc, false)
          var matchAll: bool = false
          if pref.Length == all.Length:
              matchAll = true
                var j: int = 0
                while j < pref.Length:
                    var foundMatch: bool = false
                      var k: int = 0
                      while k < all.Length:
                          if pref[j].Equals(all[k]):
                              foundMatch = true
                              break
++k
                    if !foundMatch:
                        matchAll = false
                        break
++j
          if !matchAll:
Errln(string.Format(StringFormatter.CurrentCulture, "FAIL: All values for locale {0} got:{1} expected:{2}", loc, all, pref))
++i