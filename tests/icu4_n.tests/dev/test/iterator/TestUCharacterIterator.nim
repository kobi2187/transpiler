# "Namespace: ICU4N.Dev.Test.Iterator"
type
  TestUCharacterIterator = ref object
    ITERATION_STRING_: String = "Testing 1 2 3 ð€€ 456"
    ITERATION_SUPPLEMENTARY_INDEX: int = 14

proc newTestUCharacterIterator(): TestUCharacterIterator =

proc TestClone*() =
    var iterator: UCharacterIterator = UCharacterIterator.GetInstance("testing")
    var cloned: UCharacterIterator = cast[UCharacterIterator](iterator.Clone)
    var completed: int = 0
    while completed != UCharacterIterator.Done:
        completed = iterator.Next
        if completed != cloned.Next:
Errln("Cloned operation failed")
proc getText*(iterator: UCharacterIterator, result: String) =
    var buf: char[] = seq[char]
      while true:
          if iterator.TryGetText(buf,           var charsLength: int):
              break
          else:
              buf = seq[char]
    if result.CompareToOrdinal(string(buf, 0, iterator.Length)) != 0:
Errln("getText failed for iterator")
proc TestIteration*() =
    var iterator: UCharacterIterator = UCharacterIterator.GetInstance(ITERATION_STRING_)
    var iterator2: UCharacterIterator = UCharacterIterator.GetInstance(ITERATION_STRING_)
iterator.SetToStart
    if iterator.Current != ITERATION_STRING_[0]:
Errln("Iterator failed retrieving first character")
iterator.SetToLimit
    if iterator.Previous != ITERATION_STRING_[ITERATION_STRING_.Length - 1]:
Errln("Iterator failed retrieving last character")
    if iterator.Length != ITERATION_STRING_.Length:
Errln("Iterator failed determining begin and end index")
    iterator2.Index = 0
    iterator.Index = 0
    var ch: int = 0
    while ch != UCharacterIterator.Done:
        var index: int = iterator2.Index
        ch = iterator2.NextCodePoint
        if index != ITERATION_SUPPLEMENTARY_INDEX:
            if ch != iterator.Next && ch != UCharacterIterator.Done:
Errln("Error mismatch in next() and nextCodePoint()")
        else:
            if UTF16.GetLeadSurrogate(ch) != iterator.Next || UTF16.GetTrailSurrogate(ch) != iterator.Next:
Errln("Error mismatch in next and nextCodePoint for " + "supplementary characters")
    iterator.Index = ITERATION_STRING_.Length
    iterator2.Index = ITERATION_STRING_.Length
    while ch != UCharacterIterator.Done:
        var index: int = iterator2.Index
        ch = iterator2.PreviousCodePoint
        if index != ITERATION_SUPPLEMENTARY_INDEX:
            if ch != iterator.Previous && ch != UCharacterIterator.Done:
Errln("Error mismatch in previous() and " + "previousCodePoint()")
        else:
            if UTF16.GetLeadSurrogate(ch) != iterator.Previous || UTF16.GetTrailSurrogate(ch) != iterator.Previous:
Errln("Error mismatch in previous and " + "previousCodePoint for supplementary characters")
proc TestIterationUChar32*() =
    var text: String = "abð ‚â‚¬íŸ¿ð  †ð€a"
    var c: int
    var i: int
      var iter: UCharacterIterator = UCharacterIterator.GetInstance(text)
      var iterText: String = iter.GetText
      if !iterText.Equals(text):
Errln("iter.getText() failed")
      iter.Index = 1
      if iter.CurrentCodePoint != UTF16.CharAt(text, 1):
Errln("Iterator didn't start out in the right place.")
iter.SetToStart
      c = iter.CurrentCodePoint
      i = 0
      i = iter.MoveCodePointIndex(1)
      c = iter.CurrentCodePoint
      if c != UTF16.CharAt(text, 1) || i != 1:
Errln("moveCodePointIndex(1) didn't work correctly expected " + Hex(c) + " got " + Hex(UTF16.CharAt(text, 1)) + " i= " + i)
      i = iter.MoveCodePointIndex(2)
      c = iter.CurrentCodePoint
      if c != UTF16.CharAt(text, 4) || i != 4:
Errln("moveCodePointIndex(2) didn't work correctly expected " + Hex(c) + " got " + Hex(UTF16.CharAt(text, 4)) + " i= " + i)
      i = iter.MoveCodePointIndex(-2)
      c = iter.CurrentCodePoint
      if c != UTF16.CharAt(text, 1) || i != 1:
Errln("moveCodePointIndex(-2) didn't work correctly expected " + Hex(c) + " got " + Hex(UTF16.CharAt(text, 1)) + " i= " + i)
iter.SetToLimit
      i = iter.MoveCodePointIndex(-2)
      c = iter.CurrentCodePoint
      if c != UTF16.CharAt(text, text.Length - 3) || i != text.Length - 3:
Errln("moveCodePointIndex(-2) didn't work correctly expected " + Hex(c) + " got " + Hex(UTF16.CharAt(text, text.Length - 3)) + " i= " + i)
iter.SetToStart
      c = iter.CurrentCodePoint
      i = 0
      i = 0
iter.SetToStart
      c = iter.Next
      if c != UTF16.CharAt(text, i):
Errln("first32PostInc failed.  Expected->" + Hex(UTF16.CharAt(text, i)) + " Got-> " + Hex(c))
      if iter.Index != UTF16.GetCharCount(c) + i:
Errln("getIndex() after first32PostInc() failed")
iter.SetToStart
      i = 0
      if iter.Index != 0:
Errln("setToStart failed")
Logln("Testing forward iteration...")
      while true:
          if c != UCharacterIterator.Done:
            c = iter.NextCodePoint
          if c != UTF16.CharAt(text, i):
Errln("Character mismatch at position " + i + ", iterator has " + Hex(c) + ", string has " + Hex(UTF16.CharAt(text, i)))
          i = UTF16.GetCharCount(c)
          if iter.Index != i:
Errln("getIndex() aftr nextCodePointPostInc() isn't working right")
          c = iter.CurrentCodePoint
          if c != UCharacterIterator.Done && c != UTF16.CharAt(text, i):
Errln("current() after nextCodePointPostInc() isn't working right")
          if notc != UCharacterIterator.Done:
              break
      c = iter.NextCodePoint
      if c != UCharacterIterator.Done:
Errln("nextCodePointPostInc() didn't return DONE at the beginning")
type
  UCharIterator = ref object
    s: seq[int]
    length: int

proc newUCharIterator(src: seq[int], len: int, index: int): UCharIterator =
  s = src
  length = len
  i = index
proc Current(): int =
    if i < length:
        return s[i]
    else:
        return -1
proc Next*(): int =
    if i < length:
        return s[++i]
    else:
        return -1
proc Previous*(): int =
    if i > 0:
        return s[--i]
    else:
        return -1
proc Index(): int =
    return i
proc TestPreviousNext*() =
    var src: char[] = @[UTF16.GetLeadSurrogate(194969), UTF16.GetTrailSurrogate(194969), UTF16.GetLeadSurrogate(119135), UTF16.GetTrailSurrogate(119135), cast[char](196), cast[char](7888)]
    var iter1: UCharacterIterator = UCharacterIterator.GetInstance(ReplaceableString(String(src)))
    var iter2: UCharacterIterator = UCharacterIterator.GetInstance(src)
    var iter3: UCharacterIterator = UCharacterIterator.GetInstance(StringCharacterIterator(String(src)))
    var iter4: UCharacterIterator = UCharacterIterator.GetInstance(StringBuffer(String(src)))
previousNext(iter1)
previousNext(iter2)
previousNext(iter3)
previousNext(iter4)
getText(iter1, String(src))
getText(iter2, String(src))
getText(iter3, String(src))
    var citer1: CharacterIterator = iter1.GetCharacterIterator
    var citer2: CharacterIterator = iter2.GetCharacterIterator
    var citer3: CharacterIterator = iter3.GetCharacterIterator
    if citer1.First != iter1.Current:
Errln("getCharacterIterator for iter1 failed")
    if citer2.First != iter2.Current:
Errln("getCharacterIterator for iter2 failed")
    if citer3.First != iter3.Current:
Errln("getCharacterIterator for iter3 failed")
    try:
        var clone1: UCharacterIterator = cast[UCharacterIterator](iter1.Clone)
        var clone2: UCharacterIterator = cast[UCharacterIterator](iter2.Clone)
        var clone3: UCharacterIterator = cast[UCharacterIterator](iter3.Clone)
        if clone1.MoveIndex(3) != iter1.MoveIndex(3):
Errln("moveIndex for iter1 failed")
        if clone2.MoveIndex(3) != iter2.MoveIndex(3):
Errln("moveIndex for iter2 failed")
        if clone3.MoveIndex(3) != iter3.MoveIndex(3):
Errln("moveIndex for iter1 failed")
    except Exception:
Errln("could not clone the iterator")
proc previousNext*(iter: UCharacterIterator) =
    var expect: int[] = @[194969, 119135, 196, 7888]
    var expectIndex: int[] = @[0, 0, 1, 1, 2, 3, 4]
    var SRC_MIDDLE: int = 4
    var EXPECT_MIDDLE: int = 2
    var moves: String = "0+0+0--0-0-+++0--+++++++0--------"
    var iter32: UCharIterator = UCharIterator(expect, expect.Length, EXPECT_MIDDLE)
      var c1: int
      var c2: int
    var m: char
    iter.Index = SRC_MIDDLE
    var movesIndex: int = 0
    while movesIndex < moves.Length:
        m = moves[++movesIndex]
        if m == '-':
            c1 = iter.PreviousCodePoint
            c2 = iter32.Previous

        elif m == '0':
            c1 = iter.CurrentCodePoint
            c2 = iter32.Current
        else:
            c1 = iter.NextCodePoint
            c2 = iter32.Next
        if c1 != c2:
            var history: String = moves.Substring(0, movesIndex - 0)
Errln("error: mismatch in Normalizer iteration at " + history + ": " + "got c1= " + Hex(c1) + " != expected c2= " + Hex(c2))
            break
        if expectIndex[iter.Index] != iter32.Index:
            var history: String = moves.Substring(0, movesIndex - 0)
Errln("error: index mismatch in Normalizer iteration at " + history + " : " + "Normalizer index " + iter.Index + " expected " + expectIndex[iter32.Index])
            break
proc TestUCharacterIteratorWrapper*() =
    var source: String = "asdfasdfjoiuyoiuy2341235679886765"
    var it: UCharacterIterator = UCharacterIterator.GetInstance(source)
    var wrap_ci: CharacterIterator = it.GetCharacterIterator
    var ci: CharacterIterator = StringCharacterIterator(source)
wrap_ci.SetIndex(10)
ci.SetIndex(10)
    var moves: String = "0+0+0--0-0-+++0--+++++++0--------++++0000----0-"
      var c1: int
      var c2: int
    var m: char
    var movesIndex: int = 0
    while movesIndex < moves.Length:
        m = moves[++movesIndex]
        if m == '-':
            c1 = wrap_ci.Previous
            c2 = ci.Previous

        elif m == '0':
            c1 = wrap_ci.Current
            c2 = ci.Current
        else:
            c1 = wrap_ci.Next
            c2 = ci.Next
        if c1 != c2:
            var history: String = moves.Substring(0, movesIndex - 0)
Errln("error: mismatch in Normalizer iteration at " + history + ": " + "got c1= " + Hex(c1) + " != expected c2= " + Hex(c2))
            break
        if wrap_ci.Index != ci.Index:
            var history: String = moves.Substring(0, movesIndex - 0)
Errln("error: index mismatch in Normalizer iteration at " + history + " : " + "Normalizer index " + wrap_ci.Index + " expected " + ci.Index)
            break
    if ci.First != wrap_ci.First:
Errln("CharacterIteratorWrapper.First() failed. expected: " + ci.First + " got: " + wrap_ci.First)
    if ci.Last != wrap_ci.Last:
Errln("CharacterIteratorWrapper.Last() failed expected: " + ci.Last + " got: " + wrap_ci.Last)
    if ci.BeginIndex != wrap_ci.BeginIndex:
Errln("CharacterIteratorWrapper.BeginIndex failed expected: " + ci.BeginIndex + " got: " + wrap_ci.BeginIndex)
    if ci.EndIndex != wrap_ci.EndIndex:
Errln("CharacterIteratorWrapper.EndIndex failed expected: " + ci.EndIndex + " got: " + wrap_ci.EndIndex)
    try:
        var cloneWCI: CharacterIterator = cast[CharacterIterator](wrap_ci.Clone)
        if wrap_ci.Index != cloneWCI.Index:
Errln("CharacterIteratorWrapper.Clone() failed expected: " + wrap_ci.Index + " got: " + cloneWCI.Index)
    except Exception:
Errln("CharacterIterator.Clone() failed")
proc TestJitterbug1952*() =
    var src: char[] = @['ï', 'ï', 'ï', 'ï', 'ï', 'ï']
    var iter: UCharacterIterator = UCharacterIterator.GetInstance(src)
    iter.Index = 1
    var ch: int
    while     ch = iter.PreviousCodePoint != UCharacterIterator.Done:
        if ch != 56320:
Errln("iter.PreviousCodePoint() failed")
    iter.Index = 5
    while     ch = iter.NextCodePoint != UCharacterIterator.Done:
        if ch != 56323:
Errln("iter.NextCodePoint() failed")