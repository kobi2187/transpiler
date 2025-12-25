# "Namespace: ICU4N.Dev.Test.Util"
type
  ICUResourceBundleCollationTest = ref object
    COLLATION_RESNAME: String = "collations"
    COLLATION_KEYWORD: String = "collation"
    DEFAULT_NAME: String = "default"
    STANDARD_NAME: String = "standard"

proc TestFunctionalEquivalent*() =
    var collCases: String[] = @["f", "sv_US_CALIFORNIA", "sv", "f", "zh_TW@collation=stroke", "zh@collation=stroke", "f", "zh_Hant_TW@collation=stroke", "zh@collation=stroke", "f", "sv_CN@collation=pinyin", "sv", "t", "zh@collation=pinyin", "zh", "f", "zh_CN@collation=pinyin", "zh", "f", "zh_Hans_CN@collation=pinyin", "zh", "f", "zh_HK@collation=pinyin", "zh", "f", "zh_Hant_HK@collation=pinyin", "zh", "f", "zh_HK@collation=stroke", "zh@collation=stroke", "f", "zh_Hant_HK@collation=stroke", "zh@collation=stroke", "f", "zh_HK", "zh@collation=stroke", "f", "zh_Hant_HK", "zh@collation=stroke", "f", "zh_MO", "zh@collation=stroke", "f", "zh_Hant_MO", "zh@collation=stroke", "f", "zh_TW_STROKE", "zh@collation=stroke", "f", "zh_TW_STROKE@collation=big5han", "zh@collation=big5han", "f", "sv_CN@calendar=japanese", "sv", "t", "sv@calendar=japanese", "sv", "f", "zh_TW@collation=big5han", "zh@collation=big5han", "f", "zh_Hant_TW@collation=big5han", "zh@collation=big5han", "f", "zh_TW@collation=gb2312han", "zh@collation=gb2312han", "f", "zh_Hant_TW@collation=gb2312han", "zh@collation=gb2312han", "f", "zh_CN@collation=big5han", "zh@collation=big5han", "f", "zh_Hans_CN@collation=big5han", "zh@collation=big5han", "f", "zh_CN@collation=gb2312han", "zh@collation=gb2312han", "f", "zh_Hans_CN@collation=gb2312han", "zh@collation=gb2312han", "t", "zh@collation=big5han", "zh@collation=big5han", "t", "zh@collation=gb2312han", "zh@collation=gb2312han", "t", "hi@collation=standard", "hi", "f", "hi_AU@collation=standard;currency=CHF;calendar=buddhist", "hi", "f", "sv_SE@collation=pinyin", "sv", "f", "sv_SE_BONN@collation=pinyin", "sv", "t", "nl", "root", "f", "nl_NL", "root", "f", "nl_NL_EEXT", "root", "t", "nl@collation=stroke", "root", "f", "nl_NL@collation=stroke", "root", "f", "nl_NL_EEXT@collation=stroke", "root"]
Logln("Testing functional equivalents for collation...")
    var assembly: Assembly = type(Collator).Assembly
getFunctionalEquivalentTestCases(ICUData.IcuCollationBaseName, assembly, COLLATION_RESNAME, COLLATION_KEYWORD, true, collCases)
proc TestGetWithFallback*() =
    var bundle: ICUResourceBundle = nil
    var key: String = nil
    try:
        bundle = cast[ICUResourceBundle](UResourceBundle.GetBundleInstance(ICUData.IcuCollationBaseName, UCultureInfo.Canonicalize("de__PHONEBOOK")))
        if !bundle.UCulture.FullName.Equals("de"):
Errln("did not get the expected bundle")
        key = bundle.GetStringWithFallback("collations/collation/default")
        if !key.Equals("phonebook"):
Errln("Did not get the expected result from getStringWithFallback method.")
    except MissingManifestResourceException:
Logln("got the expected exception")
    bundle = cast[ICUResourceBundle](UResourceBundle.GetBundleInstance(ICUData.IcuCollationBaseName, "fr_FR"))
    key = bundle.GetStringWithFallback("collations/default")
    if !key.Equals("standard"):
Errln("Did not get the expected result from getStringWithFallback method.")
proc TestKeywordValues*() =
    var kwVals: String[]
    var foundStandard: bool = false
    var n: int
Logln("Testing getting collation values:")
    kwVals = ICUResourceBundle.GetKeywordValues(ICUData.IcuCollationBaseName, COLLATION_RESNAME, ICUResourceBundle.IcuDataAssembly)
      n = 0
      while n < kwVals.Length:
Logln(n.ToString(CultureInfo.InvariantCulture) + ": " + kwVals[n])
          if DEFAULT_NAME.Equals(kwVals[n]):
Errln("getKeywordValues for collation returned 'default' in the list.")

          elif STANDARD_NAME.Equals(kwVals[n]):
              if foundStandard == false:
                  foundStandard = true
Logln("found 'standard'")
              else:
Errln("Error - 'standard' is in the keyword list twice!")
++n
    if foundStandard == false:
Errln("Error - 'standard' was not in the collation tree as a keyword.")
    else:
Logln("'standard' was found as a collation keyword.")
proc TestOpen*() =
    var bundle: UResourceBundle = UResourceBundle.GetBundleInstance(ICUData.IcuCollationBaseName, "en_US_POSIX")
    if bundle == nil:
Errln("could not load the stream")
proc getFunctionalEquivalentTestCases(path: String, cl: Assembly, resName: String, keyword: String, truncate: bool, testCases: seq[String]) =
    var T_STR: String = "t"
Logln("Testing functional equivalents...")
      var i: int = 0
      while i < testCases.Length:
          var expectAvail: bool = T_STR.Equals(testCases[i + 0])
          var inLocale: UCultureInfo = UCultureInfo(testCases[i + 1])
          var expectLocale: UCultureInfo = UCultureInfo(testCases[i + 2])
Logln(cast[int](i / 3).ToString(CultureInfo.InvariantCulture) + ": " + expectAvail.ToString + "		" + inLocale.ToString + "		" + expectLocale.ToString)
          var equivLocale: UCultureInfo = ICUResourceBundle.GetFunctionalEquivalent(path, cl, resName, keyword, inLocale,           var gotAvail: bool, truncate)
          if gotAvail != expectAvail || !equivLocale.Equals(expectLocale):
Errln(cast[int](i / 3).ToString(CultureInfo.InvariantCulture) + ":  Error, expected  Equiv=" + expectAvail.ToString + "		" + inLocale.ToString + "		--> " + expectLocale.ToString + ",  but got " + gotAvail.ToString + " " + equivLocale.ToString)
          i = 3