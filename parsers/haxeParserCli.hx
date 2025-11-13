import sys.io.File;
import haxe.macro.Context;
import haxe.macro.Expr;

class HaxeXLangCLI {
    public static function main() {
        var args = Sys.args();
        if (args.length != 1) {
            Sys.println("Usage: haxe --run HaxeXLangCLI <haxe_file>");
            return;
        }

        var inputFile = args[0];
        var outputFile = inputFile + ".xlang.json";

        try {
            var content = File.getContent(inputFile);
            var ast = Context.parse(content, Context.makePosition({ min: 0, max: content.length, file: inputFile }));
            var xlangAst = HaxeToXLangParser.convertExpr(ast);
            var jsonOutput = haxe.Json.stringify(xlangAst, null, "  ");
            File.saveContent(outputFile, jsonOutput);
            Sys.println('XLang AST saved to $outputFile');
        } catch (e:Dynamic) {
            Sys.stderr().writeString('Error: $e\n');
        }
    }
}