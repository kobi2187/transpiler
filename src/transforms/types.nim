# transforms/types.nim


import ../../xlangtypes
import sets, hashes


type TransformPassID* = enum
    ## Unique identifier for each transformation pass
    ## Used for dependency tracking
    tpNone = "none"
    tpForToWhile = "for-to-while"
    tpDoWhileToWhile = "dowhile-to-while"
    tpTernaryToIf = "ternary-to-if"
    tpNimInterfaceToConcept = "nim-interface-to-concept"
    tpPropertyToProcs = "property-to-procs"
    tpSwitchFallthrough = "switch-fallthrough"
    tpNullCoalesce = "null-coalesce"
    tpMultipleCatch = "multiple-catch"
    tpDestructuring = "destructuring"
    tpListComprehension = "list-comprehension"
    tpNormalizeSimple = "normalize-simple"
    tpStringInterpolation = "string-interpolation"
    tpWithToDefer = "with-to-defer"
    tpAsyncNormalization = "async-normalization"
    tpUnionToVariant = "union-to-variant"
    tpLinqToSequtils = "linq-to-sequtils"
    tpOperatorOverload = "operator-overload"
    tpPatternMatching = "pattern-matching"
    tpDecoratorAttribute = "decorator-attribute"
    tpExtensionMethods = "extension-methods"
    tpGoErrorHandling = "go-error-handling"
    tpGoDefer = "go-defer"
    tpCSharpUsing = "csharp-using"
    tpGoConcurrency = "go-concurrency"
    tpPythonGenerators = "python-generators"
    tpPythonTypeHints = "python-type-hints"
    tpGoPanicRecover = "go-panic-recover"
    tpCSharpEvents = "csharp-events"
    tpLambdaNormalization = "lambda-normalization"
    tpGoTypeAssertions = "go-type-assertions"
    tpGoImplicitInterfaces = "go-implicit-interfaces"
    tpEnumNormalization = "enum-normalization"
    tpPythonMultipleInheritance = "python-multiple-inheritance"
    tpLockToWithLock = "lock-to-withlock"
    tpResourceToDefer = "resource-to-defer"
    tpSafeNavigation = "safe-navigation"
    tpIndexerToProcs = "indexer-to-procs"
    tpGeneratorExpressions = "generator-expressions"
    tpThrowExpression = "throw-expression"
    tpResourceToTryFinally = "resource-to-try-finally"  # Alternative to defer for targets without it
    tpSwitchExprToCase = "switch-expr-to-case"
    tpStackAllocToSeq = "stackalloc-to-seq"
    tpConversionOpToProc = "conversion-op-to-proc"
    tpCheckedToBlock = "checked-to-block"
    tpFixedToBlock = "fixed-to-block"
    tpLocalFunctionToProc = "local-function-to-proc"
    tpUnsafeToNimBlock = "unsafe-to-nim-block"
    tpDelegateToProcType = "delegate-to-proc-type"
    # Add more passes here as they are implemented

type TransformPass* = ref object
    ## A single transformation pass
    id*: TransformPassID         ## Unique identifier
    # kind*: TransformPassKind
    operatesOnKinds*: HashSet[XLangNodeKind] 
    transform*: proc(node: XLangNode): XLangNode

proc newTransformPass*(tp: TransformPassID, p: proc(node: XLangNode): XLangNode, kinds: seq[XLangNodeKind]) : TransformPass = 
    new result
    result.id = tp
    result.transform = p
    result.operatesOnKinds = kinds.toHashSet()


    
