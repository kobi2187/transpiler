#!/bin/bash
# Regression test runner for transpiler
# Tests that bug fixes remain working by checking for expected patterns

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSPILER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REGRESSION_DIR="$SCRIPT_DIR/regression"
PARSER="$TRANSPILER_DIR/src/parsers/csharp/bin/Debug/net8.0/csharp-to-xlang"
TRANSPILER="$TRANSPILER_DIR/main"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

passed=0
failed=0
total=0

echo "Running regression tests..."
echo

# Function to run a single test
run_test() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .cs)
    local expected_file="$REGRESSION_DIR/${test_name}.expected.nim"

    echo -n "Testing $test_name... "
    total=$((total + 1))

    # Check if expected file exists
    if [ ! -f "$expected_file" ]; then
        echo -e "${YELLOW}SKIPPED${NC} (no expected output file)"
        total=$((total - 1))
        return 0
    fi

    # Create output files with persistent names
    local xljs_file="$REGRESSION_DIR/${test_name}.xljs"
    local nim_file="$REGRESSION_DIR/${test_name}.generated.nim"

    # Parse C# to XLang
    if ! "$PARSER" "$test_file" "$xljs_file" > "$xljs_file" 2>&1; then
        echo -e "${RED}FAILED${NC} (parser error)"
        failed=$((failed + 1))
        return 1
    fi

    # Transpile XLang to Nim
    if ! "$TRANSPILER" "$xljs_file" --stdout > "$nim_file" 2>&1; then
        echo -e "${RED}FAILED${NC} (transpiler error)"
        failed=$((failed + 1))
        return 1
    fi

    # Check that all expected patterns are present in the output
    local all_found=true
    local missing_patterns=""

    # Read expected file line by line, skip comments and empty lines
    while IFS= read -r expected_line; do
        # Skip comment lines and empty lines
        if [[ "$expected_line" =~ ^[[:space:]]*# ]] || [[ -z "${expected_line// }" ]]; then
            continue
        fi

        # Check if this pattern exists in the generated file
        if ! grep -qF "$expected_line" "$nim_file"; then
            all_found=false
            missing_patterns+="  - $expected_line\n"
        fi
    done < "$expected_file"

    if [ "$all_found" = true ]; then
        echo -e "${GREEN}PASSED${NC}"
        passed=$((passed + 1))
    else
        echo -e "${RED}FAILED${NC}"
        echo -e "${RED}Missing expected patterns:${NC}"
        echo -e "$missing_patterns"
        failed=$((failed + 1))
    fi

    # Keep generated files for inspection (don't cleanup)
}

# Run all tests
for test_file in "$REGRESSION_DIR"/*.cs; do
    if [ -f "$test_file" ]; then
        run_test "$test_file"
    fi
done

echo
echo "=========================================="
echo "Results: $passed passed, $failed failed out of $total tests"
echo "=========================================="

if [ $failed -gt 0 ]; then
    exit 1
else
    exit 0
fi
