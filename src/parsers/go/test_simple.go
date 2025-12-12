package main

import "fmt"

func add(a, b int) int {
	return a + b
}

func main() {
	x := 42
	result := add(x, 10)
	fmt.Println(result)
}
