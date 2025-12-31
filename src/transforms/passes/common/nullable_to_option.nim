## Nullable to Option Transformation
##
## Transforms C# Nullable<T> types to Nim Option[T]
##
## C#: int? value or Nullable<int>
## Nim: Option[int]

import core/xlangtypes
import semantic/semantic_analysis
import options

proc transformNullableToOption*(node: XLangNode, semanticInfo: var SemanticInfo): XLangNode =
  ## Transform Nullable<T> generic types to Option[T]
  case node.kind
  of xnkGenericType:
    # Check if this is a Nullable<T> type
    if node.genericTypeName == "Nullable" and node.genericArgs.len == 1:
      # Convert Nullable<T> to Option[T]
      result = XLangNode(
        kind: xnkGenericType,
        genericTypeName: "Option",
        genericArgs: node.genericArgs  # Keep the same type argument
      )
    else:
      result = node

  else:
    result = node
