# "Namespace: ICU4N.Numerics.BigMath"
type
  BigIntegerMultiplyTest = ref object


proc testCase1*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: byte[] = @[10, 40, 100, cast[byte](-55), 96, 51, 76, 40, cast[byte](-45), 85, 105, 4, 28, cast[byte](-86), cast[byte](-117), cast[byte](-52), 100, 120, 90]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber * bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase2*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: byte[] = @[cast[byte](-11), cast[byte](-41), cast[byte](-101), 54, cast[byte](-97), cast[byte](-52), cast[byte](-77), cast[byte](-41), 44, cast[byte](-86), cast[byte](-106), cast[byte](-5), cast[byte](-29), 85, 116, 51, cast[byte](-101), cast[byte](-121), cast[byte](-90)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber * bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase3*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 1, 2, 3, 4, 5]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[10, 40, 100, cast[byte](-55), 96, 51, 76, 40, cast[byte](-45), 85, 115, 44, cast[byte](-127), 115, cast[byte](-21), cast[byte](-62), cast[byte](-15), 85, 64, cast[byte](-87), cast[byte](-2), cast[byte](-36), cast[byte](-36), cast[byte](-106)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber * bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase4*() =
    var aBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 1, 2, 3, 4, 5]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[10, 40, 100, cast[byte](-55), 96, 51, 76, 40, cast[byte](-45), 85, 115, 44, cast[byte](-127), 115, cast[byte](-21), cast[byte](-62), cast[byte](-15), 85, 64, cast[byte](-87), cast[byte](-2), cast[byte](-36), cast[byte](-36), cast[byte](-106)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber * bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase5*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 1, 2, 3, 4, 5]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: byte[] = @[cast[byte](-11), cast[byte](-41), cast[byte](-101), 54, cast[byte](-97), cast[byte](-52), cast[byte](-77), cast[byte](-41), 44, cast[byte](-86), cast[byte](-116), cast[byte](-45), 126, cast[byte](-116), 20, 61, 14, cast[byte](-86), cast[byte](-65), 86, 1, 35, 35, 106]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber * bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase6*() =
    var aBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 1, 2, 3, 4, 5]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: byte[] = @[cast[byte](-11), cast[byte](-41), cast[byte](-101), 54, cast[byte](-97), cast[byte](-52), cast[byte](-77), cast[byte](-41), 44, cast[byte](-86), cast[byte](-116), cast[byte](-45), 126, cast[byte](-116), 20, 61, 14, cast[byte](-86), cast[byte](-65), 86, 1, 35, 35, 106]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber * bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase7*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 1, 2, 3, 4, 5]
    var bBytes: byte[] = @[0]
    var aSign: int = 1
    var bSign: int = 0
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber * bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testCase8*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 1, 2, 3, 4, 5]
    var aSign: int = 1
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger.Zero
    var result: BigInteger = aNumber * bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testCase9*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 1, 2, 3, 4, 5]
    var aSign: int = 1
    var rBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 1, 2, 3, 4, 5]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger.One
    var result: BigInteger = aNumber * bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase10*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 1, 2, 3, 4, 5]
    var aSign: int = -1
    var rBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-5), cast[byte](-6), cast[byte](-7), cast[byte](-8), cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-5), cast[byte](-5)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger.One
    var result: BigInteger = aNumber * bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testIntbyInt1*() =
    var aBytes: byte[] = @[10, 20, 30, 40]
    var bBytes: byte[] = @[1, 2, 3, 4]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: byte[] = @[cast[byte](-11), cast[byte](-41), cast[byte](-101), 55, 5, 15, 96]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber * bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testIntbyInt2*() =
    var aBytes: byte[] = @[cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1)]
    var bBytes: byte[] = @[cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1)]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[0, cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-2), 0, 0, 0, 1]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber * bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testPowException*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var aSign: int = 1
    var exp: int = -5
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    try:
BigInteger.Pow(aNumber, exp)
fail("ArithmeticException has not been caught")
    except ArithmeticException:
assertEquals("Improper exception message", "Negative exponent", e.Message)
proc testPowNegativeNumToOddExp*() =
    var aBytes: byte[] = @[50, cast[byte](-26), 90, 69, 120, 32, 63, cast[byte](-103), cast[byte](-14), 35]
    var aSign: int = -1
    var exp: int = 5
    var rBytes: byte[] = @[cast[byte](-21), cast[byte](-94), cast[byte](-42), cast[byte](-15), cast[byte](-127), 113, cast[byte](-50), cast[byte](-88), 115, cast[byte](-35), 3, 59, cast[byte](-92), 111, cast[byte](-75), 103, cast[byte](-42), 41, 34, cast[byte](-114), 99, cast[byte](-32), 105, cast[byte](-59), 127, 45, 108, 74, cast[byte](-93), 105, 33, 12, cast[byte](-5), cast[byte](-20), 17, cast[byte](-21), cast[byte](-119), cast[byte](-127), cast[byte](-115), 27, cast[byte](-122), 26, cast[byte](-67), 109, cast[byte](-125), 16, 91, cast[byte](-70), 109]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.Pow(aNumber, exp)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testPowNegativeNumToEvenExp*() =
    var aBytes: byte[] = @[50, cast[byte](-26), 90, 69, 120, 32, 63, cast[byte](-103), cast[byte](-14), 35]
    var aSign: int = -1
    var exp: int = 4
    var rBytes: byte[] = @[102, 107, cast[byte](-122), cast[byte](-43), cast[byte](-52), cast[byte](-20), cast[byte](-27), 25, cast[byte](-9), 88, cast[byte](-13), 75, 78, 81, cast[byte](-33), cast[byte](-77), 39, 27, cast[byte](-37), 106, 121, cast[byte](-73), 108, cast[byte](-47), cast[byte](-101), 80, cast[byte](-25), 71, 13, 94, cast[byte](-7), cast[byte](-33), 1, cast[byte](-17), cast[byte](-65), cast[byte](-70), cast[byte](-61), cast[byte](-3), cast[byte](-47)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.Pow(aNumber, exp)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testPowNegativeNumToZeroExp*() =
    var aBytes: byte[] = @[50, cast[byte](-26), 90, 69, 120, 32, 63, cast[byte](-103), cast[byte](-14), 35]
    var aSign: int = -1
    var exp: int = 0
    var rBytes: byte[] = @[1]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.Pow(aNumber, exp)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testPowPositiveNum*() =
    var aBytes: byte[] = @[50, cast[byte](-26), 90, 69, 120, 32, 63, cast[byte](-103), cast[byte](-14), 35]
    var aSign: int = 1
    var exp: int = 5
    var rBytes: byte[] = @[20, 93, 41, 14, 126, cast[byte](-114), 49, 87, cast[byte](-116), 34, cast[byte](-4), cast[byte](-60), 91, cast[byte](-112), 74, cast[byte](-104), 41, cast[byte](-42), cast[byte](-35), 113, cast[byte](-100), 31, cast[byte](-106), 58, cast[byte](-128), cast[byte](-46), cast[byte](-109), cast[byte](-75), 92, cast[byte](-106), cast[byte](-34), cast[byte](-13), 4, 19, cast[byte](-18), 20, 118, 126, 114, cast[byte](-28), 121, cast[byte](-27), 66, cast[byte](-110), 124, cast[byte](-17), cast[byte](-92), 69, cast[byte](-109)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.Pow(aNumber, exp)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testPowPositiveNumToZeroExp*() =
    var aBytes: byte[] = @[50, cast[byte](-26), 90, 69, 120, 32, 63, cast[byte](-103), cast[byte](-14), 35]
    var aSign: int = 1
    var exp: int = 0
    var rBytes: byte[] = @[1]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.Pow(aNumber, exp)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)