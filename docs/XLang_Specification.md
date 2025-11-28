
# XLang Specification v1.0.0

## Table of Contents

1. [Introduction](#introduction)
2. [Design Principles](#design-principles)
3. [Version Information](#version-information)
4. [Node Types](#node-types)
5. [Type System](#type-system)
6. [Statements](#statements)
7. [Expressions](#expressions)
8. [Declarations](#declarations)
9. [Literal Values](#literal-values)
10. [Comments and Metadata](#comments-and-metadata)
11. [Extension Mechanisms](#extension-mechanisms)

---

## Introduction

XLang is an intermediate Abstract Syntax Tree (AST) representation designed to bridge multiple programming languages to Nim. It serves as a universal format that can represent constructs from Go, Python, C#, TypeScript, Java, D, Crystal, Haxe, and Nim itself.

### Purpose

- **Universal Intermediate Representation**: Single AST format for multiple source languages
- **Lossless Conversion**: Preserves semantic information during transpilation
- **Extensibility**: Supports language-specific features through extension nodes
- **JSON Serialization**: Easy debugging and tooling integration

### Architecture

```
Source Language → Source Parser → XLang AST (JSON) → XLang to Nim → Nim Code
```

---

## Design Principles

1. **Completeness**: Support all common language constructs
2. **Clarity**: Self-documenting node types and field names
3. **Consistency**: Uniform structure across similar constructs
4. **Extensibility**: Easy to add new node types for language-specific features
5. **Type Safety**: Strong typing with Optional fields for nullable values
6. **Semantic Preservation**: Maintain intent and behavior across transformations

---

## Version Information

### Semantic Versioning

XLang follows semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Breaking changes to core node types
- **MINOR**: New node types or optional fields added
- **PATCH**: Bug fixes and documentation updates

### Current Version

**Version**: 1.0.0  
**Release Date**: 2024  
**Status**: Stable

### Version Field

Every XLang AST should include version information:

```nim
type
  XLangVersion* = tuple[major, minor, patch: int]
  
const XLANG_VERSION*: XLangVersion = (1, 0, 0)
```

---

## Node Types

### XLangNodeKind Enumeration

All XLang nodes have a `kind` field of type `XLangNodeKind`:

```nim
type
  XLangNodeKind* = enum
    # Basic structure
    xnkFile, xnkModule, xnkNamespace

    # Declarations
    xnkFuncDecl, xnkMethodDecl, xnkClassDecl, xnkStructDecl, xnkInterfaceDecl
    xnkEnumDecl, xnkVarDecl, xnkConstDecl, xnkLetDecl, xnkTypeDecl
    xnkPropertyDecl, xnkFieldDecl, xnkConstructorDecl, xnkDestructorDecl
    xnkDelegateDecl

    # Statements
    xnkBlockStmt, xnkIfStmt, xnkSwitchStmt, xnkForStmt, xnkWhileStmt
    xnkDoWhileStmt, xnkForeachStmt, xnkTryStmt, xnkCatchStmt, xnkFinallyStmt
    xnkReturnStmt, xnkYieldStmt, xnkBreakStmt, xnkContinueStmt
    xnkThrowStmt, xnkAssertStmt, xnkWithStmt, xnkPassStmt

    # Expressions
    xnkBinaryExpr, xnkUnaryExpr, xnkTernaryExpr, xnkCallExpr, xnkIndexExpr
    xnkSliceExpr, xnkMemberAccessExpr, xnkLambdaExpr, xnkListExpr, xnkDictExpr
    xnkSetExpr, xnkTupleExpr, xnkComprehensionExpr, xnkAwaitExpr, xnkYieldExpr

    # Literals
    xnkIntLit, xnkFloatLit, xnkStringLit, xnkCharLit, xnkBoolLit, xnkNoneLit

    # Types
    xnkNamedType, xnkArrayType, xnkMapType, xnkFuncType, xnkPointerType
    xnkReferenceType, xnkGenericType, xnkUnionType, xnkIntersectionType

    # Other
    xnkIdentifier, xnkComment, xnkImport, xnkExport, xnkAttribute
    xnkGenericParameter, xnkParameter, xnkArgument, xnkDecorator
```

### Base Node Structure

```nim
type
  XLangNode* = ref object
    case kind*: XLangNodeKind
    # ... variant fields based on kind
```

---

## Declarations

### File (xnkFile)

Represents a complete source file.

**Fields**:
- `fileName: string` - Name of the file
- `moduleDecls: seq[XLangNode]` - Top-level declarations

**Example**:
```json
{
  "kind": "xnkFile",
  "fileName": "main.nim",
  "moduleDecls": [...]
}
```

### Module (xnkModule)

Represents a module or namespace declaration.

**Fields**:
- `moduleName: string` - Module name
- `moduleBody: seq[XLangNode]` - Module contents

**Source Examples**:
- Python: `# implicit module`
- Java: `module com.example { ... }`
- Go: `package main`

### Namespace (xnkNamespace)

Represents a namespace (C#, C++).

**Fields**:
- `namespaceName: string` - Namespace name
- `namespaceBody: seq[XLangNode]` - Namespace contents

### Function Declaration (xnkFuncDecl)

Represents a function or procedure declaration.

**Fields**:
- `funcName: string` - Function name
- `params: seq[XLangNode]` - Parameters (xnkParameter nodes)
- `returnType: Option[XLangNode]` - Return type (optional)
- `body: XLangNode` - Function body
- `isAsync: bool` - Whether function is async/await

**Example**:
```json
{
  "kind": "xnkFuncDecl",
  "funcName": "add",
  "params": [
    {"kind": "xnkParameter", "paramName": "a", "paramType": {...}},
    {"kind": "xnkParameter", "paramName": "b", "paramType": {...}}
  ],
  "returnType": {"kind": "xnkNamedType", "typeName": "int"},
  "body": {...},
  "isAsync": false
}
```

### Method Declaration (xnkMethodDecl)

Represents a class method. Uses same fields as xnkFuncDecl.

### Class Declaration (xnkClassDecl)

Represents a class definition.

**Fields**:
- `typeName: string` - Class name
- `baseTypes: seq[XLangNode]` - Base classes/interfaces
- `members: seq[XLangNode]` - Class members (fields, methods, etc.)

**Example**:
```json
{
  "kind": "xnkClassDecl",
  "typeName": "Person",
  "baseTypes": [],
  "members": [
    {
      "kind": "xnkFieldDecl",
      "fieldName": "name",
      "fieldType": {"kind": "xnkNamedType", "typeName": "string"}
    },
    {
      "kind": "xnkMethodDecl",
      "funcName": "getName",
      "params": [],
      "returnType": {"kind": "xnkNamedType", "typeName": "string"},
      "body": {...}
    }
  ]
}
```

### Struct Declaration (xnkStructDecl)

Represents a struct (Go, C#, Nim). Uses same fields as xnkClassDecl.

### Interface Declaration (xnkInterfaceDecl)

Represents an interface. Uses same fields as xnkClassDecl.

### Enum Declaration (xnkEnumDecl)

Represents an enumeration.

**Fields**:
- `enumName: string` - Enum name
- `enumMembers: seq[tuple[name: string, value: Option[XLangNode]]]` - Enum values

**Example**:
```json
{
  "kind": "xnkEnumDecl",
  "enumName": "Color",
  "enumMembers": [
    {"name": "Red", "value": {"kind": "xnkIntLit", "literalValue": "0"}},
    {"name": "Green", "value": {"kind": "xnkIntLit", "literalValue": "1"}},
    {"name": "Blue", "value": {"kind": "xnkIntLit", "literalValue": "2"}}
  ]
}
```

### Variable Declaration (xnkVarDecl)

Represents a mutable variable declaration.

**Fields**:
- `declName: string` - Variable name
- `declType: Option[XLangNode]` - Type annotation (optional)
- `initializer: Option[XLangNode]` - Initial value (optional)

### Let Declaration (xnkLetDecl)

Represents an immutable variable (Nim let, JavaScript const). Uses same fields as xnkVarDecl.

### Const Declaration (xnkConstDecl)

Represents a compile-time constant. Uses same fields as xnkVarDecl.

### Type Declaration (xnkTypeDecl)

Represents a type alias.

**Fields**:
- `typeDefName: string` - Alias name
- `typeDefBody: XLangNode` - Underlying type

### Property Declaration (xnkPropertyDecl)

Represents a property with getters/setters (C#).

**Fields**:
- `propName: string` - Property name
- `propType: XLangNode` - Property type
- `getter: Option[XLangNode]` - Getter body
- `setter: Option[XLangNode]` - Setter body

### Field Declaration (xnkFieldDecl)

Represents a class/struct field.

**Fields**:
- `fieldName: string` - Field name
- `fieldType: XLangNode` - Field type
- `fieldInitializer: Option[XLangNode]` - Default value

### Constructor Declaration (xnkConstructorDecl)

Represents a constructor.

**Fields**:
- `constructorParams: seq[XLangNode]` - Parameters
- `constructorInitializers: seq[XLangNode]` - Member initializers
- `constructorBody: XLangNode` - Constructor body

### Destructor Declaration (xnkDestructorDecl)

Represents a destructor/finalizer.

**Fields**:
- `destructorBody: XLangNode` - Destructor body

### Delegate Declaration (xnkDelegateDecl)

Represents a delegate/function type declaration (C#).

**Fields**:
- `delegateName: string` - Delegate name
- `delegateParams: seq[XLangNode]` - Parameters
- `delegateReturnType: Option[XLangNode]` - Return type

---

## Statements

### Block Statement (xnkBlockStmt)

Represents a block of statements.

**Fields**:
- `blockBody: seq[XLangNode]` - Statements in the block

### If Statement (xnkIfStmt)

Represents a conditional statement.

**Fields**:
- `ifCondition: XLangNode` - Condition expression
- `ifBody: XLangNode` - Then branch
- `elseBody: Option[XLangNode]` - Else branch (optional)

**Example**:
```json
{
  "kind": "xnkIfStmt",
  "ifCondition": {
    "kind": "xnkBinaryExpr",
    "binaryOp": ">",
    "binaryLeft": {"kind": "xnkIdentifier", "identName": "x"},
    "binaryRight": {"kind": "xnkIntLit", "literalValue": "0"}
  },
  "ifBody": {...},
  "elseBody": {...}
}
```

### Switch Statement (xnkSwitchStmt)

Represents a switch/case statement.

**Fields**:
- `switchExpr: XLangNode` - Expression being switched on
- `switchCases: seq[tuple[caseExpr: XLangNode, caseBody: XLangNode]]` - Cases
- `switchDefault: Option[XLangNode]` - Default case

### For Statement (xnkForStmt)

Represents a C-style for loop.

**Fields**:
- `forInit: Option[XLangNode]` - Initialization
- `forCond: Option[XLangNode]` - Condition
- `forIncrement: Option[XLangNode]` - Increment
- `forBody: XLangNode` - Loop body

### While Statement (xnkWhileStmt)

Represents a while loop.

**Fields**:
- `whileCondition: XLangNode` - Loop condition
- `whileBody: XLangNode` - Loop body

### Do-While Statement (xnkDoWhileStmt)

Represents a do-while loop. Uses same fields as xnkWhileStmt.

### Foreach Statement (xnkForeachStmt)

Represents a foreach/for-in loop.

**Fields**:
- `foreachVar: XLangNode` - Loop variable
- `foreachIter: XLangNode` - Iterable expression
- `foreachBody: XLangNode` - Loop body

### Try Statement (xnkTryStmt)

Represents exception handling.

**Fields**:
- `tryBody: XLangNode` - Try block
- `catchClauses: seq[XLangNode]` - Catch blocks (xnkCatchStmt nodes)
- `finallyClause: Option[XLangNode]` - Finally block (optional)

### Catch Statement (xnkCatchStmt)

Represents a catch clause.

**Fields**:
- `catchType: Option[XLangNode]` - Exception type
- `catchVar: Option[string]` - Exception variable name
- `catchBody: XLangNode` - Catch body

### Finally Statement (xnkFinallyStmt)

Represents a finally clause.

**Fields**:
- `finallyBody: XLangNode` - Finally body

### Return Statement (xnkReturnStmt)

Represents a return statement.

**Fields**:
- `returnExpr: Option[XLangNode]` - Return value (optional)

### Yield Statement (xnkYieldStmt)

Represents a yield statement (generators/iterators).

**Fields**:
- `yieldExpr: XLangNode` - Yielded value

### Break Statement (xnkBreakStmt)

Represents a break statement.

**Fields**:
- `label: Option[string]` - Optional label for labeled break

### Continue Statement (xnkContinueStmt)

Represents a continue statement.

**Fields**:
- `label: Option[string]` - Optional label for labeled continue

### Throw Statement (xnkThrowStmt)

Represents a throw/raise statement.

**Fields**:
- `throwExpr: XLangNode` - Exception to throw

### Assert Statement (xnkAssertStmt)

Represents an assertion.

**Fields**:
- `assertCond: XLangNode` - Condition to assert
- `assertMsg: Option[XLangNode]` - Optional message

### With Statement (xnkWithStmt)

Represents a with/using statement (Python, C#).

**Fields**:
- `withItems: seq[tuple[contextExpr: XLangNode, asExpr: Option[XLangNode]]]` - Context managers
- `withBody: XLangNode` - With body

### Pass Statement (xnkPassStmt)

Represents a no-op statement (Python pass, Nim discard).

**Fields**: None

---

## Expressions

### Binary Expression (xnkBinaryExpr)

Represents a binary operation.

**Fields**:
- `binaryLeft: XLangNode` - Left operand
- `binaryOp: string` - Operator (+, -, *, /, ==, !=, <, >, etc.)
- `binaryRight: XLangNode` - Right operand

### Unary Expression (xnkUnaryExpr)

Represents a unary operation.

**Fields**:
- `unaryOp: string` - Operator (!, -, +, ~, etc.)
- `unaryOperand: XLangNode` - Operand

### Ternary Expression (xnkTernaryExpr)

Represents a conditional expression (a ? b : c).

**Fields**:
- `ternaryCondition: XLangNode` - Condition
- `ternaryThen: XLangNode` - True branch
- `ternaryElse: XLangNode` - False branch

### Call Expression (xnkCallExpr)

Represents a function/method call.

**Fields**:
- `callee: XLangNode` - Function being called
- `args: seq[XLangNode]` - Arguments

### Index Expression (xnkIndexExpr)

Represents array/map indexing.

**Fields**:
- `indexExpr: XLangNode` - Expression being indexed
- `indexArgs: seq[XLangNode]` - Index arguments

### Slice Expression (xnkSliceExpr)

Represents slicing (Python-style).

**Fields**:
- `sliceExpr: XLangNode` - Expression being sliced
- `sliceStart: Option[XLangNode]` - Start index
- `sliceEnd: Option[XLangNode]` - End index
- `sliceStep: Option[XLangNode]` - Step size

### Member Access Expression (xnkMemberAccessExpr)

Represents member access (obj.field).

**Fields**:
- `memberExpr: XLangNode` - Object expression
- `memberName: string` - Member name

### Lambda Expression (xnkLambdaExpr)

Represents an anonymous function.

**Fields**:
- `lambdaParams: seq[XLangNode]` - Parameters
- `lambdaBody: XLangNode` - Body

### List Expression (xnkListExpr)

Represents a list literal.

**Fields**:
- `elements: seq[XLangNode]` - List elements

### Dictionary Expression (xnkDictExpr)

Represents a dictionary/map literal.

**Fields**:
- `keys: seq[XLangNode]` - Dictionary keys
- `values: seq[XLangNode]` - Dictionary values

### Set Expression (xnkSetExpr)

Represents a set literal.

**Fields**:
- `elements: seq[XLangNode]` - Set elements

### Tuple Expression (xnkTupleExpr)

Represents a tuple literal.

**Fields**:
- `elements: seq[XLangNode]` - Tuple elements

### Comprehension Expression (xnkComprehensionExpr)

Represents a list/dict/set comprehension.

**Fields**:
- `compExpr: XLangNode` - Element expression
- `compFor: seq[tuple[vars: seq[XLangNode], iter: XLangNode]]` - For clauses
- `compIf: seq[XLangNode]` - Filter conditions

### Await Expression (xnkAwaitExpr)

Represents an await expression.

**Fields**:
- `awaitExpr: XLangNode` - Expression being awaited

### Yield Expression (xnkYieldExpr)

Represents a yield expression.

**Fields**:
- `yieldExpr: Option[XLangNode]` - Yielded value

---

## Literal Values

### Integer Literal (xnkIntLit)

**Fields**:
- `literalValue: string` - String representation of the integer

### Float Literal (xnkFloatLit)

**Fields**:
- `literalValue: string` - String representation of the float

### String Literal (xnkStringLit)

**Fields**:
- `literalValue: string` - String value

### Character Literal (xnkCharLit)

**Fields**:
- `literalValue: string` - Character value

### Boolean Literal (xnkBoolLit)

**Fields**:
- `boolValue: bool` - Boolean value

### None/Null Literal (xnkNoneLit)

**Fields**: None

---

## Type System

### Named Type (xnkNamedType)

Represents a type by name.

**Fields**:
- `typeName: string` - Type name

### Array Type (xnkArrayType)

Represents an array type.

**Fields**:
- `elementType: XLangNode` - Element type
- `arraySize: Option[XLangNode]` - Size (optional, for fixed-size arrays)

### Map Type (xnkMapType)

Represents a map/dictionary type.

**Fields**:
- `keyType: XLangNode` - Key type
- `valueType: XLangNode` - Value type

### Function Type (xnkFuncType)

Represents a function type.

**Fields**:
- `funcParams: seq[XLangNode]` - Parameter types
- `funcReturnType: Option[XLangNode]` - Return type

### Pointer Type (xnkPointerType)

Represents a pointer type.

**Fields**:
- `referentType: XLangNode` - Type being pointed to

### Reference Type (xnkReferenceType)

Represents a reference type.

**Fields**:
- `referentType: XLangNode` - Type being referenced

### Generic Type (xnkGenericType)

Represents a generic/parameterized type.

**Fields**:
- `genericTypeName: string` - Base type name
- `genericArgs: seq[XLangNode]` - Type arguments

**Example**:
```json
{
  "kind": "xnkGenericType",
  "genericTypeName": "List",
  "genericArgs": [
    {"kind": "xnkNamedType", "typeName": "int"}
  ]
}
```

### Union Type (xnkUnionType)

Represents a union type (TypeScript A | B).

**Fields**:
- `typeMembers: seq[XLangNode]` - Union members

### Intersection Type (xnkIntersectionType)

Represents an intersection type (TypeScript A & B).

**Fields**:
- `typeMembers: seq[XLangNode]` - Intersection members

---

## Comments and Metadata

### Identifier (xnkIdentifier)

Represents an identifier/variable name.

**Fields**:
- `identName: string` - Identifier name

### Comment (xnkComment)

Represents a comment.

**Fields**:
- `commentText: string` - Comment text

### Import (xnkImport)

Represents an import statement.

**Fields**:
- `importPath: string` - Module path
- `importAlias: Option[string]` - Import alias

### Export (xnkExport)

Represents an export declaration.

**Fields**:
- `exportedDecl: XLangNode` - Declaration being exported

### Attribute/Annotation (xnkAttribute)

Represents metadata/annotations.

**Fields**:
- `attrName: string` - Attribute name
- `attrArgs: seq[XLangNode]` - Attribute arguments

### Decorator (xnkDecorator)

Represents a decorator (Python @decorator).

**Fields**:
- `decoratorExpr: XLangNode` - Decorator expression

### Generic Parameter (xnkGenericParameter)

Represents a generic type parameter.

**Fields**:
- `genericParamName: string` - Parameter name
- `genericParamConstraints: seq[XLangNode]` - Constraints

### Parameter (xnkParameter)

Represents a function parameter.

**Fields**:
- `paramName: string` - Parameter name
- `paramType: XLangNode` - Parameter type
- `defaultValue: Option[XLangNode]` - Default value

### Argument (xnkArgument)

Represents a function call argument.

**Fields**:
- `argName: Option[string]` - Named argument name
- `argValue: XLangNode` - Argument value

---

## Extension Mechanisms

### Language-Specific Extensions

XLang can be extended with language-specific node types:

```nim
type
  XLangNodeKind = enum
    # ... core types ...
    
    # Language extensions
    xnkGoChannel       # Go channels
    xnkGoDefer         # Go defer
    xnkPythonWith      # Python with statement
    xnkRustMatch       # Rust pattern matching
    # etc.
```

### Custom Metadata

Use `xnkAttribute` nodes to attach custom metadata:

```json
{
  "kind": "xnkFuncDecl",
  "funcName": "example",
  "attributes": [
    {
      "kind": "xnkAttribute",
      "attrName": "deprecated",
      "attrArgs": [
        {"kind": "xnkStringLit", "literalValue": "Use newExample instead"}
      ]
    }
  ],
  ...
}
```

---

## Best Practices

### 1. Type Safety

Always specify types when available:

```json
{
  "kind": "xnkVarDecl",
  "declName": "count",
  "declType": {"kind": "xnkNamedType", "typeName": "int"},
  "initializer": {"kind": "xnkIntLit", "literalValue": "0"}
}
```

### 2. Preserve Semantics

Maintain source language semantics in XLang:

- Use `xnkLetDecl` for immutable variables
- Use `xnkVarDecl` for mutable variables
- Preserve async/await with `isAsync` flag

### 3. Comments for Lost Information

When information cannot be preserved, use comments:

```json
{
  "kind": "xnkComment",
  "commentText": "Original Java annotation: @Override"
}
```

### 4. Optional Fields

Use `Option[XLangNode]` for optional fields to distinguish between:
- Field not present
- Field explicitly null/none

### 5. Consistent Naming

- Node kinds: `xnk` prefix + PascalCase
- Fields: camelCase
- Types: Match Nim conventions

---

## Examples

### Complete Function Example

```json
{
  "kind": "xnkFuncDecl",
  "funcName": "calculateSum",
  "params": [
    {
      "kind": "xnkParameter",
      "paramName": "numbers",
      "paramType": {
        "kind": "xnkArrayType",
        "elementType": {"kind": "xnkNamedType", "typeName": "int"}
      }
    }
  ],
  "returnType": {"kind": "xnkNamedType", "typeName": "int"},
  "body": {
    "kind": "xnkBlockStmt",
    "blockBody": [
      {
        "kind": "xnkVarDecl",
        "declName": "sum",
        "declType": {"kind": "xnkNamedType", "typeName": "int"},
        "initializer": {"kind": "xnkIntLit", "literalValue": "0"}
      },
      {
        "kind": "xnkForeachStmt",
        "foreachVar": {"kind": "xnkIdentifier", "identName": "num"},
        "foreachIter": {"kind": "xnkIdentifier", "identName": "numbers"},
        "foreachBody": {
          "kind": "xnkBinaryExpr",
          "binaryLeft": {"kind": "xnkIdentifier", "identName": "sum"},
          "binaryOp": "+=",
          "binaryRight": {"kind": "xnkIdentifier", "identName": "num"}
        }
      },
      {
        "kind": "xnkReturnStmt",
        "returnExpr": {"kind": "xnkIdentifier", "identName": "sum"}
      }
    ]
  },
  "isAsync": false
}
```

### Complete Class Example

```json
{
  "kind": "xnkClassDecl",
  "typeName": "Rectangle",
  "baseTypes": [],
  "members": [
    {
      "kind": "xnkFieldDecl",
      "fieldName": "width",
      "fieldType": {"kind": "xnkNamedType", "typeName": "float"}
    },
    {
      "kind": "xnkFieldDecl",
      "fieldName": "height",
      "fieldType": {"kind": "xnkNamedType", "typeName": "float"}
    },
    {
      "kind": "xnkMethodDecl",
      "funcName": "area",
      "params": [],
      "returnType": {"kind": "xnkNamedType", "typeName": "float"},
      "body": {
        "kind": "xnkReturnStmt",
        "returnExpr": {
          "kind": "xnkBinaryExpr",
          "binaryLeft": {
            "kind": "xnkMemberAccessExpr",
            "memberExpr": {"kind": "xnkIdentifier", "identName": "self"},
            "memberName": "width"
          },
          "binaryOp": "*",
          "binaryRight": {
            "kind": "xnkMemberAccessExpr",
            "memberExpr": {"kind": "xnkIdentifier", "identName": "self"},
            "memberName": "height"
          }
        }
      },
      "isAsync": false
    }
  ]
}
```

---

## Appendix: Node Type Summary

| Category | Node Types |
|----------|-----------|
| **Structure** | xnkFile, xnkModule, xnkNamespace |
| **Declarations** | xnkFuncDecl, xnkMethodDecl, xnkClassDecl, xnkStructDecl, xnkInterfaceDecl, xnkEnumDecl, xnkVarDecl, xnkConstDecl, xnkLetDecl, xnkTypeDecl, xnkPropertyDecl, xnkFieldDecl, xnkConstructorDecl, xnkDestructorDecl, xnkDelegateDecl |
| **Statements** | xnkBlockStmt, xnkIfStmt, xnkSwitchStmt, xnkForStmt, xnkWhileStmt, xnkDoWhileStmt, xnkForeachStmt, xnkTryStmt, xnkCatchStmt, xnkFinallyStmt, xnkReturnStmt, xnkYieldStmt, xnkBreakStmt, xnkContinueStmt, xnkThrowStmt, xnkAssertStmt, xnkWithStmt, xnkPassStmt |
| **Expressions** | xnkBinaryExpr, xnkUnaryExpr, xnkTernaryExpr, xnkCallExpr, xnkIndexExpr, xnkSliceExpr, xnkMemberAccessExpr, xnkLambdaExpr, xnkListExpr, xnkDictExpr, xnkSetExpr, xnkTupleExpr, xnkComprehensionExpr, xnkAwaitExpr, xnkYieldExpr |
| **Literals** | xnkIntLit, xnkFloatLit, xnkStringLit, xnkCharLit, xnkBoolLit, xnkNoneLit |
| **Types** | xnkNamedType, xnkArrayType, xnkMapType, xnkFuncType, xnkPointerType, xnkReferenceType, xnkGenericType, xnkUnionType, xnkIntersectionType |
| **Other** | xnkIdentifier, xnkComment, xnkImport, xnkExport, xnkAttribute, xnkGenericParameter, xnkParameter, xnkArgument, xnkDecorator |

**Total Node Types**: 80+

---

## Version History

### v1.0.0 (Current)
- Initial stable release
- Complete coverage of core language constructs
- Support for 9 source languages
- JSON serialization format
- Semantic versioning implementation

---

## License

XLang Specification is released under MIT License.

---

## Contributors

Multi-Language to Nim Transpiler Project Team
