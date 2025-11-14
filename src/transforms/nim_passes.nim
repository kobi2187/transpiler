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

  # TODO: More passes to add:
  # - List comprehensions (Python)
  # - LINQ queries (C#)
  # - Destructuring assignment (JS/Python)
  # - Union types → variant objects
  # - Async/await normalization
  # - Operator overloading normalization

proc createNimPassManager*(): PassManager =
  ## Create a pass manager with all Nim transformation passes registered
  result = newPassManager(targetLang = "nim", maxIterations = 10)
  registerNimPasses(result)
