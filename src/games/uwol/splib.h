#include "sprites.h"
#define XWRAP 192

#ifndef FALSE
#define FALSE   0
#endif
#ifndef TRUE
#define TRUE    1
#endif
#ifndef NULL
#define NULL    0
#endif

/* sprite types */

#define sp_MASK_SPRITE	0x00

/* Colour Attributes */

#define TRANSPARENT		0x80

/* Clear Rectangle Flags */

#define sp_CR_TILES		0x01

/* Print String Struct Flags */

#define sp_PSS_INVALIDATE	0x01

/* SP's Sprite Struct */

struct sp_SS {
   u8 active;
   i16 ptr;
   i16 x;
   i16 y;
   u16 tile;
};

/* Small Rectangles with 8-bit coordinates (used by SP where units are characters) */

struct sp_Rect {
   u8 row_coord;     /* coordinate of top left corner */
   u8 col_coord;
   u8 height;        /* size */
   u8 width;
};

u8 sp_tile_buf[32*24];
u8 sp_attr_buf[32*24];

#define SPRITES_MAX	20

struct sp_SS spriteList[SPRITES_MAX];

u16 spriteBuf[SPRITES_MAX*4];


void sp_Init(void)
{
	i16 i;
	
	for(i=0;i<32*24;i++)
	{
		sp_tile_buf[i]=0;
		sp_attr_buf[i]=0;
	}
	
	for(i=0;i<SPRITES_MAX;i++) spriteList[i].active=FALSE;
	for(i=0;i<sizeof(spriteBuf);i++) spriteBuf[i]=0;

	set_sprite(0/*i*/,0,0,SPRITE_END);
	//sprites_start(); //при разрешённых спрайтах автоматически выполняется копирование выводимой графики в два экрана
}

void sp_AttrSet(i16 x,i16 y,u8 a)
{
	if(y<24) sp_attr_buf[(y<<5)+x]=a;
}

u8 sp_AttrGet(i16 x,i16 y)
{
	return (y<24?sp_attr_buf[(y<<5)+x]:0);
}

void sp_TileSet(i16 col,i16 row,u16 tile)
{
    draw_tile(col+4,row,tile);
}

/* background tiles */

void sp_PrintAtInv(u8 row, u8 col, u8 colour, u8 udg)
{
    i16 ptr;
    
    ptr=(row<<5)+col;
    sp_attr_buf[ptr]=colour;
    sp_tile_buf[ptr]=udg;
    //sp_TileSet(col,row,udg);
	draw_tile(col+4,row,udg);
}

void sp_GetTiles(struct sp_Rect *r, u8 *dest)
{
	u16 i,j,ptr;
	
	ptr=(r->row_coord<<5)+r->col_coord;
	
	for(i=0;i<r->height;i++)
	{
		for(j=0;j<r->width;j++)
		{
			*dest++=sp_tile_buf[ptr++];
		}
		ptr+=(32-r->width);
	}
}

void sp_PutTiles(struct sp_Rect *r, u8 *src)
{
	u16 i,j,ptr;
	
	ptr=(r->row_coord<<5)+r->col_coord;
	
	for(i=0;i<r->height;i++)
	{
		for(j=0;j<r->width;j++)
		{
			sp_tile_buf[ptr]=*src++;
			sp_TileSet(r->col_coord+j,r->row_coord+i,sp_tile_buf[ptr++]);
		}
		ptr+=(32-r->width);
	}
}

/* sprites */

struct sp_SS *sp_CreateSpr(u8 type, u8 rows, u16 graphic, u8 plane, u8 extra)
{
	u16 i;
	
	for(i=0;i<SPRITES_MAX;i++)
	{
		if(!spriteList[i].active)
		{
		    spriteList[i].active=TRUE;
		    spriteList[i].ptr=i;
		    spriteList[i].x=0;
		    spriteList[i].y=0;
		    spriteList[i].tile=graphic;
		    return &spriteList[i];
    	}
    }
    
    return NULL;
}

void sp_MoveSprAbs(struct sp_SS *sprite, struct sp_Rect *clip, u16 animate, u8 row, u8 col, u8 hpix, u8 vpix)
{
	if(sprite)
	{
		//if(animate<33+16) animate+=PALETTE_NUM(1);
		if(row<24)
		{
			sprite->x=(col<<3)+hpix/*+(col?128:0)*/;
			sprite->y=(row<<3)+vpix/*+(col?128+16:0)*/;
		}
		sprite->tile=animate;
	}
}

void sp_DeleteSpr(struct sp_SS *sprite)
{
	if(sprite)
	{
		sprite->active=FALSE;
	}
}

/* updater */

void sp_UpdateNow(void)
{
	u16 i,cnt;
	u8 x,y;
	u16 tile;
	//u16 link;
	//u16 *buf;
	
	cnt=0;
/*	
	link=1;
	buf=spriteBuf;
	for(i=0;i<SPRITES_MAX;i++) if(spriteList[i].active) cnt++;
	
	if(!cnt)
	{
		*buf++=0;
		*buf++=0;
		*buf++=0;
		*buf++=0;
	}
*/	
	for(i=0;i<SPRITES_MAX;i++)
	{
        if(!spriteList[i].active) continue;
        /*cnt--;
        if(cnt==0) link=0;
        *buf++=spriteList[i].y;
        *buf++=0x0500|link;
        *buf++=spriteList[i].tile;
        *buf++=spriteList[i].x;
        link++;*/
		x = spriteList[i].x>>1;
		if(x)
		{
			y = spriteList[i].y;
			tile = spriteList[i].tile;
			set_sprite(cnt,16+x,y,tile);
			cnt++;
			if(x<32)
			{
				//set_sprite(cnt,(16+(XWRAP/2))+x,y,tile);
				//cnt++;
				set_sprite(cnt,32-8,y,blacksquare);
				cnt++;
				//set_sprite(cnt,32+(XWRAP/2),y,blacksquare);
				//cnt++;
			}
			else if(x>(16+(XWRAP/2)-8))
			{
				//set_sprite(cnt,(16-(XWRAP/2))+x,y,tile);
				//cnt++;
				//set_sprite(cnt,32-8,y,blacksquare);
				//cnt++;
				set_sprite(cnt,(u8)(32+(XWRAP/2)),y,blacksquare);
				cnt++;
			}
		}
	}
	set_sprite(cnt,0,0,SPRITE_END);

	swap_screen();
 	vsync();
	//update_palette();
	//vram_copy(SPRITES_ADR,spriteBuf,sizeof(spriteBuf));
}

void sp_ClearRect(struct sp_Rect *area, u8 colour, u8 udg, u8 flags)
{
	u16 i,j;
	
	for(i=0;i<24;i++)
	{
		for(j=0;j<32;j++)
		{
			sp_PrintAtInv(i,j,0,0);
		}
	}
}

/* additional stuff */

void sp_HideAllSpr(void)
{
	u16 i;
	
	for(i=0;i<SPRITES_MAX;i++)
	{
		if(spriteList[i].active)
		{
			spriteList[i].x=0;
			spriteList[i].y=0;
		}
		//spriteList[i].active=FALSE;
	}
	sp_UpdateNow();
}

void sp_DelAllSpr(void)
{
	u16 i;
	
	for(i=0;i<SPRITES_MAX;i++)
	{
		spriteList[i].active=FALSE;
	}
	//sp_UpdateNow();
}
