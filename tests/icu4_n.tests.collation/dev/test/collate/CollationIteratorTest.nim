# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationIteratorTest = ref object
    test1: String = "What subset of all possible test cases?"
    test2: String = "has the highest probability of detecting"

proc TestClearBuffers*() =
    var c: RuleBasedCollator = nil
    try:
        c = RuleBasedCollator("&a < b < c & ab = d")
    except Exception:
Warnln("Couldn't create a RuleBasedCollator.")
        return
    var source: String = "abcd"
    var i: CollationElementIterator = c.GetCollationElementIterator(source)
    var e0: int = 0
    try:
        e0 = i.Next
    except Exception:
Errln("call to i.Next() failed.")
        return
    try:
i.SetOffset(3)
    except Exception:
Errln("call to i.setOffset(3) failed.")
        return
    try:
i.Next
    except Exception:
Errln("call to i.Next() failed.")
        return
    try:
i.SetOffset(0)
    except Exception:
Errln("call to i.setOffset(0) failed. ")
      var e: int = 0
      try:
          e = i.Next
      except Exception:
Errln("call to i.Next() failed. ")
          return
      if e != e0:
Errln("got 0x" + e.ToHexString + ", expected 0x" + e0.ToHexString)
proc TestMaxExpansion*() =
    var unassigned: int = 983037
    var rule: String = "&a < ab < c/aba < d < z < ch"
    var coll: RuleBasedCollator = nil
    try:
        coll = RuleBasedCollator(rule)
    except Exception:
Warnln("Fail to create RuleBasedCollator")
        return
    var ch: char = cast[char](0)
    var str: String = ch + ""
    var iter: CollationElementIterator = coll.GetCollationElementIterator(str)
    while ch < 65535:
        var count: int = 1
++ch
        str = ch + ""
iter.SetText(str)
        var order: int = iter.Previous
        if order == 0:
            order = iter.Previous
        while iter.Previous != CollationElementIterator.NullOrder:
++count
        if iter.GetMaxExpansion(order) < count:
Errln("Failure at codepoint " + ch + ", maximum expansion count < " + count)
    ch = cast[char](0)
    while ch < 97:
        str = ch + ""
iter.SetText(str)
        var order: int = iter.Previous
        if iter.GetMaxExpansion(order) != 1:
Errln("Failure at codepoint 0x" + ch.ToHexString + " maximum expansion count == 1")
++ch
    ch = cast[char](99)
    str = ch + ""
iter.SetText(str)
    var temporder: int = iter.Previous
    if iter.GetMaxExpansion(temporder) != 3:
Errln("Failure at codepoint 0x" + ch.ToHexString + " maximum expansion count == 3")
    ch = cast[char](100)
    str = ch + ""
iter.SetText(str)
    temporder = iter.Previous
    if iter.GetMaxExpansion(temporder) != 1:
Errln("Failure at codepoint 0x" + ch.ToHexString + " maximum expansion count == 1")
    str = UChar.ConvertFromUtf32(unassigned)
iter.SetText(str)
    temporder = iter.Previous
    if iter.GetMaxExpansion(temporder) != 2:
Errln("Failure at codepoint 0x" + ch.ToHexString + " maximum expansion count == 2")
    ch = cast[char](4453)
    str = ch + ""
iter.SetText(str)
    temporder = iter.Previous
    if iter.GetMaxExpansion(temporder) > 3:
Errln("Failure at codepoint 0x" + ch.ToHexString + " maximum expansion count < 3")
    rule = "&q<ᅥ/qqqq"
    try:
        coll = RuleBasedCollator(rule)
    except Exception:
Errln("Fail to create RuleBasedCollator")
        return
    iter = coll.GetCollationElementIterator(str)
    temporder = iter.Previous
    if iter.GetMaxExpansion(temporder) != 6:
Errln("Failure at codepoint 0x" + ch.ToHexString + " maximum expansion count == 6")
proc TestOffset*() =
    var en_us: RuleBasedCollator
    try:
        en_us = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    except Exception:
Warnln("ERROR: in creation of collator of ENGLISH locale")
        return
    var iter: CollationElementIterator = en_us.GetCollationElementIterator(test1)
iter.SetOffset(0)
    if iter.Previous != CollationElementIterator.NullOrder:
Errln("Error: After setting offset to 0, we should be at the end " + "of the backwards iteration")
iter.SetOffset(test1.Length)
    if iter.Next != CollationElementIterator.NullOrder:
Errln("Error: After setting offset to the end of the string, we " + "should be at the end of the forwards iteration")
    var orders: int[] = CollationTest.GetOrders(iter)
Logln("orders.Length = " + orders.Length)
    var offset: int = iter.GetOffset
    if offset != test1.Length:
        var msg1: String = "offset at end != length: "
        var msg2: String = " vs "
Errln(msg1 + offset + msg2 + test1.Length)
    var pristine: CollationElementIterator = en_us.GetCollationElementIterator(test1)
    try:
iter.SetOffset(0)
    except Exception:
Errln("setOffset failed.")
assertEqual(iter, pristine)
    var contraction: String = "change"
    var tailored: RuleBasedCollator = nil
    try:
        tailored = RuleBasedCollator("& a < ch")
    except Exception:
Errln("Error: in creation of Spanish collator")
        return
    iter = tailored.GetCollationElementIterator(contraction)
    var order: int[] = CollationTest.GetOrders(iter)
iter.SetOffset(1)
    var order2: int[] = CollationTest.GetOrders(iter)
    if !ArrayEqualityComparer[int].OneDimensional.Equals(order, order2):
Errln("Error: setting offset in the middle of a contraction should be the same as setting it to the start of the contraction")
    contraction = "peache"
    iter = tailored.GetCollationElementIterator(contraction)
iter.SetOffset(3)
    order = CollationTest.GetOrders(iter)
iter.SetOffset(4)
    order2 = CollationTest.GetOrders(iter)
    if !ArrayEqualityComparer[int].OneDimensional.Equals(order, order2):
Errln("Error: setting offset in the middle of a contraction should be the same as setting it to the start of the contraction")
    var surrogate: String = "𐀀str"
    iter = tailored.GetCollationElementIterator(surrogate)
    order = CollationTest.GetOrders(iter)
iter.SetOffset(1)
    order2 = CollationTest.GetOrders(iter)
    if !ArrayEqualityComparer[int].OneDimensional.Equals(order, order2):
Errln("Error: setting offset in the middle of a surrogate pair should be the same as setting it to the start of the surrogate pair")
    surrogate = "simple𐀀str"
    iter = tailored.GetCollationElementIterator(surrogate)
iter.SetOffset(6)
    order = CollationTest.GetOrders(iter)
iter.SetOffset(7)
    order2 = CollationTest.GetOrders(iter)
    if !ArrayEqualityComparer[int].OneDimensional.Equals(order, order2):
Errln("Error: setting offset in the middle of a surrogate pair should be the same as setting it to the start of the surrogate pair")
proc assertEqual(i1: CollationElementIterator, i2: CollationElementIterator) =
      var c1: int
      var c2: int
      var count: int = 0
    while true:
        c1 = i1.Next
        c2 = i2.Next
        if c1 != c2:
Errln("    " + count + ": strength(0x" + c1.ToHexString + ") != strength(0x" + c2.ToHexString + ")")
            break
        count = 1
        if notc1 != CollationElementIterator.NullOrder:
            break
CollationTest.BackAndForth(self, i1)
CollationTest.BackAndForth(self, i2)
proc TestPrevious*() =
    var en_us: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    var iter: CollationElementIterator = en_us.GetCollationElementIterator(test1)
CollationTest.BackAndForth(self, iter)
    var source: String
    var c1: RuleBasedCollator = nil
    try:
        c1 = RuleBasedCollator("&a,A < b,B < c,C, d,D < z,Z < ch,cH,Ch,CH")
    except Exception:
Errln("Couldn't create a RuleBasedCollator with a contracting sequence.")
        return
    source = "abchdcba"
    iter = c1.GetCollationElementIterator(source)
CollationTest.BackAndForth(self, iter)
    var c2: RuleBasedCollator = nil
    try:
        c2 = RuleBasedCollator("&a < b < c/abd < d")
    except Exception:
Errln("Couldn't create a RuleBasedCollator with an expanding sequence.")
        return
    source = "abcd"
    iter = c2.GetCollationElementIterator(source)
CollationTest.BackAndForth(self, iter)
    var c3: RuleBasedCollator = nil
    try:
        c3 = RuleBasedCollator("&a < b < c/aba < d < z < ch")
    except Exception:
Errln("Couldn't create a RuleBasedCollator with both an expanding and a contracting sequence.")
        return
    source = "abcdbchdc"
    iter = c3.GetCollationElementIterator(source)
CollationTest.BackAndForth(self, iter)
    source = "แขแขวabc"
    var c4: Collator = nil
    try:
        c4 = Collator.GetInstance(CultureInfo("th-TH"))
    except Exception:
Errln("Couldn't create a collator")
        return
    iter = cast[RuleBasedCollator](c4).GetCollationElementIterator(source)
CollationTest.BackAndForth(self, iter)
    source = "aバー"
    var c5: Collator = nil
    try:
        c5 = Collator.GetInstance(CultureInfo("ja-JP"))
    except Exception:
Errln("Couldn't create Japanese collator
")
        return
    iter = cast[RuleBasedCollator](c5).GetCollationElementIterator(source)
CollationTest.BackAndForth(self, iter)
proc TestSetText*() =
    var en_us: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    var iter1: CollationElementIterator = en_us.GetCollationElementIterator(test1)
    var iter2: CollationElementIterator = en_us.GetCollationElementIterator(test2)
    var c: int = iter2.Next
    var i: int = 0
    while ++i < 10 && c != CollationElementIterator.NullOrder:
        try:
            c = iter2.Next
        except Exception:
Errln("iter2.Next() returned an error.")
            break
    try:
iter2.SetText(test1)
    except Exception:
Errln("call to iter2->setText(test1) failed.")
        return
assertEqual(iter1, iter2)
iter1.Reset
    var chariter: CharacterIterator = StringCharacterIterator(test1)
    try:
iter2.SetText(chariter)
    except Exception:
Errln("call to iter2->setText(chariter(test1)) failed.")
        return
assertEqual(iter1, iter2)
iter1.Reset
    var uchariter: UCharacterIterator = UCharacterIterator.GetInstance(test1)
    try:
iter2.SetText(uchariter)
    except Exception:
Errln("call to iter2->setText(uchariter(test1)) failed.")
        return
assertEqual(iter1, iter2)
proc TestUnicodeChar*() =
    var en_us: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    var iter: CollationElementIterator
    var codepoint: char
    var source: StringBuffer = StringBuffer
source.Append("ํ๎๏")
    iter = en_us.GetCollationElementIterator(source.ToString)
CollationTest.BackAndForth(self, iter)
      codepoint = cast[char](1)
      while codepoint < 65534:
source.Delete(0, source.Length - 0)
          while codepoint % 255 != 0:
              if UChar.IsDefined(codepoint):
source.Append(codepoint)
++codepoint
          if UChar.IsDefined(codepoint):
source.Append(codepoint)
          if codepoint != 65535:
++codepoint
          iter = en_us.GetCollationElementIterator(source.ToString)
CollationTest.BackAndForth(self, iter)
proc TestNormalizedUnicodeChar*() =
    var th_th: RuleBasedCollator = nil
    try:
        th_th = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("th-TH")))
    except Exception:
Warnln("Error creating Thai collator")
        return
    var source: StringBuffer = StringBuffer
source.Append('�')
    var iter: CollationElementIterator = th_th.GetCollationElementIterator(source.ToString)
CollationTest.BackAndForth(self, iter)
      var codepoint: char = cast[char](1)
      while codepoint < 65534:
source.Delete(0, source.Length - 0)
          while codepoint % 255 != 0:
              if UChar.IsDefined(codepoint):
source.Append(codepoint)
++codepoint
          if UChar.IsDefined(codepoint):
source.Append(codepoint)
          if codepoint != 65535:
++codepoint
          iter = th_th.GetCollationElementIterator(source.ToString)
CollationTest.BackAndForth(self, iter)
proc TestDiscontiguous*() =
    var rulestr: String = "&z < AB < X̀ < ABC < X̀̕"
    var src: String[] = @["ADB", "ADBC", "A̕B", "A̕BC", "XD̀", "XD̀̕", "X̙̀", "X̙̀̕", "X̔̀", "X̔̀̕", "ABDC", "AB̕C", "X̀D̕", "X̙̀̕", "X̀̚̕", "X̙̀D", "X̙̀̕D", "X̀D̕D", "X̙̀̕D", "X̀̚̕D"]
    var tgt: String[] = @["A D B", "A D BC", "A ̕ B", "A ̕ BC", "X D ̀", "X D ̀̕", "X̀ ̙", "X̀̕ ̙", "X ̔ ̀", "X ̔ ̀̕", "AB DC", "AB ̕ C", "X̀ D ̕", "X̀̕ ̙", "X̀ ̚ ̕", "X̀ ̙D", "X̀̕ ̙D", "X̀ D̕D", "X̀̕ ̙D", "X̀ ̚̕D"]
    var count: int = 0
    try:
        var coll: RuleBasedCollator = RuleBasedCollator(rulestr)
        var iter: CollationElementIterator = coll.GetCollationElementIterator("")
        var resultiter: CollationElementIterator = coll.GetCollationElementIterator("")
        while count < src.Length:
iter.SetText(src[count])
            var s: int = 0
            while s < tgt[count].Length:
                var e: int = tgt[count].IndexOf(' ', s)
                if e < 0:
                    e = tgt[count].Length
                var resultstr: String = tgt[count].Substring(s, e - s)
resultiter.SetText(resultstr)
                var ce: int = resultiter.Next
                while ce != CollationElementIterator.NullOrder:
                    if ce != iter.Next:
Errln("Discontiguos contraction test mismatch at" + count)
                        return
                    ce = resultiter.Next
                s = e + 1
iter.Reset
CollationTest.BackAndForth(self, iter)
++count
    except Exception:
Warnln("Error running discontiguous tests " + e.ToString)
proc TestNormalization*() =
    var rules: String = "&a < ̀̕ < À̕ < ̖̕B < ̖̀̕"
    var testdata: String[] = @["ộ", "ộ", "̀̕", "̀̕", "À̕B", "À̕B", "A̖̕B", "A̖̕B", "̖̀̕", "̖̀̕", "À̖̕B", "À̖̕B", "̖̀̕", "À̖̕B"]
    var coll: RuleBasedCollator = nil
    try:
        coll = RuleBasedCollator(rules)
        coll.Decomposition = NormalizationMode.CanonicalDecomposition
    except Exception:
Warnln("ERROR: in creation of collator using rules " + rules)
        return
    var iter: CollationElementIterator = coll.GetCollationElementIterator("testing")
      var count: int = 0
      while count < testdata.Length:
iter.SetText(testdata[count])
CollationTest.BackAndForth(self, iter)
++count
type
  TSCEItem = ref object
    localeString: String
    offsets: seq[int]

proc newTSCEItem(locStr: String, offs: seq[int]): TSCEItem =
  localeString = locStr
  offsets = offs
proc LocaleString(): String =
    return localeString
proc GetOffsets*(): int[] =
    return offsets
proc TestSearchCollatorElements*() =
    var tsceText: String = " 가" + " 각" + " 갏" + " 꿿" + " 각" + " ㄱㅏㄱ" + " 갏" + " 꿿" + " æ" + " ṍ" + " "
    var rootStandardOffsets: int[] = @[0, 1, 2, 2, 3, 4, 4, 4, 5, 6, 6, 6, 7, 8, 8, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 26, 27, 28, 28, 28, 29]
    var rootSearchOffsets: int[] = @[0, 1, 2, 2, 3, 4, 4, 4, 5, 6, 6, 6, 6, 7, 8, 8, 8, 8, 8, 8, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 21, 22, 22, 23, 23, 23, 24, 24, 25, 26, 26, 27, 28, 28, 28, 29]
    var tsceItems: TSCEItem[] = @[TSCEItem("root", rootStandardOffsets), TSCEItem("root@collation=search", rootSearchOffsets)]
    for tsceItem in tsceItems:
        var localeString: String = tsceItem.LocaleString
        var uloc: UCultureInfo = UCultureInfo(localeString)
        var col: RuleBasedCollator = nil
        try:
            col = cast[RuleBasedCollator](Collator.GetInstance(uloc))
        except Exception:
Errln("Error: in locale " + localeString + ", err in Collator.getInstance")
            continue
        var uce: CollationElementIterator = col.GetCollationElementIterator(tsceText)
        var offsets: int[] = tsceItem.GetOffsets
          var ioff: int
          var noff: int = offsets.Length
          var offset: int
          var element: int
        ioff = 0
        while true:
            offset = uce.GetOffset
            element = uce.Next
Logln(String.Format("({0}) offset={1:d2}  ce={2:x8}
", tsceItem.LocaleString, offset, element))
            if element == 0:
Errln("Error: in locale " + localeString + ", CEIterator next() returned element 0")
            if ioff < noff:
                if offset != offsets[ioff]:
Errln("Error: in locale " + localeString + ", expected CEIterator next()->getOffset " + offsets[ioff] + ", got " + offset)
++ioff
            else:
Errln("Error: in locale " + localeString + ", CEIterator next() returned more elements than expected")
            if notelement != CollationElementIterator.NullOrder:
                break
        if ioff < noff:
Errln("Error: in locale " + localeString + ", CEIterator next() returned fewer elements than expected")
uce.SetOffset(tsceText.Length)
        ioff = noff
        while true:
            offset = uce.GetOffset
            element = uce.Previous
            if element == 0:
Errln("Error: in locale " + localeString + ", CEIterator previous() returned element 0")
            if ioff > 0:
--ioff
                if offset != offsets[ioff]:
Errln("Error: in locale " + localeString + ", expected CEIterator previous()->getOffset " + offsets[ioff] + ", got " + offset)
            else:
Errln("Error: in locale " + localeString + ", CEIterator previous() returned more elements than expected")
            if notelement != CollationElementIterator.NullOrder:
                break
        if ioff > 0:
Errln("Error: in locale " + localeString + ", CEIterator previous() returned fewer elements than expected")