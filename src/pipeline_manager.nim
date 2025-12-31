## Pipeline Manager
##
## Orchestrates the entire transpilation pipeline from XLang JSON to Nim code.
## This is a higher-level manager than FixedPointTransformer - it coordinates
## all the steps: parsing, semantic analysis, transformations, and code generation.

import os
import sequtils, strutils
import core/xlangtypes
import backends/nim/my_nim_node
import backends/nim/naming_conventions
import backends/nim/nim_constants
import transforms/fixed_point_transformer
import transforms/nim_passes
import error_collector
import semantic/semantic_analysis
import main_steps

type
  PipelineConfig* = object
    ## Configuration for the transpilation pipeline
    inputFile*: string
    outputDir*: string
    inputRoot*: string
    verbose*: bool
    skipTransforms*: bool
    outputJson*: bool
    useStdout*: bool
    sameDir*: bool

  PipelineResult* = object
    ## Result of running the pipeline
    success*: bool
    nimCode*: string
    nimAst*: MyNimNode
    xlangAst*: XLangNode
    errors*: seq[string]

  TranspilationPipeline* = ref object
    ## Main pipeline orchestrator
    config*: PipelineConfig
    errorCollector*: ErrorCollector
    transformManager*: FixedPointTransformer
    infiniteLoopFiles*: seq[tuple[file: string, iterations: int, kinds: seq[XLangNodeKind]]]

proc newTranspilationPipeline*(config: PipelineConfig): TranspilationPipeline =
  ## Create a new transpilation pipeline
  result = TranspilationPipeline(
    config: config,
    errorCollector: newErrorCollector(),
    infiniteLoopFiles: @[]
  )

  # Create and register transform passes if not skipping
  if not config.skipTransforms:
    result.transformManager = newFixedPointTransformer()
    registerNimPasses(result.transformManager, config.verbose)
    result.transformManager.errorCollector = result.errorCollector

proc run*(pipeline: TranspilationPipeline): PipelineResult =
  ## Run the complete transpilation pipeline for a single file
  result = PipelineResult(success: false, errors: @[])
  let inputFile = pipeline.config.inputFile
  let verbose = pipeline.config.verbose

  if verbose:
    echo "\n=== Processing: ", inputFile, " ==="

  # Step 1: Parse JSON to XLang AST
  var xlangAst: XLangNode
  try:
    xlangAst = stepParseXLang(inputFile, pipeline.errorCollector, verbose)
  except Exception as e:
    result.errors.add("Failed to parse input file: " & e.msg)
    return

  # Step 1.5: Run semantic analysis
  var semanticInfo: SemanticInfo
  try:
    semanticInfo = stepSemanticAnalysis(xlangAst, verbose)
  except Exception as e:
    result.errors.add("Semantic analysis failed: " & e.msg)
    return

  # Step 1.7: Normalize enum member access
  try:
    stepEnumNormalization(xlangAst, verbose, semanticInfo)
  except Exception as e:
    result.errors.add("Enum normalization failed: " & e.msg)
    return

  # Step 2: Apply transformation passes
  if not pipeline.config.skipTransforms:
    try:
      stepTransformPasses(xlangAst, semanticInfo, pipeline.transformManager,
                         inputFile, pipeline.infiniteLoopFiles, verbose)
    except Exception as e:
      result.errors.add("Transformation pipeline failed: " & e.msg)
      return

  # Step 2.5: Apply identifier sanitization
  try:
    stepSanitizeIdentifiers(xlangAst, verbose)
  except Exception as e:
    result.errors.add("Identifier sanitization failed: " & e.msg)
    return

  # Step 2.6: Fix generic type syntax
  try:
    stepFixGenericTypes(xlangAst, verbose)
  except Exception as e:
    result.errors.add("Generic type fix failed: " & e.msg)
    return

  # Step 2.7: Apply primitive type mapping
  try:
    stepMapPrimitiveTypes(xlangAst, verbose)
  except Exception as e:
    result.errors.add("Primitive type mapping failed: " & e.msg)
    return

  # Step 3: Convert XLang AST to Nim AST
  var nimAst: MyNimNode
  try:
    nimAst = stepConvertToNim(xlangAst, semanticInfo, inputFile, verbose)
  except Exception as e:
    result.errors.add("Failed to convert XLang to Nim AST: " & e.msg)
    return

  # Step 4: Generate Nim code from AST
  var nimCode: string
  try:
    nimCode = stepGenerateCode(nimAst, verbose)
  except Exception as e:
    result.errors.add("Failed to generate Nim code: " & e.msg)
    return

  # Step 5: Write outputs
  try:
    stepWriteOutputs(nimCode, nimAst, xlangAst, inputFile,
                    pipeline.config.outputDir, pipeline.config.inputRoot,
                    pipeline.config.useStdout, pipeline.config.outputJson,
                    pipeline.config.sameDir, verbose)
  except Exception as e:
    result.errors.add("Failed to write output: " & e.msg)
    return

  # Success!
  result.success = true
  result.nimCode = nimCode
  result.nimAst = nimAst
  result.xlangAst = xlangAst

proc reportResults*(pipeline: TranspilationPipeline) =
  ## Report pipeline results (warnings, errors, infinite loops)

  # Report infinite loop files
  if pipeline.infiniteLoopFiles.len > 0:
    echo ""
    echo "=== INFINITE LOOP REPORT ==="
    echo "Files that reached max iterations (", pipeline.transformManager.maxIterations, "):"
    for entry in pipeline.infiniteLoopFiles:
      echo "  - ", entry.file
      echo "    Iterations: ", entry.iterations
      if entry.kinds.len > 0:
        echo "    Stuck on kinds: ", entry.kinds.mapIt($it).join(", ")
    echo ""
    echo "Total files with infinite loops: ", pipeline.infiniteLoopFiles.len
    echo ""

  # Report errors and warnings
  if pipeline.errorCollector.hasWarnings() or pipeline.errorCollector.hasErrors():
    pipeline.errorCollector.reportSummary()

  if not pipeline.errorCollector.hasErrors():
    echo "No errors encountered."

  if pipeline.infiniteLoopFiles.len == 0:
    echo "No infinite loops detected in transform passes"
