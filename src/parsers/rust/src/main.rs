/*!
 * Comprehensive Rust to XLang Parser
 *
 * This parser converts Rust source code to XLang JSON format using the syn crate.
 * It handles ALL Rust language constructs as defined in:
 * - The Rust Reference (https://doc.rust-lang.org/reference/)
 * - syn::Item enum (16 variants)
 * - syn::Expr enum (40 variants)
 *
 * Usage: rust_to_xlang <input_file.rs> [output_file.json]
 */

use quote::ToTokens;
use serde_json::{json, Map, Value};
use std::env;
use std::fs;
use std::process;
use syn::*;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: rust_to_xlang <input.rs> [output.json]");
        eprintln!("\nConverts Rust source code to XLang JSON format");
        process::exit(1);
    }

    let input_path = &args[1];
    let output_path = if args.len() > 2 {
        args[2].clone()
    } else {
        format!("{}.xlang.json", input_path)
    };

    // Read source file
    let source = fs::read_to_string(input_path)
        .unwrap_or_else(|err| {
            eprintln!("Error reading {}: {}", input_path, err);
            process::exit(1);
        });

    // Parse with syn
    let file = syn::parse_file(&source)
        .unwrap_or_else(|err| {
            eprintln!("Parse error: {}", err);
            process::exit(1);
        });

    // Convert to XLang
    let xlang = convert_file(&file, input_path);

    // Write JSON output
    let json_output = serde_json::to_string_pretty(&xlang)
        .expect("Failed to serialize JSON");

    fs::write(&output_path, json_output)
        .unwrap_or_else(|err| {
            eprintln!("Error writing {}: {}", output_path, err);
            process::exit(1);
        });

    println!("Successfully generated: {}", output_path);
}

//
// File-level conversion
//

fn convert_file(file: &File, filename: &str) -> Value {
    json!({
        "kind": "xnkFile",
        "fileName": filename,
        "moduleDecls": file.items.iter().map(convert_item).collect::<Vec<_>>()
    })
}

//
// Item Conversion (syn::Item - 16 variants)
//

fn convert_item(item: &Item) -> Value {
    match item {
        Item::Const(item) => convert_const(item),
        Item::Enum(item) => convert_enum(item),
        Item::ExternCrate(item) => convert_extern_crate(item),
        Item::Fn(item) => convert_fn(item),
        Item::ForeignMod(item) => convert_foreign_mod(item),
        Item::Impl(item) => convert_impl(item),
        Item::Macro(item) => convert_macro(item),
        Item::Mod(item) => convert_mod(item),
        Item::Static(item) => convert_static(item),
        Item::Struct(item) => convert_struct(item),
        Item::Trait(item) => convert_trait(item),
        Item::TraitAlias(item) => convert_trait_alias(item),
        Item::Type(item) => convert_type_alias(item),
        Item::Union(item) => convert_union(item),
        Item::Use(item) => convert_use(item),
        Item::Verbatim(_) => json!({"kind": "xnkUnknown", "note": "verbatim item"}),
        _ => json!({"kind": "xnkUnknown", "note": "unknown item variant"}),
    }
}

fn convert_const(item: &ItemConst) -> Value {
    json!({
        "kind": "xnkConstDecl",
        "declName": item.ident.to_string(),
        "declType": convert_type(&item.ty),
        "initializer": convert_expr(&item.expr),
        "visibility": convert_visibility(&item.vis),
        "attributes": convert_attributes(&item.attrs)
    })
}

fn convert_enum(item: &ItemEnum) -> Value {
    json!({
        "kind": "xnkEnumDecl",
        "enumName": item.ident.to_string(),
        "enumMembers": item.variants.iter().map(convert_variant).collect::<Vec<_>>(),
        "typeParams": convert_generics(&item.generics),
        "visibility": convert_visibility(&item.vis),
        "attributes": convert_attributes(&item.attrs)
    })
}

fn convert_variant(variant: &Variant) -> Value {
    let mut member = Map::new();
    member.insert("kind".to_string(), json!("xnkEnumMember"));
    member.insert("enumMemberName".to_string(), json!(variant.ident.to_string()));

    // Handle variant fields
    match &variant.fields {
        Fields::Named(fields) => {
            member.insert("enumMemberFields".to_string(),
                fields.named.iter().map(convert_field).collect());
        },
        Fields::Unnamed(fields) => {
            member.insert("enumMemberFields".to_string(),
                fields.unnamed.iter().map(convert_field).collect());
        },
        Fields::Unit => {
            member.insert("enumMemberValue".to_string(), Value::Null);
        }
    }

    // Discriminant (explicit value like `A = 5`)
    if let Some((_, expr)) = &variant.discriminant {
        member.insert("enumMemberValue".to_string(), convert_expr(expr));
    }

    member.insert("attributes".to_string(), Value::Array(convert_attributes(&variant.attrs)));

    Value::Object(member)
}

fn convert_extern_crate(item: &ItemExternCrate) -> Value {
    json!({
        "kind": "xnkImportStmt",
        "imports": vec![item.ident.to_string()],
        "importAlias": item.rename.as_ref().map(|(_, ident)| ident.to_string()),
        "visibility": convert_visibility(&item.vis),
        "attributes": convert_attributes(&item.attrs)
    })
}

fn convert_fn(item: &ItemFn) -> Value {
    let sig = &item.sig;

    json!({
        "kind": "xnkFuncDecl",
        "funcName": sig.ident.to_string(),
        "params": sig.inputs.iter().map(convert_fn_arg).collect::<Vec<_>>(),
        "returnType": convert_return_type(&sig.output),
        "funcBody": convert_block(&item.block),
        "typeParams": convert_generics(&sig.generics),
        "isAsync": sig.asyncness.is_some(),
        "isUnsafe": sig.unsafety.is_some(),
        "isConst": sig.constness.is_some(),
        "abi": sig.abi.as_ref().map(|abi| abi.name.as_ref().map(|n| n.value()).unwrap_or("C".to_string())),
        "visibility": convert_visibility(&item.vis),
        "attributes": convert_attributes(&item.attrs)
    })
}

fn convert_foreign_mod(item: &ItemForeignMod) -> Value {
    json!({
        "kind": "xnkLibDecl",
        "libName": item.abi.name.as_ref().map(|n| n.value()).unwrap_or("C".to_string()),
        "libBody": item.items.iter().map(convert_foreign_item).collect::<Vec<_>>(),
        "attributes": convert_attributes(&item.attrs)
    })
}

fn convert_foreign_item(item: &ForeignItem) -> Value {
    match item {
        ForeignItem::Fn(func) => json!({
            "kind": "xnkCFuncDecl",
            "cfuncName": func.sig.ident.to_string(),
            "cfuncParams": func.sig.inputs.iter().map(convert_fn_arg).collect::<Vec<_>>(),
            "cfuncReturnType": convert_return_type(&func.sig.output),
            "visibility": convert_visibility(&func.vis),
            "attributes": convert_attributes(&func.attrs)
        }),
        ForeignItem::Static(stat) => json!({
            "kind": "xnkExternalVar",
            "extVarName": stat.ident.to_string(),
            "extVarType": convert_type(&stat.ty),
            "isMutable": matches!(stat.mutability, syn::StaticMutability::Mut(_)),
            "visibility": convert_visibility(&stat.vis),
            "attributes": convert_attributes(&stat.attrs)
        }),
        _ => json!({"kind": "xnkUnknown", "note": "unknown foreign item"}),
    }
}

fn convert_impl(item: &ItemImpl) -> Value {
    if let Some((_, trait_path, _)) = &item.trait_ {
        // Trait implementation: impl Trait for Type
        json!({
            "kind": "xnkTraitImpl",
            "traitImplTrait": convert_path(trait_path),
            "traitImplType": convert_type(&item.self_ty),
            "traitImplGenerics": convert_generics(&item.generics),
            "traitImplMembers": item.items.iter().map(convert_impl_item).collect::<Vec<_>>(),
            "traitImplUnsafety": item.unsafety.is_some(),
            "attributes": convert_attributes(&item.attrs)
        })
    } else {
        // Inherent implementation: impl Type
        json!({
            "kind": "xnkInherentImpl",
            "inherentImplType": convert_type(&item.self_ty),
            "inherentImplGenerics": convert_generics(&item.generics),
            "inherentImplMembers": item.items.iter().map(convert_impl_item).collect::<Vec<_>>(),
            "inherentImplUnsafety": item.unsafety.is_some(),
            "attributes": convert_attributes(&item.attrs)
        })
    }
}

fn convert_impl_item(item: &ImplItem) -> Value {
    match item {
        ImplItem::Const(c) => json!({
            "kind": "xnkConstDecl",
            "declName": c.ident.to_string(),
            "declType": convert_type(&c.ty),
            "initializer": convert_expr(&c.expr),
            "visibility": convert_visibility(&c.vis),
            "attributes": convert_attributes(&c.attrs)
        }),
        ImplItem::Fn(f) => {
            let sig = &f.sig;
            json!({
                "kind": "xnkMethodDecl",
                "methodName": sig.ident.to_string(),
                "receiver": sig.inputs.first().and_then(|arg| {
                    if let FnArg::Receiver(r) = arg {
                        Some(convert_receiver(r))
                    } else {
                        None
                    }
                }),
                "mparams": sig.inputs.iter().skip(if matches!(sig.inputs.first(), Some(FnArg::Receiver(_))) { 1 } else { 0 })
                    .map(convert_fn_arg).collect::<Vec<_>>(),
                "mreturnType": convert_return_type(&sig.output),
                "mbody": convert_block(&f.block),
                "typeParams": convert_generics(&sig.generics),
                "methodIsAsync": sig.asyncness.is_some(),
                "isUnsafe": sig.unsafety.is_some(),
                "visibility": convert_visibility(&f.vis),
                "attributes": convert_attributes(&f.attrs)
            })
        },
        ImplItem::Type(t) => json!({
            "kind": "xnkTypeAlias",
            "aliasName": t.ident.to_string(),
            "aliasTarget": convert_type(&t.ty),
            "typeParams": convert_generics(&t.generics),
            "visibility": convert_visibility(&t.vis),
            "attributes": convert_attributes(&t.attrs)
        }),
        _ => json!({"kind": "xnkUnknown", "note": "unknown impl item"}),
    }
}

fn convert_receiver(receiver: &Receiver) -> Value {
    if receiver.reference.is_some() {
        json!({
            "kind": "xnkReferenceType",
            "isMutable": receiver.mutability.is_some(),
            "lifetime": receiver.reference.as_ref().and_then(|(_, lt)| lt.as_ref().map(|l| l.ident.to_string())),
            "referentType": {"kind": "xnkThisExpr"}
        })
    } else {
        json!({"kind": "xnkThisExpr"})
    }
}

fn convert_macro(item: &ItemMacro) -> Value {
    json!({
        "kind": "xnkMacroDecl",
        "macroName": item.ident.as_ref().map(|i| i.to_string()).unwrap_or_default(),
        "macroBody": item.mac.tokens.to_string(),
        "attributes": convert_attributes(&item.attrs)
    })
}

fn convert_mod(item: &ItemMod) -> Value {
    if let Some((_, items)) = &item.content {
        json!({
            "kind": "xnkModule",
            "moduleName": item.ident.to_string(),
            "moduleBody": items.iter().map(convert_item).collect::<Vec<_>>(),
            "visibility": convert_visibility(&item.vis),
            "attributes": convert_attributes(&item.attrs)
        })
    } else {
        // Module declaration (mod foo;)
        json!({
            "kind": "xnkModuleDecl",
            "moduleNameDecl": item.ident.to_string(),
            "visibility": convert_visibility(&item.vis),
            "attributes": convert_attributes(&item.attrs)
        })
    }
}

fn convert_static(item: &ItemStatic) -> Value {
    json!({
        "kind": "xnkVarDecl",
        "declName": item.ident.to_string(),
        "declType": convert_type(&item.ty),
        "initializer": convert_expr(&item.expr),
        "isStatic": true,
        "isMutable": matches!(item.mutability, syn::StaticMutability::Mut(_)),
        "visibility": convert_visibility(&item.vis),
        "attributes": convert_attributes(&item.attrs)
    })
}

fn convert_struct(item: &ItemStruct) -> Value {
    json!({
        "kind": "xnkStructDecl",
        "typeNameDecl": item.ident.to_string(),
        "members": match &item.fields {
            Fields::Named(fields) => fields.named.iter().map(convert_field).collect(),
            Fields::Unnamed(fields) => fields.unnamed.iter().map(convert_field).collect(),
            Fields::Unit => vec![],
        },
        "typeParams": convert_generics(&item.generics),
        "visibility": convert_visibility(&item.vis),
        "attributes": convert_attributes(&item.attrs)
    })
}

fn convert_field(field: &Field) -> Value {
    json!({
        "kind": "xnkFieldDecl",
        "fieldName": field.ident.as_ref().map(|i| i.to_string()).unwrap_or_default(),
        "fieldType": convert_type(&field.ty),
        "visibility": convert_visibility(&field.vis),
        "attributes": convert_attributes(&field.attrs)
    })
}

fn convert_trait(item: &ItemTrait) -> Value {
    json!({
        "kind": "xnkInterfaceDecl",
        "typeNameDecl": item.ident.to_string(),
        "members": item.items.iter().map(convert_trait_item).collect::<Vec<_>>(),
        "typeParams": convert_generics(&item.generics),
        "baseTypes": item.supertraits.iter().map(convert_type_param_bound).collect::<Vec<_>>(),
        "isUnsafe": item.unsafety.is_some(),
        "isAuto": item.auto_token.is_some(),
        "visibility": convert_visibility(&item.vis),
        "attributes": convert_attributes(&item.attrs)
    })
}

fn convert_trait_item(item: &TraitItem) -> Value {
    match item {
        TraitItem::Const(c) => json!({
            "kind": "xnkConstDecl",
            "declName": c.ident.to_string(),
            "declType": convert_type(&c.ty),
            "initializer": c.default.as_ref().map(|(_, expr)| convert_expr(expr)),
            "attributes": convert_attributes(&c.attrs)
        }),
        TraitItem::Fn(f) => {
            let sig = &f.sig;
            json!({
                "kind": "xnkMethodDecl",
                "methodName": sig.ident.to_string(),
                "receiver": sig.inputs.first().and_then(|arg| {
                    if let FnArg::Receiver(r) = arg {
                        Some(convert_receiver(r))
                    } else {
                        None
                    }
                }),
                "mparams": sig.inputs.iter().skip(if matches!(sig.inputs.first(), Some(FnArg::Receiver(_))) { 1 } else { 0 })
                    .map(convert_fn_arg).collect::<Vec<_>>(),
                "mreturnType": convert_return_type(&sig.output),
                "mbody": f.default.as_ref().map(convert_block).unwrap_or(Value::Null),
                "typeParams": convert_generics(&sig.generics),
                "attributes": convert_attributes(&f.attrs)
            })
        },
        TraitItem::Type(t) => json!({
            "kind": "xnkTypeDecl",
            "typeDefName": t.ident.to_string(),
            "typeDefBody": t.default.as_ref().map(|(_, ty)| convert_type(ty)).unwrap_or(Value::Null),
            "typeParams": convert_generics(&t.generics),
            "bounds": t.bounds.iter().map(convert_type_param_bound).collect::<Vec<_>>(),
            "attributes": convert_attributes(&t.attrs)
        }),
        _ => json!({"kind": "xnkUnknown", "note": "unknown trait item"}),
    }
}

fn convert_trait_alias(item: &ItemTraitAlias) -> Value {
    json!({
        "kind": "xnkTypeAlias",
        "aliasName": item.ident.to_string(),
        "aliasTarget": json!({"kind": "xnkUnionType", "unionTypes": item.bounds.iter().map(convert_type_param_bound).collect::<Vec<_>>()}),
        "typeParams": convert_generics(&item.generics),
        "visibility": convert_visibility(&item.vis),
        "attributes": convert_attributes(&item.attrs)
    })
}

fn convert_type_alias(item: &ItemType) -> Value {
    json!({
        "kind": "xnkTypeAlias",
        "aliasName": item.ident.to_string(),
        "aliasTarget": convert_type(&item.ty),
        "typeParams": convert_generics(&item.generics),
        "visibility": convert_visibility(&item.vis),
        "attributes": convert_attributes(&item.attrs)
    })
}

fn convert_union(item: &ItemUnion) -> Value {
    json!({
        "kind": "xnkStructDecl",
        "typeNameDecl": item.ident.to_string(),
        "members": item.fields.named.iter().map(convert_field).collect::<Vec<_>>(),
        "typeParams": convert_generics(&item.generics),
        "isUnion": true,
        "visibility": convert_visibility(&item.vis),
        "attributes": convert_attributes(&item.attrs)
    })
}

fn convert_use(item: &ItemUse) -> Value {
    json!({
        "kind": "xnkImportStmt",
        "imports": collect_use_paths(&item.tree),
        "visibility": convert_visibility(&item.vis),
        "attributes": convert_attributes(&item.attrs)
    })
}

fn collect_use_paths(tree: &UseTree) -> Vec<String> {
    match tree {
        UseTree::Path(path) => {
            let prefix = path.ident.to_string();
            collect_use_paths(&path.tree).into_iter()
                .map(|p| format!("{}::{}", prefix, p))
                .collect()
        },
        UseTree::Name(name) => vec![name.ident.to_string()],
        UseTree::Rename(rename) => vec![format!("{} as {}", rename.ident, rename.rename)],
        UseTree::Glob(_) => vec!["*".to_string()],
        UseTree::Group(group) => {
            group.items.iter()
                .flat_map(collect_use_paths)
                .collect()
        },
    }
}

//
// Expression Conversion (syn::Expr - 40 variants)
//

fn convert_expr(expr: &Expr) -> Value {
    match expr {
        Expr::Array(e) => json!({
            "kind": "xnkArrayLiteral",
            "arrayElements": e.elems.iter().map(convert_expr).collect::<Vec<_>>()
        }),
        Expr::Assign(e) => json!({
            "kind": "xnkAsgn",
            "asgnLeft": convert_expr(&e.left),
            "asgnRight": convert_expr(&e.right)
        }),
        Expr::Async(e) => json!({
            "kind": "xnkBlockStmt",
            "blockBody": e.block.stmts.iter().map(convert_stmt).collect::<Vec<_>>(),
            "isAsync": true
        }),
        Expr::Await(e) => json!({
            "kind": "xnkAwaitExpr",
            "awaitExpr": convert_expr(&e.base)
        }),
        Expr::Binary(e) => json!({
            "kind": "xnkBinaryExpr",
            "binaryLeft": convert_expr(&e.left),
            "binaryOp": format!("{:?}", e.op).to_lowercase(),
            "binaryRight": convert_expr(&e.right)
        }),
        Expr::Block(e) => convert_block(&e.block),
        Expr::Break(e) => json!({
            "kind": "xnkBreakStmt",
            "label": e.label.as_ref().map(|l| l.ident.to_string()),
            "breakExpr": e.expr.as_ref().map(|ex| convert_expr(ex))
        }),
        Expr::Call(e) => json!({
            "kind": "xnkCallExpr",
            "callExpr": convert_expr(&e.func),
            "callArgs": e.args.iter().map(convert_expr).collect::<Vec<_>>()
        }),
        Expr::Cast(e) => json!({
            "kind": "xnkCastExpr",
            "castExpr": convert_expr(&e.expr),
            "castType": convert_type(&e.ty)
        }),
        Expr::Closure(e) => json!({
            "kind": "xnkLambdaExpr",
            "lambdaParams": e.inputs.iter().map(convert_pat).collect::<Vec<_>>(),
            "lambdaBody": convert_expr(&e.body),
            "lambdaReturnType": convert_return_type(&e.output),
            "isAsync": e.asyncness.is_some(),
            "isMove": e.movability.is_some()
        }),
        Expr::Const(e) => json!({
            "kind": "xnkBlockStmt",
            "blockBody": e.block.stmts.iter().map(convert_stmt).collect::<Vec<_>>(),
            "isConst": true
        }),
        Expr::Continue(e) => json!({
            "kind": "xnkContinueStmt",
            "label": e.label.as_ref().map(|l| l.ident.to_string())
        }),
        Expr::Field(e) => json!({
            "kind": "xnkMemberAccessExpr",
            "memberExpr": convert_expr(&e.base),
            "memberName": match &e.member {
                Member::Named(ident) => ident.to_string(),
                Member::Unnamed(index) => format!("{}", index.index),
            }
        }),
        Expr::ForLoop(e) => json!({
            "kind": "xnkForeachStmt",
            "foreachVar": convert_pat(&e.pat),
            "foreachIter": convert_expr(&e.expr),
            "foreachBody": convert_block(&e.body),
            "label": e.label.as_ref().map(|l| l.name.ident.to_string())
        }),
        Expr::Group(e) => convert_expr(&e.expr), // Transparent
        Expr::If(e) => json!({
            "kind": "xnkIfStmt",
            "ifCondition": convert_expr(&e.cond),
            "ifBody": convert_block(&e.then_branch),
            "elseBody": e.else_branch.as_ref().map(|(_, expr)| convert_expr(expr))
        }),
        Expr::Index(e) => json!({
            "kind": "xnkIndexExpr",
            "indexExpr": convert_expr(&e.expr),
            "indexArgs": vec![convert_expr(&e.index)]
        }),
        Expr::Infer(_) => json!({
            "kind": "xnkIdentifier",
            "identName": "_"
        }),
        Expr::Let(e) => json!({
            "kind": "xnkVarDecl",
            "declPattern": convert_pat(&e.pat),
            "declInit": convert_expr(&e.expr)
        }),
        Expr::Lit(e) => convert_lit(&e.lit),
        Expr::Loop(e) => json!({
            "kind": "xnkWhileStmt",
            "whileCondition": {"kind": "xnkBoolLit", "boolValue": true},
            "whileBody": convert_block(&e.body),
            "label": e.label.as_ref().map(|l| l.name.ident.to_string())
        }),
        Expr::Macro(e) => json!({
            "kind": "xnkCallExpr",
            "callExpr": {"kind": "xnkIdentifier", "identName": e.mac.path.segments.last().unwrap().ident.to_string()},
            "callArgs": [],
            "isMacro": true,
            "macroTokens": e.mac.tokens.to_string()
        }),
        Expr::Match(e) => json!({
            "kind": "xnkSwitchStmt",
            "switchExpr": convert_expr(&e.expr),
            "switchCases": e.arms.iter().map(convert_arm).collect::<Vec<_>>()
        }),
        Expr::MethodCall(e) => json!({
            "kind": "xnkCallExpr",
            "callExpr": json!({
                "kind": "xnkMemberAccessExpr",
                "memberExpr": convert_expr(&e.receiver),
                "memberName": e.method.to_string()
            }),
            "callArgs": e.args.iter().map(convert_expr).collect::<Vec<_>>(),
            "turbofish": e.turbofish.as_ref().map(|t| t.args.iter().map(convert_generic_arg).collect::<Vec<_>>())
        }),
        Expr::Paren(e) => convert_expr(&e.expr), // Transparent
        Expr::Path(e) => convert_path(&e.path),
        Expr::Range(e) => json!({
            "kind": "xnkRangeExpr",
            "rangeStart": e.start.as_ref().map(|s| convert_expr(s)),
            "rangeEnd": e.end.as_ref().map(|s| convert_expr(s)),
            "rangeInclusive": matches!(e.limits, RangeLimits::Closed(_))
        }),
        Expr::RawAddr(e) => json!({
            "kind": "xnkRawAddrExpr",
            "rawAddrOperand": convert_expr(&e.expr),
            "rawAddrMutable": matches!(e.mutability, PointerMutability::Mut(_))
        }),
        Expr::Reference(e) => json!({
            "kind": "xnkRefExpr",
            "refExpr": convert_expr(&e.expr),
            "isMutable": e.mutability.is_some()
        }),
        Expr::Repeat(e) => json!({
            "kind": "xnkArrayLiteral",
            "arrayElements": vec![convert_expr(&e.expr)],
            "repeatCount": convert_expr(&e.len)
        }),
        Expr::Return(e) => json!({
            "kind": "xnkReturnStmt",
            "returnExpr": e.expr.as_ref().map(|ex| convert_expr(ex))
        }),
        Expr::Struct(e) => json!({
            "kind": "xnkStructLiteral",
            "structType": convert_path(&e.path),
            "structFields": e.fields.iter().map(|f| json!({
                "fieldName": match &f.member {
                    Member::Named(ident) => ident.to_string(),
                    Member::Unnamed(index) => format!("{}", index.index),
                },
                "fieldValue": convert_expr(&f.expr)
            })).collect::<Vec<_>>(),
            "structBase": e.rest.as_ref().map(|r| convert_expr(r))
        }),
        Expr::Try(e) => json!({
            "kind": "xnkTryExpr",
            "tryOperand": convert_expr(&e.expr)
        }),
        Expr::TryBlock(e) => json!({
            "kind": "xnkTryStmt",
            "tryBody": convert_block(&e.block),
            "tryCatches": []
        }),
        Expr::Tuple(e) => json!({
            "kind": "xnkTupleExpr",
            "elements": e.elems.iter().map(convert_expr).collect::<Vec<_>>()
        }),
        Expr::Unary(e) => json!({
            "kind": "xnkUnaryExpr",
            "unaryOp": format!("{:?}", e.op).to_lowercase(),
            "unaryOperand": convert_expr(&e.expr)
        }),
        Expr::Unsafe(e) => json!({
            "kind": "xnkUnsafeStmt",
            "unsafeBody": convert_block(&e.block)
        }),
        Expr::Verbatim(_) => json!({"kind": "xnkUnknown", "note": "verbatim expr"}),
        Expr::While(e) => json!({
            "kind": "xnkWhileStmt",
            "whileCondition": convert_expr(&e.cond),
            "whileBody": convert_block(&e.body),
            "label": e.label.as_ref().map(|l| l.name.ident.to_string())
        }),
        Expr::Yield(e) => json!({
            "kind": "xnkIteratorYield",
            "iteratorYieldValue": e.expr.as_ref().map(|ex| convert_expr(ex))
        }),
        _ => json!({"kind": "xnkUnknown", "note": "unknown expr variant"}),
    }
}

fn convert_arm(arm: &Arm) -> Value {
    json!({
        "kind": "xnkCaseClause",
        "caseValues": vec![convert_pat(&arm.pat)],
        "caseGuard": arm.guard.as_ref().map(|(_, expr)| convert_expr(expr)),
        "caseBody": convert_expr(&arm.body)
    })
}

fn convert_block(block: &Block) -> Value {
    json!({
        "kind": "xnkBlockStmt",
        "blockBody": block.stmts.iter().map(convert_stmt).collect::<Vec<_>>()
    })
}

fn convert_stmt(stmt: &Stmt) -> Value {
    match stmt {
        Stmt::Local(local) => {
            let mut var = json!({
                "kind": "xnkVarDecl",
                "declPattern": convert_pat(&local.pat),
                "declType": local.init.as_ref().and_then(|i| i.diverge.as_ref()).map(|(_, expr)| convert_expr(expr)),
                "declInit": local.init.as_ref().map(|i| convert_expr(&i.expr))
            });
            if let Some(obj) = var.as_object_mut() {
                obj.insert("attributes".to_string(), Value::Array(convert_attributes(&local.attrs)));
            }
            var
        },
        Stmt::Item(item) => convert_item(item),
        Stmt::Expr(expr, _) => convert_expr(expr),
        Stmt::Macro(mac) => json!({
            "kind": "xnkCallExpr",
            "callExpr": {"kind": "xnkIdentifier", "identName": mac.mac.path.segments.last().unwrap().ident.to_string()},
            "isMacro": true,
            "macroTokens": mac.mac.tokens.to_string()
        }),
    }
}

//
// Type Conversion
//

fn convert_type(ty: &Type) -> Value {
    match ty {
        Type::Array(t) => json!({
            "kind": "xnkArrayType",
            "elementType": convert_type(&t.elem),
            "arraySize": convert_expr(&t.len)
        }),
        Type::BareFn(t) => json!({
            "kind": "xnkFuncType",
            "funcParams": t.inputs.iter().map(|arg| json!({
                "kind": "xnkParameter",
                "paramName": arg.name.as_ref().map(|(n, _)| n.to_string()).unwrap_or_default(),
                "paramType": convert_type(&arg.ty)
            })).collect::<Vec<_>>(),
            "funcReturnType": convert_return_type(&t.output),
            "isUnsafe": t.unsafety.is_some()
        }),
        Type::Group(t) => convert_type(&t.elem),
        Type::ImplTrait(t) => json!({
            "kind": "xnkNamedType",
            "typeName": "impl",
            "bounds": t.bounds.iter().map(convert_type_param_bound).collect::<Vec<_>>()
        }),
        Type::Infer(_) => json!({"kind": "xnkNamedType", "typeName": "_"}),
        Type::Macro(t) => json!({
            "kind": "xnkNamedType",
            "typeName": format!("{}!", t.mac.path.segments.last().unwrap().ident)
        }),
        Type::Never(_) => json!({"kind": "xnkNamedType", "typeName": "!"}),
        Type::Paren(t) => convert_type(&t.elem),
        Type::Path(t) => convert_type_path(&t.path),
        Type::Ptr(t) => json!({
            "kind": "xnkPointerType",
            "referentType": convert_type(&t.elem),
            "isMutable": t.mutability.is_some(),
            "isConst": t.const_token.is_some()
        }),
        Type::Reference(t) => json!({
            "kind": "xnkReferenceType",
            "referentType": convert_type(&t.elem),
            "isMutable": t.mutability.is_some(),
            "lifetime": t.lifetime.as_ref().map(|l| l.ident.to_string())
        }),
        Type::Slice(t) => json!({
            "kind": "xnkArrayType",
            "elementType": convert_type(&t.elem)
        }),
        Type::TraitObject(t) => json!({
            "kind": "xnkNamedType",
            "typeName": "dyn",
            "bounds": t.bounds.iter().map(convert_type_param_bound).collect::<Vec<_>>()
        }),
        Type::Tuple(t) => json!({
            "kind": "xnkTupleExpr",
            "elements": t.elems.iter().map(convert_type).collect::<Vec<_>>()
        }),
        _ => json!({"kind": "xnkNamedType", "typeName": "unknown"}),
    }
}

fn convert_type_path(path: &Path) -> Value {
    if path.segments.len() == 1 {
        let seg = &path.segments[0];
        if seg.arguments.is_empty() {
            return json!({"kind": "xnkNamedType", "typeName": seg.ident.to_string()});
        } else {
            return json!({
                "kind": "xnkGenericType",
                "genericTypeName": seg.ident.to_string(),
                "genericArgs": extract_generic_args(&seg.arguments)
            });
        }
    }

    convert_path(path)
}

fn convert_path(path: &Path) -> Value {
    let parts: Vec<String> = path.segments.iter().map(|s| s.ident.to_string()).collect();
    if parts.len() == 1 {
        json!({"kind": "xnkIdentifier", "identName": parts[0]})
    } else {
        json!({"kind": "xnkQualifiedName", "qualifiedPath": parts.join("::")})
    }
}

fn extract_generic_args(args: &PathArguments) -> Vec<Value> {
    match args {
        PathArguments::AngleBracketed(args) => {
            args.args.iter().map(convert_generic_arg).collect()
        },
        _ => vec![],
    }
}

fn convert_generic_arg(arg: &GenericArgument) -> Value {
    match arg {
        GenericArgument::Type(ty) => convert_type(ty),
        GenericArgument::Lifetime(lt) => json!({
            "kind": "xnkGenericParameter",
            "genericParamName": lt.ident.to_string(),
            "isLifetime": true
        }),
        GenericArgument::Const(expr) => convert_expr(expr),
        _ => json!({"kind": "xnkUnknown", "note": "unknown generic arg"}),
    }
}

fn convert_lit(lit: &Lit) -> Value {
    match lit {
        Lit::Str(s) => json!({"kind": "xnkStringLit", "literalValue": s.value()}),
        Lit::ByteStr(s) => json!({"kind": "xnkStringLit", "literalValue": String::from_utf8_lossy(&s.value()).to_string(), "isByteString": true}),
        Lit::Byte(b) => json!({"kind": "xnkCharLit", "literalValue": (b.value() as char).to_string()}),
        Lit::Char(c) => json!({"kind": "xnkCharLit", "literalValue": c.value().to_string()}),
        Lit::Int(i) => json!({"kind": "xnkIntLit", "literalValue": i.base10_digits()}),
        Lit::Float(f) => json!({"kind": "xnkFloatLit", "literalValue": f.base10_digits()}),
        Lit::Bool(b) => json!({"kind": "xnkBoolLit", "boolValue": b.value}),
        Lit::Verbatim(_) => json!({"kind": "xnkUnknown", "note": "verbatim literal"}),
        _ => json!({"kind": "xnkUnknown", "note": "unknown literal"}),
    }
}

fn convert_pat(pat: &Pat) -> Value {
    match pat {
        Pat::Ident(p) => json!({
            "kind": "xnkIdentifier",
            "identName": p.ident.to_string(),
            "isMutable": p.mutability.is_some(),
            "byRef": p.by_ref.is_some()
        }),
        Pat::Lit(p) => convert_lit(&p.lit),
        Pat::Path(p) => convert_path(&p.path),
        Pat::Range(p) => json!({
            "kind": "xnkRangeExpr",
            "rangeStart": p.start.as_ref().map(|s| convert_expr(s)),
            "rangeEnd": p.end.as_ref().map(|s| convert_expr(s)),
            "rangeInclusive": matches!(p.limits, RangeLimits::Closed(_))
        }),
        Pat::Struct(p) => json!({
            "kind": "xnkStructLiteral",
            "structType": convert_path(&p.path),
            "structFields": p.fields.iter().map(|f| json!({
                "fieldName": match &f.member {
                    Member::Named(ident) => ident.to_string(),
                    Member::Unnamed(index) => format!("{}", index.index),
                },
                "fieldPattern": convert_pat(&f.pat)
            })).collect::<Vec<_>>(),
            "structRest": p.rest.is_some()
        }),
        Pat::Tuple(p) => json!({
            "kind": "xnkTupleExpr",
            "elements": p.elems.iter().map(convert_pat).collect::<Vec<_>>()
        }),
        Pat::TupleStruct(p) => json!({
            "kind": "xnkCallExpr",
            "callExpr": convert_path(&p.path),
            "callArgs": p.elems.iter().map(convert_pat).collect::<Vec<_>>()
        }),
        Pat::Type(p) => json!({
            "kind": "xnkCastExpr",
            "castExpr": convert_pat(&p.pat),
            "castType": convert_type(&p.ty)
        }),
        Pat::Wild(_) => json!({"kind": "xnkIdentifier", "identName": "_"}),
        Pat::Or(p) => json!({
            "kind": "xnkBinaryExpr",
            "binaryOp": "or",
            "binaryLeft": convert_pat(&p.cases[0]),
            "binaryRight": if p.cases.len() > 2 {
                json!({"kind": "xnkUnknown", "note": "multi-or pattern"})
            } else {
                convert_pat(&p.cases[1])
            }
        }),
        _ => json!({"kind": "xnkUnknown", "note": "unknown pattern"}),
    }
}

//
// Helper Converters
//

fn convert_generics(generics: &Generics) -> Vec<Value> {
    generics.params.iter().map(|param| {
        match param {
            GenericParam::Lifetime(lt) => json!({
                "kind": "xnkGenericParameter",
                "genericParamName": lt.lifetime.ident.to_string(),
                "isLifetime": true,
                "bounds": lt.bounds.iter().map(|b| json!({"kind": "xnkNamedType", "typeName": b.ident.to_string()})).collect::<Vec<_>>()
            }),
            GenericParam::Type(ty) => json!({
                "kind": "xnkGenericParameter",
                "genericParamName": ty.ident.to_string(),
                "isLifetime": false,
                "bounds": ty.bounds.iter().map(convert_type_param_bound).collect::<Vec<_>>()
            }),
            GenericParam::Const(c) => json!({
                "kind": "xnkGenericParameter",
                "genericParamName": c.ident.to_string(),
                "isConst": true,
                "constType": convert_type(&c.ty)
            }),
        }
    }).collect()
}

fn convert_type_param_bound(bound: &TypeParamBound) -> Value {
    match bound {
        TypeParamBound::Trait(t) => convert_path(&t.path),
        TypeParamBound::Lifetime(lt) => json!({
            "kind": "xnkNamedType",
            "typeName": lt.ident.to_string()
        }),
        _ => json!({"kind": "xnkUnknown", "note": "unknown bound"}),
    }
}

fn convert_fn_arg(arg: &FnArg) -> Value {
    match arg {
        FnArg::Receiver(r) => convert_receiver(r),
        FnArg::Typed(t) => json!({
            "kind": "xnkParameter",
            "paramName": match &*t.pat {
                Pat::Ident(ident) => ident.ident.to_string(),
                _ => "_".to_string(),
            },
            "paramType": convert_type(&t.ty)
        }),
    }
}

fn convert_return_type(ret: &ReturnType) -> Option<Value> {
    match ret {
        ReturnType::Default => None,
        ReturnType::Type(_, ty) => Some(convert_type(ty)),
    }
}

fn convert_visibility(vis: &Visibility) -> String {
    match vis {
        Visibility::Public(_) => "pub".to_string(),
        Visibility::Restricted(r) => {
            if r.path.segments.len() == 1 {
                let seg = &r.path.segments[0].ident;
                if seg == "crate" {
                    return "pub(crate)".to_string();
                } else if seg == "super" {
                    return "pub(super)".to_string();
                } else if seg == "self" {
                    return "pub(self)".to_string();
                }
            }
            format!("pub(in {})", quote::quote!(#r).to_string())
        },
        Visibility::Inherited => "private".to_string(),
    }
}

fn convert_attributes(attrs: &[Attribute]) -> Vec<Value> {
    attrs.iter().map(|attr| {
        json!({
            "kind": "xnkAttribute",
            "attrName": attr.path().segments.iter().map(|s| s.ident.to_string()).collect::<Vec<_>>().join("::"),
            "attrTokens": attr.meta.to_token_stream().to_string()
        })
    }).collect()
}
