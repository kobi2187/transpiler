package com.example.simple;

import java.util.List;
import java.util.ArrayList;

/**
 * Simple test file for Java to XLang parser
 */
public class TestSimple {
    private int value;
    private static final String CONSTANT = "Hello";

    public TestSimple(int value) {
        this.value = value;
    }

    public int getValue() {
        return value;
    }

    public void setValue(int value) {
        this.value = value;
    }

    public static int add(int a, int b) {
        return a + b;
    }

    public static void main(String[] args) {
        TestSimple obj = new TestSimple(42);
        int result = add(obj.getValue(), 10);
        System.out.println("Result: " + result);

        // Test control flow
        if (result > 50) {
            System.out.println("Greater than 50");
        } else {
            System.out.println("Less than or equal to 50");
        }

        // Test loop
        for (int i = 0; i < 5; i++) {
            System.out.println("Count: " + i);
        }

        // Test enhanced for loop
        List<String> items = new ArrayList<>();
        items.add("apple");
        items.add("banana");
        items.add("cherry");

        for (String item : items) {
            System.out.println("Item: " + item);
        }
    }
}
