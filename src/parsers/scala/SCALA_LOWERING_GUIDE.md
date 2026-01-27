# Scala Feature Lowering Guide

This document describes Scala-specific language features that have no direct equivalent in the common XLang subset and must be lowered through transformation passes.

## Overview

Scala has several unique features that need translation:
1. Pattern matching with extractors and guards
2. For comprehensions
3. Implicit parameters and type classes
4. Multiple parameter lists (currying)
5. Call-by-name parameters
6. Case classes with auto-generated methods
7. Sealed traits (ADTs/sum types)
8. Companion objects

Each feature is described with:
- **Semantic meaning**: What the feature does
- **Example**: Scala code demonstrating the feature
- **Lowering strategy**: How to convert to common constructs
- **Equivalents**: How this appears in C#, Nim, Java

---

## 1. Pattern Matching with Extractors

### Semantic Meaning

Pattern matching in Scala goes beyond simple type checking:
- **Extractors**: Deconstruct values (e.g., `case Point(x, y) =>`)
- **Guards**: Additional conditions (e.g., `case x if x > 0 =>`)
- **Nested patterns**: Match within structures
- **Pattern binds**: Bind to parts and whole (`case x @ Some(y) =>`)

### Example

```scala
sealed trait Shape
case class Circle(radius: Double) extends Shape
case class Rectangle(width: Double, height: Double) extends Shape

def area(s: Shape): Double = s match {
  case Circle(r) if r > 0 =>
    Math.PI * r * r

  case Rectangle(w, h) if w > 0 && h > 0 =>
    w * h

  case r @ Rectangle(_, _) =>
    println(s"Invalid rectangle: $r")
    0.0

  case _ =>
    0.0
}
```

### Lowering Strategy

**Step 1**: Convert to type checks
```scala
// case Circle(r) if r > 0 => expr
```

Becomes:
```scala
if (s.isInstanceOf[Circle]) {
  val temp = s.asInstanceOf[Circle]
  val r = temp.radius
  if (r > 0) {
    expr
  }
}
```

**Step 2**: Chain as if-else
```scala
def area(s: Shape): Double = {
  if (s.isInstanceOf[Circle]) {
    val temp = s.asInstanceOf[Circle]
    val r = temp.radius
    if (r > 0) {
      Math.PI * r * r
    } else {
      // Continue to next case
    }
  } else if (s.isInstanceOf[Rectangle]) {
    // ...
  } else {
    0.0
  }
}
```

### C# Equivalent

C# 9+ pattern matching:
```csharp
public double Area(Shape s) => s switch
{
    Circle { Radius: var r } when r > 0 =>
        Math.PI * r * r,

    Rectangle { Width: var w, Height: var h } when w > 0 && h > 0 =>
        w * h,

    Rectangle r =>
        Console.WriteLine($"Invalid rectangle: {r}");
        0.0,

    _ => 0.0
};
```

### Nim Equivalent

Nim object variants:
```nim
type
  ShapeKind = enum Circle, Rectangle
  Shape = object
    case kind: ShapeKind
    of Circle:
      radius: float
    of Rectangle:
      width, height: float

proc area(s: Shape): float =
  case s.kind
  of Circle:
    if s.radius > 0:
      PI * s.radius * s.radius
    else:
      0.0
  of Rectangle:
    if s.width > 0 and s.height > 0:
      s.width * s.height
    else:
      0.0
```

### Java Equivalent

Java requires visitor pattern or instanceof chains:
```java
public double area(Shape s) {
    if (s instanceof Circle) {
        Circle c = (Circle) s;
        double r = c.getRadius();
        if (r > 0) {
            return Math.PI * r * r;
        }
    } else if (s instanceof Rectangle) {
        Rectangle rect = (Rectangle) s;
        double w = rect.getWidth();
        double h = rect.getHeight();
        if (w > 0 && h > 0) {
            return w * h;
        }
    }
    return 0.0;
}
```

---

## 2. For Comprehensions

### Semantic Meaning

For comprehensions are **syntactic sugar** for chained `map`, `flatMap`, and `filter` operations. They express:
- **Generators**: `x <- collection`
- **Guards**: `if condition`
- **Value bindings**: `y = expression`
- **Yield**: Transform result

Desugaring rules:
- Single generator → `map`
- Multiple generators → `flatMap`
- Guard → `filter`
- Yield → final transformation

### Example

```scala
// For comprehension
for {
  i <- 1 to 10         // Generator
  if i % 2 == 0        // Guard
  j <- 1 to i          // Nested generator
} yield i * j          // Yield expression

// Desugars to:
(1 to 10)
  .filter(i => i % 2 == 0)
  .flatMap(i => (1 to i).map(j => i * j))
```

### Another Example (with value binding)

```scala
for {
  x <- xs
  y = x * 2            // Value binding
  if y > 10
  z <- process(y)
} yield z

// Desugars to:
xs.map(x => (x, x * 2))
  .filter { case (x, y) => y > 10 }
  .flatMap { case (x, y) => process(y).map(z => z) }
```

### Lowering Strategy

**Step 1**: Identify generators, guards, and bindings

**Step 2**: Convert to nested loops with filters

```scala
for {
  i <- list1
  if i > 5
  j <- list2
} yield i + j

// Becomes:
val result = mutable.Buffer[Int]()
for (i <- list1) {
  if (i > 5) {
    for (j <- list2) {
      result += (i + j)
    }
  }
}
result.toSeq
```

### C# Equivalent (LINQ)

```csharp
// Query syntax (most similar)
var result = from i in list1
             where i > 5
             from j in list2
             select i + j;

// Method syntax
var result = list1
    .Where(i => i > 5)
    .SelectMany(i => list2.Select(j => i + j));
```

### Nim Equivalent

Nim's `collect` macro:
```nim
import std/sequtils

let result = collect:
  for i in list1:
    if i > 5:
      for j in list2:
        i + j
```

Or manual loops:
```nim
var result: seq[int] = @[]
for i in list1:
  if i > 5:
    for j in list2:
      result.add(i + j)
```

### Python Equivalent

List comprehension (most similar):
```python
result = [i + j
          for i in list1 if i > 5
          for j in list2]
```

### Java Equivalent

Java streams:
```java
List<Integer> result = list1.stream()
    .filter(i -> i > 5)
    .flatMap(i -> list2.stream().map(j -> i + j))
    .collect(Collectors.toList());
```

---

## 3. Implicit Parameters

### Semantic Meaning

Implicit parameters are **automatically passed** based on type and scope. The compiler searches for matching implicit values and fills them in automatically.

Use cases:
- Context passing (like execution contexts)
- Type classes (evidence patterns)
- Dependency injection

### Example

```scala
// Define an implicit execution context
implicit val ec: ExecutionContext = ExecutionContext.global

// Function with implicit parameter
def fetchData(url: String)(implicit ec: ExecutionContext): Future[String] = {
  Future {
    // Use ec implicitly
    download(url)
  }
}

// Call without explicitly passing ec
val result = fetchData("http://example.com")  // ec filled automatically
```

### Type Class Example

```scala
// Type class
trait Show[A] {
  def show(a: A): String
}

// Instance
implicit val intShow: Show[Int] = new Show[Int] {
  def show(a: Int): String = a.toString
}

// Function using type class
def print[A](a: A)(implicit s: Show[A]): Unit = {
  println(s.show(a))
}

// Usage
print(42)  // intShow passed automatically
```

### Lowering Strategy

**Option 1**: Convert to explicit parameters with default lookup

```scala
// Before:
def foo(x: Int)(implicit ctx: Context): String

// After:
def foo(x: Int, ctx: Context = implicitContext()): String

// Where implicitContext() does the lookup
```

**Option 2**: Thread context through call chain

```scala
// Original:
def a(x: Int)(implicit ctx: Context) = b(x * 2)
def b(y: Int)(implicit ctx: Context) = ctx.process(y)

// Lowered:
def a(x: Int, ctx: Context) = b(x * 2, ctx)
def b(y: Int, ctx: Context) = ctx.process(y)
```

### C# Equivalent

**Ambient Context Pattern**:
```csharp
public class ExecutionContext
{
    private static readonly AsyncLocal<ExecutionContext> _current = new();
    public static ExecutionContext Current => _current.Value ?? Default;
    public static ExecutionContext Default { get; } = new ExecutionContext();

    public static void SetCurrent(ExecutionContext ctx) {
        _current.Value = ctx;
    }
}

public Task<string> FetchData(string url) {
    var ec = ExecutionContext.Current;  // Get from ambient context
    return Task.Run(() => Download(url), ec.CancellationToken);
}
```

**Dependency Injection** (more common):
```csharp
public class DataFetcher
{
    private readonly ExecutionContext _ec;

    public DataFetcher(ExecutionContext ec) {  // Injected
        _ec = ec;
    }

    public Task<string> FetchData(string url) {
        return Task.Run(() => Download(url), _ec.CancellationToken);
    }
}
```

### Nim Equivalent

**Template-based** (compile-time):
```nim
template withContext(ctx: Context, body: untyped) =
  template getContext(): Context = ctx
  body

withContext(myContext):
  # getContext() available in this scope
  doSomething(getContext())
```

**Explicit passing** (runtime):
```nim
proc fetchData(url: string, ec: ExecutionContext): Future[string] =
  # Explicit parameter
```

### Java Equivalent

**ThreadLocal** (for context):
```java
public class ExecutionContext {
    private static final ThreadLocal<ExecutionContext> current = new ThreadLocal<>();

    public static ExecutionContext getCurrent() {
        return current.get();
    }

    public static void setCurrent(ExecutionContext ctx) {
        current.set(ctx);
    }
}

public Future<String> fetchData(String url) {
    ExecutionContext ec = ExecutionContext.getCurrent();
    return CompletableFuture.supplyAsync(() -> download(url), ec.getExecutor());
}
```

---

## 4. Multiple Parameter Lists (Currying)

### Semantic Meaning

Scala allows functions to have **multiple parameter groups**, enabling:
- Partial application
- Type inference across parameter groups
- Creating DSLs
- Simulating higher-order control structures

### Example

```scala
// Multiple parameter lists
def foldLeft[A, B](list: List[A])(init: B)(f: (B, A) => B): B = {
  var acc = init
  for (elem <- list) {
    acc = f(acc, elem)
  }
  acc
}

// Partial application
val sumInts: List[Int] => Int = foldLeft(_: List[Int])(0)(_ + _)

// Usage
sumInts(List(1, 2, 3, 4))  // Returns 10
```

### Custom Control Structure Example

```scala
def times(n: Int)(block: => Unit): Unit = {
  for (_ <- 1 to n) {
    block
  }
}

// Usage looks like built-in control structure
times(3) {
  println("Hello")
}
```

### Lowering Strategy

**Option 1**: Flatten to single parameter list

```scala
// Before:
def add(x: Int)(y: Int): Int = x + y

// After:
def add(x: Int, y: Int): Int = x + y
```

**Option 2**: Convert to curried functions (nested lambdas)

```scala
// Before:
def add(x: Int)(y: Int): Int = x + y

// After (returns function):
def add(x: Int): Int => Int = {
  (y: Int) => x + y
}
```

### C# Equivalent

**Curried functions**:
```csharp
// Explicit currying
public Func<int, int> Add(int x) {
    return y => x + y;
}

// Usage
var add5 = Add(5);
var result = add5(3);  // Returns 8
```

**Extension methods** (for DSL-like syntax):
```csharp
public static void Times(this int n, Action block) {
    for (int i = 0; i < n; i++) {
        block();
    }
}

// Usage
3.Times(() => Console.WriteLine("Hello"));
```

### Nim Equivalent

**Nested procs**:
```nim
proc add(x: int): proc(y: int): int =
  return proc(y: int): int = x + y

# Usage
let add5 = add(5)
echo add5(3)  # 8
```

**Templates** (for DSL):
```nim
template times(n: int, body: untyped) =
  for i in 1..n:
    body

# Usage
times 3:
  echo "Hello"
```

### Java Equivalent

**Curried functions**:
```java
public Function<Integer, Integer> add(int x) {
    return y -> x + y;
}

// Usage
Function<Integer, Integer> add5 = add(5);
int result = add5.apply(3);  // 8
```

---

## 5. Call-by-Name Parameters

### Semantic Meaning

Call-by-name parameters are **evaluated each time they're used**, not once at call site. Useful for:
- Lazy evaluation
- Custom control structures
- Avoiding unnecessary computation

Syntax: `def foo(x: => Int)` (note the `=>`)

### Example

```scala
def twice(x: => Int): Int = {
  println("Computing...")
  x + x  // x evaluated twice
}

var counter = 0
def getNext(): Int = {
  counter += 1
  counter
}

twice(getNext())  // Prints "Computing...", returns 1 + 2 = 3
```

### Control Structure Example

```scala
def myIf[A](cond: => Boolean)(thenBranch: => A)(elseBranch: => A): A = {
  if (cond) thenBranch else elseBranch
}

// Usage
myIf (x > 0) {
  println("Positive")
  x
} {
  println("Non-positive")
  -x
}
```

### Lowering Strategy

Convert to zero-argument function:

```scala
// Before:
def twice(x: => Int): Int = x + x

// After:
def twice(x: () => Int): Int = x() + x()

// Call site:
// Before: twice(expensive())
// After: twice(() => expensive())
```

### C# Equivalent

**Func parameter**:
```csharp
public int Twice(Func<int> x) {
    Console.WriteLine("Computing...");
    return x() + x();
}

// Usage
int counter = 0;
Twice(() => ++counter);  // Returns 3
```

**Lazy<T>** (for caching):
```csharp
public int Once(Lazy<int> x) {
    return x.Value + x.Value;  // Computed only once
}

// Usage
Once(new Lazy<int>(() => expensive()));
```

### Nim Equivalent

**Untyped parameter** (inlined):
```nim
template twice(x: untyped): int =
  echo "Computing..."
  x + x

var counter = 0
proc getNext(): int =
  inc counter
  counter

echo twice(getNext())  # Inlined, evaluated twice
```

**Proc parameter** (explicit):
```nim
proc twice(x: proc(): int): int =
  echo "Computing..."
  x() + x()

echo twice(proc(): int = getNext())
```

### Java Equivalent

**Supplier parameter**:
```java
public int twice(Supplier<Integer> x) {
    System.out.println("Computing...");
    return x.get() + x.get();
}

// Usage
AtomicInteger counter = new AtomicInteger(0);
twice(() -> counter.incrementAndGet());  // Returns 3
```

---

## 6. Case Classes

### Semantic Meaning

Case classes are **data classes** with auto-generated:
- Constructor
- `equals()` (structural equality)
- `hashCode()`
- `toString()`
- `copy()` method (immutable updates)
- Extractor for pattern matching

### Example

```scala
case class Person(name: String, age: Int, email: String)

// Usage
val alice = Person("Alice", 30, "alice@example.com")

// Structural equality (auto-generated equals)
val bob = Person("Alice", 30, "alice@example.com")
println(alice == bob)  // true (content equality)

// Immutable update (auto-generated copy)
val older = alice.copy(age = 31)

// Pattern matching (auto-generated extractor)
alice match {
  case Person(name, age, _) => println(s"$name is $age years old")
}

// toString
println(alice)  // Person(Alice,30,alice@example.com)
```

### Lowering Strategy

Generate methods:

```scala
// Before:
case class Person(name: String, age: Int, email: String)

// After (expanded):
class Person(val name: String, val age: Int, val email: String) {

  // equals
  override def equals(obj: Any): Boolean = obj match {
    case that: Person =>
      this.name == that.name &&
      this.age == that.age &&
      this.email == that.email
    case _ => false
  }

  // hashCode
  override def hashCode(): Int = {
    val state = Seq(name, age, email)
    state.map(_.hashCode()).foldLeft(0)((a, b) => 31 * a + b)
  }

  // toString
  override def toString: String =
    s"Person($name,$age,$email)"

  // copy
  def copy(
    name: String = this.name,
    age: Int = this.age,
    email: String = this.email
  ): Person = new Person(name, age, email)
}

// Companion object with apply/unapply
object Person {
  // apply (constructor)
  def apply(name: String, age: Int, email: String): Person =
    new Person(name, age, email)

  // unapply (extractor)
  def unapply(p: Person): Option[(String, Int, String)] =
    Some((p.name, p.age, p.email))
}
```

### C# Equivalent (C# 9+ Records)

```csharp
// Record (similar to case class)
public record Person(string Name, int Age, string Email);

// Usage
var alice = new Person("Alice", 30, "alice@example.com");
var bob = new Person("Alice", 30, "alice@example.com");

Console.WriteLine(alice == bob);  // True (value equality)

// Immutable update (with expression)
var older = alice with { Age = 31 };

// Deconstruction (pattern matching)
var (name, age, _) = alice;
Console.WriteLine($"{name} is {age} years old");

// ToString auto-generated
Console.WriteLine(alice);  // Person { Name = Alice, Age = 30, Email = alice@example.com }
```

### Nim Equivalent (Object type)

```nim
type Person = object
  name: string
  age: int
  email: string

# Constructor
proc newPerson(name: string, age: int, email: string): Person =
  Person(name: name, age: age, email: email)

# Equality (structural by default for objects)
let alice = newPerson("Alice", 30, "alice@example.com")
let bob = newPerson("Alice", 30, "alice@example.com")
echo alice == bob  # true

# "Copy" (create new with modified fields)
proc copyWith(p: Person, age: int): Person =
  Person(name: p.name, age: age, email: p.email)

let older = alice.copyWith(age = 31)

# Pattern matching (manual)
case alice
of Person(name: "Alice", age: let a, email: _):
  echo "Alice is ", a, " years old"
else:
  discard
```

### Java Equivalent (Java 16+ Records)

```java
// Record
public record Person(String name, int age, String email) {}

// Usage
var alice = new Person("Alice", 30, "alice@example.com");
var bob = new Person("Alice", 30, "alice@example.com");

System.out.println(alice.equals(bob));  // true

// Immutable update (manual)
var older = new Person(alice.name(), 31, alice.email());

// Pattern matching (Java 21+)
if (alice instanceof Person(String name, int age, String email)) {
    System.out.println(name + " is " + age + " years old");
}

// toString
System.out.println(alice);  // Person[name=Alice, age=30, email=alice@example.com]
```

---

## 7. Sealed Traits (Sum Types / ADTs)

### Semantic Meaning

Sealed traits create **closed type hierarchies**:
- All subtypes must be in same file
- Enables exhaustiveness checking in pattern matching
- Represents sum types (one of several alternatives)

### Example

```scala
sealed trait Result[+A]
case class Success[A](value: A) extends Result[A]
case class Failure(error: String) extends Result[Nothing]

def process(r: Result[Int]): Int = r match {
  case Success(value) => value
  case Failure(error) =>
    println(s"Error: $error")
    0
  // Compiler ensures all cases covered - no default needed
}
```

### Tree Example

```scala
sealed trait Tree[+A]
case class Leaf[A](value: A) extends Tree[A]
case class Branch[A](left: Tree[A], right: Tree[A]) extends Tree[A]
case object Empty extends Tree[Nothing]

def size[A](tree: Tree[A]): Int = tree match {
  case Leaf(_) => 1
  case Branch(left, right) => size(left) + size(right)
  case Empty => 0
}
```

### Lowering Strategy

**Option 1**: Keep as sealed hierarchy, track for exhaustiveness

**Option 2**: Convert to tagged union

```scala
// Before:
sealed trait Result[A]
case class Success[A](value: A) extends Result[A]
case class Failure(error: String) extends Result[Nothing]

// After (tagged union):
class Result[A] {
  enum Tag { Success, Failure }
  val tag: Tag
  val successValue: A  // Only valid if tag == Success
  val failureError: String  // Only valid if tag == Failure
}
```

### C# Equivalent (Discriminated Unions)

**C# 9+ with records**:
```csharp
public abstract record Result<A>;
public record Success<A>(A Value) : Result<A>;
public record Failure<A>(string Error) : Result<A>;

public int Process(Result<int> r) => r switch
{
    Success<int>(var value) => value,
    Failure<int>(var error) =>
        Console.WriteLine($"Error: {error}");
        0,
    _ => throw new ArgumentException()  // Exhaustiveness not enforced
};
```

**Manual tagged union**:
```csharp
public class Result<A>
{
    public enum Tag { Success, Failure }
    public Tag Kind { get; }

    private A _value;
    private string _error;

    private Result(Tag kind, A value = default, string error = null) {
        Kind = kind;
        _value = value;
        _error = error;
    }

    public static Result<A> Success(A value) => new(Tag.Success, value);
    public static Result<A> Failure(string error) => new(Tag.Failure, error: error);

    public T Match<T>(Func<A, T> success, Func<string, T> failure) =>
        Kind switch {
            Tag.Success => success(_value),
            Tag.Failure => failure(_error),
            _ => throw new InvalidOperationException()
        };
}
```

### Nim Equivalent (Object Variants)

```nim
type
  ResultKind = enum Success, Failure
  Result[A] = object
    case kind: ResultKind
    of Success:
      value: A
    of Failure:
      error: string

proc process(r: Result[int]): int =
  case r.kind
  of Success:
    r.value
  of Failure:
    echo "Error: ", r.error
    0
  # Compiler enforces exhaustiveness
```

### Java Equivalent

**Sealed classes** (Java 17+):
```java
public sealed interface Result<A>
    permits Success, Failure {}

public record Success<A>(A value) implements Result<A> {}
public record Failure<A>(String error) implements Result<A> {}

public int process(Result<Integer> r) {
    return switch(r) {
        case Success<Integer>(Integer value) -> value;
        case Failure<Integer>(String error) -> {
            System.out.println("Error: " + error);
            yield 0;
        }
    };  // Exhaustiveness checked!
}
```

**Pre-Java 17** (manual):
```java
public abstract class Result<A> {
    private Result() {}  // Prevent external subclassing

    public abstract <T> T match(Function<A, T> success, Function<String, T> failure);

    public static class Success<A> extends Result<A> {
        public final A value;
        public Success(A value) { this.value = value; }

        public <T> T match(Function<A, T> success, Function<String, T> failure) {
            return success.apply(value);
        }
    }

    public static class Failure<A> extends Result<A> {
        public final String error;
        public Failure(String error) { this.error = error; }

        public <T> T match(Function<A, T> success, Function<String, T> failure) {
            return failure.apply(error);
        }
    }
}
```

---

## 8. Companion Objects

### Semantic Meaning

Companion objects provide **static members** for a class:
- Must have same name as class
- Can access private members of class
- Commonly used for factory methods (apply)
- Used for extractors (unapply)

### Example

```scala
class User(val id: Int, val name: String)

object User {
  // Factory method
  def apply(name: String): User = {
    val id = generateId()
    new User(id, name)
  }

  // Alternative constructors
  def fromId(id: Int): Option[User] = {
    database.findUser(id)
  }

  // Static constants
  val Anonymous = new User(0, "Anonymous")

  // Static methods
  def isValid(name: String): Boolean = {
    name.nonEmpty && name.length <= 50
  }
}

// Usage
val user = User("Alice")  // Calls apply
val found = User.fromId(42)
println(User.Anonymous.name)
```

### Lowering Strategy

**Convert to static class**:

```scala
// Before:
object User { ... }

// After (concept):
static class User {
  // All methods become static
}
```

### C# Equivalent

**Static class**:
```csharp
public class User
{
    public int Id { get; }
    public string Name { get; }

    public User(int id, string name) {
        Id = id;
        Name = name;
    }

    // Factory method (convention)
    public static User Create(string name) {
        var id = GenerateId();
        return new User(id, name);
    }

    // Static method
    public static Option<User> FromId(int id) {
        return database.FindUser(id);
    }

    // Static constant
    public static readonly User Anonymous = new User(0, "Anonymous");

    // Static validation
    public static bool IsValid(string name) {
        return !string.IsNullOrEmpty(name) && name.Length <= 50;
    }
}

// Usage
var user = User.Create("Alice");
var found = User.FromId(42);
Console.WriteLine(User.Anonymous.Name);
```

### Nim Equivalent

**Module-level procs**:
```nim
type User = object
  id: int
  name: string

# Factory proc
proc newUser(name: string): User =
  result.id = generateId()
  result.name = name

# Alternative constructor
proc fromId(T: type User, id: int): Option[User] =
  database.findUser(id)

# Constant
const Anonymous* = User(id: 0, name: "Anonymous")

# Validation
proc isValid(T: type User, name: string): bool =
  name.len > 0 and name.len <= 50

# Usage
let user = newUser("Alice")
let found = User.fromId(42)
echo Anonymous.name
```

### Java Equivalent

**Static methods in class**:
```java
public class User {
    private final int id;
    private final String name;

    public User(int id, String name) {
        this.id = id;
        this.name = name;
    }

    // Factory method
    public static User create(String name) {
        int id = generateId();
        return new User(id, name);
    }

    // Static method
    public static Optional<User> fromId(int id) {
        return database.findUser(id);
    }

    // Static constant
    public static final User ANONYMOUS = new User(0, "Anonymous");

    // Static validation
    public static boolean isValid(String name) {
        return name != null && !name.isEmpty() && name.length() <= 50;
    }
}

// Usage
User user = User.create("Alice");
Optional<User> found = User.fromId(42);
System.out.println(User.ANONYMOUS.getName());
```

---

## Summary Table

| Scala Feature | Requires Lowering? | C# Equivalent | Nim Equivalent | Difficulty |
|---------------|-------------------|---------------|----------------|------------|
| Pattern matching with extractors | Yes | Pattern matching (limited) | Object variants | High |
| For comprehensions | Yes | LINQ | collect macro | Medium |
| Implicit parameters | Yes | Ambient context / DI | Templates | High |
| Multiple parameter lists | Yes | Curried functions | Nested procs | Low |
| Call-by-name params | Yes | Func<T> | untyped params | Low |
| Case classes | Yes | Records (C# 9+) | Object type | Medium |
| Sealed traits | Yes | Sealed classes (C# 9+) | Object variants | Medium |
| Companion objects | No | Static class | Module procs | Low |

## Recommended XLang External Nodes

Add these to support Scala-specific features:

```nim
# Scala for comprehension
xnkExternal_ScalaForComp:
  scalaForGenerators*: seq[XLangNode]  # Generator clauses
  scalaForGuards*: seq[XLangNode]      # Filter conditions
  scalaForBindings*: seq[XLangNode]    # Value bindings
  scalaForYield*: XLangNode            # Yield expression

# Pattern with guard
xnkExternal_PatternGuard:
  patternGuardPattern*: XLangNode      # Pattern to match
  patternGuardCondition*: XLangNode    # Guard condition
  patternGuardBody*: XLangNode         # Body if matched

# Implicit parameter
xnkParameter:  # Extend existing
  paramIsImplicit*: bool               # Add flag

# Call-by-name parameter
xnkParameter:  # Extend existing
  paramIsByName*: bool                 # Add flag

# Case class marker
xnkClassDecl:  # Extend existing
  classIsCase*: bool                   # Auto-generate methods
```

---

## Transformation Pass Order

1. **Desugar for comprehensions** → nested loops with filters
2. **Lower pattern matching** → type checks + field access
3. **Thread implicit parameters** → explicit passing
4. **Flatten parameter lists** → single list or curried functions
5. **Expand call-by-name** → thunks (zero-arg functions)
6. **Generate case class methods** → equals, hashCode, copy, toString
7. **Mark sealed traits** → for exhaustiveness tracking
8. **Convert companion objects** → static members

This order ensures dependencies are resolved (e.g., for comprehensions may contain pattern matching).
