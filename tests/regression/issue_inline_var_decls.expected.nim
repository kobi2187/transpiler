# Expected patterns for inline variable declaration hoisting

# The hoisted variable declarations should appear before the assignment
var value: int32
var success: bool = tryParse("123", value)

# Second case with 'out var' syntax (type is inferred as 'var')
var value2
var success2: bool = tryParse("456", value2)
