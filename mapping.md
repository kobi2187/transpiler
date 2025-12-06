Got it — I looked at both files.
Here’s the straight-shooting truth: **you’ve already got 95% of the information you need to build your mapper**, because:

1. `xlangtypes.nim` gives you a giant `XNodeKind` enum.
2. `my_nim_node.nim` gives you your private `MyNodeKind` enum + constructors.

So the game is simply:
**For each XLang/C#/Python construct → pick the Nim AST form it should lower to → build the corresponding MyNode.**

And since you’ve already got lowering passes, this mapper becomes the “final mile.”

Below is exactly what you need:

* A clean mapping table
* Tiny input examples
* Expected Nim code
* And the **`proc xlangToNimNode*(x: XNode): MyNode` skeleton** wired with a big `case` ready for you to fill.

No fluff, no mysticism.

---

# ✅ **MASTER MAPPING TABLE (C#, Python, XLang → Nim)**

### Legend

* ✔ = Mapped
* discard = No sane Nim equivalent → becomes `nnkDiscardStmt`
* ⌀ = not representable in Nim (but you can simulate in lowering pass)

Below is a **tight, practical table** — the things that really map to Nim AST.

---

# **I. DECLARATIONS**

| XLang Kind             | Example Input                                    | Output Nim Code                            | AST Node                     |
| ---------------------- | ------------------------------------------------ | ------------------------------------------ | ---------------------------- |
| IteratorDecl           | C#: `IEnumerable<int> Foo() { yield return 3; }` | `iterator foo(): int = yield 3`            | `nnkIteratorDef`             |
| PropertyDecl           | C#: `int X { get; set; }`                        | `{.get: getX, set: setX.}` or just methods | ⌀ → lowered into procs       |
| FieldDecl              | `int x;`                                         | `var x: int`                               | `nnkVarSection`              |
| ConstructorDecl        | `MyClass() { ... }`                              | `proc initMyClass(): MyClass =`            | `nnkProcDef`                 |
| DestructorDecl         | `~MyClass()`                                     | destructor not in Nim                      | discard                      |
| DelegateDecl           | `delegate void D(int x);`                        | `type D = proc(x:int)`                     | `nnkTypeDef`+`nnkProcTy`     |
| EventDecl              | `event Action Foo;`                              | discard                                    | discard                      |
| ModuleDecl             | Python: module                                   | `import xyz` or a block                    | `nnkStmtList`                |
| TypeAlias              | `using X = Y;`                                   | `type X = Y`                               | `nnkTypeDef`                 |
| AbstractDecl           | abstract methods                                 | discard                                    | discard                      |
| EnumMember             | `Red = 1`                                        | `Red = 1`                                  | `nnkEnumFieldDef`            |
| IndexerDecl            | `int this[int i] {get;}`                         | proc getItem                               | ⌀ lowered                    |
| OperatorDecl           | `static T operator+(...)`                        | `proc `+``                                 | `nnkProcDef`                 |
| ConversionOperatorDecl | `implicit operator int(X)`                       | `proc toInt(x:X): int`                     | proc                         |
| AbstractType           | same                                             | discard                                    |                              |
| FunctionType           | `func(int)->int`                                 | `type F = proc(x:int):int`                 | `nnkProcTy`                  |
| Metadata               | attributes                                       | discard or store                           | discard                      |
| LibDecl                | XLang lib                                        | `importc` wrapper                          | `nnkProcDef` or `nnkTypeDef` |
| CFuncDecl              | `extern "C" foo(int)`                            | `proc foo(x:int){.importc.}`               | `nnkProcDef`                 |
| ExternalVar            | external global                                  | `var x {.importc.}: int`                   | `nnkVarSection`              |

---

# **II. STATEMENTS**

| XLang Kind            | Example Input                     | Nim                              | AST                        |                 |       |
| --------------------- | --------------------------------- | -------------------------------- | -------------------------- | --------------- | ----- |
| Asgn                  | `x = y`                           | `x = y`                          | `nnkAsgn`                  |                 |       |
| SwitchStmt            | C#: `switch(x){case 1:...}`       | `case x:`                        | `nnkCaseStmt`              |                 |       |
| CaseClause            | `case 3:`                         | Nim case branch                  | `nnkOfBranch`              |                 |       |
| DefaultClause         | `default:`                        | `else:`                          | `nnkElse`                  |                 |       |
| DoWhileStmt           | `do {...} while(x)`               | Nim has no do-while              | emulate or discard         |                 |       |
| ForeachStmt           | `foreach(var x in arr)`           | `for x in arr:`                  | `nnkForStmt`               |                 |       |
| CatchStmt             | `catch(Exception e)`              | `except e:`                      | `nnkExceptBranch`          |                 |       |
| FinallyStmt           | `finally`                         | `finally:`                       | `nnkFinally`               |                 |       |
| YieldExpr             | `yield x`                         | `yield x`                        | `nnkYieldStmt`             |                 |       |
| YieldFromStmt         | Python `yield from y`             | emulate: `for v in y: yield v`   | lowered                    |                 |       |
| BreakStmt             | `break`                           | `break`                          | `nnkBreakStmt`             |                 |       |
| ContinueStmt          | `continue`                        | `continue`                       | `nnkContinueStmt`          |                 |       |
| ThrowStmt             | C#: `throw e`                     | `raise e`                        | `nnkRaiseStmt`             |                 |       |
| AssertStmt            | `assert x`                        | `assert x`                       | `nnkAsgn`? No → `nnkCall ' | assert          | '`    |
| WithStmt              | Python `with x:`                  | scope helper                     | discard or lower           |                 |       |
| PassStmt              | Python `pass`                     | discard                          | `nnkDiscardStmt`           |                 |       |
| TypeSwitchStmt        | Go-style                          | Nim has no type switch           | lower                      |                 |       |
| WithItem              | part of `with`                    | discard                          |                            |                 |       |
| EmptyStmt             | `;`                               | empty                            | `nnkEmpty`                 |                 |       |
| LabeledStmt           | `myLabel:`                        | discard                          |                            |                 |       |
| GotoStmt              | `goto X`                          | no goto                          | discard                    |                 |       |
| FixedStmt             | C# fixed                          | unsafe                           | discard                    |                 |       |
| LockStmt              | `lock(x)`                         | no lock                          | discard                    |                 |       |
| UnsafeStmt            | unsafe block                      | Nim has `{.emit.}` maybe         | discard                    |                 |       |
| CheckedStmt           | checked/unchecked                 | Nim has range checks             | discard                    |                 |       |
| LocalFunctionStmt     | local func                        | Nim nested proc                  | `nnkProcDef`               |                 |       |
| UnlessStmt            | `unless x:`                       | lower to `if not x:`             |                            |                 |       |
| UntilStmt             | `repeat until x`                  | lower                            |                            |                 |       |
| StaticAssert          | compile-time                      | `static:` assert                 | nnkStaticStmt              |                 |       |
| SwitchCase            | variant                           | `case`                           | same                       |                 |       |
| MixinDecl             | mixin                             | Nim mixin                        | `nnkMixinStmt`             |                 |       |
| TemplateDecl          | template                          | Nim template                     | `nnkTemplateDef`           |                 |       |
| MacroDecl             | macro                             | Nim macro                        | `nnkMacroDef`              |                 |       |
| Include               | include                           | `include "x"`                    | `nnkIncludeStmt`           |                 |       |
| Extend                | extension                         | lower                            |                            |                 |       |
| TernaryExpr           | `cond ? a : b`                    | `if cond: a else: b`             | `nnkIfExpr`                |                 |       |
| SliceExpr             | `x[1..3]`                         | same                             | `nnkSlice`                 |                 |       |
| SafeNavigationExpr    | `x?.y`                            | `if x != nil: x.y else: default` | lower                      |                 |       |
| NullCoalesceExpr      | `x ?? y`                          | `if x != nil: x else: y`         | lower                      |                 |       |
| ConditionalAccessExpr | C# conditional call               | lower                            |                            |                 |       |
| LambdaExpr            | `x => x+1`                        | `(x:int) => x+1`                 | `nnkLambda`                |                 |       |
| TypeAssertion         | TS `x as T`                       | cast                             | `nnkCast`                  |                 |       |
| CastExpr              | `(T)x`                            | `T(x)`                           | `nnkCast`                  |                 |       |
| ThisExpr              | `this`                            | `self`                           | `nnkIdent`                 |                 |       |
| BaseExpr              | `base.foo()`                      | low-level base call              | lower                      |                 |       |
| RefExpr               | ref                               | `addr x`                         | `nnkAddr`                  |                 |       |
| InstanceVar           | `obj.x`                           | dot call                         | `nnkDotExpr`               |                 |       |
| ClassVar              | static                            | `Type.x`                         | `nnkDotExpr`               |                 |       |
| GlobalVar             | global                            | ident                            | `nnkIdent`                 |                 |       |
| ProcLiteral           | Python def inside expr            | lambda or nested                 | `nnkLambda`                |                 |       |
| ProcPointer           | pointer                           | `proc` type                      | `nnkPtrTy`                 |                 |       |
| ArrayLit              | `[1,2]`                           | `[1,2]`                          | `nnkBracket`               |                 |       |
| NumberLit             | `123`                             | `123`                            | literal node               |                 |       |
| SymbolLit             | special                           | discard or treat as ident        |                            |                 |       |
| DynamicType           | dynamic                           | discard                          |                            |                 |       |
| GeneratorExpr         | `(x*x for x in y)`                | Nim comprehension                | `collect(for x in y: x*x)` |                 |       |
| AwaitExpr             | `await x`                         | async                            | Nim `await`                | `nnkPragmaExpr` |       |
| StringInterpolation   | `$"hi {x}"`                       | &"hi {x}"                        | `nnkInfix '&'`             |                 |       |
| CompFor               | comp                              | as above                         | `collect`                  |                 |       |
| DefaultExpr           | default(T)                        | `default(T)`                     | `nnkCall`                  |                 |       |
| TypeOfExpr            | typeof(T)                         | `T`                              | ident                      |                 |       |
| SizeOfExpr            | sizeof(T)                         | `sizeof(T)`                      | `nnkCall`                  |                 |       |
| CheckedExpr           | checked                           | lower                            |                            |                 |       |
| ThrowExpr             | `throw` in expr                   | raise                            | same                       |                 |       |
| SwitchExpr            | switch returning value            | `case` expr                      | lower                      |                 |       |
| StackAllocExpr        | stackalloc                        | Nim doesn't                      | discard                    |                 |       |
| ImplicitArrayCreation | new[]{1,2}                        | `[1,2]`                          | node                       |                 |       |
| NoneLit               | None                              | `nil`                            | literal nil                |                 |       |
| NamedType             | type name                         | ident                            | `nnkIdent`                 |                 |       |
| ArrayType             | `int[]`                           | `array[...]`                     | `nnkBracketExpr`           |                 |       |
| MapType               | `Dictionary<K,V>`                 | `Table[K,V]`                     | `nnkBracketExpr`           |                 |       |
| FuncType              | `(A)->B`                          | `proc(a:A):B`                    | `nnkProcTy`                |                 |       |
| PointerType           | `int*`                            | `ptr int`                        | `nnkPtrTy`                 |                 |       |
| ReferenceType         | `ref T`                           | `ref T`                          | `nnkRefTy`                 |                 |       |
| GenericType           | `List<T>`                         | `List[T]`                        | `nnkBracketExpr`           |                 |       |
| UnionType             | `A                                | B`                               | distinct union             | Nim no union    | lower |
| IntersectionType      | `A&B`                             | type constraints                 | lower                      |                 |       |
| DistinctType          | `distinct int`                    | `distinct int`                   | `nnkDistinctTy`            |                 |       |
| Attribute             | annotation                        | discard                          |                            |                 |       |
| Parameter             | function arg                      | param                            | `nnkIdentDefs`             |                 |       |
| Argument              | passed arg                        | `x`                              | expr                       |                 |       |
| Decorator             | Python decorator                  | pragma or lower                  | discard                    |                 |       |
| LambdaProc            | special                           | `proc` literal                   | nnkLambda                  |                 |       |
| ArrowFunc             | javascript-like → treat as lambda | nnkLambda                        |                            |                 |       |
| ConceptRequirement    | typeclass constraint              | Nim concept                      | `nnkConceptDef`            |                 |       |
| QualifiedName         | `a.b.c`                           | dotted ident                     | `nnkDotExpr`               |                 |       |
| AliasQualifiedName    | alias.x                           | same                             |                            |                 |       |
| GenericName           | T<T>                              | bracket                          | `nnkBracketExpr`           |                 |       |
| Unknown               | ?                                 | discard                          |                            |                 |       |
| ConceptDecl           | concept                           | Nim concept                      | `nnkConceptDef`            |                 |       |
| DestructureObj        | `{a,b} = obj`                     | `(a,b) = obj`                    | tuple destruct             |                 |       |
| DestructureArray      | `[a,b]=arr`                       | same                             | `nnkVarTuple`              |                 |       |
| MethodReference       | `obj.Method`                      | `obj.Method`                     | `nnkDotExpr`               |                 |       |
| ListExpr              | `[1,2]`                           | same                             | bracket                    |                 |       |
| SetExpr               | `{1,2}`                           | Nim set                          | `nnkCurly`                 |                 |       |
| TupleExpr             | `(a,b)`                           | `(a,b)`                          | `nnkTupleConstr`           |                 |       |
| DictExpr              | `{a:1}`                           | `{a:1}`                          | `nnkTableConstr`           |                 |       |
| ComprehensionExpr     | `[x*x for x in y]`                | collect                          | call                       |                 |       |
| DictEntry             | `a:1`                             | table entry                      | `nnkExprColonExpr`         |                 |       |

---

# ✅ **NIMCODE: The Mapper Skeleton**

```nim
proc xlangToNimNode*(x: XNode): MyNode =
  ## Convert any XLang AST node into our MyNode AST.
  case x.kind

  of xnkIteratorDecl:
    result = nnkIteratorDef.newNode(@[
      newIdentNode(x.name),
      paramsFromX(x),
      bodyFromX(x.body)
    ])

  of xnkFieldDecl:
    result = nnkVarSection.newNode(@[
      nnkIdentDefs.newNode(@[
        newIdentNode(x.name),
        typeFromX(x.typ),
        defaultFromX(x.init)
      ])
    ])

  of xnkAsgn:
    result = nnkAsgn.newNode(@[
      xlangToNimNode(x.lhs),
      xlangToNimNode(x.rhs)
    ])

  of xnkSwitchStmt:
    result = nnkCaseStmt.newNode(@[
      xlangToNimNode(x.expr)
    ] & mapIt(x.cases, xlangToNimNode(it)) & 
      (if x.defaultCase != nil: @[xlangToNimNode(x.defaultCase)] else: @[]))

  of xnkCaseClause:
    result = nnkOfBranch.newNode(@[
      xlangToNimNode(x.value),
      stmtListFromX(x.body)
    ])

  of xnkDefaultClause:
    result = nnkElse.newNode(@[ stmtListFromX(x.body) ])

  of xnkLambdaExpr:
    result = nnkLambda.newNode(@[
      paramsFromX(x),
      bodyFromX(x.body)
    ])

  of xnkArrayLit:
    result = nnkBracket.newNode(x.items.mapIt(xlangToNimNode(it)))

  of xnkNumberLit:
    result = newIntLitNode(x.intVal)

  # --- and so on for all mapped items ----

  else:
    # Not applicable / no Nim equivalent
    result = nnkDiscardStmt.newNode(@[])
```

---

# If you want:

I can also generate a **complete file** containing:

* full mapping table
* complete Nim source file
* helper constructors (`paramsFromX`, `bodyFromX`, etc.)
* a test suite covering each mapping

Just say:
**“Generate the full implementation file.”**

I'll hammer it out cleanly.
