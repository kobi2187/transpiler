# "Namespace: ICU4N.Dev.Test.Translit"
type
  JamoTest = ref object
    WHAT_IS_UNICODE: String = "유니코드에 대해 ? " + "어떤 플랫폼, 어떤 " + "프로그램, 어떤 언어에도 " + "상관없이 유니코드는 모든 " + "문자에 대해 고유 번호를 " + "제공합니다. " + "기본적으로 컴퓨터는 " + "숫자만 처리합니다. 글자나 " + "다른 문자에도 숫자를 " + "지정하여 " + "저장합니다. 유니코드가 " + "개발되기 전에는 이러한 " + "숫자를 지정하기 위해 수백 " + "가지의 다른 기호화 " + "시스템을 " + "사용했습니다. 단일 기호화 " + "방법으로는 모든 문자를 " + "포함할 수 없었습니다. 예를 " + "들어 유럽 연합에서만 " + "보더라도 모든 각 나라별 " + "언어를 처리하려면 여러 " + "개의 다른 기호화 방법이 " + "필요합니다. 영어와 같은 " + "단일 언어의 경우도 " + "공통적으로 사용되는 모든 " + "글자, 문장 부호 및 " + "테크니컬 기호에 맞는 단일 " + "기호화 방법을 갖고 있지 " + "못하였습니다. " + "이러한 기호화 시스템은 " + "또한 다른 기호화 시스템과 " + "충돌합니다. 즉 두 가지 " + "기호화 방법이 두 개의 다른 " + "문자에 대해 같은 번호를 " + "사용하거나 같은 문자에 " + "대해 다른 번호를 사용할 수 " + "있습니다. 주어진 모든 " + "컴퓨터(특히 서버)는 서로 " + "다른 여러 가지 기호화 " + "방법을 지원해야 " + "합니다. 그러나, 데이터를 " + "서로 다른 기호화 방법이나 " + "플랫폼 간에 전달할 때마다 " + "그 데이터는 항상 손상의 " + "위험을 겪게 됩니다. " + "유니코드로 모든 것을 " + "해결할 수 있습니다! " + "유니코드는 사용 중인 " + "플랫폼, 프로그램, 언어에 " + "관계없이 문자마다 고유한 " + "숫자를 " + "제공합니다. 유니코드 " + "표준은 " + "및 기타 여러 " + "회사와 같은 업계 " + "선두주자에 의해 " + "채택되었습니다. 유니코드는 " + "등과 " + "같이 현재 널리 사용되는 " + "표준에서 필요하며 이는 " + "10646을 구현하는 공식적인 " + "방법입니다. 이는 많은 운영 " + "체제, 요즘 사용되는 모든 " + "브라우저 및 기타 많은 " + "제품에서 " + "지원됩니다. 유니코드 " + "표준의 부상과 이를 " + "지원하는 도구의 가용성은 " + "최근 전 세계에 불고 있는 " + "기술 경향에서 가장 중요한 " + "부분을 차지하고 있습니다. " + "유니코드를 " + "클라이언트 서버 또는 " + "다중 연결 응용 프로그램과 " + "웹 사이트에 통합하면 " + "레거시 문자 세트 사용에 " + "있어서 상당한 비용 절감 " + "효과가 " + "나타납니다. 유니코드를 " + "통해 리엔지니어링 없이 " + "다중 플랫폼, 언어 및 국가 " + "간에 단일 소프트웨어 " + "플랫폼 또는 단일 웹 " + "사이트를 목표로 삼을 수 " + "있습니다. 이를 사용하면 " + "데이터를 손상 없이 여러 " + "시스템을 통해 전송할 수 " + "있습니다. " + "유니코드 콘소시엄에 대해 " + "유니코드 콘소시엄은 " + "비영리 조직으로서 현대 " + "소프트웨어 제품과 " + "표준에서 텍스트의 표현을 " + "지정하는 유니코드 표준의 " + "사용을 개발하고 확장하며 " + "장려하기 위해 " + "세워졌습니다. 콘소시엄 " + "멤버쉽은 컴퓨터와 정보 " + "처리 산업에 종사하고 있는 " + "광범위한 회사 및 조직의 " + "범위를 " + "나타냅니다. 콘소시엄의 " + "재정은 전적으로 회비에 " + "의해 충당됩니다. 유니코드 " + "컨소시엄에서의 멤버쉽은 " + "전 세계 어느 곳에서나 " + "유니코드 표준을 지원하고 " + "그 확장과 구현을 " + "지원하고자하는 조직과 " + "개인에게 개방되어 " + "있습니다. " + "더 자세한 내용은 용어집, " + "예제 유니코드 사용 가능 " + "제품, 기술 정보 및 기타 " + "유용한 정보를 " + "참조하십시오."
    JAMO_NAMES: seq[String] = @["(Gi)", "ᄀ", "(GGi)", "ᄁ", "(Ni)", "ᄂ", "(Di)", "ᄃ", "(DD)", "ᄄ", "(R)", "ᄅ", "(Mi)", "ᄆ", "(Bi)", "ᄇ", "(BB)", "ᄈ", "(Si)", "ᄉ", "(SSi)", "ᄊ", "(IEUNG)", "ᄋ", "(Ji)", "ᄌ", "(JJ)", "ᄍ", "(Ci)", "ᄎ", "(Ki)", "ᄏ", "(Ti)", "ᄐ", "(Pi)", "ᄑ", "(Hi)", "ᄒ", "(A)", "ᅡ", "(AE)", "ᅢ", "(YA)", "ᅣ", "(YAE)", "ᅤ", "(EO)", "ᅥ", "(E)", "ᅦ", "(YEO)", "ᅧ", "(YE)", "ᅨ", "(O)", "ᅩ", "(WA)", "ᅪ", "(WAE)", "ᅫ", "(OE)", "ᅬ", "(YO)", "ᅭ", "(U)", "ᅮ", "(WEO)", "ᅯ", "(WE)", "ᅰ", "(WI)", "ᅱ", "(YU)", "ᅲ", "(EU)", "ᅳ", "(YI)", "ᅴ", "(I)", "ᅵ", "(Gf)", "ᆨ", "(GGf)", "ᆩ", "(GS)", "ᆪ", "(Nf)", "ᆫ", "(NJ)", "ᆬ", "(NH)", "ᆭ", "(Df)", "ᆮ", "(L)", "ᆯ", "(LG)", "ᆰ", "(LM)", "ᆱ", "(LB)", "ᆲ", "(LS)", "ᆳ", "(LT)", "ᆴ", "(LP)", "ᆵ", "(LH)", "ᆶ", "(Mf)", "ᆷ", "(Bf)", "ᆸ", "(BS)", "ᆹ", "(Sf)", "ᆺ", "(SSf)", "ᆻ", "(NG)", "ᆼ", "(Jf)", "ᆽ", "(Cf)", "ᆾ", "(Kf)", "ᆿ", "(Tf)", "ᇀ", "(Pf)", "ᇁ", "(Hf)", "ᇂ"]
    JAMO_TO_NAME: IDictionary[string, string] = LoadJamoToName
    NAME_TO_JAMO: IDictionary[string, string] = LoadNameToJamo

proc TestJamo*() =
    var latinJamo: Transliterator = Transliterator.GetInstance("Latin-Jamo")
    var jamoLatin: Transliterator = latinJamo.GetInverse
    var CASE: String[] = @["gach", "(Gi)(A)(Cf)", nil, "geumhui", "(Gi)(EU)(Mf)(Hi)(YI)", nil, "choe", "(Ci)(OE)", nil, "wo", "(IEUNG)(WEO)", nil, "Wonpil", "(IEUNG)(WEO)(Nf)(Pi)(I)(L)", "wonpil", "GIPPEUM", "(Gi)(I)(BB)(EU)(Mf)", "gippeum", "EUTTEUM", "(IEUNG)(EU)(DD)(EU)(Mf)", "eutteum", "KKOTNAE", "(GGi)(O)(Tf)(Ni)(AE)", "kkotnae", "gaga", "(Gi)(A)(Gi)(A)", nil, "gag-a", "(Gi)(A)(Gf)(IEUNG)(A)", nil, "gak-ka", "(Gi)(A)(Kf)(Ki)(A)", nil, "gakka", "(Gi)(A)(GGi)(A)", nil, "gakk-a", "(Gi)(A)(GGf)(IEUNG)(A)", nil, "gakkka", "(Gi)(A)(GGf)(Ki)(A)", nil, "gak-kka", "(Gi)(A)(Kf)(GGi)(A)", nil, "bab", "(Bi)(A)(Bf)", nil, "babb", "(Bi)(A)(Bf)(Bi)(EU)", "babbeu", "babbba", "(Bi)(A)(Bf)(Bi)(EU)(Bi)(A)", "babbeuba", "bagg", "(Bi)(A)(Gf)(Gi)(EU)", "baggeu", "baggga", "(Bi)(A)(Gf)(Gi)(EU)(Gi)(A)", "baggeuga", "kabsa", "(Ki)(A)(Bf)(Si)(A)", nil, "kabska", "(Ki)(A)(BS)(Ki)(A)", nil, "gabsbka", "(Gi)(A)(BS)(Bi)(EU)(Ki)(A)", "gabsbeuka", "gga", "(Gi)(EU)(Gi)(A)", "geuga", "bsa", "(Bi)(EU)(Si)(A)", "beusa", "agg", "(IEUNG)(A)(Gf)(Gi)(EU)", "aggeu", "agga", "(IEUNG)(A)(Gf)(Gi)(A)", nil, "la", "(R)(A)", nil, "bs", "(Bi)(EU)(Sf)", "beus", "kalgga", "(Ki)(A)(L)(Gi)(EU)(Gi)(A)", "kalgeuga", "karka", "(Ki)(A)(L)(Ki)(A)", "kalka"]
      var i: int = 0
      while i < CASE.Length:
          var jamo: String = nameToJamo(CASE[i + 1])
          if CASE[i + 2] == nil:
TransliteratorTest.Expect(latinJamo, CASE[i], jamo, jamoLatin)
          else:
TransliteratorTest.Expect(latinJamo, CASE[i], jamo)
TransliteratorTest.Expect(jamoLatin, jamo, CASE[i + 2])
          i = 3
proc TestRoundTrip*() =
    var HANGUL: String[] = @["갃싸", "아어"]
    var latinJamo: Transliterator = Transliterator.GetInstance("Latin-Jamo")
    var jamoLatin: Transliterator = latinJamo.GetInverse
    var jamoHangul: Transliterator = Transliterator.GetInstance("NFC")
    var hangulJamo: Transliterator = Transliterator.GetInstance("NFD")
    var buf: StringBuffer = StringBuffer
      var i: int = 0
      while i < HANGUL.Length:
          var hangul: String = HANGUL[i]
          var jamo: String = hangulJamo.Transliterate(hangul)
          var latin: String = jamoLatin.Transliterate(jamo)
          var jamo2: String = latinJamo.Transliterate(latin)
          var hangul2: String = jamoHangul.Transliterate(jamo2)
          buf.Length = 0
buf.Append(hangul + " => " + jamoToName(jamo) + " => " + latin + " => " + jamoToName(jamo2) + " => " + hangul2)
          if !hangul.Equals(hangul2):
Errln("FAIL: " + Utility.Escape(buf.ToString))
          else:
Logln(Utility.Escape(buf.ToString))
++i
proc TestPiecemeal*() =
    var hangul: String = "및"
    var jamo: String = nameToJamo("(Mi)(I)(Cf)")
    var latin: String = "mic"
    var latin2: String = "mich"
    var t: Transliterator = nil
    t = Transliterator.GetInstance("NFD")
TransliteratorTest.Expect(t, hangul, jamo)
    t = Transliterator.GetInstance("NFC")
TransliteratorTest.Expect(t, jamo, hangul)
    t = Transliterator.GetInstance("Latin-Jamo")
TransliteratorTest.Expect(t, latin, jamo)
    t = Transliterator.GetInstance("Jamo-Latin")
TransliteratorTest.Expect(t, jamo, latin2)
    t = Transliterator.GetInstance("Hangul-Latin")
TransliteratorTest.Expect(t, hangul, latin2)
    t = Transliterator.GetInstance("Latin-Hangul")
TransliteratorTest.Expect(t, latin, hangul)
    t = Transliterator.GetInstance("Hangul-Latin; Latin-Jamo")
TransliteratorTest.Expect(t, hangul, jamo)
    t = Transliterator.GetInstance("Jamo-Latin; Latin-Hangul")
TransliteratorTest.Expect(t, jamo, hangul)
    t = Transliterator.GetInstance("Hangul-Latin; Latin-Hangul")
TransliteratorTest.Expect(t, hangul, hangul)
proc TestRealText*() =
    var latinJamo: Transliterator = Transliterator.GetInstance("Latin-Jamo")
    var jamoLatin: Transliterator = latinJamo.GetInverse
    var jamoHangul: Transliterator = Transliterator.GetInstance("NFC")
    var hangulJamo: Transliterator = Transliterator.GetInstance("NFD")
    var rt: Transliterator = Transliterator.GetInstance("NFD;Jamo-Latin;Latin-Jamo;NFC")
    var pos: int = 0
    var buf: StringBuffer = StringBuffer
    var total: int = 0
    var errors: int = 0
    while pos < WHAT_IS_UNICODE.Length:
        var space: int = WHAT_IS_UNICODE.IndexOf(' ', pos + 1)
        if space < 0:
            space = WHAT_IS_UNICODE.Length
        if pos < space:
++total
            var hangul: String = WHAT_IS_UNICODE.Substring(pos, space - pos)
            var hangulX: String = rt.Transliterate(hangul)
            if !hangul.Equals(hangulX):
++errors
                var jamo: String = hangulJamo.Transliterate(hangul)
                var latin: String = jamoLatin.Transliterate(jamo)
                var jamo2: String = latinJamo.Transliterate(latin)
                var hangul2: String = jamoHangul.Transliterate(jamo2)
                if hangul.Equals(hangul2):
                    buf.Length = 0
buf.Append("FAIL (Compound transliterator problem): ")
buf.Append(hangul + " => " + jamoToName(jamo) + " => " + latin + " => " + jamoToName(jamo2) + " => " + hangul2 + "; but " + hangul + " =cpd=> " + jamoToName(hangulX))
Errln(Utility.Escape(buf.ToString))

                elif jamo.Equals(jamo2):
                    buf.Length = 0
buf.Append("FAIL (Jamo<>Hangul problem): ")
                    if !hangul2.Equals(hangulX):
buf.Append("(Weird: " + hangulX + " != " + hangul2 + ")")
buf.Append(hangul + " => " + jamoToName(jamo) + " => " + latin + " => " + jamoToName(jamo2) + " => " + hangul2)
Errln(Utility.Escape(buf.ToString))
                else:
                    buf.Length = 0
buf.Append("FAIL: ")
                    if !hangul2.Equals(hangulX):
buf.Append("(Weird: " + hangulX + " != " + hangul2 + ")")
buf.Append(jamoToName(jamo) + " => " + latin + " => " + jamoToName(jamo2))
Errln(Utility.Escape(buf.ToString))
        pos = space + 1
    if errors != 0:
Errln("Test word failures: " + errors + " out of " + total)
    else:
Logln("All " + total + " test words passed")
proc expectAux(tag: String, summary: String, pass: bool, expectedResult: String): bool =
    return TransliteratorTest.ExpectAux(tag, jamoToName(summary), pass, jamoToName(expectedResult))
proc LoadJamoToName(): IDictionary<string, string> =
    var result = Dictionary<string, string>
      var i: int = 0
      while i < JAMO_NAMES.Length:
          result[JAMO_NAMES[i + 1]] = JAMO_NAMES[i]
          i = 2
    return result
proc LoadNameToJamo(): IDictionary<string, string> =
    var result = Dictionary<string, string>
      var i: int = 0
      while i < JAMO_NAMES.Length:
          result[JAMO_NAMES[i]] = JAMO_NAMES[i + 1]
          i = 2
    return result
proc nameToJamo(input: String): String =
    var buf: StringBuffer = StringBuffer
      var i: int = 0
      while i < input.Length:
          var c: char = input[i]
          if c == '(':
              var j: int = input.IndexOf(')', i + 1)
              if j - i >= 2 && j - i <= 6:
                  if NAME_TO_JAMO.TryGetValue(input.Substring(i, j + 1 - i),                   var jamo: string) && jamo != nil:
buf.Append(jamo)
                      i = j
                      continue
buf.Append(c)
++i
    return buf.ToString
proc jamoToName(input: String): String =
    var buf: StringBuffer = StringBuffer
      var i: int = 0
      while i < input.Length:
          var c: char = input[i]
          if c >= 4352 && c <= 4546:
              if JAMO_TO_NAME.TryGetValue(input.Substring(i, 1),               var name: string) && name != nil:
buf.Append(name)
                  continue
buf.Append(c)
++i
    return buf.ToString