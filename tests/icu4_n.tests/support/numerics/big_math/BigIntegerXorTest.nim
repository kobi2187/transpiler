# "Namespace: ICU4N.Numerics.BigMath"
type
  BigIntegerXorTest = ref object


proc testZeroPos*() =
    var numA: String = "0"
    var numB: String = "27384627835298756289327365"
    var res: String = "27384627835298756289327365"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testZeroNeg*() =
    var numA: String = "0"
    var numB: String = "-27384627835298756289327365"
    var res: String = "-27384627835298756289327365"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testPosZero*() =
    var numA: String = "27384627835298756289327365"
    var numB: String = "0"
    var res: String = "27384627835298756289327365"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testNegPos*() =
    var numA: String = "-27384627835298756289327365"
    var numB: String = "0"
    var res: String = "-27384627835298756289327365"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testZeroZero*() =
    var numA: String = "0"
    var numB: String = "0"
    var res: String = "0"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testZeroOne*() =
    var numA: String = "0"
    var numB: String = "1"
    var res: String = "1"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testOneOne*() =
    var numA: String = "1"
    var numB: String = "1"
    var res: String = "0"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testPosPosSameLength*() =
    var numA: String = "283746278342837476784564875684767"
    var numB: String = "293478573489347658763745839457637"
    var res: String = "71412358434940908477702819237626"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testPosPosFirstLonger*() =
    var numA: String = "2837462783428374767845648748973847593874837948575684767"
    var numB: String = "293478573489347658763745839457637"
    var res: String = "2837462783428374767845615168483972194300564226167553530"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testPosPosFirstShorter*() =
    var numA: String = "293478573489347658763745839457637"
    var numB: String = "2837462783428374767845648748973847593874837948575684767"
    var res: String = "2837462783428374767845615168483972194300564226167553530"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testNegNegSameLength*() =
    var numA: String = "-283746278342837476784564875684767"
    var numB: String = "-293478573489347658763745839457637"
    var res: String = "71412358434940908477702819237626"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testNegNegFirstLonger*() =
    var numA: String = "-2837462783428374767845648748973847593874837948575684767"
    var numB: String = "-293478573489347658763745839457637"
    var res: String = "2837462783428374767845615168483972194300564226167553530"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testNegNegFirstShorter*() =
    var numA: String = "293478573489347658763745839457637"
    var numB: String = "2837462783428374767845648748973847593874837948575684767"
    var res: String = "2837462783428374767845615168483972194300564226167553530"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testPosNegSameLength*() =
    var numA: String = "283746278342837476784564875684767"
    var numB: String = "-293478573489347658763745839457637"
    var res: String = "-71412358434940908477702819237628"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testNegPosSameLength*() =
    var numA: String = "-283746278342837476784564875684767"
    var numB: String = "293478573489347658763745839457637"
    var res: String = "-71412358434940908477702819237628"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testNegPosFirstLonger*() =
    var numA: String = "-2837462783428374767845648748973847593874837948575684767"
    var numB: String = "293478573489347658763745839457637"
    var res: String = "-2837462783428374767845615168483972194300564226167553532"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testNegPosFirstShorter*() =
    var numA: String = "-293478573489347658763745839457637"
    var numB: String = "2837462783428374767845648748973847593874837948575684767"
    var res: String = "-2837462783428374767845615168483972194300564226167553532"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testPosNegFirstLonger*() =
    var numA: String = "2837462783428374767845648748973847593874837948575684767"
    var numB: String = "-293478573489347658763745839457637"
    var res: String = "-2837462783428374767845615168483972194300564226167553532"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))
proc testPosNegFirstShorter*() =
    var numA: String = "293478573489347658763745839457637"
    var numB: String = "-2837462783428374767845648748973847593874837948575684767"
    var res: String = "-2837462783428374767845615168483972194300564226167553532"
    var aNumber: BigInteger = BigInteger.Parse(numA)
    var bNumber: BigInteger = BigInteger.Parse(numB)
    var result: BigInteger = aNumber ^ bNumber
assertTrue("invalid result", res.Equals(result.ToString(CultureInfo.InvariantCulture)))