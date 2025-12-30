## Enum Transformations for C# to Nim
##
## Converts C# enum declarations and member access to idiomatic Nim style.
##
## C# enum member access:
##   RegexOptions.Compiled
##   StringComparison.Ordinal
##
## Nim idiomatic form (prefix = enum type initials):
##   roCompiled    (RegexOptions → ro)
##   scOrdinal     (StringComparison → sc)

import ../../../xlangtypes
import options
import strutils
import collections/tables
import ../helpers

# Global registry for enum types and their prefixes
var enumRegistry {.global.} = initTable[string, string]()

proc createEnumPrefix*(typeName: string): string =
  ## Create Nim enum prefix from type name by extracting uppercase letters
  ## Examples: RegexOptions → ro, PadPosition → pp, Color → c
  result = ""
  for ch in typeName:
    if ch >= 'A' and ch <= 'Z':
      result.add(($ch).toLowerAscii())

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
  ## Transform enum member access to idiomatic Nim identifier
  ## Example: RegexOptions.Compiled → roCompiled

  if node.kind != xnkMemberAccessExpr:
    return node

  # Extract member access chain: e.g., [RegexOptions, Compiled]
  var chain: seq[string] = @[]
  var current = node

  while current.kind == xnkMemberAccessExpr:
    chain.insert(current.memberName, 0)
    current = current.memberExpr

  # Add the leftmost identifier
  if current.kind == xnkIdentifier:
    chain.insert(current.identName, 0)
  else:
    return node  # Not a simple member access chain

  # Check if this is enum access: EnumType.Value
  if chain.len == 2:
    let enumType = chain[0]
    let memberName = chain[1]

    if isEnumType(enumType):
      let prefix = getEnumPrefix(enumType).get()
      let idiomaticName = prefix & memberName
      return XLangNode(kind: xnkIdentifier, identName: idiomaticName)

  return node

proc collectExternalEnums(n: XLangNode) =
  ## Collect external enum types from C# parser metadata (isEnumAccess=true)
  ## This registers BCL enums like RegexOptions that aren't defined in source
  if n.isNil:
    return

  case n.kind
  of xnkMemberAccessExpr:
    if n.isEnumAccess and n.enumTypeName != "":
      registerEnum(n.enumTypeName)
    collectExternalEnums(n.memberExpr)
  of xnkFile:
    for decl in n.moduleDecls:
      collectExternalEnums(decl)
  of xnkNamespace:
    for decl in n.namespaceBody:
      collectExternalEnums(decl)
  of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
    for member in n.members:
      collectExternalEnums(member)
  of xnkFuncDecl:
    collectExternalEnums(n.body)
  of xnkMethodDecl:
    collectExternalEnums(n.mbody)
  of xnkConstructorDecl:
    collectExternalEnums(n.constructorBody)
  of xnkFieldDecl:
    if n.fieldInitializer.isSome():
      collectExternalEnums(n.fieldInitializer.get())
  of xnkBlockStmt:
    for stmt in n.blockBody:
      collectExternalEnums(stmt)
  of xnkIfStmt:
    collectExternalEnums(n.ifCondition)
    collectExternalEnums(n.ifBody)
    if n.elseBody.isSome():
      collectExternalEnums(n.elseBody.get())
  of xnkWhileStmt:
    collectExternalEnums(n.whileCondition)
    collectExternalEnums(n.whileBody)
  of xnkForeachStmt:
    collectExternalEnums(n.foreachIter)
    collectExternalEnums(n.foreachBody)
  of xnkCallExpr:
    collectExternalEnums(n.callee)
    for arg in n.args:
      collectExternalEnums(arg)
  of xnkBinaryExpr:
    collectExternalEnums(n.binaryLeft)
    collectExternalEnums(n.binaryRight)
  of xnkUnaryExpr:
    collectExternalEnums(n.unaryOperand)
  of xnkReturnStmt:
    if n.returnExpr.isSome():
      collectExternalEnums(n.returnExpr.get())
  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    if n.initializer.isSome():
      collectExternalEnums(n.initializer.get())
  else:
    discard

proc collectSourceEnums(n: XLangNode) =
  ## Collect enum declarations defined in source code
  case n.kind
  of xnkEnumDecl:
    registerEnum(n.enumName)
  of xnkFile:
    for decl in n.moduleDecls:
      collectSourceEnums(decl)
  of xnkNamespace:
    for decl in n.namespaceBody:
      collectSourceEnums(decl)
  of xnkClassDecl, xnkStructDecl:
    for member in n.members:
      collectSourceEnums(member)
  else:
    discard

proc transformEnumNormalization*(node: XLangNode): XLangNode =
  ## Main enum normalization transformation
  ##
  ## Three-pass approach:
  ## 1. Collect external enums from C# parser metadata
  ## 2. Collect source-defined enums
  ## 3. Transform enum member access and declarations

  var resultNode = node

  # PASS 1: Collect external BCL enums from isEnumAccess metadata
  collectExternalEnums(resultNode)

  # PASS 2: Collect source-defined enums
  if resultNode.kind == xnkFile:
    collectSourceEnums(resultNode)

  # PASS 3: Transform enum member access and declarations
  proc transformNode(n: var XLangNode) =
    case n.kind
    of xnkMemberAccessExpr:
      # Try to normalize enum member access: EnumType.Value → etValue
      let normalized = normalizeEnumMemberAccess(n)
      if normalized.kind != n.kind:
        n = normalized

    of xnkEnumDecl:
      # Register and normalize enum declaration
      registerEnum(n.enumName)

      # Add prefix to all enum member names
      let prefix = getEnumPrefix(n.enumName).get()
      var normalizedMembers: seq[XLangNode] = @[]

      for member in n.enumMembers:
        let idiomaticName = prefix & member.enumMemberName
        normalizedMembers.add(XLangNode(
          kind: xnkEnumMember,
          enumMemberName: idiomaticName,
          enumMemberValue: member.enumMemberValue
        ))

      n = XLangNode(
        kind: xnkEnumDecl,
        enumName: n.enumName,
        enumMembers: normalizedMembers
      )

    else:
      discard

  # Apply transformation to entire tree
  traverseTree(resultNode, transformNode)

  return resultNode
