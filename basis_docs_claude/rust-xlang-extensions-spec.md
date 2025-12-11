# XLang Type Extensions for Rust Support

## Overview

This document details the XLang type system extensions required to support Rust language constructs. These extensions maintain XLang's language-agnostic design while accurately representing Rust's unique features.

## Design Principles

1. **Semantic Accuracy**: Each extension captures the semantic meaning of Rust constructs
2. **Minimal Addition**: Only add what's truly necessary; reuse existing nodes where possible
3. **Language Agnostic**: Extensions should be general enough for other languages
4. **Complete Coverage**: Support all Rust constructs from the official reference and syn crate

## New Node Types

### 1. `xnkTraitImpl` - Trait Implementation

**Semantic Importance**: Represents Rust's `impl Trait for Type` which provides implementations of trait methods for a specific type. This is fundamental to Rust's trait system and enables polymorphism through trait objects and generic bounds.

**Rust Example**:
```rust
impl Display for Point {
    fn fmt(&self, f: &mut Formatter) -> Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}

impl<T: Clone> Iterator for MyIter<T> {
    type Item = T;
    fn next(&mut self) -> Option<T> { ... }
}
```

**XLang Structure**:
```nim
of xnkTraitImpl:
  traitImplTrait*: XLangNode          # The trait being implemented
  traitImplType*: XLangNode           # The type receiving the implementation
  traitImplGenerics*: seq[XLangNode]  # Generic parameters: <T: Clone>
  traitImplWhere*: seq[XLangNode]     # Where clause constraints
  traitImplMembers*: seq[XLangNode]   # Method implementations and associated items
  traitImplUnsafety*: bool            # unsafe impl marker
  traitImplPolarity*: string          # "positive" or "negative" (!impl)
```

**Why Needed**: Unlike interfaces in other languages, Rust allows implementing traits for types defined elsewhere (orphan rules permitting). This separation of trait definition and implementation is fundamental to Rust's design.

**Transpilation Notes**:
- To Nim: Can generate method definitions on the type
- May need runtime trait objects for `dyn Trait`
- Associated types become type aliases

---

### 2. `xnkInherentImpl` - Inherent Implementation

**Semantic Importance**: Represents Rust's `impl Type` which provides methods and associated functions directly on a type. Unlike trait impls, these are always available on the type without needing to import any traits.

**Rust Example**:
```rust
impl Point {
    // Associated function (like static method)
    pub fn new(x: f64, y: f64) -> Self {
        Point { x, y }
    }

    // Method (has self parameter)
    pub fn distance(&self) -> f64 {
        (self.x * self.x + self.y * self.y).sqrt()
    }

    // Associated constant
    const ORIGIN: Point = Point { x: 0.0, y: 0.0 };
}

impl<T> Vec<T> {
    fn with_capacity(cap: usize) -> Self { ... }
}
```

**XLang Structure**:
```nim
of xnkInherentImpl:
  inherentImplType*: XLangNode         # The type: Point, Vec<T>, etc.
  inherentImplGenerics*: seq[XLangNode] # Generic parameters if any
  inherentImplWhere*: seq[XLangNode]    # Where clause constraints
  inherentImplMembers*: seq[XLangNode]  # Methods, functions, constants
  inherentImplUnsafety*: bool           # unsafe impl marker
```

**Why Needed**: Separates type definition from method implementation. In Rust, you can have multiple `impl` blocks for the same type, even across different modules (with visibility rules).

**Transpilation Notes**:
- Methods go into the type's class definition
- Associated functions become static methods
- Can merge multiple impl blocks for the same type

---

### 3. `xnkRawAddrExpr` - Raw Address-Of

**Semantic Importance**: Represents Rust's `&raw const` and `&raw mut` which take addresses without creating references. This is crucial for dealing with uninitialized memory and creating raw pointers safely.

**Rust Example**:
```rust
let uninit: MaybeUninit<T> = MaybeUninit::uninit();
let ptr = &raw const uninit;  // Safe! Doesn't dereference

let mut x = 5;
let ptr = &raw mut x;  // *mut i32
```

**XLang Structure**:
```nim
of xnkRawAddrExpr:
  rawAddrOperand*: XLangNode  # Expression to take address of
  rawAddrMutable*: bool       # const or mut
```

**Why Needed**: Different from regular references (`&`) - doesn't require the place to be initialized or aligned. Essential for unsafe Rust code.

---

## Field Extensions to Existing Nodes

### 4. `xnkReferenceType` Extensions

**New Fields**:
```nim
of xnkPointerType, xnkReferenceType:
  referentType*: XLangNode
  isMutable*: bool              # NEW: for &mut T vs &T
  lifetime*: Option[string]     # NEW: for &'a T
```

**Semantic Importance**:
- **`isMutable`**: Distinguishes shared references (`&T`) from exclusive mutable references (`&mut T`). This is central to Rust's ownership system - only one mutable reference OR multiple immutable references can exist.
- **`lifetime`**: Tracks the scope of reference validity (`'a`, `'static`, etc.). While primarily compile-time, it's essential for understanding code semantics.

**Examples**:
```rust
&T          → isMutable=false, lifetime=None
&mut T      → isMutable=true, lifetime=None
&'a T       → isMutable=false, lifetime=Some("a")
&'static str → isMutable=false, lifetime=Some("static")
```

---

### 5. `xnkGenericParameter` Extensions

**New Fields**:
```nim
of xnkGenericParameter:
  genericParamName*: string
  genericParamConstraints*: seq[XLangNode]
  bounds*: seq[XLangNode]
  lifetime*: Option[string]     # NEW: for lifetime params
  isLifetime*: bool             # NEW: distinguish 'a from T
  isConst*: bool                # NEW: for const generics
  constType*: Option[XLangNode] # NEW: type of const generic
```

**Semantic Importance**:
- **Lifetime Parameters**: Rust has three kinds of generic parameters:
  1. Type parameters: `T`, `U`
  2. Lifetime parameters: `'a`, `'b`
  3. Const parameters: `const N: usize`

**Examples**:
```rust
fn foo<'a, T, const N: usize>(x: &'a [T; N]) where T: Clone
//     ^^  ^  ^^^^^^^^^^^^^
//   lifetime type  const

<'a>          → isLifetime=true, lifetime=Some("a")
<T: Display>  → isLifetime=false, bounds=[Display]
<const N: usize> → isConst=true, constType=usize
```

---

### 6. Visibility Field for Declaration Nodes

**New Field**: Add `visibility*: Option[string]` to all declaration nodes.

**Semantic Importance**: Rust has fine-grained visibility control:
- `pub` - Public to all
- `pub(crate)` - Public within the current crate
- `pub(super)` - Public to parent module
- `pub(in path)` - Public to specific path
- (no modifier) - Private

**Values**:
```nim
"pub"              # Fully public
"pub(crate)"       # Crate-visible
"pub(super)"       # Parent module visible
"pub(in ::path)"   # Path-scoped
null               # Private (default)
```

**Affected Nodes**:
- `xnkFuncDecl`
- `xnkStructDecl`
- `xnkEnumDecl`
- `xnkTraitImpl` (entire impl)
- `xnkFieldDecl`
- `xnkTypeDecl`
- `xnkConstDecl`
- `xnkVarDecl` (for static)
- `xnkModuleDecl`

---

### 7. Method Receiver Types

**Enhancement**: Extend `xnkMethodDecl.receiver` to handle Rust's diverse receiver types.

**Semantic Importance**: Rust methods can receive `self` in many forms:
- `self` - Take ownership (move)
- `&self` - Shared borrow
- `&mut self` - Mutable borrow
- `self: Box<Self>` - Custom smart pointer receivers
- `self: Pin<&mut Self>` - Pinned receivers

**Examples**:
```rust
fn consume(self) { }              // Takes ownership
fn read(&self) -> &str { }        // Borrows immutably
fn modify(&mut self) { }          // Borrows mutably
fn into_box(self: Box<Self>) { }  // Custom receiver
```

**Representation**: Use existing `receiver` field but ensure it can represent:
- `xnkIdentifier` for `self`
- `xnkReferenceType` for `&self`, `&mut self`
- Full type expressions for custom receivers

---

### 8. Additional Expression Support

**Extensions Needed**:

#### a. Question Mark Operator `?`
```nim
# Use xnkUnaryExpr with op="?" (postfix)
# or add dedicated node:
of xnkTryExpr:
  tryOperand*: XLangNode
```

**Semantic**: Early return with error propagation in `Result<T, E>` or `Option<T>`.

#### b. Range Expressions
```nim
# Use xnkBinaryExpr with special ops:
# ".." for exclusive range (a..b)
# "..=" for inclusive range (a..=b)
# Or dedicated node:
of xnkRangeExpr:
  rangeStart*: Option[XLangNode]  # Can be empty: ..b
  rangeEnd*: Option[XLangNode]    # Can be empty: a..
  rangeInclusive*: bool           # ..= vs ..
```

#### c. Struct Literal with Update Syntax
```nim
# Extend xnkDictExpr or add:
of xnkStructLiteral:
  structType*: XLangNode
  structFields*: seq[XLangNode]   # Field assignments
  structBase*: Option[XLangNode]  # For ..base syntax
```

**Example**: `Point { x: 1, ..other }`

---

### 9. Pattern Matching Extensions

**New Field**: Add to `xnkCaseClause`:
```nim
of xnkCaseClause:
  caseValues*: seq[XLangNode]
  caseBody*: XLangNode
  caseFallthrough*: bool
  caseGuard*: Option[XLangNode]   # NEW: if condition in patterns
```

**Semantic Importance**: Rust patterns can have guards:
```rust
match x {
    Some(n) if n > 10 => { }  // Guard: if n > 10
    _ => { }
}
```

---

### 10. Unsafe Marker

**Add Field**: `isUnsafe*: bool` to:
- `xnkFuncDecl` - `unsafe fn`
- `xnkTraitImpl` - `unsafe impl`
- `xnkInterfaceDecl` - `unsafe trait`

**Semantic Importance**: Marks functions/traits that have safety invariants that must be upheld by the caller.

---

## Complete Rust Construct Coverage

### Items (syn::Item - 16 variants)
| Rust Item | XLang Node | Status |
|-----------|------------|--------|
| `const` | `xnkConstDecl` | ✅ Existing |
| `enum` | `xnkEnumDecl` | ✅ Existing |
| `extern crate` | `xnkImportStmt` | ✅ Existing |
| `fn` | `xnkFuncDecl` | ✅ Existing |
| `extern "C" { }` | `xnkLibDecl` | ✅ Existing |
| `impl` | `xnkInherentImpl` / `xnkTraitImpl` | ✅ New |
| `macro` | `xnkMacroDecl` | ✅ Existing |
| `mod` | `xnkModule` | ✅ Existing |
| `static` | `xnkVarDecl` (isStatic) | ✅ Existing |
| `struct` | `xnkStructDecl` | ✅ Existing |
| `trait` | `xnkInterfaceDecl` | ✅ Existing |
| `trait alias` | `xnkTypeAlias` + metadata | ✅ Existing |
| `type` | `xnkTypeAlias` | ✅ Existing |
| `union` | `xnkStructDecl` + metadata | ✅ Existing |
| `use` | `xnkImportStmt` | ✅ Existing |

### Expressions (syn::Expr - 40 variants)
| Rust Expression | XLang Node | Status |
|----------------|------------|--------|
| Array `[a, b]` | `xnkArrayLiteral` | ✅ Existing |
| Assign `a = b` | `xnkAsgn` | ✅ Existing |
| Async `async { }` | `xnkBlockStmt` (isAsync) | ✅ Existing |
| Await `.await` | `xnkAwaitExpr` | ✅ Existing |
| Binary `a + b` | `xnkBinaryExpr` | ✅ Existing |
| Block `{ }` | `xnkBlockStmt` | ✅ Existing |
| Break | `xnkBreakStmt` | ✅ Existing |
| Call `f(a)` | `xnkCallExpr` | ✅ Existing |
| Cast `x as T` | `xnkCastExpr` | ✅ Existing |
| Closure `\|x\| x` | `xnkLambdaExpr` | ✅ Existing |
| Const `const { }` | `xnkBlockStmt` + flag | ✅ Existing |
| Continue | `xnkContinueStmt` | ✅ Existing |
| Field `obj.field` | `xnkMemberAccessExpr` | ✅ Existing |
| For `for x in i` | `xnkForeachStmt` | ✅ Existing |
| Group `(expr)` | Transparent | ✅ Existing |
| If `if cond { }` | `xnkIfStmt` | ✅ Existing |
| Index `a[i]` | `xnkIndexExpr` | ✅ Existing |
| Infer `_` | `xnkIdentifier("_")` | ✅ Existing |
| Let `let x = y` | `xnkVarDecl` | ✅ Existing |
| Lit `42`, `"x"` | `xnkIntLit`, etc. | ✅ Existing |
| Loop `loop { }` | `xnkWhileStmt` (true cond) | ✅ Existing |
| Macro `vec![]` | `xnkCallExpr` + macro flag | ✅ Existing |
| Match `match x` | `xnkSwitchStmt` | ✅ Existing |
| MethodCall `x.f()` | `xnkCallExpr` + method | ✅ Existing |
| Paren `(expr)` | Transparent | ✅ Existing |
| Path `std::vec` | `xnkQualifiedName` | ✅ Existing |
| Range `a..b` | `xnkRangeExpr` | ✅ New |
| RawAddr `&raw` | `xnkRawAddrExpr` | ✅ New |
| Reference `&x` | `xnkRefExpr` | ✅ Existing |
| Repeat `[x; N]` | `xnkArrayLiteral` + repeat | ✅ Existing |
| Return | `xnkReturnStmt` | ✅ Existing |
| Struct `S { }` | `xnkStructLiteral` | ✅ New |
| Try `x?` | `xnkTryExpr` | ✅ New |
| TryBlock `try { }` | `xnkTryStmt` | ✅ Existing |
| Tuple `(a, b)` | `xnkTupleExpr` | ✅ Existing |
| Unary `!x`, `*x` | `xnkUnaryExpr` | ✅ Existing |
| Unsafe `unsafe { }` | `xnkUnsafeStmt` | ✅ Existing |
| While `while c` | `xnkWhileStmt` | ✅ Existing |
| Yield `yield x` | `xnkIteratorYield` | ✅ Existing |

## Summary

### Additions Required
- **2 new node types**: `xnkTraitImpl`, `xnkInherentImpl`
- **4 small new nodes**: `xnkRawAddrExpr`, `xnkRangeExpr`, `xnkStructLiteral`, `xnkTryExpr`
- **Field extensions**: Visibility, mutability, lifetimes, const generics, guards
- **95%+ coverage**: Most Rust constructs map to existing XLang nodes

### Semantic Impact
Each extension captures fundamental Rust semantics:
1. **Trait system**: `xnkTraitImpl` enables Rust's powerful trait-based polymorphism
2. **Method organization**: `xnkInherentImpl` models Rust's separation of concerns
3. **Safety**: Visibility, unsafe markers preserve Rust's safety guarantees
4. **Ownership**: Reference mutability and lifetimes document (but don't enforce) ownership
5. **Generics**: Lifetime and const parameters enable Rust's zero-cost abstractions

These extensions make XLang fully capable of representing Rust's semantics while remaining general enough for other systems languages.

## References

- [Rust Reference - Items](https://doc.rust-lang.org/reference/items.html)
- [Rust Reference - Expressions](https://doc.rust-lang.org/reference/expressions.html)
- [syn crate - Expr enum](https://docs.rs/syn/latest/syn/enum.Expr.html)
- [syn crate - Item enum](https://docs.rs/syn/latest/syn/enum.Item.html)
