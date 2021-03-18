#ifndef GAMEOVER_C
#define GAMEOVER_C

#include <evo.h>
#include "font.c"
#include "gameloop.c"
#include "engine.c"

void gameover()
{
    init_text();
    text_y = 12/*14*/;
    text_x = 15;
    put_str("Game Over!\n");
    text_x = 12;
    put_str("Your score: ");
    put_num(score);
    swap_screen();
    for (i=0;i<200;i++)
        swap_screen();
    state = STATE_MENU;
}

#endif