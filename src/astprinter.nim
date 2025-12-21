## AST Printer - Convert MyNimNode trees to Nim source code
## Uses Forth-style small helper functions for maintainability

import my_nim_node
import std/strutils

export my_nim_node  # Re-export for convenience

# Forward declarations
proc renderNode(n: MyNimNode, indent: int = 0): string
proc renderNodes(nodes: openArray[MyNimNode], sep: string, indent: int = 0): string

# Basic rendering helpers
proc ind(level: int): string = "  ".repeat(level)
proc needsParens(n: MyNimNode): bool =
  n.kind in {nnkInfix, nnkPrefix, nnkCall, nnkCommand}

# Literal rendering
proc renderIntLit(n: MyNimNode): string = $n.intVal
proc renderFloatLit(n: MyNimNode): string = $n.floatVal
proc renderCharLit(n: MyNimNode): string = "'" & chr(int(n.intVal)) & "'"
proc renderStrLit(n: MyNimNode): string = "\"" & n.strVal & "\""
proc renderRStrLit(n: MyNimNode): string = "r\"" & n.strVal & "\""
proc renderTripleStrLit(n: MyNimNode): string = "\"\"\"" & n.strVal & "\"\"\""

# Identifier and symbol rendering
proc renderIdent(n: MyNimNode): string = n.identStr
proc renderSym(n: MyNimNode): string = n.symName

# Expression rendering helpers
proc renderInfix(n: MyNimNode, indent: int): string =
  let op = renderNode(n[0], indent)
  let lhs = renderNode(n[1], indent)
  let rhs = renderNode(n[2], indent)
  result = lhs & " " & op & " " & rhs

proc renderPrefix(n: MyNimNode, indent: int): string =
  let op = renderNode(n[0], indent)
  let arg = renderNode(n[1], indent)
  result = op & arg

proc renderPostfix(n: MyNimNode, indent: int): string =
  let arg = renderNode(n[0], indent)
  let op = renderNode(n[1], indent)
  result = arg & op

proc renderCall(n: MyNimNode, indent: int): string =
  if n.len == 0: return ind(indent) & "()"
  result = ind(indent) & renderNode(n[0], 0)
  if n.len > 1:
    result &= "("
    for i in 1..<n.len:
      if i > 1: result &= ", "
      result &= renderNode(n[i], 0)
    result &= ")"

proc renderCommand(n: MyNimNode, indent: int): string =
  result = renderNode(n[0], indent)
  for i in 1..<n.len:
    result &= " "
    result &= renderNode(n[i], indent)

proc renderDotExpr(n: MyNimNode, indent: int): string =
  result = renderNode(n[0], indent) & "." & renderNode(n[1], indent)

proc renderBracketExpr(n: MyNimNode, indent: int): string =
  result = renderNode(n[0], indent) & "["
  for i in 1..<n.len:
    if i > 1: result &= ", "
    result &= renderNode(n[i], indent)
  result &= "]"

proc renderPar(n: MyNimNode, indent: int): string =
  result = "("
  for i, child in n:
    if i > 0: result &= ", "
    result &= renderNode(child, indent)
  result &= ")"

proc renderBracket(n: MyNimNode, indent: int): string =
  result = "["
  for i, child in n:
    if i > 0: result &= ", "
    result &= renderNode(child, indent)
  result &= "]"

proc renderCurly(n: MyNimNode, indent: int): string =
  result = "{"
  for i, child in n:
    if i > 0: result &= ", "
    result &= renderNode(child, indent)
  result &= "}"

proc renderTupleConstr(n: MyNimNode, indent: int): string =
  result = "("
  for i, child in n:
    if i > 0: result &= ", "
    result &= renderNode(child, indent)
  if n.len == 1: result &= ","  # Single element tuple
  result &= ")"

proc renderCast(n: MyNimNode, indent: int): string =
  # Nim cast syntax: cast[Type](value)
  # n[0] is the target type, n[1] is the expression to cast
  result = "cast[" & renderNode(n[0], indent) & "](" & renderNode(n[1], indent) & ")"

proc renderObjConstr(n: MyNimNode, indent: int): string =
  if n.len == 0: return "()"
  result = renderNode(n[0], indent) & "("
  for i in 1..<n.len:
    if i > 1: result &= ", "
    result &= renderNode(n[i], indent)
  result &= ")"

proc renderExprColonExpr(n: MyNimNode, indent: int): string =
  result = renderNode(n[0], indent) & ": " & renderNode(n[1], indent)

proc renderExprEqExpr(n: MyNimNode, indent: int): string =
  result = renderNode(n[0], indent) & " = " & renderNode(n[1], indent)

# Statement rendering helpers
proc renderAsgn(n: MyNimNode, indent: int): string =
  result = ind(indent) & renderNode(n[0], indent) & " = " & renderNode(n[1], indent)

proc renderIdentDefs(n: MyNimNode, indent: int): string =
  # name: type = default
  result = renderNode(n[0], indent)
  if n.len > 1 and n[1].kind != nnkEmpty:
    let typeStr = renderNode(n[1], indent)
    # Skip type annotation if it's "var" (C# var keyword with inferred type)
    if typeStr != "var":
      result &= ": " & typeStr
  if n.len > 2 and n[2].kind != nnkEmpty:
    result &= " = " & renderNode(n[2], indent)

proc renderVarSection(n: MyNimNode, indent: int): string =
  result = ind(indent) & "var "
  for i, identDefs in n:
    if i > 0: result &= "\n" & ind(indent) & "var "
    result &= renderIdentDefs(identDefs, 0)

proc renderLetSection(n: MyNimNode, indent: int): string =
  result = ind(indent) & "let "
  for i, identDefs in n:
    if i > 0: result &= "\n" & ind(indent) & "let "
    result &= renderIdentDefs(identDefs, 0)

proc renderConstSection(n: MyNimNode, indent: int): string =
  result = ind(indent) & "const\n"
  for constDef in n:
    result &= ind(indent + 1) & renderNode(constDef[0], 0)
    if constDef.len > 1 and constDef[1].kind != nnkEmpty:
      result &= ": " & renderNode(constDef[1], 0)
    if constDef.len > 2:
      result &= " = " & renderNode(constDef[2], 0)
    result &= "\n"

proc renderStmtList(n: MyNimNode, indent: int): string =
  for i, stmt in n:
    if i > 0: result &= "\n"
    result &= renderNode(stmt, indent)

proc renderBlockStmt(n: MyNimNode, indent: int): string =
  if n[0].kind != nnkEmpty:
    result = ind(indent) & "block " & renderNode(n[0], 0) & ":\n"
  else:
    result = ind(indent)
    
  result &= renderNode(n[1], indent + 1)

proc renderIfStmt(n: MyNimNode, indent: int): string =
  for i, branch in n:
    if i > 0: result &= "\n"
    result &= renderNode(branch, indent)

proc renderElifBranch(n: MyNimNode, indent: int): string =
  let keyword = "if"  # First branch uses "if", others use "elif"
  result = ind(indent) & keyword & " " & renderNode(n[0], 0) & ":\n"
  if n[1].kind == nnkStmtList:
    result &= renderStmtList(n[1], indent + 1)
  else:
    result &= renderNode(n[1], indent + 1)

proc renderElse(n: MyNimNode, indent: int): string =
  result = ind(indent) & "else:\n"
  if n[0].kind == nnkStmtList:
    result &= renderStmtList(n[0], indent + 1)
  else:
    # For simple expressions, add indentation manually
    result &= ind(indent + 1) & renderNode(n[0], 0) & "\n"

proc renderWhileStmt(n: MyNimNode, indent: int): string =
  result = ind(indent) & "while " & renderNode(n[0], 0) & ":\n"
  if n[1].kind == nnkStmtList:
    result &= renderStmtList(n[1], indent + 1)
  else:
    result &= renderNode(n[1], indent + 1)

proc renderForStmt(n: MyNimNode, indent: int): string =
  result = ind(indent) & "for " & renderNode(n[0], 0)
  result &= " in " & renderNode(n[1], 0) & ":\n"
  if n[2].kind == nnkStmtList:
    result &= renderStmtList(n[2], indent + 1)
  else:
    result &= renderNode(n[2], indent + 1)

proc renderCaseStmt(n: MyNimNode, indent: int): string =
  result = ind(indent) & "case " & renderNode(n[0], 0) & "\n"
  for i in 1..<n.len:
    if i > 1: result &= "\n"
    result &= renderNode(n[i], indent)

proc renderOfBranch(n: MyNimNode, indent: int): string =
  result = ind(indent) & "of "
  for i in 0..<n.len-1:
    if i > 0: result &= ", "
    result &= renderNode(n[i], 0)
  result &= ":\n"
  let body = n[n.len-1]
  if body.kind == nnkStmtList:
    result &= renderStmtList(body, indent + 1)
  else:
    # For simple expressions, add indentation manually
    result &= ind(indent + 1) & renderNode(body, 0) & "\n"

proc renderReturnStmt(n: MyNimNode, indent: int): string =
  result = ind(indent) & "return"
  if n.len > 0 and n[0].kind != nnkEmpty:
    # Special handling for case expressions - they need the branches indented at parent level
    if n[0].kind == nnkCaseStmt:
      result &= " case " & renderNode(n[0][0], 0) & "\n"
      # Render branches with parent's indentation
      for i in 1..<n[0].len:
        if i > 1: result &= "\n"
        result &= renderNode(n[0][i], indent)
    else:
      result &= " " & renderNode(n[0], 0)

proc renderYieldStmt(n: MyNimNode, indent: int): string =
  result = ind(indent) & "yield"
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= " " & renderNode(n[0], 0)

proc renderDiscardStmt(n: MyNimNode, indent: int): string =
  result = ind(indent) & "discard"
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= " " & renderNode(n[0], 0)

proc renderBreakStmt(n: MyNimNode, indent: int): string =
  result = ind(indent) & "break"
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= " " & renderNode(n[0], 0)

proc renderContinueStmt(n: MyNimNode, indent: int): string =
  result = ind(indent) & "continue"

proc renderRaiseStmt(n: MyNimNode, indent: int): string =
  result = ind(indent) & "raise"
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= " " & renderNode(n[0], 0)

proc renderTryStmt(n: MyNimNode, indent: int): string =
  # Try statement: [0] is try body, [1..n-1] are except/finally branches
  result = ind(indent) & "try:\n"
  if n.len > 0 and n[0].kind != nnkEmpty:
    if n[0].kind == nnkStmtList:
      result &= renderStmtList(n[0], indent + 1)
    else:
      result &= renderNode(n[0], indent + 1)

  for i in 1..<n.len:
    result &= "\n"
    result &= renderNode(n[i], indent)

proc renderExceptBranch(n: MyNimNode, indent: int): string =
  # Except branch: [0..n-2] are exception types, [n-1] is the body
  result = ind(indent) & "except"
  if n.len > 1:
    # Render exception types with space after except
    result &= " "
    for i in 0..<n.len-1:
      if i > 0: result &= ", "
      result &= renderNode(n[i], 0)
  result &= ":\n"
  let body = n[n.len - 1]
  if body.kind == nnkStmtList:
    result &= renderStmtList(body, indent + 1)
  else:
    result &= renderNode(body, indent + 1)

proc renderFinally(n: MyNimNode, indent: int): string =
  # Finally block: [0] is the body
  result = ind(indent) & "finally:\n"
  if n.len > 0 and n[0].kind != nnkEmpty:
    if n[0].kind == nnkStmtList:
      result &= renderStmtList(n[0], indent + 1)
    else:
      result &= renderNode(n[0], indent + 1)

# Procedure/function rendering
proc renderFormalParams(n: MyNimNode, indent: int): string =
  # [0] is return type, [1..] are parameters
  result = "("
  for i in 1..<n.len:
    if i > 1: result &= ", "
    result &= renderIdentDefs(n[i], 0)
  result &= ")"
  if n.len > 0 and n[0].kind != nnkEmpty:
    # Skip rendering void return type (idiomatic Nim has no return type for void procedures)
    let returnType = renderNode(n[0], 0)
    if returnType != "void":
      result &= ": " & returnType

proc renderProcDef(n: MyNimNode, indent: int): string =
  result = ind(indent) & "proc "
  # [0] name, [1] term rewriting, [2] generic params, [3] params, [4] return type/pragma, [5] reserved, [6] body
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= renderNode(n[0], 0)
  if n.len > 2 and n[2].kind != nnkEmpty:
    result &= "[" & renderNode(n[2], 0) & "]"
  if n.len > 3 and n[3].kind != nnkEmpty:
    result &= renderFormalParams(n[3], 0)
  if n.len > 4 and n[4].kind == nnkPragma:
    result &= " {." & renderNode(n[4], 0) & ".}"
  result &= " =\n"
  if n.len > 6 and n[6].kind != nnkEmpty:
    if n[6].kind == nnkStmtList:
      result &= renderStmtList(n[6], indent + 1)
    else:
      result &= renderNode(n[6], indent + 1)
  else:
    result &= ind(indent + 1) & "discard"

proc renderFuncDef(n: MyNimNode, indent: int): string =
  result = ind(indent) & "func "
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= renderNode(n[0], 0)
  if n.len > 2 and n[2].kind != nnkEmpty:
    result &= "[" & renderNode(n[2], 0) & "]"
  if n.len > 3 and n[3].kind != nnkEmpty:
    result &= renderFormalParams(n[3], 0)
  result &= " =\n"
  if n.len > 6 and n[6].kind != nnkEmpty:
    result &= renderNode(n[6], indent + 1)
  else:
    result &= ind(indent + 1) & "discard"

proc renderMethodDef(n: MyNimNode, indent: int): string =
  result = ind(indent) & "method "
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= renderNode(n[0], 0)
  if n.len > 3 and n[3].kind != nnkEmpty:
    result &= renderFormalParams(n[3], 0)
  result &= " =\n"
  if n.len > 6 and n[6].kind != nnkEmpty:
    result &= renderNode(n[6], indent + 1)

proc renderIteratorDef(n: MyNimNode, indent: int): string =
  result = ind(indent) & "iterator "
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= renderNode(n[0], 0)
  if n.len > 3 and n[3].kind != nnkEmpty:
    result &= renderFormalParams(n[3], 0)
  result &= " =\n"
  if n.len > 6 and n[6].kind != nnkEmpty:
    result &= renderNode(n[6], indent + 1)

proc renderTemplateDef(n: MyNimNode, indent: int): string =
  result = ind(indent) & "template "
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= renderNode(n[0], 0)
  if n.len > 3 and n[3].kind != nnkEmpty:
    result &= renderFormalParams(n[3], 0)
  result &= " =\n"
  if n.len > 6 and n[6].kind != nnkEmpty:
    result &= renderNode(n[6], indent + 1)

proc renderMacroDef(n: MyNimNode, indent: int): string =
  result = ind(indent) & "macro "
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= renderNode(n[0], 0)
  if n.len > 3 and n[3].kind != nnkEmpty:
    result &= renderFormalParams(n[3], 0)
  result &= " =\n"
  if n.len > 6 and n[6].kind != nnkEmpty:
    result &= renderNode(n[6], indent + 1)

# Type rendering
proc renderTypeDef(n: MyNimNode, indent: int): string =
  # [0] name, [1] generic params, [2] type def
  result = ind(indent) & renderNode(n[0], 0)
  if n.len > 1 and n[1].kind != nnkEmpty:
    result &= "[" & renderNode(n[1], 0) & "]"
  if n.len > 2 and n[2].kind != nnkEmpty:
    result &= " = " & renderNode(n[2], indent)

proc renderTypeSection(n: MyNimNode, indent: int): string =
  result = ind(indent) & "type\n"
  for typeDef in n:
    result &= renderTypeDef(typeDef, indent + 1) & "\n"

proc renderObjectTy(n: MyNimNode, indent: int): string =
  result = "object"
  if n.len > 0 and n[0].kind != nnkEmpty:
    result &= " of " & renderNode(n[0], 0)
  if n.len > 2 and n[2].kind != nnkEmpty:
    result &= "\n" & renderNode(n[2], indent + 1)

proc renderRecList(n: MyNimNode, indent: int): string =
  for i, field in n:
    if i > 0: result &= "\n"
    result &= ind(indent) & renderIdentDefs(field, 0)

proc renderRefTy(n: MyNimNode, indent: int): string =
  result = "ref "
  if n.len > 0:
    result &= renderNode(n[0], indent)

proc renderPtrTy(n: MyNimNode, indent: int): string =
  result = "ptr "
  if n.len > 0:
    result &= renderNode(n[0], indent)

proc renderVarTy(n: MyNimNode, indent: int): string =
  result = "var "
  if n.len > 0:
    result &= renderNode(n[0], indent)

proc renderDistinctTy(n: MyNimNode, indent: int): string =
  result = "distinct "
  if n.len > 0:
    result &= renderNode(n[0], indent)

proc renderEnumFieldDef(n: MyNimNode, indent: int): string =
  # Enum field definition: [name] or [name, value]
  if n.len > 0 and n[0].kind != nnkEmpty:
    result = renderNode(n[0], 0)
    if n.len > 1 and n[1].kind != nnkEmpty:
      result &= " = " & renderNode(n[1], 0)

proc renderEnumTy(n: MyNimNode, indent: int): string =
  result = "enum\n"
  for i, field in n:
    if i == 0 and field.kind == nnkEmpty: continue
    result &= ind(indent + 1) & renderNode(field, 0)
    if i < n.len - 1: result &= "\n"

proc renderTupleTy(n: MyNimNode, indent: int): string =
  result = "tuple["
  for i, field in n:
    if i > 0: result &= ", "
    result &= renderIdentDefs(field, 0)
  result &= "]"

proc renderProcTy(n: MyNimNode, indent: int): string =
  result = "proc"
  if n.len > 0:
    result &= renderFormalParams(n[0], 0)

# Import/export rendering
proc renderImportStmt(n: MyNimNode, indent: int): string =
  result = ind(indent) & "import "
  for i, child in n:
    if i > 0: result &= ", "
    result &= renderNode(child, 0)

proc renderExportStmt(n: MyNimNode, indent: int): string =
  result = ind(indent) & "export "
  for i, child in n:
    if i > 0: result &= ", "
    result &= renderNode(child, 0)

proc renderFromStmt(n: MyNimNode, indent: int): string =
  result = ind(indent) & "from " & renderNode(n[0], 0) & " import "
  for i in 1..<n.len:
    if i > 1: result &= ", "
    result &= renderNode(n[i], 0)

proc renderIncludeStmt(n: MyNimNode, indent: int): string =
  result = ind(indent) & "include "
  for i, child in n:
    if i > 0: result &= ", "
    result &= renderNode(child, 0)

# Pragma rendering
proc renderPragma(n: MyNimNode, indent: int): string =
  for i, child in n:
    if i > 0: result &= ", "
    result &= renderNode(child, 0)

proc renderPragmaExpr(n: MyNimNode, indent: int): string =
  result = renderNode(n[0], indent) & " {." & renderNode(n[1], 0) & ".}"

# Comment rendering
proc renderCommentStmt(n: MyNimNode, indent: int): string =
  result = ind(indent) & "# "
  if n.len > 0:
    result &= renderNode(n[0], 0)

# Main rendering dispatch
proc renderNode(n: MyNimNode, indent: int = 0): string =
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
    result = renderInfix(n, indent)
  of nnkPrefix:
    result = renderPrefix(n, indent)
  of nnkPostfix:
    result = renderPostfix(n, indent)
  of nnkCall:
    result = renderCall(n, indent)
  of nnkCommand:
    result = renderCommand(n, indent)
  of nnkDotExpr:
    result = renderDotExpr(n, indent)
  of nnkBracketExpr:
    result = renderBracketExpr(n, indent)
  of nnkPar:
    result = renderPar(n, indent)
  of nnkBracket:
    result = renderBracket(n, indent)
  of nnkCurly:
    result = renderCurly(n, indent)
  of nnkTupleConstr:
    result = renderTupleConstr(n, indent)
  of nnkObjConstr:
    result = renderObjConstr(n, indent)
  of nnkCast:
    result = renderCast(n, indent)
  of nnkExprColonExpr:
    result = renderExprColonExpr(n, indent)
  of nnkExprEqExpr:
    result = renderExprEqExpr(n, indent)

  # Statements
  of nnkAsgn:
    result = renderAsgn(n, indent)
  of nnkIdentDefs:
    result = renderIdentDefs(n, indent)
  of nnkVarSection:
    result = renderVarSection(n, indent)
  of nnkLetSection:
    result = renderLetSection(n, indent)
  of nnkConstSection:
    result = renderConstSection(n, indent)
  of nnkStmtList, nnkStmtListExpr:
    result = renderStmtList(n, indent)
  of nnkBlockStmt:
    result = renderBlockStmt(n, indent)
  of nnkIfStmt:
    result = renderIfStmt(n, indent)
  of nnkElifBranch:
    result = renderElifBranch(n, indent)
  of nnkElse:
    result = renderElse(n, indent)
  of nnkWhileStmt:
    result = renderWhileStmt(n, indent)
  of nnkForStmt:
    result = renderForStmt(n, indent)
  of nnkCaseStmt:
    result = renderCaseStmt(n, indent)
  of nnkOfBranch:
    result = renderOfBranch(n, indent)
  of nnkReturnStmt:
    result = renderReturnStmt(n, indent)
  of nnkYieldStmt:
    result = renderYieldStmt(n, indent)
  of nnkDiscardStmt:
    result = renderDiscardStmt(n, indent)
  of nnkBreakStmt:
    result = renderBreakStmt(n, indent)
  of nnkContinueStmt:
    result = renderContinueStmt(n, indent)
  of nnkRaiseStmt:
    result = renderRaiseStmt(n, indent)
  of nnkTryStmt:
    result = renderTryStmt(n, indent)
  of nnkExceptBranch:
    result = renderExceptBranch(n, indent)
  of nnkFinally:
    result = renderFinally(n, indent)

  # Procedures/functions
  of nnkProcDef:
    result = renderProcDef(n, indent)
  of nnkFuncDef:
    result = renderFuncDef(n, indent)
  of nnkMethodDef:
    result = renderMethodDef(n, indent)
  of nnkIteratorDef:
    result = renderIteratorDef(n, indent)
  of nnkTemplateDef:
    result = renderTemplateDef(n, indent)
  of nnkMacroDef:
    result = renderMacroDef(n, indent)
  of nnkFormalParams:
    result = renderFormalParams(n, indent)

  # Types
  of nnkTypeSection:
    result = renderTypeSection(n, indent)
  of nnkTypeDef:
    result = renderTypeDef(n, indent)
  of nnkObjectTy:
    result = renderObjectTy(n, indent)
  of nnkRecList:
    result = renderRecList(n, indent)
  of nnkRefTy:
    result = renderRefTy(n, indent)
  of nnkPtrTy:
    result = renderPtrTy(n, indent)
  of nnkVarTy:
    result = renderVarTy(n, indent)
  of nnkDistinctTy:
    result = renderDistinctTy(n, indent)
  of nnkEnumTy:
    result = renderEnumTy(n, indent)
  of nnkEnumFieldDef:
    result = renderEnumFieldDef(n, indent)
  of nnkTupleTy:
    result = renderTupleTy(n, indent)
  of nnkProcTy:
    result = renderProcTy(n, indent)

  # Import/export
  of nnkImportStmt:
    result = renderImportStmt(n, indent)
  of nnkExportStmt:
    result = renderExportStmt(n, indent)
  of nnkFromStmt:
    result = renderFromStmt(n, indent)
  of nnkIncludeStmt:
    result = renderIncludeStmt(n, indent)

  # Pragmas
  of nnkPragma:
    result = renderPragma(n, indent)
  of nnkPragmaExpr:
    result = renderPragmaExpr(n, indent)

  # Comments
  of nnkCommentStmt:
    result = renderCommentStmt(n, indent)

  else:
    result = "<unhandled: " & $n.kind & ">"

proc renderNodes(nodes: openArray[MyNimNode], sep: string, indent: int = 0): string =
  for i, node in nodes:
    if i > 0: result &= sep
    result &= renderNode(node, indent)

# Public API
proc `$`*(n: MyNimNode): string =
  ## Convert a MyNimNode tree to Nim source code
  renderNode(n, 0)

proc toNimCode*(n: MyNimNode): string =
  ## Convert a MyNimNode tree to Nim source code (alias for $)
  renderNode(n, 0)
