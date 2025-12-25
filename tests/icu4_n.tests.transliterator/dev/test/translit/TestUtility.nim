# "Namespace: ICU4N.Dev.Test.Translit"
type
  TestUtility = ref object


proc Hex*(ch: char): String =
    var foo: String = Convert.ToString(ch, 16).ToUpperInvariant
    return "0000".Substring(0, 4 - foo.Length) + foo
proc Hex*(ch: int): String =
    var foo: String = Convert.ToString(ch, 16).ToUpperInvariant
    return "00000000".Substring(0, 4 - foo.Length) + foo
proc Hex*(s: String): String =
    return Hex(s, ",")
proc Hex*(s: String, sep: String): String =
    if s.Length == 0:
      return ""
    var result: String = Hex(s[0])
      var i: int = 1
      while i < s.Length:
          result = sep
          result = Hex(s[i])
++i
    return result
proc Replace*(source: String, toBeReplaced: String, replacement: String): String =
    var results: StringBuffer = StringBuffer
    var len: int = toBeReplaced.Length
      var i: int = 0
      while i < source.Length:
          if source.IndexOf(toBeReplaced, i, len, StringComparison.OrdinalIgnoreCase) == i:
results.Append(replacement)
              i = len - 1
          else:
results.Append(source[i])
++i
    return results.ToString
proc ReplaceAll*(source: String, set: UnicodeSet, replacement: String): String =
    var results: StringBuffer = StringBuffer
    var cp: int
      var i: int = 0
      while i < source.Length:
          cp = UTF16.CharAt(source, i)
          if set.Contains(cp):
results.Append(replacement)
          else:
UTF16.Append(results, cp)
          i = UTF16.GetCharCount(cp)
    return results.ToString