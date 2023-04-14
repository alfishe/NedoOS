#include "../_sdk/evo.h"
#include "resources.h"
#include "functions.h"
#include "mouse.h"

#define	SIZE_EASY_LEVEL		3
#define	SIZE_MEDIUM_LEVEL	4
#define	SIZE_HARD_LEVEL		5

#define TIME_EASY_LEVEL		6000
#define TIME_MEDIUM_LEVEL	12000
#define TIME_HARD_LEVEL		24000

#define OFFSET_EASY_X 		60
#define OFFSET_EASY_Y 		56

#define OFFSET_MEDIUM_X 	52
#define OFFSET_MEDIUM_Y 	40

#define OFFSET_HARD_X 		44
#define OFFSET_HARD_Y 		24

static u32 t, t_old, t_level, t_total;

static i8 level;

static u16 summ_score=0;

static i8 map_x,map_y;

static i8 size_level;

static u8 offset_x,offset_y;

static u8 scr_map[SIZE_HARD_LEVEL][SIZE_HARD_LEVEL];

static u8 dot_map[SIZE_HARD_LEVEL][SIZE_HARD_LEVEL];

static u8 num_map[SIZE_HARD_LEVEL-1][SIZE_HARD_LEVEL-1];


//experts list
static struct
{
	u16 scoreboard;
	u8 name[9];
}	bestlist[9];

#include "saveload.h"

// reset experts list
void bestlist_init()
{
	u8 i,j;
	
	for (i=0;i<9;i++)
	{
		bestlist[i].scoreboard=0;
		for (j=0;j<8;j++)
			bestlist[i].name[j]='.';
	}
}

//exit to os
void quit()__naked
{
__asm
	jp _EXIT_TO_OS
__endasm;
}

// output score on screen
void output_score()
{
	u8 i;
	u16 score; 
	
	score=summ_score;
	
	select_image(IMG_FONT);
	color_key(15);
	
	for (i=0;i<=4;i++)
	{
		draw_tile(36-i,15,16+(score%10));
		score/=10;
	}
}


// output strings on coord
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

// waiting for a key
void press_start()
{
	while (TRUE)
	{
		if(joystick()||mouse_position()==MOUSE_LBTN)
		{
			sfx_play(SFX_DOTDEL,8);
			return;
		}
	}
}

// increasing screen brightness
void bright_up()
{
	u8 i;
	for (i=BRIGHT_MIN;i<=BRIGHT_MID;i++)
	{
		pal_bright(i);
		delay(3);
	}
}

// decreased screen brightness
void bright_down()
{
	i8 i;
	for (i=BRIGHT_MID;i>=BRIGHT_MIN;i--)
	{
		pal_bright(i);
		delay(3);
	}
	clear_screen(0);
	swap_screen();
}

// intro
void start_screen()
{
	pal_bright(BRIGHT_MIN);

	pal_select(PAL_PIPBOY);
	
	border(0);
	clear_screen(0);
	
	draw_image(0,0,IMG_PIPBOY);
	
	swap_screen();
	
	bright_up();
	
	sample_play(SMP_START);
	
	press_start();
	
	bright_down();
}

// output list of experts
void output_expertlist()
{
	u8 output_name_x=17;
	u8 output_score_x=30;
	u8 output_y=5;
	u16 tmp;
	u8 i, j;
	
	
	draw_image(0,0,IMG_LIST_EXPERTS);
	
	select_image(IMG_FONT);
	color_key (15);
	
	for (i=0;i<9;i++)
	{
		tmp=bestlist[i].scoreboard;
		for (j=0;j<=4;j++)
		{
			draw_tile(output_score_x-j,output_y,16+(tmp%10));
			tmp/=10;
		}
		put_string (output_name_x,output_y,bestlist[i].name);
		output_y+=2;
	}
	swap_screen();
	bright_up();
	press_start();
	bright_down();
}

// menu switch lewel
void switch_level()
{
	switch (level)
		{
			case 1:
			draw_image(17,4,IMG_EASY_ENABLE);
			draw_image(17,8,IMG_MEDIUM_DISABLE);
			draw_image(17,12,IMG_HARD_DISABLE);
			draw_image(14,16,IMG_LIST_DISABLE);
			draw_image(17,20,IMG_EXIT_DISABLE);
			t_level=TIME_EASY_LEVEL;
			break;
			case 2:
			draw_image(17,4,IMG_EASY_DISABLE);
			draw_image(17,8,IMG_MEDIUM_ENABLE);
			draw_image(17,12,IMG_HARD_DISABLE);
			draw_image(14,16,IMG_LIST_DISABLE);
			draw_image(17,20,IMG_EXIT_DISABLE);
			t_level=TIME_MEDIUM_LEVEL;
			break;
			case 3:
			draw_image(17,4,IMG_EASY_DISABLE);
			draw_image(17,8,IMG_MEDIUM_DISABLE);
			draw_image(17,12,IMG_HARD_ENABLE);
			draw_image(14,16,IMG_LIST_DISABLE);
			draw_image(17,20,IMG_EXIT_DISABLE);
			t_level=TIME_HARD_LEVEL;
			break;
			case 4:
			draw_image(17,4,IMG_EASY_DISABLE);
			draw_image(17,8,IMG_MEDIUM_DISABLE);
			draw_image(17,12,IMG_HARD_DISABLE);
			draw_image(14,16,IMG_LIST_ENABLE);
			draw_image(17,20,IMG_EXIT_DISABLE);
			break;
			case 5:
			draw_image(17,4,IMG_EASY_DISABLE);
			draw_image(17,8,IMG_MEDIUM_DISABLE);
			draw_image(17,12,IMG_HARD_DISABLE);
			draw_image(14,16,IMG_LIST_DISABLE);
			draw_image(17,20,IMG_EXIT_ENABLE);
			break;
		}
	swap_screen();
	sfx_play(SFX_MOVE,8);
}

// menu
void menu_screen()
{
	u8 key, i;
	i8 level_temp;
	
	level=1;
	t_level=TIME_EASY_LEVEL;
	
	clear_screen(0);
	
	draw_image(0,0,IMG_MENU);
	draw_image(17,4,IMG_EASY_ENABLE);
	
	swap_screen();
	bright_up();
	
	while (TRUE)
	{
		
		//mouse
		i=mouse_position();
		if (i==MOUSE_LBTN)
		{
			sfx_play(SFX_DOTDEL,8);
			if (level==5) quit();
			if (level==4)
			{
				bright_down();
				set_sprite(0,0,0,SPRITE_END);
				swap_screen();
				set_sprite(0,0,0,SPRITE_END);
				output_expertlist();
				menu_screen();
			}
			summ_score=0;
			while(mouse_position()==MOUSE_LBTN);
			return;
		}
		mouse_setup(mouse_x,mouse_y); 
		set_sprite(0,mouse_x,mouse_y,6);
		
		level_temp=level;
		if (mouse_x>56&&mouse_x<108)
		{
			if(mouse_y>24&&mouse_y<48) level=1;
			if(mouse_y>56&&mouse_y<80) level=2;
			if(mouse_y>88&&mouse_y<112) level=3;
			if(mouse_y>120&&mouse_y<144) level=4;
			if(mouse_y>152&&mouse_y<176) level=5;
		}
		if (level_temp!=level) switch_level();
		swap_screen();
		
		
		//keyboard
		key=joystick();
		
		if(key!=FALSE)
		{
			mouse_x=152;
			mouse_y=184;
			mouse_setup(152,184);
			
			if(key&JOY_FIRE)
			{
				sfx_play(SFX_DOTDEL,8);
				if (level==5) quit();
				if (level==4)
				{
					bright_down();
					output_expertlist();
					menu_screen();
				}
				summ_score=0;
				return;
			}
			
			if(key&JOY_UP)
			{
				level_temp=level;
				level--;
				if (level<1) level=1;
				if (level_temp!=level) switch_level();
			}
			
			if(key&JOY_DOWN)
			{
				level_temp=level;
				level++;
				if (level>5) level=5;
				if (level_temp!=level) switch_level();
			}
			while (joystick());
		}
		t=t_level;
	}
}

// level generation
void level_gen()
{
	u8 n;
	u8 summ_dot=0;
	
	switch (level)
	{
		case 1:
		draw_image(0,0,IMG_EASY);
		swap_screen();
	
		size_level=SIZE_EASY_LEVEL;
		offset_x=OFFSET_EASY_X;
		offset_y=OFFSET_EASY_Y;
		break;

		case 2:
		draw_image(0,0,IMG_MEDIUM);
		swap_screen();
	
		size_level=SIZE_MEDIUM_LEVEL;
		offset_x=OFFSET_MEDIUM_X;
		offset_y=OFFSET_MEDIUM_Y;
		break;

		case 3:
		draw_image(0,0,IMG_HARD);
		swap_screen();
	
		size_level=SIZE_HARD_LEVEL;
		offset_x=OFFSET_HARD_X;
		offset_y=OFFSET_HARD_Y;
		break;
	}
	
	for (map_y=0;map_y<size_level;map_y++)
		for (map_x=0;map_x<size_level;map_x++)
		{
			n=rand16()%100;
			if (n<45) dot_map[map_x][map_y]=0; // balance
			else
			{
				dot_map[map_x][map_y]=1;
			}
			summ_dot+=dot_map[map_x][map_y];
			scr_map[map_x][map_y]=0;
		}
		
	if (level==1&&summ_dot==9||level==2&&summ_dot==16||summ_dot==25) level_gen();
	
	output_score();
	
	select_image(IMG_NUM);
	color_key(15);
	
	for (map_y=0;map_y<size_level-1;map_y++)
		for (map_x=0;map_x<size_level-1;map_x++)
		{
			num_map[map_x][map_y]=dot_map[map_x][map_y]+dot_map[map_x+1][map_y]+dot_map[map_x][map_y+1]+dot_map[map_x+1][map_y+1];
			draw_tile_key(map_x*4+(offset_x/4+2),map_y*4+(offset_y/8+2),num_map[map_x][map_y]*4);
			draw_tile_key(map_x*4+(offset_x/4+3),map_y*4+(offset_y/8+2),num_map[map_x][map_y]*4+1);
			draw_tile_key(map_x*4+(offset_x/4+2),map_y*4+(offset_y/8+3),num_map[map_x][map_y]*4+2);
			draw_tile_key(map_x*4+(offset_x/4+3),map_y*4+(offset_y/8+3),num_map[map_x][map_y]*4+3);
		}
	swap_screen();
	map_x=0;
	map_y=0;
	
	t_old=time();
}


// init new game
void new_game()
{
	menu_screen();
	
	level_gen();
}

//checking leader and input name
void enter_name()
{
	u8 i,j,n;
	u8 n_list=0;
	
	u8 input_x=25;
	u8 input_y=19;
	
	u32 t=time();
	u8 key;
	u8 keys[40];
	
	u8 check=FALSE;
	
	for (j=0;j<9;j++)
	{
		if (summ_score>bestlist[j].scoreboard)
		{
			for (i=8;i>j;i--)
			{
				bestlist[i].scoreboard=bestlist[i-1].scoreboard;
				for (n=0;n<8;n++) bestlist[i].name[n]=bestlist[i-1].name[n];
			}
			bestlist[j].scoreboard=summ_score;
			for (i=0;i<8;i++) bestlist[j].name[i]='.';
			check=TRUE;
			n_list=j;
			break;
		}
	}
	if (check==FALSE) return;
	
	draw_image(0,0,IMG_ENTER_NAME);
	swap_screen();
	bright_up();
	sfx_play(SFX_WIN,8);
	vsync();

	select_image(IMG_FONT);

	while(1)
	{
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

		if(key!=255)
		{
			if(key>=' '&&key<='Z')
			{
				draw_tile(input_x,input_y,key-' ');
			}
			if(input_x==33)
			{
				input_x=32;
			}
			if(key=='\n')
			{
				swap_screen();
				set_sprite(0,input_x*4,input_y*8-5,SPRITE_END);
				swap_screen();
				set_sprite(0,input_x*4,input_y*8-5,SPRITE_END);
				bright_down();
				save_best();
				save_to_file("savelist.bin");
				output_expertlist();
				return;
			}
			if(key=='0'||joystick()&JOY_LEFT)
			{
				for (i=0;i<8;i++) bestlist[n_list].name[i]='.';
				put_string (25,input_y,bestlist[n_list].name);
				input_x=24;
			}
			bestlist[n_list].name[(input_x-25)]=key;
			input_x++;
			if(input_x==33)
			{
				input_x=32;
			}
		}
		
		// cursor
		if (t+25>time()) 
		{
			set_sprite(0,input_x*4,input_y*8-5,5);
			swap_screen();
		}
		else if (t+50>time())
		{
			set_sprite(0,input_x*4,input_y*8-5,4);
			swap_screen();
		}
		else
		{
			t=time();
			sfx_play(SFX_MOVE,8);
		}
	}
}

// game over
void time_over()
{
	sfx_play(SFX_TIMEOVER,8);
	bright_down();
	
	set_sprite(0,0,0,SPRITE_END);
	set_sprite(1,0,0,SPRITE_END);
	swap_screen();
	set_sprite(0,0,0,SPRITE_END);
	set_sprite(1,0,0,SPRITE_END);
	
	
	draw_image(0,0,IMG_TIME_OVER);
	swap_screen();
	bright_up();
	
	press_start();
	bright_down();
	
	enter_name();
	new_game();
}

// output time on screen
void output_time()
{
	u8 i;
	u8 sec, min;
	select_image(IMG_FONT);
	color_key(15);
	
	t_total=t-(time()-t_old);
	
	min=(t_total/50)/60;
	sec=(t_total/50)%60;
	for (i=0;i<=1;i++)
	{
		draw_tile_key(4-i,15,16+(min%10));
		min/=10;
		draw_tile_key(6-i,15,16+(sec%10));
		sec/=10;
	}
	
	if (t_total<=0) time_over();
}

// setup dot
void dot_set()
{
	select_image(IMG_TILES);
	color_key(15);
	
	if (scr_map[map_x][map_y]==0)
	{
		sfx_play(SFX_DOTSET,8);
		scr_map[map_x][map_y]=1;
		draw_tile_key(map_x*4+(offset_x/4),map_y*4+(offset_y/8),12);
		draw_tile_key(map_x*4+(offset_x/4+1),map_y*4+(offset_y/8),13);
		draw_tile_key(map_x*4+(offset_x/4),map_y*4+(offset_y/8+1),14);
		draw_tile_key(map_x*4+(offset_x/4+1),map_y*4+(offset_y/8+1),15);
		swap_screen();
	}
	else
	{
		sfx_play(SFX_DOTDEL,8);
		scr_map[map_x][map_y]=0;
		draw_tile_key(map_x*4+(offset_x/4),map_y*4+(offset_y/8),4);
		draw_tile_key(map_x*4+(offset_x/4+1),map_y*4+(offset_y/8),5);
		draw_tile_key(map_x*4+(offset_x/4),map_y*4+(offset_y/8+1),6);
		draw_tile_key(map_x*4+(offset_x/4+1),map_y*4+(offset_y/8+1),7);
		swap_screen();
	}
}

//calculation score
void win()
{
	u16 score=0;
	u16 time_bonus;
	u8 multiplier=0;
	
	u8 i;
	u8 sec, min;
	
	switch (level)
	{
		case 2:
		multiplier=5;
		break;
		
		case 3:
		multiplier=10;
		break;
	}
	
	if ((time()-t_old)<t_level/20)
	{
		score=10*multiplier;
		time_bonus=t_level/10;
		t=t_total+time_bonus;
	}
	else if ((time()-t_old)<t_level/10)
	{
		score=5*multiplier;
		time_bonus=t_level/20;
		t=t_total+time_bonus;
	}
	else if ((time()-t_old)<t_level/5)
	{
		score=2*multiplier;
		time_bonus=50;
		t=t_total+time_bonus;
	}
	else
	{
		score=1*multiplier;
		time_bonus=0;
		t=t_total;
	}

	if (score==0) score=1;
	
	summ_score+=score;
	
	sfx_play(SFX_COMPLETED,8);
	
	while(joystick()||mouse_position()==MOUSE_LBTN);
	
	set_sprite(0,0,0,SPRITE_END);
	set_sprite(1,0,0,SPRITE_END); 
	swap_screen();
	set_sprite(0,0,0,SPRITE_END);
	set_sprite(1,0,0,SPRITE_END);
	draw_image(11,9,IMG_LEVEL_COMPLETED);

	select_image(IMG_FONT);
	color_key(15);
	min=(time_bonus/50)/60;
	sec=(time_bonus/50)%60;
	for (i=0;i<=1;i++)
	{
		draw_tile_key(24-i,13,16+(min%10));
		min/=10;
		draw_tile_key(26-i,13,16+(sec%10));
		sec/=10;
	}
	swap_screen();
	press_start();
	
	level_gen();
}

// checking map
void checking()
{
	i8 x,y;
	u8 chk=TRUE;
	
	for (y=0;y<size_level-1;y++)
		for (x=0;x<size_level-1;x++)
		{
			if(num_map[x][y]!=scr_map[x][y]+scr_map[x+1][y]+scr_map[x][y+1]+scr_map[x+1][y+1]) chk=FALSE;
		}
	if (chk==TRUE) win();
}

// update screen cursor sprites
void animation()
{
	set_sprite(0,map_x*16+offset_x,map_y*32+offset_y,1);
	set_sprite(1,mouse_x,mouse_y,6);
	swap_screen();
}

////////////////////////////////////////////////////////////
void main(void)
{
	u8 key,i;
	u8 mouse_en=TRUE;
	
	sprites_start();
	start_screen();
	
	bestlist_init();
	save_best();
	
	load_from_file("savelist.bin");
	load_best();
	
	
	
	mouse_clipping(4,8,152,184);
	//mouse_setup(152,184);
	
	new_game();
	
	while (TRUE)
	{
		output_time();
		
		mouse_position();
		
		key=joystick();
		
		// keyboard control
		if(key!=FALSE)
		{
			mouse_en=FALSE;
			mouse_x=152;
			mouse_y=184;
			mouse_setup(152,184);
			
			if(key&JOY_FIRE)
			{
				dot_set();
				checking();
			}
			if(key&JOY_UP)
			{
				map_y--;
				if (map_y<0) map_y=0;
			}
			if(key&JOY_DOWN)
			{
				map_y++;
				if (map_y>size_level-1) map_y=size_level-1;
			}
			if(key&JOY_LEFT)
			{
				map_x--;
				if (map_x<0) map_x=0;
			}
			if(key&JOY_RIGHT)
			{
				map_x++;
				if (map_x>size_level-1)
				{
					while (TRUE)
					{
						
						output_time();
						set_sprite(0,132,32,0);
						set_sprite(1,mouse_x,mouse_y,6);
						swap_screen();
						
						if(joystick()&JOY_LEFT)
						{
							map_x=size_level-1;
							break;
						}
						if(joystick()&JOY_FIRE)
						{
							sfx_play(SFX_DOTDEL,8);
							bright_down();
							
							set_sprite(0,0,0,SPRITE_END);
							set_sprite(1,0,0,SPRITE_END);
							swap_screen();
							set_sprite(0,0,0,SPRITE_END);
							set_sprite(1,0,0,SPRITE_END);
							
							enter_name();
							new_game();
							break;
						}
					}
				}
			}
			while (joystick())
			{
				output_time();
				animation();
			}
		}
		
		// mouse control
		if (mouse_x<150 || mouse_y<180) mouse_en=TRUE;
		if (mouse_en==TRUE)
		{
			mouse_setup(mouse_x,mouse_y); 
			
			map_x=(mouse_x-offset_x+4)/16;
			if (map_x<0) map_x=0;
			if (map_x>size_level-1) map_x=size_level-1;
			
			map_y=(mouse_y-offset_y+8)/32;
			if (map_y<0) map_y=0;
			if (map_y>size_level-1) map_y=size_level-1;
			
			
			if (mouse_x>128&&mouse_y<56)
			{
				while (mouse_x>128&&mouse_y<56)
				{
					i=mouse_position();
					
					output_time();
					set_sprite(0,132,32,0);
					set_sprite(1,mouse_x,mouse_y,6);
					swap_screen();
					
					if(i==MOUSE_LBTN)
					{
						sfx_play(SFX_DOTDEL,8);
						bright_down();
						
						set_sprite(0,0,0,SPRITE_END);
						set_sprite(1,0,0,SPRITE_END); 
						swap_screen();
						set_sprite(0,0,0,SPRITE_END);
						set_sprite(1,0,0,SPRITE_END);
						
						enter_name();
						new_game();
						break;
					}
				}
			}			
			
			i=mouse_position();
			if (i==MOUSE_LBTN)
			{
				dot_set();
				checking();
				while(mouse_position()==MOUSE_LBTN)
				{
					output_time();
					animation();
				}
			}
		}
		animation();
	}
}