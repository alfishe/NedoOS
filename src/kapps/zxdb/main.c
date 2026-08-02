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

unsigned char uVer[] = "0.4";
unsigned char curPath[128];
unsigned char cmd[256];
unsigned char search[256];
unsigned char crlf[2] = {13, 10};
const unsigned char gotWiFi[] = "WIFI GOT IP";
char hosts[3][32] = {"next.zxart.ee", "zxdb.remysharp.com", "hood.speccy.cz"};
unsigned char userAgent1[] = " HTTP/1.1\r\nHost: ";
unsigned char userAgent2[] = "\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS; ZXDB)\r\n\r\n\0";
unsigned char netbuf[4096];
unsigned char buf[16384];
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
	unsigned char tittle[80];
} curWin;

struct time
{
	unsigned int hours;
	unsigned int minutes;
	unsigned char oldMinutes;

} clock;

struct linkStruct
{
	unsigned char host[128];
	unsigned char path[512];
	unsigned int port;
	unsigned char hasName;
	unsigned char fname[256];
} link;

struct line
{
	unsigned long id;
	unsigned char name[512];
	unsigned char file[512];
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
//////////////////////////

void clearNetbuf(void)
{
	unsigned int counter;
	for (counter = 0; counter < sizeof(netbuf); counter++)
	{
		netbuf[counter] = 0;
	}
}

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

unsigned char saveBuf(unsigned char *fileNamePtr, unsigned char operation, unsigned int sizeOfBuf)
{
	FILE *fp2;

	switch (operation)
	{
	case 00:
		fp2 = OS_CREATEHANDLE(fileNamePtr, 0x80);
		if (((int)fp2) & 0xff)
		{
			clearStatus();
			printf("%s  creating error.", fileNamePtr);
			getchar();
			exit(0);
		}
		OS_CLOSEHANDLE(fp2);
		break;
	case 01:
		fp2 = OS_OPENHANDLE(fileNamePtr, 0x80);
		if (((int)fp2) & 0xff)
		{
			clearStatus();
			printf("%s opening error.\r\n ", fileNamePtr);
			getchar();
			exit(0);
		}
		OS_SEEKHANDLE(fp2, OS_GETFILESIZE(fp2));
		OS_WRITEHANDLE(netbuf + limiter.headLng, fp2, sizeOfBuf);
		OS_CLOSEHANDLE(fp2);
		break;
	case 02:
		OS_CLOSEHANDLE(fp2);
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
	get_dns();
	netDriver = readParamFromIni();
	if (netDriver == 1)
	{
		loadEspConfig();
		uart_init(divider);
		espReBoot();
	}
	OS_SETSYSDRV();
	OS_MKDIR("../downloads");	   // Create if not exist
	OS_MKDIR("../downloads/zxdb"); // Create if not exist
	OS_CHDIR("../downloads/zxdb");

	strcpy(link.host, hosts[curHost]);
	clock.oldMinutes = 255;
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

void simpleBox(struct window w)
{
	unsigned char wcount, tempx;
	w.h = w.h - 2;
	OS_SETXY(w.x, w.y);
	BDBOX(w.x, w.y + 1, w.w, w.h, w.back, 32);
	w.w = w.w - 2;
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

void sendReqdialog(void)
{
	curWin.w = 50;
	curWin.x = 39 - curWin.w / 2;
	curWin.y = 10;
	curWin.h = 4;
	curWin.text = 223;
	curWin.back = 223;
	simpleBox(curWin);
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
	simpleBox(curWin);
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

char *insert_string(const char *original, const char *to_insert, unsigned int position)
{
	unsigned int original_len = strlen(original);
	unsigned int insert_len = strlen(to_insert);
	unsigned int new_len = original_len + insert_len;

	char *new_string = (char *)malloc(new_len + 1); // +1 для \0
	if (new_string == NULL)
	{
		return NULL; // Обработка ошибки выделения памяти
	}

	// Копирование части исходной строки до позиции вставки
	strncpy(new_string, original, position);
	new_string[position] = '\0';

	// Вставка строки
	strcat(new_string, to_insert);

	// Добавление оставшейся части исходной строки
	strcat(new_string, original + position);

	return new_string;
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
	simpleBox(curWin);

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
				if (inputBox(curWin, link.fname))
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
	sendcommand("AT+CIPCLOSE");
	getAnswer3(); // CLOSED
	getAnswer3(); // OK
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
				if (inputBox(curWin, link.fname))
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
	return downloaded;
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
	} while (downloaded != contLen); // ref < лучше

	netShutDown(socket, 0);
	buf[downloaded + 1] = 0;
	return downloaded;
}

char makeRequest(const char *request)
{
	char result;
	unsigned int counter, len;
	char tempreq[256];

	sendReqdialog();

	strcpy(tempreq, request);
	len = strlen(tempreq);
	for (counter = 0; counter < len; counter++)
	{
		if (tempreq[counter] == ' ' || tempreq[counter] == '-')
		{
			tempreq[counter] = '*';
		}
	}
	sprintf(link.path, "GET /?s=%s&p=%d%s%s%s", tempreq, limiter.curPage, userAgent1, link.host, userAgent2);

	switch (netDriver)
	{
	case 0:
		result = makeRequestNet();
		break;
	case 1:
		result = makeRequestEsp();
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
		if (len > 511)
			len = 511; // Защита буфера name[512]
		strncpy(table[counter].name, buf + limiter.first, len);
		table[counter].name[len] = 0;

		// File & Ext
		if (findLimiters(limiter.second) == -2)
			break;
		len = limiter.second - limiter.first - 3;
		if (len > 511)
			len = 511; // Защита буфера file[512]
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

	if (inputBox(curWin, ""))
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

		if (inputBox(curWin, ""))
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

C_task main(int argc, const char *argv[])
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
