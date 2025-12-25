# "Namespace: ICU4N.Dev.Test.Util"
type
  ICUServiceThreadTest = ref object
    PRINTSTATS: bool = false
    countries: seq[string] = @["ab", "bc", "cd", "de", "ef", "fg", "gh", "ji", "ij", "jk"]
    languages: seq[string] = @["", "ZY", "YX", "XW", "WV", "VU", "UT", "TS", "SR", "RQ", "QP"]
    variants: seq[string] = @["", "", "", "GOLD", "SILVER", "BRONZE"]
    r: Random = Random
    WAIT: bool = true
    GO: bool = false
    TIME: long = 5000
    stableService: ICUService

type
  TestFactory = ref object


proc newTestFactory(id: string): TestFactory =
newICUSimpleFactory(UCultureInfo(id), id, true)
proc GetDisplayName*(idForDisplay: string, locale: UCultureInfo): string =
    return     if visible && idForDisplay.Equals(self.id):
"(" + locale.ToString + ") " + idForDisplay
    else:
nil
proc ToString*(): string =
    return "Factory_" + id
proc GetDisplayNames*(service: ICUService, locale: UCultureInfo): IDictionary<string, string> =
    var col: CompareInfo
    try:
        col = CompareInfo.GetCompareInfo(locale.ToCultureInfo.ToString)
    except MissingManifestResourceException:
        col = nil
    return service.GetDisplayNames(locale, col, nil)
proc GetCLV(): string =
    var c: string = countries[r.Next(countries.Length)]
    var l: string = languages[r.Next(languages.Length)]
    var v: string = variants[r.Next(variants.Length)]
    var sb = StringBuilder(c)
    if !string.IsNullOrEmpty(l):
sb.Append('_')
sb.Append(l)
        if !string.IsNullOrEmpty(v):
sb.Append('_')
sb.Append(v)
    return sb.ToString
proc RunThreads*() =
RunThreads(TIME)
proc RunThreads*(time: long) =
    GO = true
    WAIT = false
Thread.Sleep(cast[int](time))
    WAIT = true
    GO = false
Thread.Sleep(300)
type
  TestThread = ref object
    service: ICUService
    delay: long

proc newTestThread(name: string, service: ICUService, delay: long): TestThread =
  self.service = service
  self.delay = delay
  self.IsBackground = true
proc Run*() =
    while WAIT:
Thread.Sleep(0)
    while GO:
Iterate
        if delay > 0:
Thread.Sleep(cast[int](delay))
proc Iterate() =

type
  RegisterFactoryThread = ref object


proc newRegisterFactoryThread(name: string, service: ICUService, delay: long): RegisterFactoryThread =
newTestThread("REG " + name, service, delay)
proc Iterate() =
    var f: IServiceFactory = TestFactory(GetCLV)
service.RegisterFactory(f)
TestFmwk.Logln(f.ToString)
type
  UnregisterFactoryThread = ref object
    r: Random
    factories: IList[IServiceFactory]

proc newUnregisterFactoryThread(name: string, service: ICUService, delay: long): UnregisterFactoryThread =
newTestThread("UNREG " + name, service, delay)
  r = Random
  factories = service.Factories
proc Iterate() =
    var s: int = factories.Count
    if s == 0:
        factories = service.Factories
    else:
        var n: int = r.Next(s)
        var f: IServiceFactory = factories[n]
factories.Remove(f)
        var success: bool = service.UnregisterFactory(f)
TestFmwk.Logln("factory: " + f +         if success:
" succeeded."
        else:
" *** failed.")
type
  UnregisterFactoryListThread = ref object
    factories: seq[IServiceFactory]
    n: int

proc newUnregisterFactoryListThread(name: string, service: ICUService, delay: long, factories: seq[IServiceFactory]): UnregisterFactoryListThread =
newTestThread("UNREG " + name, service, delay)
  self.factories = factories
proc Iterate() =
    if n < factories.Length:
        var f: IServiceFactory = factories[++n]
        var success: bool = service.UnregisterFactory(f)
TestFmwk.Logln("factory: " + f +         if success:
" succeeded."
        else:
" *** failed.")
type
  GetVisibleThread = ref object


proc newGetVisibleThread(name: string, service: ICUService, delay: long): GetVisibleThread =
newTestThread("VIS " + name, service, delay)
proc Iterate() =
    var ids = service.GetVisibleIDs
    var iter = ids.GetEnumerator
    var n: int = 10
    while --n >= 0 && iter.MoveNext:
        var id: string = cast[string](iter.Current)
        var result: object = service.Get(id)
TestFmwk.Logln("iter: " + n + " id: " + id + " result: " + result)
type
  GetDisplayThread = ref object
    locale: UCultureInfo

proc newGetDisplayThread(name: string, service: ICUService, delay: long, locale: UCultureInfo): GetDisplayThread =
newTestThread("DIS " + name, service, delay)
  self.locale = locale
proc Iterate() =
    var names = GetDisplayNames(service, locale)
    var iter = names.GetEnumerator
    var n: int = 10
    while --n >= 0 && iter.MoveNext:
        var e = iter.Current
        var dname: string = cast[string](e.Key)
        var id: string = cast[string](e.Value)
        var result: object = service.Get(id)
        var num: string = n.ToString(CultureInfo.InvariantCulture)
TestFmwk.Logln(" iter: " + num + " dname: " + dname + " id: " + id + " result: " + result)
type
  GetThread = ref object
    actualID: string

proc newGetThread(name: string, service: ICUService, delay: long): GetThread =
newTestThread("GET " + name, service, delay)
proc Iterate() =
    var id: string = GetCLV
    var o: object = service.Get(id, actualID)
    if o != nil:
TestFmwk.Logln(" id: " + id + " actual: " + actualID + " result: " + o)
type
  GetListThread = ref object
    list: seq[string]
    n: int

proc newGetListThread(name: string, service: ICUService, delay: long, list: seq[string]): GetListThread =
newTestThread("GETL " + name, service, delay)
  self.list = list
proc Iterate() =
    if --n < 0:
        n = list.Length - 1
    var id: string = list[n]
    var o: object = service.Get(id)
TestFmwk.Logln(" id: " + id + " result: " + o)
proc GetFactoryCollection(requested: int): ICollection<IServiceFactory> =
    var locales = HashSet<string>
      var i: int = 0
      while i < requested:
locales.Add(GetCLV)
++i
    var factories = List<IServiceFactory>(locales.Count)
    var iter = locales.GetEnumerator
    while iter.MoveNext:
factories.Add(TestFactory(cast[string](iter.Current)))
    return factories
proc RegisterFactories(service: ICUService, c: ICollection[IServiceFactory]) =
      let iter = c.GetEnumerator
<unhandled: nnkDefer>
      while iter.MoveNext:
service.RegisterFactory(cast[IServiceFactory](iter.Current))
proc StableService(): ICUService =
    if stableService == nil:
        stableService = ICULocaleService
RegisterFactories(stableService, GetFactoryCollection(50))
    if PRINTSTATS:
stableService.Stats
    return stableService
proc Test00_ConcurrentGet*() =
      var i: int = 0
      while i < 10:
GetThread("[" + i.ToString(CultureInfo.InvariantCulture) + "]", StableService, 0).Start
++i
RunThreads
    if PRINTSTATS:
Console.Out.WriteLine(stableService.Stats)
proc Test01_ConcurrentGetVisible*() =
      var i: int = 0
      while i < 10:
GetVisibleThread("[" + i.ToString(CultureInfo.InvariantCulture) + "]", StableService, 0).Start
++i
RunThreads
    if PRINTSTATS:
Console.Out.WriteLine(stableService.Stats)
proc Test02_ConcurrentGetDisplay*() =
    var localeNames: string[] = @["en", "es", "de", "fr", "zh", "it", "no", "sv"]
      var i: int = 0
      while i < localeNames.Length:
          var locale: string = localeNames[i]
GetDisplayThread("[" + locale + "]", StableService, 0, UCultureInfo(locale)).Start
++i
RunThreads
    if PRINTSTATS:
Console.Out.WriteLine(stableService.Stats)
proc Test03_ConcurrentRegUnreg*() =
    var service: ICUService = ICULocaleService
    if PRINTSTATS:
service.Stats
      var i: int = 0
      while i < 5:
RegisterFactoryThread("[" + i + "]", service, 0).Start
++i
      var i: int = 0
      while i < 5:
UnregisterFactoryThread("[" + i + "]", service, 0).Start
++i
RunThreads
    if PRINTSTATS:
Console.Out.WriteLine(service.Stats)
proc Test04_WitheringService*() =
    var service: ICUService = ICULocaleService
    if PRINTSTATS:
service.Stats
    var fc = GetFactoryCollection(50)
RegisterFactories(service, fc)
    var factories: IServiceFactory[] = cast[IServiceFactory[]](fc.ToArray)
    var comp = Comparer[object].Create(<unhandled: nnkLambda>)
Array.Sort(factories, comp)
GetThread("", service, 0).Start
UnregisterFactoryListThread("", service, 3, factories).Start
RunThreads(2000)
    if PRINTSTATS:
Console.Out.WriteLine(service.Stats)
proc Test05_ConcurrentEverything*() =
    var service: ICUService = ICULocaleService
    if PRINTSTATS:
service.Stats
RegisterFactoryThread("", service, 500).Start
      var i: int = 0
      while i < 15:
GetThread("[" + i.ToString(CultureInfo.InvariantCulture) + "]", service, 0).Start
++i
GetVisibleThread("", service, 50).Start
    var localeNames: string[] = @["en", "de"]
      var i: int = 0
      while i < localeNames.Length:
          var locale: string = localeNames[i]
GetDisplayThread("[" + locale + "]", StableService, 500, UCultureInfo(locale)).Start
++i
UnregisterFactoryThread("", service, 500).Start
RunThreads(9500)
    if PRINTSTATS:
Console.Out.WriteLine(service.Stats)