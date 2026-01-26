package com.example

// Simple test file for Kotlin parser

fun main() {
    println("Hello, World!")
    val x = 42
    var y = "test"

    if (x > 10) {
        println("x is greater than 10")
    } else {
        println("x is 10 or less")
    }

    for (i in 1..5) {
        println(i)
    }
}

class SimpleClass(val name: String) {
    fun greet(): String {
        return "Hello, $name!"
    }
}
