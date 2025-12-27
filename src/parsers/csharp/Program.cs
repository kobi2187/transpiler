using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

partial class Program
{
    // Global dictionary to track missing/unknown constructs
    private static Dictionary<string, int> constructStats = new Dictionary<string, int>();
    private static List<string> errorLog = new List<string>();

    static void Main(string[] args)
    {
        if (args.Length < 1)
        {
            Console.WriteLine("Usage:");
            Console.WriteLine("  Single file: csharp-to-xlang <file.cs>");
            Console.WriteLine("  Directory:   csharp-to-xlang <directory>");
            Environment.Exit(1);
        }

        string path = args[0];

        // Auto-detect if it's a directory or file
        if (Directory.Exists(path))
        {
            BatchProcessDirectory(path);
        }
        else if (File.Exists(path))
        {
            ProcessSingleFile(path, outputToConsole: true);
        }
        else
        {
            Console.Error.WriteLine($"Error: Path not found: {path}");
            Environment.Exit(1);
        }
    }

    static void BatchProcessDirectory(string directoryPath)
    {
        if (!Directory.Exists(directoryPath))
        {
            Console.Error.WriteLine($"Error: Directory not found: {directoryPath}");
            Environment.Exit(1);
        }

        var csFiles = Directory.GetFiles(directoryPath, "*.cs", SearchOption.AllDirectories);
        Console.WriteLine($"Found {csFiles.Length} C# files to process in: {directoryPath}");
        Console.WriteLine();

        int successCount = 0;
        int errorCount = 0;

        foreach (var csFile in csFiles)
        {
            try
            {
                Console.WriteLine($"Processing: {csFile}");
                ProcessSingleFile(csFile, outputToConsole: false);
                successCount++;
            }
            catch (Exception ex)
            {
                errorCount++;
                string errorMsg = $"Error processing {csFile}: {ex.Message}";
                errorLog.Add(errorMsg);
                Console.Error.WriteLine(errorMsg);
            }
        }

        // Print summary report
        Console.WriteLine();
        Console.WriteLine("=== BATCH PROCESSING SUMMARY ===");
        Console.WriteLine($"Total files: {csFiles.Length}");
        Console.WriteLine($"Successfully processed: {successCount}");
        Console.WriteLine($"Errors: {errorCount}");
        Console.WriteLine();

        if (constructStats.Count > 0)
        {
            Console.WriteLine("=== MISSING/UNKNOWN CONSTRUCTS ===");
            var sortedStats = constructStats.OrderByDescending(kvp => kvp.Value);
            foreach (var stat in sortedStats)
            {
                Console.WriteLine($"{stat.Key}: {stat.Value} occurrences");
            }
            Console.WriteLine();
        }

        if (errorLog.Count > 0)
        {
            Console.WriteLine("=== ERROR LOG ===");
            foreach (var error in errorLog)
            {
                Console.WriteLine(error);
            }
        }
    }

    static void ProcessSingleFile(string filePath, bool outputToConsole)
    {
        string sourceCode = File.ReadAllText(filePath);
        var tree = CSharpSyntaxTree.ParseText(sourceCode);
        var root = tree.GetRoot();

        var xlangNode = ConvertToXLang(root, filePath);
        var json = JsonConvert.SerializeObject(xlangNode, Formatting.Indented);

        if (outputToConsole)
        {
            Console.WriteLine(json);
        }
        else
        {
            // Output to .xljs file with same basename in same directory
            string outputPath = Path.ChangeExtension(filePath, ".xljs");
            // Use UTF-8 without BOM for JSON compatibility
            var utf8NoBom = new System.Text.UTF8Encoding(false);
            File.WriteAllText(outputPath, json, utf8NoBom);
            Console.WriteLine($"  -> Written to: {outputPath}");
        }
    }

    static JObject ConvertToXLang(SyntaxNode node, string fileName)
    {
        return node switch
        {
            CompilationUnitSyntax cu => ConvertCompilationUnit(cu, fileName),
            _ => CreateUnknownNode(node, "root")
        };
    }

    static JObject CreateUnknownNode(SyntaxNode node, string context)
    {
        string nodeType = node.GetType().Name;
        string key = $"{context}:{nodeType}";

        if (constructStats.ContainsKey(key))
        {
            constructStats[key]++;
        }
        else
        {
            constructStats[key] = 1;
        }

        return new JObject
        {
            ["kind"] = "xnkUnknown",
            ["unknownData"] = node.ToString().Length > 100 ? node.ToString().Substring(0, 100) + "..." : node.ToString()
        };
    }

    static JArray ExtractDocComments(SyntaxNode node)
    {
        var comments = new JArray();

        // Get leading trivia (comments that appear before the node)
        var leadingTrivia = node.GetLeadingTrivia();

        foreach (var trivia in leadingTrivia)
        {
            // Check for XML documentation comments (///)
            if (trivia.IsKind(Microsoft.CodeAnalysis.CSharp.SyntaxKind.SingleLineDocumentationCommentTrivia))
            {
                // Extract the comment text, removing the /// prefix and trimming
                string commentText = trivia.ToString().Trim();

                // Remove /// prefix from each line
                var lines = commentText.Split('\n');
                var cleanedLines = lines.Select(line =>
                {
                    line = line.Trim();
                    if (line.StartsWith("///"))
                        return line.Substring(3).TrimStart();
                    return line;
                }).Where(line => !string.IsNullOrWhiteSpace(line));

                string cleanedText = string.Join("\n", cleanedLines);

                if (!string.IsNullOrWhiteSpace(cleanedText))
                {
                    comments.Add(new JObject
                    {
                        ["kind"] = "xnkComment",
                        ["commentText"] = cleanedText,
                        ["isDocComment"] = true
                    });
                }
            }
        }

        return comments;
    }

    static JObject ConvertCompilationUnit(CompilationUnitSyntax cu, string fileName)
    {
        var moduleDecls = new JArray();

        // For each member, first add any doc comments, then the member itself
        foreach (var member in cu.Members)
        {
            var docComments = ExtractDocComments(member);
            foreach (var comment in docComments)
            {
                moduleDecls.Add(comment);
            }
            moduleDecls.Add(ConvertMember(member));
        }

        var result = new JObject
        {
            ["kind"] = "xnkFile",
            ["fileName"] = Path.GetFileName(fileName),
            ["sourceLang"] = "csharp",
            ["moduleDecls"] = moduleDecls
        };
        return result;
    }

    static JObject ConvertMember(MemberDeclarationSyntax member)
    {
        return member switch
        {
            NamespaceDeclarationSyntax ns => ConvertNamespace(ns),
            ClassDeclarationSyntax cls => ConvertClass(cls),
            EnumDeclarationSyntax enumDecl => ConvertEnum(enumDecl),
            InterfaceDeclarationSyntax interfaceDecl => ConvertInterface(interfaceDecl),
            StructDeclarationSyntax structDecl => ConvertStruct(structDecl),
            DelegateDeclarationSyntax delegateDecl => ConvertDelegate(delegateDecl),
            GlobalStatementSyntax globalStmt => ConvertStatement(globalStmt.Statement),
            FieldDeclarationSyntax field => ConvertField(field),
            _ => CreateUnknownNode(member, "member")
        };
    }

    static JObject ConvertNamespace(NamespaceDeclarationSyntax ns)
    {
        var namespaceBody = new JArray();

        // For each member, first add any doc comments, then the member itself
        foreach (var member in ns.Members)
        {
            var docComments = ExtractDocComments(member);
            foreach (var comment in docComments)
            {
                namespaceBody.Add(comment);
            }
            namespaceBody.Add(ConvertMember(member));
        }

        return new JObject
        {
            ["kind"] = "xnkNamespace",
            ["namespaceName"] = ns.Name.ToString(),
            ["namespaceBody"] = namespaceBody
        };
    }

    static JObject ConvertClass(ClassDeclarationSyntax cls)
    {
        var members = new JArray();

        // For each member, first add any doc comments, then the member itself
        foreach (var member in cls.Members)
        {
            var docComments = ExtractDocComments(member);
            foreach (var comment in docComments)
            {
                members.Add(comment);
            }
            members.Add(ConvertClassMember(member));
        }

        return new JObject
        {
            ["kind"] = "xnkClassDecl",
            ["typeNameDecl"] = cls.Identifier.Text,
            ["baseTypes"] = cls.BaseList != null
                ? new JArray(cls.BaseList.Types.Select(t => new JObject
                {
                    ["kind"] = "xnkNamedType",
                    ["typeName"] = t.Type.ToString()
                }))
                : new JArray(),
            ["members"] = members
        };
    }

    static JObject ConvertClassMember(MemberDeclarationSyntax member)
    {
        return member switch
        {
            MethodDeclarationSyntax method => ConvertMethod(method),
            FieldDeclarationSyntax field => ConvertField(field),
            PropertyDeclarationSyntax property => ConvertProperty(property),
            ConstructorDeclarationSyntax constructor => ConvertConstructor(constructor),
            ClassDeclarationSyntax cls => ConvertClass(cls),
            EnumDeclarationSyntax enumDecl => ConvertEnum(enumDecl),
            InterfaceDeclarationSyntax interfaceDecl => ConvertInterface(interfaceDecl),
            StructDeclarationSyntax structDecl => ConvertStruct(structDecl),
            OperatorDeclarationSyntax operatorDecl => ConvertOperator(operatorDecl),
            ConversionOperatorDeclarationSyntax conversionOp => ConvertConversionOperator(conversionOp),
            IndexerDeclarationSyntax indexer => ConvertIndexer(indexer),
            DelegateDeclarationSyntax delegateDecl => ConvertDelegate(delegateDecl),
            DestructorDeclarationSyntax destructor => ConvertDestructor(destructor),
            EventFieldDeclarationSyntax eventField => ConvertEventFieldDeclaration(eventField),
            EventDeclarationSyntax eventDecl => ConvertEventDeclaration(eventDecl),
            IncompleteMemberSyntax incompleteMember => ConvertIncompleteMember(incompleteMember),
            _ => CreateUnknownNode(member, "class_member")
        };
    }

    static JObject ConvertType(TypeSyntax type)
    {
        // Properly convert types
        // Debug: check what type we're dealing with
        if (type.ToString().Contains("?"))
        {
            Console.Error.WriteLine($"DEBUG: Type '{type}' is {type.GetType().Name}");
        }

        return type switch
        {
            NullableTypeSyntax nullableType => ConvertNullableType(nullableType),
            PredefinedTypeSyntax predefinedType => ConvertPredefinedType(predefinedType),
            ArrayTypeSyntax arrayType => ConvertArrayType(arrayType),
            GenericNameSyntax genericName => ConvertGenericName(genericName),
            QualifiedNameSyntax qualifiedName => ConvertQualifiedName(qualifiedName),
            // Fallback: create a NamedType with the type's string representation
            _ => new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = type.ToString()
            }
        };
    }

    static string ExtractVisibility(SyntaxTokenList modifiers)
    {
        if (modifiers.Any(m => m.IsKind(Microsoft.CodeAnalysis.CSharp.SyntaxKind.PublicKeyword)))
            return "public";
        if (modifiers.Any(m => m.IsKind(Microsoft.CodeAnalysis.CSharp.SyntaxKind.PrivateKeyword)))
            return "private";
        if (modifiers.Any(m => m.IsKind(Microsoft.CodeAnalysis.CSharp.SyntaxKind.InternalKeyword)))
            return "internal";
        if (modifiers.Any(m => m.IsKind(Microsoft.CodeAnalysis.CSharp.SyntaxKind.ProtectedKeyword)))
            return "protected";
        // Default to internal if no explicit visibility (C# default)
        return "internal";
    }

    static JObject ConvertMethod(MethodDeclarationSyntax method)
    {
        // Check if this is an extension method (static method with 'this' on first parameter)
        bool isExtensionMethod = method.Modifiers.Any(m => m.IsKind(Microsoft.CodeAnalysis.CSharp.SyntaxKind.StaticKeyword)) &&
                                  method.ParameterList.Parameters.Count > 0 &&
                                  method.ParameterList.Parameters[0].Modifiers.Any(m => m.IsKind(Microsoft.CodeAnalysis.CSharp.SyntaxKind.ThisKeyword));

        // Extract parameters
        var parameters = method.ParameterList.Parameters.Select(p => new JObject
        {
            ["kind"] = "xnkParameter",
            ["paramName"] = p.Identifier.Text,
            ["paramType"] = p.Type != null ? ConvertType(p.Type) : JValue.CreateNull(),
            ["defaultValue"] = p.Default != null ? ConvertExpression(p.Default.Value) : JValue.CreateNull(),
            ["isThis"] = p.Modifiers.Any(m => m.IsKind(Microsoft.CodeAnalysis.CSharp.SyntaxKind.ThisKeyword))
        });

        if (isExtensionMethod)
        {
            // Handle both block bodies and expression bodies (=>)
            JToken bodyToken;
            if (method.Body != null)
            {
                bodyToken = ConvertBlock(method.Body);
            }
            else if (method.ExpressionBody != null)
            {
                // Convert expression body to a return statement wrapped in a block
                var returnExpr = ConvertExpression(method.ExpressionBody.Expression);
                bodyToken = new JObject
                {
                    ["kind"] = "xnkBlockStmt",
                    ["blockBody"] = new JArray(new JObject
                    {
                        ["kind"] = "xnkReturnStmt",
                        ["returnExpr"] = returnExpr
                    })
                };
            }
            else
            {
                // Fallback: empty block (abstract/interface methods shouldn't be here)
                bodyToken = new JObject
                {
                    ["kind"] = "xnkBlockStmt",
                    ["blockBody"] = new JArray()
                };
            }

            return new JObject
            {
                ["kind"] = "xnkExternal_ExtensionMethod",
                ["extExtMethodName"] = method.Identifier.Text,
                ["extExtMethodParams"] = new JArray(parameters),
                ["extExtMethodReturnType"] = new JObject { ["kind"] = "xnkNamedType", ["typeName"] = method.ReturnType.ToString() },
                ["extExtMethodBody"] = bodyToken,
                ["extExtMethodIsStatic"] = true,  // Extension methods are always static in C#
                ["extExtMethodVisibility"] = ExtractVisibility(method.Modifiers)
            };
        }
        else
        {
            // Handle both block bodies and expression bodies (=>)
            JToken bodyToken;
            if (method.Body != null)
            {
                bodyToken = ConvertBlock(method.Body);
            }
            else if (method.ExpressionBody != null)
            {
                // Convert expression body to a return statement wrapped in a block
                var returnExpr = ConvertExpression(method.ExpressionBody.Expression);
                bodyToken = new JObject
                {
                    ["kind"] = "xnkBlockStmt",
                    ["blockBody"] = new JArray(new JObject
                    {
                        ["kind"] = "xnkReturnStmt",
                        ["returnExpr"] = returnExpr
                    })
                };
            }
            else
            {
                // Fallback: empty block (abstract/interface methods shouldn't be here)
                bodyToken = new JObject
                {
                    ["kind"] = "xnkBlockStmt",
                    ["blockBody"] = new JArray()
                };
            }

            return new JObject
            {
                ["kind"] = "xnkFuncDecl",
                ["funcName"] = method.Identifier.Text,
                ["params"] = new JArray(parameters),
                ["returnType"] = new JObject { ["kind"] = "xnkNamedType", ["typeName"] = method.ReturnType.ToString() },
                ["body"] = bodyToken,
                ["isAsync"] = method.Modifiers.Any(m => m.IsKind(Microsoft.CodeAnalysis.CSharp.SyntaxKind.AsyncKeyword)),
                ["funcVisibility"] = ExtractVisibility(method.Modifiers)
            };
        }
    }

    static JObject ConvertBlock(BlockSyntax block)
    {
        return new JObject
        {
            ["kind"] = "xnkBlockStmt",
            ["blockBody"] = new JArray(block.Statements.Select(ConvertStatement))
        };
    }

    static JObject ConvertStatement(StatementSyntax stmt)
    {
        return stmt switch
        {
            BlockSyntax block => ConvertBlock(block),
            ExpressionStatementSyntax exprStmt => ConvertExpressionStatement(exprStmt),
            LocalDeclarationStatementSyntax localDecl => ConvertLocalDeclaration(localDecl),
            ReturnStatementSyntax returnStmt => ConvertReturn(returnStmt),
            IfStatementSyntax ifStmt => ConvertIf(ifStmt),
            ForStatementSyntax forStmt => ConvertFor(forStmt),
            TryStatementSyntax tryStmt => ConvertTry(tryStmt),
            WhileStatementSyntax whileStmt => ConvertWhile(whileStmt),
            ForEachStatementSyntax forEachStmt => ConvertForEach(forEachStmt),
            ThrowStatementSyntax throwStmt => ConvertThrow(throwStmt),
            SwitchStatementSyntax switchStmt => ConvertSwitch(switchStmt),
            UsingStatementSyntax usingStmt => ConvertUsing(usingStmt),
            LockStatementSyntax lockStmt => ConvertLock(lockStmt),
            DoStatementSyntax doStmt => ConvertDo(doStmt),
            YieldStatementSyntax yieldStmt => ConvertYield(yieldStmt),
            BreakStatementSyntax breakStmt => ConvertBreak(breakStmt),
            ContinueStatementSyntax continueStmt => ConvertContinue(continueStmt),
            GotoStatementSyntax gotoStmt => ConvertGoto(gotoStmt),
            LabeledStatementSyntax labeled => ConvertLabeledStatement(labeled),
            EmptyStatementSyntax empty => ConvertEmptyStatement(empty),
            FixedStatementSyntax fixedStmt => ConvertFixedStatement(fixedStmt),
            LocalFunctionStatementSyntax localFunc => ConvertLocalFunctionStatement(localFunc),
            UnsafeStatementSyntax unsafeStmt => ConvertUnsafeStatement(unsafeStmt),
            CheckedStatementSyntax checkedStmt => ConvertCheckedStatement(checkedStmt),
            _ => CreateUnknownNode(stmt, "statement")
        };
    }

    static JObject ConvertExpressionStatement(ExpressionStatementSyntax exprStmt)
    {
        return ConvertExpression(exprStmt.Expression);
    }

    static JObject ConvertExpression(ExpressionSyntax expr)
    {
        return expr switch
        {
            LiteralExpressionSyntax literal => ConvertLiteral(literal),
            ParenthesizedExpressionSyntax paren => ConvertExpression(paren.Expression),
            CheckedExpressionSyntax checkedExpr => ConvertCheckedExpression(checkedExpr),
            ConditionalExpressionSyntax conditional => ConvertConditional(conditional),
            PredefinedTypeSyntax predefinedType => ConvertPredefinedType(predefinedType),
            IsPatternExpressionSyntax isPattern => ConvertIsPattern(isPattern),
            DeclarationExpressionSyntax declExpr => ConvertDeclarationExpression(declExpr),
            InterpolatedStringExpressionSyntax interpolated => ConvertInterpolatedString(interpolated),
            GenericNameSyntax genericName => ConvertGenericName(genericName),
            TypeOfExpressionSyntax typeOf => ConvertTypeOf(typeOf),
            BaseExpressionSyntax baseExpr => ConvertBase(baseExpr),
            ConditionalAccessExpressionSyntax condAccess => ConvertConditionalAccess(condAccess),
            ThrowExpressionSyntax throwExpr => ConvertThrowExpression(throwExpr),
            ParenthesizedLambdaExpressionSyntax parenLambda => ConvertLambda(parenLambda),
            SimpleLambdaExpressionSyntax simpleLambda => ConvertLambda(simpleLambda),
            AnonymousMethodExpressionSyntax anonymousMethod => ConvertAnonymousMethodExpression(anonymousMethod),
            DefaultExpressionSyntax defaultExpr => ConvertDefaultExpression(defaultExpr),
            AwaitExpressionSyntax awaitExpr => ConvertAwaitExpression(awaitExpr),
            IdentifierNameSyntax ident => ConvertIdentifier(ident),
            MemberAccessExpressionSyntax memberAccess => ConvertMemberAccess(memberAccess),
            AssignmentExpressionSyntax assignment => ConvertAssignment(assignment),
            BinaryExpressionSyntax binary => ConvertBinary(binary),
            PrefixUnaryExpressionSyntax prefix => ConvertPrefixUnary(prefix),
            PostfixUnaryExpressionSyntax postfix => ConvertPostfixUnary(postfix),
            InvocationExpressionSyntax inv => ConvertInvocation(inv),
            ObjectCreationExpressionSyntax objCreate => ConvertObjectCreation(objCreate),
            AnonymousObjectCreationExpressionSyntax anonObjectCreate => ConvertAnonymousObjectCreationExpression(anonObjectCreate),
            ImplicitObjectCreationExpressionSyntax implicitObjCreate => ConvertImplicitObjectCreation(implicitObjCreate),
            CastExpressionSyntax cast => ConvertCast(cast),
            ElementAccessExpressionSyntax elemAccess => ConvertElementAccess(elemAccess),
            ThisExpressionSyntax thisExpr => ConvertThis(thisExpr),
            ArrayCreationExpressionSyntax arrayCreate => ConvertArrayCreation(arrayCreate),
            InitializerExpressionSyntax initializer => ConvertInitializer(initializer),
            StackAllocArrayCreationExpressionSyntax stackAlloc => ConvertStackAllocArray(stackAlloc),
            ImplicitArrayCreationExpressionSyntax implicitArray => ConvertImplicitArrayCreation(implicitArray),
            QualifiedNameSyntax qualifiedName => ConvertQualifiedName(qualifiedName),
            SwitchExpressionSyntax switchExpr => ConvertSwitchExpression(switchExpr),
            QueryExpressionSyntax queryExpr => ConvertQueryExpression(queryExpr),
            TupleExpressionSyntax tupleExpr => ConvertTupleExpression(tupleExpr),
            RefExpressionSyntax refExpr => ConvertRefExpression(refExpr),
            RefValueExpressionSyntax refValueExpr => ConvertRefValueExpression(refValueExpr),
            MakeRefExpressionSyntax makeRefExpr => ConvertMakeRefExpression(makeRefExpr),
            RefTypeExpressionSyntax refTypeExpr => ConvertRefTypeExpression(refTypeExpr),
            SizeOfExpressionSyntax sizeOf => ConvertSizeOf(sizeOf),
            ArrayTypeSyntax arrayType => ConvertArrayType(arrayType),
            NullableTypeSyntax nullableType => ConvertNullableType(nullableType),
            AliasQualifiedNameSyntax aliasQualified => ConvertAliasQualifiedName(aliasQualified),
            _ => CreateUnknownNode(expr, "expression")
        };
    }

    static JObject ConvertInvocation(InvocationExpressionSyntax inv)
    {
        return new JObject
        {
            ["kind"] = "xnkCallExpr",
            ["callee"] = ConvertExpression(inv.Expression),
            ["args"] = new JArray(inv.ArgumentList.Arguments.Select(arg => ConvertExpression(arg.Expression)))
        };
    }

    // Expression converters
    static JObject ConvertLiteral(LiteralExpressionSyntax literal)
    {
        // Map C# literal kinds to xlang literal kinds
        string xlangKind;

        if (literal.Kind() == Microsoft.CodeAnalysis.CSharp.SyntaxKind.NumericLiteralExpression)
        {
            xlangKind = "xnkNumberLit";
        }
        else
        {
            xlangKind = literal.Kind() switch
            {
                Microsoft.CodeAnalysis.CSharp.SyntaxKind.StringLiteralExpression => "xnkStringLit",
                Microsoft.CodeAnalysis.CSharp.SyntaxKind.CharacterLiteralExpression => "xnkCharLit",
                Microsoft.CodeAnalysis.CSharp.SyntaxKind.TrueLiteralExpression => "xnkBoolLit",
                Microsoft.CodeAnalysis.CSharp.SyntaxKind.FalseLiteralExpression => "xnkBoolLit",
                Microsoft.CodeAnalysis.CSharp.SyntaxKind.NullLiteralExpression => "xnkNilLit",
                Microsoft.CodeAnalysis.CSharp.SyntaxKind.DefaultLiteralExpression => "xnkNilLit",
                _ => "xnkUnknownLit" // Default fallback
            };
        }

        var result = new JObject
        {
            ["kind"] = xlangKind
        };

        // Different literal types use different field names
        if (xlangKind == "xnkBoolLit")
        {
            result["boolValue"] = literal.Kind() == Microsoft.CodeAnalysis.CSharp.SyntaxKind.TrueLiteralExpression;
        }
        else if (xlangKind == "xnkNumberLit")
        {
            result["numberValue"] = literal.Token.Text;  // Preserve exact literal format
        }
        else
        {
            result["literalValue"] = literal.Token.Value?.ToString() ?? literal.Token.Text;
        }

        return result;
    }

    static JObject ConvertIdentifier(IdentifierNameSyntax ident)
    {
        return new JObject
        {
            ["kind"] = "xnkIdentifier",
            ["identName"] = ident.Identifier.Text
        };
    }

    static JObject ConvertMemberAccess(MemberAccessExpressionSyntax memberAccess)
    {
        return new JObject
        {
            ["kind"] = "xnkMemberAccessExpr",
            ["memberExpr"] = ConvertExpression(memberAccess.Expression),
            ["memberName"] = memberAccess.Name.Identifier.Text
        };
    }

    static JObject ConvertAssignment(AssignmentExpressionSyntax assignment)
    {
        return new JObject
        {
            ["kind"] = "xnkAsgn",
            ["asgnLeft"] = ConvertExpression(assignment.Left),
            ["asgnRight"] = ConvertExpression(assignment.Right)
        };
    }

    static string MapBinaryOpToSemantic(string csharpOp)
    {
        return csharpOp switch
        {
            // Arithmetic
            "+" => "add",
            "-" => "sub",
            "*" => "mul",
            "/" => "div",
            "%" => "mod",

            // Bitwise
            "&" => "bitand",
            "|" => "bitor",
            "^" => "bitxor",
            "<<" => "shl",
            ">>" => "shr",
            ">>>" => "shru",

            // Comparison
            "==" => "eq",
            "!=" => "neq",
            "<" => "lt",
            "<=" => "le",
            ">" => "gt",
            ">=" => "ge",

            // Logical
            "&&" => "and",
            "||" => "or",

            // Assignment (compound)
            "+=" => "adda",
            "-=" => "suba",
            "*=" => "mula",
            "/=" => "diva",
            "%=" => "moda",
            "&=" => "bitanda",
            "|=" => "bitora",
            "^=" => "bitxora",
            "<<=" => "shla",
            ">>=" => "shra",
            ">>>=" => "shrua",

            // Special
            "??" => "nullcoalesce",
            "is" => "istype",
            "as" => "as",

            _ => csharpOp  // Fallback: return original if not mapped
        };
    }

    static JObject ConvertBinary(BinaryExpressionSyntax binary)
    {
        // Check for null coalescing operator ??
        if (binary.OperatorToken.Text == "??")
        {
            return new JObject
            {
                ["kind"] = "xnkExternal_NullCoalesce",
                ["extNullCoalesceLeft"] = ConvertExpression(binary.Left),
                ["extNullCoalesceRight"] = ConvertExpression(binary.Right)
            };
        }

        return new JObject
        {
            ["kind"] = "xnkBinaryExpr",
            ["binaryLeft"] = ConvertExpression(binary.Left),
            ["binaryRight"] = ConvertExpression(binary.Right),
            ["binaryOp"] = MapBinaryOpToSemantic(binary.OperatorToken.Text)
        };
    }

    static JObject ConvertObjectCreation(ObjectCreationExpressionSyntax objCreate)
    {
        return new JObject
        {
            ["kind"] = "xnkCallExpr",
            ["callee"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = objCreate.Type.ToString()
            },
            ["args"] = objCreate.ArgumentList != null
                ? new JArray(objCreate.ArgumentList.Arguments.Select(arg => ConvertExpression(arg.Expression)))
                : new JArray()
        };
    }

    // Statement converters
    static JObject ConvertLocalDeclaration(LocalDeclarationStatementSyntax localDecl)
    {
        // If multiple variables, return a block with individual declarations
        if (localDecl.Declaration.Variables.Count > 1)
        {
            var varDecls = new JArray();
            foreach (var variable in localDecl.Declaration.Variables)
            {
                varDecls.Add(new JObject
                {
                    ["kind"] = "xnkVarDecl",
                    ["declName"] = variable.Identifier.Text,
                    ["declType"] = new JObject
                    {
                        ["kind"] = "xnkNamedType",
                        ["typeName"] = localDecl.Declaration.Type.ToString()
                    },
                    ["initializer"] = variable.Initializer != null
                        ? ConvertExpression(variable.Initializer.Value)
                        : JValue.CreateNull()
                });
            }
            return new JObject
            {
                ["kind"] = "xnkBlockStmt",
                ["blockBody"] = varDecls
            };
        }
        else {
        // Single variable declaration
        var singleVar = localDecl.Declaration.Variables[0];
        return new JObject
        {
            ["kind"] = "xnkVarDecl",
            ["declName"] = singleVar.Identifier.Text,
            ["declType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = localDecl.Declaration.Type.ToString()
            },
            ["initializer"] = singleVar.Initializer != null
                ? ConvertExpression(singleVar.Initializer.Value)
                : JValue.CreateNull()
        };
        }
    }

    static JObject ConvertReturn(ReturnStatementSyntax returnStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkReturnStmt",
            ["returnExpr"] = returnStmt.Expression != null
                ? ConvertExpression(returnStmt.Expression)
                : JValue.CreateNull()
        };
    }

    static JObject ConvertIf(IfStatementSyntax ifStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkIfStmt",
            ["ifCondition"] = ConvertExpression(ifStmt.Condition),
            ["ifBody"] = ConvertStatement(ifStmt.Statement),
            ["elseBody"] = ifStmt.Else != null
                ? ConvertStatement(ifStmt.Else.Statement)
                : JValue.CreateNull()
        };
    }

    static JObject ConvertFor(ForStatementSyntax forStmt)
    {
        // Convert declaration to init expression if present
        JToken initExpr = JValue.CreateNull();
        if (forStmt.Declaration != null)
        {
            var firstVar = forStmt.Declaration.Variables.FirstOrDefault();
            if (firstVar != null)
            {
                initExpr = new JObject
                {
                    ["kind"] = "xnkVarDecl",
                    ["declName"] = firstVar.Identifier.Text,
                    ["declType"] = new JObject
                    {
                        ["kind"] = "xnkNamedType",
                        ["typeName"] = forStmt.Declaration.Type.ToString()
                    },
                    ["initializer"] = firstVar.Initializer != null ? ConvertExpression(firstVar.Initializer.Value) : JValue.CreateNull()
                };
            }
        }
        else if (forStmt.Initializers.Any())
        {
            initExpr = ConvertExpression(forStmt.Initializers.First());
        }

        // Convert incrementors - take first one for simple case
        JToken incrExpr = JValue.CreateNull();
        if (forStmt.Incrementors.Any())
        {
            incrExpr = ConvertExpression(forStmt.Incrementors.First());
        }

        return new JObject
        {
            ["kind"] = "xnkExternal_ForStmt",
            ["extForInit"] = initExpr,
            ["extForCond"] = forStmt.Condition != null ? ConvertExpression(forStmt.Condition) : JValue.CreateNull(),
            ["extForIncrement"] = incrExpr,
            ["extForBody"] = ConvertStatement(forStmt.Statement)
        };
    }

    static JObject ConvertWhile(WhileStatementSyntax whileStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkWhileStmt",
            ["whileCondition"] = ConvertExpression(whileStmt.Condition),
            ["whileBody"] = ConvertStatement(whileStmt.Statement)
        };
    }

    static JObject ConvertForEach(ForEachStatementSyntax forEachStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkForeachStmt",
            ["foreachVar"] = new JObject
            {
                ["kind"] = "xnkVarDecl",
                ["declName"] = forEachStmt.Identifier.Text,
                ["declType"] = new JObject
                {
                    ["kind"] = "xnkNamedType",
                    ["typeName"] = forEachStmt.Type.ToString()
                },
                ["initializer"] = JValue.CreateNull()
            },
            ["foreachIter"] = ConvertExpression(forEachStmt.Expression),
            ["foreachBody"] = ConvertStatement(forEachStmt.Statement)
        };
    }

    static JObject ConvertTry(TryStatementSyntax tryStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkTryStmt",
            ["tryBody"] = ConvertBlock(tryStmt.Block),
            ["catchClauses"] = new JArray(tryStmt.Catches.Select(c => new JObject
            {
                ["kind"] = "xnkCatchStmt",
                ["catchType"] = c.Declaration != null ? new JObject
                {
                    ["kind"] = "xnkNamedType",
                    ["typeName"] = c.Declaration.Type.ToString()
                } : JValue.CreateNull(),
                ["catchVar"] = c.Declaration != null && !string.IsNullOrEmpty(c.Declaration.Identifier.Text)
                    ? c.Declaration.Identifier.Text
                    : JValue.CreateNull(),
                ["catchBody"] = ConvertBlock(c.Block)
            })),
            ["finallyClause"] = tryStmt.Finally != null
                ? ConvertBlock(tryStmt.Finally.Block)
                : JValue.CreateNull()
        };
    }

    // Class member converters
    static JObject ConvertField(FieldDeclarationSyntax field)
    {
        // For fields, we'll just return the first variable as a single field
        // Multiple field declarations like "int x, y;" are rare in modern C#
        var firstVar = field.Declaration.Variables[0];

        // Check if this is a const declaration
        bool isConst = field.Modifiers.Any(m => m.IsKind(Microsoft.CodeAnalysis.CSharp.SyntaxKind.ConstKeyword));
        bool isStatic = field.Modifiers.Any(m => m.IsKind(Microsoft.CodeAnalysis.CSharp.SyntaxKind.StaticKeyword));

        if (isConst || isStatic)
        {
            // Emit as xnkConstDecl for const/static fields (both are module-level in Nim)
            return new JObject
            {
                ["kind"] = "xnkConstDecl",
                ["declName"] = firstVar.Identifier.Text,
                ["declType"] = ConvertType(field.Declaration.Type),
                ["initializer"] = firstVar.Initializer != null
                    ? ConvertExpression(firstVar.Initializer.Value)
                    : JValue.CreateNull()
            };
        }
        else
        {
            // Regular instance field
            return new JObject
            {
                ["kind"] = "xnkFieldDecl",
                ["fieldName"] = firstVar.Identifier.Text,
                ["fieldType"] = ConvertType(field.Declaration.Type),
                ["fieldInitializer"] = firstVar.Initializer != null
                    ? ConvertExpression(firstVar.Initializer.Value)
                    : JValue.CreateNull()
            };
        }
    }

    static JObject ConvertProperty(PropertyDeclarationSyntax property)
    {
        var result = new JObject
        {
            ["kind"] = "xnkExternal_Property",
            ["extPropName"] = property.Identifier.Text
        };

        // extPropType as XLangNode
        result["extPropType"] = ConvertType(property.Type);

        // extPropGetter and extPropSetter as Option[XLangNode]
        // Handle expression-bodied properties: public int Age => 42;
        if (property.ExpressionBody != null)
        {
            // Expression-bodied property is a getter-only property
            result["extPropGetter"] = new JObject
            {
                ["kind"] = "xnkBlockStmt",
                ["blockBody"] = new JArray(new JObject
                {
                    ["kind"] = "xnkReturnStmt",
                    ["returnExpr"] = ConvertExpression(property.ExpressionBody.Expression)
                })
            };
        }
        else if (property.AccessorList != null)
        {
            // Handle explicit accessor list: public int Age { get { return 42; } set { ... } }
            var getAccessor = property.AccessorList.Accessors.FirstOrDefault(a => a.Kind() == Microsoft.CodeAnalysis.CSharp.SyntaxKind.GetAccessorDeclaration);
            if (getAccessor != null)
            {
                if (getAccessor.Body != null)
                {
                    result["extPropGetter"] = ConvertBlock(getAccessor.Body);
                }
                else if (getAccessor.ExpressionBody != null)
                {
                    // Expression-bodied accessor: get => expression;
                    result["extPropGetter"] = new JObject
                    {
                        ["kind"] = "xnkBlockStmt",
                        ["blockBody"] = new JArray(new JObject
                        {
                            ["kind"] = "xnkReturnStmt",
                            ["returnExpr"] = ConvertExpression(getAccessor.ExpressionBody.Expression)
                        })
                    };
                }
            }

            var setAccessor = property.AccessorList.Accessors.FirstOrDefault(a => a.Kind() == Microsoft.CodeAnalysis.CSharp.SyntaxKind.SetAccessorDeclaration);
            if (setAccessor != null)
            {
                if (setAccessor.Body != null)
                {
                    result["extPropSetter"] = ConvertBlock(setAccessor.Body);
                }
                else if (setAccessor.ExpressionBody != null)
                {
                    // Expression-bodied accessor: set => field = value;
                    result["extPropSetter"] = new JObject
                    {
                        ["kind"] = "xnkBlockStmt",
                        ["blockBody"] = new JArray(ConvertExpression(setAccessor.ExpressionBody.Expression))
                    };
                }
            }
        }

        return result;
    }

    static JObject ConvertConstructor(ConstructorDeclarationSyntax constructor)
    {
        return new JObject
        {
            ["kind"] = "xnkConstructorDecl",
            ["constructorParams"] = new JArray(constructor.ParameterList.Parameters.Select(p => new JObject
            {
                ["kind"] = "xnkParameter",
                ["paramName"] = p.Identifier.Text,
                ["paramType"] = p.Type != null ? ConvertType(p.Type) : new JObject { ["kind"] = "xnkNamedType", ["typeName"] = "auto" },
                ["defaultValue"] = p.Default != null ? ConvertExpression(p.Default.Value) : JValue.CreateNull()
            })),
            // TODO: Handle constructor initializers: this(...) and base(...) calls
            ["constructorInitializers"] = constructor.Initializer != null
                ? new JArray(new JObject
                {
                    ["kind"] = constructor.Initializer.ThisOrBaseKeyword.Text == "base" ? "xnkBaseCall" : "xnkThisCall",
                    ["arguments"] = new JArray(constructor.Initializer.ArgumentList.Arguments.Select(arg => ConvertExpression(arg.Expression)))
                })
                : new JArray(),
            ["constructorBody"] = constructor.Body != null ? ConvertBlock(constructor.Body) : JValue.CreateNull()
        };
    }
}
