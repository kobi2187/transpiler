import haxe.macro.Expr;
import haxe.macro.Context;
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

    static function convertModule(module: haxe.macro.Type.ModuleType): XLangNode {
        return switch (module) {
            case TClassDecl(c):
                convertClassDecl(c.get());
            case TEnumDecl(e):
                convertEnumDecl(e.get());
            case TTypeDecl(t):
                convertTypeDecl(t.get());
            case TAbstract(a):
                convertAbstractDecl(a.get());
            case _:
                throw "Unsupported module type";
        }
    }

    static function convertClassDecl(c: haxe.macro.Type.ClassType): XLangNode {
        var fields = c.fields.get().map(convertClassField);
        var statics = c.statics.get().map(convertClassField);

        return {
            kind: "xnkClassDecl",
            className: c.name,
            isPrivate: c.isPrivate,
            isFinal: c.isFinal,
            isInterface: c.isInterface,
            superClass: c.superClass != null ? convertTypeRef(c.superClass.t) : null,
            interfaces: c.interfaces.map(i -> convertTypeRef(i.t)),
            typeParameters: c.params.map(convertTypeParameterDecl),
            fields: fields,
            statics: statics,
            constructor: c.constructor != null ? convertClassField(c.constructor.get()) : null,
            meta: convertMetadata(c.meta.get())
        };
    }

    static function convertClassField(f: haxe.macro.Type.ClassField): XLangNode {
        return {
            kind: f.isPublic ? "xnkPublicField" : "xnkPrivateField",
            name: f.name,
            type: convertComplexType(f.type),
            isStatic: f.isStatic,
            isFinal: f.isFinal,
            isOverride: f.overloads.length > 0,
            expr: f.expr != null ? convertExpr(f.expr()) : null,
            meta: convertMetadata(f.meta.get())
        };
    }

    static function convertEnumDecl(e: haxe.macro.Type.EnumType): XLangNode {
        return {
            kind: "xnkEnumDecl",
            name: e.name,
            isPrivate: e.isPrivate,
            constructors: e.constructs.map(convertEnumConstructor),
            typeParameters: e.params.map(convertTypeParameterDecl),
            meta: convertMetadata(e.meta.get())
        };
    }

    static function convertEnumConstructor(c: haxe.macro.Type.EnumField): XLangNode {
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

    static function convertTypeDecl(t: haxe.macro.Type.DefType): XLangNode {
        return {
            kind: "xnkTypeDecl",
            name: t.name,
            isPrivate: t.isPrivate,
            type: convertComplexType(t.type),
            typeParameters: t.params.map(convertTypeParameterDecl),
            meta: convertMetadata(t.meta.get())
        };
    }

    static function convertAbstractDecl(a: haxe.macro.Type.AbstractType): XLangNode {
        return {
            kind: "xnkAbstractDecl",
            name: a.name,
            isPrivate: a.isPrivate,
            type: convertComplexType(a.type),
            typeParameters: a.params.map(convertTypeParameterDecl),
            from: a.from.map(convertComplexType),
            to: a.to.map(convertComplexType),
            impl: a.impl != null ? convertClassDecl(a.impl.get()) : null,
            meta: convertMetadata(a.meta.get())
        };
    }

    static function convertExpr(e: TypedExpr): XLangNode {
        return switch (e.expr) {
            case TConst(c):
                convertConst(c);
            case TLocal(v):
                {kind: "xnkIdentifier", name: v.name};
            case TArray(e1, e2):
                {kind: "xnkArrayAccess", array: convertExpr(e1), index: convertExpr(e2)};
            case TBinop(op, e1, e2):
                {kind: "xnkBinaryExpr", op: Std.string(op), left: convertExpr(e1), right: convertExpr(e2)};
            case TField(e, fa):
                {kind: "xnkFieldAccess", expr: convertExpr(e), field: convertFieldAccess(fa)};
            case TTypeExpr(m):
                {kind: "xnkTypeExpr", module: convertModuleType(m)};
            case TParenthesis(e):
                {kind: "xnkParenthesis", expr: convertExpr(e)};
            case TObjectDecl(fields):
                {kind: "xnkObjectDecl", fields: fields.map(f -> ({name: f.name, expr: convertExpr(f.expr)}))};
            case TArrayDecl(el):
                {kind: "xnkArrayDecl", elements: el.map(convertExpr)};
            case TCall(e, el):
                {kind: "xnkCallExpr", expr: convertExpr(e), args: el.map(convertExpr)};
            case TNew(c, params, el):
                {kind: "xnkNewExpr", className: c.get().name, typeParams: params.map(convertTypeParameter), args: el.map(convertExpr)};
            case TUnop(op, postFix, e):
                {kind: "xnkUnaryExpr", op: Std.string(op), postFix: postFix, expr: convertExpr(e)};
            case TFunction(tf):
                {kind: "xnkFunctionExpr", args: tf.args.map(convertFunctionArg), expr: convertExpr(tf.expr), ret: convertComplexType(tf.t)};
            case TVar(v, expr):
                {kind: "xnkVarDecl", name: v.name, type: convertComplexType(v.t), expr: expr != null ? convertExpr(expr) : null};
            case TBlock(el):
                {kind: "xnkBlockExpr", exprs: el.map(convertExpr)};
            case TFor(v, e1, e2):
                {kind: "xnkForExpr", variable: v.name, expr: convertExpr(e1), body: convertExpr(e2)};
            case TIf(econd, eif, eelse):
                {kind: "xnkIfExpr", cond: convertExpr(econd), ifExpr: convertExpr(eif), elseExpr: eelse != null ? convertExpr(eelse) : null};
            case TWhile(econd, e, normalWhile):
                {kind: "xnkWhileExpr", cond: convertExpr(econd), body: convertExpr(e), doWhile: !normalWhile};
            case TSwitch(e, cases, edef):
                {
                    kind: "xnkSwitchExpr",
                    expr: convertExpr(e),
                    cases: cases.map(c -> ({values: c.values.map(convertExpr), expr: convertExpr(c.expr)})),
                    defaultExpr: edef != null ? convertExpr(edef) : null
                };
            case TTry(e, catches):
                {
                    kind: "xnkTryExpr",
                    expr: convertExpr(e),
                    catches: catches.map(c -> ({name: c.name, type: convertComplexType(c.type), expr: convertExpr(c.expr)}))
                };
            case TReturn(e):
                {kind: "xnkReturnExpr", expr: e != null ? convertExpr(e) : null};
            case TBreak:
                {kind: "xnkBreakExpr"};
            case TContinue:
                {kind: "xnkContinueExpr"};
            case TThrow(e):
                {kind: "xnkThrowExpr", expr: convertExpr(e)};
            case TCast(e, m):
                {kind: "xnkCastExpr", expr: convertExpr(e), type: m != null ? convertModuleType(m) : null};
            case TMeta(m, e):
                {kind: "xnkMetaExpr", meta: convertMetadata([m]), expr: convertExpr(e)};
            case TEnumParameter(e, ef, index):
                {kind: "xnkEnumParameterExpr", expr: convertExpr(e), field: ef.name, index: index};
            case TEnumIndex(e):
                {kind: "xnkEnumIndexExpr", expr: convertExpr(e)};
            case TIdent(s):
                {kind: "xnkIdentifier", name: s};
        }
    }

    static function convertConst(c: TConstant): XLangNode {
        return switch (c) {
            case TInt(i): {kind: "xnkIntLit", value: i};
            case TFloat(s): {kind: "xnkFloatLit", value: Std.parseFloat(s)};
            case TString(s): {kind: "xnkStringLit", value: s};
            case TBool(b): {kind: "xnkBoolLit", value: b};
            case TNull: {kind: "xnkNullLit"};
            case TThis: {kind: "xnkThisLit"};
            case TSuper: {kind: "xnkSuperLit"};
        }
    }

    static function convertFieldAccess(fa: FieldAccess): XLangNode {
        return switch (fa) {
            case FInstance(_, _, cf): {kind: "xnkInstanceField", name: cf.get().name};
            case FStatic(_, cf): {kind: "xnkStaticField", name: cf.get().name};
            case FAnon(cf): {kind: "xnkAnonField", name: cf.get().name};
            case FDynamic(s): {kind: "xnkDynamicField", name: s};
            case FClosure(_, cf): {kind: "xnkClosureField", name: cf.get().name};
            case FEnum(_, ef): {kind: "xnkEnumField", name: ef.name};
        }
    }

    static function convertComplexType(t: haxe.macro.Type): XLangNode {
        return switch (t) {
            case TMono(_): {kind: "xnkMonoType"};
            case TEnum(_, params): {kind: "xnkEnumType", name: _.get().name, params: params.map(convertComplexType)};
            case TInst(_, params): {kind: "xnkClassType", name: _.get().name, params: params.map(convertComplexType)};
            case TType(_, params): {kind: "xnkTypedefType", name: _.get().name, params: params.map(convertComplexType)};
            case TFun(args, ret): {kind: "xnkFunctionType", args: args.map(a -> ({name: a.name, type: convertComplexType(a.t)})), ret: convertComplexType(ret)};
            case TAnonymous(a): {kind: "xnkAnonymousType", fields: a.get().fields.map(convertClassField)};
            case TDynamic(t): {kind: "xnkDynamicType", type: t != null ? convertComplexType(t) : null};
            case TLazy(f): convertComplexType(f());
            case TAbstract(_, params): {kind: "xnkAbstractType", name: _.get().name, params: params.map(convertComplexType)};
        }
    }

    static function convertTypeParameterDecl(p: haxe.macro.Type.TypeParameter): XLangNode {
        return {
            kind: "xnkTypeParameter",
            name: p.name,
            constraints: p.constraints.map(convertComplexType)
        };
    }

    static function convertModuleType(m: ModuleType): XLangNode {
        return switch (m) {
            case TClassDecl(c): {kind: "xnkClassTypeExpr", name: c.get().name};
            case TEnumDecl(e): {kind: "xnkEnumTypeExpr", name: e.get().name};
            case TTypeDecl(t): {kind: "xnkTypedefTypeExpr", name: t.get().name};
            case TAbstract(a): {kind: "xnkAbstractTypeExpr", name: a.get().name};
        }
    }

    static function convertMetadata(meta: haxe.macro.Metadata): XLangNode {
        return {
            kind: "xnkMetadata",
            entries: meta.map(m -> ({name: m.name, params: m.params.map(convertExpr)}))
        };
    }

    static function convertFunctionArg(arg: {name:String, opt:Bool, type:Null<haxe.macro.Type>}): XLangNode {
        return {
            kind: "xnkFunctionArg",
            name: arg.name,
            type: arg.type != null ? convertComplexType(arg.type) : null,
            optional: arg.opt
        };
    }
}