# "Namespace: ICU4N.Dev.Test.Normalizers"
type
  NormalizerRegressionTests = ref object


proc TestJB4472*() =
    var tamil: String = "இந்தியா"
Logln("Normalized: " + Normalizer.IsNormalized(tamil, NormalizerMode.NFC, 0))
    var sample: string = "aaab̧"
Logln("Normalized: " + Normalizer.IsNormalized(sample, NormalizerMode.NFC, 0))
    var sample2: string = "aaaç"
Logln("Normalized: " + Normalizer.IsNormalized(sample2, NormalizerMode.NFC, 0))