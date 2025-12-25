# "Namespace: ICU4N.Numerics.BigMath"
type
  BigDecimalTest = ref object
    value: BigInteger = BigInteger.Parse("12345908")
    value2: BigInteger = BigInteger.Parse("12334560000")

proc test_ConstructorLjava_math_BigInteger*() =
    var big: BigDecimal = BigDecimal(value)
assertTrue("the BigDecimal value is not initialized properly", big.UnscaledValue.Equals(value) && big.Scale == 0)
proc test_ConstructorLjava_math_BigIntegerI*() =
    var big: BigDecimal = BigDecimal(value2, 5)
assertTrue("the BigDecimal value is not initialized properly", big.UnscaledValue.Equals(value2) && big.Scale == 5)
assertTrue("the BigDecimal value is not represented properly", big.ToString.Equals("123345.60000"))
proc test_ConstructorD*() =
    var big: BigDecimal = BigDecimal(1230000.0)
assertTrue("the BigDecimal value taking a double argument is not initialized properly", big.ToString.Equals("1230000"))
    big = BigDecimal(1.2345e-12)
assertTrue("the double representation is not correct", big.ToDouble == 1.2345e-12)
    big = BigDecimal(-12.345)
assertTrue("the double representation is not correct", big.ToDouble == -12.345)
    big = BigDecimal(5.123456789765432e+138)
assertTrue("the double representation is not correct", big.ToDouble == 5.123456789765432e+138 && big.Scale == 0)
    big = BigDecimal(0.1)
assertTrue("the double representation of 0.1 bigDecimal is not correct", big.ToDouble == 0.1)
    big = BigDecimal(0.00345)
assertTrue("the double representation of 0.00345 bigDecimal is not correct", big.ToDouble == 0.00345)
    big = BigDecimal(-0.0)
assertTrue("the double representation of -0.0 bigDecimal is not correct", big.Scale == 0)
proc test_ConstructorLjava_lang_String*() =
    var big: BigDecimal = BigDecimal.Parse("345.23499600293850", CultureInfo.InvariantCulture)
assertTrue("the BigDecimal value is not initialized properly", big.ToString.Equals("345.23499600293850") && big.Scale == 14)
    big = BigDecimal.Parse("-12345", CultureInfo.InvariantCulture)
assertTrue("the BigDecimal value is not initialized properly", big.ToString.Equals("-12345") && big.Scale == 0)
    big = BigDecimal.Parse("123.", CultureInfo.InvariantCulture)
assertTrue("the BigDecimal value is not initialized properly", big.ToString.Equals("123") && big.Scale == 0)
BigDecimal.Parse("1.234E02", CultureInfo.InvariantCulture)
proc test_constructor_String_plus_exp*() =
BigDecimal(+23.0)
BigDecimal(-23.0)
proc test_constructor_String_empty*() =
    try:
BigDecimal.Parse("", CultureInfo.InvariantCulture)
fail("NumberFormatException expected")
    except FormatException:

proc test_constructor_String_plus_minus_exp*() =
    try:
BigDecimal.Parse("+35e+-2", CultureInfo.InvariantCulture)
fail("NumberFormatException expected")
    except FormatException:

    try:
BigDecimal.Parse("-35e-+2", CultureInfo.InvariantCulture)
fail("NumberFormatException expected")
    except FormatException:

proc test_constructor_CC_plus_minus_exp*() =
    try:
BigDecimal.Parse("+35e+-2".ToCharArray, CultureInfo.InvariantCulture)
fail("NumberFormatException expected")
    except FormatException:

    try:
BigDecimal.Parse("-35e-+2".ToCharArray, CultureInfo.InvariantCulture)
fail("NumberFormatException expected")
    except FormatException:

proc test_abs*() =
    var big: BigDecimal = BigDecimal.Parse("-1234", CultureInfo.InvariantCulture)
    var bigabs: BigDecimal = BigDecimal.Abs(big)
assertTrue("the absolute value of -1234 is not 1234", bigabs.ToString.Equals("1234"))
    big = BigDecimal(BigInteger.Parse("2345"), 2)
    bigabs = BigDecimal.Abs(big)
assertTrue("the absolute value of 23.45 is not 23.45", bigabs.ToString.Equals("23.45"))
proc test_addLjava_math_BigDecimal*() =
    var add1: BigDecimal = BigDecimal.Parse("23.456", CultureInfo.InvariantCulture)
    var add2: BigDecimal = BigDecimal.Parse("3849.235", CultureInfo.InvariantCulture)
    var sum: BigDecimal = BigDecimal.Add(add1, add2)
assertTrue("the sum of 23.456 + 3849.235 is wrong", sum.UnscaledValue.ToString.Equals("3872691") && sum.Scale == 3)
assertTrue("the sum of 23.456 + 3849.235 is not printed correctly", sum.ToString.Equals("3872.691"))
    var add3: BigDecimal = BigDecimal(1234.0)
assertTrue("the sum of 23.456 + 12.34E02 is not printed correctly", BigDecimal.Add(add1, add3).ToString.Equals("1257.456"))
proc test_compareToLjava_math_BigDecimal*() =
    var comp1: BigDecimal = BigDecimal.Parse("1.00", CultureInfo.InvariantCulture)
    var comp2: BigDecimal = BigDecimal(1.0)
assertTrue("1.00 and 1.000000 should be equal", comp1.CompareTo(comp2) == 0)
    var comp3: BigDecimal = BigDecimal.Parse("1.02", CultureInfo.InvariantCulture)
assertTrue("1.02 should be bigger than 1.00", comp3.CompareTo(comp1) == 1)
    var comp4: BigDecimal = BigDecimal(0.98)
assertTrue("0.98 should be less than 1.00", comp4.CompareTo(comp1) == -1)
proc test_divideLjava_math_BigDecimalI*() =
    var divd1: BigDecimal = BigDecimal(value, 2)
    var divd2: BigDecimal = BigDecimal.Parse("2.335", CultureInfo.InvariantCulture)
    var divd3: BigDecimal = BigDecimal.Divide(divd1, divd2, RoundingMode.Up)
assertTrue("123459.08/2.335 is not correct", divd3.ToString.Equals("52873.27") && divd3.Scale == divd1.Scale)
assertTrue("the unscaledValue representation of 123459.08/2.335 is not correct", divd3.UnscaledValue.ToString.Equals("5287327"))
    divd2 = BigDecimal(123.4)
    divd3 = BigDecimal.Divide(divd1, divd2, RoundingMode.Down)
assertTrue("123459.08/123.4  is not correct", divd3.ToString.Equals("1000.47") && divd3.Scale == 2)
    divd2 = BigDecimal(0.0)
    try:
BigDecimal.Divide(divd1, divd2, RoundingMode.Down)
fail("divide by zero is not caught")
    except DivideByZeroException:

proc test_divideLjava_math_BigDecimalII*() =
    var divd1: BigDecimal = BigDecimal(value2, 4)
    var divd2: BigDecimal = BigDecimal.Parse("0.0023", CultureInfo.InvariantCulture)
    var divd3: BigDecimal = BigDecimal.Divide(divd1, divd2, 3, RoundingMode.HalfUp)
assertTrue("1233456/0.0023 is not correct", divd3.ToString.Equals("536285217.391") && divd3.Scale == 3)
    divd2 = BigDecimal(13.455)
    divd3 = BigDecimal.Divide(divd1, divd2, 0, RoundingMode.Down)
assertTrue("1233456/13.455 is not correct or does not have the correct scale", divd3.ToString.Equals("91672") && divd3.Scale == 0)
    divd2 = BigDecimal(0.0)
    try:
BigDecimal.Divide(divd1, divd2, 4, RoundingMode.Down)
fail("divide by zero is not caught")
    except DivideByZeroException:

proc test_doubleValue*() =
    var bigDB: BigDecimal = BigDecimal(-1.234e-112)
    bigDB = BigDecimal(5e-324)
assertTrue("the double representation of bigDecimal is not correct", bigDB.ToDouble == 5e-324)
    bigDB = BigDecimal(1.79e+308)
assertTrue("the double representation of bigDecimal is not correct", bigDB.ToDouble == 1.79e+308 && bigDB.Scale == 0)
    bigDB = BigDecimal(-2.33e+102)
assertTrue("the double representation of bigDecimal -2.33E102 is not correct", bigDB.ToDouble == -2.33e+102 && bigDB.Scale == 0)
    bigDB = BigDecimal(double.MaxValue)
    bigDB = bigDB + bigDB
assertTrue("a  + number out of the double range should return infinity", bigDB.ToDouble == double.PositiveInfinity)
    bigDB = BigDecimal(-double.MaxValue)
    bigDB = bigDB + bigDB
assertTrue("a  - number out of the double range should return neg infinity", bigDB.ToDouble == double.NegativeInfinity)
proc test_equalsLjava_lang_Object*() =
    var equal1: BigDecimal = BigDecimal(1.0)
    var equal2: BigDecimal = BigDecimal.Parse("1.0", CultureInfo.InvariantCulture)
assertFalse("1.00 and 1.0 should not be equal", equal1.Equals(equal2))
    equal2 = BigDecimal(1.01)
assertFalse("1.00 and 1.01 should not be equal", equal1.Equals(equal2))
    equal2 = BigDecimal.Parse("1.00", CultureInfo.InvariantCulture)
assertFalse("1.00D and 1.00 should not be equal", equal1.Equals(equal2))
    var val: BigInteger = BigInteger.Parse("100")
    equal1 = BigDecimal.Parse("1.00", CultureInfo.InvariantCulture)
    equal2 = BigDecimal(val, 2)
assertTrue("1.00(string) and 1.00(bigInteger) should be equal", equal1.Equals(equal2))
    equal1 = BigDecimal(100.0)
    equal2 = BigDecimal.Parse("2.34576", CultureInfo.InvariantCulture)
assertFalse("100D and 2.34576 should not be equal", equal1.Equals(equal2))
assertFalse("bigDecimal 100D does not equal string 23415", equal1.Equals("23415"))
proc test_floatValue*() =
    var fl1: BigDecimal = BigDecimal.Parse("234563782344567", CultureInfo.InvariantCulture)
assertTrue("the float representation of bigDecimal 234563782344567", fl1.ToSingle == 234563780000000.0)
    var fl2: BigDecimal = BigDecimal(2.345e+37)
assertTrue("the float representation of bigDecimal 2.345E37", fl2.ToSingle == 2.345e+37)
    fl2 = BigDecimal(-1e-44)
assertTrue("the float representation of bigDecimal -1.00E-44", fl2.ToSingle == -1e-44)
    fl2 = BigDecimal(-3000000000000.0)
assertTrue("the float representation of bigDecimal -3E12", fl2.ToSingle == -3000000000000.0)
    fl2 = BigDecimal(double.MaxValue)
assertTrue("A number can't be represented by float should return infinity", fl2.ToSingle == float.PositiveInfinity)
    fl2 = BigDecimal(-double.MaxValue)
assertTrue("A number can't be represented by float should return infinity", fl2.ToSingle == float.NegativeInfinity)
proc test_hashCode*() =
    var hash: BigDecimal = BigDecimal.Parse("1.00", CultureInfo.InvariantCulture)
    var hash2: BigDecimal = BigDecimal(1.0)
assertTrue("the hashCode of 1.00 and 1.00D is equal", hash.GetHashCode != hash2.GetHashCode && !hash.Equals(hash2))
    hash2 = BigDecimal.Parse("1.0", CultureInfo.InvariantCulture)
assertTrue("the hashCode of 1.0 and 1.00 is equal", hash.GetHashCode != hash2.GetHashCode && !hash.Equals(hash2))
    var val: BigInteger = BigInteger.Parse("100")
    hash2 = BigDecimal(val, 2)
assertTrue("hashCode of 1.00 and 1.00(bigInteger) is not equal", hash.GetHashCode == hash2.GetHashCode && hash.Equals(hash2))
    hash = BigDecimal(value, 2)
    hash2 = BigDecimal.Parse("-1233456.0000", CultureInfo.InvariantCulture)
assertTrue("hashCode of 123459.08 and -1233456.0000 is not equal", hash.GetHashCode != hash2.GetHashCode && !hash.Equals(hash2))
    hash2 = BigDecimal(-value, 2)
assertTrue("hashCode of 123459.08 and -123459.08 is not equal", hash.GetHashCode != hash2.GetHashCode && !hash.Equals(hash2))
proc test_intValue*() =
    var int1: BigDecimal = BigDecimal(value, 3)
assertTrue("the int value of 12345.908 is not 12345", int1.ToInt32 == 12345)
    int1 = BigDecimal.Parse("1.99", CultureInfo.InvariantCulture)
assertTrue("the int value of 1.99 is not 1", int1.ToInt32 == 1)
    int1 = BigDecimal.Parse("23423419083091823091283933", CultureInfo.InvariantCulture)
assertTrue("the int value of 23423419083091823091283933 is wrong", int1.ToInt32 == -249268259)
    int1 = BigDecimal(-1235.0)
assertTrue("the int value of -1235 is not -1235", int1.ToInt32 == -1235)
proc test_longValue*() =
    var long1: BigDecimal = BigDecimal(-value2, 0)
assertTrue("the long value of 12334560000 is not 12334560000", long1.ToInt64 == -12334560000)
    long1 = BigDecimal(-1.345348e-120)
assertTrue("the long value of -1345.348E-123D is not zero", long1.ToInt64 == 0)
    long1 = BigDecimal.Parse("31323423423419083091823091283933", CultureInfo.InvariantCulture)
assertTrue("the long value of 31323423423419083091823091283933 is wrong", long1.ToInt64 == -5251313250005125155)
proc test_maxLjava_math_BigDecimal*() =
    var max1: BigDecimal = BigDecimal(value2, 1)
    var max2: BigDecimal = BigDecimal(value2, 4)
assertTrue("1233456000.0 is not greater than 1233456", BigDecimal.Max(max1, max2).Equals(max1))
    max1 = BigDecimal(-1.224)
    max2 = BigDecimal(-1.2245)
assertTrue("-1.224 is not greater than -1.2245", BigDecimal.Max(max1, max2).Equals(max1))
    max1 = BigDecimal(1.23e+20)
    max2 = BigDecimal(1.23e+21)
assertTrue("123E19 is the not the max", BigDecimal.Max(max1, max2).Equals(max2))
proc test_minLjava_math_BigDecimal*() =
    var min1: BigDecimal = BigDecimal(-12345.4)
    var min2: BigDecimal = BigDecimal(-12345.39)
assertTrue("-12345.39 should have been returned", BigDecimal.Min(min1, min2).Equals(min1))
    min1 = BigDecimal(value2, 5)
    min2 = BigDecimal(value2, 0)
assertTrue("123345.6 should have been returned", BigDecimal.Min(min1, min2).Equals(min1))
proc test_movePointLeftI*() =
    var movePtLeft: BigDecimal = BigDecimal.Parse("123456265.34", CultureInfo.InvariantCulture)
    var alreadyMoved: BigDecimal = BigDecimal.MovePointLeft(movePtLeft, 5)
assertTrue("move point left 5 failed", alreadyMoved.Scale == 7 && alreadyMoved.ToString.Equals("1234.5626534"))
    movePtLeft = BigDecimal(-value2, 0)
    alreadyMoved = BigDecimal.MovePointLeft(movePtLeft, 12)
assertTrue("move point left 12 failed", alreadyMoved.Scale == 12 && alreadyMoved.ToString.Equals("-0.012334560000"))
    movePtLeft = BigDecimal(1.23e+20)
    alreadyMoved = BigDecimal.MovePointLeft(movePtLeft, 2)
assertTrue("move point left 2 failed", alreadyMoved.Scale == movePtLeft.Scale + 2 && alreadyMoved.ToDouble == 1.23e+18)
    movePtLeft = BigDecimal(1.123e-12)
    alreadyMoved = BigDecimal.MovePointLeft(movePtLeft, 3)
assertTrue("move point left 3 failed", alreadyMoved.Scale == movePtLeft.Scale + 3 && alreadyMoved.ToDouble == 1.123e-15)
    movePtLeft = BigDecimal(value, 2)
    alreadyMoved = BigDecimal.MovePointLeft(movePtLeft, -2)
assertTrue("move point left -2 failed", alreadyMoved.Scale == movePtLeft.Scale - 2 && alreadyMoved.ToString.Equals("12345908"))
proc test_movePointRightI*() =
    var movePtRight: BigDecimal = BigDecimal.Parse("-1.58796521458", CultureInfo.InvariantCulture)
    var alreadyMoved: BigDecimal = BigDecimal.MovePointRight(movePtRight, 8)
assertTrue("move point right 8 failed", alreadyMoved.Scale == 3 && alreadyMoved.ToString.Equals("-158796521.458"))
    movePtRight = BigDecimal(value, 2)
    alreadyMoved = BigDecimal.MovePointRight(movePtRight, 4)
assertTrue("move point right 4 failed", alreadyMoved.Scale == 0 && alreadyMoved.ToString.Equals("1234590800"))
    movePtRight = BigDecimal(134000000000000.0)
    alreadyMoved = BigDecimal.MovePointRight(movePtRight, 2)
assertTrue("move point right 2 failed", alreadyMoved.Scale == 0 && alreadyMoved.ToString.Equals("13400000000000000"))
    movePtRight = BigDecimal(-3.4e-10)
    alreadyMoved = BigDecimal.MovePointRight(movePtRight, 5)
assertTrue("move point right 5 failed", alreadyMoved.Scale == movePtRight.Scale - 5 && alreadyMoved.ToDouble == -0.000034)
    alreadyMoved = BigDecimal.MovePointRight(alreadyMoved, -5)
assertTrue("move point right -5 failed", alreadyMoved.Equals(movePtRight))
proc test_multiplyLjava_math_BigDecimal*() =
    var multi1: BigDecimal = BigDecimal(value, 5)
    var multi2: BigDecimal = BigDecimal(2.345)
    var result: BigDecimal = multi1 * multi2
assertTrue("123.45908 * 2.345 is not correct: " + result, result.ToString.StartsWith("289.51154260", StringComparison.Ordinal) && result.Scale == multi1.Scale + multi2.Scale)
    multi1 = BigDecimal.Parse("34656", CultureInfo.InvariantCulture)
    multi2 = BigDecimal.Parse("-2", CultureInfo.InvariantCulture)
    result = multi1 * multi2
assertTrue("34656 * 2 is not correct", result.ToString.Equals("-69312") && result.Scale == 0)
    multi1 = BigDecimal(-0.02345)
    multi2 = BigDecimal(-1.34e+132)
    result = multi1 * multi2
assertTrue("-2.345E-02 * -134E130 is not correct " + result.ToDouble, result.ToDouble == 3.1422999999999997e+130 && result.Scale == multi1.Scale + multi2.Scale)
    multi1 = BigDecimal.Parse("11235", CultureInfo.InvariantCulture)
    multi2 = BigDecimal.Parse("0", CultureInfo.InvariantCulture)
    result = multi1 * multi2
assertTrue("11235 * 0 is not correct", result.ToDouble == 0 && result.Scale == 0)
    multi1 = BigDecimal.Parse("-0.00234", CultureInfo.InvariantCulture)
    multi2 = BigDecimal(134000000000.0)
    result = multi1 * multi2
assertTrue("-0.00234 * 13.4E10 is not correct", result.ToDouble == -313560000 && result.Scale == multi1.Scale + multi2.Scale)
proc test_negate*() =
    var negate1: BigDecimal = BigDecimal(value2, 7)
assertTrue("the negate of 1233.4560000 is not -1233.4560000", -negate1.ToString.Equals("-1233.4560000"))
    negate1 = BigDecimal.Parse("-23465839", CultureInfo.InvariantCulture)
assertTrue("the negate of -23465839 is not 23465839", -negate1.ToString.Equals("23465839"))
    negate1 = BigDecimal(-3456000.0)
assertTrue("the negate of -3.456E6 is not 3.456E6", --negate1.Equals(negate1))
proc test_scale*() =
    var scale1: BigDecimal = BigDecimal(value2, 8)
assertTrue("the scale of the number 123.34560000 is wrong", scale1.Scale == 8)
    var scale2: BigDecimal = BigDecimal.Parse("29389.", CultureInfo.InvariantCulture)
assertTrue("the scale of the number 29389. is wrong", scale2.Scale == 0)
    var scale3: BigDecimal = BigDecimal(33740000000000.0)
assertTrue("the scale of the number 3.374E13 is wrong", scale3.Scale == 0)
    var scale4: BigDecimal = BigDecimal.Parse("-3.45E-203", CultureInfo.InvariantCulture)
assertTrue("the scale of the number -3.45E-203 is wrong: " + scale4.Scale, scale4.Scale == 205)
    scale4 = BigDecimal.Parse("-345.4E-200", CultureInfo.InvariantCulture)
assertTrue("the scale of the number -345.4E-200 is wrong", scale4.Scale == 201)
proc test_setScaleI*() =
    var setScale1: BigDecimal = BigDecimal(value, 3)
    var setScale2: BigDecimal = BigDecimal.SetScale(setScale1, 5)
    var setresult: BigInteger = BigInteger.Parse("1234590800")
assertTrue("the number 12345.908 after setting scale is wrong", setScale2.UnscaledValue.Equals(setresult) && setScale2.Scale == 5)
    try:
        setScale2 = BigDecimal.SetScale(setScale1, 2, RoundingMode.Unnecessary)
fail("arithmetic Exception not caught as a result of loosing precision")
    except ArithmeticException:

proc test_setScaleII*() =
    var setScale1: BigDecimal = BigDecimal(2.323e+102)
    var setScale2: BigDecimal = BigDecimal.SetScale(setScale1, 4)
assertTrue("the number 2.323E102 after setting scale is wrong", setScale2.Scale == 4)
assertTrue("the representation of the number 2.323E102 is wrong", setScale2.ToDouble == 2.323e+102)
    setScale1 = BigDecimal.Parse("-1.253E-12", CultureInfo.InvariantCulture)
    setScale2 = BigDecimal.SetScale(setScale1, 17, RoundingMode.Ceiling)
assertTrue("the number -1.253E-12 after setting scale is wrong", setScale2.Scale == 17)
assertTrue("the representation of the number -1.253E-12 after setting scale is wrong, " + setScale2.ToString, setScale2.ToString.Equals("-1.25300E-12"))
    setScale1 = BigDecimal(value, 4)
    setScale2 = BigDecimal.SetScale(setScale1, 1, RoundingMode.Ceiling)
assertTrue("the number 1234.5908 after setting scale to 1/ROUND_CEILING is wrong", setScale2.ToString.Equals("1234.6") && setScale2.Scale == 1)
    var setNeg: BigDecimal = BigDecimal(-value, 4)
    setScale2 = BigDecimal.SetScale(setNeg, 1, RoundingMode.Ceiling)
assertTrue("the number -1234.5908 after setting scale to 1/ROUND_CEILING is wrong", setScale2.ToString.Equals("-1234.5") && setScale2.Scale == 1)
    setScale2 = BigDecimal.SetScale(setNeg, 1, RoundingMode.Down)
assertTrue("the number -1234.5908 after setting scale to 1/ROUND_DOWN is wrong", setScale2.ToString.Equals("-1234.5") && setScale2.Scale == 1)
    setScale1 = BigDecimal(value, 4)
    setScale2 = BigDecimal.SetScale(setScale1, 1, RoundingMode.Down)
assertTrue("the number 1234.5908 after setting scale to 1/ROUND_DOWN is wrong", setScale2.ToString.Equals("1234.5") && setScale2.Scale == 1)
    setScale2 = BigDecimal.SetScale(setScale1, 1, RoundingMode.Floor)
assertTrue("the number 1234.5908 after setting scale to 1/ROUND_FLOOR is wrong", setScale2.ToString.Equals("1234.5") && setScale2.Scale == 1)
    setScale2 = BigDecimal.SetScale(setNeg, 1, RoundingMode.Floor)
assertTrue("the number -1234.5908 after setting scale to 1/ROUND_FLOOR is wrong", setScale2.ToString.Equals("-1234.6") && setScale2.Scale == 1)
    setScale2 = BigDecimal.SetScale(setScale1, 3, RoundingMode.HalfDown)
assertTrue("the number 1234.5908 after setting scale to 3/ROUND_HALF_DOWN is wrong", setScale2.ToString.Equals("1234.591") && setScale2.Scale == 3)
    setScale1 = BigDecimal(BigInteger.Parse("12345000"), 5)
    setScale2 = BigDecimal.SetScale(setScale1, 1, RoundingMode.HalfDown)
assertTrue("the number 123.45908 after setting scale to 1/ROUND_HALF_DOWN is wrong", setScale2.ToString.Equals("123.4") && setScale2.Scale == 1)
    setScale2 = BigDecimal.SetScale(BigDecimal.Parse("-1234.5000", CultureInfo.InvariantCulture), 0, RoundingMode.HalfDown)
assertTrue("the number -1234.5908 after setting scale to 0/ROUND_HALF_DOWN is wrong", setScale2.ToString.Equals("-1234") && setScale2.Scale == 0)
    setScale1 = BigDecimal(1.2345789)
    setScale2 = BigDecimal.SetScale(setScale1, 4, RoundingMode.HalfEven)
assertTrue("the number 1.2345789 after setting scale to 4/ROUND_HALF_EVEN is wrong", setScale2.ToDouble == 1.2346 && setScale2.Scale == 4)
    setNeg = BigDecimal(-1.2335789)
    setScale2 = BigDecimal.SetScale(setNeg, 2, RoundingMode.HalfEven)
assertTrue("the number -1.2335789 after setting scale to 2/ROUND_HALF_EVEN is wrong", setScale2.ToDouble == -1.23 && setScale2.Scale == 2)
    setScale2 = BigDecimal.SetScale(BigDecimal.Parse("1.2345000", CultureInfo.InvariantCulture), 3, RoundingMode.HalfEven)
assertTrue("the number 1.2345789 after setting scale to 3/ROUND_HALF_EVEN is wrong", setScale2.ToDouble == 1.234 && setScale2.Scale == 3)
    setScale2 = BigDecimal.SetScale(BigDecimal.Parse("-1.2345000", CultureInfo.InvariantCulture), 3, RoundingMode.HalfEven)
assertTrue("the number -1.2335789 after setting scale to 3/ROUND_HALF_EVEN is wrong", setScale2.ToDouble == -1.234 && setScale2.Scale == 3)
    setScale1 = BigDecimal.Parse("134567.34650", CultureInfo.InvariantCulture)
    setScale2 = BigDecimal.SetScale(setScale1, 3, RoundingMode.HalfUp)
assertTrue("the number 134567.34658 after setting scale to 3/ROUND_HALF_UP is wrong", setScale2.ToString.Equals("134567.347") && setScale2.Scale == 3)
    setNeg = BigDecimal.Parse("-1234.4567", CultureInfo.InvariantCulture)
    setScale2 = BigDecimal.SetScale(setNeg, 0, RoundingMode.HalfUp)
assertTrue("the number -1234.4567 after setting scale to 0/ROUND_HALF_UP is wrong", setScale2.ToString.Equals("-1234") && setScale2.Scale == 0)
    try:
BigDecimal.SetScale(setScale1, 3, RoundingMode.Unnecessary)
fail("arithmetic Exception not caught for round unnecessary")
    except ArithmeticException:

    setScale1 = BigDecimal.Parse("100000.374", CultureInfo.InvariantCulture)
    setScale2 = BigDecimal.SetScale(setScale1, 2, RoundingMode.Up)
assertTrue("the number 100000.374 after setting scale to 2/ROUND_UP is wrong", setScale2.ToString.Equals("100000.38") && setScale2.Scale == 2)
    setNeg = BigDecimal(-134.34589)
    setScale2 = BigDecimal.SetScale(setNeg, 2, RoundingMode.Up)
assertTrue("the number -134.34589 after setting scale to 2/ROUND_UP is wrong", setScale2.ToDouble == -134.35 && setScale2.Scale == 2)
    try:
        setScale2 = BigDecimal.SetScale(setScale1, 0, cast[RoundingMode](-123))
fail("IllegalArgumentException is not caught for wrong rounding mode")
    except ArgumentException:

proc test_signum*() =
    var sign: BigDecimal = BigDecimal(1.23e-102)
assertTrue("123E-104 is not positive in signum()", sign.Sign == 1)
    sign = BigDecimal.Parse("-1234.3959", CultureInfo.InvariantCulture)
assertTrue("-1234.3959 is not negative in signum()", sign.Sign == -1)
    sign = BigDecimal(0.0)
assertTrue("000D is not zero in signum()", sign.Sign == 0)
proc test_subtractLjava_math_BigDecimal*() =
    var sub1: BigDecimal = BigDecimal.Parse("13948", CultureInfo.InvariantCulture)
    var sub2: BigDecimal = BigDecimal.Parse("2839.489", CultureInfo.InvariantCulture)
    var result: BigDecimal = sub1 - sub2
assertTrue("13948 - 2839.489 is wrong: " + result, result.ToString.Equals("11108.511") && result.Scale == 3)
    var result2: BigDecimal = sub2 - sub1
assertTrue("2839.489 - 13948 is wrong", result2.ToString.Equals("-11108.511") && result2.Scale == 3)
assertTrue("13948 - 2839.489 is not the negative of 2839.489 - 13948", result.Equals(-result2))
    sub1 = BigDecimal(value, 1)
    sub2 = BigDecimal.Parse("0", CultureInfo.InvariantCulture)
    result = sub1 - sub2
assertTrue("1234590.8 - 0 is wrong", result.Equals(sub1))
    sub1 = BigDecimal(0.001234)
    sub2 = BigDecimal(3.423e-10)
    result = sub1 - sub2
assertTrue("1.234E-03 - 3.423E-10 is wrong, " + result.ToDouble, result.ToDouble == 0.0012339996577)
    sub1 = BigDecimal(1234.0123)
    sub2 = BigDecimal(1234.0123)
    result = sub1 - sub2
assertTrue("1234.0123 - 1234.0123000 is wrong, " + result.ToDouble, result.ToDouble == 0.0)
proc test_toBigInteger*() =
    var sub1: BigDecimal = BigDecimal.Parse("-29830.989", CultureInfo.InvariantCulture)
    var result: BigInteger = sub1.ToBigInteger
assertTrue("the bigInteger equivalent of -29830.989 is wrong", result.ToString.Equals("-29830"))
    sub1 = BigDecimal(-28370000000000.0)
    result = sub1.ToBigInteger
assertTrue("the bigInteger equivalent of -2837E10 is wrong", result.ToDouble == -28370000000000.0)
    sub1 = BigDecimal(2.349e-10)
    result = sub1.ToBigInteger
assertTrue("the bigInteger equivalent of 2.349E-10 is wrong", result.Equals(BigInteger.Zero))
    sub1 = BigDecimal(value2, 6)
    result = sub1.ToBigInteger
assertTrue("the bigInteger equivalent of 12334.560000 is wrong", result.ToString.Equals("12334"))
proc test_toString*() =
    var toString1: BigDecimal = BigDecimal.Parse("1234.000", CultureInfo.InvariantCulture)
assertTrue("the toString representation of 1234.000 is wrong", toString1.ToString.Equals("1234.000"))
    toString1 = BigDecimal.Parse("-123.4E-5", CultureInfo.InvariantCulture)
assertTrue("the toString representation of -123.4E-5 is wrong: " + toString1, toString1.ToString.Equals("-0.001234"))
    toString1 = BigDecimal.Parse("-1.455E-20", CultureInfo.InvariantCulture)
assertTrue("the toString representation of -1.455E-20 is wrong", toString1.ToString.Equals("-1.455E-20"))
    toString1 = BigDecimal(value2, 4)
assertTrue("the toString representation of 1233456.0000 is wrong", toString1.ToString.Equals("1233456.0000"))
proc test_unscaledValue*() =
    var unsVal: BigDecimal = BigDecimal.Parse("-2839485.000", CultureInfo.InvariantCulture)
assertTrue("the unscaledValue of -2839485.000 is wrong", unsVal.UnscaledValue.ToString.Equals("-2839485000"))
    unsVal = BigDecimal(1230000000000.0)
assertTrue("the unscaledValue of 123E10 is wrong", unsVal.UnscaledValue.ToString.Equals("1230000000000"))
    unsVal = BigDecimal.Parse("-4.56E-13", CultureInfo.InvariantCulture)
assertTrue("the unscaledValue of -4.56E-13 is wrong: " + unsVal.UnscaledValue, unsVal.UnscaledValue.ToString.Equals("-456"))
    unsVal = BigDecimal(value, 3)
assertTrue("the unscaledValue of 12345.908 is wrong", unsVal.UnscaledValue.ToString.Equals("12345908"))
proc test_valueOfJ*() =
    var valueOfL: BigDecimal = BigDecimal.GetInstance(9223372036854775806)
assertTrue("the bigDecimal equivalent of 9223372036854775806 is wrong", valueOfL.UnscaledValue.ToString.Equals("9223372036854775806") && valueOfL.Scale == 0)
assertTrue("the toString representation of 9223372036854775806 is wrong", valueOfL.ToString.Equals("9223372036854775806"))
    valueOfL = BigDecimal.GetInstance(0)
assertTrue("the bigDecimal equivalent of 0 is wrong", valueOfL.UnscaledValue.ToString.Equals("0") && valueOfL.Scale == 0)
proc test_valueOfJI*() =
    var valueOfJI: BigDecimal = BigDecimal.GetInstance(9223372036854775806, 5)
assertTrue("the bigDecimal equivalent of 92233720368547.75806 is wrong", valueOfJI.UnscaledValue.ToString.Equals("9223372036854775806") && valueOfJI.Scale == 5)
assertTrue("the toString representation of 9223372036854775806 is wrong", valueOfJI.ToString.Equals("92233720368547.75806"))
    valueOfJI = BigDecimal.GetInstance(1234, 8)
assertTrue("the bigDecimal equivalent of 92233720368547.75806 is wrong", valueOfJI.UnscaledValue.ToString.Equals("1234") && valueOfJI.Scale == 8)
assertTrue("the toString representation of 9223372036854775806 is wrong", valueOfJI.ToString.Equals("0.00001234"))
    valueOfJI = BigDecimal.GetInstance(0, 3)
assertTrue("the bigDecimal equivalent of 92233720368547.75806 is wrong", valueOfJI.UnscaledValue.ToString.Equals("0") && valueOfJI.Scale == 3)
assertTrue("the toString representation of 9223372036854775806 is wrong", valueOfJI.ToString.Equals("0.000"))
proc test_stripTrailingZero*() =
    var sixhundredtest: BigDecimal = BigDecimal.Parse("600.0", CultureInfo.InvariantCulture)
assertTrue("stripTrailingZero failed for 600.0", BigDecimal.StripTrailingZeros(sixhundredtest).Scale == -2)
    var notrailingzerotest: BigDecimal = BigDecimal.Parse("1", CultureInfo.InvariantCulture)
assertTrue("stripTrailingZero failed for 1", BigDecimal.StripTrailingZeros(notrailingzerotest).Scale == 0)
    var zerotest: BigDecimal = BigDecimal.Parse("0.0000", CultureInfo.InvariantCulture)
assertTrue("stripTrailingZero failed for 0.0000", BigDecimal.StripTrailingZeros(zerotest).Scale == 0)
proc testMathContextConstruction*() =
    var a: String = "-12380945E+61"
    var aNumber: BigDecimal = BigDecimal.Parse(a, CultureInfo.InvariantCulture)
    var precision: int = 6
    var rm: RoundingMode = RoundingMode.HalfDown
    var mcIntRm: MathContext = MathContext(precision, rm)
    var mcStr: MathContext = MathContext.Parse("precision=6 roundingMode=HalfDown")
    var mcInt: MathContext = MathContext(precision)
    var res: BigDecimal = BigDecimal.Abs(aNumber, mcInt)
assertEquals("MathContext Constructer with int precision failed", res, BigDecimal.Parse("1.23809E+68", CultureInfo.InvariantCulture))
assertEquals("Equal MathContexts are not Equal ", mcIntRm, mcStr)
assertEquals("Different MathContext are reported as Equal ", mcInt.Equals(mcStr), false)
assertEquals("Equal MathContexts have different hashcodes ", mcIntRm.GetHashCode, mcStr.GetHashCode)
assertEquals("MathContext.toString() returning incorrect value", mcIntRm.ToString, "precision=6 roundingMode=HalfDown")