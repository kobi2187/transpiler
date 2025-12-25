# "Namespace: ICU4N.Dev.Test.StringPrep"
type
  TestStringPrep = ref object
    mixed_prep_data: seq[String] = @["OWNER@", "GROUP@", "EVERYONE@", "INTERACTIVE@", "NETWORK@", "DIALUP@", "BATCH@", "ANONYMOUS@", "AUTHENTICATED@", "र्म्क्षेत्@slip129-37-118-146.nc.us.ibm.net", "श्रीमद्@saratoga.pe.utexas.edu", "भगवद्गीता@dial-120-45.ots.utexas.edu", "अध्याय@woo-085.dorms.waller.net", "अर्जुन@hd30-049.hil.compuserve.com", "विषाद@pem203-31.pe.ttu.edu", "योग@56K-227.MaxTNT3.pdq.net", "धृतराष्ट्र@dial-36-2.ots.utexas.edu", "उवाचृ@slip129-37-23-152.ga.us.ibm.net", "धर्मक्षेत्रे@ts45ip119.cadvision.com", "कुरुक्षेत्रे@sdn-ts-004txaustP05.dialsprint.net", "समवेता@bar-tnt1s66.erols.com", "युयुत्सवः@101.st-louis-15.mo.dial-access.att.net", "मामकाः@h92-245.Arco.COM", "पाण्डवाश्चैव@dial-13-2.ots.utexas.edu", "किमकुर्वत@net-redynet29.datamarkets.com.ar", "संजव@ccs-shiva28.reacciun.net.ve", "రఘురామ్@7.houston-11.tx.dial-access.att.net", "విశ్వనాధ@ingw129-37-120-26.mo.us.ibm.net", "ఆనంద్@dialup6.austintx.com", "వద్దిరాజు@dns2.tpao.gov.tr", "రాజీవ్@slip129-37-119-194.nc.us.ibm.net", "కశరబాద@cs7.dillons.co.uk.203.119.193.in-addr.arpa", "సంజీవ్@swprd1.innovplace.saskatoon.sk.ca", "కశరబాద@bikini.bologna.maraut.it", "సంజీబ్@node91.subnet159-198-79.baxter.com", "సెన్గుప్త@cust19.max5.new-york.ny.ms.uu.net", "అమరేంద్ర@balexander.slip.andrew.cmu.edu", "హనుమానుల@pool029.max2.denver.co.dynip.alter.net", "రవి@cust49.max9.new-york.ny.ms.uu.net", "కుమార్@s61.abq-dialin2.hollyberry.com", "విశ్వనాధ@गनेश.sanjose.ibm.com", "ఆదిత్య@www.à³¯.com", "కంద్రేగుల@www.Â¤.com", "శ్రీధర్@www.Â£.com", "కంటమశెట్టి@%", "మాధవ్@\\", "దెశెట్టి@www.!.com", "test@www.$.com", "help@Ã¼.com"]

proc TestNFS4MixedPrep*() =
      var i: int = 0
      while i < mixed_prep_data.Length:
          try:
              var src: String = mixed_prep_data[i]
              var dest: byte[] = NFS4StringPrep.MixedPrepare(Encoding.UTF8.GetBytes(src))
              var destString: String = Encoding.UTF8.GetString(dest)
              var destIndex: int = destString.IndexOf('@')
              if destIndex < 0:
Errln("Delimiter @ disappeared from the output!")
          except Exception:
Errln("mixed_prepare for string: " + mixed_prep_data[i] + " failed with " + e.ToString)
++i
      var src: String = "OWNER@oss.software.ibm.com"
      try:
          var dest: byte[] = NFS4StringPrep.MixedPrepare(Encoding.UTF8.GetBytes(src))
          if dest != nil:
Errln("Did not get the expected exception")
      except Exception:
Logln("mixed_prepare for string: " + src + " passed with " + e.ToString)
proc TestCISPrep*() =
      var i: int = 0
      while i < TestData.conformanceTestCases.Length:
          var testCase: TestData.ConformanceTestCase = TestData.conformanceTestCases[i]
          var src: String = testCase.input
          var expected: Exception = testCase.expected
          var expectedDest: String = testCase.output
          try:
              var dest: byte[] = NFS4StringPrep.CISPrepare(Encoding.UTF8.GetBytes(src))
              var destString: String = Encoding.UTF8.GetString(dest)
              if !expectedDest.Equals(destString, StringComparison.OrdinalIgnoreCase):
Errln("Did not get the expected output for nfs4_cis_prep at index " + i)
          except Exception:
              if expected != nil && !expected.Equals(e):
Errln("Did not get the expected exception: " + e.ToString)
++i
proc TestCSPrep*() =
    var src: String = "세계의모든사람들이ليه한국어를이해한다면"
    try:
NFS4StringPrep.CSPrepare(Encoding.UTF8.GetBytes(src), false)
    except Exception:
Errln("Got unexpected exception: " + e.ToString)
    try:
        src = "www.à³¯.com"
        var dest: byte[] = NFS4StringPrep.CSPrepare(Encoding.UTF8.GetBytes(src), false)
        var destStr: String = Encoding.UTF8.GetString(dest)
        if !src.Equals(destStr):
Errln("Did not get expected output. Expected: " + Prettify(src) + " Got: " + Prettify(destStr))
    except Exception:
Errln("Got unexpected exception: " + e.ToString)
    try:
        src = "THISISATEST"
        var dest: byte[] = NFS4StringPrep.CSPrepare(Encoding.UTF8.GetBytes(src), false)
        var destStr: String = Encoding.UTF8.GetString(dest)
        if !src.ToLowerInvariant.Equals(destStr):
Errln("Did not get expected output. Expected: " + Prettify(src) + " Got: " + Prettify(destStr))
    except Exception:
Errln("Got unexpected exception: " + e.ToString)
    try:
        src = "THISISATEST"
        var dest: byte[] = NFS4StringPrep.CSPrepare(Encoding.UTF8.GetBytes(src), true)
        var destStr: String = Encoding.UTF8.GetString(dest)
        if !src.Equals(destStr):
Errln("Did not get expected output. Expected: " + Prettify(src) + " Got: " + Prettify(destStr))
    except Exception:
Errln("Got unexpected exception: " + e.ToString)
proc TestCoverage*() =
    if StringPrepFormatException("coverage", 0, "", 0, 0) == nil:
Errln("Construct StringPrepFormatException(String, int, String, int, int)")
proc TestGetInstance*() =
    var neg_num_cases: int[] = @[-100, -50, -10, -5, -2, -1]
      var i: int = 0
      while i < neg_num_cases.Length:
          try:
StringPrep.GetInstance(cast[StringPrepProfile](neg_num_cases[i]))
Errln("StringPrep.GetInstance(int) expected an exception for " + "an invalid parameter of " + neg_num_cases[i])
          except Exception:

++i
    var max_profile_cases: StringPrepProfile[] = @[StringPrepProfile.Rfc4518LdapCaseInsensitive + 1, StringPrepProfile.Rfc4518LdapCaseInsensitive + 2, StringPrepProfile.Rfc4518LdapCaseInsensitive + 5, StringPrepProfile.Rfc4518LdapCaseInsensitive + 10]
      var i: int = 0
      while i < max_profile_cases.Length:
          try:
StringPrep.GetInstance(max_profile_cases[i])
Errln("StringPrep.GetInstance(int) expected an exception for " + "an invalid parameter of " + max_profile_cases[i])
          except Exception:

++i
    var cases: int[] = @[0, 1, cast[int](StringPrepProfile.Rfc4518LdapCaseInsensitive)]
      var i: int = 0
      while i < cases.Length:
          try:
StringPrep.GetInstance(cast[StringPrepProfile](cases[i]))
          except Exception:
Errln("StringPrep.GetInstance(int) did not expected an exception for " + "an valid parameter of " + cases[i])
++i
proc TestPrepare*() =
    var sp: StringPrep = StringPrep.GetInstance(0)
    try:
        if !sp.Prepare("dummy", 0).Equals("dummy"):
Errln("StringPrep.prepare(String,int) was suppose to return " + "'dummy'")
    except Exception:
Errln("StringPrep.prepare(String,int) was not suppose to return " + "an exception.")
proc TestStringPrepFormatException*() =
    var locales: CultureInfo[] = @[CultureInfo("en-US"), CultureInfo("fr"), CultureInfo("zh-Hans")]
    var rules: String = "This is a very odd little set of rules, just for testing, you know..."
    var exceptions: StringPrepFormatException[] = seq[StringPrepFormatException]
      var i: int = 0
      while i < locales.Length:
          exceptions[i] = StringPrepFormatException(locales[i].ToString, cast[StringPrepErrorType](i), rules, i, i)
          i = 1
proc TestStringPrepFormatExceptionEquals*() =
    var sppe: StringPrepFormatException = StringPrepFormatException("dummy", 0, "dummy", 0, 0)
    var sppe_clone: StringPrepFormatException = StringPrepFormatException("dummy", 0, "dummy", 0, 0)
    var sppe1: StringPrepFormatException = StringPrepFormatException("dummy1", cast[StringPrepErrorType](1), "dummy1", 0, 0)
    if sppe.Equals(0):
Errln("StringPrepFormatException.Equals(Object) is suppose to return false when " + "passing integer '0'")
    if sppe.Equals(0.0):
Errln("StringPrepFormatException.Equals(Object) is suppose to return false when " + "passing float/double '0.0'")
    if sppe.Equals("0"):
Errln("StringPrepFormatException.Equals(Object) is suppose to return false when " + "passing string '0'")
    if !sppe.Equals(sppe):
Errln("StringPrepFormatException.Equals(Object) is suppose to return true when " + "comparing to the same object")
    if !sppe.Equals(sppe_clone):
Errln("StringPrepFormatException.Equals(Object) is suppose to return true when " + "comparing to the same initiated object")
    if sppe.Equals(sppe1):
Errln("StringPrepFormatException.Equals(Object) is suppose to return false when " + "comparing to another object that isn't the same")
proc TestGetError*() =
      var i: int = 0
      while i < 5:
          var sppe: StringPrepFormatException = StringPrepFormatException("dummy", cast[StringPrepErrorType](i), "dummy", 0, 0)
          if cast[int](sppe.Error) != i:
Errln("StringPrepParseExcpetion.getError() was suppose to return " + i + " but got " + sppe.Error)
++i
proc TestSetPreContext*() =
    var WordAtLeast16Characters: String = "abcdefghijklmnopqrstuvwxyz"
      var i: int = 0
      while i < 5:
          try:
              var sppe: StringPrepFormatException = StringPrepFormatException("dummy", cast[StringPrepErrorType](i), WordAtLeast16Characters, 0, 0)
sppe.ToString
              sppe = StringPrepFormatException(WordAtLeast16Characters, cast[StringPrepErrorType](i), "dummy", 0, 0)
sppe.ToString
          except Exception:
Errln("StringPrepFormatException.PreContext was not suppose to return an exception")
++i