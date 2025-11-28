
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
      case ts.SyntaxKind.VariableStatement:
        return this.convertVariableStatement(node as ts.VariableStatement);
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
      case ts.SyntaxKind.IfStatement:
        return this.convertIfStatement(node as ts.IfStatement);
      case ts.SyntaxKind.WhileStatement:
        return this.convertWhileStatement(node as ts.WhileStatement);
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
      case ts.SyntaxKind.Block:
        return this.convertBlock(node as ts.Block);
      case ts.SyntaxKind.CallExpression:
        return this.convertCallExpression(node as ts.CallExpression);
      case ts.SyntaxKind.BinaryExpression:
        return this.convertBinaryExpression(node as ts.BinaryExpression);
      case ts.SyntaxKind.PropertyAccessExpression:
        return this.convertPropertyAccessExpression(node as ts.PropertyAccessExpression);
      case ts.SyntaxKind.ArrowFunction:
        return this.convertArrowFunction(node as ts.ArrowFunction);
      case ts.SyntaxKind.Identifier:
        return { kind: "xnkIdentifier", name: (node as ts.Identifier).text };
      case ts.SyntaxKind.NumericLiteral:
        return { kind: "xnkIntLit", value: (node as ts.NumericLiteral).text };
      case ts.SyntaxKind.StringLiteral:
        return { kind: "xnkStringLit", value: (node as ts.StringLiteral).text };
      case ts.SyntaxKind.TrueKeyword:
        return { kind: "xnkBoolLit", value: true };
      case ts.SyntaxKind.FalseKeyword:
        return { kind: "xnkBoolLit", value: false };
      case ts.SyntaxKind.NullKeyword:
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
    return {
      kind: "xnkBinaryExpr",
      operator: ts.tokenToString(node.operatorToken.kind),
      left: this.convertNode(node.left),
      right: this.convertNode(node.right)
    };
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
}

// Main execution
if (process.argv.length < 3) {
  console.log("Usage: ts-node typescript_to_xlang.ts <typescript_file>");
  process.exit(1);
}

const parser = new TypeScriptToXLangParser(process.argv[2]);
const xlangAst = parser.parse();
console.log(JSON.stringify(xlangAst, null, 2));