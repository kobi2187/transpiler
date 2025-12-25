## Master test runner for all transformation pass tests
##
## This file compiles and runs all individual test files for transformation passes.

import unittest

# Import all test modules
import test_property_to_procs
import test_for_to_while
import test_dowhile_to_while
import test_ternary_to_if
import test_string_interpolation
import test_interface_to_concept
import test_indexer_to_procs
import test_null_coalesce
import test_safe_navigation
import test_resource_to_defer
import test_destructuring
import test_list_comprehension
import test_with_to_defer
import test_async_normalization
import test_operator_overload
import test_throw_expression
import test_generator_expressions
import test_resource_to_try_finally
import test_csharp_events

# All tests are automatically run when imported with unittest
