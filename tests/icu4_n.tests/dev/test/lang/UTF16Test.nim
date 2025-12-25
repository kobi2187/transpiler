# "Namespace: ICU4N.Dev.Test.Lang"
type
  UTF16Test = ref object
    INDEXOF_SUPPLEMENTARY_STRING_: String = "𠐂q��q𠐂qr" + "𠐂q𠐂q��s"
    INDEXOF_SUPPLEMENTARY_CHAR_: seq[int] = @[113, 55361, 56322, UTF16Util.GetRawSupplementary(cast[char](55361), cast[char](56322))]
    INDEXOF_SUPPLEMENTARY_CHAR_INDEX_: seq[int] = @[@[2, 5, 8, 12, 15], @[4, 17], @[3, 16], @[0, 6, 10, 13]]
    INDEXOF_SUPPLEMENTARY_STR_: String = "��"
    INDEXOF_SUPPLEMENTARY_STR_INDEX_: seq[int] = @[3, 16]

proc newUTF16Test(): UTF16Test =

proc TestAppend*() =
    var strbuff: StringBuffer = StringBuffer("this is a string ")
    var array: char[] = seq[char]
    var strsize: int = strbuff.Length
    var arraysize: int = strsize
    if 0 != strsize:
strbuff.CopyTo(0, array, 0, strsize)
      var i: int = 1
      while i < UChar.MaxValue:
UTF16.Append(strbuff, i)
          arraysize = UTF16.Append(array, arraysize, i)
          var arraystr: String = String(array, 0, arraysize)
          if !arraystr.Equals(strbuff.ToString):
Errln("FAIL Comparing char array append and string append " + "with 0x" + i.ToHexString)
          if i == 56401:
--strsize
          if UTF16.CountCodePoint(strbuff.ToString) != strsize + i / 100 + 1:
Errln("FAIL Counting code points in string appended with " + " 0x" + i.ToHexString)
              break
          i = 100
    strbuff = StringBuffer
UTF16.AppendCodePoint(strbuff, 65536)
    if strbuff.Length != 2:
Errln("fail appendCodePoint")
proc TestBounds*() =
    var strbuff: StringBuffer = StringBuffer("�0123𐀀𐐁�")
    var str: String = strbuff.ToString
    var array: char[] = str.ToCharArray
    var boundtype: int[] = @[UTF16.SingleCharBoundary, UTF16.SingleCharBoundary, UTF16.SingleCharBoundary, UTF16.SingleCharBoundary, UTF16.SingleCharBoundary, UTF16.LeadSurrogateBoundary, UTF16.TrailSurrogateBoundary, UTF16.LeadSurrogateBoundary, UTF16.TrailSurrogateBoundary, UTF16.SingleCharBoundary]
    var length: int = str.Length
      var i: int = 0
      while i < length:
          if UTF16.Bounds(str, i) != boundtype[i]:
Errln("FAIL checking bound type at index " + i)
          if UTF16.Bounds(strbuff, i) != boundtype[i]:
Errln("FAIL checking bound type at index " + i)
          if UTF16.Bounds(array.AsSpan(0, length), i) != boundtype[i]:
Errln("FAIL checking bound type at index " + i)
++i
    var start: int = 4
    var limit: int = 9
    var subboundtype1: int[] = @[UTF16.SingleCharBoundary, UTF16.LeadSurrogateBoundary, UTF16.TrailSurrogateBoundary, UTF16.LeadSurrogateBoundary, UTF16.TrailSurrogateBoundary]
    try:
UTF16.Bounds(array.AsSpan(start, limit - start), -1)
Errln("FAIL Out of bounds index in bounds should fail")
    except Exception:
Console.Out.Write("")
      var i: int = 0
      while i < limit - start:
          if UTF16.Bounds(array.AsSpan(start, limit - start), i) != subboundtype1[i]:
Errln("FAILED Subarray bounds in [" + start + ", " + limit + "] expected " + subboundtype1[i] + " at offset " + i)
++i
    var subboundtype2: int[] = @[UTF16.SingleCharBoundary, UTF16.LeadSurrogateBoundary, UTF16.TrailSurrogateBoundary]
    start = 6
    limit = 9
      var i: int = 0
      while i < limit - start:
          if UTF16.Bounds(array.AsSpan(start, limit - start), i) != subboundtype2[i]:
Errln("FAILED Subarray bounds in [" + start + ", " + limit + "] expected " + subboundtype2[i] + " at offset " + i)
++i
    var subboundtype3: int[] = @[UTF16.LeadSurrogateBoundary, UTF16.TrailSurrogateBoundary, UTF16.SingleCharBoundary]
    start = 5
    limit = 8
      var i: int = 0
      while i < limit - start:
          if UTF16.Bounds(array.AsSpan(start, limit - start), i) != subboundtype3[i]:
Errln("FAILED Subarray bounds in [" + start + ", " + limit + "] expected " + subboundtype3[i] + " at offset " + i)
++i
proc TestCharAt*() =
    var strbuff: ValueStringBuilder = ValueStringBuilder(newSeq[char](32))
strbuff.Append("12345𐀁67890𐀂")
    if UTF16.CharAt(strbuff.AsSpan, 0) != '1' || UTF16.CharAt(strbuff.AsSpan, 2) != '3' || UTF16.CharAt(strbuff.AsSpan, 5) != 65537 || UTF16.CharAt(strbuff.AsSpan, 6) != 65537 || UTF16.CharAt(strbuff.AsSpan, 12) != 65538 || UTF16.CharAt(strbuff.AsSpan, 13) != 65538:
Errln("FAIL Getting character from string buffer error")
    var str: String = strbuff.ToString
    if UTF16.CharAt(str, 0) != '1' || UTF16.CharAt(str, 2) != '3' || UTF16.CharAt(str, 5) != 65537 || UTF16.CharAt(str, 6) != 65537 || UTF16.CharAt(str, 12) != 65538 || UTF16.CharAt(str, 13) != 65538:
Errln("FAIL Getting character from string error")
    var array: char[] = str.ToCharArray
    var start: int = 0
    var limit: int = str.Length
    if UTF16.CharAt(array.AsSpan(start, limit - start), 0) != '1' || UTF16.CharAt(array.AsSpan(start, limit - start), 2) != '3' || UTF16.CharAt(array.AsSpan(start, limit - start), 5) != 65537 || UTF16.CharAt(array.AsSpan(start, limit - start), 6) != 65537 || UTF16.CharAt(array.AsSpan(start, limit - start), 12) != 65538 || UTF16.CharAt(array.AsSpan(start, limit - start), 13) != 65538:
Errln("FAIL Getting character from array error")
    start = 6
    limit = 13
    try:
UTF16.CharAt(array.AsSpan(start, limit - start), -1)
Errln("FAIL out of bounds error expected")
    except Exception:
Console.Out.Write("")
    try:
UTF16.CharAt(array.AsSpan(start, limit - start), 8)
Errln("FAIL out of bounds error expected")
    except Exception:
Console.Out.Write("")
    if UTF16.CharAt(array.AsSpan(start, limit - start), 0) != 56321:
Errln("FAIL Expected result in subarray 0xdc01")
    if UTF16.CharAt(array.AsSpan(start, limit - start), 6) != 55296:
Errln("FAIL Expected result in subarray 0xd800")
    var replaceable: ReplaceableString = ReplaceableString(str)
    if UTF16.CharAt(replaceable, 0) != '1' || UTF16.CharAt(replaceable, 2) != '3' || UTF16.CharAt(replaceable, 5) != 65537 || UTF16.CharAt(replaceable, 6) != 65537 || UTF16.CharAt(replaceable, 12) != 65538 || UTF16.CharAt(replaceable, 13) != 65538:
Errln("FAIL Getting character from replaceable error")
    var strbuffer: OpenStringBuilder = OpenStringBuilder("0xD805")
UTF16.CharAt(strbuffer.AsSpan, 0)
proc TestCountCodePoint*() =
    var strbuff: OpenStringBuilder = OpenStringBuilder("")
    var array: char[] = nil
    if UTF16.CountCodePoint(strbuff.AsSpan) != 0 || UTF16.CountCodePoint("") != 0 || UTF16.CountCodePoint(array.AsSpan(0, 0)) != 0:
Errln("FAIL Counting code points for empty strings")
    strbuff = OpenStringBuilder("this is a string ")
    var str: String = strbuff.ToString
    array = str.ToCharArray
    var size: int = str.Length
    if UTF16.CountCodePoint(array.AsSpan(0, 0)) != 0:
Errln("FAIL Counting code points for 0 offset array")
    if UTF16.CountCodePoint(str) != size || UTF16.CountCodePoint(strbuff.AsSpan) != size || UTF16.CountCodePoint(array.AsSpan(0, size)) != size:
Errln("FAIL Counting code points")
strbuff.AppendCodePoint(65536)
    str = strbuff.ToString
    array = str.ToCharArray
    if UTF16.CountCodePoint(str) != size + 1 || UTF16.CountCodePoint(strbuff.AsSpan) != size + 1 || UTF16.CountCodePoint(array.AsSpan(0, size + 1)) != size + 1 || UTF16.CountCodePoint(array.AsSpan(0, size + 2)) != size + 1:
Errln("FAIL Counting code points")
strbuff.AppendCodePoint(97)
    str = strbuff.ToString
    array = str.ToCharArray
    if UTF16.CountCodePoint(str) != size + 2 || UTF16.CountCodePoint(strbuff.AsSpan) != size + 2 || UTF16.CountCodePoint(array.AsSpan(0, size + 1)) != size + 1 || UTF16.CountCodePoint(array.AsSpan(0, size + 2)) != size + 1 || UTF16.CountCodePoint(array.AsSpan(0, size + 3)) != size + 2:
Errln("FAIL Counting code points")
proc TestDelete*() =
    var strbuff: StringBuffer = StringBuffer("these are strings")
    var size: int = strbuff.Length
    var array: char[] = strbuff.ToString.ToCharArray
UTF16.Delete(strbuff, 3)
UTF16.Delete(strbuff, 3)
UTF16.Delete(strbuff, 3)
UTF16.Delete(strbuff, 3)
UTF16.Delete(strbuff, 3)
UTF16.Delete(strbuff, 3)
    try:
UTF16.Delete(strbuff, strbuff.Length)
Errln("FAIL deleting out of bounds character should fail")
    except Exception:
Console.Out.Write("")
UTF16.Delete(strbuff, strbuff.Length - 1)
    if !strbuff.ToString.Equals("the string"):
Errln("FAIL expected result after deleting characters is " + ""the string"")
    size = UTF16.Delete(array, size, 3)
    size = UTF16.Delete(array, size, 3)
    size = UTF16.Delete(array, size, 3)
    size = UTF16.Delete(array, size, 3)
    size = UTF16.Delete(array, size, 3)
    size = UTF16.Delete(array, size, 3)
    try:
UTF16.Delete(array, size, size)
Errln("FAIL deleting out of bounds character should fail")
    except Exception:
Console.Out.Write("")
    size = UTF16.Delete(array, size, size - 1)
    var str: String = String(array, 0, size)
    if !str.Equals("the string"):
Errln("FAIL expected result after deleting characters is " + ""the string"")
    strbuff = StringBuffer("string: 𐀀 𐐁 𐐁")
    size = strbuff.Length
    array = strbuff.ToString.ToCharArray
UTF16.Delete(strbuff, 8)
UTF16.Delete(strbuff, 8)
UTF16.Delete(strbuff, 9)
UTF16.Delete(strbuff, 8)
UTF16.Delete(strbuff, 9)
UTF16.Delete(strbuff, 6)
UTF16.Delete(strbuff, 6)
    if !strbuff.ToString.Equals("string"):
Errln("FAIL expected result after deleting characters is "string"")
    size = UTF16.Delete(array, size, 8)
    size = UTF16.Delete(array, size, 8)
    size = UTF16.Delete(array, size, 9)
    size = UTF16.Delete(array, size, 8)
    size = UTF16.Delete(array, size, 9)
    size = UTF16.Delete(array, size, 6)
    size = UTF16.Delete(array, size, 6)
    str = String(array, 0, size)
    if !str.Equals("string"):
Errln("FAIL expected result after deleting characters is "string"")
proc TestfindOffset*() =
    var str: String = "a𐀀b"
    var strbuff: OpenStringBuilder = OpenStringBuilder(str)
    var array: char[] = str.ToCharArray
    var limit: int = str.Length
    if UTF16.FindCodePointOffset(str, 0) != 0 || UTF16.FindOffsetFromCodePoint(str, 0) != 0 || UTF16.FindCodePointOffset(strbuff.AsSpan, 0) != 0 || UTF16.FindOffsetFromCodePoint(strbuff.AsSpan, 0) != 0 || UTF16.FindCodePointOffset(array.AsSpan(0, limit), 0) != 0 || UTF16.FindOffsetFromCodePoint(array.AsSpan(0, limit), 0) != 0:
Errln("FAIL Getting the first codepoint offset to a string with " + "supplementary characters")
    if UTF16.FindCodePointOffset(str, 1) != 1 || UTF16.FindOffsetFromCodePoint(str, 1) != 1 || UTF16.FindCodePointOffset(strbuff.AsSpan, 1) != 1 || UTF16.FindOffsetFromCodePoint(strbuff.AsSpan, 1) != 1 || UTF16.FindCodePointOffset(array.AsSpan(0, limit), 1) != 1 || UTF16.FindOffsetFromCodePoint(array.AsSpan(0, limit), 1) != 1:
Errln("FAIL Getting the second codepoint offset to a string with " + "supplementary characters")
    if UTF16.FindCodePointOffset(str, 2) != 1 || UTF16.FindOffsetFromCodePoint(str, 2) != 3 || UTF16.FindCodePointOffset(strbuff.AsSpan, 2) != 1 || UTF16.FindOffsetFromCodePoint(strbuff.AsSpan, 2) != 3 || UTF16.FindCodePointOffset(array.AsSpan(0, limit), 2) != 1 || UTF16.FindOffsetFromCodePoint(array.AsSpan(0, limit), 2) != 3:
Errln("FAIL Getting the third codepoint offset to a string with " + "supplementary characters")
    if UTF16.FindCodePointOffset(str, 3) != 2 || UTF16.FindOffsetFromCodePoint(str, 3) != 4 || UTF16.FindCodePointOffset(strbuff.AsSpan, 3) != 2 || UTF16.FindOffsetFromCodePoint(strbuff.AsSpan, 3) != 4 || UTF16.FindCodePointOffset(array.AsSpan(0, limit), 3) != 2 || UTF16.FindOffsetFromCodePoint(array.AsSpan(0, limit), 3) != 4:
Errln("FAIL Getting the last codepoint offset to a string with " + "supplementary characters")
    if UTF16.FindCodePointOffset(str, 4) != 3 || UTF16.FindCodePointOffset(strbuff.AsSpan, 4) != 3 || UTF16.FindCodePointOffset(array.AsSpan(0, limit), 4) != 3:
Errln("FAIL Getting the length offset to a string with " + "supplementary characters")
    try:
UTF16.FindCodePointOffset(str, 5)
Errln("FAIL Getting the a non-existence codepoint to a string " + "with supplementary characters")
    except Exception:
Logln("Passed out of bounds codepoint offset")
    try:
UTF16.FindOffsetFromCodePoint(str, 4)
Errln("FAIL Getting the a non-existence codepoint to a string " + "with supplementary characters")
    except Exception:
Logln("Passed out of bounds codepoint offset")
    try:
UTF16.FindCodePointOffset(strbuff.AsSpan, 5)
Errln("FAIL Getting the a non-existence codepoint to a string " + "with supplementary characters")
    except Exception:
Logln("Passed out of bounds codepoint offset")
    try:
UTF16.FindOffsetFromCodePoint(strbuff.AsSpan, 4)
Errln("FAIL Getting the a non-existence codepoint to a string " + "with supplementary characters")
    except Exception:
Logln("Passed out of bounds codepoint offset")
    try:
UTF16.FindCodePointOffset(array.AsSpan(0, limit), 5)
Errln("FAIL Getting the a non-existence codepoint to a string " + "with supplementary characters")
    except Exception:
Logln("Passed out of bounds codepoint offset")
    try:
UTF16.FindOffsetFromCodePoint(array.AsSpan(0, limit), 4)
Errln("FAIL Getting the a non-existence codepoint to a string " + "with supplementary characters")
    except Exception:
Logln("Passed out of bounds codepoint offset")
    if UTF16.FindCodePointOffset(array.AsSpan(1, 3 - 1), 0) != 0 || UTF16.FindOffsetFromCodePoint(array.AsSpan(1, 3 - 1), 0) != 0 || UTF16.FindCodePointOffset(array.AsSpan(1, 3 - 1), 1) != 0 || UTF16.FindCodePointOffset(array.AsSpan(1, 3 - 1), 2) != 1 || UTF16.FindOffsetFromCodePoint(array.AsSpan(1, 3 - 1), 1) != 2:
Errln("FAIL Getting valid codepoint offset in sub array")
proc TestGetCharCountSurrogate*() =
    if UTF16.GetCharCount(97) != 1 || UTF16.GetCharCount(65536) != 2:
Errln("FAIL getCharCount result failure")
    if UTF16.GetLeadSurrogate(97) != 0 || UTF16.GetTrailSurrogate(97) != 97 || UTF16.IsLeadSurrogate(cast[char](97)) || UTF16.IsTrailSurrogate(cast[char](97)) || UTF16.GetLeadSurrogate(65536) != 55296 || UTF16.GetTrailSurrogate(65536) != 56320 || UTF16.IsLeadSurrogate(cast[char](55296)) != true || UTF16.IsTrailSurrogate(cast[char](55296)) || UTF16.IsLeadSurrogate(cast[char](56320)) || UTF16.IsTrailSurrogate(cast[char](56320)) != true:
Errln("FAIL *Surrogate result failure")
    if UTF16.IsSurrogate(cast[char](97)) || !UTF16.IsSurrogate(cast[char](55296)) || !UTF16.IsSurrogate(cast[char](56320)):
Errln("FAIL isSurrogate result failure")
proc TestInsert*() =
    var strbuff: StringBuffer = StringBuffer("0123456789")
    var array: char[] = seq[char]
    var srcEnd: int = strbuff.Length
    if 0 != srcEnd:
strbuff.CopyTo(0, array, 0, srcEnd)
    var length: int = 10
UTF16.Insert(strbuff, 5, 't')
UTF16.Insert(strbuff, 5, 's')
UTF16.Insert(strbuff, 5, 'e')
UTF16.Insert(strbuff, 5, 't')
    if !strbuff.ToString.Equals("01234test56789"):
Errln("FAIL inserting "test"")
    length = UTF16.Insert(array, length, 5, 't')
    length = UTF16.Insert(array, length, 5, 's')
    length = UTF16.Insert(array, length, 5, 'e')
    length = UTF16.Insert(array, length, 5, 't')
    var str: String = String(array, 0, length)
    if !str.Equals("01234test56789"):
Errln("FAIL inserting "test"")
UTF16.Insert(strbuff, 0, 65536)
UTF16.Insert(strbuff, 11, 65536)
UTF16.Insert(strbuff, strbuff.Length, 65536)
    if !strbuff.ToString.Equals("𐀀01234test𐀀56789𐀀"):
Errln("FAIL inserting supplementary characters")
    length = UTF16.Insert(array, length, 0, 65536)
    length = UTF16.Insert(array, length, 11, 65536)
    length = UTF16.Insert(array, length, length, 65536)
    str = String(array, 0, length)
    if !str.Equals("𐀀01234test𐀀56789𐀀"):
Errln("FAIL inserting supplementary characters")
    try:
UTF16.Insert(strbuff, -1, 0)
Errln("FAIL invalid insertion offset")
    except Exception:
Console.Out.Write("")
    try:
UTF16.Insert(strbuff, 64, 0)
Errln("FAIL invalid insertion offset")
    except Exception:
Console.Out.Write("")
    try:
UTF16.Insert(array, length, -1, 0)
Errln("FAIL invalid insertion offset")
    except Exception:
Console.Out.Write("")
    try:
UTF16.Insert(array, length, 64, 0)
Errln("FAIL invalid insertion offset")
    except Exception:
Console.Out.Write("")
    try:
UTF16.Insert(array, array.Length, 64, 0)
Errln("FAIL invalid insertion offset")
    except Exception:
Console.Out.Write("")
proc CheckMoveCodePointOffset(s: String, startIdx: int, amount: int, expectedResult: int) =
    try:
        var result: int = UTF16.MoveCodePointOffset(s, startIdx, amount)
        if result != expectedResult:
Errln("FAIL: UTF16.MoveCodePointOffset(String "" + s + "", " + startIdx + ", " + amount + ")" + " returned " + result + ", expected result was " +             if expectedResult == -1:
"exception"
            else:
expectedResult.ToString(CultureInfo.InvariantCulture))
    except IndexOutOfRangeException:
        if expectedResult != -1:
Errln("FAIL: UTF16.MoveCodePointOffset(String "" + s + "", " + startIdx + ", " + amount + ")" + " returned exception" + ", expected result was " + expectedResult)
    var sb: OpenStringBuilder = OpenStringBuilder(s)
    try:
        var result: int = UTF16.MoveCodePointOffset(sb.AsSpan, startIdx, amount)
        if result != expectedResult:
Errln("FAIL: UTF16.MoveCodePointOffset(StringBuffer "" + s + "", " + startIdx + ", " + amount + ")" + " returned " + result + ", expected result was " +             if expectedResult == -1:
"exception"
            else:
expectedResult.ToString(CultureInfo.InvariantCulture))
    except IndexOutOfRangeException:
        if expectedResult != -1:
Errln("FAIL: UTF16.MoveCodePointOffset(StringBuffer "" + s + "", " + startIdx + ", " + amount + ")" + " returned exception" + ", expected result was " + expectedResult)
    var ca: char[] = s.ToCharArray
    try:
        var result: int = UTF16.MoveCodePointOffset(ca.AsSpan(0, s.Length), startIdx, amount)
        if result != expectedResult:
Errln("FAIL: UTF16.MoveCodePointOffset(char[] "" + s + "", 0, " + s.Length + ", " + startIdx + ", " + amount + ")" + " returned " + result + ", expected result was " +             if expectedResult == -1:
"exception"
            else:
expectedResult.ToString(CultureInfo.InvariantCulture))
    except IndexOutOfRangeException:
        if expectedResult != -1:
Errln("FAIL: UTF16.MoveCodePointOffset(char[] "" + s + "", 0, " + s.Length + ", " + startIdx + ", " + amount + ")" + " returned exception" + ", expected result was " + expectedResult)
proc TestMoveCodePointOffset*() =
CheckMoveCodePointOffset("abc", 1, 1, 2)
CheckMoveCodePointOffset("abc", 1, -1, 0)
CheckMoveCodePointOffset("abc", 1, -2, -1)
CheckMoveCodePointOffset("abc", 1, 2, 3)
CheckMoveCodePointOffset("abc", 1, 3, -1)
CheckMoveCodePointOffset("abc", 1, 0, 1)
CheckMoveCodePointOffset("abc", 3, 0, 3)
CheckMoveCodePointOffset("abc", 4, 0, -1)
CheckMoveCodePointOffset("abc", 0, 0, 0)
CheckMoveCodePointOffset("abc", -1, 0, -1)
CheckMoveCodePointOffset("", 0, 0, 0)
CheckMoveCodePointOffset("", 0, -1, -1)
CheckMoveCodePointOffset("", 0, 1, -1)
CheckMoveCodePointOffset("a", 0, 0, 0)
CheckMoveCodePointOffset("a", 1, 0, 1)
CheckMoveCodePointOffset("a", 0, 1, 1)
CheckMoveCodePointOffset("a", 1, -1, 0)
CheckMoveCodePointOffset("a𐀀b", 0, 1, 1)
CheckMoveCodePointOffset("a𐀀b", 0, 2, 3)
CheckMoveCodePointOffset("a𐀀b", 0, 3, 4)
CheckMoveCodePointOffset("a𐀀b", 0, 4, -1)
CheckMoveCodePointOffset("a𐀀b", 4, -1, 3)
CheckMoveCodePointOffset("a𐀀b", 4, -2, 1)
CheckMoveCodePointOffset("a𐀀b", 4, -3, 0)
CheckMoveCodePointOffset("a𐀀b", 4, -4, -1)
CheckMoveCodePointOffset("𐀀ab", 0, 1, 2)
CheckMoveCodePointOffset("𐀀ab", 1, 1, 2)
CheckMoveCodePointOffset("𐀀ab", 2, 1, 3)
CheckMoveCodePointOffset("𐀀ab", 2, -1, 0)
CheckMoveCodePointOffset("𐀀ab", 1, -1, 0)
CheckMoveCodePointOffset("𐀀ab", 0, -1, -1)
CheckMoveCodePointOffset("ab𐀀", 1, 1, 2)
CheckMoveCodePointOffset("ab𐀀", 2, 1, 4)
CheckMoveCodePointOffset("ab𐀀", 3, 1, 4)
CheckMoveCodePointOffset("ab𐀀", 4, 1, -1)
CheckMoveCodePointOffset("ab𐀀", 5, -2, -1)
CheckMoveCodePointOffset("ab𐀀", 4, -1, 2)
CheckMoveCodePointOffset("ab𐀀", 3, -1, 2)
CheckMoveCodePointOffset("ab𐀀", 2, -1, 1)
CheckMoveCodePointOffset("ab𐀀", 1, -1, 0)
CheckMoveCodePointOffset("a�b", 0, 1, 1)
CheckMoveCodePointOffset("a�b", 1, 1, 2)
CheckMoveCodePointOffset("a�b", 2, 1, 3)
CheckMoveCodePointOffset("a�b", 0, 1, 1)
CheckMoveCodePointOffset("a�b", 1, 1, 2)
CheckMoveCodePointOffset("a�b", 2, 1, 3)
CheckMoveCodePointOffset("a��b", 0, 1, 1)
CheckMoveCodePointOffset("a��b", 1, 1, 2)
CheckMoveCodePointOffset("a��b", 2, 1, 3)
CheckMoveCodePointOffset("a��b", 3, 1, 4)
CheckMoveCodePointOffset("a�b", 1, -1, 0)
CheckMoveCodePointOffset("a�b", 2, -1, 1)
CheckMoveCodePointOffset("a�b", 3, -1, 2)
CheckMoveCodePointOffset("a�b", 1, -1, 0)
CheckMoveCodePointOffset("a�b", 2, -1, 1)
CheckMoveCodePointOffset("a�b", 3, -1, 2)
CheckMoveCodePointOffset("a��b", 1, -1, 0)
CheckMoveCodePointOffset("a��b", 2, -1, 1)
CheckMoveCodePointOffset("a��b", 3, -1, 2)
CheckMoveCodePointOffset("a��b", 4, -1, 3)
CheckMoveCodePointOffset("�ab", 0, 1, 1)
CheckMoveCodePointOffset("�ab", 0, 2, 2)
CheckMoveCodePointOffset("��ab", 0, 3, 3)
CheckMoveCodePointOffset("��ab", 0, 4, 4)
CheckMoveCodePointOffset("�ab", 2, -1, 1)
CheckMoveCodePointOffset("�ab", 1, -1, 0)
CheckMoveCodePointOffset("�ab", 1, -2, -1)
CheckMoveCodePointOffset("��ab", 2, -1, 1)
CheckMoveCodePointOffset("��ab", 2, -2, 0)
CheckMoveCodePointOffset("��ab", 2, -3, -1)
CheckMoveCodePointOffset("ab��ab", 3, 1, 4)
CheckMoveCodePointOffset("ab��ab", 2, 1, 3)
CheckMoveCodePointOffset("ab��ab", 1, 1, 2)
CheckMoveCodePointOffset("ab��ab", 4, -1, 3)
CheckMoveCodePointOffset("ab��ab", 3, -1, 2)
CheckMoveCodePointOffset("ab��ab", 2, -1, 1)
    var str: String = "0123456789𐀀𐐁0123456789"
    var move1: int[] = @[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 12, 14, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
    var move2: int[] = @[2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 14, 15, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, -1]
    var move3: int[] = @[3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 15, 15, 16, 16, 17, 18, 19, 20, 21, 22, 23, 24, -1, -1]
    var size: int = str.Length
      var i: int = 0
      while i < size:
CheckMoveCodePointOffset(str, i, 1, move1[i])
CheckMoveCodePointOffset(str, i, 2, move2[i])
CheckMoveCodePointOffset(str, i, 3, move3[i])
++i
    var strarray: char[] = str.ToCharArray
    if UTF16.MoveCodePointOffset(strarray.AsSpan(9, 13 - 9), 0, 2) != 3:
Errln("FAIL: Moving offset 0 by 2 codepoint in subarray [9, 13] " + "expected result 3")
    if UTF16.MoveCodePointOffset(strarray.AsSpan(9, 13 - 9), 1, 2) != 4:
Errln("FAIL: Moving offset 1 by 2 codepoint in subarray [9, 13] " + "expected result 4")
    if UTF16.MoveCodePointOffset(strarray.AsSpan(11, 14 - 11), 0, 2) != 3:
Errln("FAIL: Moving offset 0 by 2 codepoint in subarray [11, 14] " + "expected result 3")
proc TestSetCharAt*() =
    var strbuff: StringBuffer = StringBuffer("012345")
    var array: char[] = seq[char]
    var srcEnd: int = strbuff.Length
    if 0 != srcEnd:
strbuff.CopyTo(0, array, 0, srcEnd)
    var length: int = 6
      var i: int = 0
      while i < length:
UTF16.SetCharAt(strbuff, i, '0')
UTF16.SetCharAt(array, length, i, '0')
++i
    var str: String = String(array, 0, length)
    if !strbuff.ToString.Equals("000000") || !str.Equals("000000"):
Errln("FAIL: setChar to '0' failed")
UTF16.SetCharAt(strbuff, 0, 65536)
UTF16.SetCharAt(strbuff, 4, 65536)
UTF16.SetCharAt(strbuff, 7, 65536)
    if !strbuff.ToString.Equals("𐀀00𐀀0𐀀"):
Errln("FAIL: setChar to 0x10000 failed")
    length = UTF16.SetCharAt(array, length, 0, 65536)
    length = UTF16.SetCharAt(array, length, 4, 65536)
    length = UTF16.SetCharAt(array, length, 7, 65536)
    str = String(array, 0, length)
    if !str.Equals("𐀀00𐀀0𐀀"):
Errln("FAIL: setChar to 0x10000 failed")
UTF16.SetCharAt(strbuff, 0, '0')
UTF16.SetCharAt(strbuff, 1, '1')
UTF16.SetCharAt(strbuff, 2, '2')
UTF16.SetCharAt(strbuff, 4, '3')
UTF16.SetCharAt(strbuff, 4, '4')
UTF16.SetCharAt(strbuff, 5, '5')
    if !strbuff.ToString.Equals("012345"):
Errln("Fail converting supplementaries in StringBuffer to BMP " + "characters")
    length = UTF16.SetCharAt(array, length, 0, '0')
    length = UTF16.SetCharAt(array, length, 1, '1')
    length = UTF16.SetCharAt(array, length, 2, '2')
    length = UTF16.SetCharAt(array, length, 4, '3')
    length = UTF16.SetCharAt(array, length, 4, '4')
    length = UTF16.SetCharAt(array, length, 5, '5')
    str = String(array, 0, length)
    if !str.Equals("012345"):
Errln("Fail converting supplementaries in array to BMP " + "characters")
    try:
UTF16.SetCharAt(strbuff, -1, 0)
Errln("FAIL: setting character at invalid offset")
    except Exception:
Console.Out.Write("")
    try:
UTF16.SetCharAt(array, length, -1, 0)
Errln("FAIL: setting character at invalid offset")
    except Exception:
Console.Out.Write("")
    try:
UTF16.SetCharAt(strbuff, length, 0)
Errln("FAIL: setting character at invalid offset")
    except Exception:
Console.Out.Write("")
    try:
UTF16.SetCharAt(array, length, length, 0)
Errln("FAIL: setting character at invalid offset")
    except Exception:
Console.Out.Write("")
proc TestValueOf*() =
    if UChar.ConvertToUtf32('�', '�') != 65536:
Errln("FAIL: getCodePoint('�','�')")
    if !UTF16.ValueOf(97).Equals("a") || !UTF16.ValueOf(65536).Equals("𐀀"):
Errln("FAIL: valueof(char32)")
    var str: String = "01234𐀀56789"
    var strbuff: ReadOnlySpan<char> = str.AsSpan
    var array: char[] = str.ToCharArray
    var length: int = str.Length
    var expected: String[] = @["0", "1", "2", "3", "4", "𐀀", "𐀀", "5", "6", "7", "8", "9"]
      var i: int = 0
      while i < length:
          if !UTF16.ValueOf(str, i).Equals(expected[i], StringComparison.Ordinal) || !UTF16.ValueOf(strbuff, i).Equals(expected[i], StringComparison.Ordinal) || !UTF16.ValueOf(array.AsSpan(0, length), i).Equals(expected[i], StringComparison.Ordinal):
Errln("FAIL: valueOf() expected " + expected[i])
++i
    try:
UTF16.ValueOf(str, -1)
Errln("FAIL: out of bounds error expected")
    except Exception:
Console.Out.Write("")
    try:
UTF16.ValueOf(strbuff, -1)
Errln("FAIL: out of bounds error expected")
    except Exception:
Console.Out.Write("")
    try:
UTF16.ValueOf(array.AsSpan(0, length), -1)
Errln("FAIL: out of bounds error expected")
    except Exception:
Console.Out.Write("")
    try:
UTF16.ValueOf(str, length)
Errln("FAIL: out of bounds error expected")
    except Exception:
Console.Out.Write("")
    try:
UTF16.ValueOf(strbuff, length)
Errln("FAIL: out of bounds error expected")
    except Exception:
Console.Out.Write("")
    try:
UTF16.ValueOf(array.AsSpan(0, length), length)
Errln("FAIL: out of bounds error expected")
    except Exception:
Console.Out.Write("")
    if !UTF16.ValueOf(array.AsSpan(6, length - 6), 0).Equals("�", StringComparison.Ordinal) || !UTF16.ValueOf(array.AsSpan(0, 6), 5).Equals("�", StringComparison.Ordinal):
Errln("FAIL: error getting partial supplementary character")
    try:
UTF16.ValueOf(array.AsSpan(3, 5 - 3), -1)
Errln("FAIL: out of bounds error expected")
    except Exception:
Console.Out.Write("")
    try:
UTF16.ValueOf(array.AsSpan(3, 5 - 3), 3)
Errln("FAIL: out of bounds error expected")
    except Exception:
Console.Out.Write("")
proc TestValueOf_Int32_Span_Int32*() =
    var actual: Span<char> = newSeq[char](2)
    var length: int
    length = UTF16.ValueOf(97, actual, 0)
    if !System.MemoryExtensions.Equals(actual.Slice(0, length), "a".AsSpan, StringComparison.Ordinal):
Errln("FAIL: valueof(char32, destination, destinationIndex)")
    length = UTF16.ValueOf(65536, actual, 0)
    if !System.MemoryExtensions.Equals(actual.Slice(0, length), "𐀀".AsSpan, StringComparison.Ordinal):
Errln("FAIL: valueof(char32, destination, destinationIndex)")
    try:
UTF16.ValueOf(97, actual, 3)
Errln("FAIL: out of bounds error expected")
    except Exception:
Console.Out.Write("")
    try:
UTF16.ValueOf(97, actual, -1)
Errln("FAIL: out of bounds error expected")
    except Exception:
Console.Out.Write("")
    try:
UTF16.ValueOf(UTF16.CodePointMinValue - 1, actual, 0)
Errln("FAIL: out of bounds error expected")
    except Exception:
Console.Out.Write("")
    try:
UTF16.ValueOf(UTF16.CodePointMaxValue + 1, actual, 0)
Errln("FAIL: out of bounds error expected")
    except Exception:
Console.Out.Write("")
proc TestIndexOf*() =
    var test1: String = "test test ttest tetest testesteststt"
    var test2: String = "test"
    var testChar1: int = 116
    var testChar2: int = 132098
    var test3: String = "𠐂q��q𠐂qr𠐂q𠐂q��s"
    var test4: String = UChar.ConvertFromUtf32(testChar2)
    if UTF16.IndexOf(test1, test2, StringComparison.Ordinal) != 0 || UTF16.IndexOf(test1, test2, 0, StringComparison.Ordinal) != 0:
Errln("indexOf failed: expected to find '" + test2 + "' at position 0 in text '" + test1 + "'")
    if UTF16.IndexOf(test1, testChar1) != 0 || UTF16.IndexOf(test1, testChar1) != 0:
Errln("indexOf failed: expected to find 0x" + testChar1.ToHexString + " at position 0 in text '" + test1 + "'")
    if UTF16.IndexOf(test3, testChar2) != 0 || UTF16.IndexOf(test3, testChar2, 0) != 0:
Errln("indexOf failed: expected to find 0x" + testChar2.ToHexString + " at position 0 in text '" + Utility.Hex(test3) + "'")
    var test5: String = "�𠐂"
    if UTF16.IndexOf(test5, testChar2) != 1 || UTF16.IndexOf(test5, testChar2, 0) != 1:
Errln("indexOf failed: expected to find 0x" + testChar2.ToHexString + " at position 0 in text '" + Utility.Hex(test3) + "'")
    if UTF16.LastIndexOf(test1, test2, StringComparison.Ordinal) != 29 || UTF16.LastIndexOf(test1, test2, test1.Length, StringComparison.Ordinal) != 29:
Errln("LastIndexOf failed: expected to find '" + test2 + "' at position 29 in text '" + test1 + "'")
    if UTF16.LastIndexOf(test1, testChar1) != 35 || UTF16.LastIndexOf(test1, testChar1, test1.Length) != 35:
Errln("LastIndexOf failed: expected to find 0x" + testChar1.ToHexString + " at position 35 in text '" + test1 + "'")
    if UTF16.LastIndexOf(test3, testChar2) != 13 || UTF16.LastIndexOf(test3, testChar2, test3.Length) != 13:
Errln("LastIndexOf failed: expected to find 0x" + testChar2.ToHexString + " at position 13 in text '" + Utility.Hex(test3) + "'")
AssertThrows[ArgumentOutOfRangeException](<unhandled: nnkLambda>)
AssertThrows[ArgumentOutOfRangeException](<unhandled: nnkLambda>)
AssertThrows[ArgumentOutOfRangeException](<unhandled: nnkLambda>)
AssertThrows[ArgumentOutOfRangeException](<unhandled: nnkLambda>)
AssertThrows[ArgumentOutOfRangeException](<unhandled: nnkLambda>)
AssertThrows[ArgumentOutOfRangeException](<unhandled: nnkLambda>)
AssertDoesNotThrow(<unhandled: nnkLambda>)
AssertDoesNotThrow(<unhandled: nnkLambda>)
    if UTF16.SafeLastIndexOf(test1, test2, test1.Length) != 29:
Errln("LastIndexOf failed: expected to find '" + test2 + "' at position 29 in text '" + test1 + "'")
    if UTF16.SafeLastIndexOf(test1, testChar1, test1.Length) != 35:
Errln("LastIndexOf failed: expected to find 0x" + testChar1.ToHexString + " at position 35 in text '" + test1 + "'")
    if UTF16.SafeLastIndexOf(test3, testChar2, test3.Length) != 13:
Errln("LastIndexOf failed: expected to find 0x" + testChar2.ToHexString + " at position 13 in text '" + Utility.Hex(test3) + "'")
    var occurrences: int = 0
      var startPos: int = 0
      while startPos != -1 && startPos < test1.Length:
          startPos = UTF16.IndexOf(test1, test2, startPos, StringComparison.Ordinal)
          if startPos >= 0:
++occurrences
              startPos = 4
    if occurrences != 6:
Errln("indexOf failed: expected to find 6 occurrences, found " + occurrences)
    occurrences = 0
      var startPos: int = 10
      while startPos != -1 && startPos < test1.Length:
          startPos = UTF16.IndexOf(test1, test2, startPos, StringComparison.Ordinal)
          if startPos >= 0:
++occurrences
              startPos = 4
    if occurrences != 4:
Errln("indexOf with starting offset failed: expected to find 4 occurrences, found " + occurrences)
    occurrences = 0
      var startPos: int = 0
      while startPos != -1 && startPos < test3.Length:
          startPos = UTF16.IndexOf(test3, test4, startPos, StringComparison.Ordinal)
          if startPos != -1:
++occurrences
              startPos = 2
    if occurrences != 4:
Errln("indexOf failed: expected to find 4 occurrences, found " + occurrences)
    occurrences = 0
      var startPos: int = 10
      while startPos != -1 && startPos < test3.Length:
          startPos = UTF16.IndexOf(test3, test4, startPos, StringComparison.Ordinal)
          if startPos != -1:
++occurrences
              startPos = 2
    if occurrences != 2:
Errln("indexOf failed: expected to find 2 occurrences, found " + occurrences)
    occurrences = 0
      var startPos: int = 0
      while startPos != -1 && startPos < test1.Length:
          startPos = UTF16.IndexOf(test1, testChar1, startPos)
          if startPos != -1:
++occurrences
              startPos = 1
    if occurrences != 16:
Errln("indexOf with character failed: expected to find 16 occurrences, found " + occurrences)
    occurrences = 0
      var startPos: int = 10
      while startPos != -1 && startPos < test1.Length:
          startPos = UTF16.IndexOf(test1, testChar1, startPos)
          if startPos != -1:
++occurrences
              startPos = 1
    if occurrences != 12:
Errln("indexOf with character & start offset failed: expected to find 12 occurrences, found " + occurrences)
    occurrences = 0
      var startPos: int = 0
      while startPos != -1 && startPos < test3.Length:
          startPos = UTF16.IndexOf(test3, testChar2, startPos)
          if startPos != -1:
++occurrences
              startPos = 1
    if occurrences != 4:
Errln("indexOf failed: expected to find 4 occurrences, found " + occurrences)
    occurrences = 0
      var startPos: int = 5
      while startPos != -1 && startPos < test3.Length:
          startPos = UTF16.IndexOf(test3, testChar2, startPos)
          if startPos != -1:
++occurrences
              startPos = 1
    if occurrences != 3:
Errln("indexOf with character & start & end offsets failed: expected to find 2 occurrences, found " + occurrences)
    occurrences = 0
      var startPos: int = 32
      while startPos != -1:
          startPos = UTF16.LastIndexOf(test1, test2, startPos, StringComparison.Ordinal)
          if startPos != -1:
++occurrences
              startPos = 5
    if occurrences != 3:
Errln("lastIndexOf with starting and ending offsets failed: expected to find 3 occurrences, found " + occurrences)
    occurrences = 0
      var startPos: int = 32
      while startPos > -1:
          startPos = UTF16.LastIndexOf(test1, testChar1, startPos)
          if startPos != -1:
++occurrences
              startPos = 5
    if occurrences != 7:
Errln("lastIndexOf with character & start & end offsets failed: expected to find 7 occurrences, found " + occurrences)
    occurrences = 0
      var startPos: int = test3.Length
      while startPos > -1:
          startPos = UTF16.LastIndexOf(test3, testChar2, Math.Max(startPos - 5, 0))
          if startPos != -1:
++occurrences
    if occurrences != 3:
Errln("lastIndexOf with character & start & end offsets failed: expected to find 3 occurrences, found " + occurrences)
      var i: int = 0
      while i < INDEXOF_SUPPLEMENTARY_CHAR_.Length:
          var ch: int = INDEXOF_SUPPLEMENTARY_CHAR_[i]
            var j: int = 0
            while j < INDEXOF_SUPPLEMENTARY_CHAR_INDEX_[i].Length:
                var index: int = 0
                var expected: int = INDEXOF_SUPPLEMENTARY_CHAR_INDEX_[i][j]
                if j > 0:
                    index = INDEXOF_SUPPLEMENTARY_CHAR_INDEX_[i][j - 1] + 1
                if UTF16.IndexOf(INDEXOF_SUPPLEMENTARY_STRING_, ch, index) != expected || UTF16.IndexOf(INDEXOF_SUPPLEMENTARY_STRING_, UChar.ConvertFromUtf32(ch), index, StringComparison.Ordinal) != expected:
Errln("Failed finding index for supplementary 0x" + ch.ToHexString)
                index = INDEXOF_SUPPLEMENTARY_STRING_.Length
                if j < INDEXOF_SUPPLEMENTARY_CHAR_INDEX_[i].Length - 1:
                    index = INDEXOF_SUPPLEMENTARY_CHAR_INDEX_[i][j + 1] - 1
                if UTF16.LastIndexOf(INDEXOF_SUPPLEMENTARY_STRING_, ch, index) != expected || UTF16.LastIndexOf(INDEXOF_SUPPLEMENTARY_STRING_, UChar.ConvertFromUtf32(ch), index, StringComparison.Ordinal) != expected:
Errln("Failed finding last index for supplementary 0x" + ch.ToHexString)
++j
++i
      var i: int = 0
      while i < INDEXOF_SUPPLEMENTARY_STR_INDEX_.Length:
          var index: int = 0
          var expected: int = INDEXOF_SUPPLEMENTARY_STR_INDEX_[i]
          if i > 0:
              index = INDEXOF_SUPPLEMENTARY_STR_INDEX_[i - 1] + 1
          if UTF16.IndexOf(INDEXOF_SUPPLEMENTARY_STRING_, INDEXOF_SUPPLEMENTARY_STR_, index, StringComparison.Ordinal) != expected:
Errln("Failed finding index for supplementary string " + Hex(INDEXOF_SUPPLEMENTARY_STRING_))
          index = INDEXOF_SUPPLEMENTARY_STRING_.Length
          if i < INDEXOF_SUPPLEMENTARY_STR_INDEX_.Length - 1:
              index = INDEXOF_SUPPLEMENTARY_STR_INDEX_[i + 1] - 1
          if UTF16.LastIndexOf(INDEXOF_SUPPLEMENTARY_STRING_, INDEXOF_SUPPLEMENTARY_STR_, index, StringComparison.Ordinal) != expected:
Errln("Failed finding last index for supplementary string " + Hex(INDEXOF_SUPPLEMENTARY_STRING_))
++i
proc TestReplace*() =
    var test1: String = "One potato, two potato, three potato, four
"
    var test2: String = "potato"
    var test3: String = "MISSISSIPPI"
    var result: String = UTF16.Replace(test1, test2, test3)
    var expectedValue: String = "One MISSISSIPPI, two MISSISSIPPI, three MISSISSIPPI, four
"
    if !result.Equals(expectedValue):
Errln("findAndReplace failed: expected "" + expectedValue + "", got "" + test1 + "".")
    result = UTF16.Replace(test1, test3, test2)
    expectedValue = test1
    if !result.Equals(expectedValue):
Errln("findAndReplace failed: expected "" + expectedValue + "", got "" + test1 + "".")
    result = UTF16.Replace(test1, ',', 'e')
    expectedValue = "One potatoe two potatoe three potatoe four
"
    if !result.Equals(expectedValue):
Errln("findAndReplace failed: expected "" + expectedValue + "", got "" + test1 + "".")
    result = UTF16.Replace(test1, ',', 65536)
    expectedValue = "One potato𐀀 two potato𐀀 three potato𐀀 four
"
    if !result.Equals(expectedValue):
Errln("findAndReplace failed: expected "" + expectedValue + "", got "" + test1 + "".")
    result = UTF16.Replace(test1, "potato", "𐀀𐐁")
    expectedValue = "One 𐀀𐐁, two 𐀀𐐁, three 𐀀𐐁, four
"
    if !result.Equals(expectedValue):
Errln("findAndReplace failed: expected "" + expectedValue + "", got "" + test1 + "".")
    var test4: String = "�𐀀𐀀��𐀀𐀀�"
    result = UTF16.Replace(test4, 55296, 'A')
    expectedValue = "A𐀀𐀀�A𐀀𐀀�"
    if !result.Equals(expectedValue):
Errln("findAndReplace failed: expected "" + expectedValue + "", got "" + test1 + "".")
    result = UTF16.Replace(test4, 56320, 'A')
    expectedValue = "�𐀀𐀀A�𐀀𐀀A"
    if !result.Equals(expectedValue):
Errln("findAndReplace failed: expected "" + expectedValue + "", got "" + test1 + "".")
    result = UTF16.Replace(test4, 65536, 'A')
    expectedValue = "�AA��AA�"
    if !result.Equals(expectedValue):
Errln("findAndReplace failed: expected "" + expectedValue + "", got "" + test1 + "".")
proc TestReverse*() =
    var test: StringBuffer = StringBuffer("backwards words say to used I")
    var result: StringBuffer = UTF16.Reverse(test)
    if !result.ToString.Equals("I desu ot yas sdrow sdrawkcab"):
Errln("reverse() failed:  Expected "I desu ot yas sdrow sdrawkcab",
 got "" + result + """)
    var testbuffer: StringBuffer = StringBuffer
UTF16.Append(testbuffer, 194969)
UTF16.Append(testbuffer, 119135)
UTF16.Append(testbuffer, 196)
UTF16.Append(testbuffer, 7888)
    result = UTF16.Reverse(testbuffer)
    var resultString: string = result.ToString
    if result[0] != 7888 || result[1] != 196 || UTF16.CharAt(resultString, 2) != 119135 || UTF16.CharAt(resultString, 4) != 194969:
Errln("reverse() failed with supplementary characters")
proc TestStringComparator*() =
    var compare: UTF16.StringComparer = UTF16.StringComparer
    if compare.CodePointCompare != false:
Errln("Default string comparator should be code unit compare")
    if compare.IgnoreCase != false:
Errln("Default string comparator should be case sensitive compare")
    if compare.IgnoreCaseOption != UTF16.StringComparer.FoldCaseDefault:
Errln("Default string comparator should have fold case default compare")
    compare.CodePointCompare = true
    if compare.CodePointCompare != true:
Errln("Error setting code point compare")
    compare.CodePointCompare = false
    if compare.CodePointCompare != false:
Errln("Error setting code point compare")
    compare.IgnoreCase = true
    compare.IgnoreCaseOption = UTF16.StringComparer.FoldCaseDefault
    if compare.IgnoreCase != true || compare.IgnoreCaseOption != UTF16.StringComparer.FoldCaseDefault:
Errln("Error setting ignore case and options")
    compare.IgnoreCase = false
    compare.IgnoreCaseOption = UTF16.StringComparer.FoldCaseExcludeSpecialI
    if compare.IgnoreCase != false || compare.IgnoreCaseOption != UTF16.StringComparer.FoldCaseExcludeSpecialI:
Errln("Error setting ignore case and options")
    compare.IgnoreCase = true
    compare.IgnoreCaseOption = UTF16.StringComparer.FoldCaseExcludeSpecialI
    if compare.IgnoreCase != true || compare.IgnoreCaseOption != UTF16.StringComparer.FoldCaseExcludeSpecialI:
Errln("Error setting ignore case and options")
    compare.IgnoreCase = false
    compare.IgnoreCaseOption = UTF16.StringComparer.FoldCaseDefault
    if compare.IgnoreCase != false || compare.IgnoreCaseOption != UTF16.StringComparer.FoldCaseDefault:
Errln("Error setting ignore case and options")
proc TestCodePointCompare*() =
    var str: String[] = @["a", "€�", "€𐀀", "�", "�｡", "�", "｡�", "｡𐀂", "𐀂", "𣑖"]
    var cpcompare: UTF16.StringComparer = UTF16.StringComparer(true, false, UTF16.StringComparer.FoldCaseDefault)
    var cucompare: UTF16.StringComparer = UTF16.StringComparer
      var i: int = 0
      while i < str.Length - 1:
          if cpcompare.Compare(str[i], str[i + 1]) >= 0:
Errln("error: compare() in code point order fails for string " + Utility.Hex(str[i]) + " and " + Utility.Hex(str[i + 1]))
          if Math.Sign(cucompare.Compare(str[i], str[i + 1])) != Math.Sign(str[i].CompareToOrdinal(str[i + 1])):
Errln("error: compare() in code unit order fails for string " + Utility.Hex(str[i]) + " and " + Utility.Hex(str[i + 1]))
++i
proc TestCaseCompare*() =
    var mixed: String = "aBıΣßﬃ񟿿"
    var otherDefault: String = "AbıσsSFfI񟿿"
    var otherExcludeSpecialI: String = "AbıσSsfFi񟿿"
    var different: String = "AbıσsSFfI񟿽"
    var compare: UTF16.StringComparer = UTF16.StringComparer
    compare.IgnoreCase = true
    compare.IgnoreCaseOption = UTF16.StringComparer.FoldCaseDefault
    var result: int = compare.Compare(mixed, otherDefault)
    if result != 0:
Errln("error: default compare(mixed, other) = " + result + " instead of 0")
    compare.IgnoreCase = true
    compare.IgnoreCaseOption = UTF16.StringComparer.FoldCaseExcludeSpecialI
    result = compare.Compare(mixed, otherExcludeSpecialI)
    if result != 0:
Errln("error: exclude_i compare(mixed, other) = " + result + " instead of 0")
    compare.IgnoreCase = true
    compare.IgnoreCaseOption = UTF16.StringComparer.FoldCaseDefault
    result = compare.Compare(mixed, different)
    if result <= 0:
Errln("error: default compare(mixed, different) = " + result + " instead of positive")
    compare.IgnoreCase = true
    compare.IgnoreCaseOption = UTF16.StringComparer.FoldCaseDefault
    result = compare.Compare(mixed.Substring(0, 4), different.Substring(0, 4))
    if result != 0:
Errln("error: default compare(mixed substring, different substring) = " + result + " instead of 0")
    compare.IgnoreCase = true
    compare.IgnoreCaseOption = UTF16.StringComparer.FoldCaseDefault
    result = compare.Compare(mixed.Substring(0, 5), different.Substring(0, 5))
    if result <= 0:
Errln("error: default compare(mixed substring, different substring) = " + result + " instead of positive")
proc TestHasMoreCodePointsThan*() =
    var str: String = "ab𐀀𐐁c�d" + "�ef𑀄𑐅g"
    var length: int = str.Length
    while length >= 0:
          var i: int = 0
          while i <= length:
              var s: String = str.Substring(0, i)
                var number: int = -1
                while number <= length - i + 2:
                    var flag: bool = UTF16.HasMoreCodePointsThan(s, number)
                    if flag != UTF16.CountCodePoint(s) > number:
Errln("hasMoreCodePointsThan(" + Utility.Hex(s) + ", " + number + ") = " + flag + " is wrong")
++number
++i
--length
      length = -1
      while length <= 1:
            var i: int = 0
            while i <= length:
                  var number: int = -2
                  while number <= 2:
                      var flag: bool = UTF16.HasMoreCodePointsThan(cast[String](nil), number)
                      if flag != UTF16.CountCodePoint(cast[String](nil)) > number:
Errln("hasMoreCodePointsThan(null, " + number + ") = " + flag + " is wrong")
++number
++i
++length
    length = str.Length
    while length >= 0:
          var i: int = 0
          while i <= length:
              var s: ReadOnlySpan<char> = str.AsSpan(0, i)
                var number: int = -1
                while number <= length - i + 2:
                    var flag: bool = UTF16.HasMoreCodePointsThan(s, number)
                    if flag != UTF16.CountCodePoint(s) > number:
Errln("hasMoreCodePointsThan(" + Utility.Hex(s) + ", " + number + ") = " + flag + " is wrong")
++number
++i
--length
      length = -1
      while length <= 1:
            var i: int = 0
            while i <= length:
                  var number: int = -2
                  while number <= 2:
                      var flag: bool = UTF16.HasMoreCodePointsThan(cast[ReadOnlySpan<char>](nil), number)
                      if flag != UTF16.CountCodePoint(cast[ReadOnlySpan<char>](nil)) > number:
Errln("hasMoreCodePointsThan(null, " + number + ") = " + flag + " is wrong")
++number
++i
++length
    var strarray: char[] = str.ToCharArray
    while length >= 0:
          var limit: int = 0
          while limit <= length:
                var start: int = 0
                while start <= limit:
                      var number: int = -1
                      while number <= limit - start + 2:
                          var flag: bool = UTF16.HasMoreCodePointsThan(strarray.AsSpan(start, limit - start), number)
                          if flag != UTF16.CountCodePoint(strarray.AsSpan(start, limit - start)) > number:
Errln("hasMoreCodePointsThan(" + Utility.Hex(str.AsSpan(start, limit - start)) + ", " + start + ", " + limit + ", " + number + ") = " + flag + " is wrong")
++number
++start
++limit
--length
      length = -1
      while length <= 1:
            var i: int = 0
            while i <= length:
                  var number: int = -2
                  while number <= 2:
                      var flag: bool = UTF16.HasMoreCodePointsThan(cast[ReadOnlySpan<char>](nil), number)
                      if flag != UTF16.CountCodePoint(cast[ReadOnlySpan<char>](nil)) > number:
Errln("hasMoreCodePointsThan(null, " + number + ") = " + flag + " is wrong")
++number
++i
++length
proc TestUtilities*() =
    var tests: String[] = @["a", "￿", "ðŸ˜€", "�", "�", "􏿿", "", " ", "��", "ab", "ðŸ˜€a", nil]
    var sc: UTF16.StringComparer = UTF16.StringComparer(true, false, 0)
    for item1 in tests:
        var nonNull1: String =         if item1 != nil:
item1
        else:
""
        var count: int = UTF16.CountCodePoint(nonNull1)
        var expected: int =         if count == 0 || count > 1:
-1
        else:
nonNull1.CodePointAt(0)
assertEquals("codepoint test " + Utility.Hex(nonNull1), expected, UTF16.GetSingleCodePoint(item1))
        if expected == -1:
            continue
        for item2 in tests:
            var nonNull2: String =             if item2 != nil:
item2
            else:
""
            var scValue: int = sc.Compare(nonNull1, nonNull2).Signum
            var fValue: int = UTF16.CompareCodePoint(expected, item2).Signum
assertEquals("comparison " + Utility.Hex(nonNull1) + ", " + Utility.Hex(nonNull2), scValue, fValue)
proc TestNewString*() =
    var codePoints: int[] = @[UChar.ToCodePoint(UChar.MinHighSurrogate, UChar.MaxLowSurrogate), UChar.ToCodePoint(UChar.MaxHighSurrogate, UChar.MinLowSurrogate), UChar.MaxHighSurrogate, 'A', -1]
    var cpString: String = "" + UChar.MinHighSurrogate + UChar.MaxLowSurrogate + UChar.MaxHighSurrogate + UChar.MinLowSurrogate + UChar.MaxHighSurrogate + 'A'
    var tests: int[][] = @[@[0, 1, 0, 2], @[0, 2, 0, 4], @[1, 1, 2, 2], @[1, 2, 2, 3], @[1, 3, 2, 4], @[2, 2, 4, 2], @[2, 3, 0, -1], @[4, 5, 0, -1], @[3, -1, 0, -1]]
      var i: int = 0
      while i < tests.Length:
          var t: int[] = tests[i]
          var s: int = t[0]
          var c: int = t[1]
          var rs: int = t[2]
          var rc: int = t[3]
          var e: Exception = nil
          try:
              var str: String = UTF16.NewString(codePoints, s, c)
              if rc == -1 || !str.AsSpan.Equals(cpString.AsSpan(rs, rc), StringComparison.Ordinal):
Errln("failed codePoints iter: " + i + " start: " + s + " len: " + c)
              continue
          except IndexOutOfRangeException:
              e = e1
          except ArgumentException:
              e = e2
          if rc != -1:
Errln(e.ToString)
++i