# Multi-Language to Nim Transpiler

A comprehensive transpiler system that converts code from multiple programming languages to Nim using **XLang** as an intermediate representation.

## Architecture Overview

This transpiler uses a multi-stage architecture:

```
Source Code → Language Parser → XLang JSON → XLang AST → Transformation Passes → Nim AST → Nim Code
```

### Pipeline Stages

1. **Language Parser**: Parses source code into language-specific AST
2. **XLang Converter**: Converts language AST to XLang JSON format
3. **XLang Parser**: Parses XLang JSON to XLang AST (Nim types)
4. **Transformation Passes**: Applies language-specific lowering transformations
5. **Nim Generator**: Converts XLang AST to Nim AST
6. **Code Generation**: Generates idiomatic Nim source code

## Supported Languages

### Input Languages
- **Python** - Full support with list comprehensions, decorators, type hints
- **Go** - Concurrency primitives, defer, panic/recover, implicit interfaces
- **C#** - Events, LINQ, using statements, properties
- **Java** - Classes, interfaces, generics
- **TypeScript** - Type system, async/await
- **D** - System programming features
- **Crystal** - Ruby-like syntax with types
- **Haxe** - Cross-platform features
- **Nim** - For transformations and round-trip testing

## Project Structure

```
transpiler/
├── src/
│   ├── xlang/                    # Core XLang system
│   │   ├── xlang_types.nim       # XLang AST node definitions
│   │   ├── xlang_parser.nim      # JSON to XLang AST parser
│   │   ├── xlang_to_nim.nim      # XLang to Nim AST converter
│   │   ├── lang_capabilities.nim # Language capability detection
│   │   └── error_handling.nim    # Error handling utilities
│   │
│   ├── parsers/                  # Language-specific parsers
│   │   ├── python/
│   │   │   └── python_to_xlang.py
│   │   ├── go/
│   │   │   └── go_to_xlang.go
│   │   ├── csharp/
│   │   │   └── csharp_to_xlang.cs
│   │   ├── java/
│   │   │   ├── java_to_xlang.java
│   │   │   └── javaparser.java
│   │   ├── typescript/
│   │   ├── nim/
│   │   │   └── nim_to_xlang.nim
│   │   ├── haxe/
│   │   │   └── HaxeParser.hx
│   │   └── ...
│   │
│   ├── transforms/               # Transformation passes (33 total)
│   │   ├── pass_manager.nim      # Orchestrates transformation pipeline
│   │   │
│   │   ├── # Generic transformations
│   │   ├── for_to_while.nim
│   │   ├── dowhile_to_while.nim
│   │   ├── ternary_to_if.nim
│   │   ├── string_interpolation.nim
│   │   ├── operator_overload.nim
│   │   ├── pattern_matching.nim
│   │   ├── async_normalization.nim
│   │   ├── lambda_normalization.nim
│   │   │
│   │   ├── # Python-specific
│   │   ├── list_comprehension.nim
│   │   ├── decorator_attribute.nim
│   │   ├── python_generators.nim
│   │   ├── python_multiple_inheritance.nim
│   │   ├── python_type_hints.nim
│   │   │
│   │   ├── # Go-specific
│   │   ├── go_concurrency.nim
│   │   ├── go_defer.nim
│   │   ├── go_error_handling.nim
│   │   ├── go_panic_recover.nim
│   │   ├── go_implicit_interfaces.nim
│   │   ├── go_type_assertions.nim
│   │   │
│   │   ├── # C#-specific
│   │   ├── csharp_events.nim
│   │   ├── csharp_using.nim
│   │   ├── linq_to_sequtils.nim
│   │   ├── property_to_procs.nim
│   │   │
│   │   └── # Advanced transformations
│   │       ├── destructuring.nim
│   │       ├── enum_transformations.nim
│   │       ├── extension_methods.nim
│   │       ├── interface_to_concept.nim
│   │       ├── multiple_catch.nim
│   │       ├── null_coalesce.nim
│   │       ├── switch_fallthrough.nim
│   │       ├── union_to_variant.nim
│   │       └── with_to_defer.nim
│   │
│   └── compatibility/            # Runtime compatibility layer
│       └── xlang_compatibility.nim
│
├── tests/                        # Test suites
│   ├── test_integration.nim
│   ├── test_roundtrip.nim
│   ├── test_transforms.nim
│   └── test_xlangtonim.nim
│
├── docs/                         # Documentation
│   ├── TRANSFORMATION_SYSTEM.md
│   ├── TRANSFORMATION_EXAMPLES.md
│   ├── ADDING_A_TRANSFORMATION.md
│   ├── XLANG_TO_NIM_MAPPING.md
│   └── NIM_AS_INPUT.md
│
├── main.nim                      # Main transpiler entry point
└── README.md                     # This file
```

## Installation

### Prerequisites
- Nim compiler (>= 2.0)
- Python 3.8+ (for Python parser)
- Go 1.18+ (for Go parser)
- .NET SDK (for C# parser)
- JDK 11+ (for Java parser)

### Building

```bash
# Clone the repository
git clone <repository-url>
cd transpiler

# Compile the main transpiler
nim c main.nim

# Or compile with optimizations
nim c -d:release main.nim
```

## Usage

### Python to Nim

```bash
# Step 1: Parse Python to XLang JSON
python src/parsers/python/python_to_xlang.py input.py > output.xlang.json

# Step 2: Convert XLang to Nim
nim c -r main.nim output.xlang.json > output.nim
```

### Go to Nim

```bash
# Step 1: Parse Go to XLang JSON
go run src/parsers/go/go_to_xlang.go input.go > output.xlang.json

# Step 2: Convert XLang to Nim
nim c -r main.nim output.xlang.json > output.nim
```

### C# to Nim

```bash
# Step 1: Parse C# to XLang JSON
dotnet run --project src/parsers/csharp/csharp_to_xlang.cs input.cs > output.xlang.json

# Step 2: Convert XLang to Nim
nim c -r main.nim output.xlang.json > output.nim
```

### Java to Nim

```bash
# Step 1: Compile the Java parser
javac -cp .:javaparser-core.jar src/parsers/java/java_to_xlang.java

# Step 2: Parse Java to XLang JSON
java -cp .:javaparser-core.jar src/parsers/java/java_to_xlang Input.java > output.xlang.json

# Step 3: Convert XLang to Nim
nim c -r main.nim output.xlang.json > output.nim
```

## XLang Specification

XLang is a language-agnostic intermediate representation that captures common programming constructs:

### Node Categories

- **Structures**: File, Module, Namespace
- **Declarations**: Functions, Classes, Interfaces, Enums, Variables, Types
- **Statements**: If, Switch, Loops (For, While, Foreach), Try/Catch, Return
- **Expressions**: Binary/Unary ops, Calls, Member access, Lambdas, Literals
- **Types**: Named, Array, Map, Function, Generic, Union, Intersection

### XLang Version

Current version: **1.0.0**

## Transformation System

The transpiler includes 33 transformation passes that convert language-specific constructs to Nim idioms:

### Pass Categories

1. **Control Flow**: for→while, dowhile→while, ternary→if
2. **Language Features**: async/await, lambdas, pattern matching
3. **Python**: list comprehensions, decorators, generators, type hints
4. **Go**: goroutines, channels, defer, panic/recover, interfaces
5. **C#**: LINQ, events, using statements, properties
6. **Advanced**: destructuring, union types, null coalescing

See `docs/TRANSFORMATION_SYSTEM.md` for detailed documentation.

## Features

### ✓ Implemented

- Complete XLang type system (60+ node kinds)
- JSON to XLang AST parsing
- XLang to Nim AST conversion
- 33 transformation passes with dependency tracking
- Support for 9 input languages
- Round-trip testing (Nim → XLang → Nim)
- Comprehensive error handling

### Planned

- TypeScript parser implementation
- Rust parser implementation
- Kotlin parser implementation
- Crystal parser implementation
- Direct code generation (bypassing Nim AST)
- Optimization passes
- Type inference improvements

## Development

### Adding a New Language

1. Create directory: `src/parsers/<language>/`
2. Implement parser: `<language>_to_xlang.<ext>`
3. Output XLang JSON following specification
4. Add language-specific transformations if needed

See `docs/ADDING_A_TRANSFORMATION.md` for guidance.

### Running Tests

```bash
# Run all tests
nim c -r tests/test_integration.nim
nim c -r tests/test_roundtrip.nim
nim c -r tests/test_transforms.nim

# Test specific transformation
nim c -r tests/test_specific_transform.nim
```

### Project Goals

1. **Expand Nim's ecosystem** by enabling easy porting of libraries
2. **Provide idiomatic output** that feels native to Nim
3. **Maintain type safety** throughout the conversion process
4. **Support modern language features** from all source languages
5. **Enable incremental migration** from other languages to Nim

## Contributing

Contributions are welcome! Areas of focus:

- Parser implementations for additional languages
- New transformation passes
- Optimization improvements
- Documentation and examples
- Bug fixes and testing

## License

See LICENSE file for details.

## Version History

- **Current**: Restructured project with clean modular architecture
- **Previous**: Feature-complete transformation system (33 passes)
- **Initial**: Basic XLang to Nim conversion

## Acknowledgments

This transpiler builds on the XLang intermediate representation concept to enable multi-language transpilation to Nim.
