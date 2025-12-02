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
  ## Register all transformation passes for Nim target language using the pass registry + selection logic
  let registry = buildNimPassRegistry()
  let ids = selectPassIDsForLang(pm.targetLang)

  for id in ids:
    if registry.hasKey(id):
      pm.addPass(registry[id])

proc createNimPassManager*(): PassManager =
  ## Create a pass manager with all Nim transformation passes registered
  result = newPassManager(targetLang = "nim", maxIterations = 10)
  registerNimPasses(result)

proc buildNimPassRegistry*(): Table[TransformPassID, TransformPass] =
  ## Build a registry of all Nim passes so callers can select which ones to add based on target capabilities.
  var reg = initTable[TransformPassID, TransformPass]()

  # Lowering passes
  reg[tpForToWhile] = newTransformPass(tpForToWhile, transformForToWhile, dependencies: @[], targetKinds: @[xnkForStmt])
  reg[tpDoWhileToWhile] = newTransformPass(tpDoWhileToWhile, transformDoWhileToWhile, dependencies: @[], targetKinds: @[xnkDoWhileStmt])
  reg[tpTernaryToIf] = newTransformPass(tpTernaryToIf, transformTernaryToIf, dependencies: @[], targetKinds: @[xnkTernaryExpr])
  reg[tpInterfaceToConcept] = newTransformPass(tpInterfaceToConcept, transformInterfaceToConcept, dependencies: @[], targetKinds: @[xnkInterfaceDecl])
  reg[tpPropertyToProcs] = newTransformPass(tpPropertyToProcs, transformPropertyToProcs, dependencies: @[], targetKinds: @[xnkPropertyDecl])
  reg[tpSwitchFallthrough] = newTransformPass(tpSwitchFallthrough, transformSwitchFallthrough, dependencies: @[], targetKinds: @[xnkSwitchStmt, xnkCaseClause])
  reg[tpNullCoalesce] = newTransformPass(tpNullCoalesce, transformNullCoalesce, dependencies: @[], targetKinds: @[xnkNullCoalesceExpr, xnkSafeNavigationExpr])
  reg[tpMultipleCatch] = newTransformPass(tpMultipleCatch, transformMultipleCatch, dependencies: @[], targetKinds: @[xnkTryStmt])
  reg[tpDestructuring] = newTransformPass(tpDestructuring, transformDestructuring, dependencies: @[], targetKinds: @[xnkDestructureObj, xnkDestructureArray, xnkTupleUnpacking])
  reg[tpListComprehension] = newTransformPass(tpListComprehension, transformListComprehension, dependencies: @[], targetKinds: @[xnkComprehensionExpr])
  reg[tpStringInterpolation] = newTransformPass(tpStringInterpolation, transformStringInterpolation, dependencies: @[], targetKinds: @[xnkStringInterpolation])
  reg[tpNormalizeSimple] = newTransformPass(tpNormalizeSimple, transformNormalizeSimple, dependencies: @[] )
  reg[tpWithToDefer] = newTransformPass(tpWithToDefer, transformWithToDefer, dependencies: @[], targetKinds: @[xnkWithStmt])
  reg[tpAsyncNormalization] = newTransformPass(tpAsyncNormalization, transformAsyncNormalization, dependencies: @[], targetKinds: @[xnkAwaitExpr, xnkYieldExpr])
  reg[tpUnionToVariant] = newTransformPass(tpUnionToVariant, transformUnionToVariant, dependencies: @[], targetKinds: @[xnkUnionType])
  reg[tpLinqToSequtils] = newTransformPass(tpLinqToSequtils, transformLinqToSequtils, dependencies: @[], targetKinds: @[xnkCallExpr])
  reg[tpOperatorOverload] = newTransformPass(tpOperatorOverload, transformOperatorOverload, dependencies: @[]) 
  reg[tpPatternMatching] = newTransformPass(tpPatternMatching, transformPatternMatching, dependencies: @[]) 
  reg[tpDecoratorAttribute] = newTransformPass(tpDecoratorAttribute, transformDecoratorAttribute, dependencies: @[], targetKinds: @[xnkDecorator, xnkAttribute])
  reg[tpExtensionMethods] = newTransformPass(tpExtensionMethods, transformExtensionMethods, dependencies: @[], targetKinds: @[xnkMethodDecl, xnkFuncDecl])
  reg[tpGoErrorHandling] = newTransformPass(tpGoErrorHandling, transformGoErrorHandling, dependencies: @[]) 
  reg[tpGoDefer] = newTransformPass(tpGoDefer, transformGoDefer, dependencies: @[], targetKinds: @[xnkDeferStmt])
  reg[tpCSharpUsing] = newTransformPass(tpCSharpUsing, transformCSharpUsing, dependencies: @[], targetKinds: @[xnkUsingStmt])
  reg[tpGoConcurrency] = newTransformPass(tpGoConcurrency, transformGoStatement, dependencies: @[]) 
  reg[tpPythonGenerators] = newTransformPass(tpPythonGenerators, transformPythonGenerator, dependencies: @[], targetKinds: @[xnkYieldStmt, xnkFuncDecl]) 
  reg[tpPythonTypeHints] = newTransformPass(tpPythonTypeHints, transformPythonTypeHints, dependencies: @[]) 
  reg[tpGoPanicRecover] = newTransformPass(tpGoPanicRecover, transformGoPanicRecover, dependencies: @[]) 
  reg[tpCSharpEvents] = newTransformPass(tpCSharpEvents, transformCSharpEvents, dependencies: @[]) 
  reg[tpLambdaNormalization] = newTransformPass(tpLambdaNormalization, transformLambdaNormalization, dependencies: @[]) 
  reg[tpGoTypeAssertions] = newTransformPass(tpGoTypeAssertions, transformGoTypeAssertions, dependencies: @[]) 
  reg[tpGoImplicitInterfaces] = newTransformPass(tpGoImplicitInterfaces, transformGoImplicitInterfaces, dependencies: @[]) 
  reg[tpEnumNormalization] = newTransformPass(tpEnumNormalization, transformEnumNormalization, dependencies: @[]) 
  reg[tpPythonMultipleInheritance] = newTransformPass(tpPythonMultipleInheritance, transformMultipleInheritance, dependencies: @[]) 

  return reg

let nimDefaultPassIDs = @[tpForToWhile, tpDoWhileToWhile, tpTernaryToIf, tpInterfaceToConcept, tpPropertyToProcs, tpSwitchFallthrough,
                         tpNullCoalesce, tpMultipleCatch, tpDestructuring, tpListComprehension, tpStringInterpolation, tpNormalizeSimple,
                         tpWithToDefer, tpAsyncNormalization, tpUnionToVariant, tpLinqToSequtils, tpOperatorOverload, tpPatternMatching,
                         tpDecoratorAttribute, tpExtensionMethods, tpLambdaNormalization, tpEnumNormalization]

let goDefaultPassIDs = @[tpGoErrorHandling, tpGoDefer, tpGoConcurrency, tpGoTypeAssertions, tpGoImplicitInterfaces, tpGoPanicRecover]

let pythonDefaultPassIDs = @[tpPythonGenerators, tpPythonTypeHints, tpListComprehension, tpDestructuring, tpPatternMatching]

let csharpDefaultPassIDs = @[tpLinqToSequtils, tpCSharpUsing, tpCSharpEvents, tpExtensionMethods]

proc selectPassIDsForLang*(caps: LangCapabilities): seq[TransformPassID] =
  result = @[]
  case caps.name.toLowerAscii():
  of "nim": result = nimDefaultPassIDs
  of "go": result = goDefaultPassIDs
  of "python": result = pythonDefaultPassIDs
  of "csharp": result = csharpDefaultPassIDs
  else: # default include Nim-like pass set
    result = nimDefaultPassIDs
  # Always include normalization and utilities
  result.add(tpNormalizeSimple)
  result.add(tpOperatorOverload)
  return result
