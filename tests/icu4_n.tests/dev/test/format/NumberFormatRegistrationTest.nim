# "Namespace: ICU4N.Dev.Test.Format"
type
  NumberFormatRegistrationTest = ref object
    SRC_LOC: UCultureInfo = UCultureInfo("fr-FR")
    SWAP_LOC: UCultureInfo = UCultureInfo("en-US")

type
  TestFactory = ref object
    currencyStyle: NumberFormat

proc newTestFactory(): TestFactory =
newTestFactory(SRC_LOC, SWAP_LOC)
proc newTestFactory(srcLoc: UCultureInfo, swapLoc: UCultureInfo): TestFactory =
newSimpleNumberFormatFactory(srcLoc)
  currencyStyle = NumberFormat.GetIntegerInstance(swapLoc)
proc CreateFormat*(loc: UCultureInfo, formatType: int): NumberFormat =
    if formatType == FormatCurrency:
        return currencyStyle
    return nil
proc TestRegistration*() =
      try:
NumberFormat.Unregister(nil)
Errln("did not throw exception on null unregister")
      except Exception:
Logln("PASS: null unregister failed as expected")
      try:
NumberFormat.RegisterFactory(nil)
Errln("did not throw exception on null register")
      except Exception:
Logln("PASS: null register failed as expected")
      try:
          if NumberFormat.Unregister(""):
Errln("unregister of empty string key succeeded")
      except Exception:

    var fu_FU: UCultureInfo = UCultureInfo("fu_FU")
    var f0: NumberFormat = NumberFormat.GetIntegerInstance(SWAP_LOC)
    var f1: NumberFormat = NumberFormat.GetIntegerInstance(SRC_LOC)
    var f2: NumberFormat = NumberFormat.GetCurrencyInstance(SRC_LOC)
    var key: Object = NumberFormat.RegisterFactory(TestFactory)
    var key2: Object = NumberFormat.RegisterFactory(TestFactory(fu_FU, UCultureInfo("de-DE")))
    if !NumberFormat.GetUCultures(UCultureTypes.AllCultures).Contains(fu_FU):
Errln("did not list fu_FU")
    var f3: NumberFormat = NumberFormat.GetCurrencyInstance(SRC_LOC)
    var f4: NumberFormat = NumberFormat.GetIntegerInstance(SRC_LOC)
NumberFormat.Unregister(key)
    var f5: NumberFormat = NumberFormat.GetCurrencyInstance(SRC_LOC)
NumberFormat.Unregister(key2)
    var n: float = 1234.567
Logln("f0 swap int: " + f0.Format(n))
Logln("f1 src int: " + f1.Format(n))
Logln("f2 src cur: " + f2.Format(n))
Logln("f3 reg cur: " + f3.Format(n))
Logln("f4 reg int: " + f4.Format(n))
Logln("f5 unreg cur: " + f5.Format(n))
    if !f3.Format(n).Equals(f0.Format(n), StringComparison.Ordinal):
Errln("registered service did not match")
    if !f4.Format(n).Equals(f1.Format(n), StringComparison.Ordinal):
Errln("registered service did not inherit")
    if !f5.Format(n).Equals(f2.Format(n), StringComparison.Ordinal):
Errln("unregistered service did not match original")
    var f6: NumberFormat = NumberFormat.GetNumberInstance(fu_FU)
    if f6 == nil:
Errln("getNumberInstance(fu_FU) returned null")