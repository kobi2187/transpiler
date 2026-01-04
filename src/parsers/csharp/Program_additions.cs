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
    // Map unary operator to semantic representation
    static string MapUnaryOpToSemantic(string csharpOp, bool isPrefix)
    {
        return csharpOp switch
        {
            "+" => "pos",
            "-" => "neg",
            "!" => "not",
            "~" => "bitnot",
            "++" => isPrefix ? "preinc" : "postinc",
            "--" => isPrefix ? "predec" : "postdec",
            "&" => "addrof",
            "*" => "deref",
            _ => csharpOp  // Fallback
        };
    }

    // Additional Expression converters
    static JObject ConvertPrefixUnary(PrefixUnaryExpressionSyntax prefix)
    {
        return new JObject
        {
            ["kind"] = "xnkUnaryExpr",
            ["unaryOp"] = MapUnaryOpToSemantic(prefix.OperatorToken.Text, isPrefix: true),
            ["unaryOperand"] = ConvertExpression(prefix.Operand)
        };
    }
    static JObject ConvertPostfixUnary(PostfixUnaryExpressionSyntax postfix)
    {
        return new JObject
        {
            ["kind"] = "xnkUnaryExpr",
            ["unaryOp"] = MapUnaryOpToSemantic(postfix.OperatorToken.Text, isPrefix: false),
            ["unaryOperand"] = ConvertExpression(postfix.Operand)
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
                            ["caseBody"] = body,
                            ["caseFallthrough"] = false  // C# doesn't have fallthrough by default
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
        // Convert C# using to external resource statement
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
            ["kind"] = "xnkExternal_Resource",
            ["extResourceItems"] = resourceItems,
            ["extResourceBody"] = ConvertStatement(usingStmt.Statement)
        };
    }
    static JObject ConvertLock(LockStatementSyntax lockStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkExternal_Lock",
            ["extLockExpr"] = ConvertExpression(lockStmt.Expression),
            ["extLockBody"] = ConvertStatement(lockStmt.Statement)
        };
    }
    static JObject ConvertDo(DoStatementSyntax doStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkExternal_DoWhile",
            ["extDoWhileCondition"] = ConvertExpression(doStmt.Condition),
            ["extDoWhileBody"] = ConvertStatement(doStmt.Statement)
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
            ["checkedExpr"] = ConvertExpression(checkedExpr.Expression)
        };
    }
    static JObject ConvertConditional(ConditionalExpressionSyntax conditional)
    {
        return new JObject
        {
            ["kind"] = "xnkExternal_Ternary",
            ["extTernaryCondition"] = ConvertExpression(conditional.Condition),
            ["extTernaryThen"] = ConvertExpression(conditional.WhenTrue),
            ["extTernaryElse"] = ConvertExpression(conditional.WhenFalse)
        };
    }
    static JObject ConvertPredefinedType(PredefinedTypeSyntax predefinedType)
    {
        return new JObject
        {
            ["kind"] = "xnkNamedType",
            ["typeName"] = predefinedType.Keyword.Text
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
            ["kind"] = "xnkExternal_StringInterp",
            ["extInterpParts"] = new JArray(interpolated.Contents.Select(c =>
                c is InterpolatedStringTextSyntax text
                    ? (JObject)new JObject { ["kind"] = "xnkStringLit", ["literalValue"] = text.TextToken.ValueText }
                    : ConvertExpression(((InterpolationSyntax)c).Expression)
            )),
            ["extInterpIsExpr"] = new JArray(interpolated.Contents.Select(c => c is InterpolationSyntax))
        };
    }
    static JObject ConvertGenericName(GenericNameSyntax genericName)
    {
        return new JObject
        {
            ["kind"] = "xnkGenericName",
            ["genericNameIdentifier"] = genericName.Identifier.Text,
            ["genericNameArgs"] = new JArray(genericName.TypeArgumentList.Arguments.Select(arg => new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = arg.ToString()
            }))
        };
    }
    static JObject ConvertTypeOf(TypeOfExpressionSyntax typeOf)
    {
        return new JObject
        {
            ["kind"] = "xnkTypeOfExpr",
            ["typeOfType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = typeOf.Type.ToString()
            }
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
        // C# ?. operator → xnkExternal_SafeNavigation
        return new JObject
        {
            ["kind"] = "xnkExternal_SafeNavigation",
            ["extSafeNavObject"] = ConvertExpression(condAccess.Expression),
            ["extSafeNavMember"] = condAccess.WhenNotNull.ToString()
        };
    }
    static JObject ConvertThrowExpression(ThrowExpressionSyntax throwExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkExternal_ThrowExpr",
            ["extThrowExprValue"] = ConvertExpression(throwExpr.Expression)
        };
    }
    static JObject ConvertLambda(LambdaExpressionSyntax lambda)
    {
        var parameters = lambda is ParenthesizedLambdaExpressionSyntax paren
            ? paren.ParameterList.Parameters.Select(p => new JObject
            {
                ["kind"] = "xnkParameter",
                ["paramName"] = p.Identifier.Text,
                ["paramType"] = p.Type != null ? new JObject
                {
                    ["kind"] = "xnkNamedType",
                    ["typeName"] = p.Type.ToString()
                } : JValue.CreateNull(),
                ["defaultValue"] = JValue.CreateNull()
            })
            : lambda is SimpleLambdaExpressionSyntax simple
            ? new[] { new JObject
            {
                ["kind"] = "xnkParameter",
                ["paramName"] = simple.Parameter.Identifier.Text,
                ["paramType"] = simple.Parameter.Type != null ? new JObject
                {
                    ["kind"] = "xnkNamedType",
                    ["typeName"] = simple.Parameter.Type.ToString()
                } : JValue.CreateNull(),
                ["defaultValue"] = JValue.CreateNull()
            }}
            : Enumerable.Empty<JObject>();

        return new JObject
        {
            ["kind"] = "xnkLambdaExpr",
            ["lambdaParams"] = new JArray(parameters),
            ["lambdaReturnType"] = JValue.CreateNull(),
            ["lambdaBody"] = lambda.Body is BlockSyntax block
                ? ConvertBlock(block)
                : new JObject
                {
                    ["kind"] = "xnkBlockStmt",
                    ["blockBody"] = new JArray(new[] { ConvertExpression((ExpressionSyntax)lambda.Body) })
                }
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
            ["kind"] = "xnkExternal_Await",
            ["extAwaitExpr"] = ConvertExpression(awaitExpr.Expression)
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
            else if (clause is LetClauseSyntax letClause)
            {
                // let x = expr → Select(item => new { item, x = expr })
                // For simplicity, we'll use a tuple-like transformation
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
                        ["lambdaBody"] = new JObject
                        {
                            ["kind"] = "xnkTupleExpr",
                            ["elements"] = new JArray(
                                new JObject { ["kind"] = "xnkIdentifier", ["identName"] = currentIdentifier },
                                ConvertExpression(letClause.Expression)
                            )
                        }
                    })
                };
                // Note: After let, the identifier changes to include the let variable
                // This is simplified - proper handling would track both identifiers
            }
            else if (clause is JoinClauseSyntax joinClause)
            {
                // join x in collection on outerKey equals innerKey
                currentCollection = new JObject
                {
                    ["kind"] = "xnkCallExpr",
                    ["callee"] = new JObject
                    {
                        ["kind"] = "xnkMemberAccessExpr",
                        ["memberExpr"] = currentCollection,
                        ["memberName"] = "Join"
                    },
                    ["args"] = new JArray(
                        ConvertExpression(joinClause.InExpression),
                        new JObject
                        {
                            ["kind"] = "xnkLambdaExpr",
                            ["lambdaParams"] = new JArray(new JObject { ["kind"] = "xnkIdentifier", ["identName"] = currentIdentifier }),
                            ["lambdaBody"] = ConvertExpression(joinClause.LeftExpression)
                        },
                        new JObject
                        {
                            ["kind"] = "xnkLambdaExpr",
                            ["lambdaParams"] = new JArray(new JObject { ["kind"] = "xnkIdentifier", ["identName"] = joinClause.Identifier.Text }),
                            ["lambdaBody"] = ConvertExpression(joinClause.RightExpression)
                        },
                        new JObject
                        {
                            ["kind"] = "xnkLambdaExpr",
                            ["lambdaParams"] = new JArray(
                                new JObject { ["kind"] = "xnkIdentifier", ["identName"] = currentIdentifier },
                                new JObject { ["kind"] = "xnkIdentifier", ["identName"] = joinClause.Identifier.Text }
                            ),
                            ["lambdaBody"] = new JObject
                            {
                                ["kind"] = "xnkTupleExpr",
                                ["elements"] = new JArray(
                                    new JObject { ["kind"] = "xnkIdentifier", ["identName"] = currentIdentifier },
                                    new JObject { ["kind"] = "xnkIdentifier", ["identName"] = joinClause.Identifier.Text }
                                )
                            }
                        }
                    )
                };
            }
            else if (clause is FromClauseSyntax fromClause)
            {
                // Additional from clause → SelectMany
                currentCollection = new JObject
                {
                    ["kind"] = "xnkCallExpr",
                    ["callee"] = new JObject
                    {
                        ["kind"] = "xnkMemberAccessExpr",
                        ["memberExpr"] = currentCollection,
                        ["memberName"] = "SelectMany"
                    },
                    ["args"] = new JArray(new JObject
                    {
                        ["kind"] = "xnkLambdaExpr",
                        ["lambdaParams"] = new JArray(new JObject { ["kind"] = "xnkIdentifier", ["identName"] = currentIdentifier }),
                        ["lambdaBody"] = ConvertExpression(fromClause.Expression)
                    })
                };
                // Update identifier to the new from variable
                currentIdentifier = fromClause.Identifier.Text;
            }
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
            // Query continuation like 'into newVar ...'
            // The continuation creates a new query scope with the result so far
            // We'll wrap this as a nested query with the continuation's clauses
            var continuation = queryExpr.Body.Continuation;
            string contIdentifier = continuation.Identifier.Text;

            // Process continuation clauses
            foreach (var clause in continuation.Body.Clauses)
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
                            ["lambdaParams"] = new JArray(new JObject { ["kind"] = "xnkIdentifier", ["identName"] = contIdentifier }),
                            ["lambdaBody"] = ConvertExpression(whereClause.Condition)
                        })
                    };
                }
                // Add more clause handling as needed
            }

            // Handle continuation's select/group
            if (continuation.Body.SelectOrGroup is SelectClauseSyntax contSelect)
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
                        ["lambdaParams"] = new JArray(new JObject { ["kind"] = "xnkIdentifier", ["identName"] = contIdentifier }),
                        ["lambdaBody"] = ConvertExpression(contSelect.Expression)
                    })
                };
            }
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
            // For inferred names like `new { a.b, a.c }`, the name is the last member (b, c)
            string name = null;

            if (initializer.NameEquals != null)
            {
                // Explicit name: new { Name = value }
                name = initializer.NameEquals.Name.Identifier.Text;
            }
            else if (initializer.Expression is IdentifierNameSyntax identExpr)
            {
                // Simple identifier: new { variableName }
                name = identExpr.Identifier.Text;
            }
            else if (initializer.Expression is MemberAccessExpressionSyntax memberAccess)
            {
                // Member access: new { obj.Property } → name is "Property"
                name = memberAccess.Name.Identifier.Text;
            }

            if (name != null)
            {
                entries.Add(new JObject
                {
                    ["kind"] = "xnkDictEntry",
                    ["key"] = new JObject
                    {
                        ["kind"] = "xnkStringLit",
                        ["literalValue"] = name
                    },
                    ["value"] = ConvertExpression(initializer.Expression)
                });
            }
            else
            {
                // For other complex expressions, use the expression string as key
                entries.Add(new JObject
                {
                    ["kind"] = "xnkDictEntry",
                    ["key"] = new JObject
                    {
                        ["kind"] = "xnkStringLit",
                        ["literalValue"] = initializer.Expression.ToString()
                    },
                    ["value"] = ConvertExpression(initializer.Expression)
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
    static JObject ConvertImplicitObjectCreation(ImplicitObjectCreationExpressionSyntax implicitObjCreate)
    {
        // C# 9.0 target-typed new: new() { ... } or new(args)
        // The type is inferred from context, so we use a placeholder
        return new JObject
        {
            ["kind"] = "xnkCallExpr",
            ["callee"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = "auto"  // Type is inferred from context
            },
            ["args"] = implicitObjCreate.ArgumentList != null
                ? new JArray(implicitObjCreate.ArgumentList.Arguments.Select(arg => ConvertExpression(arg.Expression)))
                : new JArray(),
            ["initializer"] = implicitObjCreate.Initializer != null
                ? ConvertInitializer(implicitObjCreate.Initializer)
                : JValue.CreateNull()
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
            ["gotoLabel"] = gotoStmt.Expression?.ToString() ?? ""
        };
    }
    static JObject ConvertLabeledStatement(LabeledStatementSyntax labeled)
    {
        return new JObject
        {
            ["kind"] = "xnkLabeledStmt",
            ["labelName"] = labeled.Identifier.Text,
            ["labeledStmt"] = ConvertStatement(labeled.Statement)
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
            ["kind"] = "xnkExternal_StackAlloc",
            ["extStackAllocType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = stackAlloc.Type.ToString()
            },
            ["extStackAllocSize"] = stackAlloc.Initializer != null
        ? ConvertInitializer(stackAlloc.Initializer)
        : JValue.CreateNull()
        };
    }
    static JObject ConvertImplicitArrayCreation(ImplicitArrayCreationExpressionSyntax implicitArray)
    {
        return new JObject
        {
            ["kind"] = "xnkImplicitArrayCreation",
            ["implicitArrayElements"] = new JArray(implicitArray.Initializer.Expressions.Select(ConvertExpression))
        };
    }
    static JObject ConvertQualifiedName(QualifiedNameSyntax qualifiedName)
    {
        // Convert the right side properly - it could be an identifier or a generic name
        JToken rightSide = qualifiedName.Right switch
        {
            GenericNameSyntax genericName => ConvertGenericName(genericName),
            IdentifierNameSyntax identName => new JObject
            {
                ["kind"] = "xnkIdentifier",
                ["identName"] = identName.Identifier.Text
            },
            _ => JToken.FromObject(qualifiedName.Right.ToString()) // Fallback to string
        };

        return new JObject
        {
            ["kind"] = "xnkQualifiedName",
            ["qualifiedLeft"] = new JObject
            {
                ["kind"] = "xnkIdentifier",
                ["identName"] = qualifiedName.Left.ToString()
            },
            ["qualifiedRight"] = rightSide
        };
    }
    static JObject ConvertSwitchExpression(SwitchExpressionSyntax switchExpr)
    {
        var arms = switchExpr.Arms.Select(arm =>
        {
            // Convert pattern to expression form for matching
            // For constant patterns (e.g., 1, "foo"), extract the expression
            // For discard patterns (_), use identifier "_"
            JObject patternExpr;
            if (arm.Pattern is ConstantPatternSyntax constantPattern)
            {
                patternExpr = ConvertExpression(constantPattern.Expression);
            }
            else if (arm.Pattern is DiscardPatternSyntax)
            {
                patternExpr = new JObject
                {
                    ["kind"] = "xnkIdentifier",
                    ["identName"] = "_"
                };
            }
            else
            {
                // For other patterns, convert to string representation
                patternExpr = new JObject
                {
                    ["kind"] = "xnkIdentifier",
                    ["identName"] = arm.Pattern.ToString()
                };
            }

            return new JObject
            {
                ["kind"] = "xnkSwitchCase",
                ["switchCaseConditions"] = new JArray { patternExpr },
                ["switchCaseBody"] = ConvertExpression(arm.Expression)
            };
        });

        return new JObject
        {
            ["kind"] = "xnkExternal_SwitchExpr",
            ["extSwitchExprValue"] = ConvertExpression(switchExpr.GoverningExpression),
            ["extSwitchExprArms"] = new JArray(arms)
        };
    }
    static JObject ConvertRefExpression(RefExpressionSyntax refExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkRefExpr",
            ["refExpr"] = ConvertExpression(refExpr.Expression)
        };
    }
    static JObject ConvertSizeOf(SizeOfExpressionSyntax sizeOf)
    {
        return new JObject
        {
            ["kind"] = "xnkSizeOfExpr",
            ["sizeOfType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = sizeOf.Type.ToString()
            }
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
            ["aliasQualifier"] = aliasQualified.Alias.ToString(),
            ["aliasQualifiedName"] = aliasQualified.Name.ToString()
        };
    }
    // Additional statement converters
    static JObject ConvertFixedStatement(FixedStatementSyntax fixedStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkExternal_Fixed",
            ["extFixedDeclarations"] = new JArray(fixedStmt.Declaration.Variables.Select(v => new JObject
            {
                ["kind"] = "xnkVarDecl",
                ["declName"] = v.Identifier.Text,
                ["declType"] = new JObject
                {
                    ["kind"] = "xnkNamedType",
                    ["typeName"] = fixedStmt.Declaration.Type.ToString()
                },
                ["initializer"] = v.Initializer != null ? ConvertExpression(v.Initializer.Value) : JValue.CreateNull()
            })),
            ["extFixedBody"] = ConvertStatement(fixedStmt.Statement)
        };
    }
    static JObject ConvertLocalFunctionStatement(LocalFunctionStatementSyntax localFunc)
    {
        return new JObject
        {
            ["kind"] = "xnkExternal_LocalFunction",
            ["extLocalFuncName"] = localFunc.Identifier.Text,
            ["extLocalFuncParams"] = new JArray(localFunc.ParameterList.Parameters.Select(p => new JObject
            {
                ["kind"] = "xnkParameter",
                ["paramName"] = p.Identifier.Text,
                ["paramType"] = new JObject
                {
                    ["kind"] = "xnkNamedType",
                    ["typeName"] = p.Type?.ToString() ?? "auto"
                },
                ["defaultValue"] = JValue.CreateNull()
            })),
            ["extLocalFuncReturnType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = localFunc.ReturnType.ToString()
            },
            ["extLocalFuncBody"] = localFunc.Body != null ? ConvertBlock(localFunc.Body) : JValue.CreateNull()
        };
    }
    static JObject ConvertUnsafeStatement(UnsafeStatementSyntax unsafeStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkExternal_Unsafe",
            ["extUnsafeBody"] = ConvertBlock(unsafeStmt.Block)
        };
    }
    static JObject ConvertCheckedStatement(CheckedStatementSyntax checkedStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkExternal_Checked",
            ["extCheckedIsChecked"] = checkedStmt.Kind() == Microsoft.CodeAnalysis.CSharp.SyntaxKind.CheckedStatement,
            ["extCheckedBody"] = ConvertBlock(checkedStmt.Block)
        };
    }
    // Type declaration converters
    static JObject ConvertEnum(EnumDeclarationSyntax enumDecl)
    {
        return new JObject
        {
            ["kind"] = "xnkEnumDecl",
            ["enumName"] = enumDecl.Identifier.Text,
            ["enumMembers"] = new JArray(enumDecl.Members.Select(m => new JObject
            {
                ["kind"] = "xnkEnumMember",
                ["enumMemberName"] = m.Identifier.Text,
                ["enumMemberValue"] = m.EqualsValue != null ? ConvertExpression(m.EqualsValue.Value) : JValue.CreateNull()
            }))
        };
    }
    static JObject ConvertInterface(InterfaceDeclarationSyntax interfaceDecl)
    {
        var members = new JArray();

        // For each member, first add any doc comments, then the member itself
        foreach (var member in interfaceDecl.Members)
        {
            var docComments = ExtractDocComments(member);
            foreach (var comment in docComments)
            {
                members.Add(comment);
            }
            members.Add(ConvertMemberDeclaration(member));
        }

        return new JObject
        {
            ["kind"] = "xnkExternal_Interface",
            ["extInterfaceName"] = interfaceDecl.Identifier.Text,
            ["extInterfaceBaseTypes"] = interfaceDecl.BaseList != null
                ? new JArray(interfaceDecl.BaseList.Types.Select(t => new JObject
                {
                    ["kind"] = "xnkNamedType",
                    ["typeName"] = t.Type.ToString()
                }))
                : new JArray(),
            ["extInterfaceMembers"] = members
        };
    }
    static JObject ConvertStruct(StructDeclarationSyntax structDecl)
    {
        var members = new JArray();

        // For each member, first add any doc comments, then the member itself
        foreach (var member in structDecl.Members)
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
            ["kind"] = "xnkStructDecl",
            ["typeNameDecl"] = structDecl.Identifier.Text,
            ["baseTypes"] = structDecl.BaseList != null
                ? new JArray(structDecl.BaseList.Types.Select(t => new JObject
                {
                    ["kind"] = "xnkNamedType",
                    ["typeName"] = t.Type.ToString()
                }))
                : new JArray(),
            ["members"] = members
        };
    }
    static JObject ConvertDelegate(DelegateDeclarationSyntax delegateDecl)
    {
        return new JObject
        {
            ["kind"] = "xnkExternal_Delegate",
            ["extDelegateName"] = delegateDecl.Identifier.Text,
            ["extDelegateParams"] = new JArray(delegateDecl.ParameterList.Parameters.Select(p => new JObject
            {
                ["kind"] = "xnkParameter",
                ["paramName"] = p.Identifier.Text,
                ["paramType"] = new JObject
                {
                    ["kind"] = "xnkNamedType",
                    ["typeName"] = p.Type?.ToString() ?? "auto"
                }
            })),
            ["extDelegateReturnType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = delegateDecl.ReturnType.ToString()
            }
        };
    }
    // Class member converters for advanced members
    static JObject ConvertOperator(OperatorDeclarationSyntax operatorDecl)
    {
        JToken bodyJson;
        if (operatorDecl.Body != null)
        {
            bodyJson = ConvertBlock(operatorDecl.Body);
        }
        else if (operatorDecl.ExpressionBody != null)
        {
            bodyJson = new JObject
            {
                ["kind"] = "xnkBlockStmt",
                ["blockBody"] = new JArray(new JObject
                {
                    ["kind"] = "xnkReturnStmt",
                    ["returnExpr"] = ConvertExpression(operatorDecl.ExpressionBody.Expression)
                })
            };
        }
        else
        {
            bodyJson = JValue.CreateNull();
        }

        return new JObject
        {
            ["kind"] = "xnkExternal_Operator",
            ["extOperatorSymbol"] = operatorDecl.OperatorToken.Text,
            ["extOperatorParams"] = new JArray(operatorDecl.ParameterList.Parameters.Select(p => new JObject
            {
                ["kind"] = "xnkParameter",
                ["paramName"] = p.Identifier.Text,
                ["paramType"] = new JObject
                {
                    ["kind"] = "xnkNamedType",
                    ["typeName"] = p.Type?.ToString() ?? "auto"
                },
                ["defaultValue"] = JValue.CreateNull()
            })),
            ["extOperatorReturnType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = operatorDecl.ReturnType.ToString()
            },
            ["extOperatorBody"] = bodyJson
        };
    }
    static JObject ConvertConversionOperator(ConversionOperatorDeclarationSyntax conversionOp)
    {
        // Handle both block bodies and expression bodies (=>)
        JToken bodyJson;
        if (conversionOp.Body != null)
        {
            bodyJson = ConvertBlock(conversionOp.Body);
        }
        else if (conversionOp.ExpressionBody != null)
        {
            // Convert expression body (=>) to a block with return statement
            bodyJson = new JObject
            {
                ["kind"] = "xnkBlockStmt",
                ["blockBody"] = new JArray
                {
                    new JObject
                    {
                        ["kind"] = "xnkReturnStmt",
                        ["returnExpr"] = ConvertExpression(conversionOp.ExpressionBody.Expression)
                    }
                }
            };
        }
        else
        {
            bodyJson = JValue.CreateNull();
        }

        // Extract parameter name for conversion function
        var paramName = "value";  // default
        if (conversionOp.ParameterList.Parameters.Count > 0)
        {
            paramName = conversionOp.ParameterList.Parameters[0].Identifier.Text;
        }

        return new JObject
        {
            ["kind"] = "xnkExternal_ConversionOp",
            ["extConversionIsImplicit"] = conversionOp.ImplicitOrExplicitKeyword.Text == "implicit",
            ["extConversionParamName"] = paramName,
            ["extConversionFromType"] = conversionOp.ParameterList.Parameters.Count > 0
                ? new JObject
                {
                    ["kind"] = "xnkNamedType",
                    ["typeName"] = conversionOp.ParameterList.Parameters[0].Type?.ToString() ?? "unknown"
                }
                : new JObject { ["kind"] = "xnkNamedType", ["typeName"] = "unknown" },
            ["extConversionToType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = conversionOp.Type.ToString()
            },
            ["extConversionBody"] = bodyJson
        };
    }
    static JObject ConvertIndexer(IndexerDeclarationSyntax indexer)
    {
        var getAccessor = indexer.AccessorList?.Accessors.FirstOrDefault(a => a.Kind() == Microsoft.CodeAnalysis.CSharp.SyntaxKind.GetAccessorDeclaration);
        var setAccessor = indexer.AccessorList?.Accessors.FirstOrDefault(a => a.Kind() == Microsoft.CodeAnalysis.CSharp.SyntaxKind.SetAccessorDeclaration);

        // Handle expression-bodied indexer (e.g., public T this[int i] => arr[i];)
        JToken getterBody = JValue.CreateNull();
        JToken setterBody = JValue.CreateNull();

        if (indexer.ExpressionBody != null)
        {
            // Expression-bodied indexer (getter only)
            getterBody = new JObject
            {
                ["kind"] = "xnkBlockStmt",
                ["blockBody"] = new JArray(new JObject
                {
                    ["kind"] = "xnkReturnStmt",
                    ["returnExpr"] = ConvertExpression(indexer.ExpressionBody.Expression)
                })
            };
        }
        else if (indexer.AccessorList != null)
        {
            if (getAccessor != null)
            {
                if (getAccessor.Body != null)
                {
                    getterBody = ConvertBlock(getAccessor.Body);
                }
                else if (getAccessor.ExpressionBody != null)
                {
                    getterBody = new JObject
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

            if (setAccessor != null)
            {
                if (setAccessor.Body != null)
                {
                    setterBody = ConvertBlock(setAccessor.Body);
                }
                else if (setAccessor.ExpressionBody != null)
                {
                    setterBody = new JObject
                    {
                        ["kind"] = "xnkBlockStmt",
                        ["blockBody"] = new JArray(ConvertExpression(setAccessor.ExpressionBody.Expression))
                    };
                }
            }
        }

        return new JObject
        {
            ["kind"] = "xnkExternal_Indexer",
            ["extIndexerType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = indexer.Type.ToString()
            },
            ["extIndexerParams"] = new JArray(indexer.ParameterList.Parameters.Select(p => new JObject
            {
                ["kind"] = "xnkParameter",
                ["paramName"] = p.Identifier.Text,
                ["paramType"] = new JObject
                {
                    ["kind"] = "xnkNamedType",
                    ["typeName"] = p.Type?.ToString() ?? "auto"
                },
                ["defaultValue"] = JValue.CreateNull()
            })),
            ["extIndexerGetter"] = getterBody,
            ["extIndexerSetter"] = setterBody
        };
    }
    static JObject ConvertDestructor(DestructorDeclarationSyntax destructor)
    {
        return new JObject
        {
            ["kind"] = "xnkDestructorDecl",
            ["destructorBody"] = destructor.Body != null ? ConvertBlock(destructor.Body) : JValue.CreateNull()
        };
    }
    static JObject ConvertEventFieldDeclaration(EventFieldDeclarationSyntax eventField)
    {
        // Assuming single event declaration, similar to fields
        var firstVar = eventField.Declaration.Variables[0];
        return new JObject
        {
            ["kind"] = "xnkExternal_Event",
            ["extEventName"] = firstVar.Identifier.Text,
            ["extEventType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = eventField.Declaration.Type.ToString()
            }
        };
    }
    static JObject ConvertEventDeclaration(EventDeclarationSyntax eventDecl)
    {
        var addAccessor = eventDecl.AccessorList?.Accessors.FirstOrDefault(a => a.IsKind(SyntaxKind.AddAccessorDeclaration));
        var removeAccessor = eventDecl.AccessorList?.Accessors.FirstOrDefault(a => a.IsKind(SyntaxKind.RemoveAccessorDeclaration));
        return new JObject
        {
            ["kind"] = "xnkExternal_Event",
            ["extEventName"] = eventDecl.Identifier.Text,
            ["extEventType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = eventDecl.Type.ToString()
            },
            ["extEventAdd"] = addAccessor != null
        ? (addAccessor.Body != null ? ConvertBlock(addAccessor.Body) : (addAccessor.ExpressionBody != null ? ConvertExpression(addAccessor.ExpressionBody.Expression) : JValue.CreateNull()))
        : JValue.CreateNull(),
            ["extEventRemove"] = removeAccessor != null
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
            _ => new JObject { ["kind"] = "xnkUnknown", ["unknownData"] = member.ToString() }
        };
    }

    static JObject ConvertIncompleteMember(IncompleteMemberSyntax incompleteMember)
    {
        // IncompleteMemberSyntax represents a member that couldn't be fully parsed
        // It typically has a Type property that indicates what was being declared
        // This can happen with code that's still being edited or has syntax errors

        // Try to extract useful information
        var typeStr = incompleteMember.Type?.ToString() ?? "unknown";

        // If it looks like a field declaration (just a type), create a placeholder field
        if (incompleteMember.Type != null)
        {
            return new JObject
            {
                ["kind"] = "xnkFieldDecl",
                ["fieldName"] = "_incomplete_",  // Placeholder name
                ["fieldType"] = ConvertType(incompleteMember.Type),
                ["fieldInitializer"] = JValue.CreateNull(),
                ["isIncomplete"] = true  // Mark it as incomplete for downstream processing
            };
        }

        // Fallback to unknown
        return new JObject
        {
            ["kind"] = "xnkUnknown",
            ["unknownData"] = incompleteMember.ToString().Length > 100
                ? incompleteMember.ToString().Substring(0, 100) + "..."
                : incompleteMember.ToString(),
            ["context"] = "incomplete_member"
        };
    }

    // New C# constructs support (C# 8-12)

    static JObject ConvertFileScopedNamespace(FileScopedNamespaceDeclarationSyntax ns)
    {
        var namespaceBody = new JArray();

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

    static JObject ConvertRecord(RecordDeclarationSyntax record)
    {
        var members = new JArray();

        foreach (var member in record.Members)
        {
            var docComments = ExtractDocComments(member);
            foreach (var comment in docComments)
            {
                members.Add(comment);
            }
            members.Add(ConvertClassMember(member));
        }

        // Handle positional parameters if present
        JArray recordParams = new JArray();
        if (record.ParameterList != null)
        {
            foreach (var param in record.ParameterList.Parameters)
            {
                recordParams.Add(new JObject
                {
                    ["kind"] = "xnkParameter",
                    ["paramName"] = param.Identifier.Text,
                    ["paramType"] = param.Type != null ? ConvertType(param.Type) : JValue.CreateNull()
                });
            }
        }

        return new JObject
        {
            ["kind"] = "xnkExternal_Record",
            ["extRecordName"] = record.Identifier.Text,
            ["extRecordParams"] = recordParams,
            ["extRecordBaseTypes"] = record.BaseList != null
                ? new JArray(record.BaseList.Types.Select(t => new JObject
                {
                    ["kind"] = "xnkNamedType",
                    ["typeName"] = t.Type.ToString()
                }))
                : new JArray(),
            ["extRecordMembers"] = members
        };
    }

    static JObject ConvertCollectionExpression(CollectionExpressionSyntax collectionExpr)
    {
        var elements = new JArray();
        foreach (var element in collectionExpr.Elements)
        {
            if (element is ExpressionElementSyntax exprElem)
            {
                elements.Add(ConvertExpression(exprElem.Expression));
            }
            else
            {
                elements.Add(JValue.CreateNull());
            }
        }

        return new JObject
        {
            ["kind"] = "xnkSequenceLiteral",
            ["elements"] = elements
        };
    }

    static JObject ConvertRangeExpression(RangeExpressionSyntax rangeExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkSliceExpr",
            ["sliceExpr"] = JValue.CreateNull(),  // In C#, range is standalone, not applied to an object here
            ["sliceStart"] = rangeExpr.LeftOperand != null
                ? ConvertExpression(rangeExpr.LeftOperand)
                : JValue.CreateNull(),
            ["sliceEnd"] = rangeExpr.RightOperand != null
                ? ConvertExpression(rangeExpr.RightOperand)
                : JValue.CreateNull(),
            ["sliceStep"] = JValue.CreateNull()  // C# ranges don't have step
        };
    }

    static JObject ConvertWithExpression(WithExpressionSyntax withExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkExternal_With",
            ["extWithExpression"] = ConvertExpression(withExpr.Expression),
            ["extWithInitializer"] = withExpr.Initializer != null
                ? ConvertInitializer(withExpr.Initializer)
                : JValue.CreateNull()
        };
    }

    static JObject ConvertForEachVariable(ForEachVariableStatementSyntax forEachVar)
    {
        return new JObject
        {
            ["kind"] = "xnkForeachStmt",
            ["foreachVar"] = new JObject
            {
                ["kind"] = "xnkVarDecl",
                ["declName"] = forEachVar.Variable.ToString(),
                ["declType"] = new JObject
                {
                    ["kind"] = "xnkNamedType",
                    ["typeName"] = "auto"
                },
                ["initializer"] = JValue.CreateNull()
            },
            ["foreachIter"] = ConvertExpression(forEachVar.Expression),
            ["foreachBody"] = ConvertStatement(forEachVar.Statement)
        };
    }

    static JObject ConvertImplicitElementAccess(ImplicitElementAccessSyntax implicitElemAccess)
    {
        return new JObject
        {
            ["kind"] = "xnkIndexExpr",
            ["indexExpr"] = JValue.CreateNull(),  // Implicit target
            ["indexArgs"] = new JArray(implicitElemAccess.ArgumentList.Arguments.Select(arg => ConvertExpression(arg.Expression)))
        };
    }

    static JObject ConvertImplicitStackAllocArray(ImplicitStackAllocArrayCreationExpressionSyntax implicitStackAlloc)
    {
        return new JObject
        {
            ["kind"] = "xnkExternal_StackAlloc",
            ["extStackAllocType"] = new JObject
            {
                ["kind"] = "xnkNamedType",
                ["typeName"] = "auto"  // Type inferred from context
            },
            ["extStackAllocSize"] = implicitStackAlloc.Initializer != null
                ? ConvertInitializer(implicitStackAlloc.Initializer)
                : JValue.CreateNull()
        };
    }

    static JObject ConvertTupleType(TupleTypeSyntax tupleType)
    {
        var elements = new JArray();
        foreach (var element in tupleType.Elements)
        {
            elements.Add(new JObject
            {
                ["kind"] = "xnkParameter",
                ["paramName"] = element.Identifier.Text != "" ? element.Identifier.Text : null,
                ["paramType"] = element.Type != null ? ConvertType(element.Type) : new JObject { ["kind"] = "xnkNamedType", ["typeName"] = "unknown" }
            });
        }

        return new JObject
        {
            ["kind"] = "xnkTupleType",
            ["tupleTypeElements"] = elements
        };
    }
}
