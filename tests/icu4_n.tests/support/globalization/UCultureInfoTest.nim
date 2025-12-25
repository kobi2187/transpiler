# "Namespace: ICU4N.Globalization"
type
  UCultureInfoTest = ref object
    LOCALE_SIZE: int = 9
    rawData2: seq[string] = @[@["en", "fr", "ca", "el", "no", "zh", "de", "es", "ja"], @["", "", "", "", "", "Hans", "", "", ""], @["US", "FR", "ES", "GR", "NO", "CN", "DE", "", "JP"], @["", "", "", "", "NY", "", "", "", ""], @["en_US", "fr_FR", "ca_ES", "el_GR", "no_NO_NY", "zh_Hans_CN", "de_DE@collation=phonebook", "es@collation=traditional", "ja_JP@calendar=japanese"], @["eng", "fra", "cat", "ell", "nor", "zho", "deu", "spa", "jpn"], @["USA", "FRA", "ESP", "GRC", "NOR", "CHN", "DEU", "", "JPN"], @["409", "40c", "403", "408", "814", "804", "407", "a", "411"], @["English", "French", "Catalan", "Greek", "Norwegian", "Chinese", "German", "Spanish", "Japanese"], @["", "", "", "", "", "Simplified Han", "", "", ""], @["United States", "France", "Spain", "Greece", "Norway", "China", "Germany", "", "Japan"], @["", "", "", "", "NY", "", "", "", ""], @["English (United States)", "French (France)", "Catalan (Spain)", "Greek (Greece)", "Norwegian (Norway, NY)", "Chinese (Simplified Han, China)", "German (Germany, Collation=Phonebook Sort Order)", "Spanish (Collation=Traditional)", "Japanese (Japan, Calendar=Japanese Calendar)"], @["anglais", "fran\u00E7ais", "catalan", "grec", "norv\u00E9gien", "chinois", "allemand", "espagnol", "japonais"], @["", "", "", "", "", "Hans", "", "", ""], @["\u00C9tats-Unis", "France", "Espagne", "Gr\u00E8ce", "Norv\u00E8ge", "Chine", "Allemagne", "", "Japon"], @["", "", "", "", "NY", "", "", "", ""], @["anglais (\u00C9tats-Unis)", "fran\u00E7ais (France)", "catalan (Espagne)", "grec (Gr\u00E8ce)", "norv\u00E9gien (Norv\u00E8ge, NY)", "chinois (Hans, Chine)", "allemand (Allemagne, Ordonnancement=Ordre de l'annuaire)", "espagnol (Ordonnancement=Ordre traditionnel)", "japonais (Japon, Calendrier=Calendrier japonais)"], @["angl\u00E8s", "franc\u00E8s", "catal\u00E0", "grec", "noruec", "xin\u00E9s", "alemany", "espanyol", "japon\u00E8s"], @["", "", "", "", "", "Hans", "", "", ""], @["Estats Units", "Fran\u00E7a", "Espanya", "Gr\u00E8cia", "Noruega", "Xina", "Alemanya", "", "Jap\u00F3"], @["", "", "", "", "NY", "", "", "", ""], @["angl\u00E8s (Estats Units)", "franc\u00E8s (Fran\u00E7a)", "catal\u00E0 (Espanya)", "grec (Gr\u00E8cia)", "noruec (Noruega, NY)", "xin\u00E9s (Hans, Xina)", "alemany (Alemanya, COLLATION=PHONEBOOK)", "espanyol (COLLATION=TRADITIONAL)", "japon\u00E8s (Jap\u00F3, CALENDAR=JAPANESE)"], @["\u0391\u03b3\u03b3\u03bb\u03b9\u03ba\u03ac", "\u0393\u03b1\u03bb\u03bb\u03b9\u03ba\u03ac", "\u039a\u03b1\u03c4\u03b1\u03bb\u03b1\u03bd\u03b9\u03ba\u03ac", "\u0395\u03bb\u03bb\u03b7\u03bd\u03b9\u03ba\u03ac", "\u039d\u03bf\u03c1\u03b2\u03b7\u03b3\u03b9\u03ba\u03ac", "\u039A\u03B9\u03BD\u03B5\u03B6\u03B9\u03BA\u03AC", "\u0393\u03B5\u03C1\u03BC\u03B1\u03BD\u03B9\u03BA\u03AC", "\u0399\u03C3\u03C0\u03B1\u03BD\u03B9\u03BA\u03AC", "\u0399\u03B1\u03C0\u03C9\u03BD\u03B9\u03BA\u03AC"], @["", "", "", "", "", "Hans", "", "", ""], @["\u0397\u03bd\u03c9\u03bc\u03ad\u03bd\u03b5\u03c2 \u03a0\u03bf\u03bb\u03b9\u03c4\u03b5\u03af\u03b5\u03c2", "\u0393\u03b1\u03bb\u03bb\u03af\u03b1", "\u0399\u03c3\u03c0\u03b1\u03bd\u03af\u03b1", "\u0395\u03bb\u03bb\u03ac\u03b4\u03b1", "\u039d\u03bf\u03c1\u03b2\u03b7\u03b3\u03af\u03b1", "\u039A\u03AF\u03BD\u03B1", "\u0393\u03B5\u03C1\u03BC\u03B1\u03BD\u03AF\u03B1", "", "\u0399\u03B1\u03C0\u03C9\u03BD\u03AF\u03B1"], @["", "", "", "", "NY", "", "", "", ""], @["\u0391\u03b3\u03b3\u03bb\u03b9\u03ba\u03ac (\u0397\u03bd\u03c9\u03bc\u03ad\u03bd\u03b5\u03c2 \u03a0\u03bf\u03bb\u03b9\u03c4\u03b5\u03af\u03b5\u03c2)", "\u0393\u03b1\u03bb\u03bb\u03b9\u03ba\u03ac (\u0393\u03b1\u03bb\u03bb\u03af\u03b1)", "\u039a\u03b1\u03c4\u03b1\u03bb\u03b1\u03bd\u03b9\u03ba\u03ac (\u0399\u03c3\u03c0\u03b1\u03bd\u03af\u03b1)", "\u0395\u03bb\u03bb\u03b7\u03bd\u03b9\u03ba\u03ac (\u0395\u03bb\u03bb\u03ac\u03b4\u03b1)", "\u039d\u03bf\u03c1\u03b2\u03b7\u03b3\u03b9\u03ba\u03ac (\u039d\u03bf\u03c1\u03b2\u03b7\u03b3\u03af\u03b1, NY)", "\u039A\u03B9\u03BD\u03B5\u03B6\u03B9\u03BA\u03AC (Hans, \u039A\u03AF\u03BD\u03B1)", "\u0393\u03B5\u03C1\u03BC\u03B1\u03BD\u03B9\u03BA\u03AC (\u0393\u03B5\u03C1\u03BC\u03B1\u03BD\u03AF\u03B1, COLLATION=PHONEBOOK)", "\u0399\u03C3\u03C0\u03B1\u03BD\u03B9\u03BA\u03AC (COLLATION=TRADITIONAL)", "\u0399\u03B1\u03C0\u03C9\u03BD\u03B9\u03BA\u03AC (\u0399\u03B1\u03C0\u03C9\u03BD\u03AF\u03B1, CALENDAR=JAPANESE)"]]
    LANG: int = 0
    SCRIPT: int = 1
    CTRY: int = 2
    VAR: int = 3
    NAME: int = 4
    h: seq[IDictionary<string, string>] = seq[Dictionary<string, string>]
    ACCEPT_LANGUAGE_TESTS: seq[string] = @[@["mt_MT", "false"], @["en", "false"], @["en", "true"], @[nil, "true"], @["es", "false"], @["de", "false"], @["zh_TW", "false"], @["zh", "true"]]
    ACCEPT_LANGUAGE_HTTP: seq[string] = @["mt-mt, ja;q=0.76, en-us;q=0.95, en;q=0.92, en-gb;q=0.89, fr;q=0.87, iu-ca;q=0.84, iu;q=0.82, ja-jp;q=0.79, mt;q=0.97, de-de;q=0.74, de;q=0.71, es;q=0.68, it-it;q=0.66, it;q=0.63, vi-vn;q=0.61, vi;q=0.58, nl-nl;q=0.55, nl;q=0.53, th-th-traditional;q=.01", "ja;q=0.5, en;q=0.8, tlh", "en-zzz, de-lx;q=0.8", "mga-ie;q=0.9, tlh", "xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, " + "xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, " + "xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, " + "xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, " + "xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, " + "xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, " + "xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, " + "xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, " + "xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, " + "xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, xxx-yyy;q=.01, " + "es", "de;q=.9, fr;q=.9, xxx-yyy, sr;q=.8", "zh-tw", "zh-hant-cn"]

proc TestSetULocaleKeywords*() =
    var uloc: UCultureInfo = UCultureInfo("en_Latn_US")
    uloc = uloc.SetKeywordValue("Foo", "FooValue")
    if !"en_Latn_US@foo=FooValue".Equals(uloc.FullName):
Errln("failed to add foo keyword, got: " + uloc.FullName)
    uloc = uloc.SetKeywordValue("Bar", "BarValue")
    if !"en_Latn_US@bar=BarValue;foo=FooValue".Equals(uloc.FullName):
Errln("failed to add bar keyword, got: " + uloc.FullName)
    uloc = uloc.SetKeywordValue("BAR", "NewBarValue")
    if !"en_Latn_US@bar=NewBarValue;foo=FooValue".Equals(uloc.FullName):
Errln("failed to change bar keyword, got: " + uloc.FullName)
    uloc = uloc.SetKeywordValue("BaR", nil)
    if !"en_Latn_US@foo=FooValue".Equals(uloc.FullName):
Errln("failed to delete bar keyword, got: " + uloc.FullName)
    uloc = uloc.SetKeywordValue(nil, nil)
    if !"en_Latn_US".Equals(uloc.FullName):
Errln("failed to delete all keywords, got: " + uloc.FullName)
proc loccmp(str: String, prefix: String): int =
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
proc checklocs(label: String, req: String, validLoc: CultureInfo, actualLoc: CultureInfo, expReqValid: String, expValidActual: String) =
    var valid: String = validLoc.ToString
    var actual: String = actualLoc.ToString
    var reqValid: int = loccmp(req, valid)
    var validActual: int = loccmp(valid, actual)
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
type
  IServiceFacade = object

type
  ISubObject = object

type
  IRegistrar = object

proc checkObject(requestedLocale: String, obj: Object, expReqValid: String, expValidActual: String) =
    try:
        var cls: Type = obj.GetType
        var validProperty: PropertyInfo = cls.GetProperty("ValidCulture")
        var valid: UCultureInfo = cast[UCultureInfo](validProperty.GetValue(obj, seq[object]))
        var actualProperty: PropertyInfo = cls.GetProperty("ActualCulture")
        var actual: UCultureInfo = cast[UCultureInfo](actualProperty.GetValue(obj, seq[object]))
checklocs(cls.Name, requestedLocale, valid.ToCultureInfo, actual.ToCultureInfo, expReqValid, expValidActual)
    except MissingMethodException:

    except MethodAccessException:
Errln("FAIL: reflection failed: " + e2)
    except InvalidOperationException:
Errln("FAIL: reflection failed: " + e3)
    except ArgumentException:
Errln("FAIL: reflection failed: " + e4)
    except TargetInvocationException:

proc checkService(requestedLocale: String, svc: IServiceFacade) =
checkService(requestedLocale, svc, nil, nil)
proc checkService(requestedLocale: String, svc: IServiceFacade, sub: ISubObject, reg: IRegistrar) =
    var req: UCultureInfo = UCultureInfo(requestedLocale)
    var obj: Object = svc.Create(req)
checkObject(requestedLocale, obj, "gt", "ge")
    if sub != nil:
        var subobj: Object = sub.Get(obj)
checkObject(requestedLocale, subobj, "gt", "ge")
    if reg != nil:
Logln("Info: Registering service")
        var key: Object = reg.Register(req, obj)
        var objReg: Object = svc.Create(req)
checkObject(requestedLocale, objReg, "eq", "eq")
        if sub != nil:
            var subobj: Object = sub.Get(obj)
checkObject(requestedLocale, subobj, "gt", "ge")
Logln("Info: Unregistering service")
        if !reg.Unregister(key):
Errln("FAIL: unregister failed")
        var objUnreg: Object = svc.Create(req)
checkObject(requestedLocale, objUnreg, "gt", "ge")
proc TestBasicGetters*() =
    var i: int
Logln("Testing Basic Getters
")
      i = 0
      while i < LOCALE_SIZE:
          var testLocale: String = rawData2[NAME][i]
Logln("Testing " + testLocale + ".....
")
          var lang: String = UCultureInfo.GetLanguage(testLocale)
          if 0 != lang.CompareToOrdinal(rawData2[LANG][i]):
Errln("  Language code mismatch: " + lang + " versus " + rawData2[LANG][i])
          var ctry: String = UCultureInfo.GetCountry(testLocale)
          if 0 != ctry.CompareToOrdinal(rawData2[CTRY][i]):
Errln("  Country code mismatch: " + ctry + " versus " + rawData2[CTRY][i])
          var var: String = UCultureInfo.GetVariant(testLocale)
          if 0 != var.CompareToOrdinal(rawData2[VAR][i]):
Errln("  Variant code mismatch: " + var + " versus " + rawData2[VAR][i])
          var name: String = UCultureInfo.GetFullName(testLocale)
          if 0 != name.CompareToOrdinal(rawData2[NAME][i]):
Errln("  Name mismatch: " + name + " versus " + rawData2[NAME][i])
++i
proc TestPrefixes*() =
    var testData: string[][] = @[@["sv", "", "FI", "AL", "sv-fi-al", "sv_FI_AL", nil], @["en", "", "GB", "", "en-gb", "en_GB", nil], @["i-hakka", "", "MT", "XEMXIJA", "i-hakka_MT_XEMXIJA", "i-hakka_MT_XEMXIJA", nil], @["i-hakka", "", "CN", "", "i-hakka_CN", "i-hakka_CN", nil], @["i-hakka", "", "MX", "", "I-hakka_MX", "i-hakka_MX", nil], @["x-klingon", "", "US", "SANJOSE", "X-KLINGON_us_SANJOSE", "x-klingon_US_SANJOSE", nil], @["de", "", "", "1901", "de-1901", "de__1901", nil], @["mr", "", "", "", "mr.utf8", "mr.utf8", "mr"], @["de", "", "TV", "", "de-tv.koi8r", "de_TV.koi8r", "de_TV"], @["x-piglatin", "", "ML", "", "x-piglatin_ML.MBE", "x-piglatin_ML.MBE", "x-piglatin_ML"], @["i-cherokee", "", "US", "", "i-Cherokee_US.utf7", "i-cherokee_US.utf7", "i-cherokee_US"], @["x-filfli", "", "MT", "FILFLA", "x-filfli_MT_FILFLA.gb-18030", "x-filfli_MT_FILFLA.gb-18030", "x-filfli_MT_FILFLA"], @["no", "", "NO", "NY_B", "no-no-ny.utf32@B", "no_NO_NY.utf32@B", "no_NO_NY_B"], @["no", "", "NO", "B", "no-no.utf32@B", "no_NO.utf32@B", "no_NO_B"], @["no", "", "", "NY", "no__ny", "no__NY", nil], @["no", "", "", "NY", "no@ny", "no@ny", "no__NY"], @["el", "Latn", "", "", "el-latn", "el_Latn", nil], @["en", "Cyrl", "RU", "", "en-cyrl-ru", "en_Cyrl_RU", nil], @["zh", "Hant", "TW", "STROKE", "zh-hant_TW_STROKE", "zh_Hant_TW_STROKE", "zh_Hant_TW@collation=stroke"], @["zh", "Hant", "CN", "STROKE", "zh-hant_CN_STROKE", "zh_Hant_CN_STROKE", "zh_Hant_CN@collation=stroke"], @["zh", "Hant", "TW", "PINYIN", "zh-hant_TW_PINYIN", "zh_Hant_TW_PINYIN", "zh_Hant_TW@collation=pinyin"], @["qq", "Qqqq", "QQ", "QQ", "qq_Qqqq_QQ_QQ", "qq_Qqqq_QQ_QQ", nil], @["qq", "Qqqq", "", "QQ", "qq_Qqqq__QQ", "qq_Qqqq__QQ", nil], @["ab", "Cdef", "GH", "IJ", "ab_cdef_gh_ij", "ab_Cdef_GH_IJ", nil], @["", "", "", "", "@FOO=bar", "@foo=bar", nil], @["", "", "", "", "_@FOO=bar", "@foo=bar", nil], @["", "", "", "", "__@FOO=bar", "@foo=bar", nil], @["", "", "", "FOO", "__foo@FOO=bar", "__FOO@foo=bar", nil]]
      var loc: string
      var buf: string
      var buf1: string
    var testTitles: string[] = @["UCultureInfo.Language", "UCultureInfo.Script", "UCultureInfo.Country", "UCultureInfo.Variant", "Name", "UCultureInfo.FullName", "Canonicalize()"]
    var uloc: UCultureInfo
      var row: int = 0
      while row < testData.Length:
          loc = testData[row][NAME]
Logln("Test #" + row + ": " + loc)
          uloc = UCultureInfo(loc)
            var n: int = 0
            while n <= NAME + 2:
                if n == NAME:
                  continue
                case n
                of LANG:
                    buf = UCultureInfo.GetLanguage(loc)
                    buf1 = uloc.Language
                    break
                of SCRIPT:
                    buf = UCultureInfo.GetScript(loc)
                    buf1 = uloc.Script
                    break
                of CTRY:
                    buf = UCultureInfo.GetCountry(loc)
                    buf1 = uloc.Country
                    break
                of VAR:
                    buf = UCultureInfo.GetVariant(loc)
                    buf1 = buf
                    break
                of NAME + 1:
                    buf = UCultureInfo.GetFullName(loc)
                    buf1 = uloc.FullName
                    break
                of NAME + 2:
                    buf = UCultureInfo.Canonicalize(loc)
                    buf1 = UCultureInfo.CreateCanonical(loc).FullName
                    break
                else:
                    buf = "**??"
                    buf1 = buf
                    break
Logln("#" + row + ": " + testTitles[n] + " on " + loc + ": -> [" + buf + "]")
                var expected: string = testData[row][n]
                if expected == nil && n == NAME + 2:
                    expected = testData[row][NAME + 1]
                if n == NAME + 1 && expected.IndexOf('.') != -1 || expected.IndexOf('@') != -1:
                    continue
                if buf.CompareToOrdinal(expected) != 0:
Errln("#" + row + ": " + testTitles[n] + " on " + loc + ": -> [" + buf + "] (expected '" + expected + "'!)")
                if buf1.CompareToOrdinal(expected) != 0:
Errln("#" + row + ": " + testTitles[n] + " on UCultureInfo object " + loc + ": -> [" + buf1 + "] (expected '" + expected + "'!)")
++n
++row
proc TestUldnWithGarbage*() =
    var ldn: CultureDisplayNames = CultureDisplayNames.GetInstance(CultureInfo("en-US"), DialectHandling.DialectNames)
    var badLocaleID: String = "english (United States) [w"
    var expectedResult: String = "english [united states] [w"
    var result: String = ldn.GetLocaleDisplayName(badLocaleID)
    if result.CompareToOrdinal(expectedResult) != 0:
Errln("FAIL: CultureDisplayNames.GetLocaleDisplayName(string) for bad locale ID "" + badLocaleID + "", expected "" + expectedResult + "", got "" + result + """)
    var badLocale: UCultureInfo = UCultureInfo(badLocaleID)
    result = ldn.GetLocaleDisplayName(badLocale)
    if result.CompareToOrdinal(expectedResult) != 0:
Errln("FAIL: CultureDisplayNames.GetLocaleDisplayName(UCultureInfo) for bad locale ID "" + badLocaleID + "", expected "" + expectedResult + "", got "" + result + """)
proc TestObsoleteNames*() =
    var tests: string[][] = @[@["eng_USA", "eng", "en", "USA", "US"], @["kok", "kok", "kok", "", ""], @["in", "ind", "in", "", ""], @["id", "ind", "id", "", ""], @["sh", "srp", "sh", "", ""], @["zz_CS", "", "zz", "SCG", "CS"], @["zz_FX", "", "zz", "FXX", "FX"], @["zz_RO", "", "zz", "ROU", "RO"], @["zz_TP", "", "zz", "TMP", "TP"], @["zz_TL", "", "zz", "TLS", "TL"], @["zz_ZR", "", "zz", "ZAR", "ZR"], @["zz_FXX", "", "zz", "FXX", "FX"], @["zz_ROM", "", "zz", "ROU", "RO"], @["zz_ROU", "", "zz", "ROU", "RO"], @["zz_ZAR", "", "zz", "ZAR", "ZR"], @["zz_TMP", "", "zz", "TMP", "TP"], @["zz_TLS", "", "zz", "TLS", "TL"], @["zz_YUG", "", "zz", "YUG", "YU"], @["mlt_PSE", "mlt", "mt", "PSE", "PS"], @["iw", "heb", "iw", "", ""], @["ji", "yid", "ji", "", ""], @["jw", "jaw", "jw", "", ""], @["sh", "srp", "sh", "", ""], @["", "", "", "", ""]]
      var i: int = 0
      while i < tests.Length:
          var locale: String = tests[i][0]
Logln("** Testing : " + locale)
            var buff: String
            var buff1: String
          var uloc: UCultureInfo = UCultureInfo(locale)
          buff = UCultureInfo.GetThreeLetterISOLanguageName(locale)
          if buff.CompareToOrdinal(tests[i][1]) != 0:
Errln("FAIL: UCultureInfo.GetThreeLetterISOLanguageName(" + locale + ")==" + buff + ",	 expected " + tests[i][1])
          else:
Logln("   UCultureInfo.GetThreeLetterISOLanguageName(" + locale + ")==" + buff)
          buff1 = uloc.ThreeLetterISOLanguageName
          if buff1.CompareToOrdinal(tests[i][1]) != 0:
Errln("FAIL: UCultureInfo.ThreeLetterISOLanguageName(" + locale + ")==" + buff + ",	 expected " + tests[i][1])
          else:
Logln("   UCultureInfo.ThreeLetterISOLanguageName(" + locale + ")==" + buff)
          buff = UCultureInfo.GetLanguage(locale)
          if buff.CompareToOrdinal(tests[i][2]) != 0:
Errln("FAIL: UCultureInfo.GetLanguage(" + locale + ")==" + buff + ",	 expected " + tests[i][2])
          else:
Logln("   UCultureInfo.GetLanguage(" + locale + ")==" + buff)
          buff = UCultureInfo.GetThreeLetterISOCountryName(locale)
          if buff.CompareToOrdinal(tests[i][3]) != 0:
Errln("FAIL: UCultureInfo.GetThreeLetterISOCountryName(" + locale + ")==" + buff + ",	 expected " + tests[i][3])
          else:
Logln("   UCultureInfo.GetThreeLetterISOCountryName(" + locale + ")==" + buff)
          buff1 = uloc.ThreeLetterISOCountryName
          if buff1.CompareToOrdinal(tests[i][3]) != 0:
Errln("FAIL: UCultureInfo.ThreeLetterISOCountryName (" + locale + ")==" + buff + ",	 expected " + tests[i][3])
          else:
Logln("   UCultureInfo.ThreeLetterISOCountryName (" + locale + ")==" + buff)
          buff = UCultureInfo.GetCountry(locale)
          if buff.CompareToOrdinal(tests[i][4]) != 0:
Errln("FAIL: UCultureInfo.GetCountry(" + locale + ")==" + buff + ",	 expected " + tests[i][4])
          else:
Logln("   UCultureInfo.GetCountry(" + locale + ")==" + buff)
++i
    if UCultureInfo.GetLanguage("iw_IL").CompareToOrdinal(UCultureInfo.GetLanguage("he_IL")) == 0:
Errln("he,iw UCultureInfo.GetLanguage mismatch")
    var buff2: String = UCultureInfo.GetLanguage("kok_IN")
    if buff2.CompareToOrdinal("kok") != 0:
Errln("UCultureInfo.GetLanguage("kok") failed. Expected: kok Got: " + buff2)
proc TestCanonicalization*() =
    var testCases: string[][] = @[@["ca_ES_PREEURO", "ca_ES_PREEURO", "ca_ES@currency=ESP"], @["de_AT_PREEURO", "de_AT_PREEURO", "de_AT@currency=ATS"], @["de_DE_PREEURO", "de_DE_PREEURO", "de_DE@currency=DEM"], @["de_LU_PREEURO", "de_LU_PREEURO", "de_LU@currency=EUR"], @["el_GR_PREEURO", "el_GR_PREEURO", "el_GR@currency=GRD"], @["en_BE_PREEURO", "en_BE_PREEURO", "en_BE@currency=BEF"], @["en_IE_PREEURO", "en_IE_PREEURO", "en_IE@currency=IEP"], @["es_ES_PREEURO", "es_ES_PREEURO", "es_ES@currency=ESP"], @["eu_ES_PREEURO", "eu_ES_PREEURO", "eu_ES@currency=ESP"], @["fi_FI_PREEURO", "fi_FI_PREEURO", "fi_FI@currency=FIM"], @["fr_BE_PREEURO", "fr_BE_PREEURO", "fr_BE@currency=BEF"], @["fr_FR_PREEURO", "fr_FR_PREEURO", "fr_FR@currency=FRF"], @["fr_LU_PREEURO", "fr_LU_PREEURO", "fr_LU@currency=LUF"], @["ga_IE_PREEURO", "ga_IE_PREEURO", "ga_IE@currency=IEP"], @["gl_ES_PREEURO", "gl_ES_PREEURO", "gl_ES@currency=ESP"], @["it_IT_PREEURO", "it_IT_PREEURO", "it_IT@currency=ITL"], @["nl_BE_PREEURO", "nl_BE_PREEURO", "nl_BE@currency=BEF"], @["nl_NL_PREEURO", "nl_NL_PREEURO", "nl_NL@currency=NLG"], @["pt_PT_PREEURO", "pt_PT_PREEURO", "pt_PT@currency=PTE"], @["de__PHONEBOOK", "de__PHONEBOOK", "de@collation=phonebook"], @["de_PHONEBOOK", "de__PHONEBOOK", "de@collation=phonebook"], @["en_GB_EURO", "en_GB_EURO", "en_GB@currency=EUR"], @["en_GB@EURO", nil, "en_GB@currency=EUR"], @["es__TRADITIONAL", "es__TRADITIONAL", "es@collation=traditional"], @["hi__DIRECT", "hi__DIRECT", "hi@collation=direct"], @["ja_JP_TRADITIONAL", "ja_JP_TRADITIONAL", "ja_JP@calendar=japanese"], @["th_TH_TRADITIONAL", "th_TH_TRADITIONAL", "th_TH@calendar=buddhist"], @["zh_TW_STROKE", "zh_TW_STROKE", "zh_TW@collation=stroke"], @["zh__PINYIN", "zh__PINYIN", "zh@collation=pinyin"], @["zh@collation=pinyin", "zh@collation=pinyin", "zh@collation=pinyin"], @["zh_CN@collation=pinyin", "zh_CN@collation=pinyin", "zh_CN@collation=pinyin"], @["zh_CN_CA@collation=pinyin", "zh_CN_CA@collation=pinyin", "zh_CN_CA@collation=pinyin"], @["en_US_POSIX", "en_US_POSIX", "en_US_POSIX"], @["hy_AM_REVISED", "hy_AM_REVISED", "hy_AM_REVISED"], @["no_NO_NY", "no_NO_NY", "no_NO_NY"], @["no@ny", nil, "no__NY"], @["no-no.utf32@B", nil, "no_NO_B"], @["qz-qz@Euro", nil, "qz_QZ@currency=EUR"], @["en-BOONT", "en__BOONT", "en__BOONT"], @["de-1901", "de__1901", "de__1901"], @["de-1906", "de__1906", "de__1906"], @["sr-SP-Cyrl", "sr_SP_CYRL", "sr_Cyrl_RS"], @["sr-SP-Latn", "sr_SP_LATN", "sr_Latn_RS"], @["sr_YU_CYRILLIC", "sr_YU_CYRILLIC", "sr_Cyrl_RS"], @["uz-UZ-Cyrl", "uz_UZ_CYRL", "uz_Cyrl_UZ"], @["uz-UZ-Latn", "uz_UZ_LATN", "uz_Latn_UZ"], @["zh-CHS", "zh_CHS", "zh_Hans"], @["zh-CHT", "zh_CHT", "zh_Hant"], @["mr.utf8", nil, "mr"], @["de-tv.koi8r", nil, "de_TV"], @["x-piglatin_ML.MBE", nil, "x-piglatin_ML"], @["i-cherokee_US.utf7", nil, "i-cherokee_US"], @["x-filfli_MT_FILFLA.gb-18030", nil, "x-filfli_MT_FILFLA"], @["no-no-ny.utf8@B", nil, "no_NO_NY_B"], @["en_Hant_IL_VALLEY_GIRL@currency=EUR;calendar=Japanese;", "en_Hant_IL_VALLEY_GIRL@calendar=Japanese;currency=EUR", "en_Hant_IL_VALLEY_GIRL@calendar=Japanese;currency=EUR"], @["en_Hant_IL_VALLEY_GIRL@calendar=Japanese;currency=EUR", "en_Hant_IL_VALLEY_GIRL@calendar=Japanese;currency=EUR", "en_Hant_IL_VALLEY_GIRL@calendar=Japanese;currency=EUR"], @["no-Hant-GB_NY@currency=$$$", "no_Hant_GB_NY@currency=$$$", "no_Hant_GB_NY@currency=$$$"], @["root@kw=foo", "root@kw=foo", "root@kw=foo"], @["@calendar=gregorian", "@calendar=gregorian", "@calendar=gregorian"]]
      var i: int = 0
      while i < testCases.Length:
          var testCase: String[] = testCases[i]
          var source: String = testCase[0]
          var level1Expected: String = testCase[1]
          var level2Expected: String = testCase[2]
          if level1Expected != nil:
              var level1: String = UCultureInfo.GetFullName(source)
              if !level1.Equals(level1Expected):
Errln("UCultureInfo.GetFullName error for: '" + source + "' expected: '" + level1Expected + "' but got: '" + level1 + "'")
              else:
Logln("UCultureInfo.GetFullName for: '" + source + "' returned: '" + level1 + "'")
          else:
Logln("UCultureInfo.GetFullName skipped: '" + source + "'")
          if level2Expected != nil:
              var level2: String = UCultureInfo.Canonicalize(source)
              if !level2.Equals(level2Expected):
Errln("UCultureInfo.Canonicalize error for: '" + source + "' expected: '" + level2Expected + "' but got: '" + level2 + "'")
              else:
Logln("UCultureInfo.Canonicalize for: '" + source + "' returned: '" + level2 + "'")
          else:
Logln("UCultureInfo.Canonicalize skipped: '" + source + "'")
++i
proc TestGetAvailable*() =
    var locales: UCultureInfo[] = UCultureInfo.GetCultures(UCultureTypes.AllCultures)
    if locales.Length < 10:
Errln("Did not get the correct result from getAvailableLocales")
    if !locales[locales.Length - 1].FullName.Equals("zu_ZA"):
Errln("Did not get the expected result")
    for specificCulture in UCultureInfo.GetCultures(UCultureTypes.SpecificCultures):
assertFalse("Expected a specific culture, got '" & $specificCulture.Name & "'", specificCulture.IsNeutralCulture)
    for neutralCulture in UCultureInfo.GetCultures(UCultureTypes.NeutralCultures):
assertTrue("Expected a neutral culture, got '" & $neutralCulture.Name & "'", neutralCulture.IsNeutralCulture)
type
  DisplayNamesItem = ref object
    displayLocale: string
    dialectHandling: DialectHandling
    capitalization: Capitalization
    nameLength: DisplayLength
    substituteHandling: SubstituteHandling
    localeToBeNamed: String
    result: String

proc newDisplayNamesItem(dLoc: String, dia: DialectHandling, cap: Capitalization, nameLen: DisplayLength, sub: SubstituteHandling, locToName: String, res: String): DisplayNamesItem =
  displayLocale = dLoc
  dialectHandling = dia
  capitalization = cap
  nameLength = nameLen
  substituteHandling = sub
  localeToBeNamed = locToName
  result = res
proc TestDisplayNames*() =
      var locales: UCultureInfo[] = UCultureInfo.GetCultures(UCultureTypes.AllCultures)
        var i: int = 0
        while i < locales.Length:
            var l: UCultureInfo = locales[i]
            var name: String = l.DisplayName
Logln($l.ToString & " --> " & $name & ", " & $l.GetDisplayName(UCultureInfo("de")) & ", " & $l.GetDisplayName(UCultureInfo("fr_FR")))
            var language: String = l.DisplayLanguage
            var script: String = l.DisplayScriptInContext
            var country: String = l.DisplayCountry
            var variant: String = l.DisplayVariant
checkName(name, language, script, country, variant, UCultureInfo.CurrentCulture)
              var j: int = 0
              while j < locales.Length:
                  var dl: UCultureInfo = locales[j]
                  name = l.GetDisplayName(dl)
                  language = l.GetDisplayLanguage(dl)
                  script = l.GetDisplayScriptInContext(dl)
                  country = l.GetDisplayCountry(dl)
                  variant = l.GetDisplayVariant(dl)
                  if !checkName(name, language, script, country, variant, dl):
                      break
++j
++i
      var locales: UCultureInfo[] = @[UCultureInfo("en_US"), UCultureInfo("de_DE"), UCultureInfo("fr_FR")]
      var names: String[] = @["Chinese (China)", "Chinesisch (China)", "chinois (Chine)"]
      var names2: String[] = @["Simplified Chinese (China)", "Chinesisch (vereinfacht) (China)", "chinois simplifié (Chine)"]
      var locale: UCultureInfo = UCultureInfo("zh_CN")
      var locale2: UCultureInfo = UCultureInfo("zh_Hans_CN")
        var i: int = 0
        while i < locales.Length:
            var name: String = locale.GetDisplayName(locales[i])
            if !names[i].Equals(name):
Errln("expected '" + names[i] + "' but got '" + name + "'")
++i
        var i: int = 0
        while i < locales.Length:
            var name: String = locale2.GetDisplayNameWithDialect(locales[i])
            if !names2[i].Equals(name):
Errln("expected '" + names2[i] + "' but got '" + name + "'")
++i
      var NM_STD: DialectHandling = DialectHandling.StandardNames
      var NM_DIA: DialectHandling = DialectHandling.DialectNames
      var CAP_BEG: Capitalization = Capitalization.ForBeginningOfSentence
      var CAP_MID: Capitalization = Capitalization.ForMiddleOfSentence
      var CAP_UIL: Capitalization = Capitalization.ForUIListOrMenu
      var CAP_STA: Capitalization = Capitalization.ForStandalone
      var CAP_NON: Capitalization = Capitalization.None
      var LEN_FU: DisplayLength = DisplayLength.Full
      var LEN_SH: DisplayLength = DisplayLength.Short
      var SUB_SU: SubstituteHandling = SubstituteHandling.Substitute
      var SUB_NO: SubstituteHandling = SubstituteHandling.NoSubstitute
      var items: DisplayNamesItem[] = @[DisplayNamesItem("da", NM_STD, CAP_MID, LEN_FU, SUB_SU, "en", "engelsk"), DisplayNamesItem("da", NM_STD, CAP_BEG, LEN_FU, SUB_SU, "en", "Engelsk"), DisplayNamesItem("da", NM_STD, CAP_UIL, LEN_FU, SUB_SU, "en", "Engelsk"), DisplayNamesItem("da", NM_STD, CAP_STA, LEN_FU, SUB_SU, "en", "engelsk"), DisplayNamesItem("da", NM_STD, CAP_MID, LEN_FU, SUB_SU, "en@calendar=buddhist", "engelsk (buddhistisk kalender)"), DisplayNamesItem("da", NM_STD, CAP_BEG, LEN_FU, SUB_SU, "en@calendar=buddhist", "Engelsk (buddhistisk kalender)"), DisplayNamesItem("da", NM_STD, CAP_UIL, LEN_FU, SUB_SU, "en@calendar=buddhist", "Engelsk (buddhistisk kalender)"), DisplayNamesItem("da", NM_STD, CAP_STA, LEN_FU, SUB_SU, "en@calendar=buddhist", "engelsk (buddhistisk kalender)"), DisplayNamesItem("da", NM_STD, CAP_MID, LEN_FU, SUB_SU, "en_GB", "engelsk (Storbritannien)"), DisplayNamesItem("da", NM_STD, CAP_BEG, LEN_FU, SUB_SU, "en_GB", "Engelsk (Storbritannien)"), DisplayNamesItem("da", NM_STD, CAP_UIL, LEN_FU, SUB_SU, "en_GB", "Engelsk (Storbritannien)"), DisplayNamesItem("da", NM_STD, CAP_STA, LEN_FU, SUB_SU, "en_GB", "engelsk (Storbritannien)"), DisplayNamesItem("da", NM_STD, CAP_MID, LEN_SH, SUB_SU, "en_GB", "engelsk (UK)"), DisplayNamesItem("da", NM_STD, CAP_BEG, LEN_SH, SUB_SU, "en_GB", "Engelsk (UK)"), DisplayNamesItem("da", NM_STD, CAP_UIL, LEN_SH, SUB_SU, "en_GB", "Engelsk (UK)"), DisplayNamesItem("da", NM_STD, CAP_STA, LEN_SH, SUB_SU, "en_GB", "engelsk (UK)"), DisplayNamesItem("da", NM_DIA, CAP_MID, LEN_FU, SUB_SU, "en_GB", "britisk engelsk"), DisplayNamesItem("da", NM_DIA, CAP_BEG, LEN_FU, SUB_SU, "en_GB", "Britisk engelsk"), DisplayNamesItem("da", NM_DIA, CAP_UIL, LEN_FU, SUB_SU, "en_GB", "Britisk engelsk"), DisplayNamesItem("da", NM_DIA, CAP_STA, LEN_FU, SUB_SU, "en_GB", "britisk engelsk"), DisplayNamesItem("es", NM_STD, CAP_MID, LEN_FU, SUB_SU, "en", "inglés"), DisplayNamesItem("es", NM_STD, CAP_BEG, LEN_FU, SUB_SU, "en", "Inglés"), DisplayNamesItem("es", NM_STD, CAP_UIL, LEN_FU, SUB_SU, "en", "Inglés"), DisplayNamesItem("es", NM_STD, CAP_STA, LEN_FU, SUB_SU, "en", "Inglés"), DisplayNamesItem("es", NM_STD, CAP_MID, LEN_FU, SUB_SU, "en_GB", "inglés (Reino Unido)"), DisplayNamesItem("es", NM_STD, CAP_BEG, LEN_FU, SUB_SU, "en_GB", "Inglés (Reino Unido)"), DisplayNamesItem("es", NM_STD, CAP_UIL, LEN_FU, SUB_SU, "en_GB", "Inglés (Reino Unido)"), DisplayNamesItem("es", NM_STD, CAP_STA, LEN_FU, SUB_SU, "en_GB", "Inglés (Reino Unido)"), DisplayNamesItem("es", NM_STD, CAP_MID, LEN_SH, SUB_SU, "en_GB", "inglés (RU)"), DisplayNamesItem("es", NM_STD, CAP_BEG, LEN_SH, SUB_SU, "en_GB", "Inglés (RU)"), DisplayNamesItem("es", NM_STD, CAP_UIL, LEN_SH, SUB_SU, "en_GB", "Inglés (RU)"), DisplayNamesItem("es", NM_STD, CAP_STA, LEN_SH, SUB_SU, "en_GB", "Inglés (RU)"), DisplayNamesItem("es", NM_DIA, CAP_MID, LEN_FU, SUB_SU, "en_GB", "inglés británico"), DisplayNamesItem("es", NM_DIA, CAP_BEG, LEN_FU, SUB_SU, "en_GB", "Inglés británico"), DisplayNamesItem("es", NM_DIA, CAP_UIL, LEN_FU, SUB_SU, "en_GB", "Inglés británico"), DisplayNamesItem("es", NM_DIA, CAP_STA, LEN_FU, SUB_SU, "en_GB", "Inglés británico"), DisplayNamesItem("ru", NM_STD, CAP_MID, LEN_FU, SUB_SU, "uz_Latn", "узбекский (латиница)"), DisplayNamesItem("ru", NM_STD, CAP_BEG, LEN_FU, SUB_SU, "uz_Latn", "Узбекский (латиница)"), DisplayNamesItem("ru", NM_STD, CAP_UIL, LEN_FU, SUB_SU, "uz_Latn", "Узбекский (латиница)"), DisplayNamesItem("ru", NM_STD, CAP_STA, LEN_FU, SUB_SU, "uz_Latn", "Узбекский (латиница)"), DisplayNamesItem("en", NM_STD, CAP_MID, LEN_FU, SUB_SU, "ur@numbers=latn", "Urdu (Western Digits)"), DisplayNamesItem("en", NM_STD, CAP_MID, LEN_FU, SUB_SU, "ur@numbers=arabext", "Urdu (Extended Arabic-Indic Digits)"), DisplayNamesItem("en", NM_STD, CAP_MID, LEN_SH, SUB_SU, "ur@numbers=arabext", "Urdu (X Arabic-Indic Digits)"), DisplayNamesItem("af", NM_STD, CAP_NON, LEN_FU, SUB_NO, "aa", "Afar"), DisplayNamesItem("cs", NM_STD, CAP_NON, LEN_FU, SUB_NO, "vai", "vai")]
      for item in items:
          var locale: UCultureInfo = UCultureInfo(item.displayLocale)
          var ldn: CultureDisplayNames = CultureDisplayNames.GetInstance(locale, DisplayContextOptions)
          var dialectHandling: DialectHandling = ldn.DisplayContextOptions.DialectHandling
assertEquals("consistent dialect handling", dialectHandling == DialectHandling.DialectNames, ldn.DisplayContextOptions.DialectHandling == DialectHandling.DialectNames)
          var capitalization: Capitalization = ldn.DisplayContextOptions.Capitalization
          var nameLength: DisplayLength = ldn.DisplayContextOptions.DisplayLength
          var substituteHandling: SubstituteHandling = ldn.DisplayContextOptions.SubstituteHandling
          if dialectHandling != item.dialectHandling || capitalization != item.capitalization || nameLength != item.nameLength || substituteHandling != item.substituteHandling:
Errln("FAIL: displayLoc: " + item.displayLocale + ", dialectNam?: " + item.dialectHandling + ", capitalize: " + item.capitalization + ", nameLen: " + item.nameLength + ", substituteHandling: " + item.substituteHandling + ", locToName: " + item.localeToBeNamed + ", => read back dialectNam?: " + dialectHandling + ", capitalize: " + capitalization + ", nameLen: " + nameLength + ", substituteHandling: " + substituteHandling)
          else:
              var result: String = ldn.GetLocaleDisplayName(item.localeToBeNamed)
              if !item.result == nil && result == nil && !result != nil && result.Equals(item.result):
Errln("FAIL: displayLoc: " + item.displayLocale + ", dialectNam?: " + item.dialectHandling + ", capitalize: " + item.capitalization + ", nameLen: " + item.nameLength + ", substituteHandling: " + item.substituteHandling + ", locToName: " + item.localeToBeNamed + ", => expected result: " + item.result + ", got: " + result)
proc TestDisplayLanguageWithDialectCoverage*() =
assertFalse("en in system default locale: anything but empty", UCultureInfo("en").GetDisplayLanguageWithDialect == string.Empty)
assertEquals("en in de", "Englisch", UCultureInfo("en").GetDisplayLanguageWithDialect(UCultureInfo("de")))
assertEquals("en (string) in de", "Englisch", UCultureInfo.GetDisplayLanguageWithDialect("en", UCultureInfo("de")))
assertEquals("en (string) in de (string)", "Englisch", UCultureInfo.GetDisplayLanguageWithDialect("en", "de"))
proc TestDisplayNameWithDialectCoverage*() =
assertFalse("en-GB in system default locale: anything but empty", UCultureInfo("en_GB").DisplayNameWithDialect == string.Empty)
assertEquals("en-GB in de", "Britisches Englisch", UCultureInfo("en_GB").GetDisplayNameWithDialect(UCultureInfo("de")))
assertEquals("en-GB (string) in de", "Britisches Englisch", UCultureInfo.GetDisplayNameWithDialect("en-GB", UCultureInfo("de")))
assertEquals("en-GB (string) in de (string)", "Britisches Englisch", UCultureInfo.GetDisplayNameWithDialect("en-GB", "de"))
proc TestDisplayScriptCoverage*() =
assertFalse("zh-Hans in system default locale: anything but empty", UCultureInfo("zh_Hans").DisplayScript == string.Empty)
assertEquals("zh-Hans in de", "Vereinfachtes Chinesisch", UCultureInfo("zh_Hans").GetDisplayScript(UCultureInfo("de")))
assertEquals("zh-Hans (string) in de", "Vereinfachtes Chinesisch", UCultureInfo.GetDisplayScript("zh-Hans", UCultureInfo("de")))
assertEquals("zh-Hans (string) in de (string)", "Vereinfachtes Chinesisch", UCultureInfo.GetDisplayScript("zh-Hans", "de"))
proc checkName(name: String, language: String, script: String, country: String, variant: String, dl: UCultureInfo): bool =
    if !checkInclusion(dl, name, language, "language"):
        return false
    if !checkInclusion(dl, name, script, "script"):
        return false
    if !checkInclusion(dl, name, country, "country"):
        return false
    if !checkInclusion(dl, name, variant, "variant"):
        return false
    return true
proc checkInclusion(dl: UCultureInfo, name: String, substring: String, substringName: String): bool =
    if substring.Length > 0 && name.IndexOf(substring, StringComparison.Ordinal) == -1:
        var country2: String = substring.Replace('(', '[').Replace(')', ']').Replace('�', '�').Replace('�', '�')
        if name.IndexOf(country2, StringComparison.Ordinal) == -1:
Errln("loc: " + dl + " name '" + name + "' does not contain " + substringName + " '" + substring + "'")
            return false
    return true
proc TestCoverage*() =
        var i: int
        var j: int
      var localeID: String = "zh_CN"
        var name: String
        var language: String
        var script: String
        var country: String
        var variant: String
Logln("Covering APIs with signature displayXXX(String, String)")
        i = 0
        while i < LOCALE_SIZE:
            var testLocale: String = rawData2[NAME][i]
Logln("Testing " + testLocale + ".....")
            name = UCultureInfo.GetDisplayName(localeID, testLocale)
            language = UCultureInfo.GetDisplayLanguage(localeID, testLocale)
            script = UCultureInfo.GetDisplayScriptInContext(localeID, testLocale)
            country = UCultureInfo.GetDisplayCountry(localeID, testLocale)
            variant = UCultureInfo.GetDisplayVariant(localeID, testLocale)
            if !checkName(name, language, script, country, variant, UCultureInfo(testLocale)):
                break
++i
Logln("Covering APIs with signature displayXXX(String, UCultureInfo)
")
        j = 0
        while j < LOCALE_SIZE:
            var testLocale: String = rawData2[NAME][j]
            var loc: UCultureInfo = UCultureInfo(testLocale)
Logln("Testing " + testLocale + ".....")
            name = UCultureInfo.GetDisplayName(localeID, loc)
            language = UCultureInfo.GetDisplayLanguage(localeID, loc)
            script = UCultureInfo.GetDisplayScriptInContext(localeID, loc)
            country = UCultureInfo.GetDisplayCountry(localeID, loc)
            variant = UCultureInfo.GetDisplayVariant(localeID, loc)
            if !checkName(name, language, script, country, variant, loc):
                break
++j
    var loc3: UCultureInfo = UCultureInfo("en_US")
    var loc5: UCultureInfo = cast[UCultureInfo](loc3.Clone)
    if !loc5.Equals(loc3):
Errln("ULocale.clone should get the same UCultureInfo")
UCultureInfo.GetISOCountries
proc TestBamBm*() =
    var isoLanguages: String[] = UCultureInfo.GetISOLanguages
      var i: int = 0
      while i < isoLanguages.Length:
          if "bam".Equals(isoLanguages[i]):
Errln("found bam")
          if i > 0 && isoLanguages[i].CompareToOrdinal(isoLanguages[i - 1]) <= 0:
Errln("language list out of order: '" + isoLanguages[i] + " <= " + isoLanguages[i - 1])
++i
proc TestDisplayKeyword*() =
initHashtable
    var data: string[] = @["en_US@collation=phonebook;calendar=islamic-civil", "zh_Hans@collation=pinyin;calendar=chinese", "foo_Bar_BAZ@collation=traditional;calendar=buddhist"]
      var i: int = 0
      while i < data.Length:
          var localeID: string = data[i]
Logln("")
Logln("Testing locale " + localeID + " ...")
          var loc: UCultureInfo = UCultureInfo(localeID)
          var it = loc.Keywords.GetEnumerator
          var it2 = UCultureInfo.GetKeywords(localeID).GetEnumerator
          while it.MoveNext:
              var key: string = cast[string](it.Current.Key)
it2.MoveNext
              var key2: string = cast[string](it2.Current.Key)
              if !key.Equals(key2):
Errln("FAIL: static and non-static getKeywords returned different results.")
              var s0: string = UCultureInfo.GetDisplayKeyword(key)
              var s1: string = UCultureInfo.GetDisplayKeyword(key, UCultureInfo("en_US"))
              var s2: string = UCultureInfo.GetDisplayKeyword(key, "en_US")
              if !s1.Equals(s2):
Errln("FAIL: one of the getDisplayKeyword methods failed.")
              if UCultureInfo.CurrentUICulture.Equals(UCultureInfo("en-US")) && !s1.Equals(s0):
Errln("FAIL: getDisplayKeyword methods failed for the default locale.")
              if !s1.Equals(h[0].Get(key)):
Errln("Locale " + localeID + " getDisplayKeyword for key: " + key + " in English expected "" + h[0].Get(key) + "" saw "" + s1 + "" instead")
              else:
Logln("OK: getDisplayKeyword for key: " + key + " in English got " + s1)
              s1 = UCultureInfo.GetDisplayKeyword(key, UCultureInfo("zh_Hans_CN"))
              s2 = UCultureInfo.GetDisplayKeyword(key, "zh_Hans")
              if !s1.Equals(s2):
Errln("one of the getDisplayKeyword methods failed.")
              if !s1.Equals(h[1].Get(key)):
Errln("Locale " + localeID + " getDisplayKeyword for key: " + key + " in Chinese expected "" + h[1].Get(key) + "" saw "" + s1 + "" instead")
              else:
Logln("OK: getDisplayKeyword for key: " + key + " in Chinese got " + s1)
loc.Keywords.TryGetValue(key,               var type: string)
              var ss0: string = loc.GetDisplayKeywordValue(key)
              var ss1: string = loc.GetDisplayKeywordValue(key, UCultureInfo("en_US"))
              var ss2: string = UCultureInfo.GetDisplayKeywordValue(localeID, key, "en_US")
              var ss3: string = UCultureInfo.GetDisplayKeywordValue(localeID, key, UCultureInfo("en_US"))
              if !ss1.Equals(ss2) || !ss1.Equals(ss3):
Errln("FAIL: one of the getDisplayKeywordValue methods failed.")
              if UCultureInfo.CurrentUICulture.Equals(UCultureInfo("en_US")) && !ss1.Equals(ss0):
Errln("FAIL: getDisplayKeyword methods failed for the default locale.")
              if !ss1.Equals(h[0].Get(type)):
Errln(" Locale " + localeID + " getDisplayKeywordValue for key: " + key + " in English expected "" + h[0].Get(type) + "" saw "" + ss1 + "" instead")
              else:
Logln("OK: getDisplayKeywordValue for key: " + key + " in English got " + ss1)
              ss0 = loc.GetDisplayKeywordValue(key)
              ss1 = loc.GetDisplayKeywordValue(key, UCultureInfo("zh_Hans_CN"))
              ss2 = UCultureInfo.GetDisplayKeywordValue(localeID, key, "zh_Hans")
              ss3 = UCultureInfo.GetDisplayKeywordValue(localeID, key, UCultureInfo("zh_Hans_CN"))
              if !ss1.Equals(ss2) || !ss1.Equals(ss3):
Errln("one of the getDisplayKeywordValue methods failed.")
              if !ss1.Equals(h[1].Get(type)):
Errln("Locale " + localeID + " getDisplayKeywordValue for key: " + key + " in Chinese expected "" + h[1].Get(type) + "" saw "" + ss1 + "" instead")
              else:
Logln("OK: getDisplayKeywordValue for key: " + key + " in Chinese got " + ss1)
++i
proc TestDisplayWithKeyword*() =
    var dn: CultureDisplayNames = CultureDisplayNames.GetInstance(UCultureInfo("en_US"), DialectHandling.DialectNames)
    var tdn: CultureDisplayNames = CultureDisplayNames.GetInstance(UCultureInfo("zh_Hant_TW"), DialectHandling.DialectNames)
    var name: String = dn.GetLocaleDisplayName("de@collation=phonebook")
    var target: String = "German (Phonebook Sort Order)"
assertEquals("collation", target, name)
    name = tdn.GetLocaleDisplayName("de@collation=phonebook")
    target = "德文（電話簿排序）"
assertEquals("collation", target, name)
    name = dn.GetLocaleDisplayName("ja@currency=JPY")
    target = "Japanese (Japanese Yen)"
assertEquals("currency (JPY)", target, name)
    name = tdn.GetLocaleDisplayName("ja@currency=JPY")
    target = "日文（日圓）"
assertEquals("currency (JPY)", target, name)
    name = dn.GetLocaleDisplayName("de@currency=XYZ")
    target = "German (Currency: XYZ)"
assertEquals("currency (XYZ)", target, name)
    name = dn.GetLocaleDisplayName("de@collation=phonebook;currency=XYZ")
    target = "German (Phonebook Sort Order, Currency: XYZ)"
assertEquals("currency", target, name)
    name = dn.GetLocaleDisplayName("de_Latn_DE")
    target = "German (Latin, Germany)"
assertEquals("currency", target, name)
    name = tdn.GetLocaleDisplayName("de@currency=XYZ")
    target = "德文（貨幣：XYZ）"
assertEquals("currency", target, name)
    name = tdn.GetLocaleDisplayName("de@collation=phonebook;currency=XYZ")
    target = "德文（電話簿排序，貨幣：XYZ）"
assertEquals("collation", target, name)
    name = dn.GetLocaleDisplayName("de@foo=bar")
    target = "German (foo=bar)"
assertEquals("foo", target, name)
    name = tdn.GetLocaleDisplayName("de@foo=bar")
    target = "德文（foo=bar）"
assertEquals("foo", target, name)
    var locale: UCultureInfo = UCultureInfo.GetCultureInfoByIetfLanguageTag("de-x-foobar")
    name = dn.GetLocaleDisplayName(locale)
    target = "German (Private-Use: foobar)"
assertEquals("foobar", target, name)
    name = tdn.GetLocaleDisplayName(locale)
    target = "德文（私人使用：foobar）"
assertEquals("foobar", target, name)
proc initHashtable() =
    h[0] = Dictionary<String, String>
    h[1] = Dictionary<String, String>
    h[0]["collation"] = "Sort Order"
    h[0]["calendar"] = "Calendar"
    h[0]["currency"] = "Currency"
    h[0]["phonebook"] = "Phonebook Sort Order"
    h[0]["pinyin"] = "Pinyin Sort Order"
    h[0]["traditional"] = "Traditional Sort Order"
    h[0]["stroke"] = "Stroke Order"
    h[0]["japanese"] = "Japanese Calendar"
    h[0]["buddhist"] = "Buddhist Calendar"
    h[0]["islamic"] = "Islamic Calendar"
    h[0]["islamic-civil"] = "Islamic Calendar (tabular, civil epoch)"
    h[0]["hebrew"] = "Hebrew Calendar"
    h[0]["chinese"] = "Chinese Calendar"
    h[0]["gregorian"] = "Gregorian Calendar"
    h[1]["collation"] = "排序"
    h[1]["calendar"] = "日历"
    h[1]["currency"] = "货币"
    h[1]["phonebook"] = "电话簿排序"
    h[1]["pinyin"] = "拼音排序"
    h[1]["stroke"] = "笔划顺序"
    h[1]["traditional"] = "传统排序"
    h[1]["japanese"] = "日本日历"
    h[1]["buddhist"] = "佛历"
    h[1]["islamic"] = "伊斯兰日历"
    h[1]["islamic-civil"] = "伊斯兰希吉来日历"
    h[1]["hebrew"] = "希伯来日历"
    h[1]["chinese"] = "农历"
    h[1]["gregorian"] = "公历"
proc TestAcceptLanguage*() =
      var i: int = 0
      while i < ACCEPT_LANGUAGE_HTTP.Length:
          var expectBoolean: bool = bool.Parse(ACCEPT_LANGUAGE_TESTS[i][1])
          var expectLocale: String = ACCEPT_LANGUAGE_TESTS[i][0]
Logln("#" + i + ": expecting: " + expectLocale + " (" + expectBoolean + ")")
          var r: bool = false
          var n: UCultureInfo = UCultureInfo.AcceptLanguage(ACCEPT_LANGUAGE_HTTP[i], r)
          if n == nil && expectLocale != nil:
Errln("result was null! line #" + i)
              continue
          if n == nil && expectLocale == nil || n.ToString.Equals(expectLocale):
Logln(" locale: OK.")
          else:
Errln("expected " + expectLocale + " but got " + n.ToString)
          if expectBoolean.Equals(r):
Logln(" bool: OK.")
          else:
Errln("bool: not OK, was " + r.ToString + " expected " + expectBoolean.ToString)
++i
type
  ULocaleAcceptLanguageQ = ref object
    q: double
    serial: double

proc newULocaleAcceptLanguageQ(theq: double, theserial: int): ULocaleAcceptLanguageQ =
  q = theq
  serial = theserial
proc CompareTo*(o: Object): int =
    var other: ULocaleAcceptLanguageQ = cast[ULocaleAcceptLanguageQ](o)
    if q > other.q:
        return -1

    elif q < other.q:
        return 1
    if serial < other.serial:
        return -1

    elif serial > other.serial:
        return 1
    else:
        return 0
proc StringToULocaleArray(acceptLanguageList: String): UCultureInfo[] =
    var map: SortedDictionary<ULocaleAcceptLanguageQ, UCultureInfo> = SortedDictionary<ULocaleAcceptLanguageQ, UCultureInfo>
    var l: int = acceptLanguageList.Length
    var n: int
      n = 0
      while n < l:
          var itemEnd: int = acceptLanguageList.IndexOf(',', n)
          if itemEnd == -1:
              itemEnd = l
          var paramEnd: int = acceptLanguageList.IndexOf(';', n)
          var q: double = 1.0
          if paramEnd != -1 && paramEnd < itemEnd:
              var t: int = paramEnd + 1
              while UChar.IsWhiteSpace(acceptLanguageList[t]):
++t
              if acceptLanguageList[t] == 'q':
++t
              while UChar.IsWhiteSpace(acceptLanguageList[t]):
++t
              if acceptLanguageList[t] == '=':
++t
              while UChar.IsWhiteSpace(acceptLanguageList[t]):
++t
              try:
                  var val: String = acceptLanguageList.Substring(t, itemEnd - t).Trim
                  q = double.Parse(val, CultureInfo.InvariantCulture)
              except FormatException:
                  q = 1.0
          else:
              q = 1.0
              paramEnd = itemEnd
          var loc: String = acceptLanguageList.Substring(n, paramEnd - n).Trim
          var serial: int = map.Count
          var entry: ULocaleAcceptLanguageQ = ULocaleAcceptLanguageQ(q, serial)
          map[entry] = UCultureInfo(UCultureInfo.Canonicalize(loc))
          n = itemEnd
++n
    var acceptList: UCultureInfo[] = cast[UCultureInfo[]](map.Values.ToArray)
    return acceptList
proc TestAcceptLanguage2*() =
      var i: int = 0
      while i < ACCEPT_LANGUAGE_HTTP.Length:
          var expectBoolean: bool = bool.Parse(ACCEPT_LANGUAGE_TESTS[i][1])
          var expectLocale: String = ACCEPT_LANGUAGE_TESTS[i][0]
Logln("#" + i + ": expecting: " + expectLocale + " (" + expectBoolean + ")")
          var r: bool = false
          var n: UCultureInfo = UCultureInfo.AcceptLanguage(StringToULocaleArray(ACCEPT_LANGUAGE_HTTP[i]), r)
          if n == nil && expectLocale != nil:
Errln("result was null! line #" + i)
              continue
          if n == nil && expectLocale == nil || n.ToString.Equals(expectLocale):
Logln(" locale: OK.")
          else:
Errln("expected " + expectLocale + " but got " + n.ToString)
          if expectBoolean.Equals(r):
Logln(" bool: OK.")
          else:
Errln("bool: not OK, was " + r.ToString + " expected " + expectBoolean.ToString)
++i
proc TestAcceptLanguageWithNullParameters*() =
AssertThrows[ArgumentNullException](<unhandled: nnkLambda>)
AssertThrows[ArgumentNullException](<unhandled: nnkLambda>)
AssertThrows[ArgumentNullException](<unhandled: nnkLambda>)
AssertThrows[ArgumentNullException](<unhandled: nnkLambda>)
AssertThrows[ArgumentNullException](<unhandled: nnkLambda>)
AssertThrows[ArgumentNullException](<unhandled: nnkLambda>)
proc TestAcceptLanguageWithNullElementsWithinParameters*() =
AssertThrows[ArgumentException](<unhandled: nnkLambda>)
AssertThrows[ArgumentException](<unhandled: nnkLambda>)
AssertThrows[ArgumentException](<unhandled: nnkLambda>)
proc TestOrientation*() =
      var toTest: string[][] = @[@["ar", "right-to-left", "top-to-bottom"], @["ar_Arab", "right-to-left", "top-to-bottom"], @["fa", "right-to-left", "top-to-bottom"], @["he", "right-to-left", "top-to-bottom"], @["ps", "right-to-left", "top-to-bottom"], @["ur", "right-to-left", "top-to-bottom"], @["en", "left-to-right", "top-to-bottom"]]
        var i: int = 0
        while i < toTest.Length:
            var loc: UCultureInfo = UCultureInfo(toTest[i][0])
            var co: String = loc.CharacterOrientation
            var lo: String = loc.LineOrientation
            if !co.Equals(toTest[i][1]):
Errln("Locale "" + toTest[i][0] + "" should have "" + toTest[i][1] + "" character orientation, but got '" + co + """)

            elif !lo.Equals(toTest[i][2]):
Errln("Locale "" + toTest[i][0] + "" should have "" + toTest[i][2] + "" line orientation, but got '" + lo + """)
++i
proc TestJB3962*() =
    var loc: UCultureInfo = UCultureInfo("de_CH")
    var disp: String = loc.GetDisplayName(UCultureInfo("de"))
    if !disp.Equals("Deutsch (Schweiz)"):
Errln("Did not get the expected display name for de_CH locale. Got: " + Prettify(disp))
proc TestMinimize*() =
    var data: string[][] = @[@["zh-Hans-CN", "zh", "zh"], @["zh-Hant-TW", "zh-TW", "zh-Hant"], @["zh-Hant-SG", "zh-Hant-SG", "zh-Hant-SG"], @["zh-Hans-SG", "zh-SG", "zh-SG"], @["zh-Hant-HK", "zh-HK", "zh-HK"], @["en_Latn_US", "en", "en"], @["en_Cyrl-US", "en-Cyrl", "en-Cyrl"], @["en_Cyrl-RU", "en-Cyrl-RU", "en-Cyrl-RU"], @["en_Latn-RU", "en-RU", "en-RU"], @["sr_Cyrl-US", "sr-US", "sr-US"], @["sr_Cyrl-RU", "sr-Cyrl-RU", "sr-Cyrl-RU"], @["sr_Latn-RU", "sr-RU", "sr-RU"]]
    for test in data:
        var source: UCultureInfo = UCultureInfo(test[0])
        var expectedFavorRegion: UCultureInfo = UCultureInfo(test[1])
        var expectedFavorScript: UCultureInfo = UCultureInfo(test[2])
assertEquals(string.Format(StringFormatter.CurrentCulture, "favor region:	{0}", cast[object](test)), expectedFavorRegion, UCultureInfo.MinimizeSubtags(source, UCultureInfo.Minimize.FavorRegion))
assertEquals(string.Format(StringFormatter.CurrentCulture, "favor script:	{0}", cast[object](test)), expectedFavorScript, UCultureInfo.MinimizeSubtags(source, UCultureInfo.Minimize.FavorScript))
proc TestAddLikelySubtags*() =
    var data: string[][] = @[@["en", "en_Latn_US"], @["en_US_BOSTON", "en_Latn_US_BOSTON"], @["th@calendar=buddhist", "th_Thai_TH@calendar=buddhist"], @["ar_ZZ", "ar_Arab_EG"], @["zh", "zh_Hans_CN"], @["zh_TW", "zh_Hant_TW"], @["zh_HK", "zh_Hant_HK"], @["zh_Hant", "zh_Hant_TW"], @["zh_Zzzz_CN", "zh_Hans_CN"], @["und_US", "en_Latn_US"], @["und_HK", "zh_Hant_HK"]]
      var i: int = 0
      while i < data.Length:
          var org: UCultureInfo = UCultureInfo(data[i][0])
          var res: UCultureInfo = UCultureInfo.AddLikelySubtags(org)
          if !res.ToString.Equals(data[i][1]):
Errln("Original: " + data[i][0] + " Expected: " + data[i][1] + " - but got " + res.ToString)
++i
    var basic_maximize_data: string[][] = @[@["zu_Zzzz_Zz", "zu_Latn_ZA"], @["zu_Zz", "zu_Latn_ZA"], @["en_Zz", "en_Latn_US"], @["en_Kore", "en_Kore_US"], @["en_Kore_Zz", "en_Kore_US"], @["en_Kore_ZA", "en_Kore_ZA"], @["en_Kore_ZA_POSIX", "en_Kore_ZA_POSIX"], @["en_Gujr", "en_Gujr_US"], @["en_ZA", "en_Latn_ZA"], @["en_Gujr_Zz", "en_Gujr_US"], @["en_Gujr_ZA", "en_Gujr_ZA"], @["en_Gujr_ZA_POSIX", "en_Gujr_ZA_POSIX"], @["en_US_POSIX_1901", "en_Latn_US_POSIX_1901"], @["en_Latn__POSIX_1901", "en_Latn_US_POSIX_1901"], @["en__POSIX_1901", "en_Latn_US_POSIX_1901"], @["de__POSIX_1901", "de_Latn_DE_POSIX_1901"], @["zzz", ""]]
      var i: int = 0
      while i < basic_maximize_data.Length:
          var org: UCultureInfo = UCultureInfo(basic_maximize_data[i][0])
          var res: UCultureInfo = UCultureInfo.AddLikelySubtags(org)
          var exp: String = basic_maximize_data[i][1]
          if exp.Length == 0:
              if !org.Equals(res):
Errln("Original: " + basic_maximize_data[i][0] + " expected: " + exp + " - but got " + res.ToString)

          elif !res.ToString.Equals(exp):
Errln("Original: " + basic_maximize_data[i][0] + " expected: " + exp + " - but got " + res.ToString)
++i
    var basic_minimize_data: string[][] = @[@["en_Latn_US", "en"], @["en_Latn_US_POSIX_1901", "en__POSIX_1901"], @["en_Zzzz_US_POSIX_1901", "en__POSIX_1901"], @["de_Latn_DE_POSIX_1901", "de__POSIX_1901"], @["und", ""]]
      var i: int = 0
      while i < basic_minimize_data.Length:
          var org: UCultureInfo = UCultureInfo(basic_minimize_data[i][0])
          var res: UCultureInfo = UCultureInfo.MinimizeSubtags(org)
          var exp: String = basic_minimize_data[i][1]
          if exp.Length == 0:
              if !org.Equals(res):
Errln("Original: " + basic_minimize_data[i][0] + " expected: " + exp + " - but got " + res.ToString)

          elif !res.ToString.Equals(exp):
Errln("Original: " + basic_minimize_data[i][0] + " expected: " + exp + " - but got " + res.ToString)
++i
    var full_data: string[][] = @[@["aa", "aa_Latn_ET", "aa"], @["af", "af_Latn_ZA", "af"], @["ak", "ak_Latn_GH", "ak"], @["am", "am_Ethi_ET", "am"], @["ar", "ar_Arab_EG", "ar"], @["as", "as_Beng_IN", "as"], @["az", "az_Latn_AZ", "az"], @["be", "be_Cyrl_BY", "be"], @["bg", "bg_Cyrl_BG", "bg"], @["bn", "bn_Beng_BD", "bn"], @["bo", "bo_Tibt_CN", "bo"], @["bs", "bs_Latn_BA", "bs"], @["ca", "ca_Latn_ES", "ca"], @["ch", "ch_Latn_GU", "ch"], @["chk", "chk_Latn_FM", "chk"], @["cs", "cs_Latn_CZ", "cs"], @["cy", "cy_Latn_GB", "cy"], @["da", "da_Latn_DK", "da"], @["de", "de_Latn_DE", "de"], @["dv", "dv_Thaa_MV", "dv"], @["dz", "dz_Tibt_BT", "dz"], @["ee", "ee_Latn_GH", "ee"], @["el", "el_Grek_GR", "el"], @["en", "en_Latn_US", "en"], @["es", "es_Latn_ES", "es"], @["et", "et_Latn_EE", "et"], @["eu", "eu_Latn_ES", "eu"], @["fa", "fa_Arab_IR", "fa"], @["fi", "fi_Latn_FI", "fi"], @["fil", "fil_Latn_PH", "fil"], @["fj", "fj_Latn_FJ", "fj"], @["fo", "fo_Latn_FO", "fo"], @["fr", "fr_Latn_FR", "fr"], @["fur", "fur_Latn_IT", "fur"], @["ga", "ga_Latn_IE", "ga"], @["gaa", "gaa_Latn_GH", "gaa"], @["gl", "gl_Latn_ES", "gl"], @["gn", "gn_Latn_PY", "gn"], @["gu", "gu_Gujr_IN", "gu"], @["ha", "ha_Latn_NG", "ha"], @["haw", "haw_Latn_US", "haw"], @["he", "he_Hebr_IL", "he"], @["hi", "hi_Deva_IN", "hi"], @["hr", "hr_Latn_HR", "hr"], @["ht", "ht_Latn_HT", "ht"], @["hu", "hu_Latn_HU", "hu"], @["hy", "hy_Armn_AM", "hy"], @["id", "id_Latn_ID", "id"], @["ig", "ig_Latn_NG", "ig"], @["ii", "ii_Yiii_CN", "ii"], @["is", "is_Latn_IS", "is"], @["it", "it_Latn_IT", "it"], @["ja", "ja_Jpan_JP", "ja"], @["ka", "ka_Geor_GE", "ka"], @["kaj", "kaj_Latn_NG", "kaj"], @["kam", "kam_Latn_KE", "kam"], @["kk", "kk_Cyrl_KZ", "kk"], @["kl", "kl_Latn_GL", "kl"], @["km", "km_Khmr_KH", "km"], @["kn", "kn_Knda_IN", "kn"], @["ko", "ko_Kore_KR", "ko"], @["kok", "kok_Deva_IN", "kok"], @["kpe", "kpe_Latn_LR", "kpe"], @["ku", "ku_Latn_TR", "ku"], @["ky", "ky_Cyrl_KG", "ky"], @["la", "la_Latn_VA", "la"], @["ln", "ln_Latn_CD", "ln"], @["lo", "lo_Laoo_LA", "lo"], @["lt", "lt_Latn_LT", "lt"], @["lv", "lv_Latn_LV", "lv"], @["mg", "mg_Latn_MG", "mg"], @["mh", "mh_Latn_MH", "mh"], @["mk", "mk_Cyrl_MK", "mk"], @["ml", "ml_Mlym_IN", "ml"], @["mn", "mn_Cyrl_MN", "mn"], @["mr", "mr_Deva_IN", "mr"], @["ms", "ms_Latn_MY", "ms"], @["mt", "mt_Latn_MT", "mt"], @["my", "my_Mymr_MM", "my"], @["na", "na_Latn_NR", "na"], @["ne", "ne_Deva_NP", "ne"], @["niu", "niu_Latn_NU", "niu"], @["nl", "nl_Latn_NL", "nl"], @["nn", "nn_Latn_NO", "nn"], @["nr", "nr_Latn_ZA", "nr"], @["nso", "nso_Latn_ZA", "nso"], @["om", "om_Latn_ET", "om"], @["or", "or_Orya_IN", "or"], @["pa", "pa_Guru_IN", "pa"], @["pa_Arab", "pa_Arab_PK", "pa_PK"], @["pa_PK", "pa_Arab_PK", "pa_PK"], @["pap", "pap_Latn_AW", "pap"], @["pau", "pau_Latn_PW", "pau"], @["pl", "pl_Latn_PL", "pl"], @["ps", "ps_Arab_AF", "ps"], @["pt", "pt_Latn_BR", "pt"], @["rn", "rn_Latn_BI", "rn"], @["ro", "ro_Latn_RO", "ro"], @["ru", "ru_Cyrl_RU", "ru"], @["rw", "rw_Latn_RW", "rw"], @["sa", "sa_Deva_IN", "sa"], @["se", "se_Latn_NO", "se"], @["sg", "sg_Latn_CF", "sg"], @["si", "si_Sinh_LK", "si"], @["sid", "sid_Latn_ET", "sid"], @["sk", "sk_Latn_SK", "sk"], @["sl", "sl_Latn_SI", "sl"], @["sm", "sm_Latn_WS", "sm"], @["so", "so_Latn_SO", "so"], @["sq", "sq_Latn_AL", "sq"], @["sr", "sr_Cyrl_RS", "sr"], @["ss", "ss_Latn_ZA", "ss"], @["st", "st_Latn_ZA", "st"], @["sv", "sv_Latn_SE", "sv"], @["sw", "sw_Latn_TZ", "sw"], @["ta", "ta_Taml_IN", "ta"], @["te", "te_Telu_IN", "te"], @["tet", "tet_Latn_TL", "tet"], @["tg", "tg_Cyrl_TJ", "tg"], @["th", "th_Thai_TH", "th"], @["ti", "ti_Ethi_ET", "ti"], @["tig", "tig_Ethi_ER", "tig"], @["tk", "tk_Latn_TM", "tk"], @["tkl", "tkl_Latn_TK", "tkl"], @["tn", "tn_Latn_ZA", "tn"], @["to", "to_Latn_TO", "to"], @["tpi", "tpi_Latn_PG", "tpi"], @["tr", "tr_Latn_TR", "tr"], @["ts", "ts_Latn_ZA", "ts"], @["tt", "tt_Cyrl_RU", "tt"], @["tvl", "tvl_Latn_TV", "tvl"], @["ty", "ty_Latn_PF", "ty"], @["uk", "uk_Cyrl_UA", "uk"], @["und", "en_Latn_US", "en"], @["und_AD", "ca_Latn_AD", "ca_AD"], @["und_AE", "ar_Arab_AE", "ar_AE"], @["und_AF", "fa_Arab_AF", "fa_AF"], @["und_AL", "sq_Latn_AL", "sq"], @["und_AM", "hy_Armn_AM", "hy"], @["und_AO", "pt_Latn_AO", "pt_AO"], @["und_AR", "es_Latn_AR", "es_AR"], @["und_AS", "sm_Latn_AS", "sm_AS"], @["und_AT", "de_Latn_AT", "de_AT"], @["und_AW", "nl_Latn_AW", "nl_AW"], @["und_AX", "sv_Latn_AX", "sv_AX"], @["und_AZ", "az_Latn_AZ", "az"], @["und_Arab", "ar_Arab_EG", "ar"], @["und_Arab_IN", "ur_Arab_IN", "ur_IN"], @["und_Arab_PK", "ur_Arab_PK", "ur"], @["und_Arab_SN", "ar_Arab_SN", "ar_SN"], @["und_Armn", "hy_Armn_AM", "hy"], @["und_BA", "bs_Latn_BA", "bs"], @["und_BD", "bn_Beng_BD", "bn"], @["und_BE", "nl_Latn_BE", "nl_BE"], @["und_BF", "fr_Latn_BF", "fr_BF"], @["und_BG", "bg_Cyrl_BG", "bg"], @["und_BH", "ar_Arab_BH", "ar_BH"], @["und_BI", "rn_Latn_BI", "rn"], @["und_BJ", "fr_Latn_BJ", "fr_BJ"], @["und_BN", "ms_Latn_BN", "ms_BN"], @["und_BO", "es_Latn_BO", "es_BO"], @["und_BR", "pt_Latn_BR", "pt"], @["und_BT", "dz_Tibt_BT", "dz"], @["und_BY", "be_Cyrl_BY", "be"], @["und_Beng", "bn_Beng_BD", "bn"], @["und_Beng_IN", "bn_Beng_IN", "bn_IN"], @["und_CD", "sw_Latn_CD", "sw_CD"], @["und_CF", "fr_Latn_CF", "fr_CF"], @["und_CG", "fr_Latn_CG", "fr_CG"], @["und_CH", "de_Latn_CH", "de_CH"], @["und_CI", "fr_Latn_CI", "fr_CI"], @["und_CL", "es_Latn_CL", "es_CL"], @["und_CM", "fr_Latn_CM", "fr_CM"], @["und_CN", "zh_Hans_CN", "zh"], @["und_CO", "es_Latn_CO", "es_CO"], @["und_CR", "es_Latn_CR", "es_CR"], @["und_CU", "es_Latn_CU", "es_CU"], @["und_CV", "pt_Latn_CV", "pt_CV"], @["und_CY", "el_Grek_CY", "el_CY"], @["und_CZ", "cs_Latn_CZ", "cs"], @["und_Cyrl", "ru_Cyrl_RU", "ru"], @["und_Cyrl_KZ", "ru_Cyrl_KZ", "ru_KZ"], @["und_DE", "de_Latn_DE", "de"], @["und_DJ", "aa_Latn_DJ", "aa_DJ"], @["und_DK", "da_Latn_DK", "da"], @["und_DO", "es_Latn_DO", "es_DO"], @["und_DZ", "ar_Arab_DZ", "ar_DZ"], @["und_Deva", "hi_Deva_IN", "hi"], @["und_EC", "es_Latn_EC", "es_EC"], @["und_EE", "et_Latn_EE", "et"], @["und_EG", "ar_Arab_EG", "ar"], @["und_EH", "ar_Arab_EH", "ar_EH"], @["und_ER", "ti_Ethi_ER", "ti_ER"], @["und_ES", "es_Latn_ES", "es"], @["und_ET", "am_Ethi_ET", "am"], @["und_Ethi", "am_Ethi_ET", "am"], @["und_Ethi_ER", "am_Ethi_ER", "am_ER"], @["und_FI", "fi_Latn_FI", "fi"], @["und_FM", "en_Latn_FM", "en_FM"], @["und_FO", "fo_Latn_FO", "fo"], @["und_FR", "fr_Latn_FR", "fr"], @["und_GA", "fr_Latn_GA", "fr_GA"], @["und_GE", "ka_Geor_GE", "ka"], @["und_GF", "fr_Latn_GF", "fr_GF"], @["und_GL", "kl_Latn_GL", "kl"], @["und_GN", "fr_Latn_GN", "fr_GN"], @["und_GP", "fr_Latn_GP", "fr_GP"], @["und_GQ", "es_Latn_GQ", "es_GQ"], @["und_GR", "el_Grek_GR", "el"], @["und_GT", "es_Latn_GT", "es_GT"], @["und_GU", "en_Latn_GU", "en_GU"], @["und_GW", "pt_Latn_GW", "pt_GW"], @["und_Geor", "ka_Geor_GE", "ka"], @["und_Grek", "el_Grek_GR", "el"], @["und_Gujr", "gu_Gujr_IN", "gu"], @["und_Guru", "pa_Guru_IN", "pa"], @["und_HK", "zh_Hant_HK", "zh_HK"], @["und_HN", "es_Latn_HN", "es_HN"], @["und_HR", "hr_Latn_HR", "hr"], @["und_HT", "ht_Latn_HT", "ht"], @["und_HU", "hu_Latn_HU", "hu"], @["und_Hani", "zh_Hani_CN", "zh_Hani"], @["und_Hans", "zh_Hans_CN", "zh"], @["und_Hant", "zh_Hant_TW", "zh_TW"], @["und_Hebr", "he_Hebr_IL", "he"], @["und_ID", "id_Latn_ID", "id"], @["und_IL", "he_Hebr_IL", "he"], @["und_IN", "hi_Deva_IN", "hi"], @["und_IQ", "ar_Arab_IQ", "ar_IQ"], @["und_IR", "fa_Arab_IR", "fa"], @["und_IS", "is_Latn_IS", "is"], @["und_IT", "it_Latn_IT", "it"], @["und_JO", "ar_Arab_JO", "ar_JO"], @["und_JP", "ja_Jpan_JP", "ja"], @["und_Jpan", "ja_Jpan_JP", "ja"], @["und_KG", "ky_Cyrl_KG", "ky"], @["und_KH", "km_Khmr_KH", "km"], @["und_KM", "ar_Arab_KM", "ar_KM"], @["und_KP", "ko_Kore_KP", "ko_KP"], @["und_KR", "ko_Kore_KR", "ko"], @["und_KW", "ar_Arab_KW", "ar_KW"], @["und_KZ", "ru_Cyrl_KZ", "ru_KZ"], @["und_Khmr", "km_Khmr_KH", "km"], @["und_Knda", "kn_Knda_IN", "kn"], @["und_Kore", "ko_Kore_KR", "ko"], @["und_LA", "lo_Laoo_LA", "lo"], @["und_LB", "ar_Arab_LB", "ar_LB"], @["und_LI", "de_Latn_LI", "de_LI"], @["und_LK", "si_Sinh_LK", "si"], @["und_LS", "st_Latn_LS", "st_LS"], @["und_LT", "lt_Latn_LT", "lt"], @["und_LU", "fr_Latn_LU", "fr_LU"], @["und_LV", "lv_Latn_LV", "lv"], @["und_LY", "ar_Arab_LY", "ar_LY"], @["und_Laoo", "lo_Laoo_LA", "lo"], @["und_Latn_ES", "es_Latn_ES", "es"], @["und_Latn_ET", "en_Latn_ET", "en_ET"], @["und_Latn_GB", "en_Latn_GB", "en_GB"], @["und_Latn_GH", "ak_Latn_GH", "ak"], @["und_Latn_ID", "id_Latn_ID", "id"], @["und_Latn_IT", "it_Latn_IT", "it"], @["und_Latn_NG", "en_Latn_NG", "en_NG"], @["und_Latn_TR", "tr_Latn_TR", "tr"], @["und_Latn_ZA", "en_Latn_ZA", "en_ZA"], @["und_MA", "ar_Arab_MA", "ar_MA"], @["und_MC", "fr_Latn_MC", "fr_MC"], @["und_MD", "ro_Latn_MD", "ro_MD"], @["und_ME", "sr_Latn_ME", "sr_ME"], @["und_MG", "mg_Latn_MG", "mg"], @["und_MK", "mk_Cyrl_MK", "mk"], @["und_ML", "bm_Latn_ML", "bm"], @["und_MM", "my_Mymr_MM", "my"], @["und_MN", "mn_Cyrl_MN", "mn"], @["und_MO", "zh_Hant_MO", "zh_MO"], @["und_MQ", "fr_Latn_MQ", "fr_MQ"], @["und_MR", "ar_Arab_MR", "ar_MR"], @["und_MT", "mt_Latn_MT", "mt"], @["und_MV", "dv_Thaa_MV", "dv"], @["und_MX", "es_Latn_MX", "es_MX"], @["und_MY", "ms_Latn_MY", "ms"], @["und_MZ", "pt_Latn_MZ", "pt_MZ"], @["und_Mlym", "ml_Mlym_IN", "ml"], @["und_Mymr", "my_Mymr_MM", "my"], @["und_NC", "fr_Latn_NC", "fr_NC"], @["und_NE", "ha_Latn_NE", "ha_NE"], @["und_NG", "en_Latn_NG", "en_NG"], @["und_NI", "es_Latn_NI", "es_NI"], @["und_NL", "nl_Latn_NL", "nl"], @["und_NO", "nb_Latn_NO", "nb"], @["und_NP", "ne_Deva_NP", "ne"], @["und_NR", "en_Latn_NR", "en_NR"], @["und_OM", "ar_Arab_OM", "ar_OM"], @["und_Orya", "or_Orya_IN", "or"], @["und_PA", "es_Latn_PA", "es_PA"], @["und_PE", "es_Latn_PE", "es_PE"], @["und_PF", "fr_Latn_PF", "fr_PF"], @["und_PG", "tpi_Latn_PG", "tpi"], @["und_PH", "fil_Latn_PH", "fil"], @["und_PL", "pl_Latn_PL", "pl"], @["und_PM", "fr_Latn_PM", "fr_PM"], @["und_PR", "es_Latn_PR", "es_PR"], @["und_PS", "ar_Arab_PS", "ar_PS"], @["und_PT", "pt_Latn_PT", "pt_PT"], @["und_PW", "pau_Latn_PW", "pau"], @["und_PY", "gn_Latn_PY", "gn"], @["und_QA", "ar_Arab_QA", "ar_QA"], @["und_RE", "fr_Latn_RE", "fr_RE"], @["und_RO", "ro_Latn_RO", "ro"], @["und_RS", "sr_Cyrl_RS", "sr"], @["und_RU", "ru_Cyrl_RU", "ru"], @["und_RW", "rw_Latn_RW", "rw"], @["und_SA", "ar_Arab_SA", "ar_SA"], @["und_SD", "ar_Arab_SD", "ar_SD"], @["und_SE", "sv_Latn_SE", "sv"], @["und_SG", "en_Latn_SG", "en_SG"], @["und_SI", "sl_Latn_SI", "sl"], @["und_SJ", "nb_Latn_SJ", "nb_SJ"], @["und_SK", "sk_Latn_SK", "sk"], @["und_SM", "it_Latn_SM", "it_SM"], @["und_SN", "fr_Latn_SN", "fr_SN"], @["und_SO", "so_Latn_SO", "so"], @["und_SR", "nl_Latn_SR", "nl_SR"], @["und_ST", "pt_Latn_ST", "pt_ST"], @["und_SV", "es_Latn_SV", "es_SV"], @["und_SY", "ar_Arab_SY", "ar_SY"], @["und_Sinh", "si_Sinh_LK", "si"], @["und_Syrc", "syr_Syrc_IQ", "syr"], @["und_TD", "fr_Latn_TD", "fr_TD"], @["und_TG", "fr_Latn_TG", "fr_TG"], @["und_TH", "th_Thai_TH", "th"], @["und_TJ", "tg_Cyrl_TJ", "tg"], @["und_TK", "tkl_Latn_TK", "tkl"], @["und_TL", "pt_Latn_TL", "pt_TL"], @["und_TM", "tk_Latn_TM", "tk"], @["und_TN", "ar_Arab_TN", "ar_TN"], @["und_TO", "to_Latn_TO", "to"], @["und_TR", "tr_Latn_TR", "tr"], @["und_TV", "tvl_Latn_TV", "tvl"], @["und_TW", "zh_Hant_TW", "zh_TW"], @["und_Taml", "ta_Taml_IN", "ta"], @["und_Telu", "te_Telu_IN", "te"], @["und_Thaa", "dv_Thaa_MV", "dv"], @["und_Thai", "th_Thai_TH", "th"], @["und_Tibt", "bo_Tibt_CN", "bo"], @["und_UA", "uk_Cyrl_UA", "uk"], @["und_UY", "es_Latn_UY", "es_UY"], @["und_UZ", "uz_Latn_UZ", "uz"], @["und_VA", "it_Latn_VA", "it_VA"], @["und_VE", "es_Latn_VE", "es_VE"], @["und_VN", "vi_Latn_VN", "vi"], @["und_VU", "bi_Latn_VU", "bi"], @["und_WF", "fr_Latn_WF", "fr_WF"], @["und_WS", "sm_Latn_WS", "sm"], @["und_YE", "ar_Arab_YE", "ar_YE"], @["und_YT", "fr_Latn_YT", "fr_YT"], @["und_Yiii", "ii_Yiii_CN", "ii"], @["ur", "ur_Arab_PK", "ur"], @["uz", "uz_Latn_UZ", "uz"], @["uz_AF", "uz_Arab_AF", "uz_AF"], @["uz_Arab", "uz_Arab_AF", "uz_AF"], @["ve", "ve_Latn_ZA", "ve"], @["vi", "vi_Latn_VN", "vi"], @["wal", "wal_Ethi_ET", "wal"], @["wo", "wo_Latn_SN", "wo"], @["wo_SN", "wo_Latn_SN", "wo"], @["xh", "xh_Latn_ZA", "xh"], @["yo", "yo_Latn_NG", "yo"], @["zh", "zh_Hans_CN", "zh"], @["zh_HK", "zh_Hant_HK", "zh_HK"], @["zh_Hani", "zh_Hani_CN", "zh_Hani"], @["zh_Hant", "zh_Hant_TW", "zh_TW"], @["zh_MO", "zh_Hant_MO", "zh_MO"], @["zh_TW", "zh_Hant_TW", "zh_TW"], @["zu", "zu_Latn_ZA", "zu"], @["und", "en_Latn_US", "en"], @["und_ZZ", "en_Latn_US", "en"], @["und_CN", "zh_Hans_CN", "zh"], @["und_TW", "zh_Hant_TW", "zh_TW"], @["und_HK", "zh_Hant_HK", "zh_HK"], @["und_AQ", "und_Latn_AQ", "und_AQ"], @["und_Zzzz", "en_Latn_US", "en"], @["und_Zzzz_ZZ", "en_Latn_US", "en"], @["und_Zzzz_CN", "zh_Hans_CN", "zh"], @["und_Zzzz_TW", "zh_Hant_TW", "zh_TW"], @["und_Zzzz_HK", "zh_Hant_HK", "zh_HK"], @["und_Zzzz_AQ", "und_Latn_AQ", "und_AQ"], @["und_Latn", "en_Latn_US", "en"], @["und_Latn_ZZ", "en_Latn_US", "en"], @["und_Latn_CN", "za_Latn_CN", "za"], @["und_Latn_TW", "trv_Latn_TW", "trv"], @["und_Latn_HK", "zh_Latn_HK", "zh_Latn_HK"], @["und_Latn_AQ", "und_Latn_AQ", "und_AQ"], @["und_Hans", "zh_Hans_CN", "zh"], @["und_Hans_ZZ", "zh_Hans_CN", "zh"], @["und_Hans_CN", "zh_Hans_CN", "zh"], @["und_Hans_TW", "zh_Hans_TW", "zh_Hans_TW"], @["und_Hans_HK", "zh_Hans_HK", "zh_Hans_HK"], @["und_Hans_AQ", "zh_Hans_AQ", "zh_AQ"], @["und_Hant", "zh_Hant_TW", "zh_TW"], @["und_Hant_ZZ", "zh_Hant_TW", "zh_TW"], @["und_Hant_CN", "zh_Hant_CN", "zh_Hant_CN"], @["und_Hant_TW", "zh_Hant_TW", "zh_TW"], @["und_Hant_HK", "zh_Hant_HK", "zh_HK"], @["und_Hant_AQ", "zh_Hant_AQ", "zh_Hant_AQ"], @["und_Moon", "en_Moon_US", "en_Moon"], @["und_Moon_ZZ", "en_Moon_US", "en_Moon"], @["und_Moon_CN", "zh_Moon_CN", "zh_Moon"], @["und_Moon_TW", "zh_Moon_TW", "zh_Moon_TW"], @["und_Moon_HK", "zh_Moon_HK", "zh_Moon_HK"], @["und_Moon_AQ", "und_Moon_AQ", "und_Moon_AQ"], @["es", "es_Latn_ES", "es"], @["es_ZZ", "es_Latn_ES", "es"], @["es_CN", "es_Latn_CN", "es_CN"], @["es_TW", "es_Latn_TW", "es_TW"], @["es_HK", "es_Latn_HK", "es_HK"], @["es_AQ", "es_Latn_AQ", "es_AQ"], @["es_Zzzz", "es_Latn_ES", "es"], @["es_Zzzz_ZZ", "es_Latn_ES", "es"], @["es_Zzzz_CN", "es_Latn_CN", "es_CN"], @["es_Zzzz_TW", "es_Latn_TW", "es_TW"], @["es_Zzzz_HK", "es_Latn_HK", "es_HK"], @["es_Zzzz_AQ", "es_Latn_AQ", "es_AQ"], @["es_Latn", "es_Latn_ES", "es"], @["es_Latn_ZZ", "es_Latn_ES", "es"], @["es_Latn_CN", "es_Latn_CN", "es_CN"], @["es_Latn_TW", "es_Latn_TW", "es_TW"], @["es_Latn_HK", "es_Latn_HK", "es_HK"], @["es_Latn_AQ", "es_Latn_AQ", "es_AQ"], @["es_Hans", "es_Hans_ES", "es_Hans"], @["es_Hans_ZZ", "es_Hans_ES", "es_Hans"], @["es_Hans_CN", "es_Hans_CN", "es_Hans_CN"], @["es_Hans_TW", "es_Hans_TW", "es_Hans_TW"], @["es_Hans_HK", "es_Hans_HK", "es_Hans_HK"], @["es_Hans_AQ", "es_Hans_AQ", "es_Hans_AQ"], @["es_Hant", "es_Hant_ES", "es_Hant"], @["es_Hant_ZZ", "es_Hant_ES", "es_Hant"], @["es_Hant_CN", "es_Hant_CN", "es_Hant_CN"], @["es_Hant_TW", "es_Hant_TW", "es_Hant_TW"], @["es_Hant_HK", "es_Hant_HK", "es_Hant_HK"], @["es_Hant_AQ", "es_Hant_AQ", "es_Hant_AQ"], @["es_Moon", "es_Moon_ES", "es_Moon"], @["es_Moon_ZZ", "es_Moon_ES", "es_Moon"], @["es_Moon_CN", "es_Moon_CN", "es_Moon_CN"], @["es_Moon_TW", "es_Moon_TW", "es_Moon_TW"], @["es_Moon_HK", "es_Moon_HK", "es_Moon_HK"], @["es_Moon_AQ", "es_Moon_AQ", "es_Moon_AQ"], @["zh", "zh_Hans_CN", "zh"], @["zh_ZZ", "zh_Hans_CN", "zh"], @["zh_CN", "zh_Hans_CN", "zh"], @["zh_TW", "zh_Hant_TW", "zh_TW"], @["zh_HK", "zh_Hant_HK", "zh_HK"], @["zh_AQ", "zh_Hans_AQ", "zh_AQ"], @["zh_Zzzz", "zh_Hans_CN", "zh"], @["zh_Zzzz_ZZ", "zh_Hans_CN", "zh"], @["zh_Zzzz_CN", "zh_Hans_CN", "zh"], @["zh_Zzzz_TW", "zh_Hant_TW", "zh_TW"], @["zh_Zzzz_HK", "zh_Hant_HK", "zh_HK"], @["zh_Zzzz_AQ", "zh_Hans_AQ", "zh_AQ"], @["zh_Latn", "zh_Latn_CN", "zh_Latn"], @["zh_Latn_ZZ", "zh_Latn_CN", "zh_Latn"], @["zh_Latn_CN", "zh_Latn_CN", "zh_Latn"], @["zh_Latn_TW", "zh_Latn_TW", "zh_Latn_TW"], @["zh_Latn_HK", "zh_Latn_HK", "zh_Latn_HK"], @["zh_Latn_AQ", "zh_Latn_AQ", "zh_Latn_AQ"], @["zh_Hans", "zh_Hans_CN", "zh"], @["zh_Hans_ZZ", "zh_Hans_CN", "zh"], @["zh_Hans_TW", "zh_Hans_TW", "zh_Hans_TW"], @["zh_Hans_HK", "zh_Hans_HK", "zh_Hans_HK"], @["zh_Hans_AQ", "zh_Hans_AQ", "zh_AQ"], @["zh_Hant", "zh_Hant_TW", "zh_TW"], @["zh_Hant_ZZ", "zh_Hant_TW", "zh_TW"], @["zh_Hant_CN", "zh_Hant_CN", "zh_Hant_CN"], @["zh_Hant_AQ", "zh_Hant_AQ", "zh_Hant_AQ"], @["zh_Moon", "zh_Moon_CN", "zh_Moon"], @["zh_Moon_ZZ", "zh_Moon_CN", "zh_Moon"], @["zh_Moon_CN", "zh_Moon_CN", "zh_Moon"], @["zh_Moon_TW", "zh_Moon_TW", "zh_Moon_TW"], @["zh_Moon_HK", "zh_Moon_HK", "zh_Moon_HK"], @["zh_Moon_AQ", "zh_Moon_AQ", "zh_Moon_AQ"], @["art", "", ""], @["art_ZZ", "", ""], @["art_CN", "", ""], @["art_TW", "", ""], @["art_HK", "", ""], @["art_AQ", "", ""], @["art_Zzzz", "", ""], @["art_Zzzz_ZZ", "", ""], @["art_Zzzz_CN", "", ""], @["art_Zzzz_TW", "", ""], @["art_Zzzz_HK", "", ""], @["art_Zzzz_AQ", "", ""], @["art_Latn", "", ""], @["art_Latn_ZZ", "", ""], @["art_Latn_CN", "", ""], @["art_Latn_TW", "", ""], @["art_Latn_HK", "", ""], @["art_Latn_AQ", "", ""], @["art_Hans", "", ""], @["art_Hans_ZZ", "", ""], @["art_Hans_CN", "", ""], @["art_Hans_TW", "", ""], @["art_Hans_HK", "", ""], @["art_Hans_AQ", "", ""], @["art_Hant", "", ""], @["art_Hant_ZZ", "", ""], @["art_Hant_CN", "", ""], @["art_Hant_TW", "", ""], @["art_Hant_HK", "", ""], @["art_Hant_AQ", "", ""], @["art_Moon", "", ""], @["art_Moon_ZZ", "", ""], @["art_Moon_CN", "", ""], @["art_Moon_TW", "", ""], @["art_Moon_HK", "", ""], @["art_Moon_AQ", "", ""]]
      var i: int = 0
      while i < full_data.Length:
          var org: UCultureInfo = UCultureInfo(full_data[i][0])
          var res: UCultureInfo = UCultureInfo.AddLikelySubtags(org)
          var exp: String = full_data[i][1]
          if exp.Length == 0:
              if !org.Equals(res):
Errln("Original: " + full_data[i][0] + " expected: " + exp + " - but got " + res.ToString)

          elif !res.ToString.Equals(exp):
Errln("Original: " + full_data[i][0] + " expected: " + exp + " - but got " + res.ToString)
++i
      var i: int = 0
      while i < full_data.Length:
          var maximal: String = full_data[i][1]
          if maximal.Length > 0:
              var org: UCultureInfo = UCultureInfo(maximal)
              var res: UCultureInfo = UCultureInfo.MinimizeSubtags(org)
              var exp: String = full_data[i][2]
              if exp.Length == 0:
                  if !org.Equals(res):
Errln("Original: " + full_data[i][1] + " expected: " + exp + " - but got " + res.ToString)

              elif !res.ToString.Equals(exp):
Errln("Original: " + full_data[i][1] + " expected: " + exp + " - but got " + res.ToString)
++i
proc TestCLDRVersion*() =
    var testExpect: VersionInfo
    var testCurrent: VersionInfo
    var cldrVersion: VersionInfo
    cldrVersion = LocaleData.GetCLDRVersion
TestFmwk.Logln("uloc_getCLDRVersion() returned: '" + cldrVersion + "'")
    var testLoader: Assembly = type(ICUResourceBundleTest).Assembly
    var bundle: UResourceBundle = UResourceBundle.GetBundleInstance("Dev/Data/TestData", UCultureInfo.InvariantCulture, testLoader)
    testExpect = VersionInfo.GetInstance(bundle.GetString("ExpectCLDRVersionAtLeast"))
    testCurrent = VersionInfo.GetInstance(bundle.GetString("CurrentCLDRVersion"))
Logln("(data) ExpectCLDRVersionAtLeast { " + testExpect + "")
    if cldrVersion.CompareTo(testExpect) < 0:
Errln("CLDR version is too old, expect at least " + testExpect + ".")
    var r: int = cldrVersion.CompareTo(testCurrent)
    if r < 0:
Logln("CLDR version is behind 'current' (for testdata/root.txt) " + testCurrent + ". Some things may fail.
")

    elif r > 0:
Logln("CLDR version is ahead of 'current' (for testdata/root.txt) " + testCurrent + ". Some things may fail.
")
    else:

proc TestToLanguageTag*() =
    var locale_to_langtag: string[][] = @[@["", "und"], @["en", "en"], @["en_US", "en-US"], @["iw_IL", "he-IL"], @["sr_Latn_SR", "sr-Latn-SR"], @["en_US_POSIX@ca=japanese", "en-US-u-ca-japanese-va-posix"], @["en__POSIX", "en-u-va-posix"], @["en_US_POSIX_VAR", "en-US-posix-x-lvariant-var"], @["en_US_VAR_POSIX", "en-US-x-lvariant-var-posix"], @["en_US_POSIX@va=posix2", "en-US-u-va-posix2"], @["und_555", "und-555"], @["123", "und"], @["%$#&", "und"], @["_Latn", "und-Latn"], @["_DE", "und-DE"], @["und_FR", "und-FR"], @["th_TH_TH", "th-TH-x-lvariant-th"], @["bogus", "bogus"], @["foooobarrr", "und"], @["aa_BB_CYRL", "aa-BB-x-lvariant-cyrl"], @["en_US_1234", "en-US-1234"], @["en_US_VARIANTA_VARIANTB", "en-US-varianta-variantb"], @["en_US_VARIANTB_VARIANTA", "en-US-variantb-varianta"], @["ja__9876_5432", "ja-9876-5432"], @["zh_Hant__VAR", "zh-Hant-x-lvariant-var"], @["es__BADVARIANT_GOODVAR", "es"], @["es__GOODVAR_BAD_BADVARIANT", "es-goodvar-x-lvariant-bad"], @["en@calendar=gregorian", "en-u-ca-gregory"], @["de@collation=phonebook;calendar=gregorian", "de-u-ca-gregory-co-phonebk"], @["th@numbers=thai;z=extz;x=priv-use;a=exta", "th-a-exta-u-nu-thai-z-extz-x-priv-use"], @["en@timezone=America/New_York;calendar=japanese", "en-u-ca-japanese-tz-usnyc"], @["en@timezone=US/Eastern", "en-u-tz-usnyc"], @["en@x=x-y-z;a=a-b-c", "en-x-x-y-z"], @["it@collation=badcollationtype;colStrength=identical;cu=usd-eur", "it-u-cu-usd-eur-ks-identic"], @["en_US_POSIX", "en-US-u-va-posix"], @["en_US_POSIX@calendar=japanese;currency=EUR", "en-US-u-ca-japanese-cu-eur-va-posix"], @["@x=elmer", "x-elmer"], @["_US@x=elmer", "und-US-x-elmer"], @["en@a=bar;attribute=baz", "en-a-bar-u-baz"], @["en@a=bar;attribute=baz;x=u-foo", "en-a-bar-u-baz-x-u-foo"], @["en@attribute=baz", "en-u-baz"], @["en@attribute=baz;calendar=islamic-civil", "en-u-baz-ca-islamic-civil"], @["en@a=bar;calendar=islamic-civil;x=u-foo", "en-a-bar-u-ca-islamic-civil-x-u-foo"], @["en@a=bar;attribute=baz;calendar=islamic-civil;x=u-foo", "en-a-bar-u-baz-ca-islamic-civil-x-u-foo"]]
      var i: int = 0
      while i < locale_to_langtag.Length:
          try:
              var loc: UCultureInfo = UCultureInfo(locale_to_langtag[i][0])
              var langtag: String = loc.ToIetfLanguageTag
              if !langtag.Equals(locale_to_langtag[i][1]):
Errln("FAIL: ToIetfLanguageTag returned language tag [" + langtag + "] for locale [" + loc + "] - expected: [" + locale_to_langtag[i][1] + "]")
          except Exception:

++i
proc TestForLanguageTag*() =
    var NOERROR: int? = int?(-1)
    var langtag_to_locale: object[][] = @[@["en", "en", NOERROR], @["en-us", "en_US", NOERROR], @["und-us", "_US", NOERROR], @["und-latn", "_Latn", NOERROR], @["en-us-posix", "en_US_POSIX", NOERROR], @["de-de_euro", "de", int?(3)], @["kok-in", "kok_IN", NOERROR], @["123", "", int?(0)], @["en_us", "", int?(0)], @["en-latn-x", "en_Latn", int?(8)], @["art-lojban", "jbo", NOERROR], @["zh-hakka", "hak", NOERROR], @["zh-cmn-CH", "cmn_CH", NOERROR], @["xxx-yy", "xxx_YY", NOERROR], @["fr-234", "fr_234", NOERROR], @["i-default", "en@x=i-default", NOERROR], @["i-test", "", int?(0)], @["ja-jp-jp", "ja_JP", int?(6)], @["bogus", "bogus", NOERROR], @["boguslang", "", int?(0)], @["EN-lATN-us", "en_Latn_US", NOERROR], @["und-variant-1234", "__VARIANT_1234", NOERROR], @["und-varzero-var1-vartwo", "__VARZERO", int?(12)], @["en-u-ca-gregory", "en@calendar=gregorian", NOERROR], @["en-U-cu-USD", "en@currency=usd", NOERROR], @["en-us-u-va-posix", "en_US_POSIX", NOERROR], @["en-us-u-ca-gregory-va-posix", "en_US_POSIX@calendar=gregorian", NOERROR], @["en-us-posix-u-va-posix", "en_US_POSIX@va=posix", NOERROR], @["en-us-u-va-posix2", "en_US@va=posix2", NOERROR], @["en-us-vari1-u-va-posix", "en_US_VARI1@va=posix", NOERROR], @["ar-x-1-2-3", "ar@x=1-2-3", NOERROR], @["fr-u-nu-latn-cu-eur", "fr@currency=eur;numbers=latn", NOERROR], @["de-k-kext-u-co-phonebk-nu-latn", "de@collation=phonebook;k=kext;numbers=latn", NOERROR], @["ja-u-cu-jpy-ca-jp", "ja@calendar=yes;currency=jpy;jp=yes", NOERROR], @["en-us-u-tz-usnyc", "en_US@timezone=America/New_York", NOERROR], @["und-a-abc-def", "@a=abc-def", NOERROR], @["zh-u-ca-chinese-x-u-ca-chinese", "zh@calendar=chinese;x=u-ca-chinese", NOERROR], @["fr--FR", "fr", int?(3)], @["fr-", "fr", int?(3)], @["x-elmer", "@x=elmer", NOERROR], @["en-US-u-attr1-attr2-ca-gregory", "en_US@attribute=attr1-attr2;calendar=gregorian", NOERROR], @["sr-u-kn", "sr@colnumeric=yes", NOERROR], @["de-u-kn-co-phonebk", "de@collation=phonebook;colnumeric=yes", NOERROR], @["en-u-attr2-attr1-kn-kb", "en@attribute=attr1-attr2;colbackwards=yes;colnumeric=yes", NOERROR], @["ja-u-ijkl-efgh-abcd-ca-japanese-xx-yyy-zzz-kn", "ja@attribute=abcd-efgh-ijkl;calendar=japanese;colnumeric=yes;xx=yyy-zzz", NOERROR], @["de-u-xc-xphonebk-co-phonebk-ca-buddhist-mo-very-lo-extensi-xd-that-de-should-vc-probably-xz-killthebuffer", "de@calendar=buddhist;collation=phonebook;de=should;lo=extensi;mo=very;vc=probably;xc=xphonebk;xd=that;xz=yes", int?(92)], @["en-a-bar-u-baz", "en@a=bar;attribute=baz", NOERROR], @["en-a-bar-u-baz-x-u-foo", "en@a=bar;attribute=baz;x=u-foo", NOERROR], @["en-u-baz", "en@attribute=baz", NOERROR], @["en-u-baz-ca-islamic-civil", "en@attribute=baz;calendar=islamic-civil", NOERROR], @["en-a-bar-u-ca-islamic-civil-x-u-foo", "en@a=bar;calendar=islamic-civil;x=u-foo", NOERROR], @["en-a-bar-u-baz-ca-islamic-civil-x-u-foo", "en@a=bar;attribute=baz;calendar=islamic-civil;x=u-foo", NOERROR]]
      var i: int = 0
      while i < langtag_to_locale.Length:
          var tag: String = cast[String](langtag_to_locale[i][0])
          var expected: UCultureInfo = UCultureInfo(cast[String](langtag_to_locale[i][1]))
          var loc: UCultureInfo = UCultureInfo.GetCultureInfoByIetfLanguageTag(tag)
          if !loc.Equals(expected):
Errln("FAIL: forLanguageTag returned locale [" + loc + "] for language tag [" + tag + "] - expected: [" + expected + "]")
++i
      var i: int = 0
      while i < langtag_to_locale.Length:
          var tag: String = cast[String](langtag_to_locale[i][0])
          var expected: UCultureInfo = UCultureInfo(cast[String](langtag_to_locale[i][1]))
          var errorIdx: int = cast[int?](langtag_to_locale[i][2]).Value
          try:
              var bld: UCultureInfoBuilder = UCultureInfoBuilder
bld.SetLanguageTag(tag)
              var loc: UCultureInfo = bld.Build
              if !loc.Equals(expected):
Errln("FAIL: forLanguageTag returned locale [" + loc + "] for language tag [" + tag + "] - expected: [" + expected + "]")
              if errorIdx != NOERROR.Value:
Errln("FAIL: UCultureInfoBuilder.setLanguageTag should throw an exception for input tag [" + tag + "]")
          except IllformedLocaleException:
              if ifle.ErrorIndex != errorIdx:
Errln("FAIL: UCultureInfoBuilder.setLanguageTag returned error index " + ifle.ErrorIndex + " for input language tag [" + tag + "] expected: " + errorIdx)
++i
proc Test4735*() =
    try:
UCultureInfo("und").GetDisplayKeywordValue("calendar", UCultureInfo("de"))
UCultureInfo("en").GetDisplayKeywordValue("calendar", UCultureInfo("de"))
    except Exception:
Errln("Unexpected exception: " + e.ToString)
proc TestGetFallback*() =
    var TESTIDS: string[][] = @[@["en_US", "en", "", ""], @["EN_us_Var", "en_US", "en", ""], @["de_DE@collation=phonebook", "de@collation=phonebook", "@collation=phonebook", "@collation=phonebook"], @["en__POSIX", "en", ""], @["_US_POSIX", "_US", ""], @["root", ""]]
    for chain in TESTIDS:
          var i: int = 1
          while i < chain.Length:
              var fallback: String = UCultureInfo.GetParent(chain[i - 1])
assertEquals("GetParent("" + chain[i - 1] + "")", chain[i], fallback)
++i
    var TESTLOCALES: UCultureInfo[][] = @[@[UCultureInfo("en_US"), UCultureInfo("en"), UCultureInfo.InvariantCulture, nil], @[UCultureInfo("en__POSIX"), UCultureInfo("en"), UCultureInfo.InvariantCulture, nil], @[UCultureInfo("de_DE@collation=phonebook"), UCultureInfo("de@collation=phonebook"), UCultureInfo("@collation=phonebook"), nil], @[UCultureInfo("_US_POSIX"), UCultureInfo("_US"), UCultureInfo.InvariantCulture, nil], @[UCultureInfo("root"), UCultureInfo.InvariantCulture, nil]]
    for chain in TESTLOCALES:
          var i: int = 1
          while i < chain.Length:
              var fallback: UCultureInfo = chain[i - 1].GetParent
assertEquals("UCultureInfo(" + chain[i - 1] + ").GetParent()", chain[i], fallback)
++i
proc TestExtension*() =
    var TESTCASES: string[][] = @[@["en"], @["en-a-exta-b-extb", "a", "exta", "b", "extb"], @["en-b-extb-a-exta", "a", "exta", "b", "extb"], @["de-x-a-bc-def", "x", "a-bc-def"], @["ja-JP-u-cu-jpy-ca-japanese-x-java", "u", "ca-japanese-cu-jpy", "x", "java"]]
    for testcase in TESTCASES:
        var loc: UCultureInfo = UCultureInfo.GetCultureInfoByIetfLanguageTag(testcase[0])
        var nExtensions: int = testcase.Length - 1 / 2
        if loc.Extensions.Count != nExtensions:
Errln("Incorrect number of extensions: returned=" + loc.Extensions.Count + ", expected=" + nExtensions + ", locale=" + testcase[0])
          var i: int = 0
          while i < nExtensions:
              var kstr: String = testcase[i / 2 + 1]
loc.Extensions.TryGetValue(kstr[0],               var ext: string)
              if ext == nil || !ext.Equals(testcase[i / 2 + 2]):
Errln("Incorrect extension value: key=" + kstr + ", returned=" + ext + ", expected=" + testcase[i / 2 + 2] + ", locale=" + testcase[0])
++i
    var sawException: bool = false
    try:
        var l: UCultureInfo = UCultureInfo.GetCultureInfoByIetfLanguageTag("en-US-a-exta")
        var _ = l.Extensions['$']
    except KeyNotFoundException:
        sawException = true
    if !sawException:
Errln("getExtension must throw an exception on illegal input key")
proc TestUnicodeLocaleExtension*() =
    var TESTCASES: string[][] = @[@["en", nil, nil], @["en-a-ext1-x-privuse", nil, nil], @["en-u-attr1-attr2", "attr1,attr2", nil], @["ja-u-ca-japanese-cu-jpy", nil, "ca,cu", "japanese", "jpy"], @["th-TH-u-number-attr-nu-thai-ca-buddhist", "attr,number", "ca,nu", "buddhist", "thai"]]
    for testcase in TESTCASES:
        var loc: UCultureInfo = UCultureInfo.GetCultureInfoByIetfLanguageTag(testcase[0])
        var expectedAttributes: ISet<String> = HashSet<String>
        if testcase[1] != nil:
            var attrs: String[] = testcase[1].Split(',')
            for s in attrs:
expectedAttributes.Add(s)
        var expectedKeywords: IDictionary<String, String> = Dictionary<String, String>
        if testcase[2] != nil:
            var ukeys: String[] = testcase[2].Split(',')
              var i: int = 0
              while i < ukeys.Length:
                  expectedKeywords[ukeys[i]] = testcase[i + 3]
++i
        var attributes = loc.UnicodeLocaleAttributes
        if attributes.Count != expectedAttributes.Count:
Errln("Incorrect number for Unicode locale attributes: returned=" + attributes.Count + ", expected=" + expectedAttributes.Count + ", locale=" + testcase[0])
        if !attributes.IsSupersetOf(expectedAttributes) || !expectedAttributes.IsSupersetOf(attributes):
Errln("Incorrect set of attributes for locale " + testcase[0])
        var expectedKeys: ICollection<String> = expectedKeywords.Keys
        if loc.UnicodeLocales.Count != expectedKeys.Count:
Errln("Incorrect number for Unicode locale keys: returned=" + loc.UnicodeLocales.Count + ", expected=" + expectedKeys.Count + ", locale=" + testcase[0])
        for expKey in expectedKeys:
            var type: String = loc.UnicodeLocales[expKey]
            var expType: String = expectedKeywords[expKey]
            if type == nil || !expType.Equals(type):
Errln("Incorrect Unicode locale type: key=" + expKey + ", returned=" + type + ", expected=" + expType + ", locale=" + testcase[0])
    var sawException: bool = false
    try:
        var l: UCultureInfo = UCultureInfo.GetCultureInfoByIetfLanguageTag("en-US-u-ca-gregory")
        var _ = l.UnicodeLocales["$%"]
    except KeyNotFoundException:
        sawException = true
    if !sawException:
Errln("getUnicodeLocaleType must throw an exception on illegal input key")
type
  CultureWithCalendar = ref object
    calendar: Calendar
    optionalCalendars: seq[Calendar]

proc newCultureWithCalendar(culture: string, calendar: Calendar): CultureWithCalendar =
newCultureInfo(culture)
  self.calendar = calendar
  self.DateTimeFormat.Calendar = calendar
proc Calendar(): Calendar =
    return calendar
proc OptionalCalendars(): seq[Calendar] =
    if optionalCalendars == nil:
        if !procCall.OptionalCalendars.Contains(calendar):
          optionalCalendars = List<Calendar>(optionalCalendars).ToArray
        else:
          optionalCalendars = procCall.OptionalCalendars
    return optionalCalendars
proc ToString*(): string =
    return procCall.ToString + " with " & $calendar.GetType.Name
proc GetCultureInfoData*(): IEnumerable<TestCaseData> =
    yield TestCaseData(CultureInfo.InvariantCulture, "")
    yield TestCaseData(CultureInfo("en-US"), "en_US")
    yield TestCaseData(CultureInfo("en-US-POSIX"), "en_US_POSIX")
    yield TestCaseData(CultureInfo("ckb"), "ckb")
    yield TestCaseData(CultureInfo("ckb-IQ"), "ckb_IQ")
    yield TestCaseData(CultureInfo("ckb-IR"), "ckb_IR")
    yield TestCaseData(CultureInfo("fa-AF"), "fa_AF")
    yield TestCaseData(CultureInfo("qu"), "qu")
    yield TestCaseData(CultureInfo("qu-BO"), "qu_BO")
    yield TestCaseData(CultureInfo("qu-EC"), "qu_EC")
    yield TestCaseData(CultureInfo("qu-PE"), "qu_PE")
    yield TestCaseData(CultureInfo("es-ES_tradnl"), "es_ES@collation=traditional")
    yield TestCaseData(CultureInfo("zh-TW_pronun"), "zh_TW@collation=zhuyin")
    yield TestCaseData(CultureInfo("zh-CN_stroke"), "zh_CN@collation=stroke")
    yield TestCaseData(CultureInfo("zh-SG_stroke"), "zh_SG@collation=stroke")
    yield TestCaseData(CultureInfo("zh-MO_stroke"), "zh_MO")
    yield TestCaseData(CultureInfo("zh-MO"), "zh_MO@collation=pinyin")
    yield TestCaseData(CultureInfo("de-DE_phoneb"), "de_DE@collation=phonebook")
    yield TestCaseData(CultureInfo("hu-HU_technl"), "hu_HU")
    yield TestCaseData(CultureInfo("ka-GE_modern"), "ka_GE")
    yield TestCaseData(CultureInfo("ja-JP"), "ja_JP")
    yield TestCaseData(CultureInfo("fa"), "fa")
    yield TestCaseData(CultureInfo("th-TH"), "th_TH")
    yield TestCaseData(CultureInfo("ar-SA"), "ar_SA")
    yield TestCaseData(CultureInfo("ckb-IR"), "ckb_IR")
    yield TestCaseData(CultureInfo("fa-IR"), "fa_IR")
    yield TestCaseData(CultureInfo("lrc-IR"), "lrc_IR")
    yield TestCaseData(CultureInfo("mzn-IR"), "mzn_IR")
    yield TestCaseData(CultureInfo("ps-AF"), "ps_AF")
    yield TestCaseData(CultureInfo("uz-Arab-AF"), "uz_Arab_AF")
    yield TestCaseData(CultureWithCalendar("ja-JP", JapaneseCalendar), "ja_JP@calendar=japanese")
    yield TestCaseData(CultureWithCalendar("fa", GregorianCalendar), "fa@calendar=gregorian")
    yield TestCaseData(CultureWithCalendar("th-TH", GregorianCalendar), "th_TH@calendar=gregorian")
proc TestToUCultureInfo*(culture: CultureInfo, fullName: string) =
assertEquals("ToUCultureInfo() with " & $culture, fullName, culture.ToUCultureInfo.FullName)
proc GetUCultureInfoData*(): IEnumerable<TestCaseData> =
    yield TestCaseData("", CultureInfo.InvariantCulture)
    yield TestCaseData("en_US", CultureInfo("en-US"))
    yield TestCaseData("_US", CultureInfo("US"))
    yield TestCaseData("nn_NO", CultureInfo("nn-NO"))
    yield TestCaseData("th_TH@numbers=thai", CultureInfo("th-TH"))
    yield TestCaseData("es_ES@collation=traditional", CultureInfo("es-ES_tradnl"))
    yield TestCaseData("zh_TW@collation=zhuyin", CultureInfo("zh-TW_pronun"))
    yield TestCaseData("zh_CN@collation=stroke", CultureInfo("zh-CN_stroke"))
    yield TestCaseData("zh_SG@collation=stroke", CultureInfo("zh-SG_stroke"))
    yield TestCaseData("zh_MO", CultureInfo("zh-MO_stroke"))
    yield TestCaseData("zh_MO@collation=pinyin", CultureInfo("zh-MO"))
    yield TestCaseData("de_DE@collation=phonebook", CultureInfo("de-DE_phoneb"))
proc TestToCultureInfo*(fullName: string, culture: CultureInfo) =
assertEquals("ToCultureInfo() with " & $fullName, culture, UCultureInfo(fullName).ToCultureInfo)
proc TestToCultureInfo_AllCultures*() =
    var locales = UCultureInfo.GetCultures(UCultureTypes.AllCultures)
    var unknownCultures = J2N.Collections.Generic.Dictionary<CultureInfo, string>
    var ci: CultureInfo = nil
    for locale in locales:
        ci = locale.ToCultureInfo
        if ci.EnglishName.StartsWith("Unknown Language", StringComparison.Ordinal):
unknownCultures.Add(ci, locale.EnglishName)
assertEquals("Cultures not mapped: 

" & $unknownCultures.ToString(StringFormatter.InvariantCulture) & "

", 0, unknownCultures.Count)
proc TestCategoryDefault*() =
    var backupDefault: CultureInfo = CultureInfo.CurrentCulture
    var orgDefault: UCultureInfo = UCultureInfo.CurrentCulture
    var uJaJp: UCultureInfo = UCultureInfo("ja_JP")
    var uDeDePhonebook: UCultureInfo = UCultureInfo("de_DE@collation=phonebook")
    UCultureInfo.CurrentUICulture = uJaJp
    UCultureInfo.CurrentCulture = uDeDePhonebook
    if !UCultureInfo.CurrentUICulture.Equals(uJaJp):
Errln("FAIL: DISPLAY ULocale is " + UCultureInfo.CurrentUICulture + ", expected: " + uJaJp)
    if !UCultureInfo.CurrentCulture.Equals(uDeDePhonebook):
Errln("FAIL: FORMAT ULocale is " + UCultureInfo.CurrentCulture + ", expected: " + uDeDePhonebook)
    var uFrFr: UCultureInfo = UCultureInfo("fr_FR")
    if !UCultureInfo.CurrentUICulture.Equals(uFrFr):
Errln("FAIL: DISPLAY ULocale is " + UCultureInfo.CurrentUICulture + ", expected: " + uFrFr)
    if !UCultureInfo.CurrentCulture.Equals(uFrFr):
Errln("FAIL: FORMAT ULocale is " + UCultureInfo.CurrentCulture + ", expected: " + uFrFr)
    var arEg: CultureInfo = CultureInfo("ar-EG")
    var uArEg: UCultureInfo = arEg.ToUCultureInfo
    System.Threading.Thread.CurrentThread.CurrentCulture = arEg
    if !UCultureInfo.CurrentCulture.Equals(uArEg):
Errln("FAIL: Default ULocale is " + UCultureInfo.CurrentCulture + ", expected: " + uArEg)
    if !UCultureInfo.CurrentUICulture.Equals(uArEg):
Errln("FAIL: DISPLAY ULocale is " + UCultureInfo.CurrentUICulture + ", expected: " + uArEg)
    if !UCultureInfo.CurrentCulture.Equals(uArEg):
Errln("FAIL: FORMAT ULocale is " + UCultureInfo.CurrentCulture + ", expected: " + uArEg)
    System.Threading.Thread.CurrentThread.CurrentCulture = backupDefault
proc TestComparable*() =
    var localeStrings: string[] = @["en", "EN", "en_US", "en_GB", "en_US_POSIX", "en_us_posix", "ar_EG", "zh_Hans_CN", "zh_Hant_TW", "zh_Hans", "zh_CN", "zh_TW", "th_TH@calendar=buddhist;numbers=thai", "TH_TH@NUMBERS=thai;CALENDAR=buddhist", "th_TH@calendar=buddhist", "th_TH@calendar=gergorian", "th_TH@numbers=latn", "abc_def_ghi_jkl_opq", "abc_DEF_ghi_JKL_opq", "", "und", "This is a bogus locale ID", "This is a BOGUS locale ID", "en_POSIX", "en__POSIX"]
    var locales: UCultureInfo[] = seq[UCultureInfo]
      var i: int = 0
      while i < locales.Length:
          locales[i] = UCultureInfo(localeStrings[i])
++i
      var i: int = 0
      while i < locales.Length:
            var j: int = i
            while j < locales.Length:
                var eqls1: bool = locales[i].Equals(locales[j])
                var eqls2: bool = locales[i].Equals(locales[j])
                if eqls1 != eqls2:
Errln("FAILED: loc1.Equals(loc2) and loc2.Equals(loc1) return different results: loc1=" + locales[i] + ", loc2=" + locales[j])
                var cmp1: int = locales[i].CompareTo(locales[j])
                var cmp2: int = locales[j].CompareTo(locales[i])
                if cmp1 == 0 != eqls1:
Errln("FAILED: inconsistent equals and compareTo: loc1=" + locales[i] + ", loc2=" + locales[j])
                if cmp1 < 0 && cmp2 <= 0 || cmp1 > 0 && cmp2 >= 0 || cmp1 == 0 && cmp2 != 0:
Errln("FAILED: loc1.compareTo(loc2) is inconsistent with loc2.compareTo(loc1): loc1=" + locales[i] + ", loc2=" + locales[j])
++j
++i
    var sortedLocaleStrings: String[] = @["", "abc_DEF_GHI_JKL_OPQ", "ar_EG", "en", "en__POSIX", "en_GB", "en_US", "en_US_POSIX", "th_TH@calendar=buddhist", "th_TH@calendar=buddhist;numbers=thai", "th_TH@calendar=gergorian", "th_TH@numbers=latn", "this is a bogus locale id", "und", "zh_CN", "zh_TW", "zh_Hans", "zh_Hans_CN", "zh_Hant_TW"]
    var sortedLocales: SortedSet<UCultureInfo> = SortedSet<UCultureInfo>
    for locale in locales:
sortedLocales.Add(locale)
    if sortedLocales.Count != sortedLocaleStrings.Length:
Errln("FAILED: Number of unique locales: " + sortedLocales.Count + ", expected: " + sortedLocaleStrings.Length)
    var i2: int = 0
    for loc in sortedLocales:
        if !loc.ToString.Equals(sortedLocaleStrings[++i2]):
Errln("FAILED: Sort order is incorrect for " + loc.ToString)
            break
proc TestToUnicodeLocaleKey*() =
    var DATA: string[][] = @[@["calendar", "ca"], @["CALEndar", "ca"], @["ca", "ca"], @["kv", "kv"], @["foo", nil], @["ZZ", "zz"]]
    for d in DATA:
        var keyword: String = d[0]
        var expected: String = d[1]
        var bcpKey: String = UCultureInfo.ToUnicodeLocaleKey(keyword)
assertEquals("keyword=" + keyword, expected, bcpKey)
proc TestToLegacyKey*() =
    var DATA: string[][] = @[@["kb", "colbackwards"], @["kB", "colbackwards"], @["Collation", "collation"], @["kv", "kv"], @["foo", "foo"], @["ZZ", "zz"], @["e=mc2", nil]]
    for d in DATA:
        var keyword: String = d[0]
        var expected: String = d[1]
        var legacyKey: String = UCultureInfo.ToLegacyKey(keyword)
assertEquals("bcpKey=" + keyword, expected, legacyKey)
proc TestToUnicodeLocaleType*() =
    var DATA: string[][] = @[@["tz", "Asia/Kolkata", "inccu"], @["calendar", "gregorian", "gregory"], @["ca", "gregorian", "gregory"], @["ca", "Gregorian", "gregory"], @["ca", "buddhist", "buddhist"], @["Calendar", "Japanese", "japanese"], @["calendar", "Islamic-Civil", "islamic-civil"], @["calendar", "islamicc", "islamic-civil"], @["colalternate", "NON-IGNORABLE", "noignore"], @["colcaselevel", "yes", "true"], @["rg", "GBzzzz", "gbzzzz"], @["tz", "america/new_york", "usnyc"], @["tz", "Asia/Kolkata", "inccu"], @["timezone", "navajo", "usden"], @["ca", "aaaa", "aaaa"], @["ca", "gregory-japanese-islamic", "gregory-japanese-islamic"], @["zz", "gregorian", nil], @["co", "foo-", nil], @["variableTop", "00A0", "00a0"], @["variableTop", "wxyz", "wxyz"], @["kr", "space-punct", "space-punct"], @["kr", "digit-spacepunct", nil]]
    for d in DATA:
        var keyword: String = d[0]
        var value: String = d[1]
        var expected: String = d[2]
        var bcpType: String = UCultureInfo.ToUnicodeLocaleType(keyword, value)
assertEquals("keyword=" + keyword + ", value=" + value, expected, bcpType)
proc TestToLegacyType*() =
    var DATA: string[][] = @[@["calendar", "gregory", "gregorian"], @["ca", "gregory", "gregorian"], @["ca", "Gregory", "gregorian"], @["ca", "buddhist", "buddhist"], @["Calendar", "Japanese", "japanese"], @["calendar", "Islamic-Civil", "islamic-civil"], @["calendar", "islamicc", "islamic-civil"], @["colalternate", "noignore", "non-ignorable"], @["colcaselevel", "true", "yes"], @["rg", "gbzzzz", "gbzzzz"], @["tz", "usnyc", "America/New_York"], @["tz", "inccu", "Asia/Calcutta"], @["timezone", "usden", "America/Denver"], @["timezone", "usnavajo", "America/Denver"], @["colstrength", "quarternary", "quaternary"], @["ca", "aaaa", "aaaa"], @["calendar", "gregory-japanese-islamic", "gregory-japanese-islamic"], @["zz", "gregorian", "gregorian"], @["ca", "gregorian-calendar", "gregorian-calendar"], @["co", "e=mc2", nil], @["variableTop", "00A0", "00a0"], @["variableTop", "wxyz", "wxyz"], @["kr", "space-punct", "space-punct"], @["kr", "digit-spacepunct", "digit-spacepunct"]]
    for d in DATA:
        var keyword: String = d[0]
        var value: String = d[1]
        var expected: String = d[2]
        var legacyType: String = UCultureInfo.ToLegacyType(keyword, value)
assertEquals("keyword=" + keyword + ", value=" + value, expected, legacyType)
proc TestIsRightToLeft*() =
assertFalse("root LTR", UCultureInfo.InvariantCulture.IsRightToLeft)
assertFalse("zh LTR", UCultureInfo("zh").IsRightToLeft)
assertTrue("ar RTL", UCultureInfo("ar").IsRightToLeft)
assertTrue("und-EG RTL", UCultureInfo("und-EG").IsRightToLeft)
assertFalse("fa-Cyrl LTR", UCultureInfo("fa-Cyrl").IsRightToLeft)
assertTrue("en-Hebr RTL", UCultureInfo("en-Hebr").IsRightToLeft)
assertTrue("ckb RTL", UCultureInfo("ckb").IsRightToLeft)
assertFalse("fil LTR", UCultureInfo("fil").IsRightToLeft)
assertFalse("he-Zyxw LTR", UCultureInfo("he-Zyxw").IsRightToLeft)
proc TestChineseToLocale*() =
    var LOCALES: UCultureInfo[][] = @[@[UCultureInfo("zh"), UCultureInfo("zh")], @[UCultureInfo("zh_Hans"), UCultureInfo("zh_Hans")], @[UCultureInfo("zh_Hant"), UCultureInfo("zh_Hant")], @[UCultureInfo("zh_Hans_CN"), UCultureInfo("zh_Hans_CN")], @[UCultureInfo("zh_Hans_CN"), UCultureInfo("zh_Hans_CN")], @[UCultureInfo("zh_Hant_TW"), UCultureInfo("zh_Hant_TW")]]
    for pair in LOCALES:
        if pair[0].Equals(pair[1]):
assertEquals(pair[0].ToString, pair[0].ToCultureInfo, pair[1].ToCultureInfo)
        else:
Errln("Error: " + pair[0] + " is not equal to " + pair[1])
proc TestParent*(name: string, expectedParentName: string) =
    var culture: UCultureInfo = UCultureInfo(name)
Assert.AreEqual(UCultureInfo(expectedParentName), culture.Parent)
proc TestParent_ParentChain*() =
    var myExpectParentCulture: UCultureInfo = UCultureInfo("uz_Cyrl_UZ")
Assert.AreEqual("uz_Cyrl", myExpectParentCulture.Parent.Name)
Assert.AreEqual("uz", myExpectParentCulture.Parent.Parent.Name)
Assert.AreEqual("", myExpectParentCulture.Parent.Parent.Parent.Name)
proc TestTwoLetterISOLanguageName*(name: string, expected: string) =
Assert.AreEqual(expected, UCultureInfo(name).TwoLetterISOLanguageName)
proc NativeName_TestData*(): IEnumerable<object[]> =
    yield @[UCultureInfo.CurrentCulture.Name, UCultureInfo.CurrentCulture.NativeName]
    yield @["en_US", "English (United States)"]
    yield @["en_CA", "English (Canada)"]
proc TestNativeName*(name: string, expected: string) =
    var myTestCulture: UCultureInfo = UCultureInfo(name)
Assert.AreEqual(expected, myTestCulture.NativeName)
proc TestGetHashCode*(name: string) =
    var culture: UCultureInfo = UCultureInfo(name)
Assert.AreEqual(culture.GetHashCode, culture.GetHashCode)
proc Equals_TestData*(): IEnumerable<object[]> =
    var frFRCulture: UCultureInfo = UCultureInfo("fr_FR")
    yield @[frFRCulture, frFRCulture.Clone, true]
    yield @[frFRCulture, frFRCulture, true]
    yield @[UCultureInfo("en"), UCultureInfo("en"), true]
    yield @[UCultureInfo("en_US"), UCultureInfo("en_US"), true]
    yield @[UCultureInfo.InvariantCulture, UCultureInfo.InvariantCulture, true]
    yield @[UCultureInfo.InvariantCulture, UCultureInfo(""), true]
    yield @[UCultureInfo("en"), UCultureInfo("en_US"), false]
    yield @[UCultureInfo("en_US"), UCultureInfo("fr_FR"), false]
    yield @[UCultureInfo("en_US"), nil, false]
proc TestEquals*(culture: UCultureInfo, value: object, expected: bool) =
Assert.AreEqual(expected, culture.Equals(value))
proc TestChineseCharactersGH29*(cultureName: string) =
    CurrentCulture = CultureInfo(cultureName)
Assert.DoesNotThrow(<unhandled: nnkLambda>)