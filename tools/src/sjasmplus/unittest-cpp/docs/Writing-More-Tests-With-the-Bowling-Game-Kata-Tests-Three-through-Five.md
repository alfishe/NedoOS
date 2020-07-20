At this point let's fast forward through the kata to the end, as these steps don't introduce any new UnitTest++ concepts. After this, though, we're going to introduce a new requirement that isn't in the original kata in [[Writing More Tests With the Bowling Game Kata Adding Exceptions]].

```cpp
#include "UnitTest++/UnitTest++.h"
#include <vector>

class Game
{
public:
    void roll(int pins)
    {
        rolls_.push_back(pins);
    }
    
    int score() const
    {
        int score = 0;
        int frameIndex = 0;
        for (int frame = 0; frame < 10; frame++) {
            if (isStrike(frameIndex)) {
                score += 10 + strikeBonus(frameIndex);
                frameIndex++;
            } else if (isSpare(frameIndex)) {
                score += 10 + spareBonus(frameIndex);
                frameIndex += 2;
            } else {
                score += sumOfBallsInFrame(frameIndex);
                frameIndex += 2;
            }
        }
        return score;
    }
    
private:
    
    bool isStrike(int frameIndex) const {
        return rolls_[frameIndex] == 10;
    }
    
    int sumOfBallsInFrame(int frameIndex) const {
        return rolls_[frameIndex] + rolls_[frameIndex+1];
    }
    
    int spareBonus(int frameIndex) const {
        return rolls_[frameIndex+2];
    }
    
    int strikeBonus(int frameIndex) const {
        return rolls_[frameIndex+1] + rolls_[frameIndex+2];
    }
    
    bool isSpare(int frameIndex) const {
        return rolls_[frameIndex] + rolls_[frameIndex+1] == 10;
    }
    
    
    std::vector<int> rolls_;
};

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
        
        void rollStrike()
        {
            g.roll(10);
        }
        
        void rollSpare()
        {
            g.roll(5);
            g.roll(5);
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
    
    TEST_FIXTURE(GameFixture, OneSpare)
    {
        rollSpare();
        g.roll(3);
        rollMany(17,0);
        CHECK_EQUAL(16, g.score());
    }
    
    TEST_FIXTURE(GameFixture, OneStrike)
    {
        rollStrike();
        g.roll(3);
        g.roll(4);
        rollMany(16, 0);
        CHECK_EQUAL(24, g.score());
    }
    
    TEST_FIXTURE(GameFixture, PerfectGame)
    {
        rollMany(12,10);
        CHECK_EQUAL(300, g.score());
    }
}
