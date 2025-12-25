# "Namespace: ICU4N.Dev.Test.Format"
type
  MessageRegressionTest = ref object


proc Test4074764*() =
    var pattern: String[] = @["Message without param", "Message with param:{0}", "Longer Message with param {0}"]
    var messageFormatter: MessageFormat = MessageFormat("")
    try:
messageFormatter.ApplyPattern(pattern[1])
        var paramArray: Object[] = @["BUG", DateTime]
        var tempBuffer: String = messageFormatter.Format(paramArray)
        if !tempBuffer.Equals("Message with param:BUG"):
Errln("MessageFormat with one param test failed.")
Logln("Formatted with one extra param : " + tempBuffer)
messageFormatter.ApplyPattern(pattern[0])
        tempBuffer = messageFormatter.Format(cast[object](nil))
        if !tempBuffer.Equals("Message without param"):
Errln("MessageFormat with no param test failed.")
Logln("Formatted with no params : " + tempBuffer)
        tempBuffer = messageFormatter.Format(paramArray)
        if !tempBuffer.Equals("Message without param"):
Errln("Formatted with arguments > subsitution failed. result = " + tempBuffer.ToString)
Logln("Formatted with extra params : " + tempBuffer)
    except Exception:
Errln("Exception when formatting with no params.")
proc Test4031438*() =
    var pattern1: String = "Impossible {1} has occurred -- status code is {0} and message is {2}."
    var pattern2: String = "Double '' Quotes {0} test and quoted '{1}' test plus 'other {2} stuff'."
    var messageFormatter: MessageFormat = MessageFormat("")
    try:
Logln("Apply with pattern : " + pattern1)
messageFormatter.ApplyPattern(pattern1)
        var paramArray: Object[] = @[cast[int](7)]
        var tempBuffer: String = messageFormatter.Format(paramArray)
        if !tempBuffer.Equals("Impossible {1} has occurred -- status code is 7 and message is {2}."):
Errln("Tests arguments < substitution failed")
Logln("Formatted with 7 : " + tempBuffer)
        var status: ParsePosition = ParsePosition(0)
        var objs: Object[] = messageFormatter.Parse(tempBuffer, status)
        if objs[paramArray.Length] != nil:
Errln("Parse failed with more than expected arguments")
          var i: int = 0
          while i < objs.Length:
              if objs[i] != nil && !objs[i].ToString.Equals(paramArray[i].ToString):
Errln("Parse failed on object " + objs[i] + " at index : " + i)
++i
        tempBuffer = messageFormatter.Format(cast[object](nil))
        if !tempBuffer.Equals("Impossible {1} has occurred -- status code is {0} and message is {2}."):
Errln("Tests with no arguments failed")
Logln("Formatted with null : " + tempBuffer)
Logln("Apply with pattern : " + pattern2)
messageFormatter.ApplyPattern(pattern2)
        tempBuffer = messageFormatter.Format(paramArray)
        if !tempBuffer.Equals("Double ' Quotes 7 test and quoted {1} test plus 'other {2} stuff'."):
Errln("quote format test (w/ params) failed.")
Logln("Formatted with params : " + tempBuffer)
        tempBuffer = messageFormatter.Format(cast[object](nil))
        if !tempBuffer.Equals("Double ' Quotes {0} test and quoted {1} test plus 'other {2} stuff'."):
Errln("quote format test (w/ null) failed.")
Logln("Formatted with null : " + tempBuffer)
Logln("toPattern : " + messageFormatter.ToPattern)
    except Exception:
Warnln("Exception when formatting in bug 4031438. " + foo.Message)
proc Test4052223*() =
    var pos: ParsePosition = ParsePosition(0)
    if pos.ErrorIndex != -1:
Errln("ParsePosition.getErrorIndex initialization failed.")
    var fmt: MessageFormat = MessageFormat("There are {0} apples growing on the {1} tree.")
    var str: String = "There is one apple growing on the peach tree."
    var objs: Object[] = fmt.Parse(str, pos)
Logln("unparsable string , should fail at " + pos.ErrorIndex)
    if pos.ErrorIndex == -1:
Errln("Bug 4052223 failed : parsing string " + str)
    pos.ErrorIndex = 4
    if pos.ErrorIndex != 4:
Errln("setErrorIndex failed, got " + pos.ErrorIndex + " instead of 4")
    if objs != nil:
Errln("objs should be null")
    var f: ChoiceFormat = ChoiceFormat("-1#are negative|0#are no or fraction|1#is one|1.0<is 1+|2#are two|2<are more than 2.")
    pos.Index = 0
    pos.ErrorIndex = -1
    var obj: object = f.Parse("are negative", pos)
    if pos.ErrorIndex != -1 && Convert.ToDouble(obj) == -1.0:
Errln("Parse with "are negative" failed, at " + pos.ErrorIndex)
    pos.Index = 0
    pos.ErrorIndex = -1
    obj = f.Parse("are no or fraction ", pos)
    if pos.ErrorIndex != -1 && Convert.ToDouble(obj) == 0.0:
Errln("Parse with "are no or fraction" failed, at " + pos.ErrorIndex)
    pos.Index = 0
    pos.ErrorIndex = -1
    obj = f.Parse("go postal", pos)
    if pos.ErrorIndex == -1 && !double.IsNaN(Convert.ToDouble(obj)):
Errln("Parse with "go postal" failed, at " + pos.ErrorIndex)
proc Test4104976*() =
    var limits: double[] = @[1, 20]
    var formats: String[] = @["xyz", "abc"]
    var cf: ChoiceFormat = ChoiceFormat(limits, formats)
    try:
Log("Compares to null is always false, returned : ")
Logln(        if cf.Equals(nil):
"TRUE"
        else:
"FALSE")
    except Exception:
Errln("ChoiceFormat.Equals(null) throws exception.")
proc Test4106659*() =
    var limits: double[] = @[1, 2, 3]
    var formats: String[] = @["one", "two"]
    var cf: ChoiceFormat = nil
    try:
        cf = ChoiceFormat(limits, formats)
    except Exception:
Logln("ChoiceFormat constructor should check for the array lengths")
        cf = nil
    if cf != nil:
Errln(cf.Format(5))
proc Test4106660*() =
    var limits: double[] = @[3, 1, 2]
    var formats: String[] = @["Three", "One", "Two"]
    var cf: ChoiceFormat = ChoiceFormat(limits, formats)
    var d: double = 5.0
    var str: String = cf.Format(d)
    if !str.Equals("Two"):
Errln("format(" + d + ") = " + cf.Format(d))
proc Test4114743*() =
    var originalPattern: String = "initial pattern"
    var mf: MessageFormat = MessageFormat(originalPattern)
    var illegalPattern: String = "ab { '}' de"
    try:
mf.ApplyPattern(illegalPattern)
Errln("illegal pattern: "" + illegalPattern + """)
    except ArgumentException:
        if illegalPattern.Equals(mf.ToPattern):
Errln("pattern after: "" + mf.ToPattern + """)
proc Test4116444*() =
    var patterns: String[] = @["", "one", "{0,date,short}"]
    var mf: MessageFormat = MessageFormat("")
      var i: int = 0
      while i < patterns.Length:
          var pattern: String = patterns[i]
mf.ApplyPattern(pattern)
          try:
              var array: Object[] = mf.Parse(nil, ParsePosition(0))
Logln("pattern: "" + pattern + """)
Log(" parsedObjects: ")
              if array != nil:
Log("{")
                    var j: int = 0
                    while j < array.Length:
                        if array[j] != nil:
Err(""" + array[j].ToString + """)
                        else:
Log("null")
                        if j < array.Length - 1:
Log(",")
++j
Log("}")
              else:
Log("null")
Logln("")
          except Exception:
Errln("pattern: "" + pattern + """)
Errln("  Exception: " + e.Message)
++i
proc Test4114739*() =
    var mf: MessageFormat = MessageFormat("<{0}>")
    var objs1: Object[] = nil
    var objs2: Object[] = @[]
    var objs3: Object[] = @[nil]
    try:
Logln("pattern: "" + mf.ToPattern + """)
Log("format(null) : ")
Logln(""" + mf.Format(objs1) + """)
Log("format({})   : ")
Logln(""" + mf.Format(objs2) + """)
Log("format({null}) :")
Logln(""" + mf.Format(objs3) + """)
    except Exception:
Errln("Exception thrown for null argument tests.")
proc Test4113018*() =
    var originalPattern: String = "initial pattern"
    var mf: MessageFormat = MessageFormat(originalPattern)
    var illegalPattern: String = "format: {0, xxxYYY}"
Logln("pattern before: "" + mf.ToPattern + """)
Logln("illegal pattern: "" + illegalPattern + """)
    try:
mf.ApplyPattern(illegalPattern)
Errln("Should have thrown IllegalArgumentException for pattern : " + illegalPattern)
    except ArgumentException:
        if illegalPattern.Equals(mf.ToPattern):
Errln("pattern after: "" + mf.ToPattern + """)
proc Test4106661*() =
    var fmt: ChoiceFormat = ChoiceFormat("-1#are negative| 0#are no or fraction | 1#is one |1.0<is 1+ |2#are two |2<are more than 2.")
Logln("Formatter Pattern : " + fmt.ToPattern)
Logln("Format with -INF : " + fmt.Format(double.NegativeInfinity))
Logln("Format with -1.0 : " + fmt.Format(-1.0))
Logln("Format with 0 : " + fmt.Format(0))
Logln("Format with 0.9 : " + fmt.Format(0.9))
Logln("Format with 1.0 : " + fmt.Format(1))
Logln("Format with 1.5 : " + fmt.Format(1.5))
Logln("Format with 2 : " + fmt.Format(2))
Logln("Format with 2.1 : " + fmt.Format(2.1))
Logln("Format with NaN : " + fmt.Format(Double.NaN))
Logln("Format with +INF : " + fmt.Format(double.PositiveInfinity))
proc Test4094906*() =
    var fmt: ChoiceFormat = ChoiceFormat("-∞<are negative|0<are no or fraction|1#is one|1.0<is 1+|∞<are many.")
    if !fmt.ToPattern.StartsWith("-∞<are negative|0.0<are no or fraction|1.0#is one|1.0<is 1+|∞<are many.", StringComparison.Ordinal):
Errln("Formatter Pattern : " + fmt.ToPattern)
Logln("Format with -INF : " + fmt.Format(double.NegativeInfinity))
Logln("Format with -1.0 : " + fmt.Format(-1.0))
Logln("Format with 0 : " + fmt.Format(0))
Logln("Format with 0.9 : " + fmt.Format(0.9))
Logln("Format with 1.0 : " + fmt.Format(1))
Logln("Format with 1.5 : " + fmt.Format(1.5))
Logln("Format with 2 : " + fmt.Format(2))
Logln("Format with +INF : " + fmt.Format(double.PositiveInfinity))
proc Test4118592*() =
    var mf: MessageFormat = MessageFormat("")
    var pattern: String = "{0,choice,1#YES|2#NO}"
    var prefix: String = ""
      var i: int = 0
      while i < 5:
          var formatted: String = prefix + "YES"
mf.ApplyPattern(prefix + pattern)
          prefix = "x"
          var objs: Object[] = mf.Parse(formatted, ParsePosition(0))
Logln(i + ". pattern :"" + mf.ToPattern + """)
Log(" "" + formatted + "" parsed as ")
          if objs == nil:
Logln("  null")
          else:
Logln("  " + objs[0])
++i
proc Test4118594*() =
    var mf: MessageFormat = MessageFormat("{0}, {0}, {0}")
    var forParsing: String = "x, y, z"
    var objs: Object[] = mf.Parse(forParsing, ParsePosition(0))
Logln("pattern: "" + mf.ToPattern + """)
Logln("text for parsing: "" + forParsing + """)
    if !objs[0].ToString.Equals("z"):
Errln("argument0: "" + objs[0] + """)
mf.SetCulture(CultureInfo("en-us"))
mf.ApplyPattern("{0,number,#.##}, {0,number,#.#}")
    var oldobjs: Object[] = @[3.1415]
    var result: String = mf.Format(oldobjs)
Logln("pattern: "" + mf.ToPattern + """)
Logln("text for parsing: "" + result + """)
    if !result.Equals("3.14, 3.1"):
Errln("result = " + result)
    var newobjs: Object[] = mf.Parse(result, ParsePosition(0))
    if Convert.ToDouble(newobjs[0]) != 3.1:
Errln("newobjs[0] = " + newobjs[0])
proc Test4105380*() =
    var patternText1: String = "The disk "{1}" contains {0}."
    var patternText2: String = "There are {0} on the disk "{1}""
    var form1: MessageFormat = MessageFormat(patternText1)
    var form2: MessageFormat = MessageFormat(patternText2)
    var filelimits: double[] = @[0, 1, 2]
    var filepart: String[] = @["no files", "one file", "{0,number} files"]
    var fileform: ChoiceFormat = ChoiceFormat(filelimits, filepart)
form1.SetFormat(1, fileform)
form2.SetFormat(0, fileform)
    var testArgs: Object[] = @[12373, "MyDisk"]
Logln(form1.Format(testArgs))
Logln(form2.Format(testArgs))
proc Test4120552*() =
    var mf: MessageFormat = MessageFormat("pattern")
    var texts: String[] = @["pattern", "pat", "1234"]
Logln("pattern: "" + mf.ToPattern + """)
      var i: int = 0
      while i < texts.Length:
          var pp: ParsePosition = ParsePosition(0)
          var objs: Object[] = mf.Parse(texts[i], pp)
Log("  text for parsing: "" + texts[i] + """)
          if objs == nil:
Logln("  (incorrectly formatted string)")
              if pp.ErrorIndex == -1:
Errln("Incorrect error index: " + pp.ErrorIndex)
          else:
Logln("  (correctly formatted string)")
++i
proc Test4142938*() =
    var pat: String = "''Vous'' {0,choice,0#n''|1#}avez sélectionneé " + "{0,choice,0#aucun|1#{0}} client{0,choice,0#s|1#|2#s} " + "personnel{0,choice,0#s|1#|2#s}."
    var mf: MessageFormat = MessageFormat(pat)
    var PREFIX: String[] = @["'Vous' n'avez sélectionneé aucun clients personnels.", "'Vous' avez sélectionneé ", "'Vous' avez sélectionneé "]
    var SUFFIX: String[] = @[nil, " client personnel.", " clients personnels."]
      var i: int = 0
      while i < 3:
          var @out: String = mf.Format(@[Integer.GetInstance(i)])
          if SUFFIX[i] == nil:
              if !@out.Equals(PREFIX[i]):
Errln("" + i + ": Got "" + @out + ""; Want "" + PREFIX[i] + """)
          else:
              if !@out.StartsWith(PREFIX[i], StringComparison.Ordinal) || !@out.EndsWith(SUFFIX[i], StringComparison.Ordinal):
Errln("" + i + ": Got "" + @out + ""; Want "" + PREFIX[i] + ""..."" + SUFFIX[i] + """)
++i
proc TestChoicePatternQuote*() =
    var DATA: String[] = @["0#can''t|1#can", "can't", "can", "0#'pound(#)=''#'''|1#xyz", "pound(#)='#'", "xyz", "0#'1<2 | 1≤1'|1#''", "1<2 | 1≤1", "'"]
      var i: int = 0
      while i < DATA.Length:
          try:
              var cf: ChoiceFormat = ChoiceFormat(DATA[i])
                var j: int = 0
                while j <= 1:
                    var @out: String = cf.Format(j)
                    if !@out.Equals(DATA[i + 1 + j]):
Errln("Fail: Pattern "" + DATA[i] + "" x " + j + " -> " + @out + "; want "" + DATA[i + 1 + j] + '"')
++j
              var pat: String = cf.ToPattern
              var pat2: String = ChoiceFormat(pat).ToPattern
              if !pat.Equals(pat2):
Errln("Fail: Pattern "" + DATA[i] + "" x toPattern -> "" + pat + '"')
              else:
Logln("Ok: Pattern "" + DATA[i] + "" x toPattern -> "" + pat + '"')
          except ArgumentException:
Errln("Fail: Pattern "" + DATA[i] + "" -> " + e)
          i = 3
proc Test4112104*() =
    var format: MessageFormat = MessageFormat("")
    try:
        if format.Equals(nil):
Errln("MessageFormat.Equals(null) returns false")
    except ArgumentNullException:
Errln("MessageFormat.Equals(null) throws " + e)
proc Test4169959*() =
Logln(MessageFormat.Format("This will {0}", @["work"]))
Logln(MessageFormat.Format("This will {0}", @[nil]))
proc Test4232154*() =
    var gotException: bool = false
    try:
MessageFormat("The date is {0:date}")
    except Exception:
        gotException = true
        if !e is ArgumentException:
            raise Exception("got wrong exception type")
        if "argument number too large at ".Equals(e.Message):
            raise Exception("got wrong exception message")
    if !gotException:
        raise Exception("didn't get exception for invalid input")
proc Test4293229*() =
    var format: MessageFormat = MessageFormat("'''{'0}'' '''{0}'''")
    var args: Object[] = @[nil]
    var expected: String = "'{0}' '{0}'"
    var result: String = format.Format(args)
    if !result.Equals(expected):
        raise Exception("wrong format result - expected "" + expected + "", got "" + result + """)
proc TestBugTestsWithNamesArguments*() =
      var pattern1: String = "Impossible {arg1} has occurred -- status code is {arg0} and message is {arg2}."
      var pattern2: String = "Double '' Quotes {ARG_ZERO} test and quoted '{ARG_ONE}' test plus 'other {ARG_TWO} stuff'."
      var messageFormatter: MessageFormat = MessageFormat("")
      try:
Logln("Apply with pattern : " + pattern1)
messageFormatter.ApplyPattern(pattern1)
          var paramsMap: IDictionary<string, object> = Dictionary<string, object>
          paramsMap["arg0"] = 7
          var tempBuffer: String = messageFormatter.Format(paramsMap)
          if !tempBuffer.Equals("Impossible {arg1} has occurred -- status code is 7 and message is {arg2}."):
Errln("Tests arguments < substitution failed")
Logln("Formatted with 7 : " + tempBuffer)
          var status: ParsePosition = ParsePosition(0)
          var objs = messageFormatter.ParseToMap(tempBuffer, status)
          if objs.Get("arg1") != nil || objs.Get("arg2") != nil:
Errln("Parse failed with more than expected arguments")
          for pair in objs:
              if pair.Value != nil && !pair.Value.ToString.Equals(paramsMap.Get(pair.Key).ToString):
Errln("Parse failed on object " + pair.Value + " with argument name : " + pair.Key)
          tempBuffer = messageFormatter.Format(cast[object](nil))
          if !tempBuffer.Equals("Impossible {arg1} has occurred -- status code is {arg0} and message is {arg2}."):
Errln("Tests with no arguments failed")
Logln("Formatted with null : " + tempBuffer)
Logln("Apply with pattern : " + pattern2)
messageFormatter.ApplyPattern(pattern2)
paramsMap.Clear
          paramsMap["ARG_ZERO"] = 7
          tempBuffer = messageFormatter.Format(paramsMap)
          if !tempBuffer.Equals("Double ' Quotes 7 test and quoted {ARG_ONE} test plus 'other {ARG_TWO} stuff'."):
Errln("quote format test (w/ params) failed.")
Logln("Formatted with params : " + tempBuffer)
          tempBuffer = messageFormatter.Format(cast[object](nil))
          if !tempBuffer.Equals("Double ' Quotes {ARG_ZERO} test and quoted {ARG_ONE} test plus 'other {ARG_TWO} stuff'."):
Errln("quote format test (w/ null) failed.")
Logln("Formatted with null : " + tempBuffer)
Logln("toPattern : " + messageFormatter.ToPattern)
      except Exception:
Warnln("Exception when formatting in bug 4031438. " + foo.Message)
      var pos: ParsePosition = ParsePosition(0)
      if pos.ErrorIndex != -1:
Errln("ParsePosition.getErrorIndex initialization failed.")
      var fmt: MessageFormat = MessageFormat("There are {numberOfApples} apples growing on the {whatKindOfTree} tree.")
      var str: String = "There is one apple growing on the peach tree."
      var objs = fmt.ParseToMap(str, pos)
Logln("unparsable string , should fail at " + pos.ErrorIndex)
      if pos.ErrorIndex == -1:
Errln("Bug 4052223 failed : parsing string " + str)
      pos.ErrorIndex = 4
      if pos.ErrorIndex != 4:
Errln("setErrorIndex failed, got " + pos.ErrorIndex + " instead of 4")
      if objs != nil:
Errln("unparsable string, should return null")
      var patterns: String[] = @["", "one", "{namedArgument,date,short}"]
      var mf: MessageFormat = MessageFormat("")
        var i: int = 0
        while i < patterns.Length:
            var pattern: String = patterns[i]
mf.ApplyPattern(pattern)
            try:
                var objs = mf.ParseToMap(nil, ParsePosition(0))
Logln("pattern: "" + pattern + """)
Log(" parsedObjects: ")
                if objs != nil:
Log("{")
                    var first: bool = true
                    for pair in objs:
                        if first:
                          first = false
                        else:
Log(",")
                        if pair.Value != nil:
Err(""" + pair.Value.ToString + """)
                        else:
Log("null")
Log("}")
                else:
Log("null")
Logln("")
            except Exception:
Errln("pattern: "" + pattern + """)
Errln("  Exception: " + e.Message)
++i
      var mf: MessageFormat = MessageFormat("<{arg}>")
      var objs1: IDictionary<string, object> = nil
      var objs2: IDictionary<string, object> = Dictionary<string, object>
      var objs3: IDictionary<string, object> = Dictionary<string, object>
      objs3["arg"] = nil
      try:
Logln("pattern: "" + mf.ToPattern + """)
Log("format(null) : ")
Logln(""" + mf.Format(objs1) + """)
Log("format({})   : ")
Logln(""" + mf.Format(objs2) + """)
Log("format({null}) :")
Logln(""" + mf.Format(objs3) + """)
      except Exception:
Errln("Exception thrown for null argument tests.")
      var argName: String = "something_stupid"
      var mf: MessageFormat = MessageFormat("{" + argName + "}, {" + argName + "}, {" + argName + "}")
      var forParsing: String = "x, y, z"
      var objs = mf.ParseToMap(forParsing, ParsePosition(0))
Logln("pattern: "" + mf.ToPattern + """)
Logln("text for parsing: "" + forParsing + """)
      if !objs.Get(argName).ToString.Equals("z"):
Errln("argument0: "" + objs.Get(argName) + """)
mf.SetCulture(CultureInfo("en-us"))
mf.ApplyPattern("{" + argName + ",number,#.##}, {" + argName + ",number,#.#}")
      var oldobjs = Dictionary<string, object>
      oldobjs[argName] = 3.1415
      var result: String = mf.Format(oldobjs)
Logln("pattern: "" + mf.ToPattern + """)
Logln("text for parsing: "" + result + """)
      if !result.Equals("3.14, 3.1"):
Errln("result = " + result)
      var newobjs = mf.ParseToMap(result, ParsePosition(0))
      if Convert.ToDouble(newobjs.Get(argName)) != 3.1:
Errln("newobjs.get(argName) = " + newobjs.Get(argName))
      var patternText1: String = "The disk "{diskName}" contains {numberOfFiles}."
      var patternText2: String = "There are {numberOfFiles} on the disk "{diskName}""
      var form1: MessageFormat = MessageFormat(patternText1)
      var form2: MessageFormat = MessageFormat(patternText2)
      var filelimits: double[] = @[0, 1, 2]
      var filepart: String[] = @["no files", "one file", "{numberOfFiles,number} files"]
      var fileform: ChoiceFormat = ChoiceFormat(filelimits, filepart)
form1.SetFormat(1, fileform)
form2.SetFormat(0, fileform)
      var testArgs = Dictionary<string, object>
      testArgs["diskName"] = "MyDisk"
      testArgs["numberOfFiles"] = 12373
Logln(form1.Format(testArgs))
Logln(form2.Format(testArgs))
      var format: MessageFormat = MessageFormat("'''{'myNamedArgument}'' '''{myNamedArgument}'''")
      var args = Dictionary<string, object>
      var expected: String = "'{myNamedArgument}' '{myNamedArgument}'"
      var result: String = format.Format(args)
      if !result.Equals(expected):
          raise Exception("wrong format result - expected "" + expected + "", got "" + result + """)