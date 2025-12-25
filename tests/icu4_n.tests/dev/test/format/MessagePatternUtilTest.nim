# "Namespace: ICU4N.Dev.Test.Format"
type
  MessagePatternUtilTest = ref object


type
  ExpectMessageNode = ref object
    parent: ExpectComplexArgNode
    contents: List[ExpectMessageContentsNode] = List<ExpectMessageContentsNode>

proc ExpectTextThatContains(s: String): ExpectMessageNode =
contents.Add(ExpectTextNode(s))
    return self
proc ExpectReplaceNumber(): ExpectMessageNode =
contents.Add(ExpectMessageContentsNode)
    return self
proc ExpectNoneArg(name: Object): ExpectMessageNode =
contents.Add(ExpectArgNode(name))
    return self
proc ExpectSimpleArg(name: Object, type: String): ExpectMessageNode =
contents.Add(ExpectArgNode(name, type))
    return self
proc ExpectSimpleArg(name: Object, type: String, style: String): ExpectMessageNode =
contents.Add(ExpectArgNode(name, type, style))
    return self
proc ExpectChoiceArg(name: Object): ExpectComplexArgNode =
    return ExpectComplexArg(name, MessagePatternArgType.Choice)
proc ExpectPluralArg(name: Object): ExpectComplexArgNode =
    return ExpectComplexArg(name, MessagePatternArgType.Plural)
proc ExpectSelectArg(name: Object): ExpectComplexArgNode =
    return ExpectComplexArg(name, MessagePatternArgType.Select)
proc ExpectSelectOrdinalArg(name: Object): ExpectComplexArgNode =
    return ExpectComplexArg(name, MessagePatternArgType.SelectOrdinal)
proc ExpectComplexArg(name: Object, argType: MessagePatternArgType): ExpectComplexArgNode =
    var complexArg: ExpectComplexArgNode = ExpectComplexArgNode(self, name, argType)
contents.Add(complexArg)
    return complexArg
proc FinishVariant(): ExpectComplexArgNode =
    return parent
proc CheckMatches(msg: MessageNode) =
Matches(msg)
proc Matches(msg: MessageNode): bool =
    var msgContents: IList<MessageContentsNode> = msg.GetContents
    var ok: bool = assertEquals("different numbers of MessageContentsNode", contents.Count, msgContents.Count)
    if ok:
          let msgIter = msgContents.GetEnumerator
<unhandled: nnkDefer>
          for ec in contents:
msgIter.MoveNext
              ok = ec.Matches(msgIter.Current)
    if !ok:
Errln("error in message: " + msg.ToString)
    return ok
type
  ExpectMessageContentsNode = ref object


proc Matches(c: MessageContentsNode): bool =
    return assertEquals("not a REPLACE_NUMBER node", MessageContentsNode.NodeType.ReplaceNumber, c.Type)
type
  ExpectTextNode = ref object
    subString: String

proc newExpectTextNode(subString: String): ExpectTextNode =
  self.subString = subString
proc Matches(c: MessageContentsNode): bool =
    return assertEquals("not a TextNode", MessageContentsNode.NodeType.Text, c.Type) && assertTrue("TextNode does not contain "" + subString + """, cast[TextNode](c).Text.Contains(subString))
type
  ExpectArgNode = ref object
    name: String
    number: int
    argType: MessagePatternArgType
    type: String
    style: String

proc newExpectArgNode(name: Object): ExpectArgNode =
newExpectArgNode(name, nil, nil)
proc newExpectArgNode(name: Object, type: String): ExpectArgNode =
newExpectArgNode(name, type, nil)
proc newExpectArgNode(name: Object, type: String, style: String): ExpectArgNode =
  if name is String:
      self.name = cast[String](name)
      self.number = -1
  else:
      self.number = cast[int](name)
      self.name = self.number.ToString(CultureInfo.InvariantCulture)
  if type == nil:
      argType = MessagePatternArgType.None
  else:
      argType = MessagePatternArgType.Simple
  self.type = type
  self.style = style
proc Matches(c: MessageContentsNode): bool =
    var ok: bool = assertEquals("not an ArgNode", MessageContentsNode.NodeType.Arg, c.Type)
    if !ok:
        return ok
    var arg: ArgNode = cast[ArgNode](c)
    ok = assertEquals("unexpected ArgNode argType", argType, arg.ArgType)
    ok = assertEquals("unexpected ArgNode arg name", name, arg.Name)
    ok = assertEquals("unexpected ArgNode arg number", number, arg.Number)
    ok = assertEquals("unexpected ArgNode arg type name", type, arg.TypeName)
    ok = assertEquals("unexpected ArgNode arg style", style, arg.SimpleStyle)
    if argType == MessagePatternArgType.None || argType == MessagePatternArgType.Simple:
        ok = assertNull("unexpected non-null complex style", arg.ComplexStyle)
    return ok
type
  ExpectComplexArgNode = ref object
    parent: ExpectMessageNode
    explicitOffset: bool
    offset: double
    variants: List[ExpectVariantNode] = List<ExpectVariantNode>

proc newExpectComplexArgNode(parent: ExpectMessageNode, name: Object, argType: MessagePatternArgType): ExpectComplexArgNode =
newExpectArgNode(name, argType.ToString.ToLowerInvariant)
  self.argType = argType
  self.parent = parent
proc ExpectOffset(offset: double): ExpectComplexArgNode =
    self.offset = offset
    explicitOffset = true
    return self
proc ExpectVariant(selector: String): ExpectMessageNode =
    var variant: ExpectVariantNode = ExpectVariantNode(self, selector)
variants.Add(variant)
    return variant.msg
proc ExpectVariant(selector: String, value: double): ExpectMessageNode =
    var variant: ExpectVariantNode = ExpectVariantNode(self, selector, value)
variants.Add(variant)
    return variant.msg
proc finishComplexArg(): ExpectMessageNode =
    return parent
proc Matches(c: MessageContentsNode): bool =
    var ok: bool = procCall.Matches(c)
    if !ok:
        return ok
    var arg: ArgNode = cast[ArgNode](c)
    var complexStyle: ComplexArgStyleNode = arg.ComplexStyle
    ok = assertNotNull("unexpected null complex style", complexStyle)
    if !ok:
        return ok
    ok = assertEquals("unexpected complex-style argType", argType, complexStyle.ArgType)
    ok = assertEquals("unexpected complex-style hasExplicitOffset()", explicitOffset, complexStyle.HasExplicitOffset)
    ok = assertEquals("unexpected complex-style offset", offset, complexStyle.Offset)
    var complexVariants: IList<VariantNode> = complexStyle.Variants
    ok = assertEquals("different number of variants", variants.Count, complexVariants.Count)
    if !ok:
        return ok
      let complexIter = complexVariants.GetEnumerator
<unhandled: nnkDefer>
      for variant in variants:
complexIter.MoveNext
          ok = variant.Matches(complexIter.Current)
    return ok
type
  ExpectVariantNode = ref object
    selector: String
    numericValue: double
    msg: ExpectMessageNode

proc newExpectVariantNode(parent: ExpectComplexArgNode, selector: String): ExpectVariantNode =
newExpectVariantNode(parent, selector, MessagePattern.NoNumericValue)
proc newExpectVariantNode(parent: ExpectComplexArgNode, selector: String, value: double): ExpectVariantNode =
  self.selector = selector
  numericValue = value
  msg = ExpectMessageNode
  msg.parent = parent
proc Matches(v: VariantNode): bool =
    var ok: bool = assertEquals("different selector strings", selector, v.Selector)
    ok = assertEquals("different selector strings", IsSelectorNumeric, v.IsSelectorNumeric)
    ok = assertEquals("different selector strings", numericValue, v.SelectorValue)
    return ok & msg.Matches(v.Message)
proc IsSelectorNumeric(): bool =
    return numericValue != MessagePattern.NoNumericValue
proc TestHello*() =
    var msg: MessageNode = MessagePatternUtil.BuildMessageNode("Hello!")
    var expect: ExpectMessageNode = ExpectMessageNode.ExpectTextThatContains("Hello")
expect.CheckMatches(msg)
proc TestHelloWithApos*() =
    var msg: MessageNode = MessagePatternUtil.BuildMessageNode("Hel'lo!")
    var expect: ExpectMessageNode = ExpectMessageNode.ExpectTextThatContains("Hel'lo")
expect.CheckMatches(msg)
proc TestHelloWithQuote*() =
    var msg: MessageNode = MessagePatternUtil.BuildMessageNode("Hel'{o!")
    var expect: ExpectMessageNode = ExpectMessageNode.ExpectTextThatContains("Hel{o")
expect.CheckMatches(msg)
    msg = MessagePatternUtil.BuildMessageNode("Hel'{'o!")
expect.CheckMatches(msg)
    msg = MessagePatternUtil.BuildMessageNode("a'{bc''de'f")
    expect = ExpectMessageNode.ExpectTextThatContains("a{bc'def")
expect.CheckMatches(msg)
proc TestNoneArg*() =
    var msg: MessageNode = MessagePatternUtil.BuildMessageNode("abc{0}def")
    var expect: ExpectMessageNode = ExpectMessageNode.ExpectTextThatContains("abc").ExpectNoneArg(0).ExpectTextThatContains("def")
expect.CheckMatches(msg)
    msg = MessagePatternUtil.BuildMessageNode("abc{ arg }def")
    expect = ExpectMessageNode.ExpectTextThatContains("abc").ExpectNoneArg("arg").ExpectTextThatContains("def")
expect.CheckMatches(msg)
    msg = MessagePatternUtil.BuildMessageNode("abc{1}def{arg}ghi")
    expect = ExpectMessageNode.ExpectTextThatContains("abc").ExpectNoneArg(1).ExpectTextThatContains("def").ExpectNoneArg("arg").ExpectTextThatContains("ghi")
expect.CheckMatches(msg)
proc TestSimpleArg*() =
    var msg: MessageNode = MessagePatternUtil.BuildMessageNode("a'{bc''de'f{0,number,g'hi''jk'l#}")
    var expect: ExpectMessageNode = ExpectMessageNode.ExpectTextThatContains("a{bc'def").ExpectSimpleArg(0, "number", "g'hi''jk'l#")
expect.CheckMatches(msg)
proc TestSelectArg*() =
    var msg: MessageNode = MessagePatternUtil.BuildMessageNode("abc{2, number}ghi{3, select, xx {xxx} other {ooo}} xyz")
    var expect: ExpectMessageNode = ExpectMessageNode.ExpectTextThatContains("abc").ExpectSimpleArg(2, "number").ExpectTextThatContains("ghi").ExpectSelectArg(3).ExpectVariant("xx").ExpectTextThatContains("xxx").FinishVariant.ExpectVariant("other").ExpectTextThatContains("ooo").FinishVariant.finishComplexArg.ExpectTextThatContains(" xyz")
expect.CheckMatches(msg)
proc TestPluralArg*() =
    var msg: MessageNode = MessagePatternUtil.BuildMessageNode("abc{num_people, plural, offset:17 few{fff} other {oooo}}xyz")
    var expect: ExpectMessageNode = ExpectMessageNode.ExpectTextThatContains("abc").ExpectPluralArg("num_people").ExpectOffset(17).ExpectVariant("few").ExpectTextThatContains("fff").FinishVariant.ExpectVariant("other").ExpectTextThatContains("oooo").FinishVariant.finishComplexArg.ExpectTextThatContains("xyz")
expect.CheckMatches(msg)
    msg = MessagePatternUtil.BuildMessageNode("abc{ num , plural , offset: 2 =1 {1} =-1 {-1} =3.14 {3.14} other {oo} }xyz")
    expect = ExpectMessageNode.ExpectTextThatContains("abc").ExpectPluralArg("num").ExpectOffset(2).ExpectVariant("=1", 1).ExpectTextThatContains("1").FinishVariant.ExpectVariant("=-1", -1).ExpectTextThatContains("-1").FinishVariant.ExpectVariant("=3.14", 3.14).ExpectTextThatContains("3.14").FinishVariant.ExpectVariant("other").ExpectTextThatContains("oo").FinishVariant.finishComplexArg.ExpectTextThatContains("xyz")
expect.CheckMatches(msg)
    msg = MessagePatternUtil.BuildMessageNode("a_{0,plural,other{num=#'#'=#'#'={1,number,##}!}}_z")
    expect = ExpectMessageNode.ExpectTextThatContains("a_").ExpectPluralArg(0).ExpectVariant("other").ExpectTextThatContains("num=").ExpectReplaceNumber.ExpectTextThatContains("#=").ExpectReplaceNumber.ExpectTextThatContains("#=").ExpectSimpleArg(1, "number", "##").ExpectTextThatContains("!").FinishVariant.finishComplexArg.ExpectTextThatContains("_z")
expect.CheckMatches(msg)
    msg = MessagePatternUtil.BuildMessageNode("a_{0,plural,offset:0 other{num=#!}}_z")
    expect = ExpectMessageNode.ExpectTextThatContains("a_").ExpectPluralArg(0).ExpectOffset(0).ExpectVariant("other").ExpectTextThatContains("num=").ExpectReplaceNumber.ExpectTextThatContains("!").FinishVariant.finishComplexArg.ExpectTextThatContains("_z")
expect.CheckMatches(msg)
proc TestSelectOrdinalArg*() =
    var msg: MessageNode = MessagePatternUtil.BuildMessageNode("abc{num, selectordinal, offset:17 =0{null} few{fff} other {oooo}}xyz")
    var expect: ExpectMessageNode = ExpectMessageNode.ExpectTextThatContains("abc").ExpectSelectOrdinalArg("num").ExpectOffset(17).ExpectVariant("=0", 0).ExpectTextThatContains("null").FinishVariant.ExpectVariant("few").ExpectTextThatContains("fff").FinishVariant.ExpectVariant("other").ExpectTextThatContains("oooo").FinishVariant.finishComplexArg.ExpectTextThatContains("xyz")
expect.CheckMatches(msg)
proc TestChoiceArg*() =
    var msg: MessageNode = MessagePatternUtil.BuildMessageNode("a_{0,choice,-∞ #-inf|  5≤ five | 99 # ninety'|'nine  }_z")
    var expect: ExpectMessageNode = ExpectMessageNode.ExpectTextThatContains("a_").ExpectChoiceArg(0).ExpectVariant("#", double.NegativeInfinity).ExpectTextThatContains("-inf").FinishVariant.ExpectVariant("≤", 5).ExpectTextThatContains(" five ").FinishVariant.ExpectVariant("#", 99).ExpectTextThatContains(" ninety|nine  ").FinishVariant.finishComplexArg.ExpectTextThatContains("_z")
expect.CheckMatches(msg)
proc TestComplexArgs*() =
    var msg: MessageNode = MessagePatternUtil.BuildMessageNode("I don't {a,plural,other{w'{'on't #'#'}} and " + "{b,select,other{shan't'}'}} '{'''know'''}' and " + "{c,choice,0#can't'|'}" + "{z,number,#'#'###.00'}'}.")
    var expect: ExpectMessageNode = ExpectMessageNode.ExpectTextThatContains("I don't ").ExpectPluralArg("a").ExpectVariant("other").ExpectTextThatContains("w{on't ").ExpectReplaceNumber.ExpectTextThatContains("#").FinishVariant.finishComplexArg.ExpectTextThatContains(" and ").ExpectSelectArg("b").ExpectVariant("other").ExpectTextThatContains("shan't}").FinishVariant.finishComplexArg.ExpectTextThatContains(" {'know'} and ").ExpectChoiceArg("c").ExpectVariant("#", 0).ExpectTextThatContains("can't|").FinishVariant.finishComplexArg.ExpectSimpleArg("z", "number", "#'#'###.00'}'").ExpectTextThatContains(".")
expect.CheckMatches(msg)
proc VariantText(v: VariantNode): String =
    return cast[TextNode](v.Message.GetContents[0]).Text
proc TestPluralVariantsByType*() =
    var msg: MessageNode = MessagePatternUtil.BuildMessageNode("{p,plural,a{A}other{O}=4{iv}b{B}other{U}=2{ii}}")
    var expect: ExpectMessageNode = ExpectMessageNode.ExpectPluralArg("p").ExpectVariant("a").ExpectTextThatContains("A").FinishVariant.ExpectVariant("other").ExpectTextThatContains("O").FinishVariant.ExpectVariant("=4", 4).ExpectTextThatContains("iv").FinishVariant.ExpectVariant("b").ExpectTextThatContains("B").FinishVariant.ExpectVariant("other").ExpectTextThatContains("U").FinishVariant.ExpectVariant("=2", 2).ExpectTextThatContains("ii").FinishVariant.finishComplexArg
    if !expect.Matches(msg):
        return
    var numericVariants: List<VariantNode> = List<VariantNode>
    var keywordVariants: List<VariantNode> = List<VariantNode>
    var other: VariantNode = cast[ArgNode](msg.GetContents[0]).ComplexStyle.GetVariantsByType(numericVariants, keywordVariants)
assertEquals("'other' selector", "other", other.Selector)
assertEquals("message string of first 'other'", "O", VariantText(other))
assertEquals("numericVariants.size()", 2, numericVariants.Count)
    var v: VariantNode = numericVariants[0]
assertEquals("numericVariants[0] selector", "=4", v.Selector)
assertEquals("numericVariants[0] selector value", 4.0, v.SelectorValue)
assertEquals("numericVariants[0] text", "iv", VariantText(v))
    v = numericVariants[1]
assertEquals("numericVariants[1] selector", "=2", v.Selector)
assertEquals("numericVariants[1] selector value", 2.0, v.SelectorValue)
assertEquals("numericVariants[1] text", "ii", VariantText(v))
assertEquals("keywordVariants.size()", 2, keywordVariants.Count)
    v = keywordVariants[0]
assertEquals("keywordVariants[0] selector", "a", v.Selector)
assertFalse("keywordVariants[0].isSelectorNumeric()", v.IsSelectorNumeric)
assertEquals("keywordVariants[0] text", "A", VariantText(v))
    v = keywordVariants[1]
assertEquals("keywordVariants[1] selector", "b", v.Selector)
assertFalse("keywordVariants[1].isSelectorNumeric()", v.IsSelectorNumeric)
assertEquals("keywordVariants[1] text", "B", VariantText(v))
proc TestSelectVariantsByType*() =
    var msg: MessageNode = MessagePatternUtil.BuildMessageNode("{s,select,a{A}other{O}b{B}other{U}}")
    var expect: ExpectMessageNode = ExpectMessageNode.ExpectSelectArg("s").ExpectVariant("a").ExpectTextThatContains("A").FinishVariant.ExpectVariant("other").ExpectTextThatContains("O").FinishVariant.ExpectVariant("b").ExpectTextThatContains("B").FinishVariant.ExpectVariant("other").ExpectTextThatContains("U").FinishVariant.finishComplexArg
    if !expect.Matches(msg):
        return
    var keywordVariants: IList<VariantNode> = List<VariantNode>
    var other: VariantNode = cast[ArgNode](msg.GetContents[0]).ComplexStyle.GetVariantsByType(nil, keywordVariants)
assertEquals("'other' selector", "other", other.Selector)
assertEquals("message string of first 'other'", "O", VariantText(other))
assertEquals("keywordVariants.size()", 2, keywordVariants.Count)
    var v: VariantNode = keywordVariants[0]
assertEquals("keywordVariants[0] selector", "a", v.Selector)
assertFalse("keywordVariants[0].isSelectorNumeric()", v.IsSelectorNumeric)
assertEquals("keywordVariants[0] text", "A", VariantText(v))
    v = keywordVariants[1]
assertEquals("keywordVariants[1] selector", "b", v.Selector)
assertFalse("keywordVariants[1].isSelectorNumeric()", v.IsSelectorNumeric)
assertEquals("keywordVariants[1] text", "B", VariantText(v))