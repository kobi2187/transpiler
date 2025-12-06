# MyNimNode - Independent Nim AST Structure

An independent implementation of Nim's AST node structure, based on the Nim compiler's `ast.nim` but with no dependencies on compiler internals (no macros, astdef, etc.).

## Features

### Complete Node Type Coverage

- **180+ node kinds** organized by category:
  - Literals (int, float, string, char, nil)
  - Identifiers and symbols
  - Expression nodes (calls, infix, prefix, dot expressions, etc.)
  - Statement nodes (if, while, for, block, return, etc.)
  - Declaration nodes (proc, var, let, const, type definitions)
  - Type nodes (object, tuple, ref, ptr, distinct, etc.)

### Efficient Variant Object Storage

The `MyNimNodeObj` uses case discrimination for efficient storage:
- Integer literals: `intVal: BiggestInt`
- Float literals: `floatVal: BiggestFloat`
- String literals: `strVal: string`
- Identifiers: `identStr: string`
- Symbols: `symName: string`
- All other nodes: `sons: MyNimNodeSeq` (child nodes)

## Constructor Procs

### Basic Constructors
- `newMyNimNode(kind)` - Generic constructor for any node kind
- `newIntLitNode(i)` - Integer literal
- `newFloatLitNode(f)` - Float literal
- `newStrLitNode(s)` - String literal
- `newCharNode(c)` - Character literal
- `newIdentNode(s)` - Identifier
- `newSymNode(s)` - Symbol
- `newEmptyNode()` - Empty node
- `newNilLit()` - Nil literal

### Statement Constructors
- `newStmtList()` - Statement list
- `newVarStmt(name, typ, value)` - Variable declaration
- `newLetStmt(name, typ, value)` - Let binding
- `newConstStmt(name, typ, value)` - Constant declaration
- `newAssignment(lhs, rhs)` - Assignment statement
- `newReturnStmt(expr)` - Return statement
- `newDiscardStmt(expr)` - Discard statement

### Control Flow Constructors
- `newIfStmt(branches...)` - If statement
- `newElifBranch(cond, body)` - Elif branch
- `newElse(body)` - Else branch
- `newWhileStmt(cond, body)` - While loop
- `newForStmt(vars, iterable, body)` - For loop
- `newBlockStmt(label, body)` - Block statement

### Expression Constructors
- `newCall(op, args...)` - Function call
- `newInfixCall(op, a, b)` - Infix operation (e.g., a + b)
- `newPrefixCall(op, arg)` - Prefix operation (e.g., -a)
- `newDotExpr(a, b)` - Dot expression (a.b)
- `newBracketExpr(base, indices...)` - Bracket access (a[i])
- `newColonExpr(name, value)` - Colon expression (name: value)

### Type and Definition Constructors
- `newIdentDefs(name, typ, default)` - Identifier definition
- `newPragma(pragmas...)` - Pragma list
- `newPostfixExport(name)` - Export marker (name*)

### Collection Constructors
- `newPar(elements...)` - Parenthesized expression/tuple
- `newTupleConstr(elements...)` - Tuple constructor
- `newBracket(elements...)` - Array/seq literal
- `newTree(kind, children...)` - Generic tree with children

## Tree Manipulation

### Access and Modification
- `add(parent, child)` - Add child to parent
- `node[i]` - Get child at index
- `node[i] = child` - Set child at index
- `len(node)` - Number of children
- `last(node)` - Get last child
- `node.last = child` - Set last child
- `del(node, idx)` - Delete child at index
- `insert(node, idx, child)` - Insert child at index

### Iteration
- `for child in node: ...` - Iterate over children
- `for i, child in node: ...` - Iterate with indices

### Copying and Comparison
- `copy(node)` - Shallow copy
- `copyTree(node)` - Deep copy (recursive)
- `sameTree(a, b)` - Structural equality check

## String Representation

- `$node` - Basic string representation
- `treeRepr(node, indent)` - Detailed tree representation for debugging

## Example Usage

```nim
import src/my_nim_node

# Build: var x: int = 42
let varStmt = newVarStmt(
  newIdentNode("x"),
  newIdentNode("int"),
  newIntLitNode(42)
)

# Build: x + y
let addExpr = newInfixCall("+",
  newIdentNode("x"),
  newIdentNode("y")
)

# Build a statement list
let stmts = newStmtList()
stmts.add(varStmt)
stmts.add(newAssignment(newIdentNode("x"), newIntLitNode(100)))

# Debug output
echo treeRepr(stmts)
```

## Design Notes

1. **Independence**: No dependencies on Nim's macro system or compiler internals
2. **Simplicity**: Uses strings for identifiers and symbols (no PIdent or PSym types)
3. **Completeness**: All node kinds from the Nim compiler are represented
4. **Extensibility**: Easy to add custom fields to specific node kinds as needed
5. **Compatibility**: Node kind names match the Nim compiler for easy reference

## Use Cases

- Building transpilers (C#, Python, etc. → Nim)
- Code generation
- AST manipulation and transformation
- Custom Nim-like DSLs
- Learning compiler internals

## See Also

- Original Nim compiler sources: `~/prog/experimental_nim/Nim/compiler/`
  - `ast.nim` - Node structure
  - `nodekinds.nim` - Node kind enumeration
  - `astdef.nim` - Type definitions
