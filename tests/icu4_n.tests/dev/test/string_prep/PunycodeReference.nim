# "Namespace: ICU4N.Dev.Test.StringPrep"
type
  PunycodeReference = ref object
    punycode_success: int = 0
    punycode_bad_input: int = 1
    punycode_big_output: int = 2
    punycode_overflow: int = 3
    @base: int = 36
    tmin: int = 1
    tmax: int = 26
    skew: int = 38
    damp: int = 700
    initial_bias: int = 72
    initial_n: int = 128
    delimiter: int = 45
    maxint: long = 4294967295
    MAX_BUFFER_SIZE: int = 100

proc Basic(cp: int): bool =
    return cast[char](cp) < 128
proc Delim(cp: int): bool =
    return cp == delimiter
proc DecodeDigit(cp: int): int =
    return     if cp - 48 < 10:
cp - 22
    else:
        if cp - 65 < 26:
cp - 65
        else:
            if cp - 97 < 26:
cp - 97
            else:
@base
proc EncodeDigit(d: int, flag: int): char =
    return cast[char](d + 22 + 75 *     if d < 26:
1
    else:
0 -     if flag != 0:
1
    else:
0 << 5)
proc Flagged(bcp: int): bool =
    return bcp - 65 < 26
proc EncodeBasic(bcp: int, flag: int): char =
    bcp =     if bcp - 97 < 26:
1
    else:
0 << 5
    var mybcp: bool = bcp - 65 < 26
    return cast[char](bcp +     if flag == 0 && mybcp:
1
    else:
0 << 5)
proc Adapt(delta: int, numpoints: int, firsttime: bool): int =
    var k: int
    delta =     if firsttime == true:
delta / damp
    else:
delta >> 1
    delta = delta / numpoints
      k = 0
      while delta > @base - tmin * tmax / 2:
          delta = @base - tmin
          k = @base
    return k + @base - tmin + 1 * delta / delta + skew
proc Encode*(input_length: int, input: seq[int], case_flags: seq[char], output_length: seq[int], output: seq[char]): int =
      var delta: int
      var h: int
      var b: int
      var @out: int
      var max_out: int
      var bias: int
      var j: int
      var q: int
      var k: int
      var t: int
      var m: long
      var n: long
    n = initial_n
    delta =     @out = 0
    max_out = output_length[0]
    bias = initial_bias
      j = 0
      while j < input_length:
          if Basic(input[j]):
              if max_out - @out < 2:
                return punycode_big_output
              output[++@out] = cast[char](              if case_flags != nil:
EncodeBasic(input[j], case_flags[j])
              else:
input[j])
++j
    h =     b = @out
    if b > 0:
      output[++@out] = cast[char](delimiter)
    while h < input_length:
          m = maxint
          while j < input_length:
              if input[j] >= n && input[j] < m:
                m = input[j]
++j
        if m - n > maxint - delta / h + 1:
          return punycode_overflow
        delta = cast[int](m - n) * h + 1
        n = m
          j = 0
          while j < input_length:
              if input[j] < n:
                  if ++delta == 0:
                    return punycode_overflow
              if input[j] == n:
                    q = delta
                    while true:
                        if @out >= max_out:
                          return punycode_big_output
                        t =                         if k <= bias:
tmin
                        else:
                            if k >= bias + tmax:
tmax
                            else:
k - bias
                        if q < t:
                          break
                        output[++@out] = EncodeDigit(t + q - t % @base - t, 0)
                        q = q - t / @base - t
                        k = @base
                  output[++@out] = EncodeDigit(q,                   if case_flags != nil:
case_flags[j]
                  else:
0)
                  bias = Adapt(delta, h + 1, h == b)
                  delta = 0
++h
++j
++delta
++n
    output_length[0] = @out
    return punycode_success
proc Encode*(input: StringBuffer, case_flags: seq[char]): StringBuffer =
    var @in: int[] = seq[int]
    var inLen: int = 0
    var ch: int
    var result: StringBuffer = StringBuffer
    var iter: UCharacterIterator = UCharacterIterator.GetInstance(input)
    while     ch = iter.NextCodePoint != UCharacterIterator.Done:
        @in[++inLen] = ch
    var outLen: int[] = seq[int]
    outLen[0] = input.Length * 4
    var output: char[] = seq[char]
    var rc: int = punycode_success
      while true:
          rc = Encode(inLen, @in, case_flags, outLen, output)
          if rc == punycode_big_output:
              outLen[0] = outLen[0] * 4
              output = seq[char]
              continue
          break
    if rc == punycode_success:
        return result.Append(output, 0, outLen[0])
GetException(rc)
    return result
proc GetException(rc: int) =
    case rc
    of punycode_big_output:
        raise StringPrepFormatException("The output capacity was not sufficient.", StringPrepErrorType.BufferOverflowError)
    of punycode_bad_input:
        raise StringPrepFormatException("Illegal char found in the input", StringPrepErrorType.IllegalCharFound)
    of punycode_overflow:
        raise StringPrepFormatException("Invalid char found in the input", StringPrepErrorType.InvalidCharFound)
proc Decode*(input: StringBuffer, case_flags: seq[char]): StringBuffer =
    var @in: char[] = input.ToString.ToCharArray
    var outLen: int[] = seq[int]
    outLen[0] = MAX_BUFFER_SIZE
    var output: int[] = seq[int]
    var rc: int = punycode_success
    var result: StringBuffer = StringBuffer
      while true:
          rc = Decode(input.Length, @in, outLen, output, case_flags)
          if rc == punycode_big_output:
              outLen[0] = output.Length * 4
              output = seq[int]
              continue
          break
    if rc == punycode_success:
          var i: int = 0
          while i < outLen[0]:
UTF16.Append(result, output[i])
++i
    else:
GetException(rc)
    return result
proc Decode*(input_length: int, input: seq[char], output_length: seq[int], output: seq[int], case_flags: seq[char]): int =
      var n: int
      var @out: int
      var i: int
      var max_out: int
      var bias: int
      var b: int
      var j: int
      var @in: int
      var oldi: int
      var w: int
      var k: int
      var digit: int
      var t: int
    n = initial_n
    @out =     i = 0
    max_out = output_length[0]
    bias = initial_bias
      b =       j = 0
      while j < input_length:
          if Delim(input[j]) == true:
              b = j
++j
    if b > max_out:
      return punycode_big_output
      j = 0
      while j < b:
          if case_flags != nil:
            case_flags[@out] = cast[char](            if Flagged(input[j]):
1
            else:
0)
          if !Basic(input[j]):
            return punycode_bad_input
          output[++@out] = input[j]
++j
      @in =       if b > 0:
b + 1
      else:
0
      while @in < input_length:
            oldi = i
            while true:
                if @in >= input_length:
                  return punycode_bad_input
                digit = DecodeDigit(input[++@in])
                if digit >= @base:
                  return punycode_bad_input
                if digit > maxint - i / w:
                  return punycode_overflow
                i = digit * w
                t =                 if k <= bias:
tmin
                else:
                    if k >= bias + tmax:
tmax
                    else:
k - bias
                if digit < t:
                  break
                if w > maxint / @base - t:
                  return punycode_overflow
                w = @base - t
                k = @base
          bias = Adapt(i - oldi, @out + 1, oldi == 0)
          if i / @out + 1 > maxint - n:
            return punycode_overflow
          n = i / @out + 1
          i = @out + 1
          if @out >= max_out:
            return punycode_big_output
          if case_flags != nil:
System.Array.Copy(case_flags, i, case_flags, i + 1, @out - i)
              case_flags[i] = cast[char](              if Flagged(input[@in - 1]):
0
              else:
1)
System.Array.Copy(output, i, output, i + 1, @out - i)
          output[++i] = n
++@out
    output_length[0] = @out
    return punycode_success