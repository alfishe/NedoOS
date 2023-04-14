#ifndef __SAVE_LOAD
#define __SAVE_LOAD

//save to disc
void save_best()
{
	u8 n, m;
	u16* p;
	
	for (n=0;n<9;n++)
		for (m=0;m<8;m++)
		{
			p=(u16*)(_SAVE_LOAD_BUF+(n*8)+m);
			*p=bestlist[n].name[m];
		}

	for (n=0;n<18;n+=2)
	{
		p=(u16*)(_SAVE_LOAD_BUF+(8*9)+n);
		*p=bestlist[n/2].scoreboard;
	}
}


// load of disc
void load_best()
{
	u8 n, m;
	u16* p;
	
	for (n=0;n<9;n++)
		for (m=0;m<8;m++)
		{
			p=(u16*)(_SAVE_LOAD_BUF+(n*8)+m);
			bestlist[n].name[m]=*p;
		}

	for (n=0;n<18;n+=2)
	{
		p=(u16*)(_SAVE_LOAD_BUF+(8*9)+n);
		bestlist[n/2].scoreboard=*p;
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