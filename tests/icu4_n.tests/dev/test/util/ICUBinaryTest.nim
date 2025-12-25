# "Namespace: ICU4N.Dev.Test.Util"
type
  ICUBinaryTest = ref object


proc newICUBinaryTest(): ICUBinaryTest =

type
  Authenticate = ref object


proc IsDataVersionAcceptable*(version: seq[byte]): bool =
    return version[0] == 1
proc TestReadHeader*() =
    var formatid: int = 16909060
    var array: byte[] = @[0, 24, cast[byte](218), 39, 0, 20, 0, 0, 1, 0, 2, 0, 1, 2, 3, 4, 1, 2, 3, 4, 3, 2, 0, 0]
    var bytes: ByteBuffer = ByteBuffer.Wrap(array)
    var authenticate: IAuthenticate = Authenticate
    try:
ICUBinary.ReadHeader(bytes, formatid, authenticate)
    except IOException:
Errln("Failed: Lenient authenticate object should pass ICUBinary.readHeader")
    try:
bytes.Rewind
ICUBinary.ReadHeader(bytes, formatid, nil)
    except IOException:
Errln("Failed: Null authenticate object should pass ICUBinary.readHeader")
    array[17] = 9
    try:
bytes.Rewind
ICUBinary.ReadHeader(bytes, formatid, authenticate)
    except IOException:
Errln("Failed: Lenient authenticate object should pass ICUBinary.readHeader")
    array[16] = 2
    try:
bytes.Rewind
ICUBinary.ReadHeader(bytes, formatid, authenticate)
Errln("Failed: Invalid version number should not pass authenticate object")
    except IOException:
Logln("PASS: ICUBinary.readHeader with invalid version number failed as expected")