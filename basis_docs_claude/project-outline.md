# Multi-Language to Nim Transpiler Project

## Overview
A two-stage fully automatic transpiler from high-level programming languages to Nim, using an intermediate AST layer called XLang.

## Input Languages
- Go
- Python
- C#

## Stages
1. Input Language to JSON AST
2. JSON AST to XLang AST
3. XLang AST Transformation
4. XLang AST to Nim AST
5. Nim AST to Nim Code

## Key Components
- XLang: A superset AST format encompassing all input language constructs
- Language-specific first stage parsers
- Nim-based second stage processor

## Process Flow
1. Parse input language using its native AST library
2. Generate JSON AST file for each code file
3. Convert JSON AST to XLang AST
4. Transform XLang AST to accommodate Nim features
5. Convert XLang AST to Nim AST
6. Generate Nim code from Nim AST
