# "Namespace: ICU4N.Dev.Test.Translit"
type
  ReplaceableTest = ref object


proc Test*() =
Check("Lower", "ABCD", "1234")
Check("Upper", "abcdß", "123455")
Check("Title", "aBCD", "1234")
Check("NFC", "ÀÈ", "13")
Check("NFD", "ÀÈ", "1122")
Check("*(x) > A $1 B", "wxy", "11223")
Check("*(x)(y) > A $2 B $1 C $2 D", "wxyz", "113322334")
Check("*(x)(y)(z) > A $3 B $2 C $1 D", "wxyzu", "114433225")
Check("*x > a", "xyz", "223")
Check("*x > a", "wxy", "113")
Check("*x > a", "￿xy", "_33")
Check("*(x) > A $1 B", "￿xy", "__223")
proc Check(transliteratorName: String, test: String, shouldProduceStyles: String) =
    var tr: TestReplaceable = TestReplaceable(test, nil)
    var original: String = tr.ToString
    var t: Transliterator
    if transliteratorName.StartsWith("*", StringComparison.Ordinal):
        transliteratorName = transliteratorName.Substring(1)
        t = Transliterator.CreateFromRules("test", transliteratorName, Transliterator.Forward)
    else:
        t = Transliterator.GetInstance(transliteratorName)
t.Transliterate(tr)
    var newStyles: String = tr.GetStyles
    if !newStyles.Equals(shouldProduceStyles):
Errln("FAIL Styles: " + transliteratorName + " ( " + original + " ) => " + tr.ToString + "; should be {" + shouldProduceStyles + "}!")
    else:
Logln("OK: " + transliteratorName + " ( " + original + " ) => " + tr.ToString)
    if !tr.HasMetaData || tr.Chars.HasMetaData || tr.Styles.HasMetaData:
Errln("Fail hasMetaData()")
type
  TestReplaceable = ref object
    Chars: ReplaceableString
    Styles: ReplaceableString
    NO_STYLE: char = '_'
    NO_STYLE_MARK: char = cast[char](65535)
    DEBUG: bool = false

proc newTestReplaceable(text: String, styles: String): TestReplaceable =
  Chars = ReplaceableString(text)
  var s: StringBuffer = StringBuffer
    var i: int = 0
    while i < text.Length:
        if styles != nil && i < styles.Length:
s.Append(styles[i])
        else:
            if text[i] == NO_STYLE_MARK:
s.Append(NO_STYLE)
            else:
s.Append(cast[char](i + '1'))
++i
  self.Styles = ReplaceableString(s.ToString)
proc GetStyles*(): String =
    return Styles.ToString
proc ToString*(): String =
    return Chars.ToString + "{" + Styles.ToString + "}"
proc Substring*(start: int, length: int): String =
    return Chars.Substring(start, length)
proc AsSpan*(start: int, length: int): ReadOnlySpan<char> =
    return Chars.AsSpan(start, length)
proc Length(): int =
    return Chars.Length

proc Char32At*(offset: int): int =
    return Chars.Char32At(offset)
proc CopyTo*(sourceIndex: int, destination: seq[char], destinationIndex: int, count: int) =
Chars.CopyTo(sourceIndex, destination, destinationIndex, count)
proc CopyTo*(sourceIndex: int, destination: Span[char], count: int) =
Chars.CopyTo(sourceIndex, destination, count)
proc Replace*(startIndex: int, count: int, text: string) =
    if Substring(startIndex, count).Equals(text):
      return
    if DEBUG:
Console.Out.Write(Utility.Escape(ToString + " -> replace(" + startIndex + "," + count + "," + text) + ") -> ")
Chars.Replace(startIndex, count, text)
fixStyles(startIndex, count, text.Length)
    if DEBUG:
Console.Out.Write(Utility.Escape(ToString))
proc Replace*(startIndex: int, count: int, span: ReadOnlySpan[char]) =
    if AsSpan(startIndex, count).Equals(span, StringComparison.Ordinal):
      return
self.Chars.Replace(startIndex, count, span)
fixStyles(startIndex, count, span.Length)
proc fixStyles(start: int, count: int, newLen: int) =
    var limit: int = start + count
    var newStyle: char = NO_STYLE
    if start != limit && Styles[start] != NO_STYLE:
        newStyle = Styles[start]

    elif start > 0 && self[start - 1] != NO_STYLE_MARK:
        newStyle = Styles[start - 1]
    else:
      if limit < Styles.Length:
          newStyle = Styles[limit]
    var s: StringBuffer = StringBuffer
      var i: int = 0
      while i < newLen:
          if self[start + i] == NO_STYLE_MARK:
s.Append(NO_STYLE)
          else:
s.Append(newStyle)
++i
Styles.Replace(start, count, s.ToString)
proc Copy*(startIndex: int, length: int, destinationIndex: int) =
Chars.Copy(startIndex, length, destinationIndex)
Styles.Copy(startIndex, length, destinationIndex)
proc HasMetaData(): bool =
    return true
proc Test5789*() =
    var rules: String = "IETR > IET | \' R; # (1) do split ietr between t and r
" + "I[EH] > I; # (2) friedrich"
    var trans: Transliterator = Transliterator.CreateFromRules("foo", rules, Transliterator.Forward)
    var result: String = trans.Transliterate("BLENKDIETRICH")
assertEquals("Rule breakage", "BLENKDIET'RICH", result)