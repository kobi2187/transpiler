import json, xlangtypes, options
import src/passes/nim_identifier_sanitization

# Create a simple XLang AST with @as identifier
var testAst = XLangNode(
  kind: xnkFile,
  fileName: "test.cs",
  sourceLang: "csharp",
  moduleDecls: @[
    XLangNode(
      kind: xnkVarDecl,
      declName: "@as",
      declType: some(XLangNode(kind: xnkIdentifier, identName: "string")),
      initializer: none(XLangNode)
    )
  ]
)

echo "Before sanitization: ", testAst.moduleDecls[0].declName

let sanitizedAst = applyNimIdentifierSanitization(testAst)

echo "After sanitization: ", sanitizedAst.moduleDecls[0].declName
