# "Namespace: ICU4N.Dev.Test.Normalizers"
type
  UnicodeNormalizerConformanceTest = ref object
    normalizer_C: UnicodeNormalizer
    moreCases: seq[string] = @["0061 0332 0308;00E4 0332;0061 0332 0308;00E4 0332;0061 0332 0308; # Markus 0", "0061 0301 0F73;00E1 0F71 0F72;0061 0F71 0F72 0301;00E1 0F71 0F72;0061 0F71 0F72 0301; # Markus 1"]

proc newUnicodeNormalizerConformanceTest(): UnicodeNormalizerConformanceTest =
  normalizer_C = UnicodeNormalizer(UnicodeNormalizer.C, true)
  normalizer_D = UnicodeNormalizer(UnicodeNormalizer.D, false)
  normalizer_KC = UnicodeNormalizer(UnicodeNormalizer.KC, false)
  normalizer_KD = UnicodeNormalizer(UnicodeNormalizer.KD, false)
proc TestConformance*() =
    var line: String = nil
    var fields: String[] = seq[String]
    var buf: StringBuffer = StringBuffer
    var passCount: int = 0
    var failCount: int = 0
    var other: UnicodeSet = UnicodeSet(0, 1114111)
    var c: int = 0
    var input: TextReader = nil
    try:
        input = TestUtil.GetDataReader("unicode.NormalizationTest.txt")
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
Hexsplit(line, ';', fields, buf)
              if fields[0].Length == UTF16.MoveCodePointOffset(fields[0], 0, 1):
                  c = UTF16.CharAt(fields[0], 0)
                  if 44064 <= c && c <= 55103:
                      if c == 44064:
other.Remove(44064, 55103)
                      continue
other.Remove(c)
              if checkConformance(fields, line):
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
            except Exception:

    if failCount != 0:
Errln("Total: " + failCount + " lines failed, " + passCount + " lines passed")
    else:
Logln("Total: " + passCount + " lines passed")
proc checkConformance(field: seq[string], line: string): bool =
    var pass: bool = true
    var @out: string
    var i: int = 0
      i = 0
      while i < 5:
          if i < 3:
              @out = normalizer_C.normalize(field[i])
              pass = assertEqual("C", field[i], @out, field[1], "c2!=C(c" + i + 1)
              @out = normalizer_D.normalize(field[i])
              pass = assertEqual("D", field[i], @out, field[2], "c3!=D(c" + i + 1)
          @out = normalizer_KC.normalize(field[i])
          pass = assertEqual("KC", field[i], @out, field[3], "c4!=KC(c" + i + 1)
          @out = normalizer_KD.normalize(field[i])
          pass = assertEqual("KD", field[i], @out, field[4], "c5!=KD(c" + i + 1)
++i
    if !pass:
Errln("FAIL: " + line)
    return pass
proc assertEqual(op: String, s: String, got: String, exp: String, msg: String): bool =
    if exp.Equals(got):
        return true
Errln("      " + msg + ") " + op + "(" + s + ")=" + Hex(got) + ", exp. " + Hex(exp))
    return false
proc Hexsplit(s: String, delimiter: char, output: seq[String], buf: StringBuffer) =
    var i: int
    var pos: int = 0
      i = 0
      while i < output.Length:
          var delim: int = s.IndexOf(delimiter, pos)
          if delim < 0:
              raise ArgumentException("Missing field in " + s)
          buf.Length = 0
          var toHex: string = s.Substring(pos, delim - pos)
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
_testOneLine("0385;0385;00A8 0301;0020 0308 0301;0020 0308 0301;")
proc _testOneLine(line: String) =
    var fields: String[] = seq[String]
    var buf: StringBuffer = StringBuffer
Hexsplit(line, ';', fields, buf)
checkConformance(fields, line)