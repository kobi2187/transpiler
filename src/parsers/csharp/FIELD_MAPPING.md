# C# Parser to XLang Field Mapping

This document maps the current C# parser output fields to canonical XLang field names from `xlangtypes.nim`.

## File & Module Structure

| Current | Canonical | Node Kind |
|---------|-----------|-----------|
| `declarations` | `moduleDecls` | xnkFile |
| `name` | `namespaceName` | xnkNamespace |
| `declarations` | `namespaceBody` | xnkNamespace |

## Type Declarations

| Current | Canonical | Node Kind |
|---------|-----------|-----------|
| `className` | `typeNameDecl` | xnkClassDecl |
| `identifier` | `typeNameDecl` | xnkStructDecl, xnkInterfaceDecl |
| `identifier` | `enumName` | xnkEnumDecl |
| `members` | `enumMembers` | xnkEnumDecl |

## Function/Method Declarations

| Current | Canonical | Node Kind |
|---------|-----------|-----------|
| `name` | `funcName` | xnkFuncDecl |
| `parameters` | `params` | xnkFuncDecl |
| `body` | `body` | xnkFuncDecl (OK as-is) |
| `name` | `methodName` | xnkMethodDecl |
| `parameters` | `mparams` | xnkMethodDecl |
| `returnType` | `mreturnType` | xnkMethodDecl |
| `body` | `mbody` | xnkMethodDecl |

## Field & Property Declarations

| Current | Canonical | Node Kind |
|---------|-----------|-----------|
| `name` | `fieldName` | xnkFieldDecl |
| `type` | `fieldType` | xnkFieldDecl |
| `initializer` | `fieldInitializer` | xnkFieldDecl |
| `name` | `propName` | xnkPropertyDecl |
| `type` | `propType` | xnkPropertyDecl |

## Statements

| Current | Canonical | Node Kind |
|---------|-----------|-----------|
| `statements` | `blockBody` | xnkBlockStmt |
| `condition` | `ifCondition` | xnkIfStmt |
| `thenBranch` | `ifBody` | xnkIfStmt |
| `elseBranch` | `elseBody` | xnkIfStmt |
| `condition` | `whileCondition` | xnkWhileStmt |
| `body` | `whileBody` | xnkWhileStmt |
| `expr` | `returnExpr` | xnkReturnStmt |
| `expr` | `raiseExpr` | xnkRaiseStmt |
| `expr` | `switchExpr` | xnkSwitchStmt |
| `sections` | `switchCases` | xnkSwitchStmt |

## Expressions

| Current | Canonical | Node Kind |
|---------|-----------|-----------|
| `name` | `identName` | xnkIdent (xnkIdentifier) |
| `expr` | `callee` | xnkCallExpr |
| `args` | `args` | xnkCallExpr (OK) |
| `obj` | `memberExpr` | xnkDotExpr (should be xnkMemberAccessExpr) |
| `member` | `memberName` | xnkDotExpr (should be xnkMemberAccessExpr) |
| `left` | `binaryLeft` | xnkBinaryExpr |
| `operator` | `binaryOp` | xnkBinaryExpr |
| `right` | `binaryRight` | xnkBinaryExpr |
| `operator` | `unaryOp` | xnkUnaryExpr |
| `operand` | `unaryOperand` | xnkUnaryExpr |
| `condition` | `ternaryCondition` | xnkTernaryExpr (xnkConditionalExpr) |
| `whenTrue` | `ternaryThen` | xnkTernaryExpr |
| `whenFalse` | `ternaryElse` | xnkTernaryExpr |
| `expr` | `indexExpr` | xnkIndexExpr |
| `indices` | `indexArgs` | xnkIndexExpr |

## Variable Declarations

Current structure outputs array of variables, but XLang expects single declaration:
- Current: `{"kind": "xnkVarDecl", "type": "...", "variables": [...]}`
- Canonical: `{"kind": "xnkVarDecl", "declName": "...", "declType": ..., "initializer": ...}`

Need to split multiple variable declarations into separate xnkVarDecl nodes.
