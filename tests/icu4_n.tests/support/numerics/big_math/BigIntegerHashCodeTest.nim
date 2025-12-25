# "Namespace: ICU4N.Numerics.BigMath"
type
  BigIntegerHashCodeTest = ref object


proc testSameObject*() =
    var value1: String = "12378246728727834290276457386374882976782849"
    var value2: String = "-5634562095872038262928728727834290276457386374882976782849"
    var aNumber1: BigInteger = BigInteger.Parse(value1)
    var aNumber2: BigInteger = BigInteger.Parse(value2)
    var code1: int = aNumber1.GetHashCode
    var o1 = aNumber1 + aNumber2 << 125
    var o2 = aNumber1 - aNumber2 >> 125
    var o3 = aNumber1 * aNumber2.ToByteArray
    var o4 = aNumber1 / aNumber2.BitLength
    var o5 = BigInteger.Pow(BigInteger.Gcd(aNumber1, aNumber2), 7)
    var code2: int = aNumber1.GetHashCode
assertTrue("hash codes for the same object differ", code1 == code2)
proc testEqualObjects*() =
    var value1: String = "12378246728727834290276457386374882976782849"
    var value2: String = "12378246728727834290276457386374882976782849"
    var aNumber1: BigInteger = BigInteger.Parse(value1)
    var aNumber2: BigInteger = BigInteger.Parse(value2)
    var code1: int = aNumber1.GetHashCode
    var code2: int = aNumber2.GetHashCode
    if aNumber1.Equals(aNumber2):
assertTrue("hash codes for equal objects are unequal", code1 == code2)
proc testUnequalObjectsUnequal*() =
    var value1: String = "12378246728727834290276457386374882976782849"
    var value2: String = "-5634562095872038262928728727834290276457386374882976782849"
    var aNumber1: BigInteger = BigInteger.Parse(value1)
    var aNumber2: BigInteger = BigInteger.Parse(value2)
    var code1: int = aNumber1.GetHashCode
    var code2: int = aNumber2.GetHashCode
    if !aNumber1.Equals(aNumber2):
assertTrue("hash codes for unequal objects are equal", code1 != code2)