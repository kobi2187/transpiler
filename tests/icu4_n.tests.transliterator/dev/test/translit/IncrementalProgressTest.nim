# "Namespace: ICU4N.Dev.Test.Translit"
type
  IncrementalProgressTest = ref object


proc TestData(): IEnumerable =
    var latinTest: String = "The Quick Brown Fox."
    var devaTest: String = Transliterator.GetInstance("Latin-Devanagari").Transliterate(latinTest)
    var kataTest: String = Transliterator.GetInstance("Latin-Katakana").Transliterate(latinTest)
    yield TestCaseData("Any", latinTest)
    yield TestCaseData("Latin", latinTest)
    yield TestCaseData("Halfwidth", latinTest)
    yield TestCaseData("Devanagari", devaTest)
    yield TestCaseData("Katakana", kataTest)
proc CheckIncrementalAux*(t: Transliterator, input: String) =
    var test: IReplaceable = ReplaceableString(input)
    var pos: TransliterationPosition = TransliterationPosition(0, test.Length, 0, test.Length)
t.Transliterate(test, pos)
    var gotError: bool = false
    if pos.Start == 0 && pos.Limit != 0 && !t.ID.Equals("Hex-Any/Unicode"):
Errln("No Progress, " + t.ID + ": " + UtilityExtensions.FormatInput(test, pos))
        gotError = true
    else:
Logln("PASS Progress, " + t.ID + ": " + UtilityExtensions.FormatInput(test, pos))
t.FinishTransliteration(test, pos)
    if pos.Start != pos.Limit:
Errln("Incomplete, " + t.ID + ":  " + UtilityExtensions.FormatInput(test, pos))
        gotError = true
    if !gotError:

proc TestIncrementalProgress*(lang: string, text: string) =
    var targets = Transliterator.GetAvailableTargets(lang)
    for target in targets:
        var variants = Transliterator.GetAvailableVariants(lang, target)
        for variant in variants:
            var id: String = lang + "-" + target + "/" + variant
Logln("id: " + id)
            var t: Transliterator = Transliterator.GetInstance(id)
CheckIncrementalAux(t, text)
            var rev: String = t.Transliterate(text)
            if id.Equals("Devanagari-Arabic/"):
              continue
            var inv: Transliterator = t.GetInverse
CheckIncrementalAux(inv, rev)