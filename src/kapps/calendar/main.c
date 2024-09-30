#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <tcp.h>
#include <intrz80.h>
#include <stdlib.h>
#include <../common/terminal.c>

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

void printMonth(int month, int year, char xPos, char yPos)
{
	int y, k, j, count;
	char monthsList[12][10] = {"Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"};
	int mDays[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
	static int t[] = {6, 2, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4};
	int days;
	int current;
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
		ATRIB(90);
		for (k = 0; k < current; k++)
		{
			printf("%3d", k + 1 + mDays[month - 2] - current);
		}
	}
	else
	{
		for (k = 0; k < current; k++)
			printf("   ");
	}

	ATRIB(97);
	for (j = 1; j <= days; j++)
	{
		k++;

		if (k > 5)
		{
			ATRIB(31);
		}

		printf("%3d", j);

		if (k > 6)
		{
			k = 0;
			// printf("\r\n");
			AT(curWin.x + 1, curWin.y++ + 3);
			ATRIB(97);
		}
	}
	ATRIB(90);
	for (count = 1; count < 8 - k; count++)
	{
		printf("%3d", count);
	}
}

C_task main(int argc, char *argv[])
{
	int x, y, year;
	os_initstdio();
	CLS();

	BOX(1, 1, 80, 25, 44, 32);
	AT(1, 1);
	ATRIB(97);
	if (argc == 1)
	{
		AT(37, 2);
		puts("[2024]");
		year = 2024;
	}
	else if (argc == 2)
	{
		char *p = argv[1];
		AT(37, 2);
		sscanf(p, "%d", &year);
		printf("[%d]", year);
	}

	x = 4;
	y = 4;

	printMonth(1, year, x + 00, y);
	printMonth(2, year, x + 25, y);
	printMonth(3, year, x + 50, y);

	printMonth(4, year, x + 00, y + 10);
	printMonth(5, year, x + 25, y + 10);
	printMonth(6, year, x + 50, y + 10);

	ATRIB(40);
	ATRIB(37);
	getchar();

	printMonth(7, year, x + 00, y);
	printMonth(8, year, x + 25, y);
	printMonth(9, year, x + 50, y);

	printMonth(10, year, x + 00, y + 10);
	printMonth(11, year, x + 25, y + 10);
	printMonth(12, year, x + 50, y + 10);
	getchar();
	ATRIB(40);
	ATRIB(37);
	putchar('\r');
	putchar('\n');
	return 0;
}
