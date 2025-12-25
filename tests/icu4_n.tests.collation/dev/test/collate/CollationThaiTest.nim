# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationThaiTest = ref object
    MAX_FAILURES_TO_SHOW: int = -1
    m_collator_: RuleBasedCollator

proc TestCornerCases*() =
    var TESTS: String[] = @["ก", "<", "กก", "กา", "<", "ก้า", "กา", "<", "กา์", "กาก้า", "<", "ก่าก้า", "กา", "=", "กา-", "กา-", "<", "กากา", "กา", "=", "กาๆ", "กาๆ", "<", "กากา", "ฤษี", "<", "ฤๅษี", "ฦษี", "<", "ฦๅษี", "เกอ", "<", "เกิ", "กาก่า", "<", "ก้ากา", "ก.ก.", "<", "กา"]
    var coll: RuleBasedCollator = nil
    try:
        coll = GetThaiCollator
    except Exception:
Warnln("could not construct Thai collator")
        return
CompareArray(coll, TESTS)
proc CompareArray(c: RuleBasedCollator, tests: seq[String]) =
      var i: int = 0
      while i < tests.Length:
          var expect: int = 0
          if tests[i + 1].Equals("<"):
              expect = -1

          elif tests[i + 1].Equals(">"):
              expect = 1
          else:
            if tests[i + 1].Equals("="):
                expect = 0
            else:
Errln("Error: unknown operator " + tests[i + 1])
                return
          var s1: String = tests[i]
          var s2: String = tests[i + 2]
CollationTest.DoTest(self, c, s1, s2, expect)
          i = 3
proc Sign(i: int): int =
    if i < 0:
      return -1
    if i > 0:
      return 1
    return 0
proc TestDictionary*() =
    var coll: RuleBasedCollator = nil
    try:
        coll = GetThaiCollator
    except Exception:
Warnln("could not construct Thai collator")
        return
    var line: int = 0
    var failed: int = 0
    var wordCount: int = 0
    var @in: TextReader = nil
    try:
        var fileName: String = "riwords.txt"
        @in = TestUtil.GetDataReader(fileName, "UTF-8")
        var lastWord: String = ""
        var word: String = @in.ReadLine
        while word != nil:
++line
            if word.Length == 0 || word[0] == 35:
                word = @in.ReadLine
                continue
++wordCount
            if wordCount <= 8:
Logln("Word " + wordCount + ": " + word)
            if lastWord.Length > 0:
                var result: int = coll.Compare(lastWord, word)
                if result > 0:
++failed
                    if MAX_FAILURES_TO_SHOW < 0 || failed <= MAX_FAILURES_TO_SHOW:
                        var msg: String = "--------------------------------------------
" + line + " compare(" + lastWord + ", " + word + ") returned " + result + ", expected -1
"
                          var k1: CollationKey
                          var k2: CollationKey
                        k1 = coll.GetCollationKey(lastWord)
                        k2 = coll.GetCollationKey(word)
                        msg = "key1: " + CollationTest.Prettify(k1) + "
" + "key2: " + CollationTest.Prettify(k2)
Errln(msg)
            lastWord = word
            word = @in.ReadLine
    except IOException:
Errln("IOException " + e.ToString)
    finally:
        if @in == nil:
Errln("Error: could not open test file. Aborting test.")
        else:
            try:
@in.Dispose
            except IOException:

    if @in == nil:
        return
    if failed != 0:
        if failed > MAX_FAILURES_TO_SHOW:
Errln("Too many failures; only the first " + MAX_FAILURES_TO_SHOW + " failures were shown")
Errln("Summary: " + failed + " of " + line - 1 + " comparisons failed")
Logln("Words checked: " + wordCount)
proc TestInvalidThai*() =
    var tests: String[] = @["ไกไก", "ไกกไ", "กไกไ", "กกไไ", "ไไกก", "กไไก"]
    var collator: RuleBasedCollator
    var comparator: StrCmp
    try:
        collator = GetThaiCollator
        comparator = StrCmp
    except Exception:
Warnln("could not construct Thai collator")
        return
Array.Sort(tests, comparator)
      var i: int = 0
      while i < tests.Length:
            var j: int = i + 1
            while j < tests.Length:
                if collator.Compare(tests[i], tests[j]) > 0:
Errln("Inconsistent ordering between strings " + i + " and " + j)
++j
          var iterator: CollationElementIterator = collator.GetCollationElementIterator(tests[i])
CollationTest.BackAndForth(self, iterator)
++i
proc TestReordering*() =
    var tests: String[] = @["แć", "=", "แć", "แ𝟎", "<", "แ𝟏", "แ𝅘𝅥", "=", "แ𝅘𝅥", "แ乁", "=", "แ乁", "แ́", "=", "แ́", "แ̖́", "=", "แ̖́", "abcแć", "=", "abcแć", "abcแ𝀀", "<", "abcแ𝀁", "abcแ𝅘𝅥", "=", "abcแ𝅘𝅥", "abcแ乁", "=", "abcแ乁", "abcแ́", "=", "abcแ́", "abcแ̖́", "=", "abcแ̖́", "แćabc", "=", "แćabc", "แ𝀀abc", "<", "แ𝀁abc", "แ𝅘𝅥abc", "=", "แ𝅘𝅥abc", "แ乁abc", "=", "แ乁abc", "แ́abc", "=", "แ́abc", "แ̖́abc", "=", "แ̖́abc", "abcแćabc", "=", "abcแćabc", "abcแ𝀀abc", "<", "abcแ𝀁abc", "abcแ𝅘𝅥abc", "=", "abcแ𝅘𝅥abc", "abcแ乁abc", "=", "abcแ乁abc", "abcแ́abc", "=", "abcแ́abc", "abcแ̖́abc", "=", "abcแ̖́abc"]
    var collator: RuleBasedCollator
    try:
        collator = GetThaiCollator
    except Exception:
Warnln("could not construct Thai collator")
        return
CompareArray(collator, tests)
    var rule: String = "& c < ab"
    var testcontraction: String[] = @["แab", ">", "แc"]
    try:
        collator = RuleBasedCollator(rule)
    except Exception:
Errln("Error: could not construct collator with rule " + rule)
        return
CompareArray(collator, testcontraction)
type
  StrCmp = ref object
    collator: Collator

proc Compare*(string1: String, string2: String): int =
    return collator.Compare(string1, string2)
proc newStrCmp(): StrCmp =
  collator = GetThaiCollator
proc GetThaiCollator(): RuleBasedCollator =
    if m_collator_ == nil:
        m_collator_ = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("th-TH")))
    return m_collator_