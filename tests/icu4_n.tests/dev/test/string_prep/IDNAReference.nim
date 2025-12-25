# "Namespace: ICU4N.Dev.Test.StringPrep"
type
  IDNAReference = ref object
    ACE_PREFIX: seq[char] = @[cast[char](120), cast[char](110), cast[char](45), cast[char](45)]
    ACE_PREFIX_LENGTH: int = 4
    MAX_LABEL_LENGTH: int = 63
    HYPHEN: int = 45
    CAPITAL_A: int = 65
    CAPITAL_Z: int = 90
    LOWER_CASE_DELTA: int = 32
    FULL_STOP: int = 46
    DEFAULT: IDNA2003Options = IDNA2003Options.Default
    ALLOW_UNASSIGNED: IDNA2003Options = IDNA2003Options.AllowUnassigned
    USE_STD3_RULES: IDNA2003Options = IDNA2003Options.UseSTD3Rules
    transform: NamePrepTransform = NamePrepTransform.GetInstance

proc IsReady(): bool =
    return transform.IsReady
proc StartsWithPrefix(src: StringBuffer): bool =
    var startsWithPrefix: bool = true
    if src.Length < ACE_PREFIX_LENGTH:
        return false
      var i: int = 0
      while i < ACE_PREFIX_LENGTH:
          if ToASCIILower(src[i]) != ACE_PREFIX[i]:
              startsWithPrefix = false
++i
    return startsWithPrefix
proc ToASCIILower(ch: char): char =
    if CAPITAL_A <= ch && ch <= CAPITAL_Z:
        return cast[char](ch + LOWER_CASE_DELTA)
    return ch
proc ToASCIILower(src: StringBuffer): StringBuffer =
    var dest: StringBuffer = StringBuffer
      var i: int = 0
      while i < src.Length:
dest.Append(ToASCIILower(src[i]))
++i
    return dest
proc CompareCaseInsensitiveASCII(s1: StringBuffer, s2: StringBuffer): int =
      var c1: char
      var c2: char
    var rc: int
      var i: int = 0
      while true:
          if i == s1.Length:
              return 0
          c1 = s1[i]
          c2 = s2[i]
          if c1 != c2:
              rc = ToASCIILower(c1) - ToASCIILower(c2)
              if rc != 0:
                  return rc
++i
proc GetSeparatorIndex(src: seq[char], start: int, limit: int): int =
      while start < limit:
          if NamePrepTransform.IsLabelSeparator(src[start]):
              return start
++start
    return start
proc IsLDHChar(ch: int): bool =
    if ch > 122:
        return false
    if ch == 45 || 48 <= ch && ch <= 57 || 65 <= ch && ch <= 90 || 97 <= ch && ch <= 122:
        return true
    return false
proc ConvertToASCII*(src: String, options: IDNA2003Options): StringBuffer =
    var iter: UCharacterIterator = UCharacterIterator.GetInstance(src)
    return ConvertToASCII(iter, options)
proc ConvertToASCII*(src: StringBuffer, options: IDNA2003Options): StringBuffer =
    var iter: UCharacterIterator = UCharacterIterator.GetInstance(src)
    return ConvertToASCII(iter, options)
proc ConvertToASCII*(srcIter: UCharacterIterator, options: IDNA2003Options): StringBuffer =
    var caseFlags: char[] = nil
    var srcIsASCII: bool = true
    var srcIsLDH: bool = true
    var useSTD3ASCIIRules: bool = options & USE_STD3_RULES != 0
    var ch: int
    while     ch = srcIter.Next != UCharacterIterator.Done:
        if ch > 127:
            srcIsASCII = false
    var failPos: int = -1
srcIter.SetToStart
    var processOut: StringBuffer = nil
    if !srcIsASCII:
        processOut = transform.Prepare(srcIter, cast[StringPrepOptions](options))
    else:
        processOut = StringBuffer(srcIter.GetText)
    var poLen: int = processOut.Length
    if poLen == 0:
        raise StringPrepFormatException("Found zero length lable after NamePrep.", StringPrepErrorType.ZeroLengthLabel)
    var dest: StringBuffer = StringBuffer
    srcIsASCII = true
      var j: int = 0
      while j < poLen:
          ch = processOut[j]
          if ch > 127:
              srcIsASCII = false

          elif IsLDHChar(ch) == false:
              srcIsLDH = false
              failPos = j
++j
    if useSTD3ASCIIRules == true:
        if srcIsLDH == false || processOut[0] == HYPHEN || processOut[processOut.Length - 1] == HYPHEN:
            if srcIsLDH == false:
                raise StringPrepFormatException("The input does not conform to the STD 3 ASCII rules", StringPrepErrorType.STD3ASCIIRulesError, processOut.ToString,                 if failPos > 0:
failPos - 1
                else:
failPos)

            elif processOut[0] == HYPHEN:
                raise StringPrepFormatException("The input does not conform to the STD 3 ASCII rules", StringPrepErrorType.STD3ASCIIRulesError, processOut.ToString, 0)
            else:
                raise StringPrepFormatException("The input does not conform to the STD 3 ASCII rules", StringPrepErrorType.STD3ASCIIRulesError, processOut.ToString,                 if poLen > 0:
poLen - 1
                else:
poLen)
    if srcIsASCII:
        dest = processOut
    else:
        if !StartsWithPrefix(processOut):
            var punyout: StringBuffer = PunycodeReference.Encode(processOut, caseFlags)
            var lowerOut: StringBuffer = ToASCIILower(punyout)
dest.Append(ACE_PREFIX, 0, ACE_PREFIX_LENGTH - 0)
dest.Append(lowerOut)
        else:
            raise StringPrepFormatException("The input does not start with the ACE Prefix.", StringPrepErrorType.AcePrefixError, processOut.ToString, 0)
    if dest.Length > MAX_LABEL_LENGTH:
        raise StringPrepFormatException("The labels in the input are too long. Length > 64.", StringPrepErrorType.LabelTooLongError, dest.ToString, 0)
    return dest
proc ConvertIDNtoASCII*(iter: UCharacterIterator, options: IDNA2003Options): StringBuffer =
    return ConvertIDNToASCII(iter.GetText, options)
proc ConvertIDNtoASCII*(str: StringBuffer, options: IDNA2003Options): StringBuffer =
    return ConvertIDNToASCII(str.ToString, options)
proc ConvertIDNToASCII*(src: String, options: IDNA2003Options): StringBuffer =
    var srcArr: char[] = src.ToCharArray
    var result: StringBuffer = StringBuffer
    var sepIndex: int = 0
    var oldSepIndex: int = 0
      while true:
          sepIndex = GetSeparatorIndex(srcArr, sepIndex, srcArr.Length)
          var label: String = String(srcArr, oldSepIndex, sepIndex - oldSepIndex)
          if !label.Length == 0 && sepIndex == srcArr.Length:
              var iter: UCharacterIterator = UCharacterIterator.GetInstance(label)
result.Append(ConvertToASCII(iter, options))
          if sepIndex == srcArr.Length:
              break
++sepIndex
          oldSepIndex = sepIndex
result.Append(cast[char](FULL_STOP))
    return result
proc ConvertToUnicode*(src: String, options: IDNA2003Options): StringBuffer =
    var iter: UCharacterIterator = UCharacterIterator.GetInstance(src)
    return ConvertToUnicode(iter, options)
proc ConvertToUnicode*(src: StringBuffer, options: IDNA2003Options): StringBuffer =
    var iter: UCharacterIterator = UCharacterIterator.GetInstance(src)
    return ConvertToUnicode(iter, options)
proc ConvertToUnicode*(iter: UCharacterIterator, options: IDNA2003Options): StringBuffer =
    var srcIsASCII: bool = true
    var ch: int
    var saveIndex: int = iter.Index
    while     ch = iter.Next != UCharacterIterator.Done:
        if ch > 127:
            srcIsASCII = false
            break
    while true:
        var processOut: StringBuffer
        if srcIsASCII == false:
            iter.Index = saveIndex
            try:
                processOut = transform.Prepare(iter, cast[StringPrepOptions](options))
            except StringPrepFormatException:
                break
        else:
            processOut = StringBuffer(iter.GetText)
        if StartsWithPrefix(processOut):
            var temp: String = processOut.ToString(ACE_PREFIX_LENGTH, processOut.Length - ACE_PREFIX_LENGTH)
            var decodeOut: StringBuffer = nil
            try:
                decodeOut = PunycodeReference.Decode(StringBuffer(temp), nil)
            except StringPrepFormatException:
                break
            var toASCIIOut: StringBuffer = ConvertToASCII(decodeOut, options)
            if CompareCaseInsensitiveASCII(processOut, toASCIIOut) != 0:
                break
            return decodeOut
        if notfalse:
            break
    return StringBuffer(iter.GetText)
proc ConvertIDNToUnicode*(iter: UCharacterIterator, options: IDNA2003Options): StringBuffer =
    return ConvertIDNToUnicode(iter.GetText, options)
proc ConvertIDNToUnicode*(str: StringBuffer, options: IDNA2003Options): StringBuffer =
    return ConvertIDNToUnicode(str.ToString, options)
proc ConvertIDNToUnicode*(src: String, options: IDNA2003Options): StringBuffer =
    var srcArr: char[] = src.ToCharArray
    var result: StringBuffer = StringBuffer
    var sepIndex: int = 0
    var oldSepIndex: int = 0
      while true:
          sepIndex = GetSeparatorIndex(srcArr, sepIndex, srcArr.Length)
          var label: String = String(srcArr, oldSepIndex, sepIndex - oldSepIndex)
          if label.Length == 0 && sepIndex != srcArr.Length:
              raise StringPrepFormatException("Found zero length lable after NamePrep.", StringPrepErrorType.ZeroLengthLabel)
          var iter: UCharacterIterator = UCharacterIterator.GetInstance(label)
result.Append(ConvertToUnicode(iter, options))
          if sepIndex == srcArr.Length:
              break
++sepIndex
          oldSepIndex = sepIndex
result.Append(cast[char](FULL_STOP))
    return result
proc Compare*(s1: StringBuffer, s2: StringBuffer, options: IDNA2003Options): int =
    if s1 == nil || s2 == nil:
        raise ArgumentException("One of the source buffers is null")
    var s1Out: StringBuffer = ConvertIDNToASCII(s1.ToString, options)
    var s2Out: StringBuffer = ConvertIDNToASCII(s2.ToString, options)
    return CompareCaseInsensitiveASCII(s1Out, s2Out)
proc Compare*(s1: String, s2: String, options: IDNA2003Options): int =
    if s1 == nil || s2 == nil:
        raise ArgumentException("One of the source buffers is null")
    var s1Out: StringBuffer = ConvertIDNToASCII(s1, options)
    var s2Out: StringBuffer = ConvertIDNToASCII(s2, options)
    return CompareCaseInsensitiveASCII(s1Out, s2Out)
proc Compare*(i1: UCharacterIterator, i2: UCharacterIterator, options: IDNA2003Options): int =
    if i1 == nil || i2 == nil:
        raise ArgumentException("One of the source buffers is null")
    var s1Out: StringBuffer = ConvertIDNToASCII(i1.GetText, options)
    var s2Out: StringBuffer = ConvertIDNToASCII(i2.GetText, options)
    return CompareCaseInsensitiveASCII(s1Out, s2Out)