# PHP Parser → XLang Field Mapping

## Overview

The PHP parser converts PHP 8.4 source files to XLang JSON (.xljs) using
nikic/PHP-Parser v5.x.

## Common Mappings (PHP → XLang)

| PHP Construct | XLang Kind | Notes |
|---|---|---|
| namespace | xnkNamespace | |
| use statement | xnkImport | |
| class | xnkClassDecl | |
| interface | xnkExternal_Interface | |
| trait | xnkExternal_PhpTrait | PHP-specific |
| enum (PHP 8.1) | xnkEnumDecl | |
| function | xnkFuncDecl | |
| method | xnkFuncDecl | Visibility in funcVisibility |
| __construct | xnkConstructorDecl | Promoted props in extPromotedProperties |
| __destruct | xnkDestructorDecl | |
| property | xnkFieldDecl | |
| property + hooks (PHP 8.4) | xnkExternal_Property | |
| const | xnkConstDecl | |
| static property | xnkVarDecl / xnkLetDecl | readonly → let |

## Statement Mappings

| PHP Statement | XLang Kind |
|---|---|
| if/elseif/else | xnkIfStmt |
| while | xnkWhileStmt |
| do-while | xnkExternal_DoWhile |
| for | xnkExternal_ForStmt |
| foreach | xnkForeachStmt |
| switch | xnkSwitchStmt |
| match (PHP 8.0) | xnkExternal_SwitchExpr |
| try/catch/finally | xnkTryStmt |
| throw (statement) | xnkRaiseStmt |
| throw (expression, PHP 8.0) | xnkExternal_ThrowExpr |
| return | xnkReturnStmt |
| break | xnkBreakStmt |
| continue | xnkContinueStmt |
| echo | xnkCallExpr (callee: echo) |
| yield | xnkIteratorYield |
| yield from | xnkIteratorDelegate |

## Expression Mappings

| PHP Expression | XLang Kind |
|---|---|
| $variable | xnkIdentifier |
| $this | xnkThisExpr |
| $$var | xnkExternal_PhpVariableVariable |
| assignment (=) | xnkAsgn |
| compound assignment (+=, etc.) | xnkBinaryExpr |
| binary ops (+, -, *, etc.) | xnkBinaryExpr |
| unary ops (!, -, ++, etc.) | xnkUnaryExpr |
| string concatenation (.) | xnkBinaryExpr (op: concat) |
| spaceship (<=>) | xnkBinaryExpr (op: spaceship) |
| null coalescing (??) | xnkExternal_NullCoalesce |
| ternary (?:) | xnkExternal_Ternary |
| elvis (?:) | xnkBinaryExpr (op: elvis) |
| function call | xnkCallExpr |
| method call | xnkCallExpr (callee: xnkMemberAccessExpr) |
| nullsafe method (?->) | xnkCallExpr with xnkExternal_SafeNavigation |
| static call (::) | xnkCallExpr (callee: xnkMemberAccessExpr) |
| property fetch (->) | xnkMemberAccessExpr |
| nullsafe property (?->) | xnkExternal_SafeNavigation |
| array access ([]) | xnkIndexExpr |
| array append ([]) | xnkExternal_PhpArrayAppend |
| new expression | xnkCallExpr (callee: type name) |
| instanceof | xnkTypeAssertion |
| cast expressions | xnkCastExpr |
| closure | xnkLambdaExpr |
| arrow function (fn =>) | xnkArrowFunc |
| string interpolation | xnkExternal_StringInterp |
| array literal | xnkSequenceLiteral |
| associative array | xnkMapLiteral |
| list/destructuring | xnkTupleExpr |
| named argument (PHP 8.0) | xnkArgument |
| spread operator (...) | xnkUnaryExpr (op: spread) |
| clone | xnkCallExpr (callee: clone) |
| @ error suppress | xnkExternal_PhpErrorSuppress |

## Type Mappings

| PHP Type | XLang Kind |
|---|---|
| simple type (int, string, etc.) | xnkNamedType |
| ?Type (nullable) | xnkGenericType (genericTypeName: Nullable) |
| A\|B (union, PHP 8.0) | xnkUnionType |
| A&B (intersection, PHP 8.1) | xnkIntersectionType |
| class name | xnkNamedType |

## PHP-Specific External Kinds

| Kind | Description |
|---|---|
| xnkExternal_PhpTrait | PHP trait declaration |
| xnkExternal_PhpTraitUse | Use trait inside class |
| xnkExternal_PhpDeclare | declare() directive |
| xnkExternal_PhpInlineHtml | Inline HTML sections |
| xnkExternal_PhpHaltCompiler | __halt_compiler() |
| xnkExternal_PhpErrorSuppress | @ error suppression |
| xnkExternal_PhpArrayAppend | $arr[] push syntax |
| xnkExternal_PhpVariableVariable | $$var syntax |
