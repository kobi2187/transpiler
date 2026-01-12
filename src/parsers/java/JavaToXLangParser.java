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
import java.io.FileWriter;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;

/**
 * Comprehensive Java to XLang Parser
 * Converts Java source code to XLang intermediate representation JSON.
 * Supports all Java language features through Java 24.
 */
public class JavaToXLangParser {
    private static final ObjectMapper mapper = new ObjectMapper();
    private static final Map<String, Integer> statistics = new HashMap<>();
    private static int successCount = 0;
    private static int failCount = 0;
    private static List<String> failedFiles = new ArrayList<>();

    // Binary operator mapping: Java syntax -> XLang semantic operator
    private static final Map<String, String> BINARY_OP_MAP = new HashMap<>();
    static {
        // Arithmetic
        BINARY_OP_MAP.put("+", "add");
        BINARY_OP_MAP.put("-", "sub");
        BINARY_OP_MAP.put("*", "mul");
        BINARY_OP_MAP.put("/", "div");
        BINARY_OP_MAP.put("%", "mod");
        // Bitwise
        BINARY_OP_MAP.put("&", "bitand");
        BINARY_OP_MAP.put("|", "bitor");
        BINARY_OP_MAP.put("^", "bitxor");
        BINARY_OP_MAP.put("<<", "shl");
        BINARY_OP_MAP.put(">>", "shr");
        BINARY_OP_MAP.put(">>>", "shru");
        // Comparison
        BINARY_OP_MAP.put("==", "eq");
        BINARY_OP_MAP.put("!=", "neq");
        BINARY_OP_MAP.put("<", "lt");
        BINARY_OP_MAP.put("<=", "le");
        BINARY_OP_MAP.put(">", "gt");
        BINARY_OP_MAP.put(">=", "ge");
        // Logical
        BINARY_OP_MAP.put("&&", "and");
        BINARY_OP_MAP.put("||", "or");
        // Compound assignment
        BINARY_OP_MAP.put("+=", "adda");
        BINARY_OP_MAP.put("-=", "suba");
        BINARY_OP_MAP.put("*=", "mula");
        BINARY_OP_MAP.put("/=", "diva");
        BINARY_OP_MAP.put("%=", "moda");
        BINARY_OP_MAP.put("&=", "bitanda");
        BINARY_OP_MAP.put("|=", "bitora");
        BINARY_OP_MAP.put("^=", "bitxora");
        BINARY_OP_MAP.put("<<=", "shla");
        BINARY_OP_MAP.put(">>=", "shra");
        BINARY_OP_MAP.put(">>>=", "shrua");
    }

    // Unary operator mapping: Java syntax -> XLang semantic operator
    private static final Map<String, String> UNARY_OP_MAP = new HashMap<>();
    static {
        UNARY_OP_MAP.put("-", "neg");
        UNARY_OP_MAP.put("+", "pos");
        UNARY_OP_MAP.put("!", "not");
        UNARY_OP_MAP.put("~", "bitnot");
        // Increment/decrement handled separately based on prefix/postfix
    }

    private static String mapBinaryOp(String javaOp) {
        return BINARY_OP_MAP.getOrDefault(javaOp, javaOp);
    }

    private static String mapUnaryOp(String javaOp, boolean isPrefix) {
        if (javaOp.equals("++")) {
            return isPrefix ? "preinc" : "postinc";
        } else if (javaOp.equals("--")) {
            return isPrefix ? "predec" : "postdec";
        }
        return UNARY_OP_MAP.getOrDefault(javaOp, javaOp);
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            System.err.println("Usage: java JavaToXLangParser <java_file_or_directory>");
            System.err.println("  For a file: outputs JSON to stdout");
            System.err.println("  For a directory: recursively creates .xljs files next to each .java file");
            System.exit(1);
        }

        String inputPath = args[0];
        File inputFile = new File(inputPath);

        if (!inputFile.exists()) {
            System.err.println("Error: Path not found: " + inputPath);
            System.exit(1);
        }

        if (inputFile.isDirectory()) {
            processDirectory(inputFile);
            printSummary();
        } else {
            processSingleFile(inputFile, true);
        }
    }

    private static void processDirectory(File directory) {
        try {
            Files.walk(directory.toPath())
                .filter(path -> path.toString().endsWith(".java"))
                .forEach(path -> processSingleFile(path.toFile(), false));
        } catch (IOException e) {
            System.err.println("Error walking directory: " + e.getMessage());
        }
    }

    private static void processSingleFile(File javaFile, boolean outputToStdout) {
        String filePath = javaFile.getAbsolutePath();
        try {
            ParseResult<CompilationUnit> parseResult = new JavaParser().parse(new FileInputStream(filePath));

            if (parseResult.isSuccessful() && parseResult.getResult().isPresent()) {
                CompilationUnit cu = parseResult.getResult().get();
                ObjectNode xlangAst = convertToXLang(cu, filePath);
                String json = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(xlangAst);

                if (outputToStdout) {
                    System.out.println(json);
                    printStatistics();
                } else {
                    // Write to .xljs file next to the .java file
                    String xljsPath = filePath.replaceAll("\\.java$", ".xljs");
                    try (FileWriter writer = new FileWriter(xljsPath)) {
                        writer.write(json);
                    }
                    successCount++;
                    System.err.println("OK: " + javaFile.getName());
                }
            } else {
                failCount++;
                failedFiles.add(filePath);
                System.err.println("FAIL: " + javaFile.getName());
                parseResult.getProblems().forEach(problem ->
                    System.err.println("  " + problem.getMessage()));
            }
        } catch (Exception e) {
            failCount++;
            failedFiles.add(filePath);
            System.err.println("FAIL: " + javaFile.getName() + " - " + e.getMessage());
        }
    }

    private static void printStatistics() {
        if (!statistics.isEmpty()) {
            System.err.println("\nJava AST Node Statistics:");
            System.err.println("=========================");
            statistics.entrySet().stream()
                .sorted(Map.Entry.<String, Integer>comparingByKey())
                .forEach(e -> System.err.printf("%-25s: %d%n", e.getKey(), e.getValue()));
            System.err.println("-------------------------");
            System.err.println("Total node types: " + statistics.size());
        }
    }

    private static void printSummary() {
        System.err.println("\n=================================");
        System.err.println("Parse Summary");
        System.err.println("=================================");
        System.err.println("Success: " + successCount);
        System.err.println("Failed:  " + failCount);
        if (!failedFiles.isEmpty()) {
            System.err.println("\nFailed files:");
            failedFiles.forEach(f -> System.err.println("  " + f));
        }
        printStatistics();
    }

    private static void incrementStat(String key) {
        statistics.put(key, statistics.getOrDefault(key, 0) + 1);
    }

    private static ObjectNode convertToXLang(CompilationUnit cu, String filePath) {
        incrementStat("CompilationUnit");
        ObjectNode root = mapper.createObjectNode();
        root.put("kind", "xnkFile");
        root.put("fileName", new File(filePath).getName());

        // Handle package declaration
        cu.getPackageDeclaration().ifPresent(pkg -> {
            incrementStat("PackageDeclaration");
            root.set("packageDecl", convertPackageDeclaration(pkg));
        });

        // Handle imports
        if (cu.getImports().isNonEmpty()) {
            root.set("imports", convertImports(cu.getImports()));
        }

        // Handle module declaration (Java 9+)
        cu.getModule().ifPresent(module -> {
            incrementStat("ModuleDeclaration");
            root.set("moduleDecl", convertModuleDeclaration(module));
        });

        ArrayNode declarations = mapper.createArrayNode();
        cu.getTypes().forEach(type -> declarations.add(convertTypeDeclaration(type)));
        root.set("moduleDecls", declarations);

        return root;
    }

    private static ObjectNode convertPackageDeclaration(PackageDeclaration pkg) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkNamespace");
        node.put("namespaceName", pkg.getNameAsString());
        return node;
    }

    private static ArrayNode convertImports(NodeList<ImportDeclaration> imports) {
        ArrayNode importsArray = mapper.createArrayNode();
        imports.forEach(imp -> {
            incrementStat("ImportDeclaration");
            ObjectNode importNode = mapper.createObjectNode();
            importNode.put("kind", "xnkImport");
            importNode.put("importPath", imp.getNameAsString());
            if (imp.isStatic()) {
                importNode.put("isStatic", true);
            }
            if (imp.isAsterisk()) {
                importNode.put("isWildcard", true);
            }
            importsArray.add(importNode);
        });
        return importsArray;
    }

    private static ObjectNode convertModuleDeclaration(ModuleDeclaration module) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkModule");
        node.put("moduleName", module.getNameAsString());
        node.put("isOpen", module.isOpen());

        ArrayNode directives = mapper.createArrayNode();
        module.getDirectives().forEach(directive ->
            directives.add(convertModuleDirective(directive)));
        node.set("directives", directives);

        return node;
    }

    private static ObjectNode convertModuleDirective(ModuleDirective directive) {
        ObjectNode node = mapper.createObjectNode();
        incrementStat("ModuleDirective");

        if (directive instanceof ModuleRequiresDirective) {
            ModuleRequiresDirective req = (ModuleRequiresDirective) directive;
            node.put("kind", "xnkRequiresDirective");
            node.put("moduleName", req.getNameAsString());
            node.put("isStatic", req.isStatic());
            node.put("isTransitive", req.isTransitive());
        } else if (directive instanceof ModuleExportsDirective) {
            ModuleExportsDirective exp = (ModuleExportsDirective) directive;
            node.put("kind", "xnkExportsDirective");
            node.put("packageName", exp.getNameAsString());
            if (exp.getModuleNames().isNonEmpty()) {
                ArrayNode modules = mapper.createArrayNode();
                exp.getModuleNames().forEach(m -> modules.add(m.asString()));
                node.set("toModules", modules);
            }
        } else if (directive instanceof ModuleOpensDirective) {
            ModuleOpensDirective opens = (ModuleOpensDirective) directive;
            node.put("kind", "xnkOpensDirective");
            node.put("packageName", opens.getNameAsString());
            if (opens.getModuleNames().isNonEmpty()) {
                ArrayNode modules = mapper.createArrayNode();
                opens.getModuleNames().forEach(m -> modules.add(m.asString()));
                node.set("toModules", modules);
            }
        } else if (directive instanceof ModuleUsesDirective) {
            ModuleUsesDirective uses = (ModuleUsesDirective) directive;
            node.put("kind", "xnkUsesDirective");
            node.put("serviceName", uses.getNameAsString());
        } else if (directive instanceof ModuleProvidesDirective) {
            ModuleProvidesDirective provides = (ModuleProvidesDirective) directive;
            node.put("kind", "xnkProvidesDirective");
            node.put("serviceName", provides.getNameAsString());
            ArrayNode implementations = mapper.createArrayNode();
            provides.getWith().forEach(impl -> implementations.add(impl.asString()));
            node.set("implementations", implementations);
        } else {
            node.put("kind", "xnkModuleDirective");
            node.put("directiveType", directive.getClass().getSimpleName());
        }
        return node;
    }

    private static ObjectNode convertTypeDeclaration(TypeDeclaration<?> type) {
        ObjectNode node = mapper.createObjectNode();

        if (type instanceof ClassOrInterfaceDeclaration) {
            ClassOrInterfaceDeclaration coid = (ClassOrInterfaceDeclaration) type;
            incrementStat(coid.isInterface() ? "InterfaceDeclaration" : "ClassDeclaration");
            node.put("kind", coid.isInterface() ? "xnkInterfaceDecl" : "xnkClassDecl");
            node.put("typeNameDecl", coid.getNameAsString());

            // Handle sealed types (Java 17+) - if supported by JavaParser version
            // Note: Not all JavaParser versions support isSealed()
            try {
                java.lang.reflect.Method isSealedMethod = coid.getClass().getMethod("isSealed");
                Boolean isSealed = (Boolean) isSealedMethod.invoke(coid);
                if (isSealed != null && isSealed) {
                    node.put("isSealed", true);
                }
            } catch (Exception e) {
                // Sealed classes not supported in this JavaParser version
            }

            // Base types (extends/implements)
            ArrayNode baseTypes = mapper.createArrayNode();
            coid.getExtendedTypes().forEach(t -> baseTypes.add(convertType(t)));
            coid.getImplementedTypes().forEach(t -> baseTypes.add(convertType(t)));
            if (baseTypes.size() > 0) {
                node.set("baseTypes", baseTypes);
            }

            // Members
            ArrayNode members = mapper.createArrayNode();
            coid.getMembers().forEach(member -> members.add(convertClassMember(member)));
            node.set("members", members);

            // Generic type parameters
            if (coid.getTypeParameters().isNonEmpty()) {
                node.set("typeParameters", convertTypeParameters(coid.getTypeParameters()));
            }

            // Annotations
            if (coid.getAnnotations().isNonEmpty()) {
                node.set("decorators", convertAnnotations(coid.getAnnotations()));
            }

            // Modifiers
            node.set("modifiers", convertModifiers(coid.getModifiers()));

        } else if (type instanceof EnumDeclaration) {
            incrementStat("EnumDeclaration");
            EnumDeclaration enumDecl = (EnumDeclaration) type;
            node.put("kind", "xnkEnumDecl");
            node.put("typeNameDecl", enumDecl.getNameAsString());

            // Enum constants
            ArrayNode enumMembers = mapper.createArrayNode();
            enumDecl.getEntries().forEach(entry -> {
                incrementStat("EnumConstantDeclaration");
                ObjectNode memberNode = mapper.createObjectNode();
                memberNode.put("kind", "xnkEnumMember");
                memberNode.put("enumMemberName", entry.getNameAsString());
                if (entry.getArguments().isNonEmpty()) {
                    ArrayNode args = mapper.createArrayNode();
                    entry.getArguments().forEach(arg -> args.add(convertExpression(arg)));
                    memberNode.set("arguments", args);
                }
                if (entry.getClassBody().isNonEmpty()) {
                    ArrayNode body = mapper.createArrayNode();
                    entry.getClassBody().forEach(member ->
                        body.add(convertClassMember(member)));
                    memberNode.set("classBody", body);
                }
                enumMembers.add(memberNode);
            });
            node.set("enumMembers", enumMembers);

            // Implemented interfaces
            if (enumDecl.getImplementedTypes().isNonEmpty()) {
                ArrayNode interfaces = mapper.createArrayNode();
                enumDecl.getImplementedTypes().forEach(t -> interfaces.add(convertType(t)));
                node.set("implementedTypes", interfaces);
            }

            // Enum methods and fields
            ArrayNode members = mapper.createArrayNode();
            enumDecl.getMembers().forEach(member -> members.add(convertClassMember(member)));
            if (members.size() > 0) {
                node.set("members", members);
            }

        } else if (type instanceof AnnotationDeclaration) {
            incrementStat("AnnotationDeclaration");
            AnnotationDeclaration annDecl = (AnnotationDeclaration) type;
            node.put("kind", "xnkInterfaceDecl");  // Annotations are special interfaces
            node.put("typeNameDecl", annDecl.getNameAsString());
            node.put("isAnnotation", true);

            ArrayNode members = mapper.createArrayNode();
            annDecl.getMembers().forEach(member -> members.add(convertAnnotationMember(member)));
            node.set("members", members);

        } else if (type instanceof RecordDeclaration) {
            incrementStat("RecordDeclaration");
            RecordDeclaration recordDecl = (RecordDeclaration) type;
            node.put("kind", "xnkClassDecl");
            node.put("typeNameDecl", recordDecl.getNameAsString());
            node.put("isRecord", true);

            ArrayNode parameters = mapper.createArrayNode();
            recordDecl.getParameters().forEach(param ->
                parameters.add(convertParameter(param)));
            node.set("recordComponents", parameters);

            ArrayNode members = mapper.createArrayNode();
            recordDecl.getMembers().forEach(member -> members.add(convertClassMember(member)));
            if (members.size() > 0) {
                node.set("members", members);
            }

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
            incrementStat("NestedClassDeclaration");
            return convertTypeDeclaration((ClassOrInterfaceDeclaration) member);
        } else if (member instanceof EnumDeclaration) {
            incrementStat("NestedEnumDeclaration");
            return convertTypeDeclaration((EnumDeclaration) member);
        }
        return mapper.createObjectNode().put("kind", "xnkUnknown");
    }

    private static ObjectNode convertMethodDeclaration(MethodDeclaration method) {
        incrementStat("MethodDeclaration");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkMethodDecl");
        node.put("methodName", method.getNameAsString());

        node.set("mparams", convertParameters(method.getParameters()));
        node.set("mreturnType", convertType(method.getType()));
        method.getBody().ifPresent(body -> node.set("mbody", convertBlockStmt(body)));

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
            node.set("throwsTypes", exceptions);
        }

        return node;
    }

    private static ObjectNode convertFieldDeclaration(FieldDeclaration field) {
        incrementStat("FieldDeclaration");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkFieldDecl");
        node.set("fieldType", convertType(field.getElementType()));

        ArrayNode variables = mapper.createArrayNode();
        field.getVariables().forEach(var -> {
            ObjectNode varNode = mapper.createObjectNode();
            varNode.put("varName", var.getNameAsString());
            var.getInitializer().ifPresent(init ->
                varNode.set("initializer", convertExpression(init)));
            variables.add(varNode);
        });
        node.set("fieldVars", variables);

        if (field.getAnnotations().isNonEmpty()) {
            node.set("decorators", convertAnnotations(field.getAnnotations()));
        }

        node.set("modifiers", convertModifiers(field.getModifiers()));

        return node;
    }

    private static ObjectNode convertConstructorDeclaration(ConstructorDeclaration constructor) {
        incrementStat("ConstructorDeclaration");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkConstructorDecl");
        node.put("constructorName", constructor.getNameAsString());

        node.set("cparams", convertParameters(constructor.getParameters()));
        node.set("cbody", convertBlockStmt(constructor.getBody()));

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
            node.set("throwsTypes", exceptions);
        }

        return node;
    }

    private static ObjectNode convertInitializerDeclaration(InitializerDeclaration initializer) {
        incrementStat("InitializerDeclaration");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkBlockStmt");
        node.put("isStaticInitializer", initializer.isStatic());
        ArrayNode statements = mapper.createArrayNode();
        initializer.getBody().getStatements().forEach(stmt -> statements.add(convertStatement(stmt)));
        node.set("blockBody", statements);
        return node;
    }

    private static ObjectNode convertAnnotationMember(BodyDeclaration<?> member) {
        if (member instanceof AnnotationMemberDeclaration) {
            incrementStat("AnnotationMemberDeclaration");
            AnnotationMemberDeclaration amd = (AnnotationMemberDeclaration) member;
            ObjectNode node = mapper.createObjectNode();
            node.put("kind", "xnkMethodDecl");
            node.put("methodName", amd.getNameAsString());
            node.set("mreturnType", convertType(amd.getType()));
            amd.getDefaultValue().ifPresent(defaultValue ->
                node.set("defaultValue", convertExpression(defaultValue)));
            node.set("modifiers", convertModifiers(amd.getModifiers()));
            if (amd.getAnnotations().isNonEmpty()) {
                node.set("decorators", convertAnnotations(amd.getAnnotations()));
            }
            return node;
        }
        return mapper.createObjectNode().put("kind", "xnkUnknown");
    }

    private static ArrayNode convertParameters(NodeList<Parameter> parameters) {
        ArrayNode params = mapper.createArrayNode();
        parameters.forEach(param -> params.add(convertParameter(param)));
        return params;
    }

    private static ObjectNode convertParameter(Parameter param) {
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkParameter");
        node.put("paramName", param.getNameAsString());
        node.set("paramType", convertType(param.getType()));
        if (param.isVarArgs()) {
            node.put("isVariadic", true);
        }
        if (param.getAnnotations().isNonEmpty()) {
            node.set("decorators", convertAnnotations(param.getAnnotations()));
        }
        return node;
    }

    private static ObjectNode convertBlockStmt(BlockStmt body) {
        incrementStat("BlockStmt");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkBlockStmt");
        ArrayNode statements = mapper.createArrayNode();
        body.getStatements().forEach(stmt -> statements.add(convertStatement(stmt)));
        node.set("blockBody", statements);
        return node;
    }

    // STATEMENT CONVERTERS (22 types)

    private static ObjectNode convertStatement(Statement stmt) {
        if (stmt instanceof ExpressionStmt) {
            incrementStat("ExpressionStmt");
            return convertExpression(((ExpressionStmt) stmt).getExpression());
        } else if (stmt instanceof BlockStmt) {
            return convertBlockStmt((BlockStmt) stmt);
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
        } else if (stmt instanceof EmptyStmt) {
            incrementStat("EmptyStmt");
            return mapper.createObjectNode().put("kind", "xnkEmptyStmt");
        } else if (stmt instanceof ExplicitConstructorInvocationStmt) {
            return convertExplicitConstructorInvocationStmt((ExplicitConstructorInvocationStmt) stmt);
        } else if (stmt instanceof LocalClassDeclarationStmt) {
            return convertLocalClassDeclarationStmt((LocalClassDeclarationStmt) stmt);
        } else if (stmt instanceof LocalRecordDeclarationStmt) {
            return convertLocalRecordDeclarationStmt((LocalRecordDeclarationStmt) stmt);
        } else if (stmt instanceof UnparsableStmt) {
            incrementStat("UnparsableStmt");
            return mapper.createObjectNode().put("kind", "xnkUnknown");
        }
        incrementStat("UnknownStatement");
        return mapper.createObjectNode().put("kind", "xnkUnknown");
    }

    private static ObjectNode convertIfStatement(IfStmt stmt) {
        incrementStat("IfStmt");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkIfStmt");
        node.set("ifCondition", convertExpression(stmt.getCondition()));
        node.set("ifBody", convertStatement(stmt.getThenStmt()));
        stmt.getElseStmt().ifPresent(elseStmt ->
            node.set("elseBody", convertStatement(elseStmt)));
        return node;
    }

    private static ObjectNode convertWhileStatement(WhileStmt stmt) {
        incrementStat("WhileStmt");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkWhileStmt");
        node.set("whileCondition", convertExpression(stmt.getCondition()));
        node.set("whileBody", convertStatement(stmt.getBody()));
        return node;
    }

    private static ObjectNode convertForStatement(ForStmt stmt) {
        incrementStat("ForStmt");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkExternal_ForStmt");
        // Convert init - may be multiple expressions or a single var decl
        if (stmt.getInitialization().isNonEmpty()) {
            if (stmt.getInitialization().size() == 1) {
                node.set("extForInit", convertExpression(stmt.getInitialization().get(0)));
            } else {
                ArrayNode initialization = mapper.createArrayNode();
                stmt.getInitialization().forEach(init -> initialization.add(convertExpression(init)));
                node.set("extForInit", initialization);
            }
        }
        stmt.getCompare().ifPresent(compare ->
            node.set("extForCond", convertExpression(compare)));
        if (stmt.getUpdate().isNonEmpty()) {
            if (stmt.getUpdate().size() == 1) {
                node.set("extForIncrement", convertExpression(stmt.getUpdate().get(0)));
            } else {
                ArrayNode update = mapper.createArrayNode();
                stmt.getUpdate().forEach(upd -> update.add(convertExpression(upd)));
                node.set("extForIncrement", update);
            }
        }
        node.set("extForBody", convertStatement(stmt.getBody()));
        return node;
    }

    private static ObjectNode convertForEachStatement(ForEachStmt stmt) {
        incrementStat("ForEachStmt");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkForeachStmt");
        node.set("foreachVar", convertVariableDeclarationExpr(stmt.getVariable()));
        node.set("foreachIter", convertExpression(stmt.getIterable()));
        node.set("foreachBody", convertStatement(stmt.getBody()));
        return node;
    }

    private static ObjectNode convertDoWhileStatement(DoStmt stmt) {
        incrementStat("DoStmt");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkExternal_DoWhile");
        node.set("extDoWhileBody", convertStatement(stmt.getBody()));
        node.set("extDoWhileCondition", convertExpression(stmt.getCondition()));
        return node;
    }

    private static ObjectNode convertSwitchStatement(SwitchStmt stmt) {
        incrementStat("SwitchStmt");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkSwitchStmt");
        node.set("switchExpr", convertExpression(stmt.getSelector()));
        ArrayNode entries = mapper.createArrayNode();
        stmt.getEntries().forEach(entry -> {
            ObjectNode entryNode = mapper.createObjectNode();
            if (entry.getLabels().isNonEmpty()) {
                entryNode.put("kind", "xnkCaseClause");
                ArrayNode labels = mapper.createArrayNode();
                entry.getLabels().forEach(label -> labels.add(convertExpression(label)));
                entryNode.set("caseValues", labels);
                // Build case body as block
                ObjectNode bodyNode = mapper.createObjectNode();
                bodyNode.put("kind", "xnkBlockStmt");
                ArrayNode statements = mapper.createArrayNode();
                entry.getStatements().forEach(s -> statements.add(convertStatement(s)));
                bodyNode.set("blockBody", statements);
                entryNode.set("caseBody", bodyNode);
                // Java has implicit fallthrough unless break is present
                entryNode.put("caseFallthrough", !hasBreakStatement(entry.getStatements()));
            } else {
                entryNode.put("kind", "xnkDefaultClause");
                ObjectNode bodyNode = mapper.createObjectNode();
                bodyNode.put("kind", "xnkBlockStmt");
                ArrayNode statements = mapper.createArrayNode();
                entry.getStatements().forEach(s -> statements.add(convertStatement(s)));
                bodyNode.set("blockBody", statements);
                entryNode.set("defaultBody", bodyNode);
            }
            entries.add(entryNode);
        });
        node.set("switchCases", entries);
        return node;
    }

    private static boolean hasBreakStatement(NodeList<Statement> statements) {
        for (Statement stmt : statements) {
            if (stmt instanceof BreakStmt) return true;
            if (stmt instanceof BlockStmt) {
                if (hasBreakStatement(((BlockStmt) stmt).getStatements())) return true;
            }
        }
        return false;
    }

    private static ObjectNode convertReturnStatement(ReturnStmt stmt) {
        incrementStat("ReturnStmt");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkReturnStmt");
        stmt.getExpression().ifPresent(expr ->
            node.set("returnExpr", convertExpression(expr)));
        return node;
    }

    private static ObjectNode convertThrowStatement(ThrowStmt stmt) {
        incrementStat("ThrowStmt");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkThrowStmt");
        node.set("throwExpr", convertExpression(stmt.getExpression()));
        return node;
    }

    private static ObjectNode convertTryStatement(TryStmt stmt) {
        incrementStat("TryStmt");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkTryStmt");
        node.set("tryBody", convertBlockStmt(stmt.getTryBlock()));

        ArrayNode catchClauses = mapper.createArrayNode();
        stmt.getCatchClauses().forEach(catchClause -> {
            ObjectNode catchNode = mapper.createObjectNode();
            catchNode.put("kind", "xnkCatchStmt");
            catchNode.set("catchType", convertType(catchClause.getParameter().getType()));
            catchNode.put("catchVar", catchClause.getParameter().getNameAsString());
            catchNode.set("catchBody", convertBlockStmt(catchClause.getBody()));
            catchClauses.add(catchNode);
        });
        node.set("catchClauses", catchClauses);

        stmt.getFinallyBlock().ifPresent(finallyBlock ->
            node.set("finallyBody", convertBlockStmt(finallyBlock)));

        // Try-with-resources (Java 7+)
        if (stmt.getResources().isNonEmpty()) {
            ArrayNode resources = mapper.createArrayNode();
            stmt.getResources().forEach(resource -> {
                ObjectNode resourceNode = mapper.createObjectNode();
                resourceNode.put("kind", "xnkResourceItem");
                resourceNode.set("resourceExpr", convertExpression(resource));
                resources.add(resourceNode);
            });
            node.set("tryResources", resources);
        }

        return node;
    }

    private static ObjectNode convertBreakStatement(BreakStmt stmt) {
        incrementStat("BreakStmt");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkBreakStmt");
        stmt.getLabel().ifPresent(label -> node.put("label", label.asString()));
        return node;
    }

    private static ObjectNode convertContinueStatement(ContinueStmt stmt) {
        incrementStat("ContinueStmt");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkContinueStmt");
        stmt.getLabel().ifPresent(label -> node.put("label", label.asString()));
        return node;
    }

    private static ObjectNode convertLabeledStatement(LabeledStmt stmt) {
        incrementStat("LabeledStmt");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkLabeledStmt");
        node.put("labelName", stmt.getLabel().asString());
        node.set("labeledStmt", convertStatement(stmt.getStatement()));
        return node;
    }

    private static ObjectNode convertAssertStatement(AssertStmt stmt) {
        incrementStat("AssertStmt");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkAssertStmt");
        node.set("assertCond", convertExpression(stmt.getCheck()));
        stmt.getMessage().ifPresent(msg ->
            node.set("assertMsg", convertExpression(msg)));
        return node;
    }

    private static ObjectNode convertSynchronizedStatement(SynchronizedStmt stmt) {
        incrementStat("SynchronizedStmt");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkExternal_Lock");
        node.set("extLockExpr", convertExpression(stmt.getExpression()));
        node.set("extLockBody", convertBlockStmt(stmt.getBody()));
        return node;
    }

    private static ObjectNode convertYieldStatement(YieldStmt stmt) {
        incrementStat("YieldStmt");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkIteratorYield");
        node.set("iteratorYieldValue", convertExpression(stmt.getExpression()));
        return node;
    }

    private static ObjectNode convertExplicitConstructorInvocationStmt(ExplicitConstructorInvocationStmt stmt) {
        incrementStat("ExplicitConstructorInvocationStmt");
        ObjectNode node = mapper.createObjectNode();
        // Use xnkThisCall or xnkBaseCall for constructor chains
        node.put("kind", stmt.isThis() ? "xnkThisCall" : "xnkBaseCall");
        ArrayNode arguments = mapper.createArrayNode();
        stmt.getArguments().forEach(arg -> arguments.add(convertExpression(arg)));
        node.set("arguments", arguments);
        return node;
    }

    private static ObjectNode convertLocalClassDeclarationStmt(LocalClassDeclarationStmt stmt) {
        incrementStat("LocalClassDeclarationStmt");
        return convertTypeDeclaration(stmt.getClassDeclaration());
    }

    private static ObjectNode convertLocalRecordDeclarationStmt(LocalRecordDeclarationStmt stmt) {
        incrementStat("LocalRecordDeclarationStmt");
        return convertTypeDeclaration(stmt.getRecordDeclaration());
    }

    // EXPRESSION CONVERTERS (37+ types)

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
        } else if (expr instanceof ArrayInitializerExpr) {
            ObjectNode node = mapper.createObjectNode();
            node.put("kind", "xnkArrayLiteral");
            node.set("arrayElements", convertArrayInitializerExpression((ArrayInitializerExpr) expr));
            return node;
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
        } else if (expr instanceof ClassExpr) {
            return convertClassExpression((ClassExpr) expr);
        } else if (expr instanceof AnnotationExpr) {
            incrementStat("AnnotationExpr");
            ObjectNode node = mapper.createObjectNode();
            node.put("kind", "xnkDecorator");
            node.put("decoratorName", ((AnnotationExpr) expr).getNameAsString());
            return node;
        }
        incrementStat("UnknownExpression");
        return mapper.createObjectNode().put("kind", "xnkUnknown");
    }

    private static ObjectNode convertBinaryExpression(BinaryExpr expr) {
        incrementStat("BinaryExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkBinaryExpr");
        node.set("binaryLeft", convertExpression(expr.getLeft()));
        node.put("binaryOp", mapBinaryOp(expr.getOperator().asString()));
        node.set("binaryRight", convertExpression(expr.getRight()));
        return node;
    }

    private static ObjectNode convertUnaryExpression(UnaryExpr expr) {
        incrementStat("UnaryExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkUnaryExpr");
        boolean isPrefix = expr.getOperator().isPrefix();
        node.put("unaryOp", mapUnaryOp(expr.getOperator().asString(), isPrefix));
        node.set("unaryOperand", convertExpression(expr.getExpression()));
        return node;
    }

    private static ObjectNode convertMethodCallExpression(MethodCallExpr expr) {
        incrementStat("MethodCallExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkCallExpr");

        // Build callee: either just method name, or receiver.methodName
        if (expr.getScope().isPresent()) {
            ObjectNode calleeNode = mapper.createObjectNode();
            calleeNode.put("kind", "xnkMemberAccessExpr");
            calleeNode.set("memberExpr", convertExpression(expr.getScope().get()));
            calleeNode.put("memberName", expr.getNameAsString());
            node.set("callee", calleeNode);
        } else {
            ObjectNode calleeNode = mapper.createObjectNode();
            calleeNode.put("kind", "xnkIdentifier");
            calleeNode.put("identName", expr.getNameAsString());
            node.set("callee", calleeNode);
        }

        ArrayNode arguments = mapper.createArrayNode();
        expr.getArguments().forEach(arg -> arguments.add(convertExpression(arg)));
        node.set("args", arguments);

        if (expr.getTypeArguments().isPresent()) {
            ArrayNode typeArgs = mapper.createArrayNode();
            expr.getTypeArguments().get().forEach(arg -> typeArgs.add(convertType(arg)));
            node.set("typeArguments", typeArgs);
        }

        return node;
    }

    private static ObjectNode convertFieldAccessExpression(FieldAccessExpr expr) {
        incrementStat("FieldAccessExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkMemberAccessExpr");
        node.set("memberExpr", convertExpression(expr.getScope()));
        node.put("memberName", expr.getNameAsString());
        return node;
    }

    private static ObjectNode convertObjectCreationExpression(ObjectCreationExpr expr) {
        incrementStat("ObjectCreationExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkCallExpr");
        node.put("isNewExpr", true);
        // Callee is the type being constructed
        node.set("callee", convertType(expr.getType()));
        ArrayNode arguments = mapper.createArrayNode();
        expr.getArguments().forEach(arg -> arguments.add(convertExpression(arg)));
        node.set("args", arguments);

        // Anonymous class body
        expr.getAnonymousClassBody().ifPresent(body -> {
            ArrayNode anonymousBody = mapper.createArrayNode();
            body.forEach(member -> anonymousBody.add(convertClassMember(member)));
            node.set("anonymousClassBody", anonymousBody);
        });

        return node;
    }

    private static ObjectNode convertLambdaExpression(LambdaExpr expr) {
        incrementStat("LambdaExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkLambdaExpr");
        ArrayNode parameters = mapper.createArrayNode();
        expr.getParameters().forEach(param -> {
            ObjectNode paramNode = mapper.createObjectNode();
            paramNode.put("paramName", param.getNameAsString());
            if (param.getType() != null) {
                paramNode.set("paramType", convertType(param.getType()));
            }
            parameters.add(paramNode);
        });
        node.set("lambdaParams", parameters);

        if (expr.getBody().isBlockStmt()) {
            node.set("lambdaBody", convertBlockStmt(expr.getBody().asBlockStmt()));
        } else if (expr.getBody().isExpressionStmt()) {
            node.set("lambdaBody", convertExpression(expr.getBody().asExpressionStmt().getExpression()));
        }
        return node;
    }

    private static ObjectNode convertNameExpression(NameExpr expr) {
        incrementStat("NameExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkIdentifier");
        node.put("identName", expr.getNameAsString());
        return node;
    }

    private static ObjectNode convertLiteralExpression(LiteralExpr expr) {
        ObjectNode node = mapper.createObjectNode();
        if (expr instanceof IntegerLiteralExpr) {
            incrementStat("IntegerLiteralExpr");
            node.put("kind", "xnkIntLit");
            node.put("literalValue", ((IntegerLiteralExpr) expr).asNumber().toString());
        } else if (expr instanceof LongLiteralExpr) {
            incrementStat("LongLiteralExpr");
            node.put("kind", "xnkIntLit");
            node.put("literalValue", ((LongLiteralExpr) expr).asNumber().toString());
        } else if (expr instanceof DoubleLiteralExpr) {
            incrementStat("DoubleLiteralExpr");
            node.put("kind", "xnkFloatLit");
            node.put("literalValue", String.valueOf(((DoubleLiteralExpr) expr).asDouble()));
        } else if (expr instanceof StringLiteralExpr) {
            incrementStat("StringLiteralExpr");
            node.put("kind", "xnkStringLit");
            node.put("literalValue", ((StringLiteralExpr) expr).asString());
        } else if (expr instanceof CharLiteralExpr) {
            incrementStat("CharLiteralExpr");
            node.put("kind", "xnkCharLit");
            node.put("literalValue", String.valueOf(((CharLiteralExpr) expr).asChar()));
        } else if (expr instanceof BooleanLiteralExpr) {
            incrementStat("BooleanLiteralExpr");
            node.put("kind", "xnkBoolLit");
            node.put("boolValue", ((BooleanLiteralExpr) expr).getValue());
        } else if (expr instanceof NullLiteralExpr) {
            incrementStat("NullLiteralExpr");
            node.put("kind", "xnkNilLit");
        } else if (expr instanceof TextBlockLiteralExpr) {
            incrementStat("TextBlockLiteralExpr");
            node.put("kind", "xnkStringLit");
            node.put("literalValue", ((TextBlockLiteralExpr) expr).getValue());
            node.put("isTextBlock", true);
        }
        return node;
    }

    private static ObjectNode convertCastExpression(CastExpr expr) {
        incrementStat("CastExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkCastExpr");
        node.set("castType", convertType(expr.getType()));
        node.set("castExpr", convertExpression(expr.getExpression()));
        return node;
    }

    private static ObjectNode convertInstanceOfExpression(InstanceOfExpr expr) {
        incrementStat("InstanceOfExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkBinaryExpr");
        node.put("binaryOp", "istype");  // semantic operator for type check
        node.set("binaryLeft", convertExpression(expr.getExpression()));
        node.set("binaryRight", convertType(expr.getType()));

        // Pattern matching (Java 16+) - if supported
        try {
            java.util.Optional<?> pattern = (java.util.Optional<?>) expr.getClass().getMethod("getPattern").invoke(expr);
            if (pattern.isPresent()) {
                node.put("hasPattern", true);
            }
        } catch (Exception e) {
            // Pattern matching not supported in this JavaParser version
        }

        return node;
    }

    private static ObjectNode convertConditionalExpression(ConditionalExpr expr) {
        incrementStat("ConditionalExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkExternal_Ternary");
        node.set("extTernaryCondition", convertExpression(expr.getCondition()));
        node.set("extTernaryThen", convertExpression(expr.getThenExpr()));
        node.set("extTernaryElse", convertExpression(expr.getElseExpr()));
        return node;
    }

    private static ObjectNode convertAssignExpression(AssignExpr expr) {
        incrementStat("AssignExpr");
        String operator = expr.getOperator().asString();

        if (operator.equals("=")) {
            ObjectNode node = mapper.createObjectNode();
            node.put("kind", "xnkAsgn");
            node.set("asgnLeft", convertExpression(expr.getTarget()));
            node.set("asgnRight", convertExpression(expr.getValue()));
            return node;
        } else {
            // Compound assignment like +=, -=, etc. → model as xnkAsgn with binary expr
            // e.g., x += 1 → x = x + 1
            ObjectNode node = mapper.createObjectNode();
            node.put("kind", "xnkAsgn");
            node.set("asgnLeft", convertExpression(expr.getTarget()));
            // Build the binary expr: target op value
            ObjectNode binExpr = mapper.createObjectNode();
            binExpr.put("kind", "xnkBinaryExpr");
            binExpr.set("binaryLeft", convertExpression(expr.getTarget()));
            // Map compound operator to base operator
            String baseOp = operator.substring(0, operator.length() - 1); // remove '='
            binExpr.put("binaryOp", mapBinaryOp(baseOp));
            binExpr.set("binaryRight", convertExpression(expr.getValue()));
            node.set("asgnRight", binExpr);
            return node;
        }
    }

    private static ObjectNode convertArrayCreationExpression(ArrayCreationExpr expr) {
        incrementStat("ArrayCreationExpr");
        ObjectNode node = mapper.createObjectNode();
        // Use xnkCallExpr with isNewExpr for array creation with dimensions
        // Use xnkArrayLiteral for initializer-based creation
        if (expr.getInitializer().isPresent()) {
            node.put("kind", "xnkArrayLiteral");
            node.set("elements", convertArrayInitializerExpression(expr.getInitializer().get()));
        } else {
            // Array creation with dimensions: new int[5]
            node.put("kind", "xnkCallExpr");
            node.put("isNewExpr", true);
            node.put("isArrayCreation", true);
            ObjectNode arrayType = mapper.createObjectNode();
            arrayType.put("kind", "xnkArrayType");
            arrayType.set("elementType", convertType(expr.getElementType()));
            node.set("callee", arrayType);
            ArrayNode dimensions = mapper.createArrayNode();
            expr.getLevels().forEach(level -> {
                level.getDimension().ifPresent(dim -> dimensions.add(convertExpression(dim)));
            });
            node.set("args", dimensions);
        }
        return node;
    }

    private static ArrayNode convertArrayInitializerExpression(ArrayInitializerExpr expr) {
        incrementStat("ArrayInitializerExpr");
        ArrayNode values = mapper.createArrayNode();
        expr.getValues().forEach(value -> values.add(convertExpression(value)));
        return values;
    }

    private static ObjectNode convertArrayAccessExpression(ArrayAccessExpr expr) {
        incrementStat("ArrayAccessExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkIndexExpr");
        node.set("indexExpr", convertExpression(expr.getName()));
        ArrayNode args = mapper.createArrayNode();
        args.add(convertExpression(expr.getIndex()));
        node.set("indexArgs", args);
        return node;
    }

    private static ObjectNode convertEnclosedExpression(EnclosedExpr expr) {
        incrementStat("EnclosedExpr");
        // Parentheses are transparent in XLang
        return convertExpression(expr.getInner());
    }

    private static ObjectNode convertMethodReferenceExpression(MethodReferenceExpr expr) {
        incrementStat("MethodReferenceExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkMethodReference");
        node.set("refObject", convertExpression(expr.getScope()));
        node.put("refMethod", expr.getIdentifier());
        return node;
    }

    private static ObjectNode convertThisExpression(ThisExpr expr) {
        incrementStat("ThisExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkThisExpr");
        expr.getTypeName().ifPresent(typeName ->
            node.put("thisType", typeName.asString()));
        return node;
    }

    private static ObjectNode convertSuperExpression(SuperExpr expr) {
        incrementStat("SuperExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkBaseExpr");
        expr.getTypeName().ifPresent(typeName ->
            node.put("baseType", typeName.asString()));
        return node;
    }

    private static ObjectNode convertTypeExpression(TypeExpr expr) {
        incrementStat("TypeExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkTypeExpr");
        node.set("typeExpr", convertType(expr.getType()));
        return node;
    }

    private static ObjectNode convertClassExpression(ClassExpr expr) {
        incrementStat("ClassExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkTypeOfExpr");
        node.set("typeofType", convertType(expr.getType()));
        return node;
    }

    private static ObjectNode convertVariableDeclarationExpr(VariableDeclarationExpr expr) {
        incrementStat("VariableDeclarationExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkVarDecl");

        ArrayNode variables = mapper.createArrayNode();
        expr.getVariables().forEach(var -> {
            ObjectNode varNode = mapper.createObjectNode();
            varNode.put("varName", var.getNameAsString());
            varNode.set("varType", convertType(var.getType()));
            var.getInitializer().ifPresent(init ->
                varNode.set("varInit", convertExpression(init)));
            variables.add(varNode);
        });
        node.set("varDecls", variables);

        if (expr.getAnnotations().isNonEmpty()) {
            node.set("decorators", convertAnnotations(expr.getAnnotations()));
        }

        node.set("modifiers", convertModifiers(expr.getModifiers()));

        return node;
    }

    private static ObjectNode convertSwitchExpression(SwitchExpr expr) {
        incrementStat("SwitchExpr");
        ObjectNode node = mapper.createObjectNode();
        node.put("kind", "xnkSwitchExpr");
        node.set("switchExprValue", convertExpression(expr.getSelector()));

        ArrayNode arms = mapper.createArrayNode();
        expr.getEntries().forEach(entry -> {
            ObjectNode armNode = mapper.createObjectNode();
            armNode.put("kind", "xnkSwitchArm");
            if (entry.getLabels().isNonEmpty()) {
                ArrayNode labels = mapper.createArrayNode();
                entry.getLabels().forEach(label -> labels.add(convertExpression(label)));
                armNode.set("armPatterns", labels);
            } else {
                armNode.put("isDefault", true);
            }
            // Handle switch expression body
            ArrayNode statements = mapper.createArrayNode();
            entry.getStatements().forEach(s -> statements.add(convertStatement(s)));
            armNode.set("armBody", statements);
            arms.add(armNode);
        });
        node.set("switchExprArms", arms);

        return node;
    }

    // TYPE CONVERTERS

    private static ObjectNode convertType(Type type) {
        ObjectNode node = mapper.createObjectNode();
        if (type.isClassOrInterfaceType()) {
            ClassOrInterfaceType cit = type.asClassOrInterfaceType();
            node.put("kind", "xnkNamedType");
            node.put("typeName", cit.getNameAsString());
            if (cit.getTypeArguments().isPresent()) {
                ArrayNode typeArgs = mapper.createArrayNode();
                cit.getTypeArguments().get().forEach(arg -> typeArgs.add(convertType(arg)));
                node.set("typeArgs", typeArgs);
            }
        } else if (type.isPrimitiveType()) {
            node.put("kind", "xnkNamedType");
            node.put("typeName", type.asPrimitiveType().asString());
        } else if (type.isVoidType()) {
            node.put("kind", "xnkNamedType");
            node.put("typeName", "void");
        } else if (type.isArrayType()) {
            node.put("kind", "xnkArrayType");
            node.set("arrayElementType", convertType(type.asArrayType().getComponentType()));
        } else if (type.isWildcardType()) {
            WildcardType wt = type.asWildcardType();
            node.put("kind", "xnkWildcardType");
            wt.getExtendedType().ifPresent(ext ->
                node.set("upperBound", convertType(ext)));
            wt.getSuperType().ifPresent(sup ->
                node.set("lowerBound", convertType(sup)));
        } else if (type.isUnionType()) {
            node.put("kind", "xnkUnionType");
            ArrayNode unionTypes = mapper.createArrayNode();
            type.asUnionType().getElements().forEach(elem -> unionTypes.add(convertType(elem)));
            node.set("unionTypes", unionTypes);
        } else if (type.isIntersectionType()) {
            node.put("kind", "xnkIntersectionType");
            ArrayNode intersectionTypes = mapper.createArrayNode();
            type.asIntersectionType().getElements().forEach(elem -> intersectionTypes.add(convertType(elem)));
            node.set("intersectionTypes", intersectionTypes);
        } else if (type.isTypeParameter()) {
            node.put("kind", "xnkNamedType");
            node.put("typeName", type.asTypeParameter().getNameAsString());
            node.put("isTypeParameter", true);
        } else if (type.isVarType()) {
            node.put("kind", "xnkNamedType");
            node.put("typeName", "var");
            node.put("isInferred", true);
        }
        return node;
    }

    private static ArrayNode convertTypeParameters(NodeList<TypeParameter> typeParameters) {
        ArrayNode params = mapper.createArrayNode();
        typeParameters.forEach(tp -> {
            ObjectNode param = mapper.createObjectNode();
            param.put("kind", "xnkGenericParameter");
            param.put("genericParamName", tp.getNameAsString());
            if (tp.getTypeBound().isNonEmpty()) {
                ArrayNode bounds = mapper.createArrayNode();
                tp.getTypeBound().forEach(bound -> bounds.add(convertType(bound)));
                param.set("genericBounds", bounds);
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
            annotationNode.put("decoratorName", ann.getNameAsString());

            if (ann instanceof NormalAnnotationExpr) {
                ArrayNode pairs = mapper.createArrayNode();
                ((NormalAnnotationExpr) ann).getPairs().forEach(pair -> {
                    ObjectNode pairNode = mapper.createObjectNode();
                    pairNode.put("key", pair.getNameAsString());
                    pairNode.set("value", convertExpression(pair.getValue()));
                    pairs.add(pairNode);
                });
                annotationNode.set("decoratorArgs", pairs);
            } else if (ann instanceof SingleMemberAnnotationExpr) {
                ArrayNode args = mapper.createArrayNode();
                args.add(convertExpression(((SingleMemberAnnotationExpr) ann).getMemberValue()));
                annotationNode.set("decoratorArgs", args);
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
        // Check if defaultModifier exists in this version
        try {
            java.lang.reflect.Method defaultModifierMethod = Modifier.class.getMethod("defaultModifier");
            Modifier defaultMod = (Modifier) defaultModifierMethod.invoke(null);
            mods.put("isDefault", modifiers.contains(defaultMod));
        } catch (Exception e) {
            mods.put("isDefault", false);
        }
        return mods;
    }
}
