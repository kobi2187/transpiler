# "Namespace: ICU4N.Dev.Test.Normalizers"
type
  ConformanceTest = ref object
    normalizer: Normalizer
    moreCases: seq[String] = @["0061 0332 0308;00E4 0332;0061 0332 0308;00E4 0332;0061 0332 0308; # Markus 0", "0061 0301 0F73;00E1 0F71 0F72;0061 0F71 0F72 0301;00E1 0F71 0F72;0061 0F71 0F72 0301; # Markus 1"]
    kModeStrings: seq[String] = @["D", "KD", "C", "KC"]
    kMessages: seq[String] = @["c3!=D(c{0})", "c5!=KC(c{0})", "c2!=C(c{0})", "c4!=KC(c{0})"]

proc newConformanceTest(): ConformanceTest =
  normalizer = Normalizer("", NormalizerMode.NFC, 0)
proc TestConformance*() =
runConformance("unicode.NormalizationTest.txt", 0)
proc TestConformance_3_2*() =
runConformance("unicode.NormalizationTest-3.2.0.txt", Normalizer.Unicode3_2)
proc runConformance*(fileName: String, options: int) =
    var line: String = nil
    var fields: String[] = seq[String]
    var buf: StringBuffer = StringBuffer
    var passCount: int = 0
    var failCount: int = 0
    var other: UnicodeSet = UnicodeSet(0, 1114111)
    var c: int = 0
    var input: TextReader = nil
    try:
        input = TestUtil.GetDataReader(fileName)
          var count: int = 0
          while true:
              line = input.ReadLine
              if line == nil:
                  if count > moreCases.Length:
                      count = 0

                  elif count == moreCases.Length:
                      break
                  line = moreCases[++count]
              if line.Length == 0:
                continue
              if line[0] == '#' || line[0] == '@':
                continue
hexsplit(line, ';', fields, buf)
              if fields[0].Length == UTF16.MoveCodePointOffset(fields[0], 0, 1):
                  c = UTF16.CharAt(fields[0], 0)
                  if 44064 <= c && c <= 55103:
                      if c == 44064:
other.Remove(44064, 55103)
                      continue
other.Remove(c)
              if checkConformance(fields, line, options):
++passCount
              else:
++failCount
              if count % 1000 == 999:
Logln("Line " + count + 1)
++count
    except IOException:
ex.PrintStackTrace
        raise ArgumentException("Couldn't read file " + ex.GetType.Name + " " + ex.ToString + " line = " + line)
    finally:
        if input != nil:
            try:
input.Dispose
            except IOException:

    if failCount != 0:
Errln("Total: " + failCount + " lines failed, " + passCount + " lines passed")
    else:
Logln("Total: " + passCount + " lines passed")
proc checkConformance(field: seq[String], line: String, options: int): bool =
    var pass: bool = true
    var buf: StringBuffer = StringBuffer
      var @out: String
      var fcd: String
    var i: int = 0
      i = 0
      while i < 5:
          var fieldNum: int = i + 1
          if i < 3:
              pass = checkNorm(NormalizerMode.NFC, options, field[i], field[1], fieldNum)
              pass = checkNorm(NormalizerMode.NFD, options, field[i], field[2], fieldNum)
          pass = checkNorm(NormalizerMode.NFKC, options, field[i], field[3], fieldNum)
          pass = checkNorm(NormalizerMode.NFKD, options, field[i], field[4], fieldNum)
cross(field[4], field[3], NormalizerMode.NFKC)
cross(field[3], field[4], NormalizerMode.NFKD)
++i
compare(field[1], field[2])
compare(field[0], field[1])
compare(field[0], field[2])
    var normalizerVersion = options.AsFlagsToEnum
    if QuickCheckResult.No == Normalizer.QuickCheck(field[1], NormalizerMode.NFC, normalizerVersion):
Errln("Normalizer error: quickCheck(NFC(s), Normalizer.NFC) is Normalizer.NO")
        pass = false
    if QuickCheckResult.No == Normalizer.QuickCheck(field[2], NormalizerMode.NFD, normalizerVersion):
Errln("Normalizer error: quickCheck(NFD(s), Normalizer.NFD) is Normalizer.NO")
        pass = false
    if QuickCheckResult.No == Normalizer.QuickCheck(field[3], NormalizerMode.NFKC, normalizerVersion):
Errln("Normalizer error: quickCheck(NFKC(s), Normalizer.NFKC) is Normalizer.NO")
        pass = false
    if QuickCheckResult.No == Normalizer.QuickCheck(field[4], NormalizerMode.NFKD, normalizerVersion):
Errln("Normalizer error: quickCheck(NFKD(s), Normalizer.NFKD) is Normalizer.NO")
        pass = false
    if !Normalizer.IsNormalized(field[1], NormalizerMode.NFC, normalizerVersion):
Errln("Normalizer error: isNormalized(NFC(s), Normalizer.NFC) is false")
        pass = false
    if !field[0].Equals(field[1]) && Normalizer.IsNormalized(field[0], NormalizerMode.NFC, normalizerVersion):
Errln("Normalizer error: isNormalized(s, Normalizer.NFC) is TRUE")
        pass = false
    if !Normalizer.IsNormalized(field[3], NormalizerMode.NFKC, normalizerVersion):
Errln("Normalizer error: isNormalized(NFKC(s), Normalizer.NFKC) is false")
        pass = false
    if !field[0].Equals(field[3]) && Normalizer.IsNormalized(field[0], NormalizerMode.NFKC, normalizerVersion):
Errln("Normalizer error: isNormalized(s, Normalizer.NFKC) is TRUE")
        pass = false
    if !Normalizer.IsNormalized(field[1].AsSpan(0, field[1].Length), NormalizerMode.NFC, normalizerVersion):
Errln("Normalizer error: isNormalized(NFC(s), Normalizer.NFC) is false")
        pass = false
    if !Normalizer.IsNormalized(UTF16.CharAt(field[1], 0), NormalizerMode.NFC, normalizerVersion):
Errln("Normalizer error: isNormalized(NFC(s), Normalizer.NFC) is false")
        pass = false
    fcd = Normalizer.Normalize(field[0], NormalizerMode.FCD)
    if QuickCheckResult.No == Normalizer.QuickCheck(fcd, NormalizerMode.FCD, normalizerVersion):
Errln("Normalizer error: quickCheck(FCD(s), Normalizer.FCD) is Normalizer.NO")
        pass = false
      var fcd2: char[] = seq[char]
      var src: char[] = field[0].ToCharArray
assertTrue("", Normalizer.TryNormalize(src.AsSpan(0, src.Length), fcd2.AsSpan(fcd.Length, fcd2.Length - fcd.Length),       var fcdLen: int, NormalizerMode.FCD, 0))
      if fcdLen != fcd.Length:
Errln("makeFCD did not return the correct length")
    if QuickCheckResult.No == Normalizer.QuickCheck(fcd, NormalizerMode.FCD, normalizerVersion):
Errln("Normalizer error: quickCheck(FCD(s), Normalizer.FCD) is Normalizer.NO")
        pass = false
    if QuickCheckResult.No == Normalizer.QuickCheck(field[2], NormalizerMode.FCD, normalizerVersion):
Errln("Normalizer error: quickCheck(NFD(s), Normalizer.FCD) is Normalizer.NO")
        pass = false
    if QuickCheckResult.No == Normalizer.QuickCheck(field[4], NormalizerMode.FCD, normalizerVersion):
Errln("Normalizer error: quickCheck(NFKD(s), Normalizer.FCD) is Normalizer.NO")
        pass = false
    @out = iterativeNorm(StringCharacterIterator(field[0]), NormalizerMode.FCD, buf, +1, options)
    @out = iterativeNorm(StringCharacterIterator(field[0]), NormalizerMode.FCD, buf, -1, options)
    @out = iterativeNorm(StringCharacterIterator(field[2]), NormalizerMode.FCD, buf, +1, options)
    @out = iterativeNorm(StringCharacterIterator(field[2]), NormalizerMode.FCD, buf, -1, options)
    @out = iterativeNorm(StringCharacterIterator(field[4]), NormalizerMode.FCD, buf, +1, options)
    @out = iterativeNorm(StringCharacterIterator(field[4]), NormalizerMode.FCD, buf, -1, options)
    @out = Normalizer.Normalize(fcd, NormalizerMode.NFD)
    if !@out.Equals(field[2]):
Errln("Normalizer error: NFD(FCD(s))!=NFD(s)")
        pass = false
    if !pass:
Errln("FAIL: " + line)
    if field[0] != field[2]:
        var rc: int
        var shiftedOptions: int = options << Normalizer.COMPARE_NORM_OPTIONS_SHIFT | Normalizer.COMPARE_IGNORE_CASE
        var foldCaseShifted = shiftedOptions.AsFlagsToEnum
        var normalizerComparisonShifted = shiftedOptions.AsFlagsToEnum
        if         rc = Normalizer.Compare(field[0], field[2], normalizerComparisonShifted, foldCaseShifted) != 0:
Errln("Normalizer.compare(original, NFD, case-insensitive) returned " + rc + " instead of 0 for equal")
            pass = false
    return pass
proc getModeNumber(mode: NormalizerMode): int =
    if mode == NormalizerMode.NFD:
        return 0
    if mode == NormalizerMode.NFKD:
        return 1
    if mode == NormalizerMode.NFC:
        return 2
    if mode == NormalizerMode.NFKC:
        return 3
    return -1
proc checkNorm(mode: NormalizerMode, options: int, s: String, exp: String, field: int): bool =
    var modeString: String = kModeStrings[getModeNumber(mode)]
    var msg: String = String.Format(kMessages[getModeNumber(mode)], field)
    var buf: StringBuffer = StringBuffer
    var @out: String = Normalizer.Normalize(s, mode, options.AsFlagsToEnum)
    if !assertEqual(modeString, "", s, @out, exp, msg):
        return false
    @out = iterativeNorm(s, mode, buf, +1, options)
    if !assertEqual(modeString, "(+1)", s, @out, exp, msg):
        return false
    @out = iterativeNorm(s, mode, buf, -1, options)
    if !assertEqual(modeString, "(-1)", s, @out, exp, msg):
        return false
    @out = iterativeNorm(StringCharacterIterator(s), mode, buf, +1, options)
    if !assertEqual(modeString, "(+1)", s, @out, exp, msg):
        return false
    @out = iterativeNorm(StringCharacterIterator(s), mode, buf, -1, options)
    if !assertEqual(modeString, "(-1)", s, @out, exp, msg):
        return false
    return true
proc compare(s1: String, s2: String) =
    if s1.Length == 1 && s2.Length == 1:
        if Normalizer.Compare(UTF16.CharAt(s1, 0), UTF16.CharAt(s2, 0), NormalizerComparison.IgnoreCase) != 0:
Errln("Normalizer.compare(int,int) failed for s1: " + Utility.Hex(s1) + " s2: " + Utility.Hex(s2))
    if s1.Length == 1 && s2.Length > 1:
        if Normalizer.Compare(UTF16.CharAt(s1, 0), s2, NormalizerComparison.IgnoreCase) != 0:
Errln("Normalizer.compare(int,String) failed for s1: " + Utility.Hex(s1) + " s2: " + Utility.Hex(s2))
    if s1.Length > 1 && s2.Length > 1:
        if Normalizer.Compare(s1.ToCharArray, s2.ToCharArray, NormalizerComparison.IgnoreCase) != 0:
Errln("Normalizer.compare(char[],char[]) failed for s1: " + Utility.Hex(s1) + " s2: " + Utility.Hex(s2))
proc cross(s1: String, s2: String, mode: NormalizerMode) =
    var result: String = Normalizer.Normalize(s1, mode)
    if !result.Equals(s2):
Errln("cross test failed s1: " + Utility.Hex(s1) + " s2: " + Utility.Hex(s2))
proc iterativeNorm(str: String, mode: NormalizerMode, buf: StringBuffer, dir: int, options: int): String =
normalizer.SetText(str)
normalizer.SetMode(mode)
    buf.Length = 0
normalizer.SetOption(-1, false)
normalizer.SetOption(options, true)
    var ch: int
    if dir > 0:
          ch = normalizer.First
          while ch != Normalizer.Done:
buf.Append(UTF16.ValueOf(ch))
              ch = normalizer.Next
    else:
          ch = normalizer.Last
          while ch != Normalizer.Done:
buf.Insert(0, UTF16.ValueOf(ch))
              ch = normalizer.Previous
    return buf.ToString
proc iterativeNorm(str: StringCharacterIterator, mode: NormalizerMode, buf: StringBuffer, dir: int, options: int): String =
normalizer.SetText(str)
normalizer.SetMode(mode)
    buf.Length = 0
normalizer.SetOption(-1, false)
normalizer.SetOption(options, true)
    var ch: int
    if dir > 0:
          ch = normalizer.First
          while ch != Normalizer.Done:
buf.Append(UTF16.ValueOf(ch))
              ch = normalizer.Next
    else:
          ch = normalizer.Last
          while ch != Normalizer.Done:
buf.Insert(0, UTF16.ValueOf(ch))
              ch = normalizer.Previous
    return buf.ToString
proc assertEqual(op: String, op2: String, s: String, got: String, exp: String, msg: String): bool =
    if exp.Equals(got):
        return true
Errln("      " + msg + ": " + op + op2 + '(' + s + ")=" + Hex(got) + ", exp. " + Hex(exp))
    return false
proc hexsplit(s: String, delimiter: char, output: seq[String], buf: StringBuffer) =
    var i: int
    var pos: int = 0
      i = 0
      while i < output.Length:
          var delim: int = s.IndexOf(delimiter, pos)
          if delim < 0:
              raise ArgumentException("Missing field in " + s)
          buf.Length = 0
          var toHex: String = s.Substring(pos, delim - pos)
          pos = delim
          var index: int = 0
          var len: int = toHex.Length
          while index < len:
              if toHex[index] == ' ':
++index
              else:
                  var spacePos: int = toHex.IndexOf(' ', index)
                  if spacePos == -1:
appendInt(buf, toHex.Substring(index, len - index), s)
                      spacePos = len
                  else:
appendInt(buf, toHex.Substring(index, spacePos - index), s)
                  index = spacePos + 1
          if buf.Length < 1:
              raise ArgumentException("Empty field " + i + " in " + s)
          output[i] = buf.ToString
++pos
++i
proc appendInt*(buf: StringBuffer, strToHex: String, s: String) =
    var hex: int = int.Parse(strToHex, NumberStyles.HexNumber)
    if hex < 0:
        raise ArgumentException("Out of range hex " + hex + " in " + s)

    elif hex > 65535:
buf.Append(cast[char](hex >> 10 + 55232))
buf.Append(cast[char](hex & 1023 | 56320))
    else:
buf.Append(cast[char](hex))
proc _hideTestCase6*() =
_testOneLine("0385;0385;00A8 0301;0020 0308 0301;0020 0308 0301;", 0)
proc _testOneLine(line: String, options: int) =
    var fields: String[] = seq[String]
    var buf: StringBuffer = StringBuffer
hexsplit(line, ';', fields, buf)
checkConformance(fields, line, options)