## C# primitive types and their methods
## Maps C# primitives to Nim equivalents with C#-style method names

import std/hashes

# Type aliases for C# primitives
type
  Int32* = int32
  Int64* = int64
  Boolean* = bool
  String* = string
  Double* = float64
  Single* = float32

# Extension methods for int32
proc getHashCode*(value: int32): int32 =
  hash(value).int32

proc equals*(value: int32, other: int32): bool =
  value == other

proc equals*(value: int32, obj: RootObj): bool =
  # For primitive int32 comparing to object, just return false
  false

proc toString*(value: int32): string =
  $value

proc toString*(value: int32, culture: ref RootObj): string =
  # Ignore culture for now, just convert to string
  $value

proc compareTo*(value: int32, other: int32): int32 =
  if value < other: -1
  elif value > other: 1
  else: 0

# Extension methods for string
proc getHashCode*(value: string): int32 =
  hash(value).int32

proc equals*(value: string, other: string): bool =
  value == other

proc equals*(value: string, obj: RootObj): bool =
  false

# StringComparison enum (from .NET BCL)
type
  StringComparison* = enum
    scCurrentCulture = 0
    scCurrentCultureIgnoreCase = 1
    scInvariantCulture = 2
    scInvariantCultureIgnoreCase = 3
    scOrdinal = 4
    scOrdinalIgnoreCase = 5
