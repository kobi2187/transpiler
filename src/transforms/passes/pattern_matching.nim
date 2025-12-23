## Pattern Matching Transformation
##
## Transforms advanced pattern matching (Rust, F#, Haskell, Python 3.10+)
## to Nim case statements or if-elif chains
##
## Examples:
## Rust:
##   match value {
##     Some(x) => x,
##     None => 0
##   }
##
## Nim (if variant object):
##   case value.kind
##   of someOption: value.val
##   of noneOption: 0
##
## Python 3.10+:
##   match point:
##     case (0, 0): "origin"
##     case (x, 0): f"on x-axis at {x}"
##     case _: "somewhere else"

import ../../../xlangtypes
import options
import strutils

type
  PatternKind = enum
    pkLiteral        # Literal value: 42, "hello"
    pkVariable       # Variable binding: x, name
    pkWildcard       # Wildcard: _, default
    pkConstructor    # Constructor: Some(x), Point(x, y)
    pkTuple          # Tuple pattern: (x, y, z)
    pkList           # List pattern: [x, y, rest]
    pkOr             # Or pattern: Red | Blue | Green
    pkGuard          # Pattern with guard: x if x > 0

proc isPatternMatch(node: XLangNode): bool =
  ## Check if this is a pattern match statement
  ## Look for specific indicators that this is pattern matching vs simple switch
  if node.kind == xnkSwitchStmt:
    # Check if any case has complex patterns (not just literals)
    for caseNode in node.switchCases:
      if caseNode.kind == xnkCaseClause:
        for value in caseNode.caseValues:
          # If we see tuple expressions, constructor calls, or other complex patterns
          if value.kind in {xnkTupleExpr, xnkCallExpr, xnkListExpr}:
            return true
  return false

proc transformPattern(pattern: XLangNode, matchExpr: XLangNode): tuple[condition: XLangNode, bindings: seq[XLangNode]] =
  ## Transform a pattern into a condition and variable bindings
  ## Returns: (condition to check, list of variable declarations)

  case pattern.kind
  of xnkIntLit, xnkStringLit, xnkBoolLit:
    # Literal pattern: value == literal
    result.condition = XLangNode(
      kind: xnkBinaryExpr,
      binaryOp: opEqual,
      binaryLeft: matchExpr,
      binaryRight: pattern
    )
    result.bindings = @[]

  of xnkIdentifier:
    # Variable pattern - always matches, binds variable
    # if pattern.identName == "_": # Wildcard
    if pattern.identName == "_":
      # Wildcard - always matches
      result.condition = XLangNode(kind: xnkBoolLit, boolValue: true)
      result.bindings = @[]
    else:
      # Variable binding
      result.condition = XLangNode(kind: xnkBoolLit, boolValue: true)
      result.bindings = @[XLangNode(
        kind: xnkLetDecl,
        declName: pattern.identName,
        declType: none(XLangNode),
        initializer: some(matchExpr)
      )]

  of xnkTupleExpr:
    # Tuple pattern: (x, y, z)
    # Check tuple length and destructure
    var conditions: seq[XLangNode] = @[]
    var bindings: seq[XLangNode] = @[]

    for i, elem in pattern.elements:
      # For each element, recursively transform the pattern
      # Access tuple element: matchExpr[i]
      let elemAccess = XLangNode(
        kind: xnkBracketExpr, # bracket has base/index fields
        base: matchExpr,
        index: XLangNode(kind: xnkIntLit, literalValue: $i)
      )

      let (cond, binds) = transformPattern(elem, elemAccess)
      if cond.kind != xnkBoolLit or not cond.boolValue:
        conditions.add(cond)
      for bb in binds:
        bindings.add(bb)

    # Combine all conditions with 'and'
    if conditions.len == 0:
      result.condition = XLangNode(kind: xnkBoolLit, boolValue: true)
    else:
      result.condition = conditions[0]
      for i in 1..<conditions.len:
        result.condition = XLangNode(
          kind: xnkBinaryExpr,
          binaryOp: opLogicalAnd,
          binaryLeft: result.condition,
          binaryRight: conditions[i]
        )
    result.bindings = bindings

  of xnkCallExpr:
    # Constructor pattern: Some(x), Point(x, y)
    # This maps to variant object checking in Nim
    # Check: matchExpr.kind == ConstructorKind and bind fields

    let constructorName = if pattern.callee.kind == xnkIdentifier:
                           pattern.callee.identName
                         else:
                           ""

    # Create condition: matchExpr.kind == constructorKind
    # (Simplified - real implementation needs to know the kind field)
    result.condition = XLangNode(kind: xnkBoolLit, boolValue: true)  # Placeholder
    result.bindings = @[]

  of xnkListExpr:
    # List pattern: [x, y, ...rest]
    # Similar to tuple but with length check
    result.condition = XLangNode(kind: xnkBoolLit, boolValue: true)  # Placeholder
    result.bindings = @[]

  else:
    # Unknown pattern - treat as always matching
    result.condition = XLangNode(kind: xnkBoolLit, boolValue: true)
    result.bindings = @[]

proc transformPatternMatching*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Transform pattern matching to case statements or if-elif chains
  if node.kind != xnkSwitchStmt:
    return node

  if not isPatternMatch(node):
    return node  # Regular switch, not pattern matching

  # We have pattern matching!
  # Transform to if-elif chain since Nim's case is more limited

  let matchExpr = node.switchExpr
  var currentIf: Option[XLangNode] = none(XLangNode)

  # Process cases in reverse order to build if-elif chain
  for i in countdown(node.switchCases.len - 1, 0):
    let caseNode = node.switchCases[i]

    case caseNode.kind
    of xnkCaseClause:
      # Pattern case
      # Can have multiple patterns with OR semantics
      var caseConditions: seq[XLangNode] = @[]
      var allBindings: seq[seq[XLangNode]] = @[]

      for pattern in caseNode.caseValues:
        let (condition, bindings) = transformPattern(pattern, matchExpr)
        caseConditions.add(condition)
        allBindings.add(bindings)

      # Combine patterns with OR
      var finalCondition = caseConditions[0]
      for j in 1..<caseConditions.len:
        finalCondition = XLangNode(
          kind: xnkBinaryExpr,
          binaryOp: opLogicalOr,
          binaryLeft: finalCondition,
          binaryRight: caseConditions[j]
        )

      # Build case body with bindings
      var bodyStmts: seq[XLangNode] = @[]
      if allBindings.len > 0:
        for bbb in allBindings[0]:
          bodyStmts.add(bbb)  # copy the first pattern's bindings

      if caseNode.caseBody.kind == xnkBlockStmt:
        for cbb in caseNode.caseBody.blockBody:
          bodyStmts.add(cbb)
      else:
        bodyStmts.add(caseNode.caseBody)

      let caseBody = XLangNode(kind: xnkBlockStmt, blockBody: bodyStmts)

      # Build if statement
      let ifStmt = XLangNode(
        kind: xnkIfStmt,
        ifCondition: finalCondition,
        ifBody: caseBody,
        elseBody: currentIf
      )
      currentIf = some(ifStmt)

    of xnkDefaultClause:
      # Default case - becomes final else
      currentIf = some(caseNode.defaultBody)

    else:
      discard

  result = currentIf.get(node)  # Return the if-elif chain, or original if empty
