# "Namespace: ICU4N.Dev.Test.StringPrep"
type
  NFS4StringPrep = ref object
    nfscss: StringPrep = nil
    nfscsi: StringPrep = nil
    nfscis: StringPrep = nil
    nfsmxp: StringPrep = nil
    nfsmxs: StringPrep = nil
    prep: NFS4StringPrep = NFS4StringPrep
    special_prefixes: seq[String] = @["ANONYMOUS", "AUTHENTICATED", "BATCH", "DIALUP", "EVERYONE", "GROUP", "INTERACTIVE", "NETWORK", "OWNER"]
    AT_SIGN: char = '@'

proc newNFS4StringPrep(): NFS4StringPrep =
  var loader: Assembly = type(NFS4StringPrep).Assembly
  try:
      var resourcePrefix: string = "ICU4N.Dev.Data.TestData."
        let nfscsiFile = loader.GetManifestResourceStream(resourcePrefix + "nfscsi.spp")
<unhandled: nnkDefer>
        nfscsi = StringPrep(nfscsiFile)
        let nfscssFile = loader.GetManifestResourceStream(resourcePrefix + "nfscss.spp")
<unhandled: nnkDefer>
        nfscss = StringPrep(nfscssFile)
        let nfscisFile = loader.GetManifestResourceStream(resourcePrefix + "nfscis.spp")
<unhandled: nnkDefer>
        nfscis = StringPrep(nfscisFile)
        let nfsmxpFile = loader.GetManifestResourceStream(resourcePrefix + "nfsmxp.spp")
<unhandled: nnkDefer>
        nfsmxp = StringPrep(nfsmxpFile)
        let nfsmxsFile = loader.GetManifestResourceStream(resourcePrefix + "nfsmxs.spp")
<unhandled: nnkDefer>
        nfsmxs = StringPrep(nfsmxsFile)
  except IOException:
      raise MissingManifestResourceException(e.ToString, e)
proc Prepare(src: seq[byte], strprep: StringPrep): byte[] =
    var s: String = Encoding.UTF8.GetString(src)
    var @out: string = strprep.Prepare(s, StringPrepOptions.Default)
    return Encoding.UTF8.GetBytes(@out)
proc CSPrepare*(src: seq[byte], isCaseSensitive: bool): byte[] =
    if isCaseSensitive == true:
        return Prepare(src, prep.nfscss)
    else:
        return Prepare(src, prep.nfscsi)
proc CISPrepare*(src: seq[byte]): byte[] =
    return Prepare(src, prep.nfscis)
proc FindStringIndex(sortedArr: seq[String], target: ReadOnlySpan[char]): int =
      var left: int
      var middle: int
      var right: int
      var rc: int
    left = 0
    right = sortedArr.Length - 1
    while left <= right:
        middle = left + right / 2
        rc = sortedArr[middle].CompareToOrdinal(target)
        if rc < 0:
            left = middle + 1

        elif rc > 0:
            right = middle - 1
        else:
            return middle
    return -1
proc MixedPrepare*(src: seq[byte]): byte[] =
    var s: string = Encoding.UTF8.GetString(src)
    var index: int = s.IndexOf(AT_SIGN)
    var @out: ValueStringBuilder = ValueStringBuilder(newSeq[char](32))
    try:
        if index > -1:
            var prefix: ReadOnlySpan<char> = s.AsSpan(0, index)
            var i: int = FindStringIndex(special_prefixes, prefix)
            var suffix: ReadOnlySpan<char> = s.AsSpan(index + 1, s.Length - index + 1)
            if i > -1 && !suffix.IsEmpty:
                raise StringPrepFormatException("Suffix following a special index", StringPrepErrorType.InvalidCharFound)
@out.Append(prep.nfsmxp.Prepare(prefix, StringPrepOptions.Default))
@out.Append(AT_SIGN)
@out.Append(prep.nfsmxs.Prepare(suffix, StringPrepOptions.Default))
        else:
@out.Append(prep.nfsmxp.Prepare(s, StringPrepOptions.Default))
        return Encoding.UTF8.GetBytes(@out.ToString)
    finally:
@out.Dispose