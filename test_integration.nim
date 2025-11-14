import json
import macros
import xlangtypes
import jsontoxlangtypes
import xlangtonim_complete
import nimastToCode
import src/transforms/pass_manager
import src/transforms/nim_passes
import options

## End-to-End Integration Tests
##
## Tests the full pipeline:
## JSON → XLang → Transformations → Nim AST → Nim Code

proc testSimpleFunction() =
  echo "=== Integration Test 1: Simple Function ==="
  echo ""

  # Create JSON representation of a simple function
  let jsonAst = %* {
    "kind": "xnkFuncDecl",
    "funcName": "add",
    "params": [
      {
        "kind": "xnkParameter",
        "paramName": "a",
        "paramType": {
          "kind": "xnkNamedType",
          "typeName": "int"
        }
      },
      {
        "kind": "xnkParameter",
        "paramName": "b",
        "paramType": {
          "kind": "xnkNamedType",
          "typeName": "int"
        }
      }
    ],
    "returnType": {
      "kind": "xnkNamedType",
      "typeName": "int"
    },
    "body": {
      "kind": "xnkBlockStmt",
      "blockBody": [
        {
          "kind": "xnkReturnStmt",
          "returnValue": {
            "kind": "xnkBinaryExpr",
            "binaryOp": "+",
            "binaryLeft": {
              "kind": "xnkIdentifier",
              "identName": "a"
            },
            "binaryRight": {
              "kind": "xnkIdentifier",
              "identName": "b"
            }
          }
        }
      ]
    },
    "isPublic": true
  }

  echo "Step 1: JSON input"
  echo jsonAst.pretty
  echo ""

  # Parse JSON to XLang
  let xlangAst = parseXLangJsonString($jsonAst)
  echo "Step 2: XLang AST created ✓"
  echo "  Node kind: ", xlangAst.kind
  echo "  Function name: ", xlangAst.funcName
  echo ""

  # No transformations needed for this simple function
  echo "Step 3: No transformations needed (simple function)"
  echo ""

  # Convert to Nim AST
  let nimAst = convertXLangToNim(xlangAst)
  echo "Step 4: Nim AST created ✓"
  echo ""

  # Generate Nim code
  let nimCode = generateNimCode(nimAst)
  echo "Step 5: Generated Nim code:"
  echo nimCode
  echo ""

proc testForLoopTransformation() =
  echo "=== Integration Test 2: C-Style For Loop → While ==="
  echo ""

  # Create JSON for: for (i = 0; i < 10; i++) { echo(i) }
  let jsonAst = %* {
    "kind": "xnkForStmt",
    "forInit": {
      "kind": "xnkVarDecl",
      "varName": "i",
      "varValue": {
        "kind": "xnkIntLit",
        "literalValue": "0"
      }
    },
    "forCondition": {
      "kind": "xnkBinaryExpr",
      "binaryOp": "<",
      "binaryLeft": {
        "kind": "xnkIdentifier",
        "identName": "i"
      },
      "binaryRight": {
        "kind": "xnkIntLit",
        "literalValue": "10"
      }
    },
    "forUpdate": {
      "kind": "xnkCallExpr",
      "callFunc": {
        "kind": "xnkIdentifier",
        "identName": "inc"
      },
      "callArgs": [
        {
          "kind": "xnkIdentifier",
          "identName": "i"
        }
      ]
    },
    "forBody": {
      "kind": "xnkBlockStmt",
      "blockBody": [
        {
          "kind": "xnkCallExpr",
          "callFunc": {
            "kind": "xnkIdentifier",
            "identName": "echo"
          },
          "callArgs": [
            {
              "kind": "xnkIdentifier",
              "identName": "i"
            }
          ]
        }
      ]
    }
  }

  echo "Step 1: JSON input (C-style for loop)"
  echo ""

  # Parse JSON to XLang
  var xlangAst = parseXLangJsonString($jsonAst)
  echo "Step 2: XLang AST created ✓"
  echo "  Node kind: ", xlangAst.kind
  echo ""

  # Apply transformations
  echo "Step 3: Applying transformations..."
  let pm = createNimPassManager()
  xlangAst = pm.runPasses(xlangAst)
  echo "  ✓ Transformations complete"
  echo "  Transformed to: ", xlangAst.kind
  echo ""

  # Convert to Nim AST
  let nimAst = convertXLangToNim(xlangAst)
  echo "Step 4: Nim AST created ✓"
  echo ""

  # Generate Nim code
  let nimCode = generateNimCode(nimAst)
  echo "Step 5: Generated Nim code (should be while loop):"
  echo nimCode
  echo ""

proc testComplexTransformations() =
  echo "=== Integration Test 3: Multiple Transformations ==="
  echo ""

  # Create function with both C-style for and ternary operator
  # for (i = 0; i < 10; i++) { result = i > 5 ? "big" : "small" }
  let jsonAst = %* {
    "kind": "xnkFuncDecl",
    "funcName": "classify",
    "params": [],
    "returnType": {
      "kind": "xnkNamedType",
      "typeName": "void"
    },
    "body": {
      "kind": "xnkBlockStmt",
      "blockBody": [
        {
          "kind": "xnkForStmt",
          "forInit": {
            "kind": "xnkVarDecl",
            "varName": "i",
            "varValue": {
              "kind": "xnkIntLit",
              "literalValue": "0"
            }
          },
          "forCondition": {
            "kind": "xnkBinaryExpr",
            "binaryOp": "<",
            "binaryLeft": {
              "kind": "xnkIdentifier",
              "identName": "i"
            },
            "binaryRight": {
              "kind": "xnkIntLit",
              "literalValue": "10"
            }
          },
          "forUpdate": {
            "kind": "xnkCallExpr",
            "callFunc": {
              "kind": "xnkIdentifier",
              "identName": "inc"
            },
            "callArgs": [
              {
                "kind": "xnkIdentifier",
                "identName": "i"
              }
            ]
          },
          "forBody": {
            "kind": "xnkBlockStmt",
            "blockBody": [
              {
                "kind": "xnkCallExpr",
                "callFunc": {
                  "kind": "xnkIdentifier",
                  "identName": "echo"
                },
                "callArgs": [
                  {
                    "kind": "xnkTernaryExpr",
                    "ternaryCondition": {
                      "kind": "xnkBinaryExpr",
                      "binaryOp": ">",
                      "binaryLeft": {
                        "kind": "xnkIdentifier",
                        "identName": "i"
                      },
                      "binaryRight": {
                        "kind": "xnkIntLit",
                        "literalValue": "5"
                      }
                    },
                    "ternaryThen": {
                      "kind": "xnkStringLit",
                      "literalValue": "big"
                    },
                    "ternaryElse": {
                      "kind": "xnkStringLit",
                      "literalValue": "small"
                    }
                  }
                ]
              }
            ]
          }
        }
      ]
    }
  }

  echo "Step 1: JSON input (function with for loop + ternary)"
  echo ""

  # Parse JSON to XLang
  var xlangAst = parseXLangJsonString($jsonAst)
  echo "Step 2: XLang AST created ✓"
  echo "  Node kind: ", xlangAst.kind
  echo ""

  # Apply transformations
  echo "Step 3: Applying transformations..."
  let pm = createNimPassManager()
  echo "  Registered passes:"
  for pass in pm.listPasses():
    echo "    ", pass
  echo ""

  xlangAst = pm.runPasses(xlangAst)
  echo "  ✓ All transformations complete"
  echo ""

  # Convert to Nim AST
  let nimAst = convertXLangToNim(xlangAst)
  echo "Step 4: Nim AST created ✓"
  echo ""

  # Generate Nim code
  let nimCode = generateNimCode(nimAst)
  echo "Step 5: Generated Nim code:"
  echo "  (for → while, ternary → if expression)"
  echo nimCode
  echo ""

when isMainModule:
  echo "╔════════════════════════════════════════════════════════╗"
  echo "║          End-to-End Integration Tests                 ║"
  echo "║    JSON → XLang → Transform → Nim AST → Code          ║"
  echo "╚════════════════════════════════════════════════════════╝"
  echo ""

  testSimpleFunction()
  testForLoopTransformation()
  testComplexTransformations()

  echo "╔════════════════════════════════════════════════════════╗"
  echo "║        All Integration Tests Complete                 ║"
  echo "╚════════════════════════════════════════════════════════╝"
