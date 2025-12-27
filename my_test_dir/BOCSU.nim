# "Namespace: ICU4N.Impl.Coll"
type BOCSU = ref object
  SLOPE_MIN_: int = 3
  SLOPE_MAX_: int = 0xf
  SLOPE_MIDDLE_: int = 0x81
  SLOPE_TAIL_COUNT_: int = SLOPE_MAX_ - SLOPE_MIN_ + 1
  SLOPE_MAX_BYTES_: int = 4
  SLOPE_SINGLE_: int = 80
  SLOPE_LEAD_2_: int = 42
  SLOPE_LEAD_3_: int = 3
  SLOPE_REACH_POS_1_: int = SLOPE_SINGLE_
  SLOPE_REACH_NEG_1_: int = -SLOPE_SINGLE_
  SLOPE_REACH_POS_2_: int = SLOPE_LEAD_2_ * SLOPE_TAIL_COUNT_ + SLOPE_LEAD_2_ - 1
  SLOPE_REACH_NEG_2_: int = -SLOPE_REACH_POS_2_ - 1
  SLOPE_REACH_POS_3_: int = SLOPE_LEAD_3_ * SLOPE_TAIL_COUNT_ * SLOPE_TAIL_COUNT_ + SLOPE_LEAD_3_ - 1 * SLOPE_TAIL_COUNT_ + SLOPE_TAIL_COUNT_ - 1
  SLOPE_REACH_NEG_3_: int = -SLOPE_REACH_POS_3_ - 1
  SLOPE_START_POS_2_: int = SLOPE_MIDDLE_ + SLOPE_SINGLE_ + 1
  SLOPE_START_POS_3_: int = SLOPE_START_POS_2_ + SLOPE_LEAD_2_
  SLOPE_START_NEG_2_: int = SLOPE_MIDDLE_ + SLOPE_REACH_NEG_1_
  SLOPE_START_NEG_3_: int = SLOPE_START_NEG_2_ - SLOPE_LEAD_2_

proc WriteIdenticalLevelRun*(prev: int, s: ReadOnlySpan[char], sink: ByteArrayWrapper): int =
  var i: int = 0
  var length: int = s.Length
  while i < length:
    EnsureAppendCapacity(sink, 16, s.Length * 2)
    var buffer: byte[] = sink.Bytes
    var capacity: int = buffer.Length
    var p: int = sink.Length
    var lastSafe: int = capacity - SLOPE_MAX_BYTES_
    while i < length && p <= lastSafe:
      if prev < 0x4e00 || prev >= 0xa000:
        prev = prev & ~0x7 - SLOPE_REACH_NEG_1_
      else:
        prev = 0x9ff - SLOPE_REACH_POS_2_
      var c: int = Character.CodePointAt(s, i)
      i = Character.CharCount(c)
      if c == 0xfffe:
        buffer[++p] = 2
        prev = 0
      else:
        p = WriteDiff(c - prev, buffer, p)
        prev = c
    sink.Length = p
  return prev
proc EnsureAppendCapacity(sink: ByteArrayWrapper, minCapacity: int, desiredCapacity: int) =
  var remainingCapacity: int = sink.Bytes.Length - sink.Length
  if remainingCapacity >= minCapacity:
    return
  if desiredCapacity < minCapacity:
    desiredCapacity = minCapacity
  sink.EnsureCapacity(sink.Length + desiredCapacity)
proc GetNegDivMod(number: int, factor: int): long =
  var modulo: int = number % factor
  var result: long = number / factor
  if modulo < 0:
    --result
    modulo = factor
  return result << 32 | cast[uint](modulo)
proc WriteDiff(diff: int, buffer: seq[byte], offset: int): int =
  if diff >= SLOPE_REACH_NEG_1_:
    if diff <= SLOPE_REACH_POS_1_:
      buffer[++offset] = cast[byte](SLOPE_MIDDLE_ + diff)

    elif diff <= SLOPE_REACH_POS_2_:
      buffer[++offset] = cast[byte](SLOPE_START_POS_2_ + diff / SLOPE_TAIL_COUNT_)
      buffer[++offset] = cast[byte](SLOPE_MIN_ + diff % SLOPE_TAIL_COUNT_)
    else:
      if diff <= SLOPE_REACH_POS_3_:
        buffer[offset + 2] = cast[byte](SLOPE_MIN_ + diff % SLOPE_TAIL_COUNT_)
        diff = SLOPE_TAIL_COUNT_
        buffer[offset + 1] = cast[byte](SLOPE_MIN_ + diff % SLOPE_TAIL_COUNT_)
        buffer[offset] = cast[byte](SLOPE_START_POS_3_ + diff / SLOPE_TAIL_COUNT_)
        offset = 3
      else:
        buffer[offset + 3] = cast[byte](SLOPE_MIN_ + diff % SLOPE_TAIL_COUNT_)
        diff = SLOPE_TAIL_COUNT_
        buffer[offset + 2] = cast[byte](SLOPE_MIN_ + diff % SLOPE_TAIL_COUNT_)
        diff = SLOPE_TAIL_COUNT_
        buffer[offset + 1] = cast[byte](SLOPE_MIN_ + diff % SLOPE_TAIL_COUNT_)
        buffer[offset] = cast[byte](SLOPE_MAX_)
        offset = 4
  else:
    var division: long = GetNegDivMod(diff, SLOPE_TAIL_COUNT_)
    var modulo: int = cast[int](division)
    if diff >= SLOPE_REACH_NEG_2_:
      diff = cast[int](division >> 32)
      buffer[++offset] = cast[byte](SLOPE_START_NEG_2_ + diff)
      buffer[++offset] = cast[byte](SLOPE_MIN_ + modulo)

    elif diff >= SLOPE_REACH_NEG_3_:
      buffer[offset + 2] = cast[byte](SLOPE_MIN_ + modulo)
      diff = cast[int](division >> 32)
      division = GetNegDivMod(diff, SLOPE_TAIL_COUNT_)
      modulo = cast[int](division)
      diff = cast[int](division >> 32)
      buffer[offset + 1] = cast[byte](SLOPE_MIN_ + modulo)
      buffer[offset] = cast[byte](SLOPE_START_NEG_3_ + diff)
      offset = 3
    else:
      buffer[offset + 3] = cast[byte](SLOPE_MIN_ + modulo)
      diff = cast[int](division >> 32)
      division = GetNegDivMod(diff, SLOPE_TAIL_COUNT_)
      modulo = cast[int](division)
      diff = cast[int](division >> 32)
      buffer[offset + 2] = cast[byte](SLOPE_MIN_ + modulo)
      division = GetNegDivMod(diff, SLOPE_TAIL_COUNT_)
      modulo = cast[int](division)
      buffer[offset + 1] = cast[byte](SLOPE_MIN_ + modulo)
      buffer[offset] = cast[byte](SLOPE_MIN_)
      offset = 4
  return offset