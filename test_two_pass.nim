import src/semantic/semantic_analysis
import xlangtypes
import jsontoxlangtypes
import std/[tables, sets, options, strutils]

let xlangAst = parseXLangJson("parsetoml.xljs")
const NimKeywords = @["result"]
let info = analyzeProgram(xlangAst, NimKeywords)

echo "Total symbols: ", info.allSymbols.len
echo "Total scopes: ", info.allScopes.len

# Count nextChar symbols
var nextCharSymbols = 0
for sym in info.allSymbols:
  if sym.name == "nextChar":
    nextCharSymbols.inc

echo "nextChar symbols registered: ", nextCharSymbols

# Count resolved vs unresolved
var resolved = 0
var unresolved = 0

for node, sym in info.nodeToSymbol:
  if node.kind == xnkIdentifier and node.identName == "nextChar":
    resolved.inc

for w in info.warnings:
  if "nextChar" in w:
    unresolved.inc

echo "nextChar: resolved=", resolved, " unresolved=", unresolved
