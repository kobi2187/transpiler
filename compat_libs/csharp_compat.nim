## C# Compatibility Layer for Nim
## Root facade that exports all C# type mappings and utilities
##
## Structure:
## - primitives: C# primitive types (Int32, String, etc.) mapped to Nim
## - collections: C# collections (List, Dictionary) mapped to Nim equivalents
## - system/*: .NET BCL types transpiled from .NET Core or Mono

import ./csharp_compat/primitives
import ./csharp_compat/collections
import ./csharp_compat/system

export primitives, collections, system
