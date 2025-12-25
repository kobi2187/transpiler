# "Namespace: ICU4N.Dev.Test.Translit"
type
  RoundTripTest = ref object
    FIX_ME: bool = false
    EXTRA_TESTS: bool = true
    PRINT_RULES: bool = true
    KATAKANA: String = "[[[:katakana:][ァ-ヺー]]-[ヿㇰ-ㇿ]-[:^age=5.2:]]"
    HIRAGANA: String = "[[[:hiragana:][぀-ゔ]]-[ゕ-ゖゟ-゠\U0001F200-\U0001F2FF]-[:^age=5.2:]]"
    LENGTH: String = "[ー]"
    HALFWIDTH_KATAKANA: String = "[･-ﾝ]"
    KATAKANA_ITERATION: String = "[ヽヾ]"
    HIRAGANA_ITERATION: String = "[ゝゞ]"
    ARABIC: String = "[ک،؛؟ءا-غف-ٕ٠-٬پچژڤڭگۋ-ی۰-۹]"
    latinForIndic: String = "[['.0-9A-Za-z~À-ÅÇ-ÏÑ-ÖÙ-Ý" + "à-åç-ïñ-öù-ýÿ-ď" + "Ē-ĥĨ-İĴ-ķĹ-ľŃ-ň" + "Ō-őŔ-ťŨ-žƠ-ơƯ-ư" + "Ǎ-ǜǞ-ǣǦ-ǭǰǴ-ǵǸ-ǻ" + "Ȁ-țȞ-ȟȦ-ȳʔ̃-̄̆̔-̕" + "̥ЎЙйўӁ-ӂӐ-ӑӖ-ӗ" + "Ӣ-ӣӮ-ӯḀ-ẙẠ-ỹἁἃἅ" + "ἇἉἋἍἏἑἓἕἙἛἝἡ" + "ἣἥἧἩἫἭἯἱἳἵἷἹ" + "ἻἽἿὁὃὅὉὋὍὑὓὕ" + "ὗὙὛὝὟὡὣὥὧὩὫὭ" + "Ὧᾁᾃᾅᾇᾉᾋᾍᾏᾑᾓᾕ" + "ᾗᾙᾛᾝᾟᾡᾣᾥᾧᾩᾫᾭ" + "ᾯ-ᾱᾸ-Ᾱῐ-ῑῘ-Ῑῠ-ῡῥ" + "Ῠ-ῩῬK-Å]" + "-[- Ǣǣ]& [[:latin:][:mark:]]]"
    interIndicArray: seq[String] = @[@["BENGALI-DEVANAGARI", "[:BENGALI:]", "[:Devanagari:]", "[ऄ॑-॔ृ-ॉॊॢॣऍऎऑऒऩळऴवॐक़ख़ग़ज़फ़ॽ]"], @["DEVANAGARI-BENGALI", "[:Devanagari:]", "[:BENGALI:]", "[ৗऍऎऑऒऩळऴवॐक़ख़ग़ज़फ़ৰৱ৲-৺ৎ]"], @["GURMUKHI-DEVANAGARI", "[:GURMUKHI:]", "[:Devanagari:]", "[ऄंशळ॑-॔ंःृ-ॉॊॢॣऋऌऍऎऑऒऴषऽॐॠॡॽ]"], @["DEVANAGARI-GURMUKHI", "[:Devanagari:]", "[:GURMUKHI:]", "[ਂॆੜ॑-॔ੰੱऋऌऍऎऑऒऴषऽॐॠॡੲੳੴ]"], @["GUJARATI-DEVANAGARI", "[:GUJARATI:]", "[:Devanagari:]", "[ऄॆॊॢॣ॑-॔ॡऌऎऒॽ]"], @["DEVANAGARI-GUJARATI", "[:Devanagari:]", "[:GUJARATI:]", "[॑-॔ॡऌऎऒ]"], @["ORIYA-DEVANAGARI", "[:ORIYA:]", "[:Devanagari:]", "[ऄऒऑऍऎऱृ-ॊॢॣ॑-॔ॐॽ]"], @["DEVANAGARI-ORIYA", "[:Devanagari:]", "[:ORIYA:]", "[ୟୖୗ୰ୱॐऍऎऒऑऱ]"], @["Tamil-DEVANAGARI", "[:tamil:]", "[:Devanagari:]", "[ँऄ़ृ-ॊ॑-॔ॢॣऋऌऍऑखगघछझठडढथदधफबभशऽॐ[क़-ॡ]ॽ]"], @["DEVANAGARI-Tamil", "[:Devanagari:]", "[:tamil:]", "[ௗ௰௱௲]"], @["Telugu-DEVANAGARI", "[:telugu:]", "[:Devanagari:]", "[ऄ़ॐॅॉ॑-॔ॢॣऍऑऽऩऴ[क़-य़]ॽ]"], @["DEVANAGARI-TELUGU", "[:Devanagari:]", "[:TELUGU:]", "[ౕౖॐऍऑऽऩऴ[क़-य़]]"], @["KANNADA-DEVANAGARI", "[:KANNADA:]", "[:Devanagari:]", "[ँऄॆॐॅॉ॑-॔ॢॣॐऍऑऽऩऴ[क़-य़]ॽ]"], @["DEVANAGARI-KANNADA", "[:Devanagari:]", "[:KANNADA:]", "[{ರ಼}{ಳ಼}ೞೕೖॐऍऑऽऩऴ[क़-य़]]"], @["MALAYALAM-DEVANAGARI", "[:MALAYALAM:]", "[:Devanagari:]", "[ँऄॊोौ़ॐॄॅॉ॑-॔ॢॣऍऑऽऩऴ[क़-य़]ॽ]"], @["DEVANAGARI-MALAYALAM", "[:Devanagari:]", "[:MALAYALAM:]", "[ൌൗॐऍऑऽऩऴ[क़-य़]]"], @["GURMUKHI-BENGALI", "[:GURMUKHI:]", "[:BENGALI:]", "[ংশৢৣৃৄৗঋঌষৠৡৰৱ৲-৺ৎ]"], @["BENGALI-GURMUKHI", "[:BENGALI:]", "[:GURMUKHI:]", "[ਂੜੇੰੱਲ਼ਵਖ਼ਗ਼ਜ਼ਫ਼ੲੳੴ]"], @["GUJARATI-BENGALI", "[:GUJARATI:]", "[:BENGALI:]", "[ৗৢৣঌৡৰৱ৲-৺ৎ]"], @["BENGALI-GUJARATI", "[:BENGALI:]", "[:GUJARATI:]", "[ંઃૉૅેઍઑળવઽૐ]"], @["ORIYA-BENGALI", "[:ORIYA:]", "[:BENGALI:]", "[ৄৢৣৰৱ৲-৺ৎ]"], @["BENGALI-ORIYA", "[:BENGALI:]", "[:ORIYA:]", "[ଵୱୟୖଳଽ]"], @["Tamil-BENGALI", "[:tamil:]", "[:BENGALI:]", "[ঁ়ৃৄৢৣৰৱঋঌখগঘছঝঠডঢথদধফবভশড়ঢ়য়ৠৡ৲-৺ৎ]"], @["BENGALI-Tamil", "[:BENGALI:]", "[:tamil:]", "[ெேொஎஒனறளழவ௰௱௲]"], @["Telugu-BENGALI", "[:telugu:]", "[:BENGALI:]", "[ৢৣ়ৗৰৱড়ঢ়য়৲-৺ৎ]"], @["BENGALI-TELUGU", "[:BENGALI:]", "[:TELUGU:]", "[ౕౖేెొఎఒఱళవ]"], @["KANNADA-BENGALI", "[:KANNADA:]", "[:BENGALI:]", "[ঁৢৣ়ৗৰৱড়ঢ়য়৲-৺ৎ]"], @["BENGALI-KANNADA", "[:BENGALI:]", "[:KANNADA:]", "[{ರ಼}{ಳ಼}ೆೋೖೇಎಒಱಳವೞ]"], @["MALAYALAM-BENGALI", "[:MALAYALAM:]", "[:BENGALI:]", "[ঁৢৣ়ৄৰৱড়ঢ়য়৲-৺ৎ]"], @["BENGALI-MALAYALAM", "[:BENGALI:]", "[:MALAYALAM:]", "[െൊേറ-വഎഒ]"], @["GUJARATI-GURMUKHI", "[:GUJARATI:]", "[:GURMUKHI:]", "[ਂળશੰੱંઃૃૄૅૉੜੲੳੴઋઍઑઽ]"], @["GURMUKHI-GUJARATI", "[:GURMUKHI:]", "[:GUJARATI:]", "[ੜੰੱੲੳੴંઃઋઌઍઑળશષઽૃૄૅૉૐૠૡ]"], @["ORIYA-GURMUKHI", "[:ORIYA:]", "[:GURMUKHI:]", "[ਂੜਡੇੱଂଃଳଶୃୖୗଋଌଷଽୟୠୡਵੲੳੴ]"], @["GURMUKHI-ORIYA", "[:GURMUKHI:]", "[:ORIYA:]", "[ੱଂଃଳଶୃୖୗଋଌଷଽୟୠୡ୰ୱ]"], @["TAMIL-GURMUKHI", "[:TAMIL:]", "[:GURMUKHI:]", "[ਁਂਲ਼ਸ਼਼ੰੱੇਖਗਘਛਝਠਡਢਥਦਧਫਬਭਖ਼ਗ਼ਜ਼ੜਫ਼ੲੳੴ]"], @["GURMUKHI-TAMIL", "[:GURMUKHI:]", "[:TAMIL:]", "[ஂெொௗஷளஃஎஒனறழஶ௰௱௲]"], @["TELUGU-GURMUKHI", "[:TELUGU:]", "[:GURMUKHI:]", "[ਂਲ਼ਸ਼਼ੰੱਖ਼ਗ਼ਜ਼ੜਫ਼ੲੳੴ]"], @["GURMUKHI-TELUGU", "[:GURMUKHI:]", "[:TELUGU:]", "[ంఃళశౄృెొౕౖఋఌఎఒఱషౠౡ]"], @["KANNADA-GURMUKHI", "[:KANNADA:]", "[:GURMUKHI:]", "[ਁਂਲ਼ਸ਼਼ੰੱਖ਼ਗ਼ਜ਼ੜਫ਼ੲੳੴ]"], @["GURMUKHI-KANNADA", "[:GURMUKHI:]", "[:KANNADA:]", "[{ರ಼}{ಳ಼}ಂಃಳಶೄೃೆೋೖಋಌಎಒಱಷಽೠೡೞ]"], @["MALAYALAM-GURMUKHI", "[:MALAYALAM:]", "[:GURMUKHI:]", "[ਁਂੋੌਲ਼ਸ਼਼ੰੱਖ਼ਗ਼ਜ਼ੜਫ਼ੲੳੴ]"], @["GURMUKHI-MALAYALAM", "[:GURMUKHI:]", "[:MALAYALAM:]", "[ംഃളശൃെൊൌൗഋഌഎഒറഴഷൠൡ]"], @["GUJARATI-ORIYA", "[:GUJARATI:]", "[:ORIYA:]", "[ୖୗଌୟୡ୰ୱ]"], @["ORIYA-GUJARATI", "[:ORIYA:]", "[:GUJARATI:]", "[ૄૅૉેઍઑવૐ]"], @["TAMIL-GUJARATI", "[:TAMIL:]", "[:GUJARATI:]", "[ઁઌ઼ૃૄૅૉેઋઍઑખગઘછઝઠડઢથદધફબભશઽૐૠૡ]"], @["GUJARATI-TAMIL", "[:GUJARATI:]", "[:TAMIL:]", "[ெொௗஎஒனறழ௰௱௲]"], @["TELUGU-GUJARATI", "[:TELUGU:]", "[:GUJARATI:]", "[઼ૅૉઍઑઽૐ]"], @["GUJARATI-TELUGU", "[:GUJARATI:]", "[:TELUGU:]", "[ెొౕౖఌఎఒఱౡ]"], @["KANNADA-GUJARATI", "[:KANNADA:]", "[:GUJARATI:]", "[ઁ઼ૅૉઍઑઽૐ]"], @["GUJARATI-KANNADA", "[:GUJARATI:]", "[:KANNADA:]", "[{ರ಼}{ಳ಼}ೆೋೖಌಎಒಱೞೡ]"], @["MALAYALAM-GUJARATI", "[:MALAYALAM:]", "[:GUJARATI:]", "[ઁૄોૌ઼ૅૉઍઑઽૐ]"], @["GUJARATI-MALAYALAM", "[:GUJARATI:]", "[:MALAYALAM:]", "[െൊൌൕൗഌഎഒറഴൡ]"], @["TAMIL-ORIYA", "[:TAMIL:]", "[:ORIYA:]", "[ଁ଼ୃୖଋଌଖଗଘଛଝଠଡଢଥଦଧଫବଭଶଽଡ଼ଢ଼ୟୠୡ୰ୱ]"], @["ORIYA-TAMIL", "[:ORIYA:]", "[:TAMIL:]", "[ெொேஎஒனறழவ௰௱௲]"], @["TELUGU-ORIYA", "[:TELUGU:]", "[:ORIYA:]", "[଼ୗୖଽଡ଼ଢ଼ୟ୰ୱ]"], @["ORIYA-TELUGU", "[:ORIYA:]", "[:TELUGU:]", "[ౄెొౕేఎఒఱవ]"], @["KANNADA-ORIYA", "[:KANNADA:]", "[:ORIYA:]", "[ଁ଼ୗଽଡ଼ଢ଼ୟ୰ୱ]"], @["ORIYA-KANNADA", "[:ORIYA:]", "[:KANNADA:]", "[{ರ಼}{ಳ಼}ೄೆೋೇಎಒಱವೞ]"], @["MALAYALAM-ORIYA", "[:MALAYALAM:]", "[:ORIYA:]", "[ଁ଼ୖଽଡ଼ଢ଼ୟ୰ୱ]"], @["ORIYA-MALAYALAM", "[:ORIYA:]", "[:MALAYALAM:]", "[േെൊഎഒറഴവ]"], @["TELUGU-TAMIL", "[:TELUGU:]", "[:TAMIL:]", "[ௗனழ௰௱௲௰௱௲]"], @["TAMIL-TELUGU", "[:TAMIL:]", "[:TELUGU:]", "[ఁృౄెేౕౖ౦ఋఌఖగఘఛఝఠడఢథదధఫబభశౠౡ]"], @["KANNADA-TAMIL", "[:KANNADA:]", "[:TAMIL:]", "[ௗெனழ௰௱௲]"], @["TAMIL-KANNADA", "[:TAMIL:]", "[:KANNADA:]", "[ೃೄೆೇೕೖಋಌಖಗಘಛಝಠಡಢಥದಧಫಬಭಶ಼ಽೞೠೡ]"], @["MALAYALAM-TAMIL", "[:MALAYALAM:]", "[:TAMIL:]", "[ன௰௱௲]"], @["TAMIL-MALAYALAM", "[:TAMIL:]", "[:MALAYALAM:]", "[ൃഒഋഌഖഗഘഛഝഠഡഢഥദധഫബഭശൠൡ]"], @["KANNADA-TELUGU", "[:KANNADA:]", "[:TELUGU:]", "[ఁిెైొ]"], @["TELUGU-KANNADA", "[:TELUGU:]", "[:KANNADA:]", "[ೈೕೖೞ಼ಽ]"], @["MALAYALAM-TELUGU", "[:MALAYALAM:]", "[:TELUGU:]", "[ఁౄొౌోౕౖ]"], @["TELUGU-MALAYALAM", "[:TELUGU:]", "[:MALAYALAM:]", "[ൌൗഴ]"], @["MALAYALAM-KANNADA", "[:MALAYALAM:]", "[:KANNADA:]", "[಼ಽೄೆೊೌೋೕೖೞ]"], @["Latin-Bengali", latinForIndic, "[[:Bengali:][।॥]]", "[॥ৰ-৺ৎ]"], @["Latin-Gurmukhi", latinForIndic, "[[:Gurmukhi:][।॥]]", "[ਁਂ॥ੲੳੴ]"], @["Latin-Gujarati", latinForIndic, "[[:Gujarati:][।॥]]", "[॥]"], @["Latin-Oriya", latinForIndic, "[[:Oriya:][।॥]]", "[॥୰]"], @["Latin-Tamil", latinForIndic, "[:Tamil:]", "[௰௱௲]"], @["Latin-Telugu", latinForIndic, "[:Telugu:]", nil], @["Latin-Kannada", latinForIndic, "[:Kannada:]", nil], @["Latin-Malayalam", latinForIndic, "[:Malayalam:]", nil]]

type
  AbbreviatedUnicodeSetIterator = ref object
    abbreviated: bool
    perRange: int

proc newAbbreviatedUnicodeSetIterator(): AbbreviatedUnicodeSetIterator =
newUnicodeSetIterator
  abbreviated = false
proc Reset*(newSet: UnicodeSet) =
Reset(newSet, false)
proc Reset*(newSet: UnicodeSet, abb: bool) =
Reset(newSet, abb, 100)
proc Reset*(newSet: UnicodeSet, abb: bool, density: int) =
procCall.Reset(newSet)
    abbreviated = abb
    perRange = newSet.RangeCount
    if perRange != 0:
        perRange = density / perRange
proc LoadRange(myRange: int) =
procCall.LoadRange(myRange)
    if abbreviated && endElement > nextElement + perRange:
        endElement = nextElement + perRange
proc ShowElapsed*(start: long, name: String) =
    var dur: double = Time.CurrentTimeMilliseconds - start / 1000.0
Logln(name + " took " + dur + " seconds")
proc TestKana*() =
    var start: long = Time.CurrentTimeMilliseconds
TransliterationTest("Katakana-Hiragana").Test(KATAKANA, "[" + HIRAGANA + LENGTH + "]", "[" + HALFWIDTH_KATAKANA + LENGTH + "]", self, Legal)
ShowElapsed(start, "TestKana")
proc TestHiragana*() =
    var start: long = Time.CurrentTimeMilliseconds
TransliterationTest("Latin-Hiragana").Test("[a-zA-Z]", HIRAGANA, HIRAGANA_ITERATION, self, Legal)
ShowElapsed(start, "TestHiragana")
proc TestKatakana*() =
    var start: long = Time.CurrentTimeMilliseconds
TransliterationTest("Latin-Katakana").Test("[a-zA-Z]", KATAKANA, "[" + KATAKANA_ITERATION + HALFWIDTH_KATAKANA + "]", self, Legal)
ShowElapsed(start, "TestKatakana")
proc TestJamo*() =
    var start: long = Time.CurrentTimeMilliseconds
TransliterationTest("Latin-Jamo").Test("[a-zA-Z]", "[ᄀ-ᄒ ᅡ-ᅵ ᆨ-ᇂ]", "", self, LegalJamo)
ShowElapsed(start, "TestJamo")
proc TestHangul*() =
    var start: long = Time.CurrentTimeMilliseconds
    var t: TransliterationTest = TransliterationTest("Latin-Hangul", 5)
    var TEST_ALL: bool = GetBooleanProperty("HangulRoundTripAll", false)
    if TEST_ALL && TestFmwk.GetExhaustiveness == 10:
t.SetPairLimit(int.MaxValue)
t.Test("[a-zA-Z]", "[가-힤]", "", self, Legal)
ShowElapsed(start, "TestHangul")
proc TestHangul2*() =
    var lh: Transliterator = Transliterator.GetInstance("Latin-Hangul")
    var hl: Transliterator = lh.GetInverse
    var representativeHangul: UnicodeSet = GetRepresentativeHangul
      var it: UnicodeSetIterator = UnicodeSetIterator(representativeHangul)
      while it.Next:
AssertRoundTripTransform("Transform", it.GetString, lh, hl)
proc AssertRoundTripTransform(message: String, source: String, lh: Transliterator, hl: Transliterator) =
    var to: String = hl.Transform(source)
    var back: String = lh.Transform(to)
    if !source.Equals(back):
        var to2: String = hl.Transform(Regex.Replace(source, "(.)", "$1 ").Trim)
        var to3: String = hl.Transform(Regex.Replace(back, "(.)", "$1 ").Trim)
assertEquals(message + " " + source + " [" + to + "/" + to2 + "/" + to3 + "]", source, back)
proc GetRepresentativeHangul*(): UnicodeSet =
    var extraSamples: UnicodeSet = UnicodeSet("[츠{구디}{굳이}{무렷}{물엿}{아까}{아따}{아빠}{아싸}{아짜}{아차}{악사}{악싸}{앆카}{안가}{안자}{안짜}{안하}{알가}{알따}{알마}{알바}{알빠}{알사}{알싸}{알타}{알파}{알하}{압사}{압싸}{았사}{업섯씁}{없었습}]")
    var sourceSet: UnicodeSet = UnicodeSet
AddRepresentativeHangul(sourceSet, 2, false)
AddRepresentativeHangul(sourceSet, 3, false)
AddRepresentativeHangul(sourceSet, 2, true)
AddRepresentativeHangul(sourceSet, 3, true)
    var more: UnicodeSet = GetRepresentativeBoundaryHangul
sourceSet.AddAll(more)
sourceSet.AddAll(extraSamples)
    return sourceSet
proc GetRepresentativeBoundaryHangul(): UnicodeSet =
    var resultToAddTo: UnicodeSet = UnicodeSet
    var L: UnicodeSet = UnicodeSet("[:hst=L:]")
    var V: UnicodeSet = UnicodeSet("[:hst=V:]")
    var T: UnicodeSet = UnicodeSet("[:hst=T:]")
    var prefixLV: String = "가"
    var prefixL: String = "ᄀ"
    var suffixV: String = "ᅡ"
    var nullL: String = "ᄋ"
    var L0: UnicodeSet = UnicodeSet("[ᄀᄋ]")
      var iL0: UnicodeSetIterator = UnicodeSetIterator(L0)
      while iL0.Next:
            var iV: UnicodeSetIterator = UnicodeSetIterator(V)
            while iV.Next:
                  var iV2: UnicodeSetIterator = UnicodeSetIterator(V)
                  while iV2.Next:
                      var sample: String = iL0.GetString + iV.GetString + nullL + iV2.GetString
                      var trial: String = Normalizer.Compose(sample, false)
                      if trial.Length == 2:
resultToAddTo.Add(trial)
      var iL: UnicodeSetIterator = UnicodeSetIterator(L)
      while iL.Next:
          var suffix: String = iL.GetString + suffixV
            var iV: UnicodeSetIterator = UnicodeSetIterator(V)
            while iV.Next:
                var sample: String = prefixL + iV.GetString + suffix
                var trial: String = Normalizer.Compose(sample, false)
                if trial.Length == 2:
resultToAddTo.Add(trial)
            var iT: UnicodeSetIterator = UnicodeSetIterator(T)
            while iT.Next:
                var sample: String = prefixLV + iT.GetString + suffix
                var trial: String = Normalizer.Compose(sample, false)
                if trial.Length == 2:
resultToAddTo.Add(trial)
    return resultToAddTo
proc AddRepresentativeHangul(resultToAddTo: UnicodeSet, leng: int, noFirstConsonant: bool) =
    var notYetSeen: UnicodeSet = UnicodeSet
      var c: char = '�'
      while c < '�':
          var charStr: String = c + ""
          var decomp: String = Normalizer.Decompose(charStr, false)
          if decomp.Length != leng:
              continue
          if decomp.StartsWith("ᄋ ", StringComparison.Ordinal) != noFirstConsonant:
              continue
          if !notYetSeen.ContainsAll(decomp):
resultToAddTo.Add(c)
notYetSeen.AddAll(decomp)
++c
proc TestHan*() =
    try:
        var exemplars: UnicodeSet = LocaleData.GetExemplarSet(UCultureInfo("zh"), 0)
        var b: StringBuffer = StringBuffer
          var it: UnicodeSetIterator = UnicodeSetIterator(exemplars)
          while it.Next:
UTF16.Append(b, it.Codepoint)
        var source: String = b.ToString
        var han: Transliterator = Transliterator.GetInstance("Han-Latin")
        var target: String = han.Transliterate(source)
        var allHan: UnicodeSet = UnicodeSet("[:han:]")
assertFalse("No Han must be left after Han-Latin transliteration", allHan.ContainsSome(target))
        var pn: Transliterator = Transliterator.GetInstance("Latin-NumericPinyin")
        var target2: String = pn.Transliterate(target)
        var nfc: Transliterator = Transliterator.GetInstance("nfc")
        var nfced: String = nfc.Transliterate(target2)
        var allMarks: UnicodeSet = UnicodeSet("[:mark:]")
assertFalse("NumericPinyin must contain no marks", allMarks.ContainsSome(nfced))
        var np: Transliterator = pn.GetInverse
        var target3: String = np.Transliterate(target)
        var roundtripOK: bool = target3.Equals(target)
assertTrue("NumericPinyin must roundtrip", roundtripOK)
        if !roundtripOK:
            var filename: String = "numeric-pinyin.log.txt"
              let @out = StreamWriter(FileStream(filename, FileMode.Create, FileAccess.Write), Encoding.UTF8)
<unhandled: nnkDefer>
Errln("Creating log file " + FileInfo(filename).FullName)
@out.WriteLine("Pinyin:                " + target)
@out.WriteLine("Pinyin-Numeric-Pinyin: " + target2)
    except MissingManifestResourceException:
Warnln("Could not load the locale data for fetching the exemplar characters." + ex.ToString)
proc TestSingle*() =
    var t: Transliterator = Transliterator.GetInstance("Latin-Greek")
t.Transliterate("aāi")
proc GetGreekSet(): string =
    if FIX_ME:
Errln("TestGreek needs to be updated to remove delete the [:Age=4.0:] filter ")
    else:
Logln("TestGreek needs to be updated to remove delete the section marked [:Age=4.0:] filter")
    return "[;·[[:Greek:]&[:Letter:]]-[" + "ᴦ-ᴪ" + "ᵝ-ᵡ" + "ᵦ-ᵪ" + "ϗ-ϯ" + "] & [:Age=4.0:]]"
proc TestGreek*() =
    var start: long = Time.CurrentTimeMilliseconds
TransliterationTest("Latin-Greek", 50).Test("[a-zA-Z]", GetGreekSet, "[µͺϐ-ϵϹ]", self, LegalGreek(true))
ShowElapsed(start, "TestGreek")
proc TestGreekUNGEGN*() =
    var start: long = Time.CurrentTimeMilliseconds
TransliterationTest("Latin-Greek/UNGEGN").Test("[a-zA-Z]", GetGreekSet, "[µͺϐ-￿{Μπ}]", self, LegalGreek(false))
ShowElapsed(start, "TestGreekUNGEGN")
proc Testel*() =
    var start: long = Time.CurrentTimeMilliseconds
TransliterationTest("Latin-el").Test("[a-zA-Z]", GetGreekSet, "[µͺϐ-￿{Μπ}]", self, LegalGreek(false))
ShowElapsed(start, "Testel")
proc TestCyrillic*() =
    var start: long = Time.CurrentTimeMilliseconds
TransliterationTest("Latin-Cyrillic").Test("[a-zA-ZĐđʺʹ]", "[Ѐ-џ]", nil, self, Legal)
ShowElapsed(start, "TestCyrillic")
proc TestArabic*() =
    var start: long = Time.CurrentTimeMilliseconds
TransliterationTest("Latin-Arabic").Test("[a-zA-Zʾʿ]", ARABIC, "[a-zA-Zʾʿⁿ]", nil, self, Legal)
ShowElapsed(start, "TestArabic")
proc TestHebrew*() =
    if FIX_ME:
Errln("TestHebrew needs to be updated to remove delete the [:Age=4.0:] filter ")
    else:
Logln("TestHebrew needs to be updated to remove delete the section marked [:Age=4.0:] filter")
    var start: long = Time.CurrentTimeMilliseconds
TransliterationTest("Latin-Hebrew").Test("[a-zA-Zʼʻ]", "[[[:hebrew:]-[ֽﬀ-ﯿ]]& [:Age=4.0:]]", "[װױײ]", self, LegalHebrew)
ShowElapsed(start, "TestHebrew")
proc TestThai*() =
    var start: long = Time.CurrentTimeMilliseconds
    if FIX_ME:
TransliterationTest("Latin-Thai").Test("[a-zA-Złọæıɨˌ]", "[ก-ฺเ-๛]", "[a-zA-Złọæıɨʹˌ]", nil, self, LegalThai)
    else:
TransliterationTest("Latin-Thai").Test("[a-zA-Złọæıɨˌ]", "[ก-ฺเ-๛]", "[a-zA-Złọæıɨʹˌ]", "[๏]", self, LegalThai)
ShowElapsed(start, "TestThai")
type
  LegalIndic = ref object
    vowelSignSet: UnicodeSet = UnicodeSet
    avagraha: String = "ऽঽઽଽಽ"
    nukta: String = "़়਼઼଼಼"
    virama: String = "्্੍્୍்్್്"
    sanskritStressSigns: String = "॒॑॓॔ॽ"
    chandrabindu: String = "ँঁઁଁఁ"

proc newLegalIndic(): LegalIndic =
vowelSignSet.AddAll(UnicodeSet("[ँंःऄा-ौॢॣ]"))
vowelSignSet.AddAll(UnicodeSet("[ঁংঃা-ৌৢৣৗ]"))
vowelSignSet.AddAll(UnicodeSet("[ਁਂਃਾ-ੌ੢੣ੰੱ]"))
vowelSignSet.AddAll(UnicodeSet("[ઁંઃા-ૌૢૣ]"))
vowelSignSet.AddAll(UnicodeSet("[ଁଂଃା-ୌୢୣୖୗ]"))
vowelSignSet.AddAll(UnicodeSet("[஁ஂஃா-ௌ௢௣ௗ]"))
vowelSignSet.AddAll(UnicodeSet("[ఁంఃా-ౌౢౣౕౖ]"))
vowelSignSet.AddAll(UnicodeSet("[ಁಂಃಾ-ೌೢೣೕೖ]"))
vowelSignSet.AddAll(UnicodeSet("[ഁംഃാ-ൌൢൣൗ]"))
proc Is*(sourceString: String): bool =
    var cp: int = sourceString[0]
    if vowelSignSet.Contains(cp):
        return false

    elif avagraha.IndexOf(cp) != -1:
        return false
    else:
      if virama.IndexOf(cp) != -1:
          return false

      elif nukta.IndexOf(cp) != -1:
          return false
      else:
        if sanskritStressSigns.IndexOf(cp) != -1:
            return false

        elif chandrabindu.IndexOf(cp) != -1 && sourceString.Length > 1 && vowelSignSet.Contains(sourceString[1]):
            return false
    return true
proc TestDevanagariLatin*() =
    var start: long = Time.CurrentTimeMilliseconds
    if FIX_ME:
Errln("FAIL: TestDevanagariLatin needs to be updated to remove delete the [:Age=4.1:] filter ")
        return
Logln("Warning: TestDevanagariLatin needs to be updated to remove delete the section marked [:Age=4.1:] filter")
    var minusDevAbb: String =     if logKnownIssue("cldrbug:4375", nil):
"-[॰]"
    else:
""
TransliterationTest("Latin-DEVANAGARI", 50).Test(latinForIndic, "[[[:Devanagari:][्][।॥]" + minusDevAbb + "]&[:Age=4.1:]]", "[॥ऄ]", self, LegalIndic)
ShowElapsed(start, "TestDevanagariLatin")
proc TestInterIndic*() =
    var start: long = Time.CurrentTimeMilliseconds
    var num: int = interIndicArray.Length
    if IsQuick:
Logln("Testing only 5 of " + interIndicArray.Length + " Skipping rest (use -e for exhaustive)")
        num = 5
    if FIX_ME:
Errln("FAIL: TestInterIndic needs to be updated to remove delete the [:Age=4.1:] filter ")
        return
Logln("Warning: TestInterIndic needs to be updated to remove delete the section marked [:Age=4.1:] filter")
      var i: int = 0
      while i < num:
Logln("Testing " + interIndicArray[i][0] + " at index " + i)
          var minusDevAbb: String =           if logKnownIssue("cldrbug:4375", nil):
"-[॰]"
          else:
""
TransliterationTest(interIndicArray[i][0], 50).Test("[[" + interIndicArray[i][1] + minusDevAbb + "] &[:Age=4.1:]]", "[[" + interIndicArray[i][2] + minusDevAbb + "] &[:Age=4.1:]]", interIndicArray[i][3], self, LegalIndic)
++i
ShowElapsed(start, "TestInterIndic")
type
  Legal = ref object


proc Is*(sourceString: String): bool =
    return true
type
  LegalJamo = ref object


proc Is*(sourceString: String): bool =
    try:
        var t: int
        var decomp: String = Normalizer.Normalize(sourceString, NormalizerMode.NFD)
          var i: int = 0
          while i < decomp.Length:
              case GetType(decomp[i])
              of 0:
                  t = GetType(decomp[i + 1])
                  if t != 0 && t != 1:
                    return false
                  break
              of 1:
                  t = GetType(decomp[i - 1])
                  if t != 0 && t != 1:
                    return false
                  break
              of 2:
                  t = GetType(decomp[i - 1])
                  if t != 1 && t != 2:
                    return false
                  break
++i
        return true
    except IndexOutOfRangeException:
        return false
proc GetType*(c: char): int =
    if '�' <= c && c <= '�':
      return 0

    elif '�' <= c && c <= '�':
      return 1
    else:
      if '�' <= c && c <= '�':
        return 2
    return -1
type
  LegalThai = ref object


proc Is*(sourceString: String): bool =
    if sourceString.Length == 0:
      return true
    var ch: char = sourceString[sourceString.Length - 1]
    if UChar.HasBinaryProperty(ch, UProperty.Logical_Order_Exception):
      return false
    return true
type
  LegalHebrew = ref object
    FINAL: UnicodeSet = UnicodeSet("[ךםןףץ]")
    NON_FINAL: UnicodeSet = UnicodeSet("[כמנפצ]")
    LETTER: UnicodeSet = UnicodeSet("[:letter:]")

proc Is*(sourceString: String): bool =
    if sourceString.Length == 0:
      return true
      var i: int = 0
      while i < sourceString.Length:
          var ch: char = sourceString[i]
          var next: char =           if i + 1 == sourceString.Length:
' '
          else:
sourceString[i]
          if FINAL.Contains(ch):
              if LETTER.Contains(next):
                return false

          elif NON_FINAL.Contains(ch):
              if !LETTER.Contains(next):
                return false
++i
    return true
type
  LegalGreek = ref object
    full: bool
    IOTA_SUBSCRIPT: char = '�'
    breathing: UnicodeSet = UnicodeSet("[\u0313\u0314']")
    validSecondVowel: UnicodeSet = UnicodeSet("[\u03C5\u03B9\u03A5\u0399]")

proc newLegalGreek(full: bool): LegalGreek =
  self.full = full
proc IsVowel*(c: char): bool =
    return "αεηιουωΑΕΗΙΟΥΩ".IndexOf(c) >= 0
proc IsRho*(c: char): bool =
    return "ρΡ".IndexOf(c) >= 0
proc Is*(sourceString: String): bool =
    try:
        var decomp: String = Normalizer.Normalize(sourceString, NormalizerMode.NFD)
        if !full:
              var i: int = 0
              while i < decomp.Length:
                  var c: char = decomp[i]
                  if c == '�' || c == '�' || c == '�' || c == '�' || c == '�' || c == '�':
                    return false
++i
            return true
        var firstIsVowel: bool = false
        var firstIsRho: bool = false
        var noLetterYet: bool = true
        var breathingCount: int = 0
        var letterCount: int = 0
          var i: int = 0
          while i < decomp.Length:
              var c: char = decomp[i]
              if UChar.IsLetter(c):
++letterCount
                  if firstIsVowel && !validSecondVowel.Contains(c) && breathingCount == 0:
                    return false
                  if noLetterYet:
                      noLetterYet = false
                      firstIsVowel = IsVowel(c)
                      firstIsRho = IsRho(c)
                  if firstIsRho && letterCount == 2 && breathingCount == 0:
                    return false
              if c == IOTA_SUBSCRIPT && firstIsVowel && breathingCount == 0:
                return false
              if breathing.Contains(c):
++breathingCount
++i
        if firstIsVowel || firstIsRho:
          return breathingCount == 1
        return breathingCount == 0
    except Exception:
Console.Out.WriteLine(t.GetType.Name + " " + t.ToString)
        return true
type
  TransliterationTest = ref object
    @out: TextWriter
    transliteratorID: String
    errorLimit: int = 500
    errorCount: int = 0
    pairLimit: long = 1000000
    density: int = 100
    sourceRange: UnicodeSet
    targetRange: UnicodeSet
    toSource: UnicodeSet
    toTarget: UnicodeSet
    roundtripExclusions: UnicodeSet
    log: RoundTripTest
    legalSource: Legal
    badCharacters: UnicodeSet
    okAnyway: UnicodeSet = UnicodeSet("[^[:Letter:]]")
    neverOk: UnicodeSet = UnicodeSet("[:Other:]")
    usi: AbbreviatedUnicodeSetIterator = AbbreviatedUnicodeSetIterator
    usi2: AbbreviatedUnicodeSetIterator = AbbreviatedUnicodeSetIterator
    sourceToTarget: Transliterator
    targetToSource: Transliterator

proc newTransliterationTest(transliteratorID: String): TransliterationTest =
newTransliterationTest(transliteratorID, 100)
proc newTransliterationTest(transliteratorID: String, dens: int): TransliterationTest =
  self.transliteratorID = transliteratorID
  self.density = dens
proc SetErrorLimit*(limit: int) =
    errorLimit = limit
proc SetPairLimit*(limit: int) =
    pairLimit = limit
proc IsSame*(a: String, b: String): bool =
    if a.Equals(b):
      return true
    if a.Equals(b, StringComparison.OrdinalIgnoreCase) && IsCamel(a):
      return true
    a = Normalizer.Normalize(a, NormalizerMode.NFD)
    b = Normalizer.Normalize(b, NormalizerMode.NFD)
    if a.Equals(b):
      return true
    if a.Equals(b, StringComparison.OrdinalIgnoreCase) && IsCamel(a):
      return true
    return false
proc IsCamel*(a: String): bool =
    var cp: int
    var haveLower: bool = false
      var i: int = 0
      while i < a.Length:
          cp = UTF16.CharAt(a, i)
          var t: UUnicodeCategory = UChar.GetUnicodeCategory(cp)
          case t
          of UUnicodeCategory.UppercaseLetter:
              if haveLower:
                return true
              break
          of UUnicodeCategory.TitlecaseLetter:
              if haveLower:
                return true
              haveLower = true
              break
          of UUnicodeCategory.LowercaseLetter:
              haveLower = true
              break
          i = UTF16.GetCharCount(cp)
    return false
proc Test*(srcRange: String, trgtRange: String, rdtripExclusions: String, logger: RoundTripTest, legalSrc: Legal) =
Test(srcRange, trgtRange, srcRange, rdtripExclusions, logger, legalSrc)
proc Test*(srcRange: String, trgtRange: String, backtoSourceRange: String, rdtripExclusions: String, logger: RoundTripTest, legalSrc: Legal) =
    legalSource = legalSrc
    sourceRange = UnicodeSet(srcRange)
sourceRange.RemoveAll(neverOk)
    targetRange = UnicodeSet(trgtRange)
targetRange.RemoveAll(neverOk)
    toSource = UnicodeSet(backtoSourceRange)
toSource.AddAll(okAnyway)
    toTarget = UnicodeSet(trgtRange)
toTarget.AddAll(okAnyway)
    if rdtripExclusions != nil && rdtripExclusions.Length > 0:
        roundtripExclusions = UnicodeSet(rdtripExclusions)
    else:
        roundtripExclusions = UnicodeSet
    log = logger
TestFmwk.Logln(Utility.Escape("Source:  " + sourceRange))
TestFmwk.Logln(Utility.Escape("Target:  " + targetRange))
TestFmwk.Logln(Utility.Escape("Exclude: " + roundtripExclusions))
    if TestFmwk.IsQuick:
TestFmwk.Logln("Abbreviated Test")
    badCharacters = UnicodeSet("[:other:]")
    var bast: MemoryStream = MemoryStream
    @out = StreamWriter(bast, Encoding.UTF8)
@out.WriteLine("<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">")
@out.WriteLine("<HTML><HEAD>")
@out.WriteLine("<META content="text/html; charset=utf-8" http-equiv=Content-Type></HEAD>")
@out.WriteLine("<BODY bgcolor='#FFFFFF' style='font-family: Arial Unicode MS'>")
      try:
Test2
      except TestTruncated:
@out.WriteLine(e.ToString)
@out.WriteLine("</BODY></HTML>")
@out.Dispose
      if errorCount > 0:
          try:
              var translitErrorDirectory: DirectoryInfo = DirectoryInfo("translitErrorLogs")
              if !translitErrorDirectory.Exists:
translitErrorDirectory.Create
              var logFileName: String = "translitErrorLogs/test_" + transliteratorID.Replace('/', '_') + ".html"
              var lf: FileInfo = FileInfo(logFileName)
TestFmwk.Logln("Creating log file " + lf.FullName)
                let fos = FileStream(lf.FullName, FileMode.OpenOrCreate, FileAccess.Write)
<unhandled: nnkDefer>
                var bytes = bast.ToArray
fos.Write(bytes, 0, bytes.Length)
TestFmwk.Errln(transliteratorID + " errors: " + errorCount +               if errorCount > errorLimit:
" (at least!)"
              else:
"" + ", see " + lf.FullName)
          except SecurityException:
TestFmwk.Errln(transliteratorID + " errors: " + errorCount +               if errorCount > errorLimit:
" (at least!)"
              else:
"" + ", no log provided due to protected test domain")
      else:
TestFmwk.Logln(transliteratorID + " ok")
proc CheckIrrelevants*(t: Transliterator, irrelevants: String): bool =
      var i: int = 0
      while i < irrelevants.Length:
          var c: char = irrelevants[i]
          var cs: String = UTF16.ValueOf(c)
          var targ: String = t.Transliterate(cs)
          if cs.Equals(targ):
            return true
++i
    return false
proc Test2*() =
    sourceToTarget = Transliterator.GetInstance(transliteratorID)
    targetToSource = sourceToTarget.GetInverse
TestFmwk.Logln("Checking that at least one irrevant characters is not NFC'ed")
@out.WriteLine("<h3>Checking that at least one irrevant characters is not NFC'ed</h3>")
    var irrelevants: String = "  ΩKÅ〈"
    if !CheckIrrelevants(sourceToTarget, irrelevants):
LogFails("" + GetSourceTarget(transliteratorID) + ", Must not NFC everything")
    if !CheckIrrelevants(targetToSource, irrelevants):
LogFails("" + GetTargetSource(transliteratorID) + ", irrelevants")
    if EXTRA_TESTS:
TestFmwk.Logln("Checking that toRules works")
        var rules: String = ""
        var sourceToTarget2: Transliterator
        var targetToSource2: Transliterator
        try:
            rules = sourceToTarget.ToRules(false)
            sourceToTarget2 = Transliterator.CreateFromRules("s2t2", rules, Transliterator.Forward)
            if PRINT_RULES:
@out.WriteLine("<h3>Forward Rules:</h3><p>")
@out.WriteLine(TestUtility.Replace(rules, "
", "‎<br>
‎"))
@out.WriteLine("</p>")
            rules = targetToSource.ToRules(false)
            targetToSource2 = Transliterator.CreateFromRules("t2s2", rules, Transliterator.Forward)
            if PRINT_RULES:
@out.WriteLine("<h3>Backward Rules:</h3><p>")
@out.WriteLine(TestUtility.Replace(rules, "
", "‎<br>
‎"))
@out.WriteLine("</p>")
        except Exception:
@out.WriteLine("<h3>Broken Rules:</h3><p>")
@out.WriteLine(TestUtility.Replace(rules, "
", "<br>
"))
@out.WriteLine("</p>")
@out.Flush
            raise
@out.WriteLine("<h3>Roundtrip Exclusions: " + UnicodeSet(roundtripExclusions) + "</h3>")
@out.Flush
CheckSourceTargetSource(sourceToTarget2)
CheckTargetSourceTarget(targetToSource2)
    var failSourceTarg: UnicodeSet = UnicodeSet
CheckSourceTargetSingles(failSourceTarg)
    var quickRt: bool = CheckSourceTargetDoubles(failSourceTarg)
    var failTargSource: UnicodeSet = UnicodeSet
    var failRound: UnicodeSet = UnicodeSet
CheckTargetSourceSingles(failTargSource, failRound)
CheckTargetSourceDoubles(quickRt, failTargSource, failRound)
proc CheckSourceTargetSource(sourceToTarget2: Transliterator) =
TestFmwk.Logln("Checking that source -> target -> source")
@out.WriteLine("<h3>Checking that source -> target -> source</h3>")
usi.Reset(sourceRange)
    while usi.Next:
        var c: int = usi.Codepoint
        var cs: String = UTF16.ValueOf(c)
        var targ: String = sourceToTarget.Transliterate(cs)
        var targ2: String = sourceToTarget2.Transliterate(cs)
        if !targ.Equals(targ2):
LogToRulesFails("" + GetSourceTarget(transliteratorID) + ", toRules", cs, targ, targ2)
proc CheckTargetSourceTarget(targetToSource2: Transliterator) =
TestFmwk.Logln("Checking that target -> source -> target")
@out.WriteLine("<h3>Checking that target -> source -> target</h3>")
usi.Reset(targetRange)
    while usi.Next:
        var c: int = usi.Codepoint
        var cs: String = UTF16.ValueOf(c)
        var targ: String = targetToSource.Transliterate(cs)
        var targ2: String = targetToSource2.Transliterate(cs)
        if !targ.Equals(targ2):
LogToRulesFails("" + GetTargetSource(transliteratorID) + ", toRules", cs, targ, targ2)
proc CheckSourceTargetSingles(failSourceTarg: UnicodeSet) =
TestFmwk.Logln("Checking that source characters convert to target - Singles")
@out.WriteLine("<h3>Checking that source characters convert to target - Singles</h3>")
usi.Reset(sourceRange)
    while usi.Next:
        var c: int = usi.Codepoint
        var cs: String = UTF16.ValueOf(c)
        var targ: String = sourceToTarget.Transliterate(cs)
        if !toTarget.ContainsAll(targ) || badCharacters.ContainsSome(targ):
            var targD: String = Normalizer.Normalize(targ, NormalizerMode.NFD)
            if !toTarget.ContainsAll(targD) || badCharacters.ContainsSome(targD):
LogWrongScript("" + GetSourceTarget(transliteratorID) + "", cs, targ, toTarget, badCharacters)
failSourceTarg.Add(c)
                continue
        var cs2: String = Normalizer.Normalize(cs, NormalizerMode.NFD)
        var targ2: String = sourceToTarget.Transliterate(cs2)
        if !targ.Equals(targ2):
LogNotCanonical("" + GetSourceTarget(transliteratorID) + "", cs, targ, cs2, targ2)
proc CheckSourceTargetDoubles(failSourceTarg: UnicodeSet): bool =
TestFmwk.Logln("Checking that source characters convert to target - Doubles")
@out.WriteLine("<h3>Checking that source characters convert to target - Doubles</h3>")
    var count: long = 0
    var sourceRangeMinusFailures: UnicodeSet = UnicodeSet(sourceRange)
sourceRangeMinusFailures.RemoveAll(failSourceTarg)
    var quickRt: bool = TestFmwk.GetExhaustiveness < 10
usi.Reset(sourceRangeMinusFailures, quickRt, density)
    while usi.Next:
        var c: int = usi.Codepoint
TestFmwk.Logln(count + "/" + pairLimit + " Checking starting with " + UTF16.ValueOf(c))
usi2.Reset(sourceRangeMinusFailures, quickRt, density)
        while usi2.Next:
            var d: int = usi2.Codepoint
++count
            var cs: String = UTF16.ValueOf(c) + UTF16.ValueOf(d)
            var targ: String = sourceToTarget.Transliterate(cs)
            if !toTarget.ContainsAll(targ) || badCharacters.ContainsSome(targ):
                var targD: String = Normalizer.Normalize(targ, NormalizerMode.NFD)
                if !toTarget.ContainsAll(targD) || badCharacters.ContainsSome(targD):
LogWrongScript("" + GetSourceTarget(transliteratorID) + "", cs, targ, toTarget, badCharacters)
                    continue
            var cs2: String = Normalizer.Normalize(cs, NormalizerMode.NFD)
            var targ2: String = sourceToTarget.Transliterate(cs2)
            if !targ.Equals(targ2):
LogNotCanonical("" + GetSourceTarget(transliteratorID) + "", cs, targ, cs2, targ2)
    return quickRt
proc CheckTargetSourceSingles(failTargSource: UnicodeSet, failRound: UnicodeSet) =
TestFmwk.Logln("Checking that target characters convert to source and back - Singles")
@out.WriteLine("<h3>Checking that target characters convert to source and back - Singles</h3>")
usi.Reset(targetRange)
    while usi.Next:
        var cs: String
        var c: int
        if usi.Codepoint == UnicodeSetIterator.IsString:
            cs = usi.String
            c = UTF16.CharAt(cs, 0)
        else:
            c = usi.Codepoint
            cs = UTF16.ValueOf(c)
        var targ: String = targetToSource.Transliterate(cs)
        var reverse: String = sourceToTarget.Transliterate(targ)
        if !toSource.ContainsAll(targ) || badCharacters.ContainsSome(targ):
            var targD: String = Normalizer.Normalize(targ, NormalizerMode.NFD)
            if !toSource.ContainsAll(targD) || badCharacters.ContainsSome(targD):
UnicodeSet.AddAll(targD)
LogWrongScript("" + GetTargetSource(transliteratorID) + "", cs, targ, toSource, badCharacters)
failTargSource.Add(cs)
                continue
        if !IsSame(cs, reverse) && !roundtripExclusions.Contains(c) && !roundtripExclusions.Contains(cs):
LogRoundTripFailure(cs, targetToSource.ID, targ, sourceToTarget.ID, reverse)
failRound.Add(c)
            continue
        var targ2: String = Normalizer.Normalize(targ, NormalizerMode.NFD)
        var reverse2: String = sourceToTarget.Transliterate(targ2)
        if !reverse.Equals(reverse2):
LogNotCanonical("" + GetTargetSource(transliteratorID) + "", targ, reverse, targ2, reverse2)
proc CheckTargetSourceDoubles(quickRt: bool, failTargSource: UnicodeSet, failRound: UnicodeSet) =
TestFmwk.Logln("Checking that target characters convert to source and back - Doubles")
@out.WriteLine("<h3>Checking that target characters convert to source and back - Doubles</h3>")
    var count: long = 0
    var targetRangeMinusFailures: UnicodeSet = UnicodeSet(targetRange)
targetRangeMinusFailures.RemoveAll(failTargSource)
targetRangeMinusFailures.RemoveAll(failRound)
usi.Reset(targetRangeMinusFailures, quickRt, density)
    while usi.Next:
        var c: int = usi.Codepoint
TestFmwk.Logln(count + "/" + pairLimit + " Checking starting with " + UTF16.ValueOf(c))
usi2.Reset(targetRangeMinusFailures, quickRt, density)
        while usi2.Next:
            var d: int = usi2.Codepoint
            if d < 0:
              break
            if ++count > pairLimit:
                raise TestTruncated("Test truncated at " + pairLimit)
            var cs: String = UTF16.ValueOf(c) + UTF16.ValueOf(d)
            var targ: String = targetToSource.Transliterate(cs)
            var reverse: String = sourceToTarget.Transliterate(targ)
            if !toSource.ContainsAll(targ) || badCharacters.ContainsSome(targ):
                var targD: String = Normalizer.Normalize(targ, NormalizerMode.NFD)
                if !toSource.ContainsAll(targD) || badCharacters.ContainsSome(targD):
LogWrongScript("" + GetTargetSource(transliteratorID) + "", cs, targ, toSource, badCharacters)
                    continue
            if !IsSame(cs, reverse) && !roundtripExclusions.Contains(c) && !roundtripExclusions.Contains(d) && !roundtripExclusions.Contains(cs):
LogRoundTripFailure(cs, targetToSource.ID, targ, sourceToTarget.ID, reverse)
                continue
            var targ2: String = Normalizer.Normalize(targ, NormalizerMode.NFD)
            var reverse2: String = sourceToTarget.Transliterate(targ2)
            if !reverse.Equals(reverse2):
LogNotCanonical("" + GetTargetSource(transliteratorID) + "", targ, reverse, targ2, reverse2)
TestFmwk.Logln("")
proc GetTargetSource(transliteratorID2: String): String =
    return "Target-Source [" + transliteratorID2 + "]"
proc GetSourceTarget(transliteratorID2: String): String =
    return "Source-Target [" + transliteratorID2 + "]"
proc Info(s: string): string =
    var result: StringBuffer = StringBuffer
result.Append("‎").Append(s).Append("‎ (").Append(TestUtility.Hex(s)).Append("/")
    if false:
        var cp: int = 0
          var i: int = 0
          while i < s.Length:
              cp = UTF16.CharAt(s, i)
              if i > 0:
result.Append(", ")
result.Append(UChar.GetAge(cp))
              i = UTF16.GetCharCount(cp)
result.Append(")")
    return result.ToString
proc LogWrongScript(label: String, from: String, to: String, shouldContainAll: UnicodeSet, shouldNotContainAny: UnicodeSet) =
    if ++errorCount > errorLimit:
        raise TestTruncated("Test truncated; too many failures")
    var toD: String = Normalizer.Normalize(to, NormalizerMode.NFD)
    var temp: UnicodeSet = UnicodeSet.AddAll(toD)
    var bad: UnicodeSet = UnicodeSet(shouldNotContainAny).RetainAll(temp).AddAll(UnicodeSet(temp).RemoveAll(shouldContainAll))
@out.WriteLine("<br>Fail " + label + ": " + Info(from) + " => " + Info(to) + " " + bad)
proc LogNotCanonical(label: String, from: String, to: String, fromCan: String, toCan: String) =
    if ++errorCount > errorLimit:
        raise TestTruncated("Test truncated; too many failures")
@out.WriteLine("<br>Fail (can.equiv) " + label + ": " + Info(from) + " => " + Info(to) + " -- " + Info(fromCan) + " => " + Info(toCan) + ")")
proc LogFails(label: String) =
    if ++errorCount > errorLimit:
        raise TestTruncated("Test truncated; too many failures")
@out.WriteLine("<br>Fail (can.equiv)" + label)
proc LogToRulesFails(label: String, from: String, to: String, toCan: String) =
    if ++errorCount > errorLimit:
        raise TestTruncated("Test truncated; too many failures")
@out.WriteLine("<br>Fail " + label + ": " + Info(from) + " => " + Info(to) + ", " + Info(toCan))
proc LogRoundTripFailure(from: String, toID: String, to: String, backID: String, back: String) =
    if !legalSource.Is(from):
      return
    if ++errorCount > errorLimit:
        raise TestTruncated("Test truncated; too many failures")
@out.WriteLine("<br>Fail Roundtrip: " + Info(from) + " " + toID + " => " + Info(to) + " " + backID + " => " + Info(back))
type
  TestTruncated = ref object


proc newTestTruncated(msg: String): TestTruncated =
newException(msg)