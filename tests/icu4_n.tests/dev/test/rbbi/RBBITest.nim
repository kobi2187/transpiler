# "Namespace: ICU4N.Dev.Test.Rbbi"
type
  RBBITest = ref object


proc newRBBITest(): RBBITest =

proc TestThaiDictionaryBreakIterator*() =
    var position: int
    var index: int
    var result: int[] = @[1, 2, 5, 10, 11, 12, 11, 10, 5, 2, 1, 0]
    var ctext: char[] = @[cast[char](65), cast[char](32), cast[char](3585), cast[char](3634), cast[char](3619), cast[char](3607), cast[char](3604), cast[char](3621), cast[char](3629), cast[char](3591), cast[char](32), cast[char](65)]
    var text: String = String(ctext)
    var locale: UCultureInfo = UCultureInfo.CreateCanonical("th")
    var b: BreakIterator = BreakIterator.GetWordInstance(locale)
b.SetText(text)
    index = 0
    while     position = b.Next != BreakIterator.Done:
        if position != result[++index]:
Errln("Error with ThaiDictionaryBreakIterator forward iteration test at " + position + ".
Should have been " + result[index - 1])
    while     position = b.Previous != BreakIterator.Done:
        if position != result[++index]:
Errln("Error with ThaiDictionaryBreakIterator backward iteration test at " + position + ".
Should have been " + result[index - 1])
    var text2: char[] = @[cast[char](3585), cast[char](3641), cast[char](32), cast[char](3585), cast[char](3636), cast[char](3609), cast[char](3585), cast[char](3640), cast[char](3657), cast[char](3591), cast[char](32), cast[char](3611), cast[char](3636), cast[char](3657), cast[char](3656), cast[char](3591), cast[char](3629), cast[char](3618), cast[char](3641), cast[char](3656), cast[char](3651), cast[char](3609), cast[char](3606), cast[char](3657), cast[char](3635)]
    var expectedWordResult: int[] = @[2, 3, 6, 10, 11, 15, 17, 20, 22]
    var expectedLineResult: int[] = @[3, 6, 11, 15, 17, 20, 22]
    var brk: BreakIterator = BreakIterator.GetWordInstance(UCultureInfo("th"))
brk.SetText(String(text2))
    position =     index = 0
    while     position = brk.Next != BreakIterator.Done && position < text2.Length:
        if position != expectedWordResult[++index]:
Errln("Incorrect break given by thai word break iterator. Expected: " + expectedWordResult[index - 1] + " Got: " + position)
    brk = BreakIterator.GetLineInstance(UCultureInfo("th"))
brk.SetText(String(text2))
    position =     index = 0
    while     position = brk.Next != BreakIterator.Done && position < text2.Length:
        if position != expectedLineResult[++index]:
Errln("Incorrect break given by thai line break iterator. Expected: " + expectedLineResult[index - 1] + " Got: " + position)
    if brk.Preceding(expectedLineResult[1]) != expectedLineResult[0]:
Errln("Incorrect preceding position.")
    if brk.Following(expectedLineResult[1]) != expectedLineResult[2]:
Errln("Incorrect following position.")
    var fillInArray: int[] = seq[int]
    if cast[RuleBasedBreakIterator](brk).GetRuleStatusVec(fillInArray) != 1 || fillInArray[0] != 0:
Errln("Error: Since getRuleStatusVec is not supported in DictionaryBasedBreakIterator, it should return 1 and fillInArray[0] == 0.")
type
  TBItem = ref object
    type: int
    locale: UCultureInfo
    text: String
    expectOffsets: seq[int]
    maxOffsetCount: int = 128

proc newTBItem(typ: int, loc: UCultureInfo, txt: String, eOffs: seq[int]): TBItem =
  type = typ
  locale = loc
  text = txt
  expectOffsets = eOffs
proc offsetsMatchExpected(foundOffsets: seq[int], foundOffsetsLength: int): bool =
    if foundOffsetsLength != expectOffsets.Length:
        return false
      var i: int = 0
      while i < foundOffsetsLength:
          if foundOffsets[i] != expectOffsets[i]:
              return false
++i
    return true
proc formatOffsets(offsets: seq[int], length: int): String =
    var buildString: StringBuffer = StringBuffer(4 * maxOffsetCount)
      var i: int = 0
      while i < length:
buildString.Append(" " + offsets[i])
++i
    return buildString.ToString
proc doTest*() =
    var brkIter: BreakIterator
    case type
    of BreakIterator.KIND_CHARACTER:
        brkIter = BreakIterator.GetCharacterInstance(locale)
        break
    of BreakIterator.KIND_WORD:
        brkIter = BreakIterator.GetWordInstance(locale)
        break
    of BreakIterator.KIND_LINE:
        brkIter = BreakIterator.GetLineInstance(locale)
        break
    of BreakIterator.KIND_SENTENCE:
        brkIter = BreakIterator.GetSentenceInstance(locale)
        break
    else:
Errln("Unsupported break iterator type " + type)
        return
brkIter.SetText(text)
    var foundOffsets: int[] = seq[int]
      var offset: int
      var foundOffsetsCount: int = 0
    while foundOffsetsCount < maxOffsetCount &&     offset = brkIter.Next != BreakIterator.Done:
        foundOffsets[++foundOffsetsCount] = offset
    if !offsetsMatchExpected(foundOffsets, foundOffsetsCount):
        var textToDisplay: String =         if text.Length <= 16:
text
        else:
text.Substring(0, 16 - 0)
Errln("For type " + type + " " + locale + ", text "" + textToDisplay + "..."" + "; expect " + expectOffsets.Length + " offsets:" + formatOffsets(expectOffsets, expectOffsets.Length) + "; found " + foundOffsetsCount + " offsets fwd:" + formatOffsets(foundOffsets, foundOffsetsCount))
    else:
--foundOffsetsCount
        while foundOffsetsCount > 0:
            offset = brkIter.Previous
            if offset != foundOffsets[--foundOffsetsCount]:
                var textToDisplay: String =                 if text.Length <= 16:
text
                else:
text.Substring(0, 16 - 0)
Errln("For type " + type + " " + locale + ", text "" + textToDisplay + "..."" + "; expect " + expectOffsets.Length + " offsets:" + formatOffsets(expectOffsets, expectOffsets.Length) + "; found rev offset " + offset + " where expect " + foundOffsets[foundOffsetsCount])
                break
proc TestTailoredBreaks*() =
    var elSentText: string = "Αβ, γδ; Ε ζη; Θ ικ. " + "Λμ νξ! Οπ, Ρς? Σ"
    var elSentTOffsets: int[] = @[8, 14, 20, 27, 35, 36]
    var elSentROffsets: int[] = @[20, 27, 35, 36]
    var thCharText: string = "กระท่อมรจนา " + "(สุชาติ-จุฑามาศ) " + "เด็กมีปัญหา "
    var thCharTOffsets: int[] = @[1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15, 16, 17, 19, 20, 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 35, 37, 38, 39, 40, 41]
    var tests: TBItem[] = @[TBItem(BreakIterator.KIND_SENTENCE, UCultureInfo("el"), elSentText, elSentTOffsets), TBItem(BreakIterator.KIND_SENTENCE, UCultureInfo.InvariantCulture, elSentText, elSentROffsets), TBItem(BreakIterator.KIND_CHARACTER, UCultureInfo("th"), thCharText, thCharTOffsets), TBItem(BreakIterator.KIND_CHARACTER, UCultureInfo.InvariantCulture, thCharText, thCharTOffsets)]
      var iTest: int = 0
      while iTest < tests.Length:
tests[iTest].doTest
++iTest
proc TestClone*() =
    var rbbi: RuleBasedBreakIterator = RuleBasedBreakIterator(".;")
    try:
rbbi.SetText(cast[CharacterIterator](nil))
        if cast[RuleBasedBreakIterator](rbbi.Clone).Text != nil:
Errln("RuleBasedBreakIterator.clone() was suppose to return " + "the same object because fText is set to null.")
    except Exception:
Errln("RuleBasedBreakIterator.clone() was not suppose to return " + "an exception.")
proc TestEquals*() =
    var rbbi: RuleBasedBreakIterator = RuleBasedBreakIterator(".;")
    var rbbi1: RuleBasedBreakIterator = RuleBasedBreakIterator(".;")
rbbi.SetText(cast[CharacterIterator](nil))
    if rbbi.Equals(rbbi1):
Errln("RuleBasedBreakIterator.equals(Object) was not suppose to return " + "true when the other object has a null fText.")
rbbi1.SetText(cast[CharacterIterator](nil))
    if !rbbi.Equals(rbbi1):
Errln("RuleBasedBreakIterator.equals(Object) was not suppose to return " + "false when both objects has a null fText.")
    if rbbi.Equals(0):
Errln("RuleBasedBreakIterator.equals(Object) was suppose to return " + "false when comparing to integer 0.")
    if rbbi.Equals(0.0):
Errln("RuleBasedBreakIterator.equals(Object) was suppose to return " + "false when comparing to float 0.0.")
    if rbbi.Equals("0"):
Errln("RuleBasedBreakIterator.equals(Object) was suppose to return " + "false when comparing to string '0'.")
proc TestFirst*() =
    var rbbi: RuleBasedBreakIterator = RuleBasedBreakIterator(".;")
rbbi.SetText(cast[CharacterIterator](nil))
assertEquals("RuleBasedBreakIterator.First()", BreakIterator.Done, rbbi.First)
rbbi.SetText("abc")
assertEquals("RuleBasedBreakIterator.First()", 0, rbbi.First)
assertEquals("RuleBasedBreakIterator.Next()", 1, rbbi.Next)
proc TestLast*() =
    var rbbi: RuleBasedBreakIterator = RuleBasedBreakIterator(".;")
rbbi.SetText(cast[CharacterIterator](nil))
    if rbbi.Last != BreakIterator.Done:
Errln("RuleBasedBreakIterator.Last() was supposed to return " + "BreakIterator.Done when the object has a null fText.")
proc TestFollowing*() =
    var rbbi: RuleBasedBreakIterator = RuleBasedBreakIterator(".;")
rbbi.SetText("dummy")
    if rbbi.Following(-1) != 0:
Errln("RuleBasedBreakIterator.following(-1) was suppose to return " + "0 when the object has a fText of dummy.")
proc TestPreceding*() =
    var rbbi: RuleBasedBreakIterator = RuleBasedBreakIterator(".;")
rbbi.SetText(cast[CharacterIterator](nil))
    if rbbi.Preceding(-1) != BreakIterator.Done:
Errln("RuleBasedBreakIterator.Preceding(-1) was suppose to return " + "0 when the object has a fText of null.")
rbbi.SetText("dummy")
    if rbbi.Preceding(-1) != 0:
Errln("RuleBasedBreakIterator.Preceding(-1) was suppose to return " + "0 when the object has a fText of dummy.")
proc TestCurrent*() =
    var rbbi: RuleBasedBreakIterator = RuleBasedBreakIterator(".;")
rbbi.SetText(cast[CharacterIterator](nil))
    if rbbi.Current != BreakIterator.Done:
Errln("RuleBasedBreakIterator.Current was suppose to return " + "BreakIterator.Done when the object has a fText of null.")
rbbi.SetText("dummy")
    if rbbi.Current != 0:
Errln("RuleBasedBreakIterator.Current was suppose to return " + "0 when the object has a fText of dummy.")
proc TestBug7547*() =
    try:
RuleBasedBreakIterator("")
fail("TestBug7547: RuleBasedBreakIterator constructor failed to throw an exception with empty rules.")
    except ArgumentException:

    except Exception:
fail("TestBug7547: Unexpected exception while creating RuleBasedBreakIterator: " + e)
proc TestBug12797*() =
    var rules: String = "!!chain; !!forward; $v=b c; a b; $v; !!reverse; .*;"
    var bi: RuleBasedBreakIterator = RuleBasedBreakIterator(rules)
bi.SetText("abc")
bi.First
assertEquals("Rule chaining test", 3, bi.Next)
type
  WorkerThread = ref object
    dataToBreak: string
    bi: RuleBasedBreakIterator
    assertErr: seq[AssertionException]

proc newWorkerThread(dataToBreak: string, bi: RuleBasedBreakIterator, assertErr: seq[AssertionException]): WorkerThread =
  self.dataToBreak = dataToBreak
  self.bi = bi
  self.assertErr = assertErr
proc Run*() =
    try:
        var localBI: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](bi.Clone)
localBI.SetText(dataToBreak)
          var loop: int = 0
          while loop < 100:
              var nextExpectedBreak: int = 0
                var actualBreak: int = localBI.First
                while actualBreak != BreakIterator.Done:
assertEquals("", nextExpectedBreak, actualBreak)
                    actualBreak = localBI.Next
assertEquals("", dataToBreak.Length + 4, nextExpectedBreak)
++loop
    except AssertionException:
        assertErr[0] = e
proc TestBug12873*() =
    var dataToBreak: string = "🇦🇦🇦🇦🇦🇦"
    var bi: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetLineInstance)
    var assertErr: AssertionException[] = seq[AssertionException]
    var threads: List<ThreadJob> = List<ThreadJob>
      var n: int = 0
      while n < 4:
threads.Add(WorkerThread(dataToBreak, bi, assertErr))
++n
    for thread in threads:
thread.Start
    for thread in threads:
thread.Join
    if assertErr[0] != nil:
        raise assertErr[0]
proc TestBreakAllChars*() =
    var sb: ValueStringBuilder = ValueStringBuilder(1114112 * 5)
      var c: int = 0
      while c < 1114112:
sb.AppendCodePoint(c)
sb.AppendCodePoint(c)
sb.AppendCodePoint(c)
sb.AppendCodePoint(c)
sb.Append(' ')
++c
    var s: ReadOnlyMemory<char> = sb.AsMemory
      var breakKind: int = BreakIterator.KIND_CHARACTER
      while breakKind <= BreakIterator.KIND_TITLE:
          var bi: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetBreakInstance(UCultureInfo("en"), breakKind))
bi.SetText(s)
          var lastb: int = -1
            var b: int = bi.First
            while b != BreakIterator.Done:
assertTrue("(lastb < b) : (" + lastb + " < " + b + ")", lastb < b)
                b = bi.Next
++breakKind
proc TestBug12918*() =
    var crasherString: String = "㌥䨖"
    var iter: BreakIterator = BreakIterator.GetWordInstance(UCultureInfo("en"))
iter.SetText(crasherString)
iter.First
    var pos: int = 0
    var lastPos: int = -1
    while     pos = iter.Next != BreakIterator.Done:
assertTrue("", pos > lastPos)
proc TestBug12519*() =
    var biEn: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetWordInstance(UCultureInfo("en")))
    var biFr: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](BreakIterator.GetWordInstance(UCultureInfo("fr_FR")))
assertEquals("", UCultureInfo("en"), biEn.ValidCulture)
assertEquals("", UCultureInfo("fr"), biFr.ValidCulture)
assertEquals("Locales do not participate in BreakIterator equality.", biEn, biFr)
    var cloneEn: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](biEn.Clone)
assertEquals("", biEn, cloneEn)
assertEquals("", UCultureInfo("en"), cloneEn.ValidCulture)
    var cloneFr: RuleBasedBreakIterator = cast[RuleBasedBreakIterator](biFr.Clone)
assertEquals("", biFr, cloneFr)
assertEquals("", UCultureInfo("fr"), cloneFr.ValidCulture)
type
  T13512Thread = ref object
    fText: string
    fBoundaries: IList[int]
    fExpectedBoundaries: IList[int]
    BREAK_ITERATOR_CACHE: BreakIterator = BreakIterator.GetWordInstance(UCultureInfo.InvariantCulture)

proc newT13512Thread(text: string): T13512Thread =
  fText = text
  fExpectedBoundaries = GetBoundary(fText)
proc Run*() =
      var i: int = 0
      while i < 10000:
          fBoundaries = GetBoundary(fText)
          if !fBoundaries.Equals(fExpectedBoundaries):
              break
++i
proc GetBoundary*(toParse: string): IList<int> =
    var retVal: IList<int> = List<int>
    var bi: BreakIterator = cast[BreakIterator](BREAK_ITERATOR_CACHE.Clone)
bi.SetText(toParse)
      var boundary: int = bi.First
      while boundary != BreakIterator.Done:
retVal.Add(boundary)
          boundary = bi.Next
    return retVal
proc TestBug13512*() =
    var japanese: string = "コンピューターは、本質的には数字しか扱うことができません。コンピューターは、文字や記号などのそれぞれに番号を割り振る" + "ことによって扱えるようにします。ユニコードが出来るまでは、これらの番号を割り振る仕組みが何百種類も存在しました。どの一つをとっても、十分な" + "文字を含んではいませんでした。例えば、欧州連合一つを見ても、そのすべての言語をカバーするためには、いくつかの異なる符号化の仕" + "組みが必要でした。英語のような一つの言語に限っても、一つだけの符号化の仕組みでは、一般的に使われるすべての文字、句読点、技術" + "的な記号などを扱うには不十分でした。"
    var thai: string = "โดยพื้นฐานแล้ว, คอมพิวเตอร์จะเกี่ยวข้องกับเรื่องของตัวเลข. คอมพิวเตอร์จัดเก็บตัวอักษรและอักขระอื่นๆ" + " โดยการกำหนดหมายเลขให้สำหรับแต่ละตัว. ก่อนหน้าที่๊ Unicode จะถูกสร้างขึ้น, ได้มีระบบ encoding " + "อยู่หลายร้อยระบบสำหรับการกำหนดหมายเลขเหล่านี้. ไม่มี encoding ใดที่มีจำนวนตัวอักขระมากเพียงพอ: ยกตัวอย่างเช่น, " + "เฉพาะในกลุ่มสหภาพยุโรปเพียงแห่งเดียว ก็ต้องการหลาย encoding ในการครอบคลุมทุกภาษาในกลุ่ม. " + "หรือแม้แต่ในภาษาเดี่ยว เช่น ภาษาอังกฤษ ก็ไม่มี encoding ใดที่เพียงพอสำหรับทุกตัวอักษร, " + "เครื่องหมายวรรคตอน และสัญลักษณ์ทางเทคนิคที่ใช้กันอยู่ทั่วไป.
" + "ระบบ encoding เหล่านี้ยังขัดแย้งซึ่งกันและกัน. นั่นก็คือ, ในสอง encoding สามารถใช้หมายเลขเดียวกันสำหรับตัวอักขระสองตัวที่แตกต่างกัน," + "หรือใช้หมายเลขต่างกันสำหรับอักขระตัวเดียวกัน. ในระบบคอมพิวเตอร์ (โดยเฉพาะเซิร์ฟเวอร์) ต้องมีการสนับสนุนหลาย" + " encoding; และเมื่อข้อมูลที่ผ่านไปมาระหว่างการเข้ารหัสหรือแพล็ตฟอร์มที่ต่างกัน, ข้อมูลนั้นจะเสี่ยงต่อการผิดพลาดเสียหาย."
    var t1: T13512Thread = T13512Thread(thai)
    var t2: T13512Thread = T13512Thread(japanese)
    try:
t1.Start
t2.Start
t1.Join
t2.Join
    except Exception:
fail(e.ToString)
assertEquals("", t1.fExpectedBoundaries, t1.fBoundaries)
assertEquals("", t2.fExpectedBoundaries, t2.fBoundaries)
proc ICU4N_Issue95*() =
    var failingStrings = @[Encoding.UTF8.GetString(HexStringToByteArray("D2BCDFAAED96B3E18F86E28BAFE29298EFA1BBE9B2AEE7BEAD76")), Encoding.UTF8.GetString(HexStringToByteArray("F28DB9BC2CEB8C96F1B18880CAB9E59BB5E889ADDC8017")), Encoding.UTF8.GetString(HexStringToByteArray("D1AD13F0A5A29DE8B794CA80")), Encoding.UTF8.GetString(HexStringToByteArray("D0931DEFA897D687EE9D8FE68890E3B591F28A8888E7AFADD7B3C88E05")), Encoding.UTF8.GetString(HexStringToByteArray("EE8F87D78CEE8187F09EA3BC6DD896EFB98FE7B298E3A5A7EFB7AAEF9CBE"))]
    var cjkBreakIterator = BreakIterator.GetWordInstance(UCultureInfo.InvariantCulture)
    var random = Random
Parallel.For(0, 100000, <unhandled: nnkLambda>)
proc HexStringToByteArray(hex: string): byte[] =
    if string.IsNullOrWhiteSpace(hex):
      raise ArgumentException("Input string cannot be null or empty.")
    if hex.Length % 2 != 0:
      raise ArgumentException("Hex string must have an even length.")
    var bytes: byte[] = seq[byte]
      var i: int = 0
      while i < hex.Length:
          bytes[i / 2] = Convert.ToByte(hex.Substring(i, 2), 16)
          i = 2
    return bytes