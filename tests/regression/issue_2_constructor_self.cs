// Issue #2: Constructors should use 'result' not 'self' for field assignment
class TestConstructorSelf {
    private bool ignoreCase;
    private string name;
    private int count;

    public TestConstructorSelf(bool ignoreCase, string name) {
        // Should generate:
        // result.ignoreCase = ignoreCase
        // result.name = name
        //
        // NOT:
        // self.ignoreCase = self.ignoreCase
        // self.name = self.name

        this.ignoreCase = ignoreCase;
        this.name = name;
        this.count = 0;
    }

    public TestConstructorSelf(string name) : this(false, name) {
        // Chained constructor
    }

    public void SetName(string name) {
        // Regular methods should still use self
        // Should generate: self.name = name
        this.name = name;
    }
}
