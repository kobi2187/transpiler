# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationTest = ref object
    fcd: Normalizer2
    coll: Collator
    fileLine: String
    fileLineNumber: int
    fileTestName: String

proc newCollationTest(): CollationTest =

proc DoTest(test: TestFmwk, col: RuleBasedCollator, source: String, target: String, result: int) =
DoTestVariant(test, col, source, target, result)
    if result == -1:
DoTestVariant(test, col, target, source, 1)

    elif result == 1:
DoTestVariant(test, col, target, source, -1)
    else:
DoTestVariant(test, col, target, source, 0)
    var iter: CollationElementIterator = col.GetCollationElementIterator(source)
BackAndForth(test, iter)
iter.SetText(target)
BackAndForth(test, iter)
proc GetOrders(iter: CollationElementIterator): int[] =
    var maxSize: int = 100
    var size: int = 0
    var orders: int[] = seq[int]
    var order: int
    while     order = iter.Next != CollationElementIterator.NullOrder:
        if size == maxSize:
            maxSize = 2
            var temp: int[] = seq[int]
System.Array.Copy(orders, 0, temp, 0, size)
            orders = temp
        orders[++size] = order
    if maxSize > size:
        var temp: int[] = seq[int]
System.Array.Copy(orders, 0, temp, 0, size)
        orders = temp
    return orders
proc BackAndForth(test: TestFmwk, iter: CollationElementIterator) =
iter.Reset
    var orders: int[] = GetOrders(iter)
    var index: int = orders.Length
    var o: int
iter.Reset
    while     o = iter.Previous != CollationElementIterator.NullOrder:
        if o != orders[--index]:
            if o == 0:
++index
            else:
                while index > 0 && orders[index] == 0:
--index
                if o != orders[index]:
TestFmwk.Errln("Mismatch at index " + index + ": 0x" + Utility.Hex(orders[index]) + " vs 0x" + Utility.Hex(o))
                    break
    while index != 0 && orders[index - 1] == 0:
--index
    if index != 0:
        var msg: String = "Didn't get back to beginning - index is "
TestFmwk.Errln(msg + index)
iter.Reset
TestFmwk.Err("next: ")
        while         o = iter.Next != CollationElementIterator.NullOrder:
            var hexString: String = "0x" + Utility.Hex(o) + " "
TestFmwk.Err(hexString)
TestFmwk.Errln("")
TestFmwk.Err("prev: ")
        while         o = iter.Previous != CollationElementIterator.NullOrder:
            var hexString: String = "0x" + Utility.Hex(o) + " "
TestFmwk.Err(hexString)
TestFmwk.Errln("")
proc AppendCompareResult(result: int, target: String): String =
    if result == -1:
        target = "LESS"

    elif result == 0:
        target = "EQUAL"
    else:
      if result == 1:
          target = "GREATER"
      else:
          var huh: String = "?"
          target = huh + result
    return target
proc Prettify(key: CollationKey): String =
    var bytes: byte[] = key.ToByteArray
    return Prettify(bytes, bytes.Length)
proc Prettify(key: RawCollationKey): String =
    return Prettify(key.Bytes, key.Length)
proc Prettify(skBytes: seq[byte], length: int): String =
    var target: StringBuilder = StringBuilder(length * 3 + 2).Append('[')
      var i: int = 0
      while i < length:
          var numStr: String = skBytes[i] & 255.ToHexString
          if numStr.Length < 2:
target.Append('0')
target.Append(numStr).Append(' ')
++i
target.Append(']')
    return target.ToString
proc DoTestVariant(test: TestFmwk, myCollation: RuleBasedCollator, source: String, target: String, result: int) =
    var compareResult: int = myCollation.Compare(source, target)
    if compareResult != result:
TestFmwk.Errln("Comparing "" + Utility.Hex(source) + "" with "" + Utility.Hex(target) + "" expected " + result + " but got " + compareResult)
    var ssk: CollationKey = myCollation.GetCollationKey(source)
    var tsk: CollationKey = myCollation.GetCollationKey(target)
    compareResult = ssk.CompareTo(tsk)
    if compareResult != result:
TestFmwk.Errln("Comparing CollationKeys of "" + Utility.Hex(source) + "" with "" + Utility.Hex(target) + "" expected " + result + " but got " + compareResult)
    var srsk: RawCollationKey = RawCollationKey
myCollation.GetRawCollationKey(source, srsk)
    var trsk: RawCollationKey = RawCollationKey
myCollation.GetRawCollationKey(target, trsk)
    compareResult = ssk.CompareTo(tsk)
    if compareResult != result:
TestFmwk.Errln("Comparing RawCollationKeys of "" + Utility.Hex(source) + "" with "" + Utility.Hex(target) + "" expected " + result + " but got " + compareResult)
proc TestMinMax*() =
SetRootCollator
    var rbc: RuleBasedCollator = cast[RuleBasedCollator](coll)
    var s: String = "￾￿"
    var ces: long[]
    ces = rbc.InternalGetCEs(s.AsMemory)
    if ces.Length != 2:
Errln("expected 2 CEs for <FFFE, FFFF>, got " + ces.Length)
        return
    var ce: long = ces[0]
    var expected: long = Collation.MakeCE(Collation.MergeSeparatorPrimary)
    if ce != expected:
Errln("CE(U+fffe)=0x" + Utility.Hex(ce) + " != 02..")
    ce = ces[1]
    expected = Collation.MakeCE(Collation.MaxPrimary)
    if ce != expected:
Errln("CE(U+ffff)=0x" + Utility.Hex(ce) + " != max..")
proc TestImplicits*() =
    var cd: CollationData = CollationRoot.Data
    var coreHan: UnicodeSet = UnicodeSet("[\p{unified_ideograph}&" + "[\p{Block=CJK_Unified_Ideographs}" + "\p{Block=CJK_Compatibility_Ideographs}]]")
    var otherHan: UnicodeSet = UnicodeSet("[\p{unified ideograph}-" + "[\p{Block=CJK_Unified_Ideographs}" + "\p{Block=CJK_Compatibility_Ideographs}]]")
    var unassigned: UnicodeSet = UnicodeSet("[[:Cn:][:Cs:][:Co:]]")
unassigned.Remove(65534, 65535)
    var someHanInCPOrder: UnicodeSet = UnicodeSet("[\u4E00-\u4E16\u4E18-\u4E2B\u4E2D-\u4E3C\u4E3E-\u4E48" + "\u4E4A-\u4E60\u4E63-\u4E8F\u4E91-\u4F63\u4F65-\u50F1\u50F3-\u50F6]")
    var inOrder: UnicodeSet = UnicodeSet(someHanInCPOrder)
inOrder.AddAll(unassigned).Freeze
    var sets: UnicodeSet[] = @[coreHan, otherHan, unassigned]
    var prev: int = 0
    var prevPrimary: long = 0
    var ci: UTF16CollationIterator = UTF16CollationIterator(cd, false, "".AsMemory, 0)
      var i: int = 0
      while i < sets.Length:
          var iter: UnicodeSetIterator = UnicodeSetIterator(sets[i])
          while iter.Next:
              var s: string = iter.GetString
              var c: int = s.CodePointAt(0)
ci.SetText(false, s.AsMemory, 0)
              var ce: long = ci.NextCE
              var ce2: long = ci.NextCE
              if ce == Collation.NoCE || ce2 != Collation.NoCE:
Errln("CollationIterator.nextCE(0x" + Utility.Hex(c) + ") did not yield exactly one CE")
                  continue
              if ce & 4294967295 != Collation.CommonSecondaryAndTertiaryCE:
Errln("CollationIterator.nextCE(U+" + Utility.Hex(c, 4) + ") has non-common sec/ter weights: 0x" + Utility.Hex(ce & 4294967295, 8))
                  continue
              var primary: long = ce >>> 32
              if !primary > prevPrimary && inOrder.Contains(c) && inOrder.Contains(prev):
Errln("CE(U+" + Utility.Hex(c) + ")=0x" + Utility.Hex(primary) + ".. not greater than CE(U+" + Utility.Hex(prev) + ")=0x" + Utility.Hex(prevPrimary) + "..")
              prev = c
              prevPrimary = primary
++i
proc TestSubSequence*() =
    var data: CollationData = CollationRoot.Data
    var s: string = "abab"
    var ci1: UTF16CollationIterator = UTF16CollationIterator(data, false, s.AsMemory, 0)
    var ci2: UTF16CollationIterator = UTF16CollationIterator(data, false, s.AsMemory, 2)
      var i: int = 0
      while i < 2:
          var ce1: long = ci1.NextCE
          var ce2: long = ci2.NextCE
          if ce1 != ce2:
Errln("CollationIterator.nextCE(with start position at 0) != " + "nextCE(with start position at 2) at CE " + i)
++i
proc AddLeadSurrogatesForSupplementary(src: UnicodeSet, dest: UnicodeSet) =
      var c: int = 65536
      while c < 1114112:
          var next: int = c + 1024
          if src.ContainsSome(c, next - 1):
dest.Add(UTF16.GetLeadSurrogate(c))
          c = next
proc TestShortFCDData*() =
    var expectedLccc: UnicodeSet = UnicodeSet("[:^lccc=0:]")
expectedLccc.Add(56320, 57343)
AddLeadSurrogatesForSupplementary(expectedLccc, expectedLccc)
    var lccc: UnicodeSet = UnicodeSet
      var c: int = 0
      while c <= 65535:
          if CollationFCD.HasLccc(c):
lccc.Add(c)
++c
    var diff: UnicodeSet = UnicodeSet(expectedLccc)
diff.RemoveAll(lccc)
diff.Remove(65536, 1114111)
    var empty: String = "[]"
    var diffString: String
    diffString = diff.ToPattern(true)
assertEquals("CollationFCD::hasLccc() expected-actual", empty, diffString)
    diff = lccc
diff.RemoveAll(expectedLccc)
    diffString = diff.ToPattern(true)
assertEquals("CollationFCD::hasLccc() actual-expected", empty, diffString)
    var expectedTccc: UnicodeSet = UnicodeSet("[:^tccc=0:]")
AddLeadSurrogatesForSupplementary(expectedLccc, expectedTccc)
AddLeadSurrogatesForSupplementary(expectedTccc, expectedTccc)
    var tccc: UnicodeSet = UnicodeSet
      var c: int = 0
      while c <= 65535:
          if CollationFCD.HasTccc(c):
tccc.Add(c)
++c
    diff = UnicodeSet(expectedTccc)
diff.RemoveAll(tccc)
diff.Remove(65536, 1114111)
assertEquals("CollationFCD::hasTccc() expected-actual", empty, diffString)
    diff = tccc
diff.RemoveAll(expectedTccc)
    diffString = diff.ToPattern(true)
assertEquals("CollationFCD::hasTccc() actual-expected", empty, diffString)
type
  CodePointIterator = ref object
    cp: seq[int]
    length: int
    pos: int

proc newCodePointIterator(cp: seq[int]): CodePointIterator =
  self.cp = cp
  self.length = cp.Length
  self.pos = 0
proc ResetToStart() =
    pos = 0
proc Next(): int =
    return     if pos < length:
cp[++pos]
    else:
Collation.SentinelCodePoint
proc Previous(): int =
    return     if pos > 0:
cp[--pos]
    else:
Collation.SentinelCodePoint
proc Length(): int =
    return length
proc Index(): int =
    return pos
proc CheckFCD(name: String, ci: CollationIterator, cpi: CodePointIterator) =
      while true:
          var c1: int = ci.NextCodePoint
          var c2: int = cpi.Next
          if c1 != c2:
Errln(name + ".nextCodePoint(to limit, 1st pass) = U+" + Utility.Hex(c1) + " != U+" + Utility.Hex(c1) + " at " + cpi.Index)
              return
          if c1 < 0:
              break
      var n: int = cpi.Length * 2 / 3
      while n > 0:
          var c1: int = ci.PreviousCodePoint
          var c2: int = cpi.Previous
          if c1 != c2:
Errln(name + ".previousCodePoint() = U+" + Utility.Hex(c1) + " != U+" + Utility.Hex(c2) + " at " + cpi.Index)
              return
--n
      while true:
          var c1: int = ci.NextCodePoint
          var c2: int = cpi.Next
          if c1 != c2:
Errln(name + ".nextCodePoint(to limit again) = U+" + Utility.Hex(c1) + " != U+" + Utility.Hex(c2) + " at " + cpi.Index)
              return
          if c1 < 0:
              break
      while true:
          var c1: int = ci.PreviousCodePoint
          var c2: int = cpi.Previous
          if c1 != c2:
Errln(name + ".nextCodePoint(to start) = U+" + Utility.Hex(c1) + " != U+" + Utility.Hex(c2) + " at " + cpi.Index)
              return
          if c1 < 0:
              break
proc TestFCD*() =
    var data: CollationData = CollationRoot.Data
    var buf: StringBuilder = StringBuilder
buf.Append("̈áb̧́аb").AppendCodePoint(119135).Append("̧̈").AppendCodePoint(119149).AppendCodePoint(119135).AppendCodePoint(119149).Append("각").Append("ç").AppendCodePoint(119149).AppendCodePoint(119141).Append("á").Append("ཱཱིུ").Append("一ཱྀ")
    var s: String = buf.ToString
    var cp: int[] = @[776, 225, 98, 807, 769, 1072, 98, 119128, 807, 119141, 119149, 776, 119135, 119149, 44033, 99, 807, 119141, 119149, 97, 3953, 3953, 3954, 3956, 769, 19968, 3953, 3968]
    var u16ci: FCDUTF16CollationIterator = FCDUTF16CollationIterator(data, false, s.AsMemory, 0)
    var cpi: CodePointIterator = CodePointIterator(cp)
CheckFCD("FCDUTF16CollationIterator", u16ci, cpi)
cpi.ResetToStart
    var iter: UCharacterIterator = UCharacterIterator.GetInstance(s)
    var uici: FCDIterCollationIterator = FCDIterCollationIterator(data, false, iter, 0)
CheckFCD("FCDIterCollationIterator", uici, cpi)
proc CheckAllocWeights(cw: CollationWeights, lowerLimit: long, upperLimit: long, n: int, someLength: int, minCount: int) =
    if !cw.AllocWeights(lowerLimit, upperLimit, n):
Errln("CollationWeights::allocWeights(0x" + Utility.Hex(lowerLimit) + ",0x" + Utility.Hex(upperLimit) + "," + n + ") = false")
        return
    var previous: long = lowerLimit
    var count: int = 0
      var i: int = 0
      while i < n:
          var w: long = cw.NextWeight
          if w == 4294967295:
Errln("CollationWeights::allocWeights(0x" + Utility.Hex(lowerLimit) + ",0x" + Utility.Hex(upperLimit) + ",0x" + n + ").nextWeight() returns only " + i + " weights")
              return
          if !previous < w && w < upperLimit:
Errln("CollationWeights::allocWeights(0x" + Utility.Hex(lowerLimit) + ",0x" + Utility.Hex(upperLimit) + "," + n + ").nextWeight() number " + i + 1 + " -> 0x" + Utility.Hex(w) + " not between " + Utility.Hex(previous) + " and " + Utility.Hex(upperLimit))
              return
          if CollationWeights.LengthOfWeight(w) == someLength:
++count
++i
    if count < minCount:
Errln("CollationWeights::allocWeights(0x" + Utility.Hex(lowerLimit) + ",0x" + Utility.Hex(upperLimit) + "," + n + ").nextWeight() returns only " + count + " < " + minCount + " weights of length " + someLength)
proc TestCollationWeights*() =
    var cw: CollationWeights = CollationWeights
Logln("CollationWeights.initForPrimary(non-compressible)")
cw.InitForPrimary(false)
CheckAllocWeights(cw, 268435456, 318767104, 255, 1, 1)
CheckAllocWeights(cw, 268435456, 318767104, 255, 2, 254)
CheckAllocWeights(cw, 285146688, 302187264, 260, 2, 255)
CheckAllocWeights(cw, 285146688, 302187264, 600, 2, 254)
CheckAllocWeights(cw, 285212160, 302121728, 1 + 64516 + 254 + 1, 3, 64516)
CheckAllocWeights(cw, 285147136, 285474816, 2, 2, 2)
CheckAllocWeights(cw, 270597888, 270599168, 2, 3, 2)
Logln("CollationWeights.initForPrimary(compressible)")
cw.InitForPrimary(true)
CheckAllocWeights(cw, 268435456, 318767104, 252, 1, 1)
CheckAllocWeights(cw, 268435456, 318767104, 252, 2, 251)
CheckAllocWeights(cw, 285081152, 302318336, 260, 2, 252)
CheckAllocWeights(cw, 285081600, 285605888, 2, 2, 2)
CheckAllocWeights(cw, 270597888, 270599168, 2, 3, 2)
Logln("CollationWeights.initForSecondary()")
cw.InitForSecondary
CheckAllocWeights(cw, 64288, 65536, 20, 3, 4)
Logln("CollationWeights.initForTertiary()")
cw.InitForTertiary
CheckAllocWeights(cw, 15618, 16384, 10, 3, 2)
proc IsValidCE(re: CollationRootElements, data: CollationData, p: long, s: long, ctq: long): bool =
    var p1: long = p >>> 24
    var p2: long = p >>> 16 & 255
    var p3: long = p >>> 8 & 255
    var p4: long = p & 255
    var s1: long = s >>> 8
    var s2: long = s & 255
    var c: long = ctq & Collation.CaseMask >>> 14
    var t: long = ctq & Collation.OnlyTertiaryMask
    var t1: long = t >>> 8
    var t2: long = t & 255
    var q: long = ctq & Collation.QuaternaryMask
    if p != 0 && p1 == 0 || s != 0 && s1 == 0 || t != 0 && t1 == 0:
        return false
    if p1 != 0 && p2 == 0 && p & 65535 != 0:
        return false
    if p2 != 0 && p3 == 0 && p4 != 0:
        return false
    if p1 != 0 && p1 <= Collation.MergeSeparatorByte || s1 == Collation.LevelSeparatorByte || t1 == Collation.LevelSeparatorByte || t1 > 63:
        return false
    if c > 2:
        return false
    if p2 != 0:
        if data.IsCompressibleLeadByte(cast[int](p1)):
            if p2 <= Collation.PrimaryCompressionLowByte || Collation.PrimaryCompressionHighByte <= p2:
                return false
        else:
            if p2 <= Collation.LevelSeparatorByte:
                return false
    if p3 == Collation.LevelSeparatorByte || p4 == Collation.LevelSeparatorByte || s2 == Collation.LevelSeparatorByte || t2 == Collation.LevelSeparatorByte:
        return false
    if p == 0:
        if s == 0:
            if t == 0:
                if c != 0 || q != 0:
                    return false
            else:
                if t < re.TertiaryBoundary || c != 2:
                    return false
        else:
            if s < re.SecondaryBoundary || t == 0 || t >= re.TertiaryBoundary:
                return false
    else:
        if s == 0 || Collation.CommonWeight16 < s && s <= re.LastCommonSecondary || s >= re.SecondaryBoundary:
            return false
        if t == 0 || t >= re.TertiaryBoundary:
            return false
    return true
proc IsValidCE(re: CollationRootElements, data: CollationData, ce: long): bool =
    var p: long = ce >>> 32
    var secTer: long = ce & 4294967295
    return IsValidCE(re, data, p, secTer >>> 16, secTer & 65535)
type
  RootElementsIterator = ref object
    data: CollationData
    elements: seq[long]
    length: int
    pri: long
    secTer: long
    index: int

proc newRootElementsIterator(root: CollationData): RootElementsIterator =
  data = root
  elements = root.RootElements
  length = elements.Length
  pri = 0
  secTer = 0
  index = cast[int](elements[CollationRootElements.IX_FIRST_TERTIARY_INDEX])
proc Next(): bool =
    if index >= length:
        return false
    var p: long = elements[index]
    if p == CollationRootElements.PrimarySentinel:
        return false
    if p & CollationRootElements.SecondaryTertiaryDeltaFlag != 0:
++index
        secTer = p & ~CollationRootElements.SecondaryTertiaryDeltaFlag
        return true
    if p & CollationRootElements.PrimaryStepMask != 0:
        var step: int = cast[int](p) & CollationRootElements.PrimaryStepMask
        p = 4294967040
        if pri == p:
++index
            return Next
Debug.Assert(pri < p)
        var isCompressible: bool = data.IsCompressiblePrimary(pri)
        if pri & 65535 == 0:
            pri = Collation.IncTwoBytePrimaryByOffset(pri, isCompressible, step)
        else:
            pri = Collation.IncThreeBytePrimaryByOffset(pri, isCompressible, step)
        return true
++index
    pri = p
    if index == length:
        secTer = Collation.CommonSecondaryAndTertiaryCE
    else:
        secTer = elements[index]
        if secTer & CollationRootElements.SecondaryTertiaryDeltaFlag == 0:
            secTer = Collation.CommonSecondaryAndTertiaryCE
        else:
            secTer = ~CollationRootElements.SecondaryTertiaryDeltaFlag
            if secTer > Collation.CommonSecondaryAndTertiaryCE:
                secTer = Collation.CommonSecondaryAndTertiaryCE
            else:
++index
    return true
proc getPrimary(): long =
    return pri
proc getSecTer(): long =
    return secTer
proc TestRootElements*() =
    var root: CollationData = CollationRoot.Data
    var rootElements: CollationRootElements = CollationRootElements(root.RootElements)
    var iter: RootElementsIterator = RootElementsIterator(root)
    var cw1c: CollationWeights = CollationWeights
    var cw1u: CollationWeights = CollationWeights
    var cw2: CollationWeights = CollationWeights
    var cw3: CollationWeights = CollationWeights
cw1c.InitForPrimary(true)
cw1u.InitForPrimary(false)
cw2.InitForSecondary
cw3.InitForTertiary
    var prevPri: long = 0
    var prevSec: long = 0
    var prevTer: long = 0
    while iter.Next:
        var pri: long = iter.getPrimary
        var secTer: long = iter.getSecTer
        if secTer & Collation.CaseAndQuaternaryMask != 0:
Errln("CollationRootElements CE has non-zero case and/or quaternary bits: " + "0x" + Utility.Hex(pri, 8) + " 0x" + Utility.Hex(secTer, 8))
        var sec: long = secTer >>> 16
        var ter: long = secTer & Collation.OnlyTertiaryMask
        var ctq: long = ter
        if pri == 0 && sec == 0 && ter != 0:
            ctq = 32768
        if !IsValidCE(rootElements, root, pri, sec, ctq):
Errln("invalid root CE 0x" + Utility.Hex(pri, 8) + " 0x" + Utility.Hex(secTer, 8))
        else:
            if pri != prevPri:
                var newWeight: long = 0
                if prevPri == 0 || prevPri >= Collation.FFFD_Primary:


                elif root.IsCompressiblePrimary(prevPri):
                    if !cw1c.AllocWeights(prevPri, pri, 1):
Errln("no primary/compressible tailoring gap between " + "0x" + Utility.Hex(prevPri, 8) + " and 0x" + Utility.Hex(pri, 8))
                    else:
                        newWeight = cw1c.NextWeight
                else:
                    if !cw1u.AllocWeights(prevPri, pri, 1):
Errln("no primary/uncompressible tailoring gap between " + "0x" + Utility.Hex(prevPri, 8) + " and 0x" + Utility.Hex(pri, 8))
                    else:
                        newWeight = cw1u.NextWeight
                if newWeight != 0 && !prevPri < newWeight && newWeight < pri:
Errln("mis-allocated primary weight, should get " + "0x" + Utility.Hex(prevPri, 8) + " < 0x" + Utility.Hex(newWeight, 8) + " < 0x" + Utility.Hex(pri, 8))

            elif sec != prevSec:
                var lowerLimit: long =                 if prevSec == 0:
rootElements.SecondaryBoundary - 256
                else:
prevSec
                if !cw2.AllocWeights(lowerLimit, sec, 1):
Errln("no secondary tailoring gap between " + "0x" + Utility.Hex(lowerLimit) + " and 0x" + Utility.Hex(sec))
                else:
                    var newWeight: long = cw2.NextWeight
                    if !prevSec < newWeight && newWeight < sec:
Errln("mis-allocated secondary weight, should get " + "0x" + Utility.Hex(lowerLimit) + " < 0x" + Utility.Hex(newWeight) + " < 0x" + Utility.Hex(sec))
            else:
              if ter != prevTer:
                  var lowerLimit: long =                   if prevTer == 0:
rootElements.TertiaryBoundary - 256
                  else:
prevTer
                  if !cw3.AllocWeights(lowerLimit, ter, 1):
Errln("no tertiary tailoring gap between " + "0x" + Utility.Hex(lowerLimit) + " and 0x" + Utility.Hex(ter))
                  else:
                      var newWeight: long = cw3.NextWeight
                      if !prevTer < newWeight && newWeight < ter:
Errln("mis-allocated tertiary weight, should get " + "0x" + Utility.Hex(lowerLimit) + " < 0x" + Utility.Hex(newWeight) + " < 0x" + Utility.Hex(ter))
              else:
Errln("duplicate root CE 0x" + Utility.Hex(pri, 8) + " 0x" + Utility.Hex(secTer, 8))
        prevPri = pri
        prevSec = sec
        prevTer = ter
proc TestTailoredElements*() =
    var root: CollationData = CollationRoot.Data
    var rootElements: CollationRootElements = CollationRootElements(root.RootElements)
    var prevLocales: ISet<String> = HashSet<String>
prevLocales.Add("")
prevLocales.Add("root")
prevLocales.Add("root@collation=standard")
    var ces: long[]
    var locales: UCultureInfo[] = Collator.GetUCultures(UCultureTypes.AllCultures)
    var localeID: String = "root"
    var locIdx: int = 0
      while locIdx < locales.Length:
          var locale: UCultureInfo = UCultureInfo(localeID)
          var types: String[] = Collator.GetKeywordValuesForLocale("collation", locale, false)
            var typeIdx: int = 0
            while typeIdx < types.Length:
                var type: String = types[typeIdx]
                if type.StartsWith("private-", StringComparison.Ordinal):
Errln("Collator.getKeywordValuesForLocale(" + localeID + ") returns private collation keyword: " + type)
                var localeWithType: UCultureInfo = locale.SetKeywordValue("collation", type)
                var coll: Collator = Collator.GetInstance(localeWithType)
                var actual: UCultureInfo = coll.ActualCulture
                if prevLocales.Contains(actual.FullName):
                    continue
prevLocales.Add(actual.FullName)
Logln("TestTailoredElements(): requested " + localeWithType.FullName + " -> actual " + actual.FullName)
                if !coll is RuleBasedCollator:
                    continue
                var rbc: RuleBasedCollator = cast[RuleBasedCollator](coll)
                var tailored: UnicodeSet = coll.GetTailoredSet
                var iter: UnicodeSetIterator = UnicodeSetIterator(tailored)
                while iter.Next:
                    var s: string = iter.GetString
                    ces = rbc.InternalGetCEs(s.AsMemory)
                      var i: int = 0
                      while i < ces.Length:
                          var ce: long = ces[i]
                          if !IsValidCE(rootElements, root, ce):
Logln(Prettify(s))
Errln("invalid tailored CE 0x" + Utility.Hex(ce, 16) + " at CE index " + i + " from string:")
++i
++typeIdx
          localeID = locales[++locIdx].FullName
proc IsSpace(c: char): bool =
    return c == 9 || c == 32 || c == 12288
proc IsSectionStarter(c: char): bool =
    return c == '%' || c == '*' || c == '@'
proc SkipSpaces(i: int): int =
    while IsSpace(fileLine[i]):
++i
    return i
proc PrintSortKey(p: seq[byte]): String =
    var s: StringBuilder = StringBuilder
      var i: int = 0
      while i < p.Length:
          if i > 0:
s.Append(' ')
          var b: byte = p[i]
          if b == 0:
s.Append('.')

          elif b == 1:
s.Append('|')
          else:
s.Append(string.Format("{0:x2}", b & 255))
++i
    return s.ToString
proc PrintCollationKey(key: CollationKey): String =
    var p: byte[] = key.ToByteArray
    return PrintSortKey(p)
proc ReadNonEmptyLine(input: TextReader): bool =
      while true:
          var line: String = input.ReadLine
          if line == nil:
              fileLine = nil
              return false
          if fileLineNumber == 0 && line.Length != 0 && line[0] == '�':
              line = line.Substring(1)
++fileLineNumber
          var idx: int = line.IndexOf('#')
          if idx < 0:
              idx = line.Length
          while idx > 0 && IsSpace(line[idx - 1]):
--idx
          if idx != 0:
              fileLine =               if idx < line.Length:
line.Substring(0, idx - 0)
              else:
line
              return true
proc ParseString(start: int, prefix: String, s: String): int =
    var length: int = fileLine.Length
    var i: int
      i = start
      while i < length && !IsSpace(fileLine[i]):
++i
    var pipeIndex: int = fileLine.IndexOf('|', start)
    if pipeIndex >= 0 && pipeIndex < i:
        var tmpPrefix: String = Utility.Unescape(fileLine.Substring(start, pipeIndex - start))
        if tmpPrefix.Length == 0:
            prefix = nil
Logln(fileLine)
            raise FormatException("empty prefix on line " + fileLineNumber)
        prefix = tmpPrefix
        start = pipeIndex + 1
    else:
        prefix = nil
    var tmp: String = Utility.Unescape(fileLine.Substring(start, i - start))
    if tmp.Length == 0:
        s = nil
Logln(fileLine)
        raise FormatException("empty string on line " + fileLineNumber)
    s = tmp
    return i
proc ParseRelationAndString(s: String): CollationSortKeyLevel =
    var relation: CollationSortKeyLevel = CollationSortKeyLevel.Unspecified
    var start: int
    if fileLine[0] == '<':
        var second: char = fileLine[1]
        start = 2
        case second
        of cast[char](49):
            relation = CollationSortKeyLevel.Primary
            break
        of cast[char](50):
            relation = CollationSortKeyLevel.Secondary
            break
        of cast[char](51):
            relation = CollationSortKeyLevel.Tertiary
            break
        of cast[char](52):
            relation = CollationSortKeyLevel.Quaternary
            break
        of cast[char](99):
            relation = CollationSortKeyLevel.Case
            break
        of cast[char](105):
            relation = CollationSortKeyLevel.Identical
            break
        else:
            relation = CollationSortKeyLevel.Unspecified
            start = 1
            break

    elif fileLine[0] == '=':
        relation = CollationSortKeyLevel.Zero
        start = 1
    else:
        start = 0
    if start == 0 || !IsSpace(fileLine[start]):
Logln(fileLine)
        raise FormatException("no relation (= < <1 <2 <c <3 <4 <i) at beginning of line " + fileLineNumber)
    start = SkipSpaces(start)
    var prefixOut: String
    start = ParseString(start, prefixOut, s)
    if prefixOut != nil:
Logln(fileLine)
        raise FormatException("prefix string not allowed for test string: on line " + fileLineNumber)
    if start < fileLine.Length:
Logln(fileLine)
        raise FormatException("unexpected line contents after test string on line " + fileLineNumber)
    return relation
proc ParseAndSetAttribute() =
    var start: int = SkipSpaces(1)
    var equalPos: int = fileLine.IndexOf('=')
    if equalPos < 0:
        if fileLine.RegionMatches(start, "reorder", 0, 7, StringComparison.Ordinal):
ParseAndSetReorderCodes(start + 7)
            return
Logln(fileLine)
        raise FormatException("missing '=' on line " + fileLineNumber)
    var attrString: String = fileLine.Substring(start, equalPos - start)
    var valueString: String = fileLine.Substring(equalPos + 1)
    if attrString.Equals("maxVariable"):
        var max: int
        if valueString.Equals("space"):
            max = ReorderCodes.Space

        elif valueString.Equals("punct"):
            max = ReorderCodes.Punctuation
        else:
          if valueString.Equals("symbol"):
              max = ReorderCodes.Symbol

          elif valueString.Equals("currency"):
              max = ReorderCodes.Currency
          else:
Logln(fileLine)
              raise FormatException("invalid attribute value name on line " + fileLineNumber)
        if coll != nil:
            coll.MaxVariable = max
        fileLine = nil
        return
    var parsed: bool = true
    var rbc: RuleBasedCollator = cast[RuleBasedCollator](coll)
    if attrString.Equals("backwards"):
        if valueString.Equals("on"):
            if rbc != nil:
              rbc.IsFrenchCollation = true

        elif valueString.Equals("off"):
            if rbc != nil:
              rbc.IsFrenchCollation = false
        else:
          if valueString.Equals("default"):
              if rbc != nil:
rbc.SetFrenchCollationToDefault
          else:
              parsed = false

    elif attrString.Equals("alternate"):
        if valueString.Equals("non-ignorable"):
            if rbc != nil:
              rbc.IsAlternateHandlingShifted = false

        elif valueString.Equals("shifted"):
            if rbc != nil:
              rbc.IsAlternateHandlingShifted = true
        else:
          if valueString.Equals("default"):
              if rbc != nil:
rbc.SetAlternateHandlingToDefault
          else:
              parsed = false
    else:
      if attrString.Equals("caseFirst"):
          if valueString.Equals("upper"):
              if rbc != nil:
                rbc.IsUpperCaseFirst = true

          elif valueString.Equals("lower"):
              if rbc != nil:
                rbc.IsLowerCaseFirst = true
          else:
            if valueString.Equals("default"):
                if rbc != nil:
rbc.SetCaseFirstToDefault
            else:
                parsed = false

      elif attrString.Equals("caseLevel"):
          if valueString.Equals("on"):
              if rbc != nil:
                rbc.IsCaseLevel = true

          elif valueString.Equals("off"):
              if rbc != nil:
                rbc.IsCaseLevel = false
          else:
            if valueString.Equals("default"):
                if rbc != nil:
rbc.SetCaseLevelToDefault
            else:
                parsed = false
      else:
        if attrString.Equals("strength"):
            if valueString.Equals("primary"):
                if rbc != nil:
                  rbc.Strength = CollationStrength.Primary

            elif valueString.Equals("secondary"):
                if rbc != nil:
                  rbc.Strength = CollationStrength.Secondary
            else:
              if valueString.Equals("tertiary"):
                  if rbc != nil:
                    rbc.Strength = CollationStrength.Tertiary

              elif valueString.Equals("quaternary"):
                  if rbc != nil:
                    rbc.Strength = CollationStrength.Quaternary
              else:
                if valueString.Equals("identical"):
                    if rbc != nil:
                      rbc.Strength = CollationStrength.Identical

                elif valueString.Equals("default"):
                    if rbc != nil:
rbc.SetStrengthToDefault
                else:
                    parsed = false

        elif attrString.Equals("numeric"):
            if valueString.Equals("on"):
                if rbc != nil:
                  rbc.IsNumericCollation = true

            elif valueString.Equals("off"):
                if rbc != nil:
                  rbc.IsNumericCollation = false
            else:
              if valueString.Equals("default"):
                  if rbc != nil:
rbc.SetNumericCollationToDefault
              else:
                  parsed = false
        else:
Logln(fileLine)
            raise FormatException("invalid attribute name on line " + fileLineNumber)
    if !parsed:
Logln(fileLine)
        raise FormatException("invalid attribute value name or attribute=value combination on line " + fileLineNumber)
    fileLine = nil
proc ParseAndSetReorderCodes(start: int) =
    var reorderCodes: IList<int> = List<int>
    while start < fileLine.Length:
        start = SkipSpaces(start)
        var limit: int = start
        while limit < fileLine.Length && !IsSpace(fileLine[limit]):
++limit
        var name: String = fileLine.Substring(start, limit - start)
        var code: int = CollationRuleParser.GetReorderCode(name)
        if code < -1:
            if name.Equals("default", StringComparison.OrdinalIgnoreCase):
                code = ReorderCodes.Default
            else:
Logln(fileLine)
                raise FormatException("invalid reorder code '" + name + "' on line " + fileLineNumber)
reorderCodes.Add(code)
        start = limit
    if coll != nil:
        var reorderCodesArray: int[] = seq[int]
reorderCodes.CopyTo(reorderCodesArray, 0)
coll.SetReorderCodes(reorderCodesArray)
    fileLine = nil
proc BuildTailoring(input: TextReader) =
    var rules: StringBuilder = StringBuilder
    while ReadNonEmptyLine(input) && !IsSectionStarter(fileLine[0]):
rules.Append(Utility.Unescape(fileLine))
    try:
        coll = RuleBasedCollator(rules.ToString)
    except Exception:
Logln(rules.ToString)
Errln("RuleBasedCollator(rules) failed - " + e.ToString)
        coll = nil
proc SetRootCollator() =
    coll = Collator.GetInstance(UCultureInfo.InvariantCulture)
proc SetLocaleCollator() =
    coll = nil
    var locale: UCultureInfo = nil
    if fileLine.Length > 9:
        var localeID: String = fileLine.Substring(9)
        try:
            locale = UCultureInfo(localeID)
        except IllformedLocaleException:
            locale = nil
    if locale == nil:
Logln(fileLine)
Errln("invalid language tag on line " + fileLineNumber)
        return
Logln("creating a collator for locale ID " + locale.FullName)
    try:
        coll = Collator.GetInstance(locale)
    except Exception:
Errln("unable to create a collator for locale " + locale + " on line " + fileLineNumber + " - " + e)
proc NeedsNormalization(s: String): bool =
    if !fcd.IsNormalized(s):
        return true
    var index: int = 0
    while     index = s.IndexOf(cast[char](3953), index) >= 0:
        if ++index < s.Length:
            var c: char = s[index]
            if c == 3955 || c == 3957 || c == 3969:
                return true
    return false
proc GetCollationKey(norm: String, line: String, s: String, keyOut: CollationKey): bool =
    var key: CollationKey = coll.GetCollationKey(s)
    keyOut = key
    var keyBytes: byte[] = key.ToByteArray
    if keyBytes.Length == 0 || keyBytes[keyBytes.Length - 1] != 0:
Logln(fileTestName)
Logln(line)
Logln(PrintCollationKey(key))
Errln("Collator(" + norm + ").GetSortKey() wrote an empty or unterminated key")
        return false
    var numLevels: int = cast[int](coll.Strength)
    if numLevels < cast[int](CollationStrength.Identical):
++numLevels
    else:
        numLevels = 5
    if cast[RuleBasedCollator](coll).IsCaseLevel:
++numLevels
    var numLevelSeparators: int = 0
      var i: int = 0
      while i < keyBytes.Length - 1:
          var b: byte = keyBytes[i]
          if b == 0:
Logln(fileTestName)
Logln(line)
Logln(PrintCollationKey(key))
Errln("Collator(" + norm + ").GetSortKey() contains a 00 byte")
              return false
          if b == 1:
++numLevelSeparators
++i
    if numLevelSeparators != cast[int](numLevels) - 1:
Logln(fileTestName)
Logln(line)
Logln(PrintCollationKey(key))
Errln("Collator(" + norm + ").GetSortKey() has " + numLevelSeparators + " level separators for " + numLevels + " levels")
        return false
    return true
proc GetMergedCollationKey(s: String, key: CollationKey): bool =
    var mergedKey: CollationKey = nil
    var sLength: int = s.Length
    var segmentStart: int = 0
      var i: int = 0
      while true:
          if i == sLength:
              if segmentStart == 0:
                  return false

          elif s[i] != '�':
++i
              continue
          var tmpKey: CollationKey = coll.GetCollationKey(s.Substring(segmentStart, i - segmentStart))
          if mergedKey == nil:
              mergedKey = tmpKey
          else:
              mergedKey = mergedKey.Merge(tmpKey)
          if i == sLength:
              break
          segmentStart = ++i
    key = mergedKey
    return true
proc GetDifferenceLevel(prevKey: CollationKey, key: CollationKey, order: int, collHasCaseLevel: bool): CollationSortKeyLevel =
    if order == Collation.Equal:
        return CollationSortKeyLevel.Unspecified
    var prevBytes: byte[] = prevKey.ToByteArray
    var bytes: byte[] = key.ToByteArray
    var level: CollationSortKeyLevel = CollationSortKeyLevel.Primary
      var i: int = 0
      while true:
          var b: byte = prevBytes[i]
          if b != bytes[i]:
              break
          if b == Collation.LevelSeparatorByte:
++level
              if level == CollationSortKeyLevel.Case && !collHasCaseLevel:
++level
++i
    return level
proc CheckCompareTwo(norm: String, prevFileLine: String, prevString: String, s: String, expectedOrder: int, expectedLevel: CollationSortKeyLevel): bool =
    var prevKeyOut: CollationKey = nil
    var prevKey: CollationKey
    if !GetCollationKey(norm, fileLine, prevString, prevKeyOut):
        return false
    prevKey = prevKeyOut
    var keyOut: CollationKey
    var key: CollationKey
    if !GetCollationKey(norm, fileLine, s, keyOut):
        return false
    key = keyOut
    var order: int = coll.Compare(prevString, s)
    if order != expectedOrder:
Logln(fileTestName)
Logln(prevFileLine)
Logln(fileLine)
Logln(PrintCollationKey(prevKey))
Logln(PrintCollationKey(key))
Errln("line " + fileLineNumber + " Collator(" + norm + ").compare(previous, current) wrong order: " + order + " != " + expectedOrder)
        return false
    order = coll.Compare(s, prevString)
    if order != -expectedOrder:
Logln(fileTestName)
Logln(prevFileLine)
Logln(fileLine)
Logln(PrintCollationKey(prevKey))
Logln(PrintCollationKey(key))
Errln("line " + fileLineNumber + " Collator(" + norm + ").compare(current, previous) wrong order: " + order + " != " + -expectedOrder)
        return false
    order = prevKey.CompareTo(key)
    if order != expectedOrder:
Logln(fileTestName)
Logln(prevFileLine)
Logln(fileLine)
Logln(PrintCollationKey(prevKey))
Logln(PrintCollationKey(key))
Errln("line " + fileLineNumber + " Collator(" + norm + ").GetSortKey(previous, current).compareTo() wrong order: " + order + " != " + expectedOrder)
        return false
    var collHasCaseLevel: bool = cast[RuleBasedCollator](coll).IsCaseLevel
    var level: CollationSortKeyLevel = GetDifferenceLevel(prevKey, key, order, collHasCaseLevel)
    if order != Collation.Equal && expectedLevel != CollationSortKeyLevel.Unspecified:
        if level != expectedLevel:
Logln(fileTestName)
Logln(prevFileLine)
Logln(fileLine)
Logln(PrintCollationKey(prevKey))
Logln(PrintCollationKey(key))
Errln("line " + fileLineNumber + " Collator(" + norm + ").GetSortKey(previous, current).compareTo()=" + order + " wrong level: " + level + " != " + expectedLevel)
            return false
    var outPrevKey: CollationKey = prevKey
    var outKey: CollationKey = key
    if GetMergedCollationKey(prevString, outPrevKey) | GetMergedCollationKey(s, outKey):
        prevKey = outPrevKey
        key = outKey
        order = prevKey.CompareTo(key)
        if order != expectedOrder:
Logln(fileTestName)
Errln("line " + fileLineNumber + " Collator(" + norm + ").getCollationKey" + "(previous, current segments between U+FFFE)).merge().compareTo() wrong order: " + order + " != " + expectedOrder)
Logln(prevFileLine)
Logln(fileLine)
Logln(PrintCollationKey(prevKey))
Logln(PrintCollationKey(key))
            return false
        var mergedLevel: CollationSortKeyLevel = GetDifferenceLevel(prevKey, key, order, collHasCaseLevel)
        if order != Collation.Equal && expectedLevel != CollationSortKeyLevel.Unspecified:
            if mergedLevel != level:
Logln(fileTestName)
Errln("line " + fileLineNumber + " Collator(" + norm + ").getCollationKey" + "(previous, current segments between U+FFFE)).merge().compareTo()=" + order + " wrong level: " + mergedLevel + " != " + level)
Logln(prevFileLine)
Logln(fileLine)
Logln(PrintCollationKey(prevKey))
Logln(PrintCollationKey(key))
                return false
    return true
proc CheckCompareStrings(input: TextReader) =
    var prevFileLine: String = "(none)"
    var prevString: String = ""
    var sOut: String
    while ReadNonEmptyLine(input) && !IsSectionStarter(fileLine[0]):
        var relation: CollationSortKeyLevel
        try:
            relation = ParseRelationAndString(sOut)
        except FormatException:
Errln(pe.ToString)
            break
        if coll == nil:
            continue
        var s: String = sOut
        var expectedOrder: int =         if relation == CollationSortKeyLevel.Zero:
Collation.Equal
        else:
Collation.Less
        var expectedLevel: CollationSortKeyLevel = relation
        var isOk: bool = true
        if !NeedsNormalization(prevString) && !NeedsNormalization(s):
            coll.Decomposition = NormalizationMode.NoDecomposition
            isOk = CheckCompareTwo("normalization=off", prevFileLine, prevString, s, expectedOrder, expectedLevel)
        if isOk:
            coll.Decomposition = NormalizationMode.CanonicalDecomposition
            isOk = CheckCompareTwo("normalization=on", prevFileLine, prevString, s, expectedOrder, expectedLevel)
        if isOk && !nfd.IsNormalized(prevString) || !nfd.IsNormalized(s):
            var pn: String = nfd.Normalize(prevString)
            var n: String = nfd.Normalize(s)
            isOk = CheckCompareTwo("NFD input", prevFileLine, pn, n, expectedOrder, expectedLevel)
        prevFileLine = fileLine
        prevString = s
proc TestDataDriven*() =
    nfd = Normalizer2.NFDInstance
    fcd = Norm2AllModes.FCDNormalizer2
    var input: TextReader = nil
    try:
        input = TestUtil.GetDataReader("collationtest.txt", "UTF-8")
        while fileLine != nil || ReadNonEmptyLine(input):
            if !IsSectionStarter(fileLine[0]):
Logln(fileLine)
Errln("syntax error on line " + fileLineNumber)
                return
            if fileLine.StartsWith("** test: ", StringComparison.Ordinal):
                fileTestName = fileLine
Logln(fileLine)
                fileLine = nil

            elif fileLine.Equals("@ root"):
SetRootCollator
                fileLine = nil
            else:
              if fileLine.StartsWith("@ locale ", StringComparison.Ordinal):
SetLocaleCollator
                  fileLine = nil

              elif fileLine.Equals("@ rules"):
BuildTailoring(input)
              else:
                if fileLine[0] == '%' && fileLine.Length > 1 && IsSpace(fileLine[1]):
ParseAndSetAttribute

                elif fileLine.Equals("* compare"):
CheckCompareStrings(input)
                else:
Logln(fileLine)
Errln("syntax error on line " + fileLineNumber)
                    return
    except FormatException:
Errln(pe.ToString)
    except IOException:
Errln(e.Message)
    finally:
        try:
            if input != nil:
input.Dispose
        except IOException:
e.PrintStackTrace