// Issue #9: Generic type syntax - should use [] not <>
using System.Collections.Generic;

namespace JCG = J2N.Collections.Generic;

class TestGenericSyntax {
    void UseGenericTypes() {
        // Should generate: var set: JCG.SortedSet[string]
        // NOT: var set: JCG.SortedSet<string>
        JCG.SortedSet<string> set = new JCG.SortedSet<string>();

        // Multiple type parameters
        Dictionary<string, int> dict = new Dictionary<string, int>();

        // Nested generics
        List<List<string>> nested = new List<List<string>>();
    }

    JCG.SortedSet<int> ReturnGeneric() {
        // Return type should also use []
        return new JCG.SortedSet<int>();
    }

    T GenericMethod<T>(List<T> items) {
        // Generic method parameters
        return items[0];
    }
}
