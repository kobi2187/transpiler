# "Namespace: ICU4N.Text"
type
  UnicodeSetPartialTest = ref object
    Mai_Han_Akat: int = 3633
    Letter_A: int = 65
    Letter_D: int = 68
    Letter_E: int = 69
    Letter_F: int = 70
    Letter_G: int = 71
    Letter_M: int = 77
    thaiWordSet: UnicodeSet
    thaiWordSuperset: UnicodeSet
    thaiWordSubset: UnicodeSet
    thaiWordSet2: UnicodeSet
    burmeseWordSet: UnicodeSet
    emptySet: UnicodeSet
    aThruFSet: UnicodeSet
    aThruFSubset: UnicodeSet
    aThruFSuperset: UnicodeSet
    dThruMSet: UnicodeSet

proc TestInitialize*() =
procCall.TestInitialize
    thaiWordSet = UnicodeSet("[[:Thai:]&[:LineBreak=SA:]]").Compact
    thaiWordSet2 = UnicodeSet("[[:Thai:]&[:LineBreak=SA:]]").Compact
    thaiWordSubset = UnicodeSet("[[:Thai:]&[:LineBreak=SA:]]").Remove(Mai_Han_Akat).Compact
    thaiWordSuperset = UnicodeSet("[[:Thai:]&[:LineBreak=SA:]]").Add(Letter_A).Compact
    burmeseWordSet = UnicodeSet("[[:Mymr:]&[:LineBreak=SA:]]").Compact
    emptySet = UnicodeSet
    aThruFSet = UnicodeSet(Letter_A, Letter_F).Compact
    aThruFSubset = UnicodeSet(Letter_A, Letter_E).Compact
    aThruFSuperset = UnicodeSet(Letter_A, Letter_G).Compact
    dThruMSet = UnicodeSet(Letter_D, Letter_M).Compact
proc TestSetEquals_UnicodeSet*() =
    var methodName: string = nameof(UnicodeSet.SetEquals)
assertFalse($methodName & ": The word sets are equal", thaiWordSet.SetEquals(emptySet))
assertFalse($methodName & ": The word sets are equal", emptySet.SetEquals(thaiWordSet))
assertTrue($methodName & ": The word sets are not equal", thaiWordSet.SetEquals(thaiWordSet2))
assertTrue($methodName & ": The word sets are not equal", thaiWordSet2.SetEquals(thaiWordSet))
assertFalse($methodName & ": The word sets are equal", thaiWordSet.SetEquals(burmeseWordSet))
proc TestIsSupersetOf_UnicodeSet*() =
      var setOperation: string = "superset"
      var methodName: string = nameof(UnicodeSet.IsSupersetOf)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(emptySet), thaiWordSet.IsSupersetOf(emptySet))
assertTrue($methodName & ": " & $nameof(emptySet) & " is not a " & $setOperation & " of " & $nameof(emptySet), emptySet.IsSupersetOf(emptySet))
assertFalse($methodName & ": " & $nameof(emptySet) & " is a " & $setOperation & " of " & $nameof(thaiWordSet), emptySet.IsSupersetOf(thaiWordSet))
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(thaiWordSubset), thaiWordSet.IsSupersetOf(thaiWordSubset))
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(thaiWordSet2), thaiWordSet.IsSupersetOf(thaiWordSet2))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(burmeseWordSet), thaiWordSet.IsSupersetOf(burmeseWordSet))
proc TestIsProperSupersetOf_UnicodeSet*() =
      var setOperation: string = "proper superset"
      var methodName: string = nameof(UnicodeSet.IsProperSupersetOf)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(emptySet), thaiWordSet.IsProperSupersetOf(emptySet))
assertFalse($methodName & ": " & $nameof(emptySet) & " is a " & $setOperation & " of " & $nameof(emptySet), emptySet.IsProperSupersetOf(emptySet))
assertFalse($methodName & ": " & $nameof(emptySet) & " is a " & $setOperation & " of " & $nameof(thaiWordSet), emptySet.IsProperSupersetOf(thaiWordSet))
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(thaiWordSubset), thaiWordSet.IsProperSupersetOf(thaiWordSubset))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(thaiWordSet2), thaiWordSet.IsProperSupersetOf(thaiWordSet2))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(burmeseWordSet), thaiWordSet.IsProperSupersetOf(burmeseWordSet))
proc TestIsSubsetOf_UnicodeSet*() =
      var setOperation: string = "subset"
      var methodName: string = nameof(UnicodeSet.IsSubsetOf)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(emptySet), thaiWordSet.IsSubsetOf(emptySet))
assertTrue($methodName & ": " & $nameof(emptySet) & " is not a " & $setOperation & " of " & $nameof(emptySet), emptySet.IsSubsetOf(emptySet))
assertTrue($methodName & ": " & $nameof(emptySet) & " is not a " & $setOperation & " of " & $nameof(thaiWordSet), emptySet.IsSubsetOf(thaiWordSet))
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(thaiWordSuperset), thaiWordSet.IsSubsetOf(thaiWordSuperset))
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(thaiWordSet2), thaiWordSet.IsSubsetOf(thaiWordSet2))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(burmeseWordSet), thaiWordSet.IsSubsetOf(burmeseWordSet))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(thaiWordSubset), thaiWordSet.IsSubsetOf(thaiWordSubset))
proc TestIsProperSubsetOf_UnicodeSet*() =
      var setOperation: string = "proper subset"
      var methodName: string = nameof(UnicodeSet.IsProperSubsetOf)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(emptySet), thaiWordSet.IsProperSubsetOf(emptySet))
assertFalse($methodName & ": " & $nameof(emptySet) & " is a " & $setOperation & " of " & $nameof(emptySet), emptySet.IsProperSubsetOf(emptySet))
assertTrue($methodName & ": " & $nameof(emptySet) & " is not a " & $setOperation & " of " & $nameof(thaiWordSet), emptySet.IsProperSubsetOf(thaiWordSet))
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(thaiWordSuperset), thaiWordSet.IsProperSubsetOf(thaiWordSuperset))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(thaiWordSubset), thaiWordSet.IsProperSubsetOf(thaiWordSubset))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(thaiWordSet2), thaiWordSet.IsProperSubsetOf(thaiWordSet2))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(burmeseWordSet), thaiWordSet.IsProperSubsetOf(burmeseWordSet))
proc TestOverlaps_UnicodeSet*() =
      var setOperation: string = "overlap"
      var methodName: string = nameof(UnicodeSet.Overlaps)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " does " & $setOperation & " with " & $nameof(emptySet), thaiWordSet.Overlaps(emptySet))
assertFalse($methodName & ": " & $nameof(emptySet) & " does " & $setOperation & " with " & $nameof(emptySet), emptySet.Overlaps(emptySet))
assertFalse($methodName & ": " & $nameof(emptySet) & " does " & $setOperation & " with " & $nameof(thaiWordSet), emptySet.Overlaps(thaiWordSet))
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " does not " & $setOperation & " with " & $nameof(thaiWordSuperset), thaiWordSet.Overlaps(thaiWordSuperset))
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " does not " & $setOperation & " with " & $nameof(thaiWordSubset), thaiWordSet.Overlaps(thaiWordSubset))
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " does not " & $setOperation & " with " & $nameof(thaiWordSet2), thaiWordSet.Overlaps(thaiWordSet2))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " does " & $setOperation & " with " & $nameof(burmeseWordSet), thaiWordSet.Overlaps(burmeseWordSet))
proc TestSymmetricExceptWith_UnicodeSet*() =
      var setOperation: string = "symmetric except with (xOr)"
      var methodName: string = nameof(UnicodeSet.SymmetricExceptWith)
assertEquals($methodName & ": " & $nameof(aThruFSet) & " " & $setOperation & " " & $nameof(emptySet) & " is wrong", aThruFSet, aThruFSet.SymmetricExceptWith(emptySet))
assertEquals($methodName & ": " & $nameof(emptySet) & " " & $setOperation & " " & $nameof(aThruFSet) & " is wrong", aThruFSet, emptySet.SymmetricExceptWith(aThruFSet))
assertEquals($methodName & ": " & $nameof(aThruFSet) & " " & $setOperation & " " & $nameof(dThruMSet) & " is wrong", UnicodeSet("[A-CG-M]"), aThruFSet.SymmetricExceptWith(dThruMSet))
assertEquals($methodName & ": " & $nameof(thaiWordSet) & " " & $setOperation & " " & $nameof(thaiWordSuperset) & " is wrong", UnicodeSet("[A]"), thaiWordSet.SymmetricExceptWith(thaiWordSuperset))