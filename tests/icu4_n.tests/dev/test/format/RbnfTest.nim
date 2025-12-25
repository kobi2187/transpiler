# "Namespace: ICU4N.Dev.Test.Format"
type
  RbnfTest = ref object
    fracRules: String = "%main:
" + "    x.0: <#,##0<[ >%%frac>];
" + "    0.x: >%%frac>;
" + "%%frac:
" + "    2: 1/2;
" + "    3: <0</3;
" + "    4: <0</4;
" + "    5: <0</5;
" + "    6: <0</6;
" + "    7: <0</7;
" + "    8: <0</8;
" + "    9: <0</9;
" + "   10: <0</10;
"

proc TestCoverage*() =
    var durationInSecondsRules: String = "%with-words:
" + "    0 seconds; 1 second; =0= seconds;
" + "    60/60: <%%min<[, >>];
" + "    3600/60: <%%hr<[, >>>];
" + "%%min:
" + "    0 minutes; 1 minute; =0= minutes;
" + "%%hr:
" + "    0 hours; 1 hour; =0= hours;
" + "%in-numerals:
" + "    =0= sec.;
" + "    60: =%%min-sec=;
" + "    3600: =%%hr-min-sec=;
" + "%%min-sec:
" + "    0: :=00=;
" + "    60/60: <0<>>;
" + "%%hr-min-sec:
" + "    0: :=00=;
" + "    60/60: <00<>>;
" + "    3600/60: <#,##0<:>>>;
" + "%%lenient-parse:
" + "    & : = . = ' ' = -;
"
    var fmt0: RuleBasedNumberFormat = RuleBasedNumberFormat(NumberPresentation.SpellOut)
    var fmt1: RuleBasedNumberFormat = cast[RuleBasedNumberFormat](fmt0.Clone)
    var fmt2: RuleBasedNumberFormat = RuleBasedNumberFormat(NumberPresentation.SpellOut)
    if !fmt0.Equals(fmt0):
Errln("self equality fails")
    if !fmt0.Equals(fmt1):
Errln("clone equality fails")
    if !fmt0.Equals(fmt2):
Errln("duplicate equality fails")
    var str: String = fmt0.ToString
Logln(str)
    var fmt3: RuleBasedNumberFormat = RuleBasedNumberFormat(durationInSecondsRules)
    if fmt0.Equals(fmt3):
Errln("nonequal fails")
    if !fmt3.Equals(fmt3):
Errln("self equal 2 fails")
    str = fmt3.ToString
Logln(str)
    var names: String[] = fmt3.GetRuleSetNames
    try:
fmt3.SetDefaultRuleSet(nil)
fmt3.SetDefaultRuleSet("%%foo")
Errln("sdrf %%foo didn't fail")
    except Exception:
Logln("Got the expected exception")
    try:
fmt3.SetDefaultRuleSet("%bogus")
Errln("sdrf %bogus didn't fail")
    except Exception:
Logln("Got the expected exception")
    try:
        str = fmt3.Format(2.3, names[0])
Logln(str)
        str = fmt3.Format(2.3, "%%foo")
Errln("format double %%foo didn't fail")
    except Exception:
Logln("Got the expected exception")
    try:
        str = fmt3.Format(123, names[0])
Logln(str)
        str = fmt3.Format(123, "%%foo")
Errln("format double %%foo didn't fail")
    except Exception:
Logln("Got the expected exception")
    var fmt4: RuleBasedNumberFormat = RuleBasedNumberFormat(fracRules, CultureInfo("en"))
    var fmt5: RuleBasedNumberFormat = RuleBasedNumberFormat(fracRules, CultureInfo("en"))
    str = fmt4.ToString
Logln(str)
    if !fmt4.Equals(fmt5):
Errln("duplicate 2 equality failed")
    str = fmt4.Format(123)
Logln(str)
    try:
        var num: Number = fmt4.Parse(str)
Logln(num.ToString(CultureInfo.InvariantCulture))
    except Exception:
Errln("parse caught exception")
    str = fmt4.Format(0.000123)
Logln(str)
    try:
        var num: Number = fmt4.Parse(str)
Logln(num.ToString(CultureInfo.InvariantCulture))
    except Exception:
Errln("parse caught exception")
    str = fmt4.Format(456.000123)
Logln(str)
    try:
        var num: Number = fmt4.Parse(str)
Logln(num.ToString(CultureInfo.InvariantCulture))
    except Exception:
Errln("parse caught exception")
proc TestUndefinedSpellout*() =
    var greek: CultureInfo = CultureInfo("el")
    var formatters: RuleBasedNumberFormat[] = @[RuleBasedNumberFormat(greek, NumberPresentation.SpellOut), RuleBasedNumberFormat(greek, NumberPresentation.Ordinal), RuleBasedNumberFormat(greek, NumberPresentation.Duration)]
    var data: String[] = @["0", "1", "15", "20", "23", "73", "88", "100", "106", "127", "200", "579", "1,000", "2,000", "3,004", "4,567", "15,943", "105,000", "2,345,678", "-36", "-36.91215", "234.56789"]
    var decFormat: NumberFormat = NumberFormat.GetInstance(CultureInfo("en-US"))
      var j: int = 0
      while j < formatters.Length:
          var formatter: NumberFormat = formatters[j]
Logln("formatter[" + j + "]")
            var i: int = 0
            while i < data.Length:
                try:
                    var result: String = formatter.Format(decFormat.Parse(data[i]))
Logln("[" + i + "] " + data[i] + " ==> " + result)
                except Exception:
Errln("formatter[" + j + "], data[" + i + "] " + data[i] + " threw exception " + e.Message)
++i
++j
proc TestEnglishSpellout*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("en-US"), NumberPresentation.SpellOut)
    var testData: string[][] = @[@["1", "one"], @["15", "fifteen"], @["20", "twenty"], @["23", "twenty-three"], @["73", "seventy-three"], @["88", "eighty-eight"], @["100", "one hundred"], @["106", "one hundred six"], @["127", "one hundred twenty-seven"], @["200", "two hundred"], @["579", "five hundred seventy-nine"], @["1,000", "one thousand"], @["2,000", "two thousand"], @["3,004", "three thousand four"], @["4,567", "four thousand five hundred sixty-seven"], @["15,943", "fifteen thousand nine hundred forty-three"], @["2,345,678", "two million three hundred forty-five " + "thousand six hundred seventy-eight"], @["-36", "minus thirty-six"], @["234.567", "two hundred thirty-four point five six seven"]]
doTest(formatter, testData, true)
proc TestOrdinalAbbreviations*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("en-US"), NumberPresentation.Ordinal)
    var testData: string[][] = @[@["1", "1st"], @["2", "2nd"], @["3", "3rd"], @["4", "4th"], @["7", "7th"], @["10", "10th"], @["11", "11th"], @["13", "13th"], @["20", "20th"], @["21", "21st"], @["22", "22nd"], @["23", "23rd"], @["24", "24th"], @["33", "33rd"], @["102", "102nd"], @["312", "312th"], @["12,345", "12,345th"]]
doTest(formatter, testData, false)
proc TestDurations*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("en-US"), NumberPresentation.Duration)
    var testData: string[][] = @[@["3,600", "1:00:00"], @["0", "0 sec."], @["1", "1 sec."], @["24", "24 sec."], @["60", "1:00"], @["73", "1:13"], @["145", "2:25"], @["666", "11:06"], @["3,740", "1:02:20"], @["10,293", "2:51:33"]]
doTest(formatter, testData, true)
proc TestSpanishSpellout*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("es-es"), NumberPresentation.SpellOut)
    var testData: string[][] = @[@["1", "uno"], @["6", "seis"], @["16", "dieciséis"], @["20", "veinte"], @["24", "veinticuatro"], @["26", "veintiséis"], @["73", "setenta y tres"], @["88", "ochenta y ocho"], @["100", "cien"], @["106", "ciento seis"], @["127", "ciento veintisiete"], @["200", "doscientos"], @["579", "quinientos setenta y nueve"], @["1,000", "mil"], @["2,000", "dos mil"], @["3,004", "tres mil cuatro"], @["4,567", "cuatro mil quinientos sesenta y siete"], @["15,943", "quince mil novecientos cuarenta y tres"], @["2,345,678", "dos millones trescientos cuarenta y cinco mil " + "seiscientos setenta y ocho"], @["-36", "menos treinta y seis"], @["234.567", "doscientos treinta y cuatro coma cinco seis siete"]]
doTest(formatter, testData, true)
proc TestFrenchSpellout*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("fr-FR"), NumberPresentation.SpellOut)
    var testData: string[][] = @[@["1", "un"], @["15", "quinze"], @["20", "vingt"], @["21", "vingt-et-un"], @["23", "vingt-trois"], @["62", "soixante-deux"], @["70", "soixante-dix"], @["71", "soixante-et-onze"], @["73", "soixante-treize"], @["80", "quatre-vingts"], @["88", "quatre-vingt-huit"], @["100", "cent"], @["106", "cent six"], @["127", "cent vingt-sept"], @["200", "deux cents"], @["579", "cinq cent soixante-dix-neuf"], @["1,000", "mille"], @["1,123", "mille cent vingt-trois"], @["1,594", "mille cinq cent quatre-vingt-quatorze"], @["2,000", "deux mille"], @["3,004", "trois mille quatre"], @["4,567", "quatre mille cinq cent soixante-sept"], @["15,943", "quinze mille neuf cent quarante-trois"], @["2,345,678", "deux millions trois cent quarante-cinq mille " + "six cent soixante-dix-huit"], @["-36", "moins trente-six"], @["234.567", "deux cent trente-quatre virgule cinq six sept"]]
doTest(formatter, testData, true)
proc TestSwissFrenchSpellout*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("fr-CH"), NumberPresentation.SpellOut)
    var testData: string[][] = @[@["1", "un"], @["15", "quinze"], @["20", "vingt"], @["21", "vingt-et-un"], @["23", "vingt-trois"], @["62", "soixante-deux"], @["70", "septante"], @["71", "septante-et-un"], @["73", "septante-trois"], @["80", "huitante"], @["88", "huitante-huit"], @["100", "cent"], @["106", "cent six"], @["127", "cent vingt-sept"], @["200", "deux cents"], @["579", "cinq cent septante-neuf"], @["1,000", "mille"], @["1,123", "mille cent vingt-trois"], @["1,594", "mille cinq cent nonante-quatre"], @["2,000", "deux mille"], @["3,004", "trois mille quatre"], @["4,567", "quatre mille cinq cent soixante-sept"], @["15,943", "quinze mille neuf cent quarante-trois"], @["2,345,678", "deux millions trois cent quarante-cinq mille " + "six cent septante-huit"], @["-36", "moins trente-six"], @["234.567", "deux cent trente-quatre virgule cinq six sept"]]
doTest(formatter, testData, true)
proc TestItalianSpellout*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("it"), NumberPresentation.SpellOut)
    var testData: string[][] = @[@["1", "uno"], @["15", "quindici"], @["20", "venti"], @["23", "venti­tré"], @["73", "settanta­tré"], @["88", "ottant­otto"], @["100", "cento"], @["106", "cento­sei"], @["108", "cent­otto"], @["127", "cento­venti­sette"], @["181", "cent­ottant­uno"], @["200", "due­cento"], @["579", "cinque­cento­settanta­nove"], @["1,000", "mille"], @["2,000", "due­mila"], @["3,004", "tre­mila­quattro"], @["4,567", "quattro­mila­cinque­cento­sessanta­sette"], @["15,943", "quindici­mila­nove­cento­quaranta­tré"], @["-36", "meno trenta­sei"], @["234.567", "due­cento­trenta­quattro virgola cinque sei sette"]]
doTest(formatter, testData, true)
proc TestGermanSpellout*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("de-DE"), NumberPresentation.SpellOut)
    var testData: string[][] = @[@["1", "eins"], @["15", "fünfzehn"], @["20", "zwanzig"], @["23", "drei­und­zwanzig"], @["73", "drei­und­siebzig"], @["88", "acht­und­achtzig"], @["100", "ein­hundert"], @["106", "ein­hundert­sechs"], @["127", "ein­hundert­sieben­und­zwanzig"], @["200", "zwei­hundert"], @["579", "fünf­hundert­neun­und­siebzig"], @["1,000", "ein­tausend"], @["2,000", "zwei­tausend"], @["3,004", "drei­tausend­vier"], @["4,567", "vier­tausend­fünf­hundert­sieben­und­sechzig"], @["15,943", "fünfzehn­tausend­neun­hundert­drei­und­vierzig"], @["2,345,678", "zwei Millionen drei­hundert­fünf­und­vierzig­tausend­" + "sechs­hundert­acht­und­siebzig"]]
doTest(formatter, testData, true)
proc TestThaiSpellout*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("th-TH"), NumberPresentation.SpellOut)
    var testData: string[][] = @[@["0", "ศูนย์"], @["1", "หนึ่ง"], @["10", "สิบ"], @["11", "สิบ​เอ็ด"], @["21", "ยี่​สิบ​เอ็ด"], @["101", "หนึ่ง​ร้อย​หนึ่ง"], @["1.234", "หนึ่ง​จุด​สองสามสี่"], @["21.45", "ยี่​สิบ​เอ็ด​จุด​สี่ห้า"], @["22.45", "ยี่​สิบ​สอง​จุด​สี่ห้า"], @["23.45", "ยี่​สิบ​สาม​จุด​สี่ห้า"], @["123.45", "หนึ่ง​ร้อย​ยี่​สิบ​สาม​จุด​สี่ห้า"], @["12,345.678", "หนึ่ง​หมื่น​สอง​พัน​สาม​ร้อย​สี่​สิบ​ห้า​จุด​หกเจ็ดแปด"]]
doTest(formatter, testData, true)
proc TestPluralRules*() =
    var enRules: String = "%digits-ordinal:" + "-x: −>>;" + "0: =#,##0=$(ordinal,one{st}two{nd}few{rd}other{th})$;"
    var enFormatter: RbnfFormattterSettings = RbnfFormattterSettings(enRules, UCultureInfo("en"))
    var enTestData: string[][] = @[@["1", "1st"], @["2", "2nd"], @["3", "3rd"], @["4", "4th"], @["11", "11th"], @["12", "12th"], @["13", "13th"], @["14", "14th"], @["21", "21st"], @["22", "22nd"], @["23", "23rd"], @["24", "24th"]]
doTest(enFormatter, enTestData, true)
    var ruRules: String = "%spellout-numbering:" + "-x: минус >>;" + "x.x: [<< $(cardinal,one{целый}other{целых})$ ]>%%fractions-feminine>;" + "0: ноль;" + "1: один;" + "2: два;" + "3: три;" + "4: четыре;" + "5: пять;" + "6: шесть;" + "7: семь;" + "8: восемь;" + "9: девять;" + "10: десять;" + "11: одиннадцать;" + "12: двенадцать;" + "13: тринадцать;" + "14: четырнадцать;" + "15: пятнадцать;" + "16: шестнадцать;" + "17: семнадцать;" + "18: восемнадцать;" + "19: девятнадцать;" + "20: двадцать[ >>];" + "30: тридцать[ >>];" + "40: сорок[ >>];" + "50: пятьдесят[ >>];" + "60: шестьдесят[ >>];" + "70: семьдесят[ >>];" + "80: восемьдесят[ >>];" + "90: девяносто[ >>];" + "100: сто[ >>];" + "200: <<сти[ >>];" + "300: <<ста[ >>];" + "500: <<сот[ >>];" + "1000: << $(cardinal,one{тысяча}few{тысячи}other{тысяч})$[ >>];" + "1000000: << $(cardinal,one{миллион}few{миллионы}other{миллионов})$[ >>];" + "%%fractions-feminine:" + "10: <%spellout-numbering< $(cardinal,one{десятая}other{десятых})$;" + "100: <%spellout-numbering< $(cardinal,one{сотая}other{сотых})$;"
    var ruFormatter: RbnfFormattterSettings = RbnfFormattterSettings(ruRules, UCultureInfo("ru"))
    var ruTestData: string[][] = @[@["1", "один"], @["100", "сто"], @["125", "сто двадцать пять"], @["399", "триста девяносто девять"], @["1,000", "один тысяча"], @["1,001", "один тысяча один"], @["2,000", "два тысячи"], @["2,001", "два тысячи один"], @["2,002", "два тысячи два"], @["3,333", "три тысячи триста тридцать три"], @["5,000", "пять тысяч"], @["11,000", "одиннадцать тысяч"], @["21,000", "двадцать один тысяча"], @["22,000", "двадцать два тысячи"], @["25,001", "двадцать пять тысяч один"], @["0.1", "один десятая"], @["0.2", "два десятых"], @["0.21", "двадцать один сотая"], @["0.22", "двадцать два сотых"], @["21.1", "двадцать один целый один десятая"], @["22.2", "двадцать два целых два десятых"]]
doTest(ruFormatter, ruTestData, true)
    var result: String = RuleBasedNumberFormat(ruRules, UCultureInfo("ru")).Format(21000)
    if !"двадцать один тысяча".Equals(result, StringComparison.Ordinal):
Errln("Got " + result + " for 21000")
    var russianRules: NumberFormatRules = ruFormatter.CreateNumberFormatRules
    var result2: string = IcuNumber.FormatInt64RuleBased(21000, russianRules, nil, UCultureInfo("ru").NumberFormat)
    if !"двадцать один тысяча".Equals(result2, StringComparison.Ordinal):
Errln("Got " + result + " for 21000")
proc TestMultiplePluralRules*() =
    var ruRules: String = "%spellout-cardinal-feminine-genitive:" + "-x: минус >>;" + "x.x: << запятая >>;" + "0: ноля;" + "1: одной;" + "2: двух;" + "3: трех;" + "4: четырех;" + "5: пяти;" + "6: шести;" + "7: семи;" + "8: восьми;" + "9: девяти;" + "10: десяти;" + "11: одиннадцати;" + "12: двенадцати;" + "13: тринадцати;" + "14: четырнадцати;" + "15: пятнадцати;" + "16: шестнадцати;" + "17: семнадцати;" + "18: восемнадцати;" + "19: девятнадцати;" + "20: двадцати[ >>];" + "30: тридцати[ >>];" + "40: сорока[ >>];" + "50: пятидесяти[ >>];" + "60: шестидесяти[ >>];" + "70: семидесяти[ >>];" + "80: восемидесяти[ >>];" + "90: девяноста[ >>];" + "100: ста[ >>];" + "200: <<сот[ >>];" + "1000: << $(cardinal,one{тысяча}few{тысячи}other{тысяч})$[ >>];" + "1000000: =#,##0=;" + "%spellout-cardinal-feminine:" + "-x: минус >>;" + "x.x: << запятая >>;" + "0: ноль;" + "1: одна;" + "2: две;" + "3: три;" + "4: четыре;" + "5: пять;" + "6: шесть;" + "7: семь;" + "8: восемь;" + "9: девять;" + "10: десять;" + "11: одиннадцать;" + "12: двенадцать;" + "13: тринадцать;" + "14: четырнадцать;" + "15: пятнадцать;" + "16: шестнадцать;" + "17: семнадцать;" + "18: восемнадцать;" + "19: девятнадцать;" + "20: двадцать[ >>];" + "30: тридцать[ >>];" + "40: сорок[ >>];" + "50: пятьдесят[ >>];" + "60: шестьдесят[ >>];" + "70: семьдесят[ >>];" + "80: восемьдесят[ >>];" + "90: девяносто[ >>];" + "100: сто[ >>];" + "200: <<сти[ >>];" + "300: <<ста[ >>];" + "500: <<сот[ >>];" + "1000: << $(cardinal,one{тысяча}few{тысячи}other{тысяч})$[ >>];" + "1000000: =#,##0=;"
    var ruFormatter: RuleBasedNumberFormat = RuleBasedNumberFormat(ruRules, UCultureInfo("ru"))
    try:
        var result: Number
        if 1000 !=         result = ruFormatter.Parse(ruFormatter.Format(1000)).ToDouble:
Errln("RuleBasedNumberFormat did not return the correct value. Got: " + result)
        if 1000 !=         result = ruFormatter.Parse(ruFormatter.Format(1000, "%spellout-cardinal-feminine-genitive")).ToDouble:
Errln("RuleBasedNumberFormat did not return the correct value. Got: " + result)
        if 1000 !=         result = ruFormatter.Parse(ruFormatter.Format(1000, "%spellout-cardinal-feminine")).ToDouble:
Errln("RuleBasedNumberFormat did not return the correct value. Got: " + result)
    except FormatException:
Errln(e.ToString)
proc TestFractionalRuleSet*() =
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(fracRules, CultureInfo("en"))
    var testData: string[][] = @[@["0", "0"], @["1", "1"], @["10", "10"], @[".1", "1/10"], @[".11", "1/9"], @[".125", "1/8"], @[".1428", "1/7"], @[".1667", "1/6"], @[".2", "1/5"], @[".25", "1/4"], @[".333", "1/3"], @[".5", "1/2"], @["1.1", "1 1/10"], @["2.11", "2 1/9"], @["3.125", "3 1/8"], @["4.1428", "4 1/7"], @["5.1667", "5 1/6"], @["6.2", "6 1/5"], @["7.25", "7 1/4"], @["8.333", "8 1/3"], @["9.5", "9 1/2"], @[".2222", "2/9"], @[".4444", "4/9"], @[".5555", "5/9"], @["1.2856", "1 2/7"]]
doTest(formatter, testData, false)
proc TestSwedishSpellout*() =
    var locale: CultureInfo = CultureInfo("sv")
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(locale, NumberPresentation.SpellOut)
    var testDataDefault: string[][] = @[@["101", "ett­hundra­ett"], @["123", "ett­hundra­tjugo­tre"], @["1,001", "et­tusen ett"], @["1,100", "et­tusen ett­hundra"], @["1,101", "et­tusen ett­hundra­ett"], @["1,234", "et­tusen två­hundra­trettio­fyra"], @["10,001", "tio­tusen ett"], @["11,000", "elva­tusen"], @["12,000", "tolv­tusen"], @["20,000", "tjugo­tusen"], @["21,000", "tjugo­et­tusen"], @["21,001", "tjugo­et­tusen ett"], @["200,000", "två­hundra­tusen"], @["201,000", "två­hundra­et­tusen"], @["200,200", "två­hundra­tusen två­hundra"], @["2,002,000", "två miljoner två­tusen"], @["12,345,678", "tolv miljoner tre­hundra­fyrtio­fem­tusen sex­hundra­sjuttio­åtta"], @["123,456.789", "ett­hundra­tjugo­tre­tusen fyra­hundra­femtio­sex komma sju åtta nio"], @["-12,345.678", "minus tolv­tusen tre­hundra­fyrtio­fem komma sex sju åtta"]]
Logln("testing default rules")
doTest(formatter, testDataDefault, true)
    var testDataNeutrum: string[][] = @[@["101", "ett­hundra­ett"], @["1,001", "et­tusen ett"], @["1,101", "et­tusen ett­hundra­ett"], @["10,001", "tio­tusen ett"], @["21,001", "tjugo­et­tusen ett"]]
formatter.SetDefaultRuleSet("%spellout-cardinal-neuter")
Logln("testing neutrum rules")
doTest(formatter, testDataNeutrum, true)
    var testDataYear: string[][] = @[@["101", "ett­hundra­ett"], @["900", "nio­hundra"], @["1,001", "et­tusen ett"], @["1,100", "elva­hundra"], @["1,101", "elva­hundra­ett"], @["1,234", "tolv­hundra­trettio­fyra"], @["2,001", "tjugo­hundra­ett"], @["10,001", "tio­tusen ett"]]
formatter.SetDefaultRuleSet("%spellout-numbering-year")
Logln("testing year rules")
doTest(formatter, testDataYear, true)
proc TestBigNumbers*() =
    var bigI: ICU4N.Numerics.BigMath.BigInteger = ICU4N.Numerics.BigMath.BigInteger.Parse("1234567890", 10)
    var buf: StringBuffer = StringBuffer
    var fmt: RuleBasedNumberFormat = RuleBasedNumberFormat(NumberPresentation.SpellOut)
fmt.Format(bigI, buf, nil)
Logln("big int: " + buf.ToString)
    buf.Length = 0
    var bigD: ICU4N.Numerics.BigMath.BigDecimal = ICU4N.Numerics.BigMath.BigDecimal(bigI)
fmt.Format(bigD, buf, nil)
Logln("big dec: " + buf.ToString)
proc TestBigNumbers2*() =
    var bigI: System.Numerics.BigInteger = System.Numerics.BigInteger.Parse("1234567890", CultureInfo.InvariantCulture)
    var buf: StringBuffer = StringBuffer
    var fmt: RuleBasedNumberFormat = RuleBasedNumberFormat(NumberPresentation.SpellOut)
fmt.Format(bigI, buf, nil)
Logln("big int: " + buf.ToString)
proc TestTrailingSemicolon*() =
    var thaiRules: String = "%default:
" + "  -x: ลบ>>;
" + "  x.x: <<จุด>>>;
" + "  ศูนย์; หนึ่ง; สอง; สาม;
" + "  สี่; ห้า; หก; เจ็ด; แปด;
" + "  เก้า; สิบ; สิบเอ็ด;
" + "  สิบสอง; สิบสาม;
" + "  สิบสี่; สิบห้า;
" + "  สิบหก; สิบเจ็ด;
" + "  สิบแปด; สิบเก้า;
" + "  20: ยี่สิบ[>%%alt-ones>];
" + "  30: สามสิบ[>%%alt-ones>];
" + "  40: สี่สิบ[>%%alt-ones>];
" + "  50: ห้าสิบ[>%%alt-ones>];
" + "  60: หกสิบ[>%%alt-ones>];
" + "  70: เจ็ดสิบ[>%%alt-ones>];
" + "  80: แปดสิบ[>%%alt-ones>];
" + "  90: เก้าสิบ[>%%alt-ones>];
" + "  100: <<ร้อย[>>];
" + "  1000: <<พัน[>>];
" + "  10000: <<หมื่น[>>];
" + "  100000: <<แสน[>>];
" + "  1,000,000: <<ล้าน[>>];
" + "  1,000,000,000: <<พันล้าน[>>];
" + "  1,000,000,000,000: <<ล้านล้าน[>>];
" + "  1,000,000,000,000,000: =#,##0=;
" + "%%alt-ones:
" + "  ศูนย์;
" + "  เอ็ด;
" + "  =%default=;
 ; ;; "
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(thaiRules, CultureInfo("th-TH"))
    var testData: string[][] = @[@["0", "ศูนย์"], @["1", "หนึ่ง"], @["123.45", "หนึ่งร้อยยี่สิบสามจุดสี่ห้า"]]
doTest(formatter, testData, true)
proc TestSmallValues*() =
    var testData: string[][] = @[@["0.001", "zero point zero zero one"], @["0.0001", "zero point zero zero zero one"], @["0.00001", "zero point zero zero zero zero one"], @["0.000001", "zero point zero zero zero zero zero one"], @["0.0000001", "zero point zero zero zero zero zero zero one"], @["0.00000001", "zero point zero zero zero zero zero zero zero one"], @["0.000000001", "zero point zero zero zero zero zero zero zero zero one"], @["0.0000000001", "zero point zero zero zero zero zero zero zero zero zero one"], @["0.00000000001", "zero point zero zero zero zero zero zero zero zero zero zero one"], @["0.000000000001", "zero point zero zero zero zero zero zero zero zero zero zero zero one"], @["0.0000000000001", "zero point zero zero zero zero zero zero zero zero zero zero zero zero one"], @["0.00000000000001", "zero point zero zero zero zero zero zero zero zero zero zero zero zero zero one"], @["0.000000000000001", "zero point zero zero zero zero zero zero zero zero zero zero zero zero zero zero one"], @["10,000,000.001", "ten million point zero zero one"], @["10,000,000.0001", "ten million point zero zero zero one"], @["10,000,000.00001", "ten million point zero zero zero zero one"], @["10,000,000.000001", "ten million point zero zero zero zero zero one"], @["10,000,000.0000001", "ten million point zero zero zero zero zero zero one"], @["10,000,000.00000001", "ten million point zero zero zero zero zero zero zero one"], @["10,000,000.000000002", "ten million point zero zero zero zero zero zero zero zero two"], @["10,000,000", "ten million"], @["1,234,567,890.0987654", "one billion two hundred thirty-four million five hundred sixty-seven thousand eight hundred ninety point zero nine eight seven six five four"], @["123,456,789.9876543", "one hundred twenty-three million four hundred fifty-six thousand seven hundred eighty-nine point nine eight seven six five four three"], @["12,345,678.87654321", "twelve million three hundred forty-five thousand six hundred seventy-eight point eight seven six five four three two one"], @["1,234,567.7654321", "one million two hundred thirty-four thousand five hundred sixty-seven point seven six five four three two one"], @["123,456.654321", "one hundred twenty-three thousand four hundred fifty-six point six five four three two one"], @["12,345.54321", "twelve thousand three hundred forty-five point five four three two one"], @["1,234.4321", "one thousand two hundred thirty-four point four three two one"], @["123.321", "one hundred twenty-three point three two one"], @["0.0000000011754944", "zero point zero zero zero zero zero zero zero zero one one seven five four nine four four"], @["0.000001175494351", "zero point zero zero zero zero zero one one seven five four nine four three five one"]]
    var formatter: RbnfFormattterSettings = RbnfFormattterSettings(CultureInfo("en-US"), NumberPresentation.SpellOut)
doTest(formatter, testData, true)
proc TestRuleSetDisplayName*() =
Assume.That(!PlatformDetection.IsLinux, "LUCENENET TODO: On Linux, this test is failing for some unkown reason. Most likely, it is because the localizations array is not being processed correctly.")
    var ukEnglish: String = "%simplified:
" + "    -x: minus >>;
" + "    x.x: << point >>;
" + "    zero; one; two; three; four; five; six; seven; eight; nine;
" + "    ten; eleven; twelve; thirteen; fourteen; fifteen; sixteen;
" + "        seventeen; eighteen; nineteen;
" + "    20: twenty[->>];
" + "    30: thirty[->>];
" + "    40: forty[->>];
" + "    50: fifty[->>];
" + "    60: sixty[->>];
" + "    70: seventy[->>];
" + "    80: eighty[->>];
" + "    90: ninety[->>];
" + "    100: << hundred[ >>];
" + "    1000: << thousand[ >>];
" + "    1,000,000: << million[ >>];
" + "    1,000,000,000,000: << billion[ >>];
" + "    1,000,000,000,000,000: =#,##0=;
" + "%alt-teens:
" + "    =%simplified=;
" + "    1000>: <%%alt-hundreds<[ >>];
" + "    10,000: =%simplified=;
" + "    1,000,000: << million[ >%simplified>];
" + "    1,000,000,000,000: << billion[ >%simplified>];
" + "    1,000,000,000,000,000: =#,##0=;
" + "%%alt-hundreds:
" + "    0: SHOULD NEVER GET HERE!;
" + "    10: <%simplified< thousand;
" + "    11: =%simplified= hundred>%%empty>;
" + "%%empty:
" + "    0:;" + "%ordinal:
" + "    zeroth; first; second; third; fourth; fifth; sixth; seventh;
" + "        eighth; ninth;
" + "    tenth; eleventh; twelfth; thirteenth; fourteenth;
" + "        fifteenth; sixteenth; seventeenth; eighteenth;
" + "        nineteenth;
" + "    twentieth; twenty->>;
" + "    30: thirtieth; thirty->>;
" + "    40: fortieth; forty->>;
" + "    50: fiftieth; fifty->>;
" + "    60: sixtieth; sixty->>;
" + "    70: seventieth; seventy->>;
" + "    80: eightieth; eighty->>;
" + "    90: ninetieth; ninety->>;
" + "    100: <%simplified< hundredth; <%simplified< hundred >>;
" + "    1000: <%simplified< thousandth; <%simplified< thousand >>;
" + "    1,000,000: <%simplified< millionth; <%simplified< million >>;
" + "    1,000,000,000,000: <%simplified< billionth;
" + "        <%simplified< billion >>;
" + "    1,000,000,000,000,000: =#,##0=;" + "%default:
" + "    -x: minus >>;
" + "    x.x: << point >>;
" + "    =%simplified=;
" + "    100: << hundred[ >%%and>];
" + "    1000: << thousand[ >%%and>];
" + "    100,000>>: << thousand[>%%commas>];
" + "    1,000,000: << million[>%%commas>];
" + "    1,000,000,000,000: << billion[>%%commas>];
" + "    1,000,000,000,000,000: =#,##0=;
" + "%%and:
" + "    and =%default=;
" + "    100: =%default=;
" + "%%commas:
" + "    ' and =%default=;
" + "    100: , =%default=;
" + "    1000: , <%default< thousand, >%default>;
" + "    1,000,000: , =%default=;" + "%%lenient-parse:
" + "    & ' ' , ',' ;
"
    UCultureInfo.CurrentCulture = UCultureInfo("en-US")
    var localizations: string[][] = @[@["%simplified", "%default", "%ordinal"], @["en_US", "Simplified", "Default", "Ordinal"], @["zh_Hans", "简化", "缺省", "序列"], @["foo_Bar_BAZ", "Simplified", "Default", "Ordinal"]]
    var formatter: RuleBasedNumberFormat = RuleBasedNumberFormat(ukEnglish, localizations, UCultureInfo("en-US"))
    var f2: RuleBasedNumberFormat = RuleBasedNumberFormat(ukEnglish, localizations)
assertTrue("Check the two formatters' equality", formatter.Equals(f2))
    var ruleSetNames: String[] = formatter.GetRuleSetNames
      var i: int = 0
      while i < ruleSetNames.Length:
Logln("Rule set name: " + ruleSetNames[i])
          var RSName_defLoc: String = formatter.GetRuleSetDisplayName(ruleSetNames[i])
assertEquals("Display name in default locale (" & $UCultureInfo.CurrentUICulture.FullName & ") for index " & $i & ".", localizations[1][i + 1], RSName_defLoc)
          var RSName_loc: String = formatter.GetRuleSetDisplayName(ruleSetNames[i], UCultureInfo("zh_Hans_CN"))
assertEquals("Display name in Chinese for index " & $i & ".", localizations[2][i + 1], RSName_loc)
++i
    var defaultRS: String = formatter.DefaultRuleSetName
assertEquals("getDefaultRuleSetName", "%simplified", defaultRS)
    var locales: UCultureInfo[] = formatter.GetRuleSetDisplayNameLocales
      var i: int = 0
      while i < locales.Length:
Logln(locales[i].FullName)
++i
    var RSNames_defLoc: String[] = formatter.GetRuleSetDisplayNames
      var i: int = 0
      while i < RSNames_defLoc.Length:
assertEquals("getRuleSetDisplayNames in default locale", localizations[1][i + 1], RSNames_defLoc[i])
++i
    var RSNames_loc: String[] = formatter.GetRuleSetDisplayNames(UCultureInfo("en_GB"))
      var i: int = 0
      while i < RSNames_loc.Length:
assertEquals("getRuleSetDisplayNames in English", localizations[1][i + 1], RSNames_loc[i])
++i
    RSNames_loc = formatter.GetRuleSetDisplayNames(UCultureInfo("zh_Hans_CN"))
      var i: int = 0
      while i < RSNames_loc.Length:
assertEquals("getRuleSetDisplayNames in Chinese", localizations[2][i + 1], RSNames_loc[i])
++i
    RSNames_loc = formatter.GetRuleSetDisplayNames(UCultureInfo("foo_Bar_BAZ"))
      var i: int = 0
      while i < RSNames_loc.Length:
assertEquals("getRuleSetDisplayNames in fake locale", localizations[3][i + 1], RSNames_loc[i])
++i
proc TestAllLocales_DecimalFormatPattern*() =
    var diff = System.Collections.Generic.Dictionary<UCultureInfo, string>
    var names: String[] = @[" (spellout) ", " (ordinal) ", " (duration) ", " (numbering system)"]
    for loc in NumberFormat.GetUCultures(UCultureTypes.AllCultures):
        var culture: CultureInfo = loc.ToCultureInfo
          var j: int = 0
          while j < names.Length:
              var fmt: RuleBasedNumberFormat = RuleBasedNumberFormat(loc, cast[NumberPresentation](j))
              var number: double = 12345678.901234567
              var pattern: string = fmt.DecimalFormat.ToPattern
              var icuNumberFormat: string = fmt.DecimalFormat.Format(number)
              var symbols = fmt.DecimalFormatSymbols
              var digits: string[] = symbols.DigitStringsLocal
              var info = NumberFormatInfo
              info.NumberGroupSeparator = symbols.GroupingSeparatorString
              info.NumberDecimalSeparator = symbols.DecimalSeparatorString
              info.NumberGroupSizes = GetGroupingSizes(pattern)
              info.NegativeSign = symbols.MinusSignString
              info.PositiveSign = symbols.PlusSignString
              info.NaNSymbol = symbols.NaN
              info.PositiveInfinitySymbol = symbols.Infinity
              info.NegativeInfinitySymbol = info.NegativeSign + symbols.Infinity
              var tempNetNumberFormat: string = number.ToString(pattern, info)
              var netNumberFormat: string = tempNetNumberFormat
              if !AreAsciiDigits(digits):
                  var sb = ICU4N.Text.ValueStringBuilder(seq[char])
                  var charsWritten: int = 0
                  for ch in tempNetNumberFormat:
                      if IsAsciiDigit(ch):
                          var text: string = digits[ch - 48]
sb.Append(text)
                          charsWritten = text.Length
                      else:
sb.Append(ch)
++charsWritten
                  netNumberFormat = sb.ToString
              if icuNumberFormat != netNumberFormat && !diff.ContainsKey(loc):
diff.Add(loc, string.Concat(icuNumberFormat, "|", netNumberFormat))
++j
assertEquals("", 0, diff.Count)
proc AreAsciiDigits*(digits: seq[string]): bool =
    if digits.Length != 10:
      return false
    return digits[0] == "0" && digits[1] == "1" && digits[2] == "2" && digits[3] == "3" && digits[4] == "4" && digits[5] == "5" && digits[6] == "6" && digits[7] == "7" && digits[8] == "8" && digits[9] == "9"
proc GetGroupingSizes*(pattern: string): int[] =
    var patternInfo: PatternStringParser.ParsedPatternInfo = PatternStringParser.ParseToPatternInfo(pattern)
    var positive: PatternStringParser.ParsedSubpatternInfo = patternInfo.positive
    var grouping1: short = cast[short](positive.groupingSizes & 65535)
    var grouping2: short = cast[short](positive.groupingSizes >>> 16 & 65535)
    var grouping3: short = cast[short](positive.groupingSizes >>> 32 & 65535)
    var groupingSize: int =     if grouping1 < 0:
0
    else:
grouping1
    var secondaryGroupingSize: int =     if grouping3 != -1:
        if grouping2 < 0:
0
        else:
grouping2
    else:
0
    if groupingSize == 0 || secondaryGroupingSize == 0:
      return @[groupingSize]
    return @[groupingSize, secondaryGroupingSize]
proc IsAsciiDigit*(c: char): bool =
    return IsBetween(c, '0', '9')
proc IsBetween*(c: char, minInclusive: char, maxInclusive: char): bool =
    return cast[uint](c - minInclusive) <= cast[uint](maxInclusive - minInclusive)
proc TestAllLocales*() =
    var errors: StringBuilder = StringBuilder
    var names: String[] = @[" (spellout) ", " (ordinal) "]
    var numbers: double[] = @[45.678, 1, 2, 10, 11, 100, 110, 200, 1000, 1111, -1111]
    var count: int = numbers.Length
    var r: Random =     if count <= numbers.Length:
nil
    else:
CreateRandom
    for loc in NumberFormat.GetUCultures(UCultureTypes.AllCultures):
          var j: int = 0
          while j < names.Length:
              var fmt: RuleBasedNumberFormat = RuleBasedNumberFormat(loc, cast[NumberPresentation](j))
              if !loc.Equals(fmt.ActualCulture):
                  break
                var c: int = 0
                while c < count:
                    var n: double
                    if c < numbers.Length:
                        n = numbers[c]
                    else:
                        n = r.Next(10000) - 3000 / 16.0
                    var s: String = fmt.Format(n)
                    if IsVerbose:
Logln(loc.FullName + names[j] + "success format: " + n + " -> " + s)
                    try:
                        fmt.LenientParseEnabled = false

                        var num: Number = fmt.Parse(s)
                        if IsVerbose:
Logln(loc.FullName + names[j] + "success parse: " + s + " -> " + num)
                        if j != 0:
                            continue
                        if n != num.ToDouble:
errors.Append("
" + loc + names[j] + "got " + num + " expected " + n)
                    except FormatException:
                        var msg: String = loc.FullName + names[j] + "ERROR:" + pe.ToString
Logln(msg)
errors.Append("
" + msg)
++c
++j
    if errors.Length > 0:
Errln(errors.ToString)
proc doTest(formatterSettings: RbnfFormattterSettings, testData: seq[string], testParsing: bool) =
    var formatter: RuleBasedNumberFormat = formatterSettings.formatter
    var decFmt: NumberFormat = DecimalFormat("#,###.################")
    try:
          var i: int = 0
          while i < testData.Length:
              var number: String = testData[i][0]
              var expectedWords: String = testData[i][1]
              if IsVerbose:
Logln("test[" + i + "] number: " + number + " target: " + expectedWords)
              var num: Number = decFmt.Parse(number)
              var actualWords: String = formatter.Format(num)
              if !actualWords.Equals(expectedWords):
Errln("Spot check format failed: for " + number + ", expected
    " + expectedWords + ", but got
    " + actualWords)

              elif testParsing:
                  var actualNumber: String = decFmt.Format(formatter.Parse(actualWords))
                  if !actualNumber.Equals(number):
Errln("Spot check parse failed: for " + actualWords + ", expected " + number + ", but got " + actualNumber)
              actualWords = formatterSettings.FormatWithIcuNumber(num)
              if !actualWords.Equals(expectedWords):
Errln("Spot check format failed: for " + number + ", expected
    " + expectedWords + ", but got
    " + actualWords)

              elif testParsing:
                  var actualNumber: String = decFmt.Format(formatter.Parse(actualWords))
                  if !actualNumber.Equals(number):
Errln("Spot check parse failed: for " + actualWords + ", expected " + number + ", but got " + actualNumber)
++i
    except Exception:
Errln("Test failed with exception: " + e.ToString)
Console.WriteLine(e.ToString)
proc doTest(formatter: RuleBasedNumberFormat, testData: seq[string], testParsing: bool) =
    var decFmt: NumberFormat = DecimalFormat("#,###.################")
    try:
          var i: int = 0
          while i < testData.Length:
              var number: String = testData[i][0]
              var expectedWords: String = testData[i][1]
              if IsVerbose:
Logln("test[" + i + "] number: " + number + " target: " + expectedWords)
              var num: Number = decFmt.Parse(number)
              var actualWords: String = formatter.Format(num)
              if !actualWords.Equals(expectedWords):
Errln("Spot check format failed: for " + number + ", expected
    " + expectedWords + ", but got
    " + actualWords)

              elif testParsing:
                  var actualNumber: String = decFmt.Format(formatter.Parse(actualWords))
                  if !actualNumber.Equals(number):
Errln("Spot check parse failed: for " + actualWords + ", expected " + number + ", but got " + actualNumber)
++i
    except Exception:
Errln("Test failed with exception: " + e.ToString)
Console.WriteLine(e.ToString)
proc TestEquals*() =
    var rbnf: RuleBasedNumberFormat = RuleBasedNumberFormat("dummy")
    if rbnf.Equals("dummy") || rbnf.Equals('a') || rbnf.Equals(Object) || rbnf.Equals(-1) || rbnf.Equals(0) || rbnf.Equals(1) || rbnf.Equals(-1.0) || rbnf.Equals(0.0) || rbnf.Equals(1.0):
Errln("RuleBasedNumberFormat.equals(Object that) was suppose to " + "be false for an invalid object.")
    var rbnf1: RuleBasedNumberFormat = RuleBasedNumberFormat("dummy", CultureInfo("en"))
    var rbnf2: RuleBasedNumberFormat = RuleBasedNumberFormat("dummy", CultureInfo("jp"))
    var rbnf3: RuleBasedNumberFormat = RuleBasedNumberFormat("dummy", CultureInfo("sp"))
    var rbnf4: RuleBasedNumberFormat = RuleBasedNumberFormat("dummy", CultureInfo("fr"))
    if rbnf1.Equals(rbnf2) || rbnf1.Equals(rbnf3) || rbnf1.Equals(rbnf4) || rbnf2.Equals(rbnf3) || rbnf2.Equals(rbnf4) || rbnf3.Equals(rbnf4):
Errln("RuleBasedNumberFormat.equals(Object that) was suppose to " + "be false for an invalid object.")
    if !rbnf1.Equals(rbnf1):
Errln("RuleBasedNumberFormat.equals(Object that) was not suppose to " + "be false for an invalid object.")
    if !rbnf2.Equals(rbnf2):
Errln("RuleBasedNumberFormat.equals(Object that) was not suppose to " + "be false for an invalid object.")
    if !rbnf3.Equals(rbnf3):
Errln("RuleBasedNumberFormat.equals(Object that) was not suppose to " + "be false for an invalid object.")
    if !rbnf4.Equals(rbnf4):
Errln("RuleBasedNumberFormat.equals(Object that) was not suppose to " + "be false for an invalid object.")
    var rbnf5: RuleBasedNumberFormat = RuleBasedNumberFormat("dummy", CultureInfo("en"))
    var rbnf6: RuleBasedNumberFormat = RuleBasedNumberFormat("dummy", CultureInfo("en"))
    if !rbnf5.Equals(rbnf6):
Errln("RuleBasedNumberFormat.equals(Object that) was not suppose to " + "be false for an invalid object.")
    rbnf6.LenientParseEnabled = true
    if rbnf5.Equals(rbnf6):
Errln("RuleBasedNumberFormat.equals(Object that) was suppose to " + "be false for an invalid object.")
    var rbnf7: RuleBasedNumberFormat = RuleBasedNumberFormat("not_dummy", CultureInfo("en"))
    if rbnf5.Equals(rbnf7):
Errln("RuleBasedNumberFormat.equals(Object that) was suppose to " + "be false for an invalid object.")
proc TestGetRuleDisplayNameLocales*() =
    var rbnf: RuleBasedNumberFormat = RuleBasedNumberFormat("dummy")
rbnf.GetRuleSetDisplayNameLocales
    if rbnf.GetRuleSetDisplayNameLocales != nil:
Errln("RuleBasedNumberFormat.getRuleDisplayNameLocales() was suppose to " + "return null.")
proc TestGetNameListForLocale*() =
    var rbnf: RuleBasedNumberFormat = RuleBasedNumberFormat("dummy")
rbnf.GetRuleSetDisplayNames(nil)
    try:
rbnf.GetRuleSetDisplayNames(nil)
    except Exception:
Errln("RuleBasedNumberFormat.getRuleSetDisplayNames(ULocale loc) " + "was not suppose to have an exception.")
proc TestGetRulesSetDisplayName*() =
    var rbnf: RuleBasedNumberFormat = RuleBasedNumberFormat("dummy")
    try:
rbnf.GetRuleSetDisplayName("", UCultureInfo("en_US"))
Errln("RuleBasedNumberFormat.getRuleSetDisplayName(String ruleSetName, ULocale loc) " + "was suppose to have an exception.")
    except Exception:

    try:
rbnf.GetRuleSetDisplayName("dummy", UCultureInfo("en_US"))
Errln("RuleBasedNumberFormat.getRuleSetDisplayName(String ruleSetName, ULocale loc) " + "was suppose to have an exception.")
    except Exception:

proc TestChineseProcess*() =
    var ruleWithChinese: String = "%simplified:
" + "    -x: minus >>;
" + "    x.x: << point >>;
" + "    zero; one; two; three; four; five; six; seven; eight; nine;
" + "    ten; eleven; twelve; thirteen; fourteen; fifteen; sixteen;
" + "        seventeen; eighteen; nineteen;
" + "    20: twenty[->>];
" + "    30: thirty[->>];
" + "    40: forty[->>];
" + "    50: fifty[->>];
" + "    60: sixty[->>];
" + "    70: seventy[->>];
" + "    80: eighty[->>];
" + "    90: ninety[->>];
" + "    100: << hundred[ >>];
" + "    1000: << thousand[ >>];
" + "    1,000,000: << million[ >>];
" + "    1,000,000,000,000: << billion[ >>];
" + "    1,000,000,000,000,000: =#,##0=;
" + "%alt-teens:
" + "    =%simplified=;
" + "    1000>: <%%alt-hundreds<[ >>];
" + "    10,000: =%simplified=;
" + "    1,000,000: << million[ >%simplified>];
" + "    1,000,000,000,000: << billion[ >%simplified>];
" + "    1,000,000,000,000,000: =#,##0=;
" + "%%alt-hundreds:
" + "    0: SHOULD NEVER GET HERE!;
" + "    10: <%simplified< thousand;
" + "    11: =%simplified= hundred>%%empty>;
" + "%%empty:
" + "    0:;" + "%accounting:
" + "    萬; 萬; 萬; 萬; 萬; 萬; 萬; 萬;
" + "        萬; 萬;
" + "    萬; 萬; 萬; 萬; 萬;
" + "        萬; 萬; 萬; 萬;
" + "        萬;
" + "    twentieth; 零|>>;
" + "    30: 零; 零|>>;
" + "    40: 零; 零|>>;
" + "    50: 零; 零|>>;
" + "    60: 零; 零|>>;
" + "    70: 零; 零|>>;
" + "    80: 零; 零|>>;
" + "    90: 零; 零|>>;
" + "    100: <%simplified< 零; <%simplified< 零 >>;
" + "    1000: <%simplified< 零; <%simplified< 零 >>;
" + "    1,000,000: <%simplified< 零; <%simplified< 零 >>;
" + "    1,000,000,000,000: <%simplified< 零;
" + "        <%simplified< 零 >>;
" + "    1,000,000,000,000,000: =#,##0=;" + "%default:
" + "    -x: minus >>;
" + "    x.x: << point >>;
" + "    =%simplified=;
" + "    100: << hundred[ >%%and>];
" + "    1000: << thousand[ >%%and>];
" + "    100,000>>: << thousand[>%%commas>];
" + "    1,000,000: << million[>%%commas>];
" + "    1,000,000,000,000: << billion[>%%commas>];
" + "    1,000,000,000,000,000: =#,##0=;
" + "%%and:
" + "    and =%default=;
" + "    100: =%default=;
" + "%%commas:
" + "    ' and =%default=;
" + "    100: , =%default=;
" + "    1000: , <%default< thousand, >%default>;
" + "    1,000,000: , =%default=;" + "%traditional:
" + "    -x: 〇| >>;
" + "    x.x: << 點 >>;
" + "    萬; 萬; 萬; 萬; 萬; 萬; 萬; 萬; 萬; 萬;
" + "    萬; 萬; 萬; 萬; 萬; 萬; 萬;
" + "        萬; 萬; 萬;
" + "    20: 萬[->>];
" + "    30: 萬[->>];
" + "    40: 萬[->>];
" + "    50: 萬[->>];
" + "    60: 萬[->>];
" + "    70: 萬[->>];
" + "    80: 萬[->>];
" + "    90: 萬[->>];
" + "    100: << 萬[ >>];
" + "    1000: << 萬[ >>];
" + "    1,000,000: << 萬[ >>];
" + "    1,000,000,000,000: << 萬[ >>];
" + "    1,000,000,000,000,000: =#,##0=;
" + "%time:
" + "    =0= sec.;
" + "    60: =%%min-sec=;
" + "    3600: =%%hr-min-sec=;
" + "%%min-sec:
" + "    0: *=00=;
" + "    60/60: <0<>>;
" + "%%hr-min-sec:
" + "    0: *=00=;
" + "    60/60: <00<>>;
" + "    3600/60: <#,##0<:>>>;
" + "%%post-process:ICU4N.Text.RbnfChinesePostProcessor
"
    var rbnf: RuleBasedNumberFormat = RuleBasedNumberFormat(ruleWithChinese, UCultureInfo("zh"))
    var ruleNames: String[] = rbnf.GetRuleSetNames
    try:
rbnf.Format(0.0, nil)
Errln("This was suppose to return an exception for a null format")
    except Exception:

      var i: int = 0
      while i < ruleNames.Length:
          try:
rbnf.Format(-123450.6789, ruleNames[i])
          except Exception:
Errln("RBNFChinesePostProcessor was not suppose to return an exception " + "when being formatted with parameters 0.0 and " + ruleNames[i])
++i
proc TestSetDecimalFormatSymbols*() =
    var rbnf: RuleBasedNumberFormat = RuleBasedNumberFormat(CultureInfo("en"), NumberPresentation.Ordinal)
    var dfs: DecimalFormatSymbols = DecimalFormatSymbols(CultureInfo("en"))
    var number: double = 1001
    var expected: String[] = @["1,001st", "1&001st"]
    var result: String = rbnf.Format(number)
    if !result.Equals(expected[0]):
Errln("Format Error - Got: " + result + " Expected: " + expected[0])
    dfs.GroupingSeparator = '&'
rbnf.SetDecimalFormatSymbols(dfs)
    result = rbnf.Format(number)
    if !result.Equals(expected[1]):
Errln("Format Error - Got: " + result + " Expected: " + expected[1])
type
  TextContextItem = ref object
    locale: String
    format: NumberPresentation
    context: DisplayContext
    value: double
    expectedResult: String

proc newTextContextItem(loc: String, fmt: NumberPresentation, ctxt: DisplayContext, val: double, expRes: String): TextContextItem =
  locale = loc
  format = fmt
  context = ctxt
  value = val
  expectedResult = expRes
proc TestContext*() =
    var items: TextContextItem[] = @[TextContextItem("sv", NumberPresentation.SpellOut, DisplayContext.CapitalizationForMiddleOfSentence, 123.45, "ett­hundra­tjugo­tre komma fyra fem"), TextContextItem("sv", NumberPresentation.SpellOut, DisplayContext.CapitalizationForBeginningOfSentence, 123.45, "Ett­hundra­tjugo­tre komma fyra fem"), TextContextItem("sv", NumberPresentation.SpellOut, DisplayContext.CapitalizationForUIListOrMenu, 123.45, "ett­hundra­tjugo­tre komma fyra fem"), TextContextItem("sv", NumberPresentation.SpellOut, DisplayContext.CapitalizationForStandalone, 123.45, "ett­hundra­tjugo­tre komma fyra fem"), TextContextItem("en", NumberPresentation.SpellOut, DisplayContext.CapitalizationForMiddleOfSentence, 123.45, "one hundred twenty-three point four five"), TextContextItem("en", NumberPresentation.SpellOut, DisplayContext.CapitalizationForBeginningOfSentence, 123.45, "One hundred twenty-three point four five"), TextContextItem("en", NumberPresentation.SpellOut, DisplayContext.CapitalizationForUIListOrMenu, 123.45, "One hundred twenty-three point four five"), TextContextItem("en", NumberPresentation.SpellOut, DisplayContext.CapitalizationForStandalone, 123.45, "One hundred twenty-three point four five")]
    for item in items:
        var locale: UCultureInfo = UCultureInfo(item.locale)
        var rbnf: RuleBasedNumberFormat = RuleBasedNumberFormat(locale, item.format)
rbnf.SetContext(item.context)
        var result: String = rbnf.Format(item.value, rbnf.DefaultRuleSetName)
        if !result.Equals(item.expectedResult):
Errln("Error for locale " + item.locale + ", context " + item.context + ", expected " + item.expectedResult + ", got " + result)
        var rbnfClone: RuleBasedNumberFormat = cast[RuleBasedNumberFormat](rbnf.Clone)
        if !rbnfClone.Equals(rbnf):
Errln("Error for locale " + item.locale + ", context " + item.context + ", rbnf.clone() != rbnf")
        else:
            result = rbnfClone.Format(item.value, rbnfClone.DefaultRuleSetName)
            if !result.Equals(item.expectedResult):
Errln("Error with clone for locale " + item.locale + ", context " + item.context + ", expected " + item.expectedResult + ", got " + result)
type
  TextCapiltaizationItem = ref object
    locale: string
    format: NumberPresentation
    capitalization: Capitalization
    value: double
    expectedResult: string

proc newTextCapiltaizationItem(loc: string, fmt: NumberPresentation, ctxt: Capitalization, val: double, expRes: string): TextCapiltaizationItem =
  locale = loc
  format = fmt
  capitalization = ctxt
  value = val
  expectedResult = expRes
proc TestContext_IcuNumber*() =
    var items: TextCapiltaizationItem[] = @[TextCapiltaizationItem("sv", NumberPresentation.SpellOut, Capitalization.ForMiddleOfSentence, 123.45, "ett­hundra­tjugo­tre komma fyra fem"), TextCapiltaizationItem("sv", NumberPresentation.SpellOut, Capitalization.ForBeginningOfSentence, 123.45, "Ett­hundra­tjugo­tre komma fyra fem"), TextCapiltaizationItem("sv", NumberPresentation.SpellOut, Capitalization.ForUIListOrMenu, 123.45, "ett­hundra­tjugo­tre komma fyra fem"), TextCapiltaizationItem("sv", NumberPresentation.SpellOut, Capitalization.ForStandalone, 123.45, "ett­hundra­tjugo­tre komma fyra fem"), TextCapiltaizationItem("en", NumberPresentation.SpellOut, Capitalization.ForMiddleOfSentence, 123.45, "one hundred twenty-three point four five"), TextCapiltaizationItem("en", NumberPresentation.SpellOut, Capitalization.ForBeginningOfSentence, 123.45, "One hundred twenty-three point four five"), TextCapiltaizationItem("en", NumberPresentation.SpellOut, Capitalization.ForUIListOrMenu, 123.45, "One hundred twenty-three point four five"), TextCapiltaizationItem("en", NumberPresentation.SpellOut, Capitalization.ForStandalone, 123.45, "One hundred twenty-three point four five")]
    for item in items:
        var locale: UCultureInfo = UCultureInfo(item.locale)
        var info = cast[UNumberFormatInfo](locale.NumberFormat.Clone)
        info.Capitalization = item.capitalization
        var rules = item.format.ToNumberFormatRules(info)
        var result: string = IcuNumber.FormatDoubleRuleBased(item.value, rules, nil, info)
        if !result.Equals(item.expectedResult):
Errln("Error for locale " + item.locale + ", capitalization " + item.capitalization + ", expected " + item.expectedResult + ", got " + result)
proc TestInfinityNaN*() =
    var enRules: String = "%default:" + "-x: minus >>;" + "Inf: infinite;" + "NaN: not a number;" + "0: =#,##0=;"
    var enFormatter: RbnfFormattterSettings = RbnfFormattterSettings(enRules, UCultureInfo("en"))
    var enTestData: string[][] = @[@["1", "1"], @["∞", "infinite"], @["-∞", "minus infinite"], @["NaN", "not a number"]]
doTest(enFormatter, enTestData, true)
    enRules = "%default:" + "-x: ->>;" + "0: =#,##0=;"
    enFormatter = RbnfFormattterSettings(enRules, UCultureInfo("en"))
    var enDefaultTestData: string[][] = @[@["1", "1"], @["∞", "∞"], @["-∞", "-∞"], @["NaN", "NaN"]]
doTest(enFormatter, enDefaultTestData, true)
proc TestVariableDecimalPoint*() =
    var enRules: String = "%spellout-numbering:" + "-x: minus >>;" + "x.x: << point >>;" + "x,x: << comma >>;" + "0.x: xpoint >>;" + "0,x: xcomma >>;" + "0: zero;" + "1: one;" + "2: two;" + "3: three;" + "4: four;" + "5: five;" + "6: six;" + "7: seven;" + "8: eight;" + "9: nine;"
    var enFormatter: RbnfFormattterSettings = RbnfFormattterSettings(enRules, UCultureInfo("en"))
    var enTestPointData: string[][] = @[@["1.1", "one point one"], @["1.23", "one point two three"], @["0.4", "xpoint four"]]
doTest(enFormatter, enTestPointData, true)
    var decimalFormatSymbols: DecimalFormatSymbols = DecimalFormatSymbols(UCultureInfo("en"))
    decimalFormatSymbols.DecimalSeparator = ','
enFormatter.formatter.SetDecimalFormatSymbols(decimalFormatSymbols)
    enFormatter.info = cast[UNumberFormatInfo](UCultureInfo("en").NumberFormat.Clone)
    enFormatter.info.NumberDecimalSeparator = ","
    var enTestCommaData: string[][] = @[@["1.1", "one comma one"], @["1.23", "one comma two three"], @["0.4", "xcomma four"]]
doTest(enFormatter, enTestCommaData, true)
proc TestRounding*() =
    var enFormatter: RuleBasedNumberFormat = RuleBasedNumberFormat(UCultureInfo("en"), NumberPresentation.SpellOut)
    var enTestFullData: string[][] = @[@["0", "zero"], @["0.4", "zero point four"], @["0.49", "zero point four nine"], @["0.5", "zero point five"], @["0.51", "zero point five one"], @["0.99", "zero point nine nine"], @["1", "one"], @["1.01", "one point zero one"], @["1.49", "one point four nine"], @["1.5", "one point five"], @["1.51", "one point five one"], @["450359962737049.6", "four hundred fifty trillion three hundred fifty-nine billion nine hundred sixty-two million seven hundred thirty-seven thousand forty-nine point six"], @["450359962737049.7", "four hundred fifty trillion three hundred fifty-nine billion nine hundred sixty-two million seven hundred thirty-seven thousand forty-nine point seven"]]
doTest(enFormatter, enTestFullData, false)
    enFormatter.MaximumFractionDigits = 0
    enFormatter.RoundingMode = BigDecimal.RoundHalfEven.ToRoundingMode
    var enTestIntegerData: string[][] = @[@["0", "zero"], @["0.4", "zero"], @["0.49", "zero"], @["0.5", "zero"], @["0.51", "one"], @["0.99", "one"], @["1", "one"], @["1.01", "one"], @["1.49", "one"], @["1.5", "two"], @["1.51", "two"]]
doTest(enFormatter, enTestIntegerData, false)
    enFormatter.MaximumFractionDigits = 1
    enFormatter.RoundingMode = BigDecimal.RoundHalfEven.ToRoundingMode
    var enTestTwoDigitsData: string[][] = @[@["0", "zero"], @["0.04", "zero"], @["0.049", "zero"], @["0.05", "zero"], @["0.051", "zero point one"], @["0.099", "zero point one"], @["10.11", "ten point one"], @["10.149", "ten point one"], @["10.15", "ten point two"], @["10.151", "ten point two"]]
doTest(enFormatter, enTestTwoDigitsData, false)
    enFormatter.MaximumFractionDigits = 3
    enFormatter.RoundingMode = BigDecimal.RoundDown.ToRoundingMode
    var enTestThreeDigitsDownData: string[][] = @[@["4.3", "four point three"]]
doTest(enFormatter, enTestThreeDigitsDownData, false)
proc TestLargeNumbers*() =
    var rbnf: RbnfFormattterSettings = RbnfFormattterSettings(UCultureInfo("en-US"), NumberPresentation.SpellOut)
    var enTestFullData: string[][] = @[@["-9007199254740991", "minus nine quadrillion seven trillion one hundred ninety-nine billion two hundred fifty-four million seven hundred forty thousand nine hundred ninety-one"], @["9007199254740991", "nine quadrillion seven trillion one hundred ninety-nine billion two hundred fifty-four million seven hundred forty thousand nine hundred ninety-one"], @["-9007199254740992", "minus nine quadrillion seven trillion one hundred ninety-nine billion two hundred fifty-four million seven hundred forty thousand nine hundred ninety-two"], @["9007199254740992", "nine quadrillion seven trillion one hundred ninety-nine billion two hundred fifty-four million seven hundred forty thousand nine hundred ninety-two"], @["9999999999999998", "nine quadrillion nine hundred ninety-nine trillion nine hundred ninety-nine billion nine hundred ninety-nine million nine hundred ninety-nine thousand nine hundred ninety-eight"], @["9999999999999999", "nine quadrillion nine hundred ninety-nine trillion nine hundred ninety-nine billion nine hundred ninety-nine million nine hundred ninety-nine thousand nine hundred ninety-nine"], @["999999999999999999", "nine hundred ninety-nine quadrillion nine hundred ninety-nine trillion nine hundred ninety-nine billion nine hundred ninety-nine million nine hundred ninety-nine thousand nine hundred ninety-nine"], @["1000000000000000000", "1,000,000,000,000,000,000"], @["-9223372036854775809", "-9,223,372,036,854,775,809"], @["-9223372036854775808", "-9,223,372,036,854,775,808"], @["-9223372036854775807", "minus 9,223,372,036,854,775,807"], @["-9223372036854775806", "minus 9,223,372,036,854,775,806"], @["9223372036854774111", "9,223,372,036,854,774,111"], @["9223372036854774999", "9,223,372,036,854,774,999"], @["9223372036854775000", "9,223,372,036,854,775,000"], @["9223372036854775806", "9,223,372,036,854,775,806"], @["9223372036854775807", "9,223,372,036,854,775,807"], @["9223372036854775808", "9,223,372,036,854,775,808"]]
doTest(rbnf, enTestFullData, false)
proc TestCompactDecimalFormatStyle*() =
    var numberPattern: string = "=###0.#####=;" + "1000: <###0.00< K;" + "1000000: <###0.00< M;" + "1000000000: <###0.00< B;" + "1000000000000: <###0.00< T;" + "1000000000000000: <###0.00< Q;"
    var rbnf: RuleBasedNumberFormat = RuleBasedNumberFormat(numberPattern, UCultureInfo("en_US"))
    var enTestFullData: string[][] = @[@["1000", "1.00 K"], @["1234", "1.23 K"], @["999994", "999.99 K"], @["999995", "1000.00 K"], @["1000000", "1.00 M"], @["1200000", "1.20 M"], @["1200000000", "1.20 B"], @["1200000000000", "1.20 T"], @["1200000000000000", "1.20 Q"], @["4503599627370495", "4.50 Q"], @["4503599627370496", "4.50 Q"], @["8990000000000000", "8.99 Q"], @["9008000000000000", "9.00 Q"], @["9456000000000000", "9.00 Q"], @["10000000000000000", "10.00 Q"], @["9223372036854775807", "9223.00 Q"], @["9223372036854775808", "9,223,372,036,854,775,808"]]
doTest(rbnf, enTestFullData, false)
proc assertEquals(expected: String, result: String) =
    if !expected.Equals(result, StringComparison.Ordinal):
Errln("Expected: " + expected + " Got: " + result)
proc TestRoundingUnrealNumbers*() =
    var rbnf: RuleBasedNumberFormat = RuleBasedNumberFormat(UCultureInfo("en-US"), NumberPresentation.SpellOut)
    rbnf.RoundingMode = BigDecimal.RoundHalfUp.ToRoundingMode
    rbnf.MaximumFractionDigits = 3
assertEquals("zero point one", rbnf.Format(0.1))
assertEquals("zero point zero zero one", rbnf.Format(0.0005))
assertEquals("infinity", rbnf.Format(double.PositiveInfinity))
assertEquals("not a number", rbnf.Format(double.NaN))
type
  RbnfFormattterSettings = ref object
    locale: UCultureInfo = nil
    format: NumberPresentation = nil
    description: string = nil
    formatter: RuleBasedNumberFormat
    createOption: CreateOption
    defaultRuleSet: string = nil
    info: UNumberFormatInfo = nil

proc DefaultRuleSet(): string =
    return defaultRuleSet
type
  CreateOption = enum
    DescriptionAndLocale
    LocaleAndFormat

proc newRbnfFormattterSettings(description: string, locale: UCultureInfo): RbnfFormattterSettings =
  self.description =   if description != nil:
description
  else:
      raise ArgumentNullException(nameof(description))
  self.locale =   if locale != nil:
locale
  else:
      raise ArgumentNullException(nameof(locale))
  self.formatter = RuleBasedNumberFormat(description, locale)
  self.createOption = CreateOption.DescriptionAndLocale
proc newRbnfFormattterSettings(description: string, locale: CultureInfo): RbnfFormattterSettings =
  self.description =   if description != nil:
description
  else:
      raise ArgumentNullException(nameof(description))
  self.locale =   if locale.ToUCultureInfo != nil:
locale.ToUCultureInfo
  else:
      raise ArgumentNullException(nameof(locale))
  self.formatter = RuleBasedNumberFormat(description, locale)
  self.createOption = CreateOption.DescriptionAndLocale
proc newRbnfFormattterSettings(locale: UCultureInfo, format: NumberPresentation): RbnfFormattterSettings =
  if !format.IsDefined:
    raise ArgumentOutOfRangeException(nameof(format))
  self.locale =   if locale != nil:
locale
  else:
      raise ArgumentNullException(nameof(locale))
  self.format = format
  self.formatter = RuleBasedNumberFormat(locale, format)
  self.createOption = CreateOption.LocaleAndFormat
proc newRbnfFormattterSettings(locale: CultureInfo, format: NumberPresentation): RbnfFormattterSettings =
  if !format.IsDefined:
    raise ArgumentOutOfRangeException(nameof(format))
  self.locale =   if locale.ToUCultureInfo != nil:
locale.ToUCultureInfo
  else:
      raise ArgumentNullException(nameof(locale))
  self.format = format
  self.formatter = RuleBasedNumberFormat(locale, format)
  self.createOption = CreateOption.LocaleAndFormat
proc SetDefaultRuleSet*(defaultRuleSet: string) =
    self.defaultRuleSet = defaultRuleSet
self.formatter.SetDefaultRuleSet(defaultRuleSet)
proc CreateNumberFormatRules*(): NumberFormatRules =
    case createOption
    of CreateOption.DescriptionAndLocale:
        return NumberFormatRules(description)
    of CreateOption.LocaleAndFormat:
        return NumberFormatRules.GetInstance(locale, format)
    else:
        raise InvalidOperationException("Not a valid option")
proc FormatWithIcuNumber*(num: long): string =
    var rules: NumberFormatRules = CreateNumberFormatRules
    var ruleSet: string = DefaultRuleSet
    var numberFormatInfo: UNumberFormatInfo =     if self.info != nil:
self.info
    else:
UNumberFormatInfo.GetInstance(locale)
    return IcuNumber.FormatInt64RuleBased(num, rules, ruleSet, numberFormatInfo)
proc FormatWithIcuNumber*(num: double): string =
    var rules: NumberFormatRules = CreateNumberFormatRules
    var ruleSet: string = DefaultRuleSet
    var numberFormatInfo: UNumberFormatInfo =     if self.info != nil:
self.info
    else:
UNumberFormatInfo.GetInstance(locale)
    return IcuNumber.FormatDoubleRuleBased(num, rules, ruleSet, numberFormatInfo)
proc FormatWithIcuNumber*(num: System.Numerics.BigInteger): string =
    var rules: NumberFormatRules = CreateNumberFormatRules
    var ruleSet: string = DefaultRuleSet
    var numberFormatInfo: UNumberFormatInfo =     if self.info != nil:
self.info
    else:
UNumberFormatInfo.GetInstance(locale)
    return IcuNumber.FormatBigIntegerRuleBased(num, rules, ruleSet, numberFormatInfo)
proc FormatWithIcuNumber*(num: J2N.Numerics.Number): string =
    var rules: NumberFormatRules = CreateNumberFormatRules
    var ruleSet: string = DefaultRuleSet
    var numberFormatInfo: UNumberFormatInfo =     if self.info != nil:
self.info
    else:
UNumberFormatInfo.GetInstance(locale)
    if num is J2N.Numerics.Int64:
        return IcuNumber.FormatInt64RuleBased(num.ToInt64, rules, ruleSet, numberFormatInfo)

    elif num:
        return IcuNumber.FormatBigIntegerRuleBased(System.Numerics.BigInteger.Parse(bi.ToString(CultureInfo.InvariantCulture), CultureInfo.InvariantCulture), rules, ruleSet, numberFormatInfo)
    else:
        return IcuNumber.FormatDoubleRuleBased(num.ToDouble, rules, ruleSet, numberFormatInfo)