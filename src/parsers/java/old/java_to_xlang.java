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
import java.util.Optional;

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
            parseResult.getProblems().forEach(problem -> 
                System.err.println(problem.getVerboseMessage()));
        }
    }

    private static ObjectNode convertToXLang(CompilationUnit cu) {
        ObjectNode root = mapper.createObjectNode();
        root.put("kind", "xnkFile");
        root.put("fileName", cu.getStorage().map(s -> s.getFileName()).orElse("unknown"));

        cu.getPackageDeclaration().ifPresent(pkg -> 
            root.set("packageDecl", convertPackageDeclaration(pkg)));

        if (cu.getImports().isNonEmpty()) {
            root.set("imports", convertImports(cu.getImports()));
        }

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
        }
        return node;
    }

    private static ObjectNode convertTypeDeclaration(TypeDeclaration<?> type) {
        ObjectNode node = mapper.createObjectNode();

        if (type instanceof ClassOrInterfaceDeclaration) {
            ClassOrInterfaceDeclaration coid = (ClassOrInterfaceDeclaration) type;
            node.put("kind", coid.isInterface() ? "xnkInterfaceDecl" : "xnkClassDecl");
            node.put("name", coid.getNameAsString());

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
                enumMembers.add(memberNode);
            });
            node.set("enumMembers", enumMembers);
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
        node.set("modifiers", convertModifiers(method.getModifiers()));
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
        node.set("modifiers", convertModifiers(field.getModifiers()));
        return node;
    }

    private static ObjectNode convertConstructorDeclaration(ConstructorDeclaration constructor) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkConstructorDecl");
        node.put("name", constructor.getNameAsString());
        node.set("parameters", convertParameters(constructor.getParameters()));
        node.set("body", convertMethodBody(constructor.getBody()));
        node.set("modifiers", convertModifiers(constructor.getModifiers()));
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
        } else if (stmt instanceof ReturnStmt) {
            return convertReturnStatement((ReturnStmt) stmt);
        } else if (stmt instanceof IfStmt) {
            return convertIfStatement((IfStmt) stmt);
        }
        return mapper.createObjectNode().put("kind", "xnkUnknown");
    }

    private static ObjectNode convertReturnStatement(ReturnStmt stmt) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkReturnStmt");
        stmt.getExpression().ifPresent(expr -> 
            node.set("expression", convertExpression(expr)));
        return node;
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

    private static ObjectNode convertExpression(Expression expr) {
        if (expr instanceof BinaryExpr) {
            return convertBinaryExpression((BinaryExpr) expr);
        } else if (expr instanceof MethodCallExpr) {
            return convertMethodCallExpression((MethodCallExpr) expr);
        } else if (expr instanceof NameExpr) {
            return convertNameExpression((NameExpr) expr);
        } else if (expr instanceof LiteralExpr) {
            return convertLiteralExpression((LiteralExpr) expr);
        } else if (expr instanceof LambdaExpr) {
            return convertLambdaExpression((LambdaExpr) expr);
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

    private static ObjectNode convertMethodCallExpression(MethodCallExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkCallExpr");
        node.put("name", expr.getNameAsString());
        ArrayNode arguments = mapper.createArrayNode();
        expr.getArguments().forEach(arg -> arguments.add(convertExpression(arg)));
        node.set("arguments", arguments);
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
        } else if (expr instanceof StringLiteralExpr) {
            node.put("kind", "xnkStringLit");
            node.put("value", ((StringLiteralExpr) expr).asString());
        } else if (expr instanceof BooleanLiteralExpr) {
            node.put("kind", "xnkBoolLit");
            node.put("value", ((BooleanLiteralExpr) expr).getValue());
        }
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

    private static ObjectNode convertType(Type type) {
        ObjectNode node = mapper.createObjectNode();
        if (type.isClassOrInterfaceType()) {
            node.put("kind", "xnkNamedType");
            node.put("name", type.asClassOrInterfaceType().getNameAsString());
        } else if (type.isPrimitiveType()) {
            node.put("kind", "xnkNamedType");
            node.put("name", type.asPrimitiveType().asString());
        } else if (type.isArrayType()) {
            node.put("kind", "xnkArrayType");
            node.set("elementType", convertType(type.asArrayType().getComponentType()));
        }
        return node;
    }

    private static ArrayNode convertTypeParameters(NodeList<TypeParameter> typeParameters) {
        ArrayNode params = mapper.createArrayNode();
        typeParameters.forEach(tp -> {
            ObjectNode param = mapper.createObjectNode();
            param.put("kind", "xnkGenericParameter");
            param.put("name", tp.getNameAsString());
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
            annotationNodes.add(annotationNode);
        });
        return annotationNodes;
    }

    private static ObjectNode convertModifiers(NodeList<Modifier> modifiers) {
        ObjectNode mods = mapper.createObjectNode();
        mods.put("isPublic", modifiers.contains(Modifier.publicModifier()));
        mods.put("isPrivate", modifiers.contains(Modifier.privateModifier()));
        mods.put("isStatic", modifiers.contains(Modifier.staticModifier()));
        mods.put("isFinal", modifiers.contains(Modifier.finalModifier()));
        return mods;
    }
}