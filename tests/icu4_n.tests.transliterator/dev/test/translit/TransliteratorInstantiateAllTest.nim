# "Namespace: ICU4N.Dev.Test.Translit"
type
  TransliteratorInstantiateAllTest = ref object


proc TestData(): IEnumerable =
    for e in Transliterator.GetAvailableIDs:
        yield e
proc TestInstantiation*(testTransliteratorID: string) =
    var t: Transliterator = nil
    try:
        t = Transliterator.GetInstance(testTransliteratorID)
    except ArgumentException:
Errln("FAIL: " + testTransliteratorID)
        raise
    if t != nil:
        var rules: String = nil
        try:
            rules = t.ToRules(true)
Transliterator.CreateFromRules("x", rules, Transliterator.Forward)
        except ArgumentException:
Errln("FAIL: " + "ID" + ".toRules() => bad rules: " + rules)
            raise