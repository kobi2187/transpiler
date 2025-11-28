# Parser JSON to XLang Converters

## Overview

The parsers (`python_to_xlang.py`, `go_to_xlang.go`, `csharp_to_xlang.cs`, etc.) output their **native language AST structures** in JSON format. These need to be converted to the canonical XLang JSON format before they can be processed by the Nim XLang toolchain.

## Architecture

```
Source Code
  ↓
Language Parser (Python/Go/C#/Java/etc.)
  ↓
Native AST JSON
  ↓
Converter (Nim binary)
  ↓
Canonical XLang JSON
  ↓
xlang_parser.nim → XLang AST (Nim types)
  ↓
Transformation Passes
  ↓
xlang_to_nim.nim → Nim AST
  ↓
Nim Code
```

## Converter Binaries

Each language has a dedicated converter binary:

| Language | Parser | Native AST | Converter | Output |
|----------|--------|------------|-----------|--------|
| Python | `python_to_xlang.py` | Python AST + "xnk" kinds | `python_json_to_xlang.nim` | XLang JSON |
| Go | `go_to_xlang.go` | Go AST kinds | `go_json_to_xlang.nim` | XLang JSON |
| C# | `csharp_to_xlang.cs` | C# ANTLR AST | `csharp_json_to_xlang.nim` | XLang JSON |
| Java | `java_to_xlang.java` | Java Parser AST | `java_json_to_xlang.nim` | XLang JSON |
| TypeScript | `typescript_to_xlang.ts` | TS Compiler API | `typescript_json_to_xlang.nim` | XLang JSON |
| D | `d_to_xlang.d` | D AST | `d_json_to_xlang.nim` | XLang JSON |
| Crystal | `crystal_to_xlang.cr` | Crystal AST | `crystal_json_to_xlang.nim` | XLang JSON |
| Haxe | `haxe_to_xlang.hx` | Haxe AST | `haxe_json_to_xlang.nim` | XLang JSON |

## Canonical XLang JSON Format

Based on `src/xlang/xlang_types.nim` (the source of truth):

### Node Kinds

All XLang nodes must use `"xnk"` prefix:
- File: `"xnkFile"`
- Functions: `"xnkFuncDecl"`, `"xnkMethodDecl"`
- Types: `"xnkClassDecl"`, `"xnkStructDecl"`, `"xnkInterfaceDecl"`, `"xnkEnumDecl"`
- Statements: `"xnkIfStmt"`, `"xnkWhileStmt"`, `"xnkForStmt"`, `"xnkBlockStmt"`, etc.
- Expressions: `"xnkBinaryExpr"`, `"xnkCallExpr"`, `"xnkIdentifier"`, etc.
- Literals: `"xnkIntLit"`, `"xnkStringLit"`, `"xnkBoolLit"`, etc.

### Field Names (Canonical)

**IMPORTANT**: Use these exact field names (from `xlang_types.nim`):

#### File & Modules
```json
{
  "kind": "xnkFile",
  "fileName": "example.ext",
  "moduleDecls": [...]
}
```

#### Functions
```json
{
  "kind": "xnkFuncDecl",
  "funcName": "myFunc",
  "params": [...],
  "returnType": {...},
  "body": {...},
  "isAsync": false
}
```

#### Classes/Structs/Interfaces
```json
{
  "kind": "xnkClassDecl",
  "typeNameDecl": "MyClass",  // Note: typeNameDecl, not typeName!
  "baseTypes": [...],
  "members": [...]
}
```

#### Variables
```json
{
  "kind": "xnkVarDecl",
  "declName": "myVar",
  "declType": {...},
  "initializer": {...}
}
```

#### If Statements
```json
{
  "kind": "xnkIfStmt",
  "ifCondition": {...},
  "ifBody": {...},
  "elseBody": {...}
}
```

#### While/For Loops
```json
{
  "kind": "xnkWhileStmt",
  "whileCondition": {...},
  "whileBody": {...}
}

{
  "kind": "xnkForStmt",
  "forInit": {...},
  "forCond": {...},
  "forIncrement": {...},
  "forBody": {...}
}
```

#### Binary Expressions
```json
{
  "kind": "xnkBinaryExpr",
  "binaryLeft": {...},
  "binaryOp": "+",
  "binaryRight": {...}
}
```

#### Identifiers & Literals
```json
{
  "kind": "xnkIdentifier",
  "identName": "variableName"
}

{
  "kind": "xnkIntLit",
  "literalValue": "42"
}

{
  "kind": "xnkBoolLit",
  "boolValue": true
}
```

## Field Mapping Reference

### Common Native → XLang Mappings

| Native Field | XLang Field | Notes |
|--------------|-------------|-------|
| `name` | `funcName` | For functions |
| `name` | `declName` | For variables |
| `name` | `typeNameDecl` | For classes/structs |
| `name` | `enumName` | For enums |
| `parameters` | `params` | Function parameters |
| `declarations` | `moduleDecls` | File-level declarations |
| `body` | `blockBody` | For block statements |
| `condition` | `ifCondition`, `whileCondition` | Statement conditions |
| `left`, `right` | `binaryLeft`, `binaryRight` | Binary expressions |
| `operator` | `binaryOp` | Binary operator |
| `function` | `callee` | Function call target |
| `arguments` | `args` | Function call arguments |

### Language-Specific Conversions

#### Python
- Python parser already uses `"xnk"` prefixes but wrong field names
- `"declarations"` → `"moduleDecls"`
- `"name"` → `"funcName"`, `"declName"`, etc.
- `"parameters"` → `"params"`
- `"expression"` → `"returnExpr"`

#### Go
- Go parser uses native AST kinds without `"xnk"` prefix
- `"File"` → `"xnkFile"`
- `"FuncDecl"` → `"xnkFuncDecl"`
- `"StructType"` → `"xnkStructDecl"`
- `"InterfaceType"` → `"xnkInterfaceDecl"`
- `"Ident"` → `"xnkIdentifier"`
- `"BasicLit"` → `"xnkIntLit"`, `"xnkStringLit"`, etc.

#### C#
- C# parser uses ANTLR-derived kinds
- `"CompilationUnit"` → `"xnkFile"`
- `"Class"` → `"xnkClassDecl"`
- `"Method"` → `"xnkMethodDecl"`
- `"Namespace"` → `"xnkNamespace"`
- `"Property"` → `"xnkPropertyDecl"`

## Usage Examples

### Python
```bash
# Step 1: Parse Python to native AST JSON
python src/parsers/python/python_to_xlang.py input.py > input.native.json

# Step 2: Convert to canonical XLang JSON
nim c -r src/parsers/python/python_json_to_xlang.nim input.native.json > input.xlang.json

# Step 3: Convert XLang JSON to Nim
nim c -r main.nim input.xlang.json > output.nim
```

### Go
```bash
# Step 1: Parse Go to native AST JSON
go run src/parsers/go/go_to_xlang.go input.go > input.native.json

# Step 2: Convert to canonical XLang JSON
nim c -r src/parsers/go/go_json_to_xlang.nim input.native.json > input.xlang.json

# Step 3: Convert XLang JSON to Nim
nim c -r main.nim input.xlang.json > output.nim
```

### C#
```bash
# Step 1: Parse C# to native AST JSON
dotnet run --project src/parsers/csharp/csharp_to_xlang.cs input.cs > input.native.json

# Step 2: Convert to canonical XLang JSON
nim c -r src/parsers/csharp/csharp_json_to_xlang.nim input.native.json > input.xlang.json

# Step 3: Convert XLang JSON to Nim
nim c -r main.nim input.xlang.json > output.nim
```

## Converter Implementation Status

- ✅ **Python** - Complete (`python_json_to_xlang.nim`)
- ✅ **Go** - Complete (`go_json_to_xlang.nim`)
- ✅ **C#** - Complete (`csharp_json_to_xlang.nim`)
- ⏳ **Java** - In Progress
- ⏳ **TypeScript** - Pending
- ⏳ **D** - Pending
- ⏳ **Crystal** - Pending
- ⏳ **Haxe** - Pending

## Verification

To verify a converter is working correctly:

1. Parse a simple source file
2. Convert to XLang JSON
3. Validate against `xlang_types.nim` structure
4. Check field names match exactly
5. Ensure all `"xnk"` prefixes are present
6. Test full pipeline to Nim output

## Contributing

When adding a new language converter:

1. Study the parser's output JSON format
2. Map native AST kinds to XLang `"xnk"` kinds
3. Map native field names to canonical XLang field names
4. Handle language-specific constructs
5. Test with representative code samples
6. Document any special cases

## References

- Canonical field names: `src/xlang/xlang_types.nim` (source of truth)
- XLang spec: `docs/XLang_Specification.md` (may be outdated)
- Example converters: `src/parsers/{python,go,csharp}/`
