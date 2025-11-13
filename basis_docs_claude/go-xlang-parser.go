package main

import (
	"encoding/json"
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"os"
	"path/filepath"
	"strings"
)

type XLangNode struct {
	Kind string      `json:"kind"`
	Data interface{} `json:"data,omitempty"`
}

type Statistics struct {
	Constructs map[string]int
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go-xlang-parser <file_or_directory>")
		os.Exit(1)
	}

	path := os.Args[1]
	stats := &Statistics{Constructs: make(map[string]int)}

	err := processPath(path, stats)
	if err != nil {
		fmt.Printf("Error processing path: %v\n", err)
		os.Exit(1)
	}

	printStatistics(stats)
}

func processPath(path string, stats *Statistics) error {
	fileInfo, err := os.Stat(path)
	if err != nil {
		return err
	}

	if fileInfo.IsDir() {
		return filepath.Walk(path, func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return err
			}
			if !info.IsDir() && strings.HasSuffix(info.Name(), ".go") {
				return processFile(path, stats)
			}
			return nil
		})
	}

	return processFile(path, stats)
}

func processFile(filename string, stats *Statistics) error {
	fset := token.NewFileSet()
	node, err := parser.ParseFile(fset, filename, nil, parser.ParseComments)
	if err != nil {
		return err
	}

	xlangAST := convertToXLang(node, stats)

	jsonData, err := json.MarshalIndent(xlangAST, "", "  ")
	if err != nil {
		return err
	}

	outputFilename := strings.TrimSuffix(filename, ".go") + ".json"
	err = os.WriteFile(outputFilename, jsonData, 0644)
	if err != nil {
		return err
	}

	fmt.Printf("Processed %s -> %s\n", filename, outputFilename)
	return nil
}

func convertToXLang(node ast.Node, stats *Statistics) XLangNode {
	switch n := node.(type) {
	case *ast.File:
		stats.Constructs["File"]++
		return XLangNode{Kind: "File", Data: map[string]interface{}{
			"Name":    n.Name.Name,
			"Imports": convertToXLang(n.Imports, stats),
			"Decls":   convertToXLang(n.Decls, stats),
		}}
	case *ast.ImportSpec:
		stats.Constructs["Import"]++
		return XLangNode{Kind: "Import", Data: map[string]interface{}{
			"Path": n.Path.Value,
			"Name": convertToXLang(n.Name, stats),
		}}
	case *ast.GenDecl:
		switch n.Tok {
		case token.TYPE:
			stats.Constructs["TypeDecl"]++
			return XLangNode{Kind: "TypeDecl", Data: convertToXLang(n.Specs, stats)}
		case token.CONST:
			stats.Constructs["ConstDecl"]++
			return XLangNode{Kind: "ConstDecl", Data: convertToXLang(n.Specs, stats)}
		case token.VAR:
			stats.Constructs["VarDecl"]++
			return XLangNode{Kind: "VarDecl", Data: convertToXLang(n.Specs, stats)}
		}
	case *ast.TypeSpec:
		stats.Constructs["TypeSpec"]++
		return XLangNode{Kind: "TypeSpec", Data: map[string]interface{}{
			"Name": n.Name.Name,
			"Type": convertToXLang(n.Type, stats),
		}}
	case *ast.StructType:
		stats.Constructs["StructType"]++
		return XLangNode{Kind: "StructType", Data: map[string]interface{}{
			"Fields": convertToXLang(n.Fields, stats),
		}}
	case *ast.InterfaceType:
		stats.Constructs["InterfaceType"]++
		return XLangNode{Kind: "InterfaceType", Data: map[string]interface{}{
			"Methods": convertToXLang(n.Methods, stats),
		}}
	case *ast.FuncDecl:
		stats.Constructs["FuncDecl"]++
		return XLangNode{Kind: "FuncDecl", Data: map[string]interface{}{
			"Name":    n.Name.Name,
			"Recv":    convertToXLang(n.Recv, stats),
			"Type":    convertToXLang(n.Type, stats),
			"Body":    convertToXLang(n.Body, stats),
		}}
	case *ast.FuncType:
		stats.Constructs["FuncType"]++
		return XLangNode{Kind: "FuncType", Data: map[string]interface{}{
			"Params":  convertToXLang(n.Params, stats),
			"Results": convertToXLang(n.Results, stats),
		}}
	case *ast.FieldList:
		if n == nil {
			return XLangNode{Kind: "FieldList", Data: nil}
		}
		fields := make([]XLangNode, len(n.List))
		for i, field := range n.List {
			fields[i] = convertToXLang(field, stats)
		}
		return XLangNode{Kind: "FieldList", Data: fields}
	case *ast.Field:
		stats.Constructs["Field"]++
		return XLangNode{Kind: "Field", Data: map[string]interface{}{
			"Names": convertToXLang(n.Names, stats),
			"Type":  convertToXLang(n.Type, stats),
			"Tag":   n.Tag.Value,
		}}
	case *ast.BlockStmt:
		stats.Constructs["BlockStmt"]++
		return XLangNode{Kind: "BlockStmt", Data: convertToXLang(n.List, stats)}
	case *ast.AssignStmt:
		stats.Constructs["AssignStmt"]++
		return XLangNode{Kind: "AssignStmt", Data: map[string]interface{}{
			"Lhs": convertToXLang(n.Lhs, stats),
			"Rhs": convertToXLang(n.Rhs, stats),
			"Tok": n.Tok.String(),
		}}
	case *ast.IfStmt:
		stats.Constructs["IfStmt"]++
		return XLangNode{Kind: "IfStmt", Data: map[string]interface{}{
			"Init": convertToXLang(n.Init, stats),
			"Cond": convertToXLang(n.Cond, stats),
			"Body": convertToXLang(n.Body, stats),
			"Else": convertToXLang(n.Else, stats),
		}}
	case *ast.SwitchStmt:
		stats.Constructs["SwitchStmt"]++
		return XLangNode{Kind: "SwitchStmt", Data: map[string]interface{}{
			"Init":   convertToXLang(n.Init, stats),
			"Tag":    convertToXLang(n.Tag, stats),
			"Body":   convertToXLang(n.Body, stats),
		}}
	case *ast.CaseClause:
		stats.Constructs["CaseClause"]++
		return XLangNode{Kind: "CaseClause", Data: map[string]interface{}{
			"List": convertToXLang(n.List, stats),
			"Body": convertToXLang(n.Body, stats),
		}}
	case *ast.ForStmt:
		stats.Constructs["ForStmt"]++
		return XLangNode{Kind: "ForStmt", Data: map[string]interface{}{
			"Init": convertToXLang(n.Init, stats),
			"Cond": convertToXLang(n.Cond, stats),
			"Post": convertToXLang(n.Post, stats),
			"Body": convertToXLang(n.Body, stats),
		}}
	case *ast.RangeStmt:
		stats.Constructs["RangeStmt"]++
		return XLangNode{Kind: "RangeStmt", Data: map[string]interface{}{
			"Key":   convertToXLang(n.Key, stats),
			"Value": convertToXLang(n.Value, stats),
			"X":     convertToXLang(n.X, stats),
			"Body":  convertToXLang(n.Body, stats),
		}}
	case *ast.DeferStmt:
		stats.Constructs["DeferStmt"]++
		return XLangNode{Kind: "DeferStmt", Data: map[string]interface{}{
			"Call": convertToXLang(n.Call, stats),
		}}
	case *ast.GoStmt:
		stats.Constructs["GoStmt"]++
		return XLangNode{Kind: "GoStmt", Data: map[string]interface{}{
			"Call": convertToXLang(n.Call, stats),
		}}
	case *ast.ReturnStmt:
		stats.Constructs["ReturnStmt"]++
		return XLangNode{Kind: "ReturnStmt", Data: convertToXLang(n.Results, stats)}
	case *ast.BranchStmt:
		stats.Constructs["BranchStmt"]++
		return XLangNode{Kind: "BranchStmt", Data: map[string]interface{}{
			"Tok":   n.Tok.String(),
			"Label": convertToXLang(n.Label, stats),
		}}
	case *ast.CallExpr:
		stats.Constructs["CallExpr"]++
		return XLangNode{Kind: "CallExpr", Data: map[string]interface{}{
			"Fun":  convertToXLang(n.Fun, stats),
			"Args": convertToXLang(n.Args, stats),
		}}
	case *ast.UnaryExpr:
		stats.Constructs["UnaryExpr"]++
		return XLangNode{Kind: "UnaryExpr", Data: map[string]interface{}{
			"Op": n.Op.String(),
			"X":  convertToXLang(n.X, stats),
		}}
	case *ast.BinaryExpr:
		stats.Constructs["BinaryExpr"]++
		return XLangNode{Kind: "BinaryExpr", Data: map[string]interface{}{
			"X":  convertToXLang(n.X, stats),
			"Op": n.Op.String(),
			"Y":  convertToXLang(n.Y, stats),
		}}
	case *ast.IndexExpr:
		stats.Constructs["IndexExpr"]++
		return XLangNode{Kind: "IndexExpr", Data: map[string]interface{}{
			"X":     convertToXLang(n.X, stats),
			"Index": convertToXLang(n.Index, stats),
		}}
	case *ast.SliceExpr:
		stats.Constructs["SliceExpr"]++
		return XLangNode{Kind: "SliceExpr", Data: map[string]interface{}{
			"X":    convertToXLang(n.X, stats),
			"Low":  convertToXLang(n.Low, stats),
			"High": convertToXLang(n.High, stats),
			"Max":  convertToXLang(n.Max, stats),
		}}
	case *ast.CompositeLit:
		stats.Constructs["CompositeLit"]++
		return XLangNode{Kind: "CompositeLit", Data: map[string]interface{}{
			"Type": convertToXLang(n.Type, stats),
			"Elts": convertToXLang(n.Elts, stats),
		}}
	case *ast.ChanType:
		stats.Constructs["ChanType"]++
		return XLangNode{Kind: "ChanType", Data: map[string]interface{}{
			"Dir":   n.Dir,
			"Value": convertToXLang(n.Value, stats),
		}}
	case *ast.Ident:
		stats.Constructs["Ident"]++
		return XLangNode{Kind: "Ident", Data: n.Name}
	case *ast.BasicLit:
		stats.Constructs["BasicLit"]++
		return XLangNode{Kind: "BasicLit", Data: map[string]interface{}{
			"Kind":  n.Kind.String(),
			"Value": n.Value,
		}}
	case []ast.Stmt:
		stmts := make([]XLangNode, len(n))
		for i, stmt := range n {
			stmts[i] = convertToXLang(stmt, stats)
		}
		return XLangNode{Kind: "StmtList", Data: stmts}
	case []ast.Expr:
		exprs := make([]XLangNode, len(n))
		for i, expr := range n {
			exprs[i] = convertToXLang(expr, stats)
		}
		return XLangNode{Kind: "ExprList", Data: exprs}
	case []ast.Decl:
		decls := make([]XLangNode, len(n))
		for i, decl := range n {
			decls[i] = convertToXLang(decl, stats)
		}
		return XLangNode{Kind: "DeclList", Data: decls}
	case []*ast.ImportSpec:
		imports := make([]XLangNode, len(n))
		for i, imp := range n {
			imports[i] = convertToXLang(imp, stats)
		}
		return XLangNode{Kind: "ImportList", Data: imports}
	case []*ast.Ident:
		idents := make([]string, len(n))
		for i, ident := range n {
			idents[i] = ident.Name
		}
		return XLangNode{Kind: "IdentList", Data: idents}
	default:
		stats.Constructs["Unhandled"]++
		return XLangNode{Kind: "Unhandled", Data: fmt.Sprintf("%T", n)}
	}
	return XLangNode{Kind: "Unknown", Data: nil}
}

func printStatistics(stats *Statistics) {
	fmt.Println("\nStatistics:")
	for construct, count := range stats.Constructs {
		fmt.Printf("%s: %d\n", construct, count)
	}
}
