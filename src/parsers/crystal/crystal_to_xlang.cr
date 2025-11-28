require "compiler/crystal/syntax"
require "json"

class CrystalToXLangParser
  def parse_file(content : String)
    ast = Crystal::Parser.parse(content)
    convert_to_xlang(ast).to_json
  end

  private def convert_to_xlang(node : Crystal::ASTNode)
    case node
    when Crystal::Expressions
      {
        kind: "xnkBlockStmt",
        statements: node.expressions.map { |expr| convert_to_xlang(expr) },
      }
    when Crystal::Program
      {
        kind: "xnkFile",
        declarations: node.declarations.map { |decl| convert_to_xlang(decl) },
      }
    when Crystal::ClassDef
      {
        kind: "xnkClassDecl",
        className: node.name.names.join("::"),
        superclass: node.superclass ? convert_to_xlang(node.superclass) : nil,
        body: convert_to_xlang(node.body),
        abstract: node.abstract?,
      }
    when Crystal::ModuleDef
      {
        kind: "xnkModuleDecl",
        moduleName: node.name.names.join("::"),
        body: convert_to_xlang(node.body),
      }
    when Crystal::Def
      {
        kind: "xnkFuncDecl",
        funcName: node.name,
        parameters: node.args.map { |arg| convert_to_xlang(arg) },
        returnType: node.return_type ? convert_to_xlang(node.return_type) : nil,
        body: convert_to_xlang(node.body),
        receiver: node.receiver ? convert_to_xlang(node.receiver) : nil,
      }
    when Crystal::Macro
      {
        kind: "xnkMacroDecl",
        macroName: node.name,
        parameters: node.args.map { |arg| convert_to_xlang(arg) },
        body: convert_to_xlang(node.body),
      }
    when Crystal::Arg
      {
        kind: "xnkParameter",
        paramName: node.name,
        paramType: node.restriction ? convert_to_xlang(node.restriction) : nil,
        defaultValue: node.default_value ? convert_to_xlang(node.default_value) : nil,
      }
    when Crystal::Call
      {
        kind: "xnkCallExpr",
        name: node.name,
        args: node.args.map { |arg| convert_to_xlang(arg) },
        receiver: node.obj ? convert_to_xlang(node.obj) : nil,
        namedArgs: node.named_args ? node.named_args.map { |arg| convert_to_xlang(arg) } : nil,
      }
    when Crystal::If
      {
        kind: "xnkIfStmt",
        condition: convert_to_xlang(node.cond),
        thenBranch: convert_to_xlang(node.then),
        elseBranch: node.else ? convert_to_xlang(node.else) : nil,
      }
    when Crystal::Unless
      {
        kind: "xnkUnlessStmt",
        condition: convert_to_xlang(node.cond),
        body: convert_to_xlang(node.then),
        elseBody: node.else ? convert_to_xlang(node.else) : nil,
      }
    when Crystal::While
      {
        kind: "xnkWhileStmt",
        condition: convert_to_xlang(node.cond),
        body: convert_to_xlang(node.body),
      }
    when Crystal::Until
      {
        kind: "xnkUntilStmt",
        condition: convert_to_xlang(node.cond),
        body: convert_to_xlang(node.body),
      }
    when Crystal::Case
      {
        kind: "xnkSwitchStmt",
        subject: node.cond ? convert_to_xlang(node.cond) : nil,
        whens: node.whens.map { |when_node| convert_to_xlang(when_node) },
        elseBody: node.else ? convert_to_xlang(node.else) : nil,
      }
    when Crystal::When
      {
        kind: "xnkSwitchCase",
        conditions: node.conds.map { |cond| convert_to_xlang(cond) },
        body: convert_to_xlang(node.body),
      }
    when Crystal::Assign
      {
        kind: "xnkAssignExpr",
        target: convert_to_xlang(node.target),
        value: convert_to_xlang(node.value),
      }
    when Crystal::Var
      {
        kind: "xnkIdentifier",
        name: node.name,
      }
    when Crystal::InstanceVar
      {
        kind: "xnkInstanceVar",
        name: node.name,
      }
    when Crystal::ClassVar
      {
        kind: "xnkClassVar",
        name: node.name,
      }
    when Crystal::Global
      {
        kind: "xnkGlobalVar",
        name: node.name,
      }
    when Crystal::BinaryOp
      {
        kind: "xnkBinaryExpr",
        operator: node.class.name.split("::").last,
        left: convert_to_xlang(node.left),
        right: convert_to_xlang(node.right),
      }
    when Crystal::UnaryOp
      {
        kind: "xnkUnaryExpr",
        operator: node.class.name.split("::").last,
        operand: convert_to_xlang(node.exp),
      }
    when Crystal::StringLiteral
      {
        kind: "xnkStringLit",
        value: node.value,
      }
    when Crystal::NumberLiteral
      {
        kind: "xnkNumberLit",
        value: node.value,
      }
    when Crystal::SymbolLiteral
      {
        kind: "xnkSymbolLit",
        value: node.value,
      }
    when Crystal::ArrayLiteral
      {
        kind: "xnkArrayLit",
        elements: node.elements.map { |elem| convert_to_xlang(elem) },
      }
    when Crystal::HashLiteral
      {
        kind: "xnkDictLit",
        entries: node.entries.map { |entry| {key: convert_to_xlang(entry.key), value: convert_to_xlang(entry.value)} },
      }
    when Crystal::Require
      {
        kind: "xnkRequire",
        path: node.string,
      }
    when Crystal::Include
      {
        kind: "xnkInclude",
        name: convert_to_xlang(node.name),
      }
    when Crystal::Extend
      {
        kind: "xnkExtend",
        name: convert_to_xlang(node.name),
      }
    when Crystal::Alias
      {
        kind: "xnkAlias",
        name: node.name,
        value: convert_to_xlang(node.value),
      }
    when Crystal::TypeDeclaration
      {
        kind: "xnkTypeDecl",
        var: convert_to_xlang(node.var),
        declaredType: convert_to_xlang(node.declared_type),
        value: node.value ? convert_to_xlang(node.value) : nil,
      }
    when Crystal::UninitializedVar
      {
        kind: "xnkUninitializedVar",
        var: convert_to_xlang(node.var),
        declaredType: convert_to_xlang(node.declared_type),
      }
    when Crystal::Generic
      {
        kind: "xnkGenericType",
        name: convert_to_xlang(node.name),
        typeArgs: node.type_vars.map { |type_var| convert_to_xlang(type_var) },
      }
    when Crystal::Union
      {
        kind: "xnkUnionType",
        types: node.types.map { |type| convert_to_xlang(type) },
      }
    when Crystal::Fun
      {
        kind: "xnkFunctionType",
        inputs: node.inputs.map { |input| convert_to_xlang(input) },
        output: node.output ? convert_to_xlang(node.output) : nil,
      }
    when Crystal::EnumDef
      {
        kind: "xnkEnumDecl",
        name: node.name.names.join("::"),
        members: node.members.map { |member| convert_to_xlang(member) },
      }
    when Crystal::LibDef
      {
        kind: "xnkLibDecl",
        name: node.name,
        body: convert_to_xlang(node.body),
      }
    when Crystal::FunDef
      {
        kind: "xnkCFuncDecl",
        name: node.name,
        args: node.args.map { |arg| convert_to_xlang(arg) },
        returnType: node.return_type ? convert_to_xlang(node.return_type) : nil,
        body: node.body ? convert_to_xlang(node.body) : nil,
      }
    when Crystal::ExternalVar
      {
        kind: "xnkExternalVar",
        name: node.name,
        type: convert_to_xlang(node.type),
      }
    when Crystal::ProcLiteral
      {
        kind: "xnkProcLiteral",
        def: convert_to_xlang(node.def),
      }
    when Crystal::ProcPointer
      {
        kind: "xnkProcPointer",
        obj: node.obj ? convert_to_xlang(node.obj) : nil,
        name: node.name,
        args: node.args.map { |arg| convert_to_xlang(arg) },
      }
    else
      {
        kind: "xnkUnknown",
        crystalType: node.class.name,
      }
    end
  end
end

# Example usage
if ARGV.size != 1
  puts "Usage: crystal run crystal_to_xlang.cr -- <crystal_file>"
  exit 1
end

parser = CrystalToXLangParser.new
code = File.read(ARGV[0])
puts parser.parse_file(code)