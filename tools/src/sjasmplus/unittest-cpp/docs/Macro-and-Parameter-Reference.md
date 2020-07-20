Suites
--------
`SUITE(Name)`: Organizes your tests into suites (groups). Tests can be added to suites across multiple test source files.  A suite serves as a namespace for test names, so that the same test name can be used in two difference contexts.

e.g.:

```cpp
SUITE(MySuite)
{
   // tests go here
}
```

Tests
-------
`TEST(Name)`: Creates a single test case. All checks in a test will be run using the standard runners, unless an exception is thrown or an early return is introduced.

```cpp
TEST(MyTest)
{
   // checks go here
}
``` 

`TEST_FIXTURE(FixtureClass, TestName)`: Creates a single test case using a fixture. The FixtureClass is default instantiated before the test is run, then the test runs with access to anything `public` or `protected` in the fixture. Useful for sharing setup / teardown code.

```cpp
class MyFixture
{
public:
   MyFixture() { /* setup goes here */ }
   ~MyFixture() { /* teardown goes here */ }
};

TEST_FIXTURE(MyFixture, MyFixtureTest)
{
   // checks go here
}
```

Checks
--------
`CHECK(statement)`: Verifies the statement evaluates to true (not necessary boolean true / false).

```cpp
CHECK(true); // passes
CHECK(1 == 2); // fails
CHECK(0); // fails
```

`CHECK_EQUAL(expected, actual)`: Verifies that the actual value matches the expected. Note that conversions can occur. Requires `operator==` for the types of `expected` and `actual`, and requires the ability for both types to be streamed to `UnitTest::MemoryOutStream` using `operator<<`.

```cpp
CHECK_EQUAL(1, 1); // passes
CHECK_EQUAL("123", std::string("123")); //passes
CHECK_EQUAL((1.0 / 40.0), 0.025000000000000001); // passes... wait what? be careful with floating point types!
```

`CHECK_CLOSE(expected, actual, tolerance)`: Verifies that the actual value is within +/- tolerance of the expected value. This has the same requirements of the types involved as `CHECK_EQUAL`.

```cpp
CHECK_CLOSE(0.025000000000000002, (1.0 / 40.0), 0.000000000000000001); // passes
CHECK_CLOSE(0.025, (1.0 / 40.0), 0.000000000000000001); // also passes
CHECK_CLOSE(0.025000000000000020, (1.0 / 40.0), 0.000000000000000001); // fails
```

`CHECK_THROW(expression, ExpectedExceptionType)`: Verifies that the expression throws an exception that is polymorphically of the ExpectedExceptionType.

`CHECK_ARRAY_EQUAL(expected, actual, count)`: Like `CHECK_EQUAL`, but for arrays and containers that support random access (`operator[]`). `count` is the number of items in the array.

`CHECK_ARRAY_CLOSE(expected, actual, count, tolerance)`: Like `CHECK_CLOSE`, but for arrays and containers that support random access (`operator[]`). `count` is the number of items in the array.

`CHECK_ARRAY2D_CLOSE(expected, actual, rows, columns, tolerance)`: Like `CHECK_ARRAY_CLOSE` but for two-dimensional arrays.

Miscellaneous
----------------
`REQUIRE`: Requires the following CHECK or block of CHECK statements to pass, ending the test early if one does not.

```cpp
REQUIRE CHECK(!container.empty()); // test fails and ends here if container is empty

CHECK_EQUAL(2, *container.begin()); // check only runs if container is not empty
```

```cpp
REQUIRE
{
   CHECK(pointer1);  // test fails and ends here if pointer1 is null
   CHECK(pointer2);  // test fails and ends here if pointer2 is null
}

CHECK_EQUAL(*pointer1, *pointer2); // check only runs if both pointers are non-null
```

`UNITTEST_TIME_CONSTRAINT`: Fail a test if it takes too long to complete. They come in two flavors; **local** and **global** time constraints.

Local time constraints are limited to the current scope, like so:

```cpp
TEST(YourTimedTest)
{
   // Lengthy setup...
   {
      UNITTEST_TIME_CONSTRAINT(50);  // Local time constraint (in milliseconds)
      // Do time-critical stuff
   }
   // Lengthy teardown...
}
```

A global time constraint requires that all of the tests in a test run are faster than a specified amount of time. This will cause UnitTest++ to fail it entirely if any test exceeds the global constraint. The max time is passed as a parameter to an overload of `RunAllTests()`.

`UNITTEST_TIME_CONSTRAINT_EXEMPT`: If you want to use a global time constraint, but have one test that is notoriously slow, you can exempt it from inspection by using the `UNITTEST_TIME_CONSTRAINT_EXEMPT` macro anywhere inside the test body.

```cpp
TEST(NotoriouslySlowTest)
{
   UNITTEST_TIME_CONSTRAINT_EXEMPT();
   // Oh boy, this is going to take a while
   ...
}
```

Test runners
--------

The `RunAllTests()` function has an overload that lets you customize the behaviour of the runner, such as global time constraints, custom reporters, which suite to run, etc.

```cpp
int RunAllTests(TestReporter& reporter, TestList const& list, char const* suiteName, int const maxTestTimeInMs);
```

If you attempt to pass custom parameters to `RunAllTests()`, note that the `list` parameter should have the value `Test::GetTestList()`.

The parameterless `RunAllTests()` is a simple wrapper for this one, with sensible defaults.