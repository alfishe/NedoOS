//#define __SDCC_z80
#include <evo.h>
#include "resources.h"
#include "map.h"
#include <math.h>
static u8 save_output_x;
static u8 output_x;
static u8 output_y;
static u8 keys[40];
struct room2 *curroom;
static u8 noredraw;
void fade_to_black(void)
{
	u8 a;
	for(a=4;a>0;a--)
	{
		pal_bright(a-1);
		delay(2);
		swap_screen();
	}
}
void fade_from_black(void)
{
	u8 a;
	for(a=0;a<=3;a++)
	{
		pal_bright(a);
		delay(2);
		swap_screen();
	}
}
void put_char(u8 n)
{
 if(n>=' ') draw_tile(output_x,output_y,n-' ');

  ++output_x;

  if(output_x==39||n=='\n')
  {
    output_x=save_output_x;
    
    ++output_y;
    
    if(output_y==24) output_y=1;
  }
}
void put_str(u8* str)
{

  u8 i;
  //output_x=1;
  //output_y=1;
  //pal_select(PAL_FONT);
  select_image(IMG_FONT);
  save_output_x=output_x;
  while(1)
  {
    i=*str++;

    if(!i) break;

    put_char(i);
  }
}
struct room2 *ge_room(u8 num)
{
	if(num==0)return &l34;
	if(num==1)return &l33;
	if(num==2)return &l36;
	if(num==3)return &l35;
	if(num==4)return &l32;
	if(num==5)return &l31;
	if(num==6)return &l37;
	if(num==7)return &l39;
	if(num==8)return &l310;
	if(num==9)return &l21;
	if(num==10)return &l22;
	if(num==11)return &l23;
	if(num==12)return &l25;
	if(num==13)return &l24;
	if(num==14)return &l210;
	if(num==15)return &l26;
	if(num==16)return &l27;
	if(num==17)return &l29;
	if(num==18)return &l28;
	if(num==19)return &l11;
	if(num==20)return &l17;
	if(num==21)return &l19;
	if(num==22)return &l18;
	if(num==23)return &l12;
	if(num==24)return &l13;
	if(num==25)return &l15;
	if(num==26)return &l14;
	if(num==27)return &l16;
	if(num==28)return &l38;
	if(num==29)return &l41;
	if(num==30)return &l01;
	return &l34;
}
/*void print_tile(u8 x,u8 y,u8 tilenum,u8 tw,u8 tmw,u8 mask)
{
  u8 a,b,c,d;
  //select_image(IMG_TILES);
  for(a=0;a<tw;a++)
  {
    for(b=0;b<tw;b++)
    {
      d=(tilenum/(tmw/tw));
      c=(d*tw)*tmw+(tilenum-d*(tmw/tw))*tw;
      //+a+b*tmw
      if(mask!=1) draw_tile(x+a,y+b,(tilenum-d*(tmw/tw))*tw+(d*tw)*tmw+a+b*tmw);
      else
      {
        color_key(13);
        draw_tile_key(x+a,y+b,(tilenum-d*(tmw/tw))*tw+(d*tw)*tmw+a+b*tmw);
      }
        
      
    }
  }
}*/
void print_tile(u8 x,u8 y,u16 tilenum,u8 tw,u8 tmw,u8 mask)
{
  u16 c,d,tn;
  u8 a,b,xt,xend;
  //select_image(IMG_TILES);
  if(tw==1) 
  {
    tn = tilenum;
    c = tilenum;
  }
  else
  {
    if ( (tw==2) && (tmw == 32))
    {
        d = (tilenum & 0xfff0) << 2;
//        ptile_d = ptile_d << 2;
        c = d + ((tilenum & 0x0f) << 1);
        tn = c;
    }
    else
    {
      d=(tilenum/(tmw/tw));
      c=(d*tw)*tmw+(tilenum-d*(tmw/tw))*tw;
      tn = c;
    }
  }
if(mask!=1) 
  for(a=0;a<tw;a++)
  {
    xt = x;
	xend = xt+tw;
    //for(b=0;b<tw;b++)
	do
    {
      draw_tile(xt,y,tn);
	  tn++;
      xt++;
    }while(xt < xend);
    y++;
    c+=tmw;
    tn = c;
  }
else //mask==1
{
  color_key(13); 
  for(a=0;a<tw;a++)
  {
    xt = x;
	xend = xt+tw;
    //for(b=0;b<tw;b++)
	do
    {
      draw_tile_key(xt,y,tn);
	  tn++;
      xt++;
    }while(xt < xend);
    y++;
    c+=tmw;
    tn = c;
  }
} //else
} 
void draw_room(struct room2 *rm)
{
  i16 x,xx,yy,y,b;
  i16 a;
  i16 curelem;
  clear_screen(1);
  x=rm->l;
  y=rm->t;
  xx=x;
  yy=y;
  select_image(IMG_TILES);
  if(rm->count_l1_elements>0)
  {
	  for(a=0;a<rm->count_l1_elements*2;a+=2)
	  {
		curelem=rm->l1_elements[a];
		for(b=0;b<rm->l1_elements[a+1];b++)
		{
		  if (curelem>0)print_tile(xx*2,yy*2,curelem-1,2,32,0);
		  xx++;
		  if(xx>20)
		  {
			xx=x;
			yy++;
		  }
		}
	  }
	 }
	if(rm->count_l1_elements==0 && rm->l1_elements[0]==0)
	{
		draw_image(0,0,IMG_ROOF);
	}
	if(rm->count_l1_elements==0 && rm->l1_elements[0]==1)
	{
		draw_image(0,0,IMG_BASEMENT);
	}
	  select_image(IMG_SEC_LAY);
	 
	  for(a=0;a<rm->count_l2_elements;a++)
	  {
		curelem=rm->l2_elements[a*3]-1;
		print_tile(rm->l2_elements[a*3+1]*2,rm->l2_elements[a*3+2]*2,curelem,2,32,1);
	  }
	  select_image(IMG_OBJECTS);
	  for(a=rm->count_triggers-1;a>=0;a--)
	  {
		if(rm->triggers[a].picture_unactived>0 ||rm->triggers[a].picture_actived>0)
		{
			if(rm->triggers[a].actived==1 && rm->triggers[a].picture_actived>0)
			{
				print_tile(rm->triggers[a].x*2,rm->triggers[a].y*2,rm->triggers[a].picture_actived-1,2,2,1);
			}
			else if(rm->triggers[a].actived==0 && rm->triggers[a].picture_unactived>0)
			{
				print_tile(rm->triggers[a].x*2,rm->triggers[a].y*2,rm->triggers[a].picture_unactived-1,2,2,1);
			}
		}
	  }
  

}
void draw_text(struct room2 *rm,struct text *txt)
{
	int a,b,c;
	sprites_stop();
	txt->x=20-(txt->w/2)-1;
	txt->y=12-(txt->h/2)-1;
	for(c=0;c<txt->count_phrases;c++)
	{
		sample_play(SMP_SWITCH);
		output_x=txt->x;
		output_y=txt->y;
		put_str("╔");
		output_x=txt->x+txt->w;
		output_y=txt->y;
		put_str("╗");
		output_x=txt->x;
		output_y=txt->y+txt->h;
		put_str("╚");
		output_x=txt->x+txt->w;
		output_y=txt->y+txt->h;
		put_str("╝");
		output_x=txt->x+1;
		output_y=txt->y;
		for(a=txt->x+1;a<txt->x+txt->w;a++)
		{
			put_str("═");
		}
		output_x=txt->x+1;
		output_y=txt->y+txt->h;
		for(a=txt->x+1;a<txt->x+txt->w;a++)
		{
			put_str("═");
		}
		output_x=txt->x;
		output_y=txt->y+1;
		for(a=txt->y+1;a<txt->y+txt->h;a++)
		{
			output_x=txt->x;
			output_y=a;
			put_str("║");
		}
		output_x=txt->x+txt->w;
		output_y=txt->y+1;
		for(a=txt->y+1;a<txt->y+txt->h;a++)
		{
			output_x=txt->x+txt->w;
			output_y=a;
			put_str("║");
		}
		
		for(b=txt->y+1;b<txt->y+txt->h;b++)
		{
			output_x=txt->x+1;
			output_y=b;
			for(a=txt->x+1;a<txt->x+txt->w;a++)
			{
				put_str(" ");
			}
		}
		output_x=txt->x+txt->w-1;
		output_y=txt->y+txt->h;
		put_str("░");
		output_x=txt->x+1;
		output_y=txt->y+1;
		put_str(txt->text[c]);
		swap_screen();
		delay(10);
		while(joystick()==0) vsync(); //for joystick
		
	}
	if (noredraw!=2)	draw_room(rm);
	swap_screen();
	sprites_start();
	delay(15);
}

void title(void)
{
	
	music_play(MUS_DIAMOND);
	sprites_stop();
	pal_select(PAL_TITLE);
	draw_image(0,0,IMG_TITLE);
	swap_screen();
	fade_from_black();
	while(joystick()==0) vsync(); //for joystick
	music_stop(); //bug fixed
	sample_play(SMP_BELL);
	fade_to_black();
	clear_screen(1);
	swap_screen();
	clear_screen(1);
	swap_screen();
	sprites_start();
}
void game_begin( character *james)
{
  u8 a,b;
  noredraw=1;
  border(1);
  james->x=50;
  james->y=80;
  james->napr=1;
  james->frame=0;
  james->count_items=0;
  pal_bright(BRIGHT_MIN);
  pal_select(PAL_TILES);
  pal_bright(BRIGHT_MID);
  for(a=0;a<=30;a++)
 {
	curroom=ge_room(a);
	for(b=0;b<(curroom)->count_triggers;b++)
	{
		(curroom)->triggers[b].actived=1;
		if((curroom)->triggers[b].act_walkable==1)(curroom)->triggers[b].walkable=0;
	}
 }
 
  curroom=ge_room(0);
  draw_text(curroom,&intro);
  color_key(30);
  /*james->count_items=2;
  james->inventory[0]=21;
  james->inventory[1]=20;*/
  draw_room(curroom);
  swap_screen();
  draw_room(curroom);
  
  
  sprites_start();
  draw_text(curroom,texts[0]);                     //------------------потом вернуть
}



//-----------------------------------------------------------------
u8 check_distance(struct room2 *rm,u8 tox,u8 toy)
{
  i16 a,c,d,e;
  u8 b;
  b=1;
  toy+=16;


	for(a=0;a<rm->count_triggers;a++)
	{
		for(d=0;d<rm->triggers[a].w;d++)
		{
			for(e=0;e<rm->triggers[a].h;e++)
			{
				c=sqrtf(((tox-(rm->triggers[a].x+d)*8)*(tox-(rm->triggers[a].x+d)*8))+(toy-(rm->triggers[a].y+e)*16)*(toy-(rm->triggers[a].y+e)*16));
				if(c<=20&&rm->triggers[a].actived==1&&rm->triggers[a].item_needed!=0)
				{
					
					b=a+5;
					a=rm->count_triggers+1;
					e=rm->triggers[a].h+1;
					d=rm->triggers[a].w+1;
				}
			}
		}
	}

  
  return b;
}
u8 on_trig(struct room2 *rm,u8 x,u8 trg,u8 tox,u8 toy)
{
  u8 a,b;
  b=1;
  toy+=32;
  tox+=4;

	  for(a=0;a<rm->count_triggers;a++)
	  {

		if(rm->triggers[a].actived==1)
		{
			if((((tox-2>=(rm->triggers[a].x-1)*8)||(tox>=(rm->triggers[a].x-1)*8))&&(toy>=(rm->triggers[a].y-1)*16)&&((tox-2<=((rm->triggers[a].x+1)*8+rm->triggers[a].w*8))||(tox<=((rm->triggers[a].x+1)*8+rm->triggers[a].w)))&&(toy<=((rm->triggers[a].y+2)*16+rm->triggers[a].h*16))))
			{
				b=a+5;
			}
		}
	 }

  return b;
}
u8 check_walkness(struct room2 *rm,u8 x,u8 trg,u8 tox,u8 toy)
{
  u8 a,b;
  b=1;
  toy+=32;
  tox+=4;
  if (trg==0)
  {
	  for(a=0;a<rm->count_walk_elements*4;a+=4)
	  {

			if(((tox-2>=rm->walk_elements[a]*8)||(tox>=rm->walk_elements[a]*8))&&(toy>=rm->walk_elements[a+1]*16)&&((tox-2<=(rm->walk_elements[a]*8+rm->walk_elements[a+2]*8))||(tox<=(rm->walk_elements[a]*8+rm->walk_elements[a+2]*8)))&&(toy<=(rm->walk_elements[a+1]*16+rm->walk_elements[a+3]*16)))
			{
				b=0;
			}
	  }
	  for(a=0;a<rm->count_triggers;a++)
	  {
			if((rm->triggers[a].walkable==0)&&(((tox-2>=rm->triggers[a].x*8)||(tox>=rm->triggers[a].x*8))&&(toy>=rm->triggers[a].y*16)&&((tox-2<=(rm->triggers[a].x*8+rm->triggers[a].w*8))||(tox<=(rm->triggers[a].x+rm->triggers[a].w)))&&(toy<=(rm->triggers[a].y*16+rm->triggers[a].h*16))))
			{
				b=0;
			}
	  }
 }
  
  if (trg==1)
  {
	  for(a=0;a<rm->count_triggers;a++)
	  {

		if(rm->triggers[a].actived==1&&rm->triggers[a].walkable==1)
		{
			if((((tox-2>=rm->triggers[a].x*8)||(tox>=rm->triggers[a].x*8))&&(toy>=rm->triggers[a].y*16)&&((tox-2<=(rm->triggers[a].x*8+rm->triggers[a].w*8))||(tox<=(rm->triggers[a].x+rm->triggers[a].w)))&&(toy<=(rm->triggers[a].y*16+rm->triggers[a].h*16))))
			{
				b=a+5;
			}
		}
	 }
 }
  
  return b;
}
void activate_trigger(struct room2 *rm,character *chr,struct room2 **rooms,struct room2 **curroom,u8 triggernum,u8 fire)//fire так же является номером предмета. если 0-наступил. 1- жмякнул действие 2 и более предмет
{
	u8 a,b,c;
	if(rm->triggers[triggernum].actived==1)
	{
		if(rm->triggers[triggernum].item_needed==fire)
		{
			//put_str("correct");
			if(rm->triggers[triggernum].disabling==1)
			{
				rm->triggers[triggernum].actived=0;
				draw_room(rm);
				
			}
			if(fire>1)
			{
				for(a=0;a<chr->count_items;a++)
				{
					if (chr->inventory[a]==fire)
					{
						for(b=a;b<chr->count_items;b++)
						{
							chr->inventory[b]=chr->inventory[b+1];
						}
						a=chr->count_items;
						chr->count_items--;
					}
				}
			}
			if(rm->triggers[triggernum].item_or_teleport==1)
			{
				//fade_to_black();
				pal_bright(0);
				*curroom=ge_room(rm->triggers[triggernum].room_or_item_number);
				//*curroom=rooms[];
				chr->x=rm->triggers[triggernum].x_exit*8;
				chr->y=rm->triggers[triggernum].y_exit*16-20;
				select_image(IMG_TILES);
				sprites_stop();
				clear_screen(1);
				draw_room(*curroom);
				swap_screen();
				//clear_screen(1);
				//draw_room(*curroom);
				//sample_play(SMP_DOOR);
				sprites_start();
				//fade_from_black();
				pal_bright(3);
			}
			if(rm->triggers[triggernum].item_or_teleport==2)
			{
				c=0;
				for(b=0;b<chr->count_items;b++)
				{	
					if(chr->inventory[0]==rm->triggers[triggernum].room_or_item_number)c=1;
				}
				if(c==0)
				{				
					chr->inventory[chr->count_items]=rm->triggers[triggernum].room_or_item_number;
					chr->count_items++;
				}
			}
			if(rm->triggers[triggernum].item_or_teleport==5)//попался к глубоководным
			{
				sprites_stop();
				pal_select(PAL_DEEP_ONE);
				draw_image(0,0,IMG_DEEP_ONE);
				swap_screen();
				draw_image(0,0,IMG_DEEP_ONE);
				swap_screen();
				sample_play(SMP_DEEPONE);
				delay(25);
				clear_screen(2);
				swap_screen();
				draw_image(0,0,IMG_SCRATCH1);
				swap_screen();
				draw_image(0,0,IMG_SCRATCH1);
				swap_screen();
				sample_play(SMP_SLASH);
				delay(25);
				clear_screen(2);
				swap_screen();
				draw_image(0,0,IMG_SCRATCH2);
				swap_screen();
				draw_image(0,0,IMG_SCRATCH2);
				swap_screen();
				sample_play(SMP_SLASH);
				delay(25);
				for(a=4;a>0;a--)
				{
					pal_bright(a-1);
					delay(10);
					swap_screen();
				}
				delay(150);
				border(0);
				pal_bright(3);
				pal_select(PAL_GAMEOVER);
				draw_image(0,0,IMG_GAMEOVER);
				swap_screen();
				while(joystick()==0) vsync(); //for joystick
				sprites_start();
				border(1);
				clear_screen(1);
				title();
				game_begin(chr);
			}
			if(rm->triggers[triggernum].item_or_teleport==6)//конец
			{
				sprites_stop();
				pal_select(PAL_WIN);
				draw_image(0,0,IMG_WIN);
				swap_screen();
				draw_image(0,0,IMG_WIN);
				swap_screen();
				delay(150);
				noredraw=2;
				draw_text(rm,&end);
				noredraw=1;
				sprites_start();
				border(1);
				clear_screen(1);
				fade_to_black();
				title();
				game_begin(chr);
			}

			if(rm->triggers[triggernum].text_active!=0)
			{
				draw_text(rm,texts[rm->triggers[triggernum].text_active-1]);
			}
			if(rm->triggers[triggernum].act_walkable==1 )rm->triggers[triggernum].walkable=1-rm->triggers[triggernum].walkable;
		}
		else
		{
			
			if(rm->triggers[triggernum].text_wrong!=0 && fire!=0)
			{
				draw_text(rm,texts[rm->triggers[triggernum].text_wrong-1]);
			}
		}
		
		
		
		
		if(rm->triggers[triggernum].text_touch!=0 && rm->triggers[triggernum].text_touch_sayed==0)
		{
			draw_text(rm,texts[rm->triggers[triggernum].text_touch-1]);
			rm->triggers[triggernum].text_touch_sayed=1;
		}
	}
}
u8 check_triggers(struct room2 *rm,character *chr,struct room2 **rooms,struct room2 **curroom,u8 fire)
{
	u8 a,b;
	u8 str[3];
	//for(a=0;a<rm->count_triggers;a++)
	//{
		b=check_walkness(rm,0,1,chr->x,chr->y);
		if(b>1)
		{
			activate_trigger(rm,chr,rooms,curroom,b-5,fire);
		}
		else if(fire>0)
		{
			
			b=check_distance(rm,chr->x,chr->y);
			output_x=0;
			if(b>1)
			{
				//draw_text(rm,&testtxt);
				activate_trigger(rm,chr,rooms,curroom,b-5,fire);
			}
		}
	//}
	return 1;
}
void redraw_inventory(u8 length,u8 curpos,character *chr)
{
	u8 a,b,c,x;
	x=3;
	select_image(IMG_ITEMS);
	if(chr->count_items==0)
	{
		for(a=0;a<length;a++)
		{
			print_tile(x+a*4+a,3,0,4,4,1);
		}
	}
	else
	{
		output_x=5;
		output_y=10;
		//for(a=3;a<length+3;a++)
		for(a=0;a<length;a++)
		{
			c=3;
			if (chr->count_items<3)c=1;
			b=chr->inventory[(curpos+a+chr->count_items-c)%chr->count_items];
			print_tile(x+(a)*4+(a),3,items[b-2]->imgnum,4,4,1);
		}
		b=(curpos+3)%chr->count_items;
		put_str(items[chr->inventory[curpos]-2]->name);
		
	}
}
u8 inventory(struct room2 *rm,character* chr)
{
	u8 a,b,c;
	u8 exit;
	exit=0;
	c=0;
	a=1;
	b=0;
	sprites_stop();
	draw_image(0,0,IMG_INVENTORY);
	redraw_inventory(7,b,chr);
	swap_screen();
	//keyboard(keys);
	
	
	while(exit==0)
	{
		vsync(); //for joystick
		keyboard(keys);
		if (keys[KEY_ENTER]==KEY_DOWN)
		{
			exit=1;
			if(chr->count_items>0)
			{
				c=chr->inventory[b];
			}
			else
			{
				c=0;
			}
			//return(b+1);
		}
		if(joystick()!=0)
		{
			if(joystick()==JOY_LEFT)
			{
				if(b==0)b=chr->count_items;
				b--;
				draw_image(0,0,IMG_INVENTORY);
				redraw_inventory(7,b,chr);
				sample_play(SMP_INVENTORY);
				swap_screen();
			}
			if(joystick()==JOY_RIGHT)
			{
				b++;
				if(b==chr->count_items)b=0;
				draw_image(0,0,IMG_INVENTORY);
				redraw_inventory(7,b,chr);
				sample_play(SMP_INVENTORY);
				swap_screen();
			}
		}
	}
	pal_bright(0);
	draw_room(rm);
	swap_screen();
	draw_room(rm);
	sprites_start();
	fade_from_black();
	return c;
}
void main(void)
{
  
  static u8 i;
  static u8 xx,yy,a,b,c;
  static u8 palette[16];
  
  character james;
  //struct room2 rm;
  struct room2 *rooms[16];
  
  //rm.l1_elements=m1_l1_elements;
  title();
 
  border(1);
  curroom=ge_room(0);
  music_play(MUS_DIAMOND2);
  game_begin(&james);
/*for(a=0;a<57;a++)
  {
	draw_text(curroom,texts[a]);
  }*/
  c=0;
  
  while(1)
  {
	b=on_trig(curroom,james.x,0,james.x+1,james.y);
	if(b!=1)	set_sprite(2,curroom->triggers[b-5].x*8,curroom->triggers[b-5].y*16,48);
	else set_sprite(2,3,3,49);
  //vsync(); //for joystick
  if(joystick()==JOY_LEFT && james.x>0)
  {
	//if(on_trig(curroom,james.x,0,james.x+1,james.y)!=1)	set_sprite(2,3,3,48);
	//b=on_trig(curroom,james.x,0,james.x+1,james.y);
	//if(b!=1)	set_sprite(2,curroom->triggers[b-5].x*8,curroom->triggers[b-5].y*16,48);
	//else set_sprite(2,3,3,49);
    if(check_walkness(curroom,james.x,0,james.x-1,james.y)==1)james.x--;
    james.frame++;
    if(james.frame>=32)james.frame=0;
    james.napr=3;
	check_triggers(curroom,&james,rooms,&curroom,0);
  }
  if(joystick()==JOY_RIGHT&& james.x<(150))
  {

    //james.x++;
	//b=on_trig(curroom,james.x,0,james.x+1,james.y);
	//if(b!=1)	set_sprite(2,curroom->triggers[b-5].x*8,curroom->triggers[b-5].y*16,48);
	//else set_sprite(2,3,3,49);
    if(check_walkness(curroom,james.x,0,james.x+1,james.y)==1)james.x++;
    james.frame++;
    if(james.frame>=32)james.frame=0;
    james.napr=1;
	check_triggers(curroom,&james,rooms,&curroom,0);
  }
  if(joystick()==JOY_UP&& james.y>0)
  {

    //if(on_trig(curroom,james.x,0,james.x+1,james.y)!=1)	set_sprite(2,3,3,48);
	//b=on_trig(curroom,james.x,0,james.x+1,james.y);
	//if(b!=1)	set_sprite(2,curroom->triggers[b-5].x*8,curroom->triggers[b-5].y*16,48);
	//else set_sprite(2,3,3,49);
    if(check_walkness(curroom,james.x,0,james.x,james.y-1)==1)james.y--;
    james.frame++;
    if(james.frame>=30)james.frame=0;
    james.napr=4;
	check_triggers(curroom,&james,rooms,&curroom,0);
  }
  if(joystick()==JOY_DOWN&&james.y<184)
  {
    //if(on_trig(curroom,james.x,0,james.x+1,james.y)!=1)	set_sprite(2,3,3,48);
	//b=on_trig(curroom,james.x,0,james.x+1,james.y);
	//if(b!=1)	set_sprite(2,curroom->triggers[b-5].x*8,curroom->triggers[b-5].y*16,48);
	//else set_sprite(2,3,3,49);
    if(check_walkness(curroom,james.x,0,james.x,james.y+1)==1)james.y++;
    james.frame++;
    if(james.frame>=30)james.frame=0;
    james.napr=2;
	check_triggers(curroom,&james,rooms,&curroom,0);
  }
  if(joystick()==JOY_FIRE)
  {
	check_triggers(curroom,&james,rooms,&curroom,1);
	
  }
  keyboard(keys);
  if(keys[KEY_ENTER]==KEY_DOWN)
  {
	a=inventory(curroom,&james);
	if(a!=0)
	{
		check_triggers(curroom,&james,rooms,&curroom,a);
	}
  }
  if(james.napr==1)
  {
    set_sprite(0,james.x,james.y,16+james.frame/4);
    set_sprite(1,james.x,james.y+16,24+james.frame/4);
  }
  if(james.napr==3)
  {
    set_sprite(0,james.x,james.y,32+james.frame/4);
    set_sprite(1,james.x,james.y+16,40+james.frame/4);
  }
  if(james.napr==2)
  {
    set_sprite(0,james.x,james.y,4+james.frame/10);
    set_sprite(1,james.x,james.y+16,12+james.frame/10);
  }
  if(james.napr==4)
  {
    set_sprite(0,james.x,james.y,1+james.frame/10);
    set_sprite(1,james.x,james.y+16,9+james.frame/10);
  }
  
  swap_screen();
  }
}
