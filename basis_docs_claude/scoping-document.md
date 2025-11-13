# Scoping in XLang to Nim Transpilation

## 1. Introduction

Scoping rules define how variables are looked up and accessed in different parts of a program. When transpiling from one language to another, it's crucial to understand and correctly translate these rules to maintain the original program's behavior. This document outlines the challenges and proposed solutions for handling scoping when transpiling from Go, Python, and C# to Nim.

### 1.1 Brief overview of scoping in Go, Python, and C#

- Go: Block-scoped with lexical scoping
- Python: Function-scoped with lexical scoping, but with some peculiarities (e.g., class variables)
- C#: Block-scoped with lexical scoping, includes additional concepts like namespaces

### 1.2 Nim's scoping rules

Nim uses block scoping with lexical scoping, similar to Go and C#. Variables declared in an inner block can shadow variables from an outer block.

## 2. Challenges

### 2.1 Differences in scoping rules

The main challenge comes from Python's function scoping vs. the block scoping of Go, C#, and Nim. We need to ensure that variables behave the same way after transpilation.

### 2.2 Variable shadowing

All four languages allow variable shadowing, but the rules and behavior can differ slightly.

### 2.3 Closures and nested functions

Closures and nested functions can capture variables from their enclosing scopes. The behavior needs to be preserved during transpilation.

### 2.4 Global vs. local variables

Python's global and nonlocal keywords don't have direct equivalents in Nim. We need to handle these cases carefully.

## 3. Proposed Solution

### 3.1 Symbol Table Structure

We'll implement a symbol table to keep track of variables, their scopes, and their properties. Each scope will have its own symbol table, and scopes will be nested to reflect the program structure.

### 3.2 Scope Stack

We'll use a stack of scopes to handle nested scopes. When entering a new block or function, we'll push a new scope onto the stack. When exiting, we'll pop the scope off the stack.

### 3.3 Name Resolution Algorithm

To resolve a variable name, we'll start from the current scope and move up the scope stack until we find the variable or reach the global scope.

### 3.4 Handling Language-Specific Scoping Rules

For Python's function scoping, we'll implement special handling to ensure variables behave correctly when transpiled to Nim's block scoping.

## 4. Implementation Details

### 4.1 Symbol Table Data Structure

```nim
type
  SymbolKind = enum
    skVariable, skFunction, skClass, skModule

  Symbol = object
    name: string
    kind: SymbolKind
    isGlobal: bool
    isNonlocal: bool  # For Python's nonlocal variables

  SymbolTable = Table[string, Symbol]

  Scope = ref object
    parent: Scope
    symbols: SymbolTable
```

### 4.2 Scope Entry and Exit

```nim
proc enterScope(currentScope: var Scope) =
  currentScope = Scope(parent: currentScope, symbols: initTable[string, Symbol]())

proc exitScope(currentScope: var Scope) =
  currentScope = currentScope.parent
```

### 4.3 Variable Declaration and Lookup

```nim
proc declareSymbol(scope: Scope, name: string, kind: SymbolKind) =
  scope.symbols[name] = Symbol(name: name, kind: kind)

proc lookupSymbol(scope: Scope, name: string): Option[Symbol] =
  var currentScope = scope
  while currentScope != nil:
    if currentScope.symbols.hasKey(name):
      return some(currentScope.symbols[name])
    currentScope = currentScope.parent
  return none(Symbol)
```

### 4.4 Resolving Naming Conflicts

When a naming conflict is detected (e.g., a variable in an inner scope shadows a variable in an outer scope), we'll rename the inner variable by appending a unique identifier.

## 5. Examples

### 5.1 Python to Nim Scoping Example

Python:
```python
x = 10
def foo():
    x = 20
    def bar():
        global x
        x = 30
    bar()
    print(x)
foo()
print(x)
```

Transpiled Nim:
```nim
var x = 10
proc foo() =
  var x_inner = 20
  proc bar() =
    x = 30  # Accesses the global x
  bar()
  echo x_inner
foo()
echo x
```

### 5.2 Go to Nim Scoping Example

Go:
```go
package main

import "fmt"

func main() {
    x := 10
    {
        x := 20
        fmt.Println(x)
    }
    fmt.Println(x)
}
```

Transpiled Nim:
```nim
proc main() =
  var x = 10
  block:
    var x = 20
    echo x
  echo x

main()
```

### 5.3 C# to Nim Scoping Example

C#:
```csharp
using System;

class Program
{
    static int x = 10;
    static void Main()
    {
        int x = 20;
        {
            int x = 30;
            Console.WriteLine(x);
        }
        Console.WriteLine(x);
    }
}
```

Transpiled Nim:
```nim
var x = 10
proc main() =
  var x_main = 20
  block:
    var x_inner = 30
    echo x_inner
  echo x_main

main()
```

## 6. Limitations and Future Work

- Complex closures and nested functions might require additional handling.
- Some very language-specific scoping behaviors might not be perfectly replicated.
- Future work could include more sophisticated analysis to optimize variable renaming and minimize changes to the original code structure.
