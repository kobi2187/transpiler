#!/bin/bash
# Run script for Kotlin to XLang parser
# Usage: ./run.sh <kotlin_file_path>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAR_PATH="$SCRIPT_DIR/build/libs/kotlin-to-xlang-1.0.0.jar"

if [ ! -f "$JAR_PATH" ]; then
    echo "Error: JAR not found. Please run build.sh first." >&2
    exit 1
fi

if [ -z "$1" ]; then
    echo "Usage: $0 <kotlin_file_path>" >&2
    exit 1
fi

java -jar "$JAR_PATH" "$1"
