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

	outputFilename := strings.TrimSuffix(filename, ".go") + ".xlang.json"
	err = os.WriteFile(outputFilename, jsonData, 0644)
	if err != nil {
		return err
	}

	fmt.Printf("Processed %s -> %s\n", filename, outputFilename)
	return nil
}

func convertToXLang(node ast.Node, stats *Statistics) XLangNode {
	switch n := node.(type) {
	// ========== File and Package ==========
	case *ast.File:
		stats.Constructs["File"]++
		return XLangNode{Kind: "File", Data: map[string]interface{}{
			"Name":     n.Name.Name,
			"Imports":  convertToXLangList(n.Imports, stats),
			"Decls":    convertToXLangList(n.Decls, stats),
			"Comments": convertCommentGroups(n.Comments, stats),
		}}

	// ========== Declarations ==========
	case *ast.BadDecl:
		stats.Constructs["BadDecl"]++
		return XLangNode{Kind: "BadDecl", Data: "syntax error"}

	case *ast.GenDecl:
		switch n.Tok {
		case token.IMPORT:
			stats.Constructs["ImportDecl"]++
			return XLangNode{Kind: "ImportDecl", Data: convertToXLangList(n.Specs, stats)}
		case token.TYPE:
			stats.Constructs["TypeDecl"]++
			return XLangNode{Kind: "TypeDecl", Data: convertToXLangList(n.Specs, stats)}
		case token.CONST:
			stats.Constructs["ConstDecl"]++
			return XLangNode{Kind: "ConstDecl", Data: convertToXLangList(n.Specs, stats)}
		case token.VAR:
			stats.Constructs["VarDecl"]++
			return XLangNode{Kind: "VarDecl", Data: convertToXLangList(n.Specs, stats)}
		}

	case *ast.FuncDecl:
		stats.Constructs["FuncDecl"]++
		data := map[string]interface{}{
			"Name": n.Name.Name,
			"Type": convertToXLang(n.Type, stats),
		}
		if n.Recv != nil {
			data["Recv"] = convertToXLang(n.Recv, stats)
		}
		if n.Body != nil {
			data["Body"] = convertToXLang(n.Body, stats)
		}
		// Handle type parameters (Go 1.18+)
		if n.Type != nil && n.Type.TypeParams != nil {
			data["TypeParams"] = convertToXLang(n.Type.TypeParams, stats)
		}
		return XLangNode{Kind: "FuncDecl", Data: data}

	// ========== Specifications ==========
	case *ast.ImportSpec:
		stats.Constructs["Import"]++
		name := ""
		if n.Name != nil {
			name = n.Name.Name
		}
		return XLangNode{Kind: "Import", Data: map[string]interface{}{
			"Path": n.Path.Value,
			"Name": name,
		}}

	case *ast.TypeSpec:
		stats.Constructs["TypeSpec"]++
		data := map[string]interface{}{
			"Name": n.Name.Name,
			"Type": convertToXLang(n.Type, stats),
		}
		// Handle type parameters (Go 1.18+ generics)
		if n.TypeParams != nil {
			data["TypeParams"] = convertToXLang(n.TypeParams, stats)
		}
		return XLangNode{Kind: "TypeSpec", Data: data}

	case *ast.ValueSpec:
		stats.Constructs["ValueSpec"]++
		names := make([]string, len(n.Names))
		for i, name := range n.Names {
			names[i] = name.Name
		}
		data := map[string]interface{}{
			"Names": names,
		}
		if n.Type != nil {
			data["Type"] = convertToXLang(n.Type, stats)
		}
		if len(n.Values) > 0 {
			data["Values"] = convertToXLangList(n.Values, stats)
		}
		return XLangNode{Kind: "ValueSpec", Data: data}

	// ========== Type Expressions ==========
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

	case *ast.FuncType:
		stats.Constructs["FuncType"]++
		data := map[string]interface{}{}
		if n.Params != nil {
			data["Params"] = convertToXLang(n.Params, stats)
		}
		if n.Results != nil {
			data["Results"] = convertToXLang(n.Results, stats)
		}
		if n.TypeParams != nil {
			data["TypeParams"] = convertToXLang(n.TypeParams, stats)
		}
		return XLangNode{Kind: "FuncType", Data: data}

	case *ast.ArrayType:
		stats.Constructs["ArrayType"]++
		data := map[string]interface{}{
			"Elt": convertToXLang(n.Elt, stats),
		}
		if n.Len != nil {
			data["Len"] = convertToXLang(n.Len, stats)
		}
		return XLangNode{Kind: "ArrayType", Data: data}

	case *ast.MapType:
		stats.Constructs["MapType"]++
		return XLangNode{Kind: "MapType", Data: map[string]interface{}{
			"Key":   convertToXLang(n.Key, stats),
			"Value": convertToXLang(n.Value, stats),
		}}

	case *ast.ChanType:
		stats.Constructs["ChanType"]++
		return XLangNode{Kind: "ChanType", Data: map[string]interface{}{
			"Dir":   int(n.Dir),
			"Value": convertToXLang(n.Value, stats),
		}}

	case *ast.StarExpr:
		stats.Constructs["StarExpr"]++
		return XLangNode{Kind: "StarExpr", Data: map[string]interface{}{
			"X": convertToXLang(n.X, stats),
		}}

	case *ast.Ellipsis:
		stats.Constructs["Ellipsis"]++
		data := map[string]interface{}{}
		if n.Elt != nil {
			data["Elt"] = convertToXLang(n.Elt, stats)
		}
		return XLangNode{Kind: "Ellipsis", Data: data}

	// ========== Field and Field List ==========
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
		names := make([]string, len(n.Names))
		for i, name := range n.Names {
			names[i] = name.Name
		}
		data := map[string]interface{}{
			"Names": names,
		}
		if n.Type != nil {
			data["Type"] = convertToXLang(n.Type, stats)
		}
		if n.Tag != nil {
			data["Tag"] = n.Tag.Value
		}
		return XLangNode{Kind: "Field", Data: data}

	// ========== Statements ==========
	case *ast.BadStmt:
		stats.Constructs["BadStmt"]++
		return XLangNode{Kind: "BadStmt", Data: "syntax error"}

	case *ast.DeclStmt:
		stats.Constructs["DeclStmt"]++
		return XLangNode{Kind: "DeclStmt", Data: convertToXLang(n.Decl, stats)}

	case *ast.EmptyStmt:
		stats.Constructs["EmptyStmt"]++
		return XLangNode{Kind: "EmptyStmt", Data: nil}

	case *ast.LabeledStmt:
		stats.Constructs["LabeledStmt"]++
		return XLangNode{Kind: "LabeledStmt", Data: map[string]interface{}{
			"Label": n.Label.Name,
			"Stmt":  convertToXLang(n.Stmt, stats),
		}}

	case *ast.ExprStmt:
		stats.Constructs["ExprStmt"]++
		return XLangNode{Kind: "ExprStmt", Data: convertToXLang(n.X, stats)}

	case *ast.SendStmt:
		stats.Constructs["SendStmt"]++
		return XLangNode{Kind: "SendStmt", Data: map[string]interface{}{
			"Chan":  convertToXLang(n.Chan, stats),
			"Value": convertToXLang(n.Value, stats),
		}}

	case *ast.IncDecStmt:
		stats.Constructs["IncDecStmt"]++
		return XLangNode{Kind: "IncDecStmt", Data: map[string]interface{}{
			"X":   convertToXLang(n.X, stats),
			"Tok": n.Tok.String(),
		}}

	case *ast.AssignStmt:
		stats.Constructs["AssignStmt"]++
		return XLangNode{Kind: "AssignStmt", Data: map[string]interface{}{
			"Lhs": convertToXLangList(n.Lhs, stats),
			"Rhs": convertToXLangList(n.Rhs, stats),
			"Tok": n.Tok.String(),
		}}

	case *ast.GoStmt:
		stats.Constructs["GoStmt"]++
		return XLangNode{Kind: "GoStmt", Data: map[string]interface{}{
			"Call": convertToXLang(n.Call, stats),
		}}

	case *ast.DeferStmt:
		stats.Constructs["DeferStmt"]++
		return XLangNode{Kind: "DeferStmt", Data: map[string]interface{}{
			"Call": convertToXLang(n.Call, stats),
		}}

	case *ast.ReturnStmt:
		stats.Constructs["ReturnStmt"]++
		return XLangNode{Kind: "ReturnStmt", Data: convertToXLangList(n.Results, stats)}

	case *ast.BranchStmt:
		stats.Constructs["BranchStmt"]++
		data := map[string]interface{}{
			"Tok": n.Tok.String(),
		}
		if n.Label != nil {
			data["Label"] = convertToXLang(n.Label, stats)
		}
		return XLangNode{Kind: "BranchStmt", Data: data}

	case *ast.BlockStmt:
		stats.Constructs["BlockStmt"]++
		return XLangNode{Kind: "BlockStmt", Data: convertToXLangList(n.List, stats)}

	case *ast.IfStmt:
		stats.Constructs["IfStmt"]++
		data := map[string]interface{}{
			"Cond": convertToXLang(n.Cond, stats),
			"Body": convertToXLang(n.Body, stats),
		}
		if n.Init != nil {
			data["Init"] = convertToXLang(n.Init, stats)
		}
		if n.Else != nil {
			data["Else"] = convertToXLang(n.Else, stats)
		}
		return XLangNode{Kind: "IfStmt", Data: data}

	case *ast.CaseClause:
		stats.Constructs["CaseClause"]++
		data := map[string]interface{}{
			"Body": convertToXLangList(n.Body, stats),
		}
		if len(n.List) > 0 {
			data["List"] = convertToXLangList(n.List, stats)
		}
		return XLangNode{Kind: "CaseClause", Data: data}

	case *ast.SwitchStmt:
		stats.Constructs["SwitchStmt"]++
		data := map[string]interface{}{
			"Body": convertToXLang(n.Body, stats),
		}
		if n.Init != nil {
			data["Init"] = convertToXLang(n.Init, stats)
		}
		if n.Tag != nil {
			data["Tag"] = convertToXLang(n.Tag, stats)
		}
		return XLangNode{Kind: "SwitchStmt", Data: data}

	case *ast.TypeSwitchStmt:
		stats.Constructs["TypeSwitchStmt"]++
		data := map[string]interface{}{
			"Assign": convertToXLang(n.Assign, stats),
			"Body":   convertToXLang(n.Body, stats),
		}
		if n.Init != nil {
			data["Init"] = convertToXLang(n.Init, stats)
		}
		return XLangNode{Kind: "TypeSwitchStmt", Data: data}

	case *ast.CommClause:
		stats.Constructs["CommClause"]++
		data := map[string]interface{}{
			"Body": convertToXLangList(n.Body, stats),
		}
		if n.Comm != nil {
			data["Comm"] = convertToXLang(n.Comm, stats)
		}
		return XLangNode{Kind: "CommClause", Data: data}

	case *ast.SelectStmt:
		stats.Constructs["SelectStmt"]++
		return XLangNode{Kind: "SelectStmt", Data: map[string]interface{}{
			"Body": convertToXLang(n.Body, stats),
		}}

	case *ast.ForStmt:
		stats.Constructs["ForStmt"]++
		data := map[string]interface{}{
			"Body": convertToXLang(n.Body, stats),
		}
		if n.Init != nil {
			data["Init"] = convertToXLang(n.Init, stats)
		}
		if n.Cond != nil {
			data["Cond"] = convertToXLang(n.Cond, stats)
		}
		if n.Post != nil {
			data["Post"] = convertToXLang(n.Post, stats)
		}
		return XLangNode{Kind: "ForStmt", Data: data}

	case *ast.RangeStmt:
		stats.Constructs["RangeStmt"]++
		data := map[string]interface{}{
			"X":    convertToXLang(n.X, stats),
			"Body": convertToXLang(n.Body, stats),
			"Tok":  n.Tok.String(),
		}
		if n.Key != nil {
			data["Key"] = convertToXLang(n.Key, stats)
		}
		if n.Value != nil {
			data["Value"] = convertToXLang(n.Value, stats)
		}
		return XLangNode{Kind: "RangeStmt", Data: data}

	// ========== Expressions ==========
	case *ast.BadExpr:
		stats.Constructs["BadExpr"]++
		return XLangNode{Kind: "BadExpr", Data: "syntax error"}

	case *ast.Ident:
		stats.Constructs["Ident"]++
		return XLangNode{Kind: "Ident", Data: n.Name}

	case *ast.BasicLit:
		stats.Constructs["BasicLit"]++
		return XLangNode{Kind: "BasicLit", Data: map[string]interface{}{
			"Kind":  n.Kind.String(),
			"Value": n.Value,
		}}

	case *ast.FuncLit:
		stats.Constructs["FuncLit"]++
		return XLangNode{Kind: "FuncLit", Data: map[string]interface{}{
			"Type": convertToXLang(n.Type, stats),
			"Body": convertToXLang(n.Body, stats),
		}}

	case *ast.CompositeLit:
		stats.Constructs["CompositeLit"]++
		data := map[string]interface{}{
			"Elts": convertToXLangList(n.Elts, stats),
		}
		if n.Type != nil {
			data["Type"] = convertToXLang(n.Type, stats)
		}
		return XLangNode{Kind: "CompositeLit", Data: data}

	case *ast.ParenExpr:
		stats.Constructs["ParenExpr"]++
		return XLangNode{Kind: "ParenExpr", Data: map[string]interface{}{
			"X": convertToXLang(n.X, stats),
		}}

	case *ast.SelectorExpr:
		stats.Constructs["SelectorExpr"]++
		return XLangNode{Kind: "SelectorExpr", Data: map[string]interface{}{
			"X":   convertToXLang(n.X, stats),
			"Sel": n.Sel.Name,
		}}

	case *ast.IndexExpr:
		stats.Constructs["IndexExpr"]++
		return XLangNode{Kind: "IndexExpr", Data: map[string]interface{}{
			"X":     convertToXLang(n.X, stats),
			"Index": convertToXLang(n.Index, stats),
		}}

	case *ast.IndexListExpr:
		stats.Constructs["IndexListExpr"]++
		return XLangNode{Kind: "IndexListExpr", Data: map[string]interface{}{
			"X":       convertToXLang(n.X, stats),
			"Indices": convertToXLangList(n.Indices, stats),
		}}

	case *ast.SliceExpr:
		stats.Constructs["SliceExpr"]++
		data := map[string]interface{}{
			"X": convertToXLang(n.X, stats),
		}
		if n.Low != nil {
			data["Low"] = convertToXLang(n.Low, stats)
		}
		if n.High != nil {
			data["High"] = convertToXLang(n.High, stats)
		}
		if n.Max != nil {
			data["Max"] = convertToXLang(n.Max, stats)
		}
		data["Slice3"] = n.Slice3
		return XLangNode{Kind: "SliceExpr", Data: data}

	case *ast.TypeAssertExpr:
		stats.Constructs["TypeAssertExpr"]++
		data := map[string]interface{}{
			"X": convertToXLang(n.X, stats),
		}
		if n.Type != nil {
			data["Type"] = convertToXLang(n.Type, stats)
		}
		return XLangNode{Kind: "TypeAssertExpr", Data: data}

	case *ast.CallExpr:
		stats.Constructs["CallExpr"]++
		return XLangNode{Kind: "CallExpr", Data: map[string]interface{}{
			"Fun":      convertToXLang(n.Fun, stats),
			"Args":     convertToXLangList(n.Args, stats),
			"Ellipsis": n.Ellipsis != token.NoPos,
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

	case *ast.KeyValueExpr:
		stats.Constructs["KeyValueExpr"]++
		return XLangNode{Kind: "KeyValueExpr", Data: map[string]interface{}{
			"Key":   convertToXLang(n.Key, stats),
			"Value": convertToXLang(n.Value, stats),
		}}

	// ========== Comments ==========
	case *ast.Comment:
		stats.Constructs["Comment"]++
		return XLangNode{Kind: "Comment", Data: map[string]interface{}{
			"Text": n.Text,
		}}

	case *ast.CommentGroup:
		stats.Constructs["CommentGroup"]++
		comments := make([]string, len(n.List))
		for i, comment := range n.List {
			comments[i] = comment.Text
		}
		return XLangNode{Kind: "CommentGroup", Data: map[string]interface{}{
			"List": comments,
		}}

	case nil:
		return XLangNode{Kind: "Nil", Data: nil}

	default:
		stats.Constructs["Unhandled"]++
		return XLangNode{Kind: "Unhandled", Data: fmt.Sprintf("%T", n)}
	}

	return XLangNode{Kind: "Unknown", Data: nil}
}

func convertToXLangList(nodes interface{}, stats *Statistics) []XLangNode {
	switch n := nodes.(type) {
	case []ast.Stmt:
		stmts := make([]XLangNode, len(n))
		for i, stmt := range n {
			stmts[i] = convertToXLang(stmt, stats)
		}
		return stmts
	case []ast.Expr:
		exprs := make([]XLangNode, len(n))
		for i, expr := range n {
			exprs[i] = convertToXLang(expr, stats)
		}
		return exprs
	case []ast.Decl:
		decls := make([]XLangNode, len(n))
		for i, decl := range n {
			decls[i] = convertToXLang(decl, stats)
		}
		return decls
	case []*ast.ImportSpec:
		imports := make([]XLangNode, len(n))
		for i, imp := range n {
			imports[i] = convertToXLang(imp, stats)
		}
		return imports
	case []ast.Spec:
		specs := make([]XLangNode, len(n))
		for i, spec := range n {
			specs[i] = convertToXLang(spec, stats)
		}
		return specs
	}
	return []XLangNode{}
}

func convertCommentGroups(groups []*ast.CommentGroup, stats *Statistics) []XLangNode {
	if groups == nil {
		return nil
	}
	result := make([]XLangNode, len(groups))
	for i, group := range groups {
		result[i] = convertToXLang(group, stats)
	}
	return result
}

func printStatistics(stats *Statistics) {
	fmt.Println("\nGo AST Node Statistics:")
	fmt.Println("=======================")
	for construct, count := range stats.Constructs {
		fmt.Printf("%-20s: %d\n", construct, count)
	}
	fmt.Printf("\nTotal node types: %d\n", len(stats.Constructs))
}
