## XLang Parser
## Parses xlang source text into XLangNode AST.
##
## The parser reads the human-readable xlang format (as output by xlang_printer)
## and produces XLangNode objects that can be used directly or serialized to JSON.

import std/[options, strutils, json, sequtils]
import xlang_lexer
import ../../core/xlangtypes

type
  ParseError* = object of CatchableError

  Parser* = ref object
    tokens: seq[Token]
    pos: int
    errors*: seq[string]

# =============================================================================
# Parser Utilities
# =============================================================================

proc newParser*(tokens: seq[Token]): Parser =
  Parser(tokens: tokens, pos: 0, errors: @[])

proc current(p: Parser): Token =
  if p.pos < p.tokens.len:
    p.tokens[p.pos]
  else:
    Token(kind: tkEOF, value: "", line: 0, col: 0)

proc peek(p: Parser, offset: int = 0): Token =
  let idx = p.pos + offset
  if idx < p.tokens.len:
    p.tokens[idx]
  else:
    Token(kind: tkEOF, value: "", line: 0, col: 0)

proc advance(p: Parser): Token =
  result = p.current()
  if p.pos < p.tokens.len:
    inc p.pos

proc check(p: Parser, kind: TokenKind): bool =
  p.current().kind == kind

proc checkAny(p: Parser, kinds: set[TokenKind]): bool =
  p.current().kind in kinds

proc match(p: Parser, kind: TokenKind): bool =
  if p.check(kind):
    discard p.advance()
    true
  else:
    false

proc expect(p: Parser, kind: TokenKind, msg: string = ""): Token =
  if p.check(kind):
    return p.advance()
  let errMsg = if msg.len > 0: msg else: "Expected " & $kind & " but got " & $p.current().kind
  p.errors.add(errMsg & " at line " & $p.current().line & ":" & $p.current().col)
  raise newException(ParseError, errMsg)

proc skipNewlines(p: Parser) =
  while p.check(tkNewline):
    discard p.advance()

proc skipNewlinesAndComments(p: Parser) =
  while p.checkAny({tkNewline, tkComment, tkDocComment}):
    discard p.advance()

proc expectIndentedBlock(p: Parser): bool =
  ## Expects newline followed by indent
  p.skipNewlines()
  if p.check(tkIndent):
    discard p.advance()
    true
  else:
    false

proc atBlockEnd(p: Parser): bool =
  ## Check if we're at the end of an indented block
  p.check(tkDedent) or p.check(tkEOF)

# =============================================================================
# Operator Mapping
# =============================================================================

proc tokenToBinaryOp(kind: TokenKind): Option[BinaryOp] =
  case kind
  of tkPlus: some(opAdd)
  of tkMinus: some(opSub)
  of tkStar: some(opMul)
  of tkSlash: some(opDiv)
  of tkPercent: some(opMod)
  of tkStarStar: some(opPow)
  of tkSlashSlash: some(opIntDiv)
  of tkAmpersand: some(opBitAnd)
  of tkPipe: some(opBitOr)
  of tkCaret: some(opBitXor)
  of tkAmpCaret: some(opBitAndNot)
  of tkShl: some(opShiftLeft)
  of tkShr: some(opShiftRight)
  of tkShru: some(opShiftRightUnsigned)
  of tkEq: some(opEqual)
  of tkNeq: some(opNotEqual)
  of tkLt: some(opLess)
  of tkLe: some(opLessEqual)
  of tkGt: some(opGreater)
  of tkGe: some(opGreaterEqual)
  of tkIs: some(opIdentical)
  of tkIsnot: some(opNotIdentical)
  of tkAnd: some(opLogicalAnd)
  of tkOr: some(opLogicalOr)
  of tkQQ: some(opNullCoalesce)
  of tkQColon: some(opElvis)
  of tkDotDot: some(opRange)
  of tkIn: some(opIn)
  of tkNotin: some(opNotIn)
  of tkIstype: some(opIs)
  of tkAs: some(opAs)
  of tkPlusEq: some(opAddAssign)
  of tkMinusEq: some(opSubAssign)
  of tkStarEq: some(opMulAssign)
  of tkSlashEq: some(opDivAssign)
  of tkPercentEq: some(opModAssign)
  of tkAmpEq: some(opBitAndAssign)
  of tkPipeEq: some(opBitOrAssign)
  of tkCaretEq: some(opBitXorAssign)
  of tkShlEq: some(opShiftLeftAssign)
  of tkShrEq: some(opShiftRightAssign)
  of tkShruEq: some(opShiftRightUnsignedAssign)
  else: none(BinaryOp)

proc tokenToUnaryOp(kind: TokenKind): Option[UnaryOp] =
  case kind
  of tkMinus: some(opNegate)
  of tkPlus: some(opUnaryPlus)
  of tkNot: some(opNot)
  of tkTilde: some(opBitNot)
  of tkPlusPlus: some(opPreIncrement)
  of tkMinusMinus: some(opPreDecrement)
  of tkAmpersand: some(opAddressOf)
  of tkStar: some(opDereference)
  of tkAwait: some(opAwait)
  of tkChanRecv: some(opChannelReceive)
  of tkCaret: some(opIndexFromEnd)
  else: none(UnaryOp)

# =============================================================================
# Forward Declarations
# =============================================================================

proc parseExpression(p: Parser): XLangNode
proc parseStatement(p: Parser): XLangNode
proc parseDeclaration(p: Parser): XLangNode
proc parseType(p: Parser): XLangNode
proc parseBlock(p: Parser): XLangNode
proc parseParameter(p: Parser): XLangNode

# =============================================================================
# Type Parsing
# =============================================================================

proc parseType(p: Parser): XLangNode =
  ## Parse a type expression
  let tok = p.current()

  case tok.kind
  of tkIdent:
    let name = p.advance().value
    # Check for generic args
    if p.check(tkLt):
      discard p.advance()  # <
      var args: seq[XLangNode] = @[]
      if not p.check(tkGt):
        args.add(p.parseType())
        while p.check(tkComma):
          discard p.advance()
          args.add(p.parseType())
      discard p.expect(tkGt, "Expected '>' after generic arguments")
      return XLangNode(kind: xnkGenericType, genericTypeName: name, genericArgs: args)
    return XLangNode(kind: xnkNamedType, typeName: name)

  of tkArray:
    discard p.advance()  # array
    discard p.expect(tkLBracket, "Expected '[' after 'array'")
    let elemType = p.parseType()
    var size: Option[XLangNode] = none(XLangNode)
    if p.check(tkComma):
      discard p.advance()
      size = some(p.parseExpression())
    discard p.expect(tkRBracket, "Expected ']' after array type")
    return XLangNode(kind: xnkArrayType, elementType: elemType, arraySize: size)

  of tkMap:
    discard p.advance()  # Map
    discard p.expect(tkLt, "Expected '<' after 'Map'")
    let keyType = p.parseType()
    discard p.expect(tkComma, "Expected ',' in Map type")
    let valType = p.parseType()
    discard p.expect(tkGt, "Expected '>' after Map type")
    return XLangNode(kind: xnkMapType, keyType: keyType, valueType: valType)

  of tkFunc:
    discard p.advance()  # func
    discard p.expect(tkLParen, "Expected '(' after 'func' in type")
    var params: seq[XLangNode] = @[]
    if not p.check(tkRParen):
      params.add(p.parseType())
      while p.check(tkComma):
        discard p.advance()
        params.add(p.parseType())
    discard p.expect(tkRParen, "Expected ')' after function type params")
    var retType: Option[XLangNode] = none(XLangNode)
    if p.check(tkArrow):
      discard p.advance()
      retType = some(p.parseType())
    return XLangNode(kind: xnkFuncType, funcParams: params, funcReturnType: retType)

  of tkPtr:
    discard p.advance()
    return XLangNode(kind: xnkPointerType, referentType: p.parseType())

  of tkRef:
    discard p.advance()
    return XLangNode(kind: xnkReferenceType, referentType: p.parseType())

  of tkDistinct:
    discard p.advance()
    return XLangNode(kind: xnkDistinctType, distinctBaseType: p.parseType())

  of tkChan:
    discard p.advance()  # chan
    discard p.expect(tkLt, "Expected '<' after 'chan'")
    let elemType = p.parseType()
    discard p.expect(tkGt, "Expected '>' after channel type")
    return XLangNode(kind: xnkExternal_GoChanType, extChanElemType: elemType, extChanDir: "both")

  of tkLParen:
    # Tuple type: (T1, T2, ...)
    discard p.advance()
    var elements: seq[XLangNode] = @[]
    if not p.check(tkRParen):
      elements.add(p.parseType())
      while p.check(tkComma):
        discard p.advance()
        elements.add(p.parseType())
    discard p.expect(tkRParen, "Expected ')' after tuple type")
    return XLangNode(kind: xnkTupleType, tupleTypeElements: elements)

  else:
    p.errors.add("Expected type at line " & $tok.line)
    return XLangNode(kind: xnkNamedType, typeName: "unknown")

# =============================================================================
# Expression Parsing (Pratt Parser)
# =============================================================================

proc getPrecedence(kind: TokenKind): int =
  case kind
  of tkOr: 1
  of tkAnd: 2
  of tkPipe: 3
  of tkCaret: 4
  of tkAmpersand: 5
  of tkEq, tkNeq, tkIs, tkIsnot: 6
  of tkLt, tkLe, tkGt, tkGe, tkIn, tkNotin, tkIstype: 7
  of tkDotDot: 8
  of tkShl, tkShr, tkShru: 9
  of tkPlus, tkMinus: 10
  of tkStar, tkSlash, tkPercent, tkSlashSlash: 11
  of tkStarStar: 12
  of tkQQ, tkQColon: 13
  of tkAs: 14
  else: 0

proc parseAtom(p: Parser): XLangNode =
  ## Parse atomic expressions
  let tok = p.current()

  case tok.kind
  of tkIntLit:
    discard p.advance()
    return XLangNode(kind: xnkIntLit, literalValue: tok.value)

  of tkFloatLit:
    discard p.advance()
    return XLangNode(kind: xnkFloatLit, literalValue: tok.value)

  of tkStringLit, tkRawStringLit, tkMultilineStringLit:
    discard p.advance()
    return XLangNode(kind: xnkStringLit, literalValue: tok.value)

  of tkCharLit:
    discard p.advance()
    return XLangNode(kind: xnkCharLit, literalValue: tok.value)

  of tkTrue:
    discard p.advance()
    return XLangNode(kind: xnkBoolLit, boolValue: true)

  of tkFalse:
    discard p.advance()
    return XLangNode(kind: xnkBoolLit, boolValue: false)

  of tkNil:
    discard p.advance()
    return XLangNode(kind: xnkNilLit)

  of tkNone:
    discard p.advance()
    return XLangNode(kind: xnkNoneLit)

  of tkSelf:
    discard p.advance()
    return XLangNode(kind: xnkThisExpr)

  of tkBase:
    discard p.advance()
    return XLangNode(kind: xnkBaseExpr)

  of tkIdent:
    let name = p.advance().value
    return XLangNode(kind: xnkIdentifier, identName: name)

  of tkLParen:
    discard p.advance()  # (
    # Could be tuple or grouping
    if p.check(tkRParen):
      discard p.advance()
      return XLangNode(kind: xnkTupleExpr, elements: @[])

    let first = p.parseExpression()
    if p.check(tkComma):
      # Tuple
      var elements = @[first]
      while p.check(tkComma):
        discard p.advance()
        if p.check(tkRParen):
          break
        elements.add(p.parseExpression())
      discard p.expect(tkRParen, "Expected ')' after tuple")
      return XLangNode(kind: xnkTupleExpr, elements: elements)
    else:
      discard p.expect(tkRParen, "Expected ')' after expression")
      return first

  of tkLBracket:
    discard p.advance()  # [
    var elements: seq[XLangNode] = @[]
    if not p.check(tkRBracket):
      elements.add(p.parseExpression())
      while p.check(tkComma):
        discard p.advance()
        if p.check(tkRBracket):
          break
        elements.add(p.parseExpression())
    discard p.expect(tkRBracket, "Expected ']' after array")
    return XLangNode(kind: xnkArrayLiteral, elements: elements)

  of tkLBrace:
    discard p.advance()  # {
    # Could be set or map
    if p.check(tkRBrace):
      discard p.advance()
      return XLangNode(kind: xnkMapLiteral, entries: @[])

    let first = p.parseExpression()
    if p.check(tkColon):
      # Map literal
      discard p.advance()
      let firstVal = p.parseExpression()
      var entries = @[XLangNode(kind: xnkDictEntry, key: first, value: firstVal)]
      while p.check(tkComma):
        discard p.advance()
        if p.check(tkRBrace):
          break
        let key = p.parseExpression()
        discard p.expect(tkColon, "Expected ':' in map entry")
        let val = p.parseExpression()
        entries.add(XLangNode(kind: xnkDictEntry, key: key, value: val))
      discard p.expect(tkRBrace, "Expected '}' after map")
      return XLangNode(kind: xnkMapLiteral, entries: entries)
    else:
      # Set literal
      var elements = @[first]
      while p.check(tkComma):
        discard p.advance()
        if p.check(tkRBrace):
          break
        elements.add(p.parseExpression())
      discard p.expect(tkRBrace, "Expected '}' after set")
      return XLangNode(kind: xnkSetLiteral, elements: elements)

  of tkDefault:
    discard p.advance()
    var defaultType: Option[XLangNode] = none(XLangNode)
    if p.check(tkLParen):
      discard p.advance()
      defaultType = some(p.parseType())
      discard p.expect(tkRParen, "Expected ')' after default type")
    return XLangNode(kind: xnkDefaultExpr, defaultType: defaultType)

  of tkTypeof:
    discard p.advance()
    discard p.expect(tkLParen, "Expected '(' after 'typeof'")
    let typ = p.parseType()
    discard p.expect(tkRParen, "Expected ')' after typeof")
    return XLangNode(kind: xnkTypeOfExpr, typeOfType: typ)

  of tkSizeof:
    discard p.advance()
    discard p.expect(tkLParen, "Expected '(' after 'sizeof'")
    let typ = p.parseType()
    discard p.expect(tkRParen, "Expected ')' after sizeof")
    return XLangNode(kind: xnkSizeOfExpr, sizeOfType: typ)

  of tkCast:
    discard p.advance()
    discard p.expect(tkLParen, "Expected '(' after 'cast'")
    let expr = p.parseExpression()
    discard p.expect(tkSlash, "Expected '/' in cast expression")
    let typ = p.parseType()
    discard p.expect(tkRParen, "Expected ')' after cast")
    return XLangNode(kind: xnkCastExpr, castExpr: expr, castType: typ)

  of tkLambda:
    discard p.advance()
    var params: seq[XLangNode] = @[]
    if p.check(tkLParen):
      discard p.advance()
      if not p.check(tkRParen):
        params.add(p.parseParameter())
        while p.check(tkComma):
          discard p.advance()
          params.add(p.parseParameter())
      discard p.expect(tkRParen, "Expected ')' after lambda params")
    var retType: Option[XLangNode] = none(XLangNode)
    if p.check(tkArrow):
      discard p.advance()
      retType = some(p.parseType())
    discard p.expect(tkColon, "Expected ':' after lambda signature")
    let body = p.parseBlock()
    return XLangNode(kind: xnkLambdaExpr, lambdaParams: params, lambdaReturnType: retType, lambdaBody: body)

  of tkAwait:
    discard p.advance()
    let expr = p.parseExpression()
    return XLangNode(kind: xnkUnaryExpr, unaryOp: opAwait, unaryOperand: expr)

  of tkAt:
    # Instance variable @name
    discard p.advance()
    if p.check(tkAt):
      # Class variable @@name
      discard p.advance()
      let name = p.expect(tkIdent, "Expected identifier after '@@'").value
      return XLangNode(kind: xnkClassVar, varName: name)
    let name = p.expect(tkIdent, "Expected identifier after '@'").value
    return XLangNode(kind: xnkInstanceVar, varName: name)

  of tkDollar:
    # Global variable $name
    discard p.advance()
    let name = p.expect(tkIdent, "Expected identifier after '$'").value
    return XLangNode(kind: xnkGlobalVar, varName: name)

  else:
    # Unary prefix operators
    let unaryOp = tokenToUnaryOp(tok.kind)
    if unaryOp.isSome:
      discard p.advance()
      let operand = p.parseAtom()
      return XLangNode(kind: xnkUnaryExpr, unaryOp: unaryOp.get, unaryOperand: operand)

    p.errors.add("Unexpected token in expression: " & $tok.kind & " at line " & $tok.line)
    discard p.advance()
    return XLangNode(kind: xnkIdentifier, identName: "error")

proc parsePostfix(p: Parser, left: XLangNode): XLangNode =
  ## Parse postfix operations: calls, indexing, member access
  result = left

  while true:
    case p.current().kind
    of tkLParen:
      # Function call
      discard p.advance()
      var args: seq[XLangNode] = @[]
      if not p.check(tkRParen):
        # Check for named argument
        if p.check(tkIdent) and p.peek(1).kind == tkColon:
          let name = p.advance().value
          discard p.advance()  # :
          let val = p.parseExpression()
          args.add(XLangNode(kind: xnkArgument, argName: some(name), argValue: val))
        else:
          args.add(p.parseExpression())

        while p.check(tkComma):
          discard p.advance()
          if p.check(tkIdent) and p.peek(1).kind == tkColon:
            let name = p.advance().value
            discard p.advance()  # :
            let val = p.parseExpression()
            args.add(XLangNode(kind: xnkArgument, argName: some(name), argValue: val))
          else:
            args.add(p.parseExpression())
      discard p.expect(tkRParen, "Expected ')' after call arguments")
      result = XLangNode(kind: xnkCallExpr, callee: result, args: args)

    of tkLBracket:
      # Index or slice
      discard p.advance()

      # Check for slice
      if p.check(tkDotDot):
        discard p.advance()
        var endExpr: Option[XLangNode] = none(XLangNode)
        if not p.check(tkRBracket) and not p.check(tkColon):
          endExpr = some(p.parseExpression())
        var step: Option[XLangNode] = none(XLangNode)
        if p.check(tkColon):
          discard p.advance()
          step = some(p.parseExpression())
        discard p.expect(tkRBracket, "Expected ']' after slice")
        result = XLangNode(kind: xnkSliceExpr, sliceExpr: result,
                          sliceStart: none(XLangNode), sliceEnd: endExpr, sliceStep: step)
      else:
        let startOrIndex = p.parseExpression()
        if p.check(tkDotDot):
          # Slice with start
          discard p.advance()
          var endExpr: Option[XLangNode] = none(XLangNode)
          if not p.check(tkRBracket) and not p.check(tkColon):
            endExpr = some(p.parseExpression())
          var step: Option[XLangNode] = none(XLangNode)
          if p.check(tkColon):
            discard p.advance()
            step = some(p.parseExpression())
          discard p.expect(tkRBracket, "Expected ']' after slice")
          result = XLangNode(kind: xnkSliceExpr, sliceExpr: result,
                            sliceStart: some(startOrIndex), sliceEnd: endExpr, sliceStep: step)
        elif p.check(tkComma):
          # Multi-dimensional index
          var indices = @[startOrIndex]
          while p.check(tkComma):
            discard p.advance()
            indices.add(p.parseExpression())
          discard p.expect(tkRBracket, "Expected ']' after indices")
          result = XLangNode(kind: xnkIndexExpr, indexExpr: result, indexArgs: indices)
        else:
          discard p.expect(tkRBracket, "Expected ']' after index")
          result = XLangNode(kind: xnkIndexExpr, indexExpr: result, indexArgs: @[startOrIndex])

    of tkDot:
      # Member access
      discard p.advance()
      let member = p.expect(tkIdent, "Expected identifier after '.'").value
      result = XLangNode(kind: xnkMemberAccessExpr, memberExpr: result, memberName: member)

    of tkQDot:
      # Safe navigation
      discard p.advance()
      let member = p.expect(tkIdent, "Expected identifier after '?.'").value
      result = XLangNode(kind: xnkExternal_SafeNavigation, extSafeNavObject: result, extSafeNavMember: member)

    of tkColonColon:
      # Method reference or qualified name
      discard p.advance()
      let member = p.expect(tkIdent, "Expected identifier after '::'").value
      result = XLangNode(kind: xnkMethodReference, refObject: result, refMethod: member)

    of tkPlusPlus:
      # Post-increment
      discard p.advance()
      result = XLangNode(kind: xnkUnaryExpr, unaryOp: opPostIncrement, unaryOperand: result)

    of tkMinusMinus:
      # Post-decrement
      discard p.advance()
      result = XLangNode(kind: xnkUnaryExpr, unaryOp: opPostDecrement, unaryOperand: result)

    else:
      break

proc parseBinaryExpr(p: Parser, minPrec: int): XLangNode =
  ## Pratt parser for binary expressions
  var left = p.parsePostfix(p.parseAtom())

  while true:
    let prec = getPrecedence(p.current().kind)
    if prec < minPrec:
      break

    let opTok = p.advance()
    let binOp = tokenToBinaryOp(opTok.kind)
    if binOp.isNone:
      p.errors.add("Invalid binary operator: " & $opTok.kind)
      break

    let right = p.parseBinaryExpr(prec + 1)
    left = XLangNode(kind: xnkBinaryExpr, binaryLeft: left, binaryOp: binOp.get, binaryRight: right)

  return left

proc parseExpression(p: Parser): XLangNode =
  p.parseBinaryExpr(1)

# =============================================================================
# Parameter Parsing
# =============================================================================

proc parseParameter(p: Parser): XLangNode =
  # Accept identifiers and common keywords used as parameter names (self, base)
  var name: string
  if p.check(tkIdent):
    name = p.advance().value
  elif p.check(tkSelf):
    discard p.advance()
    name = "self"
  elif p.check(tkBase):
    discard p.advance()
    name = "base"
  else:
    discard p.expect(tkIdent, "Expected parameter name")
    name = "error"

  var typ: Option[XLangNode] = none(XLangNode)
  var default: Option[XLangNode] = none(XLangNode)

  if p.check(tkColon):
    discard p.advance()
    typ = some(p.parseType())

  if p.check(tkEqSign):
    discard p.advance()
    default = some(p.parseExpression())

  XLangNode(kind: xnkParameter, paramName: name, paramType: typ, defaultValue: default)

# =============================================================================
# Statement Parsing
# =============================================================================

proc parseBlock(p: Parser): XLangNode =
  ## Parse an indented block of statements
  var stmts: seq[XLangNode] = @[]

  p.skipNewlines()

  if p.check(tkIndent):
    discard p.advance()
    while not p.atBlockEnd():
      p.skipNewlinesAndComments()
      if p.atBlockEnd():
        break
      stmts.add(p.parseStatement())
      p.skipNewlines()

    if p.check(tkDedent):
      discard p.advance()
  else:
    # Single-line block
    stmts.add(p.parseStatement())

  XLangNode(kind: xnkBlockStmt, blockBody: stmts)

proc parseFieldLabel(p: Parser): tuple[label: string, hasValue: bool] =
  ## Parse `| label:` field annotation
  ## Labels can be identifiers or keywords (e.g., | base:, | type:)
  if not p.check(tkPipe):
    return ("", false)
  discard p.advance()  # |
  # Accept identifier or keywords as field labels
  var label: string
  if p.check(tkIdent):
    label = p.advance().value
  elif p.check(tkBase):
    discard p.advance()
    label = "base"
  elif p.check(tkType):
    discard p.advance()
    label = "type"
  elif p.check(tkIn):
    discard p.advance()
    label = "in"
  else:
    # Try to get any token as the label - many keywords can be field names
    let tok = p.advance()
    label = tok.value
    if label.len == 0:
      p.errors.add("Expected field label after '|'")
      return ("", false)
  discard p.expect(tkColon, "Expected ':' after field label")
  return (label, true)

proc parseIfStmt(p: Parser): XLangNode =
  discard p.advance()  # if
  let condition = p.parseExpression()
  discard p.expect(tkColon, "Expected ':' after if condition")
  let body = p.parseBlock()

  var elifBranches: seq[tuple[condition: XLangNode, body: XLangNode]] = @[]
  var elseBody: Option[XLangNode] = none(XLangNode)

  p.skipNewlines()

  while p.check(tkElif):
    discard p.advance()
    let elifCond = p.parseExpression()
    discard p.expect(tkColon, "Expected ':' after elif condition")
    let elifBody = p.parseBlock()
    elifBranches.add((elifCond, elifBody))
    p.skipNewlines()

  if p.check(tkElse):
    discard p.advance()
    discard p.expect(tkColon, "Expected ':' after else")
    elseBody = some(p.parseBlock())

  XLangNode(kind: xnkIfStmt, ifCondition: condition, ifBody: body,
            elifBranches: elifBranches, elseBody: elseBody)

proc parseWhileStmt(p: Parser): XLangNode =
  discard p.advance()  # while
  let condition = p.parseExpression()
  discard p.expect(tkColon, "Expected ':' after while condition")
  let body = p.parseBlock()
  XLangNode(kind: xnkWhileStmt, whileCondition: condition, whileBody: body)

proc parseForeachStmt(p: Parser): XLangNode =
  discard p.advance()  # foreach
  # Parse variable name (identifier only, not full expression to avoid consuming 'in')
  let varName = p.expect(tkIdent, "Expected variable name after foreach").value
  let varExpr = XLangNode(kind: xnkIdentifier, identName: varName)
  discard p.expect(tkIn, "Expected 'in' after foreach variable")
  let iterExpr = p.parseExpression()
  discard p.expect(tkColon, "Expected ':' after foreach iterable")
  let body = p.parseBlock()
  XLangNode(kind: xnkForeachStmt, foreachVar: varExpr, foreachIter: iterExpr, foreachBody: body)

proc parseTryStmt(p: Parser): XLangNode =
  discard p.advance()  # try
  discard p.expect(tkColon, "Expected ':' after try")
  let tryBody = p.parseBlock()

  var catchClauses: seq[XLangNode] = @[]
  var finallyClause: Option[XLangNode] = none(XLangNode)

  p.skipNewlines()

  while p.check(tkCatch):
    discard p.advance()
    var catchVar: Option[string] = none(string)
    var catchType: Option[XLangNode] = none(XLangNode)

    if p.check(tkIdent):
      catchVar = some(p.advance().value)
      if p.check(tkColon):
        discard p.advance()
        catchType = some(p.parseType())
    elif p.check(tkColon):
      discard p.advance()
      catchType = some(p.parseType())

    discard p.expect(tkColon, "Expected ':' after catch")
    let catchBody = p.parseBlock()
    catchClauses.add(XLangNode(kind: xnkCatchStmt, catchVar: catchVar,
                               catchType: catchType, catchBody: catchBody))
    p.skipNewlines()

  if p.check(tkFinally):
    discard p.advance()
    discard p.expect(tkColon, "Expected ':' after finally")
    finallyClause = some(p.parseBlock())

  XLangNode(kind: xnkTryStmt, tryBody: tryBody,
            catchClauses: catchClauses, finallyClause: finallyClause)

proc parseMatchStmt(p: Parser): XLangNode =
  discard p.advance()  # match
  let expr = p.parseExpression()
  p.skipNewlines()

  var cases: seq[XLangNode] = @[]

  if p.expectIndentedBlock():
    while not p.atBlockEnd():
      p.skipNewlinesAndComments()
      if p.atBlockEnd():
        break

      if not p.check(tkPipe):
        break

      discard p.advance()  # |

      if p.check(tkIdent) and p.current().value == "_":
        # Default case
        discard p.advance()
        discard p.expect(tkColon, "Expected ':' after default case")
        let body = p.parseBlock()
        cases.add(XLangNode(kind: xnkDefaultClause, defaultBody: body))
      else:
        # Regular case(s)
        var values: seq[XLangNode] = @[]
        values.add(p.parseExpression())
        while p.check(tkComma):
          discard p.advance()
          values.add(p.parseExpression())
        discard p.expect(tkColon, "Expected ':' after case values")
        let body = p.parseBlock()
        var fallthrough = false
        p.skipNewlines()
        if p.check(tkFallthrough):
          discard p.advance()
          fallthrough = true
        cases.add(XLangNode(kind: xnkCaseClause, caseValues: values,
                           caseBody: body, caseFallthrough: fallthrough))

    if p.check(tkDedent):
      discard p.advance()

  XLangNode(kind: xnkSwitchStmt, switchExpr: expr, switchCases: cases)

proc parseReturnStmt(p: Parser): XLangNode =
  discard p.advance()  # return
  var expr: Option[XLangNode] = none(XLangNode)
  if not p.checkAny({tkNewline, tkDedent, tkEOF}):
    expr = some(p.parseExpression())
  XLangNode(kind: xnkReturnStmt, returnExpr: expr)

proc parseYieldStmt(p: Parser): XLangNode =
  discard p.advance()  # yield
  if p.check(tkFrom):
    discard p.advance()
    let expr = p.parseExpression()
    return XLangNode(kind: xnkIteratorDelegate, iteratorDelegateExpr: expr)
  var expr: Option[XLangNode] = none(XLangNode)
  if not p.checkAny({tkNewline, tkDedent, tkEOF}):
    expr = some(p.parseExpression())
  XLangNode(kind: xnkIteratorYield, iteratorYieldValue: expr)

proc parseBreakStmt(p: Parser): XLangNode =
  discard p.advance()  # break
  var label: Option[string] = none(string)
  if p.check(tkCaret):
    discard p.advance()
    label = some(p.expect(tkIdent, "Expected label after '^'").value)
  XLangNode(kind: xnkBreakStmt, label: label)

proc parseContinueStmt(p: Parser): XLangNode =
  discard p.advance()  # continue
  var label: Option[string] = none(string)
  if p.check(tkCaret):
    discard p.advance()
    label = some(p.expect(tkIdent, "Expected label after '^'").value)
  XLangNode(kind: xnkContinueStmt, label: label)

proc parseThrowStmt(p: Parser): XLangNode =
  discard p.advance()  # throw
  let expr = p.parseExpression()
  XLangNode(kind: xnkThrowStmt, throwExpr: expr)

proc parseRaiseStmt(p: Parser): XLangNode =
  discard p.advance()  # raise
  var expr: Option[XLangNode] = none(XLangNode)
  if not p.checkAny({tkNewline, tkDedent, tkEOF}):
    expr = some(p.parseExpression())
  XLangNode(kind: xnkRaiseStmt, raiseExpr: expr)

proc parseAssertStmt(p: Parser): XLangNode =
  discard p.advance()  # assert
  let cond = p.parseExpression()
  var msg: Option[XLangNode] = none(XLangNode)
  if p.check(tkComma):
    discard p.advance()
    msg = some(p.parseExpression())
  XLangNode(kind: xnkAssertStmt, assertCond: cond, assertMsg: msg)

proc parseDeferStmt(p: Parser): XLangNode =
  discard p.advance()  # defer
  discard p.expect(tkColon, "Expected ':' after defer")
  let body = p.parseBlock()
  XLangNode(kind: xnkDeferStmt, staticBody: body)

proc parseImportStmt(p: Parser): XLangNode =
  discard p.advance()  # import
  let path = p.expect(tkIdent, "Expected import path").value
  var pathParts = path
  while p.check(tkDot):
    discard p.advance()
    pathParts &= "." & p.expect(tkIdent, "Expected identifier in import path").value

  var alias: Option[string] = none(string)
  if p.check(tkAs):
    discard p.advance()
    alias = some(p.expect(tkIdent, "Expected alias name").value)

  XLangNode(kind: xnkImport, importPath: pathParts, importAlias: alias)

proc parseStatement(p: Parser): XLangNode =
  p.skipNewlinesAndComments()

  let tok = p.current()

  case tok.kind
  of tkIf: return p.parseIfStmt()
  of tkWhile: return p.parseWhileStmt()
  of tkForeach: return p.parseForeachStmt()
  of tkTry: return p.parseTryStmt()
  of tkMatch: return p.parseMatchStmt()
  of tkReturn: return p.parseReturnStmt()
  of tkYield: return p.parseYieldStmt()
  of tkBreak: return p.parseBreakStmt()
  of tkContinue: return p.parseContinueStmt()
  of tkThrow: return p.parseThrowStmt()
  of tkRaise: return p.parseRaiseStmt()
  of tkAssert: return p.parseAssertStmt()
  of tkDefer: return p.parseDeferStmt()
  of tkPass:
    discard p.advance()
    return XLangNode(kind: xnkPassStmt)
  of tkDiscard:
    discard p.advance()
    var expr: Option[XLangNode] = none(XLangNode)
    if not p.checkAny({tkNewline, tkDedent, tkEOF}):
      expr = some(p.parseExpression())
    return XLangNode(kind: xnkDiscardStmt, discardExpr: expr)
  of tkImport: return p.parseImportStmt()

  # Variable declarations
  of tkVar, tkLet, tkConst:
    let kind = tok.kind
    discard p.advance()
    let name = p.expect(tkIdent, "Expected variable name").value
    var typ: Option[XLangNode] = none(XLangNode)
    var init: Option[XLangNode] = none(XLangNode)
    if p.check(tkColon):
      discard p.advance()
      typ = some(p.parseType())
    if p.check(tkEqSign):
      discard p.advance()
      init = some(p.parseExpression())
    case kind
    of tkVar:
      return XLangNode(kind: xnkVarDecl, declName: name, declType: typ, initializer: init)
    of tkLet:
      return XLangNode(kind: xnkLetDecl, declName: name, declType: typ, initializer: init)
    else:
      return XLangNode(kind: xnkConstDecl, declName: name, declType: typ, initializer: init)

  # Labeled statement
  of tkCaret:
    discard p.advance()
    let label = p.expect(tkIdent, "Expected label name").value
    p.skipNewlines()
    let stmt = p.parseStatement()
    return XLangNode(kind: xnkLabeledStmt, labelName: label, labeledStmt: stmt)

  of tkGoto:
    discard p.advance()
    discard p.expect(tkCaret, "Expected '^' before label")
    let label = p.expect(tkIdent, "Expected label name").value
    return XLangNode(kind: xnkGotoStmt, gotoLabel: label)

  # Declarations that can appear in statement position
  of tkFunc, tkMethod, tkClass, tkStruct, tkInterface, tkEnum, tkType,
     tkAsync, tkStatic, tkIterator:
    return p.parseDeclaration()

  else:
    # Expression statement or assignment
    let expr = p.parseExpression()

    if p.check(tkEqSign):
      discard p.advance()
      let right = p.parseExpression()
      return XLangNode(kind: xnkAsgn, asgnLeft: expr, asgnRight: right)

    return expr

# =============================================================================
# Declaration Parsing
# =============================================================================

proc parseFuncDecl(p: Parser, isAsync: bool = false, isStatic: bool = false): XLangNode =
  discard p.advance()  # func
  let name = p.expect(tkIdent, "Expected function name").value
  p.skipNewlines()

  var params: seq[XLangNode] = @[]
  var returnType: Option[XLangNode] = none(XLangNode)
  var body: XLangNode = nil
  var visibility = "public"

  # Parse field annotations
  while p.check(tkPipe) or p.check(tkIndent):
    if p.check(tkIndent):
      discard p.advance()
      continue

    let (label, hasValue) = p.parseFieldLabel()
    if not hasValue:
      break

    case label
    of "params":
      if p.expectIndentedBlock():
        while not p.atBlockEnd():
          p.skipNewlinesAndComments()
          if p.atBlockEnd():
            break
          params.add(p.parseParameter())
          p.skipNewlines()
        if p.check(tkDedent):
          discard p.advance()

    of "returns":
      returnType = some(p.parseType())
      p.skipNewlines()

    of "visibility":
      visibility = p.expect(tkIdent, "Expected visibility").value
      p.skipNewlines()

    of "body":
      body = p.parseBlock()

    else:
      p.errors.add("Unknown field label in function: " & label)
      p.skipNewlines()

  XLangNode(kind: xnkFuncDecl, funcName: name, params: params,
            returnType: returnType, body: body, isAsync: isAsync,
            funcIsStatic: isStatic, funcVisibility: visibility)

proc parseMethodDecl(p: Parser, isAsync: bool = false): XLangNode =
  discard p.advance()  # method
  let name = p.expect(tkIdent, "Expected method name").value
  p.skipNewlines()

  var receiver: Option[XLangNode] = none(XLangNode)
  var params: seq[XLangNode] = @[]
  var returnType: Option[XLangNode] = none(XLangNode)
  var body: XLangNode = nil

  # Parse field annotations
  while p.check(tkPipe) or p.check(tkIndent):
    if p.check(tkIndent):
      discard p.advance()
      continue

    let (label, hasValue) = p.parseFieldLabel()
    if not hasValue:
      break

    case label
    of "receiver":
      receiver = some(p.parseParameter())
      p.skipNewlines()

    of "params":
      if p.expectIndentedBlock():
        while not p.atBlockEnd():
          p.skipNewlinesAndComments()
          if p.atBlockEnd():
            break
          params.add(p.parseParameter())
          p.skipNewlines()
        if p.check(tkDedent):
          discard p.advance()

    of "returns":
      returnType = some(p.parseType())
      p.skipNewlines()

    of "body":
      body = p.parseBlock()

    else:
      p.errors.add("Unknown field label in method: " & label)
      p.skipNewlines()

  XLangNode(kind: xnkMethodDecl, methodName: name, receiver: receiver,
            mparams: params, mreturnType: returnType, mbody: body,
            methodIsAsync: isAsync)

proc parseClassDecl(p: Parser): XLangNode =
  discard p.advance()  # class
  let name = p.expect(tkIdent, "Expected class name").value
  p.skipNewlines()

  var baseTypes: seq[XLangNode] = @[]
  var members: seq[XLangNode] = @[]

  # Parse field annotations
  while p.check(tkPipe) or p.check(tkIndent):
    if p.check(tkIndent):
      discard p.advance()
      continue

    let (label, hasValue) = p.parseFieldLabel()
    if not hasValue:
      break

    case label
    of "kind":
      # Accept any keyword (class, struct, interface) or identifier
      discard p.advance()
      p.skipNewlines()

    of "base", "extends", "implements":
      # Parse comma-separated base types
      baseTypes.add(p.parseType())
      while p.check(tkComma):
        discard p.advance()
        baseTypes.add(p.parseType())
      p.skipNewlines()

    of "members", "methods":
      if p.expectIndentedBlock():
        while not p.atBlockEnd():
          p.skipNewlinesAndComments()
          if p.atBlockEnd():
            break
          members.add(p.parseDeclaration())
          p.skipNewlines()
        if p.check(tkDedent):
          discard p.advance()

    else:
      p.errors.add("Unknown field label in class: " & label)
      p.skipNewlines()

  XLangNode(kind: xnkClassDecl, typeNameDecl: name,
            baseTypes: baseTypes, members: members)

proc parseStructDecl(p: Parser): XLangNode =
  discard p.advance()  # struct
  let name = p.expect(tkIdent, "Expected struct name").value
  p.skipNewlines()

  var baseTypes: seq[XLangNode] = @[]
  var members: seq[XLangNode] = @[]

  while p.check(tkPipe) or p.check(tkIndent):
    if p.check(tkIndent):
      discard p.advance()
      continue

    let (label, hasValue) = p.parseFieldLabel()
    if not hasValue:
      break

    case label
    of "kind":
      # Accept any keyword (struct, etc) or identifier
      discard p.advance()
      p.skipNewlines()
    of "implements":
      baseTypes.add(p.parseType())
      while p.check(tkComma):
        discard p.advance()
        baseTypes.add(p.parseType())
      p.skipNewlines()
    of "members":
      if p.expectIndentedBlock():
        while not p.atBlockEnd():
          p.skipNewlinesAndComments()
          if p.atBlockEnd():
            break
          members.add(p.parseDeclaration())
          p.skipNewlines()
        if p.check(tkDedent):
          discard p.advance()
    else:
      p.errors.add("Unknown field label in struct: " & label)
      p.skipNewlines()

  XLangNode(kind: xnkStructDecl, typeNameDecl: name,
            baseTypes: baseTypes, members: members)

proc parseInterfaceDecl(p: Parser): XLangNode =
  discard p.advance()  # interface
  let name = p.expect(tkIdent, "Expected interface name").value
  p.skipNewlines()

  var baseTypes: seq[XLangNode] = @[]
  var members: seq[XLangNode] = @[]

  while p.check(tkPipe) or p.check(tkIndent):
    if p.check(tkIndent):
      discard p.advance()
      continue

    let (label, hasValue) = p.parseFieldLabel()
    if not hasValue:
      break

    case label
    of "kind":
      # Accept any keyword (interface, etc) or identifier
      discard p.advance()
      p.skipNewlines()
    of "extends":
      baseTypes.add(p.parseType())
      while p.check(tkComma):
        discard p.advance()
        baseTypes.add(p.parseType())
      p.skipNewlines()
    of "methods":
      if p.expectIndentedBlock():
        while not p.atBlockEnd():
          p.skipNewlinesAndComments()
          if p.atBlockEnd():
            break
          members.add(p.parseDeclaration())
          p.skipNewlines()
        if p.check(tkDedent):
          discard p.advance()
    else:
      p.errors.add("Unknown field label in interface: " & label)
      p.skipNewlines()

  XLangNode(kind: xnkInterfaceDecl, typeNameDecl: name,
            baseTypes: baseTypes, members: members)

proc parseEnumDecl(p: Parser): XLangNode =
  discard p.advance()  # enum
  let name = p.expect(tkIdent, "Expected enum name").value
  p.skipNewlines()

  var members: seq[XLangNode] = @[]

  while p.check(tkPipe) or p.check(tkIndent):
    if p.check(tkIndent):
      discard p.advance()
      continue

    let (label, hasValue) = p.parseFieldLabel()
    if not hasValue:
      break

    case label
    of "values":
      if p.expectIndentedBlock():
        while not p.atBlockEnd():
          p.skipNewlinesAndComments()
          if p.atBlockEnd():
            break
          let memberName = p.expect(tkIdent, "Expected enum member name").value
          var memberValue: Option[XLangNode] = none(XLangNode)
          if p.check(tkEqSign):
            discard p.advance()
            memberValue = some(p.parseExpression())
          members.add(XLangNode(kind: xnkEnumMember, enumMemberName: memberName, enumMemberValue: memberValue))
          p.skipNewlines()
        if p.check(tkDedent):
          discard p.advance()
    else:
      p.errors.add("Unknown field label in enum: " & label)
      p.skipNewlines()

  XLangNode(kind: xnkEnumDecl, enumName: name, enumMembers: members)

proc parseTypeDecl(p: Parser): XLangNode =
  discard p.advance()  # type
  let name = p.expect(tkIdent, "Expected type name").value
  discard p.expect(tkEqSign, "Expected '=' in type declaration")
  let body = p.parseType()
  XLangNode(kind: xnkTypeDecl, typeDefName: name, typeDefBody: body)

proc parseCtorDecl(p: Parser): XLangNode =
  discard p.advance()  # ctor
  p.skipNewlines()

  var params: seq[XLangNode] = @[]
  var initializers: seq[XLangNode] = @[]
  var body: XLangNode = nil

  while p.check(tkPipe) or p.check(tkIndent):
    if p.check(tkIndent):
      discard p.advance()
      continue

    let (label, hasValue) = p.parseFieldLabel()
    if not hasValue:
      break

    case label
    of "params":
      if p.expectIndentedBlock():
        while not p.atBlockEnd():
          p.skipNewlinesAndComments()
          if p.atBlockEnd():
            break
          params.add(p.parseParameter())
          p.skipNewlines()
        if p.check(tkDedent):
          discard p.advance()
    of "initializers":
      if p.expectIndentedBlock():
        while not p.atBlockEnd():
          p.skipNewlinesAndComments()
          if p.atBlockEnd():
            break
          initializers.add(p.parseExpression())
          p.skipNewlines()
        if p.check(tkDedent):
          discard p.advance()
    of "body":
      body = p.parseBlock()
    else:
      p.errors.add("Unknown field label in constructor: " & label)
      p.skipNewlines()

  XLangNode(kind: xnkConstructorDecl, constructorParams: params,
            constructorInitializers: initializers, constructorBody: body)

proc parseFieldDecl(p: Parser): XLangNode =
  let name = p.expect(tkIdent, "Expected field name").value
  discard p.expect(tkColon, "Expected ':' after field name")
  let typ = p.parseType()
  var init: Option[XLangNode] = none(XLangNode)
  if p.check(tkEqSign):
    discard p.advance()
    init = some(p.parseExpression())
  XLangNode(kind: xnkFieldDecl, fieldName: name, fieldType: typ, fieldInitializer: init)

proc parseIteratorDecl(p: Parser): XLangNode =
  discard p.advance()  # iterator
  let name = p.expect(tkIdent, "Expected iterator name").value
  p.skipNewlines()

  var params: seq[XLangNode] = @[]
  var returnType: Option[XLangNode] = none(XLangNode)
  var body: XLangNode = nil

  while p.check(tkPipe) or p.check(tkIndent):
    if p.check(tkIndent):
      discard p.advance()
      continue

    let (label, hasValue) = p.parseFieldLabel()
    if not hasValue:
      break

    case label
    of "params":
      if p.expectIndentedBlock():
        while not p.atBlockEnd():
          p.skipNewlinesAndComments()
          if p.atBlockEnd():
            break
          params.add(p.parseParameter())
          p.skipNewlines()
        if p.check(tkDedent):
          discard p.advance()
    of "yields":
      returnType = some(p.parseType())
      p.skipNewlines()
    of "body":
      body = p.parseBlock()
    else:
      p.errors.add("Unknown field label in iterator: " & label)
      p.skipNewlines()

  XLangNode(kind: xnkIteratorDecl, iteratorName: name, iteratorParams: params,
            iteratorReturnType: returnType, iteratorBody: body)

proc parseDeclaration(p: Parser): XLangNode =
  p.skipNewlinesAndComments()

  let tok = p.current()

  case tok.kind
  of tkAsync:
    discard p.advance()
    if p.check(tkFunc):
      return p.parseFuncDecl(isAsync = true)
    elif p.check(tkMethod):
      return p.parseMethodDecl(isAsync = true)
    else:
      p.errors.add("Expected 'func' or 'method' after 'async'")
      return XLangNode(kind: xnkUnknown, unknownData: "async")

  of tkStatic:
    discard p.advance()
    if p.check(tkFunc):
      return p.parseFuncDecl(isStatic = true)
    else:
      p.errors.add("Expected 'func' after 'static'")
      return XLangNode(kind: xnkUnknown, unknownData: "static")

  of tkFunc: return p.parseFuncDecl()
  of tkMethod: return p.parseMethodDecl()
  of tkClass: return p.parseClassDecl()
  of tkStruct: return p.parseStructDecl()
  of tkInterface: return p.parseInterfaceDecl()
  of tkEnum: return p.parseEnumDecl()
  of tkType: return p.parseTypeDecl()
  of tkCtor: return p.parseCtorDecl()
  of tkIterator: return p.parseIteratorDecl()

  of tkIdent:
    # Could be a field declaration: name: Type
    if p.peek(1).kind == tkColon:
      return p.parseFieldDecl()
    # Otherwise treat as expression/statement
    return p.parseStatement()

  else:
    return p.parseStatement()

# =============================================================================
# Module Parsing
# =============================================================================

proc parseModule(p: Parser): XLangNode =
  p.skipNewlinesAndComments()

  if not p.check(tkModule):
    p.errors.add("Expected 'module' at start of file")
    return XLangNode(kind: xnkFile, fileName: "unknown", sourceLang: "", moduleDecls: @[])

  discard p.advance()  # module
  let fileName = p.expect(tkIdent, "Expected module name").value
  # Allow dotted names
  var fullName = fileName
  while p.check(tkDot):
    discard p.advance()
    fullName &= "." & p.expect(tkIdent, "Expected identifier in module path").value

  p.skipNewlines()

  var sourceLang = ""
  var decls: seq[XLangNode] = @[]

  while p.check(tkPipe) or p.check(tkIndent):
    if p.check(tkIndent):
      discard p.advance()
      continue

    let (label, hasValue) = p.parseFieldLabel()
    if not hasValue:
      break

    case label
    of "source":
      sourceLang = p.expect(tkIdent, "Expected source language").value
      p.skipNewlines()

    of "body":
      if p.expectIndentedBlock():
        while not p.atBlockEnd():
          p.skipNewlinesAndComments()
          if p.atBlockEnd():
            break
          decls.add(p.parseDeclaration())
          p.skipNewlines()
        if p.check(tkDedent):
          discard p.advance()

    else:
      p.errors.add("Unknown field label in module: " & label)
      p.skipNewlines()

  XLangNode(kind: xnkFile, fileName: fullName, sourceLang: sourceLang, moduleDecls: decls)

# =============================================================================
# Public API
# =============================================================================

proc parse*(source: string): XLangNode =
  ## Parse xlang source text into an XLangNode AST
  let tokens = tokenize(source)
  var parser = newParser(tokens)
  result = parser.parseModule()
  if parser.errors.len > 0:
    raise newException(ParseError, "Parse errors:\n" & parser.errors.join("\n"))

proc parseFile*(filePath: string): XLangNode =
  ## Parse an xlang file into an XLangNode AST
  let source = readFile(filePath)
  parse(source)

proc validate*(source: string): tuple[valid: bool, errors: seq[string]] =
  ## Validate xlang source text and return any errors
  let tokens = tokenize(source)
  var parser = newParser(tokens)
  discard parser.parseModule()
  result = (parser.errors.len == 0, parser.errors)

proc toJson*(node: XLangNode): JsonNode =
  ## Convert XLangNode to JSON (xljs format)
  ## Custom implementation to handle tuple fields properly
  if node.isNil:
    return newJNull()

  result = newJObject()
  result["kind"] = %($node.kind)

  # Add UUID fields if present
  if node.id.isSome:
    result["id"] = %($node.id.get)
  if node.parentId.isSome:
    result["parentId"] = %($node.parentId.get)

  # Add variant-specific fields
  case node.kind
  of xnkFile:
    result["fileName"] = %node.fileName
    result["sourceLang"] = %node.sourceLang
    result["moduleDecls"] = %node.moduleDecls.mapIt(it.toJson())
  of xnkModule:
    result["moduleName"] = %node.moduleName
    result["moduleBody"] = %node.moduleBody.mapIt(it.toJson())
  of xnkNamespace:
    result["namespaceName"] = %node.namespaceName
    result["namespaceBody"] = %node.namespaceBody.mapIt(it.toJson())
  of xnkFuncDecl:
    result["funcName"] = %node.funcName
    result["params"] = %node.params.mapIt(it.toJson())
    if node.returnType.isSome:
      result["returnType"] = node.returnType.get.toJson()
    if node.body != nil:
      result["body"] = node.body.toJson()
    result["isAsync"] = %node.isAsync
    result["funcIsStatic"] = %node.funcIsStatic
    result["funcVisibility"] = %node.funcVisibility
  of xnkMethodDecl:
    result["methodName"] = %node.methodName
    if node.receiver.isSome:
      result["receiver"] = node.receiver.get.toJson()
    result["mparams"] = %node.mparams.mapIt(it.toJson())
    if node.mreturnType.isSome:
      result["mreturnType"] = node.mreturnType.get.toJson()
    if node.mbody != nil:
      result["mbody"] = node.mbody.toJson()
    result["methodIsAsync"] = %node.methodIsAsync
  of xnkIteratorDecl:
    result["iteratorName"] = %node.iteratorName
    result["iteratorParams"] = %node.iteratorParams.mapIt(it.toJson())
    if node.iteratorReturnType.isSome:
      result["iteratorReturnType"] = node.iteratorReturnType.get.toJson()
    if node.iteratorBody != nil:
      result["iteratorBody"] = node.iteratorBody.toJson()
  of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
    result["typeNameDecl"] = %node.typeNameDecl
    result["baseTypes"] = %node.baseTypes.mapIt(it.toJson())
    result["members"] = %node.members.mapIt(it.toJson())
  of xnkEnumDecl:
    result["enumName"] = %node.enumName
    result["enumMembers"] = %node.enumMembers.mapIt(it.toJson())
  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    result["declName"] = %node.declName
    if node.declType.isSome:
      result["declType"] = node.declType.get.toJson()
    if node.initializer.isSome:
      result["initializer"] = node.initializer.get.toJson()
  of xnkTypeDecl:
    result["typeDefName"] = %node.typeDefName
    if node.typeDefBody != nil:
      result["typeDefBody"] = node.typeDefBody.toJson()
  of xnkFieldDecl:
    result["fieldName"] = %node.fieldName
    result["fieldType"] = node.fieldType.toJson()
    if node.fieldInitializer.isSome:
      result["fieldInitializer"] = node.fieldInitializer.get.toJson()
  of xnkConstructorDecl:
    result["constructorParams"] = %node.constructorParams.mapIt(it.toJson())
    result["constructorInitializers"] = %node.constructorInitializers.mapIt(it.toJson())
    if node.constructorBody != nil:
      result["constructorBody"] = node.constructorBody.toJson()
  of xnkDestructorDecl:
    if node.destructorBody.isSome:
      result["destructorBody"] = node.destructorBody.get.toJson()
  of xnkAsgn:
    result["asgnLeft"] = node.asgnLeft.toJson()
    result["asgnRight"] = node.asgnRight.toJson()
  of xnkBlockStmt:
    result["blockBody"] = %node.blockBody.mapIt(it.toJson())
  of xnkIfStmt:
    result["ifCondition"] = node.ifCondition.toJson()
    result["ifBody"] = node.ifBody.toJson()
    # Handle tuple seq specially
    var elifArr = newJArray()
    for branch in node.elifBranches:
      var branchObj = newJObject()
      branchObj["condition"] = branch.condition.toJson()
      branchObj["body"] = branch.body.toJson()
      elifArr.add(branchObj)
    result["elifBranches"] = elifArr
    if node.elseBody.isSome:
      result["elseBody"] = node.elseBody.get.toJson()
  of xnkSwitchStmt:
    result["switchExpr"] = node.switchExpr.toJson()
    result["switchCases"] = %node.switchCases.mapIt(it.toJson())
  of xnkCaseClause:
    result["caseValues"] = %node.caseValues.mapIt(it.toJson())
    result["caseBody"] = node.caseBody.toJson()
    result["caseFallthrough"] = %node.caseFallthrough
  of xnkDefaultClause:
    result["defaultBody"] = node.defaultBody.toJson()
  of xnkWhileStmt, xnkDoWhileStmt:
    result["whileCondition"] = node.whileCondition.toJson()
    result["whileBody"] = node.whileBody.toJson()
  of xnkForeachStmt:
    result["foreachVar"] = node.foreachVar.toJson()
    result["foreachIter"] = node.foreachIter.toJson()
    result["foreachBody"] = node.foreachBody.toJson()
  of xnkTryStmt:
    result["tryBody"] = node.tryBody.toJson()
    result["catchClauses"] = %node.catchClauses.mapIt(it.toJson())
    if node.finallyClause.isSome:
      result["finallyClause"] = node.finallyClause.get.toJson()
  of xnkCatchStmt:
    if node.catchType.isSome:
      result["catchType"] = node.catchType.get.toJson()
    if node.catchVar.isSome:
      result["catchVar"] = %node.catchVar.get
    result["catchBody"] = node.catchBody.toJson()
  of xnkFinallyStmt:
    result["finallyBody"] = node.finallyBody.toJson()
  of xnkReturnStmt:
    if node.returnExpr.isSome:
      result["returnExpr"] = node.returnExpr.get.toJson()
  of xnkIteratorYield:
    if node.iteratorYieldValue.isSome:
      result["iteratorYieldValue"] = node.iteratorYieldValue.get.toJson()
  of xnkIteratorDelegate:
    result["iteratorDelegateExpr"] = node.iteratorDelegateExpr.toJson()
  of xnkBreakStmt, xnkContinueStmt:
    if node.label.isSome:
      result["label"] = %node.label.get
  of xnkThrowStmt:
    result["throwExpr"] = node.throwExpr.toJson()
  of xnkAssertStmt:
    result["assertCond"] = node.assertCond.toJson()
    if node.assertMsg.isSome:
      result["assertMsg"] = node.assertMsg.get.toJson()
  of xnkPassStmt, xnkEmptyStmt, xnkThisExpr, xnkBaseExpr, xnkNilLit, xnkNoneLit:
    discard  # No additional fields
  of xnkBinaryExpr:
    result["binaryLeft"] = node.binaryLeft.toJson()
    result["binaryOp"] = %($node.binaryOp)
    result["binaryRight"] = node.binaryRight.toJson()
  of xnkUnaryExpr:
    result["unaryOp"] = %($node.unaryOp)
    result["unaryOperand"] = node.unaryOperand.toJson()
  of xnkCallExpr:
    result["callee"] = node.callee.toJson()
    result["args"] = %node.args.mapIt(it.toJson())
  of xnkIndexExpr:
    result["indexExpr"] = node.indexExpr.toJson()
    result["indexArgs"] = %node.indexArgs.mapIt(it.toJson())
  of xnkSliceExpr:
    result["sliceExpr"] = node.sliceExpr.toJson()
    if node.sliceStart.isSome:
      result["sliceStart"] = node.sliceStart.get.toJson()
    if node.sliceEnd.isSome:
      result["sliceEnd"] = node.sliceEnd.get.toJson()
    if node.sliceStep.isSome:
      result["sliceStep"] = node.sliceStep.get.toJson()
  of xnkMemberAccessExpr:
    result["memberExpr"] = node.memberExpr.toJson()
    result["memberName"] = %node.memberName
    result["isEnumAccess"] = %node.isEnumAccess
    result["enumTypeName"] = %node.enumTypeName
    result["enumFullName"] = %node.enumFullName
  of xnkLambdaExpr:
    result["lambdaParams"] = %node.lambdaParams.mapIt(it.toJson())
    if node.lambdaReturnType.isSome:
      result["lambdaReturnType"] = node.lambdaReturnType.get.toJson()
    result["lambdaBody"] = node.lambdaBody.toJson()
  of xnkCastExpr:
    result["castExpr"] = node.castExpr.toJson()
    result["castType"] = node.castType.toJson()
  of xnkIntLit, xnkFloatLit, xnkStringLit, xnkCharLit:
    result["literalValue"] = %node.literalValue
  of xnkBoolLit:
    result["boolValue"] = %node.boolValue
  of xnkNamedType:
    result["typeName"] = %node.typeName
    if node.isEmptyMarkerType.isSome:
      result["isEmptyMarkerType"] = %node.isEmptyMarkerType.get
  of xnkArrayType:
    result["elementType"] = node.elementType.toJson()
    if node.arraySize.isSome:
      result["arraySize"] = node.arraySize.get.toJson()
  of xnkMapType:
    result["keyType"] = node.keyType.toJson()
    result["valueType"] = node.valueType.toJson()
  of xnkFuncType:
    result["funcParams"] = %node.funcParams.mapIt(it.toJson())
    if node.funcReturnType.isSome:
      result["funcReturnType"] = node.funcReturnType.get.toJson()
  of xnkPointerType, xnkReferenceType:
    result["referentType"] = node.referentType.toJson()
  of xnkGenericType:
    result["genericTypeName"] = %node.genericTypeName
    if node.genericBase.isSome:
      result["genericBase"] = node.genericBase.get.toJson()
    result["genericArgs"] = %node.genericArgs.mapIt(it.toJson())
  of xnkUnionType:
    result["unionTypes"] = %node.unionTypes.mapIt(it.toJson())
  of xnkTupleType:
    result["tupleTypeElements"] = %node.tupleTypeElements.mapIt(it.toJson())
  of xnkDistinctType:
    result["distinctBaseType"] = node.distinctBaseType.toJson()
  of xnkIdentifier:
    result["identName"] = %node.identName
  of xnkParameter:
    result["paramName"] = %node.paramName
    if node.paramType.isSome:
      result["paramType"] = node.paramType.get.toJson()
    if node.defaultValue.isSome:
      result["defaultValue"] = node.defaultValue.get.toJson()
  of xnkArgument:
    if node.argName.isSome:
      result["argName"] = %node.argName.get
    result["argValue"] = node.argValue.toJson()
  of xnkEnumMember:
    result["enumMemberName"] = %node.enumMemberName
    if node.enumMemberValue.isSome:
      result["enumMemberValue"] = node.enumMemberValue.get.toJson()
  of xnkSequenceLiteral, xnkSetLiteral, xnkArrayLiteral, xnkTupleExpr:
    result["elements"] = %node.elements.mapIt(it.toJson())
  of xnkMapLiteral:
    result["entries"] = %node.entries.mapIt(it.toJson())
  of xnkDictEntry:
    result["key"] = node.key.toJson()
    result["value"] = node.value.toJson()
  of xnkComment:
    result["commentText"] = %node.commentText
    result["isDocComment"] = %node.isDocComment
  of xnkImport:
    result["importPath"] = %node.importPath
    if node.importAlias.isSome:
      result["importAlias"] = %node.importAlias.get
  of xnkRaiseStmt:
    if node.raiseExpr.isSome:
      result["raiseExpr"] = node.raiseExpr.get.toJson()
  of xnkDiscardStmt:
    if node.discardExpr.isSome:
      result["discardExpr"] = node.discardExpr.get.toJson()
  of xnkLabeledStmt:
    result["labelName"] = %node.labelName
    result["labeledStmt"] = node.labeledStmt.toJson()
  of xnkGotoStmt:
    result["gotoLabel"] = %node.gotoLabel
  of xnkDeferStmt, xnkStaticStmt:
    result["staticBody"] = node.staticBody.toJson()
  of xnkInstanceVar, xnkClassVar, xnkGlobalVar:
    result["varName"] = %node.varName
  of xnkDefaultExpr:
    if node.defaultType.isSome:
      result["defaultType"] = node.defaultType.get.toJson()
  of xnkTypeOfExpr:
    result["typeOfType"] = node.typeOfType.toJson()
  of xnkSizeOfExpr:
    result["sizeOfType"] = node.sizeOfType.toJson()
  of xnkMethodReference:
    result["refObject"] = node.refObject.toJson()
    result["refMethod"] = %node.refMethod
  of xnkExternal_SafeNavigation:
    result["extSafeNavObject"] = node.extSafeNavObject.toJson()
    result["extSafeNavMember"] = %node.extSafeNavMember
  of xnkExternal_GoChanType:
    result["extChanElemType"] = node.extChanElemType.toJson()
    result["extChanDir"] = %node.extChanDir
  of xnkUnknown:
    result["unknownData"] = %node.unknownData
  else:
    # For any unhandled kinds, just output the kind
    discard

proc toJsonString*(node: XLangNode, pretty: bool = true): string =
  ## Convert XLangNode to JSON string
  let j = node.toJson()
  if pretty:
    j.pretty()
  else:
    $j
