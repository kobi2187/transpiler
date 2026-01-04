## Record to Struct Transformation
##
## Transforms C# record types into Nim structs with auto-generated methods.
##
## C# record:
##   record Person(string Name, int Age);
##
## Becomes Nim struct with:
##   - Field declarations (name*, age*)
##   - Constructor proc (newPerson)
##   - Equality operator (==)
##   - String representation ($)
##
## Records in C# are reference or value types with value-based equality semantics.
## In Nim, we represent them as objects with explicit equality and constructor procs.

import core/xlangtypes
import transforms/transform_context
import error_collector
import options
import strutils
import strformat

proc makeConstructorName(recordName: string): string =
  ## Convert RecordName to newRecordName
  "new" & recordName

proc makeEqualityOpName(): string =
  "=="

proc makeToStringOpName(): string =
  "$"

proc createRecordField(param: XLangNode): XLangNode =
  ## Create a field declaration from a record parameter
  ## Parameters in records become public fields
  let fieldName = if param.paramName.len > 0: param.paramName else: "field"
  XLangNode(
    kind: xnkFieldDecl,
    fieldName: fieldName,
    fieldType: if param.paramType.isSome(): param.paramType.get
               else: XLangNode(kind: xnkNamedType, typeName: "auto"),
    fieldInitializer: none(XLangNode)
  )

proc generateRecordConstructor(record: XLangNode, structNode: XLangNode): XLangNode =
  ## Generate constructor proc for record
  ## Example: proc newPerson(name: string, age: int): Person
  var params: seq[XLangNode] = @[]
  var bodyStmts: seq[XLangNode] = @[]

  # Add new(result) call to initialize the ref object
  let newCall = XLangNode(
    kind: xnkCallExpr,
    callee: XLangNode(kind: xnkIdentifier, identName: "new"),
    args: @[XLangNode(kind: xnkIdentifier, identName: "result")]
  )
  bodyStmts.add(newCall)

  # Add parameters and assignment statements
  for param in record.extRecordParams:
    # Add parameter to proc signature
    params.add(param)

    # Create assignment: result.fieldName = paramName
    let fieldName = param.paramName
    let assignment = XLangNode(
      kind: xnkAsgn,
      asgnLeft: XLangNode(
        kind: xnkMemberAccessExpr,
        memberExpr: XLangNode(kind: xnkIdentifier, identName: "result"),
        memberName: fieldName
      ),
      asgnRight: XLangNode(kind: xnkIdentifier, identName: fieldName)
    )
    bodyStmts.add(assignment)

  # Create return type - a reference to the record type
  let returnType = some(XLangNode(
    kind: xnkNamedType,
    typeName: record.extRecordName
  ))

  # Create constructor proc
  XLangNode(
    kind: xnkFuncDecl,
    funcName: makeConstructorName(record.extRecordName),
    params: params,
    returnType: returnType,
    body: XLangNode(
      kind: xnkBlockStmt,
      blockBody: bodyStmts
    ),
    isAsync: false,
    funcVisibility: "public",
    funcIsStatic: false
  )

proc generateRecordEquality(record: XLangNode): XLangNode =
  ## Generate value-based equality operator
  ## Example: proc `==`(a: Person, b: Person): bool
  let recordType = XLangNode(
    kind: xnkNamedType,
    typeName: record.extRecordName
  )

  let paramA = XLangNode(
    kind: xnkParameter,
    paramName: "a",
    paramType: some(recordType),
    defaultValue: none(XLangNode)
  )

  let paramB = XLangNode(
    kind: xnkParameter,
    paramName: "b",
    paramType: some(recordType),
    defaultValue: none(XLangNode)
  )

  # Build equality expression: (a.field1 == b.field1) and (a.field2 == b.field2) and ...
  var equalityExpr: Option[XLangNode] = none(XLangNode)

  for param in record.extRecordParams:
    let fieldName = param.paramName
    let fieldComparison = XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: opEqual,
      binaryLeft: XLangNode(
        kind: xnkMemberAccessExpr,
        memberExpr: XLangNode(kind: xnkIdentifier, identName: "a"),
        memberName: fieldName
      ),
      binaryRight: XLangNode(
        kind: xnkMemberAccessExpr,
        memberExpr: XLangNode(kind: xnkIdentifier, identName: "b"),
        memberName: fieldName
      )
    )

    if equalityExpr.isNone():
      equalityExpr = some(fieldComparison)
    else:
      equalityExpr = some(XLangNode(
        kind: xnkBinaryExpr,
        binaryOp: opLogicalAnd,
        binaryLeft: equalityExpr.get,
        binaryRight: fieldComparison
      ))

  # Default to true if no fields
  let returnExpr = if equalityExpr.isSome():
    equalityExpr.get
  else:
    XLangNode(kind: xnkBoolLit, boolValue: true)

  # Create equality operator proc
  XLangNode(
    kind: xnkFuncDecl,
    funcName: makeEqualityOpName(),
    params: @[paramA, paramB],
    returnType: some(XLangNode(kind: xnkNamedType, typeName: "bool")),
    body: XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[
        XLangNode(
          kind: xnkReturnStmt,
          returnExpr: some(returnExpr)
        )
      ]
    ),
    isAsync: false,
    funcVisibility: "public",
    funcIsStatic: false
  )

proc generateRecordToString(record: XLangNode): XLangNode =
  ## Generate toString ($) operator
  ## Example: proc `$`(p: Person): string = "Person { name = ..., age = ... }"
  let recordType = XLangNode(
    kind: xnkNamedType,
    typeName: record.extRecordName
  )

  let param = XLangNode(
    kind: xnkParameter,
    paramName: "self",
    paramType: some(recordType),
    defaultValue: none(XLangNode)
  )

  # Build string concatenation: "RecordName { field1 = " & $self.field1 & ", field2 = " & $self.field2 & " }"
  var stringExpr: Option[XLangNode] = none(XLangNode)

  # Start with record name and opening brace
  stringExpr = some(XLangNode(
    kind: xnkStringLit,
    literalValue: record.extRecordName & " { "
  ))

  # Add each field
  var isFirst = true
  for param in record.extRecordParams:
    let fieldName = param.paramName

    # Add comma separator if not first field
    if not isFirst:
      stringExpr = some(XLangNode(
        kind: xnkBinaryExpr,
        binaryOp: opConcat,
        binaryLeft: stringExpr.get,
        binaryRight: XLangNode(kind: xnkStringLit, literalValue: ", ")
      ))
    isFirst = false

    # Add field name
    stringExpr = some(XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: opConcat,
      binaryLeft: stringExpr.get,
      binaryRight: XLangNode(kind: xnkStringLit, literalValue: fieldName & " = ")
    ))

    # Add field value (converted to string via $ function call)
    let fieldAccess = XLangNode(
      kind: xnkMemberAccessExpr,
      memberExpr: XLangNode(kind: xnkIdentifier, identName: "self"),
      memberName: fieldName
    )

    let fieldToString = XLangNode(
      kind: xnkCallExpr,
      callee: XLangNode(kind: xnkIdentifier, identName: "$"),
      args: @[fieldAccess]
    )

    stringExpr = some(XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: opConcat,
      binaryLeft: stringExpr.get,
      binaryRight: fieldToString
    ))

  # Add closing brace
  stringExpr = some(XLangNode(
    kind: xnkBinaryExpr,
    binaryOp: opConcat,
    binaryLeft: stringExpr.get,
    binaryRight: XLangNode(kind: xnkStringLit, literalValue: " }")
  ))

  # Create toString operator proc
  XLangNode(
    kind: xnkFuncDecl,
    funcName: makeToStringOpName(),
    params: @[param],
    returnType: some(XLangNode(kind: xnkNamedType, typeName: "string")),
    body: XLangNode(
      kind: xnkBlockStmt,
      blockBody: @[
        XLangNode(
          kind: xnkReturnStmt,
          returnExpr: stringExpr
        )
      ]
    ),
    isAsync: false,
    funcVisibility: "public",
    funcIsStatic: false
  )

proc transformRecordToStruct*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform C# record declarations into Nim structs with auto-generated methods
  if node.kind != xnkExternal_Record:
    return node

  let record = node
  var results: seq[XLangNode] = @[]

  # 1. Create struct declaration with fields from positional parameters
  var structNode = XLangNode(
    kind: xnkStructDecl,
    typeNameDecl: record.extRecordName,
    baseTypes: record.extRecordBaseTypes,
    members: @[]
  )

  # 2. Add fields from positional parameters
  for param in record.extRecordParams:
    let field = createRecordField(param)
    structNode.members.add(field)

  # 3. Add user-defined members from record body
  for member in record.extRecordMembers:
    structNode.members.add(member)

  results.add(structNode)

  # 4. Generate constructor proc (only if there are parameters)
  if record.extRecordParams.len > 0:
    results.add(generateRecordConstructor(record, structNode))

  # 5. Generate equality operator
  results.add(generateRecordEquality(record))

  # 6. Generate toString ($) operator
  results.add(generateRecordToString(record))

  # Return as block if multiple nodes, otherwise single node
  if results.len == 1:
    result = results[0]
  else:
    result = XLangNode(
      kind: xnkBlockStmt,
      blockBody: results
    )
