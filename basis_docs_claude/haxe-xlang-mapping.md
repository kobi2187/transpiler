# Haxe to XLang Mapping

This document maps Haxe language constructs to XLang nodes for the transpiler pipeline.

## Module-Level Constructs

### File and Module Structure
| Haxe Construct | XLang Node | Notes |
|----------------|------------|-------|
| File | `xnkFile` | Top-level file node |
| Package declaration | `xnkNamespace` | Haxe packages map to namespaces |
| Import statement | `xnkImportStmt` | Import declarations |

### Type Declarations

| Haxe Construct | XLang Node | Notes |
|----------------|------------|-------|
| Class | `xnkClassDecl` | Regular classes |
| Interface | `xnkInterfaceDecl` | Interface declarations |
| Enum | `xnkEnumDecl` | Algebraic data types |
| Typedef | `xnkTypeAlias` | Type aliases |
| Abstract | `xnkAbstractDecl` | Haxe abstract types |
| Anonymous structure | `xnkStructDecl` | Anonymous object types |

## Class Members

| Haxe Construct | XLang Node | Notes |
|----------------|------------|-------|
| Field | `xnkFieldDecl` | Class fields |
| Method | `xnkMethodDecl` | Instance and static methods |
| Property | `xnkPropertyDecl` | Properties with getters/setters |
| Constructor | `xnkConstructorDecl` | `new` function |
| Static field | `xnkFieldDecl` | With static flag |
| Static method | `xnkMethodDecl` | With static flag |

## Types

| Haxe Type | XLang Node | Notes |
|-----------|------------|-------|
| `Int`, `Float`, `Bool`, `String` | `xnkNamedType` | Basic types |
| `Array<T>` | `xnkGenericType` | Generic array type |
| `Map<K, V>` | `xnkMapType` or `xnkGenericType` | Map type |
| `T -> R` (function type) | `xnkFuncType` | Function types |
| Generic type `Type<T>` | `xnkGenericType` | Parameterized types |
| `Null<T>` | `xnkGenericType` | Nullable types |
| Type parameter | `xnkGenericParameter` | Generic type parameters |
| Anonymous { field: Type } | `xnkStructDecl` | Anonymous structures |
| `Dynamic` | `xnkDynamicType` | Dynamic type |
| Abstract type | `xnkAbstractType` | Abstract wrapper types |

## Expressions

### Literals

| Haxe Literal | XLang Node | Notes |
|--------------|------------|-------|
| Integer literal | `xnkIntLit` | `42`, `0xFF` |
| Float literal | `xnkFloatLit` | `3.14`, `1e-5` |
| String literal | `xnkStringLit` | `"hello"` |
| String interpolation | `xnkStringInterpolation` | `'hello $name'` |
| Boolean literal | `xnkBoolLit` | `true`, `false` |
| `null` | `xnkNilLit` | Null value |
| Array literal | `xnkArrayLiteral` | `[1, 2, 3]` |
| Object literal | `xnkDictExpr` | `{x: 1, y: 2}` |
| Map literal | `xnkMapLiteral` | `["a" => 1]` |

### TypedExprDef Mapping

| Haxe TypedExprDef | XLang Node | Notes |
|-------------------|------------|-------|
| `TConst` | `xnkIntLit`, `xnkFloatLit`, `xnkStringLit`, `xnkBoolLit`, `xnkNilLit` | Based on constant type |
| `TLocal` | `xnkIdentifier` | Local variable reference |
| `TArray` | `xnkIndexExpr` | Array access `e1[e2]` |
| `TBinop` | `xnkBinaryExpr` | Binary operations |
| `TField` | `xnkMemberAccessExpr` | Field access `e.field` |
| `TTypeExpr` | `xnkNamedType` | Type reference |
| `TParenthesis` | (transparent) | Just return inner expression |
| `TObjectDecl` | `xnkDictExpr` | Object declaration |
| `TArrayDecl` | `xnkArrayLiteral` | Array declaration |
| `TCall` | `xnkCallExpr` | Function call |
| `TNew` | `xnkCallExpr` | Constructor call |
| `TUnop` | `xnkUnaryExpr` | Unary operations |
| `TFunction` | `xnkLambdaExpr` | Anonymous function |
| `TVar` | `xnkVarDecl` | Variable declaration |
| `TBlock` | `xnkBlockStmt` | Block statement |
| `TFor` | `xnkForeachStmt` | For loop (iterator-based) |
| `TIf` | `xnkIfStmt` | Conditional |
| `TWhile` | `xnkWhileStmt` or `xnkDoWhileStmt` | Based on `normalWhile` flag |
| `TSwitch` | `xnkSwitchStmt` | Switch/pattern matching |
| `TTry` | `xnkTryStmt` | Try-catch |
| `TReturn` | `xnkReturnStmt` | Return statement |
| `TBreak` | `xnkBreakStmt` | Break statement |
| `TContinue` | `xnkContinueStmt` | Continue statement |
| `TThrow` | `xnkThrowStmt` | Throw exception |
| `TCast` | `xnkCastExpr` | Type casting |
| `TMeta` | `xnkMetadata` | Metadata annotation |
| `TEnumParameter` | `xnkMemberAccessExpr` | Enum parameter access |
| `TEnumIndex` | `xnkCallExpr` | Enum index access |
| `TIdent` | `xnkIdentifier` | Identifier |

### ExprDef Mapping (Untyped AST)

| Haxe ExprDef | XLang Node | Notes |
|--------------|------------|-------|
| `EConst` | Literal nodes | Based on constant type |
| `EArray` | `xnkIndexExpr` | Array access |
| `EBinop` | `xnkBinaryExpr` | Binary operator |
| `EField` | `xnkMemberAccessExpr` | Field access |
| `EParenthesis` | (transparent) | Unwrap parentheses |
| `EObjectDecl` | `xnkDictExpr` | Object literal |
| `EArrayDecl` | `xnkArrayLiteral` | Array literal |
| `ECall` | `xnkCallExpr` | Function call |
| `ENew` | `xnkCallExpr` | Constructor |
| `EUnop` | `xnkUnaryExpr` | Unary operator |
| `EVars` | `xnkVarDecl` (multiple) | Variable declarations |
| `EFunction` | `xnkFuncDecl` or `xnkLambdaExpr` | Named or anonymous function |
| `EBlock` | `xnkBlockStmt` | Block |
| `EFor` | `xnkForeachStmt` | For loop |
| `EIf` | `xnkIfStmt` | If statement |
| `EWhile` | `xnkWhileStmt` or `xnkDoWhileStmt` | While loop |
| `ESwitch` | `xnkSwitchStmt` | Switch statement |
| `ETry` | `xnkTryStmt` | Try-catch |
| `EReturn` | `xnkReturnStmt` | Return |
| `EBreak` | `xnkBreakStmt` | Break |
| `EContinue` | `xnkContinueStmt` | Continue |
| `EUntyped` | (transparent) | Unwrap untyped |
| `EThrow` | `xnkThrowStmt` | Throw |
| `ECast` | `xnkCastExpr` | Cast |
| `ETernary` | `xnkTernaryExpr` | Ternary conditional |
| `ECheckType` | `xnkCastExpr` | Type check |
| `EMeta` | `xnkMetadata` | Metadata |
| `EIs` | `xnkBinaryExpr` | Type checking (is operator) |

## Statements

| Haxe Statement | XLang Node | Notes |
|----------------|------------|-------|
| Block `{ }` | `xnkBlockStmt` | Statement block |
| If-else | `xnkIfStmt` | Conditional statement |
| While loop | `xnkWhileStmt` | While loop |
| Do-while loop | `xnkDoWhileStmt` | Do-while loop |
| For loop | `xnkForeachStmt` | Iterator-based for |
| Switch | `xnkSwitchStmt` | Pattern matching switch |
| Try-catch | `xnkTryStmt` | Exception handling |
| Return | `xnkReturnStmt` | Return statement |
| Break | `xnkBreakStmt` | Break statement |
| Continue | `xnkContinueStmt` | Continue statement |
| Throw | `xnkThrowStmt` | Throw exception |
| Variable declaration | `xnkVarDecl` | `var x = value` |

## Operators

### Binary Operators
| Haxe Operator | XLang Mapping |
|---------------|---------------|
| `+`, `-`, `*`, `/`, `%` | Arithmetic operators |
| `==`, `!=`, `<`, `>`, `<=`, `>=` | Comparison operators |
| `&&`, `\|\|` | Logical operators |
| `&`, `\|`, `^`, `<<`, `>>`, `>>>` | Bitwise operators |
| `=`, `+=`, `-=`, etc. | Assignment operators (via `xnkAsgn`) |

### Unary Operators
| Haxe Operator | XLang Mapping |
|---------------|---------------|
| `!`, `-`, `~` | Prefix unary |
| `++`, `--` | Prefix/postfix increment/decrement |

## Haxe-Specific Features

| Haxe Feature | XLang Mapping | Notes |
|--------------|---------------|-------|
| Abstract types | `xnkAbstractDecl` | With `from`/`to` conversions |
| Enum constructors | `xnkEnumMember` | ADT constructors |
| Metadata `@:meta` | `xnkMetadata` | Compiler metadata |
| Type parameters `<T>` | `xnkGenericParameter` | Generic parameters |
| Constraints `<T:Constraint>` | Via `xnkGenericParameter.constraints` | Type constraints |
| Static extensions | Special metadata | Via `@:using` metadata |
| Inline functions | Metadata flag | Via `@:inline` metadata |
| Macro expressions | Not directly mapped | Compile-time only |
| String interpolation `'$var'` | `xnkStringInterpolation` | Single-quoted strings |
| Array comprehension | `xnkComprehensionExpr` | `[for (x in arr) x * 2]` |

## Type System Features

| Haxe Type Feature | XLang Mapping |
|-------------------|---------------|
| Type inference | Omit type in `xnkVarDecl.declType` |
| Optional type annotations | Use `Option[XLangNode]` for types |
| Nullable types `Null<T>` | `xnkGenericType` with `Null` |
| Anonymous structures | `xnkStructDecl` |
| Function types `A -> B` | `xnkFuncType` |
| Structural subtyping | Handled at type level |

## Access Modifiers

| Haxe Modifier | XLang Mapping |
|---------------|---------------|
| `public` | Default (no flag needed) |
| `private` | `isPrivate` flag |
| `static` | `isStatic` flag |
| `inline` | `@:inline` metadata |
| `final` | `isFinal` flag |
| `override` | `isOverride` flag |
| `dynamic` | `@:dynamic` metadata |

## Special Constructs

| Haxe Construct | XLang Node | Notes |
|----------------|------------|-------|
| Property getter | `xnkPropertyDecl.getter` | Custom getter |
| Property setter | `xnkPropertyDecl.setter` | Custom setter |
| Constructor initializer | `xnkConstructorDecl.constructorInitializers` | Field initializers |
| Super call | `xnkCallExpr` with `xnkBaseExpr` | `super.method()` |
| This reference | `xnkThisExpr` | `this` keyword |
| Type path `pack.Type` | `xnkQualifiedName` | Fully qualified names |

## Error Handling

| Haxe Construct | XLang Node |
|----------------|------------|
| `try { } catch(e:Type) { }` | `xnkTryStmt` with `xnkCatchStmt` |
| `throw expr` | `xnkThrowStmt` |

## Notes

1. **Typed vs Untyped AST**: The parser should primarily work with Haxe's typed AST (`TypedExpr`/`TypedExprDef`) as it provides more semantic information.

2. **Parentheses**: Parenthesized expressions (`TParenthesis`) are transparent and should return the inner expression directly.

3. **Type Information**: Haxe's typed AST includes type information for every expression, which should be preserved where XLang supports it.

4. **Pattern Matching**: Haxe's switch with pattern matching should map to `xnkSwitchStmt` with appropriate case patterns.

5. **Metadata**: Haxe's extensive metadata system should be preserved using `xnkMetadata` nodes.

6. **String Interpolation**: Haxe uses single quotes for interpolated strings: `'Hello $name'`.

7. **Array Comprehension**: Haxe supports array comprehension syntax which should map to `xnkComprehensionExpr`.

8. **Abstract Types**: Haxe's abstract types with implicit conversions are unique and need special handling via `xnkAbstractDecl`.

## References

- Haxe Manual: https://haxe.org/manual/introduction.html
- Language Features: https://haxe.org/documentation/introduction/language-features.html
- Expr API: https://api.haxe.org/haxe/macro/Expr.html
- TypedExpr API: https://api.haxe.org/haxe/macro/TypedExpr.html
- Type.hx Source: https://github.com/HaxeFoundation/haxe/blob/4.3.3/std/haxe/macro/Type.hx
