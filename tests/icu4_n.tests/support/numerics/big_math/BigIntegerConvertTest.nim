# "Namespace: ICU4N.Numerics.BigMath"
type
  BigIntegerConvertTest = ref object


proc testDoubleValueZero*() =
    var a: String = "0"
    var result: double = 0.0
    var aNumber: double = BigInteger.Parse(a).ToDouble
assertTrue("incorrect result", aNumber == result)
proc testDoubleValuePositive1*() =
    var a: String = "27467238945"
    var result: double = 27467238945.0
    var aNumber: double = BigInteger.Parse(a).ToDouble
assertTrue("incorrect result", aNumber == result)
proc testDoubleValuePositive2*() =
    var a: String = "2746723894572364578265426346273456972"
    var result: double = 2.7467238945723645e+36
    var aNumber: double = BigInteger.Parse(a).ToDouble
assertTrue("incorrect result", aNumber == result)
proc testDoubleValueNegative1*() =
    var a: String = "-27467238945"
    var result: double = -27467238945.0
    var aNumber: double = BigInteger.Parse(a).ToDouble
assertTrue("incorrect result", aNumber == result)
proc testDoubleValueNegative2*() =
    var a: String = "-2746723894572364578265426346273456972"
    var result: double = -2.7467238945723645e+36
    var aNumber: double = BigInteger.Parse(a).ToDouble
assertTrue("incorrect result", aNumber == result)
proc testDoubleValuePosRounded1*() =
    var a: byte[] = @[cast[byte](-128), 1, 2, 3, 4, 5, 60, 23, 1, cast[byte](-3), cast[byte](-5)]
    var aSign: int = 1
    var result: double = 1.54747264387948e+26
    var aNumber: double = BigInteger(aSign, a).ToDouble
assertTrue("incorrect result", aNumber == result)
proc testDoubleValuePosRounded2*() =
    var a: byte[] = @[cast[byte](-128), 1, 2, 3, 4, 5, 36, 23, 1, cast[byte](-3), cast[byte](-5)]
    var aSign: int = 1
    var result: double = 1.547472643879479e+26
    var aNumber: double = BigInteger(aSign, a).ToDouble
assertTrue("incorrect result", aNumber == result)
proc testDoubleValuePosNotRounded*() =
    var a: byte[] = @[cast[byte](-128), 1, 2, 3, 4, 5, cast[byte](-128), 23, 1, cast[byte](-3), cast[byte](-5)]
    var aSign: int = 1
    var result: double = 1.5474726438794828e+26
    var aNumber: double = BigInteger(aSign, a).ToDouble
assertTrue("incorrect result", aNumber == result)
proc testDoubleValueNegRounded1*() =
    var a: byte[] = @[cast[byte](-128), 1, 2, 3, 4, 5, 60, 23, 1, cast[byte](-3), cast[byte](-5)]
    var aSign: int = -1
    var result: double = -1.54747264387948e+26
    var aNumber: double = BigInteger(aSign, a).ToDouble
assertTrue("incorrect result", aNumber == result)
proc testDoubleValueNegRounded2*() =
    var a: byte[] = @[cast[byte](-128), 1, 2, 3, 4, 5, 36, 23, 1, cast[byte](-3), cast[byte](-5)]
    var aSign: int = -1
    var result: double = -1.547472643879479e+26
    var aNumber: double = BigInteger(aSign, a).ToDouble
assertTrue("incorrect result", aNumber == result)
proc testDoubleValueNegNotRounded*() =
    var a: byte[] = @[cast[byte](-128), 1, 2, 3, 4, 5, cast[byte](-128), 23, 1, cast[byte](-3), cast[byte](-5)]
    var aSign: int = -1
    var result: double = -1.5474726438794828e+26
    var aNumber: double = BigInteger(aSign, a).ToDouble
assertTrue("incorrect result", aNumber == result)
proc testDoubleValuePosMaxValue*() =
    var a: byte[] = @[0, cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-8), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1)]
    var aSign: int = 1
    var aNumber: double = BigInteger(aSign, a).ToDouble
assertTrue("incorrect result", aNumber == double.MaxValue)
proc testDoubleValueNegMaxValue*() =
    var a: byte[] = @[0, cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-8), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1)]
    var aSign: int = -1
    var aNumber: double = BigInteger(aSign, a).ToDouble
assertTrue("incorrect result", aNumber == -double.MaxValue)
proc testDoubleValuePositiveInfinity1*() =
    var a: byte[] = @[cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-8), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var aSign: int = 1
    var aNumber: double = BigInteger(aSign, a).ToDouble
assertTrue("incorrect result", aNumber == double.PositiveInfinity)
proc testDoubleValuePositiveInfinity2*() =
    var a: String = "2746723894572364578265426346273456972283746872364768676747462342342342342342342342323423423423423423426767456345745293762384756238475634563456845634568934568347586346578648576478568456457634875673845678456786587345873645767456834756745763457863485768475678465783456702897830296720476846578634576384567845678346573465786457863"
    var aNumber: double = BigInteger.Parse(a).ToDouble
assertTrue("incorrect result", aNumber == double.PositiveInfinity)
proc testDoubleValueNegativeInfinity1*() =
    var a: String = "-2746723894572364578265426346273456972283746872364768676747462342342342342342342342323423423423423423426767456345745293762384756238475634563456845634568934568347586346578648576478568456457634875673845678456786587345873645767456834756745763457863485768475678465783456702897830296720476846578634576384567845678346573465786457863"
    var aNumber: double = BigInteger.Parse(a).ToDouble
assertTrue("incorrect result", aNumber == double.NegativeInfinity)
proc testDoubleValueNegativeInfinity2*() =
    var a: byte[] = @[cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-8), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var aSign: int = -1
    var aNumber: double = BigInteger(aSign, a).ToDouble
assertTrue("incorrect result", aNumber == double.NegativeInfinity)
proc testDoubleValuePosMantissaIsZero*() =
    var a: byte[] = @[cast[byte](-128), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var aSign: int = 1
    var result: double = 8.98846567431158e+307
    var aNumber: double = BigInteger(aSign, a).ToDouble
assertTrue("incorrect result", aNumber == result)
proc testDoubleValueNegMantissaIsZero*() =
    var a: byte[] = @[cast[byte](-128), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var aSign: int = -1
    var aNumber: double = BigInteger(aSign, a).ToDouble
assertTrue("incorrect result", aNumber == -8.98846567431158e+307)
proc testFloatValueZero*() =
    var a: String = "0"
    var result: float = 0.0
    var aNumber: float = BigInteger.Parse(a).ToSingle
assertTrue("incorrect result", aNumber == result)
proc testFloatValuePositive1*() =
    var a: String = "27467238"
    var result: float = 27467238.0
    var aNumber: float = BigInteger.Parse(a).ToSingle
assertTrue("incorrect result", aNumber == result)
proc testFloatValuePositive2*() =
    var a: String = "27467238945723645782"
    var result: float = 2.7467239e+19
    var aNumber: float = BigInteger.Parse(a).ToSingle
assertTrue("incorrect result", aNumber == result)
proc testFloatValueNegative1*() =
    var a: String = "-27467238"
    var result: float = -27467238.0
    var aNumber: float = BigInteger.Parse(a).ToSingle
assertTrue("incorrect result", aNumber == result)
proc testFloatValueNegative2*() =
    var a: String = "-27467238945723645782"
    var result: float = -2.7467239e+19
    var aNumber: float = BigInteger.Parse(a).ToSingle
assertTrue("incorrect result", aNumber == result)
proc testFloatValuePosRounded1*() =
    var a: byte[] = @[cast[byte](-128), 1, cast[byte](-1), cast[byte](-4), 4, 5, 60, 23, 1, cast[byte](-3), cast[byte](-5)]
    var aSign: int = 1
    var result: float = 1.5475195e+26
    var aNumber: float = BigInteger(aSign, a).ToSingle
assertTrue("incorrect result", aNumber == result)
proc testFloatValuePosRounded2*() =
    var a: byte[] = @[cast[byte](-128), 1, 2, cast[byte](-128), 4, 5, 60, 23, 1, cast[byte](-3), cast[byte](-5)]
    var aSign: int = 1
    var result: float = 1.5474728e+26
    var aNumber: float = BigInteger(aSign, a).ToSingle
assertTrue("incorrect result", aNumber == result)
proc testFloatValuePosNotRounded*() =
    var a: byte[] = @[cast[byte](-128), 1, 2, 3, 4, 5, 60, 23, 1, cast[byte](-3), cast[byte](-5)]
    var aSign: int = 1
    var result: float = 1.5474726e+26
    var aNumber: float = BigInteger(aSign, a).ToSingle
assertTrue("incorrect result", aNumber == result)
proc testFloatValueNegRounded1*() =
    var a: byte[] = @[cast[byte](-128), 1, cast[byte](-1), cast[byte](-4), 4, 5, 60, 23, 1, cast[byte](-3), cast[byte](-5)]
    var aSign: int = -1
    var result: float = -1.5475195e+26
    var aNumber: float = BigInteger(aSign, a).ToSingle
assertTrue("incorrect result", aNumber == result)
proc testFloatValueNegRounded2*() =
    var a: byte[] = @[cast[byte](-128), 1, 2, cast[byte](-128), 4, 5, 60, 23, 1, cast[byte](-3), cast[byte](-5)]
    var aSign: int = -1
    var result: float = -1.5474728e+26
    var aNumber: float = BigInteger(aSign, a).ToSingle
assertTrue("incorrect result", aNumber == result)
proc testFloatValueNegNotRounded*() =
    var a: byte[] = @[cast[byte](-128), 1, 2, 3, 4, 5, 60, 23, 1, cast[byte](-3), cast[byte](-5)]
    var aSign: int = -1
    var result: float = -1.5474726e+26
    var aNumber: float = BigInteger(aSign, a).ToSingle
assertTrue("incorrect result", aNumber == result)
proc testFloatValuePosMaxValue*() =
    var a: byte[] = @[0, cast[byte](-1), cast[byte](-1), cast[byte](-1), 0, cast[byte](-1), cast[byte](-1), cast[byte](-8), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1)]
    var aSign: int = 1
    var aNumber: float = BigInteger(aSign, a).ToSingle
assertTrue("incorrect result", aNumber == float.MaxValue)
proc testFloatValueNegMaxValue*() =
    var a: byte[] = @[0, cast[byte](-1), cast[byte](-1), cast[byte](-1), 0, cast[byte](-1), cast[byte](-1), cast[byte](-8), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1)]
    var aSign: int = -1
    var aNumber: float = BigInteger(aSign, a).ToSingle
assertTrue("incorrect result", aNumber == -float.MaxValue)
proc testFloatValuePositiveInfinity1*() =
    var a: byte[] = @[0, cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1)]
    var aSign: int = 1
    var aNumber: float = BigInteger(aSign, a).ToSingle
assertTrue("incorrect result", aNumber == float.PositiveInfinity)
proc testFloatValuePositiveInfinity2*() =
    var a: String = "2746723894572364578265426346273456972283746872364768676747462342342342342342342342323423423423423423426767456345745293762384756238475634563456845634568934568347586346578648576478568456457634875673845678456786587345873645767456834756745763457863485768475678465783456702897830296720476846578634576384567845678346573465786457863"
    var aNumber: float = BigInteger.Parse(a).ToSingle
assertTrue("incorrect result", aNumber == float.PositiveInfinity)
proc testFloatValueNegativeInfinity1*() =
    var a: String = "-2746723894572364578265426346273456972283746872364768676747462342342342342342342342323423423423423423426767456345745293762384756238475634563456845634568934568347586346578648576478568456457634875673845678456786587345873645767456834756745763457863485768475678465783456702897830296720476846578634576384567845678346573465786457863"
    var aNumber: float = BigInteger.Parse(a).ToSingle
assertTrue("incorrect result", aNumber == float.NegativeInfinity)
proc testFloatValueNegativeInfinity2*() =
    var a: byte[] = @[0, cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1)]
    var aSign: int = -1
    var aNumber: float = BigInteger(aSign, a).ToSingle
assertTrue("incorrect result", aNumber == float.NegativeInfinity)
proc testFloatValuePosMantissaIsZero*() =
    var a: byte[] = @[cast[byte](-128), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var aSign: int = 1
    var result: float = 1.7014118e+38
    var aNumber: float = BigInteger(aSign, a).ToSingle
assertTrue("incorrect result", aNumber == result)
proc testFloatValueNegMantissaIsZero*() =
    var a: byte[] = @[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var aSign: int = -1
    var aNumber: float = BigInteger(aSign, a).ToSingle
assertTrue("incorrect result", aNumber == float.NegativeInfinity)
proc testFloatValueBug2482*() =
    var a: String = "2147483649"
    var result: float = 2147483600.0
    var aNumber: float = BigInteger.Parse(a).ToSingle
assertTrue("incorrect result", aNumber == result)
proc testIntValuePositive1*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3]
    var resInt: int = 1496144643
    var aNumber: int = BigInteger(aBytes).ToInt32
assertTrue("incorrect result", aNumber == resInt)
proc testIntValuePositive2*() =
    var aBytes: byte[] = @[12, 56, 100]
    var resInt: int = 800868
    var aNumber: int = BigInteger(aBytes).ToInt32
assertTrue("incorrect result", aNumber == resInt)
proc testIntValuePositive3*() =
    var aBytes: byte[] = @[56, 13, 78, cast[byte](-12), cast[byte](-5), 56, 100]
    var sign: int = 1
    var resInt: int = -184862620
    var aNumber: int = BigInteger(sign, aBytes).ToInt32
assertTrue("incorrect result", aNumber == resInt)
proc testIntValueNegative1*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), cast[byte](-128), 45, 91, 3]
    var sign: int = -1
    var resInt: int = 2144511229
    var aNumber: int = BigInteger(sign, aBytes).ToInt32
assertTrue("incorrect result", aNumber == resInt)
proc testIntValueNegative2*() =
    var aBytes: byte[] = @[cast[byte](-12), 56, 100]
    var result: int = -771996
    var aNumber: int = BigInteger(aBytes).ToInt32
assertTrue("incorrect result", aNumber == result)
proc testIntValueNegative3*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 127, 45, 91, 3]
    var sign: int = -1
    var resInt: int = -2133678851
    var aNumber: int = BigInteger(sign, aBytes).ToInt32
assertTrue("incorrect result", aNumber == resInt)
proc testLongValuePositive1*() =
    var aBytes: byte[] = @[12, 56, 100, cast[byte](-2), cast[byte](-76), 89, 45, 91, 3, 120, cast[byte](-34), cast[byte](-12), 45, 98]
    var result: long = 3268209772258930018
    var aNumber: long = BigInteger(aBytes).ToInt64
assertTrue("incorrect result", aNumber == result)
proc testLongValuePositive2*() =
    var aBytes: byte[] = @[12, 56, 100, 18, cast[byte](-105), 34, cast[byte](-18), 45]
    var result: long = 880563758158769709
    var aNumber: long = BigInteger(aBytes).ToInt64
assertTrue("incorrect result", aNumber == result)
proc testLongValueNegative1*() =
    var aBytes: byte[] = @[12, cast[byte](-1), 100, cast[byte](-2), cast[byte](-76), cast[byte](-128), 45, 91, 3]
    var result: long = -43630045168837885
    var aNumber: long = BigInteger(aBytes).ToInt64
assertTrue("incorrect result", aNumber == result)
proc testLongValueNegative2*() =
    var aBytes: byte[] = @[cast[byte](-12), 56, 100, 45, cast[byte](-101), 45, 98]
    var result: long = -3315696807498398
    var aNumber: long = BigInteger(aBytes).ToInt64
assertTrue("incorrect result", aNumber == result)
proc testValueOfIntegerMax*() =
    var longVal: long = int.MaxValue
    var aNumber: BigInteger = BigInteger.GetInstance(longVal)
    var rBytes: byte[] = @[127, cast[byte](-1), cast[byte](-1), cast[byte](-1)]
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect result", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testValueOfIntegerMin*() =
    var longVal: long = int.MinValue
    var aNumber: BigInteger = BigInteger.GetInstance(longVal)
    var rBytes: byte[] = @[cast[byte](-128), 0, 0, 0]
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect result", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testValueOfLongMax*() =
    var longVal: long = long.MaxValue
    var aNumber: BigInteger = BigInteger.GetInstance(longVal)
    var rBytes: byte[] = @[127, cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1), cast[byte](-1)]
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect result", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testValueOfLongMin*() =
    var longVal: long = long.MinValue
    var aNumber: BigInteger = BigInteger.GetInstance(longVal)
    var rBytes: byte[] = @[cast[byte](-128), 0, 0, 0, 0, 0, 0, 0]
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect result", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testValueOfLongPositive1*() =
    var longVal: long = 268209772258930018
    var aNumber: BigInteger = BigInteger.GetInstance(longVal)
    var rBytes: byte[] = @[3, cast[byte](-72), cast[byte](-33), 93, cast[byte](-24), cast[byte](-56), 45, 98]
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect result", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testValueOfLongPositive2*() =
    var longVal: long = 58930018
    var aNumber: BigInteger = BigInteger.GetInstance(longVal)
    var rBytes: byte[] = @[3, cast[byte](-125), 51, 98]
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect result", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 1, aNumber.Sign)
proc testValueOfLongNegative1*() =
    var longVal: long = -268209772258930018
    var aNumber: BigInteger = BigInteger.GetInstance(longVal)
    var rBytes: byte[] = @[cast[byte](-4), 71, 32, cast[byte](-94), 23, 55, cast[byte](-46), cast[byte](-98)]
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect result", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testValueOfLongNegative2*() =
    var longVal: long = -58930018
    var aNumber: BigInteger = BigInteger.GetInstance(longVal)
    var rBytes: byte[] = @[cast[byte](-4), 124, cast[byte](-52), cast[byte](-98)]
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect result", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", -1, aNumber.Sign)
proc testValueOfLongZero*() =
    var longVal: long = 0
    var aNumber: BigInteger = BigInteger.GetInstance(longVal)
    var rBytes: byte[] = @[0]
    var resBytes: byte[]
    resBytes = aNumber.ToByteArray
      var i: int = 0
      while i < resBytes.Length:
assertTrue("incorrect result", resBytes[i] == rBytes[i])
++i
assertEquals("incorrect sign", 0, aNumber.Sign)