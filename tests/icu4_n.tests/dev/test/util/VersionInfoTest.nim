# "Namespace: ICU4N.Dev.Test.Util"
type
  VersionInfoTest = ref object
    INSTANCE_INVALID_STRING_: seq[String] = @["a", "-1", "-1.0", "-1.0.0", "-1.0.0.0", "0.-1", "0.0.-1", "0.0.0.-1", "256", "256.0", "256.0.0", "256.0.0.0", "0.256", "0.0.256", "0.0.0.256", "1.2.3.4.5"]
    INSTANCE_VALID_STRING_: seq[String] = @["255", "255.255", "255.255.255", "255.255.255.255"]
    INSTANCE_INVALID_INT_: seq[int] = @[@[-1], @[-1, 0], @[-1, 0, 0], @[-1, 0, 0, 0], @[0, -1], @[0, 0, -1], @[0, 0, 0, -1], @[256], @[256, 0], @[256, 0, 0], @[256, 0, 0, 0], @[0, 256], @[0, 0, 256], @[0, 0, 0, 256]]
    INSTANCE_VALID_INT_: seq[int] = @[@[255], @[255, 255], @[255, 255, 255], @[255, 255, 255, 255]]
    COMPARE_NOT_EQUAL_STRING_: seq[String] = @["2.0.0.0", "3.0.0.0"]
    COMPARE_NOT_EQUAL_INT_: seq[int] = @[@[2, 0, 0, 0], @[3, 0, 0, 0]]
    COMPARE_EQUAL_STRING_: seq[String] = @["2.0.0.0", "2.0.0", "2.0", "2"]
    COMPARE_EQUAL_INT_: seq[int] = @[@[2], @[2, 0], @[2, 0, 0], @[2, 0, 0, 0]]
    COMPARE_LESS_: seq[String] = @["0", "0.0.0.1", "0.0.1", "0.1", "1", "2", "2.1", "2.1.1", "2.1.1.1"]
    GET_STRING_: seq[String] = @["0", "1.1", "2.1.255", "3.1.255.100"]
    GET_INT_: seq[int] = @[@[0], @[1, 1], @[2, 1, 255], @[3, 1, 255, 100]]
    GET_RESULT_: seq[int] = @[0, 0, 0, 0, 1, 1, 0, 0, 2, 1, 255, 0, 3, 1, 255, 100]
    TOSTRING_STRING_: seq[String] = @["0", "1.1", "2.1.255", "3.1.255.100"]
    TOSTRING_INT_: seq[int] = @[@[0], @[1, 1], @[2, 1, 255], @[3, 1, 255, 100]]
    TOSTRING_RESULT_: seq[String] = @["0.0.0.0", "1.1.0.0", "2.1.255.0", "3.1.255.100"]

proc newVersionInfoTest(): VersionInfoTest =

proc TestInstance*() =
      var i: int = 0
      while i < INSTANCE_INVALID_STRING_.Length:
          try:
VersionInfo.GetInstance(INSTANCE_INVALID_STRING_[i])
Errln(""" + INSTANCE_INVALID_STRING_[i] + "" should produce an exception")
          except Exception:
Logln("PASS: "" + INSTANCE_INVALID_STRING_[i] + "" failed as expected")
++i
      var i: int = 0
      while i < INSTANCE_VALID_STRING_.Length:
          try:
VersionInfo.GetInstance(INSTANCE_VALID_STRING_[i])
          except Exception:
Errln(""" + INSTANCE_VALID_STRING_[i] + "" should produce an valid version")
++i
      var i: int = 0
      while i < INSTANCE_INVALID_INT_.Length:
          try:
GetInstance(INSTANCE_INVALID_INT_[i])
Errln("invalid ints should produce an exception")
          except Exception:
Logln("PASS: "" + String.Format(StringFormatter.CurrentCulture, "{0}", cast[object](INSTANCE_INVALID_INT_[i])) + "" failed as expected")
++i
      var i: int = 0
      while i < INSTANCE_VALID_INT_.Length:
          try:
GetInstance(INSTANCE_VALID_INT_[i])
          except Exception:
Errln("valid ints should not produce an exception")
++i
proc TestCompare*() =
      var i: int = 0
      while i < COMPARE_NOT_EQUAL_STRING_.Length:
          var v1: VersionInfo = VersionInfo.GetInstance(COMPARE_NOT_EQUAL_STRING_[i])
          var v2: VersionInfo = VersionInfo.GetInstance(COMPARE_NOT_EQUAL_STRING_[i + 1])
          if v1.CompareTo(v2) == 0:
Errln(COMPARE_NOT_EQUAL_STRING_[i] + " should not equal " + COMPARE_NOT_EQUAL_STRING_[i + 1])
          i = 2
      var i: int = 0
      while i < COMPARE_NOT_EQUAL_INT_.Length:
          var v1: VersionInfo = GetInstance(COMPARE_NOT_EQUAL_INT_[i])
          var v2: VersionInfo = GetInstance(COMPARE_NOT_EQUAL_INT_[i + 1])
          if v1.CompareTo(v2) == 0:
Errln(string.Format(StringFormatter.CurrentCulture, "{0} should not equal {1}", cast[object](COMPARE_NOT_EQUAL_INT_[i]), cast[object](COMPARE_NOT_EQUAL_INT_[i + 1])))
          i = 2
      var i: int = 0
      while i < COMPARE_EQUAL_STRING_.Length - 1:
          var v1: VersionInfo = VersionInfo.GetInstance(COMPARE_EQUAL_STRING_[i])
          var v2: VersionInfo = VersionInfo.GetInstance(COMPARE_EQUAL_STRING_[i + 1])
          if v1.CompareTo(v2) != 0:
Errln(COMPARE_EQUAL_STRING_[i] + " should equal " + COMPARE_EQUAL_STRING_[i + 1])
++i
      var i: int = 0
      while i < COMPARE_EQUAL_INT_.Length - 1:
          var v1: VersionInfo = GetInstance(COMPARE_EQUAL_INT_[i])
          var v2: VersionInfo = GetInstance(COMPARE_EQUAL_INT_[i + 1])
          if v1.CompareTo(v2) != 0:
Errln(string.Format(StringFormatter.CurrentCulture, "{0} should equal {1}", cast[object](COMPARE_EQUAL_INT_[i]), cast[object](COMPARE_EQUAL_INT_[i + 1])))
++i
      var i: int = 0
      while i < COMPARE_LESS_.Length - 1:
          var v1: VersionInfo = VersionInfo.GetInstance(COMPARE_LESS_[i])
          var v2: VersionInfo = VersionInfo.GetInstance(COMPARE_LESS_[i + 1])
          if v1.CompareTo(v2) >= 0:
Errln(COMPARE_LESS_[i] + " should be less than " + COMPARE_LESS_[i + 1])
          if v2.CompareTo(v1) <= 0:
Errln(COMPARE_LESS_[i + 1] + " should be greater than " + COMPARE_LESS_[i])
++i
proc TestGetter*() =
      var i: int = 0
      while i < GET_STRING_.Length:
          var v: VersionInfo = VersionInfo.GetInstance(GET_STRING_[i])
          if v.Major != GET_RESULT_[i << 2] || v.Minor != GET_RESULT_[i << 2 + 1] || v.Milli != GET_RESULT_[i << 2 + 2] || v.Micro != GET_RESULT_[i << 2 + 3]:
Errln(GET_STRING_[i] + " should return major=" + GET_RESULT_[i << 2] + " minor=" + GET_RESULT_[i << 2 + 1] + " milli=" + GET_RESULT_[i << 2 + 2] + " micro=" + GET_RESULT_[i << 2 + 3])
          v = GetInstance(GET_INT_[i])
          if v.Major != GET_RESULT_[i << 2] || v.Minor != GET_RESULT_[i << 2 + 1] || v.Milli != GET_RESULT_[i << 2 + 2] || v.Micro != GET_RESULT_[i << 2 + 3]:
Errln(GET_STRING_[i] + " should return major=" + GET_RESULT_[i << 2] + " minor=" + GET_RESULT_[i << 2 + 1] + " milli=" + GET_RESULT_[i << 2 + 2] + " micro=" + GET_RESULT_[i << 2 + 3])
++i
proc TesttoString*() =
      var i: int = 0
      while i < TOSTRING_STRING_.Length:
          var v: VersionInfo = VersionInfo.GetInstance(TOSTRING_STRING_[i])
          if !v.ToString.Equals(TOSTRING_RESULT_[i]):
Errln("toString() for " + TOSTRING_STRING_[i] + " should produce " + TOSTRING_RESULT_[i])
          v = GetInstance(TOSTRING_INT_[i])
          if !v.ToString.Equals(TOSTRING_RESULT_[i]):
Errln(string.Format(StringFormatter.CurrentCulture, "toString() for {0} should produce {1}", cast[object](TOSTRING_INT_[i]), cast[object](TOSTRING_RESULT_[i])))
++i
proc TestComparable*() =
      var i: int = 0
      while i < COMPARE_NOT_EQUAL_STRING_.Length:
          var v1: VersionInfo = VersionInfo.GetInstance(COMPARE_NOT_EQUAL_STRING_[i])
          var v2: VersionInfo = VersionInfo.GetInstance(COMPARE_NOT_EQUAL_STRING_[i + 1])
          if v1.CompareTo(v2) == 0:
Errln(COMPARE_NOT_EQUAL_STRING_[i] + " should not equal " + COMPARE_NOT_EQUAL_STRING_[i + 1])
          i = 2
      var i: int = 0
      while i < COMPARE_EQUAL_STRING_.Length - 1:
          var v1: VersionInfo = VersionInfo.GetInstance(COMPARE_EQUAL_STRING_[i])
          var v2: VersionInfo = VersionInfo.GetInstance(COMPARE_EQUAL_STRING_[i + 1])
          if v1.CompareTo(v2) != 0:
Errln(COMPARE_EQUAL_STRING_[i] + " should equal " + COMPARE_EQUAL_STRING_[i + 1])
++i
proc TestEqualsAndHashCode*() =
    var v1234a: VersionInfo = VersionInfo.GetInstance(1, 2, 3, 4)
    var v1234b: VersionInfo = VersionInfo.GetInstance(1, 2, 3, 4)
    var v1235: VersionInfo = VersionInfo.GetInstance(1, 2, 3, 5)
assertEquals("v1234a and v1234b", v1234a, v1234b)
assertEquals("v1234a.hashCode() and v1234b.hashCode()", v1234a.GetHashCode, v1234b.GetHashCode)
assertNotEquals("v1234a and v1235", v1234a, v1235)
proc GetInstance(data: seq[int]): VersionInfo =
    case data.Length
    of 1:
        return VersionInfo.GetInstance(data[0])
    of 2:
        return VersionInfo.GetInstance(data[0], data[1])
    of 3:
        return VersionInfo.GetInstance(data[0], data[1], data[2])
    else:
        return VersionInfo.GetInstance(data[0], data[1], data[2], data[3])
proc TestMultiThread*() =
    var numThreads: int = 20
    var workers: GetInstanceWorker[] = seq[GetInstanceWorker]
    var results: VersionInfo[][] = Support.Collections.Arrays.NewRectangularArray(numThreads, 255)
      var i: int = 0
      while i < workers.Length:
          workers[i] = GetInstanceWorker(i, results[i])
++i
      var i: int = 0
      while i < workers.Length:
workers[i].Start
++i
      var i: int = 0
      while i < workers.Length:
workers[i].Join
++i
      var i: int = 1
      while i < results.Length:
            var j: int = 0
            while j < results[0].Length:
                if results[0][j] != results[i][j]:
Errln("Different instance at index " + j + " Thread#" + i)
++j
++i
type
  GetInstanceWorker = ref object
    results: seq[VersionInfo]

proc newGetInstanceWorker(serialNumber: int, results: seq[VersionInfo]): GetInstanceWorker =
newThreadJob("GetInstnaceWorker#" + serialNumber)
  self.results = results
proc Run*() =
      var i: int = 0
      while i < results.Length:
          results[i] = VersionInfo.GetInstance(i)
++i