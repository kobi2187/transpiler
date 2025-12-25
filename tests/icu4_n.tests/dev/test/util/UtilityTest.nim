# "Namespace: ICU4N.Dev.Test.Util"
type
  UtilityTest = ref object


proc TestUnescape*() =
    var input: string = "Sch\u00f6nes Auto: \u20ac 11240.\fPrivates Zeichen: \U00102345\e\cC\n \x1b\x{263a}"
    var expect: string = "Schönes Auto: € 11240.Privates Zeichen: 􂍅
 ☺"
    var result: string = Utility.Unescape(input)
    if !result.Equals(expect):
Errln("FAIL: Utility.unescape() returned " + result + ", exp. " + expect)
proc TestFormat*() =
    var data: string[] = @["the quick brown fox jumps over the lazy dog", "testing space , quotations "", "testing weird supplementary characters 𐀀", "testing control characters  and line breaking!! 
 are we done yet?"]
    var result: string[] = @["        "the quick brown fox jumps over the lazy dog"", "        "testing space , quotations \042"", "        "testing weird supplementary characters \uD800\uDC00"", "        "testing control characters \001 and line breaking!! \n are we done ye"+" + Utility.LINE_SEPARATOR + "        "t?""]
    var result1: string[] = @[""the quick brown fox jumps over the lazy dog"", ""testing space , quotations \042"", ""testing weird supplementary characters \uD800\uDC00"", ""testing control characters \001 and line breaking!! \n are we done yet?""]
      var i: int = 0
      while i < data.Length:
assertEquals("formatForSource("" + data[i] + "")", result[i], Utility.FormatForSource(data[i]))
++i
      var i: int = 0
      while i < data.Length:
assertEquals("format1ForSource("" + data[i] + "")", result1[i], Utility.Format1ForSource(data[i]))
++i
proc TestHighBit*() =
    var data: int[] = @[-1, -1276, 0, 65535, 4660]
    var result: sbyte[] = @[-1, -1, -1, 15, 12]
      var i: int = 0
      while i < data.Length:
          if Utility.HighBit(data[i]) != result[i]:
Errln("Fail: Highest bit of \u" + data[i].ToHexString + " should be " + result[i])
++i
proc TestCompareUnsigned*() =
    var data: int[] = @[0, 1, cast[int](2415919103), -1, int.MaxValue, int.MinValue, 2342423, -2342423]
      var i: int = 0
      while i < data.Length:
            var j: int = 0
            while j < data.Length:
                if Utility.CompareUnsigned(data[i], data[j]) != compareLongUnsigned(data[i], data[j]):
Errln("Fail: Unsigned comparison failed with " + data[i] + " " + data[i + 1])
++j
++i
proc TestByteArrayWrapper*() =
    var ba: byte[] = @[0, 1, 2]
    var bb: sbyte[] = @[0, 1, 2, -1]
    var buffer: ByteBuffer = ByteBuffer.Wrap(ba)
    var x: ByteArrayWrapper = ByteArrayWrapper(buffer)
    var y: ByteArrayWrapper = ByteArrayWrapper(ba, 3)
    var z: ByteArrayWrapper = ByteArrayWrapper(cast[byte[]](cast[Array](bb)), 3)
    if !y.ToString.Equals("00 01 02"):
Errln("FAIL: test toString : Failed!")
    if !x.Equals(y) || !x.Equals(z):
Errln("FAIL: test (operator ==): Failed!")
    if x.GetHashCode != y.GetHashCode:
Errln("FAIL: identical objects have different hash codes.")
    y = ByteArrayWrapper(cast[byte[]](cast[Array](bb)), 4)
    if x.Equals(y):
Errln("FAIL: test (operator !=): Failed!")
    if x.CompareTo(y) > 0 != y.CompareTo(x) < 0:
Errln("FAIL: comparisons not opposite sign")
proc compareLongUnsigned(x: int, y: int): int =
    var x1: long = x & 4294967295
    var y1: long = y & 4294967295
    if x1 < y1:
        return -1

    elif x1 > y1:
        return 1
    return 0
proc TestUnicodeSet*() =
    var array: string[] = @["a", "b", "c", "{de}"]
    var list: List<string> = array.ToList
    var aset: ISet<string> = HashSet<string>(list)
Logln(" *** The source set's size is: " + aset.Count)
    var set: UnicodeSet = UnicodeSet
set.Clear
set.AddAll(aset)
Logln(" *** After addAll, the UnicodeSet size is: " + set.Count)
proc TestAssert*() =
    try:
ICU4N.Impl.Assert.Assrt(false)
Errln("FAIL: Assert.assrt(false)")
    except InvalidOperationException:
        if e.Message.Equals("assert failed"):
Logln("Assert.assrt(false) works")
        else:
Errln("FAIL: Assert.assrt(false) returned " + e.Message)
    try:
ICU4N.Impl.Assert.Assrt("Assert message", false)
Errln("FAIL: Assert.assrt(false)")
    except InvalidOperationException:
        if e.Message.Equals("assert 'Assert message' failed"):
Logln("Assert.assrt(false) works")
        else:
Errln("FAIL: Assert.assrt(false) returned " + e.Message)
    try:
ICU4N.Impl.Assert.Fail("Assert message")
Errln("FAIL: Assert.fail")
    except InvalidOperationException:
        if e.Message.Equals("failure 'Assert message'"):
Logln("Assert.fail works")
        else:
Errln("FAIL: Assert.fail returned " + e.Message)
    try:
ICU4N.Impl.Assert.Fail(InvalidFormatException)
Errln("FAIL: Assert.fail with an exception")
    except InvalidOperationException:
Logln("Assert.fail works")
proc TestCaseInsensitiveString*() =
    var str1: CaseInsensitiveString = CaseInsensitiveString("ThIs is A tEst")
    var str2: CaseInsensitiveString = CaseInsensitiveString("This IS a test")
    if !str1.Equals(str2) || !str1.ToString.Equals(str1.String) || str1.ToString.Equals(str2.ToString):
Errln("FAIL: str1(" + str1 + ") != str2(" + str2 + ")")
proc TestSourceLocation*() =
    var here: string = TestFmwk.SourceLocation
    var there: string = CheckSourceLocale
    var hereAgain: string = TestFmwk.SourceLocation
assertTrue("here < there < hereAgain", here.CompareToOrdinal(there) < 0 && there.CompareToOrdinal(hereAgain) < 0)
proc CheckSourceLocale*(): string =
    return TestFmwk.SourceLocation