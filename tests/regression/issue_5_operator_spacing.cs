// Issue #5: Operator spacing - 'not' operator should have space before operand
class TestOperatorSpacing {
    bool CheckHandler(object handler) {
        // Should generate: if not handler.isValid():
        // NOT: if nothandler.isValid():
        if (!handler.IsValid()) {
            return false;
        }

        // Should generate: return not result
        // NOT: return notresult
        bool result = true;
        return !result;
    }

    bool CheckMethod() {
        // Should generate: if not method():
        // NOT: if not method:
        return !Method();
    }

    bool Method() {
        return true;
    }
}
