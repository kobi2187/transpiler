# Revised XLang Constructs for Input Languages to Nim Transpilation

This list focuses on constructs from Go, Python, and C# that we need to represent in XLang for transpilation to Nim.

## Basic Types
- Integer
- Float
- Boolean
- String
- Array
- Slice (Go) / List (Python) / List<T> (C#)
- Map (Go) / Dictionary (Python) / Dictionary<K,V> (C#)
- Tuple (Python, C#)
- Set (Python, C#)

## Control Flow
- If-Else Statement
- Switch (Go) / Match (C#) Statement
- For Loop
- While Loop
- For-Each Loop
- Break Statement
- Continue Statement
- Return Statement
- Defer Statement (Go)

## Functions and Methods
- Function Declaration
- Method Declaration
- Lambda / Anonymous Function
- Function Call
- Method Call

## Object-Oriented Programming
- Class Declaration (Python, C#)
- Interface Declaration
- Struct Declaration (Go, C#)
- Object Instantiation
- Inheritance
- Method Overriding
- Constructor

## Error Handling
- Try-Except-Finally Block (Python, C#)
- Exception Raising / Throwing
- Error Returning (Go)

## Modules and Packages
- Import Statement
- Export / Public Declaration
- Package Declaration (Go)
- Namespace (C#)

## Concurrency and Parallelism
- Goroutines (Go)
- Channels (Go)
- Async/Await (Python, C#)
- Task (C#)

## Generics
- Generic Type (Go, C#)
- Generic Function (Go, C#)

## Miscellaneous
- Enum
- Yield Statement (Python, C#)
- Assert Statement

## Operators
- Arithmetic Operators
- Comparison Operators
- Logical Operators
- Bitwise Operators
- Assignment Operators

## Type-Related
- Type Assertion (Go)
- Type Casting
- Type Checking
- Type Inference
- Type Alias

## Memory Management
- Pointer (Go, C#)
- Reference (C#)

## Removed
- Decorators (Python)
- Attributes (C#)
- Reflection
- Eval
- Preprocessing

