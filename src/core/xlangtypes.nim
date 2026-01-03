import options
import uuid4
# import strutils

# type
#   XLangVersion = tuple[major, minor, patch: int]

# const SUPPORTED_XLANG_VERSION: XLangVersion = (1, 0, 0)
# proc parseVersion(v: string): XLangVersion =
#   let parts: seq[string] = v.split(".")
#   if parts.len != 3:
#     raise newException(ValueError, "Invalid version string")
#   result = (parseInt(parts[0]), parseInt(parts[1]), parseInt(parts[2]))

# proc isVersionCompatible(ast_version, supported_version: XLangVersion): bool =
#   if ast_version.major != supported_version.major:
#     return false
#   if ast_version.major == supported_version.major and ast_version.minor > supported_version.minor:
#     return false
#   return true

# ==============================================================================
# SEMANTIC OPERATORS
# ==============================================================================
# Operators are represented semantically, not syntactically.
# Each source language parser maps its syntax to these semantic operators.
# Each target language converter maps these semantic operators to its syntax.
#
# Examples:
#   C# "<<" → opShiftLeft → Nim "shl"
#   C# "&&" → opLogicalAnd → Nim "and"
#   Python "**" → opPow → Nim "^" (or call to pow)
# ==============================================================================

type
  BinaryOp* = enum
    # Arithmetic operators
    opAdd = "add"              # + (addition)
    opSub = "sub"              # - (subtraction)
    opMul = "mul"              # * (multiplication)
    opDiv = "div"              # / (division)
    opMod = "mod"              # % (modulo/remainder)
    opPow = "pow"              # ** or ^ (exponentiation)
    opIntDiv = "intdiv"        # // (integer division, Python/Nim)

    # Bitwise operators
    opBitAnd = "bitand"        # & (bitwise AND)
    opBitOr = "bitor"          # | (bitwise OR)
    opBitXor = "bitxor"        # ^ (bitwise XOR)
    opShiftLeft = "shl"        # << (left shift)
    opShiftRight = "shr"       # >> (right shift)
    opShiftRightUnsigned = "shru"  # >>> (unsigned right shift, Java/JavaScript)

    # Comparison operators
    opEqual = "eq"             # == (equality)
    opNotEqual = "neq"         # != (inequality)
    opLess = "lt"              # < (less than)
    opLessEqual = "le"         # <= (less than or equal)
    opGreater = "gt"           # > (greater than)
    opGreaterEqual = "ge"      # >= (greater than or equal)
    opIdentical = "is"         # === (reference equality, JavaScript) or is (Python/Nim)
    opNotIdentical = "isnot"   # !== (reference inequality)

    # Logical operators
    opLogicalAnd = "and"       # && or and (logical AND)
    opLogicalOr = "or"         # || or or (logical OR)

    # Assignment operators (compound)
    opAddAssign = "adda"       # +=
    opSubAssign = "suba"       # -=
    opMulAssign = "mula"       # *=
    opDivAssign = "diva"       # /=
    opModAssign = "moda"       # %=
    opBitAndAssign = "bitanda" # &=
    opBitOrAssign = "bitora"   # |=
    opBitXorAssign = "bitxora" # ^=
    opShiftLeftAssign = "shla" # <<=
    opShiftRightAssign = "shra"# >>=
    opShiftRightUnsignedAssign = "shrua" # >>>=

    # Special operators
    opNullCoalesce = "nullcoalesce"  # ?? (C#/JavaScript)
    opElvis = "elvis"                # ?: (Kotlin/Groovy)
    opRange = "range"                # .. (range operator)
    opIn = "in"                      # in (membership test)
    opNotIn = "notin"                # not in
    opIs = "istype"                  # is (type check)
    opAs = "as"                      # as (type cast)
    opConcat = "concat"              # string concatenation (when different from +)

  UnaryOp* = enum
    # Arithmetic
    opNegate = "neg"           # - (negation)
    opUnaryPlus = "pos"        # + (unary plus)

    # Logical
    opNot = "not"              # ! or not (logical NOT)

    # Bitwise
    opBitNot = "bitnot"        # ~ (bitwise NOT/complement)

    # Increment/Decrement
    opPreIncrement = "preinc"  # ++x (pre-increment)
    opPostIncrement = "postinc"# x++ (post-increment)
    opPreDecrement = "predec"  # --x (pre-decrement)
    opPostDecrement = "postdec"# x-- (post-decrement)

    # Pointer/Reference operations
    opAddressOf = "addrof"     # & (address-of)
    opDereference = "deref"    # * (dereference)

    # Async
    opAwait = "await"          # await (async/await)

    # Spread/Splat
    opSpread = "spread"        # ... (spread operator, JavaScript/Python)

type
  XLangNodeKind* = enum
    # xnkNone
    # Basic structure
    xnkFile, xnkModule, xnkNamespace

    # Declarations
    xnkFuncDecl, xnkMethodDecl, xnkIteratorDecl, xnkClassDecl, xnkStructDecl, xnkInterfaceDecl
    xnkEnumDecl, xnkVarDecl, xnkConstDecl, xnkTypeDecl, xnkLetDecl
    xnkFieldDecl, xnkConstructorDecl, xnkDestructorDecl, 
    xnkModuleDecl, xnkTypeAlias, xnkAbstractDecl, xnkEnumMember,
    
    xnkAbstractType, xnkFunctionType, xnkMetadata,
    # C FFI and external declarations
    xnkLibDecl, xnkCFuncDecl, xnkExternalVar

    # Statements
    xnkAsgn, xnkBlockStmt, xnkIfStmt, xnkSwitchStmt, xnkCaseClause, xnkDefaultClause, xnkWhileStmt
    xnkDoWhileStmt, xnkForeachStmt, xnkTryStmt, xnkCatchStmt, xnkFinallyStmt
    xnkReturnStmt, xnkIteratorYield, xnkIteratorDelegate, xnkBreakStmt, xnkContinueStmt
    # Legacy (deprecated - unified into iterator nodes):
    xnkYieldStmt, xnkYieldExpr, xnkYieldFromStmt
    xnkThrowStmt, xnkAssertStmt, xnkPassStmt, xnkTypeSwitchStmt,
    xnkResourceItem,  # Unified resource management (with/using)
    xnkDiscardStmt, xnkCaseStmt, xnkRaiseStmt, xnkImportStmt, xnkExportStmt, xnkFromImportStmt, xnkTypeCaseClause, xnkWithItem,
    xnkEmptyStmt, xnkLabeledStmt, xnkGotoStmt,  xnkUnlessStmt, xnkUntilStmt, xnkStaticAssert, xnkSwitchCase, xnkMixinDecl, xnkTemplateDecl, xnkMacroDecl, xnkInclude, xnkExtend
    # Expressions
    xnkBinaryExpr, xnkUnaryExpr, xnkCallExpr, xnkThisCall, xnkBaseCall, xnkIndexExpr,
     xnkSliceExpr, xnkMemberAccessExpr,
      xnkLambdaExpr, xnkTypeAssertion, xnkCastExpr, xnkThisExpr, xnkBaseExpr, xnkRefExpr, xnkInstanceVar, xnkClassVar, xnkGlobalVar, xnkProcLiteral, xnkProcPointer, xnkNumberLit, xnkSymbolLit, xnkDynamicType,
      xnkDotExpr, xnkBracketExpr, xnkCompFor,
      xnkDefaultExpr, xnkTypeOfExpr, xnkSizeOfExpr, xnkCheckedExpr,   xnkImplicitArrayCreation
    # Literals
    xnkIntLit, xnkFloatLit, xnkStringLit, xnkCharLit, xnkBoolLit, xnkNoneLit, xnkNilLit

    # Types
    xnkNamedType, xnkArrayType, xnkMapType, xnkFuncType, xnkPointerType
    xnkReferenceType, xnkGenericType, xnkUnionType, xnkIntersectionType, xnkDistinctType

    # Other
    xnkIdentifier, xnkComment, xnkImport, xnkExport, xnkAttribute
    xnkGenericParameter, xnkParameter, xnkArgument, xnkDecorator, xnkLambdaProc, xnkArrowFunc, xnkConceptRequirement,
    xnkQualifiedName, xnkAliasQualifiedName, xnkGenericName,
    xnkUnknown  # Fallback for unhandled constructs
    # Comments

    xnkTemplateDef, xnkMacroDef, xnkPragma, xnkStaticStmt, xnkDeferStmt,
    xnkAsmStmt, xnkDistinctTypeDef, xnkConceptDef, xnkMixinStmt, xnkConceptDecl,
    xnkBindStmt, xnkTupleConstr, xnkTupleUnpacking, xnkUsingStmt,
    xnkDestructureObj, xnkDestructureArray

    xnkMethodReference
    # Collection literals (renamed for clarity and consistency):
    xnkSequenceLiteral, xnkSetLiteral, xnkMapLiteral, xnkArrayLiteral, xnkTupleExpr,  xnkDictEntry
    # Legacy (deprecated - renamed to *Literal):
    xnkListExpr, xnkSetExpr, xnkDictExpr, xnkArrayLit

    # ==========================================================================
    # External/Source-Specific Kinds (xnkExternal_*)
    # ==========================================================================
    # These are language-specific constructs that have no direct equivalent in the
    # target language and MUST be lowered by transformation passes. The pass manager
    # tracks only these kinds for elimination during fixed-point iteration.
    #
    # Naming: xnkExternal_<FeatureName>
    # After lowering, these should be replaced with common kinds.
    # ==========================================================================

    # C# specific declarations
    xnkExternal_Property        # C# property with getter/setter → lowered to procs
    xnkExternal_Indexer         # C# indexer this[...] → lowered to [] procs
    xnkExternal_Event           # C# event with add/remove → lowered to procs
    xnkExternal_Delegate        # C# delegate type → lowered to proc type
    xnkExternal_Operator        # C# operator overload → lowered to proc
    xnkExternal_ConversionOp    # C# implicit/explicit conversion → lowered to converter

    # C# specific statements
    xnkExternal_Resource        # C# using / Java try-with-resources → lowered to try/finally
    xnkExternal_Fixed           # C# fixed statement → lowered to ptr operations
    xnkExternal_Lock            # C# lock statement → lowered to acquire/release
    xnkExternal_Unsafe          # C# unsafe block → lowered to {.emit.} or removed
    xnkExternal_Checked         # C# checked/unchecked → lowered or removed

    # C# specific expressions
    xnkExternal_SafeNavigation  # C# ?. operator → lowered to if-nil checks
    xnkExternal_NullCoalesce    # C# ?? operator → lowered to if-nil-else
    xnkExternal_ThrowExpr       # C# throw expression → lowered to raise
    xnkExternal_SwitchExpr      # C# switch expression → lowered to case expression
    xnkExternal_StackAlloc      # C# stackalloc → lowered to alloca or seq
    xnkExternal_StringInterp    # C# $"..." / Python f"..." → lowered to strformat

    # Cross-language constructs needing lowering
    xnkExternal_Ternary         # C-style ternary ?: → lowered to if expression
    xnkExternal_DoWhile         # do-while loop → lowered to while with flag
    xnkExternal_ForStmt         # C-style for(;;) → lowered to while
    xnkExternal_Interface       # Interface declaration → lowered to concept (Nim)
    xnkExternal_Generator       # Python generator expression → lowered to iterator
    xnkExternal_Comprehension   # Python list/dict/set comprehension → lowered to collect
    xnkExternal_With            # Python with statement → lowered to try/finally
    xnkExternal_Destructure     # JS/Python destructuring → lowered to individual assigns
    xnkExternal_Await           # async/await → lowered to Future handling
    xnkExternal_LocalFunction   # C# local function → lowered to nested proc or closure

    # C# extension methods
    xnkExternal_ExtensionMethod # C# extension method → raised to regular func with self param

    # Switch/case with fallthrough
    xnkExternal_FallthroughCase # Case clause with fallthrough → lowered to if-chain or state machine

    # Ruby-specific constructs
    xnkExternal_Unless          # Ruby unless → lowered to if not
    xnkExternal_Until           # Ruby until → lowered to while not

    # Python-specific constructs
    xnkExternal_Pass            # Python pass → lowered to discard

    # Go-specific constructs
    xnkExternal_Channel         # Go channel → lowered to channel library calls
    xnkExternal_Goroutine       # Go goroutine (go stmt) → lowered to spawn/async
    xnkExternal_GoDefer         # Go defer (different semantics from Nim defer)
    xnkExternal_GoSelect        # Go select statement → lowered to channel multiplexing



  XLangNode* = ref object
    ## Common fields (available for all node kinds)
    id*: Option[Uuid]        ## Unique identifier for this node (assigned during parsing or by buildNodeIndex)
    parentId*: Option[Uuid]  ## Parent node's UUID (for traversing up the tree)

    case kind*: XLangNodeKind  ## Variant fields (depends on node kind)
    of xnkFile:
      fileName*: string
      sourceLang*: string  ## Source language: "csharp", "java", "python", etc.
      moduleDecls*: seq[XLangNode]  ## Top-level declarations including imports, namespaces, classes, etc.
    of xnkModule:
      moduleName*: string
      moduleBody*: seq[XLangNode]
    of xnkNamespace:
      namespaceName*: string
      namespaceBody*: seq[XLangNode]
    of xnkFuncDecl:
      funcName*: string
      params*: seq[XLangNode]
      returnType*: Option[XLangNode]
      body*: XLangNode
      isAsync*: bool
      funcIsStatic*: bool  # Static functions don't get self parameter
      funcVisibility*: string  # "public", "private", "internal", "protected", etc.

    of xnkMethodDecl:
      receiver*: Option[XLangNode]       # <- method-specific field
      methodName*: string
      mparams*: seq[XLangNode]
      mreturnType*: Option[XLangNode]
      mbody*: XLangNode
      methodIsAsync*: bool
    of xnkIteratorDecl:
      iteratorName*: string
      iteratorParams*: seq[XLangNode]
      iteratorReturnType*: Option[XLangNode]
      iteratorBody*: XLangNode
    of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
      typeNameDecl*: string
      baseTypes*: seq[XLangNode]
      members*: seq[XLangNode]
    of xnkEnumDecl:
      enumName*: string
      enumMembers*: seq[XLangNode]
    of xnkVarDecl, xnkLetDecl, xnkConstDecl:
      declName*: string
      declType*: Option[XLangNode]
      initializer*: Option[XLangNode]
    of xnkTypeDecl:
      typeDefName*: string
      typeDefBody*: XLangNode
    # of xnkPropertyDecl:
    #   propName*: string
    #   propType*: Option[XLangNode]
    #   getter*: Option[XLangNode]
    #   setter*: Option[XLangNode]
    of xnkFieldDecl:
      fieldName*: string
      fieldType*: XLangNode
      fieldInitializer*: Option[XLangNode]
    of xnkConstructorDecl:
      constructorParams*: seq[XLangNode]
      constructorInitializers*: seq[XLangNode]
      constructorBody*: XLangNode
    of xnkDestructorDecl:
      destructorBody*: Option[XLangNode]
    # of xnkDelegateDecl:
    #   delegateName*: string
    #   delegateParams*: seq[XLangNode]
    #   delegateReturnType*: Option[XLangNode]
    of xnkAsgn:
      asgnLeft*: XLangNode
      asgnRight*: XLangNode
    of xnkBlockStmt:
      blockBody*: seq[XLangNode]
    of xnkIfStmt:
      ifCondition*: XLangNode
      ifBody*: XLangNode
      elseBody*: Option[XLangNode]
    of xnkSwitchStmt:
      switchExpr*: XLangNode
      switchCases*: seq[XLangNode]       # Contains xnkCaseClause and xnkDefaultClause nodes
    of xnkCaseClause:
      caseValues*: seq[XLangNode]        # Multiple values for case 1, 2, 3:
      caseBody*: XLangNode
      caseFallthrough*: bool             # For Go's fallthrough keyword
    of xnkDefaultClause:
      defaultBody*: XLangNode
    # of xnkForStmt:
    #   forInit*: Option[XLangNode]
    #   forCond*: Option[XLangNode]
    #   forIncrement*: Option[XLangNode]
    #   forBody*: Option[XLangNode]
    of xnkWhileStmt, xnkDoWhileStmt:
      whileCondition*: XLangNode
      whileBody*: XLangNode
    of xnkForeachStmt:
      foreachVar*: XLangNode
      foreachIter*: XLangNode
      foreachBody*: XLangNode
    of xnkTryStmt:
      tryBody*: XLangNode
      catchClauses*: seq[XLangNode]
      finallyClause*: Option[XLangNode]
    of xnkCatchStmt:
      catchType*: Option[XLangNode]
      catchVar*: Option[string]
      catchBody*: XLangNode
    of xnkFinallyStmt:
      finallyBody*: XLangNode
    of xnkReturnStmt:
      returnExpr*: Option[XLangNode]
    of xnkIteratorYield:
      ## Unified iterator/generator yield: Python yield, C# yield return, Nim yield
      iteratorYieldValue*: Option[XLangNode]
    of xnkIteratorDelegate:
      ## Delegate to sub-iterator: Python yield from, conceptually like foreach+yield
      iteratorDelegateExpr*: XLangNode
    # Legacy (deprecated):
    of xnkYieldStmt:
      yieldStmt*: Option[XLangNode]
    of xnkYieldExpr:
      yieldExpr*: Option[XLangNode]
    of xnkYieldFromStmt:
      yieldFromExpr*: XLangNode
    of xnkBreakStmt, xnkContinueStmt:
      label*: Option[string]
    of xnkThrowStmt:
      throwExpr*: XLangNode
    of xnkAssertStmt:
      assertCond*: XLangNode
      assertMsg*: Option[XLangNode]
    
    # of xnkWithStmt:
    #   items*: seq[XLangNode]
    #   withBody*: XLangNode
    of xnkWithItem:
      contextExpr*: XLangNode
      asExpr*: Option[XLangNode]
    # of xnkResourceStmt:
    #   ## Unified resource management: Python 'with', C# 'using', Java 'try-with-resources'
    #   resourceItems*: seq[XLangNode]  # xnkResourceItem nodes
    #   resourceBody*: XLangNode
    of xnkResourceItem:
      ## Individual resource in a resource statement
      resourceExpr*: XLangNode           # Expression that acquires resource
      resourceVar*: Option[XLangNode]    # Variable to bind resource to
      cleanupHint*: Option[string]       # Cleanup method: "close", "dispose", etc.
    of xnkPassStmt:
      discard
    of xnkTypeSwitchStmt:
      typeSwitchExpr*: XLangNode
      typeSwitchVar*: Option[XLangNode]
      typeSwitchCases*: seq[XLangNode]   # Contains xnkTypeCaseClause and xnkDefaultClause nodes
    of xnkBinaryExpr:
      binaryLeft*: XLangNode
      binaryOp*: BinaryOp      # Semantic operator (was string)
      binaryRight*: XLangNode
    of xnkUnaryExpr:
      unaryOp*: UnaryOp        # Semantic operator (was string)
      unaryOperand*: XLangNode
    # of xnkTernaryExpr:
    #   ternaryCondition*: XLangNode
    #   ternaryThen*: XLangNode
    #   ternaryElse*: XLangNode
    of xnkCallExpr:
      callee*: XLangNode
      args*: seq[XLangNode]
    of xnkThisCall, xnkBaseCall:
      ## C# constructor initializers: this(...) or base(...)
      arguments*: seq[XLangNode]
    of xnkIndexExpr:
      indexExpr*: XLangNode
      indexArgs*: seq[XLangNode]
    of xnkSliceExpr:
      sliceExpr*: XLangNode
      sliceStart*: Option[XLangNode]
      sliceEnd*: Option[XLangNode]
      sliceStep*: Option[XLangNode]
    of xnkMemberAccessExpr:
      memberExpr*: XLangNode
      memberName*: string
      isEnumAccess*: bool = false  # True if this is accessing an enum value (from C# parser semantic analysis)
      enumTypeName*: string = ""  # Short name of the enum type (e.g., "RegexOptions")
      enumFullName*: string = ""  # Fully qualified name (e.g., "System.Text.RegularExpressions.RegexOptions")
    # of xnkSafeNavigationExpr:
    #   safeNavObject*: XLangNode
    #   safeNavMember*: string             # For user?.Name
    # of xnkNullCoalesceExpr:
    #   nullCoalesceLeft*: XLangNode       # Left side of ??
    #   nullCoalesceRight*: XLangNode      # Right side of ??
    of xnkLambdaExpr:
      lambdaParams*: seq[XLangNode]
      lambdaReturnType*: Option[XLangNode]
      lambdaBody*: XLangNode
    of xnkTypeAssertion:
      assertExpr*: XLangNode
      assertType*: XLangNode
    of xnkLambdaProc:
      lambdaProcParams*: seq[XLangNode]
      lambdaProcReturn*: Option[XLangNode]
      lambdaProcBody*: XLangNode
    of xnkArrowFunc:
      arrowParams*: seq[XLangNode]
      arrowBody*: XLangNode
      arrowReturnType*: Option[XLangNode]
    of xnkConceptRequirement:
      reqName*: string
      reqParams*: seq[XLangNode]
      reqReturn*: Option[XLangNode]
    of xnkMethodReference:
      refObject*: XLangNode
      refMethod*: string
    of xnkSequenceLiteral, xnkSetLiteral, xnkArrayLiteral, xnkTupleExpr:
      ## Collection literals: [1,2,3], {1,2,3}, (1,2,3)
      elements*: seq[XLangNode]
    of xnkMapLiteral:
      ## Map/dictionary literal: {"a": 1, "b": 2}
      entries*: seq[XLangNode]  # seq of xnkDictEntry
    # Legacy (deprecated - use unified *Literal nodes):
    of xnkListExpr, xnkSetExpr:
      legacyElements*: seq[XLangNode]
    of xnkDictExpr:
      legacyEntries*: seq[XLangNode]
    of xnkArrayLit:
      legacyArrayElements*: seq[XLangNode]
    of xnkDictEntry:
      key*: XLangNode
      value*: XLangNode
    # of xnkComprehensionExpr:
    #   compExpr*: XLangNode
    #   fors*: seq[XLangNode]
    #   compIf*: seq[XLangNode]
    of xnkCompFor:
      vars*: seq[XLangNode]
      iter*: XLangNode
    # of xnkGeneratorExpr:
    #   genExpr*: XLangNode
    #   genFor*: seq[XLangNode]  # Each should be xnkCompFor
    #   genIf*: seq[XLangNode]
    # of xnkAwaitExpr:
    #   awaitExpr*: XLangNode
    # xnkYieldExpr handled above grouped with xnkYieldStmt
    # of xnkStringInterpolation:
    #   interpParts*: seq[XLangNode]       # Mix of string literals and expressions
    #   interpIsExpr*: seq[bool]           # True if corresponding part is expression
    of xnkIntLit, xnkFloatLit, xnkStringLit, xnkCharLit:
      literalValue*: string
    of xnkBoolLit:
      boolValue*: bool
    of xnkNoneLit:
      discard
    of xnkNamedType:
      typeName*: string
    of xnkArrayType:
      elementType*: XLangNode
      arraySize*: Option[XLangNode]
    of xnkMapType:
      keyType*: XLangNode
      valueType*: XLangNode
    of xnkFuncType:
      funcParams*: seq[XLangNode]
      funcReturnType*: Option[XLangNode]
    of xnkPointerType, xnkReferenceType:
      referentType*: XLangNode
    of xnkGenericType:
      genericTypeName*: string
      genericBase*: Option[XLangNode]
      genericArgs*: seq[XLangNode]
    of xnkUnionType:
      unionTypes*: seq[XLangNode]
    of xnkIntersectionType:
      typeMembers*: seq[XLangNode]
    of xnkDistinctType:
      distinctBaseType*: XLangNode
    of xnkIdentifier:
      identName*: string

    of xnkComment:
      commentText*: string
      isDocComment*: bool

    of xnkImport:
      importPath*: string
      importAlias*: Option[string]
    of xnkExport:
      exportedDecl*: XLangNode
    of xnkAttribute:
      attrName*: string
      attrArgs*: seq[XLangNode]
    of xnkGenericParameter:
      genericParamName*: string
      genericParamConstraints*: seq[XLangNode]
      bounds*: seq[XLangNode]
    of xnkParameter:
      paramName*: string
      paramType*: Option[XLangNode]
      defaultValue*: Option[XLangNode]
    of xnkArgument:
      argName*: Option[string]
      argValue*: XLangNode
    of xnkDecorator:
      decoratorExpr*: XLangNode
    of xnkTemplateDef, xnkMacroDef:
      name*: string
      tplparams*: seq[XLangNode]
      tmplbody*: XLangNode
      isExported*: bool
    of xnkPragma:
      pragmas*: seq[XLangNode]
    of xnkStaticStmt, xnkDeferStmt:
      staticBody*: XLangNode
    of xnkAsmStmt:
      asmCode*: string
    of xnkDistinctTypeDef:
      distinctName*: string
      baseType*: XLangNode
    of xnkConceptDef:
      conceptName*: string
      conceptBody*: XLangNode
    of xnkConceptDecl:
      conceptDeclName*: string
      conceptRequirements*: seq[XLangNode]
    of xnkMixinStmt:
      mixinNames*: seq[string]
    of xnkBindStmt:
      bindNames*: seq[string]
    of xnkTupleConstr:
      tupleElements*: seq[XLangNode]
    of xnkTupleUnpacking:
      unpackTargets*: seq[XLangNode]
      unpackExpr*: XLangNode
    of xnkUsingStmt:
      usingExpr*: XLangNode
      usingBody*: XLangNode
    of xnkDestructureObj:
      destructObjFields*: seq[string]    # Field names to extract
      destructObjSource*: XLangNode      # Source object
    of xnkDestructureArray:
      destructArrayVars*: seq[string]    # Variable names for elements
      destructArrayRest*: Option[string] # Rest/spread variable name
      destructArraySource*: XLangNode    # Source array
    of xnkDotExpr:
      dotBase*: XLangNode
      member*: XLangNode
      # dot expr used for dot-style member access; memberExpr/memberName handled via xnkMemberAccessExpr
    of xnkBracketExpr:
      base*: XLangNode
      index*: XLangNode
    of xnkCaseStmt:
      expr*: Option[XLangNode]
      branches*: seq[XLangNode]
      caseElseBody*: Option[XLangNode]
    of xnkRaiseStmt:
      raiseExpr*: Option[XLangNode]
    of xnkImportStmt:
      imports*: seq[string]
    of xnkExportStmt:
      exports*: seq[string]
    of xnkFromImportStmt:
      module*: string
      fromImports*: seq[string]
      # imports handled by xnkImportStmt; keep canonical 'fromImports*'
    of xnkNilLit:
      discard
    of xnkDiscardStmt:
      discardExpr*: Option[XLangNode]
    of xnkTypeCaseClause:
      caseType*: XLangNode
      typeCaseBody*: XLangNode
    of xnkModuleDecl:
      moduleNameDecl*: string
      moduleMembers*: seq[XLangNode]
    of xnkTypeAlias:
      aliasName*: string
      aliasTarget*: XLangNode
    of xnkAbstractDecl:
      abstractName*: string
      abstractBody*: seq[XLangNode]
    of xnkEnumMember:
      enumMemberName*: string
      enumMemberValue*: Option[XLangNode]
    of xnkLibDecl:
      libName*: string
      libBody*: seq[XLangNode]
    of xnkCFuncDecl:
      cfuncName*: string
      cfuncParams*: seq[XLangNode]
      cfuncReturnType*: Option[XLangNode]
    of xnkExternalVar:
      extVarName*: string
      extVarType*: XLangNode
    of xnkUnlessStmt:
      unlessCondition*: XLangNode
      unlessBody*: XLangNode
    of xnkUntilStmt:
      untilCondition*: XLangNode
      untilBody*: XLangNode
    of xnkStaticAssert:
      staticAssertCondition*: XLangNode
      staticAssertMessage*: Option[XLangNode]
    of xnkSwitchCase:
      switchCaseConditions*: seq[XLangNode]
      switchCaseBody*: XLangNode
    of xnkMixinDecl:
      mixinDeclExpr*: XLangNode
    of xnkTemplateDecl:
      templateName*: string
      templateParams*: seq[XLangNode]
      templateBody*: seq[XLangNode]
    of xnkMacroDecl:
      macroName*: string
      macroParams*: seq[XLangNode]
      macroBody*: XLangNode
    of xnkInclude:
      includeName*: XLangNode
    of xnkExtend:
      extendName*: XLangNode
    of xnkCastExpr:
      castExpr*: XLangNode
      castType*: XLangNode
    of xnkThisExpr:
      discard  # No fields needed - represents "this" keyword
    of xnkInstanceVar, xnkClassVar, xnkGlobalVar:
      varName*: string
    of xnkProcLiteral:
      procBody*: XLangNode
    of xnkProcPointer:
      procPointerName*: string
    # xnkArrayLit moved to unified collection literals section (line 286)
    of xnkNumberLit:
      numberValue*: string
    of xnkSymbolLit:
      symbolValue*: string
    of xnkDynamicType:
      dynamicConstraint*: Option[XLangNode]
    of xnkAbstractType:
      abstractTypeName*: string
    of xnkFunctionType:
      functionTypeParams*: seq[XLangNode]
      functionTypeReturn*: Option[XLangNode]
    of xnkMetadata:
      metadataEntries*: seq[XLangNode]
    # New C# constructs
    # of xnkIndexerDecl:
    #   indexerParams*: seq[XLangNode]
    #   indexerType*: XLangNode
    #   indexerGetter*: Option[XLangNode]
    #   indexerSetter*: Option[XLangNode]
    # of xnkOperatorDecl:
    #   operatorSymbol*: string
    #   operatorParams*: seq[XLangNode]
    #   operatorReturnType*: XLangNode
    #   operatorBody*: XLangNode
    # of xnkConversionOperatorDecl:
    #   conversionIsImplicit*: bool
    #   conversionFromType*: XLangNode
    #   conversionToType*: XLangNode
    #   conversionBody*: XLangNode
    of xnkBaseExpr:
      discard  # Represents "base" keyword
    of xnkRefExpr:
      refExpr*: XLangNode
    of xnkDefaultExpr:
      defaultType*: Option[XLangNode]
    of xnkTypeOfExpr:
      typeOfType*: XLangNode
    of xnkSizeOfExpr:
      sizeOfType*: XLangNode
    of xnkCheckedExpr:
      checkedExpr*: XLangNode
      isChecked*: bool
    # of xnkThrowExpr:
    #   throwExprValue*: XLangNode
    # of xnkSwitchExpr:
    #   switchExprValue*: XLangNode
    #   switchExprArms*: seq[XLangNode]
    # of xnkStackAllocExpr:
    #   stackAllocType*: XLangNode
    #   stackAllocSize*: Option[XLangNode]
    of xnkImplicitArrayCreation:
      implicitArrayElements*: seq[XLangNode]
    of xnkEmptyStmt:
      discard
    of xnkLabeledStmt:
      labelName*: string
      labeledStmt*: XLangNode
    of xnkGotoStmt:
      gotoLabel*: string
    # of xnkFixedStmt:
    #   fixedDeclarations*: seq[XLangNode]
    #   fixedBody*: XLangNode
    # of xnkLockStmt:
    #   lockExpr*: XLangNode
    #   lockBody*: XLangNode
    # of xnkUnsafeStmt:
    #   unsafeBody*: XLangNode
    # of xnkCheckedStmt:
    #   checkedBody*: XLangNode
    #   checkedIsChecked*: bool
    # of xnkLocalFunctionStmt:
    #   localFuncName*: string
    #   localFuncParams*: seq[XLangNode]
    #   localFuncReturnType*: Option[XLangNode]
    #   localFuncBody*: XLangNode
    of xnkQualifiedName:
      qualifiedLeft*: XLangNode
      qualifiedRight*: XLangNode
    of xnkAliasQualifiedName:
      aliasQualifier*: string
      aliasQualifiedName*: string
    of xnkGenericName:
      genericNameIdentifier*: string
      genericNameArgs*: seq[XLangNode]

    # ==========================================================================
    # External/Source-Specific Kind Fields
    # ==========================================================================
    # These share the same field structure as their common counterparts.
    # The external prefix indicates they must be lowered by transformation passes.

    # C# Property with explicit accessor info
    of xnkExternal_Property:
      extPropName*: string
      extPropType*: Option[XLangNode]
      extPropVisibility*: string          # "public", "private", "protected", "internal"
      extPropIsStatic*: bool
      extPropHasGetter*: bool             # Does get accessor exist?
      extPropHasSetter*: bool             # Does set accessor exist?
      extPropGetterBody*: Option[XLangNode]  # Body if explicit, none if auto
      extPropSetterBody*: Option[XLangNode]  # Body if explicit, none if auto
      extPropInitializer*: Option[XLangNode] # For: public int X { get; } = 5;

    # C# Indexer → shares fields with xnkIndexerDecl
    of xnkExternal_Indexer:
      extIndexerParams*: seq[XLangNode]
      extIndexerType*: XLangNode
      extIndexerGetter*: Option[XLangNode]
      extIndexerSetter*: Option[XLangNode]

    # C# Event declaration
    of xnkExternal_Event:
      extEventName*: string
      extEventType*: XLangNode
      extEventAdd*: Option[XLangNode]
      extEventRemove*: Option[XLangNode]

    # C# Delegate → shares fields with xnkDelegateDecl
    of xnkExternal_Delegate:
      extDelegateName*: string
      extDelegateParams*: seq[XLangNode]
      extDelegateReturnType*: Option[XLangNode]

    # C# Operator → shares fields with xnkOperatorDecl
    of xnkExternal_Operator:
      extOperatorSymbol*: string
      extOperatorParams*: seq[XLangNode]
      extOperatorReturnType*: XLangNode
      extOperatorBody*: Option[XLangNode]

    # C# Conversion Operator → shares fields with xnkConversionOperatorDecl
    of xnkExternal_ConversionOp:
      extConversionIsImplicit*: bool
      extConversionParamName*: string
      extConversionFromType*: XLangNode
      extConversionToType*: XLangNode
      extConversionBody*: XLangNode  # Changed from Option - C# parser always provides body

    # C# using / Java try-with-resources → shares fields with xnkResourceStmt
    of xnkExternal_Resource:
      extResourceItems*: seq[XLangNode]
      extResourceBody*: XLangNode

    # C# fixed statement → shares fields with xnkFixedStmt
    of xnkExternal_Fixed:
      extFixedDeclarations*: seq[XLangNode]
      extFixedBody*: XLangNode

    # C# lock statement → shares fields with xnkLockStmt
    of xnkExternal_Lock:
      extLockExpr*: XLangNode
      extLockBody*: XLangNode

    # C# unsafe block → shares fields with xnkUnsafeStmt
    of xnkExternal_Unsafe:
      extUnsafeBody*: XLangNode

    # C# checked/unchecked → shares fields with xnkCheckedStmt
    of xnkExternal_Checked:
      extCheckedBody*: XLangNode
      extCheckedIsChecked*: bool

    # C# ?. operator → shares fields with xnkSafeNavigationExpr
    of xnkExternal_SafeNavigation:
      extSafeNavObject*: XLangNode
      extSafeNavMember*: string

    # C# ?? operator → shares fields with xnkNullCoalesceExpr
    of xnkExternal_NullCoalesce:
      extNullCoalesceLeft*: XLangNode
      extNullCoalesceRight*: XLangNode

    # C# throw expression → shares fields with xnkThrowExpr
    of xnkExternal_ThrowExpr:
      extThrowExprValue*: XLangNode

    # C# switch expression → shares fields with xnkSwitchExpr
    of xnkExternal_SwitchExpr:
      extSwitchExprValue*: XLangNode
      extSwitchExprArms*: seq[XLangNode]

    # C# stackalloc → shares fields with xnkStackAllocExpr
    of xnkExternal_StackAlloc:
      extStackAllocType*: XLangNode
      extStackAllocSize*: Option[XLangNode]

    # String interpolation → shares fields with xnkStringInterpolation
    of xnkExternal_StringInterp:
      extInterpParts*: seq[XLangNode]
      extInterpIsExpr*: seq[bool]

    # Ternary expression → shares fields with xnkTernaryExpr
    of xnkExternal_Ternary:
      extTernaryCondition*: XLangNode
      extTernaryThen*: XLangNode
      extTernaryElse*: XLangNode

    # Do-while loop → shares fields with xnkDoWhileStmt
    of xnkExternal_DoWhile:
      extDoWhileCondition*: XLangNode
      extDoWhileBody*: XLangNode

    # C-style for loop → shares fields with xnkForStmt
    of xnkExternal_ForStmt:
      extForInit*: Option[XLangNode]
      extForCond*: Option[XLangNode]
      extForIncrement*: Option[XLangNode]
      extForBody*: Option[XLangNode]

    # Interface → shares fields with xnkInterfaceDecl
    of xnkExternal_Interface:
      extInterfaceName*: string
      extInterfaceBaseTypes*: seq[XLangNode]
      extInterfaceMembers*: seq[XLangNode]

    # Generator expression → shares fields with xnkGeneratorExpr
    of xnkExternal_Generator:
      extGenExpr*: XLangNode
      extGenFor*: seq[XLangNode]
      extGenIf*: seq[XLangNode]

    # List/dict/set comprehension → shares fields with xnkComprehensionExpr
    of xnkExternal_Comprehension:
      extCompExpr*: XLangNode
      extCompFors*: seq[XLangNode]
      extCompIf*: seq[XLangNode]

    # Python with statement → shares fields with xnkWithStmt
    of xnkExternal_With:
      extWithItems*: seq[XLangNode]
      extWithBody*: XLangNode

    # Destructuring → combined destructure fields
    of xnkExternal_Destructure:
      extDestructKind*: string  # "object" or "array"
      extDestructSource*: XLangNode
      extDestructFields*: seq[string]  # for object destructure
      extDestructVars*: seq[string]    # for array destructure
      extDestructRest*: Option[string] # rest/spread variable

    # Await expression → shares fields with xnkAwaitExpr
    of xnkExternal_Await:
      extAwaitExpr*: XLangNode

    # Local function → shares fields with xnkLocalFunctionStmt
    of xnkExternal_LocalFunction:
      extLocalFuncName*: string
      extLocalFuncParams*: seq[XLangNode]
      extLocalFuncReturnType*: Option[XLangNode]
      extLocalFuncBody*: Option[XLangNode]

    # C# extension method
    of xnkExternal_ExtensionMethod:
      extExtMethodName*: string
      extExtMethodParams*: seq[XLangNode]  # first param is 'this' type
      extExtMethodReturnType*: Option[XLangNode]
      extExtMethodBody*: XLangNode
      extExtMethodIsStatic*: bool
      extExtMethodVisibility*: string  # "public", "private", "internal", "protected", etc.

    # Switch case with fallthrough
    of xnkExternal_FallthroughCase:
      extFallthroughValues*: seq[XLangNode]  # case values
      extFallthroughBody*: XLangNode
      extFallthroughHasFallthrough*: bool    # true if falls through to next case

    # Ruby unless
    of xnkExternal_Unless:
      extUnlessCondition*: XLangNode
      extUnlessBody*: XLangNode
      extUnlessElse*: Option[XLangNode]

    # Ruby until
    of xnkExternal_Until:
      extUntilCondition*: XLangNode
      extUntilBody*: XLangNode

    # Python pass
    of xnkExternal_Pass:
      discard  # pass has no fields

    # Go channel
    of xnkExternal_Channel:
      extChannelType*: XLangNode        # channel element type
      extChannelBuffered*: bool
      extChannelSize*: Option[XLangNode]

    # Go goroutine
    of xnkExternal_Goroutine:
      extGoroutineCall*: XLangNode      # the function call to run

    # Go defer (different from Nim defer - LIFO stack)
    of xnkExternal_GoDefer:
      extGoDeferCall*: XLangNode        # the deferred function call

    # Go select
    of xnkExternal_GoSelect:
      extSelectCases*: seq[XLangNode]   # select cases (channel operations)
      extSelectDefault*: Option[XLangNode]

    of xnkUnknown:
      unknownData*: string
    # else: discard


# type XLangAST = object
#   version: XLangVersion
#   root: XLangNode


proc `$`*(node: XLangNode): string =
  if node == nil: return "nil"

  result = $node.kind

  case node.kind:
  of xnkFile:
    result &= "(" & node.fileName & ")"
  of xnkModule:
    result &= "(" & node.moduleName & ")"
  of xnkNamespace:
    result &= "(" & node.namespaceName & ")"
  of xnkFuncDecl:
    result &= "(" & node.funcName & ")"
  of xnkMethodDecl:
    result &= "(" & node.methodName & ")"
  of xnkIteratorDecl:
    result &= "(" & node.iteratorName & ")"
  of xnkClassDecl, xnkStructDecl, xnkInterfaceDecl:
    result &= "(" & node.typeNameDecl & ")"
  of xnkEnumDecl:
    result &= "(" & node.enumName & ")"
  of xnkVarDecl, xnkLetDecl, xnkConstDecl:
    result &= "(" & node.declName & ")"
  of xnkTypeDecl:
    result &= "(" & node.typeDefName & ")"
  of xnkFieldDecl:
    result &= "(" & node.fieldName & ")"
  of xnkBinaryExpr:
    result &= "(" & $node.binaryOp & ")"
  of xnkUnaryExpr:
    result &= "(" & $node.unaryOp & ")"
  of xnkMemberAccessExpr:
    result &= "(" & node.memberName & ")"
  of xnkIntLit, xnkFloatLit, xnkStringLit, xnkCharLit:
    result &= "(\"" & node.literalValue & "\")"
  of xnkBoolLit:
    result &= "(" & $node.boolValue & ")"
  of xnkNamedType:
    result &= "(" & node.typeName & ")"
  of xnkGenericType:
    result &= "(" & node.genericTypeName & ")"
  of xnkIdentifier:
    result &= "(" & node.identName & ")"
  of xnkComment:
    let preview = if node.commentText.len > 30: node.commentText[0..29] & "..." else: node.commentText
    result &= "(\"" & preview & "\")"
  of xnkImport:
    result &= "(" & node.importPath & ")"
  of xnkAttribute:
    result &= "(" & node.attrName & ")"
  of xnkGenericParameter:
    result &= "(" & node.genericParamName & ")"
  of xnkParameter:
    result &= "(" & node.paramName & ")"
  of xnkArgument:
    if node.argName.isSome():
      result &= "(" & node.argName.get & ")"
  of xnkTemplateDef, xnkMacroDef:
    result &= "(" & node.name & ")"
  of xnkAsmStmt:
    let preview = if node.asmCode.len > 30: node.asmCode[0..29] & "..." else: node.asmCode
    result &= "(\"" & preview & "\")"
  of xnkDistinctTypeDef:
    result &= "(" & node.distinctName & ")"
  of xnkConceptDef:
    result &= "(" & node.conceptName & ")"
  of xnkConceptDecl:
    result &= "(" & node.conceptDeclName & ")"
  of xnkConceptRequirement:
    result &= "(" & node.reqName & ")"
  of xnkModuleDecl:
    result &= "(" & node.moduleNameDecl & ")"
  of xnkTypeAlias:
    result &= "(" & node.aliasName & ")"
  of xnkAbstractDecl:
    result &= "(" & node.abstractName & ")"
  of xnkEnumMember:
    result &= "(" & node.enumMemberName & ")"
  of xnkLibDecl:
    result &= "(" & node.libName & ")"
  of xnkCFuncDecl:
    result &= "(" & node.cfuncName & ")"
  of xnkExternalVar:
    result &= "(" & node.extVarName & ")"
  of xnkTemplateDecl:
    result &= "(" & node.templateName & ")"
  of xnkMacroDecl:
    result &= "(" & node.macroName & ")"
  of xnkInstanceVar, xnkClassVar, xnkGlobalVar:
    result &= "(" & node.varName & ")"
  of xnkProcPointer:
    result &= "(" & node.procPointerName & ")"
  of xnkNumberLit:
    result &= "(\"" & node.numberValue & "\")"
  of xnkSymbolLit:
    result &= "(\"" & node.symbolValue & "\")"
  of xnkAbstractType:
    result &= "(" & node.abstractTypeName & ")"
  of xnkCheckedExpr:
    result &= "(" & (if node.isChecked: "checked" else: "unchecked") & ")"
  of xnkLabeledStmt:
    result &= "(" & node.labelName & ")"
  of xnkGotoStmt:
    result &= "(" & node.gotoLabel & ")"
  of xnkQualifiedName:
    result &= "(" & $node.qualifiedRight.kind & ")"
  of xnkAliasQualifiedName:
    result &= "(" & node.aliasQualifier & "::" & node.aliasQualifiedName & ")"
  of xnkGenericName:
    result &= "(" & node.genericNameIdentifier & ")"
  of xnkUnknown:
    let preview = if node.unknownData.len > 30: node.unknownData[0..29] & "..." else: node.unknownData
    result &= "(\"" & preview & "\")"
  of xnkBreakStmt, xnkContinueStmt:
    if node.label.isSome():
      result &= "(" & node.label.get & ")"
  of xnkCatchStmt:
    if node.catchVar.isSome():
      result &= "(" & node.catchVar.get & ")"
  of xnkMixinStmt:
    result &= "(" & $node.mixinNames & ")"
  of xnkBindStmt:
    result &= "(" & $node.bindNames & ")"
  of xnkDestructureObj:
    result &= "(" & $node.destructObjFields & ")"
  of xnkDestructureArray:
    result &= "(" & $node.destructArrayVars & ")"
  of xnkImportStmt:
    result &= "(" & $node.imports & ")"
  of xnkExportStmt:
    result &= "(" & $node.exports & ")"
  of xnkFromImportStmt:
    result &= "(from " & node.module & ")"
  of xnkResourceItem:
    if node.cleanupHint.isSome():
      result &= "(" & node.cleanupHint.get & ")"
  of xnkExternal_StringInterp:
    result &= "(" & $node.extInterpParts.len & " parts)"
  of xnkMethodReference:
    result &= "(" & node.refMethod & ")"
  of xnkExternal_Generator:
    result &= "(" & $node.extGenFor.len & " for clause" & (if node.extGenFor.len != 1: "s" else: "") & ")"

  # External kinds with name fields
  of xnkExternal_Property:
    result &= "(" & node.extPropName & ")"
  of xnkExternal_Event:
    result &= "(" & node.extEventName & ")"
  of xnkExternal_Delegate:
    result &= "(" & node.extDelegateName & ")"
  of xnkExternal_Operator:
    result &= "(" & node.extOperatorSymbol & ")"
  of xnkExternal_ConversionOp:
    result &= "(" & (if node.extConversionIsImplicit: "implicit" else: "explicit") & ")"
  of xnkExternal_SafeNavigation:
    result &= "(" & node.extSafeNavMember & ")"
  of xnkExternal_Interface:
    result &= "(" & node.extInterfaceName & ")"
  of xnkExternal_LocalFunction:
    result &= "(" & node.extLocalFuncName & ")"
  of xnkExternal_Checked:
    result &= "(" & (if node.extCheckedIsChecked: "checked" else: "unchecked") & ")"
  of xnkExternal_ExtensionMethod:
    result &= "(" & node.extExtMethodName & ")"
  of xnkExternal_Channel:
    result &= "(" & (if node.extChannelBuffered: "buffered" else: "unbuffered") & ")"

  # Statements and expressions with no meaningful string fields to display
  of xnkConstructorDecl, xnkDestructorDecl, xnkAsgn, xnkBlockStmt, xnkIfStmt,
     xnkSwitchStmt, xnkCaseClause, xnkDefaultClause, xnkWhileStmt,
     xnkDoWhileStmt, xnkForeachStmt, xnkTryStmt, xnkFinallyStmt,
     xnkReturnStmt, xnkIteratorYield, xnkIteratorDelegate,
     xnkYieldStmt, xnkYieldExpr, xnkYieldFromStmt,
     xnkThrowStmt, xnkAssertStmt,  xnkPassStmt, xnkTypeSwitchStmt,
      xnkWithItem, xnkDiscardStmt, xnkCaseStmt, xnkRaiseStmt,
     xnkTypeCaseClause, xnkEmptyStmt, 
            xnkUnlessStmt, xnkUntilStmt, xnkStaticAssert, xnkSwitchCase,
     xnkInclude, xnkExtend, xnkCallExpr, xnkThisCall, xnkBaseCall,
     xnkIndexExpr, xnkSliceExpr, xnkLambdaExpr,
     xnkTypeAssertion, xnkCastExpr, xnkThisExpr, xnkBaseExpr, xnkRefExpr,
     xnkProcLiteral, xnkDynamicType, 
     xnkDotExpr, xnkBracketExpr, xnkCompFor, xnkDefaultExpr, xnkTypeOfExpr,
     xnkSizeOfExpr,   
     xnkImplicitArrayCreation, xnkNoneLit, xnkNilLit, xnkArrayType, xnkMapType,
     xnkFuncType, xnkPointerType, xnkReferenceType, xnkUnionType,
     xnkIntersectionType, xnkDistinctType, xnkExport, xnkDecorator,
     xnkLambdaProc, xnkArrowFunc, xnkPragma, xnkStaticStmt, xnkDeferStmt,
     xnkTupleConstr, xnkTupleUnpacking, xnkUsingStmt, xnkSequenceLiteral,
     xnkSetLiteral, xnkMapLiteral, xnkArrayLiteral, xnkTupleExpr,
      xnkDictEntry, xnkListExpr, xnkSetExpr, xnkDictExpr,
     xnkArrayLit,  xnkFunctionType, xnkMetadata, xnkMixinDecl,     
     xnkExternal_Indexer, xnkExternal_Resource, xnkExternal_Fixed,
     xnkExternal_Lock, xnkExternal_Unsafe, xnkExternal_NullCoalesce,
     xnkExternal_ThrowExpr, xnkExternal_SwitchExpr, xnkExternal_StackAlloc,
     xnkExternal_Ternary, xnkExternal_DoWhile,
     xnkExternal_ForStmt, xnkExternal_Comprehension,
     xnkExternal_With, xnkExternal_Destructure, xnkExternal_Await,
     xnkExternal_FallthroughCase, xnkExternal_Unless, xnkExternal_Until,
     xnkExternal_Pass, xnkExternal_Goroutine, xnkExternal_GoDefer,
     xnkExternal_GoSelect:
    discard
    


# ==========================================================================
# External Kind Helpers
# ==========================================================================

const externalKinds*: set[XLangNodeKind] = {
  xnkExternal_Property, xnkExternal_Indexer, xnkExternal_Event,
  xnkExternal_Delegate, xnkExternal_Operator, xnkExternal_ConversionOp,
  xnkExternal_Resource, xnkExternal_Fixed, xnkExternal_Lock,
  xnkExternal_Unsafe, xnkExternal_Checked, xnkExternal_SafeNavigation,
  xnkExternal_NullCoalesce, xnkExternal_ThrowExpr, xnkExternal_SwitchExpr,
  xnkExternal_StackAlloc, xnkExternal_StringInterp, xnkExternal_Ternary,
  xnkExternal_DoWhile, xnkExternal_ForStmt, xnkExternal_Interface,
  xnkExternal_Generator, xnkExternal_Comprehension, xnkExternal_With,
  xnkExternal_Destructure, xnkExternal_Await, xnkExternal_LocalFunction,
  # Additional external kinds from audit
  xnkExternal_ExtensionMethod,  # C# extension methods
  xnkExternal_FallthroughCase,  # switch case with fallthrough
  xnkExternal_Unless,           # Ruby unless
  xnkExternal_Until,            # Ruby until
  xnkExternal_Pass,             # Python pass statement
  xnkExternal_Channel,          # Go channel
  xnkExternal_Goroutine,        # Go goroutine
  xnkExternal_GoDefer,          # Go defer
  xnkExternal_GoSelect          # Go select
}

proc isExternalKind*(kind: XLangNodeKind): bool =
  ## Returns true if the kind is an external/source-specific kind
  ## that must be lowered by transformation passes.
  kind in externalKinds

