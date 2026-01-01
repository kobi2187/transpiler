## Nim AST Node Positional Indices
##
## This module provides named constants for accessing child positions in MyNimNode.
## Instead of cryptic array indices like node[3], use descriptive names like node[ProcFormalParams].
##
## Based on Nim compiler's AST structure (compiler/ast.nim) and verified against
## our astprinter.nim usage patterns.
##
## Usage:
##   import nim_node_indices
##   procDef[ProcBody] = bodyNode  # instead of procDef[6] = bodyNode

# ==============================================================================
# Routine Definitions (nnkProcDef, nnkFuncDef, nnkMethodDef, nnkIteratorDef,
#                      nnkTemplateDef, nnkMacroDef, nnkConverterDef)
# ==============================================================================
#
# All routine definitions share the same 7-child structure:
#   [0] - name (identifier or postfix for export)
#   [1] - pattern (for term rewriting macros, usually empty)
#   [2] - generic parameters
#   [3] - formal parameters (return type + params)
#   [4] - pragmas
#   [5] - reserved (for future use, usually empty)
#   [6] - body (implementation)

const
  ProcName* = 0              ## Routine name (nnkIdent or nnkPostfix for export)
  ProcPattern* = 1           ## Term rewriting pattern (usually nnkEmpty)
  ProcGenericParams* = 2     ## Generic type parameters (nnkGenericParams or nnkEmpty)
  ProcFormalParams* = 3      ## Return type and parameters (nnkFormalParams)
  ProcPragmas* = 4           ## Pragmas like {.inline.} (nnkPragma or nnkEmpty)
  ProcReserved* = 5          ## Reserved for future use (always nnkEmpty)
  ProcBody* = 6              ## Procedure body implementation (nnkStmtList)

  # Aliases for clarity in different contexts
  FuncName* = ProcName
  FuncGenericParams* = ProcGenericParams
  FuncFormalParams* = ProcFormalParams
  FuncPragmas* = ProcPragmas
  FuncBody* = ProcBody

  MethodName* = ProcName
  MethodFormalParams* = ProcFormalParams
  MethodBody* = ProcBody

  IteratorName* = ProcName
  IteratorFormalParams* = ProcFormalParams
  IteratorBody* = ProcBody

  TemplateName* = ProcName
  TemplateFormalParams* = ProcFormalParams
  TemplateBody* = ProcBody

  MacroName* = ProcName
  MacroFormalParams* = ProcFormalParams
  MacroBody* = ProcBody

# ==============================================================================
# nnkFormalParams - Procedure parameters
# ==============================================================================
#
# Structure:
#   [0] - return type (nnkEmpty for void/no return)
#   [1..n] - parameter nnkIdentDefs nodes

const
  FormalParamsReturn* = 0    ## Return type (first child, nnkEmpty for void)
  # Remaining children [1..n] are nnkIdentDefs for each parameter

# ==============================================================================
# nnkIdentDefs - Identifier definitions (params, vars, lets, fields)
# ==============================================================================
#
# Used in: parameters, var/let/const declarations, object fields
# Structure:
#   [0..n-3] - one or more names
#   [n-2] - type (can be nnkEmpty for type inference)
#   [n-1] - default value/initializer (can be nnkEmpty)
#
# For single identifier (most common):
#   [0] - name
#   [1] - type
#   [2] - default/initializer

const
  IdentDefsName* = 0         ## Variable/parameter name (for single-name case)
  IdentDefsType* = 1         ## Type annotation (for single-name case)
  IdentDefsDefault* = 2      ## Default value or initializer (for single-name case)

# ==============================================================================
# nnkTypeDef - Type definition
# ==============================================================================
#
# Structure:
#   [0] - name (identifier or postfix for export)
#   [1] - generic parameters (nnkGenericParams or nnkEmpty)
#   [2] - type body (the actual type definition)

const
  TypeDefName* = 0           ## Type name
  TypeDefGenericParams* = 1  ## Generic type parameters
  TypeDefBody* = 2           ## Type body (object, enum, etc.)

# ==============================================================================
# nnkObjectTy - Object type definition
# ==============================================================================
#
# Structure:
#   [0] - base type (nnkOfInherit or nnkEmpty)
#   [1] - pragmas (usually nnkEmpty)
#   [2] - field list (nnkRecList)

const
  ObjectTyBase* = 0          ## Base type for inheritance
  ObjectTyPragmas* = 1       ## Object pragmas
  ObjectTyRecList* = 2       ## Record list (fields)

# ==============================================================================
# nnkConstDef - Const definition
# ==============================================================================
#
# Structure:
#   [0] - name
#   [1] - type (can be nnkEmpty)
#   [2] - value

const
  ConstDefName* = 0          ## Constant name
  ConstDefType* = 1          ## Type annotation (can be empty)
  ConstDefValue* = 2         ## Constant value

# ==============================================================================
# Control Flow - If/Elif/Else
# ==============================================================================
#
# nnkIfStmt contains branches (nnkElifBranch and optionally nnkElse)
# nnkElifBranch structure:
#   [0] - condition
#   [1] - body
# nnkElse structure:
#   [0] - body

const
  ElifCondition* = 0         ## Condition expression for if/elif
  ElifBody* = 1              ## Body statements for if/elif branch
  ElseBody* = 0              ## Body statements for else branch

# ==============================================================================
# Control Flow - While
# ==============================================================================
#
# nnkWhileStmt structure:
#   [0] - condition
#   [1] - body

const
  WhileCondition* = 0        ## Loop condition
  WhileBody* = 1             ## Loop body

# ==============================================================================
# Control Flow - For
# ==============================================================================
#
# nnkForStmt structure:
#   [0] - loop variable(s)
#   [1] - iterable expression
#   [2] - body

const
  ForVars* = 0               ## Loop variable(s)
  ForIterable* = 1           ## Expression to iterate over
  ForBody* = 2               ## Loop body

# ==============================================================================
# Control Flow - Case/Of
# ==============================================================================
#
# nnkCaseStmt structure:
#   [0] - selector expression
#   [1..n] - nnkOfBranch nodes, optionally ending with nnkElse
#
# nnkOfBranch structure:
#   [0..n-2] - match values
#   [n-1] - body

const
  CaseSelector* = 0          ## Case selector expression

# ==============================================================================
# Exception Handling
# ==============================================================================
#
# nnkTryStmt structure:
#   [0] - try body
#   [1..n] - nnkExceptBranch nodes, optionally ending with nnkFinally
#
# nnkExceptBranch structure:
#   [0..n-2] - exception types (can be empty for catch-all)
#   [n-1] - handler body
#
# nnkFinally structure:
#   [0] - finally body

const
  TryBody* = 0               ## Try block body
  ExceptHandler* = -1        ## Handler body (last child of except branch)
  FinallyBody* = 0           ## Finally block body
  DeferBody* = 0             ## Defer block body

# ==============================================================================
# Expressions - Binary and Unary
# ==============================================================================
#
# nnkInfix structure (binary operators):
#   [0] - operator
#   [1] - left operand
#   [2] - right operand
#
# nnkPrefix structure (unary operators):
#   [0] - operator
#   [1] - operand

const
  InfixOp* = 0               ## Infix operator
  InfixLeft* = 1             ## Left operand
  InfixRight* = 2            ## Right operand

  PrefixOp* = 0              ## Prefix operator
  PrefixOperand* = 1         ## Operand

  PostfixBase* = 0           ## Base expression for postfix
  PostfixOp* = 1             ## Postfix operator

# ==============================================================================
# Expressions - Calls and Indexing
# ==============================================================================
#
# nnkCall/nnkCommand structure:
#   [0] - callee (function being called)
#   [1..n] - arguments
#
# nnkBracketExpr structure (indexing):
#   [0] - base expression
#   [1..n] - index arguments
#
# nnkDotExpr structure (field access):
#   [0] - base object
#   [1] - field name

const
  CallCallee* = 0            ## Function being called
  # [1..n] are arguments

  BracketBase* = 0           ## Base expression for indexing
  # [1..n] are indices

  DotBase* = 0               ## Object for field access
  DotField* = 1              ## Field name

  ObjConstrType* = 0         ## Type name for object constructor
  # [1..n] are field assignments (nnkExprColonExpr)

# ==============================================================================
# Expressions - Type Conversions
# ==============================================================================
#
# nnkCast structure:
#   [0] - target type
#   [1] - expression to cast

const
  CastType* = 0              ## Target type for cast
  CastExpr* = 1              ## Expression being cast

# ==============================================================================
# Assignment
# ==============================================================================
#
# nnkAsgn structure:
#   [0] - left-hand side
#   [1] - right-hand side

const
  AsgnLeft* = 0              ## Assignment target
  AsgnRight* = 1             ## Assignment value

# ==============================================================================
# Other Common Patterns
# ==============================================================================
#
# nnkExprColonExpr (name: value pairs):
#   [0] - name
#   [1] - value
#
# nnkExprEqExpr (name = value in calls):
#   [0] - name
#   [1] - value
#
# nnkReturnStmt/nnkYieldStmt/nnkDiscardStmt:
#   [0] - expression (can be nnkEmpty)

const
  ColonExprName* = 0         ## Name in colon expression
  ColonExprValue* = 1        ## Value in colon expression

  EqExprName* = 0            ## Name in equals expression
  EqExprValue* = 1           ## Value in equals expression

  ReturnExpr* = 0            ## Return value expression
  YieldExpr* = 0             ## Yield value expression
  DiscardExpr* = 0           ## Discard expression

# ==============================================================================
# Lambda (nnkLambda)
# ==============================================================================
#
# nnkLambda shares the same structure as routines (7 children):
#   [0] - name (usually nnkEmpty for anonymous lambdas)
#   [1] - pattern (usually nnkEmpty)
#   [2] - generic parameters (usually nnkEmpty)
#   [3] - formal parameters
#   [4] - pragmas (usually nnkEmpty)
#   [5] - reserved (usually nnkEmpty)
#   [6] - body

const
  LambdaName* = 0            ## Lambda name (usually empty)
  LambdaPattern* = 1         ## Pattern (usually empty)
  LambdaGenericParams* = 2   ## Generic params (usually empty)
  LambdaFormalParams* = 3    ## Parameters and return type
  LambdaPragmas* = 4         ## Pragmas (usually empty)
  LambdaReserved* = 5        ## Reserved (usually empty)
  LambdaBody* = 6            ## Lambda body

# ==============================================================================
# Control Flow - Block
# ==============================================================================
#
# nnkBlockStmt structure:
#   [0] - block label (can be nnkEmpty for unlabeled block)
#   [1] - block body

const
  BlockLabel* = 0            ## Block statement label (nnkEmpty if unlabeled)
  BlockBody* = 1             ## Block body statements

# ==============================================================================
# Control Flow - Break/Continue/Raise
# ==============================================================================
#
# nnkBreakStmt structure:
#   [0] - break label (can be nnkEmpty for unlabeled break)
#
# nnkRaiseStmt structure:
#   [0] - exception expression (can be nnkEmpty for re-raise)

const
  BreakLabel* = 0            ## Break statement label (nnkEmpty if unlabeled)
  RaiseExpr* = 0             ## Exception expression to raise

# ==============================================================================
# Type Wrappers (nnkRefTy, nnkPtrTy, nnkVarTy, nnkDistinctTy)
# ==============================================================================
#
# All type wrapper nodes have a single child:
#   [0] - the wrapped type

const
  RefTypeWrapped* = 0        ## Wrapped type in ref T
  PtrTypeWrapped* = 0        ## Wrapped type in ptr T
  VarTypeWrapped* = 0        ## Wrapped type in var T
  DistinctTypeWrapped* = 0   ## Wrapped type in distinct T

  # Generic alias for all type wrappers
  TypeWrapperChild* = 0      ## The wrapped type (works for ref/ptr/var/distinct)

# ==============================================================================
# nnkEnumFieldDef - Enum field with optional value
# ==============================================================================
#
# Structure:
#   [0] - field name
#   [1] - field value (can be nnkEmpty for auto-incremented)

const
  EnumFieldName* = 0         ## Enum field name
  EnumFieldValue* = 1        ## Enum field value (nnkEmpty for auto)

# ==============================================================================
# nnkProcTy - Procedure type
# ==============================================================================
#
# Structure:
#   [0] - formal parameters (nnkFormalParams)
#   [1] - pragmas (usually nnkEmpty)

const
  ProcTyParams* = 0          ## Formal parameters for proc type
  ProcTyPragmas* = 1         ## Pragmas for proc type (usually empty)

# ==============================================================================
# nnkFromStmt - From import statement
# ==============================================================================
#
# Structure:
#   [0] - module name
#   [1..n] - imported symbols

const
  FromModule* = 0            ## Module name in 'from module import ...'
  # [1..n] are the imported symbols

# ==============================================================================
# nnkPragmaExpr - Expression with pragma
# ==============================================================================
#
# Structure:
#   [0] - base expression
#   [1] - pragma

const
  PragmaExprBase* = 0        ## Base expression
  PragmaExprPragma* = 1      ## Pragma annotation

# ==============================================================================
# nnkCommentStmt - Comment node
# ==============================================================================
#
# Structure:
#   [0] - comment text (as nnkStrLit)

const
  CommentText* = 0           ## Comment text node


