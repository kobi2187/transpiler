import std/json
import xlangtypes


proc stripBOM(s: string): string =
  ## Strip UTF-8 BOM if present
  if s.len >= 3 and s[0] == '\xEF' and s[1] == '\xBB' and s[2] == '\xBF':
    return s[3..^1]
  return s

proc parseXLangJson*(filePath: string): XLangNode =
  ## Parse XLang AST from a JSON file
  ## Returns the root XLangNode
  ## Note: Relies on natural failures when JSON fields don't match type definitions
  ## Option fields will be none if JSON field name is wrong, causing errors downstream
  var jsonString = readFile(filePath).stripBOM()

  try:
    result = jsonString.parseJson().to(XLangNode)
  except JsonParsingError as e:
    raise newException(IOError, "Failed to parse JSON from " & filePath & ": " & e.msg)


