# helpers for the xlang lowering passes mechanism:
# tree traversal, operations and transformations.
import ../../xlangtypes
import hashes, sugar, sets, sequtils
import types
import apply_to_kids

proc applyToKids*(node: var XLangNode, p: proc (x: var XLangNode))=
  visit(node, p)


proc traverseTree*(node: var XLangNode, p:( proc(node: var XLangNode) : void) )=
  p node
  applyToKids(node, p)

proc printTree*(root: var XLangNode, indent: int = 0) =
  echo "  ".repeat(indent) & $root
  applyToKids root, proc(child: var XLangNode) =
    printTree(child, indent + 1)

proc collectAllKinds*(tree: var XLangNode): HashSet[XLangNodeKind] =
  var kinds = initHashSet[XLangNodeKind]()
  traverseTree tree, (node: var XLangNode) =>
    kinds.incl(node.kind)
  result = kinds


proc isValidTransform*(transform: TransformPass, kinds: HashSet[XLangNodeKind]): bool =
  result = (transform.operatesOnKinds - kinds).len == 0

# proc validTransforms(transforms: seq[TransformPass], kinds: HashSet[XLangNodeKind]): seq[TransformPass] =
#   transforms.filterIt(isValidTransform(it, kinds))
  
proc hash*(node: var XLangNode): Hash =
  var h: Hash = 0 # ?? better seed needed?
  traverseTree node, proc(n: var XLangNode) =
    h = h !& hash(n)

  result = !$h
  

proc hashTree*(tree: var XLangNode): Hash =
  result = hash(tree)
