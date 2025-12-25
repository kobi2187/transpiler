## Common test infrastructure for transformation passes
## Provides utilities for testing that transforms eliminate external kinds

import std/json
import std/tables
import std/sets
import ../jsontoxlangtypes
import ../xlangtypes
import ../src/transforms/helpers
import ../src/transforms/nim_passes
import ../src/transforms/types

proc testTransformEliminatesKind*(
  jsonSample: string,
  passId: TransformPassID,
  expectedExternalKind: XLangNodeKind
): bool =
  ## Test that a transform eliminates the expected external kind
  ## Returns true if successful, false otherwise

  # Parse JSON to XLang
  var node = jsonSample.parseJson().to(XLangNode)

  # Verify input has the external kind
  let kindsBefore = collectAllKinds(node)
  if expectedExternalKind notin kindsBefore:
    echo "  ERROR: Input does not contain expected kind ", expectedExternalKind
    return false

  # Apply transform
  let registry = buildNimPassRegistry()
  if not registry.hasKey(passId):
    echo "  ERROR: Transform ", passId, " not found in registry"
    return false

  let transform = registry.getOrDefault(passId)
  node = transform.transform(node)

  # Verify external kind was eliminated
  let kindsAfter = collectAllKinds(node)
  if expectedExternalKind in kindsAfter:
    echo "  FAILED: External kind ", expectedExternalKind, " still present after transform"
    echo "  Kinds before: ", kindsBefore
    echo "  Kinds after: ", kindsAfter
    return false

  return true

proc parseXLangJson*(jsonStr: string): XLangNode =
  ## Helper to parse JSON string to XLangNode
  jsonStr.parseJson().to(XLangNode)

proc getKinds*(node: var XLangNode): HashSet[XLangNodeKind] =
  ## Helper to collect all kinds in a tree
  collectAllKinds(node)
