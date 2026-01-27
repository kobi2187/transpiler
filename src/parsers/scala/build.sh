#!/bin/bash

set -e

echo "Building Scala to XLang Parser..."
echo "=================================="
echo ""

# Check if sbt is installed
if ! command -v sbt &> /dev/null; then
    echo "Error: sbt is not installed"
    echo "Please install sbt from https://www.scala-sbt.org/download.html"
    echo ""
    echo "On Ubuntu/Debian:"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install apt-transport-https curl gnupg -yqq"
    echo "  echo \"deb https://repo.scala-sbt.org/scalasbt/debian all main\" | sudo tee /etc/apt/sources.list.d/sbt.list"
    echo "  echo \"deb https://repo.scala-sbt.org/scalasbt/debian /\" | sudo tee /etc/apt/sources.list.d/sbt_old.list"
    echo "  curl -sL \"https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823\" | sudo -H gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import"
    echo "  sudo chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install sbt"
    exit 1
fi

echo "Using sbt: $(sbt --version | head -n1)"
echo ""

# Compile and create fat JAR with all dependencies
echo "Compiling Scala source and creating fat JAR..."
sbt clean assembly

echo ""
echo "Build complete!"
echo "Fat JAR created at: target/scala-2.13/scala-to-xlang.jar"
echo ""
echo "You can now use ./run.sh to run the parser"
