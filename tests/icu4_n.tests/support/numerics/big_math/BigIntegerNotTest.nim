# "Namespace: ICU4N.Numerics.BigMath"
type
  BigIntegerNotTest = ref object


proc testAndNotPosPosFirstLonger*() =
    var aBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[0, cast[byte](-128), 9, 56, 100, 0, 0, 1, 1, 90, 1, cast[byte](-32), 0, 10, cast[byte](-126), 21, 82, cast[byte](-31), cast[byte](-96)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.AndNot(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testAndNotPosPosFirstShorter*() =
    var aBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var bBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[73, cast[byte](-92), cast[byte](-48), 4, 12, 6, 4, 32, 48, 64, 0, 8, 2]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.AndNot(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testAndNotNegNegFirstLonger*() =
    var aBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: byte[] = @[73, cast[byte](-92), cast[byte](-48), 4, 12, 6, 4, 32, 48, 64, 0, 8, 2]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.AndNot(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testNegPosFirstLonger*() =
    var aBytes: byte[] = @[cast[byte](-128), 9, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117), 23, 87, cast[byte](-25), cast[byte](-75)]
    var bBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: byte[] = @[cast[byte](-1), 127, cast[byte](-10), cast[byte](-57), cast[byte](-101), 1, 2, 2, 2, cast[byte](-96), cast[byte](-16), 8, cast[byte](-40), cast[byte](-59), 68, cast[byte](-88), cast[byte](-88), 16, 72]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.AndNot(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testNotZero*() =
    var rBytes: byte[] = @[cast[byte](-1)]
    var aNumber: BigInteger = BigInteger.Zero
    var result: BigInteger = BigInteger.Not(aNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testNotOne*() =
    var rBytes: byte[] = @[cast[byte](-2)]
    var aNumber: BigInteger = BigInteger.One
    var result: BigInteger = BigInteger.Not(aNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testNotPos*() =
    var aBytes: byte[] = @[cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117)]
    var aSign: int = 1
    var rBytes: byte[] = @[cast[byte](-1), 127, cast[byte](-57), cast[byte](-101), 1, 75, cast[byte](-90), cast[byte](-46), cast[byte](-92), cast[byte](-4), 14, cast[byte](-36), cast[byte](-27), 116]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.Not(aNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testNotNeg*() =
    var aBytes: byte[] = @[cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-117)]
    var aSign: int = -1
    var rBytes: byte[] = @[0, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, cast[byte](-118)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.Not(aNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testNotSpecialCase*() =
    var aBytes: byte[] = @[cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1)]
    var aSign: int = 1
    var rBytes: byte[] = @[cast[byte](-1), 0, 0, 0, 0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.Not(aNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)