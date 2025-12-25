# "Namespace: ICU4N.Numerics.BigMath"
type
  BigIntegerOrTest = ref object


proc testZeroPos*() =
    var aBytes: byte[] = @[0]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = 0
    var bSign: int = 1
    var rBytes: byte[] = @[0, cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testZeroNeg*() =
    var aBytes: byte[] = @[0]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = 0
    var bSign: int = -1
    var rBytes: byte[] = @[cast[byte](-1), 1, 2, 3, 3, cast[byte](-6), cast[byte](-15), cast[byte](-24), cast[byte](-40), cast[byte](-49), cast[byte](-58), cast[byte](-67), cast[byte](-6), cast[byte](-15), cast[byte](-23)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testPosZero*() =
    var aBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var bBytes: byte[] = @[0]
    var aSign: int = 1
    var bSign: int = 0
    var rBytes: byte[] = @[0, cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testNegPos*() =
    var aBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var bBytes: byte[] = @[0]
    var aSign: int = -1
    var bSign: int = 0
    var rBytes: byte[] = @[cast[byte](-1), 1, 2, 3, 3, cast[byte](-6), cast[byte](-15), cast[byte](-24), cast[byte](-40), cast[byte](-49), cast[byte](-58), cast[byte](-67), cast[byte](-6), cast[byte](-15), cast[byte](-23)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testZeroZero*() =
    var aBytes: byte[] = @[0]
    var bBytes: byte[] = @[0]
    var aSign: int = 0
    var bSign: int = 0
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testZeroOne*() =
    var aBytes: byte[] = @[0]
    var bBytes: byte[] = @[1]
    var aSign: int = 0
    var bSign: int = 1
    var rBytes: byte[] = @[1]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testOneOne*() =
    var aBytes: byte[] = @[1]
    var bBytes: byte[] = @[1]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[1]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testPosPosSameLength*() =
    var aBytes: byte[] = @[cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[0, cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), cast[byte](-1), cast[byte](-66), 95, 47, 123, 59, cast[byte](-13), 39, 30, cast[byte](-97)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testPosPosFirstLonger*() =
    var aBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[0, cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-3), cast[byte](-3), cast[byte](-3), 95, 15, cast[byte](-9), 39, 58, cast[byte](-69), 87, 87, cast[byte](-17), cast[byte](-73)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testPosPosFirstShorter*() =
    var aBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var bBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[0, cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-3), cast[byte](-3), cast[byte](-3), 95, 15, cast[byte](-9), 39, 58, cast[byte](-69), 87, 87, cast[byte](-17), cast[byte](-73)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testNegNegSameLength*() =
    var aBytes: byte[] = @[cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: byte[] = @[cast[byte](-1), 127, cast[byte](-57), cast[byte](-101), cast[byte](-5), cast[byte](-5), cast[byte](-18), cast[byte](-38), cast[byte](-17), cast[byte](-2), cast[byte](-65), cast[byte](-2), cast[byte](-11), cast[byte](-3)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testNegNegFirstLonger*() =
    var aBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: byte[] = @[cast[byte](-1), 1, 75, cast[byte](-89), cast[byte](-45), cast[byte](-2), cast[byte](-3), cast[byte](-18), cast[byte](-36), cast[byte](-17), cast[byte](-10), cast[byte](-3), cast[byte](-6), cast[byte](-7), cast[byte](-21)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testNegNegFirstShorter*() =
    var aBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var bBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: byte[] = @[cast[byte](-1), 1, 75, cast[byte](-89), cast[byte](-45), cast[byte](-2), cast[byte](-3), cast[byte](-18), cast[byte](-36), cast[byte](-17), cast[byte](-10), cast[byte](-3), cast[byte](-6), cast[byte](-7), cast[byte](-21)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testPosNegSameLength*() =
    var aBytes: byte[] = @[cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: byte[] = @[cast[byte](-1), 1, cast[byte](-126), 59, 103, cast[byte](-2), cast[byte](-11), cast[byte](-7), cast[byte](-3), cast[byte](-33), cast[byte](-57), cast[byte](-3), cast[byte](-5), cast[byte](-5), cast[byte](-21)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testNegPosSameLength*() =
    var aBytes: byte[] = @[cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: byte[] = @[cast[byte](-1), 5, 79, cast[byte](-73), cast[byte](-9), cast[byte](-76), cast[byte](-3), 78, cast[byte](-35), cast[byte](-17), 119]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testNegPosFirstLonger*() =
    var aBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: byte[] = @[cast[byte](-1), 127, cast[byte](-10), cast[byte](-57), cast[byte](-101), cast[byte](-1), cast[byte](-1), cast[byte](-2), cast[byte](-2), cast[byte](-91), cast[byte](-2), 31, cast[byte](-1), cast[byte](-11), 125, cast[byte](-22), cast[byte](-83), 30, 95]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testNegPosFirstShorter*() =
    var aBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var bBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: byte[] = @[cast[byte](-74), 91, 47, cast[byte](-5), cast[byte](-13), cast[byte](-7), cast[byte](-5), cast[byte](-33), cast[byte](-49), cast[byte](-65), cast[byte](-1), cast[byte](-9), cast[byte](-3)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testPosNegFirstLonger*() =
    var aBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: byte[] = @[cast[byte](-74), 91, 47, cast[byte](-5), cast[byte](-13), cast[byte](-7), cast[byte](-5), cast[byte](-33), cast[byte](-49), cast[byte](-65), cast[byte](-1), cast[byte](-9), cast[byte](-3)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testPosNegFirstShorter*() =
    var aBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var bBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: byte[] = @[cast[byte](-1), 127, cast[byte](-10), cast[byte](-57), cast[byte](-101), cast[byte](-1), cast[byte](-1), cast[byte](-2), cast[byte](-2), cast[byte](-91), cast[byte](-2), 31, cast[byte](-1), cast[byte](-11), 125, cast[byte](-22), cast[byte](-83), 30, 95]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber | bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testRegression*() =
    var x: BigInteger = BigInteger.Parse("-1023")
    var r1: BigInteger = x & BigInteger.Not(BigInteger.Zero) << 32
    var r3: BigInteger = x & BigInteger.Not(BigInteger.Not(BigInteger.Zero) << 32)
    var result: BigInteger = r1 | r3
assertEquals("incorrect result", x, result)