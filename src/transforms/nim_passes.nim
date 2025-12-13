## Nim-Specific Transformation Passes
##
## Registers all transformation passes needed to convert XLang AST
## to Nim-compatible constructs.

import ../../xlangtypes
import pass_manager2
import ../xlang/lang_capabilities
import collections/tables
import strutils
import passes/for_to_while
import passes/dowhile_to_while
import passes/ternary_to_if
import passes/interface_to_concept
import passes/property_to_procs
import passes/switch_fallthrough
import passes/null_coalesce
import passes/multiple_catch
import passes/destructuring
import passes/list_comprehension
import passes/normalize_simple
import passes/string_interpolation
import passes/with_to_defer
import passes/async_normalization
import passes/union_to_variant
import passes/linq_to_sequtils
import passes/operator_overload
import passes/pattern_matching
import passes/decorator_attribute
import passes/extension_methods
import passes/go_error_handling
import passes/go_defer
import passes/csharp_using
import passes/go_concurrency
import passes/python_generators
import passes/python_type_hints
import passes/go_panic_recover
import passes/csharp_events
import passes/lambda_normalization
import passes/go_type_assertions
import passes/go_implicit_interfaces
import passes/enum_transformations
import passes/python_multiple_inheritance
import passes/safe_navigation
import passes/indexer_to_procs
import passes/generator_expressions
import passes/throw_expression
import passes/resource_to_defer
import types

template toClosure(p: untyped): proc(node: XLangNode): XLangNode {.closure, gcsafe.} =
  proc(node: XLangNode): XLangNode {.closure, gcsafe.} =
    p(node)




# based on Nim's language constructs and features, choose transformation passes
# to add to the pass manager for xlang node kinds that aren't supported by Nim.

proc buildNimPassRegistry*(): Table[TransformPassID, TransformPass] =
  ## Build a registry of all Nim passes so callers can select which ones to add based on target capabilities.
  var reg = initTable[TransformPassID, TransformPass]()

  # Lowering passes
  reg[tpForToWhile] = newTransformPass(tpForToWhile, toClosure(transformForToWhile),  @[xnkForStmt])
  reg[tpDoWhileToWhile] = newTransformPass(tpDoWhileToWhile, toClosure(transformDoWhileToWhile),  @[xnkDoWhileStmt])
  reg[tpTernaryToIf] = newTransformPass(tpTernaryToIf, toClosure(transformTernaryToIf),  @[xnkTernaryExpr])
  reg[tpInterfaceToConcept] = newTransformPass(tpInterfaceToConcept, toClosure(transformInterfaceToConcept),  @[xnkInterfaceDecl])
  reg[tpPropertyToProcs] = newTransformPass(tpPropertyToProcs, toClosure(transformPropertyToProcs),  @[xnkPropertyDecl, xnkClassDecl, xnkStructDecl, xnkInterfaceDecl])
  reg[tpSwitchFallthrough] = newTransformPass(tpSwitchFallthrough, toClosure(transformSwitchFallthrough),  @[xnkSwitchStmt, xnkCaseClause])
  reg[tpNullCoalesce] = newTransformPass(tpNullCoalesce, toClosure(transformNullCoalesce),  @[xnkNullCoalesceExpr, xnkSafeNavigationExpr])
  reg[tpMultipleCatch] = newTransformPass(tpMultipleCatch, toClosure(transformMultipleCatch),  @[xnkTryStmt])
  reg[tpDestructuring] = newTransformPass(tpDestructuring, toClosure(transformDestructuring),  @[xnkDestructureObj, xnkDestructureArray, xnkTupleUnpacking])
  reg[tpListComprehension] = newTransformPass(tpListComprehension, toClosure(transformListComprehension),  @[xnkComprehensionExpr])
    # String interpolation can appear in many contexts, so we register for common parent nodes
  # and structural nodes to ensure we traverse into all contexts where they might appear
  reg[tpStringInterpolation] = newTransformPass(tpStringInterpolation, toClosure(transformStringInterpolation), 
    @[xnkStringInterpolation, xnkFile, xnkNamespace, xnkClassDecl, xnkStructDecl, xnkFuncDecl, xnkMethodDecl,
      xnkBlockStmt, xnkIfStmt, xnkVarDecl, xnkLetDecl, xnkConstDecl, xnkAsgn, xnkReturnStmt, xnkRaiseStmt, xnkCallExpr])
  reg[tpNormalizeSimple] = newTransformPass(tpNormalizeSimple, toClosure(transformNormalizeSimple), @[] )
  reg[tpWithToDefer] = newTransformPass(tpWithToDefer, toClosure(transformWithToDefer),  @[xnkWithStmt])
  reg[tpAsyncNormalization] = newTransformPass(tpAsyncNormalization, toClosure(transformAsyncNormalization),  @[xnkAwaitExpr, xnkIteratorYield, xnkYieldExpr])
  reg[tpUnionToVariant] = newTransformPass(tpUnionToVariant, toClosure(transformUnionToVariant),  @[xnkUnionType])
  reg[tpLinqToSequtils] = newTransformPass(tpLinqToSequtils, toClosure(transformLinqToSequtils),  @[xnkCallExpr])
  reg[tpOperatorOverload] = newTransformPass(tpOperatorOverload, toClosure(transformOperatorOverload), @[]) 
  reg[tpPatternMatching] = newTransformPass(tpPatternMatching, toClosure(transformPatternMatching), @[]) 
  reg[tpDecoratorAttribute] = newTransformPass(tpDecoratorAttribute, toClosure(transformDecoratorAttribute),  @[xnkDecorator, xnkAttribute])
  reg[tpExtensionMethods] = newTransformPass(tpExtensionMethods, toClosure(transformExtensionMethods),  @[xnkMethodDecl, xnkFuncDecl])
  reg[tpGoErrorHandling] = newTransformPass(tpGoErrorHandling, toClosure(transformGoErrorHandling), @[]) 
  reg[tpGoDefer] = newTransformPass(tpGoDefer, toClosure(transformGoDefer),  @[xnkDeferStmt])
  reg[tpCSharpUsing] = newTransformPass(tpCSharpUsing, toClosure(transformCSharpUsing),  @[xnkUsingStmt])
  reg[tpGoConcurrency] = newTransformPass(tpGoConcurrency, toClosure(transformGoStatement), @[]) 
  reg[tpPythonGenerators] = newTransformPass(tpPythonGenerators, toClosure(transformPythonGenerator),  @[xnkIteratorYield, xnkIteratorDelegate, xnkYieldStmt, xnkFuncDecl]) 
  reg[tpPythonTypeHints] = newTransformPass(tpPythonTypeHints, toClosure(transformPythonTypeHints), @[]) 
  reg[tpGoPanicRecover] = newTransformPass(tpGoPanicRecover, toClosure(transformGoPanicRecover), @[]) 
  reg[tpCSharpEvents] = newTransformPass(tpCSharpEvents, toClosure(transformCSharpEvents), @[]) 
  reg[tpLambdaNormalization] = newTransformPass(tpLambdaNormalization, toClosure(transformLambdaNormalization), @[]) 
  reg[tpGoTypeAssertions] = newTransformPass(tpGoTypeAssertions, toClosure(transformGoTypeAssertions), @[]) 
  reg[tpGoImplicitInterfaces] = newTransformPass(tpGoImplicitInterfaces, toClosure(transformGoImplicitInterfaces), @[]) 
  reg[tpEnumNormalization] = newTransformPass(tpEnumNormalization, toClosure(transformEnumNormalization), @[])
  reg[tpPythonMultipleInheritance] = newTransformPass(tpPythonMultipleInheritance, toClosure(transformMultipleInheritance), @[])
  reg[tpSafeNavigation] = newTransformPass(tpSafeNavigation, toClosure(transformSafeNavigation),  @[xnkSafeNavigationExpr])
  reg[tpIndexerToProcs] = newTransformPass(tpIndexerToProcs, toClosure(transformIndexerToProcs),  @[xnkIndexerDecl, xnkClassDecl, xnkStructDecl])
  reg[tpGeneratorExpressions] = newTransformPass(tpGeneratorExpressions, toClosure(transformGeneratorExpressions),  @[xnkGeneratorExpr])
  reg[tpThrowExpression] = newTransformPass(tpThrowExpression, toClosure(transformThrowExpression),  @[xnkThrowExpr, xnkVarDecl, xnkLetDecl, xnkReturnStmt, xnkAsgn])
  reg[tpResourceToDefer] = newTransformPass(tpResourceToDefer, toClosure(transformResourceToDefer),  @[xnkResourceStmt])

  return reg

let nimDefaultPassIDs = @[tpForToWhile, tpDoWhileToWhile, tpTernaryToIf, tpInterfaceToConcept, tpPropertyToProcs, tpSwitchFallthrough,
                         tpNullCoalesce, tpMultipleCatch, tpDestructuring, tpListComprehension, tpStringInterpolation, tpNormalizeSimple,
                         tpWithToDefer, tpAsyncNormalization, tpUnionToVariant, tpLinqToSequtils, tpOperatorOverload, tpPatternMatching,
                         tpDecoratorAttribute, tpExtensionMethods, tpLambdaNormalization, tpEnumNormalization, tpSafeNavigation,
                         tpResourceToDefer, tpThrowExpression, tpGeneratorExpressions]

let goDefaultPassIDs = @[tpGoErrorHandling, tpGoDefer, tpGoConcurrency, tpGoTypeAssertions, tpGoImplicitInterfaces, tpGoPanicRecover]

let pythonDefaultPassIDs = @[tpPythonGenerators, tpPythonTypeHints, tpListComprehension, tpDestructuring, tpPatternMatching, tpGeneratorExpressions]

let csharpDefaultPassIDs = @[tpLinqToSequtils, tpCSharpUsing, tpCSharpEvents, tpExtensionMethods, tpIndexerToProcs, tpThrowExpression]

proc selectPassIDsForLang*(name:string): seq[TransformPassID] =
  result = @[]
  case name.toLowerAscii():
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

proc registerNimPasses*(pm: PassManager2) =
  ## Register all transformation passes for Nim target language using the pass registry + selection logic
  let registry = buildNimPassRegistry() # other langs may choose lowering passes that better suits their own constructs.
  let ids = selectPassIDsForLang("nim")

  var ts : seq[TransformPass] = @[]
  for id in ids:
    if registry.hasKey(id):
      ts.add registry[id]
  pm.addTransforms(ts)
