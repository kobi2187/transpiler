## AST Printer - Convert MyNimNode trees to Nim source code
## Uses global indent level that increments/decrements on block entry/exit

import my_nim_node
import nim_node_indices
import std/strutils

export my_nim_node  # Re-export for convenience
export nim_node_indices  # Export named indices for convenience

# Global indent level
var gIndent = 0

proc incIndent() = inc gIndent
proc decIndent() = dec gIndent
proc ind(): string = "  ".repeat(gIndent)

# Forward declaration
proc renderNode(n: MyNimNode): string

# Literal rendering
proc escapeStringLiteral(s: string): string =
  ## Escape special characters in a string literal for Nim
  result = ""
  for c in s:
    case c
    of '\n': result.add("\\n")
    of '\r': result.add("\\r")
    of '\t': result.add("\\t")
    of '\\': result.add("\\\\")
    of '\"': result.add("\\\"")
    of '\0': result.add("\\0")
    else: result.add(c)

proc escapeCharLiteral(c: char): string =
  ## Escape special characters in a char literal for Nim
  case c
  of '\n': result = "\\n"
  of '\r': result = "\\r"
  of '\t': result = "\\t"
  of '\\': result = "\\\\"
  of '\'': result = "\\'"
  of '\0': result = "\\0"
  else: result = $c

proc renderIntLit(n: MyNimNode): string =
  # Use literalText if available (preserves hex format), otherwise use intVal
  if n.literalText.len > 0:
    n.literalText
  else:
    $n.intVal

proc renderFloatLit(n: MyNimNode): string = $n.floatVal
proc renderCharLit(n: MyNimNode): string = "'" & escapeCharLiteral(chr(int(n.intVal))) & "'"
proc renderStrLit(n: MyNimNode): string = "\"" & escapeStringLiteral(n.strVal) & "\""
proc renderRStrLit(n: MyNimNode): string = "r\"" & n.strVal & "\""  # Raw strings don't need escaping
proc renderTripleStrLit(n: MyNimNode): string = "\"\"\"" & n.strVal & "\"\"\""  # Triple-quoted strings preserve content as-is

# Identifier and symbol rendering
proc renderIdent(n: MyNimNode): string = n.identStr
proc renderSym(n: MyNimNode): string = n.symName

# Expression rendering helpers (no indent - expressions are inline)
proc getOperatorPrecedence(op: string): int =
  ## Get operator precedence level (higher = tighter binding)
  ## Based on Nim's operator precedence rules
  case op
  of "or", "xor": return 2
  of "and": return 3
  of "==", "!=", "<", "<=", ">", ">=", "in", "notin", "is", "isnot": return 4
  of "..": return 5
  of "&": return 6
  of "+", "-": return 7
  of "*", "/", "div", "mod", "shl", "shr": return 8
  of "=": return 1  # Assignment has very low precedence
  else: return 10  # Unknown operators get high precedence

proc getOpString(n: MyNimNode): string =
  ## Get the operator string from a node
  if n.kind == nnkIdent:
    return n.identStr
  elif n.kind == nnkSym:
    return n.symName
  else:
    return ""

proc needsParentheses(child: MyNimNode, parentOp: string): bool =
  ## Check if a child expression needs parentheses when used with parent operator
  var childOp: string

  if child.kind == nnkInfix:
    childOp = getOpString(child[InfixOp])
  elif child.kind == nnkAsgn:
    # Assignment has very low precedence
    childOp = "="
  else:
    return false

  let childPrec = getOperatorPrecedence(childOp)
  let parentPrec = getOperatorPrecedence(parentOp)

  # Need parens if child has lower precedence than parent
  return childPrec < parentPrec

proc renderInfix(n: MyNimNode): string =
  let op = renderNode(n[InfixOp])
  let opStr = getOpString(n[InfixOp])

  var lhs = renderNode(n[InfixLeft])
  var rhs = renderNode(n[InfixRight])

  # Add parentheses if needed based on precedence
  if needsParentheses(n[InfixLeft], opStr):
    lhs = "(" & lhs & ")"
  if needsParentheses(n[InfixRight], opStr):
    rhs = "(" & rhs & ")"

  result = lhs & " " & op & " " & rhs

proc renderPrefix(n: MyNimNode): string =
  let op = renderNode(n[PrefixOp])
  var arg = renderNode(n[PrefixOperand])

  # Add parentheses if the argument is an infix expression
  # Prefix operators like 'not' typically need parens around complex expressions
  if n[PrefixOperand].kind == nnkInfix:
    arg = "(" & arg & ")"

  result = op & " " & arg

proc renderPostfix(n: MyNimNode): string =
  let arg = renderNode(n[PostfixBase])
  let op = renderNode(n[PostfixOp])
  result = arg & op

proc renderCall(n: MyNimNode): string =
  if n.len == 0: return "()"
  result = renderNode(n[CallCallee])
  # Always add parentheses for calls, even with no arguments
  result &= "("
  if n.len > 1:
    for i in 1..<n.len:
      if i > 1: result &= ", "
      result &= renderNode(n[i])
  result &= ")"

proc renderCommand(n: MyNimNode): string =
  result = renderNode(n[CallCallee])
  for i in 1..<n.len:
    result &= " "
    result &= renderNode(n[i])

proc renderDotExpr(n: MyNimNode): string =
  result = renderNode(n[DotBase]) & "." & renderNode(n[DotField])

proc renderBracketExpr(n: MyNimNode): string =
  result = renderNode(n[BracketBase]) & "["
  for i in 1..<n.len:
    if i > 1: result &= ", "
    result &= renderNode(n[i])
  result &= "]"

proc renderPar(n: MyNimNode): string =
  result = "("
  for i, child in n:
    if i > 0: result &= ", "
    result &= renderNode(child)
  result &= ")"

proc renderBracket(n: MyNimNode): string =
  result = "["
  for i, child in n:
    if i > 0: result &= ", "
    result &= renderNode(child)
  result &= "]"

proc renderCurly(n: MyNimNode): string =
  result = "{"
  for i, child in n:
    if i > 0: result &= ", "
    result &= renderNode(child)
  result &= "}"

proc renderTupleConstr(n: MyNimNode): string =
  result = "("
  for i, child in n:
    if i > 0: result &= ", "
    result &= renderNode(child)
  if n.len == 1: result &= ","  # Single element tuple
  result &= ")"

proc renderCast(n: MyNimNode): string =
  result = "cast[" & renderNode(n[CastType]) & "](" & renderNode(n[CastExpr]) & ")"

proc renderObjConstr(n: MyNimNode): string =
  if n.len == 0: return "()"
  result = renderNode(n[ObjConstrType]) & "("
  for i in 1..<n.len:
    if i > 1: result &= ", "
    result &= renderNode(n[i])  # Field assignments
  result &= ")"

proc renderExprColonExpr(n: MyNimNode): string =
  result = renderNode(n[ColonExprName]) & ": " & renderNode(n[ColonExprValue])

proc renderExprEqExpr(n: MyNimNode): string =
  result = renderNode(n[EqExprName]) & " = " & renderNode(n[EqExprValue])

# Statement rendering helpers
proc renderIdentDefs(n: MyNimNode): string =
  result = renderNode(n[IdentDefsName])
  if n.len > 1 and n[IdentDefsType].kind != nnkEmpty:
    let typeStr = renderNode(n[IdentDefsType])
    if typeStr != "var":
      result &= ": " & typeStr
  if n.len > 2 and n[IdentDefsDefault].kind != nnkEmpty:
    result &= " = " & renderNode(n[IdentDefsDefault])

proc renderAsgn(n: MyNimNode): string =
  result = renderNode(n[AsgnLeft]) & " = " & renderNode(n[AsgnRight])

proc renderVarSection(n: MyNimNode): string =
  for i, identDefs in n:
    if i > 0: result &= "\n"
    result &= ind() & "var " & renderIdentDefs(identDefs)

proc renderLetSection(n: MyNimNode): string =
  for i, identDefs in n:
    if i > 0: result &= "\n"
    result &= ind() & "let " & renderIdentDefs(identDefs)

proc renderConstSection(n: MyNimNode): string =
  result = ind() & "const\n"
  incIndent()
  for constDef in n:
    result &= ind() & renderNode(constDef[ConstDefName])
    if constDef.len > 1 and constDef[ConstDefType].kind != nnkEmpty:
      result &= ": " & renderNode(constDef[ConstDefType])
    if constDef.len > 2:
      result &= " = " & renderNode(constDef[ConstDefValue])
    result &= "\n"
  decIndent()

proc renderStmtOrExpr(n: MyNimNode): string =
  ## Render a node that could be either a statement or expression
  ## Expressions used as statements need indent prefix
  if n.kind in {nnkCall, nnkCommand, nnkPrefix, nnkPostfix, nnkInfix, nnkAsgn, nnkDotExpr, nnkBracketExpr}:
    result = ind() & renderNode(n)
  else:
    result = renderNode(n)

proc renderStmtList(n: MyNimNode): string =
  for i, stmt in n:
    if i > 0: result &= "\n"
    result &= renderStmtOrExpr(stmt)

proc renderBlockStmt(n: MyNimNode): string =
  if n[BlockLabel].kind != nnkEmpty:
    result = ind() & "block " & renderNode(n[BlockLabel]) & ":\n"
  else:
    result = ""
  incIndent()
  result &= renderNode(n[BlockBody])
  decIndent()

proc renderIfStmt(n: MyNimNode): string =
  for i, branch in n:
    if i > 0: result &= "\n"
    if branch.kind == nnkElifBranch:
      let keyword = if i == 0: "if" else: "elif"
      result &= ind() & keyword & " " & renderNode(branch[ElifCondition]) & ":\n"
      incIndent()
      result &= renderStmtOrExpr(branch[ElifBody])
      decIndent()
    elif branch.kind == nnkElse:
      # Check if else body is a single nnkIfStmt - flatten to elif
      if branch[ElseBody].kind == nnkIfStmt:
        # Flatten: render the inner if as elif
        let innerIf = branch[ElseBody]
        for j, innerBranch in innerIf:
          result &= "\n"
          if innerBranch.kind == nnkElifBranch:
            result &= ind() & "elif " & renderNode(innerBranch[ElifCondition]) & ":\n"
            incIndent()
            result &= renderStmtOrExpr(innerBranch[ElifBody])
            decIndent()
          elif innerBranch.kind == nnkElse:
            # Recursively handle nested else-if
            if innerBranch[ElseBody].kind == nnkIfStmt:
              # Continue flattening
              result &= renderNode(MyNimNode(kind: nnkElse,  sons: innerBranch.sons))
            else:
              result &= ind() & "else:\n"
              incIndent()
              result &= renderStmtOrExpr(innerBranch[ElseBody])
              decIndent()
      else:
        result &= ind() & "else:\n"
        incIndent()
        result &= renderStmtOrExpr(branch[ElseBody])
        decIndent()


proc renderElifBranch(n: MyNimNode): string =
  result = ind() & "elif " & renderNode(n[ElifCondition]) & ":\n"
  incIndent()
  result &= renderStmtOrExpr(n[ElifBody])
  decIndent()

proc renderElse(n: MyNimNode): string =
  result = ind() & "else:\n"
  incIndent()
  result &= renderStmtOrExpr(n[ElseBody])
  decIndent()

proc renderWhileStmt(n: MyNimNode): string =
  result = ind() & "while " & renderNode(n[WhileCondition]) & ":\n"
  incIndent()
  result &= renderStmtOrExpr(n[WhileBody])
  decIndent()

proc renderForStmt(n: MyNimNode): string =
  result = ind() & "for " & renderNode(n[ForVars])
  result &= " in " & renderNode(n[ForIterable]) & ":\n"
  incIndent()
  result &= renderStmtOrExpr(n[ForBody])
  decIndent()

proc renderCaseStmt(n: MyNimNode): string =
  result = ind() & "case " & renderNode(n[CaseSelector]) & "\n"
  for i in 1..<n.len:
    result &= renderNode(n[i])
    if i < n.len - 1: result &= "\n"

proc renderOfBranch(n: MyNimNode): string =
  result = ind() & "of "
  for i in 0..<n.len-1:
    if i > 0: result &= ", "
    result &= renderNode(n[i])
  result &= ":\n"
  incIndent()
  result &= renderStmtOrExpr(n[n.len-1])
  decIndent()

proc renderReturnStmt(n: MyNimNode): string =
  result = ind() & "return"
  if n.len > 0 and n[ReturnExpr].kind != nnkEmpty:
    result &= " " & renderNode(n[ReturnExpr])

proc renderYieldStmt(n: MyNimNode): string =
  result = ind() & "yield"
  if n.len > 0 and n[YieldExpr].kind != nnkEmpty:
    result &= " " & renderNode(n[YieldExpr])

proc renderDiscardStmt(n: MyNimNode): string =
  result = ind() & "discard"
  if n.len > 0 and n[DiscardExpr].kind != nnkEmpty:
    result &= " " & renderNode(n[DiscardExpr])

proc renderBreakStmt(n: MyNimNode): string =
  result = ind() & "break"
  if n.len > 0 and n[BreakLabel].kind != nnkEmpty:
    result &= " " & renderNode(n[BreakLabel])

proc renderContinueStmt(n: MyNimNode): string =
  result = ind() & "continue"

proc renderRaiseStmt(n: MyNimNode): string =
  result = ind() & "raise"
  if n.len > 0 and n[RaiseExpr].kind != nnkEmpty:
    result &= " " & renderNode(n[RaiseExpr])

proc renderTryStmt(n: MyNimNode): string =
  result = ind() & "try:\n"
  incIndent()
  if n.len > 0 and n[TryBody].kind != nnkEmpty:
    result &= renderNode(n[TryBody])
  decIndent()
  for i in 1..<n.len:
    result &= "\n" & renderNode(n[i])

proc renderExceptBranch(n: MyNimNode): string =
  result = ind() & "except"
  if n.len > 1:
    result &= " "
    for i in 0..<n.len-1:
      if i > 0: result &= ", "
      result &= renderNode(n[i])
  result &= ":\n"
  incIndent()
  result &= renderStmtOrExpr(n[n.len - 1])
  decIndent()

proc renderFinally(n: MyNimNode): string =
  result = ind() & "finally:\n"
  incIndent()
  if n.len > 0 and n[FinallyBody].kind != nnkEmpty:
    result &= renderStmtOrExpr(n[FinallyBody])
  decIndent()

proc renderDefer(n: MyNimNode): string =
  result = ind() & "defer:\n"
  incIndent()
  if n.len > 0 and n[DeferBody].kind != nnkEmpty:
    result &= renderStmtOrExpr(n[DeferBody])
  decIndent()

# Procedure/function rendering
proc renderFormalParams(n: MyNimNode): string =
  result = "("
  for i in 1..<n.len:
    if i > 1: result &= ", "
    result &= renderIdentDefs(n[i])
  result &= ")"
  if n.len > 0 and n[FormalParamsReturn].kind != nnkEmpty:
    let returnType = renderNode(n[FormalParamsReturn])
    if returnType != "void":
      result &= ": " & returnType

proc renderLambda(n: MyNimNode): string =
  # Lambda using sugar module's => syntax: (params) => body
  # Much cleaner than proc syntax for inline lambdas
  result = "("

  # Render parameters (LambdaFormalParams contains formal params)
  if n.len > LambdaFormalParams and n[LambdaFormalParams].kind == nnkFormalParams:
    let params = n[LambdaFormalParams]
    # Skip return type (params[FormalParamsReturn]) and render parameters starting from params[1]
    var paramList: seq[string]
    for i in 1 ..< params.len:
      let param = params[i]
      if param.kind == nnkIdentDefs:
        # param has: [names..., type, default]
        let paramCount = param.len - 2  # names count
        for j in 0 ..< paramCount:
          if param[j].kind != nnkEmpty:
            paramList.add(renderNode(param[j]))
    result &= paramList.join(", ")

  result &= ") => "

  # Render body
  if n.len > LambdaBody and n[LambdaBody].kind != nnkEmpty:
    result &= renderNode(n[LambdaBody])
  else:
    result &= "discard"

proc renderProcDef(n: MyNimNode): string =
  result = ind() & "proc "
  if n.len > 0 and n[ProcName].kind != nnkEmpty:
    result &= renderNode(n[ProcName])
  if n.len > 2 and n[ProcGenericParams].kind != nnkEmpty:
    result &= "[" & renderNode(n[ProcGenericParams]) & "]"
  if n.len > 3 and n[ProcFormalParams].kind != nnkEmpty:
    result &= renderFormalParams(n[ProcFormalParams])
  if n.len > 4 and n[ProcPragmas].kind == nnkPragma:
    result &= " {." & renderNode(n[ProcPragmas]) & ".}"
  result &= " =\n"
  incIndent()
  if n.len > 6 and n[ProcBody].kind != nnkEmpty:
    result &= renderNode(n[ProcBody])
  else:
    result &= ind() & "discard"
  result &= "\n\n"
  decIndent()

proc renderFuncDef(n: MyNimNode): string =
  result = ind() & "func "
  if n.len > 0 and n[FuncName].kind != nnkEmpty:
    result &= renderNode(n[FuncName])
  if n.len > 2 and n[FuncGenericParams].kind != nnkEmpty:
    result &= "[" & renderNode(n[FuncGenericParams]) & "]"
  if n.len > 3 and n[FuncFormalParams].kind != nnkEmpty:
    result &= renderFormalParams(n[FuncFormalParams])
  result &= " =\n"
  incIndent()
  if n.len > 6 and n[FuncBody].kind != nnkEmpty:
    result &= renderNode(n[FuncBody])
  else:
    result &= ind() & "discard"
  decIndent()

proc renderMethodDef(n: MyNimNode): string =
  result = ind() & "method "
  if n.len > 0 and n[MethodName].kind != nnkEmpty:
    result &= renderNode(n[MethodName])
  if n.len > 3 and n[MethodFormalParams].kind != nnkEmpty:
    result &= renderFormalParams(n[MethodFormalParams])
  result &= " =\n"
  incIndent()
  if n.len > 6 and n[MethodBody].kind != nnkEmpty:
    result &= renderNode(n[MethodBody])
  decIndent()
  result &= "\n\n"

proc renderIteratorDef(n: MyNimNode): string =
  result = ind() & "iterator "
  if n.len > 0 and n[IteratorName].kind != nnkEmpty:
    result &= renderNode(n[IteratorName])
  if n.len > 3 and n[IteratorFormalParams].kind != nnkEmpty:
    result &= renderFormalParams(n[IteratorFormalParams])
  result &= " =\n"
  incIndent()
  if n.len > 6 and n[IteratorBody].kind != nnkEmpty:
    result &= renderNode(n[IteratorBody])
  decIndent()

proc renderTemplateDef(n: MyNimNode): string =
  result = ind() & "template "
  if n.len > 0 and n[TemplateName].kind != nnkEmpty:
    result &= renderNode(n[TemplateName])
  if n.len > 3 and n[TemplateFormalParams].kind != nnkEmpty:
    result &= renderFormalParams(n[TemplateFormalParams])
  result &= " =\n"
  incIndent()
  if n.len > 6 and n[TemplateBody].kind != nnkEmpty:
    result &= renderNode(n[TemplateBody])
  decIndent()

proc renderMacroDef(n: MyNimNode): string =
  result = ind() & "macro "
  if n.len > 0 and n[MacroName].kind != nnkEmpty:
    result &= renderNode(n[MacroName])
  if n.len > 3 and n[MacroFormalParams].kind != nnkEmpty:
    result &= renderFormalParams(n[MacroFormalParams])
  result &= " =\n"
  incIndent()
  if n.len > 6 and n[MacroBody].kind != nnkEmpty:
    result &= renderNode(n[MacroBody])
  decIndent()

# Type rendering
proc renderTypeDef(n: MyNimNode): string =
  result = ind() & renderNode(n[TypeDefName])
  if n.len > 1 and n[TypeDefGenericParams].kind != nnkEmpty:
    result &= "[" & renderNode(n[TypeDefGenericParams]) & "]"
  if n.len > 2 and n[TypeDefBody].kind != nnkEmpty:
    result &= " = " & renderNode(n[TypeDefBody])

proc renderTypeSection(n: MyNimNode): string =
  result = ""
  for typeDef in n:
    result &= "type " & renderTypeDef(typeDef) & "\n"
  

proc renderObjectTy(n: MyNimNode): string =
  result = "object"
  if n.len > 0 and n[ObjectTyBase].kind != nnkEmpty:
    result &= " of " & renderNode(n[ObjectTyBase])
  if n.len > 2 and n[ObjectTyRecList].kind != nnkEmpty:
    result &= "\n"
    incIndent()
    result &= renderNode(n[ObjectTyRecList])
    decIndent()

proc renderRecList(n: MyNimNode): string =
  for i, field in n:
    if i > 0: result &= "\n"
    result &= ind() & renderIdentDefs(field)

proc renderRefTy(n: MyNimNode): string =
  result = "ref "
  if n.len > 0:
    result &= renderNode(n[RefTypeWrapped])

proc renderPtrTy(n: MyNimNode): string =
  result = "ptr "
  if n.len > 0:
    result &= renderNode(n[PtrTypeWrapped])

proc renderVarTy(n: MyNimNode): string =
  result = "var "
  if n.len > 0:
    result &= renderNode(n[VarTypeWrapped])

proc renderDistinctTy(n: MyNimNode): string =
  result = "distinct "
  if n.len > 0:
    result &= renderNode(n[DistinctTypeWrapped])

proc renderEnumFieldDef(n: MyNimNode): string =
  if n.len > 0 and n[EnumFieldName].kind != nnkEmpty:
    result = renderNode(n[EnumFieldName])
    if n.len > 1 and n[EnumFieldValue].kind != nnkEmpty:
      result &= " = " & renderNode(n[EnumFieldValue])

proc renderEnumTy(n: MyNimNode): string =
  result = "enum\n"
  incIndent()
  for i, field in n:
    if i == 0 and field.kind == nnkEmpty: continue
    result &= ind() & renderNode(field)
    if i < n.len - 1: result &= "\n"
  decIndent()

proc renderTupleTy(n: MyNimNode): string =
  result = "tuple["
  for i, field in n:
    if i > 0: result &= ", "
    result &= renderIdentDefs(field)
  result &= "]"

proc renderProcTy(n: MyNimNode): string =
  result = "proc"
  if n.len > 0:
    result &= renderFormalParams(n[ProcTyParams])

# Import/export rendering
proc renderImportStmt(n: MyNimNode): string =
  result = ind() & "import "
  for i, child in n:
    if i > 0: result &= ", "
    result &= renderNode(child)

proc renderExportStmt(n: MyNimNode): string =
  result = ind() & "export "
  for i, child in n:
    if i > 0: result &= ", "
    result &= renderNode(child)

proc renderFromStmt(n: MyNimNode): string =
  result = ind() & "from " & renderNode(n[FromModule]) & " import "
  for i in 1..<n.len:  # n[1..] = imported symbols
    if i > 1: result &= ", "
    result &= renderNode(n[i])

proc renderIncludeStmt(n: MyNimNode): string =
  result = ind() & "include "
  for i, child in n:
    if i > 0: result &= ", "
    result &= renderNode(child)

# Pragma rendering
proc renderPragma(n: MyNimNode): string =
  for i, child in n:
    if i > 0: result &= ", "
    result &= renderNode(child)

proc renderPragmaExpr(n: MyNimNode): string =
  result = renderNode(n[PragmaExprBase]) & " {." & renderNode(n[PragmaExprPragma]) & ".}"

# Comment rendering
proc renderCommentStmt(n: MyNimNode): string =
  if n.len > 0:
    let commentText = n[CommentText].strVal
    # Check if it's a multi-line doc comment (starts with ##[)
    if commentText.startsWith("##["):
      # For multi-line doc comments, output as-is without "# " prefix
      result = ind() & commentText
    else:
      # Regular comment: add "# " prefix
      result = ind() & "# " & commentText
  else:
    result = ind() & "# "

# Main rendering dispatch
proc renderNode(n: MyNimNode): string =
  case n.kind
  # Literals
  of nnkIntLit, nnkInt8Lit, nnkInt16Lit, nnkInt32Lit, nnkInt64Lit,
     nnkUIntLit, nnkUInt8Lit, nnkUInt16Lit, nnkUInt32Lit, nnkUInt64Lit:
    result = renderIntLit(n)
  of nnkFloatLit, nnkFloat32Lit, nnkFloat64Lit, nnkFloat128Lit:
    result = renderFloatLit(n)
  of nnkCharLit:
    result = renderCharLit(n)
  of nnkStrLit:
    result = renderStrLit(n)
  of nnkRStrLit:
    result = renderRStrLit(n)
  of nnkTripleStrLit:
    result = renderTripleStrLit(n)
  of nnkNilLit:
    result = "nil"
  of nnkIdent:
    result = renderIdent(n)
  of nnkSym:
    result = renderSym(n)
  of nnkEmpty:
    result = ""

  # Expressions
  of nnkInfix:
    result = renderInfix(n)
  of nnkPrefix:
    result = renderPrefix(n)
  of nnkPostfix:
    result = renderPostfix(n)
  of nnkCall:
    result = renderCall(n)
  of nnkCommand:
    result = renderCommand(n)
  of nnkDotExpr:
    result = renderDotExpr(n)
  of nnkBracketExpr:
    result = renderBracketExpr(n)
  of nnkPar:
    result = renderPar(n)
  of nnkBracket:
    result = renderBracket(n)
  of nnkCurly:
    result = renderCurly(n)
  of nnkTupleConstr:
    result = renderTupleConstr(n)
  of nnkObjConstr:
    result = renderObjConstr(n)
  of nnkCast:
    result = renderCast(n)
  of nnkExprColonExpr:
    result = renderExprColonExpr(n)
  of nnkExprEqExpr:
    result = renderExprEqExpr(n)

  # Statements
  of nnkAsgn:
    result = renderAsgn(n)
  of nnkIdentDefs:
    result = ind() & renderIdentDefs(n)
  of nnkVarSection:
    result = renderVarSection(n)
  of nnkLetSection:
    result = renderLetSection(n)
  of nnkConstSection:
    result = renderConstSection(n)
  of nnkStmtList, nnkStmtListExpr:
    result = renderStmtList(n)
  of nnkBlockStmt:
    result = renderBlockStmt(n)
  of nnkIfStmt:
    result = renderIfStmt(n)
  of nnkElifBranch:
    result = renderElifBranch(n)
  of nnkElse:
    result = renderElse(n)
  of nnkWhileStmt:
    result = renderWhileStmt(n)
  of nnkForStmt:
    result = renderForStmt(n)
  of nnkCaseStmt:
    result = renderCaseStmt(n)
  of nnkOfBranch:
    result = renderOfBranch(n)
  of nnkReturnStmt:
    result = renderReturnStmt(n)
  of nnkYieldStmt:
    result = renderYieldStmt(n)
  of nnkDiscardStmt:
    result = renderDiscardStmt(n)
  of nnkBreakStmt:
    result = renderBreakStmt(n)
  of nnkContinueStmt:
    result = renderContinueStmt(n)
  of nnkRaiseStmt:
    result = renderRaiseStmt(n)
  of nnkTryStmt:
    result = renderTryStmt(n)
  of nnkExceptBranch:
    result = renderExceptBranch(n)
  of nnkFinally:
    result = renderFinally(n)
  of nnkDefer:
    result = renderDefer(n)

  # Procedures/functions
  of nnkProcDef:
    result = renderProcDef(n)
  of nnkFuncDef:
    result = renderFuncDef(n)
  of nnkMethodDef:
    result = renderMethodDef(n)
  of nnkIteratorDef:
    result = renderIteratorDef(n)
  of nnkTemplateDef:
    result = renderTemplateDef(n)
  of nnkMacroDef:
    result = renderMacroDef(n)
  of nnkLambda:
    result = renderLambda(n)
  of nnkFormalParams:
    result = renderFormalParams(n)

  # Types
  of nnkTypeSection:
    result = renderTypeSection(n)
  of nnkTypeDef:
    result = renderTypeDef(n)
  of nnkObjectTy:
    result = renderObjectTy(n)
  of nnkRecList:
    result = renderRecList(n)
  of nnkRefTy:
    result = renderRefTy(n)
  of nnkPtrTy:
    result = renderPtrTy(n)
  of nnkVarTy:
    result = renderVarTy(n)
  of nnkDistinctTy:
    result = renderDistinctTy(n)
  of nnkEnumTy:
    result = renderEnumTy(n)
  of nnkEnumFieldDef:
    result = renderEnumFieldDef(n)
  of nnkTupleTy:
    result = renderTupleTy(n)
  of nnkProcTy:
    result = renderProcTy(n)

  # Import/export
  of nnkImportStmt:
    result = renderImportStmt(n)
  of nnkExportStmt:
    result = renderExportStmt(n)
  of nnkFromStmt:
    result = renderFromStmt(n)
  of nnkIncludeStmt:
    result = renderIncludeStmt(n)

  # Pragmas
  of nnkPragma:
    result = renderPragma(n)
  of nnkPragmaExpr:
    result = renderPragmaExpr(n)

  # Comments
  of nnkCommentStmt:
    result = renderCommentStmt(n)

  else:
    result = "<unhandled: " & $n.kind & ">"

# Public API
proc `$`*(n: MyNimNode): string =
  ## Convert a MyNimNode tree to Nim source code
  gIndent = 0  # Reset indent for each new rendering
  renderNode(n)

proc toNimCode*(n: MyNimNode): string =
  ## Convert a MyNimNode tree to Nim source code (alias for $)
  gIndent = 0  # Reset indent for each new rendering
  renderNode(n)
