# Scala Parser Implementation Audit

This document lists all issues found in the current Scala parser implementation compared to the XLang type specification.

**Date**: 2026-01-18
**XLang Spec**: `src/core/xlangtypes.nim`
**Parser**: `src/parsers/scala/ScalaToXLangParser.scala`

---

## Critical Issues (Must Fix)

### 1. Binary Operators Use Strings Instead of Enum

**Location**: `convertTerm()` - Binary expression handling

**Current Code**:
```scala
Map(
  "kind" -> "xnkBinaryExpr",
  "binaryOp" -> binaryOpMap.getOrElse(op.value, op.value),  // Returns STRING
  // ...
)
```

**XLang Spec**:
```nim
of xnkBinaryExpr:
  binaryLeft*: XLangNode
  binaryOp*: BinaryOp      # ENUM, not string!
  binaryRight*: XLangNode
```

**Problem**: XLang expects `BinaryOp` enum value, parser outputs string. JSON deserialization will fail or require special handling.

**Fix**: Output string representation of enum variant:
```scala
// Map should produce enum variant names
"+" -> "opAdd"
"-" -> "opSub"
// etc.
```

**Impact**: HIGH - Breaks all binary expressions

---

### 2. Unary Operators Use Strings Instead of Enum

**Location**: `convertTerm()` - Unary expression handling

**Current Code**:
```scala
Map(
  "kind" -> "xnkUnaryExpr",
  "unaryOp" -> unaryOpMap.getOrElse(op.value, op.value),  // Returns STRING
  // ...
)
```

**XLang Spec**:
```nim
of xnkUnaryExpr:
  unaryOp*: UnaryOp        # ENUM, not string!
  unaryOperand*: XLangNode
```

**Fix**: Use enum variant names:
```scala
"-" -> "opNegate"
"!" -> "opNot"
// etc.
```

**Impact**: HIGH - Breaks all unary expressions

---

### 3. Parameterized Types Use Wrong Node Kind

**Location**: `convertType()` - Type.Apply handling

**Current Code**:
```scala
case Type.Apply(tpe, args) =>
  Map(
    "kind" -> "xnkNamedType",
    "typeName" -> tpe.syntax,
    "typeArgs" -> args.map(convertType).toSeq  // WRONG FIELD!
  )
```

**XLang Spec**:
```nim
# xnkNamedType has NO typeArgs field!
of xnkNamedType:
  typeName*: string
  isEmptyMarkerType*: Option[bool]

# Should use xnkGenericType instead:
of xnkGenericType:
  genericTypeName*: string
  genericBase*: Option[XLangNode]
  genericArgs*: seq[XLangNode]      # Correct field
```

**Fix**:
```scala
case Type.Apply(tpe, args) =>
  Map(
    "kind" -> "xnkGenericType",
    "genericTypeName" -> tpe.syntax,
    "genericArgs" -> args.map(convertType).toSeq
  )
```

**Impact**: HIGH - Breaks all generic types (List[Int], Map[K,V], etc.)

---

### 4. Function Types Use Wrong Node Kind and Fields

**Location**: `convertType()` - Type.Function handling

**Current Code**:
```scala
case Type.Function(params, res) =>
  Map(
    "kind" -> "xnkFunctionType",       // Wrong kind
    "paramTypes" -> params.map(convertType).toSeq,   // Wrong field
    "returnType" -> convertType(res)   // Wrong field
  )
```

**XLang Spec**:
```nim
# Should use xnkFuncType, not xnkFunctionType:
of xnkFuncType:
  funcParams*: seq[XLangNode]        # NOT paramTypes
  funcReturnType*: Option[XLangNode]  # NOT returnType
```

**Fix**:
```scala
case Type.Function(params, res) =>
  Map(
    "kind" -> "xnkFuncType",
    "funcParams" -> params.map(convertType).toSeq,
    "funcReturnType" -> Some(convertType(res))
  )
```

**Impact**: HIGH - Breaks all function types

---

### 5. Tuple Types Use Wrong Field Name

**Location**: `convertType()` - Type.Tuple handling

**Current Code**:
```scala
case Type.Tuple(args) =>
  Map(
    "kind" -> "xnkTupleType",
    "elementTypes" -> args.map(convertType).toSeq  // WRONG FIELD
  )
```

**XLang Spec**:
```nim
of xnkTupleType:
  tupleTypeElements*: seq[XLangNode]  # NOT elementTypes
```

**Fix**:
```scala
case Type.Tuple(args) =>
  Map(
    "kind" -> "xnkTupleType",
    "tupleTypeElements" -> args.map(convertType).toSeq
  )
```

**Impact**: MEDIUM - Breaks tuple types

---

### 6. Switch Case Clauses Use Wrong Fields

**Location**: `convertCase()` for pattern matching

**Current Code**:
```scala
Map(
  "kind" -> "xnkCaseClause",
  "casePattern" -> convertPattern(cas.pat),  // WRONG FIELD
  "caseGuard" -> cas.cond.map(convertTerm).orNull,  // NOT IN SPEC
  "caseBody" -> convertTerm(cas.body)
)
```

**XLang Spec**:
```nim
of xnkCaseClause:
  caseValues*: seq[XLangNode]        # MUST be array, not single value
  caseBody*: XLangNode
  caseFallthrough*: bool             # Required
```

**Fix**:
```scala
Map(
  "kind" -> "xnkCaseClause",
  "caseValues" -> Seq(convertPattern(cas.pat)),  // Array of values
  "caseBody" -> convertTerm(cas.body),
  "caseFallthrough" -> false  // Scala never falls through
  // Guard must be lowered to nested if or separate node
)
```

**Impact**: HIGH - Breaks all pattern matching

---

### 7. Multiple Parameter Lists Create Nested Arrays

**Location**: `convertMethodDecl()` and `convertDef()`

**Current Code**:
```scala
Map(
  // ...
  "mparams" -> defn.paramss.map(params => params.map(convertParameter).toSeq).toSeq,
  // Creates: [[param1, param2], [param3]]
)
```

**XLang Spec**:
```nim
of xnkMethodDecl:
  mparams*: seq[XLangNode]  # Flat list, NOT nested!
```

**Fix Option 1** (Flatten):
```scala
"mparams" -> defn.paramss.flatten.map(convertParameter).toSeq
// Creates: [param1, param2, param3]
```

**Fix Option 2** (Track separately):
```scala
// Store parameter group boundaries
"mparams" -> defn.paramss.flatten.map(convertParameter).toSeq,
"paramGroups" -> defn.paramss.map(_.length)  // [2, 1]
```

**Impact**: MEDIUM - Loses currying information

---

## Major Issues (Should Fix)

### 8. This/Super Expressions Have Custom Fields

**Location**: `convertTerm()` - Term.This and Term.Super

**Current Code**:
```scala
case Term.This(qual) =>
  Map(
    "kind" -> "xnkThisExpr",
    "thisType" -> qual.syntax  // CUSTOM FIELD NOT IN SPEC
  )
```

**XLang Spec**:
```nim
of xnkThisExpr:
  discard  # NO FIELDS!
```

**Fix**:
```scala
case Term.This(qual) =>
  Map("kind" -> "xnkThisExpr")
  // Drop qual information
```

**Impact**: LOW - Extra field ignored, but violates spec

---

### 9. Class Declarations Have Custom Fields

**Location**: `convertClass()`

**Current Code**:
```scala
Map(
  "kind" -> "xnkClassDecl",
  // ...
  "typeParams" -> cls.tparams.map(convertTypeParam).toSeq,  // NOT IN SPEC
  "ctorParams" -> cls.ctor.paramss.flatten.map(convertParameter).toSeq,  // NOT IN SPEC
  "typeIsCase" -> cls.mods.exists(_.is[Mod.Case]),  // CUSTOM
  "typeIsSealed" -> cls.mods.exists(_.is[Mod.Sealed]),  // CUSTOM
)
```

**XLang Spec**:
```nim
of xnkClassDecl:
  typeNameDecl*: string
  baseTypes*: seq[XLangNode]
  members*: seq[XLangNode]
  typeIsStatic*: bool
  typeIsFinal*: bool
  typeIsAbstract*: bool
  typeIsPrivate*: bool
  typeIsProtected*: bool
  typeIsPublic*: bool
  # NO: typeParams, ctorParams, typeIsCase, typeIsSealed
```

**Fix**:
1. Remove `typeParams`, `ctorParams`, `typeIsCase`, `typeIsSealed`
2. Add type parameters to `members` as `xnkGenericParameter`
3. Add constructor to `members` as `xnkConstructorDecl`

```scala
val members = ArrayBuffer[Map[String, Any]]()

// Add constructor if has parameters
if (cls.ctor.paramss.nonEmpty) {
  members += Map(
    "kind" -> "xnkConstructorDecl",
    "constructorParams" -> cls.ctor.paramss.flatten.map(convertParameter).toSeq,
    "constructorBody" -> createDefaultConstructorBody(),
    // ...
  )
}

// Add other members
members ++= cls.templ.stats.map(_.map(convertMember).toSeq).getOrElse(Seq.empty)

Map(
  "kind" -> "xnkClassDecl",
  "typeNameDecl" -> cls.name.value,
  "members" -> members.toSeq,
  // ...
)
```

**Impact**: MEDIUM - Structural change required

---

### 10. Object Declarations Use Custom Field

**Location**: `convertObject()`

**Current Code**:
```scala
Map(
  "kind" -> "xnkClassDecl",
  "isSingleton" -> true,  // CUSTOM FIELD
  // ...
)
```

**XLang Spec**: No `isSingleton` field

**Fix Options**:
1. **External node**: Create `xnkExternal_ScalaSingleton`
2. **Convention**: Use specific name pattern or marker in metadata
3. **Static class**: Convert to class with `typeIsStatic: true` (not quite right semantically)

**Recommended**: External node for now

**Impact**: MEDIUM - Need lowering pass

---

### 11. Field Declarations Have Custom Field

**Location**: `convertFieldDecl()`

**Current Code**:
```scala
Map(
  "fieldIsMutable" -> true,  // CUSTOM - use fieldIsFinal instead
)
```

**XLang Spec**: Use `fieldIsFinal` (inverse of mutable)

**Fix**:
```scala
// For 'var':
"fieldIsFinal" -> false  // Mutable

// For 'val':
"fieldIsFinal" -> true   // Immutable
```

**Impact**: LOW - Simple fix

---

### 12. Method Declarations Missing Receiver Field

**Location**: `convertMethodDecl()`

**Current Code**:
```scala
Map(
  "kind" -> "xnkMethodDecl",
  // ... missing receiver field
)
```

**XLang Spec**:
```nim
of xnkMethodDecl:
  receiver*: Option[XLangNode]       # For extension methods
```

**Note**: Scala doesn't have extension methods in the same way (uses implicit conversions), but should still include field as None.

**Fix**:
```scala
Map(
  "kind" -> "xnkMethodDecl",
  "receiver" -> None,  // Or extract from implicits
  // ...
)
```

**Impact**: LOW - Completeness issue

---

## Minor Issues (Nice to Fix)

### 13. Type Parameters Stored with Wrong Field Name

**Location**: `convertTypeParam()`

**Current Code**:
```scala
Map(
  "kind" -> "xnkGenericParameter",
  "genericParamName" -> tparam.name.value,
  "genericBounds" -> ...,  // Array of bounds
  "variance" -> ...  // CUSTOM
)
```

**XLang Spec**:
```nim
of xnkGenericParameter:
  genericParamName*: string
  genericParamConstraints*: seq[XLangNode]  # NOT genericBounds
  bounds*: seq[XLangNode]                   # Both exist?!
```

**Confusion**: XLang has BOTH `genericParamConstraints` and `bounds`. Need to understand difference.

**Impact**: LOW - May work but semantically unclear

---

### 14. Call-by-Name and Implicit Parameter Flags

**Location**: `convertParameter()`

**Current Code**:
```scala
Map(
  "isByName" -> ...,  // CUSTOM
  "isImplicit" -> ...  // CUSTOM
)
```

**XLang Spec**:
```nim
of xnkParameter:
  paramName*: string
  paramType*: Option[XLangNode]
  defaultValue*: Option[XLangNode]
  # NO: isByName, isImplicit
```

**Fix**: These are Scala-specific. Either:
1. Drop them (loses information)
2. Add to XLang spec as optional fields
3. Encode in type (e.g., `xnkExternal_ByNameType`)

**Impact**: LOW - Scala-specific features

---

### 15. New Expression Uses Custom Flag

**Location**: `convertTerm()` - Term.New

**Current Code**:
```scala
Map(
  "kind" -> "xnkCallExpr",
  "isNewExpr" -> true,  // CUSTOM
  // ...
)
```

**XLang Spec**:
```nim
of xnkCallExpr:
  callee*: XLangNode
  args*: seq[XLangNode]
  # NO: isNewExpr
```

**Fix**: Encode in callee type or use constructor detection

**Impact**: LOW - Common pattern across parsers

---

### 16. For Comprehensions Need External Node

**Location**: `convertTerm()` - Term.For

**Current Code**:
```scala
Map(
  "kind" -> "xnkExternal_ForComprehension",  // Good!
  "extForEnumerators" -> ...,  // NOT IN SPEC
  "extForBody" -> ...  // NOT IN SPEC
)
```

**XLang Spec**: `xnkExternal_ForComprehension` doesn't exist yet

**Fix**: Add to xlangtypes.nim:
```nim
of xnkExternal_ScalaForComp:
  scalaForEnums*: seq[XLangNode]
  scalaForBody*: XLangNode
```

**Impact**: MEDIUM - Need XLang spec update

---

### 17. By-Name and Repeated Types Need Nodes

**Location**: `convertType()` - Type.ByName and Type.Repeated

**Current Code**:
```scala
case Type.ByName(tpe) =>
  Map(
    "kind" -> "xnkByNameType",  // NOT IN SPEC
    "underlyingType" -> convertType(tpe)
  )

case Type.Repeated(tpe) =>
  Map(
    "kind" -> "xnkRepeatedType",  // NOT IN SPEC
    "elementType" -> convertType(tpe)
  )
```

**XLang Spec**: These nodes don't exist

**Fix Options**:
1. Add to spec as external nodes
2. Represent as wrapper types or metadata
3. Lower immediately during parsing

**Impact**: LOW - Uncommon feature

---

## Enhancements Needed

### 18. Pattern Guard Handling

**Issue**: Pattern guards (`if` conditions in case clauses) have no representation

**Current**: Stored in custom `caseGuard` field

**Solution**: Either:
1. Lower to nested if immediately
2. Create `xnkExternal_PatternGuard` node
3. Embed condition in caseBody as first statement

**Recommendation**: Create external node

---

### 19. Constructor Generation for Case Classes

**Issue**: Case classes need auto-generated methods but parser doesn't create them

**Current**: Just marks with `typeIsCase` flag

**Solution**: Generate in parser or lowering pass:
- Constructor
- equals()
- hashCode()
- toString()
- copy()
- Companion object with apply/unapply

**Recommendation**: Lowering pass (too complex for parser)

---

### 20. Implicit Parameter Threading

**Issue**: Implicit parameters need to be tracked for context passing

**Current**: Marked with `isImplicit` flag

**Solution**: Lowering pass to:
1. Identify implicit parameters
2. Thread through call chain
3. Convert to explicit parameters

---

## Summary Statistics

| Category | Count | Priority |
|----------|-------|----------|
| Critical (breaks deserialization) | 7 | P0 |
| Major (wrong structure) | 5 | P1 |
| Minor (extra/missing fields) | 8 | P2 |
| **Total Issues** | **20** | - |

## Recommended Fix Order

1. **Phase 1 (Critical)** - Fix type mismatches:
   - [ ] Binary/Unary operator enums
   - [ ] Generic types (xnkNamedType → xnkGenericType)
   - [ ] Function types (xnkFunctionType → xnkFuncType)
   - [ ] Tuple type fields
   - [ ] Case clause fields
   - [ ] Flatten parameter lists

2. **Phase 2 (Structural)** - Fix class/object structure:
   - [ ] Move type params to members
   - [ ] Move constructor to members
   - [ ] Remove custom fields from class/trait/object

3. **Phase 3 (Scala-specific)** - Add external nodes:
   - [ ] Add xnkExternal_ScalaForComp to spec
   - [ ] Add xnkExternal_ScalaSingleton to spec
   - [ ] Add xnkExternal_PatternGuard to spec
   - [ ] Handle by-name parameters

4. **Phase 4 (Lowering)** - Create transformation passes:
   - [ ] Desugar for comprehensions
   - [ ] Thread implicit parameters
   - [ ] Generate case class methods
   - [ ] Lower pattern matching

## Test Cases Needed

After fixes, test with:

1. **Generic types**: `List[Int]`, `Map[String, Int]`
2. **Function types**: `(Int, String) => Boolean`
3. **Operators**: `a + b`, `!x`, `list ::: other`
4. **Pattern matching**: With guards, extractors, nested patterns
5. **For comprehensions**: Multiple generators, guards, bindings
6. **Case classes**: With copy, pattern matching
7. **Multiple parameter lists**: Curried functions
8. **Implicit parameters**: Context passing

---

## Conclusion

The current Scala parser has **good coverage** of Scala features but **poor compliance** with XLang type spec. Most issues are **field naming and node type selection** rather than fundamental logic errors.

**Estimated effort**: 2-3 days to fix all issues and verify with test cases.

**Risk**: Medium - Many interconnected changes, need careful testing.
