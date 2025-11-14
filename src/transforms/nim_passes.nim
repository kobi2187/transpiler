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
      dependencies: @[]  # No dependencies
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
      dependencies: @[]  # No dependencies
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
      dependencies: @[]  # No dependencies
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
      dependencies: @[]  # No dependencies
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
      dependencies: @[]  # No dependencies
    ))

  # 6. Switch with fallthrough → if-elif chain
  # Nim's case doesn't support fallthrough (like Go has)
  pm.addPass(newTransformPass(
    id: tpSwitchFallthrough,
    name: "switch-fallthrough",
    kind: tpkLowering,
    description: "Transform switch with fallthrough to if-elif chain",
    transform: transformSwitchFallthrough,
    dependencies: @[]  # No dependencies
  ))

  # 7. Null coalescing and safe navigation
  # Nim doesn't have ?? and ?. operators (C# has these)
  pm.addPass(newTransformPass(
    id: tpNullCoalesce,
    name: "null-coalesce",
    kind: tpkLowering,
    description: "Transform null coalescing (??) and safe navigation (?.) operators",
    transform: transformNullCoalesce,
    dependencies: @[]  # No dependencies
  ))

  # 8. Multiple catch blocks → single catch with type checking
  # Nim only supports single catch block (Java has multiple)
  pm.addPass(newTransformPass(
    id: tpMultipleCatch,
    name: "multiple-catch",
    kind: tpkLowering,
    description: "Transform multiple catch blocks to single catch with type checking",
    transform: transformMultipleCatch,
    dependencies: @[]  # No dependencies
  ))

  # 9. Destructuring assignment (JS/Python)
  # Object: {a, b} = obj and Array: [a, ...rest] = arr
  pm.addPass(newTransformPass(
    id: tpDestructuring,
    name: "destructuring",
    kind: tpkLowering,
    description: "Transform object and array destructuring to explicit assignments",
    transform: transformDestructuring,
    dependencies: @[]  # No dependencies
  ))

  # 10. List comprehensions (Python)
  # [expr for x in iter if cond] → for loop with collect
  pm.addPass(newTransformPass(
    id: tpListComprehension,
    name: "list-comprehension",
    kind: tpkLowering,
    description: "Transform list comprehensions to for loops",
    transform: transformListComprehension,
    dependencies: @[]  # No dependencies
  ))

  # 11. String interpolation (Python f-strings, JS template literals, C#)
  # f"Hello {name}" → "Hello " & name
  pm.addPass(newTransformPass(
    id: tpStringInterpolation,
    name: "string-interpolation",
    kind: tpkNormalization,
    description: "Transform string interpolation to concatenation",
    transform: transformStringInterpolation,
    dependencies: @[]  # No dependencies
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
    dependencies: @[]  # No dependencies
  ))

  # 14. Async/await normalization
  # Normalize async/await patterns from various languages to Nim's async
  pm.addPass(newTransformPass(
    id: tpAsyncNormalization,
    name: "async-normalization",
    kind: tpkNormalization,
    description: "Normalize async/await patterns to Nim conventions",
    transform: transformAsyncNormalization,
    dependencies: @[]  # No dependencies
  ))

  # 15. Union types → variant objects (TypeScript/Python)
  # type Foo = A | B → enum + variant object with case
  pm.addPass(newTransformPass(
    id: tpUnionToVariant,
    name: "union-to-variant",
    kind: tpkLowering,
    description: "Transform union types to Nim variant objects (sum types)",
    transform: transformUnionToVariant,
    dependencies: @[]  # No dependencies
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
    dependencies: @[]  # No dependencies
  ))

  # TODO: More passes to add:
  # - Operator overloading normalization
  # - Pattern matching (Rust/F#/Haskell) → case statements
  # - Attributes/Decorators normalization
  # - Extension methods (C#) → regular procs

proc createNimPassManager*(): PassManager =
  ## Create a pass manager with all Nim transformation passes registered
  result = newPassManager(targetLang = "nim", maxIterations = 10)
  registerNimPasses(result)
