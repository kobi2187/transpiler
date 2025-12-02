## Go Implicit Interfaces to Nim Concepts
##
## Transforms Go's implicit interface satisfaction to Nim's explicit concepts
##
## Go:
##   type Reader interface {
##     Read(p []byte) (n int, err error)
##   }
##   // Any type with Read method automatically satisfies Reader
##
## Nim:
##   type Reader = concept r
##     r.read(p: var seq[byte]): int
##   # Types must explicitly match the concept

import ../../xlangtypes
import options
import strutils

proc transformGoInterface*(node: XLangNode): XLangNode =
  ## Transform Go interface to Nim concept
  ##
  ## Go interfaces are structural (duck typing)
  ## Nim concepts are also structural but more powerful
  ##
  ## Key differences:
  ## - Go: implicit satisfaction (if it has the methods, it implements)
  ## - Nim: explicit concept matching

  if node.kind != xnkInterfaceDecl:
    return node

  let interfaceName = node.typeNameDecl
  let methods = node.members

  # Transform to Nim concept
  # concept TypeName =
  #   concept x
  #     x.method1(...): RetType
  #     x.method2(...): RetType

  var conceptRequirements: seq[XLangNode] = @[]

  for member in methods:
    # Each member becomes a concept requirement
    # Transform member signature to concept requirement

    if member.kind in {xnkFuncDecl, xnkMethodDecl}:
      # Create concept requirement: x.methodName(params): RetType
      let requirement = XLangNode(
        kind: xnkConceptRequirement,
        reqName: member.funcName,
        reqParams: member.params,
        reqReturn: member.returnType
      )

      conceptRequirements.add(requirement)

      result = XLangNode(
        kind: xnkConceptDecl,
        conceptDeclName: interfaceName,
        conceptRequirements: conceptRequirements
      )
# Empty interface transformation
# Go: interface{} means "any type"
# Nim: use generics or RootRef

proc transformEmptyInterfaceDecl*(node: XLangNode): XLangNode =
  ## Transform Go's empty interface declaration
  ##
  ## Go: type Any interface{} or interface{}
  ## Nim: type Any = concept x; true  # Matches anything
  ##  or: type Any = RootRef

  if node.kind != xnkInterfaceDecl:
    return node

  if node.members.len == 0:
    # Empty interface - matches any type

    # Option 1: Use concept that always matches
    result = XLangNode(
      kind: xnkConceptDecl,
      conceptDeclName: node.typeNameDecl,
      conceptRequirements: @[
        XLangNode(
          kind: xnkConceptRequirement,
          reqName: "true",  # Special: always matches
          reqParams: @[],
          reqReturn: none(XLangNode)
        )
      ]
    )

    # Option 2: Type alias to RootRef
    # result = XLangNode(
    #   kind: xnkTypeDecl,
    #   typeDefName: node.interfaceName,
    #   typeDefBody: XLangNode(kind: xnkNamedType, typeName: "RootRef")
    # )
  else:
    result = node

# Embedded interfaces
# Go allows interface embedding (composition)
# type ReadWriter interface { Reader; Writer }

proc transformEmbeddedInterface*(node: XLangNode): XLangNode =
  ## Transform Go embedded interfaces
  ##
  ## Go:
  ##   type ReadWriter interface {
  ##     Reader
  ##     Writer
  ##   }
  ##
  ## Nim:
  ##   type ReadWriter = concept rw
  ##     rw is Reader
  ##     rw is Writer

  if node.kind != xnkInterfaceDecl:
    return node

  # Check for embedded interfaces in the interface body
  var requirements: seq[XLangNode] = @[]
  var embeddedInterfaces: seq[XLangNode] = @[]

  for item in node.members:
    if item.kind == xnkNamedType:
      # This is an embedded interface
      embeddedInterfaces.add(item)
    else:
      # Regular method
      requirements.add(item)

  if embeddedInterfaces.len == 0:
    return node  # No embedded interfaces

  # Build concept with embedded type requirements
  for embedded in embeddedInterfaces:
    requirements.add(XLangNode(
      kind: xnkConceptRequirement,
      reqName: "is",  # Special: type requirement
      reqParams: @[embedded],
      reqReturn: none(XLangNode)
    ))

  result = XLangNode(
    kind: xnkConceptDecl,
    conceptDeclName: node.typeNameDecl,
    conceptRequirements: requirements
  )

# Interface assertion in variable declarations
# Go: var r io.Reader = &bytes.Buffer{}
# Nim concepts work differently - no explicit "implements" needed

proc transformInterfaceVariable*(node: XLangNode): XLangNode =
  ## Transform variables with interface types
  ##
  ## In Go, you can assign any type to interface if it satisfies
  ## In Nim, concepts constrain generic parameters

  if node.kind notin {xnkVarDecl, xnkLetDecl}:
    return node

  # If declared type is interface/concept, the value must satisfy it
  # Nim's type system handles this automatically
  # No transformation needed

  result = node

# Method sets in Go
# Go has special rules about pointer receivers and interfaces
# Type T has methods on T
# Type *T has methods on both T and *T

proc transformMethodSet*(node: XLangNode): XLangNode =
  ## Handle Go's method set rules
  ##
  ## If concept requires method on pointer receiver,
  ## need to ensure type compatibility

  # This is complex and requires type system analysis
  # Placeholder for now

  result = node

# Interface comparison and type assertions
# Go allows interface{} equality comparison
# Nim concepts don't support this directly

# Main transformation
proc transformGoImplicitInterfaces*(node: XLangNode): XLangNode =
  ## Main interface-to-concept transformation

  case node.kind
  of xnkInterfaceDecl:
    # Check for empty interface first
    let emptyResult = transformEmptyInterfaceDecl(node)
    if emptyResult.kind != xnkInterfaceDecl:
      return emptyResult

    # Check for embedded interfaces
    let embeddedResult = transformEmbeddedInterface(node)
    if embeddedResult != node:
      return embeddedResult

    # Regular interface
    return transformGoInterface(node)

  else:
    return node
