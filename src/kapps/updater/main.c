#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <stdlib.h>
#include <oscalls.h>
#include <terminal.c>
#include <tcp.h>
#include <osfs.h>
#include <intrz80.h>
#include <ctype.h>
#include <math.h>

unsigned char netbuf[1452];
unsigned char crlf[2] = {13, 10};
unsigned long bytecount, downloaded;
unsigned char status, key, curFormat;
struct sockaddr_in targetadr;
struct readstructure readStruct;
unsigned long contLen;
long count;
unsigned char saveFlag, saveBak, rptFlag;
unsigned char logFlag = 0;
FILE *fp2;

struct window
{
	unsigned char x;
	unsigned char y;
	unsigned char w;
	unsigned char h;
	unsigned char text;
	unsigned char back;
	unsigned char tittle[80];

} cw;

void printTable(void)
{
	unsigned int cycle;
	// OS_RENAME((unsigned int)&"doc",(unsigned int)&"doc.new");

	for (cycle = 32; cycle < 256; cycle++)
	{
		printf("%03u:", cycle);
		putchar(cycle);
		printf(" ");
		if (cycle % 10 == 0)
		{
			printf("\r\n");
		}
	}
}

void drawWindow(struct window w)
{
	unsigned char wcount, tempx, tittleStart;

	AT(w.x, w.y - 1);
	tittleStart = w.x + (w.w / 2) - (strlen(w.tittle) / 2) + 1;
	BOX(w.x, w.y, w.w + 1, w.h, w.back, 32);
	AT(w.x, w.y);
	ATRIB(w.text);
	putchar(201);
	for (wcount = 0; wcount < w.w; wcount++)
	{
		putchar(205);
	}
	putchar(187);

	AT(w.x, w.y + w.h);
	putchar(200);
	for (wcount = 0; wcount < w.w; wcount++)
	{
		putchar(205);
	}
	putchar(188);

	tempx = w.x + w.w + 1;
	for (wcount = 1; wcount < w.h; wcount++)
	{
		AT(w.x, w.y + wcount);
		putchar(186);
		AT(tempx, w.y + wcount);
		putchar(186);
	}

	AT(w.x, w.y + 2);
	putchar(199);
	for (wcount = 0; wcount < w.w; wcount++)
	{
		putchar(196);
	}
	putchar(182);

	AT(tittleStart, w.y + 1);
	printf("%s", w.tittle);
}

void fatalError(unsigned char *message)
{
	strcpy(cw.tittle, "FATAL ERROR!");

	if (strlen(message) > strlen(cw.tittle))
	{
		cw.w = strlen(message) + 2;
	}
	else
		cw.w = strlen(cw.tittle) + 2;
	cw.x = 80 / 2 - cw.w / 2;
	cw.y = 11;
	cw.h = 4;
	cw.text = 97;
	cw.back = 41;

	drawWindow(cw);
	AT(cw.x + 2, cw.y + 3);
	printf(message);
	AT(1, 1);
	getchar();
	exit(0);
}

unsigned char OS_SHELL(unsigned char *command)
{
	FILE *fp2;
	unsigned char fileName[] = "cmd.com";
	unsigned char appCmd[128] = "cmd.com ";
	unsigned long shellSize, loaded, loop;
	unsigned char pgbak;
	union APP_PAGES shell_pg;
	union APP_PAGES main_pg;
	unsigned char curPath[256];

	OS_GETPATH((unsigned int)&curPath);

	strcat(appCmd, command);
	shell_pg.l = OS_GETMAINPAGES();
	pgbak = main_pg.pgs.window_0;
	loaded = 0;
	OS_SETSYSDRV();
	fp2 = OS_OPENHANDLE(fileName, 0x80);
	if (((int)fp2) & 0xff)
	{
		AT(1, 25);
		printf(fileName);
		printf(" not found.               ");
		exit(0);
	}
	shellSize = OS_GETFILESIZE(fp2);
	//OS_CHDIR((unsigned int)&curPath);
	OS_NEWAPP((unsigned int)&shell_pg);
	SETPG32KHIGH(shell_pg.pgs.window_3);
	memcpy((char *)(0xC080), &appCmd, sizeof(appCmd));
	for (loop = 0; loop < shellSize; loop = loop + loaded)
	{
		loaded = OS_READHANDLE(netbuf, fp2, sizeof(netbuf));
		memcpy((char *)(0xC100 + loop), &netbuf, loaded);
	}
	OS_CLOSEHANDLE(fp2);
	AT(1, 1);
	printf("Running shell [%s][%s] ", curPath, command);
	OS_RUNAPP(shell_pg.pgs.pId);
	OS_WAITPID(shell_pg.pgs.pId);
	SETPG32KHIGH(pgbak);
	return shell_pg.pgs.pId;
}

#include <network.c>

C_task main(int argc, char *argv[])
{
	unsigned char key;
	unsigned int errn;
	unsigned long test, count;
	os_initstdio();
	BOX(1, 1, 80, 25, 40, 176);
	cw.x = 20;
	cw.y = 5;
	cw.w = 40;
	cw.h = 15;
	cw.text = 97;
	cw.back = 44;
	strcpy(cw.tittle, "nedoOS system updater 0.1");
	drawWindow(cw);
	AT(cw.x + 1, cw.y + 3);
	printf("File:bin.zip Downloaded:");

	OS_SETSYSDRV();
	OS_CHDIR((unsigned int)&"../downloads");
	OS_SHELL("dir");
	
	fatalError("LETS JUMP!");
	// OS_DELETE((unsigned int)&"bin.zip");

	errn = getFile("bin.zip"); // Downloading the file
	if (downloaded != contLen)
	{
		fatalError("File download error!");
	}

	AT(cw.x + 1, cw.y + 5);
	printf("Download finished.");

	do
	{
		key = _low_level_get();
	} while (key == 0);
	exit(0);
}

/*
[BIN]
[DOC]
[NEDODEMO]
[NEDOGAME]
[kernel]



Clean install
 - Переименовать выбранные папки
 - Создать новые папки
 - Скачать архив выбранной папки
 - Распаковать все содержимое.
Clean install config restore
 - восстановление из old конфигов



http://svn.zxevo.ru/filedetails.php?repname=pentevo&path=%2Fcfgs%2Fstandalone_base_trdemu%2Ftrunk%2Fzxevo_fw.bin

http://nedoos.ru/svn/filedetails.php?repname=NedoOS&path=%2Frelease%2F&#a624589277887c546d3fb998aee08482f

http://nedoos.ru/svn/filedetails.php?repname=NedoOS&path=%2Frelease%2Fdoc%2F3ws.txt

http://nedoos.ru/svn/dl.php?repname=NedoOS&path=%2Frelease%2F&isdir=1&rev=1766&peg=1766

http://nedoos.ru/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fbin%2F&isdir=1

*/