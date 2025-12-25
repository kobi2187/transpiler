# "Namespace: ICU4N.Numerics.BigMath"
type
  BigIntegerTest = ref object
    minusTwo: BigInteger
    minusOne: BigInteger
    zero: BigInteger
    one: BigInteger
    two: BigInteger
    ten: BigInteger
    sixteen: BigInteger
    oneThousand: BigInteger
    aZillion: BigInteger
    twoToTheTen: BigInteger
    twoToTheSeventy: BigInteger
    rand: Random = Randomizer
    bi: BigInteger
    bi1: BigInteger
    bi2: BigInteger
    bi3: BigInteger
    bi11: BigInteger
    bi22: BigInteger
    bi33: BigInteger
    bi12: BigInteger
    bi23: BigInteger
    bi13: BigInteger
    largePos: BigInteger
    smallPos: BigInteger
    largeNeg: BigInteger
    smallNeg: BigInteger
    boolPairs: seq[BigInteger]

proc newBigIntegerTest(): BigIntegerTest =
  minusTwo = BigInteger.Parse("-2", 10)
  minusOne = BigInteger.Parse("-1", 10)
  zero = BigInteger.Parse("0", 10)
  one = BigInteger.Parse("1", 10)
  two = BigInteger.Parse("2", 10)
  ten = BigInteger.Parse("10", 10)
  sixteen = BigInteger.Parse("16", 10)
  oneThousand = BigInteger.Parse("1000", 10)
  aZillion = BigInteger.Parse("100000000000000000000000000000000000000000000000000", 10)
  twoToTheTen = BigInteger.Parse("1024", 10)
  twoToTheSeventy = BigInteger.Pow(two, 70)
proc test_ConstructorILjava_util_Random*() =
    try:
BigInteger(int.MaxValue, cast[Random](nil))
fail("NegativeArraySizeException expected")
    except OverflowException:

    bi = BigInteger(70, rand)
    bi2 = BigInteger(70, rand)
assertTrue("Random number is negative", bi.CompareTo(zero) >= 0)
assertTrue("Random number is too big", bi.CompareTo(twoToTheSeventy) < 0)
assertTrue("Two random numbers in a row are the same (might not be a bug but it very likely is)", !bi.Equals(bi2))
assertTrue("Not zero", BigInteger(0, rand).Equals(BigInteger.Zero))
proc test_ConstructorIILjava_util_Random*() =
    bi = BigInteger(10, 5, rand)
    bi2 = BigInteger(10, 5, rand)
assertTrue("Random number one is negative", bi.CompareTo(zero) >= 0)
assertTrue("Random number one is too big", bi.CompareTo(twoToTheTen) < 0)
assertTrue("Random number two is negative", bi2.CompareTo(zero) >= 0)
assertTrue("Random number two is too big", bi2.CompareTo(twoToTheTen) < 0)
      var rand: Random = Random
      var bi: BigInteger
      var certainty: int[] = @[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, int.MinValue, int.MinValue + 1, -2, -1]
        var i: int = 2
        while i <= 20:
              var c: int = 0
              while c < certainty.Length:
                  bi = BigInteger(i, c, rand)
assertTrue("Bit length incorrect", bi.BitLength == i)
++c
++i
proc test_Constructor_B*() =
    var myByteArray: byte[]
    myByteArray = @[cast[byte](0), cast[byte](255), cast[byte](254)]
    bi = BigInteger(myByteArray)
assertTrue("Incorrect value for pos number", bi.Equals(BigInteger.SetBit(BigInteger.Zero, 16) - two))
    myByteArray = @[cast[byte](255), cast[byte](254)]
    bi = BigInteger(myByteArray)
assertTrue("Incorrect value for neg number", bi.Equals(minusTwo))
proc test_ConstructorI_B*() =
    var myByteArray: byte[]
    myByteArray = @[cast[byte](255), cast[byte](254)]
    bi = BigInteger(1, myByteArray)
assertTrue("Incorrect value for pos number", bi.Equals(BigInteger.SetBit(BigInteger.Zero, 16) - two))
    bi = BigInteger(-1, myByteArray)
assertTrue("Incorrect value for neg number", bi.Equals(-BigInteger.SetBit(BigInteger.Zero, 16) - two))
    myByteArray = @[cast[byte](0), cast[byte](0)]
    bi = BigInteger(0, myByteArray)
assertTrue("Incorrect value for zero", bi.Equals(zero))
    myByteArray = @[cast[byte](1)]
    try:
BigInteger(0, myByteArray)
fail("Failed to throw NumberFormatException")
    except FormatException:

proc test_constructor_String_empty*() =
    try:
BigInteger.Parse("")
fail("Expected NumberFormatException for new BigInteger("")")
    except FormatException:

proc test_toByteArray*() =
      var myByteArray: byte[]
      var anotherByteArray: byte[]
    myByteArray = @[97, 33, 120, 124, 50, 2, 0, 0, 0, 12, 124, 42]
    anotherByteArray = BigInteger(myByteArray).ToByteArray
assertTrue("Incorrect byte array returned", myByteArray.Length == anotherByteArray.Length)
      var counter: int = myByteArray.Length - 1
      while counter >= 0:
assertTrue("Incorrect values in returned byte array", myByteArray[counter] == anotherByteArray[counter])
--counter
proc test_isProbablePrimeI*() =
    var fails: int = 0
    bi = BigInteger(20, 20, rand)
    if !BigInteger.IsProbablePrime(bi, 17):
++fails
    bi = BigInteger.Parse("4", 10)
    if BigInteger.IsProbablePrime(bi, 17):
fail("isProbablePrime failed for: " + bi)
    bi = BigInteger.GetInstance(17 * 13)
    if BigInteger.IsProbablePrime(bi, 17):
fail("isProbablePrime failed for: " + bi)
      var a: long = 2
      while a < 1000:
          if isPrime(a):
assertTrue("false negative on prime number <1000", BigInteger.IsProbablePrime(BigInteger.GetInstance(a), 5))

          elif BigInteger.IsProbablePrime(BigInteger.GetInstance(a), 17):
Console.Out.WriteLine("isProbablePrime failed for: " + a)
++fails
++a
      var a: int = 0
      while a < 1000:
          bi = BigInteger.GetInstance(rand.Next(1000000)) * BigInteger.GetInstance(rand.Next(1000000))
          if BigInteger.IsProbablePrime(bi, 17):
Console.Out.WriteLine("isProbablePrime failed for: " + bi)
++fails
++a
      var a: int = 0
      while a < 200:
          bi = BigInteger(70, rand) * BigInteger(70, rand)
          if BigInteger.IsProbablePrime(bi, 17):
Console.Out.WriteLine("isProbablePrime failed for: " + bi)
++fails
++a
assertTrue("Too many false positives - may indicate a problem", fails <= 1)
proc test_equalsLjava_lang_Object*() =
assertTrue("0=0", zero.Equals(BigInteger.GetInstance(0)))
assertTrue("-123=-123", BigInteger.GetInstance(-123).Equals(BigInteger.GetInstance(-123)))
assertTrue("0=1", !zero.Equals(one))
assertTrue("0=-1", !zero.Equals(minusOne))
assertTrue("1=-1", !one.Equals(minusOne))
assertTrue("bi3=bi3", bi3.Equals(bi3))
assertTrue("bi3=copy of bi3", bi3.Equals(--bi3))
assertTrue("bi3=bi2", !bi3.Equals(bi2))
proc test_compareToLjava_math_BigInteger*() =
assertTrue("Smaller number returned >= 0", one.CompareTo(two) < 0)
assertTrue("Larger number returned >= 0", two.CompareTo(one) > 0)
assertTrue("Equal numbers did not return 0", one.CompareTo(one) == 0)
assertTrue("Neg number messed things up", -two.CompareTo(one) < 0)
proc test_intValue*() =
assertTrue("Incorrect intValue for 2**70", twoToTheSeventy.ToInt32 == 0)
assertTrue("Incorrect intValue for 2", two.ToInt32 == 2)
proc test_longValue*() =
assertTrue("Incorrect longValue for 2**70", twoToTheSeventy.ToInt64 == 0)
assertTrue("Incorrect longValue for 2", two.ToInt64 == 2)
proc test_valueOfJ*() =
assertTrue("Incurred number returned for 2", BigInteger.GetInstance(2).Equals(two))
assertTrue("Incurred number returned for 200", BigInteger.GetInstance(200).Equals(BigInteger.GetInstance(139) + BigInteger.GetInstance(61)))
proc test_addLjava_math_BigInteger*() =
assertTrue("Incorrect sum--wanted a zillion", aZillion + aZillion + -aZillion.Equals(aZillion))
assertTrue("0+0", zero + zero.Equals(zero))
assertTrue("0+1", zero + one.Equals(one))
assertTrue("1+0", one + zero.Equals(one))
assertTrue("1+1", one + one.Equals(two))
assertTrue("0+(-1)", zero + minusOne.Equals(minusOne))
assertTrue("(-1)+0", minusOne + zero.Equals(minusOne))
assertTrue("(-1)+(-1)", minusOne + minusOne.Equals(minusTwo))
assertTrue("1+(-1)", one + minusOne.Equals(zero))
assertTrue("(-1)+1", minusOne + one.Equals(zero))
      var i: int = 0
      while i < 200:
          var midbit: BigInteger = BigInteger.SetBit(zero, i)
assertTrue("add fails to carry on bit " + i, midbit + midbit.Equals(BigInteger.SetBit(zero, i + 1)))
++i
    var bi2p3: BigInteger = bi2 + bi3
    var bi3p2: BigInteger = bi3 + bi2
assertTrue("bi2p3=bi3p2", bi2p3.Equals(bi3p2))
proc test_negate*() =
assertTrue("Single negation of zero did not result in zero", -zero.Equals(zero))
assertTrue("Single negation resulted in original nonzero number", !-aZillion.Equals(aZillion))
assertTrue("Double negation did not result in original number", --aZillion.Equals(aZillion))
assertTrue("0.neg", -zero.Equals(zero))
assertTrue("1.neg", -one.Equals(minusOne))
assertTrue("2.neg", -two.Equals(minusTwo))
assertTrue("-1.neg", -minusOne.Equals(one))
assertTrue("-2.neg", -minusTwo.Equals(two))
assertTrue("0x62EB40FEF85AA9EBL*2.neg", -BigInteger.GetInstance(7127862299076504043 * 2).Equals(BigInteger.GetInstance(-7127862299076504043 * 2)))
      var i: int = 0
      while i < 200:
          var midbit: BigInteger = BigInteger.SetBit(zero, i)
          var negate: BigInteger = -midbit
assertTrue("negate negate", -negate.Equals(midbit))
assertTrue("neg fails on bit " + i, -midbit + midbit.Equals(zero))
++i
proc test_signum*() =
assertTrue("Wrong positive signum", two.Sign == 1)
assertTrue("Wrong zero signum", zero.Sign == 0)
assertTrue("Wrong neg zero signum", -zero.Sign == 0)
assertTrue("Wrong neg signum", -two.Sign == -1)
proc test_abs*() =
assertTrue("Invalid number returned for zillion", BigInteger.Abs(-aZillion).Equals(BigInteger.Abs(aZillion)))
assertTrue("Invalid number returned for zero neg", BigInteger.Abs(-zero).Equals(zero))
assertTrue("Invalid number returned for zero", BigInteger.Abs(zero).Equals(zero))
assertTrue("Invalid number returned for two", BigInteger.Abs(-two).Equals(two))
proc test_powI*() =
assertTrue("Incorrect exponent returned for 2**10", BigInteger.Pow(two, 10).Equals(twoToTheTen))
assertTrue("Incorrect exponent returned for 2**70", BigInteger.Pow(two, 30) * BigInteger.Pow(two, 40).Equals(twoToTheSeventy))
assertTrue("Incorrect exponent returned for 10**50", BigInteger.Pow(ten, 50).Equals(aZillion))
proc test_modInverseLjava_math_BigInteger*() =
      var a: BigInteger = zero
      var mod: BigInteger
      var inv: BigInteger
      var j: int = 3
      while j < 50:
          mod = BigInteger.GetInstance(j)
            var i: int = -j + 1
            while i < j:
                try:
                    a = BigInteger.GetInstance(i)
                    inv = BigInteger.ModInverse(a, mod)
assertTrue("bad inverse: " + a + " inv mod " + mod + " equals " + inv, one.Equals(BigInteger.Mod(a * inv, mod)))
assertTrue("inverse greater than modulo: " + a + " inv mod " + mod + " equals " + inv, inv.CompareTo(mod) < 0)
assertTrue("inverse less than zero: " + a + " inv mod " + mod + " equals " + inv, inv.CompareTo(BigInteger.Zero) >= 0)
                except ArithmeticException:
assertTrue("should have found inverse for " + a + " mod " + mod, !one.Equals(BigInteger.Gcd(a, mod)))
++i
++j
      var j: int = 1
      while j < 10:
          mod = bi2 + BigInteger.GetInstance(j)
            var i: int = 0
            while i < 20:
                try:
                    a = bi3 + BigInteger.GetInstance(i)
                    inv = BigInteger.ModInverse(a, mod)
assertTrue("bad inverse: " + a + " inv mod " + mod + " equals " + inv, one.Equals(BigInteger.Mod(a * inv, mod)))
assertTrue("inverse greater than modulo: " + a + " inv mod " + mod + " equals " + inv, inv.CompareTo(mod) < 0)
assertTrue("inverse less than zero: " + a + " inv mod " + mod + " equals " + inv, inv.CompareTo(BigInteger.Zero) >= 0)
                except ArithmeticException:
assertTrue("should have found inverse for " + a + " mod " + mod, !one.Equals(BigInteger.Gcd(a, mod)))
++i
++j
proc test_shiftRightI*() =
assertTrue("1 >> 0", BigInteger.GetInstance(1) >> 0 == BigInteger.One)
assertTrue("1 >> 1", BigInteger.GetInstance(1) >> 1 == BigInteger.Zero)
assertTrue("1 >> 63", BigInteger.GetInstance(1) >> 63 == BigInteger.Zero)
assertTrue("1 >> 64", BigInteger.GetInstance(1) >> 64 == BigInteger.Zero)
assertTrue("1 >> 65", BigInteger.GetInstance(1) >> 65 == BigInteger.Zero)
assertTrue("1 >> 1000", BigInteger.GetInstance(1) >> 1000 == BigInteger.Zero)
assertTrue("-1 >> 0", BigInteger.GetInstance(-1) >> 0 == minusOne)
assertTrue("-1 >> 1", BigInteger.GetInstance(-1) >> 1 == minusOne)
assertTrue("-1 >> 63", BigInteger.GetInstance(-1) >> 63 == minusOne)
assertTrue("-1 >> 64", BigInteger.GetInstance(-1) >> 64 == minusOne)
assertTrue("-1 >> 65", BigInteger.GetInstance(-1) >> 65 == minusOne)
assertTrue("-1 >> 1000", BigInteger.GetInstance(-1) >> 1000 == minusOne)
    var a: BigInteger = BigInteger.One
    var c: BigInteger = bi3
    var E: BigInteger = -bi3
    var e: BigInteger = E
      var i: int = 0
      while i < 200:
          var b: BigInteger = BigInteger.SetBit(BigInteger.Zero, i)
assertTrue("a==b", a == b)
          a = a << 1
assertTrue("a non-neg", a.Sign >= 0)
          var d: BigInteger = bi3 >> i
assertTrue("c==d", c == d)
          c = c >> 1
assertTrue(">>1 == /2", d / two == c)
assertTrue("c non-neg", c.Sign >= 0)
          var f: BigInteger = E >> i
assertTrue("e==f", e.Equals(f))
          e = e >> 1
assertTrue(">>1 == /2", f - one / two == e)
assertTrue("e negative", e.Sign == -1)
assertTrue("b >> i", b >> i == one)
assertTrue("b >> i+1", b >> i + 1 == zero)
assertTrue("b >> i-1", b >> i - 1 == two)
++i
proc test_shiftLeftI*() =
assertTrue("1 << 0", one << 0 == one)
assertTrue("1 << 1", one << 1 == two)
assertTrue("1 << 63", one << 63 == BigInteger.Parse("8000000000000000", 16))
assertTrue("1 << 64", one << 64 == BigInteger.Parse("10000000000000000", 16))
assertTrue("1 << 65", one << 65 == BigInteger.Parse("20000000000000000", 16))
assertTrue("-1 << 0", minusOne << 0 == minusOne)
assertTrue("-1 << 1", minusOne << 1 == minusTwo)
assertTrue("-1 << 63", minusOne << 63 == BigInteger.Parse("-9223372036854775808"))
assertTrue("-1 << 64", minusOne << 64 == BigInteger.Parse("-18446744073709551616"))
assertTrue("-1 << 65", minusOne << 65 == BigInteger.Parse("-36893488147419103232"))
    var a: BigInteger = bi3
    var c: BigInteger = minusOne
      var i: int = 0
      while i < 200:
          var b: BigInteger = bi3 << i
assertTrue("a==b", a == b)
assertTrue("a >> i == bi3", a >> i == bi3)
          a = a << 1
assertTrue("<<1 == *2", b * two == a)
assertTrue("a non-neg", a.Sign >= 0)
assertTrue("a.bitCount==b.bitCount", a.BitCount == b.BitCount)
          var d: BigInteger = minusOne << i
assertTrue("c==d", c == d)
          c = c << 1
assertTrue("<<1 == *2 negative", d * two == c)
assertTrue("c negative", c.Sign == -1)
assertTrue("d >> i == minusOne", d >> i == minusOne)
++i
proc test_multiplyLjava_math_BigInteger*() =
assertTrue("Incorrect sum--wanted three zillion", aZillion + aZillion + aZillion == aZillion * BigInteger.Parse("3", 10))
assertTrue("0*0", zero * zero == zero)
assertTrue("0*1", zero * one == zero)
assertTrue("1*0", one * zero == zero)
assertTrue("1*1", one * one == one)
assertTrue("0*(-1)", zero * minusOne == zero)
assertTrue("(-1)*0", minusOne * zero == zero)
assertTrue("(-1)*(-1)", minusOne * minusOne == one)
assertTrue("1*(-1)", one * minusOne == minusOne)
assertTrue("(-1)*1", minusOne * one == minusOne)
testAllMults(bi1, bi1, bi11)
testAllMults(bi2, bi2, bi22)
testAllMults(bi3, bi3, bi33)
testAllMults(bi1, bi2, bi12)
testAllMults(bi1, bi3, bi13)
testAllMults(bi2, bi3, bi23)
proc test_divideLjava_math_BigInteger*() =
testAllDivs(bi33, bi3)
testAllDivs(bi22, bi2)
testAllDivs(bi11, bi1)
testAllDivs(bi13, bi1)
testAllDivs(bi13, bi3)
testAllDivs(bi12, bi1)
testAllDivs(bi12, bi2)
testAllDivs(bi23, bi2)
testAllDivs(bi23, bi3)
testAllDivs(largePos, bi1)
testAllDivs(largePos, bi2)
testAllDivs(largePos, bi3)
testAllDivs(largeNeg, bi1)
testAllDivs(largeNeg, bi2)
testAllDivs(largeNeg, bi3)
testAllDivs(largeNeg, largePos)
testAllDivs(largePos, largeNeg)
testAllDivs(bi3, bi3)
testAllDivs(bi2, bi2)
testAllDivs(bi1, bi1)
testDivRanges(bi1)
testDivRanges(bi2)
testDivRanges(bi3)
testDivRanges(smallPos)
testDivRanges(largePos)
testDivRanges(BigInteger.Parse("62EB40FEF85AA9EB", 16))
testAllDivs(BigInteger.GetInstance(876209345852), BigInteger.GetInstance(7402403685))
    try:
        var _ = largePos / zero
fail("ArithmeticException expected")
    except DivideByZeroException:

    try:
        var _ = bi1 / zero
fail("ArithmeticException expected")
    except DivideByZeroException:

    try:
        var _ = -bi3 / zero
fail("ArithmeticException expected")
    except DivideByZeroException:

    try:
        var _ = zero / zero
fail("ArithmeticException expected")
    except DivideByZeroException:

proc test_remainderLjava_math_BigInteger*() =
    try:
BigInteger.Remainder(largePos, zero)
fail("ArithmeticException expected")
    except DivideByZeroException:

    try:
BigInteger.Remainder(bi1, zero)
fail("ArithmeticException expected")
    except DivideByZeroException:

    try:
BigInteger.Remainder(-bi3, zero)
fail("ArithmeticException expected")
    except DivideByZeroException:

    try:
BigInteger.Remainder(zero, zero)
fail("ArithmeticException expected")
    except DivideByZeroException:

proc test_modLjava_math_BigInteger*() =
    try:
BigInteger.Mod(largePos, zero)
fail("ArithmeticException expected")
    except ArithmeticException:

    try:
BigInteger.Mod(bi1, zero)
fail("ArithmeticException expected")
    except ArithmeticException:

    try:
BigInteger.Mod(-bi3, zero)
fail("ArithmeticException expected")
    except ArithmeticException:

    try:
BigInteger.Mod(zero, zero)
fail("ArithmeticException expected")
    except ArithmeticException:

proc test_divideAndRemainderLjava_math_BigInteger*() =
    try:
BigInteger.DivideAndRemainder(largePos, zero,         var _: BigInteger)
fail("ArithmeticException expected")
    except DivideByZeroException:

    try:
BigInteger.DivideAndRemainder(bi1, zero,         var _: BigInteger)
fail("ArithmeticException expected")
    except DivideByZeroException:

    try:
BigInteger.DivideAndRemainder(-bi3, zero,         var _: BigInteger)
fail("ArithmeticException expected")
    except DivideByZeroException:

    try:
BigInteger.DivideAndRemainder(zero, zero,         var _: BigInteger)
fail("ArithmeticException expected")
    except DivideByZeroException:

proc test_ConstructorLjava_lang_String*() =
assertTrue("new(0)", BigInteger.Parse("0") == BigInteger.GetInstance(0))
assertTrue("new(1)", BigInteger.Parse("1") == BigInteger.GetInstance(1))
assertTrue("new(12345678901234)", BigInteger.Parse("12345678901234") == BigInteger.GetInstance(12345678901234))
assertTrue("new(-1)", BigInteger.Parse("-1") == BigInteger.GetInstance(-1))
assertTrue("new(-12345678901234)", BigInteger.Parse("-12345678901234") == BigInteger.GetInstance(-12345678901234))
proc test_ConstructorLjava_lang_StringI*() =
assertTrue("new(0,16)", BigInteger.Parse("0", 16) == BigInteger.GetInstance(0))
assertTrue("new(1,16)", BigInteger.Parse("1", 16) == BigInteger.GetInstance(1))
assertTrue("new(ABF345678901234,16)", BigInteger.Parse("ABF345678901234", 16) == BigInteger.GetInstance(774395206925554228))
assertTrue("new(abf345678901234,16)", BigInteger.Parse("abf345678901234", 16) == BigInteger.GetInstance(774395206925554228))
assertTrue("new(-1,16)", BigInteger.Parse("-1", 16) == BigInteger.GetInstance(-1))
assertTrue("new(-ABF345678901234,16)", BigInteger.Parse("-ABF345678901234", 16) == BigInteger.GetInstance(-774395206925554228))
assertTrue("new(-abf345678901234,16)", BigInteger.Parse("-abf345678901234", 16) == BigInteger.GetInstance(-774395206925554228))
assertTrue("new(-101010101,2)", BigInteger.Parse("-101010101", 2) == BigInteger.GetInstance(-341))
proc test_toString*() =
assertTrue("0.toString", "0".Equals(BigInteger.GetInstance(0).ToString))
assertTrue("1.toString", "1".Equals(BigInteger.GetInstance(1).ToString))
assertTrue("12345678901234.toString", "12345678901234".Equals(BigInteger.GetInstance(12345678901234).ToString))
assertTrue("-1.toString", "-1".Equals(BigInteger.GetInstance(-1).ToString))
assertTrue("-12345678901234.toString", "-12345678901234".Equals(BigInteger.GetInstance(-12345678901234).ToString))
proc test_toStringI*() =
assertTrue("0.toString(16)", "0".Equals(BigInteger.GetInstance(0).ToString(16)))
assertTrue("1.toString(16)", "1".Equals(BigInteger.GetInstance(1).ToString(16)))
assertTrue("ABF345678901234.toString(16)", "abf345678901234".Equals(BigInteger.GetInstance(774395206925554228).ToString(16)))
assertTrue("-1.toString(16)", "-1".Equals(BigInteger.GetInstance(-1).ToString(16)))
assertTrue("-ABF345678901234.toString(16)", "-abf345678901234".Equals(BigInteger.GetInstance(-774395206925554228).ToString(16)))
assertTrue("-101010101.toString(2)", "-101010101".Equals(BigInteger.GetInstance(-341).ToString(2)))
proc test_andLjava_math_BigInteger*() =
    for element in boolPairs:
          var i1: BigInteger = element[0]
          var i2: BigInteger = element[1]
        var res: BigInteger = i1 & i2
assertTrue("symmetry of and", res == i2 & i1)
        var len: int = Math.Max(i1.BitLength, i2.BitLength) + 66
          var i: int = 0
          while i < len:
assertTrue("and", BigInteger.TestBit(i1, i) && BigInteger.TestBit(i2, i) == BigInteger.TestBit(res, i))
++i
proc test_orLjava_math_BigInteger*() =
    for element in boolPairs:
          var i1: BigInteger = element[0]
          var i2: BigInteger = element[1]
        var res: BigInteger = i1 | i2
assertTrue("symmetry of or", res == i2 | i1)
        var len: int = Math.Max(i1.BitLength, i2.BitLength) + 66
          var i: int = 0
          while i < len:
assertTrue("or", BigInteger.TestBit(i1, i) || BigInteger.TestBit(i2, i) == BigInteger.TestBit(res, i))
++i
proc test_xorLjava_math_BigInteger*() =
    for element in boolPairs:
          var i1: BigInteger = element[0]
          var i2: BigInteger = element[1]
        var res: BigInteger = i1 ^ i2
assertTrue("symmetry of xor", res == i2 ^ i1)
        var len: int = Math.Max(i1.BitLength, i2.BitLength) + 66
          var i: int = 0
          while i < len:
assertTrue("xor", BigInteger.TestBit(i1, i) ^ BigInteger.TestBit(i2, i) == BigInteger.TestBit(res, i))
++i
proc test_not*() =
    for element in boolPairs:
        var i1: BigInteger = element[0]
        var res: BigInteger = BigInteger.Not(i1)
        var len: int = i1.BitLength + 66
          var i: int = 0
          while i < len:
assertTrue("not", !BigInteger.TestBit(i1, i) == BigInteger.TestBit(res, i))
++i
proc test_andNotLjava_math_BigInteger*() =
    for element in boolPairs:
          var i1: BigInteger = element[0]
          var i2: BigInteger = element[1]
        var res: BigInteger = BigInteger.AndNot(i1, i2)
        var len: int = Math.Max(i1.BitLength, i2.BitLength) + 66
          var i: int = 0
          while i < len:
assertTrue("andNot", BigInteger.TestBit(i1, i) && !BigInteger.TestBit(i2, i) == BigInteger.TestBit(res, i))
++i
        i1 = element[1]
        i2 = element[0]
        res = BigInteger.AndNot(i1, i2)
          var i: int = 0
          while i < len:
assertTrue("andNot reversed", BigInteger.TestBit(i1, i) && !BigInteger.TestBit(i2, i) == BigInteger.TestBit(res, i))
++i
    try:
BigInteger.AndNot(BigInteger.Zero, nil)
fail("should throw NPE")
    except Exception:

    var bi: BigInteger = BigInteger(0, @[])
assertEquals(string.Empty, BigInteger.Zero, BigInteger.AndNot(bi, BigInteger.Zero))
proc TestInitialize*() =
procCall.TestInitialize
SetUp
proc SetUp() =
    bi1 = BigInteger.Parse("2436798324768978", 16)
    bi2 = BigInteger.Parse("4576829475724387584378543764555", 16)
    bi3 = BigInteger.Parse("43987298363278574365732645872643587624387563245", 16)
    bi33 = BigInteger.Parse("10730846694701319120609898625733976090865327544790136667944805934175543888691400559249041094474885347922769807001", 10)
    bi22 = BigInteger.Parse("33301606932171509517158059487795669025817912852219962782230629632224456249", 10)
    bi11 = BigInteger.Parse("6809003003832961306048761258711296064", 10)
    bi23 = BigInteger.Parse("597791300268191573513888045771594235932809890963138840086083595706565695943160293610527214057", 10)
    bi13 = BigInteger.Parse("270307912162948508387666703213038600031041043966215279482940731158968434008", 10)
    bi12 = BigInteger.Parse("15058244971895641717453176477697767050482947161656458456", 10)
    largePos = BigInteger.Parse("834759814379857314986743298675687569845986736578576375675678998612743867438632986243982098437620983476924376", 16)
    smallPos = BigInteger.Parse("48753269875973284765874598630960986276", 16)
    largeNeg = BigInteger.Parse("-878824397432651481891353247987891423768534321387864361143548364457698487264387568743568743265873246576467643756437657436587436", 16)
    smallNeg = BigInteger.Parse("-567863254343798609857456273458769843", 16)
    boolPairs = @[@[largePos, smallPos], @[largePos, smallNeg], @[largeNeg, smallPos], @[largeNeg, smallNeg]]
proc testDiv(i1: BigInteger, i2: BigInteger) =
    var q: BigInteger = i1 / i2
    var r: BigInteger = BigInteger.Remainder(i1, i2)
    var temp0: BigInteger = BigInteger.DivideAndRemainder(i1, i2,     var temp1: BigInteger)
assertTrue("divide and divideAndRemainder do not agree", q.Equals(temp0))
assertTrue("remainder and divideAndRemainder do not agree", r.Equals(temp1))
assertTrue("signum and equals(zero) do not agree on quotient", q.Sign != 0 || q.Equals(zero))
assertTrue("signum and equals(zero) do not agree on remainder", r.Sign != 0 || r.Equals(zero))
assertTrue("wrong sign on quotient", q.Sign == 0 || q.Sign == i1.Sign * i2.Sign)
assertTrue("wrong sign on remainder", r.Sign == 0 || r.Sign == i1.Sign)
assertTrue("remainder out of range", BigInteger.Abs(r).CompareTo(BigInteger.Abs(i2)) < 0)
assertTrue("quotient too small", BigInteger.Abs(q) + one * BigInteger.Abs(i2).CompareTo(BigInteger.Abs(i1)) > 0)
assertTrue("quotient too large", BigInteger.Abs(q) * BigInteger.Abs(i2).CompareTo(BigInteger.Abs(i1)) <= 0)
    var p: BigInteger = q * i2
    var a: BigInteger = p + r
assertTrue("(a/b)*b+(a%b) != a", a == i1)
    try:
        var mod: BigInteger = i1 % i2
assertTrue("mod is negative", mod.Sign >= 0)
assertTrue("mod out of range", BigInteger.Abs(mod).CompareTo(BigInteger.Abs(i2)) < 0)
assertTrue("positive remainder == mod", r.Sign < 0 || r == mod)
assertTrue("negative remainder == mod - divisor", r.Sign >= 0 || r == mod - i2)
    except ArithmeticException:
assertTrue("mod fails on negative divisor only", i2.Sign <= 0)
proc testDivRanges(i: BigInteger) =
    var bound: BigInteger = i * two
      var j: BigInteger = -bound
      while j.CompareTo(bound) <= 0:
          var innerbound: BigInteger = j + two
          var k: BigInteger = j - two
            while k.CompareTo(innerbound) <= 0:
testDiv(k, i)
                k = k + one
          j = j + i
proc isPrime(b: long): bool =
    if b == 2:
        return true
    if b & 1 == 0:
        return false
    var maxlen: long = cast[long](Math.Sqrt(b)) + 2
      var x: long = 3
      while x < maxlen:
          if b % x == 0:
              return false
          x = 2
    return true
proc testAllMults(i1: BigInteger, i2: BigInteger, ans: BigInteger) =
assertTrue("i1*i2=ans", i1 * i2 == ans)
assertTrue("i2*i1=ans", i2 * i1 == ans)
assertTrue("-i1*i2=-ans", -i1 * i2 == -ans)
assertTrue("-i2*i1=-ans", -i2 * i1 == -ans)
assertTrue("i1*-i2=-ans", i1 * -i2 == -ans)
assertTrue("i2*-i1=-ans", i2 * -i1 == -ans)
assertTrue("-i1*-i2=ans", -i1 * -i2 == ans)
assertTrue("-i2*-i1=ans", -i2 * -i1 == ans)
proc testAllDivs(i1: BigInteger, i2: BigInteger) =
testDiv(i1, i2)
testDiv(-i1, i2)
testDiv(i1, -i2)
testDiv(-i1, -i2)