# "Namespace: ICU4N.Support.Text"
type
  AttributedStringTest = ref object


proc test_ConstructorLjava_lang_String*() =
    var test: String = "Test string"
    var attrString: AttributedString = AttributedString(test)
    var it: AttributedCharacterIterator = attrString.GetIterator
    var buf: StringBuffer = StringBuffer
buf.Append(it.First)
    var ch: char
    while     ch = it.Next != CharacterIterator.Done:
buf.Append(ch)
assertTrue("Wrong string: " + buf, buf.ToString.Equals(test, StringComparison.Ordinal))
proc test_ConstructorLAttributedCharacterIterator*() =
assertNotNull(string.Empty, AttributedString(testAttributedCharacterIterator))
proc test_ConstructorLAttributedCharacterIteratorII*() =
assertNotNull(string.Empty, AttributedString(testAttributedCharacterIterator, 0, 0))
type
  testAttributedCharacterIterator = ref object


proc GetAllAttributeKeys*(): ICollection<AttributedCharacterIteratorAttribute> =
    return nil
proc GetAttribute*(attribute: AttributedCharacterIteratorAttribute): object =
    return nil
proc GetAttributes*(): IDictionary<AttributedCharacterIteratorAttribute, object> =
    return nil
proc GetRunLimit*(attributes: ICollection[T]): int =
    return 0
proc GetRunLimit*(attribute: AttributedCharacterIteratorAttribute): int =
    return 0
proc GetRunLimit*(): int =
    return 0
proc GetRunStart*(attributes: ICollection[T]): int =
    return 0
proc GetRunStart*(attribute: AttributedCharacterIteratorAttribute): int =
    return 0
proc GetRunStart*(): int =
    return 0
proc Clone*(): object =
    return nil
proc Index(): int =
    return 0
proc EndIndex(): int =
    return 0
proc BeginIndex(): int =
    return 0
proc SetIndex*(location: int): char =
    return 'a'
proc Previous*(): char =
    return 'a'
proc Next*(): char =
    return 'a'
proc Current(): char =
    return 'a'
proc Last*(): char =
    return 'a'
proc First*(): char =
    return 'a'
proc test_addAttributeLjava_text_AttributedCharacterIterator_AttributeLjava_lang_ObjectII*() =
    var @as: AttributedString = AttributedString("test")
@as.AddAttribute(AttributedCharacterIteratorAttribute.Language, "a", 2, 3)
    var it: AttributedCharacterIterator = @as.GetIterator
assertEquals("non-null value limit", 2, it.GetRunLimit(AttributedCharacterIteratorAttribute.Language))
    @as = AttributedString("test")
@as.AddAttribute(AttributedCharacterIteratorAttribute.Language, nil, 2, 3)
    it = @as.GetIterator
assertEquals("null value limit", 4, it.GetRunLimit(AttributedCharacterIteratorAttribute.Language))
    try:
        @as = AttributedString("test")
@as.AddAttribute(AttributedCharacterIteratorAttribute.Language, nil, -1, 3)
fail("Expected IllegalArgumentException")
    except ArgumentException:

    @as = AttributedString("123", Dictionary<AttributedCharacterIteratorAttribute, object>)
    try:
@as.AddAttribute(nil, SortedSet<object>, 0, 1)
fail("should throw NullPointerException")
    except ArgumentNullException:

    try:
@as.AddAttribute(nil, SortedSet<object>, -1, 1)
fail("should throw NullPointerException")
    except ArgumentNullException:

proc test_addAttributeLjava_text_AttributedCharacterIterator_AttributeLjava_lang_Object*() =
    var @as: AttributedString = AttributedString("123", Dictionary<AttributedCharacterIteratorAttribute, object>)
    try:
@as.AddAttribute(nil, SortedSet<object>)
fail("should throw NullPointerException")
    except ArgumentNullException:

    try:
@as.AddAttribute(nil, nil)
fail("should throw NullPointerException")
    except ArgumentNullException:
