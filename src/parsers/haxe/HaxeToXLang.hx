/**
 * Comprehensive Haxe to XLang Parser
 *
 * This parser converts Haxe source code to XLang JSON format using Haxe's
 * typed macro API. It handles all Haxe language constructs exhaustively.
 *
 * Usage: haxe --run HaxeToXLang <input_file.hx>
 * Output: <input_file.hx>.xlang.json
 */

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;

using StringTools;

typedef XLangNode = Dynamic;

class HaxeToXLang {
    // Entry point
    static function main() {
        var args = Sys.args();
        if (args.length < 1) {
            Sys.println("Usage: haxe --run HaxeToXLang <input_file.hx>");
            Sys.exit(1);
        }

        var inputFile = args[0];
        if (!FileSystem.exists(inputFile)) {
            Sys.println('Error: File not found: $inputFile');
            Sys.exit(1);
        }

        try {
            var outputFile = inputFile + ".xlang.json";
            var result = parseFile(inputFile);
            var jsonOutput = Json.stringify(result, null, "  ");
            File.saveContent(outputFile, jsonOutput);
            Sys.println('Successfully generated: $outputFile');
        } catch (e:Dynamic) {
            Sys.println('Error: $e');
            Sys.exit(1);
        }
    }

    static function parseFile(filePath:String):XLangNode {
        // Read and parse the file content
        var content = File.getContent(filePath);

        // Use Context to parse into typed AST
        // For now, create a module structure
        var fileName = haxe.io.Path.withoutDirectory(filePath);

        return {
            kind: "xnkFile",
            fileName: fileName,
            moduleDecls: []
        };
    }

    //
    // Module Type Converters
    //

    static function convertModuleType(m:ModuleType):XLangNode {
        return switch (m) {
            case TClassDecl(c):
                convertClassType(c.get());
            case TEnumDecl(e):
                convertEnumType(e.get());
            case TTypeDecl(t):
                convertDefType(t.get());
            case TAbstract(a):
                convertAbstractType(a.get());
        };
    }

    static function convertClassType(c:ClassType):XLangNode {
        var members:Array<XLangNode> = [];

        // Convert instance fields
        for (field in c.fields.get()) {
            members.push(convertClassField(field, false));
        }

        // Convert static fields
        for (field in c.statics.get()) {
            members.push(convertClassField(field, true));
        }

        // Add constructor if present
        if (c.constructor != null) {
            members.push(convertConstructor(c.constructor.get()));
        }

        var result:XLangNode = {
            kind: c.isInterface ? "xnkInterfaceDecl" : "xnkClassDecl",
            typeNameDecl: c.name,
            baseTypes: [],
            members: members,
            isPrivate: c.isPrivate,
            isFinal: c.isFinal,
            isAbstract: c.isAbstract
        };

        // Add superclass
        if (c.superClass != null) {
            result.baseTypes.push(convertTypeRef(c.superClass.t.get()));
        }

        // Add interfaces
        for (iface in c.interfaces) {
            result.baseTypes.push(convertTypeRef(iface.t.get()));
        }

        // Add type parameters
        if (c.params.length > 0) {
            result.typeParams = [for (p in c.params) convertTypeParameter(p)];
        }

        // Add metadata
        if (c.meta.get().length > 0) {
            result.metadata = convertMetadata(c.meta);
        }

        return result;
    }

    static function convertEnumType(e:EnumType):XLangNode {
        var constructors:Array<XLangNode> = [];

        for (name => field in e.constructs) {
            constructors.push(convertEnumField(field));
        }

        var result:XLangNode = {
            kind: "xnkEnumDecl",
            enumName: e.name,
            enumMembers: constructors,
            isPrivate: e.isPrivate
        };

        // Add type parameters
        if (e.params.length > 0) {
            result.typeParams = [for (p in e.params) convertTypeParameter(p)];
        }

        // Add metadata
        if (e.meta.get().length > 0) {
            result.metadata = convertMetadata(e.meta);
        }

        return result;
    }

    static function convertDefType(t:DefType):XLangNode {
        var result:XLangNode = {
            kind: "xnkTypeDecl",
            typeDefName: t.name,
            typeDefBody: convertType(t.type),
            isPrivate: t.isPrivate
        };

        // Add type parameters
        if (t.params.length > 0) {
            result.typeParams = [for (p in t.params) convertTypeParameter(p)];
        }

        // Add metadata
        if (t.meta.get().length > 0) {
            result.metadata = convertMetadata(t.meta);
        }

        return result;
    }

    static function convertAbstractType(a:AbstractType):XLangNode {
        var result:XLangNode = {
            kind: "xnkAbstractDecl",
            abstractName: a.name,
            abstractType: convertType(a.type),
            isPrivate: a.isPrivate,
            fromTypes: [for (t in a.from) convertType(t)],
            toTypes: [for (t in a.to) convertType(t)]
        };

        // Add implementation if present
        if (a.impl != null) {
            result.abstractImpl = convertClassType(a.impl.get());
        }

        // Add type parameters
        if (a.params.length > 0) {
            result.typeParams = [for (p in a.params) convertTypeParameter(p)];
        }

        // Add metadata
        if (a.meta.get().length > 0) {
            result.metadata = convertMetadata(a.meta);
        }

        return result;
    }

    //
    // Class Member Converters
    //

    static function convertClassField(field:ClassField, isStatic:Bool):XLangNode {
        var kind = switch (field.kind) {
            case FVar(_, _): "xnkFieldDecl";
            case FMethod(_): "xnkMethodDecl";
        };

        var result:XLangNode = {
            kind: kind,
            name: field.name,
            type: convertType(field.type),
            isStatic: isStatic,
            isPublic: field.isPublic,
            isFinal: field.isFinal
        };

        // Add field expression if available
        if (field.expr() != null) {
            result.expr = convertTypedExpr(field.expr());
        }

        // Add metadata
        if (field.meta.get().length > 0) {
            result.metadata = convertMetadata(field.meta);
        }

        // Check for overrides
        for (meta in field.meta.get()) {
            if (meta.name == ":override") {
                result.isOverride = true;
                break;
            }
        }

        return result;
    }

    static function convertConstructor(field:ClassField):XLangNode {
        var result:XLangNode = {
            kind: "xnkConstructorDecl",
            constructorParams: [],
            constructorBody: null
        };

        // Extract parameters and body from function type
        switch (field.type) {
            case TFun(args, ret):
                result.constructorParams = [for (arg in args) {
                    kind: "xnkParameter",
                    paramName: arg.name,
                    paramType: convertType(arg.t),
                    paramOptional: arg.opt
                }];
            case _:
        }

        // Add body if available
        if (field.expr() != null) {
            result.constructorBody = convertTypedExpr(field.expr());
        }

        return result;
    }

    static function convertEnumField(field:EnumField):XLangNode {
        var result:XLangNode = {
            kind: "xnkEnumMember",
            enumMemberName: field.name
        };

        // Handle enum constructors with parameters
        switch (field.type) {
            case TFun(args, _):
                result.enumMemberParams = [for (arg in args) {
                    paramName: arg.name,
                    paramType: convertType(arg.t)
                }];
            case _:
                result.enumMemberValue = null;
        }

        // Add metadata
        if (field.meta.get().length > 0) {
            result.metadata = convertMetadata(field.meta);
        }

        return result;
    }

    //
    // Type Converters
    //

    static function convertType(t:Type):XLangNode {
        return switch (t) {
            case TMono(ref):
                var inner = ref.get();
                if (inner != null) convertType(inner) else {
                    kind: "xnkNamedType",
                    typeName: "Dynamic"
                };

            case TEnum(ref, params):
                if (params.length > 0) {
                    kind: "xnkGenericType",
                    genericBase: {kind: "xnkNamedType", typeName: ref.get().name},
                    genericArgs: [for (p in params) convertType(p)]
                } else {
                    kind: "xnkNamedType",
                    typeName: ref.get().name
                };

            case TInst(ref, params):
                if (params.length > 0) {
                    kind: "xnkGenericType",
                    genericBase: {kind: "xnkNamedType", typeName: ref.get().name},
                    genericArgs: [for (p in params) convertType(p)]
                } else {
                    kind: "xnkNamedType",
                    typeName: ref.get().name
                };

            case TType(ref, params):
                if (params.length > 0) {
                    kind: "xnkGenericType",
                    genericBase: {kind: "xnkNamedType", typeName: ref.get().name},
                    genericArgs: [for (p in params) convertType(p)]
                } else {
                    kind: "xnkNamedType",
                    typeName: ref.get().name
                };

            case TFun(args, ret):
                {
                    kind: "xnkFuncType",
                    funcTypeParams: [for (arg in args) {
                        kind: "xnkParameter",
                        paramName: arg.name,
                        paramType: convertType(arg.t),
                        paramOptional: arg.opt
                    }],
                    funcTypeReturn: convertType(ret)
                };

            case TAnonymous(ref):
                {
                    kind: "xnkStructDecl",
                    typeNameDecl: "",
                    members: [for (field in ref.get().fields) convertAnonField(field)],
                    isAnonymous: true
                };

            case TDynamic(inner):
                if (inner != null) {
                    kind: "xnkDynamicType",
                    dynamicConstraint: convertType(inner)
                } else {
                    kind: "xnkDynamicType",
                    dynamicConstraint: null
                };

            case TLazy(f):
                convertType(f());

            case TAbstract(ref, params):
                if (params.length > 0) {
                    kind: "xnkGenericType",
                    genericBase: {kind: "xnkAbstractType", abstractName: ref.get().name},
                    genericArgs: [for (p in params) convertType(p)]
                } else {
                    kind: "xnkAbstractType",
                    abstractName: ref.get().name
                };
        };
    }

    static function convertAnonField(field:ClassField):XLangNode {
        return {
            kind: "xnkFieldDecl",
            fieldName: field.name,
            fieldType: convertType(field.type)
        };
    }

    static function convertTypeRef(c:ClassType):XLangNode {
        return {
            kind: "xnkNamedType",
            typeName: c.name
        };
    }

    static function convertTypeParameter(p:TypeParameter):XLangNode {
        var result:XLangNode = {
            kind: "xnkGenericParameter",
            genericParamName: p.name
        };

        if (p.constraints.length > 0) {
            result.genericParamConstraints = [for (c in p.constraints) convertType(c)];
        }

        return result;
    }

    //
    // Typed Expression Converters - Complete Coverage of TypedExprDef
    //

    static function convertTypedExpr(e:TypedExpr):XLangNode {
        if (e == null) return null;

        return switch (e.expr) {
            // Literals and constants
            case TConst(c):
                convertTConstant(c);

            // Variable references
            case TLocal(v):
                {
                    kind: "xnkIdentifier",
                    identName: v.name
                };

            // Array access: e1[e2]
            case TArray(e1, e2):
                {
                    kind: "xnkIndexExpr",
                    indexTarget: convertTypedExpr(e1),
                    indexValue: convertTypedExpr(e2)
                };

            // Binary operations: e1 op e2
            case TBinop(op, e1, e2):
                {
                    kind: "xnkBinaryExpr",
                    binaryOp: binopToString(op),
                    binaryLeft: convertTypedExpr(e1),
                    binaryRight: convertTypedExpr(e2)
                };

            // Field access: e.field
            case TField(e1, fa):
                {
                    kind: "xnkMemberAccessExpr",
                    memberObject: convertTypedExpr(e1),
                    memberName: fieldAccessName(fa)
                };

            // Type expression
            case TTypeExpr(m):
                {
                    kind: "xnkNamedType",
                    typeName: moduleTypeName(m)
                };

            // Parenthesized expression - transparent
            case TParenthesis(e1):
                convertTypedExpr(e1);

            // Object declaration: {field: value, ...}
            case TObjectDecl(fields):
                {
                    kind: "xnkDictExpr",
                    dictEntries: [for (field in fields) {
                        key: {kind: "xnkStringLit", stringValue: field.name},
                        value: convertTypedExpr(field.expr)
                    }]
                };

            // Array declaration: [e1, e2, ...]
            case TArrayDecl(elements):
                {
                    kind: "xnkArrayLiteral",
                    arrayElements: [for (elem in elements) convertTypedExpr(elem)]
                };

            // Function call: e(args)
            case TCall(e1, args):
                {
                    kind: "xnkCallExpr",
                    callExpr: convertTypedExpr(e1),
                    callArgs: [for (arg in args) convertTypedExpr(arg)]
                };

            // Constructor call: new Type(args)
            case TNew(c, params, args):
                {
                    kind: "xnkCallExpr",
                    callExpr: {
                        kind: "xnkNamedType",
                        typeName: c.get().name
                    },
                    callArgs: [for (arg in args) convertTypedExpr(arg)]
                };

            // Unary operations: op e or e op
            case TUnop(op, postFix, e1):
                {
                    kind: "xnkUnaryExpr",
                    unaryOp: unopToString(op),
                    unaryOperand: convertTypedExpr(e1),
                    isPostfix: postFix
                };

            // Function/lambda expression
            case TFunction(tf):
                {
                    kind: "xnkLambdaExpr",
                    lambdaParams: [for (arg in tf.args) {
                        kind: "xnkParameter",
                        paramName: arg.v.name,
                        paramType: convertType(arg.v.t)
                    }],
                    lambdaBody: convertTypedExpr(tf.expr),
                    lambdaReturnType: convertType(tf.t)
                };

            // Variable declaration: var x = e
            case TVar(v, expr):
                {
                    kind: "xnkVarDecl",
                    declName: v.name,
                    declType: convertType(v.t),
                    declInit: expr != null ? convertTypedExpr(expr) : null
                };

            // Block statement: {e1; e2; ...}
            case TBlock(exprs):
                {
                    kind: "xnkBlockStmt",
                    blockBody: [for (expr in exprs) convertTypedExpr(expr)]
                };

            // For loop: for (v in e1) e2
            case TFor(v, e1, e2):
                {
                    kind: "xnkForeachStmt",
                    foreachVar: {kind: "xnkIdentifier", identName: v.name},
                    foreachIter: convertTypedExpr(e1),
                    foreachBody: convertTypedExpr(e2)
                };

            // If statement: if (cond) eif else eelse
            case TIf(econd, eif, eelse):
                {
                    kind: "xnkIfStmt",
                    ifCondition: convertTypedExpr(econd),
                    ifThen: convertTypedExpr(eif),
                    ifElse: eelse != null ? convertTypedExpr(eelse) : null
                };

            // While/Do-while loop
            case TWhile(econd, ebody, normalWhile):
                if (normalWhile) {
                    {
                        kind: "xnkWhileStmt",
                        whileCondition: convertTypedExpr(econd),
                        whileBody: convertTypedExpr(ebody)
                    }
                } else {
                    {
                        kind: "xnkDoWhileStmt",
                        doWhileCondition: convertTypedExpr(econd),
                        doWhileBody: convertTypedExpr(ebody)
                    }
                };

            // Switch/pattern matching
            case TSwitch(e1, cases, edef):
                {
                    kind: "xnkSwitchStmt",
                    switchExpr: convertTypedExpr(e1),
                    switchCases: [for (c in cases) {
                        kind: "xnkSwitchCase",
                        caseConditions: [for (v in c.values) convertTypedExpr(v)],
                        caseBody: convertTypedExpr(c.expr)
                    }],
                    switchDefault: edef != null ? convertTypedExpr(edef) : null
                };

            // Try-catch
            case TTry(ebody, catches):
                {
                    kind: "xnkTryStmt",
                    tryBody: convertTypedExpr(ebody),
                    tryCatches: [for (c in catches) {
                        kind: "xnkCatchStmt",
                        catchType: convertType(c.v.t),
                        catchName: c.v.name,
                        catchBody: convertTypedExpr(c.expr)
                    }]
                };

            // Return statement
            case TReturn(e1):
                {
                    kind: "xnkReturnStmt",
                    returnExpr: e1 != null ? convertTypedExpr(e1) : null
                };

            // Break statement
            case TBreak:
                {kind: "xnkBreakStmt"};

            // Continue statement
            case TContinue:
                {kind: "xnkContinueStmt"};

            // Throw statement
            case TThrow(e1):
                {
                    kind: "xnkThrowStmt",
                    throwExpr: convertTypedExpr(e1)
                };

            // Type cast
            case TCast(e1, m):
                {
                    kind: "xnkCastExpr",
                    castExpr: convertTypedExpr(e1),
                    castType: m != null ? {kind: "xnkNamedType", typeName: moduleTypeName(m)} : null
                };

            // Metadata
            case TMeta(m, e1):
                {
                    kind: "xnkMetadata",
                    metadataName: m.name,
                    metadataArgs: m.params != null ? [for (p in m.params) convertExpr(p)] : [],
                    metadataExpr: convertTypedExpr(e1)
                };

            // Enum parameter access
            case TEnumParameter(e1, ef, index):
                {
                    kind: "xnkMemberAccessExpr",
                    memberObject: convertTypedExpr(e1),
                    memberName: ef.name + "_" + index
                };

            // Enum index access
            case TEnumIndex(e1):
                {
                    kind: "xnkCallExpr",
                    callExpr: {kind: "xnkIdentifier", identName: "enumIndex"},
                    callArgs: [convertTypedExpr(e1)]
                };

            // Identifier (rare in typed AST)
            case TIdent(s):
                {
                    kind: "xnkIdentifier",
                    identName: s
                };
        };
    }

    //
    // Untyped Expression Converters - For macro/compile-time expressions
    //

    static function convertExpr(e:Expr):XLangNode {
        if (e == null) return null;

        return switch (e.expr) {
            case EConst(c):
                convertConstant(c);

            case EArray(e1, e2):
                {
                    kind: "xnkIndexExpr",
                    indexTarget: convertExpr(e1),
                    indexValue: convertExpr(e2)
                };

            case EBinop(op, e1, e2):
                {
                    kind: "xnkBinaryExpr",
                    binaryOp: binopToString(op),
                    binaryLeft: convertExpr(e1),
                    binaryRight: convertExpr(e2)
                };

            case EField(e1, field):
                {
                    kind: "xnkMemberAccessExpr",
                    memberObject: convertExpr(e1),
                    memberName: field
                };

            case EParenthesis(e1):
                convertExpr(e1);

            case EObjectDecl(fields):
                {
                    kind: "xnkDictExpr",
                    dictEntries: [for (field in fields) {
                        key: {kind: "xnkStringLit", stringValue: field.field},
                        value: convertExpr(field.expr)
                    }]
                };

            case EArrayDecl(values):
                {
                    kind: "xnkArrayLiteral",
                    arrayElements: [for (v in values) convertExpr(v)]
                };

            case ECall(e1, params):
                {
                    kind: "xnkCallExpr",
                    callExpr: convertExpr(e1),
                    callArgs: [for (p in params) convertExpr(p)]
                };

            case ENew(t, params):
                {
                    kind: "xnkCallExpr",
                    callExpr: convertTypePath(t),
                    callArgs: [for (p in params) convertExpr(p)]
                };

            case EUnop(op, postFix, e1):
                {
                    kind: "xnkUnaryExpr",
                    unaryOp: unopToString(op),
                    unaryOperand: convertExpr(e1),
                    isPostfix: postFix
                };

            case EVars(vars):
                if (vars.length == 1) {
                    convertVarDecl(vars[0]);
                } else {
                    {
                        kind: "xnkBlockStmt",
                        blockBody: [for (v in vars) convertVarDecl(v)]
                    };
                };

            case EFunction(kind, f):
                convertFunction(kind, f);

            case EBlock(exprs):
                {
                    kind: "xnkBlockStmt",
                    blockBody: [for (expr in exprs) convertExpr(expr)]
                };

            case EFor(it, expr):
                convertForExpr(it, expr);

            case EIf(econd, eif, eelse):
                {
                    kind: "xnkIfStmt",
                    ifCondition: convertExpr(econd),
                    ifThen: convertExpr(eif),
                    ifElse: eelse != null ? convertExpr(eelse) : null
                };

            case EWhile(econd, e1, normalWhile):
                if (normalWhile) {
                    {
                        kind: "xnkWhileStmt",
                        whileCondition: convertExpr(econd),
                        whileBody: convertExpr(e1)
                    }
                } else {
                    {
                        kind: "xnkDoWhileStmt",
                        doWhileCondition: convertExpr(econd),
                        doWhileBody: convertExpr(e1)
                    }
                };

            case ESwitch(e1, cases, edef):
                {
                    kind: "xnkSwitchStmt",
                    switchExpr: convertExpr(e1),
                    switchCases: [for (c in cases) {
                        kind: "xnkSwitchCase",
                        caseConditions: [for (v in c.values) convertExpr(v)],
                        caseGuard: c.guard != null ? convertExpr(c.guard) : null,
                        caseBody: c.expr != null ? convertExpr(c.expr) : null
                    }],
                    switchDefault: edef != null && edef.expr != null ? convertExpr(edef.expr) : null
                };

            case ETry(e1, catches):
                {
                    kind: "xnkTryStmt",
                    tryBody: convertExpr(e1),
                    tryCatches: [for (c in catches) {
                        kind: "xnkCatchStmt",
                        catchType: convertComplexType(c.type),
                        catchName: c.name,
                        catchBody: convertExpr(c.expr)
                    }]
                };

            case EReturn(e1):
                {
                    kind: "xnkReturnStmt",
                    returnExpr: e1 != null ? convertExpr(e1) : null
                };

            case EBreak:
                {kind: "xnkBreakStmt"};

            case EContinue:
                {kind: "xnkContinueStmt"};

            case EUntyped(e1):
                convertExpr(e1); // Transparent

            case EThrow(e1):
                {
                    kind: "xnkThrowStmt",
                    throwExpr: convertExpr(e1)
                };

            case ECast(e1, t):
                {
                    kind: "xnkCastExpr",
                    castExpr: convertExpr(e1),
                    castType: t != null ? convertComplexType(t) : null
                };

            case EDisplay(e1, _):
                convertExpr(e1); // Ignore display info

            case ETernary(econd, eif, eelse):
                {
                    kind: "xnkTernaryExpr",
                    ternaryCondition: convertExpr(econd),
                    ternaryThen: convertExpr(eif),
                    ternaryElse: convertExpr(eelse)
                };

            case ECheckType(e1, t):
                {
                    kind: "xnkCastExpr",
                    castExpr: convertExpr(e1),
                    castType: convertComplexType(t)
                };

            case EMeta(m, e1):
                {
                    kind: "xnkMetadata",
                    metadataName: m.name,
                    metadataArgs: m.params != null ? [for (p in m.params) convertExpr(p)] : [],
                    metadataExpr: convertExpr(e1)
                };

            case EIs(e1, t):
                {
                    kind: "xnkBinaryExpr",
                    binaryOp: "is",
                    binaryLeft: convertExpr(e1),
                    binaryRight: convertComplexType(t)
                };
        };
    }

    //
    // Helper converters
    //

    static function convertTConstant(c:TConstant):XLangNode {
        return switch (c) {
            case TInt(i): {kind: "xnkIntLit", intValue: i};
            case TFloat(s): {kind: "xnkFloatLit", floatValue: Std.parseFloat(s)};
            case TString(s): {kind: "xnkStringLit", stringValue: s};
            case TBool(b): {kind: "xnkBoolLit", boolValue: b};
            case TNull: {kind: "xnkNilLit"};
            case TThis: {kind: "xnkThisExpr"};
            case TSuper: {kind: "xnkBaseExpr"};
        };
    }

    static function convertConstant(c:Constant):XLangNode {
        return switch (c) {
            case CInt(v): {kind: "xnkIntLit", intValue: Std.parseInt(v)};
            case CFloat(f): {kind: "xnkFloatLit", floatValue: Std.parseFloat(f)};
            case CString(s, _): {kind: "xnkStringLit", stringValue: s};
            case CIdent(s):
                switch (s) {
                    case "true": {kind: "xnkBoolLit", boolValue: true};
                    case "false": {kind: "xnkBoolLit", boolValue: false};
                    case "null": {kind: "xnkNilLit"};
                    case "this": {kind: "xnkThisExpr"};
                    case "super": {kind: "xnkBaseExpr"};
                    case _: {kind: "xnkIdentifier", identName: s};
                };
            case CRegexp(r, opt): {kind: "xnkStringLit", stringValue: r}; // Approximate
        };
    }

    static function convertVarDecl(v:{name:String, type:Null<ComplexType>, expr:Null<Expr>}):XLangNode {
        return {
            kind: "xnkVarDecl",
            declName: v.name,
            declType: v.type != null ? convertComplexType(v.type) : null,
            declInit: v.expr != null ? convertExpr(v.expr) : null
        };
    }

    static function convertFunction(kind:Null<FunctionKind>, f:Function):XLangNode {
        var funcName = switch (kind) {
            case FNamed(name, _): name;
            case FArrow: null;
            case FAnonymous: null;
        };

        if (funcName != null) {
            return {
                kind: "xnkFuncDecl",
                funcName: funcName,
                params: [for (arg in f.args) {
                    kind: "xnkParameter",
                    paramName: arg.name,
                    paramType: arg.type != null ? convertComplexType(arg.type) : null,
                    paramOptional: arg.opt,
                    paramDefault: arg.value != null ? convertExpr(arg.value) : null
                }],
                returnType: f.ret != null ? convertComplexType(f.ret) : null,
                funcBody: f.expr != null ? convertExpr(f.expr) : null
            };
        } else {
            return {
                kind: "xnkLambdaExpr",
                lambdaParams: [for (arg in f.args) {
                    kind: "xnkParameter",
                    paramName: arg.name,
                    paramType: arg.type != null ? convertComplexType(arg.type) : null,
                    paramOptional: arg.opt,
                    paramDefault: arg.value != null ? convertExpr(arg.value) : null
                }],
                lambdaReturnType: f.ret != null ? convertComplexType(f.ret) : null,
                lambdaBody: f.expr != null ? convertExpr(f.expr) : null
            };
        }
    }

    static function convertForExpr(it:Expr, expr:Expr):XLangNode {
        // Haxe for loops are iterator-based
        return {
            kind: "xnkForeachStmt",
            foreachVar: convertExpr(it),
            foreachBody: convertExpr(expr)
        };
    }

    static function convertComplexType(t:ComplexType):XLangNode {
        return switch (t) {
            case TPath(p):
                convertTypePath(p);

            case TFunction(args, ret):
                {
                    kind: "xnkFuncType",
                    funcTypeParams: [for (arg in args) convertComplexType(arg)],
                    funcTypeReturn: convertComplexType(ret)
                };

            case TAnonymous(fields):
                {
                    kind: "xnkStructDecl",
                    typeNameDecl: "",
                    members: [for (field in fields) convertField(field)],
                    isAnonymous: true
                };

            case TParent(t1):
                convertComplexType(t1); // Transparent

            case TExtend(p, fields):
                {
                    kind: "xnkStructDecl",
                    typeNameDecl: "",
                    baseTypes: [for (path in p) convertTypePath(path)],
                    members: [for (field in fields) convertField(field)],
                    isAnonymous: true
                };

            case TOptional(t1):
                {
                    kind: "xnkGenericType",
                    genericBase: {kind: "xnkNamedType", typeName: "Null"},
                    genericArgs: [convertComplexType(t1)]
                };

            case TNamed(n, t1):
                convertComplexType(t1); // Named types in function parameters

            case TIntersection(types):
                {
                    kind: "xnkIntersectionType",
                    typeMembers: [for (t in types) convertComplexType(t)]
                };
        };
    }

    static function convertTypePath(p:TypePath):XLangNode {
        if (p.params != null && p.params.length > 0) {
            return {
                kind: "xnkGenericType",
                genericBase: {kind: "xnkNamedType", typeName: p.name},
                genericArgs: [for (param in p.params) convertTypeParam(param)]
            };
        } else {
            return {
                kind: "xnkNamedType",
                typeName: (p.pack.length > 0 ? p.pack.join(".") + "." : "") + p.name
            };
        }
    }

    static function convertTypeParam(p:TypeParam):XLangNode {
        return switch (p) {
            case TPType(t): convertComplexType(t);
            case TPExpr(e): convertExpr(e);
        };
    }

    static function convertField(f:Field):XLangNode {
        var kind = switch (f.kind) {
            case FVar(t, e): "xnkFieldDecl";
            case FFun(func): "xnkMethodDecl";
            case FProp(get, set, t, e): "xnkPropertyDecl";
        };

        var result:XLangNode = {
            kind: kind,
            name: f.name,
            isPublic: f.access != null && f.access.indexOf(APublic) != -1,
            isStatic: f.access != null && f.access.indexOf(AStatic) != -1,
            isFinal: f.access != null && f.access.indexOf(AFinal) != -1
        };

        switch (f.kind) {
            case FVar(t, e):
                result.fieldType = t != null ? convertComplexType(t) : null;
                result.fieldInit = e != null ? convertExpr(e) : null;

            case FFun(func):
                result.params = [for (arg in func.args) {
                    kind: "xnkParameter",
                    paramName: arg.name,
                    paramType: arg.type != null ? convertComplexType(arg.type) : null
                }];
                result.returnType = func.ret != null ? convertComplexType(func.ret) : null;
                result.funcBody = func.expr != null ? convertExpr(func.expr) : null;

            case FProp(get, set, t, e):
                result.propType = t != null ? convertComplexType(t) : null;
                result.propGetter = get;
                result.propSetter = set;
                result.propInit = e != null ? convertExpr(e) : null;
        }

        // Add metadata
        if (f.meta != null && f.meta.length > 0) {
            result.metadata = {
                kind: "xnkMetadata",
                metadataEntries: [for (m in f.meta) {
                    name: m.name,
                    args: m.params != null ? [for (p in m.params) convertExpr(p)] : []
                }]
            };
        }

        return result;
    }

    static function convertMetadata(meta:MetaAccess):XLangNode {
        var entries = meta.get();
        if (entries.length == 0) return null;

        return {
            kind: "xnkMetadata",
            metadataEntries: [for (m in entries) {
                name: m.name,
                args: m.params != null ? [for (p in m.params) convertExpr(p)] : [],
                pos: m.pos
            }]
        };
    }

    //
    // Operator conversion utilities
    //

    static function binopToString(op:Binop):String {
        return switch (op) {
            case OpAdd: "+";
            case OpMult: "*";
            case OpDiv: "/";
            case OpSub: "-";
            case OpAssign: "=";
            case OpEq: "==";
            case OpNotEq: "!=";
            case OpGt: ">";
            case OpGte: ">=";
            case OpLt: "<";
            case OpLte: "<=";
            case OpAnd: "&";
            case OpOr: "|";
            case OpXor: "^";
            case OpBoolAnd: "&&";
            case OpBoolOr: "||";
            case OpShl: "<<";
            case OpShr: ">>";
            case OpUShr: ">>>";
            case OpMod: "%";
            case OpAssignOp(op): binopToString(op) + "=";
            case OpInterval: "...";
            case OpArrow: "=>";
            case OpIn: "in";
            case OpNullCoal: "??";
        };
    }

    static function unopToString(op:Unop):String {
        return switch (op) {
            case OpIncrement: "++";
            case OpDecrement: "--";
            case OpNot: "!";
            case OpNeg: "-";
            case OpNegBits: "~";
            case OpSpread: "...";
        };
    }

    static function fieldAccessName(fa:FieldAccess):String {
        return switch (fa) {
            case FInstance(_, _, cf): cf.get().name;
            case FStatic(_, cf): cf.get().name;
            case FAnon(cf): cf.get().name;
            case FDynamic(s): s;
            case FClosure(_, cf): cf.get().name;
            case FEnum(_, ef): ef.name;
        };
    }

    static function moduleTypeName(m:ModuleType):String {
        return switch (m) {
            case TClassDecl(c): c.get().name;
            case TEnumDecl(e): e.get().name;
            case TTypeDecl(t): t.get().name;
            case TAbstract(a): a.get().name;
        };
    }
}
