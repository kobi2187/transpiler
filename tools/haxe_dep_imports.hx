import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import StringTools;

class Main {
    public static function main() {
        if (Sys.args().length < 2) {
            trace("Usage: haxe Main.hx -input <input_directory_or_file> -output <output_dot_file>");
            return;
        }

        var inputPath = Sys.args()[0];
        var outputPath = Sys.args()[1];

        // Traverse the directory or process the single file
        var hxFiles = traverseDirectory(inputPath);
        var imports = new Map<String, Array<String>>();

        // Extract imports from each Haxe file
        for (file in hxFiles) {
            var fileImports = extractImports(file);
            imports.set(file, fileImports);
        }

        // Build and write the dependency graph to a .dot file
        writeDotFile(imports, outputPath);

        // Count and print import occurrences
        var importCount = countImports(imports);
        trace("Import count:");
        for (imp in importCount.keys()) {
            trace(imp + ": " + importCount.get(imp));
        }
    }

    // Traverse the directory to find all Haxe files
    static function traverseDirectory(path: String): Array<String> {
        var hxFiles = new Array<String>();

        if (FileSystem.isDirectory(path)) {
            for (file in FileSystem.readDirectory(path)) {
                var fullPath = Path.join([path, file]);
                if (FileSystem.isDirectory(fullPath)) {
                    hxFiles = hxFiles.concat(traverseDirectory(fullPath));
                } else if (StringTools.endsWith(file, ".hx")) {
                    hxFiles.push(fullPath);
                }
            }
        } else if (StringTools.endsWith(path, ".hx")) {
            hxFiles.push(path);
        }

        return hxFiles;
    }
}


// Extract imports from a Haxe file
static function extractImports(filePath: String): Array<String> {
    var imports = new Array<String>();
    var fileContent = File.getContent(filePath);
    var lines = fileContent.split("\n");
    var importRegex = ~/^import\s+([\w\.]+);/;

    for (line in lines) {
        line = StringTools.trim(line);
        var matches = importRegex.match(line);
        if (matches != null) {
            imports.push(matches.matched(1));
        }
    }

    return imports;
}
// Write the dependency graph to a .dot file
static function writeDotFile(graph: Map<String, Array<String>>, outputPath: String): Void {
    var file = sys.io.File.write(outputPath, false);
    file.writeString("digraph G {\n");

    for (file in graph.keys()) {
        var deps = graph.get(file);
        for (dep in deps) {
            file.writeString('\t"' + file + '" -> "' + dep + '";\n');
        }
    }

    file.writeString("}\n");
    file.close();
}
// Count the occurrences of each import
static function countImports(imports: Map<String, Array<String>>): Map<String, Int> {
    var counts = new Map<String, Int>();

    for (deps in imports.values()) {
        for (dep in deps) {
            if (counts.exists(dep)) {
                counts.set(dep, counts.get(dep) + 1);
            } else {
                counts.set(dep, 1);
            }
        }
    }

    return counts;
}
