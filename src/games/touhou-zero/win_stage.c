#ifndef WIN_STAGE_C
#define WIN_STAGE_C

#include <evo.h>
#include "font.c"
#include "gameloop.c"
#include "engine.c"

void win_stage()
{
u16 curscroll = 1;
i16 curdscroll = 1;
u16 cycles = 256*6;
preparescroll("final-16.bmp");
    music_play(MUS_WIN);
    pal_bright(BRIGHT_MIN);    
    scroll(0, 0);
    unpack_pal256(PAL256_FINAL, 0);
    //draw_image_g256(0, 0, IMG256_FINAL);
    pal_bright(BRIGHT_MID);
swap_screen();

    for (;cycles!=0;cycles--) {
scroll(0, 512-240+curscroll);
drawscroll();
if ((curscroll==0)||(curscroll==40)) curdscroll = -curdscroll;
curscroll+=curdscroll;
        swap_screen_scroll();
    }

    init_text();
    text_y = 11/*14*/;
    text_x = 15;
    put_str("You win!\n");
    text_x = 12;
    put_str("Your score: ");
    put_num(score);
    text_x = 1;
    text_y += 2;
    put_str("This is party version of\n\"Lost Donation Box Incident\" game.\n\n Thank you for playing!\n\n Have a nice days on CAFe DEMOPARTY 2019 \n\nYou may support development via PayPal:\n\n           anihirash@gmail.com");
swap_screen();
    for (i = 0; i < 200; i++)
        vsync();//swap_screen();

    while (TRUE)
    {
        keyboard(keys);
        if (keys[FIRE])
        {
            while (keys[FIRE])
                keyboard(keys);
            state = STATE_MENU;
            break;
        }
    }
}

#endif