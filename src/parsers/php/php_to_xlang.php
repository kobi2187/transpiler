#!/usr/bin/env php
<?php
/**
 * PHP to XLang JSON Transpiler
 *
 * Parses PHP 8.4 source files using nikic/PHP-Parser and produces
 * XLang JSON (.xljs) intermediate representation.
 *
 * Usage:
 *   php php_to_xlang.php <file.php>        - Parse single file, output to stdout
 *   php php_to_xlang.php <directory>        - Batch process directory, write .xljs files
 */

require __DIR__ . '/vendor/autoload.php';

use PhpParser\Error;
use PhpParser\Node;
use PhpParser\Node\Stmt;
use PhpParser\Node\Expr;
use PhpParser\Node\Scalar;
use PhpParser\Node\Name;
use PhpParser\ParserFactory;
use PhpParser\NodeDumper;

// ---------------------------------------------------------------------------
// Global tracking for unknown/missing constructs
// ---------------------------------------------------------------------------
$constructStats  = [];
$constructErrors = [];
$errorLog        = [];
$currentFilePath = '';

function trackUnknown(string $context, Node $node): array
{
    global $constructStats, $constructErrors, $currentFilePath;

    $nodeType = $node->getType();
    $key      = "$context:$nodeType";

    $constructStats[$key] = ($constructStats[$key] ?? 0) + 1;

    if (!isset($constructErrors[$key])) {
        $constructErrors[$key] = [];
    }
    if (count($constructErrors[$key]) < 10) {
        $prettyPrinter          = new PhpParser\PrettyPrinter\Standard();
        $source                 = $prettyPrinter->prettyPrint([$node]);
        $constructErrors[$key][] = [
            'file'   => $currentFilePath,
            'line'   => $node->getStartLine(),
            'source' => mb_substr($source, 0, 200),
        ];
    }

    return [
        'kind'        => 'xnkUnknown',
        'unknownData' => mb_substr("$context:$nodeType", 0, 100),
    ];
}

// ---------------------------------------------------------------------------
// Main entry point
// ---------------------------------------------------------------------------
function main(array $argv): void
{
    if (count($argv) < 2) {
        fwrite(STDERR, "Usage:\n");
        fwrite(STDERR, "  Single file: php php_to_xlang.php <file.php>\n");
        fwrite(STDERR, "  Directory:   php php_to_xlang.php <directory>\n");
        exit(1);
    }

    $path = $argv[1];

    if (is_dir($path)) {
        batchProcessDirectory($path);
    } elseif (is_file($path)) {
        processSingleFile($path, outputToConsole: true);
    } else {
        fwrite(STDERR, "Error: Path not found: $path\n");
        exit(1);
    }
}

function batchProcessDirectory(string $dir): void
{
    global $constructStats, $constructErrors, $errorLog;

    $files        = glob("$dir/**/*.php") ?: [];
    // Also get files in the root
    $rootFiles    = glob("$dir/*.php") ?: [];
    $files        = array_unique(array_merge($rootFiles, $files));
    // Use recursive iterator for deep nesting
    $iter         = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($dir, RecursiveDirectoryIterator::SKIP_DOTS)
    );
    $files = [];
    foreach ($iter as $file) {
        if ($file->isFile() && $file->getExtension() === 'php') {
            $files[] = $file->getPathname();
        }
    }

    echo "Found " . count($files) . " PHP files to process in: $dir\n\n";

    $successCount = 0;
    $errorCount   = 0;

    foreach ($files as $phpFile) {
        try {
            echo "Processing: $phpFile\n";
            processSingleFile($phpFile, outputToConsole: false);
            $successCount++;
        } catch (\Throwable $e) {
            $errorCount++;
            $msg       = "Error processing $phpFile: " . $e->getMessage();
            $errorLog[] = $msg;
            fwrite(STDERR, "$msg\n");
        }
    }

    echo "\n=== BATCH PROCESSING SUMMARY ===\n";
    echo "Total files: " . count($files) . "\n";
    echo "Successfully processed: $successCount\n";
    echo "Errors: $errorCount\n\n";

    if (!empty($constructStats)) {
        arsort($constructStats);
        echo "=== MISSING/UNKNOWN CONSTRUCTS ===\n";
        foreach ($constructStats as $key => $count) {
            echo "$key: $count occurrences\n";
        }
        echo "\n=== DETAILED ERROR SAMPLES ===\n";
        $i = 0;
        foreach ($constructStats as $key => $count) {
            if (++$i > 10) break;
            echo "\n--- $key ($count total occurrences) ---\n";
            if (isset($constructErrors[$key])) {
                $sampleNum = 1;
                foreach (array_slice($constructErrors[$key], 0, 3) as $err) {
                    echo "\nSample #$sampleNum:\n";
                    echo "  File: {$err['file']}:{$err['line']}\n";
                    echo "  Source:\n";
                    foreach (explode("\n", $err['source']) as $line) {
                        echo "    $line\n";
                    }
                    $sampleNum++;
                }
            }
        }
        echo "\n";
    }

    if (!empty($errorLog)) {
        echo "=== ERROR LOG ===\n";
        foreach ($errorLog as $e) {
            echo "$e\n";
        }
    }
}

function processSingleFile(string $filePath, bool $outputToConsole): void
{
    global $currentFilePath;
    $currentFilePath = $filePath;

    $sourceCode = file_get_contents($filePath);
    $parser     = (new ParserFactory())->createForNewestSupportedVersion();

    try {
        $ast = $parser->parse($sourceCode);
    } catch (Error $error) {
        throw new \RuntimeException("Parse error in $filePath: " . $error->getMessage());
    }

    if ($ast === null) {
        throw new \RuntimeException("Parser returned null for $filePath");
    }

    $xlangNode = convertFile($ast, $filePath);
    $json      = json_encode($xlangNode, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

    if ($outputToConsole) {
        echo $json . "\n";
    } else {
        $outputPath = preg_replace('/\.php$/', '.xljs', $filePath);
        file_put_contents($outputPath, $json);
        echo "  -> Written to: $outputPath\n";
    }
}

// ===========================================================================
// Top-level file conversion
// ===========================================================================
function convertFile(array $stmts, string $fileName): array
{
    $moduleDecls = [];

    foreach ($stmts as $stmt) {
        // Extract doc comments
        $docComments = extractDocComments($stmt);
        foreach ($docComments as $c) {
            $moduleDecls[] = $c;
        }
        $converted = convertStmt($stmt);
        if ($converted !== null) {
            $moduleDecls[] = $converted;
        }
    }

    return [
        'kind'        => 'xnkFile',
        'fileName'    => basename($fileName),
        'sourceLang'  => 'php',
        'moduleDecls' => $moduleDecls,
    ];
}

// ===========================================================================
// Doc comment extraction
// ===========================================================================
function extractDocComments(Node $node): array
{
    $comments = [];
    $docComment = $node->getDocComment();
    if ($docComment !== null) {
        $text = $docComment->getText();
        // Clean up PHPDoc markers
        $text = preg_replace('#^/\*\*\s*#', '', $text);
        $text = preg_replace('#\s*\*/$#', '', $text);
        $lines = explode("\n", $text);
        $cleaned = [];
        foreach ($lines as $line) {
            $line = preg_replace('#^\s*\*\s?#', '', $line);
            $cleaned[] = $line;
        }
        $cleanedText = trim(implode("\n", $cleaned));
        if ($cleanedText !== '') {
            $comments[] = [
                'kind'         => 'xnkComment',
                'commentText'  => $cleanedText,
                'isDocComment' => true,
            ];
        }
    }
    return $comments;
}

// ===========================================================================
// Statement conversion
// ===========================================================================
function convertStmt(Node $node): ?array
{
    // Namespace
    if ($node instanceof Stmt\Namespace_) {
        return convertNamespace($node);
    }
    // Use/Import statements
    if ($node instanceof Stmt\Use_) {
        return convertUse($node);
    }
    if ($node instanceof Stmt\GroupUse) {
        return convertGroupUse($node);
    }
    // Class declarations
    if ($node instanceof Stmt\Class_) {
        return convertClass($node);
    }
    // Interface declarations
    if ($node instanceof Stmt\Interface_) {
        return convertInterface($node);
    }
    // Trait declarations
    if ($node instanceof Stmt\Trait_) {
        return convertTrait($node);
    }
    // Enum declarations (PHP 8.1+)
    if ($node instanceof Stmt\Enum_) {
        return convertEnum($node);
    }
    // Function declarations
    if ($node instanceof Stmt\Function_) {
        return convertFunction($node);
    }
    // Expression statement
    if ($node instanceof Stmt\Expression) {
        return convertExpr($node->expr);
    }
    // Return
    if ($node instanceof Stmt\Return_) {
        return [
            'kind'       => 'xnkReturnStmt',
            'returnExpr' => $node->expr !== null ? convertExpr($node->expr) : null,
        ];
    }
    // If
    if ($node instanceof Stmt\If_) {
        return convertIf($node);
    }
    // While
    if ($node instanceof Stmt\While_) {
        return [
            'kind'           => 'xnkWhileStmt',
            'whileCondition' => convertExpr($node->cond),
            'whileBody'      => convertBlock($node->stmts),
        ];
    }
    // Do-While
    if ($node instanceof Stmt\Do_) {
        return [
            'kind'               => 'xnkExternal_DoWhile',
            'extDoWhileCondition'=> convertExpr($node->cond),
            'extDoWhileBody'     => convertBlock($node->stmts),
        ];
    }
    // For (C-style)
    if ($node instanceof Stmt\For_) {
        return convertFor($node);
    }
    // Foreach
    if ($node instanceof Stmt\Foreach_) {
        return convertForeach($node);
    }
    // Switch
    if ($node instanceof Stmt\Switch_) {
        return convertSwitch($node);
    }
    // Try/Catch/Finally
    if ($node instanceof Stmt\TryCatch) {
        return convertTryCatch($node);
    }
    // Throw
    if ($node instanceof Stmt\Throw_) {
        return [
            'kind'      => 'xnkRaiseStmt',
            'raiseExpr' => convertExpr($node->expr),
        ];
    }
    // Break
    if ($node instanceof Stmt\Break_) {
        return ['kind' => 'xnkBreakStmt', 'label' => null];
    }
    // Continue
    if ($node instanceof Stmt\Continue_) {
        return ['kind' => 'xnkContinueStmt', 'label' => null];
    }
    // Echo
    if ($node instanceof Stmt\Echo_) {
        return convertEcho($node);
    }
    // Global variable declaration
    if ($node instanceof Stmt\Global_) {
        return convertGlobal($node);
    }
    // Static variable declaration
    if ($node instanceof Stmt\Static_) {
        return convertStaticVars($node);
    }
    // Unset
    if ($node instanceof Stmt\Unset_) {
        return convertUnset($node);
    }
    // Declare
    if ($node instanceof Stmt\Declare_) {
        return convertDeclare($node);
    }
    // Const (file-level)
    if ($node instanceof Stmt\Const_) {
        return convertFileConst($node);
    }
    // Label
    if ($node instanceof Stmt\Label) {
        return [
            'kind'        => 'xnkLabeledStmt',
            'labelName'   => $node->name->toString(),
            'labeledStmt' => ['kind' => 'xnkEmptyStmt'],
        ];
    }
    // Goto
    if ($node instanceof Stmt\Goto_) {
        return [
            'kind'      => 'xnkGotoStmt',
            'gotoLabel' => $node->name->toString(),
        ];
    }
    // Nop (empty statement / comments-only)
    if ($node instanceof Stmt\Nop) {
        return null;
    }
    // InlineHTML
    if ($node instanceof Stmt\InlineHTML) {
        return [
            'kind'        => 'xnkExternal_PhpInlineHtml',
            'extHtmlContent' => $node->value,
        ];
    }
    // HaltCompiler
    if ($node instanceof Stmt\HaltCompiler) {
        return [
            'kind'        => 'xnkExternal_PhpHaltCompiler',
            'extHaltData' => $node->remaining,
        ];
    }
    // Block (PHP 8.x)
    if ($node instanceof Stmt\Block) {
        return convertBlock($node->stmts);
    }
    // Trait use statement (inside class)
    if ($node instanceof Stmt\TraitUse) {
        return convertTraitUse($node);
    }
    // Class const
    if ($node instanceof Stmt\ClassConst) {
        return convertClassConst($node);
    }
    // Property declaration
    if ($node instanceof Stmt\Property) {
        return convertProperty($node);
    }
    // Class method
    if ($node instanceof Stmt\ClassMethod) {
        return convertClassMethod($node);
    }
    // Enum case
    if ($node instanceof Stmt\EnumCase) {
        return convertEnumCase($node);
    }

    return trackUnknown('statement', $node);
}

// ===========================================================================
// Namespace
// ===========================================================================
function convertNamespace(Stmt\Namespace_ $ns): array
{
    $body = [];
    foreach ($ns->stmts as $stmt) {
        $docComments = extractDocComments($stmt);
        foreach ($docComments as $c) {
            $body[] = $c;
        }
        $converted = convertStmt($stmt);
        if ($converted !== null) {
            $body[] = $converted;
        }
    }

    return [
        'kind'          => 'xnkNamespace',
        'namespaceName' => $ns->name !== null ? $ns->name->toString() : '',
        'namespaceBody' => $body,
    ];
}

// ===========================================================================
// Use/Import
// ===========================================================================
function convertUse(Stmt\Use_ $use): array
{
    // If single use, emit single import; if multiple, wrap in block
    if (count($use->uses) === 1) {
        $u = $use->uses[0];
        $import = [
            'kind'       => 'xnkImport',
            'importPath' => $u->name->toString(),
        ];
        if ($u->alias !== null) {
            $import['importAlias'] = $u->alias->toString();
        }
        return $import;
    }

    $imports = [];
    foreach ($use->uses as $u) {
        $import = [
            'kind'       => 'xnkImport',
            'importPath' => $u->name->toString(),
        ];
        if ($u->alias !== null) {
            $import['importAlias'] = $u->alias->toString();
        }
        $imports[] = $import;
    }
    return [
        'kind'      => 'xnkBlockStmt',
        'blockBody' => $imports,
    ];
}

function convertGroupUse(Stmt\GroupUse $groupUse): array
{
    $prefix  = $groupUse->prefix->toString();
    $imports = [];
    foreach ($groupUse->uses as $u) {
        $fullPath = $prefix . '\\' . $u->name->toString();
        $import   = [
            'kind'       => 'xnkImport',
            'importPath' => $fullPath,
        ];
        if ($u->alias !== null) {
            $import['importAlias'] = $u->alias->toString();
        }
        $imports[] = $import;
    }
    if (count($imports) === 1) {
        return $imports[0];
    }
    return [
        'kind'      => 'xnkBlockStmt',
        'blockBody' => $imports,
    ];
}

// ===========================================================================
// Class
// ===========================================================================
function convertClass(Stmt\Class_ $cls): array
{
    $members = [];
    foreach ($cls->stmts as $stmt) {
        $docComments = extractDocComments($stmt);
        foreach ($docComments as $c) {
            $members[] = $c;
        }
        $converted = convertStmt($stmt);
        if ($converted !== null) {
            $members[] = $converted;
        }
    }

    $baseTypes = [];
    if ($cls->extends !== null) {
        $baseTypes[] = convertNameNode($cls->extends);
    }
    foreach ($cls->implements as $iface) {
        $baseTypes[] = convertNameNode($iface);
    }

    return [
        'kind'           => 'xnkClassDecl',
        'typeNameDecl'   => $cls->name !== null ? $cls->name->toString() : '_anonymous_',
        'baseTypes'      => $baseTypes,
        'members'        => $members,
        'typeIsStatic'   => false,
        'typeIsFinal'    => (bool)($cls->flags & Stmt\Class_::MODIFIER_FINAL),
        'typeIsAbstract' => (bool)($cls->flags & Stmt\Class_::MODIFIER_ABSTRACT),
        'typeIsPrivate'  => false,
        'typeIsProtected'=> false,
        'typeIsPublic'   => true,
    ];
}

// ===========================================================================
// Interface
// ===========================================================================
function convertInterface(Stmt\Interface_ $iface): array
{
    $members = [];
    foreach ($iface->stmts as $stmt) {
        $docComments = extractDocComments($stmt);
        foreach ($docComments as $c) {
            $members[] = $c;
        }
        $converted = convertStmt($stmt);
        if ($converted !== null) {
            $members[] = $converted;
        }
    }

    $baseTypes = [];
    foreach ($iface->extends as $ext) {
        $baseTypes[] = convertNameNode($ext);
    }

    return [
        'kind'                  => 'xnkExternal_Interface',
        'extInterfaceName'      => $iface->name->toString(),
        'extInterfaceBaseTypes' => $baseTypes,
        'extInterfaceMembers'   => $members,
    ];
}

// ===========================================================================
// Trait (PHP-specific → External)
// ===========================================================================
function convertTrait(Stmt\Trait_ $trait): array
{
    $members = [];
    foreach ($trait->stmts as $stmt) {
        $docComments = extractDocComments($stmt);
        foreach ($docComments as $c) {
            $members[] = $c;
        }
        $converted = convertStmt($stmt);
        if ($converted !== null) {
            $members[] = $converted;
        }
    }

    return [
        'kind'              => 'xnkExternal_PhpTrait',
        'extTraitName'      => $trait->name->toString(),
        'extTraitMembers'   => $members,
    ];
}

// ===========================================================================
// Trait use (inside class)
// ===========================================================================
function convertTraitUse(Stmt\TraitUse $traitUse): array
{
    $traitNames = [];
    foreach ($traitUse->traits as $trait) {
        $traitNames[] = nameToString($trait);
    }

    $adaptations = [];
    foreach ($traitUse->adaptations as $adaptation) {
        if ($adaptation instanceof Stmt\TraitUseAdaptation\Precedence) {
            $insteadofStr = implode(', ', array_map(fn($n) => nameToString($n), $adaptation->insteadof));
            $traitStr = $adaptation->trait !== null ? nameToString($adaptation->trait) . '::' : '';
            $adaptations[] = [
                'kind'        => 'xnkComment',
                'commentText' => "precedence: {$traitStr}{$adaptation->method->toString()} insteadof {$insteadofStr}",
                'isDocComment'=> false,
            ];
        } elseif ($adaptation instanceof Stmt\TraitUseAdaptation\Alias) {
            $traitStr = $adaptation->trait !== null ? nameToString($adaptation->trait) . '::' : '';
            $newName = $adaptation->newName !== null ? $adaptation->newName->toString() : '';
            $adaptations[] = [
                'kind'        => 'xnkComment',
                'commentText' => "alias: {$traitStr}{$adaptation->method->toString()} as {$newName}",
                'isDocComment'=> false,
            ];
        }
    }

    return [
        'kind'                   => 'xnkExternal_PhpTraitUse',
        'extTraitUseNames'       => $traitNames,
        'extTraitUseAdaptations' => $adaptations,
    ];
}

// ===========================================================================
// Enum (PHP 8.1+ — maps to xnkEnumDecl)
// ===========================================================================
function convertEnum(Stmt\Enum_ $enum): array
{
    $members = [];
    foreach ($enum->stmts as $stmt) {
        $docComments = extractDocComments($stmt);
        foreach ($docComments as $c) {
            $members[] = $c;
        }
        $converted = convertStmt($stmt);
        if ($converted !== null) {
            $members[] = $converted;
        }
    }

    // Separate enum cases from other members (methods, consts)
    $enumMembers = [];
    $otherMembers = [];
    foreach ($members as $m) {
        if (($m['kind'] ?? '') === 'xnkEnumMember') {
            $enumMembers[] = $m;
        } else {
            $otherMembers[] = $m;
        }
    }

    $result = [
        'kind'          => 'xnkEnumDecl',
        'enumName'      => $enum->name->toString(),
        'enumMembers'   => $enumMembers,
        'enumIsPrivate' => false,
        'enumIsProtected'=> false,
        'enumIsPublic'  => true,
    ];

    // PHP enums can have a backing type (string or int)
    if ($enum->scalarType !== null) {
        $result['extEnumBackingType'] = convertTypeNode($enum->scalarType);
    }

    // PHP enums can implement interfaces
    if (!empty($enum->implements)) {
        $result['extEnumImplements'] = array_map(fn($n) => convertNameNode($n), $enum->implements);
    }

    // PHP enums can have methods and constants alongside cases
    if (!empty($otherMembers)) {
        $result['extEnumMethods'] = $otherMembers;
    }

    return $result;
}

function convertEnumCase(Stmt\EnumCase $case): array
{
    return [
        'kind'            => 'xnkEnumMember',
        'enumMemberName'  => $case->name->toString(),
        'enumMemberValue' => $case->expr !== null ? convertExpr($case->expr) : null,
    ];
}

// ===========================================================================
// Function declaration
// ===========================================================================
function convertFunction(Stmt\Function_ $func): array
{
    $params = [];
    foreach ($func->params as $param) {
        $params[] = convertParam($param);
    }

    return [
        'kind'           => 'xnkFuncDecl',
        'funcName'       => $func->name->toString(),
        'params'         => $params,
        'returnType'     => $func->returnType !== null ? convertTypeNode($func->returnType) : null,
        'body'           => convertBlock($func->stmts),
        'isAsync'        => false,
        'funcVisibility' => 'public',
        'funcIsStatic'   => false,
    ];
}

// ===========================================================================
// Class method
// ===========================================================================
function convertClassMethod(Stmt\ClassMethod $method): array
{
    $params = [];
    foreach ($method->params as $param) {
        $params[] = convertParam($param);
    }

    $name = $method->name->toString();

    // Constructor
    if ($name === '__construct') {
        return convertConstructor($method, $params);
    }

    // Destructor
    if ($name === '__destruct') {
        return [
            'kind'           => 'xnkDestructorDecl',
            'destructorBody' => $method->stmts !== null ? convertBlock($method->stmts) : null,
        ];
    }

    $visibility = extractVisibility($method->flags);
    $isStatic   = (bool)($method->flags & Stmt\Class_::MODIFIER_STATIC);
    $isAbstract = (bool)($method->flags & Stmt\Class_::MODIFIER_ABSTRACT);
    $isFinal    = (bool)($method->flags & Stmt\Class_::MODIFIER_FINAL);

    // Body may be null for abstract methods
    $body = $method->stmts !== null ? convertBlock($method->stmts) : [
        'kind'      => 'xnkBlockStmt',
        'blockBody' => [],
    ];

    return [
        'kind'              => 'xnkFuncDecl',
        'funcName'          => $name,
        'params'            => $params,
        'returnType'        => $method->returnType !== null ? convertTypeNode($method->returnType) : null,
        'body'              => $body,
        'isAsync'           => false,
        'funcVisibility'    => $visibility,
        'funcIsStatic'      => $isStatic,
    ];
}

// ===========================================================================
// Constructor (with promoted properties support)
// ===========================================================================
function convertConstructor(Stmt\ClassMethod $method, array $params): array
{
    // Check for constructor promotion (PHP 8.0+)
    $promotedFields = [];
    foreach ($method->params as $param) {
        if ($param->flags !== 0) {
            // This parameter has visibility flags → it's a promoted property
            $vis = extractVisibility($param->flags);
            $isReadonly = (bool)($param->flags & Stmt\Class_::MODIFIER_READONLY);
            $promotedFields[] = [
                'kind'             => 'xnkFieldDecl',
                'fieldName'        => $param->var->name,
                'fieldType'        => $param->type !== null ? convertTypeNode($param->type) : ['kind' => 'xnkNamedType', 'typeName' => 'mixed'],
                'fieldInitializer' => $param->default !== null ? convertExpr($param->default) : null,
                'fieldIsStatic'    => false,
                'fieldIsFinal'     => $isReadonly,
                'fieldIsVolatile'  => false,
                'fieldIsTransient' => false,
                'fieldIsPrivate'   => $vis === 'private',
                'fieldIsProtected' => $vis === 'protected',
                'fieldIsPublic'    => $vis === 'public',
            ];
        }
    }

    $body = $method->stmts !== null ? convertBlock($method->stmts) : [
        'kind'      => 'xnkBlockStmt',
        'blockBody' => [],
    ];

    // If there are promoted properties, prepend them as field declarations before the constructor
    // The caller should handle this, but for simplicity we wrap in metadata
    $result = [
        'kind'                   => 'xnkConstructorDecl',
        'constructorParams'      => $params,
        'constructorInitializers'=> [],
        'constructorBody'        => $body,
        'constructorIsPrivate'   => extractVisibility($method->flags) === 'private',
        'constructorIsProtected' => extractVisibility($method->flags) === 'protected',
        'constructorIsPublic'    => extractVisibility($method->flags) === 'public',
    ];

    if (!empty($promotedFields)) {
        $result['extPromotedProperties'] = $promotedFields;
    }

    return $result;
}

// ===========================================================================
// Property declaration
// ===========================================================================
function convertProperty(Stmt\Property $prop): array
{
    $visibility = extractVisibility($prop->flags);
    $isStatic   = (bool)($prop->flags & Stmt\Class_::MODIFIER_STATIC);
    $isReadonly = (bool)($prop->flags & Stmt\Class_::MODIFIER_READONLY);

    // PHP properties can have multiple declarators but usually just one
    $firstProp = $prop->props[0];

    // Check for property hooks (PHP 8.4)
    if (!empty($prop->hooks)) {
        return convertPropertyWithHooks($prop, $firstProp, $visibility, $isStatic, $isReadonly);
    }

    if ($isStatic && $isReadonly) {
        // static readonly → let declaration
        return [
            'kind'        => 'xnkLetDecl',
            'declName'    => $firstProp->name->toString(),
            'declType'    => $prop->type !== null ? convertTypeNode($prop->type) : null,
            'initializer' => $firstProp->default !== null ? convertExpr($firstProp->default) : null,
        ];
    }

    if ($isStatic) {
        // static mutable → var declaration
        return [
            'kind'        => 'xnkVarDecl',
            'declName'    => $firstProp->name->toString(),
            'declType'    => $prop->type !== null ? convertTypeNode($prop->type) : null,
            'initializer' => $firstProp->default !== null ? convertExpr($firstProp->default) : null,
        ];
    }

    // Instance field
    return [
        'kind'             => 'xnkFieldDecl',
        'fieldName'        => $firstProp->name->toString(),
        'fieldType'        => $prop->type !== null ? convertTypeNode($prop->type) : ['kind' => 'xnkNamedType', 'typeName' => 'mixed'],
        'fieldInitializer' => $firstProp->default !== null ? convertExpr($firstProp->default) : null,
        'fieldIsStatic'    => false,
        'fieldIsFinal'     => $isReadonly,
        'fieldIsVolatile'  => false,
        'fieldIsTransient' => false,
        'fieldIsPrivate'   => $visibility === 'private',
        'fieldIsProtected' => $visibility === 'protected',
        'fieldIsPublic'    => $visibility === 'public',
    ];
}

// ===========================================================================
// Property with hooks (PHP 8.4 — maps to xnkExternal_Property)
// ===========================================================================
function convertPropertyWithHooks(Stmt\Property $prop, Node\PropertyItem $firstProp, string $visibility, bool $isStatic, bool $isReadonly): array
{
    $hasGetter   = false;
    $hasSetter   = false;
    $getterBody  = null;
    $setterBody  = null;

    foreach ($prop->hooks as $hook) {
        $hookName = strtolower($hook->name->toString());
        if ($hookName === 'get') {
            $hasGetter = true;
            if ($hook->body instanceof Expr) {
                $getterBody = [
                    'kind'      => 'xnkBlockStmt',
                    'blockBody' => [[
                        'kind'       => 'xnkReturnStmt',
                        'returnExpr' => convertExpr($hook->body),
                    ]],
                ];
            } elseif (is_array($hook->body)) {
                $getterBody = convertBlock($hook->body);
            }
        } elseif ($hookName === 'set') {
            $hasSetter = true;
            if ($hook->body instanceof Expr) {
                $setterBody = [
                    'kind'      => 'xnkBlockStmt',
                    'blockBody' => [convertExpr($hook->body)],
                ];
            } elseif (is_array($hook->body)) {
                $setterBody = convertBlock($hook->body);
            }
        }
    }

    return [
        'kind'               => 'xnkExternal_Property',
        'extPropName'        => $firstProp->name->toString(),
        'extPropType'        => $prop->type !== null ? convertTypeNode($prop->type) : null,
        'extPropVisibility'  => $visibility,
        'extPropIsStatic'    => $isStatic,
        'extPropHasGetter'   => $hasGetter,
        'extPropHasSetter'   => $hasSetter,
        'extPropGetterBody'  => $getterBody,
        'extPropSetterBody'  => $setterBody,
        'extPropInitializer' => $firstProp->default !== null ? convertExpr($firstProp->default) : null,
    ];
}

// ===========================================================================
// Class const
// ===========================================================================
function convertClassConst(Stmt\ClassConst $classConst): array
{
    // Usually just one const per statement, but can be multiple
    if (count($classConst->consts) === 1) {
        $c = $classConst->consts[0];
        return [
            'kind'        => 'xnkConstDecl',
            'declName'    => $c->name->toString(),
            'declType'    => $classConst->type !== null ? convertTypeNode($classConst->type) : null,
            'initializer' => convertExpr($c->value),
        ];
    }

    $consts = [];
    foreach ($classConst->consts as $c) {
        $consts[] = [
            'kind'        => 'xnkConstDecl',
            'declName'    => $c->name->toString(),
            'declType'    => $classConst->type !== null ? convertTypeNode($classConst->type) : null,
            'initializer' => convertExpr($c->value),
        ];
    }
    return [
        'kind'      => 'xnkBlockStmt',
        'blockBody' => $consts,
    ];
}

// ===========================================================================
// File-level const
// ===========================================================================
function convertFileConst(Stmt\Const_ $fileConst): array
{
    if (count($fileConst->consts) === 1) {
        $c = $fileConst->consts[0];
        return [
            'kind'        => 'xnkConstDecl',
            'declName'    => $c->name->toString(),
            'declType'    => null,
            'initializer' => convertExpr($c->value),
        ];
    }

    $consts = [];
    foreach ($fileConst->consts as $c) {
        $consts[] = [
            'kind'        => 'xnkConstDecl',
            'declName'    => $c->name->toString(),
            'declType'    => null,
            'initializer' => convertExpr($c->value),
        ];
    }
    return [
        'kind'      => 'xnkBlockStmt',
        'blockBody' => $consts,
    ];
}

// ===========================================================================
// If / ElseIf / Else
// ===========================================================================
function convertIf(Stmt\If_ $ifStmt): array
{
    $elifBranches = [];
    foreach ($ifStmt->elseifs as $elseif) {
        $elifBranches[] = [
            'condition' => convertExpr($elseif->cond),
            'body'      => convertBlock($elseif->stmts),
        ];
    }

    return [
        'kind'          => 'xnkIfStmt',
        'ifCondition'   => convertExpr($ifStmt->cond),
        'ifBody'        => convertBlock($ifStmt->stmts),
        'elifBranches'  => $elifBranches,
        'elseBody'      => $ifStmt->else !== null ? convertBlock($ifStmt->else->stmts) : null,
    ];
}

// ===========================================================================
// For (C-style)
// ===========================================================================
function convertFor(Stmt\For_ $forStmt): array
{
    // PHP for can have multiple init/cond/loop expressions
    $init = null;
    if (!empty($forStmt->init)) {
        $init = count($forStmt->init) === 1
            ? convertExpr($forStmt->init[0])
            : [
                'kind'      => 'xnkBlockStmt',
                'blockBody' => array_map(fn($e) => convertExpr($e), $forStmt->init),
            ];
    }

    $cond = null;
    if (!empty($forStmt->cond)) {
        $cond = count($forStmt->cond) === 1
            ? convertExpr($forStmt->cond[0])
            : [
                'kind'        => 'xnkBinaryExpr',
                'binaryOp'    => 'and',
                'binaryLeft'  => convertExpr($forStmt->cond[0]),
                'binaryRight' => count($forStmt->cond) > 2
                    ? convertExpr($forStmt->cond[1]) // simplified for 2+
                    : convertExpr($forStmt->cond[1]),
            ];
    }

    $incr = null;
    if (!empty($forStmt->loop)) {
        $incr = count($forStmt->loop) === 1
            ? convertExpr($forStmt->loop[0])
            : [
                'kind'      => 'xnkBlockStmt',
                'blockBody' => array_map(fn($e) => convertExpr($e), $forStmt->loop),
            ];
    }

    return [
        'kind'            => 'xnkExternal_ForStmt',
        'extForInit'      => $init,
        'extForCond'      => $cond,
        'extForIncrement' => $incr,
        'extForBody'      => convertBlock($forStmt->stmts),
    ];
}

// ===========================================================================
// Foreach
// ===========================================================================
function convertForeach(Stmt\Foreach_ $forEach): array
{
    $varNode = convertExpr($forEach->valueVar);

    // If there's a key, wrap as a tuple
    if ($forEach->keyVar !== null) {
        $varNode = [
            'kind'     => 'xnkTupleExpr',
            'elements' => [
                convertExpr($forEach->keyVar),
                convertExpr($forEach->valueVar),
            ],
        ];
    }

    return [
        'kind'        => 'xnkForeachStmt',
        'foreachVar'  => $varNode,
        'foreachIter' => convertExpr($forEach->expr),
        'foreachBody' => convertBlock($forEach->stmts),
    ];
}

// ===========================================================================
// Switch
// ===========================================================================
function convertSwitch(Stmt\Switch_ $switch): array
{
    $cases = [];
    foreach ($switch->cases as $case) {
        if ($case->cond === null) {
            // Default case
            $cases[] = [
                'kind'        => 'xnkDefaultClause',
                'defaultBody' => convertBlock($case->stmts),
            ];
        } else {
            $cases[] = [
                'kind'            => 'xnkCaseClause',
                'caseValues'      => [convertExpr($case->cond)],
                'caseBody'        => convertBlock($case->stmts),
                'caseFallthrough' => true, // PHP switch falls through by default
            ];
        }
    }

    return [
        'kind'        => 'xnkSwitchStmt',
        'switchExpr'  => convertExpr($switch->cond),
        'switchCases' => $cases,
    ];
}

// ===========================================================================
// Try / Catch / Finally
// ===========================================================================
function convertTryCatch(Stmt\TryCatch $tryCatch): array
{
    $catches = [];
    foreach ($tryCatch->catches as $catch) {
        $catchType = null;
        if (!empty($catch->types)) {
            if (count($catch->types) === 1) {
                $catchType = convertNameNode($catch->types[0]);
            } else {
                // Multiple catch types → union type
                $catchType = [
                    'kind'       => 'xnkUnionType',
                    'unionTypes' => array_map(fn($t) => convertNameNode($t), $catch->types),
                ];
            }
        }

        $catches[] = [
            'kind'      => 'xnkCatchStmt',
            'catchType' => $catchType,
            'catchVar'  => $catch->var !== null ? $catch->var->name : null,
            'catchBody' => convertBlock($catch->stmts),
        ];
    }

    return [
        'kind'          => 'xnkTryStmt',
        'tryBody'       => convertBlock($tryCatch->stmts),
        'catchClauses'  => $catches,
        'finallyClause' => $tryCatch->finally !== null ? [
            'kind'        => 'xnkFinallyStmt',
            'finallyBody' => convertBlock($tryCatch->finally->stmts),
        ] : null,
    ];
}

// ===========================================================================
// Echo (PHP-specific — maps to call)
// ===========================================================================
function convertEcho(Stmt\Echo_ $echo): array
{
    return [
        'kind'   => 'xnkCallExpr',
        'callee' => [
            'kind'      => 'xnkIdentifier',
            'identName' => 'echo',
        ],
        'args' => array_map(fn($e) => convertExpr($e), $echo->exprs),
    ];
}

// ===========================================================================
// Global / Static / Unset / Declare
// ===========================================================================
function convertGlobal(Stmt\Global_ $global): array
{
    $vars = [];
    foreach ($global->vars as $var) {
        $vars[] = [
            'kind'    => 'xnkGlobalVar',
            'varName' => $var instanceof Expr\Variable && is_string($var->name) ? $var->name : '',
        ];
    }
    return [
        'kind'      => 'xnkBlockStmt',
        'blockBody' => $vars,
    ];
}

function convertStaticVars(Stmt\Static_ $static): array
{
    $decls = [];
    foreach ($static->vars as $var) {
        $decls[] = [
            'kind'        => 'xnkVarDecl',
            'declName'    => $var->var->name,
            'declType'    => null,
            'initializer' => $var->default !== null ? convertExpr($var->default) : null,
        ];
    }
    if (count($decls) === 1) {
        return $decls[0];
    }
    return [
        'kind'      => 'xnkBlockStmt',
        'blockBody' => $decls,
    ];
}

function convertUnset(Stmt\Unset_ $unset): array
{
    return [
        'kind'   => 'xnkCallExpr',
        'callee' => ['kind' => 'xnkIdentifier', 'identName' => 'unset'],
        'args'   => array_map(fn($v) => convertExpr($v), $unset->vars),
    ];
}

function convertDeclare(Stmt\Declare_ $declare): array
{
    $entries = [];
    foreach ($declare->declares as $d) {
        $entries[] = [
            'kind'        => 'xnkConstDecl',
            'declName'    => $d->key->toString(),
            'declType'    => null,
            'initializer' => convertExpr($d->value),
        ];
    }
    $body = null;
    if ($declare->stmts !== null) {
        $body = convertBlock($declare->stmts);
    }
    return [
        'kind'             => 'xnkExternal_PhpDeclare',
        'extDeclareEntries'=> $entries,
        'extDeclareBody'   => $body,
    ];
}

// ===========================================================================
// Expression conversion
// ===========================================================================
function convertExpr(Node $expr): array
{
    // --- Variables ---
    if ($expr instanceof Expr\Variable) {
        return convertVariable($expr);
    }

    // --- Literals ---
    if ($expr instanceof Scalar\Int_) {
        return ['kind' => 'xnkIntLit', 'literalValue' => (string)$expr->value];
    }
    if ($expr instanceof Scalar\Float_) {
        return ['kind' => 'xnkFloatLit', 'literalValue' => (string)$expr->value];
    }
    if ($expr instanceof Scalar\String_) {
        return ['kind' => 'xnkStringLit', 'literalValue' => $expr->value];
    }
    if ($expr instanceof Scalar\InterpolatedString) {
        return convertInterpolatedString($expr);
    }
    if ($expr instanceof Scalar\MagicConst) {
        return convertMagicConst($expr);
    }

    // --- Assignments ---
    if ($expr instanceof Expr\Assign) {
        return [
            'kind'      => 'xnkAsgn',
            'asgnLeft'  => convertExpr($expr->var),
            'asgnRight' => convertExpr($expr->expr),
        ];
    }
    if ($expr instanceof Expr\AssignRef) {
        return [
            'kind'      => 'xnkAsgn',
            'asgnLeft'  => convertExpr($expr->var),
            'asgnRight' => [
                'kind'        => 'xnkUnaryExpr',
                'unaryOp'     => 'addrof',
                'unaryOperand'=> convertExpr($expr->expr),
            ],
        ];
    }
    if ($expr instanceof Expr\AssignOp) {
        return convertAssignOp($expr);
    }

    // --- Binary operations ---
    if ($expr instanceof Expr\BinaryOp) {
        return convertBinaryOp($expr);
    }

    // --- Unary operations ---
    if ($expr instanceof Expr\UnaryMinus) {
        return ['kind' => 'xnkUnaryExpr', 'unaryOp' => 'neg', 'unaryOperand' => convertExpr($expr->expr)];
    }
    if ($expr instanceof Expr\UnaryPlus) {
        return ['kind' => 'xnkUnaryExpr', 'unaryOp' => 'pos', 'unaryOperand' => convertExpr($expr->expr)];
    }
    if ($expr instanceof Expr\BooleanNot) {
        return ['kind' => 'xnkUnaryExpr', 'unaryOp' => 'not', 'unaryOperand' => convertExpr($expr->expr)];
    }
    if ($expr instanceof Expr\BitwiseNot) {
        return ['kind' => 'xnkUnaryExpr', 'unaryOp' => 'bitnot', 'unaryOperand' => convertExpr($expr->expr)];
    }
    if ($expr instanceof Expr\PreInc) {
        return ['kind' => 'xnkUnaryExpr', 'unaryOp' => 'preinc', 'unaryOperand' => convertExpr($expr->var)];
    }
    if ($expr instanceof Expr\PreDec) {
        return ['kind' => 'xnkUnaryExpr', 'unaryOp' => 'predec', 'unaryOperand' => convertExpr($expr->var)];
    }
    if ($expr instanceof Expr\PostInc) {
        return ['kind' => 'xnkUnaryExpr', 'unaryOp' => 'postinc', 'unaryOperand' => convertExpr($expr->var)];
    }
    if ($expr instanceof Expr\PostDec) {
        return ['kind' => 'xnkUnaryExpr', 'unaryOp' => 'postdec', 'unaryOperand' => convertExpr($expr->var)];
    }

    // --- Error suppression (@expr) ---
    if ($expr instanceof Expr\ErrorSuppress) {
        return [
            'kind'               => 'xnkExternal_PhpErrorSuppress',
            'extSuppressedExpr'  => convertExpr($expr->expr),
        ];
    }

    // --- Cast operations ---
    if ($expr instanceof Expr\Cast) {
        return convertCast($expr);
    }

    // --- Function/method calls ---
    if ($expr instanceof Expr\FuncCall) {
        return convertFuncCall($expr);
    }
    if ($expr instanceof Expr\MethodCall) {
        return convertMethodCall($expr);
    }
    if ($expr instanceof Expr\NullsafeMethodCall) {
        return convertNullsafeMethodCall($expr);
    }
    if ($expr instanceof Expr\StaticCall) {
        return convertStaticCall($expr);
    }

    // --- Property fetch ---
    if ($expr instanceof Expr\PropertyFetch) {
        return convertPropertyFetch($expr);
    }
    if ($expr instanceof Expr\NullsafePropertyFetch) {
        return convertNullsafePropertyFetch($expr);
    }
    if ($expr instanceof Expr\StaticPropertyFetch) {
        return convertStaticPropertyFetch($expr);
    }

    // --- Class constant fetch ---
    if ($expr instanceof Expr\ClassConstFetch) {
        return convertClassConstFetch($expr);
    }

    // --- Constant fetch ---
    if ($expr instanceof Expr\ConstFetch) {
        return convertConstFetch($expr);
    }

    // --- New (object creation) ---
    if ($expr instanceof Expr\New_) {
        return convertNew($expr);
    }

    // --- Clone ---
    if ($expr instanceof Expr\Clone_) {
        return [
            'kind'   => 'xnkCallExpr',
            'callee' => ['kind' => 'xnkIdentifier', 'identName' => 'clone'],
            'args'   => [convertExpr($expr->expr)],
        ];
    }

    // --- Array operations ---
    if ($expr instanceof Expr\Array_) {
        return convertArrayExpr($expr);
    }
    if ($expr instanceof Expr\ArrayDimFetch) {
        return convertArrayDimFetch($expr);
    }

    // --- List unpacking ---
    if ($expr instanceof Expr\List_) {
        return convertList($expr);
    }

    // --- Instanceof ---
    if ($expr instanceof Expr\Instanceof_) {
        return convertInstanceof($expr);
    }

    // --- Ternary ---
    if ($expr instanceof Expr\Ternary) {
        return convertTernary($expr);
    }

    // --- Match expression (PHP 8.0+) ---
    if ($expr instanceof Expr\Match_) {
        return convertMatch($expr);
    }

    // --- Closure / Arrow function ---
    if ($expr instanceof Expr\Closure) {
        return convertClosure($expr);
    }
    if ($expr instanceof Expr\ArrowFunction) {
        return convertArrowFunction($expr);
    }

    // --- Yield / Yield From ---
    if ($expr instanceof Expr\Yield_) {
        return [
            'kind'               => 'xnkIteratorYield',
            'iteratorYieldValue' => $expr->value !== null ? convertExpr($expr->value) : null,
        ];
    }
    if ($expr instanceof Expr\YieldFrom) {
        return [
            'kind'                  => 'xnkIteratorDelegate',
            'iteratorDelegateExpr'  => convertExpr($expr->expr),
        ];
    }

    // --- Throw expression (PHP 8.0+) ---
    if ($expr instanceof Expr\Throw_) {
        return [
            'kind'              => 'xnkExternal_ThrowExpr',
            'extThrowExprValue' => convertExpr($expr->expr),
        ];
    }

    // --- Isset / Empty / Eval / Exit / Print ---
    if ($expr instanceof Expr\Isset_) {
        return [
            'kind'   => 'xnkCallExpr',
            'callee' => ['kind' => 'xnkIdentifier', 'identName' => 'isset'],
            'args'   => array_map(fn($v) => convertExpr($v), $expr->vars),
        ];
    }
    if ($expr instanceof Expr\Empty_) {
        return [
            'kind'   => 'xnkCallExpr',
            'callee' => ['kind' => 'xnkIdentifier', 'identName' => 'empty'],
            'args'   => [convertExpr($expr->expr)],
        ];
    }
    if ($expr instanceof Expr\Eval_) {
        return [
            'kind'   => 'xnkCallExpr',
            'callee' => ['kind' => 'xnkIdentifier', 'identName' => 'eval'],
            'args'   => [convertExpr($expr->expr)],
        ];
    }
    if ($expr instanceof Expr\Exit_) {
        return [
            'kind'   => 'xnkCallExpr',
            'callee' => ['kind' => 'xnkIdentifier', 'identName' => 'exit'],
            'args'   => $expr->expr !== null ? [convertExpr($expr->expr)] : [],
        ];
    }
    if ($expr instanceof Expr\Print_) {
        return [
            'kind'   => 'xnkCallExpr',
            'callee' => ['kind' => 'xnkIdentifier', 'identName' => 'print'],
            'args'   => [convertExpr($expr->expr)],
        ];
    }

    // --- Include / Require ---
    if ($expr instanceof Expr\Include_) {
        $funcName = match ($expr->type) {
            Expr\Include_::TYPE_INCLUDE      => 'include',
            Expr\Include_::TYPE_INCLUDE_ONCE => 'include_once',
            Expr\Include_::TYPE_REQUIRE      => 'require',
            Expr\Include_::TYPE_REQUIRE_ONCE => 'require_once',
            default => 'include',
        };
        return [
            'kind'        => 'xnkInclude',
            'includeName' => convertExpr($expr->expr),
        ];
    }

    // --- Shell exec (backtick) ---
    if ($expr instanceof Expr\ShellExec) {
        return convertShellExec($expr);
    }

    // --- Spread operator ---
    if ($expr instanceof Expr\Unpack) {
        // Only available in certain contexts; might be handled in arg lists
        // Treat as unary spread
        return [
            'kind'         => 'xnkUnaryExpr',
            'unaryOp'      => 'spread',
            'unaryOperand' => convertExpr($expr->expr),
        ];
    }

    // --- Named argument (PHP 8.0+) ---
    if ($expr instanceof Node\Arg) {
        return convertArg($expr);
    }

    // --- First-class callable syntax (PHP 8.1+) ---
    if ($expr instanceof Expr\CallableExpr || (isset($expr->class) === false && $expr instanceof Expr\FuncCall === false && method_exists($expr, 'getType') && $expr->getType() === 'Expr_CallableExpr')) {
        // Fallthrough to unknown
    }

    // --- Identifier / Name nodes ---
    if ($expr instanceof Node\Identifier) {
        return ['kind' => 'xnkIdentifier', 'identName' => $expr->toString()];
    }
    if ($expr instanceof Name) {
        return convertNameNode($expr);
    }

    return trackUnknown('expression', $expr);
}

// ===========================================================================
// Variable
// ===========================================================================
function convertVariable(Expr\Variable $var): array
{
    if ($var->name === 'this') {
        return ['kind' => 'xnkThisExpr'];
    }
    if (is_string($var->name)) {
        return ['kind' => 'xnkIdentifier', 'identName' => $var->name];
    }
    // Variable variables ($$var)
    return [
        'kind'           => 'xnkExternal_PhpVariableVariable',
        'extVarVarExpr'  => convertExpr($var->name),
    ];
}

// ===========================================================================
// Interpolated string
// ===========================================================================
function convertInterpolatedString(Scalar\InterpolatedString $str): array
{
    $parts  = [];
    $isExpr = [];

    foreach ($str->parts as $part) {
        if ($part instanceof Node\InterpolatedStringPart) {
            $parts[]  = ['kind' => 'xnkStringLit', 'literalValue' => $part->value];
            $isExpr[] = false;
        } else {
            $parts[]  = convertExpr($part);
            $isExpr[] = true;
        }
    }

    return [
        'kind'            => 'xnkExternal_StringInterp',
        'extInterpParts'  => $parts,
        'extInterpIsExpr' => $isExpr,
    ];
}

// ===========================================================================
// Magic constants
// ===========================================================================
function convertMagicConst(Scalar\MagicConst $mc): array
{
    $name = match (true) {
        $mc instanceof Scalar\MagicConst\Class_     => '__CLASS__',
        $mc instanceof Scalar\MagicConst\Dir        => '__DIR__',
        $mc instanceof Scalar\MagicConst\File       => '__FILE__',
        $mc instanceof Scalar\MagicConst\Function_  => '__FUNCTION__',
        $mc instanceof Scalar\MagicConst\Line       => '__LINE__',
        $mc instanceof Scalar\MagicConst\Method     => '__METHOD__',
        $mc instanceof Scalar\MagicConst\Namespace_ => '__NAMESPACE__',
        $mc instanceof Scalar\MagicConst\Trait_     => '__TRAIT__',
        $mc instanceof Scalar\MagicConst\Property   => '__PROPERTY__',
        default => '__UNKNOWN__',
    };
    return ['kind' => 'xnkIdentifier', 'identName' => $name];
}

// ===========================================================================
// Compound assignment
// ===========================================================================
function convertAssignOp(Expr\AssignOp $assignOp): array
{
    $op = match (true) {
        $assignOp instanceof Expr\AssignOp\Plus          => 'adda',
        $assignOp instanceof Expr\AssignOp\Minus         => 'suba',
        $assignOp instanceof Expr\AssignOp\Mul           => 'mula',
        $assignOp instanceof Expr\AssignOp\Div           => 'diva',
        $assignOp instanceof Expr\AssignOp\Mod           => 'moda',
        $assignOp instanceof Expr\AssignOp\Pow           => 'powa',
        $assignOp instanceof Expr\AssignOp\Concat        => 'concata',
        $assignOp instanceof Expr\AssignOp\BitwiseAnd    => 'bitanda',
        $assignOp instanceof Expr\AssignOp\BitwiseOr     => 'bitora',
        $assignOp instanceof Expr\AssignOp\BitwiseXor    => 'bitxora',
        $assignOp instanceof Expr\AssignOp\ShiftLeft     => 'shla',
        $assignOp instanceof Expr\AssignOp\ShiftRight    => 'shra',
        $assignOp instanceof Expr\AssignOp\Coalesce      => 'nullcoalescea',
        default => 'unknown',
    };

    return [
        'kind'        => 'xnkBinaryExpr',
        'binaryOp'    => $op,
        'binaryLeft'  => convertExpr($assignOp->var),
        'binaryRight' => convertExpr($assignOp->expr),
    ];
}

// ===========================================================================
// Binary operations
// ===========================================================================
function convertBinaryOp(Expr\BinaryOp $binOp): array
{
    // Null coalescing → external node
    if ($binOp instanceof Expr\BinaryOp\Coalesce) {
        return [
            'kind'                  => 'xnkExternal_NullCoalesce',
            'extNullCoalesceLeft'   => convertExpr($binOp->left),
            'extNullCoalesceRight'  => convertExpr($binOp->right),
        ];
    }

    $op = match (true) {
        // Arithmetic
        $binOp instanceof Expr\BinaryOp\Plus          => 'add',
        $binOp instanceof Expr\BinaryOp\Minus         => 'sub',
        $binOp instanceof Expr\BinaryOp\Mul           => 'mul',
        $binOp instanceof Expr\BinaryOp\Div           => 'div',
        $binOp instanceof Expr\BinaryOp\Mod           => 'mod',
        $binOp instanceof Expr\BinaryOp\Pow           => 'pow',
        // String concatenation
        $binOp instanceof Expr\BinaryOp\Concat        => 'concat',
        // Bitwise
        $binOp instanceof Expr\BinaryOp\BitwiseAnd    => 'bitand',
        $binOp instanceof Expr\BinaryOp\BitwiseOr     => 'bitor',
        $binOp instanceof Expr\BinaryOp\BitwiseXor    => 'bitxor',
        $binOp instanceof Expr\BinaryOp\ShiftLeft     => 'shl',
        $binOp instanceof Expr\BinaryOp\ShiftRight    => 'shr',
        // Comparison
        $binOp instanceof Expr\BinaryOp\Equal         => 'eq',
        $binOp instanceof Expr\BinaryOp\NotEqual      => 'neq',
        $binOp instanceof Expr\BinaryOp\Identical     => 'is',
        $binOp instanceof Expr\BinaryOp\NotIdentical  => 'isnot',
        $binOp instanceof Expr\BinaryOp\Smaller       => 'lt',
        $binOp instanceof Expr\BinaryOp\SmallerOrEqual=> 'le',
        $binOp instanceof Expr\BinaryOp\Greater       => 'gt',
        $binOp instanceof Expr\BinaryOp\GreaterOrEqual=> 'ge',
        $binOp instanceof Expr\BinaryOp\Spaceship     => 'spaceship',
        // Logical
        $binOp instanceof Expr\BinaryOp\BooleanAnd    => 'and',
        $binOp instanceof Expr\BinaryOp\BooleanOr     => 'or',
        $binOp instanceof Expr\BinaryOp\LogicalAnd    => 'and',
        $binOp instanceof Expr\BinaryOp\LogicalOr     => 'or',
        $binOp instanceof Expr\BinaryOp\LogicalXor    => 'bitxor', // PHP logical xor
        default => 'unknown',
    };

    return [
        'kind'        => 'xnkBinaryExpr',
        'binaryOp'    => $op,
        'binaryLeft'  => convertExpr($binOp->left),
        'binaryRight' => convertExpr($binOp->right),
    ];
}

// ===========================================================================
// Cast
// ===========================================================================
function convertCast(Expr\Cast $cast): array
{
    $typeName = match (true) {
        $cast instanceof Expr\Cast\Int_    => 'int',
        $cast instanceof Expr\Cast\Double  => 'float',
        $cast instanceof Expr\Cast\String_ => 'string',
        $cast instanceof Expr\Cast\Bool_   => 'bool',
        $cast instanceof Expr\Cast\Array_  => 'array',
        $cast instanceof Expr\Cast\Object_ => 'object',
        $cast instanceof Expr\Cast\Unset_  => 'unset',
        default => 'unknown',
    };

    return [
        'kind'     => 'xnkCastExpr',
        'castExpr' => convertExpr($cast->expr),
        'castType' => ['kind' => 'xnkNamedType', 'typeName' => $typeName],
    ];
}

// ===========================================================================
// Function calls
// ===========================================================================
function convertFuncCall(Expr\FuncCall $call): array
{
    $callee = $call->name instanceof Name
        ? convertNameNode($call->name)
        : convertExpr($call->name);

    return [
        'kind'   => 'xnkCallExpr',
        'callee' => $callee,
        'args'   => convertArgList($call->args),
    ];
}

function convertMethodCall(Expr\MethodCall $call): array
{
    $methodName = $call->name instanceof Node\Identifier
        ? $call->name->toString()
        : null;

    if ($methodName !== null) {
        return [
            'kind'   => 'xnkCallExpr',
            'callee' => [
                'kind'       => 'xnkMemberAccessExpr',
                'memberExpr' => convertExpr($call->var),
                'memberName' => $methodName,
            ],
            'args' => convertArgList($call->args),
        ];
    }

    // Dynamic method name ($obj->$method())
    return [
        'kind'   => 'xnkCallExpr',
        'callee' => [
            'kind'       => 'xnkMemberAccessExpr',
            'memberExpr' => convertExpr($call->var),
            'memberName' => '__dynamic__',
        ],
        'args' => convertArgList($call->args),
    ];
}

function convertNullsafeMethodCall(Expr\NullsafeMethodCall $call): array
{
    $methodName = $call->name instanceof Node\Identifier
        ? $call->name->toString()
        : '__dynamic__';

    return [
        'kind'   => 'xnkCallExpr',
        'callee' => [
            'kind'              => 'xnkExternal_SafeNavigation',
            'extSafeNavObject'  => convertExpr($call->var),
            'extSafeNavMember'  => $methodName,
        ],
        'args' => convertArgList($call->args),
    ];
}

function convertStaticCall(Expr\StaticCall $call): array
{
    $className = $call->class instanceof Name
        ? nameToString($call->class)
        : (method_exists($call->class, 'getType') ? convertExpr($call->class) : ['kind' => 'xnkIdentifier', 'identName' => 'unknown']);

    $methodName = $call->name instanceof Node\Identifier
        ? $call->name->toString()
        : '__dynamic__';

    $classNode = is_string($className) ? ['kind' => 'xnkIdentifier', 'identName' => $className] : $className;

    return [
        'kind'   => 'xnkCallExpr',
        'callee' => [
            'kind'       => 'xnkMemberAccessExpr',
            'memberExpr' => $classNode,
            'memberName' => $methodName,
        ],
        'args' => convertArgList($call->args),
    ];
}

// ===========================================================================
// Property fetch
// ===========================================================================
function convertPropertyFetch(Expr\PropertyFetch $fetch): array
{
    $propName = $fetch->name instanceof Node\Identifier
        ? $fetch->name->toString()
        : '__dynamic__';

    return [
        'kind'       => 'xnkMemberAccessExpr',
        'memberExpr' => convertExpr($fetch->var),
        'memberName' => $propName,
    ];
}

function convertNullsafePropertyFetch(Expr\NullsafePropertyFetch $fetch): array
{
    $propName = $fetch->name instanceof Node\Identifier
        ? $fetch->name->toString()
        : '__dynamic__';

    return [
        'kind'              => 'xnkExternal_SafeNavigation',
        'extSafeNavObject'  => convertExpr($fetch->var),
        'extSafeNavMember'  => $propName,
    ];
}

function convertStaticPropertyFetch(Expr\StaticPropertyFetch $fetch): array
{
    $className = $fetch->class instanceof Name
        ? nameToString($fetch->class)
        : 'unknown';

    $propName = $fetch->name instanceof Node\VarLikeIdentifier
        ? $fetch->name->toString()
        : '__dynamic__';

    return [
        'kind'       => 'xnkMemberAccessExpr',
        'memberExpr' => ['kind' => 'xnkIdentifier', 'identName' => $className],
        'memberName' => $propName,
    ];
}

// ===========================================================================
// Class constant fetch
// ===========================================================================
function convertClassConstFetch(Expr\ClassConstFetch $fetch): array
{
    $className = $fetch->class instanceof Name
        ? nameToString($fetch->class)
        : 'unknown';
    $constName = $fetch->name instanceof Node\Identifier
        ? $fetch->name->toString()
        : '__dynamic__';

    // class::class → special case
    if ($constName === 'class') {
        return [
            'kind'       => 'xnkTypeOfExpr',
            'typeOfType' => ['kind' => 'xnkNamedType', 'typeName' => $className],
        ];
    }

    return [
        'kind'       => 'xnkMemberAccessExpr',
        'memberExpr' => ['kind' => 'xnkIdentifier', 'identName' => $className],
        'memberName' => $constName,
        'isEnumAccess' => false,
        'enumTypeName' => '',
        'enumFullName' => '',
    ];
}

// ===========================================================================
// Constant fetch (true, false, null, user constants)
// ===========================================================================
function convertConstFetch(Expr\ConstFetch $fetch): array
{
    $name = strtolower($fetch->name->toString());

    if ($name === 'true') {
        return ['kind' => 'xnkBoolLit', 'boolValue' => true];
    }
    if ($name === 'false') {
        return ['kind' => 'xnkBoolLit', 'boolValue' => false];
    }
    if ($name === 'null') {
        return ['kind' => 'xnkNilLit'];
    }

    return ['kind' => 'xnkIdentifier', 'identName' => $fetch->name->toString()];
}

// ===========================================================================
// New (object creation)
// ===========================================================================
function convertNew(Expr\New_ $new): array
{
    $callee = $new->class instanceof Name
        ? convertNameNode($new->class)
        : ($new->class instanceof Stmt\Class_
            ? convertClass($new->class) // anonymous class
            : convertExpr($new->class));

    return [
        'kind'   => 'xnkCallExpr',
        'callee' => $callee,
        'args'   => convertArgList($new->args),
    ];
}

// ===========================================================================
// Array expressions
// ===========================================================================
function convertArrayExpr(Expr\Array_ $arr): array
{
    $hasKeys = false;
    foreach ($arr->items as $item) {
        if ($item !== null && $item->key !== null) {
            $hasKeys = true;
            break;
        }
    }

    if ($hasKeys) {
        // Associative array → map literal
        $entries = [];
        foreach ($arr->items as $item) {
            if ($item === null) continue;
            $entries[] = [
                'kind'  => 'xnkDictEntry',
                'key'   => $item->key !== null ? convertExpr($item->key) : ['kind' => 'xnkNilLit'],
                'value' => $item->unpack
                    ? ['kind' => 'xnkUnaryExpr', 'unaryOp' => 'spread', 'unaryOperand' => convertExpr($item->value)]
                    : convertExpr($item->value),
            ];
        }
        return ['kind' => 'xnkMapLiteral', 'entries' => $entries];
    }

    // Sequential array → sequence literal
    $elements = [];
    foreach ($arr->items as $item) {
        if ($item === null) continue;
        $elements[] = $item->unpack
            ? ['kind' => 'xnkUnaryExpr', 'unaryOp' => 'spread', 'unaryOperand' => convertExpr($item->value)]
            : convertExpr($item->value);
    }
    return ['kind' => 'xnkSequenceLiteral', 'elements' => $elements];
}

// ===========================================================================
// Array dimension fetch ($arr[key])
// ===========================================================================
function convertArrayDimFetch(Expr\ArrayDimFetch $fetch): array
{
    if ($fetch->dim === null) {
        // $arr[] → append operation
        return [
            'kind'      => 'xnkExternal_PhpArrayAppend',
            'extAppendTarget' => convertExpr($fetch->var),
        ];
    }

    return [
        'kind'      => 'xnkIndexExpr',
        'indexExpr'  => convertExpr($fetch->var),
        'indexArgs' => [convertExpr($fetch->dim)],
    ];
}

// ===========================================================================
// List unpacking
// ===========================================================================
function convertList(Expr\List_ $list): array
{
    $targets = [];
    foreach ($list->items as $item) {
        if ($item === null) {
            $targets[] = ['kind' => 'xnkIdentifier', 'identName' => '_'];
        } else {
            $targets[] = convertExpr($item->value);
        }
    }
    return [
        'kind'          => 'xnkTupleExpr',
        'elements'      => $targets,
    ];
}

// ===========================================================================
// Instanceof
// ===========================================================================
function convertInstanceof(Expr\Instanceof_ $inst): array
{
    $typeName = $inst->class instanceof Name
        ? nameToString($inst->class)
        : 'unknown';

    return [
        'kind'       => 'xnkTypeAssertion',
        'assertExpr' => convertExpr($inst->expr),
        'assertType' => ['kind' => 'xnkNamedType', 'typeName' => $typeName],
    ];
}

// ===========================================================================
// Ternary
// ===========================================================================
function convertTernary(Expr\Ternary $ternary): array
{
    if ($ternary->if === null) {
        // Elvis operator: $a ?: $b
        return [
            'kind'        => 'xnkBinaryExpr',
            'binaryOp'    => 'elvis',
            'binaryLeft'  => convertExpr($ternary->cond),
            'binaryRight' => convertExpr($ternary->else),
        ];
    }

    return [
        'kind'                => 'xnkExternal_Ternary',
        'extTernaryCondition' => convertExpr($ternary->cond),
        'extTernaryThen'      => convertExpr($ternary->if),
        'extTernaryElse'      => convertExpr($ternary->else),
    ];
}

// ===========================================================================
// Match expression (PHP 8.0+) → maps to xnkExternal_SwitchExpr
// ===========================================================================
function convertMatch(Expr\Match_ $match): array
{
    $arms = [];
    foreach ($match->arms as $arm) {
        if ($arm->conds === null) {
            // Default arm
            $arms[] = [
                'kind'                 => 'xnkSwitchCase',
                'switchCaseConditions' => [['kind' => 'xnkIdentifier', 'identName' => '_']],
                'switchCaseBody'       => convertExpr($arm->body),
            ];
        } else {
            $arms[] = [
                'kind'                 => 'xnkSwitchCase',
                'switchCaseConditions' => array_map(fn($c) => convertExpr($c), $arm->conds),
                'switchCaseBody'       => convertExpr($arm->body),
            ];
        }
    }

    return [
        'kind'               => 'xnkExternal_SwitchExpr',
        'extSwitchExprValue' => convertExpr($match->cond),
        'extSwitchExprArms'  => $arms,
    ];
}

// ===========================================================================
// Closure (anonymous function)
// ===========================================================================
function convertClosure(Expr\Closure $closure): array
{
    $params = [];
    foreach ($closure->params as $param) {
        $params[] = convertParam($param);
    }

    $result = [
        'kind'             => 'xnkLambdaExpr',
        'lambdaParams'     => $params,
        'lambdaReturnType' => $closure->returnType !== null ? convertTypeNode($closure->returnType) : null,
        'lambdaBody'       => convertBlock($closure->stmts),
    ];

    // Track use() variables
    if (!empty($closure->uses)) {
        $result['extClosureUses'] = array_map(function ($use) {
            return [
                'name'  => $use->var->name,
                'byRef' => $use->byRef,
            ];
        }, $closure->uses);
    }

    return $result;
}

// ===========================================================================
// Arrow function (PHP 7.4+)
// ===========================================================================
function convertArrowFunction(Expr\ArrowFunction $arrow): array
{
    $params = [];
    foreach ($arrow->params as $param) {
        $params[] = convertParam($param);
    }

    return [
        'kind'            => 'xnkArrowFunc',
        'arrowParams'     => $params,
        'arrowBody'       => convertExpr($arrow->expr),
        'arrowReturnType' => $arrow->returnType !== null ? convertTypeNode($arrow->returnType) : null,
    ];
}

// ===========================================================================
// Shell exec (backtick)
// ===========================================================================
function convertShellExec(Expr\ShellExec $shellExec): array
{
    $parts  = [];
    $isExpr = [];
    foreach ($shellExec->parts as $part) {
        if ($part instanceof Node\InterpolatedStringPart) {
            $parts[]  = ['kind' => 'xnkStringLit', 'literalValue' => $part->value];
            $isExpr[] = false;
        } else {
            $parts[]  = convertExpr($part);
            $isExpr[] = true;
        }
    }

    return [
        'kind'   => 'xnkCallExpr',
        'callee' => ['kind' => 'xnkIdentifier', 'identName' => 'shell_exec'],
        'args'   => [[
            'kind'            => 'xnkExternal_StringInterp',
            'extInterpParts'  => $parts,
            'extInterpIsExpr' => $isExpr,
        ]],
    ];
}

// ===========================================================================
// Argument list conversion (handles named args and spread)
// ===========================================================================
function convertArgList(array $args): array
{
    $result = [];
    foreach ($args as $arg) {
        if ($arg instanceof Node\VariadicPlaceholder) {
            // First-class callable syntax: foo(...)
            $result[] = [
                'kind'      => 'xnkIdentifier',
                'identName' => '...',
            ];
            continue;
        }
        $converted = convertExpr($arg->value);

        if ($arg->unpack) {
            $converted = [
                'kind'         => 'xnkUnaryExpr',
                'unaryOp'      => 'spread',
                'unaryOperand' => $converted,
            ];
        }

        if ($arg->name !== null) {
            // Named argument (PHP 8.0+)
            $result[] = [
                'kind'     => 'xnkArgument',
                'argName'  => $arg->name->toString(),
                'argValue' => $converted,
            ];
        } else {
            $result[] = $converted;
        }
    }
    return $result;
}

function convertArg(Node\Arg $arg): array
{
    $converted = convertExpr($arg->value);
    if ($arg->name !== null) {
        return [
            'kind'     => 'xnkArgument',
            'argName'  => $arg->name->toString(),
            'argValue' => $converted,
        ];
    }
    return $converted;
}

// ===========================================================================
// Parameter conversion
// ===========================================================================
function convertParam(Node\Param $param): array
{
    $result = [
        'kind'         => 'xnkParameter',
        'paramName'    => $param->var->name,
        'paramType'    => $param->type !== null ? convertTypeNode($param->type) : null,
        'defaultValue' => $param->default !== null ? convertExpr($param->default) : null,
    ];

    // Track variadic params
    if ($param->variadic) {
        $result['extIsVariadic'] = true;
    }

    // Track pass-by-reference
    if ($param->byRef) {
        $result['extIsByRef'] = true;
    }

    return $result;
}

// ===========================================================================
// Type node conversion
// ===========================================================================
function convertTypeNode(Node $type): array
{
    if ($type instanceof Name) {
        return convertNameNode($type);
    }

    if ($type instanceof Node\Identifier) {
        return ['kind' => 'xnkNamedType', 'typeName' => $type->toString()];
    }

    // Nullable type (?Type)
    if ($type instanceof Node\NullableType) {
        return [
            'kind'            => 'xnkGenericType',
            'genericTypeName' => 'Nullable',
            'genericArgs'     => [convertTypeNode($type->type)],
        ];
    }

    // Union type (A|B)
    if ($type instanceof Node\UnionType) {
        return [
            'kind'       => 'xnkUnionType',
            'unionTypes' => array_map(fn($t) => convertTypeNode($t), $type->types),
        ];
    }

    // Intersection type (A&B)
    if ($type instanceof Node\IntersectionType) {
        return [
            'kind'        => 'xnkIntersectionType',
            'typeMembers' => array_map(fn($t) => convertTypeNode($t), $type->types),
        ];
    }

    return ['kind' => 'xnkNamedType', 'typeName' => 'unknown'];
}

// ===========================================================================
// Name node helpers
// ===========================================================================
function convertNameNode(Name $name): array
{
    return ['kind' => 'xnkNamedType', 'typeName' => $name->toString()];
}

function nameToString(Name $name): string
{
    return $name->toString();
}

// ===========================================================================
// Block conversion
// ===========================================================================
function convertBlock(array $stmts): array
{
    $body = [];
    foreach ($stmts as $stmt) {
        $converted = convertStmt($stmt);
        if ($converted !== null) {
            $body[] = $converted;
        }
    }
    return [
        'kind'      => 'xnkBlockStmt',
        'blockBody' => $body,
    ];
}

// ===========================================================================
// Visibility helpers
// ===========================================================================
function extractVisibility(int $flags): string
{
    if ($flags & Stmt\Class_::MODIFIER_PUBLIC) {
        return 'public';
    }
    if ($flags & Stmt\Class_::MODIFIER_PROTECTED) {
        return 'protected';
    }
    if ($flags & Stmt\Class_::MODIFIER_PRIVATE) {
        return 'private';
    }
    return 'public'; // PHP default is public
}

// ===========================================================================
// Entry point
// ===========================================================================
main($argv);
