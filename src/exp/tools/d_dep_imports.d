import std.file;
import std.path;
import std.regex;
import std.stdio;
import std.string;
import std.array;

void main(string[] args) {
    if (args.length < 3) {
        writeln("Usage: dlang_dep <input_directory_or_file> <output_dot_file>");
        return;
    }

    string inputPath = args[1];
    string outputPath = args[2];

    auto dFiles = traverseDirectory(inputPath);
    string[string[]] imports;

    foreach (file; dFiles) {
        auto fileImports = extractImports(file);
        imports[file] = fileImports;
    }

    writeDotFile(imports, outputPath);
    auto importCount = countImports(imports);
    writeln("Import count:");
    foreach (key, count; importCount) {
        writeln(key, ": ", count);
    }
}

string[] traverseDirectory(string path) {
    string[] dFiles;
    if (isDir(path)) {
        foreach (file; dirEntries(path, SpanMode.depth)) {
            if (file.isFile && file.name.endsWith(".d")) {
                dFiles ~= file.name;
            }
        }
    } else if (path.endsWith(".d")) {
        dFiles ~= path;
    }
    return dFiles;
}

string[] extractImports(string filePath) {
    string[] imports;
    auto fileContent = readText(filePath);
    auto lines = fileContent.splitLines();
    auto importRegex = regex(r"^import\s+([a-zA-Z0-9_.]+);");

    foreach (line; lines) {
        auto matches = matchFirst(line, importRegex);
        if (matches !is null) {
            imports ~= matches.captures[1];
        }
    }
    return imports;
}

void writeDotFile(string[string[]] graph, string outputPath) {
    auto file = File(outputPath, "w");
    file.writeln("digraph G {");

    foreach (file, deps; graph) {
        foreach (dep; deps) {
            file.writeln(`\t"`, file, `" -> "`, dep, `";`);
        }
    }

    file.writeln("}");
}

int[string] countImports(string[string[]] imports) {
    int[string] counts;

    foreach (deps; imports.byValue) {
        foreach (dep; deps) {
            counts[dep]++;
        }
    }
    return counts;
}
