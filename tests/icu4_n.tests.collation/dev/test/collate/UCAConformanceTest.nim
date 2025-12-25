# "Namespace: ICU4N.Dev.Test.Collate"
type
  UCAConformanceTest = ref object
    UCA: RuleBasedCollator
    rbUCA: RuleBasedCollator
    comparer: UTF16.StringComparer
    isAtLeastUCA62: bool = UChar.UnicodeVersion.CompareTo(VersionInfo.Unicode_6_2) >= 0
    @in: TextReader
    IS_SHIFTED: int = 1
    FROM_RULES: int = 2

proc newUCAConformanceTest(): UCAConformanceTest =

proc init*() =
    UCA = cast[RuleBasedCollator](Collator.GetInstance(UCultureInfo.InvariantCulture))
    comparer = UTF16.StringComparer(true, false, UTF16.StringComparer.FoldCaseDefault)
proc TestTableNonIgnorable*() =
setCollNonIgnorable(UCA)
openTestFile("NON_IGNORABLE")
conformanceTest(UCA)
proc TestTableShifted*() =
setCollShifted(UCA)
openTestFile("SHIFTED")
conformanceTest(UCA)
proc TestRulesNonIgnorable*() =
    if logKnownIssue("cldrbug:6745", "UCARules.txt has problems"):
        return
initRbUCA
    if rbUCA == nil:
        return
setCollNonIgnorable(rbUCA)
openTestFile("NON_IGNORABLE")
conformanceTest(rbUCA)
proc TestRulesShifted*() =
Logln("This test is currently disabled, as it is impossible to " + "wholly represent fractional UCA using tailoring rules.")
    return
proc openTestFile(type: String) =
    var collationTest: String = "CollationTest_"
    var ext: String = ".txt"
    try:
        @in = TestUtil.GetDataReader(collationTest + type + "_SHORT" + ext)
    except Exception:
        try:
            @in = TestUtil.GetDataReader(collationTest + type + ext)
        except Exception:
            try:
                @in = TestUtil.GetDataReader(collationTest + type + "_STUB" + ext)
Logln("INFO: Working with the stub file.
" + "If you need the full conformance test, please
" + "download the appropriate data files from:
" + "http://unicode.org/cldr/trac/browser/trunk/common/uca")
            except Exception:
Errln("ERROR: Could not find any of the test files")
proc setCollNonIgnorable(coll: RuleBasedCollator) =
    if coll != nil:
        coll.Decomposition = Collator.CanonicalDecomposition
        coll.IsLowerCaseFirst = false
        coll.IsCaseLevel = false
        coll.Strength =         if isAtLeastUCA62:
Collator.Identical
        else:
Collator.Tertiary
        coll.IsAlternateHandlingShifted = false
proc setCollShifted(coll: RuleBasedCollator) =
    if coll != nil:
        coll.Decomposition = Collator.CanonicalDecomposition
        coll.IsLowerCaseFirst = false
        coll.IsCaseLevel = false
        coll.Strength =         if isAtLeastUCA62:
Collator.Identical
        else:
Collator.Quaternary
        coll.IsAlternateHandlingShifted = true
proc initRbUCA() =
    if rbUCA == nil:
        var ucarules: String = UCA.GetRules(true)
        try:
            rbUCA = RuleBasedCollator(ucarules)
        except Exception:
Errln("Failure creating UCA rule-based collator: " + e)
proc parseString(line: String): String =
      var i: int = 0
      var value: int
      var result: StringBuilder = StringBuilder
      var buffer: StringBuilder = StringBuilder
      while true:
          while i < line.Length && char.IsWhiteSpace(line[i]):
++i
          while i < line.Length && char.IsLetterOrDigit(line[i]):
buffer.Append(line[i])
++i
          if buffer.Length == 0:
              return result.ToString
          value = int.Parse(buffer.ToString, NumberStyles.HexNumber, CultureInfo.InvariantCulture)
          buffer.Length = 0
result.AppendCodePoint(value)
proc skipLineBecauseOfBug(s: String, flags: int): bool =
    return false
proc normalizeResult(result: int): int =
    return     if result < 0:
-1
    else:
        if result == 0:
0
        else:
1
proc conformanceTest(coll: RuleBasedCollator) =
    if @in == nil || coll == nil:
        return
    var skipFlags: int = 0
    if coll.IsAlternateHandlingShifted:
        skipFlags = IS_SHIFTED
    if coll == rbUCA:
        skipFlags = FROM_RULES
Logln("-prop:ucaconfnosortkeys=1 turns off getSortKey() in UCAConformanceTest")
    var withSortKeys: bool = GetProperty("ucaconfnosortkeys") == nil
    var lineNo: int = 0
      var line: String = nil
      var oldLine: String = nil
      var buffer: String = nil
      var oldB: String = nil
      var sk1: RawCollationKey = RawCollationKey
      var sk2: RawCollationKey = RawCollationKey
      var oldSk: RawCollationKey = nil
      var newSk: RawCollationKey = sk1
    try:
        while         line = @in.ReadLine != nil:
++lineNo
            if line.Length == 0 || line[0] == '#':
                continue
            buffer = parseString(line)
            if skipLineBecauseOfBug(buffer, skipFlags):
Logln("Skipping line " + lineNo + " because of a known bug")
                continue
            if withSortKeys:
coll.GetRawCollationKey(buffer, newSk)
            if oldSk != nil:
                var ok: bool = true
                var skres: int =                 if withSortKeys:
oldSk.CompareTo(newSk)
                else:
0
                var cmpres: int = coll.Compare(oldB, buffer)
                var cmpres2: int = coll.Compare(buffer, oldB)
                if cmpres != -cmpres2:
Errln(String.Format("Compare result not symmetrical on line {0}: " + "previous vs. current ({1}) / current vs. previous ({2})", lineNo, cmpres, cmpres2))
                    ok = false
                if withSortKeys && cmpres != normalizeResult(skres):
Errln("Difference between coll.compare (" + cmpres + ") and sortkey compare (" + skres + ") on line " + lineNo)
                    ok = false
                var res: int = cmpres
                if res == 0 && !isAtLeastUCA62:
                    res = comparer.Compare(oldB, buffer)
                if res > 0:
Errln("Line " + lineNo + " is not greater or equal than previous line")
                    ok = false
                if !ok:
Errln("  Previous data line " + oldLine)
Errln("  Current data line  " + line)
                    if withSortKeys:
Errln("  Previous key: " + CollationTest.Prettify(oldSk))
Errln("  Current key:  " + CollationTest.Prettify(newSk))
            oldSk = newSk
            oldB = buffer
            oldLine = line
            if oldSk == sk1:
                newSk = sk2
            else:
                newSk = sk1
    except Exception:
Errln("Unexpected exception " & $e & " line number: " & $lineNo)
    finally:
        try:
@in.Dispose
        except IOException:

        @in = nil