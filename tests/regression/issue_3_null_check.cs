// Issue #3: Null check syntax - 'is null' should become '== nil'
class TestNullCheck {
    void CheckNull(string text) {
        // Should generate: if text == nil:
        // NOT: if text:
        if (text is null) {
            return;
        }

        // Also check 'is not null'
        if (text is not null) {
            // Do something
        }
    }

    bool IsNull(object obj) {
        // Should generate: return obj == nil
        return obj is null;
    }

    bool IsNotNull(object obj) {
        // Should handle negation properly
        return obj is not null;
    }
}
