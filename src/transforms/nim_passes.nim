## Nim-Specific Transformation Passes
##
## Registers all transformation passes needed to convert XLang AST
## to Nim-compatible constructs.

import core/xlangtypes
import pass_manager2
import semantic/semantic_analysis
import collections/tables
import strutils
import passes/for_to_while
import passes/dowhile_to_while
import passes/common/ternary_to_if
import passes/common/interface_to_concept
import passes/property_to_procs
import passes/switch_fallthrough
import passes/null_coalesce
import passes/multiple_catch
import passes/destructuring
import passes/list_comprehension
import passes/normalize_simple
import passes/string_interpolation
import passes/from_python/with_to_defer
import passes/async_normalization
import passes/union_to_variant
import passes/operator_overload
import passes/pattern_matching
import passes/decorator_attribute
import passes/extension_methods
import passes/from_go/go_error_handling
import passes/from_go/go_defer
import passes/csharp_using
import passes/from_go/go_concurrency
import passes/from_python/python_generators
import passes/from_python/python_type_hints
import passes/from_go/go_panic_recover
import passes/csharp_events
import passes/lambda_normalization
import passes/from_go/go_type_assertions
import passes/from_go/go_implicit_interfaces
import passes/from_python/python_multiple_inheritance
import passes/safe_navigation
import passes/indexer_to_procs
import passes/generator_expressions
import passes/throw_expression
import passes/common/resource_to_defer
import passes/common/resource_to_try_finally
import passes/common/switch_expr_to_case
import passes/common/lock_to_with_lock
import passes/stackalloc_to_seq
import passes/conversion_op_to_proc
import passes/checked_to_block
import passes/fixed_to_block
import passes/local_function_to_proc
import passes/from_csharp/unsafe_to_nim_block
import passes/delegate_to_proc_type
import passes/common/nullable_to_option
import passes/add_self_parameter
import passes/normalize_operators
import types

template toClosure(p: untyped): proc(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode {.closure.} =
  proc(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode {.closure.} =
    p(node, semanticInfo)




# based on Nim's language constructs and features, choose transformation passes
# to add to the pass manager for xlang node kinds that aren't supported by Nim.

proc buildNimPassRegistry*(): Table[TransformPassID, TransformPass] =
  ## Build a registry of all Nim passes so callers can select which ones to add based on target capabilities.
  ## Lowering passes now operate on xnkExternal_* kinds (source-specific constructs that must be eliminated).
  var reg = initTable[TransformPassID, TransformPass]()

  # Normalization pass - runs first to convert operators to External nodes
  # Uses empty list because it needs to traverse all nodes looking for special operators
  reg[tpNormalizeOperators] = newTransformPass(tpNormalizeOperators, toClosure(normalizeOperators), @[])

  # Lowering passes - operate on external kinds that must be eliminated
  reg[tpForToWhile] = newTransformPass(tpForToWhile, toClosure(transformForToWhile), @[xnkExternal_ForStmt])
  reg[tpDoWhileToWhile] = newTransformPass(tpDoWhileToWhile, toClosure(transformDoWhileToWhile), @[xnkExternal_DoWhile])
  reg[tpTernaryToIf] = newTransformPass(tpTernaryToIf, toClosure(transformTernaryToIf), @[xnkExternal_Ternary])
  reg[tpNimInterfaceToConcept] = newTransformPass(tpNimInterfaceToConcept, toClosure(transformInterfaceToConcept), @[xnkExternal_Interface])
  reg[tpPropertyToProcs] = newTransformPass(tpPropertyToProcs, toClosure(transformPropertyToProcs), @[xnkExternal_Property])
  reg[tpSwitchFallthrough] = newTransformPass(tpSwitchFallthrough, toClosure(transformSwitchFallthrough), @[])  # operates on common kinds, no tracking
  reg[tpNullCoalesce] = newTransformPass(tpNullCoalesce, toClosure(transformNullCoalesce), @[xnkExternal_NullCoalesce])
  reg[tpMultipleCatch] = newTransformPass(tpMultipleCatch, toClosure(transformMultipleCatch), @[])  # operates on common xnkTryStmt, no tracking
  reg[tpDestructuring] = newTransformPass(tpDestructuring, toClosure(transformDestructuring), @[xnkExternal_Destructure])
  reg[tpListComprehension] = newTransformPass(tpListComprehension, toClosure(transformListComprehension), @[xnkExternal_Comprehension])
  # String interpolation - PassManager2's traverseTree visits all nodes
  reg[tpStringInterpolation] = newTransformPass(tpStringInterpolation, toClosure(transformStringInterpolation), @[xnkExternal_StringInterp])
  reg[tpNormalizeSimple] = newTransformPass(tpNormalizeSimple, toClosure(transformNormalizeSimple), @[])  # general normalization, no tracking
  reg[tpWithToDefer] = newTransformPass(tpWithToDefer, toClosure(transformWithToDefer), @[xnkExternal_With])
  reg[tpAsyncNormalization] = newTransformPass(tpAsyncNormalization, toClosure(transformAsyncNormalization), @[xnkExternal_Await])
  reg[tpUnionToVariant] = newTransformPass(tpUnionToVariant, toClosure(transformUnionToVariant), @[xnkUnionType])
  # reg[tpLinqToSequtils] = newTransformPass(tpLinqToSequtils, toClosure(transformLinqToSequtils), @[])
  reg[tpOperatorOverload] = newTransformPass(tpOperatorOverload, toClosure(transformOperatorOverload), @[xnkExternal_Operator])
  reg[tpPatternMatching] = newTransformPass(tpPatternMatching, toClosure(transformPatternMatching), @[])
  reg[tpDecoratorAttribute] = newTransformPass(tpDecoratorAttribute, toClosure(transformDecoratorAttribute), @[xnkDecorator, xnkAttribute])
  reg[tpExtensionMethods] = newTransformPass(tpExtensionMethods, toClosure(transformExtensionMethods), @[xnkExternal_ExtensionMethod])
  reg[tpGoErrorHandling] = newTransformPass(tpGoErrorHandling, toClosure(transformGoErrorHandling), @[])
  reg[tpGoDefer] = newTransformPass(tpGoDefer, toClosure(transformGoDefer), @[xnkDeferStmt])
  reg[tpCSharpUsing] = newTransformPass(tpCSharpUsing, toClosure(transformCSharpUsing), @[xnkUsingStmt])
  reg[tpGoConcurrency] = newTransformPass(tpGoConcurrency, toClosure(transformGoStatement), @[])
  reg[tpPythonGenerators] = newTransformPass(tpPythonGenerators, toClosure(transformPythonGenerator), @[xnkExternal_Generator])
  reg[tpPythonTypeHints] = newTransformPass(tpPythonTypeHints, toClosure(transformPythonTypeHints), @[])
  reg[tpGoPanicRecover] = newTransformPass(tpGoPanicRecover, toClosure(transformGoPanicRecover), @[])
  reg[tpCSharpEvents] = newTransformPass(tpCSharpEvents, toClosure(transformCSharpEvents), @[xnkExternal_Event])
  reg[tpLambdaNormalization] = newTransformPass(tpLambdaNormalization, toClosure(transformLambdaNormalization), @[])
  reg[tpGoTypeAssertions] = newTransformPass(tpGoTypeAssertions, toClosure(transformGoTypeAssertions), @[])
  reg[tpGoImplicitInterfaces] = newTransformPass(tpGoImplicitInterfaces, toClosure(transformGoImplicitInterfaces), @[])
  # Enum normalization is now called separately in main.nim, not through the pass manager
  # reg[tpEnumNormalization] = newTransformPass(tpEnumNormalization, toClosure(transformEnumNormalization), @[])
  reg[tpPythonMultipleInheritance] = newTransformPass(tpPythonMultipleInheritance, toClosure(transformMultipleInheritance), @[])
  reg[tpSafeNavigation] = newTransformPass(tpSafeNavigation, toClosure(transformSafeNavigation), @[xnkExternal_SafeNavigation])
  reg[tpGeneratorExpressions] = newTransformPass(tpGeneratorExpressions, toClosure(transformGeneratorExpressions), @[xnkExternal_Generator])
  reg[tpThrowExpression] = newTransformPass(tpThrowExpression, toClosure(transformThrowExpression), @[xnkExternal_ThrowExpr])
  reg[tpResourceToDefer] = newTransformPass(tpResourceToDefer, toClosure(transformResourceToDefer), @[xnkExternal_Resource])
  reg[tpResourceToTryFinally] = newTransformPass(tpResourceToTryFinally, toClosure(transformResourceToTryFinally), @[xnkExternal_Resource])  # Alternative for targets without defer
  reg[tpIndexerToProcs] = newTransformPass(tpIndexerToProcs, toClosure(transformIndexerToProcs), @[xnkExternal_Indexer])
  reg[tpSwitchExprToCase] = newTransformPass(tpSwitchExprToCase, toClosure(transformSwitchExprToCase), @[xnkExternal_SwitchExpr])
  reg[tpLockToWithLock] = newTransformPass(tpLockToWithLock, toClosure(transformLockToWithLock), @[xnkExternal_Lock])
  reg[tpStackAllocToSeq] = newTransformPass(tpStackAllocToSeq, toClosure(transformStackAllocToSeq), @[xnkExternal_StackAlloc])
  reg[tpConversionOpToProc] = newTransformPass(tpConversionOpToProc, toClosure(transformConversionOpToProc), @[xnkExternal_ConversionOp])
  reg[tpCheckedToBlock] = newTransformPass(tpCheckedToBlock, toClosure(transformCheckedToBlock), @[xnkExternal_Checked])
  reg[tpFixedToBlock] = newTransformPass(tpFixedToBlock, toClosure(transformFixedToBlock), @[xnkExternal_Fixed])
  reg[tpLocalFunctionToProc] = newTransformPass(tpLocalFunctionToProc, toClosure(transformLocalFunctionToProc), @[xnkExternal_LocalFunction])
  reg[tpUnsafeToNimBlock] = newTransformPass(tpUnsafeToNimBlock, toClosure(transformUnsafeToNimBlock), @[xnkExternal_Unsafe])
  reg[tpDelegateToProcType] = newTransformPass(tpDelegateToProcType, toClosure(transformDelegateToTypeAlias), @[xnkExternal_Delegate])
  reg[tpNullableToOption] = newTransformPass(tpNullableToOption, toClosure(transformNullableToOption), @[xnkGenericType])
  reg[tpAddSelfParameter] = newTransformPass(tpAddSelfParameter, toClosure(addSelfParameter), @[xnkClassDecl, xnkStructDecl])

  return reg

let nimDefaultPassIDs = @[tpNormalizeOperators, tpForToWhile, tpDoWhileToWhile, tpTernaryToIf, tpNimInterfaceToConcept, tpPropertyToProcs, tpSwitchFallthrough,
                         tpNullCoalesce, tpMultipleCatch, tpDestructuring, tpListComprehension, tpNormalizeSimple,
                         tpWithToDefer, tpAsyncNormalization, tpUnionToVariant, tpOperatorOverload, tpPatternMatching,
                         tpDecoratorAttribute, tpExtensionMethods, tpLambdaNormalization, tpSafeNavigation,
                         tpResourceToDefer, tpThrowExpression, tpGeneratorExpressions, tpStringInterpolation, tpIndexerToProcs,
                         tpSwitchExprToCase, tpLockToWithLock, tpStackAllocToSeq, tpCheckedToBlock, tpFixedToBlock,
                         tpLocalFunctionToProc, tpUnsafeToNimBlock, tpDelegateToProcType, tpNullableToOption, tpCSharpEvents] # , tpConversionOpToProc - using direct impl in xlangtonim instead # , tpAddSelfParameter - DISABLED temporarily

let goDefaultPassIDs = @[tpGoErrorHandling, tpGoDefer, tpGoConcurrency, tpGoTypeAssertions, tpGoImplicitInterfaces, tpGoPanicRecover]

let pythonDefaultPassIDs = @[tpPythonGenerators, tpPythonTypeHints, tpListComprehension, tpDestructuring, tpPatternMatching, tpGeneratorExpressions]

let csharpDefaultPassIDs = @[tpNormalizeOperators, tpLinqToSequtils, tpCSharpUsing, tpCSharpEvents, tpExtensionMethods, tpIndexerToProcs, tpThrowExpression, tpNullableToOption, tpAddSelfParameter]

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

proc registerNimPasses*(pm: PassManager2, verbose: bool = false) =
  ## Register all transformation passes for Nim target language using the pass registry + selection logic
  let registry = buildNimPassRegistry() # other langs may choose lowering passes that better suits their own constructs.
  let ids = selectPassIDsForLang("nim")

  if verbose:
    echo "DEBUG: Registering ", ids.len, " transform passes:"

  var ts : seq[TransformPass] = @[]
  for id in ids:
    if registry.hasKey(id):
      ts.add registry[id]
      if verbose:
        echo "  - ", id
    elif verbose:
      echo "  - ", id, " (NOT FOUND in registry)"
  pm.addTransforms(ts)

  if verbose:
    echo "DEBUG: Successfully registered ", ts.len, " passes"
