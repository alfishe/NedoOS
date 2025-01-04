#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <stdlib.h>
#include <oscalls.h>
#include <../common/terminal.c>
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

unsigned char uVer[] = "0.90";
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
struct sockaddr_in dnsaddress;

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
unsigned char binLink[] = "http://nedoos.ru/images/sysbin.zip";
unsigned char pkunzipLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/pkunzip.com";
unsigned char tarLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/tar.com";
unsigned char cmdLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/cmd.com";
unsigned char termLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/term.com";
unsigned char updLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/updater.com";
unsigned char newsLink[] = "/svn/dl.php?repname=NedoOS&path=/release/doc/updater.new";
unsigned char wizNetLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/wizcfg.com";
unsigned char netIniLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/net.ini";
unsigned char relLink[] = "http://nedoos.ru/images/release.zip";
unsigned char nameBuf1[512];
unsigned char *nameBuf = nameBuf1;
const unsigned char sendOk[] = "SEND OK";
const unsigned char gotWiFi[] = "WIFI GOT IP";
unsigned char cmd[512];
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
		AT(20, 2 + curLine);
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
	do
	{
		YIELD();
	} while (_low_level_get() == 0);
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
	OS_CHDIR("/");

	strcat(appCmd, command);
	fp3 = OS_OPENHANDLE(fileName, 0x80);
	if (((int)fp3) & 0xff)
	{
		clearStatus();
		AT(1, 24);
		printf("%s", fileName);
		printf(" not found.");
		do
		{
			YIELD();
		} while (_low_level_get() == 0);
		exit(0);
	}

	shellSize = OS_GETFILESIZE(fp3);

	OS_CHDIR(curPath);

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

///////////////////////////
#include <../common/esp-com.c>
#include <../common/network.c>
//////////////////////////

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

unsigned char getFile(unsigned char *fileLink, unsigned char *fileNamePtr)
{
	int todo;
	char socket;
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
		clearStatus();
		socket = OpenSock(AF_INET, SOCK_STREAM);
		testOperation("OS_NETSOCKET", socket);

		todo = netConnect(socket, 10);
		testOperation("OS_NETCONNECT", todo);

		todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf), 10);
		testOperation("OS_WIZNETWRITE", todo);
		clearStatus();
		do
		{
			headlng = 0;
			todo = tcpRead(socket, 10);
			testOperation("OS_WIZNETREAD", todo);
			if (todo == 0)
			{
				break;
			}
			if (downloaded == 0)
			{
				todo = cutHeader(todo);
				fileSize1 = contLen / 1024;
				saveBuf(fileNamePtr, 00, 0);
			}
			downloaded = downloaded + todo;
			printf(" %lu of %u kb   \r", downloaded / 1024, fileSize1);
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

		sprintf(cmd, "AT+CIPSEND=%u", sizeLink + 2); // second CRLF in send command
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
		clearStatus();
		do
		{
			headlng = 0;
			todo = recvHead();
			getdataEsp(todo); // Requested size
			if (downloaded == 0)
			{
				todo = cutHeader(todo);
				fileSize1 = contLen / 1024;
				saveBuf(fileNamePtr, 00, 0);
			}
			downloaded = downloaded + todo;
			printf("%lu of %u kb   \r", downloaded / 1024, fileSize1);
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
	ATRIB(cw.text);
	ATRIB(cw.back);
	getFile(wizNetLink, "bin/wizcfg.com");
	getFile(newsLink, "updater.new");
	getFile(pkunzipLink, "bin/pkunzip.com");
	getFile(tarLink, "bin/tar.com");
	getFile(cmdLink, "bin/cmd.com");
	getFile(termLink, "bin/term.com");
	getFile(updLink, "bin/updater.com");
	getFile(netIniLink, "bin/net.ini");
}

unsigned char ren2old(unsigned char *name)
{
	unsigned char counter = 255; // For OLD must be 255
	OS_MKDIR((void *)name);
	sprintf(nameBuf, "%s.old", name);
	while (OS_RENAME((void *)name, (void *)nameBuf) != 0)
	{
		counter++;
		sprintf(nameBuf, "%s.%u", name, counter);
		if (counter == 255)
		{
			fatalError("Unable to rename old folder");
		}
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
	if (oldBinExt == 255)
	{
		errn = OS_SHELL("copy bin.old/autoexec.bat bin/autoexec.bat >>updlog.txt");
		errn = OS_SHELL("copy bin.old/net.ini bin/net.ini >>updlog.txt");
		errn = OS_SHELL("copy bin.old/nv.ext bin/nv.ext >>updlog.txt");
		errn = OS_SHELL("copy bin.old/gp/gp.ini bin/gp/gp.ini >>updlog.txt");
		errn = OS_SHELL("copy bin.old/browser/index.gph bin/browser/index.gph >>updlog.txt");
	}
	else
	{
		sprintf(nameBuf, "copy bin.%u/autoexec.bat bin/autoexec.bat >>updlog.txt", oldBinExt);
		OS_SHELL((void *)nameBuf);
		sprintf(nameBuf, "copy bin.%u/net.ini bin/net.ini >>updlog.txt", oldBinExt);
		OS_SHELL((void *)nameBuf);
		sprintf(nameBuf, "copy bin.%u/nv.ext bin/nv.ext >>updlog.txt", oldBinExt);
		OS_SHELL((void *)nameBuf);
		sprintf(nameBuf, "copy bin.%u/gp/gp.ini bin/gp/gp.ini >>updlog.txt", oldBinExt);
		OS_SHELL((void *)nameBuf);
		sprintf(nameBuf, "copy bin.%u/browser/index.gph bin/browser/index.gph >>updlog.txt", oldBinExt);
		OS_SHELL((void *)nameBuf);
	}
	AT(1, 4);
	ATRIB(40);
	for (count = 0; count < 15; count++)
	{
		putchar(176);
	}
	errn = OS_RENAME("bin/autoexec.bat.new", "bin/autoexec.bat"); // If file already exist we dont rename
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

	errn = OS_CHDIR("/");

	strcat(cw.tittle, " (");
	strcat(cw.tittle, config.machineName);
	strcat(cw.tittle, ")");
	drawWindow(cw);

	OS_DELETE("release.zip");

	clearStatus();
	AT(cw.x + 2, cw.y + 3);
	printf("1.Downloading release.zip...");
	YIELD();
	errn = getFile(relLink, "release.zip"); //  Downloading the file

	clearStatus();
	AT(cw.x + 2, cw.y + 4);
	printf("2.Backuping old system...\r\n");
	YIELD();
	oldBinExt = ren2old("bin");
	ren2old("doc");
	ren2old("ini");
	ren2old("nedodemo");
	ren2old("nedogame");

	AT(cw.x + 2, cw.y + 5);
	printf("3.Downloading tools...\r\n");

	OS_MKDIR("bin");
	YIELD();
	getTools();

	BOX(1, 1, 80, 25, 40, 32);
	AT(1, 1);
	printf("Depacking release. Its take about 5 hours. Please wait.\r\n");

	printNews();
	YIELD();

	OS_SHELL("pkunzip.com release.zip");

	BOX(1, 1, 80, 25, 40, 176);
	drawWindow(cw);
	AT(cw.x + 2, cw.y + 3);
	printf("1.Downloading release.zip...");
	AT(cw.x + 2, cw.y + 4);
	printf("2.Backuping old system...\r\n");
	AT(cw.x + 2, cw.y + 5);
	printf("3.Downloading tools...\r\n");
	AT(cw.x + 2, cw.y + 6);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("Restoring configs...");
}

unsigned char testConect(void)
{
	unsigned char *count1;
	if (netDriver == 1)
	{
		sendcommand("AT+CIPSTART=\"TCP\",\"nedoos.ru\",80");
		getAnswer2(); // CONNECT or ERROR or link is not valid
		count1 = strstr(netbuf, "CONNECT");

		if (count1 == NULL)
		{
			YIELD();
			uart_flush();
			return 0;
		}
		getAnswer2(); // OK
		sendcommand("AT+CIPCLOSE");
		getAnswer2(); // CLOSED
		getAnswer2(); // OK
	}
	return 1;
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
	clearStatus();
	AT(cw.x + 2, cw.y + 10);
	printf(">To full update start 'updater.com F'<");

	OS_SHELL("time2 >updlog.txt");

	AT(cw.x + 2, cw.y + 3);
	printf("1.Downloading bin.zip...");
	YIELD();
	getFile(binLink, "bin/bin.zip"); //  Downloading the file

	clearStatus();
	AT(cw.x + 2, cw.y + 4);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("2.Backuping bin to bin.old...");
	YIELD();
	oldBinExt = ren2old("bin");
	OS_MKDIR("bin");

	clearStatus();
	AT(cw.x + 2, cw.y + 5);
	printf("3.Downloading tools...");
	getTools();

	if (oldBinExt != 255)
	{
		sprintf(nameBuf, "bin.%u/bin.zip", oldBinExt);
	}
	else
	{
		sprintf(nameBuf, "bin.old/bin.zip");
	}
	errn = OS_RENAME((void *)nameBuf, "bin/bin.zip");

	BOX(1, 1, 80, 25, 40, 32);
	AT(1, 1);
	printf("Depacking release. Its take about 10 minutes. Please wait...\r\n");
	printNews();
	YIELD();

	OS_CHDIR("bin");
	OS_SHELL("pkunzip.com bin.zip");

	BOX(1, 1, 80, 25, 40, 176);
	AT(1, 1);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("                  [STANDART UPDATE - UPDATING ONLY BIN FOLDER]                  ");
	drawWindow(cw);

	ATRIB(cw.text);
	ATRIB(cw.back);
	AT(cw.x + 2, cw.y + 3);
	printf("2.Downloading bin.zip...");
	AT(cw.x + 2, cw.y + 4);
	printf("1.Backuping bin to bin.old...");
	AT(cw.x + 2, cw.y + 5);
	printf("3.Downloading tools...");
	AT(cw.x + 2, cw.y + 6);
	printf("4.Downloading kernel [%s]...", config.machineName);
	errn = OS_CHDIR("/");
	errn = getFile(config.kernelLink, config.kernelName); //  Downloading the file
	AT(cw.x + 2, cw.y + 7);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("5.Restoring configs...");
}

C_task main(int argc, char *argv[])
{
	unsigned char test;
	os_initstdio();

	targetadr.family = AF_INET;
	targetadr.porth = 00;
	targetadr.portl = 80;
	targetadr.b1 = 31;
	targetadr.b2 = 31;
	targetadr.b3 = 65;
	targetadr.b4 = 35;

	clearStatus();

	OS_GETPATH((unsigned int)&curPath);
	curLetter = curPath[0];

	if (argc > 1)
	{
		if (argv[1][0] == 'F')
		{
			netDriver = 0;
			get_dns();
			test = dnsResolve("nedoos.ru");
			if (test)
			{
				fullUpdate();
			}
		}
		else if (argv[1][0] == 'e')
		{
			netDriver = 1;
			clearStatus();
			printf("    ESP-COM mode enabled...");
			loadEspConfig();
			uart_init(divider);
			espReBoot();
			test = testConect();
			if (test)
			{
				binUpdate();
			}
		}
		else if (argv[1][0] == 'E')
		{
			netDriver = 1;
			clearStatus();
			printf("    ESP-COM mode enabled...");
			loadEspConfig();
			uart_init(divider);
			espReBoot();
			test = testConect();
			if (test)
			{
				fullUpdate();
			}
		}
		else
		{
			AT(1, 1);
			// printTable();
			//  printNews();
			// getchar();
			fatalError("Use 'F' key to FULL update");
			exit(0);
		}
	}
	else
	{
		netDriver = 0;
		get_dns();
		test = dnsResolve("nedoos.ru");
		if (test)
		{
			binUpdate();
		}
	}

	if (!test)
	{
		fatalError("Check connection to the server!");
	}
	restoreConfig(oldBinExt);
	OS_DELETE("bin/bin.zip");
	clearStatus();
	infoBox("System Updated successfully!");
	delay(2000);
	OS_SHELL("time2 >>updlog.txt");
	// getchar();
	// OS_DELETE("release.zip");
	ATRIB(40);
	ATRIB(32);
	AT(1, 25);
	exit(0);
}
