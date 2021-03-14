#ifndef ENGINE_C
#define ENGINE_C
//#include <evo.h>
//#include "sprite_pool.c"

#define STATE_PLAY 0
#define STATE_TALK 1
#define STATE_GAMEOVER 2
#define STATE_WIN 3
#define STATE_MENU 4

static u8 state = STATE_MENU;

#define GHOST 16
#define FAIRY 32
#define BAT 48
#define INJAN 260
#define BOOK 276
#define KNIFES 292
#define ICE 528
#define FIARY2 784
#define FROG 800
#define ICEBALL 816
#define FIREBALL 544
#define EYE 560
#define FIARY3 1040
#define SHARP_ICE 1056
#define KNIFE_LEFT 1552

#define DEFAULT_BULLET 0x102
#define MARISA_BULLET 0x143
#define CIRNO_BULLET 0x100
#define SAKUYA_BULLET 0x140
#define FLAN_BULLET 0x101
#define BULLET2 0x141


#define CIRNO 512
#define FLANDRE 768
#define MARISA 1024
#define MAID 1536
#define PATCHULY 1792
#define FAIRY_MB 2048
static u8 keys[40];
static u8 is_npc_right_type(Npc *n, u8 type);
//static u16 score;
static u8 hp;
static i16 scroll_pos;
static i16 hor_scroll_pos = 0;
static u32 level_loop;
static i8 scroll_speed;
static i8 hor_scroll_speed = 0;
static i8 immortality = -1;
static u8 schedule = 0;
static u8 add_cnt = 0;
static u8 push_counter = 0;
static void (*process_level)();
static u16 bullet_sprite = DEFAULT_BULLET;

void wait_for_space()
{
    while (1)
    {
        keyboard(keys);
        if (keys[KEY_SPACE])
            break;
        vsync();//swap_screen();
    }
}

static void push_npc(i16 x, i16 y, i8 dx, i8 dy, u16 tile, u8 type, u16 hp, u16 bonus)
{
    i8 npc = find_free_npc();

    if (npc != -1)
    {
        npcs[npc].sprite.tile = tile;
        npcs[npc].sprite.x = x;
        npcs[npc].sprite.y = y;
        npcs[npc].sprite.dx = dx;
        npcs[npc].sprite.dy = dy;
        npcs[npc].hp = hp;
        npcs[npc].type = type;
        npcs[npc].take_bonus = bonus;
    }
}

static void push_bonus(u16 type, u16 x, u16 y, i8 dx, i8 dy)
{
    i8 b = find_free_bonus();
    if (b >= 0)
    {
        bonuses[b].x = x;
        bonuses[b].y = y;
        bonuses[b].tile = type;
        bonuses[b].dx = dx;
        bonuses[b].dy = dy;
    }
}

static void push_bullet(u16 x, u16 y, i8 dx, i8 dy)
{
    i8 b = find_free_bullet();
    if (b != -1)
    {
        bullets[b].x = x;
        bullets[b].y = y;
        bullets[b].dx = dx;
        bullets[b].dy = dy;
        bullets[b].tile = bullet_sprite;
    }
}

static void push_star(u16 x, u16 y)
{
    push_bullet(x + 2, y + 3, 2, 3);
    push_bullet(x + 3, y + 0, 3, 0);
    push_bullet(x + 3, y - 2, 3, -2);
    push_bullet(x + 1, y - 4, 1, -4);
    push_bullet(x - 1, y - 4, -1, -4);
    push_bullet(x - 4, y - 3, -4, -3);
    push_bullet(x - 4, y - 1, -4, -1);
    push_bullet(x - 4, y + 2, -4, 2);
    push_bullet(x - 2, y + 3, -2, 3);
}

static void npc_type_shoot(u8 type, i8 dx, i8 dy)
{
    static u8 npc;
    for (npc = 0; npc < NPC_count; npc++)
    {
        if (is_npc_right_type(&npcs[npc], type))
        {
            push_bullet(npcs[npc].sprite.x + 16, npcs[npc].sprite.y + 16, dx, dy);
        }
    }
}

static i16 abs(i16 v)
{
    if (v < 0)
        return -v;

    return v;
}

static i16 sign(i16 v)
{
    if (v < 0)
        return -1;

    return 1;
}

static i16 min(i16 x, i16 y)
{
    return x < y ? x : y;
}

static i16 max(i16 x, i16 y)
{
    return x > y ? x : y;
}

static void npc_aimed_shoot(u8 type)
{
    i16 dx;
    i16 dy;
    static u8 npc;
    for (npc = 0; npc < NPC_count; npc++)
    {
        if (is_npc_right_type(&npcs[npc], type))
        {
            dx = player.x - npcs[npc].sprite.x;
            dy = player.y - npcs[npc].sprite.y;
            dx = sign(dx) * min(abs(dx) / 8, 5);
            dy = sign(dy) * min(abs(dy) / 8, 5);

            push_bullet(npcs[npc].sprite.x + 16, npcs[npc].sprite.y + 16, dx, dy);
        }
    }
}

static void npc_shoot(i8 dx, u8 dy)
{
    static u8 npc;
    for (npc = 0; npc < NPC_count; npc++)
    {
        if (is_npc_active(&npcs[npc]))
        {
            push_bullet(npcs[npc].sprite.x + 16, npcs[npc].sprite.y + 16, dx, dy);
        }
    }
}

static void npc_type_star(u8 type)
{
    static u8 npc;
    for (npc = 0; npc < NPC_count; npc++)
    {
        if (is_npc_right_type(&npcs[npc], type))
        {
            push_star(npcs[npc].sprite.x + 16, npcs[npc].sprite.y + 16);
        }
    }
}

static void npc_by_type_set_speed(u8 type, i8 dx, i8 dy)
{
    static u8 npc;
    for (npc = 0; npc < NPC_count; npc++)
    {
        if (is_npc_right_type(&npcs[npc], type))
        {
            npcs[npc].sprite.dx = dx;
            npcs[npc].sprite.dy = dy;
        }
    }
}

static void user_fire()
{
    i8 bullet = find_free_my_bullet();
    if (bullet > -1)
    {
        my_bullets[bullet].tile = MY_BULLET;
        my_bullets[bullet].x = player.x + 8;
        my_bullets[bullet].y = player.y - 8;
        my_bullets[bullet].dx = 0;
        my_bullets[bullet].dy = -16;
    }
}

static u8 is_npc_right_type(Npc *n, u8 type)
{
    return n->type == type && is_npc_active(n);
}

static u8 is_player_collide_with_bullet(MovableSprite *bullet)
{
    return bullet->x < player.x + 28 &&
           bullet->x + 8 > player.x + 4 &&
           bullet->y < player.y + 28 &&
           bullet->y + 8 > player.y + 4;
}

static u8 is_player_collide_with_enemy(MovableSprite *enemy)
{
    return enemy->x + 4 < player.x + 28 &&
           enemy->x + 28 > player.x &&
           enemy->y + 4 < player.y + 28 &&
           enemy->y + 28 > player.y;
}

static u8 is_enemy_collide_with_bullet(MovableSprite *enemy, MovableSprite *bullet)
{
    return enemy->x < bullet->x + 8 &&
           enemy->x + 28 > bullet->x &&
           enemy->y + 4 < bullet->y + 16 &&
           enemy->y + 28 > bullet->y;
}

static MovableSprite *is_player_collide_with_pups()
{
    static u8 cnt;
    for (cnt = 0; cnt < MAX_BONUS_COUNT; cnt++)
    {
        if (bonuses[cnt].y < MAX_Y_RES &&
            bonuses[cnt].x < player.x + 28 &&
            bonuses[cnt].x + 8 > player.x + 4 &&
            bonuses[cnt].y < player.y + 28 &&
            bonuses[cnt].y + 8 > player.y + 4)
        {
            bonuses[cnt].y = MAX_Y_RES + 1;
            return &bonuses[cnt];
        }
    }

    return 0;
}

static u8 is_player_collide()
{
    for (cnt = 0; cnt < BULLETS_count; cnt++)
        if (is_bullet_active(&bullets[cnt]) && is_player_collide_with_bullet(&bullets[cnt]))
        {
            return 1;
        }

    for (cnt = 0; cnt < NPC_count; cnt++)
        if (is_npc_active(&npcs[cnt]) && is_player_collide_with_enemy(&npcs[cnt].sprite))
        {
            npcs[cnt].hp--;
            return 1;
        }

    return 0;
}

static void enemy_collision()
{
    static u8 ec, cnt;
    u8 is_played = 0;
    for (cnt = 0; cnt < MY_BULLETS_max; cnt++)
        if (is_bullet_active(&my_bullets[cnt]))
            for (ec = 0; ec < NPC_count; ec++)
                if (is_npc_active(&npcs[ec]) && is_enemy_collide_with_bullet(&npcs[ec].sprite, &my_bullets[cnt]))
                {
                    if (my_bullets[cnt].tile == MY_BULLET)
                        my_bullets[cnt].tile = MY_BULLET + 2;

                    if (!is_played)
                    {
                        sfx_play(0, -3);
                        is_played = 1;
                    }
                    npcs[ec].hp--;
                    score ++;
                }
}

static Npc *find_npc_by_type(u8 type)
{
    u8 i;
    for (i = 0; i < NPC_count; i++)
    {
        if (is_npc_right_type(&npcs[i], type))
        {
            return &npcs[i];
        }
    }

    return 0;
}
#endif