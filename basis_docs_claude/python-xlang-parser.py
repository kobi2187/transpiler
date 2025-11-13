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
        return {
            "kind": self.kind,
            "data": self.data
        }

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
    output_filename = os.path.splitext(filename)[0] + '.json'
    
    with open(output_filename, 'w') as file:
        file.write(json_data)
    
    print(f"Processed {filename} -> {output_filename}")

def convert_to_xlang(node: Union[ast.AST, List[ast.AST]], stats: Statistics) -> XLangNode:
    if isinstance(node, list):
        return XLangNode("List", [convert_to_xlang(n, stats) for n in node])

    stats.increment(type(node).__name__)
    
    if isinstance(node, ast.Module):
        return XLangNode("Module", {
            "body": convert_to_xlang(node.body, stats)
        })
    elif isinstance(node, ast.FunctionDef):
        return XLangNode("FunctionDef", {
            "name": node.name,
            "args": convert_to_xlang(node.args, stats),
            "body": convert_to_xlang(node.body, stats),
            "decorator_list": convert_to_xlang(node.decorator_list, stats),
            "returns": convert_to_xlang(node.returns, stats) if node.returns else None
        })
    elif isinstance(node, ast.ClassDef):
        return XLangNode("ClassDef", {
            "name": node.name,
            "bases": convert_to_xlang(node.bases, stats),
            "keywords": convert_to_xlang(node.keywords, stats),
            "body": convert_to_xlang(node.body, stats),
            "decorator_list": convert_to_xlang(node.decorator_list, stats)
        })
    elif isinstance(node, ast.Return):
        return XLangNode("Return", {
            "value": convert_to_xlang(node.value, stats) if node.value else None
        })
    elif isinstance(node, ast.Assign):
        return XLangNode("Assign", {
            "targets": convert_to_xlang(node.targets, stats),
            "value": convert_to_xlang(node.value, stats)
        })
    elif isinstance(node, ast.AugAssign):
        return XLangNode("AugAssign", {
            "target": convert_to_xlang(node.target, stats),
            "op": type(node.op).__name__,
            "value": convert_to_xlang(node.value, stats)
        })
    elif isinstance(node, ast.For):
        return XLangNode("For", {
            "target": convert_to_xlang(node.target, stats),
            "iter": convert_to_xlang(node.iter, stats),
            "body": convert_to_xlang(node.body, stats),
            "orelse": convert_to_xlang(node.orelse, stats)
        })
    elif isinstance(node, ast.While):
        return XLangNode("While", {
            "test": convert_to_xlang(node.test, stats),
            "body": convert_to_xlang(node.body, stats),
            "orelse": convert_to_xlang(node.orelse, stats)
        })
    elif isinstance(node, ast.If):
        return XLangNode("If", {
            "test": convert_to_xlang(node.test, stats),
            "body": convert_to_xlang(node.body, stats),
            "orelse": convert_to_xlang(node.orelse, stats)
        })
    elif isinstance(node, ast.With):
        return XLangNode("With", {
            "items": convert_to_xlang(node.items, stats),
            "body": convert_to_xlang(node.body, stats)
        })
    elif isinstance(node, ast.Try):
        return XLangNode("Try", {
            "body": convert_to_xlang(node.body, stats),
            "handlers": convert_to_xlang(node.handlers, stats),
            "orelse": convert_to_xlang(node.orelse, stats),
            "finalbody": convert_to_xlang(node.finalbody, stats)
        })
    elif isinstance(node, ast.ExceptHandler):
        return XLangNode("ExceptHandler", {
            "type": convert_to_xlang(node.type, stats) if node.type else None,
            "name": node.name,
            "body": convert_to_xlang(node.body, stats)
        })
    elif isinstance(node, ast.Raise):
        return XLangNode("Raise", {
            "exc": convert_to_xlang(node.exc, stats) if node.exc else None,
            "cause": convert_to_xlang(node.cause, stats) if node.cause else None
        })
    elif isinstance(node, ast.Assert):
        return XLangNode("Assert", {
            "test": convert_to_xlang(node.test, stats),
            "msg": convert_to_xlang(node.msg, stats) if node.msg else None
        })
    elif isinstance(node, ast.Import):
        return XLangNode("Import", {
            "names": convert_to_xlang(node.names, stats)
        })
    elif isinstance(node, ast.ImportFrom):
        return XLangNode("ImportFrom", {
            "module": node.module,
            "names": convert_to_xlang(node.names, stats),
            "level": node.level
        })
    elif isinstance(node, ast.alias):
        return XLangNode("alias", {
            "name": node.name,
            "asname": node.asname
        })
    elif isinstance(node, ast.Global):
        return XLangNode("Global", {
            "names": node.names
        })
    elif isinstance(node, ast.Nonlocal):
        return XLangNode("Nonlocal", {
            "names": node.names
        })
    elif isinstance(node, ast.Expr):
        return XLangNode("Expr", {
            "value": convert_to_xlang(node.value, stats)
        })
    elif isinstance(node, ast.Pass):
        return XLangNode("Pass", None)
    elif isinstance(node, ast.Break):
        return XLangNode("Break", None)
    elif isinstance(node, ast.Continue):
        return XLangNode("Continue", None)
    elif isinstance(node, ast.BinOp):
        return XLangNode("BinOp", {
            "left": convert_to_xlang(node.left, stats),
            "op": type(node.op).__name__,
            "right": convert_to_xlang(node.right, stats)
        })
    elif isinstance(node, ast.UnaryOp):
        return XLangNode("UnaryOp", {
            "op": type(node.op).__name__,
            "operand": convert_to_xlang(node.operand, stats)
        })
    elif isinstance(node, ast.Lambda):
        return XLangNode("Lambda", {
            "args": convert_to_xlang(node.args, stats),
            "body": convert_to_xlang(node.body, stats)
        })
    elif isinstance(node, ast.IfExp):
        return XLangNode("IfExp", {
            "test": convert_to_xlang(node.test, stats),
            "body": convert_to_xlang(node.body, stats),
            "orelse": convert_to_xlang(node.orelse, stats)
        })
    elif isinstance(node, ast.Dict):
        return XLangNode("Dict", {
            "keys": convert_to_xlang(node.keys, stats),
            "values": convert_to_xlang(node.values, stats)
        })
    elif isinstance(node, ast.Set):
        return XLangNode("Set", {
            "elts": convert_to_xlang(node.elts, stats)
        })
    elif isinstance(node, ast.ListComp):
        return XLangNode("ListComp", {
            "elt": convert_to_xlang(node.elt, stats),
            "generators": convert_to_xlang(node.generators, stats)
        })
    elif isinstance(node, ast.SetComp):
        return XLangNode("SetComp", {
            "elt": convert_to_xlang(node.elt, stats),
            "generators": convert_to_xlang(node.generators, stats)
        })
    elif isinstance(node, ast.DictComp):
        return XLangNode("DictComp", {
            "key": convert_to_xlang(node.key, stats),
            "value": convert_to_xlang(node.value, stats),
            "generators": convert_to_xlang(node.generators, stats)
        })
    elif isinstance(node, ast.GeneratorExp):
        return XLangNode("GeneratorExp", {
            "elt": convert_to_xlang(node.elt, stats),
            "generators": convert_to_xlang(node.generators, stats)
        })
    elif isinstance(node, ast.Yield):
        return XLangNode("Yield", {
            "value": convert_to_xlang(node.value, stats) if node.value else None
        })
    elif isinstance(node, ast.YieldFrom):
        return XLangNode("YieldFrom", {
            "value": convert_to_xlang(node.value, stats)
        })
    elif isinstance(node, ast.Compare):
        return XLangNode("Compare", {
            "left": convert_to_xlang(node.left, stats),
            "ops": [type(op).__name__ for op in node.ops],
            "comparators": convert_to_xlang(node.comparators, stats)
        })
    elif isinstance(node, ast.Call):
        return XLangNode("Call", {
            "func": convert_to_xlang(node.func, stats),
            "args": convert_to_xlang(node.args, stats),
            "keywords": convert_to_xlang(node.keywords, stats)
        })
    elif isinstance(node, ast.Num):
        return XLangNode("Num", {
            "n": node.n
        })
    elif isinstance(node, ast.Str):
        return XLangNode("Str", {
            "s": node.s
        })
    elif isinstance(node, ast.FormattedValue):
        return XLangNode("FormattedValue", {
            "value": convert_to_xlang(node.value, stats),
            "conversion": node.conversion,
            "format_spec": convert_to_xlang(node.format_spec, stats) if node.format_spec else None
        })
    elif isinstance(node, ast.JoinedStr):
        return XLangNode("JoinedStr", {
            "values": convert_to_xlang(node.values, stats)
        })
    elif isinstance(node, ast.Bytes):
        return XLangNode("Bytes", {
            "s": node.s
        })
    elif isinstance(node, ast.NameConstant):
        return XLangNode("NameConstant", {
            "value": node.value
        })
    elif isinstance(node, ast.Ellipsis):
        return XLangNode("Ellipsis", None)
    elif isinstance(node, ast.Attribute):
        return XLangNode("Attribute", {
            "value": convert_to_xlang(node.value, stats),
            "attr": node.attr,
            "ctx": type(node.ctx).__name__
        })
    elif isinstance(node, ast.Subscript):
        return XLangNode("Subscript", {
            "value": convert_to_xlang(node.value, stats),
            "slice": convert_to_xlang(node.slice, stats),
            "ctx": type(node.ctx).__name__
        })
    elif isinstance(node, ast.Starred):
        return XLangNode("Starred", {
            "value": convert_to_xlang(node.value, stats),
            "ctx": type(node.ctx).__name__
        })
    elif isinstance(node, ast.Name):
        return XLangNode("Name", {
            "id": node.id,
            "ctx": type(node.ctx).__name__
        })
    elif isinstance(node, ast.List):
        return XLangNode("List", {
            "elts": convert_to_xlang(node.elts, stats),
            "ctx": type(node.ctx).__name__
        })
    elif isinstance(node, ast.Tuple):
        return XLangNode("Tuple", {
            "elts": convert_to_xlang(node.elts, stats),
            "ctx": type(node.ctx).__name__
        })
    else:
        return XLangNode("Unknown", str(type(node)))

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
        print("Usage: python python-xlang-parser.py <file_or_directory>")
        sys.exit(1)

    path = sys.argv[1]
    stats = Statistics()

    process_path(path, stats)

    print("\nStatistics:")
    for construct, count in stats.constructs.items():
        print(f"{construct}: {count}")

if __name__ == "__main__":
    main()
