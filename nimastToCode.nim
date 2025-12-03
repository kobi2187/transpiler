
proc generateNimCode*(node: MyNimNode): string =
  result = repr(node)