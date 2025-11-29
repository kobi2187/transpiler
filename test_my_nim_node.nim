import src/my_nim_node

# Test basic node creation
echo "=== Testing MyNimNode ==="

# Test literals
let intNode = newIntLitNode(42)
echo "Int literal: ", intNode
echo "  kind: ", intNode.kind
echo "  value: ", intNode.intVal

let strNode = newStrLitNode("Hello, World!")
echo "\nString literal: ", strNode
echo "  kind: ", strNode.kind
echo "  value: ", strNode.strVal

let identNode = newIdentNode("myVar")
echo "\nIdentifier: ", identNode
echo "  kind: ", identNode.kind
echo "  value: ", identNode.identStr

# Test tree construction
echo "\n=== Building a simple expression tree ==="
# Build: x + 42
let xIdent = newIdentNode("x")
let fortyTwo = newIntLitNode(42)
let addExpr = newInfixCall("+", xIdent, fortyTwo)

echo "Expression tree for 'x + 42':"
echo treeRepr(addExpr)

# Test statement list
echo "\n=== Building a statement list ==="
let stmtList = newStmtList()
stmtList.add(newVarStmt(
  newIdentNode("count"),
  newIdentNode("int"),
  newIntLitNode(0)
))
stmtList.add(newAssignment(
  newIdentNode("count"),
  newIntLitNode(10)
))

echo "Statement list:"
echo treeRepr(stmtList)

# Test procedure building
echo "\n=== Building a simple proc ==="
# proc greet(name: string) =
#   echo "Hello, " & name
let procNode = newProc()
# Note: Full proc construction would require more nodes
echo "Proc node kind: ", procNode.kind
echo "Initial children: ", procNode.len

# Test tree manipulation
echo "\n=== Testing tree manipulation ==="
let bracket = newBracket(
  newIntLitNode(1),
  newIntLitNode(2),
  newIntLitNode(3)
)
echo "Array literal [1, 2, 3]:"
echo treeRepr(bracket)
echo "Length: ", bracket.len
echo "First element: ", bracket[0]
echo "Last element: ", bracket.last

# Test copy
echo "\n=== Testing copy ==="
let original = newCall("println", newStrLitNode("test"))
let copied = copyTree(original)
echo "Original and copy are same tree: ", sameTree(original, copied)
echo "Original:"
echo treeRepr(original)
echo "Copy:"
echo treeRepr(copied)

echo "\n=== All tests completed successfully! ==="
