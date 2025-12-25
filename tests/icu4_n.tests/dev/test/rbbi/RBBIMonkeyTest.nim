# "Namespace: ICU4N.Dev.Test.Rbbi"
type
  RBBIMonkeyTest = ref object


type
  CharClass = ref object
    fName: String
    fOriginalDef: String
    fExpandedDef: String
    fSet: UnicodeSet

proc newCharClass(name: String, originalDef: String, expandedDef: String, set: UnicodeSet): CharClass =
  fName = name
  fOriginalDef = originalDef
  fExpandedDef = expandedDef
  fSet = set
type
  BreakRule = ref object
    fName: String
    fRule: String
    fExpandedRule: String
    fRuleMatcher: Regex

type
  BreakRules = ref object
    fMonkeyImpl: RBBIMonkeyImpl
    fBreakRules: List[BreakRule]
    fCharClasses: IDictionary[String, CharClass]
    fCharClassList: List[CharClass]
    fDictionarySet: UnicodeSet
    fLocale: UCultureInfo
    fType: int
    fSetRefsMatcher: Regex
    fCommentsMatcher: Regex
    fClassDefMatcher: Regex
    fRuleDefMatcher: Regex
    fPropertyMatcher: Regex

proc newBreakRules(monkeyImpl: RBBIMonkeyImpl): BreakRules =
  fMonkeyImpl = monkeyImpl
  fBreakRules = List<BreakRule>
  fType = BreakIterator.KIND_TITLE
  fCharClasses = Dictionary<String, CharClass>
  fCharClassList = List<CharClass>
  fDictionarySet = UnicodeSet
  fSetRefsMatcher = Regex("(?<!\{[ \t]{0,4})" + "(?<!=[ \t]{0,4})" + "(?<!\[:[ \t]{0,4})" + "(?<!\\)" + "(?<![A-Za-z0-9_])" + "([A-Za-z_][A-Za-z0-9_]*)", RegexOptions.Compiled)
  fCommentsMatcher = Regex("" + "(^|(?<=;))" + "(?:[ \t]*)+" + "(?:(#.*)?)+" + "$", RegexOptions.Compiled)
  fClassDefMatcher = Regex("" + "[ \t]*" + "([A-Za-z_][A-Za-z0-9_]*)" + "[ \t]*=[ \t]*" + "(.*?)" + "[ \t]*;$", RegexOptions.Compiled)
  fRuleDefMatcher = Regex("" + "[ \t]*" + "([A-Za-z_][A-Za-z0-9_.]*)" + "[ \t]*:[ \t]*" + "(.*?)" + "[ \t]*;$", RegexOptions.Compiled)
  fPropertyMatcher = Regex("" + "\[:.*?:]|\\(?:p|P)\{.*?\}", RegexOptions.Compiled)
proc AddCharClass(name: String, definition: String): CharClass =
    var expandedDef: StringBuffer = StringBuffer
    var match: Match = fSetRefsMatcher.Match(definition)
    var lastEnd: int = 0
    if match.Success:
        while true:
            var sname: string = match.Groups[1].Value
            var expansionForName: string =             if fCharClasses.TryGetValue(sname,             var snameClass: CharClass) && snameClass != nil:
snameClass.fExpandedDef
            else:
sname
expandedDef.Append(definition.Substring(lastEnd, match.Index - lastEnd))
expandedDef.Append(expansionForName)
            lastEnd = match.Index + match.Length
            if not            match = match.NextMatch.Success:
                break
expandedDef.Append(definition.Substring(lastEnd))
    var expandedDefString: String = expandedDef.ToString
    if fMonkeyImpl.fDumpExpansions:
Console.Out.Write("addCharClass("{0}"
", name)
Console.Out.Write("             {0}
", definition)
Console.Out.Write("expandedDef: {0}
", expandedDefString)
    var s: UnicodeSet
    try:
        s = UnicodeSet(expandedDefString, UnicodeSet.IgnoreSpace)
    except ArgumentException:
Console.Error.Write("{0}: error {1} creating UnicodeSet {2}", fMonkeyImpl.fRuleFileName, e.ToString, name)
        raise
    var expandedPattern: StringBuffer = StringBuffer
s.GeneratePattern(expandedPattern, true)
    expandedDefString = expandedPattern.ToString
    if fMonkeyImpl.fDumpExpansions:
Console.Out.Write("expandedDef2: {0}
", expandedDefString)
    var cclass: CharClass = CharClass(name, definition, expandedDefString, s)
    var previousClass: CharClass
fCharClasses.TryGetValue(name, previousClass)
    fCharClasses[name] = cclass
    if previousClass != nil:

    return cclass
proc AddRule(name: String, definition: String) =
    var thisRule: BreakRule = BreakRule
    var expandedDefsRule: StringBuffer = StringBuffer
    thisRule.fName = name
    thisRule.fRule = definition
    var match = fSetRefsMatcher.Match(definition)
    var lastEnd: int = 0
    if match.Success:
        while true:
            var sname: string = match.Groups[1].Value
            var nameClass: CharClass = fCharClasses[sname]
            if nameClass == nil:
Console.Error.Write("char class "{0}" unrecognized in rule "{1}"
", sname, definition)
            var expansionForName: string =             if nameClass != nil:
nameClass.fExpandedDef
            else:
sname
expandedDefsRule.Append(definition.Substring(lastEnd, match.Index - lastEnd))
expandedDefsRule.Append(expansionForName)
            lastEnd = match.Index + match.Length
            if not            match = match.NextMatch.Success:
                break
expandedDefsRule.Append(definition.Substring(lastEnd))
    var expandedRule: StringBuffer = StringBuffer
    var expandedDefsRuleString = expandedDefsRule.ToString
    match = fPropertyMatcher.Match(expandedDefsRuleString)
    lastEnd = 0
    if match.Success:
        while true:
            var prop: String = match.Value
            var propSet: UnicodeSet = UnicodeSet("[" + prop + "]")
            var propExpansion: StringBuffer = StringBuffer
propSet.GeneratePattern(propExpansion, true)
expandedRule.Append(expandedDefsRuleString.Substring(lastEnd, match.Index - lastEnd))
expandedRule.Append(propExpansion.ToString)
            lastEnd = match.Index + match.Length
            if not            match = match.NextMatch.Success:
                break
expandedRule.Append(expandedDefsRuleString.Substring(lastEnd))
    var ruleWithFlattenedSets: StringBuffer = StringBuffer
    var idx: int = 0
    while idx < expandedRule.Length:
        var setOpenPos: int = expandedRule.IndexOf("[^", idx, StringComparison.Ordinal)
        if setOpenPos < 0:
            break
        if setOpenPos > idx:
ruleWithFlattenedSets.Append(expandedRule.ToString(idx, setOpenPos - idx))
        var nestingLevel: int = 1
        var haveNesting: bool = false
        var setClosePos: int
          setClosePos = setOpenPos + 2
          while nestingLevel > 0 && setClosePos < expandedRule.Length:
              var c: char = expandedRule[setClosePos]
              if c == '\':
++setClosePos

              elif c == '[':
++nestingLevel
                  haveNesting = true
              else:
                if c == ']':
--nestingLevel
++setClosePos
        if haveNesting && nestingLevel == 0:
            var uset: UnicodeSet = UnicodeSet(expandedRule.ToString(setOpenPos, setClosePos - setOpenPos), true)
uset.GeneratePattern(ruleWithFlattenedSets, true)
        else:
            if nestingLevel > 0:
Console.Error.Write("No closing ] found in rule {0}
", name)
ruleWithFlattenedSets.Append(expandedRule.ToString(setOpenPos, setClosePos - setOpenPos))
        idx = setClosePos
    if idx < expandedRule.Length:
ruleWithFlattenedSets.Append(expandedRule.ToString(idx, expandedRule.Length - idx))
    thisRule.fExpandedRule = ruleWithFlattenedSets.ToString
    thisRule.fExpandedRule = thisRule.fExpandedRule.Replace("÷", "()")
    if thisRule.fExpandedRule.IndexOf('�') != -1:
        var msg: String = String.Format("{0} Rule {1} contains multiple ÷ signs", fMonkeyImpl.fRuleFileName, name)
Console.Error.WriteLine(msg)
        raise ArgumentException(msg)
    thisRule.fExpandedRule = thisRule.fExpandedRule.Replace("[]", "[a&&[^a]]")
    thisRule.fExpandedRule = thisRule.fExpandedRule.Replace("#", "\#")
    if fMonkeyImpl.fDumpExpansions:
Console.Out.Write("fExpandedRule: {0}
", thisRule.fExpandedRule)
    try:
        thisRule.fRuleMatcher = Utf32Regex("\A(?:" + thisRule.fExpandedRule + ")", RegexOptions.Compiled)
    except ArgumentException:
Console.Error.Write("{0}: Error creating regular expression for rule {1}. Expansion is 
"{2}"", fMonkeyImpl.fRuleFileName, name, thisRule.fExpandedRule)
        raise
fBreakRules.Add(thisRule)
proc SetKeywordParameter(keyword: String, value: String): bool =
    if keyword.Equals("locale"):
        fLocale = UCultureInfo(value)
        return true
    if keyword.Equals("type"):
        if value.Equals("grapheme"):
            fType = BreakIterator.KIND_CHARACTER

        elif value.Equals("word"):
            fType = BreakIterator.KIND_WORD
        else:
          if value.Equals("line"):
              fType = BreakIterator.KIND_LINE

          elif value.Equals("sentence"):
              fType = BreakIterator.KIND_SENTENCE
          else:
              var msg: String = String.Format("{0}: Unrecognized break type {1}", fMonkeyImpl.fRuleFileName, value)
Console.Error.WriteLine(msg)
              raise ArgumentException(msg)
        return true
    return false
proc CreateICUBreakIterator(): RuleBasedBreakIterator =
    var bi: BreakIterator
    case fType
    of BreakIterator.KIND_CHARACTER:
        bi = BreakIterator.GetCharacterInstance(fLocale)
        break
    of BreakIterator.KIND_WORD:
        bi = BreakIterator.GetWordInstance(fLocale)
        break
    of BreakIterator.KIND_LINE:
        bi = BreakIterator.GetLineInstance(fLocale)
        break
    of BreakIterator.KIND_SENTENCE:
        bi = BreakIterator.GetSentenceInstance(fLocale)
        break
    else:
        var msg: String = String.Format("{0}: Bad break iterator type of {1}", fMonkeyImpl.fRuleFileName, fType)
Console.Error.WriteLine(msg)
        raise ArgumentException(msg)
    return cast[RuleBasedBreakIterator](bi)
proc CompileRules(rules: String) =
    var lineNumber: int = 0
    for l in Regex.Split(rules, "\r?\n"):
        var line: string = l
++lineNumber
        line = fCommentsMatcher.Replace(line, "", 1)
        if line == string.Empty:
            continue
        var match: Match = fClassDefMatcher.Match(line)
        if match.Success && match.Length == line.Length:
            var className: string = match.Groups[1].Value
            var classDef: string = match.Groups[2].Value
            if fMonkeyImpl.fDumpExpansions:
Console.Out.Write("scanned class: {0} = {1}
", className, classDef)
            if SetKeywordParameter(className, classDef):
                continue
AddCharClass(className, classDef)
            continue
        match = fRuleDefMatcher.Match(line)
        if match.Success && match.Length == line.Length:
            var ruleName: string = match.Groups[1].Value
            var ruleDef: string = match.Groups[2].Value
            if fMonkeyImpl.fDumpExpansions:
Console.Out.Write("scanned rule: {0} : {1}
", ruleName, ruleDef)
AddRule(ruleName, ruleDef)
            continue
        var msg: string = string.Format("Unrecognized line in rule file {0}:{1} "{2}"", fMonkeyImpl.fRuleFileName, lineNumber, line)
Console.Error.WriteLine(msg)
        raise ArgumentException(msg)
    var otherSet: UnicodeSet = UnicodeSet(0, 1114111)
    for el in fCharClasses:
        var ccName: string = el.Key
        var cclass: CharClass = el.Value
        if !ccName.Equals(cclass.fName):
            raise ArgumentException(String.Format("{0}: internal error, set names ({1}, {2}) inconsistent.
", fMonkeyImpl.fRuleFileName, ccName, cclass.fName))
otherSet.RemoveAll(cclass.fSet)
        if ccName.Equals("dictionary"):
            fDictionarySet = cclass.fSet
        else:
fCharClassList.Add(cclass)
    if !otherSet.IsEmpty:
        var cclass: CharClass = AddCharClass("__Others", otherSet.ToPattern(true))
fCharClassList.Add(cclass)
proc GetClassForChar(c: int): CharClass =
    for cc in fCharClassList:
        if cc.fSet.Contains(c):
            return cc
    return nil
type
  MonkeyTestData = ref object
    fRandomSeed: int
    fBkRules: BreakRules
    fString: String
    fExpectedBreaks: seq[bool]
    fActualBreaks: seq[bool]
    fRuleForPosition: seq[int]
    f2ndRuleForPos: seq[int]

proc Set(rules: BreakRules, rand: ICU_Rand) =
    var dataLength: int = 1000
    fRandomSeed = rand.GetSeed
    fBkRules = rules
    var newString: StringBuilder = StringBuilder
      var n: int = 0
      while n < dataLength:
          var charClassIndex: int = rand.Next % rules.fCharClassList.Count
          var cclass: CharClass = rules.fCharClassList[charClassIndex]
          if cclass.fSet.Count == 0:
              continue
          var charIndex: int = rand.Next % cclass.fSet.Count
          var c: int = cclass.fSet[charIndex]
          if c <= 65535 && char.IsLowSurrogate(cast[char](c)) && newString.Length > 0 && char.IsHighSurrogate(newString[newString.Length - 1]):
              continue
          if !rules.fDictionarySet.Contains(c):
newString.AppendCodePoint(c)
++n
    fString = newString.ToString
    fActualBreaks = seq[bool]
    fExpectedBreaks = seq[bool]
    fRuleForPosition = seq[int]
    f2ndRuleForPos = seq[int]
    fExpectedBreaks[0] = true
    var strIdx: int = 0
    while strIdx < fString.Length:
        var matchingRule: BreakRule = nil
        var hasBreak: bool = false
        var ruleNum: int = 0
        var matchStart: int = 0
        var matchEnd: int = 0
        var match: Match = nil
          ruleNum = 0
          while ruleNum < rules.fBreakRules.Count:
              var rule: BreakRule = rules.fBreakRules[ruleNum]
              match = rule.fRuleMatcher.Match(fString.Substring(strIdx), 0)
              if match.Success:
                  matchStart = strIdx
                  matchEnd = strIdx + match.Index + match.Length
                  hasBreak = BreakGroupStart(match) >= 0
                  if hasBreak || matchStart < fString.Length && fString.OffsetByCodePoints(matchStart, 1) < matchEnd:
                      matchingRule = rule
                      break
++ruleNum
        if matchingRule == nil:
            var msg: String = String.Format("{0}: No reference rules matched at position {1}. ", rules.fMonkeyImpl.fRuleFileName, strIdx)
Console.Error.WriteLine(msg)
Dump(strIdx)
            raise ArgumentException(msg)
        if matchingRule.fRuleMatcher.GetGroupNumbers.Length == 0:
            var msg: String = String.Format("{0}:{1}: Zero length rule match at {2}.", rules.fMonkeyImpl.fRuleFileName, matchingRule.fName, strIdx)
Console.Error.WriteLine(msg)
Dump(strIdx)
            raise ArgumentException(msg)
          var i: int = matchStart
          while i < matchEnd:
              if fRuleForPosition[i] == 0:
                  fRuleForPosition[i] = ruleNum
              else:
                  f2ndRuleForPos[i] = ruleNum
++i
        if hasBreak:
            var breakPos: int = strIdx + BreakGroupStart(match)
            fExpectedBreaks[breakPos] = true
            strIdx = breakPos
        else:
            var updatedStrIdx: int = fString.OffsetByCodePoints(matchEnd, -1)
            if updatedStrIdx == matchStart:
                raise ArgumentException(String.Format("{0}: Rule {1} internal error.", rules.fMonkeyImpl.fRuleFileName, matchingRule.fName))
            strIdx = updatedStrIdx
proc BreakGroupStart(m: Match): int =
      var groupNum: int = 1
      while groupNum <= m.Groups.Count:
          var group: String = m.Groups[groupNum].Value
          if !m.Groups[groupNum].Success:
              continue
          if group.Equals(""):
              return m.Groups[groupNum].Index
++groupNum
    return -1
proc Dump(around: int) =
Console.Out.Write("
" + "         char                        break  Rule                     Character
" + "   pos   code   class                 R I   name                     name
" + "---------------------------------------------------------------------------------------------
")
    var start: int
    var end: int
    if around == -1:
        start = 0
        end = fString.Length
    else:
        try:
            start = fString.OffsetByCodePoints(around, -30)
        except Exception:
            start = 0
        try:
            end = fString.OffsetByCodePoints(around, +30)
        except Exception:
            end = fString.Length
      var charIdx: int = start
      while charIdx < end:
          var c: int = fString.CodePointAt(charIdx)
          var cc: CharClass = fBkRules.GetClassForChar(c)
          var rule: BreakRule = fBkRules.fBreakRules[fRuleForPosition[charIdx]]
          var secondRuleName: String = ""
          if f2ndRuleForPos[charIdx] > 0:
              secondRuleName = fBkRules.fBreakRules[f2ndRuleForPos[charIdx]].fName
          var cName: String = UCharacterName.Instance.GetName(c, UCharacterNameChoice.ExtendedCharName)
Console.Out.Write("  {0:d4} {1:x6}   {2}  {3} {4}   {5} {6}    {7}
", charIdx, c, cc.fName.PadRight(20, ' '),           if fExpectedBreaks[charIdx]:
'*'
          else:
'.',           if fActualBreaks[charIdx]:
'*'
          else:
'.', rule.fName.PadRight(10, ' '), secondRuleName.PadRight(10, ' '), cName)
          charIdx = fString.OffsetByCodePoints(charIdx, 1)
proc ClearActualBreaks() =
fActualBreaks.Fill(false)
type
  RBBIMonkeyImpl = ref object
    fRuleCharBuffer: String
    fRuleSet: BreakRules
    fBI: RuleBasedBreakIterator
    fTestData: MonkeyTestData
    fRandomGenerator: ICU_Rand
    fRuleFileName: String
    fVerbose: bool
    fLoopCount: int
    fDumpExpansions: bool
    fErrorMsgs: StringBuilder = StringBuilder

proc Setup(ruleFile: String) =
    fRuleFileName = ruleFile
OpenBreakRules(ruleFile)
    fRuleSet = BreakRules(self)
fRuleSet.CompileRules(fRuleCharBuffer)
    fBI = fRuleSet.CreateICUBreakIterator
    fTestData = MonkeyTestData
proc OpenBreakRules(fileName: String) =
    var testFileBuf: StringBuilder = StringBuilder
    var @is: Stream = nil
    var filePath: String = "ICU4N.Dev.Test.Rbbi.break_rules." + fileName
    try:
        var assembly: Assembly = type(RBBIMonkeyImpl).Assembly
        @is = assembly.GetManifestResourceStream(filePath)
        if @is == nil:
Errln("Could not open test data file " + fileName)
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
        try:
@is.Dispose
        except IOException:

Errln(e.ToString)
    fRuleCharBuffer = testFileBuf.ToString
type
  MonkeyException = ref object
    fPosition: int

proc newMonkeyException(description: String, pos: int): MonkeyException =
newException(description)
  fPosition = pos
proc Run*() =
    var errorCount: int = 0
    if fBI == nil:
fErrorMsgs.Append("Unable to run test because fBI is null.
")
        return
      var loopCount: long = 0
      while fLoopCount < 0 || loopCount < fLoopCount:
          try:
fTestData.Set(fRuleSet, fRandomGenerator)
TestForwards
TestPrevious
TestFollowing
TestPreceding
TestIsBoundary
          except MonkeyException:
              var formattedMsg: String = String.Format("{0} at index {1}. VM Arguments to reproduce: -Drules={2} -Dseed={3} -Dloop=1 -Dverbose=1 "
", e.Message, e.fPosition, fRuleFileName, fTestData.fRandomSeed)
Console.Error.Write(formattedMsg)
              if fVerbose:
fTestData.Dump(e.fPosition)
fErrorMsgs.Append(formattedMsg)
              if ++errorCount > 10:
                  return
          if fLoopCount < 0 && loopCount % 100 == 0:
Console.Error.Write(".")
++loopCount
type
  CheckDirection = enum
    FORWARD
    REVERSE

proc TestForwards() =
fTestData.ClearActualBreaks
fBI.SetText(fTestData.fString)
    var previousBreak: int = -2
      var bk: int = fBI.First
      while bk != BreakIterator.Done:
          if bk <= previousBreak:
              raise MonkeyException("Break Iterator Stall", bk)
          if bk < 0 || bk > fTestData.fString.Length:
              raise MonkeyException("Boundary out of bounds", bk)
          fTestData.fActualBreaks[bk] = true
          bk = fBI.Next
CheckResults("testForwards", CheckDirection.FORWARD)
proc TestFollowing() =
fTestData.ClearActualBreaks
fBI.SetText(fTestData.fString)
    var nextBreak: int = -1
      var i: int = -1
      while i < fTestData.fString.Length:
          var bk: int = fBI.Following(i)
          if bk == BreakIterator.Done && i == fTestData.fString.Length:
              continue
          if bk == nextBreak && bk > i:
              continue
          if i == nextBreak && bk > nextBreak:
              fTestData.fActualBreaks[bk] = true
              nextBreak = bk
              continue
          raise MonkeyException("following(i)", i)
++i
CheckResults("testFollowing", CheckDirection.FORWARD)
proc TestPrevious() =
fTestData.ClearActualBreaks
fBI.SetText(fTestData.fString)
    var previousBreak: int = int.MaxValue
      var bk: int = fBI.Last
      while bk != BreakIterator.Done:
          if bk >= previousBreak:
              raise MonkeyException("Break Iterator Stall", bk)
          if bk < 0 || bk > fTestData.fString.Length:
              raise MonkeyException("Boundary out of bounds", bk)
          fTestData.fActualBreaks[bk] = true
          bk = fBI.Previous
CheckResults("testPrevius", CheckDirection.REVERSE)
proc GetChar32Start(s: String, i: int): int =
    if i > 0 && i < s.Length && char.IsLowSurrogate(s[i]) && char.IsHighSurrogate(s[i - 1]):
--i
    return i
proc TestPreceding() =
fTestData.ClearActualBreaks
fBI.SetText(fTestData.fString)
    var nextBreak: int = fTestData.fString.Length + 1
      var i: int = fTestData.fString.Length + 1
      while i >= 0:
          var bk: int = fBI.Preceding(i)
          if bk == BreakIterator.Done && i == 0:
              continue
          if bk == nextBreak && bk < i:
              continue
          if i < fTestData.fString.Length && GetChar32Start(fTestData.fString, i) < i:
              if fBI.Preceding(i) != fBI.Preceding(GetChar32Start(fTestData.fString, i)):
                  raise MonkeyException("preceding of trailing surrogate error", i)
              continue
          if i == nextBreak && bk < nextBreak:
              fTestData.fActualBreaks[bk] = true
              nextBreak = bk
              continue
          raise MonkeyException("preceding(i)", i)
--i
CheckResults("testPreceding", CheckDirection.REVERSE)
proc TestIsBoundary() =
fTestData.ClearActualBreaks
fBI.SetText(fTestData.fString)
      var i: int = fTestData.fString.Length
      while i >= 0:
          if fBI.IsBoundary(i):
              fTestData.fActualBreaks[i] = true
--i
CheckResults("testForwards", CheckDirection.FORWARD)
proc CheckResults(msg: String, direction: CheckDirection) =
    if direction == CheckDirection.FORWARD:
          var i: int = 0
          while i <= fTestData.fString.Length:
              if fTestData.fExpectedBreaks[i] != fTestData.fActualBreaks[i]:
                  raise MonkeyException(msg, i)
++i
    else:
          var i: int = fTestData.fString.Length
          while i >= 0:
              if fTestData.fExpectedBreaks[i] != fTestData.fActualBreaks[i]:
                  raise MonkeyException(msg, i)
--i
proc TestMonkey*() =
fail("TODO: Rule regex never matches the test data, so we never actually test anything (even though it passes).")
    var tests: String[] = @["grapheme.txt", "word.txt", "line.txt", "sentence.txt", "line_normal.txt", "line_normal_cj.txt", "line_loose.txt", "line_loose_cj.txt", "word_POSIX.txt"]
    var testNameFromParams: String = GetProperty("rules")
    if testNameFromParams != nil:
        tests = @[testNameFromParams]
    var loopCount: int = GetIntProperty("loop",     if IsQuick:
100
    else:
5000)
    var dumpExpansions: bool = GetBooleanProperty("expansions", false)
    var verbose: bool = GetBooleanProperty("verbose", false)
    var seed: int = GetIntProperty("seed", 1)
    var startedTests: List<RBBIMonkeyImpl> = List<RBBIMonkeyImpl>
    for testName in tests:
Logln(String.Format("beginning testing of {0}", testName))
        var test: RBBIMonkeyImpl = RBBIMonkeyImpl
test.Setup(testName)
test.Start
startedTests.Add(test)
    var errors: StringBuilder = StringBuilder
    for test in startedTests:
test.Join
errors.Append(test.fErrorMsgs)
    var errorMsgs: String = errors.ToString
assertEquals(errorMsgs, "", errorMsgs)