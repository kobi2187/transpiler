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

proc extractNamespace*(xlangAst: XLangNode): Option[string] =
  ## Extract the namespace from an XLang AST
  ## Returns None if no namespace is found
  if xlangAst.kind == xnkFile:
    for decl in xlangAst.moduleDecls:
      if decl.kind == xnkNamespace:
        return some(decl.namespaceName)
  return none(string)

proc getOutputFileName*(xlangAst: XLangNode, inputFile: string, extension: string = ".nim"): string =
  ## Determine the output filename based on namespace conventions
  ## If namespace exists: convert to module path (e.g., "System.Collections" -> "system/collections.nim")
  ## If no namespace: use input filename with changed extension
  let ns = extractNamespace(xlangAst)
  if ns.isSome():
    return namespaceToFileName(ns.get(), extension)
  else:
    # Fallback to input filename with changed extension
    return inputFile.changeFileExt(extension)
