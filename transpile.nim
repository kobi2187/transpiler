## Transpiler Pipeline
## Runs the complete transpilation process from source code to Nim
##
## Usage: transpile <input_file_or_folder> <language>
## Languages: python, go, csharp, java, typescript, d, crystal, haxe

import os, osproc, strutils, json, sequtils, tables, times

type
  Language = enum
    langPython = "python"
    langGo = "go"
    langCSharp = "csharp"
    langJava = "java"
    langTypeScript = "typescript"
    langD = "d"
    langCrystal = "crystal"
    langHaxe = "haxe"

  ParserConfig = object
    parserCmd: string
    parserScript: string
    extension: string
    converterBinary: string
    isRuntime: bool  # true for interpreted languages (Python, TypeScript, etc.)

const
  ParserConfigs = {
    langPython: ParserConfig(
      parserCmd: "python3",
      parserScript: "src/parsers/python/python_to_xlang.py",
      extension: ".py",
      converterBinary: "src/parsers/python/python_json_to_xlang",
      isRuntime: true
    ),
    langGo: ParserConfig(
      parserCmd: "go",
      parserScript: "run src/parsers/go/go_to_xlang.go",
      extension: ".go",
      converterBinary: "src/parsers/go/go_json_to_xlang",
      isRuntime: false
    ),
    langCSharp: ParserConfig(
      parserCmd: "dotnet",
      parserScript: "run --project src/parsers/csharp/csharp_to_xlang.csproj --",
      extension: ".cs",
      converterBinary: "src/parsers/csharp/csharp_json_to_xlang",
      isRuntime: false
    ),
    langJava: ParserConfig(
      parserCmd: "java",
      parserScript: "-jar src/parsers/java/java-to-xlang.jar",
      extension: ".java",
      converterBinary: "src/parsers/java/java_json_to_xlang",
      isRuntime: false
    ),
    langTypeScript: ParserConfig(
      parserCmd: "ts-node",
      parserScript: "src/parsers/typescript/typescript_to_xlang.ts",
      extension: ".ts",
      converterBinary: "src/parsers/typescript/typescript_json_to_xlang",
      isRuntime: true
    ),
    langD: ParserConfig(
      parserCmd: "dmd",
      parserScript: "-run src/parsers/d/d_to_xlang.d",
      extension: ".d",
      converterBinary: "src/parsers/d/d_json_to_xlang",
      isRuntime: false
    ),
    langCrystal: ParserConfig(
      parserCmd: "crystal",
      parserScript: "run src/parsers/crystal/crystal_to_xlang.cr --",
      extension: ".cr",
      converterBinary: "src/parsers/crystal/crystal_json_to_xlang",
      isRuntime: false
    ),
    langHaxe: ParserConfig(
      parserCmd: "haxe",
      parserScript: "--run HaxeToXLangParser",
      extension: ".hx",
      converterBinary: "src/parsers/haxe/haxe_json_to_xlang",
      isRuntime: false
    )
  }.toTable

proc parseLanguage(langStr: string): Language =
  case langStr.toLowerAscii()
  of "python", "py": langPython
  of "go", "golang": langGo
  of "csharp", "cs", "c#": langCSharp
  of "java": langJava
  of "typescript", "ts": langTypeScript
  of "d", "dlang": langD
  of "crystal", "cr": langCrystal
  of "haxe", "hx": langHaxe
  else:
    raise newException(ValueError, "Unsupported language: " & langStr)

proc compileConverter(converterPath: string): bool =
  ## Compile the converter if not already compiled
  let converterNim = converterPath & ".nim"
  if not fileExists(converterNim):
    echo "Error: Converter source not found: ", converterNim
    return false

  # Check if binary exists and is newer than source
  if fileExists(converterPath):
    let binaryTime = getLastModificationTime(converterPath)
    let sourceTime = getLastModificationTime(converterNim)
    if binaryTime >= sourceTime:
      return true

  echo "Compiling converter: ", converterPath
  let exitCode = execCmd("nim c -d:release " & converterNim)
  return exitCode == 0

proc runParser(config: ParserConfig, sourceFile: string): tuple[success: bool, json: string] =
  ## Run the language parser on source file
  echo "  [1/4] Parsing ", sourceFile, " with ", config.parserCmd

  let cmd = config.parserCmd & " " & config.parserScript & " " & quoteShell(sourceFile)
  let (output, exitCode) = execCmdEx(cmd)

  if exitCode != 0:
    echo "Parser failed with exit code ", exitCode
    echo "Output: ", output
    return (false, "")

  return (true, output)

proc runConverter(converterBinary: string, nativeJson: string): tuple[success: bool, json: string] =
  ## Run the JSON converter
  echo "  [2/4] Converting to canonical XLang JSON"

  # Write native JSON to temp file
  let tempInput = getTempDir() / "native_ast.json"
  writeFile(tempInput, nativeJson)

  let cmd = quoteShell(converterBinary) & " " & quoteShell(tempInput)
  let (output, exitCode) = execCmdEx(cmd)

  removeFile(tempInput)

  if exitCode != 0:
    echo "Converter failed with exit code ", exitCode
    echo "Output: ", output
    return (false, "")

  return (true, output)

proc parseXLangJson(xlangJson: string): tuple[success: bool, ast: JsonNode] =
  ## Parse XLang JSON string to AST
  echo "  [3/4] Parsing XLang JSON to AST"

  try:
    let ast = parseJson(xlangJson)
    return (true, ast)
  except JsonParsingError as e:
    echo "Failed to parse XLang JSON: ", e.msg
    return (false, nil)

proc transpileToNim(xlangAst: JsonNode): tuple[success: bool, nimCode: string] =
  ## Transpile XLang AST to Nim code
  echo "  [4/4] Transpiling XLang AST to Nim"

  # Write XLang JSON to temp file
  let tempInput = getTempDir() / "xlang_ast.json"
  writeFile(tempInput, $xlangAst)

  # Use xlang_codegen to convert XLang JSON to Nim code
  let xlangCodegenBinary = "src/xlang/xlang_codegen"

  # Check if we need to compile it
  if not fileExists(xlangCodegenBinary):
    echo "  Compiling xlang_codegen..."
    let compileResult = execCmd("nim c -d:release src/xlang/xlang_codegen.nim")
    if compileResult != 0:
      echo "Failed to compile xlang_codegen"
      removeFile(tempInput)
      return (false, "")

  let cmd = quoteShell(xlangCodegenBinary) & " " & quoteShell(tempInput)
  let (output, exitCode) = execCmdEx(cmd)

  removeFile(tempInput)

  if exitCode != 0:
    echo "Transpilation failed with exit code ", exitCode
    echo "Output: ", output
    return (false, "")

  return (true, output)

proc transpileFile(sourceFile: string, lang: Language, outputDir: string): bool =
  ## Transpile a single file through the complete pipeline
  echo "\nTranspiling: ", sourceFile

  let config = ParserConfigs[lang]
  echo config
  # Compile converter if needed
  echo "# Compile converter if needed"
  if not compileConverter(config.converterBinary):
    echo "Failed to compile converter"
    return false

  # Step 1: Run parser
  echo "# Step 1: Run parser"
  let (parseSuccess, nativeJson) = runParser(config, sourceFile)
  if not parseSuccess:
    return false


  echo "# Step 2: Run converter"
  # Step 2: Run converter
  let (convertSuccess, xlangJson) = runConverter(config.converterBinary, nativeJson)
  if not convertSuccess:
    return false

  echo "# Step 3: Parse XLang JSON"
  # Step 3: Parse XLang JSON
  let (jsonSuccess, xlangAst) = parseXLangJson(xlangJson)
  if not jsonSuccess:
    return false

  echo "# Step 4: Transpile to Nim"
  # Step 4: Transpile to Nim
  let (transpileSuccess, nimCode) = transpileToNim(xlangAst)
  if not transpileSuccess:
    return false

  # Write output
  let baseName = sourceFile.splitFile().name
  let outputFile = outputDir / (baseName & ".nim")
  writeFile(outputFile, nimCode)

  echo "✓ Success: ", outputFile
  return true

proc collectFiles(path: string, extension: string): seq[string] =
  ## Collect all files with given extension from path (file or directory)
  result = @[]

  if fileExists(path):
    if path.endsWith(extension):
      result.add(path)
  elif dirExists(path):
    for entry in walkDirRec(path):
      if entry.endsWith(extension):
        result.add(entry)
  else:
    raise newException(IOError, "Path not found: " & path)

proc main() =
  if paramCount() < 2:
    echo "Usage: transpile <input_file_or_folder> <language> [output_dir]"
    echo ""
    echo "Languages: python, go, csharp, java, typescript, d, crystal, haxe"
    echo ""
    echo "Examples:"
    echo "  transpile myfile.cs csharp"
    echo "  transpile ~/prog/ICU4N csharp output/"
    echo "  transpile src/main.py python"
    quit(1)

  let inputPath = paramStr(1).expandTilde()
  let langStr = paramStr(2)
  let outputDir = if paramCount() >= 3: paramStr(3) else: "output"

  # Parse language
  let lang = try:
    parseLanguage(langStr)
  except ValueError as e:
    echo e.msg
    quit(1)

  # Create output directory
  if not dirExists(outputDir):
    createDir(outputDir)

  echo "Transpiler Pipeline"
  echo "==================="
  echo "Input: ", inputPath
  echo "Language: ", lang
  echo "Output: ", outputDir
  echo ""

  # Collect files
  let config = ParserConfigs[lang]
  let files = collectFiles(inputPath, config.extension)

  if files.len == 0:
    echo "No ", config.extension, " files found in ", inputPath
    quit(1)

  echo "Found ", files.len, " file(s)"
  echo ""

  # Transpile each file (stop at first error)
  var successCount = 0
  var failCount = 0

  for file in files:
    if transpileFile(file, lang, outputDir):
      inc successCount
    else:
      inc failCount
      echo "\nStopping at first error."
      break

  echo ""
  echo "==================="
  echo "Summary:"
  echo "  Total: ", files.len
  echo "  Success: ", successCount
  echo "  Failed: ", failCount

  if failCount > 0:
    quit(1)

when isMainModule:
  main()
