# "Namespace: ICU4N.Dev.Test.StringPrep"
type
  NamePrepTransform = ref object
    transform: NamePrepTransform = NamePrepTransform
    labelSeparatorSet: UnicodeSet
    prohibitedSet: UnicodeSet
    unassignedSet: UnicodeSet
    mapTransform: MapTransform
    NONE: StringPrepOptions = StringPrepOptions.Default
    ALLOW_UNASSIGNED: StringPrepOptions = StringPrepOptions.AllowUnassigned

proc newNamePrepTransform(): NamePrepTransform =
  var assembly: Assembly = type(NamePrepTransform).Assembly
  var bundle: ICUResourceBundle = cast[ICUResourceBundle](ICUResourceBundle.GetBundleInstance("Dev/Data/TestData", "idna_rules", assembly, true))
  var mapRules: String = bundle.GetString("MapNoNormalization")
  mapRules = bundle.GetString("MapNFKC")
  mapTransform = MapTransform("CaseMap", mapRules, 0)
  labelSeparatorSet = UnicodeSet(bundle.GetString("LabelSeparatorSet"))
  prohibitedSet = UnicodeSet(bundle.GetString("ProhibitedSet"))
  unassignedSet = UnicodeSet(bundle.GetString("UnassignedSet"))
proc GetInstance*(): NamePrepTransform =
    return transform
proc IsLabelSeparator*(ch: int): bool =
    return transform.labelSeparatorSet.Contains(ch)
proc IsReady(): bool =
    return mapTransform.IsReady
proc Prepare*(src: UCharacterIterator, options: StringPrepOptions): StringBuffer =
    return Prepare(src.GetText, options)
proc Map(src: String, options: StringPrepOptions): String =
    var allowUnassigned: bool = options & ALLOW_UNASSIGNED > 0
    var caseMapOut: String = mapTransform.Transliterate(src)
    var iter: UCharacterIterator = UCharacterIterator.GetInstance(caseMapOut)
    var ch: int
    while     ch = iter.NextCodePoint != UCharacterIterator.Done:
        if transform.unassignedSet.Contains(ch) == true && allowUnassigned == false:
            raise StringPrepFormatException("An unassigned code point was found in the input", StringPrepErrorType.UnassignedError)
    return caseMapOut
proc Prepare*(src: String, options: StringPrepOptions): StringBuffer =
    var ch: int
    var mapOut: String = Map(src, options)
    var iter: UCharacterIterator = UCharacterIterator.GetInstance(mapOut)
      var direction: UCharacterDirection = UCharacterDirectionExtensions.CharDirectionCount
      var firstCharDir: UCharacterDirection = UCharacterDirectionExtensions.CharDirectionCount
      var rtlPos: int = -1
      var ltrPos: int = -1
      var rightToLeft: bool = false
      var leftToRight: bool = false
    while     ch = iter.NextCodePoint != UCharacterIterator.Done:
        if transform.prohibitedSet.Contains(ch) == true && ch != 32:
            raise StringPrepFormatException("A prohibited code point was found in the input", StringPrepErrorType.ProhibitedError, iter.GetText, iter.Index)
        direction = UChar.GetDirection(ch)
        if firstCharDir == UCharacterDirectionExtensions.CharDirectionCount:
            firstCharDir = direction
        if direction == UCharacterDirection.LeftToRight:
            leftToRight = true
            ltrPos = iter.Index - 1
        if direction == UCharacterDirection.RightToLeft || direction == UCharacterDirection.RightToLeftArabic:
            rightToLeft = true
            rtlPos = iter.Index - 1
    if leftToRight == true && rightToLeft == true:
        raise StringPrepFormatException("The input does not conform to the rules for BiDi code points.", StringPrepErrorType.CheckBiDiError, iter.GetText,         if rtlPos > ltrPos:
rtlPos
        else:
ltrPos)
    if rightToLeft == true && !firstCharDir == UCharacterDirection.RightToLeft || firstCharDir == UCharacterDirection.RightToLeftArabic && direction == UCharacterDirection.RightToLeft || direction == UCharacterDirection.RightToLeftArabic:
        raise StringPrepFormatException("The input does not conform to the rules for BiDi code points.", StringPrepErrorType.CheckBiDiError, iter.GetText,         if rtlPos > ltrPos:
rtlPos
        else:
ltrPos)
    return StringBuffer(mapOut)
type
  MapTransform = ref object
    translitInstance: Object
    translitMethod: MethodInfo
    isReady: bool

proc newMapTransform(id: String, rule: String, direction: int): MapTransform =
  isReady = Initialize(id, rule, direction)
proc Initialize(id: String, rule: String, direction: int): bool =
    try:
        var cls: Type = Type.GetType("ICU4N.Text.Transliterator, ICU4N")
        var createMethod: MethodInfo = cls.GetMethod("CreateFromRules", @[type(String), type(String), type(int)])
        translitInstance = createMethod.Invoke(nil, @[id, rule, direction])
        translitMethod = cls.GetMethod("Transliterate", @[type(String)])
    except Exception:
        return false
    return true
proc IsReady(): bool =
    return isReady
proc Transliterate(text: String): String =
    if !isReady:
        raise InvalidOperationException("Transliterator is not ready")
    var result: String = nil
    try:
        result = cast[String](translitMethod.Invoke(translitInstance, @[text]))
    except TargetInvocationException:
        raise Exception(ite.ToString, ite)
    except SecurityException:
        raise Exception(iae.ToString, iae)
    return result