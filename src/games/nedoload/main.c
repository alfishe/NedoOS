#include <evo.h>
#include "nedoload.h"

/*
void draw_image(u8 x,u8 y,u8 id) __naked
{
__asm

	ld hl,#2
	add hl,sp
	
	
	push	ix
	ld	ix,#0
	add	ix,sp
	
	;ld a,(_MEMSLOT2)
	;push af

	
	
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ld a,(hl)
	
	
	call _draw_image;_DRAW_IMAGE
	
	
	;pop af
	;LD	BC, #0xbff7
    ;ld (_MEMSLOT2),a
    ;out (c),a
	
	pop ix
	
	ret
__endasm;
}
*/


void show_picture(u8 image,u8 dir,u8 fade)
{
	static u8 i,j;

	if(fade)
	{
		for(i=0;i<4;++i)
		{
			pal_bright(dir?BRIGHT_MID+i:BRIGHT_MID-i);
			for(j=0;j<4;++j) vsync();
		}
	}

	draw_image(0,0,image);
	pal_select(image);
	swap_screen();

	if(fade)
	{
		for(i=0;i<4;++i)
		{
			pal_bright(dir?BRIGHT_MAX-i:BRIGHT_MIN+i);
			for(j=0;j<4;++j) vsync();
		}
	}
}



void main(void)
{
	static u8 i,joy,joyprev,image;

	image=0;
	joyprev=0;

	show_picture(image,0,1);

	while(1)
	{
		vsync(); //for joystick
		i=joystick();
		joy=i^joyprev&i;
		joyprev=i;

		if(joy&JOY_LEFT)
		{
			--image;
			if(image>4) image=4;

			show_picture(image,0,1);
		}

		if(joy&JOY_RIGHT)
		{
			++image;
			if(image>4) image=0;

			show_picture(image,1,1);
		}

		if(joy&JOY_UP)
		{
			--image;
			if(image>4) image=4;

			show_picture(image,0,0);
		}

		if(joy&JOY_DOWN)
		{
			++image;
			if(image>4) image=0;

			show_picture(image,0,0);
		}
	}
}