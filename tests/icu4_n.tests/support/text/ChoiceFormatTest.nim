# "Namespace: ICU4N.Support.Text"
type
  ChoiceFormatTest = ref object
    limits: seq[double] = @[0, 1, ChoiceFormat.NextDouble(1), ChoiceFormat.NextDouble(2)]
    formats: seq[string] = @["Less than one", "one", "Between one and two", "Greater than two"]
    f1: ChoiceFormat

proc newChoiceFormatTest(): ChoiceFormatTest =
  f1 = ChoiceFormat(limits, formats)
proc test_Constructor_D_Ljava_lang_String*() =
    var formattedString: String
    var appleLimits: double[] = @[1, 2, 3, 4, 5]
    var appleFormats: String[] = @["Tiny Apple", "Small Apple", "Medium Apple", "Large Apple", "Huge Apple"]
    var cf: ChoiceFormat = ChoiceFormat(appleLimits, appleFormats)
    formattedString = cf.Format(double.NegativeInfinity)
assertTrue("a) Incorrect format returned: " + formattedString, formattedString.Equals("Tiny Apple"))
    formattedString = cf.Format(0.5)
assertTrue("b) Incorrect format returned: " + formattedString, formattedString.Equals("Tiny Apple"))
    formattedString = cf.Format(1.0)
assertTrue("c) Incorrect format returned: " + formattedString, formattedString.Equals("Tiny Apple"))
    formattedString = cf.Format(1.5)
assertTrue("d) Incorrect format returned: " + formattedString, formattedString.Equals("Tiny Apple"))
    formattedString = cf.Format(2.0)
assertTrue("e) Incorrect format returned: " + formattedString, formattedString.Equals("Small Apple"))
    formattedString = cf.Format(2.5)
assertTrue("f) Incorrect format returned: " + formattedString, formattedString.Equals("Small Apple"))
    formattedString = cf.Format(3.0)
assertTrue("g) Incorrect format returned: " + formattedString, formattedString.Equals("Medium Apple"))
    formattedString = cf.Format(4.0)
assertTrue("h) Incorrect format returned: " + formattedString, formattedString.Equals("Large Apple"))
    formattedString = cf.Format(5.0)
assertTrue("i) Incorrect format returned: " + formattedString, formattedString.Equals("Huge Apple"))
    formattedString = cf.Format(5.5)
assertTrue("j) Incorrect format returned: " + formattedString, formattedString.Equals("Huge Apple"))
    formattedString = cf.Format(6.0)
assertTrue("k) Incorrect format returned: " + formattedString, formattedString.Equals("Huge Apple"))
    formattedString = cf.Format(double.PositiveInfinity)
assertTrue("l) Incorrect format returned: " + formattedString, formattedString.Equals("Huge Apple"))
proc test_ConstructorLjava_lang_String*() =
    var formattedString: String
    var patternString: String = "-2#Inverted Orange| 0#No Orange| 0<Almost No Orange| 1#Normal Orange| 2#Expensive Orange"
    var cf: ChoiceFormat = ChoiceFormat(patternString)
    formattedString = cf.Format(double.NegativeInfinity)
assertTrue("a) Incorrect format returned: " + formattedString, formattedString.Equals("Inverted Orange"))
    formattedString = cf.Format(-3)
assertTrue("b) Incorrect format returned: " + formattedString, formattedString.Equals("Inverted Orange"))
    formattedString = cf.Format(-2)
assertTrue("c) Incorrect format returned: " + formattedString, formattedString.Equals("Inverted Orange"))
    formattedString = cf.Format(-1)
assertTrue("d) Incorrect format returned: " + formattedString, formattedString.Equals("Inverted Orange"))
    formattedString = cf.Format(-0)
assertTrue("e) Incorrect format returned: " + formattedString, formattedString.Equals("No Orange"))
    formattedString = cf.Format(0)
assertTrue("f) Incorrect format returned: " + formattedString, formattedString.Equals("No Orange"))
    formattedString = cf.Format(0.1)
assertTrue("g) Incorrect format returned: " + formattedString, formattedString.Equals("Almost No Orange"))
    formattedString = cf.Format(1)
assertTrue("h) Incorrect format returned: " + formattedString, formattedString.Equals("Normal Orange"))
    formattedString = cf.Format(1.5)
assertTrue("i) Incorrect format returned: " + formattedString, formattedString.Equals("Normal Orange"))
    formattedString = cf.Format(2)
assertTrue("j) Incorrect format returned: " + formattedString, formattedString.Equals("Expensive Orange"))
    formattedString = cf.Format(3)
assertTrue("k) Incorrect format returned: " + formattedString, formattedString.Equals("Expensive Orange"))
    formattedString = cf.Format(double.PositiveInfinity)
assertTrue("l) Incorrect format returned: " + formattedString, formattedString.Equals("Expensive Orange"))
proc test_applyPatternLjava_lang_String*() =
    var f: ChoiceFormat = cast[ChoiceFormat](f1.Clone)
f.ApplyPattern("0#0|1#1")
assertTrue("Incorrect limits", Array.Equals(f.GetLimits, @[0, 1]))
assertTrue("Incorrect formats", Array.Equals(f.GetFormats, @["0", "1"]))
    var choiceLimits: double[] = @[-1, 0, 1, ChoiceFormat.NextDouble(1)]
    var choiceFormats: String[] = @["is negative", "is zero or fraction", "is one", "is more than 1"]
    f = ChoiceFormat("")
f.ApplyPattern("-1#is negative|0#is zero or fraction|1#is one|1<is more than 1")
assertTrue("Incorrect limits", Array.Equals(f.GetLimits, choiceLimits))
assertTrue("Incorrect formats", Array.Equals(f.GetFormats, choiceFormats))
    f = ChoiceFormat("")
    try:
f.ApplyPattern("-1#is negative|0#is zero or fraction|-1#is one|1<is more than 1")
fail("Expected IllegalArgumentException")
    except ArgumentException:

    f = ChoiceFormat("")
    try:
f.ApplyPattern("-1is negative|0#is zero or fraction|1#is one|1<is more than 1")
fail("Expected IllegalArgumentException")
    except ArgumentException:

    f = ChoiceFormat("")
f.ApplyPattern("-1<is negative|0#is zero or fraction|1#is one|1<is more than 1")
    choiceLimits[0] = ChoiceFormat.NextDouble(-1)
assertTrue("Incorrect limits", Array.Equals(f.GetLimits, choiceLimits))
assertTrue("Incorrect formats", Array.Equals(f.GetFormats, choiceFormats))
    f = ChoiceFormat("")
f.ApplyPattern("-1#is negative|0#is zero or fraction|1#is one|1<is more than 1")
    var str: String = "org.apache.harmony.tests.java.text.ChoiceFormat"
f.ApplyPattern(str)
    var ptrn: String = f.ToPattern
assertEquals("Return value should be empty string for invalid pattern", 0, ptrn.Length)
proc test_clone*() =
    var f: ChoiceFormat = cast[ChoiceFormat](f1.Clone)
assertTrue("Not equal", f.Equals(f1))
f.SetChoices(@[0, 1, 2], @["0", "1", "2"])
assertTrue("Equal", !f.Equals(f1))
proc test_equalsLjava_lang_Object*() =
    var patternString: String = "-2#Inverted Orange| 0#No Orange| 0<Almost No Orange| 1#Normal Orange| 2#Expensive Orange"
    var appleLimits: double[] = @[1, 2, 3, 4, 5]
    var appleFormats: String[] = @["Tiny Apple", "Small Apple", "Medium Apple", "Large Apple", "Huge Apple"]
    var orangeLimits: double[] = @[-2, 0, ChoiceFormat.NextDouble(0), 1, 2]
    var orangeFormats: String[] = @["Inverted Orange", "No Orange", "Almost No Orange", "Normal Orange", "Expensive Orange"]
    var appleChoiceFormat: ChoiceFormat = ChoiceFormat(appleLimits, appleFormats)
    var orangeChoiceFormat: ChoiceFormat = ChoiceFormat(orangeLimits, orangeFormats)
    var orangeChoiceFormat2: ChoiceFormat = ChoiceFormat(patternString)
    var hybridChoiceFormat: ChoiceFormat = ChoiceFormat(appleLimits, orangeFormats)
assertTrue("Apples should not equal oranges", !appleChoiceFormat.Equals(orangeChoiceFormat))
assertTrue("Different limit list--should not appear as equal", !orangeChoiceFormat.Equals(hybridChoiceFormat))
assertTrue("Different format list--should not appear as equal", !appleChoiceFormat.Equals(hybridChoiceFormat))
assertTrue("Should be equal--identical format", appleChoiceFormat.Equals(appleChoiceFormat))
assertTrue("Should be equals--same limits, same formats", orangeChoiceFormat.Equals(orangeChoiceFormat2))
    var f2: ChoiceFormat = ChoiceFormat("0#Less than one|1#one|1<Between one and two|2<Greater than two")
assertTrue("Not equal", f1.Equals(f2))
proc test_formatDLjava_lang_StringBufferLjava_text_FieldPosition*() =
    var field: FieldPosition = FieldPosition(0)
    var buf: StringBuffer = StringBuffer
    var r: String = f1.Format(-1, buf, field).ToString
assertEquals("Wrong choice for -1", "Less than one", r)
    buf.Length = 0
    r = f1.Format(0, buf, field).ToString
assertEquals("Wrong choice for 0", "Less than one", r)
    buf.Length = 0
    r = f1.Format(1, buf, field).ToString
assertEquals("Wrong choice for 1", "one", r)
    buf.Length = 0
    r = f1.Format(2, buf, field).ToString
assertEquals("Wrong choice for 2", "Between one and two", r)
    buf.Length = 0
    r = f1.Format(3, buf, field).ToString
assertEquals("Wrong choice for 3", "Greater than two", r)
assertEquals("", 0, ChoiceFormat("|").Format(double.NaN, StringBuffer, FieldPosition(6)).Length)
assertEquals("", 0, ChoiceFormat("|").Format(1, StringBuffer, FieldPosition(6)).Length)
assertEquals("", "Less than one", f1.Format(double.NaN, StringBuffer, field).ToString)
proc test_formatJLjava_lang_StringBufferLjava_text_FieldPosition*() =
    var field: FieldPosition = FieldPosition(0)
    var buf: StringBuffer = StringBuffer
    var r: String = f1.Format(0.5, buf, field).ToString
assertEquals("Wrong choice for 0.5", "Less than one", r)
    buf.Length = 0
    r = f1.Format(1.5, buf, field).ToString
assertEquals("Wrong choice for 1.5", "Between one and two", r)
    buf.Length = 0
    r = f1.Format(2.5, buf, field).ToString
assertEquals("Wrong choice for 2.5", "Greater than two", r)
proc test_getFormats*() =
    var orgFormats: String[] = cast[String[]](formats.Clone)
    var f: String[] = cast[String[]](f1.GetFormats)
assertTrue("Wrong formats", f.Equals(formats))
    f[0] = "Modified"
assertTrue("Formats copied", !f.Equals(orgFormats))
proc test_getLimits*() =
    var orgLimits: double[] = cast[double[]](limits.Clone)
    var l: double[] = f1.GetLimits
assertTrue("Wrong limits", l.Equals(limits))
    l[0] = 3.14527
assertTrue("Limits copied", !l.Equals(orgLimits))
proc test_hashCode*() =
    var f2: ChoiceFormat = ChoiceFormat("0#Less than one|1#one|1<Between one and two|2<Greater than two")
assertTrue("Different hash", f1.GetHashCode == f2.GetHashCode)
proc test_nextDoubleD*() =
assertTrue("Not greater 5", ChoiceFormat.NextDouble(5) > 5)
assertTrue("Not greater 0", ChoiceFormat.NextDouble(0) > 0)
assertTrue("Not greater -5", ChoiceFormat.NextDouble(-5) > -5)
assertTrue("Not NaN", double.IsNaN(ChoiceFormat.NextDouble(double.NaN)))
proc test_nextDoubleDZ*() =
assertTrue("Not greater 0", ChoiceFormat.NextDouble(0, true) > 0)
assertTrue("Not less 0", ChoiceFormat.NextDouble(0, false) < 0)
proc test_parseLjava_lang_StringLjava_text_ParsePosition*() =
    var format: ChoiceFormat = ChoiceFormat("1#one|2#two|3#three")
assertEquals("Case insensitive", 0, cast[int](format.Parse("One", ParsePosition(0))))
    var pos: ParsePosition = ParsePosition(0)
    var result: double = f1.Parse("Greater than two", pos)
assertTrue("Wrong value ~>2", result == ChoiceFormat.NextDouble(2))
assertEquals("Wrong position ~16", 16, pos.Index)
    pos = ParsePosition(0)
assertTrue("Incorrect result", double.IsNaN(f1.Parse("12one", pos)))
assertEquals("Wrong position ~0", 0, pos.Index)
    pos = ParsePosition(2)
    result = f1.Parse("12one and two", pos)
assertEquals("Ignored parse position", 1.0, result, 0.0)
assertEquals("Wrong position ~5", 5, pos.Index)
proc test_previousDoubleD*() =
assertTrue("Not less 5", ChoiceFormat.PreviousDouble(5) < 5)
assertTrue("Not less 0", ChoiceFormat.PreviousDouble(0) < 0)
assertTrue("Not less -5", ChoiceFormat.PreviousDouble(-5) < -5)
assertTrue("Not NaN", double.IsNaN(ChoiceFormat.PreviousDouble(double.NaN)))
proc test_setChoices_D_Ljava_lang_String*() =
    var f: ChoiceFormat = cast[ChoiceFormat](f1.Clone)
    var l: double[] = @[0, 1]
    var fs: String[] = @["0", "1"]
f.SetChoices(l, fs)
assertTrue("Limits copied", f.GetLimits == l)
assertTrue("Formats copied", f.GetFormats == fs)
proc test_toPattern*() =
    var cf: ChoiceFormat = ChoiceFormat("")
assertEquals("", "", cf.ToPattern)
    cf = ChoiceFormat("-1#NEGATIVE_ONE|0#ZERO|1#ONE|1<GREATER_THAN_ONE")
assertEquals("", "-1.0#NEGATIVE_ONE|0.0#ZERO|1.0#ONE|1.0<GREATER_THAN_ONE", cf.ToPattern)
    var mf: MessageFormat = MessageFormat("CHOICE {1,choice}")
    var ptrn: String = mf.ToPattern
assertEquals("Unused message format returning incorrect pattern", "CHOICE {1,choice,}", ptrn)
    var pattern: String = f1.ToPattern
assertTrue("Wrong pattern: " + pattern, pattern.Equals("0.0#Less than one|1.0#one|1.0<Between one and two|2.0<Greater than two"))
    cf = ChoiceFormat("-1#is negative| 0#is zero or fraction | 1#is one |1.0<is 1+|2#is two |2<is more than 2.")
    var str: String = "org.apache.harmony.tests.java.lang.share.MyResources2"
cf.ApplyPattern(str)
    ptrn = cf.ToPattern
assertEquals("Return value should be empty string for invalid pattern", 0, ptrn.Length)
proc test_formatL*() =
    var fmt: ChoiceFormat = ChoiceFormat("-1#NEGATIVE_ONE|0#ZERO|1#ONE|1<GREATER_THAN_ONE")
assertEquals("", "NEGATIVE_ONE", fmt.Format(long.MinValue))
assertEquals("", "NEGATIVE_ONE", fmt.Format(-1))
assertEquals("", "ZERO", fmt.Format(0))
assertEquals("", "ONE", fmt.Format(1))
assertEquals("", "GREATER_THAN_ONE", fmt.Format(long.MaxValue))
proc test_formatD*() =
    var fmt: ChoiceFormat = ChoiceFormat("-1#NEGATIVE_ONE|0#ZERO|1#ONE|1<GREATER_THAN_ONE")
assertEquals("", "NEGATIVE_ONE", fmt.Format(double.NegativeInfinity))
assertEquals("", "NEGATIVE_ONE", fmt.Format(-999999999.0))
assertEquals("", "NEGATIVE_ONE", fmt.Format(-1.1))
assertEquals("", "NEGATIVE_ONE", fmt.Format(-1.0))
assertEquals("", "NEGATIVE_ONE", fmt.Format(-0.9))
assertEquals("", "ZERO", fmt.Format(0.0))
assertEquals("", "ZERO", fmt.Format(0.9))
assertEquals("", "ONE", fmt.Format(1.0))
assertEquals("", "GREATER_THAN_ONE", fmt.Format(1.1))
assertEquals("", "GREATER_THAN_ONE", fmt.Format(999999999.0))
assertEquals("", "GREATER_THAN_ONE", fmt.Format(double.PositiveInfinity))