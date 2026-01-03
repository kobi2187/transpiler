## Nim Backend - Transform Selection
##
## Selects which lowering transforms the Nim backend needs.
## The global transform registry contains all available transforms;
## this module simply chooses the appropriate ones for Nim output.

# import core/xlangtypes
import fixed_point_transformer
import transform_registry
import types
import std/tables

# Nim default transforms - only tested, production-ready transforms
# These are the external/lowering transforms loaded by loadExternalTransforms()
const nimDefaultPassIDs* = @[
  # Normalization (always run first)
  tpNormalizeOperators,
  tpNormalizeSimple,

  # Core structural transforms
  tpForToWhile,
  tpDoWhileToWhile,
  tpTernaryToIf,
  tpSwitchExprToCase,
  tpSwitchFallthrough,

  # OOP feature lowering
  tpNimInterfaceToConcept,
  tpPropertyToProcs,
  tpIndexerToProcs,
  tpExtensionMethods,

  # Operator lowering
  tpOperatorOverload,
  tpConversionOpToProc,

  # Null safety
  tpNullCoalesce,
  tpSafeNavigation,

  # Error handling
  tpMultipleCatch,
  tpThrowExpression,

  # Collections
  tpDestructuring,
  tpListComprehension,
  tpGeneratorExpressions,

  # String processing
  tpStringInterpolation,

  # Resource management
  tpResourceToDefer,
  # tpResourceToTryFinally,
  tpLockToWithLock,

  # Async/await
  tpAsyncNormalization,

  # Attributes/decorators
  tpDecoratorAttribute,

  # Lambda normalization
  tpLambdaNormalization,

  # C#-specific lowering
  tpCSharpUsing,
  tpCSharpEvents,
  tpStackallocToSeq,
  tpCheckedToBlock,
  tpFixedToBlock,
  tpLocalFunctionToProc,
  tpUnsafeToNimBlock,
  tpDelegateToProcType
]

proc selectTransformsForNim*(): seq[TransformPass] =
  ## Select transforms needed for Nim backend
  ## Uses the global transform registry
  result = @[]
  for id in nimDefaultPassIDs:
    if globalTransformRegistry.hasKey(id):
      result.add(globalTransformRegistry[id])

proc registerNimPasses*(transformer: FixedPointTransformer, verbose: bool = false) =
  ## Register all transformation passes for Nim target language
  let transforms = selectTransformsForNim()

  if verbose:
    echo "DEBUG: Registering ", transforms.len, " transform passes for Nim backend"

  transformer.addTransforms(transforms)

  if verbose:
    echo "DEBUG: Successfully registered ", transforms.len, " passes"
