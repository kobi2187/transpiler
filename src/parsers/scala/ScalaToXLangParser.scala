import scala.meta._
import scala.meta.parsers.Parsed
import scala.io.Source
import java.io.{File, PrintWriter}
import java.nio.file.{Files, Paths}
import scala.collection.mutable

/**
 * Comprehensive Scala to XLang Parser
 * Converts Scala source code to XLang intermediate representation JSON.
 * Compliant with XLang type specification (xlangtypes.nim).
 *
 * Fixed issues:
 * - Binary/unary operators use enum variant names (opAdd, opNegate, etc.)
 * - Generic types use xnkGenericType with genericArgs field
 * - Function types use xnkFuncType with correct field names
 * - Tuple types use tupleTypeElements field
 * - Case clauses use caseValues array and caseFallthrough
 * - Parameter lists are flattened
 * - Removed custom fields (thisType, typeParams from class, etc.)
 * - Class declarations properly structure constructor and type params in members
 */
object ScalaToXLangParser {

  private val statistics = mutable.Map[String, Int]()
  private var successCount = 0
  private var failCount = 0
  private val failedFiles = mutable.ArrayBuffer[String]()

  // Binary operator mapping: Scala syntax -> XLang BinaryOp enum variant
  private val binaryOpMap = Map(
    // Arithmetic
    "+" -> "opAdd",
    "-" -> "opSub",
    "*" -> "opMul",
    "/" -> "opDiv",
    "%" -> "opMod",

    // Bitwise
    "&" -> "opBitAnd",
    "|" -> "opBitOr",
    "^" -> "opBitXor",
    "<<" -> "opShiftLeft",
    ">>" -> "opShiftRight",
    ">>>" -> "opShiftRightUnsigned",

    // Comparison
    "==" -> "opEqual",
    "!=" -> "opNotEqual",
    "<" -> "opLess",
    "<=" -> "opLessEqual",
    ">" -> "opGreater",
    ">=" -> "opGreaterEqual",

    // Logical
    "&&" -> "opLogicalAnd",
    "||" -> "opLogicalOr",

    // Compound assignment
    "+=" -> "opAddAssign",
    "-=" -> "opSubAssign",
    "*=" -> "opMulAssign",
    "/=" -> "opDivAssign",
    "%=" -> "opModAssign",
    "&=" -> "opBitAndAssign",
    "|=" -> "opBitOrAssign",
    "^=" -> "opBitXorAssign",
    "<<=" -> "opShiftLeftAssign",
    ">>=" -> "opShiftRightAssign",
    ">>>=" -> "opShiftRightUnsignedAssign"
  )

  // Unary operator mapping: Scala syntax -> XLang UnaryOp enum variant
  private val unaryOpMap = Map(
    "-" -> "opNegate",
    "+" -> "opUnaryPlus",
    "!" -> "opNot",
    "~" -> "opBitNot"
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
          "importPath" -> importer.ref.syntax
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

    val members = mutable.ArrayBuffer[Map[String, Any]]()

    // Add constructor if class has parameters
    if (cls.ctor.paramss.nonEmpty && cls.ctor.paramss.exists(_.nonEmpty)) {
      members += Map(
        "kind" -> "xnkConstructorDecl",
        "constructorParams" -> cls.ctor.paramss.flatten.map(convertParameter).toSeq,
        "constructorInitializers" -> Seq.empty[Map[String, Any]],
        "constructorBody" -> Map(
          "kind" -> "xnkBlockStmt",
          "blockBody" -> Seq.empty[Map[String, Any]]
        ),
        "constructorIsPrivate" -> cls.mods.exists(_.is[Mod.Private]),
        "constructorIsProtected" -> cls.mods.exists(_.is[Mod.Protected]),
        "constructorIsPublic" -> !cls.mods.exists(_.is[Mod.Private]) && !cls.mods.exists(_.is[Mod.Protected])
      )
    }

    // Add other members
    members ++= cls.templ.stats.map(_.map(convertMember).toSeq).getOrElse(Seq.empty)

    Map(
      "kind" -> "xnkClassDecl",
      "typeNameDecl" -> cls.name.value,
      "baseTypes" -> cls.templ.inits.map(init => convertType(init.tpe)).toSeq,
      "members" -> members.toSeq,
      "typeIsStatic" -> false,  // Scala has no static classes
      "typeIsFinal" -> cls.mods.exists(_.is[Mod.Final]),
      "typeIsAbstract" -> cls.mods.exists(_.is[Mod.Abstract]),
      "typeIsPrivate" -> cls.mods.exists(_.is[Mod.Private]),
      "typeIsProtected" -> cls.mods.exists(_.is[Mod.Protected]),
      "typeIsPublic" -> !cls.mods.exists(_.is[Mod.Private]) && !cls.mods.exists(_.is[Mod.Protected])
    )
  }

  private def convertTrait(trt: Defn.Trait): Map[String, Any] = {
    incrementStat("TraitDecl")

    val members = trt.templ.stats.map(_.map(convertMember).toSeq).getOrElse(Seq.empty)

    Map(
      "kind" -> "xnkInterfaceDecl",
      "typeNameDecl" -> trt.name.value,
      "baseTypes" -> trt.templ.inits.map(init => convertType(init.tpe)).toSeq,
      "members" -> members,
      "typeIsStatic" -> false,
      "typeIsFinal" -> false,  // Traits can't be final
      "typeIsAbstract" -> true,  // Traits are always abstract
      "typeIsPrivate" -> trt.mods.exists(_.is[Mod.Private]),
      "typeIsProtected" -> trt.mods.exists(_.is[Mod.Protected]),
      "typeIsPublic" -> !trt.mods.exists(_.is[Mod.Private]) && !trt.mods.exists(_.is[Mod.Protected])
    )
  }

  private def convertObject(obj: Defn.Object): Map[String, Any] = {
    incrementStat("ObjectDecl")

    val members = obj.templ.stats.map(_.map(convertMember).toSeq).getOrElse(Seq.empty)

    // Objects are singleton instances - mark as static class
    Map(
      "kind" -> "xnkClassDecl",
      "typeNameDecl" -> obj.name.value,
      "baseTypes" -> obj.templ.inits.map(init => convertType(init.tpe)).toSeq,
      "members" -> members,
      "typeIsStatic" -> true,  // Objects are like static classes
      "typeIsFinal" -> true,   // Objects are implicitly final
      "typeIsAbstract" -> false,
      "typeIsPrivate" -> obj.mods.exists(_.is[Mod.Private]),
      "typeIsProtected" -> obj.mods.exists(_.is[Mod.Protected]),
      "typeIsPublic" -> !obj.mods.exists(_.is[Mod.Private]) && !obj.mods.exists(_.is[Mod.Protected])
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

    // Flatten parameter lists (Scala allows multiple parameter lists)
    val flattenedParams = defn.paramss.flatten.map(convertParameter).toSeq

    // Check for abstract method (no body)
    val hasBody = defn.body match {
      case _: Term.Name if defn.body.toString == "???" => false
      case _ => true
    }

    val bodyNode = if (hasBody) {
      convertTerm(defn.body)
    } else {
      Map(
        "kind" -> "xnkBlockStmt",
        "blockBody" -> Seq.empty[Map[String, Any]]
      )
    }

    Map(
      "kind" -> "xnkMethodDecl",
      "receiver" -> None,  // Scala doesn't have extension methods like C#
      "methodName" -> defn.name.value,
      "mparams" -> flattenedParams,
      "mreturnType" -> defn.decltpe.map(convertType),
      "mbody" -> bodyNode,
      "methodIsAsync" -> false,  // Scala uses Future, not async/await
      "methodIsStatic" -> false,  // Instance methods; object methods handled via static class
      "methodIsAbstract" -> !hasBody,
      "methodIsFinal" -> defn.mods.exists(_.is[Mod.Final]),
      "methodIsPrivate" -> defn.mods.exists(_.is[Mod.Private]),
      "methodIsProtected" -> defn.mods.exists(_.is[Mod.Protected]),
      "methodIsPublic" -> !defn.mods.exists(_.is[Mod.Private]) && !defn.mods.exists(_.is[Mod.Protected])
    )
  }

  private def convertDef(defn: Defn.Def): Map[String, Any] = {
    incrementStat("FuncDecl")

    // Flatten parameter lists
    val flattenedParams = defn.paramss.flatten.map(convertParameter).toSeq

    Map(
      "kind" -> "xnkFuncDecl",
      "funcName" -> defn.name.value,
      "params" -> flattenedParams,
      "returnType" -> defn.decltpe.map(convertType),
      "body" -> convertTerm(defn.body),
      "isAsync" -> false,
      "funcIsStatic" -> false,
      "funcVisibility" -> (if (defn.mods.exists(_.is[Mod.Private])) "private" else "public")
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
          "fieldInitializer" -> Some(convertTerm(rhs)),
          "fieldIsStatic" -> false,
          "fieldIsFinal" -> true,  // val is immutable
          "fieldIsVolatile" -> false,
          "fieldIsTransient" -> false,
          "fieldIsPrivate" -> mods.exists(_.is[Mod.Private]),
          "fieldIsProtected" -> mods.exists(_.is[Mod.Protected]),
          "fieldIsPublic" -> !mods.exists(_.is[Mod.Private]) && !mods.exists(_.is[Mod.Protected])
        )
      case Defn.Var(mods, pats, decltpe, rhs) =>
        val name = pats.headOption.map(_.syntax).getOrElse("_")
        Map(
          "kind" -> "xnkFieldDecl",
          "fieldName" -> name,
          "fieldType" -> decltpe.map(convertType).getOrElse(Map("kind" -> "xnkNamedType", "typeName" -> "Any")),
          "fieldInitializer" -> rhs.map(convertTerm),
          "fieldIsStatic" -> false,
          "fieldIsFinal" -> false,  // var is mutable
          "fieldIsVolatile" -> false,
          "fieldIsTransient" -> false,
          "fieldIsPrivate" -> mods.exists(_.is[Mod.Private]),
          "fieldIsProtected" -> mods.exists(_.is[Mod.Protected]),
          "fieldIsPublic" -> !mods.exists(_.is[Mod.Private]) && !mods.exists(_.is[Mod.Protected])
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
      "declType" -> value.decltpe.map(convertType),
      "initializer" -> Some(convertTerm(value.rhs))
    )
  }

  private def convertVar(variable: Defn.Var): Map[String, Any] = {
    incrementStat("VarDecl")
    val name = variable.pats.headOption.map(_.syntax).getOrElse("_")
    Map(
      "kind" -> "xnkVarDecl",
      "declName" -> name,
      "declType" -> variable.decltpe.map(convertType),
      "initializer" -> variable.rhs.map(convertTerm)
    )
  }

  private def convertTypeAlias(typeAlias: Defn.Type): Map[String, Any] = {
    incrementStat("TypeAlias")
    Map(
      "kind" -> "xnkTypeAlias",
      "aliasName" -> typeAlias.name.value,
      "aliasTarget" -> convertType(typeAlias.body)
    )
  }

  private def convertParameter(param: Term.Param): Map[String, Any] = {
    Map(
      "kind" -> "xnkParameter",
      "paramName" -> param.name.value,
      "paramType" -> param.decltpe.map(convertType),
      "defaultValue" -> param.default.map(convertTerm)
    )
  }

  private def convertType(tpe: Type): Map[String, Any] = tpe match {
    case Type.Name(value) =>
      Map("kind" -> "xnkNamedType", "typeName" -> value)

    case Type.Select(qual, name) =>
      Map("kind" -> "xnkNamedType", "typeName" -> s"${qual.syntax}.${name.value}")

    case Type.Apply(tpe, args) =>
      // Generic type: List[Int], Map[String, Int], etc.
      Map(
        "kind" -> "xnkGenericType",
        "genericTypeName" -> tpe.syntax,
        "genericBase" -> None,
        "genericArgs" -> args.map(convertType).toSeq
      )

    case Type.Function(params, res) =>
      // Function type: (Int, String) => Boolean
      Map(
        "kind" -> "xnkFuncType",
        "funcParams" -> params.map(convertType).toSeq,
        "funcReturnType" -> Some(convertType(res))
      )

    case Type.Tuple(args) =>
      // Tuple type: (Int, String, Boolean)
      Map(
        "kind" -> "xnkTupleType",
        "tupleTypeElements" -> args.map(arg => Map(
          "kind" -> "xnkParameter",
          "paramName" -> "",
          "paramType" -> Some(convertType(arg)),
          "defaultValue" -> None
        )).toSeq
      )

    case Type.ByName(tpe) =>
      // By-name parameter: => Int
      // Wrap in function type with no parameters
      Map(
        "kind" -> "xnkFuncType",
        "funcParams" -> Seq.empty[Map[String, Any]],
        "funcReturnType" -> Some(convertType(tpe))
      )

    case Type.Repeated(tpe) =>
      // Variadic parameter: Int*
      // Represent as array type
      Map(
        "kind" -> "xnkArrayType",
        "elementType" -> convertType(tpe),
        "arraySize" -> None
      )

    case Type.Annotate(tpe, annots) =>
      // Just use underlying type, ignore annotations for now
      convertType(tpe)

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
        "binaryOp" -> binaryOpMap.getOrElse(op.value, op.value),  // Use enum variant name
        "binaryRight" -> (if (args.length == 1) convertTerm(args.head) else Map("kind" -> "xnkUnknown"))
      )

    case Term.ApplyUnary(op, arg) =>
      incrementStat("UnaryExpr")
      Map(
        "kind" -> "xnkUnaryExpr",
        "unaryOp" -> unaryOpMap.getOrElse(op.value, op.value),  // Use enum variant name
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
        "elifBranches" -> Seq.empty[Map[String, Any]],
        "elseBody" -> Some(convertTerm(elsep))
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
        "returnExpr" -> Some(convertTerm(expr))
      )

    case Term.Throw(expr) =>
      incrementStat("ThrowStmt")
      Map(
        "kind" -> "xnkThrowStmt",
        "throwExpr" -> convertTerm(expr)
      )

    case Term.Try(expr, catchp, finallyp) =>
      incrementStat("TryStmt")
      // Convert catch cases to catch clauses
      val catchClauses = catchp.map { cas =>
        // Extract type and variable from pattern
        val (catchType, catchVar) = cas.pat match {
          case Pat.Typed(Pat.Var(name), tpe) =>
            (Some(convertType(tpe)), Some(name.value))
          case Pat.Var(name) =>
            (Some(Map("kind" -> "xnkNamedType", "typeName" -> "Throwable")), Some(name.value))
          case Pat.Wildcard() =>
            (Some(Map("kind" -> "xnkNamedType", "typeName" -> "Throwable")), None)
          case _ =>
            (None, None)
        }

        Map(
          "kind" -> "xnkCatchStmt",
          "catchType" -> catchType,
          "catchVar" -> catchVar,
          "catchBody" -> convertTerm(cas.body)
        )
      }

      Map(
        "kind" -> "xnkTryStmt",
        "tryBody" -> convertTerm(expr),
        "catchClauses" -> catchClauses.toSeq,
        "finallyClause" -> finallyp.map(f => Map(
          "kind" -> "xnkFinallyStmt",
          "finallyBody" -> convertTerm(f)
        ))
      )

    case Term.Function(params, body) =>
      incrementStat("LambdaExpr")
      Map(
        "kind" -> "xnkLambdaExpr",
        "lambdaParams" -> params.map(convertParameter).toSeq,
        "lambdaReturnType" -> None,
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
        "callee" -> convertType(init.tpe),
        "args" -> init.argss.flatten.map(convertTerm).toSeq
      )

    case Term.This(qual) =>
      incrementStat("ThisExpr")
      // xnkThisExpr has no fields
      Map("kind" -> "xnkThisExpr")

    case Term.Super(thisp, superp) =>
      incrementStat("SuperExpr")
      // xnkBaseExpr has no fields
      Map("kind" -> "xnkBaseExpr")

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
      // Use empty block to represent Unit literal
      Map("kind" -> "xnkBlockStmt", "blockBody" -> Seq.empty[Map[String, Any]])

    case Term.For(enums, body) =>
      incrementStat("ForComprehension")
      // For comprehensions need special external node
      Map(
        "kind" -> "xnkExternal_ScalaForComp",
        "scalaForEnums" -> enums.map(convertEnumerator).toSeq,
        "scalaForBody" -> convertTerm(body)
      )

    case _ =>
      incrementStat("UnknownTerm")
      Map("kind" -> "xnkUnknown", "unknownData" -> term.syntax)
  }

  private def convertCase(cas: Case): Map[String, Any] = {
    // Handle pattern guards by embedding in body as if statement
    val bodyWithGuard = cas.cond match {
      case Some(guardCond) =>
        // Guard present: wrap body in if statement
        Map(
          "kind" -> "xnkIfStmt",
          "ifCondition" -> convertTerm(guardCond),
          "ifBody" -> convertTerm(cas.body),
          "elifBranches" -> Seq.empty[Map[String, Any]],
          "elseBody" -> None
        )
      case None =>
        convertTerm(cas.body)
    }

    Map(
      "kind" -> "xnkCaseClause",
      "caseValues" -> Seq(convertPattern(cas.pat)),  // Array of patterns
      "caseBody" -> bodyWithGuard,
      "caseFallthrough" -> false  // Scala never falls through
    )
  }

  private def convertPattern(pat: Pat): Map[String, Any] = pat match {
    case Pat.Var(name) =>
      Map("kind" -> "xnkIdentifier", "identName" -> name.value)

    case Pat.Wildcard() =>
      Map("kind" -> "xnkIdentifier", "identName" -> "_")

    case Pat.Typed(pat, tpe) =>
      // Type pattern: case x: Int =>
      Map(
        "kind" -> "xnkTypeAssertion",
        "assertExpr" -> convertPattern(pat),
        "assertType" -> convertType(tpe)
      )

    case Pat.Bind(lhs, rhs) =>
      // Bind pattern: case x @ Some(y) =>
      // Convert to pattern with binding
      convertPattern(rhs)

    case Pat.Extract(fun, args) =>
      // Extractor pattern: case Point(x, y) =>
      // Convert to type check and field extraction
      Map(
        "kind" -> "xnkCallExpr",
        "callee" -> Map("kind" -> "xnkIdentifier", "identName" -> fun.syntax),
        "args" -> args.map(convertPattern).toSeq
      )

    case Lit.Int(value) =>
      Map("kind" -> "xnkIntLit", "literalValue" -> value.toString)

    case Lit.String(value) =>
      Map("kind" -> "xnkStringLit", "literalValue" -> value)

    case _ =>
      Map("kind" -> "xnkIdentifier", "identName" -> pat.syntax)
  }

  private def convertEnumerator(enumerator: Enumerator): Map[String, Any] = enumerator match {
    case Enumerator.Generator(pat, rhs) =>
      Map(
        "kind" -> "xnkScalaGenerator",
        "generatorPattern" -> convertPattern(pat),
        "generatorExpr" -> convertTerm(rhs)
      )

    case Enumerator.Guard(cond) =>
      Map(
        "kind" -> "xnkScalaGuard",
        "guardCondition" -> convertTerm(cond)
      )

    case Enumerator.Val(pat, rhs) =>
      Map(
        "kind" -> "xnkScalaValDef",
        "valPattern" -> convertPattern(pat),
        "valExpr" -> convertTerm(rhs)
      )

    case _ =>
      Map("kind" -> "xnkUnknown")
  }
}
