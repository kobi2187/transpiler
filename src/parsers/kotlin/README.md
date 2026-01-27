# Kotlin to XLang Parser

Comprehensive Kotlin source code parser that outputs XLang intermediate representation JSON directly.

## Features

- Uses Kotlin's PSI (Program Structure Interface) via `kotlin-compiler-embeddable`
- Outputs XLang JSON directly (no intermediate conversion needed)
- Supports all Kotlin language features through Kotlin 1.9+
- Statistics output to stderr for coverage verification

## Requirements

- JDK 17+
- Gradle 8.5+

## Building

```bash
./build.sh
```

Or manually:

```bash
gradle wrapper --gradle-version 8.5
./gradlew jar
```

## Usage

```bash
./run.sh <kotlin_file_path>
```

Example:
```bash
./run.sh TestSimple.kt > output.xljs
```

## Supported Constructs

### Declarations

| Kotlin Construct | XLang Kind | Notes |
|-----------------|------------|-------|
| `class` | `xnkClassDecl` | Includes data, sealed, inner classes |
| `interface` | `xnkInterfaceDecl` | |
| `object` | `xnkClassDecl` | With `isObject: true` |
| `companion object` | `xnkClassDecl` | With `isCompanion: true` |
| `enum class` | `xnkEnumDecl` | |
| `fun` | `xnkFuncDecl` | |
| `fun T.ext()` | `xnkExternal_ExtensionMethod` | Extension functions |
| `val`/`var` | `xnkLetDecl`/`xnkVarDecl` | |
| `const val` | `xnkConstDecl` | |
| Property with accessors | `xnkExternal_Property` | Custom getter/setter |
| `typealias` | `xnkTypeAlias` | |
| Primary constructor | `xnkConstructorDecl` | With `isPrimary: true` |
| Secondary constructor | `xnkConstructorDecl` | With `isPrimary: false` |

### Statements

| Kotlin Construct | XLang Kind | Notes |
|-----------------|------------|-------|
| `if`/`else` | `xnkIfStmt` | Also handles if-expression |
| `when` | `xnkSwitchStmt` | With subject expression |
| `when` (no subject) | `xnkExternal_SwitchExpr` | Conditional when |
| `for` | `xnkForeachStmt` | All for-in variants |
| `while` | `xnkWhileStmt` | |
| `do-while` | `xnkExternal_DoWhile` | |
| `try`/`catch`/`finally` | `xnkTryStmt` | |
| `return` | `xnkReturnStmt` | Supports labels |
| `break` | `xnkBreakStmt` | Supports labels |
| `continue` | `xnkContinueStmt` | Supports labels |
| `throw` | `xnkThrowStmt` | |

### Expressions

| Kotlin Construct | XLang Kind | Notes |
|-----------------|------------|-------|
| Binary operators | `xnkBinaryExpr` | Semantic operator mapping |
| Unary operators | `xnkUnaryExpr` | |
| Assignment | `xnkAsgn` | |
| Function call | `xnkCallExpr` | |
| Member access | `xnkMemberAccessExpr` | `.` operator |
| Safe call | `xnkExternal_SafeNavigation` | `?.` operator |
| Elvis | `xnkExternal_NullCoalesce` | `?:` operator |
| Not-null assertion | `xnkUnaryExpr` | `!!` as `notnull` |
| `as` cast | `xnkCastExpr` | |
| `as?` safe cast | `xnkCastExpr` | With `isSafe: true` |
| `is` type check | `xnkBinaryExpr` | With `istype` operator |
| Array access | `xnkIndexExpr` | |
| Lambda | `xnkLambdaExpr` | |
| Object literal | `xnkCallExpr` | Anonymous class |
| `::` reference | `xnkMethodReference` | |
| String template | `xnkExternal_StringInterp` | |
| Range `..` | `xnkBinaryExpr` | With `range` operator |
| `in` operator | `xnkBinaryExpr` | With `in`/`notin` operator |

### Types

| Kotlin Type | XLang Kind | Notes |
|-------------|------------|-------|
| Simple type | `xnkNamedType` | |
| Nullable `T?` | `xnkNamedType` | With `isNullable: true` |
| Generic `T<A>` | `xnkGenericType` | |
| Function type | `xnkFuncType` | Supports suspend |
| Type parameter | `xnkGenericParameter` | Supports in/out variance |
| Star projection | `xnkNamedType` | With `isWildcard: true` |

### Modifiers

The parser captures all Kotlin modifiers:

- Visibility: `public`, `private`, `protected`, `internal`
- Inheritance: `open`, `final`, `abstract`, `override`
- Class types: `data`, `sealed`, `inner`, `value`, `inline`
- Function: `suspend`, `inline`, `infix`, `operator`, `tailrec`, `external`
- Property: `const`, `lateinit`
- Multiplatform: `expect`, `actual`
- Type parameter: `in`, `out`, `reified`

## Operator Mapping

| Kotlin | XLang Semantic Op |
|--------|------------------|
| `+` | `add` |
| `-` | `sub` |
| `*` | `mul` |
| `/` | `div` |
| `%` | `mod` |
| `==` | `eq` |
| `!=` | `neq` |
| `===` | `is` |
| `!==` | `isnot` |
| `<` | `lt` |
| `<=` | `le` |
| `>` | `gt` |
| `>=` | `ge` |
| `&&` | `and` |
| `\|\|` | `or` |
| `and` | `bitand` |
| `or` | `bitor` |
| `xor` | `bitxor` |
| `shl` | `shl` |
| `shr` | `shr` |
| `ushr` | `shru` |
| `..` | `range` |
| `in` | `in` |
| `!in` | `notin` |
| `?:` | (elvis - mapped to xnkExternal_NullCoalesce) |

## Example Output

Input (Kotlin):
```kotlin
fun greet(name: String): String {
    return "Hello, $name!"
}
```

Output (XLang JSON):
```json
{
  "kind": "xnkFile",
  "fileName": "example.kt",
  "sourceLang": "kotlin",
  "moduleDecls": [
    {
      "kind": "xnkFuncDecl",
      "funcName": "greet",
      "params": [
        {
          "kind": "xnkParameter",
          "paramName": "name",
          "paramType": {
            "kind": "xnkNamedType",
            "typeName": "String"
          }
        }
      ],
      "returnType": {
        "kind": "xnkNamedType",
        "typeName": "String"
      },
      "body": {
        "kind": "xnkBlockStmt",
        "blockBody": [
          {
            "kind": "xnkReturnStmt",
            "returnExpr": {
              "kind": "xnkExternal_StringInterp",
              "extInterpParts": [
                { "kind": "xnkStringLit", "literalValue": "Hello, " },
                { "kind": "xnkIdentifier", "identName": "name" },
                { "kind": "xnkStringLit", "literalValue": "!" }
              ],
              "extInterpIsExpr": [false, true, false]
            }
          }
        ]
      }
    }
  ]
}
```

## Testing

Run the test files:

```bash
./run.sh TestSimple.kt 2>/dev/null | head -50
./run.sh TestComprehensive.kt 2>/dev/null > comprehensive.xljs
```

View statistics:
```bash
./run.sh TestComprehensive.kt > /dev/null
```

## Architecture

The parser uses Kotlin's compiler infrastructure:

1. **KotlinCoreEnvironment**: Sets up the compiler environment
2. **KtPsiFactory**: Creates PSI tree from source code
3. **KtFile**: Root of the parsed file
4. **Visitor pattern**: Recursively converts PSI nodes to XLang JSON

All conversion is done in a single pass with direct JSON output using `kotlinx.serialization`.
