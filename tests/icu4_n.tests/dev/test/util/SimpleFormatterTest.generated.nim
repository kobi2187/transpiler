# "Namespace: ICU4N.Dev.Test.Util"
type
  SimpleFormatterTest = ref object


proc TestFormatRawPattern_OneArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first"
    var pattern: ReadOnlySpan<char> = "The result is: {0}".AsSpan
    var actual: string = SimpleFormatterImpl.FormatRawPattern(pattern, 0, int.MaxValue, "first".AsSpan)
assertEquals("TestFormatRawPattern_OneArguments_ReadOnlySpan", expected, actual)
proc TestFormatRawPattern_TwoArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}".AsSpan
    var actual: string = SimpleFormatterImpl.FormatRawPattern(pattern, 0, int.MaxValue, "first".AsSpan, "second".AsSpan)
assertEquals("TestFormatRawPattern_TwoArguments_ReadOnlySpan", expected, actual)
proc TestFormatRawPattern_ThreeArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}".AsSpan
    var actual: string = SimpleFormatterImpl.FormatRawPattern(pattern, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan)
assertEquals("TestFormatRawPattern_ThreeArguments_ReadOnlySpan", expected, actual)
proc TestFormatRawPattern_FourArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}".AsSpan
    var actual: string = SimpleFormatterImpl.FormatRawPattern(pattern, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan)
assertEquals("TestFormatRawPattern_FourArguments_ReadOnlySpan", expected, actual)
proc TestFormatRawPattern_FiveArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}".AsSpan
    var actual: string = SimpleFormatterImpl.FormatRawPattern(pattern, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan)
assertEquals("TestFormatRawPattern_FiveArguments_ReadOnlySpan", expected, actual)
proc TestFormatRawPattern_SixArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}".AsSpan
    var actual: string = SimpleFormatterImpl.FormatRawPattern(pattern, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan)
assertEquals("TestFormatRawPattern_SixArguments_ReadOnlySpan", expected, actual)
proc TestFormatRawPattern_SevenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}".AsSpan
    var actual: string = SimpleFormatterImpl.FormatRawPattern(pattern, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan)
assertEquals("TestFormatRawPattern_SevenArguments_ReadOnlySpan", expected, actual)
proc TestFormatRawPattern_EightArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}".AsSpan
    var actual: string = SimpleFormatterImpl.FormatRawPattern(pattern, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan)
assertEquals("TestFormatRawPattern_EightArguments_ReadOnlySpan", expected, actual)
proc TestFormatRawPattern_NineArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}".AsSpan
    var actual: string = SimpleFormatterImpl.FormatRawPattern(pattern, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan)
assertEquals("TestFormatRawPattern_NineArguments_ReadOnlySpan", expected, actual)
proc TestFormatRawPattern_TenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}".AsSpan
    var actual: string = SimpleFormatterImpl.FormatRawPattern(pattern, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan)
assertEquals("TestFormatRawPattern_TenArguments_ReadOnlySpan", expected, actual)
proc TestFormatRawPattern_ElevenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}".AsSpan
    var actual: string = SimpleFormatterImpl.FormatRawPattern(pattern, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan)
assertEquals("TestFormatRawPattern_ElevenArguments_ReadOnlySpan", expected, actual)
proc TestFormatRawPattern_TwelveArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}".AsSpan
    var actual: string = SimpleFormatterImpl.FormatRawPattern(pattern, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan)
assertEquals("TestFormatRawPattern_TwelveArguments_ReadOnlySpan", expected, actual)
proc TestFormatRawPattern_ThirteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}".AsSpan
    var actual: string = SimpleFormatterImpl.FormatRawPattern(pattern, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan)
assertEquals("TestFormatRawPattern_ThirteenArguments_ReadOnlySpan", expected, actual)
proc TestFormatRawPattern_FourteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}".AsSpan
    var actual: string = SimpleFormatterImpl.FormatRawPattern(pattern, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan)
assertEquals("TestFormatRawPattern_FourteenArguments_ReadOnlySpan", expected, actual)
proc TestFormatRawPattern_FifteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth, fifteenth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}".AsSpan
    var actual: string = SimpleFormatterImpl.FormatRawPattern(pattern, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan, "fifteenth".AsSpan)
assertEquals("TestFormatRawPattern_FifteenArguments_ReadOnlySpan", expected, actual)
proc TestFormatRawPattern_SixteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth, fifteenth, sixteenth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}".AsSpan
    var actual: string = SimpleFormatterImpl.FormatRawPattern(pattern, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan, "fifteenth".AsSpan, "sixteenth".AsSpan)
assertEquals("TestFormatRawPattern_SixteenArguments_ReadOnlySpan", expected, actual)
proc TestTryFormatRawPattern_OneArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first"
    var pattern: ReadOnlySpan<char> = "The result is: {0}".AsSpan
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatRawPattern(pattern, actual,     var charsLength: int, 0, int.MaxValue, "first".AsSpan))
assertEquals("TestTryFormatRawPattern_OneArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatRawPattern_TwoArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}".AsSpan
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatRawPattern(pattern, actual,     var charsLength: int, 0, int.MaxValue, "first".AsSpan, "second".AsSpan))
assertEquals("TestTryFormatRawPattern_TwoArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatRawPattern_ThreeArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}".AsSpan
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatRawPattern(pattern, actual,     var charsLength: int, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan))
assertEquals("TestTryFormatRawPattern_ThreeArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatRawPattern_FourArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}".AsSpan
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatRawPattern(pattern, actual,     var charsLength: int, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan))
assertEquals("TestTryFormatRawPattern_FourArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatRawPattern_FiveArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}".AsSpan
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatRawPattern(pattern, actual,     var charsLength: int, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan))
assertEquals("TestTryFormatRawPattern_FiveArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatRawPattern_SixArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}".AsSpan
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatRawPattern(pattern, actual,     var charsLength: int, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan))
assertEquals("TestTryFormatRawPattern_SixArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatRawPattern_SevenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}".AsSpan
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatRawPattern(pattern, actual,     var charsLength: int, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan))
assertEquals("TestTryFormatRawPattern_SevenArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatRawPattern_EightArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}".AsSpan
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatRawPattern(pattern, actual,     var charsLength: int, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan))
assertEquals("TestTryFormatRawPattern_EightArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatRawPattern_NineArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}".AsSpan
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatRawPattern(pattern, actual,     var charsLength: int, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan))
assertEquals("TestTryFormatRawPattern_NineArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatRawPattern_TenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}".AsSpan
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatRawPattern(pattern, actual,     var charsLength: int, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan))
assertEquals("TestTryFormatRawPattern_TenArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatRawPattern_ElevenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}".AsSpan
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatRawPattern(pattern, actual,     var charsLength: int, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan))
assertEquals("TestTryFormatRawPattern_ElevenArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatRawPattern_TwelveArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}".AsSpan
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatRawPattern(pattern, actual,     var charsLength: int, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan))
assertEquals("TestTryFormatRawPattern_TwelveArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatRawPattern_ThirteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}".AsSpan
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatRawPattern(pattern, actual,     var charsLength: int, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan))
assertEquals("TestTryFormatRawPattern_ThirteenArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatRawPattern_FourteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}".AsSpan
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatRawPattern(pattern, actual,     var charsLength: int, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan))
assertEquals("TestTryFormatRawPattern_FourteenArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatRawPattern_FifteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth, fifteenth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}".AsSpan
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatRawPattern(pattern, actual,     var charsLength: int, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan, "fifteenth".AsSpan))
assertEquals("TestTryFormatRawPattern_FifteenArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatRawPattern_SixteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth, fifteenth, sixteenth"
    var pattern: ReadOnlySpan<char> = "The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}".AsSpan
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatRawPattern(pattern, actual,     var charsLength: int, 0, int.MaxValue, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan, "fifteenth".AsSpan, "sixteenth".AsSpan))
assertEquals("TestTryFormatRawPattern_SixteenArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestFormatCompiledPattern_OneArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first"
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}".AsSpan, 0, int.MaxValue)
    var actual: string = SimpleFormatterImpl.FormatCompiledPattern(pattern.AsSpan, "first".AsSpan)
assertEquals("TestFormatCompiledPattern_OneArguments_ReadOnlySpan", expected, actual)
proc TestFormatCompiledPattern_TwoArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second"
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}".AsSpan, 0, int.MaxValue)
    var actual: string = SimpleFormatterImpl.FormatCompiledPattern(pattern.AsSpan, "first".AsSpan, "second".AsSpan)
assertEquals("TestFormatCompiledPattern_TwoArguments_ReadOnlySpan", expected, actual)
proc TestFormatCompiledPattern_ThreeArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third"
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}".AsSpan, 0, int.MaxValue)
    var actual: string = SimpleFormatterImpl.FormatCompiledPattern(pattern.AsSpan, "first".AsSpan, "second".AsSpan, "third".AsSpan)
assertEquals("TestFormatCompiledPattern_ThreeArguments_ReadOnlySpan", expected, actual)
proc TestFormatCompiledPattern_FourArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth"
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}".AsSpan, 0, int.MaxValue)
    var actual: string = SimpleFormatterImpl.FormatCompiledPattern(pattern.AsSpan, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan)
assertEquals("TestFormatCompiledPattern_FourArguments_ReadOnlySpan", expected, actual)
proc TestFormatCompiledPattern_FiveArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth"
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}".AsSpan, 0, int.MaxValue)
    var actual: string = SimpleFormatterImpl.FormatCompiledPattern(pattern.AsSpan, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan)
assertEquals("TestFormatCompiledPattern_FiveArguments_ReadOnlySpan", expected, actual)
proc TestFormatCompiledPattern_SixArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth"
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}".AsSpan, 0, int.MaxValue)
    var actual: string = SimpleFormatterImpl.FormatCompiledPattern(pattern.AsSpan, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan)
assertEquals("TestFormatCompiledPattern_SixArguments_ReadOnlySpan", expected, actual)
proc TestFormatCompiledPattern_SevenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh"
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}".AsSpan, 0, int.MaxValue)
    var actual: string = SimpleFormatterImpl.FormatCompiledPattern(pattern.AsSpan, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan)
assertEquals("TestFormatCompiledPattern_SevenArguments_ReadOnlySpan", expected, actual)
proc TestFormatCompiledPattern_EightArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth"
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}".AsSpan, 0, int.MaxValue)
    var actual: string = SimpleFormatterImpl.FormatCompiledPattern(pattern.AsSpan, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan)
assertEquals("TestFormatCompiledPattern_EightArguments_ReadOnlySpan", expected, actual)
proc TestFormatCompiledPattern_NineArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth"
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}".AsSpan, 0, int.MaxValue)
    var actual: string = SimpleFormatterImpl.FormatCompiledPattern(pattern.AsSpan, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan)
assertEquals("TestFormatCompiledPattern_NineArguments_ReadOnlySpan", expected, actual)
proc TestFormatCompiledPattern_TenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth"
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}".AsSpan, 0, int.MaxValue)
    var actual: string = SimpleFormatterImpl.FormatCompiledPattern(pattern.AsSpan, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan)
assertEquals("TestFormatCompiledPattern_TenArguments_ReadOnlySpan", expected, actual)
proc TestFormatCompiledPattern_ElevenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh"
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}".AsSpan, 0, int.MaxValue)
    var actual: string = SimpleFormatterImpl.FormatCompiledPattern(pattern.AsSpan, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan)
assertEquals("TestFormatCompiledPattern_ElevenArguments_ReadOnlySpan", expected, actual)
proc TestFormatCompiledPattern_TwelveArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth"
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}".AsSpan, 0, int.MaxValue)
    var actual: string = SimpleFormatterImpl.FormatCompiledPattern(pattern.AsSpan, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan)
assertEquals("TestFormatCompiledPattern_TwelveArguments_ReadOnlySpan", expected, actual)
proc TestFormatCompiledPattern_ThirteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth"
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}".AsSpan, 0, int.MaxValue)
    var actual: string = SimpleFormatterImpl.FormatCompiledPattern(pattern.AsSpan, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan)
assertEquals("TestFormatCompiledPattern_ThirteenArguments_ReadOnlySpan", expected, actual)
proc TestFormatCompiledPattern_FourteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth"
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}".AsSpan, 0, int.MaxValue)
    var actual: string = SimpleFormatterImpl.FormatCompiledPattern(pattern.AsSpan, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan)
assertEquals("TestFormatCompiledPattern_FourteenArguments_ReadOnlySpan", expected, actual)
proc TestFormatCompiledPattern_FifteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth, fifteenth"
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}".AsSpan, 0, int.MaxValue)
    var actual: string = SimpleFormatterImpl.FormatCompiledPattern(pattern.AsSpan, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan, "fifteenth".AsSpan)
assertEquals("TestFormatCompiledPattern_FifteenArguments_ReadOnlySpan", expected, actual)
proc TestFormatCompiledPattern_SixteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth, fifteenth, sixteenth"
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}".AsSpan, 0, int.MaxValue)
    var actual: string = SimpleFormatterImpl.FormatCompiledPattern(pattern.AsSpan, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan, "fifteenth".AsSpan, "sixteenth".AsSpan)
assertEquals("TestFormatCompiledPattern_SixteenArguments_ReadOnlySpan", expected, actual)
proc TestTryFormatCompiledPattern_OneArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first"
    var compiledPattern: Span<char> = newSeq[char](128)
assertTrue("Compile pattern result was false", SimpleFormatterImpl.TryCompileToStringMinMaxArguments("The result is: {0}".AsSpan, compiledPattern,     var patternLength: int, 0, int.MaxValue))
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatCompiledPattern(compiledPattern.Slice(0, patternLength), actual,     var charsLength: int, "first".AsSpan))
assertEquals("TestTryFormatCompiledPattern_OneArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatCompiledPattern_TwoArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second"
    var compiledPattern: Span<char> = newSeq[char](128)
assertTrue("Compile pattern result was false", SimpleFormatterImpl.TryCompileToStringMinMaxArguments("The result is: {0}, {1}".AsSpan, compiledPattern,     var patternLength: int, 0, int.MaxValue))
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatCompiledPattern(compiledPattern.Slice(0, patternLength), actual,     var charsLength: int, "first".AsSpan, "second".AsSpan))
assertEquals("TestTryFormatCompiledPattern_TwoArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatCompiledPattern_ThreeArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third"
    var compiledPattern: Span<char> = newSeq[char](128)
assertTrue("Compile pattern result was false", SimpleFormatterImpl.TryCompileToStringMinMaxArguments("The result is: {0}, {1}, {2}".AsSpan, compiledPattern,     var patternLength: int, 0, int.MaxValue))
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatCompiledPattern(compiledPattern.Slice(0, patternLength), actual,     var charsLength: int, "first".AsSpan, "second".AsSpan, "third".AsSpan))
assertEquals("TestTryFormatCompiledPattern_ThreeArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatCompiledPattern_FourArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth"
    var compiledPattern: Span<char> = newSeq[char](128)
assertTrue("Compile pattern result was false", SimpleFormatterImpl.TryCompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}".AsSpan, compiledPattern,     var patternLength: int, 0, int.MaxValue))
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatCompiledPattern(compiledPattern.Slice(0, patternLength), actual,     var charsLength: int, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan))
assertEquals("TestTryFormatCompiledPattern_FourArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatCompiledPattern_FiveArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth"
    var compiledPattern: Span<char> = newSeq[char](128)
assertTrue("Compile pattern result was false", SimpleFormatterImpl.TryCompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}".AsSpan, compiledPattern,     var patternLength: int, 0, int.MaxValue))
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatCompiledPattern(compiledPattern.Slice(0, patternLength), actual,     var charsLength: int, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan))
assertEquals("TestTryFormatCompiledPattern_FiveArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatCompiledPattern_SixArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth"
    var compiledPattern: Span<char> = newSeq[char](128)
assertTrue("Compile pattern result was false", SimpleFormatterImpl.TryCompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}".AsSpan, compiledPattern,     var patternLength: int, 0, int.MaxValue))
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatCompiledPattern(compiledPattern.Slice(0, patternLength), actual,     var charsLength: int, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan))
assertEquals("TestTryFormatCompiledPattern_SixArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatCompiledPattern_SevenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh"
    var compiledPattern: Span<char> = newSeq[char](128)
assertTrue("Compile pattern result was false", SimpleFormatterImpl.TryCompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}".AsSpan, compiledPattern,     var patternLength: int, 0, int.MaxValue))
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatCompiledPattern(compiledPattern.Slice(0, patternLength), actual,     var charsLength: int, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan))
assertEquals("TestTryFormatCompiledPattern_SevenArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatCompiledPattern_EightArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth"
    var compiledPattern: Span<char> = newSeq[char](128)
assertTrue("Compile pattern result was false", SimpleFormatterImpl.TryCompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}".AsSpan, compiledPattern,     var patternLength: int, 0, int.MaxValue))
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatCompiledPattern(compiledPattern.Slice(0, patternLength), actual,     var charsLength: int, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan))
assertEquals("TestTryFormatCompiledPattern_EightArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatCompiledPattern_NineArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth"
    var compiledPattern: Span<char> = newSeq[char](128)
assertTrue("Compile pattern result was false", SimpleFormatterImpl.TryCompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}".AsSpan, compiledPattern,     var patternLength: int, 0, int.MaxValue))
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatCompiledPattern(compiledPattern.Slice(0, patternLength), actual,     var charsLength: int, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan))
assertEquals("TestTryFormatCompiledPattern_NineArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatCompiledPattern_TenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth"
    var compiledPattern: Span<char> = newSeq[char](128)
assertTrue("Compile pattern result was false", SimpleFormatterImpl.TryCompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}".AsSpan, compiledPattern,     var patternLength: int, 0, int.MaxValue))
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatCompiledPattern(compiledPattern.Slice(0, patternLength), actual,     var charsLength: int, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan))
assertEquals("TestTryFormatCompiledPattern_TenArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatCompiledPattern_ElevenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh"
    var compiledPattern: Span<char> = newSeq[char](128)
assertTrue("Compile pattern result was false", SimpleFormatterImpl.TryCompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}".AsSpan, compiledPattern,     var patternLength: int, 0, int.MaxValue))
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatCompiledPattern(compiledPattern.Slice(0, patternLength), actual,     var charsLength: int, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan))
assertEquals("TestTryFormatCompiledPattern_ElevenArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatCompiledPattern_TwelveArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth"
    var compiledPattern: Span<char> = newSeq[char](128)
assertTrue("Compile pattern result was false", SimpleFormatterImpl.TryCompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}".AsSpan, compiledPattern,     var patternLength: int, 0, int.MaxValue))
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatCompiledPattern(compiledPattern.Slice(0, patternLength), actual,     var charsLength: int, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan))
assertEquals("TestTryFormatCompiledPattern_TwelveArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatCompiledPattern_ThirteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth"
    var compiledPattern: Span<char> = newSeq[char](128)
assertTrue("Compile pattern result was false", SimpleFormatterImpl.TryCompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}".AsSpan, compiledPattern,     var patternLength: int, 0, int.MaxValue))
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatCompiledPattern(compiledPattern.Slice(0, patternLength), actual,     var charsLength: int, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan))
assertEquals("TestTryFormatCompiledPattern_ThirteenArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatCompiledPattern_FourteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth"
    var compiledPattern: Span<char> = newSeq[char](128)
assertTrue("Compile pattern result was false", SimpleFormatterImpl.TryCompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}".AsSpan, compiledPattern,     var patternLength: int, 0, int.MaxValue))
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatCompiledPattern(compiledPattern.Slice(0, patternLength), actual,     var charsLength: int, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan))
assertEquals("TestTryFormatCompiledPattern_FourteenArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatCompiledPattern_FifteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth, fifteenth"
    var compiledPattern: Span<char> = newSeq[char](128)
assertTrue("Compile pattern result was false", SimpleFormatterImpl.TryCompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}".AsSpan, compiledPattern,     var patternLength: int, 0, int.MaxValue))
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatCompiledPattern(compiledPattern.Slice(0, patternLength), actual,     var charsLength: int, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan, "fifteenth".AsSpan))
assertEquals("TestTryFormatCompiledPattern_FifteenArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestTryFormatCompiledPattern_SixteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth, fifteenth, sixteenth"
    var compiledPattern: Span<char> = newSeq[char](128)
assertTrue("Compile pattern result was false", SimpleFormatterImpl.TryCompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}".AsSpan, compiledPattern,     var patternLength: int, 0, int.MaxValue))
    var actual: Span<char> = newSeq[char](expected.Length)
assertTrue("Result was false", SimpleFormatterImpl.TryFormatCompiledPattern(compiledPattern.Slice(0, patternLength), actual,     var charsLength: int, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan, "fifteenth".AsSpan, "sixteenth".AsSpan))
assertEquals("TestTryFormatCompiledPattern_SixteenArguments_ReadOnlySpan", expected, actual.Slice(0, charsLength).ToString)
proc TestFormatAndAppend_OneArguments_ReadOnlySpan*() =
    var expected: string = "prefix|The result is: first"
    var expectedOffsets: int[] = @[22]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndAppend(pattern.AsSpan, sb, offsets, "first".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndAppend_OneArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndAppend_TwoArguments_ReadOnlySpan*() =
    var expected: string = "prefix|The result is: first, second"
    var expectedOffsets: int[] = @[22]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndAppend(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndAppend_TwoArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndAppend_ThreeArguments_ReadOnlySpan*() =
    var expected: string = "prefix|The result is: first, second, third"
    var expectedOffsets: int[] = @[22]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndAppend(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndAppend_ThreeArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndAppend_FourArguments_ReadOnlySpan*() =
    var expected: string = "prefix|The result is: first, second, third, fourth"
    var expectedOffsets: int[] = @[22]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndAppend(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndAppend_FourArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndAppend_FiveArguments_ReadOnlySpan*() =
    var expected: string = "prefix|The result is: first, second, third, fourth, fifth"
    var expectedOffsets: int[] = @[22]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndAppend(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndAppend_FiveArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndAppend_SixArguments_ReadOnlySpan*() =
    var expected: string = "prefix|The result is: first, second, third, fourth, fifth, sixth"
    var expectedOffsets: int[] = @[22]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndAppend(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndAppend_SixArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndAppend_SevenArguments_ReadOnlySpan*() =
    var expected: string = "prefix|The result is: first, second, third, fourth, fifth, sixth, seventh"
    var expectedOffsets: int[] = @[22]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndAppend(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndAppend_SevenArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndAppend_EightArguments_ReadOnlySpan*() =
    var expected: string = "prefix|The result is: first, second, third, fourth, fifth, sixth, seventh, eighth"
    var expectedOffsets: int[] = @[22]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndAppend(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndAppend_EightArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndAppend_NineArguments_ReadOnlySpan*() =
    var expected: string = "prefix|The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth"
    var expectedOffsets: int[] = @[22]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndAppend(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndAppend_NineArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndAppend_TenArguments_ReadOnlySpan*() =
    var expected: string = "prefix|The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth"
    var expectedOffsets: int[] = @[22]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndAppend(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndAppend_TenArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndAppend_ElevenArguments_ReadOnlySpan*() =
    var expected: string = "prefix|The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh"
    var expectedOffsets: int[] = @[22]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndAppend(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndAppend_ElevenArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndAppend_TwelveArguments_ReadOnlySpan*() =
    var expected: string = "prefix|The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth"
    var expectedOffsets: int[] = @[22]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndAppend(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndAppend_TwelveArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndAppend_ThirteenArguments_ReadOnlySpan*() =
    var expected: string = "prefix|The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth"
    var expectedOffsets: int[] = @[22]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndAppend(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndAppend_ThirteenArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndAppend_FourteenArguments_ReadOnlySpan*() =
    var expected: string = "prefix|The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth"
    var expectedOffsets: int[] = @[22]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndAppend(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndAppend_FourteenArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndAppend_FifteenArguments_ReadOnlySpan*() =
    var expected: string = "prefix|The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth, fifteenth"
    var expectedOffsets: int[] = @[22]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndAppend(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan, "fifteenth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndAppend_FifteenArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndAppend_SixteenArguments_ReadOnlySpan*() =
    var expected: string = "prefix|The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth, fifteenth, sixteenth"
    var expectedOffsets: int[] = @[22]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndAppend(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan, "fifteenth".AsSpan, "sixteenth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndAppend_SixteenArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndReplace_OneArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first"
    var expectedOffsets: int[] = @[15]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndReplace(pattern.AsSpan, sb, offsets, "first".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndReplace_OneArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndReplace_TwoArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second"
    var expectedOffsets: int[] = @[15]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndReplace(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndReplace_TwoArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndReplace_ThreeArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third"
    var expectedOffsets: int[] = @[15]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndReplace(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndReplace_ThreeArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndReplace_FourArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth"
    var expectedOffsets: int[] = @[15]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndReplace(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndReplace_FourArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndReplace_FiveArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth"
    var expectedOffsets: int[] = @[15]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndReplace(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndReplace_FiveArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndReplace_SixArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth"
    var expectedOffsets: int[] = @[15]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndReplace(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndReplace_SixArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndReplace_SevenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh"
    var expectedOffsets: int[] = @[15]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndReplace(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndReplace_SevenArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndReplace_EightArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth"
    var expectedOffsets: int[] = @[15]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndReplace(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndReplace_EightArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndReplace_NineArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth"
    var expectedOffsets: int[] = @[15]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndReplace(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndReplace_NineArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndReplace_TenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth"
    var expectedOffsets: int[] = @[15]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndReplace(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndReplace_TenArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndReplace_ElevenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh"
    var expectedOffsets: int[] = @[15]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndReplace(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndReplace_ElevenArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndReplace_TwelveArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth"
    var expectedOffsets: int[] = @[15]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndReplace(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndReplace_TwelveArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndReplace_ThirteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth"
    var expectedOffsets: int[] = @[15]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndReplace(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndReplace_ThirteenArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndReplace_FourteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth"
    var expectedOffsets: int[] = @[15]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndReplace(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndReplace_FourteenArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndReplace_FifteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth, fifteenth"
    var expectedOffsets: int[] = @[15]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndReplace(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan, "fifteenth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndReplace_FifteenArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)
proc TestFormatAndReplace_SixteenArguments_ReadOnlySpan*() =
    var expected: string = "The result is: first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth, eleventh, twelveth, thirteenth, fourteenth, fifteenth, sixteenth"
    var expectedOffsets: int[] = @[15]
    var pattern: string = SimpleFormatterImpl.CompileToStringMinMaxArguments("The result is: {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}".AsSpan, 0, int.MaxValue)
    var actual: string
    var offsets: int[] = seq[int]
    var sb: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
sb.Append("prefix|")
SimpleFormatterImpl.FormatAndReplace(pattern.AsSpan, sb, offsets, "first".AsSpan, "second".AsSpan, "third".AsSpan, "fourth".AsSpan, "fifth".AsSpan, "sixth".AsSpan, "seventh".AsSpan, "eighth".AsSpan, "ninth".AsSpan, "tenth".AsSpan, "eleventh".AsSpan, "twelveth".AsSpan, "thirteenth".AsSpan, "fourteenth".AsSpan, "fifteenth".AsSpan, "sixteenth".AsSpan)
        actual = sb.ToString
    finally:
sb.Dispose
assertEquals("TestFormatAndReplace_SixteenArguments_ReadOnlySpan", expected, actual)
assertEquals("Offsets", expectedOffsets, offsets)