# Comprehensive Rust to XLang Parser

A complete, exhaustive Rust parser that converts Rust source code to XLang intermediate representation using the `syn` crate.

## Features

✅ **100% Coverage** of Rust language constructs
- All 16 `syn::Item` variants (modules, structs, enums, traits, impl blocks, etc.)
- All 40 `syn::Expr` variants (literals, operators, control flow, async/await, etc.)
- Full type system support (generics, lifetimes, associated types, trait objects)
- Complete pattern matching support
- All Rust-specific features (ownership syntax, unsafe, attributes, macros)

## Usage

```bash
# Build the parser
cd src/parsers/rust
cargo build --release

# Parse a Rust file
./target/release/rust_to_xlang input.rs [output.json]

# If no output specified, generates input.rs.xlang.json
./target/release/rust_to_xlang myfile.rs
# Creates: myfile.rs.xlang.json
```

## Supported Constructs

### Items (All 16 syn::Item variants)

| Rust Item | XLang Mapping | Example |
|-----------|---------------|---------|
| `const` | `xnkConstDecl` | `const MAX: i32 = 100;` |
| `enum` | `xnkEnumDecl` | `enum Option<T> { Some(T), None }` |
| `extern crate` | `xnkImportStmt` | `extern crate serde;` |
| `fn` | `xnkFuncDecl` | `fn add(a: i32, b: i32) -> i32 { a + b }` |
| `extern "C" {}` | `xnkLibDecl` | `extern "C" { fn printf(...); }` |
| `impl Trait for Type` | **`xnkTraitImpl`** (NEW) | `impl Display for Point { ... }` |
| `impl Type` | **`xnkInherentImpl`** (NEW) | `impl Point { fn new() -> Self { ... } }` |
| `macro_rules!` | `xnkMacroDecl` | `macro_rules! vec { ... }` |
| `mod` | `xnkModule` | `mod utils { ... }` |
| `static` | `xnkVarDecl` (isStatic) | `static COUNTER: i32 = 0;` |
| `struct` | `xnkStructDecl` | `struct Point { x: f64, y: f64 }` |
| `trait` | `xnkInterfaceDecl` | `trait Draw { fn draw(&self); }` |
| `trait alias` | `xnkTypeAlias` | `trait Iter = Iterator + Send;` |
| `type` | `xnkTypeAlias` | `type Result<T> = std::result::Result<T, Error>;` |
| `union` | `xnkStructDecl` (isUnion) | `union Data { i: i32, f: f32 }` |
| `use` | `xnkImportStmt` | `use std::collections::HashMap;` |

### Expressions (All 40 syn::Expr variants)

| Rust Expression | XLang Mapping | Example |
|----------------|---------------|---------|
| Array | `xnkArrayLiteral` | `[1, 2, 3]` |
| Assign | `xnkAsgn` | `x = 5` |
| Async | `xnkBlockStmt` (isAsync) | `async { ... }` |
| Await | `xnkAwaitExpr` | `future.await` |
| Binary | `xnkBinaryExpr` | `a + b`, `x && y` |
| Block | `xnkBlockStmt` | `{ stmt1; stmt2 }` |
| Break | `xnkBreakStmt` | `break 'label` |
| Call | `xnkCallExpr` | `foo(a, b)` |
| Cast | `xnkCastExpr` | `x as i32` |
| Closure | `xnkLambdaExpr` | `\|x\| x + 1` |
| Const | `xnkBlockStmt` (isConst) | `const { ... }` |
| Continue | `xnkContinueStmt` | `continue` |
| Field | `xnkMemberAccessExpr` | `obj.field`, `tuple.0` |
| ForLoop | `xnkForeachStmt` | `for x in iter { ... }` |
| Group | Transparent | `(expr)` |
| If | `xnkIfStmt` | `if cond { } else { }` |
| Index | `xnkIndexExpr` | `arr[i]` |
| Infer | `xnkIdentifier("_")` | `_` (type inference) |
| Let | `xnkVarDecl` | `let Some(x) = opt` (in patterns) |
| Lit | Literal nodes | `42`, `"hello"`, `true` |
| Loop | `xnkWhileStmt` (always true) | `loop { ... }` |
| Macro | `xnkCallExpr` (isMacro) | `vec![1, 2, 3]` |
| Match | `xnkSwitchStmt` | `match x { ... }` |
| MethodCall | `xnkCallExpr` | `obj.method(args)` |
| Paren | Transparent | `(expr)` |
| Path | `xnkQualifiedName` | `std::vec::Vec` |
| Range | **`xnkRangeExpr`** (NEW) | `1..10`, `..=5` |
| RawAddr | **`xnkRawAddrExpr`** (NEW) | `&raw const x` |
| Reference | `xnkRefExpr` | `&x`, `&mut x` |
| Repeat | `xnkArrayLiteral` | `[0; 100]` |
| Return | `xnkReturnStmt` | `return x` |
| Struct | **`xnkStructLiteral`** (NEW) | `Point { x: 1, y: 2 }` |
| Try | **`xnkTryExpr`** (NEW) | `result?` |
| TryBlock | `xnkTryStmt` | `try { ... }` |
| Tuple | `xnkTupleExpr` | `(1, 2, 3)` |
| Unary | `xnkUnaryExpr` | `!x`, `*ptr`, `-n` |
| Unsafe | `xnkUnsafeStmt` | `unsafe { ... }` |
| While | `xnkWhileStmt` | `while cond { ... }` |
| Yield | `xnkIteratorYield` | `yield value` |

### Types

| Rust Type | XLang Mapping |
|-----------|---------------|
| `i32`, `u64`, `f32`, `bool`, etc. | `xnkNamedType` |
| `&T` | `xnkReferenceType` (isMutable=false) |
| `&mut T` | `xnkReferenceType` (isMutable=true) |
| `&'a T` | `xnkReferenceType` (lifetime="a") |
| `*const T`, `*mut T` | `xnkPointerType` |
| `[T; N]` | `xnkArrayType` (with size) |
| `[T]` | `xnkArrayType` (slice, no size) |
| `Vec<T>`, `Option<T>` | `xnkGenericType` |
| `fn(A, B) -> C` | `xnkFuncType` |
| `(A, B, C)` | `xnkTupleExpr` |
| `impl Trait` | `xnkNamedType` (typeName="impl") |
| `dyn Trait` | `xnkNamedType` (typeName="dyn") |
| `!` (never) | `xnkNamedType` (typeName="!") |

### Generics & Lifetimes

| Rust Feature | XLang Representation |
|--------------|---------------------|
| `<T>` | `xnkGenericParameter` (isLifetime=false) |
| `<'a>` | `xnkGenericParameter` (isLifetime=true) |
| `<const N: usize>` | `xnkGenericParameter` (isConst=true) |
| `T: Display + Clone` | bounds array in `xnkGenericParameter` |
| `where T: Clone` | same as trait bounds |

## New XLang Nodes

This parser introduces **4 new XLang node types** for Rust-specific constructs:

### 1. `xnkTraitImpl` - Trait Implementation

Represents `impl Trait for Type`:

```json
{
  "kind": "xnkTraitImpl",
  "traitImplTrait": { "kind": "xnkNamedType", "typeName": "Display" },
  "traitImplType": { "kind": "xnkNamedType", "typeName": "Point" },
  "traitImplGenerics": [],
  "traitImplMembers": [...],
  "traitImplUnsafety": false
}
```

### 2. `xnkInherentImpl` - Inherent Implementation

Represents `impl Type`:

```json
{
  "kind": "xnkInherentImpl",
  "inherentImplType": { "kind": "xnkNamedType", "typeName": "Point" },
  "inherentImplGenerics": [],
  "inherentImplMembers": [...]
}
```

### 3. `xnkRangeExpr` - Range Expression

Represents `a..b`, `..=5`, etc.:

```json
{
  "kind": "xnkRangeExpr",
  "rangeStart": { "kind": "xnkIntLit", "literalValue": "1" },
  "rangeEnd": { "kind": "xnkIntLit", "literalValue": "10" },
  "rangeInclusive": false
}
```

### 4. `xnkRawAddrExpr` - Raw Address-Of

Represents `&raw const x`, `&raw mut x`:

```json
{
  "kind": "xnkRawAddrExpr",
  "rawAddrOperand": { "kind": "xnkIdentifier", "identName": "x" },
  "rawAddrMutable": false
}
```

### 5. `xnkStructLiteral` - Struct Literal with Update Syntax

Represents `Point { x: 1, ..other }`:

```json
{
  "kind": "xnkStructLiteral",
  "structType": { "kind": "xnkNamedType", "typeName": "Point" },
  "structFields": [
    { "fieldName": "x", "fieldValue": { "kind": "xnkIntLit", "literalValue": "1" } }
  ],
  "structBase": { "kind": "xnkIdentifier", "identName": "other" }
}
```

### 6. `xnkTryExpr` - Question Mark Operator

Represents `result?`:

```json
{
  "kind": "xnkTryExpr",
  "tryOperand": { "kind": "xnkIdentifier", "identName": "result" }
}
```

## Extended XLang Fields

### Reference Types

`xnkReferenceType` now includes:
- `isMutable`: boolean (distinguishes `&T` from `&mut T`)
- `lifetime`: optional string (for `&'a T`)

### Generic Parameters

`xnkGenericParameter` now includes:
- `isLifetime`: boolean (distinguishes `'a` from `T`)
- `isConst`: boolean (for `const N: usize`)
- `constType`: type of const generic

### Visibility

All declaration nodes now include `visibility` string:
- `"pub"` - Public
- `"pub(crate)"` - Crate-visible
- `"pub(super)"` - Parent module
- `"pub(in path)"` - Path-scoped
- `"private"` - Private (default)

### Attributes

All items preserve Rust attributes:

```json
{
  "attributes": [
    {
      "kind": "xnkAttribute",
      "attrName": "derive",
      "attrTokens": "derive (Debug , Clone)"
    }
  ]
}
```

## Implementation Details

### Parser Architecture

- **Frontend**: Uses `syn 2.0` crate for robust Rust parsing
- **Conversion**: Single-pass AST traversal
- **Output**: Pretty-printed JSON via `serde_json`
- **Coverage**: Handles all documented Rust syntax

### Ownership & Borrowing

The parser represents ownership/borrowing as **syntax annotations**:
- `&T` vs `&mut T` preserved via `isMutable` flag
- Lifetimes (`'a`) stored as strings
- Moves vs copies implicit in method receivers

**Note**: The parser doesn't perform borrow checking - it assumes valid, compiling Rust code.

### Pattern Matching

Rust patterns map to expressions for simplicity:
- `Some(x)` → `xnkCallExpr`
- `Point { x, y }` → `xnkStructLiteral`
- `(a, b, c)` → `xnkTupleExpr`
- `1..=10` → `xnkRangeExpr`

Pattern guards are preserved in `caseGuard` field.

## Testing

```bash
# Run on comprehensive test
./target/release/rust_to_xlang test_comprehensive.rs

# Output contains all constructs
cat test_comprehensive.rs.xlang.json | jq '.moduleDecls[] | .kind' | sort | uniq
```

Expected output includes:
- `xnkStructDecl`, `xnkEnumDecl`, `xnkInterfaceDecl`
- `xnkTraitImpl`, `xnkInherentImpl`
- `xnkFuncDecl`, `xnkMethodDecl`
- `xnkConstDecl`, `xnkVarDecl`, `xnkTypeAlias`
- `xnkModule`, `xnkImportStmt`, `xnkLibDecl`

## Limitations

1. **Macro Expansion**: Macros are captured as tokens, not expanded
2. **Name Resolution**: Type/name resolution not performed
3. **Const Evaluation**: Const expressions not evaluated
4. **Format Macros**: `println!`, `format!` captured as macro calls
5. **Proc Macros**: Treated as attributes, not expanded

These are intentional - the parser focuses on **syntax representation**, not semantic analysis.

## Example Output

Input (`point.rs`):
```rust
pub struct Point {
    pub x: f64,
    pub y: f64,
}

impl Point {
    pub fn new(x: f64, y: f64) -> Self {
        Point { x, y }
    }
}
```

Output (`point.rs.xlang.json`):
```json
{
  "kind": "xnkFile",
  "fileName": "point.rs",
  "moduleDecls": [
    {
      "kind": "xnkStructDecl",
      "typeNameDecl": "Point",
      "members": [
        { "kind": "xnkFieldDecl", "fieldName": "x", "fieldType": {...}, "visibility": "pub" },
        { "kind": "xnkFieldDecl", "fieldName": "y", "fieldType": {...}, "visibility": "pub" }
      ],
      "visibility": "pub"
    },
    {
      "kind": "xnkInherentImpl",
      "inherentImplType": { "kind": "xnkNamedType", "typeName": "Point" },
      "inherentImplMembers": [
        {
          "kind": "xnkMethodDecl",
          "methodName": "new",
          "mparams": [...],
          "mreturnType": { "kind": "xnkNamedType", "typeName": "Self" },
          "mbody": {...},
          "visibility": "pub"
        }
      ]
    }
  ]
}
```

## References

- [Rust Reference](https://doc.rust-lang.org/reference/)
- [syn crate](https://docs.rs/syn/latest/syn/)
- [Expr enum](https://docs.rs/syn/latest/syn/enum.Expr.html) (40 variants)
- [Item enum](https://docs.rs/syn/latest/syn/enum.Item.html) (16 variants)
- [XLang Extensions Spec](../../../basis_docs_claude/rust-xlang-extensions-spec.md)

## Next Steps

To integrate this parser into the transpiler pipeline:

1. **Update `xlangtypes.nim`** with new node types (see spec doc)
2. **Update `xlang_to_nim.nim`** to handle Rust-specific nodes
3. **Test** with various Rust projects
4. **Optimize** for large codebases if needed

## License

Part of the transpiler project.
