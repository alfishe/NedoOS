#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <intrz80.h>
#include <terminal.c>
	unsigned char trdBuf[8192];
	unsigned char fileName[256];
	struct diskOp readParam;
	unsigned char argLng;
void interface (void)
{
char fnPos;
	fnPos = (41-9-argLng)/2 + 20;
	BOX(20, 5, 41, 1, 47);
    ATRIB(34);
	AT (21,5);
	printf("RDTRD2 Make TRD images from floppy disk");
	BOX(20, 6, 41, 6, 44);
	ATRIB(37);
	AT (fnPos,7);
	printf("filename:");
	printf(fileName);
	AT (23,9);
	printf("[.................................]");
	AT (34,11);
	printf("[ESC - Exit]");
}

void pBar( char procent)
{
float lng;
char cycle;
AT (24,9);
lng = (float)33 / (float)100 * (float)procent;
for (cycle = 0; cycle < lng; cycle++)
{
	putchar(219);
}
}

C_task main (int argc, char *argv[]) 
{
	unsigned int cycle;
	unsigned long secTmp;
	unsigned int result;
	unsigned char argPos;
	char prgPrc;
	unsigned char key;


	FILE *fp1;
	os_initstdio();
	if (argc < 2)
	{
		argv[1] = "noname.trd\0";
	}
	
	argPos =0;
	fileName[255] = '\0';
	
while (argv[1][argPos] != '\0')
	{
	fileName[argPos] = argv[1][argPos];
	argPos++;
	}	
	argLng = strlen(fileName);
	interface();
	fp1 = OS_CREATEHANDLE(argv[1], 0x80);
    if (((int)fp1) & 0xff)
    {
      printf (argv[1]);
	  printf(" creating error\r\n");
	  exit(0);
	}
	readParam.drive		= 0;
	readParam.BufAdr 	= &trdBuf;
	readParam.sector 	= 0;
	readParam.count 	= 32;
	
	
	
	for (cycle = 0; cycle < 80; cycle++)
	{
	secTmp = cycle * (unsigned long)8192/256;
	readParam.sector = secTmp;
	result = OS_READSECTORS (&readParam);
	OS_WRITEHANDLE(trdBuf, fp1, 8192);
	prgPrc = cycle * 1.25;
	if (prgPrc % 5 == 0)	pBar(prgPrc);
	key = _low_level_get();
	}
		if (key == 27)
	{
		OS_CLOSEHANDLE(fp1);
		exit(0);
	}
	OS_CLOSEHANDLE(fp1);
	return 0;
}   

/*Если количество параметров неопределённо (printf(...) и т.п.), то все параметры передаются через стек. Иначе первый параметр передаётся в E, DE, CDE или BCDE, в зависимости от разрядности значения. Если первый и второй параметры не шире 16 бит каждый, то второй параметр передаётся в регистрах B или BC, иначе через стек. Возвращаемое значение из функции передаётся в регистрах A (L при банкинге), HL, CHL или BCHL, в зависимости от разрядности значения.
Сохранять надо ix и iy обязательно.
DE и  BC сохранять если они не юзаются в качестве параметров
*/
