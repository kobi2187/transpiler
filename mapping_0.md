Nice — big, useful mapping. I’ll give a compact, practical cheat-sheet you can use when writing a transpiler from C#/Python/XLang → Nim.
I’ll:

* show a tiny input snippet (C# / Python / XLang where relevant),
* show the Nim source you’d want, and
* show a **conceptual** `NimNode` AST construction (a small, consistent pseudo-API you can implement against Nim’s compiler AST helpers).

**Important:** the `NimNode` snippets below use a compact, illustrative builder API (so you can read quickly and adapt to your actual `ast` helpers). Legend:

* `newNode(kind, children...)` — make a new NimNode with `kind` (e.g. `nnkProc`, `nnkIdent`, `nnkCall`, `nnkConst`, `nnkIfStmt`, etc.).
* `ident("name")` — identifier node.
* `lit(val)` — literal node (number/string/none).
* `typeNode("T")` — type name node.
* `params((name, type), ...)` — parameter list builder.
* `body(...)` — block/stmtlist builder.
* `setAttr(node, "key", value)` — attach attributes/meta (conceptual).
* The exact token names (`nnkProc`, `nnkVarSection`, ...) vary in the compiler; treat the following nodes as **pseudo-code** to be translated to the real Nim compiler constructors in your transpiler.

If something truly doesn’t exist in Nim (semantic mismatch), I’ll mark **discard**.

---

# 1 — Declarations & types

### FieldDecl

C#

```csharp
public int x = 5;
```

Python

```python
x = 5  # module var
```

XLang (imagined)

```xlang field int x = 5
```

Nim:

```nim
var x: int = 5
```

NimNode:

```nim
newNode(nnkVarSection,
  newNode(nnkIdentDefs,
    newNode(nnkIdent, ident("x")),
    typeNode("int"),
    lit(5)
  )
)
```

---

### PropertyDecl (C#)

C#

```csharp
public int Count { get; private set; }
```

Nim source (property ~ pair of procs or `getter`/`setter`):

```nim
var Count: int

proc `=Count`(v: int) = Count = v
proc Count(): int = Count
```

NimNode (conceptual — property becomes var + procs):

```nim
varNode = newNode(nnkVar, ident("Count"), typeNode("int"))
getter = newNode(nnkProc, ident("Count"), params(), body(newNode(nnkReturn, ident("Count"))))
setter = newNode(nnkProc, ident("=Count"), params(("v", typeNode("int"))), body(newNode(nnkAsgn, ident("Count"), ident("v"))))
```

---

### ConstructorDecl

C#

```csharp
public C(int x) { this.x = x; }
```

Nim:

```nim
type C = object
  x: int

proc newC(x: int): C =
  result = C(x: x)
```

NimNode:

```nim
typeNode = newNode(nnkObjectTy, ident("C"),
                    newNode(nnkField, ident("x"), typeNode("int")))

ctor = newNode(nnkProc, ident("newC"), params(("x", typeNode("int"))),
               body(
                 newNode(nnkLet, ident("result"), newNode(nnkCall, ident("C"),
                   newNode(nnkNamed, ident("x"), ident("x"))
                 ))
               ))
```

---

### DestructorDecl

C# (finalizer)

```csharp
~C() { /* cleanup */ }
```

Nim: no destructors — use `defer`/`finalize` patterns or ref object `destroy` methods. So: **discard** (semantic) — translate to `proc finalize(c: var C)` or put cleanup in `defer` where used.

NimNode: `discard`

---

### DelegateDecl

C#

```csharp
public delegate int D(string s);
```

Nim:

```nim
type D = proc (s: string): int
```

NimNode:

```nim
newNode(nnkTypeSection,
  newNode(nnkIdentDefs,
    ident("D"),
    newNode(nnkProcTy, params(("s", typeNode("string"))), typeNode("int"))
  )
)
```

---

### EventDecl

C#

```csharp
public event EventHandler Changed;
```

Nim: translate to a proc list/observer pattern or `var Changed: proc(...)` or `seq[proc]`. Example:

```nim
var Changed: seq[proc(sender: RootObj, args: EventArgs)]
```

NimNode: build `var` with seq of proc type. (Not builtin event semantics) — conceptual.

---

### ModuleDecl

C#/Python module → Nim module file.
C# `namespace N { ... }` → Nim `module` or `namespace` mapping: Nim file = module.

NimNode: module is top-level node list; treat as root `nnkModule` containing nodes.

---

### TypeAlias

C#

```csharp
using Int = System.Int32;
```

Python

```python
Int = int
```

Nim:

```nim
type Int = int
```

NimNode:

```nim
newNode(nnkTypeSection,
  newNode(nnkIdentDefs, ident("Int"), typeNode("int"))
)
```

---

### AbstractDecl

C#/XLang `abstract class A {}`
Nim: `type A = ref object of RootObj` + `# mark abstract by convention` or use `concepts` or proc stubs. If pure-virtual needed, use `discard`/protocol pattern. Provide approximate translation.

---

### EnumMember

C#

```csharp
enum E { A = 1, B = 2 }
```

Nim:

```nim
type E = enum
  A = 1
  B = 2
```

NimNode:

```nim
newNode(nnkTypeSection,
  newNode(nnkIdentDefs, ident("E"),
    newNode(nnkEnumTy,
      newNode(nnkEnumMember, ident("A"), lit(1)),
      newNode(nnkEnumMember, ident("B"), lit(2))
    )
  )
)
```

---

### IndexerDecl

C#

```csharp
public int this[int i] { get { return a[i]; } set { a[i] = value; } }
```

Nim: translate to `proc get(i: int): int` / `proc set(i: int, v: int)` or operator `[]` via `[]`/`[]=` procs on types.
Nim example:

```nim
proc `[]`(s: SomeSeq, i: int): int = ...
proc `[]=`(s: var SomeSeq, i: int, v: int) = ...
```

NimNode: create procs named `[]` and `[]=`.

---

### OperatorDecl / ConversionOperatorDecl

C#

```csharp
public static SomeType operator+(SomeType a, SomeType b) { ... }
public static explicit operator int(SomeType a) { ... }
```

Nim:

```nim
proc `+`(a, b: SomeType): SomeType = ...
proc toInt(a: SomeType): int = ...
```

NimNode: proc node with ident("`+`") or ident("toInt").

---

### AbstractType

If XLang has `abstract` type, translate to Nim `ref object` protocol or a `concept`. If language requires runtime abstract methods, model as `proc` that raises `not implemented`. (Conceptual)

---

### FunctionType

C#/Python function type → Nim `proc` type:

```nim
type F = proc(x: int): int
```

NimNode:

```nim
newNode(nnkTypeSection,
  newNode(nnkIdentDefs, ident("F"),
    newNode(nnkProcTy, params(("x", typeNode("int"))), typeNode("int"))
  )
)
```

---

### Metadata / Attribute

C# `[Obsolete]` etc. Nim uses `{.deprecated.}` or pragmas. Map attributes to pragmas or attach `setAttr(node, ...)`.
If cannot map: preserve as comment or annotation.

NimNode:

```nim
setAttr(procNode, "deprecated", true)
```

---

### LibDecl / CFuncDecl / ExternalVar

C#

```csharp
[DllImport("lib")] public static extern int foo(int x);
```

Nim:

```nim
proc foo(x: cint): cint {.importc: "foo", dynlib: "lib".}
```

NimNode:

```nim
newNode(nnkProc, ident("foo"), params(("x", typeNode("cint"))), typeNode("cint"))
setAttr(node, "importc", "foo")
setAttr(node, "dynlib", "lib")
```

---

# 2 — Statements & control-flow

### Asgn (assignment)

C#/Python:

```csharp
x = y + 1;
```

Nim:

```nim
x = y + 1
```

NimNode:

```nim
newNode(nnkAsgn, ident("x"), newNode(nnkInfix, "+", ident("y"), lit(1)))
```

---

### SwitchStmt / CaseClause / DefaultClause

C# switch:

```csharp
switch(x) {
 case 1: foo(); break;
 default: bar(); break;
}
```

Nim:

```nim
case x:
of 1: foo()
else: bar()
```

NimNode:

```nim
newNode(nnkCaseStmt, ident("x"),
  newNode(nnkOfBranch, lit(1), body(newNode(nnkCall, ident("foo")))),
  newNode(nnkElseBranch, body(newNode(nnkCall, ident("bar"))))
)
```

---

### DoWhileStmt

C#:

```csharp
do { body(); } while(cond);
```

Nim:

```nim
while true:
  body()
  if not cond: break
```

NimNode: translate to `nnkWhileStmt` with `true` and internal conditional break, or `nnkDoWhile` if supported. Conceptual.

---

### ForeachStmt

C#/Python:

```csharp
foreach(var t in seq) { ... }
```

Nim:

```nim
for t in seq:
  ...
```

NimNode:

```nim
newNode(nnkForInStmt, ident("t"), ident("seq"), body(...))
```

---

### CatchStmt / FinallyStmt / Try

C#/Python:

```csharp
try { ... } catch (E e) { ... } finally { ... }
```

Nim:

```nim
try:
  ...
except E as e:
  ...
finally:
  ...
```

NimNode: `nnkTryExcept` with child `except` branches and optional `finally`.

---

### YieldExpr / YieldFromStmt

Python `yield`:

```python
def gen():
  yield x
```

Nim has iterators/generators (`iterator`). Map Python generator to Nim `iterator` or to `seq` accumulation.
If generator semantics cannot be expressed simply: translate to `discard` or an `iterator`:

```nim
iterator gen(): int =
  yield x
```

NimNode:

```nim
newNode(nnkIterator, ident("gen"), params(), body(newNode(nnkYield, ident("x"))))
```

---

### BreakStmt / ContinueStmt

Direct mapping:
NimNode: `nnkBreak`, `nnkContinue`.

---

### ThrowStmt / ThrowExpr

C#/Python: `throw new Exception("x")` / `raise Exception("x")`
Nim:

```nim
raise newException(ValueError, "x")
```

NimNode:

```nim
newNode(nnkRaise, newNode(nnkCall, ident("newException"), lit("ValueError"), lit("x")))
```

---

### AssertStmt

Python: `assert x`
Nim:

```nim
assert x
```

NimNode: `nnkAssertStmt`

---

### WithStmt (Python)

Python:

```python
with open("f") as fh:
  ...
```

Nim: `with` exists but different — often `defer` pattern. Map to `try/finally` or `using` pattern. Conceptual translation:

```nim
let fh = open("f")
defer: fh.close()
...
```

NimNode: create `let` + `defer` or `try/finally`.

---

### PassStmt (Python)

Python `pass` → Nim `discard` (empty).
NimNode: `nnkEmptyStmt` or `nnkNoop`. Use `discard`.

---

### TypeSwitchStmt / TypeCaseClause

C# `switch (obj) { case A a: ... }`
Nim: pattern match via `when` generics or runtime `case` with RTTI using `of` and `is` checks. No direct equivalent; transpile to `if instance(of A, obj): let a = obj[].` Conceptual — implement with `is` checks.

---

### WithItem

Part of Python `with` context (resource expression). Map as described in WithStmt.

---

### EmptyStmt

No-op — `discard`. NimNode: `nnkEmptyStmt`.

---

### LabeledStmt / GotoStmt

C# supports `goto label`. Nim has `goto` but rarely used. You can map labels to `label:` and `goto label`. NimNode: `nnkLabel`, `nnkGoto`. If unreachable in Nim, `discard`.

---

### FixedStmt / LockStmt / UnsafeStmt / CheckedStmt

C# `fixed`, `lock`, `unsafe`, `checked`:

* `fixed` (pin memory) — Nim: manual; usually `discard` or `addr` usage.
* `lock` — Nim: use `lock myLock:` from `locks` module or `synchronized` proc; translate to `lock` block.
* `unsafe` — Nim has ` {.compile: "..." .}` not same; map to comment or `discard`.
* `checked` — arithmetic overflow checking: Nim pragmas `--overflow:error` at compile-time or use `checkedAdd`. Map to attribute or wrap with `try`.

For these, provide conceptual mapping, sometimes `discard`.

---

### LocalFunctionStmt

C# local function:

```csharp
void Outer() {
  int Inner() { return 1; }
}
```

Nim:

```nim
proc Outer() =
  proc Inner(): int = 1
```

NimNode: `nnkProc` inside another `nnkProc` body.

---

### UnlessStmt / UntilStmt

`Unless` (Ruby) — Nim: `if not cond: ...`. `Until` (loop until cond) — Nim has `while not cond:`. Map to `if not` / `while not`.

---

### StaticAssert

C# `static_assert` → Nim `static` checks or `static: assert` or `staticEcho`. Map to `static:` block.

NimNode: `nnkStaticStmt`.

---

### SwitchCase (alternate name)

Covered above.

---

### MixinDecl

Nim has `mixin` macro and `include`. If C#/XLang mixin, translate to `include` or use template/macro. NimNode: `nnkMixin` or `nnkInclude` depending.

---

### TemplateDecl / MacroDecl

C# macros — not present. Nim templates/macros should be used. Example:

```nim
template whileFalse(body) = ...
macro mymacro(a: untyped): untyped = ...
```

NimNode: `nnkTemplate`, `nnkMacro`.

---

### Include / Extend

`include "file.nim"` or module extension via `import`. Map XLang include to Nim `include` or `import`.

NimNode: `nnkInclude`.

---

# 3 — Expressions & operators

### TernaryExpr

C# `cond ? a : b` → Nim `if cond: a else: b` (expr)
NimNode:

```nim
newNode(nnkIfExpr, ident("cond"), ident("a"), ident("b"))
```

---

### SliceExpr

Python `a[1:3]` → Nim `a[1..2]` for sequences or `a[1:3]` for open ranges (use `a[1 ..< 3]` library) — implement as call to slice helper.
NimNode: `nnkIndex` with range node.

---

### SafeNavigationExpr / NullCoalesceExpr / ConditionalAccessExpr

C# `a?.b` / `a ?? b` / `a?.Method()`
Nim: use `if a != nil: a.b` or helpers:

```nim
let x = if a.isNil: default else: a.b
```

Null-coalesce: `a.getDefault(b)` or `if a != nil: a else: b`.
NimNode: lower to `if`/`isNil` checks.

---

### LambdaExpr / ArrowFunc / ProcLiteral

Python `lambda x: x+1` => Nim `proc (x: int): int = x + 1` or `x => x+1` with `func`? Nim uses anonymous procs:

```nim
let f = proc(x: int): int = x + 1
```

NimNode:

```nim
newNode(nnkProcLit, params(("x", typeNode("int"))), body(newNode(nnkInfix, "+", ident("x"), lit(1))))
```

---

### TypeAssertion / CastExpr

C# `(int)x` / Python `cast(int, x)`
Nim:

```nim
int(x)  # or cast[int](x)
```

NimNode:

```nim
newNode(nnkCall, ident("cast"), typeNode("int"), ident("x"))
```

---

### ThisExpr / BaseExpr

C# `this` / `base` → Nim `self` for methods; no `base` but call parent methods by name or `parentProc(obj)`. Map `this` → `self`. NimNode: `ident("self")`.

---

### RefExpr / PointerType / ReferenceType / PointerType

C# `ref`, `&` pointer → Nim `var`, `ptr T`, `ref T`. Map:

```nim
var p: ptr int
```

NimNode:

```nim
newNode(nnkPtrTy, typeNode("int"))
```

---

### InstanceVar / ClassVar / GlobalVar

C# instance field => inside `object` type; static/class var => `static` var at module level or `const`/`var`; map accordingly.

NimNode: `nnkField` in object; `nnkVarSection` for class var.

---

### ProcPointer / Function pointer

C# `IntPtr`/delegate → Nim `proc` type or `ptr proc` if needed. Use `proc` types as above.

---

### ArrayLit / ListExpr / SetExpr / TupleExpr / DictExpr / MapType

Python list/tuple/dict → Nim `@[ ... ]`, `(a, b)`, `{"k": v}` via `Table` or `initTable`.
Examples:

```nim
let a = @[1,2,3]
let t = (1, "x")
let d = {"k": "v"}  # not builtin; use Table[string, string] and initTable
```

NimNode: `nnkOpenArrayConstr`, `nnkTupleConstr`, `nnkTableConstr`.

---

### NumberLit / StringInterpolation / SymbolLit

Literals map directly. String interpolation: Nim uses `$` or `fmt` macros; translate to `$(...)` or `fmt"..."`. NimNode: `nnkStrLit` or `nnkStrFormat`.

---

### DynamicType / Any / Unknown

Map to `auto` or `any`/`JsonNode` or `pointer` depending. Nim has `system.Any` via `ref SystemNode`? Best map to `json` or `ref object` or `pointer`. If not applicable, keep as `discard` or `type Node = ref RootObj`.

---

### GeneratorExpr / AwaitExpr

`async/await` → Nim has `asyncdispatch` and `await`. Map to `async proc` and `await` call. Generators map to `iterator`.

NimNode: `nnkAsyncProc` and `nnkAwait`.

---

### ComprehensionExpr / CompFor / DictEntry

Python comprehensions -> build loops or use iterators to construct sequences. Translate to explicit loops filling arrays or tables.

---

# 4 — Type node families

### NoneLit

Python `None` → Nim `nil` or `none` if using option types. If option: `Option[T]` or `None` sentinel. NimNode: `lit(nil)`.

---

### NamedType / GenericType / GenericName / QualifiedName / AliasQualifiedName

Map generics: C# `List<int>` -> Nim `seq[int]` or `seq[int]`. Qualified names map to dotted identifiers `mod.name`. NimNode:

```nim
newNode(nnkQualIdent, ident("ns"), ident("T"))
newNode(nnkGenericType, ident("List"), typeNode("int"))
```

---

### ArrayType / MapType / FuncType / UnionType / IntersectionType / DistinctType

Map:

* `ArrayType` -> `seq[T]` or `array[NN, T]`
* `MapType` -> `Table[K,V]` or `TableRef[K,V]`
* `FuncType` -> `proc` type
* `UnionType` -> Nim `variant` object or `SomeUnion = distinct object` or `ref object` with union fields
* `IntersectionType` -> concept/constraints — map to `concept` or `where` constraints
* `DistinctType` -> Nim `distinct T`

NimNode: construct type nodes accordingly (nnkSeqTy, nnkTableTy, nnkProcTy, nnkDistinctTy, etc.)

---

### Attribute / Parameter / Argument / Decorator

Map C# attributes to Nim pragmas/comments; Python decorators -> Nim `@` not same — Nim macros can act as decorators: `mixin` or `template`. Parameters & arguments map directly to `params` and call argument nodes.

---

### LambdaProc / ArrowFunc

Covered under LambdaExpr. Use anonymous `proc` nodes.

---

### ConceptDecl / ConceptRequirement

XLang concepts -> Nim `concept`. Map requirements to `concept R = type T;` or `concept R[T] = ...`.

NimNode: `nnkConceptDecl` (conceptual).

---

### Unknown

If you cannot map a construct, output a node with a comment node:

```nim
newNode(nnkComment, lit("UNMAPPED: <original>"))
```

---

# 5 — Misc / advanced constructs (short notes)

* **MethodReference** (C# `Class::Method`) → map to `proc` reference `addr Method` or `cast[proc...]` where possible. NimNode: `nnkAddr`.
* **DestructureObj / DestructureArray** (Python tuple unpacking): `let (a,b) = t` — Nim supports destructuring for tuples: `let (a, b) = t`. NimNode: `nnkLet` with `nnkTuple`.
* **StackAllocExpr** (C# `stackalloc`) — Nim `alloca` or `stackAlloc` from `system` — advanced; map carefully or `discard`.
* **ImplicitArrayCreation** — transform to explicit array literal.
* **SafeNavigationExpr** — covered (null checks).
* **TypeOfExpr / SizeOfExpr** — Nim `typeof`/`sizeof` exist. NimNode: `nnkTypeOf`, `nnkSizeOf`.
* **CheckedExpr / ThrowExpr** — map to `try/except` or `raise`.
* **StringInterpolation** — translate to `fmt"{...}"` or build with `$()`; use `strformat`/`format` macro.

---

# 6 — When I wrote "discard"

When a construct is language/runtime specific and Nim has no natural equivalent (`DestructorDecl` finalizer semantics, some unmanaged `fixed` behaviors, exact `lock` semantics that need a runtime mapping, etc.), I wrote **discard** — meaning: don't generate a direct Nim AST node; instead either:

* transform semantics to an idiomatic Nim pattern (e.g. `destructor` → `defer`/`finalize`), or
* preserve as an annotation or comment for manual handling.

---

# Example concrete transform (end-to-end small example)

**Input (C#):**

```csharp
public class P {
  public int[] arr;
  public int this[int i] { get { return arr[i]; } set { arr[i] = value; } }
  public static int Sum(int[] a) {
    int s = 0;
    foreach(var x in a) s += x;
    return s;
  }
}
```

**Desired Nim:**

```nim
type P = object
  arr: seq[int]

proc `[]`(p: P; i: int): int = p.arr[i]
proc `[]=`(p: var P; i: int; v: int) = p.arr[i] = v

proc Sum(a: seq[int]): int =
  var s = 0
  for x in a:
    s += x
  return s
```

**Conceptual NimNode construction:**

```nim
# type
typeNode = newNode(nnkTypeSection,
  newNode(nnkIdentDefs, ident("P"),
    newNode(nnkObjectTy,
      newNode(nnkField, ident("arr"), newNode(nnkSeqTy, typeNode("int")))
    )
  )
)

# indexer getter
getNode = newNode(nnkProc,
  ident("[]"), params(("p", typeNode("P")), ("i", typeNode("int"))),
  typeNode("int"),
  body(
    newNode(nnkReturn,
      newNode(nnkIndex, newNode(nnkDot, ident("p"), ident("arr")), ident("i"))
    )
  )
)

# indexer setter
setNode = newNode(nnkProc,
  ident("[]="), params(("p", newNode(nnkVarTy, typeNode("P"))), ("i", typeNode("int")), ("v", typeNode("int"))),
  body(
    newNode(nnkInfix, "=", newNode(nnkIndex, newNode(nnkDot, ident("p"), ident("arr")), ident("i")), ident("v"))
  )
)

# Sum
sumNode = newNode(nnkProc,
  ident("Sum"), params(("a", newNode(nnkSeqTy, typeNode("int")))), typeNode("int"),
  body(
    newNode(nnkVarSection, newNode(nnkIdentDefs, ident("s"), typeNode("int"), lit(0))),
    newNode(nnkForInStmt, ident("x"), ident("a"),
      body(newNode(nnkInfix, "+=", ident("s"), ident("x")))),
    newNode(nnkReturn, ident("s"))
  )
)
```

---

# Closing / how to proceed

This is a compact, actionable mapping you can use to implement a transpiler. I intentionally kept the `NimNode` code **conceptual** and small so you can translate each to the actual tokens and constructors in your Nim compiler front-end (`newNimNode(nnk... )`, `nnkIdent`, `nnkProcDef`, etc.).

If you want, I can:

* convert any specific mapping above into exact Nim compiler calls (pick 5), or
* generate a library of helper builders (`ident()`, `lit()`, `procDef(name, params, body)`) that output real `NimNode` code targeting the Nim compiler version you use — tell me the Nim compiler/ast API you target and I’ll emit exact code.

Which 5 constructs should I convert to exact Nim compiler code now? (I’ll start immediately on those.)
