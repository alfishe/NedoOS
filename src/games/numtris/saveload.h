#ifndef __SAVE_LOAD
#define __SAVE_LOAD

void SaveBest()
{
	u8 n, m;
	u16* p;
	
	for (n=0;n<8;n++)
		for (m=0;m<8;m++)
		{
			p=(u16*)(53248+(n*8)+m);
			*p=best[n].name[m];
		}

	for (n=0;n<16;n+=2)
	{
		p=(u16*)(53248+64+n);
		*p=best[n/2].scoreboard;
	}
}

void LoadBest()
{
	u8 n, m;
	u16* p;
	
	for (n=0;n<8;n++)
		for (m=0;m<8;m++)
		{
			p=(u16*)(53248+(n*8)+m);
			
			best[n].name[m]=*p;
		}

	for (n=0;n<16;n+=2)
	{
		p=(u16*)(53248+64+n);
		best[n/2].scoreboard=*p;
	}
}

void load_from_file(u8 *filename)
{
__asm
	jp _LOAD_FROM_FILE
__endasm;
}


void save_to_file(u8 *filename)
{
__asm
	jp _SAVE_TO_FILE
__endasm;
}

#endif