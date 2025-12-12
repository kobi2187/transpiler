# Go to XLang Parser

Comprehensive Go language parser that converts Go source code to XLang intermediate representation.

## Overview

This parser uses Go's standard `go/ast` and `go/parser` packages to parse Go source code into an Abstract Syntax Tree (AST), then converts it to XLang JSON format for use in the transpiler pipeline.

## Architecture

The parser consists of two stages:

1. **go_to_xlang.go** - Native Go parser that:
   - Uses `go/ast` and `go/parser` from the Go standard library
   - Parses `.go` source files into Go's native AST
   - Converts to intermediate JSON format
   - Handles all 52+ Go AST node types

2. **go_json_to_xlang.nim** - Nim converter that:
   - Reads the intermediate JSON from stage 1
   - Converts to canonical XLang JSON format
   - Maps Go constructs to XLang node types
   - Outputs XLang-compatible JSON

## Usage

### Compile the Parser

```bash
go build -o go-xlang-parser go_to_xlang.go
```

### Parse a Go File

```bash
./go-xlang-parser myfile.go
```

This creates `myfile.xlang.json` with the parsed AST.

### Parse a Directory

```bash
./go-xlang-parser ./mypackage
```

Recursively processes all `.go` files in the directory.

### Convert to XLang Format (Optional Stage 2)

```bash
nim c -r go_json_to_xlang.nim myfile.xlang.json > myfile.final.json
```

## Supported Go Constructs

### Complete AST Coverage (52+ Node Types)

#### Declarations (3 types)
- ✅ `BadDecl` - Syntax error placeholder
- ✅ `FuncDecl` - Function and method declarations
- ✅ `GenDecl` - Generic declarations (import, type, const, var)

#### Specifications (3 types)
- ✅ `ImportSpec` - Import statements
- ✅ `TypeSpec` - Type definitions
- ✅ `ValueSpec` - Variable and constant declarations

#### Statements (19 types)
- ✅ `AssignStmt` - Assignment (=, :=, +=, etc.)
- ✅ `BadStmt` - Syntax error placeholder
- ✅ `BlockStmt` - Block of statements `{ }`
- ✅ `BranchStmt` - `break`, `continue`, `goto`, `fallthrough`
- ✅ `CaseClause` - `case` in switch statements
- ✅ `CommClause` - `case` in select statements
- ✅ `DeclStmt` - Declaration in statement position
- ✅ `DeferStmt` - Defer statements
- ✅ `EmptyStmt` - Empty statements (semicolon)
- ✅ `ExprStmt` - Expression as statement
- ✅ `ForStmt` - For loops (all variants)
- ✅ `GoStmt` - Goroutine launch (`go` keyword)
- ✅ `IfStmt` - If statements with optional init
- ✅ `IncDecStmt` - Increment (`++`) and decrement (`--`)
- ✅ `LabeledStmt` - Labeled statements
- ✅ `RangeStmt` - Range loops
- ✅ `ReturnStmt` - Return statements
- ✅ `SelectStmt` - Select on channels
- ✅ `SendStmt` - Channel send (`ch <- value`)
- ✅ `SwitchStmt` - Switch statements
- ✅ `TypeSwitchStmt` - Type switch statements

#### Expressions (18+ types)
- ✅ `BadExpr` - Syntax error placeholder
- ✅ `BasicLit` - Literals (int, float, string, char)
- ✅ `BinaryExpr` - Binary operations (+, -, *, /, etc.)
- ✅ `CallExpr` - Function/method calls
- ✅ `CompositeLit` - Composite literals (struct, array, map, slice)
- ✅ `Ellipsis` - Variadic parameters (`...`)
- ✅ `FuncLit` - Function literals (anonymous functions)
- ✅ `Ident` - Identifiers
- ✅ `IndexExpr` - Indexing operations (`a[i]`)
- ✅ `IndexListExpr` - Multiple indices (generics instantiation)
- ✅ `KeyValueExpr` - Key-value pairs in composites
- ✅ `ParenExpr` - Parenthesized expressions
- ✅ `SelectorExpr` - Member access (`x.y`)
- ✅ `SliceExpr` - Slice operations (`a[i:j]`, `a[i:j:k]`)
- ✅ `StarExpr` - Pointer dereference (`*p`) and pointer type
- ✅ `TypeAssertExpr` - Type assertions (`x.(T)`)
- ✅ `UnaryExpr` - Unary operations (!, -, +, ^, &, <-)

#### Type Expressions (6 types)
- ✅ `ArrayType` - Array and slice types
- ✅ `ChanType` - Channel types (bidirectional, send-only, receive-only)
- ✅ `FuncType` - Function signatures
- ✅ `InterfaceType` - Interface definitions
- ✅ `MapType` - Map types
- ✅ `StructType` - Struct definitions

#### Other Nodes
- ✅ `Field` - Struct fields and function parameters
- ✅ `FieldList` - Lists of fields/parameters
- ✅ `Comment` - Single comments
- ✅ `CommentGroup` - Comment blocks

## Go-Specific Features

### Goroutines
```go
go processData(data)
go func() {
    fmt.Println("async")
}()
```

Parsed as `GoStmt` containing a `CallExpr`.

### Channels
```go
ch := make(chan int)
ch <- 42              // SendStmt
value := <-ch         // UnaryExpr with op="<-"
val, ok := <-ch       // UnaryExpr in AssignStmt
```

### Select Statements
```go
select {
case msg := <-ch1:
    process(msg)
case ch2 <- value:
    sent()
default:
    timeout()
}
```

Parsed as `SelectStmt` with `CommClause` cases.

### Defer
```go
defer file.Close()
defer cleanup()
```

Parsed as `DeferStmt`.

### Type Switches
```go
switch v := x.(type) {
case int:
    handleInt(v)
case string:
    handleString(v)
}
```

Parsed as `TypeSwitchStmt`.

### Multiple Return Values
```go
func divmod(a, b int) (int, int) {
    return a / b, a % b
}

quotient, remainder := divmod(10, 3)
```

### Named Returns
```go
func split(sum int) (x, y int) {
    x = sum * 4 / 9
    y = sum - x
    return  // naked return
}
```

### Method Receivers
```go
func (p Point) Distance() float64 {
    return math.Sqrt(p.X*p.X + p.Y*p.Y)
}

func (p *Point) Scale(factor float64) {
    p.X *= factor
    p.Y *= factor
}
```

Parsed as `FuncDecl` with `Recv` field.

### Struct Tags
```go
type User struct {
    ID   int    `json:"id" db:"user_id"`
    Name string `json:"name"`
}
```

Tags stored in `Field` nodes.

### Interface Embedding
```go
type ReadWriter interface {
    Reader
    Writer
    Close() error
}
```

### Type Embedding (Anonymous Fields)
```go
type Employee struct {
    Person  // embedded
    ID int
}
```

### Generics (Go 1.18+)
```go
func Map[T, U any](slice []T, f func(T) U) []U {
    // ...
}

type Stack[T any] struct {
    items []T
}
```

Type parameters stored in `TypeParams` field.

### Type Constraints
```go
type Number interface {
    int | int64 | float64
}

func Min[T Number](a, b T) T {
    if a < b {
        return a
    }
    return b
}
```

### Variadic Functions
```go
func sum(nums ...int) int {
    // ...
}

// Call with slice
result := sum(slice...)
```

Ellipsis tracked in both parameter definition and call site.

### Short Variable Declaration
```go
x := 42
a, b := divmod(10, 3)
```

Parsed as `AssignStmt` with `Tok` = `":="`.

### Blank Identifier
```go
_, err := someFunc()
for _, v := range slice {
    // ...
}
```

Represented as `Ident` with name `"_"`.

## Test Coverage

The `test_comprehensive.go` file demonstrates all supported constructs:
- All declaration types
- All statement types
- All expression types
- All Go-specific features (goroutines, channels, defer, select)
- Generics and type constraints
- Methods with value and pointer receivers
- Interface and struct embedding
- Variadic functions
- Type assertions and type switches
- All operators (arithmetic, logical, bitwise, comparison)
- Comments

### Running Tests

```bash
./go-xlang-parser test_comprehensive.go
```

Output shows statistics for all parsed node types (52+ different constructs).

## Parser Statistics

Example output from test file:
```
Go AST Node Statistics:
=======================
File                : 1
Import              : 6
FuncDecl            : 16
TypeDecl            : 10
ConstDecl           : 2
VarDecl             : 7
StructType          : 4
InterfaceType       : 7
IfStmt              : 11
SwitchStmt          : 3
TypeSwitchStmt      : 1
ForStmt             : 5
RangeStmt           : 5
DeferStmt           : 2
GoStmt              : 3
SelectStmt          : 1
CommClause          : 3
SendStmt            : 2
BinaryExpr          : 48
UnaryExpr           : 7
CallExpr            : 57
CompositeLit        : 11
TypeAssertExpr      : 2
... and more

Total node types: 52
```

## XLang Mapping

Seeالبحر`basis_docs_claude/go-xlang-mapping.md` for complete mapping of Go constructs to XLang node types.

### Common Mappings

| Go AST | XLang Node | Notes |
|--------|------------|-------|
| `FuncDecl` | `xnkFuncDecl` / `xnkMethodDecl` | Based on receiver |
| `IfStmt` | `xnkIfStmt` | With optional init statement |
| `ForStmt` | `xnkForStmt` / `xnkWhileStmt` | Based on structure |
| `RangeStmt` | `xnkForeachStmt` | Range loop |
| `DeferStmt` | `xnkDeferStmt` | Defer statement |
| `GoStmt` | `xnkCallExpr` + metadata | Goroutine marker |
| `SelectStmt` | `xnkSwitchStmt` + metadata | Channel select |
| `ChanType` | Custom channel type | Go-specific |
| `TypeSwitchStmt` | `xnkTypeSwitchStmt` | Type switch |
| `CompositeLit` | `xnkArrayLiteral` / `xnkMapLiteral` | Based on type |

## Output Format

### Stage 1: Intermediate JSON

```json
{
  "kind": "File",
  "data": {
    "Name": "main",
    "Imports": [...],
    "Decls": [
      {
        "kind": "FuncDecl",
        "data": {
          "Name": "main",
          "Type": {...},
          "Body": {...}
        }
      }
    ]
  }
}
```

### Stage 2: XLang JSON (after Nim converter)

```json
{
  "kind": "xnkFile",
  "fileName": "main.go",
  "moduleDecls": [
    {
      "kind": "xnkFuncDecl",
      "funcName": "main",
      "params": [],
      "returnType": null,
      "body": {...}
    }
  ]
}
```

## Implementation Notes

- Uses Go's standard library parsers (no external dependencies)
- Handles all language features through Go 1.22
- Preserves comments and documentation
- Tracks source positions (can be enabled)
- Supports both single files and directories
- Provides detailed statistics about parsed constructs

## Error Handling

Syntax errors are captured in `BadDecl`, `BadStmt`, and `BadExpr` nodes, allowing partial parsing of files with errors.

## Performance

The parser is efficient for large codebases:
- Single files: < 100ms for most files
- Packages: Processes in parallel (directory walk)
- Memory: Scales linearly with AST size

## References

- [Go Language Specification](https://go.dev/ref/spec)
- [go/ast Package Documentation](https://pkg.go.dev/go/ast)
- [go/parser Package Documentation](https://pkg.go.dev/go/parser)
- [XLang Type System](../../xlangtypes.nim)

## Future Enhancements

- [ ] Source position preservation in XLang output
- [ ] Symbol resolution and type information
- [ ] Cross-reference generation
- [ ] Direct XLang output (skip intermediate JSON)
- [ ] Incremental parsing support

## Contributing

When adding new Go language features:
1. Add AST node handling in `convertToXLang()`
2. Update `go-xlang-mapping.md`
3. Add test cases to `test_comprehensive.go`
4. Update Nim converter (`go_json_to_xlang.nim`)
5. Verify with `./go-xlang-parser test_comprehensive.go`
