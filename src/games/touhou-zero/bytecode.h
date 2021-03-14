#include "interpreter.c"

#define NOP_CMD 0
#define JUST_STAR_CMD 1
#define ENEMIES_PAIR_CMD 2
#define MAKE_CARAVAN_CMD 3
#define MAKE_LEFT_FLYERS_CMD 4
#define MAKE_RIGHT_FLYERS_CMD 5
#define MAKE_BOOM_FAIRY_CMD 6
#define ENEMY_WAVE_CMD 7
#define MID_BOSS1_CMD 8
#define DOUBLE_CARAVAN_CMD 9
#define MAKE_SHOOTING_STAR_CMD 10
#define PUSH_NPC_CMD 11
#define TRIANGLE_CMD 12
#define MAKE_CORRIDOR_CMD 13
#define TRIANGLE_HALF_CMD 14
#define DROPPED_ENEMY_CMD 15
#define FIRING_TRAP_CMD 16
#define MID_BOSS2_CMD 17
#define AIMED_SIDE_ENEMIES_CMD 18
#define AIMED_CIRCLE_CMD 19
#define MARISA_HELP_CMD 20
#define SET_SPEED_CMD 21
#define AIMED_SHOT_CMD 22
#define END_CMD 255

#define u16tobytes(i) ((u16)i & 255), ((u16)i >> 8)

#define Nop(len)  NOP_CMD, len, 3
#define JustStar(x, y, count)  JUST_STAR_CMD, count, 8,  1, u16tobytes(x), u16tobytes(y)
#define MakeEnemiesPair(sprite, type, life) ENEMIES_PAIR_CMD, 16, 8, type, u16tobytes(sprite), u16tobytes(life)
#define MakeCaravan(x, tile, type, hp, bonus) MAKE_CARAVAN_CMD, 36, 12, type, u16tobytes(x), u16tobytes(tile), u16tobytes(hp), u16tobytes(bonus)
#define MakeLeftFlyers(y, tile, hp,  bonus) MAKE_LEFT_FLYERS_CMD, 7, 12, 10, u16tobytes(y), u16tobytes(tile), u16tobytes(hp), u16tobytes(bonus)
#define MakeRightFlyers(y, tile, hp, bonus) MAKE_RIGHT_FLYERS_CMD, 7, 12, 10, u16tobytes(y), u16tobytes(tile), u16tobytes(hp), u16tobytes(bonus)
#define MakeBoomFairy(x, hp, bonus) MAKE_BOOM_FAIRY_CMD, 12, 8, hp,  u16tobytes(x), u16tobytes(bonus)
#define MakeEnemyWave(tile, type, hp) ENEMY_WAVE_CMD, 36, 8, type, u16tobytes(tile), u16tobytes(hp)
#define MidBoss1(tile, hp) MID_BOSS1_CMD, 26, 8, 0, u16tobytes(tile), u16tobytes(hp)
#define DoubleCaravan(tile, type, hp, bonus) DOUBLE_CARAVAN_CMD, 22, 10, type, u16tobytes(tile), u16tobytes(hp), u16tobytes(bonus)
#define MakeShootingStar(x, y, tile, type, hp) MAKE_SHOOTING_STAR_CMD, 31, 12, type, u16tobytes(x), u16tobytes(y), u16tobytes(tile), u16tobytes(hp)
#define PushNpc(x, y, dx, dy, tile, type, hp,  bonus) PUSH_NPC_CMD, 1, 18, type, u16tobytes(x), u16tobytes(y), u16tobytes(dx), u16tobytes(dy),  u16tobytes(tile),  u16tobytes(bonus), u16tobytes(hp)  
#define Triangle(tile, hp, bonus) TRIANGLE_CMD, 26, 8, hp, u16tobytes(tile), u16tobytes(bonus)
#define MakeCorridor(tile, type, hp, bonus) MAKE_CORRIDOR_CMD, 20, 10, type, u16tobytes(tile), u16tobytes(hp), u16tobytes(bonus) 
#define TriangleHalf(isLeft, tile, hp, bonus) TRIANGLE_HALF_CMD, 26, 10, isLeft, u16tobytes(tile), u16tobytes(hp), u16tobytes(bonus)
#define DroppedEnemy(x, tile, hp) DROPPED_ENEMY_CMD, 1, 8, hp, u16tobytes(x), u16tobytes(tile)
#define FiringTrap(tile) FIRING_TRAP_CMD, 86, 6, 0, u16tobytes(tile)
#define MidBoss2(tile, hp) MID_BOSS2_CMD, 26, 8, 0, u16tobytes(tile), u16tobytes(hp)
#define AimedSideEnemies(tile, hp, count) AIMED_SIDE_ENEMIES_CMD, 5 * count, 6, hp, u16tobytes(tile)
#define AimedCircle(tile, hp, count) AIMED_CIRCLE_CMD, 10 * count, 6, hp, u16tobytes(tile)
#define MarisaHelp MARISA_HELP_CMD, 15, 3
#define SetNpcSpeed(type, dx, dy) SET_SPEED_CMD, 1, 8, type, u16tobytes(dx), u16tobytes(dy)
#define AimedShoot(type, count) AIMED_SHOT_CMD, count, 4, type 
#define End END_CMD, 1, 1, 3