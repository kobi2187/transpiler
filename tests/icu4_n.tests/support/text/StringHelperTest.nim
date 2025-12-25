# "Namespace: ICU4N.Text"
type
  StringHelperTest = ref object
    a: string = "ayz"
    b: string = "byz"
    c: string = "cyz"
    d: string = "dyz"
    e: string = "eyz"
    s: string = "ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss"
    Empty: string = ""

proc TestConcat_ReadOnlySpan_x2*(expected: string, str0: string, str1: string) =
Assert.AreEqual(expected, StringHelper.Concat(str0.AsSpan, str1.AsSpan))
proc TestConcat_ReadOnlySpan_x3*(expected: string, str0: string, str1: string, str2: string) =
Assert.AreEqual(expected, StringHelper.Concat(str0.AsSpan, str1.AsSpan, str2.AsSpan))
proc TestConcat_ReadOnlySpan_x4*(expected: string, str0: string, str1: string, str2: string, str3: string) =
Assert.AreEqual(expected, StringHelper.Concat(str0.AsSpan, str1.AsSpan, str2.AsSpan, str3.AsSpan))
proc TestConcat_ReadOnlySpan_x5*(expected: string, str0: string, str1: string, str2: string, str3: string, str4: string) =
Assert.AreEqual(expected, StringHelper.Concat(str0.AsSpan, str1.AsSpan, str2.AsSpan, str3.AsSpan, str4.AsSpan))
proc TestConcat_ReadOnlySpan_x6*(expected: string, str0: string, str1: string, str2: string, str3: string, str4: string, str5: string) =
Assert.AreEqual(expected, StringHelper.Concat(str0.AsSpan, str1.AsSpan, str2.AsSpan, str3.AsSpan, str4.AsSpan, str5.AsSpan))