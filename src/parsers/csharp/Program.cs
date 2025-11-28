using System;
using System.IO;
using System.Linq;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

class Program
{
    static void Main(string[] args)
    {
        if (args.Length < 1)
        {
            Console.WriteLine("Usage: csharp-to-xlang <file.cs>");
            Environment.Exit(1);
        }

        string sourceCode = File.ReadAllText(args[0]);
        var tree = CSharpSyntaxTree.ParseText(sourceCode);
        var root = tree.GetRoot();

        var xlangNode = ConvertToXLang(root);
        var json = JsonConvert.SerializeObject(xlangNode, Formatting.Indented);
        Console.WriteLine(json);
    }

    static JObject ConvertToXLang(SyntaxNode node)
    {
        return node switch
        {
            CompilationUnitSyntax cu => ConvertCompilationUnit(cu),
            _ => new JObject { ["kind"] = "xnkUnknown", ["text"] = node.ToString() }
        };
    }

    static JObject ConvertCompilationUnit(CompilationUnitSyntax cu)
    {
        var result = new JObject
        {
            ["kind"] = "xnkFile",
            ["fileName"] = "unknown",
            ["declarations"] = new JArray(cu.Members.Select(ConvertMember))
        };
        return result;
    }

    static JObject ConvertMember(MemberDeclarationSyntax member)
    {
        return member switch
        {
            NamespaceDeclarationSyntax ns => ConvertNamespace(ns),
            ClassDeclarationSyntax cls => ConvertClass(cls),
            _ => new JObject { ["kind"] = "xnkUnknown" }
        };
    }

    static JObject ConvertNamespace(NamespaceDeclarationSyntax ns)
    {
        return new JObject
        {
            ["kind"] = "xnkNamespace",
            ["name"] = ns.Name.ToString(),
            ["declarations"] = new JArray(ns.Members.Select(ConvertMember))
        };
    }

    static JObject ConvertClass(ClassDeclarationSyntax cls)
    {
        return new JObject
        {
            ["kind"] = "xnkClassDecl",
            ["className"] = cls.Identifier.Text,
            ["members"] = new JArray(cls.Members.Select(ConvertClassMember))
        };
    }

    static JObject ConvertClassMember(MemberDeclarationSyntax member)
    {
        return member switch
        {
            MethodDeclarationSyntax method => ConvertMethod(method),
            _ => new JObject { ["kind"] = "xnkUnknown" }
        };
    }

    static JObject ConvertMethod(MethodDeclarationSyntax method)
    {
        return new JObject
        {
            ["kind"] = "xnkFuncDecl",
            ["name"] = method.Identifier.Text,
            ["parameters"] = new JArray(),
            ["returnType"] = new JObject { ["kind"] = "xnkNamedType", ["name"] = method.ReturnType.ToString() },
            ["body"] = method.Body != null ? ConvertBlock(method.Body) : JValue.CreateNull()
        };
    }

    static JObject ConvertBlock(BlockSyntax block)
    {
        return new JObject
        {
            ["kind"] = "xnkBlockStmt",
            ["statements"] = new JArray(block.Statements.Select(ConvertStatement))
        };
    }

    static JObject ConvertStatement(StatementSyntax stmt)
    {
        return stmt switch
        {
            ExpressionStatementSyntax exprStmt => ConvertExpressionStatement(exprStmt),
            _ => new JObject { ["kind"] = "xnkUnknown", ["text"] = stmt.ToString() }
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
            InvocationExpressionSyntax inv => ConvertInvocation(inv),
            _ => new JObject { ["kind"] = "xnkExpression", ["text"] = expr.ToString() }
        };
    }

    static JObject ConvertInvocation(InvocationExpressionSyntax inv)
    {
        return new JObject
        {
            ["kind"] = "xnkCallExpr",
            ["expr"] = ConvertExpression(inv.Expression),
            ["args"] = new JArray(inv.ArgumentList.Arguments.Select(arg => ConvertExpression(arg.Expression)))
        };
    }
}
