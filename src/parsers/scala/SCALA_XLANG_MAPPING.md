# Scala to XLang Semantic Mapping

This document provides a comprehensive mapping between Scala language constructs and XLang intermediate representation nodes at the semantic level.

## Table of Contents

1. [Type Declarations](#type-declarations)
2. [Statements](#statements)
3. [Expressions](#expressions)
4. [Types](#types)
5. [Scala-Specific Features Requiring Lowering](#scala-specific-features)
6. [Field Mapping Verification](#field-mapping-verification)
7. [Semantic Equivalents in Other Languages](#semantic-equivalents)

---

## Type Declarations

### Class Declaration

**Scala Construct**: `class Foo(x: Int) extends Bar with Baz`

**XLang Node**: `xnkClassDecl`

**Required Fields**:
- ✅ `typeNameDecl`: class name ("Foo")
- ✅ `baseTypes`: base class + traits (["Bar", "Baz"])
- ✅ `members`: class members (methods, fields, nested types)
- ✅ `typeIsStatic`: always false in Scala (no static classes)
- ✅ `typeIsFinal`: maps from `final` modifier
- ✅ `typeIsAbstract`: maps from `abstract` modifier
- ✅ `typeIsPrivate`: maps from `private` modifier
- ✅ `typeIsProtected`: maps from `protected` modifier
- ✅ `typeIsPublic`: maps from `public` (default in Scala)
- ⚠️ **MISSING**: `typeParams` for generic parameters (e.g., `class Foo[T]`)
- ⚠️ **MISSING**: `ctorParams` for primary constructor parameters

**Current Implementation Issues**:
```scala
// Current code stores type params and ctor params separately
Map(
  "typeParams" -> cls.tparams.map(convertTypeParam).toSeq,
  "ctorParams" -> cls.ctor.paramss.flatten.map(convertParameter).toSeq,
  // ...
)
```

These fields don't exist in xnkClassDecl! Should be stored in members as constructor.

**Scala-Specific Extensions**:
- **Case classes** (`case class Foo(...)`): Add `typeIsCase` flag (not in XLang spec)
- **Sealed classes** (`sealed class/trait`): Use `typeIsSealed` flag (not in XLang spec)
- **Singleton objects**: Use `isSingleton` flag (not in XLang spec)

---

### Trait Declaration

**Scala Construct**: `trait Foo extends Bar`

**XLang Node**: `xnkInterfaceDecl`

**Required Fields**:
- ✅ `typeNameDecl`: trait name
- ✅ `baseTypes`: extended traits
- ✅ `members`: trait members
- ✅ `typeIsStatic`: always false
- ✅ `typeIsFinal`: always false (traits can't be final)
- ✅ `typeIsAbstract`: always true
- ✅ `typeIsPrivate`: from modifiers
- ✅ `typeIsProtected`: from modifiers
- ✅ `typeIsPublic`: from modifiers

**Semantic Notes**:
- Scala traits can have concrete methods (unlike Java interfaces pre-Java 8)
- Traits can have state (fields)
- This is semantically closer to abstract classes with multiple inheritance

---

### Object Declaration (Singleton)

**Scala Construct**: `object Foo extends Bar`

**XLang Node**: `xnkClassDecl` with `isSingleton: true`

**Required Fields**:
- ✅ `typeNameDecl`: object name
- ✅ `baseTypes`: extended classes/traits
- ✅ `members`: object members
- ⚠️ **CUSTOM**: `isSingleton: true` (not in XLang spec)

**Semantic Translation**:
Objects are singleton instances. In other languages:
- **C#**: Static class or singleton pattern
- **Java**: Class with private constructor and getInstance()
- **Nim**: Module-level vars/procs
- **Python**: Module or metaclass

---

### Method Declaration

**Scala Construct**: `def foo[T](x: Int)(implicit ctx: Context): String = ...`

**XLang Node**: `xnkMethodDecl`

**Required Fields**:
- ✅ `methodName`: method name
- ✅ `mparams`: parameters (sequence of parameter lists!)
- ✅ `mreturnType`: return type
- ✅ `mbody`: method body
- ✅ `methodIsAsync`: always false (Scala uses Future, not async/await)
- ✅ `methodIsStatic`: from modifiers
- ✅ `methodIsAbstract`: from modifiers
- ✅ `methodIsFinal`: from modifiers
- ✅ `methodIsPrivate`: from modifiers
- ✅ `methodIsProtected`: from modifiers
- ✅ `methodIsPublic`: from modifiers
- ⚠️ **MISSING**: `receiver` for extension methods

**Current Implementation Issues**:
```scala
// Multiple parameter lists stored as:
"mparams" -> defn.paramss.map(params => params.map(convertParameter).toSeq).toSeq
```

This creates nested arrays, but XLang expects `seq[XLangNode]` (flat list).

**Scala-Specific Features**:
- **Multiple parameter lists**: `def foo(x: Int)(y: Int)` - needs flattening or special handling
- **Implicit parameters**: `(implicit ctx: Context)` - need `isImplicit` flag on parameters
- **Type parameters**: `def foo[T]` - need to store in separate field
- **By-name parameters**: `def foo(x: => Int)` - need `isByName` flag

---

### Field Declaration

**Scala Construct**: `val x: Int = 5` or `var y: String = "hello"`

**XLang Node**: `xnkFieldDecl`

**Required Fields**:
- ✅ `fieldName`: field name
- ✅ `fieldType`: field type
- ✅ `fieldInitializer`: initial value (optional)
- ✅ `fieldIsStatic`: from modifiers
- ✅ `fieldIsFinal`: true for `val`, false for `var`
- ✅ `fieldIsVolatile`: from `@volatile` annotation
- ✅ `fieldIsTransient`: from `@transient` annotation
- ✅ `fieldIsPrivate`: from modifiers
- ✅ `fieldIsProtected`: from modifiers
- ✅ `fieldIsPublic`: from modifiers
- ⚠️ **CUSTOM**: `fieldIsMutable` (not in XLang, should use fieldIsFinal inverted)

---

## Statements

### If Statement

**Scala Construct**: `if (cond) expr1 else expr2`

**XLang Node**: `xnkIfStmt`

**Required Fields**:
- ✅ `ifCondition`: condition expression
- ✅ `ifBody`: then branch
- ✅ `elifBranches`: sequence of (condition, body) tuples (empty for simple if-else)
- ✅ `elseBody`: else branch (optional)

**Semantic Note**: In Scala, if is an **expression** that returns a value, not just a statement.

---

### While Statement

**Scala Construct**: `while (cond) body`

**XLang Node**: `xnkWhileStmt`

**Required Fields**:
- ✅ `whileCondition`: loop condition
- ✅ `whileBody`: loop body

---

### Match Expression (Pattern Matching)

**Scala Construct**:
```scala
x match {
  case 1 => "one"
  case n if n > 10 => "big"
  case Point(x, y) => s"point at $x,$y"
  case _ => "other"
}
```

**XLang Node**: `xnkSwitchStmt`

**Required Fields**:
- ✅ `switchExpr`: expression being matched
- ✅ `switchCases`: sequence of case clauses

**For each case**:
- ✅ `xnkCaseClause` with:
  - ⚠️ `caseValues`: pattern (but Scala has complex patterns!)
  - ⚠️ `caseBody`: case body
  - ✅ `caseFallthrough`: always false in Scala

**Current Implementation Issues**:
```scala
Map(
  "kind" -> "xnkCaseClause",
  "casePattern" -> convertPattern(cas.pat),  // WRONG FIELD NAME
  "caseGuard" -> cas.cond.map(convertTerm).orNull,  // NOT IN XLANG
  "caseBody" -> convertTerm(cas.body)
)
```

Should be:
```scala
Map(
  "kind" -> "xnkCaseClause",
  "caseValues" -> Seq(convertPattern(cas.pat)),  // Pattern as value
  "caseBody" -> convertTerm(cas.body),
  "caseFallthrough" -> false
)
```

**Scala-Specific: Pattern Guards**
```scala
case n if n > 10 => ...  // Guard: "if n > 10"
```

Guards need special handling - could embed in pattern or convert to nested if.

---

### For Comprehension

**Scala Construct**:
```scala
for {
  i <- 1 to 10
  if i % 2 == 0
  j <- 1 to i
} yield i * j
```

**XLang Node**: `xnkExternal_ForComprehension` (needs lowering!)

**Required Fields**:
- ⚠️ **CUSTOM**: `extForEnumerators`: generators and guards
- ⚠️ **CUSTOM**: `extForBody`: body expression

**Semantic Equivalent**:
For comprehensions are **syntactic sugar for flatMap/map/filter**:

```scala
// For comprehension
for {
  x <- xs
  if x > 5
  y <- ys
} yield x + y

// Desugars to:
xs.filter(x => x > 5).flatMap(x => ys.map(y => x + y))
```

**Translation to other languages**:
- **C#**: LINQ query syntax or SelectMany
- **Python**: List comprehension `[x+y for x in xs if x > 5 for y in ys]`
- **Nim**: Manual loops or `collect` macro

**Lowering Strategy**: Convert to nested foreach with filter

---

### Try-Catch-Finally

**Scala Construct**:
```scala
try {
  risky()
} catch {
  case e: IOException => handle(e)
  case _: Exception => recover()
} finally {
  cleanup()
}
```

**XLang Node**: `xnkTryStmt`

**Required Fields**:
- ✅ `tryBody`: try block
- ✅ `catchClauses`: sequence of catch blocks
- ✅ `finallyClause`: finally block (optional)

**For each catch** (`xnkCatchStmt`):
- ⚠️ `catchType`: exception type (from pattern)
- ⚠️ `catchVar`: variable name (from pattern)
- ✅ `catchBody`: handler body

**Current Implementation**: Uses pattern matching (case clauses) which is more powerful than simple type-based catch.

---

## Expressions

### Binary Operators

**Scala Construct**: `a + b`, `x && y`, `list ::: other`

**XLang Node**: `xnkBinaryExpr`

**Required Fields**:
- ✅ `binaryLeft`: left operand
- ✅ `binaryOp`: **BinaryOp enum value** (NOT string!)
- ✅ `binaryRight`: right operand

**Current Implementation Issue**:
```scala
Map(
  "kind" -> "xnkBinaryExpr",
  "binaryLeft" -> convertTerm(lhs),
  "binaryOp" -> binaryOpMap.getOrElse(op.value, op.value),  // Returns STRING
  "binaryRight" -> ...
)
```

**CRITICAL BUG**: XLang expects `BinaryOp` enum, not string!

Must use proper enum values:
- `"add"` → `opAdd`
- `"sub"` → `opSub`
- etc.

But Scala JSON output uses strings, so this must be converted during deserialization.

**Scala-Specific Operators**:
- `:::` - list concatenation
- `::` - cons operator
- Custom operators (user-defined)

These need mapping or marking as external.

---

### Lambda Expressions

**Scala Construct**: `(x: Int) => x + 1` or `x => x + 1`

**XLang Node**: `xnkLambdaExpr`

**Required Fields**:
- ✅ `lambdaParams`: parameters
- ✅ `lambdaReturnType`: return type (optional in Scala)
- ✅ `lambdaBody`: lambda body

**Current Implementation**: ✅ Correct

---

### Method Call

**Scala Construct**: `obj.method(arg1, arg2)`

**XLang Node**: `xnkCallExpr`

**Required Fields**:
- ✅ `callee`: method being called (can be xnkMemberAccessExpr)
- ✅ `args`: arguments

**Scala-Specific**:
- **Infix notation**: `list map func` same as `list.map(func)`
- **Multiple parameter lists**: `curry(a)(b)`
- **Named arguments**: `method(x = 5, y = 10)`
- **Default arguments**: handled by caller

---

### Member Access

**Scala Construct**: `obj.field` or `obj.method`

**XLang Node**: `xnkMemberAccessExpr`

**Required Fields**:
- ✅ `memberExpr`: object expression
- ✅ `memberName`: member name
- ⚠️ `isEnumAccess`: false (Scala uses case objects, not enums)
- ⚠️ `enumTypeName`: empty
- ⚠️ `enumFullName`: empty

---

### Object Creation

**Scala Construct**: `new Foo(arg1, arg2)`

**XLang Node**: `xnkCallExpr` with `isNewExpr: true`

**Required Fields**:
- ✅ `callee`: type being constructed
- ✅ `args`: constructor arguments
- ⚠️ **CUSTOM**: `isNewExpr: true` (not in XLang spec!)

**Current Implementation**: ✅ Correct structure

---

### This/Super

**Scala Construct**: `this`, `super.method()`

**XLang Node**: `xnkThisExpr`, `xnkBaseExpr`

**Required Fields**:
- `xnkThisExpr`: no required fields (just represents "this")
- `xnkBaseExpr`: no required fields (just represents "super")

**Current Implementation**:
```scala
Map(
  "kind" -> "xnkThisExpr",
  "thisType" -> qual.syntax  // CUSTOM FIELD
)
```

**Issue**: `thisType` field doesn't exist in XLang spec. Should be removed.

---

## Types

### Named Type

**Scala Construct**: `Int`, `String`, `MyClass`

**XLang Node**: `xnkNamedType`

**Required Fields**:
- ✅ `typeName`: type name
- ⚠️ `isEmptyMarkerType`: only for Go empty interfaces/structs

**Current Implementation**: ✅ Correct

---

### Parameterized Type (Generics)

**Scala Construct**: `List[Int]`, `Map[String, Int]`

**XLang Node**: `xnkNamedType` with `typeArgs`

**Required Fields**:
- ✅ `typeName`: base type name ("List")
- ⚠️ **CUSTOM**: `typeArgs`: type arguments ([Int])

**Current Implementation Issue**:
```scala
Type.Apply(tpe, args) =>
  Map(
    "kind" -> "xnkNamedType",
    "typeName" -> tpe.syntax,
    "typeArgs" -> args.map(convertType).toSeq  // CUSTOM FIELD
  )
```

**XLang Spec Check**: Looking at xnkNamedType definition:
```nim
of xnkNamedType:
  typeName*: string
  isEmptyMarkerType*: Option[bool]
```

**CRITICAL**: `typeArgs` field does NOT exist! Should use `xnkGenericType` instead:
```nim
of xnkGenericType:
  genericTypeName*: string
  genericBase*: Option[XLangNode]
  genericArgs*: seq[XLangNode]
```

---

### Function Type

**Scala Construct**: `(Int, String) => Boolean`

**XLang Node**: `xnkFuncType` or `xnkFunctionType`

**XLang has TWO function type nodes**:
1. `xnkFuncType`: with `funcParams`, `funcReturnType`
2. `xnkFunctionType`: with `functionTypeParams`, `functionTypeReturn`

**Current Implementation**: Uses custom `xnkFunctionType` mapping

**Correct Mapping**: Should use `xnkFuncType`

---

### Tuple Type

**Scala Construct**: `(Int, String, Boolean)`

**XLang Node**: `xnkTupleType`

**Required Fields**:
- ✅ `tupleTypeElements`: sequence of element types

**Current Implementation**:
```scala
Type.Tuple(args) =>
  Map(
    "kind" -> "xnkTupleType",
    "elementTypes" -> args.map(convertType).toSeq  // WRONG FIELD
  )
```

**Should be**: `tupleTypeElements` not `elementTypes`

---

## Scala-Specific Features Requiring Lowering

### 1. Pattern Matching (Advanced)

**Scala Feature**: Extractors, guards, nested patterns

**Example**:
```scala
case Point(x, y) if x > 0 => "positive x"
case List(a, b, _*) => "list with at least 2 elements"
case x @ Some(y) => "bind x to whole Some"
```

**XLang Equivalent**: None (simple switch/case only)

**Lowering Strategy**:
1. Convert extractors to type checks + field access
2. Convert guards to nested if statements
3. Convert pattern binds to variable assignments

**Translation Example (C#)**:
```csharp
// Scala: case Point(x, y) if x > 0 => result
// C#:
if (obj is Point p && p.X > 0) {
    var x = p.X;
    var y = p.Y;
    result = ...;
}
```

---

### 2. For Comprehensions

Already covered above. Needs `xnkExternal_ForComprehension` node.

**Desugaring Example**:
```scala
for {
  x <- List(1,2,3)
  y <- List(4,5,6)
  if x < y
} yield x + y

// Becomes:
List(1,2,3).flatMap(x =>
  List(4,5,6).filter(y => x < y).map(y => x + y)
)
```

---

### 3. Implicit Parameters

**Scala Feature**: Automatic parameter passing

**Example**:
```scala
def foo(x: Int)(implicit ctx: ExecutionContext): Future[Int] = ...

// Call without explicit context:
foo(5)  // ctx filled in automatically
```

**XLang Equivalent**: None

**Lowering Strategy**: Convert to explicit parameters with default lookup

**C# Equivalent**: Ambient context or DI

**Nim Equivalent**: Template with compile-time resolution

---

### 4. Type Classes (Implicit Conversions)

**Scala Feature**: Ad-hoc polymorphism via implicits

**Example**:
```scala
implicit def intToString(x: Int): String = x.toString

val s: String = 42  // Automatically converts via implicit
```

**XLang Equivalent**: None

**Lowering Strategy**: Insert explicit conversion calls

---

### 5. Call-by-Name Parameters

**Scala Feature**: Lazy evaluation of parameters

**Example**:
```scala
def foo(x: => Int): Int = {
  x + x  // x evaluated twice
}
```

**XLang Equivalent**: None

**Parameter Representation**: Add `isByName` flag to parameter

**Lowering Strategy**: Wrap in lambda: `() => expr`

**C# Equivalent**: `Func<int>` parameter
**Nim Equivalent**: Untyped parameter or template

---

### 6. Multiple Parameter Lists (Currying)

**Scala Feature**: Functions with multiple parameter groups

**Example**:
```scala
def add(x: Int)(y: Int): Int = x + y

val add5 = add(5) _  // Partial application
```

**Current Implementation**: Stores as nested array

**XLang Representation**: Flatten to single parameter list, or create nested lambdas

**Lowering Strategy**: Convert to curried functions (lambdas returning lambdas)

**Translation**:
```scala
// Scala: def add(x: Int)(y: Int) = x + y
// Nim: proc add(x: int): proc(y: int): int = ...
// C#: Func<int, Func<int, int>> add = x => y => x + y;
```

---

### 7. Case Classes (Product Types)

**Scala Feature**: Auto-generated equals, hashCode, copy, pattern matching

**Example**:
```scala
case class Person(name: String, age: Int)

val p1 = Person("Alice", 30)
val p2 = p1.copy(age = 31)
```

**XLang Representation**: Regular class with `typeIsCase` flag

**Lowering Strategy**: Generate:
- Constructor
- `equals()` method (structural equality)
- `hashCode()` method
- `toString()` method
- `copy()` method (with-expression)
- Extractor for pattern matching

---

### 8. Sealed Traits (Sum Types / ADTs)

**Scala Feature**: Closed type hierarchies for exhaustive pattern matching

**Example**:
```scala
sealed trait Result
case class Success(value: Int) extends Result
case class Failure(error: String) extends Result

def handle(r: Result) = r match {
  case Success(v) => v
  case Failure(e) => 0
  // Compiler ensures all cases covered
}
```

**XLang Representation**: Interface with `typeIsSealed` flag

**Lowering Strategy**: Keep as-is, but track sealed-ness for exhaustiveness checking

**C# Equivalent**: Discriminated union (C# 9+ records with pattern matching)
**Nim Equivalent**: Object variants

---

### 9. Singleton Objects (Companion Objects)

**Scala Feature**: Static members via singleton pattern

**Example**:
```scala
class Foo(x: Int)

object Foo {  // Companion object
  def apply(x: Int): Foo = new Foo(x)
}

// Usage:
val f = Foo(5)  // Calls Foo.apply(5)
```

**XLang Representation**: Separate class with `isSingleton: true`

**Lowering Strategy**: Convert to static class or module

---

### 10. Structural Types (Duck Typing)

**Scala Feature**: Type based on structure, not name

**Example**:
```scala
type HasClose = { def close(): Unit }

def withResource(r: HasClose): Unit = {
  try { use(r) }
  finally { r.close() }
}
```

**XLang Equivalent**: None (requires interface)

**Lowering Strategy**: Convert to interface definition or use dynamic typing

---

## Field Mapping Verification

### Critical Bugs Found

1. **Binary Operators**: Using strings instead of BinaryOp enum
2. **Parameterized Types**: Using `xnkNamedType` with custom `typeArgs` instead of `xnkGenericType`
3. **Function Types**: Using `xnkFunctionType` with wrong field names instead of `xnkFuncType`
4. **Tuple Types**: Using `elementTypes` instead of `tupleTypeElements`
5. **Case Clauses**: Using `casePattern` instead of `caseValues` (must be array)
6. **Multiple Parameter Lists**: Creating nested arrays instead of flattening
7. **Custom Fields**: Adding fields not in XLang spec (`thisType`, `typeParams`, `ctorParams`, etc.)

### Missing XLang Features

1. Constructor declarations (primary constructors converted incorrectly)
2. Type parameter constraints/bounds (stored separately instead of in members)
3. Variance annotations (stored as custom field)
4. Pattern guard representation

---

## Recommendations

### 1. Create External Nodes for Scala-Specific Features

Add to XLang spec:
- `xnkExternal_ForComprehension`: For comprehensions
- `xnkExternal_PatternMatch`: Rich pattern matching with guards
- `xnkExternal_ImplicitParam`: Implicit parameters
- `xnkExternal_CaseClass`: Case class with auto-generated methods
- `xnkExternal_SealedTrait`: Sealed trait for sum types

### 2. Fix Field Mappings

- Use `xnkGenericType` for parameterized types
- Use `xnkFuncType` for function types
- Remove custom fields not in spec
- Use proper field names from XLang definition

### 3. Add Constructor Representation

Convert primary constructor to `xnkConstructorDecl`:
```scala
class Foo(x: Int, y: String)

// Should become:
xnkClassDecl {
  typeNameDecl: "Foo",
  members: [
    xnkConstructorDecl {
      constructorParams: [
        {paramName: "x", paramType: Int},
        {paramName: "y", paramType: String}
      ],
      constructorBody: ... // Auto-generated field assignments
    }
  ]
}
```

### 4. Flatten Multiple Parameter Lists

Convert multiple parameter lists to single list with markers:
```scala
def curry(x: Int)(y: Int) = x + y

// Option 1: Flatten
xnkMethodDecl {
  methodName: "curry",
  mparams: [
    {paramName: "x", paramType: Int},
    {paramName: "y", paramType: Int}
  ]
}

// Option 2: Curry (nested lambda in body)
xnkMethodDecl {
  methodName: "curry",
  mparams: [{paramName: "x", paramType: Int}],
  mbody: xnkLambdaExpr {
    lambdaParams: [{paramName: "y", paramType: Int}],
    lambdaBody: ...
  }
}
```

---

## Summary

The current Scala parser has **structural** correctness but **semantic** mismatches with XLang:

1. **Wrong field names** in many nodes
2. **Custom fields** not in XLang spec
3. **Type representation** using wrong node kinds
4. **Operator enums** vs strings issue

Needs comprehensive refactoring to match XLang type definitions exactly.
