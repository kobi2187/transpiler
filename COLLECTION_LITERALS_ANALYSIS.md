# Collection Literals: Syntax vs Library Analysis

## The Problem

Collection literals look like language syntax but actually rely on stdlib:

### Python
```python
[1, 2, 3]        # List - built-in type
{1, 2, 3}        # Set - requires set() stdlib
{"a": 1}         # Dict - built-in type
```

### C#
```csharp
new[] {1, 2, 3}         // Array - language-level
new List<int> {1, 2, 3} // List - System.Collections.Generic
new HashSet<int> {1,2,3}// Set - System.Collections.Generic
new Dictionary<string,int> {{"a",1}} // Dict - stdlib
```

### Nim
```nim
[1, 2, 3]        # Array - language-level (fixed size)
@[1, 2, 3]       # Seq - stdlib (from system)
{1, 2, 3}        # Set - language-level (bitset)
{"a": 1}.toTable # Table - requires import tables
```

## Key Insight

**These constructs span the boundary between syntax and library:**

1. **Syntax-level**: Parser recognizes the literal form
2. **Library-level**: The actual type/implementation lives in stdlib
3. **Hybrid**: Parser produces syntax, but semantics require stdlib

## Current XLang Representation

We have separate node kinds:
- `xnkArrayLit` - Fixed-size arrays
- `xnkListExpr` - Dynamic lists/sequences
- `xnkSetExpr` - Sets
- `xnkDictExpr` - Dictionaries/maps

**Problem:** These conflate syntax with semantics!

## The Real Semantic Differences

### 1. Ordered vs Unordered
- **Ordered:** Arrays, Lists, Tuples
- **Unordered:** Sets, Dicts (in most langs)

### 2. Mutable vs Immutable
- **Mutable:** Most collections by default
- **Immutable:** Python frozenset, Nim const arrays

### 3. Fixed-size vs Dynamic
- **Fixed:** Arrays, Tuples
- **Dynamic:** Lists, Sets, Dicts

### 4. Indexed vs Associative
- **Indexed:** Arrays, Lists (access by integer)
- **Associative:** Dicts (access by key)
- **Membership only:** Sets (no access, just contains)

## What Should XLang Represent?

**Option 1: Keep Syntax-Level Nodes (Current)**
```nim
# Parser emits what it sees:
xnkArrayLit   # [1,2,3] syntax
xnkListExpr   # List literal (Python-specific?)
xnkSetExpr    # {1,2,3} syntax
xnkDictExpr   # {k:v} syntax
```

**Pros:**
- Easy for parsers to emit
- Direct mapping from source

**Cons:**
- Conflates syntax with semantics
- Language-specific (what's a "list"?)
- Doesn't capture type information

**Option 2: Semantic Collection Constructors**
```nim
# Emit semantic meaning:
xnkCollectionLiteral
  collectionKind: array | seq | set | table
  elementType: Option[XLangNode]
  elements: seq[XLangNode]
```

**Pros:**
- Language-agnostic
- Clear semantics

**Cons:**
- Parsers need to infer semantics
- More complex

**Option 3: Hybrid - Syntax + Type Info**
```nim
# Keep syntax nodes but add metadata:
xnkArrayLit        # Syntax: [...]
  targetType: Option[string]  # "array", "seq", "List<T>", etc.

xnkSetLiteral      # Syntax: {...} for sets
  targetType: "set" | "HashSet<T>"

xnkDictLiteral     # Syntax: {k:v}
  targetType: "Table" | "Dictionary<K,V>"
```

## Recommendation

**Keep syntax-level nodes, but clarify semantics in transforms:**

### 1. Rename for Clarity
```nim
# Before (ambiguous):
xnkListExpr  # Is this Python list? Nim seq? C# List<T>?

# After (clear):
xnkSequenceLiteral  # Dynamic, ordered collection
xnkArrayLiteral     # Fixed-size, ordered collection
xnkSetLiteral       # Unordered, unique elements
xnkMapLiteral       # Key-value pairs (not "Dict")
```

### 2. Handle Import Requirements in Transforms

Create a new transform pass: `collection_imports.nim`

```nim
proc addRequiredImports*(node: XLangNode): XLangNode =
  ## Analyze collection literals and add required imports

  var neededImports: seq[string] = @[]

  # Walk AST looking for collections
  case node.kind
  of xnkMapLiteral:
    # Maps/dicts need tables module in Nim
    neededImports.add("tables")

  of xnkSequenceLiteral:
    # Seqs are in system, auto-imported
    discard

  of xnkSetLiteral:
    # Check if it's beyond ordinal set size
    # Might need std/sets for large sets
    if needsHashSet(node):
      neededImports.add("sets")

  # Add imports to module
  result = node
  for imp in neededImports:
    prependImport(result, imp)
```

### 3. Target-Language Transform

```nim
proc transformCollectionsForNim*(node: XLangNode): XLangNode =
  ## Transform collection literals to Nim equivalents

  case node.kind
  of xnkSequenceLiteral:
    # Add @ prefix for seqs
    result = wrapWithPrefix("@", node)

  of xnkMapLiteral:
    # Add .toTable suffix for tables
    result = wrapWithSuffix(".toTable", node)

  of xnkSetLiteral:
    # Nim sets are ordinal only
    if not isOrdinalSet(node):
      # Need HashSet from std/sets
      result = constructorCall("toHashSet", node)
    else:
      result = node  # Direct syntax works

  else:
    result = node
```

## Comparison with Other Languages

### JavaScript
```javascript
[1,2,3]              // Array - built-in
new Set([1,2,3])     // Set - ES6 stdlib
new Map([['a',1]])   // Map - ES6 stdlib
{a:1}                // Object literal (NOT a map!)
```

### Rust
```rust
vec![1,2,3]          // Vec - macro + stdlib
[1,2,3]              // Array - language-level
HashSet::from([1,2]) // Set - use statement + stdlib
HashMap::from([('a',1)]) // Map - use statement + stdlib
```

### Go
```go
[3]int{1,2,3}        // Array - language-level
[]int{1,2,3}         // Slice - language-level
map[string]int{"a":1}// Map - language-level
// No set - use map[T]bool or library
```

## Pattern Across Languages

**Common theme:**
- **Arrays/tuples** are almost always language-level
- **Seqs/lists** vary (built-in in Python, library in many others)
- **Sets** almost always require stdlib
- **Dicts/maps** vary widely

**Insight:** The XLang representation should:
1. Capture the **syntax** (what the parser saw)
2. Annotate the **semantics** (what type is intended)
3. Let **transforms** handle stdlib requirements

## Implementation Plan

### Phase 1: Rename Nodes (Clarity)
```nim
xnkArrayLit     → xnkArrayLiteral    # Or keep as-is
xnkListExpr     → xnkSequenceLiteral # More semantic
xnkSetExpr      → xnkSetLiteral      # Consistent naming
xnkDictExpr     → xnkMapLiteral      # "Map" > "Dict" (more universal)
```

### Phase 2: Add Import Analysis Transform
- `collection_imports.nim` pass
- Analyzes AST for collection usage
- Adds required imports at module level

### Phase 3: Add Target-Specific Transforms
- `nim_collections.nim` - Nim-specific collection transforms
- Handles `@[...]` for seqs
- Handles `.toTable` for maps
- Handles HashSet for non-ordinal sets

### Phase 4: Document Requirements
- Each collection node documents what it needs
- Transforms ensure requirements are met
- Clear error messages if stdlib unavailable

## Philosophical Question

**Should XLang care about imports?**

**Option A: Yes, XLang tracks imports**
- Pro: Complete representation
- Pro: Can validate availability
- Con: Couples XLang to target platform

**Option B: No, transforms add imports**
- Pro: XLang stays abstract
- Pro: Each target handles its needs
- Con: Imports are "magic"

**Recommendation:** Option B with documentation
- XLang node = semantic intent
- Transform = implementation detail
- Documentation = what's required

## Summary

Collection literals are **syntax-level constructs with library-level requirements**:

1. **Rename nodes** for clarity (`xnkSequenceLiteral` vs `xnkListExpr`)
2. **Track requirements** in transform passes
3. **Add imports** automatically when needed
4. **Document** what each collection needs

This keeps XLang abstract while ensuring generated code works.
