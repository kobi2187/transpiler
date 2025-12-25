# "Namespace: ICU4N.Dev.Test.Collate"
type
  CollationThreadTest = ref object
    threadTestData: seq[String] = LoadCollationThreadTestData

proc LoadCollationThreadTestData(): string[] =
    var collator: Collator = Collator.GetInstance(CultureInfo("pl"))
    var temporaryData: String[] = @["Banc Seókdyaaouq Pfuymjec", "BSH óy", "ABB - óg", "Gókpo Adhdoetpwtx Twxma, qm. Ilnudx", "Góbjh Zcgopqmjidw Dyhlu, ky. Npyamr", "Gódxb Slfduvgdwfi Qhreu, ao. Adyfqx", "Góten Emrmbmttgne Rtpir, rx. Mgmpjy", "Gókjo Hciqkymfcds Jpudo, ti. Ueceedbm (tkvyj vplrnpoq)", "Przjrpnbhrflnoo Dbiccp Lnmikfhsuoós Tgfhlpqoso / ZAD ENR", "Bang Nbygmoyc Ndónipcryjtzm", "Citjkëd Qgmgvr Er. w u.x.", "Dyrscywp Kvoifmyxo Ivvór Lbyxtrwnzp", "Géawk Ssqenl Pk. c r.g.", "Nesdoé Ilwbay Z.U.", "Poczsb Lrdtqg", "Pocafu Tgbmpn - wwg zo Mpespnzdllqk", "Polyvmg Z.C.", "POLUHONANQ FO", "Polrpycn", "Poleeaw-Rqzghgnnj R.W.", "Polyto Sgrgcvncz", "Polixj Tyfcóvcga Gbkjxfóf Tuogcybbbkyd C.U.", "Poltmzzlrkwt", "Polefgb Oiqefrkq", "Polrfdk Kónvyrfot Xuzbzzn f Ujmfwkdbnzh E.U. Wxkfiwss", "Polxtcf Hfowus Zzobblfm N.I.", "POLJNXO ZVYU L.A.", "PP Lowyr Rmknyoew", "Pralpe", "Preyojy Qnrxr", "PRK -5", "PRONENC U.P.", "Prowwyq & Relnda Hxkvauksnn Znyord Tz. w t.o.", "Propydv Afobbmhpg", "Proimpoupvp", "Probfo Hfttyr", "Propgi Lutgumnj X.W. BL", "Prozkch K.E.", "Progiyvzr Erejqk T.W.", "Prooxwq-Ydglovgk J.J.", "PTU Ntcw Lwkxjk S.M. UYF", "PWN", "PWP", "PZU I.D. Tlpzmhax", "PZU ioii A.T. Yqkknryu - bipdq badtg 500/9", "Qumnl-Udffq", "Radmvv", "Railoggeqd Aewy Fwlmsp K.S. Ybrqjgyr", "Remhmxkx Ewuhxbg", "Renafwp Sapnqr io v z.n.", "Repqbpuuo", "Resflig", "Rocqz Mvwftutxozs VQ", "Rohkui", "RRC", "Samgtzg Fkbulcjaaqv Ollllq Ad. l l.v.", "Schelrlw Fu. t z.x.", "Schemxgoc Axvufoeuh", "Siezsxz Eb. n r.h", "Sikj Wyvuog", "Sobcwssf Oy. q o.s. Kwaxj", "Sobpxpoc Fb. w q.h. Elftx", "Soblqeqs Kpvppc RH - tbknhjubw siyaenc Njsjbpx Buyshpgyv", "Sofeaypq FJ", "Stacyok Qurqjw Hw. f c.h.", "STOWN HH", "Stopjhmq Prxhkakjmalkvdt Weqxejbyig Wgfplnvk D.C.", "STRHAEI Clydqr Ha. d z.j.", "Sun Clvaqupknlk", "TarfAml", "Tchukm Rhwcpcvj Cc. v y.a.", "Teco Nyxm Rsvzkx pm. J a.t.", "Tecdccaty", "Telruaet Nmyzaz Twwwuf", "Tellrwihv Xvtjle N.U.", "Telesjedc Boewsx A.F", "tellqfwiqkv dinjlrnyit yktdhlqquihzxr (ohvso)", "Tetft Kna Ab. j l.z.", "Thesch", "Totqucvhcpm Gejxkgrz Is. e k.i.", "Towajgixetj Ngaayjitwm fj csxm Mxebfj Sbocok X.H.", "Toyfon Meesp Neeban Jdsjmrn sz v z.w.", "TRAJQ NZHTA Li. n x.e. - Vghfmngh", "Triuiu", "Tripsq", "TU ENZISOP ZFYIPF V.U.", "TUiX Kscdw G.G.", "TVN G.A.", "Tycd", "Unibjqxv rdnbsn - ZJQNJ XCG / Wslqfrk", "Unilcs - hopef ps 20 nixi", "UPC Gwwmru Ds. g o.r.", "Vaidgoav", "Vatyqzcgqh Kjnnsy GQ WT", "Volhz", "Vos Jviggogjt Iyqhlm Ih. w j.y. (fbshoihdnb)", "WARMFC E.D.", "Wincqk Pqadskf", "WKRD", "Wolk Pyug", "WPRV", "WSiI", "Wurag XZ", "Zacrijl B.B.", "Zakja Tziaboysenum Squlslpp - Diifw V.D.", "Zakgat Meqivadj Nrpxlekmodx s Bbymjozge W.Y.", "Zjetxpbkpgj Mmhhgohasjtpkjd Uwucubbpdj K.N.", "ZREH"]
Sort(temporaryData, collator)
    return temporaryData
proc Scramble(data: seq[String], r: System.Random) =
      var i: int = 0
      while i < data.Length:
          var ix: int = r.Next(data.Length)
          var s: String = data[i]
          data[i] = data[ix]
          data[ix] = s
++i
proc Sort(data: seq[String], collator: Collator) =
Array.Sort(data, collator)
proc VerifySort(data: seq[String]): bool =
      var i: int = 0
      while i < data.Length:
          if !data[i].Equals(threadTestData[i]):
              return false
++i
    return true
type
  Control = ref object
    go: bool
    fail: String

proc Start() =
acquire(self)
      try:
          go = true
Monitor.PulseAll(self)
      finally:
        finally:
release(self)
proc Stop() =
acquire(self)
      try:
          go = false
Monitor.PulseAll(self)
      finally:
        finally:
release(self)
proc Go(): bool =
    return go
proc Fail(msg: String) =
    fail = msg
Stop
type
  Test = ref object
    data: seq[String]
    collator: Collator
    name: String
    control: Control
    r: System.Random

proc newTest(name: String, data: seq[String], collator: Collator, r: System.Random, control: Control): Test =
  self.name = name
  self.data = data
  self.collator = collator
  self.control = control
  self.r = r
proc Run*() =
    try:
acquire(control)
          try:
              while !control.Go:
Monitor.Wait(control)
          finally:
            finally:
release(control)
        while control.Go:
Scramble(self.data, r)
Sort(self.data, self.collator)
            if !VerifySort(self.data):
control.Fail(name + ": incorrect sort")
    except IndexOutOfRangeException:
control.Fail(name + " " + e.ToString)
proc RunThreads(threads: seq[Thread], control: Control) =
      var i: int = 0
      while i < threads.Length:
threads[i].Start
++i
control.Start
    var stopTime: long = Time.CurrentTimeMilliseconds + 5000
    while true:
Thread.Sleep(100)
        if notcontrol.Go && Time.CurrentTimeMilliseconds < stopTime:
            break
control.Stop
      var i: int = 0
      while i < threads.Length:
threads[i].Join
++i
    if control.fail != nil:
Errln(control.fail)
proc TestThreads*() =
    var theCollator: Collator = Collator.GetInstance(CultureInfo("pl"))
    var r: Random = Random
    var control: Control = Control
    var threads: Thread[] = seq[Thread]
      var i: int = 0
      while i < threads.Length:
          var coll: Collator
          coll = cast[Collator](theCollator.Clone)
          var test: Test = Test("Collation test thread" + i, cast[string[]](threadTestData.Clone), coll, r, control)
          threads[i] = Thread(<unhandled: nnkLambda>)
++i
RunThreads(threads, control)
proc TestFrozen*() =
    var theCollator: Collator = Collator.GetInstance(CultureInfo("pl"))
theCollator.Freeze
    var r: Random = Random
    var control: Control = Control
    var threads: Thread[] = seq[Thread]
      var i: int = 0
      while i < threads.Length:
          var test: Test = Test("Frozen collation test thread " + i, cast[string[]](threadTestData.Clone), theCollator, r, control)
          threads[i] = Thread(<unhandled: nnkLambda>)
++i
RunThreads(threads, control)