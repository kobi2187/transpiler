# "Namespace: ICU4N.Support"
type
  IntegerExtensionsTest = ref object


proc TestAsFlagsToEnum*() =
    var options: int
    var noFlags: EnumNoFlags = EnumNoFlags.Default
    var withFlags: EnumWithFlags = EnumWithFlags.Default
    options = 1
    noFlags = options.AsFlagsToEnum
    withFlags = options.AsFlagsToEnum
assertEquals($nameof(EnumNoFlags) & " value doesn't match options", EnumNoFlags.Symbol1, noFlags)
assertEquals($nameof(EnumWithFlags) & " value doesn't match options", EnumWithFlags.Symbol1, withFlags)
    options = 2
    noFlags = options.AsFlagsToEnum
    withFlags = options.AsFlagsToEnum
assertEquals($nameof(EnumNoFlags) & " value doesn't match options", EnumNoFlags.Symbol2, noFlags)
assertEquals($nameof(EnumWithFlags) & " value doesn't match options", EnumWithFlags.Symbol2, withFlags)
    options = 6
AssertThrows[ArgumentOutOfRangeException](<unhandled: nnkLambda>, "Expected " & $nameof(ArgumentOutOfRangeException) & " not thrown")
    withFlags = options.AsFlagsToEnum
assertEquals($nameof(EnumWithFlags) & " value doesn't match options", EnumWithFlags.Symbol2 | EnumWithFlags.Symbol3, withFlags)
    options = 3
AssertThrows[ArgumentOutOfRangeException](<unhandled: nnkLambda>, "Expected " & $nameof(ArgumentOutOfRangeException) & " not thrown")
    withFlags = options.AsFlagsToEnum
assertEquals($nameof(EnumWithFlags) & " value doesn't match options", EnumWithFlags.Symbol1 | EnumWithFlags.Symbol2, withFlags)
    options = 0
    noFlags = options.AsFlagsToEnum(EnumNoFlags.Symbol3)
    withFlags = options.AsFlagsToEnum(EnumWithFlags.Symbol3)
assertEquals($nameof(EnumNoFlags) & " value doesn't match options", EnumNoFlags.Symbol3, noFlags)
assertEquals($nameof(EnumWithFlags) & " value doesn't match options", EnumWithFlags.Symbol3, withFlags)
type
  EnumNoFlags = enum
    Default = 0
    Symbol1 = 1
    Symbol2 = 2
    Symbol3 = 4

type
  EnumWithFlags = enum
    Default = 0
    Symbol1 = 1
    Symbol2 = 2
    Symbol3 = 4
