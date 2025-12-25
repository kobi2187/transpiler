# "Namespace: ICU4N.Numerics.BigMath"
type
  BigIntegerOperateBitsTest = ref object


proc testBitCountZero*() =
    var aNumber: BigInteger = BigInteger.Parse("0")
assertEquals("incorrect result", 0, aNumber.BitCount)
proc testBitCountNeg*() =
    var aNumber: BigInteger = BigInteger.Parse("-12378634756382937873487638746283767238657872368748726875")
assertEquals("incorrect result", 87, aNumber.BitCount)
proc testBitCountPos*() =
    var aNumber: BigInteger = BigInteger.Parse("12378634756343564757582937873487638746283767238657872368748726875")
assertEquals("incorrect result", 107, aNumber.BitCount)
proc testBitLengthZero*() =
    var aNumber: BigInteger = BigInteger.Parse("0")
assertEquals("incorrect result", 0, aNumber.BitLength)
proc testBitLengthPositive1*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
assertEquals("incorrect result", 108, aNumber.BitLength)
proc testBitLengthPositive2*() =
    var aBytes: byte[] = @[cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
assertEquals("incorrect result", 96, aNumber.BitLength)
proc testBitLengthPositive3*() =
    var aBytes: byte[] = @[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var aSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
assertEquals("incorrect result", 81, aNumber.BitLength)
proc testBitLengthNegative1*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aSign: int = -1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
assertEquals("incorrect result", 108, aNumber.BitLength)
proc testBitLengthNegative2*() =
    var aBytes: byte[] = @[cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
assertEquals("incorrect result", 96, aNumber.BitLength)
proc testBitLengthNegative3*() =
    var aBytes: byte[] = @[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var aSign: int = -1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
assertEquals("incorrect result", 80, aNumber.BitLength)
proc testClearBitException*() =
    var aBytes: byte[] = @[cast[byte](-1), cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = -7
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    try:
BigInteger.ClearBit(aNumber, number)
fail("ArithmeticException has not been caught")
    except ArithmeticException:
assertEquals("Improper exception message", "Negative bit address", e.Message)
proc testClearBitZero*() =
    var aBytes: byte[] = @[0]
    var aSign: int = 0
    var number: int = 0
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testClearBitZeroOutside1*() =
    var aBytes: byte[] = @[0]
    var aSign: int = 0
    var number: int = 95
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testClearBitNegativeInside1*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 15
    var rBytes: byte[] = @[cast[byte](-2), 127, cast[byte](-57), cast[byte](-101), 1, 75, cast[byte](-90), cast[byte](-46), cast[byte](-92), cast[byte](-4), 14, 92, cast[byte](-26)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testClearBitNegativeInside2*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 44
    var rBytes: byte[] = @[cast[byte](-2), 127, cast[byte](-57), cast[byte](-101), 1, 75, cast[byte](-90), cast[byte](-62), cast[byte](-92), cast[byte](-4), 14, cast[byte](-36), cast[byte](-26)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testClearBitNegativeInside3*() =
    var @as: String = "-18446744073709551615"
    var number: int = 2
    var aNumber: BigInteger = BigInteger.Parse(@as)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
assertEquals("incorrect result", @as, result.ToString(CultureInfo.InvariantCulture))
proc testClearBitNegativeInside4*() =
    var @as: String = "-4294967295"
    var res: String = "-4294967296"
    var number: int = 0
    var aNumber: BigInteger = BigInteger.Parse(@as)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
assertEquals("incorrect result", res, result.ToString(CultureInfo.InvariantCulture))
proc testClearBitNegativeInside5*() =
    var @as: String = "-18446744073709551615"
    var res: String = "-18446744073709551616"
    var number: int = 0
    var aNumber: BigInteger = BigInteger.Parse(@as)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
assertEquals("incorrect result", res, result.ToString(CultureInfo.InvariantCulture))
proc testClearBitNegativeOutside1*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 150
    var rBytes: byte[] = @[cast[byte](-65), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-2), 127, cast[byte](-57), cast[byte](-101), 1, 75, cast[byte](-90), cast[byte](-46), cast[byte](-92), cast[byte](-4), 14, cast[byte](-36), cast[byte](-26)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testClearBitNegativeOutside2*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 165
    var rBytes: byte[] = @[cast[byte](-33), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-2), 127, cast[byte](-57), cast[byte](-101), 1, 75, cast[byte](-90), cast[byte](-46), cast[byte](-92), cast[byte](-4), 14, cast[byte](-36), cast[byte](-26)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testClearBitPositiveInside1*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 20
    var rBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-31), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testClearBitPositiveInside2*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 17
    var rBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testClearBitPositiveInside3*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 45
    var rBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 13, 91, 3, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testClearBitPositiveInside4*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 50
    var rBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testClearBitPositiveInside5*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 63
    var rBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), 52, 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testClearBitPositiveOutside1*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 150
    var rBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testClearBitPositiveOutside2*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 191
    var rBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testClearBitTopNegative*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 63
    var rBytes: byte[] = @[cast[byte](-1), 127, cast[byte](-2), 127, cast[byte](-57), cast[byte](-101), 14, cast[byte](-36), cast[byte](-26)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.ClearBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testFlipBitException*() =
    var aBytes: byte[] = @[cast[byte](-1), cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = -7
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    try:
BigInteger.FlipBit(aNumber, number)
fail("ArithmeticException has not been caught")
    except ArithmeticException:
assertEquals("Improper exception message", "Negative bit address", e.Message)
proc testFlipBitZero*() =
    var aBytes: byte[] = @[0]
    var aSign: int = 0
    var number: int = 0
    var rBytes: byte[] = @[1]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.FlipBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testFlipBitZeroOutside1*() =
    var aBytes: byte[] = @[0]
    var aSign: int = 0
    var number: int = 62
    var rBytes: byte[] = @[64, 0, 0, 0, 0, 0, 0, 0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.FlipBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testFlipBitZeroOutside2*() =
    var aBytes: byte[] = @[0]
    var aSign: int = 0
    var number: int = 63
    var rBytes: byte[] = @[0, cast[byte](-128), 0, 0, 0, 0, 0, 0, 0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.FlipBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testFlipBitLeftmostNegative*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 48
    var rBytes: byte[] = @[cast[byte](-1), 127, cast[byte](-57), cast[byte](-101), 14, cast[byte](-36), cast[byte](-26), 49]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.FlipBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testFlipBitLeftmostPositive*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 48
    var rBytes: byte[] = @[0, cast[byte](-128), 56, 100, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.FlipBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testFlipBitNegativeInside1*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 15
    var rBytes: byte[] = @[cast[byte](-2), 127, cast[byte](-57), cast[byte](-101), 1, 75, cast[byte](-90), cast[byte](-46), cast[byte](-92), cast[byte](-4), 14, 92, cast[byte](-26)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.FlipBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testFlipBitNegativeInside2*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 45
    var rBytes: byte[] = @[cast[byte](-2), 127, cast[byte](-57), cast[byte](-101), 1, 75, cast[byte](-90), cast[byte](-14), cast[byte](-92), cast[byte](-4), 14, cast[byte](-36), cast[byte](-26)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.FlipBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testFlipBitNegativeInside3*() =
    var @as: String = "-18446744073709551615"
    var res: String = "-18446744073709551611"
    var number: int = 2
    var aNumber: BigInteger = BigInteger.Parse(@as)
    var result: BigInteger = BigInteger.FlipBit(aNumber, number)
assertEquals("incorrect result", res, result.ToString(CultureInfo.InvariantCulture))
proc testFlipBitNegativeInside4*() =
    var @as: String = "-4294967295"
    var res: String = "-4294967296"
    var number: int = 0
    var aNumber: BigInteger = BigInteger.Parse(@as)
    var result: BigInteger = BigInteger.FlipBit(aNumber, number)
assertEquals("incorrect result", res, result.ToString(CultureInfo.InvariantCulture))
proc testFlipBitNegativeInside5*() =
    var @as: String = "-18446744073709551615"
    var res: String = "-18446744073709551616"
    var number: int = 0
    var aNumber: BigInteger = BigInteger.Parse(@as)
    var result: BigInteger = BigInteger.FlipBit(aNumber, number)
assertEquals("incorrect result", res, result.ToString(CultureInfo.InvariantCulture))
proc testFlipBitNegativeOutside1*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 150
    var rBytes: byte[] = @[cast[byte](-65), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-2), 127, cast[byte](-57), cast[byte](-101), 1, 75, cast[byte](-90), cast[byte](-46), cast[byte](-92), cast[byte](-4), 14, cast[byte](-36), cast[byte](-26)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.FlipBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testFlipBitNegativeOutside2*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 191
    var rBytes: byte[] = @[cast[byte](-1), 127, cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-2), 127, cast[byte](-57), cast[byte](-101), 1, 75, cast[byte](-90), cast[byte](-46), cast[byte](-92), cast[byte](-4), 14, cast[byte](-36), cast[byte](-26)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.FlipBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testFlipBitPositiveInside1*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 15
    var rBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), cast[byte](-93), 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.FlipBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testFlipBitPositiveInside2*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 45
    var rBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 13, 91, 3, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.FlipBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testFlipBitPositiveOutside1*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 150
    var rBytes: byte[] = @[64, 0, 0, 0, 0, 0, 1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.FlipBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testFlipBitPositiveOutside2*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 191
    var rBytes: byte[] = @[0, cast[byte](-128), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.FlipBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testSetBitException*() =
    var aBytes: byte[] = @[cast[byte](-1), cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = -7
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    try:
BigInteger.SetBit(aNumber, number)
fail("ArithmeticException has not been caught")
    except ArithmeticException:
assertEquals("Improper exception message", "Negative bit address", e.Message)
proc testSetBitZero*() =
    var aBytes: byte[] = @[0]
    var aSign: int = 0
    var number: int = 0
    var rBytes: byte[] = @[1]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testSetBitZeroOutside1*() =
    var aBytes: byte[] = @[0]
    var aSign: int = 0
    var number: int = 95
    var rBytes: byte[] = @[0, cast[byte](-128), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testSetBitPositiveInside1*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 20
    var rBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testSetBitPositiveInside2*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 17
    var rBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-13), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testSetBitPositiveInside3*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 45
    var rBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testSetBitPositiveInside4*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 50
    var rBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 93, 45, 91, 3, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testSetBitPositiveOutside1*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 150
    var rBytes: byte[] = @[64, 0, 0, 0, 0, 0, 1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testSetBitPositiveOutside2*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 223
    var rBytes: byte[] = @[0, cast[byte](-128), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testSetBitTopPositive*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 63
    var rBytes: byte[] = @[0, cast[byte](-128), 1, cast[byte](-128), 56, 100, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testSetBitLeftmostNegative*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 48
    var rBytes: byte[] = @[cast[byte](-1), 127, cast[byte](-57), cast[byte](-101), 14, cast[byte](-36), cast[byte](-26), 49]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testSetBitNegativeInside1*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 15
    var rBytes: byte[] = @[cast[byte](-2), 127, cast[byte](-57), cast[byte](-101), 1, 75, cast[byte](-90), cast[byte](-46), cast[byte](-92), cast[byte](-4), 14, cast[byte](-36), cast[byte](-26)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testSetBitNegativeInside2*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 44
    var rBytes: byte[] = @[cast[byte](-2), 127, cast[byte](-57), cast[byte](-101), 1, 75, cast[byte](-90), cast[byte](-46), cast[byte](-92), cast[byte](-4), 14, cast[byte](-36), cast[byte](-26)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testSetBitNegativeInside3*() =
    var @as: String = "-18446744073709551615"
    var res: String = "-18446744073709551611"
    var number: int = 2
    var aNumber: BigInteger = BigInteger.Parse(@as)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
assertEquals("incorrect result", res, result.ToString(CultureInfo.InvariantCulture))
proc testSetBitNegativeInside4*() =
    var @as: String = "-4294967295"
    var number: int = 0
    var aNumber: BigInteger = BigInteger.Parse(@as)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
assertEquals("incorrect result", @as, result.ToString(CultureInfo.InvariantCulture))
proc testSetBitNegativeInside5*() =
    var @as: String = "-18446744073709551615"
    var number: int = 0
    var aNumber: BigInteger = BigInteger.Parse(@as)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
assertEquals("incorrect result", @as, result.ToString(CultureInfo.InvariantCulture))
proc testSetBitNegativeOutside1*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 150
    var rBytes: byte[] = @[cast[byte](-2), 127, cast[byte](-57), cast[byte](-101), 1, 75, cast[byte](-90), cast[byte](-46), cast[byte](-92), cast[byte](-4), 14, cast[byte](-36), cast[byte](-26)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testSetBitNegativeOutside2*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 191
    var rBytes: byte[] = @[cast[byte](-2), 127, cast[byte](-57), cast[byte](-101), 1, 75, cast[byte](-90), cast[byte](-46), cast[byte](-92), cast[byte](-4), 14, cast[byte](-36), cast[byte](-26)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = BigInteger.SetBit(aNumber, number)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testSetBitBug1331*() =
    var result: BigInteger = BigInteger.SetBit(BigInteger.GetInstance(0), 191)
assertEquals("incorrect value", "3138550867693340381917894711603833208051177722232017256448", result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect sign", 1, result.Sign)
proc testShiftLeft1*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 0
    var rBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = aNumber << number
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testShiftLeft2*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = -27
    var rBytes: byte[] = @[48, 7, 12, cast[byte](-97), cast[byte](-42), cast[byte](-117), 37, cast[byte](-85), 96]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = aNumber << number
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testShiftLeft3*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 27
    var rBytes: byte[] = @[12, 1, cast[byte](-61), 39, cast[byte](-11), cast[byte](-94), cast[byte](-55), 106, cast[byte](-40), 31, cast[byte](-119), 24, cast[byte](-48), 0, 0, 0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = aNumber << number
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testShiftLeft4*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 45
    var rBytes: byte[] = @[48, 7, 12, cast[byte](-97), cast[byte](-42), cast[byte](-117), 37, cast[byte](-85), 96, 126, 36, 99, 64, 0, 0, 0, 0, 0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = aNumber << number
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testShiftLeft5*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 45
    var rBytes: byte[] = @[cast[byte](-49), cast[byte](-8), cast[byte](-13), 96, 41, 116, cast[byte](-38), 84, cast[byte](-97), cast[byte](-127), cast[byte](-37), cast[byte](-100), cast[byte](-64), 0, 0, 0, 0, 0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = aNumber << number
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testShiftRight1*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 0
    var rBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = aNumber >> number
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testShiftRight2*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = -27
    var rBytes: byte[] = @[12, 1, cast[byte](-61), 39, cast[byte](-11), cast[byte](-94), cast[byte](-55), 106, cast[byte](-40), 31, cast[byte](-119), 24, cast[byte](-48), 0, 0, 0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = aNumber >> number
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testShiftRight3*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 27
    var rBytes: byte[] = @[48, 7, 12, cast[byte](-97), cast[byte](-42), cast[byte](-117), 37, cast[byte](-85), 96]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = aNumber >> number
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testShiftRight4*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 45
    var rBytes: byte[] = @[12, 1, cast[byte](-61), 39, cast[byte](-11), cast[byte](-94), cast[byte](-55)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = aNumber >> number
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testShiftRight5*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 300
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = aNumber >> number
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testShiftRightNegNonZeroesMul32*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 1, 0, 0, 0, 0, 0, 0, 0]
    var aSign: int = -1
    var number: int = 64
    var rBytes: byte[] = @[cast[byte](-2), 127, cast[byte](-57), cast[byte](-101), 1, 75, cast[byte](-90), cast[byte](-46), cast[byte](-92)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = aNumber >> number
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testShiftRightNegNonZeroes*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 0, 0, 0, 0, 0, 0, 0, 0]
    var aSign: int = -1
    var number: int = 68
    var rBytes: byte[] = @[cast[byte](-25), cast[byte](-4), 121, cast[byte](-80), 20, cast[byte](-70), 109, 42]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = aNumber >> number
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testShiftRightNegZeroes*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var aSign: int = -1
    var number: int = 68
    var rBytes: byte[] = @[cast[byte](-25), cast[byte](-4), 121, cast[byte](-80), 20, cast[byte](-70), 109, 48]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = aNumber >> number
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testShiftRightNegZeroesMul32*() =
    var aBytes: byte[] = @[1, cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 0, 0, 0, 0, 0, 0, 0, 0]
    var aSign: int = -1
    var number: int = 64
    var rBytes: byte[] = @[cast[byte](-2), 127, cast[byte](-57), cast[byte](-101), 1, 75, cast[byte](-90), cast[byte](-46), cast[byte](-91)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var result: BigInteger = aNumber >> number
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testTestBitException*() =
    var aBytes: byte[] = @[cast[byte](-1), cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = -7
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    try:
BigInteger.TestBit(aNumber, number)
fail("ArithmeticException has not been caught")
    except ArithmeticException:
assertEquals("Improper exception message", "Negative bit address", e.Message)
proc testTestBitPositive1*() =
    var aBytes: byte[] = @[cast[byte](-1), cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 7
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
assertTrue("incorrect value", !BigInteger.TestBit(aNumber, number))
proc testTestBitPositive2*() =
    var aBytes: byte[] = @[cast[byte](-1), cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 45
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
assertTrue("incorrect value", BigInteger.TestBit(aNumber, number))
proc testTestBitPositive3*() =
    var aBytes: byte[] = @[cast[byte](-1), cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = 1
    var number: int = 300
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
assertTrue("incorrect value", !BigInteger.TestBit(aNumber, number))
proc testTestBitNegative1*() =
    var aBytes: byte[] = @[cast[byte](-1), cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 7
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
assertTrue("incorrect value", BigInteger.TestBit(aNumber, number))
proc testTestBitNegative2*() =
    var aBytes: byte[] = @[cast[byte](-1), cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 45
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
assertTrue("incorrect value", !BigInteger.TestBit(aNumber, number))
proc testTestBitNegative3*() =
    var aBytes: byte[] = @[cast[byte](-1), cast[byte](-128), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26]
    var aSign: int = -1
    var number: int = 300
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
assertTrue("incorrect value", BigInteger.TestBit(aNumber, number))