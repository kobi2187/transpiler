# "Namespace: ICU4N.Dev.Test.Lang"
type
  UPropertyAliasesTest = ref object


proc newUPropertyAliasesTest(): UPropertyAliasesTest =

proc TestPropertyNames*() =
      var v: int
      var rev: int
    var p: UProperty
    var choice: NameChoice
      p = 0
      while true:
          var sawProp: bool = false
            choice = 0
            while true:
                var name: string = nil
                try:
                    name = UChar.GetPropertyName(p, choice)
                    if !sawProp:
Log("prop " + p + ":")
                    var n: string =                     if name != nil:
""" + name + '"'
                    else:
"null"
Log(" " + choice + "=" + n)
                    sawProp = true
                except ArgumentException:
                    if choice > 0:
                      break
                if name != nil:
                    rev = UChar.GetPropertyEnum(name)
                    if rev != cast[int](p):
Errln("Property round-trip failure: " + p + " -> " + name + " -> " + rev)
++choice
          if sawProp:
              var pname: string = UChar.GetPropertyName(p, NameChoice.Long)
              var max: int = 0
              if p == UProperty.Canonical_Combining_Class:
                  max = 255

              elif p == UProperty.General_Category_Mask:
                  max = 4096
              else:
                if p == UProperty.Block:
                    max = 1
Logln("")
                v = -1
                while true:
                    var sawValue: bool = false
                      choice = 0
                      while true:
                          var vname: string = nil
                          try:
                              vname = UChar.GetPropertyValueName(p, v, choice)
                              var n: string =                               if vname != nil:
""" + vname + '"'
                              else:
"null"
                              if !sawValue:
Log(" " + pname + ", value " + v + ":")
Log(" " + choice + "=" + n)
                              sawValue = true
                          except ArgumentException:
                              if choice > 0:
                                break
                          if vname != nil:
                              rev = UChar.GetPropertyValueEnum(p, vname)
                              if rev != v:
Errln("Value round-trip failure (" + pname + "): " + v + " -> " + vname + " -> " + rev)
++choice
                    if sawValue:
Logln("")
                    if !sawValue && v >= max:
                      break
++v
          if !sawProp:
              if p >= UPropertyConstants.String_Limit:
                  break

              elif p >= UPropertyConstants.Double_Limit:
                  p = UPropertyConstants.String_Start - 1
              else:
                if p >= UPropertyConstants.Mask_Limit:
                    p = UPropertyConstants.Double_Start - 1

                elif p >= UPropertyConstants.Int_Limit:
                    p = UPropertyConstants.Mask_Start - 1
                else:
                  if p >= UPropertyConstants.Binary_Limit:
                      p = UPropertyConstants.Int_Start - 1
++p
    var i: int = UChar.GetIntPropertyMinValue(UProperty.Canonical_Combining_Class)
    try:
          while i <= UChar.GetIntPropertyMaxValue(UProperty.Canonical_Combining_Class):
UChar.GetPropertyValueName(UProperty.Canonical_Combining_Class, i, NameChoice.Long)
++i
    except ArgumentException:
Errln("0x" + i.ToHexString + " should have a null property value name")
proc TestPropertyNamesUsingTry*() =
      var v: int
      var rev: int
    var p: UProperty
    var choice: NameChoice
    var success: bool = false
      p = 0
      while true:
          var sawProp: bool = false
            choice = 0
            while true:
                var name: string = nil
                success = UChar.TryGetPropertyName(p, choice,                 var error: ICU4N.Impl.UPropertyAliases.NameFetchError,                 var nameSpan: ReadOnlySpan<char>)
                if success || !success && error == UPropertyAliases.NameFetchError.Undefined:
                    name =                     if error == ICU4N.Impl.UPropertyAliases.NameFetchError.Undefined:
nil
                    else:
nameSpan.ToString
                    if !sawProp:
Log("prop " + p + ":")
                    var n: string =                     if name != nil:
""" + name + '"'
                    else:
"null"
Log(" " + choice + "=" + n)
                    sawProp = true

                elif !success:
                    if choice > 0:
                      break
                if name != nil:
UChar.TryGetPropertyEnum(name, rev)
                    if rev != cast[int](p):
Errln("Property round-trip failure: " + p + " -> " + name + " -> " + rev)
UChar.TryGetPropertyEnum(name.AsSpan, rev)
                    if rev != cast[int](p):
Errln("Property round-trip failure: " + p + " -> " + name + " -> " + rev)
++choice
          if sawProp:
              var pname: string = nil
              if UChar.TryGetPropertyName(p, NameChoice.Long,               var pnameSpan: ReadOnlySpan<char>):
                  pname = pnameSpan.ToString
              var max: int = 0
              if p == UProperty.Canonical_Combining_Class:
                  max = 255

              elif p == UProperty.General_Category_Mask:
                  max = 4096
              else:
                if p == UProperty.Block:
                    max = 1
Logln("")
                v = -1
                while true:
                    var sawValue: bool = false
                      choice = 0
                      while true:
                          var vname: string = nil
                          success = UChar.TryGetPropertyValueName(p, v, choice,                           var error: UPropertyAliases.NameFetchError,                           var vnameSpan: ReadOnlySpan<char>)
                          if success || !success && error == UPropertyAliases.NameFetchError.Undefined:
                              vname =                               if error == UPropertyAliases.NameFetchError.Undefined:
nil
                              else:
vnameSpan.ToString
                              var n: string =                               if vname != nil:
""" + vname + '"'
                              else:
"null"
                              if !sawValue:
Log(" " + pname + ", value " + v + ":")
Log(" " + choice + "=" + n)
                              sawValue = true

                          elif !success:
                              if choice > 0:
                                break
                          if vname != nil:
UChar.TryGetPropertyValueEnum(p, vname, rev)
                              if rev != v:
Errln("Value round-trip failure (" + pname + "): " + v + " -> " + vname.ToString + " -> " + rev)
UChar.TryGetPropertyValueEnum(p, vname.AsSpan, rev)
                              if rev != v:
Errln("Value round-trip failure (" + pname + "): " + v + " -> " + vname.ToString + " -> " + rev)
++choice
                    if sawValue:
Logln("")
                    if !sawValue && v >= max:
                      break
++v
          if !sawProp:
              if p >= UPropertyConstants.String_Limit:
                  break

              elif p >= UPropertyConstants.Double_Limit:
                  p = UPropertyConstants.String_Start - 1
              else:
                if p >= UPropertyConstants.Mask_Limit:
                    p = UPropertyConstants.Double_Start - 1

                elif p >= UPropertyConstants.Int_Limit:
                    p = UPropertyConstants.Mask_Start - 1
                else:
                  if p >= UPropertyConstants.Binary_Limit:
                      p = UPropertyConstants.Int_Start - 1
++p
    var i: int = UChar.GetIntPropertyMinValue(UProperty.Canonical_Combining_Class)
      while i <= UChar.GetIntPropertyMaxValue(UProperty.Canonical_Combining_Class):
          success = UChar.TryGetPropertyValueName(UProperty.Canonical_Combining_Class, i, NameChoice.Long,           var error: UPropertyAliases.NameFetchError,           var valueName: ReadOnlySpan<char>)
          if !success && error != UPropertyAliases.NameFetchError.Undefined:
Errln("0x" + i.ToHexString + " should return false or should have a valid property value name")
              break
++i
proc TestUnknownPropertyNames*() =
    try:
        var p: int = UChar.GetPropertyEnum("??")
Errln("UCharacter.getPropertyEnum(??) returned " + p + " rather than throwing an exception")
    except ArgumentException:

    try:
        var p: int = UChar.GetPropertyValueEnum(UProperty.Line_Break, "?!")
Errln("UCharacter.getPropertyValueEnum(UProperty.LINE_BREAK, ?!) returned " + p + " rather than throwing an exception")
    except ArgumentException:

proc TestUnknownPropertyNamesUsingTry*() =
    if UChar.TryGetPropertyEnum("??",     var p: int):
Errln("UCharacter.TryGetPropertyEnum(??) returned " + p + " rather than false")
    else:

    if UChar.TryGetPropertyValueEnum(UProperty.Line_Break, "?!", p):
Errln("UCharacter.TryGetPropertyValueEnum(UProperty.LINE_BREAK, ?!) returned " + p + " rather than false")
    else:
