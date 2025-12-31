## Global Transform Registry
##
## Centralizes all available lowering transforms.
## Output language backends select which transforms they need from this registry.
##
## Categories:
## - External/Lowering transforms: Eliminate xnkExternal_* nodes (tested, production-ready)
## - Go transforms: Go-specific features (draft, untested)
## - Python transforms: Python-specific features (draft, untested)
## - Experimental: Union/intersection types, pattern matching (draft)

import core/xlangtypes
import semantic/semantic_analysis
import std/tables
import types
import transform_context

# Import core/tested transforms only
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
import passes/async_normalization
import passes/operator_overload
import passes/decorator_attribute
import passes/extension_methods
import passes/csharp_using
import passes/csharp_events
import passes/lambda_normalization
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
import passes/normalize_operators

# Import draft/untested transforms
import passes/from_python/with_to_defer
import passes/union_to_variant
import passes/pattern_matching
import passes/from_go/go_error_handling
import passes/from_go/go_defer
import passes/from_go/go_concurrency
import passes/from_python/python_generators
import passes/from_python/python_type_hints
import passes/from_go/go_panic_recover
import passes/from_go/go_type_assertions
import passes/from_go/go_implicit_interfaces
import passes/from_python/python_multiple_inheritance

# Helper template to convert transform functions to closures
template toClosure(p: untyped): proc(node: XLangNode, ctx: TransformContext): XLangNode {.closure.} =
  proc(node: XLangNode, ctx: TransformContext): XLangNode {.closure.} =
    p(node, ctx)

# Global registry - built once at module load
# Maps each transform ID to its TransformPass implementation
var globalTransformRegistry* {.global.}: Table[TransformPassID, TransformPass]

proc loadExternalTransforms*() =
  ## Load tested, production-ready transforms that eliminate xnkExternal_* nodes
  ## These are the core lowering passes used by the Nim backend

  # Normalization - converts operators to External nodes
  globalTransformRegistry[tpNormalizeOperators] = newTransformPass(tpNormalizeOperators, toClosure(normalizeOperators), @[])
  globalTransformRegistry[tpNormalizeSimple] = newTransformPass(tpNormalizeSimple, toClosure(transformNormalizeSimple), @[])

  # Control flow lowering
  globalTransformRegistry[tpForToWhile] = newTransformPass(tpForToWhile, toClosure(transformForToWhile), @[xnkExternal_ForStmt])
  globalTransformRegistry[tpDoWhileToWhile] = newTransformPass(tpDoWhileToWhile, toClosure(transformDoWhileToWhile), @[xnkExternal_DoWhile])
  globalTransformRegistry[tpTernaryToIf] = newTransformPass(tpTernaryToIf, toClosure(transformTernaryToIf), @[xnkExternal_Ternary])
  globalTransformRegistry[tpSwitchExprToCase] = newTransformPass(tpSwitchExprToCase, toClosure(transformSwitchExprToCase), @[xnkExternal_SwitchExpr])
  globalTransformRegistry[tpSwitchFallthrough] = newTransformPass(tpSwitchFallthrough, toClosure(transformSwitchFallthrough), @[])

  # OOP feature lowering
  globalTransformRegistry[tpNimInterfaceToConcept] = newTransformPass(tpNimInterfaceToConcept, toClosure(transformInterfaceToConcept), @[xnkExternal_Interface])
  globalTransformRegistry[tpPropertyToProcs] = newTransformPass(tpPropertyToProcs, toClosure(transformPropertyToProcs), @[xnkExternal_Property])
  globalTransformRegistry[tpIndexerToProcs] = newTransformPass(tpIndexerToProcs, toClosure(transformIndexerToProcs), @[xnkExternal_Indexer])
  globalTransformRegistry[tpExtensionMethods] = newTransformPass(tpExtensionMethods, toClosure(transformExtensionMethods), @[xnkExternal_ExtensionMethod])

  # Operator lowering
  globalTransformRegistry[tpOperatorOverload] = newTransformPass(tpOperatorOverload, toClosure(transformOperatorOverload), @[xnkExternal_Operator])
  globalTransformRegistry[tpConversionOpToProc] = newTransformPass(tpConversionOpToProc, toClosure(transformConversionOpToProc), @[xnkExternal_ConversionOp])

  # Null safety lowering
  globalTransformRegistry[tpNullCoalesce] = newTransformPass(tpNullCoalesce, toClosure(transformNullCoalesce), @[xnkExternal_NullCoalesce])
  globalTransformRegistry[tpSafeNavigation] = newTransformPass(tpSafeNavigation, toClosure(transformSafeNavigation), @[xnkExternal_SafeNavigation])

  # Error handling
  globalTransformRegistry[tpMultipleCatch] = newTransformPass(tpMultipleCatch, toClosure(transformMultipleCatch), @[])
  globalTransformRegistry[tpThrowExpression] = newTransformPass(tpThrowExpression, toClosure(transformThrowExpression), @[xnkExternal_ThrowExpr])

  # Collections
  globalTransformRegistry[tpDestructuring] = newTransformPass(tpDestructuring, toClosure(transformDestructuring), @[xnkExternal_Destructure])
  globalTransformRegistry[tpListComprehension] = newTransformPass(tpListComprehension, toClosure(transformListComprehension), @[xnkExternal_Comprehension])
  globalTransformRegistry[tpGeneratorExpressions] = newTransformPass(tpGeneratorExpressions, toClosure(transformGeneratorExpressions), @[xnkExternal_Generator])

  # String processing
  globalTransformRegistry[tpStringInterpolation] = newTransformPass(tpStringInterpolation, toClosure(transformStringInterpolation), @[xnkExternal_StringInterp])

  # Resource management
  globalTransformRegistry[tpResourceToDefer] = newTransformPass(tpResourceToDefer, toClosure(transformResourceToDefer), @[xnkExternal_Resource])
  globalTransformRegistry[tpResourceToTryFinally] = newTransformPass(tpResourceToTryFinally, toClosure(transformResourceToTryFinally), @[xnkExternal_Resource])
  globalTransformRegistry[tpLockToWithLock] = newTransformPass(tpLockToWithLock, toClosure(transformLockToWithLock), @[xnkExternal_Lock])

  # Async/await
  globalTransformRegistry[tpAsyncNormalization] = newTransformPass(tpAsyncNormalization, toClosure(transformAsyncNormalization), @[xnkExternal_Await])

  # Attributes/decorators
  globalTransformRegistry[tpDecoratorAttribute] = newTransformPass(tpDecoratorAttribute, toClosure(transformDecoratorAttribute), @[xnkDecorator, xnkAttribute])

  # Lambda normalization
  globalTransformRegistry[tpLambdaNormalization] = newTransformPass(tpLambdaNormalization, toClosure(transformLambdaNormalization), @[])

  # C#-specific lowering
  globalTransformRegistry[tpCSharpUsing] = newTransformPass(tpCSharpUsing, toClosure(transformCSharpUsing), @[xnkUsingStmt])
  globalTransformRegistry[tpCSharpEvents] = newTransformPass(tpCSharpEvents, toClosure(transformCSharpEvents), @[xnkExternal_Event])
  globalTransformRegistry[tpStackallocToSeq] = newTransformPass(tpStackallocToSeq, toClosure(transformStackAllocToSeq), @[xnkExternal_StackAlloc])
  globalTransformRegistry[tpCheckedToBlock] = newTransformPass(tpCheckedToBlock, toClosure(transformCheckedToBlock), @[xnkExternal_Checked])
  globalTransformRegistry[tpFixedToBlock] = newTransformPass(tpFixedToBlock, toClosure(transformFixedToBlock), @[xnkExternal_Fixed])
  globalTransformRegistry[tpLocalFunctionToProc] = newTransformPass(tpLocalFunctionToProc, toClosure(transformLocalFunctionToProc), @[xnkExternal_LocalFunction])
  globalTransformRegistry[tpUnsafeToNimBlock] = newTransformPass(tpUnsafeToNimBlock, toClosure(transformUnsafeToNimBlock), @[xnkExternal_Unsafe])
  globalTransformRegistry[tpDelegateToProcType] = newTransformPass(tpDelegateToProcType, toClosure(transformDelegateToTypeAlias), @[xnkExternal_Delegate])

proc loadGoTransforms*() =
  ## Load Go-specific transforms (DRAFT - untested)
  globalTransformRegistry[tpGoErrorHandling] = newTransformPass(tpGoErrorHandling, toClosure(transformGoErrorHandling), @[])
  globalTransformRegistry[tpGoDefer] = newTransformPass(tpGoDefer, toClosure(transformGoDefer), @[xnkDeferStmt])
  globalTransformRegistry[tpGoConcurrency] = newTransformPass(tpGoConcurrency, toClosure(transformGoStatement), @[])
  globalTransformRegistry[tpGoTypeAssertions] = newTransformPass(tpGoTypeAssertions, toClosure(transformGoTypeAssertions), @[])
  globalTransformRegistry[tpGoImplicitInterfaces] = newTransformPass(tpGoImplicitInterfaces, toClosure(transformGoImplicitInterfaces), @[])
  globalTransformRegistry[tpGoPanicRecover] = newTransformPass(tpGoPanicRecover, toClosure(transformGoPanicRecover), @[])

proc loadPythonTransforms*() =
  ## Load Python-specific transforms (DRAFT - untested)
  globalTransformRegistry[tpWithToDefer] = newTransformPass(tpWithToDefer, toClosure(transformWithToDefer), @[xnkExternal_With])
  globalTransformRegistry[tpPythonGenerators] = newTransformPass(tpPythonGenerators, toClosure(transformPythonGenerator), @[xnkExternal_Generator])
  globalTransformRegistry[tpPythonTypeHints] = newTransformPass(tpPythonTypeHints, toClosure(transformPythonTypeHints), @[])
  globalTransformRegistry[tpPythonMultipleInheritance] = newTransformPass(tpPythonMultipleInheritance, toClosure(transformMultipleInheritance), @[])

proc loadExperimentalTransforms*() =
  ## Load experimental/draft transforms (UNTESTED - do not use in production)
  ## These include union/intersection types, pattern matching, etc.
  globalTransformRegistry[tpUnionToVariant] = newTransformPass(tpUnionToVariant, toClosure(transformUnionToVariant), @[xnkUnionType])
  globalTransformRegistry[tpPatternMatching] = newTransformPass(tpPatternMatching, toClosure(transformPatternMatching), @[])

proc initGlobalTransformRegistry*() =
  ## Initialize the global transform registry with all available transforms
  ## This is called once at module load time.

  if globalTransformRegistry.len > 0:
    return  # Already initialized

  globalTransformRegistry = initTable[TransformPassID, TransformPass]()

  # Load tested, production-ready transforms
  loadExternalTransforms()

  # Load draft transforms (commented out by default - enable as they are tested)
  # loadGoTransforms()
  # loadPythonTransforms()
  # loadExperimentalTransforms()

# Initialize on module load
initGlobalTransformRegistry()
