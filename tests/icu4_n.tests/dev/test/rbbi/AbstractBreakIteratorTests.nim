# "Namespace: ICU4N.Dev.Test.Rbbi"
type
  AbstractBreakIteratorTests = ref object
    bi: BreakIterator

type
  AbstractBreakIterator = ref object
    position: int = 0
    LIMIT: int = 100

proc Set(n: int): int =
    position = n
    if position > LIMIT:
        position = LIMIT
        return Done
    if position < 0:
        position = 0
        return Done
    return position
proc First*(): int =
    return Set(0)
proc Last*(): int =
    return Set(LIMIT)
proc Next*(n: int): int =
    return Set(position + n)
proc Next*(): int =
    return Next(1)
proc Previous*(): int =
    return Next(-1)
proc Following*(offset: int): int =
    return Set(offset + 1)
proc Current(): int =
    return position
proc Text(): CharacterIterator =
    return nil
proc SetText*(newText: CharacterIterator) =

proc CreateBreakIterator*() =
    bi = AbstractBreakIterator
proc TestPreceding*() =
    var pos: int = bi.Preceding(0)
TestFmwk.assertEquals("BreakIterator preceding position not correct", BreakIterator.Done, pos)
    pos = bi.Preceding(5)
TestFmwk.assertEquals("BreakIterator preceding position not correct", 4, pos)
proc TestIsBoundary*() =
    var b: bool = bi.IsBoundary(0)
TestFmwk.assertTrue("BreakIterator is boundary not correct", b)
    b = bi.IsBoundary(5)
TestFmwk.assertTrue("BreakIterator is boundary not correct", b)