# "Namespace: ICU4N.Dev.Test.Normalizers"
type
  NormalizerData = ref object
    NOT_COMPOSITE: int = 'ï'
    canonicalClass: IntHashtable
    decompose: IntStringHashtable
    compose: LongHashtable
    isCompatibility: BitSet = BitSet(1)
    isExcluded: BitSet = BitSet(1)

proc GetCanonicalClass*(ch: int): int =
    return canonicalClass.Get(ch)
proc GetPairwiseComposition*(first: int, second: int): int =
    return compose.Get(cast[long](first) << 32 | cast[uint](second))
proc GetRecursiveDecomposition*(canonical: bool, ch: int, buffer: StringBuffer) =
    var decomp: string = decompose.Get(ch)
    if decomp != nil && !canonical && isCompatibility.Get(ch):
          var i: int = 0
          while i < decomp.Length:
              ch = UTF16Util.NextCodePoint(decomp, i)
GetRecursiveDecomposition(canonical, ch, buffer)
              i = UTF16Util.CodePointLength(ch)
    else:
UTF16Util.AppendCodePoint(buffer, ch)
proc newNormalizerData(canonicalClass: IntHashtable, decompose: IntStringHashtable, compose: LongHashtable, isCompatibility: BitSet, isExcluded: BitSet): NormalizerData =
  self.canonicalClass = canonicalClass
  self.decompose = decompose
  self.compose = compose
  self.isCompatibility = isCompatibility
  self.isExcluded = isExcluded
proc GetExcluded(ch: char): bool =
    return isExcluded.Get(ch)
proc GetRawDecompositionMapping(ch: char): string =
    return decompose.Get(ch)