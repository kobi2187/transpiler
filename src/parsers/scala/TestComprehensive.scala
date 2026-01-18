package com.example.comprehensive

import scala.collection.mutable.{ArrayBuffer, HashMap}
import scala.util.{Try, Success, Failure}

// Trait example
trait Drawable {
  def draw(): Unit
  def move(x: Int, y: Int): Unit
}

// Abstract class
abstract class Shape(val color: String) extends Drawable {
  def area(): Double
  def perimeter(): Double
}

// Case class
case class Point(x: Double, y: Double) {
  def distance(other: Point): Double = {
    math.sqrt(math.pow(x - other.x, 2) + math.pow(y - other.y, 2))
  }
}

// Sealed trait for ADT
sealed trait Result[+A]
case class Success[A](value: A) extends Result[A]
case class Error(message: String) extends Result[Nothing]

// Class with type parameters and multiple parameter lists
class Rectangle(width: Double, height: Double, color: String) extends Shape(color) {

  override def area(): Double = width * height

  override def perimeter(): Double = 2 * (width + height)

  override def draw(): Unit = {
    println(s"Drawing rectangle: $width x $height in $color")
  }

  override def move(x: Int, y: Int): Unit = {
    println(s"Moving rectangle to ($x, $y)")
  }
}

// Singleton object
object MathUtils {
  val PI = 3.14159265359

  def max(a: Int, b: Int): Int = if (a > b) a else b

  def factorial(n: Int): Int = {
    if (n <= 1) 1
    else n * factorial(n - 1)
  }

  def sum(numbers: Int*): Int = numbers.sum
}

// Class with implicit parameters
class Logger(implicit val prefix: String) {
  def log(message: String): Unit = {
    println(s"$prefix: $message")
  }
}

// Object with pattern matching and for comprehension
object ComprehensiveTest {

  // Pattern matching
  def describe(x: Any): String = x match {
    case i: Int if i > 0 => "positive integer"
    case i: Int if i < 0 => "negative integer"
    case 0 => "zero"
    case s: String => s"string: $s"
    case p: Point => s"point at (${p.x}, ${p.y})"
    case _ => "unknown"
  }

  // For comprehension
  def generatePairs(n: Int): Seq[(Int, Int)] = {
    for {
      i <- 1 to n
      j <- 1 to n
      if i < j
    } yield (i, j)
  }

  // Higher-order functions
  def applyTwice[A](f: A => A, x: A): A = f(f(x))

  // Lambda expressions
  val increment = (x: Int) => x + 1
  val multiply = (x: Int, y: Int) => x * y

  // Try-catch
  def safeDivide(a: Int, b: Int): Option[Int] = {
    try {
      Some(a / b)
    } catch {
      case _: ArithmeticException => None
    } finally {
      println("Division attempted")
    }
  }

  // While loop
  def countdown(n: Int): Unit = {
    var i = n
    while (i > 0) {
      println(i)
      i -= 1
    }
  }

  // Type alias
  type IntPair = (Int, Int)
  type StringMap = Map[String, String]

  // By-name parameters
  def byNameExample(block: => Unit): Unit = {
    println("Before block")
    block
    println("After block")
  }

  // Multiple parameter lists (currying)
  def curriedAdd(x: Int)(y: Int): Int = x + y

  // Implicit class (extension method)
  implicit class RichInt(val n: Int) extends AnyVal {
    def times(f: => Unit): Unit = {
      var i = 0
      while (i < n) {
        f
        i += 1
      }
    }
  }

  def main(args: Array[String]): Unit = {
    // Basic operations
    val rect = new Rectangle(10.0, 5.0, "blue")
    println(s"Area: ${rect.area()}")
    println(s"Perimeter: ${rect.perimeter()}")
    rect.draw()
    rect.move(100, 200)

    // Pattern matching
    println(describe(42))
    println(describe("hello"))
    println(describe(Point(1.0, 2.0)))

    // For comprehension
    val pairs = generatePairs(3)
    println(s"Pairs: $pairs")

    // Higher-order function
    val result = applyTwice(increment, 5)
    println(s"Result: $result")

    // Collections
    val list = List(1, 2, 3, 4, 5)
    val doubled = list.map(_ * 2)
    val filtered = list.filter(_ > 2)
    val sum = list.reduce(_ + _)

    println(s"Doubled: $doubled")
    println(s"Filtered: $filtered")
    println(s"Sum: $sum")

    // Option handling
    val divided = safeDivide(10, 2)
    divided match {
      case Some(value) => println(s"Result: $value")
      case None => println("Division failed")
    }

    // Curried function
    val add5 = curriedAdd(5) _
    println(s"5 + 3 = ${add5(3)}")

    // Extension method
    3.times {
      println("Hello")
    }
  }
}
