## LoadTransforms - populate the shared transform registry

import common.transform_registry
import transforms/passes/enum_transformations
import core/xlangtypes
import transforms/passes/for_to_while
import transforms/passes/dowhile_to_while
import transforms/passes/ternary_to_if
import transforms/passes/interface_to_concept
import transforms/passes/property_to_procs
import transforms/passes/switch_fallthrough
import transforms/passes/null_coalesce
import transforms/passes/multiple_catch
import transforms/passes/destructuring
import transforms/passes/list_comprehension
import transforms/passes/normalize_simple
import transforms/passes/string_interpolation
import transforms/passes/with_to_defer
import transforms/passes/async_normalization
import transforms/passes/union_to_variant
import transforms/passes/linq_to_sequtils
import transforms/passes/operator_overload
import transforms/passes/pattern_matching
import transforms/passes/decorator_attribute
import transforms/passes/extension_methods
import transforms/passes/csharp_using
import transforms/passes/csharp_events
import transforms/passes/lambda_normalization
import transforms/passes/enum_transformations
import transforms/passes/safe_navigation
import transforms/passes/indexer_to_procs
import transforms/passes/generator_expressions
import transforms/passes/throw_expression
import transforms/passes/resource_to_defer
import transforms/passes/resource_to_try_finally
import transforms/passes/switch_expr_to_case
import transforms/passes/lock_to_with_lock
import transforms/passes/stackalloc_to_seq
import transforms/passes/conversion_op_to_proc
import transforms/passes/checked_to_block
import transforms/passes/fixed_to_block
import transforms/passes/local_function_to_proc
import transforms/passes/unsafe_to_nim_block
import transforms/passes/delegate_to_proc_type
import transforms/passes/nullable_to_option
import transforms/passes/add_self_parameter
import transforms/passes/normalize_operators
import types

proc loadTransforms*(verbose: bool = false) =
  if verbose:
    echo "DEBUG: Loading transform implementations into shared registry..."

  # Register transforms directly into the shared registry. Each line mirrors
  # the previous buildNimPassRegistry entries but registers into `transformRegistry`.
  registerTransform(tpNormalizeOperators, newTransformPass(tpNormalizeOperators, toClosure(normalizeOperators), @[]))

  registerTransform(tpForToWhile, newTransformPass(tpForToWhile, toClosure(transformForToWhile), @[xnkExternal_ForStmt]))
  registerTransform(tpDoWhileToWhile, newTransformPass(tpDoWhileToWhile, toClosure(transformDoWhileToWhile), @[xnkExternal_DoWhile]))
  registerTransform(tpTernaryToIf, newTransformPass(tpTernaryToIf, toClosure(transformTernaryToIf), @[xnkExternal_Ternary]))
  registerTransform(tpNimInterfaceToConcept, newTransformPass(tpNimInterfaceToConcept, toClosure(transformInterfaceToConcept), @[xnkExternal_Interface]))
  registerTransform(tpPropertyToProcs, newTransformPass(tpPropertyToProcs, toClosure(transformPropertyToProcs), @[xnkExternal_Property]))
  registerTransform(tpSwitchFallthrough, newTransformPass(tpSwitchFallthrough, toClosure(transformSwitchFallthrough), @[]))
  registerTransform(tpNullCoalesce, newTransformPass(tpNullCoalesce, toClosure(transformNullCoalesce), @[xnkExternal_NullCoalesce]))
  registerTransform(tpMultipleCatch, newTransformPass(tpMultipleCatch, toClosure(transformMultipleCatch), @[]))
  registerTransform(tpDestructuring, newTransformPass(tpDestructuring, toClosure(transformDestructuring), @[xnkExternal_Destructure]))
  registerTransform(tpListComprehension, newTransformPass(tpListComprehension, toClosure(transformListComprehension), @[xnkExternal_Comprehension]))
  registerTransform(tpStringInterpolation, newTransformPass(tpStringInterpolation, toClosure(transformStringInterpolation), @[xnkExternal_StringInterp]))
  registerTransform(tpNormalizeSimple, newTransformPass(tpNormalizeSimple, toClosure(transformNormalizeSimple), @[]))
  registerTransform(tpWithToDefer, newTransformPass(tpWithToDefer, toClosure(transformWithToDefer), @[xnkExternal_With]))
  registerTransform(tpAsyncNormalization, newTransformPass(tpAsyncNormalization, toClosure(transformAsyncNormalization), @[xnkExternal_Await]))
  registerTransform(tpUnionToVariant, newTransformPass(tpUnionToVariant, toClosure(transformUnionToVariant), @[xnkUnionType]))
  registerTransform(tpOperatorOverload, newTransformPass(tpOperatorOverload, toClosure(transformOperatorOverload), @[xnkExternal_Operator]))
  registerTransform(tpPatternMatching, newTransformPass(tpPatternMatching, toClosure(transformPatternMatching), @[]))
  registerTransform(tpDecoratorAttribute, newTransformPass(tpDecoratorAttribute, toClosure(transformDecoratorAttribute), @[xnkDecorator, xnkAttribute]))
  registerTransform(tpExtensionMethods, newTransformPass(tpExtensionMethods, toClosure(transformExtensionMethods), @[xnkExternal_ExtensionMethod]))
  registerTransform(tpGoErrorHandling, newTransformPass(tpGoErrorHandling, toClosure(transformGoErrorHandling), @[]))
  registerTransform(tpGoDefer, newTransformPass(tpGoDefer, toClosure(transformGoDefer), @[xnkDeferStmt]))
  registerTransform(tpCSharpUsing, newTransformPass(tpCSharpUsing, toClosure(transformCSharpUsing), @[xnkUsingStmt]))
  registerTransform(tpGoConcurrency, newTransformPass(tpGoConcurrency, toClosure(transformGoStatement), @[]))
  registerTransform(tpPythonGenerators, newTransformPass(tpPythonGenerators, toClosure(transformPythonGenerator), @[xnkExternal_Generator]))
  registerTransform(tpPythonTypeHints, newTransformPass(tpPythonTypeHints, toClosure(transformPythonTypeHints), @[]))
  registerTransform(tpGoPanicRecover, newTransformPass(tpGoPanicRecover, toClosure(transformGoPanicRecover), @[]))
  registerTransform(tpCSharpEvents, newTransformPass(tpCSharpEvents, toClosure(transformCSharpEvents), @[xnkExternal_Event]))
  registerTransform(tpLambdaNormalization, newTransformPass(tpLambdaNormalization, toClosure(transformLambdaNormalization), @[]))
  registerTransform(tpGoTypeAssertions, newTransformPass(tpGoTypeAssertions, toClosure(transformGoTypeAssertions), @[]))
  registerTransform(tpGoImplicitInterfaces, newTransformPass(tpGoImplicitInterfaces, toClosure(transformGoImplicitInterfaces), @[]))
  registerTransform(tpPythonMultipleInheritance, newTransformPass(tpPythonMultipleInheritance, toClosure(transformMultipleInheritance), @[]))
  registerTransform(tpSafeNavigation, newTransformPass(tpSafeNavigation, toClosure(transformSafeNavigation), @[xnkExternal_SafeNavigation]))
  registerTransform(tpGeneratorExpressions, newTransformPass(tpGeneratorExpressions, toClosure(transformGeneratorExpressions), @[xnkExternal_Generator]))
  registerTransform(tpThrowExpression, newTransformPass(tpThrowExpression, toClosure(transformThrowExpression), @[xnkExternal_ThrowExpr]))
  registerTransform(tpResourceToDefer, newTransformPass(tpResourceToDefer, toClosure(transformResourceToDefer), @[xnkExternal_Resource]))
  registerTransform(tpResourceToTryFinally, newTransformPass(tpResourceToTryFinally, toClosure(transformResourceToTryFinally), @[xnkExternal_Resource]))
  registerTransform(tpIndexerToProcs, newTransformPass(tpIndexerToProcs, toClosure(transformIndexerToProcs), @[xnkExternal_Indexer]))
  registerTransform(tpSwitchExprToCase, newTransformPass(tpSwitchExprToCase, toClosure(transformSwitchExprToCase), @[xnkExternal_SwitchExpr]))
  registerTransform(tpLockToWithLock, newTransformPass(tpLockToWithLock, toClosure(transformLockToWithLock), @[xnkExternal_Lock]))
  registerTransform(tpStackAllocToSeq, newTransformPass(tpStackAllocToSeq, toClosure(transformStackAllocToSeq), @[xnkExternal_StackAlloc]))
  registerTransform(tpConversionOpToProc, newTransformPass(tpConversionOpToProc, toClosure(transformConversionOpToProc), @[xnkExternal_ConversionOp]))
  registerTransform(tpCheckedToBlock, newTransformPass(tpCheckedToBlock, toClosure(transformCheckedToBlock), @[xnkExternal_Checked]))
  registerTransform(tpFixedToBlock, newTransformPass(tpFixedToBlock, toClosure(transformFixedToBlock), @[xnkExternal_Fixed]))
  registerTransform(tpLocalFunctionToProc, newTransformPass(tpLocalFunctionToProc, toClosure(transformLocalFunctionToProc), @[xnkExternal_LocalFunction]))
  registerTransform(tpUnsafeToNimBlock, newTransformPass(tpUnsafeToNimBlock, toClosure(transformUnsafeToNimBlock), @[xnkExternal_Unsafe]))
  registerTransform(tpDelegateToProcType, newTransformPass(tpDelegateToProcType, toClosure(transformDelegateToTypeAlias), @[xnkExternal_Delegate]))
  registerTransform(tpNullableToOption, newTransformPass(tpNullableToOption, toClosure(transformNullableToOption), @[xnkGenericType]))
  registerTransform(tpAddSelfParameter, newTransformPass(tpAddSelfParameter, toClosure(addSelfParameter), @[xnkClassDecl, xnkStructDecl]))

  if verbose:
    echo "DEBUG: Transform implementations registered: ", transformRegistry.len
