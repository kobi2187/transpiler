# "Namespace: ICU4N.Dev.Test.StringPrep"
type
  IDNAConformanceTest = ref object


proc TestConformance*() =
    var inputData: SortedDictionary<long, IDictionary<string, string>> = nil
    try:
        inputData = ReadInput.GetInputData
    except EncoderFallbackException:
Errln(e.ToString)
        return
    except IOException:
Errln(e.ToString)
        return
    var keyMap = inputData.Keys
    for element in keyMap:
        var tempHash = inputData.Get(element)
        var passfail: String = cast[String](tempHash.Get("passfail"))
        var desc: String = cast[String](tempHash.Get("desc"))
        var type: String = cast[String](tempHash.Get("type"))
        var namebase: String = cast[String](tempHash.Get("namebase"))
        var nameutf8: String = cast[String](tempHash.Get("nameutf8"))
        var namezone: String = cast[String](tempHash.Get("namezone"))
        var failzone1: String = cast[String](tempHash.Get("failzone1"))
        var failzone2: String = cast[String](tempHash.Get("failzone2"))
        namebase = StringReplace(namebase)
        namezone = StringReplace(namezone)
        var result: String = nil
        var failed: bool = false
        if "toascii".Equals(tempHash.Get("type")):
            try:
                if desc.IndexOf("UseSTD3ASCIIRules", StringComparison.OrdinalIgnoreCase) == -1:
                    result = IDNA.ConvertIDNToASCII(namebase, IDNA2003Options.AllowUnassigned).ToString
                else:
                    result = IDNA.ConvertIDNToASCII(namebase, IDNA2003Options.UseSTD3Rules).ToString
            except StringPrepFormatException:
                failed = true
            if "pass".Equals(passfail):
                if !namezone.Equals(result):
PrintInfo(desc, namebase, nameutf8, namezone, failzone1, failzone2, result, type, passfail)
Errln("	 pass fail standard is pass, but failed")
                else:
PrintInfo(desc, namebase, nameutf8, namezone, failzone1, failzone2, result, type, passfail)
Logln("	passed")
            if "fail".Equals(passfail):
                if failed:
PrintInfo(desc, namebase, nameutf8, namezone, failzone1, failzone2, result, type, passfail)
Logln("passed")
                else:
PrintInfo(desc, namebase, nameutf8, namezone, failzone1, failzone2, result, type, passfail)
Errln("	 pass fail standard is fail, but no exception thrown out")

        elif "tounicode".Equals(tempHash.Get("type")):
            try:
                if desc.IndexOf("UseSTD3ASCIIRules", StringComparison.OrdinalIgnoreCase) == -1:
                    result = IDNA.ConvertIDNToUnicode(namebase, IDNA2003Options.AllowUnassigned)
                else:
                    result = IDNA.ConvertIDNToUnicode(namebase, IDNA2003Options.UseSTD3Rules)
            except StringPrepFormatException:
                failed = true
            if "pass".Equals(passfail):
                if !namezone.Equals(result):
PrintInfo(desc, namebase, nameutf8, namezone, failzone1, failzone2, result, type, passfail)
Errln("	 Did not get the expected result. Expected: " + Prettify(namezone) + " Got: " + Prettify(result))
                else:
PrintInfo(desc, namebase, nameutf8, namezone, failzone1, failzone2, result, type, passfail)
Logln("	passed")
            if "fail".Equals(passfail):
                if failed || namebase.Equals(result):
PrintInfo(desc, namebase, nameutf8, namezone, failzone1, failzone2, result, type, passfail)
Logln("	passed")
                else:
PrintInfo(desc, namebase, nameutf8, namezone, failzone1, failzone2, result, type, passfail)
Errln("	 pass fail standard is fail, but no exception thrown out")
            var arrayToReturnToPool: char[] = ArrayPool[char].Shared.Rent(namebase.Length + 16)
            var charsLength: int = 0
            try:
                if desc.IndexOf("UseSTD3ASCIIRules", StringComparison.OrdinalIgnoreCase) == -1:
                    failed = !IDNA.TryConvertIDNToUnicode(namebase.AsSpan, arrayToReturnToPool, charsLength, IDNA2003Options.AllowUnassigned, _)
                else:
                    failed = !IDNA.TryConvertIDNToUnicode(namebase.AsSpan, arrayToReturnToPool, charsLength, IDNA2003Options.UseSTD3Rules, _)
            finally:
ArrayPool[char].Shared.Return(arrayToReturnToPool)
            if "pass".Equals(passfail):
                if !namezone.Equals(result):
PrintInfo(desc, namebase, nameutf8, namezone, failzone1, failzone2, result, type, passfail)
Errln("	 Did not get the expected result. Expected: " + Prettify(namezone) + " Got: " + Prettify(result))
                else:
PrintInfo(desc, namebase, nameutf8, namezone, failzone1, failzone2, result, type, passfail)
Logln("	passed")
            if "fail".Equals(passfail):
                if failed || namebase.Equals(result):
PrintInfo(desc, namebase, nameutf8, namezone, failzone1, failzone2, result, type, passfail)
Logln("	passed")
                else:
PrintInfo(desc, namebase, nameutf8, namezone, failzone1, failzone2, result, type, passfail)
Errln("	 pass fail standard is fail, but no exception thrown out")
        else:
            continue
proc PrintInfo(desc: String, namebase: String, nameutf8: String, namezone: String, failzone1: String, failzone2: String, result: String, type: String, passfail: String) =
Logln("desc:	" + desc)
Log("	")
Logln("type:	" + type)
Log("	")
Logln("pass fail standard:	" + passfail)
Log("	")
Logln("namebase:	" + namebase)
Log("	")
Logln("nameutf8:	" + nameutf8)
Log("	")
Logln("namezone:	" + namezone)
Log("	")
Logln("failzone1:	" + failzone1)
Log("	")
Logln("failzone2:	" + failzone2)
Log("	")
Logln("result:	" + result)
proc StringReplace(str: String): String =
    var result: StringBuffer = StringBuffer
    var chars: char[] = str.ToCharArray
    var sbTemp: StringBuffer = StringBuffer
      var i: int = 0
      while i < chars.Length:
          if '<' == chars[i]:
              sbTemp = StringBuffer
              while '>' != chars[i + 1]:
sbTemp.Append(chars[++i])
              var toBeInserted: int = int.Parse(sbTemp.ToString, NumberStyles.HexNumber, CultureInfo.InvariantCulture)
              if toBeInserted >> 16 == 0:
result.Append(cast[char](toBeInserted))
              else:
                  var utf16String: String = UTF16.ValueOf(toBeInserted)
                  var charsTemp: char[] = utf16String.ToCharArray
                    var j: int = 0
                    while j < charsTemp.Length:
result.Append(charsTemp[j])
++j

          elif '>' == chars[i]:
              continue
          else:
result.Append(chars[i])
++i
    return result.ToString
type
  ReadInput = ref object


proc GetInputData*(): SortedDictionary<long, IDictionary<string, string>> =
    var result: SortedDictionary<long, IDictionary<string, string>> = SortedDictionary<long, IDictionary<string, string>>
    var @in: TextReader = TestUtil.GetDataReader("IDNATestInput.txt", "utf-8")
    try:
        var tempStr: String = nil
        var records: int = 0
        var firstLine: bool = true
        var hashItem = Dictionary<string, string>
        while         tempStr = @in.ReadLine != nil:
            if firstLine:
                if "=====".Equals(tempStr):
                  continue
                firstLine = false
            if "".Equals(tempStr):
                continue
            var attr: String = ""
            var body: String = ""
            var postion: int = tempStr.IndexOf(':')
            if postion > -1:
                attr = tempStr.Substring(0, postion).Trim
                body = tempStr.Substring(postion + 1).Trim
                while nil != body && body.Length > 0 && '\' == body[body.Length - 1]:
                    body = body.Substring(0, body.Length - 1)
                    body = "
"
                    tempStr = @in.ReadLine
                    body = tempStr
            hashItem[attr] = body
            if "=====".Equals(tempStr):
                result[cast[long](records)] = hashItem
                hashItem = Dictionary<string, string>
++records
                continue
    finally:
@in.Dispose
    return result