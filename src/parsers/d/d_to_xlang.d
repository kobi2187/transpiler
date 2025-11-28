import std.stdio;
import std.file;
import std.json;
import std.conv;
import std.algorithm;
import std.array;
import dparse.ast;
import dparse.lexer;
import dparse.parser;
import dparse.rollback_allocator;

JSONValue convertToXLang(const Module module_) {
    JSONValue root;
    root["kind"] = "xnkFile";
    root["fileName"] = module_.moduleDeclaration ? 
        module_.moduleDeclaration.moduleName.identifiers.map!(id => id.text).join(".") : "unknown";
    
    JSONValue declarations = JSONValue.emptyArray;
    foreach (decl; module_.declarations) {
        declarations.array ~= convertDeclaration(decl);
    }
    root["declarations"] = declarations;
    
    return root;
}

JSONValue convertDeclaration(const Declaration decl) {
    if (auto funcDecl = cast(const FunctionDeclaration) decl) {
        return convertFunctionDeclaration(funcDecl);
    }
    if (auto classDecl = cast(const ClassDeclaration) decl) {
        return convertClassDeclaration(classDecl);
    }
    if (auto structDecl = cast(const StructDeclaration) decl) {
        return convertStructDeclaration(structDecl);
    }
    if (auto interfaceDecl = cast(const InterfaceDeclaration) decl) {
        return convertInterfaceDeclaration(interfaceDecl);
    }
    if (auto enumDecl = cast(const EnumDeclaration) decl) {
        return convertEnumDeclaration(enumDecl);
    }
    if (auto templateDecl = cast(const TemplateDeclaration) decl) {
        return convertTemplateDeclaration(templateDecl);
    }
    if (auto mixinDecl = cast(const MixinDeclaration) decl) {
        return convertMixinDeclaration(mixinDecl);
    }
    if (auto aliasDecl = cast(const AliasDeclaration) decl) {
        return convertAliasDeclaration(aliasDecl);
    }
    if (auto varDecl = cast(const VariableDeclaration) decl) {
        return convertVariableDeclaration(varDecl);
    }
    if (auto importDecl = cast(const ImportDeclaration) decl) {
        return convertImportDeclaration(importDecl);
    }
    if (auto staticAssert = cast(const StaticAssertDeclaration) decl) {
        return convertStaticAssertDeclaration(staticAssert);
    }
    
    return JSONValue(["kind": "xnkUnknown"]);
}

JSONValue convertFunctionDeclaration(const FunctionDeclaration funcDecl) {
    JSONValue node;
    node["kind"] = "xnkFuncDecl";
    node["name"] = funcDecl.name.text;
    
    JSONValue parameters = JSONValue.emptyArray;
    if (funcDecl.parameters) {
        foreach (param; funcDecl.parameters.parameters) {
            parameters.array ~= convertParameter(param);
        }
    }
    node["parameters"] = parameters;
    
    if (funcDecl.returnType) {
        node["returnType"] = convertType(funcDecl.returnType);
    }
    
    if (funcDecl.functionBody) {
        node["body"] = convertFunctionBody(funcDecl.functionBody);
    }
    
    return node;
}

JSONValue convertClassDeclaration(const ClassDeclaration classDecl) {
    JSONValue node;
    node["kind"] = "xnkClassDecl";
    node["name"] = classDecl.name.text;
    
    JSONValue baseClasses = JSONValue.emptyArray;
    if (classDecl.baseClassList) {
        foreach (base; classDecl.baseClassList.items) {
            baseClasses.array ~= convertType(base.type2);
        }
    }
    node["baseTypes"] = baseClasses;
    
    JSONValue members = JSONValue.emptyArray;
    if (classDecl.structBody) {
        foreach (decl; classDecl.structBody.declarations) {
            members.array ~= convertDeclaration(decl);
        }
    }
    node["members"] = members;
    
    return node;
}

JSONValue convertStructDeclaration(const StructDeclaration structDecl) {
    JSONValue node;
    node["kind"] = "xnkStructDecl";
    node["name"] = structDecl.name.text;
    
    JSONValue members = JSONValue.emptyArray;
    if (structDecl.structBody) {
        foreach (decl; structDecl.structBody.declarations) {
            members.array ~= convertDeclaration(decl);
        }
    }
    node["members"] = members;
    
    return node;
}

JSONValue convertInterfaceDeclaration(const InterfaceDeclaration interfaceDecl) {
    JSONValue node;
    node["kind"] = "xnkInterfaceDecl";
    node["name"] = interfaceDecl.name.text;
    
    JSONValue baseInterfaces = JSONValue.emptyArray;
    if (interfaceDecl.baseInterfaceList) {
        foreach (base; interfaceDecl.baseInterfaceList.items) {
            baseInterfaces.array ~= convertType(base.type2);
        }
    }
    node["baseTypes"] = baseInterfaces;
    
    JSONValue members = JSONValue.emptyArray;
    if (interfaceDecl.structBody) {
        foreach (decl; interfaceDecl.structBody.declarations) {
            members.array ~= convertDeclaration(decl);
        }
    }
    node["members"] = members;
    
    return node;
}

JSONValue convertEnumDeclaration(const EnumDeclaration enumDecl) {
    JSONValue node;
    node["kind"] = "xnkEnumDecl";
    node["name"] = enumDecl.name.text;
    
    if (enumDecl.type) {
        node["baseType"] = convertType(enumDecl.type);
    }
    
    JSONValue members = JSONValue.emptyArray;
    if (enumDecl.enumBody) {
        foreach (member; enumDecl.enumBody.enumMembers) {
            JSONValue memberNode;
            memberNode["name"] = member.name.text;
            if (member.assignExpression) {
                memberNode["value"] = convertExpression(member.assignExpression);
            }
            members.array ~= memberNode;
        }
    }
    node["members"] = members;
    
    return node;
}

JSONValue convertTemplateDeclaration(const TemplateDeclaration templateDecl) {
    JSONValue node;
    node["kind"] = "xnkTemplateDecl";
    node["name"] = templateDecl.name.text;
    
    JSONValue parameters = JSONValue.emptyArray;
    if (templateDecl.templateParameters) {
        foreach (param; templateDecl.templateParameters.templateParameterList.items) {
            parameters.array ~= convertTemplateParameter(param);
        }
    }
    node["parameters"] = parameters;
    
    JSONValue declarations = JSONValue.emptyArray;
    foreach (decl; templateDecl.declarations) {
        declarations.array ~= convertDeclaration(decl);
    }
    node["declarations"] = declarations;
    
    return node;
}

JSONValue convertMixinDeclaration(const MixinDeclaration mixinDecl) {
    JSONValue node;
    node["kind"] = "xnkMixinDecl";
    
    if (mixinDecl.mixinExpression) {
        node["expression"] = convertExpression(mixinDecl.mixinExpression.assignExpression);
    }
    
    return node;
}

JSONValue convertAliasDeclaration(const AliasDeclaration aliasDecl) {
    JSONValue node;
    node["kind"] = "xnkAliasDecl";
    
    if (aliasDecl.initializers.length > 0) {
        node["name"] = aliasDecl.initializers[0].name.text;
        if (aliasDecl.initializers[0].type) {
            node["type"] = convertType(aliasDecl.initializers[0].type);
        }
    }
    
    return node;
}

JSONValue convertVariableDeclaration(const VariableDeclaration varDecl) {
    JSONValue node;
    node["kind"] = "xnkVarDecl";
    
    if (varDecl.type) {
        node["type"] = convertType(varDecl.type);
    }
    
    JSONValue declarators = JSONValue.emptyArray;
    foreach (declarator; varDecl.declarators) {
        JSONValue declNode;
        declNode["name"] = declarator.name.text;
        if (declarator.initializer) {
            declNode["initializer"] = convertInitializer(declarator.initializer);
        }
        declarators.array ~= declNode;
    }
    node["declarators"] = declarators;
    
    return node;
}

JSONValue convertImportDeclaration(const ImportDeclaration importDecl) {
    return JSONValue([
        "kind": "xnkImport",
        "path": importDecl.singleImport ? 
                      importDecl.singleImport.identifierChain.identifiers.map!(id => id.text).join(".") :
                      importDecl.importBindings.map!(ib => ib.toString()).join(", "),
        "importAlias": importDecl.singleImport && importDecl.singleImport.rename ?
                       importDecl.singleImport.rename.text : JSONValue(null)
    ]);
}

JSONValue convertStaticAssertDeclaration(const StaticAssertDeclaration staticAssert) {
    JSONValue node;
    node["kind"] = "xnkStaticAssert";
    node["condition"] = convertExpression(staticAssert.assignExpression);
    if (staticAssert.message) {
        node["message"] = convertExpression(staticAssert.message);
    }
    return node;
}

JSONValue convertParameter(const Parameter param) {
    JSONValue node;
    node["kind"] = "xnkParameter";
    node["name"] = param.name.text;
    if (param.type) {
        node["type"] = convertType(param.type);
    }
    if (param.default_) {
        node["defaultValue"] = convertExpression(param.default_);
    }
    return node;
}

JSONValue convertTemplateParameter(const TemplateParameter param) {
    JSONValue node;
    node["kind"] = "xnkTemplateParameter";
    
    if (auto typeParam = cast(const TemplateTypeParameter) param) {
        node["name"] = typeParam.identifier.text;
        node["paramType"] = "type";
    } else if (auto valueParam = cast(const TemplateValueParameter) param) {
        node["name"] = valueParam.identifier.text;
        node["type"] = convertType(valueParam.type);
        node["paramType"] = "value";
    }
    
    return node;
}

JSONValue convertType(const Type type) {
    if (!type) return JSONValue(null);
    
    JSONValue node;
    node["kind"] = "xnkNamedType";
    node["name"] = type.toString();
    return node;
}

JSONValue convertFunctionBody(const FunctionBody body) {
    if (body.blockStatement) {
        return convertStatement(body.blockStatement);
    }
    return JSONValue(["kind": "xnkEmpty"]);
}

JSONValue convertStatement(const Statement stmt) {
    if (auto blockStmt = cast(const BlockStatement) stmt) {
        return convertBlockStatement(blockStmt);
    }
    if (auto ifStmt = cast(const IfStatement) stmt) {
        return convertIfStatement(ifStmt);
    }
    if (auto whileStmt = cast(const WhileStatement) stmt) {
        return convertWhileStatement(whileStmt);
    }
    if (auto forStmt = cast(const ForStatement) stmt) {
        return convertForStatement(forStmt);
    }
    if (auto foreachStmt = cast(const ForeachStatement) stmt) {
        return convertForeachStatement(foreachStmt);
    }
    if (auto switchStmt = cast(const SwitchStatement) stmt) {
        return convertSwitchStatement(switchStmt);
    }
    if (auto returnStmt = cast(const ReturnStatement) stmt) {
        return convertReturnStatement(returnStmt);
    }
    
    return JSONValue(["kind": "xnkUnknown"]);
}

JSONValue convertBlockStatement(const BlockStatement block) {
    JSONValue node;
    node["kind"] = "xnkBlockStmt";
    
    JSONValue statements = JSONValue.emptyArray;
    foreach (stmt; block.declarationsAndStatements) {
        statements.array ~= convertStatement(stmt);
    }
    node["statements"] = statements;
    
    return node;
}

JSONValue convertIfStatement(const IfStatement ifStmt) {
    JSONValue node;
    node["kind"] = "xnkIfStmt";
    node["condition"] = convertExpression(ifStmt.expression);
    node["thenBranch"] = convertStatement(ifStmt.thenStatement);
    if (ifStmt.elseStatement) {
        node["elseBranch"] = convertStatement(ifStmt.elseStatement);
    }
    return node;
}

JSONValue convertWhileStatement(const WhileStatement whileStmt) {
    JSONValue node;
    node["kind"] = "xnkWhileStmt";
    node["condition"] = convertExpression(whileStmt.expression);
    node["body"] = convertStatement(whileStmt.declarationOrStatement);
    return node;
}

JSONValue convertForStatement(const ForStatement forStmt) {
    JSONValue node;
    node["kind"] = "xnkForStmt";
    if (forStmt.initialization) {
        node["init"] = convertStatement(forStmt.initialization);
    }
    if (forStmt.test) {
        node["condition"] = convertExpression(forStmt.test);
    }
    if (forStmt.increment) {
        node["increment"] = convertExpression(forStmt.increment);
    }
    node["body"] = convertStatement(forStmt.declarationOrStatement);
    return node;
}

JSONValue convertForeachStatement(const ForeachStatement foreachStmt) {
    JSONValue node;
    node["kind"] = "xnkForeachStmt";
    node["iterator"] = convertExpression(foreachStmt.aggregate);
    node["body"] = convertStatement(foreachStmt.declarationOrStatement);
    return node;
}

JSONValue convertSwitchStatement(const SwitchStatement switchStmt) {
    JSONValue node;
    node["kind"] = "xnkSwitchStmt";
    node["expression"] = convertExpression(switchStmt.expression);
    return node;
}

JSONValue convertReturnStatement(const ReturnStatement returnStmt) {
    JSONValue node;
    node["kind"] = "xnkReturnStmt";
    if (returnStmt.expression) {
        node["expression"] = convertExpression(returnStmt.expression);
    }
    return node;
}

JSONValue convertExpression(const Expression expr) {
    if (!expr) return JSONValue(null);
    
    JSONValue node;
    node["kind"] = "xnkExpression";
    node["text"] = expr.toString();
    return node;
}

JSONValue convertInitializer(const Initializer init) {
    if (!init) return JSONValue(null);
    
    JSONValue node;
    node["kind"] = "xnkInitializer";
    return node;
}

void main(string[] args) {
    if (args.length < 2) {
        writeln("Usage: d-to-xlang-parser <d_source_file>");
        return;
    }

    string sourceCode = readText(args[1]);
    LexerConfig config;
    auto tokens = getTokensForParser(cast(ubyte[])sourceCode, config, &emptyStringCache);
    RollbackAllocator allocator;
    auto module_ = parseModule(tokens, args[1], &allocator);

    JSONValue xlangAST = convertToXLang(module_);
    writeln(xlangAST.toPrettyString());
}