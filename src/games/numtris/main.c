#include "../_sdk/evo.h"
#include "resources.h"
#include "functions.h"
#include "intro.h"

#define HIGH_MAP 	11	// высота матрицы стакана
#define WIDTH_MAP 	5	// ширина матрицы стакана

#define LEFT_LIMIT 	60	// левая граница стакана
#define RIGHT_LIMIT 92 	// правая граница стакана
#define TOP_LIMIT 	16 	// верхняя точка стакана
#define DOWN_LIMIT 	160 // нижняя граница стакана
#define X_SCORE 	34
#define Y_SCORE 	7
#define X_BESTSCORE 	34
#define Y_BESTSCORE 	17
#define X_NEXT 		24
#define Y_NEXT 		56
#define X_ROTATE 	7
#define Y_ROTATE	15


//структура списка лидеров
static struct
{
	u16 scoreboard;
	u8 name[9];
}best[8];


static u16 score=0; // общие набранные очки
static u16 rotate=0; // замены кубика
static u16 score_rotate=0; 
static u8 map[HIGH_MAP][WIDTH_MAP]; // матрица игрового поля
static u8 gN=0;
static u8 yLimit=0;		//расстояние до дна
static u8 boxReel=0; 	//варианты возможных кубиков
static u8 i, j;



//структура спрайта
static struct
{
	u16 x,y;	//координаты
	u8 variant;	//вид кубика
	u8 variantNext; //следующий кубик
	u8 str,col;	//координаты кубика в матрице
}box;




#include "saveload.h"

// инициализация списка лидеров
void BestInit()
{
	for (i=0;i<8;i++)
	{
		best[i].scoreboard=0;
		for (j=0;j<8;j++)
			best[i].name[j]='.';
	}
}



//stop spacebar
void Stop()
{
	u8 done=FALSE;
	while(!done)
	{
		vsync();
		if(joystick()&JOY_FIRE) done=TRUE;
	}
}



// вывод bestscore
void put_best_score()
{
	u16 bestscore=0;
	
	select_image(IMG_FONT);// выбор изображения для тайлов
	color_key(15);
	
	for (i=0;i<8;i++)
		if (best[i].scoreboard>bestscore) bestscore=best[i].scoreboard;
	
	for (i=0;i<=3;i++)
	{
		draw_tile(X_BESTSCORE-i,Y_BESTSCORE,16+(bestscore%10));
		bestscore/=10;
	}
}



// вывод score и rotate на экран
void put_score(u16 score, u16 rotate)
{
	select_image(IMG_FONT);// выбор изображения для тайлов
	color_key(15);
	
	for (i=0;i<=3;i++)
	{
		draw_tile(X_SCORE-i,Y_SCORE,16+(score%10));
		score/=10;
	}
	if (rotate==0) draw_image(5,13,IMG_ROTOR_DIS);
	else
	{
		draw_image(5,13,IMG_ROTOR_EN);
		for (i=0;i<=1;i++)
		{
			draw_tile(X_ROTATE-i,Y_ROTATE,16+(rotate%10));
			rotate/=10;
		}
	}
}




// вывод строк по координатам
void put_string(u8 output_x, u8 output_y, u8* str)
{
	u8 n;
	while(1)
	{
		n=*str++;
		if(!n) break;
		draw_tile(output_x,output_y,n-' ');
		++output_x;
	}
}



// ввод имени в таблицу лидеров
void PutName(u8 output_x, u8 output_y)
{
	u32 n=time();
	u8 key;
	u8 keys[40];

	select_image(IMG_FONT);//выбор изображения для вывода тайлов

	while(1)
	{
		//получение состояния клавиш
		keyboard(keys);

		key=255;

		if(keys[KEY_0]&KEY_PRESS) key='0';
		if(keys[KEY_1]&KEY_PRESS) key='1';
		if(keys[KEY_2]&KEY_PRESS) key='2';
		if(keys[KEY_3]&KEY_PRESS) key='3';
		if(keys[KEY_4]&KEY_PRESS) key='4';
		if(keys[KEY_5]&KEY_PRESS) key='5';
		if(keys[KEY_6]&KEY_PRESS) key='6';
		if(keys[KEY_7]&KEY_PRESS) key='7';
		if(keys[KEY_8]&KEY_PRESS) key='8';
		if(keys[KEY_9]&KEY_PRESS) key='9';

		if(keys[KEY_A]&KEY_PRESS) key='A';
		if(keys[KEY_B]&KEY_PRESS) key='B';
		if(keys[KEY_C]&KEY_PRESS) key='C';
		if(keys[KEY_D]&KEY_PRESS) key='D';
		if(keys[KEY_E]&KEY_PRESS) key='E';
		if(keys[KEY_F]&KEY_PRESS) key='F';
		if(keys[KEY_G]&KEY_PRESS) key='G';
		if(keys[KEY_H]&KEY_PRESS) key='H';
		if(keys[KEY_I]&KEY_PRESS) key='I';
		if(keys[KEY_J]&KEY_PRESS) key='J';
		if(keys[KEY_K]&KEY_PRESS) key='K';
		if(keys[KEY_L]&KEY_PRESS) key='L';
		if(keys[KEY_M]&KEY_PRESS) key='M';
		if(keys[KEY_N]&KEY_PRESS) key='N';
		if(keys[KEY_O]&KEY_PRESS) key='O';
		if(keys[KEY_P]&KEY_PRESS) key='P';
		if(keys[KEY_Q]&KEY_PRESS) key='Q';
		if(keys[KEY_R]&KEY_PRESS) key='R';
		if(keys[KEY_S]&KEY_PRESS) key='S';
		if(keys[KEY_T]&KEY_PRESS) key='T';
		if(keys[KEY_U]&KEY_PRESS) key='U';
		if(keys[KEY_V]&KEY_PRESS) key='V';
		if(keys[KEY_W]&KEY_PRESS) key='W';
		if(keys[KEY_X]&KEY_PRESS) key='X';
		if(keys[KEY_Y]&KEY_PRESS) key='Y';
		if(keys[KEY_Z]&KEY_PRESS) key='Z';

		if(keys[KEY_SPACE]&KEY_PRESS) key=' ';
		if(keys[KEY_ENTER]&KEY_PRESS) key='\n';

		//если была нажата клавиша, вывести ее
		if(key!=255)
		{
			if(key>=' '&&key<='Z')
			{
				draw_tile(output_x,output_y,key-' ');
			}
			if(output_x==22)
			{
				output_x=21;
			}
			if(key=='\n')
			{
				swap_screen();
				set_sprite(0,output_x*4,output_y*8-5,SPRITE_END);
				swap_screen();
				set_sprite(0,output_x*4,output_y*8-5,SPRITE_END);
				
				sprites_stop();
	
				return;
			}
			if(key=='0'||joystick()&JOY_LEFT)
			{
				for (i=0;i<8;i++) best[((output_y-5)/2)].name[i]='.';
				put_string (14,output_y,best[((output_y-5)/2)].name);
				output_x=13;
			}
			best[((output_y-5)/2)].name[(output_x-14)]=key;
			output_x++;
			if(output_x==22)
			{
				output_x=21;
			}
		}
		
		
		if (n+25>time()) // мигающий курсор
		{
			set_sprite(0,output_x*4,output_y*8-5,11);
			swap_screen();
		}
		else if (n+50>time())
		{
			set_sprite(0,output_x*4,output_y*8-5,10);
			swap_screen();
		}
		else n=time();
	}
	
	
}




// конец игры и вывод лучших результатов
void GameOver()
{
	u8 n, m;
	u16 b;
	u8 output_y=3;
	u8 output_yy=5;
	
	
	draw_image(14,11,IMG_GAMEOVER);
	swap_screen();
	
	Stop();
	
	sprites_stop();
	clear_screen(0);
	swap_screen();
	clear_screen(0);
	swap_screen();
	sprites_start();
	draw_image(0,0,IMG_BEST);
	
	for (j=0;j<8;j++) //проверка на лидерство
	{
		if (score>best[j].scoreboard)
		{
			for (i=8;i>j;i--)
			{
				best[i].scoreboard=best[i-1].scoreboard;
				for (n=0;n<8;n++) best[i].name[n]=best[i-1].name[n];
			}
			best[j].scoreboard=score;
			for (i=0;i<8;i++) best[j].name[i]='.';
			score=0;
			output_yy+=(2*j);
		}
	}
	
	select_image(IMG_FONT);// выбор изображения для шрифта
	for (j=0;j<8;j++) // вывод списка лидеров
	{
		output_y+=2;
		b=best[j].scoreboard;
		for (i=0;i<=3;i++)
		{
			draw_tile(27-i,output_y,16+(b%10));
			b/=10;
		}
		put_string (14,output_y,best[j].name);
	}
	
	swap_screen();
	
	if (score==0)PutName(14,output_yy);
		
	
	SaveBest();
	
	save_to_file("savelist.bin");
	
	new_exit();
}



// подготовка игрового экрана
void InitScreen()
{
	//обнуление матрицы стакана
	for(i=0;i<HIGH_MAP;++i)
		for(j=0;j<WIDTH_MAP;++j) map[i][j]=0;
	
	// обнуление замен кубика
	rotate=0;
	score_rotate=0;
	
	//обнуление вариантов кубика
	boxReel=0;
	
	box.variantNext=0;
	
	//черный экран на время подготовки
	//pal_bright(BRIGHT_MIN);

	//установка палитры
	pal_select(PAL_BOX);
	
	//запуск спрайтов
	sprites_start();
	
	//очистка теневого экрана нужным цветом 0..15
	border(0);
	clear_screen(0);
	
	//вывод фона на теневой экран
	draw_image(0,0,IMG_BACK);

	//вывод строки очков
	put_score(0,0);
	
	//вывод строки лидера
	put_best_score();
	
	//установка нормальной яркости
	pal_bright(BRIGHT_MID);
	
}



// обновление спрайта
void Update()
{
	set_sprite(0,box.x,box.y,box.variant);
	set_sprite(1,X_NEXT,Y_NEXT,box.variantNext);
	swap_screen();
}



// отрисовка кубика тайлом
void DrawTileBox(u8 str, u8 col, u8 variant)
{
	select_image(IMG_BOX);	// выбор изображения для тайлов
	color_key(15);
	
	draw_tile_key(15+col*2,2+str*2,4*variant);
	draw_tile_key(16+col*2,2+str*2,4*variant+1);
	draw_tile_key(15+col*2,3+str*2,4*variant+2);
	draw_tile_key(16+col*2,3+str*2,4*variant+3);	

	//set_sprite(0,LEFT_LIMIT+col*8,TOP_LIMIT+str*16,SPRITE_END);
	swap_screen();
}



// инициализация нового кубика
void InitNewBox()
{
	u8 n;
	
	box.x=LEFT_LIMIT+16;
	box.y=TOP_LIMIT;
	box.col=2;
	box.str=0;
	box.variant=box.variantNext;
	
	n=rand16()%100;
	switch (boxReel)
	{
		case 0: box.variantNext=0;
		break;

		case 1:
		if (n<30) box.variantNext=0;		// 30%-2  70%-4
		else box.variantNext=1;
		break;
		
		case 2:
		if (n<40) box.variantNext=0;		// 40%-2  40%-4  20%-8
		else if (n<80) box.variantNext=1;
		else box.variantNext=2;
		break;
		
		case 3:
		if (n<40) box.variantNext=0;		// 40%-2  30%-4  20%-8  10%-16
		else if (n<70) box.variantNext=1;
		else if (n<90) box.variantNext=2;
		else box.variantNext=3;
		break;
		
		case 4:
		if (n<30) box.variantNext=0;		// 30%-2  25%-4  20%-8  15%-16  10%-32
		else if (n<55) box.variantNext=1;
		else if (n<75) box.variantNext=2;
		else if (n<90) box.variantNext=3;
		else box.variantNext=4;
		break;
		
		case 5:
		if (n<30) box.variantNext=0;		// 30%-2  25%-4  20%-8  10%-16  10%-32  5%-64
		else if (n<55) box.variantNext=1;
		else if (n<75) box.variantNext=2;
		else if (n<85) box.variantNext=3;
		else if (n<95) box.variantNext=4;
		else box.variantNext=5;
		break;
		
		case 6:
		if (n<25) box.variantNext=0;		// 25%-2  25%-4  20%-8  10%-16  10%-32  5%-64  5%-128
		else if (n<50) box.variantNext=1;
		else if (n<70) box.variantNext=2;
		else if (n<80) box.variantNext=3;
		else if (n<90) box.variantNext=4;
		else if (n<95) box.variantNext=5;
		else box.variantNext=6;
		break;
		
		case 7:
		if (n<20) box.variantNext=0;		// 20%-2  20%-4  20%-8  15%-16  10%-32  10%-64  3%-128  2%-256
		else if (n<40) box.variantNext=1;
		else if (n<60) box.variantNext=2;
		else if (n<75) box.variantNext=3;
		else if (n<85) box.variantNext=4;
		else if (n<95) box.variantNext=5;
		else if (n<98) box.variantNext=6;
		else box.variantNext=7;
		break;
		
		case 8:
		if (n<20) box.variantNext=0;		// 20%-2  20%-4  20%-8  15%-16  10%-32  5%-64  5%-128  3%-256 2%-512
		else if (n<40) box.variantNext=1;
		else if (n<60) box.variantNext=2;
		else if (n<75) box.variantNext=3;
		else if (n<85) box.variantNext=4;
		else if (n<90) box.variantNext=5;
		else if (n<95) box.variantNext=6;
		else if (n<98) box.variantNext=7;
		else box.variantNext=8;
		break;
	}
}



// проверка пространства снизу
u8 CheckDown()
{
	for(i=1;i<=HIGH_MAP-1;++i)
		{
			if (map[i][box.col]!=0)
			{
				yLimit=i-1;
				break;
			}
			else yLimit=HIGH_MAP-2;
		}
	return yLimit;
}



// проверка на коллизии
void Collision(u8 str, u8 col)
{
	
	if (map[str][col]!=map[str+1][col])
	{
		DrawTileBox(box.str,box.col,box.variant);
		if (gN==0) sfx_play(SFX_DEFINE,8);
		gN=0;
		
		if (str==1) // конец игры
		{
			sfx_play(SFX_GAMEOVER,8);
			vsync();
			GameOver();
			InitScreen(); // новая игра
			return;
		}
	}

	if (map[str][col]==map[str+1][col])
	{
		switch (gN)
		{
			case 0:
			sfx_play(SFX_BELL5,8);
			break;
			case 1:
			sfx_play(SFX_BELL4,8);
			break;
			case 2:
			sfx_play(SFX_BELL3,8);
			break;
			case 3:
			sfx_play(SFX_BELL2,8);
			break;
			case 4:
			sfx_play(SFX_BELL1,8);
			break;
			default:
			sfx_play(SFX_BELL0,8);
		}
		map[str+1][col]+=1;
		map[str][col]=0;
		if (gN>0) DrawTileBox(box.str,box.col,10);
		for (i=0;i<8;++i)
		{
			box.y+=2;
			Update();
		}
		box.str++;
		box.variant++;
		gN++;
		score+=box.variant;
		if (score>=score_rotate+100) //начисление rotate за 100 score
		{
			rotate++;
			score_rotate+=100;
		}
		put_score(score, rotate);
		if (box.variant==10)
		{
			map[box.str][box.col]=0;
			DrawTileBox(box.str,box.col,10);
			sfx_play(SFX_1024,8);
			gN=0;
		}			
	}
	if (gN>0)
	{
		Collision(box.str,box.col);
	}
	if (boxReel<(map[box.str][box.col]-1)&&boxReel<8) boxReel++;
	gN=0;
}


// обмен кубиков
void Substitution()
{
	sfx_play(SFX_SUB,8);
	for (i=0;i<=40;i+=8)
	{
		set_sprite(0,box.x,box.y+i,box.variant);
		set_sprite(1,X_NEXT,Y_NEXT-i,box.variantNext);
		swap_screen();
	}
	for (i=0;i<=box.x-24;i+=4)
	{
		set_sprite(0,box.x-i,box.y+40,box.variant);
		set_sprite(1,X_NEXT+i,Y_NEXT-40,box.variantNext);
		swap_screen();
	}
				
	j=box.variant;
	box.variant=box.variantNext;
	box.variantNext=j;
}

// главный цикл
void main(void)
{
	u8 k;

	Intro();
	Bright();
	BestInit();
	SaveBest();
	
	load_from_file("savelist.bin");
	LoadBest();
	InitScreen();
	InitNewBox();
	Update();
	
	while(1)
	{
		vsync();
		k=joystick();
		if(k&JOY_UP)
		{
			if (rotate>0)
			{
				rotate-=1;
				put_score(score,rotate);
				Substitution();
			}
		}
		if(k&JOY_RIGHT&&box.col<4)
		{
			sfx_play(SFX_SWIPE,4);
			for (i=0;i<8;i++)
			{
				box.x++;
				Update();
			}
			box.col++;
			
			
		}
		if(k&JOY_LEFT&&box.col>0)
		{
			sfx_play(SFX_SWIPE,4);
			for (i=0;i<8;i++)
			{
				box.x--;
				Update();
			}
			box.col--;
			
		}
		if(k&JOY_DOWN)
		{
			CheckDown();
			
			while (box.str<yLimit) // движение вниз
			{
				for (i=0;i<2;i++)
				{
					box.y+=8;
					Update();
				}
				box.str++;
			}
			map[box.str][box.col]=(box.variant+1);
			Collision(box.str, box.col);
			InitNewBox();
			Update();
			while (joystick());
		}
	}
}