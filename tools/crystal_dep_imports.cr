require "file_utils"
require "regex"

def main(input_path, output_path)
  crystal_files = traverse_directory(input_path)
  imports = {} of String => Array(String)

  crystal_files.each do |file|
    file_imports = extract_imports(file)
    imports[file] = file_imports
  end

  write_dot_file(imports, output_path)
  import_count = count_imports(imports)
  puts "Import count:"
  import_count.each do |imp, count|
    puts "#{imp}: #{count}"
  end
end

def traverse_directory(path : String) : Array(String)
  crystal_files = [] of String

  if File.directory?(path)
    File.each_file(path) do |file|
      crystal_files.concat(traverse_directory(file)) if File.directory?(file)
      crystal_files.push(file) if file.ends_with?(".cr")
    end
  elsif path.ends_with?(".cr")
    crystal_files.push(path)
  end

  crystal_files
end

def extract_imports(file_path : String) : Array(String)
  imports = [] of String
  import_regex = Regex.new("^require\\s+([a-zA-Z0-9_/]+)")

  File.each_line(file_path) do |line|
    if match = import_regex.match(line)
      imports.push(match[1])
    end
  end

  imports
end

def write_dot_file(graph : Hash(String, Array(String)), output_path : String)
  File.open(output_path, "w") do |file|
    file.puts "digraph G {"

    graph.each do |file, deps|
      deps.each do |dep|
        file.puts %("\(file)" -> "\(dep)";)
      end
    end

    file.puts "}"
  end
end

def count_imports(imports : Hash(String, Array(String))) : Hash(String, Int32)
  counts = Hash(String, Int32).new(0)

  imports.each_value do |deps|
    deps.each do |dep|
      counts[dep] += 1
    end
  end

  counts
end

main(ARGV[0], ARGV[1])
