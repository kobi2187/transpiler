# "Namespace: ICU4N.Numerics.BigMath"
type
  BigDecimalConstructorsTest = ref object


proc testFieldONE*() =
    var oneS: String = "1"
    var oneD: double = 1.0
assertEquals("incorrect string value", oneS, BigDecimal.One.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect double value", oneD, BigDecimal.One.ToDouble, 0)
proc testFieldTEN*() =
    var oneS: String = "10"
    var oneD: double = 10.0
assertEquals("incorrect string value", oneS, BigDecimal.Ten.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect double value", oneD, BigDecimal.Ten.ToDouble, 0)
proc testFieldZERO*() =
    var oneS: String = "0"
    var oneD: double = 0.0
assertEquals("incorrect string value", oneS, BigDecimal.Zero.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect double value", oneD, BigDecimal.Zero.ToDouble, 0)
proc testConstrBI*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var bA: BigInteger = BigInteger.Parse(a)
    var aNumber: BigDecimal = BigDecimal(bA)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", 0, aNumber.Scale)
    try:
BigDecimal(cast[BigInteger](nil))
fail("No NullPointerException")
    except ArgumentNullException:

proc testConstrBIScale*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var bA: BigInteger = BigInteger.Parse(a)
    var aScale: int = 10
    var aNumber: BigDecimal = BigDecimal(bA, aScale)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrBigIntegerMathContext*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var bA: BigInteger = BigInteger.Parse(a)
    var precision: int = 46
    var rm: RoundingMode = RoundingMode.Ceiling
    var mc: MathContext = MathContext(precision, rm)
    var res: String = "1231212478987482988429808779810457634781384757"
    var resScale: int = -6
    var result: BigDecimal = BigDecimal(bA, mc)
assertEquals("incorrect value", res, result.UnscaledValue.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testConstrBigIntegerScaleMathContext*() =
    var a: String = "1231212478987482988429808779810457634781384756794987"
    var bA: BigInteger = BigInteger.Parse(a)
    var aScale: int = 10
    var precision: int = 46
    var rm: RoundingMode = RoundingMode.Ceiling
    var mc: MathContext = MathContext(precision, rm)
    var res: String = "1231212478987482988429808779810457634781384757"
    var resScale: int = 4
    var result: BigDecimal = BigDecimal(bA, aScale, mc)
assertEquals("incorrect value", res, result.UnscaledValue.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testConstrChar*() =
    var value: char[] = @['-', '1', '2', '3', '8', '0', '.', '4', '7', '3', '8', 'E', '-', '4', '2', '3']
    var result: BigDecimal = BigDecimal.Parse(value, CultureInfo.InvariantCulture)
    var res: String = "-1.23804738E-419"
    var resScale: int = 427
assertEquals("incorrect value", res, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
    try:
BigDecimal.Parse(@[], CultureInfo.InvariantCulture)
fail("NumberFormatException has not been thrown")
    except FormatException:

proc testConstrCharIntInt*() =
    var value: char[] = @['-', '1', '2', '3', '8', '0', '.', '4', '7', '3', '8', 'E', '-', '4', '2', '3']
    var offset: int = 3
    var len: int = 12
    var result: BigDecimal = BigDecimal.Parse(value, offset, len, CultureInfo.InvariantCulture)
    var res: String = "3.804738E-40"
    var resScale: int = 46
assertEquals("incorrect value", res, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
    try:
BigDecimal.Parse(@[], 0, 0, CultureInfo.InvariantCulture)
fail("NumberFormatException has not been thrown")
    except FormatException:

proc testConstrCharIntIntMathContext*() =
    var value: char[] = @['-', '1', '2', '3', '8', '0', '.', '4', '7', '3', '8', 'E', '-', '4', '2', '3']
    var offset: int = 3
    var len: int = 12
    var precision: int = 4
    var rm: RoundingMode = RoundingMode.Ceiling
    var mc: MathContext = MathContext(precision, rm)
    var result: BigDecimal = BigDecimal.Parse(value, offset, len, mc, CultureInfo.InvariantCulture)
    var res: String = "3.805E-40"
    var resScale: int = 43
assertEquals("incorrect value", res, result.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
    try:
BigDecimal.Parse(@[], 0, 0, MathContext.Decimal32, CultureInfo.InvariantCulture)
fail("NumberFormatException has not been thrown")
    except FormatException:

proc testConstrCharIntIntMathContextException1*() =
    var value: char[] = @['-', '1', '2', '3', '8', '0', '.', '4', '7', '3', '8', 'E', '-', '4', '2', '3']
    var offset: int = 3
    var len: int = 120
    var precision: int = 4
    var rm: RoundingMode = RoundingMode.Ceiling
    var mc: MathContext = MathContext(precision, rm)
    try:
BigDecimal.Parse(value, offset, len, mc, CultureInfo.InvariantCulture)
fail("NumberFormatException has not been thrown")
    except ArgumentOutOfRangeException:

proc testConstrCharIntIntMathContextException2*() =
    var value: char[] = @['-', '1', '2', '3', '8', '0', ',', '4', '7', '3', '8', 'E', '-', '4', '2', '3']
    var offset: int = 3
    var len: int = 120
    var precision: int = 4
    var rm: RoundingMode = RoundingMode.Ceiling
    var mc: MathContext = MathContext(precision, rm)
    try:
BigDecimal.Parse(value, offset, len, mc, CultureInfo.InvariantCulture)
fail("NumberFormatException has not been thrown")
    except ArgumentOutOfRangeException:

proc testConstrCharMathContext*() =
    try:
BigDecimal.Parse(@[], MathContext.Decimal32, CultureInfo.InvariantCulture)
fail("NumberFormatException has not been thrown")
    except FormatException:

proc testConstrDoubleNaN*() =
    var a: double = Double.NaN
    try:
BigDecimal(a)
fail("NumberFormatException has not been caught")
    except OverflowException:
assertEquals("Improper exception message", "Infinite or NaN", e.Message)
proc testConstrDoublePosInfinity*() =
    var a: double = double.PositiveInfinity
    try:
BigDecimal(a)
fail("NumberFormatException has not been caught")
    except OverflowException:
assertEquals("Improper exception message", "Infinite or NaN", e.Message)
proc testConstrDoubleNegInfinity*() =
    var a: double = double.NegativeInfinity
    try:
BigDecimal(a)
fail("NumberFormatException has not been caught")
    except OverflowException:
assertEquals("Improper exception message", "Infinite or NaN", e.Message)
proc testConstrDouble*() =
    var a: double = 7.325469823749823e+35
    var aScale: int = 0
    var bA: BigInteger = BigInteger.Parse("732546982374982285073458350476230656")
    var aNumber: BigDecimal = BigDecimal(a)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrDoubleMathContext*() =
    var a: double = 7.325469823749823e+35
    var precision: int = 21
    var rm: RoundingMode = RoundingMode.Ceiling
    var mc: MathContext = MathContext(precision, rm)
    var res: String = "732546982374982285074"
    var resScale: int = -15
    var result: BigDecimal = BigDecimal(a, mc)
assertEquals("incorrect value", res, result.UnscaledValue.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testConstrDouble01*() =
    var a: double = 0.1
    var aScale: int = 55
    var bA: BigInteger = BigInteger.Parse("1000000000000000055511151231257827021181583404541015625")
    var aNumber: BigDecimal = BigDecimal(a)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrDouble02*() =
    var a: double = 0.555
    var aScale: int = 53
    var bA: BigInteger = BigInteger.Parse("55500000000000004884981308350688777863979339599609375")
    var aNumber: BigDecimal = BigDecimal(a)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrDoubleMinus01*() =
    var a: double = -0.1
    var aScale: int = 55
    var bA: BigInteger = BigInteger.Parse("-1000000000000000055511151231257827021181583404541015625")
    var aNumber: BigDecimal = BigDecimal(a)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrInt*() =
    var a: int = 732546982
    var res: String = "732546982"
    var resScale: int = 0
    var result: BigDecimal = BigDecimal(a)
assertEquals("incorrect value", res, result.UnscaledValue.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testConstrIntMathContext*() =
    var a: int = 732546982
    var precision: int = 21
    var rm: RoundingMode = RoundingMode.Ceiling
    var mc: MathContext = MathContext(precision, rm)
    var res: String = "732546982"
    var resScale: int = 0
    var result: BigDecimal = BigDecimal(a, mc)
assertEquals("incorrect value", res, result.UnscaledValue.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testConstrLong*() =
    var a: long = 4576578677732546982
    var res: String = "4576578677732546982"
    var resScale: int = 0
    var result: BigDecimal = BigDecimal(a)
assertEquals("incorrect value", res, result.UnscaledValue.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testConstrLongMathContext*() =
    var a: long = 4576578677732546982
    var precision: int = 5
    var rm: RoundingMode = RoundingMode.Ceiling
    var mc: MathContext = MathContext(precision, rm)
    var res: String = "45766"
    var resScale: int = -14
    var result: BigDecimal = BigDecimal(a, mc)
assertEquals("incorrect value", res, result.UnscaledValue.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)
proc testConstrDoubleDenormalized*() =
    var a: double = 2.274341322658976e-309
    var aScale: int = 1073
    var bA: BigInteger = BigInteger.Parse("227434132265897633950269241702666687639731047124115603942986140264569528085692462493371029187342478828091760934014851133733918639492582043963243759464684978401240614084312038547315281016804838374623558434472007664427140169018817050565150914041833284370702366055678057809362286455237716100382057360123091641959140448783514464639706721250400288267372238950016114583259228262046633530468551311769574111763316146065958042194569102063373243372766692713192728878701004405568459288708477607744497502929764155046100964958011009313090462293046650352146796805866786767887226278836423536035611825593567576424943331337401071583562754098901412372708947790843318760718495117047155597276492717187936854356663665005157041552436478744491526494952982062613955349661409854888916015625")
    var aNumber: BigDecimal = BigDecimal(a)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrStringException*() =
    var a: String = "-238768.787678287a+10"
    try:
BigDecimal.Parse(a, CultureInfo.InvariantCulture)
fail("NumberFormatException has not been caught")
    except FormatException:

proc testConstrStringExceptionEmptyExponent1*() =
    var a: String = "-238768.787678287e"
    try:
BigDecimal.Parse(a, CultureInfo.InvariantCulture)
fail("NumberFormatException has not been caught")
    except FormatException:

proc testConstrStringExceptionEmptyExponent2*() =
    var a: String = "-238768.787678287e-"
    try:
BigDecimal.Parse(a, CultureInfo.InvariantCulture)
fail("NumberFormatException has not been caught")
    except FormatException:

proc testConstrStringExceptionExponentGreaterIntegerMax*() =
    var a: String = "-238768.787678287e214748364767876"
    try:
BigDecimal.Parse(a, CultureInfo.InvariantCulture)
fail("NumberFormatException has not been caught")
    except OverflowException:

proc testConstrStringExceptionExponentLessIntegerMin*() =
    var a: String = "-238768.787678287e-214748364767876"
    try:
BigDecimal.Parse(a, CultureInfo.InvariantCulture)
fail("NumberFormatException has not been caught")
    except OverflowException:

proc testConstrStringExponentIntegerMax*() =
    var a: String = "-238768.787678287e2147483647"
    var aScale: int = -2147483638
    var bA: BigInteger = BigInteger.Parse("-238768787678287")
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrStringExponentIntegerMin*() =
    var a: String = ".238768e-2147483648"
    try:
BigDecimal.Parse(a, CultureInfo.InvariantCulture)
fail("NumberFormatException expected")
    except FormatException:
assertEquals("Improper exception message", "Scale out of range.", e.Message)
proc testConstrStringWithoutExpPos1*() =
    var a: String = "732546982374982347892379283571094797.287346782359284756"
    var aScale: int = 18
    var bA: BigInteger = BigInteger.Parse("732546982374982347892379283571094797287346782359284756")
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrStringWithoutExpPos2*() =
    var a: String = "+732546982374982347892379283571094797.287346782359284756"
    var aScale: int = 18
    var bA: BigInteger = BigInteger.Parse("732546982374982347892379283571094797287346782359284756")
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrStringWithoutExpNeg*() =
    var a: String = "-732546982374982347892379283571094797.287346782359284756"
    var aScale: int = 18
    var bA: BigInteger = BigInteger.Parse("-732546982374982347892379283571094797287346782359284756")
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrStringWithoutExpWithoutPoint*() =
    var a: String = "-732546982374982347892379283571094797287346782359284756"
    var aScale: int = 0
    var bA: BigInteger = BigInteger.Parse("-732546982374982347892379283571094797287346782359284756")
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrStringWithExponentWithoutPoint1*() =
    var a: String = "-238768787678287e214"
    var aScale: int = -214
    var bA: BigInteger = BigInteger.Parse("-238768787678287")
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrStringWithExponentWithoutPoint2*() =
    var a: String = "-238768787678287e-214"
    var aScale: int = 214
    var bA: BigInteger = BigInteger.Parse("-238768787678287")
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrStringWithExponentWithoutPoint3*() =
    var a: String = "238768787678287e-214"
    var aScale: int = 214
    var bA: BigInteger = BigInteger.Parse("238768787678287")
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrStringWithExponentWithoutPoint4*() =
    var a: String = "238768787678287e+214"
    var aScale: int = -214
    var bA: BigInteger = BigInteger.Parse("238768787678287")
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrStringWithExponentWithoutPoint5*() =
    var a: String = "238768787678287E214"
    var aScale: int = -214
    var bA: BigInteger = BigInteger.Parse("238768787678287")
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrStringWithExponentWithPoint1*() =
    var a: String = "23985439837984782435652424523876878.7678287e+214"
    var aScale: int = -207
    var bA: BigInteger = BigInteger.Parse("239854398379847824356524245238768787678287")
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrStringWithExponentWithPoint2*() =
    var a: String = "238096483923847545735673567457356356789029578490276878.7678287e-214"
    var aScale: int = 221
    var bA: BigInteger = BigInteger.Parse("2380964839238475457356735674573563567890295784902768787678287")
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrStringWithExponentWithPoint3*() =
    var a: String = "2380964839238475457356735674573563567890.295784902768787678287E+21"
    var aScale: int = 0
    var bA: BigInteger = BigInteger.Parse("2380964839238475457356735674573563567890295784902768787678287")
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrStringWithExponentWithPoint4*() =
    var a: String = "23809648392384754573567356745735635678.90295784902768787678287E+21"
    var aScale: int = 2
    var bA: BigInteger = BigInteger.Parse("2380964839238475457356735674573563567890295784902768787678287")
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrStringWithExponentWithPoint5*() =
    var a: String = "238096483923847545735673567457356356789029.5784902768787678287E+21"
    var aScale: int = -2
    var bA: BigInteger = BigInteger.Parse("2380964839238475457356735674573563567890295784902768787678287")
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
assertEquals("incorrect value", bA, aNumber.UnscaledValue)
assertEquals("incorrect scale", aScale, aNumber.Scale)
proc testConstrStringMathContext*() =
    var a: String = "-238768787678287e214"
    var precision: int = 5
    var rm: RoundingMode = RoundingMode.Ceiling
    var mc: MathContext = MathContext(precision, rm)
    var res: String = "-23876"
    var resScale: int = -224
    var result: BigDecimal = BigDecimal.Parse(a, mc, CultureInfo.InvariantCulture)
assertEquals("incorrect value", res, result.UnscaledValue.ToString(CultureInfo.InvariantCulture))
assertEquals("incorrect scale", resScale, result.Scale)