#!/usr/bin/env php
<?php
/**
 * PHPT Extractor & Parser Error Reporter
 *
 * 1. Scans a directory tree for .phpt files (PHP test files from php-src)
 * 2. Extracts the <?php ... ?> code from the --FILE-- section
 * 3. Saves extracted PHP files into an output directory
 * 4. Runs the php_to_xlang.php parser on each extracted file
 * 5. Collects and reports statistics on parse errors and unknown constructs
 *
 * Usage:
 *   php phpt_extract_and_report.php <phpt-source-dir> [output-dir]
 *
 * Example:
 *   php phpt_extract_and_report.php ../../php-src extracted_tests
 */

require __DIR__ . '/vendor/autoload.php';

// We re-use the parser's internals by including it and overriding main()
// Instead, we load the parser functions directly.

use PhpParser\Error;
use PhpParser\Node;
use PhpParser\Node\Stmt;
use PhpParser\Node\Expr;
use PhpParser\Node\Scalar;
use PhpParser\Node\Name;
use PhpParser\ParserFactory;

// ============================================================================
// Configuration
// ============================================================================
$MAX_FILES = 0; // 0 = no limit

// ============================================================================
// Statistics tracking
// ============================================================================
$stats = [
    'phpt_found'       => 0,
    'extracted'        => 0,
    'extract_skipped'  => 0,
    'parse_success'    => 0,
    'parse_error'      => 0,
    'convert_success'  => 0,
    'convert_error'    => 0,
];

$unknownConstructs  = [];  // key => count
$unknownSamples     = [];  // key => [{file, line, source}, ...]
$parseErrors        = [];  // [{file, error}, ...]
$convertErrors      = [];  // [{file, error}, ...]
$currentFilePath    = '';

// ============================================================================
// Unknown construct tracker (mirrors the one in php_to_xlang.php)
// ============================================================================
function trackUnknown(string $context, Node $node): array
{
    global $unknownConstructs, $unknownSamples, $currentFilePath;

    $nodeType = $node->getType();
    $key      = "$context:$nodeType";

    $unknownConstructs[$key] = ($unknownConstructs[$key] ?? 0) + 1;

    if (!isset($unknownSamples[$key])) {
        $unknownSamples[$key] = [];
    }
    if (count($unknownSamples[$key]) < 5) {
        try {
            $prettyPrinter = new PhpParser\PrettyPrinter\Standard();
            $source        = $prettyPrinter->prettyPrint([$node]);
        } catch (\Throwable $e) {
            $source = '(could not pretty-print)';
        }
        $unknownSamples[$key][] = [
            'file'   => $currentFilePath,
            'line'   => $node->getStartLine(),
            'source' => mb_substr($source, 0, 300),
        ];
    }

    return [
        'kind'        => 'xnkUnknown',
        'unknownData' => mb_substr("$context:$nodeType", 0, 100),
    ];
}

// ============================================================================
// Include the parser's conversion functions
// ============================================================================
// We need to load the parser functions without running main().
// The simplest approach: we source the file's functions directly.
// Since php_to_xlang.php calls main($argv) at the bottom, we need to
// handle that. Let's just load all conversion functions ourselves.

// We'll load the parser file as a string, extract just the functions,
// and eval them... Actually that's fragile. Better approach: include the
// file but prevent main() from running by checking a constant.

// Even better: let's just copy the core logic. But that duplicates code.
// Best approach: modify nothing, just shell out to the parser and capture
// its unknown-construct output. But that loses structured data.

// Pragmatic approach: source the file with an include guard.
define('PHPT_REPORTER_MODE', true);

// We'll load the conversion functions by including a modified bootstrap.
// Actually, the cleanest way: just load the file as a string, strip the
// main() call at the bottom, and eval the rest.

$parserSource = file_get_contents(__DIR__ . '/php_to_xlang.php');
// Remove the shebang line
$parserSource = preg_replace('/^#!.*\n/', '', $parserSource);
// Remove the main() call at the bottom
$parserSource = preg_replace('/^main\(\$argv\);\s*$/m', '// main() disabled by reporter', $parserSource);
// Remove the opening <?php tag (eval doesn't want it)
$parserSource = preg_replace('/^<\?php\s*/', '', $parserSource);
// Remove the require autoload (we already loaded it)
$parserSource = preg_replace('/^require\s+__DIR__.*autoload\.php.*;\s*$/m', '// autoload disabled by reporter', $parserSource);
// Remove the trackUnknown function (we define our own)
$parserSource = preg_replace(
    '/^function trackUnknown\(.*?\n\}\s*$/ms',
    '// trackUnknown replaced by reporter',
    $parserSource
);

eval($parserSource);

// ============================================================================
// PHPT extraction
// ============================================================================
function extractPhpFromPhpt(string $phptPath): ?string
{
    $content = file_get_contents($phptPath);
    if ($content === false) {
        return null;
    }

    // Find the --FILE-- section
    $fileStart = strpos($content, '--FILE--');
    if ($fileStart === false) {
        return null;
    }

    // Move past the --FILE-- marker line
    $codeStart = strpos($content, "\n", $fileStart);
    if ($codeStart === false) {
        return null;
    }
    $codeStart++; // skip the newline

    // Find the next section marker (--EXPECT--, --EXPECTF--, --EXPECTREGEX--, etc.)
    // Section markers are lines that match --WORD-- at the start of a line
    if (preg_match('/\n--[A-Z_]+--\s*\n/s', $content, $matches, PREG_OFFSET_CAPTURE, $codeStart)) {
        $codeEnd = $matches[0][1];
    } else {
        $codeEnd = strlen($content);
    }

    $phpCode = substr($content, $codeStart, $codeEnd - $codeStart);
    $phpCode = rtrim($phpCode) . "\n";

    // Skip files that don't contain PHP code (some .phpt files test other things)
    if (strpos($phpCode, '<?php') === false && strpos($phpCode, '<?=') === false) {
        return null;
    }

    return $phpCode;
}

// ============================================================================
// Main
// ============================================================================
function reporterMain(array $argv): void
{
    global $stats, $unknownConstructs, $unknownSamples, $parseErrors, $convertErrors;
    global $currentFilePath, $MAX_FILES;

    if (count($argv) < 2) {
        fwrite(STDERR, "Usage: php phpt_extract_and_report.php <phpt-source-dir> [output-dir]\n");
        fwrite(STDERR, "\nExample:\n");
        fwrite(STDERR, "  php phpt_extract_and_report.php ../../php-src extracted_tests\n");
        exit(1);
    }

    $sourceDir = rtrim($argv[1], '/');
    $outputDir = $argv[2] ?? __DIR__ . '/extracted_tests';

    if (!is_dir($sourceDir)) {
        fwrite(STDERR, "Error: Source directory not found: $sourceDir\n");
        exit(1);
    }

    // Create output directory
    if (!is_dir($outputDir)) {
        mkdir($outputDir, 0755, true);
    }

    echo "=== PHPT Extractor & Parser Error Reporter ===\n\n";
    echo "Source:  $sourceDir\n";
    echo "Output:  $outputDir\n\n";

    // ---- Phase 1: Find and extract .phpt files ----
    echo "Phase 1: Extracting PHP code from .phpt files...\n";

    $iter = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($sourceDir, RecursiveDirectoryIterator::SKIP_DOTS)
    );

    $phptFiles = [];
    foreach ($iter as $file) {
        if ($file->isFile() && $file->getExtension() === 'phpt') {
            $phptFiles[] = $file->getPathname();
        }
    }
    sort($phptFiles);
    $stats['phpt_found'] = count($phptFiles);
    echo "  Found {$stats['phpt_found']} .phpt files\n";

    if ($MAX_FILES > 0) {
        $phptFiles = array_slice($phptFiles, 0, $MAX_FILES);
        echo "  (Limited to $MAX_FILES files)\n";
    }

    $extractedFiles = [];
    foreach ($phptFiles as $phptPath) {
        $phpCode = extractPhpFromPhpt($phptPath);
        if ($phpCode === null) {
            $stats['extract_skipped']++;
            continue;
        }

        // Create a unique output filename preserving some path info
        $relPath   = str_replace($sourceDir . '/', '', $phptPath);
        $flatName  = str_replace(['/', '\\'], '__', $relPath);
        $flatName  = preg_replace('/\.phpt$/', '.php', $flatName);
        $outPath   = $outputDir . '/' . $flatName;

        file_put_contents($outPath, $phpCode);
        $extractedFiles[] = $outPath;
        $stats['extracted']++;
    }

    echo "  Extracted: {$stats['extracted']}\n";
    echo "  Skipped (no --FILE-- or no PHP): {$stats['extract_skipped']}\n\n";

    // ---- Phase 2: Parse each extracted file ----
    echo "Phase 2: Parsing extracted files through php_to_xlang...\n";

    $parser    = (new ParserFactory())->createForNewestSupportedVersion();
    $total     = count($extractedFiles);
    $milestone = max(1, intdiv($total, 20)); // report every 5%

    foreach ($extractedFiles as $i => $phpFile) {
        $currentFilePath = $phpFile;

        if (($i + 1) % $milestone === 0 || $i === $total - 1) {
            $pct = round(($i + 1) / $total * 100);
            echo "  Progress: " . ($i + 1) . "/$total ({$pct}%)\n";
        }

        // Step 1: PHP-Parser parse
        $sourceCode = file_get_contents($phpFile);
        try {
            $ast = $parser->parse($sourceCode);
        } catch (Error $error) {
            $stats['parse_error']++;
            $parseErrors[] = [
                'file'  => basename($phpFile),
                'error' => $error->getMessage(),
            ];
            continue;
        } catch (\Throwable $error) {
            $stats['parse_error']++;
            $parseErrors[] = [
                'file'  => basename($phpFile),
                'error' => $error->getMessage(),
            ];
            continue;
        }

        if ($ast === null) {
            $stats['parse_error']++;
            $parseErrors[] = [
                'file'  => basename($phpFile),
                'error' => 'Parser returned null',
            ];
            continue;
        }
        $stats['parse_success']++;

        // Step 2: Convert to xlang
        try {
            $xlangNode = convertFile($ast, $phpFile);
            $stats['convert_success']++;
        } catch (\Throwable $error) {
            $stats['convert_error']++;
            $convertErrors[] = [
                'file'  => basename($phpFile),
                'error' => $error->getMessage(),
                'trace' => $error->getTraceAsString(),
            ];
        }
    }

    echo "\n";

    // ---- Phase 3: Report ----
    printReport();
}

function printReport(): void
{
    global $stats, $unknownConstructs, $unknownSamples, $parseErrors, $convertErrors;

    echo str_repeat('=', 72) . "\n";
    echo "                    PARSER COVERAGE REPORT\n";
    echo str_repeat('=', 72) . "\n\n";

    // Overview
    echo "--- Overview ---\n";
    echo sprintf("  .phpt files found:        %6d\n", $stats['phpt_found']);
    echo sprintf("  Extracted to .php:        %6d\n", $stats['extracted']);
    echo sprintf("  Skipped (no PHP code):    %6d\n", $stats['extract_skipped']);
    echo "\n";
    echo sprintf("  PHP parse successes:      %6d\n", $stats['parse_success']);
    echo sprintf("  PHP parse errors:         %6d\n", $stats['parse_error']);
    echo sprintf("  XLang convert successes:  %6d\n", $stats['convert_success']);
    echo sprintf("  XLang convert errors:     %6d\n", $stats['convert_error']);
    echo "\n";

    $totalParsed = $stats['parse_success'];
    if ($totalParsed > 0) {
        $convertRate = round($stats['convert_success'] / $totalParsed * 100, 1);
        echo "  Conversion success rate:  {$convertRate}%\n";
    }

    $totalUnknown = array_sum($unknownConstructs);
    echo sprintf("  Total unknown nodes:      %6d\n", $totalUnknown);
    echo sprintf("  Distinct unknown kinds:   %6d\n", count($unknownConstructs));
    echo "\n";

    // Unknown constructs ranked by frequency
    if (!empty($unknownConstructs)) {
        arsort($unknownConstructs);
        echo str_repeat('-', 72) . "\n";
        echo "UNKNOWN/MISSING CONSTRUCTS (ranked by frequency)\n";
        echo str_repeat('-', 72) . "\n";
        echo sprintf("  %-50s %s\n", "CONSTRUCT", "COUNT");
        echo sprintf("  %-50s %s\n", str_repeat('-', 50), str_repeat('-', 8));

        $rank = 0;
        foreach ($unknownConstructs as $key => $count) {
            $rank++;
            echo sprintf("  %3d. %-46s %6d\n", $rank, $key, $count);
        }
        echo "\n";

        // Detailed samples for top unknowns
        echo str_repeat('-', 72) . "\n";
        echo "DETAILED SAMPLES (top 20 unknown constructs)\n";
        echo str_repeat('-', 72) . "\n";

        $shown = 0;
        foreach ($unknownConstructs as $key => $count) {
            if (++$shown > 20) break;

            echo "\n  [$shown] $key ($count occurrences)\n";
            if (isset($unknownSamples[$key])) {
                foreach (array_slice($unknownSamples[$key], 0, 3) as $j => $sample) {
                    echo "      Sample " . ($j + 1) . ": {$sample['file']}:{$sample['line']}\n";
                    $lines = explode("\n", $sample['source']);
                    foreach (array_slice($lines, 0, 5) as $line) {
                        echo "        | " . rtrim($line) . "\n";
                    }
                }
            }
        }
        echo "\n";
    }

    // Convert errors (crashes during conversion)
    if (!empty($convertErrors)) {
        echo str_repeat('-', 72) . "\n";
        echo "CONVERSION ERRORS (crashes during XLang conversion)\n";
        echo str_repeat('-', 72) . "\n";

        // Group by error message
        $grouped = [];
        foreach ($convertErrors as $err) {
            $msgKey = preg_replace('/in \/.*?:\d+/', 'in <file>', $err['error']);
            $msgKey = mb_substr($msgKey, 0, 120);
            if (!isset($grouped[$msgKey])) {
                $grouped[$msgKey] = ['count' => 0, 'samples' => []];
            }
            $grouped[$msgKey]['count']++;
            if (count($grouped[$msgKey]['samples']) < 3) {
                $grouped[$msgKey]['samples'][] = $err;
            }
        }

        uasort($grouped, fn($a, $b) => $b['count'] <=> $a['count']);

        foreach ($grouped as $msg => $data) {
            echo "\n  [{$data['count']}x] $msg\n";
            foreach ($data['samples'] as $sample) {
                echo "      File: {$sample['file']}\n";
            }
        }
        echo "\n";
    }

    // Parse errors (PHP syntax errors - expected for some test files)
    if (!empty($parseErrors)) {
        echo str_repeat('-', 72) . "\n";
        echo "PHP PARSE ERRORS ({$stats['parse_error']} files - expected for intentional syntax error tests)\n";
        echo str_repeat('-', 72) . "\n";

        // Group by error pattern
        $grouped = [];
        foreach ($parseErrors as $err) {
            $msgKey = preg_replace('/on line \d+/', 'on line N', $err['error']);
            $msgKey = mb_substr($msgKey, 0, 100);
            if (!isset($grouped[$msgKey])) {
                $grouped[$msgKey] = 0;
            }
            $grouped[$msgKey]++;
        }
        arsort($grouped);

        echo sprintf("  %-70s %s\n", "ERROR PATTERN", "COUNT");
        echo sprintf("  %-70s %s\n", str_repeat('-', 70), str_repeat('-', 6));
        foreach (array_slice($grouped, 0, 30, true) as $msg => $count) {
            echo sprintf("  %-70s %5d\n", $msg, $count);
        }
        echo "\n";
    }

    // Priority fix list
    if (!empty($unknownConstructs) || !empty($convertErrors)) {
        echo str_repeat('=', 72) . "\n";
        echo "FIXING PRIORITIES\n";
        echo str_repeat('=', 72) . "\n\n";

        // Combine unknowns and convert errors into a priority list
        $priorities = [];

        foreach ($unknownConstructs as $key => $count) {
            $priorities[] = [
                'type'  => 'unknown',
                'key'   => $key,
                'count' => $count,
                'desc'  => "Add handler for $key",
            ];
        }

        // Add convert error groups
        $errorGroups = [];
        foreach ($convertErrors as $err) {
            $msgKey = preg_replace('/in \/.*?:\d+/', '', $err['error']);
            $msgKey = mb_substr($msgKey, 0, 80);
            $errorGroups[$msgKey] = ($errorGroups[$msgKey] ?? 0) + 1;
        }
        foreach ($errorGroups as $msg => $count) {
            $priorities[] = [
                'type'  => 'crash',
                'key'   => $msg,
                'count' => $count,
                'desc'  => "Fix crash: $msg",
            ];
        }

        usort($priorities, fn($a, $b) => $b['count'] <=> $a['count']);

        echo "  Priority  Type     Count  Description\n";
        echo "  " . str_repeat('-', 68) . "\n";

        foreach ($priorities as $i => $p) {
            $pri  = $i + 1;
            $type = strtoupper($p['type']);
            echo sprintf("  %4d.     %-8s %5d  %s\n", $pri, $type, $p['count'], $p['desc']);
        }
        echo "\n";
    }

    if (empty($unknownConstructs) && empty($convertErrors)) {
        echo "  *** ALL CONSTRUCTS HANDLED - NO GAPS DETECTED ***\n\n";
    }
}

reporterMain($argv);
