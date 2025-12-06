# Canonical Node Naming Guidelines

## Problem: Vague and Overloaded Names

Many XLang node names are:
- Language-specific (e.g., "with", "using") instead of semantic
- Overloaded with multiple meanings (e.g., "yield")
- Technical jargon without clear intent (e.g., "defer")

## Principle: Self-Documenting Semantic Names

Node names should answer: **"What does this DO, not what is it CALLED in language X"**

Good names are:
- **Semantic**: Describe the behavior/purpose
- **Unambiguous**: One meaning only
- **Cross-language**: Not tied to specific syntax
- **Self-documenting**: Readable without comments

## Renaming Proposals

### Category: Control Flow

#### Current: `xnkYieldStmt`, `xnkYieldExpr`, `xnkYieldFromStmt`
**Problem:** "Yield" has completely different semantics in different contexts!

**Context 1: Generators/Iterators** (Python, C#, JavaScript)
```python
def fibonacci():
    a, b = 0, 1
    while True:
        yield a  # Produce next value in sequence
        a, b = b, a + b
```
**Meaning:** Produce a value and pause, resumable iteration

**Context 2: Async/Await** (C# async, some coroutines)
```csharp
async Task<int> Compute() {
    await Task.Delay(100);  // Similar to yield in coroutines
    return 42;
}
```
**Meaning:** Suspend execution, allow other work, resume later

**Context 3: Thread Yielding** (Some languages)
```
yield()  // Give up CPU time slice
```
**Meaning:** Cooperative multitasking, scheduler hint

**Analysis:** These are three COMPLETELY different concepts!

**Proposals:**

1. **Generator Value Production**
   - **Old:** `xnkYieldStmt`
   - **New:** `xnkIteratorYield` or `xnkProduceValue`
   - **Semantic:** "Produce the next value in an iteration sequence"

2. **Yield From (Python's `yield from`)**
   - **Old:** `xnkYieldFromStmt`
   - **New:** `xnkDelegateIteration` or `xnkIteratorDelegate`
   - **Semantic:** "Delegate iteration to another iterator"

3. **Yield Expression (Coroutine receive)**
   - **Old:** `xnkYieldExpr`
   - **New:** `xnkCoroutineReceive` or `xnkSuspendAndReceive`
   - **Semantic:** "Suspend and wait for value to be sent in"

**Recommended Naming:**
```nim
# For generators/iterators
xnkIteratorYield      # yield value (Python, C#)
xnkIteratorDelegate   # yield from subiterator (Python)

# For coroutines (if needed separately)
xnkCoroutineYield     # Suspend and optionally send value
xnkCoroutineReceive   # Receive value from sender

# For async/await (probably separate nodes already)
xnkAwaitExpr          # Already exists, good name!
```

### Category: Resource Management

#### Current: `xnkWithStmt`, `xnkUsingStmt`, `xnkDeferStmt`
**Status:** Already proposed `xnkResourceStmt` ✓

**Additional consideration:**

**`xnkDeferStmt`** (Go's defer)
- **Current meaning:** Execute statement when function returns
- **Semantic:** "Scheduled cleanup" or "Exit handler"
- **Keep as is?** Yes, "defer" is actually pretty clear
- **Alternative:** `xnkOnScopeExit` (more explicit)

### Category: Exception Handling

#### Current: `xnkThrowStmt`, `xnkRaiseStmt`
**Status:** Already proposed unification to `xnkRaiseStmt` ✓

**Consideration:** Is "raise" the best canonical name?
- **Alternatives:** `xnkThrowException`, `xnkRaiseException`
- **Decision:** Keep `xnkRaiseStmt` (concise, widely understood)

### Category: Conditional Expressions

#### Current: `xnkTernaryExpr`
**Analysis:** "Ternary" describes syntax (three operands), not semantics

**Proposal:**
- **Old:** `xnkTernaryExpr`
- **New:** `xnkConditionalExpr` or `xnkIfExpr`
- **Semantic:** "Expression that evaluates to one of two values based on condition"

**Decision:** Keep `xnkTernaryExpr` for now
- It's unambiguous
- Widely recognized term
- No confusion across languages

### Category: Null Safety

#### Current: `xnkNullCoalesceExpr`, `xnkSafeNavigationExpr`
**Analysis:** These names are actually pretty good!

- `xnkNullCoalesceExpr` (x ?? y) = "Use default if null"
- `xnkSafeNavigationExpr` (x?.y) = "Navigate only if not null"

**Decision:** Keep as-is ✓

### Category: Type Operations

#### Current: `xnkCastExpr`, `xnkTypeAssertion`
**Analysis:**
- Cast = runtime type conversion
- Type assertion = compile-time type hint

**Decision:** Keep separate, names are clear ✓

### Category: Comprehensions

#### Current: `xnkComprehensionExpr`, `xnkGeneratorExpr`
**Problem:** These might be the same thing!

**Python:**
```python
[x*2 for x in range(10)]       # List comprehension → xnkComprehensionExpr
(x*2 for x in range(10))       # Generator expression → xnkGeneratorExpr
```

**Semantic difference:**
- Comprehension = Build entire collection immediately
- Generator = Lazy evaluation, produces values on demand

**Proposal:** Keep separate
- **`xnkComprehensionExpr`** = Eager collection building
- **`xnkGeneratorExpr`** = Lazy iteration

**Alternative names:**
- `xnkCollectionBuilder` vs `xnkLazyIterator`
- But current names are fine

### Category: Loops

#### Current: `xnkForStmt`, `xnkWhileStmt`, `xnkDoWhileStmt`, `xnkForeachStmt`
**Analysis:**
- `xnkForStmt` = C-style for loop (init; cond; incr)
- `xnkForeachStmt` = Iteration over collection
- `xnkWhileStmt` = Condition-based loop
- `xnkDoWhileStmt` = Post-test loop

**Proposals:**

**Option 1: More explicit**
```nim
xnkCountingLoop    # C-style for
xnkIterationLoop   # foreach
xnkConditionalLoop # while
xnkPostTestLoop    # do-while
```

**Option 2: Keep traditional names (current)**
- They're universally understood
- No ambiguity

**Decision:** Keep current names, they're fine

## Summary of Proposed Changes

### High Priority (Semantic Clarity Needed)

1. **Yield → Iterator operations**
   ```nim
   xnkYieldStmt      → xnkIteratorYield
   xnkYieldFromStmt  → xnkIteratorDelegate
   xnkYieldExpr      → xnkCoroutineReceive (or keep separate if truly different)
   ```

2. **Resource management** (already planned)
   ```nim
   xnkWithStmt + xnkUsingStmt → xnkResourceStmt
   ```

3. **Exception handling** (already planned)
   ```nim
   xnkThrowStmt → xnkRaiseStmt (unify)
   ```

### Medium Priority (Consider)

4. **Defer naming**
   ```nim
   xnkDeferStmt → xnkOnScopeExit  (more explicit)
   # OR keep xnkDeferStmt (concise, clear enough)
   ```

### Low Priority (Fine as-is)

- Control flow (if, while, for, foreach) ✓
- Null safety operators ✓
- Type operations ✓
- Most expressions ✓

## Naming Convention Rules

1. **Use full words, not abbreviations**
   - Good: `xnkIteratorYield`
   - Bad: `xnkIterYld`

2. **Be verb-based for actions**
   - Good: `xnkProduceValue`, `xnkRaiseException`
   - Okay: `xnkIteratorYield` (noun + verb)

3. **Be noun-based for data**
   - Good: `xnkResourceStmt`, `xnkIteratorDelegate`

4. **Avoid language-specific terminology**
   - Bad: `xnkWithStmt` (Python-specific)
   - Good: `xnkResourceStmt` (semantic meaning)

5. **When in doubt, be more explicit**
   - Better to be verbose and clear than concise and confusing
   - `xnkIteratorYield` > `xnkYield`

## Implementation Strategy

Same as node unification:
1. Add new names alongside old
2. Deprecate old names
3. Update parsers
4. Update transforms
5. Remove old names

## Review Checklist

Before renaming any node:
- [ ] Does the new name describe the semantic behavior?
- [ ] Is it unambiguous across all languages?
- [ ] Would a newcomer understand it without context?
- [ ] Does it avoid language-specific jargon?
- [ ] Is it consistent with other node names?
