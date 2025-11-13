using Antlr4.Runtime;
using Antlr4.Runtime.Tree;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

public class XLangNode
{
    public string Kind { get; set; }
    public object Data { get; set; }
}

public class Statistics
{
    public Dictionary<string, int> Constructs { get; } = new Dictionary<string, int>();

    public void Increment(string construct)
    {
        if (!Constructs.ContainsKey(construct))
            Constructs[construct] = 0;
        Constructs[construct]++;
    }
}

public class XLangVisitor : CSharpParserBaseVisitor<XLangNode>
{
    private readonly Statistics _stats;

    public XLangVisitor(Statistics stats)
    {
        _stats = stats;
    }

    public override XLangNode VisitCompilationUnit(CSharpParser.CompilationUnitContext context)
    {
        _stats.Increment("CompilationUnit");
        var members = new List<XLangNode>();
        foreach (var member in context.namespace_member_declaration())
        {
            members.Add(Visit(member));
        }
        return new XLangNode { Kind = "CompilationUnit", Data = members };
    }

    public override XLangNode VisitNamespace_declaration(CSharpParser.Namespace_declarationContext context)
    {
        _stats.Increment("Namespace");
        return new XLangNode
        {
            Kind = "Namespace",
            Data = new
            {
                Name = context.qualified_identifier().GetText(),
                Members = Visit(context.namespace_body())
            }
        };
    }

    public override XLangNode VisitClass_declaration(CSharpParser.Class_declarationContext context)
    {
        _stats.Increment("Class");
        return new XLangNode
        {
            Kind = "Class",
            Data = new
            {
                Name = context.identifier().GetText(),
                BaseList = Visit(context.class_base()),
                Members = VisitClassMembers(context.class_body().class_member_declaration())
            }
        };
    }

    public override XLangNode VisitStruct_declaration(CSharpParser.Struct_declarationContext context)
    {
        _stats.Increment("Struct");
        return new XLangNode
        {
            Kind = "Struct",
            Data = new
            {
                Name = context.identifier().GetText(),
                BaseList = Visit(context.struct_interfaces()),
                Members = VisitStructMembers(context.struct_body().struct_member_declaration())
            }
        };
    }

    public override XLangNode VisitInterface_declaration(CSharpParser.Interface_declarationContext context)
    {
        _stats.Increment("Interface");
        return new XLangNode
        {
            Kind = "Interface",
            Data = new
            {
                Name = context.identifier().GetText(),
                BaseList = Visit(context.interface_base()),
                Members = VisitInterfaceMembers(context.interface_body().interface_member_declaration())
            }
        };
    }

    public override XLangNode VisitEnum_declaration(CSharpParser.Enum_declarationContext context)
    {
        _stats.Increment("Enum");
        return new XLangNode
        {
            Kind = "Enum",
            Data = new
            {
                Name = context.identifier().GetText(),
                BaseType = context.enum_base()?.@base().GetText(),
                Members = VisitEnumMembers(context.enum_body().enum_member_declaration())
            }
        };
    }

    public override XLangNode VisitDelegate_definition(CSharpParser.Delegate_definitionContext context)
    {
        _stats.Increment("Delegate");
        return new XLangNode
        {
            Kind = "Delegate",
            Data = new
            {
                ReturnType = context.return_type().GetText(),
                Name = context.identifier().GetText(),
                Parameters = Visit(context.variant_type_parameter_list())
            }
        };
    }

    public override XLangNode VisitMethod_declaration(CSharpParser.Method_declarationContext context)
    {
        _stats.Increment("Method");
        return new XLangNode
        {
            Kind = "Method",
            Data = new
            {
                ReturnType = context.return_type().GetText(),
                Name = context.method_member_name().GetText(),
                Parameters = Visit(context.formal_parameter_list()),
                Body = Visit(context.method_body())
            }
        };
    }

    public override XLangNode VisitProperty_declaration(CSharpParser.Property_declarationContext context)
    {
        _stats.Increment("Property");
        return new XLangNode
        {
            Kind = "Property",
            Data = new
            {
                Type = context.member_access().GetText(),
                Name = context.identifier().GetText(),
                Accessors = VisitAccessorDeclarations(context.accessor_declarations())
            }
        };
    }

    public override XLangNode VisitField_declaration(CSharpParser.Field_declarationContext context)
    {
        _stats.Increment("Field");
        return new XLangNode
        {
            Kind = "Field",
            Data = new
            {
                Type = context.variable_declarators().variable_declarator()[0].var_type().GetText(),
                Declarations = context.variable_declarators().variable_declarator().Select(vd => new
                {
                    Name = vd.identifier().GetText(),
                    Initializer = vd.variable_initializer()?.GetText()
                }).ToList()
            }
        };
    }

    public override XLangNode VisitConstructor_declaration(CSharpParser.Constructor_declarationContext context)
    {
        _stats.Increment("Constructor");
        return new XLangNode
        {
            Kind = "Constructor",
            Data = new
            {
                Name = context.identifier().GetText(),
                Parameters = Visit(context.formal_parameter_list()),
                Initializer = Visit(context.constructor_initializer()),
                Body = Visit(context.body())
            }
        };
    }

    public override XLangNode VisitDestructor_definition(CSharpParser.Destructor_definitionContext context)
    {
        _stats.Increment("Destructor");
        return new XLangNode
        {
            Kind = "Destructor",
            Data = new
            {
                Name = context.identifier().GetText(),
                Body = Visit(context.body())
            }
        };
    }

    public override XLangNode VisitLocal_variable_declaration(CSharpParser.Local_variable_declarationContext context)
    {
        _stats.Increment("LocalVariable");
        return new XLangNode
        {
            Kind = "LocalVariable",
            Data = new
            {
                Type = context.local_variable_type().GetText(),
                Declarations = context.local_variable_declarator().Select(lvd => new
                {
                    Name = lvd.identifier().GetText(),
                    Initializer = lvd.local_variable_initializer()?.GetText()
                }).ToList()
            }
        };
    }

    public override XLangNode VisitIf_statement(CSharpParser.If_statementContext context)
    {
        _stats.Increment("IfStatement");
        return new XLangNode
        {
            Kind = "IfStatement",
            Data = new
            {
                Condition = Visit(context.expression()),
                ThenStatement = Visit(context.if_body()),
                ElseStatement = context.ELSE() != null ? Visit(context.if_body()[1]) : null
            }
        };
    }

    public override XLangNode VisitSwitch_statement(CSharpParser.Switch_statementContext context)
    {
        _stats.Increment("SwitchStatement");
        return new XLangNode
        {
            Kind = "SwitchStatement",
            Data = new
            {
                Expression = Visit(context.expression()),
                Sections = context.switch_section().Select(Visit).ToList()
            }
        };
    }

    public override XLangNode VisitFor_statement(CSharpParser.For_statementContext context)
    {
        _stats.Increment("ForStatement");
        return new XLangNode
        {
            Kind = "ForStatement",
            Data = new
            {
                Initializer = Visit(context.for_initializer()),
                Condition = Visit(context.expression()),
                Iterator = Visit(context.for_iterator()),
                Body = Visit(context.embedded_statement())
            }
        };
    }

    public override XLangNode VisitForeach_statement(CSharpParser.Foreach_statementContext context)
    {
        _stats.Increment("ForeachStatement");
        return new XLangNode
        {
            Kind = "ForeachStatement",
            Data = new
            {
                Type = context.local_variable_type().GetText(),
                Identifier = context.identifier().GetText(),
                Expression = Visit(context.expression()),
                Body = Visit(context.embedded_statement())
            }
        };
    }

    public override XLangNode VisitWhile_statement(CSharpParser.While_statementContext context)
    {
        _stats.Increment("WhileStatement");
        return new XLangNode
        {
            Kind = "WhileStatement",
            Data = new
            {
                Condition = Visit(context.expression()),
                Body = Visit(context.embedded_statement())
            }
        };
    }

    public override XLangNode VisitDo_statement(CSharpParser.Do_statementContext context)
    {
        _stats.Increment("DoStatement");
        return new XLangNode
        {
            Kind = "DoStatement",
            Data = new
            {
                Body = Visit(context.embedded_statement()),
                Condition = Visit(context.expression())
            }
        };
    }

    public override XLangNode VisitTry_statement(CSharpParser.Try_statementContext context)
    {
        _stats.Increment("TryStatement");
        return new XLangNode
        {
            Kind = "TryStatement",
            Data = new
            {
                Body = Visit(context.block()),
                CatchClauses = context.catch_clauses()?.specific_catch_clause().Select(Visit).ToList(),
                GeneralCatchClause = Visit(context.catch_clauses()?.general_catch_clause()),
                FinallyClause = context.finally_clause() != null ? Visit(context.finally_clause().block()) : null
            }
        };
    }

    // Add more visit methods for other C# constructs...

    private List<XLangNode> VisitClassMembers(IEnumerable<CSharpParser.Class_member_declarationContext> members)
    {
        return members.Select(Visit).ToList();
    }

    private List<XLangNode> VisitStructMembers(IEnumerable<CSharpParser.Struct_member_declarationContext> members)
    {
        return members.Select(Visit).ToList();
    }

    private List<XLangNode> VisitInterfaceMembers(IEnumerable<CSharpParser.Interface_member_declarationContext> members)
    {
        return members.Select(Visit).ToList();
    }

    private List<XLangNode> VisitEnumMembers(IEnumerable<CSharpParser.Enum_member_declarationContext> members)
    {
        return members.Select(m => new XLangNode
        {
            Kind = "EnumMember",
            Data = new
            {
                Name = m.identifier().GetText(),
                Value = m.expression()?.GetText()
            }
        }).ToList();
    }

    private object VisitAccessorDeclarations(CSharpParser.Accessor_declarationsContext context)
    {
        var accessors = new Dictionary<string, XLangNode>();
        if (context.GET() != null)
        {
            accessors["get"] = Visit(context.accessor_body()[0]);
        }
        if (context.SET() != null)
        {
            accessors["set"] = Visit(context.accessor_body()[1]);
        }
        return accessors;
    }

    // Default visit method for unhandled nodes
    protected override XLangNode DefaultResult => new XLangNode { Kind = "Unhandled", Data = null };
}

public class Program
{
    public static void Main(string[] args)
    {
        if (args.Length < 1)
        {
            Console.WriteLine("Usage: CSharpXLangParser <file_or_directory>");
            return;
        }

        string path = args[0];
        var stats = new Statistics();

        ProcessPath(path, stats);

        Console.WriteLine("\nStatistics:");
        foreach (var kvp in stats.Constructs)
        {
            Console.WriteLine($"{kvp.Key}: {kvp.Value}");
        }
    }

    private static void ProcessPath(string path, Statistics stats)
    {
        if (File.Exists(path))
        {
            if (Path.GetExtension(path).ToLower() == ".cs")
            {
                ProcessFile(path, stats);
            }
        }
        else if (Directory.Exists(path))
        {
            foreach (var file in Directory.EnumerateFiles(path, "*.cs", SearchOption.AllDirectories))
            {
                ProcessFile(file, stats);
            }
        }
        else
        {
            Console.WriteLine($"Invalid path: {path}");
        }
    }

    private static void ProcessFile(string filename, Statistics stats)
    {
        string input = File.ReadAllText(filename);
        var inputStream = new AntlrInputStream(input);
        var lexer = new CSharpLexer(inputStream);
        var tokenStream = new CommonTokenStream(lexer);
        var parser = new CSharpParser(tokenStream);
        var tree = parser.compilation_unit();

        var visitor = new XLangVisitor(stats);
        var xlangAst = visitor.Visit(tree);

        string json = JsonConvert.SerializeObject(xlangAst, Formatting.Indented);
        string outputFilename = Path.ChangeExtension(filename, ".json");
        File.WriteAllText(outputFilename, json);

        Console.WriteLine($"Processed {filename} -> {outputFilename}");
    }
}
