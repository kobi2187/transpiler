# "Namespace: ICU4N.Dev.Test.Util"
type
  ICUServiceTest = ref object


proc lrmsg(message: string, lhs: object, rhs: object): string =
    return message + " lhs: " + lhs + " rhs: " + rhs
proc confirmBoolean*(message: string, val: bool) =
msg(message,     if val:
LOG
    else:
ERR, !val, true)
proc confirmEqual*(message: string, lhs: object, rhs: object) =
msg(lrmsg(message, lhs, rhs),     if     if lhs == nil:
rhs == nil
    else:
lhs.Equals(rhs):
LOG
    else:
ERR, true, true)
proc confirmIdentical*(message: string, lhs: object, rhs: object) =
msg(lrmsg(message, lhs, rhs),     if lhs == rhs:
LOG
    else:
ERR, true, true)
proc confirmIdentical*(message: string, lhs: int, rhs: int) =
msg(message + " lhs: " + lhs + " rhs: " + rhs,     if lhs == rhs:
LOG
    else:
ERR, true, true)
proc GetDisplayNames*(service: ICUService): IDictionary<string, string> =
    var locale: UCultureInfo = UCultureInfo.CurrentCulture
    var col: CompareInfo = CompareInfo.GetCompareInfo(locale.ToCultureInfo.Name)
    return service.GetDisplayNames(locale, col, nil)
proc GetDisplayNames*(service: ICUService, locale: UCultureInfo): IDictionary<string, string> =
    var col: CompareInfo = CompareInfo.GetCompareInfo(locale.ToCultureInfo.Name)
    return service.GetDisplayNames(locale, col, nil)
proc GetDisplayNames*(service: ICUService, locale: UCultureInfo, matchID: string): IDictionary<string, string> =
    var col: CompareInfo = CompareInfo.GetCompareInfo(locale.ToCultureInfo.Name)
    return service.GetDisplayNames(locale, col, matchID)
type
  TestService = ref object


proc newTestService(): TestService =
newICUService("Test Service")
proc CreateKey*(id: string): ICUServiceKey =
    return LocaleKey.CreateWithCanonicalFallback(id, nil)
type
  AnonymousFactory = ref object
    create: Func[ICUServiceKey, ICUService, object]
    getDisplayName: Func[string, UCultureInfo, string]
    updateVisibleIds: Action[IDictionary<string, IServiceFactory>]

proc newAnonymousFactory(create: Func[ICUServiceKey, ICUService, object], getDisplayName: Func[string, UCultureInfo, string], updateVisibleIds: Action[IDictionary<string, IServiceFactory>]): AnonymousFactory =
  self.create = create
  self.getDisplayName = getDisplayName
  self.updateVisibleIds = updateVisibleIds
proc Create*(key: ICUServiceKey, service: ICUService): object =
    return     if create != nil:
create(key, service)
    else:
UCultureInfo(key.CurrentID)
proc GetDisplayName*(id: string, locale: UCultureInfo): string =
    return     if getDisplayName != nil:
getDisplayName(id, locale)
    else:
string.Empty
proc UpdateVisibleIDs*(result: IDictionary[string, IServiceFactory]) =
    if updateVisibleIds != nil:
updateVisibleIds..Invoke(result)
    else:
nil
type
  AnonymousServiceListener = ref object
    serviceChanged: Action[ICUService, AnonymousServiceListener]
    n: int

proc newAnonymousServiceListener(serviceChanged: Action[ICUService, AnonymousServiceListener]): AnonymousServiceListener =
  self.serviceChanged =   if serviceChanged != nil:
serviceChanged
  else:
      raise ArgumentNullException(nameof(serviceChanged))
proc ServiceChanged*(service: ICUService) =
serviceChanged(service, self)
proc TestAPI*() =
    var service: ICUService = TestService
Logln("service name:" + service.Name)
    var singleton0: Integer = Integer(0)
service.RegisterObject(singleton0, "en_US")
    var result: object = service.Get("en_US_FOO")
confirmIdentical("1) en_US_FOO -> en_US", result, singleton0)
    var singleton1: Integer = Integer(1)
service.RegisterObject(singleton1, "en_US_FOO")
    result = service.Get("en_US_FOO")
confirmIdentical("2) en_US_FOO -> en_US_FOO", result, singleton1)
    result = service.Get("en_US_BAR")
confirmIdentical("3) en_US_BAR -> en_US", result, singleton0)
    var factories: IList<IServiceFactory> = service.Factories
confirmIdentical("4) factory size", factories.Count, 2)
    var singleton2: Integer = Integer(2)
service.RegisterObject(singleton2, "en")
confirmIdentical("5) factory size", factories.Count, 2)
    result = service.Get("en_US_BAR")
confirmIdentical("6) en_US_BAR -> en_US", result, singleton0)
    var singleton3: Integer = Integer(3)
service.RegisterObject(singleton3, "en_US")
    factories = service.Factories
confirmIdentical("9) factory size", factories.Count, 4)
    result = service.Get("en_US_BAR")
confirmIdentical("10) en_US_BAR -> (3)", result, singleton3)
service.UnregisterFactory(cast[IServiceFactory](factories[0]))
    factories = service.Factories
confirmIdentical("11) factory size", factories.Count, 3)
    result = service.Get("en_US_BAR")
confirmIdentical("12) en_US_BAR -> 0", result, singleton0)
    result = service.Get("foo")
confirmIdentical("13) foo -> null", result, nil)
    result = service.Get("EN_us_fOo",     var resultID: string)
confirmEqual("14) find non-canonical", resultID, "en_US_FOO")
service.RegisterObject(singleton3, "eN_ca_dUde")
    result = service.Get("En_Ca_DuDe", resultID)
confirmEqual("15) register non-canonical", resultID, "en_CA_DUDE")
    var singleton4: Integer = Integer(4)
service.RegisterObject(singleton4, "en_US_BAR", false)
    result = service.Get("en_US_BAR")
confirmIdentical("17) get invisible", result, singleton4)
    var ids = service.GetVisibleIDs
confirmBoolean("18) find invisible", !ids.Contains("en_US_BAR"))
service.Reset
      var factory: IServiceFactory = AnonymousFactory(nil, cast[Func<string, UCultureInfo, string>](nil), nil)
service.RegisterFactory(factory)
      result = service.Get(UCultureInfo("en_US").ToString)
confirmEqual("21) locale", result, UCultureInfo("en_US"))
      result = service.Get("EN_US_BAR")
confirmEqual("22) locale", result, UCultureInfo("en_US_BAR"))
service.RegisterObject(singleton3, "en_US_BAR")
      result = service.Get("en_US_BAR")
confirmIdentical("23) override super", result, singleton3)
service.Reset
    result = service.Get("en_US")
confirmIdentical("24) empty", result, nil)
      var xids: string[] = @["en_US_VALLEY_GIRL", "en_US_VALLEY_BOY", "en_US_SURFER_GAL", "en_US_SURFER_DUDE"]
service.RegisterFactory(TestLocaleKeyFactory(xids, "Later"))
      var vids: ICollection<string> = service.GetVisibleIDs
      var iter = vids.GetEnumerator
      var count: int = 0
      while iter.MoveNext:
++count
          var id: string = cast[string](iter.Current)
Logln("  " + id + " --> " + service.Get(id))
confirmIdentical("25) visible ids", count, 4)
      var dids = GetDisplayNames(service, UCultureInfo("de"))
      var iter = dids.GetEnumerator
      var count: int = 0
      while iter.MoveNext:
++count
          var e = iter.Current
Logln("  " + e.Key + " -- > " + e.Value)
confirmIdentical("26) display names", count, 4)
confirmIdentical("27) get display name", service.GetDisplayName("en_US_VALLEY_GEEK"), nil)
      var name: string = service.GetDisplayName("en_US_SURFER_DUDE", UCultureInfo("en_US"))
confirmEqual("28) get display name", name, "English (United States, SURFER_DUDE)")
      var xids: string[] = @["en_US_SURFER", "en_US_SURFER_GAL", "en_US_SILICON", "en_US_SILICON_GEEK"]
service.RegisterFactory(TestLocaleKeyFactory(xids, "Rad dude"))
      var dids = GetDisplayNames(service)
      var iter = dids.GetEnumerator
      var count: int = 0
      while iter.MoveNext:
++count
          var e = iter.Current
Logln("  " + e.Key + " --> " + e.Value)
confirmIdentical("29) display names", count, 7)
      var id: string = "en_us_surfer_gal"
      var gal: string = cast[string](service.Get(id,       var actualID: string))
      if gal != nil:
Logln("actual id: " + actualID)
          var displayName: string = service.GetDisplayName(actualID, UCultureInfo("en_US"))
Logln("found actual: " + gal + " with display name: " + displayName)
confirmBoolean("30) found display name for actual", displayName != nil)
          displayName = service.GetDisplayName(id, UCultureInfo("en_US"))
Logln("found query: " + gal + " with display name: " + displayName)
      else:
Errln("30) service could not find entry for " + id)
      id = "en_US_SURFER_BOZO"
      var bozo: string = cast[string](service.Get(id, actualID))
      if bozo != nil:
          var displayName: string = service.GetDisplayName(actualID, UCultureInfo("en_US"))
Logln("found actual: " + bozo + " with display name: " + displayName)
confirmBoolean("32) found display name for actual", displayName != nil)
          displayName = service.GetDisplayName(id, UCultureInfo("en_US"))
Logln("found actual: " + bozo + " with display name: " + displayName)
      else:
Errln("32) service could not find entry for " + id)
confirmBoolean("34) is default ", !service.IsDefault)
      var xids = service.GetVisibleIDs
      var iter = xids.GetEnumerator
      while iter.MoveNext:
          var xid: string = cast[string](iter.Current)
Logln(xid + "?  " + service.Get(xid))
Logln("valleygirl?  " + service.Get("en_US_VALLEY_GIRL"))
Logln("valleyboy?   " + service.Get("en_US_VALLEY_BOY"))
Logln("valleydude?  " + service.Get("en_US_VALLEY_DUDE"))
Logln("surfergirl?  " + service.Get("en_US_SURFER_GIRL"))
service.Reset
service.RegisterFactory(ICUResourceBundleFactory)
Logln("all visible ids: " + service.GetVisibleIDs)
Logln("visible ids for es locale: " + service.GetVisibleIDs("es"))
Logln("display names: " + GetDisplayNames(service, UCultureInfo("es"), "es"))
Logln("display names in reverse order: " + service.GetDisplayNames(UCultureInfo("en_US"), Comparer[object].Create(<unhandled: nnkLambda>)))
Logln("service display names for de_DE")
      var names = GetDisplayNames(service, UCultureInfo("de_DE"))
      var buf: StringBuffer = StringBuffer("{")
      var iter = names.GetEnumerator
      while iter.MoveNext:
          var e = iter.Current
          var name: string = cast[string](e.Key)
          var id: string = cast[string](e.Value)
buf.Append("
   " + name + " --> " + id)
buf.Append("
}")
Logln(buf.ToString)
    var califactory: CalifornioLanguageFactory = CalifornioLanguageFactory
service.RegisterFactory(califactory)
Logln("californio language factory")
      var buf: StringBuffer = StringBuffer("{")
      var idNames: string[] = @[CalifornioLanguageFactory.californio, CalifornioLanguageFactory.valley, CalifornioLanguageFactory.surfer, CalifornioLanguageFactory.geek]
        var i: int = 0
        while i < idNames.Length:
            var idName: string = idNames[i]
buf.Append("
  --- " + idName + " ---")
            var names = GetDisplayNames(service, UCultureInfo(idName))
            var iter = names.GetEnumerator
            while iter.MoveNext:
                var e = iter.Current
                var name: string = cast[string](e.Key)
                var id: string = cast[string](e.Value)
buf.Append("
    " + name + " --> " + id)
++i
buf.Append("
}")
Logln(buf.ToString)
Logln("simple registration notification")
      var ls: ICULocaleService = ICULocaleService
      var l1: IServiceListener = AnonymousServiceListener(<unhandled: nnkLambda>)
ls.AddListener(l1)
      var l2: IServiceListener = AnonymousServiceListener(<unhandled: nnkLambda>)
ls.AddListener(l2)
Logln("registering foo... ")
ls.RegisterObject("Foo", "en_FOO")
Logln("registering bar... ")
ls.RegisterObject("Bar", "en_BAR")
Logln("getting foo...")
Logln(cast[string](ls.Get("en_FOO")))
Logln("removing listener 2...")
ls.RemoveListener(l2)
Logln("registering baz...")
ls.RegisterObject("Baz", "en_BAZ")
Logln("removing listener 1")
ls.RemoveListener(l1)
Logln("registering burp...")
ls.RegisterObject("Burp", "en_BURP")
Logln("... trying multiple registration")
ls.AddListener(l1)
ls.AddListener(l1)
ls.AddListener(l1)
ls.AddListener(l2)
ls.RegisterObject("Foo", "en_FOO")
Logln("... registered foo")
      var l3: IServiceListener = AnonymousServiceListener(<unhandled: nnkLambda>)
ls.AddListener(l3)
Logln("registering boo...")
ls.RegisterObject("Boo", "en_BOO")
Logln("...done")
Thread.Sleep(100)
type
  TestLocaleKeyFactory = ref object
    ids: ISet[string]
    factoryID: string

proc newTestLocaleKeyFactory(ids: seq[string], factoryID: string): TestLocaleKeyFactory =
newLocaleKeyFactory(Visible, factoryID)
  self.ids = HashSet<string>(ids).AsReadOnly
  self.factoryID = factoryID + ": "
proc HandleCreate(loc: UCultureInfo, kind: int, service: ICUService): object =
    return factoryID + loc.ToString
proc GetSupportedIDs(): ICollection<string> =
    return ids
type
  CalifornioLanguageFactory = ref object
    californio: string = "en_US_CA"
    valley: string = californio + "_VALLEY"
    surfer: string = californio + "_SURFER"
    geek: string = californio + "_GEEK"
    supportedIDs: ISet[string] = LoadSupportedIDs

proc LoadSupportedIDs(): ISet<string> =
    var result: HashSet<string> = HashSet<string>
result.UnionWith(ICUResourceBundle.GetAvailableLocaleNameSet)
result.Add(californio)
result.Add(valley)
result.Add(surfer)
result.Add(geek)
    return result.AsReadOnly
proc GetSupportedIDs(): ICollection<string> =
    return supportedIDs
proc GetDisplayName*(id: string, locale: UCultureInfo): string =
    var prefix: string = ""
    var suffix: string = ""
    var ls: string = locale.ToString
    if LocaleUtility.IsFallbackOf(californio, ls):
        if ls.Equals(valley, StringComparison.OrdinalIgnoreCase):
            prefix = "Like, you know, it's so totally "

        elif ls.Equals(surfer, StringComparison.OrdinalIgnoreCase):
            prefix = "Dude, its "
        else:
          if ls.Equals(geek, StringComparison.OrdinalIgnoreCase):
              prefix = "I'd estimate it's approximately "
          else:
              prefix = "Huh?  Maybe "
    if LocaleUtility.IsFallbackOf(californio, id):
        if id.Equals(valley, StringComparison.OrdinalIgnoreCase):
            suffix = "like the Valley, you know?  Let's go to the mall!"

        elif id.Equals(surfer, StringComparison.OrdinalIgnoreCase):
            suffix = "time to hit those gnarly waves, Dude!!!"
        else:
          if id.Equals(geek, StringComparison.OrdinalIgnoreCase):
              suffix = "all systems go.  T-Minus 9, 8, 7..."
          else:
              suffix = "No Habla Englais"
    else:
        suffix = procCall.GetDisplayName(id, locale)
    return prefix + suffix
proc TestLocale*() =
    var service: ICULocaleService = ICULocaleService("test locale")
service.RegisterObject("root", UCultureInfo.InvariantCulture)
service.RegisterObject("german", "de")
service.RegisterObject("german_Germany", UCultureInfo("de_DE"))
service.RegisterObject("japanese", "ja")
service.RegisterObject("japanese_Japan", UCultureInfo("ja_JP"))
    var target: object = service.Get("de_US")
confirmEqual("test de_US", "german", target)
    var de: UCultureInfo = UCultureInfo("de")
    var de_US: UCultureInfo = UCultureInfo("de_US")
    target = service.Get(de_US)
confirmEqual("test de_US 2", "german", target)
    target = service.Get(de_US, LocaleKey.KindAny)
confirmEqual("test de_US 3", "german", target)
    target = service.Get(de_US, 1234)
confirmEqual("test de_US 4", "german", target)
    target = service.Get(de_US,     var actualReturn: UCultureInfo)
confirmEqual("test de_US 5", "german", target)
confirmEqual("test de_US 6", actualReturn, de)
    target = service.Get(de_US, LocaleKey.KindAny, actualReturn)
confirmEqual("test de_US 7", actualReturn, de)
    target = service.Get(de_US, 1234, actualReturn)
confirmEqual("test de_US 8", "german", target)
confirmEqual("test de_US 9", actualReturn, de)
service.RegisterObject("one/de_US", de_US, 1)
service.RegisterObject("two/de_US", de_US, 2)
    target = service.Get(de_US, 1)
confirmEqual("test de_US kind 1", "one/de_US", target)
    target = service.Get(de_US, 2)
confirmEqual("test de_US kind 2", "two/de_US", target)
    target = service.Get(de_US)
confirmEqual("test de_US kind 3", "german", target)
    var lkey: LocaleKey = LocaleKey.CreateWithCanonicalFallback("en", nil, 1234)
Logln("lkey prefix: " + lkey.Prefix)
Logln("lkey descriptor: " + lkey.GetCurrentDescriptor)
Logln("lkey current locale: " + lkey.GetCurrentCulture)
lkey.Fallback
Logln("lkey descriptor 2: " + lkey.GetCurrentDescriptor)
lkey.Fallback
Logln("lkey descriptor 3: " + lkey.GetCurrentDescriptor)
    target = service.Get("za_PPP")
confirmEqual("test zappp", "root", target)
    var ids: ICollection<string>
      let resource = ThreadCultureChange("ja", "ja")
<unhandled: nnkDefer>
      target = service.Get("za_PPP")
confirmEqual("test with ja locale", "japanese", target)
      ids = service.GetVisibleIDs
        var iter = ids.GetEnumerator
        while iter.MoveNext:
Logln("id: " + iter.Current)
    ids = service.GetVisibleIDs
      var iter = ids.GetEnumerator
      while iter.MoveNext:
Logln("id: " + iter.Current)
    target = service.Get("za_PPP")
confirmEqual("test with en locale", "root", target)
    var locales: UCultureInfo[] = service.GetUCultures(UCultureTypes.AllCultures)
confirmIdentical("test available locales", locales.Length, 6)
Logln("locales: ")
      var i: int = 0
      while i < locales.Length:
Log("
  [" + i + "] " + locales[i])
++i
Logln(" ")
service.RegisterFactory(ICUResourceBundleFactory)
    target = service.Get(UCultureInfo("ja_JP"))
      var n: int = 0
      var factories = service.Factories
      var iter = factories.GetEnumerator
      while iter.MoveNext:
Logln("[" + ++n + "] " + iter.Current)
      var map = service.GetDisplayNames(UCultureInfo("en_US"), Comparer[object].Create(<unhandled: nnkLambda>), "es")
Logln("es display names in reverse order " + map)
type
  WrapFactory = ref object
    greetingID: string

proc newWrapFactory(greetingID: string): WrapFactory =
  self.greetingID = greetingID
proc Create*(key: ICUServiceKey, serviceArg: ICUService): object =
    if key.CurrentID.Equals(greetingID):
        var previous: object = serviceArg.GetKey(key, self)
        return "A different greeting: "" + previous + """
    return nil
proc UpdateVisibleIDs*(result: IDictionary[string, IServiceFactory]) =
    result["greeting"] = self
proc GetDisplayName*(id: string, locale: UCultureInfo): string =
    return "wrap '" + id + "'"
proc TestWrapFactory*() =
    var greeting: string = "Hello There"
    var greetingID: string = "greeting"
    var service: ICUService = ICUService("wrap")
service.RegisterObject(greeting, greetingID)
Logln("test one: " + service.Get(greetingID))
service.RegisterFactory(WrapFactory(greetingID))
confirmEqual("wrap test: ", service.Get(greetingID), "A different greeting: "" + greeting + """)
proc TestCoverage*() =
    var key: ICUServiceKey = ICUServiceKey("foobar")
Logln("ID: " + key.ID)
Logln("canonicalID: " + key.CanonicalID)
Logln("currentID: " + key.CurrentID)
Logln("has fallback: " + key.Fallback)
    var obj: object = object
    var sf: ICUSimpleFactory = ICUSimpleFactory(obj, "object")
    try:
        sf = ICUSimpleFactory(nil, nil)
Errln("didn't throw exception")
    except ArgumentException:
Logln("OK: " + e.ToString)
    except Exception:
Errln("threw wrong exception" + e)
Logln(sf.GetDisplayName("object", cast[UCultureInfo](nil)))
    var service: ICUService = ICUService
service.RegisterFactory(sf)
    try:
service.Get(nil)
Errln("didn't throw exception")
    except ArgumentNullException:
Logln("OK: " + e.ToString)
    try:
service.RegisterFactory(nil)
Errln("didn't throw exception")
    except ArgumentNullException:
Logln("OK: " + e.ToString)
    except Exception:
Errln("threw wrong exception" + e)
    try:
service.UnregisterFactory(nil)
Errln("didn't throw exception")
    except ArgumentNullException:
Logln("OK: " + e.ToString)
    except Exception:
Errln("threw wrong exception" + e)
Logln("object is: " + service.Get("object"))
Logln("stats: " + service.Stats)
    var rwlock: ICUReaderWriterLock = ICUReaderWriterLock
rwlock.ResetStats
rwlock.AcquireRead
rwlock.ReleaseRead
rwlock.AcquireWrite
rwlock.ReleaseWrite
Logln("stats: " + rwlock.GetStats)
Logln("stats: " + rwlock.ClearStats)
rwlock.AcquireRead
rwlock.ReleaseRead
rwlock.AcquireWrite
rwlock.ReleaseWrite
Logln("stats: " + rwlock.GetStats)
    try:
rwlock.ReleaseRead
Errln("no error thrown")
    except Exception:
Logln("OK: " + e.ToString)
    try:
rwlock.ReleaseWrite
Errln("no error thrown")
    except Exception:
Logln("OK: " + e.ToString)
    var lkey: LocaleKey = LocaleKey.CreateWithCanonicalFallback("en_US", "ja_JP")
Logln("lkey: " + lkey)
    lkey = LocaleKey.CreateWithCanonicalFallback(nil, nil)
Logln("lkey from null,null: " + lkey)
    var lkf: LocaleKeyFactory = LKFSubclass(false)
Logln("lkf: " + lkf)
Logln("obj: " + lkf.Create(lkey, nil))
Logln(lkf.GetDisplayName("foo", cast[UCultureInfo](nil)))
Logln(lkf.GetDisplayName("bar", cast[UCultureInfo](nil)))
lkf.UpdateVisibleIDs(Dictionary<string, IServiceFactory>)
    var invisibleLKF: LocaleKeyFactory = LKFSubclass(false)
Logln("obj: " + invisibleLKF.Create(lkey, nil))
Logln(invisibleLKF.GetDisplayName("foo", cast[UCultureInfo](nil)))
Logln(invisibleLKF.GetDisplayName("bar", cast[UCultureInfo](nil)))
invisibleLKF.UpdateVisibleIDs(Dictionary<string, IServiceFactory>)
    var rbf: ICUResourceBundleFactory = ICUResourceBundleFactory
Logln("RB: " + rbf.Create(lkey, nil))
    var nf: ICUNotifier = ICUNSubclass
    try:
nf.AddListener(nil)
Errln("added null listener")
    except ArgumentNullException:
Logln(e.ToString)
    except Exception:
Errln("got wrong exception")
    try:
nf.AddListener(WrongListener)
Errln("added wrong listener")
    except InvalidOperationException:
Logln(e.ToString)
    except Exception:
Errln("got wrong exception")
    try:
nf.RemoveListener(nil)
Errln("removed null listener")
    except ArgumentNullException:
Logln(e.ToString)
    except Exception:
Errln("got wrong exception")
nf.RemoveListener(MyListener)
nf.NotifyChanged
nf.AddListener(MyListener)
nf.RemoveListener(MyListener)
type
  MyListener = ref object


type
  WrongListener = ref object


type
  ICUNSubclass = ref object


proc AcceptsListener(l: IEventListener): bool =
    return l is MyListener
proc NotifyListener(l: IEventListener) =

type
  LKFSubclass = ref object


proc newLKFSubclass(visible: bool): LKFSubclass =
newLocaleKeyFactory(  if visible:
Visible
  else:
Invisible)
proc GetSupportedIDs(): ICollection<string> =
    return HashSet<string>