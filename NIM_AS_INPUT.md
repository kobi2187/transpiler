# Nim as Input Language

## Overview

The transpiler now supports **Nim as an input language**, enabling several powerful use cases:

1. **Testing transformations** without needing other language parsers
2. **Round-trip validation** (Nim → XLang → Nim)
3. **Code modernization** (improve Nim idioms)
4. **Bootstrapping** the project with fast iteration

## Architecture

```
┌──────────────┐
│  Nim Code    │
└──────┬───────┘
       │
       ↓ [nimtoXlang.nim - NEW!]
┌──────────────┐
│  XLang AST   │
└──────┬───────┘
       │
       ↓ [Transformation passes]
┌──────────────┐
│ Transformed  │
│  XLang AST   │
└──────┬───────┘
       │
       ↓ [xlangtonim_complete.nim]
┌──────────────┐
│  Nim AST     │
└──────┬───────┘
       │
       ↓ [repr]
┌──────────────┐
│  Nim Code    │
└──────────────┘
```

## File Structure

```
transpiler/
├── nimtoXlang.nim              ← NEW: Nim → XLang converter
├── xlangtonim_complete.nim     ← XLang → Nim converter
├── test_roundtrip.nim          ← Round-trip tests
└── example_transform_*.nim     ← Transformation examples
```

## Usage

### 1. Basic Round-Trip

```nim
import macros
import nimtoXlang
import xlangtonim_complete

let nimCode = """
proc hello(name: string): string =
  return "Hello, " & name
"""

# Parse Nim code
let nimAst = parseStmt(nimCode)

# Convert to XLang
let xlangAst = convertNimToXLang(nimAst)

# Convert back to Nim
let nimAst2 = convertXLangToNim(xlangAst)

echo nimAst2.repr
```

### 2. With Transformations

```nim
import macros
import nimtoXlang
import xlangtonim_complete
import xlangtypes

proc transformXLang(node: XLangNode): XLangNode =
  # Your transformation logic here
  case node.kind
  of xnkWhileStmt:
    # Transform while → for
    result = convertWhileToFor(node)
  else:
    result = node

let nimCode = """
while i < 10:
  echo i
  inc i
"""

# Pipeline
let nimAst = parseStmt(nimCode)
let xlangAst = convertNimToXLang(nimAst)
let transformedXLang = transformXLang(xlangAst)
let nimAst2 = convertXLangToNim(transformedXLang)

echo nimAst2.repr  # Now uses for loop!
```

### 3. Compile-Time Transformation

```nim
import macros
import nimtoXlang
import xlangtonim_complete

macro optimize(code: untyped): untyped =
  # Convert to XLang
  let xlangAst = convertNimToXLang(code)

  # Apply transformations
  let optimized = applyOptimizations(xlangAst)

  # Convert back to Nim
  result = convertXLangToNim(optimized)

# Use it
optimize:
  proc myFunc() =
    var i = 0
    while i < 10:
      echo i
      inc i
# The while loop gets transformed at compile time!
```

## Supported Nim Constructs

### ✅ Fully Supported

| Nim Construct | XLang Equivalent | Notes |
|--------------|------------------|-------|
| **Types** |
| `int`, `string`, etc. | `xnkNamedType` | Basic types |
| `array[N, T]` | `xnkArrayType` | Arrays |
| `seq[T]` | `xnkGenericType` | Sequences |
| `Table[K, V]` | `xnkMapType` | Hash tables |
| `ptr T` | `xnkPointerType` | Pointers |
| `ref T` | `xnkReferenceType` | References |
| `proc(...)` | `xnkFuncType` | Function types |
| **Declarations** |
| `proc/func` | `xnkFuncDecl` | Functions |
| `method` | `xnkMethodDecl` | Methods |
| `template` | `xnkTemplateDef` | Templates |
| `macro` | `xnkMacroDef` | Macros |
| `var/let/const` | `xnkVarDecl/xnkLetDecl/xnkConstDecl` | Variables |
| `type = object` | `xnkStructDecl` | Objects |
| `type = ref object` | `xnkClassDecl` | Ref objects |
| `type = enum` | `xnkEnumDecl` | Enums |
| `type = distinct` | `xnkDistinctTypeDef` | Distinct types |
| **Statements** |
| `if/elif/else` | `xnkIfStmt` | Conditionals |
| `case/of/else` | `xnkSwitchStmt` | Pattern matching |
| `while` | `xnkWhileStmt` | While loops |
| `for..in` | `xnkForeachStmt` | For loops |
| `return` | `xnkReturnStmt` | Returns |
| `break/continue` | `xnkBreakStmt/xnkContinueStmt` | Loop control |
| `try/except/finally` | `xnkTryStmt` | Exceptions |
| `defer` | `xnkDeferStmt` | Defer |
| `discard` | `xnkPassStmt` | No-op |
| **Expressions** |
| `a + b` | `xnkBinaryExpr` | Binary ops |
| `-a` | `xnkUnaryExpr` | Unary ops |
| `if c: a else: b` | `xnkTernaryExpr` | If expr |
| `f(x, y)` | `xnkCallExpr` | Calls |
| `obj.field` | `xnkMemberAccessExpr` | Member access |
| `arr[i]` | `xnkIndexExpr` | Indexing |
| `[1, 2, 3]` | `xnkListExpr` | Array literals |
| `{1, 2, 3}` | `xnkSetExpr` | Set literals |
| `(1, "a")` | `xnkTupleExpr` | Tuples |
| `{"a": 1}` | `xnkDictExpr` | Table literals |
| `proc(x) = x*2` | `xnkLambdaExpr` | Lambdas |

### ⚠️ Partially Supported

| Nim Construct | Notes |
|--------------|-------|
| Generic types | Basic support, complex constraints may not convert |
| Concepts | Not fully mapped yet |
| Effects system | Pragmas converted but effects not analyzed |
| Overloading | All overloads treated independently |

### ❌ Not Yet Supported

| Nim Construct | Reason |
|--------------|--------|
| `iterator` | No XLang equivalent yet |
| `converter` | Treated as proc for now |
| Term rewriting macros | Complex macro features |
| `using` statement | Not in XLang yet |

## Use Cases

### 1. Testing Transformations

**Problem**: You want to test a transformation pass but don't want to set up Go/Python parsers.

**Solution**: Use Nim as input!

```nim
# Test input (Nim code)
let input = """
while i < 10:
  inc i
"""

# Apply transformation
let xlang = parseNimToXLang(input)
let transformed = transformWhileToFor(xlang)
let output = convertXLangToNim(transformed)

# Verify it's now a for loop
assert output contains "for i in"
```

### 2. Code Modernization

**Problem**: You have old Nim code with outdated idioms.

**Solution**: Transform it automatically!

```nim
# Old style
var list: seq[int] = @[]
for i in 0..<10:
  list.add(i * 2)

# After transformation
let list = (0..<10).mapIt(it * 2)
```

### 3. Idiomatic Nim Generator

**Problem**: Code transpiled from other languages is verbose.

**Solution**: Transform to idiomatic Nim!

```nim
# From Python (verbose)
var i = 0
while i < len(items):
  echo items[i]
  i = i + 1

# To idiomatic Nim
for item in items:
  echo item
```

### 4. Quick Prototyping

**Problem**: You want to test the full pipeline quickly.

**Solution**: Write test cases in Nim!

```nim
# Write test in familiar Nim syntax
testTransformation("""
  proc add(a, b: int): int =
    return a + b
""")
# Instantly see transformation results
```

## Implementation Details

### nimtoXlang.nim Structure

```nim
# Main dispatcher
proc convertNimToXLang*(node: NimNode): XLangNode

# Specialized converters
proc convertNimType(node: NimNode): XLangNode
proc convertNimExpr(node: NimNode): XLangNode
proc convertNimStmt(node: NimNode): XLangNode
proc convertNimDecl(node: NimNode): XLangNode
```

### Key Design Decisions

1. **Uses Nim's macro system**: Gets AST for free via `parseStmt()`
2. **Mirrors xlangtonim_complete.nim**: Same structure, opposite direction
3. **Handles nnkPostfix**: Exports marked with `*` are preserved
4. **Context-aware**: `nnkIdent` → `xnkIdentifier` or `xnkNamedType` depending on context
5. **Multiple declarations**: `var a, b, c = 0` → multiple `xnkVarDecl`

### NimNode → XLangNode Mapping

| NimNode Kind | XLangNode Kind | Context |
|--------------|----------------|---------|
| `nnkIdent` | `xnkIdentifier` | In expression |
| `nnkIdent` | `xnkNamedType` | In type position |
| `nnkInfix` | `xnkBinaryExpr` | Always |
| `nnkPrefix` | `xnkUnaryExpr` | Always |
| `nnkCall` | `xnkCallExpr` | Always |
| `nnkDotExpr` | `xnkMemberAccessExpr` | Always |
| `nnkBracketExpr` | `xnkIndexExpr` or generic type | Context |
| `nnkProcDef` | `xnkFuncDecl` | Always |
| `nnkMethodDef` | `xnkMethodDecl` | Always |
| `nnkTypeSection` | Various | Depends on type kind |

## Testing

### Run Round-Trip Tests

```bash
nim c -r test_roundtrip.nim
```

Expected output:
```
╔════════════════════════════════════════════════════════╗
║         Nim → XLang → Nim Round-Trip Tests           ║
╚════════════════════════════════════════════════════════╝

=== Test 1: Simple Function ===
Original Nim AST: ...
XLang AST kind: xnkFuncDecl
Regenerated Nim AST: ...

[... more tests ...]

╔════════════════════════════════════════════════════════╗
║              All Round-Trip Tests Complete            ║
╚════════════════════════════════════════════════════════╝
```

### Run Transformation Example

```bash
nim c -r example_transform_while_to_for.nim
```

## Advantages of Nim as Input

| Advantage | Description |
|-----------|-------------|
| **Fast iteration** | No need to compile/run external parsers |
| **Easy testing** | Write tests in familiar syntax |
| **Bootstrapping** | Get the pipeline working before adding other languages |
| **Validation** | Round-trip tests catch conversion bugs |
| **Real use case** | Code modernization tool for Nim itself |
| **Learning tool** | See how transformations work step-by-step |

## Limitations

1. **Not all Nim features**: Some advanced features not in XLang yet
2. **Comments lost**: Nim's macro system doesn't preserve all comments
3. **Formatting lost**: AST doesn't preserve spacing/formatting
4. **Macro expansion**: Macros are already expanded by parseStmt

## Future Enhancements

1. **Comment preservation**: Parse source text alongside AST
2. **More complex patterns**: Handle iterator, converter, etc.
3. **Type inference**: Preserve inferred types in XLang
4. **Effect tracking**: Map Nim's effect system to XLang
5. **Source mapping**: Track original source locations

## Integration with Main Pipeline

```nim
# main.nim
import nimtoXlang

proc transpileFile(inputFile: string, inputLang: string, outputLang: string) =
  case inputLang
  of "nim":
    # Parse Nim directly
    let nimCode = readFile(inputFile)
    let nimAst = parseStmt(nimCode)
    let xlangAst = convertNimToXLang(nimAst)
    # Continue with transformation pipeline...

  of "go":
    # Use Go parser
    let jsonAst = runGoParser(inputFile)
    let xlangAst = parseXLangJson(jsonAst)
    # Continue with transformation pipeline...

  # ... etc.
```

## Conclusion

Adding Nim as an input language is a **game-changer** for development:

✅ Fast testing of transformations
✅ Validates the full pipeline
✅ Provides a real use case (code modernization)
✅ No external dependencies needed

Start with Nim input to build and test transformations, then add other languages once the pipeline is solid!
