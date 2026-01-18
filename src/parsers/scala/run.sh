#!/bin/bash

set -e

JAR_PATH="target/scala-2.13/scala-to-xlang.jar"

if [ ! -f "$JAR_PATH" ]; then
    echo "Error: JAR file not found at $JAR_PATH"
    echo "Please run ./build.sh first"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Usage: ./run.sh <scala_file_or_directory>"
    exit 1
fi

java -jar "$JAR_PATH" "$@"
