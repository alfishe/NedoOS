#ifndef LEVEL2_C
#define LEVEL2_C
#include "gameloop.c"
#include "level_fragments.h"
#include "engine.c"
#include "resources.h"
#include "dialogs.c"
#include "gameloop.c"
#include "level3.c"

//static void init_level(u8 image);
//static void start_level(u8 image, u8 *name);
static void init_level(u8 pal, char *fn);
static void start_level(u8 pal, char *fn, u8 *name);

static void process_level2();
u8 l2s=0;

const u8 l2intro[] = {
    PushNpc(160, -10, 0, 2, FROG, 1, 300, 0),
    Nop(10),
    End
};

const u8 level2_bc[] = {
    DoubleCaravan(FROG, 1, 20, 0),
    Nop(10),
    Triangle(FAIRY, 30, BONUS_CARD),
    Nop(10),
    MakeCorridor(FIARY2, 1, 20, 0),
    Nop(10),
    MakeRightFlyers(32, GHOST, 10, BONUS_CARD),
    MakeLeftFlyers(120, GHOST, 10, BONUS_CARD),
    Nop(20),
    MakeBoomFairy(160, 30, HEALTH_CARD),
    Nop(10),
    MakeShootingStar(160, 90, ICEBALL, 20, 30),
    Nop(10),
    TriangleHalf(1, FAIRY, 30, HEALTH_CARD),
    Nop(20),
    DroppedEnemy(32, SHARP_ICE, 5),
    DroppedEnemy(64, SHARP_ICE, 5),
    DroppedEnemy(16, SHARP_ICE, 5),
    DroppedEnemy(160, SHARP_ICE, 5),
    JustStar(160, 120, 3),
    Nop(5),
    DroppedEnemy(15, SHARP_ICE, 5),
    DroppedEnemy(32, SHARP_ICE, 5),
    DroppedEnemy(96, SHARP_ICE, 5),
    DroppedEnemy(150, SHARP_ICE, 5),
    DroppedEnemy(200, SHARP_ICE, 5),
    DroppedEnemy(96, SHARP_ICE, 5),
    Nop(3),
    JustStar(160, 120, 3),
    Nop(10),
    MakeShootingStar(160, 90, ICEBALL, 20, 30),
    Nop(20),
    FiringTrap(SHARP_ICE),
    Nop(10),
    DroppedEnemy(16, GHOST, 4),
    DroppedEnemy(160, GHOST, 4),
    DroppedEnemy(300, GHOST, 4),
    DroppedEnemy(50, GHOST, 4),
    DroppedEnemy(250, GHOST, 4),
    Nop(13),
    DroppedEnemy(16, GHOST, 4),
    DroppedEnemy(160, GHOST, 4),
    DroppedEnemy(300, GHOST, 4),
    DroppedEnemy(50, GHOST, 4),
    DroppedEnemy(250, GHOST, 4),
    Nop(20),
    MidBoss2(FAIRY_MB, 100),
    Nop(10),
    MakeShootingStar(160, 90, ICEBALL, 20, 30),
    Nop(20),
    DroppedEnemy(16, GHOST, 4),
    DroppedEnemy(160, GHOST, 4),
    DroppedEnemy(300, GHOST, 4),
    DroppedEnemy(50, GHOST, 4),
    DroppedEnemy(250, GHOST, 4),
    Nop(10),
    DroppedEnemy(16, GHOST, 4),
    DroppedEnemy(160, GHOST, 4),
    DroppedEnemy(300, GHOST, 4),
    DroppedEnemy(50, GHOST, 4),
    DroppedEnemy(250, GHOST, 4),
    Nop(10),
    DroppedEnemy(16, GHOST, 4),
    DroppedEnemy(160, GHOST, 4),
    DroppedEnemy(300, GHOST, 4),
    DroppedEnemy(50, GHOST, 4),
    DroppedEnemy(250, GHOST, 4),
    Nop(10),
    MakeLeftFlyers(120, GHOST, 10, BONUS_CARD),
    Nop(20),
    PushNpc(160, -10, 0, 1, CIRNO, 66, 1024, 0),
    Nop(15),
    End
};

static void init_level2()
{
    level_loop = 0;
    scroll_speed = 1;
    process_level = process_level2;
    init_vm(l2intro);
    flush_sprites();
    //start_level(IMG256_BG3, "Fairies Lake");
music_stop();
start_level(PAL256_BG3, "bg3-16.bmp", "Fairies Lake");
    music_play(MUS_GLASSED);
    bullet_sprite = DEFAULT_BULLET;
    state = STATE_PLAY;
    l2s = 0;
}

static void l2b_dialog()
{
    init_dialog();
    swap_screen();
    put_dialog_string(REIMU_FACE, "CIIIIRRRNOO!\nWhat a heck you doing?!", 1);
//swap_screen();
    wait_for_space();
    flush_sprites();
    //init_level(IMG256_BG3);
init_level(0/*PAL256_BG3*/, "bg3-16.bmp");
unpack_pal256(PAL256_BG3, 0);
    init_vm(level2_bc);
}

static void l2f_dialog()
{
    init_dialog();
    swap_screen();
    put_dialog_string(CIRNO_FACE, "Okay, okay...\nYou've beaten the\nstrongest boss!", 0);
    put_dialog_string(REIMU_FACE, "Hey, insect!\nHave you seen my donation\nbox?", 1);
    put_dialog_string(CIRNO_FACE, "Why do I need empty box?No. I don't need it.", 0);
    put_dialog_string(REIMU_FACE, "We'll talk again!\nI have no time for bugs now!", 1);
//swap_screen();
    wait_for_space();
    init_level3();
}

static void process_boss2()
{
    u8 c;
    Npc *boss;

    if (scroll_pos < 2)
        scroll_speed = 0;

    boss = find_npc_by_type(BOSS_TYPE);

    if (boss)
    {
        if (boss->sprite.x <= 20 || boss->sprite.x >= 280)
        {
            boss->sprite.dx = -boss->sprite.dx;
            boss->sprite.x += boss->sprite.dx;
        }
        if (boss->sprite.y <= 20 || boss->sprite.y >= 120)
        {
            boss->sprite.dy = -boss->sprite.dy;
            boss->sprite.y += boss->sprite.dy;
        }
    }
    else
    {
        l2f_dialog();
        return;
    }
    
    switch (level_loop)
    {
        boss_shoot1(1, boss->sprite.x + 16, boss->sprite.y + 16);
        boss_attack_drop_npc(20, ICE);
    case 26:
        boss->sprite.dx = 1;
        boss->sprite.dy = 1;
        break;
        boss_shoot1(30, boss->sprite.x + 16, boss->sprite.y + 16);
        boss_attack_drop_npc(50, FROG);

        just_star(60, boss->sprite.x + 16, boss->sprite.y + 16);
        just_star(61, boss->sprite.x + 16, boss->sprite.y + 16);
        just_star(62, boss->sprite.x + 16, boss->sprite.y + 16);

        just_star(80, boss->sprite.x + 16, boss->sprite.y + 16);
        just_star(82, boss->sprite.x + 16, boss->sprite.y + 16);
        just_star(84, boss->sprite.x + 16, boss->sprite.y + 16);

    case 100:
        for (c = 0; c < 5; c++)
            push_bonus(BONUS_CARD, boss->sprite.x + 16, boss->sprite.y + 16, 3 - (c * 2), 2);
        level_loop = 1;
    }
}

static void l2m_dialog()
{
music_stop();
init_level(PAL256_BG4, "bg4-16.bmp");
    music_play(MUS_CIRNO); //TODO почему где-то здесь приостанавливается музыка?
    init_dialog();
    swap_screen();
    put_dialog_string(REIMU_FACE, "Hey, BUG!\nSTOP! I SAID STOP!", 1);
    put_dialog_string(CIRNO_FACE, "Whaat?\nYou are talking with\nthe final boss!", 0);
    put_dialog_string(REIMU_FACE, "You are the second...\nIf Marisa was the first.", 1);
    put_dialog_string(CIRNO_FACE, "It's your final!", 0);
//swap_screen();
    wait_for_space();
    flush_sprites();
    //init_level(IMG256_BG4);
unpack_pal256(PAL256_BG4, 0);

    level_loop = 0;
    bullet_sprite = CIRNO_BULLET;
    process_level = process_boss2;
    scroll_pos = 192;
    push_npc(144, 20, 0, 0, CIRNO, 255, 1500, 0);
}


static void process_level2()
{
    if (executing) {
        vm_step();
    } else {
        switch (l2s) {
            case 0:
                l2s ++;
                l2b_dialog();
                break;
            case 1:
                l2m_dialog();
                break;
        }
    }
}

#endif