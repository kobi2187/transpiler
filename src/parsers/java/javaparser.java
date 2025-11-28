import com.github.javaparser.JavaParser;
import com.github.javaparser.ParseResult;
import com.github.javaparser.ast.*;
import com.github.javaparser.ast.body.*;
import com.github.javaparser.ast.expr.*;
import com.github.javaparser.ast.stmt.*;
import com.github.javaparser.ast.type.*;
import com.github.javaparser.ast.modules.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.fasterxml.jackson.databind.node.ArrayNode;

import java.io.FileInputStream;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class ComprehensiveJavaToXLangParser {
    private static final ObjectMapper mapper = new ObjectMapper();

    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            System.out.println("Usage: java ComprehensiveJavaToXLangParser <java_file_path>");
            System.exit(1);
        }

        String filePath = args[0];
        ParseResult<CompilationUnit> parseResult = new JavaParser().parse(new FileInputStream(filePath));
        
        if (parseResult.isSuccessful() && parseResult.getResult().isPresent()) {
            CompilationUnit cu = parseResult.getResult().get();
            ObjectNode xlangAst = convertToXLang(cu);
            System.out.println(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(xlangAst));
        } else {
            System.err.println("Failed to parse Java file: " + filePath);
        }
    }

    private static ObjectNode convertToXLang(CompilationUnit cu) {
        ObjectNode root = mapper.createObjectNode();
        root.put("kind", "xnkFile");
        root.put("fileName", cu.getStorage().map(s -> s.getFileName()).orElse("unknown"));

        // Handle package declaration
        cu.getPackageDeclaration().ifPresent(pkg -> 
            root.set("packageDecl", convertPackageDeclaration(pkg)));

        // Handle imports
        if (cu.getImports().isNonEmpty()) {
            root.set("imports", convertImports(cu.getImports()));
        }

        // Handle module declaration (Java 9+)
        cu.getModule().ifPresent(module -> 
            root.set("moduleDecl", convertModuleDeclaration(module)));

        ArrayNode declarations = mapper.createArrayNode();
        cu.getTypes().forEach(type -> declarations.add(convertTypeDeclaration(type)));
        root.set("declarations", declarations);

        return root;
    }

    private static ObjectNode convertPackageDeclaration(PackageDeclaration pkg) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkNamespace");
        node.put("name", pkg.getNameAsString());
        return node;
    }

    private static ArrayNode convertImports(NodeList<ImportDeclaration> imports) {
        ArrayNode importsArray = mapper.createArrayNode();
        imports.forEach(imp -> {
            ObjectNode importNode = mapper.createObjectNode();
            importNode.put("kind", "xnkImport");
            importNode.put("name", imp.getNameAsString());
            importNode.put("isStatic", imp.isStatic());
            importNode.put("isAsterisk", imp.isAsterisk());
            importsArray.add(importNode);
        });
        return importsArray;
    }

    private static ObjectNode convertModuleDeclaration(ModuleDeclaration module) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkModule");
        node.put("name", module.getNameAsString());
        node.put("isOpen", module.isOpen());

        ArrayNode directives = mapper.createArrayNode();
        module.getDirectives().forEach(directive -> 
            directives.add(convertModuleDirective(directive)));
        node.set("directives", directives);

        return node;
    }

    private static ObjectNode convertModuleDirective(ModuleDirective directive) {
        ObjectNode node = mapper.createObjectNode();
        if (directive instanceof RequiresDirective) {
            RequiresDirective req = (RequiresDirective) directive;
            node.put("kind", "xnkRequiresDirective");
            node.put("name", req.getNameAsString());
            node.put("isStatic", req.isStatic());
            node.put("isTransitive", req.isTransitive());
        } else if (directive instanceof ExportsDirective) {
            ExportsDirective exp = (ExportsDirective) directive;
            node.put("kind", "xnkExportsDirective");
            node.put("name", exp.getNameAsString());
            if (exp.getModuleNames().isNonEmpty()) {
                ArrayNode modules = mapper.createArrayNode();
                exp.getModuleNames().forEach(m -> modules.add(m.asString()));
                node.set("toModules", modules);
            }
        } else if (directive instanceof OpensDirective) {
            OpensDirective opens = (OpensDirective) directive;
            node.put("kind", "xnkOpensDirective");
            node.put("name", opens.getNameAsString());
            if (opens.getModuleNames().isNonEmpty()) {
                ArrayNode modules = mapper.createArrayNode();
                opens.getModuleNames().forEach(m -> modules.add(m.asString()));
                node.set("toModules", modules);
            }
        } else if (directive instanceof UsesDirective) {
            UsesDirective uses = (UsesDirective) directive;
            node.put("kind", "xnkUsesDirective");
            node.put("name", uses.getNameAsString());
        } else if (directive instanceof ProvidesDirective) {
            ProvidesDirective provides = (ProvidesDirective) directive;
            node.put("kind", "xnkProvidesDirective");
            node.put("service", provides.getNameAsString());
            ArrayNode implementations = mapper.createArrayNode();
            provides.getImplementations().forEach(impl -> 
                implementations.add(impl.asString()));
            node.set("implementations", implementations);
        }
        return node;
    }

    private static ObjectNode convertTypeDeclaration(TypeDeclaration<?> type) {
        ObjectNode node = mapper.createObjectNode();

        if (type instanceof ClassOrInterfaceDeclaration) {
            ClassOrInterfaceDeclaration coid = (ClassOrInterfaceDeclaration) type;
            node.put("kind", coid.isInterface() ? "xnkInterfaceDecl" : "xnkClassDecl");
            node.put("name", coid.getNameAsString());

            if (coid.isInterface() && coid.isSealed()) {
                node.put("isSealed", true);
                ArrayNode permittedTypes = mapper.createArrayNode();
                coid.getPermittedTypes().forEach(t -> permittedTypes.add(convertType(t)));
                node.set("permittedTypes", permittedTypes);
            }

            ArrayNode baseTypes = mapper.createArrayNode();
            coid.getExtendedTypes().forEach(t -> baseTypes.add(convertType(t)));
            coid.getImplementedTypes().forEach(t -> baseTypes.add(convertType(t)));
            if (baseTypes.size() > 0) {
                node.set("baseTypes", baseTypes);
            }

            ArrayNode members = mapper.createArrayNode();
            coid.getMembers().forEach(member -> members.add(convertClassMember(member)));
            node.set("members", members);

            if (coid.getTypeParameters().isNonEmpty()) {
                node.set("typeParameters", convertTypeParameters(coid.getTypeParameters()));
            }

            if (coid.getAnnotations().isNonEmpty()) {
                node.set("decorators", convertAnnotations(coid.getAnnotations()));
            }

            node.set("modifiers", convertModifiers(coid.getModifiers()));

        } else if (type instanceof EnumDeclaration) {
            EnumDeclaration enumDecl = (EnumDeclaration) type;
            node.put("kind", "xnkEnumDecl");
            node.put("name", enumDecl.getNameAsString());

            ArrayNode enumMembers = mapper.createArrayNode();
            enumDecl.getEntries().forEach(entry -> {
                ObjectNode memberNode = mapper.createObjectNode();
                memberNode.put("name", entry.getNameAsString());
                if (entry.getArguments().isNonEmpty()) {
                    ArrayNode args = mapper.createArrayNode();
                    entry.getArguments().forEach(arg -> args.add(convertExpression(arg)));
                    memberNode.set("arguments", args);
                }
                if (entry.getClassBody().isPresent()) {
                    ArrayNode body = mapper.createArrayNode();
                    entry.getClassBody().get().getMembers().forEach(member -> 
                        body.add(convertClassMember(member)));
                    memberNode.set("body", body);
                }
                enumMembers.add(memberNode);
            });
            node.set("enumMembers", enumMembers);

            if (enumDecl.getImplementedTypes().isNonEmpty()) {
                ArrayNode interfaces = mapper.createArrayNode();
                enumDecl.getImplementedTypes().forEach(t -> interfaces.add(convertType(t)));
                node.set("implementedTypes", interfaces);
            }

            ArrayNode members = mapper.createArrayNode();
            enumDecl.getMembers().forEach(member -> members.add(convertClassMember(member)));
            node.set("members", members);

        } else if (type instanceof AnnotationDeclaration) {
            AnnotationDeclaration annDecl = (AnnotationDeclaration) type;
            node.put("kind", "xnkAnnotationDecl");
            node.put("name", annDecl.getNameAsString());

            ArrayNode members = mapper.createArrayNode();
            annDecl.getMembers().forEach(member -> members.add(convertAnnotationMember(member)));
            node.set("members", members);

        } else if (type instanceof RecordDeclaration) {
            RecordDeclaration recordDecl = (RecordDeclaration) type;
            node.put("kind", "xnkRecordDecl");
            node.put("name", recordDecl.getNameAsString());

            ArrayNode parameters = mapper.createArrayNode();
            recordDecl.getParameters().forEach(param -> 
                parameters.add(convertParameter(param)));
            node.set("parameters", parameters);

            ArrayNode members = mapper.createArrayNode();
            recordDecl.getMembers().forEach(member -> members.add(convertClassMember(member)));
            node.set("members", members);

            if (recordDecl.getImplementedTypes().isNonEmpty()) {
                ArrayNode interfaces = mapper.createArrayNode();
                recordDecl.getImplementedTypes().forEach(t -> interfaces.add(convertType(t)));
                node.set("implementedTypes", interfaces);
            }
        }

        return node;
    }

    private static ObjectNode convertClassMember(BodyDeclaration<?> member) {
        if (member instanceof MethodDeclaration) {
            return convertMethodDeclaration((MethodDeclaration) member);
        } else if (member instanceof FieldDeclaration) {
            return convertFieldDeclaration((FieldDeclaration) member);
        } else if (member instanceof ConstructorDeclaration) {
            return convertConstructorDeclaration((ConstructorDeclaration) member);
        } else if (member instanceof InitializerDeclaration) {
            return convertInitializerDeclaration((InitializerDeclaration) member);
        } else if (member instanceof ClassOrInterfaceDeclaration) {
            return convertTypeDeclaration((ClassOrInterfaceDeclaration) member);
        }
        return mapper.createObjectNode().put("kind", "xnkUnknown");
    }

    private static ObjectNode convertMethodDeclaration(MethodDeclaration method) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkMethodDecl");
        node.put("name", method.getNameAsString());

        node.set("parameters", convertParameters(method.getParameters()));
        node.set("returnType", convertType(method.getType()));
        method.getBody().ifPresent(body -> node.set("body", convertMethodBody(body)));

        if (method.getTypeParameters().isNonEmpty()) {
            node.set("typeParameters", convertTypeParameters(method.getTypeParameters()));
        }

        if (method.getAnnotations().isNonEmpty()) {
            node.set("decorators", convertAnnotations(method.getAnnotations()));
        }

        node.set("modifiers", convertModifiers(method.getModifiers()));

        if (method.getThrownExceptions().isNonEmpty()) {
            ArrayNode exceptions = mapper.createArrayNode();
            method.getThrownExceptions().forEach(ex -> exceptions.add(convertType(ex)));
            node.set("throws", exceptions);
        }

        return node;
    }

    private static ObjectNode convertFieldDeclaration(FieldDeclaration field) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkFieldDecl");
        node.set("type", convertType(field.getElementType()));

        ArrayNode variables = mapper.createArrayNode();
        field.getVariables().forEach(var -> {
            ObjectNode varNode = mapper.createObjectNode();
            varNode.put("name", var.getNameAsString());
            var.getInitializer().ifPresent(init -> 
                varNode.set("initializer", convertExpression(init)));
            variables.add(varNode);
        });
        node.set("variables", variables);

        if (field.getAnnotations().isNonEmpty()) {
            node.set("decorators", convertAnnotations(field.getAnnotations()));
        }

        node.set("modifiers", convertModifiers(field.getModifiers()));

        return node;
    }

    private static ObjectNode convertConstructorDeclaration(ConstructorDeclaration constructor) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkConstructorDecl");
        node.put("name", constructor.getNameAsString());

        node.set("parameters", convertParameters(constructor.getParameters()));
        node.set("body", convertMethodBody(constructor.getBody()));

        if (constructor.getTypeParameters().isNonEmpty()) {
            node.set("typeParameters", convertTypeParameters(constructor.getTypeParameters()));
        }

        if (constructor.getAnnotations().isNonEmpty()) {
            node.set("decorators", convertAnnotations(constructor.getAnnotations()));
        }

        node.set("modifiers", convertModifiers(constructor.getModifiers()));

        if (constructor.getThrownExceptions().isNonEmpty()) {
            ArrayNode exceptions = mapper.createArrayNode();
            constructor.getThrownExceptions().forEach(ex -> exceptions.add(convertType(ex)));
            node.set("throws", exceptions);
        }

        return node;
    }

    private static ObjectNode convertInitializerDeclaration(InitializerDeclaration initializer) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkInitializerDecl");
        node.put("isStatic", initializer.isStatic());
        node.set("body", convertMethodBody(initializer.getBody()));
        return node;
    }

    private static ArrayNode convertParameters(NodeList<Parameter> parameters) {
        ArrayNode params = mapper.createArrayNode();
        parameters.forEach(param -> params.add(convertParameter(param)));
        return params;
    }

    private static ObjectNode convertParameter(Parameter param) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkParameter");
        node.put("name", param.getNameAsString());
        node.set("type", convertType(param.getType()));
        if (param.isVarArgs()) {
            node.put("isVarArgs", true);
        }
        if (param.getAnnotations().isNonEmpty()) {
            node.set("decorators", convertAnnotations(param.getAnnotations()));
        }
        return node;
    }

    private static ObjectNode convertMethodBody(BlockStmt body) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkBlockStmt");
        ArrayNode statements = mapper.createArrayNode();
        body.getStatements().forEach(stmt -> statements.add(convertStatement(stmt)));
        node.set("statements", statements);
        return node;
    }

    private static ObjectNode convertStatement(Statement stmt) {
        if (stmt instanceof ExpressionStmt) {
            return convertExpression(((ExpressionStmt) stmt).getExpression());
        } else if (stmt instanceof BlockStmt) {
            return convertMethodBody((BlockStmt) stmt);
        } else if (stmt instanceof IfStmt) {
            return convertIfStatement((IfStmt) stmt);
        } else if (stmt instanceof WhileStmt) {
            return convertWhileStatement((WhileStmt) stmt);
        } else if (stmt instanceof ForStmt) {
            return convertForStatement((ForStmt) stmt);
        } else if (stmt instanceof ForEachStmt) {
            return convertForEachStatement((ForEachStmt) stmt);
        } else if (stmt instanceof DoStmt) {
            return convertDoWhileStatement((DoStmt) stmt);
        } else if (stmt instanceof SwitchStmt) {
            return convertSwitchStatement((SwitchStmt) stmt);
        } else if (stmt instanceof ReturnStmt) {
            return convertReturnStatement((ReturnStmt) stmt);
        } else if (stmt instanceof ThrowStmt) {
            return convertThrowStatement((ThrowStmt) stmt);
        } else if (stmt instanceof TryStmt) {
            return convertTryStatement((TryStmt) stmt);
        } else if (stmt instanceof BreakStmt) {
            return convertBreakStatement((BreakStmt) stmt);
        } else if (stmt instanceof ContinueStmt) {
            return convertContinueStatement((ContinueStmt) stmt);
        } else if (stmt instanceof LabeledStmt) {
            return convertLabeledStatement((LabeledStmt) stmt);
        } else if (stmt instanceof AssertStmt) {
            return convertAssertStatement((AssertStmt) stmt);
        } else if (stmt instanceof SynchronizedStmt) {
            return convertSynchronizedStatement((SynchronizedStmt) stmt);
        } else if (stmt instanceof YieldStmt) {
            return convertYieldStatement((YieldStmt) stmt);
        }
        return mapper.createObjectNode().put("kind", "xnkUnknown");
    }

    private static ObjectNode convertIfStatement(IfStmt stmt) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkIfStmt");
        node.set("condition", convertExpression(stmt.getCondition()));
        node.set("thenStmt", convertStatement(stmt.getThenStmt()));
        stmt.getElseStmt().ifPresent(elseStmt -> 
            node.set("elseStmt", convertStatement(elseStmt)));
        return node;
    }

    private static ObjectNode convertWhileStatement(WhileStmt stmt) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkWhileStmt");
        node.set("condition", convertExpression(stmt.getCondition()));
        node.set("body", convertStatement(stmt.getBody()));
        return node;
    }

    private static ObjectNode convertForStatement(ForStmt stmt) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkForStmt");
        ArrayNode initialization = mapper.createArrayNode();
        stmt.getInitialization().forEach(init -> initialization.add(convertExpression(init)));
        node.set("initialization", initialization);
        stmt.getCompare().ifPresent(compare -> 
            node.set("condition", convertExpression(compare)));
        ArrayNode update = mapper.createArrayNode();
        stmt.getUpdate().forEach(upd -> update.add(convertExpression(upd)));
        node.set("update", update);
        node.set("body", convertStatement(stmt.getBody()));
        return node;
    }

    private static ObjectNode convertForEachStatement(ForEachStmt stmt) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkForeachStmt");
        node.set("variable", convertVariableDeclarationExpr(stmt.getVariable()));
        node.set("iterable", convertExpression(stmt.getIterable()));
        node.set("body", convertStatement(stmt.getBody()));
        return node;
    }

    private static ObjectNode convertDoWhileStatement(DoStmt stmt) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkDoWhileStmt");
        node.set("body", convertStatement(stmt.getBody()));
        node.set("condition", convertExpression(stmt.getCondition()));
        return node;
    }

    private static ObjectNode convertSwitchStatement(SwitchStmt stmt) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkSwitchStmt");
        node.set("selector", convertExpression(stmt.getSelector()));
        ArrayNode entries = mapper.createArrayNode();
        stmt.getEntries().forEach(entry -> {
            ObjectNode entryNode = mapper.createObjectNode();
            if (entry.getLabels().isNonEmpty()) {
                ArrayNode labels = mapper.createArrayNode();
                entry.getLabels().forEach(label -> labels.add(convertExpression(label)));
                entryNode.set("labels", labels);
            } else {
                entryNode.put("isDefault", true);
            }
            ArrayNode statements = mapper.createArrayNode();
            entry.getStatements().forEach(s -> statements.add(convertStatement(s)));
            entryNode.set("statements", statements);
            entries.add(entryNode);
        });
        node.set("entries", entries);
        return node;
    }

    private static ObjectNode convertReturnStatement(ReturnStmt stmt) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkReturnStmt");
        stmt.getExpression().ifPresent(expr -> 
            node.set("expression", convertExpression(expr)));
        return node;
    }

    private static ObjectNode convertThrowStatement(ThrowStmt stmt) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkThrowStmt");
        node.set("expression", convertExpression(stmt.getExpression()));
        return node;
    }

    private static ObjectNode convertTryStatement(TryStmt stmt) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkTryStmt");
        node.set("tryBlock", convertMethodBody(stmt.getTryBlock()));
        ArrayNode catchClauses = mapper.createArrayNode();
        stmt.getCatchClauses().forEach(catchClause -> {
            ObjectNode catchNode = mapper.createObjectNode();
            catchNode.put("kind", "xnkCatchClause");
            catchNode.set("parameter", convertParameter(catchClause.getParameter()));
            catchNode.set("body", convertMethodBody(catchClause.getBody()));
            catchClauses.add(catchNode);
        });
        node.set("catchClauses", catchClauses);
        stmt.getFinallyBlock().ifPresent(finallyBlock -> 
            node.set("finallyBlock", convertMethodBody(finallyBlock)));
        if (stmt.getResources().isNonEmpty()) {
            ArrayNode resources = mapper.createArrayNode();
            stmt.getResources().forEach(resource -> 
                resources.add(convertExpression(resource)));
            node.set("resources", resources);
        }
        return node;
    }

    private static ObjectNode convertBreakStatement(BreakStmt stmt) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkBreakStmt");
        stmt.getLabel().ifPresent(label -> node.put("label", label.asString()));
        return node;
    }

    private static ObjectNode convertContinueStatement(ContinueStmt stmt) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkContinueStmt");
        stmt.getLabel().ifPresent(label -> node.put("label", label.asString()));
        return node;
    }

    private static ObjectNode convertLabeledStatement(LabeledStmt stmt) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkLabeledStmt");
        node.put("label", stmt.getLabel().asString());
        node.set("statement", convertStatement(stmt.getStatement()));
        return node;
    }

    private static ObjectNode convertAssertStatement(AssertStmt stmt) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkAssertStmt");
        node.set("check", convertExpression(stmt.getCheck()));
        stmt.getMessage().ifPresent(msg -> 
            node.set("message", convertExpression(msg)));
        return node;
    }

    private static ObjectNode convertSynchronizedStatement(SynchronizedStmt stmt) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkSynchronizedStmt");
        node.set("expression", convertExpression(stmt.getExpression()));
        node.set("body", convertMethodBody(stmt.getBody()));
        return node;
    }

    private static ObjectNode convertYieldStatement(YieldStmt stmt) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkYieldStmt");
        node.set("expression", convertExpression(stmt.getExpression()));
        return node;
    }

    private static ObjectNode convertExpression(Expression expr) {
        if (expr instanceof BinaryExpr) {
            return convertBinaryExpression((BinaryExpr) expr);
        } else if (expr instanceof UnaryExpr) {
            return convertUnaryExpression((UnaryExpr) expr);
        } else if (expr instanceof MethodCallExpr) {
            return convertMethodCallExpression((MethodCallExpr) expr);
        } else if (expr instanceof FieldAccessExpr) {
            return convertFieldAccessExpression((FieldAccessExpr) expr);
        } else if (expr instanceof ObjectCreationExpr) {
            return convertObjectCreationExpression((ObjectCreationExpr) expr);
        } else if (expr instanceof LambdaExpr) {
            return convertLambdaExpression((LambdaExpr) expr);
        } else if (expr instanceof NameExpr) {
            return convertNameExpression((NameExpr) expr);
        } else if (expr instanceof LiteralExpr) {
            return convertLiteralExpression((LiteralExpr) expr);
        } else if (expr instanceof CastExpr) {
            return convertCastExpression((CastExpr) expr);
        } else if (expr instanceof InstanceOfExpr) {
            return convertInstanceOfExpression((InstanceOfExpr) expr);
        } else if (expr instanceof ConditionalExpr) {
            return convertConditionalExpression((ConditionalExpr) expr);
        } else if (expr instanceof AssignExpr) {
            return convertAssignExpression((AssignExpr) expr);
        } else if (expr instanceof ArrayCreationExpr) {
            return convertArrayCreationExpression((ArrayCreationExpr) expr);
        } else if (expr instanceof ArrayAccessExpr) {
            return convertArrayAccessExpression((ArrayAccessExpr) expr);
        } else if (expr instanceof EnclosedExpr) {
            return convertEnclosedExpression((EnclosedExpr) expr);
        } else if (expr instanceof MethodReferenceExpr) {
            return convertMethodReferenceExpression((MethodReferenceExpr) expr);
        } else if (expr instanceof ThisExpr) {
            return convertThisExpression((ThisExpr) expr);
        } else if (expr instanceof SuperExpr) {
            return convertSuperExpression((SuperExpr) expr);
        } else if (expr instanceof TypeExpr) {
            return convertTypeExpression((TypeExpr) expr);
        } else if (expr instanceof VariableDeclarationExpr) {
            return convertVariableDeclarationExpr((VariableDeclarationExpr) expr);
        } else if (expr instanceof SwitchExpr) {
            return convertSwitchExpression((SwitchExpr) expr);
        }
        return mapper.createObjectNode().put("kind", "xnkUnknown");
    }

    private static ObjectNode convertBinaryExpression(BinaryExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkBinaryExpr");
        node.set("left", convertExpression(expr.getLeft()));
        node.put("operator", expr.getOperator().asString());
        node.set("right", convertExpression(expr.getRight()));
        return node;
    }

    private static ObjectNode convertUnaryExpression(UnaryExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkUnaryExpr");
        node.put("operator", expr.getOperator().asString());
        node.set("expression", convertExpression(expr.getExpression()));
        return node;
    }

    private static ObjectNode convertMethodCallExpression(MethodCallExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkCallExpr");
        expr.getScope().ifPresent(scope -> 
            node.set("scope", convertExpression(scope)));
        node.put("name", expr.getNameAsString());
        ArrayNode arguments = mapper.createArrayNode();
        expr.getArguments().forEach(arg -> arguments.add(convertExpression(arg)));
        node.set("arguments", arguments);
        return node;
    }

    private static ObjectNode convertFieldAccessExpression(FieldAccessExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkMemberAccessExpr");
        node.set("scope", convertExpression(expr.getScope()));
        node.put("name", expr.getNameAsString());
        return node;
    }

    private static ObjectNode convertObjectCreationExpression(ObjectCreationExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkNewExpr");
        node.set("type", convertType(expr.getType()));
        ArrayNode arguments = mapper.createArrayNode();
        expr.getArguments().forEach(arg -> arguments.add(convertExpression(arg)));
        node.set("arguments", arguments);
        expr.getAnonymousClassBody().ifPresent(body -> {
            ArrayNode anonymousBody = mapper.createArrayNode();
            body.forEach(member -> anonymousBody.add(convertClassMember(member)));
            node.set("anonymousClassBody", anonymousBody);
        });
        return node;
    }

    private static ObjectNode convertLambdaExpression(LambdaExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkLambdaExpr");
        ArrayNode parameters = mapper.createArrayNode();
        expr.getParameters().forEach(param -> parameters.add(convertParameter(param)));
        node.set("parameters", parameters);
        if (expr.getBody().isBlockStmt()) {
            node.set("body", convertMethodBody(expr.getBody().asBlockStmt()));
        } else {
            node.set("body", convertExpression(expr.getBody()));
        }
        return node;
    }

    private static ObjectNode convertNameExpression(NameExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkIdentifier");
        node.put("name", expr.getNameAsString());
        return node;
    }

    private static ObjectNode convertLiteralExpression(LiteralExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        if (expr instanceof IntegerLiteralExpr) {
            node.put("kind", "xnkIntLit");
            node.put("value", ((IntegerLiteralExpr) expr).asNumber().toString());
        } else if (expr instanceof LongLiteralExpr) {
            node.put("kind", "xnkIntLit");
            node.put("value", ((LongLiteralExpr) expr).asNumber().toString());
        } else if (expr instanceof DoubleLiteralExpr) {
            node.put("kind", "xnkFloatLit");
            node.put("value", ((DoubleLiteralExpr) expr).asDouble());
        } else if (expr instanceof StringLiteralExpr) {
            node.put("kind", "xnkStringLit");
            node.put("value", ((StringLiteralExpr) expr).asString());
        } else if (expr instanceof CharLiteralExpr) {
            node.put("kind", "xnkCharLit");
            node.put("value", ((CharLiteralExpr) expr).asChar());
        } else if (expr instanceof BooleanLiteralExpr) {
            node.put("kind", "xnkBoolLit");
            node.put("value", ((BooleanLiteralExpr) expr).getValue());
        } else if (expr instanceof NullLiteralExpr) {
            node.put("kind", "xnkNoneLit");
        }
        return node;
    }

    private static ObjectNode convertCastExpression(CastExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkCastExpr");
        node.set("type", convertType(expr.getType()));
        node.set("expression", convertExpression(expr.getExpression()));
        return node;
    }

    private static ObjectNode convertInstanceOfExpression(InstanceOfExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkInstanceOfExpr");
        node.set("expression", convertExpression(expr.getExpression()));
        node.set("type", convertType(expr.getType()));
        expr.getPattern().ifPresent(pattern -> 
            node.set("pattern", convertPattern(pattern)));
        return node;
    }

    private static ObjectNode convertPattern(PatternExpr pattern) {
        if (pattern instanceof VarPattern) {
            VarPattern varPattern = (VarPattern) pattern;
            ObjectNode node = mapper.createObjectNode();
            node.put("kind", "xnkVarPattern");
            node.put("name", varPattern.getNameAsString());
            node.set("type", convertType(varPattern.getType()));
            return node;
        }
        // Add support for other pattern types as they are introduced in future Java versions
        return mapper.createObjectNode().put("kind", "xnkUnknownPattern");
    }

    private static ObjectNode convertConditionalExpression(ConditionalExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkTernaryExpr");
        node.set("condition", convertExpression(expr.getCondition()));
        node.set("thenExpr", convertExpression(expr.getThenExpr()));
        node.set("elseExpr", convertExpression(expr.getElseExpr()));
        return node;
    }

    private static ObjectNode convertAssignExpression(AssignExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkAssignExpr");
        node.set("target", convertExpression(expr.getTarget()));
        node.put("operator", expr.getOperator().asString());
        node.set("value", convertExpression(expr.getValue()));
        return node;
    }

    private static ObjectNode convertArrayCreationExpression(ArrayCreationExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkArrayCreateExpr");
        node.set("elementType", convertType(expr.getElementType()));
        ArrayNode levels = mapper.createArrayNode();
        expr.getLevels().forEach(level -> {
            ObjectNode levelNode = mapper.createObjectNode();
            level.getDimension().ifPresent(dim -> 
                levelNode.set("dimension", convertExpression(dim)));
            levels.add(levelNode);
        });
        node.set("levels", levels);
        expr.getInitializer().ifPresent(init -> 
            node.set("initializer", convertArrayInitializerExpression(init)));
        return node;
    }

    private static ObjectNode convertArrayInitializerExpression(ArrayInitializerExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkArrayInitializerExpr");
        ArrayNode values = mapper.createArrayNode();
        expr.getValues().forEach(value -> values.add(convertExpression(value)));
        node.set("values", values);
        return node;
    }

    private static ObjectNode convertArrayAccessExpression(ArrayAccessExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkIndexExpr");
        node.set("name", convertExpression(expr.getName()));
        node.set("index", convertExpression(expr.getIndex()));
        return node;
    }

    private static ObjectNode convertEnclosedExpression(EnclosedExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkParenthesizedExpr");
        node.set("inner", convertExpression(expr.getInner()));
        return node;
    }

    private static ObjectNode convertMethodReferenceExpression(MethodReferenceExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkMethodReferenceExpr");
        node.set("scope", convertExpression(expr.getScope()));
        node.put("identifier", expr.getIdentifier());
        return node;
    }

    private static ObjectNode convertThisExpression(ThisExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkThisExpr");
        expr.getTypeName().ifPresent(typeName -> 
            node.put("typeName", typeName.asString()));
        return node;
    }

    private static ObjectNode convertSuperExpression(SuperExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkSuperExpr");
        expr.getTypeName().ifPresent(typeName -> 
            node.put("typeName", typeName.asString()));
        return node;
    }

    private static ObjectNode convertTypeExpression(TypeExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkTypeExpr");
        node.set("type", convertType(expr.getType()));
        return node;
    }

    private static ObjectNode convertVariableDeclarationExpr(VariableDeclarationExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkVarDecl");
        node.set("modifiers", convertModifiers(expr.getModifiers()));
        node.set("annotations", convertAnnotations(expr.getAnnotations()));
        ArrayNode variables = mapper.createArrayNode();
        expr.getVariables().forEach(var -> {
            ObjectNode varNode = mapper.createObjectNode();
            varNode.put("name", var.getNameAsString());
            varNode.set("type", convertType(var.getType()));
            var.getInitializer().ifPresent(init -> 
                varNode.set("initializer", convertExpression(init)));
            variables.add(varNode);
        });
        node.set("variables", variables);
        return node;
    }

    private static ObjectNode convertSwitchExpression(SwitchExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkSwitchExpr");
        node.set("selector", convertExpression(expr.getSelector()));
        ArrayNode entries = mapper.createArrayNode();
        expr.getEntries().forEach(entry -> {
            ObjectNode entryNode = mapper.createObjectNode();
            if (entry.getLabels().isNonEmpty()) {
                ArrayNode labels = mapper.createArrayNode();
                entry.getLabels().forEach(label -> labels.add(convertExpression(label)));
                entryNode.set("labels", labels);
            } else {
                entryNode.put("isDefault", true);
            }
            entryNode.set("result", convertExpression(entry.getResult()));
            entries.add(entryNode);
        });
        node.set("entries", entries);
        return node;
    }

    private static ObjectNode convertType(Type type) {
        ObjectNode node = mapper.createObjectNode();
        if (type.isClassOrInterfaceType()) {
            ClassOrInterfaceType cit = type.asClassOrInterfaceType();
            node.put("kind", "xnkNamedType");
            node.put("name", cit.getNameAsString());
            if (cit.getTypeArguments().isPresent()) {
                ArrayNode typeArgs = mapper.createArrayNode();
                cit.getTypeArguments().get().forEach(arg -> typeArgs.add(convertType(arg)));
                node.set("typeArguments", typeArgs);
            }
        } else if (type.isPrimitiveType()) {
            node.put("kind", "xnkNamedType");
            node.put("name", type.asPrimitiveType().asString());
        } else if (type.isVoidType()) {
            node.put("kind", "xnkNamedType");
            node.put("name", "void");
        } else if (type.isArrayType()) {
            node.put("kind", "xnkArrayType");
            node.set("elementType", convertType(type.asArrayType().getComponentType()));
        } else if (type.isWildcardType()) {
            WildcardType wt = type.asWildcardType();
            node.put("kind", "xnkWildcardType");
            wt.getExtendedType().ifPresent(ext -> 
                node.set("extendsBound", convertType(ext)));
            wt.getSuperType().ifPresent(sup -> 
                node.set("superBound", convertType(sup)));
        } else if (type.isUnionType()) {
            node.put("kind", "xnkUnionType");
            ArrayNode elements = mapper.createArrayNode();
            type.asUnionType().getElements().forEach(elem -> elements.add(convertType(elem)));
            node.set("elements", elements);
        } else if (type.isIntersectionType()) {
            node.put("kind", "xnkIntersectionType");
            ArrayNode elements = mapper.createArrayNode();
            type.asIntersectionType().getElements().forEach(elem -> elements.add(convertType(elem)));
            node.set("elements", elements);
        } else if (type.isTypeParameter()) {
            node.put("kind", "xnkTypeParameter");
            node.put("name", type.asTypeParameter().getNameAsString());
        }
        return node;
    }

    private static ArrayNode convertTypeParameters(NodeList<TypeParameter> typeParameters) {
        ArrayNode params = mapper.createArrayNode();
        typeParameters.forEach(tp -> {
            ObjectNode param = mapper.createObjectNode();
            param.put("kind", "xnkTypeParameter");
            param.put("name", tp.getNameAsString());
            if (tp.getTypeBound().isNonEmpty()) {
                ArrayNode bounds = mapper.createArrayNode();
                tp.getTypeBound().forEach(bound -> bounds.add(convertType(bound)));
                param.set("bounds", bounds);
            }
            params.add(param);
        });
        return params;
    }

    private static ArrayNode convertAnnotations(NodeList<AnnotationExpr> annotations) {
        ArrayNode annotationNodes = mapper.createArrayNode();
        annotations.forEach(ann -> {
            ObjectNode annotationNode = mapper.createObjectNode();
            annotationNode.put("kind", "xnkDecorator");
            annotationNode.put("name", ann.getNameAsString());
            if (ann instanceof NormalAnnotationExpr) {
                ArrayNode pairs = mapper.createArrayNode();
                ((NormalAnnotationExpr) ann).getPairs().forEach(pair -> {
                    ObjectNode pairNode = mapper.createObjectNode();
                    pairNode.put("name", pair.getNameAsString());
                    pairNode.set("value", convertExpression(pair.getValue()));
                    pairs.add(pairNode);
                });
                annotationNode.set("pairs", pairs);
            } else if (ann instanceof SingleMemberAnnotationExpr) {
                annotationNode.set("value", convertExpression(((SingleMemberAnnotationExpr) ann).getMemberValue()));
            }
            annotationNodes.add(annotationNode);
        });
        return annotationNodes;
    }

    private static ObjectNode convertModifiers(NodeList<Modifier> modifiers) {
        ObjectNode mods = mapper.createObjectNode();
        mods.put("isPublic", modifiers.contains(Modifier.publicModifier()));
        mods.put("isPrivate", modifiers.contains(Modifier.privateModifier()));
        mods.put("isProtected", modifiers.contains(Modifier.protectedModifier()));
        mods.put("isStatic", modifiers.contains(Modifier.staticModifier()));
        mods.put("isFinal", modifiers.contains(Modifier.finalModifier()));
        mods.put("isAbstract", modifiers.contains(Modifier.abstractModifier()));
        mods.put("isSynchronized", modifiers.contains(Modifier.synchronizedModifier()));
        mods.put("isNative", modifiers.contains(Modifier.nativeModifier()));
        mods.put("isStrictfp", modifiers.contains(Modifier.strictfpModifier()));
        mods.put("isTransient", modifiers.contains(Modifier.transientModifier()));
        mods.put("isVolatile", modifiers.contains(Modifier.volatileModifier()));
        mods.put("isDefault", modifiers.contains(Modifier.defaultModifier()));
        return mods;
    }

    private static ObjectNode convertAnnotationMember(BodyDeclaration<?> member) {
        if (member instanceof AnnotationMemberDeclaration) {
            AnnotationMemberDeclaration amd = (AnnotationMemberDeclaration) member;
            ObjectNode node = mapper.createObjectNode();
            node.put("kind", "xnkAnnotationMember");
            node.put("name", amd.getNameAsString());
            node.set("type", convertType(amd.getType()));
            amd.getDefaultValue().ifPresent(defaultValue -> 
                node.set("defaultValue", convertExpression(defaultValue)));
            node.set("modifiers", convertModifiers(amd.getModifiers()));
            node.set("annotations", convertAnnotations(amd.getAnnotations()));
            return node;
        }
        return mapper.createObjectNode().put("kind", "xnkUnknown");
    }

    private static ObjectNode convertRecordComponent(RecordDeclaration.RecordComponent component) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkRecordComponent");
        node.put("name", component.getNameAsString());
        node.set("type", convertType(component.getType()));
        node.set("annotations", convertAnnotations(component.getAnnotations()));
        return node;
    }

    // Utility method to handle compilation units with module declarations
    private static ObjectNode handleModuleDeclaration(CompilationUnit cu) {
        ObjectNode root = mapper.createObjectNode();
        root.put("kind", "xnkModule");
        
        cu.getModule().ifPresent(module -> {
            root.put("name", module.getNameAsString());
            root.put("isOpen", module.isOpen());
            
            ArrayNode directives = mapper.createArrayNode();
            module.getDirectives().forEach(directive -> 
                directives.add(convertModuleDirective(directive)));
            root.set("directives", directives);
        });

        return root;
    }

    // Method to handle text blocks (Java 13+)
    private static ObjectNode convertTextBlock(TextBlockLiteralExpr textBlock) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkTextBlockLit");
        node.put("value", textBlock.getValue());
        return node;
    }

    // Method to handle records (Java 14+)
    private static ObjectNode convertRecordDeclaration(RecordDeclaration record) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkRecordDecl");
        node.put("name", record.getNameAsString());

        ArrayNode components = mapper.createArrayNode();
        record.getParameters().forEach(param -> 
            components.add(convertRecordComponent(param)));
        node.set("components", components);

        ArrayNode members = mapper.createArrayNode();
        record.getMembers().forEach(member -> 
            members.add(convertClassMember(member)));
        node.set("members", members);

        node.set("modifiers", convertModifiers(record.getModifiers()));
        node.set("annotations", convertAnnotations(record.getAnnotations()));

        if (record.getImplementedTypes().isNonEmpty()) {
            ArrayNode implementedTypes = mapper.createArrayNode();
            record.getImplementedTypes().forEach(type -> 
                implementedTypes.add(convertType(type)));
            node.set("implementedTypes", implementedTypes);
        }

        return node;
    }

    // Method to handle sealed classes and interfaces (Java 15+)
    private static void handleSealedType(ClassOrInterfaceDeclaration type, ObjectNode node) {
        if (type.isSealed()) {
            node.put("isSealed", true);
            if (type.getPermittedTypes().isPresent()) {
                ArrayNode permittedTypes = mapper.createArrayNode();
                type.getPermittedTypes().get().forEach(t -> 
                    permittedTypes.add(convertType(t)));
                node.set("permittedTypes", permittedTypes);
            }
        }
    }

    // Method to handle pattern matching in instanceof (Java 16+)
    private static ObjectNode convertPatternExpr(PatternExpr pattern) {
        ObjectNode node = mapper.createObjectNode();
        if (pattern instanceof VarPattern) {
            VarPattern varPattern = (VarPattern) pattern;
            node.put("kind", "xnkVarPattern");
            node.put("name", varPattern.getNameAsString());
            node.set("type", convertType(varPattern.getType()));
        } else {
            // Handle future pattern types as they are introduced
            node.put("kind", "xnkUnknownPattern");
        }
        return node;
    }

    // Method to handle switch expressions (Java 12+)
    private static ObjectNode convertSwitchExpr(SwitchExpr switchExpr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkSwitchExpr");
        node.set("selector", convertExpression(switchExpr.getSelector()));
        
        ArrayNode entries = mapper.createArrayNode();
        switchExpr.getEntries().forEach(entry -> {
            ObjectNode entryNode = mapper.createObjectNode();
            if (entry.getLabels().isNonEmpty()) {
                ArrayNode labels = mapper.createArrayNode();
                entry.getLabels().forEach(label -> labels.add(convertExpression(label)));
                entryNode.set("labels", labels);
            } else {
                entryNode.put("isDefault", true);
            }
            entryNode.set("result", convertExpression(entry.getResult()));
            entries.add(entryNode);
        });
        node.set("entries", entries);
        
        return node;
    }

    // Main method for testing
    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            System.out.println("Usage: java ComprehensiveJavaToXLangParser <java_file_path>");
            System.exit(1);
        }

        String filePath = args[0];
        ParseResult<CompilationUnit> parseResult = new JavaParser().parse(new FileInputStream(filePath));
        
        if (parseResult.isSuccessful() && parseResult.getResult().isPresent()) {
            CompilationUnit cu = parseResult.getResult().get();
            ObjectNode xlangAst = convertToXLang(cu);
            System.out.println(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(xlangAst));
        } else {
            System.err.println("Failed to parse Java file: " + filePath);
            parseResult.getProblems().forEach(problem -> 
                System.err.println(problem.getVerboseMessage()));
        }
    }
}