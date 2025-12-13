# Java to XLang Parser

Comprehensive Java source code parser that converts Java AST to XLang intermediate representation JSON format.

## Features

- **Complete Java Support**: Handles all Java language features from Java 1.0 through Java 24
- **Modern Java Features**:
  - Records (Java 14+)
  - Sealed classes and interfaces (Java 17+)
  - Pattern matching for instanceof (Java 16+)
  - Switch expressions (Java 12+)
  - Text blocks (Java 13+)
  - Try-with-resources (Java 7+)
  - Lambda expressions and method references (Java 8+)
  - Modules (Java 9+)
- **All Statement Types**: 22+ statement types including if, while, for, foreach, switch, try-catch, synchronized, assert, yield, and more
- **All Expression Types**: 37+ expression types including all operators, literals, lambdas, method calls, object creation, and more
- **Type System**: Full support for generics, wildcards, type parameters, arrays, primitives, and intersection/union types
- **Annotations**: Complete annotation support including custom annotations with parameters
- **Nested Constructs**: Inner classes, local classes, anonymous classes, nested interfaces, and enums

## Requirements

- Java 11 or higher
- JavaParser library (3.25.7)
- Jackson JSON library (2.16.0)

## Building

Run the build script to download dependencies and compile:

```bash
chmod +x build.sh
./build.sh
```

This will:
1. Download required JAR files to `lib/` directory
2. Compile the parser

## Usage

### Basic Usage

```bash
./run.sh <java_file>
```

Example:
```bash
./run.sh TestSimple.java > output.json
```

### Direct Java Execution

After building, you can also run directly:

```bash
java -cp ".:lib/*" JavaToXLangParser MyFile.java
```

## Output Format

The parser outputs XLang JSON to stdout and statistics to stderr.

### Example Input (Java):

```java
package com.example;

public class Hello {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```

### Example Output (XLang JSON):

```json
{
  "kind": "xnkFile",
  "fileName": "Hello.java",
  "packageDecl": {
    "kind": "xnkNamespace",
    "namespaceName": "com.example"
  },
  "moduleDecls": [
    {
      "kind": "xnkClassDecl",
      "typeNameDecl": "Hello",
      "members": [
        {
          "kind": "xnkMethodDecl",
          "methodName": "main",
          "mparams": [...],
          "mreturnType": {...},
          "mbody": {...}
        }
      ]
    }
  ]
}
```

## Test Files

- `TestSimple.java` - Basic test covering fundamental constructs
- `TestComprehensive.java` - Comprehensive test covering all Java features

Run tests:
```bash
./run.sh TestSimple.java > test_simple_output.json
./run.sh TestComprehensive.java > test_comprehensive_output.json
```

## XLang Node Mappings

### Type Declarations

| Java Construct | XLang Node | Notes |
|----------------|------------|-------|
| Class | `xnkClassDecl` | Regular classes |
| Interface | `xnkInterfaceDecl` | Interfaces |
| Enum | `xnkEnumDecl` | Enumerations |
| Record | `xnkClassDecl` | With `isRecord: true` |
| Annotation | `xnkInterfaceDecl` | With `isAnnotation: true` |

### Statements

| Java Statement | XLang Node |
|----------------|------------|
| Block | `xnkBlockStmt` |
| If/Else | `xnkIfStmt` |
| While | `xnkWhileStmt` |
| Do-While | `xnkDoWhileStmt` |
| For | `xnkForStmt` |
| Enhanced For | `xnkForeachStmt` |
| Switch | `xnkSwitchStmt` |
| Return | `xnkReturnStmt` |
| Throw | `xnkThrowStmt` |
| Try-Catch-Finally | `xnkTryStmt` |
| Break | `xnkBreakStmt` |
| Continue | `xnkContinueStmt` |
| Synchronized | `xnkLockStmt` |
| Assert | `xnkAssertStmt` |
| Yield | `xnkIteratorYield` |

### Expressions

| Java Expression | XLang Node |
|-----------------|------------|
| Binary operators | `xnkBinaryExpr` |
| Unary operators | `xnkUnaryExpr` |
| Method call | `xnkCallExpr` |
| Field access | `xnkMemberAccessExpr` |
| Array access | `xnkIndexExpr` |
| Object creation | `xnkCallExpr` with `isNewExpr` |
| Lambda | `xnkLambdaExpr` |
| Method reference | `xnkMethodReference` |
| Assignment | `xnkAsgn` |
| Ternary | `xnkTernaryExpr` |
| Cast | `xnkCastExpr` |
| Instanceof | `xnkBinaryExpr` with op="instanceof" |
| Literals | `xnkIntLit`, `xnkStringLit`, etc. |

## Implementation Details

### JavaParser Library

The parser uses the JavaParser library which provides a complete Java AST implementation. It supports:
- All Java versions through Java 24
- Full syntax validation
- Source location tracking
- Comment preservation (if needed)

### Statistics

When run, the parser outputs statistics to stderr showing the count of each AST node type encountered. This is useful for:
- Verifying parser coverage
- Understanding code complexity
- Debugging parsing issues

### Error Handling

- Invalid Java files are reported with detailed error messages
- File not found errors are handled gracefully
- Parse errors include location information

## Architecture

```
JavaToXLangParser.java
├── Main entry point
├── convertToXLang() - CompilationUnit converter
├── Type Declaration Converters
│   ├── convertTypeDeclaration()
│   ├── convertClassMember()
│   └── convertAnnotationMember()
├── Statement Converters (22 types)
│   ├── convertIfStatement()
│   ├── convertForStatement()
│   ├── convertTryStatement()
│   └── ... (19 more)
├── Expression Converters (37+ types)
│   ├── convertBinaryExpression()
│   ├── convertMethodCallExpression()
│   ├── convertLambdaExpression()
│   └── ... (34+ more)
└── Type System Converters
    ├── convertType()
    ├── convertTypeParameters()
    └── convertModifiers()
```

## Comparison with Other Parsers

This Java parser follows the same architecture as other XLang parsers:

- **C# Parser**: Direct XLang JSON output using Roslyn
- **Go Parser**: Direct XLang JSON output using go/ast
- **Rust Parser**: Direct XLang JSON output using syn
- **Haxe Parser**: Direct XLang JSON output using haxeparser

All parsers output consistent XLang JSON that can be consumed by the Nim transpiler backend.

## Development

### Adding New Features

To add support for new Java features:

1. Update `convertExpression()` or `convertStatement()` with new case
2. Add converter method for the new construct
3. Map to appropriate XLang node type
4. Update statistics tracking
5. Add test case to `TestComprehensive.java`

### Debugging

Enable verbose output:
```bash
./run.sh TestSimple.java 2>&1 | tee debug.log
```

The statistics output shows which constructs were encountered.

## License

Part of the transpiler project.

## See Also

- `basis_docs_claude/java-xlang-mapping.md` - Complete mapping specification
- `xlangtypes.nim` - XLang type definitions
- Other parsers: `src/parsers/csharp/`, `src/parsers/go/`, `src/parsers/rust/`, `src/parsers/haxe/`
