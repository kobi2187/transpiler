# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationCreationMethodTest = ref object


proc TestRuleVsLocaleCreationMonkey*() =
      var x: int
      var y: int
      var z: int
    var r: Random = CreateRandom
    var randString1: String
    var key1: CollationKey
    var key2: CollationKey
    var locales: CultureInfo[] = Collator.GetCultures(UCultureTypes.AllCultures)
    var localeCollator: RuleBasedCollator
    var ruleCollator: RuleBasedCollator
      z = 0
      while z < 60:
          x = r.Next(locales.Length)
          var locale: CultureInfo = locales[x]
          try:
              localeCollator = cast[RuleBasedCollator](Collator.GetInstance(locale))
Logln("Rules for " + locale + " are: " + localeCollator.GetRules)
              ruleCollator = RuleBasedCollator(localeCollator.GetRules)
          except Exception:
Warnln("ERROR: in creation of collator of locale " + locale.DisplayName + ": " + e)
              return
          var n: int = 3
            y = 0
            while y < n:
                randString1 = GenerateNewString(r)
                key1 = localeCollator.GetCollationKey(randString1)
                key2 = ruleCollator.GetCollationKey(randString1)
Report(locale.DisplayName, randString1, key1, key2)
++y
++z
proc GenerateNewString(r: Random): String =
    var maxCodePoints: int = 40
    var c: byte[] = seq[byte]
    var x: int
    var z: int
    var s: String = ""
      x = 0
      while x < c.Length / 2:
          z = r.Next(32767)
          c[x + 1] = cast[byte](z)
          c[x] = cast[byte](z >>> 4)
          x = x + 2
    try:
        s = Encoding.GetEncoding("UTF-16BE").GetString(c)
    except Exception:
Warnln("Error creating random strings")
    return s
proc Report(localeName: String, string1: String, k1: CollationKey, k2: CollationKey) =
    if !k1.Equals(k2):
        var msg: StringBuilder = StringBuilder
msg.Append("With ").Append(localeName).Append(" collator
 and input string: ").Append(string1).Append('
')
msg.Append(" failed to produce identical keys on both collators
")
msg.Append("  localeCollator key: ").Append(CollationTest.Prettify(k1)).Append('
')
msg.Append("  ruleCollator   key: ").Append(CollationTest.Prettify(k2)).Append('
')
Errln(msg.ToString)