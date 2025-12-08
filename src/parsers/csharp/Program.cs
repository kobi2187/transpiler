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
            Console.WriteLine("  Batch mode:  csharp-to-xlang --batch <directory>");
            Environment.Exit(1);
        }

        if (args[0] == "--batch" && args.Length >= 2)
        {
            BatchProcessDirectory(args[1]);
        }
        else
        {
            ProcessSingleFile(args[0], outputToConsole: true);
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
            ["syntaxKind"] = node.Kind().ToString(),
            ["nodeType"] = nodeType,
            ["text"] = node.ToString().Length > 100 ? node.ToString().Substring(0, 100) + "..." : node.ToString()
        };
    }

    static JObject ConvertCompilationUnit(CompilationUnitSyntax cu, string fileName)
    {
        var result = new JObject
        {
            ["kind"] = "xnkFile",
            ["fileName"] = Path.GetFileName(fileName),
            ["moduleDecls"] = new JArray(cu.Members.Select(ConvertMember))
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
        return new JObject
        {
            ["kind"] = "xnkNamespace",
            ["namespaceName"] = ns.Name.ToString(),
            ["namespaceBody"] = new JArray(ns.Members.Select(ConvertMember))
        };
    }

    static JObject ConvertClass(ClassDeclarationSyntax cls)
    {
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
            ["members"] = new JArray(cls.Members.Select(ConvertClassMember))
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
            IncompleteMemberSyntax incompleteMember => CreateUnknownNode(incompleteMember, "class_member"),
            _ => CreateUnknownNode(member, "class_member")
        };
    }

    static JObject ConvertMethod(MethodDeclarationSyntax method)
    {
        return new JObject
        {
            ["kind"] = "xnkFuncDecl",
            ["funcName"] = method.Identifier.Text,
            ["params"] = new JArray(),
            ["returnType"] = new JObject { ["kind"] = "xnkNamedType", ["name"] = method.ReturnType.ToString() },
            ["body"] = method.Body != null ? ConvertBlock(method.Body) : JValue.CreateNull()
        };
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
        string xlangKind = literal.Kind() switch
        {
            Microsoft.CodeAnalysis.CSharp.SyntaxKind.NumericLiteralExpression => "xnkIntLit",
            Microsoft.CodeAnalysis.CSharp.SyntaxKind.StringLiteralExpression => "xnkStringLit",
            Microsoft.CodeAnalysis.CSharp.SyntaxKind.CharacterLiteralExpression => "xnkCharLit",
            Microsoft.CodeAnalysis.CSharp.SyntaxKind.TrueLiteralExpression => "xnkBoolLit",
            Microsoft.CodeAnalysis.CSharp.SyntaxKind.FalseLiteralExpression => "xnkBoolLit",
            Microsoft.CodeAnalysis.CSharp.SyntaxKind.NullLiteralExpression => "xnkNilLit",
            Microsoft.CodeAnalysis.CSharp.SyntaxKind.DefaultLiteralExpression => "xnkNilLit",
            _ => "xnkUnknownLit" // Default fallback
        };

        var result = new JObject
        {
            ["kind"] = xlangKind,
            ["literalValue"] = literal.Token.Value?.ToString() ?? literal.Token.Text
        };

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

    static JObject ConvertBinary(BinaryExpressionSyntax binary)
    {
        return new JObject
        {
            ["kind"] = "xnkBinaryExpr",
            ["binaryLeft"] = ConvertExpression(binary.Left),
            ["binaryRight"] = ConvertExpression(binary.Right),
            ["binaryOp"] = binary.OperatorToken.Text
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
                        ["name"] = localDecl.Declaration.Type.ToString()
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
                ["name"] = localDecl.Declaration.Type.ToString()
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
        return new JObject
        {
            ["kind"] = "xnkForStmt",
            ["declaration"] = forStmt.Declaration != null
                ? new JObject
                {
                    ["type"] = forStmt.Declaration.Type.ToString(),
                    ["variables"] = new JArray(forStmt.Declaration.Variables.Select(v => new JObject
                    {
                        ["name"] = v.Identifier.Text,
                        ["initializer"] = v.Initializer != null ? ConvertExpression(v.Initializer.Value) : JValue.CreateNull()
                    }))
                }
                : JValue.CreateNull(),
            ["initializers"] = new JArray(forStmt.Initializers.Select(ConvertExpression)),
            ["condition"] = forStmt.Condition != null ? ConvertExpression(forStmt.Condition) : JValue.CreateNull(),
            ["incrementors"] = new JArray(forStmt.Incrementors.Select(ConvertExpression)),
            ["body"] = ConvertStatement(forStmt.Statement)
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
            ["varName"] = forEachStmt.Identifier.Text,
            ["varType"] = forEachStmt.Type.ToString(),
            ["collection"] = ConvertExpression(forEachStmt.Expression),
            ["body"] = ConvertStatement(forEachStmt.Statement)
        };
    }

    static JObject ConvertTry(TryStatementSyntax tryStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkTryStmt",
            ["tryBlock"] = ConvertBlock(tryStmt.Block),
            ["catches"] = new JArray(tryStmt.Catches.Select(c => new JObject
            {
                ["exceptionType"] = c.Declaration?.Type.ToString() ?? "Exception",
                ["varName"] = c.Declaration?.Identifier.Text ?? "",
                ["body"] = ConvertBlock(c.Block)
            })),
            ["finallyBlock"] = tryStmt.Finally != null
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
        return new JObject
        {
            ["kind"] = "xnkFieldDecl",
            ["fieldName"] = firstVar.Identifier.Text,
            ["fieldType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = field.Declaration.Type.ToString()
            },
            ["fieldInitializer"] = firstVar.Initializer != null
                ? ConvertExpression(firstVar.Initializer.Value)
                : JValue.CreateNull()
        };
    }

    static JObject ConvertProperty(PropertyDeclarationSyntax property)
    {
        var result = new JObject
        {
            ["kind"] = "xnkPropertyDecl",
            ["propName"] = property.Identifier.Text
        };

        // propType as XLangNode (NamedType)
        result["propType"] = new JObject
        {
            ["kind"] = "xnkNamedType",
            ["name"] = property.Type.ToString()
        };

        // getter and setter as Option[XLangNode]
        var getAccessor = property.AccessorList?.Accessors.FirstOrDefault(a => a.Kind() == Microsoft.CodeAnalysis.CSharp.SyntaxKind.GetAccessorDeclaration);
        if (getAccessor != null && getAccessor.Body != null)
        {
            result["getter"] = ConvertBlock(getAccessor.Body);
        }

        var setAccessor = property.AccessorList?.Accessors.FirstOrDefault(a => a.Kind() == Microsoft.CodeAnalysis.CSharp.SyntaxKind.SetAccessorDeclaration);
        if (setAccessor != null && setAccessor.Body != null)
        {
            result["setter"] = ConvertBlock(setAccessor.Body);
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
                ["paramType"] = new JObject
                {
                    ["kind"] = "xnkNamedType",
                    ["typeName"] = p.Type?.ToString() ?? "auto"
                },
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
