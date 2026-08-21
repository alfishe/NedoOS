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
//
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
unsigned int espRetry = 5;
unsigned long factor, timerok, count = 0;
unsigned int magic = 16;
unsigned char netDriver = 0;
unsigned char curHost;
unsigned long contLen;
unsigned int httpErr;

unsigned char uVer[] = "1.0";
unsigned char curPath[128];
unsigned char cmd[256];
unsigned char search[128];
unsigned char crlf[2] = {13, 10};
const unsigned char gotWiFi[] = "WIFI GOT IP";
char hosts[3][32] = {"next.zxart.ee", "zxdb.remysharp.com", "hood.speccy.cz"};
unsigned char userAgent1[] = " HTTP/1.1\r\nHost: ";
unsigned char userAgent2[] = "\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS; ZXDB)\r\n\r\n\0";
unsigned char netbuf[4096];
unsigned char buf[10000];
struct sockaddr_in targetadr;
struct readstructure readStruct;
struct sockaddr_in dnsaddress;

struct window
{
	unsigned char x;
	unsigned char y;
	unsigned char w;
	unsigned char h;
	unsigned char text;
	unsigned char back;
	unsigned char tittle[60];
} curWin;

struct time
{
	unsigned int hours;
	unsigned int minutes;
	unsigned char oldMinutes;

} clock;

/* makeRequest search-string scratch (was 256 B on CSTACK). */
static char g_mkreq[256];

struct linkStruct
{
	unsigned char host[64];
	unsigned char path[512];
	unsigned int port;
	unsigned char hasName;
	unsigned char fname[128];
} link;

struct line
{
	unsigned long id;
	unsigned char name[300];
	unsigned char file[300];
	unsigned char ext[5];
	unsigned long size;
	unsigned char option;
	unsigned int year;
} table[12];

struct limit
{
	int first;
	int second;
	int total;
	int curline;
	int oldline; // <-- ДОБАВЛЕНО: Предыдущая активная строка
	int curOpt;
	int headLng;
	int curPage;
} limiter;

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

void quit(void)
{
	OS_CLS(0);
	OS_SETGFX(-1);
	exit(0);
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

unsigned char delayLongKey(unsigned long counter)
{
	unsigned long start, finish, key;
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
		key = OS_GETKEY();
		if (key != 0)
		{
			return key;
		}
		YIELD();
	}
	return 32;
}

///////////////////////////
#include <../common/esp-com.c>
#include <../common/network.c>
/* 2048 UART payload: ~25 frames for 50KB. 512 was ~4x more round-trips. */
#define ESPNET_HOST_MAX 2048
#define ESPNET_CLIENT_ONLY 1
#include <../common/espnet.c>
#include <../common/espnet-net.c>
//////////////////////////

int testOperation2(const char *process, int socket)
{
	if (socket < 0)
	{
		printf("%s: [ERROR:", process);
		errorPrint(-socket);
		printf("]\r\n");
		YIELD();
		return -socket;
	}
	return 1;
}

/* ESPNET helpers return 0 / socket id / byte count, or negative errno. */
static unsigned char espnet_check(const char *op, int r);
int cutHeader(void);

static unsigned char espnet_check(const char *op, int r)
{
	if (r >= 0)
		return 1;
	clearStatus();
	OS_SETCOLOR(206);
	OS_SETXY(0, 24);
	printf("%s: [ERROR:", op);
	errorPrint((unsigned int)(0 - r));
	printf("]     ");
	writeLog(op, "espnet_check   ");
	delayLong(2000);
	return 0;
}

/*
 * EspRead overwrites netbuf each call and is capped at ESPNET_HOST_MAX.
 * Collect into buf until HTTP header is complete, then cutHeader().
 * Returns body bytes already in buf[], 0 if HTTP is not 200, or <0 on net error.
 */
static int espnet_read_header(int socket)
{
	int todo;
	unsigned int got;
	unsigned int n;

	got = 0;
	for (;;)
	{
		todo = EspRead((signed char)socket);
		if (todo == 0 - (int)ESPNET_ERR_EAGAIN)
		{
			YIELD();
			continue;
		}
		if (todo <= 0)
			return (todo < 0) ? todo : (0 - (int)ESPNET_ERR_CONNRESET);
		if (got + (unsigned int)todo >= sizeof(buf))
			return 0 - (int)ESPNET_ERR_EMSGSIZE;
		memcpy(buf + got, netbuf, (unsigned int)todo);
		got += (unsigned int)todo;
		buf[got] = 0;
		if (strstr(buf, "\r\n\r\n") == 0)
			continue;
		n = got;
		if (n > sizeof(netbuf) - 1)
			n = sizeof(netbuf) - 1;
		memcpy(netbuf, buf, n);
		netbuf[n] = 0;
		limiter.headLng = cutHeader();
		if (httpErr != 200)
			return 0;
		if (limiter.headLng < 0 || (unsigned int)limiter.headLng > got)
			return 0;
		got -= (unsigned int)limiter.headLng;
		if (got != 0)
			memmove(buf, buf + limiter.headLng, got);
		buf[got] = 0;
		return (int)got;
	}
}

static FILE *g_save_fp;
static unsigned char g_save_ok; /* 1 = g_save_fp is open; low byte of FILE* is not a sentinel */

unsigned char saveBuf(unsigned char *fileNamePtr, unsigned char operation, unsigned int sizeOfBuf)
{
	FILE *fp2;

	switch (operation)
	{
	case 00:
		if (g_save_ok)
		{
			OS_CLOSEHANDLE(g_save_fp);
			g_save_ok = 0;
		}
		fp2 = OS_CREATEHANDLE(fileNamePtr, 0x80);
		if (((int)fp2) & 0xff)
		{
			clearStatus();
			printf("%s  creating error.", fileNamePtr);
			getchar();
			exit(0);
		}
		g_save_fp = fp2;
		g_save_ok = 1;
		break;
	case 01:
		if (!g_save_ok)
		{
			fp2 = OS_OPENHANDLE(fileNamePtr, 0x80);
			if (((int)fp2) & 0xff)
			{
				clearStatus();
				printf("%s opening error.\r\n ", fileNamePtr);
				getchar();
				exit(0);
			}
			OS_SEEKHANDLE(fp2, OS_GETFILESIZE(fp2));
			g_save_fp = fp2;
			g_save_ok = 1;
		}
		OS_WRITEHANDLE(netbuf + limiter.headLng, g_save_fp, sizeOfBuf);
		break;
	case 02:
		if (g_save_ok)
		{
			OS_CLOSEHANDLE(g_save_fp);
			g_save_ok = 0;
		}
		break;
	default:
		break;
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
		OS_SETCOLOR(103);
		OS_SETXY(73, 0);
		printf("[%02u:%02u]", clock.hours, clock.minutes);
	}
}

void drawPage(void)
{
	OS_SETCOLOR(103);
	OS_SETXY(64, 0);
	printf("[Page:%2d]", limiter.curPage);
}

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

void init(void)
{
	targetadr.family = AF_INET;
	targetadr.porth = 00;
	targetadr.portl = 80;
	targetadr.b1 = 0;
	targetadr.b2 = 0;
	targetadr.b3 = 0;
	targetadr.b4 = 0;
	curHost = 0;
	link.port = 80;
	link.hasName = false;
	limiter.curOpt = 1;
	limiter.curPage = 0;
	netDriver = readParamFromIni();

	switch (netDriver)
	{
	case 0:
		get_dns();
		break;
	case 1:
		loadEspConfig();
		uart_init(divider);
		espReBoot();
		break;
	case 2:
		/* UART + seq; without this OS_ESPDNSRESOLVE returns NOTCONN. */
		OS_ESPINIT();
		targetadr.family = AF_INET;
		targetadr.porth = 0;
		targetadr.portl = 0;
		targetadr.b1 = targetadr.b2 = targetadr.b3 = targetadr.b4 = 0;
		break;
	}

	OS_SETSYSDRV();
	OS_MKDIR("../downloads");	   // Create if not exist
	OS_MKDIR("../downloads/zxdb"); // Create if not exist
	OS_CHDIR("../downloads/zxdb");

	strcpy(link.host, hosts[curHost]);
	clock.oldMinutes = 255;
}

void simpleBox(const struct window *wp)
{
	unsigned char wcount, tempx;
	unsigned char x, y, w, h, back;

	x = wp->x;
	y = wp->y;
	w = wp->w;
	h = wp->h;
	back = wp->back;
	h = (unsigned char)(h - 2);
	OS_SETXY(x, y);
	/* Fill uses full window width; frame lines then use w-2. */
	BDBOX(x, (unsigned char)(y + 1), w, h, back, 32);
	w = (unsigned char)(w - 2);
	OS_SETXY(x, y);
	OS_SETCOLOR(wp->text);
	putchar(201);
	for (wcount = 0; wcount < w; wcount++)
	{
		putchar(205);
	}
	putchar(187);

	OS_SETXY(x, (unsigned char)(y + h));
	putchar(200);
	for (wcount = 0; wcount < w; wcount++)
	{
		putchar(205);
	}
	putchar(188);
	tempx = (unsigned char)(x + w + 1);
	for (wcount = 1; wcount < h; wcount++)
	{
		OS_SETXY(x, (unsigned char)(y + wcount));
		putchar(186);
		OS_SETXY(tempx, (unsigned char)(y + wcount));
		putchar(186);
	}
}

unsigned char inputBox(const struct window *wp, const char *prefilled)
{
	unsigned char wcount, tempx, tittleStart;
	unsigned char byte;
	unsigned char box_h;

	// Переменные редактора (объявлены строго в начале функции для IAR)
	unsigned char cmdLen;	  // Полная текущая длина строки cmd
	unsigned char cursorPos;  // Позиция курсора в строке (от 0 до cmdLen)
	unsigned char viewOffset; // Смещение просмотра для скроллинга длинного текста
	unsigned char visibleLen; // Сколько символов строки физически влезает в окно
	unsigned char i;		  // Индекс для циклов отрисовки
	unsigned char printPos;	  // Текущий индекс символа для вывода на экран

	box_h = (unsigned char)(wp->h + 1);
	OS_SETXY(wp->x, (unsigned char)(wp->y - 1));
	BDBOX(wp->x, wp->y, (unsigned char)(wp->w + 1), box_h, wp->back, 32);
	OS_SETXY(wp->x, wp->y);
	OS_SETCOLOR(wp->text);
	putchar(201);
	for (wcount = 0; wcount < wp->w; wcount++)
	{
		putchar(205);
	}
	putchar(187);
	OS_SETXY(wp->x, (unsigned char)(wp->y + box_h));
	putchar(200);
	for (wcount = 0; wcount < wp->w; wcount++)
	{
		putchar(205);
	}
	putchar(188);

	tempx = (unsigned char)(wp->x + wp->w + 1);
	for (wcount = 1; wcount < box_h; wcount++)
	{
		OS_SETXY(wp->x, (unsigned char)(wp->y + wcount));
		putchar(186);
		OS_SETXY(tempx, (unsigned char)(wp->y + wcount));
		putchar(186);
	}
	tittleStart = (unsigned char)(wp->x + (wp->w / 2) - (strlen((char *)wp->tittle) / 2));
	OS_SETXY(tittleStart, wp->y);
	printf("[%s]", wp->tittle);

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
	visibleLen = (unsigned char)(wp->w - 1); // Доступная ширина внутри рамки под текст и курсор

	for (;;)
	{
		// 1. АВТОСКРОЛЛИНГ: Корректируем окно видимости текста относительно курсора
		if (cursorPos < viewOffset)
		{
			viewOffset = cursorPos;
		}
		else if (cursorPos - viewOffset >= visibleLen)
		{
			viewOffset = (unsigned char)(cursorPos - visibleLen + 1);
		}

		// 2. ОТРИСОВКА СТРОКИ С ПОБИТОВОЙ ИНВЕРСИЕЙ ЦВЕТА КУРСOРА (Для NedoOS)
		OS_SETXY((unsigned char)(wp->x + 1), (unsigned char)(wp->y + 1));

		for (i = 0; i < visibleLen; i++)
		{
			printPos = (unsigned char)(viewOffset + i);

			// Если в этой позиции находится курсор ? считаем инверсный байт атрибута
			if (printPos == cursorPos)
			{
				OS_SETCOLOR((unsigned char)(
					// 1. Формируем новый PAPER (из старого INK)
					((wp->text & 0x40) << 1) | // Старый BRIGHT_INK (6) двигаем на место BRIGHT_PAPER (7)
					((wp->text & 0x07) << 3) | // Старый INK (2-0) двигаем на место PAPER (5-3)

					// 2. Формируем новый INK (из старого PAPER)
					((wp->text & 0x80) >> 1) | // Старый BRIGHT_PAPER (7) двигаем на место BRIGHT_INK (6)
					((wp->text & 0x38) >> 3)	 // Старый PAPER (5-3) двигаем на место INK (2-0)
					));
			}
			else
			{
				OS_SETCOLOR(wp->text); // Стандартный цвет окна (например, тот самый 207)
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
		OS_SETCOLOR(wp->text);

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
					for (i = (unsigned char)(cursorPos - 1); i < cmdLen; i++)
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

void sendReqdialog(void)
{
	curWin.w = 50;
	curWin.x = 39 - curWin.w / 2;
	curWin.y = 10;
	curWin.h = 4;
	curWin.text = 223;
	curWin.back = 223;
	simpleBox(&curWin);
	OS_SETXY(30, curWin.y + 1);
	printf("Sending request...");
}

void tittleDraw(void)
{
	clock.oldMinutes = 255;
	OS_SETCOLOR(103);
	OS_SETXY(0, 0);
	spaces(79);
	OS_SETXY(0, 0);
	printf(" ZXDB downloader [%s]", uVer);
	OS_SETXY(38 - strlen(link.host) / 2, 0);
	printf("[");
	OS_SETCOLOR(102);
	printf("%s", link.host);
	OS_SETCOLOR(103);
	printf("]");
	drawPage();
	drawClock();
}
void drawSearch(void)
{
	OS_SETCOLOR(207);
	OS_SETXY(38 - strlen(search) / 2, 1);
	putchar('[');
	OS_SETCOLOR(71);
	printf("%s", search);
	OS_SETCOLOR(curWin.text);
	OS_SETCOLOR(207);
	putchar(']');
}

void mainWinDraw(void)
{
	tittleDraw();
	OS_SETXY(0, 23);
	OS_SETCOLOR(71);
	printf("[");
	OS_SETCOLOR(87);
	printf("H");
	OS_SETCOLOR(71);
	printf("]change host       [");
	OS_SETCOLOR(87);
	printf("S");

	OS_SETCOLOR(71);
	printf("]Search item        [");
	OS_SETCOLOR(87);
	printf("ENTER");
	OS_SETCOLOR(71);
	printf("]Download item       [");
	OS_SETCOLOR(87);
	printf("ESC");
	OS_SETCOLOR(71);
	printf("]Exit   ");

	curWin.x = 0;
	curWin.y = 1;
	curWin.w = 80;
	curWin.h = 23;
	curWin.text = 207;
	curWin.back = 207;
	simpleBox(&curWin);
	drawSearch();
	clearStatus();
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

void squeeze(char s[], int c)
{
	int i, j;

	for (i = j = 0; s[i] != '\0'; i++)
		if (s[i] != c)
			s[j++] = s[i];
	s[j] = '\0';
}

// Функция вставки без использования malloc (безопасно для Z80)
void inject_option_suffix(char *fname, int option)
{
	int counter = strlen(fname);
	while (counter > 0)
	{
		counter--;
		if (fname[counter] == '.')
		{
			char ext_backup[16];
			strcpy(ext_backup, &fname[counter]);					 // Сохраняем расширение (например, ".tap")
			sprintf(&fname[counter], "-%02d%s", option, ext_backup); // Соединяем обратно
			return;
		}
	}
}

int cutHeader(void)
{
	unsigned char *count1;
	int counter;
	int max_len;

	httpErr = httpError();
	if (httpErr != 200)
	{
		clearStatus();
		printf("HTTP response:[%u]", httpErr);
		return 0;
	}

	count1 = strstr(netbuf, "Content-Length:");
	if (count1 == NULL)
	{
		clearStatus();
		printf("contLen not found");
		contLen = 0;
		httpErr = 999;
		return 0;
	}
	contLen = atol(count1 + 15);

	count1 = strstr(netbuf, "Content-Disposition: attachment; filename=");
	if (count1 != NULL)
	{
		// Безопасное копирование имени файла из кавычек
		strncpy(link.fname, count1 + 43, sizeof(link.fname) - 1);
		link.fname[sizeof(link.fname) - 1] = 0;

		counter = 0;
		max_len = strlen(link.fname);
		while (counter < max_len && link.fname[counter] != '\"')
		{
			counter++;
		}
		link.fname[counter] = 0; // Обрезаем на закрывающей кавычке
		link.hasName = true;
	}
	else
	{
		// Сборка имени по умолчанию
		strncpy(link.fname, table[limiter.curline].file, sizeof(link.fname) - 6);
		link.fname[sizeof(link.fname) - 6] = 0;
		strcat(link.fname, ".");
		strcat(link.fname, table[limiter.curline].ext);

		if (table[limiter.curline].option > 1)
		{
			inject_option_suffix(link.fname, limiter.curOpt);
		}
		link.hasName = false;
	}

	count1 = strstr(netbuf, "\r\n\r\n");
	if (count1 == NULL)
	{
		clearStatus();
		printf("end of header not found\r\n");
		return 0;
	}

	return ((unsigned int)count1 - (unsigned int)netbuf + 4);
}

void downDialog(void)
{
	unsigned int nameLong;

	nameLong = strlen(link.fname);
	if (nameLong < 21)
	{
		curWin.w = 23;
	}
	else
	{
		curWin.w = nameLong + 4;
	}
	curWin.x = 39 - curWin.w / 2;
	curWin.y = 10;
	curWin.h = 6;
	curWin.text = 223;
	curWin.back = 223;
	simpleBox(&curWin);

	// Красиво центрируем заголовок в рамке окошка (строка 10)
	OS_SETXY(curWin.x + (curWin.w / 2) - ((nameLong + 2) / 2), curWin.y);
	printf("[%s]", link.fname);
}

void drawProgressBar(unsigned long downloaded, unsigned long total)
{
	unsigned char width;
	unsigned char filled;
	unsigned char i;
	unsigned int percent;

	if (total == 0)
		return;

	// Вычисляем доступную ширину шкалы внутри окошка (минус скобки и отступы)
	width = curWin.w - 7;

	// Считаем проценты и сколько символов закрасить
	percent = (unsigned int)((downloaded * 100) / total);
	if (percent > 100)
		percent = 100;

	filled = (unsigned char)((downloaded * width) / total);
	if (filled > width)
		filled = width;

	// Позиционируем на 12-ю строку, со смещением внутрь окна
	OS_SETXY(curWin.x + 2, 12);
	OS_SETCOLOR(curWin.text); // Используем цвет окна (223)
	putchar('[');

	// Рисуем закрашенную часть полосы
	for (i = 0; i < filled; i++)
	{
		putchar(219);
	}

	// Рисуем пустую часть
	for (i = filled; i < width; i++)
	{
		putchar('.');
	}
	// printf("] %3u%%", percent);
	putchar(']');
}

char getFileEsp(void)
{
	int todo;
	unsigned char byte, firstPacket;
	unsigned long downloaded = 0;
	unsigned int fileSize1, down;
	// const unsigned char sendOk[] = "SEND OK";
	// unsigned int count;
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

	sprintf(cmd, "AT+CIPSEND=%u", strlen(link.path) + 2);
	sendcommand(cmd);
	getAnswer3();

	do
	{
		byte = uartReadBlock();
	} while (byte != '>');

	sendcommand(link.path);

	firstPacket = true;
	do
	{
		limiter.headLng = 0;
		todo = recvHead();

		if (todo == 0)
		{
			writeLog("Error parsing packet size, todo = 0", "getFileEsp     ");
			writeLog(netbuf, "getFileEsp     ");
			return false;
		}

		if (!getdataEsp(todo))
		{
			OS_CLS(0);
			puts("[getdataEsp]Downloading timeout. Exit!");
			writeLog("Downloading timeout. Exit!", "getFileEsp     ");
			delayLongKey(5000);
			exit(0);
		}

		if (firstPacket)
		{
			firstPacket = false;
			limiter.headLng = cutHeader();
			todo = todo - limiter.headLng;
			fileSize1 = contLen / 1024;

			if (!link.hasName)
			{
				curWin.w = 66;
				curWin.x = 39 - curWin.w / 2;
				curWin.y = 9;
				curWin.h = 1;
				curWin.text = 103;
				curWin.back = 103;

				strcpy(curWin.tittle, "Введите имя файла");
				if (inputBox(&curWin, link.fname))
				{
					strncpy(link.fname, cmd, 64);
					strcat(link.fname, "\0");
				}
			}
			if (httpErr != 200)
			{
				sendcommand("AT+CIPCLOSE");
				getAnswer3(); // CLOSED
				getAnswer3(); // OK
				mainWinDraw();
				return false;
			}
			downDialog();
			OS_DELETE(link.fname);
			saveBuf(link.fname, 00, 0);
		}

		downloaded = downloaded + todo;
		down = downloaded / 1024;
		OS_SETCOLOR(223);
		// ИНДИКАТОР: Рисуем заполняющийся прогресс-бар
		drawProgressBar(downloaded, contLen);

		saveBuf(link.fname, 01, todo);
		drawClock();
	} while (downloaded < contLen);
	saveBuf(link.fname, 02, 0);
	sendcommand("AT+CIPCLOSE");
	getAnswer3(); // CLOSED
	getAnswer3(); // OK
	return true;
}

char getFileEspNet(void)
{
	int todo, socket;

	unsigned int fileSize1;
	unsigned long downloaded = 0;
	unsigned int down;

	socket = EspOpenSock(AF_INET, SOCK_STREAM);
	if (!espnet_check("OS_ESPSOCKET", socket))
		return false;

	todo = EspConnect((signed char)socket);
	if (!espnet_check("OS_ESPCONNECT", todo))
	{
		EspShutDown((signed char)socket, 0);
		return false;
	}

	todo = EspSend((signed char)socket, (unsigned int)&link.path, strlen(link.path));
	if (!espnet_check("OS_ESPWRITE", todo))
	{
		EspShutDown((signed char)socket, 0);
		return false;
	}

	todo = espnet_read_header(socket);
	if (todo < 0)
	{
		espnet_check("OS_ESPREAD", todo);
		EspShutDown((signed char)socket, 0);
		return false;
	}
	if (httpErr != 200)
	{
		EspShutDown((signed char)socket, 0);
		mainWinDraw();
		return false;
	}

	fileSize1 = contLen / 1024;
	if (!link.hasName)
	{
		curWin.w = 66;
		curWin.x = 39 - curWin.w / 2;
		curWin.y = 9;
		curWin.h = 1;
		curWin.text = 103;
		curWin.back = 103;

		strcpy(curWin.tittle, "Введите имя файла");
		if (inputBox(&curWin, link.fname))
		{
			strncpy(link.fname, cmd, 64);
			strcat(link.fname, "\0");
		}
	}
	downDialog();
	saveBuf(link.fname, 00, 0);
	limiter.headLng = 0;
	if (todo > 0)
	{
		memcpy(netbuf, buf, (unsigned int)todo);
		saveBuf(link.fname, 01, (unsigned int)todo);
		downloaded = (unsigned long)todo;
		drawProgressBar(downloaded, contLen);
	}

	while (downloaded < contLen)
	{
		todo = EspRead((signed char)socket);
		if (todo == 0 - (int)ESPNET_ERR_EAGAIN)
		{
			YIELD();
			continue;
		}
		if (todo <= 0)
			break;
		downloaded = downloaded + (unsigned long)todo;
		down = downloaded / 1024;
		OS_SETCOLOR(223);
		drawProgressBar(downloaded, contLen);
		limiter.headLng = 0;
		saveBuf(link.fname, 01, (unsigned int)todo);
		drawClock();
	}

	saveBuf(link.fname, 02, 0);
	EspShutDown((signed char)socket, 0);

	if (downloaded != contLen)
	{
		puts("File download error!");
		puts("File download error!");
		puts("File download error!");
		puts("File download error!");
		waitKey();
	}
	return true;
}

char getFileNet(void)
{
	int todo, socket;
	char firstPacket;

	unsigned int fileSize1;
	unsigned long downloaded = 0;
	unsigned int down;

	socket = OpenSock(AF_INET, SOCK_STREAM);
	if (testOperation2("OS_NETSOCKET", socket) != 1)
	{
		getchar();
		quit();
	}

	todo = netConnect(socket, 1);
	if (testOperation2("OS_NETCONNECT", todo) != 1)
	{
		getchar();
		quit();
	}

	todo = tcpSend(socket, (unsigned int)&link.path, strlen(link.path), 1);
	if (testOperation2("OS_WIZNETWRITE", todo) != 1)
	{
		getchar();
		quit();
	}

	firstPacket = true;
	do
	{
		limiter.headLng = 0;
		todo = tcpRead(socket, 1);
		testOperation("OS_WIZNETREAD", todo);
		if (todo == 0)
		{
			break;
		}
		if (firstPacket)
		{
			firstPacket = false;
			limiter.headLng = cutHeader();
			todo = todo - limiter.headLng;
			fileSize1 = contLen / 1024;

			if (!link.hasName)
			{
				curWin.w = 66;
				curWin.x = 39 - curWin.w / 2;
				curWin.y = 9;
				curWin.h = 1;
				curWin.text = 103;
				curWin.back = 103;

				strcpy(curWin.tittle, "Введите имя файла");
				if (inputBox(&curWin, link.fname))
				{
					strncpy(link.fname, cmd, 64);
					strcat(link.fname, "\0");
				}
			}
			if (httpErr != 200)
			{
				netShutDown(socket, 0);
				mainWinDraw();
				return false;
			}
			downDialog();
			saveBuf(link.fname, 00, 0);
		}
		downloaded = downloaded + todo;
		down = downloaded / 1024;
		OS_SETCOLOR(223);

		// ИНДИКАТОР: Рисуем заполняющийся прогресс-бар
		drawProgressBar(downloaded, contLen);

		saveBuf(link.fname, 01, todo);
		drawClock();
	} while (downloaded < contLen);

	saveBuf(link.fname, 02, 0);
	netShutDown(socket, 0);

	if (downloaded != contLen)
	{
		puts("File download error!");
		puts("File download error!");
		puts("File download error!");
		puts("File download error!");
		waitKey();
	}
	return true;
}

void renderSingleLine(unsigned char index, unsigned char isSelected)
{
	unsigned char line = 2 + (index * 2);

	if (index >= limiter.total)
	{
		// Если элемента под таким индексом нет ? просто зачищаем эти две строки
		OS_SETCOLOR(206);
		OS_SETXY(2, line);
		spaces(76);
		OS_SETXY(2, line + 1);
		spaces(76);
		return;
	}

	// Установка цвета: если строка выбрана ? красим в инверсный (121), иначе ? чередуем (206/207)
	if (isSelected)
	{
		OS_SETCOLOR(121);
	}
	else
	{
		OS_SETCOLOR((index % 2 == 0) ? 206 : 207);
	}

	// Отрисовка первой текстовой строки (Имя + Расширение + Размер + Опции + Год)
	OS_SETXY(2, line);
	spaces(76); // Очищаем строку нужным цветом перед выводом
	OS_SETXY(2, line);
	printf("%s ", table[index].name);
	OS_SETXY(48, line);
	printf("%s  %6lu  %u  %4u", table[index].ext, table[index].size, table[index].option, table[index].year);

	// Отрисовка второй текстовой строки (Имя физического файла)
	OS_SETXY(2, line + 1);
	spaces(76); // Очищаем
	OS_SETXY(5, line + 1);
	printf("%s ", table[index].file);
}

void renderResult(char currentLine)
{
	unsigned char counter;
	// На экран физически влезает только 10 двухстрочных элементов (строки 2-21)
	for (counter = 0; counter < 10; counter++)
	{
		renderSingleLine(counter, (counter == currentLine));
	}
}

char getFile(unsigned char number)
{
	int result = 0;
	unsigned char option = 1;

	for (option = 1; option <= table[number].option; option++)
	{
		sprintf(link.path, "GET /get/%lu/%u%s%s%s", table[number].id, option, userAgent1, link.host, userAgent2);
		limiter.curOpt = option;
		switch (netDriver)
		{
		case 0:
			result = getFileNet();
			break;
		case 1:
			result = getFileEsp();
			break;
		case 2:
			result = getFileEspNet();
			break;
		default:
			break;
		}
	}
	// ВОССТАНОВЛЕНИЕ ИНТЕРФЕЙСА ПОСЛЕ СКАЧИВАНИЯ
	mainWinDraw();
	renderResult(limiter.curline);
	return result;
}

char makeRequestEsp(void)
{

	int todo;
	unsigned char byte, firstPacket;
	unsigned long downloaded = 0;
	// unsigned int count;
	// const unsigned char sendOk[] = "SEND OK";

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

	sprintf(cmd, "AT+CIPSEND=%u", strlen(link.path) + 2);
	sendcommand(cmd);
	getAnswer3();

	do
	{
		byte = uartReadBlock();
	} while (byte != '>');

	// sendcommandNrn(link.path);
	sendcommand(link.path);
	/*
		count = 0;
		do
		{
			byte = uartReadBlock();
			if (byte == sendOk[count])
			{
				count++;
				// putchar(byte);
			}
			else
			{
				count = 0;
			}
		} while (count < strlen(sendOk));

		uartReadBlock(); // CR
		uartReadBlock(); // LF
	*/
	firstPacket = true;
	do
	{
		limiter.headLng = 0;
		todo = recvHead();

		if (todo == 0)
		{
			writeLog("Error parsing packet size, todo = 0", "makeRequestEsp ");
			writeLog(netbuf, "makeRequestEsp ");
			return false;
		}

		if (!getdataEsp(todo))
		{
			OS_CLS(0);
			puts("[makeRequestEsp]Downloading timeout. Exit!");
			writeLog("[makeRequestEsp]Downloading timeout. Exit!", "makeRequestEsp ");
			delayLongKey(5000);
			exit(0);
		}

		if (firstPacket)
		{
			firstPacket = false;
			limiter.headLng = cutHeader();
			todo = todo - limiter.headLng;

			if (httpErr != 200)
			{
				sendcommand("AT+CIPCLOSE");
				getAnswer3(); // CLOSED
				getAnswer3(); // OK
				return false;
			}
		}
		if (downloaded + todo > sizeof(buf))
		{
			printf("dataBuffer overrun... %lu reached \n\r", downloaded + todo);
			return false;
		}
		memcpy(buf + downloaded, netbuf + limiter.headLng, todo);
		downloaded = downloaded + todo;
	} while (downloaded < contLen);

	sendcommand("AT+CIPCLOSE");
	getAnswer3(); // CLOSED
	getAnswer3(); // OK
	buf[downloaded + 1] = 0;
	if (downloaded < 2)
		return 0;
	return 2;
}

char makeRequestEspNet(void)
{
	int socket, todo;
	unsigned long downloaded = 0;

	{
		unsigned char ip[4];
		unsigned int r;

		r = OS_ESPDNSRESOLVE((unsigned char *)link.host, ip);
		if (!ESPNET_C_OK(r))
		{
			espnet_check("OS_ESPDNSRESOLVE", 0 - (int)ESPNET_C_ERR(r));
			clearStatus();
			printf("Ошибка определения адреса '%s'", link.host);
			return false;
		}
		targetadr.family = AF_INET;
		targetadr.b1 = ip[0];
		targetadr.b2 = ip[1];
		targetadr.b3 = ip[2];
		targetadr.b4 = ip[3];
	}

	targetadr.porth = link.port >> 8;
	targetadr.portl = link.port;

	socket = EspOpenSock(AF_INET, SOCK_STREAM);
	if (!espnet_check("OS_ESPSOCKET", socket))
		return false;

	todo = EspConnect((signed char)socket);
	if (!espnet_check("OS_ESPCONNECT", todo))
	{
		EspShutDown((signed char)socket, 0);
		return false;
	}
	todo = EspSend((signed char)socket, (unsigned int)&link.path, strlen(link.path));
	if (!espnet_check("OS_ESPWRITE", todo))
	{
		EspShutDown((signed char)socket, 0);
		return false;
	}

	todo = espnet_read_header(socket);
	if (todo < 0)
	{
		espnet_check("OS_ESPREAD", todo);
		EspShutDown((signed char)socket, 0);
		return false;
	}
	if (httpErr != 200)
	{
		EspShutDown((signed char)socket, 0);
		return false;
	}
	downloaded = (unsigned long)todo;

	while (downloaded < contLen)
	{
		todo = EspRead((signed char)socket);
		if (todo == 0 - (int)ESPNET_ERR_EAGAIN)
		{
			YIELD();
			continue;
		}
		if (todo <= 0)
		{
			EspShutDown((signed char)socket, 0);
			return false;
		}
		if (downloaded + (unsigned long)todo > sizeof(buf))
		{
			printf("dataBuffer overrun... %lu reached \n\r", downloaded + todo);
			EspShutDown((signed char)socket, 0);
			return false;
		}
		memcpy(buf + downloaded, netbuf, (unsigned int)todo);
		downloaded = downloaded + (unsigned long)todo;
	}

	EspShutDown((signed char)socket, 0);
	if (downloaded < sizeof(buf))
		buf[downloaded] = 0;
	if (downloaded < 2)
		return 0;
	return 2;
}

char makeRequestNet(void)
{
	int socket, todo;
	char firstPacket;
	unsigned long downloaded = 0;

	if (!dnsResolve(link.host))
	{
		clearStatus();
		printf("Ошибка определения адреса '%s'", link.host);
		return false;
	}

	targetadr.porth = link.port >> 8;
	targetadr.portl = link.port;
	// clearStatus();
	// printf("Connecting to %u.%u.%u.%u:%u", targetadr.b1, targetadr.b2, targetadr.b3, targetadr.b4, targetadr.porth * 256 + targetadr.portl);

	socket = OpenSock(AF_INET, SOCK_STREAM);
	if (testOperation2("OS_NETSOCKET", socket) != 1)
	{
		getchar();
		quit();
	}

	todo = netConnect(socket, 1);
	if (testOperation2("OS_NETCONNECT", todo) != 1)
	{
		getchar();
		quit();
	}
	todo = tcpSend(socket, (unsigned int)&link.path, strlen(link.path), 1);
	if (testOperation2("OS_WIZNETWRITE", todo) != 1)
	{
		getchar();
		quit();
	}
	firstPacket = true;
	do
	{
		limiter.headLng = 0;
		todo = tcpRead(socket, 1);
		testOperation("OS_WIZNETREAD", todo); // Quit if too many retries

		if (firstPacket)
		{
			firstPacket = false;
			limiter.headLng = cutHeader();
			todo = todo - limiter.headLng;

			if (httpErr != 200)
			{
				netShutDown(socket, 0);
				return false;
			}
		}

		if (downloaded + todo > sizeof(buf))
		{
			printf("dataBuffer overrun... %lu reached \n\r", downloaded + todo);
			return false;
		}
		memcpy(buf + downloaded, netbuf + limiter.headLng, todo);
		downloaded = downloaded + todo;
	} while (downloaded < contLen);

	netShutDown(socket, 0);
	buf[downloaded + 1] = 0;
	if (downloaded < 2)
		return 0;
	return 2;
}

char makeRequest(const char *request)
{
	char result;
	unsigned int counter, len;

	sendReqdialog();

	strcpy(g_mkreq, request);
	len = strlen(g_mkreq);
	for (counter = 0; counter < len; counter++)
	{
		if (g_mkreq[counter] == ' ' || g_mkreq[counter] == '-')
		{
			g_mkreq[counter] = '*';
		}
	}
	sprintf(link.path, "GET /?s=%s&p=%d%s%s%s", g_mkreq, limiter.curPage, userAgent1, link.host, userAgent2);

	switch (netDriver)
	{
	case 0:
		result = makeRequestNet();
		break;
	case 1:
		result = makeRequestEsp();
		break;
	case 2:
		result = makeRequestEspNet();
		break;
	default:
		return false;
	}

	return result;
}

int findLimiters(int n)
{
	n = pos(buf, "^", 1, n + 1);
	if (n == -1)
	{
		return -2;
	}
	limiter.first = n + 1;
	n = pos(buf, "^", 1, n + 1);
	if (n == -1)
	{
		return -2;
	}
	limiter.second = n - 1;
	return n;
}
void fillTable(void)
{
	int counter = 0;
	int len;
	limiter.second = -1;
	limiter.total = 0;

	do
	{
		// ID
		if (findLimiters(limiter.second) == -2)
			break;
		table[counter].id = atol(buf + limiter.first);
		limiter.total++;

		// Name
		if (findLimiters(limiter.second) == -2)
			break;
		len = limiter.second - limiter.first + 1;
		if (len > 299)
			len = 299; // Защита буфера name[300]
		strncpy(table[counter].name, buf + limiter.first, len);
		table[counter].name[len] = 0;

		// File & Ext
		if (findLimiters(limiter.second) == -2)
			break;
		len = limiter.second - limiter.first - 3;
		if (len > 299)
			len = 299; // Защита буфера file[300]
		if (len < 0)
			len = 0;
		strncpy(table[counter].file, buf + limiter.first, len);
		table[counter].file[len] = 0;

		strncpy(table[counter].ext, buf + limiter.second - 2, 3);
		table[counter].ext[3] = 0; // Правильное закрытие строки из 3 символов

		// Size
		if (findLimiters(limiter.second) == -2)
			break;
		table[counter].size = atol(buf + limiter.first);

		// Option
		if (findLimiters(limiter.second) == -2)
			break;
		table[counter].option = atoi(buf + limiter.first);

		// Year
		if (findLimiters(limiter.second) == -2)
			break;
		table[counter].year = atoi(buf + limiter.first);

		limiter.second++;
		counter++;
	} while (counter < 12);
}

// Выносим логику поиска в отдельную подфункцию
char triggerSearch(void)
{
	limiter.total = 0;
	limiter.curline = 0;
	curWin.w = 40;
	curWin.x = 80 / 2 - curWin.w / 2 - 1;
	curWin.y = 10;
	curWin.h = 1;
	curWin.text = 103;
	curWin.back = 103;
	strcpy(curWin.tittle, "Введите поисковый запрос");

	if (inputBox(&curWin, ""))
	{
		strcpy(search, cmd);
		limiter.curPage = 0;
		drawSearch();
	}
	else
	{
		mainWinDraw();
		OS_SETXY(32, 11);
		OS_SETCOLOR(206);
		puts("No results found");
		return false;
	}

	if (makeRequest(search) < 2)
	{
		mainWinDraw();
		OS_SETXY(32, 11);
		OS_SETCOLOR(206);
		puts("No results found");
		return false;
	}

	OS_SETXY(1, 2);
	OS_SETCOLOR(206);
	fillTable();
	return true;
}

char getKey(void)
{
	char key;
	key = OS_GETKEY();

	// ЗАПОМИНАЕМ старую позицию курсора перед обработкой нажатия
	limiter.oldline = limiter.curline;

	switch (key)
	{
	case 27: // escape - exit
		OS_CLS(0);
		OS_SETGFX(-1);
		exit(0);
		break;

	case 's':
	case 'ы':
	case 'Ы':
	case 'S':
	fuckingoto:
		limiter.total = 0;
		limiter.curline = 0;
		curWin.w = 40;
		curWin.x = 80 / 2 - curWin.w / 2 - 1;
		curWin.y = 10;
		curWin.h = 1;
		curWin.text = 103;
		curWin.back = 103;
		strcpy(curWin.tittle, "Введите поисковый запрос");

		if (inputBox(&curWin, ""))
		{
			strcpy(search, cmd);
			limiter.curPage = 0;
			drawSearch();
		}
		else
		{
			mainWinDraw();
			OS_SETXY(32, 11);
			OS_SETCOLOR(206);
			puts("No results found");
			limiter.total = 0;
			limiter.curline = 0;
			break;
		}

		if (makeRequest(search) < 2)
		{
			mainWinDraw();
			OS_SETXY(32, 11);
			OS_SETCOLOR(206);
			puts("No results found");
			limiter.total = 0;
			limiter.curline = 0;
			return key;
		}

		OS_SETXY(1, 2);
		OS_SETCOLOR(206);
		fillTable();

		// ПОСЛЕ ПОИСКА: Перерисовываем экран и выводим ВСЕ новые результаты
		mainWinDraw();
		renderResult(limiter.curline);
		break;

	case 'h':
	case 'H':
	case 'р':
	case 'Р':
		limiter.total = 0;
		limiter.curline = 0;
		curHost++;
		if (curHost > 1) // Специально пропускаем hood.speccy.cz, как вы и задумывали
		{
			curHost = 0;
		}
		strcpy(link.host, hosts[curHost]);

		// ПРИ СМЕНЕ ХОСТА: Полная очистка экрана и перерисовка таблицы
		mainWinDraw();
		renderResult(limiter.curline);
		break;

	case 'q':
	case 'Q':
	case 'Й':
	case 'й':
	case 250: // СТРЕЛКА ВВЕРХ (или 'q')
		if (limiter.total != 0)
		{
			// Вычисляем максимум элементов на экране (не больше total и не больше 10)
			unsigned char maxLines = (limiter.total > 10) ? 10 : limiter.total;
			if (limiter.curline < 1)
			{
				limiter.curline = maxLines - 1;
			}
			else
			{
				limiter.curline--;
			}
		}
		break;

	case 'a':
	case 'A':
	case 'ф':
	case 'Ф':
	case 249: // СТРЕЛКА ВНИЗ (или 'a')
		if (limiter.total != 0)
		{
			unsigned char maxLines = (limiter.total > 10) ? 10 : limiter.total;
			if (limiter.curline >= maxLines - 1)
			{
				limiter.curline = 0;
			}
			else
			{
				limiter.curline++;
			}
		}
		break;

	case 248: // СТРЕЛКА ВЛЕВО (Предыдущая страница)
	case 'o':
		if (limiter.curPage != 0 && limiter.total != 0)
		{
			limiter.curPage--;
			mainWinDraw();
			if (makeRequest(search) < 2)
			{
				OS_SETXY(32, 11);
				OS_SETCOLOR(206);
				puts("No results found");
				limiter.total = 0;
				limiter.curline = 0;
				break;
			}
			fillTable();
			limiter.curline = 0;

			// ПРИ СМЕНЕ СТРАНИЦЫ: Полная перерисовка результатов
			renderResult(limiter.curline);
		}
		break;

	case 251: // СТРЕЛКА ВПРАВО (Следующая страница)
	case 'p':
		if (limiter.total != 0)
		{
			limiter.curPage++;
			mainWinDraw();
			if (makeRequest(search) < 2)
			{
				limiter.curPage--;
				drawPage();
				makeRequest(search);
			}
			fillTable();
			limiter.curline = 0;

			// ПРИ СМЕНЕ СТРАНИЦЫ: Полная перерисовка результатов
			renderResult(limiter.curline);
		}
		break;

	case 13: // ENTER
		if (limiter.total != 0)
		{
			getFile(limiter.curline);
		}
		else
		{
			goto fuckingoto;
		}
		break;

	default:
		break;
	}

	// ОПТИМИЗИРОВАННЫЙ БЛОК ОТРИСОВКИ:
	if (key != 0)
	{
		// Если это обычное перемещение курсора вверх/вниз в пределах текущей таблицы
		if (limiter.curline != limiter.oldline)
		{
			renderSingleLine(limiter.oldline, false); // Снимаем подсветку со старой строки
			renderSingleLine(limiter.curline, true);  // Подсвечиваем новую строку
		}
	}
	else
	{
		YIELD(); // Если клавиша не нажата, отдаем квант времени ОС NedoOS
	}
	return key;
}

C_task main(void)
{
	OS_HIDEFROMPARENT();
	OS_SETGFX(0x86);
	OS_CLS(0);
	OS_SETSYSDRV();
	printf("[Build:%s  %s]", __DATE__, __TIME__);
	init();
	// printTable();
	//  waitKey();
	OS_CLS(0);
	mainWinDraw();

	do
	{
		getKey();
	} while (42);
}
