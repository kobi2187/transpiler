## LINQ to Sequtils Transformation
##
## Transforms C# LINQ queries to Nim sequtils/algorithm operations or for loops
##
## Examples:
## - people.Where(p => p.Age >= 18) → people.filter(proc(p: Person): bool = p.age >= 18)
## - items.Select(x => x.Name) → items.map(proc(x: Item): string = x.name)
## - numbers.OrderBy(x => x) → numbers.sorted()
## - people.GroupBy(p => p.City) → for loop with Table grouping

import core/xlangtypes
import transforms/transform_context
import options
import strutils
import tables

type
  LinqMethod = enum
    lmWhere,      # Filter elements
    lmSelect,     # Map/transform elements
    lmOrderBy,    # Sort ascending
    lmOrderByDescending,  # Sort descending
    lmGroupBy,    # Group by key
    lmFirst,      # Get first element
    lmLast,       # Get last element
    lmCount,      # Count elements
    lmAny,        # Check if any match
    lmAll,        # Check if all match
    lmSum,        # Sum values
    lmDistinct,   # Get distinct values
    lmTake,       # Take first N
    lmSkip,       # Skip first N
    lmToList,     # Materialize to list (often no-op in Nim)
    lmToArray,    # Materialize to array
    lmUnknown

proc identifyLinqMethod(methodName: string): LinqMethod =
  ## Identify which LINQ method is being called
  case methodName.toLowerAscii
  of "where": lmWhere
  of "select": lmSelect
  of "orderby": lmOrderBy
  of "orderbydescending": lmOrderByDescending
  of "groupby": lmGroupBy
  of "first": lmFirst
  of "last": lmLast
  of "count": lmCount
  of "any": lmAny
  of "all": lmAll
  of "sum": lmSum
  of "distinct": lmDistinct
  of "take": lmTake
  of "skip": lmSkip
  of "tolist": lmToList
  of "toarray": lmToArray
  else: lmUnknown

proc isLinqMethodCall(node: XLangNode): bool =
  ## Check if this is a LINQ-style method call
  if node.kind != xnkCallExpr:
    return false

  # LINQ calls are method calls on collections
  # They look like: collection.Method(lambda)
  if node.callee.kind != xnkMemberAccessExpr:
    return false

  let methodName = node.callee.memberName
  return identifyLinqMethod(methodName) != lmUnknown

proc transformLinqToSequtils*(node: XLangNode, ctx: TransformContext): XLangNode =
  ## Transform LINQ method chains to Nim sequtils/algorithm operations
  if not isLinqMethodCall(node):
    return node

  # We have a LINQ call!
  # node is: collection.Method(args)
  # node.callee is: collection.Method (MemberAccessExpr)
  # node.callee.memberExpr is: collection
  # node.callee.memberName is: "Method"
  # node.args are the arguments

  let collection = node.callee.memberExpr
  let methodName = node.callee.memberName
  let linqMethod = identifyLinqMethod(methodName)
  let args = node.args

  case linqMethod
  of lmWhere:
    # collection.Where(predicate) → collection.filter(predicate)
    result = XLangNode(
      kind: xnkCallExpr,
      callee: XLangNode(
        kind: xnkMemberAccessExpr,
        memberExpr: collection,
        memberName: "filter"
      ),
      args: args
    )

  of lmSelect:
    # collection.Select(selector) → collection.map(selector)
    result = XLangNode(
      kind: xnkCallExpr,
      callee: XLangNode(
        kind: xnkMemberAccessExpr,
        memberExpr: collection,
        memberName: "map"
      ),
      args: args
    )

  of lmOrderBy:
    # collection.OrderBy(keySelector) → collection.sorted(keySelector)
    # Or if no argument: collection.sorted()
    if args.len == 0:
      result = XLangNode(
        kind: xnkCallExpr,
        callee: XLangNode(
          kind: xnkMemberAccessExpr,
          memberExpr: collection,
          memberName: "sorted"
        ),
        args: @[]
      )
    else:
      # sorted takes a cmp function, not a key selector
      # This is more complex - for now, just use sorted
      result = XLangNode(
        kind: xnkCallExpr,
        callee: XLangNode(
          kind: xnkMemberAccessExpr,
          memberExpr: collection,
          memberName: "sortedByIt"  # sequtils.sortedByIt for key selector
        ),
        args: args
      )

  of lmOrderByDescending:
    # collection.OrderByDescending(keySelector) → collection.sorted(..., Descending)
    result = XLangNode(
      kind: xnkCallExpr,
      callee: XLangNode(
        kind: xnkMemberAccessExpr,
        memberExpr: collection,
        memberName: "sorted"
      ),
      args: args & @[XLangNode(kind: xnkIdentifier, identName: "Descending")]
    )

  of lmFirst:
    # collection.First() → collection[0]
    # collection.First(predicate) → collection.filterIt(predicate)[0]
    if args.len == 0:
      result = XLangNode(
        kind: xnkIndexExpr,
        indexExpr: collection,
        indexArgs: @[XLangNode(kind: xnkIntLit, literalValue: "0")]
      )
    else:
      # First with predicate
      let filtered = XLangNode(
        kind: xnkCallExpr,
        callee: XLangNode(
          kind: xnkMemberAccessExpr,
          memberExpr: collection,
          memberName: "filterIt"
        ),
        args: args
      )
      result = XLangNode(
        kind: xnkIndexExpr,
        indexExpr: filtered,
        indexArgs: @[XLangNode(kind: xnkIntLit, literalValue: "0")]
      )

  of lmLast:
    # collection.Last() → collection[^1]
    result = XLangNode(
      kind: xnkIndexExpr,
      indexExpr: collection,
      indexArgs: @[XLangNode(
        kind: xnkUnaryExpr,
        unaryOp: opNegate,
        unaryOperand: XLangNode(kind: xnkIntLit, literalValue: "1")
      )]
    )

  of lmCount:
    # collection.Count() → collection.len
    # collection.Count(predicate) → collection.countIt(predicate)
    if args.len == 0:
      result = XLangNode(
        kind: xnkMemberAccessExpr,
        memberExpr: collection,
        memberName: "len"
      )
    else:
      result = XLangNode(
        kind: xnkCallExpr,
        callee: XLangNode(
          kind: xnkMemberAccessExpr,
          memberExpr: collection,
          memberName: "countIt"
        ),
        args: args
      )

  of lmAny:
    # collection.Any(predicate) → collection.anyIt(predicate)
    result = XLangNode(
      kind: xnkCallExpr,
      callee: XLangNode(
        kind: xnkMemberAccessExpr,
        memberExpr: collection,
        memberName: "anyIt"
      ),
      args: args
    )

  of lmAll:
    # collection.All(predicate) → collection.allIt(predicate)
    result = XLangNode(
      kind: xnkCallExpr,
      callee: XLangNode(
        kind: xnkMemberAccessExpr,
        memberExpr: collection,
        memberName: "allIt"
      ),
      args: args
    )

  of lmSum:
    # collection.Sum() → collection.sum
    # collection.Sum(selector) → collection.mapIt(selector).sum
    if args.len == 0:
      result = XLangNode(
        kind: xnkCallExpr,
        callee: XLangNode(
          kind: xnkMemberAccessExpr,
          memberExpr: collection,
          memberName: "sum"
        ),
        args: @[]
      )
    else:
      let mapped = XLangNode(
        kind: xnkCallExpr,
        callee: XLangNode(
          kind: xnkMemberAccessExpr,
          memberExpr: collection,
          memberName: "mapIt"
        ),
        args: args
      )
      result = XLangNode(
        kind: xnkCallExpr,
        callee: XLangNode(
          kind: xnkMemberAccessExpr,
          memberExpr: mapped,
          memberName: "sum"
        ),
        args: @[]
      )

  of lmDistinct:
    # collection.Distinct() → collection.deduplicate
    result = XLangNode(
      kind: xnkCallExpr,
      callee: XLangNode(
        kind: xnkMemberAccessExpr,
        memberExpr: collection,
        memberName: "deduplicate"
      ),
      args: @[]
    )

  of lmTake:
    # collection.Take(n) → collection[0..<n]
    if args.len > 0:
      result = XLangNode(
        kind: xnkSliceExpr,
        sliceExpr: collection,
        sliceStart: some(XLangNode(kind: xnkIntLit, literalValue: "0")),
        sliceEnd: some(args[0]),
        sliceStep: none(XLangNode)
      )
    else:
      result = node

  of lmSkip:
    # collection.Skip(n) → collection[n..^1]
    if args.len > 0:
      result = XLangNode(
        kind: xnkSliceExpr,
        sliceExpr: collection,
        sliceStart: some(args[0]),
        sliceEnd: none(XLangNode),  # To end
        sliceStep: none(XLangNode)
      )
    else:
      result = node

  of lmToList, lmToArray:
    # collection.ToList() → collection (no-op in Nim, seqs are the default)
    # Just return the collection
    result = collection

  of lmGroupBy:
    # GroupBy is complex - would need to transform to Table-based code
    # For now, keep as-is and handle in a more sophisticated way later
    result = node

  of lmUnknown:
    result = node
