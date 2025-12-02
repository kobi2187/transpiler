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
import collections/tables

proc buildNimPassRegistry*(): Table[TransformPassID, TransformPass] =
  ## Build a registry of all Nim passes so callers can select which ones to add based on target capabilities.
  var reg = initTable[TransformPassID, TransformPass]()

  # Lowering passes
  reg[tpForToWhile] = newTransformPass(tpForToWhile, transformForToWhile, @[], @[xnkForStmt])
  reg[tpDoWhileToWhile] = newTransformPass(tpDoWhileToWhile, transformDoWhileToWhile, @[], @[xnkDoWhileStmt])
  reg[tpTernaryToIf] = newTransformPass(tpTernaryToIf, transformTernaryToIf, @[], @[xnkTernaryExpr])
  reg[tpInterfaceToConcept] = newTransformPass(tpInterfaceToConcept, transformInterfaceToConcept, @[], @[xnkInterfaceDecl])
  reg[tpPropertyToProcs] = newTransformPass(tpPropertyToProcs, transformPropertyToProcs, @[], @[xnkPropertyDecl])
  reg[tpSwitchFallthrough] = newTransformPass(tpSwitchFallthrough, transformSwitchFallthrough, @[], @[xnkSwitchStmt, xnkCaseClause])
  reg[tpNullCoalesce] = newTransformPass(tpNullCoalesce, transformNullCoalesce, @[], @[xnkNullCoalesceExpr, xnkSafeNavigationExpr])
  reg[tpMultipleCatch] = newTransformPass(tpMultipleCatch, transformMultipleCatch, @[], @[xnkTryStmt])
  reg[tpDestructuring] = newTransformPass(tpDestructuring, transformDestructuring, @[], @[xnkDestructureObj, xnkDestructureArray, xnkTupleUnpacking])
  reg[tpListComprehension] = newTransformPass(tpListComprehension, transformListComprehension, @[], @[xnkComprehensionExpr])
  reg[tpStringInterpolation] = newTransformPass(tpStringInterpolation, transformStringInterpolation, @[], @[xnkStringInterpolation])
  reg[tpNormalizeSimple] = newTransformPass(tpNormalizeSimple, transformNormalizeSimple, @[] )
  reg[tpWithToDefer] = newTransformPass(tpWithToDefer, transformWithToDefer, @[], @[xnkWithStmt])
  reg[tpAsyncNormalization] = newTransformPass(tpAsyncNormalization, transformAsyncNormalization, @[], @[xnkAwaitExpr, xnkYieldExpr])
  reg[tpUnionToVariant] = newTransformPass(tpUnionToVariant, transformUnionToVariant, @[], @[xnkUnionType])
  reg[tpLinqToSequtils] = newTransformPass(tpLinqToSequtils, transformLinqToSequtils, @[], @[xnkCallExpr])
  reg[tpOperatorOverload] = newTransformPass(tpOperatorOverload, transformOperatorOverload, @[]) 
  reg[tpPatternMatching] = newTransformPass(tpPatternMatching, transformPatternMatching, @[]) 
  reg[tpDecoratorAttribute] = newTransformPass(tpDecoratorAttribute, transformDecoratorAttribute, @[], @[xnkDecorator, xnkAttribute])
  reg[tpExtensionMethods] = newTransformPass(tpExtensionMethods, transformExtensionMethods, @[], @[xnkMethodDecl, xnkFuncDecl])
  reg[tpGoErrorHandling] = newTransformPass(tpGoErrorHandling, transformGoErrorHandling, @[]) 
  reg[tpGoDefer] = newTransformPass(tpGoDefer, transformGoDefer, @[], @[xnkDeferStmt])
  reg[tpCSharpUsing] = newTransformPass(tpCSharpUsing, transformCSharpUsing, @[], @[xnkUsingStmt])
  reg[tpGoConcurrency] = newTransformPass(tpGoConcurrency, transformGoStatement, @[]) 
  reg[tpPythonGenerators] = newTransformPass(tpPythonGenerators, transformPythonGenerator, @[], @[xnkYieldStmt, xnkFuncDecl]) 
  reg[tpPythonTypeHints] = newTransformPass(tpPythonTypeHints, transformPythonTypeHints, @[]) 
  reg[tpGoPanicRecover] = newTransformPass(tpGoPanicRecover, transformGoPanicRecover, @[]) 
  reg[tpCSharpEvents] = newTransformPass(tpCSharpEvents, transformCSharpEvents, @[]) 
  reg[tpLambdaNormalization] = newTransformPass(tpLambdaNormalization, transformLambdaNormalization, @[]) 
  reg[tpGoTypeAssertions] = newTransformPass(tpGoTypeAssertions, transformGoTypeAssertions, @[]) 
  reg[tpGoImplicitInterfaces] = newTransformPass(tpGoImplicitInterfaces, transformGoImplicitInterfaces, @[]) 
  reg[tpEnumNormalization] = newTransformPass(tpEnumNormalization, transformEnumNormalization, @[]) 
  reg[tpPythonMultipleInheritance] = newTransformPass(tpPythonMultipleInheritance, transformMultipleInheritance, @[]) 

  return reg

proc registerNimPasses*(pm: PassManager) =
  ## Register all transformation passes for Nim target language using the pass registry + selection logic
  let registry = buildNimPassRegistry()
  let ids = selectPassIDsForLang(pm.targetLang)

  for id in ids:
    if registry.hasKey(id):
      pm.addPass(registry[id])

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
