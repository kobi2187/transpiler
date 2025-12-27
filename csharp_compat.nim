## C# Compatibility Module for Nim
##
## This module provides type mappings, standard library functions, and helper
## utilities to make transpiled C# code work seamlessly in Nim.
##
## Usage: All transpiled C# files automatically import this module.

import std/[tables, sets, strutils, sequtils, times, options]

# ==============================================================================
# Type Aliases - C# → Nim
# ==============================================================================

# Primitive types (handled by primitive_type_mapping.nim, listed here for reference)
# bool    → bool
# byte    → uint8
# sbyte   → int8
# short   → int16
# ushort  → uint16
# int     → int32
# uint    → uint32
# long    → int64
# ulong   → uint64
# float   → float32
# double  → float64
# char    → char
# string  → string

# Common framework types
type
  StringBuilder* = ref object
    data: seq[string]

  DateTime* = times.DateTime
  TimeSpan* = times.Duration

# Collection type aliases
type
  List*[T] = seq[T]
  Dictionary*[K, V] = Table[K, V]
  HashSet*[T] = HashSet[T]
  Queue*[T] = seq[T]  # Simple queue implementation
  Stack*[T] = seq[T]  # Simple stack implementation

# ==============================================================================
# StringBuilder Implementation
# ==============================================================================

proc newStringBuilder*(): StringBuilder =
  ## Create a new StringBuilder
  StringBuilder(data: @[])

proc append*(sb: StringBuilder, s: string): StringBuilder {.discardable.} =
  ## Append a string to the StringBuilder
  sb.data.add(s)
  result = sb

proc append*(sb: StringBuilder, c: char): StringBuilder {.discardable.} =
  ## Append a char to the StringBuilder
  sb.data.add($c)
  result = sb

proc append*(sb: StringBuilder, value: SomeInteger): StringBuilder {.discardable.} =
  ## Append an integer to the StringBuilder
  sb.data.add($value)
  result = sb

proc toString*(sb: StringBuilder): string =
  ## Convert StringBuilder to string
  result = sb.data.join("")

proc clear*(sb: StringBuilder) =
  ## Clear the StringBuilder
  sb.data.setLen(0)

proc length*(sb: StringBuilder): int =
  ## Get the total length of the StringBuilder
  result = 0
  for s in sb.data:
    result += s.len

# ==============================================================================
# String Extensions (C# string methods)
# ==============================================================================

proc substring*(s: string, startIndex: int): string =
  ## C#: string.Substring(int startIndex)
  if startIndex >= s.len:
    return ""
  result = s[startIndex ..< s.len]

proc substring*(s: string, startIndex: int, length: int): string =
  ## C#: string.Substring(int startIndex, int length)
  if startIndex >= s.len:
    return ""
  let endIndex = min(startIndex + length, s.len)
  result = s[startIndex ..< endIndex]

proc indexOf*(s: string, value: string): int =
  ## C#: string.IndexOf(string value)
  ## Returns -1 if not found (like C#)
  let pos = s.find(value)
  result = if pos == -1: -1 else: pos

proc indexOf*(s: string, value: char): int =
  ## C#: string.IndexOf(char value)
  result = s.find(value)

proc contains*(s: string, value: string): bool =
  ## C#: string.Contains(string value)
  result = value in s

proc startsWith*(s: string, value: string): bool =
  ## C#: string.StartsWith(string value)
  result = s.startsWith(value)

proc endsWith*(s: string, value: string): bool =
  ## C#: string.EndsWith(string value)
  result = s.endsWith(value)

proc toUpper*(s: string): string =
  ## C#: string.ToUpper()
  result = s.toUpperAscii()

proc toLower*(s: string): string =
  ## C#: string.ToLower()
  result = s.toLowerAscii()

proc trim*(s: string): string =
  ## C#: string.Trim()
  result = s.strip()

proc trimStart*(s: string): string =
  ## C#: string.TrimStart()
  result = s.strip(leading = true, trailing = false)

proc trimEnd*(s: string): string =
  ## C#: string.TrimEnd()
  result = s.strip(leading = false, trailing = true)

proc replace*(s: string, oldValue: string, newValue: string): string =
  ## C#: string.Replace(string oldValue, string newValue)
  result = s.replace(oldValue, newValue)

proc split*(s: string, separator: char): seq[string] =
  ## C#: string.Split(char separator)
  result = s.split(separator)

proc split*(s: string, separator: string): seq[string] =
  ## C#: string.Split(string separator)
  result = s.split(separator)

# ==============================================================================
# Collection Extensions (C# collection methods)
# ==============================================================================

proc add*[T](list: var List[T], item: T) =
  ## C#: List<T>.Add(T item)
  list.add(item)

proc remove*[T](list: var List[T], item: T): bool =
  ## C#: List<T>.Remove(T item)
  ## Returns true if item was removed
  let idx = list.find(item)
  if idx >= 0:
    list.delete(idx)
    result = true
  else:
    result = false

proc removeAt*[T](list: var List[T], index: int) =
  ## C#: List<T>.RemoveAt(int index)
  list.delete(index)

proc clear*[T](list: var List[T]) =
  ## C#: List<T>.Clear()
  list.setLen(0)

proc count*[T](list: List[T]): int =
  ## C#: List<T>.Count property
  result = list.len

proc toArray*[T](list: List[T]): seq[T] =
  ## C#: List<T>.ToArray()
  result = list

# Dictionary extensions
proc add*[K, V](dict: var Dictionary[K, V], key: K, value: V) =
  ## C#: Dictionary<K,V>.Add(K key, V value)
  dict[key] = value

proc remove*[K, V](dict: var Dictionary[K, V], key: K): bool =
  ## C#: Dictionary<K,V>.Remove(K key)
  if key in dict:
    dict.del(key)
    result = true
  else:
    result = false

proc containsKey*[K, V](dict: Dictionary[K, V], key: K): bool =
  ## C#: Dictionary<K,V>.ContainsKey(K key)
  result = dict.hasKey(key)

proc tryGetValue*[K, V](dict: Dictionary[K, V], key: K, value: var V): bool =
  ## C#: Dictionary<K,V>.TryGetValue(K key, out V value)
  if key in dict:
    value = dict[key]
    result = true
  else:
    result = false

proc count*[K, V](dict: Dictionary[K, V]): int =
  ## C#: Dictionary<K,V>.Count property
  result = dict.len

# ==============================================================================
# Math/Numeric Helpers
# ==============================================================================

proc max*[T](a, b: T): T =
  ## C#: Math.Max(T a, T b)
  result = if a > b: a else: b

proc min*[T](a, b: T): T =
  ## C#: Math.Min(T a, T b)
  result = if a < b: a else: b

proc abs*[T](x: T): T =
  ## C#: Math.Abs(T x)
  result = if x < 0: -x else: x

# ==============================================================================
# Exception Types
# ==============================================================================

type
  ArgumentException* = object of CatchableError
  ArgumentNullException* = object of ArgumentException
  ArgumentOutOfRangeException* = object of ArgumentException
  InvalidOperationException* = object of CatchableError
  NotImplementedException* = object of CatchableError
  NotSupportedException* = object of CatchableError
  NullReferenceException* = object of CatchableError
  IndexOutOfRangeException* = object of CatchableError
  KeyNotFoundException* = object of CatchableError

# ==============================================================================
# Object/Reference Helpers
# ==============================================================================

template isNull*[T](obj: ref T): bool =
  ## Check if a reference is null (nil in Nim)
  obj.isNil

template isNull*(obj: ptr): bool =
  ## Check if a pointer is null
  obj.isNil

# ==============================================================================
# LINQ-style Operations (basic implementations)
# ==============================================================================

proc where*[T](list: seq[T], predicate: proc(x: T): bool): seq[T] =
  ## C#: list.Where(predicate)
  result = list.filter(predicate)

proc select*[T, U](list: seq[T], selector: proc(x: T): U): seq[U] =
  ## C#: list.Select(selector)
  result = list.map(selector)

proc first*[T](list: seq[T]): T =
  ## C#: list.First()
  if list.len == 0:
    raise newException(InvalidOperationException, "Sequence contains no elements")
  result = list[0]

proc firstOrDefault*[T](list: seq[T]): T =
  ## C#: list.FirstOrDefault()
  if list.len == 0:
    result = default(T)
  else:
    result = list[0]

proc last*[T](list: seq[T]): T =
  ## C#: list.Last()
  if list.len == 0:
    raise newException(InvalidOperationException, "Sequence contains no elements")
  result = list[^1]

proc any*[T](list: seq[T], predicate: proc(x: T): bool): bool =
  ## C#: list.Any(predicate)
  for item in list:
    if predicate(item):
      return true
  result = false

proc all*[T](list: seq[T], predicate: proc(x: T): bool): bool =
  ## C#: list.All(predicate)
  for item in list:
    if not predicate(item):
      return false
  result = true

proc count*[T](list: seq[T], predicate: proc(x: T): bool): int =
  ## C#: list.Count(predicate)
  result = 0
  for item in list:
    if predicate(item):
      inc result
