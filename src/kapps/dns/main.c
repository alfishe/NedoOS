#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <socket.h>
#include <intrz80.h>
#include <stdlib.h>

unsigned char ipadress[] = "\0\0\0\0\0";
unsigned char *p;
const unsigned char help[] = "View and set system DNS server\r\nUsage: dns.com [ip-adress]\r\n\0";

void errorip(void)
{
	printf("Error parsing IP adress\r\n");
	exit(0);
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

void get_dns(void)
{
	os_getdns(ipadress);
	printf("%d", ipadress[0]);
	printf(".");
	printf("%d", ipadress[1]);
	printf(".");
	printf("%d", ipadress[2]);
	printf(".");
	printf("%d", ipadress[3]);
	printf("\r\n");
}

void setdns(void)
{
	int n = -1, nold, test;
	unsigned char counter, counter2;
	unsigned char coma[] = ".";
	unsigned char buf[16];
	unsigned char p2[255];
	p2[0] = '\0';
	strcat(p2, p);
	strcat(p2, coma);
	for (counter = 0; counter < 4; counter++)
	{
		nold = n;
		n = pos(p2, coma, counter + 1, 0);
		if (n == -1)
		{
			errorip();
		}
		for (counter2 = 0; counter2 < (n - nold - 1); counter2++)
		{
			buf[counter2] = p[counter2 + nold + 1];
		}
		buf[counter2] = '\0';
		test = atoi(buf);
		if (test > 255)
		{
			errorip();
		}
		ipadress[counter] = atoi(buf);
	}
	os_setdns(ipadress);
}

C_task main(int argc, char *argv[])
{
	os_initstdio();

	if (argc == 1)
	{
		puts(help);
		printf("Current DNS-server: ");
		get_dns();
		exit(0);
	}

	if (argc == 2)
	{
		p = argv[1];
		setdns();
		printf("Current DNS-server: ");
		get_dns();
		exit(0);
	}
	errorip();
	//	return 0;
}
