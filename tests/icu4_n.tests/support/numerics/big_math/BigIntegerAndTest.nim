# "Namespace: ICU4N.Numerics.BigMath"
type
  BigIntegerAndTest = ref object


proc testZeroPos*() =
    var aBytes: byte[] = @[0]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = 0
    var bSign: int = 1
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testZeroNeg*() =
    var aBytes: byte[] = @[0]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = 0
    var bSign: int = -1
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testPosZero*() =
    var aBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var bBytes: byte[] = @[0]
    var aSign: int = 1
    var bSign: int = 0
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testNegPos*() =
    var aBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var bBytes: byte[] = @[0]
    var aSign: int = -1
    var bSign: int = 0
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testZeroZero*() =
    var aBytes: byte[] = @[0]
    var bBytes: byte[] = @[0]
    var aSign: int = 0
    var bSign: int = 0
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testZeroOne*() =
    var aNumber: BigInteger = BigInteger.Zero
    var bNumber: BigInteger = BigInteger.One
    var result: BigInteger = aNumber & bNumber
assertTrue("incorrect equality", result.Equals(BigInteger.Zero))
assertEquals("incorrect sign", 0, result.Sign)
proc testOneOne*() =
    var aNumber: BigInteger = BigInteger.One
    var bNumber: BigInteger = BigInteger.One
    var result: BigInteger = aNumber & bNumber
assertTrue("equality failed", result.Equals(BigInteger.One))
assertEquals("incorrect sign", 1, result.Sign)
proc testPosPosSameLength*() =
    var aBytes: byte[] = @[cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: sbyte[] = @[0, -128, 56, 100, 4, 4, 17, 37, 16, 1, 64, 1, 10, 3]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testPosPosFirstLonger*() =
    var aBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: sbyte[] = @[0, -2, -76, 88, 44, 1, 2, 17, 35, 16, 9, 2, 5, 6, 21]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testPosPosFirstShorter*() =
    var aBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var bBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: sbyte[] = @[0, -2, -76, 88, 44, 1, 2, 17, 35, 16, 9, 2, 5, 6, 21]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testNegNegSameLength*() =
    var aBytes: byte[] = @[cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: sbyte[] = @[-1, 1, 2, 3, 3, 0, 65, -96, -48, -124, -60, 12, -40, -31, 97]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testNegNegFirstLonger*() =
    var aBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: sbyte[] = @[-1, 127, -10, -57, -101, 1, 2, 2, 2, -96, -16, 8, -40, -59, 68, -88, -88, 16, 73]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testNegNegFirstShorter*() =
    var aBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var bBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: sbyte[] = @[-1, 127, -10, -57, -101, 1, 2, 2, 2, -96, -16, 8, -40, -59, 68, -88, -88, 16, 73]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testPosNegSameLength*() =
    var aBytes: byte[] = @[cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: sbyte[] = @[0, -6, -80, 72, 8, 75, 2, -79, 34, 16, -119]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testNegPosSameLength*() =
    var aBytes: byte[] = @[cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: sbyte[] = @[0, -2, 125, -60, -104, 1, 10, 6, 2, 32, 56, 2, 4, 4, 21]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testNegPosFirstLonger*() =
    var aBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: sbyte[] = @[73, -92, -48, 4, 12, 6, 4, 32, 48, 64, 0, 8, 3]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testNegPosFirstShorter*() =
    var aBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var bBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: sbyte[] = @[0, -128, 9, 56, 100, 0, 0, 1, 1, 90, 1, -32, 0, 10, -126, 21, 82, -31, -95]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testPosNegFirstLonger*() =
    var aBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: sbyte[] = @[0, -128, 9, 56, 100, 0, 0, 1, 1, 90, 1, -32, 0, 10, -126, 21, 82, -31, -95]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testPosNegFirstShorter*() =
    var aBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var bBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: sbyte[] = @[73, -92, -48, 4, 12, 6, 4, 32, 48, 64, 0, 8, 3]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testSpecialCase1*() =
    var aBytes: byte[] = @[cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1)]
    var bBytes: byte[] = @[5, cast[byte](-4), cast[byte](-3), cast[byte](-2)]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: sbyte[] = @[-1, 0, 0, 0, 0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testSpecialCase2*() =
    var aBytes: byte[] = @[cast[byte](-51)]
    var bBytes: byte[] = @[cast[byte](-52), cast[byte](-51), cast[byte](-50), cast[byte](-49), cast[byte](-48)]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: sbyte[] = @[0, -52, -51, -50, -49, 16]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber & bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, result.Sign)