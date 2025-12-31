## SequentialPassManager - runs a list of one-shot transformation steps in order

import core/xlangtypes
import semantic/semantic_analysis

type
  StepProc = proc(xlangAst: var XLangNode, semanticInfo: var SemanticInfo, verbose: bool) {.closure.}

  SequentialPassManager* = ref object
    steps*: seq[StepProc]

proc newSequentialPassManager*(): SequentialPassManager =
  SequentialPassManager(steps: @[])

proc addStep*(pm: SequentialPassManager, p: StepProc) =
  pm.steps.add(p)

proc run*(pm: SequentialPassManager, xlangAst: var XLangNode, semanticInfo: var SemanticInfo, verbose: bool) =
  for s in pm.steps:
    s(xlangAst, semanticInfo, verbose)
