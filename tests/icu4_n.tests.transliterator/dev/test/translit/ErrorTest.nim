# "Namespace: ICU4N.Dev.Test.Translit"
type
  ErrorTest = ref object


proc TestTransliteratorErrors*() =
    var trans: String = "Latin-Greek"
    var bogusID: String = "LATINGREEK-GREEKLATIN"
    var newID: String = "Bogus-Latin"
    var newIDRules: String = "zzz > Z; f <> ph"
    var bogusRules: String = "a } [b-g m-p "
    var testString: ReplaceableString = ReplaceableString("A quick fox jumped over the lazy dog.")
    var insertString: String = "cats and dogs"
      var stoppedAt: int = 0
      var len: int
    var pos: TransliterationPosition = TransliterationPosition
    var t: Transliterator = Transliterator.GetInstance(trans, Transliterator.Forward)
    if t == nil:
Errln("FAIL: construction of Latin-Greek")
        return
    len = testString.Length
    stoppedAt = t.Transliterate(testString, 0, 100)
    if stoppedAt != -1:
Errln("FAIL: Out of bounds check failed (1).")

    elif testString.Length != len:
        testString = ReplaceableString("A quick fox jumped over the lazy dog.")
Errln("FAIL: Transliterate fails and the target string was modified.")
    stoppedAt = t.Transliterate(testString, 100, testString.Length - 1)
    if stoppedAt != -1:
Errln("FAIL: Out of bounds check failed (2).")

    elif testString.Length != len:
        testString = ReplaceableString("A quick fox jumped over the lazy dog.")
Errln("FAIL: Transliterate fails and the target string was modified.")
    pos.Start = 100
    pos.Limit = testString.Length
    try:
t.Transliterate(testString, pos)
Errln("FAIL: Start offset is out of bounds, error not reported.")
    except ArgumentException:
Logln("Start offset is out of bounds and detected.")
    pos.Limit = 100
    pos.Start = 0
    try:
t.Transliterate(testString, pos)
Errln("FAIL: Limit offset is out of bounds, error not reported.
")
    except ArgumentException:
Logln("Start offset is out of bounds and detected.")
    len =     pos.ContextLimit = testString.Length
    pos.ContextStart = 0
    pos.Limit = len - 1
    pos.Start = 5
    try:
t.Transliterate(testString, pos, insertString)
        if len == pos.Limit:
Errln("FAIL: Test insertion with string: the transliteration position limit didn't change as expected.")
    except ArgumentException:
Errln("Insertion test with string failed for some reason.")
    pos.ContextStart = 0
    pos.ContextLimit = testString.Length
    pos.Limit = testString.Length - 1
    pos.Start = 5
    try:
t.Transliterate(testString, pos, 97)
        if len == pos.Limit:
Errln("FAIL: Test insertion with character: the transliteration position limit didn't change as expected.")
    except ArgumentException:
Errln("FAIL: Insertion test with UTF-16 code point failed for some reason.")
    len =     pos.Limit = testString.Length
    pos.ContextStart = 0
    pos.ContextLimit = testString.Length - 1
    pos.Start = 5
    try:
t.Transliterate(testString, pos, insertString)
Errln("FAIL: Out of bounds check failed (3).")
        if testString.Length != len:
Errln("FAIL: The input string was modified though the offsets were out of bounds.")
    except ArgumentException:
Logln("Insertion test with out of bounds indexes.")
    var t1: Transliterator = nil
    try:
        t1 = Transliterator.GetInstance(bogusID, Transliterator.Forward)
        if t1 != nil:
Errln("FAIL: construction of bogus ID "LATINGREEK-GREEKLATIN"")
    except ArgumentException:

    var t2: Transliterator = Transliterator.CreateFromRules(newID, newIDRules, Transliterator.Forward)
    try:
        var t3: Transliterator = t2.GetInverse
Errln("FAIL: The newID transliterator was not registered so createInverse should fail.")
        if t3 != nil:
Errln("FAIL: The newID transliterator was not registered so createInverse should fail.")
    except Exception:

    try:
        var t4: Transliterator = Transliterator.CreateFromRules(newID, bogusRules, Transliterator.Forward)
        if t4 != nil:
Errln("FAIL: The rules is malformed but error was not reported.")
    except Exception:

proc TestUnicodeSetErrors*() =
    var badPattern: String = "[[:L:]-[0x0300-0x0400]"
    var set: UnicodeSet = UnicodeSet
    if !set.IsEmpty:
Errln("FAIL: The default ctor of UnicodeSet created a non-empty object.")
    try:
set.ApplyPattern(badPattern)
Errln("FAIL: Applied a bad pattern to the UnicodeSet object okay.")
    except ArgumentException:
Logln("Test applying with the bad pattern.")
    try:
UnicodeSet(badPattern)
Errln("FAIL: Created a UnicodeSet based on bad patterns.")
    except ArgumentException:
Logln("Test constructing with the bad pattern.")
proc TestRBTErrors*() =
    var rules: String = "ab>y"
    var id: String = "MyRandom-YReverse"
    var goodPattern: String = "[[:L:]&[\u0000-\uFFFF]]"
    var set: UnicodeSet = nil
    try:
        set = UnicodeSet(goodPattern)
        try:
            var t: Transliterator = Transliterator.CreateFromRules(id, rules, Transliterator.Reverse)
            t.Filter = set
Transliterator.RegisterType(id, t.GetType, nil)
Transliterator.Unregister(id)
            try:
Transliterator.GetInstance(id, Transliterator.Reverse)
Errln("FAIL: construction of unregistered ID should have failed.")
            except ArgumentException:

        except ArgumentException:
Errln("FAIL: Was not able to create a good RBT to test registration.")
    except ArgumentException:
Errln("FAIL: Was not able to create a good UnicodeSet based on valid patterns.")
        return