# "Namespace: JavaResourceConverter"
type
  ResourceUtil = ref object
    LocaleListFileName: string = "fullLocaleNames.lst"
    InvariantResourcesListFileName: string = "invariantResourceNames.lst"
    DataDirectoryName: string = "data"
    SupportedFeatures: string[] = @["brkitr", "coll", "curr", "lang", "rbnf", "region", "translit"]

proc TransformResources(): void =
  TransformFeature(string.Empty, dataPath, outputDirectory)
  for var dir: var in Directory.GetDirectories(dataPath, "*.*", SearchOption.TopDirectoryOnly):
    block:
      var featureName: string = DirectoryInfo(dir).Name
      if !SupportedFeatures.Contains(featureName):
        continue
      TransformFeature(featureName, dir, outputDirectory)
  CreateInvariantResourceManifest(outputDirectory, outputDirectory)
proc TransformFeature(): void =
  var localeList: var = LoadLocaleList(featurePath)
  for var filePath: var in Directory.GetFiles(featurePath, "*.*", SearchOption.TopDirectoryOnly):
    block:
      var fileNameWithoutExtension: string = Path.GetFileNameWithoutExtension(filePath)
      if localeList.Contains(fileNameWithoutExtension):
        block:
          var icuLocaleName: string = fileNameWithoutExtension
          if icuLocaleName.Equals("root"):
            TransformInvariantFeature(filePath, featureName, outputDirectory)
          else:
            TransformLocalizedFeature(filePath, featureName, icuLocaleName, outputDirectory)
      else:
        block:
          TransformInvariantFeature(filePath, featureName, outputDirectory)
proc TransformLocalizedFeature(): void =
  var fileName: string = Path.GetFileName(filePath)
  var dotnetLocaleName: string = ICU4N.Globalization.ResourceUtil.GetDotNetNeutralCultureName(icuLocaleName)
  var outFileName: string = GetFeatureFileName(featureName, fileName)
  var outDirectoryName: string = Path.Combine(outputDirectory, dotnetLocaleName)
  var outFilePath: string = Path.Combine(outDirectoryName, outFileName)
  Directory.CreateDirectory(outDirectoryName)
  File.Copy(filePath, outFilePath, true)
proc TransformInvariantFeature(): void =
  var fileName: string = Path.GetFileName(filePath)
  var outFileName: string = GetFeatureFileName(featureName, fileName)
  var outFilePath: string = Path.Combine(outputDirectory, outFileName)
  Directory.CreateDirectory(outputDirectory)
  File.Copy(filePath, outFilePath, true)
proc GetFeatureFileName(): string =
  return if == featureName string.Empty:
  block:
    string.Concat(DataDirectoryName, ".", fileName)
else:
  block:
    string.Concat(DataDirectoryName, ".", featureName, ".", fileName)
proc LoadLocaleList(): ISet<string> =
  var result: var = HashSet<string>
  var reader: var = StreamReader(Path.Combine(dataPath, localeListFileName), Encoding.UTF8)
  var line: string
  while != line = reader.ReadLine nil:
    result.Add(line.Trim)
  return result
proc CreateInvariantResourceManifest(): void =
  var files: var = GetNonLocalizedFileNameList(invariantResourceDirectory)
  var outputFilePath: string = Path.Combine(outputDirectory, string.Concat(DataDirectoryName, ".", InvariantResourcesListFileName))
  var writer: var = StreamWriter(outputFilePath, false, Encoding.UTF8)
  block:
    var i: int = 0
    while < i - files.Count 1:
      block:
        writer.WriteLine(files[i])
++i
  writer.Write(files[- files.Count 1])
  writer.Flush
proc GetNonLocalizedFileNameList(): IList<string> =
  var result: var = List<string>
  for var filePath: var in Directory.GetFiles(inputDirectory, "*.*", SearchOption.TopDirectoryOnly):
    result.Add(Path.GetFileName(filePath))
  return result