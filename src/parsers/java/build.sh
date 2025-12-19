#!/bin/bash

# Java to XLang Parser Build Script
# Requires: Java 11+, JavaParser library, Jackson JSON library

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==================================="
echo "Java to XLang Parser Build Script"
echo "==================================="

# Download dependencies if not present
JAVAPARSER_VERSION="3.25.7"
JACKSON_VERSION="2.16.0"

LIB_DIR="lib"
mkdir -p "$LIB_DIR"

download_if_missing() {
    local file="$1"
    local url="$2"

    if [ ! -f "$LIB_DIR/$file" ]; then
        echo "Downloading $file..."
        curl -L -o "$LIB_DIR/$file" "$url"
    else
        echo "✓ $file already exists"
    fi
}

echo ""
echo "Checking dependencies..."
download_if_missing "javaparser-core-${JAVAPARSER_VERSION}.jar" \
    "https://repo1.maven.org/maven2/com/github/javaparser/javaparser-core/${JAVAPARSER_VERSION}/javaparser-core-${JAVAPARSER_VERSION}.jar"

download_if_missing "jackson-databind-${JACKSON_VERSION}.jar" \
    "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/${JACKSON_VERSION}/jackson-databind-${JACKSON_VERSION}.jar"

download_if_missing "jackson-core-${JACKSON_VERSION}.jar" \
    "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/${JACKSON_VERSION}/jackson-core-${JACKSON_VERSION}.jar"

download_if_missing "jackson-annotations-${JACKSON_VERSION}.jar" \
    "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/${JACKSON_VERSION}/jackson-annotations-${JACKSON_VERSION}.jar"

echo ""
echo "Building JavaToXLangParser..."

# Build classpath
CLASSPATH="$LIB_DIR/javaparser-core-${JAVAPARSER_VERSION}.jar"
CLASSPATH="$CLASSPATH:$LIB_DIR/jackson-databind-${JACKSON_VERSION}.jar"
CLASSPATH="$CLASSPATH:$LIB_DIR/jackson-core-${JACKSON_VERSION}.jar"
CLASSPATH="$CLASSPATH:$LIB_DIR/jackson-annotations-${JACKSON_VERSION}.jar"

# Compile
javac -cp "$CLASSPATH" JavaToXLangParser.java

echo "✓ Build successful!"
echo ""
echo "Usage:"
echo "  ./run.sh <java_file>"
echo ""
