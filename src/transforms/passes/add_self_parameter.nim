## Add Self Parameter Transformation
##
## Adds 'self' parameter to instance methods and 'result' to constructors
##
## C# instance method: public int GetValue() { return this.value; }
## Nim: proc getValue(self: MyType): int = return self.value
##
## C# constructor: public MyType(int x) { this.value = x; }
## Nim: proc newMyType(x: int): MyType = result = MyType(); result.value = x

import ../../../xlangtypes
import options
import strutils

proc addSelfParameter*(node: XLangNode): XLangNode {.noSideEffect, gcsafe.} =
  ## Add self parameter to instance methods in classes/structs
  case node.kind
  of xnkClassDecl, xnkStructDecl:
    # Process members and add self parameter to instance methods
    var newMembers: seq[XLangNode] = @[]
    let typeName = node.typeNameDecl

    for member in node.members:
      if member.kind == xnkFuncDecl:
        # Check if this is a static method (would have metadata)
        # For now, assume all methods need self parameter
        # TODO: Check for static modifier

        # Add self parameter as first parameter
        let selfParam = XLangNode(
          kind: xnkParameter,
          paramName: "self",
          paramType: some(XLangNode(
            kind: xnkNamedType,
            typeName: typeName
          )),
          defaultValue: none(XLangNode)
        )

        var newParams = @[selfParam]
        newParams.add(member.params)

        var newMember = member
        newMember.params = newParams
        newMembers.add(newMember)
      elif member.kind == xnkConstructorDecl:
        # Constructors don't need self, but we need to track that result is available
        # This is handled by the Nim code generator
        newMembers.add(member)
      else:
        newMembers.add(member)

    result = node
    result.members = newMembers

  else:
    result = node
