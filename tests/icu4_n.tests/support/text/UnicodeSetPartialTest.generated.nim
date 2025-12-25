# "Namespace: ICU4N.Text"
type
  UnicodeSetPartialTest = ref object


proc TestSetEquals_String*() =
    var empty = ""
    var equiv1 = "ABCDEF"
    var equiv2 = "BDEFAC"
    var nonEquiv1 = "CDEAZF"
    var nonEquiv2 = "ABCDEFG"
    var methodName: string = nameof(UnicodeSet.SetEquals)
assertFalse($methodName & ": The word sets are equal", aThruFSet.SetEquals(empty))
assertTrue($methodName & ": The word sets are not equal", emptySet.SetEquals(empty))
assertTrue($methodName & ": The word sets are not equal", aThruFSet.SetEquals(equiv1))
assertTrue($methodName & ": The word sets are not equal", aThruFSet.SetEquals(equiv2))
assertFalse($methodName & ": The word sets are equal", aThruFSet.SetEquals(nonEquiv1))
assertFalse($methodName & ": The word sets are equal", aThruFSet.SetEquals(nonEquiv2))
proc TestSetEquals_ReadOnlySpan*() =
    var empty = "".AsSpan
    var equiv1 = "ABCDEF".AsSpan
    var equiv2 = "BDEFAC".AsSpan
    var nonEquiv1 = "CDEAZF".AsSpan
    var nonEquiv2 = "ABCDEFG".AsSpan
    var methodName: string = nameof(UnicodeSet.SetEquals)
assertFalse($methodName & ": The word sets are equal", aThruFSet.SetEquals(empty))
assertTrue($methodName & ": The word sets are not equal", emptySet.SetEquals(empty))
assertTrue($methodName & ": The word sets are not equal", aThruFSet.SetEquals(equiv1))
assertTrue($methodName & ": The word sets are not equal", aThruFSet.SetEquals(equiv2))
assertFalse($methodName & ": The word sets are equal", aThruFSet.SetEquals(nonEquiv1))
assertFalse($methodName & ": The word sets are equal", aThruFSet.SetEquals(nonEquiv2))
proc TestSetEquals_CharArray*() =
    var empty = "".ToCharArray
    var equiv1 = "ABCDEF".ToCharArray
    var equiv2 = "BDEFAC".ToCharArray
    var nonEquiv1 = "CDEAZF".ToCharArray
    var nonEquiv2 = "ABCDEFG".ToCharArray
    var methodName: string = nameof(UnicodeSet.SetEquals)
assertFalse($methodName & ": The word sets are equal", aThruFSet.SetEquals(empty))
assertTrue($methodName & ": The word sets are not equal", emptySet.SetEquals(empty))
assertTrue($methodName & ": The word sets are not equal", aThruFSet.SetEquals(equiv1))
assertTrue($methodName & ": The word sets are not equal", aThruFSet.SetEquals(equiv2))
assertFalse($methodName & ": The word sets are equal", aThruFSet.SetEquals(nonEquiv1))
assertFalse($methodName & ": The word sets are equal", aThruFSet.SetEquals(nonEquiv2))
proc TestSetEquals_StringCollection*() =
    var equivSet = List<string>
    var methodName: string = nameof(UnicodeSet.SetEquals)
assertFalse($methodName & ": The word sets are equal", thaiWordSet.SetEquals(equivSet))
thaiWordSet.CopyTo(equivSet)
assertTrue($methodName & ": The word sets are not equal", thaiWordSet.SetEquals(equivSet))
equivSet.RemoveAt(0)
assertFalse($methodName & ": The word sets are equal", thaiWordSet.SetEquals(equivSet))
proc TestSetEquals_CharArrayCollection*() =
    var equivSet = List<char[]>
    var methodName: string = nameof(UnicodeSet.SetEquals)
assertFalse($methodName & ": The word sets are equal", thaiWordSet.SetEquals(equivSet))
thaiWordSet.CopyTo(equivSet)
assertTrue($methodName & ": The word sets are not equal", thaiWordSet.SetEquals(equivSet))
equivSet.RemoveAt(0)
assertFalse($methodName & ": The word sets are equal", thaiWordSet.SetEquals(equivSet))
proc TestIsSupersetOf_String*() =
    var equivEmptySet = ""
    var equivSet = "ABCDEF"
    var equivSet2 = "BDEFAC"
    var equivSubset = "CDEAF"
    var equivSuperset = "ABCDEFG"
      var setOperation: string = "superset"
      var methodName: string = nameof(UnicodeSet.IsSupersetOf)
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), aThruFSet.IsSupersetOf(equivEmptySet))
assertTrue($methodName & ": " & $nameof(emptySet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsSupersetOf(equivEmptySet))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSet), aThruFSet.IsSupersetOf(equivSet))
assertTrue($methodName & ": " & $nameof(aThruFSuperset) & " is not a " & $setOperation & " of " & $nameof(equivSet2), aThruFSuperset.IsSupersetOf(equivSet2))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSubset), aThruFSet.IsSupersetOf(equivSubset))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSet.IsSupersetOf(equivSuperset))
assertTrue($methodName & ": " & $nameof(aThruFSuperset) & " is not a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSuperset.IsSupersetOf(equivSuperset))
proc TestIsSupersetOf_ReadOnlySpan*() =
    var equivEmptySet = "".AsSpan
    var equivSet = "ABCDEF".AsSpan
    var equivSet2 = "BDEFAC".AsSpan
    var equivSubset = "CDEAF".AsSpan
    var equivSuperset = "ABCDEFG".AsSpan
      var setOperation: string = "superset"
      var methodName: string = nameof(UnicodeSet.IsSupersetOf)
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), aThruFSet.IsSupersetOf(equivEmptySet))
assertTrue($methodName & ": " & $nameof(emptySet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsSupersetOf(equivEmptySet))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSet), aThruFSet.IsSupersetOf(equivSet))
assertTrue($methodName & ": " & $nameof(aThruFSuperset) & " is not a " & $setOperation & " of " & $nameof(equivSet2), aThruFSuperset.IsSupersetOf(equivSet2))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSubset), aThruFSet.IsSupersetOf(equivSubset))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSet.IsSupersetOf(equivSuperset))
assertTrue($methodName & ": " & $nameof(aThruFSuperset) & " is not a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSuperset.IsSupersetOf(equivSuperset))
proc TestIsSupersetOf_CharArray*() =
    var equivEmptySet = "".ToCharArray
    var equivSet = "ABCDEF".ToCharArray
    var equivSet2 = "BDEFAC".ToCharArray
    var equivSubset = "CDEAF".ToCharArray
    var equivSuperset = "ABCDEFG".ToCharArray
      var setOperation: string = "superset"
      var methodName: string = nameof(UnicodeSet.IsSupersetOf)
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), aThruFSet.IsSupersetOf(equivEmptySet))
assertTrue($methodName & ": " & $nameof(emptySet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsSupersetOf(equivEmptySet))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSet), aThruFSet.IsSupersetOf(equivSet))
assertTrue($methodName & ": " & $nameof(aThruFSuperset) & " is not a " & $setOperation & " of " & $nameof(equivSet2), aThruFSuperset.IsSupersetOf(equivSet2))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSubset), aThruFSet.IsSupersetOf(equivSubset))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSet.IsSupersetOf(equivSuperset))
assertTrue($methodName & ": " & $nameof(aThruFSuperset) & " is not a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSuperset.IsSupersetOf(equivSuperset))
proc TestIsSupersetOf_StringCollection*() =
    var equivEmptySet = List<string>
    var equivSet = List<string>
    var equivSubset = List<string>
    var equivSuperset = List<string>
      var setOperation: string = "superset"
      var methodName: string = nameof(UnicodeSet.IsSupersetOf)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), thaiWordSet.IsSupersetOf(equivEmptySet))
assertTrue($methodName & ": " & $nameof(emptySet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsSupersetOf(equivEmptySet))
thaiWordSet.CopyTo(equivSet)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(equivSet), thaiWordSet.IsSupersetOf(equivSet))
thaiWordSubset.CopyTo(equivSubset)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(equivSubset), thaiWordSet.IsSupersetOf(equivSubset))
thaiWordSuperset.CopyTo(equivSuperset)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivSuperset), thaiWordSet.IsSupersetOf(equivSuperset))
proc TestIsSupersetOf_CharArrayCollection*() =
    var equivEmptySet = List<char[]>
    var equivSet = List<char[]>
    var equivSubset = List<char[]>
    var equivSuperset = List<char[]>
      var setOperation: string = "superset"
      var methodName: string = nameof(UnicodeSet.IsSupersetOf)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), thaiWordSet.IsSupersetOf(equivEmptySet))
assertTrue($methodName & ": " & $nameof(emptySet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsSupersetOf(equivEmptySet))
thaiWordSet.CopyTo(equivSet)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(equivSet), thaiWordSet.IsSupersetOf(equivSet))
thaiWordSubset.CopyTo(equivSubset)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(equivSubset), thaiWordSet.IsSupersetOf(equivSubset))
thaiWordSuperset.CopyTo(equivSuperset)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivSuperset), thaiWordSet.IsSupersetOf(equivSuperset))
proc TestIsProperSupersetOf_String*() =
    var equivEmptySet = ""
    var equivSet = "ABCDEF"
    var equivSet2 = "BDEFAC"
    var equivSubset = "CDEAF"
    var equivSuperset = "ABCDEFG"
      var setOperation: string = "proper superset"
      var methodName: string = nameof(UnicodeSet.IsProperSupersetOf)
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), aThruFSet.IsProperSupersetOf(equivEmptySet))
assertFalse($methodName & ": " & $nameof(emptySet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsProperSupersetOf(equivEmptySet))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSet), aThruFSet.IsProperSupersetOf(equivSet))
assertTrue($methodName & ": " & $nameof(aThruFSuperset) & " is not a " & $setOperation & " of " & $nameof(equivSet2), aThruFSuperset.IsProperSupersetOf(equivSet2))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSubset), aThruFSet.IsProperSupersetOf(equivSubset))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSet.IsProperSupersetOf(equivSuperset))
assertFalse($methodName & ": " & $nameof(aThruFSuperset) & " is a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSuperset.IsProperSupersetOf(equivSuperset))
proc TestIsProperSupersetOf_ReadOnlySpan*() =
    var equivEmptySet = "".AsSpan
    var equivSet = "ABCDEF".AsSpan
    var equivSet2 = "BDEFAC".AsSpan
    var equivSubset = "CDEAF".AsSpan
    var equivSuperset = "ABCDEFG".AsSpan
      var setOperation: string = "proper superset"
      var methodName: string = nameof(UnicodeSet.IsProperSupersetOf)
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), aThruFSet.IsProperSupersetOf(equivEmptySet))
assertFalse($methodName & ": " & $nameof(emptySet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsProperSupersetOf(equivEmptySet))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSet), aThruFSet.IsProperSupersetOf(equivSet))
assertTrue($methodName & ": " & $nameof(aThruFSuperset) & " is not a " & $setOperation & " of " & $nameof(equivSet2), aThruFSuperset.IsProperSupersetOf(equivSet2))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSubset), aThruFSet.IsProperSupersetOf(equivSubset))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSet.IsProperSupersetOf(equivSuperset))
assertFalse($methodName & ": " & $nameof(aThruFSuperset) & " is a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSuperset.IsProperSupersetOf(equivSuperset))
proc TestIsProperSupersetOf_CharArray*() =
    var equivEmptySet = "".ToCharArray
    var equivSet = "ABCDEF".ToCharArray
    var equivSet2 = "BDEFAC".ToCharArray
    var equivSubset = "CDEAF".ToCharArray
    var equivSuperset = "ABCDEFG".ToCharArray
      var setOperation: string = "proper superset"
      var methodName: string = nameof(UnicodeSet.IsProperSupersetOf)
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), aThruFSet.IsProperSupersetOf(equivEmptySet))
assertFalse($methodName & ": " & $nameof(emptySet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsProperSupersetOf(equivEmptySet))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSet), aThruFSet.IsProperSupersetOf(equivSet))
assertTrue($methodName & ": " & $nameof(aThruFSuperset) & " is not a " & $setOperation & " of " & $nameof(equivSet2), aThruFSuperset.IsProperSupersetOf(equivSet2))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSubset), aThruFSet.IsProperSupersetOf(equivSubset))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSet.IsProperSupersetOf(equivSuperset))
assertFalse($methodName & ": " & $nameof(aThruFSuperset) & " is a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSuperset.IsProperSupersetOf(equivSuperset))
proc TestIsProperSupersetOf_StringCollection*() =
    var equivEmptySet = List<string>
    var equivSet = List<string>
    var equivSubset = List<string>
      var setOperation: string = "proper superset"
      var methodName: string = nameof(UnicodeSet.IsProperSupersetOf)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), thaiWordSet.IsProperSupersetOf(equivEmptySet))
assertFalse($methodName & ": " & $nameof(emptySet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsProperSupersetOf(equivEmptySet))
thaiWordSet.CopyTo(equivSet)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivSet), thaiWordSet.IsProperSupersetOf(equivSet))
thaiWordSubset.CopyTo(equivSubset)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(equivSubset), thaiWordSet.IsProperSupersetOf(equivSubset))
proc TestIsProperSupersetOf_CharArrayCollection*() =
    var equivEmptySet = List<char[]>
    var equivSet = List<char[]>
    var equivSubset = List<char[]>
      var setOperation: string = "proper superset"
      var methodName: string = nameof(UnicodeSet.IsProperSupersetOf)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), thaiWordSet.IsProperSupersetOf(equivEmptySet))
assertFalse($methodName & ": " & $nameof(emptySet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsProperSupersetOf(equivEmptySet))
thaiWordSet.CopyTo(equivSet)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivSet), thaiWordSet.IsProperSupersetOf(equivSet))
thaiWordSubset.CopyTo(equivSubset)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(equivSubset), thaiWordSet.IsProperSupersetOf(equivSubset))
proc TestIsSubsetOf_String*() =
    var equivEmptySet = ""
    var equivSet = "ABCDEF"
    var equivSet2 = "BDEFAC"
    var equivSubset = "CDEAF"
    var equivSuperset = "ABCDEFG"
      var setOperation: string = "subset"
      var methodName: string = nameof(UnicodeSet.IsSubsetOf)
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), aThruFSet.IsSubsetOf(equivEmptySet))
assertTrue($methodName & ": " & $nameof(emptySet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsSubsetOf(equivEmptySet))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSet), aThruFSet.IsSubsetOf(equivSet))
assertFalse($methodName & ": " & $nameof(aThruFSuperset) & " is a " & $setOperation & " of " & $nameof(equivSet2), aThruFSuperset.IsSubsetOf(equivSet2))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSubset), aThruFSet.IsSubsetOf(equivSubset))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSet.IsSubsetOf(equivSuperset))
assertTrue($methodName & ": " & $nameof(aThruFSuperset) & " is not a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSuperset.IsSubsetOf(equivSuperset))
proc TestIsSubsetOf_ReadOnlySpan*() =
    var equivEmptySet = "".AsSpan
    var equivSet = "ABCDEF".AsSpan
    var equivSet2 = "BDEFAC".AsSpan
    var equivSubset = "CDEAF".AsSpan
    var equivSuperset = "ABCDEFG".AsSpan
      var setOperation: string = "subset"
      var methodName: string = nameof(UnicodeSet.IsSubsetOf)
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), aThruFSet.IsSubsetOf(equivEmptySet))
assertTrue($methodName & ": " & $nameof(emptySet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsSubsetOf(equivEmptySet))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSet), aThruFSet.IsSubsetOf(equivSet))
assertFalse($methodName & ": " & $nameof(aThruFSuperset) & " is a " & $setOperation & " of " & $nameof(equivSet2), aThruFSuperset.IsSubsetOf(equivSet2))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSubset), aThruFSet.IsSubsetOf(equivSubset))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSet.IsSubsetOf(equivSuperset))
assertTrue($methodName & ": " & $nameof(aThruFSuperset) & " is not a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSuperset.IsSubsetOf(equivSuperset))
proc TestIsSubsetOf_CharArray*() =
    var equivEmptySet = "".ToCharArray
    var equivSet = "ABCDEF".ToCharArray
    var equivSet2 = "BDEFAC".ToCharArray
    var equivSubset = "CDEAF".ToCharArray
    var equivSuperset = "ABCDEFG".ToCharArray
      var setOperation: string = "subset"
      var methodName: string = nameof(UnicodeSet.IsSubsetOf)
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), aThruFSet.IsSubsetOf(equivEmptySet))
assertTrue($methodName & ": " & $nameof(emptySet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsSubsetOf(equivEmptySet))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSet), aThruFSet.IsSubsetOf(equivSet))
assertFalse($methodName & ": " & $nameof(aThruFSuperset) & " is a " & $setOperation & " of " & $nameof(equivSet2), aThruFSuperset.IsSubsetOf(equivSet2))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSubset), aThruFSet.IsSubsetOf(equivSubset))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSet.IsSubsetOf(equivSuperset))
assertTrue($methodName & ": " & $nameof(aThruFSuperset) & " is not a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSuperset.IsSubsetOf(equivSuperset))
proc TestIsSubsetOf_StringCollection*() =
    var equivEmptySet = List<string>
    var equivSet = List<string>
    var equivSubset = List<string>
    var equivSuperset = List<string>
      var setOperation: string = "subset"
      var methodName: string = nameof(UnicodeSet.IsSubsetOf)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), thaiWordSet.IsSubsetOf(equivEmptySet))
assertTrue($methodName & ": " & $nameof(emptySet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsSubsetOf(equivEmptySet))
thaiWordSet.CopyTo(equivSet)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(equivSet), thaiWordSet.IsSubsetOf(equivSet))
thaiWordSubset.CopyTo(equivSubset)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivSubset), thaiWordSet.IsSubsetOf(equivSubset))
thaiWordSuperset.CopyTo(equivSuperset)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(equivSuperset), thaiWordSet.IsSubsetOf(equivSuperset))
proc TestIsSubsetOf_CharArrayCollection*() =
    var equivEmptySet = List<char[]>
    var equivSet = List<char[]>
    var equivSubset = List<char[]>
    var equivSuperset = List<char[]>
      var setOperation: string = "subset"
      var methodName: string = nameof(UnicodeSet.IsSubsetOf)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), thaiWordSet.IsSubsetOf(equivEmptySet))
assertTrue($methodName & ": " & $nameof(emptySet) & " is not a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsSubsetOf(equivEmptySet))
thaiWordSet.CopyTo(equivSet)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(equivSet), thaiWordSet.IsSubsetOf(equivSet))
thaiWordSubset.CopyTo(equivSubset)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivSubset), thaiWordSet.IsSubsetOf(equivSubset))
thaiWordSuperset.CopyTo(equivSuperset)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(equivSuperset), thaiWordSet.IsSubsetOf(equivSuperset))
proc TestIsProperSubsetOf_String*() =
    var equivEmptySet = ""
    var equivSet = "ABCDEF"
    var equivSubset = "CDEAF"
    var equivSuperset = "ABCDEFG"
      var setOperation: string = "proper superset"
      var methodName: string = nameof(UnicodeSet.IsProperSubsetOf)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), aThruFSet.IsProperSubsetOf(equivEmptySet))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsProperSubsetOf(equivEmptySet))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSet), aThruFSet.IsProperSubsetOf(equivSet))
assertTrue($methodName & ": " & $nameof(aThruFSubset) & " is not a " & $setOperation & " of " & $nameof(equivSet), aThruFSubset.IsProperSubsetOf(equivSet))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSubset), aThruFSet.IsProperSubsetOf(equivSubset))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSet.IsProperSubsetOf(equivSuperset))
assertFalse($methodName & ": " & $nameof(aThruFSuperset) & " is a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSuperset.IsProperSubsetOf(equivSuperset))
proc TestIsProperSubsetOf_ReadOnlySpan*() =
    var equivEmptySet = "".AsSpan
    var equivSet = "ABCDEF".AsSpan
    var equivSubset = "CDEAF".AsSpan
    var equivSuperset = "ABCDEFG".AsSpan
      var setOperation: string = "proper superset"
      var methodName: string = nameof(UnicodeSet.IsProperSubsetOf)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), aThruFSet.IsProperSubsetOf(equivEmptySet))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsProperSubsetOf(equivEmptySet))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSet), aThruFSet.IsProperSubsetOf(equivSet))
assertTrue($methodName & ": " & $nameof(aThruFSubset) & " is not a " & $setOperation & " of " & $nameof(equivSet), aThruFSubset.IsProperSubsetOf(equivSet))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSubset), aThruFSet.IsProperSubsetOf(equivSubset))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSet.IsProperSubsetOf(equivSuperset))
assertFalse($methodName & ": " & $nameof(aThruFSuperset) & " is a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSuperset.IsProperSubsetOf(equivSuperset))
proc TestIsProperSubsetOf_CharArray*() =
    var equivEmptySet = "".ToCharArray
    var equivSet = "ABCDEF".ToCharArray
    var equivSubset = "CDEAF".ToCharArray
    var equivSuperset = "ABCDEFG".ToCharArray
      var setOperation: string = "proper superset"
      var methodName: string = nameof(UnicodeSet.IsProperSubsetOf)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), aThruFSet.IsProperSubsetOf(equivEmptySet))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsProperSubsetOf(equivEmptySet))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSet), aThruFSet.IsProperSubsetOf(equivSet))
assertTrue($methodName & ": " & $nameof(aThruFSubset) & " is not a " & $setOperation & " of " & $nameof(equivSet), aThruFSubset.IsProperSubsetOf(equivSet))
assertFalse($methodName & ": " & $nameof(aThruFSet) & " is a " & $setOperation & " of " & $nameof(equivSubset), aThruFSet.IsProperSubsetOf(equivSubset))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " is not a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSet.IsProperSubsetOf(equivSuperset))
assertFalse($methodName & ": " & $nameof(aThruFSuperset) & " is a " & $setOperation & " of " & $nameof(equivSuperset), aThruFSuperset.IsProperSubsetOf(equivSuperset))
proc TestIsProperSubsetOf_StringCollection*() =
    var equivEmptySet = List<string>
    var equivSet = List<string>
    var equivSubset = List<string>
    var equivSuperset = List<string>
      var setOperation: string = "proper superset"
      var methodName: string = nameof(UnicodeSet.IsProperSubsetOf)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), thaiWordSet.IsProperSubsetOf(equivEmptySet))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsProperSubsetOf(equivEmptySet))
thaiWordSet.CopyTo(equivSet)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivSet), thaiWordSet.IsProperSubsetOf(equivSet))
thaiWordSubset.CopyTo(equivSubset)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivSubset), thaiWordSet.IsProperSubsetOf(equivSubset))
thaiWordSuperset.CopyTo(equivSuperset)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(equivSuperset), thaiWordSet.IsProperSubsetOf(equivSuperset))
proc TestIsProperSubsetOf_CharArrayCollection*() =
    var equivEmptySet = List<char[]>
    var equivSet = List<char[]>
    var equivSubset = List<char[]>
    var equivSuperset = List<char[]>
      var setOperation: string = "proper superset"
      var methodName: string = nameof(UnicodeSet.IsProperSubsetOf)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), thaiWordSet.IsProperSubsetOf(equivEmptySet))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivEmptySet), emptySet.IsProperSubsetOf(equivEmptySet))
thaiWordSet.CopyTo(equivSet)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivSet), thaiWordSet.IsProperSubsetOf(equivSet))
thaiWordSubset.CopyTo(equivSubset)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " is a " & $setOperation & " of " & $nameof(equivSubset), thaiWordSet.IsProperSubsetOf(equivSubset))
thaiWordSuperset.CopyTo(equivSuperset)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " is not a " & $setOperation & " of " & $nameof(equivSuperset), thaiWordSet.IsProperSubsetOf(equivSuperset))
proc TestOverlaps_String*() =
    var equivEmptySet = ""
    var equivSet = "ABCDEF"
    var equivSubset = "CDEAF"
    var equivSuperset = "ABCDEFG"
      var setOperation: string = "overlap"
      var methodName: string = nameof(UnicodeSet.Overlaps)
assertFalse($methodName & ": " & $nameof(aThruFSet) & " does " & $setOperation & " with " & $nameof(equivEmptySet), aThruFSet.Overlaps(equivEmptySet))
assertFalse($methodName & ": " & $nameof(emptySet) & " does " & $setOperation & " with " & $nameof(equivEmptySet), emptySet.Overlaps(equivEmptySet))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " does not " & $setOperation & " with " & $nameof(equivSet), aThruFSet.Overlaps(equivSet))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " does not " & $setOperation & " with " & $nameof(equivSubset), aThruFSet.Overlaps(equivSubset))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " does not " & $setOperation & " with " & $nameof(equivSuperset), aThruFSet.Overlaps(equivSuperset))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " does " & $setOperation & " with " & $nameof(equivSet), thaiWordSet.Overlaps(equivSet))
proc TestOverlaps_ReadOnlySpan*() =
    var equivEmptySet = "".AsSpan
    var equivSet = "ABCDEF".AsSpan
    var equivSubset = "CDEAF".AsSpan
    var equivSuperset = "ABCDEFG".AsSpan
      var setOperation: string = "overlap"
      var methodName: string = nameof(UnicodeSet.Overlaps)
assertFalse($methodName & ": " & $nameof(aThruFSet) & " does " & $setOperation & " with " & $nameof(equivEmptySet), aThruFSet.Overlaps(equivEmptySet))
assertFalse($methodName & ": " & $nameof(emptySet) & " does " & $setOperation & " with " & $nameof(equivEmptySet), emptySet.Overlaps(equivEmptySet))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " does not " & $setOperation & " with " & $nameof(equivSet), aThruFSet.Overlaps(equivSet))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " does not " & $setOperation & " with " & $nameof(equivSubset), aThruFSet.Overlaps(equivSubset))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " does not " & $setOperation & " with " & $nameof(equivSuperset), aThruFSet.Overlaps(equivSuperset))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " does " & $setOperation & " with " & $nameof(equivSet), thaiWordSet.Overlaps(equivSet))
proc TestOverlaps_CharArray*() =
    var equivEmptySet = "".ToCharArray
    var equivSet = "ABCDEF".ToCharArray
    var equivSubset = "CDEAF".ToCharArray
    var equivSuperset = "ABCDEFG".ToCharArray
      var setOperation: string = "overlap"
      var methodName: string = nameof(UnicodeSet.Overlaps)
assertFalse($methodName & ": " & $nameof(aThruFSet) & " does " & $setOperation & " with " & $nameof(equivEmptySet), aThruFSet.Overlaps(equivEmptySet))
assertFalse($methodName & ": " & $nameof(emptySet) & " does " & $setOperation & " with " & $nameof(equivEmptySet), emptySet.Overlaps(equivEmptySet))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " does not " & $setOperation & " with " & $nameof(equivSet), aThruFSet.Overlaps(equivSet))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " does not " & $setOperation & " with " & $nameof(equivSubset), aThruFSet.Overlaps(equivSubset))
assertTrue($methodName & ": " & $nameof(aThruFSet) & " does not " & $setOperation & " with " & $nameof(equivSuperset), aThruFSet.Overlaps(equivSuperset))
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " does " & $setOperation & " with " & $nameof(equivSet), thaiWordSet.Overlaps(equivSet))
proc TestOverlaps_StringCollection*() =
    var equivEmptySet = List<string>
    var equivSet = List<string>
    var equivSubset = List<string>
    var equivSuperset = List<string>
    var equivBurmeseSet = List<string>
      var setOperation: string = "overlap"
      var methodName: string = nameof(UnicodeSet.Overlaps)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " does " & $setOperation & " with " & $nameof(equivEmptySet), thaiWordSet.Overlaps(equivEmptySet))
assertFalse($methodName & ": " & $nameof(emptySet) & " does " & $setOperation & " with " & $nameof(equivEmptySet), emptySet.Overlaps(equivEmptySet))
thaiWordSet.CopyTo(equivSet)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " does not " & $setOperation & " with " & $nameof(equivSet), thaiWordSet.Overlaps(equivSet))
thaiWordSubset.CopyTo(equivSubset)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " does not " & $setOperation & " with " & $nameof(equivSubset), thaiWordSet.Overlaps(equivSubset))
thaiWordSuperset.CopyTo(equivSuperset)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " does not " & $setOperation & " with " & $nameof(equivSuperset), thaiWordSet.Overlaps(equivSuperset))
burmeseWordSet.CopyTo(equivBurmeseSet)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " does " & $setOperation & " with " & $nameof(equivBurmeseSet), thaiWordSet.Overlaps(equivBurmeseSet))
proc TestOverlaps_CharArrayCollection*() =
    var equivEmptySet = List<char[]>
    var equivSet = List<char[]>
    var equivSubset = List<char[]>
    var equivSuperset = List<char[]>
    var equivBurmeseSet = List<char[]>
      var setOperation: string = "overlap"
      var methodName: string = nameof(UnicodeSet.Overlaps)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " does " & $setOperation & " with " & $nameof(equivEmptySet), thaiWordSet.Overlaps(equivEmptySet))
assertFalse($methodName & ": " & $nameof(emptySet) & " does " & $setOperation & " with " & $nameof(equivEmptySet), emptySet.Overlaps(equivEmptySet))
thaiWordSet.CopyTo(equivSet)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " does not " & $setOperation & " with " & $nameof(equivSet), thaiWordSet.Overlaps(equivSet))
thaiWordSubset.CopyTo(equivSubset)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " does not " & $setOperation & " with " & $nameof(equivSubset), thaiWordSet.Overlaps(equivSubset))
thaiWordSuperset.CopyTo(equivSuperset)
assertTrue($methodName & ": " & $nameof(thaiWordSet) & " does not " & $setOperation & " with " & $nameof(equivSuperset), thaiWordSet.Overlaps(equivSuperset))
burmeseWordSet.CopyTo(equivBurmeseSet)
assertFalse($methodName & ": " & $nameof(thaiWordSet) & " does " & $setOperation & " with " & $nameof(equivBurmeseSet), thaiWordSet.Overlaps(equivBurmeseSet))
proc TestSymmetricExceptWith_StringCollection*() =
    var equivEmptySet = List<string>
    var equivDThruMSet = List<string>
    var equivThaiWordSuperset = List<string>
      var setOperation: string = "symmetric except with (xOr)"
      var methodName: string = nameof(UnicodeSet.SymmetricExceptWith)
assertEquals($methodName & ": " & $nameof(aThruFSet) & " " & $setOperation & " " & $nameof(equivEmptySet) & " is wrong", aThruFSet, aThruFSet.SymmetricExceptWith(equivEmptySet))
dThruMSet.CopyTo(equivDThruMSet)
assertEquals($methodName & ": " & $nameof(aThruFSet) & " " & $setOperation & " " & $nameof(equivDThruMSet) & " is wrong", UnicodeSet("[A-CG-M]"), aThruFSet.SymmetricExceptWith(equivDThruMSet))
thaiWordSuperset.CopyTo(equivThaiWordSuperset)
assertEquals($methodName & ": " & $nameof(thaiWordSet) & " " & $setOperation & " " & $nameof(equivThaiWordSuperset) & " is wrong", UnicodeSet("[A]"), thaiWordSet.SymmetricExceptWith(equivThaiWordSuperset))
proc TestSymmetricExceptWith_CharArrayCollection*() =
    var equivEmptySet = List<char[]>
    var equivDThruMSet = List<char[]>
    var equivThaiWordSuperset = List<char[]>
      var setOperation: string = "symmetric except with (xOr)"
      var methodName: string = nameof(UnicodeSet.SymmetricExceptWith)
assertEquals($methodName & ": " & $nameof(aThruFSet) & " " & $setOperation & " " & $nameof(equivEmptySet) & " is wrong", aThruFSet, aThruFSet.SymmetricExceptWith(equivEmptySet))
dThruMSet.CopyTo(equivDThruMSet)
assertEquals($methodName & ": " & $nameof(aThruFSet) & " " & $setOperation & " " & $nameof(equivDThruMSet) & " is wrong", UnicodeSet("[A-CG-M]"), aThruFSet.SymmetricExceptWith(equivDThruMSet))
thaiWordSuperset.CopyTo(equivThaiWordSuperset)
assertEquals($methodName & ": " & $nameof(thaiWordSet) & " " & $setOperation & " " & $nameof(equivThaiWordSuperset) & " is wrong", UnicodeSet("[A]"), thaiWordSet.SymmetricExceptWith(equivThaiWordSuperset))