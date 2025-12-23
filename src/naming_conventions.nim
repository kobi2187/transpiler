## Naming Convention Conversions
##
## Handles conversion between different language naming conventions:
## - C# PascalCase namespaces (System.Collections.Generic)
## - Nim snake_case modules (system/collections/generic)

import strutils, re, options, os
import ../xlangtypes

proc pascalToSnake*(s: string): string =
  ## Convert PascalCase to snake_case using regex
  ## Examples:
  ##   "RegularExpressions" -> "regular_expressions"
  ##   "System" -> "system"
  ##   "IO" -> "io"
  ##   "IOStream" -> "io_stream"
  ##   "TestApp" -> "test_app"
  result = s

  # Insert underscore before uppercase letters that follow lowercase or digits
  # Handles: "myVar" -> "my_var", "var2Name" -> "var2_name", "TestApp" -> "Test_App"
  result = result.replacef(re"([a-z\d])([A-Z])", "$1_$2")

  # Insert underscore between consecutive uppercase letters and a following lowercase
  # Handles acronyms: "IOStream" -> "IO_Stream" -> "io_stream"
  result = result.replacef(re"([A-Z]+)([A-Z][a-z])", "$1_$2")

  # Convert to lowercase
  result = result.toLowerAscii()

proc namespaceToModulePath*(namespace: string): string =
  ## Convert C# namespace to Nim module path
  ## Examples:
  ##   "System.Collections.Generic" -> "system/collections/generic"
  ##   "System.Text.RegularExpressions" -> "system/text/regular_expressions"
  ##   "MyCompany.MyProduct.Core" -> "my_company/my_product/core"
  let parts = namespace.split('.')
  var nimParts: seq[string] = @[]

  for part in parts:
    nimParts.add(pascalToSnake(part))

  result = nimParts.join("/")

proc namespaceToFileName*(namespace: string, extension: string = ".nim"): string =
  ## Convert C# namespace to Nim filename
  ## Examples:
  ##   "System.Collections" -> "system/collections.nim"
  ##   "MyApp.Models.User" -> "my_app/models/user.nim"
  result = namespaceToModulePath(namespace) & extension

proc typeNameToNim*(typeName: string): string =
  ## Convert C# type name to Nim type name
  ## Generally keeps PascalCase for types, but handles special cases
  ## Examples:
  ##   "List" -> "List"
  ##   "Dictionary" -> "Dictionary"
  ##   "IEnumerable" -> "IEnumerable" (keep interface naming)
  result = typeName

proc memberNameToNim*(memberName: string): string =
  ## Convert C# member name (field/method) to Nim naming
  ## C# uses camelCase or PascalCase, Nim prefers camelCase for procs/vars
  ## Examples:
  ##   "ToString" -> "toString"
  ##   "GetHashCode" -> "getHashCode"
  ##   "myField" -> "myField"
  if memberName.len > 0 and memberName[0].isUpperAscii():
    result = memberName[0].toLowerAscii() & memberName[1..^1]
  else:
    result = memberName

proc sanitizeNimIdentifier*(ident: string): string =
  ## Sanitize identifier to be valid Nim
  ## - Remove trailing underscores (C# convention, invalid in Nim)
  ## - Keep leading underscores (valid in Nim for private/internal)
  ## Examples:
  ##   "SLOPE_MIN_" -> "SLOPE_MIN"
  ##   "_privateField" -> "_privateField"
  ##   "value_" -> "value"
  result = ident.strip(chars = {'_'}, leading = false, trailing = true)

proc extractNamespace*(xlangAst: XLangNode): Option[string] =
  ## Extract the namespace from an XLang AST
  ## Returns None if no namespace is found
  if xlangAst.kind == xnkFile:
    for decl in xlangAst.moduleDecls:
      if decl.kind == xnkNamespace:
        return some(decl.namespaceName)
  return none(string)

proc getOutputFileName*(xlangAst: XLangNode, inputFile: string, extension: string = ".nim", inputRoot: string = ""): string =
  ## Determine the output filename based on input file structure
  ## Uses source directory structure relative to inputRoot to preserve uniqueness
  ## Each C# source file maps to its own Nim file with the same relative directory structure
  ##
  ## Args:
  ##   xlangAst: The XLang AST (unused, kept for API compatibility)
  ##   inputFile: The full path to the input file
  ##   extension: Output file extension (default ".nim")
  ##   inputRoot: The root input directory to make paths relative to
  let inputBaseName = inputFile.splitFile().name  # filename without extension

  # If no inputRoot provided, use just the filename
  if inputRoot == "":
    return inputBaseName & extension

  # Compute relative path from inputRoot to inputFile's directory
  let inputDir = inputFile.parentDir()
  let root = inputRoot.normalizedPath().absolutePath()
  let fullDir = inputDir.normalizedPath().absolutePath()

  let relativeDir = if fullDir.startsWith(root):
    fullDir[root.len..^1].strip(chars = {os.DirSep}, leading = true, trailing = true)
  else:
    # Input file is not under inputRoot - use just the filename
    ""

  # Convert relative path to snake_case for Nim conventions
  if relativeDir != "":
    return pascalToSnake(relativeDir) & "/" & inputBaseName & extension
  else:
    return inputBaseName & extension
