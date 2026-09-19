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
//////////////////
#define true 1
#define false 0
FILE *fp2; // must be global if savebuf may not to close file.
fileInfo global_info;

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
unsigned int netDriver = 0;
unsigned int espRetry = 5;
unsigned long factor, timerok, count = 0;
unsigned int magic = 15;

unsigned char uVer[] = "2.4";
unsigned char curPath[128];
unsigned char curLetter;
unsigned char oldBinExt;
unsigned int errn, headlng;
unsigned long contLen;
unsigned char saveFlag, saveBak;
unsigned char crlf[2] = {13, 10};

/* CLI flags (override network.ini where noted) */
unsigned char forceEsp = 0;		/* -e : ESP-COM mode */
unsigned char doFullUpdate = 0; /* -f : full update */
unsigned char useMirror = 0;	/* -m : kulich.su instead of nedoos.ru */

unsigned char status, curFormat;

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
	unsigned char tittle[60];

} cw;

struct configuration
{
	unsigned char kernelName[32];
	unsigned char machineName[32];
	unsigned char kernelLink[128];
	unsigned char is_atm;
} config;

unsigned char userAgent[100];
unsigned char binLink[100];
unsigned char pkunzipLink[100];
unsigned char tarLink[90];
unsigned char cmdLink[90];
unsigned char termLink[90];
unsigned char updLink[90];
unsigned char newsLink[90];
unsigned char wizNetLink[90];
unsigned char netIniLink[90];
unsigned char relLink[90];
unsigned char updateHost[16];

unsigned char netbuf[4000];
unsigned char cmd[350];
unsigned char link[350];

// const unsigned char sendOk[] = "SEND OK";
const unsigned char gotWiFi[] = "WIFI GOT IP";

void clearNetBuf(unsigned int const size)
{
	unsigned int counter;
	for (counter = 0; counter < size; counter++)
	{
		netbuf[counter] = 0;
	}
}

void quit(void)
{
	ATRIB(40);
	ATRIB(32);
	AT(1, 25);
	exit(0);
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
	AT(1, 24);
	spaces(80);
	putchar('\r');
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
		key = _low_level_get();
		if (key != 0)
		{

			if (key == 27)
			{
				quit();
			}
			return key;
		}
		YIELD();
	}
	return 0;
}

void waitKey(void)
{
	do
	{
		YIELD();
	} while (_low_level_get() == 0);
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
	while (curLine < 21)
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

void fatalError(const unsigned char *message)
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

void infoBox(const unsigned char *message)
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

unsigned char OS_SHELL(const unsigned char *command)
{
	unsigned char fileName[] = "bin/cmd.com";
	unsigned char appCmd[128];
	unsigned int shellSize, loop;
	unsigned char pgbak;
	union APP_PAGES shell_pg;
	union APP_PAGES main_pg;
	FILE *fp3;
	unsigned char *targetAddr;
	unsigned int cmdLen;

	/* Безопасное построение командной строки */
	strcpy((char *)appCmd, "cmd.com ");
	/* 128 всего - 8 ("cmd.com ") - 1 (для '\0') = 119 символов максимум */
	strncat((char *)appCmd, (const char *)command, 119);

	main_pg.l = OS_GETMAINPAGES();
	pgbak = main_pg.pgs.window_3;
	OS_GETPATH(curPath);
	OS_CHDIR("/");

	fp3 = OS_OPENHANDLE(fileName, 0x80);
	if (((int)fp3) & 0xff)
	{
		clearStatus();
		AT(1, 24);
		printf("%s not found.", fileName);
		getchar();
		exit(0);
	}

	shellSize = OS_GETFILESIZE(fp3);
	OS_CHDIR(curPath);

	OS_NEWAPP((unsigned int)&shell_pg);
	shell_pg.l = OS_GETAPPMAINPAGES(shell_pg.pgs.pId);

	/* Включаем страницу шелла */
	SETPG32KHIGH(shell_pg.pgs.window_0);

	/* Копируем ASCIIZ строку параметров строго по её фактической длине */
	cmdLen = strlen((char *)appCmd) + 1;
	memcpy((unsigned char *)(0xC080), appCmd, cmdLen);

	/* СВЕРХБЫСТРАЯ ЗАГРУЗКА БЕЗ ПРОМЕЖУТОЧНОГО БУФЕРА */
	loop = 0;
	targetAddr = (unsigned char *)0xC100;

	while (loop < shellSize)
	{
		unsigned int loaded;
		/* Читаем порцию напрямую в ОЗУ процесса, сколько осталось до конца */
		loaded = OS_READHANDLE(targetAddr, fp3, shellSize - loop);
		if (loaded == 0)
		{
			break; /* Защита от зависания при ошибке диска/FAT */
		}
		loop += loaded;
		targetAddr += loaded;
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
#define ESPNET_CLIENT_ONLY 1
#include <../common/espnet.c>
#include <../common/espnet-net.c>
//////////////////////////

unsigned char saveBuf(unsigned char *fileNamePtr, unsigned char operation, unsigned int sizeOfBuf)
{
	switch (operation)
	{
	case 00:
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
		break;

	case 01:
		OS_WRITEHANDLE(netbuf + headlng, fp2, sizeOfBuf);
		break;

	default:
		OS_CLOSEHANDLE(fp2);
	}

	return 0;
}

unsigned int cutHeader(void)
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
		// printf("header %u bytes\r\n", headlng);
	}
	return ((unsigned int)count1 - (unsigned int)netbuf + 4);
}

char testOperation3(const char *process, int socket)
{
	if (socket < 0)
	{
		clearStatus();
		printf("%s:", process);
		errorPrint(-socket & 0xff);
		YIELD();
		return false;
	}
	return true;
}

unsigned char delete_tree_recursive(const char *dir_name)
{
	/* СЕКЦИЯ ОБЪЯВЛЕНИЯ ПЕРЕМЕННЫХ (Всего несколько байт в стеке!) */
	unsigned char result;
	char local_name[64];
	char is_dir;
	char found_any;

	/* Пытаемся зайти внутрь целевой папки */
	if (OS_CHDIR((unsigned char *)dir_name) != 0)
	{
		return 255;
	}

	/* Главный цикл очистки текущей папки */
	while (1)
	{
		/* Принудительно переоткрываем текущую папку */
		OS_OPENDIR("");
		found_any = 0;

		/* Ищем ПЕРВЫЙ валидный элемент, используя глобальную структуру */
		while (1)
		{
			result = OS_READDIR(&global_info);

			if (result == 4 || result != 0)
				break;

			/* Строжайшая посимвольная проверка на служебные точки */
			if (global_info.fname[0] == '.')
			{
				if (global_info.fname[1] == 0 || (global_info.fname[1] == '.' && global_info.fname[2] == 0))
				{
					continue;
				}
			}

			/* Забираем имя в локальный безопасный буфер текущего уровня */
			if (global_info.lfname[0] != 0)
			{
				strcpy(local_name, (char *)global_info.lfname);
			}
			else
			{
				strcpy(local_name, (char *)global_info.fname);
			}

			is_dir = (global_info.fattrib & 0x10) ? 1 : 0;
			found_any = 1;
			break;
		}

		/* Если папка пуста ? выходим из цикла удаления содержимого */
		if (!found_any)
		{
			break;
		}

		/* Уничтожаем цель */
		if (is_dir)
		{

			/* Рекурсивно очищаем подпапку (чистая рекурсия, стек тратит всего пару байт) */
			delete_tree_recursive(local_name);

			/* ВОССТАНОВЛЕНИЕ ПОЗИЦИИ И КЭША ОС */
			OS_CHDIR((unsigned char *)"..");
			OS_CHDIR((unsigned char *)dir_name);

			/* НИКАКИХ РЕКУРСИВНЫХ RETURN! Просто продолжаем цикл while(1) дальше */
		}
		else
		{
			OS_DELETE((unsigned char *)local_name);
		}
	}

	/* Выходим из вычищенной папки на уровень вверх */
	OS_CHDIR((unsigned char *)"..");

	/* Удаляем саму папку */
	OS_DELETE((unsigned char *)dir_name);
	return 0;
}

char delete(char *target_dir_ptr)
{
	char safe_target_dir[64];

	if (target_dir_ptr == NULL)
	{
		return 255;
	}

	strcpy(safe_target_dir, target_dir_ptr);

	delete_tree_recursive(safe_target_dir);
	return 0;
}

unsigned char getFileEspNet(const unsigned char *fileLink, unsigned char *fileNamePtr)
{
	int todo, socket;
	char firstPacket;
	unsigned int fileSize1;
	unsigned long downloaded = 0;
	unsigned int down;
	sprintf(netbuf, "GET %s%s", fileLink, userAgent);

	if (!EspDnsResolve((char *)updateHost))
	{
		return false;
	}

	socket = EspOpenSock(AF_INET, SOCK_STREAM);
	if (socket < 0)
		return false;

	todo = EspConnect(socket);
	if (todo < 0)
	{
		EspShutDown(socket, 0);
		return false;
	}

	todo = EspSend(socket, (unsigned int)&netbuf, strlen(netbuf));
	if (todo < 0)
	{
		EspShutDown(socket, 0);
		return false;
	}

	firstPacket = true;

	do
	{
		headlng = 0;
		if (firstPacket)
		{
			todo = EspReadHeader(socket);
		}
		else
		{
			do
			{
				todo = EspRead(socket);
			} while (todo == 0 - ESPNET_ERR_EAGAIN);
		}
		if (todo < 1)
		{
			EspShutDown(socket, 0);
			if (todo == 0 - (int)ESPNET_ERR_HOSTUNREACH ||
				todo == 0 - (int)ESPNET_ERR_INTR)
			{
				clearStatus();
				printf("ESPNET link lost after %lu kb", downloaded / 1024);
				return false;
			}
			clearStatus();
			printf("[%ld] Unknown error at %lu kb", todo, downloaded / 1024);
			return false;
		}
		if (firstPacket)
		{
			firstPacket = false;
			headlng = cutHeader();
			todo = todo - headlng;
			fileSize1 = contLen / 1024;
			saveBuf(fileNamePtr, 00, 0);
		}

		downloaded = downloaded + todo;
		down = downloaded / 1024;
		printf("\r %5u of %5u kb     ", down, fileSize1);
		saveBuf(fileNamePtr, 01, todo);
		if (_low_level_get() == 27)
		{
			saveBuf(fileNamePtr, 02, 00);
			fatalError("Update aborted!");
		}
	} while (downloaded < contLen);
	EspShutDown(socket, 0);
	saveBuf(fileNamePtr, 02, 00);

	if (downloaded != contLen)
	{
		return false;
	}
	return true;
}

unsigned char getFileNet(const unsigned char *fileLink, unsigned char *fileNamePtr)
{
	int todo;
	char socket, firstPacket;
	unsigned int fileSize1;
	unsigned long downloaded = 0;
	unsigned int down;
	sprintf(netbuf, "GET %s%s", fileLink, userAgent);
	socket = OpenSock(AF_INET, SOCK_STREAM);
	if (!testOperation3("OS_NETSOCKET", socket))
	{
		return false;
	}

	todo = netConnect(socket, 1);
	if (!testOperation3("OS_NETCONNECT", todo))
	{
		return false;
	}

	todo = tcpSend(socket, (unsigned int)&netbuf, strlen(netbuf), 1);
	if (!testOperation3("OS_WIZNETWRITE", todo))
	{
		return false;
	}

	firstPacket = true;

	do
	{
		headlng = 0;
		if (firstPacket)
			todo = tcpReadHeader(socket, 1);
		else
			todo = tcpRead(socket, 1);
		if (!testOperation3("OS_WIZNETREAD", todo))
		{
			return false;
		}

		if (firstPacket)
		{
			firstPacket = false;
			headlng = cutHeader();
			todo = todo - headlng;
			fileSize1 = contLen / 1024;
			saveBuf(fileNamePtr, 00, 0);
		}

		downloaded = downloaded + todo;
		down = downloaded / 1024;
		printf("\r %5u of %5u kb     ", down, fileSize1);
		saveBuf(fileNamePtr, 01, todo);
		if (_low_level_get() == 27)
		{
			saveBuf(fileNamePtr, 02, 00);
			fatalError("Update aborted!");
		}
	} while (downloaded < contLen);
	netShutDown(socket, 0);
	saveBuf(fileNamePtr, 02, 00);
	return true;
}

unsigned char getFileEsp(const unsigned char *fileLink, unsigned char *fileNamePtr)
{
	int todo;
	unsigned char firstPacket = true;
	unsigned int fileSize1;
	unsigned long downloaded = 0;
	unsigned int down, byte;
	unsigned int sizeLink;
	const unsigned char *count1;

	do
	{
		sprintf(cmd, "AT+CIPSTART=\"TCP\",\"%s\",80", updateHost);
		sendcommand(cmd);

		if (!getAnswer3()) // "CONNECT"
		{
			writeLog("Timeout 'AT+CIPSTART' return false", "getFileEsp     ");
			return false;
		}
		count1 = strstr(netbuf, "CONNECT");
		if (count1 == NULL)
		{
			writeLog("Error in AT+CIPSTART. Not 'CONNECT'.", "getFileEsp     ");
			clearStatus();
			espReBoot();
			delayLongKey(1000);
		}
		else
		{
			break;
		}
	} while (42);

	sprintf(link, "GET %s%s", fileLink, userAgent);
	sizeLink = strlen(link);

	sprintf(cmd, "AT+CIPSEND=%u", sizeLink + 2); // second CRLF in send command
	sendcommand(cmd);
	do
	{
		byte = uartReadBlock();
		if (byte > 255)
		{
			writeLog("Timeout when waiting '>' ", "getFileEsp     ");
			return false;
		}
		// putchar(byte);
	} while (byte != '>');

	sendcommand(link);

	do
	{
		clearNetBuf(255);
		headlng = 0;
		todo = recvHead();

		if (todo == 0)
		{
			writeLog("Error parsing packet size, todo = 0", "getFileEsp     ");
			writeLog(netbuf, "getFileEsp     ");
			return false;
		}

		if (!getdataEsp(todo))
		{
			saveBuf(fileNamePtr, 01, todo);
			saveBuf(fileNamePtr, 02, 00);
			writeLog("Downloading timeout. Exit!", "getFileEsp     ");
			fatalError("[getdataEsp]Downloading timeout. Exit!");
		}

		if (firstPacket)
		{
			firstPacket = false;
			headlng = cutHeader();
			todo = todo - headlng;
			fileSize1 = contLen / 1024;
			saveBuf(fileNamePtr, 00, 0);
		}
		downloaded = downloaded + todo;
		down = downloaded / 1024;
		printf("\r %5u of %5u kb     ", down, fileSize1);
		saveBuf(fileNamePtr, 01, todo);
		if (_low_level_get() == 27)
		{
			saveBuf(fileNamePtr, 02, 00);
			fatalError("Update aborted!");
		}
	} while (downloaded < contLen);
	saveBuf(fileNamePtr, 02, 00);
	sendcommand("AT+CIPCLOSE");

	if (!getAnswer3()) // CLOSED or ERROR
	{
		writeLog("Timeout  waiting CLOSED or ERROR continue", "fillPictureEsp ");
	}

	count1 = strstr(netbuf, "CLOSED");
	if (count1 != NULL)
	{
		if (!getAnswer3()) // OK
		{
			writeLog("Timeout  waiting OK after CLOSED continue", "fillPictureEsp ");
		}
	}

	return true;
}

unsigned char getFile(const unsigned char *fileLink, unsigned char *fileNamePtr)
{
	char result;
	clearStatus();
	AT(26, 24);
	printf("%s", fileNamePtr);

	switch (netDriver)
	{
	case 0:
		result = getFileNet(fileLink, fileNamePtr);
		break;
	case 1:
		result = getFileEsp(fileLink, fileNamePtr);
		break;
	case 2:
		result = getFileEspNet(fileLink, fileNamePtr);
		break;
	}

	if (!result)
	{
		sprintf(cmd, "%s download error!", fileNamePtr);
		fatalError(cmd);
	}

	return false;
}

unsigned char getConfig(void)
{
	config.is_atm = (unsigned char)OS_GETCONFIG();
	/* H=system drive, L= 1-Evo 2-ATM2 3-ATM3 6-p2.666 ;E=pgsys(system page) D= TR-DOS page */
	switch ((config.is_atm))
	{
	case 1:
		strcpy(config.machineName, "ZX-Evolution");
		strcpy(config.kernelName, "sd_boot.$C");
		if (useMirror)
			strcpy(config.kernelLink, "/svn/dl.php?repname=nedoos&path=/nedoos/release/sd_boot.%24C");
		else
			strcpy(config.kernelLink, "/svn/dl.php?repname=NedoOS&path=/release/sd_boot.%24C");
		break;
	case 2:
		strcpy(config.machineName, "TURBO 2+");
		strcpy(config.kernelName, "osatm2hd.$C");
		if (useMirror)
			strcpy(config.kernelLink, "/svn/dl.php?repname=nedoos&path=/nedoos/release/osatm2hd.%24C");
		else
			strcpy(config.kernelLink, "/svn/dl.php?repname=NedoOS&path=/release/osatm2hd.%24C");
		break;

	case 3: /* SD HDD versions */
		strcpy(config.machineName, "TURBO 3 [SD]");
		strcpy(config.kernelName, "osatm3hd.$C");
		if (useMirror)
			strcpy(config.kernelLink, "/svn/dl.php?repname=nedoos&path=/nedoos/release/osatm3hd.%24C");
		else
			strcpy(config.kernelLink, "/svn/dl.php?repname=NedoOS&path=/release/osatm3hd.%24C");
		break;
	case 6: /* SD HDD versions */
		strcpy(config.machineName, "P2.666 [SD]");
		strcpy(config.kernelName, "osp26sd.$C");
		if (useMirror)
			strcpy(config.kernelLink, "/svn/dl.php?repname=nedoos&path=/nedoos/release/osp26sd.%24C");
		else
			strcpy(config.kernelLink, "/svn/dl.php?repname=NedoOS&path=/release/osp26sd.%24C");
		break;

	default:
		strcpy(config.machineName, "NOT DETECED (ZX-Evo)");
		strcpy(config.kernelName, "sd_boot.$C");
		if (useMirror)
			strcpy(config.kernelLink, "/svn/dl.php?repname=nedoos&path=/nedoos/release/sd_boot.s%24C");
		else
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
	getFile(wizNetLink, "bin.new/wizcfg.com");
	getFile(newsLink, "updater.new");
	getFile(pkunzipLink, "bin.new/pkunzip.com");
	getFile(tarLink, "bin.new/tar.com");
	getFile(cmdLink, "bin.new/cmd.com");
	getFile(termLink, "bin.new/term.com");
	getFile(updLink, "bin.new/updater.com");
	getFile(netIniLink, "bin.new/net.ini");
}

unsigned char ren2old(unsigned char *name)
{
	static unsigned char src[32];
	static unsigned char dst[40];
	unsigned char counter;

	if (name == 0 || name[0] == 0)
	{
		clearStatus();
		printf("empty name to rename");
		return 254;
	}
	strncpy((char *)src, (const char *)name, sizeof(src) - 1);
	src[sizeof(src) - 1] = 0;

	counter = 255;
	sprintf((char *)dst, "%s.old", src);
	while (OS_RENAME(src, dst) != 0)
	{
		counter++;
		sprintf((char *)dst, "%s.%u", src, counter);
		if (counter == 254)
		{
			break;
		}
	}
	// 255 = OLD
	// 254 = no OLD
	return counter;
}

/*
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
*/

/*
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
*/

void restoreConfig(unsigned char oldBinExt)
{
	unsigned char count;
	if (oldBinExt == 254)
	{
		clearStatus();
		printf("restoreConfig() skipped");
		getchar();
		return;
	}

	errn = OS_CHDIR("/");
	errn = OS_RENAME("bin/autoexec.bat", "bin/autoexec.bat.new");
	errn = OS_RENAME("bin/net.ini", "bin/net.ini.new");
	errn = OS_RENAME("bin/nv.ext", "bin/nv.ext.new");
	errn = OS_RENAME("bin/gp/gp.ini", "bin/gp/gp.ini.new");
	errn = OS_RENAME("/bin/browser/index.gph", "/bin/browser/index.gph.new");
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
		sprintf(netbuf, "copy bin.%u/autoexec.bat bin/autoexec.bat", oldBinExt);
		OS_SHELL((void *)netbuf);
		sprintf(netbuf, "copy bin.%u/net.ini bin/net.ini", oldBinExt);
		OS_SHELL((void *)netbuf);
		sprintf(netbuf, "copy bin.%u/nv.ext bin/nv.ext", oldBinExt);
		OS_SHELL((void *)netbuf);
		sprintf(netbuf, "copy bin.%u/gp/gp.ini bin/gp/gp.ini", oldBinExt);
		OS_SHELL((void *)netbuf);
		sprintf(netbuf, "copy bin.%u/browser/index.gph bin/browser/index.gph", oldBinExt);
		OS_SHELL((void *)netbuf);
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

// Download, backup, unpack release.zip
void fullUpdate(void)
{
	BOX(1, 1, 80, 25, 40, 176);
	cw.x = 20;
	cw.y = 5;
	cw.w = 40;
	cw.h = 10;
	cw.text = 97;
	cw.back = 45;

	AT(1, 1);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("[%u:%u]              [FULL UPDATE - UPDATING ALL SYSTEM FILES]     ", netDriver, comType);
	strcpy(cw.tittle, "nedoOS FULL updater ");
	strcat(cw.tittle, uVer);
	getConfig();

	strcat(cw.tittle, " (");
	strcat(cw.tittle, config.machineName);
	strcat(cw.tittle, ")");
	drawWindow(cw);

	OS_CHDIR("/");
	OS_DELETE("release.zip");
	OS_SHELL("time2 >updlog.txt");

	clearStatus();
	AT(cw.x + 2, cw.y + 3);
	printf("1. Downloading release.zip.");
	YIELD();
	errn = getFile(relLink, "release.zip"); //  Downloading the file
	OS_SHELL("time2 >>updlog.txt");
	AT(cw.x + 2, cw.y + 4);
	printf("2. Downloading pkunzip.com.");
	YIELD();
	getFile(pkunzipLink, "pkunzip.com");
	getFile(cmdLink, "cmd.com");
	getFile(newsLink, "updater.new");
	clearStatus();
	AT(cw.x + 2, cw.y + 5);
	printf("3. Backuping old system.");
	YIELD();
	oldBinExt = ren2old("bin");
	ren2old("doc");
	ren2old("ini");
	ren2old("nedodemo");
	ren2old("nedogame");
	BOX(1, 1, 80, 25, 40, 32);
	AT(1, 1);
	printf("4. Unpacking release.zip. Its take about 5 hours. Please wait.\r\n");
	printNews();
	YIELD();
	OS_MKDIR("bin");
	OS_RENAME("cmd.com", "bin/cmd.com");
	OS_SHELL("pkunzip.com release.zip");

	BOX(1, 1, 80, 25, 40, 176);
	drawWindow(cw);
	printf("[%u:%u]              [FULL UPDATE - UPDATING ALL SYSTEM FILES]    [Build:%s]", netDriver, comType, __TIME__);
	clearStatus();
	AT(cw.x + 2, cw.y + 3);
	printf("1. Downloading release.zip.");
	AT(cw.x + 2, cw.y + 4);
	printf("2. Downloading pkunzip.com.");
	AT(cw.x + 2, cw.y + 5);
	printf("3. Backuping old system.");
	AT(cw.x + 2, cw.y + 6);
	printf("4. Unpacking release.zip.");
	AT(cw.x + 2, cw.y + 7);
	printf("5. Restoring configs.");
	YIELD();
}

// Updating only BIN folders, where is OS lives.
void binUpdate(void)
{
	BOX(1, 1, 80, 25, 40, 176);
	cw.x = 20;
	cw.y = 5;
	cw.w = 40;
	cw.h = 13;
	cw.text = 97;
	cw.back = 44;

	AT(1, 1);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("[%u:%u]            [STANDART UPDATE - UPDATING ONLY BIN FOLDER]   [Build:%s]", netDriver, comType, __TIME__);
	strcpy(cw.tittle, "nedoOS BIN updater ");
	strcat(cw.tittle, uVer);
	getConfig();
	strcat(cw.tittle, " (");
	strcat(cw.tittle, config.machineName);
	strcat(cw.tittle, ")");
	drawWindow(cw);

	clearStatus();
	AT(cw.x + 2, cw.y + 10);
	printf(">To full update start'updater.com -f'<");
	YIELD();

	OS_CHDIR("/");
	delete("bin.new");
	if (OS_MKDIR("bin.new") != 0)
	{
		fatalError("Please delete 'bin.new' and try again");
	}

	OS_SHELL("time2 >updlog.txt");

	AT(cw.x + 2, cw.y + 3);
	printf("1. Downloading bin.zip.");
	YIELD();
	getFile(binLink, "bin.new/bin.zip"); //  Downloading the file
	OS_SHELL("time2 >>updlog.txt");
	clearStatus();
	AT(cw.x + 2, cw.y + 4);
	printf("2. Downloading tools.");
	getTools();

	BOX(1, 1, 80, 25, 40, 32);
	AT(1, 1);
	printf("3. Unpacking bin.zip. Its take about 10 minutes. Please wait.\r\n");
	printNews();
	YIELD();

	OS_CHDIR("bin.new");
	OS_SHELL("pkunzip.com bin.zip");

	BOX(1, 1, 80, 25, 40, 176);
	AT(1, 1);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("[%u:%u]            [STANDART UPDATE - UPDATING ONLY BIN FOLDER]   [Build:%s]", netDriver, comType, __TIME__);
	drawWindow(cw);

	ATRIB(cw.text);
	ATRIB(cw.back);
	AT(cw.x + 2, cw.y + 3);
	puts("1. Downloading bin.zip.");
	AT(cw.x + 2, cw.y + 4);
	puts("2. Downloading tools.");
	AT(cw.x + 2, cw.y + 5);
	puts("3. Unpacking bin.zip.");
	AT(cw.x + 2, cw.y + 6);
	puts("4. Backuping bin to bin.old.");
	YIELD();
	clearStatus();
	OS_CHDIR("/");
	oldBinExt = ren2old("bin");
	AT(cw.x + 2, cw.y + 7);
	puts("5. Renaming bin.new to bin.");
	YIELD();
	clearStatus();
	OS_RENAME("bin.new", "bin");
	YIELD();
	clearStatus();
	AT(cw.x + 2, cw.y + 8);
	printf("6. Downloading kernel [%s].", config.machineName);
	errn = OS_CHDIR("/");
	errn = getFile(config.kernelLink, config.kernelName); //  Downloading the file
	AT(cw.x + 2, cw.y + 9);
	ATRIB(cw.text);
	ATRIB(cw.back);
	printf("7. Restoring configs."); // in main loop
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

void setUpdateSource(unsigned char mirror)
{
	if (mirror)
	{
		strcpy(updateHost, "kulich.su");
		strcpy(userAgent, " HTTP/1.1\r\nHost: kulich.su\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)\r\n\r\n");
		strcpy(binLink, "http://kulich.su/images/sysbin.zip");
		strcpy(relLink, "http://kulich.su/images/release.zip");
		strcpy(pkunzipLink, "/svn/dl.php?repname=nedoos&path=/nedoos/release/bin/pkunzip.com");
		strcpy(tarLink, "/svn/dl.php?repname=nedoos&path=/nedoos/release/bin/tar.com");
		strcpy(cmdLink, "/svn/dl.php?repname=nedoos&path=/nedoos/release/bin/cmd.com");
		strcpy(termLink, "/svn/dl.php?repname=nedoos&path=/nedoos/release/bin/term.com");
		strcpy(updLink, "/svn/dl.php?repname=nedoos&path=/nedoos/release/bin/updater.com");
		strcpy(newsLink, "/svn/dl.php?repname=nedoos&path=/nedoos/release/doc/updater.new");
		strcpy(wizNetLink, "/svn/dl.php?repname=nedoos&path=/nedoos/release/bin/wizcfg.com");
		strcpy(netIniLink, "/svn/dl.php?repname=nedoos&path=/nedoos/release/bin/net.ini");
	}
	else
	{
		strcpy(updateHost, "nedoos.ru");
		strcpy(userAgent, " HTTP/1.1\r\nHost: nedoos.ru\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)\r\n\r\n");
		strcpy(binLink, "http://nedoos.ru/images/sysbin.zip");
		strcpy(relLink, "http://nedoos.ru/images/release.zip");
		strcpy(pkunzipLink, "/svn/dl.php?repname=NedoOS&path=/release/bin/pkunzip.com");
		strcpy(tarLink, "/svn/dl.php?repname=NedoOS&path=/release/bin/tar.com");
		strcpy(cmdLink, "/svn/dl.php?repname=NedoOS&path=/release/bin/cmd.com");
		strcpy(termLink, "/svn/dl.php?repname=NedoOS&path=/release/bin/term.com");
		strcpy(updLink, "/svn/dl.php?repname=NedoOS&path=/release/bin/updater.com");
		strcpy(newsLink, "/svn/dl.php?repname=NedoOS&path=/release/doc/updater.new");
		strcpy(wizNetLink, "/svn/dl.php?repname=NedoOS&path=/release/bin/wizcfg.com");
		strcpy(netIniLink, "/svn/dl.php?repname=NedoOS&path=/release/bin/net.ini");
	}
}

void parseArgs(int argc, const char *argv[])
{
	int i;
	const char *a;
	unsigned char c;
	unsigned char bad = 0;

	forceEsp = 0;
	doFullUpdate = 0;
	useMirror = 0;

	for (i = 1; i < argc; i++)
	{
		a = argv[i];
		if (a == 0 || a[0] == 0)
		{
			continue;
		}

		if (a[0] == '-' || a[0] == '/')
		{
			a++;
			if (*a == 0)
			{
				bad = 1;
				break;
			}
			while (*a)
			{
				c = (unsigned char)*a++;
				if (c >= 'A' && c <= 'Z')
				{
					c = (unsigned char)(c + 32);
				}
				switch (c)
				{
				case 'e':
					forceEsp = 1;
					break;
				case 'f':
					doFullUpdate = 1;
					break;
				case 'm':
					useMirror = 1;
					break;
				default:
					bad = 1;
					break;
				}
				if (bad)
				{
					break;
				}
			}
		}
		else
		{
			/* Legacy single-token forms */
			if (a[0] == 'E' && a[1] == 0)
			{
				forceEsp = 1;
				doFullUpdate = 1;
			}
			else if ((a[0] == 'F' || a[0] == 'f') && a[1] == 0)
			{
				doFullUpdate = 1;
			}
			else if (a[0] == 'e' && a[1] == 0)
			{
				forceEsp = 1;
			}
			else if ((a[0] == 'm' || a[0] == 'M') && a[1] == 0)
			{
				useMirror = 1;
			}
			else
			{
				bad = 1;
			}
		}
		if (bad)
		{
			break;
		}
	}

	if (bad)
	{
		AT(1, 1);
		printf("Usage: updater.com [-e] [-f] [-m]\r\n");
		printf("  -e  ESP-COM mode (override network.ini)\r\n");
		printf("  -f  full update (all system files)\r\n");
		printf("  -m  use mirror kulich.su\r\n");
		fatalError("Bad command line");
	}
}

C_task main(int argc, const char *argv[])
{
	unsigned char test;
	os_initstdio();

	parseArgs(argc, argv);
	setUpdateSource(useMirror);

	targetadr.family = AF_INET;
	targetadr.porth = 00;
	targetadr.portl = 80;
	targetadr.b1 = 31;
	targetadr.b2 = 31;
	targetadr.b3 = 65;
	targetadr.b4 = 35;

	netDriver = readParamFromIni();
	clearStatus();
	// puts("network.ini loaded.");
	// YIELD();
	OS_GETPATH(curPath);
	curLetter = curPath[0];

	clearStatus();
	if (forceEsp)
	{
		printf("forced ESP-COM\r\n");
		netDriver = 1;
	}
	if (useMirror)
	{

		printf("forced Mirror %s\r\n", updateHost);
	}

	switch (netDriver)
	{
	case 0:
		get_dns();
		test = dnsResolve(updateHost);
		if (!test)
		{
			sprintf(cmd, "Check connection to %s!", updateHost);
			fatalError(cmd);
		}
		break;
	case 1:
		loadEspConfig();
		uart_init(divider);
		espReBoot();
		break;
	case 2:
		OS_ESPINIT();
		EspGetDns();
		break;
	}

	if (doFullUpdate)
	{
		fullUpdate();
	}
	else
	{
		binUpdate();
	}

	restoreConfig(oldBinExt);
	OS_DELETE("bin/bin.zip");
	OS_DELETE("pkunzip.com");
	clearStatus();
	infoBox("System Updated successfully!");
	OS_SHELL("time2 >>updlog.txt");
	delayLongKey(5000);
	// getchar();
	//   OS_DELETE("release.zip");
	quit();
}
