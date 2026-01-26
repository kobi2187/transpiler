package transpiler.kotlin

import org.jetbrains.kotlin.cli.common.CLIConfigurationKeys
import org.jetbrains.kotlin.cli.common.messages.MessageCollector
import org.jetbrains.kotlin.cli.jvm.compiler.EnvironmentConfigFiles
import org.jetbrains.kotlin.cli.jvm.compiler.KotlinCoreEnvironment
import org.jetbrains.kotlin.com.intellij.openapi.util.Disposer
import org.jetbrains.kotlin.com.intellij.psi.PsiElement
import org.jetbrains.kotlin.config.CompilerConfiguration
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*
import org.jetbrains.kotlin.psi.psiUtil.getChildrenOfType
import kotlinx.serialization.json.*
import java.io.File

/**
 * Comprehensive Kotlin to XLang Parser
 * Converts Kotlin source code to XLang intermediate representation JSON.
 * Uses Kotlin's PSI (Program Structure Interface) for accurate parsing.
 * Supports all Kotlin language features.
 */
class KotlinToXLangParser {
    private val statistics = mutableMapOf<String, Int>()

    companion object {
        @JvmStatic
        fun main(args: Array<String>) {
            if (args.isEmpty()) {
                System.err.println("Usage: kotlin KotlinToXLangParser <kotlin_file_path>")
                System.exit(1)
            }

            val filePath = args[0]
            val file = File(filePath)

            if (!file.exists()) {
                System.err.println("Error: File not found: $filePath")
                System.exit(1)
            }

            val parser = KotlinToXLangParser()
            val json = parser.parseFile(file)
            println(json)

            // Print statistics to stderr
            parser.printStatistics()
        }
    }

    private fun incrementStat(key: String) {
        statistics[key] = statistics.getOrDefault(key, 0) + 1
    }

    private fun printStatistics() {
        if (statistics.isNotEmpty()) {
            System.err.println("\nKotlin AST Node Statistics:")
            System.err.println("============================")
            statistics.entries.sortedBy { it.key }.forEach { (key, count) ->
                System.err.println("${key.padEnd(35)}: $count")
            }
            System.err.println("----------------------------")
            System.err.println("Total node types: ${statistics.size}")
        }
    }

    fun parseFile(file: File): String {
        val disposable = Disposer.newDisposable()
        try {
            val configuration = CompilerConfiguration().apply {
                put(CLIConfigurationKeys.MESSAGE_COLLECTOR_KEY, MessageCollector.NONE)
            }

            val environment = KotlinCoreEnvironment.createForProduction(
                disposable,
                configuration,
                EnvironmentConfigFiles.JVM_CONFIG_FILES
            )

            val psiFactory = KtPsiFactory(environment.project)
            val ktFile = psiFactory.createFile(file.name, file.readText())

            val xlangAst = convertFile(ktFile, file.name)
            return Json { prettyPrint = true }.encodeToString(JsonObject.serializer(), xlangAst)
        } finally {
            Disposer.dispose(disposable)
        }
    }

    // ============================================================================
    // FILE & TOP-LEVEL CONVERSION
    // ============================================================================

    private fun convertFile(ktFile: KtFile, fileName: String): JsonObject {
        incrementStat("KtFile")
        return buildJsonObject {
            put("kind", "xnkFile")
            put("fileName", fileName)
            put("sourceLang", "kotlin")

            // Package declaration
            ktFile.packageDirective?.let { pkg ->
                if (pkg.fqName.asString().isNotEmpty()) {
                    incrementStat("PackageDirective")
                    put("packageDecl", buildJsonObject {
                        put("kind", "xnkNamespace")
                        put("namespaceName", pkg.fqName.asString())
                    })
                }
            }

            // Imports
            val imports = ktFile.importDirectives
            if (imports.isNotEmpty()) {
                putJsonArray("imports") {
                    imports.forEach { imp ->
                        add(convertImport(imp))
                    }
                }
            }

            // Top-level declarations
            putJsonArray("moduleDecls") {
                ktFile.declarations.forEach { decl ->
                    add(convertDeclaration(decl))
                }
            }
        }
    }

    private fun convertImport(import: KtImportDirective): JsonObject {
        incrementStat("KtImportDirective")
        return buildJsonObject {
            put("kind", "xnkImport")
            put("importPath", import.importedFqName?.asString() ?: "")
            import.aliasName?.let { put("importAlias", it) }
            if (import.isAllUnder) {
                put("isWildcard", true)
            }
        }
    }

    // ============================================================================
    // DECLARATION CONVERSION
    // ============================================================================

    private fun convertDeclaration(decl: KtDeclaration): JsonObject {
        return when (decl) {
            is KtClass -> convertClass(decl)
            is KtObjectDeclaration -> convertObject(decl)
            is KtNamedFunction -> convertFunction(decl)
            is KtProperty -> convertProperty(decl)
            is KtTypeAlias -> convertTypeAlias(decl)
            is KtDestructuringDeclaration -> convertDestructuringDeclaration(decl)
            is KtScript -> convertScript(decl)
            is KtClassInitializer -> convertClassInitializer(decl)
            is KtSecondaryConstructor -> convertSecondaryConstructor(decl)
            is KtEnumEntry -> convertEnumEntry(decl)
            else -> {
                incrementStat("UnknownDeclaration_${decl::class.simpleName}")
                buildJsonObject {
                    put("kind", "xnkUnknown")
                    put("unknownData", "Unknown declaration: ${decl::class.simpleName}")
                }
            }
        }
    }

    private fun convertClass(cls: KtClass): JsonObject {
        val kind = when {
            cls.isInterface() -> {
                incrementStat("KtInterface")
                "xnkInterfaceDecl"
            }
            cls.isEnum() -> {
                incrementStat("KtEnumClass")
                "xnkEnumDecl"
            }
            cls.isAnnotation() -> {
                incrementStat("KtAnnotationClass")
                "xnkInterfaceDecl" // Annotations are special interfaces
            }
            else -> {
                incrementStat("KtClass")
                "xnkClassDecl"
            }
        }

        return buildJsonObject {
            put("kind", kind)

            if (kind == "xnkEnumDecl") {
                put("enumName", cls.name ?: "")
                putJsonArray("enumMembers") {
                    cls.declarations.filterIsInstance<KtEnumEntry>().forEach { entry ->
                        add(convertEnumEntry(entry))
                    }
                }
                // Non-enum members
                val nonEnumMembers = cls.declarations.filter { it !is KtEnumEntry }
                if (nonEnumMembers.isNotEmpty()) {
                    putJsonArray("members") {
                        nonEnumMembers.forEach { add(convertDeclaration(it)) }
                    }
                }
            } else {
                put("typeNameDecl", cls.name ?: "")

                // Base types (superclass and interfaces)
                val baseTypes = mutableListOf<JsonObject>()
                cls.superTypeListEntries.forEach { entry ->
                    baseTypes.add(convertSuperTypeEntry(entry))
                }
                if (baseTypes.isNotEmpty()) {
                    putJsonArray("baseTypes") {
                        baseTypes.forEach { add(it) }
                    }
                }

                // Members
                putJsonArray("members") {
                    // Primary constructor
                    cls.primaryConstructor?.let { add(convertPrimaryConstructor(it, cls)) }

                    // Class body declarations
                    cls.body?.declarations?.forEach { member ->
                        add(convertDeclaration(member))
                    }
                }
            }

            // Type parameters
            if (cls.typeParameters.isNotEmpty()) {
                putJsonArray("typeParameters") {
                    cls.typeParameters.forEach { add(convertTypeParameter(it)) }
                }
            }

            // Annotations
            val annotations = cls.annotationEntries
            if (annotations.isNotEmpty()) {
                putJsonArray("decorators") {
                    annotations.forEach { add(convertAnnotation(it)) }
                }
            }

            // Modifiers
            put("modifiers", convertModifiers(cls))

            // Kotlin-specific class modifiers
            if (cls.isData()) put("isData", true)
            if (cls.isSealed()) put("isSealed", true)
            if (cls.isInner()) put("isInner", true)
            if (cls.isValue()) put("isValue", true)
            if (cls.hasModifier(KtTokens.INLINE_KEYWORD)) put("isInline", true)
            if (cls.hasModifier(KtTokens.ABSTRACT_KEYWORD)) put("isAbstract", true)
            if (cls.hasModifier(KtTokens.OPEN_KEYWORD)) put("isOpen", true)
        }
    }

    private fun convertObject(obj: KtObjectDeclaration): JsonObject {
        incrementStat("KtObjectDeclaration")
        return buildJsonObject {
            put("kind", "xnkClassDecl")
            put("typeNameDecl", obj.name ?: "")
            put("isObject", true)

            if (obj.isCompanion()) {
                put("isCompanion", true)
            }

            // Base types
            val baseTypes = mutableListOf<JsonObject>()
            obj.superTypeListEntries.forEach { entry ->
                baseTypes.add(convertSuperTypeEntry(entry))
            }
            if (baseTypes.isNotEmpty()) {
                putJsonArray("baseTypes") {
                    baseTypes.forEach { add(it) }
                }
            }

            // Members
            putJsonArray("members") {
                obj.body?.declarations?.forEach { member ->
                    add(convertDeclaration(member))
                }
            }

            // Annotations
            val annotations = obj.annotationEntries
            if (annotations.isNotEmpty()) {
                putJsonArray("decorators") {
                    annotations.forEach { add(convertAnnotation(it)) }
                }
            }

            put("modifiers", convertModifiers(obj))
        }
    }

    private fun convertPrimaryConstructor(ctor: KtPrimaryConstructor, cls: KtClass): JsonObject {
        incrementStat("KtPrimaryConstructor")
        return buildJsonObject {
            put("kind", "xnkConstructorDecl")
            put("isPrimary", true)

            putJsonArray("cparams") {
                ctor.valueParameters.forEach { param ->
                    add(convertParameter(param, isConstructorParam = true))
                }
            }

            // Constructor body is the init blocks
            val initBlocks = cls.body?.declarations?.filterIsInstance<KtClassInitializer>() ?: emptyList()
            if (initBlocks.isNotEmpty()) {
                put("cbody", buildJsonObject {
                    put("kind", "xnkBlockStmt")
                    putJsonArray("blockBody") {
                        initBlocks.forEach { init ->
                            add(convertBlockExpression(init.body as? KtBlockExpression))
                        }
                    }
                })
            } else {
                put("cbody", buildJsonObject {
                    put("kind", "xnkBlockStmt")
                    putJsonArray("blockBody") { }
                })
            }

            // Annotations
            val annotations = ctor.annotationEntries
            if (annotations.isNotEmpty()) {
                putJsonArray("decorators") {
                    annotations.forEach { add(convertAnnotation(it)) }
                }
            }

            put("modifiers", convertModifiers(ctor))
        }
    }

    private fun convertSecondaryConstructor(ctor: KtSecondaryConstructor): JsonObject {
        incrementStat("KtSecondaryConstructor")
        return buildJsonObject {
            put("kind", "xnkConstructorDecl")
            put("isPrimary", false)

            putJsonArray("cparams") {
                ctor.valueParameters.forEach { param ->
                    add(convertParameter(param))
                }
            }

            // Delegation call (this/super)
            ctor.getDelegationCall()?.let { delegation ->
                putJsonArray("constructorInitializers") {
                    add(buildJsonObject {
                        put("kind", if (delegation.isCallToThis) "xnkThisCall" else "xnkBaseCall")
                        putJsonArray("arguments") {
                            delegation.valueArguments.forEach { arg ->
                                add(convertValueArgument(arg))
                            }
                        }
                    })
                }
            }

            // Body
            ctor.bodyExpression?.let { body ->
                put("cbody", convertBlockExpression(body as? KtBlockExpression))
            } ?: put("cbody", buildJsonObject {
                put("kind", "xnkBlockStmt")
                putJsonArray("blockBody") { }
            })

            put("modifiers", convertModifiers(ctor))
        }
    }

    private fun convertClassInitializer(init: KtClassInitializer): JsonObject {
        incrementStat("KtClassInitializer")
        return buildJsonObject {
            put("kind", "xnkBlockStmt")
            put("isStaticInitializer", false)
            (init.body as? KtBlockExpression)?.let { block ->
                putJsonArray("blockStmts") {
                    block.statements.forEach { stmt ->
                        add(convertExpression(stmt))
                    }
                }
            }
        }
    }

    private fun convertEnumEntry(entry: KtEnumEntry): JsonObject {
        incrementStat("KtEnumEntry")
        return buildJsonObject {
            put("kind", "xnkEnumMember")
            put("enumMemberName", entry.name ?: "")

            // Constructor arguments
            val args = entry.initializerList?.initializers
            if (!args.isNullOrEmpty()) {
                putJsonArray("arguments") {
                    args.filterIsInstance<KtSuperTypeCallEntry>().forEach { call ->
                        call.valueArguments.forEach { arg ->
                            add(convertValueArgument(arg))
                        }
                    }
                }
            }

            // Enum entry body
            entry.body?.let { body ->
                putJsonArray("classBody") {
                    body.declarations.forEach { decl ->
                        add(convertDeclaration(decl))
                    }
                }
            }
        }
    }

    private fun convertFunction(func: KtNamedFunction): JsonObject {
        incrementStat("KtNamedFunction")

        // Check if it's an extension function
        val isExtension = func.receiverTypeReference != null

        return buildJsonObject {
            if (isExtension) {
                put("kind", "xnkExternal_ExtensionMethod")
                put("extExtMethodName", func.name ?: "")

                // Parameters including receiver
                putJsonArray("extExtMethodParams") {
                    // First param is the receiver type
                    add(buildJsonObject {
                        put("kind", "xnkParameter")
                        put("paramName", "this")
                        put("paramType", convertTypeReference(func.receiverTypeReference!!))
                        put("isReceiver", true)
                    })
                    func.valueParameters.forEach { param ->
                        add(convertParameter(param))
                    }
                }

                // Return type
                func.typeReference?.let {
                    put("extExtMethodReturnType", convertTypeReference(it))
                }

                // Body
                func.bodyExpression?.let { body ->
                    put("extExtMethodBody", convertFunctionBody(body))
                }

                put("extExtMethodIsStatic", true)
                put("extExtMethodVisibility", getVisibility(func))
            } else {
                put("kind", "xnkFuncDecl")
                put("funcName", func.name ?: "")

                putJsonArray("params") {
                    func.valueParameters.forEach { param ->
                        add(convertParameter(param))
                    }
                }

                func.typeReference?.let {
                    put("returnType", convertTypeReference(it))
                }

                func.bodyExpression?.let { body ->
                    put("body", convertFunctionBody(body))
                }

                put("funcIsStatic", func.hasModifier(KtTokens.COMPANION_KEYWORD) || !func.isTopLevel)
                put("funcVisibility", getVisibility(func))
            }

            // Type parameters
            if (func.typeParameters.isNotEmpty()) {
                putJsonArray("typeParameters") {
                    func.typeParameters.forEach { add(convertTypeParameter(it)) }
                }
            }

            // Annotations
            val annotations = func.annotationEntries
            if (annotations.isNotEmpty()) {
                putJsonArray("decorators") {
                    annotations.forEach { add(convertAnnotation(it)) }
                }
            }

            put("modifiers", convertModifiers(func))

            // Kotlin-specific
            if (func.hasModifier(KtTokens.SUSPEND_KEYWORD)) put("isAsync", true)
            if (func.hasModifier(KtTokens.INLINE_KEYWORD)) put("isInline", true)
            if (func.hasModifier(KtTokens.INFIX_KEYWORD)) put("isInfix", true)
            if (func.hasModifier(KtTokens.OPERATOR_KEYWORD)) put("isOperator", true)
            if (func.hasModifier(KtTokens.TAILREC_KEYWORD)) put("isTailrec", true)
            if (func.hasModifier(KtTokens.EXTERNAL_KEYWORD)) put("isExternal", true)
        }
    }

    private fun convertFunctionBody(body: KtExpression): JsonObject {
        return when (body) {
            is KtBlockExpression -> convertBlockExpression(body)
            else -> {
                // Expression body: fun foo() = expr
                buildJsonObject {
                    put("kind", "xnkBlockStmt")
                    putJsonArray("blockBody") {
                        add(buildJsonObject {
                            put("kind", "xnkReturnStmt")
                            put("returnExpr", convertExpression(body))
                        })
                    }
                }
            }
        }
    }

    private fun convertProperty(prop: KtProperty): JsonObject {
        incrementStat("KtProperty")

        // Check if it's an extension property
        val isExtension = prop.receiverTypeReference != null

        if (isExtension) {
            return buildJsonObject {
                put("kind", "xnkExternal_Property")
                put("extPropName", prop.name ?: "")

                prop.typeReference?.let {
                    put("extPropType", convertTypeReference(it))
                }

                // Getter
                prop.getter?.let { getter ->
                    put("extPropGetter", convertPropertyAccessor(getter))
                }

                // Setter
                prop.setter?.let { setter ->
                    put("extPropSetter", convertPropertyAccessor(setter))
                }

                put("isExtension", true)
                put("receiverType", convertTypeReference(prop.receiverTypeReference!!))
            }
        }

        // Check if it has custom accessors (property)
        val hasCustomAccessors = prop.getter != null || prop.setter != null

        if (hasCustomAccessors) {
            return buildJsonObject {
                put("kind", "xnkExternal_Property")
                put("extPropName", prop.name ?: "")

                prop.typeReference?.let {
                    put("extPropType", convertTypeReference(it))
                }

                prop.getter?.let { getter ->
                    put("extPropGetter", convertPropertyAccessor(getter))
                }

                prop.setter?.let { setter ->
                    put("extPropSetter", convertPropertyAccessor(setter))
                }

                put("modifiers", convertModifiers(prop))
            }
        }

        // Simple variable/constant
        return buildJsonObject {
            put("kind", if (prop.isVar) "xnkVarDecl" else if (prop.hasModifier(KtTokens.CONST_KEYWORD)) "xnkConstDecl" else "xnkLetDecl")
            put("declName", prop.name ?: "")

            prop.typeReference?.let {
                put("declType", convertTypeReference(it))
            }

            prop.initializer?.let {
                put("initializer", convertExpression(it))
            }

            // Delegated property
            prop.delegateExpression?.let { delegate ->
                put("delegate", convertExpression(delegate))
            }

            // Annotations
            val annotations = prop.annotationEntries
            if (annotations.isNotEmpty()) {
                putJsonArray("decorators") {
                    annotations.forEach { add(convertAnnotation(it)) }
                }
            }

            put("modifiers", convertModifiers(prop))

            // Kotlin-specific
            if (prop.hasModifier(KtTokens.LATEINIT_KEYWORD)) put("isLateinit", true)
        }
    }

    private fun convertPropertyAccessor(accessor: KtPropertyAccessor): JsonObject {
        incrementStat("KtPropertyAccessor")
        return buildJsonObject {
            put("kind", if (accessor.isGetter) "xnkFuncDecl" else "xnkFuncDecl")
            put("funcName", if (accessor.isGetter) "get" else "set")

            if (!accessor.isGetter) {
                putJsonArray("params") {
                    accessor.parameter?.let { param ->
                        add(convertParameter(param))
                    } ?: add(buildJsonObject {
                        put("kind", "xnkParameter")
                        put("paramName", "value")
                    })
                }
            } else {
                putJsonArray("params") { }
            }

            accessor.bodyExpression?.let { body ->
                put("body", convertFunctionBody(body))
            }

            put("modifiers", convertModifiers(accessor))
        }
    }

    private fun convertTypeAlias(alias: KtTypeAlias): JsonObject {
        incrementStat("KtTypeAlias")
        return buildJsonObject {
            put("kind", "xnkTypeAlias")
            put("aliasName", alias.name ?: "")
            alias.getTypeReference()?.let {
                put("aliasTarget", convertTypeReference(it))
            }

            if (alias.typeParameters.isNotEmpty()) {
                putJsonArray("typeParameters") {
                    alias.typeParameters.forEach { add(convertTypeParameter(it)) }
                }
            }

            put("modifiers", convertModifiers(alias))
        }
    }

    private fun convertDestructuringDeclaration(decl: KtDestructuringDeclaration): JsonObject {
        incrementStat("KtDestructuringDeclaration")
        return buildJsonObject {
            put("kind", "xnkExternal_Destructure")
            put("extDestructKind", "object")

            decl.initializer?.let {
                put("extDestructSource", convertExpression(it))
            }

            putJsonArray("extDestructFields") {
                decl.entries.forEach { entry ->
                    add(JsonPrimitive(entry.name ?: "_"))
                }
            }
        }
    }

    private fun convertScript(script: KtScript): JsonObject {
        incrementStat("KtScript")
        return buildJsonObject {
            put("kind", "xnkBlockStmt")
            putJsonArray("blockBody") {
                script.blockExpression.statements.forEach { stmt ->
                    add(convertExpression(stmt))
                }
            }
        }
    }

    // ============================================================================
    // STATEMENT CONVERSION
    // ============================================================================

    private fun convertStatement(stmt: KtExpression): JsonObject {
        return convertExpression(stmt)
    }

    private fun convertBlockExpression(block: KtBlockExpression?): JsonObject {
        incrementStat("KtBlockExpression")
        return buildJsonObject {
            put("kind", "xnkBlockStmt")
            putJsonArray("blockBody") {
                block?.statements?.forEach { stmt ->
                    add(convertExpression(stmt))
                }
            }
        }
    }

    // ============================================================================
    // EXPRESSION CONVERSION
    // ============================================================================

    private fun convertExpression(expr: KtExpression?): JsonObject {
        if (expr == null) {
            return buildJsonObject { put("kind", "xnkNilLit") }
        }

        return when (expr) {
            // Literals
            is KtConstantExpression -> convertConstantExpression(expr)
            is KtStringTemplateExpression -> convertStringTemplate(expr)

            // References
            is KtNameReferenceExpression -> convertNameReference(expr)
            is KtThisExpression -> convertThisExpression(expr)
            is KtSuperExpression -> convertSuperExpression(expr)

            // Operators
            is KtBinaryExpression -> convertBinaryExpression(expr)
            is KtUnaryExpression -> convertUnaryExpression(expr)
            is KtBinaryExpressionWithTypeRHS -> convertBinaryExpressionWithType(expr)
            is KtIsExpression -> convertIsExpression(expr)

            // Control flow
            is KtIfExpression -> convertIfExpression(expr)
            is KtWhenExpression -> convertWhenExpression(expr)
            is KtWhileExpression -> convertWhileExpression(expr)
            is KtDoWhileExpression -> convertDoWhileExpression(expr)
            is KtForExpression -> convertForExpression(expr)
            is KtTryExpression -> convertTryExpression(expr)

            // Jump expressions
            is KtReturnExpression -> convertReturnExpression(expr)
            is KtBreakExpression -> convertBreakExpression(expr)
            is KtContinueExpression -> convertContinueExpression(expr)
            is KtThrowExpression -> convertThrowExpression(expr)

            // Calls and access
            is KtCallExpression -> convertCallExpression(expr)
            is KtDotQualifiedExpression -> convertDotQualifiedExpression(expr)
            is KtSafeQualifiedExpression -> convertSafeQualifiedExpression(expr)
            is KtArrayAccessExpression -> convertArrayAccessExpression(expr)

            // Lambdas and anonymous
            is KtLambdaExpression -> convertLambdaExpression(expr)
            is KtAnonymousInitializer -> convertAnonymousInitializer(expr)
            is KtObjectLiteralExpression -> convertObjectLiteral(expr)
            is KtCallableReferenceExpression -> convertCallableReference(expr)

            // Collections
            is KtCollectionLiteralExpression -> convertCollectionLiteral(expr)

            // Other
            is KtParenthesizedExpression -> convertExpression(expr.expression)
            is KtBlockExpression -> convertBlockExpression(expr)
            is KtProperty -> convertProperty(expr)
            is KtDestructuringDeclaration -> convertDestructuringDeclaration(expr)
            is KtLabeledExpression -> convertLabeledExpression(expr)
            is KtAnnotatedExpression -> convertAnnotatedExpression(expr)
            is KtClassLiteralExpression -> convertClassLiteral(expr)
            is KtDoubleColonExpression -> convertDoubleColonExpression(expr)

            else -> {
                incrementStat("UnknownExpression_${expr::class.simpleName}")
                buildJsonObject {
                    put("kind", "xnkUnknown")
                    put("unknownData", "Unknown expression: ${expr::class.simpleName}")
                }
            }
        }
    }

    private fun convertConstantExpression(expr: KtConstantExpression): JsonObject {
        incrementStat("KtConstantExpression")
        val text = expr.text
        val elementType = expr.node.elementType

        return buildJsonObject {
            when (elementType) {
                KtNodeTypes.INTEGER_CONSTANT -> {
                    put("kind", "xnkIntLit")
                    put("literalValue", text.replace("_", "").removeSuffix("L").removeSuffix("l")
                        .removeSuffix("U").removeSuffix("u").removeSuffix("UL").removeSuffix("ul"))
                }
                KtNodeTypes.FLOAT_CONSTANT -> {
                    put("kind", "xnkFloatLit")
                    put("literalValue", text.replace("_", "").removeSuffix("f").removeSuffix("F"))
                }
                KtNodeTypes.CHARACTER_CONSTANT -> {
                    put("kind", "xnkCharLit")
                    put("literalValue", text.removeSurrounding("'"))
                }
                KtNodeTypes.BOOLEAN_CONSTANT -> {
                    put("kind", "xnkBoolLit")
                    put("boolValue", text == "true")
                }
                KtNodeTypes.NULL -> {
                    put("kind", "xnkNilLit")
                }
                else -> {
                    put("kind", "xnkStringLit")
                    put("literalValue", text)
                }
            }
        }
    }

    private fun convertStringTemplate(expr: KtStringTemplateExpression): JsonObject {
        incrementStat("KtStringTemplateExpression")

        val entries = expr.entries
        if (entries.all { it is KtLiteralStringTemplateEntry }) {
            // Simple string literal
            return buildJsonObject {
                put("kind", "xnkStringLit")
                put("literalValue", entries.joinToString("") {
                    (it as KtLiteralStringTemplateEntry).text
                })
                if (expr.text.startsWith("\"\"\"")) {
                    put("isRaw", true)
                }
            }
        }

        // String interpolation
        return buildJsonObject {
            put("kind", "xnkExternal_StringInterp")
            putJsonArray("extInterpParts") {
                entries.forEach { entry ->
                    when (entry) {
                        is KtLiteralStringTemplateEntry -> {
                            add(buildJsonObject {
                                put("kind", "xnkStringLit")
                                put("literalValue", entry.text)
                            })
                        }
                        is KtSimpleNameStringTemplateEntry -> {
                            add(buildJsonObject {
                                put("kind", "xnkIdentifier")
                                put("identName", entry.expression?.text ?: "")
                            })
                        }
                        is KtBlockStringTemplateEntry -> {
                            add(convertExpression(entry.expression))
                        }
                        is KtEscapeStringTemplateEntry -> {
                            add(buildJsonObject {
                                put("kind", "xnkStringLit")
                                put("literalValue", entry.unescapedValue)
                            })
                        }
                    }
                }
            }
            putJsonArray("extInterpIsExpr") {
                entries.forEach { entry ->
                    add(JsonPrimitive(entry !is KtLiteralStringTemplateEntry && entry !is KtEscapeStringTemplateEntry))
                }
            }
        }
    }

    private fun convertNameReference(expr: KtNameReferenceExpression): JsonObject {
        incrementStat("KtNameReferenceExpression")
        return buildJsonObject {
            put("kind", "xnkIdentifier")
            put("identName", expr.getReferencedName())
        }
    }

    private fun convertThisExpression(expr: KtThisExpression): JsonObject {
        incrementStat("KtThisExpression")
        return buildJsonObject {
            put("kind", "xnkThisExpr")
            expr.getLabelName()?.let { put("thisLabel", it) }
        }
    }

    private fun convertSuperExpression(expr: KtSuperExpression): JsonObject {
        incrementStat("KtSuperExpression")
        return buildJsonObject {
            put("kind", "xnkBaseExpr")
            expr.superTypeQualifier?.let { put("baseType", it.text) }
            expr.getLabelName()?.let { put("baseLabel", it) }
        }
    }

    private fun convertBinaryExpression(expr: KtBinaryExpression): JsonObject {
        incrementStat("KtBinaryExpression")

        val operatorToken = expr.operationToken
        val operatorText = expr.operationReference.text

        // Handle assignment
        if (operatorToken == KtTokens.EQ) {
            return buildJsonObject {
                put("kind", "xnkAsgn")
                put("asgnLeft", convertExpression(expr.left))
                put("asgnRight", convertExpression(expr.right))
            }
        }

        // Handle elvis operator
        if (operatorToken == KtTokens.ELVIS) {
            return buildJsonObject {
                put("kind", "xnkExternal_NullCoalesce")
                put("extNullCoalesceLeft", convertExpression(expr.left))
                put("extNullCoalesceRight", convertExpression(expr.right))
            }
        }

        // Handle range operators
        if (operatorToken == KtTokens.RANGE || operatorToken == KtTokens.RANGE_UNTIL) {
            return buildJsonObject {
                put("kind", "xnkBinaryExpr")
                put("binaryLeft", convertExpression(expr.left))
                put("binaryOp", "range")
                put("binaryRight", convertExpression(expr.right))
                if (operatorToken == KtTokens.RANGE_UNTIL) {
                    put("isExclusive", true)
                }
            }
        }

        // Handle in/!in operators
        if (operatorToken == KtTokens.IN_KEYWORD || operatorToken == KtTokens.NOT_IN) {
            return buildJsonObject {
                put("kind", "xnkBinaryExpr")
                put("binaryLeft", convertExpression(expr.left))
                put("binaryOp", if (operatorToken == KtTokens.IN_KEYWORD) "in" else "notin")
                put("binaryRight", convertExpression(expr.right))
            }
        }

        return buildJsonObject {
            put("kind", "xnkBinaryExpr")
            put("binaryLeft", convertExpression(expr.left))
            put("binaryOp", mapBinaryOperator(operatorText))
            put("binaryRight", convertExpression(expr.right))

            // Compound assignment
            if (operatorText.endsWith("=") && operatorText != "==" && operatorText != "!=" &&
                operatorText != "<=" && operatorText != ">=") {
                put("isCompoundAssignment", true)
            }
        }
    }

    private fun mapBinaryOperator(op: String): String {
        return when (op) {
            "+" -> "add"
            "-" -> "sub"
            "*" -> "mul"
            "/" -> "div"
            "%" -> "mod"
            "+=" -> "adda"
            "-=" -> "suba"
            "*=" -> "mula"
            "/=" -> "diva"
            "%=" -> "moda"
            "==" -> "eq"
            "!=" -> "neq"
            "===" -> "is"
            "!==" -> "isnot"
            "<" -> "lt"
            "<=" -> "le"
            ">" -> "gt"
            ">=" -> "ge"
            "&&" -> "and"
            "||" -> "or"
            "&" -> "bitand"
            "|" -> "bitor"
            "^" -> "bitxor"
            "shl" -> "shl"
            "shr" -> "shr"
            "ushr" -> "shru"
            "and" -> "bitand"
            "or" -> "bitor"
            "xor" -> "bitxor"
            else -> op
        }
    }

    private fun convertUnaryExpression(expr: KtUnaryExpression): JsonObject {
        incrementStat("KtUnaryExpression")

        val operatorToken = expr.operationToken
        val operatorText = expr.operationReference.text
        val isPrefix = expr is KtPrefixExpression

        // Handle not-null assertion
        if (operatorToken == KtTokens.EXCLEXCL) {
            return buildJsonObject {
                put("kind", "xnkUnaryExpr")
                put("unaryOp", "notnull")
                put("unaryOperand", convertExpression(expr.baseExpression))
                put("isPrefix", false)
            }
        }

        return buildJsonObject {
            put("kind", "xnkUnaryExpr")
            put("unaryOp", mapUnaryOperator(operatorText, isPrefix))
            put("unaryOperand", convertExpression(expr.baseExpression))
            put("isPrefix", isPrefix)
        }
    }

    private fun mapUnaryOperator(op: String, isPrefix: Boolean): String {
        return when (op) {
            "-" -> "neg"
            "+" -> "pos"
            "!" -> "not"
            "++" -> if (isPrefix) "preinc" else "postinc"
            "--" -> if (isPrefix) "predec" else "postdec"
            else -> op
        }
    }

    private fun convertBinaryExpressionWithType(expr: KtBinaryExpressionWithTypeRHS): JsonObject {
        incrementStat("KtBinaryExpressionWithTypeRHS")

        val operationToken = expr.operationReference.getReferencedNameElementType()

        return when (operationToken) {
            KtTokens.AS_KEYWORD -> {
                buildJsonObject {
                    put("kind", "xnkCastExpr")
                    put("castExpr", convertExpression(expr.left))
                    put("castType", convertTypeReference(expr.right!!))
                }
            }
            KtTokens.AS_SAFE -> {
                buildJsonObject {
                    put("kind", "xnkCastExpr")
                    put("castExpr", convertExpression(expr.left))
                    put("castType", convertTypeReference(expr.right!!))
                    put("isSafe", true)
                }
            }
            KtTokens.COLON -> {
                buildJsonObject {
                    put("kind", "xnkTypeAssertion")
                    put("assertExpr", convertExpression(expr.left))
                    put("assertType", convertTypeReference(expr.right!!))
                }
            }
            else -> {
                buildJsonObject {
                    put("kind", "xnkBinaryExpr")
                    put("binaryLeft", convertExpression(expr.left))
                    put("binaryOp", operationToken.toString())
                    put("binaryRight", convertTypeReference(expr.right!!))
                }
            }
        }
    }

    private fun convertIsExpression(expr: KtIsExpression): JsonObject {
        incrementStat("KtIsExpression")
        return buildJsonObject {
            put("kind", "xnkBinaryExpr")
            put("binaryLeft", convertExpression(expr.leftHandSide))
            put("binaryOp", if (expr.isNegated) "isnot" else "istype")
            put("binaryRight", convertTypeReference(expr.typeReference!!))
        }
    }

    private fun convertIfExpression(expr: KtIfExpression): JsonObject {
        incrementStat("KtIfExpression")
        return buildJsonObject {
            // Kotlin if is an expression, but we use xnkIfStmt
            // The transformation pass will handle if-expression vs if-statement
            put("kind", "xnkIfStmt")
            put("ifCondition", convertExpression(expr.condition))
            put("ifBody", convertExpressionOrBlock(expr.then))
            expr.`else`?.let {
                put("elseBody", convertExpressionOrBlock(it))
            }
            // Mark as expression if used as value
            val parent = expr.parent
            if (parent !is KtBlockExpression && parent !is KtWhenEntry) {
                put("isExpression", true)
            }
        }
    }

    private fun convertExpressionOrBlock(expr: KtExpression?): JsonObject {
        if (expr == null) {
            return buildJsonObject {
                put("kind", "xnkBlockStmt")
                putJsonArray("blockBody") { }
            }
        }
        return when (expr) {
            is KtBlockExpression -> convertBlockExpression(expr)
            else -> buildJsonObject {
                put("kind", "xnkBlockStmt")
                putJsonArray("blockBody") {
                    add(convertExpression(expr))
                }
            }
        }
    }

    private fun convertWhenExpression(expr: KtWhenExpression): JsonObject {
        incrementStat("KtWhenExpression")

        return buildJsonObject {
            // Kotlin 'when' can be with or without subject
            if (expr.subjectExpression != null) {
                put("kind", "xnkSwitchStmt")
                put("switchExpr", convertExpression(expr.subjectExpression))
                putJsonArray("switchCases") {
                    expr.entries.forEach { entry ->
                        add(convertWhenEntry(entry))
                    }
                }
            } else {
                // when without subject is like chained if-else
                put("kind", "xnkExternal_SwitchExpr")
                put("extSwitchExprValue", buildJsonObject { put("kind", "xnkBoolLit"); put("boolValue", true) })
                putJsonArray("extSwitchExprArms") {
                    expr.entries.forEach { entry ->
                        add(convertWhenEntry(entry))
                    }
                }
            }

            // Mark as expression if used as value
            val parent = expr.parent
            if (parent !is KtBlockExpression) {
                put("isExpression", true)
            }
        }
    }

    private fun convertWhenEntry(entry: KtWhenEntry): JsonObject {
        incrementStat("KtWhenEntry")
        return buildJsonObject {
            if (entry.isElse) {
                put("kind", "xnkDefaultClause")
                put("defaultBody", convertExpressionOrBlock(entry.expression))
            } else {
                put("kind", "xnkCaseClause")
                putJsonArray("caseValues") {
                    entry.conditions.forEach { condition ->
                        add(convertWhenCondition(condition))
                    }
                }
                put("caseBody", convertExpressionOrBlock(entry.expression))
            }
        }
    }

    private fun convertWhenCondition(condition: KtWhenCondition): JsonObject {
        incrementStat("KtWhenCondition")
        return when (condition) {
            is KtWhenConditionWithExpression -> convertExpression(condition.expression)
            is KtWhenConditionInRange -> {
                buildJsonObject {
                    put("kind", "xnkBinaryExpr")
                    put("binaryLeft", buildJsonObject { put("kind", "xnkIdentifier"); put("identName", "_subject") })
                    put("binaryOp", if (condition.isNegated) "notin" else "in")
                    put("binaryRight", convertExpression(condition.rangeExpression))
                }
            }
            is KtWhenConditionIsPattern -> {
                buildJsonObject {
                    put("kind", "xnkBinaryExpr")
                    put("binaryLeft", buildJsonObject { put("kind", "xnkIdentifier"); put("identName", "_subject") })
                    put("binaryOp", if (condition.isNegated) "isnot" else "istype")
                    put("binaryRight", convertTypeReference(condition.typeReference!!))
                }
            }
            else -> buildJsonObject { put("kind", "xnkUnknown") }
        }
    }

    private fun convertWhileExpression(expr: KtWhileExpression): JsonObject {
        incrementStat("KtWhileExpression")
        return buildJsonObject {
            put("kind", "xnkWhileStmt")
            put("whileCondition", convertExpression(expr.condition))
            put("whileBody", convertExpressionOrBlock(expr.body))
        }
    }

    private fun convertDoWhileExpression(expr: KtDoWhileExpression): JsonObject {
        incrementStat("KtDoWhileExpression")
        return buildJsonObject {
            put("kind", "xnkExternal_DoWhile")
            put("extDoWhileBody", convertExpressionOrBlock(expr.body))
            put("extDoWhileCondition", convertExpression(expr.condition))
        }
    }

    private fun convertForExpression(expr: KtForExpression): JsonObject {
        incrementStat("KtForExpression")
        return buildJsonObject {
            put("kind", "xnkForeachStmt")

            // Loop variable
            val loopParam = expr.loopParameter
            if (loopParam != null) {
                put("foreachVar", buildJsonObject {
                    if (loopParam.destructuringDeclaration != null) {
                        // Destructuring: for ((a, b) in list)
                        put("kind", "xnkExternal_Destructure")
                        put("extDestructKind", "object")
                        putJsonArray("extDestructFields") {
                            loopParam.destructuringDeclaration!!.entries.forEach { entry ->
                                add(JsonPrimitive(entry.name ?: "_"))
                            }
                        }
                    } else {
                        put("kind", "xnkVarDecl")
                        put("declName", loopParam.name ?: "_")
                        loopParam.typeReference?.let {
                            put("declType", convertTypeReference(it))
                        }
                    }
                })
            }

            put("foreachIter", convertExpression(expr.loopRange))
            put("foreachBody", convertExpressionOrBlock(expr.body))
        }
    }

    private fun convertTryExpression(expr: KtTryExpression): JsonObject {
        incrementStat("KtTryExpression")
        return buildJsonObject {
            put("kind", "xnkTryStmt")
            put("tryBody", convertBlockExpression(expr.tryBlock))

            putJsonArray("catchClauses") {
                expr.catchClauses.forEach { clause ->
                    add(convertCatchClause(clause))
                }
            }

            expr.finallyBlock?.let { finally ->
                put("finallyClause", buildJsonObject {
                    put("kind", "xnkFinallyStmt")
                    put("finallyBody", convertBlockExpression(finally.finalExpression as? KtBlockExpression))
                })
            }
        }
    }

    private fun convertCatchClause(clause: KtCatchClause): JsonObject {
        incrementStat("KtCatchClause")
        return buildJsonObject {
            put("kind", "xnkCatchStmt")
            clause.catchParameter?.let { param ->
                put("catchVar", param.name)
                param.typeReference?.let {
                    put("catchType", convertTypeReference(it))
                }
            }
            put("catchBody", convertBlockExpression(clause.catchBody))
        }
    }

    private fun convertReturnExpression(expr: KtReturnExpression): JsonObject {
        incrementStat("KtReturnExpression")
        return buildJsonObject {
            put("kind", "xnkReturnStmt")
            expr.returnedExpression?.let {
                put("returnExpr", convertExpression(it))
            }
            expr.getLabelName()?.let {
                put("returnLabel", it)
            }
        }
    }

    private fun convertBreakExpression(expr: KtBreakExpression): JsonObject {
        incrementStat("KtBreakExpression")
        return buildJsonObject {
            put("kind", "xnkBreakStmt")
            expr.getLabelName()?.let {
                put("label", it)
            }
        }
    }

    private fun convertContinueExpression(expr: KtContinueExpression): JsonObject {
        incrementStat("KtContinueExpression")
        return buildJsonObject {
            put("kind", "xnkContinueStmt")
            expr.getLabelName()?.let {
                put("label", it)
            }
        }
    }

    private fun convertThrowExpression(expr: KtThrowExpression): JsonObject {
        incrementStat("KtThrowExpression")
        return buildJsonObject {
            put("kind", "xnkThrowStmt")
            put("throwExpr", convertExpression(expr.thrownExpression))
        }
    }

    private fun convertCallExpression(expr: KtCallExpression): JsonObject {
        incrementStat("KtCallExpression")
        return buildJsonObject {
            put("kind", "xnkCallExpr")
            put("callee", convertExpression(expr.calleeExpression))

            putJsonArray("args") {
                expr.valueArguments.forEach { arg ->
                    add(convertValueArgument(arg))
                }
            }

            // Lambda arguments (trailing lambda)
            expr.lambdaArguments.forEach { lambda ->
                // Already included via valueArguments
            }

            // Type arguments
            expr.typeArguments.let { typeArgs ->
                if (typeArgs.isNotEmpty()) {
                    putJsonArray("typeArguments") {
                        typeArgs.forEach { arg ->
                            add(convertTypeProjection(arg))
                        }
                    }
                }
            }
        }
    }

    private fun convertValueArgument(arg: KtValueArgument): JsonObject {
        incrementStat("KtValueArgument")
        return buildJsonObject {
            put("kind", "xnkArgument")
            arg.getArgumentName()?.let {
                put("argName", it.asName.asString())
            }

            val argExpr = arg.getArgumentExpression()
            if (arg.isSpread) {
                put("argValue", buildJsonObject {
                    put("kind", "xnkUnaryExpr")
                    put("unaryOp", "spread")
                    put("unaryOperand", convertExpression(argExpr))
                    put("isPrefix", true)
                })
            } else {
                put("argValue", convertExpression(argExpr))
            }
        }
    }

    private fun convertDotQualifiedExpression(expr: KtDotQualifiedExpression): JsonObject {
        incrementStat("KtDotQualifiedExpression")

        val selector = expr.selectorExpression

        return when (selector) {
            is KtCallExpression -> {
                buildJsonObject {
                    put("kind", "xnkCallExpr")
                    put("callee", buildJsonObject {
                        put("kind", "xnkMemberAccessExpr")
                        put("memberExpr", convertExpression(expr.receiverExpression))
                        put("memberName", selector.calleeExpression?.text ?: "")
                    })
                    putJsonArray("args") {
                        selector.valueArguments.forEach { arg ->
                            add(convertValueArgument(arg))
                        }
                    }
                    selector.typeArguments.let { typeArgs ->
                        if (typeArgs.isNotEmpty()) {
                            putJsonArray("typeArguments") {
                                typeArgs.forEach { arg ->
                                    add(convertTypeProjection(arg))
                                }
                            }
                        }
                    }
                }
            }
            else -> {
                buildJsonObject {
                    put("kind", "xnkMemberAccessExpr")
                    put("memberExpr", convertExpression(expr.receiverExpression))
                    put("memberName", selector?.text ?: "")
                }
            }
        }
    }

    private fun convertSafeQualifiedExpression(expr: KtSafeQualifiedExpression): JsonObject {
        incrementStat("KtSafeQualifiedExpression")

        val selector = expr.selectorExpression

        return buildJsonObject {
            put("kind", "xnkExternal_SafeNavigation")
            put("extSafeNavObject", convertExpression(expr.receiverExpression))
            put("extSafeNavMember", selector?.text ?: "")

            // If selector is a call, include the call info
            if (selector is KtCallExpression) {
                put("isCall", true)
                putJsonArray("args") {
                    selector.valueArguments.forEach { arg ->
                        add(convertValueArgument(arg))
                    }
                }
            }
        }
    }

    private fun convertArrayAccessExpression(expr: KtArrayAccessExpression): JsonObject {
        incrementStat("KtArrayAccessExpression")
        return buildJsonObject {
            put("kind", "xnkIndexExpr")
            put("indexExpr", convertExpression(expr.arrayExpression))
            putJsonArray("indexArgs") {
                expr.indexExpressions.forEach { idx ->
                    add(convertExpression(idx))
                }
            }
        }
    }

    private fun convertLambdaExpression(expr: KtLambdaExpression): JsonObject {
        incrementStat("KtLambdaExpression")
        return buildJsonObject {
            put("kind", "xnkLambdaExpr")

            putJsonArray("lambdaParams") {
                expr.valueParameters.forEach { param ->
                    add(convertParameter(param))
                }
            }

            // If no explicit parameters, Kotlin provides implicit 'it'
            if (expr.valueParameters.isEmpty() && expr.functionLiteral.valueParameterList == null) {
                // Implicit 'it' parameter - we'll note this
                put("hasImplicitIt", true)
            }

            put("lambdaBody", convertBlockExpression(expr.bodyExpression))
        }
    }

    private fun convertAnonymousInitializer(expr: KtAnonymousInitializer): JsonObject {
        incrementStat("KtAnonymousInitializer")
        return buildJsonObject {
            put("kind", "xnkBlockStmt")
            put("isInitializer", true)
            (expr.body as? KtBlockExpression)?.let { block ->
                putJsonArray("blockBody") {
                    block.statements.forEach { stmt ->
                        add(convertExpression(stmt))
                    }
                }
            }
        }
    }

    private fun convertObjectLiteral(expr: KtObjectLiteralExpression): JsonObject {
        incrementStat("KtObjectLiteralExpression")
        return buildJsonObject {
            put("kind", "xnkCallExpr")
            put("isNewExpr", true)
            put("isAnonymous", true)

            val objDecl = expr.objectDeclaration

            // Base types
            objDecl.superTypeListEntries.firstOrNull()?.let { entry ->
                put("callType", convertSuperTypeEntry(entry))
            }

            // Constructor arguments
            val superCall = objDecl.superTypeListEntries.filterIsInstance<KtSuperTypeCallEntry>().firstOrNull()
            putJsonArray("callArgs") {
                superCall?.valueArguments?.forEach { arg ->
                    add(convertValueArgument(arg))
                }
            }

            // Anonymous class body
            objDecl.body?.let { body ->
                putJsonArray("anonymousClassBody") {
                    body.declarations.forEach { decl ->
                        add(convertDeclaration(decl))
                    }
                }
            }
        }
    }

    private fun convertCallableReference(expr: KtCallableReferenceExpression): JsonObject {
        incrementStat("KtCallableReferenceExpression")
        return buildJsonObject {
            put("kind", "xnkMethodReference")
            expr.receiverExpression?.let {
                put("refObject", convertExpression(it))
            }
            put("refMethod", expr.callableReference.getReferencedName())
        }
    }

    private fun convertCollectionLiteral(expr: KtCollectionLiteralExpression): JsonObject {
        incrementStat("KtCollectionLiteralExpression")
        return buildJsonObject {
            put("kind", "xnkArrayLiteral")
            putJsonArray("elements") {
                expr.getInnerExpressions().forEach { elem ->
                    add(convertExpression(elem))
                }
            }
        }
    }

    private fun convertLabeledExpression(expr: KtLabeledExpression): JsonObject {
        incrementStat("KtLabeledExpression")
        return buildJsonObject {
            put("kind", "xnkLabeledStmt")
            put("labelName", expr.getLabelName() ?: "")
            put("labeledStmt", convertExpression(expr.baseExpression))
        }
    }

    private fun convertAnnotatedExpression(expr: KtAnnotatedExpression): JsonObject {
        incrementStat("KtAnnotatedExpression")
        val baseExpr = convertExpression(expr.baseExpression)

        // Add annotations to the base expression
        return buildJsonObject {
            baseExpr.forEach { (key, value) -> put(key, value) }
            putJsonArray("decorators") {
                expr.annotationEntries.forEach { ann ->
                    add(convertAnnotation(ann))
                }
            }
        }
    }

    private fun convertClassLiteral(expr: KtClassLiteralExpression): JsonObject {
        incrementStat("KtClassLiteralExpression")
        return buildJsonObject {
            put("kind", "xnkTypeOfExpr")
            expr.receiverExpression?.let {
                put("typeOfType", convertExpression(it))
            }
        }
    }

    private fun convertDoubleColonExpression(expr: KtDoubleColonExpression): JsonObject {
        incrementStat("KtDoubleColonExpression")
        return when (expr) {
            is KtCallableReferenceExpression -> convertCallableReference(expr)
            is KtClassLiteralExpression -> convertClassLiteral(expr)
            else -> buildJsonObject {
                put("kind", "xnkMethodReference")
                expr.receiverExpression?.let {
                    put("refObject", convertExpression(it))
                }
            }
        }
    }

    // ============================================================================
    // TYPE CONVERSION
    // ============================================================================

    private fun convertTypeReference(typeRef: KtTypeReference): JsonObject {
        incrementStat("KtTypeReference")
        val typeElement = typeRef.typeElement
        return convertTypeElement(typeElement)
    }

    private fun convertTypeElement(typeElement: KtTypeElement?): JsonObject {
        if (typeElement == null) {
            return buildJsonObject {
                put("kind", "xnkNamedType")
                put("typeName", "Any")
            }
        }

        return when (typeElement) {
            is KtUserType -> convertUserType(typeElement)
            is KtNullableType -> convertNullableType(typeElement)
            is KtFunctionType -> convertFunctionType(typeElement)
            is KtDynamicType -> {
                incrementStat("KtDynamicType")
                buildJsonObject {
                    put("kind", "xnkDynamicType")
                }
            }
            is KtSelfType -> {
                incrementStat("KtSelfType")
                buildJsonObject {
                    put("kind", "xnkNamedType")
                    put("typeName", "Self")
                    put("isSelfType", true)
                }
            }
            is KtIntersectionType -> {
                incrementStat("KtIntersectionType")
                buildJsonObject {
                    put("kind", "xnkIntersectionType")
                    putJsonArray("typeMembers") {
                        typeElement.getLeftTypeRef()?.let { add(convertTypeReference(it)) }
                        typeElement.getRightTypeRef()?.let { add(convertTypeReference(it)) }
                    }
                }
            }
            else -> {
                incrementStat("UnknownTypeElement_${typeElement::class.simpleName}")
                buildJsonObject {
                    put("kind", "xnkNamedType")
                    put("typeName", typeElement.text)
                }
            }
        }
    }

    private fun convertUserType(type: KtUserType): JsonObject {
        incrementStat("KtUserType")

        val typeArgs = type.typeArguments

        return buildJsonObject {
            if (typeArgs.isNotEmpty()) {
                put("kind", "xnkGenericType")
                put("genericTypeName", type.referencedName ?: "")
                putJsonArray("genericArgs") {
                    typeArgs.forEach { arg ->
                        add(convertTypeProjection(arg))
                    }
                }
            } else {
                put("kind", "xnkNamedType")
                put("typeName", type.text)
            }

            // Handle qualified types (e.g., com.example.MyClass)
            type.qualifier?.let { qualifier ->
                put("qualifier", convertUserType(qualifier))
            }
        }
    }

    private fun convertNullableType(type: KtNullableType): JsonObject {
        incrementStat("KtNullableType")
        val innerType = convertTypeElement(type.innerType)
        return buildJsonObject {
            innerType.forEach { (key, value) -> put(key, value) }
            put("isNullable", true)
        }
    }

    private fun convertFunctionType(type: KtFunctionType): JsonObject {
        incrementStat("KtFunctionType")
        return buildJsonObject {
            put("kind", "xnkFuncType")

            // Receiver type (for extension function types)
            type.receiverTypeReference?.let {
                put("receiverType", convertTypeReference(it))
            }

            putJsonArray("funcParams") {
                type.parameters.forEach { param ->
                    add(buildJsonObject {
                        put("kind", "xnkParameter")
                        param.name?.let { put("paramName", it) }
                        param.typeReference?.let {
                            put("paramType", convertTypeReference(it))
                        }
                    })
                }
            }

            type.returnTypeReference?.let {
                put("funcReturnType", convertTypeReference(it))
            }

            if (type.isSuspendModifier) {
                put("isSuspend", true)
            }
        }
    }

    private fun convertTypeProjection(projection: KtTypeProjection): JsonObject {
        incrementStat("KtTypeProjection")

        val variance = projection.projectionKind

        if (variance == KtProjectionKind.STAR) {
            return buildJsonObject {
                put("kind", "xnkNamedType")
                put("typeName", "*")
                put("isWildcard", true)
            }
        }

        val typeRef = projection.typeReference
        val baseType = if (typeRef != null) convertTypeReference(typeRef) else buildJsonObject {
            put("kind", "xnkNamedType")
            put("typeName", "Any")
        }

        return buildJsonObject {
            baseType.forEach { (key, value) -> put(key, value) }
            when (variance) {
                KtProjectionKind.IN -> put("variance", "in")
                KtProjectionKind.OUT -> put("variance", "out")
                else -> {}
            }
        }
    }

    private fun convertTypeParameter(param: KtTypeParameter): JsonObject {
        incrementStat("KtTypeParameter")
        return buildJsonObject {
            put("kind", "xnkGenericParameter")
            put("genericParamName", param.name ?: "")

            // Variance
            when {
                param.hasModifier(KtTokens.IN_KEYWORD) -> put("variance", "in")
                param.hasModifier(KtTokens.OUT_KEYWORD) -> put("variance", "out")
            }

            // Bounds (constraints)
            val bounds = mutableListOf<JsonObject>()
            param.extendsBound?.let { bound ->
                bounds.add(convertTypeReference(bound))
            }
            if (bounds.isNotEmpty()) {
                putJsonArray("bounds") {
                    bounds.forEach { add(it) }
                }
            }

            // Reified
            if (param.hasModifier(KtTokens.REIFIED_KEYWORD)) {
                put("isReified", true)
            }
        }
    }

    private fun convertSuperTypeEntry(entry: KtSuperTypeListEntry): JsonObject {
        incrementStat("KtSuperTypeListEntry")
        return when (entry) {
            is KtSuperTypeCallEntry -> {
                // Constructor call: Class(args)
                buildJsonObject {
                    entry.typeReference?.let { typeRef ->
                        val typeNode = convertTypeReference(typeRef)
                        typeNode.forEach { (key, value) -> put(key, value) }
                    }
                    put("hasConstructorCall", true)
                    putJsonArray("constructorArgs") {
                        entry.valueArguments.forEach { arg ->
                            add(convertValueArgument(arg))
                        }
                    }
                }
            }
            is KtSuperTypeEntry -> {
                entry.typeReference?.let { convertTypeReference(it) } ?: buildJsonObject {
                    put("kind", "xnkNamedType")
                    put("typeName", "Any")
                }
            }
            is KtDelegatedSuperTypeEntry -> {
                buildJsonObject {
                    entry.typeReference?.let { typeRef ->
                        val typeNode = convertTypeReference(typeRef)
                        typeNode.forEach { (key, value) -> put(key, value) }
                    }
                    put("isDelegated", true)
                    entry.delegateExpression?.let {
                        put("delegateExpr", convertExpression(it))
                    }
                }
            }
            else -> buildJsonObject {
                put("kind", "xnkNamedType")
                put("typeName", entry.text)
            }
        }
    }

    // ============================================================================
    // HELPER METHODS
    // ============================================================================

    private fun convertParameter(param: KtParameter, isConstructorParam: Boolean = false): JsonObject {
        incrementStat("KtParameter")
        return buildJsonObject {
            put("kind", "xnkParameter")
            put("paramName", param.name ?: "")

            param.typeReference?.let {
                put("paramType", convertTypeReference(it))
            }

            param.defaultValue?.let {
                put("defaultValue", convertExpression(it))
            }

            // Constructor parameter properties (val/var in constructor)
            if (isConstructorParam) {
                when {
                    param.hasValOrVar() -> {
                        put("isProperty", true)
                        put("isMutable", param.isMutable)
                    }
                }
            }

            if (param.isVarArg) {
                put("isVariadic", true)
            }

            // Annotations
            val annotations = param.annotationEntries
            if (annotations.isNotEmpty()) {
                putJsonArray("decorators") {
                    annotations.forEach { add(convertAnnotation(it)) }
                }
            }

            // Crossinline, noinline modifiers
            if (param.hasModifier(KtTokens.CROSSINLINE_KEYWORD)) put("isCrossinline", true)
            if (param.hasModifier(KtTokens.NOINLINE_KEYWORD)) put("isNoinline", true)
        }
    }

    private fun convertAnnotation(annotation: KtAnnotationEntry): JsonObject {
        incrementStat("KtAnnotationEntry")
        return buildJsonObject {
            put("kind", "xnkDecorator")
            put("decoratorExpr", buildJsonObject {
                put("kind", "xnkCallExpr")
                put("callee", buildJsonObject {
                    put("kind", "xnkIdentifier")
                    put("identName", annotation.shortName?.asString() ?: "")
                })
                putJsonArray("args") {
                    annotation.valueArguments.forEach { arg ->
                        add(convertValueArgument(arg))
                    }
                }
            })

            // Annotation use-site target (field, get, set, param, etc.)
            annotation.useSiteTarget?.let { target ->
                put("useSiteTarget", target.text)
            }
        }
    }

    private fun convertModifiers(element: KtModifierListOwner): JsonObject {
        incrementStat("Modifiers")
        return buildJsonObject {
            put("isPublic", element.hasModifier(KtTokens.PUBLIC_KEYWORD) ||
                (!element.hasModifier(KtTokens.PRIVATE_KEYWORD) &&
                 !element.hasModifier(KtTokens.PROTECTED_KEYWORD) &&
                 !element.hasModifier(KtTokens.INTERNAL_KEYWORD)))
            put("isPrivate", element.hasModifier(KtTokens.PRIVATE_KEYWORD))
            put("isProtected", element.hasModifier(KtTokens.PROTECTED_KEYWORD))
            put("isInternal", element.hasModifier(KtTokens.INTERNAL_KEYWORD))
            put("isFinal", !element.hasModifier(KtTokens.OPEN_KEYWORD) &&
                          !element.hasModifier(KtTokens.ABSTRACT_KEYWORD) &&
                          !element.hasModifier(KtTokens.OVERRIDE_KEYWORD))
            put("isAbstract", element.hasModifier(KtTokens.ABSTRACT_KEYWORD))
            put("isOpen", element.hasModifier(KtTokens.OPEN_KEYWORD))
            put("isOverride", element.hasModifier(KtTokens.OVERRIDE_KEYWORD))
            put("isConst", element.hasModifier(KtTokens.CONST_KEYWORD))
            put("isExpect", element.hasModifier(KtTokens.EXPECT_KEYWORD))
            put("isActual", element.hasModifier(KtTokens.ACTUAL_KEYWORD))
        }
    }

    private fun getVisibility(element: KtModifierListOwner): String {
        return when {
            element.hasModifier(KtTokens.PRIVATE_KEYWORD) -> "private"
            element.hasModifier(KtTokens.PROTECTED_KEYWORD) -> "protected"
            element.hasModifier(KtTokens.INTERNAL_KEYWORD) -> "internal"
            else -> "public"
        }
    }
}

// Kotlin node types (for reference)
object KtNodeTypes {
    val INTEGER_CONSTANT = org.jetbrains.kotlin.lexer.KtTokens.INTEGER_LITERAL
    val FLOAT_CONSTANT = org.jetbrains.kotlin.lexer.KtTokens.FLOAT_LITERAL
    val CHARACTER_CONSTANT = org.jetbrains.kotlin.lexer.KtTokens.CHARACTER_LITERAL
    val BOOLEAN_CONSTANT = org.jetbrains.kotlin.lexer.KtTokens.IDENTIFIER // true/false are identifiers
    val NULL = org.jetbrains.kotlin.lexer.KtTokens.NULL_KEYWORD
}
