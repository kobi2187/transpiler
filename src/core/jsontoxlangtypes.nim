import std/json
import xlangtypes


proc stripBOM(s: string): string =
  ## Strip UTF-8 BOM if present
  if s.len >= 3 and s[0] == '\xEF' and s[1] == '\xBB' and s[2] == '\xBF':
    return s[3..^1]
  return s

proc setDefaultEnumFields(node: var XLangNode) =
  ## Recursively set default values for optional enum fields in member access expressions
  case node.kind
  of xnkMemberAccessExpr:
    # These fields might not exist in JSON, set defaults if needed
    if not node.isEnumAccess:
      node.isEnumAccess = false
    if node.enumTypeName == "":
      node.enumTypeName = ""
    if node.enumFullName == "":
      node.enumFullName = ""
    setDefaultEnumFields(node.memberExpr)
  else:
    # Recursively process all child nodes based on kind
    discard  # Handled by normal parsing

proc parseXLangJson*(filePath: string): XLangNode =
  ## Parse XLang AST from a JSON file
  ## Returns the root XLangNode
  ## Note: Relies on natural failures when JSON fields don't match type definitions
  ## Option fields will be none if JSON field name is wrong, causing errors downstream
  var jsonString = readFile(filePath).stripBOM()
  var jsonNode = jsonString.parseJson()

  # Add default fields to all nodes
  proc addDefaultsToJson(j: var JsonNode) =
    if j.kind == JObject:
      if j.hasKey("kind") and j["kind"].kind == JString:
        let kindStr = j["kind"].getStr()

        # Add UUID fields if missing (will be generated later)
        if not j.hasKey("id"):
          j["id"] = newJNull()
        if not j.hasKey("parentId"):
          j["parentId"] = newJNull()

        # Add enum-specific fields for memberAccessExpr
        if kindStr == "xnkMemberAccessExpr":
          if not j.hasKey("isEnumAccess"):
            j["isEnumAccess"] = %false
          if not j.hasKey("enumTypeName"):
            j["enumTypeName"] = %""
          if not j.hasKey("enumFullName"):
            j["enumFullName"] = %""

        # Add property-specific fields for xnkExternal_Property
        if kindStr == "xnkExternal_Property":
          if not j.hasKey("extPropVisibility"):
            j["extPropVisibility"] = %"public"
          if not j.hasKey("extPropIsStatic"):
            j["extPropIsStatic"] = %false
          if not j.hasKey("extPropHasGetter"):
            j["extPropHasGetter"] = %false
          if not j.hasKey("extPropHasSetter"):
            j["extPropHasSetter"] = %false

        # Add method-specific fields for xnkMethodDecl
        if kindStr == "xnkMethodDecl":
          if not j.hasKey("receiver"):
            j["receiver"] = newJNull()

        # Fix Go type case default - extTypeCaseTypes can be null for default case
        if kindStr == "xnkExternal_GoTypeCase":
          if j.hasKey("extTypeCaseTypes") and j["extTypeCaseTypes"].kind == JNull:
            j["extTypeCaseTypes"] = newJArray()

      for key, val in j.mpairs:
        addDefaultsToJson(val)
    elif j.kind == JArray:
      for item in j.mitems:
        addDefaultsToJson(item)

  addDefaultsToJson(jsonNode)

  try:
    result = jsonNode.to(XLangNode)
  except JsonParsingError as e:
    raise newException(IOError, "Failed to parse JSON from " & filePath & ": " & e.msg)


