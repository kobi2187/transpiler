# "Namespace: System.Text.RegularExpressions"
type
  Regex = ref object
    pattern: string

proc newRegex(p: string): Regex =
  pattern = p