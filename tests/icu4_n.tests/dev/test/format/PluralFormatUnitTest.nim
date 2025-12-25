# "Namespace: ICU4N.Dev.Test.Format"
type
  PluralFormatUnitTest = ref object


proc TestConstructor*() =
    var plFmts: PluralFormat[] = seq[PluralFormat]
    plFmts[0] = PluralFormat
plFmts[0].ApplyPattern("other{#}")
    plFmts[1] = PluralFormat(PluralRules.Default)
plFmts[1].ApplyPattern("other{#}")
    plFmts[2] = PluralFormat(PluralRules.Default, "other{#}")
    plFmts[3] = PluralFormat("other{#}")
    plFmts[4] = PluralFormat(UCultureInfo.CurrentCulture)
plFmts[4].ApplyPattern("other{#}")
    plFmts[5] = PluralFormat(UCultureInfo.CurrentCulture, PluralRules.Default)
plFmts[5].ApplyPattern("other{#}")
    plFmts[6] = PluralFormat(UCultureInfo.CurrentCulture, PluralRules.Default, "other{#}")
    plFmts[7] = PluralFormat(UCultureInfo.CurrentCulture, "other{#}")
    plFmts[8] = PluralFormat(CultureInfo.CurrentCulture)
plFmts[8].ApplyPattern("other{#}")
    plFmts[9] = PluralFormat(CultureInfo.CurrentCulture, PluralRules.Default)
plFmts[9].ApplyPattern("other{#}")
    var numberFmt: NumberFormat = NumberFormat.GetInstance(UCultureInfo.CurrentCulture)
      var n: int = 1
      while n < 13:
          var result: String = numberFmt.Format(n)
            var k: int = 0
            while k < plFmts.Length:
TestFmwk.assertEquals("PluralFormat's output is not as expected", result, plFmts[k].Format(n))
++k
++n
    var sb: StringBuffer = StringBuffer
    var ignore: FieldPosition = FieldPosition(-1)
      var n: int = 100
      while n < 113:
          var result: String = numberFmt.Format(n * n)
            var k: int = 0
            while k < plFmts.Length:
sb.Delete(0, sb.Length)
                var pfResult: String = plFmts[k].Format(Long.GetInstance(n * n), sb, ignore).ToString
TestFmwk.assertEquals("PluralFormat's output is not as expected", result, pfResult)
++k
++n
proc TestEquals*() =
    var de_fee_1: PluralFormat = PluralFormat(UCultureInfo("de"), PluralType.Cardinal, "other{fee}")
    var de_fee_2: PluralFormat = PluralFormat(UCultureInfo("de"), PluralType.Cardinal, "other{fee}")
    var de_fi: PluralFormat = PluralFormat(UCultureInfo("de"), PluralType.Cardinal, "other{fi}")
    var fr_fee: PluralFormat = PluralFormat(UCultureInfo("fr"), PluralType.Cardinal, "other{fee}")
assertTrue("different de_fee objects", de_fee_1 != de_fee_2)
assertTrue("equal de_fee objects", de_fee_1.Equals(de_fee_2))
assertFalse("different pattern strings", de_fee_1.Equals(de_fi))
assertFalse("different locales", de_fee_1.Equals(fr_fee))
proc TestApplyPatternAndFormat*() =
    var oddAndEven: PluralRules = PluralRules.CreateRules("odd: n mod 2 is 1")
      var plfOddAndEven: PluralFormat = PluralFormat(oddAndEven)
plfOddAndEven.ApplyPattern("odd{# is odd.} other{# is even.}")
      var plfOddOrEven: PluralFormat = PluralFormat(oddAndEven)
plfOddOrEven.ApplyPattern("other{# is odd or even.}")
      var numberFormat: NumberFormat = NumberFormat.GetInstance(UCultureInfo.CurrentCulture)
        var i: int = 0
        while i < 22:
assertEquals("Fallback to other gave wrong results", numberFormat.Format(i) + " is odd or even.", plfOddOrEven.Format(i))
assertEquals("Fully specified PluralFormat gave wrong results", numberFormat.Format(i) +             if i % 2 == 1:
" is odd."
            else:
" is even.", plfOddAndEven.Format(i))
++i
      var pf: PluralFormat = PluralFormat(UCultureInfo("en"), oddAndEven, "odd{foo} odd{bar} other{foobar}")
assertEquals("should use first occurrence of the 'odd' keyword", "foo", pf.Format(1))
pf.ApplyPattern("odd{foo} other{bar} other{foobar}")
assertEquals("should use first occurrence of the 'other' keyword", "bar", pf.Format(2))
pf.ApplyPattern("other{foo} odd{bar} other{foobar}")
assertEquals("should use first occurrence of the 'other' keyword", "foo", pf.Format(2))
    try:
        var plFmt: PluralFormat = PluralFormat(oddAndEven)
plFmt.ApplyPattern("odd{foo}")
Errln("Not defining plural case other should result in an " + "exception but did not.")
    except ArgumentException:

      var pf: PluralFormat = PluralFormat(UCultureInfo("en"), oddAndEven, "otto{foo} other{bar}")
assertEquals("should ignore unknown keywords", "bar", pf.Format(1))
    try:
        var plFmt: PluralFormat = PluralFormat(oddAndEven)
plFmt.ApplyPattern("*odd{foo} other{bar}")
Errln("Defining a message for an invalid keyword should result in " + "an exception but did not.")
    except ArgumentException:

    try:
        var plFmt: PluralFormat = PluralFormat(oddAndEven)
plFmt.ApplyPattern("odd{foo},other{bar}")
Errln("Separating keyword{message} items with other characters " + "than space should provoke an exception but did not.")
    except ArgumentException:

    try:
        var plFmt: PluralFormat = PluralFormat(oddAndEven)
plFmt.ApplyPattern("od d{foo} other{bar}")
Errln("Spaces inside keywords should provoke an exception but " + "did not.")
    except ArgumentException:

    try:
        var plFmt: PluralFormat = PluralFormat(oddAndEven)
plFmt.ApplyPattern("odd{foo}{foobar}other{foo}")
Errln("Defining multiple messages after a keyword should provoke " + "an exception but did not.")
    except ArgumentException:

      var plFmt: PluralFormat = PluralFormat(oddAndEven)
plFmt.ApplyPattern("odd{The number {0, number, #.#0} is odd.}" + "other{The number {0, number, #.#0} is even.}")
        var i: int = 1
        while i < 3:
assertEquals("format did not preserve a nested format string.",             if i % 2 == 1:
"The number {0, number, #.#0} is odd."
            else:
"The number {0, number, #.#0} is even.", plFmt.Format(i))
++i
      var plFmt: PluralFormat = PluralFormat(oddAndEven)
plFmt.ApplyPattern("odd{The number {1,number,#} is odd.}" + "other{The number {2,number,#} is even.}")
        var i: int = 1
        while i < 3:
assertEquals("format did not preserve # inside curly braces.",             if i % 2 == 1:
"The number {1,number,#} is odd."
            else:
"The number {2,number,#} is even.", plFmt.Format(i))
++i
proc TestSamples*() =
    var same: IDictionary<UCultureInfo, ISet<UCultureInfo>> = J2N.Collections.Generic.OrderedDictionary<UCultureInfo, ISet<UCultureInfo>>
    for locale in PluralRules.GetUCultures:
        var otherLocale: UCultureInfo = PluralRules.GetFunctionalEquivalent(locale)
        if !same.TryGetValue(otherLocale,         var others: ISet<UCultureInfo>):
          same[otherLocale] =           others = LinkedHashSet<UCultureInfo>
others.Add(locale)
        continue
    for locale0 in same.Keys:
        var rules: PluralRules = PluralRules.GetInstance(locale0)
        var localeName: String =         if locale0.ToString.Length == 0:
"root"
        else:
locale0.ToString
Logln(localeName + "	=	" + same[locale0])
Logln(localeName + "	toString	" + rules.ToString)
        var keywords: ICollection<string> = rules.Keywords
        for keyword in keywords:
            var list: ICollection<double> = rules.GetSamples(keyword)
            if list.Count == 0:
                list = rules.GetSamples(keyword, PluralRulesSampleType.Decimal)
            if list == nil || list.Count == 0:
Errln("Empty list for " + localeName + " : " + keyword)
            else:
Logln("	" + localeName + " : " + keyword + " ; " + list)
proc TestSetLocale*() =
    var oddAndEven: PluralRules = PluralRules.CreateRules("odd__: n mod 2 is 1")
    var plFmt: PluralFormat = PluralFormat(oddAndEven)
plFmt.ApplyPattern("odd__{odd} other{even}")
plFmt.SetCulture(UCultureInfo("en"))
    var nrFmt: NumberFormat = NumberFormat.GetInstance(UCultureInfo("en"))
assertEquals("pattern was not resetted by setLocale() call.", nrFmt.Format(5), plFmt.Format(5))
plFmt.ApplyPattern("odd__{odd} other{even}")
assertEquals("SetLocale should reset rules but did not.", "even", plFmt.Format(1))
plFmt.ApplyPattern("one{one} other{not one}")
      var i: int = 0
      while i < 20:
assertEquals("Wrong ruleset loaded by setLocale()",           if i == 1:
"one"
          else:
"not one", plFmt.Format(i))
++i
proc TestParse*() =
    var plFmt: PluralFormat = PluralFormat("other{test}")
    try:
plFmt.Parse("test", ParsePosition(0))
Errln("parse() should throw an UnsupportedOperationException but " + "did not")
    except NotSupportedException:

    plFmt = PluralFormat("other{test}")
    try:
plFmt.ParseObject("test", ParsePosition(0))
Errln("parse() should throw an UnsupportedOperationException but " + "did not")
    except NotSupportedException:

proc TestPattern*() =
    var args: Object[] = @["acme", nil]
      var pat: String = "  one {one ''widget} other {# widgets}  "
      var pf: PluralFormat = PluralFormat(pat)
assertEquals("should not trim() the pattern", pat, pf.ToPattern)
    var pfmt: MessageFormat = MessageFormat("The disk ''{0}'' contains {1, plural,  one {one ''''{1, number, #.0}'''' widget} other {# widgets}}.")
Logln("")
      var i: int = 0
      while i < 3:
          args[1] = Integer.GetInstance(i)
Logln(pfmt.Format(args))
++i
Logln(pfmt.ToPattern)
    var pfmt2: MessageFormat = MessageFormat(pfmt.ToPattern)
assertEquals("message formats are equal", pfmt, pfmt2)
proc TestExtendedPluralFormat*() =
    var targets: String[] = @["There are no widgets.", "There is one widget.", "There is a bling widget and one other widget.", "There is a bling widget and 2 other widgets.", "There is a bling widget and 3 other widgets.", "Widgets, five (5-1=4) there be.", "There is a bling widget and 5 other widgets.", "There is a bling widget and 6 other widgets."]
    var pluralStyle: String = "offset:1.0 " + "=0 {There are no widgets.} " + "=1.0 {There is one widget.} " + "=5 {Widgets, five (5-1=#) there be.} " + "one {There is a bling widget and one other widget.} " + "other {There is a bling widget and # other widgets.}"
    var pf: PluralFormat = PluralFormat(UCultureInfo("en"), pluralStyle)
    var mf: MessageFormat = MessageFormat("{0,plural," + pluralStyle + "}", UCultureInfo("en"))
    var args: Integer[] = seq[Integer]
      var i: int = 0
      while i <= 7:
          var result: String = pf.Format(i)
assertEquals("PluralFormat.format(value " + i + ")", targets[i], result)
          args[0] = i
          result = mf.Format(args)
assertEquals("MessageFormat.format(value " + i + ")", targets[i], result)
++i
pf.ApplyPattern("other{zz}other{yy}one{xx}one{ww}=1{vv}=1{uu}")
assertEquals("should find first matching *explicit* value", "vv", pf.Format(1))
proc TestExtendedPluralFormatParsing*() =
    var failures: String[] = @["offset:1..0 =0 {Foo}", "offset:1.0 {Foo}", "=0= {Foo}", "=0 {Foo} =0.0 {Bar}", " = {Foo}"]
    for fmt in failures:
        try:
PluralFormat(fmt)
fail("expected exception when parsing '" + fmt + "'")
        except ArgumentException:

proc TestOrdinalFormat*() =
    var pattern: String = "one{#st file}two{#nd file}few{#rd file}other{#th file}"
    var pf: PluralFormat = PluralFormat(UCultureInfo("en"), PluralType.Ordinal, pattern)
assertEquals("PluralFormat.format(321)", "321st file", pf.Format(321))
assertEquals("PluralFormat.format(22)", "22nd file", pf.Format(22))
assertEquals("PluralFormat.format(3)", "3rd file", pf.Format(3))
    pf = PluralFormat(UCultureInfo("en"), PluralType.Ordinal)
pf.ApplyPattern(pattern)
assertEquals("PluralFormat.format(456)", "456th file", pf.Format(456))
assertEquals("PluralFormat.format(111)", "111th file", pf.Format(111))
    pf = PluralFormat(CultureInfo("en"), PluralType.Ordinal)
pf.ApplyPattern(pattern)
assertEquals("PluralFormat.format(456)", "456th file", pf.Format(456))
assertEquals("PluralFormat.format(111)", "111th file", pf.Format(111))
proc TestDecimals*() =
    var pf: PluralFormat = PluralFormat(UCultureInfo("en"), "one{one meter}other{# meters}")
assertEquals("simple format(1)", "one meter", pf.Format(1))
assertEquals("simple format(1.5)", "1.5 meters", pf.Format(1.5))
    var pf2: PluralFormat = PluralFormat(UCultureInfo("en"), "offset:1 one{another meter}other{another # meters}")
pf2.SetNumberFormat(DecimalFormat("0.0", DecimalFormatSymbols(UCultureInfo("en"))))
assertEquals("offset-decimals format(1)", "another 0.0 meters", pf2.Format(1))
assertEquals("offset-decimals format(2)", "another 1.0 meters", pf2.Format(2))
assertEquals("offset-decimals format(2.5)", "another 1.5 meters", pf2.Format(2.5))
proc TestNegative*() =
    var pluralFormat: PluralFormat = PluralFormat(UCultureInfo("en"), "one{# foot}other{# feet}")
    var actual: String = pluralFormat.Format(-3)
assertEquals(pluralFormat.ToString, "-3 feet", actual)