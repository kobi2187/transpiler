import std/json
# import jsony
import xlangtypes


proc stripBOM(s: string): string =
  ## Strip UTF-8 BOM if present
  if s.len >= 3 and s[0] == '\xEF' and s[1] == '\xBB' and s[2] == '\xBF':
    return s[3..^1]
  return s

proc parseXLangJson*(filePath: string): XLangNode =
  ## Parse XLang AST from a JSON file
  ## Returns the root XLangNode
  var jsonString = readFile(filePath).stripBOM()

  try:
    result = jsonString.parseJson().to(XLangNode)
  except JsonParsingError as e:
    # If jsony fails, provide more helpful error message
    raise newException(IOError, "Failed to parse JSON from " & filePath & ": " & e.msg)


