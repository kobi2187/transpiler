## Transpiler Error Handling
##
## Centralized error collection and reporting for the transpiler

# import strutils

type
  TranspilerErrorKind* = enum
    ## Different kinds of errors that can occur
    tekParseError        ## Error parsing input JSON
    tekValidationError   ## XLang AST validation error
    tekTransformError    ## Error during transformation pass
    tekTransformLimitReachedError
    tekConversionError   ## Error converting XLang to Nim AST
    tekCodegenError      ## Error generating Nim code

  TranspilerError* = object
    ## A single error that occurred during transpilation
    kind*: TranspilerErrorKind
    message*: string
    location*: string  ## File/location where error occurred
    details*: string   ## Additional details

  ErrorCollector* = ref object
    ## Collects errors during transpilation
    errors*: seq[TranspilerError]
    warnings*: seq[TranspilerError]

proc newErrorCollector*(): ErrorCollector =
  ## Create a new error collector
  ErrorCollector(
    errors: @[],
    warnings: @[]
  )

proc addError*(ec: ErrorCollector, kind: TranspilerErrorKind, message: string,
               location: string = "", details: string = "") =
  ## Add an error to the collector
  ec.errors.add(TranspilerError(
    kind: kind,
    message: message,
    location: location,
    details: details
  ))

proc addWarning*(ec: ErrorCollector, kind: TranspilerErrorKind, message: string,
                 location: string = "", details: string = "") =
  ## Add a warning to the collector
  ec.warnings.add(TranspilerError(
    kind: kind,
    message: message,
    location: location,
    details: details
  ))

proc hasErrors*(ec: ErrorCollector): bool =
  ## Check if any errors have been collected
  ec.errors.len > 0

proc hasWarnings*(ec: ErrorCollector): bool =
  ## Check if any warnings have been collected
  ec.warnings.len > 0

proc getErrorCount*(ec: ErrorCollector): int =
  ## Get number of errors
  ec.errors.len

proc getWarningCount*(ec: ErrorCollector): int =
  ## Get number of warnings
  ec.warnings.len

proc formatError(err: TranspilerError, prefix: string): string =
  ## Format a single error message
  result = prefix & ": " & $err.kind & " - " & err.message
  if err.location != "":
    result &= "\n  Location: " & err.location
  if err.details != "":
    result &= "\n  Details: " & err.details

proc reportAndExit*(ec: ErrorCollector) =
  ## Report all collected errors and warnings, then exit with failure status
  ## This is called when critical errors prevent continuation

  # Report warnings first
  if ec.hasWarnings():
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║                      WARNINGS                         ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo ""
    for i, warning in ec.warnings:
      echo formatError(warning, "WARNING " & $(i+1))
      echo ""

  # Report errors
  if ec.hasErrors():
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║                       ERRORS                          ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo ""
    for i, error in ec.errors:
      echo formatError(error, "ERROR " & $(i+1))
      echo ""

    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║  Transpilation failed with ", ec.getErrorCount(), " error(s)"
    if ec.hasWarnings():
      echo "║  and ", ec.getWarningCount(), " warning(s)"
    echo "╚═══════════════════════════════════════════════════════╝"

    quit(1)  # Exit with failure status

proc reportSummary*(ec: ErrorCollector) =
  ## Report summary of warnings (if any) without exiting
  ## Used for successful transpilation that had warnings
  if ec.hasWarnings():
    echo ""
    echo "Transpilation completed with ", ec.getWarningCount(), " warning(s)"
    echo "Run with -v for details"
