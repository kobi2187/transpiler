#!/bin/bash
# Build script for Kotlin to XLang parser

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Building Kotlin to XLang parser..."

# Check if gradle wrapper exists, if not create it
if [ ! -f "gradlew" ]; then
    echo "Creating Gradle wrapper..."
    gradle wrapper --gradle-version 8.5
fi

# Build the fat JAR
./gradlew jar --no-daemon

echo "Build complete!"
echo "JAR location: build/libs/kotlin-to-xlang-1.0.0.jar"
