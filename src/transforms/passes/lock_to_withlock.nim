## Lock Statement Transformation
##
## Transforms C#'s lock statement to Nim's locks module withLock template
##
## C#:
##   lock (myLock)
##   {
##     // critical section
##   }
##
## Nim:
##   import locks
##   withLock myLock:
##     # critical section
##
## Note: This requires that the lock object is a Nim Lock type
## C# objects need to be wrapped in a Lock

import ../../xlangtypes
import ../../semantic/semantic_analysis
import options

proc transformLockStatement*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform C# lock statements to Nim's withLock template
  ##
  ## C#'s lock ensures mutual exclusion on an object
  ## Nim's locks module provides Lock type and withLock template

  if node.kind != xnkLockStmt:
    return node

  # C# lock statement:
  # lock (lockObject) { body }

  # Extract the lock expression and body
  let lockExpr = node.lockExpr
  let lockBody = node.lockBody

  # In Nim, we use withLock template:
  # withLock lockVar:
  #   body

  # Note: The C# object needs to be a Nim Lock type
  # This transformation assumes proper lock setup

  # Build call to withLock template
  # withLock is a template that takes lock and body
  result = XLangNode(
    kind: xnkCallExpr,
    callee: XLangNode(kind: xnkIdentifier, identName: "withLock"),
    args: @[
      lockExpr,
      XLangNode(
        kind: xnkStmtListExpr,
        stmtListBody: if lockBody.kind == xnkBlockStmt: lockBody.blockBody else: @[lockBody]
      )
    ]
  )

  # Alternative: use acquire/release pattern with defer
  # This is more explicit but also more verbose:
  #
  # lockVar.acquire()
  # defer: lockVar.release()
  # body
  #
  # We could make this configurable

proc transformLockToAcquireRelease*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Alternative transformation using explicit acquire/release with defer
  ## This is more explicit and doesn't require the withLock template

  if node.kind != xnkLockStmt:
    return node

  let lockExpr = node.lockExpr
  let lockBody = node.lockBody

  var stmts: seq[XLangNode] = @[]

  # 1. Acquire the lock
  stmts.add(XLangNode(
    kind: xnkCallExpr,
    callee: XLangNode(
      kind: xnkMemberAccessExpr,
      memberExpr: lockExpr,
      memberName: "acquire"
    ),
    args: @[]
  ))

  # 2. Defer release
  stmts.add(XLangNode(
    kind: xnkDeferStmt,
    staticBody: XLangNode(
      kind: xnkCallExpr,
      callee: XLangNode(
        kind: xnkMemberAccessExpr,
        memberExpr: lockExpr,
        memberName: "release"
      ),
      args: @[]
    )
  ))

  # 3. Body
  if lockBody.kind == xnkBlockStmt:
    stmts.add(lockBody.blockBody)
  else:
    stmts.add(lockBody)

  result = XLangNode(
    kind: xnkBlockStmt,
    blockBody: stmts
  )

# Usage note:
# In Nim, you'll need to:
# 1. Import locks module: import std/locks
# 2. Declare locks: var myLock: Lock
# 3. Initialize locks: initLock(myLock)
# 4. Destroy locks when done: deinitLock(myLock)
#
# C# objects used in lock statements need to be converted to Lock types
