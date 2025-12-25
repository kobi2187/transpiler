# "Namespace: ICU4N.Numerics.BigMath"
type
  BigIntegerCompareTest = ref object


proc testAbsPositive*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var aSign: int = 1
    var rBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.Abs(aNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testAbsNegative*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var aSign: int = -1
    var rBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.Abs(aNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCompareToPosPos1*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = 1
    var bSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
assertEquals("incorrect result", 1, BigInteger.Compare(aNumber, bNumber))
proc testCompareToPosPos2*() =
    var aBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var bBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var bSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
assertEquals("incorrect result", -1, BigInteger.Compare(aNumber, bNumber))
proc testCompareToEqualPos*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var bBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var bSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
assertEquals("incorrect result", 0, BigInteger.Compare(aNumber, bNumber))
proc testCompareToNegNeg1*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = -1
    var bSign: int = -1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
assertEquals("incorrect result", -1, BigInteger.Compare(aNumber, bNumber))
proc testCompareNegNeg2*() =
    var aBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var bBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = -1
    var bSign: int = -1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
assertEquals("incorrect result", 1, BigInteger.Compare(aNumber, bNumber))
proc testCompareToEqualNeg*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var bBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = -1
    var bSign: int = -1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
assertEquals("incorrect result", 0, BigInteger.Compare(aNumber, bNumber))
proc testCompareToDiffSigns1*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = 1
    var bSign: int = -1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
assertEquals("incorrect result", 1, BigInteger.Compare(aNumber, bNumber))
proc testCompareToDiffSigns2*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = -1
    var bSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
assertEquals("incorrect result", -1, BigInteger.Compare(aNumber, bNumber))
proc testCompareToPosZero*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger.Zero
assertEquals("incorrect result", 1, BigInteger.Compare(aNumber, bNumber))
proc testCompareToZeroPos*() =
    var bBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var bSign: int = 1
    var aNumber: BigInteger = BigInteger.Zero
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
assertEquals("incorrect result", -1, BigInteger.Compare(aNumber, bNumber))
proc testCompareToNegZero*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = -1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger.Zero
assertEquals("incorrect result", -1, BigInteger.Compare(aNumber, bNumber))
proc testCompareToZeroNeg*() =
    var bBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var bSign: int = -1
    var aNumber: BigInteger = BigInteger.Zero
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
assertEquals("incorrect result", 1, BigInteger.Compare(aNumber, bNumber))
proc testCompareToZeroZero*() =
    var aNumber: BigInteger = BigInteger.Zero
    var bNumber: BigInteger = BigInteger.Zero
assertEquals("incorrect result", 0, BigInteger.Compare(aNumber, bNumber))
proc testEqualsObject*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var obj: Object = Object
assertFalse("incorrect result", aNumber.Equals(obj))
proc testEqualsNull*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
assertFalse("incorrect result", aNumber.Equals(nil))
proc testEqualsBigIntegerTrue*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var bBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var bSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: Object = BigInteger(bSign, bBytes)
assertTrue("incorrect result", aNumber.Equals(bNumber))
proc testEqualsBigIntegerFalse*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var bBytes: byte[] = @[45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var bSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: Object = BigInteger(bSign, bBytes)
assertFalse("incorrect result", aNumber.Equals(bNumber))
proc testMaxGreater*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var bBytes: byte[] = @[45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: sbyte[] = @[12, 56, 100, -2, -76, 89, 45, 91, 3, -15, 35, 26, 3, 91]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Max(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertTrue("incorrect sign", result.Sign == 1)
proc testMaxLess*() =
    var aBytes: byte[] = @[45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var bBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: sbyte[] = @[12, 56, 100, -2, -76, 89, 45, 91, 3, -15, 35, 26, 3, 91]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Max(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertTrue("incorrect sign", result.Sign == 1)
proc testMaxEqual*() =
    var aBytes: byte[] = @[45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var bBytes: byte[] = @[45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: sbyte[] = @[45, 91, 3, -15, 35, 26, 3, 91]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Max(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testMaxNegZero*() =
    var aBytes: byte[] = @[45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = -1
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger.Zero
    var result: BigInteger = BigInteger.Max(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertTrue("incorrect sign", result.Sign == 0)
proc testMinGreater*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var bBytes: byte[] = @[45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: sbyte[] = @[45, 91, 3, -15, 35, 26, 3, 91]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Min(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testMinLess*() =
    var aBytes: byte[] = @[45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var bBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: sbyte[] = @[45, 91, 3, -15, 35, 26, 3, 91]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Min(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testMinEqual*() =
    var aBytes: byte[] = @[45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var bBytes: byte[] = @[45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: sbyte[] = @[45, 91, 3, -15, 35, 26, 3, 91]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Min(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertTrue("incorrect sign", result.Sign == 1)
proc testMinPosZero*() =
    var aBytes: byte[] = @[45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger.Zero
    var result: BigInteger = BigInteger.Min(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertTrue("incorrect sign", result.Sign == 0)
proc testNegatePositive*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var rBytes: sbyte[] = @[-13, -57, -101, 1, 75, -90, -46, -92, -4, 14, -36, -27, -4, -91]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = -aNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertTrue("incorrect sign", result.Sign == -1)
proc testNegateNegative*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = -1
    var rBytes: sbyte[] = @[12, 56, 100, -2, -76, 89, 45, 91, 3, -15, 35, 26, 3, 91]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = -aNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertTrue("incorrect sign", result.Sign == 1)
proc testNegateZero*() =
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger.Zero
    var result: BigInteger = -aNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testSignumPositive*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testSignumNegative*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = -1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testSignumZero*() =
    var aNumber: BigInteger = BigInteger.Zero
assertEquals("incorrect sign", 0, aNumber.Sign)