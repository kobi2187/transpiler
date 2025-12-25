## AST Printer - Convert MyNimNode trees to Nim source code
## Uses global indent level that increments/decrements on block entry/exit

import my_nim_node
import std/strutils

export my_nim_node  # Re-export for convenience

# Global indent level
var gIndent = 0

proc incIndent() = inc gIndent
proc decIndent() = dec gIndent
proc ind(): string = "  ".repeat(gIndent)

# Forward declaration
proc renderNode(n: MyNimNode): string

# Literal rendering
proc renderIntLit(n: MyNimNode): string =
  # Use literalText if available (preserves hex format), otherwise use intVal
  if n.literalText.len > 0:
    n.literalText
  else:
    $n.intVal

proc renderFloatLit(n: MyNimNode): string = $n.floatVal
proc renderCharLit(n: MyNimNode): string = "'" & chr(int(n.intVal)) & "'"
proc renderStrLit(n: MyNimNode): string = "\"" & n.strVal & "\""
proc renderRStrLit(n: MyNimNode): string = "r\"" & n.strVal & "\""
proc renderTripleStrLit(n: MyNimNode): string = "\"\"\"" & n.strVal & "\"\"\""

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
    childOp = getOpString(child[0])
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
  let op = renderNode(n[0])
  let opStr = getOpString(n[0])

  var lhs = renderNode(n[1])
  var rhs = renderNode(n[2])

  # Add parentheses if needed based on precedence
  if needsParentheses(n[1], opStr):
    lhs = "(" & lhs & ")"
  if needsParentheses(n[2], opStr):
    rhs = "(" & rhs & ")"

  result = lhs & " " & op & " " & rhs

proc renderPrefix(n: MyNimNode): string =
  let op = renderNode(n[0])
  var arg = renderNode(n[1])

  # Add parentheses if the argument is an infix expression
  # Prefix operators like 'not' typically need parens around complex expressions
  if n[1].kind == nnkInfix:
    arg = "(" & arg & ")"

  result = op & " " & arg

proc renderPostfix(n: MyNimNode): string =
  let arg = renderNode(n[0])
  let op = renderNode(n[1])
  result = arg & op

proc renderCall(n: MyNimNode): string =
  if n.len == 0: return "()"
  result = renderNode(n[0])
  # Always add parentheses for calls, even with no arguments
  result &= "("
  if n.len > 1:
    for i in 1..<n.len:
      if i > 1: result &= ", "
      result &= renderNode(n[i])
  result &= ")"

proc renderCommand(n: MyNimNode): string =
  result = renderNode(n[0])
  for i in 1..<n.len:
    result &= " "
    result &= renderNode(n[i])

proc renderDotExpr(n: MyNimNode): string =
  result = renderNode(n[0]) & "." & renderNode(n[1])

proc renderBracketExpr(n: MyNimNode): string =
  result = renderNode(n[0]) & "["
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
  result = "cast[" & renderNode(n[0]) & "](" & renderNode(n[1]) & ")"

proc renderObjConstr(n: MyNimNode): string =
  if n.len == 0: return "()"
  result = renderNode(n[0]) & "("
  for i in 1..<n.len:
    if i > 1: result &= ", "
    result &= renderNode(n[i])
  result &= ")"

proc renderExprColonExpr(n: MyNimNode): string =
  result = renderNode(n[0]) & ": " & renderNode(n[1])

proc renderExprEqExpr(n: MyNimNode): string =
  result = renderNode(n[0]) & " = " & renderNode(n[1])

# Statement rendering helpers
proc renderIdentDefs(n: MyNimNode): string =
  result = renderNode(n[0])
  if n.len > 1 and n[1].kind != nnkEmpty:
    let typeStr = renderNode(n[1])
    if typeStr != "var":
      result &= ": " & typeStr
  if n.len > 2 and n[2].kind != nnkEmpty:
    result &= " = " & renderNode(n[2])

proc renderAsgn(n: MyNimNode): string =
  result = renderNode(n[0]) & " = " & renderNode(n[1])

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
    result &= ind() & renderNode(constDef[0])
    if constDef.len > 1 and constDef[1].kind != nnkEmpty:
      result &= ": " & renderNode(constDef[1])
    if constDef.len > 2:
      result &= " = " & renderNode(constDef[2])
    result &= "\n"
  decIndent()

proc renderStmtList(n: MyNimNode): string =
  for i, stmt in n:
    if i > 0: result &= "\n"
    # Expression nodes when used as statements need indent
    # Also nnkAsgn needs indent when used as a statement
    if stmt.kind in {nnkCall, nnkCommand, nnkPrefix, nnkPostfix, nnkInfix, nnkAsgn}:
      result &= ind() & renderNode(stmt)
    else:
      result &= renderNode(stmt)

proc renderBlockStmt(n: MyNimNode): string =
  if n[0].kind != nnkEmpty:
    result = ind() & "block " & renderNode(n[0]) & ":\n"
  else:
    result = ""
  incIndent()
  result &= renderNode(n[1])
  decIndent()

proc renderIfStmt(n: MyNimNode): string =
  for i, branch in n:
    if i > 0: result &= "\n"
    if branch.kind == nnkElifBranch:
      let keyword = if i == 0: "if" else: "elif"
      result &= ind() & keyword & " " & renderNode(branch[0]) & ":\n"
      incIndent()
      result &= renderNode(branch[1])
      decIndent()
    elif branch.kind == nnkElse:
      # Check if else body is a single nnkIfStmt - flatten to elif
      if branch[0].kind == nnkIfStmt:
        # Flatten: render the inner if as elif
        let innerIf = branch[0]
        for j, innerBranch in innerIf:
          result &= "\n"
          if innerBranch.kind == nnkElifBranch:
            result &= ind() & "elif " & renderNode(innerBranch[0]) & ":\n"
            incIndent()
            result &= renderNode(innerBranch[1])
            decIndent()
          elif innerBranch.kind == nnkElse:
            # Recursively handle nested else-if
            if innerBranch[0].kind == nnkIfStmt:
              # Continue flattening
              result &= renderNode(MyNimNode(kind: nnkElse,  sons: innerBranch.sons))
            else:
              result &= ind() & "else:\n"
              incIndent()
              result &= renderNode(innerBranch[0])
              decIndent()
      else:
        result &= ind() & "else:\n"
        incIndent()
        result &= renderNode(branch[0])
        decIndent()


proc renderElifBranch(n: MyNimNode): string =
  result = ind() & "elif " & renderNode(n[0]) & ":\n"
  incIndent()
  result &= renderNode(n[1])
  decIndent()

proc renderElse(n: MyNimNode): string =
  result = ind() & "else:\n"
  incIndent()
  result &= renderNode(n[0])
  decIndent()

proc renderWhileStmt(n: MyNimNode): string =
  result = ind() & "while " & renderNode(n[0]) & ":\n"
  incIndent()
  result &= renderNode(n[1])
  decIndent()

proc renderForStmt(n: MyNimNode): string =
  result = ind() & "for " & renderNode(n[0])
  result &= " in " & renderNode(n[1]) & ":\n"
  incIndent()
  result &= renderNode(n[2])
  decIndent()

proc renderCaseStmt(n: MyNimNode): string =
  result = ind() & "case " & renderNode(n[0]) & "\n"
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
  result &= renderNode(n[n.len-1])
  decIndent()

proc renderReturnStmt(n: MyNimNode): string =
  result = ind() & "return"
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= " " & renderNode(n[0])

proc renderYieldStmt(n: MyNimNode): string =
  result = ind() & "yield"
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= " " & renderNode(n[0])

proc renderDiscardStmt(n: MyNimNode): string =
  result = ind() & "discard"
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= " " & renderNode(n[0])

proc renderBreakStmt(n: MyNimNode): string =
  result = ind() & "break"
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= " " & renderNode(n[0])

proc renderContinueStmt(n: MyNimNode): string =
  result = ind() & "continue"

proc renderRaiseStmt(n: MyNimNode): string =
  result = ind() & "raise"
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= " " & renderNode(n[0])

proc renderTryStmt(n: MyNimNode): string =
  result = ind() & "try:\n"
  incIndent()
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= renderNode(n[0])
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
  result &= renderNode(n[n.len - 1])
  decIndent()

proc renderFinally(n: MyNimNode): string =
  result = ind() & "finally:\n"
  incIndent()
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= renderNode(n[0])
  decIndent()

# Procedure/function rendering
proc renderFormalParams(n: MyNimNode): string =
  result = "("
  for i in 1..<n.len:
    if i > 1: result &= ", "
    result &= renderIdentDefs(n[i])
  result &= ")"
  if n.len > 0 and n[0].kind != nnkEmpty:
    let returnType = renderNode(n[0])
    if returnType != "void":
      result &= ": " & returnType

proc renderProcDef(n: MyNimNode): string =
  result = ind() & "proc "
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= renderNode(n[0])
  if n.len > 2 and n[2].kind != nnkEmpty:
    result &= "[" & renderNode(n[2]) & "]"
  if n.len > 3 and n[3].kind != nnkEmpty:
    result &= renderFormalParams(n[3])
  if n.len > 4 and n[4].kind == nnkPragma:
    result &= " {." & renderNode(n[4]) & ".}"
  result &= " =\n"
  incIndent()
  if n.len > 6 and n[6].kind != nnkEmpty:
    result &= renderNode(n[6])
  else:
    result &= ind() & "discard"
  decIndent()

proc renderFuncDef(n: MyNimNode): string =
  result = ind() & "func "
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= renderNode(n[0])
  if n.len > 2 and n[2].kind != nnkEmpty:
    result &= "[" & renderNode(n[2]) & "]"
  if n.len > 3 and n[3].kind != nnkEmpty:
    result &= renderFormalParams(n[3])
  result &= " =\n"
  incIndent()
  if n.len > 6 and n[6].kind != nnkEmpty:
    result &= renderNode(n[6])
  else:
    result &= ind() & "discard"
  decIndent()

proc renderMethodDef(n: MyNimNode): string =
  result = ind() & "method "
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= renderNode(n[0])
  if n.len > 3 and n[3].kind != nnkEmpty:
    result &= renderFormalParams(n[3])
  result &= " =\n"
  incIndent()
  if n.len > 6 and n[6].kind != nnkEmpty:
    result &= renderNode(n[6])
  decIndent()

proc renderIteratorDef(n: MyNimNode): string =
  result = ind() & "iterator "
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= renderNode(n[0])
  if n.len > 3 and n[3].kind != nnkEmpty:
    result &= renderFormalParams(n[3])
  result &= " =\n"
  incIndent()
  if n.len > 6 and n[6].kind != nnkEmpty:
    result &= renderNode(n[6])
  decIndent()

proc renderTemplateDef(n: MyNimNode): string =
  result = ind() & "template "
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= renderNode(n[0])
  if n.len > 3 and n[3].kind != nnkEmpty:
    result &= renderFormalParams(n[3])
  result &= " =\n"
  incIndent()
  if n.len > 6 and n[6].kind != nnkEmpty:
    result &= renderNode(n[6])
  decIndent()

proc renderMacroDef(n: MyNimNode): string =
  result = ind() & "macro "
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= renderNode(n[0])
  if n.len > 3 and n[3].kind != nnkEmpty:
    result &= renderFormalParams(n[3])
  result &= " =\n"
  incIndent()
  if n.len > 6 and n[6].kind != nnkEmpty:
    result &= renderNode(n[6])
  decIndent()

# Type rendering
proc renderTypeDef(n: MyNimNode): string =
  result = ind() & renderNode(n[0])
  if n.len > 1 and n[1].kind != nnkEmpty:
    result &= "[" & renderNode(n[1]) & "]"
  if n.len > 2 and n[2].kind != nnkEmpty:
    result &= " = " & renderNode(n[2])

proc renderTypeSection(n: MyNimNode): string =
  result = ""
  for typeDef in n:
    result &= "type " & renderTypeDef(typeDef) & "\n"
  

proc renderObjectTy(n: MyNimNode): string =
  result = "object"
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= " of " & renderNode(n[0])
  if n.len > 2 and n[2].kind != nnkEmpty:
    result &= "\n"
    incIndent()
    result &= renderNode(n[2])
    decIndent()

proc renderRecList(n: MyNimNode): string =
  for i, field in n:
    if i > 0: result &= "\n"
    result &= ind() & renderIdentDefs(field)

proc renderRefTy(n: MyNimNode): string =
  result = "ref "
  if n.len > 0:
    result &= renderNode(n[0])

proc renderPtrTy(n: MyNimNode): string =
  result = "ptr "
  if n.len > 0:
    result &= renderNode(n[0])

proc renderVarTy(n: MyNimNode): string =
  result = "var "
  if n.len > 0:
    result &= renderNode(n[0])

proc renderDistinctTy(n: MyNimNode): string =
  result = "distinct "
  if n.len > 0:
    result &= renderNode(n[0])

proc renderEnumFieldDef(n: MyNimNode): string =
  if n.len > 0 and n[0].kind != nnkEmpty:
    result = renderNode(n[0])
    if n.len > 1 and n[1].kind != nnkEmpty:
      result &= " = " & renderNode(n[1])

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
    result &= renderFormalParams(n[0])

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
  result = ind() & "from " & renderNode(n[0]) & " import "
  for i in 1..<n.len:
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
  result = renderNode(n[0]) & " {." & renderNode(n[1]) & ".}"

# Comment rendering
proc renderCommentStmt(n: MyNimNode): string =
  if n.len > 0:
    let commentText = n[0].strVal
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
