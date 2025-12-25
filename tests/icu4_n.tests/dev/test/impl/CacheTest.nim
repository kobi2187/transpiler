# "Namespace: ICU4N.Dev.Test.Impl"
type
  CacheTest = ref object


proc newCacheTest(): CacheTest =

proc TestNullCacheValue*() =
    var nv: CacheValue<object> = CacheValue[object].GetInstance(nil)
assertTrue("null CacheValue isNull()", nv.IsNull)
assertTrue("null CacheValue get()==null", nv.Get == nil)
proc TestStrongCacheValue*() =
    var wasStrong: bool = CacheValue[object].FutureInstancesWillBeStrong
    CacheValue[object].Strength = CacheValueStrength.Strong
assertTrue("setStrength(STRONG).futureInstancesWillBeStrong()", CacheValue[object].FutureInstancesWillBeStrong)
    var sv: CacheValue<Object> = CacheValue[Object].GetInstance(<unhandled: nnkLambda>)
assertFalse("strong CacheValue not isNull()", sv.IsNull)
assertTrue("strong CacheValue get()==same", sv.Get == self)
    if !wasStrong:
        CacheValue[object].Strength = CacheValueStrength.Soft
proc TestSoftCacheValue*() =
    var wasStrong: bool = CacheValue[object].FutureInstancesWillBeStrong
    CacheValue[object].Strength = CacheValueStrength.Soft
assertFalse("setStrength(SOFT).futureInstancesWillBeStrong()", CacheValue[object].FutureInstancesWillBeStrong)
    var sv: CacheValue<Object> = CacheValue[object].GetInstance(<unhandled: nnkLambda>)
assertFalse("soft CacheValue not isNull()", sv.IsNull)
    var v: Object = sv.Get
assertTrue("soft CacheValue get()==same or null", v == self || v == nil)
    if wasStrong:
        CacheValue[object].Strength = CacheValueStrength.Strong