# "Namespace: ICU4N.Dev.Test.Lang"
type
  UCharacterCategoryTest = ref object


proc newUCharacterCategoryTest(): UCharacterCategoryTest =

proc TestToString*() =
    var name: String[] = @["Unassigned", "Letter, Uppercase", "Letter, Lowercase", "Letter, Titlecase", "Letter, Modifier", "Letter, Other", "Mark, Non-Spacing", "Mark, Enclosing", "Mark, Spacing Combining", "Number, Decimal Digit", "Number, Letter", "Number, Other", "Separator, Space", "Separator, Line", "Separator, Paragraph", "Other, Control", "Other, Format", "Other, Private Use", "Other, Surrogate", "Punctuation, Dash", "Punctuation, Open", "Punctuation, Close", "Punctuation, Connector", "Punctuation, Other", "Symbol, Math", "Symbol, Currency", "Symbol, Modifier", "Symbol, Other", "Punctuation, Initial quote", "Punctuation, Final quote"]
      var i: int = UUnicodeCategory.OtherNotAssigned.ToInt32
      while i < UUnicodeCategoryExtensions.CharCategoryCount:
          if !cast[UUnicodeCategory](i).AsString.Equals(name[i]):
Errln("Error toString for category " + i + " expected " + name[i])
++i
    for category in Enum.GetValues(type(UUnicodeCategory)):
        if !category.AsString.Equals(name[category.ToInt32]):
Errln("Error toString for category " + category + " expected " + name[category.ToInt32])