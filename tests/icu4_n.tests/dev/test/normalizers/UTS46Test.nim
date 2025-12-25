# "Namespace: ICU4N.Dev.Test.Normalizers"
type
  UTS46Test = ref object
    errorNamesToErrors: IDictionary[string, IDNAErrors] = SortedDictionary<string, IDNAErrors>(StringComparer.Ordinal)
    testCases: seq[string] = @[@["www.eXample.cOm", "B", "www.example.com", ""], @["Bücher.de", "B", "bücher.de", ""], @["ÖBB", "B", "öbb", ""], @["faß.de", "N", "faß.de", ""], @["faß.de", "T", "fass.de", ""], @["XN--fA-hia.dE", "B", "faß.de", ""], @["βόλος.com", "N", "βόλος.com", ""], @["βόλος.com", "T", "βόλοσ.com", ""], @["xn--nxasmm1c", "B", "βόλος", ""], @["www.ශ්‍රී.com", "N", "www.ශ්‍රී.com", ""], @["www.ශ්‍රී.com", "T", "www.ශ්රී.com", ""], @["www.xn--10cl1a0b660p.com", "B", "www.ශ්‍රී.com", ""], @["نامه‌ای", "N", "نامه‌ای", ""], @["نامه‌ای", "T", "نامهای", ""], @["xn--mgba3gch31f060k.com", "B", "نامه‌ای.com", ""], @["a.b．c。d｡", "B", "a.b.c.d.", ""], @["Ü.xn--tda", "B", "ü.ü", ""], @["xn--u-ccb", "B", "xn--u-ccb�", "UIDNA_ERROR_INVALID_ACE_LABEL"], @["a⒈com", "B", "a�com", "UIDNA_ERROR_DISALLOWED"], @["xn--a-ecp.ru", "B", "xn--a-ecp�.ru", "UIDNA_ERROR_INVALID_ACE_LABEL"], @["xn--0.pt", "B", "xn--0�.pt", "UIDNA_ERROR_PUNYCODE"], @["xn--a.pt", "B", "xn--a�.pt", "UIDNA_ERROR_INVALID_ACE_LABEL"], @["xn--a-Ä.pt", "B", "xn--a-ä.pt", "UIDNA_ERROR_PUNYCODE"], @["日本語。ＪＰ", "B", "日本語.jp", ""], @["☕", "B", "☕", ""], @["a≠b≮c≯d", "B", "a�b�c�d", "UIDNA_ERROR_DISALLOWED"], @["1.aß‌‍b‌‍cßßßßd" + "ςσßßßßßßßße" + "ßßßßßßßßßßx" + "ßßßßßßßßßßy" + "ßßßßßßßß̂ßz", "N", "1.aß‌‍b‌‍cßßßßd" + "ςσßßßßßßßße" + "ßßßßßßßßßßx" + "ßßßßßßßßßßy" + "ßßßßßßßß̂ßz", "UIDNA_ERROR_LABEL_TOO_LONG|UIDNA_ERROR_CONTEXTJ"], @["1.aß‌‍b‌‍cßßßßd" + "ςσßßßßßßßße" + "ßßßßßßßßßßx" + "ßßßßßßßßßßy" + "ßßßßßßßß̂ßz", "T", "1.assbcssssssssd" + "σσsssssssssssssssse" + "ssssssssssssssssssssx" + "ssssssssssssssssssssy" + "sssssssssssssssŝssz", "UIDNA_ERROR_LABEL_TOO_LONG"], @["‌x‍n‌-‍-bß", "N", "‌x‍n‌-‍-bß", "UIDNA_ERROR_CONTEXTJ"], @["‌x‍n‌-‍-bß", "T", "夙", ""], @["ˣ͏ℕ​﹣­－᠌" + "ℬ︀ſ⁤" + "𝔰󠇯" + "ﬄ", "B", "夡夞夜夙", ""], @["123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901", "B", "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901", ""], @["123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901.", "B", "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901.", ""], @["123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "12345678901234567890123456789012345678901234567890123456789012", "B", "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "12345678901234567890123456789012345678901234567890123456789012", "UIDNA_ERROR_DOMAIN_NAME_TOO_LONG"], @["123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789א", "B", "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789א", "UIDNA_ERROR_DOMAIN_NAME_TOO_LONG|UIDNA_ERROR_BIDI"], @["123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901234." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890", "B", "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901234." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890", "UIDNA_ERROR_LABEL_TOO_LONG"], @["123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901234." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890.", "B", "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901234." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890.", "UIDNA_ERROR_LABEL_TOO_LONG"], @["123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901234." + "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901", "B", "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901234." + "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901", "UIDNA_ERROR_LABEL_TOO_LONG|UIDNA_ERROR_DOMAIN_NAME_TOO_LONG"], @["ä1234567890123456789012345678901234567890123456789012345", "B", "ä1234567890123456789012345678901234567890123456789012345", ""], @["1234567890ä1234567890123456789012345678901234567890123456", "B", "1234567890ä1234567890123456789012345678901234567890123456", "UIDNA_ERROR_LABEL_TOO_LONG"], @["123456789012345678901234567890123456789012345678901234567890123." + "1234567890ä123456789012345678901234567890123456789012345." + "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901", "B", "123456789012345678901234567890123456789012345678901234567890123." + "1234567890ä123456789012345678901234567890123456789012345." + "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901", ""], @["123456789012345678901234567890123456789012345678901234567890123." + "1234567890ä123456789012345678901234567890123456789012345." + "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901.", "B", "123456789012345678901234567890123456789012345678901234567890123." + "1234567890ä123456789012345678901234567890123456789012345." + "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901.", ""], @["123456789012345678901234567890123456789012345678901234567890123." + "1234567890ä123456789012345678901234567890123456789012345." + "123456789012345678901234567890123456789012345678901234567890123." + "12345678901234567890123456789012345678901234567890123456789012", "B", "123456789012345678901234567890123456789012345678901234567890123." + "1234567890ä123456789012345678901234567890123456789012345." + "123456789012345678901234567890123456789012345678901234567890123." + "12345678901234567890123456789012345678901234567890123456789012", "UIDNA_ERROR_DOMAIN_NAME_TOO_LONG"], @["123456789012345678901234567890123456789012345678901234567890123." + "1234567890ä1234567890123456789012345678901234567890123456." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890", "B", "123456789012345678901234567890123456789012345678901234567890123." + "1234567890ä1234567890123456789012345678901234567890123456." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890", "UIDNA_ERROR_LABEL_TOO_LONG"], @["123456789012345678901234567890123456789012345678901234567890123." + "1234567890ä1234567890123456789012345678901234567890123456." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890.", "B", "123456789012345678901234567890123456789012345678901234567890123." + "1234567890ä1234567890123456789012345678901234567890123456." + "123456789012345678901234567890123456789012345678901234567890123." + "123456789012345678901234567890123456789012345678901234567890.", "UIDNA_ERROR_LABEL_TOO_LONG"], @["123456789012345678901234567890123456789012345678901234567890123." + "1234567890ä1234567890123456789012345678901234567890123456." + "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901", "B", "123456789012345678901234567890123456789012345678901234567890123." + "1234567890ä1234567890123456789012345678901234567890123456." + "123456789012345678901234567890123456789012345678901234567890123." + "1234567890123456789012345678901234567890123456789012345678901", "UIDNA_ERROR_LABEL_TOO_LONG|UIDNA_ERROR_DOMAIN_NAME_TOO_LONG"], @[".", "B", ".", "UIDNA_ERROR_EMPTY_LABEL"], @["．", "B", ".", "UIDNA_ERROR_EMPTY_LABEL"], @["a.b..-q--a-.e", "B", "a.b..-q--a-.e", "UIDNA_ERROR_EMPTY_LABEL|UIDNA_ERROR_LEADING_HYPHEN|UIDNA_ERROR_TRAILING_HYPHEN|" + "UIDNA_ERROR_HYPHEN_3_4"], @["a.b..-q--ä-.e", "B", "a.b..-q--ä-.e", "UIDNA_ERROR_EMPTY_LABEL|UIDNA_ERROR_LEADING_HYPHEN|UIDNA_ERROR_TRAILING_HYPHEN|" + "UIDNA_ERROR_HYPHEN_3_4"], @["a.b..xn---q----jra.e", "B", "a.b..-q--ä-.e", "UIDNA_ERROR_EMPTY_LABEL|UIDNA_ERROR_LEADING_HYPHEN|UIDNA_ERROR_TRAILING_HYPHEN|" + "UIDNA_ERROR_HYPHEN_3_4"], @["a..c", "B", "a..c", "UIDNA_ERROR_EMPTY_LABEL"], @["a.xn--.c", "B", "a..c", "UIDNA_ERROR_EMPTY_LABEL"], @["a.-b.", "B", "a.-b.", "UIDNA_ERROR_LEADING_HYPHEN"], @["a.b-.c", "B", "a.b-.c", "UIDNA_ERROR_TRAILING_HYPHEN"], @["a.-.c", "B", "a.-.c", "UIDNA_ERROR_LEADING_HYPHEN|UIDNA_ERROR_TRAILING_HYPHEN"], @["a.bc--de.f", "B", "a.bc--de.f", "UIDNA_ERROR_HYPHEN_3_4"], @["ä.­.c", "B", "ä..c", "UIDNA_ERROR_EMPTY_LABEL"], @["ä.xn--.c", "B", "ä..c", "UIDNA_ERROR_EMPTY_LABEL"], @["ä.-b.", "B", "ä.-b.", "UIDNA_ERROR_LEADING_HYPHEN"], @["ä.b-.c", "B", "ä.b-.c", "UIDNA_ERROR_TRAILING_HYPHEN"], @["ä.-.c", "B", "ä.-.c", "UIDNA_ERROR_LEADING_HYPHEN|UIDNA_ERROR_TRAILING_HYPHEN"], @["ä.bc--de.f", "B", "ä.bc--de.f", "UIDNA_ERROR_HYPHEN_3_4"], @["a.b.̈c.d", "B", "a.b.�c.d", "UIDNA_ERROR_LEADING_COMBINING_MARK"], @["a.b.xn--c-bcb.d", "B", "a.b.xn--c-bcb�.d", "UIDNA_ERROR_LEADING_COMBINING_MARK|UIDNA_ERROR_INVALID_ACE_LABEL"], @["A0", "B", "a0", ""], @["0A", "B", "0a", ""], @["0A.א", "B", "0a.א", "UIDNA_ERROR_BIDI"], @["c.xn--0-eha.xn--4db", "B", "c.0ü.א", "UIDNA_ERROR_BIDI"], @["b-.א", "B", "b-.א", "UIDNA_ERROR_TRAILING_HYPHEN|UIDNA_ERROR_BIDI"], @["d.xn----dha.xn--4db", "B", "d.ü-.א", "UIDNA_ERROR_TRAILING_HYPHEN|UIDNA_ERROR_BIDI"], @["aא", "B", "aא", "UIDNA_ERROR_BIDI"], @["אׇ", "B", "אׇ", ""], @["א9ׇ", "B", "א9ׇ", ""], @["אaׇ", "B", "אaׇ", "UIDNA_ERROR_BIDI"], @["את", "B", "את", ""], @["א׳ת", "B", "א׳ת", ""], @["aאTz", "B", "aאtz", "UIDNA_ERROR_BIDI"], @["אTת", "B", "אtת", "UIDNA_ERROR_BIDI"], @["א7ת", "B", "א7ת", ""], @["א٧ת", "B", "א٧ת", ""], @["a7٧z", "B", "a7٧z", "UIDNA_ERROR_BIDI"], @["a7٧", "B", "a7٧", "UIDNA_ERROR_BIDI"], @["א7٧ת", "B", "א7٧ת", "UIDNA_ERROR_BIDI"], @["א7٧", "B", "א7٧", "UIDNA_ERROR_BIDI"], @["ஹ்‍", "N", "ஹ்‍", ""], @["ஹ‍", "N", "ஹ‍", "UIDNA_ERROR_CONTEXTJ"], @["‍", "N", "‍", "UIDNA_ERROR_CONTEXTJ"], @["ஹ்‌", "N", "ஹ்‌", ""], @["ஹ‌", "N", "ஹ‌", "UIDNA_ERROR_CONTEXTJ"], @["‌", "N", "‌", "UIDNA_ERROR_CONTEXTJ"], @["لٰ‌ۭۯ", "N", "لٰ‌ۭۯ", ""], @["لٰ‌ۯ", "N", "لٰ‌ۯ", ""], @["ل‌ۭۯ", "N", "ل‌ۭۯ", ""], @["ل‌ۯ", "N", "ل‌ۯ", ""], @["لٰ‌ۭ", "N", "لٰ‌ۭ", "UIDNA_ERROR_BIDI|UIDNA_ERROR_CONTEXTJ"], @["ۯ‌ۯ", "N", "ۯ‌ۯ", "UIDNA_ERROR_CONTEXTJ"], @["ل‌", "N", "ل‌", "UIDNA_ERROR_BIDI|UIDNA_ERROR_CONTEXTJ"], @["٠١", "B", "٠١", "UIDNA_ERROR_BIDI"], @["۰۱", "B", "۰۱", ""], @["٠۱", "B", "٠۱", "UIDNA_ERROR_CONTEXTO_DIGITS|UIDNA_ERROR_BIDI"], @["l·l一͵αא׳״・", "B", "l·l一͵αא׳״・", "UIDNA_ERROR_BIDI"], @["l·", "B", "l·", "UIDNA_ERROR_CONTEXTO_PUNCTUATION"], @["·l", "B", "·l", "UIDNA_ERROR_CONTEXTO_PUNCTUATION"], @["͵", "B", "͵", "UIDNA_ERROR_CONTEXTO_PUNCTUATION"], @["α׳", "B", "α׳", "UIDNA_ERROR_CONTEXTO_PUNCTUATION|UIDNA_ERROR_BIDI"], @["״", "B", "״", "UIDNA_ERROR_CONTEXTO_PUNCTUATION"], @["l・", "B", "l・", "UIDNA_ERROR_CONTEXTO_PUNCTUATION"]]
    trans: IDNA
    severeErrors: IDNAErrors = IDNAErrors.LeadingCombiningMark | IDNAErrors.Disallowed | IDNAErrors.Punycode | IDNAErrors.LabelHasDot | IDNAErrors.InvalidAceLabel
    lengthOverflowErrors: IDNAErrors = IDNAErrors.LabelTooLong | IDNAErrors.DomainNameTooLong

proc newUTS46Test(): UTS46Test =
  var commonOptions: UTS46Options = UTS46Options.UseSTD3Rules | UTS46Options.CheckBiDi | UTS46Options.CheckContextJ | UTS46Options.CheckContextO
  trans = IDNA.GetUTS46Instance(commonOptions)
  nontrans = IDNA.GetUTS46Instance(commonOptions | UTS46Options.NontransitionalToASCII | UTS46Options.NontransitionalToUnicode)
proc TestAPI*() =
    var result: ValueStringBuilder = ValueStringBuilder(newSeq[char](32))
    try:
        var resultSpan: Span<char> = newSeq[char](32)
        var input: String = "www.eXample.cOm"
        var expected: String = "www.example.com"
        if !trans.TryNameToASCII(input, result,         var info: IDNAInfo) || info.HasErrors || !UTF16Plus.Equal(result.AsSpan, expected.AsSpan):
Errln(String.Format(StringFormatter.CurrentCulture, "T.TryNameToASCII(www.example.com) info.errors={0} result matches={1}", info.Errors, UTF16Plus.Equal(result.AsSpan, expected.AsSpan)))
        if !trans.TryNameToASCII(input, resultSpan,         var charsLength: int, info) || info.HasErrors || !UTF16Plus.Equal(resultSpan.Slice(0, charsLength), expected.AsSpan):
Errln(String.Format(StringFormatter.CurrentCulture, "T.TryNameToASCII(www.example.com) info.errors={0} result matches={1}", info.Errors, UTF16Plus.Equal(result.AsSpan, expected.AsSpan)))
        input = "xn--bcher.de-65a"
        expected = "xn--bcher�de-65a"
        result.Length = 0
nontrans.TryLabelToASCII(input, result, info)
        if !sameErrors(info.Errors, IDNAErrors.LabelHasDot | IDNAErrors.InvalidAceLabel) || !UTF16Plus.Equal(result.AsSpan, expected.AsSpan):
Errln(String.Format(StringFormatter.CurrentCulture, "N.LabelToASCII(label-with-dot) failed with errors {0}", info.Errors))
nontrans.TryLabelToASCII(input, resultSpan, charsLength, info)
        if !sameErrors(info.Errors, IDNAErrors.LabelHasDot | IDNAErrors.InvalidAceLabel) || !UTF16Plus.Equal(resultSpan.Slice(0, charsLength), expected.AsSpan):
Errln(String.Format(StringFormatter.CurrentCulture, "N.TryLabelToASCII(label-with-dot) failed with errors {0}", info.Errors))
        result.Length = 0
        var success: bool = trans.TryNameToUnicode("fAß.de", result, info)
        var resultString: string = result.ToString
        if !success || info.HasErrors || !resultString.Equals("fass.de"):
Errln(String.Format(StringFormatter.CurrentCulture, "T.NameToUnicode(fAß.de) info.errors={0} result matches={1}", info.Errors, resultString.Equals("fass.de")))
        if !trans.TryNameToUnicode("fAß.de", resultSpan, charsLength, info) || info.HasErrors || !UTF16Plus.Equal(resultSpan.Slice(0, charsLength), "fass.de"):
Errln(String.Format(StringFormatter.CurrentCulture, "T.TryNameToUnicode(fAß.de) info.errors={0} result matches={1}", info.Errors, resultString.Equals("fass.de")))
        try:
nontrans.TryLabelToUnicode(resultSpan, resultSpan, _, _)
Errln("N.labelToUnicode(result, result) did not throw an Exception")
        except Exception:

        try:
nontrans.TryLabelToUnicode(result.AsSpan, result, _)
Errln("N.labelToUnicode(result, result) did not throw an Exception")
        except Exception:

    finally:
result.Dispose
proc TestNotSTD3*() =
    var not3: IDNA = IDNA.GetUTS46Instance(UTS46Options.CheckBiDi)
    var input: String = " A_2+2=4
.eßen.net"
    var resultSpan: Span<char> = newSeq[char](64)
    var result: ValueStringBuilder = ValueStringBuilder(newSeq[char](64))
    try:
not3.TryNameToUnicode(input, result,         var info: IDNAInfo)
        if !UTF16Plus.Equal(result.AsSpan, " a_2+2=4
.essen.net") || info.HasErrors:
Errln(String.Format(StringFormatter.CurrentCulture, "notSTD3.TryNameToUnicode(non-LDH ASCII) unexpected errors {0} string {1}", info.Errors, Prettify(result.AsSpan)))
not3.TryNameToUnicode(input, resultSpan,         var charsLength: int, info)
        if !UTF16Plus.Equal(resultSpan.Slice(0, charsLength), " a_2+2=4
.essen.net") || info.HasErrors:
Errln(String.Format(StringFormatter.CurrentCulture, "notSTD3.TryNameToUnicode(non-LDH ASCII) unexpected errors {0} string {1}", info.Errors, Prettify(resultSpan.Slice(0, charsLength))))
        input = "a z.xn--4db.edu"
        result.Length = 0
not3.TryNameToASCII(input, result, info)
        if !UTF16Plus.Equal(result.AsSpan, input.AsSpan) || !sameErrors(info.Errors, IDNAErrors.BiDi):
Errln("notSTD3.TryNameToASCII(ASCII-with-space.alef.edu) failed")
not3.TryNameToASCII(input, resultSpan, charsLength, info)
        if !UTF16Plus.Equal(resultSpan.Slice(0, charsLength), input.AsSpan) || !sameErrors(info.Errors, IDNAErrors.BiDi):
Errln("notSTD3.TryNameToASCII(ASCII-with-space.alef.edu) failed")
        input = "a≠b≮c≯d"
        result.Length = 0
not3.TryNameToUnicode(input, result, info)
        if !UTF16Plus.Equal(result.AsSpan, input.AsSpan) || info.HasErrors:
Errln(String.Format(StringFormatter.CurrentCulture, "notSTD3.TryNameToUnicode(equiv to non-LDH ASCII) unexpected errors {0} string {1}", info.Errors, Prettify(result.AsSpan)))
        if !not3.TryNameToUnicode(input, resultSpan, charsLength, info) || !UTF16Plus.Equal(resultSpan.Slice(0, charsLength), input.AsSpan) || info.HasErrors:
Errln(String.Format(StringFormatter.CurrentCulture, "notSTD3.TryNameToUnicode(equiv to non-LDH ASCII) unexpected errors {0} string {1}", info.Errors, Prettify(resultSpan.Slice(0, charsLength))))
    finally:
result.Dispose
type
  TestCase = ref object
    s: string
    u: string
    errors: IDNAErrors

proc newTestCase(): TestCase =
  errors = IDNAErrors.None
proc Set(data: seq[string]) =
    s = data[0]
    o = data[1]
    u = data[2]
    errors = IDNAErrors.None
    if data[3].Length != 0:
        for e in Regex.Split(data[3], "\|"):
            errors = errorNamesToErrors.Get(e)
proc TestSomeCases*() =
    var StackBufferSize: int = 512
      var aTBuf: Span<char> = newSeq[char](StackBufferSize)
      var uTBuf: Span<char> = newSeq[char](StackBufferSize)
      var aNBuf: Span<char> = newSeq[char](StackBufferSize)
      var uNBuf: Span<char> = newSeq[char](StackBufferSize)
      var aT: ReadOnlySpan<char>
      var uT: ReadOnlySpan<char>
      var aN: ReadOnlySpan<char>
      var uN: ReadOnlySpan<char>
      var aTInfo: IDNAInfo
      var uTInfo: IDNAInfo
      var aNInfo: IDNAInfo
      var uNInfo: IDNAInfo
      var aTuNBuf: Span<char> = newSeq[char](StackBufferSize)
      var uTaNBuf: Span<char> = newSeq[char](StackBufferSize)
      var aNuNBuf: Span<char> = newSeq[char](StackBufferSize)
      var uNaNBuf: Span<char> = newSeq[char](StackBufferSize)
      var aTuN: ReadOnlySpan<char>
      var uTaN: ReadOnlySpan<char>
      var aNuN: ReadOnlySpan<char>
      var uNaN: ReadOnlySpan<char>
      var aTuNInfo: IDNAInfo
      var uTaNInfo: IDNAInfo
      var aNuNInfo: IDNAInfo
      var uNaNInfo: IDNAInfo
      var aTLBuf: Span<char> = newSeq[char](StackBufferSize)
      var uTLBuf: Span<char> = newSeq[char](StackBufferSize)
      var aNLBuf: Span<char> = newSeq[char](StackBufferSize)
      var uNLBuf: Span<char> = newSeq[char](StackBufferSize)
      var aTL: ReadOnlySpan<char>
      var uTL: ReadOnlySpan<char>
      var aNL: ReadOnlySpan<char>
      var uNL: ReadOnlySpan<char>
      var aTLInfo: IDNAInfo
      var uTLInfo: IDNAInfo
      var aNLInfo: IDNAInfo
      var uNLInfo: IDNAInfo
    var uniErrors: IDNAErrors
    var charsLength: int
    try:
        var testCase: TestCase = TestCase
        var i: int
          i = 0
          while i < testCases.Length:
testCase.Set(testCases[i])
              var input: String = testCase.s
              var expected: String = testCase.u
              try:
                    # "# Note: C# unsafe block - contains pointer operations"
trans.TryNameToASCII(input, aTBuf, charsLength, aTInfo)
                      aT = aTBuf.Slice(0, charsLength)
trans.TryNameToUnicode(input, uTBuf, charsLength, uTInfo)
                      uT = uTBuf.Slice(0, charsLength)
nontrans.TryNameToASCII(input, aNBuf, charsLength, aNInfo)
                      aN = aNBuf.Slice(0, charsLength)
nontrans.TryNameToUnicode(input, uNBuf, charsLength, uNInfo)
                      uN = uNBuf.Slice(0, charsLength)
              except Exception:
Errln(String.Format("first-level processing [{0}/{1}] {2} - {3}", i, testCase.o, testCase.s, e))
                  continue
              uniErrors = testCase.errors & ~lengthOverflowErrors
              var mode: char = testCase.o[0]
              if mode == 'B' || mode == 'N':
                  if !sameErrors(uNInfo, uniErrors):
Errln(String.Format(StringFormatter.CurrentCulture, "N.nameToUnicode([{0}] {1}) unexpected errors {2}", i, testCase.s, uNInfo.Errors))
                      continue
                  if !UTF16Plus.Equal(uN, expected):
Errln(String.Format("N.nameToUnicode([{0}] {1}) unexpected string {2}", i, testCase.s, Prettify(uN)))
                      continue
                  if !sameErrors(aNInfo, testCase.errors):
Errln(String.Format("N.nameToASCII([{0}] {1}) unexpected errors {2}", i, testCase.s, aNInfo.Errors))
                      continue
              if mode == 'B' || mode == 'T':
                  if !sameErrors(uTInfo, uniErrors):
Errln(String.Format("T.nameToUnicode([{0}] {1}) unexpected errors {2}", i, testCase.s, uTInfo.Errors))
                      continue
                  if !UTF16Plus.Equal(uT, expected):
Errln(String.Format("T.nameToUnicode([{0}] {1}) unexpected string {2}", i, testCase.s, Prettify(uT)))
                      continue
                  if !sameErrors(aTInfo, testCase.errors):
Errln(String.Format("T.nameToASCII([{0}] {1}) unexpected errors {2}", i, testCase.s, aTInfo.Errors))
                      continue
              if !hasCertainErrors(aNInfo, severeErrors) && !IsASCII(aN):
Errln(String.Format("N.nameToASCII([{0}] {1}) (errors {2}) result is not ASCII {3}", i, testCase.s, aNInfo.Errors, Prettify(aN)))
                  continue
              if !hasCertainErrors(aTInfo, severeErrors) && !IsASCII(aT):
Errln(String.Format("T.nameToASCII([{0}] {1}) (errors {2}) result is not ASCII {3}", i, testCase.s, aTInfo.Errors, Prettify(aT)))
                  continue
              if IsVerbose:
                  var m: char =                   if mode == 'B':
mode
                  else:
'N'
Logln(String.Format("{0}.nameToASCII([{1}] {2}) (errors {3}) result string: {4}", m, i, testCase.s, aNInfo.Errors, Prettify(aN)))
                  if mode != 'B':
Logln(String.Format("T.nameToASCII([{0}] {1}) (errors {2}) result string: {3}", i, testCase.s, aTInfo.Errors, Prettify(aT)))
              try:
                    # "# Note: C# unsafe block - contains pointer operations"
nontrans.TryNameToUnicode(aT, aTuNBuf, charsLength, aTuNInfo)
                      aTuN = aTuNBuf.Slice(0, charsLength)
nontrans.TryNameToASCII(uT, uTaNBuf, charsLength, uTaNInfo)
                      uTaN = uTaNBuf.Slice(0, charsLength)
nontrans.TryNameToUnicode(aN, aNuNBuf, charsLength, aNuNInfo)
                      aNuN = aNuNBuf.Slice(0, charsLength)
nontrans.TryNameToASCII(uN, uNaNBuf, charsLength, uNaNInfo)
                      uNaN = uNaNBuf.Slice(0, charsLength)
              except Exception:
Errln(String.Format("second-level processing [{0}/{1}] {2} - {3}", i, testCase.o, testCase.s, e))
                  continue
              if !UTF16Plus.Equal(aN, uNaN):
Errln(String.Format(StringFormatter.CurrentCulture, "N.nameToASCII([{0}] {1})!=N.nameToUnicode().N.nameToASCII() " + "(errors {2}) {3} vs. {4}", i, testCase.s, aNInfo.Errors, Prettify(aN), Prettify(uNaN)))
                  continue
              if !UTF16Plus.Equal(aT, uTaN):
Errln(String.Format(StringFormatter.CurrentCulture, "T.nameToASCII([{0}] {1})!=T.nameToUnicode().N.nameToASCII() " + "(errors {2}) {3} vs. {4}", i, testCase.s, aNInfo.Errors, Prettify(aT), Prettify(uTaN)))
                  continue
              if !UTF16Plus.Equal(uN, aNuN):
Errln(String.Format(StringFormatter.CurrentCulture, "N.nameToUnicode([{0}] {1})!=N.nameToASCII().N.nameToUnicode() " + "(errors {2}) {3} vs. {4}", i, testCase.s, uNInfo.Errors, Prettify(uN), Prettify(aNuN)))
                  continue
              if !UTF16Plus.Equal(uT, aTuN):
Errln(String.Format(StringFormatter.CurrentCulture, "T.nameToUnicode([{0}] {1})!=T.nameToASCII().N.nameToUnicode() " + "(errors {2}) {3} vs. {4}", i, testCase.s, uNInfo.Errors, Prettify(uT), Prettify(aTuN)))
                  continue
              try:
                    # "# Note: C# unsafe block - contains pointer operations"
trans.TryLabelToASCII(input, aTLBuf, charsLength, aTLInfo)
                      aTL = aTLBuf.Slice(0, charsLength)
trans.TryLabelToUnicode(input, uTLBuf, charsLength, uTLInfo)
                      uTL = uTLBuf.Slice(0, charsLength)
nontrans.TryLabelToASCII(input, aNLBuf, charsLength, aNLInfo)
                      aNL = aNLBuf.Slice(0, charsLength)
nontrans.TryLabelToUnicode(input, uNLBuf, charsLength, uNLInfo)
                      uNL = uNLBuf.Slice(0, charsLength)
              except Exception:
Errln(String.Format("labelToXYZ processing [{0}/{1}] {2} - {3}", i, testCase.o, testCase.s, e))
                  continue
              if aN.IndexOf(".", StringComparison.Ordinal) < 0:
                  if !UTF16Plus.Equal(aN, aNL) || !sameErrors(aNInfo, aNLInfo):
Errln(String.Format(StringFormatter.CurrentCulture, "N.nameToASCII([{0}] {1})!=N.labelToASCII() " + "(errors {2} vs {3}) {4} vs. {5}", i, testCase.s, aNInfo.Errors, aNLInfo.Errors, Prettify(aN), Prettify(aNL)))
                      continue
              else:
                  if !hasError(aNLInfo, IDNAErrors.LabelHasDot):
Errln(String.Format(StringFormatter.CurrentCulture, "N.labelToASCII([{0}] {1}) errors {2} missing UIDNA_ERROR_LABEL_HAS_DOT", i, testCase.s, aNLInfo.Errors))
                      continue
              if aT.IndexOf(".", StringComparison.Ordinal) < 0:
                  if !UTF16Plus.Equal(aT, aTL) || !sameErrors(aTInfo, aTLInfo):
Errln(String.Format(StringFormatter.CurrentCulture, "T.nameToASCII([{0}] {1})!=T.labelToASCII() " + "(errors {2} vs {3}) {4} vs. {5}", i, testCase.s, aTInfo.Errors, aTLInfo.Errors, Prettify(aT), Prettify(aTL)))
                      continue
              else:
                  if !hasError(aTLInfo, IDNAErrors.LabelHasDot):
Errln(String.Format(StringFormatter.CurrentCulture, "T.labelToASCII([{0}] {1}) errors {2} missing UIDNA_ERROR_LABEL_HAS_DOT", i, testCase.s, aTLInfo.Errors))
                      continue
              if uN.IndexOf(".", StringComparison.Ordinal) < 0:
                  if !UTF16Plus.Equal(uN, uNL) || !sameErrors(uNInfo, uNLInfo):
Errln(String.Format(StringFormatter.CurrentCulture, "N.nameToUnicode([{0}] {1})!=N.labelToUnicode() " + "(errors {2} vs {3}) {4} vs. {5}", i, testCase.s, uNInfo.Errors, uNLInfo.Errors, Prettify(uN), Prettify(uNL)))
                      continue
              else:
                  if !hasError(uNLInfo, IDNAErrors.LabelHasDot):
Errln(String.Format(StringFormatter.CurrentCulture, "N.labelToUnicode([{0}] {1}) errors {2} missing UIDNA_ERROR_LABEL_HAS_DOT", i, testCase.s, uNLInfo.Errors))
                      continue
              if uT.IndexOf(".", StringComparison.Ordinal) < 0:
                  if !UTF16Plus.Equal(uT, uTL) || !sameErrors(uTInfo, uTLInfo):
Errln(String.Format(StringFormatter.CurrentCulture, "T.nameToUnicode([{0}] {1})!=T.labelToUnicode() " + "(errors {2} vs {3}) {4} vs. {5}", i, testCase.s, uTInfo.Errors, uTLInfo.Errors, Prettify(uT), Prettify(uTL)))
                      continue
              else:
                  if !hasError(uTLInfo, IDNAErrors.LabelHasDot):
Errln(String.Format(StringFormatter.CurrentCulture, "T.labelToUnicode([{0}] {1}) errors {2} missing UIDNA_ERROR_LABEL_HAS_DOT", i, testCase.s, uTLInfo.Errors))
                      continue
              if mode == 'B':
                  if aNInfo.IsTransitionalDifferent || aTInfo.IsTransitionalDifferent || uNInfo.IsTransitionalDifferent || uTInfo.IsTransitionalDifferent || aNLInfo.IsTransitionalDifferent || aTLInfo.IsTransitionalDifferent || uNLInfo.IsTransitionalDifferent || uTLInfo.IsTransitionalDifferent:
Errln(String.Format("B.process([{0}] {1}) isTransitionalDifferent()", i, testCase.s))
                      continue
                  if !UTF16Plus.Equal(aN, aT) || !UTF16Plus.Equal(uN, uT) || !UTF16Plus.Equal(aNL, aTL) || !UTF16Plus.Equal(uNL, uTL) || !sameErrors(aNInfo, aTInfo) || !sameErrors(uNInfo, uTInfo) || !sameErrors(aNLInfo, aTLInfo) || !sameErrors(uNLInfo, uTLInfo):
Errln(String.Format("N.process([{0}] {1}) vs. T.process() different errors or result strings", i, testCase.s))
                      continue
              else:
                  if !aNInfo.IsTransitionalDifferent || !aTInfo.IsTransitionalDifferent || !uNInfo.IsTransitionalDifferent || !uTInfo.IsTransitionalDifferent || !aNLInfo.IsTransitionalDifferent || !aTLInfo.IsTransitionalDifferent || !uNLInfo.IsTransitionalDifferent || !uTLInfo.IsTransitionalDifferent:
Errln(String.Format("{0}.process([{1}] {2}) !isTransitionalDifferent()", testCase.o, i, testCase.s))
                      continue
                  if UTF16Plus.Equal(aN, aT) || UTF16Plus.Equal(uN, uT) || UTF16Plus.Equal(aNL, aTL) || UTF16Plus.Equal(uNL, uTL):
Errln(String.Format("N.process([{0}] {1}) vs. T.process() same result strings", i, testCase.s))
                      continue
++i
    finally:

proc TestSomeCases2*() =
    var StackBufferSize: int = 32
      var aT: ValueStringBuilder = ValueStringBuilder(newSeq[char](StackBufferSize))
      var uT: ValueStringBuilder = ValueStringBuilder(newSeq[char](StackBufferSize))
      var aN: ValueStringBuilder = ValueStringBuilder(newSeq[char](StackBufferSize))
      var uN: ValueStringBuilder = ValueStringBuilder(newSeq[char](StackBufferSize))
      var aTInfo: IDNAInfo
      var uTInfo: IDNAInfo
      var aNInfo: IDNAInfo
      var uNInfo: IDNAInfo
      var aTuN: ValueStringBuilder = ValueStringBuilder(newSeq[char](StackBufferSize))
      var uTaN: ValueStringBuilder = ValueStringBuilder(newSeq[char](StackBufferSize))
      var aNuN: ValueStringBuilder = ValueStringBuilder(newSeq[char](StackBufferSize))
      var uNaN: ValueStringBuilder = ValueStringBuilder(newSeq[char](StackBufferSize))
      var aTuNInfo: IDNAInfo
      var uTaNInfo: IDNAInfo
      var aNuNInfo: IDNAInfo
      var uNaNInfo: IDNAInfo
      var aTL: ValueStringBuilder = ValueStringBuilder(newSeq[char](StackBufferSize))
      var uTL: ValueStringBuilder = ValueStringBuilder(newSeq[char](StackBufferSize))
      var aNL: ValueStringBuilder = ValueStringBuilder(newSeq[char](StackBufferSize))
      var uNL: ValueStringBuilder = ValueStringBuilder(newSeq[char](StackBufferSize))
      var aTLInfo: IDNAInfo
      var uTLInfo: IDNAInfo
      var aNLInfo: IDNAInfo
      var uNLInfo: IDNAInfo
    var uniErrors: IDNAErrors
    try:
        var testCase: TestCase = TestCase
        var i: int
          i = 0
          while i < testCases.Length:
testCase.Set(testCases[i])
              var input: String = testCase.s
              var expected: String = testCase.u
              try:
                    # "# Note: C# unsafe block - contains pointer operations"
trans.TryNameToASCII(input, aT, aTInfo)
trans.TryNameToUnicode(input, uT, uTInfo)
nontrans.TryNameToASCII(input, aN, aNInfo)
nontrans.TryNameToUnicode(input, uN, uNInfo)
              except Exception:
Errln(String.Format("first-level processing [{0}/{1}] {2} - {3}", i, testCase.o, testCase.s, e))
                  continue
              uniErrors = testCase.errors & ~lengthOverflowErrors
              var mode: char = testCase.o[0]
              if mode == 'B' || mode == 'N':
                  if !sameErrors(uNInfo, uniErrors):
Errln(String.Format(StringFormatter.CurrentCulture, "N.nameToUnicode([{0}] {1}) unexpected errors {2}", i, testCase.s, uNInfo.Errors))
                      continue
                  if !UTF16Plus.Equal(uN.AsSpan, expected):
Errln(String.Format("N.nameToUnicode([{0}] {1}) unexpected string {2}", i, testCase.s, Prettify(uN.AsSpan)))
                      continue
                  if !sameErrors(aNInfo, testCase.errors):
Errln(String.Format("N.nameToASCII([{0}] {1}) unexpected errors {2}", i, testCase.s, aNInfo.Errors))
                      continue
              if mode == 'B' || mode == 'T':
                  if !sameErrors(uTInfo, uniErrors):
Errln(String.Format("T.nameToUnicode([{0}] {1}) unexpected errors {2}", i, testCase.s, uTInfo.Errors))
                      continue
                  if !UTF16Plus.Equal(uT.AsSpan, expected):
Errln(String.Format("T.nameToUnicode([{0}] {1}) unexpected string {2}", i, testCase.s, Prettify(uT.AsSpan)))
                      continue
                  if !sameErrors(aTInfo, testCase.errors):
Errln(String.Format("T.nameToASCII([{0}] {1}) unexpected errors {2}", i, testCase.s, aTInfo.Errors))
                      continue
              if !hasCertainErrors(aNInfo, severeErrors) && !IsASCII(aN.AsSpan):
Errln(String.Format("N.nameToASCII([{0}] {1}) (errors {2}) result is not ASCII {3}", i, testCase.s, aNInfo.Errors, Prettify(aN.AsSpan)))
                  continue
              if !hasCertainErrors(aTInfo, severeErrors) && !IsASCII(aT.AsSpan):
Errln(String.Format("T.nameToASCII([{0}] {1}) (errors {2}) result is not ASCII {3}", i, testCase.s, aTInfo.Errors, Prettify(aT.AsSpan)))
                  continue
              if IsVerbose:
                  var m: char =                   if mode == 'B':
mode
                  else:
'N'
Logln(String.Format("{0}.nameToASCII([{1}] {2}) (errors {3}) result string: {4}", m, i, testCase.s, aNInfo.Errors, Prettify(aN.AsSpan)))
                  if mode != 'B':
Logln(String.Format("T.nameToASCII([{0}] {1}) (errors {2}) result string: {3}", i, testCase.s, aTInfo.Errors, Prettify(aT.AsSpan)))
              try:
                    # "# Note: C# unsafe block - contains pointer operations"
nontrans.TryNameToUnicode(aT.AsSpan, aTuN, aTuNInfo)
nontrans.TryNameToASCII(uT.AsSpan, uTaN, uTaNInfo)
nontrans.TryNameToUnicode(aN.AsSpan, aNuN, aNuNInfo)
nontrans.TryNameToASCII(uN.AsSpan, uNaN, uNaNInfo)
              except Exception:
Errln(String.Format("second-level processing [{0}/{1}] {2} - {3}", i, testCase.o, testCase.s, e))
                  continue
              if !UTF16Plus.Equal(aN.AsSpan, uNaN.AsSpan):
Errln(String.Format(StringFormatter.CurrentCulture, "N.nameToASCII([{0}] {1})!=N.nameToUnicode().N.nameToASCII() " + "(errors {2}) {3} vs. {4}", i, testCase.s, aNInfo.Errors, Prettify(aN.AsSpan), Prettify(uNaN.AsSpan)))
                  continue
              if !UTF16Plus.Equal(aT.AsSpan, uTaN.AsSpan):
Errln(String.Format(StringFormatter.CurrentCulture, "T.nameToASCII([{0}] {1})!=T.nameToUnicode().N.nameToASCII() " + "(errors {2}) {3} vs. {4}", i, testCase.s, aNInfo.Errors, Prettify(aT.AsSpan), Prettify(uTaN.AsSpan)))
                  continue
              if !UTF16Plus.Equal(uN.AsSpan, aNuN.AsSpan):
Errln(String.Format(StringFormatter.CurrentCulture, "N.nameToUnicode([{0}] {1})!=N.nameToASCII().N.nameToUnicode() " + "(errors {2}) {3} vs. {4}", i, testCase.s, uNInfo.Errors, Prettify(uN.AsSpan), Prettify(aNuN.AsSpan)))
                  continue
              if !UTF16Plus.Equal(uT.AsSpan, aTuN.AsSpan):
Errln(String.Format(StringFormatter.CurrentCulture, "T.nameToUnicode([{0}] {1})!=T.nameToASCII().N.nameToUnicode() " + "(errors {2}) {3} vs. {4}", i, testCase.s, uNInfo.Errors, Prettify(uT.AsSpan), Prettify(aTuN.AsSpan)))
                  continue
              try:
                    # "# Note: C# unsafe block - contains pointer operations"
trans.TryLabelToASCII(input, aTL, aTLInfo)
trans.TryLabelToUnicode(input, uTL, uTLInfo)
nontrans.TryLabelToASCII(input, aNL, aNLInfo)
nontrans.TryLabelToUnicode(input, uNL, uNLInfo)
              except Exception:
Errln(String.Format("labelToXYZ processing [{0}/{1}] {2} - {3}", i, testCase.o, testCase.s, e))
                  continue
              if aN.IndexOf(".", StringComparison.Ordinal) < 0:
                  if !UTF16Plus.Equal(aN.AsSpan, aNL.AsSpan) || !sameErrors(aNInfo, aNLInfo):
Errln(String.Format(StringFormatter.CurrentCulture, "N.nameToASCII([{0}] {1})!=N.labelToASCII() " + "(errors {2} vs {3}) {4} vs. {5}", i, testCase.s, aNInfo.Errors, aNLInfo.Errors, Prettify(aN.AsSpan), Prettify(aNL.AsSpan)))
                      continue
              else:
                  if !hasError(aNLInfo, IDNAErrors.LabelHasDot):
Errln(String.Format(StringFormatter.CurrentCulture, "N.labelToASCII([{0}] {1}) errors {2} missing UIDNA_ERROR_LABEL_HAS_DOT", i, testCase.s, aNLInfo.Errors))
                      continue
              if aT.IndexOf(".", StringComparison.Ordinal) < 0:
                  if !UTF16Plus.Equal(aT.AsSpan, aTL.AsSpan) || !sameErrors(aTInfo, aTLInfo):
Errln(String.Format(StringFormatter.CurrentCulture, "T.nameToASCII([{0}] {1})!=T.labelToASCII() " + "(errors {2} vs {3}) {4} vs. {5}", i, testCase.s, aTInfo.Errors, aTLInfo.Errors, Prettify(aT.AsSpan), Prettify(aTL.AsSpan)))
                      continue
              else:
                  if !hasError(aTLInfo, IDNAErrors.LabelHasDot):
Errln(String.Format(StringFormatter.CurrentCulture, "T.labelToASCII([{0}] {1}) errors {2} missing UIDNA_ERROR_LABEL_HAS_DOT", i, testCase.s, aTLInfo.Errors))
                      continue
              if uN.IndexOf(".", StringComparison.Ordinal) < 0:
                  if !UTF16Plus.Equal(uN.AsSpan, uNL.AsSpan) || !sameErrors(uNInfo, uNLInfo):
Errln(String.Format(StringFormatter.CurrentCulture, "N.nameToUnicode([{0}] {1})!=N.labelToUnicode() " + "(errors {2} vs {3}) {4} vs. {5}", i, testCase.s, uNInfo.Errors, uNLInfo.Errors, Prettify(uN.AsSpan), Prettify(uNL.AsSpan)))
                      continue
              else:
                  if !hasError(uNLInfo, IDNAErrors.LabelHasDot):
Errln(String.Format(StringFormatter.CurrentCulture, "N.labelToUnicode([{0}] {1}) errors {2} missing UIDNA_ERROR_LABEL_HAS_DOT", i, testCase.s, uNLInfo.Errors))
                      continue
              if uT.IndexOf(".", StringComparison.Ordinal) < 0:
                  if !UTF16Plus.Equal(uT.AsSpan, uTL.AsSpan) || !sameErrors(uTInfo, uTLInfo):
Errln(String.Format(StringFormatter.CurrentCulture, "T.nameToUnicode([{0}] {1})!=T.labelToUnicode() " + "(errors {2} vs {3}) {4} vs. {5}", i, testCase.s, uTInfo.Errors, uTLInfo.Errors, Prettify(uT.AsSpan), Prettify(uTL.AsSpan)))
                      continue
              else:
                  if !hasError(uTLInfo, IDNAErrors.LabelHasDot):
Errln(String.Format(StringFormatter.CurrentCulture, "T.labelToUnicode([{0}] {1}) errors {2} missing UIDNA_ERROR_LABEL_HAS_DOT", i, testCase.s, uTLInfo.Errors))
                      continue
              if mode == 'B':
                  if aNInfo.IsTransitionalDifferent || aTInfo.IsTransitionalDifferent || uNInfo.IsTransitionalDifferent || uTInfo.IsTransitionalDifferent || aNLInfo.IsTransitionalDifferent || aTLInfo.IsTransitionalDifferent || uNLInfo.IsTransitionalDifferent || uTLInfo.IsTransitionalDifferent:
Errln(String.Format("B.process([{0}] {1}) isTransitionalDifferent()", i, testCase.s))
                      continue
                  if !UTF16Plus.Equal(aN.AsSpan, aT.AsSpan) || !UTF16Plus.Equal(uN.AsSpan, uT.AsSpan) || !UTF16Plus.Equal(aNL.AsSpan, aTL.AsSpan) || !UTF16Plus.Equal(uNL.AsSpan, uTL.AsSpan) || !sameErrors(aNInfo, aTInfo) || !sameErrors(uNInfo, uTInfo) || !sameErrors(aNLInfo, aTLInfo) || !sameErrors(uNLInfo, uTLInfo):
Errln(String.Format("N.process([{0}] {1}) vs. T.process() different errors or result strings", i, testCase.s))
                      continue
              else:
                  if !aNInfo.IsTransitionalDifferent || !aTInfo.IsTransitionalDifferent || !uNInfo.IsTransitionalDifferent || !uTInfo.IsTransitionalDifferent || !aNLInfo.IsTransitionalDifferent || !aTLInfo.IsTransitionalDifferent || !uNLInfo.IsTransitionalDifferent || !uTLInfo.IsTransitionalDifferent:
Errln(String.Format("{0}.process([{1}] {2}) !isTransitionalDifferent()", testCase.o, i, testCase.s))
                      continue
                  if UTF16Plus.Equal(aN.AsSpan, aT.AsSpan) || UTF16Plus.Equal(uN.AsSpan, uT.AsSpan) || UTF16Plus.Equal(aNL.AsSpan, aTL.AsSpan) || UTF16Plus.Equal(uNL.AsSpan, uTL.AsSpan):
Errln(String.Format("N.process([{0}] {1}) vs. T.process() same result strings", i, testCase.s))
                      continue
++i
    finally:
aT.Dispose
uT.Dispose
aN.Dispose
uN.Dispose
aTuN.Dispose
uTaN.Dispose
aNuN.Dispose
uNaN.Dispose
aTL.Dispose
uTL.Dispose
aNL.Dispose
uNL.Dispose
proc CheckIdnaTestResult(line: String, type: String, expected: String, result: ReadOnlySpan[char], info: IDNAInfo) =
    var expectedHasErrors: bool = !string.IsNullOrEmpty(expected) && expected[0] == '['
    if expectedHasErrors != info.HasErrors:
Errln(String.Format(StringFormatter.CurrentCulture, "{0}  expected errors {1} != {2} = actual has errors: {3}
    {4}", type, expectedHasErrors, info.HasErrors, info.Errors, line))
    if !expectedHasErrors && !UTF16Plus.Equal(expected, result):
Errln(String.Format("{0}  expected != actual
    {1}", type, line))
Errln("    " + expected)
Errln("    " + result.ToString)
proc IdnaTest*() =
    var idnaTestFile: TextReader = TestUtil.GetDataReader("unicode.IdnaTest.txt", "UTF-8")
    var semi: Regex = Regex(";", RegexOptions.Compiled)
      var uN: ValueStringBuilder = ValueStringBuilder(newSeq[char](32))
      var aN: ValueStringBuilder = ValueStringBuilder(newSeq[char](32))
      var aT: ValueStringBuilder = ValueStringBuilder(newSeq[char](32))
      var uNSpan: Span<char> = newSeq[char](256)
      var aNSpan: Span<char> = newSeq[char](256)
      var aTSpan: Span<char> = newSeq[char](256)
    try:
        var line: string
        while         line = idnaTestFile.ReadLine != nil:
            var commentStart: int = line.IndexOf('#')
            if commentStart >= 0:
                line = line.Substring(0, commentStart)
            var fields: String[] = semi.Split(line)
            if fields.Length <= 1:
                continue
            var type: String = fields[0].Trim
            var typeChar: char
            if type.Length != 1 ||             typeChar = type[0] != 'B' && typeChar != 'N' && typeChar != 'T':
Errln("empty or unknown type field: " + line)
                return
            var source16: String = Utility.Unescape(fields[1].Trim)
            var unicode16: String = Utility.Unescape(fields[2].Trim)
            if string.IsNullOrEmpty(unicode16):
                unicode16 = source16
            var ascii16: String = Utility.Unescape(fields[3].Trim)
            if string.IsNullOrEmpty(ascii16):
                ascii16 = unicode16
            uN.Length = 0
            aN.Length = 0
            aT.Length = 0
nontrans.TryNameToUnicode(source16, uN,             var uNInfo: IDNAInfo)
CheckIdnaTestResult(line, "toUnicodeNontrans", unicode16, uN.AsSpan, uNInfo)
            if typeChar == 'T' || typeChar == 'B':
trans.TryNameToASCII(source16, aT,                 var aTInfo: IDNAInfo)
CheckIdnaTestResult(line, "toASCIITrans", ascii16, aT.AsSpan, aTInfo)
            if typeChar == 'N' || typeChar == 'B':
nontrans.TryNameToASCII(source16, aN,                 var aNInfo: IDNAInfo)
CheckIdnaTestResult(line, "toASCIINontrans", ascii16, aN.AsSpan, aNInfo)
nontrans.TryNameToUnicode(source16, uNSpan,             var charsLength: int, uNInfo)
CheckIdnaTestResult(line, "toUnicodeNontrans", unicode16, uNSpan.Slice(0, charsLength), uNInfo)
            if typeChar == 'T' || typeChar == 'B':
trans.TryNameToASCII(source16, aTSpan, charsLength,                 var aTInfo: IDNAInfo)
CheckIdnaTestResult(line, "toASCIITrans", ascii16, aTSpan.Slice(0, charsLength), aTInfo)
            if typeChar == 'N' || typeChar == 'B':
nontrans.TryNameToASCII(source16, aNSpan, charsLength,                 var aNInfo: IDNAInfo)
CheckIdnaTestResult(line, "toASCIINontrans", ascii16, aNSpan.Slice(0, charsLength), aNInfo)
    finally:
uN.Dispose
aT.Dispose
aN.Dispose
idnaTestFile.Dispose
proc TestBufferOverflow*() =
    var longBuffer: Span<char> = newSeq[char](512)
    var shortBuffer: Span<char> = newSeq[char](4)
    var testCase: TestCase = TestCase
      var i: int = 0
      while i < testCases.Length:
testCase.Set(testCases[i])
          var input: string = testCase.s
          if input.Length <= shortBuffer.Length + 5:
            continue
trans.TryLabelToASCII(input, longBuffer,             var longBufferLength: int,             var info: IDNAInfo)
            if info.errors & IDNAErrors.BufferOverflow != 0:
Errln("IDNA.TryLabelToASCII was not suppose to return a " & $IDNAErrors.BufferOverflow & " when there is a long enough buffer.")
            var success: bool = trans.TryLabelToASCII(input, shortBuffer,             var shortBufferLength: int, info)
            if success || info.errors & IDNAErrors.BufferOverflow == 0:
Errln("IDNA.TryLabelToASCII was suppose to return a " & $IDNAErrors.BufferOverflow & " when the buffer is too short.")
            if shortBufferLength < longBufferLength:
Errln("IDNA.TryLabelToASCII was suppose to return a buffer size large enough to fit the text.")
trans.TryLabelToUnicode(input, longBuffer,             var longBufferLength: int,             var info: IDNAInfo)
            if info.errors & IDNAErrors.BufferOverflow != 0:
Errln("IDNA.TryLabelToUnicode was not suppose to return a " & $IDNAErrors.BufferOverflow & " when there is a long enough buffer.")
            var success: bool = trans.TryLabelToUnicode(input, shortBuffer,             var shortBufferLength: int, info)
            if success || info.errors & IDNAErrors.BufferOverflow == 0:
Errln("IDNA.TryLabelToUnicode was suppose to return a " & $IDNAErrors.BufferOverflow & " when the buffer is too short.")
            if shortBufferLength < longBufferLength:
Errln("IDNA.TryLabelToUnicode was suppose to return a buffer size large enough to fit the text.")
trans.TryNameToASCII(input, longBuffer,             var longBufferLength: int,             var info: IDNAInfo)
            if info.errors & IDNAErrors.BufferOverflow != 0:
Errln("IDNA.TryNameToASCII was not suppose to return a " & $IDNAErrors.BufferOverflow & " when there is a long enough buffer.")
            var success: bool = trans.TryNameToASCII(input, shortBuffer,             var shortBufferLength: int, info)
            if success || info.errors & IDNAErrors.BufferOverflow == 0:
Errln("IDNA.TryNameToASCII was suppose to return a " & $IDNAErrors.BufferOverflow & " when the buffer is too short.")
            if shortBufferLength < longBufferLength:
Errln("IDNA.TryNameToASCII was suppose to return a buffer size large enough to fit the text.")
trans.TryNameToUnicode(input, longBuffer,             var longBufferLength: int,             var info: IDNAInfo)
            if info.errors & IDNAErrors.BufferOverflow != 0:
Errln("IDNA.TryNameToUnicode was not suppose to return a " & $IDNAErrors.BufferOverflow & " when there is a long enough buffer.")
            var success: bool = trans.TryNameToUnicode(input, shortBuffer,             var shortBufferLength: int, info)
            if success || info.errors & IDNAErrors.BufferOverflow == 0:
Errln("IDNA.TryNameToUnicode was suppose to return a " & $IDNAErrors.BufferOverflow & " when the buffer is too short.")
            if shortBufferLength < longBufferLength:
Errln("IDNA.TryNameToUnicode was suppose to return a buffer size large enough to fit the text.")
++i
proc hasError(info: IDNAInfo, error: IDNAErrors): bool =
    return info.Errors & error != 0
proc hasCertainErrors(errors: IDNAErrors, certainErrors: IDNAErrors): bool =
    return errors != IDNAErrors.None && errors & certainErrors != 0
proc hasCertainErrors(info: IDNAInfo, certainErrors: IDNAErrors): bool =
    return hasCertainErrors(info.Errors, certainErrors)
proc sameErrors(a: IDNAErrors, b: IDNAErrors): bool =
    return a == b
proc sameErrors(a: IDNAInfo, b: IDNAInfo): bool =
    return sameErrors(a.Errors, b.Errors)
proc sameErrors(a: IDNAInfo, b: IDNAErrors): bool =
    return sameErrors(a.Errors, b)
proc IsASCII(str: ReadOnlySpan[char]): bool =
    var length: int = str.Length
      var i: int = 0
      while i < length:
          if str[i] >= 128:
              return false
++i
    return true