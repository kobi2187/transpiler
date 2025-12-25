# "Namespace: ICU4N.Dev.Test.Normalizers"
type
  NormalizationMonkeyTest = ref object
    loopCount: int = 100
    maxCharCount: int = 20
    maxCodePoint: int = 1114111
    random: Random = nil
    unicode_NFD: UnicodeNormalizer
    unicode_NFC: UnicodeNormalizer
    unicode_NFKD: UnicodeNormalizer
    unicode_NFKC: UnicodeNormalizer

proc newNormalizationMonkeyTest(): NormalizationMonkeyTest =

proc TestNormalize*() =
    if unicode_NFD == nil:
        try:
            unicode_NFD = UnicodeNormalizer(UnicodeNormalizer.D, true)
            unicode_NFC = UnicodeNormalizer(UnicodeNormalizer.C, true)
            unicode_NFKD = UnicodeNormalizer(UnicodeNormalizer.KD, true)
            unicode_NFKC = UnicodeNormalizer(UnicodeNormalizer.KC, true)
        except Exception:
Errln("Normalization tests could not be run: " + e.ToString)
    var i: int = 0
    while i < loopCount:
        var source: String = GetTestSource
Logln("Test source:" + source)
        var uncodeNorm: String = unicode_NFD.normalize(source)
        var icuNorm: String = Normalizer.Normalize(source, NormalizerMode.NFD)
Logln("	NFD(Unicode): " + uncodeNorm)
Logln("	NFD(icu4j)  : " + icuNorm)
        if !uncodeNorm.Equals(icuNorm):
Errln("NFD: Unicode sample output => " + uncodeNorm + "; icu4j output=> " + icuNorm)
        uncodeNorm = unicode_NFC.normalize(source)
        icuNorm = Normalizer.Normalize(source, NormalizerMode.NFC)
Logln("	NFC(Unicode): " + uncodeNorm)
Logln("	NFC(icu4j)  : " + icuNorm)
        if !uncodeNorm.Equals(icuNorm):
Errln("NFC: Unicode sample output => " + uncodeNorm + "; icu4j output=> " + icuNorm)
        uncodeNorm = unicode_NFKD.normalize(source)
        icuNorm = Normalizer.Normalize(source, NormalizerMode.NFKD)
Logln("	NFKD(Unicode): " + uncodeNorm)
Logln("	NFKD(icu4j)  : " + icuNorm)
        if !uncodeNorm.Equals(icuNorm):
Errln("NFKD: Unicode sample output => " + uncodeNorm + "; icu4j output=> " + icuNorm)
        uncodeNorm = unicode_NFKC.normalize(source)
        icuNorm = Normalizer.Normalize(source, NormalizerMode.NFKC)
Logln("	NFKC(Unicode): " + uncodeNorm)
Logln("	NFKC(icu4j)  : " + icuNorm)
        if !uncodeNorm.Equals(icuNorm):
Errln("NFKC: Unicode sample output => " + uncodeNorm + "; icu4j output=> " + icuNorm)
++i
proc GetTestSource(): String =
    if random == nil:
        random = CreateRandom
    var source: String = ""
    var i: int = 0
    while i < random.Next(maxCharCount) + 1:
        var codepoint: int = random.Next(maxCodePoint)
        while UChar.GetUnicodeCategory(codepoint) == UUnicodeCategory.OtherNotAssigned:
            codepoint = random.Next(maxCodePoint)
        source = source + UTF16.ValueOf(codepoint)
++i
    return source