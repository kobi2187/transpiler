## XLang Lexer
## Tokenizes xlang source text into tokens for the parser.
## Uses std/pegs for pattern matching.

import std/[pegs, strutils, options]

type
  TokenKind* = enum
    # Structure
    tkNewline, tkIndent, tkDedent, tkEOF

    # Keywords - declarations
    tkModule, tkNamespace, tkFunc, tkMethod, tkIterator
    tkClass, tkStruct, tkInterface, tkEnum, tkType, tkAlias
    tkVar, tkLet, tkConst, tkField
    tkCtor, tkDtor
    tkAsync, tkStatic
    tkTemplate, tkMacro, tkConcept
    tkLib, tkCfunc, tkExtern
    tkAbstract, tkDistinct

    # Keywords - statements
    tkIf, tkElif, tkElse, tkMatch, tkCase, tkWhile, tkDo
    tkForeach, tkFor, tkIn, tkTry, tkCatch, tkFinally
    tkReturn, tkYield, tkYieldFrom, tkBreak, tkContinue
    tkThrow, tkRaise, tkAssert, tkPass, tkDiscard
    tkDefer, tkUsing, tkWith, tkUnless, tkUntil
    tkGoto, tkFallthrough
    tkImport, tkFrom, tkExport, tkInclude, tkExtend
    tkGo, tkSelect  # Go-specific

    # Keywords - expressions
    tkLambda, tkProc, tkSelf, tkBase, tkNil, tkNone
    tkTrue, tkFalse, tkDefault, tkTypeof, tkSizeof
    tkCast, tkRef, tkPtr, tkChan, tkAwait
    tkChecked, tkUnchecked, tkUnsafe, tkLock, tkFixed

    # Keywords - type modifiers
    tkArray, tkMap, tkSet, tkDistinctKw

    # Operators
    tkPlus, tkMinus, tkStar, tkSlash, tkPercent
    tkStarStar, tkSlashSlash  # ** //
    tkAmpersand, tkPipe, tkCaret, tkTilde
    tkAmpCaret  # &^ (Go bit clear)
    tkShl, tkShr, tkShru  # shl shr shru
    tkEq, tkNeq, tkLt, tkLe, tkGt, tkGe
    tkIs, tkIsnot, tkIstype, tkAs, tkNotin
    tkAnd, tkOr, tkNot
    tkDotDot, tkArrow, tkFatArrow  # .. -> =>
    tkQQ, tkQColon  # ?? ?:
    tkQDot  # ?.
    tkPlusPlus, tkMinusMinus  # ++ --
    tkChanRecv  # <- (channel receive)
    tkColonColon  # ::

    # Compound assignment
    tkPlusEq, tkMinusEq, tkStarEq, tkSlashEq, tkPercentEq
    tkAmpEq, tkPipeEq, tkCaretEq
    tkShlEq, tkShrEq, tkShruEq

    # Delimiters
    tkLParen, tkRParen, tkLBracket, tkRBracket
    tkLBrace, tkRBrace
    tkComma, tkColon, tkSemicolon, tkDot
    tkAt, tkHash, tkDollar, tkBacktick
    tkEqSign  # = (assignment)
    tkFieldLabel  # | (for field annotations)

    # Literals
    tkIntLit, tkFloatLit, tkStringLit, tkCharLit
    tkRawStringLit, tkMultilineStringLit

    # Identifiers
    tkIdent

    # Special
    tkComment, tkDocComment
    tkUnknown

  Token* = object
    kind*: TokenKind
    value*: string
    line*: int
    col*: int
    indent*: int  # Indentation level (in spaces)

  Lexer* = ref object
    source*: string
    pos*: int
    line*: int
    col*: int
    indentStack*: seq[int]
    pendingDedents*: int
    atLineStart*: bool
    tokens*: seq[Token]  # For lookahead

const
  Keywords = {
    # Declarations
    "module": tkModule, "namespace": tkNamespace,
    "func": tkFunc, "method": tkMethod, "iterator": tkIterator,
    "class": tkClass, "struct": tkStruct, "interface": tkInterface,
    "enum": tkEnum, "type": tkType, "alias": tkAlias,
    "var": tkVar, "let": tkLet, "const": tkConst,
    "ctor": tkCtor, "dtor": tkDtor,
    "async": tkAsync, "static": tkStatic,
    "template": tkTemplate, "macro": tkMacro, "concept": tkConcept,
    "lib": tkLib, "cfunc": tkCfunc, "extern": tkExtern,
    "abstract": tkAbstract, "distinct": tkDistinct,

    # Statements
    "if": tkIf, "elif": tkElif, "else": tkElse,
    "match": tkMatch, "case": tkCase,
    "while": tkWhile, "do": tkDo,
    "foreach": tkForeach, "for": tkFor, "in": tkIn,
    "try": tkTry, "catch": tkCatch, "finally": tkFinally,
    "return": tkReturn, "yield": tkYield,
    "break": tkBreak, "continue": tkContinue,
    "throw": tkThrow, "raise": tkRaise,
    "assert": tkAssert, "pass": tkPass, "discard": tkDiscard,
    "defer": tkDefer, "using": tkUsing, "with": tkWith,
    "unless": tkUnless, "until": tkUntil,
    "goto": tkGoto, "fallthrough": tkFallthrough,
    "import": tkImport, "from": tkFrom, "export": tkExport,
    "include": tkInclude, "extend": tkExtend,
    "go": tkGo, "select": tkSelect,

    # Expressions
    "lambda": tkLambda, "proc": tkProc,
    "self": tkSelf, "base": tkBase,
    "nil": tkNil, "None": tkNone,
    "true": tkTrue, "false": tkFalse,
    "default": tkDefault, "typeof": tkTypeof, "sizeof": tkSizeof,
    "cast": tkCast, "ref": tkRef, "ptr": tkPtr, "chan": tkChan,
    "await": tkAwait,
    "checked": tkChecked, "unchecked": tkUnchecked,
    "unsafe": tkUnsafe, "lock": tkLock, "fixed": tkFixed,

    # Type modifiers
    "array": tkArray, "Map": tkMap,

    # Operators as keywords
    "shl": tkShl, "shr": tkShr, "shru": tkShru,
    "and": tkAnd, "or": tkOr, "not": tkNot,
    "is": tkIs, "isnot": tkIsnot, "istype": tkIstype,
    "as": tkAs, "notin": tkNotin,
  }.toTable

proc newLexer*(source: string): Lexer =
  result = Lexer(
    source: source,
    pos: 0,
    line: 1,
    col: 1,
    indentStack: @[0],
    pendingDedents: 0,
    atLineStart: true,
    tokens: @[]
  )

proc peek(lex: Lexer, offset: int = 0): char =
  let idx = lex.pos + offset
  if idx < lex.source.len:
    lex.source[idx]
  else:
    '\0'

proc advance(lex: Lexer): char =
  result = lex.peek()
  inc lex.pos
  if result == '\n':
    inc lex.line
    lex.col = 1
    lex.atLineStart = true
  else:
    inc lex.col

proc skipWhitespace(lex: Lexer) =
  ## Skip spaces and tabs (not newlines)
  while lex.peek() in {' ', '\t'} and not lex.atLineStart:
    discard lex.advance()

proc measureIndent(lex: Lexer): int =
  ## Measure leading spaces at current position
  result = 0
  var i = lex.pos
  while i < lex.source.len and lex.source[i] == ' ':
    inc result
    inc i

proc makeToken(lex: Lexer, kind: TokenKind, value: string = ""): Token =
  Token(
    kind: kind,
    value: value,
    line: lex.line,
    col: lex.col,
    indent: if lex.indentStack.len > 0: lex.indentStack[^1] else: 0
  )

proc scanString(lex: Lexer, quote: char): Token =
  let startLine = lex.line
  let startCol = lex.col
  discard lex.advance()  # consume opening quote

  var value = ""
  var isMultiline = false

  # Check for triple quote
  if lex.peek() == quote and lex.peek(1) == quote:
    discard lex.advance()
    discard lex.advance()
    isMultiline = true

  while lex.peek() != '\0':
    let c = lex.peek()

    if isMultiline:
      if c == quote and lex.peek(1) == quote and lex.peek(2) == quote:
        discard lex.advance()
        discard lex.advance()
        discard lex.advance()
        return Token(
          kind: tkMultilineStringLit,
          value: value,
          line: startLine,
          col: startCol,
          indent: lex.indentStack[^1]
        )
      value.add(lex.advance())
    else:
      if c == quote:
        discard lex.advance()
        let kind = if quote == '"': tkStringLit else: tkCharLit
        return Token(kind: kind, value: value, line: startLine, col: startCol, indent: lex.indentStack[^1])
      elif c == '\\':
        discard lex.advance()
        let escaped = lex.advance()
        case escaped
        of 'n': value.add('\n')
        of 't': value.add('\t')
        of 'r': value.add('\r')
        of '\\': value.add('\\')
        of '"': value.add('"')
        of '\'': value.add('\'')
        of '0': value.add('\0')
        else: value.add(escaped)
      elif c == '\n':
        break  # Unterminated string
      else:
        value.add(lex.advance())

  # Unterminated string
  Token(kind: tkUnknown, value: value, line: startLine, col: startCol, indent: lex.indentStack[^1])

proc scanNumber(lex: Lexer): Token =
  let startCol = lex.col
  var value = ""
  var isFloat = false

  # Handle hex, binary, octal
  if lex.peek() == '0' and lex.peek(1) in {'x', 'X', 'b', 'B', 'o', 'O'}:
    value.add(lex.advance())
    value.add(lex.advance())
    while lex.peek() in HexDigits + {'_'}:
      if lex.peek() != '_':
        value.add(lex.advance())
      else:
        discard lex.advance()
    return Token(kind: tkIntLit, value: value, line: lex.line, col: startCol, indent: lex.indentStack[^1])

  # Regular number
  while lex.peek() in Digits + {'_'}:
    if lex.peek() != '_':
      value.add(lex.advance())
    else:
      discard lex.advance()

  # Check for decimal point
  if lex.peek() == '.' and lex.peek(1) in Digits:
    isFloat = true
    value.add(lex.advance())  # .
    while lex.peek() in Digits + {'_'}:
      if lex.peek() != '_':
        value.add(lex.advance())
      else:
        discard lex.advance()

  # Check for exponent
  if lex.peek() in {'e', 'E'}:
    isFloat = true
    value.add(lex.advance())
    if lex.peek() in {'+', '-'}:
      value.add(lex.advance())
    while lex.peek() in Digits:
      value.add(lex.advance())

  # Check for type suffix
  if lex.peek() in {'f', 'F', 'd', 'D', 'i', 'I', 'u', 'U', 'l', 'L'}:
    value.add(lex.advance())
    while lex.peek() in Digits + IdentChars:
      value.add(lex.advance())

  let kind = if isFloat: tkFloatLit else: tkIntLit
  Token(kind: kind, value: value, line: lex.line, col: startCol, indent: lex.indentStack[^1])

proc scanIdent(lex: Lexer): Token =
  let startCol = lex.col
  var value = ""

  while lex.peek() in IdentStartChars + Digits + {'_'}:
    value.add(lex.advance())

  # Check for keywords
  if value in Keywords:
    return Token(kind: Keywords[value], value: value, line: lex.line, col: startCol, indent: lex.indentStack[^1])

  Token(kind: tkIdent, value: value, line: lex.line, col: startCol, indent: lex.indentStack[^1])

proc scanComment(lex: Lexer): Token =
  let startCol = lex.col
  discard lex.advance()  # consume #

  var isDoc = false
  if lex.peek() == '#':
    isDoc = true
    discard lex.advance()

  # Check for pragma #[...]
  if lex.peek() == '[':
    discard lex.advance()
    var value = ""
    var depth = 1
    while lex.peek() != '\0' and depth > 0:
      if lex.peek() == '[':
        inc depth
      elif lex.peek() == ']':
        dec depth
        if depth == 0:
          discard lex.advance()
          break
      value.add(lex.advance())
    return Token(kind: tkHash, value: value, line: lex.line, col: startCol, indent: lex.indentStack[^1])

  var value = ""
  while lex.peek() != '\0' and lex.peek() != '\n':
    value.add(lex.advance())

  let kind = if isDoc: tkDocComment else: tkComment
  Token(kind: kind, value: value.strip(), line: lex.line, col: startCol, indent: lex.indentStack[^1])

proc nextToken*(lex: Lexer): Token =
  # Return pending dedents first
  if lex.pendingDedents > 0:
    dec lex.pendingDedents
    return lex.makeToken(tkDedent)

  # Handle indentation at line start
  if lex.atLineStart:
    lex.atLineStart = false
    let indent = lex.measureIndent()

    # Skip blank lines
    var tempPos = lex.pos + indent
    while tempPos < lex.source.len and lex.source[tempPos] in {'\n', '\r'}:
      lex.pos = tempPos
      discard lex.advance()  # consume newline
      lex.atLineStart = false
      let newIndent = lex.measureIndent()
      tempPos = lex.pos + newIndent

    # Skip comment-only lines for indent calculation
    if lex.pos + indent < lex.source.len and lex.source[lex.pos + indent] == '#':
      # It's a comment line - process normally without changing indent
      lex.pos += indent
      lex.col += indent
    else:
      let currentIndent = if lex.indentStack.len > 0: lex.indentStack[^1] else: 0

      if indent > currentIndent:
        lex.indentStack.add(indent)
        lex.pos += indent
        lex.col += indent
        return lex.makeToken(tkIndent)
      elif indent < currentIndent:
        while lex.indentStack.len > 1 and lex.indentStack[^1] > indent:
          discard lex.indentStack.pop()
          inc lex.pendingDedents
        lex.pos += indent
        lex.col += indent
        if lex.pendingDedents > 0:
          dec lex.pendingDedents
          return lex.makeToken(tkDedent)
      else:
        lex.pos += indent
        lex.col += indent

  lex.skipWhitespace()

  if lex.pos >= lex.source.len:
    # Emit remaining dedents at EOF
    if lex.indentStack.len > 1:
      discard lex.indentStack.pop()
      return lex.makeToken(tkDedent)
    return lex.makeToken(tkEOF)

  let c = lex.peek()

  # Newline
  if c == '\n':
    discard lex.advance()
    return lex.makeToken(tkNewline)
  if c == '\r':
    discard lex.advance()
    if lex.peek() == '\n':
      discard lex.advance()
    return lex.makeToken(tkNewline)

  # String literals
  if c == '"' or c == '\'':
    return lex.scanString(c)

  # Raw string
  if c == 'r' and lex.peek(1) == '"':
    discard lex.advance()
    var tok = lex.scanString('"')
    tok.kind = tkRawStringLit
    return tok

  # Numbers
  if c in Digits:
    return lex.scanNumber()

  # Identifiers and keywords
  if c in IdentStartChars:
    return lex.scanIdent()

  # Comments
  if c == '#':
    return lex.scanComment()

  # Multi-character operators
  let c2 = lex.peek(1)
  let c3 = lex.peek(2)

  # Three-char operators
  if c == '>' and c2 == '>' and c3 == '=':
    discard lex.advance(); discard lex.advance(); discard lex.advance()
    return lex.makeToken(tkShrEq, ">>=")
  if c == '>' and c2 == '>' and c3 == '>':
    discard lex.advance(); discard lex.advance(); discard lex.advance()
    if lex.peek() == '=':
      discard lex.advance()
      return lex.makeToken(tkShruEq, ">>>=")
    return lex.makeToken(tkShru, ">>>")
  if c == '<' and c2 == '<' and c3 == '=':
    discard lex.advance(); discard lex.advance(); discard lex.advance()
    return lex.makeToken(tkShlEq, "<<=")
  if c == '.' and c2 == '.' and c3 == '.':
    discard lex.advance(); discard lex.advance(); discard lex.advance()
    return lex.makeToken(tkIdent, "...")  # spread operator

  # Two-char operators
  case c
  of '+':
    discard lex.advance()
    if lex.peek() == '+':
      discard lex.advance()
      return lex.makeToken(tkPlusPlus, "++")
    if lex.peek() == '=':
      discard lex.advance()
      return lex.makeToken(tkPlusEq, "+=")
    return lex.makeToken(tkPlus, "+")
  of '-':
    discard lex.advance()
    if lex.peek() == '-':
      discard lex.advance()
      return lex.makeToken(tkMinusMinus, "--")
    if lex.peek() == '=':
      discard lex.advance()
      return lex.makeToken(tkMinusEq, "-=")
    if lex.peek() == '>':
      discard lex.advance()
      return lex.makeToken(tkArrow, "->")
    return lex.makeToken(tkMinus, "-")
  of '*':
    discard lex.advance()
    if lex.peek() == '*':
      discard lex.advance()
      return lex.makeToken(tkStarStar, "**")
    if lex.peek() == '=':
      discard lex.advance()
      return lex.makeToken(tkStarEq, "*=")
    return lex.makeToken(tkStar, "*")
  of '/':
    discard lex.advance()
    if lex.peek() == '/':
      discard lex.advance()
      return lex.makeToken(tkSlashSlash, "//")
    if lex.peek() == '=':
      discard lex.advance()
      return lex.makeToken(tkSlashEq, "/=")
    return lex.makeToken(tkSlash, "/")
  of '%':
    discard lex.advance()
    if lex.peek() == '=':
      discard lex.advance()
      return lex.makeToken(tkPercentEq, "%=")
    return lex.makeToken(tkPercent, "%")
  of '&':
    discard lex.advance()
    if lex.peek() == '^':
      discard lex.advance()
      return lex.makeToken(tkAmpCaret, "&^")
    if lex.peek() == '=':
      discard lex.advance()
      return lex.makeToken(tkAmpEq, "&=")
    return lex.makeToken(tkAmpersand, "&")
  of '|':
    discard lex.advance()
    if lex.peek() == '=':
      discard lex.advance()
      return lex.makeToken(tkPipeEq, "|=")
    return lex.makeToken(tkPipe, "|")
  of '^':
    discard lex.advance()
    if lex.peek() == '=':
      discard lex.advance()
      return lex.makeToken(tkCaretEq, "^=")
    return lex.makeToken(tkCaret, "^")
  of '=':
    discard lex.advance()
    if lex.peek() == '=':
      discard lex.advance()
      return lex.makeToken(tkEq, "==")
    if lex.peek() == '>':
      discard lex.advance()
      return lex.makeToken(tkFatArrow, "=>")
    return lex.makeToken(tkEqSign, "=")
  of '!':
    discard lex.advance()
    if lex.peek() == '=':
      discard lex.advance()
      return lex.makeToken(tkNeq, "!=")
    return lex.makeToken(tkNot, "!")
  of '<':
    discard lex.advance()
    if lex.peek() == '=':
      discard lex.advance()
      return lex.makeToken(tkLe, "<=")
    if lex.peek() == '<':
      discard lex.advance()
      if lex.peek() == '=':
        discard lex.advance()
        return lex.makeToken(tkShlEq, "<<=")
      return lex.makeToken(tkShl, "<<")
    if lex.peek() == '-':
      discard lex.advance()
      return lex.makeToken(tkChanRecv, "<-")
    return lex.makeToken(tkLt, "<")
  of '>':
    discard lex.advance()
    if lex.peek() == '=':
      discard lex.advance()
      return lex.makeToken(tkGe, ">=")
    if lex.peek() == '>':
      discard lex.advance()
      if lex.peek() == '=':
        discard lex.advance()
        return lex.makeToken(tkShrEq, ">>=")
      if lex.peek() == '>':
        discard lex.advance()
        return lex.makeToken(tkShru, ">>>")
      return lex.makeToken(tkShr, ">>")
    return lex.makeToken(tkGt, ">")
  of '?':
    discard lex.advance()
    if lex.peek() == '?':
      discard lex.advance()
      return lex.makeToken(tkQQ, "??")
    if lex.peek() == ':':
      discard lex.advance()
      return lex.makeToken(tkQColon, "?:")
    if lex.peek() == '.':
      discard lex.advance()
      return lex.makeToken(tkQDot, "?.")
    return lex.makeToken(tkUnknown, "?")
  of '.':
    discard lex.advance()
    if lex.peek() == '.':
      discard lex.advance()
      return lex.makeToken(tkDotDot, "..")
    return lex.makeToken(tkDot, ".")
  of ':':
    discard lex.advance()
    if lex.peek() == ':':
      discard lex.advance()
      return lex.makeToken(tkColonColon, "::")
    return lex.makeToken(tkColon, ":")
  of '~':
    discard lex.advance()
    return lex.makeToken(tkTilde, "~")
  of '(':
    discard lex.advance()
    return lex.makeToken(tkLParen, "(")
  of ')':
    discard lex.advance()
    return lex.makeToken(tkRParen, ")")
  of '[':
    discard lex.advance()
    return lex.makeToken(tkLBracket, "[")
  of ']':
    discard lex.advance()
    return lex.makeToken(tkRBracket, "]")
  of '{':
    discard lex.advance()
    return lex.makeToken(tkLBrace, "{")
  of '}':
    discard lex.advance()
    return lex.makeToken(tkRBrace, "}")
  of ',':
    discard lex.advance()
    return lex.makeToken(tkComma, ",")
  of ';':
    discard lex.advance()
    return lex.makeToken(tkSemicolon, ";")
  of '@':
    discard lex.advance()
    return lex.makeToken(tkAt, "@")
  of '$':
    discard lex.advance()
    return lex.makeToken(tkDollar, "$")
  of '`':
    discard lex.advance()
    return lex.makeToken(tkBacktick, "`")
  else:
    discard lex.advance()
    return lex.makeToken(tkUnknown, $c)

proc tokenize*(source: string): seq[Token] =
  ## Tokenize entire source into a sequence of tokens
  var lex = newLexer(source)
  result = @[]
  while true:
    let tok = lex.nextToken()
    result.add(tok)
    if tok.kind == tkEOF:
      break

proc `$`*(tok: Token): string =
  result = $tok.kind
  if tok.value.len > 0:
    result &= "(" & tok.value & ")"
  result &= " @" & $tok.line & ":" & $tok.col
