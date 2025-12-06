# Unifying Semantically Equivalent Node Kinds

## Problem
We currently have different XLang node kinds for the same semantic concepts across languages. This creates unnecessary complexity and duplicate transform passes.

## Examples of Redundant Nodes

### 1. Resource Management (CRITICAL)
**Current:**
- `xnkWithStmt` (Python: `with open() as f:`)
- `xnkUsingStmt` (C#: `using (var f = open())`)
- `xnkDeferStmt` (Go: `defer f.close()`)

**Semantic meaning:** Acquire resource, ensure cleanup happens

**Proposal:** Single `xnkResourceStmt` node
```nim
of xnkResourceStmt:
  resourceItems*: seq[XLangNode]  # Resources to acquire
  resourceBody*: XLangNode         # Body that uses resources

of xnkResourceItem:
  resourceExpr*: XLangNode         # Resource expression
  resourceVar*: Option[XLangNode]  # Optional variable name
  cleanupMethod*: Option[string]   # Optional cleanup method hint ("close", "dispose")
```

**Migration:**
1. Add `xnkResourceStmt` and `xnkResourceItem` to xlangtypes.nim
2. Update Python parser to emit `xnkResourceStmt` instead of `xnkWithStmt`
3. Update C# parser to emit `xnkResourceStmt` instead of `xnkUsingStmt`
4. Merge `with_to_defer.nim` and `csharp_using.nim` into single `resource_to_defer.nim`
5. Deprecate old node kinds

### 2. Null Coalescing / Optional Chaining
**Current:**
- `xnkNullCoalesceExpr` (C#: `x ?? y`)
- `xnkSafeNavigationExpr` (C#: `x?.y`)
- `xnkConditionalAccessExpr` (C#: another form of `?.`)

**Proposal:** These are actually different enough to keep separate, but they should all use the same transform pass

### 3. String Interpolation
**Current:**
- Languages have different syntax but same semantics
- C#: `$"Hello {name}"`
- Python: `f"Hello {name}"`
- JavaScript: `` `Hello ${name}` ``

**Current status:** Already unified as `xnkStringInterpolation` ✓

### 4. Lambda Expressions
**Current:**
- `xnkLambdaExpr` (multi-language lambda)
- `xnkArrowFunc` (JavaScript arrow function)
- `xnkLambdaProc` (another form)

**Proposal:** Unify to single `xnkLambdaExpr` with optional metadata about style

### 5. Type Assertions/Casts
**Current:**
- `xnkTypeAssertion` (TypeScript: `x as Type`)
- `xnkCastExpr` (C#: `(Type)x`)

**Semantic difference:** Type assertions are compile-time hints, casts are runtime conversions
**Decision:** Keep separate - they ARE semantically different

## Benefits of Unification

1. **Simpler transform pipeline** - One transform instead of multiple
2. **Easier to maintain** - Single source of truth for each concept
3. **Better cross-language support** - New languages just map to existing nodes
4. **Clearer semantics** - Node kind name describes WHAT, not HOW

## Implementation Strategy

### Phase 1: Add Unified Nodes (Non-breaking)
1. Add new unified node kinds to xlangtypes.nim
2. Keep old node kinds (deprecated)
3. Add transforms that convert old → new

### Phase 2: Update Parsers
1. Update Python parser: `with` → `xnkResourceStmt`
2. Update C# parser: `using` → `xnkResourceStmt`
3. Test extensively

### Phase 3: Consolidate Transforms
1. Create unified transform: `resource_to_defer.nim`
2. Test that it handles both Python and C# cases
3. Deprecate old transforms

### Phase 4: Remove Old Nodes
1. Remove old node kinds from xlangtypes.nim
2. Remove old transform passes
3. Update documentation

## Guiding Principle

**"One semantic concept = One node kind"**

If two language constructs have the same:
- **Purpose** (why it exists)
- **Behavior** (what it does)
- **Transformation** (how we lower it)

Then they should use the same XLang node kind, regardless of syntax differences.

## Additional Unification Candidates

### Throw vs Raise
**Current:**
- `xnkThrowStmt` (C#/Java: `throw ex`)
- `xnkRaiseStmt` (Python/Nim: `raise ex`)

**Semantic meaning:** Both raise an exception

**Proposal:** Unify to `xnkRaiseStmt` (more general, supports re-raise)
```nim
of xnkRaiseStmt:
  raiseExpr*: Option[XLangNode]  # None = re-raise current exception
```

**Parsers:**
- C#/Java `throw` → emit `xnkRaiseStmt` with expr
- Python/Nim `raise` → emit `xnkRaiseStmt` (with or without expr)

### Safe Navigation / Conditional Access
**Current:**
- `xnkSafeNavigationExpr` (C#: `x?.y`)
- `xnkConditionalAccessExpr` (C#: another variant?)

**These appear to be the same thing!**

**Proposal:** Keep only `xnkSafeNavigationExpr`, remove `xnkConditionalAccessExpr`

### Member Access / Dot Expression
**Current:**
- `xnkMemberAccessExpr` (explicit member access)
- `xnkDotExpr` (dot syntax)

**Analysis:** These might be intentionally separate:
- `xnkDotExpr` = general dot operator (could be module.function)
- `xnkMemberAccessExpr` = specifically object.member

**Decision:** Keep separate for now, but review usage patterns

### Yield Statement vs Yield Expression
**Current:**
- `xnkYieldStmt` (statement form)
- `xnkYieldExpr` (expression form)

**Analysis:** These ARE semantically different:
- Statement: `yield x` (Python generators)
- Expression: value of yield can be used: `y = (yield x)` (coroutines)

**Decision:** Keep separate

## Open Questions

1. Should `xnkDeferStmt` (Go's explicit defer) also unify with resource management?
   - **Answer:** No - Go's defer is more general (any statement, not just cleanup)
   - Keep as separate node, but `xnkResourceStmt` can lower to it

2. What about `xnkLockStmt`? Is this resource management?
   - **Answer:** Yes! Lock acquisition is resource management
   - `xnkLockStmt` could be a special case of `xnkResourceStmt`
   - Or keep separate since locking has special semantics (mutual exclusion)

3. How to handle language-specific hints (cleanup method name)?
   - **Answer:** Add optional `cleanupMethod` field with hints like "close", "dispose", "release"
   - Transform can use this hint or apply heuristics
