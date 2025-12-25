# "Namespace: ICU4N.Numerics.BigMath"
type
  BigIntegerModPowTest = ref object


proc testModPowException*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var eBytes: byte[] = @[1, 2, 3, 4, 5]
    var mBytes: byte[] = @[1, 2, 3]
    var aSign: int = 1
    var eSign: int = 1
    var mSign: int = -1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var exp: BigInteger = BigInteger(eSign, eBytes)
    var modulus: BigInteger = BigInteger(mSign, mBytes)
    try:
BigInteger.ModPow(aNumber, exp, modulus)
fail("ArithmeticException has not been caught")
    except ArithmeticException:
assertEquals("Improper exception message", "BigInteger: modulus not positive", e.Message)
    try:
BigInteger.ModPow(BigInteger.Zero, BigInteger.Parse("-1"), BigInteger.Parse("10"))
fail("ArithmeticException has not been caught")
    except ArithmeticException:

proc testModPowPosExp*() =
    var aBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127, 75, 48, cast[byte](-7)]
    var eBytes: byte[] = @[27, cast[byte](-15), 65, 39]
    var mBytes: byte[] = @[cast[byte](-128), 2, 3, 4, 5]
    var aSign: int = 1
    var eSign: int = 1
    var mSign: int = 1
    var rBytes: byte[] = @[113, 100, cast[byte](-84), cast[byte](-28), cast[byte](-85)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var exp: BigInteger = BigInteger(eSign, eBytes)
    var modulus: BigInteger = BigInteger(mSign, mBytes)
    var result: BigInteger = BigInteger.ModPow(aNumber, exp, modulus)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testModPowNegExp*() =
    var aBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127, 75, 48, cast[byte](-7)]
    var eBytes: byte[] = @[27, cast[byte](-15), 65, 39]
    var mBytes: byte[] = @[cast[byte](-128), 2, 3, 4, 5]
    var aSign: int = 1
    var eSign: int = -1
    var mSign: int = 1
    var rBytes: byte[] = @[12, 118, 46, 86, 92]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var exp: BigInteger = BigInteger(eSign, eBytes)
    var modulus: BigInteger = BigInteger(mSign, mBytes)
    var result: BigInteger = BigInteger.ModPow(aNumber, exp, modulus)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testModPowZeroExp*() =
    var exp: BigInteger = BigInteger.Parse("0")
    var @base: BigInteger[] = @[BigInteger.Parse("-1"), BigInteger.Parse("0"), BigInteger.Parse("1")]
    var mod: BigInteger[] = @[BigInteger.Parse("2"), BigInteger.Parse("10"), BigInteger.Parse("2147483648")]
      var i: int = 0
      while i < @base.Length:
            var j: int = 0
            while j < mod.Length:
assertEquals(@base[i] + " modePow(" + exp + ", " + mod[j] + ") should be " + BigInteger.One, BigInteger.One, BigInteger.ModPow(@base[i], exp, mod[j]))
++j
++i
    mod = @[BigInteger.Parse("1")]
      var i: int = 0
      while i < @base.Length:
            var j: int = 0
            while j < mod.Length:
assertEquals(@base[i] + " modePow(" + exp + ", " + mod[j] + ") should be " + BigInteger.Zero, BigInteger.Zero, BigInteger.ModPow(@base[i], exp, mod[j]))
++j
++i
proc testmodInverseException*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var mBytes: byte[] = @[1, 2, 3]
    var aSign: int = 1
    var mSign: int = -1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var modulus: BigInteger = BigInteger(mSign, mBytes)
    try:
BigInteger.ModInverse(aNumber, modulus)
fail("ArithmeticException has not been caught")
    except ArithmeticException:
assertEquals("Improper exception message", "BigInteger: modulus not positive", e.Message)
proc testmodInverseNonInvertible*() =
    var aBytes: byte[] = @[cast[byte](-15), 24, 123, 56, cast[byte](-11), cast[byte](-112), cast[byte](-34), cast[byte](-98), 8, 10, 12, 14, 25, 125, cast[byte](-15), 28, cast[byte](-127)]
    var mBytes: byte[] = @[cast[byte](-12), 1, 0, 0, 0, 23, 44, 55, 66]
    var aSign: int = 1
    var mSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var modulus: BigInteger = BigInteger(mSign, mBytes)
    try:
BigInteger.ModInverse(aNumber, modulus)
fail("ArithmeticException has not been caught")
    except ArithmeticException:
assertEquals("Improper exception message", "BigInteger not invertible.", e.Message)
proc testmodInversePos1*() =
    var aBytes: byte[] = @[24, 123, 56, cast[byte](-11), cast[byte](-112), cast[byte](-34), cast[byte](-98), 8, 10, 12, 14, 25, 125, cast[byte](-15), 28, cast[byte](-127)]
    var mBytes: byte[] = @[122, 45, 36, 100, 122, 45]
    var aSign: int = 1
    var mSign: int = 1
    var rBytes: byte[] = @[47, 3, 96, 62, 87, 19]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var modulus: BigInteger = BigInteger(mSign, mBytes)
    var result: BigInteger = BigInteger.ModInverse(aNumber, modulus)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testmodInversePos2*() =
    var aBytes: byte[] = @[15, 24, 123, 56, cast[byte](-11), cast[byte](-112), cast[byte](-34), cast[byte](-98), 8, 10, 12, 14, 25, 125, cast[byte](-15), 28, cast[byte](-127)]
    var mBytes: byte[] = @[2, 122, 45, 36, 100]
    var aSign: int = 1
    var mSign: int = 1
    var rBytes: byte[] = @[1, cast[byte](-93), 40, 127, 73]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var modulus: BigInteger = BigInteger(mSign, mBytes)
    var result: BigInteger = BigInteger.ModInverse(aNumber, modulus)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testmodInverseNeg1*() =
    var aBytes: byte[] = @[15, 24, 123, 56, cast[byte](-11), cast[byte](-112), cast[byte](-34), cast[byte](-98), 8, 10, 12, 14, 25, 125, cast[byte](-15), 28, cast[byte](-127)]
    var mBytes: byte[] = @[2, 122, 45, 36, 100]
    var aSign: int = -1
    var mSign: int = 1
    var rBytes: byte[] = @[0, cast[byte](-41), 4, cast[byte](-91), 27]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var modulus: BigInteger = BigInteger(mSign, mBytes)
    var result: BigInteger = BigInteger.ModInverse(aNumber, modulus)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testmodInverseNeg2*() =
    var aBytes: byte[] = @[cast[byte](-15), 24, 123, 57, cast[byte](-15), 24, 123, 57, cast[byte](-15), 24, 123, 57]
    var mBytes: byte[] = @[122, 2, 4, 122, 2, 4]
    var rBytes: byte[] = @[85, 47, 127, 4, cast[byte](-128), 45]
    var aNumber: BigInteger = BigInteger(aBytes)
    var modulus: BigInteger = BigInteger(mBytes)
    var result: BigInteger = BigInteger.ModInverse(aNumber, modulus)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testGcdSecondZero*() =
    var aBytes: byte[] = @[15, 24, 123, 57, cast[byte](-15), 24, 123, 57, cast[byte](-15), 24, 123, 57]
    var bBytes: byte[] = @[0]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[15, 24, 123, 57, cast[byte](-15), 24, 123, 57, cast[byte](-15), 24, 123, 57]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Gcd(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testGcdFirstZero*() =
    var aBytes: byte[] = @[0]
    var bBytes: byte[] = @[15, 24, 123, 57, cast[byte](-15), 24, 123, 57, cast[byte](-15), 24, 123, 57]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[15, 24, 123, 57, cast[byte](-15), 24, 123, 57, cast[byte](-15), 24, 123, 57]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Gcd(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testGcdFirstZERO*() =
    var bBytes: byte[] = @[15, 24, 123, 57, cast[byte](-15), 24, 123, 57, cast[byte](-15), 24, 123, 57]
    var bSign: int = 1
    var rBytes: byte[] = @[15, 24, 123, 57, cast[byte](-15), 24, 123, 57, cast[byte](-15), 24, 123, 57]
    var aNumber: BigInteger = BigInteger.Zero
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Gcd(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testGcdBothZeros*() =
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger.Parse("0")
    var bNumber: BigInteger = BigInteger.GetInstance(0)
    var result: BigInteger = BigInteger.Gcd(aNumber, bNumber)
    var resBytes: byte[] = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testGcdFirstLonger*() =
    var aBytes: byte[] = @[cast[byte](-15), 24, 123, 56, cast[byte](-11), cast[byte](-112), cast[byte](-34), cast[byte](-98), 8, 10, 12, 14, 25, 125, cast[byte](-15), 28, cast[byte](-127)]
    var bBytes: byte[] = @[cast[byte](-12), 1, 0, 0, 0, 23, 44, 55, 66]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[7]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Gcd(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testGcdSecondLonger*() =
    var aBytes: byte[] = @[cast[byte](-12), 1, 0, 0, 0, 23, 44, 55, 66]
    var bBytes: byte[] = @[cast[byte](-15), 24, 123, 56, cast[byte](-11), cast[byte](-112), cast[byte](-34), cast[byte](-98), 8, 10, 12, 14, 25, 125, cast[byte](-15), 28, cast[byte](-127)]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[7]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Gcd(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)