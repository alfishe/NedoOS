#ifndef MENU_C
#define MENU_C
#include <evo.h>
#include "gameloop.c"
#include "engine.c" 
#include "font.c"

void instruction_page();

void menu_loop();

void init_menu_loop()
{
    music_play(MUS_EA2);
    instruction_page();
    menu_loop();
}

void instruction_page()
{
    init_text();
    text_x = 5;
    text_y = 0;
    put_str("Lost donation box incident\n\n");
    put_str("Code and levels by Nihirash\nGraphics by Hina\nMusic by EA, WBCBZ7, Scalesmann, Gogin,\nNihirash\n\n");
    text_x = 5;
    put_str("Spring begins with an incident!");
    put_str("\n\nReimu lost her donation box, right \nbefore the spring festival of flowers.\nTogether with the box, Aun Komano also \ndisappeared.");
    put_str("\n\nNow she want to get them back!\n\n");
    text_x = 2;
    put_str("Pick up ");
    put_char(128);
    put_str(" - for power up your shoots\n");
    text_x = 2;
    put_str("Pick up ");
    put_char(129);
    put_str(" - to increase your \n\n");
    text_x = 10;
    put_str("Controls:\n\n");
    //put_str("  ARROWS - movement\n  SPACE - fire\n\n\n\n");
    put_str("  ARROWS - movement\n  SPACE - fire\n\n");
    text_x = 7;
    put_str("Press FIRE to start game!\n\n");
    pal_bright(BRIGHT_MID);
    swap_screen();
}

void menu_loop()
{
    while (TRUE)
    {
        keyboard(keys);
        if (keys[FIRE])
            break;
        vsync();//swap_screen();
    }

    state = STATE_PLAY;
}

#endif