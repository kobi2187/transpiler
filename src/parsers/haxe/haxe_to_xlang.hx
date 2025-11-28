import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import sys.io.File;
import haxe.Json;

class HaxeToXLangParser {
    static function main() {
        var args = Sys.args();
        if (args.length != 1) {
            Sys.println("Usage: haxe --run HaxeToXLangParser <haxe_file>");
            return;
        }

        var filePath = args[0];
        var content = File.getContent(filePath);

        Context.onAfterTyping(function(modules) {
            for (module in modules) {
                if (module.file == filePath) {
                    var xlangAst = convertModule(module);
                    var jsonOutput = Json.stringify(xlangAst, null, "  ");
                    File.saveContent(filePath + ".xlang.json", jsonOutput);
                    break;
                }
            }
        });

        Context.parse(content, Context.makePosition({min: 0, max: content.length, file: filePath}));
    }

    static function convertModule(module: ModuleType): Dynamic {
        return switch (module) {
            case TClassDecl(c):
                convertClassDecl(c.get());
            case TEnumDecl(e):
                convertEnumDecl(e.get());
            case TTypeDecl(t):
                convertTypeDecl(t.get());
            case TAbstract(a):
                convertAbstractDecl(a.get());
        }
    }

    static function convertClassDecl(c: ClassType): Dynamic {
        var fields = c.fields.get().map(convertClassField);
        var statics = c.statics.get().map(convertClassField);

        return {
            kind: c.isInterface ? "xnkInterfaceDecl" : "xnkClassDecl",
            className: c.name,
            isPrivate: c.isPrivate,
            isFinal: c.isFinal,
            superClass: c.superClass != null ? convertTypeRef(c.superClass.t) : null,
            interfaces: c.interfaces.map(i -> convertTypeRef(i.t)),
            typeParameters: c.params.map(convertTypeParameterDecl),
            fields: fields,
            statics: statics,
            constructor: c.constructor != null ? convertClassField(c.constructor.get()) : null,
            meta: convertMetadata(c.meta.get())
        };
    }

    static function convertClassField(f: ClassField): Dynamic {
        return {
            kind: f.kind == FMethod(MethDynamic) ? "xnkMethodDecl" : "xnkFieldDecl",
            name: f.name,
            type: convertComplexType(f.type),
            isStatic: f.isStatic,
            isFinal: f.isFinal,
            isOverride: f.overloads.length > 0,
            expr: f.expr != null ? convertExpr(f.expr()) : null,
            meta: convertMetadata(f.meta.get())
        };
    }

    static function convertEnumDecl(e: EnumType): Dynamic {
        return {
            kind: "xnkEnumDecl",
            name: e.name,
            isPrivate: e.isPrivate,
            constructors: e.constructs.map(convertEnumConstructor),
            typeParameters: e.params.map(convertTypeParameterDecl),
            meta: convertMetadata(e.meta.get())
        };
    }

    static function convertEnumConstructor(c: EnumField): Dynamic {
        return {
            kind: "xnkEnumConstructor",
            name: c.name,
            args: switch (c.type) {
                case TFun(args, _): args.map(a -> ({name: a.name, type: convertComplexType(a.t)}));
                case _: [];
            },
            meta: convertMetadata(c.meta.get())
        };
    }

    static function convertTypeDecl(t: DefType): Dynamic {
        return {
            kind: "xnkTypeDecl",
            name: t.name,
            isPrivate: t.isPrivate,
            type: convertComplexType(t.type),
            typeParameters: t.params.map(convertTypeParameterDecl),
            meta: convertMetadata(t.meta.get())
        };
    }

    static function convertAbstractDecl(a: AbstractType): Dynamic {
        return {
            kind: "xnkAbstractDecl",
            name: a.name,
            isPrivate: a.isPrivate,
            type: convertComplexType(a.type),
            typeParameters: a.params.map(convertTypeParameterDecl),
            fromTypes: a.from.map(convertComplexType),
            toTypes: a.to.map(convertComplexType),
            impl: a.impl != null ? convertClassDecl(a.impl.get()) : null,
            meta: convertMetadata(a.meta.get())
        };
    }

    static function convertExpr(e: TypedExpr): Dynamic {
        return switch (e.expr) {
            case TConst(c):
                convertConst(c);
            case TLocal(v):
                {kind: "xnkIdentifier", name: v.name};
            case TArray(e1, e2):
                {kind: "xnkIndexExpr", expr: convertExpr(e1), index: convertExpr(e2)};
            case TBinop(op, e1, e2):
                {kind: "xnkBinaryExpr", op: Std.string(op), left: convertExpr(e1), right: convertExpr(e2)};
            case TField(e, fa):
                {kind: "xnkMemberAccessExpr", expr: convertExpr(e), field: convertFieldAccess(fa)};
            case TTypeExpr(m):
                {kind: "xnkNamedType", name: convertModuleType(m)};
            case TParenthesis(e):
                convertExpr(e);
            case TObjectDecl(fields):
                {kind: "xnkDictExpr", entries: fields.map(f -> ({key: f.name, value: convertExpr(f.expr)}))};
            case TArrayDecl(el):
                {kind: "xnkListExpr", elements: el.map(convertExpr)};
            case TCall(e, el):
                {kind: "xnkCallExpr", expr: convertExpr(e), args: el.map(convertExpr)};
            case TNew(c, params, el):
                {kind: "xnkCallExpr", expr: {kind: "xnkNamedType", name: c.get().name}, args: el.map(convertExpr)};
            case TUnop(op, postFix, e):
                {kind: "xnkUnaryExpr", op: Std.string(op), postFix: postFix, expr: convertExpr(e)};
            case TFunction(tf):
                {kind: "xnkLambdaExpr", args: tf.args.map(convertFunctionArg), expr: convertExpr(tf.expr), ret: convertComplexType(tf.t)};
            case TVar(v, expr):
                {kind: "xnkVarDecl", name: v.name, type: convertComplexType(v.t), expr: expr != null ? convertExpr(expr) : null};
            case TBlock(el):
                {kind: "xnkBlockStmt", statements: el.map(convertExpr)};
            case TFor(v, e1, e2):
                {kind: "xnkForStmt", variable: {kind: "xnkIdentifier", name: v.name}, expr: convertExpr(e1), body: convertExpr(e2)};
            case TIf(econd, eif, eelse):
                {kind: "xnkIfStmt", condition: convertExpr(econd), thenBranch: convertExpr(eif), elseBranch: eelse != null ? convertExpr(eelse) : null};
            case TWhile(econd, e, normalWhile):
                {kind: normalWhile ? "xnkWhileStmt" : "xnkDoWhileStmt", condition: convertExpr(econd), body: convertExpr(e)};
            case TSwitch(e, cases, edef):
                {
                    kind: "xnkSwitchStmt",
                    expr: convertExpr(e),
                    cases: cases.map(c -> ({patterns: c.values.map(convertExpr), body: convertExpr(c.expr)})),
                    defaultBody: edef != null ? convertExpr(edef) : null
                };
            case TTry(e, catches):
                {
                    kind: "xnkTryStmt",
                    body: convertExpr(e),
                    catches: catches.map(c -> ({
                        kind: "xnkCatchStmt",
                        type: convertComplexType(c.type),
                        name: c.name,
                        body: convertExpr(c.expr)
                    }))
                };
            case TReturn(e):
                {kind: "xnkReturnStmt", expr: e != null ? convertExpr(e) : null};
            case TBreak:
                {kind: "xnkBreakStmt"};
            case TContinue:
                {kind: "xnkContinueStmt"};
            case TThrow(e):
                {kind: "xnkThrowStmt", expr: convertExpr(e)};
            case TCast(e, m):
                {kind: "xnkTypeCheck", expr: convertExpr(e), type: m != null ? convertModuleType(m) : null};
            case TMeta(m, e):
                {kind: "xnkMetadata", name: m.name, args: m.params.map(convertExpr), expr: convertExpr(e)};
            case TEnumParameter(e, ef, index):
                {kind: "xnkEnumParameterExpr", expr: convertExpr(e), field: ef.name, index: index};
            case TEnumIndex(e):
                {kind: "xnkEnumIndexExpr", expr: convertExpr(e)};
            case TIdent(s):
                {kind: "xnkIdentifier", name: s};
        }
    }

    static function convertConst(c: TConstant): Dynamic {
        return switch (c) {
            case TInt(i): {kind: "xnkIntLit", value: i};
            case TFloat(s): {kind: "xnkFloatLit", value: Std.parseFloat(s)};
            case TString(s): {kind: "xnkStringLit", value: s};
            case TBool(b): {kind: "xnkBoolLit", value: b};
            case TNull: {kind: "xnkNoneLit"};
            case TThis: {kind: "xnkThisExpr"};
            case TSuper: {kind: "xnkSuperExpr"};
        }
    }

    static function convertFieldAccess(fa: FieldAccess): Dynamic {
        return {kind: "xnkIdentifier", name: switch (fa) {
            case FInstance(_, _, cf): cf.get().name;
            case FStatic(_, cf): cf.get().name;
            case FAnon(cf): cf.get().name;
            case FDynamic(s): s;
            case FClosure(_, cf): cf.get().name;
            case FEnum(_, ef): ef.name;
        }};
    }

    static function convertComplexType(t: Type): Dynamic {
        return switch (t) {
            case TMono(_): {kind: "xnkNamedType", name: "Any"};
            case TEnum(_, params): {kind: "xnkGenericType", name: _.get().name, typeArgs: params.map(convertComplexType)};
            case TInst(_, params): {kind: "xnkGenericType", name: _.get().name, typeArgs: params.map(convertComplexType)};
            case TType(_, params): {kind: "xnkGenericType", name: _.get().name, typeArgs: params.map(convertComplexType)};
            case TFun(args, ret): {kind: "xnkFuncType", args: args.map(a -> ({name: a.name, type: convertComplexType(a.t)})), returnType: convertComplexType(ret)};
            case TAnonymous(a): {kind: "xnkStructDecl", fields: a.get().fields.map(convertClassField)};
            case TDynamic(t): {kind: "xnkDynamicType", type: t != null ? convertComplexType(t) : null};
            case TLazy(f): convertComplexType(f());
            case TAbstract(_, params): {kind: "xnkAbstractType", name: _.get().name, typeArgs: params.map(convertComplexType)};
        }
    }

    static function convertTypeParameterDecl(p: TypeParameter): Dynamic {
        return {
            kind: "xnkGenericParameter",
            name: p.name,
            constraints: p.constraints.map(convertComplexType)
        };
    }

    static function convertModuleType(m: ModuleType): String {
        return switch (m) {
            case TClassDecl(c): c.get().name;
            case TEnumDecl(e): e.get().name;
            case TTypeDecl(t): t.get().name;
            case TAbstract(a): a.get().name;
        };
    }

    static function convertTypeRef(t: Ref<ClassType>): Dynamic {
        return {
            kind: "xnkNamedType",
            name: t.get().name
        };
    }

    static function convertMetadata(meta: MetaAccess): Dynamic {
        return {
            kind: "xnkMetadata",
            entries: meta.get().map(m -> ({name: m.name, args: m.params != null ? m.params.map(convertExpr) : []}))
        };
    }

    static function convertFunctionArg(arg: {name:String, opt:Bool, t:Type}): Dynamic {
        return {
            kind: "xnkParameter",
            name: arg.name,
            type: convertComplexType(arg.t),
            defaultValue: arg.opt ? {kind: "xnkNoneLit"} : null
        };
    }
}