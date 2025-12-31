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
import transforms/passes/enum_transformations
import error_collector
import passes/nim_identifier_sanitization
import passes/primitive_type_mapping
import passes/fix_generic_type_syntax
import semantic/semantic_analysis

proc stepParseXLang*(inputFile: string, errorCollector: ErrorCollector, verbose: bool): XLangNode =
  ## Step 1: Parse JSON to XLang AST
  if verbose:
    echo "DEBUG: About to parse xljs file..."
  result = parseXLangJson(inputFile)
  if verbose:
    echo "DEBUG: XLang AST kind: ", result.kind
    echo "DEBUG: XLang AST has ", (if result.kind == xnkFile: $result.moduleDecls.len else: "N/A"), " module declarations"
    echo "✓ XLang AST created successfully"

proc stepSemanticAnalysis*(xlangAst: XLangNode, verbose: bool): SemanticInfo =
  ## Step 1.5: Run semantic analysis
  if verbose:
    echo "DEBUG: Running semantic analysis..."
  result = analyzeProgram(xlangAst, NimKeywords)
  if verbose:
    echo "✓ Semantic analysis complete"
    echo "  - Symbols: ", result.allSymbols.len
    echo "  - Scopes: ", result.allScopes.len
    echo "  - Renames: ", result.renames.len
    if result.warnings.len > 0:
      echo "  - Warnings: ", result.warnings.len

proc stepEnumNormalization*(xlangAst: var XLangNode, verbose: bool, semanticInfo: var SemanticInfo) =
  ## Step 1.7: Normalize enum member access
  if verbose:
    echo "DEBUG: Running enum normalization..."
  xlangAst = transformEnumNormalization(xlangAst, semanticInfo)
  if verbose:
    echo "✓ Enum normalization complete"

proc stepTransformPasses*(xlangAst: var XLangNode, semanticInfo: var SemanticInfo, passManager: FixedPointTransformer,
                        inputFile: string, infiniteLoopFiles: var seq[tuple[file: string, iterations: int, kinds: seq[XLangNodeKind]]],
                        verbose: bool) =
  ## Step 2: Apply transformation passes
  if verbose:
    echo "DEBUG: Running transformation passes..."
    echo "DEBUG: About to run passes on AST..."
  xlangAst = passManager.run(xlangAst, verbose, semanticInfo)
  if passManager.result.maxIterationsReached:
    infiniteLoopFiles.add((
      file: inputFile,
      iterations: passManager.result.iterations,
      kinds: passManager.result.loopKinds
    ))
    echo "WARNING: Max iterations reached for: ", inputFile
  elif passManager.result.loopWarning and verbose:
    echo "WARNING: Potential infinite loop detected (", passManager.result.iterations, " iterations)"
  if verbose:
    echo "DEBUG: After transformations, AST kind: ", xlangAst.kind
    echo "✓ Transformations applied successfully"

proc stepSanitizeIdentifiers*(xlangAst: var XLangNode, verbose: bool) =
  ## Step 2.5: Apply identifier sanitization
  if verbose:
    echo "DEBUG: Applying Nim identifier sanitization..."
  xlangAst = applyNimIdentifierSanitization(xlangAst)
  if verbose:
    echo "✓ Identifier sanitization applied"

proc stepFixGenericTypes*(xlangAst: var XLangNode, verbose: bool) =
  ## Step 2.6: Fix generic type syntax
  if verbose:
    echo "DEBUG: Fixing generic type syntax..."
  xlangAst = applyGenericTypeFix(xlangAst)
  if verbose:
    echo "✓ Generic type syntax fixed"

proc stepMapPrimitiveTypes*(xlangAst: var XLangNode, verbose: bool) =
  ## Step 2.7: Apply primitive type mapping
  if verbose:
    echo "DEBUG: Applying primitive type mapping..."
  xlangAst = applyPrimitiveTypeMapping(xlangAst)
  if verbose:
    echo "✓ Primitive type mapping applied"

proc stepConvertToNim*(xlangAst: XLangNode, semanticInfo: SemanticInfo, inputFile: string, verbose: bool): MyNimNode =
  ## Step 3: Convert XLang AST to Nim AST
  if verbose:
    echo "DEBUG: About to convert XLang AST to Nim AST..."

  # Count classes from semantic info to determine if we need prefixes
  var classCount = 0
  for sym in semanticInfo.allSymbols:
    if sym.kind == skType and not sym.declNode.isNil and sym.declNode.kind == xnkClassDecl:
      inc classCount

  if verbose and classCount > 1:
    echo "DEBUG: Found ", classCount, " classes - will use prefixes for static methods"

  let ctx = newContext()
  ctx.currentFile = inputFile
  ctx.semanticInfo = semanticInfo
  ctx.classCount = classCount
  if xlangAst.kind == xnkFile and xlangAst.sourceLang != "":
    ctx.inputLang = xlangAst.sourceLang
    if verbose:
      echo "DEBUG: Source language: ", ctx.inputLang
  result = convertToNimAST(xlangAst, ctx)
  if verbose:
    echo "DEBUG: Nim AST root kind: ", result.kind
    echo "DEBUG: Nim AST has ", result.sons.len, " sons"
    echo "✓ Nim AST created successfully"

proc stepGenerateCode*(nimAst: MyNimNode, verbose: bool): string =
  ## Step 4: Generate Nim code from AST
  if verbose:
    echo "DEBUG: About to generate Nim code from AST..."
  result = nimAst.toNimCode()
  if verbose:
    echo "DEBUG: Generated Nim code length: ", result.len, " characters"
    echo "✓ Nim code generated successfully"

proc stepWriteOutputs*(nimCode: string, nimAst: MyNimNode, xlangAst: XLangNode, inputFile, outputDir, inputRoot: string,
                     useStdout, outputJson, sameDir, verbose: bool) =
  ## Step 5: Write outputs
  if useStdout:
    stdout.write(nimCode)
  else:
    let nimOutputFile = if sameDir:
      # Write to same directory as input file, converting filename to snake_case
      let inputDir = inputFile.parentDir()
      let inputBaseName = inputFile.splitFile().name
      let snakeBaseName = pascalToSnake(inputBaseName)
      inputDir / (snakeBaseName & ".nim")
    else:
      # Write to transpiler_output with proper structure
      let relativeOutputPath = getOutputFileName(xlangAst, inputFile, ".nim", inputRoot)
      outputDir / relativeOutputPath

    let parentDir = nimOutputFile.parentDir()
    if parentDir != "" and not dirExists(parentDir):
      createDir(parentDir)
      if verbose:
        echo "DEBUG: Created directory: ", parentDir
    if verbose:
      echo "DEBUG: About to write .nim file to: ", nimOutputFile
    writeFile(nimOutputFile, nimCode)
    if verbose:
      echo "✓ Nim code written to: ", nimOutputFile

  if outputJson:
    let nimJsonFile = inputFile.changeFileExt(".nimjs")
    if verbose:
      echo "DEBUG: About to serialize Nim AST to JSON using %* operator..."
    let jsonNode = %nimAst
    if verbose:
      echo "DEBUG: JSON node created, about to pretty-print..."
    let jsonContent = pretty(jsonNode)
    if verbose:
      echo "DEBUG: JSON content length: ", jsonContent.len, " characters"
      echo "DEBUG: About to write .nimjs file to: ", nimJsonFile
    writeFile(nimJsonFile, jsonContent)
    if verbose:
      echo "✓ Nim AST JSON written to: ", nimJsonFile
      echo "DEBUG: First 200 chars of nimjs: ", jsonContent[0..<min(200, jsonContent.len)]
