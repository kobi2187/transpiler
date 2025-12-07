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
    // Additional Expression converters
    static JObject ConvertPrefixUnary(PrefixUnaryExpressionSyntax prefix)
    {
        return new JObject
        {
            ["kind"] = "xnkUnaryExpr",
            ["unaryOp"] = prefix.OperatorToken.Text,
            ["unaryOperand"] = ConvertExpression(prefix.Operand),
            ["isPrefix"] = true
        };
    }
    static JObject ConvertPostfixUnary(PostfixUnaryExpressionSyntax postfix)
    {
        return new JObject
        {
            ["kind"] = "xnkUnaryExpr",
            ["unaryOp"] = postfix.OperatorToken.Text,
            ["unaryOperand"] = ConvertExpression(postfix.Operand),
            ["isPrefix"] = false
        };
    }
    static JObject ConvertCast(CastExpressionSyntax cast)
    {
        return new JObject
        {
            ["kind"] = "xnkCastExpr",
            ["castExpr"] = ConvertExpression(cast.Expression),
            ["castType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = cast.Type.ToString()
            }
        };
    }
    static JObject ConvertElementAccess(ElementAccessExpressionSyntax elemAccess)
    {
        return new JObject
        {
            ["kind"] = "xnkIndexExpr",
            ["indexExpr"] = ConvertExpression(elemAccess.Expression),
            ["indexArgs"] = new JArray(elemAccess.ArgumentList.Arguments.Select(arg => ConvertExpression(arg.Expression)))
        };
    }
    static JObject ConvertThis(ThisExpressionSyntax thisExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkThisExpr"
        };
    }
    static JObject ConvertArrayCreation(ArrayCreationExpressionSyntax arrayCreate)
    {
        // If there's an initializer, use xnkSequenceLiteral, otherwise use xnkCallExpr with array type
        if (arrayCreate.Initializer != null)
        {
            return ConvertInitializer(arrayCreate.Initializer);
        }
        else
        {
            // Array creation without initializer (e.g., new int[5])
            return new JObject
            {
                ["kind"] = "xnkCallExpr",
                ["callee"] = new JObject
                {
                    ["kind"] = "xnkArrayType",
                    ["elementType"] = new JObject
                    {
                        ["kind"] = "xnkNamedType",
                        ["typeName"] = arrayCreate.Type.ElementType.ToString()
                    }
                },
                ["args"] = new JArray()
            };
        }
    }
    static JObject ConvertInitializer(InitializerExpressionSyntax initializer)
    {
        // Map to xnkSequenceLiteral for array/collection initializers
        return new JObject
        {
            ["kind"] = "xnkSequenceLiteral",
            ["elements"] = new JArray(initializer.Expressions.Select(ConvertExpression))
        };
    }
    // Additional Statement converters
    static JObject ConvertThrow(ThrowStatementSyntax throwStmt)
    {
        // C# throw → xnkRaiseStmt (unified with Python raise)
        return new JObject
        {
            ["kind"] = "xnkRaiseStmt",
            ["raiseExpr"] = throwStmt.Expression != null
        ? ConvertExpression(throwStmt.Expression)
        : JValue.CreateNull()
        };
    }
    static JObject ConvertSwitch(SwitchStatementSyntax switchStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkSwitchStmt",
            ["switchExpr"] = ConvertExpression(switchStmt.Expression),
            ["switchCases"] = new JArray(switchStmt.Sections.SelectMany(section =>
            {
                // Body is shared by all labels in this section
                var body = new JObject
                {
                    ["kind"] = "xnkBlockStmt",
                    ["blockBody"] = new JArray(section.Statements.Select(ConvertStatement))
                };

                // Create one clause per label
                return section.Labels.Select(label =>
                {
                    if (label is CaseSwitchLabelSyntax caseLabel)
                    {
                        return new JObject
                        {
                            ["kind"] = "xnkCaseClause",
                            ["caseValues"] = new JArray(new[] { ConvertExpression(caseLabel.Value) }),
                            ["caseBody"] = body
                        };
                    }
                    else // DefaultSwitchLabel
                    {
                        return new JObject
                        {
                            ["kind"] = "xnkDefaultClause",
                            ["defaultBody"] = body
                        };
                    }
                });
            }))
        };
    }
    static JObject ConvertUsing(UsingStatementSyntax usingStmt)
    {
        // Convert C# using to unified xnkResourceStmt
        var resourceItems = new JArray();

        if (usingStmt.Declaration != null)
        {
            // using (Type var = expr) → resource items with declarations
            foreach (var variable in usingStmt.Declaration.Variables)
            {
                resourceItems.Add(new JObject
                {
                    ["kind"] = "xnkResourceItem",
                    ["resourceExpr"] = variable.Initializer != null
                        ? ConvertExpression(variable.Initializer.Value)
                        : JValue.CreateNull(),
                    ["resourceVar"] = new JObject
                    {
                        ["kind"] = "xnkVarDecl",
                        ["declName"] = variable.Identifier.Text,
                        ["declType"] = new JObject
                        {
                            ["kind"] = "xnkNamedType",
                            ["typeName"] = usingStmt.Declaration.Type.ToString()
                        },
                        ["initializer"] = JValue.CreateNull()
                    },
                    ["cleanupHint"] = "Dispose"
                });
            }
        }
        else if (usingStmt.Expression != null)
        {
            // using (expr) → resource item without declaration
            resourceItems.Add(new JObject
            {
                ["kind"] = "xnkResourceItem",
                ["resourceExpr"] = ConvertExpression(usingStmt.Expression),
                ["resourceVar"] = JValue.CreateNull(),
                ["cleanupHint"] = "Dispose"
            });
        }

        return new JObject
        {
            ["kind"] = "xnkResourceStmt",
            ["resourceItems"] = resourceItems,
            ["resourceBody"] = ConvertStatement(usingStmt.Statement)
        };
    }
    static JObject ConvertLock(LockStatementSyntax lockStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkLockStmt",
            ["expr"] = ConvertExpression(lockStmt.Expression),
            ["statement"] = ConvertStatement(lockStmt.Statement)
        };
    }
    static JObject ConvertDo(DoStatementSyntax doStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkDoWhileStmt",
            ["condition"] = ConvertExpression(doStmt.Condition),
            ["statement"] = ConvertStatement(doStmt.Statement)
        };
    }
    static JObject ConvertYield(YieldStatementSyntax yieldStmt)
    {
        // C# yield return → xnkIteratorYield (unified with Python yield)
        return new JObject
        {
            ["kind"] = "xnkIteratorYield",
            ["iteratorYieldValue"] = yieldStmt.Expression != null
                ? ConvertExpression(yieldStmt.Expression)
                : JValue.CreateNull()
        };
    }
    // More expression converters
    static JObject ConvertCheckedExpression(CheckedExpressionSyntax checkedExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkCheckedExpr",
            ["isChecked"] = checkedExpr.Kind() == Microsoft.CodeAnalysis.CSharp.SyntaxKind.CheckedExpression,
            ["expr"] = ConvertExpression(checkedExpr.Expression)
        };
    }
    static JObject ConvertConditional(ConditionalExpressionSyntax conditional)
    {
        return new JObject
        {
            ["kind"] = "xnkTernaryExpr",
            ["ternaryCondition"] = ConvertExpression(conditional.Condition),
            ["ternaryThen"] = ConvertExpression(conditional.WhenTrue),
            ["ternaryElse"] = ConvertExpression(conditional.WhenFalse)
        };
    }
    static JObject ConvertPredefinedType(PredefinedTypeSyntax predefinedType)
    {
        return new JObject
        {
            ["kind"] = "xnkNamedType",
            ["name"] = predefinedType.Keyword.Text
        };
    }
    static JObject ConvertIsPattern(IsPatternExpressionSyntax isPattern)
    {
        // C# "is pattern" maps to TypeAssertion for simple type checks
        return new JObject
        {
            ["kind"] = "xnkTypeAssertion",
            ["assertExpr"] = ConvertExpression(isPattern.Expression),
            ["assertType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = isPattern.Pattern.ToString()
            }
        };
    }
    static JObject ConvertDeclarationExpression(DeclarationExpressionSyntax declExpr)
    {
        // Maps to xnkVarDecl for inline variable declarations (e.g., "out var x")
        return new JObject
        {
            ["kind"] = "xnkVarDecl",
            ["declName"] = declExpr.Designation.ToString(),
            ["declType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = declExpr.Type.ToString()
            },
            ["initializer"] = null
        };
    }
    static JObject ConvertInterpolatedString(InterpolatedStringExpressionSyntax interpolated)
    {
        return new JObject
        {
            ["kind"] = "xnkStringInterpolation",
            ["interpParts"] = new JArray(interpolated.Contents.Select(c =>
                c is InterpolatedStringTextSyntax text
                    ? (JObject)new JObject { ["kind"] = "xnkStringLit", ["literalValue"] = text.TextToken.ValueText }
                    : ConvertExpression(((InterpolationSyntax)c).Expression)
            )),
            ["interpIsExpr"] = new JArray(interpolated.Contents.Select(c => c is InterpolationSyntax))
        };
    }
    static JObject ConvertGenericName(GenericNameSyntax genericName)
    {
        return new JObject
        {
            ["kind"] = "xnkGenericName",
            ["identifier"] = genericName.Identifier.Text,
            ["typeArguments"] = new JArray(genericName.TypeArgumentList.Arguments.Select(arg => arg.ToString()))
        };
    }
    static JObject ConvertTypeOf(TypeOfExpressionSyntax typeOf)
    {
        return new JObject
        {
            ["kind"] = "xnkTypeOfExpr",
            ["type"] = typeOf.Type.ToString()
        };
    }
    static JObject ConvertBase(BaseExpressionSyntax baseExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkBaseExpr"
        };
    }
    static JObject ConvertConditionalAccess(ConditionalAccessExpressionSyntax condAccess)
    {
        // C# ?. operator → xnkSafeNavigationExpr (xnkConditionalAccessExpr was duplicate)
        return new JObject
        {
            ["kind"] = "xnkSafeNavigationExpr",
            ["safeObject"] = ConvertExpression(condAccess.Expression),
            ["safeMember"] = condAccess.WhenNotNull.ToString()
        };
    }
    static JObject ConvertThrowExpression(ThrowExpressionSyntax throwExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkThrowExpr",
            ["expr"] = ConvertExpression(throwExpr.Expression)
        };
    }
    static JObject ConvertLambda(LambdaExpressionSyntax lambda)
    {
        return new JObject
        {
            ["kind"] = "xnkLambdaExpr",
            ["lambdaKind"] = lambda.Kind().ToString(),
            ["parameters"] = lambda is ParenthesizedLambdaExpressionSyntax paren
        ? new JArray(paren.ParameterList.Parameters.Select(p => p.Identifier.Text))
        : lambda is SimpleLambdaExpressionSyntax simple
        ? new JArray(simple.Parameter.Identifier.Text)
        : new JArray(),
            ["body"] = lambda.Body.ToString()
        };
    }
    static JObject ConvertDefaultExpression(DefaultExpressionSyntax defaultExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkDefaultExpr",
            ["type"] = defaultExpr.Type?.ToString() ?? "default"
        };
    }
    static JObject ConvertAwaitExpression(AwaitExpressionSyntax awaitExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkAwaitExpr",
            ["awaitExpr"] = ConvertExpression(awaitExpr.Expression)
        };
    }
    static JObject ConvertAnonymousMethodExpression(AnonymousMethodExpressionSyntax anonymousMethod)
    {
        return new JObject
        {
            ["kind"] = "xnkLambdaExpr",
            ["lambdaParams"] = anonymousMethod.ParameterList != null
        ? new JArray(anonymousMethod.ParameterList.Parameters.Select(p => new JObject { ["kind"] = "xnkIdentifier", ["identName"] = p.Identifier.Text }))
        : new JArray(),
            ["lambdaBody"] = ConvertBlock(anonymousMethod.Block)
        };
    }
    static JObject ConvertQueryExpression(QueryExpressionSyntax queryExpr)
    {
        // The initial collection
        JObject currentCollection = ConvertExpression(queryExpr.FromClause.Expression);
        string currentIdentifier = queryExpr.FromClause.Identifier.Text;

        // Build the chain of method calls
        foreach (var clause in queryExpr.Body.Clauses)
        {
            if (clause is WhereClauseSyntax whereClause)
            {
                currentCollection = new JObject
                {
                    ["kind"] = "xnkCallExpr",
                    ["callee"] = new JObject
                    {
                        ["kind"] = "xnkMemberAccessExpr",
                        ["memberExpr"] = currentCollection,
                        ["memberName"] = "Where"
                    },
                    ["args"] = new JArray(new JObject
                    {
                        ["kind"] = "xnkLambdaExpr",
                        ["lambdaParams"] = new JArray(new JObject { ["kind"] = "xnkIdentifier", ["identName"] = currentIdentifier }),
                        ["lambdaBody"] = ConvertExpression(whereClause.Condition)
                    })
                };
            }
            else if (clause is OrderByClauseSyntax orderByClause)
            {
                bool firstOrdering = true;
                foreach (var ordering in orderByClause.Orderings)
                {
                    string methodName = firstOrdering ? "OrderBy" : "ThenBy";
                    if (ordering.AscendingOrDescendingKeyword.IsKind(SyntaxKind.DescendingKeyword))
                    {
                        methodName += "Descending";
                    }

                    currentCollection = new JObject
                    {
                        ["kind"] = "xnkCallExpr",
                        ["callee"] = new JObject
                        {
                            ["kind"] = "xnkMemberAccessExpr",
                            ["memberExpr"] = currentCollection,
                            ["memberName"] = methodName
                        },
                        ["args"] = new JArray(new JObject
                        {
                            ["kind"] = "xnkLambdaExpr",
                            ["lambdaParams"] = new JArray(new JObject { ["kind"] = "xnkIdentifier", ["identName"] = currentIdentifier }),
                            ["lambdaBody"] = ConvertExpression(ordering.Expression)
                        })
                    };
                    firstOrdering = false;
                }
            }
            // TODO: Handle other clauses like join, let
        }

        // Handle the final select or group clause
        if (queryExpr.Body.SelectOrGroup is SelectClauseSyntax selectClause)
        {
            currentCollection = new JObject
            {
                ["kind"] = "xnkCallExpr",
                ["callee"] = new JObject
                {
                    ["kind"] = "xnkMemberAccessExpr",
                    ["memberExpr"] = currentCollection,
                    ["memberName"] = "Select"
                },
                ["args"] = new JArray(new JObject
                {
                    ["kind"] = "xnkLambdaExpr",
                    ["lambdaParams"] = new JArray(new JObject { ["kind"] = "xnkIdentifier", ["identName"] = currentIdentifier }),
                    ["lambdaBody"] = ConvertExpression(selectClause.Expression)
                })
            };
        }
        else if (queryExpr.Body.SelectOrGroup is GroupClauseSyntax groupClause)
        {
            currentCollection = new JObject
            {
                ["kind"] = "xnkCallExpr",
                ["callee"] = new JObject
                {
                    ["kind"] = "xnkMemberAccessExpr",
                    ["memberExpr"] = currentCollection,
                    ["memberName"] = "GroupBy"
                },
                ["args"] = new JArray(
                    new JObject
                    {
                        ["kind"] = "xnkLambdaExpr",
                        ["lambdaParams"] = new JArray(new JObject { ["kind"] = "xnkIdentifier", ["identName"] = currentIdentifier }),
                        ["lambdaBody"] = ConvertExpression(groupClause.ByExpression)
                    },
                    new JObject
                    {
                        ["kind"] = "xnkLambdaExpr",
                        ["lambdaParams"] = new JArray(new JObject { ["kind"] = "xnkIdentifier", ["identName"] = currentIdentifier }),
                        ["lambdaBody"] = ConvertExpression(groupClause.GroupExpression)
                    }
                )
            };
        }

        if (queryExpr.Body.Continuation != null)
        {
            // This is a query continuation like 'into ...'
            // The logic here is complex. For now, create an unknown node.
            return CreateUnknownNode(queryExpr, "expression");
        }

        return currentCollection;
    }
    static JObject ConvertTupleExpression(TupleExpressionSyntax tupleExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkTupleExpr",
            ["elements"] = new JArray(tupleExpr.Arguments.Select(arg => ConvertExpression(arg.Expression)))
        };
    }
    static JObject ConvertAnonymousObjectCreationExpression(AnonymousObjectCreationExpressionSyntax anonObject)
    {
        // C# anonymous objects → xnkMapLiteral with entries
        var entries = new JArray();
        foreach (var initializer in anonObject.Initializers)
        {
            // NameEquals can be null if the property name is inferred.
            var name = initializer.NameEquals?.Name.Identifier.Text ?? (initializer.Expression as IdentifierNameSyntax)?.Identifier.Text;
            if (name != null)
            {
                entries.Add(new JObject
                {
                    ["kind"] = "xnkDictEntry",
                    ["key"] = new JObject
                    {
                        ["kind"] = "xnkStringLit",
                        ["value"] = name
                    },
                    ["value"] = ConvertExpression(initializer.Expression)
                });
            }
            else
            {
                // Could be a more complex expression where name is inferred, e.g. new { a.b, a.c }
                // For now, we'll just create an unknown entry for this initializer.
                entries.Add(new JObject
                {
                    ["kind"] = "xnkDictEntry",
                    ["key"] = new JObject
                    {
                        ["kind"] = "xnkStringLit",
                        ["value"] = "unknown"
                    },
                    ["value"] = CreateUnknownNode(initializer, "anonymous_initializer")
                });
            }
        }
        return new JObject
        {
            ["kind"] = "xnkMapLiteral",
            ["entries"] = entries
        };
    }
    static JObject ConvertNullableType(NullableTypeSyntax nullableType)
    {
        return new JObject
        {
            ["kind"] = "xnkGenericType",
            ["genericTypeName"] = "Nullable",
            ["genericArgs"] = new JArray(ConvertExpression(nullableType.ElementType))
        };
    }
    static JObject ConvertRefValueExpression(RefValueExpressionSyntax refValueExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkCallExpr",
            ["callee"] = new JObject
            {
                ["kind"] = "xnkIdentifier",
                ["identName"] = "__refvalue"
            },
            ["args"] = new JArray(
        ConvertExpression(refValueExpr.Expression),
        ConvertExpression(refValueExpr.Type)
        )
        };
    }
    static JObject ConvertMakeRefExpression(MakeRefExpressionSyntax makeRefExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkCallExpr",
            ["callee"] = new JObject
            {
                ["kind"] = "xnkIdentifier",
                ["identName"] = "__makeref"
            },
            ["args"] = new JArray(ConvertExpression(makeRefExpr.Expression))
        };
    }
    static JObject ConvertRefTypeExpression(RefTypeExpressionSyntax refTypeExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkCallExpr",
            ["callee"] = new JObject
            {
                ["kind"] = "xnkIdentifier",
                ["identName"] = "__reftype"
            },
            ["args"] = new JArray(ConvertExpression(refTypeExpr.Expression))
        };
    }
    // More statement converters
    static JObject ConvertBreak(BreakStatementSyntax breakStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkBreakStmt"
        };
    }
    static JObject ConvertContinue(ContinueStatementSyntax continueStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkContinueStmt"
        };
    }
    static JObject ConvertGoto(GotoStatementSyntax gotoStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkGotoStmt",
            ["gotoKind"] = gotoStmt.Kind().ToString(),
            ["label"] = gotoStmt.Expression?.ToString() ?? ""
        };
    }
    static JObject ConvertLabeledStatement(LabeledStatementSyntax labeled)
    {
        return new JObject
        {
            ["kind"] = "xnkLabeledStmt",
            ["label"] = labeled.Identifier.Text,
            ["statement"] = ConvertStatement(labeled.Statement)
        };
    }
    static JObject ConvertEmptyStatement(EmptyStatementSyntax empty)
    {
        return new JObject
        {
            ["kind"] = "xnkEmptyStmt"
        };
    }
    // Additional expression converters
    static JObject ConvertStackAllocArray(StackAllocArrayCreationExpressionSyntax stackAlloc)
    {
        return new JObject
        {
            ["kind"] = "xnkStackAllocExpr",
            ["type"] = stackAlloc.Type.ToString(),
            ["initializer"] = stackAlloc.Initializer != null
        ? ConvertInitializer(stackAlloc.Initializer)
        : JValue.CreateNull()
        };
    }
    static JObject ConvertImplicitArrayCreation(ImplicitArrayCreationExpressionSyntax implicitArray)
    {
        return new JObject
        {
            ["kind"] = "xnkImplicitArrayCreation",
            ["initializer"] = ConvertInitializer(implicitArray.Initializer)
        };
    }
    static JObject ConvertQualifiedName(QualifiedNameSyntax qualifiedName)
    {
        return new JObject
        {
            ["kind"] = "xnkQualifiedName",
            ["left"] = qualifiedName.Left.ToString(),
            ["right"] = qualifiedName.Right.ToString()
        };
    }
    static JObject ConvertSwitchExpression(SwitchExpressionSyntax switchExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkSwitchExpr",
            ["governingExpression"] = ConvertExpression(switchExpr.GoverningExpression),
            ["arms"] = new JArray(switchExpr.Arms.Select(arm => new JObject
            {
                ["pattern"] = arm.Pattern.ToString(),
                ["expression"] = ConvertExpression(arm.Expression)
            }))
        };
    }
    static JObject ConvertRefExpression(RefExpressionSyntax refExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkRefExpr",
            ["expression"] = ConvertExpression(refExpr.Expression)
        };
    }
    static JObject ConvertSizeOf(SizeOfExpressionSyntax sizeOf)
    {
        return new JObject
        {
            ["kind"] = "xnkSizeOfExpr",
            ["type"] = sizeOf.Type.ToString()
        };
    }
    static JObject ConvertArrayType(ArrayTypeSyntax arrayType)
    {
        return new JObject
        {
            ["kind"] = "xnkArrayType",
            ["elementType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = arrayType.ElementType.ToString()
            },
            ["arraySize"] = JValue.CreateNull()  // C# arrays don't have compile-time size in type
        };
    }
    static JObject ConvertAliasQualifiedName(AliasQualifiedNameSyntax aliasQualified)
    {
        return new JObject
        {
            ["kind"] = "xnkAliasQualifiedName",
            ["alias"] = aliasQualified.Alias.ToString(),
            ["name"] = aliasQualified.Name.ToString()
        };
    }
    // Additional statement converters
    static JObject ConvertFixedStatement(FixedStatementSyntax fixedStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkFixedStmt",
            ["declaration"] = new JObject
            {
                ["type"] = fixedStmt.Declaration.Type.ToString(),
                ["variables"] = new JArray(fixedStmt.Declaration.Variables.Select(v => new JObject
                {
                    ["name"] = v.Identifier.Text,
                    ["initializer"] = v.Initializer != null ? ConvertExpression(v.Initializer.Value) : JValue.CreateNull()
                }))
            },
            ["statement"] = ConvertStatement(fixedStmt.Statement)
        };
    }
    static JObject ConvertLocalFunctionStatement(LocalFunctionStatementSyntax localFunc)
    {
        return new JObject
        {
            ["kind"] = "xnkLocalFunctionStmt",
            ["returnType"] = localFunc.ReturnType.ToString(),
            ["identifier"] = localFunc.Identifier.Text,
            ["parameters"] = new JArray(localFunc.ParameterList.Parameters.Select(p => new JObject
            {
                ["name"] = p.Identifier.Text,
                ["type"] = p.Type?.ToString() ?? "var"
            })),
            ["body"] = localFunc.Body != null ? ConvertBlock(localFunc.Body) : JValue.CreateNull()
        };
    }
    static JObject ConvertUnsafeStatement(UnsafeStatementSyntax unsafeStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkUnsafeStmt",
            ["block"] = ConvertBlock(unsafeStmt.Block)
        };
    }
    static JObject ConvertCheckedStatement(CheckedStatementSyntax checkedStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkCheckedStmt",
            ["isChecked"] = checkedStmt.Kind() == Microsoft.CodeAnalysis.CSharp.SyntaxKind.CheckedStatement,
            ["block"] = ConvertBlock(checkedStmt.Block)
        };
    }
    // Type declaration converters
    static JObject ConvertEnum(EnumDeclarationSyntax enumDecl)
    {
        return new JObject
        {
            ["kind"] = "xnkEnumDecl",
            ["identifier"] = enumDecl.Identifier.Text,
            ["modifiers"] = string.Join(" ", enumDecl.Modifiers.Select(m => m.Text)),
            ["baseType"] = enumDecl.BaseList?.Types.FirstOrDefault()?.ToString() ?? "",
            ["members"] = new JArray(enumDecl.Members.Select(m => new JObject
            {
                ["name"] = m.Identifier.Text,
                ["value"] = m.EqualsValue?.Value.ToString() ?? ""
            }))
        };
    }
    static JObject ConvertInterface(InterfaceDeclarationSyntax interfaceDecl)
    {
        return new JObject
        {
            ["kind"] = "xnkInterfaceDecl",
            ["identifier"] = interfaceDecl.Identifier.Text,
            ["modifiers"] = string.Join(" ", interfaceDecl.Modifiers.Select(m => m.Text)),
            ["members"] = new JArray(interfaceDecl.Members.Select(m => ConvertMemberDeclaration(m)))
        };
    }
    static JObject ConvertStruct(StructDeclarationSyntax structDecl)
    {
        return new JObject
        {
            ["kind"] = "xnkStructDecl",
            ["identifier"] = structDecl.Identifier.Text,
            ["modifiers"] = string.Join(" ", structDecl.Modifiers.Select(m => m.Text)),
            ["members"] = new JArray(structDecl.Members.Select(ConvertClassMember))
        };
    }
    static JObject ConvertDelegate(DelegateDeclarationSyntax delegateDecl)
    {
        return new JObject
        {
            ["kind"] = "xnkDelegateDecl",
            ["identifier"] = delegateDecl.Identifier.Text,
            ["modifiers"] = string.Join(" ", delegateDecl.Modifiers.Select(m => m.Text)),
            ["returnType"] = delegateDecl.ReturnType.ToString(),
            ["parameters"] = new JArray(delegateDecl.ParameterList.Parameters.Select(p => new JObject
            {
                ["name"] = p.Identifier.Text,
                ["type"] = p.Type?.ToString() ?? "var"
            }))
        };
    }
    // Class member converters for advanced members
    static JObject ConvertOperator(OperatorDeclarationSyntax operatorDecl)
    {
        return new JObject
        {
            ["kind"] = "xnkOperatorDecl",
            ["operatorToken"] = operatorDecl.OperatorToken.Text,
            ["modifiers"] = string.Join(" ", operatorDecl.Modifiers.Select(m => m.Text)),
            ["returnType"] = operatorDecl.ReturnType.ToString(),
            ["parameters"] = new JArray(operatorDecl.ParameterList.Parameters.Select(p => new JObject
            {
                ["name"] = p.Identifier.Text,
                ["type"] = p.Type?.ToString() ?? "var"
            })),
            ["body"] = operatorDecl.Body != null ? ConvertBlock(operatorDecl.Body) : JValue.CreateNull()
        };
    }
    static JObject ConvertConversionOperator(ConversionOperatorDeclarationSyntax conversionOp)
    {
        return new JObject
        {
            ["kind"] = "xnkConversionOperatorDecl",
            ["implicitOrExplicitKeyword"] = conversionOp.ImplicitOrExplicitKeyword.Text,
            ["modifiers"] = string.Join(" ", conversionOp.Modifiers.Select(m => m.Text)),
            ["type"] = conversionOp.Type.ToString(),
            ["parameters"] = new JArray(conversionOp.ParameterList.Parameters.Select(p => new JObject
            {
                ["name"] = p.Identifier.Text,
                ["type"] = p.Type?.ToString() ?? "var"
            })),
            ["body"] = conversionOp.Body != null ? ConvertBlock(conversionOp.Body) : JValue.CreateNull()
        };
    }
    static JObject ConvertIndexer(IndexerDeclarationSyntax indexer)
    {
        return new JObject
        {
            ["kind"] = "xnkIndexerDecl",
            ["type"] = indexer.Type.ToString(),
            ["modifiers"] = string.Join(" ", indexer.Modifiers.Select(m => m.Text)),
            ["parameters"] = new JArray(indexer.ParameterList.Parameters.Select(p => new JObject
            {
                ["name"] = p.Identifier.Text,
                ["type"] = p.Type?.ToString() ?? "var"
            })),
            ["accessors"] = indexer.AccessorList != null
        ? new JArray(indexer.AccessorList.Accessors.Select(a => new JObject
        {
            ["kind"] = a.Kind().ToString(),
            ["body"] = a.Body != null ? ConvertBlock(a.Body) : JValue.CreateNull()
        }))
        : new JArray()
        };
    }
    static JObject ConvertDestructor(DestructorDeclarationSyntax destructor)
    {
        return new JObject
        {
            ["kind"] = "xnkDestructorDecl",
            ["identifier"] = destructor.Identifier.Text,
            ["modifiers"] = string.Join(" ", destructor.Modifiers.Select(m => m.Text)),
            ["body"] = destructor.Body != null ? ConvertBlock(destructor.Body) : JValue.CreateNull()
        };
    }
    static JObject ConvertEventFieldDeclaration(EventFieldDeclarationSyntax eventField)
    {
        // Assuming single event declaration, similar to fields
        var firstVar = eventField.Declaration.Variables[0];
        return new JObject
        {
            ["kind"] = "xnkEventDecl",
            ["eventName"] = firstVar.Identifier.Text,
            ["eventType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = eventField.Declaration.Type.ToString()
            },
            ["modifiers"] = string.Join(" ", eventField.Modifiers.Select(m => m.Text))
        };
    }
    static JObject ConvertEventDeclaration(EventDeclarationSyntax eventDecl)
    {
        var addAccessor = eventDecl.AccessorList?.Accessors.FirstOrDefault(a => a.IsKind(SyntaxKind.AddAccessorDeclaration));
        var removeAccessor = eventDecl.AccessorList?.Accessors.FirstOrDefault(a => a.IsKind(SyntaxKind.RemoveAccessorDeclaration));
        return new JObject
        {
            ["kind"] = "xnkEventDecl",
            ["eventName"] = eventDecl.Identifier.Text,
            ["eventType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = eventDecl.Type.ToString()
            },
            ["modifiers"] = string.Join(" ", eventDecl.Modifiers.Select(m => m.Text)),
            ["addAccessor"] = addAccessor != null
        ? (addAccessor.Body != null ? ConvertBlock(addAccessor.Body) : (addAccessor.ExpressionBody != null ? ConvertExpression(addAccessor.ExpressionBody.Expression) : JValue.CreateNull()))
        : JValue.CreateNull(),
            ["removeAccessor"] = removeAccessor != null
        ? (removeAccessor.Body != null ? ConvertBlock(removeAccessor.Body) : (removeAccessor.ExpressionBody != null ? ConvertExpression(removeAccessor.ExpressionBody.Expression) : JValue.CreateNull()))
        : JValue.CreateNull()
        };
    }
    // Helper for interface members which may differ from class members
    static JObject ConvertMemberDeclaration(MemberDeclarationSyntax member)
    {
        return member switch
        {
            MethodDeclarationSyntax method => ConvertMethod(method),
            PropertyDeclarationSyntax property => ConvertProperty(property),
            _ => new JObject { ["kind"] = "xnkUnknown", ["text"] = member.ToString() }
        };
    }
}
