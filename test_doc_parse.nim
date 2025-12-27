import jsontoxlangtypes
import os

when isMainModule:
  if paramCount() < 1:
    echo "Usage: test_doc_parse <xlang_json_file>"
    quit(1)

  let filePath = paramStr(1)

  try:
    let node = parseXLangJson(filePath)
    echo "Successfully parsed XLang JSON!"
    echo "Root kind: ", node.kind
  except Exception as e:
    echo "ERROR: Failed to parse XLang JSON"
    echo "Error message: ", e.msg
    quit(1)
