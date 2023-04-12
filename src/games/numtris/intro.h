#ifndef __INTRO
#define __INTRO

void quit()
{
__asm
	jp _EXIT
__endasm;
}

void PressStart(u8 y)
{
	u32 n=time();
	sfx_play(SFX_SPACE,8);
	while (1)
	{
		vsync();
		
		if(joystick()&JOY_FIRE) return;
		
		if (n+25>time()) // мигающий курсор
		{
			draw_image(15,y,IMG_PRESSSPACE);
			swap_screen();
		}
		else if (n+50>time())
		{
			draw_image(15,y,IMG_PRESSSPACE0);
			swap_screen();
		}
		else
		{
			n=time();
			sfx_play(SFX_SPACE,8);
		}
	
	}
}

void new_exit()
{
	u8 keys[40];
	u32 n=time();
	sfx_play(SFX_SPACE,8);
	while (1)
	{
		vsync();
		
		if(joystick()&JOY_FIRE) return;
		
		keyboard(keys);
		if(keys[KEY_Q]&KEY_PRESS) quit();

		if (n+25>time()) // мигающий курсор
		{
			draw_image(8,22,IMG_SPACE_Q1);
			swap_screen();
		}
		else if (n+50>time())
		{
			draw_image(8,22,IMG_SPACE_Q0);
			swap_screen();
		}
		else
		{
			n=time();
			sfx_play(SFX_SPACE,8);
		}
	
	}
}

void Intro()
{
	u32 n=time();
	
	//черный экран на время подготовки
	pal_bright(BRIGHT_MIN);

	//установка палитры
	pal_select(PAL_BOX);
	
	//очистка теневого экрана нужным цветом 0..15
	border(0);
	clear_screen(0);
	
	//установка нормальной яркости
	pal_bright(BRIGHT_MID);
	
	//вывод фона на теневой экран
	draw_image(0,0,IMG_INTRO);
	swap_screen();
	draw_image(0,0,IMG_INTRO);
	swap_screen();

	PressStart(20);

}

void Bright()
{
	i8 k;
	for (k=BRIGHT_MID;k>=BRIGHT_MIN;k--)
	{
		pal_bright(k);
		delay(5);
	}
	clear_screen(0);
	swap_screen();
}

#endif