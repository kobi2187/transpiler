# "Namespace: ICU4N.Dev.Test.Translit"
type
  CompoundTransliteratorTest = ref object


proc TestConstruction*() =
Logln("Testing the construction of the compound Transliterator")
    var names: String[] = @["Greek-Latin", "Latin-Devanagari", "Devanagari-Latin", "Latin-Greek"]
    try:
Transliterator.GetInstance(names[0])
Transliterator.GetInstance(names[1])
Transliterator.GetInstance(names[2])
Transliterator.GetInstance(names[3])
    except ArgumentException:
Errln("FAIL: Transliterator construction failed" + ex.ToString)
        raise
    var IDs: string[] = @[names[0], names[0] + ";" + names[3], names[3] + ";" + names[1] + ";" + names[2], names[0] + ";" + names[1] + ";" + names[2] + ";" + names[3]]
      var i: int = 0
      while i < 4:
          try:
Transliterator.GetInstance(IDs[i])
          except ArgumentException:
Errln("FAIL: construction using CompoundTransliterator(String ID) failed for " + IDs[i])
              raise
          try:
Transliterator.GetInstance(IDs[i], Transliterator.Forward)
          except ArgumentException:
Errln("FAIL: construction using CompoundTransliterator(String ID, int direction=FORWARD) failed for " + IDs[i])
              raise
          try:
Transliterator.GetInstance(IDs[i], Transliterator.Reverse)
          except ArgumentException:
Errln("FAIL: construction using CompoundTransliterator(String ID, int direction=REVERSE) failed for " + IDs[i])
              raise
++i
proc TestGetTransliterator*() =
Logln("Testing the getTransliterator() API of CompoundTransliterator")
    var ID: String = "Latin-Greek;Greek-Latin;Latin-Devanagari;Devanagari-Latin;Latin-Cyrillic;Cyrillic-Latin;Any-Hex;Hex-Any"
    var ct1: Transliterator = nil
    try:
        ct1 = Transliterator.GetInstance(ID)
    except ArgumentException:
Errln("CompoundTransliterator construction failed for ID=" + ID)
        raise
    var elems: Transliterator[] = ct1.GetElements
    var count: int = elems.Length
    var array: String[] = split(ID, ';')
    if count != array.Length:
Errln("Error: getCount() failed. Expected:" + array.Length + " got:" + count)
      var i: int = 0
      while i < count:
          var child: String = elems[i].ID
          if !child.Equals(array[i]):
Errln("Error getTransliterator() failed: Expected->" + array[i] + " Got->" + child)
          else:
Logln("OK: getTransliterator() passed: Expected->" + array[i] + " Got->" + child)
++i
proc TestTransliterate*() =
Logln("Testing the handleTransliterate() API of CompoundTransliterator")
    var ct1: Transliterator = nil
    try:
        ct1 = Transliterator.GetInstance("Any-Hex;Hex-Any")
    except ArgumentException:
Errln("FAIL: construction using CompoundTransliterator(String ID) failed for " + "Any-Hex;Hex-Any")
        raise
    var s: String = "abcabc"
expect(ct1, s, s)
    var index: TransliterationPosition = TransliterationPosition
    var rsource2: ReplaceableString = ReplaceableString(s)
    var expectedResult: String = s
ct1.Transliterate(rsource2, index)
ct1.FinishTransliteration(rsource2, index)
    var result: String = rsource2.ToString
expectAux(ct1.ID + ":ReplaceableString, index(0,0,0,0)", s + "->" + rsource2, result.Equals(expectedResult), expectedResult)
    var index2: TransliterationPosition = TransliterationPosition(1, 3, 2, 3)
    var rsource3: ReplaceableString = ReplaceableString(s)
ct1.Transliterate(rsource3, index2)
ct1.FinishTransliteration(rsource3, index2)
    result = rsource3.ToString
expectAux(ct1.ID + ":String, index2(1,2,2,3)", s + "->" + rsource3, result.Equals(expectedResult), expectedResult)
    var Data: String[] = @["Any-Hex;Hex-Any;Any-Hex", "hello", "\u0068\u0065\u006C\u006C\u006F", "Any-Hex;Hex-Any", "hello! How are you?", "hello! How are you?", "Devanagari-Latin;Latin-Devanagari", "भै'र'व", "भैरव", "Latin-Cyrillic;Cyrillic-Latin", "a'b'k'd'e'f'g'h'i'j'Shch'shch'zh'h", "a'b'k'd'e'f'g'h'i'j'Shch'shch'zh'h", "Latin-Greek;Greek-Latin", "ABGabgAKLMN", "ABGabgAKLMN", "Hiragana-Katakana", "ぁわ゙のかを゙", "ァヷノカヺ", "Hiragana-Katakana;Katakana-Hiragana", "ぁわ゙のかけ", "ぁわ゙のかけ", "Katakana-Hiragana;Hiragana-Katakana", "ァヷノヵヶ", "ァヷノカケ", "Latin-Katakana;Katakana-Latin", "vavivuvevohuzizuzoninunasesuzezu", "vavivuvevohuzizuzoninunasesuzezu"]
    var ct2: Transliterator = nil
      var i: int = 0
      while i < Data.Length:
          try:
              ct2 = Transliterator.GetInstance(Data[i + 0])
          except ArgumentException:
Errln("FAIL: CompoundTransliterator construction failed for " + Data[i + 0])
              raise
expect(ct2, Data[i + 1], Data[i + 2])
          i = 3
proc split(s: String, divider: char): String[] =
    var count: int = 1
      var i: int = 0
      while i < s.Length:
          if s[i] == divider:
++count
++i
      var result: String[] = seq[String]
      var last: int = 0
      var current: int = 0
      var i: int
        i = 0
        while i < s.Length:
            if s[i] == divider:
                result[++current] = s.Substring(last, i - last)
                last = i + 1
++i
      result[++current] = s.Substring(last, i - last)
      return result
proc expect(t: Transliterator, source: String, expectedResult: String) =
    var result: String = t.Transliterate(source)
expectAux(t.ID + ":String", source, result, expectedResult)
    var rsource: ReplaceableString = ReplaceableString(source)
t.Transliterate(rsource)
    result = rsource.ToString
expectAux(t.ID + ":Replaceable", source, result, expectedResult)
rsource.Replace(0, rsource.Length - 0, "")
    var index: TransliterationPosition = TransliterationPosition
    var log: ValueStringBuilder = ValueStringBuilder(newSeq[char](32))
    try:
          var i: int = 0
          while i < source.Length:
              if i != 0:
log.Append(" + ")
log.Append(source[i])
log.Append(" -> ")
t.Transliterate(rsource, index, source[i])
              var s: string = rsource.ToString
log.Append(s.AsSpan(0, index.Start))
log.Append('|')
log.Append(s.AsSpan(index.Start))
++i
t.FinishTransliteration(rsource, index)
        result = rsource.ToString
log.Append(" => ")
log.Append(rsource.ToString)
expectAux(t.ID + ":Keyboard", log.ToString, result.Equals(expectedResult), expectedResult)
    finally:
log.Dispose
proc expectAux(tag: String, source: String, result: String, expectedResult: String) =
expectAux(tag, source + " -> " + result, result.Equals(expectedResult), expectedResult)
proc expectAux(tag: String, summary: String, pass: bool, expectedResult: String) =
    if pass:
Logln("(" + tag + ") " + Utility.Escape(summary))
    else:
Errln("FAIL: (" + tag + ") " + Utility.Escape(summary) + ", expected " + Utility.Escape(expectedResult))