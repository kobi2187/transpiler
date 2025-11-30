import strutils

## Language Capabilities
##
## Defines what features each output language supports.
## Used by transformation passes to decide what to lower/transform.

type
  LangCapabilities* = object
    ## Capabilities of a target language
    name*: string

    # Statement capabilities
    hasDefer*: bool              ## Supports defer statements
    hasForLoop*: bool            ## Supports C-style for loops (for init; cond; update)
    hasForeachLoop*: bool        ## Supports foreach/for-in loops
    hasWhileLoop*: bool          ## Supports while loops
    hasDoWhileLoop*: bool        ## Supports do-while loops
    hasSwitchStatement*: bool    ## Supports switch/case statements
    hasTryCatchFinally*: bool    ## Supports try/catch/finally
    hasAsyncAwait*: bool         ## Supports async/await
    hasYield*: bool              ## Supports yield (generators/iterators)

    # Type system capabilities
    hasClasses*: bool            ## Supports classes
    hasStructs*: bool            ## Supports structs/value types
    hasInterfaces*: bool         ## Supports interfaces
    hasTraits*: bool             ## Supports traits/mixins
    hasEnums*: bool              ## Supports enumerations
    hasUnionTypes*: bool         ## Supports union types
    hasGenericTypes*: bool       ## Supports generics/parametric types
    hasTypeAliases*: bool        ## Supports type aliases
    hasDistinctTypes*: bool      ## Supports distinct/newtype

    # Expression capabilities
    hasTernaryOperator*: bool    ## Supports ? : ternary operator
    hasIfExpression*: bool       ## Supports if as expression
    hasLambdas*: bool            ## Supports anonymous functions
    hasClosures*: bool           ## Supports closures
    hasNullableTypes*: bool      ## Supports nullable/option types
    hasOperatorOverload*: bool   ## Supports operator overloading

    # Declaration capabilities
    hasProperties*: bool         ## Supports properties (get/set)
    hasConstructors*: bool       ## Supports explicit constructors
    hasDestructors*: bool        ## Supports explicit destructors
    hasTemplates*: bool          ## Supports templates/metaprogramming
    hasMacros*: bool             ## Supports compile-time macros

    # Memory management
    hasGarbageCollection*: bool  ## Has garbage collection
    hasManualMemory*: bool       ## Supports manual memory management
    hasReferences*: bool         ## Supports reference types
    hasPointers*: bool           ## Supports pointers

    # Other capabilities
    hasExceptions*: bool         ## Supports exceptions
    hasAssertions*: bool         ## Supports assertions
    hasAttributes*: bool         ## Supports attributes/annotations
    hasPragmas*: bool            ## Supports pragmas/compiler directives
    hasFFI*: bool                ## Supports foreign function interface
    hasInlineAsm*: bool          ## Supports inline assembly

proc nimCapabilities*(): LangCapabilities =
  ## Nim language capabilities
  LangCapabilities(
    name: "Nim",

    # Statement capabilities
    hasDefer: true,
    hasForLoop: false,           # Nim doesn't have C-style for - needs lowering to while
    hasForeachLoop: true,        # for x in items
    hasWhileLoop: true,
    hasDoWhileLoop: false,       # Needs lowering to while true + break
    hasSwitchStatement: true,    # case statement
    hasTryCatchFinally: true,
    hasAsyncAwait: true,
    hasYield: true,              # iterators

    # Type system capabilities
    hasClasses: true,            # ref object
    hasStructs: true,            # object
    hasInterfaces: false,        # Nim uses concepts instead
    hasTraits: true,             # via concepts
    hasEnums: true,
    hasUnionTypes: false,        # No direct support - use variant objects
    hasGenericTypes: true,
    hasTypeAliases: true,
    hasDistinctTypes: true,

    # Expression capabilities
    hasTernaryOperator: false,   # Use if expression instead
    hasIfExpression: true,       # if cond: a else: b
    hasLambdas: true,            # proc (x: int): int = x * 2
    hasClosures: true,
    hasNullableTypes: true,      # Option[T] from std/options
    hasOperatorOverload: true,

    # Declaration capabilities
    hasProperties: true,         # via getter/setter procs
    hasConstructors: true,       # procs named `new` or `init`
    hasDestructors: true,        # =destroy hook
    hasTemplates: true,
    hasMacros: true,

    # Memory management
    hasGarbageCollection: true,
    hasManualMemory: true,       # Can use ptr, alloc, dealloc
    hasReferences: true,         # ref types
    hasPointers: true,           # ptr types

    # Other capabilities
    hasExceptions: true,
    hasAssertions: true,
    hasPragmas: true,
    hasAttributes: false,        # Uses pragmas instead
    hasFFI: true,
    hasInlineAsm: true
  )

proc goCapabilities*(): LangCapabilities =
  ## Go language capabilities (for reference/future use)
  LangCapabilities(
    name: "Go",

    # Statement capabilities
    hasDefer: true,
    hasForLoop: true,            # for init; cond; update
    hasForeachLoop: true,        # for x := range items
    hasWhileLoop: false,         # Use for without init/update
    hasDoWhileLoop: false,
    hasSwitchStatement: true,
    hasTryCatchFinally: false,   # No exceptions in Go
    hasAsyncAwait: false,        # Use goroutines
    hasYield: false,             # No generators

    # Type system capabilities
    hasClasses: false,           # Only structs + methods
    hasStructs: true,
    hasInterfaces: true,
    hasTraits: false,
    hasEnums: false,             # Use const + iota
    hasUnionTypes: false,
    hasGenericTypes: true,       # Since Go 1.18
    hasTypeAliases: true,
    hasDistinctTypes: false,

    # Expression capabilities
    hasTernaryOperator: false,   # Use if statement
    hasIfExpression: false,
    hasLambdas: true,            # func(x int) int { return x * 2 }
    hasClosures: true,
    hasNullableTypes: false,     # Use pointers for optional
    hasOperatorOverload: false,

    # Declaration capabilities
    hasProperties: false,        # Use getter/setter methods
    hasConstructors: false,      # Use functions that return structs
    hasDestructors: false,
    hasTemplates: false,
    hasMacros: false,

    # Memory management
    hasGarbageCollection: true,
    hasManualMemory: false,
    hasReferences: false,        # Only pointers
    hasPointers: true,

    # Other capabilities
    hasExceptions: false,        # Use error returns
    hasAssertions: false,        # Use panic
    hasAttributes: false,
    hasPragmas: false,
    hasFFI: true,
    hasInlineAsm: false
  )

proc pythonCapabilities*(): LangCapabilities =
  ## Python language capabilities (for reference/future use)
  LangCapabilities(
    name: "Python",

    # Statement capabilities
    hasDefer: false,             # No defer - needs transformation
    hasForLoop: false,           # No C-style for
    hasForeachLoop: true,        # for x in items
    hasWhileLoop: true,
    hasDoWhileLoop: false,
    hasSwitchStatement: true,    # match/case (Python 3.10+)
    hasTryCatchFinally: true,
    hasAsyncAwait: true,
    hasYield: true,

    # Type system capabilities
    hasClasses: true,
    hasStructs: false,           # Use dataclasses or namedtuples
    hasInterfaces: false,        # Use ABC (abstract base classes)
    hasTraits: false,            # Use multiple inheritance
    hasEnums: true,
    hasUnionTypes: true,         # Type hints: Union[A, B]
    hasGenericTypes: true,       # Type hints
    hasTypeAliases: true,
    hasDistinctTypes: false,

    # Expression capabilities
    hasTernaryOperator: true,    # a if c else b
    hasIfExpression: true,
    hasLambdas: true,            # lambda x: x * 2
    hasClosures: true,
    hasNullableTypes: true,      # Optional[T]
    hasOperatorOverload: true,   # __add__, __mul__, etc.

    # Declaration capabilities
    hasProperties: true,         # @property decorator
    hasConstructors: true,       # __init__
    hasDestructors: true,        # __del__
    hasTemplates: false,
    hasMacros: false,

    # Memory management
    hasGarbageCollection: true,
    hasManualMemory: false,
    hasReferences: true,         # Everything is a reference
    hasPointers: false,

    # Other capabilities
    hasExceptions: true,
    hasAssertions: true,
    hasAttributes: true,         # Decorators
    hasPragmas: false,
    hasFFI: true,                # ctypes, cffi
    hasInlineAsm: false
  )

proc requiresLowering*(caps: LangCapabilities, feature: string): bool =
  ## Check if a feature requires lowering for this language
  case feature
  of "defer":
    return not caps.hasDefer
  of "for-loop":
    return not caps.hasForLoop
  of "do-while":
    return not caps.hasDoWhileLoop
  of "ternary":
    return not caps.hasTernaryOperator
  of "union-type":
    return not caps.hasUnionTypes
  of "interface":
    return not caps.hasInterfaces
  of "properties":
    return not caps.hasProperties
  else:
    return false

proc getCapabilities*(langName: string): LangCapabilities =
  ## Get capabilities for a language by name
  case langName.toLowerAscii()
  of "nim":
    return nimCapabilities()
  of "go":
    return goCapabilities()
  of "python":
    return pythonCapabilities()
  else:
    # Return a minimal capabilities set as default
    return LangCapabilities(name: langName)
