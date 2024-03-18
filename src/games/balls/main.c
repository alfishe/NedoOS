#include <evo.h>
#include "functions.h"
#include "resources.h"

#define SFX_BUM		0
#define SFX_POCKET	1
#define SFX_BUM2	2
#define SFX_POCKET_MAIN	3
#define SFX_WINPOCKET	4

#define SPRITES_ALL	11 //11 //20 шариков тянет при 130000t, 17 при 100000t с трудом

#define FIRSTBALLVALUE 10 /*начальная цена шара*/
#define CONTINUOUSBALLBONUS 10 /*по столько растёт цена шара после удачного хода*/
#define DOUBLEBALLBONUS 25 /*по столько растёт выигрыш за каждый следующий шар при двойном попадании*/
#define POCKETMAINMALUS 15 /*штраф за потерю битка*/
#define NOHITMALUS 10 /*штраф за непопадание по шару*/
#define WINPOCKETFACTOR 2 /*коэффициент при попадании в лузу winpocket*/


#define WRONGX 64/*0*/ /* для exist==0, чтобы не проверять exist */
#define WRONGY 224/*0*/ /* для exist==0, чтобы не проверять exist */

#define XTYPE u16
#define DXTYPE i16
#define UTYPE u32 /* для dist и SQR(BALLSIZE) */
#define ITYPE i32 /* для p */
#define SHIFTCOORDS 7

#define SCRSHIFTX 16
#define SCRSHIFTY 16
#define LEFTMARGIN (((XTYPE)(LEFT+2))<<SHIFTCOORDS) /*запас на сравнение координат -BALLSIZE в беззнаковых и переполнение x-dx*/
#define RIGHTMARGIN (((XTYPE)(RIGHT-2-ballsize))<<SHIFTCOORDS)
#define TOPMARGIN (((XTYPE)(TOP+2))<<SHIFTCOORDS) /*запас на сравнение координат -BALLSIZE в беззнаковых и переполнение y-dy*/
#define BOTTOMMARGIN (((XTYPE)(BOTTOM-2-ballsize))<<SHIFTCOORDS)
#define RNDLEFTMARGIN (LEFTMARGIN+(16<<SHIFTCOORDS))
#define RNDRIGHTMARGIN (RIGHTMARGIN-(16<<SHIFTCOORDS))
#define RNDTOPMARGIN (TOPMARGIN+(16<<SHIFTCOORDS))
#define RNDBOTTOMMARGIN (BOTTOMMARGIN-(16<<SHIFTCOORDS))

#define CHECKMAXSPEED
#define MAXSPEED ((DXTYPE)(4<<SHIFTCOORDS))

#define ballsize 15
#define sqrhalfballsize (ballsize*ballsize/4)
#define BALLSIZE (ballsize<<SHIFTCOORDS)

#define BRIM 11
#define TOP (32+SCRSHIFTY)
#define BOTTOM (200+SCRSHIFTY)
#define LEFT (0+SCRSHIFTX)
#define RIGHT (320+SCRSHIFTX)
#define MIDX (160+SCRSHIFTX)
#define POCKETSIZE 28/*24*/
#define CORNERSIZE 24
#define CORNERLEFT (LEFT+(CORNERSIZE-BRIM))
#define CORNERRIGHT (RIGHT-(CORNERSIZE-BRIM))
#define CORNERTOP (TOP+(CORNERSIZE-BRIM))
#define CORNERBOTTOM (BOTTOM-(CORNERSIZE-BRIM))
#define TOPY (TOP+BRIM)
#define TOPLEFTMINX (LEFT+CORNERSIZE)
#define TOPLEFTMAXX (MIDX-(POCKETSIZE/2))
#define TOPRIGHTMINX (MIDX+(POCKETSIZE/2))
#define TOPRIGHTMAXX (RIGHT-CORNERSIZE)
#define BOTTOMY (BOTTOM-BRIM)
#define BOTTOMLEFTMINX TOPLEFTMINX
#define BOTTOMLEFTMAXX TOPLEFTMAXX
#define BOTTOMRIGHTMINX TOPRIGHTMINX
#define BOTTOMRIGHTMAXX TOPRIGHTMAXX
#define LEFTX (LEFT+BRIM)
#define LEFTMINY (TOP+CORNERSIZE)
#define LEFTMAXY (BOTTOM-CORNERSIZE)
#define RIGHTX (RIGHT-BRIM)
#define RIGHTMINY LEFTMINY
#define RIGHTMAXY LEFTMAXY


#define MAGNETSIZE 5
#define MAGNETSPEED 20

#define MIDY ((TOPY+BOTTOMY-ballsize)/2)
#define MYX ((MIDX+LEFT)/2)
#define PYRX ((MIDX+RIGHT)/2)
#define PYRXSTEP (ballsize)
#define PYRYSTEP (PYRXSTEP*50/87) /* / (sqrt(3))*/

//XTYPE initial[SPRITES_ALL]={};
/*XTYPE initial[SPRITES_ALL][2]={
{(u32)(MYX            )<<SHIFTCOORDS,(u32)(MIDY           )<<SHIFTCOORDS},
{(u32)(PYRX           )<<SHIFTCOORDS,(u32)(MIDY           )<<SHIFTCOORDS},
{(u32)(PYRX+1*PYRXSTEP)<<SHIFTCOORDS,(u32)(MIDY+1*PYRYSTEP)<<SHIFTCOORDS},
{(u32)(PYRX+1*PYRXSTEP)<<SHIFTCOORDS,(u32)(MIDY-1*PYRYSTEP)<<SHIFTCOORDS},
{(u32)(PYRX+2*PYRXSTEP)<<SHIFTCOORDS,(u32)(MIDY+2*PYRYSTEP)<<SHIFTCOORDS},
{(u32)(PYRX+2*PYRXSTEP)<<SHIFTCOORDS,(u32)(MIDY+0*PYRYSTEP)<<SHIFTCOORDS},
{(u32)(PYRX+2*PYRXSTEP)<<SHIFTCOORDS,(u32)(MIDY-2*PYRYSTEP)<<SHIFTCOORDS},
{(u32)(PYRX+3*PYRXSTEP)<<SHIFTCOORDS,(u32)(MIDY+3*PYRYSTEP)<<SHIFTCOORDS},
{(u32)(PYRX+3*PYRXSTEP)<<SHIFTCOORDS,(u32)(MIDY+1*PYRYSTEP)<<SHIFTCOORDS},
{(u32)(PYRX+3*PYRXSTEP)<<SHIFTCOORDS,(u32)(MIDY-1*PYRYSTEP)<<SHIFTCOORDS},
{(u32)(PYRX+3*PYRXSTEP)<<SHIFTCOORDS,(u32)(MIDY-3*PYRYSTEP)<<SHIFTCOORDS},
};*/

//шарик не должен попадать в трапецию между лузами, но отскок разный в зависимости от стороны, которую он пересёк
//от вертикали: dx=-dxold
//от горизонтали: dy=-dyold
//от диагонали левой верхней или правой нижней лузы: dx=dyold, dy=dxold
//от диагонали правой верхней или левой нижней лузы: dx=-dyold, dy=-dxold
//от угла (сила реакции направлена перпендикулярно, т.е. к центру): как при столкновении шариков

//координаты шарика = xleft,ytop = координаты левого верхнего угла его bounding box плюс SCRSHIFT
//координаты ограничителей тоже плюс SCRSHIFT
//посчитаем x,y (центр), ytop, ybottom, xleft, xright

//можно проверять при флаге в сетке[x,y], там номер ветки проверки

//проверки верхних луз только при ytop<TOPY (каждый вариант исключает все нижестоящие, идут в порядке усложнения):

//пересечение левой части верхней горизонтали: (x>TOPLEFTMINX) && (x<TOPLEFTMAXX) //&& (ytop<TOPY)
//пересечение верхней диагонали левой верхней лузы: (x<=TOPLEFTMINX) && ((y-x-(ballsize*7/10))<(TOP-CORNERLEFT))
//пересечение правой части верхней горизонтали: (x>TOPRIGHTMINX) && (x<TOPRIGHTMAXX) //&& (ytop<TOPY)
//пересечение верхней диагонали правой верхней лузы: (x>=TOPRIGHTMAXX) && ((y+x-(ballsize*7/10))<(TOP+CORNERRIGHT))
//if (y<TOPY) {
//пересечение левой вертикали в центральной лузе: ((TOPLEFTMAXX-xleft)<ballsize) //&& (y<TOPY)
//пересечение правой вертикали в центральной лузе: ((xright-TOPRIGHTMINX)<ballsize) //&& (y<TOPY)
//} else {
//контакт с левым углом центральной лузы: ((sqr(x-TOPLEFTMAXX)+sqr(y-TOPY))<sqrhalfballsize)
//контакт с правым углом центральной лузы: ((sqr(x-TOPRIGHTMINX)+sqr(y-TOPY))<sqrhalfballsize)
//контакт с верхним углом левой верхней лузы: ((sqr(x-TOPLEFTMINX)+sqr(y-TOPY))<sqrhalfballsize)
//контакт с верхним углом правой верхней лузы: ((sqr(x-TOPRIGHTMAXX)+sqr(y-TOPY))<sqrhalfballsize)
//}

//проверки нижних луз только при ybottom>BOTTOMY (каждый вариант исключает все нижестоящие, идут в порядке усложнения):

//пересечение левой части нижней горизонтали: (x>BOTTOMLEFTMINX) && (x<BOTTOMLEFTMAXX) //&& (ybottom>BOTTOMY)
//пересечение нижней диагонали левой нижней лузы: (x<=BOTTOMLEFTMINX) && ((y+x+(ballsize*7/10))>(BOTTOM+CORNERLEFT))
//пересечение правой части нижней горизонтали: (x>BOTTOMRIGHTMINX) && (x<BOTTOMRIGHTMAXX) //&& (ybottom>BOTTOMY)
//пересечение нижней диагонали правой нижней лузы: (x>=BOTTOMRIGHTMAXX) && ((y-x+(ballsize*7/10))>(BOTTOM-CORNERRIGHT))
//if (y>BOTTOMY) {
//пересечение левой вертикали в центральной лузе: ((BOTTOMLEFTMAXX-xleft)<ballsize) //&& (y>BOTTOMY)
//пересечение правой вертикали в центральной лузе: ((xright-BOTTOMRIGHTMINX)<ballsize) //&& (y>BOTTOMY)
//} else {
//контакт с левым углом центральной лузы: ((sqr(x-BOTTOMLEFTMAXX)+sqr(y-BOTTOMY))<sqrhalfballsize)
//контакт с правым углом центральной лузы: ((sqr(x-BOTTOMRIGHTMINX)+sqr(y-BOTTOMY))<sqrhalfballsize)
//контакт с нижним углом левой нижней лузы: ((sqr(x-BOTTOMLEFTMINX)+sqr(y-BOTTOMY))<sqrhalfballsize)
//контакт с нижним углом правой нижней лузы: ((sqr(x-BOTTOMRIGHTMAXX)+sqr(y-BOTTOMY))<sqrhalfballsize)
//}

//проверки левой стороны только при xleft<LEFTX (каждый вариант исключает все нижестоящие, идут в порядке усложнения)

//пересечение левой вертикали: (y>LEFTMINY) && (y<LEFTMAXY) //&& (xleft<LEFTX)
//пересечение нижней диагонали левой верхней лузы: (y<=LEFTMINY) && ((y-x+(ballsize*7/10))>(CORNERTOP-LEFT))
//пересечение верхней диагонали левой нижней лузы: (y>=LEFTMAXY) && ((y+x-(ballsize*7/10))<(CORNERBOTTOM+LEFT))
//контакт с нижним углом левой верхней лузы: ((sqr(x-LEFTX)+sqr(y-LEFTMINY))<sqrhalfballsize)
//контакт с верхним углом левой нижней лузы: ((sqr(x-LEFTX)+sqr(y-LEFTMAXY))<sqrhalfballsize)

//проверки правой стороны только при xright>RIGHTX (каждый вариант исключает все нижестоящие, идут в порядке усложнения)

//пересечение правой вертикали: (y>RIGHTMINY) && (y<RIGHTMAXY) //&& (xright>RIGHTX)
//пересечение нижней диагонали правой верхней лузы: (y<=RIGHTMINY) && ((y+x+(ballsize*7/10))>(CORNERTOP+RIGHT))
//пересечение верхней диагонали правой нижней лузы: (y>=RIGHTMAXY) && ((y-x-(ballsize*7/10))<(CORNERBOTTOM-RIGHT))
//контакт с нижним углом правой верхней лузы: ((sqr(x-RIGHTX)+sqr(y-RIGHTMINY))<sqrhalfballsize)
//контакт с верхним углом правой нижней лузы: ((sqr(x-RIGHTX)+sqr(y-RIGHTMAXY))<sqrhalfballsize)



//структура объекта

struct spriteStruct {
	XTYPE x,y;	//координаты
	DXTYPE dx,dy;	//дельты скорости
	u8 color;
	u8 exist; //0=отсутствует, 1=стоит, 2=едет
	u8 wallcollided;
};

//список объектов

struct spriteStruct spriteList[SPRITES_ALL];

volatile u8 spritezones[SPRITES_ALL*2];

#define ZONESHIFT 4
#define XZONES ((320>>ZONESHIFT)+1)
#define YZONES ((256/*200*/>>ZONESHIFT)+1)
volatile i8 ballsinzone[(YZONES+1)<<8];
volatile u8 slowphase;
volatile XTYPE tmpx,tmpy;
volatile u16 tmpxscr;
volatile u8 xzone,yzone;
volatile u8* spritezonesaddr;
volatile DXTYPE nx,ny,px,py,tempdx,tempdy;
volatile i8 p; //DXTYPE //ITYPE
volatile u8* addr;
volatile XTYPE tmpnewx,tmpnewy;
volatile XTYPE tmpxmin,tmpymin;
volatile DXTYPE dxold,dyold;
volatile XTYPE sqrdy; //UTYPE нужно для квадрата точных координат, а тут неточные

//NU
//u8 collided[SPRITES_ALL][SPRITES_ALL];
//0 -можно проверять столкновение
//>0 - сталкивались, считаем таймаут, текущее столкновение игнорируем

volatile u8 i,j;
volatile XTYPE x,y,xleft,xright,ytop,ybottom;
volatile u8 movingballs,pocketballs,pyramidshot,washit;
volatile u16 ballvalue/*на начало удара*/,bonusballvalue/*бонус, появляется во время удара*/;
volatile u8 winpocket,curpocket; //0 или 1..6
volatile u8 pocketfactor;
static u8 key;
static u8 keys[40];
static u8 joy;

#define MAXPLAYERS 2
static i16 scores[MAXPLAYERS];
static u8 curplayer;

#define ABS(x) (((x)<0)?(-x):(x))
#define sqr(x) ((x)*(x))
#define SQR(x) ((ITYPE)((UTYPE)(x)*(UTYPE)(x)))

static u8 tsqr[256];

#define DOTPRODUCT(x1,y1,x2,y2) ((x1)*(x2)+(y1)*(y2))

//static XTYPE xshow=BOTTOMLEFTMINX,yshow=BOTTOMY;

static u8 output_x,output_y;
static u8 oldoutput_x,oldoutput_y;
static char tnnn[4];//="012";
static char tscore[7];//="012345";
//static char* presskey="PRESS ANY KEY"; //так не работает

u8 pocketcoords[7][2];


unsigned int lsqrt(unsigned long arg){
char count=16;
unsigned long res=0,tmp=0;
	if(arg!=0){ 
		if(!(arg&0xFF000000)){arg<<=8;count-=4;}


		res=1;
		while((tmp<1)&&(count)){
			count--;
			if(arg&0x80000000UL)tmp|=2;
			if(arg&0x40000000UL)tmp|=1;

			arg<<=2;


		};//поиск первой 1-ы
		tmp--;
		for(count;count;count--){
			tmp<<=2;
			res<<=1;

			if(arg&0x80000000UL)tmp|=2;
			if(arg&0x40000000UL)tmp|=1;
			arg<<=2;

			if( tmp>=((res<<1)|1)){
				tmp-=((res<<1)|1);
				res|=1;
			}
			
		}
	}
	return (unsigned int)res;
} 

//вывод одного символа на экран с автоматическим изменением
//позиции вывода, также символ '\n' переводит строку
void put_char(u8 n)
{
	if(n>=' '&&n<='Z') draw_tile(output_x,output_y,n-' ');

	++output_x;

	if(output_x==39||n=='\n')
	{
		output_x=1;
		
		++output_y;
		
		if(output_y==24) output_y=1;
	}
}

//вывод строки символов
void put_str(u8* str)
{
	u8 i;

	while(1)
	{
		i=*str++;

		if(!i) break;

		put_char(i);
	}
}

void prstr(u8 y,u8 x,u8* str)
{
	select_image(IMG_FONT);
	output_x=x;
	output_y=y;
	put_str(str);
}

void prnum(u8 y,u8 x,i16 hiscore)
{
	select_image(IMG_FONT);
	if (hiscore<(i16)0) {
		tscore[0]='-';
		hiscore=-hiscore;
	} else {
		tscore[0]=' ';
	};
	tscore[1]='0'+(hiscore)/10000;
	tscore[2]='0'+(hiscore%10000)/1000;
	tscore[3]='0'+(hiscore%1000)/100;
	tscore[4]='0'+(hiscore%100)/10;
	tscore[5]='0'+(hiscore%10);
	output_x=x;
	output_y=y;
	put_str(tscore);
}

void prnnn(u8 y,u8 x,i16 hiscore)
{
	select_image(IMG_FONT);
	tnnn[0]='0'+(hiscore)/100;
	tnnn[1]='0'+(hiscore%100)/10;
	tnnn[2]='0'+(hiscore%10);
	output_x=x;
	output_y=y;
	put_str(tnnn);
}

void prpower(u8 power)
{
#define POWER_LEN 8
	static u8 y,x;
	static u8 i;
	static u8 tiles[POWER_LEN];
	select_image(IMG_TILES);
	y=0;
	x=curplayer?32:0;
	output_x=x;
	output_y=y;
	for (i=0;i<POWER_LEN;i++) {
	  tiles[i]=((i*8)<power)?15:0;
	}
	tiles[power/8]=8+(power&7);
	if (!power) tiles[0]=0;
	for (i=0;i<POWER_LEN;i++) {
	  draw_tile(output_x++,output_y,tiles[i]+((i>=2)?16:0)+((i>=6)?16:0));
	}
}


void prscores()
{
//todo обновлять только при изменении
	prnum(0,12,scores[0]);
	if (curplayer==0) put_char('*'); else put_char(' ');
	prnum(0,21,scores[1]);
	if (curplayer==1) put_char('*'); else put_char(' ');
	prnnn(2,16,ballvalue);
	put_char('+');
	prnnn(2,21,bonusballvalue);
	//prnnn(3,0,winpocket);
	//prnnn(3,10,curpocket);
	output_x=oldoutput_x;
	output_y=oldoutput_y;
	put_char(' ');
	output_x=pocketcoords[winpocket][0];
	output_y=pocketcoords[winpocket][1];
	oldoutput_x=output_x;
	oldoutput_y=output_y;
	if (winpocket) put_char('*');
}


void draw_sprites() {
                //if (1) {
		i=(SPRITES_ALL-1);
                j=0;
		//for(i=(SPRITES_ALL-1);i!=(u8)(-1);--i) {
		/*
                do {
			if (spriteList[i].exist) {
			//i&3 выбирает один из четырех разноцветных шариков
			//i&4 = фаза сдвига по X

			tmpx=spriteList[i].x;
			tmpxscr=(tmpx>>(SHIFTCOORDS+1)); //>>SHIFTCOORDS компилится со сдвигом
			//j=tmpxscr>>8; //компилится без сдвига
			set_sprite(j++,
					tmpxscr-(SCRSHIFTX>>1),
					(spriteList[i].y>>SHIFTCOORDS)-SCRSHIFTY,
					spriteList[i].color|((tmpx&(1<<SHIFTCOORDS))?16:0));*/
__asm
			ld	a,(#_i+0)
			ld	e,a
00000$: //начало цикла
			//ld	a,(#_i+0)
			//ld	e,a
			ld a,e
			add	a,a
			add	a,a
			add	a,e
			add	a,a
			add	a,e
			ld hl,#_spriteList+9
			add	a,l //#<_spriteList
			ld	l,a
			ld	a,h //#>_spriteList
			adc	a,#0x00
			ld	h,a
			ld a,(hl) //exist
			or a
			jr z,00005$ //конец цикла без восстановления регистров
			push de
			dec hl
			ld c,(hl) //color
			dec hl
			dec hl
			dec hl
			dec hl
			dec hl
			ld a,(hl) //Y
			dec hl
			ld e,(hl) //y
			rl e
			rla
			add	a,#0xF0
			ld d,a //d=(spriteList[i].y>>SHIFTCOORDS)-SCRSHIFTY
			dec hl
			ld a,(hl) //X
			add	a,#0xF8
			ld e,a //e=tmpxscr-(SCRSHIFTX>>1)
			dec hl
			ld a,(hl) //x
			rla
			sbc a,a
			and #0x10
			or	a,c //color
			ld	c,a
			ld	b,#0x00
			push bc //spriteList[i].color|((tmpx&(1<<SHIFTCOORDS))?4:0)
			push de //d=(spriteList[i].y>>SHIFTCOORDS)-SCRSHIFTY //e=tmpxscr-(SCRSHIFTX>>1)
			ld	hl,#_j + 0
			ld	a,(hl)
			inc (hl)
			push	af //j++
			inc	sp
			call	_set_sprite
			pop	af
			pop	af
			inc	sp
			pop de
00005$: //конец цикла без восстановления регистров
			dec e
			jp p,00000$ //начало цикла
__endasm;
			/*}
		}while((--i)!=(u8)(-1));*/
                //}
}



void moveball() {
			
			//движение
#define RESTOREX tmpnewx=tmpx;
#define RESTOREY tmpnewy=tmpy;
#define RESTORECOORDS /*RESTOREX;RESTOREY;*/
			/*movingballs=0;
			slowphase++;
			for(i=0;i<SPRITES_ALL;++i) if (spriteList[i].exist==2) //движется
			{*/
				tmpx=spriteList[i].x;
				tmpy=spriteList[i].y;
				
				tmpnewx=tmpx+spriteList[i].dx;
				tmpnewy=tmpy+spriteList[i].dy;
				if (((tmpnewx>=RIGHTMARGIN)/*&&(spriteList[i].dx>=0)*/)
				|| ((tmpnewx<LEFTMARGIN)/*&&(spriteList[i].dx<0)*/))
				{
					spriteList[i].dx=-spriteList[i].dx;
					//tmpnewx=tmpx+spriteList[i].dx;
					tmpnewx=WRONGX;
					tmpnewy=WRONGY;
					//звук, определить номер лузы, номер шарика и оценить по правилам
						//ищем, в какую лузу мы попали
						if (tmpx<(MYX<<SHIFTCOORDS)) {
							curpocket=(tmpy<(MIDY<<SHIFTCOORDS))?1:4;
						}
						else {
							curpocket=(tmpy<(MIDY<<SHIFTCOORDS))?3:6;
						};
					pocketfactor=1;
					spriteList[i].exist=0;
					if (i!=0) {
						if (curpocket==winpocket) {
							sfx_play(SFX_WINPOCKET,0);
							pocketfactor=WINPOCKETFACTOR;
							winpocket=0;
						} else {
							sfx_play(SFX_POCKET,0);
						}
						scores[curplayer]+=((ballvalue+bonusballvalue)*pocketfactor);
						bonusballvalue+=DOUBLEBALLBONUS;
						pocketballs+=1;
					} else {
						sfx_play(SFX_POCKET_MAIN,0);
						scores[curplayer]-=POCKETMAINMALUS;
					}
					prscores();
				}
				else if (((tmpnewy>=BOTTOMMARGIN)/*&&(spriteList[i].dy>=0)*/)
				|| ((tmpnewy<TOPMARGIN)/*&&(spriteList[i].dy<0)*/))
				{
					spriteList[i].dy=-spriteList[i].dy;
					//tmpnewy=tmpy+spriteList[i].dy;
					tmpnewx=WRONGX;
					tmpnewy=WRONGY;
					//звук, определить номер лузы, номер шарика и оценить по правилам
						//ищем, в какую лузу мы попали
						if (tmpx<(MYX<<SHIFTCOORDS)) {
							curpocket=(tmpy<(MIDY<<SHIFTCOORDS))?1:4;
						}
						else if (tmpx<(PYRX<<SHIFTCOORDS)) {
							curpocket=(tmpy<(MIDY<<SHIFTCOORDS))?2:5;
						}
						else {
							curpocket=(tmpy<(MIDY<<SHIFTCOORDS))?3:6;
						};
					pocketfactor=1;
					spriteList[i].exist=0;
					if (i!=0) {
						if (curpocket==winpocket) {
							sfx_play(SFX_WINPOCKET,0);
							pocketfactor=WINPOCKETFACTOR;
							winpocket=0;
						} else {
							sfx_play(SFX_POCKET,0);
						}
						scores[curplayer]+=((ballvalue+bonusballvalue)*pocketfactor);
						bonusballvalue+=DOUBLEBALLBONUS;
						pocketballs+=1;
					} else {
						sfx_play(SFX_POCKET_MAIN,0);
						scores[curplayer]-=POCKETMAINMALUS;
					}
					prscores();
				}
				else {

			//}
			//торможение и проверка остановки

			//for(i=0;i<SPRITES_ALL;++i)
			//{
				if ((spriteList[i].dx)||(spriteList[i].dy)) {
					movingballs=1;
					if (((slowphase-i)&15)==0) {
						dxold=spriteList[i].dx;
						dyold=spriteList[i].dy;
						if ( (ABS(dxold) < 12)
						  && (ABS(dyold) < 12) ) {
							spriteList[i].dx=0;
							spriteList[i].dy=0;
							spriteList[i].exist=1;
						}
						else if ( (ABS(dxold) < 32)
						  && (ABS(dyold) < 32) ) {
							spriteList[i].dx=dxold*3/4; //округление отрицательных тоже к нулю
							spriteList[i].dy=dyold*3/4; //округление отрицательных тоже к нулю
						}
						else if ( (ABS(dxold) < 100)
						  && (ABS(dyold) < 100) ) {
							spriteList[i].dx=dxold*7/8; //округление отрицательных тоже к нулю
							spriteList[i].dy=dyold*7/8; //округление отрицательных тоже к нулю
						}
						else if ( (ABS(dxold) < 256)
						  && (ABS(dyold) < 256) ) {
							spriteList[i].dx=dxold*15/16; //округление отрицательных тоже к нулю
							spriteList[i].dy=dyold*15/16; //округление отрицательных тоже к нулю
						}
						else {
							spriteList[i].dx=dxold*31/32; //округление отрицательных тоже к нулю
							spriteList[i].dy=dyold*31/32; //округление отрицательных тоже к нулю
						}
					}
				}
			//}

			//определение коллизий
			//for(i=0;i<SPRITES_ALL;++i) {

//шарик не должен попадать в трапецию между лузами, но отскок разный в зависимости от стороны, которую он пересёк
//от вертикали: dx=-dxold
//от горизонтали: dy=-dyold
//от диагонали левой верхней или правой нижней лузы: dx=dyold, dy=dxold
//от диагонали правой верхней или левой нижней лузы: dx=-dyold, dy=-dxold
//от угла (сила реакции направлена перпендикулярно, т.е. к центру): TODO как при столкновении шариков

//координаты шарика = xleft,ytop = координаты левого верхнего угла его bounding box плюс SCRSHIFT
//координаты ограничителей тоже плюс SCRSHIFT
//посчитаем x,y (центр), ytop, ybottom, xleft, xright
				//xleft=(XTYPE)(tmpx+SCRSHIFTX)>>SHIFTCOORDS;
				//xright=xleft+ballsize;
				//x=xleft+(ballsize/2);
				//ytop=(XTYPE)(tmpy+SCRSHIFTY)>>SHIFTCOORDS;
				//ybottom=ytop+ballsize;
				//y=ytop+(ballsize/2);
				__asm
				ld hl,(#_tmpx) //(#_moveballs_tmpx_1_1+0)
				ld bc,#0x0010 //SCRSHIFTX
				add hl,bc
				add hl,hl
				ld l,h
				ld h,b
				rl h
				ld (#_xleft+0),hl
				ex de,hl
				ld hl,(#_tmpy) //(#_moveballs_tmpy_1_1+0)
				add hl,bc //SCRSHIFTY==SCRSHIFTX
				add hl,hl
				ld l,h
				ld h,b
				rl h
				ld (#_ytop+0),hl
				ld c,#0x07 //ballsize/2
				add hl,bc
				ld (#_y+0),hl
				ex de,hl
				add hl,bc
				ld (#_x+0),hl
				inc c //ld c,#0x08 //ballsize-(ballsize/2)
				add hl,bc
				ld (#_xright+0),hl
				ex de,hl
				add hl,bc
				ld (#_ybottom+0),hl
				__endasm;

				dxold=spriteList[i].dx;
				dyold=spriteList[i].dy;

#define WALLCOLLIDED sfx_play(SFX_BUM2,0);
 /*spriteList[i].wallcollided=2;*/
//можно проверять при флаге в сетке[x,y], там номер ветки проверки

//проверки верхних луз только при ytop<TOPY (каждый вариант исключает все нижестоящие, идут в порядке усложнения):
				if (ytop<TOPY) {
//пересечение левой части верхней горизонтали: (x>TOPLEFTMINX) && (x<TOPLEFTMAXX) //&& (ytop<TOPY)
					if ( (x>TOPLEFTMINX) && (x<TOPLEFTMAXX) ) {
						spriteList[i].dy=-dyold;
						//RESTOREY;
						tmpnewy=((XTYPE)TOPY<<SHIFTCOORDS);
						WALLCOLLIDED;
					}
//пересечение верхней диагонали левой верхней лузы: (x<=TOPLEFTMINX) && ((y-x-(ballsize*7/10))<(TOP-CORNERLEFT))
					else if ( (x<=TOPLEFTMINX) ) {
						if ( (y<(x+TOP-CORNERLEFT+(ballsize*7/10))) && (-dyold>-dxold) ) {
							spriteList[i].dx=dyold;
							spriteList[i].dy=dxold;
							RESTORECOORDS;
							WALLCOLLIDED;
						}
					}
//пересечение правой части верхней горизонтали: (x>TOPRIGHTMINX) && (x<TOPRIGHTMAXX) //&& (ytop<TOPY)
					else if ( (x>TOPRIGHTMINX) && (x<TOPRIGHTMAXX) ) {
						spriteList[i].dy=-dyold;
						//RESTOREY;
						tmpnewy=((XTYPE)TOPY<<SHIFTCOORDS);
						WALLCOLLIDED;
					}
//пересечение верхней диагонали правой верхней лузы: (x>=TOPRIGHTMAXX) && ((y+x-(ballsize*7/10))<(TOP+CORNERRIGHT))
					else if ( (x>=TOPRIGHTMAXX) ) {
						if ( ((y+x)<(TOP+CORNERRIGHT+(ballsize*7/10))) && (-dyold>dxold) ) {
							spriteList[i].dx=-dyold;
							spriteList[i].dy=-dxold;
							RESTORECOORDS;
							WALLCOLLIDED;
						}
					}
					else {
//if (y<TOPY) {
						if (y<(TOPY+MAGNETSIZE)) {
								spriteList[i].dy-=MAGNETSPEED;
						}
						if (y<TOPY) {
//пересечение левой вертикали в центральной лузе: ((TOPLEFTMAXX-xleft)<ballsize) //&& (y<TOPY)
							if ((TOPLEFTMAXX-xleft)<ballsize) {
								spriteList[i].dx=-dxold;
								RESTOREX;
								WALLCOLLIDED;
							}
//пересечение правой вертикали в центральной лузе: ((xright-TOPRIGHTMINX)<ballsize) //&& (y<TOPY)
							else if ((xright-TOPRIGHTMINX)<ballsize) {
								spriteList[i].dx=-dxold;
								RESTOREX;
								WALLCOLLIDED;
							}
//} else {
						} else {
						//if(!spriteList[i].wallcollided) {
							sqrdy=sqrhalfballsize-sqr((DXTYPE)y-TOPY);
//контакт с левым углом центральной лузы: ((sqr(x-TOPLEFTMAXX)+sqr(y-TOPY))<sqrhalfballsize)
							if ((x>TOPLEFTMAXX) && ((sqr(x-TOPLEFTMAXX))<sqrdy)) { //x>
								spriteList[i].dx=ABS(dyold); //-dyold
								spriteList[i].dy=ABS(dxold); //-dxold
								RESTORECOORDS;
								WALLCOLLIDED;
							}
//контакт с правым углом центральной лузы: ((sqr(x-TOPRIGHTMINX)+sqr(y-TOPY))<sqrhalfballsize)
							else if ((x<TOPRIGHTMINX) && ((sqr(TOPRIGHTMINX-x))<sqrdy)) { //x<
								spriteList[i].dx=-ABS(dyold); //dyold
								spriteList[i].dy=ABS(dxold);
								RESTORECOORDS;
								WALLCOLLIDED;
							}
//контакт с верхним углом левой верхней лузы: ((sqr(x-TOPLEFTMINX)+sqr(y-TOPY))<sqrhalfballsize)
							else if ((x<TOPLEFTMINX) && ((sqr(TOPLEFTMINX-x))<sqrdy) && (dyold<0)) { //x<
								spriteList[i].dx=dyold;
								spriteList[i].dy=dxold;
								RESTORECOORDS;
								WALLCOLLIDED;
							}
//контакт с верхним углом правой верхней лузы: ((sqr(x-TOPRIGHTMINX)+sqr(y-TOPY))<sqrhalfballsize)
							else if ((x>TOPRIGHTMAXX) && ((sqr(x-TOPRIGHTMAXX))<sqrdy) && (dyold<0)) { //x>
								spriteList[i].dx=-dyold;
								spriteList[i].dy=-dxold;
								RESTORECOORDS;
								WALLCOLLIDED;
							}
//}
						} //else spriteList[i].wallcollided--;
					}
				}

/*
					if ( (y<(x+TOP-CORNERLEFT+(ballsize*7/10))) ) {
						spriteList[i].dx=dyold;
						spriteList[i].dy=dxold;
					}
					if ( ((y+x)<(TOP+CORNERRIGHT+(ballsize*7/10))) ) {
								spriteList[i].color=(spriteList[i].color+1)&3;
						spriteList[i].dx=-dyold;
						spriteList[i].dy=-dxold;
					}
*/

//проверки нижних луз только при ybottom>BOTTOMY (каждый вариант исключает все нижестоящие, идут в порядке усложнения):
				if (ybottom>BOTTOMY) {
//пересечение левой части нижней горизонтали: (x>BOTTOMLEFTMINX) && (x<BOTTOMLEFTMAXX) //&& (ybottom>BOTTOMY)
					if ( (x>BOTTOMLEFTMINX) && (x<BOTTOMLEFTMAXX) ) {
						spriteList[i].dy=-dyold;
						//RESTOREY;
						tmpnewy=((XTYPE)BOTTOMY<<SHIFTCOORDS)-BALLSIZE;
						WALLCOLLIDED;
					}
//пересечение нижней диагонали левой нижней лузы: (x<=BOTTOMLEFTMINX) && ((y+x+(ballsize*7/10))>(BOTTOM+CORNERLEFT))
					else if ( (x<=BOTTOMLEFTMINX) ) {
						if ( ((y+x)>(BOTTOM+CORNERLEFT-(ballsize*7/10))) && (dyold>-dxold) ) {
							spriteList[i].dx=-dyold;
							spriteList[i].dy=-dxold;
							//RESTORECOORDS;
							WALLCOLLIDED;
						}
					}
//пересечение правой части нижней горизонтали: (x>BOTTOMRIGHTMINX) && (x<BOTTOMRIGHTMAXX) //&& (ybottom>BOTTOMY)
					else if ( (x>BOTTOMRIGHTMINX) && (x<BOTTOMRIGHTMAXX) ) {
						spriteList[i].dy=-dyold;
						//RESTOREY;
						tmpnewy=((XTYPE)BOTTOMY<<SHIFTCOORDS)-BALLSIZE;
						WALLCOLLIDED;
					}
//пересечение нижней диагонали правой нижней лузы: (x>=BOTTOMRIGHTMAXX) && ((y-x+(ballsize*7/10))>(BOTTOM-CORNERRIGHT))
					else if ( (x>=BOTTOMRIGHTMAXX) ) {
						if ( (y>(x+BOTTOM-CORNERRIGHT-(ballsize*7/10))) && (dyold>dxold) ) {
							spriteList[i].dx=dyold;
							spriteList[i].dy=dxold;
							//RESTORECOORDS;
							WALLCOLLIDED;
						}
					}
//if (y>BOTTOMY) {
						if (y<(BOTTOMY-MAGNETSIZE)) {
								spriteList[i].dy+=MAGNETSPEED;
						}
						if (y>BOTTOMY) {
//пересечение левой вертикали в центральной лузе: ((BOTTOMLEFTMAXX-xleft)<ballsize) //&& (y>BOTTOMY)
							if ((BOTTOMLEFTMAXX-xleft)<ballsize) { //xleft<
								spriteList[i].dx=-dxold;
								RESTOREX;
								WALLCOLLIDED;
							}
//пересечение правой вертикали в центральной лузе: ((xright-BOTTOMRIGHTMINX)<ballsize) //&& (y>BOTTOMY)
							else if ((xright-BOTTOMRIGHTMINX)<ballsize) { //xright>
								spriteList[i].dx=-dxold;
								RESTOREX;
								WALLCOLLIDED;
							}
//} else {
						} else {
							sqrdy=sqrhalfballsize-sqr(BOTTOMY-(DXTYPE)y);
//контакт с левым углом центральной лузы: ((sqr(x-BOTTOMLEFTMAXX)+sqr(y-BOTTOMY))<sqrhalfballsize)
							if ((x>BOTTOMLEFTMAXX) && ((sqr(x-BOTTOMLEFTMAXX))<sqrdy)) { //x>
								//xshow=dxold;
								//yshow=dyold;
								spriteList[i].dx=ABS(dyold);
								spriteList[i].dy=-ABS(dxold);
								RESTORECOORDS;
								WALLCOLLIDED;
							}
//контакт с правым углом центральной лузы: ((sqr(x-BOTTOMRIGHTMINX)+sqr(y-BOTTOMY))<sqrhalfballsize)
							else if ((x<BOTTOMRIGHTMINX) && ((sqr(BOTTOMRIGHTMINX-x))<sqrdy)) { //x<
								//xshow=x;
								//yshow=y;
								spriteList[i].dx=-ABS(dyold);
								spriteList[i].dy=-ABS(dxold); //-dxold
								RESTORECOORDS;
								WALLCOLLIDED;
							}
//контакт с нижним углом левой нижней лузы: ((sqr(x-BOTTOMLEFTMINX)+sqr(y-BOTTOMY))<sqrhalfballsize)
							else if ((x<BOTTOMLEFTMINX) && ((sqr(BOTTOMLEFTMINX-x))<sqrdy) && (dyold>0)) { //x<
								spriteList[i].dx=-dyold;
								spriteList[i].dy=-dxold;
								//RESTORECOORDS;
								//tmpnewy=((XTYPE)BOTTOMY<<SHIFTCOORDS)-BALLSIZE;
								WALLCOLLIDED;
							}
//контакт с нижним углом правой нижней лузы: ((sqr(x-BOTTOMRIGHTMINX)+sqr(y-BOTTOMY))<sqrhalfballsize)
							else if ((x>BOTTOMRIGHTMAXX) && ((sqr(x-BOTTOMRIGHTMAXX))<sqrdy) && (dyold>0)) { //x>
								spriteList[i].dx=dyold;
								spriteList[i].dy=dxold;
								//RESTORECOORDS;
								//tmpnewy=((XTYPE)BOTTOMY<<SHIFTCOORDS)-BALLSIZE;
								WALLCOLLIDED;
							}
//}
						}
				}

//проверки левой стороны только при xleft<LEFTX (каждый вариант исключает все нижестоящие, идут в порядке усложнения)
				if (xleft<LEFTX) {
//пересечение левой вертикали: (y>LEFTMINY) && (y<LEFTMAXY) //&& (xleft<LEFTX)
					if ( (y>LEFTMINY) && (y<LEFTMAXY) ) {
						spriteList[i].dx=-dxold;
						//RESTOREX;
						tmpnewx=(XTYPE)LEFTX<<SHIFTCOORDS;
						WALLCOLLIDED;
					}
//пересечение нижней диагонали левой верхней лузы: (y<=LEFTMINY) && ((y-x+(ballsize*7/10))>(CORNERTOP-LEFT))
					else if ( (y<=LEFTMINY) ) {
						if ( (y>(x+CORNERTOP-LEFT-(ballsize*7/10))) && (dxold<dyold) ) {
							spriteList[i].dx=dyold;
							spriteList[i].dy=dxold;
							//RESTORECOORDS;
							WALLCOLLIDED;
						}
					}
//пересечение верхней диагонали левой нижней лузы: (y>=LEFTMAXY) && ((y+x-(ballsize*7/10))<(CORNERBOTTOM+LEFT))
					else if ( (y>=LEFTMAXY) ) {
						if ( ((y+x)<(CORNERBOTTOM+LEFT+(ballsize*7/10))) && (dxold<-dyold) ) {
							spriteList[i].dx=-dyold;
							spriteList[i].dy=-dxold;
							//RESTORECOORDS;
							WALLCOLLIDED;
						}
					}
//контакт с нижним углом левой верхней лузы: ((sqr(x-LEFTX)+sqr(y-LEFTMINY))<sqrhalfballsize)
					else if (y<(LEFTMINY+ballsize)) {
							if ((((DXTYPE)sqr((DXTYPE)x-LEFTX)+sqr(LEFTMINY-(DXTYPE)y))<sqrhalfballsize) && (dxold<0)) { //y<
								spriteList[i].dx=-dyold;
								spriteList[i].dy=-dxold;
								RESTORECOORDS;
								WALLCOLLIDED;
							}
					}
//контакт с верхним углом левой нижней лузы: ((sqr(x-LEFTX)+sqr(y-LEFTMAXY))<sqrhalfballsize)
					else if (y>(LEFTMAXY-ballsize)) {
							if ((((DXTYPE)sqr((DXTYPE)x-LEFTX)+sqr((DXTYPE)y-LEFTMAXY))<sqrhalfballsize) && (dxold<0)) { //y>
								spriteList[i].dx=dyold;
								spriteList[i].dy=dxold;
								RESTORECOORDS;
								WALLCOLLIDED;
							}
					}
					else if (x<=(LEFTX+MAGNETSIZE)) {
						spriteList[i].dx-=MAGNETSPEED;
					}
				}

//проверки правой стороны только при xright>RIGHTX (каждый вариант исключает все нижестоящие, идут в порядке усложнения)
				if (xright>RIGHTX) {
//пересечение правой вертикали: (y>RIGHTMINY) && (y<RIGHTMAXY) //&& (xright>RIGHTX)
					if ( (y>RIGHTMINY) && (y<RIGHTMAXY) ) {
						spriteList[i].dx=-dxold;
						//RESTOREX;
						tmpnewx=((XTYPE)RIGHTX<<SHIFTCOORDS)-BALLSIZE;
						WALLCOLLIDED;
					}
//пересечение нижней диагонали правой верхней лузы: (y<=RIGHTMINY) && ((y+x+(ballsize*7/10))>(CORNERTOP+RIGHT))
					else if ( (y<=RIGHTMINY) ) {
						if ( ((y+x)>(CORNERTOP+RIGHT-(ballsize*7/10))) && (dxold>-dyold) ) {
							spriteList[i].dx=-dyold;
							spriteList[i].dy=-dxold;
							//RESTORECOORDS;
							WALLCOLLIDED;
						}
					}
//пересечение верхней диагонали правой нижней лузы: (y>=RIGHTMAXY) && ((y-x-(ballsize*7/10))<(CORNERBOTTOM-RIGHT))
					else if ( (y>=RIGHTMAXY) ) {
						if ( (y<(x+CORNERBOTTOM-RIGHT+(ballsize*7/10))) && (dxold>dyold) ) {
							spriteList[i].dx=dyold;
							spriteList[i].dy=dxold;
							//RESTORECOORDS;
							WALLCOLLIDED;
						}
					}
//контакт с нижним углом правой верхней лузы: ((sqr(x-RIGHTX)+sqr(y-RIGHTMINY))<sqrhalfballsize)
					else if (y<(RIGHTMINY+ballsize)) {
							if ((((DXTYPE)sqr((DXTYPE)x-RIGHTX)+sqr(RIGHTMINY-(DXTYPE)y))<sqrhalfballsize) && (dxold>0)) { //y<
								spriteList[i].dx=dyold;
								spriteList[i].dy=dxold;
								RESTORECOORDS;
								WALLCOLLIDED;
							}
					}
//контакт с верхним углом правой нижней лузы: ((sqr(x-RIGHTX)+sqr(y-RIGHTMAXY))<sqrhalfballsize)
					else if (y>(RIGHTMAXY+ballsize)) {
							if ((((DXTYPE)sqr((DXTYPE)x-RIGHTX)+sqr((DXTYPE)y-RIGHTMAXY))<sqrhalfballsize) && (dxold>0)) { //y>
								spriteList[i].dx=-dyold;
								spriteList[i].dy=-dxold;
								RESTORECOORDS;
								WALLCOLLIDED;
							}
					}
					else if (x>=(RIGHTX-MAGNETSIZE)) {
						spriteList[i].dx+=MAGNETSPEED;
					}
				}
				} //если не в лузе
			spriteList[i].x=tmpnewx;
			spriteList[i].y=tmpnewy;
			//} //exist==2
			/*}*/
}

void uncollideballs() {
	//static u8 xzone,yzone;
//обнуление зон
//идеология такая:
//изначально в зонах -1
//при проверке очередного шарика мы вносим его в зону, и если там уже был шарик, то вылезет флаг. иначе получится 0 в зоне.
//для несуществующих шариков будет -1, но они и в несуществующих зонах
			for(i=0;i<SPRITES_ALL;++i) {
				xzone=spriteList[i].x>>(ZONESHIFT+SHIFTCOORDS);
				yzone=spriteList[i].y>>(ZONESHIFT+SHIFTCOORDS);
				//exist=(spriteList[i].exist);
			//addr=ballsinzone+((u16)yzone<<8)+xzone;
			//( (++(*addr)); (++(*(addr+1))); (++(*(addr+257))); (++(*(addr+256))) );
			__asm
				ld	hl,(_xzone) //(_moveballs_xzone_1_1)
				ld	a,(_yzone) //(_moveballs_yzone_1_1)
				ld	h,a
				ld	bc,#_ballsinzone
				add	hl,bc
				ld a,#-1
				ld (hl),a
				inc	l
				ld (hl),a
				inc	h
				ld (hl),a
				dec	l
				ld (hl),a
			__endasm;
			}
}

void docollide()
{
							if ((spriteList[i].exist)&&(spriteList[j].exist)) { //для надёжности (чтобы мёртвые шарики не оживлялись)
								//импульс, делённый на массу (размерность V, т.к. (nx,xy) будет нормализован)
								//надо умножение 16*16=>32 или 8.8*8.8=>8.8
                                                                //tempdx = (spriteList[i].dx-spriteList[j].dx);
                                                                //tempdy = (spriteList[i].dy-spriteList[j].dy);
								p=DOTPRODUCT((spriteList[i].dx-spriteList[j].dx),(spriteList[i].dy-spriteList[j].dy),nx,ny)>>(4+4);
											///(ITYPE)BALLSIZE; //нельзя UTYPE - почему?
								//if (p>0) p=-p;
								if (p<0) { //импульс не может идти в сторону другого шарика
								//вектор импульса, делённый на массу (размерность V)
								px=(p*nx);
								///(ITYPE)BALLSIZE; //нельзя UTYPE - почему?
								py=(p*ny);
								///(ITYPE)BALLSIZE; //нельзя UTYPE - почему?
								//меняем скорости (размерность V)
								tempdx = spriteList[i].dx-px; //spriteList[i].dx-=px;
								#ifdef CHECKMAXSPEED
								if (tempdx/*spriteList[i].dx*/ >= MAXSPEED) tempdx/*spriteList[i].dx*/ = MAXSPEED;
								if (tempdx/*spriteList[i].dx*/ < -MAXSPEED) tempdx/*spriteList[i].dx*/ = -MAXSPEED;
								#endif
                                                                spriteList[i].dx = tempdx;
								tempdy = spriteList[i].dy-py; //spriteList[i].dy-=py;
								#ifdef CHECKMAXSPEED
								if (tempdy/*spriteList[i].dy*/ >= MAXSPEED) tempdy/*spriteList[i].dy*/ = MAXSPEED;
								if (tempdy/*spriteList[i].dy*/ < -MAXSPEED) tempdy/*spriteList[i].dy*/ = -MAXSPEED;
								#endif
                                                                spriteList[i].dy = tempdy;
								tempdx = spriteList[j].dx+px; //spriteList[j].dx+=px;
								#ifdef CHECKMAXSPEED
								if (tempdx/*spriteList[j].dx*/ >= MAXSPEED) tempdx/*spriteList[j].dx*/ = MAXSPEED;
								if (tempdx/*spriteList[j].dx*/ < -MAXSPEED) tempdx/*spriteList[j].dx*/ = -MAXSPEED;
								#endif
                                                                spriteList[j].dx = tempdx;
								tempdy = spriteList[j].dy+py; //spriteList[j].dy+=py;
								#ifdef CHECKMAXSPEED
								if (tempdy/*spriteList[j].dy*/ >= MAXSPEED) tempdy/*spriteList[j].dy*/ = MAXSPEED;
								if (tempdy/*spriteList[j].dy*/ < -MAXSPEED) tempdy/*spriteList[j].dy*/ = -MAXSPEED;
								#endif
                                                                spriteList[j].dy = tempdy;
//надо чтобы шарики после столкновения не сближались, т.е. dx левого шарика должен быть < dx правого, dy верхнего < dy нижнего

		//spriteList[i].dx=rand16()%(2<<SHIFTCOORDS)-(1<<SHIFTCOORDS); //rand16()&1?-1:1;
		//spriteList[i].dy=rand16()%(2<<SHIFTCOORDS)-(1<<SHIFTCOORDS); //rand16()&1?-1:1;
		//spriteList[j].dx=rand16()%(2<<SHIFTCOORDS)-(1<<SHIFTCOORDS); //rand16()&1?-1:1;
		//spriteList[j].dy=rand16()%(2<<SHIFTCOORDS)-(1<<SHIFTCOORDS); //rand16()&1?-1:1;
								//spriteList[i].color=(spriteList[i].color+1)&3;
								//spriteList[j].color=(spriteList[j].color+1)&3;
								//collided[i][j]=5;
								spriteList[i].exist=2; //движется
								spriteList[j].exist=2; //движется
								washit=1; //был удар
								sfx_play(SFX_BUM,0);
								}
							}
}

//определение столкновений шариков друг с другом
			/*for(i=0;i<SPRITES_ALL;++i) if (spriteList[i].exist)
			{*/

void preparecollideball() {
			tmpx=spriteList[i].x;
			tmpy=spriteList[i].y;
			xzone=tmpx>>(ZONESHIFT+SHIFTCOORDS);
			yzone=tmpy>>(ZONESHIFT+SHIFTCOORDS);
			//spritezones[(i<<1)+1]=(tmpnewx>>(SHIFTCOORDS+1));
			//spritezones[(i<<1)]=(tmpnewy>>(SHIFTCOORDS+1));
			//addr=ballsinzone+((u16)yzone<<8)+xzone;
			//if ( (++(*addr)) + (++(*(addr+1))) + (++(*(addr+257))) + (++(*(addr+256))) ) //помечаем положение и проверяем наложение в зонах
//spritezones содержит пересчитанные x,y (8 bit) для всех шариков
__asm
	ld	a,(#_i+0) //номер шара
	add	a,a
	add	a,#<_spritezones
	ld	l,a
	adc	a,#>_spritezones
	sub	a,l
	ld	h,a
	ld	a,(#_tmpy+1) //(#_moveballs_tmpy_1_1+1)
	ld	(hl),a
	inc	hl
	ld	a,(#_tmpx+1) //(#_moveballs_tmpx_1_1+1)
	ld	(hl),a

//ballsinzone содержит число шариков в каждой клетке 16x16
	ld	hl,(_xzone) //(_moveballs_xzone_1_1)
	ld	a,(_yzone) //(_moveballs_yzone_1_1)
	ld	h,a
	ld	bc,#_ballsinzone
	add	hl,bc
	inc (hl)
	ld	a,(hl)
	inc	l
	inc (hl)
	add	a,(hl)
	inc	h
	inc (hl)
	add	a,(hl)
	dec	l
	inc (hl)
	add	a,(hl)
	//jp	Z,skipinnerloop$
	ld (_xzone),a //(_moveballs_xzone_1_1),a //теперь это число шариков в 4 зонах под шариком
__endasm;
}

void collideball() {
		
			//if (xzone && i)
			//{
				xleft=(tmpx-BALLSIZE)>>(SHIFTCOORDS+1);
				ytop=(tmpy-BALLSIZE)>>(SHIFTCOORDS+1);
//				spritezonesaddr=spritezones+i+i-1; //почему-то тут не работает

				//for(j=i-1; j!=-1; --j)
				j=i-1; //i!=0, так что сравниваем каждую пару [i] и [j] один раз, а не два
//				do
//				/*if (spriteList[j].exist)*/ {
__asm
	ld a,(_xleft)
	ld (#00091$+1),a
	ld c,a
	ld b,#0x10
	ld a,(_ytop)
	ld (#00092$+1),a
	ld de,(_spritezonesaddr) //(_moveballs_spritezonesaddr_1_1)
	ld hl,#_j
00099$: //начало цикла j
					//if(!collided[i][j]) {
//					if ((spriteList[j].x-tmpxmin)<(BALLSIZE<<1)) {
//						if ((spriteList[j].y-tmpymin)<(BALLSIZE<<1)) {
//					if ((u8)((spriteList[j].x>>(SHIFTCOORDS+1))-xleft)<(u8)(ballsize+1)) {
//						if ((u8)((spriteList[j].y>>(SHIFTCOORDS+1))-ytop)<(u8)(ballsize+1)) {

//					if ((u8)(/*(spritezones[(j<<2)])*/(*spritezonesaddr)-xleft)<(u8)(ballsize+1)) {
	ld a,(de)
	dec de
//9999491$: //переменная (+1)
	sub a,c //#0 //(_moveballs_xleft_1_1)
	sub	a,b //#0x10
	jp	nc,00001$ //конец цикла без восстановления регистров
//						if ((u8)(/*(spritezones[(j<<2)+1])*/(*(spritezonesaddr+1))-ytop)<(u8)(ballsize+1)) {
        //ld a,(_ytop)
        //ex de,hl
        //sub a,(hl)
        //ex de,hl
        //neg

	ld a,(de)
00092$: //переменная (+1)
	sub a,#0 //(_moveballs_ytop_1_1)
	sub	a,b //#0x10
	jp	nc,00001$ //конец цикла без восстановления регистров
	push de //spritezonesaddr-1
				//координаты близко - можно считать расстояние по формуле
							//dist=(SQR((ITYPE)(DXTYPE)(spriteList[i].x-spriteList[j].x))+SQR((ITYPE)(DXTYPE)(spriteList[i].y-spriteList[j].y))); //двойное преобразование для нахождения знака, потом расширения знака (расширение, чтобы правильно посчитать квадрат)
							//if (dist < SQR((UTYPE)BALLSIZE)) {
							//if ( (sqr((DXTYPE)(spriteList[i].x-spriteList[j].x)>>SHIFTCOORDS)+sqr((DXTYPE)(spriteList[i].y-spriteList[j].y)>>SHIFTCOORDS)) < sqr(ballsize) ) {
							//if ( ((u16)sqr((DXTYPE)(spriteList[i].x-spriteList[j].x)>>(SHIFTCOORDS+1))) + ((u16)sqr((DXTYPE)(spriteList[i].y-spriteList[j].y)>>(SHIFTCOORDS+1))) < (u16)(sqrhalfballsize) ) { //неточность видна
							//if ((u8)tsqr[(i8)((DXTYPE)(tmpx-spriteList[j].x)>>5)+(128)] + (u8)tsqr[(i8)((DXTYPE)(tmpy-spriteList[j].y)>>5)+(128)] < (u8)(sqr(BALLSIZE>>5)/64) ) { //tsqr[i]=(u8)(((i-128)*(i-128))/64) //(tmpx-spriteList[j].x)>>4 может не поместиться в байт
	ld	a,(hl)//(_j)
		//ld hl,#_moveballs_comparisons_1_1
		//inc (hl)
	ld	e,a
	add	a,a
	add	a,a
	add	a,e
	add	a,a
	add	a,e
	add	a,#<_spriteList
	ld	l,a
	adc	a,#>_spriteList
	sub a,l
	ld	h,a
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc hl
	ex de,hl
	ld hl,(#_tmpx) //(#_moveballs_tmpx_1_1+0)
	or a,a //такая точность не важна?
	sbc hl,bc
	push hl //tmpx-spriteList[j].x
	sra	h
	rr	l
	sra	h
	rr	l
	sra	h
	rr	l
	sra	h
	rr	l
	sra	h
	rr	l
	ex de,hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld hl,(#_tmpy) //(#_moveballs_tmpy_1_1+0)
	or a,a //такая точность не важна?
	sbc hl,bc
	push hl //tmpy-spriteList[j].y
	sra	h
	rr	l
	sra	h
	rr	l
	sra	h
	rr	l
	sra	h
	rr	l
	sra	h
	rr	l
	ld bc,#_tsqr+0x80
	add hl,bc
	ex de,hl
	add hl,bc
	ld a,(de)
	add a,(hl)
	pop bc //tmpy-spriteList[j].y
	pop hl //tmpx-spriteList[j].x
	//jp C,9999500$
	cp a,#0x38 //#0xE1
	jp nc,00010$ //конец цикла с восстановлением регистров
								//столкновение:
								//нормаль между шарами (размерность 1, т.к. подразумевается нормализация)
//								nx=(DXTYPE)(tmpx-spriteList[j].x)/(BALLSIZE>>4);
	push bc
	//push	bc
	ld	de,#0x0078
	//push	de
	//push	hl //tmpx-spriteList[j].x
	call	_DIVSIGNED //_divsint_rrx_s //hl = hl/de
	//pop	af
	//pop	af
	//pop	bc
	ld	(_nx),hl //(_moveballs_nx_1_1 + 0),hl
//								ny=(DXTYPE)(tmpy-spriteList[j].y)/(BALLSIZE>>4);
	pop hl
	//push	bc
	ld	de,#0x0078
	//push	de
	//push	hl //tmpy-spriteList[j].y
	call	_DIVSIGNED //_divsint_rrx_s //hl = hl/de
	//pop	af
	//pop	af
	//pop	bc
	ld	(_ny),hl //(_moveballs_ny_1_1 + 0),hl
        
        call _docollide

00010$: //конец цикла с восстановлением регистров
	pop de //spritezonesaddr-1
	ld	hl,#_j
00091$: //переменная (+1=c)
	ld bc,#0x1000 //(_moveballs_xleft_1_1)
00001$: //конец цикла без восстановления регистров
	//spritezonesaddr-=2;
	dec de
	//}//else collided[i][j]--;
	//ld	hl,#_j
	//inc	(hl)
	//ld	a,(_i)
	//sub	a,(hl)
	//jp	NZ,9999499$
	dec (hl)
	jp	p,00099$ //начало цикла balls in zone
__endasm;
//				} while ((--j) != -1); //j
			//} //ballsinzone
/*
			} //i //sprites
*/
}

void initboard()
{	
	static u8 xzone,yzone;
	//инициализация параметров объектов

	//for(i=0;i<SPRITES_ALL;++i) for(j=0;j<SPRITES_ALL;++j) collided[i][j]=0;

	for(i=0;i<SPRITES_ALL;++i) {
/*
		spriteList[i].x=RNDLEFTMARGIN+(((u32)rand16()<<16)+rand16())%((u32)(RNDRIGHTMARGIN-RNDLEFTMARGIN));
		spriteList[i].y=RNDTOPMARGIN+(((u32)rand16()<<16)+rand16())%((u32)(RNDBOTTOMMARGIN-RNDTOPMARGIN));
*/
		/*spriteList[i].x=(initial[i][0]);
		spriteList[i].y=(initial[i][1]);*/
		//while(spriteList[i].y>=RNDBOTTOMMARGIN){};
		spriteList[i].dx=0;
		spriteList[i].dy=0;
		spriteList[i].color=i?(i&3):4;
		spriteList[i].exist=1;
		spriteList[i].wallcollided=0;
	};

spriteList[0].x = (u32)(MYX            )<<SHIFTCOORDS;spriteList[0].y = (u32)(MIDY           )<<SHIFTCOORDS;
spriteList[1].x = (u32)(PYRX           )<<SHIFTCOORDS;spriteList[1].y = (u32)(MIDY           )<<SHIFTCOORDS;
spriteList[2].x = (u32)(PYRX+1*PYRXSTEP)<<SHIFTCOORDS;spriteList[2].y = (u32)(MIDY+1*PYRYSTEP)<<SHIFTCOORDS;
spriteList[3].x = (u32)(PYRX+1*PYRXSTEP)<<SHIFTCOORDS;spriteList[3].y = (u32)(MIDY-1*PYRYSTEP)<<SHIFTCOORDS;
spriteList[4].x = (u32)(PYRX+2*PYRXSTEP)<<SHIFTCOORDS;spriteList[4].y = (u32)(MIDY+2*PYRYSTEP)<<SHIFTCOORDS;
spriteList[5].x = (u32)(PYRX+2*PYRXSTEP)<<SHIFTCOORDS;spriteList[5].y = (u32)(MIDY+0*PYRYSTEP)<<SHIFTCOORDS;
spriteList[6].x = (u32)(PYRX+2*PYRXSTEP)<<SHIFTCOORDS;spriteList[6].y = (u32)(MIDY-2*PYRYSTEP)<<SHIFTCOORDS;
spriteList[7].x = (u32)(PYRX+3*PYRXSTEP)<<SHIFTCOORDS;spriteList[7].y = (u32)(MIDY+3*PYRYSTEP)<<SHIFTCOORDS;
spriteList[8].x = (u32)(PYRX+3*PYRXSTEP)<<SHIFTCOORDS;spriteList[8].y = (u32)(MIDY+1*PYRYSTEP)<<SHIFTCOORDS;
spriteList[9].x = (u32)(PYRX+3*PYRXSTEP)<<SHIFTCOORDS;spriteList[9].y = (u32)(MIDY-1*PYRYSTEP)<<SHIFTCOORDS;
spriteList[10].x =(u32)(PYRX+3*PYRXSTEP)<<SHIFTCOORDS;spriteList[10].y =(u32)(MIDY-3*PYRYSTEP)<<SHIFTCOORDS;

/*
	for(i=0;i<SPRITES_ALL;++i) {
		spriteList[i].dx=((ITYPE)((((u32)rand16()<<16)+rand16())%((u32)8<<SHIFTCOORDS))-((u32)4<<SHIFTCOORDS))/2; //rand16()&1?-1:1;
		spriteList[i].dy=((ITYPE)((((u32)rand16()<<16)+rand16())%((u32)8<<SHIFTCOORDS))-((u32)4<<SHIFTCOORDS))/2; //rand16()&1?-1:1;
	}
*/
	for(xzone=0;xzone<XZONES;++xzone) {
		for(yzone=0;yzone<YZONES;++yzone) {
			ballsinzone[((u16)yzone<<8)+xzone]=-1;
		}
	};

	curplayer=0;
	for(i=0;i<MAXPLAYERS;++i) {
		scores[i]=0;
	};
}


#define CUR_BRIM (2) /* поле с боков курсора до игрового поля*/
#define CUR_SIZE (7) /* размер курсора */
#define CUR_CENTERSHIFT (3) /* сдвиг центра курсора относительно его координат */
#define CUR_XPERIOD (RIGHT-BRIM-SCRSHIFTX + CUR_BRIM - (LEFT+BRIM-SCRSHIFTX - CUR_BRIM-CUR_SIZE))
#define CUR_YPERIOD (BOTTOM-BRIM-SCRSHIFTY + CUR_BRIM - (TOP+BRIM-SCRSHIFTY - CUR_BRIM-CUR_SIZE))
#define CUR_PERIOD ((CUR_XPERIOD+CUR_YPERIOD)*2)

static u16 cur_x,cur_y;
static u8 plots;

void draw_cursor(void) {
#define SPRITE_CUR 32
#define SPRITE_DOT 34
	static u16 plot_x,plot_y;
	static u8 cur_xscr;
	static u8 k;
		cur_xscr=(cur_x>>1);
		set_sprite(j++,(cur_xscr>(160-8))?cur_xscr-4:cur_xscr,cur_y,SPRITE_CUR|((cur_x&1)?16:0)|((cur_xscr>(160-8))?1:0));
		plots=5;
		for (k=1;k<plots;k++) { //на 1 меньше, т.к. нулевой - это сам шар
			plot_x=((k*((spriteList[0].x>>SHIFTCOORDS)-SCRSHIFTX-CUR_CENTERSHIFT+(ballsize/2)))+((plots-k)*(DXTYPE)cur_x))/plots;
			plot_y=((k*((spriteList[0].y>>SHIFTCOORDS)-SCRSHIFTY+CUR_CENTERSHIFT-(ballsize/2)))+((plots-k)*(DXTYPE)cur_y))/plots;
			cur_xscr=(plot_x>>1);
			set_sprite(j++,(cur_xscr>(160-8))?cur_xscr-4:cur_xscr,plot_y,SPRITE_DOT|((plot_x&1)?16:0)|((cur_xscr>(160-8))?1:0));
		}
}

void main(void)
{
	static DXTYPE vx,vy;
	static XTYPE len;
	static XTYPE tryx,tryy;
	static i16 cur_place,cur_speed;
	static u8 palette[16];
	static u8 curtime,oldtime,logictime,logicframe;
	static u8 ingame;
	static u8 power;
	static i8 powerspeed;
	static u8 k;
	u8* pkeys;

pocketcoords[0][0]=0; pocketcoords[0][1]=4;
pocketcoords[1][0]=0; pocketcoords[1][1]=4;
pocketcoords[2][0]=20;pocketcoords[2][1]=4;
pocketcoords[3][0]=39;pocketcoords[3][1]=4;
pocketcoords[4][0]=0; pocketcoords[4][1]=24;
pocketcoords[5][0]=20;pocketcoords[5][1]=24;
pocketcoords[6][0]=39;pocketcoords[6][1]=24;

	pal_select(PAL_BACK);
	prstr(12,14,"PRESS ANY KEY"/*presskey*/);
	swap_screen();

	while (1) {
		rand16();
		//получение состояния клавиш
		vsync(); //for joystick
		joy=joystick();
		keyboard(keys);
		k=0;
		pkeys=keys;
		for (i=0;i<40;++i) k|=/*keys[i]*/ *pkeys++;
		if (joy || k) break;
	}

	//чёрный экран на время подготовки

	pal_bright(BRIGHT_MIN);

	//инициализация таблицы квадратов
	i=0; do { tsqr[i]=(u8)(((i-128)*(i-128))/64); ++i; } while (i!=0);

	initboard();
	

	//вывод фона на теневой экран

	draw_image(0,0,IMG_BACK);
	pal_select(PAL_BACK);

	//переключение экранов, теперь фон на видимом экране

	swap_screen();

	//запуск спрайтов

	sprites_start();

	//установка нормальной яркости

	pal_bright(BRIGHT_MID);


	pyramidshot=1; //первый удар (разбиваем пирамиду)
	cur_place=CUR_YPERIOD/2; //по часовой стрелке от правого верхнего угла
	ballvalue=FIRSTBALLVALUE;
	winpocket=0;
	curpocket=0;
	//главный цикл
while(1) {

	if ((!winpocket) && (!(rand16()&0x8000))) {
		winpocket=(rand16()%6)+1;
	}

	//scores[0]+=10;
	prscores();
	ingame=0;
	cur_speed=0;

	oldtime = time()-1;
	//управляем
	while(!ingame) {
		//cur_x=LEFT+BRIM-SCRSHIFTX - CUR_BRIM-CUR_SIZE;
		//cur_x=RIGHT-BRIM-SCRSHIFTX + CUR_BRIM;
		//cur_y=100;
		//по часовой стрелке от правого верхнего угла
		if (cur_place<CUR_YPERIOD) { //правая сторона
			cur_x=RIGHT-BRIM-SCRSHIFTX + CUR_BRIM;
			cur_y=(TOP+BRIM-SCRSHIFTY -9 - CUR_BRIM-CUR_SIZE) + cur_place;
		}
		else if (cur_place<(CUR_YPERIOD+CUR_XPERIOD)) { //нижняя сторона (справа налево)
			cur_x=(RIGHT-BRIM-SCRSHIFTX + CUR_BRIM) - (cur_place-CUR_YPERIOD);
			cur_y=BOTTOM-BRIM-SCRSHIFTY -9 + CUR_BRIM;
		}
		else if (cur_place<(CUR_YPERIOD+CUR_XPERIOD+CUR_YPERIOD)) { //левая сторона (снизу вверх)
			cur_x=LEFT+BRIM-SCRSHIFTX - CUR_BRIM-CUR_SIZE;
			cur_y=(BOTTOM-BRIM-SCRSHIFTY -9 + CUR_BRIM) - (cur_place-(CUR_YPERIOD+CUR_XPERIOD));
		}
		else { //верхняя сторона
			cur_x=(LEFT+BRIM-SCRSHIFTX - CUR_BRIM-CUR_SIZE) + (cur_place-(CUR_YPERIOD+CUR_XPERIOD+CUR_YPERIOD));
			cur_y=TOP+BRIM-SCRSHIFTY -9 - CUR_BRIM-CUR_SIZE;
		}

		//заполнение списка спрайтов
		j=0;
		draw_sprites();
		draw_cursor();
		set_sprite(j,0,0,SPRITE_END);
		swap_screen();
		
		//получение состояния клавиш
		keyboard(keys);
		//vsync(); //for joystick
		joy=joystick();

		curtime = time();
		logictime = curtime-oldtime;
		oldtime = curtime;
		for (logicframe = 0 ; logicframe < logictime; logicframe++)
		{

		//if(gameover==0)
		{
			if(joy&JOY_FIRE) { joy=JOY_FIRE; ingame=1;}
			if(joy&JOY_LEFT) { joy=JOY_LEFT; cur_speed++; if (cur_speed<8)cur_speed=8; cur_place-=(cur_speed/8);}
			if(joy&JOY_RIGHT) { joy=JOY_RIGHT; cur_speed++; if (cur_speed<8)cur_speed=8; cur_place+=(cur_speed/8);}
			if(!(joy&(JOY_LEFT|JOY_RIGHT))) cur_speed=0;
			if (cur_place<0) cur_place+=CUR_PERIOD;
			if (cur_place>=CUR_PERIOD) cur_place-=CUR_PERIOD;
			//if(joy&JOY_UP) { joy=JOY_UP; move_up();}
			//if(joy&JOY_DOWN) { joy=JOY_DOWN; move_down();}

			//обновление экрана
			//if(joy==0) put_board();

			//if (check_gameover()!=0) do_gameover();

			//if (win==1) {win++; do_win();};
		}

		}
		
		//if(keys[KEY_R]&KEY_PRESS) new_game();
	}

	//такие же спрайты на втором экране
		j=0;
		draw_sprites();
		//set_sprite(j++,(cur_xscr>(160-8))?cur_xscr-4:cur_xscr,cur_y,SPRITE_CUR|((cur_x&1)?16:0)|((cur_xscr>(160-8))?1:0));
		draw_cursor();
		set_sprite(j,0,0,SPRITE_END);
		swap_screen();

	
	oldtime = time()-1;
	//набираем скорость
	power=0;
	powerspeed=+1;
	do {
		//j=0;
		//draw_sprites();
		//set_sprite(j++,(cur_xscr>(160-8))?cur_xscr-4:cur_xscr,cur_y,SPRITE_CUR|((cur_x&1)?16:0)|((cur_xscr>(160-8))?1:0));
		//set_sprite(j,0,0,SPRITE_END);
		prpower(power);
		//prnum(0,10,power);
		swap_screen();

		//получение состояния клавиш
		keyboard(keys);
		//vsync(); //for joystick
		joy=joystick();

		curtime = time();
		logictime = curtime-oldtime;
		oldtime = curtime;
		for (logicframe = 0 ; logicframe < logictime; logicframe++)
		{
			if(joy&JOY_FIRE) {
				power+=powerspeed;
				if ((power==0)||(power==63)) powerspeed=-powerspeed;
				//power=(power+1)&63;
			} else {
				ingame=2;
			}
		}
	
	}while(ingame!=2);
	i = 0;
//скорость = единичный вектор * power
	vx = (DXTYPE)(cur_x-CUR_CENTERSHIFT+SCRSHIFTX)-(spriteList[i].x>>SHIFTCOORDS);
	vy = (DXTYPE)(cur_y+CUR_CENTERSHIFT+SCRSHIFTY)-(spriteList[i].y>>SHIFTCOORDS);
	//prnum(1,0,vx);
	//prnum(1,10,vy);
	len = lsqrt(SQR(ABS(vx)) + SQR(ABS(vy))); //OK
	//prnum(1,20,len);
	//prnum(2,20,power);
        vx = ((ITYPE)vx * 8) * (ITYPE)power / len;
	vy = ((ITYPE)vy * 8) * (ITYPE)power / len;
	spriteList[0].dx=vx;
	spriteList[0].dy=vy;
	//prnum(2,0,spriteList[0].dx);
	//prnum(2,10,spriteList[0].dy);
	spriteList[i].exist=2; //движется

	//устанавливаем скорости шариков
	for(i=1;i<SPRITES_ALL;++i) {
		spriteList[i].dx=0;
		spriteList[i].dy=0;
	}

	pocketballs=0;
	washit=0;
	bonusballvalue=0; //бонус в текущем ударе (будет расти с каждым забитым в этом ударе шариком)
	oldtime = time()-1;
	//делаем ход
	do {
		//заполнение списка спрайтов
		j=0;
		draw_sprites();
		set_sprite(j,0,0,SPRITE_END);

		//перемещение объектов
		curtime = time();
		logictime = (curtime-oldtime)*2;
		oldtime = curtime;
		for (logicframe = 0 ; logicframe < logictime; logicframe++)
		{
			//comparisons=0;
			movingballs=0;
			slowphase++;
			for(i=0;i<SPRITES_ALL;++i) if (spriteList[i].exist==2) //движется
			{
                                moveball();
                        }
                        uncollideballs();                        
			for(i=0;i<SPRITES_ALL;++i) if (spriteList[i].exist) //стоит или движется
                        {
                                preparecollideball();
                                if (xzone && i) /*в зонах шарика что-то есть и шарик не №0 (чтобы крутить цикл j=i-1...0)*/
                                {
                                        spritezonesaddr=spritezones+i+i-1;
                                        collideball();
                                }
                        }

		} //logicframes
		//spritezonesaddr+=2; //надо для того, чтобы переменная не воспринялась как константа (не помогает)

		//prnum(0,0,comparisons);
		//przones(1,0);
		//prnum(2,0,xshow);
		//prnum(2,10,yshow);
		
		//обновление экрана, спрайты выводятся автоматически
		swap_screen();
	}while(movingballs);
	bonusballvalue=0; //бонус в текущем ударе (будет расти с каждым забитым в этом ударе шариком)
	
	//prnum(0,0,0/*power*/);
	prpower(0/*power*/);

	//счёт
//если удар удачный, цена шарика растёт
	if (pocketballs) {
		sfx_play(SFX_POCKET,0);
		ballvalue+=CONTINUOUSBALLBONUS;
	}

	//если ничего не забил (не на разбивке пирамиды) или потерял биток, то надо сменить игрока (только не два раза, см. ниже)
	if (((pocketballs+pyramidshot)==0)||(!(spriteList[0].exist))) {
		//если потерял биток - штраф (уже посчитан при потере)
		/*if (!(spriteList[0].exist)) {
			sfx_play(SFX_POCKET_MAIN,0);
			scores[curplayer]-=POCKETMAINMALUS;
		}*/
		//если не ударил другой шар - штраф
		if (!washit) {
			sfx_play(SFX_POCKET_MAIN,0);
			scores[curplayer]-=NOHITMALUS;
		}
		curplayer++; if (curplayer>=MAXPLAYERS) curplayer=0;
		ballvalue=FIRSTBALLVALUE; //сбрасываем цену шарика
	}

	prscores();

	//если биток потерян, ставим его снова
	if (!(spriteList[0].exist))
	{
		//curplayer++; if (curplayer>=MAXPLAYERS) curplayer=0;
		spriteList[0].exist=1;
		tryx=(LEFT+64)<<SHIFTCOORDS;
		tryy=((TOP+(BOTTOM-ballsize))/2)<<SHIFTCOORDS;
		do {
			ingame=0;
			for (i=1;i<SPRITES_ALL;++i) if(spriteList[i].exist) {
				if( ((spriteList[i].x-(tryx-BALLSIZE))<(BALLSIZE*2))
				 && ((spriteList[i].y-(tryy-BALLSIZE))<(BALLSIZE*2)) ) ingame=1; //пересечение
			}
			if (ingame) { //пересечение - пробуем другие координаты
				tryy+=(16<<SHIFTCOORDS);
				if (tryy > (((TOP+(BOTTOM-ballsize))/2+50)<<SHIFTCOORDS) ) {
					tryy=((TOP+(BOTTOM-ballsize))/2-50)<<SHIFTCOORDS;
					tryx+=(16<<SHIFTCOORDS);
				}
			}
		} while (ingame!=0);
		spriteList[0].x=tryx;
		spriteList[0].y=tryy;
	}
	pyramidshot=0;
	
}
}