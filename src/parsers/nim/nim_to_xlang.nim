import macros, options, strutils
import ../../xlang/xlang_types #TODO: replace with xlangtypes.nim

## Nim AST to XLang AST Converter
## Converts NimNode (from Nim's macro system) to XLangNode
## This is the inverse of xlangtonim_complete.nim

proc convertNimToXLang*(node: NimNode): XLangNode

# Forward declarations for mutual recursion
proc convertNimType(node: NimNode): XLangNode
proc convertNimExpr(node: NimNode): XLangNode
proc convertNimStmt(node: NimNode): XLangNode
proc convertNimDecl(node: NimNode): XLangNode

# =============================================================================
# Type Conversions
# =============================================================================

proc convertNimType(node: NimNode): XLangNode =
  case node.kind
  of nnkIdent, nnkSym:
    result = XLangNode(kind: xnkNamedType, typeName: node.strVal)

  of nnkBracketExpr:
    # Could be array, seq, Table, generic type, etc.
    let baseType = node[0].strVal
    if baseType == "array":
      # array[size, T] or array[T]
      if node.len == 3:  # array[size, T]
        result = XLangNode(
          kind: xnkArrayType,
          elementType: convertNimType(node[2]),
          arraySize: some(convertNimExpr(node[1]))
        )
      elif node.len == 2:  # array[T]
        result = XLangNode(
          kind: xnkArrayType,
          elementType: convertNimType(node[1]),
          arraySize: none(XLangNode)
        )
      else:
        result = XLangNode(kind: xnkNamedType, typeName: "array")
    elif baseType in ["Table", "TableRef", "OrderedTable"]:
      # Table[K, V]
      if node.len == 3:
        result = XLangNode(
          kind: xnkMapType,
          keyType: convertNimType(node[1]),
          valueType: convertNimType(node[2])
        )
      else:
        result = XLangNode(kind: xnkNamedType, typeName: baseType)
    else:
      # Generic type like seq[T], Option[T], etc.
      result = XLangNode(
        kind: xnkGenericType,
        genericTypeName: baseType,
        genericArgs: @[]
      )
      for i in 1 ..< node.len:
        result.genericArgs.add(convertNimType(node[i]))

  of nnkPtrTy:
    result = XLangNode(
      kind: xnkPointerType,
      referentType: convertNimType(node[0])
    )

  of nnkRefTy:
    result = XLangNode(
      kind: xnkReferenceType,
      referentType: convertNimType(node[0])
    )

  of nnkProcTy:
    # proc(...): ReturnType
    result = XLangNode(
      kind: xnkFuncType,
      funcParams: @[],
      funcReturnType: none(XLangNode)
    )
    if node[0].kind == nnkFormalParams:
      let params = node[0]
      if params[0].kind != nnkEmpty:
        result.funcReturnType = some(convertNimType(params[0]))
      for i in 1 ..< params.len:
        result.funcParams.add(convertNimToXLang(params[i]))

  of nnkVarTy:
    # var T -> just treat as T for now
    result = convertNimType(node[0])

  of nnkDistinctTy:
    result = XLangNode(
      kind: xnkNamedType,
      typeName: "distinct_" & node[0].strVal
    )

  of nnkEmpty:
    result = XLangNode(kind: xnkNamedType, typeName: "void")

  else:
    result = XLangNode(kind: xnkNamedType, typeName: "UnknownType")

# =============================================================================
# Expression Conversions
# =============================================================================

proc convertNimExpr(node: NimNode): XLangNode =
  case node.kind
  of nnkIdent, nnkSym:
    result = XLangNode(kind: xnkIdentifier, identName: node.strVal)

  of nnkIntLit:
    result = XLangNode(kind: xnkIntLit, literalValue: $node.intVal)

  of nnkInt8Lit, nnkInt16Lit, nnkInt32Lit, nnkInt64Lit,
     nnkUIntLit, nnkUInt8Lit, nnkUInt16Lit, nnkUInt32Lit, nnkUInt64Lit:
    result = XLangNode(kind: xnkIntLit, literalValue: $node.intVal)

  of nnkFloatLit, nnkFloat32Lit, nnkFloat64Lit, nnkFloat128Lit:
    result = XLangNode(kind: xnkFloatLit, literalValue: $node.floatVal)

  of nnkStrLit, nnkRStrLit, nnkTripleStrLit:
    result = XLangNode(kind: xnkStringLit, literalValue: node.strVal)

  of nnkCharLit:
    result = XLangNode(kind: xnkCharLit, literalValue: $char(node.intVal))

  of nnkNilLit:
    result = XLangNode(kind: xnkNoneLit)

  of nnkInfix:
    # Binary operator: left op right
    result = XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: node[0].strVal,
      binaryLeft: convertNimExpr(node[1]),
      binaryRight: convertNimExpr(node[2])
    )

  of nnkPrefix:
    # Unary operator: op operand
    result = XLangNode(
      kind: xnkUnaryExpr,
      unaryOp: node[0].strVal,
      unaryOperand: convertNimExpr(node[1])
    )

  of nnkPostfix:
    # Usually for exports (name*)
    if node[0].strVal == "*":
      # This is an export marker, return the name
      result = convertNimExpr(node[1])
    else:
      result = XLangNode(
        kind: xnkUnaryExpr,
        unaryOp: node[0].strVal,
        unaryOperand: convertNimExpr(node[1])
      )

  of nnkCall, nnkCommand:
    result = XLangNode(
      kind: xnkCallExpr,
      callee: convertNimExpr(node[0]),
      args: @[]
    )
    for i in 1 ..< node.len:
      result.args.add(convertNimExpr(node[i]))

  of nnkCallStrLit:
    # Special call like fmt"..." or r"..."
    result = XLangNode(
      kind: xnkCallExpr,
      callee: convertNimExpr(node[0]),
      args: @[convertNimExpr(node[1])]
    )

  of nnkDotExpr:
    result = XLangNode(
      kind: xnkMemberAccessExpr,
      memberExpr: convertNimExpr(node[0]),
      memberName: node[1].strVal
    )

  of nnkBracketExpr:
    # Could be array access or generic instantiation
    # Context-dependent, but assume array access for expressions
    result = XLangNode(
      kind: xnkIndexExpr,
      indexExpr: convertNimExpr(node[0]),
      indexArgs: @[]
    )
    for i in 1 ..< node.len:
      result.indexArgs.add(convertNimExpr(node[i]))

  of nnkPar, nnkTupleConstr:
    result = XLangNode(kind: xnkTupleExpr, elements: @[])
    for child in node:
      result.elements.add(convertNimExpr(child))

  of nnkBracket:
    # Array/seq literal: [1, 2, 3]
    result = XLangNode(kind: xnkListExpr, elements: @[])
    for child in node:
      result.elements.add(convertNimExpr(child))

  of nnkCurly:
    # Set literal: {1, 2, 3}
    result = XLangNode(kind: xnkSetExpr, elements: @[])
    for child in node:
      result.elements.add(convertNimExpr(child))

  of nnkTableConstr:
    # Table constructor: {"a": 1, "b": 2}
    result = XLangNode(kind: xnkDictExpr, keys: @[], values: @[])
    for pair in node:
      if pair.kind == nnkExprColonExpr:
        result.keys.add(convertNimExpr(pair[0]))
        result.values.add(convertNimExpr(pair[1]))

  of nnkIfExpr:
    # If expression: if c: a else: b
    # Convert to ternary for simplicity
    if node.len >= 2:
      let elifBranch = node[0]
      if elifBranch.kind == nnkElifExpr and node.len == 2:
        let elseBranch = node[1]
        if elseBranch.kind == nnkElseExpr:
          result = XLangNode(
            kind: xnkTernaryExpr,
            ternaryCondition: convertNimExpr(elifBranch[0]),
            ternaryThen: convertNimExpr(elifBranch[1]),
            ternaryElse: convertNimExpr(elseBranch[0])
          )
        else:
          # Not a simple ternary, convert to if statement
          result = convertNimStmt(node)
      else:
        result = convertNimStmt(node)
    else:
      result = convertNimStmt(node)

  of nnkLambda:
    result = XLangNode(
      kind: xnkLambdaExpr,
      lambdaParams: @[],
      lambdaBody: convertNimStmt(node[6])  # Body is at index 6
    )
    if node[3].kind == nnkFormalParams:
      for i in 1 ..< node[3].len:
        result.lambdaParams.add(convertNimToXLang(node[3][i]))

  of nnkPragmaExpr:
    # Expression with pragma, return the expression
    result = convertNimExpr(node[0])

  of nnkExprColonExpr:
    # name: value (in named arguments, etc.)
    result = XLangNode(
      kind: xnkArgument,
      argName: some(node[0].strVal),
      argValue: convertNimExpr(node[1])
    )

  of nnkObjConstr:
    # Object constructor: Type(field: value)
    result = XLangNode(
      kind: xnkCallExpr,
      callee: convertNimExpr(node[0]),
      args: @[]
    )
    for i in 1 ..< node.len:
      result.args.add(convertNimExpr(node[i]))

  of nnkCast:
    result = XLangNode(
      kind: xnkCallExpr,
      callee: XLangNode(kind: xnkIdentifier, identName: "cast"),
      args: @[convertNimType(node[0]), convertNimExpr(node[1])]
    )

  of nnkConv:
    # Type conversion
    result = XLangNode(
      kind: xnkCallExpr,
      callee: convertNimType(node[0]),
      args: @[convertNimExpr(node[1])]
    )

  of nnkAddr:
    result = XLangNode(
      kind: xnkUnaryExpr,
      unaryOp: "addr",
      unaryOperand: convertNimExpr(node[0])
    )

  of nnkHiddenDeref:
    # Hidden dereference, just pass through
    result = convertNimExpr(node[0])

  of nnkDerefExpr:
    result = XLangNode(
      kind: xnkUnaryExpr,
      unaryOp: "[]",  # Dereference operator
      unaryOperand: convertNimExpr(node[0])
    )

  else:
    # Try as statement
    result = convertNimStmt(node)

# =============================================================================
# Statement Conversions
# =============================================================================

proc convertNimStmt(node: NimNode): XLangNode =
  case node.kind
  of nnkStmtList:
    result = XLangNode(kind: xnkBlockStmt, blockBody: @[])
    for child in node:
      if child.kind != nnkEmpty:
        result.blockBody.add(convertNimToXLang(child))

  of nnkBlockStmt:
    result = XLangNode(kind: xnkBlockStmt, blockBody: @[])
    # node[0] is label, node[1] is body
    if node[1].kind == nnkStmtList:
      for child in node[1]:
        if child.kind != nnkEmpty:
          result.blockBody.add(convertNimToXLang(child))
    else:
      result.blockBody.add(convertNimToXLang(node[1]))

  of nnkIfStmt:
    # if/elif/else chain
    result = XLangNode(
      kind: xnkIfStmt,
      ifCondition: nil,
      ifBody: nil,
      elseBody: none(XLangNode)
    )
    if node.len > 0:
      let firstBranch = node[0]
      if firstBranch.kind == nnkElifBranch:
        result.ifCondition = convertNimExpr(firstBranch[0])
        result.ifBody = convertNimStmt(firstBranch[1])

      # Handle else branch
      if node.len > 1:
        let lastBranch = node[^1]
        if lastBranch.kind == nnkElse:
          result.elseBody = some(convertNimStmt(lastBranch[0]))
        elif lastBranch.kind == nnkElifBranch:
          # Convert remaining elifs to nested if
          var current = result
          for i in 1 ..< node.len:
            let branch = node[i]
            if branch.kind == nnkElifBranch:
              let nestedIf = XLangNode(
                kind: xnkIfStmt,
                ifCondition: convertNimExpr(branch[0]),
                ifBody: convertNimStmt(branch[1]),
                elseBody: none(XLangNode)
              )
              current.elseBody = some(nestedIf)
              current = nestedIf
            elif branch.kind == nnkElse:
              current.elseBody = some(convertNimStmt(branch[0]))

  of nnkCaseStmt:
    result = XLangNode(
      kind: xnkSwitchStmt,
      switchExpr: convertNimExpr(node[0]),
      switchCases: @[],
      switchDefault: none(XLangNode)
    )
    for i in 1 ..< node.len:
      let branch = node[i]
      if branch.kind == nnkOfBranch:
        # Can have multiple values: of 1, 2, 3:
        for j in 0 ..< branch.len - 1:
          result.switchCases.add((
            caseExpr: convertNimExpr(branch[j]),
            caseBody: convertNimStmt(branch[^1])
          ))
      elif branch.kind == nnkElse:
        result.switchDefault = some(convertNimStmt(branch[0]))

  of nnkWhileStmt:
    result = XLangNode(
      kind: xnkWhileStmt,
      whileCondition: convertNimExpr(node[0]),
      whileBody: convertNimStmt(node[1])
    )

  of nnkForStmt:
    # for i in 0..<10: body
    result = XLangNode(
      kind: xnkForeachStmt,
      foreachVar: convertNimExpr(node[0]),
      foreachIter: convertNimExpr(node[^2]),
      foreachBody: convertNimStmt(node[^1])
    )

  of nnkReturnStmt:
    result = XLangNode(
      kind: xnkReturnStmt,
      returnExpr: if node[0].kind == nnkEmpty: none(XLangNode)
                  else: some(convertNimExpr(node[0]))
    )

  of nnkYieldStmt:
    result = XLangNode(
      kind: xnkYieldStmt,
      yieldStmt: convertNimExpr(node[0])
    )

  of nnkBreakStmt:
    result = XLangNode(
      kind: xnkBreakStmt,
      label: if node[0].kind == nnkEmpty: none(string)
             else: some(node[0].strVal)
    )

  of nnkContinueStmt:
    result = XLangNode(
      kind: xnkContinueStmt,
      label: if node[0].kind == nnkEmpty: none(string)
             else: some(node[0].strVal)
    )

  of nnkRaiseStmt:
    result = XLangNode(
      kind: xnkThrowStmt,
      throwExpr: convertNimExpr(node[0])
    )

  of nnkTryStmt:
    result = XLangNode(
      kind: xnkTryStmt,
      tryBody: convertNimStmt(node[0]),
      catchClauses: @[],
      finallyClause: none(XLangNode)
    )
    for i in 1 ..< node.len:
      let branch = node[i]
      if branch.kind == nnkExceptBranch:
        let catchNode = XLangNode(
          kind: xnkCatchStmt,
          catchType: if branch[0].kind == nnkEmpty: none(XLangNode)
                     else: some(convertNimType(branch[0])),
          catchVar: none(string),
          catchBody: convertNimStmt(branch[^1])
        )
        result.catchClauses.add(catchNode)
      elif branch.kind == nnkFinally:
        result.finallyClause = some(XLangNode(
          kind: xnkFinallyStmt,
          finallyBody: convertNimStmt(branch[0])
        ))

  of nnkDiscardStmt:
    result = XLangNode(kind: xnkPassStmt)

  of nnkDefer:
    result = XLangNode(
      kind: xnkDeferStmt,
      staticBody: convertNimStmt(node[0])
    )

  of nnkStaticStmt:
    result = XLangNode(
      kind: xnkStaticStmt,
      staticBody: convertNimStmt(node[0])
    )

  of nnkAsmStmt:
    result = XLangNode(
      kind: xnkAsmStmt,
      asmCode: if node.len > 1: node[1].strVal else: ""
    )

  of nnkCommentStmt:
    result = XLangNode(
      kind: xnkComment,
      commentText: node.strVal,
      isDocComment: node.strVal.startsWith("##")
    )

  else:
    # Try as expression
    result = convertNimExpr(node)

# =============================================================================
# Declaration Conversions
# =============================================================================

proc convertNimDecl(node: NimNode): XLangNode =
  case node.kind
  of nnkProcDef, nnkFuncDef, nnkMethodDef, nnkConverterDef:
    let name = if node[0].kind == nnkPostfix: node[0][1].strVal
               else: node[0].strVal

    result = XLangNode(
      kind: if node.kind == nnkMethodDef: xnkMethodDecl else: xnkFuncDecl,
      funcName: name,
      params: @[],
      returnType: none(XLangNode),
      body: convertNimStmt(node[6]),
      isAsync: false
    )

    # Check for pragmas (async, etc.)
    if node[4].kind == nnkPragma:
      for pragma in node[4]:
        if pragma.kind == nnkIdent and pragma.strVal == "async":
          result.isAsync = true

    # Process parameters
    if node[3].kind == nnkFormalParams:
      let params = node[3]
      if params[0].kind != nnkEmpty:
        result.returnType = some(convertNimType(params[0]))
      for i in 1 ..< params.len:
        result.params.add(convertNimToXLang(params[i]))

  of nnkTemplateDef:
    let name = if node[0].kind == nnkPostfix: node[0][1].strVal
               else: node[0].strVal

    result = XLangNode(
      kind: xnkTemplateDef,
      name: name,
      tplparams: @[],
      tmplbody: convertNimStmt(node[6]),
      isExported: node[0].kind == nnkPostfix
    )

    if node[3].kind == nnkFormalParams:
      for i in 1 ..< node[3].len:
        result.tplparams.add(convertNimToXLang(node[3][i]))

  of nnkMacroDef:
    let name = if node[0].kind == nnkPostfix: node[0][1].strVal
               else: node[0].strVal

    result = XLangNode(
      kind: xnkMacroDef,
      name: name,
      tplparams: @[],
      tmplbody: convertNimStmt(node[6]),
      isExported: node[0].kind == nnkPostfix
    )

    if node[3].kind == nnkFormalParams:
      for i in 1 ..< node[3].len:
        result.tplparams.add(convertNimToXLang(node[3][i]))

  of nnkVarSection:
    # Can have multiple variables
    if node.len == 1:
      let identDefs = node[0]
      result = XLangNode(
        kind: xnkVarDecl,
        declName: identDefs[0].strVal,
        declType: if identDefs[1].kind == nnkEmpty: none(XLangNode)
                  else: some(convertNimType(identDefs[1])),
        initializer: if identDefs[2].kind == nnkEmpty: none(XLangNode)
                     else: some(convertNimExpr(identDefs[2]))
      )
    else:
      # Multiple vars, wrap in block
      result = XLangNode(kind: xnkBlockStmt, blockBody: @[])
      for identDefs in node:
        result.blockBody.add(convertNimToXLang(identDefs))

  of nnkLetSection:
    if node.len == 1:
      let identDefs = node[0]
      result = XLangNode(
        kind: xnkLetDecl,
        declName: identDefs[0].strVal,
        declType: if identDefs[1].kind == nnkEmpty: none(XLangNode)
                  else: some(convertNimType(identDefs[1])),
        initializer: if identDefs[2].kind == nnkEmpty: none(XLangNode)
                     else: some(convertNimExpr(identDefs[2]))
      )
    else:
      result = XLangNode(kind: xnkBlockStmt, blockBody: @[])
      for identDefs in node:
        result.blockBody.add(convertNimToXLang(identDefs))

  of nnkConstSection:
    if node.len == 1:
      let identDefs = node[0]
      result = XLangNode(
        kind: xnkConstDecl,
        declName: identDefs[0].strVal,
        declType: if identDefs[1].kind == nnkEmpty: none(XLangNode)
                  else: some(convertNimType(identDefs[1])),
        initializer: if identDefs[2].kind == nnkEmpty: none(XLangNode)
                     else: some(convertNimExpr(identDefs[2]))
      )
    else:
      result = XLangNode(kind: xnkBlockStmt, blockBody: @[])
      for identDefs in node:
        result.blockBody.add(convertNimToXLang(identDefs))

  of nnkTypeSection:
    if node.len == 1:
      let typeDef = node[0]
      let name = if typeDef[0].kind == nnkPostfix: typeDef[0][1].strVal
                 else: typeDef[0].strVal

      case typeDef[2].kind
      of nnkEnumTy:
        result = XLangNode(
          kind: xnkEnumDecl,
          enumName: name,
          enumMembers: @[]
        )
        for i in 1 ..< typeDef[2].len:  # Skip empty node at 0
          let member = typeDef[2][i]
          if member.kind == nnkEnumFieldDef:
            result.enumMembers.add((
              name: member[0].strVal,
              value: some(convertNimExpr(member[1]))
            ))
          else:
            result.enumMembers.add((
              name: member.strVal,
              value: none(XLangNode)
            ))

      of nnkObjectTy:
        let objTy = typeDef[2]
        result = XLangNode(
          kind: xnkStructDecl,
          typeNameDecl: name,
          baseTypes: @[],
          members: @[]
        )

        # Check for ref
        if typeDef[2].kind == nnkRefTy:
          result.kind = xnkClassDecl

        # Handle inheritance
        if objTy.len > 1 and objTy[1].kind == nnkOfInherit:
          result.baseTypes.add(convertNimType(objTy[1][0]))

        # Handle fields
        if objTy.len > 2 and objTy[2].kind == nnkRecList:
          for identDefs in objTy[2]:
            result.members.add(XLangNode(
              kind: xnkFieldDecl,
              fieldName: identDefs[0].strVal,
              fieldType: convertNimType(identDefs[1]),
              fieldInitializer: if identDefs[2].kind == nnkEmpty: none(XLangNode)
                                else: some(convertNimExpr(identDefs[2]))
            ))

      of nnkRefTy:
        # ref object
        if typeDef[2][0].kind == nnkObjectTy:
          let objTy = typeDef[2][0]
          result = XLangNode(
            kind: xnkClassDecl,
            typeNameDecl: name,
            baseTypes: @[],
            members: @[]
          )

          if objTy.len > 1 and objTy[1].kind == nnkOfInherit:
            result.baseTypes.add(convertNimType(objTy[1][0]))

          if objTy.len > 2 and objTy[2].kind == nnkRecList:
            for identDefs in objTy[2]:
              result.members.add(XLangNode(
                kind: xnkFieldDecl,
                fieldName: identDefs[0].strVal,
                fieldType: convertNimType(identDefs[1]),
                fieldInitializer: if identDefs[2].kind == nnkEmpty: none(XLangNode)
                                  else: some(convertNimExpr(identDefs[2]))
              ))
        else:
          result = XLangNode(
            kind: xnkTypeDecl,
            typeDefName: name,
            typeDefBody: convertNimType(typeDef[2])
          )

      of nnkDistinctTy:
        result = XLangNode(
          kind: xnkDistinctTypeDef,
          distinctName: name,
          baseType: convertNimType(typeDef[2][0])
        )

      else:
        # Type alias
        result = XLangNode(
          kind: xnkTypeDecl,
          typeDefName: name,
          typeDefBody: convertNimType(typeDef[2])
        )
    else:
      # Multiple types
      result = XLangNode(kind: xnkBlockStmt, blockBody: @[])
      for typeDef in node:
        result.blockBody.add(convertNimToXLang(typeDef))

  of nnkImportStmt:
    if node.len == 1:
      result = XLangNode(
        kind: xnkImport,
        importPath: node[0].strVal,
        importAlias: none(string)
      )
    else:
      result = XLangNode(kind: xnkBlockStmt, blockBody: @[])
      for imp in node:
        result.blockBody.add(XLangNode(
          kind: xnkImport,
          importPath: imp.strVal,
          importAlias: none(string)
        ))

  of nnkExportStmt:
    result = XLangNode(
      kind: xnkExport,
      exportedDecl: convertNimToXLang(node[0])
    )

  of nnkIdentDefs:
    # Parameter or field definition
    result = XLangNode(
      kind: xnkParameter,
      paramName: node[0].strVal,
      paramType: convertNimType(node[1]),
      defaultValue: if node[2].kind == nnkEmpty: none(XLangNode)
                    else: some(convertNimExpr(node[2]))
    )

  else:
    result = convertNimStmt(node)

# =============================================================================
# Main Dispatcher
# =============================================================================

proc convertNimToXLang*(node: NimNode): XLangNode =
  case node.kind
  # Declarations
  of nnkProcDef, nnkFuncDef, nnkMethodDef, nnkConverterDef,
     nnkTemplateDef, nnkMacroDef,
     nnkVarSection, nnkLetSection, nnkConstSection,
     nnkTypeSection, nnkImportStmt, nnkExportStmt,
     nnkIdentDefs:
    result = convertNimDecl(node)

  # Statements
  of nnkStmtList, nnkBlockStmt, nnkIfStmt, nnkCaseStmt,
     nnkWhileStmt, nnkForStmt, nnkReturnStmt, nnkYieldStmt,
     nnkBreakStmt, nnkContinueStmt, nnkRaiseStmt, nnkTryStmt,
     nnkDiscardStmt, nnkDefer, nnkStaticStmt, nnkAsmStmt,
     nnkCommentStmt:
    result = convertNimStmt(node)

  # Expressions
  of nnkIdent, nnkSym, nnkIntLit, nnkFloatLit, nnkStrLit, nnkCharLit,
     nnkNilLit, nnkInfix, nnkPrefix, nnkPostfix, nnkCall, nnkCommand,
     nnkDotExpr, nnkBracketExpr, nnkPar, nnkTupleConstr, nnkBracket,
     nnkCurly, nnkTableConstr, nnkIfExpr, nnkLambda, nnkPragmaExpr,
     nnkExprColonExpr, nnkObjConstr, nnkCast, nnkConv, nnkAddr,
     nnkDerefExpr, nnkHiddenDeref:
    result = convertNimExpr(node)

  # Types (when used in type position)
  of nnkPtrTy, nnkRefTy, nnkProcTy, nnkVarTy, nnkDistinctTy:
    result = convertNimType(node)

  of nnkEmpty:
    result = XLangNode(kind: xnkPassStmt)

  else:
    # Default fallback
    result = XLangNode(
      kind: xnkComment,
      commentText: "Unhandled Nim node: " & $node.kind,
      isDocComment: false
    )

# =============================================================================
# Convenience Functions
# =============================================================================

proc parseNimCodeToXLang*(code: string): XLangNode {.compileTime.} =
  ## Parse Nim code string to XLang AST at compile time
  let nimAst = parseStmt(code)
  result = convertNimToXLang(nimAst)

macro nimToXLang*(code: untyped): untyped =
  ## Macro to convert Nim AST to XLang AST
  let xlangNode = convertNimToXLang(code)
  # Return the XLang node construction code
  result = quote do:
    `xlangNode`
