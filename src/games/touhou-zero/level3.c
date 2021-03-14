#ifndef LEVEL3_C
#define LEVEL3_C
#include "gameloop.c"
#include "level_fragments.h"
#include "engine.c"
#include "resources.h"
#include "dialogs.c"
#include "gameloop.c"
#include "sprite_pool.c"
#include "level4.c"

static void init_level(u8 image);
static void start_level(u8 image, u8 *name);

static void process_level3();

i16 px, py;
u8 l3s = 0;
const u8 l3intro[] = {
    DroppedEnemy(40, KNIFES, 10),
    DroppedEnemy(100, KNIFES, 10),
    DroppedEnemy(20, KNIFES, 10),
    DroppedEnemy(140, KNIFES, 10),
    DroppedEnemy(80, KNIFES, 10),
    DroppedEnemy(180, KNIFES, 10),
    Nop(10),
    End
};

const u8 boss3[] = {
    DroppedEnemy(20, KNIFES, 10),
    DroppedEnemy(40, KNIFES, 10),
    DroppedEnemy(100, KNIFES, 10),
    Nop(20),
    DroppedEnemy(30, KNIFES, 10),
    DroppedEnemy(40, KNIFES, 10),
    Nop(20),
    AimedCircle(FIREBALL, 1, 1), 
    Nop(10),
    AimedCircle(FIREBALL, 1, 1), 
    Nop(30),
    DroppedEnemy(10, KNIFES, 10),
    DroppedEnemy(90, KNIFES, 10),
    Nop(20),
    DroppedEnemy(20, KNIFES, 10),
    DroppedEnemy(190, KNIFES, 10),
    DroppedEnemy(140, KNIFES, 10),
    Nop(30),
    AimedCircle(FIREBALL, 1, 1), 
    Nop(10),
    AimedCircle(FIREBALL, 1, 1), 
    Nop(10),
    AimedCircle(FIREBALL, 1, 1), 
    Nop(40),
    MarisaHelp,
    Nop(20),
    DroppedEnemy(20, KNIFES, 10),
    DroppedEnemy(60, KNIFES, 10),
    Nop(20),
    DroppedEnemy(140, KNIFES, 10),
    DroppedEnemy(130, KNIFES, 10),
    DroppedEnemy(40, KNIFES, 10),
    Nop(20),
    End
};

const u8 level3[] = { 
    MakeEnemyWave(EYE, 1, 20),
    MakeLeftFlyers(70, BAT, 10, BONUS_CARD),
    MakeRightFlyers(120, BAT, 10, BONUS_CARD),
    MakeRightFlyers(15, BAT, 10, BONUS_CARD),
    Nop(20),
    MakeShootingStar(120, 64, FIREBALL, 20, 20),
    Nop(20),
    DroppedEnemy(20, KNIFES, 10),
    DroppedEnemy(40, KNIFES, 10),
    DroppedEnemy(100, KNIFES, 10),
    DroppedEnemy(30, KNIFES, 10),
    DroppedEnemy(40, KNIFES, 10), 
    Nop(10),
    DroppedEnemy(120, KNIFES, 10),
    DroppedEnemy(140, KNIFES, 10),
    DroppedEnemy(10, KNIFES, 10),
    DroppedEnemy(130, KNIFES, 10),
    DroppedEnemy(140, KNIFES, 10),
    Nop(20),
    MakeBoomFairy(120, 40, HEALTH_CARD),
    Nop(20),
    DroppedEnemy(20, KNIFES, 10),
    DroppedEnemy(40, KNIFES, 10),
    DroppedEnemy(100, KNIFES, 10),
    DroppedEnemy(30, KNIFES, 10),
    DroppedEnemy(40, KNIFES, 10),
    Nop(10), 
    DroppedEnemy(120, KNIFES, 10),
    DroppedEnemy(140, KNIFES, 10),
    DroppedEnemy(10, KNIFES, 10),
    DroppedEnemy(130, KNIFES, 10),
    DroppedEnemy(140, KNIFES, 10), 
    Nop(20), 
    AimedSideEnemies(KNIFE_LEFT, 10, 6),
    Nop(20),
    MarisaHelp,
    Nop(10),
    AimedCircle(FIREBALL, 5, 10),
    Nop(20),
    FiringTrap(EYE),
    Nop(20),
    TriangleHalf(1, BAT, 20, HEALTH_CARD),
    Nop(10),
    TriangleHalf(0, BAT, 20, HEALTH_CARD),
    Nop(20),
    MakeShootingStar(160, 70, FIREBALL, 33, 33),
    Nop(20),
    MidBoss1(EYE, 500),
    Nop(20),
    DoubleCaravan(BAT, 40, 50, BONUS_CARD),
    Nop(20),
    AimedCircle(FIREBALL, 5, 5),
    Nop(5),
    JustStar(80, 120, 5),
    AimedCircle(FIREBALL, 5, 5),
    DroppedEnemy(120, KNIFES, 10),
    DroppedEnemy(140, KNIFES, 10),
    DroppedEnemy(10, KNIFES, 10),
    DroppedEnemy(130, KNIFES, 10),
    DroppedEnemy(140, KNIFES, 10), 
    DroppedEnemy(120, KNIFES, 10),
    DroppedEnemy(140, KNIFES, 10),
    DroppedEnemy(10, KNIFES, 10),
    DroppedEnemy(130, KNIFES, 10), 
    DroppedEnemy(140, KNIFES, 10), 
    Nop(20),
    PushNpc(160, -20, 0, 1, MAID, 255, 1024, 0), 
    Nop(15),
    End
};

static void init_level3()
{
    level_loop = 0;
    scroll_speed = 1;
    process_level = process_level3;
    flush_sprites();
    start_level(IMG256_BG5, "Scarlet Devil Mansion");
    music_play(MUS_SISTERS);
    bullet_sprite = DEFAULT_BULLET;
    init_vm(l3intro);
    l3s = 0;
    state = STATE_PLAY;
}

static void dialog_l3b()
{
    init_dialog();
    vsync();//swap_screen();
    put_dialog_string(REIMU_FACE, "And here is the famous\nhospitality of the Scarlets.", 1);
    wait_for_space();
    flush_sprites();
    init_level(IMG256_BG5);
    init_vm(level3);
}

static void dialog_l3f()
{
    init_dialog();
    vsync();//swap_screen();
    put_dialog_string(REIMU_FACE, "I've not asked you!\nI'm going to talk with\nPatchuly!", 1);
    wait_for_space();
    flush_sprites();
    init_level4();
}

static void process_boss3()
{
    u8 c;
    Npc *boss;

    if (scroll_pos < 4) 
    {
        scroll_speed = -2;
    }
    
    if (scroll_pos > 190) {
        scroll_speed = 2;
    }

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
        dialog_l3f();
        return;
    }

    if (executing) {
        vm_step();
    } else {
        init_vm(boss3);
    }

    if (level_loop % 15 < 6) 
        push_star(boss->sprite.x + 8, boss->sprite.y);
}

static void dialog_l3m()
{
    music_play(MUS_HARD);
    init_dialog();
    vsync();//swap_screen();
    put_dialog_string(MAID_FACE, "Hello!\nWe today too busy!\nCome tomorrow please!", 0);
    put_dialog_string(REIMU_FACE, "I've asked about it?\nI need to talk with\nyour bookworm!", 1);
    put_dialog_string(MAID_FACE, "No no no!\nPatchuly is veery busy\nnow!", 0);
    wait_for_space();
    init_dialog();
    vsync();//swap_screen();
    put_dialog_string(REIMU_FACE, "Who will ask you?", 1);
    wait_for_space();
    init_level(IMG256_BG6);
    level_loop = 0;
    process_level = process_boss3;
    scroll_pos = 192;
    scroll_speed = 2;
    push_npc(144, 20, 2, 2, MAID, BOSS_TYPE, 1100, 1);
    init_vm(boss3);
    bullet_sprite = SAKUYA_BULLET;
}



static void process_level3()
{ 
    if (executing) {
        vm_step();
    } else {
        switch (l3s)
        {
        case 0:
            l3s++;
            dialog_l3b();
            break;
        case 1:
            dialog_l3m();
            break;
        default:
            break;
        }
    }
}
#endif