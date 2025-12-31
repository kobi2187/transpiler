## Nim Language Constants
##
## Constants specific to the Nim programming language,
## including keywords and reserved identifiers.

const NimKeywords* = @[
  # Reserved words
  "addr", "and", "as", "asm", "bind", "block", "break", "case", "cast",
  "concept", "const", "continue", "converter", "defer", "discard", "distinct",
  "div", "do", "elif", "else", "end", "enum", "except", "export", "finally",
  "for", "from", "func", "if", "import", "in", "include", "interface",
  "is", "isnot", "iterator", "let", "macro", "method", "mixin", "mod",
  "nil", "not", "notin", "object", "of", "or", "out", "proc", "ptr",
  "raise", "ref", "return", "shl", "shr", "static", "template", "try",
  "tuple", "type", "using", "var", "when", "while", "xor", "yield",
  # Common builtins/identifiers to avoid
  "result", "self", "this", "true", "false", "echo", "quit", "assert"
]
