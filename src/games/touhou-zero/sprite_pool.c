#ifndef SPRITEPOOL_C
#define SPRITEPOOL_C

#define MY_BULLET   0x500
//#define BONUS_CARD 0x103
//#define HEALTH_CARD 0x142
#define BONUS_CARD 0x512
#define HEALTH_CARD 0x518

#define NPC_count 15
#define BULLETS_count 45
#define MY_BULLETS_max 10
#define MAX_BONUS_COUNT 14

#define SPR_FLIPX 16/*32768*/
#define SPR_FLIPY 16384
//#define MAX_Y_RES 240

#define BOSS_TYPE 255

//extern static u16 score;

static void push_bonus(u16 type, u16 x, u16 y, i8 dx, i8 dy);
/*
struct game_sprite
{
    u8 id;
    u8 pal;
    i16 x;
    i16 y;
    u16 tile;
};
*/
struct movable_sprite
{
    u8 id;
    u8 pal;
    i16 x;
    i16 y;
    u16 tile;
    i8 dx;
    i8 dy;
};

typedef struct game_sprite Sprite;
typedef struct movable_sprite MovableSprite;

struct npc
{
    MovableSprite sprite;
    u16 hp;
    u8 type;
    u16 take_bonus;
};

typedef struct npc Npc;

Sprite player;
Npc npcs[NPC_count];
MovableSprite bullets[BULLETS_count];
MovableSprite my_bullets[MY_BULLETS_max];
MovableSprite bonuses[MAX_BONUS_COUNT];

static u8 cnt;
static u8 cards;

//static u8 anim_shift[] = {0, 4, 8, 12}; //const needed!!!
static u8 anim_frame = 0;

static u8 is_bullet_active(MovableSprite *bullet)
{
    return bullet->y < MAX_Y_RES && bullet->y > -10 && bullet->x > -10 && bullet->x < 320;
}

static u8 is_npc_active(Npc *npc)
{
    return npc->hp && npc->sprite.y < MAX_Y_RES + 40 && npc->sprite.x >= -16/*-60*/ && npc->sprite.x < 360 && npc->sprite.y > -40;
}



void init_pool()
{
    cards = 2;
    player.id = create_sprite(1, 4, 4);
    player.pal = 15;
    set_sprite256(player.id, 0, 15, 160, 205);

    for (cnt = 0; cnt < NPC_count; cnt++)
    {
        npcs[cnt].sprite.id = create_sprite(2, 4, 4);
        npcs[cnt].sprite.y = MAX_Y_RES + 1;
        npcs[cnt].hp = 0;
        npcs[cnt].sprite.pal = 15;
        set_sprite256(npcs[cnt].sprite.id, 0, 15, 160, 205);
    }

    for (cnt = 0; cnt < BULLETS_count; cnt++)
    {
        bullets[cnt].id = create_sprite(0, 1, 1);
        bullets[cnt].y = MAX_Y_RES + 1;
        bullets[cnt].pal = 15;
        set_sprite256(bullets[cnt].id, 0, 15, 160, 205);
    }

    for (cnt = 0; cnt < MAX_BONUS_COUNT; cnt++)
    {
        bonuses[cnt].id = create_sprite(0, 1, 1);
        bonuses[cnt].y = MAX_Y_RES + 1;
        bonuses[cnt].pal = 15;
        bonuses[cnt].dx = 0;
        bonuses[cnt].dy = 0;
        set_sprite256(bonuses[cnt].id, 0, 15, 160, 235);
    }

        for (cnt = 0; cnt < MY_BULLETS_max; cnt++)
    {
        my_bullets[cnt].id = create_sprite(2, 2, 2);
        my_bullets[cnt].y = -32;
        my_bullets[cnt].pal = 15;
        my_bullets[cnt].dx = 0;
        my_bullets[cnt].dy = 0;
        set_sprite256(my_bullets[cnt].id, 0, 15, 160, 105);
    }
}

static i8 find_free_bullet()
{
    for (cnt = 0; cnt < BULLETS_count; cnt++)
        if (!is_bullet_active(&bullets[cnt]))
            return cnt;

    return -1;
}

static i8 find_free_my_bullet()
{
    if (cards > MY_BULLETS_max) cards = MY_BULLETS_max;
    for (cnt = 0; cnt < cards; cnt++)
        if (my_bullets[cnt].y < 0 || my_bullets[cnt].tile >= MY_BULLET + 6)
            return cnt;

    return -1;
}

static i8 find_free_npc()
{
    for (cnt = 0; cnt < NPC_count; cnt++)
        if (!is_npc_active(&npcs[cnt]))
            return cnt;

    return -1;
}

static i8 find_free_bonus()
{
    static u8 cnt;
    for (cnt = 0; cnt < MAX_BONUS_COUNT; cnt++)
        if (bonuses[cnt].y > MAX_Y_RES || bonuses[cnt].x < 0 || bonuses[cnt].x > 320 || bonuses[cnt].y < 0)
            return cnt;

    return -1;
}

static void update_sprites(u8 part) //координаты спрайтов каждой из двух частей (part) обновляются через фрейм
{
    static u8 b;
    set_sprite256(player.id, player.tile + (anim_frame<<2)/*anim_shift[anim_frame]*/, player.pal, player.x, player.y);
    if (part)
    {
        for (cnt = 0; cnt < BULLETS_count; cnt++)
        {
            if (is_bullet_active(&bullets[cnt]))
            {
                bullets[cnt].y += bullets[cnt].dy;
                bullets[cnt].x += bullets[cnt].dx;
            }
            set_sprite256(bullets[cnt].id, bullets[cnt].tile, bullets[cnt].pal, bullets[cnt].x, bullets[cnt].y);

            if (cnt < MAX_BONUS_COUNT)
            {
                if (bonuses[cnt].y < MAX_Y_RES + 4 && bonuses[cnt].x > -8 && bonuses[cnt].x < 328)
                {
                    if (bonuses[cnt].dy < 4) bonuses[cnt].dy ++;

                    bonuses[cnt].y += bonuses[cnt].dy;
                    bonuses[cnt].x += bonuses[cnt].dx;
                }
                set_sprite256(bonuses[cnt].id, bonuses[cnt].tile, bonuses[cnt].pal, bonuses[cnt].x, bonuses[cnt].y);
            }

            if (cnt < MY_BULLETS_max)
            {
                if (my_bullets[cnt].tile >= MY_BULLET + 6) my_bullets[cnt].y = -20;
                
                if (my_bullets[cnt].y > -16 && my_bullets[cnt].tile == MY_BULLET)
                {
                    my_bullets[cnt].y += my_bullets[cnt].dy;
                    my_bullets[cnt].x += my_bullets[cnt].dx;
                }

                set_sprite256(my_bullets[cnt].id, my_bullets[cnt].tile, my_bullets[cnt].pal, my_bullets[cnt].x, my_bullets[cnt].y);

                if (my_bullets[cnt].tile != MY_BULLET) my_bullets[cnt].tile += 2;
            }
        }
    }
    else
    {
        for (cnt = 0; cnt < NPC_count; cnt++)
        {
            if (npcs[cnt].hp < 1 && npcs[cnt].sprite.y < MAX_Y_RES)
            {
                score += 5;
                sfx_play(3, 3);
                if (npcs[cnt].take_bonus)
                {
                    push_bonus(npcs[cnt].take_bonus, npcs[cnt].sprite.x + 16, npcs[cnt].sprite.y + 16, 0, -5);
                }
                npcs[cnt].sprite.y = MAX_Y_RES + 1;
            }
            if (is_npc_active(&npcs[cnt]))
            {
                npcs[cnt].sprite.y += npcs[cnt].sprite.dy;
                npcs[cnt].sprite.x += npcs[cnt].sprite.dx;
            }
            if (npcs[cnt].type == BOSS_TYPE || 
                npcs[cnt].sprite.tile == 1552) 
            {
                set_sprite256(npcs[cnt].sprite.id, npcs[cnt].sprite.tile + (anim_frame<<2)/*anim_shift[anim_frame]*/ + (((npcs[cnt].sprite.dx < 0)&&(npcs[cnt].sprite.tile == 1552)) ? SPR_FLIPX : 0), npcs[cnt].sprite.pal, npcs[cnt].sprite.x, npcs[cnt].sprite.y);
            } 
            else 
            {
                set_sprite256(npcs[cnt].sprite.id, npcs[cnt].sprite.tile + (anim_frame<<2)/*anim_shift[anim_frame]*/, npcs[cnt].sprite.pal, npcs[cnt].sprite.x, npcs[cnt].sprite.y);
            } 
            
        }
    }
}

static void flush_sprites()
{
    for (cnt = 0; cnt < BULLETS_count; cnt++)
    {
        bullets[cnt].y = 400;
        if (cnt < NPC_count)
            npcs[cnt].sprite.y = 400;

        if (cnt < MY_BULLETS_max)
            my_bullets[cnt].y = -40;

        if (cnt < MAX_BONUS_COUNT)
            bonuses[cnt].y = 400;
    }
//begin_set_sprites();
    update_sprites(0);
    update_sprites(1);
end_set_sprites();
}

#endif