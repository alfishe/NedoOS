#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <stdlib.h>
#include <oscalls.h>
#include <../common/terminal.c>
#include <tcp.h>
#include <osfs.h>
#include <graphic.h>
#include <ctype.h>
#include <math.h>
///
#define true 1
#define false 0
#define screenHeight 23
#define screenWidth 80

unsigned int RBR_THR = 0xf8ef;
unsigned int IER = 0xf9ef;
unsigned int IIR_FCR = 0xfaef;
unsigned int LCR = 0xfbef;
unsigned int MCR = 0xfcef;
unsigned int LSR = 0xfdef;
unsigned int MSR = 0xfeef;
unsigned int SR = 0xffef;
unsigned int divider = 1;
unsigned int comType = 0;
unsigned int espType = 32;
unsigned int netDriver = 0;
unsigned int espRetry = 5;
unsigned long factor, timerok, count = 0;
unsigned int magic = 15;

unsigned char uVer[] = "1.6";
unsigned char curPath[128];
unsigned char cmd[512];
unsigned int pageOffsets[128];
unsigned long volumeOffsets[16];
unsigned char crlf[2] = {13, 10};
const unsigned char gotWiFi[] = "WIFI GOT IP";

struct sockaddr_in targetadr;
struct readstructure readStruct;
struct sockaddr_in dnsaddress;

struct mouseStruct
{
	char lmb;
	char rmb;
	char mmb;
	char wheel;
	char prevWheel;
	char mouseXpos;
	char mouseYpos;
	char prevMouseXpos;
	char prevMouseYpos;
	int cursXpos;
	int cursYpos;
	unsigned int prevMouseButtons;
	char prevMouseMove;
	char oldAtr;
	char classic;
	char divider;
} mouse;

struct navigationStruct
{
	unsigned int page;
	unsigned int volume;
	unsigned int maxVolume;
	unsigned int maxPage;
	unsigned int linePage;
	unsigned int lineSelect;
	unsigned int lastLine;
	unsigned int prevLineSelect;
	unsigned int bufPos;
	unsigned int nextBufPos;
	unsigned int history;
	unsigned int saveAs;
	unsigned char fileName[128];
} navi;

struct linkStruct
{
	unsigned char type;
	unsigned long size;
	unsigned char nexType;
	unsigned char path[512];
	unsigned char host[300];
	unsigned char prevHost[300];
	unsigned int port;
} link;

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

struct time
{
	unsigned int hours;
	unsigned int minutes;
	unsigned char oldMinutes;

} clock;

unsigned char nvext[1024];
unsigned char netbuf[31768];
unsigned char heap[1500];
FILE *fp2;

void clearNetBuf(unsigned int const size)
{
	unsigned int counter;
	for (counter = 0; counter < size; counter++)
	{
		netbuf[counter] = 0;
	}
}

void spaces(unsigned char number)
{
	while (number > 0)
	{
		putchar(' ');
		number--;
	}
}

void waitKey(void)
{
	do
	{
		YIELD();
	} while (OS_GETKEY() == 0);
}

void clearStatus(void)
{
	OS_SETCOLOR(5);
	OS_SETXY(0, 24);
	spaces(79);
	putchar('\r');
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

///////////////////////////
#include <../common/esp-com.c>
#include <../common/network.c>
//////////////////////////

char readParamFromIni(void)
{
	FILE *fpini;
	unsigned char *count1;
	const char currentNetwork[] = "currentNetwork";
	unsigned char curNet = 0;

	OS_GETPATH((unsigned int)&curPath);
	OS_SETSYSDRV();
	OS_CHDIR("/");
	OS_CHDIR("ini");

	fpini = OS_OPENHANDLE("network.ini", 0x80);
	if (((int)fpini) & 0xff)
	{
		clearStatus();
		printf("network.ini not found.\r\n");
		getchar();
		return false;
	}

	OS_READHANDLE(netbuf, fpini, sizeof(netbuf) - 1);
	OS_CLOSEHANDLE(fpini);

	count1 = strstr(netbuf, currentNetwork);
	if (count1 != NULL)
	{
		sscanf(count1 + strlen(currentNetwork) + 1, "%u", &curNet);
	}

	OS_CHDIR(curPath);
	return curNet;
}

unsigned char saveBuf(unsigned char *fileNamePtr, unsigned char operation, unsigned int sizeOfBuf)
{

	switch (operation)
	{
	case 00:
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
		break;

	case 01:
		OS_WRITEHANDLE(netbuf, fp2, sizeOfBuf);
		break;

	default:
		OS_CLOSEHANDLE(fp2);
	}

	return 0;
}

void drawClock(void)
{
	unsigned long dosTime;
	dosTime = OS_GETTIME();
	clock.hours = dosTime >> 11 & 31;	 // 0b00011111
	clock.minutes = (dosTime >> 5) & 63; // 0b00111111

	if (clock.minutes != clock.oldMinutes)
	{
		clock.oldMinutes = clock.minutes;
		OS_SETCOLOR(207);
		OS_SETXY(73, 0);
		printf("[%02u:%02u]", clock.hours, clock.minutes);
	}
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

	OS_SETXY(55, 0);

	if (netDriver)
	{
		printf("[ESP-COM]");
	}
	else
	{
		printf("[NEDONET]");
	}
	OS_SETXY(64, 0);
	if (navi.saveAs)
	{
		printf("[Save As]");
	}
	else
	{
		printf("[Play It]");
	}

	clock.oldMinutes = 255;
	drawClock();
}

void initMouse(void)
{
	unsigned long mouseRaw;
	unsigned int mouseButtons;
	mouseRaw = OS_GETMOUSE();
	mouseButtons = mouseRaw;
	mouse.wheel = (mouseButtons >> 4) & 15;
	mouse.prevWheel = mouse.wheel;
	mouse.classic = 0;
}

unsigned char OS_SHELL(const char *command)
{
	unsigned char fileName[] = "term.com";
	unsigned char appCmd[128] = "term.com ";
	unsigned int shellSize, loop;
	unsigned char pgbak;
	union APP_PAGES shell_pg;
	union APP_PAGES main_pg;
	FILE *fp3;
	main_pg.l = OS_GETMAINPAGES();
	pgbak = main_pg.pgs.window_3;

	OS_GETPATH((unsigned int)&curPath);
	OS_SETSYSDRV();
	strcat(appCmd, command);

	fp3 = OS_OPENHANDLE(fileName, 0x80);
	if (((int)fp3) & 0xff)
	{
		clearStatus();
		printf("%s not found.", fileName);
		waitKey();
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
		unsigned int loaded, adr;
		loaded = OS_READHANDLE(cmd, fp3, sizeof(cmd) - 1);
		adr = 0xC100 + loop;
		memcpy((unsigned char *)(adr), &cmd, loaded);
		loop = loop + loaded;
	}
	OS_CLOSEHANDLE(fp3);
	SETPG32KHIGH(pgbak);
	OS_RUNAPP(shell_pg.pgs.pId);
	return shell_pg.pgs.pId;
}

char loadPageFromDisk(unsigned char *filepath, unsigned int volume)
{
	unsigned int todo = 0;
	unsigned long clean = 0, loaded = 0;
	FILE *fp1;

	fp1 = OS_OPENHANDLE(filepath, 0x80);
	if (((int)fp1) & 0xff)
	{
		clearStatus();
		printf("%s opening error. ", filepath);
		return false;
	}
	OS_SEEKHANDLE(fp1, volumeOffsets[volume]);

	do
	{
		if ((sizeof(netbuf) - loaded) < 513)
		{
			clearStatus();
			printf("Файл слишком большой, будет загружаться частями (%ld kb)...", link.size / 1024);
			break;
		}

		todo = OS_READHANDLE(netbuf + loaded, fp1, 512);
		loaded = loaded + todo;

	} while (todo != 0 && errno == 0);
	OS_CLOSEHANDLE(fp1);

	netbuf[loaded + 1] = 0;

	if (todo == 0 && errno == 0)
	{
		navi.maxVolume = volume;
	}
	volumeOffsets[volume + 1] = volumeOffsets[volume] + loaded;

	/*
	clean = loaded + 128;
	do
	{
		netbuf[loaded] = 0;
		loaded++;
	} while (loaded < clean);
*/
	return true;
}

void loadNVext(void)
{
	FILE *nvf;
	unsigned int nvextSize, loop = 0, loaded;
	OS_SETSYSDRV();
	nvf = OS_OPENHANDLE("nv.ext", 0x80);
	if (((int)nvf) & 0xff)
	{
		clearStatus();
		printf("nv.ext not found.\r\n");
		exit(0);
	}
	nvextSize = OS_GETFILESIZE(nvf);
	do
	{
		loaded = OS_READHANDLE(nvext + loop, nvf, sizeof(nvext) - 1);
		loop = loop + loaded;
	} while (loop < nvextSize);

	OS_CLOSEHANDLE(nvf);
	nvext[loop + 1] = 0;
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
	navi.maxPage = 32767;
	navi.maxVolume = 32767;
	navi.volume = 0;
	volumeOffsets[0] = 0;
	navi.saveAs = true;
	mouse.divider = 0;
	mouse.prevMouseButtons = 0;
	navi.history = 0;
	link.type = '1';
	link.size = 0;
	link.nexType = '1';
	strcpy(link.path, "HOMEPAGE");
	strcpy(link.host, "HOMEPAGE");
	strcpy(link.prevHost, "HOMEPAGE");
	link.port = 70;
	OS_SETSYSDRV();
	OS_DELETE("browser/ng_hist.dat");
	get_dns();
	loadNVext();
	loadEspConfig();

	netDriver = readParamFromIni();
	if (netDriver == 1)
	{
		uart_init(divider);
		espReBoot();
	}

	initMouse();
	clock.oldMinutes = 255;
}
void newPage(void)
{
	navi.page = 0;
	navi.maxPage = 32767;
	navi.maxVolume = 32767;
	navi.linePage = 0;
	navi.lineSelect = 1;
	navi.prevLineSelect = 2;
	navi.bufPos = 0;
	navi.nextBufPos = 0;
	volumeOffsets[0] = 0;
	navi.lastLine = 0;
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
	case 'h': // html
		putchar('H');
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
	unsigned int flag = true;

	link.type = '0';

	OS_CLS(0);
	mainWinDraw();
	OS_SETCOLOR(7);
	OS_SETXY(0, 1);

	counter = 0;
	do
	{
		unsigned int byte;
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

	link.type = '1';

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
				navi.lastLine = counter;
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

void reDraw(void)
{
	if (link.type == '0')
	{
		navi.nextBufPos = renderPlain(pageOffsets[navi.page]);
	}
	else
	{
		if (link.type == '1')
		{
			navi.nextBufPos = renderPage(pageOffsets[navi.page]);
		}
	}
}

void errorBox(struct window w, const char *message)
{
	unsigned char wcount, tempx, tittleStart;

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
	tittleStart = w.x + (w.w / 2) - (strlen(message) / 2);
	OS_SETXY(tittleStart, w.y + 1);
	printf("%s", message);
}

unsigned char inputBox(struct window w, const char *prefilled)
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

	cmd[0] = 0;

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

				if (counter == 0)
				{
					return false;
				}
				else
				{
					return true;
				}

			case 31:
				break;
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
		YIELD();
	} while (42);
	return false;
}

void pusHistory(void)
{
	FILE *hf;
	unsigned int structSize;
	unsigned long filePos;
	if (link.type == '7')
	{
		return;
	}

	navi.history++;
	structSize = sizeof(struct linkStruct);
	filePos = structSize * (navi.history - 1);

	OS_SETSYSDRV();

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
	memcpy(&heap, &link, structSize);
	OS_WRITEHANDLE(heap, hf, structSize);
	OS_CLOSEHANDLE(hf);
}

void popHistory(void)
{
	FILE *hf;
	unsigned int structSize;
	unsigned long filePos;
	navi.history--;
	structSize = sizeof(struct linkStruct);
	filePos = structSize * (navi.history - 1);
	OS_SETSYSDRV();
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

void goHome(char backSpace)
{
	OS_SETSYSDRV();
	if (loadPageFromDisk("browser/nedogoph.gph", 0))
	{
		newPage();
		link.type = '1';
		strcpy(link.host, "HOMEPAGE");
		if (!backSpace)
		{
			pusHistory();
		}
		navi.nextBufPos = renderPage(navi.nextBufPos);
	}
	else
	{
		newPage();
		clearNetBuf(sizeof(netbuf));
		OS_CLS(0);
		mainWinDraw();
	}
}

void errNoConnect(void)
{

	if (strcmp(link.host, "HOMEPAGE") == 0)
	{
		goHome(false);
		return;
	}

	curWin.w = 50;
	curWin.x = 80 / 2 - curWin.w / 2 - 1;
	curWin.y = 10;
	curWin.h = 1;
	curWin.text = 215;
	curWin.back = 215;
	strcpy(curWin.tittle, "Ошибка открытия страницы");
	strcpy(cmd, "Нет соединения с ");
	strcat(cmd, link.host);
	errorBox(curWin, cmd);
	strcpy(link.host, link.prevHost);
	waitKey();

	switch (link.type)
	{
	case '0':
		OS_SETSYSDRV();
		loadPageFromDisk("browser/current.txt", 0);
		navi.nextBufPos = renderPlain(pageOffsets[navi.page]);
		break;
	case '1':
		OS_SETSYSDRV();
		loadPageFromDisk("browser/current.gph", 0);
		navi.nextBufPos = renderPage(pageOffsets[navi.page]);
		break;
	default:
		OS_SETSYSDRV();
		loadPageFromDisk("browser/current.gph", 0);
		navi.nextBufPos = renderPage(pageOffsets[navi.page]);
		break;
	}
}

char getFileEsp(unsigned char *fileNamePtr)
{
	int todo;
	unsigned char byte;
	unsigned long downloaded = 0;

	if ((strlen(link.path) == 1 && link.path[0] == '/') || strlen(link.path) == 0)
	{
		strcpy(link.path, "\r\n");
	}
	else
	{
		strcat(link.path, "\r\n");
	}

	sprintf(cmd, "AT+CIPSTART=\"TCP\",\"%s\",%u", link.host, link.port);
	sendcommand(cmd);
	do
	{
		getAnswer3(); // CONNECT or ERROR or link is not valid

		if (strstr(netbuf, "CONNECT") != NULL)
		{
			break;
		}
		else
		{
			if (strstr(netbuf, "ERROR") != NULL)
			{
				return false;
			}
		}
	} while (42); // Try until endo of the days recieve CONNECT or ERROR

	getAnswer3(); // OK

	sprintf(cmd, "AT+CIPSEND=%u", strlen(link.path)); // second CRLF in send command
	sendcommand(cmd);
	getAnswer3();

	do
	{
		byte = uartReadBlock();
	} while (byte != '>');

	sendcommandNrn(link.path);

	OS_DELETE(fileNamePtr);
	saveBuf(fileNamePtr, 00, 0);
	clearStatus();
	do
	{
		clearNetBuf(128);
		todo = recvHead();
		downloaded = downloaded + todo;
		if (downloaded == 0)
		{
			return false;
		}
		getdataEsp(todo);
		saveBuf(fileNamePtr, 01, todo);
		printf("%lu kb  \r", downloaded / 1024);
	} while (todo != 0);
	link.size = downloaded;
	saveBuf(fileNamePtr, 02, 00);
	return true;
}

char getFileNet(unsigned char *fileNamePtr)
{
	int todo;
	int socket;
	unsigned long downloaded = 0;

	if (!dnsResolve(link.host))
	{
		clearStatus();
		printf("Ошибка определения адреса '%s'", link.host);
		return false;
	}
	targetadr.porth = 00;
	targetadr.portl = link.port;

	// clearStatus();
	// printf("File:%s", fileNamePtr);
	// printf("\r\nAddress:%u.%u.%u.%u:%u\r\n", targetadr.b1, targetadr.b2, targetadr.b3, targetadr.b4, targetadr.porth * 256 + targetadr.portl);
	// waitKey();

	if ((strlen(link.path) == 1 && link.path[0] == '/') || strlen(link.path) == 0)
	{
		strcpy(link.path, crlf);
	}
	else
	{
		strcat(link.path, crlf);
	}
	socket = OpenSock(AF_INET, SOCK_STREAM);
	if (socket < 0)
	{
		return false;
	}
	todo = netConnect(socket, 1);
	if (todo < 0)
	{
		return false;
	}
	todo = tcpSend(socket, (unsigned int)&link.path, strlen(link.path), 1);
	if (todo < 0)
	{
		return false;
	}
	saveBuf(fileNamePtr, 00, 0);
	clearStatus();
	do
	{
		todo = tcpRead(socket, 3);
		if (todo < 1)
		{
			break;
		}

		downloaded = downloaded + todo;
		printf("%lu kb    \r", downloaded / 1024);
		saveBuf(fileNamePtr, 01, todo);
	} while (42);
	saveBuf(fileNamePtr, 02, 00);
	clearStatus();
	netShutDown(socket, 0);
	link.size = downloaded;
	if (downloaded == 0)
	{
		clearStatus();
		printf("Ошибка получения данных от '%s' (%u.%u.%u.%u:%u)", link.host, targetadr.b1, targetadr.b2, targetadr.b3, targetadr.b4, targetadr.porth * 256 + targetadr.portl);
		return false;
	}
	return true;
}

char getFile(unsigned char *fileNamePtr)
{
	int result;
	switch (netDriver)
	{
	case 0:
		result = getFileNet(fileNamePtr);
		break;
	case 1:
		do
		{
			result = getFileEsp(fileNamePtr);
		} while (result == 0);
		break;

	default:
		break;
	}
	return result;
}

unsigned char selectorProcessor(void)
{
	unsigned int startSearch = 0, lineSearch = 0, SelectedPos, counter1 = 0;
	unsigned char byte;

	if (link.type == '0' || navi.lineSelect > navi.lastLine) // Если текущая страница текстовая, нечего по ней тыкать или тыкнули ниже низа.
	{
		// clearStatus();
		// printf("[%c]Cтраница текстовая или [%u>%u]тыкнули ниже низа.", link.type, navi.lineSelect, navi.lastLine);
		return false;
	}

	startSearch = pageOffsets[navi.page];

	do
	{
		byte = netbuf[startSearch + counter1];

		if (byte == 0x0a)
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

	strcpy(link.prevHost, link.host);
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

char extractName(void)
{
	unsigned int counter, counter2 = 0, lng, byte, source;
	unsigned char ext2[128];
	const unsigned char *count1;

	lng = strlen(link.path);

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

	if (navi.saveAs)
	{
		curWin.w = 61;
		curWin.x = 80 / 2 - curWin.w / 2 - 1;
		curWin.y = 10;
		curWin.h = 1;
		curWin.text = 103;
		curWin.back = 103;
		strcpy(curWin.tittle, "Введите имя файла");

		// navi.fileName[64] = 0;

		if (inputBox(curWin, navi.fileName))
		{
			strcpy(navi.fileName, cmd);
		}
		else
		{
			return false;
		}
	}
	else // Play It
	{
		count1 = strstr(navi.fileName, ".");
		if (count1 == NULL)
		{
			clearStatus();
			printf("Ошибка определения типа файла, не найдено расширение. [%s]", navi.fileName);
			waitKey();
			return false;
		}
		else
		{
			strcpy(ext2, count1 + 1);
			strcpy(navi.fileName, "current.");
			strcat(navi.fileName, ext2);
		}
	}
	return true;
}

int pos(unsigned char *s, unsigned char *c, unsigned int n, unsigned int startPos)
{
	unsigned int i, j;
	unsigned int lenC, lenS;

	for (lenC = 0; c[lenC]; lenC++)
		;
	for (lenS = 0; s[lenS]; lenS++)
		;

	for (i = startPos; i <= lenS - lenC; i++)
	{
		for (j = 0; s[i + j] == c[j]; j++)
			;

		if (j - lenC == 1 && i == lenS - lenC && !(n - 1))
			return i;
		if (j == lenC)
			if (n - 1)
				n--;
			else
				return i;
	}
	return -1;
}

unsigned char mediaProcessorExt(void)
{
	// unsigned char ext[65];
	unsigned char extLow[4];
	unsigned char extUp[4];
	unsigned char byte;
	const unsigned char *count1;
	unsigned int counter, counter2, next, curPosition;
	int n;

	count1 = strstr(navi.fileName, ".");
	if (count1 == NULL)
	{
		clearStatus();
		printf("Ошибка определения типа файла, не найдено расширение. [%s]", navi.fileName);
		waitKey();
	}

	counter = strlen(navi.fileName);
	do
	{
		counter--;
		if (navi.fileName[counter] == '.')
		{

			for (counter2 = 0; counter2 < 3; counter2++)
			{
				extLow[counter2] = tolower(navi.fileName[counter + counter2 + 1]);
				extUp[counter2] = toupper(navi.fileName[counter + counter2 + 1]);
			}
			extUp[3] = 0;
			extLow[3] = 0;
			// printf("[%s]\r\n[%s]\r\n", extLow, extUp);
			break;
		}

	} while (counter != 0);

	next = 1;
	curPosition = 0;
	do
	{
		// n = -1;
		n = pos(nvext, extLow, next, curPosition);
		curPosition = n;
		if (n == -1)
		{
			curPosition = 0;
			n = pos(nvext, extUp, next, curPosition);
			curPosition = n;
			if (n == -1)
			{
				clearStatus();
				printf("[ext]не найдено соответствие к расширению [%s][%s]", extLow, extUp);
				waitKey();
				return false;
			}
		}
		else
		{
			counter = 0;
			do
			{
				byte = nvext[n + counter];
				if (byte == 0x0d)
				{
					next++;
					break;
				}

				if (byte == ':')
				{
					counter++;
					counter2 = 0;

					while (nvext[n + counter] == ' ')
					{
						counter++;
					}

					do
					{
						byte = nvext[n + counter];
						cmd[counter2] = byte;
						counter++;
						counter2++;
					} while (byte != 0x0d);
					cmd[counter2 - 1] = ' ';
					cmd[counter2] = 0;
					strcat(cmd, " ");
					strcat(cmd, curPath);
					strcat(cmd, "/current.");
					strcat(cmd, extLow);
					return true;
				}
				counter++;
			} while (42);
		}
	} while (42);
	return false;
}

void doLink(char backSpace)
{
	unsigned char *count1;
	if (strcmp(link.host, "HOMEPAGE") == 0)
	{
		goHome(backSpace);
		return;
	}

	switch (link.type) // Тут уже новый элемент
	{
	case 'i':
		link.type = link.nexType; // так-как мы остались на странице, восстановим тип, хотя можно просто ставить 1 (пока других нет)
		return;
	case '0': // plain texts
		if (getFile("browser/current.txt"))
		{
			newPage();
			OS_SETSYSDRV();
			loadPageFromDisk("browser/current.txt", 0);
			if (!backSpace)
			{
				pusHistory();
			}
			navi.nextBufPos = renderPlain(navi.nextBufPos);
		}
		else
		{
			errNoConnect();
		}
		return;
	case '1': // gopher page
		if (getFile("browser/current.gph"))
		{
			newPage();
			OS_SETSYSDRV();
			loadPageFromDisk("browser/current.gph", 0);
			if (!backSpace)
			{
				pusHistory();
			}
			navi.nextBufPos = renderPage(navi.nextBufPos);
		}
		else
		{

			errNoConnect();
		}
		return;
	case '7': // search input
		curWin.w = 40;
		curWin.x = 80 / 2 - curWin.w / 2 - 1;
		curWin.y = 10;
		curWin.h = 1;
		curWin.text = 95;
		curWin.back = 95;
		strcpy(curWin.tittle, "Введите поисковый запрос");
		if (inputBox(curWin, ""))
		{
			strcat(link.path, "\t");
			strcat(link.path, cmd);
			if (getFile("browser/current.gph"))
			{
				newPage();
				OS_SETSYSDRV();
				loadPageFromDisk("browser/current.gph", 0);
				navi.nextBufPos = renderPage(navi.nextBufPos);
				link.type = '1';
			}
			else
			{
				reDraw();
				errNoConnect();
			}
		}
		else
		{
			link.type = '1';
			reDraw();
			return;
		}
		return;
	case 'g': // gif pic
	case 'I': // image
	case 's': // sound
	case '9': // binary (pt3/scr)
	case '8':
	case '6':
	case '5':
	case '4':
		if (!extractName())
		{
			link.type = '1';
			reDraw();
			return;
		}
		OS_CHDIR("/");
		OS_CHDIR("downloads");
		OS_GETPATH((unsigned int)&curPath);

		if (getFile(navi.fileName))
		{
			OS_SETSYSDRV();
			loadPageFromDisk("browser/current.gph", 0);
			navi.nextBufPos = renderPage(pageOffsets[navi.page]);
			if (!navi.saveAs)
			{
				if (mediaProcessorExt())
				{
					OS_CHDIR("/");
					OS_CHDIR("downloads");
					clearStatus();
					printf("cmd:[%s]", cmd);
					OS_SHELL(cmd);
					OS_SETSYSDRV();
				}
			}
		}
		else
		{
			errNoConnect();
		}
		return;
	case 'h': // html
		clearStatus();

		count1 = strstr(link.path, "http");
		if (count1 == NULL)
		{
			count1 = strstr(link.path, "HTTP");
			if (count1 == NULL)
			{
				clearStatus();
				printf("Не удалось получить ссылку [%s]", link.path);
				link.type = link.nexType;
				return;
			}
		}
		sprintf(cmd, "browser.com %s", count1);
		OS_SHELL(cmd);
		OS_SETSYSDRV();
		link.type = '1';
		break;
	default:
		clearStatus();
		printf("Неизвестный селектор:[%u]lineselect[%u]linelast[%u]", link.type, navi.lineSelect, navi.lastLine);
		link.type = link.nexType;
		return;
	}
}

void activate(void)
{
	if (!selectorProcessor())
	{
		return;
	}
	doLink(false);
}

void enterDomain(void)
{
	curWin.w = 40;
	curWin.x = 80 / 2 - curWin.w / 2 - 1;
	curWin.y = 10;
	curWin.h = 1;
	curWin.text = 207;
	curWin.back = 207;
	strcpy(curWin.tittle, "Введите адрес Gopher сервера");

	if (inputBox(curWin, ""))
	{
		strcpy(link.prevHost, link.host);
		link.type = '1';
		strcpy(link.host, cmd);
		strcpy(link.path, "/");
		link.port = 70;
		doLink(false);
	}
	else
	{
		reDraw();
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
	case 0x0d:
		activate();
		break;
	case 0x08: // BS
		if (navi.history > 1)
		{
			popHistory();
			doLink(true);
		}
		break;
	case 31: // screen redraw
		renderPage(pageOffsets[navi.page]);
		break;
	case 'h':
	case 'H':
		goHome(false);
		break;
	case 'd':
	case 'D':
		enterDomain();
		break;
	case 's':
	case 'S':
		navi.saveAs = !navi.saveAs;
		mainWinDraw();
		break;
	case 'i':
	case 'I':
		netDriver = !netDriver;
		mainWinDraw();
		if (netDriver)
		{
			uart_init(divider);
			espReBoot();
		}
		break;
	case 'm':
	case 'M':
		mouse.classic = !mouse.classic;
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
	case 248: // Left
	case 250: // Up

		if (navi.page == 0)
		{
			if (navi.volume == 0)
			{
				break;
			}
			navi.volume--;
			newPage();
			OS_SETSYSDRV();
			loadPageFromDisk("browser/current.txt", navi.volume);
			navi.nextBufPos = renderPlain(navi.nextBufPos);
			break;
		}
		navi.page--;
		navi.nextBufPos = pageOffsets[navi.page];
		navi.lineSelect = screenHeight;
		navi.nextBufPos = renderPlain(navi.nextBufPos);
		break;
	case 251: // Right
	case 249: // down
		if (navi.page == navi.maxPage)
		{
			if (navi.volume == navi.maxVolume)
			{
				break;
			}
			navi.volume++;
			newPage();
			OS_SETSYSDRV();
			loadPageFromDisk("browser/current.txt", navi.volume);
			navi.nextBufPos = renderPlain(navi.nextBufPos);
			break;
		}
		navi.page++;
		pageOffsets[navi.page] = navi.nextBufPos;
		navi.lineSelect = 1;
		navi.nextBufPos = renderPlain(navi.nextBufPos);
		break;
	case 0x08: // BS
		if (navi.history > 1)
		{
			popHistory();
			doLink(true);
		}
		break;
	case 31: // screen redraw
		renderPlain(pageOffsets[navi.page]);
		break;
	case 'h':
	case 'H':
		goHome(false);
		break;
	case 'd':
	case 'D':
		enterDomain();
		break;
	case 's':
	case 'S':
		navi.saveAs = !navi.saveAs;
		mainWinDraw();
		break;
	case 'i':
	case 'I':
		netDriver = !netDriver;
		mainWinDraw();
		if (netDriver)
		{
			uart_init(divider);
			espReBoot();
		}
		break;
	case 'm':
	case 'M':
		mouse.classic = !mouse.classic;
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
	default:
		clearStatus();
		printf("Unknown link.type, [%d]", link.type);
		waitKey();
		break;
	}
}

unsigned char getMouse(void)
{
	unsigned long mouseRaw;
	unsigned int mouseMove;
	unsigned int mouseButtons;
	int mouseScroll = 0;
	int mouseXpos;
	int mouseYpos;
	int dx, dy;
	mouseRaw = OS_GETMOUSE();

	mouseMove = mouseRaw >> 16;
	mouseButtons = mouseRaw;

	if (mouseMove != mouse.prevMouseMove)
	{
		OS_SETXY(mouse.cursXpos, mouse.cursYpos);
		OS_PRATTR(mouse.oldAtr);
		mouse.prevMouseMove = mouseMove;

		mouse.prevMouseXpos = mouse.mouseXpos;
		mouse.prevMouseYpos = mouse.mouseYpos;

		mouse.mouseXpos = mouseRaw >> 16;
		mouse.mouseYpos = mouseRaw >> 24;

		if (mouse.classic)
		{
			mouse.cursXpos = mouse.mouseXpos / 3;
			mouse.cursYpos = 25 - mouse.mouseYpos / 10;
		}
		else
		{
			mouseXpos = mouse.mouseXpos - mouse.prevMouseXpos;
			mouseYpos = mouse.mouseYpos - mouse.prevMouseYpos;

			dx = abs(mouseXpos / 2);
			dy = abs(mouseYpos / 2);

			if (dx == 0)
				dx = 1;
			if (dy == 0)
				dy = 1;
			if (dx > 3)
				dx = 3;
			if (dy > 2)
				dy = 2;

			if (mouseXpos < -250)
			{
				mouseXpos = 1;
			}
			else if (mouseXpos > 250)
			{
				mouseXpos = -1;
			}

			if (mouseYpos < -254)
			{
				mouseYpos = 1;
			}
			else if (mouseYpos > 254)
			{
				mouseYpos = -1;
			}

			if (mouseXpos < 0)
			{
				mouse.cursXpos = mouse.cursXpos - dx;
			}
			else if (mouseXpos > 0)
			{
				mouse.cursXpos = mouse.cursXpos + dx;
			}

			if (mouse.divider == 0)
			{
				if (mouseYpos > 0)
				{
					mouse.cursYpos = mouse.cursYpos - dy;
				}
				else if (mouseYpos < 0)
				{
					mouse.cursYpos = mouse.cursYpos + dy;
				}
				mouse.divider = 2;
			}
			mouse.divider--;
			// clearStatus();
			// printf("dx=%d dy=%d X=%d Y=%d", dx, dy, mouse.mouseXpos, mouse.mouseYpos);

			if (mouse.cursXpos > 79)
			{
				mouse.cursXpos = 79;
			}
			if (mouse.cursYpos > 24)
			{
				mouse.cursYpos = 24;
			}

			if (mouse.cursXpos < 0)
			{
				mouse.cursXpos = 0;
			}
			if (mouse.cursYpos < 0)
			{
				mouse.cursYpos = 0;
			}
		}
		OS_SETXY(mouse.cursXpos, mouse.cursYpos);
		mouse.oldAtr = OS_GETATTR();
		OS_PRATTR(215);
	}

	if (mouseButtons != mouse.prevMouseButtons)
	{

		mouse.prevWheel = mouse.wheel;
		mouse.wheel = (mouseButtons >> 4) & 15;
		mouse.mmb = (mouseButtons >> 2) & 1;
		mouse.rmb = (mouseButtons >> 1) & 1;
		mouse.lmb = mouseButtons & 1;
	}

	// clearStatus();
	// printf("lmb:[%d] rmb:[%d] mmb:[%d] wheel:[%02d] X:[%03d] Y:[%03d] cursX:[%02d] cursY:[%02d]", mouse.lmb, mouse.rmb, mouse.mmb, mouse.wheel, mouse.mouseXpos, mouse.mouseYpos, mouse.cursXpos, mouse.cursYpos);

	OS_SETXY(mouse.cursXpos, mouse.cursYpos);

	mouseScroll = mouse.wheel - mouse.prevWheel;

	if (mouseScroll < -12)
	{
		mouseScroll = 1;
	}
	else if (mouseScroll > 12)
	{
		mouseScroll = -1;
	}

	if (mouseScroll < 0)
	{
		navigation(248); // Left
	}
	else if (mouseScroll > 0)
	{
		navigation(251); // Right
	}
	mouse.prevWheel = mouse.wheel;

	return mouseButtons >> 8;
}

C_task main(int argc, const char *argv[])
{
	unsigned char keypress;
	OS_SETGFX(0x86);
	OS_CLS(0);
	OS_SETSYSDRV();
	init();
	OS_HIDEFROMPARENT();

	goHome(false);

	do
	{
		keypress = getMouse();
		if (mouse.lmb == 0)
		{
			if (mouse.cursYpos > 0 && mouse.cursYpos < screenHeight + 1)
			{
				navi.prevLineSelect = navi.lineSelect;
				navi.lineSelect = mouse.cursYpos;
				activate();
				OS_SETXY(mouse.cursXpos, mouse.cursYpos);
				OS_PRATTR(215);
			}
			else
			{
				if (mouse.cursYpos == 0)
				{
					enterDomain();
				}
			}
		}
		else if (mouse.rmb == 0)
		{
			popHistory();
			doLink(true);
		}

		if (keypress != 0)
		{
			navigation(keypress);

			//	printf("keypress [%d]", keypress);
		}
		YIELD();
		drawClock();
	} while (keypress != 27);
	OS_DELETE("browser/current.gph");
	OS_DELETE("browser/current.txt");
	OS_DELETE("browser/ng_hist.dat");
}
