#ifndef DIALOGS_C
#define DIALOGS_C
//#include <evo.h>
//#include "font.c"
//#include "engine.c"
//#include "sprite_pool.c"

//extern static u8 lifes;
//extern static u16 score;

#define REIMU_FACE 130
#define MARISA_FACE 146
#define CIRNO_FACE 170
#define MAID_FACE 186
#define PACHU_FACE 202
#define FLAN_FACE 218

#define POSITION_LEFT 1
#define POSITION_RIGHT 0

#define FRAME 162
#define FRAME_BOTTOM 169
#define FRAME_RIGHT_TOP 163
#define FRAME_RIGHT_BOTTOM 166
#define FRAME_VERTICAL_RIGHT 167
#define FRAME_VERTICAL_LEFT 168
#define FRAME_LEFT_BOTTOM 164
#define FRAME_LEFT_TOP 165
void draw_face(u16 start_point)
{
    u8 i;
    u8 position_x = text_x;
    for (i = 0; i < 4; i++)
    {
        text_x = position_x;
        put_char(start_point++);
        put_char(start_point++);
        put_char(start_point++);
        put_char(start_point++);
        text_y++;
    }
    text_y -= 3;
}

void put_slow_str(u8 *str)
{
    u8 i;
    while (1)
    {
        i = *str++;
        if (!i)
            break;
        put_char(i);
        swap_screen();
    }
}

void draw_frame(u8 position, u8 old_text_y)
{
    u8 c;
    u8 bias = position ? 0 : 5;
    u8 right = position ? 35 : 29;

    for (c = 5; c < right; c++)
    {
        text_x = c + bias;
        text_y = old_text_y + 4;
        put_char(FRAME_BOTTOM);
        text_x = c + bias;
        text_y = old_text_y;
        put_char(FRAME);
    }
    text_y = old_text_y;
    text_x = right + bias;
    put_char(FRAME_RIGHT_TOP);
    text_x = right + bias;
    text_y = old_text_y + 4;
    put_char(FRAME_RIGHT_BOTTOM);
    for (c = 1; c < 4; c++)
    {
        text_x = right + bias;
        text_y = old_text_y + c;
        put_char(FRAME_VERTICAL_RIGHT);
        text_x = 4 + bias;
        put_char(FRAME_VERTICAL_LEFT);
    }
    text_x = 4 + bias;
    text_y = old_text_y + 4;
    put_char(FRAME_LEFT_BOTTOM);
    text_x = 4 + bias;
    text_y = old_text_y;
    put_char(FRAME_LEFT_TOP);
}

// position 1 - left, 0 - right
void put_dialog_string(u16 avatar, u8 *phrase, u8 position)
{
    u8 old_text_y = text_y;
    left_pad = 0;
    text_x = position ? 0 : 35;
    draw_face(avatar);
    left_pad = position ? 5 : 10;
    right_pad = position ? 34 : 34;
    draw_frame(position, old_text_y);
    text_y = old_text_y + 1;
    text_x = position ? 5 : 10;
    put_slow_str(phrase);
    left_pad = 0;
    right_pad = 40;
    text_y = old_text_y + 6;
}

void init_dialog()
{
    init_text();
    player.y = STARTY/*321*/;
    flush_sprites();
    put_str(" Lives: ");
    put_num(hp);
    text_x = 25;
    put_str(" Score: ");
    put_num(score);
    text_x = 0;
    text_y += 2;
}

#endif