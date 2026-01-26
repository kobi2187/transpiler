@file:JvmName("TestComprehensiveKotlin")
package com.example.comprehensive

import kotlin.collections.List
import kotlin.math.PI as Pi
import java.io.File

// =============================================================================
// COMPREHENSIVE KOTLIN TEST FILE
// Tests all Kotlin language constructs for XLang parser validation
// =============================================================================

// =============================================================================
// PACKAGE-LEVEL DECLARATIONS
// =============================================================================

// Constants
const val GLOBAL_CONST = 42
const val STRING_CONST = "Hello"

// Top-level variables
val topLevelVal = listOf(1, 2, 3)
var topLevelVar: String = "mutable"

// Top-level function
fun topLevelFunction(x: Int, y: Int = 10): Int {
    return x + y
}

// Single expression function
fun singleExpressionFunc(x: Int) = x * 2

// Extension function
fun String.addExclamation(): String = this + "!"

// Extension property
val String.lastChar: Char
    get() = this[length - 1]

// Infix function
infix fun Int.times(str: String) = str.repeat(this)

// Operator overload
operator fun Int.unaryMinus(): Int = -this

// Higher-order function
inline fun <T> withLock(lock: Any, action: () -> T): T {
    synchronized(lock) {
        return action()
    }
}

// Suspend function (coroutines)
suspend fun fetchData(): String {
    // Simulated async operation
    return "data"
}

// Tailrec function
tailrec fun factorial(n: Int, acc: Int = 1): Int {
    return if (n <= 1) acc else factorial(n - 1, n * acc)
}

// =============================================================================
// TYPE ALIASES
// =============================================================================

typealias StringList = List<String>
typealias Predicate<T> = (T) -> Boolean
typealias Handler = (Int, String) -> Unit

// =============================================================================
// CLASSES
// =============================================================================

// Simple class with primary constructor
class SimpleClass(val name: String, var age: Int)

// Class with init block
class ClassWithInit(name: String) {
    val upperName: String

    init {
        upperName = name.uppercase()
    }
}

// Class with secondary constructors
class MultiConstructor {
    val value: Int

    constructor() {
        value = 0
    }

    constructor(v: Int) : this() {
        // Additional initialization
    }

    constructor(s: String) : this(s.toIntOrNull() ?: 0)
}

// Open class for inheritance
open class Animal(val name: String) {
    open fun makeSound(): String = "..."

    protected val protectedField = "protected"
    private val privateField = "private"
}

// Inheritance
class Dog(name: String, val breed: String) : Animal(name) {
    override fun makeSound(): String = "Woof!"

    fun fetch() {
        println("$name is fetching!")
    }
}

// Abstract class
abstract class Shape {
    abstract val area: Double
    abstract fun perimeter(): Double

    fun describe(): String = "This is a shape with area $area"
}

class Circle(val radius: Double) : Shape() {
    override val area: Double
        get() = Pi * radius * radius

    override fun perimeter(): Double = 2 * Pi * radius
}

// Sealed class
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val message: String) : Result<Nothing>()
    object Loading : Result<Nothing>()
}

// Data class
data class Person(
    val firstName: String,
    val lastName: String,
    val age: Int = 0
) {
    val fullName: String
        get() = "$firstName $lastName"
}

// Enum class
enum class Color(val rgb: Int) {
    RED(0xFF0000) {
        override fun colorName() = "Red"
    },
    GREEN(0x00FF00) {
        override fun colorName() = "Green"
    },
    BLUE(0x0000FF) {
        override fun colorName() = "Blue"
    };

    abstract fun colorName(): String

    fun printColor() {
        println("Color: ${colorName()}, RGB: $rgb")
    }
}

// Value class (inline class)
@JvmInline
value class Password(private val value: String) {
    init {
        require(value.length >= 8) { "Password must be at least 8 characters" }
    }

    val length: Int
        get() = value.length
}

// Inner class
class Outer {
    private val outerValue = 10

    inner class Inner {
        fun getOuterValue(): Int = outerValue
    }

    class Nested {
        fun describe() = "I'm nested"
    }
}

// =============================================================================
// INTERFACES
// =============================================================================

interface Drawable {
    fun draw()
    fun erase() {
        println("Default erase implementation")
    }
}

interface Clickable {
    fun click()
    val clickCount: Int
}

// Multiple interface implementation
class Button : Drawable, Clickable {
    private var _clickCount = 0

    override val clickCount: Int
        get() = _clickCount

    override fun draw() {
        println("Drawing button")
    }

    override fun click() {
        _clickCount++
    }
}

// Functional interface (SAM)
fun interface IntTransformer {
    fun transform(x: Int): Int
}

// =============================================================================
// OBJECTS
// =============================================================================

// Singleton object
object DatabaseConnection {
    private var isConnected = false

    fun connect() {
        isConnected = true
    }

    fun disconnect() {
        isConnected = false
    }
}

// Companion object
class MyClass {
    companion object Factory {
        const val MAX_SIZE = 100

        fun create(): MyClass = MyClass()

        @JvmStatic
        fun staticMethod() {
            println("Static-like method")
        }
    }

    fun instanceMethod() {
        println("Instance method")
    }
}

// Object expression (anonymous object)
fun createComparator(): Comparator<String> {
    return object : Comparator<String> {
        override fun compare(s1: String, s2: String): Int {
            return s1.length - s2.length
        }
    }
}

// =============================================================================
// DELEGATION
// =============================================================================

interface Base {
    fun print()
}

class BaseImpl(val x: Int) : Base {
    override fun print() {
        println(x)
    }
}

// Class delegation
class Derived(b: Base) : Base by b

// Property delegation
class Lazy {
    val lazyValue: String by lazy {
        println("Computing...")
        "Hello"
    }

    var observable: String by kotlin.properties.Delegates.observable("initial") { _, old, new ->
        println("Changed from $old to $new")
    }

    var vetoable: Int by kotlin.properties.Delegates.vetoable(0) { _, _, newValue ->
        newValue >= 0
    }
}

// Map delegation
class User(val map: Map<String, Any?>) {
    val name: String by map
    val age: Int by map
}

// =============================================================================
// GENERICS
// =============================================================================

// Generic class
class Box<T>(val value: T) {
    fun get(): T = value
}

// Generic function
fun <T> singletonList(item: T): List<T> = listOf(item)

// Variance: covariance (out)
interface Producer<out T> {
    fun produce(): T
}

// Variance: contravariance (in)
interface Consumer<in T> {
    fun consume(item: T)
}

// Generic constraints
fun <T : Comparable<T>> sort(list: List<T>): List<T> {
    return list.sorted()
}

// Multiple constraints
fun <T> copyWhenGreater(list: List<T>, threshold: T): List<String>
        where T : CharSequence,
              T : Comparable<T> {
    return list.filter { it > threshold }.map { it.toString() }
}

// Reified type parameter
inline fun <reified T> isInstance(value: Any): Boolean = value is T

// Star projection
fun printAll(list: List<*>) {
    for (item in list) {
        println(item)
    }
}

// =============================================================================
// NULL SAFETY
// =============================================================================

fun nullSafetyExamples() {
    // Nullable types
    var nullable: String? = "Hello"
    nullable = null

    // Safe call
    val length = nullable?.length

    // Elvis operator
    val len = nullable?.length ?: 0

    // Not-null assertion
    // val forcedLength = nullable!!.length  // Would throw NPE

    // Safe cast
    val anyValue: Any = "String"
    val safeString: String? = anyValue as? String

    // Let for null check
    nullable?.let {
        println("Not null: $it")
    }

    // Also, apply, run, with
    val result = nullable?.run {
        length * 2
    } ?: -1
}

// Platform types and annotations
fun platformTypes(@Suppress("UNUSED_PARAMETER") javaObject: Any) {
    // Java interop examples would go here
}

// =============================================================================
// CONTROL FLOW
// =============================================================================

fun controlFlowExamples(x: Int, items: List<String>) {
    // If expression
    val max = if (x > 0) x else -x

    // When expression
    val description = when (x) {
        0 -> "zero"
        1, 2 -> "one or two"
        in 3..10 -> "between 3 and 10"
        !in 100..200 -> "not in range"
        else -> "something else"
    }

    // When with type checking
    fun describe(obj: Any): String = when (obj) {
        is String -> "String of length ${obj.length}"
        is Int -> "Integer: $obj"
        is List<*> -> "List of size ${obj.size}"
        else -> "Unknown"
    }

    // When without argument
    val result = when {
        x < 0 -> "negative"
        x == 0 -> "zero"
        else -> "positive"
    }

    // For loop
    for (item in items) {
        println(item)
    }

    // For with index
    for ((index, value) in items.withIndex()) {
        println("$index: $value")
    }

    // For with range
    for (i in 1..5) {
        print(i)
    }

    // For with step and downTo
    for (i in 10 downTo 1 step 2) {
        print(i)
    }

    // For until (exclusive)
    for (i in 0 until items.size) {
        println(items[i])
    }

    // While loop
    var i = 0
    while (i < 10) {
        i++
    }

    // Do-while loop
    do {
        i--
    } while (i > 0)
}

// =============================================================================
// EXCEPTIONS
// =============================================================================

fun exceptionExamples() {
    // Try-catch
    try {
        val result = 10 / 0
    } catch (e: ArithmeticException) {
        println("Cannot divide by zero")
    } finally {
        println("Cleanup")
    }

    // Try as expression
    val number: Int? = try {
        "123".toInt()
    } catch (e: NumberFormatException) {
        null
    }

    // Multiple catch blocks
    try {
        // risky code
    } catch (e: IllegalArgumentException) {
        println("Illegal argument")
    } catch (e: IllegalStateException) {
        println("Illegal state")
    }

    // Throw expression
    fun fail(message: String): Nothing {
        throw IllegalArgumentException(message)
    }

    // Elvis with throw
    val value: String? = null
    val nonNull = value ?: throw IllegalStateException("Value cannot be null")
}

// =============================================================================
// LAMBDAS AND HIGHER-ORDER FUNCTIONS
// =============================================================================

fun lambdaExamples() {
    // Lambda syntax
    val sum: (Int, Int) -> Int = { a, b -> a + b }

    // Lambda with receiver
    val buildString: StringBuilder.() -> Unit = {
        append("Hello")
        append(" ")
        append("World")
    }

    // Trailing lambda
    val list = listOf(1, 2, 3)
    list.filter { it > 1 }
        .map { it * 2 }
        .forEach { println(it) }

    // it: implicit name
    list.filter { it > 0 }

    // Destructuring in lambdas
    val pairs = listOf(1 to "one", 2 to "two")
    pairs.forEach { (num, name) ->
        println("$num = $name")
    }

    // Anonymous function
    val anonymousFunc = fun(x: Int, y: Int): Int = x + y

    // Function references
    fun isPositive(x: Int) = x > 0
    list.filter(::isPositive)

    // Method references
    val strings = listOf("a", "b", "c")
    strings.map(String::uppercase)

    // Constructor references
    data class Item(val name: String)
    val names = listOf("A", "B")
    names.map(::Item)
}

// =============================================================================
// COLLECTIONS
// =============================================================================

fun collectionExamples() {
    // List
    val immutableList = listOf(1, 2, 3)
    val mutableList = mutableListOf(1, 2, 3)

    // Set
    val immutableSet = setOf(1, 2, 3)
    val mutableSet = mutableSetOf(1, 2, 3)

    // Map
    val immutableMap = mapOf("a" to 1, "b" to 2)
    val mutableMap = mutableMapOf("a" to 1, "b" to 2)

    // Array
    val array = arrayOf(1, 2, 3)
    val intArray = intArrayOf(1, 2, 3)

    // Collection operations
    immutableList
        .filter { it > 1 }
        .map { it * 2 }
        .take(5)
        .drop(1)
        .sortedDescending()
        .distinct()
        .groupBy { it % 2 }
        .flatMap { it.value }
        .fold(0) { acc, i -> acc + i }

    // Sequences (lazy evaluation)
    val sequence = sequenceOf(1, 2, 3)
    val generated = generateSequence(1) { it + 1 }.take(10)

    // Destructuring
    val (first, second) = Pair(1, 2)
    val (a, b, c) = Triple(1, 2, 3)
}

// =============================================================================
// OPERATORS
// =============================================================================

data class Point(val x: Int, val y: Int) {
    // Unary operators
    operator fun unaryMinus() = Point(-x, -y)
    operator fun unaryPlus() = Point(+x, +y)
    operator fun not() = Point(y, x)

    // Increment/decrement
    operator fun inc() = Point(x + 1, y + 1)
    operator fun dec() = Point(x - 1, y - 1)

    // Binary operators
    operator fun plus(other: Point) = Point(x + other.x, y + other.y)
    operator fun minus(other: Point) = Point(x - other.x, y - other.y)
    operator fun times(scale: Int) = Point(x * scale, y * scale)
    operator fun div(scale: Int) = Point(x / scale, y / scale)
    operator fun rem(mod: Int) = Point(x % mod, y % mod)

    // Augmented assignments are auto-generated from binary operators

    // In operator
    operator fun contains(value: Int) = value in x..y

    // Range operator
    operator fun rangeTo(other: Point) = listOf(this, other)

    // Indexed access
    operator fun get(index: Int) = if (index == 0) x else y
    operator fun set(index: Int, value: Int) {
        // Would need mutable fields
    }

    // Invoke
    operator fun invoke(z: Int) = Point(x + z, y + z)

    // Comparison
    operator fun compareTo(other: Point) = (x + y) - (other.x + other.y)
}

fun operatorExamples() {
    val p1 = Point(1, 2)
    val p2 = Point(3, 4)

    // Using operators
    val sum = p1 + p2
    val diff = p1 - p2
    val scaled = p1 * 2
    val negated = -p1

    // In check
    val inRange = 1 in p1

    // Invoke
    val moved = p1(5)

    // Indexed access
    val xValue = p1[0]
}

// =============================================================================
// DESTRUCTURING DECLARATIONS
// =============================================================================

fun destructuringExamples() {
    // Data class destructuring
    val person = Person("John", "Doe", 30)
    val (firstName, lastName, age) = person

    // Pair and Triple
    val pair = Pair("key", 42)
    val (key, value) = pair

    // Map entry destructuring
    val map = mapOf("a" to 1, "b" to 2)
    for ((k, v) in map) {
        println("$k -> $v")
    }

    // Underscore for unused variables
    val (name, _) = pair

    // In lambdas
    map.forEach { (k, v) -> println("$k = $v") }
}

// =============================================================================
// ANNOTATIONS
// =============================================================================

@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
@MustBeDocumented
annotation class Fancy

@Target(AnnotationTarget.PROPERTY)
annotation class Inject

@Target(AnnotationTarget.VALUE_PARAMETER)
annotation class Positive

@Fancy
class AnnotatedClass {
    @Inject
    lateinit var dependency: String

    @Fancy
    fun annotatedMethod(@Positive value: Int) {
        // Method body
    }
}

// Use-site targets
class UseTargetExample(
    @field:Inject val fieldTarget: String,
    @get:Fancy val getterTarget: String,
    @param:Positive paramTarget: Int
)

// =============================================================================
// REFLECTION
// =============================================================================

fun reflectionExamples() {
    // Class reference
    val kClass = String::class

    // Function reference
    val funcRef = ::topLevelFunction

    // Property reference
    val propRef = ::topLevelVal

    // Bound references
    val str = "Hello"
    val lengthRef = str::length
}

// =============================================================================
// SCOPE FUNCTIONS
// =============================================================================

fun scopeFunctionExamples() {
    val person = Person("John", "Doe", 30)

    // let - it, returns lambda result
    val result1 = person.let {
        println(it.firstName)
        it.fullName
    }

    // run - this, returns lambda result
    val result2 = person.run {
        println(firstName)
        fullName
    }

    // with - this, returns lambda result (non-extension)
    val result3 = with(person) {
        println(firstName)
        fullName
    }

    // apply - this, returns receiver
    val result4 = person.apply {
        println(firstName)
    }

    // also - it, returns receiver
    val result5 = person.also {
        println(it.firstName)
    }

    // takeIf and takeUnless
    val evenNumber = 42.takeIf { it % 2 == 0 }
    val oddNumber = 42.takeUnless { it % 2 == 0 }
}

// =============================================================================
// COROUTINES (Conceptual - requires kotlinx.coroutines)
// =============================================================================

// Suspend functions
suspend fun doSomethingAsync(): Int {
    // Would use delay() in real coroutines
    return 42
}

// Inline classes for coroutines would typically use Flow, Channel, etc.

// =============================================================================
// DSL BUILDING
// =============================================================================

class HTML {
    fun head(init: HEAD.() -> Unit) {}
    fun body(init: BODY.() -> Unit) {}
}

class HEAD {
    fun title(text: String) {}
}

class BODY {
    fun div(init: DIV.() -> Unit) {}
    fun p(text: String) {}
}

class DIV {
    fun p(text: String) {}
}

fun html(init: HTML.() -> Unit): HTML {
    val html = HTML()
    html.init()
    return html
}

fun dslExample() {
    html {
        head {
            title("My Page")
        }
        body {
            div {
                p("Hello, DSL!")
            }
            p("Another paragraph")
        }
    }
}

// =============================================================================
// CONTRACTS (Conceptual)
// =============================================================================

@OptIn(kotlin.contracts.ExperimentalContracts::class)
fun requireNotNull(value: Any?) {
    kotlin.contracts.contract {
        returns() implies (value != null)
    }
    if (value == null) throw IllegalArgumentException()
}

// =============================================================================
// MAIN FUNCTION
// =============================================================================

fun main(args: Array<String>) {
    println("Comprehensive Kotlin Test File")

    // Test various constructs
    val person = Person("John", "Doe", 30)
    println(person)

    val box = Box(42)
    println(box.get())

    val color = Color.RED
    color.printColor()

    DatabaseConnection.connect()

    val button = Button()
    button.draw()
    button.click()

    println("Tests completed!")
}
