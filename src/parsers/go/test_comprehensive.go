// Comprehensive Go test file covering all language constructs
package main

import (
	"fmt"
	"math"
	"strings"
)

// Constants
const (
	Pi      = 3.14159
	MaxSize = 100
)

const Answer = 42

// Type declarations
type (
	Age    int
	Name   string
	Status bool
)

// Struct with tags
type User struct {
	ID       int    `json:"id" db:"user_id"`
	Username string `json:"username"`
	Email    string `json:"email,omitempty"`
	// Embedded anonymous field
	Address
}

type Address struct {
	Street string
	City   string
	Zip    int
}

// Interface
type Reader interface {
	Read(p []byte) (n int, err error)
}

type Writer interface {
	Write(p []byte) (n int, err error)
}

// Interface embedding
type ReadWriter interface {
	Reader
	Writer
	Close() error
}

// Generic type (Go 1.18+)
type Stack[T any] struct {
	items []T
}

// Generic function
func Map[T, U any](slice []T, f func(T) U) []U {
	result := make([]U, len(slice))
	for i, v := range slice {
		result[i] = f(v)
	}
	return result
}

// Type constraint
type Number interface {
	int | int64 | float64
}

func Min[T Number](a, b T) T {
	if a < b {
		return a
	}
	return b
}

// Variables
var (
	count   int
	message string = "Hello"
	active  bool
)

// Function with multiple return values
func divmod(a, b int) (int, int) {
	return a / b, a % b
}

// Function with named return values
func split(sum int) (x, y int) {
	x = sum * 4 / 9
	y = sum - x
	return
}

// Variadic function
func sum(nums ...int) int {
	total := 0
	for _, num := range nums {
		total += num
	}
	return total
}

// Method receiver (value receiver)
func (p Point) Distance() float64 {
	return math.Sqrt(p.X*p.X + p.Y*p.Y)
}

// Method receiver (pointer receiver)
func (p *Point) Scale(factor float64) {
	p.X *= factor
	p.Y *= factor
}

type Point struct {
	X, Y float64
}

// Constructor-like function
func NewPoint(x, y float64) Point {
	return Point{X: x, Y: y}
}

// Anonymous function / Function literal
var increment = func(x int) int {
	return x + 1
}

// Closure
func makeAdder(x int) func(int) int {
	return func(y int) int {
		return x + y
	}
}

// Main function demonstrating statements
func main() {
	// Short variable declaration
	x := 42
	y := "test"

	// Assignment
	x = 100

	// Multiple assignment
	a, b := 1, 2

	// Assignment with operators
	x += 10
	x -= 5
	x *= 2
	x /= 3

	// Inc/Dec statements
	x++
	x--

	// If statement
	if x > 50 {
		fmt.Println("Large")
	}

	// If with init statement
	if val := compute(); val > 0 {
		fmt.Println("Positive:", val)
	} else if val < 0 {
		fmt.Println("Negative:", val)
	} else {
		fmt.Println("Zero")
	}

	// Switch statement
	switch day := "Monday"; day {
	case "Monday", "Tuesday":
		fmt.Println("Weekday")
	case "Saturday", "Sunday":
		fmt.Println("Weekend")
	default:
		fmt.Println("Midweek")
	}

	// Switch with no condition (like if-else chain)
	switch {
	case x < 10:
		fmt.Println("Small")
	case x < 100:
		fmt.Println("Medium")
	default:
		fmt.Println("Large")
	}

	// Type switch
	var i interface{} = "hello"
	switch v := i.(type) {
	case int:
		fmt.Printf("Integer: %d\n", v)
	case string:
		fmt.Printf("String: %s\n", v)
	default:
		fmt.Printf("Unknown type\n")
	}

	// For loop (C-style)
	for i := 0; i < 10; i++ {
		fmt.Println(i)
	}

	// For loop (while-style)
	for x < 100 {
		x++
	}

	// Infinite loop
	for {
		break
	}

	// Range over slice
	numbers := []int{1, 2, 3, 4, 5}
	for i, v := range numbers {
		fmt.Printf("Index: %d, Value: %d\n", i, v)
	}

	// Range over map
	ages := map[string]int{"Alice": 30, "Bob": 25}
	for name, age := range ages {
		fmt.Printf("%s is %d years old\n", name, age)
	}

	// Range with blank identifier
	for _, v := range numbers {
		fmt.Println(v)
	}

	// Defer statement
	defer fmt.Println("Deferred")
	defer cleanup()

	// Go statement (goroutine)
	go processAsync("data")
	go func() {
		fmt.Println("Anonymous goroutine")
	}()

	// Channel operations
	ch := make(chan int)
	buffered := make(chan string, 10)

	// Channel send
	go func() {
		ch <- 42
	}()

	// Channel receive
	value := <-ch
	fmt.Println(value)

	// Channel receive with comma-ok
	val, ok := <-ch
	if ok {
		fmt.Println(val)
	}

	// Select statement
	select {
	case msg := <-ch:
		fmt.Println("Received:", msg)
	case buffered <- "hello":
		fmt.Println("Sent")
	default:
		fmt.Println("No communication")
	}

	// Labeled statement and goto
Loop:
	for i := 0; i < 10; i++ {
		for j := 0; j < 10; j++ {
			if j == 5 {
				break Loop
			}
			if j == 2 {
				continue
			}
		}
	}

	// Goto
	if x > 50 {
		goto Skip
	}
	fmt.Println("This might be skipped")
Skip:
	fmt.Println("After skip")

	// Type assertion
	var inter interface{} = "hello"
	str, ok := inter.(string)
	if ok {
		fmt.Println("String:", str)
	}

	// Slice operations
	slice := []int{1, 2, 3, 4, 5}
	sub := slice[1:3]      // [2, 3]
	start := slice[:2]     // [1, 2]
	end := slice[3:]       // [4, 5]
	all := slice[:]        // [1, 2, 3, 4, 5]
	fullSlice := slice[1:3:4]  // 3-index slice

	_ = sub
	_ = start
	_ = end
	_ = all
	_ = fullSlice

	// Array literal
	arr := [5]int{1, 2, 3, 4, 5}
	_ = arr

	// Slice literal
	sliceLit := []string{"a", "b", "c"}
	_ = sliceLit

	// Map literal
	mapLit := map[string]int{
		"one": 1,
		"two": 2,
	}
	_ = mapLit

	// Struct literal
	p1 := Point{X: 1.0, Y: 2.0}
	p2 := Point{1.0, 2.0}
	_ = p1
	_ = p2

	// Composite literal with type
	var p3 = Point{
		X: 3.0,
		Y: 4.0,
	}
	_ = p3

	// Pointer operations
	ptr := &x
	*ptr = 200
	fmt.Println(*ptr)

	// Type conversions
	f := float64(x)
	i64 := int64(f)
	_ = i64

	// Function call
	result := sum(1, 2, 3, 4, 5)
	_ = result

	// Method call
	pt := NewPoint(3, 4)
	dist := pt.Distance()
	_ = dist

	// Variadic call with slice
	nums := []int{1, 2, 3, 4, 5}
	total := sum(nums...)
	_ = total

	// Empty statement
	;

	// Expression statement
	increment(42)

	// String concatenation
	greeting := "Hello, " + "World!"
	_ = greeting

	// Logical operators
	if x > 0 && y != "" || a == b {
		fmt.Println("Complex condition")
	}

	// Comparison operators
	equals := a == b
	notEquals := a != b
	less := a < b
	greater := a > b
	lessEq := a <= b
	greaterEq := a >= b
	_ = equals
	_ = notEquals
	_ = less
	_ = greater
	_ = lessEq
	_ = greaterEq

	// Bitwise operators
	bitwiseAnd := a & b
	bitwiseOr := a | b
	bitwiseXor := a ^ b
	leftShift := a << 2
	rightShift := a >> 1
	_ = bitwiseAnd
	_ = bitwiseOr
	_ = bitwiseXor
	_ = leftShift
	_ = rightShift

	// Unary operators
	negation := -x
	not := !true
	complement := ^a
	_ = negation
	_ = not
	_ = complement

	// Parenthesized expression
	result2 := (a + b) * (a - b)
	_ = result2

	// Comments are handled
	// Single line comment

	/*
	   Multi-line
	   comment
	*/

	// Fallthrough in switch
	value2 := 1
	switch value2 {
	case 1:
		fmt.Println("One")
		fallthrough
	case 2:
		fmt.Println("One or Two")
	default:
		fmt.Println("Other")
	}
}

// Helper functions
func compute() int {
	return 42
}

func cleanup() {
	fmt.Println("Cleaning up")
}

func processAsync(data string) {
	fmt.Println("Processing:", data)
}

// Additional type examples
type (
	// Function type
	BinaryOp func(int, int) int

	// Channel types
	SendOnly   chan<- int
	ReceiveOnly <-chan int
	Bidirectional chan int

	// Map type
	UserMap map[string]User

	// Slice type
	IntSlice []int

	// Array type
	FixedArray [10]string

	// Pointer type
	IntPointer *int
)

// Empty interface
var anything interface{}

// Method on generic type
func (s *Stack[T]) Push(item T) {
	s.items = append(s.items, item)
}

func (s *Stack[T]) Pop() T {
	if len(s.items) == 0 {
		var zero T
		return zero
	}
	item := s.items[len(s.items)-1]
	s.items = s.items[:len(s.items)-1]
	return item
}

// Init function
func init() {
	fmt.Println("Initializing package")
}
