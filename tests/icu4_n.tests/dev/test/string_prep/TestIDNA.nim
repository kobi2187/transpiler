# "Namespace: ICU4N.Dev.Test.StringPrep"
type
  TestIDNA = ref object
    unassignedException: StringPrepFormatException = StringPrepFormatException("", StringPrepErrorType.UnassignedError)
    loopCount: int = 100
    maxCharCount: int = 15
    random: Random = nil

proc TestToUnicode*() =
      var i: int = 0
      while i < TestData.asciiIn.Length:
DoTestToUnicode(TestData.asciiIn[i], String(TestData.unicodeIn[i]), IDNA2003Options.Default, nil)
DoTestToUnicode(TestData.asciiIn[i], String(TestData.unicodeIn[i]), IDNA2003Options.AllowUnassigned, nil)
DoTestToUnicode(TestData.asciiIn[i], String(TestData.unicodeIn[i]), IDNA2003Options.UseSTD3Rules, nil)
DoTestToUnicode(TestData.asciiIn[i], String(TestData.unicodeIn[i]), IDNA2003Options.UseSTD3Rules | IDNA2003Options.AllowUnassigned, nil)
++i
proc TestToASCII*() =
      var i: int = 0
      while i < TestData.asciiIn.Length:
DoTestToASCII(String(TestData.unicodeIn[i]), TestData.asciiIn[i], IDNA2003Options.Default, nil)
DoTestToASCII(String(TestData.unicodeIn[i]), TestData.asciiIn[i], IDNA2003Options.AllowUnassigned, nil)
DoTestToUnicode(TestData.asciiIn[i], String(TestData.unicodeIn[i]), IDNA2003Options.UseSTD3Rules, nil)
DoTestToUnicode(TestData.asciiIn[i], String(TestData.unicodeIn[i]), IDNA2003Options.UseSTD3Rules | IDNA2003Options.AllowUnassigned, nil)
++i
proc TestIDNToASCII*() =
      var i: int = 0
      while i < TestData.domainNames.Length:
DoTestIDNToASCII(TestData.domainNames[i], TestData.domainNames[i], IDNA2003Options.Default, nil)
DoTestIDNToASCII(TestData.domainNames[i], TestData.domainNames[i], IDNA2003Options.AllowUnassigned, nil)
DoTestIDNToASCII(TestData.domainNames[i], TestData.domainNames[i], IDNA2003Options.UseSTD3Rules, nil)
DoTestIDNToASCII(TestData.domainNames[i], TestData.domainNames[i], IDNA2003Options.AllowUnassigned | IDNA2003Options.UseSTD3Rules, nil)
++i
      var i: int = 0
      while i < TestData.domainNames1Uni.Length:
DoTestIDNToASCII(TestData.domainNames1Uni[i], TestData.domainNamesToASCIIOut[i], IDNA2003Options.Default, nil)
DoTestIDNToASCII(TestData.domainNames1Uni[i], TestData.domainNamesToASCIIOut[i], IDNA2003Options.AllowUnassigned, nil)
++i
proc TestIDNToUnicode*() =
      var i: int = 0
      while i < TestData.domainNames.Length:
DoTestIDNToUnicode(TestData.domainNames[i], TestData.domainNames[i], IDNA2003Options.Default, nil)
DoTestIDNToUnicode(TestData.domainNames[i], TestData.domainNames[i], IDNA2003Options.AllowUnassigned, nil)
DoTestIDNToUnicode(TestData.domainNames[i], TestData.domainNames[i], IDNA2003Options.UseSTD3Rules, nil)
DoTestIDNToUnicode(TestData.domainNames[i], TestData.domainNames[i], IDNA2003Options.AllowUnassigned | IDNA2003Options.UseSTD3Rules, nil)
++i
      var i: int = 0
      while i < TestData.domainNamesToASCIIOut.Length:
DoTestIDNToUnicode(TestData.domainNamesToASCIIOut[i], TestData.domainNamesToUnicodeOut[i], IDNA2003Options.Default, nil)
DoTestIDNToUnicode(TestData.domainNamesToASCIIOut[i], TestData.domainNamesToUnicodeOut[i], IDNA2003Options.AllowUnassigned, nil)
++i
proc DoTestToUnicode(src: String, expected: String, options: IDNA2003Options, expectedException: Object) =
    try:
        var @out: string = IDNA.ConvertToUnicode(src, options)
        if expected != nil && @out != nil && !@out.Equals(expected):
Errln("convertToUnicode did not return expected result with options : " + options + " Expected: " + Prettify(expected) + " Got: " + Prettify(@out))
        if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("convertToUnicode did not get the expected exception. The operation succeeded!")
    except StringPrepFormatException:
        if expectedException == nil || !ex.Equals(expectedException):
Errln("convertToUnicode did not get the expected exception for source: " + Prettify(src) + " Got:  " + ex.ToString)
      var outBuf: Span<char> = newSeq[char](src.Length + 32)
      var outBufLength: int = 0
      var errorType: StringPrepErrorType = cast[StringPrepErrorType](-1)
      var success: bool = IDNA.TryConvertToUnicode(src.AsSpan, outBuf, outBufLength, options, errorType)
      if success:
          var @out: string = outBuf.Slice(0, outBufLength).ToString
          if expected != nil && @out != nil && !@out.ToString.Equals(expected):
Errln("TryConvertToUnicode did not return expected result with options : " + options + " Expected: " + Prettify(expected) + " Got: " + @out)
          if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("TryConvertToUnicode did not get the expected exception. The operation succeeded!")
      else:
          if expectedException == nil || cast[StringPrepFormatException](expectedException).Error != errorType:
Errln("TryConvertToUnicode did not get the expected exception for source: " + src + " Got:  " + errorType.ToString)
proc DoTestIDNToUnicode(src: String, expected: String, options: IDNA2003Options, expectedException: Object) =
    try:
        var @out: string = IDNA.ConvertIDNToUnicode(src, options)
        if expected != nil && @out != nil && !@out.Equals(expected):
Errln("ConvertIDNToUnicode did not return expected result with options : " + options + " Expected: " + Prettify(expected) + " Got: " + Prettify(@out))
        if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("ConvertIDNToUnicode did not get the expected exception. The operation succeeded!")
    except StringPrepFormatException:
        if expectedException == nil || !expectedException.Equals(ex):
Errln("ConvertIDNToUnicode did not get the expected exception for source: " + src + " Got:  " + ex.ToString)
      var outBuf: Span<char> = newSeq[char](src.Length + 32)
      var outBufLength: int = 0
      var errorType: StringPrepErrorType = cast[StringPrepErrorType](-1)
      var success: bool = IDNA.TryConvertIDNToUnicode(src.AsSpan, outBuf, outBufLength, options, errorType)
      if success:
          var @out: string = outBuf.Slice(0, outBufLength).ToString
          if expected != nil && @out != nil && !@out.Equals(expected):
Errln("TryConvertIDNToUnicode did not return expected result with options : " + options + " Expected: " + Prettify(expected) + " Got: " + @out)
          if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("TryConvertIDNToUnicode did not get the expected exception. The operation succeeded!")
      else:
          if expectedException == nil || cast[StringPrepFormatException](expectedException).Error != errorType:
Errln("TryConvertIDNToUnicode did not get the expected exception for source: " + src + " Got:  " + errorType.ToString)
proc DoTestToASCII(src: String, expected: String, options: IDNA2003Options, expectedException: Object) =
    try:
        var @out: string = IDNA.ConvertToASCII(src, options)
        if !unassignedException.Equals(expectedException) && expected != nil && @out != nil && !@out.Equals(expected.ToLowerInvariant):
Errln("ConvertToASCII did not return expected result with options : " + options + " Expected: " + expected + " Got: " + @out)
        if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("ConvertToASCII did not get the expected exception. The operation succeeded!")
    except StringPrepFormatException:
        if expectedException == nil || !expectedException.Equals(ex):
Errln("ConvertToASCII did not get the expected exception for source: " + src + "
 Got:  " + ex.ToString + "
 Expected: " + ex.ToString)
      var outBuf: Span<char> = newSeq[char](src.Length + 32)
      var errorType: StringPrepErrorType = cast[StringPrepErrorType](-1)
      var success: bool = IDNA.TryConvertToASCII(src.AsSpan, outBuf,       var outBufLength: int, options, errorType)
      if success:
          var @out: string = outBuf.Slice(0, outBufLength).ToString
          if !unassignedException.Equals(expectedException) && expected != nil && @out != nil && !@out.Equals(expected.ToLowerInvariant):
Errln("TryConvertToASCII did not return expected result with options : " + options + " Expected: " + Prettify(expected) + " Got: " + @out)
          if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("TryConvertToASCII did not get the expected exception. The operation succeeded!")
      else:
          if expectedException == nil || cast[StringPrepFormatException](expectedException).Error != errorType:
Errln("TryConvertToASCII did not get the expected exception for source: " + src + " Got:  " + errorType.ToString)
proc DoTestIDNToASCII(src: String, expected: String, options: IDNA2003Options, expectedException: Object) =
    try:
        var @out: string = IDNA.ConvertIDNToASCII(src, options)
        if expected != nil && @out != nil && !@out.Equals(expected):
Errln("ConvertIDNToASCII did not return expected result with options : " + options + " Expected: " + expected + " Got: " + @out)
        if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("ConvertIDNToASCII did not get the expected exception. The operation succeeded!")
    except StringPrepFormatException:
        if expectedException == nil || !ex.Equals(expectedException):
Errln("ConvertIDNToASCII did not get the expected exception for source: " + src + " Got:  " + ex.ToString)
      var outBuf: Span<char> = newSeq[char](src.Length + 32)
      var outBufLength: int = 0
      var errorType: StringPrepErrorType = cast[StringPrepErrorType](-1)
      var success: bool = IDNA.TryConvertIDNToASCII(src.AsSpan, outBuf, outBufLength, options, errorType)
      if success:
          var @out: string = outBuf.Slice(0, outBufLength).ToString
          if expected != nil && @out != nil && !@out.ToString.Equals(expected):
Errln("TryConvertIDNToASCII did not return expected result with options : " + options + " Expected: " + Prettify(expected) + " Got: " + @out)
          if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("TryConvertIDNToASCII did not get the expected exception. The operation succeeded!")
      else:
          if expectedException == nil || cast[StringPrepFormatException](expectedException).Error != errorType:
Errln("TryConvertIDNToASCII did not get the expected exception for source: " + src + " Got:  " + errorType.ToString)
proc TestConformance*() =
      var i: int = 0
      while i < TestData.conformanceTestCases.Length:
          var testCase: TestData.ConformanceTestCase = TestData.conformanceTestCases[i]
          if testCase.expected != nil:
DoTestToASCII(testCase.input, testCase.output, IDNA2003Options.Default, testCase.expected)
DoTestToASCII(testCase.input, testCase.output, IDNA2003Options.AllowUnassigned, testCase.expected)
++i
proc TestNamePrepConformance*() =
    var namePrep: Text.StringPrep = Text.StringPrep.GetInstance(StringPrepProfile.Rfc3491NamePrep)
    var outputBuf: Span<char> = newSeq[char](256)
      var i: int = 0
      while i < TestData.conformanceTestCases.Length:
          var testCase: TestData.ConformanceTestCase = TestData.conformanceTestCases[i]
          try:
              var output: string = namePrep.Prepare(testCase.input, StringPrepOptions.Default)
              if testCase.output != nil && output != nil && !testCase.output.Equals(output):
Errln("Did not get the expected output. Expected: " + Prettify(testCase.output) + " Got: " + Prettify(output))
              if testCase.expected != nil && !unassignedException.Equals(testCase.expected):
Errln("Did not get the expected exception. The operation succeeded!")
          except StringPrepFormatException:
              if testCase.expected == nil || !ex.Equals(testCase.expected):
Errln("Did not get the expected exception for source: " + testCase.input + " Got:  " + ex.ToString)
          try:
              var output: string = namePrep.Prepare(testCase.input, StringPrepOptions.AllowUnassigned)
              if testCase.output != nil && output != nil && !testCase.output.Equals(output):
Errln("Did not get the expected output. Expected: " + Prettify(testCase.output) + " Got: " + Prettify(output))
              if testCase.expected != nil && !unassignedException.Equals(testCase.expected):
Errln("Did not get the expected exception. The operation succeeded!")
          except StringPrepFormatException:
              if testCase.expected == nil || !ex.Equals(testCase.expected):
Errln("Did not get the expected exception for source: " + testCase.input + " Got:  " + ex.ToString)
            var success: bool = namePrep.TryPrepare(testCase.input.AsSpan, outputBuf,             var charsLength: int, StringPrepOptions.Default,             var errorType: StringPrepErrorType)
            if success:
                var output: string = outputBuf.Slice(0, charsLength).ToString
                if testCase.output != nil && output != nil && !testCase.output.Equals(output):
Errln("Did not get the expected output. Expected: " + Prettify(testCase.output) + " Got: " + Prettify(output))
                if testCase.expected != nil && !unassignedException.Equals(testCase.expected):
Errln("Did not get the expected exception. The operation succeeded!")
            else:
                if testCase.expected == nil || errorType != cast[StringPrepFormatException](testCase.expected).Error:
Errln("Did not get the expected exception for source: " + testCase.input + " Got:  " + errorType.ToString)
            var success: bool = namePrep.TryPrepare(testCase.input.AsSpan, outputBuf,             var charsLength: int, StringPrepOptions.AllowUnassigned,             var errorType: StringPrepErrorType)
            if success:
                var output: string = outputBuf.Slice(0, charsLength).ToString
                if testCase.output != nil && output != nil && !testCase.output.Equals(output):
Errln("Did not get the expected output. Expected: " + Prettify(testCase.output) + " Got: " + Prettify(output))
                if testCase.expected != nil && !unassignedException.Equals(testCase.expected):
Errln("Did not get the expected exception. The operation succeeded!")
            else:
                if testCase.expected == nil || errorType != cast[StringPrepFormatException](testCase.expected).Error:
Errln("Did not get the expected exception for source: " + testCase.input + " Got:  " + errorType.ToString)
++i
proc TestErrorCases*() =
      var i: int = 0
      while i < TestData.errorCases.Length:
          var errCase: TestData.ErrorCase = TestData.errorCases[i]
          if errCase.testLabel == true:
DoTestToASCII(String(errCase.unicode), errCase.ascii, IDNA2003Options.Default, errCase.expected)
DoTestToASCII(String(errCase.unicode), errCase.ascii, IDNA2003Options.AllowUnassigned, errCase.expected)
              if errCase.useSTD3ASCIIRules:
DoTestToASCII(String(errCase.unicode), errCase.ascii, IDNA2003Options.UseSTD3Rules, errCase.expected)
          if errCase.useSTD3ASCIIRules != true:
DoTestIDNToASCII(String(errCase.unicode), errCase.ascii, IDNA2003Options.Default, errCase.expected)
DoTestIDNToASCII(String(errCase.unicode), errCase.ascii, IDNA2003Options.AllowUnassigned, errCase.expected)
          else:
DoTestIDNToASCII(String(errCase.unicode), errCase.ascii, IDNA2003Options.UseSTD3Rules, errCase.expected)
          if errCase.testToUnicode == true:
              if errCase.useSTD3ASCIIRules != true:
DoTestIDNToUnicode(errCase.ascii, String(errCase.unicode), IDNA2003Options.Default, errCase.expected)
DoTestIDNToUnicode(errCase.ascii, String(errCase.unicode), IDNA2003Options.AllowUnassigned, errCase.expected)
              else:
DoTestIDNToUnicode(errCase.ascii, String(errCase.unicode), IDNA2003Options.UseSTD3Rules, errCase.expected)
++i
proc DoTestCompare(s1: String, s2: String, isEqual: bool) =
    try:
        var retVal: int = IDNA.Compare(s1, s2, IDNA2003Options.Default)
        if isEqual == true && retVal != 0:
Errln("Did not get the expected result for s1: " + Prettify(s1) + " s2: " + Prettify(s2))
        retVal = IDNA.Compare(s1.AsSpan, s2.AsSpan, IDNA2003Options.Default)
        if isEqual == true && retVal != 0:
Errln("Did not get the expected result for s1: " + Prettify(s1) + " s2: " + Prettify(s2))
    except Exception:
e.PrintStackTrace
Errln("Unexpected exception thrown by IDNA.compare")
    try:
        var retVal: int = IDNA.Compare(s1, s2, IDNA2003Options.AllowUnassigned)
        if isEqual == true && retVal != 0:
Errln("Did not get the expected result for s1: " + Prettify(s1) + " s2: " + Prettify(s2))
        retVal = IDNA.Compare(s1.AsSpan, s2.AsSpan, IDNA2003Options.AllowUnassigned)
        if isEqual == true && retVal != 0:
Errln("Did not get the expected result for s1: " + Prettify(s1) + " s2: " + Prettify(s2))
    except Exception:
Errln("Unexpected exception thrown by IDNA.compare")
proc TestCompare*() =
    var www: String = "www."
    var com: String = ".com"
    var source: StringBuffer = StringBuffer(www)
    var uni0: StringBuffer = StringBuffer(www)
    var uni1: StringBuffer = StringBuffer(www)
    var ascii0: StringBuffer = StringBuffer(www)
    var ascii1: StringBuffer = StringBuffer(www)
uni0.Append(TestData.unicodeIn[0])
uni0.Append(com)
uni1.Append(TestData.unicodeIn[1])
uni1.Append(com)
ascii0.Append(TestData.asciiIn[0])
ascii0.Append(com)
ascii1.Append(TestData.asciiIn[1])
ascii1.Append(com)
      var i: int = 0
      while i < TestData.unicodeIn.Length:
          source.Length = 4
source.Append(TestData.unicodeIn[i])
source.Append(com)
DoTestCompare(source.ToString, source.ToString, true)
DoTestCompare(source.ToString, www + TestData.asciiIn[i] + com, true)
          if i == 0:
DoTestCompare(source.ToString, uni1.ToString, false)
          else:
DoTestCompare(source.ToString, uni0.ToString, false)
          if i == 0:
DoTestCompare(source.ToString, ascii1.ToString, false)
          else:
DoTestCompare(source.ToString, ascii0.ToString, false)
++i
proc DoTestChainingToASCII(source: String) =
    var expected: string
    var chained: string
    expected = IDNA.ConvertIDNToASCII(source, IDNA2003Options.Default)
    chained = expected
      var i: int = 0
      while i < 4:
          chained = IDNA.ConvertIDNToASCII(chained, IDNA2003Options.Default)
++i
    if !expected.Equals(chained):
Errln("Chaining test failed for convertIDNToASCII")
    expected = IDNA.ConvertToASCII(source, IDNA2003Options.Default)
    chained = expected
      var i: int = 0
      while i < 4:
          chained = IDNA.ConvertToASCII(chained, IDNA2003Options.Default)
++i
    if !expected.Equals(chained):
Errln("Chaining test failed for convertToASCII")
proc DoTestChainingToUnicode(source: String) =
    var expected: string
    var chained: string
    expected = IDNA.ConvertIDNToUnicode(source, IDNA2003Options.Default)
    chained = expected
      var i: int = 0
      while i < 4:
          chained = IDNA.ConvertIDNToUnicode(chained, IDNA2003Options.Default)
++i
    if !expected.Equals(chained):
Errln("Chaining test failed for convertIDNToUnicode")
    expected = IDNA.ConvertToUnicode(source, IDNA2003Options.Default)
    chained = expected
      var i: int = 0
      while i < 4:
          chained = IDNA.ConvertToUnicode(chained, IDNA2003Options.Default)
++i
    if !expected.Equals(chained):
Errln("Chaining test failed for convertToUnicode")
proc TestChaining*() =
      var i: int = 0
      while i < TestData.asciiIn.Length:
DoTestChainingToUnicode(TestData.asciiIn[i])
++i
      var i: int = 0
      while i < TestData.unicodeIn.Length:
DoTestChainingToASCII(String(TestData.unicodeIn[i]))
++i
proc TestRootLabelSeparator*() =
    var www: String = "www."
    var com: String = ".com."
    var source: StringBuffer = StringBuffer(www)
    var uni0: StringBuffer = StringBuffer(www)
    var uni1: StringBuffer = StringBuffer(www)
    var ascii0: StringBuffer = StringBuffer(www)
    var ascii1: StringBuffer = StringBuffer(www)
uni0.Append(TestData.unicodeIn[0])
uni0.Append(com)
uni1.Append(TestData.unicodeIn[1])
uni1.Append(com)
ascii0.Append(TestData.asciiIn[0])
ascii0.Append(com)
ascii1.Append(TestData.asciiIn[1])
ascii1.Append(com)
      var i: int = 0
      while i < TestData.unicodeIn.Length:
          source.Length = 4
source.Append(TestData.unicodeIn[i])
source.Append(com)
DoTestCompare(source.ToString, source.ToString, true)
DoTestCompare(source.ToString, www + TestData.asciiIn[i] + com, true)
          if i == 0:
DoTestCompare(source.ToString, uni1.ToString, false)
          else:
DoTestCompare(source.ToString, uni0.ToString, false)
          if i == 0:
DoTestCompare(source.ToString, ascii1.ToString, false)
          else:
DoTestCompare(source.ToString, ascii0.ToString, false)
++i
proc RandUni(): int =
    var retVal: int = cast[int](random.Next & 262143)
    if retVal >= 196608:
        retVal = 720896
    return retVal
proc Randi(n: int): int =
    return random.Next(32767) % n + 1
proc GetTestSource(fillIn: StringBuffer): StringBuffer =
    if random == nil:
        random = CreateRandom
    var i: int = 0
    var charCount: int = Randi(maxCharCount) + 1
    while i < charCount:
        var codepoint: int = RandUni
        if codepoint == 0:
            continue
UTF16.Append(fillIn, codepoint)
++i
    return fillIn
proc MonkeyTest*() =
    var source: StringBuffer = StringBuffer
      var i: int = 0
      while i < loopCount:
          source.Length = 0
GetTestSource(source)
DoTestCompareReferenceImpl(source)
++i
source.Append("\u0000\u2109\u3E1B\U000E65CA\U0001CAC5")
    source = StringBuffer(Utility.Unescape(source.ToString))
DoTestCompareReferenceImpl(source)
    source = StringBuffer(Utility.Unescape("\u043f\u00AD\u034f\u043e\u0447\u0435\u043c\u0443\u0436\u0435\u043e\u043d\u0438\u043d\u0435\u0433\u043e\u0432\u043e\u0440\u044f\u0442\u043f\u043e\u0440\u0443\u0441\u0441\u043a\u0438"))
    var expected: StringBuffer = StringBuffer("xn--b1abfaaepdrnnbgefbadotcwatmq2g4l")
DoTestCompareReferenceImpl(source)
DoTestToASCII(source.ToString, expected.ToString, IDNA2003Options.Default, nil)
proc _doTestCompareReferenceImpl(src: StringBuffer, toASCII: bool, options: IDNA2003Options): StringBuffer =
    var refIDNAName: String =     if toASCII:
"IDNAReference.convertToASCII"
    else:
"IDNAReference.convertToUnicode"
    var uIDNAName: String =     if toASCII:
"IDNA.convertToASCII"
    else:
"IDNA.convertToUnicode"
Logln("Comparing " + refIDNAName + " with " + uIDNAName + " for input: " + Prettify(src) + " with options: " + options)
    var exp: StringBuffer = nil
    var expStatus: int = -1
    try:
        exp =         if toASCII:
IDNAReference.ConvertToASCII(src, options)
        else:
IDNAReference.ConvertToUnicode(src, options)
    except StringPrepFormatException:
        expStatus = cast[int](e.Error)
    var got: string = nil
    var gotStatus: int = -1
    try:
        got =         if toASCII:
IDNA.ConvertToASCII(src.ToString, options)
        else:
IDNA.ConvertToUnicode(src.ToString, options)
    except StringPrepFormatException:
        gotStatus = cast[int](e.Error)
    if expStatus != gotStatus:
Errln("Did not get the expected status while comparing " + refIDNAName + " with " + uIDNAName + " Expected: " + expStatus + " Got: " + gotStatus + " for Source: " + Prettify(src) + " Options: " + options)
    else:
        if gotStatus == -1:
            if !got.ToString.Equals(exp.ToString):
Errln("Did not get the expected output while comparing " + refIDNAName + " with " + uIDNAName + " Expected: " + exp + " Got: " + got + " for Source: " + Prettify(src) + " Options: " + options)
        else:
Logln("Got the same error while comparing " + refIDNAName + " with " + uIDNAName + " for input: " + Prettify(src) + " with options: " + options)
    return exp
proc DoTestCompareReferenceImpl(src: StringBuffer) =
    var asciiLabel: StringBuffer = _doTestCompareReferenceImpl(src, true, IDNA2003Options.AllowUnassigned)
_doTestCompareReferenceImpl(src, true, IDNA2003Options.Default)
_doTestCompareReferenceImpl(src, true, IDNA2003Options.UseSTD3Rules)
_doTestCompareReferenceImpl(src, true, IDNA2003Options.UseSTD3Rules | IDNA2003Options.AllowUnassigned)
    if asciiLabel != nil:
_doTestCompareReferenceImpl(src, false, IDNA2003Options.AllowUnassigned)
_doTestCompareReferenceImpl(src, false, IDNA2003Options.Default)
_doTestCompareReferenceImpl(src, false, IDNA2003Options.UseSTD3Rules)
_doTestCompareReferenceImpl(src, false, IDNA2003Options.UseSTD3Rules | IDNA2003Options.AllowUnassigned)
proc TestJB4490*() =
    var @in: String[] = @["õÞßÝ", "ﬀﬁ"]
      var i: int = 0
      while i < @in.Length:
          try:
              var ascii: String = IDNA.ConvertToASCII(@in[i], IDNA2003Options.Default).ToString
              try:
                  var unicode: String = IDNA.ConvertToUnicode(ascii, IDNA2003Options.Default).ToString
Logln("result " + unicode)
              except StringPrepFormatException:
Errln("Unexpected exception for convertToUnicode: " + ex.ToString)
          except StringPrepFormatException:
Errln("Unexpected exception for convertToASCII: " + ex.ToString)
++i
proc TestJB4475*() =
    var @in: String[] = @["TEST", "test"]
      var i: int = 0
      while i < @in.Length:
          try:
              var ascii: String = IDNA.ConvertToASCII(@in[i], IDNA2003Options.Default).ToString
              if !ascii.Equals(@in[i]):
Errln("Did not get the expected string for convertToASCII. Expected: " + @in[i] + " Got: " + ascii)
          except StringPrepFormatException:
Errln("Unexpected exception: " + ex.ToString)
++i
proc TestDebug*() =
    try:
        var src: String = "í4dn"
        var uni: String = IDNA.ConvertToUnicode(src, IDNA2003Options.Default).ToString
        if !uni.Equals(src):
Errln("Did not get the expected result. Expected: " + Prettify(src) + " Got: " + uni)
    except StringPrepFormatException:
Logln("Unexpected exception: " + ex.ToString)
    try:
        var ascii: String = IDNA.ConvertToASCII("­", IDNA2003Options.Default).ToString
        if ascii != nil:
Errln("Did not get the expected exception")
    except StringPrepFormatException:
Logln("Got the expected exception: " + ex.ToString)
proc TestJB5273*() =
    var INVALID_DOMAIN_NAME: String = "xn--müller.de"
    try:
IDNA.ConvertIDNToUnicode(INVALID_DOMAIN_NAME, IDNA2003Options.Default)
IDNA.ConvertIDNToUnicode(INVALID_DOMAIN_NAME, IDNA2003Options.UseSTD3Rules)
    except StringPrepFormatException:
Errln("Unexpected exception: " + ex.ToString)
    except IndexOutOfRangeException:
Errln("Got an ArrayIndexOutOfBoundsException calling convertIDNToUnicode("" + INVALID_DOMAIN_NAME + "")")
    var domain: String = "xn--müller.de"
    try:
IDNA.ConvertIDNToUnicode(domain, IDNA2003Options.Default)
    except StringPrepFormatException:
Logln("Got the expected exception. " + ex.ToString)
    except Exception:
Errln("Unexpected exception: " + ex.ToString)
    try:
IDNA.ConvertIDNToUnicode(domain, IDNA2003Options.UseSTD3Rules)
    except StringPrepFormatException:
Logln("Got the expected exception. " + ex.ToString)
    except Exception:
Errln("Unexpected exception: " + ex.ToString)
    try:
IDNA.ConvertToUnicode("xn--müller", IDNA2003Options.Default)
    except Exception:
Errln("ToUnicode operation failed! " + ex.ToString)
    try:
IDNA.ConvertToUnicode("xn--müller", IDNA2003Options.UseSTD3Rules)
    except Exception:
Errln("ToUnicode operation failed! " + ex.ToString)
    try:
IDNA.ConvertIDNToUnicode("xn--mሴller", IDNA2003Options.UseSTD3Rules)
    except StringPrepFormatException:
Errln("ToUnicode operation failed! " + ex.ToString)
proc TestLength*() =
    var ul: String = "my_very_very_very_very_very_very_very_very_very_very_very_very_very_long_and_incredibly_uncreative_domain_label"
    var ul1: String = "세계의모든사람들이" + "한국어를이­͏᠆᠋" + "᠌᠍​‌‍⁠︀︁︂" + "︃︄︅︆︇︈︉︊︋" + "︌︍︎️﻿해한다면" + "세A­͏᠆᠋᠌᠍​" + "‌‍⁠︀︁︂︃︄︅" + "︆︇︈︉︊︋︌︍︎" + "️﻿­͏᠆᠋᠌᠍​" + "‌‍⁠︀︁︂︃︄︅" + "︆︇︈︉︊︋︌︍︎" + "️﻿­͏᠆᠋᠌᠍​" + "‌‍⁠︀︁︂︃︄︅" + "︆︇︈︉︊︋︌︍︎" + "️﻿"
    try:
IDNA.ConvertToASCII(ul, IDNA2003Options.Default)
Errln("IDNA.convertToUnicode did not fail!")
    except StringPrepFormatException:
        if ex.Error != StringPrepErrorType.LabelTooLongError:
Errln("IDNA.convertToASCII failed with error: " + ex.ToString)
        else:
Logln("IDNA.ConvertToASCII(ul, IDNAOptions.Default) Succeeded")
    try:
IDNA.ConvertToASCII(ul1, IDNA2003Options.Default)
    except StringPrepFormatException:
Errln("IDNA.convertToASCII failed with error: " + ex.ToString)
    try:
IDNA.ConvertToUnicode(ul1, IDNA2003Options.Default)
    except StringPrepFormatException:
Errln("IDNA.convertToASCII failed with error: " + ex.ToString)
    try:
IDNA.ConvertToUnicode(ul, IDNA2003Options.Default)
    except StringPrepFormatException:
Errln("IDNA.convertToASCII failed with error: " + ex.ToString)
    var idn: String = "my_very_very_long_and_incredibly_uncreative_domain_label.my_very_very_long_and_incredibly_uncreative_domain_label.my_very_very_long_and_incredibly_uncreative_domain_label.my_very_very_long_and_incredibly_uncreative_domain_label.my_very_very_long_and_incredibly_uncreative_domain_label.my_very_very_long_and_incredibly_uncreative_domain_label.ibm.com"
    try:
IDNA.ConvertIDNToASCII(idn, IDNA2003Options.Default)
Errln("IDNA.convertToUnicode did not fail!")
    except StringPrepFormatException:
        if ex.Error != StringPrepErrorType.DomainNameTooLongError:
Errln("IDNA.convertToASCII failed with error: " + ex.ToString)
        else:
Logln("IDNA.ConvertToASCII(idn, IDNAOptions.Default) Succeeded")
    try:
IDNA.ConvertIDNToUnicode(idn, IDNA2003Options.Default)
Errln("IDNA.convertToUnicode did not fail!")
    except StringPrepFormatException:
        if ex.Error != StringPrepErrorType.DomainNameTooLongError:
Errln("IDNA.convertToUnicode failed with error: " + ex.ToString)
        else:
Logln("IDNA.ConvertToUnicode(idn, IDNAOptions.Default) Succeeded")
proc TestConvertToASCII*() =
    try:
        if !IDNA.ConvertToASCII("dummy", 0).ToString.Equals("dummy"):
Errln("IDNA.ConvertToASCII(String,int) was suppose to return the same string passed.")
    except Exception:
Errln("IDNA.ConvertToASCII(String,int) was not suppose to return an exception.")
    var result: Span<char> = newSeq[char](10)
    var success: bool = IDNA.TryConvertToASCII("dummy".AsSpan, result,     var resultLength: int, 0, _)
    if success:
        if !result.Slice(0, resultLength).ToString.Equals("dummy"):
Errln("IDNA.TryConvertToASCII(ReadOnlySpan<char>, Span<char>, out int, IDNA2003Options, out StringPrepErrorType) was suppose to " + "return the same string passed.")
    else:
Errln("IDNA.TryConvertToASCII was not suppose to return an error.")
proc TestConvertIDNToASCII*() =
    try:
        if !IDNA.ConvertIDNToASCII("dummy", 0).Equals("dummy"):
Errln("IDNA.ConvertIDNToASCII(string, IDNA2003Options) was suppose to " + "return the same string passed.")
        if !IDNA.ConvertIDNToASCII("dummy".AsSpan, 0).Equals("dummy"):
Errln("IDNA.ConvertIDNToASCII(string, IDNA2003Options) was suppose to " + "return the same string passed.")
    except Exception:
Errln("IDNA.ConvertIDNToASCII was not suppose to return an exception.")
    var result: Span<char> = newSeq[char](10)
    var success: bool = IDNA.TryConvertIDNToASCII("dummy".AsSpan, result,     var resultLength: int, 0, _)
    if success:
        if !result.Slice(0, resultLength).ToString.Equals("dummy"):
Errln("IDNA.TryConvertIDNToASCII(ReadOnlySpan<char>, Span<char>, out int, IDNA2003Options, out StringPrepErrorType) was suppose to " + "return the same string passed.")
    else:
Errln("IDNA.TryConvertIDNToASCII was not suppose to return an error.")
proc TestConvertToUnicode*() =
    try:
        if !IDNA.ConvertToUnicode("dummy", 0).Equals("dummy"):
Errln("IDNA.ConvertToUnicode(String, IDNA2003Options) was suppose to " + "return the same string passed.")
        if !IDNA.ConvertToUnicode("dummy".AsSpan, 0).Equals("dummy"):
Errln("IDNA.ConvertToUnicode(ReadOnlySpan<chr>, IDNA2003Options) was suppose to " + "return the same string passed.")
    except Exception:
Errln("IDNA.ConvertToUnicode was not suppose to return an exception.")
    var result: Span<char> = newSeq[char](10)
    var success: bool = IDNA.TryConvertToUnicode("dummy".AsSpan, result,     var resultLength: int, 0, _)
    if success:
        if !result.Slice(0, resultLength).ToString.Equals("dummy"):
Errln("IDNA.TryConvertToUnicode(ReadOnlySpan<char>, Span<char>, out int, IDNA2003Options, out StringPrepErrorType) was suppose to " + "return the same string passed.")
    else:
Errln("IDNA.TryConvertToUnicode was not suppose to return an error.")
proc TestConvertIDNToUnicode*() =
    try:
        if !IDNA.ConvertIDNToUnicode("dummy", 0).Equals("dummy"):
Errln("IDNA.ConvertIDNToUnicode(string, IDNA2003Options) was suppose to " + "return the same string passed.")
        if !IDNA.ConvertIDNToUnicode("dummy".AsSpan, 0).Equals("dummy"):
Errln("IDNA.ConvertIDNToUnicode(ReadOnlySpan<char>, IDNA2003Options) was suppose to " + "return the same string passed.")
    except Exception:
Errln("IDNA.convertIDNToUnicode was not suppose to return an exception.")
    var result: Span<char> = newSeq[char](10)
    var success: bool = IDNA.TryConvertIDNToUnicode("dummy".AsSpan, result,     var resultLength: int, 0, _)
    if success:
        if !result.Slice(0, resultLength).ToString.Equals("dummy"):
Errln("IDNA.TryConvertIDNToUnicode(ReadOnlySpan<char>, Span<char>, out int, IDNA2003Options, out StringPrepErrorType) was suppose to " + "return the same string passed.")
    else:
Errln("IDNA.TryConvertIDNToUnicode was not suppose to return an error.")
proc TestIDNACompare*() =
    try:
IDNA.Compare(cast[String](nil), cast[String](nil), 0)
Errln("IDNA.Compare((String)null,(String)null) was suppose to return an exception.")
    except Exception:

    try:
IDNA.Compare(cast[String](nil), "dummy", 0)
Errln("IDNA.Compare((String)null,'dummy') was suppose to return an exception.")
    except Exception:

    try:
IDNA.Compare("dummy", cast[String](nil), 0)
Errln("IDNA.Compare('dummy',(String)null) was suppose to return an exception.")
    except Exception:

    try:
        if IDNA.Compare("dummy", "dummy", 0) != 0:
Errln("IDNA.Compare('dummy','dummy') was suppose to return a 0.")
    except Exception:
Errln("IDNA.Compare('dummy','dummy') was not suppose to return an exception.")
    try:
        if IDNA.Compare("dummy".AsSpan, "dummy".AsSpan, 0) != 0:
Errln("IDNA.Compare('dummy','dummy') was suppose to return a 0.")
    except Exception:
Errln("IDNA.Compare('dummy','dummy') was not suppose to return an exception.")
proc TestTryConvertToASCII_BufferOverflow*() =
    var longBuffer: Span<char> = newSeq[char](256)
    var shortBuffer: Span<char> = newSeq[char](4)
      var i: int = 0
      while i < TestData.asciiIn.Length:
DoTest(TestData.unicodeIn[i], longBuffer, shortBuffer)
++i
    proc DoTest(src: ReadOnlySpan<char>, longBuffer: Span<char>, shortBuffer: Span<char>) =
        var success: bool = IDNA.TryConvertToASCII(src, longBuffer,         var longBufferLength: int, IDNA2003Options.Default, _)
        if !success:
Errln("IDNA.TryConvertToASCII was not suppose to return an exception when there is a long enough buffer.")
        success = IDNA.TryConvertToASCII(src, shortBuffer,         var shortBufferLength: int, IDNA2003Options.Default,         var errorType: StringPrepErrorType)
        if success || errorType != StringPrepErrorType.BufferOverflowError:
Errln("IDNA.TryConvertToASCII was suppose to return a " & $StringPrepErrorType.BufferOverflowError & " when the buffer is too short.")
        if shortBufferLength < longBufferLength:
Errln("IDNA.TryConvertToASCII was suppose to return a buffer size large enough to fit the text.")
proc TestTryConvertToUnicode_BufferOverflow*() =
    var longBuffer: Span<char> = newSeq[char](256)
    var shortBuffer: Span<char> = newSeq[char](4)
      var i: int = 0
      while i < TestData.asciiIn.Length:
DoTest(TestData.asciiIn[i], longBuffer, shortBuffer)
++i
    proc DoTest(src: string, longBuffer: Span<char>, shortBuffer: Span<char>) =
        var success: bool = IDNA.TryConvertToUnicode(src.AsSpan, longBuffer,         var longBufferLength: int, IDNA2003Options.Default, _)
        if !success:
Errln("IDNA.TryConvertToUnicode was not suppose to return an exception when there is a long enough buffer.")
        success = IDNA.TryConvertToUnicode(src.AsSpan, shortBuffer,         var shortBufferLength: int, IDNA2003Options.Default,         var errorType: StringPrepErrorType)
        if success || errorType != StringPrepErrorType.BufferOverflowError:
Errln("IDNA.TryConvertToUnicode was suppose to return a " & $StringPrepErrorType.BufferOverflowError & " when the buffer is too short.")
        if shortBufferLength < longBufferLength:
Errln("IDNA.TryConvertToUnicode was suppose to return a buffer size large enough to fit the text.")
proc TestTryConvertIDNToASCII_BufferOverflow*() =
    var longBuffer: Span<char> = newSeq[char](256)
    var shortBuffer: Span<char> = newSeq[char](4)
      var i: int = 0
      while i < TestData.domainNames.Length:
DoTest(TestData.domainNames[i], longBuffer, shortBuffer)
++i
      var i: int = 0
      while i < TestData.domainNames1Uni.Length:
DoTest(TestData.domainNames1Uni[i], longBuffer, shortBuffer)
++i
    proc DoTest(src: string, longBuffer: Span<char>, shortBuffer: Span<char>) =
        var success: bool = IDNA.TryConvertIDNToASCII(src.AsSpan, longBuffer,         var longBufferLength: int, IDNA2003Options.Default, _)
        if !success:
Errln("IDNA.TryConvertIDNToASCII was not suppose to return an exception when there is a long enough buffer.")
        success = IDNA.TryConvertIDNToASCII(src.AsSpan, shortBuffer,         var shortBufferLength: int, IDNA2003Options.Default,         var errorType: StringPrepErrorType)
        if success || errorType != StringPrepErrorType.BufferOverflowError:
Errln("IDNA.TryConvertIDNToASCII was suppose to return a " & $StringPrepErrorType.BufferOverflowError & " when the buffer is too short.")
        if shortBufferLength < longBufferLength:
Errln("IDNA.TryConvertIDNToASCII was suppose to return a buffer size large enough to fit the text.")
proc TestTryConvertIDNToUnicode_BufferOverflow*() =
    var longBuffer: Span<char> = newSeq[char](256)
    var shortBuffer: Span<char> = newSeq[char](4)
      var i: int = 0
      while i < TestData.domainNames.Length:
DoTest(TestData.domainNames[i], longBuffer, shortBuffer)
++i
      var i: int = 0
      while i < TestData.domainNamesToASCIIOut.Length:
DoTest(TestData.domainNamesToASCIIOut[i], longBuffer, shortBuffer)
++i
    proc DoTest(src: string, longBuffer: Span<char>, shortBuffer: Span<char>) =
        var success: bool = IDNA.TryConvertIDNToUnicode(src.AsSpan, longBuffer,         var longBufferLength: int, IDNA2003Options.Default, _)
        if !success:
Errln("IDNA.TryConvertIDNToUnicode was not suppose to return an exception when there is a long enough buffer.")
        success = IDNA.TryConvertIDNToUnicode(src.AsSpan, shortBuffer,         var shortBufferLength: int, IDNA2003Options.Default,         var errorType: StringPrepErrorType)
        if success || errorType != StringPrepErrorType.BufferOverflowError:
Errln("IDNA.TryConvertIDNToUnicode was suppose to return a " & $StringPrepErrorType.BufferOverflowError & " when the buffer is too short.")
        if shortBufferLength < longBufferLength:
Errln("IDNA.TryConvertIDNToUnicode was suppose to return a buffer size large enough to fit the text.")