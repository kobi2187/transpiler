# "Namespace: ICU4N.Dev.Test.Lang"
type
  UCharacterThreadTest = ref object


proc newUCharacterThreadTest(): UCharacterThreadTest =

proc TestUCharactersGetName*() =
    var threads: List<GetNameThread> = List<GetNameThread>
      var t: int = 0
      while t < 20:
          var codePoint: int = 47 + t
          var correctName: String = UChar.GetName(codePoint)
          var thread: GetNameThread = GetNameThread(codePoint, correctName)
thread.Start
threads.Add(thread)
++t
    for thread in threads:
thread.Join
        if !thread.correctName.Equals(thread.actualName):
Errln("FAIL, expected "" + thread.correctName + "", got "" + thread.actualName + """)
type
  GetNameThread = ref object
    codePoint: int
    correctName: String
    actualName: String

proc newGetNameThread(codePoint: int, correctName: String): GetNameThread =
  self.codePoint = codePoint
  self.correctName = correctName
proc Run*() =
      var i: int = 0
      while i < 10000:
          actualName = UChar.GetName(codePoint)
          if !correctName.Equals(actualName):
              break
++i