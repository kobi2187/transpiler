// Issue #4: Empty parameter lists - 'out _' should become '_', not empty
class TestOutParams {
    int Get(string text, out int value) {
        value = 42;
        return 1;
    }

    int CallGet(string text) {
        // Should generate: return get(text, _)
        // NOT: return get(text, )
        return Get(text, out _);
    }

    bool TryParse(string s, out int result) {
        result = 123;
        return true;
    }

    void UseMultipleOutParams() {
        // Should generate: discard tryParse("123", _)
        // NOT: discard tryParse("123", )
        TryParse("123", out _);

        // Regular out parameter should work too
        int x;
        TryParse("456", out x);
    }
}
