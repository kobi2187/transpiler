// Issue #6: Double finally blocks - lock statements should generate single finally
using System.Threading;

class TestLockStatements {
    private static object cacheLock = new object();
    private static string cachedValue = null;

    string GetCachedValue() {
        lock (cacheLock) {
            // Should generate:
            // acquire(cacheLock)
            // try:
            //   ...
            // finally:
            //   release(cacheLock)
            //
            // NOT:
            // finally:
            //   finally:
            //     release(cacheLock)

            if (cachedValue == null) {
                cachedValue = "computed";
            }
            return cachedValue;
        }
    }

    void NestedLocks() {
        object lock1 = new object();
        object lock2 = new object();

        lock (lock1) {
            lock (lock2) {
                // Nested locks should each have single finally
                cachedValue = "nested";
            }
        }
    }
}
