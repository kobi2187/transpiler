# "Namespace: ICU4N.Support.Resources"
type
  SatelliteAssemblyTest = ref object
    localeCultures: IList[string] = List<string>
    collCultures: IList[string] = List<string>
    currCultures: IList[string] = List<string>
    regionCultures: IList[string] = List<string>
    langCultures: IList[string] = List<string>
    translitCultures: IList[string] = List<string>

proc newSatelliteAssemblyTest(): SatelliteAssemblyTest =
  var assembly = type(ICU4N.ICUConfig).Assembly.GetSatelliteAssembly(CultureInfo.InvariantCulture)
LoadManifest(assembly, "data.fullLocaleNames.lst", localeCultures)
LoadManifest(assembly, "data.coll.fullLocaleNames.lst", collCultures)
LoadManifest(assembly, "data.curr.fullLocaleNames.lst", currCultures)
LoadManifest(assembly, "data.region.fullLocaleNames.lst", regionCultures)
LoadManifest(assembly, "data.lang.fullLocaleNames.lst", langCultures)
LoadManifest(assembly, "data.translit.fullLocaleNames.lst", translitCultures)
proc LoadManifest*(assembly: Assembly, manifestName: string, result: IList[string]) =
    var locales = assembly.GetManifestResourceStream(manifestName)
    var line: string
    var reader = StreamReader(locales)
    while     line = reader.ReadLine != nil:
result.Add(line.Trim)
proc LocaleCultures(): IEnumerable[TestCaseData] =
    for culture in localeCultures:
      yield TestCaseData(culture)
proc CollationCultures(): IEnumerable[TestCaseData] =
    for culture in collCultures:
      yield TestCaseData(culture)
proc CurrencyCultures(): IEnumerable[TestCaseData] =
    for culture in currCultures:
      yield TestCaseData(culture)
proc RegionCultures(): IEnumerable[TestCaseData] =
    for culture in regionCultures:
      yield TestCaseData(culture)
proc LanguageCultures(): IEnumerable[TestCaseData] =
    for culture in langCultures:
      yield TestCaseData(culture)
proc TransliteratorCultures(): IEnumerable[TestCaseData] =
    for culture in translitCultures:
      yield TestCaseData(culture)
proc TestLoadInvariantAssembly*() =
    var assembly = type(ICU4N.ICUConfig).Assembly.GetSatelliteAssembly(CultureInfo.InvariantCulture)
assertNotNull(string.Empty, assembly)
proc TestLoadLocaleAssemblies*(locale: string) =
    var assembly = type(ICU4N.ICUConfig).Assembly.GetSatelliteAssembly(ResourceCultureInfo(ResourceUtil.GetDotNetNeutralCultureName(locale.AsSpan)))
assertNotNull(string.Empty, assembly)