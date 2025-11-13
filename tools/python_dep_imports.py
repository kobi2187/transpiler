import os
import re
from collections import defaultdict

def main(input_path, output_path):
    py_files = traverse_directory(input_path)
    imports = {}

    for file in py_files:
        file_imports = extract_imports(file)
        imports[file] = file_imports

    write_dot_file(imports, output_path)
    import_count = count_imports(imports)
    print("Import count:")
    for imp, count in import_count.items():
        print(f"{imp}: {count}")

def traverse_directory(path):
    py_files = []
    for root, _, files in os.walk(path):
        for file in files:
            if file.endswith(".py"):
                py_files.append(os.path.join(root, file))
    return py_files

def extract_imports(file_path):
    imports = []
    import_regex = re.compile(r'^\s*(?:from|import)\s+([\w\.]+)')
    
    with open(file_path, 'r') as file:
        for line in file:
            match = import_regex.match(line)
            if match:
                imports.append(match.group(1))
    
    return imports

def write_dot_file(graph, output_path):
    with open(output_path, 'w') as file:
        file.write("digraph G {\n")
        for file, deps in graph.items():
            for dep in deps:
                file.write(f'\t"{file}" -> "{dep}";\n')
        file.write("}\n")

def count_imports(imports):
    counts = defaultdict(int)
    for deps in imports.values():
        for dep in deps:
            counts[dep] += 1
    return counts

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python dep.py <input_directory_or_file> <output_dot_file>")
    else:
        main(sys.argv[1], sys.argv[2])
