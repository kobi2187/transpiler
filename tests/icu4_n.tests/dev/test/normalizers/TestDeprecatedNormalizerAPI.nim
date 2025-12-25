# "Namespace: ICU4N.Dev.Test.Normalizers"
type
  TestDeprecatedNormalizerAPI = ref object


proc newTestDeprecatedNormalizerAPI(): TestDeprecatedNormalizerAPI =

proc TestNormalizerAPI*() =
    var s: string = Utility.Unescape("ä가\U0002f800")
    var iter: CharacterIterator = StringCharacterIterator(s + s)
    var norm: Normalizer = Normalizer(iter, NormalizerMode.NFC, 0)
    if norm.Next != 228:
Errln("error in Normalizer(CharacterIterator).next()")
    var norm2: Normalizer = Normalizer(s, NormalizerMode.NFC, 0)
    if norm2.Next != 228:
Errln("error in Normalizer(CharacterIterator).next()")
    var clone: Normalizer = cast[Normalizer](norm.Clone)
    if clone.GetBeginIndex != norm.GetBeginIndex:
Errln("error in Normalizer.getBeginIndex()")
    if clone.GetEndIndex != norm.GetEndIndex:
Errln("error in Normalizer.getEndIndex()")
clone.SetOption(11141120, true)
clone.SetOption(131072, false)
    if clone.GetOption(8912896) == 0 || clone.GetOption(131072) == 1:
Errln("error in Normalizer::setOption() or Normalizer::getOption()")
    clone.UnicodeVersion = NormalizerUnicodeVersion.Unicode3_2
assertEquals("error in Normalizer.UnicodeVersion property", NormalizerUnicodeVersion.Unicode3_2, clone.UnicodeVersion)
    clone.UnicodeVersion = NormalizerUnicodeVersion.Default
assertEquals("error in Normalizer.UnicodeVersion property", NormalizerUnicodeVersion.Default, clone.UnicodeVersion)
Normalizer.Normalize(s, NormalizerMode.NFC, 0)
Normalizer.Compose(s, false, 0)
Normalizer.Decompose(s, false, 0)
proc TestComposedCharIter*() =
doTestComposedChars(false)
proc doTestComposedChars(compat: bool) =
    var options: int = Normalizer.IGNORE_HANGUL
    var iter: ComposedCharIter = ComposedCharIter(compat, options)
    var lastChar: char = cast[char](0)
    while iter.HasNext:
        var ch: char = iter.Next
assertNoDecomp(lastChar, ch, compat, options)
        lastChar = ch
        var chString: String = StringBuffer.Append(ch).ToString
        var iterDecomp: String = iter.Decomposition
        var normDecomp: String = Normalizer.Decompose(chString, compat)
        if iterDecomp.Equals(chString):
Errln("ERROR: " + Hex(ch) + " has identical decomp")

        elif !iterDecomp.Equals(normDecomp):
Errln("ERROR: Normalizer decomp for " + Hex(ch) + " (" + Hex(normDecomp) + ")" + " != iter decomp (" + Hex(iterDecomp) + ")")
assertNoDecomp(lastChar, '�', compat, options)
proc assertNoDecomp(start: char, limit: char, compat: bool, options: int) =
      var x: char = ++start
      while x < limit:
          var xString: String = StringBuffer.Append(x).ToString
          var decomp: String = Normalizer.Decompose(xString, compat)
          if !decomp.Equals(xString):
Errln("ERROR: " + Hex(x) + " has decomposition (" + Hex(decomp) + ")" + " but was not returned by iterator")
++x
proc TestRoundTrip*() =
    var options: int = Normalizer.IGNORE_HANGUL
    var compat: bool = false
    var iter: ComposedCharIter = ComposedCharIter(false, options)
    while iter.HasNext:
        var ch: char = iter.Next
        var chStr: string = "" + ch
        var decomp: string = iter.Decomposition
        var comp: string = Normalizer.Compose(decomp, compat)
        if UChar.HasBinaryProperty(ch, UProperty.Full_Composition_Exclusion):
Logln("Skipped excluded char " + Hex(ch) + " (" + UChar.GetName(ch) + ")")
            continue
        if decomp.Length == 4:
          continue
        if !comp.Equals(chStr):
Errln("ERROR: Round trip invalid: " + Hex(chStr) + " --> " + Hex(decomp) + " --> " + Hex(comp))
Errln("  char decomp is '" + decomp + "'")