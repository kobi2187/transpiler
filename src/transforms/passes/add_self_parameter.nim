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
        # Skip static functions - they don't need self parameter
        if member.funcIsStatic:
          newMembers.add(member)
          continue

        # Add self parameter as first parameter for instance methods
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
      elif member.kind == xnkMethodDecl:
        # Methods already have receiver info - don't add self parameter
        newMembers.add(member)
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
