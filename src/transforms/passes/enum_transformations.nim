## Enum Transformations Across Languages
##
## Normalizes enum declarations from various languages to Nim's enum syntax
##
## Python (Enum class):
##   class Color(Enum):
##     RED = 1
##     GREEN = 2
##     BLUE = 3
##
## C#:
##   enum Color { Red, Green, Blue }
##   enum Color { Red = 1, Green = 2, Blue = 3 }
##
## TypeScript:
##   enum Color { Red, Green, Blue }
##   enum Color { Red = "red", Green = "green" }
##
## Java:
##   enum Color { RED, GREEN, BLUE }
##
## Nim:
##   type Color = enum
##     red, green, blue

import ../../../xlangtypes
import options
import strutils
import collections/tables

proc createEnumPrefix*(typeName: string): string =
  ## Create idiomatic Nim enum prefix from type name
  ## PadPosition → pp, FileMode → fm, Color → c
  result = ""
  for ch in typeName:
    if ch >= 'A' and ch <= 'Z':
      result.add(($ch).toLowerAscii())

proc normalizeEnumMemberName*(name: string): string =
  ## Convert enum member names to Nim convention
  ##
  ## C#/Java: RED, Green, Blue
  ## Python: RED, GREEN, BLUE
  ## Nim prefers: red, green, blue (camelCase for multi-word)

  # Convert SCREAMING_SNAKE_CASE or PascalCase to camelCase
  result = name.toLowerAscii()

  # Handle snake_case: HELLO_WORLD → helloWorld
  if "_" in result:
    var parts = result.split("_")
    result = parts[0]
    for i in 1..<parts.len:
      if parts[i].len > 0:
        result.add(parts[i][0].toUpperAscii & parts[i][1..^1])

# Global registry for enum types and their prefixes
var enumRegistry {.global.} = initTable[string, string]()

proc registerEnum*(enumName: string) =
  ## Register an enum type and compute its prefix
  let prefix = createEnumPrefix(enumName)
  enumRegistry[enumName] = prefix

proc getEnumPrefix*(enumName: string): Option[string] =
  ## Get the prefix for a registered enum type
  if enumRegistry.hasKey(enumName):
    return some(enumRegistry[enumName])
  return none(string)

proc isEnumType*(typeName: string): bool =
  ## Check if a type name is a registered enum
  return enumRegistry.hasKey(typeName)

proc normalizeEnumMemberAccess*(node: XLangNode): XLangNode =
  ## Normalize enum member access to idiomatic Nim form
  ## Handles both:
  ## - Simple: PadPosition.BeforePrefix → ppBeforePrefix
  ## - Nested: Padder.PadPosition.BeforePrefix → ppBeforePrefix

  if node.kind != xnkMemberAccessExpr:
    return node

  # Extract the chain of member access: [Padder, PadPosition, BeforePrefix]
  var chain: seq[string] = @[]
  var current = node

  # Walk up the member access chain
  while current.kind == xnkMemberAccessExpr:
    chain.insert(current.memberName, 0)
    current = current.memberExpr

  # Add the leftmost identifier
  if current.kind == xnkIdentifier:
    chain.insert(current.identName, 0)
  else:
    # Not a simple member access chain, leave it alone
    return node

  # Try to find enum type in the chain
  # For Padder.PadPosition.BeforePrefix: check if PadPosition is an enum
  # For PadPosition.BeforePrefix: check if PadPosition is an enum

  if chain.len >= 2:
    # Try second-to-last as enum type name
    let potentialEnumType = chain[^2]
    if isEnumType(potentialEnumType):
      let prefix = getEnumPrefix(potentialEnumType).get()
      let memberName = chain[^1]
      let idiomaticName = prefix & memberName
      return XLangNode(kind: xnkIdentifier, identName: idiomaticName)

    # Also try if the first part is an enum (for simple access)
    if chain.len == 2:
      let potentialEnumType2 = chain[0]
      if isEnumType(potentialEnumType2):
        let prefix = getEnumPrefix(potentialEnumType2).get()
        let memberName = chain[1]
        let idiomaticName = prefix & memberName
        return XLangNode(kind: xnkIdentifier, identName: idiomaticName)

  # Not an enum access, leave as-is
  return node

proc transformPythonEnum*(node: XLangNode): XLangNode =
  ## Transform Python Enum class to Nim enum
  ##
  ## Python:
  ##   class Status(Enum):
  ##     PENDING = 1
  ##     ACTIVE = 2
  ##     DONE = 3
  ##
  ## Nim:
  ##   type Status = enum
  ##     pending = 1, active, done

  if node.kind != xnkClassDecl:
    return node

  # Check if this class inherits from Enum
  var isEnum = false
  for baseType in node.baseTypes:
    if baseType.kind == xnkNamedType and baseType.typeName == "Enum":
      isEnum = true
      break

  if not isEnum:
    return node

  # Extract enum members from class body
  var enumMembers: seq[XLangNode] = @[]

  for member in node.members:
    if member.kind in {xnkVarDecl, xnkLetDecl, xnkConstDecl}:
      # Class variable = enum member
      let memberName = normalizeEnumMemberName(member.declName)
      let memberValue = member.initializer

      enumMembers.add(XLangNode(
        kind: xnkEnumMember,
        enumMemberName: memberName,
        enumMemberValue: memberValue
      ))

  result = XLangNode(
    kind: xnkEnumDecl,
    enumName: node.typeNameDecl,
    enumMembers: enumMembers
  )

proc transformCSharpEnum*(node: XLangNode): XLangNode =
  ## Transform C# enum to Nim enum
  ##
  ## C#:
  ##   enum Status { Pending, Active, Done }
  ##   enum Status { Pending = 1, Active = 2, Done = 3 }
  ##
  ## Already represented as EnumDecl in XLang
  ## Just normalize member names

  if node.kind != xnkEnumDecl:
    return node

  var normalizedMembers: seq[XLangNode] = @[]

  for member in node.enumMembers:
    let normalizedName = normalizeEnumMemberName(member.enumMemberName)
    normalizedMembers.add(XLangNode(
      kind: xnkEnumMember,
      enumMemberName: normalizedName,
      enumMemberValue: member.enumMemberValue
    ))

  result = XLangNode(
    kind: xnkEnumDecl,
    enumName: node.enumName,
    enumMembers: normalizedMembers
  )

# String enums (TypeScript)
# enum Color { Red = "RED", Green = "GREEN" }
# Nim doesn't have string enums natively
# Can use distinct string or const declarations

proc transformStringEnum*(node: XLangNode): XLangNode =
  ## Transform TypeScript string enums
  ##
  ## TS:
  ##   enum Status { Pending = "pending", Active = "active" }
  ##
  ## Nim (option 1 - distinct string):
  ##   type Status = distinct string
  ##   const pending = Status("pending")
  ##   const active = Status("active")
  ##
  ## Nim (option 2 - object):
  ##   type StatusEnum = object
  ##   const Status = (pending: "pending", active: "active")

  if node.kind != xnkEnumDecl:
    return node

  # Check if all values are strings
  var allStrings = true
  for member in node.enumMembers:
    if member.enumMemberValue.isNone():
      allStrings = false
      break
    if member.enumMemberValue.get.kind != xnkStringLit:
      allStrings = false
      break

  if not allStrings:
    return node  # Regular enum

  # Create distinct string type + const declarations
  let enumName = node.enumMemberName

  # Type definition: type Status = distinct string
  let typeDef = XLangNode(
    kind: xnkTypeDecl,
    typeDefName: enumName,
    typeDefBody: XLangNode(
      kind: xnkDistinctType,
      distinctBaseType: XLangNode(kind: xnkNamedType, typeName: "string")
    )
  )

  # Const declarations for each member
  var constDecls: seq[XLangNode] = @[]
  for member in node.enumMembers:
    constDecls.add(XLangNode(
      kind: xnkConstDecl,
      declName: member.name,
      declType: some(XLangNode(kind: xnkNamedType, typeName: enumName)),
      initializer: some(XLangNode(
        kind: xnkCallExpr,
        callee: XLangNode(kind: xnkIdentifier, identName: enumName),
        args: @[member.enumMemberValue.get]
      ))
    ))

  # Return block with type + consts
  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: @[typeDef] & constDecls
  )

# Enum with methods (Java, C#, TypeScript)
# Java allows methods in enums
# This becomes a type with methods in Nim

proc transformEnumWithMethods*(node: XLangNode): XLangNode =
  ## Transform enums that have methods (Java style)
  ##
  ## Java:
  ##   enum Operation {
  ##     PLUS { int apply(int x, int y) { return x + y; } },
  ##     MINUS { int apply(int x, int y) { return x - y; } }
  ##   }
  ##
  ## This is complex - enum becomes object type with procs

  if node.kind != xnkEnumDecl:
    return node

  # Check if enum has methods (would be in metadata)
  # For now, pass through

  result = node

# Flag enums (C# [Flags])
# C#:
##   [Flags]
##   enum Permissions { Read = 1, Write = 2, Execute = 4 }
##
## Nim:
##   type Permission = enum
##     permRead, permWrite, permExecute
##   type Permissions = set[Permission]

proc transformFlagsEnum*(node: XLangNode): XLangNode =
  ## Transform C# flags enum to Nim set type
  ##
  ## C#: [Flags] enum Permissions { Read = 1, Write = 2, Execute = 4 }
  ## Nim: type Permission = enum ...; type Permissions = set[Permission]

  if node.kind != xnkEnumDecl:
    return node

  # Check for [Flags] attribute (would be in metadata)
  # Would need attribute checking

  # If flags enum:
  # 1. Create base enum with singular name
  # 2. Create set type with plural name

  result = node  # Placeholder

# Enum iteration support
# Some languages allow iterating enum values
# Nim: for value in Color: echo value

# Main transformation - TWO PASS approach
proc transformEnumNormalization*(node: XLangNode): XLangNode =
  ## Main enum normalization transformation
  ## PASS 1: Register all enums in the tree
  ## PASS 2: Transform enum declarations and member access

  # Helper proc to collect all enum declarations
  proc collectEnums(n: XLangNode) =
    case n.kind
    of xnkEnumDecl:
      registerEnum(n.enumName)
    of xnkFile:
      for decl in n.moduleDecls:
        collectEnums(decl)
    of xnkNamespace:
      for decl in n.namespaceBody:
        collectEnums(decl)
    of xnkClassDecl, xnkStructDecl:
      for member in n.members:
        collectEnums(member)
    else:
      discard

  # PASS 1: If this is the root (xnkFile), collect all enums first
  if node.kind == xnkFile:
    collectEnums(node)

  # PASS 2: Transform the node
  case node.kind
  of xnkMemberAccessExpr:
    # Normalize enum member access
    return normalizeEnumMemberAccess(node)

  of xnkClassDecl:
    # Check for Python Enum
    return transformPythonEnum(node)

  of xnkEnumDecl:
    # Register this enum
    registerEnum(node.enumName)

    # Check for string enum first
    let stringResult = transformStringEnum(node)
    if stringResult.kind != xnkEnumDecl:
      return stringResult

    # Check for flags enum
    let flagsResult = transformFlagsEnum(node)
    if flagsResult != node:
      return flagsResult

    # Regular enum normalization (updates member names to use prefix)
    let prefix = getEnumPrefix(node.enumName).get()
    var normalizedMembers: seq[XLangNode] = @[]
    for member in node.enumMembers:
      let idiomaticName = prefix & member.enumMemberName
      normalizedMembers.add(XLangNode(
        kind: xnkEnumMember,
        enumMemberName: idiomaticName,
        enumMemberValue: member.enumMemberValue
      ))

    return XLangNode(
      kind: xnkEnumDecl,
      enumName: node.enumName,
      enumMembers: normalizedMembers
    )

  else:
    return node
