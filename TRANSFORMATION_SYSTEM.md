# Transformation System Documentation

## Overview

The transformation system is the middle layer of the transpiler pipeline that converts XLang AST constructs into forms compatible with the target language (Nim).

```
┌─────────────┐
│ Input Lang  │ (Go, Python, C#, Java, etc.)
└──────┬──────┘
       │ Native Parser → JSON
       ↓
┌─────────────┐
│  XLang AST  │ (Superset of all languages)
└──────┬──────┘
       │ Transformation Passes ← YOU ARE HERE
       ↓
┌─────────────┐
│ Transformed │ (Lowered to Nim subset)
│  XLang AST  │
└──────┬──────┘
       │ xlangtonim_complete
       ↓
┌─────────────┐
│   Nim AST   │
└──────┬──────┘
       │ repr/codegen
       ↓
┌─────────────┐
│  Nim Code   │
└─────────────┘
```

## Architecture

### Core Components

#### 1. Language Capabilities (`src/lang_capabilities.nim`)

Defines what features each target language supports. This drives which transformations are needed.

```nim
let nimCaps = nimCapabilities()
if nimCaps.requiresLowering("for-loop"):
  # Apply for-to-while transformation
```

**Key capabilities tracked:**
- Statement types (defer, for loops, do-while, etc.)
- Type system features (classes, interfaces, generics, etc.)
- Expressions (ternary, lambdas, etc.)
- Memory management (GC, manual, references)

#### 2. Pass Manager (`src/transforms/pass_manager.nim`)

Orchestrates the execution of transformation passes.

**Features:**
- **Iterative execution**: Runs passes multiple times until no changes occur
- **Selective enabling**: Can enable/disable individual passes
- **Recursive application**: Automatically applies passes to all AST nodes
- **Statistics**: Track how many passes are registered/enabled

**Usage:**
```nim
let pm = newPassManager(targetLang = "nim", maxIterations = 10)
pm.addPass(someTransformPass)
let transformed = pm.runPasses(ast)
```

#### 3. Transformation Passes (`src/transforms/`)

Individual transformation modules that modify XLang AST nodes.

**Current passes:**

| Pass | File | Purpose |
|------|------|---------|
| **for-to-while** | `for_to_while.nim` | Lower C-style for loops to while loops |
| **dowhile-to-while** | `dowhile_to_while.nim` | Lower do-while to while-true + break |
| **ternary-to-if** | `ternary_to_if.nim` | Transform `? :` to if expressions |
| **interface-to-concept** | `interface_to_concept.nim` | Transform interfaces to Nim concepts |
| **property-to-procs** | `property_to_procs.nim` | Transform properties to getter/setter procs |

#### 4. Nim Passes Registration (`src/transforms/nim_passes.nim`)

Convenience module that registers all Nim-specific passes.

```nim
let pm = createNimPassManager()  # All passes registered automatically
```

## How Transformations Work

### Example: C-Style For → While

**Input XLang:**
```
for (var i = 0; i < 10; i++)
  echo(i)
```

**XLang AST:**
```nim
XLangNode(
  kind: xnkForStmt,
  forInit: var i = 0,
  forCondition: i < 10,
  forUpdate: inc(i),
  forBody: echo(i)
)
```

**After `for-to-while` pass:**
```nim
XLangNode(
  kind: xnkBlockStmt,
  blockBody: [
    var i = 0,           # Init moved outside
    XLangNode(
      kind: xnkWhileStmt,
      whileCondition: i < 10,
      whileBody: [
        echo(i),
        inc(i)           # Update moved inside
      ]
    )
  ]
)
```

**Generated Nim code:**
```nim
var i = 0
while i < 10:
  echo i
  inc(i)
```

### Example: Ternary → If Expression

**Input XLang:**
```
result = x > 5 ? "big" : "small"
```

**After `ternary-to-if` pass:**
```nim
XLangNode(
  kind: xnkIfStmt,  # Becomes if expression in Nim
  ifCondition: x > 5,
  ifBody: "big",
  elseBody: "small"
)
```

**Generated Nim code:**
```nim
result = if x > 5: "big" else: "small"
```

## Writing a New Transformation Pass

### Template

```nim
import ../../xlangtypes
import options

proc transformMyFeature*(node: XLangNode): XLangNode =
  ## Transform MyFeature into Nim-compatible construct

  # 1. Check if this node needs transformation
  if node.kind != xnkMyFeature:
    return node  # Not our responsibility

  # 2. Extract relevant data from input node
  let someField = node.someField

  # 3. Create transformed XLang AST
  result = XLangNode(
    kind: xnkSupportedConstruct,
    # ... build new structure
  )
```

### Registering the Pass

In `src/transforms/nim_passes.nim`:

```nim
proc registerNimPasses*(pm: PassManager) =
  # ... existing passes ...

  pm.addPass(newTransformPass(
    name: "my-feature",
    kind: tpkLowering,
    description: "Transform my feature to Nim construct",
    transform: transformMyFeature
  ))
```

## Integration with Main Pipeline

### In `main.nim`

```nim
# Parse JSON to XLang
var xlangAst = parseXLangJson(inputFile)

# Apply transformations
if not skipTransforms:
  let pm = createNimPassManager()
  xlangAst = pm.runPasses(xlangAst)

# Convert to Nim
let nimAst = convertXLangToNim(xlangAst)
let nimCode = generateNimCode(nimAst)
```

### Command Line Options

```bash
# Run with transformations (default)
./transpiler input.json -o output.nim -v

# Skip transformations
./transpiler input.json -o output.nim --skip-transforms

# Specify target language
./transpiler input.json -t nim -o output.nim
```

## Testing

### Unit Tests for Individual Passes

See `test_transforms.nim`:

```nim
let forLoop = XLangNode(...)
let transformed = transformForToWhile(forLoop)
assert transformed.kind == xnkWhileStmt
```

### Integration Tests

See `test_integration.nim`:

```nim
# Test full pipeline
let json = %* {...}
let xlang = parseXLangJsonString($json)
let transformed = pm.runPasses(xlang)
let nimAst = convertXLangToNim(transformed)
let code = generateNimCode(nimAst)
```

### Round-Trip Tests

See `test_roundtrip.nim`:

```nim
# Nim → XLang → Transform → Nim
let nimCode = "proc foo() = ..."
let xlang = convertNimToXLang(parseStmt(nimCode))
let transformed = pm.runPasses(xlang)
let nimAst = convertXLangToNim(transformed)
```

## Pass Kinds

Transformations are categorized by purpose:

| Kind | Purpose | Example |
|------|---------|---------|
| `tpkLowering` | Convert unsupported constructs | for → while |
| `tpkNormalization` | Make code more idiomatic | Simplify patterns |
| `tpkOptimization` | Improve performance | Constant folding |
| `tpkValidation` | Check correctness | Verify types |

## Future Enhancements

### Planned Passes

1. **Union types → Variant objects**
   - Input: `x: int | string`
   - Output: `x: object; case kind: enum { int, string }`

2. **Async/await normalization**
   - Ensure consistent async patterns across languages

3. **Exception handling normalization**
   - Map different error handling styles to Nim exceptions

4. **Import resolution**
   - Translate import statements between languages

5. **Operator overloading normalization**
   - Map C#/Python operator overloads to Nim procs

6. **Generic constraint translation**
   - Handle complex generic type constraints

### Optimization Ideas

1. **Pass ordering optimization**
   - Determine optimal order based on dependencies
   - Maybe: passes declare prerequisites

2. **Incremental transformation**
   - Only re-run passes on changed subtrees
   - Track which nodes were modified

3. **Parallel pass execution**
   - Run independent passes in parallel
   - Requires careful dependency analysis

4. **Caching**
   - Cache transformation results for identical subtrees
   - Useful for generated code with repetitive patterns

## Troubleshooting

### Pass Not Running

**Check:**
1. Is pass registered? `pm.listPasses()`
2. Is pass enabled? Check status in list
3. Is target language correct? `pm.targetLang.name`

### Infinite Loop (Max Iterations Hit)

**Possible causes:**
1. Pass creates a node that another pass transforms back
2. Pass incorrectly reports changes when none occurred
3. Cyclic transformation dependency

**Solution:**
- Add debug output to see which pass keeps triggering
- Reduce `maxIterations` temporarily to fail fast
- Check pass logic for correctness

### Wrong Output

**Debug steps:**
1. Test pass individually with unit test
2. Check if multiple passes interfere
3. Verify input XLang AST is correct
4. Check if `xlangtonim_complete` handles transformed node

## Related Documentation

- `XLANG_TO_NIM_MAPPING.md` - How XLang maps to Nim AST
- `IMPLEMENTATION_COMPLETE.md` - Status of XLang → Nim conversion
- `NIM_AS_INPUT.md` - Using Nim as input for testing
- `questions.txt` - Open questions and design decisions
