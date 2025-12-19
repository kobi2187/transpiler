# Rust to XLang Feasibility Analysis

## Executive Summary

**Verdict: ✅ HIGHLY FEASIBLE** - Rust can be successfully mapped to XLang with minor extensions.

Assuming valid, compiling Rust code (no borrow checking needed in parser), ~95% of Rust constructs map cleanly to existing XLang nodes. Only a few Rust-specific features require new XLang nodes.

## Rust Language Overview

Rust is a systems programming language with:
- Ownership and borrowing system (syntax only for our purposes)
- Algebraic data types (enums with variants)
- Traits (similar to interfaces with implementations)
- Pattern matching
- Generics with constraints
- Lifetimes (compile-time annotations)
- Macros

## XLang Coverage Analysis

### ✅ Already Supported (90%+)

| Rust Feature | XLang Node | Notes |
|--------------|------------|-------|
| **Structs** | `xnkStructDecl` | Perfect match |
| **Enums** | `xnkEnumDecl` | Algebraic data types |
| **Functions** | `xnkFuncDecl` | Direct mapping |
| **Methods** | `xnkMethodDecl` | Has `receiver` field |
| **Traits** | `xnkInterfaceDecl` | Conceptually similar |
| **Impl blocks** | `xnkClassDecl` or metadata | Can use members array |
| **Generics** | `xnkGenericType` + `xnkGenericParameter` | Full support |
| **References `&T`** | `xnkReferenceType` | Already exists |
| **Pointers `*T`** | `xnkPointerType` | Already exists |
| **Arrays `[T; N]`** | `xnkArrayType` | Already exists |
| **Slices `&[T]`** | `xnkReferenceType` + `xnkArrayType` | Combine existing |
| **Tuples** | `xnkTupleExpr` | Already exists |
| **Match** | `xnkSwitchStmt` | Pattern matching |
| **Closures** | `xnkLambdaExpr` | Already exists |
| **Loops** | `xnkForStmt`, `xnkWhileStmt` | All covered |
| **If/else** | `xnkIfStmt` | Already exists |
| **Break/continue** | `xnkBreakStmt`, `xnkContinueStmt` | With labels |
| **Modules** | `xnkModule` | Already exists |
| **Use statements** | `xnkImportStmt` | Already exists |
| **Constants** | `xnkConstDecl` | Already exists |
| **Static** | `xnkVarDecl` + metadata | Use isStatic flag |
| **Type aliases** | `xnkTypeAlias` | Already exists |
| **Unsafe blocks** | `xnkUnsafeStmt` | Already exists! |
| **Defer (Drop)** | `xnkDestructorDecl` | Already exists |
| **Async/await** | `xnkAwaitExpr` + `isAsync` | Already exists |
| **String literals** | `xnkStringLit` | Already exists |
| **Range `a..b`** | `xnkBinaryExpr` with `..` op | Already exists |

### 🟡 Needs Minor Extension (5%)

These need small additions to existing XLang nodes:

| Rust Feature | XLang Solution | Effort |
|--------------|----------------|--------|
| **Lifetimes `'a`** | Add `lifetime` field to `xnkGenericParameter` | Trivial |
| **Trait bounds `T: Trait`** | Use existing `bounds` field in `xnkGenericParameter` | Already exists! |
| **Where clauses** | Extend `xnkGenericParameter.constraints` | Already supported |
| **Mutable refs `&mut`** | Add `isMutable` flag to `xnkReferenceType` | Trivial |
| **Associated types** | Use `xnkTypeDecl` inside trait | Already works |
| **Method receiver `&self`** | Use `receiver` field in `xnkMethodDecl` | Already exists! |

### 🔴 Needs New XLang Nodes (5%)

Only a few Rust-specific features need new nodes:

| Rust Feature | Proposed XLang Node | Description |
|--------------|---------------------|-------------|
| **Trait impl** | `xnkTraitImpl` | `impl Trait for Type { }` |
| **Inherent impl** | `xnkInherentImpl` | `impl Type { }` |
| **Macro invocation** | `xnkMacroCall` | `vec![]`, `println!()` |
| **Macro definition** | `xnkMacroDef` | Already exists! |
| **Visibility** | Add `visibility` field | `pub`, `pub(crate)`, etc. |
| **Attributes** | `xnkAttribute` or `xnkMetadata` | Already exists! |

## Proposed XLang Extensions

### 1. Add `xnkTraitImpl` Node

```nim
of xnkTraitImpl:
  traitImplTrait*: XLangNode          # Trait being implemented
  traitImplType*: XLangNode           # Type implementing it
  traitImplGenerics*: seq[XLangNode]  # Generic parameters
  traitImplWhere*: seq[XLangNode]     # Where clauses
  traitImplMembers*: seq[XLangNode]   # Methods/associated items
```

### 2. Add `xnkInherentImpl` Node

```nim
of xnkInherentImpl:
  inherentImplType*: XLangNode         # Type
  inherentImplGenerics*: seq[XLangNode] # Generic parameters
  inherentImplMembers*: seq[XLangNode]  # Methods
```

### 3. Extend `xnkReferenceType`

```nim
of xnkReferenceType:
  referentType*: XLangNode
  isMutable*: bool         # NEW: for &mut T
  lifetime*: Option[string] # NEW: for 'a lifetime
```

### 4. Extend `xnkGenericParameter`

```nim
of xnkGenericParameter:
  genericParamName*: string
  genericParamConstraints*: seq[XLangNode]
  bounds*: seq[XLangNode]
  lifetime*: Option[string]  # NEW: for lifetime params 'a
  isLifetime*: bool          # NEW: distinguish lifetime params
```

### 5. Add Visibility Field to Declarations

Add `visibility: string` field to:
- `xnkFuncDecl`
- `xnkStructDecl`
- `xnkEnumDecl`
- `xnkFieldDecl`
- etc.

Values: `"pub"`, `"pub(crate)"`, `"pub(super)"`, `"private"`

### 6. Use Existing `xnkMacroCall`

Already covered by `xnkMacroDef` and can use `xnkCallExpr` with macro flag.

## Rust to XLang Mapping Table

### Module-Level Items

| Rust Construct | XLang Node |
|----------------|------------|
| `mod name { }` | `xnkModule` |
| `use path::item` | `xnkImportStmt` |
| `pub use path` | `xnkExportStmt` |
| `fn name() { }` | `xnkFuncDecl` |
| `struct Name { }` | `xnkStructDecl` |
| `enum Name { }` | `xnkEnumDecl` |
| `trait Name { }` | `xnkInterfaceDecl` |
| `impl Trait for Type` | `xnkTraitImpl` (NEW) |
| `impl Type` | `xnkInherentImpl` (NEW) |
| `type Alias = T` | `xnkTypeAlias` |
| `const X: T = v` | `xnkConstDecl` |
| `static X: T = v` | `xnkVarDecl` (isStatic) |

### Types

| Rust Type | XLang Node |
|-----------|------------|
| `i32`, `u64`, `f32`, etc. | `xnkNamedType` |
| `&T` | `xnkReferenceType` |
| `&mut T` | `xnkReferenceType` (isMutable) |
| `*const T` | `xnkPointerType` |
| `*mut T` | `xnkPointerType` (isMutable) |
| `[T; N]` | `xnkArrayType` (with size) |
| `[T]` | `xnkArrayType` (no size) |
| `Vec<T>` | `xnkGenericType` |
| `fn(A) -> B` | `xnkFuncType` |
| `(A, B, C)` | `xnkTupleExpr` |
| `Option<T>` | `xnkGenericType` |
| `impl Trait` | `xnkNamedType` (special) |
| `dyn Trait` | `xnkNamedType` (special) |

### Expressions

| Rust Expression | XLang Node |
|----------------|------------|
| `a + b` | `xnkBinaryExpr` |
| `!a`, `-a`, `*a`, `&a` | `xnkUnaryExpr` |
| `f(a, b)` | `xnkCallExpr` |
| `a[i]` | `xnkIndexExpr` |
| `a.field` | `xnkMemberAccessExpr` |
| `a?.method()` | `xnkSafeNavigationExpr` |
| `obj.method()` | `xnkCallExpr` |
| `a..b`, `a..=b` | `xnkBinaryExpr` |
| `[1, 2, 3]` | `xnkArrayLiteral` |
| `(1, 2, 3)` | `xnkTupleExpr` |
| `\|x\| x + 1` | `xnkLambdaExpr` |
| `if cond { } else { }` | `xnkIfStmt` |
| `match x { }` | `xnkSwitchStmt` |
| `loop { }` | `xnkWhileStmt` (condition=true) |
| `while cond { }` | `xnkWhileStmt` |
| `for x in iter { }` | `xnkForeachStmt` |
| `return x` | `xnkReturnStmt` |
| `break`, `continue` | `xnkBreakStmt`, `xnkContinueStmt` |
| `unsafe { }` | `xnkUnsafeStmt` |
| `async { }` | `xnkBlockStmt` (isAsync) |
| `.await` | `xnkAwaitExpr` |
| `x?` | `xnkUnaryExpr` (op="?") |
| `Type { field: val }` | `xnkDictExpr` (struct literal) |
| `&x`, `&mut x` | `xnkRefExpr` |

### Patterns (in match)

| Rust Pattern | XLang Representation |
|--------------|---------------------|
| Literal | Literal nodes |
| Wildcard `_` | `xnkIdentifier("_")` |
| Variable `x` | `xnkIdentifier` |
| Enum variant | `xnkCallExpr` |
| Struct pattern | `xnkDictExpr` |
| Tuple pattern | `xnkTupleExpr` |
| Range `1..=10` | `xnkBinaryExpr` |
| `Some(x)` | `xnkCallExpr` |

## Parser Implementation Strategy

### Option 1: Use `syn` Crate (Recommended) ⭐

**Pros:**
- Battle-tested Rust parser used by procedural macros
- Complete AST coverage
- Well-documented
- Active maintenance

**Cons:**
- Rust-only (parser must be written in Rust)
- Need to bridge Rust → JSON → XLang

**Implementation:**
```rust
use syn::{File, Item, Expr};
use serde_json;

fn parse_rust_file(path: &str) -> XLangNode {
    let content = std::fs::read_to_string(path)?;
    let ast = syn::parse_file(&content)?;
    convert_to_xlang(ast)
}
```

### Option 2: Use `rust-analyzer` AST

**Pros:**
- Used by Rust LSP
- Very complete

**Cons:**
- More complex API
- Heavier dependency

### Option 3: Use `rustc_ast` (Not Recommended)

**Cons:**
- Unstable API
- Tied to compiler internals
- Overkill for our needs

## Example: Simple Rust to XLang

### Input (Rust):
```rust
pub struct Point {
    pub x: f64,
    pub y: f64,
}

impl Point {
    pub fn new(x: f64, y: f64) -> Self {
        Point { x, y }
    }

    pub fn distance(&self) -> f64 {
        (self.x * self.x + self.y * self.y).sqrt()
    }
}

pub trait Drawable {
    fn draw(&self);
}

impl Drawable for Point {
    fn draw(&self) {
        println!("Point({}, {})", self.x, self.y);
    }
}
```

### Output (XLang):
```json
{
  "kind": "xnkFile",
  "fileName": "point.rs",
  "moduleDecls": [
    {
      "kind": "xnkStructDecl",
      "typeNameDecl": "Point",
      "visibility": "pub",
      "members": [
        {"kind": "xnkFieldDecl", "fieldName": "x", "fieldType": {"kind": "xnkNamedType", "typeName": "f64"}, "visibility": "pub"},
        {"kind": "xnkFieldDecl", "fieldName": "y", "fieldType": {"kind": "xnkNamedType", "typeName": "f64"}, "visibility": "pub"}
      ]
    },
    {
      "kind": "xnkInherentImpl",
      "inherentImplType": {"kind": "xnkNamedType", "typeName": "Point"},
      "inherentImplMembers": [
        {
          "kind": "xnkFuncDecl",
          "funcName": "new",
          "visibility": "pub",
          "params": [...],
          "returnType": {"kind": "xnkNamedType", "typeName": "Self"},
          "funcBody": {...}
        },
        {
          "kind": "xnkMethodDecl",
          "methodName": "distance",
          "receiver": {"kind": "xnkRefExpr", "isMutable": false},
          "visibility": "pub",
          "mparams": [],
          "mreturnType": {"kind": "xnkNamedType", "typeName": "f64"},
          "mbody": {...}
        }
      ]
    },
    {
      "kind": "xnkInterfaceDecl",
      "typeNameDecl": "Drawable",
      "visibility": "pub",
      "members": [
        {
          "kind": "xnkMethodDecl",
          "methodName": "draw",
          "receiver": {"kind": "xnkRefExpr"},
          "mparams": [],
          "mbody": null
        }
      ]
    },
    {
      "kind": "xnkTraitImpl",
      "traitImplTrait": {"kind": "xnkNamedType", "typeName": "Drawable"},
      "traitImplType": {"kind": "xnkNamedType", "typeName": "Point"},
      "traitImplMembers": [
        {
          "kind": "xnkMethodDecl",
          "methodName": "draw",
          "receiver": {"kind": "xnkRefExpr"},
          "mbody": {...}
        }
      ]
    }
  ]
}
```

## Effort Estimate

### Minimal XLang Extensions
- Add 2-3 new node types: **1-2 days**
- Extend 2-3 existing nodes: **1 day**
- Update Nim parsers to handle new nodes: **1 day**

### Parser Implementation (using `syn`)
- Set up Rust project with syn: **1 day**
- Implement item converters (structs, enums, etc.): **2-3 days**
- Implement expression converters: **3-4 days**
- Implement type converters: **2 days**
- Handle generics, lifetimes, traits: **2-3 days**
- Testing and refinement: **2-3 days**

**Total: ~2-3 weeks for full implementation**

## Compatibility Assessment

| Aspect | Compatibility | Notes |
|--------|--------------|-------|
| Basic types | ✅ 100% | All map to XLang |
| Control flow | ✅ 100% | Perfect match |
| Functions | ✅ 100% | Full support |
| Structs/Enums | ✅ 100% | Perfect fit |
| Generics | ✅ 95% | Need lifetime support |
| Traits | ✅ 90% | Need impl blocks |
| Pattern matching | ✅ 100% | Maps to switch |
| Ownership (syntax) | ✅ 95% | Just parse annotations |
| Macros | ⚠️ 80% | Basic support, not expansion |
| Unsafe | ✅ 100% | Already has `xnkUnsafeStmt` |

## Recommendations

### Phase 1: Core Features (Week 1)
1. Add `xnkTraitImpl` and `xnkInherentImpl` nodes to XLang
2. Extend `xnkReferenceType` with `isMutable` and `lifetime`
3. Set up Rust parser project with `syn` crate
4. Implement basic item parsing (structs, enums, functions)

### Phase 2: Advanced Features (Week 2)
5. Implement trait and impl block parsing
6. Add generic and lifetime support
7. Implement expression parsing
8. Handle pattern matching in match expressions

### Phase 3: Polish (Week 3)
9. Add macro invocation support
10. Handle visibility modifiers
11. Add comprehensive tests
12. Documentation

## Conclusion

**Rust to XLang transpilation is highly feasible!**

Key advantages:
- ✅ 90%+ of Rust maps to existing XLang
- ✅ Only 2-3 new node types needed
- ✅ `syn` crate provides robust parsing
- ✅ No borrow checking needed (syntax-only)
- ✅ Similar complexity to Haxe parser

The main work is:
1. Minor XLang extensions (1-2 days)
2. Rust parser implementation (2-3 weeks)
3. Testing and refinement (ongoing)

**Estimated total effort: 2-3 weeks for full Rust support**

## References

- [Rust 2024 Edition](https://doc.rust-lang.org/edition-guide/rust-2024/index.html)
- [Rust Cheat Sheet](https://cheats.rs/)
- [syn crate](https://github.com/dtolnay/syn)
- [Rust Lifetimes](https://doc.rust-lang.org/book/ch10-03-lifetime-syntax.html)
- [Rust Book - Advanced Features](https://rust-lang.github.io/book/ch20-00-advanced-features.html)
