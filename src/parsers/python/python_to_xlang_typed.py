#!/usr/bin/env python3
"""
Enhanced Python to XLang Parser with Type Inference

Converts Python AST to XLang JSON with type inference for unannotated code.
- Preserves explicit type annotations
- Infers types from literals, builtin calls, and common patterns
- Uses 'auto' for unknown/dynamic types
"""

import ast
import json
import os
import sys
from typing import Any, Dict, List, Union, Optional, Set

class TypeInferencer:
    """Infers types for unannotated Python code"""

    def __init__(self):
        self.type_map: Dict[str, Dict[str, Any]] = {}  # varname -> type info

    def infer_from_value(self, value_node: ast.AST) -> Optional[Dict[str, Any]]:
        """Infer type from a value expression"""
        if isinstance(value_node, ast.Constant):
            if isinstance(value_node.value, bool):
                return {"kind": "xnkNamedType", "typeName": "bool"}
            elif isinstance(value_node.value, int):
                return {"kind": "xnkNamedType", "typeName": "int"}
            elif isinstance(value_node.value, float):
                return {"kind": "xnkNamedType", "typeName": "float"}
            elif isinstance(value_node.value, str):
                return {"kind": "xnkNamedType", "typeName": "str"}
            elif value_node.value is None:
                return {"kind": "xnkNamedType", "typeName": "None"}

        elif isinstance(value_node, ast.List):
            elem_type = self._infer_collection_element_type(value_node.elts)
            return {
                "kind": "xnkGenericType",
                "typeName": "list",
                "typeArgs": [elem_type or {"kind": "xnkNamedType", "typeName": "auto"}]
            }

        elif isinstance(value_node, ast.Tuple):
            if value_node.elts:
                elem_types = [self.infer_from_value(e) or {"kind": "xnkNamedType", "typeName": "auto"}
                             for e in value_node.elts]
                return {
                    "kind": "xnkTupleType",
                    "elementTypes": elem_types
                }
            return {"kind": "xnkNamedType", "typeName": "tuple"}

        elif isinstance(value_node, ast.Dict):
            key_type = self._infer_collection_element_type(value_node.keys)
            val_type = self._infer_collection_element_type(value_node.values)
            return {
                "kind": "xnkGenericType",
                "typeName": "dict",
                "typeArgs": [
                    key_type or {"kind": "xnkNamedType", "typeName": "auto"},
                    val_type or {"kind": "xnkNamedType", "typeName": "auto"}
                ]
            }

        elif isinstance(value_node, ast.Set):
            elem_type = self._infer_collection_element_type(value_node.elts)
            return {
                "kind": "xnkGenericType",
                "typeName": "set",
                "typeArgs": [elem_type or {"kind": "xnkNamedType", "typeName": "auto"}]
            }

        elif isinstance(value_node, ast.Call):
            return self._infer_from_call(value_node)

        elif isinstance(value_node, ast.BinOp):
            return self._infer_from_binop(value_node)

        elif isinstance(value_node, ast.UnaryOp):
            return self.infer_from_value(value_node.operand)

        elif isinstance(value_node, ast.Compare):
            return {"kind": "xnkNamedType", "typeName": "bool"}

        elif isinstance(value_node, ast.BoolOp):
            return {"kind": "xnkNamedType", "typeName": "bool"}

        elif isinstance(value_node, ast.Name):
            # Look up variable type
            return self.type_map.get(value_node.id, {}).get("type")

        elif isinstance(value_node, ast.ListComp) or isinstance(value_node, ast.GeneratorExp):
            elem_type = self.infer_from_value(value_node.elt) if hasattr(value_node, 'elt') else None
            return {
                "kind": "xnkGenericType",
                "typeName": "list" if isinstance(value_node, ast.ListComp) else "Generator",
                "typeArgs": [elem_type or {"kind": "xnkNamedType", "typeName": "auto"}]
            }

        elif isinstance(value_node, ast.DictComp):
            key_type = self.infer_from_value(value_node.key) if hasattr(value_node, 'key') else None
            val_type = self.infer_from_value(value_node.value) if hasattr(value_node, 'value') else None
            return {
                "kind": "xnkGenericType",
                "typeName": "dict",
                "typeArgs": [
                    key_type or {"kind": "xnkNamedType", "typeName": "auto"},
                    val_type or {"kind": "xnkNamedType", "typeName": "auto"}
                ]
            }

        elif isinstance(value_node, ast.Lambda):
            return {"kind": "xnkFunctionType", "params": [], "returnType": {"kind": "xnkNamedType", "typeName": "auto"}}

        # Default: unknown type
        return {"kind": "xnkNamedType", "typeName": "auto"}

    def _infer_collection_element_type(self, elements: List[ast.AST]) -> Optional[Dict[str, Any]]:
        """Infer common type from collection elements"""
        if not elements:
            return None

        types = [self.infer_from_value(e) for e in elements[:10]]  # Sample first 10
        types = [t for t in types if t]  # Remove None

        if not types:
            return None

        # Check if all types are the same
        first_type = types[0]
        if all(t.get("typeName") == first_type.get("typeName") for t in types):
            return first_type

        # Mixed types
        return {"kind": "xnkNamedType", "typeName": "auto"}

    def _infer_from_call(self, call_node: ast.Call) -> Optional[Dict[str, Any]]:
        """Infer type from function call"""
        if isinstance(call_node.func, ast.Name):
            name = call_node.func.id

            # Builtin type constructors
            if name in ('int', 'float', 'str', 'bool', 'bytes'):
                return {"kind": "xnkNamedType", "typeName": name}
            elif name in ('list', 'tuple', 'set', 'frozenset'):
                return {"kind": "xnkNamedType", "typeName": name}
            elif name == 'dict':
                return {"kind": "xnkNamedType", "typeName": "dict"}
            elif name in ('range', 'enumerate', 'zip', 'map', 'filter'):
                return {"kind": "xnkNamedType", "typeName": "Iterator"}
            elif name == 'open':
                return {"kind": "xnkNamedType", "typeName": "File"}

        return {"kind": "xnkNamedType", "typeName": "auto"}

    def _infer_from_binop(self, binop: ast.BinOp) -> Optional[Dict[str, Any]]:
        """Infer type from binary operation"""
        left_type = self.infer_from_value(binop.left)
        right_type = self.infer_from_value(binop.right)

        # String concatenation
        if isinstance(binop.op, ast.Add):
            if left_type and left_type.get("typeName") == "str":
                return {"kind": "xnkNamedType", "typeName": "str"}

        # Numeric operations
        if isinstance(binop.op, (ast.Add, ast.Sub, ast.Mult, ast.Mod)):
            if left_type and left_type.get("typeName") in ("int", "float"):
                if right_type and right_type.get("typeName") in ("int", "float"):
                    # float + int = float
                    if "float" in (left_type.get("typeName"), right_type.get("typeName")):
                        return {"kind": "xnkNamedType", "typeName": "float"}
                    return {"kind": "xnkNamedType", "typeName": "int"}

        # Division always returns float
        if isinstance(binop.op, ast.Div):
            return {"kind": "xnkNamedType", "typeName": "float"}

        # Floor division returns int
        if isinstance(binop.op, ast.FloorDiv):
            return {"kind": "xnkNamedType", "typeName": "int"}

        return left_type or right_type or {"kind": "xnkNamedType", "typeName": "auto"}

    def register_var(self, name: str, var_type: Optional[Dict[str, Any]]):
        """Register a variable's inferred type"""
        if var_type:
            self.type_map[name] = {"type": var_type}


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
        self.inferred_types: int = 0
        self.explicit_types: int = 0

    def increment(self, construct: str):
        self.constructs[construct] = self.constructs.get(construct, 0) + 1


def convert_to_xlang(node: Union[ast.AST, List[ast.AST]], stats: Statistics, inferencer: TypeInferencer) -> XLangNode:
    if isinstance(node, list):
        return XLangNode("List", [convert_to_xlang(n, stats, inferencer).to_dict() for n in node])

    if node is None:
        return XLangNode("xnkNoneLit", {})

    stats.increment(type(node).__name__)

    if isinstance(node, ast.Module):
        return XLangNode("xnkFile", {
            "fileName": "",
            "moduleDecls": [convert_to_xlang(n, stats, inferencer).to_dict() for n in node.body]
        })

    elif isinstance(node, ast.FunctionDef):
        # Infer return type if not annotated
        return_type = None
        if node.returns:
            stats.explicit_types += 1
            return_type = convert_to_xlang(node.returns, stats, inferencer).to_dict()
        else:
            # Try to infer from return statements
            stats.inferred_types += 1
            return_type = {"kind": "xnkNamedType", "typeName": "auto"}

        return XLangNode("xnkFuncDecl", {
            "funcName": node.name,
            "params": [convert_param(arg, stats, inferencer) for arg in node.args.args],
            "returnType": return_type,
            "body": {"kind": "xnkBlockStmt", "blockStmts": [convert_to_xlang(stmt, stats, inferencer).to_dict() for stmt in node.body]},
            "decorators": [convert_to_xlang(dec, stats, inferencer).to_dict() for dec in node.decorator_list],
            "isAsync": False
        })

    elif isinstance(node, ast.AsyncFunctionDef):
        return_type = None
        if node.returns:
            stats.explicit_types += 1
            return_type = convert_to_xlang(node.returns, stats, inferencer).to_dict()
        else:
            stats.inferred_types += 1
            return_type = {"kind": "xnkNamedType", "typeName": "auto"}

        return XLangNode("xnkFuncDecl", {
            "funcName": node.name,
            "params": [convert_param(arg, stats, inferencer) for arg in node.args.args],
            "returnType": return_type,
            "body": {"kind": "xnkBlockStmt", "blockStmts": [convert_to_xlang(stmt, stats, inferencer).to_dict() for stmt in node.body]},
            "decorators": [convert_to_xlang(dec, stats, inferencer).to_dict() for dec in node.decorator_list],
            "isAsync": True
        })

    elif isinstance(node, ast.ClassDef):
        return XLangNode("xnkClassDecl", {
            "typeNameDecl": node.name,
            "baseTypes": [convert_to_xlang(base, stats, inferencer).to_dict() for base in node.bases],
            "members": [convert_to_xlang(n, stats, inferencer).to_dict() for n in node.body],
            "decorators": [convert_to_xlang(dec, stats, inferencer).to_dict() for dec in node.decorator_list]
        })

    elif isinstance(node, ast.Return):
        return XLangNode("xnkReturnStmt", {
            "returnExpr": convert_to_xlang(node.value, stats, inferencer).to_dict() if node.value else None
        })

    elif isinstance(node, ast.Assign):
        # Infer type from value
        value_dict = convert_to_xlang(node.value, stats, inferencer).to_dict()
        inferred_type = inferencer.infer_from_value(node.value)

        # Register variables with their types
        for target in node.targets:
            if isinstance(target, ast.Name):
                inferencer.register_var(target.id, inferred_type)

        stats.inferred_types += 1
        return XLangNode("xnkVarDecl", {
            "varDecls": [{
                "varName": convert_to_xlang(t, stats, inferencer).to_dict(),
                "varType": inferred_type,
                "varInit": value_dict
            } for t in node.targets]
        })

    elif isinstance(node, ast.AnnAssign):
        # Explicit type annotation
        stats.explicit_types += 1
        var_type = convert_to_xlang(node.annotation, stats, inferencer).to_dict()

        if isinstance(node.target, ast.Name):
            inferencer.register_var(node.target.id, var_type)

        return XLangNode("xnkVarDecl", {
            "varName": convert_to_xlang(node.target, stats, inferencer).to_dict(),
            "varType": var_type,
            "varInit": convert_to_xlang(node.value, stats, inferencer).to_dict() if node.value else None
        })

    elif isinstance(node, ast.AugAssign):
        return XLangNode("xnkAsgn", {
            "asgnLeft": convert_to_xlang(node.target, stats, inferencer).to_dict(),
            "asgnRight": XLangNode("xnkBinaryExpr", {
                "binaryLeft": convert_to_xlang(node.target, stats, inferencer).to_dict(),
                "binaryOp": ast_op_to_string(node.op),
                "binaryRight": convert_to_xlang(node.value, stats, inferencer).to_dict()
            }).to_dict()
        })

    elif isinstance(node, ast.For):
        return XLangNode("xnkForeachStmt", {
            "foreachVar": convert_to_xlang(node.target, stats, inferencer).to_dict(),
            "foreachIter": convert_to_xlang(node.iter, stats, inferencer).to_dict(),
            "foreachBody": {"kind": "xnkBlockStmt", "blockStmts": [convert_to_xlang(n, stats, inferencer).to_dict() for n in node.body]},
            "foreachElse": {"kind": "xnkBlockStmt", "blockStmts": [convert_to_xlang(n, stats, inferencer).to_dict() for n in node.orelse]} if node.orelse else None
        })

    elif isinstance(node, ast.While):
        return XLangNode("xnkWhileStmt", {
            "whileCond": convert_to_xlang(node.test, stats, inferencer).to_dict(),
            "whileBody": {"kind": "xnkBlockStmt", "blockStmts": [convert_to_xlang(n, stats, inferencer).to_dict() for n in node.body]},
            "whileElse": {"kind": "xnkBlockStmt", "blockStmts": [convert_to_xlang(n, stats, inferencer).to_dict() for n in node.orelse]} if node.orelse else None
        })

    elif isinstance(node, ast.If):
        return XLangNode("xnkIfStmt", {
            "ifCond": convert_to_xlang(node.test, stats, inferencer).to_dict(),
            "ifBody": {"kind": "xnkBlockStmt", "blockStmts": [convert_to_xlang(n, stats, inferencer).to_dict() for n in node.body]},
            "elseBody": {"kind": "xnkBlockStmt", "blockStmts": [convert_to_xlang(n, stats, inferencer).to_dict() for n in node.orelse]} if node.orelse else None
        })

    elif isinstance(node, ast.With):
        return XLangNode("xnkWithStmt", {
            "withItems": [convert_to_xlang(item, stats, inferencer).to_dict() for item in node.items],
            "withBody": {"kind": "xnkBlockStmt", "blockStmts": [convert_to_xlang(n, stats, inferencer).to_dict() for n in node.body]}
        })

    elif isinstance(node, ast.withitem):
        return XLangNode("xnkWithItem", {
            "contextExpr": convert_to_xlang(node.context_expr, stats, inferencer).to_dict(),
            "optionalVars": convert_to_xlang(node.optional_vars, stats, inferencer).to_dict() if node.optional_vars else None
        })

    elif isinstance(node, ast.Try):
        return XLangNode("xnkTryStmt", {
            "tryBody": {"kind": "xnkBlockStmt", "blockStmts": [convert_to_xlang(n, stats, inferencer).to_dict() for n in node.body]},
            "catchClauses": [convert_to_xlang(h, stats, inferencer).to_dict() for h in node.handlers],
            "tryElse": {"kind": "xnkBlockStmt", "blockStmts": [convert_to_xlang(n, stats, inferencer).to_dict() for n in node.orelse]} if node.orelse else None,
            "finallyBody": {"kind": "xnkBlockStmt", "blockStmts": [convert_to_xlang(n, stats, inferencer).to_dict() for n in node.finalbody]} if node.finalbody else None
        })

    elif isinstance(node, ast.ExceptHandler):
        return XLangNode("xnkCatchStmt", {
            "catchType": convert_to_xlang(node.type, stats, inferencer).to_dict() if node.type else {"kind": "xnkNamedType", "typeName": "Exception"},
            "catchVar": node.name,
            "catchBody": {"kind": "xnkBlockStmt", "blockStmts": [convert_to_xlang(n, stats, inferencer).to_dict() for n in node.body]}
        })

    elif isinstance(node, ast.Raise):
        return XLangNode("xnkThrowStmt", {
            "throwExpr": convert_to_xlang(node.exc, stats, inferencer).to_dict() if node.exc else None,
            "throwCause": convert_to_xlang(node.cause, stats, inferencer).to_dict() if node.cause else None
        })

    elif isinstance(node, ast.Assert):
        return XLangNode("xnkAssertStmt", {
            "assertCond": convert_to_xlang(node.test, stats, inferencer).to_dict(),
            "assertMsg": convert_to_xlang(node.msg, stats, inferencer).to_dict() if node.msg else None
        })

    elif isinstance(node, ast.Import):
        return XLangNode("xnkImport", {
            "importNames": [{"name": alias.name, "asname": alias.asname} for alias in node.names]
        })

    elif isinstance(node, ast.ImportFrom):
        return XLangNode("xnkImport", {
            "importModule": node.module,
            "importNames": [{"name": alias.name, "asname": alias.asname} for alias in node.names],
            "importLevel": node.level
        })

    elif isinstance(node, ast.Global):
        return XLangNode("xnkGlobal", {"globalNames": node.names})

    elif isinstance(node, ast.Nonlocal):
        return XLangNode("xnkNonlocal", {"nonlocalNames": node.names})

    elif isinstance(node, ast.Expr):
        return convert_to_xlang(node.value, stats, inferencer)

    elif isinstance(node, ast.Pass):
        return XLangNode("xnkPassStmt", {})

    elif isinstance(node, ast.Break):
        return XLangNode("xnkBreakStmt", {})

    elif isinstance(node, ast.Continue):
        return XLangNode("xnkContinueStmt", {})

    elif isinstance(node, ast.BinOp):
        return XLangNode("xnkBinaryExpr", {
            "binaryLeft": convert_to_xlang(node.left, stats, inferencer).to_dict(),
            "binaryOp": ast_op_to_string(node.op),
            "binaryRight": convert_to_xlang(node.right, stats, inferencer).to_dict()
        })

    elif isinstance(node, ast.UnaryOp):
        return XLangNode("xnkUnaryExpr", {
            "unaryOp": ast_op_to_string(node.op),
            "unaryExpr": convert_to_xlang(node.operand, stats, inferencer).to_dict()
        })

    elif isinstance(node, ast.Lambda):
        return XLangNode("xnkLambdaExpr", {
            "lambdaParams": [convert_param(arg, stats, inferencer) for arg in node.args.args],
            "lambdaBody": convert_to_xlang(node.body, stats, inferencer).to_dict()
        })

    elif isinstance(node, ast.IfExp):
        return XLangNode("xnkTernaryExpr", {
            "ternaryCond": convert_to_xlang(node.test, stats, inferencer).to_dict(),
            "ternaryThen": convert_to_xlang(node.body, stats, inferencer).to_dict(),
            "ternaryElse": convert_to_xlang(node.orelse, stats, inferencer).to_dict()
        })

    elif isinstance(node, ast.Dict):
        return XLangNode("xnkDictLit", {
            "dictKeys": [convert_to_xlang(k, stats, inferencer).to_dict() if k else None for k in node.keys],
            "dictValues": [convert_to_xlang(v, stats, inferencer).to_dict() for v in node.values]
        })

    elif isinstance(node, ast.Set):
        return XLangNode("xnkSetLit", {
            "setElements": [convert_to_xlang(e, stats, inferencer).to_dict() for e in node.elts]
        })

    elif isinstance(node, ast.ListComp):
        return XLangNode("xnkListComp", {
            "compElement": convert_to_xlang(node.elt, stats, inferencer).to_dict(),
            "compGenerators": [convert_to_xlang(g, stats, inferencer).to_dict() for g in node.generators]
        })

    elif isinstance(node, ast.SetComp):
        return XLangNode("xnkSetComp", {
            "compElement": convert_to_xlang(node.elt, stats, inferencer).to_dict(),
            "compGenerators": [convert_to_xlang(g, stats, inferencer).to_dict() for g in node.generators]
        })

    elif isinstance(node, ast.DictComp):
        return XLangNode("xnkDictComp", {
            "compKey": convert_to_xlang(node.key, stats, inferencer).to_dict(),
            "compValue": convert_to_xlang(node.value, stats, inferencer).to_dict(),
            "compGenerators": [convert_to_xlang(g, stats, inferencer).to_dict() for g in node.generators]
        })

    elif isinstance(node, ast.GeneratorExp):
        return XLangNode("xnkGeneratorExpr", {
            "genElement": convert_to_xlang(node.elt, stats, inferencer).to_dict(),
            "genGenerators": [convert_to_xlang(g, stats, inferencer).to_dict() for g in node.generators]
        })

    elif isinstance(node, ast.comprehension):
        return XLangNode("xnkComprehension", {
            "compTarget": convert_to_xlang(node.target, stats, inferencer).to_dict(),
            "compIter": convert_to_xlang(node.iter, stats, inferencer).to_dict(),
            "compFilters": [convert_to_xlang(i, stats, inferencer).to_dict() for i in node.ifs],
            "compIsAsync": node.is_async
        })

    elif isinstance(node, ast.Await):
        return XLangNode("xnkAwaitExpr", {
            "awaitExpr": convert_to_xlang(node.value, stats, inferencer).to_dict()
        })

    elif isinstance(node, ast.Yield):
        return XLangNode("xnkYieldExpr", {
            "yieldExpr": convert_to_xlang(node.value, stats, inferencer).to_dict() if node.value else None
        })

    elif isinstance(node, ast.YieldFrom):
        return XLangNode("xnkYieldFromExpr", {
            "yieldFromExpr": convert_to_xlang(node.value, stats, inferencer).to_dict()
        })

    elif isinstance(node, ast.Compare):
        return XLangNode("xnkCompareExpr", {
            "compareLeft": convert_to_xlang(node.left, stats, inferencer).to_dict(),
            "compareOps": [ast_op_to_string(op) for op in node.ops],
            "compareRight": [convert_to_xlang(c, stats, inferencer).to_dict() for c in node.comparators]
        })

    elif isinstance(node, ast.Call):
        return XLangNode("xnkCallExpr", {
            "callName": convert_to_xlang(node.func, stats, inferencer).to_dict(),
            "callArgs": [convert_to_xlang(arg, stats, inferencer).to_dict() for arg in node.args],
            "callKeywords": [convert_to_xlang(kw, stats, inferencer).to_dict() for kw in node.keywords]
        })

    elif isinstance(node, ast.keyword):
        return XLangNode("xnkKeywordArg", {
            "kwName": node.arg,
            "kwValue": convert_to_xlang(node.value, stats, inferencer).to_dict()
        })

    elif isinstance(node, ast.Constant):
        if isinstance(node.value, int):
            return XLangNode("xnkIntLit", {"literalValue": str(node.value)})
        elif isinstance(node.value, float):
            return XLangNode("xnkFloatLit", {"literalValue": str(node.value)})
        elif isinstance(node.value, str):
            return XLangNode("xnkStringLit", {"literalValue": node.value})
        elif isinstance(node.value, bool):
            return XLangNode("xnkBoolLit", {"literalValue": node.value})
        elif node.value is None:
            return XLangNode("xnkNilLit", {})
        else:
            return XLangNode("xnkConstant", {"literalValue": str(node.value)})

    elif isinstance(node, ast.Attribute):
        return XLangNode("xnkMemberAccessExpr", {
            "memberObject": convert_to_xlang(node.value, stats, inferencer).to_dict(),
            "memberName": node.attr
        })

    elif isinstance(node, ast.Subscript):
        return XLangNode("xnkIndexExpr", {
            "indexBase": convert_to_xlang(node.value, stats, inferencer).to_dict(),
            "indexExpr": convert_to_xlang(node.slice, stats, inferencer).to_dict()
        })

    elif isinstance(node, ast.Slice):
        return XLangNode("xnkSliceExpr", {
            "sliceStart": convert_to_xlang(node.lower, stats, inferencer).to_dict() if node.lower else None,
            "sliceEnd": convert_to_xlang(node.upper, stats, inferencer).to_dict() if node.upper else None,
            "sliceStep": convert_to_xlang(node.step, stats, inferencer).to_dict() if node.step else None
        })

    elif isinstance(node, ast.Starred):
        return XLangNode("xnkStarredExpr", {
            "starredExpr": convert_to_xlang(node.value, stats, inferencer).to_dict()
        })

    elif isinstance(node, ast.Name):
        return XLangNode("xnkIdentifier", {"identName": node.id})

    elif isinstance(node, ast.List):
        return XLangNode("xnkArrayLiteral", {
            "arrayElements": [convert_to_xlang(e, stats, inferencer).to_dict() for e in node.elts]
        })

    elif isinstance(node, ast.Tuple):
        return XLangNode("xnkTupleLit", {
            "tupleElements": [convert_to_xlang(e, stats, inferencer).to_dict() for e in node.elts]
        })

    elif isinstance(node, ast.arg):
        # Should use convert_param instead
        return convert_param(node, stats, inferencer)

    # Type annotations
    elif isinstance(node, ast.Name) and hasattr(node, 'id'):
        return XLangNode("xnkNamedType", {"typeName": node.id})

    elif isinstance(node, ast.Subscript) and isinstance(node.value, ast.Name):
        # Generic type like List[int]
        return XLangNode("xnkGenericType", {
            "typeName": node.value.id,
            "typeArgs": [convert_to_xlang(node.slice, stats, inferencer).to_dict()]
        })

    else:
        return XLangNode("xnkUnknown", {"pythonType": type(node).__name__})


def convert_param(arg: ast.arg, stats: Statistics, inferencer: TypeInferencer) -> Dict[str, Any]:
    """Convert parameter with type inference"""
    param_type = None
    if arg.annotation:
        stats.explicit_types += 1
        param_type = convert_to_xlang(arg.annotation, stats, inferencer).to_dict()
    else:
        stats.inferred_types += 1
        param_type = {"kind": "xnkNamedType", "typeName": "auto"}

    return {
        "kind": "xnkParameter",
        "paramName": arg.arg,
        "paramType": param_type
    }


def ast_op_to_string(op: ast.AST) -> str:
    """Convert AST operator to string"""
    op_map = {
        ast.Add: '+', ast.Sub: '-', ast.Mult: '*', ast.Div: '/', ast.FloorDiv: '//',
        ast.Mod: '%', ast.Pow: '**', ast.LShift: '<<', ast.RShift: '>>',
        ast.BitOr: '|', ast.BitXor: '^', ast.BitAnd: '&',
        ast.And: 'and', ast.Or: 'or',
        ast.Eq: '==', ast.NotEq: '!=', ast.Lt: '<', ast.LtE: '<=',
        ast.Gt: '>', ast.GtE: '>=', ast.Is: 'is', ast.IsNot: 'is not',
        ast.In: 'in', ast.NotIn: 'not in',
        ast.UAdd: '+', ast.USub: '-', ast.Not: 'not', ast.Invert: '~'
    }
    return op_map.get(type(op), type(op).__name__)


def process_file(filename: str, stats: Statistics) -> None:
    """Process a Python file and convert to XLang JSON"""
    with open(filename, 'r', encoding='utf-8') as file:
        source = file.read()

    tree = ast.parse(source, filename=filename)
    inferencer = TypeInferencer()
    xlang_ast = convert_to_xlang(tree, stats, inferencer)

    json_data = json.dumps(xlang_ast.to_dict(), indent=2)
    print(json_data)

    # Print statistics to stderr
    print(f"\n=== Statistics for {filename} ===", file=sys.stderr)
    print(f"AST Node Types:", file=sys.stderr)
    for construct, count in sorted(stats.constructs.items()):
        print(f"  {construct}: {count}", file=sys.stderr)
    print(f"\nType Statistics:", file=sys.stderr)
    print(f"  Explicit type annotations: {stats.explicit_types}", file=sys.stderr)
    print(f"  Inferred/auto types: {stats.inferred_types}", file=sys.stderr)


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: python python_to_xlang_typed.py <file.py>", file=sys.stderr)
        sys.exit(1)

    path = sys.argv[1]
    stats = Statistics()

    if os.path.isfile(path) and path.endswith('.py'):
        process_file(path, stats)
    else:
        print(f"Error: {path} is not a Python file", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
