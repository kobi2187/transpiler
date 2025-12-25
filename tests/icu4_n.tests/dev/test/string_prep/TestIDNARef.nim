# "Namespace: ICU4N.Dev.Test.StringPrep"
type
  TestIDNARef = ref object
    unassignedException: StringPrepFormatException = StringPrepFormatException("", StringPrepErrorType.UnassignedError)

proc TestToUnicode*() =
    try:
          var i: int = 0
          while i < TestData.asciiIn.Length:
DoTestToUnicode(TestData.asciiIn[i], String(TestData.unicodeIn[i]), IDNAReference.DEFAULT, nil)
DoTestToUnicode(TestData.asciiIn[i], String(TestData.unicodeIn[i]), IDNAReference.ALLOW_UNASSIGNED, nil)
++i
    except TypeInitializationException:
Warnln("Could not load NamePrepTransform data")
    except TypeLoadException:
Warnln("Could not load NamePrepTransform data")
proc TestToASCII*() =
    try:
          var i: int = 0
          while i < TestData.asciiIn.Length:
DoTestToASCII(String(TestData.unicodeIn[i]), TestData.asciiIn[i], IDNAReference.DEFAULT, nil)
DoTestToASCII(String(TestData.unicodeIn[i]), TestData.asciiIn[i], IDNAReference.ALLOW_UNASSIGNED, nil)
++i
    except TypeInitializationException:
Warnln("Could not load NamePrepTransform data")
    except TypeLoadException:
Warnln("Could not load NamePrepTransform data")
proc TestIDNToASCII*() =
    try:
          var i: int = 0
          while i < TestData.domainNames.Length:
DoTestIDNToASCII(TestData.domainNames[i], TestData.domainNames[i], IDNAReference.DEFAULT, nil)
DoTestIDNToASCII(TestData.domainNames[i], TestData.domainNames[i], IDNAReference.ALLOW_UNASSIGNED, nil)
DoTestIDNToASCII(TestData.domainNames[i], TestData.domainNames[i], IDNAReference.USE_STD3_RULES, nil)
DoTestIDNToASCII(TestData.domainNames[i], TestData.domainNames[i], IDNAReference.ALLOW_UNASSIGNED | IDNAReference.USE_STD3_RULES, nil)
++i
          var i: int = 0
          while i < TestData.domainNames1Uni.Length:
DoTestIDNToASCII(TestData.domainNames1Uni[i], TestData.domainNamesToASCIIOut[i], IDNAReference.DEFAULT, nil)
DoTestIDNToASCII(TestData.domainNames1Uni[i], TestData.domainNamesToASCIIOut[i], IDNAReference.ALLOW_UNASSIGNED, nil)
DoTestIDNToASCII(TestData.domainNames1Uni[i], TestData.domainNamesToASCIIOut[i], IDNAReference.USE_STD3_RULES, nil)
DoTestIDNToASCII(TestData.domainNames1Uni[i], TestData.domainNamesToASCIIOut[i], IDNAReference.ALLOW_UNASSIGNED | IDNAReference.USE_STD3_RULES, nil)
++i
    except TypeInitializationException:
Warnln("Could not load NamePrepTransform data")
    except TypeLoadException:
Warnln("Could not load NamePrepTransform data")
proc TestIDNToUnicode*() =
    try:
          var i: int = 0
          while i < TestData.domainNames.Length:
DoTestIDNToUnicode(TestData.domainNames[i], TestData.domainNames[i], IDNAReference.DEFAULT, nil)
DoTestIDNToUnicode(TestData.domainNames[i], TestData.domainNames[i], IDNAReference.ALLOW_UNASSIGNED, nil)
DoTestIDNToUnicode(TestData.domainNames[i], TestData.domainNames[i], IDNAReference.USE_STD3_RULES, nil)
DoTestIDNToUnicode(TestData.domainNames[i], TestData.domainNames[i], IDNAReference.ALLOW_UNASSIGNED | IDNAReference.USE_STD3_RULES, nil)
++i
          var i: int = 0
          while i < TestData.domainNamesToASCIIOut.Length:
DoTestIDNToUnicode(TestData.domainNamesToASCIIOut[i], TestData.domainNamesToUnicodeOut[i], IDNAReference.DEFAULT, nil)
DoTestIDNToUnicode(TestData.domainNamesToASCIIOut[i], TestData.domainNamesToUnicodeOut[i], IDNAReference.ALLOW_UNASSIGNED, nil)
++i
    except TypeInitializationException:
Warnln("Could not load NamePrepTransform data")
    except TypeLoadException:
Warnln("Could not load NamePrepTransform data")
proc DoTestToUnicode(src: String, expected: String, options: IDNA2003Options, expectedException: Object) =
    if !IDNAReference.IsReady:
Logln("Transliterator is not available on this environment.  Skipping doTestToUnicode.")
        return
    var inBuf: StringBuffer = StringBuffer(src)
    var inIter: UCharacterIterator = UCharacterIterator.GetInstance(src)
    try:
        var @out: StringBuffer = IDNAReference.ConvertToUnicode(src, options)
        if expected != nil && @out != nil && !@out.ToString.Equals(expected):
Errln("convertToUnicode did not return expected result with options : " + options + " Expected: " + Prettify(expected) + " Got: " + Prettify(@out))
        if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("convertToUnicode did not get the expected exception. The operation succeeded!")
    except StringPrepFormatException:
        if expectedException == nil || !ex.Equals(expectedException):
Errln("convertToUnicode did not get the expected exception for source: " + Prettify(src) + " Got:  " + ex.ToString)
    try:
        var @out: StringBuffer = IDNAReference.ConvertToUnicode(inBuf, options)
        if expected != nil && @out != nil && !@out.ToString.Equals(expected):
Errln("convertToUnicode did not return expected result with options : " + options + " Expected: " + Prettify(expected) + " Got: " + @out)
        if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("convertToUnicode did not get the expected exception. The operation succeeded!")
    except StringPrepFormatException:
        if expectedException == nil || !ex.Equals(expectedException):
Errln("convertToUnicode did not get the expected exception for source: " + Prettify(src) + " Got:  " + ex.ToString)
    try:
        var @out: StringBuffer = IDNAReference.ConvertToUnicode(inIter, options)
        if expected != nil && @out != nil && !@out.ToString.Equals(expected):
Errln("convertToUnicode did not return expected result with options : " + options + " Expected: " + Prettify(expected) + " Got: " + Prettify(@out))
        if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("Did not get the expected exception. The operation succeeded!")
    except StringPrepFormatException:
        if expectedException == nil || !ex.Equals(expectedException):
Errln("Did not get the expected exception for source: " + Prettify(src) + " Got:  " + ex.ToString)
proc DoTestIDNToUnicode(src: String, expected: String, options: IDNA2003Options, expectedException: Object) =
    if !IDNAReference.IsReady:
Logln("Transliterator is not available on this environment.  Skipping doTestIDNToUnicode.")
        return
    var inBuf: StringBuffer = StringBuffer(src)
    var inIter: UCharacterIterator = UCharacterIterator.GetInstance(src)
    try:
        var @out: StringBuffer = IDNAReference.ConvertIDNToUnicode(src, options)
        if expected != nil && @out != nil && !@out.ToString.Equals(expected):
Errln("convertToUnicode did not return expected result with options : " + options + " Expected: " + Prettify(expected) + " Got: " + Prettify(@out))
        if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("convertToUnicode did not get the expected exception. The operation succeeded!")
    except StringPrepFormatException:
        if expectedException == nil || !expectedException.Equals(ex):
Errln("convertToUnicode did not get the expected exception for source: " + src + " Got:  " + ex.ToString)
    try:
        var @out: StringBuffer = IDNAReference.ConvertIDNToUnicode(inBuf, options)
        if expected != nil && @out != nil && !@out.ToString.Equals(expected):
Errln("convertToUnicode did not return expected result with options : " + options + " Expected: " + Prettify(expected) + " Got: " + @out)
        if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("convertToUnicode did not get the expected exception. The operation succeeded!")
    except StringPrepFormatException:
        if expectedException == nil || !expectedException.Equals(ex):
Errln("convertToUnicode did not get the expected exception for source: " + src + " Got:  " + ex.ToString)
    try:
        var @out: StringBuffer = IDNAReference.ConvertIDNToUnicode(inIter, options)
        if expected != nil && @out != nil && !@out.ToString.Equals(expected):
Errln("convertToUnicode did not return expected result with options : " + options + " Expected: " + Prettify(expected) + " Got: " + Prettify(@out))
        if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("Did not get the expected exception. The operation succeeded!")
    except StringPrepFormatException:
        if expectedException == nil || !expectedException.Equals(ex):
Errln("Did not get the expected exception for source: " + src + " Got:  " + ex.ToString)
proc DoTestToASCII(src: String, expected: String, options: IDNA2003Options, expectedException: Object) =
    if !IDNAReference.IsReady:
Logln("Transliterator is not available on this environment.  Skipping doTestToASCII.")
        return
    var inBuf: StringBuffer = StringBuffer(src)
    var inIter: UCharacterIterator = UCharacterIterator.GetInstance(src)
    try:
        var @out: StringBuffer = IDNAReference.ConvertToASCII(src, options)
        if !unassignedException.Equals(expectedException) && expected != nil && @out != nil && expected != nil && @out != nil && !@out.ToString.Equals(expected.ToLowerInvariant):
Errln("convertToASCII did not return expected result with options : " + options + " Expected: " + expected + " Got: " + @out)
        if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("convertToASCII did not get the expected exception. The operation succeeded!")
    except StringPrepFormatException:
        if expectedException == nil || !expectedException.Equals(ex):
Errln("convertToASCII did not get the expected exception for source: " + src + " Got:  " + ex.ToString)
    try:
        var @out: StringBuffer = IDNAReference.ConvertToASCII(inBuf, options)
        if !unassignedException.Equals(expectedException) && expected != nil && @out != nil && expected != nil && @out != nil && !@out.ToString.Equals(expected.ToLowerInvariant):
Errln("convertToASCII did not return expected result with options : " + options + " Expected: " + expected + " Got: " + @out)
        if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("convertToASCII did not get the expected exception. The operation succeeded!")
    except StringPrepFormatException:
        if expectedException == nil || !expectedException.Equals(ex):
Errln("convertToASCII did not get the expected exception for source: " + src + " Got:  " + ex.ToString)
    try:
        var @out: StringBuffer = IDNAReference.ConvertToASCII(inIter, options)
        if !unassignedException.Equals(expectedException) && expected != nil && @out != nil && expected != nil && @out != nil && !@out.ToString.Equals(expected.ToLowerInvariant):
Errln("convertToASCII did not return expected result with options : " + options + " Expected: " + expected + " Got: " + @out)
        if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("convertToASCII did not get the expected exception. The operation succeeded!")
    except StringPrepFormatException:
        if expectedException == nil || !expectedException.Equals(ex):
Errln("convertToASCII did not get the expected exception for source: " + src + " Got:  " + ex.ToString)
proc DoTestIDNToASCII(src: String, expected: String, options: IDNA2003Options, expectedException: Object) =
    if !IDNAReference.IsReady:
Logln("Transliterator is not available on this environment.  Skipping doTestIDNToASCII.")
        return
    var inBuf: StringBuffer = StringBuffer(src)
    var inIter: UCharacterIterator = UCharacterIterator.GetInstance(src)
    try:
        var @out: StringBuffer = IDNAReference.ConvertIDNToASCII(src, options)
        if expected != nil && @out != nil && !@out.ToString.Equals(expected):
Errln("convertToIDNAReferenceASCII did not return expected result with options : " + options + " Expected: " + expected + " Got: " + @out)
        if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("convertToIDNAReferenceASCII did not get the expected exception. The operation succeeded!")
    except StringPrepFormatException:
        if expectedException == nil || !ex.Equals(expectedException):
Errln("convertToIDNAReferenceASCII did not get the expected exception for source: " + src + " Got:  " + ex.ToString)
    try:
        var @out: StringBuffer = IDNAReference.ConvertIDNtoASCII(inBuf, options)
        if expected != nil && @out != nil && !@out.ToString.Equals(expected):
Errln("convertToIDNAReferenceASCII did not return expected result with options : " + options + " Expected: " + expected + " Got: " + @out)
        if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("convertToIDNAReferenceSCII did not get the expected exception. The operation succeeded!")
    except StringPrepFormatException:
        if expectedException == nil || !ex.Equals(expectedException):
Errln("convertToIDNAReferenceSCII did not get the expected exception for source: " + src + " Got:  " + ex.ToString)
    try:
        var @out: StringBuffer = IDNAReference.ConvertIDNtoASCII(inIter, options)
        if expected != nil && @out != nil && !@out.ToString.Equals(expected):
Errln("convertIDNToASCII did not return expected result with options : " + options + " Expected: " + expected + " Got: " + @out)
        if expectedException != nil && !unassignedException.Equals(expectedException):
Errln("convertIDNToASCII did not get the expected exception. The operation succeeded!")
    except StringPrepFormatException:
        if expectedException == nil || !ex.Equals(expectedException):
Errln("convertIDNToASCII did not get the expected exception for source: " + src + " Got:  " + ex.ToString)
proc TestConformance*() =
    try:
          var i: int = 0
          while i < TestData.conformanceTestCases.Length:
              var testCase: TestData.ConformanceTestCase = TestData.conformanceTestCases[i]
              if testCase.expected != nil:
DoTestToASCII(testCase.input, testCase.output, IDNAReference.DEFAULT, testCase.expected)
DoTestToASCII(testCase.input, testCase.output, IDNAReference.ALLOW_UNASSIGNED, testCase.expected)
++i
    except TypeInitializationException:
Warnln("Could not load NamePrepTransform data")
    except TypeLoadException:
Warnln("Could not load NamePrepTransform data")
proc TestNamePrepConformance*() =
    try:
        var namePrep: NamePrepTransform = NamePrepTransform.GetInstance
        if !namePrep.IsReady:
Logln("Transliterator is not available on this environment.")
            return
          var i: int = 0
          while i < TestData.conformanceTestCases.Length:
              var testCase: TestData.ConformanceTestCase = TestData.conformanceTestCases[i]
              var iter: UCharacterIterator = UCharacterIterator.GetInstance(testCase.input)
              try:
                  var output: StringBuffer = namePrep.Prepare(iter, NamePrepTransform.NONE)
                  if testCase.output != nil && output != nil && !testCase.output.Equals(output.ToString):
Errln("Did not get the expected output. Expected: " + Prettify(testCase.output) + " Got: " + Prettify(output))
                  if testCase.expected != nil && !unassignedException.Equals(testCase.expected):
Errln("Did not get the expected exception. The operation succeeded!")
              except StringPrepFormatException:
                  if testCase.expected == nil || !ex.Equals(testCase.expected):
Errln("Did not get the expected exception for source: " + testCase.input + " Got:  " + ex.ToString)
              try:
iter.SetToStart
                  var output: StringBuffer = namePrep.Prepare(iter, NamePrepTransform.ALLOW_UNASSIGNED)
                  if testCase.output != nil && output != nil && !testCase.output.Equals(output.ToString):
Errln("Did not get the expected output. Expected: " + Prettify(testCase.output) + " Got: " + Prettify(output))
                  if testCase.expected != nil && !unassignedException.Equals(testCase.expected):
Errln("Did not get the expected exception. The operation succeeded!")
              except StringPrepFormatException:
                  if testCase.expected == nil || !ex.Equals(testCase.expected):
Errln("Did not get the expected exception for source: " + testCase.input + " Got:  " + ex.ToString)
++i
    except TypeInitializationException:
Warnln("Could not load NamePrepTransformData")
    except TypeLoadException:
Warnln("Could not load NamePrepTransform data")
proc TestErrorCases*() =
    try:
          var i: int = 0
          while i < TestData.errorCases.Length:
              var errCase: TestData.ErrorCase = TestData.errorCases[i]
              if errCase.testLabel == true:
DoTestToASCII(String(errCase.unicode), errCase.ascii, IDNAReference.DEFAULT, errCase.expected)
DoTestToASCII(String(errCase.unicode), errCase.ascii, IDNAReference.ALLOW_UNASSIGNED, errCase.expected)
                  if errCase.useSTD3ASCIIRules:
DoTestToASCII(String(errCase.unicode), errCase.ascii, IDNAReference.USE_STD3_RULES, errCase.expected)
              if errCase.useSTD3ASCIIRules != true:
DoTestIDNToASCII(String(errCase.unicode), errCase.ascii, IDNAReference.DEFAULT, errCase.expected)
DoTestIDNToASCII(String(errCase.unicode), errCase.ascii, IDNAReference.ALLOW_UNASSIGNED, errCase.expected)
              else:
DoTestIDNToASCII(String(errCase.unicode), errCase.ascii, IDNAReference.USE_STD3_RULES, errCase.expected)
              if errCase.testToUnicode == true:
                  if errCase.useSTD3ASCIIRules != true:
DoTestIDNToUnicode(errCase.ascii, String(errCase.unicode), IDNAReference.DEFAULT, errCase.expected)
DoTestIDNToUnicode(errCase.ascii, String(errCase.unicode), IDNAReference.ALLOW_UNASSIGNED, errCase.expected)
                  else:
DoTestIDNToUnicode(errCase.ascii, String(errCase.unicode), IDNAReference.USE_STD3_RULES, errCase.expected)
++i
    except TypeInitializationException:
Warnln("Could not load NamePrepTransform data")
    except TypeLoadException:
Warnln("Could not load NamePrepTransform data")
proc DoTestCompare(s1: String, s2: String, isEqual: bool) =
    if !IDNAReference.IsReady:
Logln("Transliterator is not available on this environment.  Skipping doTestCompare.")
        return
    try:
        var retVal: int = IDNAReference.Compare(s1, s2, IDNA2003Options.Default)
        if isEqual == true && retVal != 0:
Errln("Did not get the expected result for s1: " + Prettify(s1) + " s2: " + Prettify(s2))
        retVal = IDNAReference.Compare(StringBuffer(s1), StringBuffer(s2), IDNA2003Options.Default)
        if isEqual == true && retVal != 0:
Errln("Did not get the expected result for s1: " + Prettify(s1) + " s2: " + Prettify(s2))
        retVal = IDNAReference.Compare(UCharacterIterator.GetInstance(s1), UCharacterIterator.GetInstance(s2), IDNA2003Options.Default)
        if isEqual == true && retVal != 0:
Errln("Did not get the expected result for s1: " + Prettify(s1) + " s2: " + Prettify(s2))
    except Exception:
e.PrintStackTrace
Errln("Unexpected exception thrown by IDNAReference.compare")
    try:
        var retVal: int = IDNAReference.Compare(s1, s2, IDNA2003Options.AllowUnassigned)
        if isEqual == true && retVal != 0:
Errln("Did not get the expected result for s1: " + Prettify(s1) + " s2: " + Prettify(s2))
        retVal = IDNAReference.Compare(StringBuffer(s1), StringBuffer(s2), IDNA2003Options.AllowUnassigned)
        if isEqual == true && retVal != 0:
Errln("Did not get the expected result for s1: " + Prettify(s1) + " s2: " + Prettify(s2))
        retVal = IDNAReference.Compare(UCharacterIterator.GetInstance(s1), UCharacterIterator.GetInstance(s2), IDNA2003Options.AllowUnassigned)
        if isEqual == true && retVal != 0:
Errln("Did not get the expected result for s1: " + Prettify(s1) + " s2: " + Prettify(s2))
    except Exception:
Errln("Unexpected exception thrown by IDNAReference.compare")
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
    try:
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
    except TypeInitializationException:
Warnln("Could not load NamePrepTransform data")
    except TypeLoadException:
Warnln("Could not load NamePrepTransform data")
proc DoTestChainingToASCII(source: String) =
    if !IDNAReference.IsReady:
Logln("Transliterator is not available on this environment.  Skipping doTestChainingToASCII.")
        return
    var expected: StringBuffer
    var chained: StringBuffer
    expected = IDNAReference.ConvertIDNToASCII(source, IDNAReference.DEFAULT)
    chained = expected
      var i: int = 0
      while i < 4:
          chained = IDNAReference.ConvertIDNtoASCII(chained, IDNAReference.DEFAULT)
++i
    if !expected.ToString.Equals(chained.ToString):
Errln("Chaining test failed for convertIDNToASCII")
    expected = IDNAReference.ConvertToASCII(source, IDNAReference.DEFAULT)
    chained = expected
      var i: int = 0
      while i < 4:
          chained = IDNAReference.ConvertToASCII(chained, IDNAReference.DEFAULT)
++i
    if !expected.ToString.Equals(chained.ToString):
Errln("Chaining test failed for convertToASCII")
proc DoTestChainingToUnicode*(source: String) =
    if !IDNAReference.IsReady:
Logln("Transliterator is not available on this environment.  Skipping doTestChainingToUnicode.")
        return
    var expected: StringBuffer
    var chained: StringBuffer
    expected = IDNAReference.ConvertIDNToUnicode(source, IDNAReference.DEFAULT)
    chained = expected
      var i: int = 0
      while i < 4:
          chained = IDNAReference.ConvertIDNToUnicode(chained, IDNAReference.DEFAULT)
++i
    if !expected.ToString.Equals(chained.ToString):
Errln("Chaining test failed for convertIDNToUnicode")
    expected = IDNAReference.ConvertToUnicode(source, IDNAReference.DEFAULT)
    chained = expected
      var i: int = 0
      while i < 4:
          chained = IDNAReference.ConvertToUnicode(chained, IDNAReference.DEFAULT)
++i
    if !expected.ToString.Equals(chained.ToString):
Errln("Chaining test failed for convertToUnicode")
proc TestChaining*() =
    try:
          var i: int = 0
          while i < TestData.unicodeIn.Length:
DoTestChainingToASCII(String(TestData.unicodeIn[i]))
++i
          var i: int = 0
          while i < TestData.asciiIn.Length:
DoTestChainingToUnicode(TestData.asciiIn[i])
++i
    except TypeInitializationException:
Warnln("Could not load NamePrepTransform data")
    except TypeLoadException:
Warnln("Could not load NamePrepTransform data")
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
    try:
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
    except TypeInitializationException:
Warnln("Could not load NamePrepTransform data")
    except TypeLoadException:
Warnln("Could not load NamePrepTransform data")