using System;
using System.Collections.Generic;

class TestUnifiedNodes
{
    // Test xnkRaiseStmt (was xnkThrowStmt)
    void TestThrow()
    {
        throw new Exception("test");
    }

    // Test xnkIteratorYield (was xnkYieldStmt)
    IEnumerable<int> TestYield()
    {
        yield return 1;
        yield return 2;
        yield return 3;
    }

    // Test xnkResourceStmt (was xnkUsingStmt)
    void TestUsing()
    {
        using (var file = File.OpenRead("test.txt"))
        {
            Console.WriteLine("Reading file");
        }
    }

    // Test xnkSequenceLiteral (was xnkListExpr)
    void TestArrayInit()
    {
        int[] arr = new int[] { 1, 2, 3 };
    }

    // Test xnkMapLiteral (was xnkDictExpr)
    void TestAnonymousObject()
    {
        var obj = new { Name = "John", Age = 30 };
    }

    // Test xnkSafeNavigationExpr (was xnkConditionalAccessExpr)
    void TestSafeNav()
    {
        string s = null;
        int? len = s?.Length;
    }
}
