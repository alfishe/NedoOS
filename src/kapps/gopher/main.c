#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <stdlib.h>
#include <oscalls.h>
#include <../common/terminal.c>
#include <tcp.h>
#include <espnet.h>
#include <osfs.h>
#include <graphic.h>
#include <ctype.h>
#include <math.h>

///
#define true 1
#define false 0
#define screenHeight 23
#define SCREEN_WIDTH 80
#define MAX_PAGES_TOTAL 150
#define NETBUF_SIZE 25500

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

unsigned char uVer[] = "2.0";
unsigned char curPath[128];
unsigned char cmd[512];
unsigned long volumeOffsets[32];
unsigned int pageOffsets[MAX_PAGES_TOTAL];
unsigned char pageVolumes[MAX_PAGES_TOTAL];

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
	unsigned char tittle[SCREEN_WIDTH];
} curWin;

struct time
{
	unsigned int hours;
	unsigned int minutes;
	unsigned char oldMinutes;

} clock;

unsigned char nvext[1024];
unsigned char netbuf[NETBUF_SIZE];
unsigned char colors[25];
FILE *fp2;

void clearNetBuf(unsigned int size)
{
	if (size > sizeof(netbuf))
	{
		size = sizeof(netbuf);
	}
	memset(netbuf, 0, size);
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

///////////////////////////
#include <../common/esp-com.c>
#include <../common/network.c>
#define ESPNET_CLIENT_ONLY 1
#include <../common/espnet.c>
#include <../common/espnet-net.c>
//////////////////////////

char readParamFromIni(void)
{
	FILE *fpini;
	unsigned char *count1;
	const char currentNetwork[] = "currentNetwork";
	unsigned char curNet = 0;

	OS_GETPATH(curPath);
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
	spaces(SCREEN_WIDTH);
	OS_SETXY(0, 0);
	printf("NedoGopher %s", uVer);

	OS_SETXY(39 - strlen(link.host) / 2, 0);
	printf("%s", link.host);

	OS_SETXY(55, 0);

	if (netDriver == 2)
		printf("[ESPNET]");
	else if (netDriver == 1)
		printf("[ESP-COM]");
	else
		printf("[NEDONET]");
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
	unsigned char appCmd[128];
	unsigned int shellSize, loop;
	unsigned char pgbak;
	union APP_PAGES shell_pg;
	union APP_PAGES main_pg;
	FILE *fp3;
	unsigned char *targetAddr;
	unsigned int cmdLen; /* Переменная для точной длины */

	/* Безопасное построение командной строки */
	strcpy((char *)appCmd, "term.com ");
	/* 128 всего - 9 (term.com ) - 1 (для гарантированного нуля) = 118 */
	strncat((char *)appCmd, command, 118);

	main_pg.l = OS_GETMAINPAGES();
	pgbak = main_pg.pgs.window_3;
	OS_GETPATH(curPath);
	OS_SETSYSDRV();

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

	/* Включаем страницу нового процесса в верхнее окно */
	SETPG32KHIGH(shell_pg.pgs.window_0);

	/* ИСПРАВЛЕНИЕ: Считаем точную длину строки с учетом терминатора */
	cmdLen = strlen((char *)appCmd) + 1;

	/* Копируем в память процесса ТОЛЬКО саму строку и её завершающий ноль */
	memcpy((unsigned char *)(0xC080), appCmd, cmdLen);

	/* ОПТИМИЗАЦИЯ ЗАГРУЗКИ */
	loop = 0;
	targetAddr = (unsigned char *)0xC100;

	while (loop < shellSize)
	{
		unsigned int loaded;
		loaded = OS_READHANDLE(targetAddr, fp3, shellSize - loop);

		if (loaded == 0)
			break;

		loop += loaded;
		targetAddr += loaded;
	}

	OS_CLOSEHANDLE(fp3);
	SETPG32KHIGH(pgbak);

	OS_RUNAPP(shell_pg.pgs.pId);
	return shell_pg.pgs.pId;
}

char loadPageFromDisk(unsigned char *filepath, unsigned int volume)
{
	unsigned int todo;
	unsigned int loaded = 0; /* Изменили long на 16-битный int */
	unsigned int cleanMax;
	FILE *fp1;

	fp1 = OS_OPENHANDLE(filepath, 0x80);
	if (((int)fp1) & 0xff)
	{
		clearStatus();
		printf("%s opening error. ", filepath);
		return false; /* false/true (0/1) в стиле C89 */
	}

	OS_SEEKHANDLE(fp1, volumeOffsets[volume]);

	/* Цикл чтения: убрали лишние проверки и 32-битные вычисления */
	do
	{
		/* sizeof(netbuf) - loaded ? это 16-битная арифметика, Z80 делает её мгновенно */
		if ((sizeof(netbuf) - loaded) < 512)
		{
			break;
		}

		todo = OS_READHANDLE(netbuf + loaded, fp1, 512);
		loaded += todo;

	} while (todo != 0);

	OS_CLOSEHANDLE(fp1);

	/* Безопасно закрываем строку нулем строго на границе данных */
	if (loaded < sizeof(netbuf))
	{
		netbuf[loaded] = 0;
	}

	if (todo == 0)
	{
		navi.maxVolume = volume;
	}

	/* Смещение для следующего тома (16-битное или 32-битное сложение, зависит от типа массива) */
	volumeOffsets[volume + 1] = volumeOffsets[volume] + loaded;

	/* Элегантная и быстрая очистка хвоста (максимум 128 байт) без long-арифметики */
	cleanMax = loaded + 128;
	if (cleanMax > sizeof(netbuf) || cleanMax < loaded) /* Защита от переполнения 16 бит */
	{
		cleanMax = sizeof(netbuf);
	}

	while (loaded < cleanMax)
	{
		netbuf[loaded++] = 0; /* Компилятор преобразует в эффективный инкремент указателя */
	}

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

void applyNetDriver(void)
{
	if (netDriver == 1)
	{
		loadEspConfig();
		uart_init((unsigned char)divider);
		espReBoot();
	}
	else if (netDriver == 2)
	{
		OS_ESPINIT();
		EspGetDns();
	}
	else
		get_dns();
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
	loadNVext();

	netDriver = readParamFromIni();
	applyNetDriver();

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
	navi.lastLine = 0;
	navi.volume = 0;

	memset(volumeOffsets, 0, sizeof(volumeOffsets));
	memset(pageOffsets, 0, sizeof(pageOffsets));
	memset(pageVolumes, 0, sizeof(pageVolumes));
}

void renderType(unsigned char linkType)
{
	OS_SETCOLOR(70); // Ярко-желтый

	switch (linkType)
	{
	case 'i':
		colors[navi.lastLine] = 7;
		OS_SETCOLOR(7);
		putchar(' ');
		return;
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
		colors[navi.lastLine] = 7;
		OS_SETCOLOR(7);
		putchar(linkType);
		return;
	}
	colors[navi.lastLine] = 5;
	OS_SETCOLOR(5);
}
/* current.txt for plaintext, current.gph for menus (link.type set by render*). */
static unsigned char *browserCachePath(void)
{
	if (link.type == '0')
		return (unsigned char *)"browser/current.txt";
	return (unsigned char *)"browser/current.gph";
}

/**
 * Hot-load next volume during render (plain or gopher menu).
 * Kept separate so the main render loops stay register-friendly.
 */
static unsigned char switchInternalVolume(void)
{
	if (navi.volume < navi.maxVolume)
	{
		navi.volume++;
		OS_SETSYSDRV();
		loadPageFromDisk(browserCachePath(), navi.volume);
		return 1;
	}
	return 0;
}

/**
 * Renders a page of plain text from the network buffer to the screen.
 *
 * @param bufPos The starting position in the netbuf buffer to begin rendering from.
 * @return The new buffer position after rendering the page.
 */
unsigned int renderPlain(unsigned int bufPos)
{
	unsigned int lookAheadPos;
	unsigned char counter = 0;
	unsigned char colCount = 0;
	unsigned char byte;
	unsigned char wordLength;
	unsigned char nextByte;
	char justWrapped = 0;

	link.type = '0';

	OS_CLS(0);
	mainWinDraw();

	clearStatus();
	// Быстрый расчет позиции для статус-бара через сдвиг
	printf(" Position: %u/%lu kb | Page: %u ",
		   (unsigned int)((volumeOffsets[navi.volume] + bufPos) >> 10),
		   (unsigned long)(link.size >> 10), navi.page + 1);

	OS_SETCOLOR(7);
	OS_SETXY(0, 1);

	do
	{
		byte = netbuf[bufPos];

		// 1. КОНЕЦ ДАННЫХ В ТЕКУЩЕМ БУФЕРЕ (ГОРЯЧАЯ СКЛЕЙКА ТОМОВ)
		if (byte == 0)
		{
			// Пытаемся подгрузить следующий том прямо на лету
			if (switchInternalVolume())
			{
				bufPos = 0; // Новый том читаем с самого начала
				justWrapped = 0;
				continue; // Продолжаем рендерить эту же страницу без разрывов!
			}
			else
			{
				// Если томов больше нет ? это реальный конец файла
				navi.maxPage = navi.page;
				return bufPos;
			}
		}

		// 2. Обработка явного переноса строки (\r или \n)
		if (byte == 0xd || byte == 0xa)
		{
			if (!justWrapped)
			{
				putchar('\n');
				counter++;
			}
			colCount = 0;
			justWrapped = 0;
			bufPos++;

			if (byte == 0xd && netbuf[bufPos] == 0xa)
			{
				bufPos++;
			}
			continue;
		}

		// 3. ОПТИМИЗИРОВАННАЯ ЛОГИКА WORD WRAP (ПЕРЕНОС СЛОВ)
		if (byte != ' ' && byte != '\t' && colCount > 0)
		{
			// Проверка на начало слова: буфер только начался ИЛИ предыдущий символ был пробелом/табом
			if (bufPos == 0 || netbuf[bufPos - 1] == ' ' || netbuf[bufPos - 1] == '\t')
			{
				lookAheadPos = bufPos;

				// Быстрый линейный поиск конца слова
				// Z80 быстрее обрабатывает инкремент указателя, чем постоянное сложение lookAheadPos + wordLength
				while (1)
				{
					nextByte = netbuf[lookAheadPos];

					// Агрегированная проверка на терминаторы (0, пробельные символы и перенос)
					// Компиляторы под Z80 генерируют отличный код, когда проверки идут "от меньшего к большему"
					if (nextByte <= '\t') // Покрывает \0 (0) и \t (9)
					{
						if (nextByte == 0 || nextByte == '\t')
							break;
					}
					else if (nextByte <= ' ') // Покрывает \n (10), \r (13) и пробел (32)
					{
						if (nextByte == ' ' || nextByte == 0xd || nextByte == 0xa)
							break;
					}

					lookAheadPos++;

					// Если слово длиннее, чем ширина экрана, нет смысла искать дальше
					if ((unsigned int)(lookAheadPos - bufPos) > 80)
					{
						break;
					}
				}

				wordLength = (unsigned char)(lookAheadPos - bufPos);

				// Проверяем, помещается ли слово на текущей строке
				if (wordLength <= 80 && wordLength > (80 - colCount))
				{
					if ((unsigned char)(counter + 1) >= (unsigned char)screenHeight)
					{
						return bufPos;
					}
					putchar('\n');
					counter++;
					colCount = 0;
					justWrapped = 1;
				}
			}
		}

		// 4. Вывод текущего символа
		putchar(byte);
		colCount++;
		bufPos++;
		justWrapped = 0;

		// 5. Логика автопереноса по ширине экрана (80 символов)
		if (colCount >= 80)
		{
			counter++;
			colCount = 0;
			justWrapped = 1;

			while (netbuf[bufPos] == ' ' || netbuf[bufPos] == '\t')
			{
				bufPos++;
			}
		}

	} while (counter < (unsigned char)screenHeight);

	return bufPos;
}

/**
 * Renders a page of gopher directory entries from the network buffer to the screen.
 *
 * @param bufPos The starting position in the netbuf buffer to begin rendering from.
 * @return The new buffer position after rendering the page.
 */
unsigned int renderPage(unsigned int bufPos)
{
	unsigned char counter = 0;
	unsigned char colCount = 0;
	unsigned char byte;
	register unsigned char *ptr = netbuf + bufPos;

	navi.lastLine = 0;
	link.type = '1';

	OS_CLS(0);
	mainWinDraw();
	OS_SETXY(0, 1);

	/* Skip leading NULs / empty volume head (after a prior hot-switch edge). */
	while (*ptr == 0)
	{
		if (!switchInternalVolume())
		{
			navi.maxPage = navi.page;
			navi.lastLine = 0;
			return (unsigned int)(ptr - netbuf);
		}
		ptr = netbuf;
	}

	renderType(*ptr);

	do
	{
		/* Name until TAB. First ptr++ skips the type byte already drawn. */
		while (1)
		{
			ptr++;
			byte = *ptr;

			if (byte == 0)
			{
				if (switchInternalVolume())
				{
					ptr = netbuf - 1; /* next ++ lands on first byte of new volume */
					continue;
				}
				navi.maxPage = navi.page;
				navi.lastLine = counter;
				return (unsigned int)(ptr - netbuf);
			}

			if (byte == 9)
			{
				putchar('\r');
				putchar('\n');
				break;
			}

			if (colCount < (unsigned char)(SCREEN_WIDTH - 3))
			{
				putchar(byte);
				colCount++;
			}
		}

		/* Skip selector/host/port until LF; may span volumes. */
		while (1)
		{
			ptr++;
			byte = *ptr;

			if (byte == 0)
			{
				if (switchInternalVolume())
				{
					ptr = netbuf - 1;
					continue;
				}
				navi.maxPage = navi.page;
				navi.lastLine = counter;
				return (unsigned int)(ptr - netbuf);
			}

			if (byte == 10)
			{
				colCount = 0;
				counter++;
				navi.lastLine = counter;
				ptr++;

				while (*ptr == 0)
				{
					if (!switchInternalVolume())
					{
						navi.maxPage = navi.page;
						navi.lastLine = counter;
						return (unsigned int)(ptr - netbuf);
					}
					ptr = netbuf;
				}

				if (*ptr == '.' && *(ptr + 1) < 32)
				{
					navi.maxPage = navi.page;
					navi.lastLine = counter;
					return (unsigned int)(ptr - netbuf);
				}

				if (counter < (unsigned char)screenHeight)
				{
					renderType(*ptr);
				}
				break;
			}
		}
	} while (counter < (unsigned char)screenHeight);

	navi.lastLine = counter;
	return (unsigned int)(ptr - netbuf);
}

void reDraw(void)
{
	OS_SETSYSDRV();
	navi.volume = pageVolumes[navi.page];
	if (link.type == '0')
	{
		loadPageFromDisk("browser/current.txt", navi.volume);
		navi.nextBufPos = renderPlain(pageOffsets[navi.page]);
	}
	else if (link.type == '1')
	{
		loadPageFromDisk("browser/current.gph", navi.volume);
		navi.nextBufPos = renderPage(pageOffsets[navi.page]);
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
	unsigned char byte;

	// Переменные редактора (объявлены строго в начале функции для IAR)
	unsigned char cmdLen;	  // Полная текущая длина строки cmd
	unsigned char cursorPos;  // Позиция курсора в строке (от 0 до cmdLen)
	unsigned char viewOffset; // Смещение просмотра для скроллинга длинного текста
	unsigned char visibleLen; // Сколько символов строки физически влезает в окно
	unsigned char i;		  // Индекс для циклов отрисовки
	unsigned char printPos;	  // Текущий индекс символа для вывода на экран

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

	// Инициализация строки cmd
	cmd[0] = 0;
	cmdLen = strlen(prefilled);
	if (cmdLen != 0)
	{
		strncpy(cmd, prefilled, sizeof(cmd) - 1);
		cmd[sizeof(cmd) - 1] = 0; // Гарантированный ноль на конце
	}

	// Настройка начального состояния курсора и скроллинга
	cursorPos = cmdLen;
	viewOffset = 0;
	visibleLen = w.w - 1; // Доступная ширина внутри рамки под текст и курсор

	for (;;)
	{
		// 1. АВТОСКРОЛЛИНГ: Корректируем окно видимости текста относительно курсора
		if (cursorPos < viewOffset)
		{
			viewOffset = cursorPos;
		}
		else if (cursorPos - viewOffset >= visibleLen)
		{
			viewOffset = cursorPos - visibleLen + 1;
		}

		// 2. ОТРИСОВКА СТРОКИ С ПОБИТОВОЙ ИНВЕРСИЕЙ ЦВЕТА КУРСOРА (Для NedoOS)
		OS_SETXY(w.x + 1, w.y + 1);

		for (i = 0; i < visibleLen; i++)
		{
			printPos = viewOffset + i;

			// Если в этой позиции находится курсор ? считаем инверсный байт атрибута
			if (printPos == cursorPos)
			{
				OS_SETCOLOR((unsigned char)(
					// 1. Формируем новый PAPER (из старого INK)
					((w.text & 0x40) << 1) | // Старый BRIGHT_INK (6) двигаем на место BRIGHT_PAPER (7)
					((w.text & 0x07) << 3) | // Старый INK (2-0) двигаем на место PAPER (5-3)

					// 2. Формируем новый INK (из старого PAPER)
					((w.text & 0x80) >> 1) | // Старый BRIGHT_PAPER (7) двигаем на место BRIGHT_INK (6)
					((w.text & 0x38) >> 3)	 // Старый PAPER (5-3) двигаем на место INK (2-0)
					));
			}
			else
			{
				OS_SETCOLOR(w.text); // Стандартный цвет окна (например, тот самый 207)
			}

			// Выводим символ или пробел на месте курсора
			if (printPos < cmdLen)
			{
				putchar(cmd[printPos]);
			}
			else
			{
				putchar(' '); // Зачищаем хвост строки или рисуем инверсный курсор-пробел в конце
			}
		}
		// Восстанавливаем цвет по умолчанию после завершения строки
		OS_SETCOLOR(w.text);

		YIELD(); // Обязательно уступаем квант времени ОС NedoOS

		byte = OS_GETKEY();
		if (byte != 0)
		{
			switch (byte)
			{
			case 248: // Left (Стрелка влево)
				if (cursorPos > 0)
				{
					cursorPos--;
				}
				break;

			case 251: // Right (Стрелка вправо)
				if (cursorPos < cmdLen)
				{
					cursorPos++;
				}
				break;

			case 0x08: // Backspace (Удаление символа СЛЕВА от курсора)
				if (cursorPos > 0 && cmdLen > 0)
				{
					// Сдвигаем хвост строки влево на 1 символ
					for (i = cursorPos - 1; i < cmdLen; i++)
					{
						cmd[i] = cmd[i + 1];
					}
					cursorPos--;
					cmdLen--;
				}
				break;

			case 252: // Delete (Удаление символа В ПОЗИЦИИ курсора)
				if (cursorPos < cmdLen && cmdLen > 0)
				{
					// Сдвигаем хвост строки начиная от курсора
					for (i = cursorPos; i < cmdLen; i++)
					{
						cmd[i] = cmd[i + 1];
					}
					cmdLen--;
				}
				break;

			case 0x0d: // Enter (Подтверждение ввода)
				if (cmdLen == 0)
				{
					return false;
				}
				return true;

			case 27: // Esc (Полная очистка и выход)
				cmd[0] = 0;
				return false;

			case 31:  // Игнорируем служебные клавиши навигации основного экрана
			case 250: // Up
			case 249: // Down
				break;

			default: // ВВОД СИМВОЛА (С поддержкой вставки в середину строки)
				// Проверяем, есть ли место в массиве cmd и влезает ли символ
				if (cmdLen < (sizeof(cmd) - 2) && byte >= 32)
				{
					// Раздвигаем строку вправо, освобождая место под символ
					for (i = cmdLen; i > cursorPos; i--)
					{
						cmd[i] = cmd[i - 1];
					}
					// Вставляем символ в позицию курсора
					cmd[cursorPos] = byte;
					cursorPos++;
					cmdLen++;
					cmd[cmdLen] = 0; // Корректно закрываем строку нулем
				}
				break;
			}
		}
	}
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
	filePos = (unsigned long)structSize * (navi.history - 1);

	OS_SETSYSDRV();

	// ОПТИМИЗАЦИЯ: Пересоздаем файл только ПРИ САМОЙ ПЕРВОЙ записи в историю.
	// В остальных случаях - сразу открываем на запись.
	if (navi.history == 1)
	{
		hf = OS_CREATEHANDLE("browser/ng_hist.dat", 0x80);
		if (((int)hf) & 0xff)
		{
			clearStatus();
			printf("History create error.");
			exit(0);
		}
		OS_CLOSEHANDLE(hf);
	}

	hf = OS_OPENHANDLE("browser/ng_hist.dat", 0x80);
	if (((int)hf) & 0xff)
	{
		clearStatus();
		printf("History open error.");
		exit(0);
	}

	OS_SEEKHANDLE(hf, filePos);
	OS_WRITEHANDLE((unsigned char *)&link, hf, structSize);
	OS_CLOSEHANDLE(hf);
}

char popHistory(void)
{
	FILE *hf;
	unsigned int structSize;
	unsigned long filePos;

	if (navi.history == 0)
	{
		return false;
	}

	navi.history--;
	structSize = sizeof(struct linkStruct);
	filePos = (unsigned long)structSize * (navi.history - 1);

	OS_SETSYSDRV();
	hf = OS_OPENHANDLE("browser/ng_hist.dat", 0x80);
	if (((int)hf) & 0xff)
	{
		clearStatus();
		printf("History open error.");
		exit(0);
	}

	OS_SEEKHANDLE(hf, filePos);
	OS_READHANDLE((unsigned char *)&link, hf, structSize);
	OS_CLOSEHANDLE(hf);
	return true;
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
	curWin.x = SCREEN_WIDTH / 2 - curWin.w / 2 - 1;
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

	navi.volume = pageVolumes[navi.page];
	switch (link.type)
	{
	case '0':
		OS_SETSYSDRV();
		loadPageFromDisk("browser/current.txt", navi.volume);
		navi.nextBufPos = renderPlain(pageOffsets[navi.page]);
		break;
	case '1':
		OS_SETSYSDRV();
		loadPageFromDisk("browser/current.gph", navi.volume);
		navi.nextBufPos = renderPage(pageOffsets[navi.page]);
		break;
	default:
		OS_SETSYSDRV();
		loadPageFromDisk("browser/current.gph", navi.volume);
		navi.nextBufPos = renderPage(pageOffsets[navi.page]);
		break;
	}
}

unsigned char quitDownload(void)
{
	unsigned char key;
	key = OS_GETKEY();
	if (key == 0)
	{
		return false;
	}
	return true;
}

char getFileEsp(unsigned char *fileNamePtr)
{
	int todo;
	unsigned char byte;
	unsigned long downloaded = 0;

	if ((strlen(link.path) == 1 && link.path[0] == '/') || strlen(link.path) == 0)
	{
		strncpy(link.path, "\r\n", sizeof(link.path) - 1);
	}
	else
	{
		strcat(link.path, "\r\n");
	}

	sprintf(cmd, "AT+CIPSTART=\"TCP\",\"%s\",%u", link.host, link.port);

	sendcommand(cmd);
	for (;;) // Try until endo of the days recieve CONNECT or ERROR
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
	}
	getAnswer3();									  // OK
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
			saveBuf(fileNamePtr, 02, 00);
			return true;
		}
		getdataEsp(todo);
		saveBuf(fileNamePtr, 01, todo);
		printf("%lu kb  \r", downloaded / 1024);
		if (quitDownload())
		{
			saveBuf(fileNamePtr, 02, 00);
			return false;
		}
	} while (todo != 0);
	link.size = downloaded;
	saveBuf(fileNamePtr, 02, 00);
	/* Must return true: getFile() retries while result==0, and CLOSED
	 * ends the loop with todo==0 ? old "result=false" re-fetched forever. */
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
	for (;;)
	{
		do
		{
			todo = tcpRead(socket, 3);
		} while (todo == 0 - ERR_EAGAIN);
		if (todo < 1 || quitDownload())
		{
			break;
		}

		downloaded = downloaded + todo;
		printf("%lu kb    \r", downloaded / 1024);
		saveBuf(fileNamePtr, 01, todo);
	}
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

char getFileEspnet(unsigned char *fileNamePtr)
{
	int todo;
	int socket;
	unsigned long downloaded = 0;

	if (!EspDnsResolve((char *)link.host))
	{
		clearStatus();
		printf("Ошибка определения адреса '%s'", link.host);
		return false;
	}
	targetadr.porth = 00;
	targetadr.portl = link.port;

	if ((strlen(link.path) == 1 && link.path[0] == '/') || strlen(link.path) == 0)
		strcpy(link.path, crlf);
	else
		strcat(link.path, crlf);

	socket = EspOpenSock(AF_INET, SOCK_STREAM);
	if (socket < 0)
		return false;
	todo = EspConnect((signed char)socket);
	if (todo < 0)
	{
		EspShutDown((signed char)socket, 0);
		return false;
	}
	todo = EspSend((signed char)socket, (unsigned int)&link.path, strlen(link.path));
	if (todo < 0)
	{
		EspShutDown((signed char)socket, 0);
		return false;
	}
	saveBuf(fileNamePtr, 00, 0);
	clearStatus();
	for (;;)
	{
		do
		{
			todo = EspRead(socket);
		} while (todo == 0 - ESPNET_ERR_EAGAIN);
		if (todo < 1 || quitDownload())
		{
			if (todo == 0 - (int)ESPNET_ERR_HOSTUNREACH ||
				todo == 0 - (int)ESPNET_ERR_INTR)
			{
				EspShutDown((signed char)socket, 0);
				clearStatus();
				printf("ESPNET link lost after %lu kb", downloaded / 1024);
				return false;
			}
			break;
		}
		downloaded = downloaded + todo;
		if ((downloaded & 8191) < (unsigned int)todo)
			printf("%lu kb    \r", downloaded / 1024);
		saveBuf(fileNamePtr, 01, todo);
	}
	saveBuf(fileNamePtr, 02, 00);
	clearStatus();
	EspShutDown((signed char)socket, 0);
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
	case 2:
		result = getFileEspnet(fileNamePtr);
		break;
	default:
		break;
	}
	return result;
}

unsigned char selectorProcessor(void)
{
	unsigned int lineSearch = 0;
	unsigned char *p;
	unsigned int counter;

	/* 1. Быстрые входные проверки */
	if (link.type == '0' || navi.lineSelect > navi.lastLine || navi.lineSelect == 0)
	{
		return false;
	}

	/* Ставим указатель на начало нужной страницы в netbuf */
	p = netbuf + pageOffsets[navi.page];

	/* 2. Поиск начала выбранной строки (пропускаем n-1 строк) */
	if (navi.lineSelect > 1)
	{
		do
		{
			if (*p == 0)
				return false; /* Защита от выхода за данные */
			if (*p == 0x0a)
			{
				lineSearch++;
			}
			p++;
		} while (lineSearch < navi.lineSelect - 1);
	}

	/* Сохраняем историю типа */
	strncpy((char *)link.prevHost, (char *)link.host, sizeof(link.prevHost) - 1);
	link.nexType = link.type;
	link.type = *p;

	/* Проверяем тип элемента (информационный, точка или конец) */
	if (link.type == 'i' || link.type == '.' || link.type == 0)
	{
		link.type = link.nexType;
		return false;
	}

	/* 3. Пропускаем видимое имя (ищем первый таб 0x09) */
	while (*p != 9 && *p != 0x0a && *p != 0)
	{
		p++;
	}
	if (*p != 9)
		return false; /* Битый формат строки */
	p++;			  /* Шаг за таб */

	/* 4. Извлекаем путь (path) до следующего таба */
	counter = 0;
	while (*p != 9 && *p != 0x0a && *p != 0)
	{
		if (counter < sizeof(link.path) - 1)
		{
			link.path[counter++] = *p;
		}
		p++;
	}
	link.path[counter] = 0;
	if (*p != 9)
		return false;
	p++; /* Шаг за таб */

	/* 5. Извлекаем хост (host) */
	counter = 0;
	while (*p != 9 && *p != 0x0a && *p != 0)
	{
		if (counter < sizeof(link.host) - 1)
		{
			link.host[counter++] = *p;
		}
		p++;
	}
	link.host[counter] = 0;
	if (*p != 9)
		return false;
	p++; /* Шаг за таб */

	/* 6. Извлекаем порт (парсим прямо с текущей позиции указателя) */
	link.port = atoi((const char *)p);

	return true;
}

char extractName(void)
{
	unsigned char *p;
	unsigned char *pDot;
	unsigned int counter;

	/* 1. Извлекаем чистое имя файла из пути (ищем конец строки и идем назад) */
	p = (unsigned char *)link.path + strlen((const char *)link.path);

	while (p > (unsigned char *)link.path)
	{
		p--;
		if (*p == '/' || *p == ':')
		{
			p++; /* Встаем на первый символ после разделителя */
			break;
		}
	}
	/* Теперь p указывает на начало имени файла внутри link.path */

	/* Безопасно копируем имя файла в navi.fileName */
	counter = 0;
	while (*p && counter < sizeof(navi.fileName) - 1)
	{
		navi.fileName[counter++] = *p++;
	}
	navi.fileName[counter] = 0;

	/* 2. Обработка ручного ввода (Save As) */
	if (navi.saveAs)
	{
		curWin.w = 61;
		curWin.x = SCREEN_WIDTH / 2 - curWin.w / 2 - 1;
		curWin.y = 10;
		curWin.h = 1;
		curWin.text = 103;
		curWin.back = 103;
		strcpy((char *)curWin.tittle, "Введите имя файла");

		if (inputBox(curWin, navi.fileName))
		{
			strncpy((char *)navi.fileName, (const char *)cmd, sizeof(navi.fileName) - 1);
			navi.fileName[sizeof(navi.fileName) - 1] = 0; /* Гарантируем нуль */
		}
		else
		{
			return false;
		}
	}
	/* 3. Автоматическое определение (Play It) */
	else
	{
		/* Ищем ПОСЛЕДНЮЮ точку с конца имени файла */
		pDot = (unsigned char *)strrchr((const char *)navi.fileName, '.');

		if (pDot == NULL)
		{
			clearStatus();
			printf("Ошибка определения типа файла, не найдено расширение. [%s]", navi.fileName);
			waitKey();
			return false;
		}
		else
		{
			/* Маленький буфер строго под 3 буквы расширения + нуль-терминатор */
			char ext[4];

			/* Безопасно копируем расширение во временный буфер, пока navi.fileName еще цел */
			strncpy(ext, (const char *)(pDot + 1), 3);
			ext[3] = 0; /* Гарантируем нуль-терминатор для расширения */

			/* Теперь можно смело затирать navi.fileName, расширение уже спасено */
			strcpy((char *)navi.fileName, "current.");
			strcat((char *)navi.fileName, ext);
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
	unsigned char extLow[4];
	const unsigned char *pDot;
	const unsigned char *pDb;
	const unsigned char *pLineStart;
	unsigned char *pCmd;
	unsigned int i;

	/* 1. Поиск расширения с конца строки */
	pDot = (const unsigned char *)strrchr((const char *)navi.fileName, '.');
	if (pDot == NULL)
	{
		clearStatus();
		printf("Ошибка определения типа файла, не найдено расширение. [%s]", navi.fileName);
		waitKey();
		return false;
	}

	/* 2. Извлекаем расширение строго в нижнем регистре (макс 3 символа) */
	pDot++;
	for (i = 0; i < 3; i++)
	{
		/* Заканчиваем, если строка кончилась, пробел, точка или спецсимволы */
		if (pDot[i] == 0 || pDot[i] == 0x0d || pDot[i] == 0x0a || pDot[i] == ' ' || pDot[i] == '.')
			break;
		extLow[i] = (unsigned char)tolower(pDot[i]);
	}
	extLow[i] = 0;

	/* Если расширение было из пробелов или пустое, дополняем до реального сравнения */
	if (extLow[0] == 0)
		return false;

	/* 3. Сканируем базу данных nvext */
	pDb = (const unsigned char *)nvext;

	while (*pDb != 0)
	{
		pLineStart = pDb; /* Запоминаем начало текущей строки базы */

		/* Бежим по элементам внутри ОДНОЙ строки базы данных */
		while (*pDb != 0x0d && *pDb != 0x0a && *pDb != 0)
		{
			/* Сравниваем текущее слово в базе с нашим extLow */
			i = 0;
			while (extLow[i] != 0 && tolower(pDb[i]) == extLow[i])
			{
				i++;
			}

			/* Проверяем, честное ли совпадение: наше расширение закончилось,
			   А в базе после него идёт ЛИБО запятая, ЛИБО двоеточие */
			if (extLow[i] == 0 && (pDb[i] == ':' || pDb[i] == ','))
			{
				/* НАШЛИ! Теперь нужно найти двоеточие ':' в этой строке, чтобы дойти до команды */
				while (*pDb != ':' && *pDb != 0x0d && *pDb != 0x0a && *pDb != 0)
				{
					pDb++;
				}

				if (*pDb == ':')
				{
					pDb++; /* Шаг за двоеточие */
					while (*pDb == ' ')
						pDb++; /* Пропускаем пробелы перед командой */

					/* 4. Копируем имя исполняемого файла в буфер cmd */
					pCmd = (unsigned char *)cmd;
					while (*pDb != 0x0d && *pDb != 0x0a && *pDb != 0)
					{
						*pCmd++ = *pDb++;
					}
					*pCmd++ = ' ';
					*pCmd = 0;

					/* 5. Сборка финальной командной строки */
					strcat((char *)cmd, (const char *)curPath);
					strcat((char *)cmd, "/current.");
					strcat((char *)cmd, (const char *)extLow);

					return true;
				}
			}

			/* Если в текущей позиции строки совпадения нет, прыгаем к следующему расширению за запятую */
			while (*pDb != ',' && *pDb != ':' && *pDb != 0x0d && *pDb != 0x0a && *pDb != 0)
			{
				pDb++;
			}
			if (*pDb == ',')
				pDb++; /* Перешагиваем запятую, продолжаем внутренний цикл */
			else
				break; /* Если уперлись в двоеточие или конец строки ? выходим из внутреннего цикла */
		}

		/* На случай неудачи: восстанавливаем указатель на начало строки и мотаем её до самого конца \r\n */
		pDb = pLineStart;
		while (*pDb != 0x0d && *pDb != 0)
		{
			pDb++;
		}
		if (*pDb == 0x0d)
			pDb++;
		if (*pDb == 0x0a)
			pDb++;
	}

	/* Если пробежали всю базу и ничего не нашли */
	clearStatus();
	printf("[ext] Не найдена команда для расширения [%s]", extLow);
	waitKey();
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
		curWin.x = SCREEN_WIDTH / 2 - curWin.w / 2 - 1;
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
		OS_GETPATH(curPath);

		if (getFile(navi.fileName))
		{
			OS_SETSYSDRV();
			navi.volume = pageVolumes[navi.page];
			loadPageFromDisk("browser/current.gph", navi.volume);
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
	curWin.x = SCREEN_WIDTH / 2 - curWin.w / 2 - 1;
	curWin.y = 10;
	curWin.h = 1;
	curWin.text = 207;
	curWin.back = 207;
	strcpy(curWin.tittle, "Введите адрес Gopher сервера");

	if (inputBox(curWin, ""))
	{
		strncpy(link.prevHost, link.host, sizeof(link.prevHost) - 1);
		link.type = '1';
		strncpy(link.host, cmd, sizeof(link.host) - 1);
		strncpy(link.path, "/", sizeof(link.path) - 1);
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
	unsigned char oldColor; /* C89: decls at top */
	unsigned int curPage = navi.page;

	switch (keypress)
	{
	case 250: /* Up */
		navi.prevLineSelect = navi.lineSelect;
		navi.lineSelect--;

		if (navi.lineSelect < 1 && navi.page == 0)
		{
			navi.lineSelect = screenHeight;
			break;
		}

		if (navi.page != 0 && navi.lineSelect == 0)
		{
			curPage = navi.page - 1;
			navi.page = curPage;
			navi.volume = pageVolumes[curPage];
			OS_SETSYSDRV();
			loadPageFromDisk("browser/current.gph", navi.volume);
			navi.nextBufPos = renderPage(pageOffsets[curPage]);
			navi.lineSelect = screenHeight;
		}
		break;
	case 249: /* down */
		navi.prevLineSelect = navi.lineSelect;
		navi.lineSelect++;
		if (navi.lineSelect > screenHeight && navi.page == navi.maxPage)
		{
			navi.lineSelect = 1;
			break;
		}
		if (navi.page != navi.maxPage && navi.lineSelect > screenHeight)
		{
			if (curPage < MAX_PAGES_TOTAL)
			{
				pageOffsets[curPage + 1] = navi.nextBufPos;
				pageVolumes[curPage + 1] = navi.volume;
			}
			curPage++;
			navi.page = curPage;
			if (navi.volume != pageVolumes[curPage])
			{
				navi.volume = pageVolumes[curPage];
				OS_SETSYSDRV();
				loadPageFromDisk("browser/current.gph", navi.volume);
			}
			navi.nextBufPos = renderPage(pageOffsets[curPage]);
			navi.lineSelect = 1;
		}
		break;
	case 248: /* Left */
		if (navi.page == 0)
		{
			break;
		}
		curPage = navi.page - 1;
		navi.page = curPage;
		navi.volume = pageVolumes[curPage];
		OS_SETSYSDRV();
		loadPageFromDisk("browser/current.gph", navi.volume);
		navi.nextBufPos = renderPage(pageOffsets[curPage]);
		navi.lineSelect = screenHeight;
		break;
	case 251: /* Right */
		if (navi.page == navi.maxPage)
		{
			break;
		}
		if (curPage < MAX_PAGES_TOTAL)
		{
			pageOffsets[curPage + 1] = navi.nextBufPos;
			pageVolumes[curPage + 1] = navi.volume;
		}
		curPage++;
		navi.page = curPage;
		if (navi.volume != pageVolumes[curPage])
		{
			navi.volume = pageVolumes[curPage];
			OS_SETSYSDRV();
			loadPageFromDisk("browser/current.gph", navi.volume);
		}
		navi.nextBufPos = renderPage(pageOffsets[curPage]);
		navi.lineSelect = 1;
		break;
	case 0x0d:
		activate();
		break;
	case 0x08: /* BS */
		if (navi.history > 1)
		{
			popHistory();
			doLink(true);
		}
		break;
	case 31: /* screen redraw */
		OS_SETSYSDRV();
		loadPageFromDisk("browser/current.gph", navi.volume);
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
		netDriver++;
		if (netDriver > 2)
			netDriver = 0;
		mainWinDraw();
		applyNetDriver();
		break;
	case 'm':
	case 'M':
		mouse.classic = !mouse.classic;
		break;
	}

	if (link.type == '1')
	{
		oldColor = colors[navi.prevLineSelect - 1];

		for (counter = 1; counter < (unsigned char)SCREEN_WIDTH; counter++)
		{
			OS_SETXY(counter, navi.prevLineSelect);
			OS_PRATTR(oldColor);
		}

		if (mouse.cursYpos == navi.prevLineSelect)
		{
			OS_SETXY(mouse.cursXpos, mouse.cursYpos);
			mouse.oldAtr = OS_GETATTR();
		}

		for (counter = 1; counter < (unsigned char)SCREEN_WIDTH; counter++)
		{
			OS_SETXY(counter, navi.lineSelect);
			OS_PRATTR(15);
		}
	}
}

void navigationPlain(char keypress)
{
	unsigned int curPage = navi.page;

	switch (keypress)
	{
	case 248: // Left
	case 250: // Up
		if (curPage == 0)
		{
			break;
		}

		curPage--;
		navi.page = curPage;

		// Восстанавливаем том, на котором страница НАЧИНАЕТСЯ
		navi.volume = pageVolumes[curPage];

		OS_SETSYSDRV();
		// Принудительно перечитываем именно тот том, с которого страница начинается
		loadPageFromDisk("browser/current.txt", navi.volume);

		// Рендерим со смещения этой страницы
		navi.nextBufPos = renderPlain(pageOffsets[curPage]);
		break;

	case 251: // Right
	case 249: // down
		if (curPage == navi.maxPage)
		{
			break;
		}

		// Запоминаем, где закончилась текущая страница
		if (curPage < MAX_PAGES_TOTAL)
		{
			pageOffsets[curPage + 1] = navi.nextBufPos;
			pageVolumes[curPage + 1] = navi.volume; // Фиксируем том НАЧАЛА следующей страницы
		}

		curPage++;
		navi.page = curPage;

		// Если при рендере предыдущей страницы произошел switchInternalVolume,
		// то navi.volume уже равен новому тому, а данные находятся в буфере netbuf.
		// Но если мы заходим на страницу, которая требует другого тома, подгружаем его:
		if (navi.volume != pageVolumes[curPage])
		{
			navi.volume = pageVolumes[curPage];
			OS_SETSYSDRV();
			loadPageFromDisk("browser/current.txt", navi.volume);
		}

		navi.nextBufPos = renderPlain(pageOffsets[curPage]);
		break;

	case 0x08: // BS
		if (navi.history > 1)
		{
			popHistory();
			doLink(true);
		}
		break;

	case 31: // Перерисовка
		OS_SETSYSDRV();
		loadPageFromDisk("browser/current.txt", navi.volume);
		renderPlain(pageOffsets[curPage]);
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
		netDriver++;
		if (netDriver > 2)
			netDriver = 0;
		mainWinDraw();
		applyNetDriver();
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
	unsigned int mouseButtons;
	unsigned char mX, mY;
	int dx, dy;

	mouseRaw = OS_GETMOUSE();
	mouseButtons = (unsigned int)mouseRaw; /* HL: L = кнопки/колесо, H = кнопка клавиатуры */

	mX = (unsigned char)(mouseRaw >> 16); /* Регистр E */
	mY = (unsigned char)(mouseRaw >> 24); /* Регистр D */

	if (mX != mouse.mouseXpos || mY != mouse.mouseYpos)
	{
		OS_SETXY(mouse.cursXpos, mouse.cursYpos);
		OS_PRATTR(mouse.oldAtr);

		if (mouse.classic)
		{
			/* Пропорциональная точная интерполяция на 80x25 */
			mouse.cursXpos = (unsigned char)((mX * 80) >> 8);
			mouse.cursYpos = (unsigned char)(24 - ((mY * 25) >> 8));

			mouse.mouseXpos = mX;
			mouse.mouseYpos = mY;
		}
		else
		{
			/* Относительный режим */
			int mouseXpos = (int)mX - (int)mouse.mouseXpos;
			int mouseYpos = (int)mY - (int)mouse.mouseYpos;

			mouse.mouseXpos = mX;
			mouse.mouseYpos = mY;

			if (mouseXpos < -128)
				mouseXpos += 256;
			else if (mouseXpos > 128)
				mouseXpos -= 256;

			if (mouseYpos < -128)
				mouseYpos += 256;
			else if (mouseYpos > 128)
				mouseYpos -= 256;

			dx = 1;
			if (mouseXpos > 6 || mouseXpos < -6)
				dx = 2;
			if (mouseXpos > 15 || mouseXpos < -15)
				dx = 3;

			dy = 1;
			if (mouseYpos > 6 || mouseYpos < -6)
				dy = 2;
			if (mouseYpos > 15 || mouseYpos < -15)
				dy = 3;

			if (mouseXpos > 0)
				mouse.cursXpos += dx;
			else if (mouseXpos < 0)
				mouse.cursXpos -= dx;

			if (mouse.divider == 0)
			{
				if (mouseYpos > 0)
					mouse.cursYpos -= dy;
				else if (mouseYpos < 0)
					mouse.cursYpos += dy;
				mouse.divider = 1;
			}
			else
			{
				mouse.divider--;
			}

			if (mouse.cursXpos > 79)
				mouse.cursXpos = 79;
			if (mouse.cursXpos < 0)
				mouse.cursXpos = 0;
			if (mouse.cursYpos > 24)
				mouse.cursYpos = 24;
			if (mouse.cursYpos < 0)
				mouse.cursYpos = 0;
		}

		OS_SETXY(mouse.cursXpos, mouse.cursYpos);
		mouse.oldAtr = OS_GETATTR();
		OS_PRATTR(215);
	}

	/* Сохраняем физические кнопки */
	mouse.mmb = (mouseButtons >> 2) & 1;
	mouse.rmb = (mouseButtons >> 1) & 1;
	mouse.lmb = mouseButtons & 1;

	/* Записываем текущее значение колеса (0..15) */
	mouse.wheel = (mouseButtons >> 4) & 15;

	OS_SETXY(mouse.cursXpos, mouse.cursYpos);

	/* Возвращает код символа с клавиатуры (из регистра H) */
	return (unsigned char)(mouseButtons >> 8);
}

C_task main(void)
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
			if (navi.history > 1)
			{
				popHistory();
				doLink(true);
			}
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
