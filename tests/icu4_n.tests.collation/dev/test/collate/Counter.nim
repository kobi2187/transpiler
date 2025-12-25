# "Namespace: ICU4N.Dev.Test.Collate"
type
  Counter = ref object
    map: IDictionary[T, RWInt64]
    comparer: IComparer[T]

proc newCounter(): Counter =
newCounter(nil)
proc newCounter(comparer: IComparer[T]): Counter =
  if self.comparer != nil:
      self.comparer = comparer
      map = SortedDictionary<T, RWInt64>(self.comparer)
  else:
      map = Dictionary<T, RWInt64>
type
  RWInt64 = ref object
    uniqueCount: int
    value: long
    forceUnique: int

proc newRWInt64(): RWInt64 =
  forceUnique = Interlocked.Increment(uniqueCount) - 1
proc CompareTo*(that: RWInt64): int =
    if that.value < value:
      return -1
    if that.value > value:
      return 1
    if self == that:
      return 0
    if that.forceUnique < forceUnique:
      return -1
    return 1
proc ToString*(): string =
    return value.ToString(CultureInfo.InvariantCulture)
proc Add*(obj: T, countValue: long): Counter<T> =
    if !map.TryGetValue(obj,     var count: RWInt64):
      map[obj] =       count = RWInt64
    count.value = countValue
    return self
proc GetCount*(obj: T): long =
    return Get(obj)
proc Get*(obj: T): long =
    return     if !map.TryGetValue(obj,     var count: RWInt64):
0
    else:
count.value
proc Clear*(): Counter<T> =
map.Clear
    return self
proc GetTotal*(): long =
    var count: long = 0
    for pair in map:
        count = pair.Value.value
    return count
proc ItemCount(): int =
    return self.Count
type
  Entry = ref object
    count: RWInt64
    value: T
    uniqueness: int

proc newEntry(count: RWInt64, value: T, uniqueness: int): Entry =
  self.count = count
  self.value = value
  self.uniqueness = uniqueness
type
  EntryComparer = ref object
    countOrdering: int
    byValue: IComparer[T]

proc newEntryComparer(ascending: bool, byValue: IComparer[T]): EntryComparer =
  countOrdering =   if ascending:
1
  else:
-1
  self.byValue = byValue
proc Compare*(o1: Entry, o2: Entry): int =
    if o1.count.value < o2.count.value:
      return -countOrdering
    if o1.count.value > o2.count.value:
      return countOrdering
    if byValue != nil:
        return byValue.Compare(o1.value, o2.value)
    return o1.uniqueness - o2.uniqueness
proc GetKeysetSortedByCount*(ascending: bool): ICollection<T> =
    return GetKeysetSortedByCount(ascending, nil)
proc GetKeysetSortedByCount*(ascending: bool, byValue: IComparer[T]): ICollection<T> =
    var count_key: ISet<Entry> = SortedSet<Entry>(EntryComparer(ascending, byValue))
    var counter: int = 0
    for key in map.Keys:
count_key.Add(Entry(map[key], key, ++counter))
    var result: IList<T> = List<T>
    for entry in count_key:
result.Add(entry.value)
    return result
proc GetKeysetSortedByKey*(): ICollection<T> =
    var s: ISet<T> = SortedSet<T>(comparer)
s.UnionWith(map.Keys)
    return s
proc Keys(): ICollection[T] =
    return map.Keys
proc GetEnumerator*(): IEnumerator<T> =
    return map.Keys.GetEnumerator
proc GetEnumerator(): IEnumerator =
    return GetEnumerator
proc GetMap*(): IDictionary<T, RWInt64> =
    return map
proc Count(): int =
    return map.Count
proc ToString*(): String =
    return map.ToString
proc UnionWith*(keys: ICollection[T], delta: int): Counter<T> =
    for key in keys:
Add(key, delta)
    return self
proc UnionWith*(keys: Counter[T]): Counter<T> =
    for key in keys:
Add(key, keys.GetCount(key))
    return self
proc CompareTo*(o: Counter[T]): int =
      let i = map.Keys.GetEnumerator
<unhandled: nnkDefer>
        let j = o.map.Keys.GetEnumerator
<unhandled: nnkDefer>
        while true:
            var goti: bool = i.MoveNext
            var gotj: bool = j.MoveNext
            if !goti || !gotj:
                return                 if goti:
1
                else:
                    if gotj:
-1
                    else:
0
            var ii: T = i.Current
            var jj: T = i.Current
            var result: int = cast[IComparable<T>](ii).CompareTo(jj)
            if result != 0:
                return result
            var iv: long = map[ii].value
            var jv: long = o.map[jj].value
            if iv != jv:
              return               if iv < jv:
-1
              else:
0
proc Increment*(key: T): Counter<T> =
    return Add(key, 1)
proc ContainsKey*(key: T): bool =
    return map.ContainsKey(key)
proc Equals*(o: object): bool =
    return map.Equals(o)
proc GetHashCode*(): int =
    return map.GetHashCode
proc Remove*(key: T): Counter<T> =
map.Remove(key)
    return self