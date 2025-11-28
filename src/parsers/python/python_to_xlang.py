import ast
import json
import os
import sys
from typing import Any, Dict, List, Union

class XLangNode:
    def __init__(self, kind: str, data: Any = None):
        self.kind = kind
        self.data = data

    def to_dict(self) -> Dict[str, Any]:
        result = {"kind": self.kind}
        if self.data is not None:
            if isinstance(self.data, dict):
                result.update(self.data)
            else:
                result["data"] = self.data
        return result

class Statistics:
    def __init__(self):
        self.constructs: Dict[str, int] = {}

    def increment(self, construct: str):
        self.constructs[construct] = self.constructs.get(construct, 0) + 1

def process_file(filename: str, stats: Statistics) -> None:
    with open(filename, 'r') as file:
        source = file.read()
    
    tree = ast.parse(source)
    xlang_ast = convert_to_xlang(tree, stats)
    
    json_data = json.dumps(xlang_ast.to_dict(), indent=2)
    output_filename = os.path.splitext(filename)[0] + '.xlang.json'
    
    with open(output_filename, 'w') as file:
        file.write(json_data)
    
    print(f"Processed {filename} -> {output_filename}")

def convert_to_xlang(node: Union[ast.AST, List[ast.AST]], stats: Statistics) -> XLangNode:
    if isinstance(node, list):
        return XLangNode("List", [convert_to_xlang(n, stats).to_dict() for n in node])

    stats.increment(type(node).__name__)
    
    if isinstance(node, ast.Module):
        return XLangNode("xnkFile", {
            "declarations": [convert_to_xlang(n, stats).to_dict() for n in node.body]
        })
    
    elif isinstance(node, ast.FunctionDef):
        return XLangNode("xnkFuncDecl", {
            "name": node.name,
            "parameters": [convert_to_xlang(arg, stats).to_dict() for arg in node.args.args],
            "body": convert_to_xlang(node.body, stats).to_dict(),
            "decorators": [convert_to_xlang(dec, stats).to_dict() for dec in node.decorator_list],
            "returnType": convert_to_xlang(node.returns, stats).to_dict() if node.returns else None,
            "isAsync": False
        })
    
    elif isinstance(node, ast.AsyncFunctionDef):
        return XLangNode("xnkFuncDecl", {
            "name": node.name,
            "parameters": [convert_to_xlang(arg, stats).to_dict() for arg in node.args.args],
            "body": convert_to_xlang(node.body, stats).to_dict(),
            "decorators": [convert_to_xlang(dec, stats).to_dict() for dec in node.decorator_list],
            "returnType": convert_to_xlang(node.returns, stats).to_dict() if node.returns else None,
            "isAsync": True
        })
    
    elif isinstance(node, ast.ClassDef):
        return XLangNode("xnkClassDecl", {
            "name": node.name,
            "baseTypes": [convert_to_xlang(base, stats).to_dict() for base in node.bases],
            "members": [convert_to_xlang(n, stats).to_dict() for n in node.body],
            "decorators": [convert_to_xlang(dec, stats).to_dict() for dec in node.decorator_list]
        })
    
    elif isinstance(node, ast.Return):
        return XLangNode("xnkReturnStmt", {
            "expression": convert_to_xlang(node.value, stats).to_dict() if node.value else None
        })
    
    elif isinstance(node, ast.Assign):
        return XLangNode("xnkVarDecl", {
            "targets": [convert_to_xlang(t, stats).to_dict() for t in node.targets],
            "value": convert_to_xlang(node.value, stats).to_dict()
        })
    
    elif isinstance(node, ast.AugAssign):
        return XLangNode("xnkBinaryExpr", {
            "left": convert_to_xlang(node.target, stats).to_dict(),
            "operator": type(node.op).__name__,
            "right": convert_to_xlang(node.value, stats).to_dict()
        })
    
    elif isinstance(node, ast.AnnAssign):
        return XLangNode("xnkVarDecl", {
            "target": convert_to_xlang(node.target, stats).to_dict(),
            "type": convert_to_xlang(node.annotation, stats).to_dict(),
            "value": convert_to_xlang(node.value, stats).to_dict() if node.value else None
        })
    
    elif isinstance(node, ast.For):
        return XLangNode("xnkForeachStmt", {
            "variable": convert_to_xlang(node.target, stats).to_dict(),
            "iterable": convert_to_xlang(node.iter, stats).to_dict(),
            "body": [convert_to_xlang(n, stats).to_dict() for n in node.body],
            "orelse": [convert_to_xlang(n, stats).to_dict() for n in node.orelse] if node.orelse else []
        })
    
    elif isinstance(node, ast.While):
        return XLangNode("xnkWhileStmt", {
            "condition": convert_to_xlang(node.test, stats).to_dict(),
            "body": [convert_to_xlang(n, stats).to_dict() for n in node.body],
            "orelse": [convert_to_xlang(n, stats).to_dict() for n in node.orelse] if node.orelse else []
        })
    
    elif isinstance(node, ast.If):
        return XLangNode("xnkIfStmt", {
            "condition": convert_to_xlang(node.test, stats).to_dict(),
            "thenBranch": [convert_to_xlang(n, stats).to_dict() for n in node.body],
            "elseBranch": [convert_to_xlang(n, stats).to_dict() for n in node.orelse] if node.orelse else []
        })
    
    elif isinstance(node, ast.With):
        return XLangNode("xnkWithStmt", {
            "items": [convert_to_xlang(item, stats).to_dict() for item in node.items],
            "body": [convert_to_xlang(n, stats).to_dict() for n in node.body]
        })
    
    elif isinstance(node, ast.withitem):
        return XLangNode("xnkWithItem", {
            "context": convert_to_xlang(node.context_expr, stats).to_dict(),
            "optional_vars": convert_to_xlang(node.optional_vars, stats).to_dict() if node.optional_vars else None
        })
    
    elif isinstance(node, ast.Try):
        return XLangNode("xnkTryStmt", {
            "body": [convert_to_xlang(n, stats).to_dict() for n in node.body],
            "handlers": [convert_to_xlang(h, stats).to_dict() for h in node.handlers],
            "orelse": [convert_to_xlang(n, stats).to_dict() for n in node.orelse] if node.orelse else [],
            "finalbody": [convert_to_xlang(n, stats).to_dict() for n in node.finalbody] if node.finalbody else []
        })
    
    elif isinstance(node, ast.ExceptHandler):
        return XLangNode("xnkCatchStmt", {
            "type": convert_to_xlang(node.type, stats).to_dict() if node.type else None,
            "name": node.name,
            "body": [convert_to_xlang(n, stats).to_dict() for n in node.body]
        })
    
    elif isinstance(node, ast.Raise):
        return XLangNode("xnkThrowStmt", {
            "exception": convert_to_xlang(node.exc, stats).to_dict() if node.exc else None,
            "cause": convert_to_xlang(node.cause, stats).to_dict() if node.cause else None
        })
    
    elif isinstance(node, ast.Assert):
        return XLangNode("xnkAssertStmt", {
            "test": convert_to_xlang(node.test, stats).to_dict(),
            "message": convert_to_xlang(node.msg, stats).to_dict() if node.msg else None
        })
    
    elif isinstance(node, ast.Import):
        return XLangNode("xnkImport", {
            "names": [{"name": alias.name, "asname": alias.asname} for alias in node.names]
        })
    
    elif isinstance(node, ast.ImportFrom):
        return XLangNode("xnkImport", {
            "module": node.module,
            "names": [{"name": alias.name, "asname": alias.asname} for alias in node.names],
            "level": node.level
        })
    
    elif isinstance(node, ast.Global):
        return XLangNode("xnkGlobal", {
            "names": node.names
        })
    
    elif isinstance(node, ast.Nonlocal):
        return XLangNode("xnkNonlocal", {
            "names": node.names
        })
    
    elif isinstance(node, ast.Expr):
        return XLangNode("xnkExprStmt", {
            "value": convert_to_xlang(node.value, stats).to_dict()
        })
    
    elif isinstance(node, ast.Pass):
        return XLangNode("xnkPassStmt", {})
    
    elif isinstance(node, ast.Break):
        return XLangNode("xnkBreakStmt", {})
    
    elif isinstance(node, ast.Continue):
        return XLangNode("xnkContinueStmt", {})
    
    elif isinstance(node, ast.BinOp):
        return XLangNode("xnkBinaryExpr", {
            "left": convert_to_xlang(node.left, stats).to_dict(),
            "operator": type(node.op).__name__,
            "right": convert_to_xlang(node.right, stats).to_dict()
        })
    
    elif isinstance(node, ast.UnaryOp):
        return XLangNode("xnkUnaryExpr", {
            "operator": type(node.op).__name__,
            "operand": convert_to_xlang(node.operand, stats).to_dict()
        })
    
    elif isinstance(node, ast.Lambda):
        return XLangNode("xnkLambdaExpr", {
            "parameters": [convert_to_xlang(arg, stats).to_dict() for arg in node.args.args],
            "body": convert_to_xlang(node.body, stats).to_dict()
        })
    
    elif isinstance(node, ast.IfExp):
        return XLangNode("xnkTernaryExpr", {
            "condition": convert_to_xlang(node.test, stats).to_dict(),
            "thenExpr": convert_to_xlang(node.body, stats).to_dict(),
            "elseExpr": convert_to_xlang(node.orelse, stats).to_dict()
        })
    
    elif isinstance(node, ast.Dict):
        return XLangNode("xnkDictExpr", {
            "keys": [convert_to_xlang(k, stats).to_dict() if k else None for k in node.keys],
            "values": [convert_to_xlang(v, stats).to_dict() for v in node.values]
        })
    
    elif isinstance(node, ast.Set):
        return XLangNode("xnkSetExpr", {
            "elements": [convert_to_xlang(e, stats).to_dict() for e in node.elts]
        })
    
    elif isinstance(node, ast.ListComp):
        return XLangNode("xnkComprehensionExpr", {
            "element": convert_to_xlang(node.elt, stats).to_dict(),
            "generators": [convert_to_xlang(g, stats).to_dict() for g in node.generators]
        })
    
    elif isinstance(node, ast.SetComp):
        return XLangNode("xnkComprehensionExpr", {
            "element": convert_to_xlang(node.elt, stats).to_dict(),
            "generators": [convert_to_xlang(g, stats).to_dict() for g in node.generators],
            "isSet": True
        })
    
    elif isinstance(node, ast.DictComp):
        return XLangNode("xnkComprehensionExpr", {
            "key": convert_to_xlang(node.key, stats).to_dict(),
            "value": convert_to_xlang(node.value, stats).to_dict(),
            "generators": [convert_to_xlang(g, stats).to_dict() for g in node.generators],
            "isDict": True
        })
    
    elif isinstance(node, ast.GeneratorExp):
        return XLangNode("xnkGeneratorExpr", {
            "element": convert_to_xlang(node.elt, stats).to_dict(),
            "generators": [convert_to_xlang(g, stats).to_dict() for g in node.generators]
        })
    
    elif isinstance(node, ast.comprehension):
        return XLangNode("xnkComprehension", {
            "target": convert_to_xlang(node.target, stats).to_dict(),
            "iter": convert_to_xlang(node.iter, stats).to_dict(),
            "ifs": [convert_to_xlang(i, stats).to_dict() for i in node.ifs],
            "is_async": node.is_async
        })
    
    elif isinstance(node, ast.Await):
        return XLangNode("xnkAwaitExpr", {
            "value": convert_to_xlang(node.value, stats).to_dict()
        })
    
    elif isinstance(node, ast.Yield):
        return XLangNode("xnkYieldExpr", {
            "value": convert_to_xlang(node.value, stats).to_dict() if node.value else None
        })
    
    elif isinstance(node, ast.YieldFrom):
        return XLangNode("xnkYieldFromExpr", {
            "value": convert_to_xlang(node.value, stats).to_dict()
        })
    
    elif isinstance(node, ast.Compare):
        return XLangNode("xnkCompareExpr", {
            "left": convert_to_xlang(node.left, stats).to_dict(),
            "operators": [type(op).__name__ for op in node.ops],
            "comparators": [convert_to_xlang(c, stats).to_dict() for c in node.comparators]
        })
    
    elif isinstance(node, ast.Call):
        return XLangNode("xnkCallExpr", {
            "function": convert_to_xlang(node.func, stats).to_dict(),
            "arguments": [convert_to_xlang(arg, stats).to_dict() for arg in node.args],
            "keywords": [convert_to_xlang(kw, stats).to_dict() for kw in node.keywords]
        })
    
    elif isinstance(node, ast.keyword):
        return XLangNode("xnkKeyword", {
            "arg": node.arg,
            "value": convert_to_xlang(node.value, stats).to_dict()
        })
    
    elif isinstance(node, ast.Constant):
        if isinstance(node.value, int):
            return XLangNode("xnkIntLit", {"value": node.value})
        elif isinstance(node.value, float):
            return XLangNode("xnkFloatLit", {"value": node.value})
        elif isinstance(node.value, str):
            return XLangNode("xnkStringLit", {"value": node.value})
        elif isinstance(node.value, bool):
            return XLangNode("xnkBoolLit", {"value": node.value})
        elif node.value is None:
            return XLangNode("xnkNoneLit", {})
        else:
            return XLangNode("xnkConstant", {"value": str(node.value)})
    
    elif isinstance(node, ast.Attribute):
        return XLangNode("xnkMemberAccessExpr", {
            "value": convert_to_xlang(node.value, stats).to_dict(),
            "attribute": node.attr
        })
    
    elif isinstance(node, ast.Subscript):
        return XLangNode("xnkIndexExpr", {
            "value": convert_to_xlang(node.value, stats).to_dict(),
            "index": convert_to_xlang(node.slice, stats).to_dict()
        })
    
    elif isinstance(node, ast.Slice):
        return XLangNode("xnkSliceExpr", {
            "lower": convert_to_xlang(node.lower, stats).to_dict() if node.lower else None,
            "upper": convert_to_xlang(node.upper, stats).to_dict() if node.upper else None,
            "step": convert_to_xlang(node.step, stats).to_dict() if node.step else None
        })
    
    elif isinstance(node, ast.Starred):
        return XLangNode("xnkStarredExpr", {
            "value": convert_to_xlang(node.value, stats).to_dict()
        })
    
    elif isinstance(node, ast.Name):
        return XLangNode("xnkIdentifier", {
            "name": node.id
        })
    
    elif isinstance(node, ast.List):
        return XLangNode("xnkListExpr", {
            "elements": [convert_to_xlang(e, stats).to_dict() for e in node.elts]
        })
    
    elif isinstance(node, ast.Tuple):
        return XLangNode("xnkTupleExpr", {
            "elements": [convert_to_xlang(e, stats).to_dict() for e in node.elts]
        })
    
    elif isinstance(node, ast.arg):
        return XLangNode("xnkParameter", {
            "name": node.arg,
            "annotation": convert_to_xlang(node.annotation, stats).to_dict() if node.annotation else None
        })
    
    else:
        return XLangNode("xnkUnknown", {"pythonType": type(node).__name__})

def process_path(path: str, stats: Statistics) -> None:
    if os.path.isfile(path):
        if path.endswith('.py'):
            process_file(path, stats)
    elif os.path.isdir(path):
        for root, _, files in os.walk(path):
            for file in files:
                if file.endswith('.py'):
                    process_file(os.path.join(root, file), stats)

def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: python python_to_xlang.py <file_or_directory>")
        sys.exit(1)

    path = sys.argv[1]
    stats = Statistics()

    process_path(path, stats)

    print("\nStatistics:")
    for construct, count in stats.constructs.items():
        print(f"{construct}: {count}")

if __name__ == "__main__":
    main()