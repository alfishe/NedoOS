#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <stdlib.h>
#include <oscalls.h>
#include <terminal.c>
#include <tcp.h>
#include <osfs.h>
#include <intrz80.h>
#include <ctype.h>
#include <math.h>

unsigned int RBR_THR = 0xf8ef;
unsigned int IER = 0xf9ef;
unsigned int IIR_FCR = 0xfaef;
unsigned int LCR = 0xfbef;
unsigned int MCR = 0xfcef;
unsigned int LSR = 0xfdef;
unsigned int MSR = 0xfeef;
unsigned int SR = 0xffef;
unsigned int divider = 1;
unsigned char comType = 0;
unsigned int espType = 32;
unsigned char netDriver = 0;

unsigned char uVer[] = "0.48";
unsigned char curPath[128];
unsigned char curLetter;
unsigned char oldBinExt;
unsigned int errn, headlng;
unsigned long contLen;
unsigned char saveFlag, saveBak;
unsigned char crlf[2] = {13, 10};

unsigned char status, curFormat;
struct sockaddr_in targetadr;
struct readstructure readStruct;
FILE *fp2;

struct window
{
	unsigned char x;
	unsigned char y;
	unsigned char w;
	unsigned char h;
	unsigned char text;
	unsigned char back;
	unsigned char tittle[80];

} cw;

struct configuration
{
	unsigned char kernelName[32];
	unsigned char machineName[32];
	unsigned char kernelLink[256];
	unsigned char is_atm;
} config;

unsigned char netbuf[4096];

unsigned char cmdlist1[] = " HTTP/1.1\r\nHost: nedoos.ru\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)\r\n\r\n\0";
unsigned char binLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/&isdir=1";
unsigned char pkunzipLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/pkunzip.com";
unsigned char tarLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/tar.com";
unsigned char cmdLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/cmd.com";
unsigned char termLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/term.com";
unsigned char updLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/updater.com";
unsigned char newsLink[] = "/svn/dl.php?repname=NedoOS&path=/release/doc/updater.new";
unsigned char wizNetLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/wizcfg.com";
unsigned char netIniLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/net.ini";
unsigned char relLink[] = "http://nedoos.ru/images/release.zip";
unsigned char nameBuf1[256];
unsigned char *nameBuf = nameBuf1;
//unsigned char *nameBuf = "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
const unsigned char sendOk[] = "SEND OK";
const unsigned char gotWiFi[] = "WIFI GOT IP";
unsigned char cmd[256];
unsigned char link[512];
unsigned char dataBuffer[4096];

void clearStatus(void)
{
	AT(1, 24);
	printf("                                                                                \r");
}

void printTable(void)
{
	unsigned int cycle;

	for (cycle = 32; cycle < 256; cycle++)
	{
		printf("%03u:", cycle);
		putchar(cycle);
		printf(" ");
		if (cycle % 10 == 0)
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

void printNews(void) // max 20 lines in total and 59 col.
{
	FILE *fpNews;
	unsigned char str[1];
	unsigned char curLine, nbyte;

	fpNews = OS_OPENHANDLE("updater.new", 0x80);
	if (((int)fpNews) & 0xff)
	{

#include <printnews.c>

		return;
	}
	curLine = 0;
	while (curLine < 20)
	{
		AT(20, 3 + curLine);
		while (1)
		{
			OS_READHANDLE(str, fpNews, sizeof(str));

			if (errno != 0)
			{
				OS_CLOSEHANDLE(fpNews);
				return;
			}

			nbyte = str[0];

			if (nbyte != 13)
			{
				putchar(nbyte);
			}
			else
			{
				break;
			}
		}
		OS_READHANDLE(str, fpNews, sizeof(str));
		curLine++;
	}
	OS_CLOSEHANDLE(fpNews);
}

void drawWindow(struct window w)
{
	unsigned char wcount, tempx, tittleStart;

	AT(w.x, w.y - 1);
	tittleStart = w.x + (w.w / 2) - (strlen(w.tittle) / 2) + 1;
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

	AT(w.x, w.y + 2);
	putchar(199);
	for (wcount = 0; wcount < w.w; wcount++)
	{
		putchar(196);
	}
	putchar(182);

	AT(tittleStart, w.y + 1);
	printf("%s", w.tittle);
}

void fatalError(unsigned char *message)
{
	strcpy(cw.tittle, "FATAL ERROR!");

	if (strlen(message) > strlen(cw.tittle))
	{
		cw.w = strlen(message) + 2;
	}
	else
		cw.w = strlen(cw.tittle) + 2;
	cw.x = 80 / 2 - cw.w / 2;
	cw.y = 11;
	cw.h = 4;
	cw.text = 97;
	cw.back = 41;
	drawWindow(cw);
	AT(cw.x + 2, cw.y + 3);
	printf("%s", message);
	AT(1, 1);
	getchar();
	exit(0);
}

void infoBox(unsigned char *message)
{
	strcpy(cw.tittle, "nedoOS system updater ");
	strcat(cw.tittle, uVer);

	if (strlen(message) > strlen(cw.tittle))
	{
		cw.w = strlen(message) + 2;
	}
	else
		cw.w = strlen(cw.tittle) + 2;
	cw.x = 80 / 2 - cw.w / 2;
	cw.y = 15;
	cw.h = 4;
	cw.text = 97;
	cw.back = 42;

	drawWindow(cw);
	AT(cw.x + 2, cw.y + 3);
	printf("%s", message);
	AT(1, 1);
}

unsigned char OS_SHELL(unsigned char *command)
{
	unsigned char fileName[] = "bin/cmd.com";
	unsigned char appCmd[128] = "cmd.com ";
	unsigned int shellSize, loaded, loop, adr;
	unsigned char pgbak;
	union APP_PAGES shell_pg;
	union APP_PAGES main_pg;
	FILE *fp3;
	main_pg.l = OS_GETMAINPAGES();
	pgbak = main_pg.pgs.window_3;
	OS_GETPATH((unsigned int)&curPath);
	strcat(appCmd, command);
	fp3 = OS_OPENHANDLE(fileName, 0x80);
	if (((int)fp3) & 0xff)
	{
		clearStatus();
		AT(1, 24);
		printf("%s", fileName);
		printf(" not found.");
		getchar();
		exit(0);
	}
	shellSize = OS_GETFILESIZE(fp3);

	OS_NEWAPP((unsigned int)&shell_pg);

	shell_pg.l = OS_GETAPPMAINPAGES(shell_pg.pgs.pId);

	SETPG32KHIGH(shell_pg.pgs.window_0);

	memcpy((unsigned char *)(0xC080), (unsigned char *)(&appCmd), strlen(appCmd) + 1);

	loop = 0;
	while (loop < shellSize)
	{
		loaded = OS_READHANDLE(netbuf, fp3, sizeof(netbuf));
		adr = 0xC100 + loop;
		memcpy((unsigned char *)(adr), &netbuf, loaded);
		loop = loop + loaded;
	}
	OS_CLOSEHANDLE(fp3);
	SETPG32KHIGH(pgbak);
	clearStatus();
	AT(1, 24);
	printf("Shell [pId:%u][%s][%s]", shell_pg.pgs.pId, curPath, appCmd);
	AT(1, 24);
	delay(300);
	OS_RUNAPP(shell_pg.pgs.pId);
	AT(1, 4);
	OS_WAITPID(shell_pg.pgs.pId);
	return shell_pg.pgs.pId;
}

////////////////////////ESP32 PROCEDURES//////////////////////
void uart_write(unsigned char data)
{
	unsigned char status;
	switch (comType)
	{
	case 0:
	case 2:
		while ((input(LSR) & 64) == 0)
		{
		}
		output(RBR_THR, data);
		break;
	case 1:
		disable_interrupt();
		do
		{
			input(0x55fe);			// Переход в режим команд
			status = input(0x42fe); // Команда прочесть статус
		} while ((status & 64) == 0); // Проверяем 6 бит

		input(0x55fe);				 // Переход в режим команд
		input(0x03fe);				 // Команда записать в порт
		input((data << 8) | 0x00fe); // Записываем data в порт
		enable_interrupt();
		break;
	}
}

void uart_setrts(unsigned char mode)
{
	switch (comType)
	{
	case 0:
		switch (mode)
		{
		case 1:
			output(MCR, 2);
			break;
		case 0:
			output(MCR, 0);
			break;
		default:
			disable_interrupt();
			output(MCR, 2);
			output(MCR, 0);
			enable_interrupt();
			break;
		}
	case 1:
		switch (mode)
		{
		case 1:
			disable_interrupt();
			input(0x55fe); // Переход в режим команд
			input(0x43fe); // Команда установить статус
			input(0x03fe); // Устанавливаем готовность DTR и RTS
			enable_interrupt();
			break;
		case 0:
			disable_interrupt();
			input(0x55fe); // Переход в режим команд
			input(0x43fe); // Команда установить статус
			input(0x00fe); // Снимаем готовность DTR и RTS
			enable_interrupt();
			break;
		default:
			disable_interrupt();
			input(0x55fe); // Переход в режим команд
			input(0x43fe); // Команда установить статус
			input(0x03fe); // Устанавливаем готовность DTR и RTS
			input(0x55fe); // Переход в режим команд
			input(0x43fe); // Команда установить статус
			input(0x00fe); // Снимаем готовность DTR и RTS
			enable_interrupt();
			break;
		}
	case 2:
		break;
	}
}

void uart_init(unsigned char divisor)
{
	switch (comType)
	{
	case 0:
	case 2:
		output(MCR, 0x00);		  // Disable input
		output(IIR_FCR, 0x87);	  // Enable fifo 8 level, and clear it
		output(LCR, 0x83);		  // 8n1, DLAB=1
		output(RBR_THR, divisor); // 115200 (divider 1-115200, 3 - 38400)
		output(IER, 0x00);		  // (divider 0). Divider is 16 bit, so we get (#0002 divider)
		output(LCR, 0x03);		  // 8n1, DLAB=0
		output(IER, 0x00);		  // Disable int
		output(MCR, 0x2f);		  // Enable AFE
		break;
	case 1:
		disable_interrupt();
		input(0x55fe);
		input(0xc3fe);
		input((divisor << 8) | 0x00fe);
		enable_interrupt();
		break;
	}
}

unsigned char uart_hasByte(void)
{
	unsigned char queue;
	switch (comType)
	{
	case 0:
	case 2:
		return (1 & input(LSR));
	case 1:
		disable_interrupt();
		input(0x55fe);		   // Переход в режим команд
		queue = input(0xc2fe); // Получаем количество байт в приемном буфере
		enable_interrupt();
		return queue;
	}
	return 255;
}

unsigned char uart_read(void)
{
	unsigned char data;
	switch (comType)
	{
	case 0:
	case 2:
		return input(RBR_THR);
	case 1:
		disable_interrupt();
		input(0x55fe);		  // Переход в режим команд
		data = input(0x02fe); // Команда прочесть из порта
		enable_interrupt();
		return data;
	}
	return 255;
}

unsigned char uart_readBlock(void)
{
	unsigned char data;
	switch (comType)
	{
	case 0:
		while (uart_hasByte() == 0)
		{
			uart_setrts(2);
		}
		return input(RBR_THR);
	case 1:
		while (uart_hasByte() == 0)
		{
			uart_setrts(2);
		}
		disable_interrupt();
		input(0x55fe);		  // Переход в режим команд
		data = input(0x02fe); // Команда прочесть из порта
		enable_interrupt();
		return data;
	case 2:
		while (uart_hasByte() == 0)
		{
		}
		return input(RBR_THR);
	}
	return 255;
}

void uart_flush(void)
{
	unsigned int count;
	for (count = 0; count < 6000; count++)
	{
		uart_setrts(1);
		uart_read();
	}
}

void getdataEsp(unsigned int counted)
{
	unsigned int counter;
	for (counter = 0; counter < counted; counter++)
	{
		netbuf[counter] = uart_readBlock();
	}
	netbuf[counter] = 0;
}

void sendcommand(char *commandline)
{
	unsigned int count, cmdLen;
	cmdLen = strlen(commandline);
	for (count = 0; count < cmdLen; count++)
	{
		uart_write(commandline[count]);
	}
	uart_write('\r');
	uart_write('\n');
	// printf("Sended:[%s] \r\n", commandline);
}

unsigned char getAnswer2(void)
{
	unsigned char readbyte;
	unsigned int curPos = 0;
	do
	{
		readbyte = uart_readBlock();
		// putdec(readbyte);
	} while (((readbyte == 0x0a) || (readbyte == 0x0d)));

	netbuf[curPos] = readbyte;
	curPos++;
	do
	{
		readbyte = uart_readBlock();
		netbuf[curPos] = readbyte;
		curPos++;
	} while (readbyte != 0x0d);
	netbuf[curPos - 1] = 0;
	uart_readBlock(); // 0xa
	// printf("Answer:[%s]\r\n", netbuf);
	//    getchar();
	return curPos;
}

void espReBoot(void)
{
	unsigned char byte, count;
	uart_flush();
	sendcommand("AT+RST");
	printf("Resetting ESP...");
	do
	{
		byte = uart_readBlock();
		if (byte == gotWiFi[count])
		{
			count++;
		}
		else
		{
			count = 0;
		}
	} while (count < strlen(gotWiFi));
	uart_readBlock(); // CR
	uart_readBlock(); // LF
	printf("Reset complete.");

	sendcommand("ATE0");
	do
	{
		byte = uart_readBlock();
	} while (byte != 'K'); // OK
	// puts("ATE0 Answer:[OK]");
	uart_readBlock(); // CR
	uart_readBlock(); // LN

	sendcommand("AT+CIPCLOSE");
	getAnswer2();
	sendcommand("AT+CIPDINFO=0");
	getAnswer2();
	sendcommand("AT+CIPMUX=0");
	getAnswer2();
	sendcommand("AT+CIPSERVER=0");
	getAnswer2();
	sendcommand("AT+CIPRECVMODE=0");
	getAnswer2();
}

unsigned int recvHead(void)
{
	unsigned char byte, dataRead = 0;
	unsigned int loaded;
	do
	{
		byte = uart_readBlock();
	} while (byte != ',');

	dataRead = 0;
	do
	{
		byte = uart_readBlock();
		netbuf[dataRead] = byte;
		dataRead++;
	} while (byte != ':');
	netbuf[dataRead] = 0;
	loaded = atoi(netbuf); // <actual_len>
	// printf("\r\n loaded %u\r\n", loaded);
	return loaded;
}

void loadEspConfig(void)
{
	unsigned char curParam[256];
	unsigned char res;
	FILE *espcom;
	OS_SETSYSDRV();
	OS_CHDIR("browser");
	espcom = OS_OPENHANDLE("espcom.ini", 0x80);
	if (((int)espcom) & 0xff)
	{
		clearStatus();
		printf("mrfesp.ini opening error");
		return;
	}

	OS_READHANDLE(curParam, espcom, 256);

	res = sscanf(curParam, "%x %x %x %x %x %x %x %x %u %u %u", &RBR_THR, &IER, &IIR_FCR, &LCR, &MCR, &LSR, &MSR, &SR, &divider, &comType, &espType);
	puts("Config loaded:");
	if (comType == 1)
	{
		puts("     Controller base port: 0x55fe");
	}
	else
	{
		printf("     RBR_THR:0x%4x     IER    :0x%4x\r\n     IIR_FCR:0x%4x     LCR    :0x%4x\r\n", RBR_THR, IER, IIR_FCR, LCR);
		printf("     MCR    :0x%4x     LSR    :0x%4x\r\n     MSR    :0x%4x     SR     :0x%4x\r\n", MCR, LSR, MSR, SR);
	}
	printf("     DIV    :%u    TYPE    :%u    ESP    :%u ", divider, comType, espType);
	switch (comType)
	{
	case 0:
		puts("(16550 like w/o AFC)");
		break;
	case 1:
		puts("(ATM Turbo 2+)");
		break;
	case 2:
		puts("(16550 with AFC)");
	default:
		puts("(Unknown type)");
		break;
	}
}

////////////////////////ESP32 PROCEDURES//////////////////////

//////////////// NETWORK PART //////////////////////
void errorPrint(unsigned int error)
{
	clearStatus();
	switch (error)
	{
	case 2:
		printf("02 SHUT_RDWR");
		break;
	case 4:
		printf("04 ERR_INTR");
		break;
	case 23:
		printf("23 ERR_NFILE");
		break;
	case 35:
		printf("35 ERR_EAGAIN");
		break;
	case 37:
		printf("37 ERR_ALREADY");
		break;
	case 38:
		printf("38 ERR_NOTSOCK");
		break;
	case 40:
		printf("40 ERR_EMSGSIZE");
		break;
	case 41:
		printf("41 ERR_PROTOTYPE");
		break;
	case 47:
		printf("47 ERR_AFNOSUPPORT");
		break;
	case 53:
		printf("53 ERR_ECONNABORTED");
		break;
	case 54:
		printf("54 ERR_CONNRESET");
		break;
	case 57:
		printf("57 ERR_NOTCONN");
		break;
	case 65:
		printf("65 ERR_HOSTUNREACH");
		break;
	default:
		printf("[%u] UNKNOWN ERROR", error);
		break;
	}
	do
	{
		YIELD();
	} while (_low_level_get() == 0);
}

unsigned int httpError(void)
{
	unsigned char *httpRes;
	unsigned int httpErr;
	httpRes = strstr(netbuf, "HTTP/1.1 ");

	if (httpRes != NULL)
	{
		httpErr = atol(httpRes + 9);
	}
	else
	{
		httpErr = 0;
	}
	return httpErr;
}

unsigned char OpenSock(unsigned char family, unsigned char protocol)
{
	unsigned char socket;
	unsigned int todo;
	todo = OS_NETSOCKET((family << 8) + protocol);
	if (todo > 32767)
	{
		clearStatus();
		AT(1, 24);
		printf("OS_NETSOCKET: ");
		errorPrint(todo & 255);
		exit(0);
	}
	else
	{
		socket = ((todo & 65280) >> 8);
	}
	return socket;
}

signed char netShutDown(signed char socket, unsigned char type)
{
	unsigned int todo;
	todo = OS_NETSHUTDOWN(socket, type);
	if (todo > 32767)
	{
		clearStatus();
		printf("OS_NETSHUTDOWN: [ERROR:");
		errorPrint(todo & 255);
		printf("] Press any key.");
		return -1;
	}
	else
	{
		// printf("Socket #%d closed.\n\r", socket);
	}
	return 1;
}

unsigned char netConnect(unsigned char socket)
{
	unsigned int todo;
	unsigned char retry = 10;

	targetadr.family = AF_INET;
	targetadr.porth = 00;
	targetadr.portl = 80;
	targetadr.b1 = 31;
	targetadr.b2 = 31;
	targetadr.b3 = 65;
	targetadr.b4 = 35;

	while (retry > 0)
	{
		todo = OS_NETCONNECT(socket, &targetadr);

		if (todo > 32767)
		{
			retry--;
			clearStatus();
			printf("OS_NETCONNECT [ERROR:");
			errorPrint(todo & 255);
			printf("] [Retry:%u]", retry);
			YIELD();
			netShutDown(socket, 0);
			socket = OpenSock(AF_INET, SOCK_STREAM);
		}
		else
		{
			// printf("OS_NETCONNECT: connection successful, %u\n\r", (todo & 255));
			return 1;
		}
	}
	getchar();
	exit(0);
	return 0;
}

unsigned char saveBuf(unsigned char *fileNamePtr, unsigned char operation, unsigned int sizeOfBuf)
{
	if (operation == 00)
	{
		fp2 = OS_CREATEHANDLE(fileNamePtr, 0x80);
		if (((int)fp2) & 0xff)
		{
			clearStatus();
			AT(1, 24);
			printf("%s", fileNamePtr);
			printf(" creating error.");
			exit(0);
		}
		OS_CLOSEHANDLE(fp2);

		fp2 = OS_OPENHANDLE(fileNamePtr, 0x80);
		if (((int)fp2) & 0xff)
		{
			clearStatus();
			AT(1, 24);
			printf("%s", fileNamePtr);
			printf(" opening error. ");

			exit(0);
		}
		AT(1, 24);
		return 0;
	}

	if (operation == 01)
	{
		OS_WRITEHANDLE(netbuf + headlng, fp2, sizeOfBuf);
		return 0;
	}

	if (operation == 02)
	{
		OS_CLOSEHANDLE(fp2);
		return 0;
	}
	return 0;
}

unsigned int tcpRead(unsigned char socket)
{
	unsigned char retry = 20;
	unsigned int todo;
	readStruct.socket = socket;
	readStruct.BufAdr = (unsigned int)&netbuf;
	readStruct.bufsize = sizeof(netbuf);
	readStruct.protocol = SOCK_STREAM;

	while (retry > 0)
	{
		todo = OS_WIZNETREAD(&readStruct);

		if (todo > 32767)
		{
			if ((todo & 255) != ERR_EAGAIN)
			{
				clearStatus();
				printf("OS_WIZNETREAD: [ERROR:");
				errorPrint(todo & 255);
				printf("] [Retry:%u]", retry);
				YIELD();
				retry--;
			}
		}
		else
		{
			// printf("OS_WIZNETREAD: %u bytes read. \n\r", todo);
			return todo;
		}
	}
	getchar();
	exit(0);
	return todo;
}

unsigned int cutHeader(unsigned int todo)
{
	unsigned int err;
	unsigned char *count1;

	err = httpError();
	if (err != 200)
	{
		BOX(1, 1, 80, 25, 40, 32);
		AT(1, 1);
		printf("HTTP ERROR %u", err);
		puts("^^^^^^^^^^^^^^^^^^^^^");
		puts(netbuf);
		getchar();
		fatalError("Server response error!");
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

unsigned int tcpSend(unsigned char socket, unsigned int messageadr, unsigned int size)
{
	unsigned char retry = 20;
	unsigned int todo;
	readStruct.socket = socket;
	readStruct.BufAdr = messageadr;
	readStruct.bufsize = size;
	readStruct.protocol = SOCK_STREAM;

wizwrite:
	todo = OS_WIZNETWRITE(&readStruct);
	if (todo > 32767)
	{
		clearStatus();
		AT(1, 24);
		printf("OS_WIZNETWRITE: ");
		errorPrint(todo & 255);
		if (retry == 0)
		{
			exit(0);
		}
		retry--;
		if (_low_level_get() == 27)
		{
			fatalError("File download aborted!");
		}
		delay(100);
		goto wizwrite;
	}

	return todo;
}
unsigned char getFile(unsigned char *fileLink, unsigned char *fileNamePtr)
{
	unsigned int todo;
	unsigned char socket;
	unsigned int skipHeader = 0;
	unsigned int fileSize1;
	unsigned long downloaded = 0;

	unsigned char sizeLink;
	unsigned char byte, count = 0, try = 0;
	unsigned char *count1;

	strcpy(netbuf, "GET ");
	strcat(netbuf, fileLink);
	strcat(netbuf, cmdlist1);
	clearStatus();
	AT(1, 24);
	printf("%s", fileNamePtr);

	if (netDriver == 0)
	{
		socket = OpenSock(AF_INET, SOCK_STREAM);
		todo = netConnect(socket);
		todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf));
		do
		{
			headlng = 0;
			todo = tcpRead(socket);
			if (todo == 0)
			{
				break;
			}
			if (skipHeader == 0)
			{
				skipHeader = 1;
				todo = cutHeader(todo);
				fileSize1 = contLen / 1024;
				saveBuf(fileNamePtr, 00, 0);
			}
			downloaded = downloaded + todo;
			AT(32, 24);
			printf("%lu of %u kb  ", downloaded / 1024, fileSize1);

			saveBuf(fileNamePtr, 01, todo);
			if (_low_level_get() == 27)
			{
				fatalError("File download aborted!");
			}
		} while (downloaded < contLen);

		netShutDown(socket, 0);
		saveBuf(fileNamePtr, 02, 00);

		if (downloaded != contLen)
		{
			fatalError("File download error!");
		}
	}
	if (netDriver == 1)
	{
		strcpy(link, netbuf);
		sizeLink = strlen(link);
		try = 0;
		do
		{
			try++;
			if (try > 1)
			{
				clearStatus();
				printf("----->Retry:%u", try);
				delay(500);
			}
			sendcommand("AT+CIPSTART=\"TCP\",\"nedoos.ru\",80");
			getAnswer2(); // CONNECT or ERROR or link is not valid
			count1 = strstr(netbuf, "CONNECT");
		} while (count1 == NULL);

		getAnswer2(); // OK

		strcpy(cmd, "AT+CIPSEND=");
		sprintf(netbuf, "%u", sizeLink + 2); // second CRLF in send command
		strcat(cmd, netbuf);
		sendcommand(cmd);
		getAnswer2();

		do
		{
			byte = uart_readBlock();
			// putchar(byte);
		} while (byte != '>');
		sendcommand(link);
		count = 0;

		do
		{
			byte = uart_readBlock();
			if (byte == sendOk[count])
			{
				count++;
			}
			else
			{
				count = 0;
			}
		} while (count < strlen(sendOk));
		uart_readBlock(); // CR
		uart_readBlock(); // LF

		do
		{
			headlng = 0;
			todo = recvHead();
			getdataEsp(todo); // Requested size
			if (skipHeader == 0)
			{
				skipHeader = 1;
				todo = cutHeader(todo);
				fileSize1 = contLen / 1024;
				saveBuf(fileNamePtr, 00, 0);
			}
			downloaded = downloaded + todo;
			AT(32, 24);
			printf("%lu of %u kb   ", downloaded / 1024, fileSize1);

			saveBuf(fileNamePtr, 01, todo);

			if (_low_level_get() == 27)
			{
				fatalError("File download aborted!");
			}
		} while (downloaded < contLen);
		saveBuf(fileNamePtr, 02, 00);
		sendcommand("AT+CIPCLOSE");
		getAnswer2(); // CLOSED
		getAnswer2(); // OK
	}

	return 0;
}
////////////////////////////////////////////////////
/*
unsigned char getTrack2(unsigned long fileId)
{
	unsigned int todo;
	unsigned char socket;
	unsigned int skipHeader = 0;
	unsigned long bytecount;
	unsigned int packSize = 2000;
	unsigned char sizeLink;
	unsigned long toDownload, downloaded;
	unsigned char try = 0, byte = 0;
	unsigned int todo, count;
	unsigned char *count1;
	clearStatus();
	printf("Getting track...");

	if (netDriver == 0)
	{
		strcpy(netbuf, cmdlist1);
		sprintf(buffer, "%lu", fileId);
		strcat(netbuf, buffer);
		strcat(netbuf, userAgent);

		socket = OpenSock(AF_INET, SOCK_STREAM);
		todo = netConnect(socket);
		todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf));
		saveBuf(curFileStruct.picId, 00, 0);
		do
		{
			todo = tcpRead(socket);
			if (todo == 0)
			{
				break;
			}
			if (skipHeader == 0)
			{
				skipHeader = 1;
				todo = cutHeader(todo);
				bytecount = contLen;
			}
			saveBuf(curFileStruct.picId, 01, todo);
			bytecount = bytecount - todo;
		} while (bytecount != 0);
		netShutDown(socket, 0);
	}
	else
	{
		sprintf(buffer, "%lu", fileId);
		strcpy(netbuf, cmdlist1);
		strcat(netbuf, buffer);
		strcat(netbuf, userAgent);
		saveBuf(curFileStruct.picId, 00, 0);

		strcpy(link, netbuf);
		sizeLink = strlen(link);
		try = 0;
		do
		{
			try++;
			if (try > 1)
			{
				clearStatus();
				printf("----->Retry:%u", try);
				delay(500);
			}
			sendcommand("AT+CIPSTART=\"TCP\",\"zxart.ee\",80");
			getAnswer2(); // CONNECT or ERROR or link is not valid
			count1 = strstr(netbuf, "CONNECT");
		} while (count1 == NULL);

		getAnswer2(); // OK

		strcpy(netbuf, cmdlist1);
		sprintf(buffer, "%lu", fileId);
		strcat(netbuf, buffer);
		strcat(netbuf, userAgent);
		strcpy(cmd, "AT+CIPSEND=");
		sprintf(netbuf, "%u", sizeLink + 2); // second CRLF in send command
		strcat(cmd, netbuf);
		sendcommand(cmd);
		getAnswer2();

		do
		{
			byte = uart_readBlock();
			// putchar(byte);
		} while (byte != '>');
		sendcommand(link);
		count = 0;

		do
		{
			byte = uart_readBlock();
			if (byte == sendOk[count])
			{
				count++;
			}
			else
			{
				count = 0;
			}
		} while (count < strlen(sendOk));
		uart_readBlock(); // CR
		uart_readBlock(); // LF
		skipHeader = 0;
		downloaded = 0;

		do
		{
			headlng = 0;
			todo = recvHead();
			getdataEsp(todo); // Requested size
			if (skipHeader == 0)
			{
				todo = cutHeader(todo);
				toDownload = contLen;
				skipHeader = 1;
			}
			downloaded = downloaded + todo;
			saveBuf(curFileStruct.picId, 01, todo);
			toDownload = toDownload - todo;
		} while (toDownload > 0);
		sendcommand("AT+CIPCLOSE");
		getAnswer2(); // CLOSED
		getAnswer2(); // OK
	}
	return 0;
}
*/
unsigned char getConfig(void)
{
	config.is_atm = (unsigned char)OS_GETCONFIG();
	// H=system drive, L= 1-Evo 2-ATM2 3-ATM3 6-p2.666 ;E=pgsys(system page) D= TR-DOS page
	switch ((config.is_atm))
	{
	case 1:
		strcpy(config.machineName, "ZX-Evolution");
		strcpy(config.kernelName, "sd_boot.$C");
		strcpy(config.kernelLink, "/svn/dl.php?repname=NedoOS&path=/release/sd_boot.%24C");
		break;
	case 2:
		strcpy(config.machineName, "TURBO 2+");
		strcpy(config.kernelName, "osatm2hd.$C");
		strcpy(config.kernelLink, "/svn/dl.php?repname=NedoOS&path=/release/osatm2hd.%24C");

		break;

	case 3: // SD HDD versions
		strcpy(config.machineName, "TURBO 3 [SD]");
		strcpy(config.kernelName, "osatm3hd.$C");
		strcpy(config.kernelLink, "/svn/dl.php?repname=NedoOS&path=/release/osatm3hd.%24C");
		break;
	case 6: // SD HDD versions
		strcpy(config.machineName, "P2.666 [SD]");
		strcpy(config.kernelName, "osp26sd.$C");
		strcpy(config.kernelLink, "/svn/dl.php?repname=NedoOS&path=/release/osp26sd.%24C");
		break;

	default:
		strcpy(config.machineName, "NOT DETECED (ZX-Evo)");
		strcpy(config.kernelName, "sd_boot.$C");
		strcpy(config.kernelLink, "/svn/dl.php?repname=NedoOS&path=/release/sd_boot.s%24C");
		break;
	}
	return config.is_atm;
}
// Downloading minimal tools for updating/boot
void getTools(void)
{
	OS_MKDIR("bin"); // Create if not exist
	ATRIB(cw.text);
	ATRIB(cw.back);
	getFile(wizNetLink, "bin/wizcfg.com");
	getFile(newsLink, "updater.new");
	getFile(pkunzipLink, "bin/pkunzip.com");
	getFile(tarLink, "bin/tar.com");
	getFile(cmdLink, "bin/cmd.com");
	getFile(termLink, "bin/term.com");
	getFile(updLink, "bin/updater.com");
	getFile(netIniLink, "bin/net_.ini");
}

void deleteWorkFiles(void)
{
	OS_DELETE("bin.zip");
	OS_DELETE("bin.tar");
}

unsigned char ren2old(unsigned char *name)
{
	unsigned char counter = 0;
	OS_MKDIR((void *)name);
	sprintf(nameBuf, "%s.old", name);
	while (OS_RENAME((void *)name, (void *)nameBuf) != 0)
	{

		if (counter == 255)
		{
			fatalError("Unable to rename old folder");
		}
		counter++;
		sprintf(nameBuf, "%s.%u", name, counter);
	}
	return counter;
}

void ren2tar(void)
{
	unsigned int counter = 2400;
	do
	{
		sprintf(nameBuf, "bin.r%u", counter);

		errn = OS_RENAME((void *)nameBuf, "bin.tar");
		counter--;
		if (counter < 2000)
		{
			fatalError("Unable to rename TAR file");
		}
	} while (errn != 0);
}

void ren2bin(void)
{
	unsigned char counter = 20;
	sprintf(nameBuf, "bin.r%u", counter);
	do
	{
		errn = OS_RENAME((void *)nameBuf, "bin");
		counter++;
		sprintf(nameBuf, "bin.r%u", counter);
		if (counter > 99)
		{
			fatalError("Unable to rename BIN folder");
		}
	} while (errn != 0);
}

void restoreConfig(unsigned char oldBinExt)
{
	unsigned char count;
	errn = OS_CHDIR("/");
	errn = OS_RENAME("bin/autoexec.bat", "bin/autoexec.bat.new");
	errn = OS_RENAME("bin/net.ini", "bin/net.ini.new");
	errn = OS_RENAME("bin/nv.ext", "bin/nv.ext.new");
	errn = OS_RENAME("bin/gp/gp.ini", "bin/gp/gp.ini.new");
	errn = OS_RENAME("/bin/browser/index.gph", "/bin/browser/index.gph.new");

	errn = OS_CHDIR("/");

	if (oldBinExt == 255)
	{
		errn = OS_SHELL("copy bin.old/autoexec.bat bin/autoexec.bat");

		errn = OS_SHELL("copy bin.old/net.ini bin/net.ini");

		errn = OS_SHELL("copy bin.old/nv.ext bin/nv.ext");

		errn = OS_SHELL("copy bin.old/gp/gp.ini bin/gp/gp.ini");
		errn = OS_SHELL("copy bin.old/browser/index.gph bin/browser/index.gph");
	}
	else
	{
		sprintf(nameBuf, "copy bin.%u/autoexec.bat bin/autoexec.bat", oldBinExt);
		OS_SHELL((void *)nameBuf);

		sprintf(nameBuf, "copy bin.%u/net.ini bin/net.ini", oldBinExt);
		OS_SHELL((void *)nameBuf);

		sprintf(nameBuf, "copy bin.%u/nv.ext bin/nv.ext", oldBinExt);
		OS_SHELL((void *)nameBuf);
		sprintf(nameBuf, "copy bin.%u/gp/gp.ini bin/gp/gp.ini", oldBinExt);
		OS_SHELL((void *)nameBuf);
		sprintf(nameBuf, "copy bin.%u/browser/index.gph bin/browser/index.gph", oldBinExt);
		OS_SHELL((void *)nameBuf);
	}
	AT(1, 4);
	for (count = 0; count < 15; count++)
	{
		putchar(176);
	}
	errn = OS_RENAME("bin/bin/autoexec.bat.new", "bin/autoexec.bat"); // If file already exist we dont rename
	errn = OS_RENAME("bin/net.ini.new", "bin/net.ini");
	errn = OS_RENAME("bin/nv.ext.new", "bin/nv.ext");
	errn = OS_RENAME("bin/gp/gp.ini.new", "bin/gp/gp.ini");
	errn = OS_RENAME("bin/browser/index.gph.new", "bin/browser/index.gph");
}

// Download, backup, unpack release.bin
void fullUpdate(void)
{
	BOX(1, 1, 80, 25, 40, 176);
	cw.x = 20;
	cw.y = 5;
	cw.w = 40;
	cw.h = 7;
	cw.text = 97;
	cw.back = 45;

	AT(1, 1);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("                   [FULL UPDATE - UPDATING ALL SYSTEM FILES]                    ");

	strcpy(cw.tittle, "nedoOS FULL updater ");
	strcat(cw.tittle, uVer);

	getConfig();

	OS_GETPATH((unsigned int)&curPath);
	curLetter = curPath[0];
	errn = OS_CHDIR("/");

	strcat(cw.tittle, " (");
	strcat(cw.tittle, config.machineName);
	strcat(cw.tittle, ")");
	drawWindow(cw);

	OS_DELETE("release.zip");

	clearStatus();
	AT(cw.x + 2, cw.y + 3);
	printf("1.Downloading release.zip...");

	errn = getFile(relLink, "release.zip"); //  Downloading the file

	clearStatus();

	clearStatus();
	AT(cw.x + 2, cw.y + 4);
	printf("2.Backuping old system...\r\n");

	oldBinExt = ren2old("bin");
	ren2old("doc");
	ren2old("nedodemo");
	ren2old("nedogame");

	AT(cw.x + 2, cw.y + 5);
	printf("3.Downloading tools...\r\n");

	getTools();

	BOX(1, 1, 80, 25, 40, 32);
	AT(1, 1);
	printf("Depacking release. Its take about 10 hours. Please wait.\r\n");
	printf("First hours going without signs of life.\r\n");

	printNews();

	YIELD();
	OS_SHELL("pkunzip.com release.zip");
	BOX(1, 1, 80, 25, 40, 176);
	drawWindow(cw);
	AT(cw.x + 2, cw.y + 3);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("Restoring configs...");
}
// Updating only BIN folders, where is OS lives.
void binUpdate(void)
{
	BOX(1, 1, 80, 25, 40, 176);
	cw.x = 20;
	cw.y = 5;
	cw.w = 40;
	cw.h = 11;
	cw.text = 97;
	cw.back = 44;

	AT(1, 1);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("                  [STANDART UPDATE - UPDATING ONLY BIN FOLDER]                  ");

	strcpy(cw.tittle, "nedoOS BIN updater ");
	strcat(cw.tittle, uVer);
	getConfig();
	strcat(cw.tittle, " (");
	strcat(cw.tittle, config.machineName);
	strcat(cw.tittle, ")");
	drawWindow(cw);

	OS_CHDIR("/");
	OS_GETPATH((unsigned int)&curPath);
	curLetter = curPath[0];

	deleteWorkFiles();

	clearStatus();

	AT(cw.x + 2, cw.y + 10);
	printf(">To full update start 'updater.com F'<");

	AT(cw.x + 2, cw.y + 3);
	printf("1.Downloading bin.zip...");

	getFile(binLink, "bin.zip"); //  Downloading the file

	clearStatus();
	AT(cw.x + 2, cw.y + 4);
	printf("2.Downloading tools...");

	getTools();

	BOX(1, 1, 80, 25, 40, 32);
	AT(1, 1);
	printf("Please, make sure you don't have bin.r* folder on disk!!!\r\n");
	printf("Depacking release. Its take about 10 minutes. Please wait...\r\n");

	printNews();
	YIELD();

	OS_SHELL("pkunzip.com bin.zip");
	BOX(1, 1, 80, 25, 40, 176);
	drawWindow(cw);
	clearStatus();
	AT(cw.x + 2, cw.y + 3);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("3.Renaming bin.r?? to bin.tar...");

	ren2tar();

	AT(cw.x + 2, cw.y + 4);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("4.Untaring bin.tar, please wait...");
	clearStatus();
	OS_SHELL("tar.com bin.tar");

	AT(cw.x + 2, cw.y + 5);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("5.Backuping old bin to bin.old...");

	oldBinExt = ren2old("bin");

	AT(cw.x + 2, cw.y + 6);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("6.Renaming NEW BIN...");

	ren2bin();

	AT(cw.x + 2, cw.y + 7);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("7.Deleting zip & tar...");

	AT(cw.x + 2, cw.y + 8);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("8.Downloading kernel [%s]...", config.machineName);
	errn = OS_CHDIR("/");
	errn = getFile(config.kernelLink, config.kernelName); //  Downloading the file
	AT(cw.x + 2, cw.y + 9);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("9.Restoring configs...");
}

C_task main(int argc, char *argv[])
{
	os_initstdio();

	if (argc > 1)
	{
		if (argv[1][0] == 'F')
		{
			fullUpdate();
		}
		else if (argv[1][0] == 'e')
		{
			netDriver = 1;
			clearStatus();
			printf("    ESP-COM mode enabled...");
			loadEspConfig();
			uart_init(divider);
			espReBoot();
			binUpdate();
		}
		else if (argv[1][0] == 'E')
		{
			netDriver = 1;
			clearStatus();
			printf("    ESP-COM mode enabled...");
			loadEspConfig();
			uart_init(divider);
			espReBoot();
			fullUpdate();
		}
		else
		{
			AT(1, 1);
			// printTable();
			// printNews();
			// getchar();
			fatalError("Use 'F' key to FULL update");
			exit(0);
		}
	}
	else
	{
		binUpdate();
	}
	restoreConfig(oldBinExt);
	deleteWorkFiles();
	clearStatus();
	infoBox("System Updated successfully!");
	getchar();
	OS_DELETE("release.zip");
	ATRIB(40);
	ATRIB(32);
	exit(0);
}
