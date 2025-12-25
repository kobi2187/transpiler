# "Namespace: ICU4N.Dev.Test.Util"
type
  SimpleFormatterTest = ref object


proc newSimpleFormatterTest(): SimpleFormatterTest =

proc TestWithNoArguments*() =
    var fmt: SimpleFormatter = SimpleFormatter.Compile("This doesn''t have templates '{0}")
    var buffer: Span<char> = newSeq[char](64)
assertEquals("getArgumentLimit", 0, fmt.ArgumentLimit)
assertEquals("format", "This doesn't have templates {0}", fmt.Format("unused"))
assertEquals("format", "This doesn't have templates {0}",     if fmt.TryFormat(buffer,     var charsLength: int, "unused"):
buffer.Slice(0, charsLength).ToString
    else:
string.Empty)
assertEquals("format with values=null", "This doesn't have templates {0}", fmt.Format(cast[string[]](nil)))
assertEquals("format with values=null", "This doesn't have templates {0}",     if fmt.TryFormat(buffer, charsLength, cast[string[]](nil)):
buffer.Slice(0, charsLength).ToString
    else:
string.Empty)
assertEquals("toString", "This doesn't have templates {0}", fmt.ToString)
    var offsets: int[] = seq[int]
assertEquals("formatAndAppend", "This doesn't have templates {0}", fmt.FormatAndAppend(StringBuilder, offsets).ToString)
assertEquals("offsets[0]", -1, offsets[0])
assertEquals("formatAndAppend with values=null", "This doesn't have templates {0}", fmt.FormatAndAppend(StringBuilder, nil, cast[string[]](nil)).ToString)
assertEquals("formatAndReplace with values=null", "This doesn't have templates {0}", fmt.FormatAndReplace(StringBuilder, nil, cast[string[]](nil)).ToString)
proc TestSyntaxErrors*() =
    try:
SimpleFormatter.Compile("{}")
fail("Syntax error did not yield an exception.")
    except ArgumentException:

    try:
SimpleFormatter.Compile("{12d")
fail("Syntax error did not yield an exception.")
    except ArgumentException:

proc TestOneArgument*() =
    var expected: string = "1 meter"
    var fmt: SimpleFormatter = SimpleFormatter.Compile("{0} meter")
assertEquals("TestOneArgument Format", expected, fmt.Format("1"))
    var buffer: Span<char> = newSeq[char](32)
assertTrue("TestOneArgument TryFormat result", fmt.TryFormat(buffer,     var charsLength: int, "1"))
assertEquals("TestOneArgument TryFormat", expected, buffer.Slice(0, charsLength).ToString)
proc TestBigArgument*() =
    var fmt: SimpleFormatter = SimpleFormatter.Compile("a{20}c")
assertEquals("{20} count", 21, fmt.ArgumentLimit)
    var values: string[] = seq[string]
    values[20] = "b"
assertEquals("{20}=b", "abc", fmt.Format(values))
proc TestGetTextWithNoArguments*() =
    var fmt: SimpleFormatter = SimpleFormatter.Compile("Templates {1}{2} and {3} are here.")
    var expected: string = "Templates  and  are here."
assertEquals("", expected, fmt.GetTextWithNoArguments)
    var buffer: Span<char> = newSeq[char](40)
assertTrue("", fmt.TryGetTextWithNoArguments(buffer,     var charsLength: int))
assertEquals("", expected, buffer.Slice(0, charsLength).ToString)
proc TestTooFewArgumentValues*() =
    var fmt: SimpleFormatter = SimpleFormatter.Compile("Templates {2}{1} and {4} are out of order.")
    var buffer: Span<char> = newSeq[char](64)
    try:
fmt.Format("freddy", "tommy", "frog", "leg")
fail("Expected IllegalArgumentException")
    except ArgumentException:

    try:
fmt.TryFormat(buffer,         var charsLength: int, "freddy", "tommy", "frog", "leg")
fail("Expected IllegalArgumentException")
    except ArgumentException:

    try:
fmt.FormatAndAppend(StringBuilder, nil, "freddy", "tommy", "frog", "leg")
fail("Expected IllegalArgumentException")
    except ArgumentException:

    try:
fmt.FormatAndReplace(StringBuilder, nil, "freddy", "tommy", "frog", "leg")
fail("Expected IllegalArgumentException")
    except ArgumentException:

proc TestWithArguments*() =
    var fmt: SimpleFormatter = SimpleFormatter.Compile("Templates {2}{1} and {4} are out of order.")
assertEquals("getArgumentLimit", 5, fmt.ArgumentLimit)
assertEquals("toString", "Templates {2}{1} and {4} are out of order.", fmt.ToString)
    var offsets: int[] = seq[int]
assertEquals("format", "123456: Templates frogtommy and {0} are out of order.", fmt.FormatAndAppend(StringBuilder("123456: "), offsets, "freddy", "tommy", "frog", "leg", "{0}").ToString)
    var expectedOffsets: int[] = @[-1, 22, 18, -1, 32, -1]
verifyOffsets(expectedOffsets, offsets)
proc TestFormatUseAppendToAsArgument*() =
    var fmt: SimpleFormatter = SimpleFormatter.Compile("Arguments {0} and {1}")
    var appendTo: Span<char> = newSeq[char](32)
"previous:".AsSpan.CopyTo(appendTo)
    try:
fmt.TryFormat(appendTo,         var charsLength: int, appendTo, "frog".AsSpan)
fail("IllegalArgumentException expected.")
    except ArgumentException:

proc TestFormatReplaceNoOptimization*() =
    var fmt: SimpleFormatter = SimpleFormatter.Compile("{2}, {0}, {1} and {3}")
    var offsets: int[] = seq[int]
    var result: StringBuilder = StringBuilder("original")
assertEquals("format", "frog, original, freddy and by", fmt.FormatAndReplace(result, offsets, result.ToString, "freddy", "frog", "by").ToString)
    var expectedOffsets: int[] = @[6, 16, 0, 27]
verifyOffsets(expectedOffsets, offsets)
proc TestFormatReplaceNoOptimizationLeadingText*() =
    var fmt: SimpleFormatter = SimpleFormatter.Compile("boo {2}, {0}, {1} and {3}")
    var offsets: int[] = seq[int]
    var result: StringBuilder = StringBuilder("original")
assertEquals("format", "boo original, freddy, frog and by", fmt.FormatAndReplace(result, offsets, "freddy", "frog", result.ToString, "by").ToString)
    var expectedOffsets: int[] = @[14, 22, 4, 31]
verifyOffsets(expectedOffsets, offsets)
proc TestFormatReplaceOptimization*() =
    var fmt: SimpleFormatter = SimpleFormatter.Compile("{2}, {0}, {1} and {3}")
    var offsets: int[] = seq[int]
    var result: StringBuilder = StringBuilder("original")
assertEquals("format", "original, freddy, frog and by", fmt.FormatAndReplace(result, offsets, "freddy", "frog", result.ToString, "by").ToString)
    var expectedOffsets: int[] = @[10, 18, 0, 27]
verifyOffsets(expectedOffsets, offsets)
proc TestFormatReplaceOptimizationNoOffsets*() =
    var fmt: SimpleFormatter = SimpleFormatter.Compile("{2}, {0}, {1} and {3}")
    var result: StringBuilder = StringBuilder("original")
assertEquals("format", "original, freddy, frog and by", fmt.FormatAndReplace(result, nil, "freddy", "frog", result.ToString, "by").ToString)
proc TestFormatReplaceNoOptimizationNoOffsets*() =
    var fmt: SimpleFormatter = SimpleFormatter.Compile("Arguments {0} and {1}")
    var result: StringBuilder = StringBuilder("previous:")
assertEquals("", "Arguments previous: and frog", fmt.FormatAndReplace(result, nil, result.ToString, "frog").ToString)
proc TestFormatReplaceNoOptimizationLeadingArgumentUsedTwice*() =
    var fmt: SimpleFormatter = SimpleFormatter.Compile("{2}, {0}, {1} and {3} {2}")
    var result: StringBuilder = StringBuilder("original")
    var offsets: int[] = seq[int]
assertEquals("", "original, freddy, frog and by original", fmt.FormatAndReplace(result, offsets, "freddy", "frog", result.ToString, "by").ToString)
    var expectedOffsets: int[] = @[10, 18, 30, 27]
verifyOffsets(expectedOffsets, offsets)
proc TestQuotingLikeMessageFormat*() =
    var pattern: string = "{0} don't can''t '{5}''}{a' again '}'{1} to the '{end"
    var spf: SimpleFormatter = SimpleFormatter.Compile(pattern)
    var mf: MessageFormat = MessageFormat(pattern, UCultureInfo.InvariantCulture)
    var expected: String = "X don't can't {5}'}{a again }Y to the {end"
assertEquals("MessageFormat", expected, mf.Format(@["X", "Y"]))
assertEquals("SimpleFormatter", expected, spf.Format("X", "Y"))
proc verifyOffsets(expected: seq[int], actual: seq[int]) =
      var i: int = 0
      while i < expected.Length:
          if expected[i] != actual[i]:
Errln("Expected " + expected[i] + ", got " + actual[i])
++i