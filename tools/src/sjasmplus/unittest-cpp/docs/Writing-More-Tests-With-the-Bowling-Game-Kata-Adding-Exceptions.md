You may have noticed in the previous code that nothing prevents a user of the Game object from rolling more than 10 pins at a time. (It also doesn't prevent the sum of two rolls in a frame from being greater than ten. Man, maybe we should re-implement this thing. Ah, well.) For this, let's have the `Game` class throw an exception when an out of range `pins` value is rolled. We'll add a new test:

```cpp
    TEST_FIXTURE(GameFixture, Cheater)
    {
        CHECK_THROW(g.roll(11), std::exception);
    }
```

The `CHECK_THROW` macro tests that the provided expression throws an exception of the type specified. This is caught polymorphically, so in this case any exception thrown that inherits from `std::exception` will pass the test. Of course, right now this test fails with a message similar to this one:

    TheExtraTest.cpp:125:1: error: Failure in Cheater: Expected exception: "std::exception" not thrown

A simple change to the Game::roll method makes this test pass.

```cpp
class Game
{
public:
    void roll(int pins)
    {
        if (pins < 0 || pins > 10)
        {
            throw std::runtime_error("Somebody is trying to cheat");
        }
        rolls_.push_back(pins);
    }
    // ...
```

Now we add a test for -1:

```cpp
    TEST_FIXTURE(GameFixture, BadCheater)
    {
        g.roll(-1);
    }
```

When we build and run this we get an error because we forgot to CHECK_THROW:

    TheExtraTest.cpp:132:1: error: Failure in BadCheater: Unhandled exception: Somebody is trying to cheat
    FAILURE: 1 out of 15 tests failed (1 failures).

Any test case (or fixture code) in UnitTest++ that throws an uncaught exception is considered a failure. We wrap this new test up in a `CHECK_THROW` and call it a day:

```cpp
    TEST_FIXTURE(GameFixture, BadCheater)
    {
        CHECK_THROW(g.roll(-1), std::runtime_error);
    }
```

You now know a lot of what you need to know to use UnitTest++. For more documentation see the [[Macro and Parameter Reference]] or, when in doubt, refer to the source code.