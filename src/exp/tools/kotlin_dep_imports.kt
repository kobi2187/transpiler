import java.io.File

fun main(args: Array<String>) {
    if (args.size < 2) {
        println("Usage: kotlin Dep.kt <input_directory_or_file> <output_dot_file>")
        return
    }

    val inputPath = args[0]
    val outputPath = args[1]

    val ktFiles = traverseDirectory(inputPath)
    val imports = mutableMapOf<String, List<String>>()

    for (file in ktFiles) {
        val fileImports = extractImports(file)
        imports[file] = fileImports
    }

    writeDotFile(imports, outputPath)
    val importCount = countImports(imports)
    println("Import count:")
    for ((imp, count) in importCount) {
        println("$imp: $count")
    }
}

fun traverseDirectory(path: String): List<String> {
    val ktFiles = mutableListOf<String>()

    File(path).walkTopDown().forEach {
        if (it.isFile && it.extension == "kt") {
            ktFiles.add(it.path)
        }
    }
    return ktFiles
}

fun extractImports(filePath: String): List<String> {
    val imports = mutableListOf<String>()
    val importRegex = Regex("^import\\s+([\\w\\.]+)")

    File(filePath).forEachLine { line ->
        val match = importRegex.find(line)
        if (match != null) {
            imports.add(match.groupValues[1])
        }
    }
    return imports
}

fun writeDotFile(graph: Map<String, List<String>>, outputPath: String) {
    File(outputPath).printWriter().use { out ->
        out.println("digraph G {")

        for ((file, deps) in graph) {
            for (dep in deps) {
                out.println("\t\"$file\" -> \"$dep\";")
            }
        }

        out.println("}")
    }
}

fun countImports(imports: Map<String, List<String>>): Map<String, Int> {
    val counts = mutableMapOf<String, Int>()

    imports.values.flatten().forEach { dep ->
        counts[dep] = counts.getOrDefault(dep, 0) + 1
    }
    return counts
}
