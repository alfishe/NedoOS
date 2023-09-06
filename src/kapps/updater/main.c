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

unsigned char is_atm;
unsigned long contLen;
unsigned char saveFlag, saveBak;
unsigned char crlf[2] = {13, 10};
unsigned long bytecount, downloaded;
unsigned char status, key, curFormat;
struct sockaddr_in targetadr;
struct readstructure readStruct;
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
unsigned int bufSize = 1500;
unsigned char netbuf[4000];

void clearStatus(void)
{
	AT(1, 24);
	printf("                                                                                ");
}

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

void delay(unsigned long counter)
{
	unsigned long start, finish;
	counter = counter / 20;
	if (counter < 1)
	{
		counter = 1;
	}
	start = time();
	finish = start + counter;

	while (start < finish)
	{
		start = time();
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

void infoBox(unsigned char *message)
{
	strcpy(cw.tittle, "nedoOS system updater 0.1");

	if (strlen(message) > strlen(cw.tittle))
	{
		cw.w = strlen(message) + 2;
	}
	else
		cw.w = strlen(cw.tittle) + 2;
	cw.x = 80 / 2 - cw.w / 2;
	cw.y = 15;
	cw.h = 4;
	cw.text = 97;
	cw.back = 42;

	drawWindow(cw);
	AT(cw.x + 2, cw.y + 3);
	printf(message);
	AT(1, 1);
}

unsigned char OS_SHELL(unsigned char *command)
{
	FILE *fp2;
	unsigned char fileName[] = "cmd.com";
	unsigned char appCmd[128] = "cmd.com ";
	unsigned int shellSize, loaded, loop;
	unsigned char pgbak;
	union APP_PAGES shell_pg;
	union APP_PAGES main_pg;
	unsigned char curPath[256];
	main_pg.l = OS_GETMAINPAGES();
	pgbak = main_pg.pgs.window_0;
	OS_GETPATH((unsigned int)&curPath);
	strcat(appCmd, command);
	strcat(appCmd, "\0");
	OS_SETSYSDRV();
	fp2 = OS_OPENHANDLE(fileName, 0x80);
	if (((int)fp2) & 0xff)
	{
		AT(1, 24);
		printf(fileName);
		printf(" not found.               ");
		exit(0);
	}
	shellSize = OS_GETFILESIZE(fp2);
	OS_CHDIR((unsigned int)&curPath);
	OS_NEWAPP((unsigned int)&shell_pg);
	SETPG32KHIGH(shell_pg.pgs.window_3);
	memcpy((char *)(0xC080), &appCmd, sizeof(appCmd));
	for (loop = 0; loop < shellSize; loop = loop + loaded)
	{
		loaded = OS_READHANDLE(netbuf, fp2, bufSize);
		memcpy((char *)(0xC100 + loop), &netbuf, loaded);
	}
	OS_CLOSEHANDLE(fp2);
	clearStatus();
	AT(1, 24);
	printf("Running shell [pId:%u][%s][%s]", shell_pg.pgs.pId, curPath, command);
	YIELD();
	delay(250);
	SETPG32KHIGH(pgbak);
	OS_RUNAPP(shell_pg.pgs.pId);
	OS_WAITPID(shell_pg.pgs.pId);
	return shell_pg.pgs.pId;
}

// #include <network.c>

void errorPrint(unsigned int error)
{
	clearStatus();
	AT(1, 24);
	switch (error)
	{
	case 2:
		printf("02 SHUT_RDWR");
		break;
	case 4:
		printf("04 ERR_INTR");
		break;
	case 23:
		printf("23 ERR_NFILE");
		break;
	case 35:
		printf("35 ERR_EAGAIN");
		break;
	case 37:
		printf("37 ERR_ALREADY");
		break;
	case 38:
		printf("38 ERR_NOTSOCK");
		break;
	case 40:
		printf("40 ERR_EMSGSIZE");
		break;
	case 41:
		printf("41 ERR_PROTOTYPE");
		break;
	case 47:
		printf("47 ERR_AFNOSUPPORT");
		break;
	case 53:
		printf("53 ERR_ECONNABORTED");
		break;
	case 54:
		printf("54 ERR_CONNRESET");
		break;
	case 57:
		printf("57 ERR_NOTCONN");
		break;
	case 65:
		printf("65 ERR_HOSTUNREACH");
		break;
	default:
		printf("[%u] UNKNOWN ERROR", error);
		break;
	}
	YIELD();
	do
	{
		key = _low_level_get();
	} while (key == 0);
}

unsigned char OpenSock(unsigned char family, unsigned char protocol)
{
	unsigned char socket;
	unsigned int todo;
	todo = OS_NETSOCKET((family << 8) + protocol);
	if (todo > 32767)
	{
		clearStatus();
		AT(1, 24);
		printf("OS_NETSOCKET: ");
		errorPrint(todo & 255);
		exit(0);
	}
	else
	{
		socket = ((todo & 65280) >> 8);
	}
	return socket;
}

unsigned char netConnect(unsigned char socket)
{
	unsigned int todo;

	targetadr.family = AF_INET;
	targetadr.porth = 00;
	targetadr.portl = 80;
	targetadr.b1 = 31;
	targetadr.b2 = 31;
	targetadr.b3 = 65;
	targetadr.b4 = 35;

	todo = OS_NETCONNECT(socket, &targetadr);
	if (todo > 32767)
	{
		clearStatus();
		AT(1, 24);
		printf("OS_NETCONNECT: ");
		errorPrint(todo & 255);
		exit(0);
	}
	return 0;
}

unsigned int tcpRead(unsigned char socket)
{
	unsigned char retry = 100;
	unsigned int err, todo;
	readStruct.socket = socket;
	readStruct.BufAdr = (unsigned int)&netbuf;
	readStruct.bufsize = bufSize;
	readStruct.protocol = SOCK_STREAM;
wizread:
	todo = OS_WIZNETREAD(&readStruct);
	if (todo > 32767)
	{
		if (retry == 0)
		{
			err = todo & 255;
			clearStatus();
			AT(1, 24);
			printf("OS_WIZNETREAD: ");
			errorPrint(err);

			if (err == 35)
			{
				return 0;
			}
			fatalError("ERROR CONNECTION TO SERVER");
		}
		retry--;
		YIELD();
		YIELD();
		delay(300);
		YIELD();
		YIELD();
		goto wizread;
	}
	return todo;
}

unsigned int netShutDown(unsigned char socket)
{
	unsigned int todo;
	todo = OS_NETSHUTDOWN(socket);
	if (todo > 32767)
	{
		printf("OS_NETSHUTDOWN: ");
		errorPrint(todo & 255);
		return 255;
	}

	return 0;
}

unsigned int cutHeader(unsigned int todo)
{
	unsigned int q, headlng;
	unsigned char *count;
	count = strstr(netbuf, "Content-Length:");
	if (count == NULL)
	{
		clearStatus();
		AT(1, 24);
		printf("Content-Length:  not found.");
		contLen = 0;
	}
	else
	{
		contLen = atol(count + 15);
		bytecount = contLen;
		//    AT (1,24);
		//      printf("=> Dlinna  soderzhimogo = %lu \n\r", bytecount);
	}

	count = strstr(netbuf, "\r\n\r\n");
	headlng = ((unsigned int)count - (unsigned int)netbuf + 4);
	q = todo - headlng;
	memcpy(&netbuf, count + 4, q);
	return q;
}

unsigned char saveBuf(unsigned char *fileNamePtr, unsigned char operation, unsigned int sizeOfBuf)
{
	unsigned char fileName[255];

	if (operation == 00)
	{
		strcpy(fileName, fileNamePtr);
		fp2 = OS_CREATEHANDLE(fileName, 0x80);
		if (((int)fp2) & 0xff)
		{
			clearStatus();
			AT(1, 24);
			printf(fileName);
			printf(" creating error.");
			exit(0);
		}
		OS_CLOSEHANDLE(fp2);
		fp2 = OS_OPENHANDLE(fileName, 0x80);
		if (((int)fp2) & 0xff)
		{
			clearStatus();
			AT(1, 24);
			printf(fileName);
			printf(" opening error.");

			exit(0);
		}
		AT(1, 24);
		return 0;
	}

	if (operation == 01)
	{
		OS_WRITEHANDLE(netbuf, fp2, sizeOfBuf);
		downloaded = downloaded + sizeOfBuf;
		return 0;
	}

	if (operation == 02)
	{
		OS_CLOSEHANDLE(fp2);
		return 0;
	}
	return 0;
}

unsigned int tcpSend(unsigned char socket, unsigned int messageadr, unsigned int size)
{
	unsigned char retry = 20;
	unsigned int todo;
	readStruct.socket = socket;
	readStruct.BufAdr = messageadr;
	readStruct.bufsize = size;
	readStruct.protocol = SOCK_STREAM;

wizwrite:
	todo = OS_WIZNETWRITE(&readStruct);
	if (todo > 32767)
	{
		clearStatus();
		AT(1, 24);
		printf("OS_WIZNETWRITE: ");
		errorPrint(todo & 255);
		if (retry == 0)
		{
			exit(0);
		}
		retry--;
		YIELD();
		delay(250);
		goto wizwrite;
	}

	return todo;
}
unsigned char getFile(unsigned char *fileLink, unsigned char *fileNamePtr)
{
	unsigned int todo;
	unsigned char cmdlist1[] = " HTTP/1.1\r\nHost: nedoos.ru\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)\r\n\r\n\0";
	unsigned char socket;
	unsigned int bytes2read, headskip;
	strcpy(netbuf, "GET ");
	strcat(netbuf, fileLink);
	strcat(netbuf, cmdlist1);
	clearStatus();
	socket = OpenSock(AF_INET, SOCK_STREAM);
	todo = netConnect(socket);
	todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf));
	headskip = 0;
	bytecount = 255;
	downloaded = 0;
	saveBuf(fileNamePtr, 00, 0);
	while (bytecount != 0)
	{
		todo = tcpRead(socket);
		if (todo == 0)
		{
			break;
		}
		bytes2read = todo;
		if (headskip == 0)
		{
			headskip = 1;
			bytes2read = cutHeader(todo);
		}
		AT(1, 24);
		printf(" Downloaded %lu of %lu kb", downloaded / 1024, contLen / 1024);

		saveBuf(fileNamePtr, 01, bytes2read);
		bytecount = bytecount - bytes2read;

		key = _low_level_get();
		if (key == 27)
		{
			saveBuf(fileNamePtr, 02, 00);
			fatalError("File download aborted!");
		}
	}
	saveBuf(fileNamePtr, 02, 00);
	netShutDown(socket);
	return 0;
}

////////////////////////////////////////////////////

C_task main(int argc, char *argv[])
{
	unsigned char kernelName[32];
	unsigned char machineName[32];
	unsigned char kernelLink[256];
	unsigned char sysLetter;
	unsigned int errn;
	unsigned char binLink[] = "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fbin%2F&isdir=1";
	os_initstdio();
	BOX(1, 1, 80, 25, 40, 176);
	cw.x = 20;
	cw.y = 5;
	cw.w = 40;
	cw.h = 10;
	cw.text = 97;
	cw.back = 44;
	strcpy(cw.tittle, "nedoOS updater 0.1");

	OS_SETSYSDRV();
	errn = OS_CHDIR((unsigned int)&"..");

	is_atm = (unsigned char)OS_GETCONFIG();
	// H=system drive, L= 1-Evo 2-ATM2 3-ATM3 6-p2.666 ;E=pgsys(system page) D= TR-DOS page
	switch ((is_atm))
	{
	case 1:
		strcpy(machineName, "ZX-Evolution");
		strcpy(kernelName, "sd_boot.$C");
		strcpy(kernelLink, "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fsd_boot.%24C");
		break;
	case 2:
		strcpy(machineName, "TURBO 2+");
		strcpy(kernelName, "osatm2hd.$C");
		strcpy(kernelLink, "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fosatm2hd.%24C");

		break;

	case 3: // SD HDD versions
		strcpy(machineName, "TURBO 3 [SD]");
		strcpy(kernelName, "osatm3hd.$C");
		strcpy(kernelLink, "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fosatm3hd.%24C");
		break;
	case 6: // SD HDD versions
		strcpy(machineName, "P2.666 [SD]");
		strcpy(kernelName, "osp26sd.$C");
		strcpy(kernelLink, "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fosp26sd.%24C");
		break;

	default:
		strcpy(machineName, "NOT DETECED (ZX-Evo)");
		strcpy(kernelName, "sd_boot.$C");
		strcpy(kernelLink, "/svn/dl.php?repname=NedoOS&path=%2Frelease%2Fsd_boot.%24C");
		break;
	}
	strcat(cw.tittle, " (");
	strcat(cw.tittle, machineName);
	strcat(cw.tittle, ")");
	drawWindow(cw);

	OS_SETSYSDRV();
	errn = OS_CHDIR((unsigned int)&"..");

	OS_DELETE((unsigned int)&"bin.zip");
	OS_DELETE((unsigned int)&"bin.tar");
	OS_DELETE((unsigned int)&"bin.old");
	OS_DELETE((unsigned int)&"bin.r17");
	OS_DELETE((unsigned int)&"bin.r18");
	OS_DELETE((unsigned int)&"bin.r19");	
	OS_DELETE((unsigned int)&"bin.r20");
	
	clearStatus();
	AT(cw.x + 2, cw.y + 3);
	printf("Downloading file: bin.zip");

	errn = getFile(binLink, "bin.zip"); //  Downloading the file
	if (downloaded != contLen)
	{
		fatalError("File download error!");
	}

	BOX(1, 1, 80, 25, 40, 32);
	AT(1, 1);
	OS_SHELL("pkunzip.com bin.zip");

	BOX(1, 1, 80, 25, 40, 176);
	drawWindow(cw);

	ATRIB(cw.text);
	ATRIB(cw.back);
	AT(cw.x + 2, cw.y + 3);
	printf("Renaming bin.r?? to bin.tar");

	errn = OS_RENAME((unsigned int)&"bin.r17", (unsigned int)&"bin.tar");
	errn = OS_RENAME((unsigned int)&"bin.r18", (unsigned int)&"bin.tar");
	errn = OS_RENAME((unsigned int)&"bin.r19", (unsigned int)&"bin.tar");
	errn = OS_RENAME((unsigned int)&"bin.r20", (unsigned int)&"bin.tar");

	ATRIB(cw.text);
	ATRIB(cw.back);
	AT(cw.x + 2, cw.y + 4);
	printf("Untaring bin.tar, please wait");

	OS_SHELL("tar.com bin.tar");

	ATRIB(cw.text);
	ATRIB(cw.back);
	AT(cw.x + 2, cw.y + 5);
	printf("Backuping old bin to bin.old");

	OS_SHELL("ren bin bin.old");

	ATRIB(cw.text);
	ATRIB(cw.back);
	AT(cw.x + 2, cw.y + 6);
	printf("Renaming new bin directory.");
	errn = OS_RENAME((unsigned int)&"bin.r17", (unsigned int)&"bin");
	errn = OS_RENAME((unsigned int)&"bin.r18", (unsigned int)&"bin");

	ATRIB(cw.text);
	ATRIB(cw.back);
	AT(cw.x + 2, cw.y + 7);
	printf("Deleting zip&tar");

	OS_SHELL("del bin.zip");
	OS_SHELL("del bin.tar");

	clearStatus();
	AT(cw.x + 2, cw.y + 8);
	printf("Downloading file: %s",kernelName);
	errn = getFile(kernelLink, "kernel.tmp"); //  Downloading the file
	if (downloaded != contLen)
	{
		fatalError("File download error!");
	}

	ATRIB(cw.text);
	ATRIB(cw.back);
	AT(cw.x + 2, cw.y + 9);
	printf("Updating kernel[%s]", kernelName);

	OS_DELETE((unsigned int)&kernelName);
	strcpy(kernelLink, "ren kernel.tmp ");
	strcat(kernelLink, kernelName);
	OS_SHELL(kernelLink);

	infoBox("System Updated successfully");
	getchar();
	ATRIB(40);
	ATRIB(32);
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
*/