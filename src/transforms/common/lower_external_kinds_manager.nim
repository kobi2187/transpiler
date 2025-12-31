## LowerExternalKindsManager - fixed-point pass runner for lowering external kinds
## This module is a clearer-name replacement for the previous `pass_manager2.nim`.

import core/xlangtypes
import ../types
import ../../error_collector
import semantic/semantic_analysis
import tables
import sets, strutils, sequtils

import ../helpers

type
  LowerExternalKindsManager* = ref object
    kindToTransform*: Table[XLangNodeKind, TransformPass]
    activeKinds*: HashSet[XLangNodeKind]
    maxIterations*: int
    errorCollector*: ErrorCollector
    semanticInfo*: SemanticInfo
    result*: PassManagerResult

proc newLowerExternalKindsManager*(maxIterations: int = 10000,
                                  errorCollector: ErrorCollector = nil): LowerExternalKindsManager =
  LowerExternalKindsManager(
    kindToTransform: initTable[XLangNodeKind, TransformPass](),
    activeKinds: initHashSet[XLangNodeKind](),
    maxIterations: maxIterations,
    errorCollector: if errorCollector != nil: errorCollector else: newErrorCollector(),
    result: PassManagerResult(success: true, iterations: 0, loopWarning: false, loopKinds: @[], maxIterationsReached: false)
  )

proc addTransforms*(pm: LowerExternalKindsManager, transforms: seq[TransformPass]) =
  for transform in transforms:
    for kind in transform.operatesOnKinds:
      pm.activeKinds.incl(kind)
      pm.kindToTransform[kind] = transform


proc applyTransform*(pm: LowerExternalKindsManager, node: var XLangNode,
                     counter: var int, applicableKinds: HashSet[XLangNodeKind],
                     reintroducedKinds: var HashSet[XLangNodeKind]) =
  let kind = node.kind
  if kind notin applicableKinds:
    return

  let transform = pm.kindToTransform.getOrDefault(kind, nil)
  if transform != nil:
    let newNode = transform.transform(node, pm.semanticInfo)
    if newNode != node:
      node = newNode
      counter.inc()
      if node.kind in pm.activeKinds:
        reintroducedKinds.incl(node.kind)

proc run*(pm: LowerExternalKindsManager, root: var XLangNode, verbose: bool = false,
          semanticInfo: var SemanticInfo): XLangNode =
  pm.semanticInfo = semanticInfo
  var counter = 1
  var iterations = 0
  const loopWarningThreshold = 20
  const progressInterval = 100

  var reintroducedKinds: HashSet[XLangNodeKind] = initHashSet[XLangNodeKind]()
  var cycleWarningShown = false

  pm.result = PassManagerResult(success: true, iterations: 0, loopWarning: false, loopKinds: @[], maxIterationsReached: false)

  while counter > 0 and iterations < pm.maxIterations:
    counter = 0
    iterations.inc()
    reintroducedKinds.clear()

    if verbose and iterations mod progressInterval == 0:
      stderr.write("\r  Pass iteration: " & $iterations & "...")
      stderr.flushFile()

    var treeKinds = collectAllKinds(root)
    let applicableKinds = pm.activeKinds * treeKinds
    if applicableKinds.len == 0:
      break

    traverseTree(root, proc(node: var XLangNode) =
      applyTransform(pm, node, counter, applicableKinds, reintroducedKinds))

    if reintroducedKinds.len > 0 and iterations >= loopWarningThreshold and not cycleWarningShown:
      pm.result.loopWarning = true
      for kind in reintroducedKinds:
        pm.result.loopKinds.add(kind)
      if verbose:
        stderr.write("\n  WARNING: Potential transform cycle detected at iteration " & $iterations & "\n")
        stderr.write("    Transforms producing triggerable kinds: ")
        for k in reintroducedKinds:
          stderr.write($k & " ")
        stderr.write("\n")
        stderr.flushFile()
      cycleWarningShown = true

    if iterations >= pm.maxIterations:
      pm.result.maxIterationsReached = true
      pm.result.success = false
      let cycleInfo = if reintroducedKinds.len > 0:
        " (cycle on: " & reintroducedKinds.toSeq.mapIt($it).join(", ") & ")"
      else:
        ""
      pm.errorCollector.addError(tekTransformLimitReachedError,
        "LowerExternalKindsManager: Max iterations reached" & cycleInfo)
      break

    if counter == 0:
      break

  if verbose and iterations >= progressInterval:
    stderr.write("\r" & " ".repeat(40) & "\r")
    stderr.flushFile()

  pm.result.iterations = iterations
  result = root
