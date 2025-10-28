#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <socket.h>
#include <intrz80.h>
#include <osfs.h>
#include <stdlib.h>
////////
#define true 1
#define false 0

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
unsigned int magic = 15;
unsigned long factor, timerok, count = 0;
const unsigned char sendOk[] = "SEND OK";
const unsigned char gotWiFi[] = "WIFI GOT IP";
const unsigned char timeUpdated[] = "+CIPSNTPTIME:";
int GMT = 3;
unsigned char is_atm;
unsigned char netbuf[4096];
unsigned char cmd[512];
unsigned char curPath[128];

struct sockaddr_in ntp_ia;
union
{
	unsigned long ul;
	unsigned char b[4];
} secsUnix;
unsigned int hour, minute, second, day, month, year, weekday;
SOCKET s = 0;
unsigned char inet = 0, espInet = 0;
const unsigned char monthDays[12] =
	{31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
const unsigned char ntpnead[48] =
	{
		0xdb,
		0x00,
		0x11,
		0xfa,
		0x00,
		0x00,
		0x00,
		0x00,
		0x00,
		0x01,
		0x03,
		0xfe,
};
unsigned char *defntp = "2.ru.pool.ntp.org";
const unsigned char regaddr_ve[16] = {0x10, 0, 0x50, 0, 0x90, 0, 0, 0x12, 0x52, 0x92, 0, 0, 0, 0, 0, 0};

const unsigned char help[] = "\
-H help\r\n\
-T set time(-T17:59:38)\r\n\
-D set date(-D21-06-2019)\r\n\
-N ntp-server default: -N2.ru.pool.ntp.org\r\n\
-Z time-zone default: -Z3\r\n\
-i get datetime from internet\r\n\
-e get datetime from ESP-COM";

extern void
dns_resolve(void);

void clearStatus(void)
{
}

void delay(unsigned long counter)
{
	unsigned long finish;
	counter = counter / 20;
	if (counter < 1)
	{
		counter = 1;
	}
	finish = time() + counter;

	while (time() < finish)
	{
	}
}

void exit(int e)
{
	if (s)
		closesocket(s, 0);
	if (e != 0)
	{
		puts((char *)e);
	}
	((void (*)(int))0x0000)(e);
}

extern void dns_resolve(void);

unsigned char readcmos(unsigned char r)
{
	disable_interrupt();
	if (is_atm == 2 || is_atm == 3)
	{
		r = regaddr_ve[r];
		if (r != 0)
		{
			input(0x55FE);
			r = input((r << 8) | 0x00fe);
		}
	}
	else
	{
		output(0xdef7, r);
		r = input(0xbef7);
	}
	enable_interrupt();
	return r;
}

void writecmos(unsigned char r, unsigned char v)
{
	disable_interrupt();
	if (is_atm == 2 || is_atm == 3)
	{
		r = regaddr_ve[r] + 1; // На запись порт + 1
		if (r != 0)
		{
			input(0x55FE);
			input((r << 8) | 0x00fe);
			input((v << 8) | 0x00fe);
		}
	}
	else
	{
		output(0xdef7, r);
		output(0xbef7, v);
	}
	enable_interrupt();
}

void Unix_to_GMT(void)
{
	unsigned char monthLength = 0;
	// корректировка часового пояса и синхронизация
	int days = 0;
	secsUnix.ul = secsUnix.ul + GMT * 3600;

	second = secsUnix.ul % 60;
	secsUnix.ul /= 60; // now it is minutes
	minute = secsUnix.ul % 60;
	secsUnix.ul /= 60; // now it is hours
	hour = secsUnix.ul % 24;
	secsUnix.ul /= 24;				 // now it is days
	weekday = (secsUnix.ul + 4) % 7; // day week, 0-sunday
	year = 70;
	while (days + ((year % 4) ? 365 : 366) <= secsUnix.ul)
	{
		days += (year % 4) ? 365 : 366;
		year++;
	}
	secsUnix.ul -= days; // now it is days in this year, starting at 0

	days = 0;
	month = 0;
	for (month = 0; month < 12; month++)
	{
		if (month == 1)
		{ // february
			if (year % 4)
				monthLength = 28;
			else
				monthLength = 29;
		}
		else
			monthLength = monthDays[month];
		if (secsUnix.ul >= monthLength)
			secsUnix.ul -= monthLength;
		else
			break;
	}
	month++;			   // jan is month 1
	day = secsUnix.ul + 1; // day of month
}
void ntp_resolver(void)
{
	unsigned char i, j;
	signed char res;
	int len;
	ntp_ia.sin_port = 123 << 8;
	ntp_ia.sin_addr = *dns_resolver((void *)defntp);
	if (!ntp_ia.sin_addr.S_un.S_addr)
		exit((int)"error: domain name not resolved");
	i = 200;
inetloop:
	YIELD();
	i--;
	YIELD();
	if (i == 0)
	{
		exit((int)"inet error");
	}
	s = socket(AF_INET, SOCK_DGRAM, 0);
	if (s < 0)
	{
		s = 0;
		goto inetloop;
	}
	memcpy(netbuf, ntpnead, sizeof(ntpnead));

	len = sendto(s, netbuf, 48, 0, &ntp_ia, sizeof(ntp_ia));
	if (res < 0)
	{
		closesocket(s, 0);
		s = 0;
		goto inetloop;
	}
	j = 50;
	while (j)
	{
		j--;
		len = recvfrom(s, netbuf, sizeof(netbuf), 0, &ntp_ia, sizeof(ntp_ia));
		if (len < 0)
		{
			YIELD();
			YIELD();
			continue;
		}
		break;
	}

	closesocket(s, 0);
	s = 0;
	if (len <= 0)
	{
		exit((int)"server error");
	}
	secsUnix.b[3] = netbuf[40];
	secsUnix.b[2] = netbuf[41];
	secsUnix.b[1] = netbuf[42];
	secsUnix.b[0] = netbuf[43];
	secsUnix.ul -= 2208988800UL;
	Unix_to_GMT();
}

///////////////////////////
#include <../common/esp-com.c>
//////////////////////////

void espntp_resolver(void)
{
	unsigned char retry, retryuart, count = 0;
	unsigned long finish;
	unsigned char *count1;
	loadEspConfig();
	uart_init(divider);
	if (!espReBoot())
	{
		puts("\r\nerror ESP init...");
		exit(255);
	}
	puts("\r\nGetting time...");

	writeLog("Time2 started and inited", "espntp_resolver");

	// AT+CIPSNTPCFG=1,8,"cn.ntp.org.cn","ntp.sjtu.edu.cn"
	weekday = 0;
	month = 0;
	day = 0;
	hour = 0;
	second = 0;
	year = 170;
	retry = 10;
	retryuart = 3;
	sprintf(cmd, "AT+CIPSNTPCFG=1,%u,\"%s\",\"time.google.com\"", GMT, defntp);
	sendcommand(cmd);
	if (!getAnswer3()) // OK
	{
		puts("Timeout waiting 'OK' AT+CIPSNTPCFG");
		writeLog("Timeout waiting 'OK' AT+CIPSNTPCFG", "espntp_resolver");
		exit(255);
	}
	count1 = strstr(netbuf, "ERROR");
	if (count1 != NULL)
	{
		printf("Error. You may need to update your AT-Firmware, to a version that supports AT+CIPSNTPCFG");
		writeLog("ERROR answer to AT+CIPSNTPCFG", "espntp_resolver");
		exit(255);
	}

	delay(250);

	if (espType == 32)
	{
		getAnswer3(); // "+TIME_UPDATED"
	}

retryTime:
	count = 0;
	delay(300);
	finish = time() + (5 * 50);
	sendcommand("AT+CIPSNTPTIME?");

	getAnswer3(); // TIME......

	count1 = strstr(netbuf, "+CIPSNTPTIME:");
	if (count1 == NULL)
	{
		puts("Error. No '+CIPSNTPTIME:' in answer ");
		writeLog("Error. No '+CIPSNTPTIME:' in answer", "espntp_resolver");
		exit(255);
	}

	strncpy(cmd, netbuf + 13, 3);
	cmd[3] = 0;

	if (cmd[0] == 'S' && cmd[1] == 'u')
	{
		weekday = 1;
	}
	else if (cmd[0] == 'M' && cmd[1] == 'o')
	{
		weekday = 2;
	}
	else if (cmd[0] == 'T' && cmd[1] == 'u')
	{
		weekday = 3;
	}
	else if (cmd[0] == 'W' && cmd[1] == 'e')
	{
		weekday = 4;
	}
	else if (cmd[0] == 'T' && cmd[1] == 'h')
	{
		weekday = 5;
	}
	else if (cmd[0] == 'F' && cmd[1] == 'r')
	{
		weekday = 6;
	}
	else if (cmd[0] == 'S' && cmd[1] == 'a')
	{
		weekday = 7;
	}

	strncpy(cmd, netbuf + 4 + 13, 3);
	cmd[3] = 0;

	if (cmd[0] == 'J' && cmd[1] == 'a')
	{
		month = 1;
	}
	else if (cmd[0] == 'F' && cmd[1] == 'e')
	{
		month = 2;
	}
	else if (cmd[0] == 'M' && cmd[2] == 'r')
	{
		month = 3;
	}
	else if (cmd[0] == 'A' && cmd[1] == 'p')
	{
		month = 4;
	}
	else if (cmd[0] == 'M' && cmd[2] == 'y')
	{
		month = 5;
	}
	else if (cmd[0] == 'J' && cmd[2] == 'n')
	{
		month = 6;
	}
	else if (cmd[0] == 'J' && cmd[2] == 'l')
	{
		month = 7;
	}
	else if (cmd[0] == 'A' && cmd[1] == 'u')
	{
		month = 8;
	}
	else if (cmd[0] == 'S' && cmd[1] == 'e')
	{
		month = 9;
	}
	else if (cmd[0] == 'O' && cmd[1] == 'c')
	{
		month = 10;
	}
	else if (cmd[0] == 'N' && cmd[1] == 'o')
	{
		month = 11;
	}
	else if (cmd[0] == 'D' && cmd[1] == 'e')
	{
		month = 12;
	}

	strncpy(cmd, netbuf + 8 + 13, 2);
	cmd[2] = 0;
	day = atoi(cmd);

	strncpy(cmd, netbuf + 11 + 13, 2);
	hour = atoi(cmd);

	strncpy(cmd, netbuf + 14 + 13, 2);
	minute = atoi(cmd);

	strncpy(cmd, netbuf + 17 + 13, 2);
	second = atoi(cmd);

	strncpy(cmd, netbuf + 22 + 13, 2);
	cmd[4] = 0;
	year = atoi(cmd) + 100;

	// printf("day of week:%u Month:%u day:%u hours:%u minutes:%u seconds:%u year:%u\r\n", weekday, month, day, hour, minute, second, year);

	getAnswer3(); // OK

	if (year == 170)
	{
		YIELD();
		if (retry == 0)
		{
			puts("error getting time...");
			exit(255);
		}

		retry--;
		printf("Retry [NTP][%u]\r\n", retry);
		writeLog("Retry [NTP] incorrect year", "espntp_resolver");
		delay(500);
		goto retryTime;
	}
}

void set_datetime(void)
{
	writecmos(0x0b, readcmos(0x0b) | 6);
	writecmos(0x07, day);
	writecmos(0x08, month);
	if (is_atm == 2 || is_atm == 3)
	{
		writecmos(0x09, year - 80);
	}
	else
	{
		writecmos(0x09, year - 100);
	}

	writecmos(0x00, second);
	writecmos(0x02, minute);
	writecmos(0x04, hour);
}
void get_datetime(void)
{
	writecmos(0x0b, readcmos(0x0b) | 6);
	second = readcmos(0x00);
	minute = readcmos(0x02);
	hour = readcmos(0x04);
	weekday = readcmos(0x06) - 1;
	day = readcmos(0x07);
	month = readcmos(0x08);
	if (is_atm == 2 || is_atm == 3)
	{
		year = readcmos(0x09) + 80;
	}
	else
	{
		year = readcmos(0x09) + 100;
	}
}

C_task main(int argc, char *argv[])
{
	unsigned char i = 1;
	os_initstdio();
	printf("[TIME2 Build:%s  %s]\r\n", __DATE__, __TIME__);
	is_atm = (unsigned char)OS_GETCONFIG();

	if (argc == 1)
	{
		get_datetime();
		puts(help);
	}
	while (i != argc)
	{
		char *p = argv[i];
		if (p[0] != '-')
			exit((int)"Wrong parameter. Use -H for help");
		switch (p[1] & 0xdf)
		{
		case 'T':
			get_datetime();
			if (sscanf(p + 2, "%d:%d:%d", &hour, &minute, &second) == 3)
			{
				disable_interrupt();
				set_datetime();
				enable_interrupt();
			}
			break;
		case 'D':
			get_datetime();
			if (sscanf(p + 2, "%d-%d-%d", &day, &month, &year) == 3)
			{
				disable_interrupt();
				year -= 1900;
				set_datetime();
				enable_interrupt();
			}
			break;
		case 'N':
			defntp = p + 2;
			break;
		case 'Z':
			if (sscanf(p + 2, "%d", &GMT) != 1)
			{
				GMT = 3;
			}
			break;
		case 'H':
			exit((int)help);
			break;
		case 'I':
			inet = 1;
			break;
		case 'E':
			espInet = 1;
			break;

		default:
			exit((int)"Wrong parameter. Use -H for help");
		}
		i++;
	}
	if (inet)
	{
		ntp_resolver();
		set_datetime();
		writecmos(0x06, weekday + 1);
	}
	if (espInet)
	{
		espntp_resolver();
		set_datetime();
		writecmos(0x06, weekday + 1);
		uartFlush(500);
	}
	puts("Now time:");
	printf("%02u-%02u-%04u ", day, month, year + 1900);
	printf("%02u:%02u:%02u\r\n", hour, minute, second);
	exit(0);
	return 0;
}
