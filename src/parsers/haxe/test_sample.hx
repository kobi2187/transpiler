// Test sample for Haxe to XLang parser
// This file demonstrates various Haxe language constructs

package test;

import haxe.ds.Option;

// Simple class with fields and methods
class Point {
    public var x:Int;
    public var y:Int;

    public function new(x:Int, y:Int) {
        this.x = x;
        this.y = y;
    }

    public function distance():Float {
        return Math.sqrt(x * x + y * y);
    }

    public function add(other:Point):Point {
        return new Point(this.x + other.x, this.y + other.y);
    }
}

// Enum with constructors
enum Color {
    Red;
    Green;
    Blue;
    RGB(r:Int, g:Int, b:Int);
}

// Generic class
class Container<T> {
    private var value:T;

    public function new(value:T) {
        this.value = value;
    }

    public function get():T {
        return value;
    }

    public function set(v:T):Void {
        value = v;
    }
}

// Interface
interface Drawable {
    function draw():Void;
}

// Class implementing interface
class Circle implements Drawable {
    public var radius:Float;

    public function new(radius:Float) {
        this.radius = radius;
    }

    public function draw():Void {
        trace('Drawing circle with radius: $radius');
    }
}

// Abstract type
abstract Meters(Float) {
    public inline function new(v:Float) {
        this = v;
    }

    @:from
    public static inline function fromFloat(f:Float):Meters {
        return new Meters(f);
    }

    @:to
    public inline function toFloat():Float {
        return this;
    }

    @:op(A + B)
    public inline function add(other:Meters):Meters {
        return new Meters(this + other.toFloat());
    }
}

// Class with various statement types
class Examples {
    // If-else
    public static function max(a:Int, b:Int):Int {
        if (a > b) {
            return a;
        } else {
            return b;
        }
    }

    // While loop
    public static function factorial(n:Int):Int {
        var result = 1;
        var i = 1;
        while (i <= n) {
            result *= i;
            i++;
        }
        return result;
    }

    // For loop (iterator-based)
    public static function sum(arr:Array<Int>):Int {
        var total = 0;
        for (item in arr) {
            total += item;
        }
        return total;
    }

    // Switch with pattern matching
    public static function colorName(c:Color):String {
        return switch (c) {
            case Red: "Red";
            case Green: "Green";
            case Blue: "Blue";
            case RGB(r, g, b): 'RGB($r,$g,$b)';
        };
    }

    // Try-catch
    public static function safeDivide(a:Float, b:Float):Float {
        try {
            if (b == 0) {
                throw "Division by zero";
            }
            return a / b;
        } catch (e:String) {
            trace('Error: $e');
            return 0;
        }
    }

    // Lambda expression
    public static function mapArray<T, U>(arr:Array<T>, f:T->U):Array<U> {
        var result = [];
        for (item in arr) {
            result.push(f(item));
        }
        return result;
    }

    // Array comprehension (if supported)
    public static function squares(n:Int):Array<Int> {
        return [for (i in 0...n) i * i];
    }

    // Ternary operator
    public static function abs(x:Int):Int {
        return x >= 0 ? x : -x;
    }
}

// Typedef
typedef Person = {
    name:String,
    age:Int
}

// Main class
class Main {
    static function main() {
        var p1 = new Point(3, 4);
        var p2 = new Point(1, 2);
        var p3 = p1.add(p2);

        trace('Distance: ${p1.distance()}');

        var color = Color.RGB(255, 0, 128);
        trace(Examples.colorName(color));

        var container = new Container<String>("Hello");
        trace(container.get());

        var arr = [1, 2, 3, 4, 5];
        var doubled = Examples.mapArray(arr, x -> x * 2);
        trace(doubled);

        var m1:Meters = 5.0;
        var m2:Meters = 3.0;
        var m3 = m1 + m2;
        trace('Total meters: ${m3.toFloat()}');
    }
}
