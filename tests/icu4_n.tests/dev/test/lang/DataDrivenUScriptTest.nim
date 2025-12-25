# "Namespace: ICU4N.Dev.Test.Lang"
type
  DataDrivenUScriptTest = ref object


proc ScriptsToString(scripts: seq[int]): String =
    if scripts == nil:
        return "null"
    var sb: StringBuilder = StringBuilder
    for script in scripts:
        if sb.Length > 0:
sb.Append(' ')
sb.Append(UScript.GetShortName(script))
    return sb.ToString
proc AssertEqualScripts(msg: String, expectedScripts: seq[int], actualScripts: seq[int]) =
assertEquals(msg, ScriptsToString(expectedScripts), ScriptsToString(actualScripts))
type
  LocaleGetCodeTest = ref object


proc TestData(): IEnumerable =
    yield TestCaseData(UCultureInfo("en"), UScript.Latin)
    yield TestCaseData(UCultureInfo("en_US"), UScript.Latin)
    yield TestCaseData(UCultureInfo("sr"), UScript.Cyrillic)
    yield TestCaseData(UCultureInfo("ta"), UScript.Tamil)
    yield TestCaseData(UCultureInfo("te_IN"), UScript.Telugu)
    yield TestCaseData(UCultureInfo("hi"), UScript.Devanagari)
    yield TestCaseData(UCultureInfo("he"), UScript.Hebrew)
    yield TestCaseData(UCultureInfo("ar"), UScript.Arabic)
    yield TestCaseData(UCultureInfo("abcde"), UScript.InvalidCode)
    yield TestCaseData(UCultureInfo("abcde_cdef"), UScript.InvalidCode)
    yield TestCaseData(UCultureInfo("iw"), UScript.Hebrew)
proc TestLocaleGetCode*(testLocaleName: UCultureInfo, expected: int) =
    var code: int[] = UScript.GetCode(testLocaleName)
    if code == nil:
        if expected != UScript.InvalidCode:
Errln("Error testing UScript.getCode(). Got: null" + " Expected: " + expected + " for locale " + testLocaleName)

    elif code[0] != expected:
Errln("Error testing UScript.getCode(). Got: " + code[0] + " Expected: " + expected + " for locale " + testLocaleName)
    var esperanto: UCultureInfo = UCultureInfo("eo_DE")
      let resource = ThreadCultureChange(esperanto, esperanto)
<unhandled: nnkDefer>
      code = UScript.GetCode(esperanto)
      if code != nil:
          if code[0] != UScript.Latin:
Errln("Did not get the expected script code for Esperanto")
      else:
Warnln("Could not load the locale data.")
AssertEqualScripts("tg script: Cyrl", @[UScript.Cyrillic], UScript.GetCode(UCultureInfo("tg")))
AssertEqualScripts("xsr script: Deva", @[UScript.Devanagari], UScript.GetCode(UCultureInfo("xsr")))
AssertEqualScripts("ja scripts: Kana Hira Hani", @[UScript.Katakana, UScript.Hiragana, UScript.Han], UScript.GetCode(UCultureInfo("ja")))
AssertEqualScripts("ko scripts: Hang Hani", @[UScript.Hangul, UScript.Han], UScript.GetCode(UCultureInfo("ko")))
AssertEqualScripts("zh script: Hani", @[UScript.Han], UScript.GetCode(UCultureInfo("zh")))
AssertEqualScripts("zh-Hant scripts: Hani Bopo", @[UScript.Han, UScript.Bopomofo], UScript.GetCode(UCultureInfo("zh_Hant")))
AssertEqualScripts("zh-TW scripts: Hani Bopo", @[UScript.Han, UScript.Bopomofo], UScript.GetCode(UCultureInfo("zh_Hant_TW")))
AssertEqualScripts("ro-RO script: Latn", @[UScript.Latin], UScript.GetCode("ro-RO"))
type
  TestMultipleUScript = ref object


proc TestData(): IEnumerable =
    yield TestCaseData("ja", @[UScript.Katakana, UScript.Hiragana, UScript.Han], CultureInfo("ja"))
    yield TestCaseData("ko_KR", @[UScript.Hangul, UScript.Han], CultureInfo("ko-KR"))
    yield TestCaseData("zh", @[UScript.Han], CultureInfo("zh"))
    yield TestCaseData("zh_TW", @[UScript.Han, UScript.Bopomofo], CultureInfo("zh-TW"))
proc TestMultipleCodes*(testLocaleName: string, expected: seq[int], testLocale: CultureInfo) =
    var code: int[] = UScript.GetCode(testLocaleName)
    if code != nil:
          var j: int = 0
          while j < code.Length:
              if code[j] != expected[j]:
Errln("Error testing UScript.getCode(). Got: " + code[j] + " Expected: " + expected[j] + " for locale " + testLocaleName)
++j
    else:
Errln("Error testing UScript.getCode() for locale " + testLocaleName)
Logln("  Testing UScript.getCode(Locale) with locale: " + testLocale.DisplayName)
    code = UScript.GetCode(testLocale)
    if code != nil:
          var j: int = 0
          while j < code.Length:
              if code[j] != expected[j]:
Errln("Error testing UScript.getCode(). Got: " + code[j] + " Expected: " + expected[j] + " for locale " + testLocaleName)
++j
    else:
Errln("Error testing UScript.getCode() for locale " + testLocaleName)
type
  GetCodeTest = ref object


proc TestData(): IEnumerable =
    yield TestCaseData("en", UScript.Latin)
    yield TestCaseData("en_US", UScript.Latin)
    yield TestCaseData("sr", UScript.Cyrillic)
    yield TestCaseData("ta", UScript.Tamil)
    yield TestCaseData("gu", UScript.Gujarati)
    yield TestCaseData("te_IN", UScript.Telugu)
    yield TestCaseData("hi", UScript.Devanagari)
    yield TestCaseData("he", UScript.Hebrew)
    yield TestCaseData("ar", UScript.Arabic)
    yield TestCaseData("abcde", UScript.InvalidCode)
    yield TestCaseData("abscde_cdef", UScript.InvalidCode)
    yield TestCaseData("iw", UScript.Hebrew)
    yield TestCaseData("Hani", UScript.Han)
    yield TestCaseData("Hang", UScript.Hangul)
    yield TestCaseData("Hebr", UScript.Hebrew)
    yield TestCaseData("Hira", UScript.Hiragana)
    yield TestCaseData("Knda", UScript.Kannada)
    yield TestCaseData("Kana", UScript.Katakana)
    yield TestCaseData("Khmr", UScript.Khmer)
    yield TestCaseData("Lao", UScript.Lao)
    yield TestCaseData("Latn", UScript.Latin)
    yield TestCaseData("Mlym", UScript.Malayalam)
    yield TestCaseData("Mong", UScript.Mongolian)
    yield TestCaseData("CYRILLIC", UScript.Cyrillic)
    yield TestCaseData("DESERET", UScript.Deseret)
    yield TestCaseData("DEVANAGARI", UScript.Devanagari)
    yield TestCaseData("ETHIOPIC", UScript.Ethiopic)
    yield TestCaseData("GEORGIAN", UScript.Georgian)
    yield TestCaseData("GOTHIC", UScript.Gothic)
    yield TestCaseData("GREEK", UScript.Greek)
    yield TestCaseData("GUJARATI", UScript.Gujarati)
    yield TestCaseData("COMMON", UScript.Common)
    yield TestCaseData("INHERITED", UScript.Inherited)
    yield TestCaseData("malayalam", UScript.Malayalam)
    yield TestCaseData("mongolian", UScript.Mongolian)
    yield TestCaseData("myanmar", UScript.Myanmar)
    yield TestCaseData("ogham", UScript.Ogham)
    yield TestCaseData("old-italic", UScript.OldItalic)
    yield TestCaseData("oriya", UScript.Oriya)
    yield TestCaseData("runic", UScript.Runic)
    yield TestCaseData("sinhala", UScript.Sinhala)
    yield TestCaseData("syriac", UScript.Syriac)
    yield TestCaseData("tamil", UScript.Tamil)
    yield TestCaseData("telugu", UScript.Telugu)
    yield TestCaseData("thaana", UScript.Thaana)
    yield TestCaseData("thai", UScript.Thai)
    yield TestCaseData("tibetan", UScript.Tibetan)
    yield TestCaseData("Cans", UScript.CanadianAboriginal)
    yield TestCaseData("arabic", UScript.Arabic)
    yield TestCaseData("Yi", UScript.Yi)
    yield TestCaseData("Zyyy", UScript.Common)
proc TestGetCode*(testName: string, expected: int) =
    var code: int[] = UScript.GetCode(testName)
    if code == nil:
        if expected != UScript.InvalidCode:
Errln("Error testing UScript.getCode(). Got: null" + " Expected: " + expected + " for locale " + testName)

    elif code[0] != expected:
Errln("Error testing UScript.getCode(). Got: " + code[0] + " Expected: " + expected + " for locale " + testName)
type
  GetNameTest = ref object


proc TestData(): IEnumerable =
    yield TestCaseData(UScript.Cyrillic, "Cyrillic")
    yield TestCaseData(UScript.Deseret, "Deseret")
    yield TestCaseData(UScript.Devanagari, "Devanagari")
    yield TestCaseData(UScript.Ethiopic, "Ethiopic")
    yield TestCaseData(UScript.Georgian, "Georgian")
    yield TestCaseData(UScript.Gothic, "Gothic")
    yield TestCaseData(UScript.Greek, "Greek")
    yield TestCaseData(UScript.Gujarati, "Gujarati")
proc TestGetName*(testCode: int, expected: string) =
    var scriptName: String = UScript.GetName(testCode)
    if !expected.Equals(scriptName):
Errln("Error testing UScript.getName(). Got: " + scriptName + " Expected: " + expected)
type
  GetShortNameTest = ref object


proc TestData(): IEnumerable =
    yield TestCaseData(UScript.Han, "Hani")
    yield TestCaseData(UScript.Hangul, "Hang")
    yield TestCaseData(UScript.Hebrew, "Hebr")
    yield TestCaseData(UScript.Hiragana, "Hira")
    yield TestCaseData(UScript.Kannada, "Knda")
    yield TestCaseData(UScript.Katakana, "Kana")
    yield TestCaseData(UScript.Khmer, "Khmr")
    yield TestCaseData(UScript.Lao, "Laoo")
    yield TestCaseData(UScript.Latin, "Latn")
    yield TestCaseData(UScript.Malayalam, "Mlym")
    yield TestCaseData(UScript.Mongolian, "Mong")
proc TestGetShortName*(testCode: int, expected: string) =
    var shortName: string = UScript.GetShortName(testCode)
    if !expected.Equals(shortName):
Errln("Error testing UScript.getShortName(). Got: " + shortName + " Expected: " + expected)
type
  GetScriptTest = ref object


proc TestData(): IEnumerable =
    yield TestCaseData(65437, UScript.Katakana)
    yield TestCaseData(65470, UScript.Hangul)
    yield TestCaseData(65479, UScript.Hangul)
    yield TestCaseData(65487, UScript.Hangul)
    yield TestCaseData(65495, UScript.Hangul)
    yield TestCaseData(65500, UScript.Hangul)
    yield TestCaseData(66304, UScript.OldItalic)
    yield TestCaseData(66352, UScript.Gothic)
    yield TestCaseData(66378, UScript.Gothic)
    yield TestCaseData(66560, UScript.Deseret)
    yield TestCaseData(66600, UScript.Deseret)
    yield TestCaseData(119143, UScript.Inherited)
    yield TestCaseData(119163, UScript.Inherited)
    yield TestCaseData(119173, UScript.Inherited)
    yield TestCaseData(119210, UScript.Inherited)
    yield TestCaseData(131072, UScript.Han)
    yield TestCaseData(3330, UScript.Malayalam)
    yield TestCaseData(327685, UScript.Unknown)
    yield TestCaseData(0, UScript.Common)
    yield TestCaseData(119145, UScript.Inherited)
    yield TestCaseData(119170, UScript.Inherited)
    yield TestCaseData(119179, UScript.Inherited)
    yield TestCaseData(119213, UScript.Inherited)
proc TestGetScript*(codepoint: int, expected: int) =
    var code: int = UScript.InvalidCode
    code = UScript.GetScript(codepoint)
    if code != expected:
Errln("Error testing UScript.getScript(). Got: " + code + " Expected: " + expected + " for codepoint 0x + Hex(codepoint).")