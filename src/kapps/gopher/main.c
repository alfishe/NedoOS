#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <stdlib.h>
#include <oscalls.h>
#include <../common/terminal.c>
#include <tcp.h>
#include <osfs.h>
#include <intrz80.h>
#include <graphic.h>
#include <ctype.h>
#include <math.h>

#define true 1
#define false 0
#define screenHeight 23
#define screenWidth 80

FILE *fp2;

unsigned char netDriver = 0;

unsigned char uVer[] = "00.10";
unsigned char curPath[128];
unsigned char cmd[128];
unsigned int pageOffsets[128];
unsigned long volumeOffsets[16];
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

struct linkStruct
{
	unsigned char type;
	unsigned long size;
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
	unsigned int prevMouseButtons;
	char prevMouseMove;
	char oldAtr;
} mouse;

struct navigationStruct
{
	unsigned int page;
	unsigned int volume;
	unsigned int maxPage;
	unsigned int linePage;
	unsigned int lineSelect;
	unsigned int lastLine;
	unsigned int prevLineSelect;
	unsigned int bufPos;
	unsigned int nextBufPos;
	unsigned int history;
	unsigned long NextVolumePos;
	unsigned char fileName[128];
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
	BDBOX(w.x, w.y, w.w + 1, w.h, w.back, 32);
	OS_SETXY(w.x, w.y);
	OS_SETCOLOR(w.text);
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
	OS_SETCOLOR(207);
	OS_SETXY(0, 0);
	spaces(80);
	OS_SETXY(0, 0);
	printf("NedoGopher %s", uVer);

	OS_SETXY(39 - strlen(link.host) / 2, 0);
	printf("%s", link.host);
	drawClock();
}

unsigned char getMouse(void)
{
	unsigned long mouseRaw;
	unsigned char mouseMove;
	unsigned int mouseButtons;

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
		clearStatus();
		printf("lmb:[%d] rmb:[%d] mmb:[%d] wheel:[%02d] X:[%03d] Y:[%03d] cursX:[%02d] cursY:[%02d]", mouse.lmb, mouse.rmb, mouse.mmb, mouse.wheel, mouse.mouseXpos, mouse.mouseYpos, mouse.cursXpos, mouse.cursYpos);
	*/
	OS_SETXY(mouse.cursXpos, mouse.cursYpos);

	return mouseButtons >> 8;
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

char loadPageFromDisk(unsigned char *filepath, unsigned long volumeOffset)
{
	unsigned int todo = 0;
	unsigned long clean = 0, loaded = 0;
	FILE *fp1;

	fp1 = OS_OPENHANDLE(filepath, 0x80);
	if (((int)fp1) & 0xff)
	{
		printf("%s opening error. ", filepath);
		return false;
	}

	OS_SEEKHANDLE(fp1, volumeOffset);
	do
	{
		if ((sizeof(netbuf) - loaded) < 513)
		{
			clearStatus();
			printf("file is to large (%lu)", link.size);
			getchar();
			break;
		}
		todo = OS_READHANDLE(netbuf + loaded, fp1, 512);
		loaded = loaded + todo;
	} while (todo != 0 && errno == 0);
	OS_CLOSEHANDLE(fp1);
	netbuf[loaded + 1] = 0;
	clean = loaded + 256;
	do
	{
		netbuf[loaded] = 0;
		loaded++;
	} while (loaded < clean);

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
	navi.volume = 0;
	navi.NextVolumePos = 0;

	link.type = '1';
	strcpy(link.host, "HOMEPAGE");
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
		break;
	case '0':
		putchar(21); // plain text
		putchar(' ');
		break;
	case '1':
		putchar(16); // directory
		putchar(' ');
		break;
	case '3':
		putchar(15); // error link
		putchar(' ');
		break;
	case '5': // Dos zip
		putchar('Z');
		putchar(' ');
		break;
	case '6': // uuencoded file
		putchar('Z');
		putchar(' ');
		break;
	case '7': // search input
		putchar(253);
		putchar(' ');
		break;
	case '8': // Telnet session
		putchar('T');
		putchar(' ');
		break;
	case '9': // binary (pt3/scr)
		putchar(8);
		putchar(' ');
		break;
	case 'g': // gif pic
		putchar(2);
		putchar(' ');
		break;
	case 'I': // image
		putchar(2);
		putchar(' ');
		break;
	case 's': // sound
		putchar(14);
		putchar(' ');
		break;
	default:
		putchar(linkType);
		break;
	}
	OS_SETCOLOR(7);
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
					navi.lastLine = counter;
					return bufPos;
				}
				if (counter < screenHeight)
				{
					renderType(netbuf[bufPos]);
				}
				break;
			}
		}
	} while (counter < screenHeight);
	navi.lastLine = counter;
	return bufPos;
}

unsigned char inputBox(struct window w, unsigned char *prefilled)
{
	unsigned char wcount, tempx, tittleStart;
	unsigned char byte, counter;
	w.h++;
	OS_SETXY(w.x, w.y - 1);
	BDBOX(w.x, w.y, w.w + 1, w.h, w.back, 32);
	OS_SETXY(w.x, w.y);
	OS_SETCOLOR(w.text);
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
	tittleStart = w.x + (w.w / 2) - (strlen(w.tittle) / 2);
	OS_SETXY(tittleStart, w.y);
	printf("[%s]", w.tittle);
	OS_SETXY(w.x + 1, w.y + 1);
	OS_SETCOLOR(w.back);
	putchar(219);

	counter = strlen(prefilled);
	if (counter != 0)
	{
		strcpy(cmd, prefilled);
		goto skipKeys;
	}

	do
	{
		byte = OS_GETKEY();
		if (byte != 0)
		{
			switch (byte)
			{
			case 0x08:
				if (counter > 0)
				{
					counter--;
					cmd[counter] = 0;
				}
				break;
			case 0x0d:
				if (strlen(cmd) == 0)
				{
					return false;
				}
				else
				{
					return true;
				}
			case 250:
				break;
			case 249:
				break;
			case 248:
				break;
			case 251: // Right
				break;
			case 252: // Del
				OS_SETXY(w.x + 1, w.y + 1);
				spaces(counter + 1);
				cmd[0] = 0;
				counter = 0;
				break;
			case 27:
				cmd[0] = 0;
				navi.nextBufPos = renderPage(pageOffsets[navi.page]);
				return false;
			default:
				if (counter < w.w - 1)
				{
					cmd[counter] = byte;
					counter++;
					cmd[counter] = 0;
				}
				break;
			}
		skipKeys:
			OS_SETXY(w.x + 1, w.y + 1);
			printf("%s", cmd);
			putchar(219);
			if (byte == 0x08)
			{
				putchar(' ');
			}
		}
	} while (42);
	return false;
}

void getFile(unsigned char *fileNamePtr)
{
	int todo;
	char socket;
	unsigned long downloaded = 0;

	if (!dnsResolve(link.host))
	{
		navi.nextBufPos = renderPage(pageOffsets[navi.page]);
		return;
	}

	targetadr.porth = 00;
	targetadr.portl = link.port;

	// clearStatus();
	// printf("File:%s", fileNamePtr);
	// printf("\r\nAddress:%u.%u.%u.%u:%u\r\n", targetadr.b1, targetadr.b2, targetadr.b3, targetadr.b4, targetadr.porth * 256 + targetadr.portl);
	// getchar();

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
	saveBuf(fileNamePtr, 00, 0);
	do
	{
		todo = tcpRead(socket, 3);
		if (todo < 1)
		{
			break;
		}

		downloaded = downloaded + todo;

		clearStatus();
		printf("%lu kb  ", downloaded / 1024);
		saveBuf(fileNamePtr, 01, todo);
	} while (42);
	clearStatus();
	netShutDown(socket, 0);
	saveBuf(fileNamePtr, 02, 00);
	link.size = downloaded;
}

unsigned char selectorProcessor(void)
{
	unsigned int startSearch = 0, lineSearch = 0, SelectedPos, counter1 = 0;
	unsigned char byte;

	if (link.type == '0' || navi.lineSelect > navi.lastLine) // Если текущая страница текстовая, нечего по ней тыкать или тыкнули ниже низа.
	{
		return false;
	}

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

	if (link.type == 'i' || link.type == '.' || link.type == 0)
	{
		link.type = link.nexType;
		return false;
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
	return true;
}

void pusHistory(void)
{
	FILE *hf;
	unsigned char *historyBytes;
	unsigned char buf[1];
	unsigned int structSize, filePos, counter;
	navi.history++;
	structSize = sizeof(struct linkStruct);
	filePos = structSize * navi.history;

	hf = OS_CREATEHANDLE("browser/ng_hist.dat", 0x80);
	if (((int)hf) & 0xff)
	{
		clearStatus();
		printf("browser/ng_hist.dat creating error.");
		exit(0);
	}
	OS_CLOSEHANDLE(hf);

	hf = OS_OPENHANDLE("browser/ng_hist.dat", 0x80);
	if (((int)hf) & 0xff)
	{
		clearStatus();
		printf("browser/ng_hist.dat opening error.");
		exit(0);
	}
	OS_SEEKHANDLE(hf, filePos);

	historyBytes = (unsigned char *)&link;

	for (counter = 0; counter < structSize; counter++)
	{
		buf[0] = historyBytes[counter];
		OS_WRITEHANDLE(buf, hf, 1);
	}
	OS_CLOSEHANDLE(hf);
}

void popHistory(void)
{
	FILE *hf;
	unsigned int structSize, filePos;
	navi.history--;
	structSize = sizeof(struct linkStruct);
	filePos = structSize * navi.history;

	hf = OS_OPENHANDLE("browser/ng_hist.dat", 0x80);
	if (((int)hf) & 0xff)
	{
		clearStatus();
		printf("browser/ng_hist.dat opening error.");
		exit(0);
	}
	OS_SEEKHANDLE(hf, filePos);
	OS_READHANDLE(netbuf, hf, structSize);

	memcpy(&link, netbuf, structSize);
}

void extractName(void)
{
	unsigned int counter, counter2 = 0, lng, byte, source;

	lng = strlen(link.path);

	clearStatus();
	for (counter = lng - 1; counter != 0; counter--)
	{
		byte = link.path[counter];
		if (byte == '/' || byte == ':')
		{
			break;
		}

		counter2++;
	}
	source = lng - counter2;

	for (counter = 0; counter < counter2; counter++)
	{
		navi.fileName[counter] = link.path[source + counter];
	}
	navi.fileName[counter2] = 0;

	curWin.w = 61;
	curWin.x = 80 / 2 - curWin.w / 2 - 1;
	curWin.y = 4;
	curWin.h = 1;
	curWin.text = 103;
	curWin.back = 103;
	strcpy(curWin.tittle, "Введите имя файла");

	lng = strlen(navi.fileName);
	if (lng > 60)
	{
		lng = lng - 64 - 1;
	}
	else
	{
		lng = 0;
	}

	if (inputBox(curWin, navi.fileName + lng))
	{
		strcpy(navi.fileName, cmd);
	}
}

void doLink(void)
{

	// clearStatus();
	// printf("[%c][%s][%d][%s]", link.type, link.host, link.port, link.path);
	// getchar();

	switch (link.type) // Тут уже новый элемент
	{
	case 'i':
		link.type = link.nexType; // так-как мы остались на странице, восстановим тип, хотя можно просто ставить 1 (пока других нет)
		return;
	case '0': // plain texts
		newPage();
		getFile("browser/current.txt");
		loadPageFromDisk("browser/current.txt", 0);
		navi.nextBufPos = renderPlain(navi.nextBufPos);
		return;
	case '1': // gopher page
		newPage();
		getFile("browser/current.gph");
		loadPageFromDisk("browser/current.gph", 0);
		navi.nextBufPos = renderPage(navi.nextBufPos);
		return;
	case '7': // search input
		curWin.w = 40;
		curWin.x = 80 / 2 - curWin.w / 2 - 1;
		curWin.y = 4;
		curWin.h = 1;
		curWin.text = 95;
		curWin.back = 95;
		strcpy(curWin.tittle, "Введите поисковый запрос");
		if (inputBox(curWin, ""))
		{
			strcat(link.path, "\t");
			strcat(link.path, cmd);
			newPage();
			getFile("browser/current.gph");
			loadPageFromDisk("browser/current.gph", 0);
			navi.nextBufPos = renderPage(navi.nextBufPos);
			popHistory();
			link.type = '1';
		}
		return;
	case '9': // binary (pt3/scr)
		pusHistory();
		extractName();
		getFile(navi.fileName);
		popHistory();

		// viewScreen6912((unsigned int)&netbuf, 0);

		loadPageFromDisk("browser/current.gph", 0);
		navi.nextBufPos = renderPage(pageOffsets[navi.page]);
		return;
	case 'g': // gif pic
		getFile("../downloads/pic.gif");
		link.type = link.nexType;
		return;
	case 'I': // image
		getFile("../downloads/pt3.img");
		link.type = link.nexType;
		return;
	case 's': // sound
		getFile("../downloads/mus.mid");
		link.type = link.nexType;
		return;
	default:
		clearStatus();
		printf("Неизвестный селектор:[%d]lineselect[%d]linelast[%d]", link.type, navi.lineSelect, navi.lastLine);
		return;
	}
}

void activate(void)
{
	if (!selectorProcessor())
	{
		return;
	}

	if (link.type == '0' || link.type == '1' || link.type == '7')
	{
		pusHistory();
	}
	doLink();
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
	case 0x0d:
		activate();
		break;
	case 0x08: // BS
		if (navi.history > 1)
		{
			popHistory();
			doLink();
		}
		break;
	case 31:
		renderPage(pageOffsets[navi.page]);
		break;
	case 'h':
		newPage();
		loadPageFromDisk("browser/index.gph", 0);
		navi.nextBufPos = renderPage(navi.nextBufPos);
		break;
	case 'd':
		curWin.w = 40;
		curWin.x = 80 / 2 - curWin.w / 2 - 1;
		curWin.y = 4;
		curWin.h = 1;
		curWin.text = 207;
		curWin.back = 207;
		strcpy(curWin.tittle, "Введите адрес Gopher сервера");

		if (inputBox(curWin, ""))
		{
			link.type = '1';
			strcpy(link.host, cmd);
			strcpy(link.path, "/");
			link.port = 70;
			doLink();
		}
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
	case 0x08:
		if (navi.history > 1)
		{
			popHistory();
			doLink();
		}
		break;
	case 31:
		renderPlain(pageOffsets[navi.page]);
		break;
	case 'h':
		newPage();
		loadPageFromDisk("browser/index.gph", 0);
		navi.nextBufPos = renderPage(navi.nextBufPos);
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
	loadPageFromDisk("browser/index.gph", 0);
	navi.nextBufPos = renderPage(navi.nextBufPos);

	do
	{
		keypress = getMouse();
		if (mouse.lmb == 0)
		{
			navi.prevLineSelect = navi.lineSelect;
			navi.lineSelect = mouse.cursYpos;
			activate();
			OS_SETXY(mouse.cursXpos, mouse.cursYpos);
			OS_PRATTR(215);
		}
		if (mouse.rmb == 0)
		{
			if (navi.history > 1)
			{
				popHistory();
				doLink();
			}
		}

		if (keypress != 0)
		{
			navigation(keypress);
		//	clearStatus();
		//	printf("keypress [%d]", keypress);
		}
	} while (keypress != 27);
	OS_DELETE("browser/current.gph");
	OS_DELETE("browser/current.txt");
	OS_DELETE("browser/ng_hist.dat");
}
