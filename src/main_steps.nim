import os
import std/json
import std/tables
import core/xlangtypes
import core/jsontoxlangtypes
import backends/nim/xlangtonim
import backends/nim/my_nim_node
import backends/nim/astprinter
import backends/nim/naming_conventions
import backends/nim/nim_constants
import transforms/fixed_point_transformer
import transforms/transform_context
import transforms/passes/enum_transformations
import error_collector
import passes/nim_identifier_sanitization
import passes/primitive_type_mapping
import passes/fix_generic_type_syntax
import semantic/semantic_analysis

# =============================================================================
# Parse Step Helpers
# =============================================================================

proc logParseStart(verbose: bool) =
  if verbose:
    echo "DEBUG: About to parse xljs file..."

proc logParseResult(ast: XLangNode, verbose: bool) =
  if verbose:
    echo "DEBUG: XLang AST kind: ", ast.kind
    let declCount = if ast.kind == xnkFile: $ast.moduleDecls.len else: "N/A"
    echo "DEBUG: XLang AST has ", declCount, " module declarations"
    echo "✓ XLang AST created successfully"

proc stepParseXLang*(inputFile: string, errorCollector: ErrorCollector, verbose: bool): XLangNode =
  ## Step 1: Parse JSON to XLang AST
  logParseStart(verbose)
  result = parseXLangJson(inputFile)
  logParseResult(result, verbose)

# =============================================================================
# Semantic Analysis Step Helpers
# =============================================================================

proc logSemanticStart(verbose: bool) =
  if verbose:
    echo "DEBUG: Running semantic analysis..."

proc logSemanticResult(info: SemanticInfo, verbose: bool) =
  if verbose:
    echo "✓ Semantic analysis complete"
    echo "  - Symbols: ", info.allSymbols.len
    echo "  - Scopes: ", info.allScopes.len
    echo "  - Renames: ", info.renames.len
    if info.warnings.len > 0:
      echo "  - Warnings: ", info.warnings.len

proc stepSemanticAnalysis*(xlangAst: XLangNode, verbose: bool): SemanticInfo =
  ## Step 1.5: Run semantic analysis
  logSemanticStart(verbose)
  result = analyzeProgram(xlangAst, NimKeywords)
  logSemanticResult(result, verbose)

# =============================================================================
# Enum Normalization Step Helpers
# =============================================================================

proc logEnumStart(verbose: bool) =
  if verbose:
    echo "DEBUG: Running enum normalization..."

proc logEnumComplete(verbose: bool) =
  if verbose:
    echo "✓ Enum normalization complete"

proc extractSourceLang(ast: XLangNode): string =
  ## Extract source language from AST if available
  if ast.kind == xnkFile and ast.sourceLang != "":
    ast.sourceLang
  else:
    ""

proc createEnumContext(semanticInfo: SemanticInfo, errorCollector: ErrorCollector, sourceLang: string, verbose: bool): TransformContext =
  ## Create transform context for enum normalization
  newTransformContext(
    semanticInfo = semanticInfo,
    errorCollector = errorCollector,
    targetLang = "",
    sourceLang = sourceLang,
    currentFile = "",
    verbose = verbose
  )

proc stepEnumNormalization*(xlangAst: var XLangNode, verbose: bool, semanticInfo: SemanticInfo, errorCollector: ErrorCollector) =
  ## Step 1.7: Normalize enum member access
  logEnumStart(verbose)
  let sourceLang = extractSourceLang(xlangAst)
  let ctx = createEnumContext(semanticInfo, errorCollector, sourceLang, verbose)
  xlangAst = transformEnumNormalization(xlangAst, ctx)
  logEnumComplete(verbose)

# =============================================================================
# Transform Passes Step Helpers
# =============================================================================

proc logTransformStart(verbose: bool) =
  if verbose:
    echo "DEBUG: Running transformation passes..."
    echo "DEBUG: About to run passes on AST..."

proc logTransformResult(ast: XLangNode, verbose: bool) =
  if verbose:
    echo "DEBUG: After transformations, AST kind: ", ast.kind
    echo "✓ Transformations applied successfully"

proc logTransformAuditLog(ctx: TransformContext, verbose: bool) =
  ## Display the transform audit log if there are entries and verbose mode
  let log = ctx.getTransformLog()
  if log.len > 0 and verbose:
    echo ctx.formatTransformLog()

proc logTransformWarning(iterations: int, verbose: bool) =
  if verbose:
    echo "WARNING: Potential infinite loop detected (", iterations, " iterations)"

proc createTransformContext(semanticInfo: SemanticInfo, errorCollector: ErrorCollector, targetLang, sourceLang, inputFile: string, verbose: bool): TransformContext =
  ## Create transform context for transform passes
  newTransformContext(
    semanticInfo = semanticInfo,
    errorCollector = errorCollector,
    targetLang = targetLang,
    sourceLang = sourceLang,
    currentFile = inputFile,
    verbose = verbose
  )

proc recordInfiniteLoop(infiniteLoopFiles: var seq[tuple[file: string, iterations: int, kinds: seq[XLangNodeKind]]], inputFile: string, result: FixedPointResult) =
  ## Record an infinite loop occurrence
  infiniteLoopFiles.add((
    file: inputFile,
    iterations: result.iterations,
    kinds: result.loopKinds
  ))
  echo "WARNING: Max iterations reached for: ", inputFile

proc stepTransformPasses*(xlangAst: var XLangNode, semanticInfo: SemanticInfo, passManager: FixedPointTransformer,
                        inputFile: string, targetLang: string,
                        infiniteLoopFiles: var seq[tuple[file: string, iterations: int, kinds: seq[XLangNodeKind]]],
                        verbose: bool) =
  ## Step 2: Apply transformation passes
  logTransformStart(verbose)
  
  let sourceLang = extractSourceLang(xlangAst)
  let ctx = createTransformContext(semanticInfo, passManager.errorCollector, targetLang, sourceLang, inputFile, verbose)
  
  # Build node index for parent navigation (needed by property transforms)
  ctx.buildNodeIndex(xlangAst)
  
  xlangAst = passManager.run(xlangAst, verbose, ctx)

  if passManager.result.maxIterationsReached:
    recordInfiniteLoop(infiniteLoopFiles, inputFile, passManager.result)
  elif passManager.result.loopWarning:
    logTransformWarning(passManager.result.iterations, verbose)

  logTransformResult(xlangAst, verbose)
  logTransformAuditLog(ctx, verbose)

# =============================================================================
# Sanitization Step Helpers
# =============================================================================

proc logSanitizeStart(verbose: bool) =
  if verbose:
    echo "DEBUG: Applying Nim identifier sanitization..."

proc logSanitizeComplete(verbose: bool) =
  if verbose:
    echo "✓ Identifier sanitization applied"

proc stepSanitizeIdentifiers*(xlangAst: var XLangNode, verbose: bool) =
  ## Step 2.5: Apply identifier sanitization
  logSanitizeStart(verbose)
  xlangAst = applyNimIdentifierSanitization(xlangAst)
  logSanitizeComplete(verbose)

# =============================================================================
# Generic Type Fix Step Helpers
# =============================================================================

proc logGenericFixStart(verbose: bool) =
  if verbose:
    echo "DEBUG: Fixing generic type syntax..."

proc logGenericFixComplete(verbose: bool) =
  if verbose:
    echo "✓ Generic type syntax fixed"

proc stepFixGenericTypes*(xlangAst: var XLangNode, verbose: bool) =
  ## Step 2.6: Fix generic type syntax
  logGenericFixStart(verbose)
  xlangAst = applyGenericTypeFix(xlangAst)
  logGenericFixComplete(verbose)

# =============================================================================
# Primitive Type Mapping Step Helpers
# =============================================================================

proc logPrimitiveMapStart(verbose: bool) =
  if verbose:
    echo "DEBUG: Applying primitive type mapping..."

proc logPrimitiveMapComplete(verbose: bool) =
  if verbose:
    echo "✓ Primitive type mapping applied"

proc stepMapPrimitiveTypes*(xlangAst: var XLangNode, verbose: bool) =
  ## Step 2.7: Apply primitive type mapping
  logPrimitiveMapStart(verbose)
  xlangAst = applyPrimitiveTypeMapping(xlangAst)
  logPrimitiveMapComplete(verbose)
