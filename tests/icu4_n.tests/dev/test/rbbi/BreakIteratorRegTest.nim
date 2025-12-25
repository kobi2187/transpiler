# "Namespace: ICU4N.Dev.Test.Rbbi"
type
  BreakIteratorRegTest = ref object


proc TestRegUnreg*() =
    var thailand_locale: CultureInfo = CultureInfo("th-TH")
    var jwbi: BreakIterator = BreakIterator.GetWordInstance(CultureInfo("ja"))
    var uwbi: BreakIterator = BreakIterator.GetWordInstance(CultureInfo("en-US"))
    var usbi: BreakIterator = BreakIterator.GetSentenceInstance(CultureInfo("en-US"))
    var twbi: BreakIterator = BreakIterator.GetWordInstance(thailand_locale)
    var rwbi: BreakIterator = BreakIterator.GetWordInstance(CultureInfo.InvariantCulture)
    var sbi: BreakIterator = cast[BreakIterator](usbi.Clone)
assertTrue(!BreakIterator.Unregister(""), "unregister before register")
    var key1: object = BreakIterator.RegisterInstance(sbi, CultureInfo("en-US"), BreakIterator.KIND_WORD)
    var key2: object = BreakIterator.RegisterInstance(cast[BreakIterator](twbi.Clone), CultureInfo("en-US"), BreakIterator.KIND_WORD)
      var test0: BreakIterator = BreakIterator.GetWordInstance(CultureInfo("ja"))
      var test1: BreakIterator = BreakIterator.GetWordInstance(CultureInfo("en-US"))
      var test2: BreakIterator = BreakIterator.GetSentenceInstance(CultureInfo("en-US"))
      var test3: BreakIterator = BreakIterator.GetWordInstance(thailand_locale)
assertEqual(test0, jwbi, "japan word == japan word")
assertEqual(test1, twbi, "us word == thai word")
assertEqual(test2, usbi, "us sentence == us sentence")
assertEqual(test3, twbi, "thai word == thai word")
assertTrue(BreakIterator.Unregister(key2), "unregister us word (thai word)")
assertTrue(!BreakIterator.Unregister(key2), "unregister second time")
    var error: bool = false
    try:
BreakIterator.Unregister(nil)
    except ArgumentException:
        error = true
assertTrue(error, "unregister null")
      var sci: CharacterIterator = BreakIterator.GetWordInstance(CultureInfo("en-US")).Text
      var len: int = sci.EndIndex - sci.BeginIndex
assertEqual(len, 0, "us word text: " + getString(sci))
assertEqual(BreakIterator.GetWordInstance(CultureInfo("en-US")), usbi, "us word == us sentence")
assertTrue(BreakIterator.Unregister(key1), "unregister us word (us sentence)")
      var test0: BreakIterator = BreakIterator.GetWordInstance(CultureInfo("ja"))
      var test1: BreakIterator = BreakIterator.GetWordInstance(CultureInfo("en-US"))
      var test2: BreakIterator = BreakIterator.GetSentenceInstance(CultureInfo("en-US"))
      var test3: BreakIterator = BreakIterator.GetWordInstance(thailand_locale)
assertEqual(test0, jwbi, "japanese word break")
assertEqual(test1, uwbi, "us sentence-word break")
assertEqual(test2, usbi, "us sentence break")
assertEqual(test3, twbi, "thai word break")
      var sci: CharacterIterator = test1.Text
      var len: int = sci.EndIndex - sci.BeginIndex
assertEqual(len, 0, "us sentence-word break text: " + getString(sci))
proc assertEqual(lhs: Object, rhs: Object, msg_: String) =
msg(msg_,     if lhs.Equals(rhs):
LOG
    else:
ERR, true, true)
proc assertEqual(lhs: int, rhs: int, msg_: String) =
msg(msg_,     if lhs == rhs:
LOG
    else:
ERR, true, true)
proc assertTrue(arg: bool, msg_: String) =
msg(msg_,     if arg:
LOG
    else:
ERR, true, true)
proc getString(ci: CharacterIterator): String =
    var buf: StringBuffer = StringBuffer(ci.EndIndex - ci.BeginIndex + 2)
buf.Append("'")
      var c: char = ci.First
      while c != CharacterIterator.Done:
buf.Append(c)
          c = ci.Next
buf.Append("'")
    return buf.ToString