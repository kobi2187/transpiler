# "Namespace: ICU4N.Dev.Test.Format"
type
  PluralRangesTest = ref object


proc TestLocaleData*() =
    var tests: string[][] = @[@["de", "other", "one", "one"], @["xxx", "few", "few", "few"], @["de", "one", "other", "other"], @["de", "other", "one", "one"], @["de", "other", "other", "other"], @["ro", "one", "few", "few"], @["ro", "one", "other", "other"], @["ro", "few", "one", "few"]]
    for test in tests:
        var locale: UCultureInfo = UCultureInfo(test[0])
StandardPluralUtil.TryGetValue(test[1],         var start: StandardPlural)
StandardPluralUtil.TryGetValue(test[2],         var end: StandardPlural)
StandardPluralUtil.TryGetValue(test[3],         var expected: StandardPlural)
        var pluralRanges: PluralRanges = PluralRulesFactory.DefaultFactory.GetPluralRanges(locale)
        var actual: StandardPlural = pluralRanges.Get(start, end)
assertEquals("Deriving range category", expected, actual)
proc TestRangePattern*() =

proc TestFormatting*() =

proc TestBasic*() =
    var a: PluralRanges = PluralRanges
a.Add(StandardPlural.One, StandardPlural.Other, StandardPlural.One)
    var actual: StandardPlural = a.Get(StandardPlural.One, StandardPlural.Other)
assertEquals("range", StandardPlural.One, actual)
a.Freeze
    try:
a.Add(StandardPlural.One, StandardPlural.One, StandardPlural.One)
Errln("Failed to cause exception on frozen instance")
    except NotSupportedException:
