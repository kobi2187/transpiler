## Pipeline Manager
##
## Orchestrates the entire transpilation pipeline from XLang JSON to output code.
## This is a higher-level manager than FixedPointTransformer - it coordinates
## all the steps: parsing, semantic analysis, transformations, and code generation.
##
## The pipeline is now backend-agnostic - it works with any backend that
## implements the BackendOps concept.

import os
import sequtils, strutils
import std/tables
import core/xlangtypes
import transforms/fixed_point_transformer
import transforms/transform_registry
import transforms/types
import error_collector
import semantic/semantic_analysis
import main_steps
import backends/backend_types

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
    targetLang*: OutputLanguage  # Enum for type safety

  PipelineResult* = object
    ## Result of running the pipeline
    success*: bool
    generatedCode*: string
    xlangAst*: XLangNode
    errors*: seq[string]

  TranspilationPipeline*[B: BackendOps] = ref object
    ## Main pipeline orchestrator - generic over backend type
    config*: PipelineConfig
    errorCollector*: ErrorCollector
    transformManager*: FixedPointTransformer
    backend*: B  # Generic backend implementing BackendOps concept
    infiniteLoopFiles*: seq[tuple[file: string, iterations: int, kinds: seq[XLangNodeKind]]]

proc newTranspilationPipeline*[B: BackendOps](config: PipelineConfig, backend: B): TranspilationPipeline[B] =
  ## Create a new transpilation pipeline with the given backend
  result = TranspilationPipeline[B](
    config: config,
    errorCollector: newErrorCollector(),
    backend: backend,
    infiniteLoopFiles: @[]
  )

  # Create and register transform passes if not skipping
  if not config.skipTransforms:
    result.transformManager = newFixedPointTransformer()
    result.transformManager.errorCollector = result.errorCollector

    # Get transform IDs from backend
    let transformIDs = backend.selectTransformIDs()

    # Load transforms from global registry
    var transforms: seq[TransformPass] = @[]
    for id in transformIDs:
      if globalTransformRegistry.hasKey(id):
        transforms.add(globalTransformRegistry[id])

    result.transformManager.addTransforms(transforms)

    if config.verbose:
      echo "DEBUG: Registered ", transforms.len, " transform passes for ", config.targetLang

proc run*[B: BackendOps](pipeline: TranspilationPipeline[B]): PipelineResult =
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

  # Step 1.5: Run semantic analysis using backend-specific keywords
  var semanticInfo: SemanticInfo
  try:
    let keywords = pipeline.backend.getKeywords()
    if verbose:
      echo "DEBUG: Running semantic analysis with ", keywords.len, " backend keywords..."
    semanticInfo = analyzeProgram(xlangAst, keywords)
    if verbose:
      echo "✓ Semantic analysis complete"
      echo "  - Symbols: ", semanticInfo.allSymbols.len
      echo "  - Scopes: ", semanticInfo.allScopes.len
      echo "  - Renames: ", semanticInfo.renames.len
      if semanticInfo.warnings.len > 0:
        echo "  - Warnings: ", semanticInfo.warnings.len
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

  # Step 2.5: Apply backend-specific identifier sanitization
  try:
    if verbose:
      echo "DEBUG: Applying backend-specific identifier sanitization..."
    xlangAst = pipeline.backend.sanitizeIdentifiers(xlangAst)
    if verbose:
      echo "✓ Identifier sanitization applied"
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

  # Step 3: Convert XLang AST to backend-specific AST and generate code
  var code: string
  try:
    let backendAST = pipeline.backend.convertFromXLang(xlangAst, semanticInfo, inputFile, verbose)
    code = pipeline.backend.generateCode(backendAST, verbose)

    # Step 5: Write outputs
    let outputCtx = BackendContext(
      inputFile: inputFile,
      outputDir: pipeline.config.outputDir,
      inputRoot: pipeline.config.inputRoot,
      useStdout: pipeline.config.useStdout,
      outputJson: pipeline.config.outputJson,
      sameDir: pipeline.config.sameDir,
      verbose: verbose
    )
    pipeline.backend.writeOutput(code, backendAST, xlangAst, outputCtx)
  except Exception as e:
    result.errors.add("Code generation failed: " & e.msg)
    return

  # Success!
  result.success = true
  result.generatedCode = code
  result.xlangAst = xlangAst

proc reportResults*[B: BackendOps](pipeline: TranspilationPipeline[B]) =
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
