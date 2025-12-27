import src/semantic/semantic_analysis
import xlangtypes
import jsontoxlangtypes
import std/[tables]

let xlangAst = parseXLangJson("parsetoml.xljs")
const NimKeywords = @["result"]
let info = analyzeProgram(xlangAst, NimKeywords)

echo "Total warnings: ", info.warnings.len
echo "Total symbols: ", info.allSymbols.len
echo "Total scopes: ", info.allScopes.len
