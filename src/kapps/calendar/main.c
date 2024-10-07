#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <tcp.h>
#include <intrz80.h>
#include <stdlib.h>
#include <../common/terminal.c>
#include <osfs.h>

#define true 1
#define false 0

char cmd[128];
char curPath[128];
char holidays[13][32];
char netbuf[20000];
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
} ini;

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

void calendarBox(struct window w, unsigned char *message)
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
	ATRIB(97);
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
				ATRIB(97);
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
			ATRIB(97);
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
	ATRIB(97);
	for (j = 1; j <= days; j++)
	{
		k++;
		if (holidays[month][j])
		{
			ATRIB(31);
		}
		else
		{
			ATRIB(97);
		}
		if (toDay && (j == clock.day))
		{
			putchar(' ');
			ATRIB(44);
			if (holidays[month][j])
			{
				ATRIB(41);
				ATRIB(97);
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
	char skip2end = false;
	unsigned int count = 0;
	unsigned long loaded, loop;
	unsigned char *count1;

	char useProdCalendar[] = "useProdCalendar";
	FILE *fpini;
	OS_GETPATH((unsigned int)&curPath);
	OS_SETSYSDRV();
	OS_CHDIR("/");
	OS_CHDIR("ini");

	fpini = OS_OPENHANDLE("calendar.ini", 0x80);
	if (((int)fpini) & 0xff)
	{
		printf("calendar.ini not found.\r\n");
		getchar();
		// Здесь будет заполнение  настроек по умолчанию.
		return false;
	}

	loaded = OS_READHANDLE(netbuf, fpini, 256);
	OS_CLOSEHANDLE(fpini);
	netbuf[loop + 1] = 0;

	count1 = strstr(netbuf, useProdCalendar);
	if (count1 == NULL)
	{
		ini.useProdCalendar = false;
	}
	else
	{
		sscanf(count1 + strlen(useProdCalendar) + 1, "%d", &ini.useProdCalendar);

		printf("useProdCalendar = '%d'\r\n", ini.useProdCalendar);
	}

	OS_CHDIR(curPath);
	return true;
}

char loadProdCalDisk(int year)
{
	// 2025.01.01
	FILE *fpdat;
	unsigned long loaded, total;
	int lineYear = 0;
	int lineMonth = 0;
	int lineDay = 0;
	char result;
	unsigned int count;
	char *yptr;

	clearStatus();
	printf("Загрузка производственного кадендаря на %d год", year);

	clearHolidays();

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

	result = false;
	total = 0;
	count = 0;

	do
	{
		loaded = OS_READHANDLE(netbuf + total, fpdat, sizeof(netbuf));
		total = total + loaded;
	} while (loaded != 0);
	OS_CLOSEHANDLE(fpdat);
	OS_CHDIR(curPath);

	sprintf(cmd, "%d", year);
	yptr = strstr(netbuf, cmd);

	if (yptr == NULL)
	{
		return result;
	}

	while (42)
	{
		// 2024.01.01CL
		sscanf(yptr + 0 + count, "%d", &lineYear);
		sscanf(yptr + 5 + count, "%d", &lineMonth);
		sscanf(yptr + 8 + count, "%d", &lineDay);
		count = count + 12;
		// clearStatus();
		// printf("lineDay=[%d] lineMonth=[%d] lineYear=[%d] year = [%d] \r", lineDay, lineMonth, lineYear, year);

		if (lineYear != year)
		{
			clearStatus();
			return result;
		}

		if (lineDay < 32 && lineMonth < 13 && lineDay > 0 && lineMonth > 0)
		{
			holidays[lineMonth][lineDay] = true;
			result = true;
		}
	}
	return result;
}

C_task main(int argc, char *argv[])
{
	int x, y, year, half;
	char key;
	os_initstdio();
	CLS();

	// readParamFromIni();

	BOX(1, 1, 80, 25, 44, 32);
	AT(1, 1);
	ATRIB(97);

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

loop:
	clearStatus();

	if (ini.useProdCalendar)
	{

		if (loadProdCalDisk(year) == false)
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
	AT(38, 2);
	ATRIB(93);
	ATRIB(44);
	printf("[%d]", year);
	if (ini.useProdCalendar == false)
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

	case 'h': // Up
	case 'H': // Up
		ini.useProdCalendar = !ini.useProdCalendar;
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
