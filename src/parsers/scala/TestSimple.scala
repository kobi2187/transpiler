package com.example

object TestSimple {
  // Test basic arithmetic operators (binary operators)
  def add(x: Int, y: Int): Int = x + y
  def subtract(x: Int, y: Int): Int = x - y
  def multiply(x: Int, y: Int): Int = x * y

  // Test unary operators
  def negate(x: Int): Int = -x
  def not(b: Boolean): Boolean = !b

  // Test generic types (List[Int], Option[String])
  def first[T](list: List[T]): Option[T] = list.headOption
  def getOrElse[T](opt: Option[T], default: T): T = opt.getOrElse(default)

  // Test case class
  case class Point(x: Int, y: Int) {
    def distance(other: Point): Double = {
      math.sqrt(math.pow(x - other.x, 2) + math.pow(y - other.y, 2))
    }
  }

  // Test pattern matching with guard
  def describe(x: Any): String = x match {
    case i: Int if i > 0 => "positive"
    case i: Int if i < 0 => "negative"
    case 0 => "zero"
    case s: String => s"string: $s"
    case _ => "other"
  }

  // Test for comprehension
  def pairs(n: Int): List[(Int, Int)] = {
    for {
      i <- 1 to n
      j <- 1 to n
      if i < j
    } yield (i, j)
  }

  // Test function types
  def applyTwice(f: Int => Int, x: Int): Int = f(f(x))

  // Test this and super (implicit)
  val greeting = "Hello"
  var counter = 0

  def main(args: Array[String]): Unit = {
    println(add(2, 3))
    println(negate(5))

    val p = Point(10, 20)
    println(s"Point: ${p.x}, ${p.y}")

    println(describe(42))
    println(describe(-5))
    println(describe("test"))

    val result = pairs(3)
    println(s"Pairs: $result")

    val doubled = applyTwice(_ * 2, 5)
    println(s"Doubled twice: $doubled")
  }
}
