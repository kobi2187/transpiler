import scala.meta._
import scala.meta.parsers.Parsed
import scala.io.Source
import java.io.{File, PrintWriter}
import java.nio.file.{Files, Paths}
import scala.collection.mutable

/**
 * Comprehensive Scala to XLang Parser
 * Converts Scala source code to XLang intermediate representation JSON.
 * Supports all Scala language features through Scala 3.
 */
object ScalaToXLangParser {

  private val statistics = mutable.Map[String, Int]()
  private var successCount = 0
  private var failCount = 0
  private val failedFiles = mutable.ArrayBuffer[String]()

  // Binary operator mapping: Scala syntax -> XLang semantic operator
  private val binaryOpMap = Map(
    "+" -> "add",
    "-" -> "sub",
    "*" -> "mul",
    "/" -> "div",
    "%" -> "mod",
    "&" -> "bitand",
    "|" -> "bitor",
    "^" -> "bitxor",
    "<<" -> "shl",
    ">>" -> "shr",
    ">>>" -> "shru",
    "==" -> "eq",
    "!=" -> "neq",
    "<" -> "lt",
    "<=" -> "le",
    ">" -> "gt",
    ">=" -> "ge",
    "&&" -> "and",
    "||" -> "or",
    "+=" -> "adda",
    "-=" -> "suba",
    "*=" -> "mula",
    "/=" -> "diva",
    "%=" -> "moda",
    "&=" -> "bitanda",
    "|=" -> "bitora",
    "^=" -> "bitxora",
    "<<=" -> "shla",
    ">>=" -> "shra"
  )

  // Unary operator mapping
  private val unaryOpMap = Map(
    "-" -> "neg",
    "+" -> "pos",
    "!" -> "not",
    "~" -> "bitnot"
  )

  def main(args: Array[String]): Unit = {
    if (args.length != 1) {
      System.err.println("Usage: scala ScalaToXLangParser <scala_file_or_directory>")
      System.err.println("  For a file: outputs JSON to stdout")
      System.err.println("  For a directory: recursively creates .xljs files next to each .scala file")
      sys.exit(1)
    }

    val inputPath = args(0)
    val inputFile = new File(inputPath)

    if (!inputFile.exists()) {
      System.err.println(s"Error: Path not found: $inputPath")
      sys.exit(1)
    }

    if (inputFile.isDirectory) {
      processDirectory(inputFile)
      printSummary()
    } else {
      processSingleFile(inputFile, outputToStdout = true)
    }
  }

  private def processDirectory(directory: File): Unit = {
    def walkFiles(file: File): Seq[File] = {
      if (file.isDirectory) {
        file.listFiles().flatMap(walkFiles)
      } else if (file.getName.endsWith(".scala")) {
        Seq(file)
      } else {
        Seq.empty
      }
    }

    walkFiles(directory).foreach(file => processSingleFile(file, outputToStdout = false))
  }

  private def processSingleFile(scalaFile: File, outputToStdout: Boolean): Unit = {
    val filePath = scalaFile.getAbsolutePath
    try {
      val code = Source.fromFile(filePath).mkString
      val parsed = code.parse[Source]

      parsed match {
        case Parsed.Success(tree) =>
          val xlangAst = convertToXLang(tree, filePath)
          val json = toJson(xlangAst)

          if (outputToStdout) {
            println(json)
            printStatistics()
          } else {
            val xljsPath = filePath.replaceAll("\\.scala$", ".xljs")
            val writer = new PrintWriter(new File(xljsPath))
            try {
              writer.write(json)
            } finally {
              writer.close()
            }
            successCount += 1
            System.err.println(s"OK: ${scalaFile.getName}")
          }

        case Parsed.Error(pos, message, _) =>
          failCount += 1
          failedFiles += filePath
          System.err.println(s"FAIL: ${scalaFile.getName}")
          System.err.println(s"  $message at ${pos.startLine}:${pos.startColumn}")
      }
    } catch {
      case e: Exception =>
        failCount += 1
        failedFiles += filePath
        System.err.println(s"FAIL: ${scalaFile.getName} - ${e.getMessage}")
    }
  }

  private def printStatistics(): Unit = {
    if (statistics.nonEmpty) {
      System.err.println("\nScala AST Node Statistics:")
      System.err.println("=========================")
      statistics.toSeq.sortBy(_._1).foreach { case (key, count) =>
        System.err.println(f"$key%-25s: $count%d")
      }
      System.err.println("-------------------------")
      System.err.println(s"Total node types: ${statistics.size}")
    }
  }

  private def printSummary(): Unit = {
    System.err.println("\n=================================")
    System.err.println("Parse Summary")
    System.err.println("=================================")
    System.err.println(s"Success: $successCount")
    System.err.println(s"Failed:  $failCount")
    if (failedFiles.nonEmpty) {
      System.err.println("\nFailed files:")
      failedFiles.foreach(f => System.err.println(s"  $f"))
    }
    printStatistics()
  }

  private def incrementStat(key: String): Unit = {
    statistics(key) = statistics.getOrElse(key, 0) + 1
  }

  // JSON conversion helpers
  private def toJson(value: Any, indent: Int = 0): String = {
    val indentStr = "  " * indent
    val nextIndentStr = "  " * (indent + 1)

    value match {
      case m: Map[_, _] =>
        if (m.isEmpty) "{}"
        else {
          val entries = m.map { case (k, v) =>
            s"""$nextIndentStr"$k": ${toJson(v, indent + 1)}"""
          }.mkString(",\n")
          s"{\n$entries\n$indentStr}"
        }
      case s: Seq[_] =>
        if (s.isEmpty) "[]"
        else {
          val entries = s.map(v => s"$nextIndentStr${toJson(v, indent + 1)}").mkString(",\n")
          s"[\n$entries\n$indentStr]"
        }
      case s: String => s""""${escapeJson(s)}""""
      case i: Int => i.toString
      case l: Long => l.toString
      case d: Double => d.toString
      case b: Boolean => b.toString
      case null => "null"
      case None => "null"
      case Some(v) => toJson(v, indent)
      case _ => s""""$value""""
    }
  }

  private def escapeJson(s: String): String = {
    s.replace("\\", "\\\\")
     .replace("\"", "\\\"")
     .replace("\n", "\\n")
     .replace("\r", "\\r")
     .replace("\t", "\\t")
  }

  // Main conversion function
  private def convertToXLang(tree: Source, filePath: String): Map[String, Any] = {
    incrementStat("Source")

    val declarations = mutable.ArrayBuffer[Map[String, Any]]()

    tree.stats.foreach {
      case pkg: Pkg =>
        incrementStat("Package")
        // Add package declaration
        declarations += Map(
          "kind" -> "xnkNamespace",
          "namespaceName" -> pkg.ref.syntax,
          "namespaceBody" -> pkg.stats.map(convertTopLevelStat).toSeq
        )

      case imp: Import =>
        declarations += convertImport(imp)

      case other =>
        declarations += convertTopLevelStat(other)
    }

    Map(
      "kind" -> "xnkFile",
      "fileName" -> new File(filePath).getName,
      "sourceLang" -> "scala",
      "moduleDecls" -> declarations.toSeq
    )
  }

  private def convertImport(imp: Import): Map[String, Any] = {
    incrementStat("Import")
    imp.importers.headOption match {
      case Some(importer) =>
        Map(
          "kind" -> "xnkImport",
          "importPath" -> importer.ref.syntax,
          "importees" -> importer.importees.map {
            case Importee.Name(name) => Map("name" -> name.value)
            case Importee.Rename(name, rename) => Map("name" -> name.value, "alias" -> rename.value)
            case Importee.Wildcard() => Map("wildcard" -> true)
            case _ => Map("name" -> "_")
          }.toSeq
        )
      case None =>
        Map("kind" -> "xnkImport", "importPath" -> "")
    }
  }

  private def convertTopLevelStat(stat: Stat): Map[String, Any] = stat match {
    case cls: Defn.Class => convertClass(cls)
    case trt: Defn.Trait => convertTrait(trt)
    case obj: Defn.Object => convertObject(obj)
    case defn: Defn.Def => convertDef(defn)
    case value: Defn.Val => convertVal(value)
    case variable: Defn.Var => convertVar(variable)
    case typeAlias: Defn.Type => convertTypeAlias(typeAlias)
    case _ =>
      incrementStat("UnknownTopLevel")
      Map("kind" -> "xnkUnknown", "unknownData" -> stat.syntax)
  }

  private def convertClass(cls: Defn.Class): Map[String, Any] = {
    incrementStat("ClassDecl")

    val members = cls.templ.stats.map(_.map(convertMember).toSeq).getOrElse(Seq.empty)

    Map(
      "kind" -> "xnkClassDecl",
      "typeNameDecl" -> cls.name.value,
      "typeParams" -> cls.tparams.map(convertTypeParam).toSeq,
      "ctorParams" -> cls.ctor.paramss.flatten.map(convertParameter).toSeq,
      "baseTypes" -> cls.templ.inits.map(init => convertType(init.tpe)).toSeq,
      "members" -> members,
      "typeIsAbstract" -> cls.mods.exists(_.is[Mod.Abstract]),
      "typeIsFinal" -> cls.mods.exists(_.is[Mod.Final]),
      "typeIsSealed" -> cls.mods.exists(_.is[Mod.Sealed]),
      "typeIsCase" -> cls.mods.exists(_.is[Mod.Case]),
      "typeIsPrivate" -> cls.mods.exists(_.is[Mod.Private]),
      "typeIsProtected" -> cls.mods.exists(_.is[Mod.Protected])
    )
  }

  private def convertTrait(trt: Defn.Trait): Map[String, Any] = {
    incrementStat("TraitDecl")

    val members = trt.templ.stats.map(_.map(convertMember).toSeq).getOrElse(Seq.empty)

    Map(
      "kind" -> "xnkInterfaceDecl",
      "typeNameDecl" -> trt.name.value,
      "typeParams" -> trt.tparams.map(convertTypeParam).toSeq,
      "baseTypes" -> trt.templ.inits.map(init => convertType(init.tpe)).toSeq,
      "members" -> members,
      "typeIsSealed" -> trt.mods.exists(_.is[Mod.Sealed]),
      "typeIsPrivate" -> trt.mods.exists(_.is[Mod.Private]),
      "typeIsProtected" -> trt.mods.exists(_.is[Mod.Protected])
    )
  }

  private def convertObject(obj: Defn.Object): Map[String, Any] = {
    incrementStat("ObjectDecl")

    val members = obj.templ.stats.map(_.map(convertMember).toSeq).getOrElse(Seq.empty)

    Map(
      "kind" -> "xnkClassDecl",
      "typeNameDecl" -> obj.name.value,
      "isSingleton" -> true,
      "baseTypes" -> obj.templ.inits.map(init => convertType(init.tpe)).toSeq,
      "members" -> members,
      "typeIsPrivate" -> obj.mods.exists(_.is[Mod.Private]),
      "typeIsProtected" -> obj.mods.exists(_.is[Mod.Protected])
    )
  }

  private def convertMember(stat: Stat): Map[String, Any] = stat match {
    case defn: Defn.Def => convertMethodDecl(defn)
    case value: Defn.Val => convertFieldDecl(value, isMutable = false)
    case variable: Defn.Var => convertFieldDecl(variable, isMutable = true)
    case cls: Defn.Class => convertClass(cls)
    case trt: Defn.Trait => convertTrait(trt)
    case obj: Defn.Object => convertObject(obj)
    case typeAlias: Defn.Type => convertTypeAlias(typeAlias)
    case _ =>
      incrementStat("UnknownMember")
      Map("kind" -> "xnkUnknown", "unknownData" -> stat.syntax)
  }

  private def convertMethodDecl(defn: Defn.Def): Map[String, Any] = {
    incrementStat("MethodDecl")

    Map(
      "kind" -> "xnkMethodDecl",
      "methodName" -> defn.name.value,
      "typeParams" -> defn.tparams.map(convertTypeParam).toSeq,
      "mparams" -> defn.paramss.map(params => params.map(convertParameter).toSeq).toSeq,
      "mreturnType" -> defn.decltpe.map(convertType).getOrElse(Map("kind" -> "xnkNamedType", "typeName" -> "Unit")),
      "mbody" -> convertTerm(defn.body),
      "methodIsPrivate" -> defn.mods.exists(_.is[Mod.Private]),
      "methodIsProtected" -> defn.mods.exists(_.is[Mod.Protected]),
      "methodIsFinal" -> defn.mods.exists(_.is[Mod.Final]),
      "methodIsOverride" -> defn.mods.exists(_.is[Mod.Override]),
      "methodIsImplicit" -> defn.mods.exists(_.is[Mod.Implicit]),
      "methodIsAbstract" -> false
    )
  }

  private def convertDef(defn: Defn.Def): Map[String, Any] = {
    incrementStat("FuncDecl")

    Map(
      "kind" -> "xnkFuncDecl",
      "funcName" -> defn.name.value,
      "typeParams" -> defn.tparams.map(convertTypeParam).toSeq,
      "fparams" -> defn.paramss.map(params => params.map(convertParameter).toSeq).toSeq,
      "freturnType" -> defn.decltpe.map(convertType).getOrElse(Map("kind" -> "xnkNamedType", "typeName" -> "Unit")),
      "fbody" -> convertTerm(defn.body)
    )
  }

  private def convertFieldDecl(stat: Stat, isMutable: Boolean): Map[String, Any] = {
    incrementStat("FieldDecl")

    stat match {
      case Defn.Val(mods, pats, decltpe, rhs) =>
        val name = pats.headOption.map(_.syntax).getOrElse("_")
        Map(
          "kind" -> "xnkFieldDecl",
          "fieldName" -> name,
          "fieldType" -> decltpe.map(convertType).getOrElse(Map("kind" -> "xnkNamedType", "typeName" -> "Any")),
          "fieldInitializer" -> convertTerm(rhs),
          "fieldIsMutable" -> false,
          "fieldIsPrivate" -> mods.exists(_.is[Mod.Private]),
          "fieldIsProtected" -> mods.exists(_.is[Mod.Protected]),
          "fieldIsFinal" -> true
        )
      case Defn.Var(mods, pats, decltpe, rhs) =>
        val name = pats.headOption.map(_.syntax).getOrElse("_")
        Map(
          "kind" -> "xnkFieldDecl",
          "fieldName" -> name,
          "fieldType" -> decltpe.map(convertType).getOrElse(Map("kind" -> "xnkNamedType", "typeName" -> "Any")),
          "fieldInitializer" -> rhs.map(convertTerm).orNull,
          "fieldIsMutable" -> true,
          "fieldIsPrivate" -> mods.exists(_.is[Mod.Private]),
          "fieldIsProtected" -> mods.exists(_.is[Mod.Protected]),
          "fieldIsFinal" -> false
        )
      case _ =>
        Map("kind" -> "xnkUnknown")
    }
  }

  private def convertVal(value: Defn.Val): Map[String, Any] = {
    incrementStat("ValDecl")
    val name = value.pats.headOption.map(_.syntax).getOrElse("_")
    Map(
      "kind" -> "xnkVarDecl",
      "declName" -> name,
      "declType" -> value.decltpe.map(convertType).getOrElse(Map("kind" -> "xnkNamedType", "typeName" -> "Any")),
      "initializer" -> convertTerm(value.rhs),
      "isImmutable" -> true
    )
  }

  private def convertVar(variable: Defn.Var): Map[String, Any] = {
    incrementStat("VarDecl")
    val name = variable.pats.headOption.map(_.syntax).getOrElse("_")
    Map(
      "kind" -> "xnkVarDecl",
      "declName" -> name,
      "declType" -> variable.decltpe.map(convertType).getOrElse(Map("kind" -> "xnkNamedType", "typeName" -> "Any")),
      "initializer" -> variable.rhs.map(convertTerm).orNull,
      "isImmutable" -> false
    )
  }

  private def convertTypeAlias(typeAlias: Defn.Type): Map[String, Any] = {
    incrementStat("TypeAlias")
    Map(
      "kind" -> "xnkTypeAlias",
      "aliasName" -> typeAlias.name.value,
      "typeParams" -> typeAlias.tparams.map(convertTypeParam).toSeq,
      "aliasedType" -> convertType(typeAlias.body)
    )
  }

  private def convertParameter(param: Term.Param): Map[String, Any] = {
    Map(
      "kind" -> "xnkParameter",
      "paramName" -> param.name.value,
      "paramType" -> param.decltpe.map(convertType).getOrElse(Map("kind" -> "xnkNamedType", "typeName" -> "Any")),
      "defaultValue" -> param.default.map(convertTerm).orNull,
      "isByName" -> (param.decltpe match {
        case Some(Type.ByName(_)) => true
        case _ => false
      }),
      "isImplicit" -> param.mods.exists(_.is[Mod.Implicit])
    )
  }

  private def convertTypeParam(tparam: Type.Param): Map[String, Any] = {
    Map(
      "kind" -> "xnkGenericParameter",
      "genericParamName" -> tparam.name.value,
      "genericBounds" -> tparam.tbounds.map { bounds =>
        val b = mutable.ArrayBuffer[Map[String, Any]]()
        bounds.lo.foreach(lo => b += Map("kind" -> "lowerBound", "type" -> convertType(lo)))
        bounds.hi.foreach(hi => b += Map("kind" -> "upperBound", "type" -> convertType(hi)))
        b.toSeq
      }.getOrElse(Seq.empty),
      "variance" -> (tparam.mods.find {
        case _: Mod.Covariant => true
        case _: Mod.Contravariant => true
        case _ => false
      } match {
        case Some(_: Mod.Covariant) => "covariant"
        case Some(_: Mod.Contravariant) => "contravariant"
        case _ => "invariant"
      })
    )
  }

  private def convertType(tpe: Type): Map[String, Any] = tpe match {
    case Type.Name(value) =>
      Map("kind" -> "xnkNamedType", "typeName" -> value)

    case Type.Select(qual, name) =>
      Map("kind" -> "xnkNamedType", "typeName" -> s"${qual.syntax}.${name.value}")

    case Type.Apply(tpe, args) =>
      Map(
        "kind" -> "xnkNamedType",
        "typeName" -> tpe.syntax,
        "typeArgs" -> args.map(convertType).toSeq
      )

    case Type.Function(params, res) =>
      Map(
        "kind" -> "xnkFunctionType",
        "paramTypes" -> params.map(convertType).toSeq,
        "returnType" -> convertType(res)
      )

    case Type.Tuple(args) =>
      Map(
        "kind" -> "xnkTupleType",
        "elementTypes" -> args.map(convertType).toSeq
      )

    case Type.ByName(tpe) =>
      Map(
        "kind" -> "xnkByNameType",
        "underlyingType" -> convertType(tpe)
      )

    case Type.Repeated(tpe) =>
      Map(
        "kind" -> "xnkRepeatedType",
        "elementType" -> convertType(tpe)
      )

    case Type.Annotate(tpe, annots) =>
      Map(
        "kind" -> "xnkAnnotatedType",
        "underlyingType" -> convertType(tpe),
        "annotations" -> annots.map(a => Map("name" -> a.syntax)).toSeq
      )

    case _ =>
      Map("kind" -> "xnkNamedType", "typeName" -> tpe.syntax)
  }

  private def convertTerm(term: Term): Map[String, Any] = term match {
    case Term.Apply(fun, args) =>
      incrementStat("CallExpr")
      Map(
        "kind" -> "xnkCallExpr",
        "callee" -> convertTerm(fun),
        "args" -> args.map(convertTerm).toSeq
      )

    case Term.ApplyInfix(lhs, op, targs, args) =>
      incrementStat("BinaryExpr")
      Map(
        "kind" -> "xnkBinaryExpr",
        "binaryLeft" -> convertTerm(lhs),
        "binaryOp" -> binaryOpMap.getOrElse(op.value, op.value),
        "binaryRight" -> (if (args.length == 1) convertTerm(args.head) else Map("kind" -> "xnkUnknown"))
      )

    case Term.ApplyUnary(op, arg) =>
      incrementStat("UnaryExpr")
      Map(
        "kind" -> "xnkUnaryExpr",
        "unaryOp" -> unaryOpMap.getOrElse(op.value, op.value),
        "unaryOperand" -> convertTerm(arg)
      )

    case Term.Assign(lhs, rhs) =>
      incrementStat("Assign")
      Map(
        "kind" -> "xnkAsgn",
        "asgnLeft" -> convertTerm(lhs),
        "asgnRight" -> convertTerm(rhs)
      )

    case Term.If(cond, thenp, elsep) =>
      incrementStat("IfExpr")
      Map(
        "kind" -> "xnkIfStmt",
        "ifCondition" -> convertTerm(cond),
        "ifBody" -> convertTerm(thenp),
        "elifBranches" -> Seq.empty,
        "elseBody" -> convertTerm(elsep)
      )

    case Term.While(expr, body) =>
      incrementStat("WhileStmt")
      Map(
        "kind" -> "xnkWhileStmt",
        "whileCondition" -> convertTerm(expr),
        "whileBody" -> convertTerm(body)
      )

    case Term.Match(expr, cases) =>
      incrementStat("MatchExpr")
      Map(
        "kind" -> "xnkSwitchStmt",
        "switchExpr" -> convertTerm(expr),
        "switchCases" -> cases.map(convertCase).toSeq
      )

    case Term.Block(stats) =>
      incrementStat("BlockStmt")
      Map(
        "kind" -> "xnkBlockStmt",
        "blockBody" -> stats.map(convertTerm).toSeq
      )

    case Term.Return(expr) =>
      incrementStat("ReturnStmt")
      Map(
        "kind" -> "xnkReturnStmt",
        "returnExpr" -> convertTerm(expr)
      )

    case Term.Throw(expr) =>
      incrementStat("ThrowStmt")
      Map(
        "kind" -> "xnkThrowStmt",
        "throwExpr" -> convertTerm(expr)
      )

    case Term.Try(expr, catchp, finallyp) =>
      incrementStat("TryStmt")
      Map(
        "kind" -> "xnkTryStmt",
        "tryBody" -> convertTerm(expr),
        "catchClauses" -> catchp.map(convertCase).toSeq,
        "finallyBody" -> finallyp.map(convertTerm).orNull
      )

    case Term.Function(params, body) =>
      incrementStat("LambdaExpr")
      Map(
        "kind" -> "xnkLambdaExpr",
        "lambdaParams" -> params.map(convertParameter).toSeq,
        "lambdaBody" -> convertTerm(body)
      )

    case Term.Select(qual, name) =>
      incrementStat("MemberAccessExpr")
      Map(
        "kind" -> "xnkMemberAccessExpr",
        "memberExpr" -> convertTerm(qual),
        "memberName" -> name.value
      )

    case Term.New(init) =>
      incrementStat("NewExpr")
      Map(
        "kind" -> "xnkCallExpr",
        "isNewExpr" -> true,
        "callee" -> convertType(init.tpe),
        "args" -> init.argss.flatten.map(convertTerm).toSeq
      )

    case Term.This(qual) =>
      incrementStat("ThisExpr")
      Map(
        "kind" -> "xnkThisExpr",
        "thisType" -> qual.syntax
      )

    case Term.Super(thisp, superp) =>
      incrementStat("SuperExpr")
      Map(
        "kind" -> "xnkBaseExpr",
        "baseType" -> superp.syntax
      )

    case Term.Name(value) =>
      incrementStat("Identifier")
      Map(
        "kind" -> "xnkIdentifier",
        "identName" -> value
      )

    case Lit.Int(value) =>
      incrementStat("IntLit")
      Map("kind" -> "xnkIntLit", "literalValue" -> value.toString)

    case Lit.Long(value) =>
      incrementStat("LongLit")
      Map("kind" -> "xnkIntLit", "literalValue" -> value.toString)

    case Lit.Double(value) =>
      incrementStat("DoubleLit")
      Map("kind" -> "xnkFloatLit", "literalValue" -> value.toString)

    case Lit.Float(value) =>
      incrementStat("FloatLit")
      Map("kind" -> "xnkFloatLit", "literalValue" -> value.toString)

    case Lit.String(value) =>
      incrementStat("StringLit")
      Map("kind" -> "xnkStringLit", "literalValue" -> value)

    case Lit.Char(value) =>
      incrementStat("CharLit")
      Map("kind" -> "xnkCharLit", "literalValue" -> value.toString)

    case Lit.Boolean(value) =>
      incrementStat("BoolLit")
      Map("kind" -> "xnkBoolLit", "boolValue" -> value)

    case Lit.Null() =>
      incrementStat("NullLit")
      Map("kind" -> "xnkNilLit")

    case Lit.Unit() =>
      incrementStat("UnitLit")
      Map("kind" -> "xnkUnitLit")

    case Term.For(enums, body) =>
      incrementStat("ForComprehension")
      Map(
        "kind" -> "xnkExternal_ForComprehension",
        "extForEnumerators" -> enums.map(convertEnumerator).toSeq,
        "extForBody" -> convertTerm(body)
      )

    case _ =>
      incrementStat("UnknownTerm")
      Map("kind" -> "xnkUnknown", "unknownData" -> term.syntax)
  }

  private def convertCase(cas: Case): Map[String, Any] = {
    Map(
      "kind" -> "xnkCaseClause",
      "casePattern" -> convertPattern(cas.pat),
      "caseGuard" -> cas.cond.map(convertTerm).orNull,
      "caseBody" -> convertTerm(cas.body)
    )
  }

  private def convertPattern(pat: Pat): Map[String, Any] = pat match {
    case Pat.Var(name) =>
      Map("kind" -> "xnkIdentifier", "identName" -> name.value)

    case Pat.Wildcard() =>
      Map("kind" -> "xnkWildcardPattern")

    case Pat.Bind(lhs, rhs) =>
      Map(
        "kind" -> "xnkBindPattern",
        "bindName" -> lhs.syntax,
        "bindPattern" -> convertPattern(rhs)
      )

    case Pat.Extract(fun, args) =>
      Map(
        "kind" -> "xnkExtractorPattern",
        "extractorName" -> fun.syntax,
        "extractorArgs" -> args.map(convertPattern).toSeq
      )

    case _ =>
      Map("kind" -> "xnkPattern", "patternSyntax" -> pat.syntax)
  }

  private def convertEnumerator(enumerator: Enumerator): Map[String, Any] = enumerator match {
    case Enumerator.Generator(pat, rhs) =>
      Map(
        "kind" -> "xnkGenerator",
        "generatorPattern" -> convertPattern(pat),
        "generatorExpr" -> convertTerm(rhs)
      )

    case Enumerator.Guard(cond) =>
      Map(
        "kind" -> "xnkGuard",
        "guardCondition" -> convertTerm(cond)
      )

    case Enumerator.Val(pat, rhs) =>
      Map(
        "kind" -> "xnkValDef",
        "valPattern" -> convertPattern(pat),
        "valExpr" -> convertTerm(rhs)
      )

    case _ =>
      Map("kind" -> "xnkUnknown")
  }
}
