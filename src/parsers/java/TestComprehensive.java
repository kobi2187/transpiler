package com.example.comprehensive;

import java.util.*;
import java.io.*;
import java.util.function.*;
import java.util.stream.*;

/**
 * Comprehensive test file covering all major Java language features
 */

// Annotations
@Deprecated
@SuppressWarnings("unchecked")
public class TestComprehensive {

    // Fields with various modifiers
    private int privateField;
    protected String protectedField;
    public double publicField;
    static final int STATIC_FINAL = 100;
    transient Object transientField;
    volatile boolean volatileField;

    // Static initializer
    static {
        System.out.println("Static initializer");
    }

    // Instance initializer
    {
        System.out.println("Instance initializer");
    }

    // Constructor
    public TestComprehensive() {
        this(0);
    }

    // Constructor with parameters
    public TestComprehensive(int value) {
        this.privateField = value;
    }

    // Method with generic type parameters
    public <T> List<T> genericMethod(T item) {
        List<T> list = new ArrayList<>();
        list.add(item);
        return list;
    }

    // Method with varargs
    public void varArgsMethod(String... args) {
        for (String arg : args) {
            System.out.println(arg);
        }
    }

    // Method with throws clause
    public void methodWithThrows() throws IOException, IllegalArgumentException {
        throw new IOException("Test exception");
    }

    // Test all statement types
    public void testStatements() {
        // 1. Expression statement
        int x = 10;

        // 2. Block statement
        {
            int y = 20;
            System.out.println(y);
        }

        // 3. If statement
        if (x > 5) {
            System.out.println("Greater");
        } else if (x < 5) {
            System.out.println("Less");
        } else {
            System.out.println("Equal");
        }

        // 4. While statement
        while (x < 15) {
            x++;
        }

        // 5. Do-while statement
        do {
            x--;
        } while (x > 10);

        // 6. For statement
        for (int i = 0; i < 10; i++) {
            System.out.println(i);
        }

        // 7. Enhanced for statement (foreach)
        int[] array = {1, 2, 3, 4, 5};
        for (int num : array) {
            System.out.println(num);
        }

        // 8. Switch statement (traditional)
        switch (x) {
            case 1:
                System.out.println("One");
                break;
            case 2:
                System.out.println("Two");
                break;
            default:
                System.out.println("Other");
        }

        // 9. Return statement
        if (x == 0) {
            return;
        }

        // 10. Throw statement
        if (x < 0) {
            throw new IllegalArgumentException("Negative value");
        }

        // 11. Try-catch-finally statement
        try {
            int result = 10 / x;
        } catch (ArithmeticException e) {
            System.err.println("Division by zero");
        } finally {
            System.out.println("Finally block");
        }

        // 12. Try-with-resources
        try (BufferedReader br = new BufferedReader(new FileReader("test.txt"))) {
            String line = br.readLine();
        } catch (IOException e) {
            e.printStackTrace();
        }

        // 13. Break statement
        for (int i = 0; i < 10; i++) {
            if (i == 5) break;
        }

        // 14. Continue statement
        for (int i = 0; i < 10; i++) {
            if (i % 2 == 0) continue;
            System.out.println(i);
        }

        // 15. Labeled statement
        outer: for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                if (j == 2) break outer;
            }
        }

        // 16. Assert statement
        assert x > 0 : "x must be positive";

        // 17. Synchronized statement
        synchronized (this) {
            this.privateField++;
        }

        // 18. Empty statement
        ;
    }

    // Test all expression types
    public void testExpressions() {
        // Binary expressions
        int a = 10 + 5;
        int b = 10 - 5;
        int c = 10 * 5;
        int d = 10 / 5;
        int e = 10 % 5;
        boolean f = 10 > 5;
        boolean g = 10 < 5;
        boolean h = 10 >= 5;
        boolean i = 10 <= 5;
        boolean j = 10 == 5;
        boolean k = 10 != 5;
        boolean l = true && false;
        boolean m = true || false;

        // Unary expressions
        int n = -a;
        int o = +a;
        int p = ++a;
        int q = a++;
        int r = --a;
        int s = a--;
        boolean t = !true;
        int u = ~a;

        // Ternary/conditional expression
        int v = a > 5 ? 10 : 20;

        // Assignment expressions
        a = 10;
        a += 5;
        a -= 5;
        a *= 5;
        a /= 5;
        a %= 5;
        a &= 5;
        a |= 5;
        a ^= 5;
        a <<= 2;
        a >>= 2;
        a >>>= 2;

        // Method call
        int result = Math.max(10, 20);

        // Field access
        String text = this.protectedField;

        // Array creation and access
        int[] arr = new int[10];
        int[] arr2 = {1, 2, 3, 4, 5};
        int value = arr[0];

        // Object creation
        TestComprehensive obj = new TestComprehensive(42);

        // Anonymous class
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                System.out.println("Running");
            }
        };

        // Lambda expression
        Runnable lambda = () -> System.out.println("Lambda");
        Function<Integer, Integer> square = x -> x * x;
        BiFunction<Integer, Integer, Integer> add = (x, y) -> x + y;

        // Method reference
        Consumer<String> printer = System.out::println;

        // Cast expression
        double dbl = (double) a;

        // Instanceof expression
        boolean isString = obj instanceof TestComprehensive;

        // This and super expressions
        this.privateField = 10;

        // Class literal
        Class<?> clazz = String.class;

        // Parenthesized expression
        int w = (a + b) * c;
    }

    // Lambda and method references
    public void testLambdasAndMethodRefs() {
        List<String> list = Arrays.asList("apple", "banana", "cherry");

        // Lambda with block body
        list.forEach(item -> {
            String upper = item.toUpperCase();
            System.out.println(upper);
        });

        // Lambda with expression body
        list.stream()
            .map(s -> s.toUpperCase())
            .filter(s -> s.startsWith("A"))
            .forEach(System.out::println);

        // Method reference - static
        Function<String, Integer> parseInt = Integer::parseInt;

        // Method reference - instance
        String str = "hello";
        Supplier<String> toUpper = str::toUpperCase;

        // Method reference - arbitrary object
        Function<String, String> trim = String::trim;

        // Constructor reference
        Supplier<ArrayList<String>> listFactory = ArrayList::new;
    }

    // Nested and inner classes
    public static class StaticNestedClass {
        private int value;

        public StaticNestedClass(int value) {
            this.value = value;
        }
    }

    public class InnerClass {
        public void accessOuter() {
            System.out.println(TestComprehensive.this.privateField);
        }
    }

    // Local class
    public void methodWithLocalClass() {
        class LocalClass {
            private int localValue;

            public void print() {
                System.out.println(localValue);
            }
        }

        LocalClass local = new LocalClass();
        local.print();
    }

    // Generic method with bounded type parameter
    public <T extends Comparable<T>> T max(T a, T b) {
        return a.compareTo(b) > 0 ? a : b;
    }

    // Wildcard types
    public void wildcardMethod(List<? extends Number> numbers) {
        for (Number num : numbers) {
            System.out.println(num);
        }
    }

    public void wildcardSuperMethod(List<? super Integer> list) {
        list.add(42);
    }

    // Main method
    public static void main(String[] args) {
        TestComprehensive test = new TestComprehensive(100);
        test.testStatements();
        test.testExpressions();
        test.testLambdasAndMethodRefs();
        System.out.println("All tests completed");
    }
}

// Interface
interface TestInterface {
    void method1();
    default void method2() {
        System.out.println("Default method");
    }
    static void method3() {
        System.out.println("Static method");
    }
}

// Enum
enum Color {
    RED(255, 0, 0),
    GREEN(0, 255, 0),
    BLUE(0, 0, 255);

    private final int r, g, b;

    Color(int r, int g, int b) {
        this.r = r;
        this.g = g;
        this.b = b;
    }

    public int getRed() { return r; }
    public int getGreen() { return g; }
    public int getBlue() { return b; }
}

// Annotation type
@interface TestAnnotation {
    String value() default "";
    int count() default 0;
}

// Abstract class
abstract class AbstractBase {
    abstract void abstractMethod();

    public void concreteMethod() {
        System.out.println("Concrete");
    }
}
