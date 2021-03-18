#ifndef GAMELOOPC
#define GAMELOOPC
//#include "sprite_pool.c"
//#include "engine.c"
//#include <evo.h>
//#include "dialogs.c"
#include "bytecode.h"
#include "level1.c"
#include "level3.c"
#include "level4.c"
#include "interpreter.c"

#define LEFT KEY_5
#define RIGHT KEY_8
#define DOWN KEY_6
#define UP KEY_7
#define FIRE KEY_SPACE

static u8 i, j;
static void init_level(u8 pal, char *fn);

void game_loop();

static void start_level(u8 pal, char *fn, u8 *name)
{
    u8 c;
    music_stop();
    player.y = STARTY/*321*/;
    flush_sprites();
    init_text();
    swap_screen();
    text_y = 24/*29*/;
    text_x = 20;
    put_str("Girls are praying...");

    text_y = 10;
    text_x = 3;
    put_str("Lives: ");
    put_num(hp);
    text_y = 11;
    text_x = 3;
    put_str("Score: ");
    put_num(score);

    text_y = 2;
    text_x = 20 - strlen(name) / 2;
    put_slow_str(name);

    text_x = 10;
    text_y = 5;
    draw_face(REIMU_FACE);
    text_y--;
    text_x += 5;
//swap_screen();

    for (c = 0; c < 50; c++)
        swap_screen();
//swap_screen();
    draw_face(MARISA_FACE);
//swap_screen();
    text_y--;
    text_x += 5;
    for (c = 0; c < 50; c++)
        swap_screen();
//swap_screen();
    draw_face(CIRNO_FACE);
//swap_screen();
    for (c = 0; c < 100; c++)
        swap_screen();
    //init_level(image);
init_level(pal, fn);
}

static void init_level(u8 pal, char *fn)
{
    pal_bright(BRIGHT_MIN);
preparescroll(fn);
/*    if (image == IMG256_BG8) 
        unpack_pal256(PAL256_BG8, 0);
    else 
        unpack_pal256(PAL256_BG1, 0);*/
unpack_pal256(pal, 0);

    //unpack_pal16(PAL16_SPRITES, 15, 0);
    //draw_image_g256(0, 0, image);
scroll(0, 0);
drawscroll();
    pal_bright(BRIGHT_MID);
    player.x = 120;
    player.y = 168;
    flush_sprites();
    swap_screen();
    scroll_pos = 0;
    hor_scroll_pos = 0;
    hor_scroll_speed = 0;
    level_loop = 0;
    schedule = 0;
    add_cnt = 0;
sprites_start();
}



void start_game_loop()
{
    int i;
    hp = 3;
    score = 0;

    process_level = process_level1;
    //process_level = process_patchu;
    //process_level = process_level2;
    scroll_pos = 0;
    bullet_sprite = DEFAULT_BULLET;
    //start_level(IMG256_BG1, "Day before festival");
start_level(PAL256_BG1, "bg1-16.bmp", "Day before festival");
//start_level(PAL256_BG8, "bg8-16.bmp", "Day before festival");
    init_vm(level1_bytecode);
    //init_vm(level2_bc);
//init_vm(level4_2);
    music_play(MUS_TH0EA1);
    sprites_start();
    immortality = 20;
    game_loop();
}

static void player_control()
{
    if (keys[LEFT])
        player.x -= 4;
    if (keys[RIGHT])
        player.x += 4;
    if (keys[UP])
        player.y -= 4;
    if (keys[DOWN])
        player.y += 4;
    if (keys[FIRE])
        user_fire();

    if (player.x < MIN_X_RES/*0*/)
        player.x = MIN_X_RES/*0*/;
    if (player.x > MAX_X_RES/*300*/)
        player.x = MAX_X_RES/*300*/;
    if (player.y < MIN_Y_RES/*0*/)
        player.y = MIN_Y_RES/*0*/;
    if (player.y > MAX_Y_RES - 32)
        player.y = MAX_Y_RES - 32;
}

static void bg_scroll()
{
    scroll_pos -= scroll_speed;
    scroll_pos &= 511;
    hor_scroll_pos += hor_scroll_speed;
    hor_scroll_pos &= 511;

    scroll(hor_scroll_pos, scroll_pos);
}

static void process_events()
{
    if ((schedule & 7) == 0)
    {
        level_loop++;
        process_level();
        if (immortality)
        {
            immortality--;
        }
    }
}

static void player_collisions()
{
    static MovableSprite *b;
    if (!immortality && is_player_collide())
    {
        immortality = 20;
        player.x = 160;
        player.y = 168;
        cards = 3;
        hp--;
        sfx_play(1, 0);
        for (push_counter = 0; push_counter < BULLETS_count; push_counter++)
            bullets[push_counter].dy = 10;
    }
    b = is_player_collide_with_pups();
    if (b)
    {
        switch (b->tile)
        {
        case BONUS_CARD:
            if (cards < MY_BULLETS_max)
                cards++;
            break;
        case HEALTH_CARD:
            hp++;
            break;
        default:
            break;
        }
    }
}

void game_loop()
{
    scroll_speed = 1;
    immortality = 10;
    while (state == STATE_PLAY)
    {
        schedule++;

        if ((schedule & 3) == 0)
            anim_frame++;
        anim_frame &= 3;

        player.tile = (immortality & 1) ? 2560 : 0;
        if (schedule & 1)
        {
            keyboard(keys);
            player_control();
            player_collisions();
        }
        else
        {
            enemy_collision();
            process_events();
        }
        if (hp < 1)
        {
            state = STATE_GAMEOVER;
        }
begin_set_sprites();
        update_sprites(schedule & 1);
        //update_sprites(0);
        //update_sprites(1);
        if ((schedule & 3) == 0)
            bg_scroll();
        //swap_screen();
    
if (schedule & 1) {
end_set_sprites();
drawscroll();
swap_screen_scroll();
}
    }
}

#endif