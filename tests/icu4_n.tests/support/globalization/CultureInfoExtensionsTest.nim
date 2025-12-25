# "Namespace: ICU4N.Globalization"
type
  CultureInfoExtensionsTest = ref object


proc TestToUCultureInfoAllCultures*() =
    var cultures = CultureInfoUtil.GetAllCultures
    for culture in cultures:
Assert.IsNotNull(culture.ToUCultureInfo.culture)