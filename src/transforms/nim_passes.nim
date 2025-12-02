## Nim-Specific Transformation Passes
##
## Registers all transformation passes needed to convert XLang AST
## to Nim-compatible constructs.

import ../../xlangtypes
import pass_manager
import for_to_while
import dowhile_to_while
import ternary_to_if
import interface_to_concept
import property_to_procs
import switch_fallthrough
import null_coalesce
import multiple_catch
import destructuring
import list_comprehension
import normalize_simple
import string_interpolation
import with_to_defer
import async_normalization
import union_to_variant
import linq_to_sequtils
import operator_overload
import pattern_matching
import decorator_attribute
import extension_methods
import go_error_handling
import go_defer
import csharp_using
import go_concurrency
import python_generators
import python_type_hints
import go_panic_recover
import csharp_events
import lambda_normalization
import go_type_assertions
import go_implicit_interfaces
import enum_transformations
import python_multiple_inheritance

proc registerNimPasses*(pm: PassManager) =
  ## Register all transformation passes for Nim target language
  ##
  ## These passes lower/transform XLang constructs that Nim doesn't support
  ## into equivalent Nim constructs.

  # Lowering passes - must run first to convert unsupported constructs

  # 1. C-style for → while
  # Nim doesn't have C-style for loops (for init; cond; update)
  if pm.targetLang.requiresLowering("for-loop"):
    pm.addPass(newTransformPass(
      id: tpForToWhile,
      name: "for-to-while",
      kind: tpkLowering,
      description: "Lower C-style for loops to while loops",
      transform: transformForToWhile,
      dependencies: @[],  # No dependencies
      targetKinds: @[xnkForStmt]
    ))

  # 2. Do-while → while true + break
  # Nim doesn't have do-while loops
  if pm.targetLang.requiresLowering("do-while"):
    pm.addPass(newTransformPass(
      id: tpDoWhileToWhile,
      name: "dowhile-to-while",
      kind: tpkLowering,
      description: "Lower do-while loops to while loops with break",
      transform: transformDoWhileToWhile,
      dependencies: @[],  # No dependencies
      targetKinds: @[xnkDoWhileStmt]
    ))

  # 3. Ternary → if expression
  # Nim doesn't have ternary operator (? :)
  if pm.targetLang.requiresLowering("ternary"):
    pm.addPass(newTransformPass(
      id: tpTernaryToIf,
      name: "ternary-to-if",
      kind: tpkLowering,
      description: "Transform ternary operators to if expressions",
      transform: transformTernaryToIf,
      dependencies: @[],  # No dependencies
      targetKinds: @[xnkTernaryExpr]
    ))

  # 4. Interface → concept
  # Nim doesn't have interfaces, uses concepts instead
  if pm.targetLang.requiresLowering("interface"):
    pm.addPass(newTransformPass(
      id: tpInterfaceToConcept,
      name: "interface-to-concept",
      kind: tpkLowering,
      description: "Transform interface declarations to concepts",
      transform: transformInterfaceToConcept,
      dependencies: @[],  # No dependencies
      targetKinds: @[xnkInterfaceDecl]
    ))

  # 5. Property → getter/setter procs
  # Nim doesn't have property syntax like C#/Python
  # Uses proc Name() and proc `Name=`() instead
  if pm.targetLang.requiresLowering("properties"):
    pm.addPass(newTransformPass(
      id: tpPropertyToProcs,
      name: "property-to-procs",
      kind: tpkLowering,
      description: "Transform properties to getter/setter procedures",
      transform: transformPropertyToProcs,
      dependencies: @[],  # No dependencies
      targetKinds: @[xnkPropertyDecl]
    ))

  # 6. Switch with fallthrough → if-elif chain
  # Nim's case doesn't support fallthrough (like Go has)
  pm.addPass(newTransformPass(
    id: tpSwitchFallthrough,
    name: "switch-fallthrough",
    kind: tpkLowering,
    description: "Transform switch with fallthrough to if-elif chain",
    transform: transformSwitchFallthrough,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkSwitchStmt, xnkCaseClause]
  ))

  # 7. Null coalescing and safe navigation
  # Nim doesn't have ?? and ?. operators (C# has these)
  pm.addPass(newTransformPass(
    id: tpNullCoalesce,
    name: "null-coalesce",
    kind: tpkLowering,
    description: "Transform null coalescing (??) and safe navigation (?.) operators",
    transform: transformNullCoalesce,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkNullCoalesceExpr, xnkSafeNavigationExpr]
  ))

  # 8. Multiple catch blocks → single catch with type checking
  # Nim only supports single catch block (Java has multiple)
  pm.addPass(newTransformPass(
    id: tpMultipleCatch,
    name: "multiple-catch",
    kind: tpkLowering,
    description: "Transform multiple catch blocks to single catch with type checking",
    transform: transformMultipleCatch,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkTryStmt]
  ))

  # 9. Destructuring assignment (JS/Python)
  # Object: {a, b} = obj and Array: [a, ...rest] = arr
  pm.addPass(newTransformPass(
    id: tpDestructuring,
    name: "destructuring",
    kind: tpkLowering,
    description: "Transform object and array destructuring to explicit assignments",
    transform: transformDestructuring,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkDestructureObj, xnkDestructureArray, xnkTupleUnpacking]
  ))

  # 10. List comprehensions (Python)
  # [expr for x in iter if cond] → for loop with collect
  pm.addPass(newTransformPass(
    id: tpListComprehension,
    name: "list-comprehension",
    kind: tpkLowering,
    description: "Transform list comprehensions to for loops",
    transform: transformListComprehension,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkComprehensionExpr]
  ))

  # 11. String interpolation (Python f-strings, JS template literals, C#)
  # f"Hello {name}" → "Hello " & name
  pm.addPass(newTransformPass(
    id: tpStringInterpolation,
    name: "string-interpolation",
    kind: tpkNormalization,
    description: "Transform string interpolation to concatenation",
    transform: transformStringInterpolation,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkStringInterpolation]
  ))

  # 12. Simple normalizations (pass → discard, empty blocks)
  pm.addPass(newTransformPass(
    id: tpNormalizeSimple,
    name: "normalize-simple",
    kind: tpkNormalization,
    description: "Normalize pass statements and simple constructs",
    transform: transformNormalizeSimple,
    dependencies: @[]  # No dependencies
  ))

  # 13. With statement → defer pattern (Python)
  # Python's with statement uses context managers for resource cleanup
  # Nim uses defer for automatic cleanup on scope exit
  pm.addPass(newTransformPass(
    id: tpWithToDefer,
    name: "with-to-defer",
    kind: tpkLowering,
    description: "Transform with statements to defer pattern for resource cleanup",
    transform: transformWithToDefer,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkWithStmt]
  ))

  # 14. Async/await normalization
  # Normalize async/await patterns from various languages to Nim's async
  pm.addPass(newTransformPass(
    id: tpAsyncNormalization,
    name: "async-normalization",
    kind: tpkNormalization,
    description: "Normalize async/await patterns to Nim conventions",
    transform: transformAsyncNormalization,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkAwaitExpr, xnkYieldExpr]
  ))

  # 15. Union types → variant objects (TypeScript/Python)
  # type Foo = A | B → enum + variant object with case
  pm.addPass(newTransformPass(
    id: tpUnionToVariant,
    name: "union-to-variant",
    kind: tpkLowering,
    description: "Transform union types to Nim variant objects (sum types)",
    transform: transformUnionToVariant,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkUnionType]
  ))

  # 16. LINQ queries → sequtils/zero-functional (C#)
  # LINQ method chains to Nim's sequtils or zero-functional library
  # Note: zero-functional provides LINQ-like syntax in Nim
  pm.addPass(newTransformPass(
    id: tpLinqToSequtils,
    name: "linq-to-sequtils",
    kind: tpkLowering,
    description: "Transform LINQ queries to Nim sequtils/algorithm operations",
    transform: transformLinqToSequtils,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkCallExpr]
  ))

  # 17. Operator overloading normalization (Python, C++, C#)
  # Transform operator special methods to Nim operator procs
  pm.addPass(newTransformPass(
    id: tpOperatorOverload,
    name: "operator-overload",
    kind: tpkNormalization,
    description: "Normalize operator overloads to Nim syntax (backtick operators)",
    transform: transformOperatorOverload,
    dependencies: @[]  # No dependencies
  ))

  # 18. Pattern matching → case/if-elif (Rust, F#, Haskell, Python 3.10+)
  # Advanced pattern matching to Nim case statements or if-elif chains
  pm.addPass(newTransformPass(
    id: tpPatternMatching,
    name: "pattern-matching",
    kind: tpkLowering,
    description: "Transform pattern matching to case statements or if-elif chains",
    transform: transformPatternMatching,
    dependencies: @[]  # No dependencies
  ))

  # 19. Decorators/Attributes → pragmas (Python decorators, C# attributes)
  # @decorator, [Attribute] → {.pragma.}
  pm.addPass(newTransformPass(
    id: tpDecoratorAttribute,
    name: "decorator-attribute",
    kind: tpkNormalization,
    description: "Transform decorators and attributes to Nim pragmas",
    transform: transformDecoratorAttribute,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkDecorator, xnkAttribute]
  ))

  # 20. Extension methods → regular procs (C#)
  # C# extension methods to Nim procedures (UFCS)
  pm.addPass(newTransformPass(
    id: tpExtensionMethods,
    name: "extension-methods",
    kind: tpkNormalization,
    description: "Transform C# extension methods to regular Nim procedures",
    transform: transformExtensionMethods,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkMethodDecl, xnkFuncDecl]
  ))

  # 21. Go error handling pattern (if err != nil)
  # Transform Go's explicit error returns to Nim exceptions
  pm.addPass(newTransformPass(
    id: tpGoErrorHandling,
    name: "go-error-handling",
    kind: tpkLowering,
    description: "Transform Go error handling patterns to Nim exception handling",
    transform: transformGoErrorHandling,
    dependencies: @[]  # No dependencies
  ))

  # 22. Go defer statement normalization
  # Go defer executes at function exit, Nim defer at scope exit
  pm.addPass(newTransformPass(
    id: tpGoDefer,
    name: "go-defer",
    kind: tpkNormalization,
    description: "Normalize Go defer to Nim defer (handles scope differences)",
    transform: transformGoDefer,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkDeferStmt]
  ))

  # 23. C# using statement (IDisposable pattern)
  # Transform C# using to Nim defer for resource cleanup
  pm.addPass(newTransformPass(
    id: tpCSharpUsing,
    name: "csharp-using",
    kind: tpkLowering,
    description: "Transform C# using statements to Nim defer pattern",
    transform: transformCSharpUsing,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkUsingStmt]
  ))

  # 24. Go concurrency (goroutines and channels)
  # Transform Go goroutines to Nim spawn/async and channels
  pm.addPass(newTransformPass(
    id: tpGoConcurrency,
    name: "go-concurrency",
    kind: tpkLowering,
    description: "Transform Go goroutines and channels to Nim concurrency primitives",
    transform: transformGoStatement,  # Main transform function
    dependencies: @[]  # No dependencies
  ))

  # 25. Python generators → Nim iterators
  # Transform generator functions (with yield) to Nim iterators
  pm.addPass(newTransformPass(
    id: tpPythonGenerators,
    name: "python-generators",
    kind: tpkLowering,
    description: "Transform Python generator functions to Nim iterators",
    transform: transformPythonGenerator,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkYieldStmt, xnkFuncDecl]
  ))

  # 26. Python type hints → Nim types
  # Transform Python 3.5+ type hints to Nim's static types
  pm.addPass(newTransformPass(
    id: tpPythonTypeHints,
    name: "python-type-hints",
    kind: tpkNormalization,
    description: "Transform Python type hints to Nim type annotations",
    transform: transformPythonTypeHints,
    dependencies: @[]  # No dependencies
  ))

  # 27. Go panic/recover → exceptions
  # Transform Go's panic/recover to Nim's try/except
  pm.addPass(newTransformPass(
    id: tpGoPanicRecover,
    name: "go-panic-recover",
    kind: tpkLowering,
    description: "Transform Go panic/recover to Nim exception handling",
    transform: transformGoPanicRecover,
    dependencies: @[]  # No dependencies
  ))

  # 28. C# events and delegates → callbacks
  # Transform event/delegate pattern to proc types and callback lists
  pm.addPass(newTransformPass(
    id: tpCSharpEvents,
    name: "csharp-events",
    kind: tpkLowering,
    description: "Transform C# events and delegates to Nim callbacks",
    transform: transformCSharpEvents,
    dependencies: @[]  # No dependencies
  ))

  # 29. Lambda normalization (Python, JS, C#, Java)
  # Normalize various lambda syntaxes to Nim anonymous procs
  pm.addPass(newTransformPass(
    id: tpLambdaNormalization,
    name: "lambda-normalization",
    kind: tpkNormalization,
    description: "Normalize lambda expressions to Nim anonymous procs",
    transform: transformLambdaNormalization,
    dependencies: @[]  # No dependencies
  ))

  # 30. Go type assertions and type switches
  # Transform Go's type assertions (x.(Type)) and type switches
  pm.addPass(newTransformPass(
    id: tpGoTypeAssertions,
    name: "go-type-assertions",
    kind: tpkLowering,
    description: "Transform Go type assertions and type switches",
    transform: transformGoTypeAssertions,
    dependencies: @[]  # No dependencies
  ))

  # 31. Go implicit interfaces → explicit concepts
  # Transform Go's structural interfaces to Nim's concepts
  pm.addPass(newTransformPass(
    id: tpGoImplicitInterfaces,
    name: "go-implicit-interfaces",
    kind: tpkLowering,
    description: "Transform Go implicit interfaces to Nim concepts",
    transform: transformGoImplicitInterfaces,
    dependencies: @[]  # No dependencies
  ))

  # 32. Enum normalization (Python, C#, TypeScript, Java)
  # Normalize enum declarations from various languages
  pm.addPass(newTransformPass(
    id: tpEnumNormalization,
    name: "enum-normalization",
    kind: tpkNormalization,
    description: "Normalize enum declarations to Nim enum syntax",
    transform: transformEnumNormalization,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkEnumDecl]
  ))

  # 33. Python multiple inheritance → composition
  # Transform multiple inheritance to single inheritance + composition
  pm.addPass(newTransformPass(
    id: tpPythonMultipleInheritance,
    name: "python-multiple-inheritance",
    kind: tpkLowering,
    description: "Transform Python multiple inheritance to composition pattern",
    transform: transformPythonMultipleInheritance,
    dependencies: @[],  # No dependencies
    targetKinds: @[xnkClassDecl]
  ))

  # TODO: Additional passes for even more completeness:
  # Python:
  # - f-string advanced features (format specs, conversions)
  # - Metaclasses → macros/templates
  # - Context managers (contextlib) → defer patterns
  #
  # Go:
  # - Struct tags → pragmas
  # - Build tags → conditional compilation
  #
  # C#:
  # - var keyword normalization → let with type inference
  # - Partial classes → module organization
  # - Nullable reference types → Option types
  # - LINQ query syntax → method syntax
  #
  # Java:
  # - Annotations → pragmas
  # - Checked exceptions → explicit error handling
  #
  # TypeScript:
  # - Intersection types → composition
  # - Type guards → type checking
  # - Mapped types → generics

proc createNimPassManager*(): PassManager =
  ## Create a pass manager with all Nim transformation passes registered
  result = newPassManager(targetLang = "nim", maxIterations = 10)
  registerNimPasses(result)
