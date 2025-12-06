# AST Printer - Nim Code Generator

A comprehensive AST-to-source-code printer for MyNimNode trees. Converts AST structures back into valid Nim source code, similar to `repr` but works at runtime.

## Features

- **Complete Coverage**: Handles all major Nim constructs
- **Forth-Style Design**: Uses small, focused helper functions for each node type
- **Proper Indentation**: Maintains correct indentation levels
- **Runtime Operation**: Works at runtime (unlike compile-time `repr`)

## Supported Constructs

### Literals
- Integer, float, character literals
- String literals (normal, raw, triple-quoted)
- Nil literals

### Expressions
- Infix operators: `a + b`, `x > 0`
- Prefix operators: `-a`, `not x`
- Postfix operators: `name*`
- Function calls: `func(arg1, arg2)`
- Dot expressions: `obj.field`
- Bracket expressions: `arr[i]`, `seq[0..5]`
- Tuples and arrays: `(1, 2, 3)`, `[1, 2, 3]`
- Object constructors: `Person(name: "Alice")`
- Colon expressions: `key: value`

### Statements
- Variable declarations: `var x: int = 0`
- Let bindings: `let y = compute()`
- Const declarations: `const PI = 3.14`
- Assignments: `x = 42`
- Control flow:
  - If/elif/else statements
  - While loops
  - For loops
  - Case statements
  - Block statements
- Return, yield, discard, break, continue statements
- Raise statements

### Declarations
- Procedure definitions: `proc name(args): RetType =`
- Function definitions: `func name(args): RetType =`
- Method definitions
- Iterator definitions
- Template definitions
- Macro definitions

### Types
- Type sections and definitions
- Object types with inheritance
- Reference and pointer types
- Distinct types
- Enum types
- Tuple types
- Procedure types

### Module System
- Import statements: `import module1, module2`
- Export statements: `export symbol1, symbol2`
- From imports: `from module import symbol`
- Include statements

### Pragmas
- Pragma expressions: `{.inline.}`, `{.noSideEffect.}`
- Pragma blocks

### Other
- Comments: `# comment text`

## Usage

```nim
import astprinter

# Build an AST
let ast = newInfixCall("+",
  newIdentNode("x"),
  newIntLitNode(42)
)

# Convert to Nim code
echo toNimCode(ast)  # Outputs: x + 42

# Or use the $ operator (if no conflicts)
echo $ast
```

## API

### Main Functions

- `toNimCode(node: MyNimNode): string` - Convert AST to Nim code
- `$(node: MyNimNode): string` - Operator overload for conversion

## Implementation Details

### Forth-Style Architecture

The printer uses small, focused helper functions following Forth principles:

1. **Single Responsibility**: Each render function handles one node type
2. **Clear Names**: `renderInfix`, `renderProcDef`, `renderTypeSection`
3. **Composable**: Functions call each other to build complex output
4. **Easy to Maintain**: Each function is ~5-15 lines

### Helper Function Categories

```nim
# Basic helpers
proc ind(level: int): string                    # Indentation
proc renderIntLit(n: MyNimNode): string        # Integer literals
proc renderStrLit(n: MyNimNode): string        # String literals

# Expression renderers
proc renderInfix(n: MyNimNode, indent: int): string
proc renderCall(n: MyNimNode, indent: int): string
proc renderDotExpr(n: MyNimNode, indent: int): string

# Statement renderers
proc renderVarSection(n: MyNimNode, indent: int): string
proc renderIfStmt(n: MyNimNode, indent: int): string
proc renderForStmt(n: MyNimNode, indent: int): string

# Declaration renderers
proc renderProcDef(n: MyNimNode, indent: int): string
proc renderTypeDef(n: MyNimNode, indent: int): string

# Main dispatcher
proc renderNode(n: MyNimNode, indent: int = 0): string
```

### Indentation Handling

- Uses 2-space indentation (standard Nim style)
- Tracks indent level through recursive calls
- Helper function `ind(level)` generates indent strings

### Examples

#### Simple Expression
```nim
let expr = newInfixCall("+", newIdentNode("x"), newIntLitNode(42))
# Outputs: x + 42
```

#### Variable Declaration
```nim
let varStmt = newVarStmt(
  newIdentNode("count"),
  newIdentNode("int"),
  newIntLitNode(0)
)
# Outputs: var count: int = 0
```

#### Procedure Definition
```nim
let procNode = buildProcDef("greet", ["name: string"], body)
# Outputs:
# proc greet(name: string) =
#   echo("Hello, " & name)
```

#### Type Definition
```nim
let typeNode = buildObjectType("Person", [
  ("name", "string"),
  ("age", "int")
])
# Outputs:
# type
#   Person = object
#     name: string
#     age: int
```

## Testing

Run the test suite:
```bash
nim c -r test_astprinter.nim
```

Tests include:
- All literal types
- Expression constructs
- Statement forms
- Procedure/function definitions
- Type definitions
- Complete programs

## Design Philosophy

1. **Readability**: Generated code should be human-readable
2. **Correctness**: Output should be valid, compilable Nim code
3. **Maintainability**: Small functions, clear responsibilities
4. **Completeness**: Handle all common Nim constructs

## Future Enhancements

Potential additions:
- Pretty-printing options (line width, style preferences)
- Comment preservation and formatting
- Syntax highlighting hooks
- AST validation before rendering
- Custom indentation styles
- Parenthesis minimization

## Use Cases

1. **Transpilers**: Generate Nim code from other languages
2. **Code Generation**: Programmatically create Nim code
3. **AST Visualization**: Display AST structures as readable code
4. **Metaprogramming**: Runtime code generation
5. **Documentation**: Show code examples from AST
6. **Testing**: Verify AST transformations

## See Also

- [my_nim_node.nim](src/my_nim_node.nim) - AST node structure
- [test_astprinter.nim](test_astprinter.nim) - Comprehensive tests
- Nim's compile-time `repr` - Similar functionality but compile-time only
