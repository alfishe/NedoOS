#include <evo.h>
#include "resources.h"

#define PAL256_FONT PAL_FONT_16
#define PAL256_BG1 PAL_BG1_16
#define PAL256_BG8 PAL_BG8_16
#define PAL16_SPRITES PAL_SPRITES_16
#define PAL256_FINAL PAL_FINAL_16
#define PAL256_TITLE PAL_TITLE_16

#define IMG256_FONT IMG_FONT_16
#define IMG256_BG1 IMG_BG1_16
#define IMG256_BG2 IMG_BG2_16
#define IMG256_BG3 IMG_BG3_16
#define IMG256_BG4 IMG_BG4_16
#define IMG256_BG5 IMG_BG5_16
#define IMG256_BG6 IMG_BG6_16
#define IMG256_BG7 IMG_BG7_16
#define IMG256_BG8 IMG_BG8_16
#define IMG256_FINAL IMG_FINAL_16
#define IMG256_TITLE IMG_TITLE_16

#define MAX_Y_RES 200/*240*/
#define STARTY 321

#define draw_tile_g256 draw_tile
#define unpack_pal256(a,b) pal_select(a)
#define unpack_pal16(a,n,b) pal_select(a)
#define draw_image_g256(x,y,n) draw_image(x,y,n)
#define set_screen_sync(a) ;
#define set_res(a) ;

u8 id = 0;

u8 create_sprite(u8 a, u8 wid8, u8 hgt8)
{// TODO
        //u8 id = 0;
        return id++;
}

void set_sprite256(u8 id, u16 tile, u8 pal, i16 x, i16 y)
{// TODO
        //x = x-16;
        if (x<0) x = 0;
        x = x>>1;
        if (x>160-8) x = 160-8;
        if (y<0) return;
        if (y>200-16) return;
        if (id>=64) return;
        set_sprite(id,x,y,(tile>>4)&0xff);
}

void scroll(i16 x, i16 y)
{// TODO
}

static u16 score;
static u8 lifes;

#include "sprite_pool.c"

#include "engine.c"
#include "font.c"

#include "gameloop.c"
#include "gameover.c"
#include "menu.c"
#include "dialogs.c"
#include "win_stage.c"

void intro()
{
	unpack_pal256(PAL256_TITLE, 0);
	draw_image_g256(0, 0, IMG256_TITLE);
	text_x = 11;
	text_y = 22;//25;
	//put_slow_str("This is party version!");
	text_y += 2;
	text_x = 12;
	put_slow_str("Press SPACE to start");
        swap_screen();
	while (!keys[FIRE])
	{
		keyboard(keys);
		vsync();//swap_screen();
	}
	for (cnt = BRIGHT_MID; cnt > BRIGHT_MIN; cnt--)
	{
		pal_bright(cnt);
		vsync();//swap_screen();
	}
}

void state_manager()
{
	while (TRUE)
	{
		music_stop();
		sprites_stop();
		switch (state)
		{
		case STATE_PLAY:
			start_game_loop();
			break;
		case STATE_MENU:
			init_menu_loop();
			break;
		case STATE_GAMEOVER:
			gameover();
			break;
		case STATE_WIN:
			win_stage();
			break;
		default:
			break;
		}
	}
}

void main(void)
{
	// Порт 0x20AF - порт управления скоростью CPU. Значение 6 - это 14МГц и включенный кэш(0110)
	//__asm 
	//ld bc, #0x20af 
	//ld a, #6 
	//out(c), a 
	//__endasm;
	set_screen_sync(1);
	set_res(MODE320X240);
	pal_bright(BRIGHT_MID);
	intro();
	scroll(0, 0);
	init_pool();
	state = STATE_MENU;
	state_manager();
}