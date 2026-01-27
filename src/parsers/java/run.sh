#!/bin/bash

# Java to XLang Parser Run Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <java_file_or_directory>"
    exit 1
fi

INPUT_PATH="$1"

if [ ! -e "$INPUT_PATH" ]; then
    echo "Error: Path not found: $INPUT_PATH"
    exit 1
fi

# Build classpath
JAVAPARSER_VERSION="3.25.7"
JACKSON_VERSION="2.16.0"
LIB_DIR="lib"

CLASSPATH=".:$LIB_DIR/javaparser-core-${JAVAPARSER_VERSION}.jar"
CLASSPATH="$CLASSPATH:$LIB_DIR/jackson-databind-${JACKSON_VERSION}.jar"
CLASSPATH="$CLASSPATH:$LIB_DIR/jackson-core-${JACKSON_VERSION}.jar"
CLASSPATH="$CLASSPATH:$LIB_DIR/jackson-annotations-${JACKSON_VERSION}.jar"

# Check if compiled
if [ ! -f "JavaToXLangParser.class" ]; then
    echo "Parser not compiled. Running build.sh..."
    ./build.sh
fi

# Run parser
java -cp "$CLASSPATH" JavaToXLangParser "$INPUT_PATH"
