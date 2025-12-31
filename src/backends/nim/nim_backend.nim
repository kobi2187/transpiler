## Nim Backend
##
## All Nim-specific code generation logic.
## Implements the BackendOps concept from backend_types.

import os
import std/json
import core/xlangtypes
import semantic/semantic_analysis
import transforms/types
import my_nim_node
import xlangtonim
import astprinter
import nim_constants
import naming_conventions
import ../backend_types
import ../../passes/nim_identifier_sanitization

# Re-export Nim transform selection
import ../../transforms/nim_passes
export nimDefaultPassIDs

type
  NimBackend* = object
    ## Nim backend state (currently empty, but allows for future config)

proc getFileExtension*(backend: NimBackend): string =
  ## Get output file extension for Nim
  ".nim"

proc getKeywords*(backend: NimBackend): seq[string] =
  ## Get Nim language keywords for identifier conflict detection
  NimKeywords

proc selectTransformIDs*(backend: NimBackend): seq[TransformPassID] =
  ## Select which transforms the Nim backend needs
  nimDefaultPassIDs

proc sanitizeIdentifiers*(backend: NimBackend, ast: XLangNode): XLangNode =
  ## Apply Nim-specific identifier sanitization
  applyNimIdentifierSanitization(ast)

proc convertFromXLang*(backend: NimBackend, ast: XLangNode,
                      semanticInfo: SemanticInfo, inputFile: string,
                      verbose: bool): MyNimNode =
  ## Convert XLang AST to Nim AST
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
  if ast.kind == xnkFile and ast.sourceLang != "":
    ctx.inputLang = ast.sourceLang
    if verbose:
      echo "DEBUG: Source language: ", ctx.inputLang

  result = convertToNimAST(ast, ctx)

  if verbose:
    echo "DEBUG: Nim AST root kind: ", result.kind
    echo "DEBUG: Nim AST has ", result.sons.len, " sons"
    echo "✓ Nim AST created successfully"

proc generateCode*(backend: NimBackend, nimAst: MyNimNode, verbose: bool): string =
  ## Generate Nim code from Nim AST
  if verbose:
    echo "DEBUG: About to generate Nim code from AST..."
  result = nimAst.toNimCode()
  if verbose:
    echo "DEBUG: Generated Nim code length: ", result.len, " characters"
    echo "✓ Nim code generated successfully"

proc writeOutput*(backend: NimBackend, nimCode: string, nimAst: MyNimNode,
                 xlangAst: XLangNode, ctx: BackendContext) =
  ## Write Nim output files (.nim and optionally .nimjs)
  if ctx.useStdout:
    stdout.write(nimCode)
    return

  # Determine output file path
  let nimOutputFile = if ctx.sameDir:
    # Write to same directory as input file, converting filename to snake_case
    let inputDir = ctx.inputFile.parentDir()
    let inputBaseName = ctx.inputFile.splitFile().name
    let snakeBaseName = pascalToSnake(inputBaseName)
    inputDir / (snakeBaseName & ".nim")
  else:
    # Write to transpiler_output with proper structure
    let relativeOutputPath = getOutputFileName(xlangAst, ctx.inputFile, ".nim", ctx.inputRoot)
    ctx.outputDir / relativeOutputPath

  # Create directory if needed
  let parentDir = nimOutputFile.parentDir()
  if parentDir != "" and not dirExists(parentDir):
    createDir(parentDir)
    if ctx.verbose:
      echo "DEBUG: Created directory: ", parentDir

  # Write main Nim output
  if ctx.verbose:
    echo "DEBUG: About to write .nim file to: ", nimOutputFile
  writeFile(nimOutputFile, nimCode)
  if ctx.verbose:
    echo "✓ Nim code written to: ", nimOutputFile

  # Write JSON AST if requested
  if ctx.outputJson:
    let nimJsonFile = ctx.inputFile.changeFileExt(".nimjs")
    if ctx.verbose:
      echo "DEBUG: About to serialize Nim AST to JSON using %* operator..."
    let jsonNode = %nimAst
    if ctx.verbose:
      echo "DEBUG: JSON node created, about to pretty-print..."
    let jsonContent = pretty(jsonNode)
    if ctx.verbose:
      echo "DEBUG: JSON content length: ", jsonContent.len, " characters"
      echo "DEBUG: About to write .nimjs file to: ", nimJsonFile
    writeFile(nimJsonFile, jsonContent)
    if ctx.verbose:
      echo "✓ Nim AST JSON written to: ", nimJsonFile
      echo "DEBUG: First 200 chars of nimjs: ", jsonContent[0..<min(200, jsonContent.len)]

# Helper to create a Nim backend instance
proc newNimBackend*(): NimBackend =
  NimBackend()
