#ifndef FONT_C
#define FONT_C

#include "evo.h"
#include "resources.h"

static u8 text_x;
static u8 text_y;
static u8 left_pad = 0;
static u8 right_pad = 40;

static u8 strlen(u8 *s)
{
	u8 c;

	for (c = 0; s[c] != 0; c++)
		;

	return c;
}

static void swap(u8 *x, u8 *y)
{
	u8 t = *x;
	*x = *y;
	*y = t;
}

void put_char(u8 c)
{
	//__asm 
		//di
	//__endasm;

	if (c >= ' ')
	{
		draw_tile_g256(text_x, text_y, c - ' ');
	}

	text_x++;

	if (text_x == right_pad || c == '\n')
	{
		text_x = left_pad;
		text_y++;

		if (text_y == 25/*30*/)
			text_y = 0;
	}
	//__asm 
		//ei
	//__endasm;
}

void put_num(u16 num)
{
	u8 i = 0;
	u8 buffer[] = {'0', '0', '0', '0', '0', '0'};
	u8 j = sizeof(buffer) - 1;
	
	while (num)
	{
		u8 r = num % 10;
		buffer[i++] = r + '0';
		num /= 10;
	}

	i = 0;

	while (i < j)
		swap(&buffer[i++], &buffer[j--]);

	for (i = 0; i < sizeof(buffer); i++)
		put_char(buffer[i]);
}

void put_str(u8 *str)
{
	u8 i;
	while (1)
	{
		i = *str++;
		if (!i)
			break;
		put_char(i);
	}
}

void init_text()
{
pal_bright(BRIGHT_MIN);
vsync();
//sprites_stop();
set_sprite(0,0,0,-1);
	unpack_pal256(PAL256_FONT, 0);
	select_image(IMG256_FONT);
	clear_screen(0);
	scroll(0, 0);
	swap_screen();
set_sprite(0,0,0,-1);
	clear_screen(0);
	swap_screen();
//clear_screen(0);
//swap_screen();
	pal_bright(BRIGHT_MID);
	text_x = 0;
	text_y = 0;
}

#endif