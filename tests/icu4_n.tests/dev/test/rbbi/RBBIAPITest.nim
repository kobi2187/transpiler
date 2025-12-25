# "Namespace: ICU4N.Dev.Test.Rbbi"
type
  RBBIAPITest = ref object


proc TestCloneEquals*() =
    var bi1: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetCharacterInstance(CultureInfo.CurrentCulture))
    var biequal: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetCharacterInstance(CultureInfo.CurrentCulture))
    var bi3: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetCharacterInstance(CultureInfo.CurrentCulture))
    var bi2: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetWordInstance(CultureInfo.CurrentCulture))
    var testString: string = "Testing word break iterators's clone() and equals()"
bi1.SetText(testString)
bi2.SetText(testString)
biequal.SetText(testString)
bi3.SetText("hello")
Logln("Testing equals()")
Logln("Testing == and !=")
    if !bi1.Equals(biequal) || bi1.Equals(bi2) || bi1.Equals(bi3):
Errln("ERROR:1 RBBI's == and !- operator failed.")
    if bi2.Equals(biequal) || bi2.Equals(bi1) || biequal.Equals(bi3):
Errln("ERROR:2 RBBI's == and != operator  failed.")
Logln("Testing clone()")
    var bi1clone: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](bi1.Clone)
    var bi2clone: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](bi2.Clone)
    if !bi1clone.Equals(bi1) || !bi1clone.Equals(biequal) || bi1clone.Equals(bi3) || bi1clone.Equals(bi2):
Errln("ERROR:1 RBBI's clone() method failed")
    if bi2clone.Equals(bi1) || bi2clone.Equals(biequal) || bi2clone.Equals(bi3) || !bi2clone.Equals(bi2):
Errln("ERROR:2 RBBI's clone() method failed")
    if !bi1.Text.Equals(bi1clone.Text) || !bi2clone.Text.Equals(bi2.Text) || bi2clone.Equals(bi1clone):
Errln("ERROR: RBBI's clone() method failed")
proc TestToString*() =
    var bi1: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetCharacterInstance(CultureInfo.CurrentCulture))
    var bi2: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetWordInstance(CultureInfo.CurrentCulture))
Logln("Testing toString()")
bi1.SetText("Hello there")
    var bi3: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](bi1.Clone)
    var temp: String = bi1.ToString
    var temp2: String = bi2.ToString
    var temp3: String = bi3.ToString
    if temp2.Equals(temp3) || temp.Equals(temp2) || !temp.Equals(temp3):
Errln("ERROR: error in toString() method")
proc TestHashCode*() =
    var bi1: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetCharacterInstance(CultureInfo.CurrentCulture))
    var bi3: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetCharacterInstance(CultureInfo.CurrentCulture))
    var bi2: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetWordInstance(CultureInfo.CurrentCulture))
Logln("Testing hashCode()")
bi1.SetText("Hash code")
bi2.SetText("Hash code")
bi3.SetText("Hash code")
    var bi1clone: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](bi1.Clone)
    var bi2clone: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](bi2.Clone)
    if bi1.GetHashCode != bi1clone.GetHashCode || bi1.GetHashCode != bi3.GetHashCode || bi1clone.GetHashCode != bi3.GetHashCode || bi2.GetHashCode != bi2clone.GetHashCode:
Errln("ERROR: identical objects have different hashcodes")
    if bi1.GetHashCode == bi2.GetHashCode || bi2.GetHashCode == bi3.GetHashCode || bi1clone.GetHashCode == bi2clone.GetHashCode || bi1clone.GetHashCode == bi2.GetHashCode:
Errln("ERROR: different objects have same hashcodes")
proc TestGetSetText*() =
Logln("Testing getText setText ")
    var str1: String = "first string."
    var str2: String = "Second string."
    var wordIter1: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetWordInstance(CultureInfo.CurrentCulture))
    var text1: CharacterIterator = ICU4N.Impl.ReadOnlyMemoryCharacterIterator(str1.AsMemory)
wordIter1.SetText(str1)
    if !wordIter1.Text.Equals(text1):
Errln("ERROR:1 error in setText or getText ")
    if wordIter1.Current != 0:
Errln("ERROR:1 setText did not set the iteration position to the beginning of the text, it is" + wordIter1.Current + "
")
wordIter1.Next(2)
wordIter1.SetText(str2)
    if wordIter1.Current != 0:
Errln("ERROR:2 setText did not reset the iteration position to the beginning of the text, it is" + wordIter1.Current + "
")
    var lineIter: BreakIterator = BreakIterator.GetLineInstance(CultureInfo("en"))
    var csText: ReadOnlyMemory<char> = "Hello, World. ".AsMemory
    var expected: List<int> = List<int>
expected.Add(0)
expected.Add(7)
expected.Add(14)
lineIter.SetText(csText)
      var pos: int = lineIter.First
      while pos != BreakIterator.Done:
assertTrue("", expected.Contains(pos))
          pos = lineIter.Next
assertEquals("", csText.Length, lineIter.Current)
proc TestFirstNextFollowing*() =
      var p: int
      var q: int
    var testString: String = "This is a word break. Isn't it? 2.25"
Logln("Testing first() and next(), following() with custom rules")
Logln("testing word iterator - string :- "" + testString + ""
")
    var wordIter1: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetWordInstance(CultureInfo.CurrentCulture))
wordIter1.SetText(testString)
    p = wordIter1.First
    if p != 0:
Errln("ERROR: first() returned" + p + "instead of 0")
    q = wordIter1.Next(9)
doTest(testString, p, q, 20, "This is a word break")
    p = q
    q = wordIter1.Next
doTest(testString, p, q, 21, ".")
    p = q
    q = wordIter1.Next(3)
doTest(testString, p, q, 28, " Isn't ")
    p = q
    q = wordIter1.Next(2)
doTest(testString, p, q, 31, "it?")
    q = wordIter1.Following(2)
doTest(testString, 2, q, 4, "is")
    q = wordIter1.Following(22)
doTest(testString, 22, q, 27, "Isn't")
wordIter1.Last
    p = wordIter1.Next
    q = wordIter1.Following(wordIter1.Last)
    if p != BreakIterator.Done || q != BreakIterator.Done:
Errln("ERROR: next()/following() at last position returned #" + p + " and " + q + " instead of" + testString.Length + "
")
    var charIter1: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetCharacterInstance(CultureInfo.CurrentCulture))
    testString = "Write hindi here. "
Logln("testing char iter - string:- "" + testString + """)
charIter1.SetText(testString)
    p = charIter1.First
    if p != 0:
Errln("ERROR: first() returned" + p + "instead of 0")
    q = charIter1.Next
doTest(testString, p, q, 1, "W")
    p = q
    q = charIter1.Next(4)
doTest(testString, p, q, 5, "rite")
    p = q
    q = charIter1.Next(12)
doTest(testString, p, q, 17, " hindi here.")
    p = q
    q = charIter1.Next(-6)
doTest(testString, p, q, 11, " here.")
    p = q
    q = charIter1.Next(6)
doTest(testString, p, q, 17, " here.")
    p = charIter1.Following(charIter1.Last)
    q = charIter1.Next(charIter1.Last)
    if p != BreakIterator.Done || q != BreakIterator.Done:
Errln("ERROR: following()/next() at last position returned #" + p + " and " + q + " instead of" + testString.Length)
    testString = "Hello! how are you? I'am fine. Thankyou. How are you doing? This  costs $20,00,000."
    var sentIter1: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetSentenceInstance(CultureInfo.CurrentCulture))
Logln("testing sentence iter - String:- "" + testString + """)
sentIter1.SetText(testString)
    p = sentIter1.First
    if p != 0:
Errln("ERROR: first() returned" + p + "instead of 0")
    q = sentIter1.Next
doTest(testString, p, q, 7, "Hello! ")
    p = q
    q = sentIter1.Next(2)
doTest(testString, p, q, 31, "how are you? I'am fine. ")
    p = q
    q = sentIter1.Next(-2)
doTest(testString, p, q, 7, "how are you? I'am fine. ")
    p = q
    q = sentIter1.Next(4)
doTest(testString, p, q, 60, "how are you? I'am fine. Thankyou. How are you doing? ")
    p = q
    q = sentIter1.Next
doTest(testString, p, q, 83, "This  costs $20,00,000.")
    q = sentIter1.Following(1)
doTest(testString, 1, q, 7, "ello! ")
    q = sentIter1.Following(10)
doTest(testString, 10, q, 20, " are you? ")
    q = sentIter1.Following(20)
doTest(testString, 20, q, 31, "I'am fine. ")
    p = sentIter1.Following(sentIter1.Last)
    q = sentIter1.Next(sentIter1.Last)
    if p != BreakIterator.Done || q != BreakIterator.Done:
Errln("ERROR: following()/next() at last position returned #" + p + " and " + q + " instead of" + testString.Length)
    testString = "Hello! how
 (are) you? I'am fine- Thankyou. foo bar How, are, you? This, costs $20,00,000."
Logln("(UnicodeString)testing line iter - String:- "" + testString + """)
    var lineIter1: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetLineInstance(CultureInfo.CurrentCulture))
lineIter1.SetText(testString)
    p = lineIter1.First
    if p != 0:
Errln("ERROR: first() returned" + p + "instead of 0")
    q = lineIter1.Next
doTest(testString, p, q, 7, "Hello! ")
    p = q
    p = q
    q = lineIter1.Next(4)
doTest(testString, p, q, 20, "how
 (are) ")
    p = q
    q = lineIter1.Next(-4)
doTest(testString, p, q, 7, "how
 (are) ")
    p = q
    q = lineIter1.Next(6)
doTest(testString, p, q, 30, "how
 (are) you? I'am ")
    p = q
    q = lineIter1.Next
doTest(testString, p, q, 36, "fine- ")
    p = q
    q = lineIter1.Next(2)
doTest(testString, p, q, 54, "Thankyou. foo bar ")
    q = lineIter1.Following(60)
doTest(testString, 60, q, 64, "re, ")
    q = lineIter1.Following(1)
doTest(testString, 1, q, 7, "ello! ")
    q = lineIter1.Following(10)
doTest(testString, 10, q, 12, "
")
    q = lineIter1.Following(20)
doTest(testString, 20, q, 25, "you? ")
    p = lineIter1.Following(lineIter1.Last)
    q = lineIter1.Next(lineIter1.Last)
    if p != BreakIterator.Done || q != BreakIterator.Done:
Errln("ERROR: following()/next() at last position returned #" + p + " and " + q + " instead of" + testString.Length)
proc TestLastPreviousPreceding*() =
      var p: int
      var q: int
    var testString: String = "This is a word break. Isn't it? 2.25 dollars"
Logln("Testing last(),previous(), preceding() with custom rules")
Logln("testing word iteration for string "" + testString + """)
    var wordIter1: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetWordInstance(CultureInfo("en")))
wordIter1.SetText(testString)
    p = wordIter1.Last
    if p != testString.Length:
Errln("ERROR: last() returned" + p + "instead of" + testString.Length)
    q = wordIter1.Previous
doTest(testString, p, q, 37, "dollars")
    p = q
    q = wordIter1.Previous
doTest(testString, p, q, 36, " ")
    q = wordIter1.Preceding(25)
doTest(testString, 25, q, 22, "Isn")
    p = q
    q = wordIter1.Previous
doTest(testString, p, q, 21, " ")
    q = wordIter1.Preceding(20)
doTest(testString, 20, q, 15, "break")
    p = wordIter1.Preceding(wordIter1.First)
    if p != BreakIterator.Done:
Errln("ERROR: preceding()  at starting position returned #" + p + " instead of 0")
    testString = "Hello! how are you? I'am fine. Thankyou. How are you doing? This  costs $20,00,000."
Logln("testing sentence iter - String:- "" + testString + """)
    var sentIter1: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetSentenceInstance(CultureInfo.CurrentCulture))
sentIter1.SetText(testString)
    p = sentIter1.Last
    if p != testString.Length:
Errln("ERROR: last() returned" + p + "instead of " + testString.Length)
    q = sentIter1.Previous
doTest(testString, p, q, 60, "This  costs $20,00,000.")
    p = q
    q = sentIter1.Previous
doTest(testString, p, q, 41, "How are you doing? ")
    q = sentIter1.Preceding(40)
doTest(testString, 40, q, 31, "Thankyou.")
    q = sentIter1.Preceding(25)
doTest(testString, 25, q, 20, "I'am ")
sentIter1.First
    p = sentIter1.Previous
    q = sentIter1.Preceding(sentIter1.First)
    if p != BreakIterator.Done || q != BreakIterator.Done:
Errln("ERROR: previous()/preceding() at starting position returned #" + p + " and " + q + " instead of 0
")
    testString = "Hello! how are you? I'am fine. Thankyou. How are you doing? This
 costs $20,00,000."
Logln("testing line iter - String:- "" + testString + """)
    var lineIter1: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetLineInstance(CultureInfo.CurrentCulture))
lineIter1.SetText(testString)
    p = lineIter1.Last
    if p != testString.Length:
Errln("ERROR: last() returned" + p + "instead of " + testString.Length)
    q = lineIter1.Previous
doTest(testString, p, q, 72, "$20,00,000.")
    p = q
    q = lineIter1.Previous
doTest(testString, p, q, 66, "costs ")
    q = lineIter1.Preceding(40)
doTest(testString, 40, q, 31, "Thankyou.")
    q = lineIter1.Preceding(25)
doTest(testString, 25, q, 20, "I'am ")
lineIter1.First
    p = lineIter1.Previous
    q = lineIter1.Preceding(sentIter1.First)
    if p != BreakIterator.Done || q != BreakIterator.Done:
Errln("ERROR: previous()/preceding() at starting position returned #" + p + " and " + q + " instead of 0
")
proc TestIsBoundary*() =
    var testString1: String = "Write here. भ́रत सुंदर áu"
    var charIter1: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetCharacterInstance(CultureInfo("en")))
charIter1.SetText(testString1)
    var bounds1: int[] = @[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 20, 21, 22, 23, 25, 26]
doBoundaryTest(charIter1, testString1, bounds1)
    var wordIter2: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetWordInstance(CultureInfo("en")))
wordIter2.SetText(testString1)
    var bounds2: int[] = @[0, 5, 6, 10, 11, 12, 16, 17, 22, 23, 26]
doBoundaryTest(wordIter2, testString1, bounds2)
proc TestRuleStatus*() =
    var bi: BreakIterator = BreakIterator.GetWordInstance(UCultureInfo("en"))
bi.SetText("# ")
assertEquals(nil, bi.Next, 1)
assertTrue(nil, bi.RuleStatus >= BreakIterator.WordNone)
assertTrue(nil, bi.RuleStatus < BreakIterator.WordNoneLimit)
bi.SetText("3 ")
assertEquals(nil, bi.Next, 1)
assertTrue(nil, bi.RuleStatus >= BreakIterator.WordNumber)
assertTrue(nil, bi.RuleStatus < BreakIterator.WordNumberLimit)
bi.SetText("a ")
assertEquals(nil, bi.Next, 1)
assertTrue(nil, bi.RuleStatus >= BreakIterator.WordLetter)
assertTrue(nil, bi.RuleStatus < BreakIterator.WordLetterLimit)
bi.SetText("イ  ")
assertEquals(nil, bi.Next, 1)
assertTrue(nil, bi.RuleStatus >= BreakIterator.WordKana)
bi.SetText("退 ")
assertEquals(nil, bi.Next, 1)
assertTrue(nil, bi.RuleStatus >= BreakIterator.WordIdeo)
assertTrue(nil, bi.RuleStatus < BreakIterator.WordIdeoLimit)
proc TestRuledump*() =
    var bi: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetCharacterInstance)
    var bos: MemoryStream = MemoryStream
    var @out: TextWriter = StreamWriter(bos)
bi.Dump(@out)
assertTrue(nil, bos.Length > 100)
proc doBoundaryTest(bi: BreakIterator, text: String, boundaries: seq[int]) =
Logln("testIsBoundary():")
    var p: int = 0
    var isB: bool
      var i: int = 0
      while i < text.Length:
          isB = bi.IsBoundary(i)
Logln("bi.isBoundary(" + i + ") -> " + isB)
          if i == boundaries[p]:
              if !isB:
Errln("Wrong result from isBoundary() for " + i + ": expected true, got false")
++p
          else:
              if isB:
Errln("Wrong result from isBoundary() for " + i + ": expected false, got true")
++i
proc doTest(testString: String, start: int, gotoffset: int, expectedOffset: int, expectedString: String) =
    var selected: String
    var expected: String = expectedString
    if gotoffset != expectedOffset:
Errln("ERROR:****returned #" + gotoffset + " instead of #" + expectedOffset)
    if start <= gotoffset:
        selected = testString.Substring(start, gotoffset - start)
    else:
        selected = testString.Substring(gotoffset, start - gotoffset)
    if !selected.Equals(expected):
Errln("ERROR:****selected "" + selected + "" instead of "" + expected + """)
    else:
Logln("****selected "" + selected + """)
proc TestGetTitleInstance*() =
    var bi: BreakIterator = BreakIterator.GetTitleInstance(CultureInfo("en-CA"))
TestFmwk.assertNotEquals("Title instance break iterator not correctly instantiated", bi.First, nil)
bi.SetText("Here is some Text")
TestFmwk.assertEquals("Title instance break iterator not correctly instantiated", bi.First, 0)