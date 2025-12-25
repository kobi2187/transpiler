// Issue #1: Constructor calls in field initializers should use 'new' prefix
class Node {
    public Node next;
    public int value;

    public Node(int val) {
        value = val;
    }
}

class TestConstructorCalls {
    // Should generate: Node = newNode()
    // NOT: Node = Node()
    private Node head = new Node(0);

    void CreateNodes() {
        // Field initializer
        Node n = new Node(42);

        // Should also work in assignments
        n.next = new Node(43);
    }

    Node[] CreateArray() {
        // Array initializers
        return new Node[] {
            new Node(1),
            new Node(2),
            new Node(3)
        };
    }
}
