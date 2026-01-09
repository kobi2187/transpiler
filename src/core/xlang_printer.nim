## XLang Pretty Printer
## Outputs XLang nodes in the 11B syntax format for debugging and visualization.
##
## Usage:
##   echo $$node
##   echo printXlang(node)

import options
import strutils
import xlangtypes

# Forward declaration
proc printNode(node: XLangNode, indent: int): string

# =============================================================================
# Helper Functions
# =============================================================================

proc ind(level: int): string =
  ## Generate indentation (2 spaces per level)
  repeat("  ", level)

proc seqNodes(nodes: seq[XLangNode], indent: int, separator: string = "\n"): string =
  ## Print sequence of nodes
  var parts: seq[string]
  for n in nodes:
    let s = printNode(n, indent)
    if s.len > 0:
      parts.add(s)
  parts.join(separator)

proc visibility(v: string): string =
  ## Format visibility modifier
  if v.len > 0 and v != "public":
    " | visibility: " & v
  else:
    ""

proc binaryOpStr(op: BinaryOp): string =
  case op
  of opAdd: "+"
  of opSub: "-"
  of opMul: "*"
  of opDiv: "/"
  of opMod: "%"
  of opPow: "**"
  of opIntDiv: "//"
  of opBitAnd: "&"
  of opBitOr: "|"
  of opBitXor: "^"
  of opBitAndNot: "&^"
  of opShiftLeft: "shl"
  of opShiftRight: "shr"
  of opShiftRightUnsigned: "shru"
  of opEqual: "=="
  of opNotEqual: "!="
  of opLess: "<"
  of opLessEqual: "<="
  of opGreater: ">"
  of opGreaterEqual: ">="
  of opIdentical: "is"
  of opNotIdentical: "isnot"
  of opLogicalAnd: "and"
  of opLogicalOr: "or"
  of opAddAssign: "+="
  of opSubAssign: "-="
  of opMulAssign: "*="
  of opDivAssign: "/="
  of opModAssign: "%="
  of opBitAndAssign: "&="
  of opBitOrAssign: "|="
  of opBitXorAssign: "^="
  of opShiftLeftAssign: "<<="
  of opShiftRightAssign: ">>="
  of opShiftRightUnsignedAssign: ">>>="
  of opNullCoalesce: "??"
  of opElvis: "?:"
  of opRange: ".."
  of opIn: "in"
  of opNotIn: "notin"
  of opIs: "istype"
  of opAs: "as"
  of opConcat: "++"

proc unaryOpStr(op: UnaryOp): string =
  case op
  of opNegate: "-"
  of opUnaryPlus: "+"
  of opNot: "not"
  of opBitNot: "~"
  of opPreIncrement: "++pre"
  of opPostIncrement: "post++"
  of opPreDecrement: "--pre"
  of opPostDecrement: "post--"
  of opAddressOf: "addrof"
  of opDereference: "deref"
  of opAwait: "await"
  of opSpread: "..."
  of opIndexFromEnd: "^"
  of opChannelReceive: "<-"

# =============================================================================
# Main Print Function
# =============================================================================

proc printNode(node: XLangNode, indent: int): string =
  if node == nil:
    return ""

  let i = ind(indent)
  let i1 = ind(indent + 1)

  case node.kind

  # =========================================================================
  # Top-Level / Structure
  # =========================================================================

  of xnkFile:
    result = "module " & node.fileName & "\n"
    if node.sourceLang.len > 0:
      result &= i & "| source: " & node.sourceLang & "\n"
    if node.moduleDecls.len > 0:
      result &= i & "| body:\n"
      result &= seqNodes(node.moduleDecls, indent + 2)

  of xnkModule:
    result = i & "module " & node.moduleName & "\n"
    if node.moduleBody.len > 0:
      result &= i & "| body:\n"
      result &= seqNodes(node.moduleBody, indent + 2)

  of xnkNamespace:
    result = i & "namespace " & node.namespaceName & "\n"
    if node.namespaceBody.len > 0:
      result &= i & "| body:\n"
      result &= seqNodes(node.namespaceBody, indent + 2)

  # =========================================================================
  # Function Declarations
  # =========================================================================

  of xnkFuncDecl:
    result = i
    if node.isAsync:
      result &= "async "
    if node.funcIsStatic:
      result &= "static "
    result &= "func " & node.funcName & "\n"
    if node.params.len > 0:
      result &= i & "| params:\n"
      for p in node.params:
        result &= printNode(p, indent + 2) & "\n"
    if node.returnType.isSome:
      result &= i & "| returns: " & printNode(node.returnType.get, 0) & "\n"
    if node.funcVisibility.len > 0 and node.funcVisibility != "public":
      result &= i & "| visibility: " & node.funcVisibility & "\n"
    if node.body != nil:
      result &= i & "| body:\n"
      result &= printNode(node.body, indent + 2)

  of xnkMethodDecl:
    result = i
    if node.methodIsAsync:
      result &= "async "
    result &= "method " & node.methodName & "\n"
    if node.receiver.isSome:
      result &= i & "| receiver: " & printNode(node.receiver.get, 0) & "\n"
    if node.mparams.len > 0:
      result &= i & "| params:\n"
      for p in node.mparams:
        result &= printNode(p, indent + 2) & "\n"
    if node.mreturnType.isSome:
      result &= i & "| returns: " & printNode(node.mreturnType.get, 0) & "\n"
    if node.mbody != nil:
      result &= i & "| body:\n"
      result &= printNode(node.mbody, indent + 2)

  of xnkIteratorDecl:
    result = i & "iterator " & node.iteratorName & "\n"
    if node.iteratorParams.len > 0:
      result &= i & "| params:\n"
      for p in node.iteratorParams:
        result &= printNode(p, indent + 2) & "\n"
    if node.iteratorReturnType.isSome:
      result &= i & "| yields: " & printNode(node.iteratorReturnType.get, 0) & "\n"
    if node.iteratorBody != nil:
      result &= i & "| body:\n"
      result &= printNode(node.iteratorBody, indent + 2)

  of xnkConstructorDecl:
    result = i & "ctor\n"
    if node.constructorParams.len > 0:
      result &= i & "| params:\n"
      for p in node.constructorParams:
        result &= printNode(p, indent + 2) & "\n"
    if node.constructorInitializers.len > 0:
      result &= i & "| initializers:\n"
      for init in node.constructorInitializers:
        result &= printNode(init, indent + 2) & "\n"
    if node.constructorBody != nil:
      result &= i & "| body:\n"
      result &= printNode(node.constructorBody, indent + 2)

  of xnkDestructorDecl:
    result = i & "dtor\n"
    if node.destructorBody.isSome:
      result &= i & "| body:\n"
      result &= printNode(node.destructorBody.get, indent + 2)

  # =========================================================================
  # Type Declarations
  # =========================================================================

  of xnkClassDecl:
    result = i & "class " & node.typeNameDecl & "\n"
    result &= i & "| kind: class\n"
    if node.baseTypes.len > 0:
      result &= i & "| base: " & seqNodes(node.baseTypes, 0, ", ") & "\n"
    if node.members.len > 0:
      result &= i & "| members:\n"
      result &= seqNodes(node.members, indent + 2)

  of xnkStructDecl:
    result = i & "struct " & node.typeNameDecl & "\n"
    result &= i & "| kind: struct\n"
    if node.baseTypes.len > 0:
      result &= i & "| implements: " & seqNodes(node.baseTypes, 0, ", ") & "\n"
    if node.members.len > 0:
      result &= i & "| members:\n"
      result &= seqNodes(node.members, indent + 2)

  of xnkInterfaceDecl:
    result = i & "interface " & node.typeNameDecl & "\n"
    result &= i & "| kind: interface\n"
    if node.baseTypes.len > 0:
      result &= i & "| extends: " & seqNodes(node.baseTypes, 0, ", ") & "\n"
    if node.members.len > 0:
      result &= i & "| methods:\n"
      result &= seqNodes(node.members, indent + 2)

  of xnkEnumDecl:
    result = i & "enum " & node.enumName & "\n"
    if node.enumMembers.len > 0:
      result &= i & "| values:\n"
      for m in node.enumMembers:
        result &= printNode(m, indent + 2) & "\n"

  of xnkEnumMember:
    result = i & node.enumMemberName
    if node.enumMemberValue.isSome:
      result &= " = " & printNode(node.enumMemberValue.get, 0)

  of xnkTypeDecl:
    result = i & "type " & node.typeDefName & " = " & printNode(node.typeDefBody, 0)

  of xnkTypeAlias:
    result = i & "alias " & node.aliasName & " = " & printNode(node.aliasTarget, 0)

  of xnkAbstractDecl:
    result = i & "abstract " & node.abstractName & "\n"
    if node.abstractBody.len > 0:
      result &= i & "| members:\n"
      result &= seqNodes(node.abstractBody, indent + 2)

  of xnkConceptDecl:
    result = i & "concept " & node.conceptDeclName & "\n"
    if node.conceptRequirements.len > 0:
      result &= i & "| requirements:\n"
      for r in node.conceptRequirements:
        result &= printNode(r, indent + 2) & "\n"

  of xnkConceptDef:
    result = i & "concept " & node.conceptName & "\n"
    result &= i & "| body:\n"
    result &= printNode(node.conceptBody, indent + 2)

  of xnkConceptRequirement:
    result = i & node.reqName
    if node.reqParams.len > 0:
      result &= "(" & seqNodes(node.reqParams, 0, ", ") & ")"
    if node.reqReturn.isSome:
      result &= " -> " & printNode(node.reqReturn.get, 0)

  # =========================================================================
  # Variable/Field Declarations
  # =========================================================================

  of xnkVarDecl:
    result = i & "var " & node.declName
    if node.declType.isSome:
      result &= ": " & printNode(node.declType.get, 0)
    if node.initializer.isSome:
      result &= " = " & printNode(node.initializer.get, 0)

  of xnkLetDecl:
    result = i & "let " & node.declName
    if node.declType.isSome:
      result &= ": " & printNode(node.declType.get, 0)
    if node.initializer.isSome:
      result &= " = " & printNode(node.initializer.get, 0)

  of xnkConstDecl:
    result = i & "const " & node.declName
    if node.declType.isSome:
      result &= ": " & printNode(node.declType.get, 0)
    if node.initializer.isSome:
      result &= " = " & printNode(node.initializer.get, 0)

  of xnkFieldDecl:
    result = i & node.fieldName & ": " & printNode(node.fieldType, 0)
    if node.fieldInitializer.isSome:
      result &= " = " & printNode(node.fieldInitializer.get, 0)

  of xnkParameter:
    result = i & node.paramName
    if node.paramType.isSome:
      result &= ": " & printNode(node.paramType.get, 0)
    if node.defaultValue.isSome:
      result &= " = " & printNode(node.defaultValue.get, 0)

  of xnkGenericParameter:
    result = i & node.genericParamName
    if node.genericParamConstraints.len > 0:
      result &= ": " & seqNodes(node.genericParamConstraints, 0, " + ")

  of xnkArgument:
    if node.argName.isSome:
      result = node.argName.get & ": "
    result &= printNode(node.argValue, 0)

  # =========================================================================
  # Statements
  # =========================================================================

  of xnkBlockStmt:
    for stmt in node.blockBody:
      result &= printNode(stmt, indent) & "\n"

  of xnkAsgn:
    result = i & printNode(node.asgnLeft, 0) & " = " & printNode(node.asgnRight, 0)

  of xnkIfStmt:
    result = i & "if " & printNode(node.ifCondition, 0) & ":\n"
    result &= printNode(node.ifBody, indent + 1)
    if node.elseBody.isSome:
      result &= "\n" & i & "else:\n"
      result &= printNode(node.elseBody.get, indent + 1)

  of xnkSwitchStmt:
    result = i & "match " & printNode(node.switchExpr, 0) & "\n"
    for c in node.switchCases:
      result &= printNode(c, indent)

  of xnkCaseClause:
    result = i & "| " & seqNodes(node.caseValues, 0, ", ") & ":\n"
    result &= printNode(node.caseBody, indent + 2)
    if node.caseFallthrough:
      result &= "\n" & i1 & "fallthrough"

  of xnkDefaultClause:
    result = i & "| _:\n"
    result &= printNode(node.defaultBody, indent + 2)

  of xnkWhileStmt:
    result = i & "while " & printNode(node.whileCondition, 0) & ":\n"
    result &= printNode(node.whileBody, indent + 1)

  of xnkDoWhileStmt:
    result = i & "do:\n"
    result &= printNode(node.whileBody, indent + 1)
    result &= "\n" & i & "while " & printNode(node.whileCondition, 0)

  of xnkForeachStmt:
    result = i & "foreach " & printNode(node.foreachVar, 0) & " in " & printNode(node.foreachIter, 0) & ":\n"
    result &= printNode(node.foreachBody, indent + 1)

  of xnkTryStmt:
    result = i & "try:\n"
    result &= printNode(node.tryBody, indent + 1)
    for c in node.catchClauses:
      result &= "\n" & printNode(c, indent)
    if node.finallyClause.isSome:
      result &= "\n" & i & "finally:\n"
      result &= printNode(node.finallyClause.get, indent + 1)

  of xnkCatchStmt:
    result = i & "catch"
    if node.catchVar.isSome:
      result &= " " & node.catchVar.get
    if node.catchType.isSome:
      result &= ": " & printNode(node.catchType.get, 0)
    result &= ":\n"
    result &= printNode(node.catchBody, indent + 1)

  of xnkFinallyStmt:
    result = printNode(node.finallyBody, indent)

  of xnkReturnStmt:
    result = i & "return"
    if node.returnExpr.isSome:
      result &= " " & printNode(node.returnExpr.get, 0)

  of xnkBreakStmt:
    result = i & "break"
    if node.label.isSome:
      result &= " ^" & node.label.get

  of xnkContinueStmt:
    result = i & "continue"
    if node.label.isSome:
      result &= " ^" & node.label.get

  of xnkThrowStmt:
    result = i & "throw " & printNode(node.throwExpr, 0)

  of xnkRaiseStmt:
    result = i & "raise"
    if node.raiseExpr.isSome:
      result &= " " & printNode(node.raiseExpr.get, 0)

  of xnkAssertStmt:
    result = i & "assert " & printNode(node.assertCond, 0)
    if node.assertMsg.isSome:
      result &= ", " & printNode(node.assertMsg.get, 0)

  of xnkIteratorYield:
    result = i & "yield"
    if node.iteratorYieldValue.isSome:
      result &= " " & printNode(node.iteratorYieldValue.get, 0)

  of xnkIteratorDelegate:
    result = i & "yield from " & printNode(node.iteratorDelegateExpr, 0)

  of xnkYieldStmt:
    result = i & "yield"
    if node.yieldStmt.isSome:
      result &= " " & printNode(node.yieldStmt.get, 0)

  of xnkYieldExpr:
    result = "yield"
    if node.yieldExpr.isSome:
      result &= " " & printNode(node.yieldExpr.get, 0)

  of xnkYieldFromStmt:
    result = i & "yield from " & printNode(node.yieldFromExpr, 0)

  of xnkPassStmt:
    result = i & "pass"

  of xnkDiscardStmt:
    result = i & "discard"
    if node.discardExpr.isSome:
      result &= " " & printNode(node.discardExpr.get, 0)

  of xnkEmptyStmt:
    result = i & "# empty"

  of xnkLabeledStmt:
    result = i & "^" & node.labelName & "\n"
    result &= printNode(node.labeledStmt, indent)

  of xnkGotoStmt:
    result = i & "goto ^" & node.gotoLabel

  of xnkDeferStmt:
    result = i & "defer:\n"
    result &= printNode(node.staticBody, indent + 1)

  of xnkStaticStmt:
    result = i & "static:\n"
    result &= printNode(node.staticBody, indent + 1)

  of xnkUsingStmt:
    result = i & "using " & printNode(node.usingExpr, 0) & ":\n"
    result &= printNode(node.usingBody, indent + 1)

  of xnkWithItem:
    result = printNode(node.contextExpr, 0)
    if node.asExpr.isSome:
      result &= " as " & printNode(node.asExpr.get, 0)

  of xnkResourceItem:
    result = printNode(node.resourceExpr, 0)
    if node.resourceVar.isSome:
      result &= " as " & printNode(node.resourceVar.get, 0)

  of xnkUnlessStmt:
    result = i & "unless " & printNode(node.unlessCondition, 0) & ":\n"
    result &= printNode(node.unlessBody, indent + 1)

  of xnkUntilStmt:
    result = i & "until " & printNode(node.untilCondition, 0) & ":\n"
    result &= printNode(node.untilBody, indent + 1)

  of xnkStaticAssert:
    result = i & "static assert " & printNode(node.staticAssertCondition, 0)
    if node.staticAssertMessage.isSome:
      result &= ", " & printNode(node.staticAssertMessage.get, 0)

  of xnkTypeSwitchStmt:
    result = i & "match type " & printNode(node.typeSwitchExpr, 0)
    if node.typeSwitchVar.isSome:
      result &= " as " & printNode(node.typeSwitchVar.get, 0)
    result &= "\n"
    for c in node.typeSwitchCases:
      result &= printNode(c, indent)

  of xnkTypeCaseClause:
    result = i & "| " & printNode(node.caseType, 0) & ":\n"
    result &= printNode(node.typeCaseBody, indent + 2)

  of xnkCaseStmt:
    result = i & "case"
    if node.expr.isSome:
      result &= " " & printNode(node.expr.get, 0)
    result &= "\n"
    for b in node.branches:
      result &= printNode(b, indent)
    if node.caseElseBody.isSome:
      result &= i & "else:\n"
      result &= printNode(node.caseElseBody.get, indent + 1)

  of xnkSwitchCase:
    result = i & "| " & seqNodes(node.switchCaseConditions, 0, ", ") & ":\n"
    result &= printNode(node.switchCaseBody, indent + 2)

  # =========================================================================
  # Expressions
  # =========================================================================

  of xnkBinaryExpr:
    result = printNode(node.binaryLeft, 0) & " " & binaryOpStr(node.binaryOp) & " " & printNode(node.binaryRight, 0)

  of xnkUnaryExpr:
    let op = unaryOpStr(node.unaryOp)
    case node.unaryOp
    of opPostIncrement, opPostDecrement:
      result = printNode(node.unaryOperand, 0) & op
    else:
      result = op & " " & printNode(node.unaryOperand, 0)

  of xnkCallExpr:
    result = printNode(node.callee, 0) & "(" & seqNodes(node.args, 0, ", ") & ")"

  of xnkThisCall:
    result = "this(" & seqNodes(node.arguments, 0, ", ") & ")"

  of xnkBaseCall:
    result = "base(" & seqNodes(node.arguments, 0, ", ") & ")"

  of xnkIndexExpr:
    result = printNode(node.indexExpr, 0) & "[" & seqNodes(node.indexArgs, 0, ", ") & "]"

  of xnkSliceExpr:
    result = printNode(node.sliceExpr, 0) & "["
    if node.sliceStart.isSome:
      result &= printNode(node.sliceStart.get, 0)
    result &= ".."
    if node.sliceEnd.isSome:
      result &= printNode(node.sliceEnd.get, 0)
    if node.sliceStep.isSome:
      result &= ":" & printNode(node.sliceStep.get, 0)
    result &= "]"

  of xnkMemberAccessExpr:
    result = printNode(node.memberExpr, 0) & "." & node.memberName

  of xnkDotExpr:
    result = printNode(node.dotBase, 0) & "." & printNode(node.member, 0)

  of xnkBracketExpr:
    result = printNode(node.base, 0) & "[" & printNode(node.index, 0) & "]"

  of xnkLambdaExpr:
    result = "lambda"
    if node.lambdaParams.len > 0:
      result &= "(" & seqNodes(node.lambdaParams, 0, ", ") & ")"
    if node.lambdaReturnType.isSome:
      result &= " -> " & printNode(node.lambdaReturnType.get, 0)
    result &= ":\n" & printNode(node.lambdaBody, indent + 1)

  of xnkLambdaProc:
    result = "proc"
    if node.lambdaProcParams.len > 0:
      result &= "(" & seqNodes(node.lambdaProcParams, 0, ", ") & ")"
    if node.lambdaProcReturn.isSome:
      result &= " -> " & printNode(node.lambdaProcReturn.get, 0)
    result &= ":\n" & printNode(node.lambdaProcBody, indent + 1)

  of xnkArrowFunc:
    result = "(" & seqNodes(node.arrowParams, 0, ", ") & ")"
    if node.arrowReturnType.isSome:
      result &= " -> " & printNode(node.arrowReturnType.get, 0)
    result &= " => " & printNode(node.arrowBody, 0)

  of xnkTypeAssertion:
    result = printNode(node.assertExpr, 0) & " as " & printNode(node.assertType, 0)

  of xnkCastExpr:
    result = "cast(" & printNode(node.castExpr, 0) & "/" & printNode(node.castType, 0) & ")"

  of xnkThisExpr:
    result = "self"

  of xnkBaseExpr:
    result = "base"

  of xnkRefExpr:
    result = "ref " & printNode(node.refExpr, 0)

  of xnkDefaultExpr:
    result = "default"
    if node.defaultType.isSome:
      result &= "(" & printNode(node.defaultType.get, 0) & ")"

  of xnkTypeOfExpr:
    result = "typeof(" & printNode(node.typeOfType, 0) & ")"

  of xnkSizeOfExpr:
    result = "sizeof(" & printNode(node.sizeOfType, 0) & ")"

  of xnkCheckedExpr:
    result = (if node.isChecked: "checked" else: "unchecked") & "!(" & printNode(node.checkedExpr, 0) & ")"

  of xnkMethodReference:
    result = printNode(node.refObject, 0) & "::" & node.refMethod

  # =========================================================================
  # Literals
  # =========================================================================

  of xnkIntLit, xnkFloatLit:
    result = node.literalValue

  of xnkNumberLit:
    result = node.numberValue

  of xnkStringLit:
    result = "\"" & node.literalValue & "\""

  of xnkCharLit:
    result = "'" & node.literalValue & "'"

  of xnkBoolLit:
    result = $node.boolValue

  of xnkNoneLit:
    result = "None"

  of xnkNilLit:
    result = "nil"

  of xnkSymbolLit:
    result = ":" & node.symbolValue

  of xnkSequenceLiteral, xnkArrayLiteral:
    result = "[" & seqNodes(node.elements, 0, ", ") & "]"

  of xnkSetLiteral:
    result = "{" & seqNodes(node.elements, 0, ", ") & "}"

  of xnkTupleExpr:
    result = "(" & seqNodes(node.elements, 0, ", ") & ")"

  of xnkMapLiteral:
    result = "{"
    for i, e in node.entries:
      if i > 0: result &= ", "
      result &= printNode(e, 0)
    result &= "}"

  of xnkDictEntry:
    result = printNode(node.key, 0) & ": " & printNode(node.value, 0)

  of xnkListExpr, xnkSetExpr:
    result = "[" & seqNodes(node.legacyElements, 0, ", ") & "]"

  of xnkDictExpr:
    result = "{" & seqNodes(node.legacyEntries, 0, ", ") & "}"

  of xnkArrayLit:
    result = "[" & seqNodes(node.legacyArrayElements, 0, ", ") & "]"

  of xnkImplicitArrayCreation:
    result = "[" & seqNodes(node.implicitArrayElements, 0, ", ") & "]"

  of xnkTupleConstr:
    result = "(" & seqNodes(node.tupleElements, 0, ", ") & ")"

  # =========================================================================
  # Types
  # =========================================================================

  of xnkNamedType:
    result = node.typeName

  of xnkArrayType:
    result = "array[" & printNode(node.elementType, 0)
    if node.arraySize.isSome:
      result &= ", " & printNode(node.arraySize.get, 0)
    result &= "]"

  of xnkMapType:
    result = "Map<" & printNode(node.keyType, 0) & ", " & printNode(node.valueType, 0) & ">"

  of xnkFuncType:
    result = "func(" & seqNodes(node.funcParams, 0, ", ") & ")"
    if node.funcReturnType.isSome:
      result &= " -> " & printNode(node.funcReturnType.get, 0)

  of xnkFunctionType:
    result = "func(" & seqNodes(node.functionTypeParams, 0, ", ") & ")"
    if node.functionTypeReturn.isSome:
      result &= " -> " & printNode(node.functionTypeReturn.get, 0)

  of xnkPointerType:
    result = "ptr " & printNode(node.referentType, 0)

  of xnkReferenceType:
    result = "ref " & printNode(node.referentType, 0)

  of xnkGenericType:
    result = node.genericTypeName & "<" & seqNodes(node.genericArgs, 0, ", ") & ">"

  of xnkUnionType:
    result = seqNodes(node.unionTypes, 0, " | ")

  of xnkIntersectionType:
    result = seqNodes(node.typeMembers, 0, " & ")

  of xnkDistinctType:
    result = "distinct " & printNode(node.distinctBaseType, 0)

  of xnkTupleType:
    result = "(" & seqNodes(node.tupleTypeElements, 0, ", ") & ")"

  of xnkDynamicType:
    result = "dynamic"
    if node.dynamicConstraint.isSome:
      result &= "<" & printNode(node.dynamicConstraint.get, 0) & ">"

  of xnkAbstractType:
    result = "abstract " & node.abstractTypeName

  # =========================================================================
  # Identifiers and Names
  # =========================================================================

  of xnkIdentifier:
    result = node.identName

  of xnkQualifiedName:
    result = printNode(node.qualifiedLeft, 0) & "." & printNode(node.qualifiedRight, 0)

  of xnkAliasQualifiedName:
    result = node.aliasQualifier & "::" & node.aliasQualifiedName

  of xnkGenericName:
    result = node.genericNameIdentifier & "<" & seqNodes(node.genericNameArgs, 0, ", ") & ">"

  of xnkInstanceVar:
    result = "@" & node.varName

  of xnkClassVar:
    result = "@@" & node.varName

  of xnkGlobalVar:
    result = "$" & node.varName

  # =========================================================================
  # Imports / Exports
  # =========================================================================

  of xnkImport:
    result = i & "import " & node.importPath
    if node.importAlias.isSome:
      result &= " as " & node.importAlias.get

  of xnkImportStmt:
    result = i & "import " & node.imports.join(", ")

  of xnkFromImportStmt:
    result = i & "from " & node.module & " import " & node.fromImports.join(", ")

  of xnkExport:
    result = i & "export " & printNode(node.exportedDecl, 0)

  of xnkExportStmt:
    result = i & "export " & node.exports.join(", ")

  of xnkInclude:
    result = i & "include " & printNode(node.includeName, 0)

  of xnkExtend:
    result = i & "extend " & printNode(node.extendName, 0)

  # =========================================================================
  # Attributes / Decorators / Pragmas
  # =========================================================================

  of xnkAttribute:
    result = "#[" & node.attrName
    if node.attrArgs.len > 0:
      result &= "(" & seqNodes(node.attrArgs, 0, ", ") & ")"
    result &= "]"

  of xnkDecorator:
    result = i & "#[" & printNode(node.decoratorExpr, 0) & "]"

  of xnkPragma:
    result = "#pragma(" & seqNodes(node.pragmas, 0, ", ") & ")"

  # =========================================================================
  # Comments
  # =========================================================================

  of xnkComment:
    if node.isDocComment:
      result = i & "## " & node.commentText
    else:
      result = i & "# " & node.commentText

  # =========================================================================
  # Templates / Macros
  # =========================================================================

  of xnkTemplateDef, xnkMacroDef:
    let keyword = if node.kind == xnkTemplateDef: "template" else: "macro"
    result = i & keyword & " " & node.name
    if node.tplparams.len > 0:
      result &= "(" & seqNodes(node.tplparams, 0, ", ") & ")"
    result &= "\n" & i & "| body:\n"
    result &= printNode(node.tmplbody, indent + 2)

  of xnkTemplateDecl:
    result = i & "template " & node.templateName
    if node.templateParams.len > 0:
      result &= "(" & seqNodes(node.templateParams, 0, ", ") & ")"
    result &= "\n" & i & "| body:\n"
    result &= seqNodes(node.templateBody, indent + 2)

  of xnkMacroDecl:
    result = i & "macro " & node.macroName
    if node.macroParams.len > 0:
      result &= "(" & seqNodes(node.macroParams, 0, ", ") & ")"
    result &= "\n" & i & "| body:\n"
    result &= printNode(node.macroBody, indent + 2)

  of xnkMixinDecl:
    result = i & "mixin " & printNode(node.mixinDeclExpr, 0)

  of xnkMixinStmt:
    result = i & "mixin " & node.mixinNames.join(", ")

  of xnkBindStmt:
    result = i & "bind " & node.bindNames.join(", ")

  of xnkAsmStmt:
    result = i & "asm \"" & node.asmCode & "\""

  # =========================================================================
  # Destructuring
  # =========================================================================

  of xnkTupleUnpacking:
    result = i & "var (" & seqNodes(node.unpackTargets, 0, ", ") & ") = " & printNode(node.unpackExpr, 0)

  of xnkDestructureObj:
    result = i & "var {" & node.destructObjFields.join(", ") & "} = " & printNode(node.destructObjSource, 0)

  of xnkDestructureArray:
    var parts = node.destructArrayVars
    if node.destructArrayRest.isSome:
      parts.add("*" & node.destructArrayRest.get)
    result = i & "var [" & parts.join(", ") & "] = " & printNode(node.destructArraySource, 0)

  # =========================================================================
  # Distinct Types
  # =========================================================================

  of xnkDistinctTypeDef:
    result = i & "distinct " & node.distinctName & " = " & printNode(node.baseType, 0)

  # =========================================================================
  # Module Declarations
  # =========================================================================

  of xnkModuleDecl:
    result = i & "module " & node.moduleNameDecl & "\n"
    if node.moduleMembers.len > 0:
      result &= i & "| members:\n"
      result &= seqNodes(node.moduleMembers, indent + 2)

  # =========================================================================
  # C FFI
  # =========================================================================

  of xnkLibDecl:
    result = i & "lib " & node.libName & "\n"
    if node.libBody.len > 0:
      result &= i & "| body:\n"
      result &= seqNodes(node.libBody, indent + 2)

  of xnkCFuncDecl:
    result = i & "cfunc " & node.cfuncName
    if node.cfuncParams.len > 0:
      result &= "(" & seqNodes(node.cfuncParams, 0, ", ") & ")"
    if node.cfuncReturnType.isSome:
      result &= " -> " & printNode(node.cfuncReturnType.get, 0)

  of xnkExternalVar:
    result = i & "extern " & node.extVarName & ": " & printNode(node.extVarType, 0)

  # =========================================================================
  # Misc Expressions
  # =========================================================================

  of xnkCompFor:
    result = "for " & seqNodes(node.vars, 0, ", ") & " in " & printNode(node.iter, 0)

  of xnkProcLiteral:
    result = "proc:\n" & printNode(node.procBody, indent + 1)

  of xnkProcPointer:
    result = "procptr(" & node.procPointerName & ")"

  of xnkMetadata:
    result = i & "meta:\n"
    for e in node.metadataEntries:
      result &= printNode(e, indent + 1) & "\n"

  # =========================================================================
  # External / Source-Specific Kinds
  # =========================================================================

  of xnkExternal_Property:
    result = i & "property " & node.extPropName
    if node.extPropType.isSome:
      result &= ": " & printNode(node.extPropType.get, 0)
    result &= visibility(node.extPropVisibility)
    if node.extPropIsStatic:
      result &= " | static: true"
    result &= "\n"
    if node.extPropHasGetter:
      result &= i & "| get:"
      if node.extPropGetterBody.isSome:
        result &= "\n" & printNode(node.extPropGetterBody.get, indent + 2)
      else:
        result &= " auto"
      result &= "\n"
    if node.extPropHasSetter:
      result &= i & "| set:"
      if node.extPropSetterBody.isSome:
        result &= "\n" & printNode(node.extPropSetterBody.get, indent + 2)
      else:
        result &= " auto"
      result &= "\n"
    if node.extPropInitializer.isSome:
      result &= i & "| init: " & printNode(node.extPropInitializer.get, 0) & "\n"

  of xnkExternal_Indexer:
    result = i & "indexer\n"
    if node.extIndexerParams.len > 0:
      result &= i & "| params: " & seqNodes(node.extIndexerParams, 0, ", ") & "\n"
    result &= i & "| type: " & printNode(node.extIndexerType, 0) & "\n"
    if node.extIndexerGetter.isSome:
      result &= i & "| get:\n" & printNode(node.extIndexerGetter.get, indent + 2) & "\n"
    if node.extIndexerSetter.isSome:
      result &= i & "| set:\n" & printNode(node.extIndexerSetter.get, indent + 2) & "\n"

  of xnkExternal_Event:
    result = i & "event " & node.extEventName & ": " & printNode(node.extEventType, 0) & "\n"
    if node.extEventAdd.isSome:
      result &= i & "| add:\n" & printNode(node.extEventAdd.get, indent + 2) & "\n"
    if node.extEventRemove.isSome:
      result &= i & "| remove:\n" & printNode(node.extEventRemove.get, indent + 2) & "\n"

  of xnkExternal_Delegate:
    result = i & "delegate " & node.extDelegateName
    if node.extDelegateParams.len > 0:
      result &= "(" & seqNodes(node.extDelegateParams, 0, ", ") & ")"
    if node.extDelegateReturnType.isSome:
      result &= " -> " & printNode(node.extDelegateReturnType.get, 0)

  of xnkExternal_Operator:
    result = i & "operator `" & node.extOperatorSymbol & "`"
    if node.extOperatorParams.len > 0:
      result &= "(" & seqNodes(node.extOperatorParams, 0, ", ") & ")"
    result &= " -> " & printNode(node.extOperatorReturnType, 0) & "\n"
    if node.extOperatorBody.isSome:
      result &= i & "| body:\n" & printNode(node.extOperatorBody.get, indent + 2)

  of xnkExternal_ConversionOp:
    result = i & (if node.extConversionIsImplicit: "implicit" else: "explicit") & " conversion"
    result &= "(" & node.extConversionParamName & ": " & printNode(node.extConversionFromType, 0) & ")"
    result &= " -> " & printNode(node.extConversionToType, 0) & "\n"
    result &= i & "| body:\n" & printNode(node.extConversionBody, indent + 2)

  of xnkExternal_Resource:
    result = i & "using\n"
    result &= i & "| resources:\n"
    for r in node.extResourceItems:
      result &= printNode(r, indent + 2) & "\n"
    result &= i & "| body:\n"
    result &= printNode(node.extResourceBody, indent + 2)

  of xnkExternal_Fixed:
    result = i & "fixed\n"
    result &= i & "| declarations:\n"
    for d in node.extFixedDeclarations:
      result &= printNode(d, indent + 2) & "\n"
    result &= i & "| body:\n"
    result &= printNode(node.extFixedBody, indent + 2)

  of xnkExternal_Lock:
    result = i & "lock " & printNode(node.extLockExpr, 0) & ":\n"
    result &= printNode(node.extLockBody, indent + 1)

  of xnkExternal_Unsafe:
    result = i & "unsafe:\n"
    result &= printNode(node.extUnsafeBody, indent + 1)

  of xnkExternal_Checked:
    result = i & (if node.extCheckedIsChecked: "checked" else: "unchecked") & ":\n"
    result &= printNode(node.extCheckedBody, indent + 1)

  of xnkExternal_SafeNavigation:
    result = printNode(node.extSafeNavObject, 0) & "?." & node.extSafeNavMember

  of xnkExternal_NullCoalesce:
    result = printNode(node.extNullCoalesceLeft, 0) & " ?? " & printNode(node.extNullCoalesceRight, 0)

  of xnkExternal_ThrowExpr:
    result = "throw " & printNode(node.extThrowExprValue, 0)

  of xnkExternal_SwitchExpr:
    result = "switch " & printNode(node.extSwitchExprValue, 0) & " {\n"
    for arm in node.extSwitchExprArms:
      result &= printNode(arm, indent + 1) & "\n"
    result &= i & "}"

  of xnkExternal_StackAlloc:
    result = "stackalloc " & printNode(node.extStackAllocType, 0)
    if node.extStackAllocSize.isSome:
      result &= "[" & printNode(node.extStackAllocSize.get, 0) & "]"

  of xnkExternal_StringInterp:
    result = "$\""
    for i, part in node.extInterpParts:
      if node.extInterpIsExpr[i]:
        result &= "{" & printNode(part, 0) & "}"
      else:
        result &= printNode(part, 0)
    result &= "\""

  of xnkExternal_Ternary:
    result = printNode(node.extTernaryCondition, 0) & " ? " & printNode(node.extTernaryThen, 0) & " : " & printNode(node.extTernaryElse, 0)

  of xnkExternal_DoWhile:
    result = i & "do:\n"
    result &= printNode(node.extDoWhileBody, indent + 1)
    result &= "\n" & i & "while " & printNode(node.extDoWhileCondition, 0)

  of xnkExternal_ForStmt:
    result = i & "for"
    if node.extForInit.isSome:
      result &= " " & printNode(node.extForInit.get, 0)
    result &= ";"
    if node.extForCond.isSome:
      result &= " " & printNode(node.extForCond.get, 0)
    result &= ";"
    if node.extForIncrement.isSome:
      result &= " " & printNode(node.extForIncrement.get, 0)
    result &= ":\n"
    if node.extForBody.isSome:
      result &= printNode(node.extForBody.get, indent + 1)

  of xnkExternal_Interface:
    result = i & "interface " & node.extInterfaceName & "\n"
    result &= i & "| kind: interface\n"
    if node.extInterfaceBaseTypes.len > 0:
      result &= i & "| extends: " & seqNodes(node.extInterfaceBaseTypes, 0, ", ") & "\n"
    if node.extInterfaceMembers.len > 0:
      result &= i & "| methods:\n"
      result &= seqNodes(node.extInterfaceMembers, indent + 2)

  of xnkExternal_Generator:
    result = "(" & printNode(node.extGenExpr, 0) & " "
    for f in node.extGenFor:
      result &= printNode(f, 0) & " "
    for cond in node.extGenIf:
      result &= "if " & printNode(cond, 0) & " "
    result &= ")"

  of xnkExternal_Comprehension:
    result = "[" & printNode(node.extCompExpr, 0) & " "
    for f in node.extCompFors:
      result &= printNode(f, 0) & " "
    for cond in node.extCompIf:
      result &= "if " & printNode(cond, 0) & " "
    result &= "]"

  of xnkExternal_With:
    result = i & "with " & seqNodes(node.extWithItems, 0, ", ") & ":\n"
    result &= printNode(node.extWithBody, indent + 1)

  of xnkExternal_Destructure:
    result = i & "destructure " & node.extDestructKind & " " & printNode(node.extDestructSource, 0)
    if node.extDestructKind == "object":
      result &= " {" & node.extDestructFields.join(", ") & "}"
    else:
      result &= " [" & node.extDestructVars.join(", ")
      if node.extDestructRest.isSome:
        result &= ", *" & node.extDestructRest.get
      result &= "]"

  of xnkExternal_Await:
    result = "await " & printNode(node.extAwaitExpr, 0)

  of xnkExternal_LocalFunction:
    result = i & "local func " & node.extLocalFuncName
    if node.extLocalFuncParams.len > 0:
      result &= "(" & seqNodes(node.extLocalFuncParams, 0, ", ") & ")"
    if node.extLocalFuncReturnType.isSome:
      result &= " -> " & printNode(node.extLocalFuncReturnType.get, 0)
    result &= "\n"
    if node.extLocalFuncBody.isSome:
      result &= i & "| body:\n" & printNode(node.extLocalFuncBody.get, indent + 2)

  of xnkExternal_ExtensionMethod:
    result = i & "extend func " & node.extExtMethodName
    if node.extExtMethodParams.len > 0:
      result &= "(" & seqNodes(node.extExtMethodParams, 0, ", ") & ")"
    if node.extExtMethodReturnType.isSome:
      result &= " -> " & printNode(node.extExtMethodReturnType.get, 0)
    result &= visibility(node.extExtMethodVisibility)
    result &= "\n"
    result &= i & "| body:\n" & printNode(node.extExtMethodBody, indent + 2)

  of xnkExternal_FallthroughCase:
    result = i & "| " & seqNodes(node.extFallthroughValues, 0, ", ") & ":\n"
    result &= printNode(node.extFallthroughBody, indent + 2)
    if node.extFallthroughHasFallthrough:
      result &= "\n" & i1 & "fallthrough"

  of xnkExternal_Unless:
    result = i & "unless " & printNode(node.extUnlessCondition, 0) & ":\n"
    result &= printNode(node.extUnlessBody, indent + 1)
    if node.extUnlessElse.isSome:
      result &= "\n" & i & "else:\n"
      result &= printNode(node.extUnlessElse.get, indent + 1)

  of xnkExternal_Until:
    result = i & "until " & printNode(node.extUntilCondition, 0) & ":\n"
    result &= printNode(node.extUntilBody, indent + 1)

  of xnkExternal_Pass:
    result = i & "pass"

  of xnkExternal_Channel:
    result = "chan<" & printNode(node.extChannelType, 0) & ">"
    if node.extChannelBuffered:
      if node.extChannelSize.isSome:
        result &= "[" & printNode(node.extChannelSize.get, 0) & "]"

  of xnkExternal_Goroutine:
    result = i & "go " & printNode(node.extGoroutineCall, 0)

  of xnkExternal_GoDefer:
    result = i & "defer " & printNode(node.extGoDeferCall, 0)

  of xnkExternal_GoSelect:
    result = i & "select\n"
    for c in node.extSelectCases:
      result &= printNode(c, indent)
    if node.extSelectDefault.isSome:
      result &= i & "| default:\n"
      result &= printNode(node.extSelectDefault.get, indent + 2)

  of xnkExternal_GoCommClause:
    if node.extCommIsDefault:
      result = i & "| default:\n"
    else:
      result = i & "| " & printNode(node.extCommOp, 0) & ":\n"
    result &= printNode(node.extCommBody, indent + 2)

  of xnkExternal_GoChannelSend:
    result = printNode(node.extSendChannel, 0) & " <- " & printNode(node.extSendValue, 0)

  of xnkExternal_GoChanType:
    case node.extChanDir
    of "recv":
      result = "<-chan " & printNode(node.extChanElemType, 0)
    of "send":
      result = "chan<- " & printNode(node.extChanElemType, 0)
    else:
      result = "chan " & printNode(node.extChanElemType, 0)

  of xnkExternal_GoTypeSwitch:
    result = i & "match type " & printNode(node.extGoTypeSwitchExpr, 0) & "\n"
    for c in node.extGoTypeSwitchCases:
      result &= printNode(c, indent)

  of xnkExternal_GoTypeCase:
    if node.extTypeCaseIsDefault:
      result = i & "| _:\n"
    else:
      result = i & "| " & seqNodes(node.extTypeCaseTypes, 0, ", ") & ":\n"
    result &= printNode(node.extTypeCaseBody, indent + 2)

  of xnkExternal_GoTaglessSwitch:
    result = i & "switch (tagless)\n"
    for c in node.extGoTaglessSwitchCases:
      result &= printNode(c, indent)

  of xnkExternal_GoVariadic:
    result = "..." & printNode(node.extVariadicElemType, 0)

  of xnkExternal_Record:
    result = i & "record " & node.extRecordName & "\n"
    result &= i & "| kind: record\n"
    if node.extRecordParams.len > 0:
      result &= i & "| params:\n"
      for p in node.extRecordParams:
        result &= printNode(p, indent + 2) & "\n"
    if node.extRecordBaseTypes.len > 0:
      result &= i & "| base: " & seqNodes(node.extRecordBaseTypes, 0, ", ") & "\n"
    if node.extRecordMembers.len > 0:
      result &= i & "| members:\n"
      result &= seqNodes(node.extRecordMembers, indent + 2)

  of xnkExternal_RecordWith:
    result = printNode(node.extWithExpression, 0) & " with\n"
    result &= printNode(node.extWithInitializer, indent)

  of xnkUnknown:
    result = i & "# unknown: " & node.unknownData

  # No else clause - compiler will warn about missing cases

# =============================================================================
# Public API
# =============================================================================

proc printXlang*(node: XLangNode): string =
  ## Print an XLang node tree in 11B syntax format.
  printNode(node, 0)

proc `$$`*(node: XLangNode): string =
  ## Shorthand operator for printXlang.
  ## Usage: echo $$node
  printXlang(node)
