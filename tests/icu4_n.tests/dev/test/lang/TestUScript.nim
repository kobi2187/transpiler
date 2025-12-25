# "Namespace: ICU4N.Dev.Test.Lang"
type
  TestUScript = ref object


proc newTestUScript(): TestUScript =

proc TestGetScriptOfCharsWithScriptExtensions*() =
    if !UScript.Common == UScript.GetScript(1600) && UScript.Inherited == UScript.GetScript(1616) && UScript.Arabic == UScript.GetScript(65010):
Errln("UScript.getScript(character with Script_Extensions) failed")
proc TestHasScript*() =
    if !!UScript.HasScript(1599, UScript.Common) && UScript.HasScript(1599, UScript.Arabic) && !UScript.HasScript(1599, UScript.Syriac) && !UScript.HasScript(1599, UScript.Thaana):
Errln("UScript.hasScript(U+063F, ...) is wrong")
    if !!UScript.HasScript(1600, UScript.Common) && UScript.HasScript(1600, UScript.Arabic) && UScript.HasScript(1600, UScript.Syriac) && !UScript.HasScript(1600, UScript.Thaana):
Errln("UScript.hasScript(U+0640, ...) is wrong")
    if !!UScript.HasScript(1616, UScript.Inherited) && UScript.HasScript(1616, UScript.Arabic) && UScript.HasScript(1616, UScript.Syriac) && !UScript.HasScript(1616, UScript.Thaana):
Errln("UScript.hasScript(U+0650, ...) is wrong")
    if !!UScript.HasScript(1632, UScript.Common) && UScript.HasScript(1632, UScript.Arabic) && !UScript.HasScript(1632, UScript.Syriac) && UScript.HasScript(1632, UScript.Thaana):
Errln("UScript.hasScript(U+0660, ...) is wrong")
    if !!UScript.HasScript(65010, UScript.Common) && UScript.HasScript(65010, UScript.Arabic) && !UScript.HasScript(65010, UScript.Syriac) && UScript.HasScript(65010, UScript.Thaana):
Errln("UScript.hasScript(U+FDF2, ...) is wrong")
    if UScript.HasScript(1600, 45054):
Errln("UScript.hasScript(U+0640, bogus 0xaffe) is wrong")
proc TestGetScriptExtensions*() =
    var scripts: BitArray = BitArray(UScript.CodeLimit)
    if UScript.GetScriptExtensions(-1, scripts) != UScript.Unknown || scripts.Cardinality != 1 || !scripts.Get(UScript.Unknown):
Errln("UScript.getScriptExtensions(-1) is not {UNKNOWN}")
    if UScript.GetScriptExtensions(1114112, scripts) != UScript.Unknown || scripts.Cardinality != 1 || !scripts.Get(UScript.Unknown):
Errln("UScript.getScriptExtensions(0x110000) is not {UNKNOWN}")
    if UScript.GetScriptExtensions(1599, scripts) != UScript.Arabic || scripts.Cardinality != 1 || !scripts.Get(UScript.Arabic):
Errln("UScript.getScriptExtensions(U+063F) is not {ARABIC}")
    if UScript.GetScriptExtensions(1600, scripts) > -3 || scripts.Cardinality < 3 || !scripts.Get(UScript.Arabic) || !scripts.Get(UScript.Syriac) || !scripts.Get(UScript.Mandaic):
Errln("UScript.getScriptExtensions(U+0640) failed")
    if UScript.GetScriptExtensions(65010, scripts) != -2 || scripts.Cardinality != 2 || !scripts.Get(UScript.Arabic) || !scripts.Get(UScript.Thaana):
Errln("UScript.getScriptExtensions(U+FDF2) failed")
    if UScript.GetScriptExtensions(65381, scripts) != -6 || scripts.Cardinality != 6 || !scripts.Get(UScript.Bopomofo) || !scripts.Get(UScript.Yi):
Errln("UScript.getScriptExtensions(U+FF65) failed")
proc TestScriptMetadataAPI*() =
    var sample: String = UScript.GetSampleString(UScript.Latin)
    if sample.Length != 1 || UScript.GetScript(sample[0]) != UScript.Latin:
Errln("UScript.GetSampleString(Latn) failed")
    sample = UScript.GetSampleString(UScript.InvalidCode)
    if sample.Length != 0:
Errln("UScript.GetSampleString(invalid) failed")
    var buffer: Span<char> = newSeq[char](2)
    var sampleSpan: ReadOnlySpan<char> = UScript.GetSampleSpan(UScript.Latin, buffer)
    if sampleSpan.Length != 1 || UScript.GetScript(sampleSpan[0]) != UScript.Latin:
Errln("UScript.GetSampleSpan(Latn) failed")
    sampleSpan = UScript.GetSampleSpan(UScript.InvalidCode, buffer)
    if sampleSpan.Length != 0:
Errln("UScript.GetSampleSpan(invalid) failed")
    if UScript.GetUsage(UScript.Latin) != ScriptUsage.Recommended || UScript.GetUsage(UScript.Yi) != ScriptUsage.LimitedUse || UScript.GetUsage(UScript.Cherokee) != ScriptUsage.LimitedUse || UScript.GetUsage(UScript.Coptic) != ScriptUsage.Excluded || UScript.GetUsage(UScript.Cirth) != ScriptUsage.NotEncoded || UScript.GetUsage(UScript.InvalidCode) != ScriptUsage.NotEncoded || UScript.GetUsage(UScript.CodeLimit) != ScriptUsage.NotEncoded:
Errln("UScript.getUsage() failed")
    if UScript.IsRightToLeft(UScript.Latin) || UScript.IsRightToLeft(UScript.Cirth) || !UScript.IsRightToLeft(UScript.Arabic) || !UScript.IsRightToLeft(UScript.Hebrew):
Errln("UScript.isRightToLeft() failed")
    if UScript.BreaksBetweenLetters(UScript.Latin) || UScript.BreaksBetweenLetters(UScript.Cirth) || !UScript.BreaksBetweenLetters(UScript.Han) || !UScript.BreaksBetweenLetters(UScript.Thai):
Errln("UScript.breaksBetweenLetters() failed")
    if UScript.IsCased(UScript.Cirth) || UScript.IsCased(UScript.Han) || !UScript.IsCased(UScript.Latin) || !UScript.IsCased(UScript.Greek):
Errln("UScript.isCased() failed")
proc GetCharScript(script: int): int =
    case script
    of UScript.HanWithBopomofo:
        return UScript.Han
    of UScript.SimplifiedHan:
        return UScript.Han
    of UScript.TraditionalHan:
        return UScript.Han
    of UScript.Japanese:
        return UScript.Hiragana
    of UScript.Jamo:
        return UScript.Hangul
    of UScript.Korean:
        return UScript.Hangul
    of UScript.SymbolsEmoji:
        return UScript.Symbols
    else:
        return script
proc TestScriptMetadata*() =
    var rtl: UnicodeSet = UnicodeSet("[[:bc=R:][:bc=AL:]-[:Cn:]-[:sc=Common:]]")
    var cased: UnicodeSet = UnicodeSet("[[:Lu:]-[:sc=Common:]-[:sc=Geor:]]")
    var codePointBuffer: Span<char> = newSeq[char](2)
      var sc: int = 0
      while sc < UScript.CodeLimit:
          var sn: String = UScript.GetShortName(sc)
          var usage: ScriptUsage = UScript.GetUsage(sc)
          var sample: String = UScript.GetSampleString(sc)
          var sampleSpan: ReadOnlySpan<char> = UScript.GetSampleSpan(sc, codePointBuffer)
          var scriptSet: UnicodeSet = UnicodeSet
scriptSet.ApplyInt32PropertyValue(UProperty.Script, sc)
          if usage == ScriptUsage.NotEncoded:
assertTrue(sn + " not encoded, no sample", sample.Length == 0)
assertTrue(sn + " not encoded, no sample", sampleSpan.Length == 0)
assertFalse(sn + " not encoded, not RTL", UScript.IsRightToLeft(sc))
assertFalse(sn + " not encoded, not LB letters", UScript.BreaksBetweenLetters(sc))
assertFalse(sn + " not encoded, not cased", UScript.IsCased(sc))
assertTrue(sn + " not encoded, no characters", scriptSet.IsEmpty)
          else:
assertFalse(sn + " encoded, has a sample character", sample.Length == 0)
assertFalse(sn + " encoded, has a sample character", sampleSpan.Length == 0)
              var firstChar: int = sample.CodePointAt(0)
              var charScript: int = GetCharScript(sc)
assertEquals(sn + " script(sample(script))", charScript, UScript.GetScript(firstChar))
assertEquals(sn + " RTL vs. set", rtl.Contains(firstChar), UScript.IsRightToLeft(sc))
assertEquals(sn + " cased vs. set", cased.Contains(firstChar), UScript.IsCased(sc))
assertEquals(sn + " encoded, has characters", sc == charScript, !scriptSet.IsEmpty)
              if UScript.IsRightToLeft(sc):
rtl.RemoveAll(scriptSet)
              if UScript.IsCased(sc):
cased.RemoveAll(scriptSet)
++sc
assertEquals("no remaining RTL characters", "[]", rtl.ToPattern(true))
assertEquals("no remaining cased characters", "[]", cased.ToPattern(true))
assertTrue("Hani breaks between letters", UScript.BreaksBetweenLetters(UScript.Han))
assertTrue("Thai breaks between letters", UScript.BreaksBetweenLetters(UScript.Thai))
assertFalse("Latn does not break between letters", UScript.BreaksBetweenLetters(UScript.Latin))
proc TestScriptNames*() =
      var i: int = 0
      while i < UScript.CodeLimit:
          var name: String = UScript.GetName(i)
          if name.Equals(""):
Errln("FAILED: getName for code : " + i)
          var shortName: String = UScript.GetShortName(i)
          if shortName.Equals(""):
Errln("FAILED: getName for code : " + i)
++i
proc TestScriptNamesUsingTry*() =
      var v: int
      var rev: int
      var i: int = 0
      while i < UScript.CodeLimit:
          var name: string = nil
          if !UScript.TryGetName(i,           var nameSpan: ReadOnlySpan<char>) || nameSpan.Equals("", StringComparison.Ordinal):
Errln("FAILED: getName for code : " + i)
          else:
              name = nameSpan.ToString
          if name != nil:
              rev = UScript.GetCodeFromName(name)
              if rev != cast[int](i):
Errln("Property round-trip failure: " + i + " -> " + name + " -> " + rev)
          var shortName: string = nil
          if !UScript.TryGetShortName(i,           var shortNameSpan: ReadOnlySpan<char>) || shortNameSpan.Equals("", StringComparison.Ordinal):
Errln("FAILED: getName for code : " + i)
          else:
              shortName = shortNameSpan.ToString
          if shortName != nil:
              rev = UScript.GetCodeFromName(shortName)
              if rev != cast[int](i):
Errln("Property round-trip failure: " + i + " -> " + shortName + " -> " + rev)
++i
proc TestAllCodepoints*() =
    var code: int
      var i: int = 0
      while i <= 1114111:
          code = UScript.InvalidCode
          code = UScript.GetScript(i)
          if code == UScript.InvalidCode:
Errln("UScript.GetScript for codepoint 0x" + Hex(i) + " failed")
          var id: String = UScript.GetName(code)
          if id.IndexOf("INVALID", StringComparison.Ordinal) >= 0:
Errln("UScript.GetScript for codepoint 0x" + Hex(i) + " failed")
          var abbr: String = UScript.GetShortName(code)
          if abbr.IndexOf("INV", StringComparison.Ordinal) >= 0:
Errln("UScript.GetScript for codepoint 0x" + Hex(i) + " failed")
++i
proc TestAllCodepointsUsingTry*() =
    var code: int
      var i: int = 0
      while i <= 1114111:
          code = UScript.GetScript(i)
          if code == UScript.InvalidCode:
Errln("UScript.GetScript for codepoint 0x" + Hex(i) + " failed")
          if !UScript.TryGetName(code,           var id: ReadOnlySpan<char>) || id.IndexOf("INVALID", StringComparison.Ordinal) >= 0:
Errln("UScript.GetScript for codepoint 0x" + Hex(i) + " failed")
          if !UScript.TryGetShortName(code,           var abbr: ReadOnlySpan<char>) || abbr.IndexOf("INV", StringComparison.Ordinal) >= 0:
Errln("UScript.GetScript for codepoint 0x" + Hex(i) + " failed")
++i
proc TestNewCode*() =
    var expectedLong: String[] = @["Balinese", "Batak", "Blis", "Brahmi", "Cham", "Cirt", "Cyrs", "Egyd", "Egyh", "Egyptian_Hieroglyphs", "Geok", "Hans", "Hant", "Pahawh_Hmong", "Old_Hungarian", "Inds", "Javanese", "Kayah_Li", "Latf", "Latg", "Lepcha", "Linear_A", "Mandaic", "Maya", "Meroitic_Hieroglyphs", "Nko", "Old_Turkic", "Old_Permic", "Phags_Pa", "Phoenician", "Miao", "Roro", "Sara", "Syre", "Syrj", "Syrn", "Teng", "Vai", "Visp", "Cuneiform", "Zxxx", "Unknown", "Carian", "Jpan", "Tai_Tham", "Lycian", "Lydian", "Ol_Chiki", "Rejang", "Saurashtra", "SignWriting", "Sundanese", "Moon", "Meetei_Mayek", "Imperial_Aramaic", "Avestan", "Chakma", "Kore", "Kaithi", "Manichaean", "Inscriptional_Pahlavi", "Psalter_Pahlavi", "Phlv", "Inscriptional_Parthian", "Samaritan", "Tai_Viet", "Zmth", "Zsym", "Bamum", "Lisu", "Nkgb", "Old_South_Arabian", "Bassa_Vah", "Duployan", "Elbasan", "Grantha", "Kpel", "Loma", "Mende_Kikakui", "Meroitic_Cursive", "Old_North_Arabian", "Nabataean", "Palmyrene", "Khudawadi", "Warang_Citi", "Afak", "Jurc", "Mro", "Nushu", "Sharada", "Sora_Sompeng", "Takri", "Tangut", "Wole", "Anatolian_Hieroglyphs", "Khojki", "Tirhuta", "Caucasian_Albanian", "Mahajani", "Ahom", "Hatran", "Modi", "Multani", "Pau_Cin_Hau", "Siddham", "Adlam", "Bhaiksuki", "Marchen", "Newa", "Osage", "Hanb", "Jamo", "Zsye", "Masaram_Gondi", "Soyombo", "Zanabazar_Square"]
    var expectedShort: String[] = @["Bali", "Batk", "Blis", "Brah", "Cham", "Cirt", "Cyrs", "Egyd", "Egyh", "Egyp", "Geok", "Hans", "Hant", "Hmng", "Hung", "Inds", "Java", "Kali", "Latf", "Latg", "Lepc", "Lina", "Mand", "Maya", "Mero", "Nkoo", "Orkh", "Perm", "Phag", "Phnx", "Plrd", "Roro", "Sara", "Syre", "Syrj", "Syrn", "Teng", "Vaii", "Visp", "Xsux", "Zxxx", "Zzzz", "Cari", "Jpan", "Lana", "Lyci", "Lydi", "Olck", "Rjng", "Saur", "Sgnw", "Sund", "Moon", "Mtei", "Armi", "Avst", "Cakm", "Kore", "Kthi", "Mani", "Phli", "Phlp", "Phlv", "Prti", "Samr", "Tavt", "Zmth", "Zsym", "Bamu", "Lisu", "Nkgb", "Sarb", "Bass", "Dupl", "Elba", "Gran", "Kpel", "Loma", "Mend", "Merc", "Narb", "Nbat", "Palm", "Sind", "Wara", "Afak", "Jurc", "Mroo", "Nshu", "Shrd", "Sora", "Takr", "Tang", "Wole", "Hluw", "Khoj", "Tirh", "Aghb", "Mahj", "Ahom", "Hatr", "Modi", "Mult", "Pauc", "Sidd", "Adlm", "Bhks", "Marc", "Newa", "Osge", "Hanb", "Jamo", "Zsye", "Gonm", "Soyo", "Zanb"]
    if expectedLong.Length != UScript.CodeLimit - UScript.Balinese:
Errln("need to add new script codes in lang.TestUScript.java!")
        return
    var j: int = 0
    var i: int = 0
      i = UScript.Balinese
      while i < UScript.CodeLimit:
          var name: String = UScript.GetName(i)
          if name == nil || !name.Equals(expectedLong[j]):
Errln("UScript.getName failed for code" + i + name + "!=" + expectedLong[j])
          name = UScript.GetShortName(i)
          if name == nil || !name.Equals(expectedShort[j]):
Errln("UScript.getShortName failed for code" + i + name + "!=" + expectedShort[j])
++i
      i = 0
      while i < expectedLong.Length:
          var ret: int[] = UScript.GetCode(expectedShort[i])
          if ret.Length > 1:
Errln("UScript.getCode did not return expected number of codes for script" + expectedShort[i] + ". EXPECTED: 1 GOT: " + ret.Length)
          if ret[0] != UScript.Balinese + i:
Errln("UScript.getCode did not return expected code for script" + expectedShort[i] + ". EXPECTED: " + UScript.Balinese + i + " GOT: %i
" + ret[0])
++i