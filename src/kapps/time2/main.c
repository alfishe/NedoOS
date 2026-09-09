#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <stdlib.h>
#include <oscalls.h>
#include <tcp.h>
#include <espnet.h>
#include <osfs.h>

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
unsigned int netDriver = 0;
unsigned long factor, timerok, count = 0;

const unsigned char gotWiFi[] = "WIFI GOT IP";
int GMT = 3;
unsigned char is_atm;
unsigned char netbuf[1024];
unsigned char cmd[512];
unsigned char curPath[128];

struct sockaddr_in targetadr;
struct sockaddr_in dnsaddress;
struct readstructure readStruct;

union
{
	unsigned long ul;
	unsigned char b[4];
} secsUnix;
unsigned int hour, minute, second, day, month, year, weekday;
unsigned char inet = 0, espInet = 0;
const unsigned char monthDays[12] =
	{31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
const unsigned char ntpnead[12] =
	{
		0xdb, 0x00, 0x11, 0xfa,
		0x00, 0x00, 0x00, 0x00,
		0x00, 0x01, 0x03, 0xfe};
unsigned char *defntp = "2.ru.pool.ntp.org";
const unsigned char regaddr_ve[16] = {0x10, 0, 0x50, 0, 0x90, 0, 0, 0x12, 0x52, 0x92, 0, 0, 0, 0, 0, 0};

const unsigned char help[] =
	"-H help\r\n"
	"-T set time(-T17:59:38)\r\n"
	"-D set date(-D21-06-2019)\r\n"
	"-N ntp-server default: -N2.ru.pool.ntp.org\r\n"
	"-Z time-zone default: -Z3\r\n"
	"-i get datetime from internet (ZXNETUSB / ESPNET)\r\n"
	"-e get datetime from ESP (AT-Firmware; ESPNET if currentNetwork=2)";

void clearStatus(void)
{
}

#include <../common/esp-com.c>
#include <../common/network.c>
#define ESPNET_HOST_MAX 128
#define ESPNET_CLIENT_ONLY 1
#define ESPNET_UDP 1
#include <../common/espnet.c>
#include <../common/espnet-net.c>
#include <../common/ini.c>

static void die(char *msg)
{
	puts(msg);
	exit(1);
}

void delay(unsigned long counter)
{
	unsigned long finish;
	counter = counter / 20;
	if (counter < 1)
		counter = 1;
	finish = time() + counter;
	while (time() < finish)
	{
	}
}

static unsigned char read_netdriver(void)
{
	unsigned char val[12];
	unsigned char n;

	n = 0;
	OS_GETPATH(curPath);
	OS_SETSYSDRV();
	OS_CHDIR("/");
	OS_CHDIR("ini");
	if (ini_get_param((unsigned char *)"network.ini",
			  (unsigned char *)"currentNetwork", val, sizeof(val)))
		n = (unsigned char)ini_parse_uint(val);
	OS_CHDIR(curPath);
	return n;
}

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
		r = regaddr_ve[r] + 1;
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
	int days = 0;
	secsUnix.ul = secsUnix.ul + GMT * 3600;

	second = secsUnix.ul % 60;
	secsUnix.ul /= 60;
	minute = secsUnix.ul % 60;
	secsUnix.ul /= 60;
	hour = secsUnix.ul % 24;
	secsUnix.ul /= 24;
	weekday = (secsUnix.ul + 4) % 7;
	year = 70;
	while (days + ((year % 4) ? 365 : 366) <= secsUnix.ul)
	{
		days += (year % 4) ? 365 : 366;
		year++;
	}
	secsUnix.ul -= days;

	days = 0;
	month = 0;
	for (month = 0; month < 12; month++)
	{
		if (month == 1)
		{
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
	month++;
	day = secsUnix.ul + 1;
}

void ntp_resolver(void)
{
	signed char sock;
	unsigned char i, j;
	unsigned int todo;
	int len;

	memset(netbuf, 0, 48);
	memcpy(netbuf, ntpnead, sizeof(ntpnead));

	if (netDriver == 2)
	{
		OS_ESPINIT();
		if (!EspDnsResolve((char *)defntp))
			die("error: domain name not resolved");
	}
	else
	{
		unsigned char dns_try;

		get_dns();
		for (dns_try = 0; dns_try < 4; dns_try++)
		{
			if (dnsResolve((char *)defntp))
				break;
			delay(500);
		}
		if (dns_try >= 4)
			die("error: domain name not resolved");
	}
	/* iarlib sockaddr_in: port is two bytes, network order (123 = 0x007B). */
	targetadr.family = AF_INET;
	targetadr.porth = 0;
	targetadr.portl = 123;

	i = 200;
inetloop:
	YIELD();
	i--;
	YIELD();
	if (i == 0)
		die("inet error");
	if (netDriver == 2)
		sock = EspOpenSock(AF_INET, SOCK_DGRAM);
	else
		sock = OpenSock(AF_INET, SOCK_DGRAM);
	if (sock < 0)
		goto inetloop;

	readStruct.socket = (unsigned char)sock;
	readStruct.BufAdr = (unsigned int)netbuf;
	readStruct.bufsize = 48;
	readStruct.protocol = SOCK_DGRAM;
	if (netDriver == 2)
		todo = OS_ESPWRITE_UDP(&readStruct, &targetadr);
	else
		todo = OS_WIZNETWRITE_UDP(&readStruct, &targetadr);
	if (!OS_CALL_OK(todo))
	{
		if (netDriver == 2)
			EspShutDown(sock, 0);
		else
			netShutDown(sock, 0);
		goto inetloop;
	}
	j = 50;
	len = -1;
	while (j)
	{
		j--;
		readStruct.bufsize = 48;
		if (netDriver == 2)
			todo = OS_ESPREAD_UDP(&readStruct, &targetadr);
		else
			todo = OS_WIZNETREAD_UDP(&readStruct, &targetadr);
		if (!OS_CALL_OK(todo))
		{
			YIELD();
			YIELD();
			continue;
		}
		len = (int)todo;
		break;
	}

	if (netDriver == 2)
		EspShutDown(sock, 0);
	else
		netShutDown(sock, 0);
	if (len <= 0)
		die("server error");
	secsUnix.b[3] = netbuf[40];
	secsUnix.b[2] = netbuf[41];
	secsUnix.b[1] = netbuf[42];
	secsUnix.b[0] = netbuf[43];
	secsUnix.ul -= 2208988800UL;
	Unix_to_GMT();
}

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
	if (!getAnswer3())
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
		if (!getAnswer3())
		{
			puts("Timeout waiting '+TIME_UPDATED' Check espType may be you have 8266.");
			writeLog("Timeout waiting '+TIME_UPDATED'", "espntp_resolver");
		}
	}

retryTime:
	count = 0;
	delay(300);
	finish = time() + (5 * 50);
	sendcommand("AT+CIPSNTPTIME?");

	if (!getAnswer3())
	{
		puts("Timeout waiting answer to AT+CIPSNTPTIME?");
		writeLog("Timeout waiting answer to AT+CIPSNTPTIME?", "espntp_resolver");
		exit(255);
	}

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
		weekday = 1;
	else if (cmd[0] == 'M' && cmd[1] == 'o')
		weekday = 2;
	else if (cmd[0] == 'T' && cmd[1] == 'u')
		weekday = 3;
	else if (cmd[0] == 'W' && cmd[1] == 'e')
		weekday = 4;
	else if (cmd[0] == 'T' && cmd[1] == 'h')
		weekday = 5;
	else if (cmd[0] == 'F' && cmd[1] == 'r')
		weekday = 6;
	else if (cmd[0] == 'S' && cmd[1] == 'a')
		weekday = 7;

	strncpy(cmd, netbuf + 4 + 13, 3);
	cmd[3] = 0;

	if (cmd[0] == 'J' && cmd[1] == 'a')
		month = 1;
	else if (cmd[0] == 'F' && cmd[1] == 'e')
		month = 2;
	else if (cmd[0] == 'M' && cmd[2] == 'r')
		month = 3;
	else if (cmd[0] == 'A' && cmd[1] == 'p')
		month = 4;
	else if (cmd[0] == 'M' && cmd[2] == 'y')
		month = 5;
	else if (cmd[0] == 'J' && cmd[2] == 'n')
		month = 6;
	else if (cmd[0] == 'J' && cmd[2] == 'l')
		month = 7;
	else if (cmd[0] == 'A' && cmd[1] == 'u')
		month = 8;
	else if (cmd[0] == 'S' && cmd[1] == 'e')
		month = 9;
	else if (cmd[0] == 'O' && cmd[1] == 'c')
		month = 10;
	else if (cmd[0] == 'N' && cmd[1] == 'o')
		month = 11;
	else if (cmd[0] == 'D' && cmd[1] == 'e')
		month = 12;

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

	if (!getAnswer3())
	{
		puts("Timeout waiting last OK. Continue");
		writeLog("Timeout waiting last OK. Continue", "espntp_resolver");
	}

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
		writecmos(0x09, year - 80);
	else
		writecmos(0x09, year - 100);

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
		year = readcmos(0x09) + 80;
	else
		year = readcmos(0x09) + 100;
}

static void apply_net_time(void)
{
	set_datetime();
	writecmos(0x06, weekday + 1);
}

C_task main(int argc, char *argv[])
{
	unsigned char i = 1;
	os_initstdio();
	is_atm = (unsigned char)OS_GETCONFIG();
	netDriver = read_netdriver();

	if (argc == 1)
	{
		get_datetime();
		puts(help);
	}

	while (i != argc)
	{
		char *p = argv[i];
		if (p[0] != '-')
			die("Wrong parameter. Use -H for help");
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
			defntp = (unsigned char *)(p + 2);
			break;
		case 'Z':
			if (sscanf(p + 2, "%d", &GMT) != 1)
				GMT = 3;
			break;
		case 'H':
			puts(help);
			exit(0);
			break;
		case 'I':
			inet = 1;
			break;
		case 'E':
			espInet = 1;
			break;
		default:
			die("Wrong parameter. Use -H for help");
		}
		i++;
	}
	if (inet)
	{
		if (netDriver == 1)
			espntp_resolver();
		else
			ntp_resolver();
		apply_net_time();
	}
	if (espInet)
	{
		if (netDriver == 2)
			ntp_resolver();
		else
		{
			espntp_resolver();
			uartFlush(500);
		}
		apply_net_time();
	}
	puts("Now time:");
	printf("%02u-%02u-%04u ", day, month, year + 1900);
	printf("%02u:%02u:%02u\r\n", hour, minute, second);
	exit(0);
	return 0;
}
