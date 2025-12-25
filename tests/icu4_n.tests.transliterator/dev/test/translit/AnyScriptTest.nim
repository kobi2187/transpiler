# "Namespace: ICU4N.Dev.Test.Translit"
type
  AnyScriptTest = ref object


proc TestContext*() =
    var t: Transliterator = Transliterator.CreateFromRules("foo", "::[bc]; a{b}d > B;", Transliterator.Forward)
    var sample: String = "abd abc b"
assertEquals("context works", "aBd abc b", t.Transform(sample))
proc TestScripts*() =
    var testBuffer: StringBuffer = StringBuffer
    var charBuffer: Span<char> = newSeq[char](2)
      var script: int = 0
      while script < UScript.CodeLimit:
          var test: UnicodeSet = UnicodeSet.ApplyPropertyAlias("script", UScript.GetName(script))
          var count: int = Math.Min(20, test.Count)
            var i: int = 0
            while i < count:
testBuffer.Append(UTF16.ValueOf(test[i], charBuffer))
++i
++script
      var test: String = testBuffer.ToString
Logln("Test line: " + test)
      var inclusion: int = TestFmwk.GetExhaustiveness
      var testedUnavailableScript: bool = false
        var script: int = 0
        while script < UScript.CodeLimit:
            if script == UScript.Common || script == UScript.Inherited:
                continue
            if inclusion < 10 && script != UScript.Latin && script != UScript.Han && script != UScript.Hiragana && testedUnavailableScript:
                continue
            var scriptName: String = UScript.GetName(script)
            var locale: UCultureInfo = UCultureInfo(scriptName)
            if locale.Language.Equals("new") || locale.Language.Equals("pau"):
                if logKnownIssue("11171", "long script name loosely looks like a locale ID with a known likely script"):
                    continue
            var t: Transliterator
            try:
                t = Transliterator.GetInstance("any-" + scriptName)
            except Exception:
                testedUnavailableScript = true
Logln("Skipping unavailable: " + scriptName)
                continue
Logln("Checking: " + scriptName)
            if t != nil:
t.Transform(test)
            var shortScriptName: String = UScript.GetShortName(script)
            try:
                t = Transliterator.GetInstance("any-" + shortScriptName)
            except Exception:
Errln("Transliterator.GetInstance() worked for "any-" + scriptName + "" but not for "any-" + shortScriptName + '"')
t.Transform(test)
++script
proc TestScriptsUsingTry*() =
    var testBuffer: StringBuffer = StringBuffer
    var charBuffer: Span<char> = newSeq[char](2)
      var script: int = 0
      while script < UScript.CodeLimit:
          if UScript.TryGetName(script,           var name: ReadOnlySpan<char>):
              var test: UnicodeSet = UnicodeSet.ApplyPropertyAlias("script", name.ToString)
              var count: int = Math.Min(20, test.Count)
                var i: int = 0
                while i < count:
testBuffer.Append(UTF16.ValueOf(test[i], charBuffer))
++i
++script
      var test: string = testBuffer.ToString
Logln("Test line: " + test)
      var inclusion: int = TestFmwk.GetExhaustiveness
      var testedUnavailableScript: bool = false
        var script: int = 0
        while script < UScript.CodeLimit:
            if script == UScript.Common || script == UScript.Inherited:
                continue
            if inclusion < 10 && script != UScript.Latin && script != UScript.Han && script != UScript.Hiragana && testedUnavailableScript:
                continue
            var scriptName: string = nil
            if UScript.TryGetName(script,             var scriptNameSpan: ReadOnlySpan<char>):
                scriptName = scriptNameSpan.ToString
                var locale: UCultureInfo = UCultureInfo(scriptName)
                if locale.Language.Equals("new") || locale.Language.Equals("pau"):
                    if logKnownIssue("11171", "long script name loosely looks like a locale ID with a known likely script"):
                        continue
            var t: Transliterator
            try:
                t = Transliterator.GetInstance("any-" + scriptName)
            except Exception:
                testedUnavailableScript = true
Logln("Skipping unavailable: " + scriptName)
                continue
Logln("Checking: " + scriptName)
            if t != nil:
t.Transform(test)
            var shortScriptName: string = ""
            if UScript.TryGetName(script, scriptNameSpan):
                scriptName = scriptNameSpan.ToString
                try:
                    t = Transliterator.GetInstance("any-" + shortScriptName)
                except Exception:
Errln("Transliterator.GetInstance() worked for "any-" + scriptName + "" but not for "any-" + shortScriptName + '"')
t.Transform(test)
++script
proc TestForWidth*() =
    var widen: Transliterator = Transliterator.GetInstance("halfwidth-fullwidth")
    var narrow: Transliterator = Transliterator.GetInstance("fullwidth-halfwidth")
    var ASCII: UnicodeSet = UnicodeSet("[:ascii:]")
    var lettersAndSpace: string = "abc def"
    var punctOnly: string = "( )"
    var wideLettersAndSpace: String = widen.Transform(lettersAndSpace)
    var widePunctOnly: String = widen.Transform(punctOnly)
assertContainsNone("Should be wide", ASCII, wideLettersAndSpace)
assertContainsNone("Should be wide", ASCII, widePunctOnly)
    var back: String
    back = narrow.Transform(wideLettersAndSpace)
assertEquals("Should be narrow", lettersAndSpace, back)
    back = narrow.Transform(widePunctOnly)
assertEquals("Should be narrow", punctOnly, back)
    var latin: Transliterator = Transliterator.GetInstance("any-Latn")
    back = latin.Transform(wideLettersAndSpace)
assertEquals("Should be ascii", lettersAndSpace, back)
    back = latin.Transform(widePunctOnly)
assertEquals("Should be ascii", punctOnly, back)
proc TestCommonDigits*() =
    var westernDigitSet: UnicodeSet = UnicodeSet("[0-9]")
    var westernDigitSetAndMarks: UnicodeSet = UnicodeSet("[[0-9][:Mn:]]")
    var arabicDigitSet: UnicodeSet = UnicodeSet("[[:Nd:]&[:block=Arabic:]]")
    var latin: Transliterator = Transliterator.GetInstance("Any-Latn")
    var arabic: Transliterator = Transliterator.GetInstance("Any-Arabic")
    var westernDigits: String = getList(westernDigitSet)
    var arabicDigits: String = getList(arabicDigitSet)
    var fromArabic: String = latin.Transform(arabicDigits)
assertContainsAll("Any-Latin transforms Arabic digits", westernDigitSetAndMarks, fromArabic)
    if false:
        var fromLatin: String = arabic.Transform(westernDigits)
assertContainsAll("Any-Arabic transforms Western digits", arabicDigitSet, fromLatin)
proc assertContainsAll(message: String, set: UnicodeSet, str: String) =
handleAssert(set.ContainsAll(str), message, set, str, "contains all of", false)
proc assertContainsNone(message: String, set: UnicodeSet, str: String) =
handleAssert(set.ContainsNone(str), message, set, str, "contains none of", false)
proc getList(set: UnicodeSet): String =
    var result: StringBuffer = StringBuffer
      var it: UnicodeSetIterator = UnicodeSetIterator(set)
      while it.Next:
result.Append(it.GetString)
    return result.ToString