# Scala to XLang Parser

Comprehensive Scala source code parser that converts Scala AST to XLang intermediate representation JSON format.

## Features

- **Complete Scala Support**: Handles Scala 2 and Scala 3 language features
- **Modern Scala Features**:
  - Case classes and pattern matching
  - Traits and abstract classes
  - Singleton objects
  - For comprehensions
  - Type parameters and variance annotations
  - Implicit parameters and conversions
  - Multiple parameter lists (currying)
  - By-name parameters
  - Higher-order functions and lambdas
  - Sealed traits and ADTs
  - Type aliases
  - Extension methods
- **All Statement Types**: if, while, for, match, try-catch, and more
- **All Expression Types**: operators, literals, lambdas, method calls, object creation, and more
- **Type System**: Full support for generics, type parameters, function types, tuple types, and more
- **Nested Constructs**: Inner classes, nested objects, local functions

## Requirements

- Scala 2.13.x
- sbt 1.9.x or higher
- Java 11 or higher

## Building

Run the build script to download dependencies and compile:

```bash
chmod +x build.sh
./build.sh
```

This will:
1. Download required dependencies via sbt
2. Compile the Scala source code
3. Create a fat JAR with all dependencies at `target/scala-2.13/scala-to-xlang.jar`

## Usage

### Basic Usage

```bash
./run.sh <scala_file>
```

Example:
```bash
./run.sh TestSimple.scala > output.json
```

### Directory Processing

Process all `.scala` files in a directory:

```bash
./run.sh <directory>
```

This will create `.xljs` files next to each `.scala` file.

### Direct Java Execution

After building, you can also run directly:

```bash
java -jar target/scala-2.13/scala-to-xlang.jar MyFile.scala
```

## Output Format

The parser outputs XLang JSON to stdout and statistics to stderr.

### Example Input (Scala):

```scala
package com.example

object Hello {
  def main(args: Array[String]): Unit = {
    println("Hello, World!")
  }

  def add(x: Int, y: Int): Int = x + y
}
```

### Example Output (XLang JSON):

```json
{
  "kind": "xnkFile",
  "fileName": "Hello.scala",
  "sourceLang": "scala",
  "moduleDecls": [
    {
      "kind": "xnkNamespace",
      "namespaceName": "com.example",
      "namespaceBody": [
        {
          "kind": "xnkClassDecl",
          "typeNameDecl": "Hello",
          "isSingleton": true,
          "members": [...]
        }
      ]
    }
  ]
}
```

## Test Files

- `TestSimple.scala` - Basic test covering fundamental constructs
- `TestComprehensive.scala` - Comprehensive test covering all Scala features

Run tests:
```bash
./run.sh TestSimple.scala > test_simple_output.json
./run.sh TestComprehensive.scala > test_comprehensive_output.json
```

## XLang Node Mappings

### Type Declarations

| Scala Construct | XLang Node | Notes |
|----------------|------------|-------|
| Class | `xnkClassDecl` | Regular classes |
| Case Class | `xnkClassDecl` | With `typeIsCase: true` |
| Trait | `xnkInterfaceDecl` | Scala traits |
| Object | `xnkClassDecl` | With `isSingleton: true` |
| Abstract Class | `xnkClassDecl` | With `typeIsAbstract: true` |
| Sealed Trait/Class | `xnkInterfaceDecl` or `xnkClassDecl` | With `typeIsSealed: true` |

### Statements

| Scala Statement | XLang Node |
|----------------|------------|
| Block | `xnkBlockStmt` |
| If/Else | `xnkIfStmt` |
| While | `xnkWhileStmt` |
| For Comprehension | `xnkExternal_ForComprehension` |
| Match | `xnkSwitchStmt` |
| Return | `xnkReturnStmt` |
| Throw | `xnkThrowStmt` |
| Try-Catch-Finally | `xnkTryStmt` |

### Expressions

| Scala Expression | XLang Node |
|-----------------|------------|
| Binary operators | `xnkBinaryExpr` |
| Unary operators | `xnkUnaryExpr` |
| Method call | `xnkCallExpr` |
| Field access | `xnkMemberAccessExpr` |
| Object creation | `xnkCallExpr` with `isNewExpr` |
| Lambda | `xnkLambdaExpr` |
| Assignment | `xnkAsgn` |
| This | `xnkThisExpr` |
| Super | `xnkBaseExpr` |
| Literals | `xnkIntLit`, `xnkStringLit`, etc. |

### Types

| Scala Type | XLang Node |
|-----------|------------|
| Named type | `xnkNamedType` |
| Type with args | `xnkNamedType` with `typeArgs` |
| Function type | `xnkFunctionType` |
| Tuple type | `xnkTupleType` |
| By-name type | `xnkByNameType` |
| Repeated type | `xnkRepeatedType` |

## Implementation Details

### Scalameta Library

The parser uses the Scalameta library which provides a complete Scala AST implementation. It supports:
- All Scala 2 versions through 2.13
- Many Scala 3 features
- Full syntax validation
- Source location tracking

### Statistics

When run, the parser outputs statistics to stderr showing the count of each AST node type encountered. This is useful for:
- Verifying parser coverage
- Understanding code complexity
- Debugging parsing issues

### Error Handling

- Invalid Scala files are reported with detailed error messages
- File not found errors are handled gracefully
- Parse errors include location information

## Architecture

```
ScalaToXLangParser.scala
├── Main entry point
├── convertToXLang() - Source converter
├── Type Declaration Converters
│   ├── convertClass()
│   ├── convertTrait()
│   ├── convertObject()
│   └── convertTypeAlias()
├── Statement/Term Converters
│   ├── convertTerm()
│   ├── convertCase()
│   └── convertPattern()
├── Type System Converters
│   ├── convertType()
│   ├── convertTypeParam()
│   └── convertParameter()
└── JSON Serialization
    └── toJson()
```

## Comparison with Other Parsers

This Scala parser follows the same architecture as other XLang parsers:

- **Java Parser**: Direct XLang JSON output using JavaParser
- **C# Parser**: Direct XLang JSON output using Roslyn
- **Go Parser**: Direct XLang JSON output using go/ast
- **Scala Parser**: Direct XLang JSON output using Scalameta

All parsers output consistent XLang JSON that can be consumed by the transpiler backend.

## Scala-Specific Features

The parser handles Scala-specific constructs:

- **Pattern Matching**: Converted to `xnkSwitchStmt` with pattern information
- **For Comprehensions**: Converted to `xnkExternal_ForComprehension` with generators and guards
- **Implicit Parameters**: Tracked with `isImplicit` flag
- **By-Name Parameters**: Tracked with `isByName` flag
- **Multiple Parameter Lists**: Represented as nested parameter arrays
- **Variance Annotations**: Tracked in type parameters (covariant/contravariant/invariant)
- **Singleton Objects**: Marked with `isSingleton: true`
- **Case Classes**: Marked with `typeIsCase: true`

## Development

### Adding New Features

To add support for new Scala features:

1. Update `convertTerm()` or other converter methods with new case
2. Add converter method for the new construct
3. Map to appropriate XLang node type
4. Update statistics tracking
5. Add test case to `TestComprehensive.scala`

### Debugging

Enable verbose output by running:
```bash
./run.sh TestSimple.scala 2>&1 | tee debug.log
```

The statistics output shows which constructs were encountered.

## License

Part of the transpiler project.

## See Also

- Other parsers: `src/parsers/java/`, `src/parsers/csharp/`, `src/parsers/go/`
- XLang specification and type definitions
