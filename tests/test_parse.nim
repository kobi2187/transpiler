import jsony, xlangtypes

let content = readFile("/home/kl/Downloads/mono-main/mcs/tests/test-234.xljs")
try:
  let node = content.fromJson(XLangNode)
  echo "Successfully parsed!"
  echo "Root kind: ", node.kind
except JsonError as e:
  echo "Parse error: ", e.msg
