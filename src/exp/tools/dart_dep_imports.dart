import 'dart:io';

void main(List<String> args) {
  if (args.length < 2) {
    print("Usage: dart dep.dart <input_directory_or_file> <output_dot_file>");
    return;
  }

  var inputPath = args[0];
  var outputPath = args[1];

  var dartFiles = traverseDirectory(inputPath);
  var imports = <String, List<String>>{};

  for (var file in dartFiles) {
    var fileImports = extractImports(file);
    imports[file] = fileImports;
  }

  writeDotFile(imports, outputPath);
  var importCount = countImports(imports);
  print("Import count:");
  importCount.forEach((imp, count) => print("$imp: $count"));
}

List<String> traverseDirectory(String path) {
  var dartFiles = <String>[];

  var dir = Directory(path);
  if (dir.existsSync()) {
    for (var entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith(".dart")) {
        dartFiles.add(entity.path);
      }
    }
  } else if (path.endsWith(".dart")) {
    dartFiles.add(path);
  }

  return dartFiles;
}

List<String> extractImports(String filePath) {
  var imports = <String>[];
  var importRegex = RegExp(r"^\s*import\s+['\"]([^'\"]+)['\"]");

  var lines = File(filePath).readAsLinesSync();
  for (var line in lines) {
    var match = importRegex.firstMatch(line);
    if (match != null) {
      imports.add(match.group(1)!);
    }
  }

  return imports;
}

void writeDotFile(Map<String, List<String>> graph, String outputPath) {
  var file = File(outputPath).openWrite();
  file.writeln("digraph G {");

  graph.forEach((file, deps) {
    for (var dep in deps) {
      file.writeln('\t"$file" -> "$dep";');
    }
  });

  file.writeln("}");
  file.close();
}

Map<String, int> countImports(Map<String, List<String>> imports) {
  var counts = <String, int>{};

  for (var deps in imports.values) {
    for (var dep in deps) {
      counts[dep] = (counts[dep] ?? 0) + 1;
    }
  }

  return counts;
}
