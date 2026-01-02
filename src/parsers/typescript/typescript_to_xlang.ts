
import * as ts from "typescript";
import * as fs from "fs";

interface XLangNode {
  kind: string;
  [key: string]: any;
}

class TypeScriptToXLangParser {
  private sourceFile: ts.SourceFile;
  private checker: ts.TypeChecker;

  constructor(fileName: string) {
    const program = ts.createProgram([fileName], {});
    this.sourceFile = program.getSourceFile(fileName)!;
    this.checker = program.getTypeChecker();
  }

  parse(): XLangNode {
    return this.convertNode(this.sourceFile);
  }

  private convertNode(node: ts.Node): XLangNode {
    switch (node.kind) {
      case ts.SyntaxKind.SourceFile:
        return this.convertSourceFile(node as ts.SourceFile);
      case ts.SyntaxKind.ClassDeclaration:
        return this.convertClassDeclaration(node as ts.ClassDeclaration);
      case ts.SyntaxKind.InterfaceDeclaration:
        return this.convertInterfaceDeclaration(node as ts.InterfaceDeclaration);
      case ts.SyntaxKind.FunctionDeclaration:
        return this.convertFunctionDeclaration(node as ts.FunctionDeclaration);
      case ts.SyntaxKind.MethodDeclaration:
        return this.convertMethodDeclaration(node as ts.MethodDeclaration);
      case ts.SyntaxKind.PropertyDeclaration:
        return this.convertPropertyDeclaration(node as ts.PropertyDeclaration);
      case ts.SyntaxKind.Constructor:
        return this.convertConstructorDeclaration(node as ts.ConstructorDeclaration);
      case ts.SyntaxKind.GetAccessor:
        return this.convertGetAccessor(node as ts.GetAccessorDeclaration);
      case ts.SyntaxKind.SetAccessor:
        return this.convertSetAccessor(node as ts.SetAccessorDeclaration);
      case ts.SyntaxKind.VariableStatement:
        return this.convertVariableStatement(node as ts.VariableStatement);
      case ts.SyntaxKind.VariableDeclaration:
        return this.convertVariableDeclaration(node as ts.VariableDeclaration);
      case ts.SyntaxKind.EnumDeclaration:
        return this.convertEnumDeclaration(node as ts.EnumDeclaration);
      case ts.SyntaxKind.TypeAliasDeclaration:
        return this.convertTypeAliasDeclaration(node as ts.TypeAliasDeclaration);
      case ts.SyntaxKind.ModuleDeclaration:
        return this.convertModuleDeclaration(node as ts.ModuleDeclaration);
      case ts.SyntaxKind.ImportDeclaration:
        return this.convertImportDeclaration(node as ts.ImportDeclaration);
      case ts.SyntaxKind.ExportDeclaration:
        return this.convertExportDeclaration(node as ts.ExportDeclaration);
      case ts.SyntaxKind.ExportAssignment:
        return this.convertExportAssignment(node as ts.ExportAssignment);
      case ts.SyntaxKind.IfStatement:
        return this.convertIfStatement(node as ts.IfStatement);
      case ts.SyntaxKind.WhileStatement:
        return this.convertWhileStatement(node as ts.WhileStatement);
      case ts.SyntaxKind.DoStatement:
        return this.convertDoStatement(node as ts.DoStatement);
      case ts.SyntaxKind.ForStatement:
        return this.convertForStatement(node as ts.ForStatement);
      case ts.SyntaxKind.ForOfStatement:
      case ts.SyntaxKind.ForInStatement:
        return this.convertForOfStatement(node as ts.ForOfStatement);
      case ts.SyntaxKind.SwitchStatement:
        return this.convertSwitchStatement(node as ts.SwitchStatement);
      case ts.SyntaxKind.TryStatement:
        return this.convertTryStatement(node as ts.TryStatement);
      case ts.SyntaxKind.ReturnStatement:
        return this.convertReturnStatement(node as ts.ReturnStatement);
      case ts.SyntaxKind.ThrowStatement:
        return this.convertThrowStatement(node as ts.ThrowStatement);
      case ts.SyntaxKind.BreakStatement:
        return this.convertBreakStatement(node as ts.BreakStatement);
      case ts.SyntaxKind.ContinueStatement:
        return this.convertContinueStatement(node as ts.ContinueStatement);
      case ts.SyntaxKind.ExpressionStatement:
        return this.convertExpressionStatement(node as ts.ExpressionStatement);
      case ts.SyntaxKind.EmptyStatement:
        return { kind: "xnkEmptyStmt" };
      case ts.SyntaxKind.DebuggerStatement:
        return { kind: "xnkComment", commentText: "debugger", isDocComment: false };
      case ts.SyntaxKind.LabeledStatement:
        return this.convertLabeledStatement(node as ts.LabeledStatement);
      case ts.SyntaxKind.Block:
        return this.convertBlock(node as ts.Block);
      case ts.SyntaxKind.CallExpression:
        return this.convertCallExpression(node as ts.CallExpression);
      case ts.SyntaxKind.NewExpression:
        return this.convertNewExpression(node as ts.NewExpression);
      case ts.SyntaxKind.BinaryExpression:
        return this.convertBinaryExpression(node as ts.BinaryExpression);
      case ts.SyntaxKind.ConditionalExpression:
        return this.convertConditionalExpression(node as ts.ConditionalExpression);
      case ts.SyntaxKind.PrefixUnaryExpression:
      case ts.SyntaxKind.PostfixUnaryExpression:
        return this.convertUnaryExpression(node as ts.PrefixUnaryExpression | ts.PostfixUnaryExpression);
      case ts.SyntaxKind.PropertyAccessExpression:
        return this.convertPropertyAccessExpression(node as ts.PropertyAccessExpression);
      case ts.SyntaxKind.ElementAccessExpression:
        return this.convertElementAccessExpression(node as ts.ElementAccessExpression);
      case ts.SyntaxKind.ArrowFunction:
        return this.convertArrowFunction(node as ts.ArrowFunction);
      case ts.SyntaxKind.FunctionExpression:
        return this.convertFunctionExpression(node as ts.FunctionExpression);
      case ts.SyntaxKind.ArrayLiteralExpression:
        return this.convertArrayLiteralExpression(node as ts.ArrayLiteralExpression);
      case ts.SyntaxKind.ObjectLiteralExpression:
        return this.convertObjectLiteralExpression(node as ts.ObjectLiteralExpression);
      case ts.SyntaxKind.TemplateExpression:
        return this.convertTemplateExpression(node as ts.TemplateExpression);
      case ts.SyntaxKind.NoSubstitutionTemplateLiteral:
        return { kind: "xnkStringLit", value: (node as ts.NoSubstitutionTemplateLiteral).text };
      case ts.SyntaxKind.TaggedTemplateExpression:
        return this.convertTaggedTemplateExpression(node as ts.TaggedTemplateExpression);
      case ts.SyntaxKind.ParenthesizedExpression:
        return this.convertNode((node as ts.ParenthesizedExpression).expression);
      case ts.SyntaxKind.AsExpression:
        return this.convertAsExpression(node as ts.AsExpression);
      case ts.SyntaxKind.TypeAssertionExpression:
        return this.convertTypeAssertion(node as ts.TypeAssertion);
      case ts.SyntaxKind.AwaitExpression:
        return this.convertAwaitExpression(node as ts.AwaitExpression);
      case ts.SyntaxKind.YieldExpression:
        return this.convertYieldExpression(node as ts.YieldExpression);
      case ts.SyntaxKind.SpreadElement:
        return this.convertSpreadElement(node as ts.SpreadElement);
      case ts.SyntaxKind.DeleteExpression:
        return this.convertDeleteExpression(node as ts.DeleteExpression);
      case ts.SyntaxKind.TypeOfExpression:
        return this.convertTypeOfExpression(node as ts.TypeOfExpression);
      case ts.SyntaxKind.VoidExpression:
        return this.convertVoidExpression(node as ts.VoidExpression);
      case ts.SyntaxKind.ThisKeyword:
        return { kind: "xnkThisExpr" };
      case ts.SyntaxKind.SuperKeyword:
        return { kind: "xnkBaseExpr" };
      case ts.SyntaxKind.MetaProperty:
        return this.convertMetaProperty(node as ts.MetaProperty);
      case ts.SyntaxKind.ObjectBindingPattern:
        return this.convertObjectBindingPattern(node as ts.ObjectBindingPattern);
      case ts.SyntaxKind.ArrayBindingPattern:
        return this.convertArrayBindingPattern(node as ts.ArrayBindingPattern);
      case ts.SyntaxKind.Identifier:
        return { kind: "xnkIdentifier", name: (node as ts.Identifier).text };
      case ts.SyntaxKind.NumericLiteral:
        return { kind: "xnkIntLit", value: (node as ts.NumericLiteral).text };
      case ts.SyntaxKind.BigIntLiteral:
        return { kind: "xnkIntLit", value: (node as ts.BigIntLiteral).text.replace(/n$/, ""), isBigInt: true };
      case ts.SyntaxKind.StringLiteral:
        return { kind: "xnkStringLit", value: (node as ts.StringLiteral).text };
      case ts.SyntaxKind.RegularExpressionLiteral:
        return { kind: "xnkStringLit", value: (node as ts.RegularExpressionLiteral).text, isRegex: true };
      case ts.SyntaxKind.TrueKeyword:
        return { kind: "xnkBoolLit", value: true };
      case ts.SyntaxKind.FalseKeyword:
        return { kind: "xnkBoolLit", value: false };
      case ts.SyntaxKind.NullKeyword:
        return { kind: "xnkNoneLit" };
      case ts.SyntaxKind.UndefinedKeyword:
        return { kind: "xnkNoneLit" };
      default:
        return { kind: "xnkUnknown", tsKind: ts.SyntaxKind[node.kind] };
    }
  }

  private convertSourceFile(node: ts.SourceFile): XLangNode {
    const declarations: XLangNode[] = [];
    node.statements.forEach(stmt => {
      declarations.push(this.convertNode(stmt));
    });
    return {
      kind: "xnkFile",
      fileName: node.fileName,
      declarations: declarations
    };
  }

  private convertClassDeclaration(node: ts.ClassDeclaration): XLangNode {
    const members: XLangNode[] = [];
    node.members.forEach(member => {
      members.push(this.convertNode(member));
    });

    const heritageClauses: XLangNode[] = [];
    if (node.heritageClauses) {
      node.heritageClauses.forEach(clause => {
        clause.types.forEach(type => {
          heritageClauses.push(this.convertType(type.expression as ts.TypeNode));
        });
      });
    }

    return {
      kind: "xnkClassDecl",
      name: node.name?.text || "anonymous",
      baseTypes: heritageClauses,
      members: members,
      typeParameters: node.typeParameters ? node.typeParameters.map(tp => this.convertTypeParameter(tp)) : [],
      modifiers: this.convertModifiers(node.modifiers)
    };
  }

  private convertInterfaceDeclaration(node: ts.InterfaceDeclaration): XLangNode {
    const members: XLangNode[] = [];
    node.members.forEach(member => {
      members.push(this.convertNode(member));
    });

    const baseTypes: XLangNode[] = [];
    if (node.heritageClauses) {
      node.heritageClauses.forEach(clause => {
        clause.types.forEach(type => {
          baseTypes.push(this.convertType(type.expression as ts.TypeNode));
        });
      });
    }

    return {
      kind: "xnkInterfaceDecl",
      name: node.name.text,
      baseTypes: baseTypes,
      members: members,
      typeParameters: node.typeParameters ? node.typeParameters.map(tp => this.convertTypeParameter(tp)) : []
    };
  }

  private convertFunctionDeclaration(node: ts.FunctionDeclaration): XLangNode {
    return {
      kind: "xnkFuncDecl",
      name: node.name?.text || "anonymous",
      parameters: node.parameters.map(p => this.convertParameter(p)),
      returnType: node.type ? this.convertType(node.type) : null,
      body: node.body ? this.convertNode(node.body) : null,
      isAsync: !!(node.modifiers?.some(m => m.kind === ts.SyntaxKind.AsyncKeyword)),
      typeParameters: node.typeParameters ? node.typeParameters.map(tp => this.convertTypeParameter(tp)) : []
    };
  }

  private convertMethodDeclaration(node: ts.MethodDeclaration): XLangNode {
    return {
      kind: "xnkMethodDecl",
      name: (node.name as ts.Identifier).text,
      parameters: node.parameters.map(p => this.convertParameter(p)),
      returnType: node.type ? this.convertType(node.type) : null,
      body: node.body ? this.convertNode(node.body) : null,
      isAsync: !!(node.modifiers?.some(m => m.kind === ts.SyntaxKind.AsyncKeyword)),
      modifiers: this.convertModifiers(node.modifiers)
    };
  }

  private convertPropertyDeclaration(node: ts.PropertyDeclaration): XLangNode {
    return {
      kind: "xnkFieldDecl",
      name: (node.name as ts.Identifier).text,
      type: node.type ? this.convertType(node.type) : null,
      initializer: node.initializer ? this.convertNode(node.initializer) : null,
      modifiers: this.convertModifiers(node.modifiers)
    };
  }

  private convertVariableStatement(node: ts.VariableStatement): XLangNode {
    const declarations = node.declarationList.declarations.map(decl => ({
      name: (decl.name as ts.Identifier).text,
      type: decl.type ? this.convertType(decl.type) : null,
      initializer: decl.initializer ? this.convertNode(decl.initializer) : null
    }));

    const kind = node.declarationList.flags & ts.NodeFlags.Const ? "xnkConstDecl" :
                 node.declarationList.flags & ts.NodeFlags.Let ? "xnkLetDecl" : "xnkVarDecl";

    return {
      kind: kind,
      declarations: declarations
    };
  }

  private convertEnumDeclaration(node: ts.EnumDeclaration): XLangNode {
    const members = node.members.map(member => ({
      name: (member.name as ts.Identifier).text,
      value: member.initializer ? this.convertNode(member.initializer) : null
    }));

    return {
      kind: "xnkEnumDecl",
      name: node.name.text,
      members: members
    };
  }

  private convertTypeAliasDeclaration(node: ts.TypeAliasDeclaration): XLangNode {
    return {
      kind: "xnkTypeDecl",
      name: node.name.text,
      typeBody: this.convertType(node.type),
      typeParameters: node.typeParameters ? node.typeParameters.map(tp => this.convertTypeParameter(tp)) : []
    };
  }

  private convertModuleDeclaration(node: ts.ModuleDeclaration): XLangNode {
    const body: XLangNode[] = [];
    if (node.body && ts.isModuleBlock(node.body)) {
      node.body.statements.forEach(stmt => {
        body.push(this.convertNode(stmt));
      });
    }

    return {
      kind: "xnkNamespace",
      name: node.name.text,
      body: body
    };
  }

  private convertImportDeclaration(node: ts.ImportDeclaration): XLangNode {
    return {
      kind: "xnkImport",
      path: (node.moduleSpecifier as ts.StringLiteral).text,
      imports: node.importClause ? this.convertImportClause(node.importClause) : []
    };
  }

  private convertImportClause(clause: ts.ImportClause): any[] {
    const imports: any[] = [];
    if (clause.name) {
      imports.push({ kind: "default", name: clause.name.text });
    }
    if (clause.namedBindings) {
      if (ts.isNamespaceImport(clause.namedBindings)) {
        imports.push({ kind: "namespace", name: clause.namedBindings.name.text });
      } else if (ts.isNamedImports(clause.namedBindings)) {
        clause.namedBindings.elements.forEach(element => {
          imports.push({
            kind: "named",
            name: element.name.text,
            propertyName: element.propertyName?.text
          });
        });
      }
    }
    return imports;
  }

  private convertExportDeclaration(node: ts.ExportDeclaration): XLangNode {
    return {
      kind: "xnkExport",
      moduleSpecifier: node.moduleSpecifier ? (node.moduleSpecifier as ts.StringLiteral).text : null,
      exports: node.exportClause && ts.isNamedExports(node.exportClause) ? 
        node.exportClause.elements.map(e => ({
          name: e.name.text,
          propertyName: e.propertyName?.text
        })) : []
    };
  }

  private convertIfStatement(node: ts.IfStatement): XLangNode {
    return {
      kind: "xnkIfStmt",
      condition: this.convertNode(node.expression),
      thenBranch: this.convertNode(node.thenStatement),
      elseBranch: node.elseStatement ? this.convertNode(node.elseStatement) : null
    };
  }

  private convertWhileStatement(node: ts.WhileStatement): XLangNode {
    return {
      kind: "xnkWhileStmt",
      condition: this.convertNode(node.expression),
      body: this.convertNode(node.statement)
    };
  }

  private convertForStatement(node: ts.ForStatement): XLangNode {
    return {
      kind: "xnkForStmt",
      initializer: node.initializer ? this.convertNode(node.initializer) : null,
      condition: node.condition ? this.convertNode(node.condition) : null,
      incrementor: node.incrementor ? this.convertNode(node.incrementor) : null,
      body: this.convertNode(node.statement)
    };
  }

  private convertForOfStatement(node: ts.ForOfStatement | ts.ForInStatement): XLangNode {
    return {
      kind: "xnkForeachStmt",
      variable: this.convertNode(node.initializer),
      iterable: this.convertNode(node.expression),
      body: this.convertNode(node.statement)
    };
  }

  private convertSwitchStatement(node: ts.SwitchStatement): XLangNode {
    const cases = node.caseBlock.clauses.map(clause => {
      if (ts.isCaseClause(clause)) {
        return {
          expression: this.convertNode(clause.expression),
          statements: clause.statements.map(s => this.convertNode(s))
        };
      } else {
        return {
          expression: null,
          statements: clause.statements.map(s => this.convertNode(s))
        };
      }
    });

    return {
      kind: "xnkSwitchStmt",
      expression: this.convertNode(node.expression),
      cases: cases
    };
  }

  private convertTryStatement(node: ts.TryStatement): XLangNode {
    return {
      kind: "xnkTryStmt",
      tryBlock: this.convertNode(node.tryBlock),
      catchClause: node.catchClause ? {
        kind: "xnkCatchStmt",
        variable: node.catchClause.variableDeclaration ? 
          (node.catchClause.variableDeclaration.name as ts.Identifier).text : null,
        type: node.catchClause.variableDeclaration?.type ? 
          this.convertType(node.catchClause.variableDeclaration.type) : null,
        body: this.convertNode(node.catchClause.block)
      } : null,
      finallyBlock: node.finallyBlock ? this.convertNode(node.finallyBlock) : null
    };
  }

  private convertReturnStatement(node: ts.ReturnStatement): XLangNode {
    return {
      kind: "xnkReturnStmt",
      expression: node.expression ? this.convertNode(node.expression) : null
    };
  }

  private convertThrowStatement(node: ts.ThrowStatement): XLangNode {
    return {
      kind: "xnkThrowStmt",
      expression: this.convertNode(node.expression)
    };
  }

  private convertBlock(node: ts.Block): XLangNode {
    return {
      kind: "xnkBlockStmt",
      statements: node.statements.map(s => this.convertNode(s))
    };
  }

  private convertCallExpression(node: ts.CallExpression): XLangNode {
    return {
      kind: "xnkCallExpr",
      callee: this.convertNode(node.expression),
      arguments: node.arguments.map(arg => this.convertNode(arg)),
      typeArguments: node.typeArguments ? node.typeArguments.map(t => this.convertType(t)) : []
    };
  }

  private convertBinaryExpression(node: ts.BinaryExpression): XLangNode {
    // Map TypeScript operators to XLang semantic operators
    const operator = this.mapBinaryOperator(node.operatorToken.kind);

    // Check if assignment
    if (this.isAssignmentOperator(node.operatorToken.kind)) {
      return {
        kind: "xnkAsgn",
        left: this.convertNode(node.left),
        right: operator === "=" ? this.convertNode(node.right) : {
          kind: "xnkBinaryExpr",
          operator: operator.replace(/Assign$/, ""),
          left: this.convertNode(node.left),
          right: this.convertNode(node.right)
        }
      };
    }

    return {
      kind: "xnkBinaryExpr",
      operator,
      left: this.convertNode(node.left),
      right: this.convertNode(node.right)
    };
  }

  private mapBinaryOperator(kind: ts.SyntaxKind): string {
    switch (kind) {
      // Arithmetic
      case ts.SyntaxKind.PlusToken: return "add";
      case ts.SyntaxKind.MinusToken: return "sub";
      case ts.SyntaxKind.AsteriskToken: return "mul";
      case ts.SyntaxKind.SlashToken: return "div";
      case ts.SyntaxKind.PercentToken: return "mod";
      case ts.SyntaxKind.AsteriskAsteriskToken: return "pow";

      // Bitwise
      case ts.SyntaxKind.AmpersandToken: return "bitand";
      case ts.SyntaxKind.BarToken: return "bitor";
      case ts.SyntaxKind.CaretToken: return "bitxor";
      case ts.SyntaxKind.LessThanLessThanToken: return "shl";
      case ts.SyntaxKind.GreaterThanGreaterThanToken: return "shr";
      case ts.SyntaxKind.GreaterThanGreaterThanGreaterThanToken: return "shru";

      // Comparison
      case ts.SyntaxKind.EqualsEqualsToken: return "eq";
      case ts.SyntaxKind.ExclamationEqualsToken: return "neq";
      case ts.SyntaxKind.LessThanToken: return "lt";
      case ts.SyntaxKind.LessThanEqualsToken: return "le";
      case ts.SyntaxKind.GreaterThanToken: return "gt";
      case ts.SyntaxKind.GreaterThanEqualsToken: return "ge";
      case ts.SyntaxKind.EqualsEqualsEqualsToken: return "is";
      case ts.SyntaxKind.ExclamationEqualsEqualsToken: return "isnot";

      // Logical
      case ts.SyntaxKind.AmpersandAmpersandToken: return "and";
      case ts.SyntaxKind.BarBarToken: return "or";
      case ts.SyntaxKind.QuestionQuestionToken: return "nullcoalesce";

      // Assignment
      case ts.SyntaxKind.EqualsToken: return "=";
      case ts.SyntaxKind.PlusEqualsToken: return "addAssign";
      case ts.SyntaxKind.MinusEqualsToken: return "subAssign";
      case ts.SyntaxKind.AsteriskEqualsToken: return "mulAssign";
      case ts.SyntaxKind.AsteriskAsteriskEqualsToken: return "powAssign";
      case ts.SyntaxKind.SlashEqualsToken: return "divAssign";
      case ts.SyntaxKind.PercentEqualsToken: return "modAssign";
      case ts.SyntaxKind.AmpersandEqualsToken: return "bitandAssign";
      case ts.SyntaxKind.BarEqualsToken: return "bitorAssign";
      case ts.SyntaxKind.CaretEqualsToken: return "bitxorAssign";
      case ts.SyntaxKind.LessThanLessThanEqualsToken: return "shlAssign";
      case ts.SyntaxKind.GreaterThanGreaterThanEqualsToken: return "shrAssign";
      case ts.SyntaxKind.GreaterThanGreaterThanGreaterThanEqualsToken: return "shruAssign";
      case ts.SyntaxKind.AmpersandAmpersandEqualsToken: return "andAssign";
      case ts.SyntaxKind.BarBarEqualsToken: return "orAssign";
      case ts.SyntaxKind.QuestionQuestionEqualsToken: return "nullcoalesceAssign";

      // Special
      case ts.SyntaxKind.InKeyword: return "in";
      case ts.SyntaxKind.InstanceOfKeyword: return "istype";

      default: return ts.tokenToString(kind) || "unknown";
    }
  }

  private isAssignmentOperator(kind: ts.SyntaxKind): boolean {
    return kind === ts.SyntaxKind.EqualsToken ||
           kind === ts.SyntaxKind.PlusEqualsToken ||
           kind === ts.SyntaxKind.MinusEqualsToken ||
           kind === ts.SyntaxKind.AsteriskEqualsToken ||
           kind === ts.SyntaxKind.AsteriskAsteriskEqualsToken ||
           kind === ts.SyntaxKind.SlashEqualsToken ||
           kind === ts.SyntaxKind.PercentEqualsToken ||
           kind === ts.SyntaxKind.AmpersandEqualsToken ||
           kind === ts.SyntaxKind.BarEqualsToken ||
           kind === ts.SyntaxKind.CaretEqualsToken ||
           kind === ts.SyntaxKind.LessThanLessThanEqualsToken ||
           kind === ts.SyntaxKind.GreaterThanGreaterThanEqualsToken ||
           kind === ts.SyntaxKind.GreaterThanGreaterThanGreaterThanEqualsToken ||
           kind === ts.SyntaxKind.AmpersandAmpersandEqualsToken ||
           kind === ts.SyntaxKind.BarBarEqualsToken ||
           kind === ts.SyntaxKind.QuestionQuestionEqualsToken;
  }

  private convertPropertyAccessExpression(node: ts.PropertyAccessExpression): XLangNode {
    return {
      kind: "xnkMemberAccessExpr",
      expression: this.convertNode(node.expression),
      member: node.name.text
    };
  }

  private convertArrowFunction(node: ts.ArrowFunction): XLangNode {
    return {
      kind: "xnkLambdaExpr",
      parameters: node.parameters.map(p => this.convertParameter(p)),
      body: this.convertNode(node.body),
      isAsync: !!(node.modifiers?.some(m => m.kind === ts.SyntaxKind.AsyncKeyword))
    };
  }

  private convertParameter(node: ts.ParameterDeclaration): any {
    return {
      kind: "xnkParameter",
      name: (node.name as ts.Identifier).text,
      type: node.type ? this.convertType(node.type) : null,
      defaultValue: node.initializer ? this.convertNode(node.initializer) : null,
      isOptional: !!node.questionToken
    };
  }

  private convertType(node: ts.TypeNode): XLangNode {
    switch (node.kind) {
      case ts.SyntaxKind.StringKeyword:
      case ts.SyntaxKind.NumberKeyword:
      case ts.SyntaxKind.BooleanKeyword:
      case ts.SyntaxKind.VoidKeyword:
      case ts.SyntaxKind.AnyKeyword:
        return { kind: "xnkNamedType", name: ts.SyntaxKind[node.kind].replace("Keyword", "").toLowerCase() };
      case ts.SyntaxKind.ArrayType:
        return {
          kind: "xnkArrayType",
          elementType: this.convertType((node as ts.ArrayTypeNode).elementType)
        };
      case ts.SyntaxKind.TypeReference:
        const typeRef = node as ts.TypeReferenceNode;
        return {
          kind: "xnkNamedType",
          name: (typeRef.typeName as ts.Identifier).text,
          typeArguments: typeRef.typeArguments ? typeRef.typeArguments.map(t => this.convertType(t)) : []
        };
      case ts.SyntaxKind.UnionType:
        return {
          kind: "xnkUnionType",
          types: (node as ts.UnionTypeNode).types.map(t => this.convertType(t))
        };
      case ts.SyntaxKind.IntersectionType:
        return {
          kind: "xnkIntersectionType",
          types: (node as ts.IntersectionTypeNode).types.map(t => this.convertType(t))
        };
      case ts.SyntaxKind.FunctionType:
        const funcType = node as ts.FunctionTypeNode;
        return {
          kind: "xnkFuncType",
          parameters: funcType.parameters.map(p => this.convertParameter(p)),
          returnType: this.convertType(funcType.type)
        };
      default:
        return { kind: "xnkUnknown", tsKind: ts.SyntaxKind[node.kind] };
    }
  }

  private convertTypeParameter(node: ts.TypeParameterDeclaration): any {
    return {
      kind: "xnkGenericParameter",
      name: node.name.text,
      constraint: node.constraint ? this.convertType(node.constraint) : null,
      default: node.default ? this.convertType(node.default) : null
    };
  }

  private convertModifiers(modifiers?: ts.NodeArray<ts.Modifier>): any {
    if (!modifiers) return {};
    const result: any = {};
    modifiers.forEach(mod => {
      switch (mod.kind) {
        case ts.SyntaxKind.PublicKeyword: result.isPublic = true; break;
        case ts.SyntaxKind.PrivateKeyword: result.isPrivate = true; break;
        case ts.SyntaxKind.ProtectedKeyword: result.isProtected = true; break;
        case ts.SyntaxKind.StaticKeyword: result.isStatic = true; break;
        case ts.SyntaxKind.AbstractKeyword: result.isAbstract = true; break;
        case ts.SyntaxKind.AsyncKeyword: result.isAsync = true; break;
        case ts.SyntaxKind.ReadonlyKeyword: result.isReadonly = true; break;
      }
    });
    return result;
  }

  // New statement converters
  private convertDoStatement(node: ts.DoStatement): XLangNode {
    return {
      kind: "xnkDoWhileStmt",
      condition: this.convertNode(node.expression),
      body: this.convertNode(node.statement)
    };
  }

  private convertBreakStatement(node: ts.BreakStatement): XLangNode {
    return {
      kind: "xnkBreakStmt",
      label: node.label ? node.label.text : null
    };
  }

  private convertContinueStatement(node: ts.ContinueStatement): XLangNode {
    return {
      kind: "xnkContinueStmt",
      label: node.label ? node.label.text : null
    };
  }

  private convertExpressionStatement(node: ts.ExpressionStatement): XLangNode {
    return this.convertNode(node.expression);
  }

  private convertLabeledStatement(node: ts.LabeledStatement): XLangNode {
    return {
      kind: "xnkLabeledStmt",
      label: node.label.text,
      statement: this.convertNode(node.statement)
    };
  }

  // Constructor and accessor converters
  private convertConstructorDeclaration(node: ts.ConstructorDeclaration): XLangNode {
    return {
      kind: "xnkConstructorDecl",
      parameters: node.parameters.map(p => this.convertParameter(p)),
      body: node.body ? this.convertNode(node.body) : { kind: "xnkBlockStmt", statements: [] }
    };
  }

  private convertGetAccessor(node: ts.GetAccessorDeclaration): XLangNode {
    return {
      kind: "xnkMethodDecl",
      name: (node.name as ts.Identifier).text,
      parameters: [],
      returnType: node.type ? this.convertType(node.type) : null,
      body: node.body ? this.convertNode(node.body) : null,
      isGetter: true,
      modifiers: this.convertModifiers(node.modifiers)
    };
  }

  private convertSetAccessor(node: ts.SetAccessorDeclaration): XLangNode {
    return {
      kind: "xnkMethodDecl",
      name: (node.name as ts.Identifier).text,
      parameters: node.parameters.map(p => this.convertParameter(p)),
      returnType: null,
      body: node.body ? this.convertNode(node.body) : null,
      isSetter: true,
      modifiers: this.convertModifiers(node.modifiers)
    };
  }

  private convertVariableDeclaration(node: ts.VariableDeclaration): XLangNode {
    const kind = node.parent && ts.isVariableDeclarationList(node.parent)
      ? (node.parent.flags & ts.NodeFlags.Const ? "xnkConstDecl" :
         node.parent.flags & ts.NodeFlags.Let ? "xnkLetDecl" : "xnkVarDecl")
      : "xnkVarDecl";

    return {
      kind,
      name: (node.name as ts.Identifier).text,
      type: node.type ? this.convertType(node.type) : null,
      initializer: node.initializer ? this.convertNode(node.initializer) : null
    };
  }

  // Expression converters
  private convertConditionalExpression(node: ts.ConditionalExpression): XLangNode {
    return {
      kind: "xnkIfStmt",  // Using if-statement as expression
      condition: this.convertNode(node.condition),
      thenBranch: this.convertNode(node.whenTrue),
      elseBranch: this.convertNode(node.whenFalse),
      isExpression: true
    };
  }

  private convertNewExpression(node: ts.NewExpression): XLangNode {
    return {
      kind: "xnkCallExpr",
      callee: this.convertNode(node.expression),
      arguments: node.arguments ? Array.from(node.arguments).map(arg => this.convertNode(arg)) : [],
      typeArguments: node.typeArguments ? node.typeArguments.map(t => this.convertType(t)) : [],
      isNew: true
    };
  }

  private convertUnaryExpression(node: ts.PrefixUnaryExpression | ts.PostfixUnaryExpression): XLangNode {
    const operator = this.mapUnaryOperator(node.operator, ts.isPostfixUnaryExpression(node));

    return {
      kind: "xnkUnaryExpr",
      operator,
      operand: this.convertNode(node.operand)
    };
  }

  private mapUnaryOperator(kind: ts.SyntaxKind, isPostfix: boolean): string {
    switch (kind) {
      case ts.SyntaxKind.PlusToken: return "pos";
      case ts.SyntaxKind.MinusToken: return "neg";
      case ts.SyntaxKind.ExclamationToken: return "not";
      case ts.SyntaxKind.TildeToken: return "bitnot";
      case ts.SyntaxKind.PlusPlusToken: return isPostfix ? "postinc" : "preinc";
      case ts.SyntaxKind.MinusMinusToken: return isPostfix ? "postdec" : "predec";
      default: return ts.tokenToString(kind) || "unknown";
    }
  }

  private convertElementAccessExpression(node: ts.ElementAccessExpression): XLangNode {
    return {
      kind: "xnkIndexExpr",
      expression: this.convertNode(node.expression),
      index: this.convertNode(node.argumentExpression)
    };
  }

  private convertFunctionExpression(node: ts.FunctionExpression): XLangNode {
    return {
      kind: "xnkLambdaExpr",
      name: node.name ? node.name.text : null,
      parameters: node.parameters.map(p => this.convertParameter(p)),
      returnType: node.type ? this.convertType(node.type) : null,
      body: node.body ? this.convertNode(node.body) : { kind: "xnkBlockStmt", statements: [] },
      isAsync: !!(node.modifiers?.some(m => m.kind === ts.SyntaxKind.AsyncKeyword))
    };
  }

  private convertArrayLiteralExpression(node: ts.ArrayLiteralExpression): XLangNode {
    return {
      kind: "xnkArrayLiteral",
      elements: node.elements.map(elem => this.convertNode(elem))
    };
  }

  private convertObjectLiteralExpression(node: ts.ObjectLiteralExpression): XLangNode {
    const entries: XLangNode[] = [];

    node.properties.forEach(prop => {
      if (ts.isPropertyAssignment(prop)) {
        entries.push({
          kind: "xnkDictEntry",
          key: this.convertNode(prop.name),
          value: this.convertNode(prop.initializer)
        });
      } else if (ts.isShorthandPropertyAssignment(prop)) {
        const ident = { kind: "xnkIdentifier", name: prop.name.text };
        entries.push({
          kind: "xnkDictEntry",
          key: ident,
          value: ident,
          isShorthand: true
        });
      } else if (ts.isSpreadAssignment(prop)) {
        entries.push({
          kind: "xnkUnaryExpr",
          operator: "spread",
          operand: this.convertNode(prop.expression)
        });
      } else if (ts.isMethodDeclaration(prop)) {
        entries.push({
          kind: "xnkDictEntry",
          key: this.convertNode(prop.name),
          value: this.convertMethodDeclaration(prop)
        });
      }
    });

    return {
      kind: "xnkMapLiteral",
      entries
    };
  }

  private convertTemplateExpression(node: ts.TemplateExpression): XLangNode {
    const parts: XLangNode[] = [];

    // Add head
    parts.push({ kind: "xnkStringLit", value: node.head.text });

    // Add template spans
    node.templateSpans.forEach(span => {
      parts.push(this.convertNode(span.expression));
      parts.push({ kind: "xnkStringLit", value: span.literal.text });
    });

    return {
      kind: "xnkCallExpr",
      callee: { kind: "xnkIdentifier", name: "strformat" },
      arguments: parts,
      isStringInterpolation: true
    };
  }

  private convertTaggedTemplateExpression(node: ts.TaggedTemplateExpression): XLangNode {
    const template = node.template;
    const parts: XLangNode[] = [];

    if (ts.isTemplateExpression(template)) {
      parts.push({ kind: "xnkStringLit", value: template.head.text });
      template.templateSpans.forEach(span => {
        parts.push(this.convertNode(span.expression));
        parts.push({ kind: "xnkStringLit", value: span.literal.text });
      });
    } else {
      parts.push({ kind: "xnkStringLit", value: (template as ts.NoSubstitutionTemplateLiteral).text });
    }

    return {
      kind: "xnkCallExpr",
      callee: this.convertNode(node.tag),
      arguments: parts,
      isTaggedTemplate: true
    };
  }

  private convertAsExpression(node: ts.AsExpression): XLangNode {
    return {
      kind: "xnkTypeAssertion",
      expression: this.convertNode(node.expression),
      type: this.convertType(node.type)
    };
  }

  private convertTypeAssertion(node: ts.TypeAssertion): XLangNode {
    return {
      kind: "xnkTypeAssertion",
      expression: this.convertNode(node.expression),
      type: this.convertType(node.type)
    };
  }

  private convertAwaitExpression(node: ts.AwaitExpression): XLangNode {
    return {
      kind: "xnkUnaryExpr",
      operator: "await",
      operand: this.convertNode(node.expression)
    };
  }

  private convertYieldExpression(node: ts.YieldExpression): XLangNode {
    return {
      kind: "xnkIteratorYield",
      value: node.expression ? this.convertNode(node.expression) : null,
      isDelegate: !!node.asteriskToken
    };
  }

  private convertSpreadElement(node: ts.SpreadElement): XLangNode {
    return {
      kind: "xnkUnaryExpr",
      operator: "spread",
      operand: this.convertNode(node.expression)
    };
  }

  private convertDeleteExpression(node: ts.DeleteExpression): XLangNode {
    return {
      kind: "xnkUnaryExpr",
      operator: "delete",
      operand: this.convertNode(node.expression)
    };
  }

  private convertTypeOfExpression(node: ts.TypeOfExpression): XLangNode {
    return {
      kind: "xnkTypeOfExpr",
      expression: this.convertNode(node.expression)
    };
  }

  private convertVoidExpression(node: ts.VoidExpression): XLangNode {
    return {
      kind: "xnkUnaryExpr",
      operator: "void",
      operand: this.convertNode(node.expression)
    };
  }

  private convertMetaProperty(node: ts.MetaProperty): XLangNode {
    return {
      kind: "xnkMemberAccessExpr",
      expression: { kind: "xnkIdentifier", name: node.keywordToken === ts.SyntaxKind.NewKeyword ? "new" : "import" },
      member: node.name.text,
      isMetaProperty: true
    };
  }

  private convertObjectBindingPattern(node: ts.ObjectBindingPattern): XLangNode {
    const fields: string[] = [];
    const defaults: any[] = [];

    node.elements.forEach(elem => {
      if (ts.isIdentifier(elem.name)) {
        fields.push(elem.name.text);
        defaults.push(elem.initializer ? this.convertNode(elem.initializer) : null);
      }
    });

    return {
      kind: "xnkDestructureObj",
      fields,
      defaults
    };
  }

  private convertArrayBindingPattern(node: ts.ArrayBindingPattern): XLangNode {
    const vars: string[] = [];
    let rest: string | null = null;

    node.elements.forEach(elem => {
      if (ts.isOmittedExpression(elem)) {
        vars.push("_");
      } else if (ts.isIdentifier(elem.name)) {
        if (elem.dotDotDotToken) {
          rest = elem.name.text;
        } else {
          vars.push(elem.name.text);
        }
      }
    });

    return {
      kind: "xnkDestructureArray",
      vars,
      rest
    };
  }

  private convertExportAssignment(node: ts.ExportAssignment): XLangNode {
    return {
      kind: "xnkExport",
      isDefault: node.isExportEquals ? false : true,
      declaration: this.convertNode(node.expression)
    };
  }
}

// Main execution
if (process.argv.length < 3) {
  console.log("Usage: ts-node typescript_to_xlang.ts <typescript_file>");
  process.exit(1);
}

const parser = new TypeScriptToXLangParser(process.argv[2]);
const xlangAst = parser.parse();
console.log(JSON.stringify(xlangAst, null, 2));