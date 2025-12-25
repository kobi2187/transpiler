# "Namespace: ICU4N.Dev.Test.Format"
type
  NumberFormatRoundTripTest = ref object
    MAX_ERROR: double = 1e-14
    max_numeric_error: double = 0.0
    min_numeric_error: double = 1.0
    verbose: bool = false
    STRING_COMPARE: bool = false
    EXACT_NUMERIC_COMPARE: bool = false
    DEBUG: bool = false
    quick: bool = true
    random: Random

proc TestNumberFormatRoundTrip*() =
    var fmt: NumberFormat = nil
Logln("Default Locale")
Logln("Default Number format")
    fmt = NumberFormat.GetInstance
_test(fmt)
Logln("Currency Format")
    fmt = NumberFormat.GetCurrencyInstance
_test(fmt)
Logln("Percent Format")
    fmt = NumberFormat.GetPercentInstance
_test(fmt)
    var locCount: int = 0
    var loc: CultureInfo[] = NumberFormat.GetCultures(Globalization.UCultureTypes.AllCultures)
    if quick:
        if locCount > 5:
          locCount = 5
Logln("Quick mode: only _testing first 5 Locales")
      var i: int = 0
      while i < locCount:
Logln(loc[i].DisplayName)
          fmt = NumberFormat.GetInstance(loc[i])
_test(fmt)
          fmt = NumberFormat.GetCurrencyInstance(loc[i])
_test(fmt)
          fmt = NumberFormat.GetPercentInstance(loc[i])
_test(fmt)
++i
Logln("Numeric error " + min_numeric_error + " to " + max_numeric_error)
proc randomDouble*(range: double): double =
    if random == nil:
        random = CreateRandom
    return random.NextDouble * range
proc _test(fmt: NumberFormat) =
_test(fmt, double.NaN)
_test(fmt, double.PositiveInfinity)
_test(fmt, double.NegativeInfinity)
_test(fmt, 500)
_test(fmt, 0)
_test(fmt, -0)
_test(fmt, 0.0)
    var negZero: double = 0.0
    negZero = -1.0
_test(fmt, negZero)
_test(fmt, 9.223372036854776e+18)
_test(fmt, -9.223372036854776e+18)
      var i: int = 0
      while i < 10:
_test(fmt, randomDouble(1))
_test(fmt, randomDouble(10000))
_test(fmt, Math.Floor(randomDouble(10000)))
_test(fmt, randomDouble(1e+50))
_test(fmt, randomDouble(1e-50))
_test(fmt, randomDouble(1e+100))
_test(fmt, randomDouble(1e+75))
_test(fmt, randomDouble(1e+308) / cast[DecimalFormat](fmt).Multiplier)
_test(fmt, randomDouble(1e+75) / cast[DecimalFormat](fmt).Multiplier)
_test(fmt, randomDouble(1e+65) / cast[DecimalFormat](fmt).Multiplier)
_test(fmt, randomDouble(1e-292))
_test(fmt, randomDouble(1e-78))
_test(fmt, randomDouble(1e-323))
_test(fmt, randomDouble(1e-100))
_test(fmt, randomDouble(1e-78))
++i
proc _test(fmt: NumberFormat, value: double) =
_test(fmt, cast[Number](Double.GetInstance(value)))
proc _test(fmt: NumberFormat, value: long) =
_test(fmt, cast[Number](Long.GetInstance(value)))
proc _test(fmt: NumberFormat, value: Number) =
Logln("test data = " + value)
    fmt.MaximumFractionDigits = 999
      var s: String
      var s2: String
    if value.GetType.FullName.Equals("J2N.Numerics.Double", StringComparison.OrdinalIgnoreCase):
      s = fmt.Format(value.ToDouble)
    else:
      s = fmt.Format(value.ToInt64)
    var n: Number = Double.GetInstance(0)
    var show: bool = verbose
    if DEBUG:
Logln(" F> " + s)
    try:
        n = fmt.Parse(s)
    except FormatException:
Console.Out.WriteLine(e)
    if DEBUG:
Logln(s + " P> ")
    if value.GetType.FullName.Equals("J2N.Numerics.Double", StringComparison.OrdinalIgnoreCase):
      s2 = fmt.Format(n.ToDouble)
    else:
      s2 = fmt.Format(n.ToInt64)
    if DEBUG:
Logln(" F> " + s2)
    if STRING_COMPARE:
        if !s.Equals(s2):
Errln("*** STRING ERROR "" + s + "" != "" + s2 + """)
            show = true
    if EXACT_NUMERIC_COMPARE:
        if value != n:
Errln("*** NUMERIC ERROR")
            show = true
    else:
        var error: double = proportionalError(value, n)
        if error > MAX_ERROR:
Errln("*** NUMERIC ERROR " + error)
            show = true
        if error > max_numeric_error:
          max_numeric_error = error
        if error < min_numeric_error:
          min_numeric_error = error
    if show:
Logln(value.GetType.FullName + " F> " + s + " P> " + n.GetType.FullName + " F> " + s2)
proc proportionalError(a: Number, b: Number): double =
      var aa: double
      var bb: double
    if a.GetType.FullName.Equals("J2N.Numerics.Double", StringComparison.OrdinalIgnoreCase):
      aa = a.ToDouble
    else:
      aa = a.ToInt64
    if a.GetType.FullName.Equals("J2N.Numerics.Double", StringComparison.OrdinalIgnoreCase):
      bb = b.ToDouble
    else:
      bb = b.ToInt64
    var error: double = aa - bb
    if aa != 0 && bb != 0:
      error = aa
    return Math.Abs(error)