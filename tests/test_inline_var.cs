class Test {
    bool TryParse(string s, out int result) {
        result = 42;
        return true;
    }

    void TestMethod() {
        // Inline variable declaration in argument
        bool success = TryParse("123", out int value);
    }
}
