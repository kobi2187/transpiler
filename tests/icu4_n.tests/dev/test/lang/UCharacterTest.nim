# "Namespace: ICU4N.Dev.Test.Lang"
type
  UCharacterTest = ref object
    VERSION_: VersionInfo = VersionInfo.GetInstance(10)

proc newUCharacterTest(): UCharacterTest =

proc TestLetterNumber*() =
      var i: int = 65
      while i < 91:
          if !UChar.IsLetter(i):
Errln("FAIL \u" + Hex(i) + " expected to be a letter")
++i
      var i: int = 1632
      while i < 1642:
          if UChar.IsLetter(i):
Errln("FAIL \u" + Hex(i) + " expected not to be a letter")
++i
      var i: int = 1632
      while i < 1642:
          if !UChar.IsDigit(i):
Errln("FAIL \u" + Hex(i) + " expected to be a digit")
++i
      var i: int = 65
      while i < 91:
          if !UChar.IsLetterOrDigit(i):
Errln("FAIL \u" + Hex(i) + " expected not to be a digit")
++i
      var i: int = 1632
      while i < 1642:
          if !UChar.IsLetterOrDigit(i):
Errln("FAIL \u" + Hex(i) + "expected to be either a letter or a digit")
++i
    var version: VersionInfo = UChar.UnicodeVersion
    if version.Major < 4 || version.Equals(VersionInfo.GetInstance(4, 0, 1)):
        return
    var digitsPattern: String = "[:Nd:]"
    var decimalValuesPattern: String = "[:Numeric_Type=Decimal:]"
      var digits: UnicodeSet
      var decimalValues: UnicodeSet
    digits = UnicodeSet(digitsPattern)
    decimalValues = UnicodeSet(decimalValuesPattern)
CompareUSets(digits, decimalValues, "[:Nd:]", "[:Numeric_Type=Decimal:]", true)
proc TestSpaces*() =
    var spaces: int[] = @[32, 160, 8192, 8193, 8197]
    var nonspaces: int[] = @[97, 98, 99, 100, 116]
    var whitespaces: int[] = @[8200, 8201, 8202, 28, 12]
    var nonwhitespaces: int[] = @[97, 98, 60, 40, 63, 160, 8199, 8239, 65278, 8203]
    var size: int = spaces.Length
      var i: int = 0
      while i < size:
          if !UChar.IsSpaceChar(spaces[i]):
Errln("FAIL \u" + Hex(spaces[i]) + " expected to be a space character")
              break
          if UChar.IsSpaceChar(nonspaces[i]):
Errln("FAIL \u" + Hex(nonspaces[i]) + " expected not to be space character")
              break
          if !UChar.IsWhiteSpace(whitespaces[i]):
Errln("FAIL \u" + Hex(whitespaces[i]) + " expected to be a white space character")
              break
          if UChar.IsWhiteSpace(nonwhitespaces[i]):
Errln("FAIL \u" + Hex(nonwhitespaces[i]) + " expected not to be a space character")
              break
Logln("Ok    \u" + Hex(spaces[i]) + " and \u" + Hex(nonspaces[i]) + " and \u" + Hex(whitespaces[i]) + " and \u" + Hex(nonwhitespaces[i]))
++i
    var patternWhiteSpace: int[] = @[9, 13, 32, 133, 8206, 8207, 8232, 8233]
    var nonPatternWhiteSpace: int[] = @[8, 14, 33, 134, 160, 161, 5760, 5761, 6158, 6159, 8191, 8192, 8202, 8203, 8208, 8239, 8240, 8287, 8288, 12288, 12289]
      var i: int = 0
      while i < patternWhiteSpace.Length:
          if !PatternProps.IsWhiteSpace(patternWhiteSpace[i]):
Errln("\u" + Utility.Hex(patternWhiteSpace[i], 4) + " expected to be a Pattern_White_Space")
++i
      var i: int = 0
      while i < nonPatternWhiteSpace.Length:
          if PatternProps.IsWhiteSpace(nonPatternWhiteSpace[i]):
Errln("\u" + Utility.Hex(nonPatternWhiteSpace[i], 4) + " expected to be a non-Pattern_White_Space")
++i
    var GC_Z_MASK: int = 1 << UUnicodeCategory.SpaceSeparator.ToInt32 | 1 << UUnicodeCategory.LineSeparator.ToInt32 | 1 << UUnicodeCategory.ParagraphSeparator.ToInt32
      var c: int = 0
      while c <= 65535:
          var j: bool = char.IsWhiteSpace(cast[char](c))
          var i: bool = UChar.IsWhiteSpace(c)
          var u: bool = UChar.IsUWhiteSpace(c)
          var z: bool = UChar.GetIntPropertyValue(c, UProperty.General_Category_Mask) & GC_Z_MASK != 0
          if j != i:
Logln(String.Format("isWhitespace(U+{0:x4}) difference: JDK {1} ICU {2} Unicode WS {3} Z Separator {4}", c, j, i, u, z))

          elif j || i || u || z:
Logln(String.Format("isWhitespace(U+{0:x4}) FYI:        JDK {1} ICU {2} Unicode WS {3} Z Separator {4}", c, j, i, u, z))
++c
      var c: char = cast[char](0)
      while c <= 255:
          var j: bool = J2N.Character.IsSpace(c)
          var i: bool = UChar.IsSpace(c)
          var z: bool = UChar.GetIntPropertyValue(c, UProperty.General_Category_Mask) & GC_Z_MASK != 0
          if j != i:
Logln(String.Format("isSpace(U+{0:x4}) difference: JDK {1} ICU {2} Z Separator {3}", cast[int](c), j, i, z))

          elif j || i || z:
Logln(String.Format("isSpace(U+{0:x4}) FYI:        JDK {1} ICU {2} Z Separator {3}", cast[int](c), j, i, z))
++c
proc TestPatternProperties*() =
    var syn_pp: UnicodeSet = UnicodeSet
    var syn_prop: UnicodeSet = UnicodeSet("[:Pattern_Syntax:]")
    var syn_list: UnicodeSet = UnicodeSet("[!-/\:-@\[-\^`\{-~" + "¡-§©«¬®°±¶»¿×÷" + "‐-‧‰-‾⁁-⁓⁕-⁞←-⑟─-❵" + "➔-⯿⸀-⹿、-〃〈-〠〰﴾﴿﹅﹆]")
    var ws_pp: UnicodeSet = UnicodeSet
    var ws_prop: UnicodeSet = UnicodeSet("[:Pattern_White_Space:]")
    var ws_list: UnicodeSet = UnicodeSet("[\u0009-\u000D\ \u0085\u200E\u200F\u2028\u2029]")
    var syn_ws_pp: UnicodeSet = UnicodeSet
    var syn_ws_prop: UnicodeSet = UnicodeSet(syn_prop).AddAll(ws_prop)
      var c: int = 0
      while c <= 65535:
          if PatternProps.IsSyntax(c):
syn_pp.Add(c)
          if PatternProps.IsWhiteSpace(c):
ws_pp.Add(c)
          if PatternProps.IsSyntaxOrWhiteSpace(c):
syn_ws_pp.Add(c)
++c
CompareUSets(syn_pp, syn_prop, "PatternProps.isSyntax()", "[:Pattern_Syntax:]", true)
CompareUSets(syn_pp, syn_list, "PatternProps.isSyntax()", "[Pattern_Syntax ranges]", true)
CompareUSets(ws_pp, ws_prop, "PatternProps.isWhiteSpace()", "[:Pattern_White_Space:]", true)
CompareUSets(ws_pp, ws_list, "PatternProps.isWhiteSpace()", "[Pattern_White_Space ranges]", true)
CompareUSets(syn_ws_pp, syn_ws_prop, "PatternProps.isSyntaxOrWhiteSpace()", "[[:Pattern_Syntax:][:Pattern_White_Space:]]", true)
proc TestDefined*() =
    var undefined: int[] = @[65521, 65527, 64110]
    var defined: int[] = @[21054, 20360, 65533]
    var size: int = undefined.Length
      var i: int = 0
      while i < size:
          if UChar.IsDefined(undefined[i]):
Errln("FAIL \u" + Hex(undefined[i]) + " expected not to be defined")
              break
          if !UChar.IsDefined(defined[i]):
Errln("FAIL \u" + Hex(defined[i]) + " expected defined")
              break
++i
proc TestBase*() =
    var @base: int[] = @[97, 49, 978]
    var nonbase: int[] = @[43, 32, 8251]
    var size: int = @base.Length
      var i: int = 0
      while i < size:
          if UChar.IsBaseForm(nonbase[i]):
Errln("FAIL \u" + Hex(nonbase[i]) + " expected not to be a base character")
              break
          if !UChar.IsBaseForm(@base[i]):
Errln("FAIL \u" + Hex(@base[i]) + " expected to be a base character")
              break
++i
proc TestDigits*() =
    var digits: int[] = @[48, 1634, 3875, 3797, 8544]
    var digits2: int[] = @[12295, 19968, 20108, 19977, 22232, 20116, 20845, 19971, 20843, 20061]
    var nondigits: int[] = @[16, 65, 290, 26878]
    var digitvalues: int[] = @[0, 2, 3, 5, 1]
    var digitvalues2: int[] = @[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var size: int = digits.Length
      var i: int = 0
      while i < size:
          if UChar.IsDigit(digits[i]) && UChar.Digit(digits[i]) != digitvalues[i]:
Errln("FAIL \u" + Hex(digits[i]) + " expected digit with value " + digitvalues[i])
              break
++i
    size = nondigits.Length
      var i: int = 0
      while i < size:
          if UChar.IsDigit(nondigits[i]):
Errln("FAIL \u" + Hex(nondigits[i]) + " expected nondigit")
              break
++i
    size = digits2.Length
      var i: int = 0
      while i < 10:
          if UChar.IsDigit(digits2[i]) && UChar.Digit(digits2[i]) != digitvalues2[i]:
Errln("FAIL \u" + Hex(digits2[i]) + " expected digit with value " + digitvalues2[i])
              break
++i
proc TestNumeric*() =
    if UChar.GetNumericValue(188) != -2:
Errln("Numeric value of 0x00BC expected to be -2")
      var i: int = '0'
      while i < '9':
          var n1: int = UChar.GetNumericValue(i)
          var n2: double = UChar.GetUnicodeNumericValue(i)
          if n1 != n2 || n1 != i - '0':
Errln("Numeric value of " + cast[char](i) + " expected to be " + i - '0')
++i
      var i: int = 'A'
      while i < 'F':
          var n1: int = UChar.GetNumericValue(i)
          var n2: double = UChar.GetUnicodeNumericValue(i)
          if n2 != UChar.NoNumericValue || n1 != i - 'A' + 10:
Errln("Numeric value of " + cast[char](i) + " expected to be " + i - 'A' + 10)
++i
      var i: int = 65313
      while i < 65318:
          var n1: int = UChar.GetNumericValue(i)
          var n2: double = UChar.GetUnicodeNumericValue(i)
          if n2 != UChar.NoNumericValue || n1 != i - 65313 + 10:
Errln("Numeric value of " + cast[char](i) + " expected to be " + i - 65313 + 10)
++i
    var han: int[] = @[38646, 0, 22777, 1, 36019, 2, 21443, 3, 32902, 4, 20237, 5, 38520, 6, 26578, 7, 25420, 8, 29590, 9, 21313, 10, 25342, 10, 30334, 100, 20336, 100, 21315, 1000, 20191, 1000, 33356, 10000, 20740, 100000000]
      var i: int = 0
      while i < han.Length:
          if UChar.GetHanNumericValue(han[i]) != han[i + 1]:
Errln("Numeric value of \u" + han[i].ToHexString + " expected to be " + han[i + 1])
          i = 2
proc TestVersion*() =
    if !UChar.UnicodeVersion.Equals(VERSION_):
Errln("FAIL expected: " + VERSION_ + " got: " + UChar.UnicodeVersion)
proc TestISOControl*() =
    var control: int[] = @[27, 151, 130]
    var noncontrol: int[] = @[97, 49, 226]
    var size: int = control.Length
      var i: int = 0
      while i < size:
          if !UChar.IsISOControl(control[i]):
Errln("FAIL 0x" + control[i].ToHexString + " expected to be a control character")
              break
          if UChar.IsISOControl(noncontrol[i]):
Errln("FAIL 0x" + noncontrol[i].ToHexString + " expected to be not a control character")
              break
Logln("Ok    0x" + control[i].ToHexString + " and 0x" + noncontrol[i].ToHexString)
++i
proc TestSupplementary*() =
      var i: int = 0
      while i < 65536:
          if UChar.IsSupplementary(i):
Errln("Codepoint \u" + i.ToHexString + " is not supplementary")
++i
      var i: int = 65536
      while i < 1114111:
          if !UChar.IsSupplementary(i):
Errln("Codepoint \u" + i.ToHexString + " is supplementary")
++i
proc TestMirror*() =
    if !UChar.IsMirrored(40) && UChar.IsMirrored(187) && UChar.IsMirrored(8261) && UChar.IsMirrored(9002) && !UChar.IsMirrored(39) && !UChar.IsMirrored(97) && !UChar.IsMirrored(644) && !UChar.IsMirrored(13312):
Errln("isMirrored() does not work correctly")
    if !UChar.GetMirror(60) == 62 && UChar.GetMirror(93) == 91 && UChar.GetMirror(8333) == 8334 && UChar.GetMirror(12311) == 12310 && UChar.GetMirror(187) == 171 && UChar.GetMirror(8725) == 10741 && UChar.GetMirror(10741) == 8725 && UChar.GetMirror(46) == 46 && UChar.GetMirror(1779) == 1779 && UChar.GetMirror(12316) == 12316 && UChar.GetMirror(42155) == 42155 && UChar.GetMirror(8216) == 8216 && UChar.GetMirror(8219) == 8219 && UChar.GetMirror(12317) == 12317:
Errln("getMirror() does not work correctly")
    var set: UnicodeSet = UnicodeSet("[:Bidi_Mirrored:]")
    var iter: UnicodeSetIterator = UnicodeSetIterator(set)
      var start: int
      var end: int
      var c2: int
      var c3: int
    while iter.NextRange &&     start = iter.Codepoint >= 0:
        end = iter.CodepointEnd
        while true:
            c2 = UChar.GetMirror(start)
            c3 = UChar.GetMirror(c2)
            if c3 != start:
Errln("getMirror() does not roundtrip: U+" + Hex(start) + "->U+" + Hex(c2) + "->U+" + Hex(c3))
            c3 = UChar.GetBidiPairedBracket(start)
            if UChar.GetIntPropertyValue(start, UProperty.Bidi_Paired_Bracket_Type) == BidiPairedBracketType.None:
                if c3 != start:
Errln("u_getBidiPairedBracket(U+" + Hex(start) + ") != self for bpt(c)==None")
            else:
                if c3 != c2:
Errln("u_getBidiPairedBracket(U+" + Hex(start) + ") != U+" + Hex(c2) + " = bmg(c)'")
            if not++start <= end:
                break
    if UChar.IsMirrored(8216) || UChar.IsMirrored(8221) || UChar.IsMirrored(8223) || UChar.IsMirrored(12318):
Errln("Unicode Corrigendum #6 conflict, one or more of 2018/201d/201f/301e has mirrored property")
proc TestPrint*() =
    var printable: int[] = @[66, 95, 8212]
    var nonprintable: int[] = @[8204, 159, 27]
    var size: int = printable.Length
      var i: int = 0
      while i < size:
          if !UChar.IsPrintable(printable[i]):
Errln("FAIL \u" + Hex(printable[i]) + " expected to be a printable character")
              break
          if UChar.IsPrintable(nonprintable[i]):
Errln("FAIL \u" + Hex(nonprintable[i]) + " expected not to be a printable character")
              break
Logln("Ok    \u" + Hex(printable[i]) + " and \u" + Hex(nonprintable[i]))
++i
      var ch: int = 0
      while ch <= 159:
          if ch == 32:
              ch = 127
          if UChar.IsPrintable(ch):
Errln("Fail \u" + Hex(ch) + " is a ISO 8 control character hence not printable
")
++ch
      var ch: int = 32
      while ch <= 255:
          if ch == 127:
              ch = 160
          if !UChar.IsPrintable(ch) && ch != 173:
Errln("Fail \u" + Hex(ch) + " is a Latin-1 graphic character
")
++ch
proc TestIdentifier*() =
    var unicodeidstart: int[] = @[592, 226, 97]
    var nonunicodeidstart: int[] = @[8192, 10, 8217]
    var unicodeidpart: int[] = @[95, 50, 69]
    var nonunicodeidpart: int[] = @[8240, 163, 32]
    var idignore: int[] = @[6, 16, 8299]
    var nonidignore: int[] = @[117, 163, 97]
    var size: int = unicodeidstart.Length
      var i: int = 0
      while i < size:
          if !UChar.IsUnicodeIdentifierStart(unicodeidstart[i]):
Errln("FAIL \u" + Hex(unicodeidstart[i]) + " expected to be a unicode identifier start character")
              break
          if UChar.IsUnicodeIdentifierStart(nonunicodeidstart[i]):
Errln("FAIL \u" + Hex(nonunicodeidstart[i]) + " expected not to be a unicode identifier start " + "character")
              break
          if !UChar.IsUnicodeIdentifierPart(unicodeidpart[i]):
Errln("FAIL \u" + Hex(unicodeidpart[i]) + " expected to be a unicode identifier part character")
              break
          if UChar.IsUnicodeIdentifierPart(nonunicodeidpart[i]):
Errln("FAIL \u" + Hex(nonunicodeidpart[i]) + " expected not to be a unicode identifier part " + "character")
              break
          if !UChar.IsIdentifierIgnorable(idignore[i]):
Errln("FAIL \u" + Hex(idignore[i]) + " expected to be a ignorable unicode character")
              break
          if UChar.IsIdentifierIgnorable(nonidignore[i]):
Errln("FAIL \u" + Hex(nonidignore[i]) + " expected not to be a ignorable unicode character")
              break
Logln("Ok    \u" + Hex(unicodeidstart[i]) + " and \u" + Hex(nonunicodeidstart[i]) + " and \u" + Hex(unicodeidpart[i]) + " and \u" + Hex(nonunicodeidpart[i]) + " and \u" + Hex(idignore[i]) + " and \u" + Hex(nonidignore[i]))
++i
proc TestUnicodeData*() =
    var TYPE: String = "LuLlLtLmLoMnMeMcNdNlNoZsZlZpCcCfCoCsPdPsPePcPoSmScSkSoPiPf"
    var DIR: String = "L   R   EN  ES  ET  AN  CS  B   S   WS  ON  LRE LRO AL  RLE RLO PDF NSM BN  FSI LRI RLI PDI "
    var nfc: Normalizer2 = Normalizer2.NFCInstance
    var nfkc: Normalizer2 = Normalizer2.NFKCInstance
    var input: TextReader = nil
    try:
        input = TestUtil.GetDataReader("unicode/UnicodeData.txt")
        var numErrors: int = 0
          while true:
              var s: String = input.ReadLine
              if s == nil:
                  break
              if s.Length < 4 || s.StartsWith("#", StringComparison.Ordinal):
                  continue
              var fields: String[] = s.Split(@[';'], StringSplitOptions.RemoveEmptyEntries)
Debug.Assert(fields.Length == 15, "Number of fields is " + fields.Length + ": " + s)
              var ch: int = int.Parse(fields[0], NumberStyles.HexNumber, CultureInfo.InvariantCulture)
              var type: int = TYPE.IndexOf(fields[2], StringComparison.Ordinal)
              if type < 0:
                type = 0
              else:
                type = type >> 1 + 1
              if UChar.GetUnicodeCategory(ch).ToInt32 != type:
Errln("FAIL \u" + Hex(ch) + " expected type " + type)
                  break
              if UChar.GetIntPropertyValue(ch, UProperty.General_Category_Mask) != 1 << type:
Errln("error: getIntPropertyValue(\u" + ch.ToHexString + ", UProperty.GENERAL_CATEGORY_MASK) != " + "getMask(getType(ch))")
              var cc: int = int.Parse(fields[3], CultureInfo.InvariantCulture)
              if UChar.GetCombiningClass(ch) != cc:
Errln("FAIL \u" + Hex(ch) + " expected combining " + "class " + cc)
                  break
              if nfkc.GetCombiningClass(ch) != cc:
Errln("FAIL \u" + Hex(ch) + " expected NFKC combining " + "class " + cc)
                  break
              var d: String = fields[4]
              if d.Length == 1:
                d = d + "   "
              var dir: int = DIR.IndexOf(d, StringComparison.Ordinal) >> 2
              if UChar.GetDirection(ch).ToInt32 != dir:
Errln("FAIL \u" + Hex(ch) + " expected direction " + dir + " but got " + UChar.GetDirection(ch).ToInt32)
                  break
              var bdir: byte = cast[byte](dir)
              if UChar.GetDirectionality(ch) != bdir:
Errln("FAIL \u" + Hex(ch) + " expected directionality " + bdir + " but got " + UChar.GetDirectionality(ch))
                  break
              var dt: int
              if fields[5].Length == 0:
                  if ch == 44032 || ch == 55203:
                      dt = DecompositionType.Canonical
                  else:
                      dt = DecompositionType.None
              else:
                  d = fields[5]
                  dt = -1
                  if d[0] == '<':
                      var end: int = d.IndexOf('>', 1)
                      if end >= 0:
                          dt = UChar.GetPropertyValueEnum(UProperty.Decomposition_Type, d.Substring(1, end - 1))
                          while d[++end] == ' ':

                          d = d.Substring(end)
                  else:
                      dt = DecompositionType.Canonical
              var dm: String
              if dt > DecompositionType.None:
                  if ch == 44032:
                      dm = "가"

                  elif ch == 55203:
                      dm = "힣"
                  else:
                      var dmChars: String[] = Regex.Split(d, " +")
                      var dmb: StringBuilder = StringBuilder(dmChars.Length)
                      for dmc in dmChars:
dmb.AppendCodePoint(Convert.ToInt32(dmc, 16))
                      dm = dmb.ToString
              else:
                  dm = nil
              if dt < 0:
Errln(String.Format("error in UnicodeData.txt: syntax error in U+{0:X4} decomposition field", ch))
                  return
              var i: int = UChar.GetIntPropertyValue(ch, UProperty.Decomposition_Type)
assertEquals(String.Format("error: UCharacter.getIntPropertyValue(U+{0:X4}, UProperty.DECOMPOSITION_TYPE) is wrong", ch), dt, i)
              var mapping: String = nfkc.GetRawDecomposition(ch)
assertEquals(String.Format("error: nfkc.getRawDecomposition(U+{0:X4}) is wrong", ch), dm, mapping)
              if dt != DecompositionType.Canonical:
                  dm = nil
              mapping = nfc.GetRawDecomposition(ch)
assertEquals(String.Format("error: nfc.getRawDecomposition(U+{0:X4}) is wrong", ch), dm, mapping)
              if dt == DecompositionType.Canonical && !UChar.HasBinaryProperty(ch, UProperty.Full_Composition_Exclusion):
                  var a: int = dm.CodePointAt(0)
                  var b: int = dm.CodePointBefore(dm.Length)
                  var composite: int = nfc.ComposePair(a, b)
assertEquals(String.Format("error: nfc U+{0:X4} decomposes to U+{1:X4}+U+{2:X4} " + "but does not compose back (instead U+{3:X4})", ch, a, b, composite), ch, composite)
              try:
                  var isocomment: String = fields[11]
                  var comment: String = UChar.GetISOComment(ch)
                  if comment == nil:
                      comment = ""
                  if !comment.Equals(isocomment):
Errln("FAIL \u" + Hex(ch) + " expected iso comment " + isocomment)
                      break
              except Exception:
                  if e.Message.IndexOf("unames.icu", StringComparison.Ordinal) >= 0:
++numErrors
                  else:
                      raise
              var upper: String = fields[12]
              var tempchar: int = ch
              if upper.Length > 0:
                  tempchar = Convert.ToInt32(upper, 16)
              var resultCp: int = UChar.ToUpper(ch)
              if resultCp != tempchar:
Errln("FAIL \u" + Utility.Hex(ch, 4) + " expected uppercase \u" + Utility.Hex(tempchar, 4) + " but got \u" + Utility.Hex(resultCp, 4))
                  break
              var lower: String = fields[13]
              tempchar = ch
              if lower.Length > 0:
                  tempchar = Convert.ToInt32(lower, 16)
              if UChar.ToLower(ch) != tempchar:
Errln("FAIL \u" + Utility.Hex(ch, 4) + " expected lowercase \u" + Utility.Hex(tempchar, 4))
                  break
              var title: String = fields[14]
              tempchar = ch
              if title.Length > 0:
                  tempchar = Convert.ToInt32(title, 16)
              if UChar.ToTitleCase(ch) != tempchar:
Errln("FAIL \u" + Utility.Hex(ch, 4) + " expected titlecase \u" + Utility.Hex(tempchar, 4))
                  break
        if numErrors > 0:
Warnln("Could not find unames.icu")
    except Exception:
e.PrintStackTrace
    finally:
        if input != nil:
            try:
input.Dispose
            except IOException:

    if UnicodeBlock.Of(65) != UnicodeBlock.Basic_Latin || UChar.GetIntPropertyValue(65, UProperty.Block) != UnicodeBlock.Basic_Latin.ID:
Errln("UCharacter.UnicodeBlock.of(\u0041) property failed! " + "Expected : " + UnicodeBlock.Basic_Latin.ID + " got " + UnicodeBlock.Of(65))
      var ch: int = 65534
      while ch <= 1114111:
          var type: UUnicodeCategory = UChar.GetUnicodeCategory(ch)
          if UChar.GetIntPropertyValue(ch, UProperty.General_Category_Mask) != 1 << type.ToInt32:
Errln("error: UCharacter.getIntPropertyValue(\u" + ch.ToHexString + ", UProperty.GENERAL_CATEGORY_MASK) != " + "getMask(getType())")
          if type != UUnicodeCategory.OtherNotAssigned:
Errln("error: UCharacter.getType(\u" + Utility.Hex(ch, 4) + " != UCharacterCategory.UNASSIGNED (returns " + UChar.GetUnicodeCategory(ch).AsString + ")")
          if ch & 65535 == 65534:
++ch
          else:
              ch = 65535
      var ch: int = 57344
      while ch <= 1114109:
          var type: int = UChar.GetUnicodeCategory(ch).ToInt32
          if UChar.GetIntPropertyValue(ch, UProperty.General_Category_Mask) != 1 << type:
Errln("error: UCharacter.getIntPropertyValue(\u" + ch.ToHexString + ", UProperty.GENERAL_CATEGORY_MASK) != " + "getMask(getType())")
          if type == UUnicodeCategory.OtherNotAssigned.ToInt32:
Errln("error: UCharacter.getType(\u" + Utility.Hex(ch, 4) + ") == UCharacterCategory.UNASSIGNED")

          elif type != UUnicodeCategory.PrivateUse.ToInt32:
Logln("PUA override: UCharacter.getType(\u" + Utility.Hex(ch, 4) + ")=" + type)
          if ch == 63743:
              ch = 983040

          elif ch == 1048573:
              ch = 1048576
          else:
++ch
proc TestNames*() =
    try:
        var length: int = UCharacterName.Instance.MaxCharNameLength
        if length < 83:
Errln("getMaxCharNameLength()=" + length + " is too short")
        var c: int[] = @[97, 644, 13313, 32749, 44032, 55203, 55296, 56320, 65288, 65509, 65535, 144470]
        var name: String[] = @["LATIN SMALL LETTER A", "LATIN SMALL LETTER DOTLESS J WITH STROKE AND HOOK", "CJK UNIFIED IDEOGRAPH-3401", "CJK UNIFIED IDEOGRAPH-7FED", "HANGUL SYLLABLE GA", "HANGUL SYLLABLE HIH", "", "", "FULLWIDTH LEFT PARENTHESIS", "FULLWIDTH YEN SIGN", "", "CJK UNIFIED IDEOGRAPH-23456"]
        var oldname: String[] = @["", "", "", "", "", "", "", "", "", "", "", ""]
        var extendedname: String[] = @["LATIN SMALL LETTER A", "LATIN SMALL LETTER DOTLESS J WITH STROKE AND HOOK", "CJK UNIFIED IDEOGRAPH-3401", "CJK UNIFIED IDEOGRAPH-7FED", "HANGUL SYLLABLE GA", "HANGUL SYLLABLE HIH", "<lead surrogate-D800>", "<trail surrogate-DC00>", "FULLWIDTH LEFT PARENTHESIS", "FULLWIDTH YEN SIGN", "<noncharacter-FFFF>", "CJK UNIFIED IDEOGRAPH-23456"]
        var size: int = c.Length
        var str: String
        var uc: int
          var i: int = 0
          while i < size:
              str = UChar.GetName(c[i])
              if str == nil && name[i].Length > 0 || str != nil && !str.Equals(name[i]):
Errln("FAIL \u" + Hex(c[i]) + " expected name " + name[i])
                  break
              str = UChar.GetName1_0(c[i])
              if str == nil && oldname[i].Length > 0 || str != nil && !str.Equals(oldname[i]):
Errln("FAIL \u" + Hex(c[i]) + " expected 1.0 name " + oldname[i])
                  break
              str = UChar.GetExtendedName(c[i])
              if str == nil || !str.Equals(extendedname[i]):
Errln("FAIL \u" + Hex(c[i]) + " expected extended name " + extendedname[i])
                  break
              uc = UChar.GetCharFromName(name[i])
              if uc != c[i] && name[i].Length != 0:
Errln("FAIL " + name[i] + " expected character \u" + Hex(c[i]))
                  break
              uc = UChar.GetCharFromName1_0(oldname[i])
              if uc != c[i] && oldname[i].Length != 0:
Errln("FAIL " + oldname[i] + " expected 1.0 character \u" + Hex(c[i]))
                  break
              uc = UChar.GetCharFromExtendedName(extendedname[i])
              if uc != c[i] && i != 0 && i == 1 || i == 6:
Errln("FAIL " + extendedname[i] + " expected extended character \u" + Hex(c[i]))
                  break
++i
        if 97 != UChar.GetCharFromName("LATin smALl letTER A"):
Errln("FAIL: 'LATin smALl letTER A' should result in character " + "U+0061")
        if TestFmwk.GetExhaustiveness >= 5:
              var i: int = UChar.MinValue
              while i < UChar.MaxValue:
                  str = UChar.GetName(i)
                  if str != nil && UChar.GetCharFromName(str) != i:
Errln("FAIL \u" + Hex(i) + " " + str + " retrieval of name and vice versa")
                      break
++i
        if TestFmwk.GetExhaustiveness >= 10:
            var map: bool[] = seq[bool]
            var set: UnicodeSet = UnicodeSet(1, 0)
            var dumb: UnicodeSet = UnicodeSet(1, 0)
UCharacterName.Instance.GetCharNameCharacters(set)
map.Fill(false)
            var maxLength: int = 0
              var cp: int = 0
              while cp < 1114112:
                  var n: String = UChar.GetExtendedName(cp)
                  var len: int = n.Length
                  if len > maxLength:
                      maxLength = len
                    var i: int = 0
                    while i < len:
                        var ch: char = n[i]
                        if !map[ch & 255]:
dumb.Add(ch)
                            map[ch & 255] = true
++i
++cp
            length = UCharacterName.Instance.MaxCharNameLength
            if length != maxLength:
Errln("getMaxCharNameLength()=" + length + " differs from the maximum length " + maxLength + " of all extended names")
            var ok: bool = true
              var i: int = 0
              while i < 256:
                  if set.Contains(i) != dumb.Contains(i):
                      if 97 <= i && i <= 122 && set.Contains(i) && !dumb.Contains(i):
                          ok = true
                      else:
                          ok = false
                          break
++i
            var pattern1: String = set.ToPattern(true)
            var pattern2: String = dumb.ToPattern(true)
            if !ok:
Errln("FAIL: getCharNameCharacters() returned " + pattern1 + " expected " + pattern2 + " (too many lowercase a-z are ok)")
            else:
Logln("Ok: getCharNameCharacters() returned " + pattern1)
        var expected: String = "LATIN SMALL LETTER A|LATIN SMALL LETTER DOTLESS J WITH STROKE AND HOOK|" + "CJK UNIFIED IDEOGRAPH-3401|CJK UNIFIED IDEOGRAPH-7FED|HANGUL SYLLABLE GA|" + "HANGUL SYLLABLE HIH|LINEAR B SYLLABLE B008 A|FULLWIDTH LEFT PARENTHESIS|" + "FULLWIDTH YEN SIGN|" + "null|" + "CJK UNIFIED IDEOGRAPH-23456"
        var separator: String = "|"
        var source: String = Utility.ValueOf(c)
        var result: String = UChar.GetName(source, separator)
        if !result.Equals(expected):
Errln("UCharacter.getName did not return the expected result.
	 Expected: " + expected + "
	 Got: " + result)
    except ArgumentException:
        if e.Message.IndexOf("unames.icu", StringComparison.Ordinal) >= 0:
Warnln("Could not find unames.icu")
        else:
            raise
proc TestUCharFromNameUnderflow*() =
    var c: int = UChar.GetCharFromExtendedName("<NO BREAK SPACE>")
    if c >= 0:
Errln("UCharacter.getCharFromExtendedName(<NO BREAK SPACE>) = U+" + Hex(c) + " but should fail (-1)")
    c = UChar.GetCharFromExtendedName("<-00a0>")
    if c >= 0:
Errln("UCharacter.getCharFromExtendedName(<-00a0>) = U+" + Hex(c) + " but should fail (-1)")
    c = UChar.GetCharFromExtendedName("<control->")
    if c >= 0:
Errln("UCharacter.getCharFromExtendedName(<control->) = U+" + Hex(c) + " but should fail (-1)")
    c = UChar.GetCharFromExtendedName("<control-111111>")
    if c >= 0:
Errln("UCharacter.getCharFromExtendedName(<control-111111>) = U+" + Hex(c) + " but should fail (-1)")
proc TestNameIteration*() =
    try:
        var iterator: IValueEnumerator = UChar.GetExtendedNameEnumerator
        var old: ValueEnumeratorElement = ValueEnumeratorElement
iterator.SetRange(-10, -5)
        if iterator.MoveNext:
Errln("Fail, expected iterator to return false when range is set outside the meaningful range")
iterator.SetRange(1114112, 1118481)
        if iterator.MoveNext:
Errln("Fail, expected iterator to return false when range is set outside the meaningful range")
        try:
iterator.SetRange(50, 10)
Errln("Fail, expected exception when encountered invalid range")
        except Exception:

iterator.SetRange(-10, 10)
        if !iterator.MoveNext || iterator.Current.Integer != 0:
Errln("Fail, expected iterator to return 0 when range start limit is set outside the meaningful range")
iterator.SetRange(1114110, 2097152)
        var last: int = 0
        while iterator.MoveNext:
            last = iterator.Current.Integer
        if last != 1114111:
Errln("Fail, expected iterator to return 0x10FFFF when range end limit is set outside the meaningful range")
        iterator = UChar.GetNameEnumerator
iterator.SetRange(15, 69)
        while iterator.MoveNext:
            if iterator.Current.Integer <= old.Integer:
Errln("FAIL next returned a less codepoint \u" + iterator.Current.Integer.ToHexString + " than \u" + old.Integer.ToHexString)
                break
            if !UChar.GetName(iterator.Current.Integer).Equals(iterator.Current.Value):
Errln("FAIL next codepoint \u" + iterator.Current.Integer.ToHexString + " does not have the expected name " + UChar.GetName(iterator.Current.Integer) + " instead have the name " + cast[String](iterator.Current.Value))
                break
            old.Integer = iterator.Current.Integer
iterator.Reset
iterator.MoveNext
        if iterator.Current.Integer != 32:
Errln("FAIL reset in iterator")
iterator.SetRange(0, 1114112)
        old.Integer = 0
        while iterator.MoveNext:
            if iterator.Current.Integer != 0 && iterator.Current.Integer <= old.Integer:
Errln("FAIL next returned a less codepoint \u" + iterator.Current.Integer.ToHexString + " than \u" + old.Integer.ToHexString)
                break
            if !UChar.GetName(iterator.Current.Integer).Equals(iterator.Current.Value):
Errln("FAIL next codepoint \u" + iterator.Current.Integer.ToHexString + " does not have the expected name " + UChar.GetName(iterator.Current.Integer) + " instead have the name " + cast[String](iterator.Current.Value))
                break
              var i: int = old.Integer + 1
              while i < iterator.Current.Integer:
                  if UChar.GetName(i) != nil:
Errln("FAIL between codepoints are not null \u" + old.Integer.ToHexString + " and " + iterator.Current.Integer.ToHexString + " has " + i.ToHexString + " with a name " + UChar.GetName(i))
                      break
++i
            old.Integer = iterator.Current.Integer
        iterator = UChar.GetExtendedNameEnumerator
        old.Integer = 0
        while iterator.MoveNext:
            if iterator.Current.Integer != 0 && iterator.Current.Integer != old.Integer:
Errln("FAIL next returned a codepoint \u" + iterator.Current.Integer.ToHexString + " different from \u" + old.Integer.ToHexString)
                break
            if !UChar.GetExtendedName(iterator.Current.Integer).Equals(iterator.Current.Value):
Errln("FAIL next codepoint \u" + iterator.Current.Integer.ToHexString + " name should be " + UChar.GetExtendedName(iterator.Current.Integer) + " instead of " + cast[String](iterator.Current.Value))
                break
++old.Integer
        iterator = UChar.GetName1_0Enumerator
        old.Integer = 0
        while iterator.MoveNext:
Logln(iterator.Current.Integer.ToHexString + " " + cast[String](iterator.Current.Value))
            if iterator.Current.Integer != 0 && iterator.Current.Integer <= old.Integer:
Errln("FAIL next returned a less codepoint \u" + iterator.Current.Integer.ToHexString + " than \u" + old.Integer.ToHexString)
                break
            if !iterator.Current.Value.Equals(UChar.GetName1_0(iterator.Current.Integer)):
Errln("FAIL next codepoint \u" + iterator.Current.Integer.ToHexString + " name cannot be null")
                break
              var i: int = old.Integer + 1
              while i < iterator.Current.Integer:
                  if UChar.GetName1_0(i) != nil:
Errln("FAIL between codepoints are not null \u" + old.Integer.ToHexString + " and " + iterator.Current.Integer.ToHexString + " has " + i.ToHexString + " with a name " + UChar.GetName1_0(i))
                      break
++i
            old.Integer = iterator.Current.Integer
    except Exception:
        if e.Message.IndexOf("unames.icu", StringComparison.Ordinal) >= 0:
Warnln("Could not find unames.icu")
        else:
Errln(e.ToString)
proc TestIsLegal*() =
    var illegal: int[] = @[65534, 65535, 393214, 393215, 1114110, 1114111, 1114112, 64976, 64991, 64992, 65007, 55296, 56320, -1]
    var legal: int[] = @[97, 65533, 65536, 393213, 393216, 1114109, 64975, 65008]
      var count: int = 0
      while count < illegal.Length:
          if UChar.IsLegal(illegal[count]):
Errln("FAIL \u" + Hex(illegal[count]) + " is not a legal character")
++count
      var count: int = 0
      while count < legal.Length:
          if !UChar.IsLegal(legal[count]):
Errln("FAIL \u" + Hex(legal[count]) + " is a legal character")
++count
    var illegalStr: String = "This is an illegal string "
    var legalStr: String = "This is a legal string "
      var count: int = 0
      while count < illegal.Length:
          var str: StringBuffer = StringBuffer(illegalStr)
          if illegal[count] < 65536:
str.Append(cast[char](illegal[count]))
          else:
              var lead: char = UTF16.GetLeadSurrogate(illegal[count])
              var trail: char = UTF16.GetTrailSurrogate(illegal[count])
str.Append(lead)
str.Append(trail)
          if UChar.IsLegal(str.ToString):
Errln("FAIL " + Hex(str.ToString) + " is not a legal string")
++count
      var count: int = 0
      while count < legal.Length:
          var str: StringBuffer = StringBuffer(legalStr)
          if legal[count] < 65536:
str.Append(cast[char](legal[count]))
          else:
              var lead: char = UTF16.GetLeadSurrogate(legal[count])
              var trail: char = UTF16.GetTrailSurrogate(legal[count])
str.Append(lead)
str.Append(trail)
          if !UChar.IsLegal(str.ToString):
Errln("FAIL " + Hex(str.ToString) + " is a legal string")
++count
proc TestCodePoint*() =
    var ch: int = 65536
      var i: char = cast[char](55296)
      while i < 56320:
            var j: char = cast[char](56320)
            while j <= 57343:
                if UChar.ConvertToUtf32(i, j) != ch:
Errln("Error getting codepoint for surrogate " + "characters \u" + i.ToHexString + " \u" + j.ToHexString)
++ch
++j
++i
    try:
UChar.ConvertToUtf32(cast[char](55295), cast[char](56320))
Errln("Invalid surrogate characters should not form a " + "supplementary")
    except Exception:

      var i: char = cast[char](0)
      while i < 65535:
          if i == 65534 || i >= 55296 && i <= 57343 || i >= 64976 && i <= 65007:
              try:
UChar.ConvertToUtf32(i)
Errln("Not a character is not a valid codepoint")
              except Exception:

          else:
              if UChar.ConvertToUtf32(i) != i:
Errln("A valid codepoint should return itself")
++i
proc TestIteration*() =
    var limit: int = 0
    var prevtype: int = -1
    var shouldBeDir: int
    var test: int[][] = @[@[65, UUnicodeCategory.UppercaseLetter.ToInt32], @[776, UUnicodeCategory.NonSpacingMark.ToInt32], @[65534, UUnicodeCategory.OtherNotAssigned.ToInt32], @[917569, UUnicodeCategory.Format.ToInt32], @[983039, UUnicodeCategory.OtherNotAssigned.ToInt32]]
    var defaultBidi: int[][] = @[@[1424, UCharacterDirection.LeftToRight.ToInt32], @[1536, UCharacterDirection.RightToLeft.ToInt32], @[1984, UCharacterDirection.RightToLeftArabic.ToInt32], @[2144, UCharacterDirection.RightToLeft.ToInt32], @[2160, UCharacterDirection.RightToLeftArabic.ToInt32], @[2208, UCharacterDirection.RightToLeft.ToInt32], @[2304, UCharacterDirection.RightToLeftArabic.ToInt32], @[8352, UCharacterDirection.LeftToRight.ToInt32], @[8400, UCharacterDirection.EuropeanNumberTerminator.ToInt32], @[64285, UCharacterDirection.LeftToRight.ToInt32], @[64336, UCharacterDirection.RightToLeft.ToInt32], @[65024, UCharacterDirection.RightToLeftArabic.ToInt32], @[65136, UCharacterDirection.LeftToRight.ToInt32], @[65280, UCharacterDirection.RightToLeftArabic.ToInt32], @[67584, UCharacterDirection.LeftToRight.ToInt32], @[69632, UCharacterDirection.RightToLeft.ToInt32], @[124928, UCharacterDirection.LeftToRight.ToInt32], @[126464, UCharacterDirection.RightToLeft.ToInt32], @[126720, UCharacterDirection.RightToLeftArabic.ToInt32], @[126976, UCharacterDirection.RightToLeft.ToInt32], @[1114112, UCharacterDirection.LeftToRight.ToInt32]]
    var iterator: IRangeValueEnumerator = UChar.GetTypeEnumerator
    var result: RangeValueEnumeratorElement
    while iterator.MoveNext:
        result = iterator.Current
        if result.Start != limit:
Errln("UCharacterIteration failed: Ranges not continuous " + "0x" + result.Start.ToHexString)
        limit = result.Limit
        if result.Value == prevtype:
Errln("Type of the next set of enumeration should be different")
        prevtype = result.Value
          var i: int = result.Start
          while i < limit:
              var temptype: int = UChar.GetUnicodeCategory(i).ToInt32
              if temptype != result.Value:
Errln("UCharacterIteration failed: Codepoint \u" + i.ToHexString + " should be of type " + temptype + " not " + result.Value)
++i
          var i: int = 0
          while i < test.Length:
              if result.Start <= test[i][0] && test[i][0] < result.Limit:
                  if result.Value != test[i][1]:
Errln("error: getTypes() has range [" + result.Start.ToHexString + ", " + result.Limit.ToHexString + "] with type " + result.Value + " instead of [" + test[i][0].ToHexString + ", " + test[i][1].ToHexString)
++i
        if result.Value != UUnicodeCategory.OtherNotAssigned.ToInt32 && result.Value != UUnicodeCategory.PrivateUse.ToInt32:
            var c: int = result.Start
            while c < result.Limit:
                if 0 == UChar.GetIntPropertyValue(c, UProperty.Line_Break):
Logln("error UProperty.LINE_BREAK(assigned \u" + Utility.Hex(c, 4) + ")=XX")
++c
        if result.Value == UUnicodeCategory.OtherNotAssigned.ToInt32 || result.Value == UUnicodeCategory.PrivateUse.ToInt32:
            var c: int = result.Start
              var i: int = 0
              while i < defaultBidi.Length && c < result.Limit:
                  if c < defaultBidi[i][0]:
                      while c < result.Limit && c < defaultBidi[i][0]:
                          if UCharacterUtility.IsNonCharacter(c) || UChar.HasBinaryProperty(c, UProperty.Default_Ignorable_Code_Point):
                              shouldBeDir = UCharacterDirection.BoundaryNeutral.ToInt32
                          else:
                              shouldBeDir = defaultBidi[i][1]
                          if UChar.GetDirection(c).ToInt32 != shouldBeDir || UChar.GetIntPropertyValue(c, UProperty.Bidi_Class) != shouldBeDir:
Errln("error: getDirection(unassigned/PUA " + c.ToHexString + ") should be " + shouldBeDir)
++c
++i
iterator.Reset
    if iterator.MoveNext == false || iterator.Current.Start != 0:
Console.Out.WriteLine("result " + iterator.Current.Start)
Errln("UCharacterIteration reset() failed")
proc TestGetAge*() =
    var ages: int[] = @[65, 1, 1, 0, 0, 65535, 1, 1, 0, 0, 8363, 2, 0, 0, 0, 196606, 2, 0, 0, 0, 8364, 2, 1, 0, 0, 64285, 3, 0, 0, 0, 1012, 3, 1, 0, 0, 66304, 3, 1, 0, 0, 544, 3, 2, 0, 0, 65376, 3, 2, 0, 0]
      var i: int = 0
      while i < ages.Length:
          var age: VersionInfo = UChar.GetAge(ages[i])
          if age != VersionInfo.GetInstance(ages[i + 1], ages[i + 2], ages[i + 3], ages[i + 4]):
Errln("error: getAge(\u" + ages[i].ToHexString + ") == " + age.ToString + " instead of " + ages[i + 1] + "." + ages[i + 2] + "." + ages[i + 3] + "." + ages[i + 4])
          i = 5
    var valid_tests: int[] = @[UChar.MinValue, UChar.MinValue + 1, UChar.MaxValue - 1, UChar.MaxValue]
    var invalid_tests: int[] = @[UChar.MinValue - 1, UChar.MinValue - 2, UChar.MaxValue + 1, UChar.MaxValue + 2]
      var i: int = 0
      while i < valid_tests.Length:
          try:
UChar.GetAge(valid_tests[i])
          except Exception:
Errln("UCharacter.getAge(int) was not suppose to have " + "an exception. Value passed: " + valid_tests[i])
++i
      var i: int = 0
      while i < invalid_tests.Length:
          try:
UChar.GetAge(invalid_tests[i])
Errln("UCharacter.getAge(int) was suppose to have " + "an exception. Value passed: " + invalid_tests[i])
          except Exception:

++i
proc TestAdditionalProperties*() =
    var FALSE: int = 0
    var TRUE: int = 1
    var props: int[][] = @[@[1575, cast[int](UProperty.Alphabetic), 1], @[66378, cast[int](UProperty.Alphabetic), 1], @[8232, cast[int](UProperty.Alphabetic), 0], @[102, cast[int](UProperty.ASCII_Hex_Digit), 1], @[103, cast[int](UProperty.ASCII_Hex_Digit), 0], @[8236, cast[int](UProperty.Bidi_Control), 1], @[8239, cast[int](UProperty.Bidi_Control), 0], @[60, cast[int](UProperty.Bidi_Mirrored), 1], @[61, cast[int](UProperty.Bidi_Mirrored), 0], @[8216, cast[int](UProperty.Bidi_Mirrored), 0], @[8221, cast[int](UProperty.Bidi_Mirrored), 0], @[8223, cast[int](UProperty.Bidi_Mirrored), 0], @[12318, cast[int](UProperty.Bidi_Mirrored), 0], @[1418, cast[int](UProperty.Dash), 1], @[126, cast[int](UProperty.Dash), 0], @[3149, cast[int](UProperty.Diacritic), 1], @[12288, cast[int](UProperty.Diacritic), 0], @[3654, cast[int](UProperty.Extender), 1], @[32, cast[int](UProperty.Extender), 0], @[64285, cast[int](UProperty.Full_Composition_Exclusion), 1], @[119135, cast[int](UProperty.Full_Composition_Exclusion), 1], @[64286, cast[int](UProperty.Full_Composition_Exclusion), 0], @[4362, cast[int](UProperty.NFD_Inert), 1], @[776, cast[int](UProperty.NFD_Inert), 0], @[4452, cast[int](UProperty.NFKD_Inert), 1], @[120733, cast[int](UProperty.NFKD_Inert), 0], @[33, cast[int](UProperty.NFC_Inert), 1], @[97, cast[int](UProperty.NFC_Inert), 0], @[228, cast[int](UProperty.NFC_Inert), 0], @[258, cast[int](UProperty.NFC_Inert), 0], @[44060, cast[int](UProperty.NFC_Inert), 0], @[44061, cast[int](UProperty.NFC_Inert), 1], @[120733, cast[int](UProperty.NFKC_Inert), 0], @[173782, cast[int](UProperty.NFKC_Inert), 1], @[228, cast[int](UProperty.Segment_Starter), 1], @[776, cast[int](UProperty.Segment_Starter), 0], @[4362, cast[int](UProperty.Segment_Starter), 1], @[4452, cast[int](UProperty.Segment_Starter), 0], @[44060, cast[int](UProperty.Segment_Starter), 1], @[44061, cast[int](UProperty.Segment_Starter), 1], @[68, cast[int](UProperty.Hex_Digit), 1], @[65350, cast[int](UProperty.Hex_Digit), 1], @[71, cast[int](UProperty.Hex_Digit), 0], @[12539, cast[int](UProperty.Hyphen), 1], @[65112, cast[int](UProperty.Hyphen), 0], @[8562, cast[int](UProperty.ID_Continue), 1], @[775, cast[int](UProperty.ID_Continue), 1], @[92, cast[int](UProperty.ID_Continue), 0], @[8562, cast[int](UProperty.ID_Start), 1], @[122, cast[int](UProperty.ID_Start), 1], @[57, cast[int](UProperty.ID_Start), 0], @[19893, cast[int](UProperty.Ideographic), 1], @[194969, cast[int](UProperty.Ideographic), 1], @[12185, cast[int](UProperty.Ideographic), 0], @[8204, cast[int](UProperty.Join_Control), 1], @[8233, cast[int](UProperty.Join_Control), 0], @[120764, cast[int](UProperty.Lowercase), 1], @[837, cast[int](UProperty.Lowercase), 1], @[48, cast[int](UProperty.Lowercase), 0], @[120745, cast[int](UProperty.Math), 1], @[8501, cast[int](UProperty.Math), 1], @[98, cast[int](UProperty.Math), 0], @[64993, cast[int](UProperty.Noncharacter_Code_Point), 1], @[1114111, cast[int](UProperty.Noncharacter_Code_Point), 1], @[1114109, cast[int](UProperty.Noncharacter_Code_Point), 0], @[34, cast[int](UProperty.Quotation_Mark), 1], @[65378, cast[int](UProperty.Quotation_Mark), 1], @[55360, cast[int](UProperty.Quotation_Mark), 0], @[1567, cast[int](UProperty.Terminal_Punctuation), 1], @[917567, cast[int](UProperty.Terminal_Punctuation), 0], @[119882, cast[int](UProperty.Uppercase), 1], @[8546, cast[int](UProperty.Uppercase), 1], @[837, cast[int](UProperty.Uppercase), 0], @[32, cast[int](UProperty.White_Space), 1], @[8239, cast[int](UProperty.White_Space), 1], @[12289, cast[int](UProperty.White_Space), 0], @[1809, cast[int](UProperty.XID_Continue), 1], @[119210, cast[int](UProperty.XID_Continue), 1], @[124, cast[int](UProperty.XID_Continue), 0], @[5870, cast[int](UProperty.XID_Start), 1], @[144470, cast[int](UProperty.XID_Start), 1], @[119210, cast[int](UProperty.XID_Start), 0], @[-1, 800, 0], @[6156, cast[int](UProperty.Default_Ignorable_Code_Point), 1], @[65026, cast[int](UProperty.Default_Ignorable_Code_Point), 1], @[6145, cast[int](UProperty.Default_Ignorable_Code_Point), 0], @[329, cast[int](UProperty.Deprecated), 1], @[833, cast[int](UProperty.Deprecated), 0], @[917505, cast[int](UProperty.Deprecated), 1], @[917760, cast[int](UProperty.Deprecated), 0], @[160, cast[int](UProperty.Grapheme_Base), 1], @[2637, cast[int](UProperty.Grapheme_Base), 0], @[65437, cast[int](UProperty.Grapheme_Base), 1], @[65439, cast[int](UProperty.Grapheme_Base), 0], @[768, cast[int](UProperty.Grapheme_Extend), 1], @[65437, cast[int](UProperty.Grapheme_Extend), 0], @[65439, cast[int](UProperty.Grapheme_Extend), 1], @[1539, cast[int](UProperty.Grapheme_Extend), 0], @[2637, cast[int](UProperty.Grapheme_Link), 1], @[65439, cast[int](UProperty.Grapheme_Link), 0], @[12279, cast[int](UProperty.IDS_Binary_Operator), 1], @[12275, cast[int](UProperty.IDS_Binary_Operator), 0], @[12275, cast[int](UProperty.IDS_Trinary_Operator), 1], @[12035, cast[int](UProperty.IDS_Trinary_Operator), 0], @[3777, cast[int](UProperty.Logical_Order_Exception), 1], @[56506, cast[int](UProperty.Logical_Order_Exception), 0], @[11931, cast[int](UProperty.Radical), 1], @[19968, cast[int](UProperty.Radical), 0], @[303, cast[int](UProperty.Soft_Dotted), 1], @[73, cast[int](UProperty.Soft_Dotted), 0], @[64017, cast[int](UProperty.Unified_Ideograph), 1], @[64018, cast[int](UProperty.Unified_Ideograph), 0], @[-1, 1025, 0], @[46, cast[int](UProperty.STerm), 1], @[97, cast[int](UProperty.STerm), 0], @[6156, cast[int](UProperty.Variation_Selector), 1], @[65027, cast[int](UProperty.Variation_Selector), 1], @[917999, cast[int](UProperty.Variation_Selector), 1], @[918016, cast[int](UProperty.Variation_Selector), 0], @[1424, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeft)], @[1487, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeft)], @[1517, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeft)], @[2034, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.DirNonSpacingMark)], @[2046, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeft)], @[2207, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeft)], @[64311, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeft)], @[64322, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeft)], @[67590, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeft)], @[67849, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeft)], @[69604, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeft)], @[1565, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeftArabic)], @[1599, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeftArabic)], @[1806, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeftArabic)], @[1909, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeftArabic)], @[64450, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeftArabic)], @[64912, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeftArabic)], @[65278, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeftArabic)], @[687, cast[int](UProperty.Block), UnicodeBlock.IPA_Extensions.ID], @[3150, cast[int](UProperty.Block), UnicodeBlock.Telugu.ID], @[5466, cast[int](UProperty.Block), UnicodeBlock.Unified_Canadian_Aboriginal_Syllabics.ID], @[5911, cast[int](UProperty.Block), UnicodeBlock.Tagalog.ID], @[6400, cast[int](UProperty.Block), UnicodeBlock.Limbu.ID], @[7359, cast[int](UProperty.Block), UnicodeBlock.NoBlock.ID], @[12352, cast[int](UProperty.Block), UnicodeBlock.Hiragana.ID], @[119039, cast[int](UProperty.Block), UnicodeBlock.Byzantine_Musical_Symbols.ID], @[327680, cast[int](UProperty.Block), UnicodeBlock.NoBlock.ID], @[983039, cast[int](UProperty.Block), UnicodeBlock.NoBlock.ID], @[1102079, cast[int](UProperty.Block), UnicodeBlock.Supplementary_Private_Use_Area_B.ID], @[55255, cast[int](UProperty.Canonical_Combining_Class), 0], @[160, cast[int](UProperty.Decomposition_Type), DecompositionType.NoBreak], @[168, cast[int](UProperty.Decomposition_Type), DecompositionType.Compat], @[191, cast[int](UProperty.Decomposition_Type), DecompositionType.None], @[192, cast[int](UProperty.Decomposition_Type), DecompositionType.Canonical], @[7835, cast[int](UProperty.Decomposition_Type), DecompositionType.Canonical], @[48350, cast[int](UProperty.Decomposition_Type), DecompositionType.Canonical], @[64349, cast[int](UProperty.Decomposition_Type), DecompositionType.Medial], @[120630, cast[int](UProperty.Decomposition_Type), DecompositionType.Font], @[917555, cast[int](UProperty.Decomposition_Type), DecompositionType.None], @[9, cast[int](UProperty.East_Asian_Width), EastAsianWidth.Neutral], @[32, cast[int](UProperty.East_Asian_Width), EastAsianWidth.Narrow], @[177, cast[int](UProperty.East_Asian_Width), EastAsianWidth.Ambiguous], @[8361, cast[int](UProperty.East_Asian_Width), EastAsianWidth.HalfWidth], @[12283, cast[int](UProperty.East_Asian_Width), EastAsianWidth.Wide], @[12288, cast[int](UProperty.East_Asian_Width), EastAsianWidth.FullWidth], @[13755, cast[int](UProperty.East_Asian_Width), EastAsianWidth.Wide], @[22717, cast[int](UProperty.East_Asian_Width), EastAsianWidth.Wide], @[55203, cast[int](UProperty.East_Asian_Width), EastAsianWidth.Wide], @[61166, cast[int](UProperty.East_Asian_Width), EastAsianWidth.Ambiguous], @[119192, cast[int](UProperty.East_Asian_Width), EastAsianWidth.Neutral], @[131072, cast[int](UProperty.East_Asian_Width), EastAsianWidth.Wide], @[194759, cast[int](UProperty.East_Asian_Width), EastAsianWidth.Wide], @[239037, cast[int](UProperty.East_Asian_Width), EastAsianWidth.Wide], @[370109, cast[int](UProperty.East_Asian_Width), EastAsianWidth.Neutral], @[1044206, cast[int](UProperty.East_Asian_Width), EastAsianWidth.Ambiguous], @[1109742, cast[int](UProperty.East_Asian_Width), EastAsianWidth.Ambiguous], @[55239, cast[int](UProperty.General_Category), 0], @[55255, cast[int](UProperty.General_Category), UUnicodeCategory.OtherLetter.ToInt32], @[1092, cast[int](UProperty.Joining_Group), JoiningGroup.NoJoiningGroup], @[1593, cast[int](UProperty.Joining_Group), JoiningGroup.Ain], @[1834, cast[int](UProperty.Joining_Group), JoiningGroup.DalathRish], @[1607, cast[int](UProperty.Joining_Group), JoiningGroup.Heh], @[1729, cast[int](UProperty.Joining_Group), JoiningGroup.HehGoal], @[8204, cast[int](UProperty.Joining_Type), JoiningType.NonJoining], @[8205, cast[int](UProperty.Joining_Type), JoiningType.JoinCausing], @[1593, cast[int](UProperty.Joining_Type), JoiningType.DualJoining], @[1600, cast[int](UProperty.Joining_Type), JoiningType.JoinCausing], @[1731, cast[int](UProperty.Joining_Type), JoiningType.RightJoining], @[768, cast[int](UProperty.Joining_Type), JoiningType.Transparent], @[1807, cast[int](UProperty.Joining_Type), JoiningType.Transparent], @[917555, cast[int](UProperty.Joining_Type), JoiningType.Transparent], @[59367, cast[int](UProperty.Line_Break), LineBreak.Unknown], @[1114109, cast[int](UProperty.Line_Break), LineBreak.Unknown], @[40, cast[int](UProperty.Line_Break), LineBreak.OpenPunctuation], @[9002, cast[int](UProperty.Line_Break), LineBreak.ClosePunctuation], @[13313, cast[int](UProperty.Line_Break), LineBreak.Ideographic], @[19970, cast[int](UProperty.Line_Break), LineBreak.Ideographic], @[131076, cast[int](UProperty.Line_Break), LineBreak.Ideographic], @[63749, cast[int](UProperty.Line_Break), LineBreak.Ideographic], @[56190, cast[int](UProperty.Line_Break), LineBreak.Surrogate], @[56317, cast[int](UProperty.Line_Break), LineBreak.Surrogate], @[57340, cast[int](UProperty.Line_Break), LineBreak.Surrogate], @[10082, cast[int](UProperty.Line_Break), LineBreak.Exclamation], @[47, cast[int](UProperty.Line_Break), LineBreak.BreakSymbols], @[119964, cast[int](UProperty.Line_Break), LineBreak.Alphabetic], @[5937, cast[int](UProperty.Line_Break), LineBreak.Alphabetic], @[4351, cast[int](UProperty.Hangul_Syllable_Type), 0], @[4352, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LeadingJamo], @[4369, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LeadingJamo], @[4441, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LeadingJamo], @[4442, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LeadingJamo], @[4446, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LeadingJamo], @[4447, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LeadingJamo], @[43359, cast[int](UProperty.Hangul_Syllable_Type), 0], @[43360, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LeadingJamo], @[43388, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LeadingJamo], @[43389, cast[int](UProperty.Hangul_Syllable_Type), 0], @[4448, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.VowelJamo], @[4449, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.VowelJamo], @[4466, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.VowelJamo], @[4514, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.VowelJamo], @[4515, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.VowelJamo], @[4519, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.VowelJamo], @[55215, cast[int](UProperty.Hangul_Syllable_Type), 0], @[55216, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.VowelJamo], @[55238, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.VowelJamo], @[55239, cast[int](UProperty.Hangul_Syllable_Type), 0], @[4520, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.TrailingJamo], @[4536, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.TrailingJamo], @[4552, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.TrailingJamo], @[4601, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.TrailingJamo], @[4602, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.TrailingJamo], @[4607, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.TrailingJamo], @[4608, cast[int](UProperty.Hangul_Syllable_Type), 0], @[55242, cast[int](UProperty.Hangul_Syllable_Type), 0], @[55243, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.TrailingJamo], @[55291, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.TrailingJamo], @[55292, cast[int](UProperty.Hangul_Syllable_Type), 0], @[44032, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LvSyllable], @[44060, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LvSyllable], @[50668, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LvSyllable], @[55176, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LvSyllable], @[44033, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LvtSyllable], @[44059, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LvtSyllable], @[44061, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LvtSyllable], @[50670, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LvtSyllable], @[55203, cast[int](UProperty.Hangul_Syllable_Type), HangulSyllableType.LvtSyllable], @[55204, cast[int](UProperty.Hangul_Syllable_Type), 0], @[-1, 1040, 0], @[215, cast[int](UProperty.Pattern_Syntax), 1], @[65093, cast[int](UProperty.Pattern_Syntax), 1], @[97, cast[int](UProperty.Pattern_Syntax), 0], @[32, cast[int](UProperty.Pattern_White_Space), 1], @[133, cast[int](UProperty.Pattern_White_Space), 1], @[8207, cast[int](UProperty.Pattern_White_Space), 1], @[160, cast[int](UProperty.Pattern_White_Space), 0], @[12288, cast[int](UProperty.Pattern_White_Space), 0], @[119296, cast[int](UProperty.Block), UnicodeBlock.Ancient_Greek_Musical_Notation_ID], @[11406, cast[int](UProperty.Block), UnicodeBlock.Coptic_ID], @[65047, cast[int](UProperty.Block), UnicodeBlock.Vertical_Forms_ID], @[6656, cast[int](UProperty.Script), UScript.Buginese], @[11498, cast[int](UProperty.Script), UScript.Coptic], @[43051, cast[int](UProperty.Script), UScript.SylotiNagri], @[66512, cast[int](UProperty.Script), UScript.OldPersian], @[52264, cast[int](UProperty.Line_Break), LineBreak.H2], @[52265, cast[int](UProperty.Line_Break), LineBreak.H3], @[44035, cast[int](UProperty.Line_Break), LineBreak.H3], @[4447, cast[int](UProperty.Line_Break), LineBreak.Jl], @[4522, cast[int](UProperty.Line_Break), LineBreak.Jt], @[4513, cast[int](UProperty.Line_Break), LineBreak.Jv], @[45769, cast[int](UProperty.Grapheme_Cluster_Break), GraphemeClusterBreak.Lvt], @[879, cast[int](UProperty.Grapheme_Cluster_Break), GraphemeClusterBreak.Extend], @[0, cast[int](UProperty.Grapheme_Cluster_Break), GraphemeClusterBreak.Control], @[4448, cast[int](UProperty.Grapheme_Cluster_Break), GraphemeClusterBreak.V], @[1524, cast[int](UProperty.Word_Break), WordBreak.MidLetter], @[20208, cast[int](UProperty.Word_Break), WordBreak.Other], @[6617, cast[int](UProperty.Word_Break), WordBreak.Numeric], @[8260, cast[int](UProperty.Word_Break), WordBreak.MidNum], @[65533, cast[int](UProperty.Sentence_Break), SentenceBreak.Other], @[8188, cast[int](UProperty.Sentence_Break), SentenceBreak.Upper], @[65379, cast[int](UProperty.Sentence_Break), SentenceBreak.Close], @[8232, cast[int](UProperty.Sentence_Break), SentenceBreak.Sep], @[-1, 1312, 0], @[126436, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeft)], @[126948, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeft)], @[42726, cast[int](UProperty.Script), UScript.Bamum], @[42192, cast[int](UProperty.Script), UScript.Lisu], @[68223, cast[int](UProperty.Script), UScript.OldSouthArabian], @[-1, 1536, 0], @[1731, cast[int](UProperty.Joining_Group), JoiningGroup.TehMarbutaGoal], @[-1, 1552, 0], @[2234, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeftArabic)], @[126692, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.RightToLeftArabic)], @[-1, 1584, 0], @[8384, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.EuropeanNumberTerminator)], @[8399, cast[int](UProperty.Bidi_Class), cast[int](UCharacterDirection.EuropeanNumberTerminator)], @[39, cast[int](UProperty.Bidi_Paired_Bracket_Type), BidiPairedBracketType.None], @[40, cast[int](UProperty.Bidi_Paired_Bracket_Type), BidiPairedBracketType.Open], @[41, cast[int](UProperty.Bidi_Paired_Bracket_Type), BidiPairedBracketType.Close], @[65372, cast[int](UProperty.Bidi_Paired_Bracket_Type), BidiPairedBracketType.None], @[65371, cast[int](UProperty.Bidi_Paired_Bracket_Type), BidiPairedBracketType.Open], @[65373, cast[int](UProperty.Bidi_Paired_Bracket_Type), BidiPairedBracketType.Close], @[-1, 1792, 0], @[68287, cast[int](UProperty.Joining_Group), JoiningGroup.NoJoiningGroup], @[68288, cast[int](UProperty.Joining_Group), JoiningGroup.ManichaeanAleph], @[68289, cast[int](UProperty.Joining_Group), JoiningGroup.ManichaeanBeth], @[68335, cast[int](UProperty.Joining_Group), JoiningGroup.ManichaeanHundred], @[68336, cast[int](UProperty.Joining_Group), JoiningGroup.NoJoiningGroup], @[-1, 2560, 0], @[127461, cast[int](UProperty.Regional_Indicator), FALSE], @[127463, cast[int](UProperty.Regional_Indicator), TRUE], @[127487, cast[int](UProperty.Regional_Indicator), TRUE], @[127488, cast[int](UProperty.Regional_Indicator), FALSE], @[1536, cast[int](UProperty.Prepended_Concatenation_Mark), TRUE], @[1542, cast[int](UProperty.Prepended_Concatenation_Mark), FALSE], @[69821, cast[int](UProperty.Prepended_Concatenation_Mark), TRUE], @[97, 1191, 0], @[144572, 5613, 0]]
    if UChar.GetIntPropertyMinValue(UProperty.Dash) != 0 || UChar.GetIntPropertyMinValue(UProperty.Bidi_Class) != 0 || UChar.GetIntPropertyMinValue(UProperty.Block) != 0 || UChar.GetIntPropertyMinValue(UProperty.Script) != 0 || UChar.GetIntPropertyMinValue(cast[UProperty](9029)) != 0:
Errln("error: UCharacter.getIntPropertyMinValue() wrong")
    if UChar.GetIntPropertyMaxValue(UProperty.Dash) != 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.DASH) wrong
")
    if UChar.GetIntPropertyMaxValue(UProperty.ID_Continue) != 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.ID_CONTINUE) wrong
")
    if UChar.GetIntPropertyMaxValue(UPropertyConstants.Binary_Limit - 1) != 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.BINARY_LIMIT-1) wrong
")
    if UChar.GetIntPropertyMaxValue(UProperty.Bidi_Class) != UCharacterDirectionExtensions.CharDirectionCount.ToInt32 - 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.BIDI_CLASS) wrong
")
    if UChar.GetIntPropertyMaxValue(UProperty.Block) != UnicodeBlock.Count - 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.BLOCK) wrong
")
    if UChar.GetIntPropertyMaxValue(UProperty.Line_Break) != LineBreak.Count - 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.LINE_BREAK) wrong
")
    if UChar.GetIntPropertyMaxValue(UProperty.Script) != UScript.CodeLimit - 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.SCRIPT) wrong
")
    if UChar.GetIntPropertyMaxValue(UProperty.Numeric_Type) != NumericType.Count - 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.NUMERIC_TYPE) wrong
")
    if UChar.GetIntPropertyMaxValue(UProperty.General_Category) != UUnicodeCategoryExtensions.CharCategoryCount - 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.GENERAL_CATEGORY) wrong
")
    if UChar.GetIntPropertyMaxValue(UProperty.Hangul_Syllable_Type) != HangulSyllableType.Count - 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.HANGUL_SYLLABLE_TYPE) wrong
")
    if UChar.GetIntPropertyMaxValue(UProperty.Grapheme_Cluster_Break) != GraphemeClusterBreak.Count - 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.GRAPHEME_CLUSTER_BREAK) wrong
")
    if UChar.GetIntPropertyMaxValue(UProperty.Sentence_Break) != SentenceBreak.Count - 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.SENTENCE_BREAK) wrong
")
    if UChar.GetIntPropertyMaxValue(UProperty.Word_Break) != WordBreak.Count - 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.WORD_BREAK) wrong
")
    if UChar.GetIntPropertyMaxValue(UProperty.Bidi_Paired_Bracket_Type) != BidiPairedBracketType.Count - 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.BIDI_PAIRED_BRACKET_TYPE) wrong
")
    if UChar.GetIntPropertyMaxValue(cast[UProperty](9029)) != -1:
Errln("error: UCharacter.getIntPropertyMaxValue(0x2345) wrong
")
    if UChar.GetIntPropertyMaxValue(UProperty.Decomposition_Type) != DecompositionType.Count - 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.DECOMPOSITION_TYPE) wrong
")
    if UChar.GetIntPropertyMaxValue(UProperty.Joining_Group) != JoiningGroup.Count - 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.JOINING_GROUP) wrong
")
    if UChar.GetIntPropertyMaxValue(UProperty.Joining_Type) != JoiningType.Count - 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.JOINING_TYPE) wrong
")
    if UChar.GetIntPropertyMaxValue(UProperty.East_Asian_Width) != EastAsianWidth.Count - 1:
Errln("error: UCharacter.getIntPropertyMaxValue(UProperty.EAST_ASIAN_WIDTH) wrong
")
    var version: VersionInfo = UChar.UnicodeVersion
      var i: int = 0
      while i < props.Length:
          var which: int = props[i][1]
          if props[i][0] < 0:
              if version.CompareTo(VersionInfo.GetInstance(which >> 8, which >> 4 & 15, which & 15, 0)) < 0:
                  break
              continue
          var whichName: String
          try:
              whichName = UChar.GetPropertyName(cast[UProperty](which), NameChoice.Long)
          except ArgumentException:
              whichName = "undefined UProperty value"
          var expect: bool = true
          if props[i][2] == 0:
              expect = false
          if cast[UProperty](which) < UPropertyConstants.Int_Start:
              if UChar.HasBinaryProperty(props[i][0], cast[UProperty](which)) != expect:
Errln("error: UCharacter.hasBinaryProperty(U+" + Utility.Hex(props[i][0], 4) + ", " + whichName + ") has an error, expected=" + expect)
          var retVal: int = UChar.GetIntPropertyValue(props[i][0], cast[UProperty](which))
          if retVal != props[i][2]:
Errln("error: UCharacter.getIntPropertyValue(U+" + Utility.Hex(props[i][0], 4) + ", " + whichName + ") is wrong, expected=" + props[i][2] + " actual=" + retVal)
          case cast[UProperty](which)
          of UProperty.Alphabetic:
              if UChar.IsUAlphabetic(props[i][0]) != expect:
Errln("error: UCharacter.isUAlphabetic(\u" + props[i][0].ToHexString + ") is wrong expected " + props[i][2])
              break
          of UProperty.Lowercase:
              if UChar.IsULower(props[i][0]) != expect:
Errln("error: UCharacter.isULowercase(\u" + props[i][0].ToHexString + ") is wrong expected " + props[i][2])
              break
          of UProperty.Uppercase:
              if UChar.IsUUpper(props[i][0]) != expect:
Errln("error: UCharacter.isUUppercase(\u" + props[i][0].ToHexString + ") is wrong expected " + props[i][2])
              break
          of UProperty.White_Space:
              if UChar.IsUWhiteSpace(props[i][0]) != expect:
Errln("error: UCharacter.isUWhiteSpace(\u" + props[i][0].ToHexString + ") is wrong expected " + props[i][2])
              break
          else:
              break
++i
proc TestNumericProperties*() =
    var values: double[][] = @[@[3891, NumericType.Numeric, -1.0 / 2.0], @[3174, NumericType.Decimal, 0], @[38646, NumericType.Numeric, 0], @[43059, NumericType.Numeric, 1.0 / 16.0], @[8530, NumericType.Numeric, 1.0 / 10.0], @[8529, NumericType.Numeric, 1.0 / 9.0], @[74847, NumericType.Numeric, 1.0 / 8.0], @[8528, NumericType.Numeric, 1.0 / 7.0], @[8537, NumericType.Numeric, 1.0 / 6.0], @[2550, NumericType.Numeric, 3.0 / 16.0], @[8533, NumericType.Numeric, 1.0 / 5.0], @[189, NumericType.Numeric, 1.0 / 2.0], @[49, NumericType.Decimal, 1.0], @[19968, NumericType.Numeric, 1.0], @[22769, NumericType.Numeric, 1.0], @[66336, NumericType.Numeric, 1.0], @[3883, NumericType.Numeric, 3.0 / 2.0], @[178, NumericType.Digit, 2.0], @[24336, NumericType.Numeric, 2.0], @[6163, NumericType.Decimal, 3.0], @[24334, NumericType.Numeric, 3.0], @[8563, NumericType.Numeric, 4.0], @[32902, NumericType.Numeric, 4.0], @[10126, NumericType.Digit, 5.0], @[120818, NumericType.Decimal, 6.0], @[9338, NumericType.Digit, 7.0], @[29590, NumericType.Numeric, 9.0], @[4978, NumericType.Numeric, 10.0], @[8555, NumericType.Numeric, 12.0], @[5870, NumericType.Numeric, 17.0], @[9370, NumericType.Numeric, 19.0], @[12346, NumericType.Numeric, 30.0], @[21317, NumericType.Numeric, 30.0], @[12978, NumericType.Numeric, 37.0], @[4981, NumericType.Numeric, 40.0], @[66339, NumericType.Numeric, 50.0], @[3057, NumericType.Numeric, 100.0], @[38476, NumericType.Numeric, 100.0], @[8574, NumericType.Numeric, 500.0], @[8576, NumericType.Numeric, 1000.0], @[20191, NumericType.Numeric, 1000.0], @[8577, NumericType.Numeric, 5000.0], @[4988, NumericType.Numeric, 10000.0], @[19975, NumericType.Numeric, 10000.0], @[74802, NumericType.Numeric, 216000.0], @[74803, NumericType.Numeric, 432000.0], @[20159, NumericType.Numeric, 100000000.0], @[20806, NumericType.Numeric, 1000000000000.0], @[-1, NumericType.None, UChar.NoNumericValue], @[97, NumericType.None, UChar.NoNumericValue, 10.0], @[12288, NumericType.None, UChar.NoNumericValue], @[65534, NumericType.None, UChar.NoNumericValue], @[66305, NumericType.None, UChar.NoNumericValue], @[917555, NumericType.None, UChar.NoNumericValue], @[1114111, NumericType.None, UChar.NoNumericValue], @[1114112, NumericType.None, UChar.NoNumericValue]]
      var i: int = 0
      while i < values.Length:
          var c: int = cast[int](values[i][0])
          var type: int = UChar.GetIntPropertyValue(c, UProperty.Numeric_Type)
          var nv: double = UChar.GetUnicodeNumericValue(c)
          if type != values[i][1]:
Errln("UProperty.NUMERIC_TYPE(\u" + Utility.Hex(c, 4) + ") = " + type + " should be " + cast[int](values[i][1]))
          if 0.000001 <= Math.Abs(nv - values[i][2]):
Errln("UCharacter.getUnicodeNumericValue(\u" + Utility.Hex(c, 4) + ") = " + nv + " should be " + values[i][2])
          var expectedInt: int
          if values[i].Length == 3:
              if values[i][2] == UChar.NoNumericValue:
                  expectedInt = -1
              else:
                  expectedInt = cast[int](values[i][2])
                  if expectedInt < 0 || expectedInt != values[i][2]:
                      expectedInt = -2
          else:
              expectedInt = cast[int](values[i][3])
          var nvInt: int = UChar.GetNumericValue(c)
          if nvInt != expectedInt:
Errln("UCharacter.getNumericValue(\u" + Utility.Hex(c, 4) + ") = " + nvInt + " should be " + expectedInt)
++i
proc TestPropertyValues*() =
      var i: UProperty
      var p: UProperty
      var min: int
      var max: int
      p = UPropertyConstants.Int_Start
      while p < UPropertyConstants.Int_Limit:
          min = UChar.GetIntPropertyMinValue(p)
          if min != 0:
              if p == UProperty.Block:

              else:
                  var name: String
                  name = UChar.GetPropertyName(p, NameChoice.Long)
Errln("FAIL: UCharacter.getIntPropertyMinValue(" + name + ") = " + min + ", exp. 0")
++p
    if UChar.GetIntPropertyMinValue(UProperty.General_Category_Mask) != 0 || UChar.GetIntPropertyMaxValue(UProperty.General_Category_Mask) != -1:
Errln("error: UCharacter.getIntPropertyMin/MaxValue(" + "UProperty.GENERAL_CATEGORY_MASK) is wrong")
    max = UChar.GetIntPropertyMaxValue(cast[UProperty](-1))
    if max != -1:
Errln("FAIL: UCharacter.getIntPropertyMaxValue(-1) = " + max + ", exp. -1")
      i = 0
      while cast[int](i) < 2:
          try:
              var script: int = 0
              var desc: String = nil
              case cast[int](i)
              of 0:
                  script = UScript.GetScript(-1)
                  desc = "UScript.getScript(-1)"
                  break
              of 1:
                  script = UChar.GetIntPropertyValue(-1, UProperty.Script)
                  desc = "UCharacter.getIntPropertyValue(-1, UProperty.SCRIPT)"
                  break
              if script != 0:
Errln("FAIL: " + desc + " = " + script + ", exp. 0")
          except ArgumentException:

++i
proc TestBidiPairedBracketType*() =
    var bpt: UnicodeSet = UnicodeSet("[:^bpt=n:]")
assertTrue("bpt!=None is not empty", !bpt.IsEmpty)
    var mirrored: UnicodeSet = UnicodeSet("[:Bidi_M:]")
    var other_neutral: UnicodeSet = UnicodeSet("[:bc=ON:]")
assertTrue("bpt!=None is a subset of Bidi_M", mirrored.ContainsAll(bpt))
assertTrue("bpt!=None is a subset of bc=ON", other_neutral.ContainsAll(bpt))
    var bpt_open: UnicodeSet = UnicodeSet("[:bpt=o:]")
    var bpt_close: UnicodeSet = UnicodeSet("[:bpt=c:]")
    var ps: UnicodeSet = UnicodeSet("[:Ps:]")
    var pe: UnicodeSet = UnicodeSet("[:Pe:]")
assertTrue("bpt=Open is a subset of Ps", ps.ContainsAll(bpt_open))
assertTrue("bpt=Close is a subset of Pe", pe.ContainsAll(bpt_close))
proc TestEmojiProperties*() =
assertFalse("space is not Emoji", UChar.HasBinaryProperty(32, UProperty.Emoji))
assertTrue("shooting star is Emoji", UChar.HasBinaryProperty(127776, UProperty.Emoji))
    var emoji: UnicodeSet = UnicodeSet("[:Emoji:]")
assertTrue("lots of Emoji", emoji.Count > 700)
assertTrue("shooting star is Emoji_Presentation", UChar.HasBinaryProperty(127776, UProperty.Emoji_Presentation))
assertTrue("Fitzpatrick 6 is Emoji_Modifier", UChar.HasBinaryProperty(127999, UProperty.Emoji_Modifier))
assertTrue("happy person is Emoji_Modifier_Base", UChar.HasBinaryProperty(128587, UProperty.Emoji_Modifier_Base))
assertTrue("asterisk is Emoji_Component", UChar.HasBinaryProperty(42, UProperty.Emoji_Component))
proc TestIsBMP*() =
    var ch: int[] = @[0, -1, 65535, 1114111, 255, 131071]
    var flag: bool[] = @[true, false, true, false, true, false]
      var i: int = 0
      while i < ch.Length:
          if UChar.IsBMP(ch[i]) != flag[i]:
Errln("Fail: \u" + Utility.Hex(ch[i], 8) + " failed at UCharacter.isBMP")
++i
proc ShowADiffB(a: UnicodeSet, b: UnicodeSet, a_name: String, b_name: String, expect: bool, diffIsError: bool): bool =
      var i: int
      var start: int
      var end: int
    var equal: bool = true
      i = 0
      while i < a.RangeCount:
          start = a.GetRangeStart(i)
          end = a.GetRangeEnd(i)
          if expect != b.Contains(start, end):
              equal = false
              while start <= end:
                  if expect != b.Contains(start):
                      if diffIsError:
                          if expect:
Errln("error: " + a_name + " contains " + Hex(start) + " but " + b_name + " does not")
                          else:
Errln("error: " + a_name + " and " + b_name + " both contain " + Hex(start) + " but should not intersect")
                      else:
                          if expect:
Logln("info: " + a_name + " contains " + Hex(start) + "but " + b_name + " does not")
                          else:
Logln("info: " + a_name + " and " + b_name + " both contain " + Hex(start) + " but should not intersect")
++start
++i
    return equal
proc ShowAMinusB(a: UnicodeSet, b: UnicodeSet, a_name: String, b_name: String, diffIsError: bool): bool =
    return ShowADiffB(a, b, a_name, b_name, true, diffIsError)
proc ShowAIntersectB(a: UnicodeSet, b: UnicodeSet, a_name: String, b_name: String, diffIsError: bool): bool =
    return ShowADiffB(a, b, a_name, b_name, false, diffIsError)
proc CompareUSets(a: UnicodeSet, b: UnicodeSet, a_name: String, b_name: String, diffIsError: bool): bool =
    return ShowAMinusB(a, b, a_name, b_name, diffIsError) && ShowAMinusB(b, a, b_name, a_name, diffIsError)
proc TestConsistency*() =
      var set1: UnicodeSet
      var set2: UnicodeSet
      var set3: UnicodeSet
      var set4: UnicodeSet
      var start: int
      var end: int
      var i: int
      var length: int
    var hyphenPattern: String = "[:Hyphen:]"
    var dashPattern: String = "[:Dash:]"
    var lowerPattern: String = "[:Lowercase:]"
    var formatPattern: String = "[:Cf:]"
    var alphaPattern: String = "[:Alphabetic:]"
Logln("Starting with Unicode 4, inconsistencies with [:Hyphen:] are
" + "known to the UTC and not considered errors.
")
    set1 = UnicodeSet(hyphenPattern)
    set2 = UnicodeSet(dashPattern)
set1.Remove(12539)
set2.Remove(65381)
ShowAMinusB(set1, set2, "[:Hyphen:]", "[:Dash:]", false)
    set3 = UnicodeSet(formatPattern)
    set4 = UnicodeSet(alphaPattern)
ShowAIntersectB(set3, set1, "[:Cf:]", "[:Hyphen:]", false)
ShowAIntersectB(set3, set2, "[:Cf:]", "[:Dash:]", true)
ShowAIntersectB(set3, set4, "[:Cf:]", "[:Alphabetic:]", true)
    set1 = UnicodeSet(lowerPattern)
      i = 0
      while true:
          start = set1.GetRangeStart(i)
          end = set1.GetRangeEnd(i)
          length =           if i < set1.RangeCount:
set1.RangeCount
          else:
0
          if length != 0:
              break
          while start <= end:
              var name: String = UChar.GetName(start)
              if name.IndexOf("SMALL", StringComparison.Ordinal) < 0 || name.IndexOf("CAPITAL", StringComparison.Ordinal) < -1 && name.IndexOf("SMALL CAPITAL", StringComparison.Ordinal) == -1:
Logln("info: [:Lowercase:] contains U+" + Hex(start) + " whose name does not suggest lowercase: " + name)
++start
++i
    var norm2: Normalizer2 = Normalizer2.NFDInstance
    set1 = UnicodeSet
Norm2AllModes.NFCInstance.Impl.EnsureCanonIterData.GetCanonStartSet(73, set1)
    set2 = UnicodeSet
      start = 160
      while start < 8192:
          var decomp: String = norm2.Normalize(UTF16.ValueOf(start))
          if decomp.Length > 1 && decomp[0] == 73:
set2.Add(start)
++start
CompareUSets(set1, set2, "[canon start set of 0049]", "[all c with canon decomp with 0049]", false)
proc TestCoverage*() =
    var ch1: char = UChar.ForDigit(7, 11)
assertEquals("UCharacter.forDigit ", "7", ch1 + "")
    var ch2: char = UChar.ForDigit(17, 20)
assertEquals("UCharacter.forDigit ", "h", ch2 + "")
    var spaces: char[] = @['	', '
', '', '', ' ']
      var i: int = 0
      while i < spaces.Length:
          if !UChar.IsSpace(spaces[i]):
Errln("FAIL \u" + Hex(spaces[i]) + " expected to be a Java space")
++i
proc TestBlockData*() =
    var ubc: Type = type(UnicodeBlock)
      var b: int = 1
      while b < UnicodeBlock.Count:
          var blk: UnicodeBlock = UnicodeBlock.GetInstance(b)
          var id: int = blk.ID
          var name: String = blk.ToString
          if id != b:
Errln("UCharacter.UnicodeBlock.GetInstance(" + b + ") returned a block with id = " + id)
          try:
              if cast[int](ubc.GetField(name + "_ID").GetValue(blk)) != b:
Errln("UCharacter.UnicodeBlock.GetInstance(" + b + ") returned a block with a name of " + name + " which does not match the block id.")
          except Exception:
Errln("Couldn't get the id name for id " + b)
          b = 1
proc TestGetInstance*() =
    var invalid_test: int[] = @[-1, -10, -100]
      var i: int = 0
      while i < invalid_test.Length:
          if UnicodeBlock.Invalid_Code != UnicodeBlock.GetInstance(invalid_test[i]):
Errln("UCharacter.UnicodeBlock.GetInstance(invalid_test[i]) was " + "suppose to return UCharacter.UnicodeBlock.INVALID_CODE. Got " + UnicodeBlock.GetInstance(invalid_test[i]) + ". Expected " + UnicodeBlock.Invalid_Code)
++i
proc TestOf*() =
    if UnicodeBlock.Invalid_Code != UnicodeBlock.Of(UTF16.CodePointMaxValue + 1):
Errln("UCharacter.UnicodeBlock.of(UTF16.CODEPOINT_MAX_VALUE+1) was " + "suppose to return UCharacter.UnicodeBlock.INVALID_CODE. Got " + UnicodeBlock.Of(UTF16.CodePointMaxValue + 1) + ". Expected " + UnicodeBlock.Invalid_Code)
proc TestForName*() =

proc TestGetNumericValue*() =
    var valid_values: int[] = @[3058, 3442, 4988, 8558, 8559, 8574, 8575, 8576, 8577, 8578, 8583, 8584, 19975, 20159, 20191, 20740, 20806, 21315, 33836, 38433, 65819, 65820, 65821, 65822, 65823, 65824, 65825, 65826, 65827, 65828, 65829, 65830, 65831, 65832, 65833, 65834, 65835, 65836, 65837, 65838, 65839, 65840, 65841, 65842, 65843, 65861, 65862, 65863, 65868, 65869, 65870, 65875, 65876, 65877, 65878, 65899, 65900, 65901, 65902, 65903, 65904, 65905, 65906, 66378, 68167]
    var results: int[] = @[1000, 1000, 10000, 500, 1000, 500, 1000, 1000, 5000, 10000, 50000, 100000, 10000, 100000000, 1000, 100000000, -2, 1000, 10000, 1000, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 20000, 30000, 40000, 50000, 60000, 70000, 80000, 90000, 500, 5000, 50000, 500, 1000, 5000, 500, 1000, 10000, 50000, 300, 500, 500, 500, 500, 500, 1000, 5000, 900, 1000]
    if valid_values.Length != results.Length:
Errln("The valid_values array and the results array need to be " + "the same length.")
    else:
          var i: int = 0
          while i < valid_values.Length:
              try:
                  if UChar.GetNumericValue(valid_values[i]) != results[i]:
Errln("UCharacter.getNumericValue(i) returned a " + "different value from the expected result. " + "Got " + UChar.GetNumericValue(valid_values[i]) + "Expected" + results[i])
              except Exception:
Errln("UCharacter.getNumericValue(int) returned an exception " + "with the parameter value")
++i
proc TestGetUnicodeNumericValue*() =

proc TestToString*() =
    var valid_tests: int[] = @[UChar.MinValue, UChar.MinValue + 1, UChar.MaxValue - 1, UChar.MaxValue]
    var invalid_tests: int[] = @[UChar.MinValue - 1, UChar.MinValue - 2, UChar.MaxValue + 1, UChar.MaxValue + 2]
      var i: int = 0
      while i < valid_tests.Length:
          if UChar.ConvertFromUtf32(valid_tests[i]) == nil:
Errln("UCharacter.toString(int) was not suppose to return " + "null because it was given a valid parameter. Value passed: " + valid_tests[i] + ". Got null.")
++i
      var i: int = 0
      while i < invalid_tests.Length:
          if UChar.ConvertFromUtf32(invalid_tests[i]) != nil:
Errln("UCharacter.toString(int) was suppose to return " + "null because it was given an invalid parameter. Value passed: " + invalid_tests[i] + ". Got: " + UChar.ConvertFromUtf32(invalid_tests[i]))
++i
proc TestGetCombiningClass*() =
    var valid_tests: int[] = @[UChar.MinValue, UChar.MinValue + 1, UChar.MaxValue - 1, UChar.MaxValue]
    var invalid_tests: int[] = @[UChar.MinValue - 1, UChar.MinValue - 2, UChar.MaxValue + 1, UChar.MaxValue + 2]
      var i: int = 0
      while i < valid_tests.Length:
          try:
UChar.GetCombiningClass(valid_tests[i])
          except Exception:
Errln("UCharacter.getCombiningClass(int) was not supposed to have " + "an exception. Value passed: " + valid_tests[i])
++i
      var i: int = 0
      while i < invalid_tests.Length:
          try:
assertEquals("getCombiningClass(out of range)", 0, UChar.GetCombiningClass(invalid_tests[i]))
          except Exception:
Errln("UCharacter.getCombiningClass(int) was not supposed to have " + "an exception. Value passed: " + invalid_tests[i])
++i
proc TestGetName*() =
    var data: String[] = @["a", "z"]
    var results: String[] = @["LATIN SMALL LETTER A", "LATIN SMALL LETTER Z"]
    if data.Length != results.Length:
Errln("The data array and the results array need to be " + "the same length.")
    else:
          var i: int = 0
          while i < data.Length:
              if UChar.GetName(data[i], "").CompareToOrdinal(results[i]) != 0:
Errln("UCharacter.getName(String, String) was suppose " + "to have the same result for the data in the parameter. " + "Value passed: " + data[i] + ". Got: " + UChar.GetName(data[i], "") + ". Expected: " + results[i])
++i
proc TestGetISOComment*() =
    var invalid_tests: int[] = @[UChar.MinValue - 1, UChar.MinValue - 2, UChar.MaxValue + 1, UChar.MaxValue + 2]
      var i: int = 0
      while i < invalid_tests.Length:
          if UChar.GetISOComment(invalid_tests[i]) != nil:
Errln("UCharacter.getISOComment(int) was suppose to return " + "null because it was given an invalid parameter. Value passed: " + invalid_tests[i] + ". Got: " + UChar.GetISOComment(invalid_tests[i]))
++i
proc TestSetLimit*() =

proc TestNextCaseMapCP*() =

proc TestReset*() =

proc TestToTitleCaseCoverage*() =
    var locale: String[] = @["en", "fr", "zh", "ko", "ja", "it", "de", ""]
      var i: int = 0
      while i < locale.Length:
UChar.ToTitleCase(CultureInfo(locale[i]), "", nil)
++i
UChar.ToTitleCase(cast[UCultureInfo](nil), "", nil, 0)
proc TestToTitleCase_Locale_String_BreakIterator_I*() =
    var titleCase: String = UChar.ToTitleCase(CultureInfo("nl"), "ijsland", nil, UChar.FoldCaseDefault)
assertEquals("Wrong title casing", "IJsland", titleCase)
proc TestToTitleCase_String_BreakIterator_en*() =
    var titleCase: String = UChar.ToTitleCase(CultureInfo("en"), "ijsland", nil)
assertEquals("Wrong title casing", "Ijsland", titleCase)
proc TestToUpperCase*() =

proc TestToLowerCase*() =
    var cases: String[] = @["", "a", "A", "z", "Z", "Dummy", "DUMMY", "dummy", "a z", "A Z", "'", """, "0", "9", "0a", "a0", "*", "~!@#$%^&*()_+"]
      var i: int = 0
      while i < cases.Length:
          try:
UChar.ToLower(cast[UCultureInfo](nil), cases[i])
          except Exception:
Errln("UCharacter.toLowerCase was not suppose to return an " + "exception for input of null and string: " + cases[i])
++i
proc TestGetHanNumericValue*() =
    var valid: int[] = @[12295, 38646, 19968, 22777, 20108, 36019, 19977, 21443, 22235, 32902, 20116, 20237, 20845, 38520, 19971, 26578, 20843, 25420, 20061, 29590, 21313, 25342, 30334, 20336, 21315, 20191, 33356, 20740]
    var invalid: int[] = @[-5, -2, -1, 0]
    var results: int[] = @[0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 100, 100, 1000, 1000, 10000, 100000000]
    if valid.Length != results.Length:
Errln("The arrays valid and results are suppose to be the same length " + "to test getHanNumericValue(int ch).")
    else:
          var i: int = 0
          while i < valid.Length:
              if UChar.GetHanNumericValue(valid[i]) != results[i]:
Errln("UCharacter.getHanNumericValue does not return the " + "same result as expected. Passed value: " + valid[i] + ". Got: " + UChar.GetHanNumericValue(valid[i]) + ". Expected: " + results[i])
++i
      var i: int = 0
      while i < invalid.Length:
          if UChar.GetHanNumericValue(invalid[i]) != -1:
Errln("UCharacter.getHanNumericValue does not return the " + "same result as expected. Passed value: " + invalid[i] + ". Got: " + UChar.GetHanNumericValue(invalid[i]) + ". Expected: -1")
++i
proc TestHasBinaryProperty*() =
    var invalid: int[] = @[UChar.MinValue - 1, UChar.MinValue - 2, UChar.MaxValue + 1, UChar.MaxValue + 2]
    var valid: int[] = @[UChar.MinValue, UChar.MinValue + 1, UChar.MaxValue, UChar.MaxValue - 1]
      var i: int = 0
      while i < invalid.Length:
          try:
              if UChar.HasBinaryProperty(invalid[i], cast[UProperty](1)):
Errln("UCharacter.hasBinaryProperty(ch, property) should return " + "false for out-of-range code points but " + "returns true for " + invalid[i])
          except Exception:
Errln("UCharacter.hasBinaryProperty(ch, property) should not " + "throw an exception for any input. Value passed: " + invalid[i])
++i
      var i: int = 0
      while i < valid.Length:
          try:
UChar.HasBinaryProperty(valid[i], cast[UProperty](1))
          except Exception:
Errln("UCharacter.hasBinaryProperty(ch, property) should not " + "throw an exception for any input. Value passed: " + valid[i])
++i
proc TestGetIntPropertyValue*() =
    var negative_cases: int[] = @[-100, -50, -10, -5, -2, -1]
      var i: int = 0
      while i < negative_cases.Length:
          if UChar.GetIntPropertyValue(0, cast[UProperty](negative_cases[i])) != 0:
Errln("UCharacter.getIntPropertyValue(ch, type) was suppose to return 0 " + "when passing a negative value of " + negative_cases[i])
++i
      var i: int = Hangul.JamoLBase - 5
      while i < Hangul.JamoLBase:
          if UChar.GetIntPropertyValue(i, UProperty.Hangul_Syllable_Type) != 0:
Errln("UCharacter.getIntPropertyValue(ch, type) was suppose to return 0 " + "when passing ch: " + i + "and type of Property.HANGUL_SYLLABLE_TYPE")
++i
      var i: int = Hangul.HangulBase - 5
      while i < Hangul.HangulBase:
          if UChar.GetIntPropertyValue(i, UProperty.Hangul_Syllable_Type) != 0:
Errln("UCharacter.getIntPropertyValue(ch, type) was suppose to return 0 " + "when passing ch: " + i + "and type of Property.HANGUL_SYLLABLE_TYPE")
++i
proc TestGetIntPropertyMaxValue*() =
    var cases: UProperty[] = @[UPropertyConstants.Binary_Limit, UPropertyConstants.Binary_Limit + 1, UPropertyConstants.Int_Start - 2, UPropertyConstants.Int_Start - 1]
      var i: int = 0
      while i < cases.Length:
          if UChar.GetIntPropertyMaxValue(cases[i]) != -1:
Errln("UCharacter.getIntPropertyMaxValue was suppose to return -1 " + "but got " + UChar.GetIntPropertyMaxValue(cases[i]))
++i
proc TestCodePointAt*() =
    var cases: String[] = @["�", "�", "�"]
    var result: int[] = @[55296, 56319, 56318]
      var i: int = 0
      while i < cases.Length:
          if UChar.CodePointAt(cases[i], 0) != result[i]:
Errln("UCharacter.CodePointAt(CharSequence ...) did not return as expected. " + "Passed value: " + cases[i] + ". Expected: " + result[i] + ". Got: " + UChar.CodePointAt(cases[i], 0))
          if UChar.CodePointAt(cases[i].ToCharArray, 0) != result[i]:
Errln("UCharacter.CodePointAt(char[] ...) did not return as expected. " + "Passed value: " + cases[i] + ". Expected: " + result[i] + ". Got: " + UChar.CodePointAt(cases[i].ToCharArray, 0))
          if UChar.CodePointAt(cases[i].ToCharArray, 0, 1) != result[i]:
Errln("UCharacter.CodePointAt(char[], int, int) did not return as expected. " + "Passed value: " + cases[i] + ". Expected: " + result[i] + ". Got: " + UChar.CodePointAt(cases[i].ToCharArray, 0, 1))
++i
    var empty_text: char[] = @[]
    var one_char_text: char[] = @['a']
    var reg_text: char[] = @['d', 'u', 'm', 'm', 'y']
    var limitCases: int[] = @[2, 3, 5, 10, 25]
      var i: int = 0
      while i < limitCases.Length:
          try:
UChar.CodePointAt(reg_text, 100, limitCases[i])
Errln("UCharacter.codePointAt was suppose to return an exception " + "but got " + UChar.CodePointAt(reg_text, 100, limitCases[i]) + ". The following passed parameters were Text: " + string(reg_text) + ", Start: " + 100 + ", Limit: " + limitCases[i] + ".")
          except Exception:

++i
      var i: int = 0
      while i < limitCases.Length:
          try:
UChar.CodePointAt(empty_text, 0, limitCases[i])
Errln("UCharacter.codePointAt was suppose to return an exception " + "but got " + UChar.CodePointAt(empty_text, 0, limitCases[i]) + ". The following passed parameters were Text: " + string(empty_text) + ", Start: " + 0 + ", Limit: " + limitCases[i] + ".")
          except Exception:

          try:
UChar.CodePointCount(one_char_text.AsSpan(0, limitCases[i]))
Errln("UCharacter.codePointCount was suppose to return an exception " + "but got " + UChar.CodePointCount(one_char_text.AsSpan(0, limitCases[i])) + ". The following passed parameters were Text: " + string(one_char_text) + ", Start: " + 0 + ", Limit: " + limitCases[i] + ".")
          except Exception:

++i
proc TestCodePointBefore*() =
    var cases: String[] = @["�", "�", "�"]
    var result: int[] = @[56320, 57343, 56830]
      var i: int = 0
      while i < cases.Length:
          if UChar.CodePointBefore(cases[i], 1) != result[i]:
Errln("UCharacter.CodePointBefore(CharSequence ...) did not return as expected. " + "Passed value: " + cases[i] + ". Expected: " + result[i] + ". Got: " + UChar.CodePointBefore(cases[i], 1))
          if UChar.CodePointBefore(cases[i].ToCharArray, 1) != result[i]:
Errln("UCharacter.CodePointBefore(char[] ...) did not return as expected. " + "Passed value: " + cases[i] + ". Expected: " + result[i] + ". Got: " + UChar.CodePointBefore(cases[i].ToCharArray, 1))
          if UChar.CodePointBefore(cases[i].ToCharArray, 1, 0) != result[i]:
Errln("UCharacter.CodePointBefore(char[], int, int) did not return as expected. " + "Passed value: " + cases[i] + ". Expected: " + result[i] + ". Got: " + UChar.CodePointBefore(cases[i].ToCharArray, 1, 0))
++i
    var dummy: char[] = @['d', 'u', 'm', 'm', 'y']
    var negative_cases: int[] = @[-100, -10, -5, -2, -1]
    var index_cases: int[] = @[0, 1, 2, 5, 10, 100]
      var i: int = 0
      while i < negative_cases.Length:
          try:
UChar.CodePointBefore(dummy, 10000, negative_cases[i])
Errln("UCharacter.CodePointBefore(text, index, limit) was suppose to return an exception " + "when the parameter limit of " + negative_cases[i] + " is a negative number.")
          except Exception:

++i
      var i: int = 0
      while i < index_cases.Length:
          try:
UChar.CodePointBefore(dummy, index_cases[i], 101)
Errln("UCharacter.CodePointBefore(text, index, limit) was suppose to return an exception " + "when the parameter index of " + index_cases[i] + " is a negative number.")
          except Exception:

++i
proc TestToChars*() =
    var positive_cases: int[] = @[1, 2, 5, 10, 100]
    var dst: char[] = @['a']
      var i: int = 0
      while i < positive_cases.Length:
          try:
UChar.ToChars(-1 * positive_cases[i], dst, 0)
Errln("UCharacter.toChars(int,char[],int) was suppose to return an exception " + "when the parameter " + -1 * positive_cases[i] + " is a negative number.")
          except Exception:

          if UChar.ToChars(UChar.MinSupplementaryCodePoint - positive_cases[i], dst, 0) != 1:
Errln("UCharacter.toChars(int,char[],int) was suppose to return a value of 1. Got: " + UChar.ToChars(UChar.MinSupplementaryCodePoint - positive_cases[i], dst, 0))
          try:
UChar.ToChars(UChar.MaxCodePoint + positive_cases[i], dst, 0)
Errln("UCharacter.toChars(int,char[],int) was suppose to return an exception " + "when the parameter " + UChar.MaxCodePoint + positive_cases[i] + " is a large number.")
          except Exception:

++i
      var i: int = 0
      while i < positive_cases.Length:
          try:
UChar.ToChars(-1 * positive_cases[i])
Errln("UCharacter.toChars(cint) was suppose to return an exception " + "when the parameter " + positive_cases[i] + " is a negative number.")
          except Exception:

          if UChar.ToChars(UChar.MinSupplementaryCodePoint - positive_cases[i]).Length <= 0:
Errln("UCharacter.toChars(int) was suppose to return some result result when the parameter " + UChar.MinSupplementaryCodePoint - positive_cases[i] + "is passed.")
          try:
UChar.ToChars(UChar.MaxCodePoint + positive_cases[i])
Errln("UCharacter.toChars(int) was suppose to return an exception " + "when the parameter " + positive_cases[i] + " is a large number.")
          except Exception:

++i
proc TestCodePointCount*() =
    var empty_text: char[] = @[]
    var one_char_text: char[] = @['a']
    var reg_text: char[] = @['d', 'u', 'm', 'm', 'y']
    var invalid_startCases: int[] = @[-1, -2, -5, -10, -100]
    var limitCases: int[] = @[2, 3, 5, 10, 25]
      var i: int = 0
      while i < invalid_startCases.Length:
          try:
UChar.CodePointCount(reg_text.AsSpan(invalid_startCases[i], 1))
Errln("UCharacter.codePointCount was suppose to return an exception " + "but got " + UChar.CodePointCount(reg_text.AsSpan(invalid_startCases[i], 1)) + ". The following passed parameters were Text: " + string(reg_text) + ", Start: " + invalid_startCases[i] + ", Limit: " + 1 + ".")
          except Exception:

++i
proc TestGetEuropeanDigit*() =
    var radixResult: int[] = @[10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35]
    var radixCase1: int[] = @[0, 1, 5, 10, 100]
    var radixCase2: int[] = @[12, 16, 20, 36]
      var i: int = 65345
      while i <= 65370:
            var j: int = 0
            while j < radixCase1.Length:
                if UChar.Digit(i, radixCase1[j]) != -1:
Errln("UCharacter.digit(int,int) was supposed to return -1 for radix " + radixCase1[j] + ". Value passed: U+" + i.ToHexString + ". Got: " + UChar.Digit(i, radixCase1[j]))
++j
            var j: int = 0
            while j < radixCase2.Length:
                var radix: int = radixCase2[j]
                var expected: int =                 if radixResult[i - 65345] < radix:
radixResult[i - 65345]
                else:
-1
                var actual: int = UChar.Digit(i, radix)
                if actual != expected:
Errln("UCharacter.digit(int,int) was supposed to return " + expected + " for radix " + radix + ". Value passed: U+" + i.ToHexString + ". Got: " + actual)
                    break
++j
++i
proc TestGetProperty*() =
    var cases: int[] = @[UTF16.CodePointMaxValue + 1, UTF16.CodePointMaxValue + 2]
      var i: int = 0
      while i < cases.Length:
          if UChar.GetUnicodeCategory(cases[i]).ToInt32 != 0:
Errln("UCharacter.getType for testing UCharacter.getProperty " + "did not return 0 for passed value of " + cases[i] + " but got " + UChar.GetUnicodeCategory(cases[i]).ToInt32)
++i
type
  MyXSymbolTable = ref object


proc TestXSymbolTable*() =
    var st: MyXSymbolTable = MyXSymbolTable
    if st.LookupMatcher(0) != nil:
Errln("XSymbolTable.lookupMatcher(int i) was suppose to return null.")
    if st.ApplyPropertyAlias("", "", UnicodeSet) != false:
Errln("XSymbolTable.applyPropertyAlias(String propertyName, String propertyValue, UnicodeSet result) was suppose to return false.")
    if st.Lookup("") != nil:
Errln("XSymbolTable.lookup(String s) was suppose to return null.")
    if st.ParseReference("", nil, 0) != nil:
Errln("XSymbolTable.parseReference(String text, ParsePosition pos, int limit) was suppose to return null.")
proc TestIsFrozen*() =
    var us: UnicodeSet = UnicodeSet
    if us.IsFrozen != false:
Errln("Unicode.isFrozen() was suppose to return false.")
us.Freeze
    if us.IsFrozen != true:
Errln("Unicode.isFrozen() was suppose to return true.")
proc TestNameAliasing*() =
    var input: int = '�'
    var alias: String = UChar.GetNameAlias(input)
assertEquals("Wrong name alias", "LATIN CAPITAL LETTER GHA", alias)
    var output: int = UChar.GetCharFromNameAlias(alias)
assertEquals("alias for '" + input + "'", input, output)