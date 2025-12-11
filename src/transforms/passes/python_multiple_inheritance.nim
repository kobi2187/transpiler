## Python Multiple Inheritance to Nim Composition
##
## Transforms Python's multiple inheritance to Nim's single inheritance + composition
##
## Python:
##   class Animal:
##     def eat(self): pass
##   class Flyer:
##     def fly(self): pass
##   class Bird(Animal, Flyer):
##     pass
##
## Nim (composition):
##   type
##     Animal = ref object of RootObj
##     Flyer = ref object of RootObj
##     Bird = ref object of Animal  # Inherit first base
##       flyerMixin: Flyer  # Compose others
##
##   # Forward methods from Flyer
##   proc fly(self: Bird) = self.flyerMixin.fly()

import ../../xlangtypes
import options
import strutils
import sequtils

proc hasMultipleInheritance*(node: XLangNode): bool =
  ## Check if class has multiple base classes
  if node.kind != xnkClassDecl:
    return false

  return node.baseTypes.len > 1

proc transformMultipleInheritance*(node: XLangNode): XLangNode =
  ## Transform multiple inheritance to single inheritance + composition
  ##
  ## Strategy:
  ## 1. Inherit from first base class
  ## 2. Compose other base classes as fields (mixins)
  ## 3. Generate forwarding methods for mixin methods

  if not hasMultipleInheritance(node):
    return node

  let className = node.typeNameDecl
  let baseTypes = node.baseTypes
  let members = node.members

  # First base becomes inheritance
  let primaryBase = baseTypes[0]

  # Other bases become composition fields
  var mixinFields: seq[XLangNode] = @[]
  var mixinTypes: seq[XLangNode] = @[]

  for i in 1..<baseTypes.len:
    let baseType = baseTypes[i]

    # Create field for mixin
    let fieldName = if baseType.kind == xnkNamedType:
                      baseType.typeName.toLowerAscii() & "Mixin"
                    else:
                      "mixin" & $i

    let mixinField = XLangNode(
      kind: xnkFieldDecl,
      fieldName: fieldName,
      fieldType: baseType,
      fieldInitializer: none(XLangNode)
    )

    mixinFields.add(mixinField)
    mixinTypes.add(baseType)

  # Create class with single inheritance + mixin fields
  result = XLangNode(
    kind: xnkClassDecl,
    typeNameDecl: className,
    baseTypes: @[primaryBase],  # Only first base
    members: mixinFields & members  # Add mixin fields + original members
  )

  # Note: Ideally we'd also generate forwarding methods
  # for methods from mixin base classes
  # This requires method resolution analysis

proc generateForwardingMethods*(
  className: string,
  mixinField: string,
  mixinType: XLangNode,
  mixinMethods: seq[XLangNode]
): seq[XLangNode] =
  ## Generate forwarding methods for mixin
  ##
  ## For each method in mixin, create:
  ## proc methodName(self: ClassName, args) =
  ##   self.mixinField.methodName(args)

  result = @[]

  for mixinMethod in mixinMethods:
    if mixinMethod.kind != xnkFuncDecl and mixinMethod.kind != xnkMethodDecl:
      continue

    # Create forwarding method
    var forwardingParams = mixinMethod.mparams

    # Change self parameter to className type
    if forwardingParams.len > 0 and forwardingParams[0].kind == xnkParameter:
      if forwardingParams[0].paramName == "self":
        forwardingParams[0].paramType = some(XLangNode(
          kind: xnkNamedType,
          typeName: className
        ))

    # Build forwarding call: self.mixinField.method(args)
    let selfMixinAccess = XLangNode(
      kind: xnkMemberAccessExpr,
      memberExpr: XLangNode(kind: xnkIdentifier, identName: "self"),
      memberName: mixinField
    )

    let mixinMethodAccess = XLangNode(
      kind: xnkMemberAccessExpr,
      memberExpr: selfMixinAccess,
      memberName: mixinMethod.methodName
    )

    # Get args (skip self)
    var callArgs: seq[XLangNode] = @[]
    for i in 1..<forwardingParams.len:
      if forwardingParams[i].kind == xnkParameter:
        callArgs.add(XLangNode(
          kind: xnkIdentifier,
          identName: forwardingParams[i].paramName
        ))

    let forwardingCall = XLangNode(
      kind: xnkCallExpr,
      callee: mixinMethodAccess,
      args: callArgs
    )

    # Create forwarding method
    let forwardingMethod = XLangNode(
      kind: xnkMethodDecl,
      methodName: mixinMethod.methodName,
      mparams: forwardingParams,
      mreturnType: mixinMethod.mreturnType,
      mbody: XLangNode(
        kind: xnkBlockStmt,
        blockBody: @[forwardingCall]
      ),
      methodIsAsync: mixinMethod.methodIsAsync
    )

    result.add(forwardingMethod)

# Method Resolution Order (MRO) in Python
# Python uses C3 linearization to determine method lookup order
# This is complex - for now, we'll use simple left-to-right

proc analyzeMRO*(baseTypes: seq[XLangNode]): seq[XLangNode] =
  ## Analyze Method Resolution Order
  ##
  ## Python uses C3 linearization
  ## For simplicity, we use left-to-right order

  result = baseTypes

# Mixin classes (Python convention)
# Classes designed to be mixed in, not standalone

proc isMixinClass*(className: string): bool =
  ## Check if class name suggests it's a mixin
  ## Convention: class name ends with "Mixin"

  result = className.endsWith("Mixin")

# Abstract Base Classes (ABC) in multiple inheritance
# Python's ABC module + multiple inheritance

proc transformABCMultipleInheritance*(node: XLangNode): XLangNode =
  ## Handle multiple inheritance involving abstract base classes
  ##
  ## If one base is ABC, it should become the primary inheritance
  ## Others become mixins

  if not hasMultipleInheritance(node):
    return node

  var abcBase: Option[int] = none(int)

  # Find ABC base (would need metadata)
  # For now, use heuristic: class name starts with "Abstract"

  for i, baseType in node.baseTypes:
    if baseType.kind == xnkNamedType:
      if baseType.typeName.startsWith("Abstract") or
         baseType.typeName.startsWith("I"):  # Interface convention
        abcBase = some(i)
        break

  if abcBase.isNone:
    return transformMultipleInheritance(node)

  # Reorder bases to put ABC first
  var reorderedBases = node.baseTypes
  let abcIndex = abcBase.get

  if abcIndex != 0:
    # Swap ABC to first position
    let temp = reorderedBases[0]
    reorderedBases[0] = reorderedBases[abcIndex]
    reorderedBases[abcIndex] = temp

  # Create modified node with reordered bases
  var modifiedNode = node
  modifiedNode.baseTypes = reorderedBases

  return transformMultipleInheritance(modifiedNode)

# Diamond problem in multiple inheritance
# Python resolves this with MRO
# Nim avoids it with single inheritance

proc detectDiamondInheritance*(node: XLangNode): bool =
  ## Detect if class has diamond inheritance problem
  ##
  ## Diamond: class D(B, C) where both B and C inherit from A
  ##
  ## This requires full class hierarchy analysis
  ## Placeholder for now

  result = false

# Cooperative multiple inheritance (super() in Python)
# Python's super() works with MRO
# In Nim composition, need explicit calls

proc transformSuperCallWithMI*(node: XLangNode): XLangNode =
  ## Transform super() calls in multiple inheritance context
  ##
  ## Python: super().method()
  ## Nim: procCall Base(self).method() for first base
  ##       self.mixinField.method() for others

  # This requires context about which method is being called
  # and which base provides it

  result = node  # Placeholder

# Main transformation
proc transformPythonMultipleInheritance*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Main multiple inheritance transformation

  case node.kind
  of xnkClassDecl:
    # Check for ABC multiple inheritance first
    let abcResult = transformABCMultipleInheritance(node)
    if abcResult != node:
      return abcResult

    # Regular multiple inheritance
    return transformMultipleInheritance(node)

  else:
    return node
