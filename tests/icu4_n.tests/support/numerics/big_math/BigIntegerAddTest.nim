# "Namespace: ICU4N.Numerics.BigMath"
type
  BigIntegerAddTest = ref object


proc testCase1*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[11, 22, 33, 44, 55, 66, 77, 11, 22, 33]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[] = seq[byte]
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
    var bSign: int = -1
    var rBytes: sbyte[] = @[-12, -23, -34, -45, -56, -67, -78, -12, -23, -33]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase3*() =
    var aBytes: byte[] = @[3, 4, 5, 6, 7, 8, 9]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var rBytes: byte[] = @[2, 2, 2, 2, 2, 2, 2]
    var aSign: int = 1
    var bSign: int = -1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase4*() =
    var aBytes: byte[] = @[3, 4, 5, 6, 7, 8, 9]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var rBytes: sbyte[] = @[-3, -3, -3, -3, -3, -3, -2]
    var aSign: int = -1
    var bSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase5*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[3, 4, 5, 6, 7, 8, 9]
    var rBytes: sbyte[] = @[-3, -3, -3, -3, -3, -3, -2]
    var aSign: int = 1
    var bSign: int = -1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase6*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[3, 4, 5, 6, 7, 8, 9]
    var rBytes: byte[] = @[2, 2, 2, 2, 2, 2, 2]
    var aSign: int = -1
    var bSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase7*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = 1
    var bSign: int = 1
    var rBytes: byte[] = @[1, 2, 3, 4, 15, 26, 37, 41, 52, 63, 74, 15, 26, 37]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase8*() =
    var aBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7]
    var rBytes: byte[] = @[1, 2, 3, 4, 15, 26, 37, 41, 52, 63, 74, 15, 26, 37]
    var aNumber: BigInteger = BigInteger(aBytes)
    var bNumber: BigInteger = BigInteger(bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase9*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: sbyte[] = @[-2, -3, -4, -5, -16, -27, -38, -42, -53, -64, -75, -16, -27, -37]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase10*() =
    var aBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7]
    var aSign: int = -1
    var bSign: int = -1
    var rBytes: sbyte[] = @[-2, -3, -4, -5, -16, -27, -38, -42, -53, -64, -75, -16, -27, -37]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase11*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: sbyte[] = @[1, 2, 3, 3, -6, -15, -24, -40, -49, -58, -67, -6, -15, -23]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase12*() =
    var aBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7]
    var aSign: int = 1
    var bSign: int = -1
    var rBytes: sbyte[] = @[-2, -3, -4, -4, 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase13*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: sbyte[] = @[-2, -3, -4, -4, 5, 14, 23, 39, 48, 57, 66, 5, 14, 23]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", -1, result.Sign)
proc testCase14*() =
    var aBytes: byte[] = @[10, 20, 30, 40, 50, 60, 70, 10, 20, 30]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7]
    var aSign: int = -1
    var bSign: int = 1
    var rBytes: sbyte[] = @[1, 2, 3, 3, -6, -15, -24, -40, -49, -58, -67, -6, -15, -23]
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase15*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var rBytes: byte[] = @[0]
    var aSign: int = -1
    var bSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testCase16*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var bBytes: byte[] = @[0]
    var rBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var aSign: int = 1
    var bSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase17*() =
    var aBytes: byte[] = @[0]
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var rBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var aSign: int = 1
    var bSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase18*() =
    var aBytes: byte[] = @[0]
    var bBytes: byte[] = @[0]
    var rBytes: byte[] = @[0]
    var aSign: int = 1
    var bSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testCase19*() =
    var aBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var rBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var aSign: int = 1
    var aNumber: BigInteger = BigInteger(aSign, aBytes)
    var bNumber: BigInteger = BigInteger.Zero
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase20*() =
    var bBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var rBytes: byte[] = @[1, 2, 3, 4, 5, 6, 7]
    var bSign: int = 1
    var aNumber: BigInteger = BigInteger.Zero
    var bNumber: BigInteger = BigInteger(bSign, bBytes)
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[] = seq[byte]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase21*() =
    var rBytes: byte[] = @[0]
    var aNumber: BigInteger = BigInteger.Zero
    var bNumber: BigInteger = BigInteger.Zero
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, result.Sign)
proc testCase22*() =
    var rBytes: byte[] = @[2]
    var aNumber: BigInteger = BigInteger.One
    var bNumber: BigInteger = BigInteger.One
    var result: BigInteger = aNumber + bNumber
    var resBytes: byte[]
    resBytes = result.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, result.Sign)
proc testCase23*() =
      var aBytes: byte[] = @[cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1)]
      var bBytes: byte[] = @[cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1)]
      var aSign: int = 1
      var bSign: int = 1
      var rBytes: sbyte[] = @[1, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1, -1, -2]
      var aNumber: BigInteger = BigInteger(aSign, aBytes)
      var bNumber: BigInteger = BigInteger(bSign, bBytes)
      var result: BigInteger = aNumber + bNumber
      var resBytes: byte[]
      resBytes = result.ToByteArray
        var i: int = 0
        while i < resBytes.Length:
assertTrue("incorrect value", resBytes[i] == cast[byte](rBytes[i]))
++i
assertEquals("incorrect sign", 1, result.Sign)