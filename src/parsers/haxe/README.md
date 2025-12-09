# Haxe to XLang Parser

This directory contains a comprehensive parser for converting Haxe source code to XLang intermediate representation.

## Overview

The Haxe parser uses Haxe's native macro system and typed AST to parse Haxe code and convert it to XLang JSON format. This ensures accurate parsing that matches Haxe's actual semantics.

## Components

### 1. HaxeToXLang.hx (Main Parser)
The comprehensive parser that handles all Haxe language constructs:
- **Module types**: Classes, interfaces, enums, typedefs, abstract types
- **Expressions**: All 29 TypedExprDef variants
- **Statements**: Control flow, loops, exception handling
- **Types**: Generics, function types, anonymous structures, abstract types
- **Haxe-specific features**: Metadata, type parameters, pattern matching

### 2. haxe_to_xlang.hx (Legacy)
Previous implementation - kept for reference.

### 3. haxe_json_to_xlang.nim
Post-processor that converts semi-XLang JSON to canonical XLang format with proper field name mappings.

## Language Coverage

The parser handles all Haxe constructs exhaustively:

### Type Declarations
- ✓ Classes with inheritance and interfaces
- ✓ Interfaces
- ✓ Enums (algebraic data types) with constructors
- ✓ Typedefs (type aliases)
- ✓ Abstract types with implicit conversions
- ✓ Anonymous structures
- ✓ Generic types with constraints

### Expressions (Complete TypedExprDef Coverage)
- ✓ TConst - Constants (int, float, string, bool, null, this, super)
- ✓ TLocal - Local variables
- ✓ TArray - Array access
- ✓ TBinop - Binary operations
- ✓ TField - Field access
- ✓ TTypeExpr - Type expressions
- ✓ TParenthesis - Parenthesized expressions
- ✓ TObjectDecl - Object literals
- ✓ TArrayDecl - Array literals
- ✓ TCall - Function calls
- ✓ TNew - Constructor calls
- ✓ TUnop - Unary operations
- ✓ TFunction - Lambda/anonymous functions
- ✓ TVar - Variable declarations
- ✓ TBlock - Block statements
- ✓ TFor - For loops (iterator-based)
- ✓ TIf - Conditionals
- ✓ TWhile - While and do-while loops
- ✓ TSwitch - Pattern matching
- ✓ TTry - Exception handling
- ✓ TReturn - Return statements
- ✓ TBreak - Break statements
- ✓ TContinue - Continue statements
- ✓ TThrow - Throw exceptions
- ✓ TCast - Type casts
- ✓ TMeta - Metadata annotations
- ✓ TEnumParameter - Enum parameter access
- ✓ TEnumIndex - Enum index access
- ✓ TIdent - Identifiers

### Haxe-Specific Features
- ✓ Abstract types with @:from/@:to conversions
- ✓ Metadata (@:macro, @:native, @:inline, etc.)
- ✓ Type parameters with constraints
- ✓ Pattern matching in switch statements
- ✓ String interpolation
- ✓ Properties with getters/setters
- ✓ Static extensions
- ✓ Compile-time expressions

## Usage

### Building the Parser

```bash
cd src/parsers/haxe
haxe --main HaxeToXLang --interp
```

### Running the Parser

```bash
haxe --run HaxeToXLang <input_file.hx>
```

This will generate `<input_file.hx>.xlang.json` containing the XLang representation.

### Post-Processing

To convert to canonical XLang format:

```bash
nim c -r haxe_json_to_xlang.nim <input_file.hx>.xlang.json
```

## Pipeline Integration

The Haxe parser integrates into the transpiler pipeline as follows:

1. **Haxe Source** → HaxeToXLang.hx → **Semi-XLang JSON**
2. **Semi-XLang JSON** → haxe_json_to_xlang.nim → **Canonical XLang JSON**
3. **Canonical XLang JSON** → xlang_to_nim.nim → **Nim Code**

## XLang Mapping

See [basis_docs_claude/haxe-xlang-mapping.md](../../../basis_docs_claude/haxe-xlang-mapping.md) for complete mapping of Haxe constructs to XLang nodes.

### Key Mappings

| Haxe Construct | XLang Node |
|----------------|------------|
| Class | `xnkClassDecl` |
| Interface | `xnkInterfaceDecl` |
| Enum | `xnkEnumDecl` |
| Typedef | `xnkTypeAlias` |
| Abstract | `xnkAbstractDecl` |
| Function | `xnkFuncDecl` |
| Method | `xnkMethodDecl` |
| Lambda | `xnkLambdaExpr` |
| For loop | `xnkForeachStmt` |
| Switch | `xnkSwitchStmt` |
| Metadata | `xnkMetadata` |

## Examples

### Simple Class

```haxe
class Point {
    public var x:Int;
    public var y:Int;

    public function new(x:Int, y:Int) {
        this.x = x;
        this.y = y;
    }

    public function distance():Float {
        return Math.sqrt(x * x + y * y);
    }
}
```

### Enum with Pattern Matching

```haxe
enum Option<T> {
    Some(value:T);
    None;
}

class Example {
    static function getValue<T>(opt:Option<T>, default:T):T {
        return switch (opt) {
            case Some(v): v;
            case None: default;
        };
    }
}
```

### Abstract Type

```haxe
abstract Meters(Float) {
    public inline function new(v:Float) {
        this = v;
    }

    @:from static public inline function fromFloat(f:Float):Meters {
        return new Meters(f);
    }

    @:to public inline function toFloat():Float {
        return this;
    }
}
```

## Architecture

The parser leverages Haxe's macro system for accurate parsing:

1. **Type System Integration**: Uses Haxe's typed AST for semantic accuracy
2. **Macro API**: Accesses `haxe.macro.Context`, `Type`, and `TypedExpr`
3. **Complete Coverage**: Handles all 29 TypedExprDef variants
4. **Metadata Preservation**: Maintains Haxe's compile-time annotations
5. **Type Information**: Preserves full type information in XLang output

## Testing

Test files can be found in `tests/haxe/`:
- Basic language features
- Type system features
- Pattern matching
- Generic programming
- Abstract types
- Metadata usage

## Limitations

- Macro expressions are evaluated at compile-time (not transpiled)
- Reflection is not directly supported
- Some Haxe-specific optimizations may not transfer

## References

- [Haxe Manual](https://haxe.org/manual/introduction.html)
- [Haxe API Documentation](https://api.haxe.org/)
- [Expr API](https://api.haxe.org/haxe/macro/Expr.html)
- [TypedExpr API](https://api.haxe.org/haxe/macro/TypedExpr.html)
- [Type.hx Source](https://github.com/HaxeFoundation/haxe/blob/4.3.3/std/haxe/macro/Type.hx)
- [XLang Mapping Document](../../../basis_docs_claude/haxe-xlang-mapping.md)

## Contributing

When adding support for new Haxe features:
1. Update `HaxeToXLang.hx` with the conversion logic
2. Add corresponding field mapping in `haxe_json_to_xlang.nim`
3. Update the mapping document in `basis_docs_claude/haxe-xlang-mapping.md`
4. Add test cases demonstrating the feature
5. Update this README

## License

Part of the transpiler project.
