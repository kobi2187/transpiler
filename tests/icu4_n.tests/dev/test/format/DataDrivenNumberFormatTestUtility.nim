# "Namespace: ICU4N.Dev.Test.Format"
type
  DataDrivenNumberFormatTestUtility = ref object
    codeUnderTest: CodeUnderTest
    fileLine: string = nil
    fileLineNumber: int = 0
    fileTestName: string = ""
    tuple: DataDrivenNumberFormatTestData = DataDrivenNumberFormatTestData

type
  CodeUnderTest = ref object


proc Id(): Option[char] =
    return nil
proc Format*(tuple: DataDrivenNumberFormatTestData): string =
    if tuple.output != nil && tuple.output.Equals("fail", StringComparison.Ordinal):
      return "fail"
    return nil
proc ToPattern*(tuple: DataDrivenNumberFormatTestData): string =
    if tuple.output != nil && tuple.output.Equals("fail", StringComparison.Ordinal):
      return "fail"
    return nil
proc Parse*(tuple: DataDrivenNumberFormatTestData): string =
    if tuple.output != nil && tuple.output.Equals("fail", StringComparison.Ordinal):
      return "fail"
    return nil
proc ParseCurrency*(tuple: DataDrivenNumberFormatTestData): string =
    if tuple.output != nil && tuple.output.Equals("fail", StringComparison.Ordinal):
      return "fail"
    return nil
proc Select*(tuple: DataDrivenNumberFormatTestData): string =
    if tuple.output != nil && tuple.output.Equals("fail", StringComparison.Ordinal):
      return "fail"
    return nil
type
  RunMode = enum
    SKIP_KNOWN_FAILURES
    INCLUDE_KNOWN_FAILURES

proc runSuite*(fileName: string, codeUnderTest: CodeUnderTest) =
DataDrivenNumberFormatTestUtility(codeUnderTest).run(fileName, RunMode.SKIP_KNOWN_FAILURES)
proc runFormatSuiteIncludingKnownFailures*(fileName: string, codeUnderTest: CodeUnderTest) =
DataDrivenNumberFormatTestUtility(codeUnderTest).run(fileName, RunMode.INCLUDE_KNOWN_FAILURES)
proc new(codeUnderTest: CodeUnderTest) =
  self.codeUnderTest = codeUnderTest
proc run(fileName: string, runMode: RunMode) =
    var codeUnderTestIdObj: char? = codeUnderTest.Id
    var codeUnderTestId: char =     if codeUnderTestIdObj == nil:
cast[char](0)
    else:
char.ToUpperInvariant(codeUnderTestIdObj.Value)
    var @in: TextReader = nil
    try:
        @in = TestUtil.GetDataReader("numberformattestspecification.txt", "UTF-8")
readLine(@in)
        if fileLine != nil && fileLine[0] == 'ï':
            fileLine = fileLine.Substring(1)
        var state: int = 0
        var columnValues: IList<string>
        var columnNames: IList<string> = nil
        while true:
            if fileLine == nil || fileLine.Length == 0:
                if !readLine(@in):
                    break
                if fileLine.Length == 0 && state == 2:
                    state = 0
                continue
            if fileLine.StartsWith("//", StringComparison.Ordinal):
                fileLine = nil
                continue
            if state == 0:
                if fileLine.StartsWith("test ", StringComparison.Ordinal):
                    fileTestName = fileLine
                    tuple = DataDrivenNumberFormatTestData

                elif fileLine.StartsWith("set ", StringComparison.Ordinal):
                    if !setTupleField:
                        return
                else:
                  if fileLine.StartsWith("begin", StringComparison.Ordinal):
                      state = 1
                  else:
showError("Unrecognized verb.")
                      return

            elif state == 1:
                columnNames = splitBy(cast[char](9))
                state = 2
            else:
                var columnNamesSize: int = columnNames.Count
                columnValues = splitBy(columnNamesSize, cast[char](9))
                var columnValuesSize: int = columnValues.Count
                  var i: int = 0
                  while i < columnValuesSize:
                      if !setField(columnNames[i], columnValues[i]):
                          return
++i
                  var i: int = columnValuesSize
                  while i < columnNamesSize:
                      if !clearField(columnNames[i]):
                          return
++i
                if runMode == RunMode.INCLUDE_KNOWN_FAILURES || !breaks(codeUnderTestId):
                    var errorMessage: String
                    var err: Exception = nil
                    var shouldFail: bool =                     if tuple.output != nil && tuple.output.Equals("fail", StringComparison.Ordinal):
!breaks(codeUnderTestId)
                    else:
breaks(codeUnderTestId)
                    try:
                        errorMessage = isPass(tuple)
                    except Exception:
                        err = e
                        errorMessage = "Exception: " + e + ": " + e.InnerException
                    if shouldFail && errorMessage == nil:
showError("Expected failure, but passed")

                    elif !shouldFail && errorMessage != nil:
                        if err != nil:
                            var stackTrace: string = err.StackTrace
showError(errorMessage + "     Stack trace: " + stackTrace.Substring(0, 500))
                        else:
showError(errorMessage)
            fileLine = nil
    except Exception:
        var stackTrace: String = e.StackTrace
showError("MAJOR ERROR: " + e.ToString + "     Stack trace: " + stackTrace.Substring(0, 500))
    finally:
        try:
            if @in != nil:
@in.Dispose
        except IOException:
Console.WriteLine(e.ToString)
proc breaks(code: char): bool =
    var breaks: string =     if tuple.breaks == nil:
""
    else:
tuple.breaks
    return breaks.ToUpperInvariant.IndexOf(code) != -1
proc isSpace(c: char): bool =
    return c == 9 || c == 32 || c == 12288
proc setTupleField(): bool =
    var parts: IList<string> = splitBy(3, cast[char](32))
    if parts.Count < 3:
showError("Set expects 2 parameters")
        return false
    return setField(parts[1], parts[2])
proc setField(name: string, value: string): bool =
    try:
tuple.setField(name, Utility.Unescape(value))
        return true
    except Exception:
showError("No such field: " + name + ", or bad value: " + value)
        return false
proc clearField(name: string): bool =
    try:
tuple.clearField(name)
        return true
    except Exception:
showError("Field cannot be clared: " + name)
        return false
proc showError(message: String) =
TestFmwk.Errln(String.Format("line {0}: {1}
{2}
{3}", fileLineNumber, Utility.Escape(message), fileTestName, fileLine))
proc splitBy(delimiter: char): IList<string> =
    return splitBy(int.MaxValue, delimiter)
proc splitBy(max: int, delimiter: char): IList<string> =
    var result: List<string> = List<string>
    var colIdx: int = 0
    var colStart: int = 0
    var len: int = fileLine.Length
      var idx: int = 0
      while colIdx < max - 1 && idx < len:
          var ch: char = fileLine[idx]
          if ch == delimiter:
result.Add(fileLine.Substring(colStart, idx - colStart))
++colIdx
              colStart = idx + 1
++idx
result.Add(fileLine.Substring(colStart, len - colStart))
    return result
proc readLine(@in: TextReader): bool =
    var line: string = @in.ReadLine
    if line == nil:
        fileLine = nil
        return false
++fileLineNumber
    var idx: int = line.Length
      while idx > 0:
          if !isSpace(line[idx - 1]):
              break
--idx
    fileLine =     if idx == 0:
""
    else:
line
    return true
proc isPass(tuple: DataDrivenNumberFormatTestData): string =
    var result: StringBuilder = StringBuilder
    if tuple.format != nil && tuple.output != nil:
        var errorMessage: string = codeUnderTest.Format(tuple)
        if errorMessage != nil:
result.Append(errorMessage)

    elif tuple.toPattern != nil || tuple.toLocalizedPattern != nil:
        var errorMessage: string = codeUnderTest.ToPattern(tuple)
        if errorMessage != nil:
result.Append(errorMessage)
    else:
      if tuple.parse != nil && tuple.output != nil && tuple.outputCurrency != nil:
          var errorMessage: string = codeUnderTest.ParseCurrency(tuple)
          if errorMessage != nil:
result.Append(errorMessage)

      elif tuple.parse != nil && tuple.output != nil:
          var errorMessage: string = codeUnderTest.Parse(tuple)
          if errorMessage != nil:
result.Append(errorMessage)
      else:
        if tuple.plural != nil:
            var errorMessage: string = codeUnderTest.Select(tuple)
            if errorMessage != nil:
result.Append(errorMessage)
        else:
result.Append("Unrecognized test type.")
    if result.Length > 0:
result.Append(": ")
result.Append(tuple)
        return result.ToString
    return nil