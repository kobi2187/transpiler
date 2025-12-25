# "Namespace: ICU4N.Globalization"
type
  UCultureInfoTest_CurrentContext = ref object


proc TestCurrentCulturesAsync*() =
    var newCurrentCulture = UCultureInfo(    if UCultureInfo.CurrentCulture.Name.Equals("ja-JP", StringComparison.OrdinalIgnoreCase):
"en-US"
    else:
"ja-JP")
    var newCurrentUICulture = UCultureInfo(    if UCultureInfo.CurrentUICulture.Name.Equals("ja-JP", StringComparison.OrdinalIgnoreCase):
"en-US"
    else:
"ja-JP")
      let resource = ThreadCultureChange(newCurrentCulture, newCurrentUICulture)
<unhandled: nnkDefer>
      var t: Task = Task.Factory.StartNew(<unhandled: nnkLambda>, CancellationToken.None, TaskCreationOptions.None, TaskScheduler.Default)
cast[IAsyncResult](t).AsyncWaitHandle.WaitOne
t.Wait
proc TestCurrentCulture*() =
    var newCulture = UCultureInfo(    if UCultureInfo.CurrentCulture.Name.Equals("ja_JP", StringComparison.OrdinalIgnoreCase):
"ar_SA"
    else:
"ja_JP")
      let resource = ThreadCultureChange(newCulture)
<unhandled: nnkDefer>
Assert.AreEqual(UCultureInfo.CurrentCulture, newCulture)
    newCulture = UCultureInfo("de_DE@collation=phonebook")
      let resource = ThreadCultureChange(newCulture)
<unhandled: nnkDefer>
Assert.AreEqual(UCultureInfo.CurrentCulture, newCulture)
Assert.AreEqual("de_DE@collation=phonebook", newCulture.ToString)
proc TestCurrentCulture_Set_Null_ThrowsArgumentNullException*() =
Assert.Throws(<unhandled: nnkLambda>)
proc TestCurrentUICulture*() =
    var newUICulture = UCultureInfo(    if UCultureInfo.CurrentUICulture.Name.Equals("ja_JP", StringComparison.OrdinalIgnoreCase):
"ar_SA"
    else:
"ja_JP")
      let resource = ThreadCultureChange(UCultureInfo.CurrentCulture, newUICulture)
<unhandled: nnkDefer>
Assert.AreEqual(UCultureInfo.CurrentUICulture, newUICulture)
    newUICulture = UCultureInfo("de_DE@collation=phonebook")
      let resource = ThreadCultureChange(UCultureInfo.CurrentCulture, newUICulture)
<unhandled: nnkDefer>
Assert.AreEqual(UCultureInfo.CurrentUICulture, newUICulture)
Assert.AreEqual("de_DE@collation=phonebook", newUICulture.ToString)