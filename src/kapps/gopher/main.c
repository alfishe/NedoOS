#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <stdlib.h>
#include <oscalls.h>
#include <../common/terminal.c>
#include <tcp.h>
#include <osfs.h>
#include <intrz80.h>
#include <ctype.h>
#include <math.h>

#define true 1
#define false 0
#define screenHeight 23
#define screenWidth 80

FILE *fp2;

unsigned char netDriver = 0;

unsigned char uVer[] = "00.01";
unsigned char curDomain[] = "kulich.tplinkdns.com";
unsigned char curPath[128];
unsigned char cmd[128];
unsigned int pageOffsets[128];
unsigned char curLetter;
unsigned char oldBinExt;
unsigned int errn, headlng;
unsigned long contLen;
unsigned char saveFlag, saveBak;
unsigned char crlf[2] = {13, 10};

unsigned char status, curFormat;

struct sockaddr_in targetadr;
struct readstructure readStruct;
struct sockaddr_in dnsaddress;

struct LinkStruct
{
	unsigned char type;
	unsigned char nexType;
	unsigned char path[512];
	unsigned char host[64];
	unsigned int port;
} link;

struct mouseStruct
{
	char lmb;
	char rmb;
	char mmb;
	char wheel;
	char mouseXpos;
	char mouseYpos;
	char cursXpos;
	char cursYpos;
	char prevMouseButtons;
	char prevMouseMove;
	char oldAtr;
} mouse;

struct navigationStruct
{
	unsigned int page;
	unsigned int maxPage;
	unsigned int linePage;
	unsigned int lineSelect;
	unsigned int prevLineSelect;
	unsigned int bufPos;
	unsigned int nextBufPos;
} navi;

struct window
{
	unsigned char x;
	unsigned char y;
	unsigned char w;
	unsigned char h;
	unsigned char text;
	unsigned char back;
	unsigned char tittle[80];

} curWin;

unsigned char netbuf[32768];

void spaces(unsigned char number)
{
	while (number > 0)
	{
		putchar(' ');
		number--;
	}
}

void clearStatus(void)
{
	OS_SETCOLOR(5);
	OS_SETXY(0, 24);
	spaces(79);
	printf("\r");
}

void printTable(void)
{
	unsigned int cycle;

	for (cycle = 1; cycle < 256; cycle++)
	{
		OS_SETCOLOR(7);
		printf("%03u:", cycle);
		OS_SETCOLOR(71);
		putchar(cycle);
		OS_SETCOLOR(7);
		printf(" ");
		if (cycle % 12 == 0)
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

	OS_SETXY(w.x, w.y - 1);
	tittleStart = w.x + (w.w / 2) - (strlen(w.tittle) / 2) + 1;
	BOX(w.x, w.y, w.w + 1, w.h, w.back, 32);
	OS_SETXY(w.x, w.y);
	ATRIB(w.text);
	putchar(201);
	for (wcount = 0; wcount < w.w; wcount++)
	{
		putchar(205);
	}
	putchar(187);

	OS_SETXY(w.x, w.y + w.h);
	putchar(200);
	for (wcount = 0; wcount < w.w; wcount++)
	{
		putchar(205);
	}
	putchar(188);

	tempx = w.x + w.w + 1;
	for (wcount = 1; wcount < w.h; wcount++)
	{
		OS_SETXY(w.x, w.y + wcount);
		putchar(186);
		OS_SETXY(tempx, w.y + wcount);
		putchar(186);
	}

	OS_SETXY(w.x, w.y + 2);
	putchar(199);
	for (wcount = 0; wcount < w.w; wcount++)
	{
		putchar(196);
	}
	putchar(182);

	OS_SETXY(tittleStart, w.y + 1);
	printf("%s", w.tittle);
}

void fatalError(unsigned char *message)
{
	strcpy(curWin.tittle, "FATAL ERROR!");

	if (strlen(message) > strlen(curWin.tittle))
	{
		curWin.w = strlen(message) + 2;
	}
	else
		curWin.w = strlen(curWin.tittle) + 2;
	curWin.x = 80 / 2 - curWin.w / 2;
	curWin.y = 11;
	curWin.h = 4;
	curWin.text = 97;
	curWin.back = 41;
	drawWindow(curWin);
	OS_SETXY(curWin.x + 2, curWin.y + 3);
	printf("%s", message);
	OS_SETXY(1, 1);
	do
	{
		YIELD();
	} while (_low_level_get() == 0);
	exit(0);
}

void infoBox(unsigned char *message)
{
	strcpy(curWin.tittle, "nedoOS system updater ");
	strcat(curWin.tittle, uVer);

	if (strlen(message) > strlen(curWin.tittle))
	{
		curWin.w = strlen(message) + 2;
	}
	else
		curWin.w = strlen(curWin.tittle) + 2;
	curWin.x = 80 / 2 - curWin.w / 2;
	curWin.y = 15;
	curWin.h = 4;
	curWin.text = 97;
	curWin.back = 42;

	drawWindow(curWin);
	OS_SETXY(curWin.x + 2, curWin.y + 3);
	printf("%s", message);
	OS_SETXY(1, 1);
}

void colorBars(void)
{
	// 30-37 темный тон 90-97 светлый тон
	// 40-47 темный фон
	unsigned int count;
	OS_CLS(0);
	for (count = 0; count < 8; count++)
	{
		OS_SETCOLOR(79);
		printf("[%03d]", count);
		OS_SETCOLOR(count);
		printf(" 01234567890     ");
		OS_SETCOLOR(79);
		printf("[%03d]", (count << 3) + 7);
		OS_SETCOLOR((count << 3) + 7);
		printf(" 01234567890     \r\n");
	}
	for (count = 0; count < 8; count++)
	{
		OS_SETCOLOR(79);
		printf("[%03d]", count + 64);
		OS_SETCOLOR(count + 64);
		printf(" 01234567890     ");
		OS_SETCOLOR(79);
		printf("[%03d]", (count << 3) + 7 + 64);
		OS_SETCOLOR((count << 3) + 7 + 64);
		printf(" 01234567890     \r\n");
	}
	for (count = 0; count < 8; count++)
	{
		OS_SETCOLOR(79);
		printf("[%03d]", count + 128 + 64);
		OS_SETCOLOR(count + 64 + 128);
		printf(" 01234567890     ");
		OS_SETCOLOR(79);
		printf("[%03d]", (count << 3) + 7 + 128 + 64);
		OS_SETCOLOR((count << 3) + 7 + 64 + 128);
		printf(" 01234567890     \r\n");
	}
}

///////////////////////////
#include <../common/network.c>
//////////////////////////

unsigned char saveBuf(unsigned char *fileNamePtr, unsigned char operation, unsigned int sizeOfBuf)
{
	if (operation == 00)
	{
		fp2 = OS_CREATEHANDLE(fileNamePtr, 0x80);
		if (((int)fp2) & 0xff)
		{
			clearStatus();
			printf("%s", fileNamePtr);
			printf(" creating error.");
			exit(0);
		}
		OS_CLOSEHANDLE(fp2);

		fp2 = OS_OPENHANDLE(fileNamePtr, 0x80);
		if (((int)fp2) & 0xff)
		{
			clearStatus();
			printf("%s", fileNamePtr);
			printf(" opening error. ");

			exit(0);
		}
		return 0;
	}

	if (operation == 01)
	{
		OS_WRITEHANDLE(netbuf, fp2, sizeOfBuf);
		return 0;
	}

	if (operation == 02)
	{
		OS_CLOSEHANDLE(fp2);
		return 0;
	}
	return 0;
}

void drawClock(void)
{
	unsigned long dosTime;
	unsigned int hours, minutes;
	dosTime = OS_GETTIME();
	hours = dosTime >> 11 & 31;	   // 0b00011111
	minutes = (dosTime >> 5) & 63; // 0b00111111

	OS_SETXY(73, 0);
	printf("[%02u:%02u]", hours, minutes);
}

void mainWinDraw(void)
{
	unsigned char domainLng;
	OS_SETCOLOR(207);
	OS_SETXY(0, 0);
	spaces(80);
	OS_SETXY(0, 0);
	printf("NedoGopher %s", uVer);

	domainLng = strlen(curDomain);
	OS_SETXY(39 - domainLng / 2, 0);
	printf("%s", curDomain);
	drawClock();
}

void getMouse(void)
{
	unsigned long mouseRaw;
	unsigned char mouseButtons, mouseMove;
	mouseRaw = OS_GETMOUSE();
	mouseMove = mouseRaw >> 16;
	mouseButtons = mouseRaw;

	if (mouseMove != mouse.prevMouseMove)
	{
		OS_SETXY(mouse.cursXpos, mouse.cursYpos);
		OS_PRATTR(mouse.oldAtr);
		mouse.prevMouseMove = mouseMove;

		mouse.mouseXpos = mouseRaw >> 16;
		mouse.mouseYpos = mouseRaw >> 24;

		mouse.cursXpos = mouse.mouseXpos / 3;
		mouse.cursYpos = 25 - mouse.mouseYpos / 10;

		if (mouse.cursXpos > 79)
		{
			mouse.cursXpos = 79;
		}
		if (mouse.cursYpos > 25)
		{
			mouse.cursYpos = 25;
		}

		OS_SETXY(mouse.cursXpos, mouse.cursYpos);
		mouse.oldAtr = OS_GETATTR();
		OS_PRATTR(215);
	}

	if (mouseButtons != mouse.prevMouseButtons)
	{

		mouse.wheel = (mouseButtons >> 4) & 15;
		mouse.mmb = (mouseButtons >> 2) & 1;
		mouse.rmb = (mouseButtons >> 1) & 1;
		mouse.lmb = mouseButtons & 1;
	}
	/*
		OS_SETCOLOR(71);
		OS_SETXY(2, 23);
		printf("lmb:[%d] rmb:[%d] mmb:[%d] wheel:[%03d] X:[%03d] Y:[%03d] cursX:[%02d] cursY:[%02d]", mouse.lmb, mouse.rmb, mouse.mmb, mouse.wheel, mouse.mouseXpos, mouse.mouseYpos, mouse.cursXpos, mouse.cursYpos);
	*/
	OS_SETXY(mouse.cursXpos, mouse.cursYpos);
}

unsigned char OS_SHELL(unsigned char *command)
{
	unsigned char fileName[] = "bin/cmd.com";
	unsigned char appCmd[128] = "cmd.com ";
	unsigned int shellSize, loaded, loop, adr;
	unsigned char pgbak;
	union APP_PAGES shell_pg;
	union APP_PAGES main_pg;
	FILE *fp3;
	main_pg.l = OS_GETMAINPAGES();
	pgbak = main_pg.pgs.window_3;
	OS_GETPATH((unsigned int)&curPath);
	OS_CHDIR("/");

	strcat(appCmd, command);
	fp3 = OS_OPENHANDLE(fileName, 0x80);
	if (((int)fp3) & 0xff)
	{
		clearStatus();
		printf("%s", fileName);
		printf(" not found.");
		do
		{
			YIELD();
		} while (_low_level_get() == 0);
		exit(0);
	}

	shellSize = OS_GETFILESIZE(fp3);

	OS_CHDIR(curPath);

	OS_NEWAPP((unsigned int)&shell_pg);
	shell_pg.l = OS_GETAPPMAINPAGES(shell_pg.pgs.pId);
	SETPG32KHIGH(shell_pg.pgs.window_0);
	memcpy((unsigned char *)(0xC080), (unsigned char *)(&appCmd), strlen(appCmd) + 1);

	loop = 0;
	while (loop < shellSize)
	{
		loaded = OS_READHANDLE(netbuf, fp3, sizeof(netbuf));
		adr = 0xC100 + loop;
		memcpy((unsigned char *)(adr), &netbuf, loaded);
		loop = loop + loaded;
	}
	OS_CLOSEHANDLE(fp3);
	SETPG32KHIGH(pgbak);
	clearStatus();
	printf("Shell [pId:%u][%s][%s]", shell_pg.pgs.pId, curPath, appCmd);
	delay(300);
	OS_RUNAPP(shell_pg.pgs.pId);
	OS_SETXY(1, 4);
	OS_WAITPID(shell_pg.pgs.pId);
	return shell_pg.pgs.pId;
}

char loadPageFromDisk(unsigned char *filepath)
{
	unsigned int todo = 0;
	unsigned long loaded = 0;

	FILE *fp1;
	clearStatus();
	fp1 = OS_OPENHANDLE(filepath, 0x80);
	if (((int)fp1) & 0xff)
	{
		printf("%s opening error. ", filepath);
		return false;
	}
	clearStatus();
	printf("opening %s...", filepath);

	do
	{
		todo = OS_READHANDLE(netbuf + loaded, fp1, sizeof(netbuf));
		loaded = loaded + todo;
	} while (todo != 0 && errno == 0);
	OS_CLOSEHANDLE(fp1);
	netbuf[loaded + 1] = 0;
	return true;
}

void init(void)
{

	targetadr.family = AF_INET;
	targetadr.porth = 00;
	targetadr.portl = 70;
	targetadr.b1 = 0;
	targetadr.b2 = 0;
	targetadr.b3 = 0;
	targetadr.b4 = 0;
	mouse.oldAtr = 79;
	navi.lineSelect = 1;
	navi.prevLineSelect = 2;
	navi.nextBufPos = 0;
	navi.page = 0;
	navi.maxPage = 32768;
	link.type = '1';
	get_dns();
}

void newPage(void)
{
	navi.page = 0;
	navi.maxPage = 32767;
	navi.linePage = 0;
	navi.lineSelect = 1;
	navi.prevLineSelect = 2;
	navi.bufPos = 0;
	navi.nextBufPos = 0;
}

void renderType(unsigned char linkType)
{
	OS_SETCOLOR(70);

	switch (linkType)
	{
	case 'i':
		putchar(' ');
		return;
	case '0':
		putchar(21); // plain text
		putchar(' ');
		return;
	case '1':
		putchar(16); // directory
		putchar(' ');
		return;
	case '3':
		putchar(15); // error link
		putchar(' ');
		return;
	case '5': // Dos zip
		putchar('Z');
		putchar(' ');
		return;
	case '6': // uuencoded file
		putchar('Z');
		putchar(' ');
		return;
	case '7': // search input
		putchar(253);
		putchar(' ');
		return;
	case '8': // Telnet session
		putchar('T');
		putchar(' ');
		return;
	case '9': // binary (pt3/scr)
		putchar(8);
		putchar(' ');
		return;
	case 'g': // gif pic
		putchar(2);
		putchar(' ');
		return;
	case 'I': // image
		putchar(2);
		putchar(' ');
		return;
	case 's': // sound
		putchar(14);
		putchar(' ');
		return;
	default:
		putchar(linkType);
		return;
	}
}

unsigned int renderPlain(unsigned int bufPos)
{
	unsigned int counter = 0, colCount = 0;
	unsigned int byte = 0, flag = true;
	OS_CLS(0);
	mainWinDraw();
	OS_SETCOLOR(7);
	OS_SETXY(0, 1);

	counter = 0;
	do
	{
		byte = netbuf[bufPos];
		if (byte == 0)
		{
			navi.maxPage = navi.page;
			return bufPos;
		}

		if (colCount == 80)
		{
			counter++;
			colCount = 0;
		}

		if (byte == 0xd)
		{
			if (colCount != 80)
			{
				putchar('\r');
				flag = true;
			}
			else
			{
				flag = false;
			}

			bufPos++;
			colCount = 0;
			continue;
		}

		if (byte == 0xa)
		{
			if (flag)
			{
				putchar('\n');
			}

			bufPos++;
			counter++;
			flag = true;
			continue;
		}

		putchar(byte);

		colCount++;
		bufPos++;

	} while (counter < screenHeight);
	return bufPos;
}

unsigned int renderPage(unsigned int bufPos)
{
	unsigned char counter = 0, colCount = 0;
	unsigned char byte = 0;
	OS_CLS(0);
	mainWinDraw();
	OS_SETXY(0, 1);

	byte = netbuf[bufPos];
	renderType(byte);
	if (byte == '.')
	{
		return bufPos;
	}

	OS_SETCOLOR(7);
	do
	{
		while (42)
		{
			bufPos++;

			byte = netbuf[bufPos];

			if (byte == 9)
			{
				putchar('\r');
				putchar('\n');
				break;
			}
			if (byte == 0)
			{
				navi.maxPage = navi.page;
				return bufPos;
			}
			colCount++;
			if (colCount < 78)
			{
				putchar(byte);
			}
		}
		while (42)
		{
			bufPos++;
			if (netbuf[bufPos] == 10)
			{
				colCount = 0;
				counter++;
				bufPos++;
				if (netbuf[bufPos] == '.')
				{
					navi.maxPage = navi.page;
					return bufPos;
				}
				if (counter < screenHeight)
				{
					renderType(netbuf[bufPos]);
				}

				OS_SETCOLOR(7);
				break;
			}
		}
	} while (counter < screenHeight);
	return bufPos;
}

void getFile(void)
{
	int todo;
	char socket;
	unsigned long downloaded = 0;
	dnsResolve(curDomain);

	targetadr.porth = 00;
	targetadr.portl = link.port;
	if ((strlen(link.path) == 1 && link.path[0] == '/') || strlen(link.path) == 0)
	{
		strcpy(link.path, crlf);
	}
	else
	{
		strcat(link.path, crlf);
	}
	clearStatus();
	socket = OpenSock(AF_INET, SOCK_STREAM);
	// testOperation("OS_NETSOCKET", socket);
	todo = netConnect(socket, 1);
	// testOperation("OS_NETCONNECT", todo);
	todo = tcpSend(socket, (unsigned int)&link.path, strlen(link.path), 1);
	// testOperation("OS_WIZNETWRITE", todo);
	saveBuf("fileNamePtr", 00, 0);
	do
	{
		todo = tcpRead(socket, 3);
		if (todo < 1)
		{
			break;
		}

		downloaded = downloaded + todo;

		clearStatus();
		printf("%u kb downloaded", downloaded / 1024);
		saveBuf("fileNamePtr", 01, todo);

	} while (42);
	netShutDown(socket, 0);
	saveBuf("fileNamePtr", 02, 00);
}

void selectorProcessor(void)
{
	unsigned int startSearch = 0, lineSearch = 0, SelectedPos, counter1 = 0;
	unsigned char byte;

	startSearch = pageOffsets[navi.page];
	do
	{
		byte = netbuf[startSearch + counter1];

		if (byte == 10)
		{
			lineSearch++;
		}
		counter1++;
	} while (lineSearch < navi.lineSelect - 1);

	if (counter1 == 1)
	{
		counter1 = 0;
	}
	SelectedPos = startSearch + counter1;

	link.nexType = link.type;
	link.type = netbuf[SelectedPos];

	if (link.type == 'i')
	{
		return;
	}

	counter1 = 1; // Пропускаем  заголовок селектора
	do
	{
		byte = netbuf[SelectedPos + counter1];
		counter1++;
	} while (byte != 9);

	SelectedPos = SelectedPos + counter1;
	counter1 = 0; // Извлекаем путь к селектору

	while (netbuf[SelectedPos + counter1] != 9)
	{
		link.path[counter1] = netbuf[SelectedPos + counter1];
		counter1++;
	}
	link.path[counter1] = 0;

	SelectedPos = SelectedPos + counter1 + 1;
	counter1 = 0; // Извлекаем хост селектора
	do
	{
		link.host[counter1] = netbuf[SelectedPos + counter1];
		counter1++;
	} while (netbuf[SelectedPos + counter1] != 9);
	link.host[counter1] = 0;

	SelectedPos = SelectedPos + counter1 + 1;
	link.port = atoi(netbuf + SelectedPos);
	strcpy(curDomain, link.host);
}

void activate(void)
{

	if (link.type == '0') // Если текущая страница текстовая, нечего по ней тыкать
	{
		return;
	}

	selectorProcessor();

	switch (link.type) // Тут уже новый элемент
	{
	case 'i':
		link.type = link.nexType; // так-как мы остались на странице, восстановим тип, хотя можно просто ставить 1 (пока других нет)
		return;
	case '0': // plain texts
		newPage();
		getFile();
		loadPageFromDisk("fileNamePtr");
		navi.nextBufPos = renderPlain(navi.nextBufPos);
		return;
	case '1': // gopher page
		newPage();
		getFile();
		loadPageFromDisk("fileNamePtr");
		navi.nextBufPos = renderPage(navi.nextBufPos);
		return;
	case '7': // search input
		link.type = link.nexType;
		return;
	case '9': // binary (pt3/scr)
		getFile();
		link.type = link.nexType;
		return;
	case 'g': // gif pic
		getFile();
		link.type = link.nexType;
		return;
	case 'I': // image
		getFile();
		link.type = link.nexType;
		return;
	case 's': // sound
		getFile();
		link.type = link.nexType;
		return;
	default:
		getFile();
		link.type = link.nexType;
		return;
	}
}

void navigationPage(char keypress)
{
	unsigned char counter;

	switch (keypress)
	{
	case 250: // Up
		navi.prevLineSelect = navi.lineSelect;
		navi.lineSelect--;

		if (navi.lineSelect < 1 && navi.page == 0)
		{
			navi.lineSelect = screenHeight;
			break;
		}

		if (navi.page != 0 && navi.lineSelect == 0)
		{
			navi.page--;
			navi.nextBufPos = pageOffsets[navi.page];
			navi.nextBufPos = renderPage(navi.nextBufPos);
			navi.lineSelect = screenHeight;
		}
		break;
	case 249: // down
		navi.prevLineSelect = navi.lineSelect;
		navi.lineSelect++;
		if (navi.lineSelect > screenHeight && navi.page == navi.maxPage)
		{
			navi.lineSelect = 1;
			break;
		}
		if (navi.page != navi.maxPage && navi.lineSelect > screenHeight)
		{
			navi.page++;
			pageOffsets[navi.page] = navi.nextBufPos;
			navi.nextBufPos = renderPage(navi.nextBufPos);
			navi.lineSelect = 1;
		}
		break;
	case 248: // Left
		if (navi.page == 0)
		{
			break;
		}
		navi.page--;
		navi.nextBufPos = pageOffsets[navi.page];
		navi.nextBufPos = renderPage(navi.nextBufPos);
		navi.lineSelect = screenHeight;
		break;
	case 251: // Right
		if (navi.page == navi.maxPage)
		{
			break;
		}
		navi.page++;
		pageOffsets[navi.page] = navi.nextBufPos;

		navi.nextBufPos = renderPage(navi.nextBufPos);
		navi.lineSelect = 1;
		break;
	case 0xd:
		activate();
		break;
	}

	if (link.type == '1')
	{
		for (counter = 1; counter < 79; counter++)
		{
			OS_SETXY(counter, navi.prevLineSelect);
			OS_PRATTR(7);
		}

		if (mouse.cursYpos == navi.prevLineSelect)
		{
			OS_SETXY(mouse.cursXpos, mouse.cursYpos);
			mouse.oldAtr = OS_GETATTR();
		}
		for (counter = 1; counter < 79; counter++)
		{
			OS_SETXY(counter, navi.lineSelect);
			OS_PRATTR(15);
		}
	}
}

void navigationPlain(char keypress)
{
	switch (keypress)
	{
	case 250: // Up
		if (navi.page == 0)
		{
			break;
		}
		navi.page--;
		navi.nextBufPos = pageOffsets[navi.page];
		navi.lineSelect = screenHeight;
		navi.nextBufPos = renderPlain(navi.nextBufPos);
		break;
	case 249: // down

		if (navi.page == navi.maxPage)
		{
			break;
		}
		navi.page++;
		pageOffsets[navi.page] = navi.nextBufPos;
		navi.lineSelect = 1;
		navi.nextBufPos = renderPlain(navi.nextBufPos);
		break;
	case 248: // Left
		if (navi.page == 0)
		{
			break;
		}
		navi.page--;
		navi.nextBufPos = pageOffsets[navi.page];
		navi.lineSelect = screenHeight;
		navi.nextBufPos = renderPlain(navi.nextBufPos);
		break;
	case 251: // Right
		if (navi.page == navi.maxPage)
		{
			break;
		}
		navi.page++;
		pageOffsets[navi.page] = navi.nextBufPos;
		navi.lineSelect = 1;
		navi.nextBufPos = renderPlain(navi.nextBufPos);
		break;
	}

	if (mouse.cursYpos == navi.prevLineSelect)
	{
		OS_SETXY(mouse.cursXpos, mouse.cursYpos);
		mouse.oldAtr = OS_GETATTR();
	}
}

void navigation(unsigned char keypress)
{
	switch (link.type)
	{
	case '0':
		navigationPlain(keypress);
		break;
	case '1':
		navigationPage(keypress);
		break;
	}
}

C_task main(int argc, char *argv[])
{
	unsigned char keypress;
	OS_HIDEFROMPARENT();
	OS_SETGFX(86);
	OS_CLS(0);
	OS_SETSYSDRV();
	init();
	// printTable();
	// getchar();
	loadPageFromDisk("browser/index.gph");

	navi.nextBufPos = renderPage(navi.nextBufPos);
	do
	{
		getMouse();
		if (mouse.lmb == 0)
		{
			navi.prevLineSelect = navi.lineSelect;
			navi.lineSelect = mouse.cursYpos;
			activate();
			OS_SETXY(mouse.cursXpos, mouse.cursYpos);
			OS_PRATTR(215);
		}
		keypress = _low_level_get();
		if (keypress != 0)
		{
			navigation(keypress);
		}
	} while (keypress != 27);
}
