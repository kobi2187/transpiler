# "Namespace: ICU4N.Dev.Test.Util"
type
  ULocaleCollationTest = ref object


type
  ServiceFacade = ref object
    create: Func[UCultureInfo, object]

proc newServiceFacade(create: Func[UCultureInfo, object]): ServiceFacade =
  self.create = create
proc Create*(req: UCultureInfo): object =
    return create(req)
type
  Registrar = ref object
    register: Func[UCultureInfo, object, object]
    unregister: Func[object, bool]

proc newRegistrar(register: Func[UCultureInfo, object, object], unregister: Func[object, bool]): Registrar =
  self.register = register
  self.unregister = unregister
proc Register*(loc: UCultureInfo, prototype: object): object =
    return     if register != nil:
register(loc, prototype)
    else:
nil
proc Unregister*(key: object): bool =
    return     if unregister != nil:
unregister(key)
    else:
false
proc TestCollator*() =
CheckService("ja_JP_YOKOHAMA", ServiceFacade(<unhandled: nnkLambda>), nil, Registrar(<unhandled: nnkLambda>, <unhandled: nnkLambda>))
type
  IServiceFacade = object

type
  ISubobject = object

type
  IRegistrar = object

proc Loccmp(str: String, prefix: String): int =
      var slen: int = str.Length
      var plen: int = prefix.Length
    if prefix.Equals("root"):
        return         if str.Equals("root"):
0
        else:
1
    if plen == 0:
        return         if slen == 0:
0
        else:
1
    if !str.StartsWith(prefix, StringComparison.Ordinal):
      return -1
    if slen == plen:
      return 0
    if str[plen] == '_':
      return 1
    return -2
proc Checklocs(label: String, req: String, validLoc: CultureInfo, actualLoc: CultureInfo, expReqValid: String, expValidActual: String) =
    var valid: String = validLoc.ToString
    var actual: String = actualLoc.ToString
    var reqValid: int = Loccmp(req, valid)
    var validActual: int = Loccmp(valid, actual)
    var reqOK: bool = expReqValid.Equals("gt") && reqValid > 0 || expReqValid.Equals("ge") && reqValid >= 0 || expReqValid.Equals("eq") && reqValid == 0
    var valOK: bool = expValidActual.Equals("gt") && validActual > 0 || expValidActual.Equals("ge") && validActual >= 0 || expValidActual.Equals("eq") && validActual == 0
    if reqOK && valOK:
Logln("Ok: " + label + "; req=" + req + ", valid=" + valid + ", actual=" + actual)
    else:
Errln("FAIL: " + label + "; req=" + req + ", valid=" + valid + ", actual=" + actual +         if reqOK:
""
        else:
"
  req !" + expReqValid + " valid" +         if valOK:
""
        else:
"
  val !" + expValidActual + " actual")
proc CheckObject(requestedLocale: String, obj: Object, expReqValid: String, expValidActual: String) =
    try:
        var cls: Type = obj.GetType
        var validProperty: PropertyInfo = cls.GetProperty("ValidCulture")
        var valid: UCultureInfo = cast[UCultureInfo](validProperty.GetValue(obj, seq[object]))
        var actualProperty: PropertyInfo = cls.GetProperty("ActualCulture")
        var actual: UCultureInfo = cast[UCultureInfo](actualProperty.GetValue(obj, seq[object]))
Checklocs(cls.Name, requestedLocale, valid.ToCultureInfo, actual.ToCultureInfo, expReqValid, expValidActual)
    except MissingMethodException:

    except ArgumentException:
Errln("FAIL: reflection failed: " + e4)
    except TargetInvocationException:

proc CheckService(requestedLocale: String, svc: ServiceFacade) =
CheckService(requestedLocale, svc, nil, nil)
proc CheckService(requestedLocale: String, svc: IServiceFacade, sub: ISubobject, reg: IRegistrar) =
    var req: UCultureInfo = UCultureInfo(requestedLocale)
    var obj: Object = svc.Create(req)
CheckObject(requestedLocale, obj, "gt", "ge")
    if sub != nil:
        var subobj: Object = sub.Get(obj)
CheckObject(requestedLocale, subobj, "gt", "ge")
    if reg != nil:
Logln("Info: Registering service")
        var key: Object = reg.Register(req, obj)
        var objReg: Object = svc.Create(req)
CheckObject(requestedLocale, objReg, "eq", "eq")
        if sub != nil:
            var subobj: Object = sub.Get(obj)
CheckObject(requestedLocale, subobj, "gt", "ge")
Logln("Info: Unregistering service")
        if !reg.Unregister(key):
Errln("FAIL: unregister failed")
        var objUnreg: Object = svc.Create(req)
CheckObject(requestedLocale, objUnreg, "gt", "ge")
proc TestNameList*() =
    var tests: string[][][] = @[@[@["fr-Cyrl-BE", "fr-Cyrl-CA"], @["Français (cyrillique, Belgique)", "Français (cyrillique, Belgique)", "fr_Cyrl_BE", "fr_Cyrl_BE"], @["Français (cyrillique, Canada)", "Français (cyrillique, Canada)", "fr_Cyrl_CA", "fr_Cyrl_CA"]], @[@["en", "de", "fr", "zh"], @["Allemand", "Deutsch", "de", "de"], @["Anglais", "English", "en", "en"], @["Chinois", "中文", "zh", "zh"], @["Français", "Français", "fr", "fr"]], @[@["iw", "iw-US", "no", "no-Cyrl", "in", "in-YU"], @["Hébreu (États-Unis)", "עברית (ארצות הברית)", "iw_US", "iw_US"], @["Hébreu (Israël)", "עברית (ישראל)", "iw", "iw_IL"], @["Indonésien (Indonésie)", "Indonesia (Indonesia)", "in", "in_ID"], @["Indonésien (Serbie)", "Indonesia (Serbia)", "in_YU", "in_YU"], @["Norvégien (cyrillique)", "Norsk (kyrillisk)", "no_Cyrl", "no_Cyrl"], @["Norvégien (latin)", "Norsk (latinsk)", "no", "no_Latn"]], @[@["zh-Hant-TW", "en", "en-gb", "fr", "zh-Hant", "de", "de-CH", "zh-TW"], @["Allemand (Allemagne)", "Deutsch (Deutschland)", "de", "de_DE"], @["Allemand (Suisse)", "Deutsch (Schweiz)", "de_CH", "de_CH"], @["Anglais (États-Unis)", "English (United States)", "en", "en_US"], @["Anglais (Royaume-Uni)", "English (United Kingdom)", "en_GB", "en_GB"], @["Chinois (traditionnel)", "中文（繁體）", "zh_Hant", "zh_Hant"], @["Français", "Français", "fr", "fr"]], @[@["zh", "en-gb", "en-CA", "fr-Latn-FR"], @["Anglais (Canada)", "English (Canada)", "en_CA", "en_CA"], @["Anglais (Royaume-Uni)", "English (United Kingdom)", "en_GB", "en_GB"], @["Chinois", "中文", "zh", "zh"], @["Français", "Français", "fr", "fr"]], @[@["en-gb", "fr", "zh-Hant", "zh-SG", "sr", "sr-Latn"], @["Anglais (Royaume-Uni)", "English (United Kingdom)", "en_GB", "en_GB"], @["Chinois (simplifié, Singapour)", "中文（简体，新加坡）", "zh_SG", "zh_Hans_SG"], @["Chinois (traditionnel, Taïwan)", "中文（繁體，台灣）", "zh_Hant", "zh_Hant_TW"], @["Français", "Français", "fr", "fr"], @["Serbe (cyrillique)", "Српски (ћирилица)", "sr", "sr_Cyrl"], @["Serbe (latin)", "Srpski (latinica)", "sr_Latn", "sr_Latn"]], @[@["fr-Cyrl", "fr-Arab"], @["Français (arabe)", "Français (arabe)", "fr_Arab", "fr_Arab"], @["Français (cyrillique)", "Français (cyrillique)", "fr_Cyrl", "fr_Cyrl"]], @[@["fr-Cyrl-BE", "fr-Arab-CA"], @["Français (arabe, Canada)", "Français (arabe, Canada)", "fr_Arab_CA", "fr_Arab_CA"], @["Français (cyrillique, Belgique)", "Français (cyrillique, Belgique)", "fr_Cyrl_BE", "fr_Cyrl_BE"]]]
    var french: UCultureInfo = UCultureInfo("fr")
    var names: CultureDisplayNames = CultureDisplayNames.GetInstance(french, DisplayContextOptions)
Logln("Contexts: " + names.DisplayContextOptions.ToString)
    var collator: Collator = Collator.GetInstance(french)
    for test in tests:
        var list = JCG.LinkedHashSet<UCultureInfo>
        var expected: IList<UiListItem> = JCG.List<UiListItem>
        for item in test[0]:
list.Add(UCultureInfo(item))
          var i: int = 1
          while i < test.Length:
              var rawRow: String[] = test[i]
expected.Add(UiListItem(UCultureInfo(rawRow[2]), UCultureInfo(rawRow[3]), rawRow[0], rawRow[1]))
++i
        var newList: IList<UiListItem> = names.GetUiList(list, false, collator)
        if !expected.Equals(newList):
            if expected.Count != newList.Count:
Errln(string.Format(StringFormatter.CurrentCulture, "{0}", list) + ": wrong size" + expected + ", " + newList)
            else:
Errln(string.Format(StringFormatter.CurrentCulture, "{0}", list))
                  var i: int = 0
                  while i < expected.Count:
assertEquals(i + "", expected[i], newList[i])
++i
        else:
assertEquals(string.Format(StringFormatter.CurrentCulture, "{0}", list), expected, newList)
proc TestIllformedLocale*() =
    var french: UCultureInfo = UCultureInfo("fr")
    var collator: Collator = Collator.GetInstance(french)
    var names: CultureDisplayNames = CultureDisplayNames.GetInstance(french, DisplayContextOptions)
    for malformed in @["en-a", "$", "ü--a", "en--US"]:
        try:
            var supported: ISet<UCultureInfo> = HashSet<UCultureInfo>
names.GetUiList(supported, false, collator)
assertNull("Failed to detect bogus locale «" + malformed + "»", supported)
        except IllformedLocaleException:
Logln("Successfully detected ill-formed locale «" + malformed + "»:" + e.ToString)