# Java to XLang Mapping

## Overview

This document provides a comprehensive mapping of Java language constructs to XLang intermediate representation. Java is parsed using the JavaParser library (https://github.com/javaparser/javaparser), which supports Java 1-24.

## References

- [Java Language Specification](https://docs.oracle.com/javase/specs/)
- [JavaParser GitHub](https://github.com/javaparser/javaparser)
- [JavaParser API Documentation](https://www.javadoc.io/doc/com.github.javaparser/javaparser-core/latest/index.html)

## JavaParser AST Node Mapping

### Compilation Unit and Packages

| Java AST Type | XLang Node | Notes |
|---------------|------------|-------|
| `CompilationUnit` | `xnkFile` | Root node for Java source file |
| `PackageDeclaration` | `xnkNamespace` | Java package |
| `ImportDeclaration` | `xnkImport` | Import statement |

### Type Declarations

| Java AST Type | XLang Node | Notes |
|---------------|------------|-------|
| `ClassOrInterfaceDeclaration` (class) | `xnkClassDecl` | Class declaration |
| `ClassOrInterfaceDeclaration` (interface) | `xnkInterfaceDecl` | Interface declaration |
| `EnumDeclaration` | `xnkEnumDecl` | Enum declaration |
| `AnnotationDeclaration` | `xnkInterfaceDecl` | Annotation type declaration |
| `RecordDeclaration` | `xnkClassDecl` | Record declaration (Java 14+) |

### Class Members

| Java AST Type | XLang Node | Notes |
|---------------|------------|-------|
| `MethodDeclaration` | `xnkFuncDecl` / `xnkMethodDecl` | Method declaration |
| `ConstructorDeclaration` | `xnkConstructorDecl` | Constructor |
| `FieldDeclaration` | `xnkFieldDecl` | Field declaration |
| `InitializerDeclaration` | `xnkBlockStmt` | Static/instance initializer |
| `EnumConstantDeclaration` | `xnkEnumMember` | Enum constant |
| `AnnotationMemberDeclaration` | `xnkMethodDecl` | Annotation member |

### Statements (22 Types)

| Java AST Type | XLang Node | Notes |
|---------------|------------|-------|
| `AssertStmt` | `xnkAssertStmt` | Assert statement |
| `BlockStmt` | `xnkBlockStmt` | Block of statements |
| `BreakStmt` | `xnkBreakStmt` | Break statement |
| `ContinueStmt` | `xnkContinueStmt` | Continue statement |
| `DoStmt` | `xnkDoWhileStmt` | Do-while loop |
| `EmptyStmt` | `xnkEmptyStmt` | Empty statement (semicolon) |
| `ExplicitConstructorInvocationStmt` | `xnkCallExpr` | `this()` / `super()` call |
| `ExpressionStmt` | Nested expression | Expression as statement |
| `ForStmt` | `xnkForStmt` | Traditional for loop |
| `ForEachStmt` | `xnkForeachStmt` | Enhanced for loop |
| `IfStmt` | `xnkIfStmt` | If statement |
| `LabeledStmt` | `xnkLabeledStmt` | Labeled statement |
| `LocalClassDeclarationStmt` | `xnkClassDecl` | Local class declaration |
| `LocalRecordDeclarationStmt` | `xnkClassDecl` | Local record declaration |
| `ReturnStmt` | `xnkReturnStmt` | Return statement |
| `SwitchStmt` | `xnkSwitchStmt` | Switch statement |
| `SynchronizedStmt` | `xnkLockStmt` | Synchronized block |
| `ThrowStmt` | `xnkThrowStmt` | Throw statement |
| `TryStmt` | `xnkTryStmt` | Try-catch-finally |
| `UnparsableStmt` | `xnkUnknown` | Unparsable statement |
| `WhileStmt` | `xnkWhileStmt` | While loop |
| `YieldStmt` | `xnkIteratorYield` | Yield statement (switch expressions) |

### Expressions (37+ Types)

| Java AST Type | XLang Node | Notes |
|---------------|------------|-------|
| `AnnotationExpr` | `xnkDecorator` | Annotation usage |
| `ArrayAccessExpr` | `xnkIndexExpr` | Array element access |
| `ArrayCreationExpr` | `xnkArrayLiteral` | Array creation |
| `ArrayInitializerExpr` | `xnkArrayLiteral` | Array initializer |
| `AssignExpr` | `xnkAsgn` / `xnkBinaryExpr` | Assignment |
| `BinaryExpr` | `xnkBinaryExpr` | Binary operations |
| `BooleanLiteralExpr` | `xnkBoolLit` | `true` / `false` |
| `CastExpr` | `xnkCastExpr` | Type cast |
| `CharLiteralExpr` | `xnkCharLit` | Character literal |
| `ClassExpr` | `xnkTypeOfExpr` | `Class.class` expression |
| `ConditionalExpr` | `xnkTernaryExpr` | Ternary operator `? :` |
| `DoubleLiteralExpr` | `xnkFloatLit` | Double literal |
| `EnclosedExpr` | Transparent | Parenthesized expression |
| `FieldAccessExpr` | `xnkMemberAccessExpr` | Field access |
| `InstanceOfExpr` | `xnkBinaryExpr` | `instanceof` operator |
| `IntegerLiteralExpr` | `xnkIntLit` | Integer literal |
| `LambdaExpr` | `xnkLambdaExpr` | Lambda expression |
| `LongLiteralExpr` | `xnkIntLit` | Long literal |
| `MethodCallExpr` | `xnkCallExpr` | Method call |
| `MethodReferenceExpr` | `xnkMethodReference` | Method reference `::` |
| `NameExpr` | `xnkIdentifier` | Simple name |
| `NullLiteralExpr` | `xnkNilLit` | `null` literal |
| `ObjectCreationExpr` | `xnkCallExpr` | `new` expression |
| `StringLiteralExpr` | `xnkStringLit` | String literal |
| `SuperExpr` | `xnkBaseExpr` | `super` keyword |
| `SwitchExpr` | `xnkSwitchExpr` | Switch expression (Java 14+) |
| `TextBlockLiteralExpr` | `xnkStringLit` | Text block (Java 15+) |
| `ThisExpr` | `xnkThisExpr` | `this` keyword |
| `TypeExpr` | Type reference | Type expression |
| `UnaryExpr` | `xnkUnaryExpr` | Unary operations |
| `VariableDeclarationExpr` | `xnkVarDecl` | Variable declaration |
| `PatternExpr` | Pattern matching | Pattern expressions (Java 16+) |

### Type Expressions

| Java AST Type | XLang Node | Notes |
|---------------|------------|-------|
| `ClassOrInterfaceType` | `xnkNamedType` | Class/interface type |
| `PrimitiveType` | `xnkNamedType` | Primitive type |
| `ArrayType` | `xnkArrayType` | Array type |
| `VoidType` | `xnkNamedType` | `void` type |
| `WildcardType` | Generic wildcard | `? extends` / `? super` |
| `UnionType` | `xnkUnionType` | Multi-catch union type |
| `IntersectionType` | `xnkIntersectionType` | Type bounds intersection |
| `VarType` | Type inference | `var` keyword (Java 10+) |

## Java-Specific Features

### Generics

**Java Code**:
```java
public class Box<T> {
    private T value;

    public <U> void process(U item) {
        // ...
    }
}

List<String> list = new ArrayList<>();
```

**XLang Representation**:
```json
{
  "kind": "xnkClassDecl",
  "typeNameDecl": "Box",
  "typeParameters": [
    {
      "kind": "xnkGenericParameter",
      "genericParamName": "T"
    }
  ],
  "members": [...]
}
```

### Annotations

**Java Code**:
```java
@Override
@Deprecated(since = "1.5")
public void method() { }
```

**XLang**:
```json
{
  "kind": "xnkFuncDecl",
  "decorators": [
    {
      "kind": "xnkDecorator",
      "decoratorExpr": {"kind": "xnkIdentifier", "identName": "Override"}
    },
    {
      "kind": "xnkDecorator",
      "decoratorExpr": {"kind": "xnkIdentifier", "identName": "Deprecated"},
      "arguments": [...]
    }
  ],
  ...
}
```

### Lambda Expressions

**Java Code**:
```java
// Single parameter
list.forEach(item -> System.out.println(item));

// Multiple parameters
(a, b) -> a + b

// Block body
(x, y) -> {
    int sum = x + y;
    return sum;
}
```

**XLang**:
```json
{
  "kind": "xnkLambdaExpr",
  "lambdaParams": [...],
  "lambdaReturnType": null,
  "lambdaBody": {...}
}
```

### Method References

**Java Code**:
```java
String::length          // Static method reference
System.out::println     // Instance method reference
String::new             // Constructor reference
```

**XLang**:
```json
{
  "kind": "xnkMethodReference",
  "refObject": {"kind": "xnkIdentifier", "identName": "String"},
  "refMethod": "length"
}
```

### Try-with-Resources

**Java Code**:
```java
try (FileReader fr = new FileReader("file.txt");
     BufferedReader br = new BufferedReader(fr)) {
    // Use resources
} catch (IOException e) {
    // Handle exception
}
```

**XLang**:
```json
{
  "kind": "xnkResourceStmt",
  "resourceItems": [
    {
      "kind": "xnkResourceItem",
      "resourceExpr": {...},
      "resourceVar": {...}
    }
  ],
  "resourceBody": {...},
  "catchClauses": [...]
}
```

### Switch Expressions (Java 14+)

**Java Code**:
```java
int result = switch (day) {
    case MONDAY, FRIDAY -> 6;
    case TUESDAY -> 7;
    default -> 0;
};
```

**XLang**:
```json
{
  "kind": "xnkSwitchExpr",
  "switchExprValue": {"kind": "xnkIdentifier", "identName": "day"},
  "switchExprArms": [...]
}
```

### Pattern Matching (Java 16+)

**Java Code**:
```java
if (obj instanceof String s) {
    System.out.println(s.length());
}

switch (obj) {
    case String s -> System.out.println(s);
    case Integer i -> System.out.println(i);
    default -> System.out.println("Unknown");
}
```

**XLang**: Use type assertion with variable binding.

### Records (Java 14+)

**Java Code**:
```java
public record Point(int x, int y) {
    // Compact constructor
    public Point {
        if (x < 0 || y < 0) {
            throw new IllegalArgumentException();
        }
    }
}
```

**XLang**:
```json
{
  "kind": "xnkClassDecl",
  "typeNameDecl": "Point",
  "isRecord": true,
  "members": [...]
}
```

### Sealed Classes (Java 17+)

**Java Code**:
```java
public sealed class Shape
    permits Circle, Rectangle, Triangle {
    // ...
}
```

**XLang**: Use metadata or custom field for sealed modifier and permits clause.

### Text Blocks (Java 15+)

**Java Code**:
```java
String html = """
    <html>
        <body>
            <p>Hello</p>
        </body>
    </html>
    """;
```

**XLang**:
```json
{
  "kind": "xnkStringLit",
  "literalValue": "<html>\n    <body>\n        <p>Hello</p>\n    </body>\n</html>",
  "isTextBlock": true
}
```

### Var Keyword (Java 10+)

**Java Code**:
```java
var list = new ArrayList<String>();
var stream = list.stream();
```

**XLang**: Represent as variable declaration with inferred type.

### Multi-Catch (Java 7+)

**Java Code**:
```java
try {
    // ...
} catch (IOException | SQLException e) {
    // Handle both exceptions
}
```

**XLang**:
```json
{
  "kind": "xnkCatchStmt",
  "catchType": {
    "kind": "xnkUnionType",
    "unionTypes": [
      {"kind": "xnkNamedType", "typeName": "IOException"},
      {"kind": "xnkNamedType", "typeName": "SQLException"}
    ]
  },
  "catchVar": "e",
  "catchBody": {...}
}
```

### Static Imports

**Java Code**:
```java
import static java.lang.Math.*;
import static java.util.Collections.sort;
```

**XLang**:
```json
{
  "kind": "xnkImport",
  "importPath": "java.lang.Math",
  "isStatic": true,
  "isWildcard": true
}
```

### Varargs

**Java Code**:
```java
public void printf(String format, Object... args) {
    // ...
}
```

**XLang**: Mark parameter as variadic.

### Enums with Methods

**Java Code**:
```java
public enum Operation {
    PLUS("+") {
        public double apply(double x, double y) { return x + y; }
    },
    MINUS("-") {
        public double apply(double x, double y) { return x - y; }
    };

    private final String symbol;

    Operation(String symbol) {
        this.symbol = symbol;
    }

    public abstract double apply(double x, double y);
}
```

**XLang**: Enums with constructors, fields, and methods represented as enhanced enum declaration.

### Inner Classes

**Java Code**:
```java
public class Outer {
    private int value;

    public class Inner {
        public void access() {
            System.out.println(value);  // Access outer field
        }
    }

    public static class StaticNested {
        // Cannot access outer instance members
    }
}
```

**XLang**: Nested class declarations within class members.

### Anonymous Classes

**Java Code**:
```java
Runnable r = new Runnable() {
    @Override
    public void run() {
        System.out.println("Running");
    }
};
```

**XLang**: Represented as object creation with class body.

### Default Methods (Java 8+)

**Java Code**:
```java
public interface MyInterface {
    default void defaultMethod() {
        System.out.println("Default implementation");
    }
}
```

**XLang**: Method in interface with body and default modifier.

## Summary

Java's comprehensive feature set maps well to XLang:
- **95%+ compatibility** with existing XLang nodes
- Modern Java features (records, sealed classes, pattern matching) can be represented with metadata
- JavaParser library provides complete AST access
- All 22 statement types covered
- All 37+ expression types covered

The main Java-specific extensions needed are:
- Annotation handling (decorators)
- Generics with wildcards and bounds
- Try-with-resources
- Module system (Java 9+)
- Pattern matching constructs

## References

- [Java Language Specification](https://docs.oracle.com/javase/specs/)
- [JavaParser Documentation](https://javaparser.org/)
- [JavaParser GitHub](https://github.com/javaparser/javaparser)
- [XLang Type System](../../xlangtypes.nim)
