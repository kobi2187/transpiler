# "Namespace: ICU4N.Dev.Test.Rbbi"
type
  RBBITestExtended = ref object


proc newRBBITestExtended(): RBBITestExtended =

type
  TestParams = ref object
    bi: BreakIterator
    dataToBreak: StringBuilder = StringBuilder
    expectedBreaks: seq[int] = seq[int]
    srcLine: seq[int] = seq[int]
    srcCol: seq[int] = seq[int]
    currentLocale: UCultureInfo = UCultureInfo("en_US")

proc TestExtended*() =
    var tp: TestParams = TestParams
    var testFileBuf: StringBuilder = StringBuilder
    var @is: Stream = nil
    try:
        var assembly: Assembly = type(RBBITestExtended).Assembly
        @is = assembly.GetManifestResourceStream("ICU4N.Dev.Test.Rbbi.rbbitst.txt")
        if @is == nil:
Errln("Could not open test data file rbbitst.txt")
            return
        var isr: StreamReader = StreamReader(@is, Encoding.UTF8)
        try:
            var c: int
            var count: int = 0
              while true:
                  c = isr.Read
                  if c < 0:
                      break
++count
                  if c == 65279 && count == 1:
                      continue
testFileBuf.AppendCodePoint(c)
        finally:
isr.Dispose
    except IOException:
Errln(e.ToString)
        try:
@is.Dispose
        except IOException:

        return
    var testString: String = testFileBuf.ToString
    var PARSE_COMMENT: int = 1
    var PARSE_TAG: int = 2
    var PARSE_DATA: int = 3
    var PARSE_NUM: int = 4
    var PARSE_RULES: int = 5
    var parseState: int = PARSE_TAG
    var savedState: int = PARSE_TAG
    var lineNum: int = 1
    var colStart: int = 0
    var column: int = 0
    var charIdx: int = 0
    var i: int
    var tagValue: int = 0
    var rules: StringBuilder = StringBuilder
    var rulesFirstLine: int = 0
    var len: int = testString.Length
      charIdx = 0
      while charIdx < len:
          var c: int = testString.CodePointAt(charIdx)
++charIdx
          if c == '' && charIdx < len && testString[charIdx] == '
':
              c = '
'
++charIdx
          if c == '
' || c == '':
++lineNum
              colStart = charIdx
          column = charIdx - colStart + 1
          case parseState
          of PARSE_COMMENT:
              if c == 10 || c == 13:
                  parseState = savedState
              break
          of PARSE_TAG:
                if c == '#':
                    parseState = PARSE_COMMENT
                    savedState = PARSE_TAG
                    break
                if UChar.IsWhiteSpace(c):
                    break
                if testString.StartsWith("<word>", charIdx - 1, StringComparison.Ordinal):
                    tp.bi = BreakIterator.GetWordInstance(tp.currentLocale)
                    charIdx = 5
                    break
                if testString.StartsWith("<char>", charIdx - 1, StringComparison.Ordinal):
                    tp.bi = BreakIterator.GetCharacterInstance(tp.currentLocale)
                    charIdx = 5
                    break
                if testString.StartsWith("<line>", charIdx - 1, StringComparison.Ordinal):
                    tp.bi = BreakIterator.GetLineInstance(tp.currentLocale)
                    charIdx = 5
                    break
                if testString.StartsWith("<sent>", charIdx - 1, StringComparison.Ordinal):
                    tp.bi = BreakIterator.GetSentenceInstance(tp.currentLocale)
                    charIdx = 5
                    break
                if testString.StartsWith("<title>", charIdx - 1, StringComparison.Ordinal):
                    tp.bi = BreakIterator.GetTitleInstance(tp.currentLocale)
                    charIdx = 6
                    break
                if testString.StartsWith("<rules>", charIdx - 1, StringComparison.Ordinal) || testString.StartsWith("<badrules>", charIdx - 1, StringComparison.Ordinal):
                    charIdx = testString.IndexOf('>', charIdx) + 1
                    parseState = PARSE_RULES
                    rules.Length = 0
                    rulesFirstLine = lineNum
                    break
                if testString.StartsWith("<locale ", charIdx - 1, StringComparison.Ordinal):
                    var closeIndex: int = testString.IndexOf('>', charIdx)
                    if closeIndex < 0:
Errln("line" + lineNum + ": missing close on <locale  tag.")
                        break
                    var localeName: String = testString.Substring(charIdx + 6, closeIndex - charIdx + 6)
                    localeName = localeName.Trim
                    tp.currentLocale = UCultureInfo(localeName)
                    charIdx = closeIndex + 1
                    break
                if testString.StartsWith("<data>", charIdx - 1, StringComparison.Ordinal):
                    parseState = PARSE_DATA
                    charIdx = 5
                    tp.dataToBreak.Length = 0
tp.expectedBreaks.Fill(0)
tp.srcCol.Fill(0)
tp.srcLine.Fill(0)
                    break
Errln("line" + lineNum + ": Tag expected in test file.")
                return
          of PARSE_RULES:
              if testString.StartsWith("</rules>", charIdx - 1, StringComparison.Ordinal):
                  charIdx = 7
                  parseState = PARSE_TAG
                  try:
                      tp.bi = RuleBasedBreakIterator(rules.ToString)
                  except ArgumentException:
Errln(String.Format("rbbitst.txt:{0}  Error creating break iterator from rules.  {1}", lineNum, e))

              elif testString.StartsWith("</badrules>", charIdx - 1, StringComparison.Ordinal):
                  charIdx = 10
                  parseState = PARSE_TAG
                  var goodRules: bool = true
                  try:
RuleBasedBreakIterator(rules.ToString)
                  except ArgumentException:
                      goodRules = false
                  if goodRules:
Errln(String.Format("rbbitst.txt:{0}  Expected, but did not get, a failure creating break iterator from rules.", lineNum))
              else:
rules.AppendCodePoint(c)
              break
          of PARSE_DATA:
              if c == 'â':
                  var breakIdx: int = tp.dataToBreak.Length
                  tp.expectedBreaks[breakIdx] = -1
                  tp.srcLine[breakIdx] = lineNum
                  tp.srcCol[breakIdx] = column
                  break
              if testString.StartsWith("</data>", charIdx - 1, StringComparison.Ordinal):
                  var idx: int = tp.dataToBreak.Length
                  tp.srcLine[idx] = lineNum
                  tp.srcCol[idx] = column
                  parseState = PARSE_TAG
                  charIdx = 6
executeTest(tp)
                  break
              if testString.StartsWith("\N{", charIdx - 1, StringComparison.Ordinal):
                  var nameEndIdx: int = testString.IndexOf('}', charIdx)
                  if nameEndIdx == -1:
Errln("Error in named character in test file at line " + lineNum + ", col " + column)
                  var charName: String = testString.Substring(charIdx + 2, nameEndIdx - charIdx + 2)
                  c = UChar.GetCharFromName(charName)
                  if c == -1:
Errln("Error in named character in test file at line " + lineNum + ", col " + column)
                  else:
tp.dataToBreak.AppendCodePoint(c)
                        i = tp.dataToBreak.Length - 1
                        while i >= 0 && tp.srcLine[i] == 0:
                            tp.srcLine[i] = lineNum
                            tp.srcCol[i] = column
--i
                  if nameEndIdx > charIdx:
                      charIdx = nameEndIdx + 1
                  break
              if testString.StartsWith("<>", charIdx - 1, StringComparison.Ordinal):
++charIdx
                  var breakIdx: int = tp.dataToBreak.Length
                  tp.expectedBreaks[breakIdx] = -1
                  tp.srcLine[breakIdx] = lineNum
                  tp.srcCol[breakIdx] = column
                  break
              if c == '<':
                  tagValue = 0
                  parseState = PARSE_NUM
                  break
              if c == '#' && column == 3:
                  parseState = PARSE_COMMENT
                  savedState = PARSE_DATA
                  break
              if c == '\':
                  var cp: int = testString.CodePointAt(charIdx)
                  if cp == '' && charIdx < len && testString.CodePointAt(charIdx + 1) == '
':
++charIdx
                  if cp == '
' || cp == '':
++lineNum
                      column = 0
++charIdx
                      colStart = charIdx
                      break
                  var charIdxAr: int = charIdx
                  cp = Utility.UnescapeAt(testString, charIdxAr)
                  if cp != -1:
                      charIdx = charIdxAr
tp.dataToBreak.AppendCodePoint(cp)
                        i = tp.dataToBreak.Length - 1
                        while i >= 0 && tp.srcLine[i] == 0:
                            tp.srcLine[i] = lineNum
                            tp.srcCol[i] = column
--i
                      break
                  c = testString.CodePointAt(charIdx)
                  charIdx = testString.OffsetByCodePoints(charIdx, 1)
tp.dataToBreak.AppendCodePoint(c)
                i = tp.dataToBreak.Length - 1
                while i >= 0 && tp.srcLine[i] == 0:
                    tp.srcLine[i] = lineNum
                    tp.srcCol[i] = column
--i
              break
          of PARSE_NUM:
              if UChar.IsWhiteSpace(c):
                  break
              if c == '>':
                  parseState = PARSE_DATA
                  if tagValue == 0:
                      tagValue = -1
                  var breakIdx: int = tp.dataToBreak.Length
                  tp.expectedBreaks[breakIdx] = tagValue
                  tp.srcLine[breakIdx] = lineNum
                  tp.srcCol[breakIdx] = column
                  break
              if UChar.IsDigit(c):
                  tagValue = tagValue * 10 + UChar.Digit(c)
                  break
Errln(String.Format("Syntax Error in rbbitst.txt at line {0}, col {1}", lineNum, column))
              return
    if parseState == PARSE_RULES:
Errln(String.Format("rbbitst.txt:{0} <rules> block beginning at line {1} is not closed.", lineNum, rulesFirstLine))
    if parseState == PARSE_DATA:
Errln(String.Format("rbbitst.txt:{0} <data> block not closed.", lineNum))
proc executeTest(t: TestParams) =
    var bp: int
    var prevBP: int
    var i: int
    if t.bi == nil:
        return
t.bi.SetText(t.dataToBreak.ToString)
    prevBP = -1
      bp = t.bi.First
      while bp != BreakIterator.Done:
          if prevBP == bp:
Errln("Forward Iteration, no forward progress.  Break Pos=" + bp + "  File line,col=" + t.srcLine[bp] + ", " + t.srcCol[bp])
              break
            i = prevBP + 1
            while i < bp:
                if t.expectedBreaks[i] != 0:
Errln("Forward Iteration, break expected, but not found.  Pos=" + i + "  File line,col= " + t.srcLine[i] + ", " + t.srcCol[i])
++i
          if t.expectedBreaks[bp] == 0:
Errln("Forward Iteration, break found, but not expected.  Pos=" + bp + "  File line,col= " + t.srcLine[bp] + ", " + t.srcCol[bp])
          else:
              var expectedTagVal: int = t.expectedBreaks[bp]
              if expectedTagVal == -1:
                  expectedTagVal = 0
              var line: int = t.srcLine[bp]
              var rs: int = cast[int](t.bi.RuleStatus)
              if rs != expectedTagVal:
Errln("Incorrect status for forward break.  Pos = " + bp + ".  File line,col = " + line + ", " + t.srcCol[bp] + "
" + "          Actual, Expected status = " + rs + ", " + expectedTagVal)
              var fillInArray: int[] = seq[int]
              var numStatusVals: int = t.bi.GetRuleStatusVec(fillInArray)
assertTrue("", numStatusVals >= 1)
assertEquals("", expectedTagVal, fillInArray[0])
          prevBP = bp
          bp = t.bi.Next
      i = prevBP + 1
      while i < t.dataToBreak.Length + 1:
          if t.expectedBreaks[i] != 0:
Errln("Forward Iteration, break expected, but not found.  Pos=" + i + "  File line,col= " + t.srcLine[i] + ", " + t.srcCol[i])
++i
    prevBP = t.dataToBreak.Length + 2
      bp = t.bi.Last
      while bp != BreakIterator.Done:
          if prevBP == bp:
Errln("Reverse Iteration, no progress.  Break Pos=" + bp + "File line,col=" + t.srcLine[bp] + " " + t.srcCol[bp])
              break
            i = prevBP - 1
            while i > bp:
                if t.expectedBreaks[i] != 0:
Errln("Reverse Itertion, break expected, but not found.  Pos=" + i + "  File line,col= " + t.srcLine[i] + ", " + t.srcCol[i])
--i
          if t.expectedBreaks[bp] == 0:
Errln("Reverse Itertion, break found, but not expected.  Pos=" + bp + "  File line,col= " + t.srcLine[bp] + ", " + t.srcCol[bp])
          else:
              var expectedTagVal: int = t.expectedBreaks[bp]
              if expectedTagVal == -1:
                  expectedTagVal = 0
              var line: int = t.srcLine[bp]
              var rs: int = cast[int](t.bi.RuleStatus)
              if rs != expectedTagVal:
Errln("Incorrect status for reverse break.  Pos = " + bp + "  File line,col= " + line + ", " + t.srcCol[bp] + "
" + "          Actual, Expected status = " + rs + ", " + expectedTagVal)
          prevBP = bp
          bp = t.bi.Previous
      i = prevBP - 1
      while i >= 0:
          if t.expectedBreaks[i] != 0:
Errln("Reverse Itertion, break expected, but not found.  Pos=" + i + "  File line,col= " + t.srcLine[i] + ", " + t.srcCol[i])
--i
      i = 0
      while i <= t.dataToBreak.Length:
          var boundaryExpected: bool = t.expectedBreaks[i] != 0
          var boundaryFound: bool = t.bi.IsBoundary(i)
          if boundaryExpected != boundaryFound:
Errln("isBoundary(" + i + ") incorrect.
" + "  File line,col= " + t.srcLine[i] + ", " + t.srcCol[i] + "    Expected, Actual= " + boundaryExpected + ", " + boundaryFound)
++i
      i = 0
      while i <= t.dataToBreak.Length:
          var actualBreak: int = t.bi.Following(i)
          var expectedBreak: int = BreakIterator.Done
            var j: int = i + 1
            while j < t.expectedBreaks.Length:
                if t.expectedBreaks[j] != 0:
                    expectedBreak = j
                    break
++j
          if expectedBreak != actualBreak:
Errln("following(" + i + ") incorrect.
" + "  File line,col= " + t.srcLine[i] + ", " + t.srcCol[i] + "    Expected, Actual= " + expectedBreak + ", " + actualBreak)
++i
      i = t.dataToBreak.Length
      while i >= 0:
          var actualBreak: int = t.bi.Preceding(i)
          var expectedBreak: int = BreakIterator.Done
            var j: int = i - 1
            while j >= 0:
                if t.expectedBreaks[j] != 0:
                    expectedBreak = j
                    break
--j
          if expectedBreak != actualBreak:
Errln("preceding(" + i + ") incorrect.
" + "  File line,col= " + t.srcLine[i] + ", " + t.srcCol[i] + "    Expected, Actual= " + expectedBreak + ", " + actualBreak)
--i