# "Namespace: ICU4N.Numerics.BigMath"
type
  BigIntegerToStringTest = ref object


proc testRadixOutOfRange*() =
    var value: String = "442429234853876401"
    var radix: int = 10
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var result: String = aNumber.ToString(45)
assertTrue("incorrect result", result.Equals(value))
proc testRadix2Neg*() =
    var value: String = "-101001100010010001001010101110000101010110001010010101010101010101010101010101010101010101010010101"
    var radix: int = 2
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var result: String = aNumber.ToString(radix)
assertTrue("incorrect result", result.Equals(value))
proc testRadix2Pos*() =
    var value: String = "101000011111000000110101010101010101010001001010101010101010010101010101010000100010010"
    var radix: int = 2
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var result: String = aNumber.ToString(radix)
assertTrue("incorrect result", result.Equals(value))
proc testRadix10Neg*() =
    var value: String = "-2489756308572364789878394872984"
    var radix: int = 16
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var result: String = aNumber.ToString(radix)
assertTrue("incorrect result", result.Equals(value))
proc testRadix10Pos*() =
    var value: String = "2387627892347567398736473476"
    var radix: int = 16
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var result: String = aNumber.ToString(radix)
assertTrue("incorrect result", result.Equals(value))
proc testRadix16Neg*() =
    var value: String = "-287628a883451b800865c67e8d7ff20"
    var radix: int = 16
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var result: String = aNumber.ToString(radix)
assertTrue("incorrect result", result.Equals(value))
proc testRadix16Pos*() =
    var value: String = "287628a883451b800865c67e8d7ff20"
    var radix: int = 16
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var result: String = aNumber.ToString(radix)
assertTrue("incorrect result", result.Equals(value))
proc testRadix24Neg*() =
    var value: String = "-287628a88gmn3451b8ijk00865c67e8d7ff20"
    var radix: int = 24
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var result: String = aNumber.ToString(radix)
assertTrue("incorrect result", result.Equals(value))
proc testRadix24Pos*() =
    var value: String = "287628a883451bg80ijhk0865c67e8d7ff20"
    var radix: int = 24
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var result: String = aNumber.ToString(radix)
assertTrue("incorrect result", result.Equals(value))
proc testRadix36Neg*() =
    var value: String = "-uhguweut98iu4h3478tq3985pq98yeiuth33485yq4aiuhalai485yiaehasdkr8tywi5uhslei8"
    var radix: int = 36
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var result: String = aNumber.ToString(radix)
assertTrue("incorrect result", result.Equals(value))
proc testRadix36Pos*() =
    var value: String = "23895lt45y6vhgliuwhgi45y845htsuerhsi4586ysuerhtsio5y68peruhgsil4568ypeorihtse48y6"
    var radix: int = 36
    var aNumber: BigInteger = BigInteger.Parse(value, radix)
    var result: String = aNumber.ToString(radix)
assertTrue("incorrect result", result.Equals(value))