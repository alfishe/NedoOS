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
unsigned char uVer[] = "0.46";
unsigned char curPath[128];
unsigned char curLetter;
unsigned char oldBinExt;
unsigned int errn, headlng;
unsigned long contLen;
unsigned char saveFlag, saveBak;
unsigned char crlf[2] = {13, 10};
unsigned long downloaded;
unsigned char status, key, curFormat;
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

unsigned int bufSize = 2048; // Some memory corruption at this point, some QnD
unsigned char netbuf[4000];

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
	unsigned char appCmd[127] = "cmd.com ";
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
//////////////// NETWORK PART //////////////////////
// #include <network.c>
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
	YIELD();
	do
	{
		key = _low_level_get();
	} while (key == 0);
}

unsigned int httpError(void)
{
	unsigned char *httpRes;
	unsigned int httpErr;
	httpRes = strstr(netbuf, "HTTP/1.1 ");

	if (httpRes != NULL)
	{
		httpErr = atol(httpRes + 9);
		if (httpErr == 200)
		{
			return httpErr;
		}
	}

	BOX(1, 1, 80, 25, 40, 32);
	AT(1, 1);
	printf("HTTP ERROR %u", httpErr);

	fatalError("Server response error!");
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
		unsigned char fileName[255];
		strcpy(fileName, fileNamePtr);
		fp2 = OS_CREATEHANDLE(fileName, 0x80);
		if (((int)fp2) & 0xff)
		{
			clearStatus();
			AT(1, 24);
			printf("%s", fileName);
			printf(" creating error.");
			exit(0);
		}
		OS_CLOSEHANDLE(fp2);

		fp2 = OS_OPENHANDLE(fileName, 0x80);
		if (((int)fp2) & 0xff)
		{
			clearStatus();
			AT(1, 24);
			printf("%s", fileName);
			printf(" opening error. ");

			exit(0);
		}
		AT(1, 24);
		return 0;
	}

	if (operation == 01)
	{
		OS_WRITEHANDLE(netbuf + headlng, fp2, sizeOfBuf);
		downloaded = downloaded + sizeOfBuf;
		return 0;
	}

	if (operation == 02)
	{
		OS_CLOSEHANDLE(fp2);
		return 0;
	}
	return 0;
}

void cancel(void)
{
	key = _low_level_get();
	if (key == 27)
	{
		fatalError("File download aborted!");
	}
}

unsigned int tcpRead(unsigned char socket)
{
	unsigned char retry = 20;
	unsigned int todo;
	readStruct.socket = socket;
	readStruct.BufAdr = (unsigned int)&netbuf;
	readStruct.bufsize = bufSize;
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
	unsigned int q;
	unsigned char *count;

	count = strstr(netbuf, "Content-Length:");
	if (count == NULL)
	{
		clearStatus();
		AT(1, 24);
		printf("Content-Length:  not found.");
		contLen = 0;
	}
	else
	{
		contLen = atol(count + 15);
		//    AT (1,24);
		//      printf("=> Dlinna  soderzhimogo = %lu \n\r", contLen);
	}

	count = strstr(netbuf, "\r\n\r\n");
	headlng = ((unsigned int)count - (unsigned int)netbuf + 4);
	q = todo - headlng;
	return q;
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
		cancel();
		delay(100);
		goto wizwrite;
	}

	return todo;
}
unsigned char getFile(unsigned char *fileLink, unsigned char *fileNamePtr)
{
	unsigned int todo;
	unsigned char cmdlist1[] = " HTTP/1.1\r\nHost: nedoos.ru\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)\r\n\r\n\0";
	unsigned char socket;
	unsigned int headskip;
	unsigned long bytecount;
	unsigned long fileSize1;
	unsigned char fileName[255];
	unsigned int httpErr;
	strcpy(netbuf, "GET ");
	strcat(netbuf, fileLink);
	strcat(netbuf, cmdlist1);
	clearStatus();
	socket = OpenSock(AF_INET, SOCK_STREAM);
	todo = netConnect(socket);
	todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf));

	headskip = 0;
	bytecount = 255;
	downloaded = 0;
	strcpy(fileName, fileNamePtr);
	AT(1, 24);
	printf("%s", fileName);

	while (bytecount != 0)
	{
		headlng = 0;
		todo = tcpRead(socket);
		if (todo == 0)
		{
			break;
		}
		if (headskip == 0)
		{
			httpErr = httpError();
			headskip = 1;
			todo = cutHeader(todo);
			fileSize1 = contLen / 1024;
			bytecount = contLen;
			saveBuf(fileName, 00, 0);
		}
		AT(32, 24);
		printf("%lu of %lu kb  ", downloaded / 1024, fileSize1);

		saveBuf(fileName, 01, todo);
		bytecount = bytecount - todo;

		cancel();
	}
	netShutDown(socket, 0);
	saveBuf(fileName, 02, 00);
	if (downloaded != contLen)
	{
		fatalError("File download error!");
	}
	return 0;
}
////////////////////////////////////////////////////

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
		strcpy(config.kernelLink, "/svn/dl.php?repname=NedoOS&path=/release/sd_boot.%24C");
		break;
	}
	return config.is_atm;
}
// Downloading minimal tools for updating/boot
void getTools(void)
{
	unsigned char pkunzipLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/pkunzip.com";
	unsigned char tarLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/tar.com";
	unsigned char cmdLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/cmd.com";
	unsigned char termLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/term.com";
	unsigned char updLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/updater.com";
	unsigned char newsLink[] = "/svn/dl.php?repname=NedoOS&path=/release/doc/updater.new";
	unsigned char wizNetLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/wizcfg.com";
	unsigned char netIniLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/net.ini";

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
	unsigned char *oldName = "0000000000000000000000000000000000";
	unsigned char counter = 255;
	OS_MKDIR((void *)name);
	sprintf(oldName, "%s.old", name);
	while (OS_RENAME((void *)name, (void *)oldName) != 0)
	{
		counter++;
		if (counter == 255)
		{
			fatalError("Unable to rename old folder");
		}

		sprintf(oldName, "%s.%u", name, counter);
	}
	return counter;
}

void ren2tar(void)
{
	unsigned char *name = "0000000000000000000000000000000000";
	unsigned int counter = 2500;
	errn = 255;
	sprintf(name, "bin.r%u", counter);
	while (errn != 0)
	{
		errn = OS_RENAME((void *)name, "bin.tar");
		counter--;
		sprintf(name, "bin.r%u", counter);
		if (counter < 1800)
		{
			fatalError("Unable to rename TAR file");
		}
	}
}

void ren2bin(void)
{
	unsigned char *name = "0000000000000000000000000000000000";
	unsigned char counter = 17;
	errn = 255;
	sprintf(name, "bin.r%u", counter);
	while (errn != 0)
	{
		errn = OS_RENAME((void *)name, "bin");
		counter++;
		sprintf(name, "bin.r%u", counter);
		if (counter > 99)
		{
			fatalError("Unable to rename BIN folder");
		}
	}
}

void restoreConfig(unsigned char oldBinExt)
{
	unsigned char *name = "0000000000000000000000000000000000";
	unsigned char count;
	errn = OS_CHDIR("/");
	errn = OS_RENAME("bin/autoexec.bat", "bin/autoexec.new");
	errn = OS_RENAME("bin/net.ini", "bin/net.new");
	errn = OS_RENAME("bin/nv.ext", "bin/nv.new");
	errn = OS_RENAME("bin/gp/gp.ini", "bin/gp/gpini.new");
	errn = OS_RENAME("/bin/browser/index.gph", "/bin/browser/index.gph.new");

	errn = OS_CHDIR("/");

	if (oldBinExt == 255)
	{
		errn = OS_SHELL("copy bin.old/autoexec.bat bin/autoexec.bat");

		errn = OS_SHELL("copy bin.old/net.ini bin/net.ini");

		errn = OS_SHELL("copy bin.old/nv.ext bin/nv.ext");

		errn = OS_SHELL("copy bin.old/nv.pth bin/nv.pth");

		errn = OS_SHELL("copy bin.old/gp/gp.ini bin/gp/gp.ini");
		errn = OS_SHELL("copy bin.old/browser/index.gph bin/browser/index.gph");
	}
	else
	{
		sprintf(name, "copy bin.%u/autoexec.bat bin/autoexec.bat", oldBinExt);
		OS_SHELL((void *)name);

		sprintf(name, "copy bin.%u/net.ini bin/net.ini", oldBinExt);
		OS_SHELL((void *)name);

		sprintf(name, "copy bin.%u/nv.ext bin/nv.ext", oldBinExt);
		OS_SHELL((void *)name);
		sprintf(name, "copy bin.%u/nv.pth bin/nv.pth", oldBinExt);
		OS_SHELL((void *)name);
		sprintf(name, "copy bin.%u/gp/gp.ini bin/gp/gp.ini", oldBinExt);
		OS_SHELL((void *)name);
		sprintf(name, "copy bin.%u/browser/index.gph bin/browser/index.gph", oldBinExt);
		OS_SHELL((void *)name);
	}
	AT(1, 4);
	for (count = 0; count < 15; count++)
	{
		putchar(176);
	}
	errn = OS_RENAME("bin/autoexec.new", "bin/autoexec.bat"); // If file already exist we dont rename
	errn = OS_RENAME("bin/net.new", "bin/net.ini");
	errn = OS_RENAME("bin/nv.new", "bin/nv.ext");
	errn = OS_RENAME("bin/gp/gpini.new", "bin/gp/gp.ini");
	errn = OS_RENAME("bin/browser/index.gph.new", "bin/browser/index.gph");
}

// Download, backup, unpack release.bin
void fullUpdate(void)
{
	unsigned char relLink[] = "http://nedoos.ru/images/release.zip";

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
	unsigned char binLink[] = "/svn/dl.php?repname=NedoOS&path=/release/bin/&isdir=1";
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
