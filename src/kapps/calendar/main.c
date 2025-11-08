#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <tcp.h>
#include <intrz80.h>
#include <stdlib.h>
#include <../common/terminal.c>
#include <osfs.h>
//
#define true 1
#define false 0

FILE *fp2;

char cmd[128];
char curPath[256];
char holidays[13][32];
unsigned char netbuf[2048];
char calbuf[24000];
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

struct rtc
{
	unsigned char hours;
	unsigned char minutes;
	unsigned char seconds;
	unsigned char day;
	unsigned char month;
	unsigned int year;
} clock;

struct params
{
	char useProdCalendar;
	char currentCountry[3];
	char machineType;
} ini;

struct sockaddr_in dnsaddress;
struct sockaddr_in targetadr;
struct readstructure readStruct;

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
unsigned int magic = 16;
unsigned long factor, timerok, count = 0;

unsigned int odoa = 12;
char foreColor;
unsigned int errn, headlng;
unsigned long contLen;
//const unsigned char sendOk[] = "SEND OK";
const unsigned char gotWiFi[] = "WIFI GOT IP";
unsigned char userAgent[] = "Host: xmlcalendar.ru\r\nConnection: keep-alive\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)\r\n\r\n";
char country2[5][2] = {"ru", "kz", "by", "uz", "ua"};
char country10[5][11] = {"Россия", "Казахстан", "Беларусь", "Узбекистан", "Украина"};

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
	ATRIB(40);
	AT(1, 24);
	spaces(80);
	AT(1, 24);
}

void readClock(void)
{
	unsigned long dosTime;
	dosTime = OS_GETTIME();

	clock.hours = dosTime >> 11 & 31;	 // 0b00011111
	clock.minutes = (dosTime >> 5) & 63; // 0b00111111
	clock.seconds = (dosTime & 31) * 2;	 // 0b00011111
	clock.day = dosTime >> 16 & 31;
	clock.month = dosTime >> 21 & 15;
	clock.year = (dosTime >> 25 & 63) + 1980;
}

void calendarBox(struct window w, const unsigned char *message)
{
	unsigned char wcount, tempx, tittleStart;

	w.h++;
	AT(w.x, w.y - 1);
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
	tittleStart = w.x + (w.w / 2) - (strlen(w.tittle) / 2);
	AT(tittleStart, w.y);
	printf("[%s]", w.tittle);
	AT(w.x + 1, w.y + 1);
	ATRIB(w.back);
	tittleStart = w.x + (w.w / 2) - (strlen(message) / 2);
	AT(tittleStart, w.y + 1);
	printf("%s", message);
}

void printMonthNoProdCal(int month, int year, char xPos, char yPos)
{
	int y, k, j, count, prevMonth;
	char monthsList[12][10] = {"Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"};
	int mDays[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
	static int t[] = {6, 2, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4};
	int days;
	int current;
	char toDay = 0;

	curWin.w = 22;
	curWin.x = xPos;
	curWin.y = yPos;
	curWin.h = 7;
	curWin.text = 30;
	curWin.back = 47;
	strcpy(curWin.tittle, monthsList[month - 1]);
	calendarBox(curWin, "");

	/*
	 1) Определим номер дня недели, где:

	 0 - Понедельник
	 1 - Вторник
	 2 - Среда
	 3 - Четверг
	 4 - Пятница
	 5 - Суббота
	 6 - Воскресенье

	 */

	if (month == clock.month && year == clock.year)
	{
		toDay = true;
	}
	else
	{
		toDay = false;
	}

	y = year % 100;
	current = y / 12 + y % 12 + y % 12 / 4 + t[month - 1] +
			  (20 - year / 100);

	if ((year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)) &&
		month <= 2)
		current--;

	current = current % 7;

	/*
	 2) Проверка на високосность начиная с нулевого месяца:
	 0 - январь
	 ...
	 11 - декабрь
	 */
	if (month ==
		2) // 1 - это февраль месяц, так как счёт начинается с 0.
		if (year % 400 == 0 || (year % 4 == 0 && year % 100 != 0))
			days = 29; // Если високосный
		else
			days = mDays[month - 1];
	else
		days = mDays[month - 1];

	AT(curWin.x + 1, curWin.y + 1);
	puts(" Пн Вт Ср Чт Пт Сб Вс");
	/*
	 4) Вводим доп. переменные k и j:
	 k - количество дней в неделе от 0 до 6 (0 - ПН; 6 - ВС)
	 j - количество дней в месяце (от 1 до общего в месяце)
	 */
	AT(curWin.x + 1, curWin.y + 2);
	ATRIB(47);

	if (month != 1)
	{
		prevMonth = month - 2;
	}
	else
	{
		prevMonth = 11;
	}
	ATRIB(90);
	for (k = 0; k < current; k++)
	{
		printf("%3d", k + 1 + mDays[prevMonth] - current);
	}
	ATRIB(foreColor);
	for (j = 1; j <= days; j++)
	{
		k++;

		if (k > 5)
		{
			ATRIB(31);
		}

		if (toDay && (j == clock.day))
		{
			putchar(' ');
			ATRIB(44);
			if (k > 5)
			{
				ATRIB(41);
				ATRIB(foreColor);
			}
			printf("%2d", j);
		}
		else
		{
			printf("%3d", j);
		}

		if (toDay && (j == clock.day))
		{
			ATRIB(47);
		}

		if (k > 6)
		{
			k = 0;
			ATRIB(foreColor);
			AT(curWin.x + 1, curWin.y++ + 3);
		}
	}
	ATRIB(90);
	for (count = 1; count < 8 - k; count++)
	{
		printf("%3d", count);
	}
}

void printMonth(int month, int year, char xPos, char yPos)
{
	int y, k, j, count, prevMonth;
	char monthsList[12][10] = {"Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"};
	int mDays[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
	static int t[] = {6, 2, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4};
	int days;
	int current;
	char toDay = 0;

	curWin.w = 22;
	curWin.x = xPos;
	curWin.y = yPos;
	curWin.h = 7;
	curWin.text = 30;
	curWin.back = 47;
	strcpy(curWin.tittle, monthsList[month - 1]);
	calendarBox(curWin, "");

	/*
	 1) Определим номер дня недели, где:

	 0 - Понедельник
	 1 - Вторник
	 2 - Среда
	 3 - Четверг
	 4 - Пятница
	 5 - Суббота
	 6 - Воскресенье

	 */

	if (month == clock.month && year == clock.year)
	{
		toDay = true;
	}
	else
	{
		toDay = false;
	}

	y = year % 100;
	current = y / 12 + y % 12 + y % 12 / 4 + t[month - 1] +
			  (20 - year / 100);

	if ((year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)) &&
		month <= 2)
		current--;

	current = current % 7;

	/*
	 2) Проверка на високосность начиная с нулевого месяца:
	 0 - январь
	 ...
	 11 - декабрь
	 */
	if (month ==
		2) // 1 - это февраль месяц, так как счёт начинается с 0.
		if (year % 400 == 0 || (year % 4 == 0 && year % 100 != 0))
			days = 29; // Если високосный
		else
			days = mDays[month - 1];
	else
		days = mDays[month - 1];

	AT(curWin.x + 1, curWin.y + 1);
	puts(" Пн Вт Ср Чт Пт Сб Вс");
	/*
	 4) Вводим доп. переменные k и j:
	 k - количество дней в неделе от 0 до 6 (0 - ПН; 6 - ВС)
	 j - количество дней в месяце (от 1 до общего в месяце)
	 */
	AT(curWin.x + 1, curWin.y + 2);
	ATRIB(47);

	if (month != 1)
	{
		prevMonth = month - 2;
	}
	else
	{
		prevMonth = 11;
	}
	ATRIB(90);
	for (k = 0; k < current; k++)
	{
		printf("%3d", k + 1 + mDays[prevMonth] - current);
	}
	ATRIB(foreColor);
	for (j = 1; j <= days; j++)
	{
		k++;
		if (holidays[month][j])
		{
			ATRIB(31);
		}
		else
		{
			ATRIB(foreColor);
		}
		if (toDay && (j == clock.day))
		{
			putchar(' ');
			ATRIB(44);
			if (holidays[month][j])
			{
				ATRIB(41);
				ATRIB(foreColor);
			}
			printf("%2d", j);
		}
		else
		{
			printf("%3d", j);
		}

		if (toDay && (j == clock.day))
		{
			ATRIB(47);
		}

		if (k > 6)
		{
			k = 0;
			AT(curWin.x + 1, curWin.y++ + 3);
		}
	}
	ATRIB(90);
	for (count = 1; count < 8 - k; count++)
	{
		printf("%3d", count);
	}
}

unsigned char inputBox(struct window w, unsigned char *prefilled)
{
	unsigned char wcount, tempx, tittleStart;
	unsigned char byte, counter;
	w.h++;
	AT(w.x, w.y - 1);
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
	tittleStart = w.x + (w.w / 2) - (strlen(w.tittle) / 2);
	AT(tittleStart, w.y);
	printf("[%s]", w.tittle);
	AT(w.x + 1, w.y + 1);
	ATRIB(w.back);
	// putchar(219);

	cmd[0] = 0;

	counter = strlen(prefilled);
	if (counter != 0)
	{
		strcpy(cmd, prefilled);
		goto skipKeys;
	}

	do
	{
		byte = getchar();
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
				AT(w.x + 1, w.y + 1);
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
			AT(w.x + 1, w.y + 1);
			printf("%s", cmd);
			// putchar(219);
			if (byte == 0x08)
			{
				putchar(' ');
			}
		}
		YIELD();
	} while (42);
	return false;
}

void clearHolidays(void)
{
	char month, day;
	for (month = 0; month < 13; month++)
	{
		for (day = 0; day < 32; day++)
		{
			holidays[month][day] = false;
		}
	}
}

char readParamFromIni(void)
{
	FILE *fpini;
	// char skip2end = false;
	// unsigned int count = 0;
	// unsigned long loop = 0;
	unsigned char *count1;

	const char useProdCalendar[] = "useProdCalendar";
	const char currentCountry[] = "currentCountry";

	OS_GETPATH((unsigned int)&curPath);
	OS_SETSYSDRV();
	OS_CHDIR("/");
	OS_CHDIR("ini");

	fpini = OS_OPENHANDLE("calendar.ini", 0x80);
	if (((int)fpini) & 0xff)
	{
		clearStatus();
		printf("calendar.ini not found.\r\n");
		getchar();
		return false;
	}

	OS_READHANDLE(calbuf, fpini, 512);
	OS_CLOSEHANDLE(fpini);

	// calbuf[loop + 1] = 0;

	count1 = strstr(calbuf, useProdCalendar);
	if (count1 != NULL)
	{
		sscanf(count1 + strlen(useProdCalendar) + 1, "%d", &ini.useProdCalendar);
	}

	count1 = strstr(calbuf, currentCountry);
	if (count1 != NULL)
	{
		sscanf(count1 + strlen(currentCountry) + 1, "%c", &ini.currentCountry[0]);
		sscanf(count1 + strlen(currentCountry) + 2, "%c", &ini.currentCountry[1]);
		ini.currentCountry[2] = 0;
	}

	OS_CHDIR(curPath);
	return true;
}

char loadProdCalDisk(int year)
{
	FILE *fpdat;
	unsigned long loaded, total = 0;
	// int lineYear = 0;
	// int lineMonth = 0;
	// int lineDay = 0;
	odoa = 12;
	clearStatus();
	printf("Загрузка производственного кадендаря с диска на %d год", year);

	OS_GETPATH((unsigned int)&curPath);
	OS_SETSYSDRV();
	OS_CHDIR("/");
	OS_CHDIR("ini");
	fpdat = OS_OPENHANDLE("calendar.ini", 0x80);
	if (((int)fpdat) & 0xff)
	{
		clearStatus();
		printf("calendar.ini not found.\r\n");
		getchar();
		return false;
	}

	do
	{
		loaded = OS_READHANDLE(calbuf + total, fpdat, sizeof(calbuf));
		total = total + loaded;
	} while (loaded != 0);
	OS_CLOSEHANDLE(fpdat);
	OS_CHDIR(curPath);
	return 1;
}

char fillProdCal(int year)
{
	int lineYear = 0;
	int lineMonth = 0;
	int lineDay = 0;
	char result = false;
	unsigned int count;
	char *yptr;

	clearHolidays();

	sprintf(cmd, "%d", year);
	yptr = strstr(calbuf, cmd);

	if (yptr == NULL)
	{
		return result;
	}

	count = 0;
	clearStatus();
	while (42)
	{

		// 2024.01.01CL
		sscanf(yptr + 0 + count, "%d", &lineYear);
		sscanf(yptr + 5 + count, "%d", &lineMonth);
		sscanf(yptr + 8 + count, "%d", &lineDay);
		count = count + odoa;

		if (lineYear != year)
		{
			return result;
		}

		if (lineDay < 32 && lineMonth < 13 && lineDay > 0 && lineMonth > 0)
		{
			holidays[lineMonth][lineDay] = true;
			result = true;
			//	printf("lineDay=[%02d] lineMonth=[%02d] lineYear=[%04d]\r\n", lineDay, lineMonth, lineYear);
		}
	}
	return result;
}

#include <../common/esp-com.c>
#include <../common/network.c>

int cutHeader(unsigned int todo)
{
	unsigned int err;
	unsigned char *count1;

	err = httpError();
	if (err != 200)
	{
		/*
				BOX(1, 1, 80, 25, 40, 32);
				AT(1, 1);
				printf("HTTP ERROR %u", err);
				puts("^^^^^^^^^^^^^^^^^^^^^");
				puts(netbuf);
				getchar();
		*/
		return -1;
	}
	count1 = strstr(netbuf, "Content-Length:");
	if (count1 == NULL)
	{
		printf("contLen  not found \r\n");
		contLen = 0;
	}
	else
	{
		contLen = atol(count1 + 15);
		// printf("Content-Length: %lu \n\r", contLen);
	}

	count1 = strstr(netbuf, "\r\n\r\n");
	if (count1 == NULL)
	{
		printf("header not found\r\n");
	}
	else
	{
		headlng = ((unsigned int)count1 - (unsigned int)netbuf + 4);
		// printf("header %u bytes\r\n", headlng);
	}
	return todo - headlng;
}

char fillBuffer(signed char socket)
{
	int todo;
	unsigned int w, pPos, headskip;

	headskip = 0;
	pPos = 0;
	while (42)
	{
		headlng = 0;
		todo = tcpRead(socket, 20);
		testOperation("OS_WIZNETREAD", todo);

		if (headskip == 0)
		{
			headskip = 1;
			todo = cutHeader(todo);

			if (todo == -1)
			{
				return false;
			}
		}
		for (w = 0; w < todo; w++)
		{
			calbuf[w + pPos] = netbuf[w + headlng];
		}
		pPos = pPos + todo;
		if (pPos == contLen)
		{
			break;
		}
	}
	netShutDown(socket, 0);
	calbuf[pPos + 0] = 0;
	strcat(calbuf, "\n9999.12.31\n");
	return true;
}

unsigned char loadProdCalNet(int year, const char *country)
{
	int todo;
	char socket;
	odoa = 11;

	clearStatus();
	printf("Загрузка производственного кадендаря через NedoNet на %d год", year);

	dnsResolve("xmlcalendar.ru");
	socket = OpenSock(AF_INET, SOCK_STREAM);
	testOperation("OS_NETSOCKET", socket);

	todo = netConnect(socket, 10);
	testOperation("OS_NETCONNECT", todo);

	sprintf(netbuf, "GET /data/%s/%d/calendar.txt HTTP/1.1\r\n%s", country, year, userAgent);

	todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf), 10);
	testOperation("OS_WIZNETWRITE", todo);
	fillBuffer(socket);
	return 2;
}

unsigned char loadProdCalEsp(int year, const char *country)
{
	unsigned char sizeLink = 0;
	unsigned long downloaded = 0;
	unsigned char byte, count = 0, try = 0;
	unsigned int dataSize;
	unsigned char skipHeader = 0;
	const unsigned char *count1;
	odoa = 11;

	sprintf(curPath, "GET /data/%s/%d/calendar.txt HTTP/1.1\r\n%s", country, year, userAgent);
	sizeLink = strlen(curPath);
	try = 0;
	do
	{
		try++;
		if (try > 1)
		{
			printf("----->Retry:%u\r\n", try);
			delay(500);
		}
		sendcommand("AT+CIPSTART=\"TCP\",\"xmlcalendar.ru\",80");
		getAnswer3(); // CONNECT or ERROR or link is not valid
		count1 = strstr(netbuf, "CONNECT");
	} while (count1 == NULL);

	getAnswer3(); // OK

	sprintf(netbuf, "AT+CIPSEND=%u", sizeLink + 2); // second CRLF in send command
	sendcommand(netbuf);
	getAnswer3();
	do
	{
		byte = uartReadBlock();
		// putchar(byte);
	} while (byte != '>');
	sendcommand(curPath);
	/*
		count = 0;

		do
		{
			byte = uartReadBlock();
			if (byte == sendOk[count])
			{
				count++;
			}
			else
			{
				count = 0;
			}
		} while (count < strlen(sendOk));
		uartReadBlock(); // CR
		uartReadBlock(); // LF
	*/
	skipHeader = 0;
	downloaded = 0;
	do
	{
		headlng = 0;
		dataSize = recvHead();
		
			if (dataSize == 0)
		{
			writeLog("Error parsing packet size, dataSize = 0", "loadProdCalEsp ");
			writeLog(netbuf, "loadProdCalEsp ");
			return false;
		}	
		
		getdataEsp(dataSize); // Requested size
		if (skipHeader == 0)
		{
			dataSize = cutHeader(dataSize);
			skipHeader = 1;
			if (dataSize == -1)
			{
				return false;
			}
		}
		memcpy(calbuf + downloaded, netbuf + headlng, dataSize);
		downloaded = downloaded + dataSize;

	} while (downloaded < contLen);
	sendcommand("AT+CIPCLOSE");
	getAnswer3(); // CLOSED
	getAnswer3(); // OK
	calbuf[downloaded + 1] = 0;
	strcat(calbuf, "\n9999.12.31\n");

	return 3;
}

C_task main(int argc, char *argv[])
{
	int x, y, year, half;
	char key;
	char ci = 0;

	targetadr.porth = 00;
	targetadr.portl = 80;
	strcpy(ini.currentCountry, "ru");
	ini.useProdCalendar = false;

	os_initstdio();
	CLS();
	printf("[Build:%s  %s]", __DATE__, __TIME__);
	loadEspConfig();
	get_dns();
	AT(3, 25);
	ATRIB(40);
	ATRIB(90);
	printf("Онлайн производственный календарь предоставлен сайтом http://xmlcalendar.ru/");
	ATRIB(97);
	YIELD();

	readParamFromIni();

	ini.machineType = (unsigned char)OS_GETCONFIG();
	// L= 1-Evo 2-ATM2 3-ATM3 6-p2.666 ;E=pgsys(system page) D= TR-DOS page
	if (ini.machineType == 1)
	{
		foreColor = 97;
	}
	else
	{
		foreColor = 30;
	}

	if (ini.useProdCalendar == 3)
	{
		uart_init(divider);
		espReBoot();
	}

	BOX(1, 1, 80, 24, 44, 32);

	AT(1, 1);
	ATRIB(97);
	ATRIB(44);

	half = 0;

	if (argc == 1)
	{
		readClock();
		year = clock.year;
		AT(4, 2);
		printf("Сегодня: %02u-%02u-%04u", clock.day, clock.month, clock.year);

		if (clock.month > 5)
		{
			half = 6;
		}
	}
	else if (argc == 2)
	{
		char *p = argv[1];
		sscanf(p, "%d", &year);
	}

	x = 4;
	y = 4;

	AT(1, 25);
	ATRIB(40);
	spaces(79);

loop:
	clearStatus();
	switch (ini.useProdCalendar)
	{
	case 0:
		break;
	case 1:
		ini.useProdCalendar = loadProdCalDisk(year);
		break;
	case 2:
		ini.useProdCalendar = loadProdCalNet(year, ini.currentCountry);
		break;
	case 3:
		ini.useProdCalendar = loadProdCalEsp(year, ini.currentCountry);
		break;
	default:
		break;
	}
	if (ini.useProdCalendar != 0)
	{
		if (fillProdCal(year) == false)
		{
			ini.useProdCalendar = false;
			clearStatus();
			printf("Не найден и выключен производственный календарь на %d год. ", year);
		}
	}
loop2:

	// 0 - not use; 1 - use file; 2 - use NedoNet; 3 - use ESP-COM;
	switch (ini.useProdCalendar)
	{
	case 0:
		strcpy(cmd, "Выключены");
		break;

	case 1:
		strcpy(cmd, " Из файла");
		break;
	case 2:
	case 3:
		strcpy(cmd, "  Сетевые");
		break;
	default:
		break;
	}

	AT(60, 2);
	ATRIB(97);
	ATRIB(44);
	printf("Выходные:%s", cmd);
	clearStatus();

	ATRIB(93);
	ATRIB(44);

	switch (ini.currentCountry[0])
	{
	case 'r':
		ci = 0;
		break;
	case 'k':
		ci = 1;
		break;
	case 'b':
		ci = 2;
		break;
	case 'u':
		if (ini.currentCountry[1] == 'z')
		{
			ci = 3;
		}
		else if (ini.currentCountry[1] == 'a')
		{
			ci = 4;
		}
		break;
	}
	AT(40 - (strlen(country10[ci]) / 2) - 3, 2);
	printf("[%s %d]", country10[ci], year);

	if (ini.useProdCalendar == 0)
	{
		printMonthNoProdCal(1 + half, year, x + 00, y + 00);
		printMonthNoProdCal(2 + half, year, x + 25, y + 00);
		printMonthNoProdCal(3 + half, year, x + 50, y + 00);
		printMonthNoProdCal(4 + half, year, x + 00, y + 10);
		printMonthNoProdCal(5 + half, year, x + 25, y + 10);
		printMonthNoProdCal(6 + half, year, x + 50, y + 10);
		ATRIB(40);
		ATRIB(37);
	}
	else
	{
		printMonth(1 + half, year, x + 00, y + 00);
		printMonth(2 + half, year, x + 25, y + 00);
		printMonth(3 + half, year, x + 50, y + 00);
		printMonth(4 + half, year, x + 00, y + 10);
		printMonth(5 + half, year, x + 25, y + 10);
		printMonth(6 + half, year, x + 50, y + 10);
		ATRIB(40);
		ATRIB(37);
	}

	key = getchar();
	switch (key)
	{
	case 250: // Up
		year++;
		half = 0;
		break;
	case 249: // down
		year--;
		half = 0;
		break;
	case 'Y':
	case 'y':

		curWin.w = 14;
		curWin.x = 80 / 2 - curWin.w / 2;
		curWin.y = 9;
		curWin.h = 1;
		curWin.text = 97;
		curWin.back = 42;
		strcpy(curWin.tittle, "Введите год:");

		if (inputBox(curWin, ""))
		{
			sscanf(cmd, "%d", &year);
			half = 0;
		}

		break;

	case 'h': // File
	case 'H':
		if (ini.useProdCalendar != 0)
			ini.useProdCalendar = 0;
		else
			ini.useProdCalendar = 1;
		break;

	case 'n': // NedoNET
	case 'N':
		ini.useProdCalendar = 2;
		break;
	case 'e': // ESP-COM
	case 'E':
		ini.useProdCalendar = 3;
		break;
	default:
		if (half == 0)
		{
			half = 6;
		}
		else
		{
			half = 0;
		}
		goto loop2;
	}
	goto loop;
}
