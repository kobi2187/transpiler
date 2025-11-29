# Independent NimNode structure mimicking the Nim compiler's AST
# Based on Nim compiler's ast.nim but with no external dependencies

import std/strutils

type
  MyNodeKind* = enum
    # Order matches TNodeKind from compiler/nodekinds.nim
    nnkNone,              # unknown node kind: indicates an error
    nnkEmpty,             # the node is empty
    nnkIdent,             # node is an identifier
    nnkSym,               # node is a symbol
    nnkType,              # node is used for its typ field

    # Literal nodes
    nnkCharLit,           # character literal
    nnkIntLit,            # integer literal
    nnkInt8Lit,
    nnkInt16Lit,
    nnkInt32Lit,
    nnkInt64Lit,
    nnkUIntLit,
    nnkUInt8Lit,
    nnkUInt16Lit,
    nnkUInt32Lit,
    nnkUInt64Lit,
    nnkFloatLit,          # floating point literal
    nnkFloat32Lit,
    nnkFloat64Lit,
    nnkFloat128Lit,
    nnkStrLit,            # string literal
    nnkRStrLit,           # raw string literal
    nnkTripleStrLit,      # triple string literal
    nnkNilLit,            # nil literal

    # Expression nodes
    nnkComesFrom,
    nnkDotCall,
    nnkCommand,
    nnkCall,
    nnkCallStrLit,
    nnkInfix,
    nnkPrefix,
    nnkPostfix,
    nnkHiddenCallConv,
    nnkExprEqExpr,
    nnkExprColonExpr,
    nnkIdentDefs,
    nnkVarTuple,
    nnkPar,
    nnkObjConstr,
    nnkCurly,
    nnkCurlyExpr,
    nnkBracket,
    nnkBracketExpr,
    nnkPragmaExpr,
    nnkRange,
    nnkDotExpr,
    nnkCheckedFieldExpr,
    nnkDerefExpr,
    nnkIfExpr,
    nnkElifExpr,
    nnkElseExpr,
    nnkLambda,
    nnkDo,
    nnkAccQuoted,
    nnkTableConstr,
    nnkBind,

    # Type conversion nodes
    nnkClosedSymChoice,
    nnkOpenSymChoice,
    nnkHiddenStdConv,
    nnkHiddenSubConv,
    nnkConv,
    nnkCast,
    nnkStaticExpr,
    nnkAddr,
    nnkHiddenAddr,
    nnkHiddenDeref,
    nnkObjDownConv,
    nnkObjUpConv,
    nnkChckRangeF,
    nnkChckRange64,
    nnkChckRange,
    nnkStringToCString,
    nnkCStringToString,

    # Statement/declaration nodes
    nnkAsgn,
    nnkFastAsgn,
    nnkGenericParams,
    nnkFormalParams,
    nnkOfInherit,
    nnkImportAs,
    nnkProcDef,
    nnkMethodDef,
    nnkConverterDef,
    nnkMacroDef,
    nnkTemplateDef,
    nnkIteratorDef,
    nnkOfBranch,
    nnkElifBranch,
    nnkExceptBranch,
    nnkElse,
    nnkAsmStmt,
    nnkPragma,
    nnkPragmaBlock,
    nnkIfStmt,
    nnkWhenStmt,
    nnkForStmt,
    nnkParForStmt,
    nnkWhileStmt,
    nnkCaseStmt,
    nnkTypeSection,
    nnkVarSection,
    nnkLetSection,
    nnkConstSection,
    nnkConstDef,
    nnkTypeDef,
    nnkYieldStmt,
    nnkDefer,
    nnkTryStmt,
    nnkFinally,
    nnkRaiseStmt,
    nnkReturnStmt,
    nnkBreakStmt,
    nnkContinueStmt,
    nnkBlockStmt,
    nnkStaticStmt,
    nnkDiscardStmt,
    nnkStmtList,
    nnkImportStmt,
    nnkImportExceptStmt,
    nnkExportStmt,
    nnkExportExceptStmt,
    nnkFromStmt,
    nnkIncludeStmt,
    nnkBindStmt,
    nnkMixinStmt,
    nnkUsingStmt,
    nnkCommentStmt,
    nnkStmtListExpr,
    nnkBlockExpr,
    nnkStmtListType,
    nnkBlockType,
    nnkWith,
    nnkWithout,
    nnkTypeOfExpr,

    # Type nodes
    nnkObjectTy,
    nnkTupleTy,
    nnkTupleClassTy,
    nnkTypeClassTy,
    nnkStaticTy,
    nnkRecList,
    nnkRecCase,
    nnkRecWhen,
    nnkRefTy,
    nnkPtrTy,
    nnkVarTy,
    nnkConstTy,
    nnkOutTy,
    nnkDistinctTy,
    nnkProcTy,
    nnkIteratorTy,
    nnkSinkAsgn,
    nnkEnumTy,
    nnkEnumFieldDef,
    nnkArgList,
    nnkPattern,

    # Special nodes
    nnkHiddenTryStmt,
    nnkClosure,
    nnkGotoState,
    nnkState,
    nnkBreakState,
    nnkFuncDef,
    nnkTupleConstr,
    nnkError

  MyNodeKindSet* = set[MyNodeKind]

type
  MyNimNode* = ref MyNimNodeObj
  MyNimNodeSeq* = seq[MyNimNode]

  MyNimNodeObj* = object
    ## Independent NimNode structure based on the Nim compiler's TNode
    case kind*: MyNodeKind
    # Literal nodes with int values
    of nnkCharLit, nnkIntLit, nnkInt8Lit, nnkInt16Lit, nnkInt32Lit, nnkInt64Lit,
       nnkUIntLit, nnkUInt8Lit, nnkUInt16Lit, nnkUInt32Lit, nnkUInt64Lit:
      intVal*: BiggestInt
    # Literal nodes with float values
    of nnkFloatLit, nnkFloat32Lit, nnkFloat64Lit, nnkFloat128Lit:
      floatVal*: BiggestFloat
    # Literal nodes with string values
    of nnkStrLit, nnkRStrLit, nnkTripleStrLit:
      strVal*: string
    # Identifier node
    of nnkIdent:
      identStr*: string
    # Symbol node
    of nnkSym:
      symName*: string
    # All other nodes have children
    of nnkNone, nnkEmpty, nnkType, nnkNilLit, nnkComesFrom, nnkDotCall, nnkCommand,
       nnkCall, nnkCallStrLit, nnkInfix, nnkPrefix, nnkPostfix, nnkHiddenCallConv,
       nnkExprEqExpr, nnkExprColonExpr, nnkIdentDefs, nnkVarTuple, nnkPar,
       nnkObjConstr, nnkCurly, nnkCurlyExpr, nnkBracket, nnkBracketExpr,
       nnkPragmaExpr, nnkRange, nnkDotExpr, nnkCheckedFieldExpr, nnkDerefExpr,
       nnkIfExpr, nnkElifExpr, nnkElseExpr, nnkLambda, nnkDo, nnkAccQuoted,
       nnkTableConstr, nnkBind, nnkClosedSymChoice, nnkOpenSymChoice,
       nnkHiddenStdConv, nnkHiddenSubConv, nnkConv, nnkCast, nnkStaticExpr,
       nnkAddr, nnkHiddenAddr, nnkHiddenDeref, nnkObjDownConv, nnkObjUpConv,
       nnkChckRangeF, nnkChckRange64, nnkChckRange, nnkStringToCString,
       nnkCStringToString, nnkAsgn, nnkFastAsgn, nnkGenericParams, nnkFormalParams,
       nnkOfInherit, nnkImportAs, nnkProcDef, nnkMethodDef, nnkConverterDef,
       nnkMacroDef, nnkTemplateDef, nnkIteratorDef, nnkOfBranch, nnkElifBranch,
       nnkExceptBranch, nnkElse, nnkAsmStmt, nnkPragma, nnkPragmaBlock, nnkIfStmt,
       nnkWhenStmt, nnkForStmt, nnkParForStmt, nnkWhileStmt, nnkCaseStmt,
       nnkTypeSection, nnkVarSection, nnkLetSection, nnkConstSection, nnkConstDef,
       nnkTypeDef, nnkYieldStmt, nnkDefer, nnkTryStmt, nnkFinally, nnkRaiseStmt,
       nnkReturnStmt, nnkBreakStmt, nnkContinueStmt, nnkBlockStmt, nnkStaticStmt,
       nnkDiscardStmt, nnkStmtList, nnkImportStmt, nnkImportExceptStmt,
       nnkExportStmt, nnkExportExceptStmt, nnkFromStmt, nnkIncludeStmt,
       nnkBindStmt, nnkMixinStmt, nnkUsingStmt, nnkCommentStmt, nnkStmtListExpr,
       nnkBlockExpr, nnkStmtListType, nnkBlockType, nnkWith, nnkWithout,
       nnkTypeOfExpr, nnkObjectTy, nnkTupleTy, nnkTupleClassTy, nnkTypeClassTy,
       nnkStaticTy, nnkRecList, nnkRecCase, nnkRecWhen, nnkRefTy, nnkPtrTy,
       nnkVarTy, nnkConstTy, nnkOutTy, nnkDistinctTy, nnkProcTy, nnkIteratorTy,
       nnkSinkAsgn, nnkEnumTy, nnkEnumFieldDef, nnkArgList, nnkPattern,
       nnkHiddenTryStmt, nnkClosure, nnkGotoState, nnkState, nnkBreakState,
       nnkFuncDef, nnkTupleConstr, nnkError:
      sons*: MyNimNodeSeq

# Constructor procs
proc newMyNimNode*(kind: MyNodeKind): MyNimNode =
  ## Create a new node with the given kind
  result = MyNimNode(kind: kind)
  case kind
  of nnkCharLit..nnkUInt64Lit:
    result.intVal = 0
  of nnkFloatLit..nnkFloat128Lit:
    result.floatVal = 0.0
  of nnkStrLit..nnkTripleStrLit:
    result.strVal = ""
  of nnkIdent:
    result.identStr = ""
  of nnkSym:
    result.symName = ""
  else:
    result.sons = @[]

proc newIntLitNode*(i: BiggestInt): MyNimNode =
  ## Creates an int literal node from `i`
  result = newMyNimNode(nnkIntLit)
  result.intVal = i

proc newFloatLitNode*(f: BiggestFloat): MyNimNode =
  ## Creates a float literal node from `f`
  result = newMyNimNode(nnkFloatLit)
  result.floatVal = f

proc newStrLitNode*(s: string): MyNimNode =
  ## Creates a string literal node from `s`
  result = newMyNimNode(nnkStrLit)
  result.strVal = s

proc newIdentNode*(s: string): MyNimNode =
  ## Creates an identifier node
  result = newMyNimNode(nnkIdent)
  result.identStr = s

proc newSymNode*(s: string): MyNimNode =
  ## Creates a symbol node
  result = newMyNimNode(nnkSym)
  result.symName = s

proc newCommentStmtNode*(s: string): MyNimNode =
  ## Creates a comment statement node
  result = newMyNimNode(nnkCommentStmt)
  result.sons = @[newStrLitNode(s)]

proc newStmtList*(): MyNimNode =
  ## Creates an empty statement list
  result = newMyNimNode(nnkStmtList)

proc newProc*(): MyNimNode =
  ## Creates a proc definition node
  result = newMyNimNode(nnkProcDef)

# Additional constructor procs for common node types
proc newEmptyNode*(): MyNimNode =
  ## Creates an empty node
  result = newMyNimNode(nnkEmpty)

proc newNilLit*(): MyNimNode =
  ## Creates a nil literal node
  result = newMyNimNode(nnkNilLit)

proc newCharNode*(c: char): MyNimNode =
  ## Creates a character literal node
  result = newMyNimNode(nnkCharLit)
  result.intVal = BiggestInt(c.ord)

proc newCall*(op: MyNimNode, args: varargs[MyNimNode]): MyNimNode =
  ## Creates a call node with operator and arguments
  result = newMyNimNode(nnkCall)
  result.sons.add(op)
  for arg in args:
    result.sons.add(arg)

proc newCall*(op: string, args: varargs[MyNimNode]): MyNimNode =
  ## Creates a call node with operator name and arguments
  result = newMyNimNode(nnkCall)
  result.sons.add(newIdentNode(op))
  for arg in args:
    result.sons.add(arg)

proc newDotExpr*(a, b: MyNimNode): MyNimNode =
  ## Creates a dot expression a.b
  result = newMyNimNode(nnkDotExpr)
  result.sons.add(a)
  result.sons.add(b)

proc newBracketExpr*(base: MyNimNode, indices: varargs[MyNimNode]): MyNimNode =
  ## Creates a bracket expression base[indices]
  result = newMyNimNode(nnkBracketExpr)
  result.sons.add(base)
  for idx in indices:
    result.sons.add(idx)

proc newAssignment*(lhs, rhs: MyNimNode): MyNimNode =
  ## Creates an assignment lhs = rhs
  result = newMyNimNode(nnkAsgn)
  result.sons.add(lhs)
  result.sons.add(rhs)

proc newIdentDefs*(name, typ, default: MyNimNode): MyNimNode =
  ## Creates an identifier definition (name: typ = default)
  result = newMyNimNode(nnkIdentDefs)
  result.sons.add(name)
  result.sons.add(typ)
  result.sons.add(default)

proc newVarStmt*(name, typ, value: MyNimNode): MyNimNode =
  ## Creates a var statement
  result = newMyNimNode(nnkVarSection)
  result.sons.add(newIdentDefs(name, typ, value))

proc newLetStmt*(name, typ, value: MyNimNode): MyNimNode =
  ## Creates a let statement
  result = newMyNimNode(nnkLetSection)
  result.sons.add(newIdentDefs(name, typ, value))

proc newConstStmt*(name, typ, value: MyNimNode): MyNimNode =
  ## Creates a const statement
  result = newMyNimNode(nnkConstSection)
  let constDef = newMyNimNode(nnkConstDef)
  constDef.sons.add(name)
  constDef.sons.add(typ)
  constDef.sons.add(value)
  result.sons.add(constDef)

proc newIfStmt*(branches: varargs[MyNimNode]): MyNimNode =
  ## Creates an if statement with branches
  result = newMyNimNode(nnkIfStmt)
  for branch in branches:
    result.sons.add(branch)

proc newElifBranch*(cond, body: MyNimNode): MyNimNode =
  ## Creates an elif branch
  result = newMyNimNode(nnkElifBranch)
  result.sons.add(cond)
  result.sons.add(body)

proc newElse*(body: MyNimNode): MyNimNode =
  ## Creates an else branch
  result = newMyNimNode(nnkElse)
  result.sons.add(body)

proc newWhileStmt*(cond, body: MyNimNode): MyNimNode =
  ## Creates a while statement
  result = newMyNimNode(nnkWhileStmt)
  result.sons.add(cond)
  result.sons.add(body)

proc newForStmt*(vars, iterable, body: MyNimNode): MyNimNode =
  ## Creates a for statement
  result = newMyNimNode(nnkForStmt)
  result.sons.add(vars)
  result.sons.add(iterable)
  result.sons.add(body)

proc newBlockStmt*(label, body: MyNimNode): MyNimNode =
  ## Creates a block statement
  result = newMyNimNode(nnkBlockStmt)
  result.sons.add(label)
  result.sons.add(body)

proc newReturnStmt*(expr: MyNimNode): MyNimNode =
  ## Creates a return statement
  result = newMyNimNode(nnkReturnStmt)
  result.sons.add(expr)

proc newDiscardStmt*(expr: MyNimNode): MyNimNode =
  ## Creates a discard statement
  result = newMyNimNode(nnkDiscardStmt)
  result.sons.add(expr)

proc newPar*(elements: varargs[MyNimNode]): MyNimNode =
  ## Creates a parenthesized expression or tuple
  result = newMyNimNode(nnkPar)
  for elem in elements:
    result.sons.add(elem)

proc newTupleConstr*(elements: varargs[MyNimNode]): MyNimNode =
  ## Creates a tuple constructor
  result = newMyNimNode(nnkTupleConstr)
  for elem in elements:
    result.sons.add(elem)

proc newBracket*(elements: varargs[MyNimNode]): MyNimNode =
  ## Creates a bracket expression (array/seq literal)
  result = newMyNimNode(nnkBracket)
  for elem in elements:
    result.sons.add(elem)

proc newTree*(kind: MyNodeKind, children: varargs[MyNimNode]): MyNimNode =
  ## Generic tree constructor with children
  result = newMyNimNode(kind)
  for child in children:
    result.sons.add(child)

# Tree manipulation procs
proc add*(parent: MyNimNode, child: MyNimNode) =
  ## Add a child node to a parent node
  assert parent.kind notin {nnkCharLit..nnkUInt64Lit, nnkFloatLit..nnkFloat128Lit,
                             nnkStrLit..nnkTripleStrLit, nnkIdent, nnkSym}
  parent.sons.add(child)

proc `[]`*(n: MyNimNode, i: int): MyNimNode =
  ## Access child node by index
  assert n.kind notin {nnkCharLit..nnkUInt64Lit, nnkFloatLit..nnkFloat128Lit,
                        nnkStrLit..nnkTripleStrLit, nnkIdent, nnkSym}
  result = n.sons[i]

proc `[]=`*(n: MyNimNode, i: int, child: MyNimNode) =
  ## Set child node by index
  assert n.kind notin {nnkCharLit..nnkUInt64Lit, nnkFloatLit..nnkFloat128Lit,
                        nnkStrLit..nnkTripleStrLit, nnkIdent, nnkSym}
  n.sons[i] = child

proc len*(n: MyNimNode): int =
  ## Get the number of children
  if n.kind in {nnkCharLit..nnkUInt64Lit, nnkFloatLit..nnkFloat128Lit,
                nnkStrLit..nnkTripleStrLit, nnkIdent, nnkSym}:
    result = 0
  else:
    result = n.sons.len

iterator items*(n: MyNimNode): MyNimNode =
  ## Iterate over child nodes
  if n.kind notin {nnkCharLit..nnkUInt64Lit, nnkFloatLit..nnkFloat128Lit,
                    nnkStrLit..nnkTripleStrLit, nnkIdent, nnkSym}:
    for son in n.sons:
      yield son

iterator pairs*(n: MyNimNode): tuple[i: int, n: MyNimNode] =
  ## Iterate over child nodes with indices
  if n.kind notin {nnkCharLit..nnkUInt64Lit, nnkFloatLit..nnkFloat128Lit,
                    nnkStrLit..nnkTripleStrLit, nnkIdent, nnkSym}:
    for i, son in n.sons:
      yield (i, son)

# Helper procs for common operations
proc del*(n: MyNimNode, idx: int) =
  ## Delete child at index
  assert n.kind notin {nnkCharLit..nnkUInt64Lit, nnkFloatLit..nnkFloat128Lit,
                        nnkStrLit..nnkTripleStrLit, nnkIdent, nnkSym}
  n.sons.delete(idx)

proc insert*(n: MyNimNode, idx: int, child: MyNimNode) =
  ## Insert child at index
  assert n.kind notin {nnkCharLit..nnkUInt64Lit, nnkFloatLit..nnkFloat128Lit,
                        nnkStrLit..nnkTripleStrLit, nnkIdent, nnkSym}
  n.sons.insert(child, idx)

proc copy*(n: MyNimNode): MyNimNode =
  ## Create a shallow copy of the node
  case n.kind
  of nnkCharLit..nnkUInt64Lit:
    result = newMyNimNode(n.kind)
    result.intVal = n.intVal
  of nnkFloatLit..nnkFloat128Lit:
    result = newMyNimNode(n.kind)
    result.floatVal = n.floatVal
  of nnkStrLit..nnkTripleStrLit:
    result = newMyNimNode(n.kind)
    result.strVal = n.strVal
  of nnkIdent:
    result = newMyNimNode(nnkIdent)
    result.identStr = n.identStr
  of nnkSym:
    result = newMyNimNode(nnkSym)
    result.symName = n.symName
  else:
    result = newMyNimNode(n.kind)
    result.sons = n.sons  # Shallow copy

proc copyTree*(n: MyNimNode): MyNimNode =
  ## Create a deep copy of the node tree
  case n.kind
  of nnkCharLit..nnkUInt64Lit:
    result = newMyNimNode(n.kind)
    result.intVal = n.intVal
  of nnkFloatLit..nnkFloat128Lit:
    result = newMyNimNode(n.kind)
    result.floatVal = n.floatVal
  of nnkStrLit..nnkTripleStrLit:
    result = newMyNimNode(n.kind)
    result.strVal = n.strVal
  of nnkIdent:
    result = newMyNimNode(nnkIdent)
    result.identStr = n.identStr
  of nnkSym:
    result = newMyNimNode(nnkSym)
    result.symName = n.symName
  else:
    result = newMyNimNode(n.kind)
    for child in n.sons:
      result.sons.add(copyTree(child))

proc sameTree*(a, b: MyNimNode): bool =
  ## Check if two trees are structurally identical
  if a.kind != b.kind:
    return false
  case a.kind
  of nnkCharLit..nnkUInt64Lit:
    result = a.intVal == b.intVal
  of nnkFloatLit..nnkFloat128Lit:
    result = a.floatVal == b.floatVal
  of nnkStrLit..nnkTripleStrLit:
    result = a.strVal == b.strVal
  of nnkIdent:
    result = a.identStr == b.identStr
  of nnkSym:
    result = a.symName == b.symName
  else:
    if a.sons.len != b.sons.len:
      return false
    for i in 0..<a.sons.len:
      if not sameTree(a.sons[i], b.sons[i]):
        return false
    result = true

proc last*(n: MyNimNode): MyNimNode =
  ## Get the last child
  assert n.kind notin {nnkCharLit..nnkUInt64Lit, nnkFloatLit..nnkFloat128Lit,
                        nnkStrLit..nnkTripleStrLit, nnkIdent, nnkSym}
  result = n.sons[^1]

proc `last=`*(n: MyNimNode, child: MyNimNode) =
  ## Set the last child
  assert n.kind notin {nnkCharLit..nnkUInt64Lit, nnkFloatLit..nnkFloat128Lit,
                        nnkStrLit..nnkTripleStrLit, nnkIdent, nnkSym}
  n.sons[^1] = child

# String representation
proc `$`*(n: MyNimNode): string =
  ## Convert node to string representation
  case n.kind
  of nnkCharLit..nnkUInt64Lit:
    result = $n.intVal
  of nnkFloatLit..nnkFloat128Lit:
    result = $n.floatVal
  of nnkStrLit..nnkTripleStrLit:
    result = "\"" & n.strVal & "\""
  of nnkIdent:
    result = n.identStr
  of nnkSym:
    result = n.symName
  else:
    result = $n.kind & "(" & $n.sons.len & " children)"

proc treeRepr*(n: MyNimNode, indent: int = 0): string =
  ## Generate a detailed tree representation for debugging
  let spaces = "  ".repeat(indent)
  case n.kind
  of nnkCharLit..nnkUInt64Lit:
    result = spaces & $n.kind & " " & $n.intVal
  of nnkFloatLit..nnkFloat128Lit:
    result = spaces & $n.kind & " " & $n.floatVal
  of nnkStrLit..nnkTripleStrLit:
    result = spaces & $n.kind & " \"" & n.strVal & "\""
  of nnkIdent:
    result = spaces & "Ident " & n.identStr
  of nnkSym:
    result = spaces & "Sym " & n.symName
  else:
    result = spaces & $n.kind
    for child in n.sons:
      result.add("\n" & treeRepr(child, indent + 1))

# Convenience helpers for building specific constructs
proc newInfixCall*(op: string, a, b: MyNimNode): MyNimNode =
  ## Creates an infix call like a + b
  result = newMyNimNode(nnkInfix)
  result.sons.add(newIdentNode(op))
  result.sons.add(a)
  result.sons.add(b)

proc newPrefixCall*(op: string, arg: MyNimNode): MyNimNode =
  ## Creates a prefix call like -a
  result = newMyNimNode(nnkPrefix)
  result.sons.add(newIdentNode(op))
  result.sons.add(arg)

proc newPostfixExport*(name: MyNimNode): MyNimNode =
  ## Creates a postfix export marker name*
  result = newMyNimNode(nnkPostfix)
  result.sons.add(newIdentNode("*"))
  result.sons.add(name)

proc newColonExpr*(name, value: MyNimNode): MyNimNode =
  ## Creates a colon expression name: value
  result = newMyNimNode(nnkExprColonExpr)
  result.sons.add(name)
  result.sons.add(value)

proc newPragma*(pragmas: varargs[MyNimNode]): MyNimNode =
  ## Creates a pragma expression {.pragmas.}
  result = newMyNimNode(nnkPragma)
  for p in pragmas:
    result.sons.add(p)

# High-level builders for transpilers
# These provide a convenient API for building complete declarations

proc buildProcDef*(name: string, params: openArray[tuple[name, typ: string]],
                   returnType: string = "", body: MyNimNode = nil,
                   pragmas: MyNimNode = nil, exported: bool = false): MyNimNode =
  ## High-level proc builder for transpilers
  ##
  ## Example:
  ##   buildProcDef("greet", [("name", "string")], "", bodyStmts)
  ##   buildProcDef("add", [("a", "int"), ("b", "int")], "int", bodyStmts, exported = true)
  result = newMyNimNode(nnkProcDef)

  # 0: name (possibly with export marker)
  let nameNode = newIdentNode(name)
  if exported:
    result.sons.add(newPostfixExport(nameNode))
  else:
    result.sons.add(nameNode)

  result.sons.add(newEmptyNode())  # 1: patterns/term rewriting
  result.sons.add(newEmptyNode())  # 2: generic params

  # 3: formal params
  let formalParams = newMyNimNode(nnkFormalParams)
  if returnType == "":
    formalParams.sons.add(newEmptyNode())  # no return type
  else:
    formalParams.sons.add(newIdentNode(returnType))

  for (pname, ptyp) in params:
    formalParams.sons.add(newIdentDefs(
      newIdentNode(pname),
      if ptyp == "": newEmptyNode() else: newIdentNode(ptyp),
      newEmptyNode()
    ))
  result.sons.add(formalParams)

  # 4: pragma
  if pragmas != nil:
    result.sons.add(pragmas)
  else:
    result.sons.add(newEmptyNode())

  result.sons.add(newEmptyNode())  # 5: reserved

  # 6: body
  if body != nil:
    result.sons.add(body)
  else:
    result.sons.add(newStmtList())

proc buildFuncDef*(name: string, params: openArray[tuple[name, typ: string]],
                   returnType: string = "", body: MyNimNode = nil,
                   exported: bool = false): MyNimNode =
  ## High-level func builder (like proc but implicitly {.noSideEffect.})
  result = newMyNimNode(nnkFuncDef)

  let nameNode = newIdentNode(name)
  if exported:
    result.sons.add(newPostfixExport(nameNode))
  else:
    result.sons.add(nameNode)

  result.sons.add(newEmptyNode())  # 1: patterns
  result.sons.add(newEmptyNode())  # 2: generic params

  # 3: formal params
  let formalParams = newMyNimNode(nnkFormalParams)
  if returnType == "":
    formalParams.sons.add(newEmptyNode())
  else:
    formalParams.sons.add(newIdentNode(returnType))

  for (pname, ptyp) in params:
    formalParams.sons.add(newIdentDefs(
      newIdentNode(pname),
      if ptyp == "": newEmptyNode() else: newIdentNode(ptyp),
      newEmptyNode()
    ))
  result.sons.add(formalParams)

  result.sons.add(newEmptyNode())  # 4: pragma
  result.sons.add(newEmptyNode())  # 5: reserved

  # 6: body
  if body != nil:
    result.sons.add(body)
  else:
    result.sons.add(newStmtList())

proc addParam*(procNode: MyNimNode, name, typ: string, default: MyNimNode = nil) =
  ## Add a parameter to an existing proc/func definition
  ## Useful for building procs incrementally
  assert procNode.kind in {nnkProcDef, nnkFuncDef, nnkMethodDef, nnkIteratorDef,
                           nnkMacroDef, nnkTemplateDef}

  if procNode[3].kind == nnkEmpty:
    # Initialize formal params if empty
    procNode[3] = newMyNimNode(nnkFormalParams)
    procNode[3].sons.add(newEmptyNode())  # return type

  let defaultVal = if default == nil: newEmptyNode() else: default
  procNode[3].sons.add(newIdentDefs(
    newIdentNode(name),
    if typ == "": newEmptyNode() else: newIdentNode(typ),
    defaultVal
  ))

proc setReturnType*(procNode: MyNimNode, typ: string) =
  ## Set the return type of a proc/func definition
  assert procNode.kind in {nnkProcDef, nnkFuncDef, nnkMethodDef, nnkIteratorDef}

  if procNode[3].kind == nnkEmpty:
    procNode[3] = newMyNimNode(nnkFormalParams)
    procNode[3].sons.add(newEmptyNode())

  procNode[3][0] = if typ == "": newEmptyNode() else: newIdentNode(typ)

proc setBody*(procNode: MyNimNode, body: MyNimNode) =
  ## Set the body of a proc/func/method definition
  assert procNode.kind in {nnkProcDef, nnkFuncDef, nnkMethodDef, nnkIteratorDef,
                           nnkMacroDef, nnkTemplateDef}
  procNode[6] = body

proc setPragma*(procNode: MyNimNode, pragma: MyNimNode) =
  ## Set pragma on a proc/func definition
  assert procNode.kind in {nnkProcDef, nnkFuncDef, nnkMethodDef, nnkIteratorDef}
  procNode[4] = pragma

proc buildObjectDef*(name: string, fields: openArray[tuple[name, typ: string]],
                     exported: bool = false, inherits: string = ""): MyNimNode =
  ## Build a complete object type definition
  ##
  ## Example:
  ##   buildObjectDef("Person", [("name", "string"), ("age", "int")], exported = true)
  let typeDef = newMyNimNode(nnkTypeDef)

  # 0: name
  let nameNode = newIdentNode(name)
  if exported:
    typeDef.sons.add(newPostfixExport(nameNode))
  else:
    typeDef.sons.add(nameNode)

  typeDef.sons.add(newEmptyNode())  # 1: generic params

  # 2: object type
  let objTy = newMyNimNode(nnkObjectTy)

  # Inheritance
  if inherits == "":
    objTy.sons.add(newEmptyNode())
  else:
    let ofInherit = newMyNimNode(nnkOfInherit)
    ofInherit.sons.add(newIdentNode(inherits))
    objTy.sons.add(ofInherit)

  objTy.sons.add(newEmptyNode())  # pragmas

  # Fields
  let recList = newMyNimNode(nnkRecList)
  for (fname, ftyp) in fields:
    recList.sons.add(newIdentDefs(
      newIdentNode(fname),
      newIdentNode(ftyp),
      newEmptyNode()
    ))
  objTy.sons.add(recList)

  typeDef.sons.add(objTy)
  result = typeDef

proc buildEnumDef*(name: string, values: openArray[string],
                   exported: bool = false): MyNimNode =
  ## Build an enum type definition
  ##
  ## Example:
  ##   buildEnumDef("Color", ["Red", "Green", "Blue"], exported = true)
  let typeDef = newMyNimNode(nnkTypeDef)

  # 0: name
  let nameNode = newIdentNode(name)
  if exported:
    typeDef.sons.add(newPostfixExport(nameNode))
  else:
    typeDef.sons.add(nameNode)

  typeDef.sons.add(newEmptyNode())  # 1: generic params

  # 2: enum type
  let enumTy = newMyNimNode(nnkEnumTy)
  enumTy.sons.add(newEmptyNode())  # first slot is empty

  for val in values:
    enumTy.sons.add(newIdentNode(val))

  typeDef.sons.add(enumTy)
  result = typeDef

proc wrapInTypeSection*(typeDefs: varargs[MyNimNode]): MyNimNode =
  ## Wrap type definitions in a type section
  result = newMyNimNode(nnkTypeSection)
  for td in typeDefs:
    result.sons.add(td)
