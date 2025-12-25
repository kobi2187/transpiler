# "Namespace: ICU4N.Numerics.BigMath"
type
  BigDecimalCompareTest = ref object


proc testAbsNeg*() =
    var a: String = "-123809648392384754573567356745735.63567890295784902768787678287E+21"
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
    var result: String = "123809648392384754573567356745735635678902957849027687.87678287"
assertEquals("incorrect value", result, BigDecimal.Abs(aNumber).ToString(CultureInfo.InvariantCulture))
proc testAbsPos*() =
    var a: String = "123809648392384754573567356745735.63567890295784902768787678287E+21"
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
    var result: String = "123809648392384754573567356745735635678902957849027687.87678287"
assertEquals("incorrect value", result, BigDecimal.Abs(aNumber).ToString(CultureInfo.InvariantCulture))
proc testAbsMathContextNeg*() =
    var a: String = "-123809648392384754573567356745735.63567890295784902768787678287E+21"
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
    var precision: int = 15
    var rm: RoundingMode = RoundingMode.HalfDown
    var mc: MathContext = MathContext(precision, rm)
    var result: String = "1.23809648392385E+53"
    var resScale: int = -39
    var res: BigDecimal = BigDecimal.Abs(aNumber, mc)
assertEquals("incorrect value", result, res.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, res.Scale)
proc testAbsMathContextPos*() =
    var a: String = "123809648392384754573567356745735.63567890295784902768787678287E+21"
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
    var precision: int = 41
    var rm: RoundingMode = RoundingMode.HalfEven
    var mc: MathContext = MathContext(precision, rm)
    var result: String = "1.2380964839238475457356735674573563567890E+53"
    var resScale: int = -13
    var res: BigDecimal = BigDecimal.Abs(aNumber, mc)
assertEquals("incorrect value", result, res.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, res.Scale)
proc testCompareEqualScale1*() =
    var a: String = "12380964839238475457356735674573563567890295784902768787678287"
    var aScale: int = 18
    var b: String = "4573563567890295784902768787678287"
    var bScale: int = 18
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: int = 1
assertEquals("incorrect result", result, aNumber.CompareTo(bNumber))
proc testCompareEqualScale2*() =
    var a: String = "12380964839238475457356735674573563567890295784902768787678287"
    var aScale: int = 18
    var b: String = "4573563923487289357829759278282992758247567890295784902768787678287"
    var bScale: int = 18
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: int = -1
assertEquals("incorrect result", result, aNumber.CompareTo(bNumber))
proc testCompareGreaterScale1*() =
    var a: String = "12380964839238475457356735674573563567890295784902768787678287"
    var aScale: int = 28
    var b: String = "4573563567890295784902768787678287"
    var bScale: int = 18
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: int = 1
assertEquals("incorrect result", result, aNumber.CompareTo(bNumber))
proc testCompareGreaterScale2*() =
    var a: String = "12380964839238475457356735674573563567890295784902768787678287"
    var aScale: int = 48
    var b: String = "4573563567890295784902768787678287"
    var bScale: int = 2
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: int = -1
assertEquals("incorrect result", result, aNumber.CompareTo(bNumber))
proc testCompareLessScale1*() =
    var a: String = "12380964839238475457356735674573563567890295784902768787678287"
    var aScale: int = 18
    var b: String = "4573563567890295784902768787678287"
    var bScale: int = 28
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: int = 1
assertEquals("incorrect result", result, aNumber.CompareTo(bNumber))
proc testCompareLessScale2*() =
    var a: String = "12380964839238475457356735674573"
    var aScale: int = 36
    var b: String = "45735635948573894578349572001798379183767890295784902768787678287"
    var bScale: int = 48
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: int = -1
assertEquals("incorrect result", result, aNumber.CompareTo(bNumber))
proc testEqualsUnequal1*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "7472334223847623782375469293018787918347987234564568"
    var bScale: int = 13
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
assertFalse("incorrect value", aNumber.Equals(bNumber))
proc testEqualsUnequal2*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var bScale: int = 13
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
assertFalse("incorrect value", aNumber.Equals(bNumber))
proc testEqualsUnequal3*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
assertFalse("incorrect value", aNumber.Equals(b))
proc testEqualsEqual*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var bScale: int = -24
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
assertEquals("incorrect value", aNumber, bNumber)
proc testEqualsNull*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
assertFalse("incorrect value", aNumber.Equals(nil))
proc testHashCodeEqual*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var bScale: int = -24
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
assertEquals("incorrect value", aNumber.GetHashCode, bNumber.GetHashCode)
proc testHashCodeUnequal*() =
    var a: String = "8478231212478987482988429808779810457634781384756794987"
    var aScale: int = 41
    var b: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var bScale: int = -24
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
assertTrue("incorrect value", aNumber.GetHashCode != bNumber.GetHashCode)
proc testMaxEqual*() =
    var a: String = "8478231212478987482988429808779810457634781384756794987"
    var aScale: int = 41
    var b: String = "8478231212478987482988429808779810457634781384756794987"
    var bScale: int = 41
    var c: String = "8478231212478987482988429808779810457634781384756794987"
    var cScale: int = 41
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var cNumber: BigDecimal = BigDecimal(BigInteger.Parse(c), cScale)
assertEquals("incorrect value", cNumber, BigDecimal.Max(aNumber, bNumber))
proc testMaxUnequal1*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = 24
    var b: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var bScale: int = 41
    var c: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var cScale: int = 24
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var cNumber: BigDecimal = BigDecimal(BigInteger.Parse(c), cScale)
assertEquals("incorrect value", cNumber, BigDecimal.Max(aNumber, bNumber))
proc testMaxUnequal2*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = 41
    var b: String = "94488478231212478987482988429808779810457634781384756794987"
    var bScale: int = 41
    var c: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var cScale: int = 41
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var cNumber: BigDecimal = BigDecimal(BigInteger.Parse(c), cScale)
assertEquals("incorrect value", cNumber, BigDecimal.Max(aNumber, bNumber))
proc testMinEqual*() =
    var a: String = "8478231212478987482988429808779810457634781384756794987"
    var aScale: int = 41
    var b: String = "8478231212478987482988429808779810457634781384756794987"
    var bScale: int = 41
    var c: String = "8478231212478987482988429808779810457634781384756794987"
    var cScale: int = 41
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var cNumber: BigDecimal = BigDecimal(BigInteger.Parse(c), cScale)
assertEquals("incorrect value", cNumber, BigDecimal.Min(aNumber, bNumber))
proc testMinUnequal1*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = 24
    var b: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var bScale: int = 41
    var c: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var cScale: int = 41
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var cNumber: BigDecimal = BigDecimal(BigInteger.Parse(c), cScale)
assertEquals("incorrect value", cNumber, BigDecimal.Min(aNumber, bNumber))
proc testMinUnequal2*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = 41
    var b: String = "94488478231212478987482988429808779810457634781384756794987"
    var bScale: int = 41
    var c: String = "94488478231212478987482988429808779810457634781384756794987"
    var cScale: int = 41
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var cNumber: BigDecimal = BigDecimal(BigInteger.Parse(c), cScale)
assertEquals("incorrect value", cNumber, BigDecimal.Min(aNumber, bNumber))
proc testPlusPositive*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = 41
    var c: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var cScale: int = 41
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var cNumber: BigDecimal = BigDecimal(BigInteger.Parse(c), cScale)
assertEquals("incorrect value", cNumber, BigDecimal.Plus(aNumber))
proc testPlusMathContextPositive*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = 41
    var precision: int = 37
    var rm: RoundingMode = RoundingMode.Floor
    var mc: MathContext = MathContext(precision, rm)
    var c: String = "929487820944884782312124789.8748298842"
    var cScale: int = 10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var res: BigDecimal = BigDecimal.Plus(aNumber, mc)
assertEquals("incorrect value", c, res.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, res.Scale)
proc testPlusNegative*() =
    var a: String = "-92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = 41
    var c: String = "-92948782094488478231212478987482988429808779810457634781384756794987"
    var cScale: int = 41
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var cNumber: BigDecimal = BigDecimal(BigInteger.Parse(c), cScale)
assertEquals("incorrect value", cNumber, BigDecimal.Plus(aNumber))
proc testPlusMathContextNegative*() =
    var a: String = "-92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = 49
    var precision: int = 46
    var rm: RoundingMode = RoundingMode.Ceiling
    var mc: MathContext = MathContext(precision, rm)
    var c: String = "-9294878209448847823.121247898748298842980877981"
    var cScale: int = 27
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var res: BigDecimal = BigDecimal.Plus(aNumber, mc)
assertEquals("incorrect value", c, res.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, res.Scale)
proc testNegatePositive*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = 41
    var c: String = "-92948782094488478231212478987482988429808779810457634781384756794987"
    var cScale: int = 41
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var cNumber: BigDecimal = BigDecimal(BigInteger.Parse(c), cScale)
assertEquals("incorrect value", cNumber, -aNumber)
proc testNegateMathContextPositive*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = 41
    var precision: int = 37
    var rm: RoundingMode = RoundingMode.Floor
    var mc: MathContext = MathContext(precision, rm)
    var c: String = "-929487820944884782312124789.8748298842"
    var cScale: int = 10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var res: BigDecimal = BigDecimal.Negate(aNumber, mc)
assertEquals("incorrect value", c, res.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, res.Scale)
proc testNegateNegative*() =
    var a: String = "-92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = 41
    var c: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var cScale: int = 41
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var cNumber: BigDecimal = BigDecimal(BigInteger.Parse(c), cScale)
assertEquals("incorrect value", cNumber, -aNumber)
proc testNegateMathContextNegative*() =
    var a: String = "-92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = 49
    var precision: int = 46
    var rm: RoundingMode = RoundingMode.Ceiling
    var mc: MathContext = MathContext(precision, rm)
    var c: String = "9294878209448847823.121247898748298842980877981"
    var cScale: int = 27
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var res: BigDecimal = BigDecimal.Negate(aNumber, mc)
assertEquals("incorrect value", c, res.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, res.Scale)
proc testSignumPositive*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = 41
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
assertEquals("incorrect value", 1, aNumber.Sign)
proc testSignumNegative*() =
    var a: String = "-92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = 41
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
assertEquals("incorrect value", -1, aNumber.Sign)
proc testSignumZero*() =
    var a: String = "0"
    var aScale: int = 41
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
assertEquals("incorrect value", 0, aNumber.Sign)
proc testApproxPrecision*() =
    var testInstance: BigDecimal = BigDecimal.Ten * BigDecimal.Parse("0.1", CultureInfo.InvariantCulture)
    var result: int = testInstance.CompareTo(BigDecimal.Parse("1.00", CultureInfo.InvariantCulture))
assertEquals("incorrect value", 0, result)