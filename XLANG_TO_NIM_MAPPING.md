# XLang to Nim AST Node Mapping Reference

Quick reference for how each XLang node kind maps to Nim AST.

## Types

| XLang Node | Nim AST Node | Example |
|------------|--------------|---------|
| `xnkNamedType` | `nnkIdent` | `int`, `string` |
| `xnkArrayType` | `nnkBracketExpr` | `array[10, int]` |
| `xnkMapType` | `nnkBracketExpr` | `Table[string, int]` |
| `xnkFuncType` | `nnkProcTy` | `proc(x: int): string` |
| `xnkPointerType` | `nnkPtrTy` | `ptr int` |
| `xnkReferenceType` | `nnkRefTy` | `ref object` |
| `xnkGenericType` | `nnkBracketExpr` | `seq[int]`, `Option[T]` |
| `xnkUnionType` | Comment | No direct equivalent |
| `xnkIntersectionType` | Comment | No direct equivalent |

## Literals

| XLang Node | Nim AST | Example |
|------------|---------|---------|
| `xnkIntLit` | `newLit(int)` | `42` |
| `xnkFloatLit` | `newLit(float)` | `3.14` |
| `xnkStringLit` | `newLit(string)` | `"hello"` |
| `xnkCharLit` | `newLit(char)` | `'a'` |
| `xnkBoolLit` | `newLit(bool)` | `true` |
| `xnkNoneLit` | `newNilLit()` | `nil` |

## Expressions

| XLang Node | Nim AST Node | Example |
|------------|--------------|---------|
| `xnkIdentifier` | `nnkIdent` | `myVar` |
| `xnkBinaryExpr` | `nnkInfix` | `x + y` |
| `xnkUnaryExpr` | `nnkPrefix` | `-x`, `not x` |
| `xnkTernaryExpr` | `nnkIfExpr` | `if c: a else: b` |
| `xnkCallExpr` | `nnkCall` | `foo(1, 2)` |
| `xnkIndexExpr` | `nnkBracketExpr` | `arr[i]` |
| `xnkSliceExpr` | `nnkInfix` with `..` | `0..10` |
| `xnkMemberAccessExpr` | `nnkDotExpr` | `obj.field` |
| `xnkLambdaExpr` | `nnkLambda` | `proc(x: int): int = x * 2` |
| `xnkListExpr` | `nnkBracket` | `[1, 2, 3]` |
| `xnkSetExpr` | `nnkCurly` | `{1, 2, 3}` |
| `xnkTupleExpr` | `nnkTupleConstr` | `(1, "a", true)` |
| `xnkDictExpr` | `nnkTableConstr` | `{"a": 1, "b": 2}` |
| `xnkAwaitExpr` | `nnkCommand` | `await future` |
| `xnkYieldExpr` | `nnkYieldStmt` | `yield value` |

## Statements

| XLang Node | Nim AST Node | Conversion Notes |
|------------|--------------|------------------|
| `xnkBlockStmt` | `nnkStmtList` | Direct mapping |
| `xnkIfStmt` | `nnkIfStmt` | With `nnkElifBranch`, `nnkElse` |
| `xnkSwitchStmt` | `nnkCaseStmt` | With `nnkOfBranch`, `nnkElse` |
| `xnkForStmt` | `nnkWhileStmt` | C-style for → while |
| `xnkWhileStmt` | `nnkWhileStmt` | Direct mapping |
| `xnkDoWhileStmt` | `nnkWhileStmt` | `while true` + `break` |
| `xnkForeachStmt` | `nnkForStmt` | Direct mapping |
| `xnkTryStmt` | `nnkTryStmt` | With except/finally |
| `xnkCatchStmt` | `nnkExceptBranch` | Part of try |
| `xnkFinallyStmt` | `nnkFinally` | Part of try |
| `xnkReturnStmt` | `nnkReturnStmt` | Direct mapping |
| `xnkYieldStmt` | `nnkYieldStmt` | Direct mapping |
| `xnkBreakStmt` | `nnkBreakStmt` | Direct mapping |
| `xnkContinueStmt` | `nnkContinueStmt` | Direct mapping |
| `xnkThrowStmt` | `nnkRaiseStmt` | throw → raise |
| `xnkAssertStmt` | `nnkCommand` | `assert expr` |
| `xnkPassStmt` | `nnkDiscardStmt` | pass → discard |
| `xnkDeferStmt` | `nnkDefer` | Direct mapping |
| `xnkStaticStmt` | `nnkStaticStmt` | Direct mapping |
| `xnkAsmStmt` | `nnkAsmStmt` | Direct mapping |

## Declarations

| XLang Node | Nim AST Node | Conversion Notes |
|------------|--------------|------------------|
| `xnkFuncDecl` | `nnkProcDef` | Direct mapping |
| `xnkMethodDecl` | `nnkMethodDef` | Direct mapping |
| `xnkClassDecl` | `nnkTypeSection` → `nnkRefTy` → `nnkObjectTy` | ref object |
| `xnkStructDecl` | `nnkTypeSection` → `nnkRefTy` → `nnkObjectTy` | ref object |
| `xnkInterfaceDecl` | `nnkTypeSection` → `nnkConceptTy` | Concept |
| `xnkEnumDecl` | `nnkTypeSection` → `nnkEnumTy` | Direct mapping |
| `xnkVarDecl` | `nnkVarSection` | Direct mapping |
| `xnkLetDecl` | `nnkLetSection` | Direct mapping |
| `xnkConstDecl` | `nnkConstSection` | Direct mapping |
| `xnkTypeDecl` | `nnkTypeSection` → `nnkTypeDef` | Type alias |
| `xnkPropertyDecl` | Multiple `nnkProcDef` | Getter + setter procs |
| `xnkFieldDecl` | `nnkIdentDefs` | In object reclist |
| `xnkConstructorDecl` | `nnkProcDef` | Named `new` |
| `xnkDestructorDecl` | `nnkProcDef` | Named `=destroy` |
| `xnkDelegateDecl` | `nnkTypeSection` → `nnkProcTy` | Function type |
| `xnkTemplateDef` | `nnkTemplateDef` | Direct mapping |
| `xnkMacroDef` | `nnkMacroDef` | Direct mapping |
| `xnkDistinctTypeDef` | `nnkTypeSection` → `nnkDistinctTy` | Direct mapping |
| `xnkConceptDef` | `nnkTypeSection` → `nnkConceptTy` | Direct mapping |

## Other Nodes

| XLang Node | Nim AST Node | Conversion Notes |
|------------|--------------|------------------|
| `xnkImport` | `nnkImportStmt` | Direct mapping |
| `xnkExport` | `nnkExportStmt` | Direct mapping |
| `xnkComment` | `newCommentStmtNode` | `#` or `##` prefix |
| `xnkParameter` | `nnkIdentDefs` | In formal params |
| `xnkArgument` | Expression or `nnkExprEqExpr` | Named if has name |
| `xnkGenericParameter` | `nnkIdentDefs` | In generic params |
| `xnkAttribute` | `nnkPragma` | Decorator → pragma |
| `xnkDecorator` | `nnkPragma` | Decorator → pragma |
| `xnkPragma` | `nnkPragma` | Direct mapping |
| `xnkMixinStmt` | `nnkMixinStmt` | Direct mapping |
| `xnkBindStmt` | `nnkBindStmt` | Direct mapping |
| `xnkTupleConstr` | `nnkTupleConstr` | Direct mapping |
| `xnkTupleUnpacking` | `nnkVarTuple` | Direct mapping |

## Complex Conversions

### 1. Properties → Getter/Setter

```nim
# XLang (conceptual)
property Age:
  get: return self.age
  set: self.age = value

# Nim (after conversion)
proc Age(self: Person): int =
  return self.age

proc `Age=`(self: Person, value: int) =
  self.age = value
```

### 2. C-Style For → While

```nim
# XLang (conceptual)
for (var i = 0; i < 10; i++):
  print(i)

# Nim (after conversion)
var i = 0
while i < 10:
  echo i
  inc(i)
```

### 3. Do-While → While True

```nim
# XLang (conceptual)
do:
  processItem()
while hasMore()

# Nim (after conversion)
while true:
  processItem()
  if not hasMore():
    break
```

### 4. Ternary → If Expression

```nim
# XLang (conceptual)
result = condition ? valueA : valueB

# Nim (after conversion)
result = if condition: valueA else: valueB
```

### 5. Interface → Concept

```nim
# XLang (conceptual)
interface Drawable:
  proc draw()

# Nim (after conversion)
type Drawable = concept x
  x.draw()
```

### 6. Class → Ref Object

```nim
# XLang (conceptual)
class Person extends Human:
  var name: string
  var age: int

# Nim (after conversion)
type Person = ref object of Human
  name: string
  age: int
```

## Quick Lookup Table

Need to convert X? Look it up:

| Want to convert... | Use function... | Returns... |
|-------------------|-----------------|------------|
| Any type | `convertType()` | `NimNode` |
| Any expression | `convertExpression()` | `NimNode` |
| Any statement | `convertStatement()` | `NimNode` |
| Any declaration | `convertDeclaration()` | `NimNode` |
| Import/Export/Comment | `convertOther()` | `NimNode` |
| Any XLang node | `convertXLangToNim()` | `NimNode` |
| Full AST | `convertXLangASTToNimAST()` | `NimNode` |

## Edge Cases Handled

1. **Optional fields**: Checked with `.isSome` before accessing
2. **Empty nodes**: Use `newEmptyNode()` for Nim AST
3. **Named arguments**: Converted to `nnkExprEqExpr`
4. **Variable number of children**: Use seq and iterate
5. **No return type**: Use `newEmptyNode()` in params[0]
6. **No else branch**: Don't add `nnkElse` node
7. **Async functions**: Add `{.async.}` pragma

## Implementation Status Legend

- ✅ Complete: Fully implemented and tested
- ⚠️ Manual: Needs manual conversion (generates comment)
- 🔧 Transform: Needs transformation pass before conversion

| Status | Node Types |
|--------|------------|
| ✅ | 68 node types |
| ⚠️ | 3 node types (Union, Intersection, Comprehensions) |
| 🔧 | 0 (all conversions work, but some benefit from transformation) |
