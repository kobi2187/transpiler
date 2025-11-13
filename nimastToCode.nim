
proc generateNimCode*(node: NimNode): string =
  result = repr(node)