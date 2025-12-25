# "Namespace: ICU4N.Numerics.BigMath"
type
  BigIntegerSubtractTest = ref object


proc testCase1*() =
    var aBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[9, 18, 27, 36, 45, 54, 63, 9, 18, 27]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
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
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[cast[byte](-10), cast[byte](-19), cast[byte](-28), cast[byte](-37), cast[byte](-46), cast[byte](-55), cast[byte](-64), cast[byte](-10), cast[byte](-19), cast[byte](-27)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase3*() =
    var aBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: byte[] = @[11, 22, 33, 44, 55, 66, 77, 11, 22, 33]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase4*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: byte[] = @[11, 22, 33, 44, 55, 66, 77, 11, 22, 33]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase5*() =
    var aBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: byte[] = @[cast[byte](-10), cast[byte](-19), cast[byte](-28), cast[byte](-37), cast[byte](-46), cast[byte](-55), cast[byte](-64), cast[byte](-10), cast[byte](-19), cast[byte](-27)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase6*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: byte[] = @[9, 18, 27, 36, 45, 54, 63, 9, 18, 27]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase7*() =
    var aBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: byte[] = @[cast[byte](-12), cast[byte](-23), cast[byte](-34), cast[byte](-45), cast[byte](-56), cast[byte](-67), cast[byte](-78), cast[byte](-12), cast[byte](-23), cast[byte](-33)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase8*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: byte[] = @[cast[byte](-12), cast[byte](-23), cast[byte](-34), cast[byte](-45), cast[byte](-56), cast[byte](-67), cast[byte](-78), cast[byte](-12), cast[byte](-23), cast[byte](-33)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase9*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[1, 2, 3, 3, cast[byte](-6), cast[byte](-15), cast[byte](-24), cast[byte](-40), cast[byte](-49), cast[byte](-58), cast[byte](-67), cast[byte](-6), cast[byte](-15), cast[byte](-23)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase10*() =
    var aBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase11*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: byte[] = @[1, 2, 3, 4, 15, 26, 37, 41, 52, 63, 74, 15, 26, 37]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase12*() =
    var aBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: byte[] = @[1, 2, 3, 4, 15, 26, 37, 41, 52, 63, 74, 15, 26, 37]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase13*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-5), cast[byte](-16), cast[byte](-27), cast[byte](-38), cast[byte](-42), cast[byte](-53), cast[byte](-64), cast[byte](-75), cast[byte](-16), cast[byte](-27), cast[byte](-37)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase14*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-5), cast[byte](-16), cast[byte](-27), cast[byte](-38), cast[byte](-42), cast[byte](-53), cast[byte](-64), cast[byte](-75), cast[byte](-16), cast[byte](-27), cast[byte](-37)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase15*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: byte[] = @[cast[byte](-2), cast[byte](-3), cast[byte](-4), cast[byte](-4), 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase16*() =
    var aBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: byte[] = @[1, 2, 3, 3, cast[byte](-6), cast[byte](-15), cast[byte](-24), cast[byte](-40), cast[byte](-49), cast[byte](-58), cast[byte](-67), cast[byte](-6), cast[byte](-15), cast[byte](-23)]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase17*() =
    var aBytes: byte[] = @[cast[byte](-120), 34, 78, cast[byte](-23), cast[byte](-111), 45, 127, 23, 45, cast[byte](-3)]
    var bBytes: byte[] = @[cast[byte](-120), 34, 78, cast[byte](-23), cast[byte](-111), 45, 127, 23, 45, cast[byte](-3)]
    var rBytes: byte[] = @[0]
    var aSign: int = 1
    var bSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testCase18*() =
    var aBytes: byte[] = @[120, 34, 78, cast[byte](-23), cast[byte](-111), 45, 127, 23, 45, cast[byte](-3)]
    var bBytes: byte[] = @[0]
    var rBytes: byte[] = @[120, 34, 78, cast[byte](-23), cast[byte](-111), 45, 127, 23, 45, cast[byte](-3)]
    var aSign: int = 1
    var bSign: int = 0
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase19*() =
    var aBytes: byte[] = @[0]
    var bBytes: byte[] = @[120, 34, 78, cast[byte](-23), cast[byte](-111), 45, 127, 23, 45, cast[byte](-3)]
    var rBytes: byte[] = @[120, 34, 78, cast[byte](-23), cast[byte](-111), 45, 127, 23, 45, cast[byte](-3)]
    var aSign: int = 0
    var bSign: int = -1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase20*() =
    var aBytes: byte[] = @[0]
    var bBytes: byte[] = @[0]
    var rBytes: byte[] = @[0]
    var aSign: int = 0
    var bSign: int = 0
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testCase21*() =
    var aBytes: byte[] = @[120, 34, 78, cast[byte](-23), cast[byte](-111), 45, 127, 23, 45, cast[byte](-3)]
    var rBytes: byte[] = @[120, 34, 78, cast[byte](-23), cast[byte](-111), 45, 127, 23, 45, cast[byte](-3)]
    var aSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger.Zero
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase22*() =
    var bBytes: byte[] = @[120, 34, 78, cast[byte](-23), cast[byte](-111), 45, 127, 23, 45, cast[byte](-3)]
    var rBytes: byte[] = @[120, 34, 78, cast[byte](-23), cast[byte](-111), 45, 127, 23, 45, cast[byte](-3)]
    var bSign: int = -1
    var aNumber: BigInteger = BigInteger.Zero
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase23*() =
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger.Zero
    var bNumber: BigInteger = BigInteger.Zero
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testCase24*() =
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger.One
    var bNumber: BigInteger = BigInteger.One
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testCase25*() =
    var aBytes: byte[] = @[cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1)]
    var bBytes: byte[] = @[cast[byte](-128), cast[byte](-128), cast[byte](-128), cast[byte](-128), cast[byte](-128), cast[byte](-128), cast[byte](-128), cast[byte](-128), cast[byte](-128)]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[cast[byte](-128), 127, 127, 127, 127, 127, 127, 127, 127]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber - bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, result.Sign)