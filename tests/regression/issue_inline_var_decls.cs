class Test {
    bool TryParse(string s, out int result) {
        result = 42;
        return true;
    }

    void TestMethod() {
        // Inline variable declaration in argument - should be hoisted
        bool success = TryParse("123", out int value);

        // Also test with 'out var' syntax
        bool success2 = TryParse("456", out var value2);
    }
}
