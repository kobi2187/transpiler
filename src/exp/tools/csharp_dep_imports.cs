using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;

class Program
{
    static void Main(string[] args)
    {
        if (args.Length < 2)
        {
            Console.WriteLine("Usage: dotnet run <input_directory_or_file> <output_dot_file>");
            return;
        }

        string inputPath = args[0];
        string outputPath = args[1];

        var csFiles = TraverseDirectory(inputPath);
        var imports = new Dictionary<string, List<string>>();

        foreach (var file in csFiles)
        {
            var fileImports = ExtractImports(file);
            imports[file] = fileImports;
        }

        WriteDotFile(imports, outputPath);
        var importCount = CountImports(imports);
        Console.WriteLine("Import count:");
        foreach (var entry in importCount)
        {
            Console.WriteLine($"{entry.Key}: {entry.Value}");
        }
    }

    static List<string> TraverseDirectory(string path)
    {
        var csFiles = new List<string>();
        if (Directory.Exists(path))
        {
            csFiles.AddRange(Directory.GetFiles(path, "*.cs", SearchOption.AllDirectories));
        }
        else if (path.EndsWith(".cs"))
        {
            csFiles.Add(path);
        }
        return csFiles;
    }

    static List<string> ExtractImports(string filePath)
    {
        var imports = new List<string>();
        var importRegex = new Regex(@"^\s*using\s+([\w\.]+);");

        foreach (var line in File.ReadAllLines(filePath))
        {
            var match = importRegex.Match(line);
            if (match.Success)
            {
                imports.Add(match.Groups[1].Value);
            }
        }
        return imports;
    }

    static void WriteDotFile(Dictionary<string, List<string>> graph, string outputPath)
    {
        using (var file = new StreamWriter(outputPath))
        {
            file.WriteLine("digraph G {");

            foreach (var entry in graph)
            {
                foreach (var dep in entry.Value)
                {
                    file.WriteLine($"\t\"{entry.Key}\" -> \"{dep}\";");
                }
            }

            file.WriteLine("}");
        }
    }

    static Dictionary<string, int> CountImports(Dictionary<string, List<string>> imports)
    {
        var counts = new Dictionary<string, int>();

        foreach (var deps in imports.Values)
        {
            foreach (var dep in deps)
            {
                if (counts.ContainsKey(dep))
                {
                    counts[dep]++;
                }
                else
                {
                    counts[dep] = 1;
                }
            }
        }

        return counts;
    }
}
