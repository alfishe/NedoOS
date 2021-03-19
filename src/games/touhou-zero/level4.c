#ifndef LEVEL4_C
#define LEVEL4_C
#include "gameloop.c"
#include "level_fragments.h"
#include "engine.c"
#include "resources.h"
#include "dialogs.c"
#include "gameloop.c"
#include "sprite_pool.c"
u8 l4s = 0;

//static void init_level(u8 image);
//static void start_level(u8 image, u8 *name);
static void init_level(u8 pal, char *fn);
static void start_level(u8 pal, char *fn, u8 *name);

void process_level4();

const u8 level4[] = {
    MakeCaravan(60, EYE, 1, 20, BONUS_CARD),
    Nop(10),
    MakeLeftFlyers(100, BAT, 5, 0),
    AimedCircle(FIREBALL, 10, 2),
    MakeRightFlyers(150, BAT, 5, 0),
    AimedCircle(FIREBALL, 10, 2),
    MakeLeftFlyers(180, BAT, 5, 0),
    AimedCircle(FIREBALL, 10, 2),
    MakeRightFlyers(50, BAT, 5, 0),
    AimedCircle(FIREBALL, 10, 2),
    Nop(20),
    MakeShootingStar(160, 80, ICEBALL, 10, 30),
    Nop(10),
    MakeCorridor(GHOST, 41, 10, BONUS_CARD),
    Nop(10),
    AimedSideEnemies(KNIFE_LEFT, 10, 10),
    Nop(5),
    Triangle(EYE, 30, HEALTH_CARD),
    Nop(4),
    MakeEnemyWave(BAT, 10, 20),
    MakeBoomFairy(50, 50, HEALTH_CARD),
    Nop(10),
    PushNpc(30, -20, 1, 1, EYE, 33, 15, 0),
    PushNpc(280, -20, -1, 1, EYE, 33, 15, 0),
    PushNpc(62, -20, 1, 1, EYE, 33, 15, 0),
    PushNpc(218, -20, -1, 1, EYE, 33, 15, 0),
    PushNpc(160, -20, -1, 1, EYE, 33, 15, 0),
    AimedShoot(33, 10),
    SetNpcSpeed(33, 0, 5),
    Nop(20),
    MakeEnemiesPair(BAT, 3, 30),
    MakeCaravan(20, EYE, 30, 40, HEALTH_CARD),
    Nop(10),
    MakeShootingStar(70, 60, FIREBALL, 20, 20),
    MakeShootingStar(250, 80, ICEBALL, 20, 20),
    AimedCircle(FIREBALL, 10, 10),
    MidBoss2(EYE, 100),
    Nop(10),
    DroppedEnemy(30, FIREBALL, 10),
    DroppedEnemy(230, FIREBALL, 10),
    DroppedEnemy(130, FIREBALL, 10),
    Nop(10),
    DroppedEnemy(50, FIREBALL, 10),
    DroppedEnemy(80, FIREBALL, 10),
    DroppedEnemy(180, FIREBALL, 10),
    Nop(10),
    DroppedEnemy(3, FIREBALL, 10),
    DroppedEnemy(74, FIREBALL, 10),
    DroppedEnemy(32, FIREBALL, 10),
    Nop(10),
    DroppedEnemy(210, FIREBALL, 10),
    DroppedEnemy(11, FIREBALL, 10),
    DroppedEnemy(63, FIREBALL, 10),
    Nop(10),
    TriangleHalf(1, EYE, 30, BONUS_CARD),
    Nop(10),
    MakeEnemyWave(GHOST, 30, 30),
    Nop(16),
    PushNpc(160, -20, 0, 1, FLANDRE, BOSS_TYPE, 2000, 0),
    Nop(15),
    End
};

const u8 level4_2[] = {
    MakeCaravan(32, BOOK, 1, 10, BONUS_CARD),
    Nop(10),
    MakeBoomFairy(100, 30, HEALTH_CARD),
    Nop(10),
    Triangle(BAT, 30, 0),
    MakeLeftFlyers(120, BOOK, 20, BONUS_CARD),
    JustStar(160, 120, 5),
    MakeRightFlyers(40, BOOK, 20, BONUS_CARD),
    Nop(10),
    MakeShootingStar(70, 70, FIREBALL, 44, 20),
    MakeShootingStar(180, 90, ICEBALL, 33, 20),
    JustStar(160,120, 5),
    Nop(20),
    DroppedEnemy(30, BOOK, 10),
    DroppedEnemy(230, BOOK, 10),
    DroppedEnemy(130, BOOK, 10),
    AimedCircle(FIREBALL, 5, 1),
    Nop(10),
    DroppedEnemy(50, BOOK, 10),
    DroppedEnemy(80, BOOK, 10),
    DroppedEnemy(180, BOOK, 10),
    DroppedEnemy(3, BOOK, 10),
    AimedCircle(FIREBALL, 5, 1),
    Nop(10),
    DroppedEnemy(74, BOOK, 10),
    DroppedEnemy(32, BOOK, 10),
    AimedCircle(FIREBALL, 5, 1),
    DroppedEnemy(210, BOOK, 10),
    DroppedEnemy(11, BOOK, 10),
    Nop(5),
    AimedCircle(FIREBALL, 5, 1),
    Nop(10),
    DroppedEnemy(63, BOOK, 10),
    Nop(10),
    AimedSideEnemies(KNIFE_LEFT, 1, 10),
    Nop(10),
    MakeEnemyWave(BOOK, 20, 10),
    Nop(10),
    MakeEnemiesPair(EYE, 99, 30),
    Nop(5),
    TriangleHalf(1, EYE, 30, BONUS_CARD),
    Nop(10),
    DroppedEnemy(30, FIREBALL, 10),
    DroppedEnemy(230, BOOK, 10),
    DroppedEnemy(130, FIREBALL, 10),
    Nop(10),
    DroppedEnemy(50, BOOK, 10),
    DroppedEnemy(80, FIREBALL, 10),
    DroppedEnemy(180, BOOK, 10),
    Nop(10),
    JustStar(160,120, 5),
    Nop(10),
    DroppedEnemy(3, FIREBALL, 10),
    DroppedEnemy(74, FIREBALL, 10),
    DroppedEnemy(32, BOOK, 10),
    Nop(10),
    DroppedEnemy(210, BOOK, 10),
    DroppedEnemy(11, FIREBALL, 10),
    DroppedEnemy(63, BOOK, 10),
    Nop(10),
    Triangle(EYE, 30, BONUS_CARD),
    Nop(10),
    MakeBoomFairy(100, 30, HEALTH_CARD),
    Nop(10),
    MakeShootingStar(60, 70, BOOK, 33, 33),
    MakeShootingStar(180, 90, BOOK, 33, 33),
    MakeShootingStar(160, 120, BOOK, 33, 33),
    Nop(10),
    PushNpc(160, -20, 0, 1, PATCHULY, BOSS_TYPE, 2000, 0),
    Nop(20),
    End
};

void init_level4()
{
    level_loop = 0;
    l4s = 0;
    flush_sprites();
    //start_level(IMG256_BG7, "Looking for Patchuly Knowlege");
start_level(PAL256_BG7, "bg7-16.bmp", "Looking for Patchuly Knowlege");
    music_play(MUS_ZONK);
    bullet_sprite = DEFAULT_BULLET;
    state = STATE_PLAY;
    init_vm(level4);
    process_level = process_level4;
    scroll_speed = 1;
}

void dialog_l4p2() 
{ 
    init_dialog();
    swap_screen();
    put_dialog_string(FLAN_FACE, "So...\nYou've played with me!\nWhat do you want?", 0);
    put_dialog_string(REIMU_FACE, "I'm flying to kick\nyour bookworm's ass!", 1);
    put_dialog_string(FLAN_FACE, "Sister Flan is sitting\nin the library!", 0);
//swap_screen();
    wait_for_space();
    //init_level(IMG256_BG7);
init_level(0/*PAL256_BG7*/, "bg7-16.bmp");
unpack_pal256(PAL256_BG7, 0);
    state = STATE_PLAY;
    process_level = process_level4;
    bullet_sprite = DEFAULT_BULLET;
    init_vm(level4_2);
}

const u8 patch_vm[] = {
    Nop(20),
    AimedShoot(BOSS_TYPE, 10),
    Nop(20),
    PushNpc(32, -20, 0, 1, MAID, 254, 50, HEALTH_CARD),
    PushNpc(280, -20, 0, 1, FLANDRE, 254, 50, HEALTH_CARD),
    Nop(10),
    SetNpcSpeed(254, 0, 0),
    AimedShoot(254, 10),
    SetNpcSpeed(254, 0, -3),
    Nop(10),
    AimedCircle(FIREBALL, 1, 3),
    Nop(10),
    AimedCircle(FIREBALL, 1, 3),
    Nop(10),
    AimedCircle(FIREBALL, 1, 3),
    End
};

u8 leftBonus = 0;

void last_dialog()
{
    init_dialog();
    swap_screen();
    put_dialog_string(PACHU_FACE, "Please stop!\nWhat a noise in my\nlibrary?", 0);
    put_dialog_string(REIMU_FACE, "I NEED TO TALK WITH YOU!\nAnd \"thank you\" Marisa for\n\"help\"", 1);
    put_dialog_string(MARISA_FACE, "I've sent you\nhealthing and my power!", 0);
//swap_screen();
    wait_for_space(); init_dialog();
    swap_screen();
    put_dialog_string(REIMU_FACE, "Like a drunken sniper...", 1);
    put_dialog_string(FLAN_FACE, "So...\nWhat do you want from\nmy sister?!", 0);
    put_dialog_string(REIMU_FACE, "My donations box is lost!\nHave you taken it for\nyour books?", 1);
//swap_screen();
    wait_for_space(); init_dialog();
    swap_screen();
    put_dialog_string(PACHU_FACE, "What?\n", 0);
    put_dialog_string(REIMU_FACE, "Also, Komano is lost...", 1);
    put_dialog_string(PACHU_FACE, "Oh, she came to me and\nasked for books about\nbox repairing...", 0);
//swap_screen();
    wait_for_space(); init_dialog();
    swap_screen();
    put_dialog_string(PACHU_FACE, "She went to the repair\nmaster. But you made\nall this noise!", 0);
    put_dialog_string(REIMU_FACE, "Okeey, as an apology, I'm\nwaiting for everyone to\nget drunk tonight.", 1);
    put_dialog_string(CIRNO_FACE, "I'll be there!", 0);
//swap_screen();
    wait_for_space(); init_dialog();
    swap_screen();
    put_dialog_string(REIMU_FACE, "But how do you appear\nhere?!", 1);
    put_dialog_string(CIRNO_FACE, "Cause I'm the strongest!And Sakuya just opened\nthe door..", 0);
    put_dialog_string(REIMU_FACE, "Fi-i-inee!\nLet's drink tonight!\nAnd even Cirno-tan.", 1);
//swap_screen();
    wait_for_space(); 
    state = STATE_WIN;
}

void process_patchu()
{
    Npc *boss;
    
    boss = find_npc_by_type(BOSS_TYPE);
    if (!boss) {
        last_dialog();
        return ;
    }

    if (!executing) {
        init_vm(patch_vm);
    }

    vm_step();

    if (boss->sprite.x > 280 || boss->sprite.x < 30) 
        boss->sprite.dx = -boss->sprite.dx;

    if (scroll_pos < 2 || scroll_pos > 300/*260*/) {
        scroll_speed = -scroll_speed;
    }

    if (hor_scroll_pos < 2 || hor_scroll_pos > 195) {
        hor_scroll_speed = -hor_scroll_speed;
    }
    
    switch (level_loop % 60) {
        boss_shoot1(0, boss->sprite.x, boss->sprite.y)
        just_star(30, boss->sprite.x + 16, boss->sprite.y + 16)
        just_star(35, boss->sprite.x + 16, boss->sprite.y + 16)
        just_star(40, boss->sprite.x + 16, boss->sprite.y + 16)
        just_star(45, boss->sprite.x + 16, boss->sprite.y + 16)
        case 59:
            if (leftBonus) {
                push_bonus(HEALTH_CARD, 10, 80, 2, -5);
                push_bonus(BONUS_CARD, 100, 80, 0, -5);
                push_bonus(HEALTH_CARD, 30, 80, 2, -5);
            } else {
                push_bonus(HEALTH_CARD, 160, 80, 0, -5);
                push_bonus(BONUS_CARD, 260, 80, -2, -5);
                push_bonus(BONUS_CARD, 280, 80, -2, -5);    
            }
            leftBonus = !leftBonus;
            break;
        
    }

}

void dialog_l4p3()
{
    init_dialog();
    swap_screen();
    put_dialog_string(PACHU_FACE, "What a noise?!", 0);
    put_dialog_string(REIMU_FACE, "Oh...\nI've found you!", 1);
    put_dialog_string(PACHU_FACE, "Please, stop this noise!", 0);
//swap_screen();
    wait_for_space();
    init_dialog();
    swap_screen();
    put_dialog_string(REIMU_FACE, "I need to talk with you.", 1);
//swap_screen();
    wait_for_space();
    //init_level(IMG256_BG8);
music_stop();
init_level(PAL256_BG8, "bg8-16.bmp");
    pal_bright(BRIGHT_MIN);
    swap_screen();
    //unpack_pal256(PAL256_BG8, 0);
    //unpack_pal16(PAL16_SPRITES, 15, 0);
    pal_bright(BRIGHT_MID);
    swap_screen();
    process_level = process_patchu;
    music_play(MUS_TH0PN);
    state = STATE_PLAY;
    scroll_pos = 192;
    hor_scroll_pos = 150;
    scroll_speed = -3;
    hor_scroll_speed = 3;
    push_npc(160, 32, 2, 0, PATCHULY, BOSS_TYPE, 1024, 0);
    bullet_sprite = BULLET2;
    level_loop = 0;
    init_vm(patch_vm);
}

void process_flandre()
{
    Npc *boss;
    Npc *bossClone;

    boss = find_npc_by_type(BOSS_TYPE);
    bossClone = find_npc_by_type(254);

    if (boss) {
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

        if (bossClone) {
            if (bossClone->sprite.x <= 20 || bossClone->sprite.x >= 280)
            {
                bossClone->sprite.dx = -bossClone->sprite.dx;
                bossClone->sprite.x += bossClone->sprite.dx;
            }
            if (bossClone->sprite.y <= 20 || bossClone->sprite.y >= 120)
            {
                bossClone->sprite.dy = -bossClone->sprite.dy;
                bossClone->sprite.y += bossClone->sprite.dy;
            }
        }

        if (level_loop % 10 < 4) {
            push_star(boss->sprite.x + 16, boss->sprite.y + 16);
            if (bossClone) push_star(bossClone->sprite.x + 16, bossClone->sprite.y + 16);
        }

        switch (level_loop % 150)
        {
        case 0:
            push_npc(boss->sprite.x, boss->sprite.y, -boss->sprite.dx, -boss->sprite.dy, FLANDRE, 254, 30, HEALTH_CARD);
            break;
        case 50:
            npc_by_type_set_speed(254, 0, 330);
            break;
        case 100:
            push_bonus(HEALTH_CARD, 160, 120, -2, -3);
            push_bonus(HEALTH_CARD, 160, 120, 0, -5);
            push_bonus(HEALTH_CARD, 160, 120, 2, 3);
            push_bonus(BONUS_CARD, 160, 100, -2, -3);
            push_bonus(BONUS_CARD, 160, 100, 0, -5);
            push_bonus(BONUS_CARD, 160, 100, 2, 3);
            break;
        }
    } else {
        dialog_l4p2();
    }
}

void dialog_l4p1()
{
    init_dialog();
    swap_screen();
    put_dialog_string(FLAN_FACE, "Hello, Reddy-sister!\nAre you gonna play with me?", 0);
    put_dialog_string(REIMU_FACE, "Flan, I have no time\nfor this!", 1);
    put_dialog_string(FLAN_FACE, "Oh sister...\nYou'll play with me!", 0);
//swap_screen();
    bullet_sprite = FLAN_BULLET;
    process_level = process_flandre;
    wait_for_space();
    //init_level(IMG256_BG7);
init_level(0/*PAL256_BG7*/, "bg7-16.bmp");
unpack_pal256(PAL256_BG7, 0);
    push_npc(32, 32, 2, 3, FLANDRE, BOSS_TYPE, 500, HEALTH_CARD);
    state = STATE_PLAY;
}

void process_level4()
{
    if (executing) {
        vm_step();
    } else {
        switch (l4s) {
            case 0:
                l4s++;
                dialog_l4p1();
                break;
            case 1:
                dialog_l4p3();
                break;
        }
    }
}

#endif
