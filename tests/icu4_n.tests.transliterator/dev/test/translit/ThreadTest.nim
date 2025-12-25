# "Namespace: ICU4N.Dev.Test.Translit"
type
  ThreadTest = ref object
    threads: List[Worker] = List<Worker>
    iterationCount: int = 50000
    WORDS: seq[String] = @["edgar", "allen", "poe"]

proc TestThreads*() =
    if TestFmwk.GetExhaustiveness >= 9:
        iterationCount = 1000000
      var i: int = 0
      while i < 8:
          var thread: Worker = Worker(self)
threads.Add(thread)
thread.Start
++i
    var expectedCount: long = 0
    for thread in threads:
thread.Join
        if expectedCount == 0:
            expectedCount = thread.count
        else:
            if expectedCount != thread.count:
Errln("Threads gave differing results.")
type
  Worker = ref object
    count: long = 0
    outerInstance: ThreadTest

proc newWorker(outerInstance: ThreadTest): Worker =
  self.outerInstance = outerInstance
proc Run*() =
    var tx: Transliterator = Transliterator.GetInstance("Latin-Thai")
      var loop: int = 0
      while loop < outerInstance.iterationCount:
          for s in WORDS:
              count = tx.Transliterate(s).Length
++loop
proc TestAnyTranslit*() =
    var tx: Transliterator = Transliterator.GetInstance("Any-Latin")
    var threads: List<Thread> = List<Thread>
      var i: int = 0
      while i < 8:
threads.Add(Thread(<unhandled: nnkLambda>))
++i
    for th in threads:
th.Start
    for th in threads:
th.Join
proc TestConcurrentTransliterationCyrillic*() =
    var tx: Transliterator = Transliterator.GetInstance("Any-Latin;Latin-ASCII;[\u0000-\u0020\u007f-\uffff] Remove")
    var jobCount: int = 2000
    var results = ConcurrentBag<string>
    var countdown = CountdownEvent(jobCount)
      var i: int = 0
      while i < jobCount:
ThreadPool.QueueUserWorkItem(<unhandled: nnkLambda>)
++i
countdown.Wait
    var actual: string = string.Join(",", results.Distinct)
Assert.AreEqual("WB1289", actual)