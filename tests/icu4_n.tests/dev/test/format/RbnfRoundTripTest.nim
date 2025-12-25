# "Namespace: ICU4N.Dev.Test.Format"
type
  RbnfRoundTripTest = ref object


proc TestEnglishSpelloutRT*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("en-US"), NumberPresentation.SpellOut)
doTest(formatter, -12345678, 12345678)
proc TestDurationsRT*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("en-US"), NumberPresentation.Duration)
doTest(formatter, 0, 12345678)
proc TestSpanishSpelloutRT*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("es-es"), NumberPresentation.SpellOut)
doTest(formatter, -12345678, 12345678)
proc TestFrenchSpelloutRT*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("fr-FR"), NumberPresentation.SpellOut)
doTest(formatter, -12345678, 12345678)
proc TestSwissFrenchSpelloutRT*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("fr-CH"), NumberPresentation.SpellOut)
doTest(formatter, -12345678, 12345678)
proc TestItalianSpelloutRT*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("it-IT"), NumberPresentation.SpellOut)
doTest(formatter, -999999, 999999)
proc TestGermanSpelloutRT*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("de-DE"), NumberPresentation.SpellOut)
doTest(formatter, 0, 12345678)
proc TestSwedishSpelloutRT*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("sv-SE"), NumberPresentation.SpellOut)
doTest(formatter, 0, 12345678)
proc TestDutchSpelloutRT*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("nl-NL"), NumberPresentation.SpellOut)
doTest(formatter, -12345678, 12345678)
proc TestJapaneseSpelloutRT*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("ja-JP"), NumberPresentation.SpellOut)
doTest(formatter, 0, 12345678)
proc TestRussianSpelloutRT*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("ru-RU"), NumberPresentation.SpellOut)
doTest(formatter, 0, 12345678)
proc TestGreekSpelloutRT*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("el-GR"), NumberPresentation.SpellOut)
doTest(formatter, 0, 12345678)
proc TestHebrewNumberingRT*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("he-IL"), NumberPresentation.NumberingSystem)
formatter.SetDefaultRuleSet("%hebrew")
doTest(formatter, 0, 12345678)
proc TestEnglishNumberingRT*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("en"), NumberPresentation.NumberingSystem)
formatter.SetDefaultRuleSet("%roman-upper")
doTest(formatter, 0, 12345678)
proc doTest(formatter: RuleBasedNumberFormat, lowLimit: long, highLimit: long) =
    try:
        var count: long = 0
        var increment: long = 1
          var i: long = lowLimit
          while i <= highLimit:
              if count % 1000 == 0:
Logln(i.ToString(CultureInfo.InvariantCulture))
              if Math.Abs(i) < 5000:
                increment = 1

              elif Math.Abs(i) < 500000:
                increment = 2737
              else:
                increment = 267437
              var text: string = formatter.Format(i)
              var rt: long = formatter.Parse(text).ToInt64
              if rt != i:
Errln("Round-trip failed: " + i + " -> " + text + " -> " + rt)
++count
              i = increment
        if lowLimit < 0:
            var d: double = 1.234
            while d < 1000:
                var text: string = formatter.Format(d)
                var rt: double = formatter.Parse(text).ToDouble
                if rt != d:
Errln("Round-trip failed: " + d + " -> " + text + " -> " + rt)
                d = 10
    except Exception:
Errln("Test failed with exception: " + e.ToString)
proc doTest(formatterSettings: RbnfFormattterSettings, lowLimit: long, highLimit: long) =
    var formatter: RuleBasedNumberFormat = formatterSettings.formatter
    try:
        var count: long = 0
        var increment: long = 1
          var i: long = lowLimit
          while i <= highLimit:
              if count % 1000 == 0:
Logln(i.ToString(CultureInfo.InvariantCulture))
              if Math.Abs(i) < 5000:
                increment = 1

              elif Math.Abs(i) < 500000:
                increment = 2737
              else:
                increment = 267437
              var text: string = formatter.Format(i)
              var rt: long = formatter.Parse(text).ToInt64
              if rt != i:
Errln("Round-trip failed: " + i + " -> " + text + " -> " + rt)
++count
              i = increment
        if lowLimit < 0:
            var d: double = 1.234
            while d < 1000:
                var text: string = formatter.Format(d)
                var rt: double = formatter.Parse(text).ToDouble
                if rt != d:
Errln("Round-trip failed: " + d + " -> " + text + " -> " + rt)
                d = 10
    except Exception:
Errln("Test failed with exception: " + e.ToString)
    try:
        var count: long = 0
        var increment: long = 1
          var i: long = lowLimit
          while i <= highLimit:
              if count % 1000 == 0:
Logln(i.ToString(CultureInfo.InvariantCulture))
              if Math.Abs(i) < 5000:
                increment = 1

              elif Math.Abs(i) < 500000:
                increment = 2737
              else:
                increment = 267437
              var text: string = formatterSettings.FormatWithIcuNumber(i)
              var rt: long = formatter.Parse(text).ToInt64
              if rt != i:
Errln("Round-trip failed: " + i + " -> " + text + " -> " + rt)
++count
              i = increment
        if lowLimit < 0:
            var d: double = 1.234
            while d < 1000:
                var text: string = formatterSettings.FormatWithIcuNumber(d)
                var rt: double = formatter.Parse(text).ToDouble
                if rt != d:
Errln("Round-trip failed: " + d + " -> " + text + " -> " + rt)
                d = 10
    except Exception:
Errln("Test failed with exception: " + e.ToString)