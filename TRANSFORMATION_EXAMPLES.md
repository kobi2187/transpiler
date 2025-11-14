# Transformation Examples: Input Languages → XLang → Nim

This document shows concrete examples of transforming language-specific constructs
that Nim doesn't have into equivalent Nim code.

## Table of Contents

1. [C-Style For Loops](#1-c-style-for-loops)
2. [Switch/Case Statements](#2-switchcase-statements)
3. [Try-Catch-Finally Semantics](#3-try-catch-finally-semantics)
4. [Null Coalescing Operators](#4-null-coalescing-operators)
5. [Multiple Return Values](#5-multiple-return-values)
6. [List Comprehensions](#6-list-comprehensions)
7. [LINQ Queries](#7-linq-queries)
8. [Java Checked Exceptions](#8-java-checked-exceptions)
9. [Destructuring Assignment](#9-destructuring-assignment)
10. [Async/Await Patterns](#10-asyncawait-patterns)

---

## 1. C-Style For Loops

### Input: Go/C#/Java
```go
for (i := 0; i < 10; i++) {
    println(i)
}
```

### XLang Representation
```nim
XLangNode(
  kind: xnkForStmt,
  forInit: XLangNode(
    kind: xnkVarDecl,
    varName: "i",
    varValue: XLangNode(kind: xnkIntLit, literalValue: "0")
  ),
  forCondition: XLangNode(
    kind: xnkBinaryExpr,
    binaryOp: "<",
    binaryLeft: XLangNode(kind: xnkIdentifier, identName: "i"),
    binaryRight: XLangNode(kind: xnkIntLit, literalValue: "10")
  ),
  forUpdate: XLangNode(
    kind: xnkCallExpr,
    callFunc: XLangNode(kind: xnkIdentifier, identName: "inc"),
    callArgs: @[XLangNode(kind: xnkIdentifier, identName: "i")]
  ),
  forBody: XLangNode(
    kind: xnkBlockStmt,
    blockBody: @[
      XLangNode(kind: xnkCallExpr, ...)
    ]
  )
)
```

### Transformation Logic
```nim
# transformForToWhile in src/transforms/for_to_while.nim
proc transformForToWhile*(node: XLangNode): XLangNode =
  if node.kind != xnkForStmt:
    return node

  # Build: init; while cond: body; update
  var stmts: seq[XLangNode] = @[]

  # Add initialization
  if node.forInit.isSome:
    stmts.add(node.forInit.get)

  # Create while loop with update at end of body
  var bodyStmts = node.forBody.blockBody
  if node.forUpdate.isSome:
    bodyStmts.add(node.forUpdate.get)

  let whileLoop = XLangNode(
    kind: xnkWhileStmt,
    whileCondition: node.forCondition.get,
    whileBody: XLangNode(kind: xnkBlockStmt, blockBody: bodyStmts)
  )

  stmts.add(whileLoop)
  result = XLangNode(kind: xnkBlockStmt, blockBody: stmts)
```

### Output: Nim
```nim
block:
  var i = 0
  while i < 10:
    echo i
    inc(i)
```

---

## 2. Switch/Case Statements

### Input: Go (with fallthrough)
```go
switch x {
case 1:
    println("one")
    fallthrough
case 2:
    println("one or two")
case 3, 4:
    println("three or four")
default:
    println("other")
}
```

### XLang Representation
```nim
XLangNode(
  kind: xnkSwitchStmt,
  switchExpr: XLangNode(kind: xnkIdentifier, identName: "x"),
  switchCases: @[
    XLangNode(
      kind: xnkCaseClause,
      caseValues: @[XLangNode(kind: xnkIntLit, literalValue: "1")],
      caseBody: XLangNode(...),
      caseFallthrough: true  # Special field for Go's fallthrough
    ),
    XLangNode(
      kind: xnkCaseClause,
      caseValues: @[XLangNode(kind: xnkIntLit, literalValue: "2")],
      caseBody: XLangNode(...),
      caseFallthrough: false
    ),
    XLangNode(
      kind: xnkCaseClause,
      caseValues: @[
        XLangNode(kind: xnkIntLit, literalValue: "3"),
        XLangNode(kind: xnkIntLit, literalValue: "4")
      ],
      caseBody: XLangNode(...),
      caseFallthrough: false
    ),
    XLangNode(
      kind: xnkDefaultClause,
      caseBody: XLangNode(...)
    )
  ]
)
```

### Transformation Logic
```nim
# transformSwitchWithFallthrough (NEW - needs implementation)
proc transformSwitchWithFallthrough*(node: XLangNode): XLangNode =
  if node.kind != xnkSwitchStmt:
    return node

  # If no fallthrough, can map directly to Nim's case
  var hasFallthrough = false
  for caseNode in node.switchCases:
    if caseNode.kind == xnkCaseClause and caseNode.caseFallthrough:
      hasFallthrough = true
      break

  if not hasFallthrough:
    return node  # Nim's case can handle this directly

  # With fallthrough, transform to if-elif chain
  var conditions: seq[XLangNode] = @[]

  for i, caseNode in node.switchCases:
    if caseNode.kind == xnkCaseClause:
      # Create condition: x == value1 or x == value2 or ...
      var orConditions: seq[XLangNode] = @[]
      for value in caseNode.caseValues:
        orConditions.add(XLangNode(
          kind: xnkBinaryExpr,
          binaryOp: "==",
          binaryLeft: node.switchExpr,
          binaryRight: value
        ))

      # Combine with 'or'
      var condition = orConditions[0]
      for j in 1..<orConditions.len:
        condition = XLangNode(
          kind: xnkBinaryExpr,
          binaryOp: "or",
          binaryLeft: condition,
          binaryRight: orConditions[j]
        )

      # If fallthrough, include body of next case too
      var body = caseNode.caseBody
      if caseNode.caseFallthrough and i + 1 < node.switchCases.len:
        # Merge with next case's body
        body = mergeBlocks(body, node.switchCases[i + 1].caseBody)

      conditions.add(XLangNode(
        kind: xnkIfStmt,
        ifCondition: condition,
        ifBody: body
      ))

  # Build if-elif chain
  result = buildIfElifChain(conditions)
```

### Output: Nim (with fallthrough)
```nim
# Transformed to if-elif chain because of fallthrough
if x == 1:
  echo "one"
  echo "one or two"  # Fallthrough merged
elif x == 2:
  echo "one or two"
elif x == 3 or x == 4:
  echo "three or four"
else:
  echo "other"
```

### Output: Nim (without fallthrough)
```nim
# Can use Nim's case directly
case x
of 1:
  echo "one"
of 2:
  echo "two"
of 3, 4:
  echo "three or four"
else:
  echo "other"
```

---

## 3. Try-Catch-Finally Semantics

### Input: Java (with multiple catch blocks)
```java
try {
    riskyOperation();
} catch (IOException e) {
    handleIO(e);
} catch (SQLException e) {
    handleSQL(e);
} catch (Exception e) {
    handleGeneral(e);
} finally {
    cleanup();
}
```

### XLang Representation
```nim
XLangNode(
  kind: xnkTryStmt,
  tryBody: XLangNode(kind: xnkBlockStmt, ...),
  catchClauses: @[
    XLangNode(
      kind: xnkCatchClause,
      catchType: XLangNode(kind: xnkNamedType, typeName: "IOException"),
      catchVar: "e",
      catchBody: XLangNode(...)
    ),
    XLangNode(
      kind: xnkCatchClause,
      catchType: XLangNode(kind: xnkNamedType, typeName: "SQLException"),
      catchVar: "e",
      catchBody: XLangNode(...)
    ),
    XLangNode(
      kind: xnkCatchClause,
      catchType: XLangNode(kind: xnkNamedType, typeName: "Exception"),
      catchVar: "e",
      catchBody: XLangNode(...)
    )
  ],
  finallyBody: some(XLangNode(kind: xnkBlockStmt, ...))
)
```

### Transformation Logic
```nim
# transformMultipleCatch (NEW - needs implementation)
proc transformMultipleCatch*(node: XLangNode): XLangNode =
  if node.kind != xnkTryStmt:
    return node

  # Nim only supports single catch block
  # Transform multiple catches into if-elif chain inside single catch

  if node.catchClauses.len <= 1:
    return node  # Already compatible

  # Build single catch with exception type checking
  var ifChain: seq[XLangNode] = @[]

  for catchClause in node.catchClauses:
    let typeCheck = XLangNode(
      kind: xnkCallExpr,
      callFunc: XLangNode(kind: xnkIdentifier, identName: "is"),
      callArgs: @[
        XLangNode(kind: xnkIdentifier, identName: "e"),
        catchClause.catchType
      ]
    )

    ifChain.add(XLangNode(
      kind: xnkIfStmt,
      ifCondition: typeCheck,
      ifBody: catchClause.catchBody
    ))

  result = XLangNode(
    kind: xnkTryStmt,
    tryBody: node.tryBody,
    catchClauses: @[
      XLangNode(
        kind: xnkCatchClause,
        catchType: XLangNode(kind: xnkNamedType, typeName: "Exception"),
        catchVar: "e",
        catchBody: buildIfElifChain(ifChain)
      )
    ],
    finallyBody: node.finallyBody
  )
```

### Output: Nim
```nim
try:
  riskyOperation()
except Exception as e:
  if e is IOException:
    handleIO(e)
  elif e is SQLException:
    handleSQL(e)
  elif e is Exception:
    handleGeneral(e)
finally:
  cleanup()
```

---

## 4. Null Coalescing Operators

### Input: C# (?? and ?.)
```csharp
string name = user?.Name ?? "Anonymous";
int count = items?.Count ?? 0;
```

### XLang Representation
```nim
# Null coalescing: a ?? b
XLangNode(
  kind: xnkNullCoalesceExpr,
  nullCoalesceLeft: XLangNode(kind: xnkIdentifier, identName: "user"),
  nullCoalesceRight: XLangNode(kind: xnkStringLit, literalValue: "Anonymous")
)

# Safe navigation: user?.Name
XLangNode(
  kind: xnkSafeNavigationExpr,
  safeNavObject: XLangNode(kind: xnkIdentifier, identName: "user"),
  safeNavMember: "Name"
)
```

### Transformation Logic
```nim
# transformNullCoalesce (NEW - needs implementation)
proc transformNullCoalesce*(node: XLangNode): XLangNode =
  case node.kind
  of xnkNullCoalesceExpr:
    # a ?? b  →  if a != nil: a else: b
    result = XLangNode(
      kind: xnkIfStmt,
      ifCondition: XLangNode(
        kind: xnkBinaryExpr,
        binaryOp: "!=",
        binaryLeft: node.nullCoalesceLeft,
        binaryRight: XLangNode(kind: xnkNilLit)
      ),
      ifBody: XLangNode(
        kind: xnkBlockStmt,
        blockBody: @[node.nullCoalesceLeft]
      ),
      elseBody: some(XLangNode(
        kind: xnkBlockStmt,
        blockBody: @[node.nullCoalesceRight]
      ))
    )

  of xnkSafeNavigationExpr:
    # user?.Name  →  if user != nil: user.Name else: nil
    result = XLangNode(
      kind: xnkIfStmt,
      ifCondition: XLangNode(
        kind: xnkBinaryExpr,
        binaryOp: "!=",
        binaryLeft: node.safeNavObject,
        binaryRight: XLangNode(kind: xnkNilLit)
      ),
      ifBody: XLangNode(
        kind: xnkBlockStmt,
        blockBody: @[XLangNode(
          kind: xnkMemberAccessExpr,
          memberObject: node.safeNavObject,
          memberName: node.safeNavMember
        )]
      ),
      elseBody: some(XLangNode(
        kind: xnkBlockStmt,
        blockBody: @[XLangNode(kind: xnkNilLit)]
      ))
    )

  else:
    result = node
```

### Output: Nim
```nim
# user?.Name ?? "Anonymous"
let name = if user != nil:
             if user.Name != nil: user.Name else: "Anonymous"
           else:
             "Anonymous"

# Or using Nim's Option type (more idiomatic):
let name = user.some.map(u => u.Name).get("Anonymous")
```

---

## 5. Multiple Return Values

### Input: Go
```go
func divmod(a, b int) (int, int, error) {
    if b == 0 {
        return 0, 0, errors.New("division by zero")
    }
    return a / b, a % b, nil
}

quotient, remainder, err := divmod(10, 3)
```

### XLang Representation
```nim
XLangNode(
  kind: xnkFuncDecl,
  funcName: "divmod",
  params: @[...],
  returnType: some(XLangNode(
    kind: xnkTupleType,  # Multiple return values as tuple
    tupleTypes: @[
      XLangNode(kind: xnkNamedType, typeName: "int"),
      XLangNode(kind: xnkNamedType, typeName: "int"),
      XLangNode(kind: xnkNamedType, typeName: "error")
    ]
  )),
  body: ...
)

# Assignment with tuple unpacking
XLangNode(
  kind: xnkTupleUnpack,
  unpackVars: @["quotient", "remainder", "err"],
  unpackValue: XLangNode(kind: xnkCallExpr, ...)
)
```

### Transformation Logic
```nim
# transformMultipleReturns (NEW - needs implementation)
proc transformMultipleReturns*(node: XLangNode): XLangNode =
  if node.kind != xnkTupleUnpack:
    return node

  # Go-style: a, b, c := foo()
  # Nim-style: let (a, b, c) = foo()

  result = XLangNode(
    kind: xnkVarDecl,
    varName: "",  # Tuple unpacking
    varType: none(XLangNode),
    varValue: some(node.unpackValue),
    varUnpackNames: node.unpackVars  # Store names for unpacking
  )
```

### Output: Nim
```nim
proc divmod(a, b: int): (int, int, ref Exception) =
  if b == 0:
    return (0, 0, newException(DivByZeroDefect, "division by zero"))
  return (a div b, a mod b, nil)

let (quotient, remainder, err) = divmod(10, 3)
```

---

## 6. List Comprehensions

### Input: Python
```python
squares = [x**2 for x in range(10) if x % 2 == 0]
matrix = [[i*j for j in range(3)] for i in range(3)]
```

### XLang Representation
```nim
XLangNode(
  kind: xnkListComprehension,
  compExpr: XLangNode(  # What to compute
    kind: xnkBinaryExpr,
    binaryOp: "**",
    binaryLeft: XLangNode(kind: xnkIdentifier, identName: "x"),
    binaryRight: XLangNode(kind: xnkIntLit, literalValue: "2")
  ),
  compVar: "x",
  compIter: XLangNode(  # What to iterate over
    kind: xnkCallExpr,
    callFunc: XLangNode(kind: xnkIdentifier, identName: "range"),
    callArgs: @[XLangNode(kind: xnkIntLit, literalValue: "10")]
  ),
  compCondition: some(XLangNode(  # Optional filter
    kind: xnkBinaryExpr,
    binaryOp: "==",
    binaryLeft: XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: "%",
      binaryLeft: XLangNode(kind: xnkIdentifier, identName: "x"),
      binaryRight: XLangNode(kind: xnkIntLit, literalValue: "2")
    ),
    binaryRight: XLangNode(kind: xnkIntLit, literalValue: "0")
  ))
)
```

### Transformation Logic
```nim
# transformListComprehension (NEW - needs implementation)
proc transformListComprehension*(node: XLangNode): XLangNode =
  if node.kind != xnkListComprehension:
    return node

  # [expr for var in iter if cond]
  # Transform to:
  # var result: seq[T] = @[]
  # for var in iter:
  #   if cond:
  #     result.add(expr)
  # result

  let resultVar = genUniqueName("compResult")

  var loopBody: seq[XLangNode] = @[]

  # Build: result.add(expr)
  let addCall = XLangNode(
    kind: xnkCallExpr,
    callFunc: XLangNode(
      kind: xnkMemberAccessExpr,
      memberObject: XLangNode(kind: xnkIdentifier, identName: resultVar),
      memberName: "add"
    ),
    callArgs: @[node.compExpr]
  )

  # Wrap in if statement if there's a condition
  if node.compCondition.isSome:
    loopBody.add(XLangNode(
      kind: xnkIfStmt,
      ifCondition: node.compCondition.get,
      ifBody: XLangNode(kind: xnkBlockStmt, blockBody: @[addCall])
    ))
  else:
    loopBody.add(addCall)

  # Build for loop
  let forLoop = XLangNode(
    kind: xnkForeachStmt,
    foreachVar: XLangNode(kind: xnkIdentifier, identName: node.compVar),
    foreachIter: node.compIter,
    foreachBody: XLangNode(kind: xnkBlockStmt, blockBody: loopBody)
  )

  # Wrap in block that declares result var, runs loop, returns result
  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: @[
      XLangNode(
        kind: xnkVarDecl,
        varName: resultVar,
        varValue: some(XLangNode(kind: xnkArrayLit, arrayElements: @[]))
      ),
      forLoop,
      XLangNode(kind: xnkIdentifier, identName: resultVar)
    ]
  )
```

### Output: Nim
```nim
# [x**2 for x in range(10) if x % 2 == 0]
block:
  var compResult: seq[int] = @[]
  for x in 0..<10:
    if x mod 2 == 0:
      compResult.add(x * x)
  compResult

# Or using sequtils.collect (more idiomatic):
import sequtils
let squares = collect:
  for x in 0..<10:
    if x mod 2 == 0:
      x * x
```

---

## 7. LINQ Queries

### Input: C#
```csharp
var adults = from person in people
             where person.Age >= 18
             orderby person.Name
             select new { person.Name, person.Age };
```

### XLang Representation
```nim
XLangNode(
  kind: xnkLinqQuery,
  linqFrom: XLangNode(
    kind: xnkLinqFromClause,
    fromVar: "person",
    fromSource: XLangNode(kind: xnkIdentifier, identName: "people")
  ),
  linqClauses: @[
    XLangNode(
      kind: xnkLinqWhereClause,
      whereCondition: XLangNode(...)  # person.Age >= 18
    ),
    XLangNode(
      kind: xnkLinqOrderByClause,
      orderByExpr: XLangNode(...)  # person.Name
    )
  ],
  linqSelect: XLangNode(
    kind: xnkLinqSelectClause,
    selectExpr: XLangNode(  # Anonymous object
      kind: xnkObjectLit,
      objectFields: @[...]
    )
  )
)
```

### Transformation Logic
```nim
# transformLinqQuery (NEW - needs implementation)
proc transformLinqQuery*(node: XLangNode): XLangNode =
  if node.kind != xnkLinqQuery:
    return node

  # Transform LINQ to functional pipeline using sequtils
  # from x in xs where cond orderby key select expr
  # →
  # xs.filter(x => cond).sorted((a, b) => cmp(a.key, b.key)).map(x => expr)

  var pipeline = node.linqFrom.fromSource
  let varName = node.linqFrom.fromVar

  # Process each clause
  for clause in node.linqClauses:
    case clause.kind
    of xnkLinqWhereClause:
      # Add .filter(x => condition)
      pipeline = XLangNode(
        kind: xnkCallExpr,
        callFunc: XLangNode(
          kind: xnkMemberAccessExpr,
          memberObject: pipeline,
          memberName: "filter"
        ),
        callArgs: @[XLangNode(
          kind: xnkLambdaExpr,
          lambdaParams: @[varName],
          lambdaBody: clause.whereCondition
        )]
      )

    of xnkLinqOrderByClause:
      # Add .sorted((a, b) => cmp(a.key, b.key))
      pipeline = XLangNode(
        kind: xnkCallExpr,
        callFunc: XLangNode(
          kind: xnkMemberAccessExpr,
          memberObject: pipeline,
          memberName: "sorted"
        ),
        callArgs: @[createSortLambda(clause.orderByExpr)]
      )

    else:
      discard

  # Add final .map(x => select_expr)
  result = XLangNode(
    kind: xnkCallExpr,
    callFunc: XLangNode(
      kind: xnkMemberAccessExpr,
      memberObject: pipeline,
      memberName: "map"
    ),
    callArgs: @[XLangNode(
      kind: xnkLambdaExpr,
      lambdaParams: @[varName],
      lambdaBody: node.linqSelect.selectExpr
    )]
  )
```

### Output: Nim
```nim
import sequtils, algorithm

let adults = people
  .filterIt(it.Age >= 18)
  .sorted((a, b) => cmp(a.Name, b.Name))
  .mapIt((Name: it.Name, Age: it.Age))
```

---

## 8. Java Checked Exceptions

### Input: Java
```java
public void readFile(String path) throws IOException, FileNotFoundException {
    // method body
}
```

### XLang Representation
```nim
XLangNode(
  kind: xnkFuncDecl,
  funcName: "readFile",
  params: @[...],
  throwsExceptions: @[  # Special field for Java throws clause
    XLangNode(kind: xnkNamedType, typeName: "IOException"),
    XLangNode(kind: xnkNamedType, typeName: "FileNotFoundException")
  ],
  body: ...
)
```

### Transformation Logic
```nim
# transformCheckedExceptions (NEW - needs implementation)
proc transformCheckedExceptions*(node: XLangNode): XLangNode =
  if node.kind != xnkFuncDecl or node.throwsExceptions.len == 0:
    return node

  # Options for handling Java's checked exceptions:
  # 1. Document in comments (minimal)
  # 2. Return Result[T, E] type (type-safe)
  # 3. Add pragma/attribute (for documentation)

  # Option 2: Change return type to Result
  result = node

  if node.returnType.isSome:
    # T → Result[T, Exception]
    result.returnType = some(XLangNode(
      kind: xnkGenericType,
      genericName: "Result",
      genericArgs: @[
        node.returnType.get,
        XLangNode(kind: xnkNamedType, typeName: "Exception")
      ]
    ))

  # Add comment documenting exceptions
  result.docComment = some(
    "Can raise: " & node.throwsExceptions.mapIt(it.typeName).join(", ")
  )
```

### Output: Nim
```nim
# Option 1: Document in comments
proc readFile(path: string) {.raises: [IOError, OSError].} =
  ## Can raise: IOException, FileNotFoundException
  discard

# Option 2: Use Result type
import results

proc readFile(path: string): Result[string, ref Exception] =
  try:
    ok(readFile(path))
  except IOError, OSError:
    err(getCurrentException())
```

---

## 9. Destructuring Assignment

### Input: JavaScript/Python
```javascript
const {name, age} = person;
const [first, second, ...rest] = array;
```

### XLang Representation
```nim
# Object destructuring
XLangNode(
  kind: xnkDestructureObj,
  destructureFields: @["name", "age"],
  destructureSource: XLangNode(kind: xnkIdentifier, identName: "person")
)

# Array destructuring with rest
XLangNode(
  kind: xnkDestructureArray,
  destructureVars: @["first", "second"],
  destructureRest: some("rest"),
  destructureSource: XLangNode(kind: xnkIdentifier, identName: "array")
)
```

### Transformation Logic
```nim
# transformDestructuring (NEW - needs implementation)
proc transformDestructuring*(node: XLangNode): XLangNode =
  case node.kind
  of xnkDestructureObj:
    # {name, age} = person
    # Transform to:
    # let name = person.name
    # let age = person.age

    var declarations: seq[XLangNode] = @[]
    for field in node.destructureFields:
      declarations.add(XLangNode(
        kind: xnkLetDecl,
        varName: field,
        varValue: some(XLangNode(
          kind: xnkMemberAccessExpr,
          memberObject: node.destructureSource,
          memberName: field
        ))
      ))

    result = XLangNode(kind: xnkBlockStmt, blockBody: declarations)

  of xnkDestructureArray:
    # [first, second, ...rest] = array
    # Transform to:
    # let first = array[0]
    # let second = array[1]
    # let rest = array[2..^1]

    var declarations: seq[XLangNode] = @[]

    for i, varName in node.destructureVars:
      declarations.add(XLangNode(
        kind: xnkLetDecl,
        varName: varName,
        varValue: some(XLangNode(
          kind: xnkIndexExpr,
          indexObject: node.destructureSource,
          indexValue: XLangNode(kind: xnkIntLit, literalValue: $i)
        ))
      ))

    if node.destructureRest.isSome:
      let startIdx = node.destructureVars.len
      declarations.add(XLangNode(
        kind: xnkLetDecl,
        varName: node.destructureRest.get,
        varValue: some(XLangNode(
          kind: xnkSliceExpr,
          sliceObject: node.destructureSource,
          sliceStart: XLangNode(kind: xnkIntLit, literalValue: $startIdx),
          sliceEnd: none(XLangNode)  # To end
        ))
      ))

    result = XLangNode(kind: xnkBlockStmt, blockBody: declarations)

  else:
    result = node
```

### Output: Nim
```nim
# Object destructuring
let name = person.name
let age = person.age

# Array destructuring with rest
let first = array[0]
let second = array[1]
let rest = array[2..^1]
```

---

## 10. Async/Await Patterns

### Input: Python (different from Nim's async)
```python
async def fetch_data(url):
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.text()

result = await fetch_data("https://example.com")
```

### XLang Representation
```nim
XLangNode(
  kind: xnkAsyncFuncDecl,
  funcName: "fetch_data",
  params: @[...],
  body: XLangNode(
    kind: xnkBlockStmt,
    blockBody: @[
      XLangNode(
        kind: xnkAsyncWithStmt,  # Python's "async with"
        withExpr: XLangNode(...),  # aiohttp.ClientSession()
        withVar: "session",
        withBody: XLangNode(...)
      )
    ]
  )
)
```

### Transformation Logic
```nim
# transformAsyncWith (NEW - needs implementation)
proc transformAsyncWith*(node: XLangNode): XLangNode =
  if node.kind != xnkAsyncWithStmt:
    return node

  # Python's "async with" → Nim's defer pattern
  # async with resource as var:
  #   body
  # Transform to:
  # let var = await resource
  # defer: var.close()
  # body

  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: @[
      XLangNode(
        kind: xnkLetDecl,
        varName: node.withVar,
        varValue: some(XLangNode(
          kind: xnkAwaitExpr,
          awaitExpr: node.withExpr
        ))
      ),
      XLangNode(
        kind: xnkDeferStmt,
        deferBody: XLangNode(
          kind: xnkCallExpr,
          callFunc: XLangNode(
            kind: xnkMemberAccessExpr,
            memberObject: XLangNode(kind: xnkIdentifier, identName: node.withVar),
            memberName: "close"
          ),
          callArgs: @[]
        )
      ),
      node.withBody
    ]
  )
```

### Output: Nim
```nim
import asyncdispatch, httpclient

proc fetchData(url: string): Future[string] {.async.} =
  let client = newAsyncHttpClient()
  defer: client.close()

  let response = await client.getContent(url)
  return response

let result = waitFor fetchData("https://example.com")
```

---

## Summary: Adding New Transformations

To add a new transformation for a construct that Nim doesn't have:

1. **Define XLang representation** in `xlangtypes.nim`
   - Add node kind to `XLangNodeKind` enum
   - Add fields to `XLangNode` variant object

2. **Create transformation module** in `src/transforms/`
   - Implement `transformFoo*(node: XLangNode): XLangNode`
   - Handle the specific node kind
   - Return transformed XLang tree (using Nim-compatible constructs)

3. **Register pass** in `src/transforms/nim_passes.nim`
   - Add pass ID to `TransformPassID` enum in pass_manager.nim
   - Register with `pm.addPass(newTransformPass(...))`
   - Specify dependencies if any

4. **Update xlangtonim_complete.nim** if needed
   - If transformation creates new patterns
   - Ensure Nim AST conversion handles them

5. **Test** with unit and integration tests
   - Create test cases in `test_transforms.nim`
   - Verify end-to-end in `test_integration.nim`

The key principle: **XLang is a superset, transformations lower it to Nim's subset**.
