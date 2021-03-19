#ifndef LEVEL1_C
#define LEVEL1_C
#include "gameloop.c"
#include "level_fragments.h"
#include "engine.c"
#include "resources.h"
#include "dialogs.c"
#include "gameloop.c"
#include "level2.c"
#include "interpreter.c"

//static void init_level(u8 image);
static void init_level(u8 pal, char *fn);
static void start_level(u8 pal, char *fn, u8 *name);

static void dialog_level1();

static void prepare_boss1()
{
    flush_sprites();
music_stop();
init_level(PAL256_BG2, "bg2-16.bmp");
    music_play(MUS_NWZ);
    dialog_level1();
    bullet_sprite = MARISA_BULLET;
    //init_level(IMG256_BG2);
unpack_pal256(PAL256_BG2, 0);
    scroll_pos = 192;
    push_npc(144, 20, 0, 0, MARISA, 255, 1500, 1);
}

static void l1f_dialog()
{
    init_dialog(); //TODO почему где-то здесь приостанавливается музыка?
    swap_screen();
    put_dialog_string(MARISA_FACE, "Cool down, Reimu!", 0);
    put_dialog_string(REIMU_FACE, "???", 1);
    put_dialog_string(MARISA_FACE, "I've heard buzzing\nfairies near Shrine.", 0);
    put_dialog_string(REIMU_FACE, "Welll...\nThese insects will subside\nnow.", 1);
//swap_screen();
    wait_for_space();
    init_level2();
}

static void process_boss1()
{
    Npc *boss;
    i8 b;
    u8 c;
    if (scroll_pos < 2)
        scroll_speed = 0;

    boss = find_npc_by_type(BOSS_TYPE);
    if (boss == 0)
    {
        l1f_dialog();
        return;
    }

    switch (level_loop)
    {
    case 1:
        boss->sprite.dx = -1;
        break;
        just_star(2, boss->sprite.x + 16, boss->sprite.y + 16);
        just_star(6, boss->sprite.x + 16, boss->sprite.y + 16);
        just_star(11, boss->sprite.x + 16, boss->sprite.y + 16);
    case 13:
        boss->sprite.dx = 1;
        break;
        boss_shoot1(16, boss->sprite.x + 16, boss->sprite.y + 16);
        just_star(26, boss->sprite.x + 16, boss->sprite.y + 16);
        just_star(31, boss->sprite.x + 16, boss->sprite.y + 16);
        just_star(36, boss->sprite.x + 16, boss->sprite.y + 16);
        boss_shoot1(41, boss->sprite.x + 16, boss->sprite.y + 16);
    case 57:
        boss->sprite.dx = -1;
        break;
        boss_shoot1(58, boss->sprite.x + 16, boss->sprite.y + 16);
    case 90:
        boss->sprite.dx = 0;
        break;
        boss_shoot1(91, boss->sprite.x + 16, boss->sprite.y + 16);
    case 120:
        level_loop = 0;
        for (c = 0; c < 5; c++)
            push_bonus(BONUS_CARD, boss->sprite.x + 16, boss->sprite.y + 16, 3 - (c * 2), 2);
    default:
        break;
    }
}

static void dialog_level1()
{
    init_dialog();
    swap_screen();
    put_dialog_string(REIMU_FACE, "Have you seen my donation\nbox?", POSITION_LEFT);
    put_dialog_string(MARISA_FACE, "Where was no money?!\nWho will need it?", POSITION_RIGHT);
    put_dialog_string(REIMU_FACE, "I'll beat you for these\nwords!", POSITION_LEFT);
//swap_screen();
    wait_for_space();
}

const u8 level1_bytecode[] = { 
    Nop(5),
    MakeEnemiesPair(FAIRY, 1, 10), 
    Nop(5),
    MakeCaravan(16, FIARY2, 2, 10, BONUS_CARD), 
    Nop(5),
    MakeLeftFlyers(160, GHOST, 10, BONUS_CARD), 
    MakeRightFlyers(100, GHOST, 10, BONUS_CARD),
    Nop(20),
    MakeBoomFairy(32, 30, HEALTH_CARD),
    Nop(15),
    MakeBoomFairy(200, 30, HEALTH_CARD),
    Nop(20),
    MakeEnemyWave(FIARY3, 1, 15),
    MidBoss1(GHOST, 255),
    DoubleCaravan(FAIRY, 5, 25, BONUS_CARD),
    Nop(20),
    MakeBoomFairy(160, 30, HEALTH_CARD),
    MakeLeftFlyers(160, FAIRY, 10, 0),
    MakeRightFlyers(100, FIARY3, 10, 0),
    MakeLeftFlyers(32, FIARY2, 10, 0),
    JustStar(160, 120, 3),
    Nop(10),
    JustStar(32, 32, 1),
    JustStar(210, 132, 1),
    Nop(10),
    MakeShootingStar(160, 100, INJAN, 10, 20),
    Nop(15),
    MakeShootingStar(64, 64, INJAN, 10, 20),
    Nop(15),
    MakeShootingStar(256, 64, INJAN, 10, 20),
    Nop(20),
    PushNpc(160, -10, 0, 1, MARISA, 255, 1024, 0),
    Nop(10),
    End };

static void process_level1()
{
    if (executing) {
        vm_step();
    } else {
        prepare_boss1();
        process_level = process_boss1;
    }
}

#endif