import my_nim_node


# High-level builders for transpilers
# These provide a convenient API for building complete declarations

proc buildProcDef*(name: string, params: openArray[tuple[name, typ: string]],
                   returnType: string = "", body: MyNimNode = nil,
                   pragmas: MyNimNode = nil, exported: bool = false): MyNimNode =
  ## High-level proc builder for transpilers
  ##
  ## Example:
  ##   buildProcDef("greet", [("name", "string")], "", bodyStmts)
  ##   buildProcDef("add", [("a", "int"), ("b", "int")], "int", bodyStmts, exported = true)
  result = newMyNimNode(nnkProcDef)

  # 0: name (possibly with export marker)
  let nameNode = newIdentNode(name)
  if exported:
    result.sons.add(newPostfixExport(nameNode))
  else:
    result.sons.add(nameNode)

  result.sons.add(newEmptyNode())  # 1: patterns/term rewriting
  result.sons.add(newEmptyNode())  # 2: generic params

  # 3: formal params
  let formalParams = newMyNimNode(nnkFormalParams)
  if returnType == "":
    formalParams.sons.add(newEmptyNode())  # no return type
  else:
    formalParams.sons.add(newIdentNode(returnType))

  for (pname, ptyp) in params:
    formalParams.sons.add(newIdentDefs(
      newIdentNode(pname),
      if ptyp == "": newEmptyNode() else: newIdentNode(ptyp),
      newEmptyNode()
    ))
  result.sons.add(formalParams)

  # 4: pragma
  if pragmas != nil:
    result.sons.add(pragmas)
  else:
    result.sons.add(newEmptyNode())

  result.sons.add(newEmptyNode())  # 5: reserved

  # 6: body
  if body != nil:
    result.sons.add(body)
  else:
    result.sons.add(newStmtList())

proc buildFuncDef*(name: string, params: openArray[tuple[name, typ: string]],
                   returnType: string = "", body: MyNimNode = nil,
                   exported: bool = false): MyNimNode =
  ## High-level func builder (like proc but implicitly {.noSideEffect.})
  result = newMyNimNode(nnkFuncDef)

  let nameNode = newIdentNode(name)
  if exported:
    result.sons.add(newPostfixExport(nameNode))
  else:
    result.sons.add(nameNode)

  result.sons.add(newEmptyNode())  # 1: patterns
  result.sons.add(newEmptyNode())  # 2: generic params

  # 3: formal params
  let formalParams = newMyNimNode(nnkFormalParams)
  if returnType == "":
    formalParams.sons.add(newEmptyNode())
  else:
    formalParams.sons.add(newIdentNode(returnType))

  for (pname, ptyp) in params:
    formalParams.sons.add(newIdentDefs(
      newIdentNode(pname),
      if ptyp == "": newEmptyNode() else: newIdentNode(ptyp),
      newEmptyNode()
    ))
  result.sons.add(formalParams)

  result.sons.add(newEmptyNode())  # 4: pragma
  result.sons.add(newEmptyNode())  # 5: reserved

  # 6: body
  if body != nil:
    result.sons.add(body)
  else:
    result.sons.add(newStmtList())

proc addParam*(procNode: MyNimNode, name, typ: string, default: MyNimNode = nil) =
  ## Add a parameter to an existing proc/func definition
  ## Useful for building procs incrementally
  assert procNode.kind in {nnkProcDef, nnkFuncDef, nnkMethodDef, nnkIteratorDef,
                           nnkMacroDef, nnkTemplateDef}

  if procNode[3].kind == nnkEmpty:
    # Initialize formal params if empty
    procNode[3] = newMyNimNode(nnkFormalParams)
    procNode[3].sons.add(newEmptyNode())  # return type

  let defaultVal = if default == nil: newEmptyNode() else: default
  procNode[3].sons.add(newIdentDefs(
    newIdentNode(name),
    if typ == "": newEmptyNode() else: newIdentNode(typ),
    defaultVal
  ))

proc setReturnType*(procNode: MyNimNode, typ: string) =
  ## Set the return type of a proc/func definition
  assert procNode.kind in {nnkProcDef, nnkFuncDef, nnkMethodDef, nnkIteratorDef}

  if procNode[3].kind == nnkEmpty:
    procNode[3] = newMyNimNode(nnkFormalParams)
    procNode[3].sons.add(newEmptyNode())

  procNode[3][0] = if typ == "": newEmptyNode() else: newIdentNode(typ)

proc setBody*(procNode: MyNimNode, body: MyNimNode) =
  ## Set the body of a proc/func/method definition
  assert procNode.kind in {nnkProcDef, nnkFuncDef, nnkMethodDef, nnkIteratorDef,
                           nnkMacroDef, nnkTemplateDef}
  procNode[6] = body

proc setPragma*(procNode: MyNimNode, pragma: MyNimNode) =
  ## Set pragma on a proc/func definition
  assert procNode.kind in {nnkProcDef, nnkFuncDef, nnkMethodDef, nnkIteratorDef}
  procNode[4] = pragma

proc buildObjectDef*(name: string, fields: openArray[tuple[name, typ: string]],
                     exported: bool = false, inherits: string = ""): MyNimNode =
  ## Build a complete object type definition
  ##
  ## Example:
  ##   buildObjectDef("Person", [("name", "string"), ("age", "int")], exported = true)
  let typeDef = newMyNimNode(nnkTypeDef)

  # 0: name
  let nameNode = newIdentNode(name)
  if exported:
    typeDef.sons.add(newPostfixExport(nameNode))
  else:
    typeDef.sons.add(nameNode)

  typeDef.sons.add(newEmptyNode())  # 1: generic params

  # 2: object type
  let objTy = newMyNimNode(nnkObjectTy)

  # Inheritance
  if inherits == "":
    objTy.sons.add(newEmptyNode())
  else:
    let ofInherit = newMyNimNode(nnkOfInherit)
    ofInherit.sons.add(newIdentNode(inherits))
    objTy.sons.add(ofInherit)

  objTy.sons.add(newEmptyNode())  # pragmas

  # Fields
  let recList = newMyNimNode(nnkRecList)
  for (fname, ftyp) in fields:
    recList.sons.add(newIdentDefs(
      newIdentNode(fname),
      newIdentNode(ftyp),
      newEmptyNode()
    ))
  objTy.sons.add(recList)

  typeDef.sons.add(objTy)
  result = typeDef

proc buildEnumDef*(name: string, values: openArray[string],
                   exported: bool = false): MyNimNode =
  ## Build an enum type definition
  ##
  ## Example:
  ##   buildEnumDef("Color", ["Red", "Green", "Blue"], exported = true)
  let typeDef = newMyNimNode(nnkTypeDef)

  # 0: name
  let nameNode = newIdentNode(name)
  if exported:
    typeDef.sons.add(newPostfixExport(nameNode))
  else:
    typeDef.sons.add(nameNode)

  typeDef.sons.add(newEmptyNode())  # 1: generic params

  # 2: enum type
  let enumTy = newMyNimNode(nnkEnumTy)
  enumTy.sons.add(newEmptyNode())  # first slot is empty

  for val in values:
    enumTy.sons.add(newIdentNode(val))

  typeDef.sons.add(enumTy)
  result = typeDef

proc wrapInTypeSection*(typeDefs: varargs[MyNimNode]): MyNimNode =
  ## Wrap type definitions in a type section
  result = newMyNimNode(nnkTypeSection)
  for td in typeDefs:
    result.sons.add(td)


