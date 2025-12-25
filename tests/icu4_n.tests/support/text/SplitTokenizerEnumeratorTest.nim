# "Namespace: ICU4N.Text"
type
  SplitTokenizerEnumeratorTest = ref object


proc TestBasicSplitAndTrim*() =
    var text: ReadOnlySpan<char> = " A test ; to split ".AsSpan
    var target = text.AsTokens(";", " ")
assertTrue("Expected token not found", target.MoveNext)
assertTrue("'A test' not found", "A test".AsSpan.SequenceEqual(target.Current))
assertTrue("Expected token not found", target.MoveNext)
assertTrue("'to split' not found", "to split".AsSpan.SequenceEqual(target.Current))
assertFalse("Expected end of enumeration", target.MoveNext)
proc TestBasicSplitAndTrimStart*() =
    var text: ReadOnlySpan<char> = " A test ; to split ".AsSpan
    var target = text.AsTokens(";", " ", TrimBehavior.Start)
assertTrue("Expected token not found", target.MoveNext)
assertTrue("'A test' not found", "A test ".AsSpan.SequenceEqual(target.Current))
assertTrue("Expected token not found", target.MoveNext)
assertTrue("'to split' not found", "to split ".AsSpan.SequenceEqual(target.Current))
assertFalse("Expected end of enumeration", target.MoveNext)
proc TestBasicSplitAndTrimEnd*() =
    var text: ReadOnlySpan<char> = " A test ; to split ".AsSpan
    var target = text.AsTokens(";", " ", TrimBehavior.End)
assertTrue("Expected token not found", target.MoveNext)
assertTrue("'A test' not found", " A test".AsSpan.SequenceEqual(target.Current))
assertTrue("Expected token not found", target.MoveNext)
assertTrue("'to split' not found", " to split".AsSpan.SequenceEqual(target.Current))
assertFalse("Expected end of enumeration", target.MoveNext)
proc TestMultiLevelDelimiters*() =
    var text: string = " fooName: fooValue ; barName: barValue;" + Environment.NewLine + " bazName : " + Environment.NewLine + " bazValue | rule2Name: rule2Value"
    var rule1ElementsExpected: JCG.Dictionary<string, string> = JCG.Dictionary<string, string>
    var rule2ElementsExpected: JCG.Dictionary<string, string> = JCG.Dictionary<string, string>
    var rule1Elements: JCG.Dictionary<string, string> = JCG.Dictionary<string, string>
    var rule2Elements: JCG.Dictionary<string, string> = JCG.Dictionary<string, string>
    var ruleNumber: int = 0
    for rule in text.AsTokens('|', SplitTokenizerEnumerator.PatternWhiteSpace):
++ruleNumber
        for rule2 in rule.Text.AsTokens(';', SplitTokenizerEnumerator.PatternWhiteSpace):
              var name: string
              var value: string
            var iter = rule2.Text.AsTokens(':', SplitTokenizerEnumerator.PatternWhiteSpace)
assertTrue("missing name", iter.MoveNext)
            name = iter.Current.Text.ToString
assertTrue("missing value", iter.MoveNext)
            value = iter.Current.Text.ToString
            if ruleNumber == 1:
                rule1Elements[name] = value
            else:
                rule2Elements[name] = value
assertEquals("rule 1 rules mismatch", rule1ElementsExpected, rule1Elements)
assertEquals("rule 2 rules mismatch", rule2ElementsExpected, rule2Elements)
proc TestMultipleDelimiters*() =
    var text: string = " fooName= fooValue , barName= barValue!" + Environment.NewLine + " bazName = " + Environment.NewLine + " bazValue % rule2Name= rule2Value"
    var expectedTokens: string[] = @["fooName", "fooValue", "barName", "barValue", "bazName", "bazValue", "rule2Name", "rule2Value"]
    var expectedDelimiters: string[] = @["=", ",", "=", "!", "=", "%", "=", ""]
    var index: int = 0
    for token in text.AsTokens(@['=', ',', '!', '%'], SplitTokenizerEnumerator.PatternWhiteSpace):
        var actualToken: string = token.Text.ToString
        var expectedToken: string = expectedTokens[index]
assertEquals("mismatched token", actualToken, expectedToken)
        var actualDelimiter: string = token.Delimiter.ToString
        var expectedDelimiter: string = expectedDelimiters[index]
assertEquals("mismatched delimiter", actualDelimiter, expectedDelimiter)
++index