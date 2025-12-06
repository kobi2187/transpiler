# XLang Node Naming Quick Reference

## Golden Rule
**Name nodes by WHAT they do, not WHAT they're called in language X**

## ✅ Good Examples (Semantic Names)

| Node Kind | Meaning | Languages |
|-----------|---------|-----------|
| `xnkResourceStmt` | Acquire resource with automatic cleanup | Python `with`, C# `using`, Java try-with-resources |
| `xnkRaiseStmt` | Raise/throw an exception | Python `raise`, C# `throw`, Java `throw` |
| `xnkIteratorYield` | Produce next value in iteration | Python `yield`, C# `yield return`, JS `yield` |
| `xnkNullCoalesceExpr` | Provide default if null | C# `??`, JS `??`, Kotlin `?:` |
| `xnkSafeNavigationExpr` | Access member only if not null | C# `?.`, Swift `?.`, Kotlin `?.` |
| `xnkConditionalExpr` | Ternary conditional | C `? :`, Python `x if c else y` |

## ❌ Bad Examples (Language-Specific Names)

| Bad Name | Problem | Better Name |
|----------|---------|-------------|
| `xnkWithStmt` | "with" is Python-specific | `xnkResourceStmt` |
| `xnkUsingStmt` | "using" is C#-specific | `xnkResourceStmt` |
| `xnkYieldStmt` | Overloaded - generators vs coroutines | `xnkIteratorYield` or `xnkCoroutineYield` |
| `xnkThrowStmt` | "throw" vs "raise" - same thing | `xnkRaiseStmt` |

## 🎯 Naming Checklist

When adding a new node kind, ask:

1. **Is it semantic?**
   - ✅ "IteratorYield" (describes behavior)
   - ❌ "PythonYield" (describes syntax)

2. **Is it unambiguous?**
   - ✅ "ResourceStmt" (clear purpose)
   - ❌ "YieldStmt" (yield for what?)

3. **Is it cross-language?**
   - ✅ "NullCoalesce" (concept exists in many languages)
   - ❌ "ElvisOperator" (Kotlin-specific slang)

4. **Would a newcomer understand it?**
   - ✅ "SafeNavigation" (self-explanatory)
   - ❌ "MonadicChain" (technically correct but obscure)

## 📋 Current Unification Targets

### In Progress
- [ ] `xnkWithStmt` + `xnkUsingStmt` → `xnkResourceStmt`
- [ ] `xnkThrowStmt` → `xnkRaiseStmt`
- [ ] `xnkSafeNavigationExpr` + `xnkConditionalAccessExpr` → `xnkSafeNavigationExpr`

### Needs Disambiguation
- [ ] `xnkYieldStmt` → `xnkIteratorYield` or `xnkCoroutineYield`
- [ ] `xnkYieldExpr` → analyze usage, possibly merge or rename
- [ ] `xnkYieldFromStmt` → `xnkIteratorDelegate`

## 🔍 Analysis: When to Keep Language-Specific Names

Sometimes language-specific names are okay IF:

1. **The concept truly only exists in one language**
   - Example: `xnkGoChannel` (Go-specific construct)
   - But consider: could other languages add this? Use semantic name anyway

2. **The name has become universal**
   - Example: `xnkLambdaExpr` (from lambda calculus, now universal)
   - Example: `xnkTernaryExpr` (widely understood)

3. **The semantic name would be too verbose**
   - Bad: `xnkThreeOperandConditionalExpression`
   - Okay: `xnkTernaryExpr`

## 🎨 Naming Patterns

### Statements (Actions)
Pattern: `xnk<Action><Category>Stmt`
- `xnkRaiseStmt` (raise exception)
- `xnkReturnStmt` (return value)
- `xnkResourceStmt` (manage resource)

### Expressions (Values)
Pattern: `xnk<Purpose>Expr`
- `xnkNullCoalesceExpr` (coalesce null values)
- `xnkSafeNavigationExpr` (safely navigate)
- `xnkConditionalExpr` (conditional value)

### Declarations
Pattern: `xnk<Thing>Decl`
- `xnkFuncDecl` (function declaration)
- `xnkClassDecl` (class declaration)
- `xnkVarDecl` (variable declaration)

### Types
Pattern: `xnk<Characteristic>Type`
- `xnkPointerType` (pointer to type)
- `xnkReferenceType` (reference to type)
- `xnkGenericType` (generic/parameterized type)

## 💡 Examples of Good Refactoring

### Before (Language-Specific)
```nim
case node.kind
of xnkWithStmt:      # Python-specific
  transformWith(node)
of xnkUsingStmt:     # C#-specific
  transformUsing(node)
```

### After (Semantic)
```nim
case node.kind
of xnkResourceStmt:  # Universal concept
  transformResource(node)
```

**Benefits:**
- Single transform instead of two
- New languages (Java, Rust) map naturally
- Clearer intent

## 🚀 Quick Start for Contributors

Adding support for a new language construct:

1. **Identify the semantic concept**
   - What does it DO, not what is it CALLED?

2. **Check if an XLang node already exists**
   - Search xlangtypes.nim for semantic equivalents
   - Don't create duplicates!

3. **If creating new node:**
   - Use semantic naming (see patterns above)
   - Document which languages use it
   - Consider future languages

4. **Update this guide**
   - Add to "Good Examples" table
   - Help others avoid duplicates

## 🔧 Special Case: Collection Literals

Collection literals are **syntax-level with library-level requirements**:

```nim
# Syntax is universal:
[1,2,3]     # All languages have this
{1,2,3}     # Sets look similar
{"a":1}     # Dicts/maps look similar

# But implementations vary:
# Python: list (builtin), set (builtin), dict (builtin)
# C#: List<T> (stdlib), HashSet<T> (stdlib), Dictionary<K,V> (stdlib)
# Nim: seq (system), HashSet (std/sets), Table (std/tables)
```

### Current Nodes (Need Renaming)
- `xnkListExpr` → `xnkSequenceLiteral` (more semantic)
- `xnkDictExpr` → `xnkMapLiteral` ("map" more universal than "dict")
- `xnkSetExpr` → `xnkSetLiteral` (consistency)
- `xnkArrayLit` → `xnkArrayLiteral` (consistency)

### Strategy
1. **XLang captures syntax** - What the parser saw
2. **Transforms add imports** - What stdlib is needed
3. **Target codegen adapts** - How to construct in target lang

**Example:**
```nim
# Python parser sees: {"a": 1}
# Emits: xnkMapLiteral

# Nim transform adds:
import tables

# Nim codegen produces:
{"a": 1}.toTable
```

See `COLLECTION_LITERALS_ANALYSIS.md` for full details.

## 📚 Related Documentation

- `CANONICAL_NAMES.md` - Full naming philosophy and guidelines
- `UNIFY_NODES.md` - Why unification matters
- `NODE_UNIFICATION_PLAN.md` - Implementation plan
- `xlangtypes.nim` - The canonical node definitions
