
<!-- 
This complete XLang Textual Representation Specification provides:

1. **Introduction** explaining purpose and relationship to JSON
2. **Design Principles** guiding the syntax
3. **Complete Syntax Overview** with all elements
4. **Lexical Elements** (keywords, literals, operators)
5. **Node Representation** rules and patterns
6. **Complete Syntax Reference** for all major node types:
   - File structure
   - Functions
   - Classes
   - Control flow (if, while, for, foreach, switch)
   - Exception handling
   - Expressions
   - Types
7. **Multiple Complete Examples** showing real-world usage
8. **Comparison with JSON** showing size differences
9. **Parsing Rules** for unambiguous interpretation
10. **Best Practices** for writing clean XLang
11. **EBNF Grammar** for formal specification
12. **Tools and Utilities** available for working with the format

The textual format is approximately 40% more compact than JSON while being much more readable for humans! -->

# XLang Textual Representation Specification

**Version**: 1.0.0  
**Status**: Stable  
**Last Updated**: 2024

---

## Table of Contents

1. [Introduction](#introduction)
2. [Design Principles](#design-principles)
3. [Syntax Overview](#syntax-overview)
4. [Lexical Elements](#lexical-elements)
5. [Node Representation](#node-representation)
6. [Complete Syntax Reference](#complete-syntax-reference)
7. [Examples](#examples)
8. [Comparison with JSON](#comparison-with-json)
9. [Parsing Rules](#parsing-rules)
10. [Best Practices](#best-practices)

---

## Introduction

The XLang Textual Representation is a human-readable, indentation-based syntax for representing XLang AST nodes. It serves as an alternative to the JSON format for:

- **Manual Editing**: Easier to write and modify by hand
- **Testing**: More concise test cases
- **Documentation**: Clearer examples in documentation
- **Debugging**: Easier to read during development

### Relationship to JSON

```
XLang Textual ↔ XLang JSON ↔ XLang AST (Nim types)
     ↑             ↑              ↑
  Human-      Machine-        Runtime
  Readable    Readable      Representation
```

Both formats represent the same underlying AST and are fully interchangeable.

---

## Design Principles

1. **Readability First**: Optimized for human comprehension
2. **Minimal Syntax**: Few special characters, natural structure
3. **Indentation-Based**: Similar to Python, YAML, Nim
4. **Unambiguous**: Clear parsing rules, no ambiguity
5. **Compact**: Less verbose than JSON
6. **Compatible**: 1:1 mapping with JSON format

---

## Syntax Overview

### Basic Structure

```
NodeKind:
  field1: value1
  field2: value2
  nestedNode:
    NestedKind:
      nestedField: nestedValue
```

### Key Features

- **Indentation**: 2 or 4 spaces (consistent within file)
- **Node Declaration**: `NodeKind:` followed by indented fields
- **Field Assignment**: `fieldName: value`
- **Collections**: Use `[]` brackets or indented list
- **Strings**: Quoted with `"` or `'`
- **Comments**: Lines starting with `#`

---

## Lexical Elements

### Keywords

Node kind identifiers (all start with `xnk`):
```
xnkFile, xnkModule, xnkFuncDecl, xnkClassDecl, xnkIfStmt, ...
```

### Literals

```
# Boolean
true
false

# Null/None
null
nil

# Integer
42
-10
0xFF

# Float
3.14
-0.5
1.23e-4

# String
"hello world"
'single quotes'
"escaped \"quotes\""

# Character
'a'
'\n'
```

### Operators

```
:   # Field assignment
[]  # List/array
,   # Separator (optional in many contexts)
#   # Comment
```

### Whitespace

- **Significant**: Indentation defines structure
- **Insignificant**: Spaces/tabs within lines (except indentation)
- **Newlines**: Separate statements/fields

---

## Node Representation

### Simple Node

```
xnkIdentifier:
  identName: "myVariable"
```

**Equivalent JSON**:
```json
{
  "kind": "xnkIdentifier",
  "identName": "myVariable"
}
```

### Node with Multiple Fields

```
xnkVarDecl:
  declName: "count"
  declType:
    xnkNamedType:
      typeName: "int"
  initializer:
    xnkIntLit:
      literalValue: "0"
```

**Equivalent JSON**:
```json
{
  "kind": "xnkVarDecl",
  "declName": "count",
  "declType": {
    "kind": "xnkNamedType",
    "typeName": "int"
  },
  "initializer": {
    "kind": "xnkIntLit",
    "literalValue": "0"
  }
}
```

### Node with Array Fields

#### Inline Array Syntax

```
xnkListExpr:
  elements: [
    xnkIntLit: {literalValue: "1"},
    xnkIntLit: {literalValue: "2"},
    xnkIntLit: {literalValue: "3"}
  ]
```

#### Indented Array Syntax

```
xnkListExpr:
  elements:
    - xnkIntLit:
        literalValue: "1"
    - xnkIntLit:
        literalValue: "2"
    - xnkIntLit:
        literalValue: "3"
```

### Optional Fields

Optional fields can be omitted or explicitly set to `null`:

```
xnkFuncDecl:
  funcName: "doSomething"
  params: []
  returnType: null  # Explicitly no return type
  body:
    xnkBlockStmt:
      blockBody: []
  isAsync: false
```

---

## Complete Syntax Reference

### File Structure

```
xnkFile:
  fileName: "example.nim"
  moduleDecls:
    - xnkImport:
        importPath: "strutils"
        importAlias: null
    - xnkFuncDecl:
        funcName: "main"
        params: []
        returnType: null
        body:
          xnkBlockStmt:
            blockBody:
              - xnkCallExpr:
                  callee:
                    xnkIdentifier:
                      identName: "echo"
                  args:
                    - xnkStringLit:
                        literalValue: "Hello, World!"
        isAsync: false
```

### Function Declaration

```
xnkFuncDecl:
  funcName: "add"
  params:
    - xnkParameter:
        paramName: "a"
        paramType:
          xnkNamedType:
            typeName: "int"
        defaultValue: null
    - xnkParameter:
        paramName: "b"
        paramType:
          xnkNamedType:
            typeName: "int"
        defaultValue: null
  returnType:
    xnkNamedType:
      typeName: "int"
  body:
    xnkBlockStmt:
      blockBody:
        - xnkReturnStmt:
            returnExpr:
              xnkBinaryExpr:
                binaryLeft:
                  xnkIdentifier:
                    identName: "a"
                binaryOp: "+"
                binaryRight:
                  xnkIdentifier:
                    identName: "b"
  isAsync: false
```

### Class Declaration

```
xnkClassDecl:
  typeName: "Person"
  baseTypes: []
  members:
    - xnkFieldDecl:
        fieldName: "name"
        fieldType:
          xnkNamedType:
            typeName: "string"
        fieldInitializer: null
    - xnkFieldDecl:
        fieldName: "age"
        fieldType:
          xnkNamedType:
            typeName: "int"
        fieldInitializer: null
    - xnkMethodDecl:
        funcName: "greet"
        params: []
        returnType:
          xnkNamedType:
            typeName: "string"
        body:
          xnkBlockStmt:
            blockBody:
              - xnkReturnStmt:
                  returnExpr:
                    xnkBinaryExpr:
                      binaryLeft:
                        xnkStringLit:
                          literalValue: "Hello, "
                      binaryOp: "&"
                      binaryRight:
                        xnkMemberAccessExpr:
                          memberExpr:
                            xnkIdentifier:
                              identName: "self"
                          memberName: "name"
        isAsync: false
```

### Control Flow Statements

#### If Statement

```
xnkIfStmt:
  ifCondition:
    xnkBinaryExpr:
      binaryLeft:
        xnkIdentifier:
          identName: "x"
      binaryOp: ">"
      binaryRight:
        xnkIntLit:
          literalValue: "0"
  ifBody:
    xnkBlockStmt:
      blockBody:
        - xnkCallExpr:
            callee:
              xnkIdentifier:
                identName: "echo"
            args:
              - xnkStringLit:
                  literalValue: "Positive"
  elseBody:
    xnkBlockStmt:
      blockBody:
        - xnkCallExpr:
            callee:
              xnkIdentifier:
                identName: "echo"
            args:
              - xnkStringLit:
                  literalValue: "Non-positive"
```

#### While Loop

```
xnkWhileStmt:
  whileCondition:
    xnkBinaryExpr:
      binaryLeft:
        xnkIdentifier:
          identName: "i"
      binaryOp: "<"
      binaryRight:
        xnkIntLit:
          literalValue: "10"
  whileBody:
    xnkBlockStmt:
      blockBody:
        - xnkCallExpr:
            callee:
              xnkIdentifier:
                identName: "echo"
            args:
              - xnkIdentifier:
                  identName: "i"
        - xnkBinaryExpr:
            binaryLeft:
              xnkIdentifier:
                identName: "i"
            binaryOp: "+="
            binaryRight:
              xnkIntLit:
                literalValue: "1"
```

#### For Loop

```
xnkForStmt:
  forInit:
    xnkVarDecl:
      declName: "i"
      declType:
        xnkNamedType:
          typeName: "int"
      initializer:
        xnkIntLit:
          literalValue: "0"
  forCond:
    xnkBinaryExpr:
      binaryLeft:
        xnkIdentifier:
          identName: "i"
      binaryOp: "<"
      binaryRight:
        xnkIntLit:
          literalValue: "10"
  forIncrement:
    xnkBinaryExpr:
      binaryLeft:
        xnkIdentifier:
          identName: "i"
      binaryOp: "+="
      binaryRight:
        xnkIntLit:
          literalValue: "1"
  forBody:
    xnkBlockStmt:
      blockBody:
        - xnkCallExpr:
            callee:
              xnkIdentifier:
                identName: "echo"
            args:
              - xnkIdentifier:
                  identName: "i"
```

#### Foreach Loop

```
xnkForeachStmt:
  foreachVar:
    xnkIdentifier:
      identName: "item"
  foreachIter:
    xnkIdentifier:
      identName: "items"
  foreachBody:
    xnkBlockStmt:
      blockBody:
        - xnkCallExpr:
            callee:
              xnkIdentifier:
                identName: "echo"
            args:
              - xnkIdentifier:
                  identName: "item"
```

#### Switch Statement

```
xnkSwitchStmt:
  switchExpr:
    xnkIdentifier:
      identName: "value"
  switchCases:
    - caseExpr:
        xnkIntLit:
          literalValue: "1"
      caseBody:
        xnkBlockStmt:
          blockBody:
            - xnkCallExpr:
                callee:
                  xnkIdentifier:
                    identName: "echo"
                args:
                  - xnkStringLit:
                      literalValue: "One"
    - caseExpr:
        xnkIntLit:
          literalValue: "2"
      caseBody:
        xnkBlockStmt:
          blockBody:
            - xnkCallExpr:
                callee:
                  xnkIdentifier:
                    identName: "echo"
                args:
                  - xnkStringLit:
                      literalValue: "Two"
  switchDefault:
    xnkBlockStmt:
      blockBody:
        - xnkCallExpr:
            callee:
              xnkIdentifier:
                identName: "echo"
            args:
              - xnkStringLit:
                  literalValue: "Other"
```

### Exception Handling

```
xnkTryStmt:
  tryBody:
    xnkBlockStmt:
      blockBody:
        - xnkCallExpr:
            callee:
              xnkIdentifier:
                identName: "riskyOperation"
            args: []
  catchClauses:
    - xnkCatchStmt:
        catchType:
          xnkNamedType:
            typeName: "IOError"
        catchVar: "e"
        catchBody:
          xnkBlockStmt:
            blockBody:
              - xnkCallExpr:
                  callee:
                    xnkIdentifier:
                      identName: "echo"
                  args:
                    - xnkStringLit:
                        literalValue: "IO Error occurred"
  finallyClause:
    xnkFinallyStmt:
      finallyBody:
        xnkBlockStmt:
          blockBody:
            - xnkCallExpr:
                callee:
                  xnkIdentifier:
                    identName: "cleanup"
                args: []
```

### Expressions

#### Binary Expression

```
xnkBinaryExpr:
  binaryLeft:
    xnkIdentifier:
      identName: "a"
  binaryOp: "+"
  binaryRight:
    xnkIdentifier:
      identName: "b"
```

#### Call Expression

```
xnkCallExpr:
  callee:
    xnkIdentifier:
      identName: "max"
  args:
    - xnkIntLit:
        literalValue: "10"
    - xnkIntLit:
        literalValue: "20"
```

#### Member Access

```
xnkMemberAccessExpr:
  memberExpr:
    xnkIdentifier:
      identName: "obj"
  memberName: "field"
```

#### Lambda Expression

```
xnkLambdaExpr:
  lambdaParams:
    - xnkParameter:
        paramName: "x"
        paramType:
          xnkNamedType:
            typeName: "int"
        defaultValue: null
  lambdaBody:
    xnkBinaryExpr:
      binaryLeft:
        xnkIdentifier:
          identName: "x"
      binaryOp: "*"
      binaryRight:
        xnkIntLit:
          literalValue: "2"
```

### Type Representations

#### Named Type

```
xnkNamedType:
  typeName: "string"
```

#### Array Type

```
xnkArrayType:
  elementType:
    xnkNamedType:
      typeName: "int"
  arraySize: null
```

#### Generic Type

```
xnkGenericType:
  genericTypeName: "List"
  genericArgs:
    - xnkNamedType:
        typeName: "string"
```

#### Function Type

```
xnkFuncType:
  funcParams:
    - xnkParameter:
        paramName: "x"
        paramType:
          xnkNamedType:
            typeName: "int"
        defaultValue: null
  funcReturnType:
    xnkNamedType:
      typeName: "bool"
```

---

## Examples

### Example 1: Simple Function

**Textual**:
```
xnkFuncDecl:
  funcName: "square"
  params:
    - xnkParameter:
        paramName: "n"
        paramType:
          xnkNamedType:
            typeName: "int"
        defaultValue: null
  returnType:
    xnkNamedType:
      typeName: "int"
  body:
    xnkReturnStmt:
      returnExpr:
        xnkBinaryExpr:
          binaryLeft:
            xnkIdentifier:
              identName: "n"
          binaryOp: "*"
          binaryRight:
            xnkIdentifier:
              identName: "n"
  isAsync: false
```

### Example 2: Class with Constructor

**Textual**:
```
xnkClassDecl:
  typeName: "Rectangle"
  baseTypes: []
  members:
    - xnkFieldDecl:
        fieldName: "width"
        fieldType:
          xnkNamedType:
            typeName: "float"
        fieldInitializer: null
    - xnkFieldDecl:
        fieldName: "height"
        fieldType:
          xnkNamedType:
            typeName: "float"
        fieldInitializer: null
    - xnkConstructorDecl:
        constructorParams:
          - xnkParameter:
              paramName: "w"
              paramType:
                xnkNamedType:
                  typeName: "float"
              defaultValue: null
          - xnkParameter:
              paramName: "h"
              paramType:
                xnkNamedType:
                  typeName: "float"
              defaultValue: null
        constructorInitializers:
          - xnkBinaryExpr:
              binaryLeft:
                xnkMemberAccessExpr:
                  memberExpr:
                    xnkIdentifier:
                      identName: "self"
                  memberName: "width"
              binaryOp: "="
              binaryRight:
                xnkIdentifier:
                  identName: "w"
          - xnkBinaryExpr:
              binaryLeft:
                xnkMemberAccessExpr:
                  memberExpr:
                    xnkIdentifier:
                      identName: "self"
                  memberName: "height"
              binaryOp: "="
              binaryRight:
                xnkIdentifier:
                  identName: "h"
        constructorBody:
          xnkBlockStmt:
            blockBody: []
    - xnkMethodDecl:
        funcName: "area"
        params: []
        returnType:
          xnkNamedType:
            typeName: "float"
        body:
          xnkReturnStmt:
            returnExpr:
              xnkBinaryExpr:
                binaryLeft:
                  xnkMemberAccessExpr:
                    memberExpr:
                      xnkIdentifier:
                        identName: "self"
                    memberName: "width"
                binaryOp: "*"
                binaryRight:
                  xnkMemberAccessExpr:
                    memberExpr:
                      xnkIdentifier:
                        identName: "self"
                    memberName: "height"
        isAsync: false
```

### Example 3: Async Function with Await

**Textual**:
```
xnkFuncDecl:
  funcName: "fetchData"
  params:
    - xnkParameter:
        paramName: "url"
        paramType:
          xnkNamedType:
            typeName: "string"
        defaultValue: null
  returnType:
    xnkNamedType:
      typeName: "string"
  body:
    xnkBlockStmt:
      blockBody:
        - xnkVarDecl:
            declName: "response"
            declType:
              xnkNamedType:
                typeName: "string"
            initializer:
              xnkAwaitExpr:
                awaitExpr:
                  xnkCallExpr:
                    callee:
                      xnkIdentifier:
                        identName: "httpGet"
                    args:
                      - xnkIdentifier:
                          identName: "url"
        - xnkReturnStmt:
            returnExpr:
              xnkIdentifier:
                identName: "response"
  isAsync: true
```

### Example 4: Enum Declaration

**Textual**:
```
xnkEnumDecl:
  enumName: "Color"
  enumMembers:
    - name: "Red"
      value:
        xnkIntLit:
          literalValue: "0"
    - name: "Green"
      value:
        xnkIntLit:
          literalValue: "1"
    - name: "Blue"
      value:
        xnkIntLit:
          literalValue: "2"
```

---

## Comparison with JSON

### Textual Format (Compact)

```
xnkFuncDecl:
  funcName: "add"
  params:
    - xnkParameter:
        paramName: "a"
        paramType: {xnkNamedType: {typeName: "int"}}
        defaultValue: null
    - xnkParameter:
        paramName: "b"
        paramType: {xnkNamedType: {typeName: "int"}}
        defaultValue: null
  returnType: {xnkNamedType: {typeName: "int"}}
  body:
    xnkReturnStmt:
      returnExpr:
        xnkBinaryExpr:
          binaryLeft: {xnkIdentifier: {identName: "a"}}
          binaryOp: "+"
          binaryRight: {xnkIdentifier: {identName: "b"}}
  isAsync: false
```

### JSON Format (Verbose)

```json
{
  "kind": "xnkFuncDecl",
  "funcName": "add",
  "params": [
    {
      "kind": "xnkParameter",
      "paramName": "a",
      "paramType": {
        "kind": "xnkNamedType",
        "typeName": "int"
      },
      "defaultValue": null
    },
    {
      "kind": "xnkParameter",
      "paramName": "b",
      "paramType": {
        "kind": "xnkNamedType",
        "typeName": "int"
      },
      "defaultValue": null
    }
  ],
  "returnType": {
    "kind": "xnkNamedType",
    "typeName": "int"
  },
  "body": {
    "kind": "xnkReturnStmt",
    "returnExpr": {
      "kind": "xnkBinaryExpr",
      "binaryLeft": {
        "kind": "xnkIdentifier",
        "identName": "a"
      },
      "binaryOp": "+",
      "binaryRight": {
        "kind": "xnkIdentifier",
        "identName": "b"
      }
    }
  },
  "isAsync": false
}
```

**Size Comparison**: Textual format is ~40% smaller than JSON for typical ASTs.

---

## Parsing Rules

### Indentation

1. **Consistency**: Use either 2 or 4 spaces throughout file
2. **Nesting**: Each level increases indentation by one unit
3. **No Tabs**: Only spaces allowed for indentation
4. **Significant**: Indentation determines structure

### Field Order

Field order within a node doesn't matter:

```
# These are equivalent
xnkVarDecl:
  declName: "x"
  declType: {...}
  initializer: {...}

xnkVarDecl:
  initializer: {...}
  declName: "x"
  declType: {...}
```

### Comments

```
# This is a comment
xnkFuncDecl:
  funcName: "test"  # Inline comment
  # Comment within node
  params: []
```

### String Escaping

```
"normal string"
"escaped \"quotes\""
"newline: \n"
"tab: \t"
"unicode: \u00A9"
```

### Null Values

Three ways to represent null:

```
field: null
field: nil
# field omitted entirely
```

### Array Syntax

Two equivalent forms:

```
# Inline
fields: [{kind: "xnkIdentifier", identName: "x"}]

# Multiline
fields:
  - kind: "xnkIdentifier"
    identName: "x"
```

---

## Best Practices

### 1. Use Compact Syntax for Simple Nodes

**Good**:
```
returnType: {xnkNamedType: {typeName: "int"}}
```

**Verbose** (but also acceptable):
```
returnType:
  xnkNamedType:
    typeName: "int"
```

### 2. Consistent Indentation

**Good**:
```
xnkIfStmt:
  ifCondition:
    xnkBinaryExpr:
      binaryLeft: {...}
      binaryOp: "=="
      binaryRight: {...}
  ifBody:
    xnkBlockStmt:
      blockBody: [...]
```

**Bad** (inconsistent):
```
xnkIfStmt:
  ifCondition:
   xnkBinaryExpr:  # Wrong indentation
```

### 3. Group Related Fields

```
xnkFuncDecl:
  # Function signature
  funcName: "example"
  params: [...]
  returnType: {...}
  
  # Function properties
  isAsync: false
  
  # Function body
  body: {...}
```

### 4. Use Comments for Clarity

```
xnkClassDecl:
  typeName: "Person"
  baseTypes: []
  
  members:
    # Fields
    - xnkFieldDecl: {...}
    - xnkFieldDecl: {...}
    
    # Constructor
    - xnkConstructorDecl: {...}
    
    # Methods
    - xnkMethodDecl: {...}
    - xnkMethodDecl: {...}
```

### 5. Explicit Null for Clarity

When a field's absence is significant:

```
xnkFuncDecl:
  funcName: "procedure"
  returnType: null  # Explicitly no return value
  body: {...}
```

---

## Grammar (EBNF)

```ebnf
xlang_file      = node

node            = node_kind ":" NEWLINE INDENT fields DEDENT

node_kind       = "xnk" IDENTIFIER

fields          = field (NEWLINE field)*

field           = IDENTIFIER ":" value

value           = simple_value
                | node
                | array
                | inline_node

simple_value    = STRING
                | NUMBER
                | BOOLEAN
                | NULL

array           = "[" [value ("," value)*] "]"
                | NEWLINE INDENT array_items DEDENT

array_items     = "-" value (NEWLINE "-" value)*

inline_node     = "{" node_kind ":" "{" inline_fields "}" "}"

inline_fields   = IDENTIFIER ":" simple_value ("," IDENTIFIER ":" simple_value)*

STRING          = '"' (ESC | ~["\\])* '"'
                | "'" (ESC | ~['\\])* "'"

NUMBER          = "-"? DIGIT+ ("." DIGIT+)? ([eE] [+-]? DIGIT+)?

BOOLEAN         = "true" | "false"

NULL            = "null" | "nil"

IDENTIFIER      = [a-zA-Z_] [a-zA-Z0-9_]*

COMMENT         = "#" ~[\n]*

INDENT          = (SPACE SPACE) | (SPACE SPACE SPACE SPACE)

DEDENT          = (decrease in indentation level)

NEWLINE         = "\n" | "\r\n"

SPACE           = " "
```

---

## Tools and Utilities

### Parser Implementation

The `xlang_parser.nim` module provides:

```nim
# Parse from string
let ast = parseXLangString(textualContent)

# Parse from file
let ast = parseXLangFile("example.xlang")

# Convert to JSON
let json = ast.toJson()
```

### Formatter

Format XLang textual representation:

```bash
xlang-format input.xlang > output.xlang
```

### Validator

Validate XLang textual syntax:

```bash
xlang-validate input.xlang
# Output: OK or error messages
```

### Converter

Convert between formats:

```bash
# Textual to JSON
xlang-convert --to-json input.xlang > output.json

# JSON to Textual
xlang-convert --to-text input.json > output.xlang
```

---

## Appendix: Complete Node Examples

### All Declaration Types

```
# Function
xnkFuncDecl: {...}

# Method
xnkMethodDecl: {...}

# Class
xnkClassDecl: {...}

# Struct
xnkStructDecl: {...}

# Interface
xnkInterfaceDecl: {...}

# Enum
xnkEnumDecl: {...}

# Variable
xnkVarDecl: {...}

# Constant
xnkConstDecl: {...}

# Immutable
xnkLetDecl: {...}

# Type Alias
xnkTypeDecl: {...}

# Property
xnkPropertyDecl: {...}

# Field
xnkFieldDecl: {...}

# Constructor
xnkConstructorDecl: {...}

# Destructor
xnkDestructorDecl: {...}

# Delegate
xnkDelegateDecl: {...}
```

### All Statement Types

```
# Block
xnkBlockStmt: {...}

# If
xnkIfStmt: {...}

# Switch
xnkSwitchStmt: {...}

# For
xnkForStmt: {...}

# While
xnkWhileStmt: {...}

# Do-While
xnkDoWhileStmt: {...}

# Foreach
xnkForeachStmt: {...}

# Try
xnkTryStmt: {...}

# Catch
xnkCatchStmt: {...}

# Finally
xnkFinallyStmt: {...}

# Return
xnkReturnStmt: {...}

# Yield
xnkYieldStmt: {...}

# Break
xnkBreakStmt: {...}

# Continue
xnkContinueStmt: {...}

# Throw
xnkThrowStmt: {...}

# Assert
xnkAssertStmt: {...}

# With
xnkWithStmt: {...}

# Pass
xnkPassStmt: {}
```

---

## Conclusion

The XLang Textual Representation provides a human-friendly way to work with XLang ASTs while maintaining full compatibility with the JSON format. Its indentation-based syntax makes it ideal for manual editing, testing, and documentation.

For machine-generated ASTs, the JSON format remains the primary interchange format, but the textual representation serves as an excellent complement for human interaction with the transpiler system.

---

**Specification Version**: 1.0.0  
**Compatible with**: XLang v1.0.0  
**Status**: Stable

