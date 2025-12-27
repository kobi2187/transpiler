class Test {
    int Get(string text, out int value) {
        value = 42;
        return 1;
    }

    int CallGet(string text) {
        return Get(text, out _);
    }
}
