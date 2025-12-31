package main

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// Main function: Handles command-line arguments and orchestrates the flow
func main() {
	if len(os.Args) < 3 {
		fmt.Println("Usage: go run main.go <input_directory_or_file> <output_dot_file>")
		return
	}

	inputPath := os.Args[1]
	outputPath := os.Args[2]

	// Traverse the directory or process the single file
	goFiles, err := traverseDirectory(inputPath)
	if err != nil {
		fmt.Println("Error traversing directory:", err)
		return
	}

	// Map to hold imports with their respective files
	imports := make(map[string][]string)

	// Extract imports from each Go file
	for _, file := range goFiles {
		fileImports, err := extractImports(file)
		if err != nil {
			fmt.Println("Error extracting imports from", file, ":", err)
			continue
		}
		imports[file] = fileImports
	}

	// Build and write the dependency graph to a .dot file
	err = writeDotFile(imports, outputPath)
	if err != nil {
		fmt.Println("Error writing dot file:", err)
		return
	}

	// Count and print import occurrences
	importCount := countImports(imports)
	fmt.Println("Import count:")
	for imp, count := range importCount {
		fmt.Printf("%s: %d\n", imp, count)
	}
}

// Traverse the directory to find all Go files
func traverseDirectory(path string) ([]string, error) {
	var goFiles []string

	err := filepath.Walk(path, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && strings.HasSuffix(path, ".go") {
			goFiles = append(goFiles, path)
		}
		return nil
	})

	return goFiles, err
}

// Extract imports from a Go file
func extractImports(filePath string) ([]string, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	var imports []string
	scanner := bufio.NewScanner(file)
	importRegex := regexp.MustCompile(`^import\s+(".*?"|\(.*?\))`)

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if matches := importRegex.FindStringSubmatch(line); matches != nil {
			imports = append(imports, parseImports(line)...)
		}
	}

	if err := scanner.Err(); err != nil {
		return nil, err
	}

	return imports, nil
}

// Parse the import line into individual imports
func parseImports(importLine string) []string {
	var imports []string

	if strings.HasPrefix(importLine, "import (") {
		// Multiline import block
		importsBlock := strings.TrimPrefix(importLine, "import (")
		importsBlock = strings.TrimSuffix(importsBlock, ")")
		importLines := strings.Split(importsBlock, "\n")
		for _, imp := range importLines {
			imp = strings.TrimSpace(imp)
			if len(imp) > 0 {
				imports = append(imports, strings.Trim(imp, "\""))
			}
		}
	} else {
		// Single-line import
		imp := strings.TrimPrefix(importLine, "import ")
		imports = append(imports, strings.Trim(imp, "\""))
	}

	return imports
}

// Write the dependency graph to a .dot file
func writeDotFile(graph map[string][]string, outputPath string) error {
	file, err := os.Create(outputPath)
	if err != nil {
		return err
	}
	defer file.Close()

	file.WriteString("digraph G {\n")

	for file, deps := range graph {
		for _, dep := range deps {
			file.WriteString(fmt.Sprintf("\t\"%s\" -> \"%s\";\n", file, dep))
		}
	}

	file.WriteString("}\n")
	return nil
}

// Count the occurrences of each import
func countImports(imports map[string][]string) map[string]int {
	counts := make(map[string]int)

	for _, deps := range imports {
		for _, dep := range deps {
			counts[dep]++
		}
	}

	return counts
}
