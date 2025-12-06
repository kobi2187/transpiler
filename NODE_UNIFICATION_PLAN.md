# Node Unification Implementation Plan

## Naming Philosophy

Before unification, ensure canonical names are **semantic, not syntactic**.

**Bad names:** Language-specific syntax (`xnkWithStmt`, `xnkUsingStmt`)
**Good names:** Semantic purpose (`xnkResourceStmt`)

**Bad names:** Overloaded terms (`xnkYieldStmt` - means different things!)
**Good names:** Explicit context (`xnkIteratorYield`, `xnkCoroutineReceive`)

See CANONICAL_NAMES.md for full naming guidelines.

## Priority Order

### P0: Critical - Resource Management (with/using)
These are actively causing duplicate transform passes and maintenance burden.

**Action Items:**
1. [ ] Design `xnkResourceStmt` schema in xlangtypes.nim
2. [ ] Add `xnkResourceStmt` and `xnkResourceItem` (keep old nodes temporarily)
3. [ ] Update C# parser to emit `xnkResourceStmt`
4. [ ] Update Python parser to emit `xnkResourceStmt`
5. [ ] Create unified `resource_to_defer.nim` transform
6. [ ] Test thoroughly with C# and Python examples
7. [ ] Mark `xnkWithStmt` and `xnkUsingStmt` as deprecated
8. [ ] Remove deprecated nodes after one release cycle

### P1: High - Exception Handling (throw/raise)
Simple unification, low risk.

**Action Items:**
1. [ ] Update C# parser: `throw` → emit `xnkRaiseStmt` instead of `xnkThrowStmt`
2. [ ] Update Java parser (if exists): same
3. [ ] Update xlangtonim.nim to handle `xnkRaiseStmt` only
4. [ ] Remove `xnkThrowStmt` from xlangtypes.nim
5. [ ] Update `conv_xnkThrowStmt` → `conv_xnkRaiseStmt`

### P2: Medium - Safe Navigation Deduplication
Remove redundant `xnkConditionalAccessExpr`.

**Action Items:**
1. [ ] Audit C# parser usage of `xnkConditionalAccessExpr`
2. [ ] Replace all with `xnkSafeNavigationExpr`
3. [ ] Remove `xnkConditionalAccessExpr` from xlangtypes.nim
4. [ ] Ensure null_coalesce.nim transform handles both cases

### P3: Medium - Yield Disambiguation
The word "yield" is overloaded and confusing.

**Action Items:**
1. [ ] Analyze usage of `xnkYieldStmt` in parsers
   - Is it for generators/iterators? → rename to `xnkIteratorYield`
   - Is it for coroutines? → rename to `xnkCoroutineYield`
2. [ ] Analyze `xnkYieldExpr` usage
   - Generator value? → merge with `xnkIteratorYield`
   - Coroutine receive? → rename to `xnkCoroutineReceive`
3. [ ] Analyze `xnkYieldFromStmt` (Python's `yield from`)
   - Rename to `xnkIteratorDelegate` (more descriptive)
4. [ ] Update all parsers with new canonical names
5. [ ] Update xlangtonim.nim converter functions
6. [ ] Update transform passes

**Goal:** Make it immediately clear what kind of yield/suspension is happening

### P4: Low - Future Considerations
Review and document, but don't act yet.

**Items:**
- Lambda expression variants (xnkLambdaExpr, xnkArrowFunc, xnkLambdaProc)
- Investigate if they have semantic differences
- Member access variants (xnkMemberAccessExpr, xnkDotExpr)
- May be intentionally separate
- Defer vs OnScopeExit naming

## Testing Strategy

For each unification:

1. **Parser Tests**
   - Verify old source code still parses correctly
   - Check that XLang output uses new unified nodes

2. **Transform Tests**
   - Test transform passes with unified nodes
   - Ensure both language sources produce same transform output

3. **End-to-End Tests**
   - C# with/using → Nim defer
   - Python with → Nim defer
   - Verify generated Nim code is identical

4. **Regression Tests**
   - Run full test suite
   - Check Mono test files still work

## Schema Design: xnkResourceStmt

```nim
# In xlangtypes.nim:

of xnkResourceStmt:
  ## Unified resource management with automatic cleanup
  ## Covers: Python 'with', C# 'using', Java 'try-with-resources'
  resourceItems*: seq[XLangNode]
  resourceBody*: XLangNode

of xnkResourceItem:
  ## Individual resource acquisition in a resource statement
  resourceExpr*: XLangNode           # Expression that acquires the resource
  resourceVar*: Option[XLangNode]    # Variable to bind resource to (as x)
  cleanupHint*: Option[string]       # Hint for cleanup: "close", "dispose", etc.
```

**Examples:**

Python:
```python
with open("file.txt") as f, open("file2.txt") as g:
    process(f, g)
```
→
```nim
XLangNode(
  kind: xnkResourceStmt,
  resourceItems: @[
    XLangNode(
      kind: xnkResourceItem,
      resourceExpr: call(open, "file.txt"),
      resourceVar: some(ident("f")),
      cleanupHint: some("close")
    ),
    XLangNode(
      kind: xnkResourceItem,
      resourceExpr: call(open, "file2.txt"),
      resourceVar: some(ident("g")),
      cleanupHint: some("close")
    )
  ],
  resourceBody: call(process, f, g)
)
```

C#:
```csharp
using (var file = File.Open("data.txt"))
{
    Process(file);
}
```
→
```nim
XLangNode(
  kind: xnkResourceStmt,
  resourceItems: @[
    XLangNode(
      kind: xnkResourceItem,
      resourceExpr: call(File.Open, "data.txt"),
      resourceVar: some(varDecl("file")),
      cleanupHint: some("Dispose")
    )
  ],
  resourceBody: call(Process, file)
)
```

## Unified Transform: resource_to_defer.nim

```nim
proc transformResourceToDefer*(node: XLangNode): XLangNode =
  if node.kind != xnkResourceStmt:
    return node

  var stmts: seq[XLangNode] = @[]

  # Process each resource
  for item in node.resourceItems:
    # 1. Variable declaration (if binding exists)
    if item.resourceVar.isSome:
      let varNode = item.resourceVar.get
      stmts.add(XLangNode(
        kind: xnkLetDecl,
        declName: extractName(varNode),
        initializer: some(item.resourceExpr)
      ))

      # 2. Defer cleanup
      let cleanupMethod = item.cleanupHint.get("close")  # default
      stmts.add(XLangNode(
        kind: xnkDeferStmt,
        staticBody: call(
          dot(ident(extractName(varNode)), cleanupMethod)
        )
      ))
    else:
      # Resource without binding - just acquire/release
      let tempName = genSym("resource")
      stmts.add(letDecl(tempName, item.resourceExpr))
      stmts.add(defer(call(dot(tempName, "close"))))

  # 3. Add body
  stmts.add(node.resourceBody)

  result = XLangNode(kind: xnkBlockStmt, blockBody: stmts)
```

## Migration Path

### Phase 1: Add (non-breaking)
- Add new unified nodes
- Keep old nodes working
- Update parsers to optionally emit new nodes (flag-controlled)

### Phase 2: Dual Support
- xlangtonim.nim handles both old and new
- Transforms work with both
- Deprecation warnings for old nodes

### Phase 3: Switch Default
- Parsers emit new nodes by default
- Old nodes require explicit flag
- Update all documentation

### Phase 4: Remove
- Delete old node kinds
- Delete compatibility shims
- Clean up codebase

## Success Criteria

- [ ] Zero test failures
- [ ] All Mono C# tests pass
- [ ] All Python tests pass
- [ ] Generated Nim code quality unchanged or improved
- [ ] Codebase has fewer lines of code
- [ ] Transform passes reduced by at least 2
- [ ] Documentation updated

## Risks and Mitigation

**Risk:** Breaking existing parsers
- **Mitigation:** Phased rollout, feature flags, extensive testing

**Risk:** Semantic differences we haven't discovered
- **Mitigation:** Deep analysis of language specs, community review

**Risk:** Performance impact from additional indirection
- **Mitigation:** Benchmark before/after, optimize if needed

## Timeline Estimate

- P0 (Resource Management): 2-3 days
- P1 (throw/raise): 1 day
- P2 (Safe Navigation): 1 day
- Testing and polish: 2 days

**Total:** ~1 week of focused work
