# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationChineseTest = ref object


proc newCollationChineseTest(): CollationChineseTest =

proc TestPinYin*() =
    var seq: String[] = @["阿", "啊", "哎", "捱", "爱", "龘", "乜", "讪", "乂", "又"]
    var collator: RuleBasedCollator = nil
    try:
        collator = cast[RuleBasedCollator](Collator.GetInstance(CultureInfo("zh-Hans")))
    except Exception:
Warnln("ERROR: in creation of collator of zh__PINYIN locale")
        return
      var i: int = 0
      while i < seq.Length - 1:
CollationTest.DoTest(self, collator, seq[i], seq[i + 1], -1)
++i