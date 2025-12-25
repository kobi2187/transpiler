# "Namespace: ICU4N.Numerics.BigMath"
type
  BigDecimalScaleOperationsTest = ref object


proc testScaleDefault*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var cScale: int = 0
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a))
assertTrue("incorrect scale", aNumber.Scale == cScale)
proc testScaleNeg*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = -10
    var cScale: int = -10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
assertTrue("incorrect scale", aNumber.Scale == cScale)
proc testScalePos*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 10
    var cScale: int = 10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
assertTrue("incorrect scale", aNumber.Scale == cScale)
proc testScaleZero*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 0
    var cScale: int = 0
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
assertTrue("incorrect scale", aNumber.Scale == cScale)
proc testUnscaledValue*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 100
    var bNumber: BigInteger = BigInteger.Parse(a)
    var aNumber: BigDecimal = BigDecimal(bNumber, aScale)
assertTrue("incorrect unscaled value", aNumber.UnscaledValue.Equals(bNumber))
proc testSetScaleGreater*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 18
    var newScale: int = 28
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal.SetScale(aNumber, newScale)
assertTrue("incorrect scale", bNumber.Scale == newScale)
assertEquals("incorrect value", 0, bNumber.CompareTo(aNumber))
proc testSetScaleLess*() =
    var a: String = "2.345726458768760000E+10"
    var newScale: int = 5
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
    var bNumber: BigDecimal = BigDecimal.SetScale(aNumber, newScale)
assertTrue("incorrect scale", bNumber.Scale == newScale)
assertEquals("incorrect value", 0, bNumber.CompareTo(aNumber))
proc testSetScaleException*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 28
    var newScale: int = 18
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    try:
BigDecimal.SetScale(aNumber, newScale)
fail("ArithmeticException has not been caught")
    except ArithmeticException:
assertEquals("Improper exception message", "Rounding necessary", e.Message)
proc testSetScaleSame*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 18
    var newScale: int = 18
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal.SetScale(aNumber, newScale)
assertTrue("incorrect scale", bNumber.Scale == newScale)
assertTrue("incorrect value", bNumber.Equals(aNumber))
proc testSetScaleRoundUp*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var b: String = "123121247898748298842980877981045763478139"
    var aScale: int = 28
    var newScale: int = 18
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal.SetScale(aNumber, newScale, RoundingMode.Up)
assertTrue("incorrect scale", bNumber.Scale == newScale)
assertTrue("incorrect value", bNumber.UnscaledValue.ToString(CultureInfo.InvariantCulture).Equals(b))
proc testSetScaleRoundDown*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var b: String = "123121247898748298842980877981045763478138"
    var aScale: int = 28
    var newScale: int = 18
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal.SetScale(aNumber, newScale, RoundingMode.Down)
assertTrue("incorrect scale", bNumber.Scale == newScale)
assertTrue("incorrect value", bNumber.UnscaledValue.ToString(CultureInfo.InvariantCulture).Equals(b))
proc testSetScaleRoundCeiling*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var b: String = "123121247898748298842980877981045763478139"
    var aScale: int = 28
    var newScale: int = 18
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal.SetScale(aNumber, newScale, RoundingMode.Ceiling)
assertTrue("incorrect scale", bNumber.Scale == newScale)
assertTrue("incorrect value", bNumber.UnscaledValue.ToString(CultureInfo.InvariantCulture).Equals(b))
proc testSetScaleRoundFloor*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var b: String = "123121247898748298842980877981045763478138"
    var aScale: int = 28
    var newScale: int = 18
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal.SetScale(aNumber, newScale, RoundingMode.Floor)
assertTrue("incorrect scale", bNumber.Scale == newScale)
assertTrue("incorrect value", bNumber.UnscaledValue.ToString(CultureInfo.InvariantCulture).Equals(b))
proc testSetScaleRoundHalfUp*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var b: String = "123121247898748298842980877981045763478138"
    var aScale: int = 28
    var newScale: int = 18
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal.SetScale(aNumber, newScale, RoundingMode.HalfUp)
assertTrue("incorrect scale", bNumber.Scale == newScale)
assertTrue("incorrect value", bNumber.UnscaledValue.ToString(CultureInfo.InvariantCulture).Equals(b))
proc testSetScaleRoundHalfDown*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var b: String = "123121247898748298842980877981045763478138"
    var aScale: int = 28
    var newScale: int = 18
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal.SetScale(aNumber, newScale, RoundingMode.HalfDown)
assertTrue("incorrect scale", bNumber.Scale == newScale)
assertTrue("incorrect value", bNumber.UnscaledValue.ToString(CultureInfo.InvariantCulture).Equals(b))
proc testSetScaleRoundHalfEven*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var b: String = "123121247898748298842980877981045763478138"
    var aScale: int = 28
    var newScale: int = 18
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal.SetScale(aNumber, newScale, RoundingMode.HalfEven)
assertTrue("incorrect scale", bNumber.Scale == newScale)
assertTrue("incorrect value", bNumber.UnscaledValue.ToString(CultureInfo.InvariantCulture).Equals(b))
proc testSetScaleIntRoundingMode*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 28
    var newScale: int = 18
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var result: BigDecimal = BigDecimal.SetScale(aNumber, newScale, RoundingMode.HalfEven)
    var res: String = "123121247898748298842980.877981045763478138"
    var resScale: int = 18
assertEquals("incorrect value", res, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testMovePointLeftPos*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 28
    var shift: int = 18
    var resScale: int = 46
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal.MovePointLeft(aNumber, shift)
assertTrue("incorrect scale", bNumber.Scale == resScale)
assertTrue("incorrect value", bNumber.UnscaledValue.ToString(CultureInfo.InvariantCulture).Equals(a))
proc testMovePointLeftNeg*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 28
    var shift: int = -18
    var resScale: int = 10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal.MovePointLeft(aNumber, shift)
assertTrue("incorrect scale", bNumber.Scale == resScale)
assertTrue("incorrect value", bNumber.UnscaledValue.ToString(CultureInfo.InvariantCulture).Equals(a))
proc testMovePointRightPosGreater*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 28
    var shift: int = 18
    var resScale: int = 10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal.MovePointRight(aNumber, shift)
assertTrue("incorrect scale", bNumber.Scale == resScale)
assertTrue("incorrect value", bNumber.UnscaledValue.ToString(CultureInfo.InvariantCulture).Equals(a))
proc testMovePointRightPosLess*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var b: String = "123121247898748298842980877981045763478138475679498700"
    var aScale: int = 28
    var shift: int = 30
    var resScale: int = 0
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal.MovePointRight(aNumber, shift)
assertTrue("incorrect scale", bNumber.Scale == resScale)
assertTrue("incorrect value", bNumber.UnscaledValue.ToString(CultureInfo.InvariantCulture).Equals(b))
proc testMovePointRightNeg*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 28
    var shift: int = -18
    var resScale: int = 46
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal.MovePointRight(aNumber, shift)
assertTrue("incorrect scale", bNumber.Scale == resScale)
assertTrue("incorrect value", bNumber.UnscaledValue.ToString(CultureInfo.InvariantCulture).Equals(a))
proc testMovePointRightException*() =
    var a: String = "12312124789874829887348723648726347429808779810457634781384756794987"
    var aScale: int = int.MaxValue
    var shift: int = -18
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    try:
BigDecimal.MovePointRight(aNumber, shift)
fail("ArithmeticException has not been caught")
    except ArithmeticException:
assertEquals("Improper exception message", "Underflow", e.Message)
proc testPrecision*() =
    var a: String = "12312124789874829887348723648726347429808779810457634781384756794987"
    var aScale: int = 14
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var prec: int = aNumber.Precision
assertEquals("incorrect value", 68, prec)