## Backend Types
##
## Common types and concept (interface) for output language backends.
## Each backend (Nim, Go, Rust, etc.) must implement the BackendOps concept.

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

# Backend Concept (compile-time interface)
# Any type that implements these procedures can be used as a backend
type
  BackendOps* = concept b
    ## Compile-time interface that all backends must implement

    # Get backend metadata
    b.getFileExtension() is string
    b.getKeywords() is seq[string]
    b.selectTransformIDs() is seq[TransformPassID]

    # Transform operations
    b.sanitizeIdentifiers(XLangNode) is XLangNode

    # AST conversion (returns backend-specific AST type)
    # Note: Each backend can return its own AST type
    b.convertFromXLang(XLangNode, SemanticInfo, string, bool)

    # Code generation (takes backend AST, returns code string)
    # Note: First parameter type matches return type of convertFromXLang
    # b.generateCode(b.convertFromXLang(...), bool) is string

    # Output writing
    # b.writeOutput(string, backendAST, XLangNode, BackendContext)
