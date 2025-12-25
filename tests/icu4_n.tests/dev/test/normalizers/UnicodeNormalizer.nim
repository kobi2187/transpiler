# "Namespace: ICU4N.Dev.Test.Normalizers"
type
  UnicodeNormalizer = ref object
    COMPATIBILITY_MASK: byte = 1
    D: byte = 0
    form: byte
    data: NormalizerData = nil

proc newUnicodeNormalizer(form: byte, fullData: bool): UnicodeNormalizer =
  self.form = form
  if data == nil:
    data = NormalizerBuilder.Build(fullData)
proc normalize*(source: String, target: StringBuffer): StringBuffer =
    if source.Length != 0:
internalDecompose(source, target)
        if form & COMPOSITION_MASK != 0:
internalCompose(target)
    return target
proc normalize*(source: String): String =
    return normalize(source, StringBuffer).ToString
proc internalDecompose(source: String, target: StringBuffer) =
    var buffer: StringBuffer = StringBuffer
    var canonical: bool = form & COMPATIBILITY_MASK == 0
    var ch: int
      var i: int = 0
      while i < source.Length:
          buffer.Length = 0
          ch = UTF16Util.NextCodePoint(source, i)
          i = UTF16Util.CodePointLength(ch)
data.GetRecursiveDecomposition(canonical, ch, buffer)
            var j: int = 0
            while j < buffer.Length:
                ch = UTF16Util.NextCodePoint(buffer, j)
                j = UTF16Util.CodePointLength(ch)
                var chClass: int = data.GetCanonicalClass(ch)
                var k: int = target.Length
                if chClass != 0:
                    var ch2: int
                      while k > 0:
                          ch2 = UTF16Util.PrevCodePoint(target, k)
                          if data.GetCanonicalClass(ch2) <= chClass:
                            break
                          k = UTF16Util.CodePointLength(ch2)
UTF16Util.InsertCodePoint(target, k, ch)
proc internalCompose(target: StringBuffer) =
    var starterPos: int = 0
    var starterCh: int = UTF16Util.NextCodePoint(target, 0)
    var compPos: int = UTF16Util.CodePointLength(starterCh)
    var lastClass: int = data.GetCanonicalClass(starterCh)
    if lastClass != 0:
      lastClass = 256
      var decompPos: int = UTF16Util.CodePointLength(starterCh)
      while decompPos < target.Length:
          var ch: int = UTF16Util.NextCodePoint(target, decompPos)
          decompPos = UTF16Util.CodePointLength(ch)
          var chClass: int = data.GetCanonicalClass(ch)
          var composite: int = data.GetPairwiseComposition(starterCh, ch)
          if composite != NormalizerData.NOT_COMPOSITE && lastClass < chClass || lastClass == 0:
UTF16Util.SetCodePointAt(target, starterPos, composite)
              starterCh = composite
          else:
              if chClass == 0:
                  starterPos = compPos
                  starterCh = ch
              lastClass = chClass
              decompPos = UTF16Util.SetCodePointAt(target, compPos, ch)
              compPos = UTF16Util.CodePointLength(ch)
    target.Length = compPos
proc GetExcluded(ch: char): bool =
    return data.GetExcluded(ch)
proc GetRawDecompositionMapping(ch: char): String =
    return data.GetRawDecompositionMapping(ch)