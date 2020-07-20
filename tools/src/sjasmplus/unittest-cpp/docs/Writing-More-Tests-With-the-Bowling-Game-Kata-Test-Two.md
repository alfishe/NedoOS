For the second test, we'll ensure that a bowler that hits one pin on every roll scores twenty. (I might add, this is incredibly challenging to actually achieve in real life.)

```cpp
SUITE(BowlingGameTest)
{
    TEST(GutterGame)
    {
        Game g;
        
        for (int i = 0; i < 20; ++i)
        {
            g.roll(0);
        }
        
        CHECK_EQUAL(0, g.score());
    }
    
    TEST(AllOnes)
    {
        Game g;

        for (int i = 0; i < 20; ++i)
        {
            g.roll(1);
        }
        
        CHECK_EQUAL(20, g.score());
    }
}
```

This will of course fail, because we never really implemented any totaling of pins. Let's update class Game to keep a running total of pins.

```cpp

class Game
{
public:
    Game()
    : total_(0)
    {
    }
    
    void roll(int pins)
    {
        total_ += pins;
    }
    
    int score() const
    {
        return total_;
    }
    
private:
    int total_;
};
```

Hooray, two tests coded and passing. But, there's a lot of duplication between the two; specifically, the creation of the `Game` object and the for loops. Let's see if we can clean up those tests a big before we move on. This is where fixtures come in.

```cpp
SUITE(BowlingGameTest)
{
    class GameFixture
    {
    public:
        Game g;
    };
    
    TEST_FIXTURE(GameFixture, GutterGame)
    {
        for (int i = 0; i < 20; ++i)
        {
            g.roll(0);
        }
        
        CHECK_EQUAL(0, g.score());
    }
    
    TEST_FIXTURE(GameFixture, AllOnes)
    {
        for (int i = 0; i < 20; ++i)
        {
            g.roll(1);
        }
        
        CHECK_EQUAL(20, g.score());
    }
}
```

This builds and runs cleanly. The TEST_FIXTURE macro tells UnitTest++ to use the provided fixture class, in this case `GameFixture`, for running the test. Setup and teardown is handled in the constructor and destructor, respectively, of the fixture object, and is run separately for each test. Anything with public or protected visibility in the fixture class will be accessible within the scope of the test case; in the above example, this is the `Game` object `g`.

Fixture classes must be default-constructable. Let's move the `for` loop into our fixture.

```cpp
SUITE(BowlingGameTest)
{
    class GameFixture
    {
    public:
        Game g;
        
        void rollMany(int rolls, int pinsPerRoll)
        {
            for (int i = 0; i < rolls; ++i)
            {
                g.roll(pinsPerRoll);
            }
        }
    };
    
    TEST_FIXTURE(GameFixture, GutterGame)
    {
        rollMany(20, 0);
        CHECK_EQUAL(0, g.score());
    }
    
    TEST_FIXTURE(GameFixture, AllOnes)
    {
        rollMany(20, 1);
        CHECK_EQUAL(20, g.score());
    }
}
```

Tests still run and pass, and we've eliminated some duplication. Let's move on to [[Writing More Tests With the Bowling Game Kata Tests Three Through Five]].

