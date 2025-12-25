# "Namespace: ICU4N.Dev.Test.Search"
type
  SearchTest = ref object
    m_en_us_: RuleBasedCollator
    m_fr_fr_: RuleBasedCollator
    m_de_: RuleBasedCollator
    m_es_: RuleBasedCollator
    m_en_wordbreaker_: BreakIterator
    m_en_characterbreaker_: BreakIterator
    BASIC: seq[SearchData] = @[SD("xxxxxxxxxxxxxxxxxxxx", "fisher", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("silly spring string", "string", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(13, -1), IA(6)), SD("silly spring string string", "string", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(13, 20, -1), IA(6, 6)), SD("silly string spring string", "string", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(6, 20, -1), IA(6, 6)), SD("string spring string", "string", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, 14, -1), IA(6, 6)), SD("Scott Ganyo", "c", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(1, -1), IA(1)), SD("Scott Ganyo", " ", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(5, -1), IA(1)), SD("̥̀", "̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ḁ̀", "̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ḁ̀", "̥̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("àb", "̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("É", "e", nil, CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(1))]
    BREAKITERATOREXACT: seq[SearchData] = @[SD("foxy fox", "fox", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, "characterbreaker", IA(0, 5, -1), IA(3, 3)), SD("foxy fox", "fox", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, "wordbreaker", IA(5, -1), IA(3)), SD("This is a toe Töne", "toe", "de", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, "characterbreaker", IA(10, 14, -1), IA(3, 2)), SD("This is a toe Töne", "toe", "de", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, "wordbreaker", IA(10, -1), IA(3)), SD("Channel, another channel, more channels, and one last Channel", "Channel", "es", CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, "wordbreaker", IA(0, 54, -1), IA(7, 7)), SD("testing that é does not match e", "e", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, "characterbreaker", IA(1, 17, 30, -1), IA(1, 1, 1)), SD("testing that string abécd does not match e", "e", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, "characterbreaker", IA(1, 28, 41, -1), IA(1, 1, 1)), SD("É", "e", "fr", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, "characterbreaker", IA(0, -1), IA(1))]
    BREAKITERATORCANONICAL: seq[SearchData] = @[SD("foxy fox", "fox", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, "characterbreaker", IA(0, 5, -1), IA(3, 3)), SD("foxy fox", "fox", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, "wordbreaker", IA(5, -1), IA(3)), SD("This is a toe Töne", "toe", "de", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, "characterbreaker", IA(10, 14, -1), IA(3, 2)), SD("This is a toe Töne", "toe", "de", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, "wordbreaker", IA(10, -1), IA(3)), SD("Channel, another channel, more channels, and one last Channel", "Channel", "es", CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, "wordbreaker", IA(0, 54, -1), IA(7, 7)), SD("testing that é does not match e", "e", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, "characterbreaker", IA(1, 17, 30, -1), IA(1, 1, 1)), SD("testing that string abécd does not match e", "e", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, "characterbreaker", IA(1, 28, 41, -1), IA(1, 1, 1)), SD("É", "e", "fr", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, "characterbreaker", IA(0, -1), IA(1))]
    BASICCANONICAL: seq[SearchData] = @[SD("xxxxxxxxxxxxxxxxxxxx", "fisher", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("silly spring string", "string", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(13, -1), IA(6)), SD("silly spring string string", "string", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(13, 20, -1), IA(6, 6)), SD("silly string spring string", "string", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(6, 20, -1), IA(6, 6)), SD("string spring string", "string", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, 14, -1), IA(6, 6)), SD("Scott Ganyo", "c", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(1, -1), IA(1)), SD("Scott Ganyo", " ", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(5, -1), IA(1)), SD("̥̀", "̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ḁ̀", "̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ḁ̀", "̥̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("àb", "̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ḁ̀b", "̀b", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("̥̀Ḁ̀", "̀À", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("̥̀Ḁ̀", "̥Ḁ", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ḁ̀b̥̀c ̥b̀ ̀b̥", "̀b̥", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ạ̈", "Ạ̈", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(2)), SD("̣̈", "̣̈", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(2))]
    COLLATOR: seq[SearchData] = @[SD("fox fpx", "fox", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(3)), SD("fox fpx", "fox", nil, CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(0, 4, -1), IA(3, 3))]
    TESTCOLLATORRULE: String = "& o,O ; p,P"
    EXTRACOLLATIONRULE: String = " & ae ; ä & AE ; Ä & oe ; ö & OE ; Ö & ue ; ü & UE ; Ü"
    COLLATORCANONICAL: seq[SearchData] = @[SD("fox fpx", "fox", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(3)), SD("fox fpx", "fox", nil, CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(0, 4, -1), IA(3, 3))]
    COMPOSITEBOUNDARIES: seq[SearchData] = @[SD("À", "A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("AÀC", "A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(1)), SD("ÀA", "A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(1, -1), IA(1)), SD("BÀ", "A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ÀB", "A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("À", "̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("̀À", "̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(1)), SD("À̀", "̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ǻ", "Ǻ", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(1)), SD("Ǻ", "Ǻ", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(1)), SD("Ǻ", "̊", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ǻ", "Å", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ǻ", "̊A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ǻ", "́", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ǻ", "Á", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ǻ", "́A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ǻ", "̊́", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("AǺ", "Å", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ǺA", "́A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ཱི", "ཱི", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(1)), SD("ཱི", "ཱ", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ཱི", "ི", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ཱི", "ཱི", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(1)), SD("Aཱི", "Aཱ", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ཱིA", "ིA", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ǻ Á̊ Ǻ Å Ǻ", "Å", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(10, -1), IA(2))]
    COMPOSITEBOUNDARIESCANONICAL: seq[SearchData] = @[SD("À", "A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("AÀC", "A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(1)), SD("ÀA", "A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(1, -1), IA(1)), SD("BÀ", "A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ÀB", "A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("À", "̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("̀À", "̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(1)), SD("À̀", "̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ǻ", "Ǻ", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(1)), SD("Ǻ", "Ǻ", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(1)), SD("Ǻ", "̊", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ǻ", "Å", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ǻ", "̊A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ǻ", "́", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ǻ", "Á", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ǻ", "́A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ǻ", "̊́", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("AǺ", "Å", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ǺA", "́A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ཱི", "ཱི", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(1)), SD("ཱི", "ཱ", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ཱི", "ི", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ཱི", "ཱི", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(1)), SD("Aཱི", "Aཱ", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ཱིA", "ིA", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("Ǻ Á̊ Ǻ Å Ǻ", "Å", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(10, -1), IA(2))]
    SUPPLEMENTARY: seq[SearchData] = @[SD("abc 𐀀 𐀁 𐐀 𐀀abc abc𐀀 �𐀀 𐀀�", "𐀀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(4, 13, 22, 26, 29, -1), IA(2, 2, 2, 2, 2)), SD("and𝆹this sentence", "𝆹", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(3, -1), IA(2)), SD("and 𝆹 this sentence", " 𝆹 ", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(3, -1), IA(4)), SD("and-𝆹-this sentence", "-𝆹-", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(3, -1), IA(4)), SD("and,𝆹,this sentence", ",𝆹,", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(3, -1), IA(4)), SD("and?𝆹?this sentence", "?𝆹?", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(3, -1), IA(4))]
    CONTRACTIONRULE: String = "&z = ab/c < AB < X̀ < ABC < X̀̕"
    CONTRACTION: seq[SearchData] = @[SD("À̕", "̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("À̕", "̀̕", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("AB̕C", "A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("AB̕C", "AB", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("AB̕C", "̕", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("X̙̀̕", "̙", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("X̀̕D", "̀̕", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("X̀̕D", "X̀̕", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(3)), SD("X̀̚̕D", "X̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("X̀̚̕D", "̚̕D", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ab", "z", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0))]
    CONTRACTIONCANONICAL: seq[SearchData] = @[SD("À̕", "̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("À̕", "̀̕", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("AB̕C", "A", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("AB̕C", "AB", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("AB̕C", "̕", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("X̀̕D", "̀̕", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("X̀̕D", "X̀̕", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(3)), SD("X̀̚̕D", "X̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("X̀̚̕D", "̚̕D", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ab", "z", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(2))]
    MATCH: seq[SearchData] = @[SD("a busy bee is a very busy beeee", "bee", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(7, 26, -1), IA(3, 3)), SD("a busy bee is a very busy beeee with no bee life", "bee", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(7, 26, 40, -1), IA(3, 3, 3))]
    IGNORABLERULE: String = "&a = ̀"
    IGNORABLE: seq[SearchData] = @[SD("̀̕ ̀̕ ", "̀", nil, CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(2))]
    DIACTRICMATCH: seq[SearchData] = @[SD("aaá", "aá", nil, CollationStrength.Secondary, ElementComparisonType.StandardElementComparison, nil, IA(1, -1), IA(2)), SD(" Ẫ AaẪẪẪẫẫẫ𑠁̀ ", "Ẫ", nil, CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(1, 4, 5, 6, 7, 10, 12, 13, 16, -1), IA(2, 1, 1, 1, 3, 2, 1, 3, 2)), SD("καὶ καὶ", "και", nil, CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(0, 5, -1), IA(4, 3))]
    NORMCANONICAL: seq[SearchData] = @[SD("̥̀", "̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("̥̀", "̥", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ḁ̀", "̥̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ḁ̀", "̥̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ḁ̀", "̥", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("ḁ̀", "̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0))]
    NORMEXACT: seq[SearchData] = @[SD("ḁ̀", "ḁ̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(3))]
    NONNORMEXACT: seq[SearchData] = @[SD("ḁ̀", "̥̀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0))]
    OVERLAP: seq[SearchData] = @[SD("abababab", "abab", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, 2, 4, -1), IA(4, 4, 4))]
    NONOVERLAP: seq[SearchData] = @[SD("abababab", "abab", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, 4, -1), IA(4, 4))]
    OVERLAPCANONICAL: seq[SearchData] = @[SD("abababab", "abab", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, 2, 4, -1), IA(4, 4, 4))]
    NONOVERLAPCANONICAL: seq[SearchData] = @[SD("abababab", "abab", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, 4, -1), IA(4, 4))]
    PATTERNCANONICAL: seq[SearchData] = @[SD("The quick brown fox jumps over the lazy foxes", "the", nil, CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(0, 31, -1), IA(3, 3)), SD("The quick brown fox jumps over the lazy foxes", "fox", nil, CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(16, 40, -1), IA(3, 3))]
    PATTERN: seq[SearchData] = @[SD("The quick brown fox jumps over the lazy foxes", "the", nil, CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(0, 31, -1), IA(3, 3)), SD("The quick brown fox jumps over the lazy foxes", "fox", nil, CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(16, 40, -1), IA(3, 3))]
    PECHE_WITH_ACCENTS: String = "un péché, " + "ça pèche par, " + "pécher, " + "une pêche, " + "un pêcher, " + "j’ai pêché, " + "un pécheur, " + "“péche”, " + "decomp peché, " + "base peche"
    STRENGTH: seq[SearchData] = @[SD("The quick brown fox jumps over the lazy foxes", "fox", "en", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(16, 40, -1), IA(3, 3)), SD("The quick brown fox jumps over the lazy foxes", "fox", "en", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, "wordbreaker", IA(16, -1), IA(3)), SD("blackbirds Pat péché pêche pécher pêcher Tod Töne black Tofu blackbirds Ton PAT toehold blackbird black-bird pat toe big Toe", "peche", "fr", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(15, 21, 27, 34, -1), IA(5, 5, 5, 5)), SD("This is a toe Töne", "toe", "de", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(10, 14, -1), IA(3, 2)), SD("A channel, another CHANNEL, more Channels, and one last channel...", "channel", "es", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(2, 19, 33, 56, -1), IA(7, 7, 7, 7)), SD("À should match but not A", "À", "en", CollationStrength.Identical, ElementComparisonType.StandardElementComparison, nil, IA(0, -1), IA(1, 0)), SD(PECHE_WITH_ACCENTS, "peche", "en", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(3, 13, 24, 36, 46, 59, 69, 79, 94, 107, -1), IA(5, 5, 5, 5, 5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "peche", "en", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, "wordbreaker", IA(3, 13, 36, 59, 79, 94, 107, -1), IA(5, 5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "peche", "en", CollationStrength.Secondary, ElementComparisonType.StandardElementComparison, nil, IA(107, -1), IA(5)), SD(PECHE_WITH_ACCENTS, "peche", "en", CollationStrength.Secondary, ElementComparisonType.PatternBaseWeightIsWildcard, nil, IA(3, 13, 24, 36, 46, 59, 69, 79, 94, 107, -1), IA(5, 5, 5, 5, 5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "peche", "en", CollationStrength.Secondary, ElementComparisonType.PatternBaseWeightIsWildcard, "wordbreaker", IA(3, 13, 36, 59, 79, 94, 107, -1), IA(5, 5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "péche", "en", CollationStrength.Secondary, ElementComparisonType.StandardElementComparison, nil, IA(24, 69, 79, -1), IA(5, 5, 5)), SD(PECHE_WITH_ACCENTS, "péche", "en", CollationStrength.Secondary, ElementComparisonType.StandardElementComparison, "wordbreaker", IA(79, -1), IA(5)), SD(PECHE_WITH_ACCENTS, "péche", "en", CollationStrength.Secondary, ElementComparisonType.PatternBaseWeightIsWildcard, nil, IA(3, 24, 69, 79, -1), IA(5, 5, 5, 5)), SD(PECHE_WITH_ACCENTS, "péche", "en", CollationStrength.Secondary, ElementComparisonType.PatternBaseWeightIsWildcard, "wordbreaker", IA(3, 79, -1), IA(5, 5)), SD(PECHE_WITH_ACCENTS, "péche", "en", CollationStrength.Secondary, ElementComparisonType.AnyBaseWeightIsWildcard, nil, IA(3, 24, 69, 79, 94, 107, -1), IA(5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "péche", "en", CollationStrength.Secondary, ElementComparisonType.AnyBaseWeightIsWildcard, "wordbreaker", IA(3, 79, 94, 107, -1), IA(5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "peché", "en", CollationStrength.Secondary, ElementComparisonType.PatternBaseWeightIsWildcard, nil, IA(3, 59, 94, -1), IA(5, 5, 6)), SD(PECHE_WITH_ACCENTS, "peché", "en", CollationStrength.Secondary, ElementComparisonType.PatternBaseWeightIsWildcard, "wordbreaker", IA(3, 59, 94, -1), IA(5, 5, 6)), SD(PECHE_WITH_ACCENTS, "peché", "en", CollationStrength.Secondary, ElementComparisonType.AnyBaseWeightIsWildcard, nil, IA(3, 13, 24, 36, 46, 59, 69, 79, 94, 107, -1), IA(5, 5, 5, 5, 5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "peché", "en", CollationStrength.Secondary, ElementComparisonType.AnyBaseWeightIsWildcard, "wordbreaker", IA(3, 13, 36, 59, 79, 94, 107, -1), IA(5, 5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "peché", "en", CollationStrength.Secondary, ElementComparisonType.PatternBaseWeightIsWildcard, nil, IA(3, 59, 94, -1), IA(5, 5, 6)), SD(PECHE_WITH_ACCENTS, "peché", "en", CollationStrength.Secondary, ElementComparisonType.PatternBaseWeightIsWildcard, "wordbreaker", IA(3, 59, 94, -1), IA(5, 5, 6)), SD(PECHE_WITH_ACCENTS, "peché", "en", CollationStrength.Secondary, ElementComparisonType.AnyBaseWeightIsWildcard, nil, IA(3, 13, 24, 36, 46, 59, 69, 79, 94, 107, -1), IA(5, 5, 5, 5, 5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "peché", "en", CollationStrength.Secondary, ElementComparisonType.AnyBaseWeightIsWildcard, "wordbreaker", IA(3, 13, 36, 59, 79, 94, 107, -1), IA(5, 5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "peche", "fr", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(3, 13, 24, 36, 46, 59, 69, 79, 94, 107, -1), IA(5, 5, 5, 5, 5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "peche", "fr", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, "wordbreaker", IA(3, 13, 36, 59, 79, 94, 107, -1), IA(5, 5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "peche", "fr", CollationStrength.Secondary, ElementComparisonType.StandardElementComparison, nil, IA(107, -1), IA(5)), SD(PECHE_WITH_ACCENTS, "peche", "fr", CollationStrength.Secondary, ElementComparisonType.PatternBaseWeightIsWildcard, nil, IA(3, 13, 24, 36, 46, 59, 69, 79, 94, 107, -1), IA(5, 5, 5, 5, 5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "peche", "fr", CollationStrength.Secondary, ElementComparisonType.PatternBaseWeightIsWildcard, "wordbreaker", IA(3, 13, 36, 59, 79, 94, 107, -1), IA(5, 5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "péche", "fr", CollationStrength.Secondary, ElementComparisonType.StandardElementComparison, nil, IA(24, 69, 79, -1), IA(5, 5, 5)), SD(PECHE_WITH_ACCENTS, "péche", "fr", CollationStrength.Secondary, ElementComparisonType.StandardElementComparison, "wordbreaker", IA(79, -1), IA(5)), SD(PECHE_WITH_ACCENTS, "péche", "fr", CollationStrength.Secondary, ElementComparisonType.PatternBaseWeightIsWildcard, nil, IA(3, 24, 69, 79, -1), IA(5, 5, 5, 5)), SD(PECHE_WITH_ACCENTS, "péche", "fr", CollationStrength.Secondary, ElementComparisonType.PatternBaseWeightIsWildcard, "wordbreaker", IA(3, 79, -1), IA(5, 5)), SD(PECHE_WITH_ACCENTS, "péche", "fr", CollationStrength.Secondary, ElementComparisonType.AnyBaseWeightIsWildcard, nil, IA(3, 24, 69, 79, 94, 107, -1), IA(5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "péche", "fr", CollationStrength.Secondary, ElementComparisonType.AnyBaseWeightIsWildcard, "wordbreaker", IA(3, 79, 94, 107, -1), IA(5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "peché", "fr", CollationStrength.Secondary, ElementComparisonType.PatternBaseWeightIsWildcard, nil, IA(3, 59, 94, -1), IA(5, 5, 6)), SD(PECHE_WITH_ACCENTS, "peché", "fr", CollationStrength.Secondary, ElementComparisonType.PatternBaseWeightIsWildcard, "wordbreaker", IA(3, 59, 94, -1), IA(5, 5, 6)), SD(PECHE_WITH_ACCENTS, "peché", "fr", CollationStrength.Secondary, ElementComparisonType.AnyBaseWeightIsWildcard, nil, IA(3, 13, 24, 36, 46, 59, 69, 79, 94, 107, -1), IA(5, 5, 5, 5, 5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "peché", "fr", CollationStrength.Secondary, ElementComparisonType.AnyBaseWeightIsWildcard, "wordbreaker", IA(3, 13, 36, 59, 79, 94, 107, -1), IA(5, 5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "peché", "fr", CollationStrength.Secondary, ElementComparisonType.PatternBaseWeightIsWildcard, nil, IA(3, 59, 94, -1), IA(5, 5, 6)), SD(PECHE_WITH_ACCENTS, "peché", "fr", CollationStrength.Secondary, ElementComparisonType.PatternBaseWeightIsWildcard, "wordbreaker", IA(3, 59, 94, -1), IA(5, 5, 6)), SD(PECHE_WITH_ACCENTS, "peché", "fr", CollationStrength.Secondary, ElementComparisonType.AnyBaseWeightIsWildcard, nil, IA(3, 13, 24, 36, 46, 59, 69, 79, 94, 107, -1), IA(5, 5, 5, 5, 5, 5, 5, 5, 6, 5)), SD(PECHE_WITH_ACCENTS, "peché", "fr", CollationStrength.Secondary, ElementComparisonType.AnyBaseWeightIsWildcard, "wordbreaker", IA(3, 13, 36, 59, 79, 94, 107, -1), IA(5, 5, 5, 5, 5, 6, 5))]
    STRENGTHCANONICAL: seq[SearchData] = @[SD("The quick brown fox jumps over the lazy foxes", "fox", "en", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(16, 40, -1), IA(3, 3)), SD("The quick brown fox jumps over the lazy foxes", "fox", "en", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, "wordbreaker", IA(16, -1), IA(3)), SD("blackbirds Pat péché pêche pécher pêcher Tod Töne black Tofu blackbirds Ton PAT toehold blackbird black-bird pat toe big Toe", "peche", "fr", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(15, 21, 27, 34, -1), IA(5, 5, 5, 5)), SD("This is a toe Töne", "toe", "de", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(10, 14, -1), IA(3, 2)), SD("A channel, another CHANNEL, more Channels, and one last channel...", "channel", "es", CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(2, 19, 33, 56, -1), IA(7, 7, 7, 7))]
    SUPPLEMENTARYCANONICAL: seq[SearchData] = @[SD("abc 𐀀 𐀁 𐐀 𐀀abc abc𐀀 �𐀀 𐀀�", "𐀀", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(4, 13, 22, 26, 29, -1), IA(2, 2, 2, 2, 2)), SD("and𝆹this sentence", "𝆹", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(3, -1), IA(2)), SD("and 𝆹 this sentence", " 𝆹 ", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(3, -1), IA(4)), SD("and-𝆹-this sentence", "-𝆹-", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(3, -1), IA(4)), SD("and,𝆹,this sentence", ",𝆹,", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(3, -1), IA(4)), SD("and?𝆹?this sentence", "?𝆹?", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(3, -1), IA(4))]
    VARIABLE: seq[SearchData] = @[SD("blackbirds black blackbirds blackbird black-bird", "blackbird", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(0, 17, 28, 38, -1), IA(9, 9, 9, 10)), SD(" on", "go", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0)), SD("abcdefghijklmnopqrstuvwxyz", "   ", nil, CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1), IA(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)), SD(" abc  a bc   ab c    a  bc     ab  c", "abc", nil, CollationStrength.Quaternary, ElementComparisonType.StandardElementComparison, nil, IA(1, -1), IA(3)), SD(" abc  a bc   ab c    a  bc     ab  c", "abc", nil, CollationStrength.Secondary, ElementComparisonType.StandardElementComparison, nil, IA(1, 6, 13, 21, 31, -1), IA(3, 4, 4, 5, 5)), SD("           ---------------", "abc", nil, CollationStrength.Secondary, ElementComparisonType.StandardElementComparison, nil, IA(-1), IA(0))]
    TEXTCANONICAL: seq[SearchData] = @[SD("the foxy brown fox", "fox", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(4, 15, -1), IA(3, 3)), SD("the quick brown fox", "fox", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(16, -1), IA(3))]
    INDICPREFIXMATCH: seq[SearchData] = @[SD("क कँ कं कः की कि कृ क़ क़", "क", nil, CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(0, 2, 5, 8, 11, 14, 17, 20, 23, -1), IA(1, 2, 2, 2, 1, 1, 1, 2, 1)), SD("कत कती कति कते कृत कृते", "कत", nil, CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(0, 3, 7, 11, -1), IA(2, 2, 2, 2)), SD("कत कती कति कते कृत कृते", "कृत", nil, CollationStrength.Primary, ElementComparisonType.StandardElementComparison, nil, IA(15, 19, -1), IA(3, 3))]
    scKoText: String = " " + "가 " + "각 " + "갏 " + "꿿 " + "각 " + "가ᄀ " + "ㄱㅏㄱ " + "갏 " + "가ᄅᄒ " + "꿿 " + "æ " + "ṍ " + ""
    scKoPat0: String = "각"
    scKoPat1: String = "각"
    scKoPat2: String = "갏"
    scKoPat3: String = "가ᄅᄒ"
    scKoPat4: String = "꿿"
    scKoPat5: String = "꿿"
    scKoSrchOff01: seq[int] = @[3, 9, 13]
    scKoSrchOff23: seq[int] = @[5, 21, 25]
    scKoSrchOff45: seq[int] = @[7, 30]
    scKoStndOff01: seq[int] = @[3, 9]
    scKoStndOff2: seq[int] = @[5, 21]
    scKoStndOff3: seq[int] = @[25]
    scKoStndOff45: seq[int] = @[7, 30]
    scKoSrchPatternsOffsets: seq[PatternAndOffsets] = @[PatternAndOffsets(scKoPat0, scKoSrchOff01), PatternAndOffsets(scKoPat1, scKoSrchOff01), PatternAndOffsets(scKoPat2, scKoSrchOff23), PatternAndOffsets(scKoPat3, scKoSrchOff23), PatternAndOffsets(scKoPat4, scKoSrchOff45), PatternAndOffsets(scKoPat5, scKoSrchOff45)]
    scKoStndPatternsOffsets: seq[PatternAndOffsets] = @[PatternAndOffsets(scKoPat0, scKoStndOff01), PatternAndOffsets(scKoPat1, scKoStndOff01), PatternAndOffsets(scKoPat2, scKoStndOff2), PatternAndOffsets(scKoPat3, scKoStndOff3), PatternAndOffsets(scKoPat4, scKoStndOff45), PatternAndOffsets(scKoPat5, scKoStndOff45)]

type
  SearchData = ref object
    text: String
    pattern: String
    collator: String
    strength: CollationStrength
    cmpType: ElementComparisonType
    breaker: String
    offset: seq[int]
    size: seq[int]

proc newSearchData(text: String, pattern: String, coll: String, strength: CollationStrength, cmpType: ElementComparisonType, breaker: String, offset: seq[int], size: seq[int]): SearchData =
  self.text = text
  self.pattern = pattern
  self.collator = coll
  self.strength = strength
  self.cmpType = cmpType
  self.breaker = breaker
  self.offset = offset
  self.size = size
proc SD(text: String, pattern: String, coll: String, strength: CollationStrength, cmpType: ElementComparisonType, breaker: String, offset: seq[int], size: seq[int]): SearchData =
    return SearchData(text, pattern, coll, strength, cmpType, breaker, offset, size)
proc IA(elements: seq[int]): int[] =
    return elements
proc new() =

proc Init*() =
    m_en_us_ = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("en-US")))
    m_fr_fr_ = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("fr-FR")))
    m_de_ = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("de-DE")))
    m_es_ = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("es-ES")))
    m_en_wordbreaker_ = BreakIterator.GetWordInstance
    m_en_characterbreaker_ = BreakIterator.GetCharacterInstance
    var rules: String = m_de_.GetRules + EXTRACOLLATIONRULE
    m_de_ = RuleBasedCollator(rules)
    rules = m_es_.GetRules + EXTRACOLLATIONRULE
    m_es_ = RuleBasedCollator(rules)
proc getCollator(collator: String): RuleBasedCollator =
    if collator == nil:
        return m_en_us_
    if collator.Equals("fr"):
        return m_fr_fr_

    elif collator.Equals("de"):
        return m_de_
    else:
      if collator.Equals("es"):
          return m_es_
      else:
          return m_en_us_
proc getBreakIterator(breaker: String): BreakIterator =
    if breaker == nil:
        return nil
    if breaker.Equals("wordbreaker"):
        return m_en_wordbreaker_
    else:
        return m_en_characterbreaker_
proc assertCanonicalEqual(search: SearchData): bool =
    var collator: Collator = getCollator(search.collator)
    var breaker: BreakIterator = getBreakIterator(search.breaker)
    var strsrch: StringSearch
    var text: String = search.text
    var pattern: String = search.pattern
    if breaker != nil:
breaker.SetText(text)
    collator.Strength = search.strength
    collator.Decomposition = NormalizationMode.CanonicalDecomposition
    try:
        strsrch = StringSearch(pattern, StringCharacterIterator(text), cast[RuleBasedCollator](collator), breaker)
        strsrch.ElementComparisonType = search.cmpType
        strsrch.IsCanonical = true
    except Exception:
Errln("Error opening string search" + e.Message)
        return false
    if !assertEqualWithStringSearch(strsrch, search):
        collator.Strength = CollationStrength.Tertiary
        collator.Decomposition = NormalizationMode.NoDecomposition
        return false
    collator.Strength = CollationStrength.Tertiary
    collator.Decomposition = NormalizationMode.NoDecomposition
    return true
proc assertEqual(search: SearchData): bool =
    var collator: Collator = getCollator(search.collator)
    var breaker: BreakIterator = getBreakIterator(search.breaker)
    var strsrch: StringSearch
    var text: String = search.text
    var pattern: String = search.pattern
    if breaker != nil:
breaker.SetText(text)
    collator.Strength = search.strength
    try:
        strsrch = StringSearch(pattern, StringCharacterIterator(text), cast[RuleBasedCollator](collator), breaker)
        strsrch.ElementComparisonType = search.cmpType
    except Exception:
Errln("Error opening string search " + e.Message)
        return false
    if !assertEqualWithStringSearch(strsrch, search):
        collator.Strength = CollationStrength.Tertiary
        return false
    collator.Strength = CollationStrength.Tertiary
    return true
proc assertEqualWithAttribute(search: SearchData, canonical: bool, overlap: bool): bool =
    var collator: Collator = getCollator(search.collator)
    var breaker: BreakIterator = getBreakIterator(search.breaker)
    var strsrch: StringSearch
    var text: String = search.text
    var pattern: String = search.pattern
    if breaker != nil:
breaker.SetText(text)
    collator.Strength = search.strength
    try:
        strsrch = StringSearch(pattern, StringCharacterIterator(text), cast[RuleBasedCollator](collator), breaker)
        strsrch.IsCanonical = canonical
        strsrch.IsOverlapping = overlap
        strsrch.ElementComparisonType = search.cmpType
    except Exception:
Errln("Error opening string search " + e.Message)
        return false
    if !assertEqualWithStringSearch(strsrch, search):
        collator.Strength = CollationStrength.Tertiary
        return false
    collator.Strength = CollationStrength.Tertiary
    return true
proc assertEqualWithStringSearch(strsrch: StringSearch, search: SearchData): bool =
    var count: int = 0
    var matchindex: int = search.offset[count]
    var matchtext: String
    if strsrch.MatchStart != SearchIterator.Done || strsrch.MatchLength != 0:
Errln("Error with the initialization of match start and length")
    while matchindex >= 0:
        var matchlength: int = search.size[count]
strsrch.Next
        if matchindex != strsrch.MatchStart || matchlength != strsrch.MatchLength:
Errln("Text: " + search.text)
Errln("Searching forward for pattern: " + strsrch.Pattern)
Errln("Expected offset,len " + matchindex + ", " + matchlength + "; got " + strsrch.MatchStart + ", " + strsrch.MatchLength)
            return false
++count
        matchtext = strsrch.GetMatchedText
        var targetText: String = search.text
        if matchlength > 0 && targetText.Substring(matchindex, matchlength).CompareTo(matchtext) != 0:
Errln("Error getting following matched text")
        matchindex = search.offset[count]
strsrch.Next
    if strsrch.MatchStart != SearchIterator.Done || strsrch.MatchLength != 0:
Errln("Text: " + search.text)
Errln("Searching forward for pattern: " + strsrch.Pattern)
Errln("Expected DONE offset,len -1, 0; got " + strsrch.MatchStart + ", " + strsrch.MatchLength)
        return false
    count =     if count == 0:
0
    else:
count - 1
    matchindex = search.offset[count]
    while matchindex >= 0:
        var matchlength: int = search.size[count]
strsrch.Previous
        if matchindex != strsrch.MatchStart || matchlength != strsrch.MatchLength:
Errln("Text: " + search.text)
Errln("Searching backward for pattern: " + strsrch.Pattern)
Errln("Expected offset,len " + matchindex + ", " + matchlength + "; got " + strsrch.MatchStart + ", " + strsrch.MatchLength)
            return false
        matchtext = strsrch.GetMatchedText
        var targetText: String = search.text
        if matchlength > 0 && targetText.Substring(matchindex, matchlength).CompareTo(matchtext) != 0:
Errln("Error getting following matched text")
        matchindex =         if count > 0:
search.offset[count - 1]
        else:
-1
--count
strsrch.Previous
    if strsrch.MatchStart != SearchIterator.Done || strsrch.MatchLength != 0:
Errln("Text: " + search.text)
Errln("Searching backward for pattern: " + strsrch.Pattern)
Errln("Expected DONE offset,len -1, 0; got " + strsrch.MatchStart + ", " + strsrch.MatchLength)
        return false
    return true
proc TestConstructor*() =
    var pattern: String = "pattern"
    var text: String = "text"
    var textiter: StringCharacterIterator = StringCharacterIterator(text)
    var defaultcollator: Collator = Collator.GetInstance
    var breaker: BreakIterator = BreakIterator.GetCharacterInstance
breaker.SetText(text)
    var search: StringSearch = StringSearch(pattern, text)
    if !search.Pattern.Equals(pattern) || !search.Target.Equals(textiter) || !search.Collator.Equals(defaultcollator):
Errln("StringSearch(String, String) error")
    search = StringSearch(pattern, textiter, m_fr_fr_)
    if !search.Pattern.Equals(pattern) || !search.Target.Equals(textiter) || !search.Collator.Equals(m_fr_fr_):
Errln("StringSearch(String, StringCharacterIterator, " + "RuleBasedCollator) error")
    var de = CultureInfo("de-DE")
    breaker = BreakIterator.GetCharacterInstance(de)
breaker.SetText(text)
    search = StringSearch(pattern, textiter, de)
    if !search.Pattern.Equals(pattern) || !search.Target.Equals(textiter) || !search.Collator.Equals(Collator.GetInstance(de)):
Errln("StringSearch(String, StringCharacterIterator, Locale) " + "error")
    search = StringSearch(pattern, textiter, m_fr_fr_, m_en_wordbreaker_)
    if !search.Pattern.Equals(pattern) || !search.Target.Equals(textiter) || !search.Collator.Equals(m_fr_fr_) || !search.BreakIterator.Equals(m_en_wordbreaker_):
Errln("StringSearch(String, StringCharacterIterator, Locale) " + "error")
proc TestBasic*() =
      var count: int = 0
      while count < BASIC.Length:
          if !assertEqual(BASIC[count]):
Errln("Error at test number " + count)
++count
proc TestBreakIterator*() =
    var text: String = BREAKITERATOREXACT[0].text
    var pattern: String = BREAKITERATOREXACT[0].pattern
    var strsrch: StringSearch = nil
    try:
        strsrch = StringSearch(pattern, StringCharacterIterator(text), m_en_us_, nil)
    except Exception:
Errln("Error opening string search")
        return
strsrch.SetBreakIterator(nil)
    if strsrch.BreakIterator != nil:
Errln("Error usearch_getBreakIterator returned wrong object")
strsrch.SetBreakIterator(m_en_characterbreaker_)
    if !strsrch.BreakIterator.Equals(m_en_characterbreaker_):
Errln("Error usearch_getBreakIterator returned wrong object")
strsrch.SetBreakIterator(m_en_wordbreaker_)
    if !strsrch.BreakIterator.Equals(m_en_wordbreaker_):
Errln("Error usearch_getBreakIterator returned wrong object")
    var count: int = 0
    while count < 4:
        var search: SearchData = BREAKITERATOREXACT[count]
        var collator: RuleBasedCollator = getCollator(search.collator)
        var breaker: BreakIterator = getBreakIterator(search.breaker)
        text = search.text
        pattern = search.pattern
        if breaker != nil:
breaker.SetText(text)
        collator.Strength = search.strength
        strsrch = StringSearch(pattern, StringCharacterIterator(text), collator, breaker)
        if strsrch.BreakIterator != breaker:
Errln("Error setting break iterator")
        if !assertEqualWithStringSearch(strsrch, search):
            collator.Strength = CollationStrength.Tertiary
        search = BREAKITERATOREXACT[count + 1]
        breaker = getBreakIterator(search.breaker)
        if breaker != nil:
breaker.SetText(text)
strsrch.SetBreakIterator(breaker)
        if strsrch.BreakIterator != breaker:
Errln("Error setting break iterator")
strsrch.Reset
        if !assertEqualWithStringSearch(strsrch, search):
Errln("Error at test number " + count)
        count = 2
      count = 0
      while count < BREAKITERATOREXACT.Length:
          if !assertEqual(BREAKITERATOREXACT[count]):
Errln("Error at test number " + count)
++count
proc TestBreakIteratorCanonical*() =
    var count: int = 0
    while count < 4:
        var search: SearchData = BREAKITERATORCANONICAL[count]
        var text: String = search.text
        var pattern: String = search.pattern
        var collator: RuleBasedCollator = getCollator(search.collator)
        collator.Strength = search.strength
        var breaker: BreakIterator = getBreakIterator(search.breaker)
        var strsrch: StringSearch = nil
        try:
            strsrch = StringSearch(pattern, StringCharacterIterator(text), collator, breaker)
        except Exception:
Errln("Error creating string search data")
            return
        strsrch.IsCanonical = true
        if !strsrch.BreakIterator.Equals(breaker):
Errln("Error setting break iterator")
            return
        if !assertEqualWithStringSearch(strsrch, search):
            collator.Strength = CollationStrength.Tertiary
            return
        search = BREAKITERATOREXACT[count + 1]
        breaker = getBreakIterator(search.breaker)
breaker.SetText(strsrch.Target)
strsrch.SetBreakIterator(breaker)
        if !strsrch.BreakIterator.Equals(breaker):
Errln("Error setting break iterator")
            return
strsrch.Reset
        strsrch.IsCanonical = true
        if !assertEqualWithStringSearch(strsrch, search):
Errln("Error at test number " + count)
            return
        count = 2
      count = 0
      while count < BREAKITERATORCANONICAL.Length:
          if !assertEqual(BREAKITERATORCANONICAL[count]):
Errln("Error at test number " + count)
              return
++count
proc TestCanonical*() =
      var count: int = 0
      while count < BASICCANONICAL.Length:
          if !assertCanonicalEqual(BASICCANONICAL[count]):
Errln("Error at test number " + count)
++count
proc TestCollator*() =
    var text: String = COLLATOR[0].text
    var pattern: String = COLLATOR[0].pattern
    var strsrch: StringSearch = nil
    try:
        strsrch = StringSearch(pattern, StringCharacterIterator(text), m_en_us_, nil)
    except Exception:
Errln("Error opening string search ")
        return
    if !assertEqualWithStringSearch(strsrch, COLLATOR[0]):
        return
    var rules: String = TESTCOLLATORRULE
    var tailored: RuleBasedCollator = nil
    try:
        tailored = RuleBasedCollator(rules)
        tailored.Strength = COLLATOR[1].strength
    except Exception:
Errln("Error opening rule based collator ")
        return
strsrch.SetCollator(tailored)
    if !strsrch.Collator.Equals(tailored):
Errln("Error setting rule based collator")
strsrch.Reset
    if !assertEqualWithStringSearch(strsrch, COLLATOR[1]):
        return
strsrch.SetCollator(m_en_us_)
strsrch.Reset
    if !strsrch.Collator.Equals(m_en_us_):
Errln("Error setting rule based collator")
    if !assertEqualWithStringSearch(strsrch, COLLATOR[0]):
Errln("Error searching collator test")
proc TestCollatorCanonical*() =
    var text: String = COLLATORCANONICAL[0].text
    var pattern: String = COLLATORCANONICAL[0].pattern
    var strsrch: StringSearch = nil
    try:
        strsrch = StringSearch(pattern, StringCharacterIterator(text), m_en_us_, nil)
        strsrch.IsCanonical = true
    except Exception:
Errln("Error opening string search ")
    if !assertEqualWithStringSearch(strsrch, COLLATORCANONICAL[0]):
        return
    var rules: String = TESTCOLLATORRULE
    var tailored: RuleBasedCollator = nil
    try:
        tailored = RuleBasedCollator(rules)
        tailored.Strength = COLLATORCANONICAL[1].strength
        tailored.Decomposition = NormalizationMode.CanonicalDecomposition
    except Exception:
Errln("Error opening rule based collator ")
strsrch.SetCollator(tailored)
    if !strsrch.Collator.Equals(tailored):
Errln("Error setting rule based collator")
strsrch.Reset
    strsrch.IsCanonical = true
    if !assertEqualWithStringSearch(strsrch, COLLATORCANONICAL[1]):
Logln("COLLATORCANONICAL[1] failed")
strsrch.SetCollator(m_en_us_)
strsrch.Reset
    if !strsrch.Collator.Equals(m_en_us_):
Errln("Error setting rule based collator")
    if !assertEqualWithStringSearch(strsrch, COLLATORCANONICAL[0]):
Logln("COLLATORCANONICAL[0] failed")
proc TestCompositeBoundaries*() =
      var count: int = 0
      while count < COMPOSITEBOUNDARIES.Length:
          if !assertEqual(COMPOSITEBOUNDARIES[count]):
Errln("Error at test number " + count)
++count
proc TestCompositeBoundariesCanonical*() =
      var count: int = 0
      while count < COMPOSITEBOUNDARIESCANONICAL.Length:
          if !assertCanonicalEqual(COMPOSITEBOUNDARIESCANONICAL[count]):
Errln("Error at test number " + count)
++count
proc TestContraction*() =
    var rules: String = CONTRACTIONRULE
    var collator: RuleBasedCollator = nil
    try:
        collator = RuleBasedCollator(rules)
        collator.Strength = CollationStrength.Tertiary
        collator.Decomposition = NormalizationMode.CanonicalDecomposition
    except Exception:
Errln("Error opening collator ")
    var text: String = "text"
    var pattern: String = "pattern"
    var strsrch: StringSearch = nil
    try:
        strsrch = StringSearch(pattern, StringCharacterIterator(text), collator, nil)
    except Exception:
Errln("Error opening string search ")
      var count: int = 0
      while count < CONTRACTION.Length:
          text = CONTRACTION[count].text
          pattern = CONTRACTION[count].pattern
strsrch.SetTarget(StringCharacterIterator(text))
          strsrch.Pattern = pattern
          if !assertEqualWithStringSearch(strsrch, CONTRACTION[count]):
Errln("Error at test number " + count)
++count
proc TestContractionCanonical*() =
    var rules: String = CONTRACTIONRULE
    var collator: RuleBasedCollator = nil
    try:
        collator = RuleBasedCollator(rules)
        collator.Strength = CollationStrength.Tertiary
        collator.Decomposition = NormalizationMode.CanonicalDecomposition
    except Exception:
Errln("Error opening collator ")
    var text: String = "text"
    var pattern: String = "pattern"
    var strsrch: StringSearch = nil
    try:
        strsrch = StringSearch(pattern, StringCharacterIterator(text), collator, nil)
        strsrch.IsCanonical = true
    except Exception:
Errln("Error opening string search")
      var count: int = 0
      while count < CONTRACTIONCANONICAL.Length:
          text = CONTRACTIONCANONICAL[count].text
          pattern = CONTRACTIONCANONICAL[count].pattern
strsrch.SetTarget(StringCharacterIterator(text))
          strsrch.Pattern = pattern
          if !assertEqualWithStringSearch(strsrch, CONTRACTIONCANONICAL[count]):
Errln("Error at test number " + count)
++count
proc TestGetMatch*() =
    var search: SearchData = MATCH[0]
    var text: String = search.text
    var pattern: String = search.pattern
    var strsrch: StringSearch = nil
    try:
        strsrch = StringSearch(pattern, StringCharacterIterator(text), m_en_us_, nil)
    except Exception:
Errln("Error opening string search ")
        return
    var count: int = 0
    var matchindex: int = search.offset[count]
    var matchtext: String
    while matchindex >= 0:
        var matchlength: int = search.size[count]
strsrch.Next
        if matchindex != strsrch.MatchStart || matchlength != strsrch.MatchLength:
Errln("Text: " + search.text)
Errln("Pattern: " + strsrch.Pattern)
Errln("Error match found at " + strsrch.MatchStart + ", " + strsrch.MatchLength)
            return
++count
        matchtext = strsrch.GetMatchedText
        if matchtext.Length != matchlength:
Errln("Error getting match text")
        matchindex = search.offset[count]
strsrch.Next
    if strsrch.MatchStart != StringSearch.Done || strsrch.MatchLength != 0:
Errln("Error end of match not found")
    matchtext = strsrch.GetMatchedText
    if matchtext != nil:
Errln("Error getting null matches")
proc TestGetSetAttribute*() =
    var pattern: String = "pattern"
    var text: String = "text"
    var strsrch: StringSearch = nil
    try:
        strsrch = StringSearch(pattern, StringCharacterIterator(text), m_en_us_, nil)
    except Exception:
Errln("Error opening search")
        return
    if strsrch.IsOverlapping:
Errln("Error default overlaping should be false")
    strsrch.IsOverlapping = true
    if !strsrch.IsOverlapping:
Errln("Error setting overlap true")
    strsrch.IsOverlapping = false
    if strsrch.IsOverlapping:
Errln("Error setting overlap false")
    strsrch.IsCanonical = true
    if !strsrch.IsCanonical:
Errln("Error setting canonical match true")
    strsrch.IsCanonical = false
    if strsrch.IsCanonical:
Errln("Error setting canonical match false")
    if strsrch.ElementComparisonType != ElementComparisonType.StandardElementComparison:
Errln("Error default element comparison type should be SearchIteratorElementComparisonType.StandardElementComparison")
    strsrch.ElementComparisonType = ElementComparisonType.PatternBaseWeightIsWildcard
    if strsrch.ElementComparisonType != ElementComparisonType.PatternBaseWeightIsWildcard:
Errln("Error setting element comparison type SearchIteratorElementComparisonType.PatternBaseWeightIsWildcard")
proc TestGetSetOffset*() =
    var pattern: String = "1234567890123456"
    var text: String = "12345678901234567890123456789012"
    var strsrch: StringSearch = nil
    try:
        strsrch = StringSearch(pattern, StringCharacterIterator(text), m_en_us_, nil)
    except Exception:
Errln("Error opening search")
        return
    try:
strsrch.SetIndex(-1)
Errln("Error expecting set offset error")
    except IndexOutOfRangeException:
Logln("PASS: strsrch.setIndex(-1) failed as expected")
    try:
strsrch.SetIndex(128)
Errln("Error expecting set offset error")
    except IndexOutOfRangeException:
Logln("PASS: strsrch.setIndex(128) failed as expected")
      var index: int = 0
      while index < BASIC.Length:
          var search: SearchData = BASIC[index]
          text = search.text
          pattern = search.pattern
strsrch.SetTarget(StringCharacterIterator(text))
          strsrch.Pattern = pattern
          strsrch.Collator.Strength = search.strength
strsrch.Reset
          var count: int = 0
          var matchindex: int = search.offset[count]
          while matchindex >= 0:
              var matchlength: int = search.size[count]
strsrch.Next
              if matchindex != strsrch.MatchStart || matchlength != strsrch.MatchLength:
Errln("Text: " + text)
Errln("Pattern: " + strsrch.Pattern)
Errln("Error match found at " + strsrch.MatchStart + ", " + strsrch.MatchLength)
                  return
              matchindex =               if search.offset[count + 1] == -1:
-1
              else:
search.offset[count + 2]
              if search.offset[count + 1] != -1:
strsrch.SetIndex(search.offset[count + 1] + 1)
                  if strsrch.Index != search.offset[count + 1] + 1:
Errln("Error setting offset
")
                      return
              count = 2
strsrch.Next
          if strsrch.MatchStart != StringSearch.Done:
Errln("Text: " + text)
Errln("Pattern: " + strsrch.Pattern)
Errln("Error match found at " + strsrch.MatchStart + ", " + strsrch.MatchLength)
              return
++index
    strsrch.Collator.Strength = CollationStrength.Tertiary
proc TestGetSetOffsetCanonical*() =
    var text: String = "text"
    var pattern: String = "pattern"
    var strsrch: StringSearch = nil
    try:
        strsrch = StringSearch(pattern, StringCharacterIterator(text), m_en_us_, nil)
    except Exception:
Errln("Fail to open StringSearch!")
        return
    strsrch.IsCanonical = true
    strsrch.Collator.Decomposition = NormalizationMode.CanonicalDecomposition
    try:
strsrch.SetIndex(-1)
Errln("Error expecting set offset error")
    except IndexOutOfRangeException:
Logln("PASS: strsrch.setIndex(-1) failed as expected")
    try:
strsrch.SetIndex(128)
Errln("Error expecting set offset error")
    except IndexOutOfRangeException:
Logln("PASS: strsrch.setIndex(128) failed as expected")
      var index: int = 0
      while index < BASICCANONICAL.Length:
          var search: SearchData = BASICCANONICAL[index]
          text = search.text
          pattern = search.pattern
strsrch.SetTarget(StringCharacterIterator(text))
          strsrch.Pattern = pattern
          var count: int = 0
          var matchindex: int = search.offset[count]
          while matchindex >= 0:
              var matchlength: int = search.size[count]
strsrch.Next
              if matchindex != strsrch.MatchStart || matchlength != strsrch.MatchLength:
Errln("Text: " + text)
Errln("Pattern: " + strsrch.Pattern)
Errln("Error match found at " + strsrch.MatchStart + ", " + strsrch.MatchLength)
                  return
              matchindex =               if search.offset[count + 1] == -1:
-1
              else:
search.offset[count + 2]
              if search.offset[count + 1] != -1:
strsrch.SetIndex(search.offset[count + 1] + 1)
                  if strsrch.Index != search.offset[count + 1] + 1:
Errln("Error setting offset")
                      return
              count = 2
strsrch.Next
          if strsrch.MatchStart != StringSearch.Done:
Errln("Text: " + text)
Errln("Pattern: %s" + strsrch.Pattern)
Errln("Error match found at " + strsrch.MatchStart + ", " + strsrch.MatchLength)
              return
++index
    strsrch.Collator.Strength = CollationStrength.Tertiary
    strsrch.Collator.Decomposition = NormalizationMode.NoDecomposition
proc TestIgnorable*() =
    var rules: String = IGNORABLERULE
    var count: int = 0
    var collator: RuleBasedCollator = nil
    try:
        collator = RuleBasedCollator(rules)
        collator.Strength = IGNORABLE[count].strength
        collator.Decomposition = Collator.CanonicalDecomposition
    except Exception:
Errln("Error opening collator ")
        return
    var pattern: String = "pattern"
    var text: String = "text"
    var strsrch: StringSearch = nil
    try:
        strsrch = StringSearch(pattern, StringCharacterIterator(text), collator, nil)
    except Exception:
Errln("Error opening string search ")
        return
      while count < IGNORABLE.Length:
          text = IGNORABLE[count].text
          pattern = IGNORABLE[count].pattern
strsrch.SetTarget(StringCharacterIterator(text))
          strsrch.Pattern = pattern
          if !assertEqualWithStringSearch(strsrch, IGNORABLE[count]):
Errln("Error at test number " + count)
++count
proc TestInitialization*() =
    var pattern: String
    var text: String
    var temp: String = "a"
    var result: StringSearch
    pattern = temp + temp
    text = temp + temp + temp
    try:
        result = StringSearch(pattern, StringCharacterIterator(text), m_en_us_, nil)
    except Exception:
Errln("Error opening search ")
        return
    pattern = ""
      var count: int = 0
      while count < 512:
          pattern = temp
++count
    try:
        result = StringSearch(pattern, StringCharacterIterator(text), m_en_us_, nil)
Logln("pattern:" + result.Pattern)
    except Exception:
Errln("Fail: an extremely large pattern will fail the initialization")
        return
proc TestNormCanonical*() =
    m_en_us_.Decomposition = Collator.CanonicalDecomposition
      var count: int = 0
      while count < NORMCANONICAL.Length:
          if !assertCanonicalEqual(NORMCANONICAL[count]):
Errln("Error at test number " + count)
++count
    m_en_us_.Decomposition = Collator.NoDecomposition
proc TestNormExact*() =
    var count: int
    m_en_us_.Decomposition = Collator.CanonicalDecomposition
      count = 0
      while count < BASIC.Length:
          if !assertEqual(BASIC[count]):
Errln("Error at test number " + count)
++count
      count = 0
      while count < NORMEXACT.Length:
          if !assertEqual(NORMEXACT[count]):
Errln("Error at test number " + count)
++count
    m_en_us_.Decomposition = Collator.NoDecomposition
      count = 0
      while count < NONNORMEXACT.Length:
          if !assertEqual(NONNORMEXACT[count]):
Errln("Error at test number " + count)
++count
proc TestOpenClose*() =
    var result: StringSearch
    var breakiter: BreakIterator = m_en_wordbreaker_
    var pattern: String = ""
    var text: String = ""
    var temp: String = "a"
    var chariter: StringCharacterIterator = StringCharacterIterator(text)
    try:
        result = StringSearch(pattern, StringCharacterIterator(text), nil, nil)
Errln("Error: null arguments should produce an error")
    except Exception:
Logln("PASS: null arguments failed as expected")
chariter.SetText(text)
    try:
        result = StringSearch(pattern, chariter, nil, nil)
Errln("Error: null arguments should produce an error")
    except Exception:
Logln("PASS: null arguments failed as expected")
    text = Convert.ToString(1, CultureInfo.InvariantCulture)
    try:
        result = StringSearch(pattern, StringCharacterIterator(text), nil, nil)
Errln("Error: Empty pattern should produce an error")
    except Exception:
Logln("PASS: Empty pattern failed as expected")
chariter.SetText(text)
    try:
        result = StringSearch(pattern, chariter, nil, nil)
Errln("Error: Empty pattern should produce an error")
    except Exception:
Logln("PASS: Empty pattern failed as expected")
    text = ""
    pattern = temp
    try:
        result = StringSearch(pattern, StringCharacterIterator(text), nil, nil)
Errln("Error: Empty text should produce an error")
    except Exception:
Logln("PASS: Empty text failed as expected")
chariter.SetText(text)
    try:
        result = StringSearch(pattern, chariter, nil, nil)
Errln("Error: Empty text should produce an error")
    except Exception:
Logln("PASS: Empty text failed as expected")
    text = temp
    try:
        result = StringSearch(pattern, StringCharacterIterator(text), nil, nil)
Errln("Error: null arguments should produce an error")
    except Exception:
Logln("PASS: null arguments failed as expected")
chariter.SetText(text)
    try:
        result = StringSearch(pattern, chariter, nil, nil)
Errln("Error: null arguments should produce an error")
    except Exception:
Logln("PASS: null arguments failed as expected")
    try:
        result = StringSearch(pattern, StringCharacterIterator(text), m_en_us_, nil)
    except Exception:
Errln("Error: null break iterator is valid for opening search")
    try:
        result = StringSearch(pattern, chariter, m_en_us_, nil)
    except Exception:
Errln("Error: null break iterator is valid for opening search")
    try:
        result = StringSearch(pattern, StringCharacterIterator(text), CultureInfo("en"))
    except Exception:
Errln("Error: null break iterator is valid for opening search")
    try:
        result = StringSearch(pattern, chariter, CultureInfo("en"))
    except Exception:
Errln("Error: null break iterator is valid for opening search")
    try:
        result = StringSearch(pattern, StringCharacterIterator(text), m_en_us_, breakiter)
    except Exception:
Errln("Error: Break iterator is valid for opening search")
    try:
        result = StringSearch(pattern, chariter, m_en_us_, nil)
Logln("pattern:" + result.Pattern)
    except Exception:
Errln("Error: Break iterator is valid for opening search")
proc TestOverlap*() =
    var count: int
      count = 0
      while count < OVERLAP.Length:
          if !assertEqualWithAttribute(OVERLAP[count], false, true):
Errln("Error at overlap test number " + count)
++count
      count = 0
      while count < NONOVERLAP.Length:
          if !assertEqual(NONOVERLAP[count]):
Errln("Error at non overlap test number " + count)
++count
      count = 0
      while count < OVERLAP.Length && count < NONOVERLAP.Length:
          var search: SearchData = OVERLAP[count]
          var text: String = search.text
          var pattern: String = search.pattern
          var collator: RuleBasedCollator = getCollator(search.collator)
          var strsrch: StringSearch = nil
          try:
              strsrch = StringSearch(pattern, StringCharacterIterator(text), collator, nil)
          except Exception:
Errln("error open StringSearch")
              return
          strsrch.IsOverlapping = true
          if !strsrch.IsOverlapping:
Errln("Error setting overlap option")
          if !assertEqualWithStringSearch(strsrch, search):
              return
          search = NONOVERLAP[count]
          strsrch.IsOverlapping = false
          if strsrch.IsOverlapping:
Errln("Error setting overlap option")
strsrch.Reset
          if !assertEqualWithStringSearch(strsrch, search):
Errln("Error at test number " + count)
++count
proc TestOverlapCanonical*() =
    var count: int
      count = 0
      while count < OVERLAPCANONICAL.Length:
          if !assertEqualWithAttribute(OVERLAPCANONICAL[count], true, true):
Errln("Error at overlap test number %d" + count)
++count
      count = 0
      while count < NONOVERLAP.Length:
          if !assertCanonicalEqual(NONOVERLAPCANONICAL[count]):
Errln("Error at non overlap test number %d" + count)
++count
      count = 0
      while count < OVERLAPCANONICAL.Length && count < NONOVERLAPCANONICAL.Length:
          var search: SearchData = OVERLAPCANONICAL[count]
          var collator: RuleBasedCollator = getCollator(search.collator)
          var strsrch: StringSearch = StringSearch(search.pattern, StringCharacterIterator(search.text), collator, nil)
          strsrch.IsCanonical = true
          strsrch.IsOverlapping = true
          if strsrch.IsOverlapping != true:
Errln("Error setting overlap option")
          if !assertEqualWithStringSearch(strsrch, search):
              strsrch = nil
              return
          search = NONOVERLAPCANONICAL[count]
          strsrch.IsOverlapping = false
          if strsrch.IsOverlapping != false:
Errln("Error setting overlap option")
strsrch.Reset
          if !assertEqualWithStringSearch(strsrch, search):
              strsrch = nil
Errln("Error at test number %d" + count)
++count
proc TestPattern*() =
    m_en_us_.Strength = PATTERN[0].strength
    var strsrch: StringSearch = StringSearch(PATTERN[0].pattern, StringCharacterIterator(PATTERN[0].text), m_en_us_, nil)
    if strsrch.Pattern != PATTERN[0].pattern:
Errln("Error setting pattern")
    if !assertEqualWithStringSearch(strsrch, PATTERN[0]):
        m_en_us_.Strength = CollationStrength.Tertiary
        if strsrch != nil:
            strsrch = nil
        return
    strsrch.Pattern = PATTERN[1].pattern
    if PATTERN[1].pattern != strsrch.Pattern:
Errln("Error setting pattern")
        m_en_us_.Strength = CollationStrength.Tertiary
        if strsrch != nil:
            strsrch = nil
        return
strsrch.Reset
    if !assertEqualWithStringSearch(strsrch, PATTERN[1]):
        m_en_us_.Strength = CollationStrength.Tertiary
        if strsrch != nil:
            strsrch = nil
        return
    strsrch.Pattern = PATTERN[0].pattern
    if PATTERN[0].pattern != strsrch.Pattern:
Errln("Error setting pattern")
        m_en_us_.Strength = CollationStrength.Tertiary
        if strsrch != nil:
            strsrch = nil
        return
strsrch.Reset
    if !assertEqualWithStringSearch(strsrch, PATTERN[0]):
        m_en_us_.Strength = CollationStrength.Tertiary
        if strsrch != nil:
            strsrch = nil
        return
    var pattern: String = ""
      var templength: int = 0
      while templength != 512:
          pattern = 97
++templength
    try:
        strsrch.Pattern = pattern
    except Exception:
Errln("Error setting pattern with size 512")
    m_en_us_.Strength = CollationStrength.Tertiary
    if strsrch != nil:
        strsrch = nil
proc TestPatternCanonical*() =
    m_en_us_.Strength = PATTERNCANONICAL[0].strength
    var strsrch: StringSearch = StringSearch(PATTERNCANONICAL[0].pattern, StringCharacterIterator(PATTERNCANONICAL[0].text), m_en_us_, nil)
    strsrch.IsCanonical = true
    if PATTERNCANONICAL[0].pattern != strsrch.Pattern:
Errln("Error setting pattern")
    if !assertEqualWithStringSearch(strsrch, PATTERNCANONICAL[0]):
        m_en_us_.Strength = CollationStrength.Tertiary
        strsrch = nil
        return
    strsrch.Pattern = PATTERNCANONICAL[1].pattern
    if PATTERNCANONICAL[1].pattern != strsrch.Pattern:
Errln("Error setting pattern")
        m_en_us_.Strength = CollationStrength.Tertiary
        strsrch = nil
        return
strsrch.Reset
    strsrch.IsCanonical = true
    if !assertEqualWithStringSearch(strsrch, PATTERNCANONICAL[1]):
        m_en_us_.Strength = CollationStrength.Tertiary
        strsrch = nil
        return
    strsrch.Pattern = PATTERNCANONICAL[0].pattern
    if PATTERNCANONICAL[0].pattern != strsrch.Pattern:
Errln("Error setting pattern")
        m_en_us_.Strength = CollationStrength.Tertiary
        strsrch = nil
        return
strsrch.Reset
    strsrch.IsCanonical = true
    if !assertEqualWithStringSearch(strsrch, PATTERNCANONICAL[0]):
        m_en_us_.Strength = CollationStrength.Tertiary
        strsrch = nil
        return
proc TestReset*() =
    var text: StringCharacterIterator = StringCharacterIterator("fish fish")
    var pattern: String = "s"
    var strsrch: StringSearch = StringSearch(pattern, text, m_en_us_, nil)
    strsrch.IsOverlapping = true
    strsrch.IsCanonical = true
strsrch.SetIndex(9)
strsrch.Reset
    if strsrch.IsCanonical || strsrch.IsOverlapping || strsrch.Index != 0 || strsrch.MatchLength != 0 || strsrch.MatchStart != SearchIterator.Done:
Errln("Error resetting string search")
strsrch.Previous
    if strsrch.MatchStart != 7 || strsrch.MatchLength != 1:
Errln("Error resetting string search
")
proc TestSetMatch*() =
      var count: int = 0
      while count < MATCH.Length:
          var search: SearchData = MATCH[count]
          var strsrch: StringSearch = StringSearch(search.pattern, StringCharacterIterator(search.text), m_en_us_, nil)
          var size: int = 0
          while search.offset[size] != -1:
++size
          if strsrch.First != search.offset[0]:
Errln("Error getting first match")
          if strsrch.Last != search.offset[size - 1]:
Errln("Error getting last match")
          var index: int = 0
          while index < size:
              if index + 2 < size:
                  if strsrch.Following(search.offset[index + 2] - 1) != search.offset[index + 2]:
Errln("Error getting following match at index " + search.offset[index + 2] - 1)
              if index + 1 < size:
                  if strsrch.Preceding(search.offset[index + 1] + search.size[index + 1] + 1) != search.offset[index + 1]:
Errln("Error getting preceeding match at index " + search.offset[index + 1] + 1)
              index = 2
          if strsrch.Following(search.text.Length) != SearchIterator.Done:
Errln("Error expecting out of bounds match")
          if strsrch.Preceding(0) != SearchIterator.Done:
Errln("Error expecting out of bounds match")
++count
proc TestStrength*() =
      var count: int = 0
      while count < STRENGTH.Length:
          if !assertEqual(STRENGTH[count]):
Errln("Error at test number " + count)
++count
proc TestStrengthCanonical*() =
      var count: int = 0
      while count < STRENGTHCANONICAL.Length:
          if !assertCanonicalEqual(STRENGTHCANONICAL[count]):
Errln("Error at test number" + count)
++count
proc TestSupplementary*() =
      var count: int = 0
      while count < SUPPLEMENTARY.Length:
          if !assertEqual(SUPPLEMENTARY[count]):
Errln("Error at test number " + count)
++count
proc TestSupplementaryCanonical*() =
      var count: int = 0
      while count < SUPPLEMENTARYCANONICAL.Length:
          if !assertCanonicalEqual(SUPPLEMENTARYCANONICAL[count]):
Errln("Error at test number" + count)
++count
proc TestText*() =
    var TEXT: SearchData[] = @[SD("the foxy brown fox", "fox", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(4, 15, -1), IA(3, 3)), SD("the quick brown fox", "fox", nil, CollationStrength.Tertiary, ElementComparisonType.StandardElementComparison, nil, IA(16, -1), IA(3))]
    var t: StringCharacterIterator = StringCharacterIterator(TEXT[0].text)
    var strsrch: StringSearch = StringSearch(TEXT[0].pattern, t, m_en_us_, nil)
    if !t.Equals(strsrch.Target):
Errln("Error setting text")
    if !assertEqualWithStringSearch(strsrch, TEXT[0]):
Errln("Error at assertEqualWithStringSearch")
        return
    t = StringCharacterIterator(TEXT[1].text)
strsrch.SetTarget(t)
    if !t.Equals(strsrch.Target):
Errln("Error setting text")
        return
    if !assertEqualWithStringSearch(strsrch, TEXT[1]):
Errln("Error at assertEqualWithStringSearch")
        return
proc TestTextCanonical*() =
    var t: StringCharacterIterator = StringCharacterIterator(TEXTCANONICAL[0].text)
    var strsrch: StringSearch = StringSearch(TEXTCANONICAL[0].pattern, t, m_en_us_, nil)
    strsrch.IsCanonical = true
    if !t.Equals(strsrch.Target):
Errln("Error setting text")
    if !assertEqualWithStringSearch(strsrch, TEXTCANONICAL[0]):
        strsrch = nil
        return
    t = StringCharacterIterator(TEXTCANONICAL[1].text)
strsrch.SetTarget(t)
    if !t.Equals(strsrch.Target):
Errln("Error setting text")
        strsrch = nil
        return
    if !assertEqualWithStringSearch(strsrch, TEXTCANONICAL[1]):
        strsrch = nil
        return
    t = StringCharacterIterator(TEXTCANONICAL[0].text)
strsrch.SetTarget(t)
    if !t.Equals(strsrch.Target):
Errln("Error setting text")
        strsrch = nil
        return
    if !assertEqualWithStringSearch(strsrch, TEXTCANONICAL[0]):
Errln("Error at assertEqualWithStringSearch")
        strsrch = nil
        return
proc TestVariable*() =
    m_en_us_.IsAlternateHandlingShifted = true
      var count: int = 0
      while count < VARIABLE.Length:
          if !assertEqual(VARIABLE[count]):
Errln("Error at test number " + count)
++count
    m_en_us_.IsAlternateHandlingShifted = false
proc TestVariableCanonical*() =
    m_en_us_.IsAlternateHandlingShifted = true
      var count: int = 0
      while count < VARIABLE.Length:
          if !assertCanonicalEqual(VARIABLE[count]):
Errln("Error at test number " + count)
++count
    m_en_us_.IsAlternateHandlingShifted = false
type
  TestSearch = ref object
    pattern: String
    text: String

proc newTestSearch(target: StringCharacterIterator, breaker: BreakIterator, pattern: String): TestSearch =
newSearchIterator(target, breaker)
  self.pattern = pattern
  var buffer: StringBuffer = StringBuffer
  while m_targetText.Index != m_targetText.EndIndex:
buffer.Append(m_targetText.Current)
m_targetText.Next
  text = buffer.ToString
m_targetText.SetIndex(m_targetText.BeginIndex)
proc HandleNext(start: int): int =
    var match: int = text.IndexOf(pattern, start, StringComparison.Ordinal)
    if match < 0:
m_targetText.Last
        return Done
m_targetText.SetIndex(match)
    MatchLength = pattern.Length
    return match
proc HandlePrevious(start: int): int =
    var match: int = text.LastIndexOf(pattern, start, StringComparison.Ordinal)
    if match < 0:
m_targetText.SetIndex(0)
        return Done
m_targetText.SetIndex(match)
    MatchLength = pattern.Length
    return match
proc Index(): int =
    var result: int = m_targetText.Index
    if result < 0 || result >= text.Length:
        return Done
    return result
proc TestSubClass*() =
    var search: TestSearch = TestSearch(StringCharacterIterator("abc abcd abc"), nil, "abc")
    var expected: int[] = @[0, 4, 9]
      var i: int = 0
      while i < expected.Length:
          if search.Next != expected[i]:
Errln("Error getting next match")
          if search.MatchLength != search.pattern.Length:
Errln("Error getting next match length")
++i
    if search.Next != SearchIterator.Done:
Errln("Error should have reached the end of the iteration")
      var i: int = expected.Length - 1
      while i >= 0:
          if search.Previous != expected[i]:
Errln("Error getting next match")
          if search.MatchLength != search.pattern.Length:
Errln("Error getting next match length")
--i
    if search.Previous != SearchIterator.Done:
Errln("Error should have reached the start of the iteration")
proc TestDiactricMatch*() =
    var pattern: String = "pattern"
    var text: String = "text"
    var strsrch: StringSearch = nil
    try:
        strsrch = StringSearch(pattern, text)
    except Exception:
Errln("Error opening string search ")
        return
      var count: int = 0
      while count < DIACTRICMATCH.Length:
strsrch.SetCollator(getCollator(DIACTRICMATCH[count].collator))
          strsrch.Collator.Strength = DIACTRICMATCH[count].strength
strsrch.SetBreakIterator(getBreakIterator(DIACTRICMATCH[count].breaker))
strsrch.Reset
          text = DIACTRICMATCH[count].text
          pattern = DIACTRICMATCH[count].pattern
strsrch.SetTarget(StringCharacterIterator(text))
          strsrch.Pattern = pattern
          if !assertEqualWithStringSearch(strsrch, DIACTRICMATCH[count]):
Errln("Error at test number " + count)
++count
type
  PatternAndOffsets = ref object
    pattern: String
    offsets: seq[int]

proc newPatternAndOffsets(pat: String, offs: seq[int]): PatternAndOffsets =
  pattern = pat
  offsets = offs
proc getPattern*(): String =
    return pattern
proc getOffsets*(): int[] =
    return offsets
type
  TUSCItem = ref object
    localeString: String
    text: String
    patternsAndOffsets: seq[PatternAndOffsets]

proc newTUSCItem(locStr: String, txt: String, patsAndOffs: seq[PatternAndOffsets]): TUSCItem =
  localeString = locStr
  text = txt
  patternsAndOffsets = patsAndOffs
proc getLocaleString*(): String =
    return localeString
proc getText*(): String =
    return text
proc getPatternsAndOffsets*(): PatternAndOffsets[] =
    return patternsAndOffsets
proc TestUsingSearchCollator*() =
    var tuscItems: TUSCItem[] = @[TUSCItem("root", scKoText, scKoStndPatternsOffsets), TUSCItem("root@collation=search", scKoText, scKoSrchPatternsOffsets), TUSCItem("ko@collation=search", scKoText, scKoSrchPatternsOffsets)]
    var dummyPat: String = "a"
    for tuscItem in tuscItems:
        var localeString: String = tuscItem.getLocaleString
        var uloc: UCultureInfo = UCultureInfo(localeString)
        var col: RuleBasedCollator = nil
        try:
            col = cast[RuleBasedCollator](Collator.GetInstance(uloc))
        except Exception:
Errln("Error: in locale " + localeString + ", err in Collator.getInstance")
            continue
        var ci: StringCharacterIterator = StringCharacterIterator(tuscItem.getText)
        var srch: StringSearch = StringSearch(dummyPat, ci, col)
        for patternAndOffsets in tuscItem.getPatternsAndOffsets:
            srch.Pattern = patternAndOffsets.getPattern
            var offsets: int[] = patternAndOffsets.getOffsets
              var ioff: int
              var noff: int = offsets.Length
            var offset: int
srch.Reset
            ioff = 0
            while true:
                offset = srch.Next
                if offset == SearchIterator.Done:
                    break
                if ioff < noff:
                    if offset != offsets[ioff]:
Errln("Error: in locale " + localeString + ", expected SearchIterator.Next() " + offsets[ioff] + ", got " + offset)
++ioff
                else:
Errln("Error: in locale " + localeString + ", SearchIterator.Next() returned more matches than expected")
            if ioff < noff:
Errln("Error: in locale " + localeString + ", SearchIterator.Next() returned fewer matches than expected")
srch.Reset
            ioff = noff
            while true:
                offset = srch.Previous
                if offset == SearchIterator.Done:
                    break
                if ioff > 0:
--ioff
                    if offset != offsets[ioff]:
Errln("Error: in locale " + localeString + ", expected SearchIterator.previous() " + offsets[ioff] + ", got " + offset)
                else:
Errln("Error: in locale " + localeString + ", expected SearchIterator.previous() returned more matches than expected")
            if ioff > 0:
Errln("Error: in locale " + localeString + ", expected SearchIterator.previous() returned fewer matches than expected")
proc TestIndicPrefixMatch*() =
      var count: int = 0
      while count < INDICPREFIXMATCH.Length:
          if !assertEqual(INDICPREFIXMATCH[count]):
Errln("Error at test number" + count)
++count
proc TestLongPattern*() =
    var pattern: StringBuilder = StringBuilder
      var i: int = 0
      while i < 255:
pattern.Append('a')
++i
pattern.Append('�')
    var target: CharacterIterator = StringCharacterIterator("not important")
    try:
        var ss: StringSearch = StringSearch(pattern.ToString, target, CultureInfo("en"))
assertNotNull("Non-null StringSearch instance", ss)
    except Exception:
Errln("Error initializing a new StringSearch object")