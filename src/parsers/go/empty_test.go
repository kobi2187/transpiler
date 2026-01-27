package main

import "fmt"

func main() {
	// Empty interface literal
	var x interface{} = "hello"

	// Type assertion with interface{}
	if str, ok := x.(interface{}); ok {
		fmt.Println(str)
	}

	// Empty struct literal
	y := struct{}{}

	// Use in expression
	z := []interface{}{"a", "b", 42}

	_ = y
	_ = z
}
