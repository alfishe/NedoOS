//#define CHEAT

#include <evo.h>
#include "functions.h"
#include "resources.h"

#define PAL256_FONT PAL_FONT_16
#define PAL256_BG1 PAL_BG1_16
#define PAL256_BG2 PAL_BG2_16
#define PAL256_BG3 PAL_BG3_16
#define PAL256_BG4 PAL_BG4_16
#define PAL256_BG5 PAL_BG5_16
#define PAL256_BG6 PAL_BG6_16
#define PAL256_BG7 PAL_BG7_16
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

#define MIN_X_RES 8/*0*/
#define MAX_X_RES 296/*300*/
#define MIN_Y_RES 16/*0*/
#define MAX_Y_RES 216/*240*/
#define STARTY 321

#define draw_tile_g256 draw_tile
#define unpack_pal256(a,b) pal_select(a)
#define unpack_pal16(a,n,b) pal_select(a)
#define draw_image_g256(x,y,n) draw_image(x,y,n)
#define set_screen_sync(a) ;
#define set_res(a) ;

struct game_sprite
{
    u8 id;
    u8 pal;
    i16 x;
    i16 y;
    u16 tile;
};

u8 id = 0;

struct game_sprite sprlist[85];

void preparescroll(char *fn) __naked
{
__asm
	ld hl,#2
	add hl,sp
	ld e,(hl)
        inc hl
	ld d,(hl)
       push ix
	call _PREPARESCROLL
       pop ix
        ret
__endasm;
}

void incscroll(i16 scroll) __naked
{
__asm
	ld hl,#2
	add hl,sp
	ld c,(hl)
        inc hl
	ld b,(hl)
       push ix
	call _INCSCROLL
       pop ix
        ret
__endasm;
}

void drawscroll(void) __naked
{
__asm
	ld hl,#2
	add hl,sp
       push ix
	call _DRAWSCROLL
       pop ix
        ret
__endasm;
}

void swap_screen_scroll(void) __naked
{
__asm
	jp _SWAP_SCREEN_SCROLL
__endasm;
}

u8 create_sprite(u8 a, u8 wid8, u8 hgt8)
{// TODO
        //u8 id = 0;
        return id++;
}

void begin_set_sprites()
{
        //id = 0;
}

void end_set_sprites()
{
    u8 i;
    u8 id = 0;
    for (i = 0; i < 85; i++) {
        if (sprlist[i].x<0) continue;
        if (sprlist[i].x>320-16) continue;
        if (sprlist[i].y<0) continue;
        if (sprlist[i].y>200-16) continue;
        if (id<64) set_sprite(id++,sprlist[i].x>>1,sprlist[i].y,sprlist[i].tile);
        if ((sprlist[i].tile & 0xffc0) != 0x140) {
           if ((id<64)&&((sprlist[i].x>>1)<=160-16)) set_sprite(id++,(sprlist[i].x>>1)+8,sprlist[i].y   ,sprlist[i].tile+1);
           if (sprlist[i].y>200-32) continue;
           if (id<64) set_sprite(id++,(sprlist[i].x>>1)  ,sprlist[i].y+16,sprlist[i].tile+32);
           if ((id<64)&&((sprlist[i].x>>1)<=160-16)) set_sprite(id++,(sprlist[i].x>>1)+8,sprlist[i].y+16,sprlist[i].tile+33);
        }
    }
    if (id<64) set_sprite(id,0,0,-1);
    //drawscroll();
}

void set_sprite256(u8 id, u16 tile, u8 pal, i16 x, i16 y)
{
        //x = x-16;
        //if (x<0) return; //x = 0;
        //x = x>>1;
        //if (x>160-8) return; //x = 160-8;
        //if (y<0) return;
        //if (y>200-16) return;
        //if (id>=64) return;
        //set_sprite(id,x,y,1/*(tile>>4)&0xff*/);
        sprlist[id].x = x-8;
        sprlist[id].y = y-16;
        sprlist[id].tile = ((tile&0xff)>>1) + ((tile&0x0f00)>>2);
}

void setscroll(u16 scroll) __naked
{
__asm
	ld hl,#2
	add hl,sp
	ld a,(hl)
        inc hl
	ld h,(hl)
        ld l,a
       push ix
	call _SETSCROLL
       pop ix
        ret
__endasm;
}

void scroll(i16 x, i16 y)
{// TODO x
__asm
	ld hl,#2
	add hl,sp
       inc hl
       inc hl
	ld a,(hl)
        inc hl
	ld h,(hl)
        ld l,a
       push ix
	call _SETSCROLL
       pop ix
        ret
__endasm;
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
		//sprites_stop();
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
u16 curscroll;
	// Порт 0x20AF - порт управления скоростью CPU. Значение 6 - это 14МГц и включенный кэш(0110)
	//__asm
	//ld bc, #0x20af
	//ld a, #6
	//out(c), a
	//__endasm;
	set_screen_sync(1);
	set_res(MODE320X240);
	pal_bright(BRIGHT_MID);
sprites_start();
	intro();
/*
preparescroll("bg2-16.bmp");
curscroll=0;
while(1) {
scroll(0, curscroll++);
drawscroll();
swap_screen_scroll();
}
*/
	scroll(0, 0);
	init_pool();
	state = STATE_MENU;
	state_manager();
}