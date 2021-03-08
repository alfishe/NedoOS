//этот пример отображает движущиес€ спрайты на фоне изображени€


#include <evo.h>
#include "resources.h"



//структура объекта

struct spriteStruct {
	i16 x,y;	//координаты
	i16 dx,dy;	//дельты скорости
};

//список объектов

#define SPRITES_ALL	22	//в этом примере столько спрайтов успевает отрисоватьс€ за кадр

struct spriteStruct spriteList[SPRITES_ALL];



void main(void)
{
	static u8 i,t;
	static u8 palette[16];
	static u8 keys[40];
        static u32 oldtime,curtime;
	static u16 y;

	//чЄрный экран на врем€ подготовки

	pal_bright(BRIGHT_MIN);

	//инициализаци€ параметров объектов

	for(i=0;i<SPRITES_ALL;++i)
	{
		spriteList[i].x=1+rand16()%(160-8-2);
		spriteList[i].y=1+rand16()%(200-16-2);
		spriteList[i].dx=0;
		spriteList[i].dy=0;
		spriteList[i].dx=rand16()&1?-1:1;
		//spriteList[i].dy=rand16()&1?-1:1;
	}

	//вывод фона на теневой экран

	draw_image(0,0,IMG_BACK);
	draw_image(1,10,IMG_BALLS/*IMG_BACK*/);

	select_image(IMG_FONT);
	draw_tile(1,2  ,'A'-32);


	//переключение экранов, теперь фон на видимом экране

	swap_screen();

	//запуск спрайтов

	sprites_start();

	//установка палитры, она собираетс€ из двух разных палитр
	//цвета 0..5 дл€ фона, цвета 6..15 дл€ спрайтов

	pal_copy(PAL_BACK,palette);

	for(i=0;i<16;++i) pal_col(i,palette[i]);

	//установка нормальной €ркости

	pal_bright(BRIGHT_MID);

        music_play(0);

        oldtime = time();

	//главный цикл

	while(1)
	{
		//перемещение объектов и заполнение списка спрайтов

		for(i=0;i<SPRITES_ALL;++i)
		{
			//i&3 выбирает один из четырех разноцветных шариков
                        //y = spriteList[i].y;
			set_sprite(i,spriteList[i].x,spriteList[i].y,i&3);
                }
		//обновление экрана, спрайты вывод€тс€ автоматически
		swap_screen();

                curtime = time();
                
                for (t=0;t<(u8)(curtime-oldtime)&0xff;++t) { //logic loop

                
		for(i=0;i<SPRITES_ALL;++i)
		{
			if(spriteList[i].x==160-8 ||spriteList[i].x==0) {spriteList[i].dx=-spriteList[i].dx; 	        sfx_play(SFX_APSTENU,-3);}
			if(spriteList[i].y==200-16||spriteList[i].y==0) {spriteList[i].dy=-spriteList[i].dy; 	        sfx_play(SFX_APSTENU,-3);}

			spriteList[i].x+=spriteList[i].dx;
			//spriteList[i].y+=spriteList[i].dy;
                        //spriteList[i].y = 100;
		}
/*
		//получение состо€ни€ клавиш
		keyboard(keys);
		if(keys[KEY_O]&KEY_DOWN) spriteList[0].x-=1;
		if(keys[KEY_P]&KEY_DOWN) spriteList[0].x+=1;
		if(keys[KEY_Q]&KEY_DOWN) spriteList[0].y-=1;
		if(keys[KEY_A]&KEY_DOWN) spriteList[0].y+=1;
		if(keys[KEY_SPACE]&KEY_PRESS) {
                        for(i=1;i<SPRITES_ALL;++i)
                        {
#define INRANGE(x, range) (((x)>(-range))&&((x)<(range)))
                               if (INRANGE(spriteList[i].x-spriteList[0].x, 5)&&INRANGE(spriteList[i].y-spriteList[0].y, 10)) {
                                        sfx_play(SFX_FIRE,8);
                                        spriteList[i].dx=rand16()&1?-1:1;
                                        spriteList[i].dy=rand16()&1?-1:1;
                               }
                        }
                }
*/
                } //logic loop

                oldtime = curtime;
                
	}
}