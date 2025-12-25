# "Namespace: ICU4N.Dev.Test.Impl"
type
  CSCharacterIteratorTest = ref object


proc newCSCharacterIteratorTest(): CSCharacterIteratorTest =

proc TestAPI*() =
    var text: String = "Hello, World"
    var cs: ReadOnlyMemory<char> = text.AsMemory
    var csci: CharacterIterator = ReadOnlyMemoryCharacterIterator(cs)
    var sci: CharacterIterator = StringCharacterIterator(text)
assertEquals("", sci.SetIndex(6), csci.SetIndex(6))
assertEquals("", sci.Index, csci.Index)
assertEquals("", sci.Current, csci.Current)
assertEquals("", sci.Previous, csci.Previous)
assertEquals("", sci.Next, csci.Next)
assertEquals("", sci.BeginIndex, csci.BeginIndex)
assertEquals("", sci.EndIndex, csci.EndIndex)
assertEquals("", sci.First, csci.First)
assertEquals("", sci.Last, csci.Last)
csci.SetIndex(4)
sci.SetIndex(4)
    var clci: CharacterIterator = cast[CharacterIterator](csci.Clone)
      var i: int = 0
      while i < 50:
assertEquals("", sci.Next, clci.Next)
++i
      var i: int = 0
      while i < 50:
assertEquals("", sci.Previous, clci.Previous)
++i