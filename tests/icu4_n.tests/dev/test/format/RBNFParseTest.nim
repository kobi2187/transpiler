# "Namespace: ICU4N.Dev.Test.Format"
type
  RBNFParseTest = ref object


proc TestParse*() =
    var okrules: string[] = @["random text", "%foo:bar", "%foo: bar", "0:", "0::", "%%foo:;", "-", "-1", "-:", ".", ".1", "[", "]", "[]", "[foo]", "[[]", "[]]", "[[]]", "[][]", "<", ">", "=", "==", "===", "=foo="]
    var exceptrules: string[] = @["", ";", ";;", ":", "::", ":1", ":;", ":;:;", "<<", "<<<", "10:;9:;", ">>", ">>>", "10:", "11: << x", "%%foo: 0 foo; 10: =%%bar=; %%bar: 0: bar; 10: =%%foo=;"]
    var allrules: string[][] = @[okrules, exceptrules]
      var j: int = 0
      while j < allrules.Length:
          var tests: string[] = allrules[j]
          var except: bool = tests == exceptrules
            var i: int = 0
            while i < tests.Length:
Logln("----------")
Logln("rules: '" + tests[i] + "'")
                var caughtException: bool = false
                try:
                    var fmt: RuleBasedNumberFormat = RuleBasedNumberFormat(tests[i], CultureInfo("en-US"))
Logln("1.23: " + fmt.Format(20))
Logln("-123: " + fmt.Format(-123))
Logln(".123: " + fmt.Format(0.123))
Logln(" 123: " + fmt.Format(123))
                except Exception:
                    if !except:
Errln("Unexpected exception: " + e.Message)
                    else:
                        caughtException = true
                if except && !caughtException:
Errln("expected exception but didn't get one!")
++i
++j
proc parseFormat(rbnf: RuleBasedNumberFormat, s: string, target: string) =
    try:
        var n: Number = rbnf.Parse(s)
        var t: string = rbnf.Format(n)
assertEquals(rbnf.ActualCulture + ": " + s + " : " + n, target, t)
    except FormatException:
fail("exception:" + e)
proc parseList(rbnf_en: RuleBasedNumberFormat, rbnf_fr: RuleBasedNumberFormat, lists: seq[string]) =
      var i: int = 0
      while i < lists.Length:
          var list: string[] = lists[i]
          var s: string = list[0]
          var target_en: string = list[1]
          var target_fr: string = list[2]
parseFormat(rbnf_en, s, target_en)
parseFormat(rbnf_fr, s, target_fr)
++i
proc TestLenientParse*() =
      var rbnf_en: RuleBasedNumberFormat
      var rbnf_fr: RuleBasedNumberFormat
    rbnf_en = RuleBasedNumberFormat(CultureInfo("en"), NumberPresentation.SpellOut)
    rbnf_en.LenientParseEnabled = true
    rbnf_fr = RuleBasedNumberFormat(CultureInfo("fr"), NumberPresentation.SpellOut)
    rbnf_fr.LenientParseEnabled = true
    var n: Number = rbnf_en.Parse("1,2 million")
Logln(n.ToString)
    var lists: string[][] = @[@["1,2", "twelve", "un virgule deux"], @["1,2 million", "twelve million", "un virgule deux"], @["1,2 millions", "twelve million", "un million deux cent mille"], @["1.2", "one point two", "douze"], @["1.2 million", "one million two hundred thousand", "douze"], @["1.2 millions", "one million two hundred thousand", "douze millions"]]
    procCall.CurrentCulture = CultureInfo("fr-FR")
Logln("Default locale:" + CultureInfo.CurrentCulture)
Logln("rbnf_en:" + rbnf_en.DefaultRuleSetName)
Logln("rbnf_fr:" + rbnf_en.DefaultRuleSetName)
parseList(rbnf_en, rbnf_fr, lists)
    procCall.CurrentCulture = CultureInfo("en-US")
Logln("Default locale:" + CultureInfo.CurrentCulture)
Logln("rbnf_en:" + rbnf_en.DefaultRuleSetName)
Logln("rbnf_fr:" + rbnf_en.DefaultRuleSetName)
parseList(rbnf_en, rbnf_fr, lists)