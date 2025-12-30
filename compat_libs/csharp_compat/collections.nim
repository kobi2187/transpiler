## C# collection types mapped to Nim equivalents
## List<T> -> seq[T], Dictionary<K,V> -> Table[K,V], etc.

import std/tables

# Generic type aliases for C# collections
# Note: Nim doesn't support type aliases with generic parameters directly,
# so we'll define converter procs and helper types instead

# List<T> maps to seq[T] - no alias needed, transpiler can do direct mapping
# Dictionary<K,V> maps to Table[K,V] - re-export from std/tables

export tables

# Collection extension methods will be added here
