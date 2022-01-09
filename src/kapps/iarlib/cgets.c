#include <oscalls.h>
#include <stdio.h>
#include <string.h>

union{
	unsigned int w;
	struct{
		unsigned char x;
		unsigned char y;
	}xy;
}cxy;

char * gets(char *str)  {
	char * pstr;
	char curs = 0;
	char ch;
	cxy.w = OS_GETXY();
	*str=0x00;
	while(1)
	{
		OS_SETXY(cxy.xy.x,cxy.xy.y);
		pstr=str;
		while(*pstr) putchar(*pstr++);
		putchar(' ');
		OS_SETXY(cxy.xy.x+curs,cxy.xy.y);
		OS_PRATTR(INK_WHITE|PAPER_CYAN);
		ch=getchar();
		OS_PRATTR(INK_WHITE|PAPER_BLACK);
		switch(ch){
			case 0x0d:
				putchar(0x0a);
				return str;
			case 0x08:
				if(curs){
					strcpy(str + curs - 1,str + curs);
					curs--;
				}
				break;
			case 0xf8:
				if(curs)curs--;
				break;
			case 0xfb:
				if(*(str+curs))curs++;
				break;
			default:
				pstr = str + strlen(str+curs) + curs;
				if(((pstr - str) + cxy.xy.x)!=78){
					while(1){
						pstr[1]=pstr[0];
						if(pstr==(str+curs)) break;
						pstr--;
					}
					*(str+curs) = ch;
					curs++;
				}
				break;
		}
	}
	return str;
}