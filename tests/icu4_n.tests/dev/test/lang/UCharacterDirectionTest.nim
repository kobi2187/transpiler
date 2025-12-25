# "Namespace: ICU4N.Dev.Test.Lang"
type
  UCharacterDirectionTest = ref object


proc newUCharacterDirectionTest(): UCharacterDirectionTest =

proc TestToString*() =
    var name: String[] = @["Left-to-Right", "Right-to-Left", "European Number", "European Number Separator", "European Number Terminator", "Arabic Number", "Common Number Separator", "Paragraph Separator", "Segment Separator", "Whitespace", "Other Neutrals", "Left-to-Right Embedding", "Left-to-Right Override", "Right-to-Left Arabic", "Right-to-Left Embedding", "Right-to-Left Override", "Pop Directional Format", "Non-Spacing Mark", "Boundary Neutral", "First Strong Isolate", "Left-to-Right Isolate", "Right-to-Left Isolate", "Pop Directional Isolate", "Unassigned"]
      var i: UCharacterDirection = UCharacterDirection.LeftToRight
      while i <= UCharacterDirectionExtensions.CharDirectionCount:
          if !i.AsString.Equals(name[cast[int](i)]):
Errln("Error toString for direction " + i + " expected " + name[cast[int](i)])
++i