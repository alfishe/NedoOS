#include <evo.h>
#include "resources.h"

#define lcor 8
#define ucor 1
#define score_y 3 //2
#define score_x 33 //1
#define hiscore_y 8 //2
#define hiscore_x 33
#define n31 31
#define n32 32
#define nbig 96 //128
#define nsmall 160
#define wintile 10 //5 for "64", 10 for "2048"

//текущие координаты вывода текста

static u8 key;
static u8 keys[40];
static u8 output_x,output_xt;
static u8 output_y,output_yt;
static u8 tile;
static u8 t_tile;
static u16 output_tile;
static u8 board[4][4]; //+(n*32) = new tile
static u8 oldboard[4][4];
static u8 screenboard[4][4];
static u8 oldscreenboard[4][4];
static u32 score,screenscore,oldscreenscore;
static u32 hiscore,screenhiscore,oldscreenhiscore;
static char i,j;
static u8 joy;
static u8 gameover;
static u8 win; //increases at each wintile
static u8 nmoves;
static u8 t;

static char tscore[7]="012345";

const u32 tilescore[]={
	2,4,8,16,32,64,
	128,256,512,1024,2048,4096,8192,16384,32768ul,65536ul,131072ul,262144ul
};


//вывод одного символа на экран с автоматическим изменением
//позиции вывода, также символ '\n' переводит строку
void put_char(u8 n)
{
	if(n>=' '&&n<='Z')
	{
		draw_tile(output_x,output_y,n-' ');
		draw_tile(output_x,output_y+1,n-' '+64);
	}

	++output_x;

	if(output_x==40||n=='\n')
	{
		output_x=1;
		
		++output_y;
		
		if(output_y==24) output_y=1;
	}
}

void put_char_key(u8 n)
{
	if(n>=' '&&n<='Z')
	{
		draw_tile_key(output_x,output_y,n-' ');
		draw_tile_key(output_x,output_y+1,n-' '+64);
	}

	++output_x;

	if(output_x==40||n=='\n')
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

void put_str_key(u8* str)
{
	u8 i;

	while(1)
	{
		i=*str++;

		if(!i) break;

		put_char_key(i);
	}
}



void init_screen_board()
{
char i,j;
for(i=0;i<4;++i)
{
	for(j=0;j<4;++j)
	{
		screenboard[i][j]=255;
		oldscreenboard[i][j]=30;
	}
}
}

void init_board()
{
char i,j;
for(i=0;i<4;++i)
{
	for(j=0;j<4;++j)
	{
		board[i][j]=0;
	}
}
init_screen_board();
}

u8 spare_squares()
{
char i,j;
u8 nsq;
nsq=0;
for(i=0;i<4;++i)
	for(j=0;j<4;++j)
		if (board[i][j]==0)
		++nsq;
return nsq;
}

void add_rnd()
{
u8 nsq;
//find number of spare squares
//find rnd
nsq=rand16()%spare_squares();
//put tile 2 or 4 in random square
for(i=0;i<4;++i)
	for(j=0;j<4;++j)
		if (board[i][j]==0)
		{
			if (nsq==0) board[i][j]=(rand16()%10)?1+nsmall:2+nsmall;
			--nsq;
		}
}

void put_tile()
{
	t_tile=0;
	if(tile&0xe0)
	{
		if(tile>=nsmall) t_tile=16;
		else t_tile=8;
	}
	tile=tile&n31;
	output_yt=output_y;
	for(i=0;i<6;++i)
	{
		output_tile=((u16)tile<<8) | t_tile;
		output_xt=output_x;
		//for(j=0;j<6;++j)
		{
			//draw_tile(output_xt++,output_y,output_tile);
			//output_tile++;
			__asm
			ld	hl,(_output_tile)
			push	hl
			ld	a,(_output_yt)
			ld	b,a
			ld	hl,#_output_xt
			ld	c,(hl)
			inc	(hl)
			push	bc
			call	_draw_tile
			pop	af
			pop	af
			ld	hl,#_output_tile
			inc	(hl)
			ld	hl,(_output_tile)
			push	hl
			ld	a,(_output_yt)
			ld	b,a
			ld	hl,#_output_xt
			ld	c,(hl)
			inc	(hl)
			push	bc
			call	_draw_tile
			pop	af
			pop	af
			ld	hl,#_output_tile
			inc	(hl)
			ld	hl,(_output_tile)
			push	hl
			ld	a,(_output_yt)
			ld	b,a
			ld	hl,#_output_xt
			ld	c,(hl)
			inc	(hl)
			push	bc
			call	_draw_tile
			pop	af
			pop	af
			ld	hl,#_output_tile
			inc	(hl)
			ld	hl,(_output_tile)
			push	hl
			ld	a,(_output_yt)
			ld	b,a
			ld	hl,#_output_xt
			ld	c,(hl)
			inc	(hl)
			push	bc
			call	_draw_tile
			pop	af
			pop	af
			ld	hl,#_output_tile
			inc	(hl)
			ld	hl,(_output_tile)
			push	hl
			ld	a,(_output_yt)
			ld	b,a
			ld	hl,#_output_xt
			ld	c,(hl)
			inc	(hl)
			push	bc
			call	_draw_tile
			pop	af
			pop	af
			ld	hl,#_output_tile
			inc	(hl)
			ld	hl,(_output_tile)
			push	hl
			ld	a,(_output_yt)
			ld	b,a
			ld	hl,#_output_xt
			ld	c,(hl)
			//inc	(hl)
			push	bc
			call	_draw_tile
			pop	af
			pop	af
			//ld	hl,#_output_tile
			//inc	(hl)
			__endasm;
		};
		++output_yt;
		t_tile+=32;
	}
}


void clear_anim()
{
board[0][0]&=n31;
board[0][1]&=n31;
board[0][2]&=n31;
board[0][3]&=n31;
board[1][0]&=n31;
board[1][1]&=n31;
board[1][2]&=n31;
board[1][3]&=n31;
board[2][0]&=n31;
board[2][1]&=n31;
board[2][2]&=n31;
board[2][3]&=n31;
board[3][0]&=n31;
board[3][1]&=n31;
board[3][2]&=n31;
board[3][3]&=n31;
}

void put_board()
{
select_image(IMG_TILES2);
pal_select(PAL_TILES2);
output_y=ucor+ 0;
tile=board[0][0]; if (tile!=oldscreenboard[0][0]) {output_x=lcor+ 0; put_tile();};
tile=board[0][1]; if (tile!=oldscreenboard[0][1]) {output_x=lcor+ 6; put_tile();};
tile=board[0][2]; if (tile!=oldscreenboard[0][2]) {output_x=lcor+12; put_tile();};
tile=board[0][3]; if (tile!=oldscreenboard[0][3]) {output_x=lcor+18; put_tile();};
output_y=ucor+ 6;
tile=board[1][0]; if (tile!=oldscreenboard[1][0]) {output_x=lcor+ 0; put_tile();};
tile=board[1][1]; if (tile!=oldscreenboard[1][1]) {output_x=lcor+ 6; put_tile();};
tile=board[1][2]; if (tile!=oldscreenboard[1][2]) {output_x=lcor+12; put_tile();};
tile=board[1][3]; if (tile!=oldscreenboard[1][3]) {output_x=lcor+18; put_tile();};
output_y=ucor+ 12;
tile=board[2][0]; if (tile!=oldscreenboard[2][0]) {output_x=lcor+ 0; put_tile();};
tile=board[2][1]; if (tile!=oldscreenboard[2][1]) {output_x=lcor+ 6; put_tile();};
tile=board[2][2]; if (tile!=oldscreenboard[2][2]) {output_x=lcor+12; put_tile();};
tile=board[2][3]; if (tile!=oldscreenboard[2][3]) {output_x=lcor+18; put_tile();};
output_y=ucor+ 18;
tile=board[3][0]; if (tile!=oldscreenboard[3][0]) {output_x=lcor+ 0; put_tile();};
tile=board[3][1]; if (tile!=oldscreenboard[3][1]) {output_x=lcor+ 6; put_tile();};
tile=board[3][2]; if (tile!=oldscreenboard[3][2]) {output_x=lcor+12; put_tile();};
tile=board[3][3]; if (tile!=oldscreenboard[3][3]) {output_x=lcor+18; put_tile();};
memcpy(oldscreenboard,screenboard,16);
memcpy(screenboard,board,16);
//clear_anim();
for(i=0;i<4;++i)
{
	for(j=0;j<4;++j)
	{
		t=board[i][j];
		if(t&0xe0)
		{
			if(t>=nsmall) board[i][j]=t&31;
			else board[i][j]-=n32;
		}
	}
}
if(score!=oldscreenscore)
{
	select_image(IMG_FONT);
	tscore[0]='0'+score/100000;
	tscore[1]='0'+(score%100000)/10000;
	tscore[2]='0'+(score%10000)/1000;
	tscore[3]='0'+(score%1000)/100;
	tscore[4]='0'+(score%100)/10;
	tscore[5]='0'+(score%10);
	output_x=score_x;
	output_y=score_y;
	put_str(tscore);
	oldscreenscore=screenscore;
	screenscore=score;
}
if(hiscore!=oldscreenhiscore)
{
	select_image(IMG_FONT);
	tscore[0]='0'+hiscore/100000;
	tscore[1]='0'+(hiscore%100000)/10000;
	tscore[2]='0'+(hiscore%10000)/1000;
	tscore[3]='0'+(hiscore%1000)/100;
	tscore[4]='0'+(hiscore%100)/10;
	tscore[5]='0'+(hiscore%10);
	output_x=hiscore_x;
	output_y=hiscore_y;
	put_str(tscore);
	oldscreenhiscore=screenhiscore;
	screenhiscore=hiscore;
}
swap_screen();
}

void store_oldboard()
{
memcpy(oldboard,board,16);
//for(i=0;i<4;++i)
//	for(j=0;j<4;++j)
//		oldboard[i][j]=board[i][j];
}

//returns !=0 if comething changed
u8 compare_boards()
{
//t=0;
//for(i=0;i<4;++i)
//	for(j=0;j<4;++j)
//		if((board[i][j]&31)!=(oldboard[i][j]&31))
//		++nsq;
__asm //max tile=15, 4x4 times never overflow
	ld	c,#31
	ld	hl,#_board
	ld	de,#_oldboard
	ld	a,(de) ;0
	xor	(hl)
	and	c
	//add	a,b
	ld	b,a
	inc	hl
	inc	de
	ld	a,(de)
	xor	(hl)
	and	c
	add	a,b
	ld	b,a
	inc	hl
	inc	de
	ld	a,(de)
	xor	(hl)
	and	c
	add	a,b
	ld	b,a
	inc	hl
	inc	de
	ld	a,(de)
	xor	(hl)
	and	c
	add	a,b
	ld	b,a
	inc	hl
	inc	de
	ld	a,(de) ;4
	xor	(hl)
	and	c
	add	a,b
	ld	b,a
	inc	hl
	inc	de
	ld	a,(de)
	xor	(hl)
	and	c
	add	a,b
	ld	b,a
	inc	hl
	inc	de
	ld	a,(de)
	xor	(hl)
	and	c
	add	a,b
	ld	b,a
	inc	hl
	inc	de
	ld	a,(de)
	xor	(hl)
	and	c
	add	a,b
	ld	b,a
	inc	hl
	inc	de
	ld	a,(de) ;8
	xor	(hl)
	and	c
	add	a,b
	ld	b,a
	inc	hl
	inc	de
	ld	a,(de)
	xor	(hl)
	and	c
	add	a,b
	ld	b,a
	inc	hl
	inc	de
	ld	a,(de)
	xor	(hl)
	and	c
	add	a,b
	ld	b,a
	inc	hl
	inc	de
	ld	a,(de)
	xor	(hl)
	and	c
	add	a,b
	ld	b,a
	inc	hl
	inc	de
	ld	a,(de) ;12
	xor	(hl)
	and	c
	add	a,b
	ld	b,a
	inc	hl
	inc	de
	ld	a,(de)
	xor	(hl)
	and	c
	add	a,b
	ld	b,a
	inc	hl
	inc	de
	ld	a,(de)
	xor	(hl)
	and	c
	add	a,b
	ld	b,a
	inc	hl
	inc	de
	ld	a,(de)
	xor	(hl)
	and	c
	add	a,b
	ld	b,a
	//inc	hl
	//inc	de
	ld	hl,#_t
	ld	(hl),b
__endasm;
return t;
}

void move_end()
{
	if (score>hiscore) hiscore=score;
	//add tile
	add_rnd();
	put_board();
	put_board();
	do {
		vsync();
	} while(joystick()&joy); //for joystick
}


void move_left_move()
{
for(i=0;i<4;++i)
	for(j=0;j<3;++j)
		if(board[i][j]==0)
		{
			board[i][j]=board[i][j+1];
			board[i][j+1]=0;
		};
}

void move_right_move()
{
for(i=0;i<4;++i)
	for(j=3;j>0;--j)
		if(board[i][j]==0)
		{
			board[i][j]=board[i][j-1];
			board[i][j-1]=0;
		};
}

void move_up_move()
{
for(i=0;i<4;++i)
	for(j=0;j<3;++j)
		if(board[j][i]==0)
		{
			board[j][i]=board[j+1][i];
			board[j+1][i]=0;
		};
}

void move_down_move()
{
for(i=0;i<4;++i)
	for(j=3;j>0;--j)
		if(board[j][i]==0)
		{
			board[j][i]=board[j-1][i];
			board[j-1][i]=0;
		};
}

u8 compare_boards_put_board()
{
u8 nsq;
	nsq=compare_boards();
	if(nsq)
	{
		put_board();
		nmoves++;
	}
return nsq;
}

void move_left()
{
char i,j;
u8 dest;
u8 t;
nmoves=0;
clear_anim();
//move everything to the leftmost position
do {
	store_oldboard();
	move_left_move();
} while (compare_boards_put_board()); //nmoves++
//join tiles from the left
store_oldboard();
for(i=0;i<4;++i)
{
	dest=0;
	for(j=0;j<3;++j)
	{
		t=board[i][j];
		if(t&&(board[i][j+1]==t))
		{
			board[i][j]+=nbig+1;
			board[i][j+1]=0;
			score+=tilescore[t&n31];
			if((t&n31)==wintile)win++;
		};
	}
}
compare_boards_put_board(); //nmoves++
//move everything to the leftmost position
do {
	store_oldboard();
	move_left_move();
} while (compare_boards_put_board()); //nmoves++
if(nmoves) move_end();
}

void move_right()
{
char i,j;
u8 dest;
u8 t;
nmoves=0;
clear_anim();
//move everything to the rightmost position
do {
	store_oldboard();
	move_right_move();
} while (compare_boards_put_board()); //nmoves++
//join tiles from the right
store_oldboard();
for(i=0;i<4;++i)
{
	dest=0;
	for(j=3;j>0;--j)
	{
		t=board[i][j];
		if(t&&(board[i][j-1]==t))
		{
			board[i][j]+=nbig+1;
			board[i][j-1]=0;
			score+=tilescore[t&n31];
			if((t&n31)==wintile)win++;
		};
	}
}
compare_boards_put_board(); //nmoves++
//move everything to the rightmost position
do {
	store_oldboard();
	move_right_move();
} while (compare_boards_put_board()); //nmoves++
if(nmoves) move_end();
}

void move_up()
{
char i,j;
u8 dest;
u8 t;
nmoves=0;
clear_anim();
//move everything to the topmost position
do {
	store_oldboard();
	move_up_move();
} while (compare_boards_put_board()); //nmoves++
//join tiles from the top
store_oldboard();
for(i=0;i<4;++i)
{
	dest=0;
	for(j=0;j<3;++j)
	{
		t=board[j][i];
		if(t&&(board[j+1][i]==t))
		{
			board[j][i]+=nbig+1;
			board[j+1][i]=0;
			score+=tilescore[t&n31];
			if((t&n31)==wintile)win++;
		};
	}
}
compare_boards_put_board(); //nmoves++
//move everything to the topmost position
do {
	store_oldboard();
	move_up_move();
} while (compare_boards_put_board()); //nmoves++
if(nmoves) move_end();
}

void move_down()
{
char i,j;
u8 dest;
u8 t;
nmoves=0;
clear_anim();
//move everything to the bottommost position
do {
	store_oldboard();
	move_down_move();
} while (compare_boards_put_board()); //nmoves++
//join tiles from the bottom
store_oldboard();
for(i=0;i<4;++i)
{
	dest=0;
	for(j=3;j>0;--j)
	{
		t=board[j][i];
		if(t&&(board[j-1][i]==t))
		{
			board[j][i]+=nbig+1;
			board[j-1][i]=0;
			score+=tilescore[t&n31];
			if((t&n31)==wintile)win++;
		};
	}
}
compare_boards_put_board(); //nmoves++
//move everything to the bottommost position
do {
	store_oldboard();
	move_down_move();
} while (compare_boards_put_board()); //nmoves++
if(nmoves) move_end();
}


u8 hor_moves()
{
u8 nsq;
nsq=0;
for(i=0;i<4;++i)
	for(j=0;j<3;++j)
		if((board[i][j+1]&31)==(board[i][j]&31))
		++nsq;
return nsq;
}

u8 ver_moves()
{
u8 nsq;
nsq=0;
for(i=0;i<4;++i)
	for(j=0;j<3;++j)
		if((board[j+1][i]&31)==(board[j][i]&31))
		++nsq;
return nsq;
}


u8 check_gameover()
{
u8 c_gameover;
c_gameover=0;
//check no free space
if (spare_squares()==0)
	//check no tiles to combine horizontally
	if (hor_moves()==0)
		//check no tiles to combine vertically
		if (ver_moves()==0)
		c_gameover=1;
return c_gameover;
}


void do_gameover()
{
u8 i;
gameover=1;
for(i=0;i<2;i++)
{
	select_image(IMG_FONT);
	output_x=15;
	output_y=10;
	put_str_key("GAME OVER!");
	output_x=14;
	output_y=12;
	put_str_key("R TO RESTART");
	swap_screen();
}
music_stop();
sample_play(1);
}

void do_win()
{
u8 i;
for(i=0;i<2;i++)
{
	select_image(IMG_FONT);
	output_x=16;
	output_y=10;
	put_str_key("YOU WIN!");
	output_x=14;
	output_y=12;
	put_str_key("C TO CONTINUE");
	swap_screen();
};
music_stop();
sample_play(0);
do {
	keyboard(keys);
	vsync(); //for joystick
} while ((keys[KEY_C]&KEY_PRESS) == 0);
init_screen_board();
music_play(MUS_2ATSTSTR);
}

void draw_bg()
{
	select_image(IMG_TILES2);
	for(i=8;i<(40-8);i++)
			draw_tile(i,0,31);
	for(j=0;j<25;j++)
	{
		for(i=0;i<8;i++)
			draw_tile(i,j,((256/8)*32)+16+(j<<5)+i);
		for(i=0;i<8;i++)
			draw_tile(i+(40-8),j,((256/8)*32)+24+(j<<5)+i);
	};
	swap_screen();
}


void new_game()
{
u8 i;
music_play(MUS_2ATSTSTR);
if (score>hiscore) hiscore=score;

//инициализаци€ переменных
score=0;
screenscore=65535;
oldscreenscore=65533;
screenhiscore=65535;
oldscreenhiscore=65533;
gameover=0;
win=0;

init_board();
draw_bg();
draw_bg();
add_rnd();
add_rnd();

for(i=0;i<2;i++)
{
	put_board();
	//выбор изображени€ дл€ вывода тайлов
/*
	select_image(IMG_FONT);
	output_x=score_x;
	output_y=0;
	put_str("SCORE");
	output_x=hiscore_x;
	output_y=0;
	put_str(" BEST");
*/
	//tscore[0]='0'+hiscore/100000;
	//tscore[1]='0'+(hiscore%100000)/10000;
	//tscore[2]='0'+(hiscore%10000)/1000;
	//tscore[3]='0'+(hiscore%1000)/100;
	//tscore[4]='0'+(hiscore%100)/10;
	//tscore[5]='0'+(hiscore%10);
	//output_x=hiscore_x;
	//output_y=2;
	//put_str(tscore);
}
}


void main(void)
{
	color_key(15);

	//чЄрный экран на врем€ подготовки

	pal_select(PAL_TILES2);
	pal_bright(BRIGHT_MIN);

	//очистка теневого экрана и установка палитры

	clear_screen(12);
	border(12);

	//переключение экранов, теперь фон на видимом экране

	swap_screen();
	clear_screen(12);
	swap_screen();

	//установка нормальной €ркости

	pal_bright(BRIGHT_MID);


	//спрайты в этом примере не используютс€, но при разрешЄнных спрайтах
	//автоматически выполн€етс€ копирование выводимой графики в два экрана,
	//что позвол€ет упростить этот пример

	//sprites_start();

	hiscore=0;

	//выбор изображени€ дл€ вывода тайлов
	select_image(IMG_FONT);
	output_x=13;
	output_y=10;
	put_str_key("USE THE ARROWS");
	output_x=14;
	output_y=12;
	put_str_key("R TO RESTART");
	swap_screen();

	while(joystick()==0) {vsync();rand16();} //for joystick
	while(joystick()) {vsync();rand16();} //for joystick

	new_game();


	//главный цикл
	while(1)
	{
		//получение состо€ни€ клавиш

		keyboard(keys);
		vsync(); //for joystick
		joy=joystick();

		if(gameover==0)
		{
			if(joy&JOY_LEFT) { joy=JOY_LEFT; move_left();}
			if(joy&JOY_RIGHT) { joy=JOY_RIGHT; move_right();}
			if(joy&JOY_UP) { joy=JOY_UP; move_up();}
			if(joy&JOY_DOWN) { joy=JOY_DOWN; move_down();}

			//обновление экрана
			if(joy==0) put_board();

			if (check_gameover()!=0) do_gameover();

			if (win==1) {win++; do_win();};

		}

		if(keys[KEY_R]&KEY_PRESS) new_game();

		//if(keys[KEY_LEFTARROW]&KEY_PRESS) move_left();
		//if(keys[KEY_RIGHTARROW]&KEY_PRESS) move_right();
		//if(keys[KEY_UPARROW]&KEY_PRESS) move_up();
		//if(keys[KEY_DOWNARROW]&KEY_PRESS) move_down();

	}

}