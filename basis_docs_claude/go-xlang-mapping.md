# Go to XLang Mapping

## Overview

This document provides a comprehensive mapping of Go language constructs to XLang intermediate representation. Go is parsed using the standard `go/ast` and `go/parser` packages from the Go standard library.

## References

- [Go Language Specification](https://go.dev/ref/spec)
- [go/ast Package Documentation](https://pkg.go.dev/go/ast)
- [go/parser Package Documentation](https://pkg.go.dev/go/parser)

## AST Node Type Mapping

### Declarations (ast.Decl)

Go has 3 declaration types:

| Go AST Type | XLang Node | Notes |
|-------------|------------|-------|
| `ast.BadDecl` | `xnkUnknown` | Syntax error placeholder |
| `ast.FuncDecl` | `xnkFuncDecl` / `xnkMethodDecl` | Function or method based on receiver |
| `ast.GenDecl` | Multiple | Generic declaration (import/const/type/var) |

#### GenDecl Subtypes

`ast.GenDecl` with different `Tok` values maps to different XLang nodes:

| GenDecl.Tok | XLang Node | Notes |
|-------------|------------|-------|
| `token.IMPORT` | `xnkImportStmt` | Import declaration |
| `token.CONST` | `xnkConstDecl` | Constant declaration |
| `token.TYPE` | `xnkStructDecl` / `xnkInterfaceDecl` / `xnkTypeAlias` | Based on type |
| `token.VAR` | `xnkVarDecl` | Variable declaration |

### Specifications (ast.Spec)

| Go AST Type | XLang Node | Notes |
|-------------|------------|-------|
| `ast.ImportSpec` | `xnkImport` | Single import statement |
| `ast.TypeSpec` | `xnkStructDecl` / `xnkInterfaceDecl` / `xnkTypeAlias` | Based on underlying type |
| `ast.ValueSpec` | `xnkVarDecl` / `xnkConstDecl` | Variable or constant |

### Statements (ast.Stmt)

Go has 19 statement types:

| Go AST Type | XLang Node | Notes |
|-------------|------------|-------|
| `ast.BadStmt` | `xnkUnknown` | Syntax error placeholder |
| `ast.BlockStmt` | `xnkBlockStmt` | Block of statements |
| `ast.BranchStmt` | `xnkBreakStmt` / `xnkContinueStmt` / `xnkGotoStmt` | Based on `Tok` (BREAK/CONTINUE/GOTO/FALLTHROUGH) |
| `ast.CaseClause` | `xnkCaseClause` | Case in switch statement |
| `ast.CommClause` | `xnkCaseClause` | Case in select statement |
| `ast.DeclStmt` | Nested decl | Declaration in statement position |
| `ast.DeferStmt` | `xnkDeferStmt` | Defer statement |
| `ast.EmptyStmt` | `xnkEmptyStmt` | Empty statement (semicolon) |
| `ast.ExprStmt` | Nested expr | Expression as statement |
| `ast.ForStmt` | `xnkForStmt` / `xnkWhileStmt` | For loop or while loop |
| `ast.GoStmt` | Custom or `xnkCallExpr` with metadata | Goroutine launch |
| `ast.IfStmt` | `xnkIfStmt` | If statement |
| `ast.IncDecStmt` | `xnkUnaryExpr` as stmt | `++` / `--` statement |
| `ast.LabeledStmt` | `xnkLabeledStmt` | Labeled statement |
| `ast.RangeStmt` | `xnkForeachStmt` | Range loop |
| `ast.ReturnStmt` | `xnkReturnStmt` | Return statement |
| `ast.SelectStmt` | `xnkSwitchStmt` with metadata | Select on channels |
| `ast.SwitchStmt` | `xnkSwitchStmt` | Switch statement |
| `ast.TypeSwitchStmt` | `xnkTypeSwitchStmt` | Type switch |
| `ast.SendStmt` | `xnkBinaryExpr` with op="<-" | Channel send |

### Expressions (ast.Expr)

Go has 18+ expression types:

| Go AST Type | XLang Node | Notes |
|-------------|------------|-------|
| `ast.BadExpr` | `xnkUnknown` | Syntax error placeholder |
| `ast.BasicLit` | `xnkIntLit` / `xnkFloatLit` / `xnkStringLit` / `xnkCharLit` | Based on `Kind` |
| `ast.BinaryExpr` | `xnkBinaryExpr` | Binary operations |
| `ast.CallExpr` | `xnkCallExpr` | Function/method calls |
| `ast.CompositeLit` | `xnkArrayLiteral` / `xnkMapLiteral` / `xnkStructLiteral` | Based on type |
| `ast.Ellipsis` | Special parameter marker | `...` in varargs |
| `ast.FuncLit` | `xnkLambdaExpr` | Anonymous function |
| `ast.Ident` | `xnkIdentifier` | Identifier |
| `ast.IndexExpr` | `xnkIndexExpr` | Array/map/slice indexing |
| `ast.IndexListExpr` | `xnkIndexExpr` with multiple indices | Generics type instantiation |
| `ast.KeyValueExpr` | `xnkDictEntry` | Key-value in composite lit |
| `ast.ParenExpr` | Transparent | Parenthesized expression |
| `ast.SelectorExpr` | `xnkMemberAccessExpr` / `xnkQualifiedName` | Member access or package.Name |
| `ast.SliceExpr` | `xnkSliceExpr` | Slice operation |
| `ast.StarExpr` | `xnkUnaryExpr` with op="*" / `xnkPointerType` | Dereference or pointer type |
| `ast.TypeAssertExpr` | `xnkTypeAssertion` | Type assertion `x.(T)` |
| `ast.UnaryExpr` | `xnkUnaryExpr` / `xnkRefExpr` | Unary ops, `&` for address-of |

### Type Expressions

| Go AST Type | XLang Node | Notes |
|-------------|------------|-------|
| `ast.ArrayType` | `xnkArrayType` | Array or slice type |
| `ast.ChanType` | Custom channel type | Go-specific channel |
| `ast.FuncType` | `xnkFuncType` | Function signature |
| `ast.InterfaceType` | `xnkInterfaceDecl` | Interface type |
| `ast.MapType` | `xnkMapType` | Map type |
| `ast.StructType` | `xnkStructDecl` | Struct type |

### Other Nodes

| Go AST Type | XLang Node | Notes |
|-------------|------------|-------|
| `ast.Field` | `xnkFieldDecl` / `xnkParameter` | Context-dependent |
| `ast.FieldList` | Array of fields/params | Used in many contexts |
| `ast.File` | `xnkFile` | Complete source file |
| `ast.Comment` | `xnkComment` | Single comment |
| `ast.CommentGroup` | `xnkComment` | Comment block |
| `ast.Package` | Multiple files | Deprecated in go/ast |

## Go-Specific Constructs

### Goroutines (go statement)

**Go Code**:
```go
go myFunc(arg)
```

**XLang Representation**:
```json
{
  "kind": "xnkCallExpr",
  "callee": {"kind": "xnkIdentifier", "identName": "myFunc"},
  "args": [{"kind": "xnkIdentifier", "identName": "arg"}],
  "isGoroutine": true
}
```

Or use metadata/attributes to mark as goroutine.

### Defer Statement

**Go Code**:
```go
defer file.Close()
```

**XLang**:
```json
{
  "kind": "xnkDeferStmt",
  "staticBody": {
    "kind": "xnkCallExpr",
    "callee": {
      "kind": "xnkMemberAccessExpr",
      "memberExpr": {"kind": "xnkIdentifier", "identName": "file"},
      "memberName": "Close"
    },
    "args": []
  }
}
```

### Channels

**Channel Type**:
```go
chan int           // bidirectional
chan<- int        // send-only
<-chan int        // receive-only
```

**XLang**: Use metadata to encode channel direction:
```json
{
  "kind": "xnkNamedType",
  "typeName": "channel",
  "channelElementType": {"kind": "xnkNamedType", "typeName": "int"},
  "channelDirection": "bidirectional"
}
```

**Channel Send**:
```go
ch <- value
```

**XLang**:
```json
{
  "kind": "xnkBinaryExpr",
  "binaryLeft": {"kind": "xnkIdentifier", "identName": "ch"},
  "binaryOp": "<-",
  "binaryRight": {"kind": "xnkIdentifier", "identName": "value"}
}
```

**Channel Receive**:
```go
value := <-ch
value, ok := <-ch  // with comma-ok
```

**XLang**:
```json
{
  "kind": "xnkUnaryExpr",
  "unaryOp": "<-",
  "unaryOperand": {"kind": "xnkIdentifier", "identName": "ch"}
}
```

### Select Statement

**Go Code**:
```go
select {
case msg := <-ch1:
    fmt.Println(msg)
case ch2 <- value:
    fmt.Println("sent")
default:
    fmt.Println("no communication")
}
```

**XLang**: Use `xnkSwitchStmt` with metadata or custom handling for select.

### Type Switch

**Go Code**:
```go
switch v := x.(type) {
case int:
    fmt.Println("int")
case string:
    fmt.Println("string")
}
```

**XLang**:
```json
{
  "kind": "xnkTypeSwitchStmt",
  "typeSwitchExpr": {"kind": "xnkIdentifier", "identName": "x"},
  "typeSwitchVar": {"kind": "xnkIdentifier", "identName": "v"},
  "typeSwitchCases": [...]
}
```

### Multiple Return Values

**Go Code**:
```go
func divmod(a, b int) (int, int) {
    return a / b, a % b
}
```

**XLang**: Use `xnkTupleExpr` for return type:
```json
{
  "kind": "xnkFuncDecl",
  "funcName": "divmod",
  "params": [...],
  "returnType": {
    "kind": "xnkTupleExpr",
    "elements": [
      {"kind": "xnkNamedType", "typeName": "int"},
      {"kind": "xnkNamedType", "typeName": "int"}
    ]
  },
  "body": {
    "kind": "xnkReturnStmt",
    "returnExpr": {
      "kind": "xnkTupleExpr",
      "elements": [...]
    }
  }
}
```

### Named Return Values

**Go Code**:
```go
func divmod(a, b int) (quotient, remainder int) {
    quotient = a / b
    remainder = a % b
    return
}
```

**XLang**: Named returns are parameters with names in return type.

### Method Declarations

**Go Code**:
```go
func (p *Point) Distance() float64 {
    return math.Sqrt(p.X*p.X + p.Y*p.Y)
}
```

**XLang**:
```json
{
  "kind": "xnkMethodDecl",
  "receiver": {
    "kind": "xnkParameter",
    "paramName": "p",
    "paramType": {
      "kind": "xnkPointerType",
      "referentType": {"kind": "xnkNamedType", "typeName": "Point"}
    }
  },
  "methodName": "Distance",
  "mparams": [],
  "mreturnType": {"kind": "xnkNamedType", "typeName": "float64"},
  "mbody": {...}
}
```

### Short Variable Declaration

**Go Code**:
```go
x := 42
```

**XLang**:
```json
{
  "kind": "xnkVarDecl",
  "declName": "x",
  "declType": null,
  "initializer": {"kind": "xnkIntLit", "literalValue": "42"}
}
```

### Blank Identifier

**Go Code**:
```go
_, err := someFunc()
```

**XLang**: Use identifier with name "_":
```json
{
  "kind": "xnkIdentifier",
  "identName": "_"
}
```

### Variadic Functions

**Go Code**:
```go
func sum(nums ...int) int {
    total := 0
    for _, num := range nums {
        total += num
    }
    return total
}
```

**XLang**: Mark parameter as variadic:
```json
{
  "kind": "xnkParameter",
  "paramName": "nums",
  "paramType": {
    "kind": "xnkArrayType",
    "elementType": {"kind": "xnkNamedType", "typeName": "int"}
  },
  "isVariadic": true
}
```

### Struct Tags

**Go Code**:
```go
type User struct {
    Name  string `json:"name" db:"user_name"`
    Email string `json:"email"`
}
```

**XLang**: Use metadata or custom field:
```json
{
  "kind": "xnkFieldDecl",
  "fieldName": "Name",
  "fieldType": {"kind": "xnkNamedType", "typeName": "string"},
  "fieldTag": "`json:\"name\" db:\"user_name\"`"
}
```

### Type Embedding (Anonymous Fields)

**Go Code**:
```go
type Employee struct {
    Person
    ID int
}
```

**XLang**: Field with no name (anonymous):
```json
{
  "kind": "xnkFieldDecl",
  "fieldName": "",
  "fieldType": {"kind": "xnkNamedType", "typeName": "Person"},
  "isEmbedded": true
}
```

### Interface Embedding

**Go Code**:
```go
type ReadWriteCloser interface {
    Reader
    Writer
    Close() error
}
```

**XLang**: Use `baseTypes` for embedded interfaces:
```json
{
  "kind": "xnkInterfaceDecl",
  "typeNameDecl": "ReadWriteCloser",
  "baseTypes": [
    {"kind": "xnkNamedType", "typeName": "Reader"},
    {"kind": "xnkNamedType", "typeName": "Writer"}
  ],
  "members": [
    {
      "kind": "xnkMethodDecl",
      "methodName": "Close",
      ...
    }
  ]
}
```

### Generics (Type Parameters) - Go 1.18+

**Go Code**:
```go
func Map[T, U any](slice []T, f func(T) U) []U {
    result := make([]U, len(slice))
    for i, v := range slice {
        result[i] = f(v)
    }
    return result
}

type Stack[T any] struct {
    items []T
}
```

**XLang**: Use generic parameters:
```json
{
  "kind": "xnkFuncDecl",
  "funcName": "Map",
  "genericParams": [
    {"kind": "xnkGenericParameter", "genericParamName": "T"},
    {"kind": "xnkGenericParameter", "genericParamName": "U"}
  ],
  "params": [...],
  "returnType": {...},
  "body": {...}
}
```

### Type Constraints (Go 1.18+)

**Go Code**:
```go
func Min[T constraints.Ordered](a, b T) T {
    if a < b {
        return a
    }
    return b
}
```

**XLang**:
```json
{
  "kind": "xnkGenericParameter",
  "genericParamName": "T",
  "genericParamConstraints": [
    {"kind": "xnkNamedType", "typeName": "constraints.Ordered"}
  ]
}
```

## Complete AST Coverage

### All Declarations (3)
- ✅ `ast.BadDecl` → `xnkUnknown`
- ✅ `ast.FuncDecl` → `xnkFuncDecl` / `xnkMethodDecl`
- ✅ `ast.GenDecl` → Multiple based on `Tok`

### All Specifications (3)
- ✅ `ast.ImportSpec` → `xnkImport`
- ✅ `ast.TypeSpec` → Type declarations
- ✅ `ast.ValueSpec` → Variable/constant declarations

### All Statements (19)
- ✅ `ast.BadStmt` → `xnkUnknown`
- ✅ `ast.BlockStmt` → `xnkBlockStmt`
- ✅ `ast.BranchStmt` → Break/Continue/Goto
- ✅ `ast.CaseClause` → `xnkCaseClause`
- ✅ `ast.CommClause` → `xnkCaseClause` (for select)
- ✅ `ast.DeclStmt` → Nested declaration
- ✅ `ast.DeferStmt` → `xnkDeferStmt`
- ✅ `ast.EmptyStmt` → `xnkEmptyStmt`
- ✅ `ast.ExprStmt` → Nested expression
- ✅ `ast.ForStmt` → `xnkForStmt` / `xnkWhileStmt`
- ✅ `ast.GoStmt` → `xnkCallExpr` with metadata
- ✅ `ast.IfStmt` → `xnkIfStmt`
- ✅ `ast.IncDecStmt` → `xnkUnaryExpr` as statement
- ✅ `ast.LabeledStmt` → `xnkLabeledStmt`
- ✅ `ast.RangeStmt` → `xnkForeachStmt`
- ✅ `ast.ReturnStmt` → `xnkReturnStmt`
- ✅ `ast.SelectStmt` → `xnkSwitchStmt` with metadata
- ✅ `ast.SwitchStmt` → `xnkSwitchStmt`
- ✅ `ast.TypeSwitchStmt` → `xnkTypeSwitchStmt`
- ✅ `ast.SendStmt` → `xnkBinaryExpr` with op="<-"

### All Expressions (18+)
- ✅ `ast.BadExpr` → `xnkUnknown`
- ✅ `ast.BasicLit` → Literal nodes
- ✅ `ast.BinaryExpr` → `xnkBinaryExpr`
- ✅ `ast.CallExpr` → `xnkCallExpr`
- ✅ `ast.CompositeLit` → Array/Map/Struct literals
- ✅ `ast.Ellipsis` → Variadic marker
- ✅ `ast.FuncLit` → `xnkLambdaExpr`
- ✅ `ast.Ident` → `xnkIdentifier`
- ✅ `ast.IndexExpr` → `xnkIndexExpr`
- ✅ `ast.IndexListExpr` → `xnkIndexExpr` (generics)
- ✅ `ast.KeyValueExpr` → `xnkDictEntry`
- ✅ `ast.ParenExpr` → Transparent
- ✅ `ast.SelectorExpr` → `xnkMemberAccessExpr`
- ✅ `ast.SliceExpr` → `xnkSliceExpr`
- ✅ `ast.StarExpr` → `xnkUnaryExpr` / `xnkPointerType`
- ✅ `ast.TypeAssertExpr` → `xnkTypeAssertion`
- ✅ `ast.UnaryExpr` → `xnkUnaryExpr` / `xnkRefExpr`

### All Type Expressions (6)
- ✅ `ast.ArrayType` → `xnkArrayType`
- ✅ `ast.ChanType` → Custom channel type
- ✅ `ast.FuncType` → `xnkFuncType`
- ✅ `ast.InterfaceType` → `xnkInterfaceDecl`
- ✅ `ast.MapType` → `xnkMapType`
- ✅ `ast.StructType` → `xnkStructDecl`

## Summary

Go's AST maps cleanly to XLang with minimal extensions needed. The main Go-specific features are:
- Goroutines (`go` statement)
- Defer statements
- Channels and channel operations
- Select statements
- Type switches
- Multiple return values
- Method receivers
- Struct tags
- Type embedding

These are handled through metadata, custom node types already in XLang, or straightforward extensions.
