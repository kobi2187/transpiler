## Union Type to Variant Object Transformation
##
## Transforms TypeScript/Python union types to Nim variant objects (sum types)
##
## Example:
## type StringOrNumber = string | number
##
## Transforms to:
## type
##   StringOrNumberKind = enum
##     sonkString, sonkNumber
##   StringOrNumber = object
##     case kind: StringOrNumberKind
##     of sonkString: strVal: string
##     of sonkNumber: numVal: float

import ../../xlangtypes
import options
import strutils
import strformat

proc typeNameToEnumValue(typeName: string, index: int): string =
  ## Convert type name to enum value name
  ## "string" → "String", "number" → "Number"
  if typeName.len > 0:
    result = typeName[0].toUpperAscii & typeName[1..^1].toLowerAscii
  else:
    result = "Type" & $index

proc typeNameToFieldName(typeName: string): string =
  ## Convert type name to field name
  ## "string" → "strVal", "number" → "numVal"
  if typeName.len >= 3:
    result = typeName[0..2].toLowerAscii & "Val"
  else:
    result = typeName.toLowerAscii & "Val"

proc generateKindEnumName(unionTypeName: string): string =
  ## Generate kind enum name from union type name
  ## "StringOrNumber" → "StringOrNumberKind"
  result = unionTypeName & "Kind"

proc generateEnumPrefix(unionTypeName: string): string =
  ## Generate enum value prefix from type name
  ## "StringOrNumber" → "sonk" (string-or-number-kind)
  var words: seq[string] = @[]
  var currentWord = ""

  for c in unionTypeName:
    if c.isUpperAscii and currentWord.len > 0:
      words.add(currentWord)
      currentWord = $c
    else:
      currentWord.add(c)

  if currentWord.len > 0:
    words.add(currentWord)

  # Take first letter of each word
  result = ""
  for word in words:
    if word.len > 0:
      result.add(word[0].toLowerAscii)

  result.add("k")  # Add 'k' for Kind

proc transformUnionToVariant*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Transform union type declarations to variant objects
  if node.kind != xnkTypeDecl:
    return node

  # Check if the type body is a union type
  if node.typeDefBody.kind != xnkUnionType:
    return node

  # We have a union type!
  # type Foo = A | B | C
  # Transform to:
  # type FooKind = enum fkA, fkB, fkC
  # type Foo = object
  #   case kind: FooKind
  #   of fkA: aVal: A
  #   of fkB: bVal: B
  #   of fkC: cVal: C

  let unionTypeName = node.typeDefName
  let kindEnumName = generateKindEnumName(unionTypeName)
  let enumPrefix = generateEnumPrefix(unionTypeName)
  let members = node.typeDefBody.typeMembers

  # Generate enum values
  var enumMembers: seq[XLangNode] = @[]
  var variantFields: seq[XLangNode] = @[]

  for i, memberType in members:
    # Determine the enum value name
    var enumValueName = enumPrefix
    if memberType.kind == xnkNamedType:
      enumValueName.add(typeNameToEnumValue(memberType.typeName, i))
    else:
      enumValueName.add("Type" & $i)

    # Add to enum as XLangNode
    enumMembers.add(XLangNode(
      kind: xnkEnumMember,
      enumMemberName: enumValueName,
      enumMemberValue: none(XLangNode)
    ))

    # Create variant field
    # For each union member, create a case branch with a field
    var fieldName = ""
    if memberType.kind == xnkNamedType:
      fieldName = typeNameToFieldName(memberType.typeName)
    else:
      fieldName = "val" & $i

    # Note: This is a simplified representation
    # The actual Nim variant object syntax requires special handling
    # We'll create a FieldDecl to represent: of enumValue: fieldName: Type
    # This will need special handling in the Nim AST converter

    let variantField = XLangNode(
      kind: xnkFieldDecl,
      fieldName: enumValueName & ":" & fieldName,  # Special marker for variant field
      fieldType: memberType,
      fieldInitializer: none(XLangNode)
    )
    variantFields.add(variantField)

  # Create the kind enum type declaration
  let kindEnumDecl = XLangNode(
    kind: xnkEnumDecl,
    enumName: kindEnumName,
    enumMembers: enumMembers
  )

  # Create the variant object type
  # This is a special object with a discriminator field 'kind'
  let discriminatorField = XLangNode(
    kind: xnkFieldDecl,
    fieldName: "kind",
    fieldType: XLangNode(kind: xnkNamedType, typeName: kindEnumName),
    fieldInitializer: none(XLangNode)
  )

  let variantObject = XLangNode(
    kind: xnkStructDecl,  # Using struct to represent object
    typeNameDecl: unionTypeName,
    baseTypes: @[],
    members: @[discriminatorField] & variantFields
  )

  # Return both declarations wrapped in a block
  # The Nim converter will need to recognize this pattern
  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: @[
      XLangNode(kind: xnkTypeDecl, typeDefName: kindEnumName, typeDefBody: kindEnumDecl),
      XLangNode(kind: xnkTypeDecl, typeDefName: unionTypeName, typeDefBody: variantObject)
    ]
  )
