import src/naming_conventions

# Test @ prefix removal with keyword handling
assert sanitizeNimIdentifier("@as") == "asVar"  # "as" is a Nim keyword
assert sanitizeNimIdentifier("@event") == "event"  # "event" is NOT a keyword
assert sanitizeNimIdentifier("@class") == "class"  # "class" is NOT a keyword in Nim
assert sanitizeNimIdentifier("@type") == "typeVar"  # "type" IS a keyword
assert sanitizeNimIdentifier("@var") == "varVar"  # "var" IS a keyword
assert sanitizeNimIdentifier("@for") == "forVar"  # "for" IS a keyword

# Test trailing underscore removal
assert sanitizeNimIdentifier("value_") == "value"
assert sanitizeNimIdentifier("SLOPE_MIN_") == "SLOPE_MIN"

# Test combination
assert sanitizeNimIdentifier("@value_") == "value"

# Test underscore preservation
assert sanitizeNimIdentifier("_") == "_"
assert sanitizeNimIdentifier("_private") == "_private"

# Test no change
assert sanitizeNimIdentifier("normal") == "normal"

echo "All sanitization tests passed!"
