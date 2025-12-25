# "Namespace: ICU4N.Numerics.BigMath"
type
  BigIntegerDivideTest = ref object


proc testCase1*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[0]
    var aSign: int = 1
    var bSign: int = 0
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    try:
        var _ = aNumber / bNumber
fail("ArithmeticException has not been caught")
    except DivideByZeroException:
assertEquals("Improper exception message", "BigInteger divide by zero", e.Message)
proc testCase2*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var aSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger.Zero
    try:
        var _ = aNumber / bNumber
fail("ArithmeticException has not been caught")
    except DivideByZeroException:
assertEquals("Improper exception message", "BigInteger divide by zero", e.Message)
proc testCase3*() =
    var aBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127]
    var bBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[1]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase4*() =
    var aBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127]
    var bBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: byte[] = @[cast[byte](-1)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase5*() =
    var aBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127]
    var bBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127, 1, 2, 3, 4, 5]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testCase6*() =
    var aBytes: byte[] = @[1, 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127]
    var bBytes: byte[] = @[15, 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testCase7*() =
    var aBytes: byte[] = @[1, 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127, 5, 6, 7, 8, 9]
    var bBytes: byte[] = @[15, 48, cast[byte](-29), 7, 98, cast[byte](-1), 39, cast[byte](-128)]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[23, 115, 11, 78, 35, cast[byte](-11)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase8*() =
    var aBytes: byte[] = @[1, 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127, 5, 6, 7, 8, 9]
    var bBytes: byte[] = @[15, 48, cast[byte](-29), 7, 98, cast[byte](-1), 39, cast[byte](-128)]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: byte[] = @[cast[byte](-24), cast[byte](-116), cast[byte](-12), cast[byte](-79), cast[byte](-36), 11]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase9*() =
    var aBytes: byte[] = @[1, 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127, 5, 6, 7, 8, 9]
    var bBytes: byte[] = @[15, 48, cast[byte](-29), 7, 98, cast[byte](-1), 39, cast[byte](-128)]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: byte[] = @[cast[byte](-24), cast[byte](-116), cast[byte](-12), cast[byte](-79), cast[byte](-36), 11]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase10*() =
    var aBytes: byte[] = @[1, 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127, 5, 6, 7, 8, 9]
    var bBytes: byte[] = @[15, 48, cast[byte](-29), 7, 98, cast[byte](-1), 39, cast[byte](-128)]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: byte[] = @[23, 115, 11, 78, 35, cast[byte](-11)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase11*() =
    var aBytes: byte[] = @[0]
    var bBytes: byte[] = @[15, 48, cast[byte](-29), 7, 98, cast[byte](-1), 39, cast[byte](-128)]
    var aSign: int = 0
    var bSign: int = -1
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testCase12*() =
    var bBytes: byte[] = @[15, 48, cast[byte](-29), 7, 98, cast[byte](-1), 39, cast[byte](-128)]
    var bSign: int = -1
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger.Zero
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testCase13*() =
    var aBytes: byte[] = @[15, 48, cast[byte](-29), 7, 98, cast[byte](-1), 39, cast[byte](-128)]
    var aSign: int = 1
    var rBytes: byte[] = @[15, 48, cast[byte](-29), 7, 98, cast[byte](-1), 39, cast[byte](-128)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger.One
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase14*() =
    var rBytes: byte[] = @[1]
    var aNumber: BigInteger = BigInteger.One
    var bNumber: BigInteger = BigInteger.One
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testDivisionKnuth1*() =
    var aBytes: byte[] = @[cast[byte](-7), cast[byte](-6), cast[byte](-5), cast[byte](-4), cast[byte](-3), cast[byte](-2), cast[byte](-1), 0, 1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[cast[byte](-3), cast[byte](-3), cast[byte](-3), cast[byte](-3)]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[0, cast[byte](-5), cast[byte](-12), cast[byte](-33), cast[byte](-96), cast[byte](-36), cast[byte](-105), cast[byte](-56), 92, 15, 48, cast[byte](-109)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testDivisionKnuthIsNormalized*() =
    var aBytes: byte[] = @[cast[byte](-9), cast[byte](-8), cast[byte](-7), cast[byte](-6), cast[byte](-5), cast[byte](-4), cast[byte](-3), cast[byte](-2), cast[byte](-1), 0, 1, 2, 3, 4, 5]
    var bBytes: byte[] = @[cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1)]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: byte[] = @[0, cast[byte](-9), cast[byte](-8), cast[byte](-7), cast[byte](-6), cast[byte](-5), cast[byte](-4), cast[byte](-3)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testDivisionKnuthFirstDigitsEqual*() =
    var aBytes: byte[] = @[2, cast[byte](-3), cast[byte](-4), cast[byte](-5), cast[byte](-1), cast[byte](-5), cast[byte](-4), cast[byte](-3), cast[byte](-2), cast[byte](-1), 0, 1, 2, 3, 4, 5]
    var bBytes: byte[] = @[2, cast[byte](-3), cast[byte](-4), cast[byte](-5), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1)]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: byte[] = @[0, cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-2), cast[byte](-88), cast[byte](-60), 41]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testDivisionKnuthOneDigitByOneDigit*() =
    var aBytes: byte[] = @[113, cast[byte](-83), 123, cast[byte](-5)]
    var bBytes: byte[] = @[2, cast[byte](-3), cast[byte](-4), cast[byte](-5)]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: byte[] = @[cast[byte](-37)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testDivisionKnuthMultiDigitsByOneDigit*() =
    var aBytes: byte[] = @[113, cast[byte](-83), 123, cast[byte](-5), 18, cast[byte](-34), 67, 39, cast[byte](-29)]
    var bBytes: byte[] = @[2, cast[byte](-3), cast[byte](-4), cast[byte](-5)]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: byte[] = @[cast[byte](-38), 2, 7, 30, 109, cast[byte](-43)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber / bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase15*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[0]
    var aSign: int = 1
    var bSign: int = 0
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    try:
BigInteger.Remainder(aNumber, bNumber)
fail("ArithmeticException has not been caught")
    except ArithmeticException:
assertEquals("Improper exception message", "BigInteger divide by zero", e.Message)
proc testCase16*() =
    var aBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127]
    var bBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Remainder(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testCase17*() =
    var aBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127, 75]
    var bBytes: byte[] = @[27, cast[byte](-15), 65, 39, 100]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[12, cast[byte](-21), 73, 56, 27]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Remainder(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase18*() =
    var aBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127, 75]
    var bBytes: byte[] = @[27, cast[byte](-15), 65, 39, 100]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: byte[] = @[cast[byte](-13), 20, cast[byte](-74), cast[byte](-57), cast[byte](-27)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Remainder(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase19*() =
    var aBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127, 75]
    var bBytes: byte[] = @[27, cast[byte](-15), 65, 39, 100]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: byte[] = @[12, cast[byte](-21), 73, 56, 27]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Remainder(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase20*() =
    var aBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127, 75]
    var bBytes: byte[] = @[27, cast[byte](-15), 65, 39, 100]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: byte[] = @[cast[byte](-13), 20, cast[byte](-74), cast[byte](-57), cast[byte](-27)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Remainder(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testRemainderKnuth1*() =
    var aBytes: byte[] = @[cast[byte](-9), cast[byte](-8), cast[byte](-7), cast[byte](-6), cast[byte](-5), cast[byte](-4), cast[byte](-3), cast[byte](-2), cast[byte](-1), 0, 1]
    var bBytes: byte[] = @[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 7, 18, cast[byte](-89)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Remainder(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testRemainderKnuthOneDigitByOneDigit*() =
    var aBytes: byte[] = @[113, cast[byte](-83), 123, cast[byte](-5)]
    var bBytes: byte[] = @[2, cast[byte](-3), cast[byte](-4), cast[byte](-50)]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: byte[] = @[2, cast[byte](-9), cast[byte](-14), 53]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Remainder(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testRemainderKnuthMultiDigitsByOneDigit*() =
    var aBytes: byte[] = @[113, cast[byte](-83), 123, cast[byte](-5), 18, cast[byte](-34), 67, 39, cast[byte](-29)]
    var bBytes: byte[] = @[2, cast[byte](-3), cast[byte](-4), cast[byte](-50)]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: byte[] = @[2, cast[byte](-37), cast[byte](-60), 59]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = BigInteger.Remainder(aNumber, bNumber)
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase21*() =
    var aBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127, 75]
    var bBytes: byte[] = @[27, cast[byte](-15), 65, 39, 100]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: byte[][] = @[@[cast[byte](-5), 94, cast[byte](-115), cast[byte](-74), cast[byte](-85), 84], @[cast[byte](-13), 20, cast[byte](-74), cast[byte](-57), cast[byte](-27)]]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result0: BigInteger = BigInteger.DivideAndRemainder(aNumber, bNumber,     var result1: BigInteger)
    var resBytes: byte[]
    resBytes = result0.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
          if resBytes[i] != rBytes[0][i]:
fail("Incorrect quotation")
++i
assertEquals("incorrect sign", -1, result0.Sign)
    resBytes = result1.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
          if resBytes[i] != rBytes[1][i]:
fail("Incorrect remainder")
assertEquals("incorrect sign", -1, result1.Sign)
++i
proc testCase22*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[1, 30, 40, 56, cast[byte](-1), 45]
    var aSign: int = 1
    var bSign: int = -1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    try:
        var _ = aNumber % bNumber
fail("ArithmeticException has not been caught")
    except ArithmeticException:
assertEquals("Improper exception message", "BigInteger: modulus not positive", e.Message)
proc testCase23*() =
    var aBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127, 75]
    var bBytes: byte[] = @[27, cast[byte](-15), 65, 39, 100]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[12, cast[byte](-21), 73, 56, 27]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber % bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase24*() =
    var aBytes: byte[] = @[cast[byte](-127), 100, 56, 7, 98, cast[byte](-1), 39, cast[byte](-128), 127, 75]
    var bBytes: byte[] = @[27, cast[byte](-15), 65, 39, 100]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: byte[] = @[15, 5, cast[byte](-9), cast[byte](-17), 73]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber % bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)