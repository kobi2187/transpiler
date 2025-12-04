using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

partial class Program {

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
            ["type"] = cast.Type.ToString(),
            ["expr"] = ConvertExpression(cast.Expression)
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
        return new JObject
        {
            ["kind"] = "xnkArrayCreation",
            ["type"] = arrayCreate.Type.ToString(),
            ["initializer"] = arrayCreate.Initializer != null
                ? ConvertInitializer(arrayCreate.Initializer)
                : JValue.CreateNull()
        };
    }

    static JObject ConvertInitializer(InitializerExpressionSyntax initializer)
    {
        return new JObject
        {
            ["kind"] = "xnkInitializer",
            ["initializerKind"] = initializer.Kind().ToString(),
            ["expressions"] = new JArray(initializer.Expressions.Select(ConvertExpression))
        };
    }

    // Additional Statement converters
    static JObject ConvertThrow(ThrowStatementSyntax throwStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkThrowStmt",
            ["throwExpr"] = throwStmt.Expression != null
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
            ["switchCases"] = new JArray(switchStmt.Sections.Select(section => new JObject
            {
                ["labels"] = new JArray(section.Labels.Select(label => new JObject
                {
                    ["kind"] = label.Kind().ToString(),
                    ["value"] = label is CaseSwitchLabelSyntax caseLabel
                        ? ConvertExpression(caseLabel.Value)
                        : JValue.CreateNull()
                })),
                ["statements"] = new JArray(section.Statements.Select(ConvertStatement))
            }))
        };
    }

    static JObject ConvertUsing(UsingStatementSyntax usingStmt)
    {
        return new JObject
        {
            ["kind"] = "xnkUsingStmt",
            ["declaration"] = usingStmt.Declaration != null
                ? new JObject
                {
                    ["type"] = usingStmt.Declaration.Type.ToString(),
                    ["variables"] = new JArray(usingStmt.Declaration.Variables.Select(v => new JObject
                    {
                        ["name"] = v.Identifier.Text,
                        ["initializer"] = v.Initializer != null ? ConvertExpression(v.Initializer.Value) : JValue.CreateNull()
                    }))
                }
                : JValue.CreateNull(),
            ["expression"] = usingStmt.Expression != null ? ConvertExpression(usingStmt.Expression) : JValue.CreateNull(),
            ["statement"] = ConvertStatement(usingStmt.Statement)
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
        return new JObject
        {
            ["kind"] = "xnkYieldStmt",
            ["yieldKind"] = yieldStmt.Kind().ToString(),
            ["expr"] = yieldStmt.Expression != null
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
            ["kind"] = "xnkConditionalExpr",
            ["ternaryCondition"] = ConvertExpression(conditional.Condition),
            ["ternaryThen"] = ConvertExpression(conditional.WhenTrue),
            ["ternaryElse"] = ConvertExpression(conditional.WhenFalse)
        };
    }

    static JObject ConvertPredefinedType(PredefinedTypeSyntax predefinedType)
    {
        return new JObject
        {
            ["kind"] = "xnkPredefinedType",
            ["type"] = predefinedType.Keyword.Text
        };
    }

    static JObject ConvertIsPattern(IsPatternExpressionSyntax isPattern)
    {
        return new JObject
        {
            ["kind"] = "xnkIsPatternExpr",
            ["expr"] = ConvertExpression(isPattern.Expression),
            ["pattern"] = isPattern.Pattern.ToString()
        };
    }

    static JObject ConvertDeclarationExpression(DeclarationExpressionSyntax declExpr)
    {
        return new JObject
        {
            ["kind"] = "xnkDeclarationExpr",
            ["type"] = declExpr.Type.ToString(),
            ["designation"] = declExpr.Designation.ToString()
        };
    }

    static JObject ConvertInterpolatedString(InterpolatedStringExpressionSyntax interpolated)
    {
        return new JObject
        {
            ["kind"] = "xnkInterpolatedString",
            ["contents"] = new JArray(interpolated.Contents.Select(c => new JObject
            {
                ["kind"] = c.Kind().ToString(),
                ["text"] = c.ToString()
            }))
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
        return new JObject
        {
            ["kind"] = "xnkConditionalAccessExpr",
            ["expr"] = ConvertExpression(condAccess.Expression),
            ["whenNotNull"] = condAccess.WhenNotNull.ToString()
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
            ["elementType"] = arrayType.ElementType.ToString(),
            ["rankSpecifiers"] = new JArray(arrayType.RankSpecifiers.Select(r => r.ToString()))
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