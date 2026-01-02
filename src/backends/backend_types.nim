## Backend Types
##
## Common types and concept (interface) for output language backends.
## Each backend (Nim, Go, Rust, etc.) must implement the BackendOps concept.


#NOTE! didn't work well, unused right now. just complicates the code.

import core/xlangtypes
import semantic/semantic_analysis
import transforms/types

type
  OutputLanguage* = enum
    ## Supported output languages
    olNim = "nim"
    

  BackendContext* = object
    ## Context passed to backend operations for file output
    inputFile*: string
    outputDir*: string
    inputRoot*: string
    useStdout*: bool
    outputJson*: bool
    sameDir*: bool
    verbose*: bool

# # Backend Concept (compile-time interface)
# # Any type that implements these procedures can be used as a backend
# type
#   BackendOps* = concept b
#     ## Compile-time interface that all backends must implement

#     # Get backend metadata
#     b.getFileExtension() is string
#     b.getKeywords() is seq[string]
#     b.selectTransformIDs() is seq[TransformPassID]

#     # Transform operations
#     b.sanitizeIdentifiers(XLangNode) is XLangNode

#     # AST conversion (returns backend-specific AST type)
#     # Note: Each backend can return its own AST type
#     b.convertFromXLang(XLangNode, SemanticInfo, string, bool)

#     # Code generation (takes backend AST, returns code string)
#     # Note: First parameter type matches return type of convertFromXLang
#     # b.generateCode(b.convertFromXLang(...), bool) is string

#     # Output writing
#     # b.writeOutput(string, backendAST, XLangNode, BackendContext)

type Backend* = ref object of RootObj 
  ## Abstract base type for backends


# procs should just raise an exception, it's abstract base type.

method selectTransformIDs*(backend: Backend): seq[TransformPassID] {.base.} =
  ## Select which transforms the backend needs
  raise newException(ValueError, "selectTransformIDs not implemented for this backend")

method sanitizeIdentifiers*(backend: Backend, ast: XLangNode): XLangNode {.base.} =
  ## Apply backend-specific identifier sanitization
  raise newException(ValueError, "sanitizeIdentifiers not implemented for this backend")

method getFileExtension*(backend: Backend): string {.base.} =
  ## Get output file extension for the backend
  raise newException(ValueError, "getFileExtension not implemented for this backend")

method getKeywords*(backend: Backend): seq[string] {.base.} =
  ## Get language keywords for identifier conflict detection
  raise newException(ValueError, "getKeywords not implemented for this backend")

method convertFromXLang*(backend: Backend, ast: XLangNode,
                      semanticInfo: SemanticInfo, inputFile: string,
                      verbose: bool): RootRef {.base.} =
  ## Convert XLang AST to backend-specific AST
  raise newException(ValueError, "convertFromXLang not implemented for this backend")

method generateCode*(backend: Backend, backendAst: RootRef, verbose: bool): string {.base.} =
  ## Generate code from backend-specific AST
  raise newException(ValueError, "generateCode not implemented for this backend")

method writeOutput*(backend: Backend, code: string, backendAst: RootRef,
                  xlangAst: XLangNode, ctx: BackendContext) {.base.} =
  ## Write output files
  raise newException(ValueError, "writeOutput not implemented for this backend")
  