package main

import (
	"encoding/json"
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"os"
	"path/filepath"
	"reflect"
	"strings"
)

type Statistics struct {
	Constructs       map[string]int
	CurrentFile      string
	contextStack     []string
	UnhandledTypes   map[string]int // Track types of unhandled nodes
	UnhandledSamples []string       // Sample file locations
}

func (s *Statistics) pushContext(ctx string) {
	s.contextStack = append(s.contextStack, ctx)
}

func (s *Statistics) popContext() {
	if len(s.contextStack) > 0 {
		s.contextStack = s.contextStack[:len(s.contextStack)-1]
	}
}

func (s *Statistics) getContext() string {
	if len(s.contextStack) == 0 {
		return ""
	}
	return strings.Join(s.contextStack, " > ")
}

// Map Go operators to XLang semantic operator names
var binaryOpMap = map[string]string{
	"+":   "add",
	"-":   "sub",
	"*":   "mul",
	"/":   "div",
	"%":   "mod",
	"&":   "bitand",
	"|":   "bitor",
	"^":   "bitxor",
	"<<":  "shl",
	">>":  "shr",
	"&^":  "bitandnot", // Go-specific: bit clear
	"==":  "eq",
	"!=":  "neq",
	"<":   "lt",
	"<=":  "le",
	">":   "gt",
	">=":  "ge",
	"&&":  "and",
	"||":  "or",
	"+=":  "adda",
	"-=":  "suba",
	"*=":  "mula",
	"/=":  "diva",
	"%=":  "moda",
	"&=":  "bitanda",
	"|=":  "bitora",
	"^=":  "bitxora",
	"<<=": "shla",
	">>=": "shra",
}

var unaryOpMap = map[string]string{
	"-":  "neg",
	"+":  "pos",
	"!":  "not",
	"^":  "bitnot", // Go uses ^ for bitwise NOT (unlike C which uses ~)
	"*":  "deref",
	"&":  "ref",
	"++": "postinc",  // Go's ++ is always post-increment (statement, not expr)
	"--": "postdec",  // Go's -- is always post-decrement (statement, not expr)
	"<-": "chanrecv", // Go channel receive operator
}

func normalizeBinaryOp(op string) string {
	if mapped, ok := binaryOpMap[op]; ok {
		return mapped
	}
	return op
}

func normalizeUnaryOp(op string) string {
	if mapped, ok := unaryOpMap[op]; ok {
		return mapped
	}
	return op
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go-xlang-parser <file_or_directory>")
		os.Exit(1)
	}

	path := os.Args[1]
	stats := &Statistics{
		Constructs:       make(map[string]int),
		UnhandledTypes:   make(map[string]int),
		UnhandledSamples: []string{},
	}

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
	stats.CurrentFile = filename
	stats.contextStack = []string{} // Reset context for new file

	fset := token.NewFileSet()
	node, err := parser.ParseFile(fset, filename, nil, parser.ParseComments)
	if err != nil {
		fmt.Printf("Parse error in %s: %v (skipping)\n", filename, err)
		return nil // Continue processing other files
	}

	xlangAST := convertToXLang(node, stats)

	// Use encoder with SetEscapeHTML(false) to prevent escaping <, >, &
	var buf strings.Builder
	encoder := json.NewEncoder(&buf)
	encoder.SetEscapeHTML(false)
	encoder.SetIndent("", "  ")
	err = encoder.Encode(xlangAST)
	if err != nil {
		return err
	}

	outputFilename := strings.TrimSuffix(filename, ".go") + ".xljs"
	err = os.WriteFile(outputFilename, []byte(buf.String()), 0644)
	if err != nil {
		return err
	}

	fmt.Printf("Processed %s -> %s\n", filename, outputFilename)
	return nil
}

func convertToXLang(node ast.Node, stats *Statistics) map[string]interface{} {
	// Check for untyped nil
	if node == nil {
		// Expected nil for optional AST fields (e.g., else clause, type annotation, etc.)
		return nil
	}

	// Check for typed nil (interface with type but nil value)
	// This must be checked BEFORE the node == nil check would short-circuit
	rv := reflect.ValueOf(node)
	if rv.Kind() == reflect.Ptr && rv.IsNil() {
		context := stats.getContext()
		if context == "" {
			context = "unknown"
		}
		fmt.Printf("WARNING: typed nil node in %s | context: %s | type: %T\n", stats.CurrentFile, context, node)
		return nil
	}

	switch n := node.(type) {
	// ========== File ==========
	case *ast.File:
		stats.Constructs["xnkFile"]++
		decls := []interface{}{}

		// Add imports
		for _, imp := range n.Imports {
			decls = append(decls, convertToXLang(imp, stats))
		}

		// Add declarations
		for _, decl := range n.Decls {
			converted := convertToXLang(decl, stats)
			if converted != nil {
				decls = append(decls, converted)
			}
		}

		return map[string]interface{}{
			"kind":        "xnkFile",
			"fileName":    filepath.Base(n.Name.Name + ".go"),
			"sourceLang":  "go",
			"moduleDecls": decls,
		}

	// ========== Import ==========
	case *ast.ImportSpec:
		stats.Constructs["xnkImport"]++
		path := strings.Trim(n.Path.Value, `"`)
		result := map[string]interface{}{
			"kind":        "xnkImport",
			"importPath":  path,
			"importAlias": nil,
		}
		if n.Name != nil {
			result["importAlias"] = n.Name.Name
		}
		return result

	// ========== Declarations ==========
	case *ast.GenDecl:
		// Handle based on token type
		switch n.Tok {
		case token.IMPORT:
			// Already handled in File case
			return nil
		case token.CONST:
			if len(n.Specs) > 0 {
				return convertValueSpec(n.Specs[0].(*ast.ValueSpec), true, stats)
			}
		case token.VAR:
			if len(n.Specs) > 0 {
				return convertValueSpec(n.Specs[0].(*ast.ValueSpec), false, stats)
			}
		case token.TYPE:
			if len(n.Specs) > 0 {
				return convertTypeSpec(n.Specs[0].(*ast.TypeSpec), stats)
			}
		}
		return nil

	case *ast.FuncDecl:
		if n.Recv != nil {
			// Method declaration
			stats.Constructs["xnkMethodDecl"]++
			return convertMethod(n, stats)
		} else {
			// Function declaration
			stats.Constructs["xnkFuncDecl"]++
			return convertFunc(n, stats)
		}

	// ========== Statements ==========
	case *ast.BlockStmt:
		stats.Constructs["xnkBlockStmt"]++
		stmts := []interface{}{}
		for _, stmt := range n.List {
			converted := convertToXLang(stmt, stats)
			if converted != nil {
				stmts = append(stmts, converted)
			}
		}
		return map[string]interface{}{
			"kind":      "xnkBlockStmt",
			"blockBody": stmts,
		}

	case *ast.AssignStmt:
		stats.Constructs["xnkAsgn"]++
		if n.Tok == token.DEFINE {
			// Short variable declaration :=
			if len(n.Lhs) > 0 && len(n.Rhs) > 0 {
				lhs := n.Lhs[0]
				if ident, ok := lhs.(*ast.Ident); ok {
					return map[string]interface{}{
						"kind":        "xnkVarDecl",
						"declName":    ident.Name,
						"declType":    nil,
						"initializer": convertToXLang(n.Rhs[0], stats),
					}
				}
			}
		}
		// Regular assignment
		if len(n.Lhs) > 0 && len(n.Rhs) > 0 {
			return map[string]interface{}{
				"kind":      "xnkAsgn",
				"asgnLeft":  convertToXLang(n.Lhs[0], stats),
				"asgnRight": convertToXLang(n.Rhs[0], stats),
			}
		}
		return nil

	case *ast.IfStmt:
		stats.Constructs["xnkIfStmt"]++

		// Collect elif branches
		elifBranches := []interface{}{}
		var elseBody interface{} = nil

		// Walk the else chain to collect elif branches
		current := n.Else
		for current != nil {
			if elseIf, ok := current.(*ast.IfStmt); ok {
				// This is an elif branch
				elifBranches = append(elifBranches, map[string]interface{}{
					"condition": convertToXLang(elseIf.Cond, stats),
					"body":      convertToXLang(elseIf.Body, stats),
				})
				current = elseIf.Else
			} else if blockStmt, ok := current.(*ast.BlockStmt); ok {
				// This is the final else block
				elseBody = convertToXLang(blockStmt, stats)
				break
			} else {
				// Shouldn't happen, but handle it
				elseBody = convertToXLang(current, stats)
				break
			}
		}

		return map[string]interface{}{
			"kind":         "xnkIfStmt",
			"ifCondition":  convertToXLang(n.Cond, stats),
			"ifBody":       convertToXLang(n.Body, stats),
			"elifBranches": elifBranches,
			"elseBody":     elseBody,
		}

	case *ast.ForStmt:
		if n.Init == nil && n.Post == nil {
			// While-style loop
			stats.Constructs["xnkWhileStmt"]++
			cond := convertToXLang(n.Cond, stats)
			if cond == nil {
				// Infinite loop: for { }
				cond = map[string]interface{}{
					"kind":      "xnkBoolLit",
					"boolValue": true,
				}
			}
			return map[string]interface{}{
				"kind":           "xnkWhileStmt",
				"whileCondition": cond,
				"whileBody":      convertToXLang(n.Body, stats),
			}
		} else {
			// C-style for loop
			stats.Constructs["xnkExternal_ForStmt"]++
			return map[string]interface{}{
				"kind":            "xnkExternal_ForStmt",
				"extForInit":      convertToXLang(n.Init, stats),
				"extForCond":      convertToXLang(n.Cond, stats),
				"extForIncrement": convertToXLang(n.Post, stats),
				"extForBody":      convertToXLang(n.Body, stats),
			}
		}

	case *ast.RangeStmt:
		stats.Constructs["xnkForeachStmt"]++
		key := convertToXLang(n.Key, stats)
		if key == nil {
			key = map[string]interface{}{
				"kind":      "xnkIdentifier",
				"identName": "_",
			}
		}
		return map[string]interface{}{
			"kind":        "xnkForeachStmt",
			"foreachVar":  key,
			"foreachIter": convertToXLang(n.X, stats),
			"foreachBody": convertToXLang(n.Body, stats),
		}

	case *ast.ReturnStmt:
		stats.Constructs["xnkReturnStmt"]++
		var returnExpr interface{} = nil
		if len(n.Results) > 0 {
			if len(n.Results) == 1 {
				returnExpr = convertToXLang(n.Results[0], stats)
			} else {
				// Multiple return values - use tuple
				elements := []interface{}{}
				for _, result := range n.Results {
					elements = append(elements, convertToXLang(result, stats))
				}
				returnExpr = map[string]interface{}{
					"kind":     "xnkTupleExpr",
					"elements": elements,
				}
			}
		}
		return map[string]interface{}{
			"kind":       "xnkReturnStmt",
			"returnExpr": returnExpr,
		}

	case *ast.SwitchStmt:
		cases := []interface{}{}
		if n.Body != nil {
			for _, stmt := range n.Body.List {
				if caseClause, ok := stmt.(*ast.CaseClause); ok {
					cases = append(cases, convertCaseClause(caseClause, stats))
				}
			}
		}

		// Check if this is a tagless switch (switch without expression)
		if n.Tag == nil {
			stats.Constructs["xnkExternal_GoTaglessSwitch"]++
			return map[string]interface{}{
				"kind":                    "xnkExternal_GoTaglessSwitch",
				"extGoTaglessSwitchCases": cases,
			}
		}

		// Regular switch with expression
		stats.Constructs["xnkSwitchStmt"]++
		return map[string]interface{}{
			"kind":        "xnkSwitchStmt",
			"switchExpr":  convertToXLang(n.Tag, stats),
			"switchCases": cases,
		}

	case *ast.DeferStmt:
		stats.Constructs["xnkDeferStmt"]++
		return map[string]interface{}{
			"kind":       "xnkDeferStmt",
			"staticBody": convertToXLang(n.Call, stats),
		}

	case *ast.GoStmt:
		// Go statement - mark as goroutine via metadata
		stats.Constructs["xnkCallExpr(goroutine)"]++
		callExpr := convertToXLang(n.Call, stats)
		if callExpr != nil {
			callExpr["isGoroutine"] = true
		}
		return callExpr

	case *ast.ExprStmt:
		// Expression as statement
		return convertToXLang(n.X, stats)

	case *ast.BranchStmt:
		switch n.Tok {
		case token.BREAK:
			stats.Constructs["xnkBreakStmt"]++
			return map[string]interface{}{
				"kind":  "xnkBreakStmt",
				"label": nil,
			}
		case token.CONTINUE:
			stats.Constructs["xnkContinueStmt"]++
			return map[string]interface{}{
				"kind":  "xnkContinueStmt",
				"label": nil,
			}
		case token.GOTO:
			stats.Constructs["xnkGotoStmt"]++
			label := ""
			if n.Label != nil {
				label = n.Label.Name
			}
			return map[string]interface{}{
				"kind":      "xnkGotoStmt",
				"gotoLabel": label,
			}
		}
		return nil

	case *ast.LabeledStmt:
		stats.Constructs["xnkLabeledStmt"]++
		return map[string]interface{}{
			"kind":        "xnkLabeledStmt",
			"labelName":   n.Label.Name,
			"labeledStmt": convertToXLang(n.Stmt, stats),
		}

	case *ast.EmptyStmt:
		stats.Constructs["xnkEmptyStmt"]++
		return map[string]interface{}{
			"kind": "xnkEmptyStmt",
		}

	case *ast.IncDecStmt:
		// Convert to unary expression (Go's ++ and -- are statements, always post)
		stats.Constructs["xnkUnaryExpr"]++
		op := "postinc"
		if n.Tok == token.DEC {
			op = "postdec"
		}
		return map[string]interface{}{
			"kind":         "xnkUnaryExpr",
			"unaryOp":      op,
			"unaryOperand": convertToXLang(n.X, stats),
		}

	// ========== Expressions ==========
	case *ast.Ident:
		stats.Constructs["xnkIdentifier"]++
		return map[string]interface{}{
			"kind":      "xnkIdentifier",
			"identName": n.Name,
		}

	case *ast.BasicLit:
		switch n.Kind {
		case token.INT:
			stats.Constructs["xnkIntLit"]++
			return map[string]interface{}{
				"kind":         "xnkIntLit",
				"literalValue": n.Value,
			}
		case token.FLOAT:
			stats.Constructs["xnkFloatLit"]++
			return map[string]interface{}{
				"kind":         "xnkFloatLit",
				"literalValue": n.Value,
			}
		case token.STRING:
			stats.Constructs["xnkStringLit"]++
			return map[string]interface{}{
				"kind":         "xnkStringLit",
				"literalValue": strings.Trim(n.Value, `"`),
			}
		case token.CHAR:
			stats.Constructs["xnkCharLit"]++
			return map[string]interface{}{
				"kind":         "xnkCharLit",
				"literalValue": strings.Trim(n.Value, `'`),
			}
		}
		return nil

	case *ast.BinaryExpr:
		stats.Constructs["xnkBinaryExpr"]++
		return map[string]interface{}{
			"kind":        "xnkBinaryExpr",
			"binaryLeft":  convertToXLang(n.X, stats),
			"binaryOp":    normalizeBinaryOp(n.Op.String()),
			"binaryRight": convertToXLang(n.Y, stats),
		}

	case *ast.UnaryExpr:
		if n.Op == token.AND {
			// Address-of operator
			stats.Constructs["xnkRefExpr"]++
			return map[string]interface{}{
				"kind":    "xnkRefExpr",
				"refExpr": convertToXLang(n.X, stats),
			}
		}
		stats.Constructs["xnkUnaryExpr"]++
		return map[string]interface{}{
			"kind":         "xnkUnaryExpr",
			"unaryOp":      normalizeUnaryOp(n.Op.String()),
			"unaryOperand": convertToXLang(n.X, stats),
		}

	case *ast.CallExpr:
		stats.Constructs["xnkCallExpr"]++
		args := []interface{}{}
		for _, arg := range n.Args {
			args = append(args, convertToXLang(arg, stats))
		}
		return map[string]interface{}{
			"kind":   "xnkCallExpr",
			"callee": convertToXLang(n.Fun, stats),
			"args":   args,
		}

	case *ast.SelectorExpr:
		stats.Constructs["xnkMemberAccessExpr"]++
		return map[string]interface{}{
			"kind":       "xnkMemberAccessExpr",
			"memberExpr": convertToXLang(n.X, stats),
			"memberName": n.Sel.Name,
		}

	case *ast.IndexExpr:
		stats.Constructs["xnkIndexExpr"]++
		return map[string]interface{}{
			"kind":      "xnkIndexExpr",
			"indexExpr": convertToXLang(n.X, stats),
			"indexArgs": []interface{}{convertToXLang(n.Index, stats)},
		}

	case *ast.IndexListExpr:
		// Multiple indices for generics: Map[K, V]
		stats.Constructs["xnkIndexExpr"]++
		indices := []interface{}{}
		for _, idx := range n.Indices {
			indices = append(indices, convertToXLang(idx, stats))
		}
		return map[string]interface{}{
			"kind":      "xnkIndexExpr",
			"indexExpr": convertToXLang(n.X, stats),
			"indexArgs": indices,
		}

	case *ast.SliceExpr:
		stats.Constructs["xnkSliceExpr"]++
		return map[string]interface{}{
			"kind":       "xnkSliceExpr",
			"sliceExpr":  convertToXLang(n.X, stats),
			"sliceStart": convertToXLang(n.Low, stats),
			"sliceEnd":   convertToXLang(n.High, stats),
			"sliceStep":  nil,
		}

	case *ast.CompositeLit:
		// Determine type of composite literal
		if n.Type != nil {
			typeStr := fmt.Sprintf("%v", n.Type)
			if strings.HasPrefix(typeStr, "map[") {
				stats.Constructs["xnkMapLiteral"]++
				entries := []interface{}{}
				for _, elt := range n.Elts {
					if kv, ok := elt.(*ast.KeyValueExpr); ok {
						entries = append(entries, map[string]interface{}{
							"kind":  "xnkDictEntry",
							"key":   convertToXLang(kv.Key, stats),
							"value": convertToXLang(kv.Value, stats),
						})
					}
				}
				return map[string]interface{}{
					"kind":    "xnkMapLiteral",
					"entries": entries,
				}
			}
		}
		// Array/slice literal
		stats.Constructs["xnkArrayLiteral"]++
		elements := []interface{}{}
		for _, elt := range n.Elts {
			elements = append(elements, convertToXLang(elt, stats))
		}
		return map[string]interface{}{
			"kind":     "xnkArrayLiteral",
			"elements": elements,
		}

	case *ast.FuncLit:
		stats.Constructs["xnkLambdaExpr"]++
		return map[string]interface{}{
			"kind":             "xnkLambdaExpr",
			"lambdaParams":     convertParams(n.Type.Params, stats),
			"lambdaReturnType": convertReturnType(n.Type.Results, stats),
			"lambdaBody":       convertToXLang(n.Body, stats),
		}

	case *ast.TypeAssertExpr:
		stats.Constructs["xnkTypeAssertion"]++
		return map[string]interface{}{
			"kind":       "xnkTypeAssertion",
			"assertExpr": convertToXLang(n.X, stats),
			"assertType": convertType(n.Type, stats),
		}

	case *ast.StarExpr:
		// Could be pointer dereference or pointer type
		stats.Constructs["xnkUnaryExpr(*)"]++
		return map[string]interface{}{
			"kind":         "xnkUnaryExpr",
			"unaryOp":      normalizeUnaryOp("*"),
			"unaryOperand": convertToXLang(n.X, stats),
		}

	case *ast.ParenExpr:
		// Transparent - just return inner expression
		return convertToXLang(n.X, stats)

	case *ast.KeyValueExpr:
		// Struct field initializer: key: value
		stats.Constructs["xnkAsgn"]++
		return map[string]interface{}{
			"kind":      "xnkAsgn",
			"asgnLeft":  convertToXLang(n.Key, stats),
			"asgnRight": convertToXLang(n.Value, stats),
		}

	case *ast.DeclStmt:
		// Declaration statement inside function (var x = ...)
		return convertToXLang(n.Decl, stats)

	case *ast.SelectStmt:
		// Channel select statement
		stats.Constructs["xnkExternal_GoSelect"]++
		cases := []interface{}{}
		if n.Body != nil {
			for _, stmt := range n.Body.List {
				if commClause, ok := stmt.(*ast.CommClause); ok {
					cases = append(cases, convertCommClause(commClause, stats))
				}
			}
		}
		return map[string]interface{}{
			"kind":           "xnkExternal_GoSelect",
			"extSelectCases": cases,
		}

	case *ast.CommClause:
		// Communication clause in select (handled by convertCommClause)
		return convertCommClause(n, stats)

	case *ast.SendStmt:
		// Channel send: ch <- value
		stats.Constructs["xnkExternal_GoChannelSend"]++
		return map[string]interface{}{
			"kind":           "xnkExternal_GoChannelSend",
			"extSendChannel": convertToXLang(n.Chan, stats),
			"extSendValue":   convertToXLang(n.Value, stats),
		}

	case *ast.TypeSwitchStmt:
		// Type switch: switch x.(type) { }
		stats.Constructs["xnkExternal_GoTypeSwitch"]++
		cases := []interface{}{}
		if n.Body != nil {
			for _, stmt := range n.Body.List {
				if caseClause, ok := stmt.(*ast.CaseClause); ok {
					cases = append(cases, convertTypeSwitchCase(caseClause, stats))
				}
			}
		}
		// Extract the expression being switched on
		var switchExpr interface{} = nil
		if n.Assign != nil {
			if exprStmt, ok := n.Assign.(*ast.ExprStmt); ok {
				if typeAssert, ok := exprStmt.X.(*ast.TypeAssertExpr); ok {
					switchExpr = convertToXLang(typeAssert.X, stats)
				}
			} else if assignStmt, ok := n.Assign.(*ast.AssignStmt); ok {
				if len(assignStmt.Rhs) > 0 {
					if typeAssert, ok := assignStmt.Rhs[0].(*ast.TypeAssertExpr); ok {
						switchExpr = convertToXLang(typeAssert.X, stats)
					}
				}
			}
		}
		return map[string]interface{}{
			"kind":                 "xnkExternal_GoTypeSwitch",
			"extGoTypeSwitchExpr":  switchExpr,
			"extGoTypeSwitchCases": cases,
		}

	case *ast.ChanType:
		// Channel type: chan T, <-chan T, chan<- T
		stats.Constructs["xnkExternal_GoChanType"]++
		dir := "both"
		if n.Dir == ast.RECV {
			dir = "recv"
		} else if n.Dir == ast.SEND {
			dir = "send"
		}
		return map[string]interface{}{
			"kind":            "xnkExternal_GoChanType",
			"extChanElemType": convertType(n.Value, stats),
			"extChanDir":      dir,
		}

	case *ast.Ellipsis:
		// Variadic ... in function params or slice expansion
		stats.Constructs["xnkExternal_GoVariadic"]++
		return map[string]interface{}{
			"kind":                "xnkExternal_GoVariadic",
			"extVariadicElemType": convertType(n.Elt, stats),
		}

	case *ast.FuncType:
		// Function type (used as type, not declaration)
		stats.Constructs["xnkFuncType"]++
		return map[string]interface{}{
			"kind":       "xnkFuncType",
			"funcParams": convertParams(n.Params, stats),
			"funcReturn": convertReturnType(n.Results, stats),
		}

	case *ast.InterfaceType:
		// Interface type (used inline, not as declaration)
		members := []interface{}{}
		if n.Methods != nil {
			for _, method := range n.Methods.List {
				if len(method.Names) > 0 {
					if funcType, ok := method.Type.(*ast.FuncType); ok {
						members = append(members, map[string]interface{}{
							"kind":        "xnkMethodDecl",
							"methodName":  method.Names[0].Name,
							"mparams":     convertParams(funcType.Params, stats),
							"mreturnType": convertReturnType(funcType.Results, stats),
							"mbody":       nil,
						})
					}
				}
			}
		}

		// Check if this is an empty interface (interface{})
		if len(members) == 0 {
			stats.Constructs["xnkExternal_GoEmptyInterfaceType"]++
			return map[string]interface{}{
				"kind": "xnkExternal_GoEmptyInterfaceType",
			}
		} else {
			stats.Constructs["xnkInterfaceType"]++
			return map[string]interface{}{
				"kind":    "xnkInterfaceType",
				"members": members,
			}
		}

	case *ast.StructType:
		// Struct type (used inline, not as declaration)
		members := []interface{}{}
		if n.Fields != nil {
			for _, field := range n.Fields.List {
				fieldType := convertType(field.Type, stats)
				if len(field.Names) == 0 {
					members = append(members, map[string]interface{}{
						"kind":             "xnkFieldDecl",
						"fieldName":        "",
						"fieldType":        fieldType,
						"fieldInitializer": nil,
					})
				} else {
					for _, name := range field.Names {
						members = append(members, map[string]interface{}{
							"kind":             "xnkFieldDecl",
							"fieldName":        name.Name,
							"fieldType":        fieldType,
							"fieldInitializer": nil,
						})
					}
				}
			}
		}

		// Check if this is an empty struct (struct{})
		if len(members) == 0 {
			stats.Constructs["xnkExternal_GoEmptyStructType"]++
			return map[string]interface{}{
				"kind": "xnkExternal_GoEmptyStructType",
			}
		} else {
			stats.Constructs["xnkStructType"]++
			return map[string]interface{}{
				"kind":    "xnkStructType",
				"members": members,
			}
		}

	case *ast.ArrayType:
		// Array/slice type in expression context (e.g., []byte("hello"))
		stats.Constructs["xnkArrayType"]++
		return map[string]interface{}{
			"kind":        "xnkArrayType",
			"elementType": convertType(n.Elt, stats),
			"arraySize":   convertToXLang(n.Len, stats),
		}

	case *ast.MapType:
		// Map type in expression context
		stats.Constructs["xnkMapType"]++
		return map[string]interface{}{
			"kind":      "xnkMapType",
			"keyType":   convertType(n.Key, stats),
			"valueType": convertType(n.Value, stats),
		}

	case nil:
		return nil

	default:
		stats.Constructs["Unhandled"]++
		typeName := fmt.Sprintf("%T", n)
		stats.UnhandledTypes[typeName]++
		if len(stats.UnhandledSamples) < 10 {
			stats.UnhandledSamples = append(stats.UnhandledSamples, fmt.Sprintf("%s: %s", stats.CurrentFile, typeName))
		}
		return map[string]interface{}{
			"kind":       "xnkUnknown",
			"syntaxKind": typeName,
		}
	}

	return nil
}

func convertFunc(n *ast.FuncDecl, stats *Statistics) map[string]interface{} {
	stats.pushContext(fmt.Sprintf("func %s", n.Name.Name))
	defer stats.popContext()

	// In Go, functions starting with uppercase are exported (public)
	visibility := "private"
	if len(n.Name.Name) > 0 && n.Name.Name[0] >= 'A' && n.Name.Name[0] <= 'Z' {
		visibility = "public"
	}

	// Handle nil body (function declarations without implementation, like in builtin.go)
	var body interface{} = nil
	if n.Body != nil {
		body = convertToXLang(n.Body, stats)
	}

	return map[string]interface{}{
		"kind":           "xnkFuncDecl",
		"funcName":       n.Name.Name,
		"params":         convertParams(n.Type.Params, stats),
		"returnType":     convertReturnType(n.Type.Results, stats),
		"body":           body,
		"isAsync":        false,
		"funcIsStatic":   true, // Go functions are always "static" (no implicit receiver)
		"funcVisibility": visibility,
	}
}

func convertMethod(n *ast.FuncDecl, stats *Statistics) map[string]interface{} {
	stats.pushContext(fmt.Sprintf("method %s", n.Name.Name))
	defer stats.popContext()

	receiver := convertParams(n.Recv, stats)
	var receiverNode interface{} = nil
	if len(receiver) > 0 {
		receiverNode = receiver[0]
	}

	// Handle nil body (method declarations without implementation)
	var body interface{} = nil
	if n.Body != nil {
		body = convertToXLang(n.Body, stats)
	}

	return map[string]interface{}{
		"kind":          "xnkMethodDecl",
		"receiver":      receiverNode,
		"methodName":    n.Name.Name,
		"mparams":       convertParams(n.Type.Params, stats),
		"mreturnType":   convertReturnType(n.Type.Results, stats),
		"mbody":         body,
		"methodIsAsync": false,
	}
}

func convertParams(fields *ast.FieldList, stats *Statistics) []interface{} {
	if fields == nil {
		return []interface{}{}
	}

	params := []interface{}{}
	for _, field := range fields.List {
		fieldType := convertType(field.Type, stats)
		if len(field.Names) == 0 {
			// Unnamed parameter
			params = append(params, map[string]interface{}{
				"kind":         "xnkParameter",
				"paramName":    "",
				"paramType":    fieldType,
				"defaultValue": nil,
			})
		} else {
			for _, name := range field.Names {
				params = append(params, map[string]interface{}{
					"kind":         "xnkParameter",
					"paramName":    name.Name,
					"paramType":    fieldType,
					"defaultValue": nil,
				})
			}
		}
	}
	return params
}

func convertReturnType(fields *ast.FieldList, stats *Statistics) interface{} {
	if fields == nil || len(fields.List) == 0 {
		return nil
	}

	if len(fields.List) == 1 && len(fields.List[0].Names) == 0 {
		// Single unnamed return
		return convertType(fields.List[0].Type, stats)
	}

	// Multiple returns or named returns - use tuple
	elements := []interface{}{}
	for _, field := range fields.List {
		elements = append(elements, convertType(field.Type, stats))
	}
	return map[string]interface{}{
		"kind":     "xnkTupleExpr",
		"elements": elements,
	}
}

func convertType(typ ast.Expr, stats *Statistics) interface{} {
	if typ == nil {
		return nil
	}

	switch t := typ.(type) {
	case *ast.Ident:
		return map[string]interface{}{
			"kind":     "xnkNamedType",
			"typeName": t.Name,
		}
	case *ast.StarExpr:
		return map[string]interface{}{
			"kind":         "xnkPointerType",
			"referentType": convertType(t.X, stats),
		}
	case *ast.ArrayType:
		return map[string]interface{}{
			"kind":        "xnkArrayType",
			"elementType": convertType(t.Elt, stats),
			"arraySize":   convertToXLang(t.Len, stats),
		}
	case *ast.MapType:
		return map[string]interface{}{
			"kind":      "xnkMapType",
			"keyType":   convertType(t.Key, stats),
			"valueType": convertType(t.Value, stats),
		}
	case *ast.SelectorExpr:
		return map[string]interface{}{
			"kind":     "xnkNamedType",
			"typeName": fmt.Sprintf("%v.%v", t.X, t.Sel),
		}
	default:
		return map[string]interface{}{
			"kind":     "xnkNamedType",
			"typeName": fmt.Sprintf("%v", t),
		}
	}
}

func convertValueSpec(spec *ast.ValueSpec, isConst bool, stats *Statistics) map[string]interface{} {
	kind := "xnkVarDecl"
	if isConst {
		kind = "xnkConstDecl"
		stats.Constructs["xnkConstDecl"]++
	} else {
		stats.Constructs["xnkVarDecl"]++
	}

	name := ""
	if len(spec.Names) > 0 {
		name = spec.Names[0].Name
	}

	var initializer interface{} = nil
	if len(spec.Values) > 0 {
		initializer = convertToXLang(spec.Values[0], stats)
	}

	return map[string]interface{}{
		"kind":        kind,
		"declName":    name,
		"declType":    convertType(spec.Type, stats),
		"initializer": initializer,
	}
}

func convertTypeSpec(spec *ast.TypeSpec, stats *Statistics) map[string]interface{} {
	switch t := spec.Type.(type) {
	case *ast.StructType:
		stats.Constructs["xnkStructDecl"]++
		members := []interface{}{}
		if t.Fields != nil {
			for _, field := range t.Fields.List {
				fieldType := convertType(field.Type, stats)
				if len(field.Names) == 0 {
					// Anonymous/embedded field
					members = append(members, map[string]interface{}{
						"kind":             "xnkFieldDecl",
						"fieldName":        "",
						"fieldType":        fieldType,
						"fieldInitializer": nil,
					})
				} else {
					for _, name := range field.Names {
						members = append(members, map[string]interface{}{
							"kind":             "xnkFieldDecl",
							"fieldName":        name.Name,
							"fieldType":        fieldType,
							"fieldInitializer": nil,
						})
					}
				}
			}
		}
		return map[string]interface{}{
			"kind":         "xnkStructDecl",
			"typeNameDecl": spec.Name.Name,
			"baseTypes":    []interface{}{},
			"members":      members,
		}

	case *ast.InterfaceType:
		stats.Constructs["xnkInterfaceDecl"]++
		members := []interface{}{}
		if t.Methods != nil {
			for _, method := range t.Methods.List {
				if len(method.Names) > 0 {
					// Method signature
					if funcType, ok := method.Type.(*ast.FuncType); ok {
						members = append(members, map[string]interface{}{
							"kind":          "xnkMethodDecl",
							"methodName":    method.Names[0].Name,
							"mparams":       convertParams(funcType.Params, stats),
							"mreturnType":   convertReturnType(funcType.Results, stats),
							"mbody":         nil,
							"methodIsAsync": false,
						})
					}
				} else {
					// Embedded interface
					// Add to baseTypes instead
				}
			}
		}
		return map[string]interface{}{
			"kind":         "xnkInterfaceDecl",
			"typeNameDecl": spec.Name.Name,
			"baseTypes":    []interface{}{},
			"members":      members,
		}

	default:
		// Type alias
		stats.Constructs["xnkTypeAlias"]++
		return map[string]interface{}{
			"kind":        "xnkTypeAlias",
			"aliasName":   spec.Name.Name,
			"aliasTarget": convertType(spec.Type, stats),
		}
	}
}

func convertCaseClause(clause *ast.CaseClause, stats *Statistics) map[string]interface{} {
	values := []interface{}{}
	for _, expr := range clause.List {
		values = append(values, convertToXLang(expr, stats))
	}

	body := []interface{}{}
	for _, stmt := range clause.Body {
		body = append(body, convertToXLang(stmt, stats))
	}

	// If no values, it's the default case
	if len(values) == 0 {
		return map[string]interface{}{
			"kind": "xnkDefaultClause",
			"defaultBody": map[string]interface{}{
				"kind":      "xnkBlockStmt",
				"blockBody": body,
			},
		}
	}

	return map[string]interface{}{
		"kind":       "xnkCaseClause",
		"caseValues": values,
		"caseBody": map[string]interface{}{
			"kind":      "xnkBlockStmt",
			"blockBody": body,
		},
		"caseFallthrough": false,
	}
}

func convertCommClause(clause *ast.CommClause, stats *Statistics) map[string]interface{} {
	// Communication clause in select statement
	stats.Constructs["xnkExternal_GoCommClause"]++

	body := []interface{}{}
	for _, stmt := range clause.Body {
		converted := convertToXLang(stmt, stats)
		if converted != nil {
			body = append(body, converted)
		}
	}

	// Default case in select
	if clause.Comm == nil {
		return map[string]interface{}{
			"kind":      "xnkExternal_GoCommClause",
			"extCommOp": nil,
			"extCommBody": map[string]interface{}{
				"kind":      "xnkBlockStmt",
				"blockBody": body,
			},
			"extCommIsDefault": true,
		}
	}

	return map[string]interface{}{
		"kind":      "xnkExternal_GoCommClause",
		"extCommOp": convertToXLang(clause.Comm, stats),
		"extCommBody": map[string]interface{}{
			"kind":      "xnkBlockStmt",
			"blockBody": body,
		},
		"extCommIsDefault": false,
	}
}

func convertTypeSwitchCase(clause *ast.CaseClause, stats *Statistics) map[string]interface{} {
	// Type case in type switch
	stats.Constructs["xnkExternal_GoTypeCase"]++
	types := []interface{}{}
	for _, expr := range clause.List {
		types = append(types, convertType(expr, stats))
	}

	body := []interface{}{}
	for _, stmt := range clause.Body {
		converted := convertToXLang(stmt, stats)
		if converted != nil {
			body = append(body, converted)
		}
	}

	// Default case
	if len(types) == 0 {
		return map[string]interface{}{
			"kind":             "xnkExternal_GoTypeCase",
			"extTypeCaseTypes": nil,
			"extTypeCaseBody": map[string]interface{}{
				"kind":      "xnkBlockStmt",
				"blockBody": body,
			},
			"extTypeCaseIsDefault": true,
		}
	}

	return map[string]interface{}{
		"kind":             "xnkExternal_GoTypeCase",
		"extTypeCaseTypes": types,
		"extTypeCaseBody": map[string]interface{}{
			"kind":      "xnkBlockStmt",
			"blockBody": body,
		},
		"extTypeCaseIsDefault": false,
	}
}

func printStatistics(stats *Statistics) {
	fmt.Println("\nXLang Node Statistics:")
	fmt.Println("======================")
	for construct, count := range stats.Constructs {
		fmt.Printf("%-25s: %d\n", construct, count)
	}
	fmt.Printf("\nTotal XLang node types: %d\n", len(stats.Constructs))

	// Print unhandled types breakdown
	if len(stats.UnhandledTypes) > 0 {
		fmt.Println("\nUnhandled AST Node Types:")
		fmt.Println("=========================")
		for typeName, count := range stats.UnhandledTypes {
			fmt.Printf("%-40s: %d\n", typeName, count)
		}
		fmt.Println("\nSample locations:")
		for _, sample := range stats.UnhandledSamples {
			fmt.Printf("  %s\n", sample)
		}
	}
}
