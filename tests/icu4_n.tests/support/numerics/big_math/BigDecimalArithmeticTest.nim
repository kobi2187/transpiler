# "Namespace: ICU4N.Numerics.BigMath"
type
  BigDecimalArithmeticTest = ref object


proc testAddEqualScalePosPos*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 10
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = 10
    var c: String = "123121247898748373566323807282924555312937.1991359555"
    var cScale: int = 10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = aNumber + bNumber
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testAddMathContextEqualScalePosPos*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 10
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = 10
    var c: String = "1.2313E+41"
    var cScale: int = -37
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var mc: MathContext = MathContext(5, RoundingMode.Up)
    var result: BigDecimal = BigDecimal.Add(aNumber, bNumber, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testAddEqualScaleNegNeg*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = -10
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = -10
    var c: String = "1.231212478987483735663238072829245553129371991359555E+61"
    var cScale: int = -10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = aNumber + bNumber
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testAddMathContextEqualScaleNegNeg*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = -10
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = -10
    var c: String = "1.2312E+61"
    var cScale: int = -57
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var mc: MathContext = MathContext(5, RoundingMode.Floor)
    var result: BigDecimal = BigDecimal.Add(aNumber, bNumber, mc)
assertEquals("incorrect value ", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testAddDiffScalePosNeg*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 15
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = -10
    var c: String = "7472334294161400358170962860775454459810457634.781384756794987"
    var cScale: int = 15
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = aNumber + bNumber
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testAddMathContextDiffScalePosNeg*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 15
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = -10
    var c: String = "7.47233429416141E+45"
    var cScale: int = -31
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var mc: MathContext = MathContext(15, RoundingMode.Ceiling)
    var result: BigDecimal = BigDecimal.Add(aNumber, bNumber, mc)
assertEquals("incorrect value", c, c.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testAddDiffScaleNegPos*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = -15
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = 10
    var c: String = "1231212478987482988429808779810457634781459480137916301878791834798.7234564568"
    var cScale: int = 10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = aNumber + bNumber
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testAddDiffScaleZeroZero*() =
    var a: String = "0"
    var aScale: int = -15
    var b: String = "0"
    var bScale: int = 10
    var c: String = "0E-10"
    var cScale: int = 10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = aNumber + bNumber
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testSubtractEqualScalePosPos*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 10
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = 10
    var c: String = "123121247898748224119637948679166971643339.7522230419"
    var cScale: int = 10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = aNumber - bNumber
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testSubtractMathContextEqualScalePosPos*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 10
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = 10
    var c: String = "1.23121247898749E+41"
    var cScale: int = -27
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var mc: MathContext = MathContext(15, RoundingMode.Ceiling)
    var result: BigDecimal = BigDecimal.Subtract(aNumber, bNumber, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testSubtractEqualScaleNegNeg*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = -10
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = -10
    var c: String = "1.231212478987482241196379486791669716433397522230419E+61"
    var cScale: int = -10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = aNumber - bNumber
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testSubtractDiffScalePosNeg*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 15
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = -10
    var c: String = "-7472334291698975400195996883915836900189542365.218615243205013"
    var cScale: int = 15
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = aNumber - bNumber
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testSubtractMathContextDiffScalePosNeg*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 15
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = -10
    var c: String = "-7.4723342916989754E+45"
    var cScale: int = -29
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var mc: MathContext = MathContext(17, RoundingMode.Down)
    var result: BigDecimal = BigDecimal.Subtract(aNumber, bNumber, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testSubtractDiffScaleNegPos*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = -15
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = 10
    var c: String = "1231212478987482988429808779810457634781310033452057698121208165201.2765435432"
    var cScale: int = 10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = aNumber - bNumber
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testSubtractMathContextDiffScaleNegPos*() =
    var a: String = "986798656676789766678767876078779810457634781384756794987"
    var aScale: int = -15
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = 40
    var c: String = "9.867986566767897666787678760787798104576347813847567949870000000000000E+71"
    var cScale: int = -2
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var mc: MathContext = MathContext(70, RoundingMode.HalfDown)
    var result: BigDecimal = BigDecimal.Subtract(aNumber, bNumber, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testMultiplyScalePosPos*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 15
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = 10
    var c: String = "92000312286217574978643009574114545567010139156902666284589309.1880727173060570190220616"
    var cScale: int = 25
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = aNumber * bNumber
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testMultiplyMathContextScalePosPos*() =
    var a: String = "97665696756578755423325476545428779810457634781384756794987"
    var aScale: int = -25
    var b: String = "87656965586786097685674786576598865"
    var bScale: int = 10
    var c: String = "8.561078619600910561431314228543672720908E+108"
    var cScale: int = -69
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var mc: MathContext = MathContext(40, RoundingMode.HalfDown)
    var result: BigDecimal = BigDecimal.Multiply(aNumber, bNumber, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testMultiplyEqualScaleNegNeg*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = -15
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = -10
    var c: String = "9.20003122862175749786430095741145455670101391569026662845893091880727173060570190220616E+111"
    var cScale: int = -25
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = aNumber * bNumber
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testMultiplyDiffScalePosNeg*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 10
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = -10
    var c: String = "920003122862175749786430095741145455670101391569026662845893091880727173060570190220616"
    var cScale: int = 0
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = aNumber * bNumber
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testMultiplyMathContextDiffScalePosNeg*() =
    var a: String = "987667796597975765768768767866756808779810457634781384756794987"
    var aScale: int = 100
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = -70
    var c: String = "7.3801839465418518653942222612429081498248509257207477E+68"
    var cScale: int = -16
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var mc: MathContext = MathContext(53, RoundingMode.HalfUp)
    var result: BigDecimal = BigDecimal.Multiply(aNumber, bNumber, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testMultiplyDiffScaleNegPos*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = -15
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = 10
    var c: String = "9.20003122862175749786430095741145455670101391569026662845893091880727173060570190220616E+91"
    var cScale: int = -5
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = aNumber * bNumber
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testMultiplyMathContextDiffScaleNegPos*() =
    var a: String = "488757458676796558668876576576579097029810457634781384756794987"
    var aScale: int = -63
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = 63
    var c: String = "3.6521591193960361339707130098174381429788164316E+98"
    var cScale: int = -52
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var mc: MathContext = MathContext(47, RoundingMode.HalfUp)
    var result: BigDecimal = BigDecimal.Multiply(aNumber, bNumber, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testPow*() =
    var a: String = "123121247898748298842980"
    var aScale: int = 10
    var exp: int = 10
    var c: String = "8004424019039195734129783677098845174704975003788210729597" + "4875206425711159855030832837132149513512555214958035390490" + "798520842025826.594316163502809818340013610490541783276343" + "6514490899700151256484355936102754469438371850240000000000"
    var cScale: int = 100
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var result: BigDecimal = BigDecimal.Pow(aNumber, exp)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testPow0*() =
    var a: String = "123121247898748298842980"
    var aScale: int = 10
    var exp: int = 0
    var c: String = "1"
    var cScale: int = 0
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var result: BigDecimal = BigDecimal.Pow(aNumber, exp)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testZeroPow0*() =
    var c: String = "1"
    var cScale: int = 0
    var result: BigDecimal = BigDecimal.Pow(BigDecimal.Zero, 0)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testPowMathContext*() =
    var a: String = "123121247898748298842980"
    var aScale: int = 10
    var exp: int = 10
    var c: String = "8.0044E+130"
    var cScale: int = -126
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var mc: MathContext = MathContext(5, RoundingMode.HalfUp)
    var result: BigDecimal = BigDecimal.Pow(aNumber, exp, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", cScale, result.Scale)
proc testDivideByZero*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 15
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal.GetInstance(0)
    try:
        var _ = aNumber / bNumber
fail("ArithmeticException has not been caught")
    except DivideByZeroException:
assertEquals("Improper exception message", "Division by zero", e.Message)
proc testDivideExceptionRM*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 15
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = 10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    try:
BigDecimal.Divide(aNumber, bNumber, RoundingMode.Unnecessary)
fail("ArithmeticException has not been caught")
    except ArithmeticException:
assertEquals("Improper exception message", "Rounding necessary", e.Message)
proc testDivideExceptionInvalidRM*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 15
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = 10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    try:
BigDecimal.Divide(aNumber, bNumber, cast[RoundingMode](100))
fail("IllegalArgumentException has not been caught")
    except ArgumentOutOfRangeException:

proc testDivideExpLessZero*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = 15
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = 10
    var c: String = "1.64770E+10"
    var resScale: int = -5
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.Ceiling)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideExpEqualsZero*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = -15
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = 10
    var c: String = "1.64769459009933764189139568605273529E+40"
    var resScale: int = -5
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.Ceiling)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideExpGreaterZero*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var aScale: int = -15
    var b: String = "747233429293018787918347987234564568"
    var bScale: int = 20
    var c: String = "1.647694590099337641891395686052735285121058381E+50"
    var resScale: int = -5
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.Ceiling)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRemainderIsZero*() =
    var a: String = "8311389578904553209874735431110"
    var aScale: int = -15
    var b: String = "237468273682987234567849583746"
    var bScale: int = 20
    var c: String = "3.5000000000000000000000000000000E+36"
    var resScale: int = -5
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.Ceiling)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundUpNeg*() =
    var a: String = "-92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "7472334223847623782375469293018787918347987234564568"
    var bScale: int = 13
    var c: String = "-1.24390557635720517122423359799284E+53"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.Ceiling)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundUpPos*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "7472334223847623782375469293018787918347987234564568"
    var bScale: int = 13
    var c: String = "1.24390557635720517122423359799284E+53"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.Up)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundDownNeg*() =
    var a: String = "-92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "7472334223847623782375469293018787918347987234564568"
    var bScale: int = 13
    var c: String = "-1.24390557635720517122423359799283E+53"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.Down)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundDownPos*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "7472334223847623782375469293018787918347987234564568"
    var bScale: int = 13
    var c: String = "1.24390557635720517122423359799283E+53"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.Down)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundFloorPos*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "7472334223847623782375469293018787918347987234564568"
    var bScale: int = 13
    var c: String = "1.24390557635720517122423359799283E+53"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.Floor)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundFloorNeg*() =
    var a: String = "-92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "7472334223847623782375469293018787918347987234564568"
    var bScale: int = 13
    var c: String = "-1.24390557635720517122423359799284E+53"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.Floor)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundCeilingPos*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "7472334223847623782375469293018787918347987234564568"
    var bScale: int = 13
    var c: String = "1.24390557635720517122423359799284E+53"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.Ceiling)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundCeilingNeg*() =
    var a: String = "-92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "7472334223847623782375469293018787918347987234564568"
    var bScale: int = 13
    var c: String = "-1.24390557635720517122423359799283E+53"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.Ceiling)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundHalfUpPos*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "7472334223847623782375469293018787918347987234564568"
    var bScale: int = 13
    var c: String = "1.24390557635720517122423359799284E+53"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.HalfUp)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundHalfUpNeg*() =
    var a: String = "-92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "7472334223847623782375469293018787918347987234564568"
    var bScale: int = 13
    var c: String = "-1.24390557635720517122423359799284E+53"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.HalfUp)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundHalfUpPos1*() =
    var a: String = "92948782094488478231212478987482988798104576347813847567949855464535634534563456"
    var aScale: int = -24
    var b: String = "74723342238476237823754692930187879183479"
    var bScale: int = 13
    var c: String = "1.2439055763572051712242335979928354832010167729111113605E+76"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.HalfUp)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundHalfUpNeg1*() =
    var a: String = "-92948782094488478231212478987482988798104576347813847567949855464535634534563456"
    var aScale: int = -24
    var b: String = "74723342238476237823754692930187879183479"
    var bScale: int = 13
    var c: String = "-1.2439055763572051712242335979928354832010167729111113605E+76"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.HalfUp)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundHalfUpNeg2*() =
    var a: String = "-37361671119238118911893939591735"
    var aScale: int = 10
    var b: String = "74723342238476237823787879183470"
    var bScale: int = 15
    var c: String = "-1E+5"
    var resScale: int = -5
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.HalfUp)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundHalfDownPos*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "7472334223847623782375469293018787918347987234564568"
    var bScale: int = 13
    var c: String = "1.24390557635720517122423359799284E+53"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.HalfDown)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundHalfDownNeg*() =
    var a: String = "-92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "7472334223847623782375469293018787918347987234564568"
    var bScale: int = 13
    var c: String = "-1.24390557635720517122423359799284E+53"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.HalfDown)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundHalfDownPos1*() =
    var a: String = "92948782094488478231212478987482988798104576347813847567949855464535634534563456"
    var aScale: int = -24
    var b: String = "74723342238476237823754692930187879183479"
    var bScale: int = 13
    var c: String = "1.2439055763572051712242335979928354832010167729111113605E+76"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.HalfDown)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundHalfDownNeg1*() =
    var a: String = "-92948782094488478231212478987482988798104576347813847567949855464535634534563456"
    var aScale: int = -24
    var b: String = "74723342238476237823754692930187879183479"
    var bScale: int = 13
    var c: String = "-1.2439055763572051712242335979928354832010167729111113605E+76"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.HalfDown)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundHalfDownNeg2*() =
    var a: String = "-37361671119238118911893939591735"
    var aScale: int = 10
    var b: String = "74723342238476237823787879183470"
    var bScale: int = 15
    var c: String = "0E+5"
    var resScale: int = -5
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.HalfDown)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundHalfEvenPos*() =
    var a: String = "92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "7472334223847623782375469293018787918347987234564568"
    var bScale: int = 13
    var c: String = "1.24390557635720517122423359799284E+53"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.HalfEven)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundHalfEvenNeg*() =
    var a: String = "-92948782094488478231212478987482988429808779810457634781384756794987"
    var aScale: int = -24
    var b: String = "7472334223847623782375469293018787918347987234564568"
    var bScale: int = 13
    var c: String = "-1.24390557635720517122423359799284E+53"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.HalfEven)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundHalfEvenPos1*() =
    var a: String = "92948782094488478231212478987482988798104576347813847567949855464535634534563456"
    var aScale: int = -24
    var b: String = "74723342238476237823754692930187879183479"
    var bScale: int = 13
    var c: String = "1.2439055763572051712242335979928354832010167729111113605E+76"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.HalfEven)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundHalfEvenNeg1*() =
    var a: String = "-92948782094488478231212478987482988798104576347813847567949855464535634534563456"
    var aScale: int = -24
    var b: String = "74723342238476237823754692930187879183479"
    var bScale: int = 13
    var c: String = "-1.2439055763572051712242335979928354832010167729111113605E+76"
    var resScale: int = -21
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.HalfEven)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideRoundHalfEvenNeg2*() =
    var a: String = "-37361671119238118911893939591735"
    var aScale: int = 10
    var b: String = "74723342238476237823787879183470"
    var bScale: int = 15
    var c: String = "0E+5"
    var resScale: int = -5
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, resScale, RoundingMode.HalfEven)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideBigDecimal1*() =
    var a: String = "-37361671119238118911893939591735"
    var aScale: int = 10
    var b: String = "74723342238476237823787879183470"
    var bScale: int = 15
    var c: String = "-5E+4"
    var resScale: int = -4
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = aNumber / bNumber
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideBigDecimal2*() =
    var a: String = "-37361671119238118911893939591735"
    var aScale: int = 10
    var b: String = "74723342238476237823787879183470"
    var bScale: int = -15
    var c: String = "-5E-26"
    var resScale: int = 26
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = aNumber / bNumber
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideBigDecimalScaleRoundingModeUP*() =
    var a: String = "-37361671119238118911893939591735"
    var aScale: int = 10
    var b: String = "74723342238476237823787879183470"
    var bScale: int = -15
    var newScale: int = 31
    var rm: RoundingMode = RoundingMode.Up
    var c: String = "-5.00000E-26"
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, newScale, rm)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", newScale, result.Scale)
proc testDivideBigDecimalScaleRoundingModeDOWN*() =
    var a: String = "-37361671119238118911893939591735"
    var aScale: int = 10
    var b: String = "74723342238476237823787879183470"
    var bScale: int = 15
    var newScale: int = 31
    var rm: RoundingMode = RoundingMode.Down
    var c: String = "-50000.0000000000000000000000000000000"
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, newScale, rm)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", newScale, result.Scale)
proc testDivideBigDecimalScaleRoundingModeCEILING*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 100
    var b: String = "74723342238476237823787879183470"
    var bScale: int = 15
    var newScale: int = 45
    var rm: RoundingMode = RoundingMode.Ceiling
    var c: String = "1E-45"
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, newScale, rm)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", newScale, result.Scale)
proc testDivideBigDecimalScaleRoundingModeFLOOR*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 100
    var b: String = "74723342238476237823787879183470"
    var bScale: int = 15
    var newScale: int = 45
    var rm: RoundingMode = RoundingMode.Floor
    var c: String = "0E-45"
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, newScale, rm)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", newScale, result.Scale)
proc testDivideBigDecimalScaleRoundingModeHALF_UP*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = -51
    var b: String = "74723342238476237823787879183470"
    var bScale: int = 45
    var newScale: int = 3
    var rm: RoundingMode = RoundingMode.HalfUp
    var c: String = "50000260373164286401361913262100972218038099522752460421" + "05959924024355721031761947728703598332749334086415670525" + "3761096961.670"
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, newScale, rm)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", newScale, result.Scale)
proc testDivideBigDecimalScaleRoundingModeHALF_DOWN*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 5
    var b: String = "74723342238476237823787879183470"
    var bScale: int = 15
    var newScale: int = 7
    var rm: RoundingMode = RoundingMode.HalfDown
    var c: String = "500002603731642864013619132621009722.1803810"
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, newScale, rm)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", newScale, result.Scale)
proc testDivideBigDecimalScaleRoundingModeHALF_EVEN*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 5
    var b: String = "74723342238476237823787879183470"
    var bScale: int = 15
    var newScale: int = 7
    var rm: RoundingMode = RoundingMode.HalfEven
    var c: String = "500002603731642864013619132621009722.1803810"
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, newScale, rm)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", newScale, result.Scale)
proc testDivideBigDecimalScaleMathContextUP*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 15
    var b: String = "748766876876723342238476237823787879183470"
    var bScale: int = 10
    var precision: int = 21
    var rm: RoundingMode = RoundingMode.Up
    var mc: MathContext = MathContext(precision, rm)
    var c: String = "49897861180.2562512996"
    var resScale: int = 10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideBigDecimalScaleMathContextDOWN*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 15
    var b: String = "748766876876723342238476237823787879183470"
    var bScale: int = 70
    var precision: int = 21
    var rm: RoundingMode = RoundingMode.Down
    var mc: MathContext = MathContext(precision, rm)
    var c: String = "4.98978611802562512995E+70"
    var resScale: int = -50
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideBigDecimalScaleMathContextCEILING*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 15
    var b: String = "748766876876723342238476237823787879183470"
    var bScale: int = 70
    var precision: int = 21
    var rm: RoundingMode = RoundingMode.Ceiling
    var mc: MathContext = MathContext(precision, rm)
    var c: String = "4.98978611802562512996E+70"
    var resScale: int = -50
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideBigDecimalScaleMathContextFLOOR*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 15
    var b: String = "748766876876723342238476237823787879183470"
    var bScale: int = 70
    var precision: int = 21
    var rm: RoundingMode = RoundingMode.Floor
    var mc: MathContext = MathContext(precision, rm)
    var c: String = "4.98978611802562512995E+70"
    var resScale: int = -50
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideBigDecimalScaleMathContextHALF_UP*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 45
    var b: String = "134432345432345748766876876723342238476237823787879183470"
    var bScale: int = 70
    var precision: int = 21
    var rm: RoundingMode = RoundingMode.HalfUp
    var mc: MathContext = MathContext(precision, rm)
    var c: String = "2.77923185514690367475E+26"
    var resScale: int = -6
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideBigDecimalScaleMathContextHALF_DOWN*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 45
    var b: String = "134432345432345748766876876723342238476237823787879183470"
    var bScale: int = 70
    var precision: int = 21
    var rm: RoundingMode = RoundingMode.HalfDown
    var mc: MathContext = MathContext(precision, rm)
    var c: String = "2.77923185514690367475E+26"
    var resScale: int = -6
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideBigDecimalScaleMathContextHALF_EVEN*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 45
    var b: String = "134432345432345748766876876723342238476237823787879183470"
    var bScale: int = 70
    var precision: int = 21
    var rm: RoundingMode = RoundingMode.HalfEven
    var mc: MathContext = MathContext(precision, rm)
    var c: String = "2.77923185514690367475E+26"
    var resScale: int = -6
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideLargeScale*() =
    var arg1: BigDecimal = BigDecimal.Parse("320.0E+2147483647", CultureInfo.InvariantCulture)
    var arg2: BigDecimal = BigDecimal.Parse("6E-2147483647", CultureInfo.InvariantCulture)
    try:
        var result: BigDecimal = BigDecimal.Divide(arg1, arg2, int.MaxValue, RoundingMode.Ceiling)
fail("Expected ArithmeticException when dividing with a scale that's too large")
    except ArithmeticException:

proc testDivideToIntegralValue*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 45
    var b: String = "134432345432345748766876876723342238476237823787879183470"
    var bScale: int = 70
    var c: String = "277923185514690367474770683"
    var resScale: int = 0
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.DivideToIntegralValue(aNumber, bNumber)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideToIntegralValueMathContextUP*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 45
    var b: String = "134432345432345748766876876723342238476237823787879183470"
    var bScale: int = 70
    var precision: int = 32
    var rm: RoundingMode = RoundingMode.Up
    var mc: MathContext = MathContext(precision, rm)
    var c: String = "277923185514690367474770683"
    var resScale: int = 0
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Divide(aNumber, bNumber, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideToIntegralValueMathContextDOWN*() =
    var a: String = "3736186567876876578956958769675785435673453453653543654354365435675671119238118911893939591735"
    var aScale: int = 45
    var b: String = "134432345432345748766876876723342238476237823787879183470"
    var bScale: int = 70
    var precision: int = 75
    var rm: RoundingMode = RoundingMode.Down
    var mc: MathContext = MathContext(precision, rm)
    var c: String = "2.7792318551469036747477068339450205874992634417590178670822889E+62"
    var resScale: int = -1
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.DivideToIntegralValue(aNumber, bNumber, mc)
assertEquals("incorrect value", c, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testDivideAndRemainder1*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 45
    var b: String = "134432345432345748766876876723342238476237823787879183470"
    var bScale: int = 70
    var res: String = "277923185514690367474770683"
    var resScale: int = 0
    var rem: String = "1.3032693871288309587558885943391070087960319452465789990E-15"
    var remScale: int = 70
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result0: BigDecimal = BigDecimal.DivideAndRemainder(aNumber, bNumber,     var result1: BigDecimal)
assertEquals("incorrect quotient value", res, result0.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect quotient scale", resScale, result0.Scale)
assertEquals("incorrect remainder value", rem, result1.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect remainder scale", remScale, result1.Scale)
proc testDivideAndRemainder2*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = -45
    var b: String = "134432345432345748766876876723342238476237823787879183470"
    var bScale: int = 70
    var res: String = "2779231855146903674747706830969461168692256919247547952" + "2608549363170374005512836303475980101168105698072946555" + "6862849"
    var resScale: int = 0
    var rem: String = "3.4935796954060524114470681810486417234751682675102093970E-15"
    var remScale: int = 70
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result0: BigDecimal = BigDecimal.DivideAndRemainder(aNumber, bNumber,     var result1: BigDecimal)
assertEquals("incorrect quotient value", res, result0.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect quotient scale", resScale, result0.Scale)
assertEquals("incorrect remainder value", rem, result1.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect remainder scale", remScale, result1.Scale)
proc testDivideAndRemainderMathContextUP*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 45
    var b: String = "134432345432345748766876876723342238476237823787879183470"
    var bScale: int = 70
    var precision: int = 75
    var rm: RoundingMode = RoundingMode.Up
    var mc: MathContext = MathContext(precision, rm)
    var res: String = "277923185514690367474770683"
    var resScale: int = 0
    var rem: String = "1.3032693871288309587558885943391070087960319452465789990E-15"
    var remScale: int = 70
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result0: BigDecimal = BigDecimal.DivideAndRemainder(aNumber, bNumber, mc,     var result1: BigDecimal)
assertEquals("incorrect quotient value", res, result0.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect quotient scale", resScale, result0.Scale)
assertEquals("incorrect remainder value", rem, result1.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect remainder scale", remScale, result1.Scale)
proc testDivideAndRemainderMathContextDOWN*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 45
    var b: String = "134432345432345748766876876723342238476237823787879183470"
    var bScale: int = 20
    var precision: int = 15
    var rm: RoundingMode = RoundingMode.Down
    var mc: MathContext = MathContext(precision, rm)
    var res: String = "0E-25"
    var resScale: int = 25
    var rem: String = "3736186567876.876578956958765675671119238118911893939591735"
    var remScale: int = 45
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result0: BigDecimal = BigDecimal.DivideAndRemainder(aNumber, bNumber, mc,     var result1: BigDecimal)
assertEquals("incorrect quotient value", res, result0.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect quotient scale", resScale, result0.Scale)
assertEquals("incorrect remainder value", rem, result1.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect remainder scale", remScale, result1.Scale)
proc testRemainder1*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 45
    var b: String = "134432345432345748766876876723342238476237823787879183470"
    var bScale: int = 10
    var res: String = "3736186567876.876578956958765675671119238118911893939591735"
    var resScale: int = 45
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Remainder(aNumber, bNumber)
assertEquals("incorrect quotient value", res, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect quotient scale", resScale, result.Scale)
proc testRemainder2*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = -45
    var b: String = "134432345432345748766876876723342238476237823787879183470"
    var bScale: int = 10
    var res: String = "1149310942946292909508821656680979993738625937.2065885780"
    var resScale: int = 10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Remainder(aNumber, bNumber)
assertEquals("incorrect quotient value", res, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect quotient scale", resScale, result.Scale)
proc testRemainderMathContextHALF_UP*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 45
    var b: String = "134432345432345748766876876723342238476237823787879183470"
    var bScale: int = 10
    var precision: int = 15
    var rm: RoundingMode = RoundingMode.HalfUp
    var mc: MathContext = MathContext(precision, rm)
    var res: String = "3736186567876.876578956958765675671119238118911893939591735"
    var resScale: int = 45
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Remainder(aNumber, bNumber, mc)
assertEquals("incorrect quotient value", res, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect quotient scale", resScale, result.Scale)
proc testRemainderMathContextHALF_DOWN*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = -45
    var b: String = "134432345432345748766876876723342238476237823787879183470"
    var bScale: int = 10
    var precision: int = 75
    var rm: RoundingMode = RoundingMode.HalfDown
    var mc: MathContext = MathContext(precision, rm)
    var res: String = "1149310942946292909508821656680979993738625937.2065885780"
    var resScale: int = 10
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var bNumber: BigDecimal = BigDecimal(BigInteger.Parse(b), bScale)
    var result: BigDecimal = BigDecimal.Remainder(aNumber, bNumber, mc)
assertEquals("incorrect quotient value", res, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect quotient scale", resScale, result.Scale)
proc testRoundMathContextHALF_DOWN*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = -45
    var precision: int = 75
    var rm: RoundingMode = RoundingMode.HalfDown
    var mc: MathContext = MathContext(precision, rm)
    var res: String = "3.736186567876876578956958765675671119238118911893939591735E+102"
    var resScale: int = -45
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var result: BigDecimal = BigDecimal.Round(aNumber, mc)
assertEquals("incorrect quotient value", res, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect quotient scale", resScale, result.Scale)
proc testRoundMathContextHALF_UP*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 45
    var precision: int = 15
    var rm: RoundingMode = RoundingMode.HalfUp
    var mc: MathContext = MathContext(precision, rm)
    var res: String = "3736186567876.88"
    var resScale: int = 2
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var result: BigDecimal = BigDecimal.Round(aNumber, mc)
assertEquals("incorrect quotient value", res, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect quotient scale", resScale, result.Scale)
proc testRoundMathContextPrecision0*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 45
    var precision: int = 0
    var rm: RoundingMode = RoundingMode.HalfUp
    var mc: MathContext = MathContext(precision, rm)
    var res: String = "3736186567876.876578956958765675671119238118911893939591735"
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var result: BigDecimal = BigDecimal.Round(aNumber, mc)
assertEquals("incorrect quotient value", res, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect quotient scale", aScale, result.Scale)
proc testUlpPos*() =
    var a: String = "3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = -45
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var result: BigDecimal = BigDecimal.Ulp(aNumber)
    var res: String = "1E+45"
    var resScale: int = -45
assertEquals("incorrect value", res, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testUlpNeg*() =
    var a: String = "-3736186567876876578956958765675671119238118911893939591735"
    var aScale: int = 45
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var result: BigDecimal = BigDecimal.Ulp(aNumber)
    var res: String = "1E-45"
    var resScale: int = 45
assertEquals("incorrect value", res, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testUlpZero*() =
    var a: String = "0"
    var aScale: int = 2
    var aNumber: BigDecimal = BigDecimal(BigInteger.Parse(a), aScale)
    var result: BigDecimal = BigDecimal.Ulp(aNumber)
    var res: String = "0.01"
    var resScale: int = 2
assertEquals("incorrect value", res, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)