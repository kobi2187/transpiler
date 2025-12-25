# "Namespace: ICU4N.Numerics.BigMath"
type
  BigIntegerConstructorsTest = ref object


proc testConstructorBytesException*() =
    var aBytes: byte[] = @[]
    try:
BigInteger(aBytes)
fail("NumberFormatException has not been caught")
    except FormatException:
assertEquals("Improper exception message", "Zero length BigInteger", e.Message)
proc testConstructorBytesPositive1*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var rBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aNumber: BigInteger = BigInteger(aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testConstructorBytesPositive2*() =
    var aBytes: byte[] = @[12, 56, 100]
    var rBytes: byte[] = @[12, 56, 100]
    var aNumber: BigInteger = BigInteger(aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testConstructorBytesPositive3*() =
    var aBytes: byte[] = @[127, 56, 100, cast[byte](-1)]
    var rBytes: byte[] = @[127, 56, 100, cast[byte](-1)]
    var aNumber: BigInteger = BigInteger(aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testConstructorBytesPositive*() =
    var aBytes: byte[] = @[127, 56, 100, cast[byte](-1), 14, 75, cast[byte](-24), cast[byte](-100)]
    var rBytes: byte[] = @[127, 56, 100, cast[byte](-1), 14, 75, cast[byte](-24), cast[byte](-100)]
    var aNumber: BigInteger = BigInteger(aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testConstructorBytesNegative1*() =
    var aBytes: byte[] = @[cast[byte](-12), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var rBytes: byte[] = @[cast[byte](-12), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 35, 26, 3, 91]
    var aNumber: BigInteger = BigInteger(aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testConstructorBytesNegative2*() =
    var aBytes: byte[] = @[cast[byte](-12), 56, 100]
    var rBytes: byte[] = @[cast[byte](-12), 56, 100]
    var aNumber: BigInteger = BigInteger(aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testConstructorBytesNegative3*() =
    var aBytes: byte[] = @[cast[byte](-128), cast[byte](-12), 56, 100]
    var rBytes: byte[] = @[cast[byte](-128), cast[byte](-12), 56, 100]
    var aNumber: BigInteger = BigInteger(aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testConstructorBytesNegative4*() =
    var aBytes: byte[] = @[cast[byte](-128), cast[byte](-12), 56, 100, cast[byte](-13), 56, 93, cast[byte](-78)]
    var rBytes: byte[] = @[cast[byte](-128), cast[byte](-12), 56, 100, cast[byte](-13), 56, 93, cast[byte](-78)]
    var aNumber: BigInteger = BigInteger(aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testConstructorBytesZero*() =
    var aBytes: byte[] = @[0, 0, 0, cast[byte](-0), +0, 0, cast[byte](-0)]
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, aNumber.Sign)
proc testConstructorSignBytesException1*() =
    var aBytes: byte[] = @[123, 45, cast[byte](-3), cast[byte](-76)]
    var aSign: int = 3
    try:
BigInteger(aSign, aBytes)
fail("NumberFormatException has not been caught")
    except FormatException:
assertEquals("Improper exception message", "Invalid signum value", e.Message)
proc testConstructorSignBytesException2*() =
    var aBytes: byte[] = @[123, 45, cast[byte](-3), cast[byte](-76)]
    var aSign: int = 0
    try:
BigInteger(aSign, aBytes)
fail("NumberFormatException has not been caught")
    except FormatException:
assertEquals("Improper exception message", "signum-magnitude mismatch", e.Message)
proc testConstructorSignBytesPositive1*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15)]
    var aSign: int = 1
    var rBytes: sbyte[] = @[12, 56, 100, -2, -76, 89, 45, 91, 3, -15]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testConstructorSignBytesPositive2*() =
    var aBytes: byte[] = @[cast[byte](-12), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15)]
    var aSign: int = 1
    var rBytes: sbyte[] = @[0, -12, 56, 100, -2, -76, 89, 45, 91, 3, -15]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testConstructorSignBytesPositive3*() =
    var aBytes: byte[] = @[cast[byte](-12), 56, 100]
    var aSign: int = 1
    var rBytes: sbyte[] = @[0, -12, 56, 100]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testConstructorSignBytesPositive4*() =
    var aBytes: byte[] = @[127, 56, 100, cast[byte](-2)]
    var aSign: int = 1
    var rBytes: sbyte[] = @[127, 56, 100, -2]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testConstructorSignBytesPositive5*() =
    var aBytes: byte[] = @[cast[byte](-127), 56, 100, cast[byte](-2)]
    var aSign: int = 1
    var rBytes: sbyte[] = @[0, -127, 56, 100, -2]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testConstructorSignBytesPositive6*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 23, cast[byte](-101)]
    var aSign: int = 1
    var rBytes: sbyte[] = @[12, 56, 100, -2, -76, 89, 45, 91, 3, -15, 23, -101]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testConstructorSignBytesPositive7*() =
    var aBytes: byte[] = @[cast[byte](-12), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 23, cast[byte](-101)]
    var aSign: int = 1
    var rBytes: sbyte[] = @[0, -12, 56, 100, -2, -76, 89, 45, 91, 3, -15, 23, -101]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testConstructorSignBytesNegative1*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15)]
    var aSign: int = -1
    var rBytes: sbyte[] = @[-13, -57, -101, 1, 75, -90, -46, -92, -4, 15]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testConstructorSignBytesNegative2*() =
    var aBytes: byte[] = @[cast[byte](-12), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15)]
    var aSign: int = -1
    var rBytes: sbyte[] = @[-1, 11, -57, -101, 1, 75, -90, -46, -92, -4, 15]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testConstructorSignBytesNegative3*() =
    var aBytes: byte[] = @[cast[byte](-12), 56, 100]
    var aSign: int = -1
    var rBytes: sbyte[] = @[-1, 11, -57, -100]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testConstructorSignBytesNegative4*() =
    var aBytes: byte[] = @[127, 56, 100, cast[byte](-2)]
    var aSign: int = -1
    var rBytes: sbyte[] = @[-128, -57, -101, 2]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testConstructorSignBytesNegative5*() =
    var aBytes: byte[] = @[cast[byte](-127), 56, 100, cast[byte](-2)]
    var aSign: int = -1
    var rBytes: sbyte[] = @[-1, 126, -57, -101, 2]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testConstructorSignBytesNegative6*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 23, cast[byte](-101)]
    var aSign: int = -1
    var rBytes: sbyte[] = @[-13, -57, -101, 1, 75, -90, -46, -92, -4, 14, -24, 101]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testConstructorSignBytesNegative7*() =
    var aBytes: byte[] = @[cast[byte](-12), 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, cast[byte](-15), 23, cast[byte](-101)]
    var aSign: int = -1
    var rBytes: sbyte[] = @[-1, 11, -57, -101, 1, 75, -90, -46, -92, -4, 14, -24, 101]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testConstructorSignBytesZero1*() =
    var aBytes: byte[] = @[cast[byte](-0), 0, +0, 0, 0, 0, 0]
    var aSign: int = -1
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, aNumber.Sign)
proc testConstructorSignBytesZero2*() =
    var aBytes: byte[] = @[cast[byte](-0), 0, +0, 0, 0, 0, 0]
    var aSign: int = 0
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, aNumber.Sign)
proc testConstructorSignBytesZero3*() =
    var aBytes: byte[] = @[cast[byte](-0), 0, +0, 0, 0, 0, 0]
    var aSign: int = 1
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, aNumber.Sign)
proc testConstructorSignBytesZeroNull1*() =
    var aBytes: byte[] = @[]
    var aSign: int = -1
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, aNumber.Sign)
proc testConstructorSignBytesZeroNull2*() =
    var aBytes: byte[] = @[]
    var aSign: int = 0
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, aNumber.Sign)
proc testConstructorSignBytesZeroNull3*() =
    var aBytes: byte[] = @[]
    var aSign: int = 1
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, aNumber.Sign)
proc testConstructorStringException1*() =
    var value: String = "9234853876401"
    var radix: int = 45
    try:
BigInteger.Parse(value, radix)
fail("NumberFormatException has not been caught")
    except ArgumentOutOfRangeException:
assertTrue("Improper exception message", e.Message.Contains("Radix must be greater than or equal to Character.MinRadix and less than or equal to Character.MaxRadix."))
proc testConstructorStringException2*() =
    var value: String = "   9234853876401"
    var radix: int = 10
    try:
BigInteger.Parse(value, radix)
fail("NumberFormatException has not been caught")
    except FormatException:

proc testConstructorStringException3*() =
    var value: String = "92348$*#78987"
    var radix: int = 34
    try:
BigInteger.Parse(value, radix)
fail("NumberFormatException has not been caught")
    except FormatException:

proc testConstructorStringException4*() =
    var value: String = "98zv765hdsaiy"
    var radix: int = 20
    try:
BigInteger.Parse(value, radix)
fail("NumberFormatException has not been caught")
    except FormatException:

proc testConstructorStringRadix2*() =
    var value: String = "10101010101010101"
    var radix: int = 2
    var rBytes: byte[] = @[1, 85, 85]
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testConstructorStringRadix8*() =
    var value: String = "76356237071623450"
    var radix: int = 8
    var rBytes: sbyte[] = @[7, -50, -28, -8, -25, 39, 40]
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testConstructorStringRadix10*() =
    var value: String = "987328901348934898"
    var radix: int = 10
    var rBytes: sbyte[] = @[13, -77, -78, 103, -103, 97, 68, -14]
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testConstructorStringRadix16*() =
    var value: String = "fe2340a8b5ce790"
    var radix: int = 16
    var rBytes: sbyte[] = @[15, -30, 52, 10, -117, 92, -25, -112]
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testConstructorStringRadix36*() =
    var value: String = "skdjgocvhdjfkl20jndjkf347ejg457"
    var radix: int = 36
    var rBytes: sbyte[] = @[0, -12, -116, 112, -105, 12, -36, 66, 108, 66, -20, -37, -15, 108, -7, 52, -99, -109, -8, -45, -5]
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testConstructorStringRadix10Negative*() =
    var value: String = "-234871376037"
    var radix: int = 36
    var rBytes: sbyte[] = @[-4, 48, 71, 62, -76, 93, -105, 13]
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testConstructorStringRadix10Zero*() =
    var value: String = "-00000000000000"
    var radix: int = 10
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, aNumber.Sign)
proc testConstructorRandom*() =
    var bitLen: int = 75
    var rnd: Random = Random
    var aNumber: BigInteger = BigInteger(bitLen, rnd)
assertTrue("incorrect bitLength", aNumber.BitLength <= bitLen)
proc testConstructorPrime*() =
    var bitLen: int = 25
    var rnd: Random = Random
    var aNumber: BigInteger = BigInteger(bitLen, 80, rnd)
assertTrue("incorrect bitLength", aNumber.BitLength == bitLen)
proc testConstructorPrime2*() =
    var bitLen: int = 2
    var rnd: Random = Random
    var aNumber: BigInteger = BigInteger(bitLen, 80, rnd)
assertTrue("incorrect bitLength", aNumber.BitLength == bitLen)
    var num: int = aNumber.ToInt32
assertTrue("incorrect value", num == 2 || num == 3)